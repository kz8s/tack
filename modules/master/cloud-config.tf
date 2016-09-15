resource "template_file" "cloud-config" {
  template = <<EOF
#cloud-config

---
coreos:

  etcd2:
    discovery-srv: ${ internal-tld }
    peer-trusted-ca-file: /etc/kubernetes/ssl/ca.pem
    peer-client-cert-auth: true
    peer-cert-file: /etc/kubernetes/ssl/k8s-apiserver.pem
    peer-key-file: /etc/kubernetes/ssl/k8s-apiserver-key.pem
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

    - name: etcd2.service
      command: start

    - name: flanneld.service
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Service]
            ExecStartPre=-/usr/bin/etcdctl mk /coreos.com/network/config \
              '{ "Network": "${ pod-ip-range }", "Backend": { "Type": "vxlan" } }'
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
        ConditionFileIsExecutable=/usr/lib/coreos/kubelet-wrapper
        Requires=docker.socket
        [Service]
        Environment="KUBELET_VERSION=${ coreos-hyperkube-tag }"
        Environment="RKT_OPTS=\
        --volume=resolv,kind=host,source=/etc/resolv.conf \
        --mount volume=resolv,target=/etc/resolv.conf"
        ExecStart=/usr/lib/coreos/kubelet-wrapper \
          --allow-privileged=true \
          --api-servers=http://127.0.0.1:8080 \
          --cloud-provider=aws \
          --cluster-dns=${ dns-service-ip } \
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
    coreos-hyperkube-image = "${ var.coreos-hyperkube-image }"
    coreos-hyperkube-tag = "${ var.coreos-hyperkube-tag }"
    dns-service-ip = "${ var.dns-service-ip }"
    etc-tar = "/manifests/etc.tar"
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    hostname = "etcd${ count.index + 1 }"
    internal-tld = "${ var.internal-tld }"
    log-group = "k8s-${ var.name }"
    pod-ip-range = "${ var.pod-ip-range }"
    region = "${ var.region }"
    service-ip-range = "${ var.service-ip-range }"
    ssl-tar = "ssl/k8s-apiserver.tar"
  }
}
