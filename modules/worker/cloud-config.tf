resource "template_file" "cloud-config" {

  template = <<EOF
#cloud-config

---
coreos:

  etcd2:
    discovery-srv: ${ internal-tld }
    proxy: on

  units:
    - name: format-ephemeral.service
      command: start
      content: |
        [Unit]
        Description=Formats the ephemeral drive
        After=dev-xvdf.device
        Requires=dev-xvdf.device
        [Service]
        ExecStart=/usr/sbin/wipefs -f /dev/xvdf
        ExecStart=/usr/sbin/mkfs.ext4 -F /dev/xvdf
        RemainAfterExit=yes
        Type=oneshot

    - name: var-lib-docker.mount
      command: start
      content: |
        [Unit]
        Description=Mount ephemeral to /var/lib/docker
        Requires=format-ephemeral.service
        After=format-ephemeral.service
        Before=docker.service
        [Mount]
        What=/dev/xvdf
        Where=/var/lib/docker
        Type=ext4

    - name: etcd2.service
      command: start

    - name: flanneld.service
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Service]
            Restart=always
            RestartSec=10

    - name: docker.service
      command: start
      drop-ins:
        - name: 40-flannel.conf
          content: |
            [Unit]
            After=flanneld.service
            Requires=flanneld.service
            [Service]
            Restart=always
            RestartSec=10
        - name: awslogs.conf
          content: |
            [Service]
            Environment="DOCKER_OPTS=--log-driver=awslogs --log-opt awslogs-region=us-west-1 --log-opt awslogs-group=k8s-testing"

    - name: download-kubernetes.service
      command: start
      content: |
        [Unit]
        After=network-online.target
        Description=Download Kubernetes Binaries
        Documentation=https://github.com/kubernetes/kubernetes
        Requires=network-online.target

        [Service]
        Environment=K8S_VER=v1.1.8
        Environment="K8S_URL=https://storage.googleapis.com/kubernetes-release/release"
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStart=/usr/bin/curl -L -o /opt/bin/kubectl $${K8S_URL}/$${K8S_VER}/bin/linux/amd64/kubectl
        ExecStart=/usr/bin/curl -L -o /opt/bin/kubelet $${K8S_URL}/$${K8S_VER}/bin/linux/amd64/kubelet
        ExecStart=/usr/bin/chmod +x /opt/bin/kubectl
        ExecStart=/usr/bin/chmod +x /opt/bin/kubelet
        RemainAfterExit=yes
        Type=oneshot

    - name: s3-iam-get.service
      command: start
      content: |
        [Unit]
        After=network-online.target
        Description=Install s3-iam-get
        Requires=network-online.target
        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStart=/usr/bin/curl -L -o /opt/bin/s3-iam-get \
          https://raw.githubusercontent.com/kz8s/s3-iam-get/master/s3-iam-get
        ExecStart=/usr/bin/chmod +x /opt/bin/s3-iam-get
        RemainAfterExit=yes
        Type=oneshot

    - name: get-ssl.service
      command: start
      content: |
        [Unit]
        After=s3-iam-get.service
        Description=Get ssl artifacts from s3 bucket using IAM role
        Requires=s3-iam-get.service
        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /etc/kubernetes/ssl
        ExecStart=/bin/sh -c "/opt/bin/s3-iam-get ${ ssl-tar } | tar xv -C /etc/kubernetes/ssl/"
        ExecStartPost=/bin/sh -c "/usr/bin/chmod 600 /etc/kubernetes/ssl/*"
        RemainAfterExit=yes
        Type=oneshot

    - name: kubelet.service
      command: start
      content: |
        [Unit]
        After=docker.socket
        ConditionFileIsExecutable=/opt/bin/kubectl
        Requires=docker.socket
        [Service]
        ExecStart=/opt/bin/kubelet \
          --allow-privileged=true \
          --api-servers=http://master.k8s:8080 \
          --cloud-provider=aws \
          --cluster-dns=10.3.0.10 \
          --cluster-domain=cluster.local \
          --config=/etc/kubernetes/manifests \
          --kubeconfig=/etc/kubernetes/kubeconfig.yml \
          --register-node=true \
          --tls-cert-file=/etc/kubernetes/ssl/k8s-worker.pem \
          --tls-private-key-file=/etc/kubernetes/ssl/k8s-worker-key.pem
        Restart=always
        RestartSec=5
        [Install]
        WantedBy=multi-user.target

  update:
    reboot-strategy: etcd-lock

write-files:
  - path: /etc/kubernetes/kubeconfig.yml
    content: |
      apiVersion: v1
      kind: Config
      clusters:
        - name: local
          cluster:
            certificate-authority: /etc/kubernetes/ssl/ca.pem
      users:
        - name: kubelet
          user:
            client-certificate: /etc/kubernetes/ssl/k8s-worker.pem
            client-key: /etc/kubernetes/ssl/k8s-worker-key.pem
      contexts:
        - context:
            cluster: local
            user: kubelet
          name: kubelet-context
      current-context: kubelet-context

  - path: /etc/kubernetes/manifests/kube-proxy.yml
    content: |
      apiVersion: v1
      kind: Pod
      metadata:
        name: kube-proxy
        namespace: kube-system
      spec:
        hostNetwork: true
        containers:
        - name: kube-proxy
          image: gcr.io/google_containers/hyperkube:v1.1.8
          command:
          - /hyperkube
          - proxy
          - --kubeconfig=/etc/kubernetes/kubeconfig.yml
          - --master=https://master.k8s
          - --proxy-mode=iptables
          securityContext:
            privileged: true
          volumeMounts:
            - mountPath: /etc/ssl/certs
              name: "ssl-certs"
            - mountPath: /etc/kubernetes/kubeconfig.yml
              name: "kubeconfig"
              readOnly: true
            - mountPath: /etc/kubernetes/ssl
              name: "etc-kube-ssl"
              readOnly: true
        volumes:
          - name: "ssl-certs"
            hostPath:
              path: "/usr/share/ca-certificates"
          - name: "kubeconfig"
            hostPath:
              path: "/etc/kubernetes/kubeconfig.yml"
          - name: "etc-kube-ssl"
            hostPath:
              path: "/etc/kubernetes/ssl"
EOF

  vars {
    internal-tld = "${ var.internal-tld }"
    ssl-tar = "s3://${ var.bucket-prefix }/ssl/k8s-worker.tar"
  }
}
