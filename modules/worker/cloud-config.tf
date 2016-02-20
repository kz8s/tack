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

    - name: download-kubernetes.service
      command: start
      content: |
        [Unit]
        After=network-online.target
        Description=Download Kubernetes Binaries
        Documentation=https://github.com/kubernetes/kubernetes
        Requires=network-online.target

        [Service]
        Environment=K8S_VER=v1.1.7
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

    - name: get-manifests.service
      command: start
      content: |
        [Unit]
        After=s3-iam-get.service
        Description=Get kubernetes manifest from s3 bucket using IAM role
        Requires=s3-iam-get.service
        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /etc/kubernetes/manifests
        ExecStart=/bin/sh -c "/opt/bin/s3-iam-get ${ worker-tar } | tar xv -C /etc/kubernetes/manifests/"
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
          --kubeconfig=/etc/kubernetes/worker-kubeconfig.yaml \
          --register-node=true \
          --tls-cert-file=/etc/kubernetes/ssl/worker.pem \
          --tls-private-key-file=/etc/kubernetes/ssl/worker-key.pem
        Restart=always
        RestartSec=5
        [Install]
        WantedBy=multi-user.target

  update:
    reboot-strategy: etcd-lock
EOF

  vars {
    internal-tld = "${ var.internal-tld }"
    ssl-tar = "s3://${ var.bucket-prefix }/ssl/k8s-worker.tar"
    worker-tar = "s3://${ var.bucket-prefix }/manifests/worker.tar"
  }
}
