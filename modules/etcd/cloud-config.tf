resource "template_file" "cloud-config" {
  count = "${ length( split(",", var.etcd-ips) ) }"

  template = <<EOF
#cloud-config

---
coreos:

  etcd2:
    advertise-client-urls: http://${ fqdn }:2379
    # cert-file: /etc/kubernetes/ssl/k8s-etcd.pem
    # debug: true
    discovery-srv: ${ internal-tld }
    initial-advertise-peer-urls: https://${ fqdn }:2380
    initial-cluster-state: new
    initial-cluster-token: ${ cluster-token }
    # key-file: /etc/kubernetes/ssl/k8s-etcd-key.pem
    listen-client-urls: http://0.0.0.0:2379
    listen-peer-urls: https://0.0.0.0:2380
    name: ${ hostname }
    peer-ca-file: /etc/kubernetes/ssl/ca.pem
    peer-cert-file: /etc/kubernetes/ssl/k8s-etcd.pem
    peer-key-file: /etc/kubernetes/ssl/k8s-etcd-key.pem

  units:
    - name: etcd2.service
      command: start
      drop-ins:
        - name: wait-for-certs.conf
          content: |
            [Unit]
            After=get-ssl.service
            Requires=get-ssl.service

    - name: flanneld.service
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Service]
            ExecStartPre=-/usr/bin/etcdctl mk /coreos.com/network/config \
              '{ "Network": "10.3.0.0/16", "Backend": { "Type": "vxlan" } }'
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
        - name: overlay.conf
          content: |
            [Service]
            Environment="DOCKER_OPTS=--storage-driver=overlay"

    - name: download-kubernetes.service
      command: start
      content: |
        [Unit]
        After=network-online.target
        Description=Download Kubernetes Binaries
        Documentation=https://github.com/kubernetes/kubernetes
        Requires=network-online.target

        [Service]
        Environment=K8S_VER=${ k8s-version }
        Environment="K8S_URL=https://storage.googleapis.com/kubernetes-release/release"
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStart=/usr/bin/curl -L -o /opt/bin/kubectl $${K8S_URL}/$${K8S_VER}/bin/linux/amd64/kubectl
        ExecStart=/usr/bin/curl -L -o /opt/bin/kubelet $${K8S_URL}/$${K8S_VER}/bin/linux/amd64/kubelet
        ExecStart=/usr/bin/chmod +x /opt/bin/kubectl
        ExecStart=/usr/bin/chmod +x /opt/bin/kubelet
        RemainAfterExit=yes
        Type=oneshot

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

    - name: get-manifests.service
      command: start
      content: |
        [Unit]
        After=s3-get-presigned-url.service
        Description=Get kubernetes manifest from s3 bucket using IAM role
        Requires=s3-get-presigned-url.service
        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /etc/kubernetes/manifests
        ExecStart=/bin/sh -c "/usr/bin/curl $(/opt/bin/s3-get-presigned-url \
          ${ region } ${ bucket } ${ etc-tar }) | tar xv -C /etc/kubernetes/manifests/"
        RemainAfterExit=yes
        Type=oneshot

    - name: kubelet.service
      command: start
      content: |
        [Unit]
        After=docker.socket
        ConditionFileIsExecutable=/opt/bin/kubelet
        Requires=docker.socket
        [Service]
        ExecStart=/opt/bin/kubelet \
          --allow-privileged=true \
          --api-servers=http://127.0.0.1:8080 \
          --cloud-provider=aws \
          --cluster-dns=10.3.0.10 \
          --cluster-domain=cluster.local \
          --config=/etc/kubernetes/manifests \
          --register-schedulable=false
        Restart=always
        RestartSec=5
        [Install]
        WantedBy=multi-user.target

  update:
    reboot-strategy: etcd-lock
EOF

  vars {
    bucket = "${ var.bucket-prefix }"
    cluster-token = "etcd-cluster-${ var.name }"
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    hostname = "etcd${ count.index + 1 }"
    # hyperkube-image = "${ var.hyperkube-image }"
    internal-tld = "${ var.internal-tld }"
    k8s-version = "${ var.k8s-version }"
    log-group = "k8s-${ var.name }"
    region = "${ var.region }"
    ssl-tar = "ssl/k8s-apiserver.tar"
    etc-tar = "/manifests/etc.tar"
  }
}
