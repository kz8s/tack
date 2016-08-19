resource "template_file" "cloud-config" {

  template = <<EOF
#cloud-config

---
coreos:

  etcd2:
    discovery-srv: ${ internal-tld }
    peer-trusted-ca-file: /etc/kubernetes/ssl/ca.pem
    peer-client-cert-auth: true
    peer-cert-file: /etc/kubernetes/ssl/k8s-worker.pem
    peer-key-file: /etc/kubernetes/ssl/k8s-worker-key.pem
    proxy: on

  units:
    - name: prefetch-hyperkube-container.service
      command: start
      content: |
        [Unit]
        Description=Accelerate spin up by prefetching hyperkube
        After=network-online.target
        [Service]
        ExecStart=/usr/bin/rkt fetch --trust-keys-from-https \
          ${ coreos-hyperkube-image }:${ coreos-hyperkube-tag }
        RemainAfterExit=yes
        Type=oneshot

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

    - name: s3-get-presigned-url.service
      command: start
      content: |
        [Unit]
        After=network-online.target
        Description=Install s3-get-presigned-url
        Requires=network-online.target
        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStart=/usr/bin/curl -L -o /opt/bin/s3-get-presigned-url \
          https://github.com/kz8s/s3-get-presigned-url/releases/download/v0.1/s3-get-presigned-url_linux_amd64
        ExecStart=/usr/bin/chmod +x /opt/bin/s3-get-presigned-url
        RemainAfterExit=yes
        Type=oneshot

    - name: get-ssl.service
      command: start
      content: |
        [Unit]
        After=s3-get-presigned-url.service
        Description=Get ssl artifacts from s3 bucket using IAM role
        Requires=s3-get-presigned-url.service
        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /etc/kubernetes/ssl
        ExecStart=/bin/sh -c "/usr/bin/curl $(/opt/bin/s3-get-presigned-url \
          ${ region } ${ bucket } ${ ssl-tar }) | tar xv -C /etc/kubernetes/ssl/"
        RemainAfterExit=yes
        Type=oneshot

    - name: kubelet.service
      command: start
      content: |
        [Unit]
        After=docker.socket
        ConditionFileIsExecutable=/usr/lib/coreos/kubelet-wrapper
        Requires=docker.socket
        [Service]
        Environment="KUBELET_VERSION=${ coreos-hyperkube-tag }"
        Environment="RKT_OPTS=\
        --volume=resolv,kind=host,source=/etc/resolv.conf \
        --mount volume=resolv,target=/etc/resolv.conf"
        ExecStart=/usr/lib/coreos/kubelet-wrapper \
          --allow-privileged=true \
          --api-servers=http://master.${ internal-tld }:8080 \
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
          image: ${ coreos-hyperkube-image }:${ coreos-hyperkube-tag }
          command:
          - /hyperkube
          - proxy
          - --kubeconfig=/etc/kubernetes/kubeconfig.yml
          - --master=https://master.${ internal-tld }
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
    bucket = "${ var.bucket-prefix }"
    coreos-hyperkube-image = "${ var.coreos-hyperkube-image }"
    coreos-hyperkube-tag = "${ var.coreos-hyperkube-tag }"
    internal-tld = "${ var.internal-tld }"
    region = "${ var.region }"
    ssl-tar = "/ssl/k8s-worker.tar"
  }
}
