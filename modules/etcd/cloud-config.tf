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
    data-dir: /media/etcd2
    discovery-srv: ${ internal-tld }
    initial-advertise-peer-urls: https://${ fqdn }:2380
    initial-cluster-state: new
    initial-cluster-token: ${ cluster-token }
    # key-file: /etc/kubernetes/ssl/k8s-etcd-key.pem
    listen-client-urls: http://0.0.0.0:2379
    listen-peer-urls: https://0.0.0.0:2380
    name: ${ hostname }
    peer-trusted-ca-file: /etc/kubernetes/ssl/ca.pem
    peer-client-cert-auth: true
    peer-cert-file: /etc/kubernetes/ssl/k8s-etcd.pem
    peer-key-file: /etc/kubernetes/ssl/k8s-etcd-key.pem

  units:
    - name: format-ebs-volume.service
      command: start
      content: |
        [Unit]
        Description=Formats the ebs volume
        After=dev-xvdf.device
        Requires=dev-xvdf.device
        [Service]
        ExecStart=/bin/bash -c "(/usr/sbin/blkid -t TYPE=ext4 | grep /dev/xvdf) || (/usr/sbin/wipefs -fa /dev/xvdf && /usr/sbin/mkfs.ext4 /dev/xvdf)"
        RemainAfterExit=yes
        Type=oneshot

    - name: media-etcd2.mount
      command: start
      content: |
        [Unit]
        Description=Mount ebs to /media/etcd2
        Requires=format-ebs-volume.service
        After=format-ebs-volume.service
        [Mount]
        What=/dev/xvdf
        Where=/media/etcd2
        Type=ext4

    - name: prepare-etcd-data-dir.service
      command: start
      content: |
        [Unit]
        Description=Prepares the etcd data directory
        Requires=media-etcd2.mount
        After=media-etcd2.mount
        Before=etcd2.service
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/bin/chown -R etcd:etcd /media/etcd2

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

    - name: kubelet.service
      command: start
      content: |
        [Unit]
        ConditionFileIsExecutable=/usr/lib/coreos/kubelet-wrapper
        [Service]
        Environment="KUBELET_ACI=${ hyperkube-image }"
        Environment="KUBELET_VERSION=${ hyperkube-tag }"
        Environment="RKT_OPTS=\
          --volume dns,kind=host,source=/etc/resolv.conf \
          --mount volume=dns,target=/etc/resolv.conf \
          --volume rkt,kind=host,source=/opt/bin/host-rkt \
          --mount volume=rkt,target=/usr/bin/rkt \
          --volume var-lib-rkt,kind=host,source=/var/lib/rkt \
          --mount volume=var-lib-rkt,target=/var/lib/rkt \
          --volume stage,kind=host,source=/tmp \
          --mount volume=stage,target=/tmp \
          --volume var-log,kind=host,source=/var/log \
          --mount volume=var-log,target=/var/log"
        ExecStartPre=/usr/bin/mkdir -p /var/log/containers
        ExecStartPre=/usr/bin/mkdir -p /var/lib/kubelet
        ExecStartPre=/usr/bin/mount --bind /var/lib/kubelet /var/lib/kubelet
        ExecStartPre=/usr/bin/mount --make-shared /var/lib/kubelet
        ExecStart=/usr/lib/coreos/kubelet-wrapper \
          --allow-privileged=true \
          --api-servers=http://127.0.0.1:8080 \
          --cloud-provider=aws \
          --cluster-dns=${ dns-service-ip } \
          --cluster-domain=${ cluster-domain } \
          --config=/etc/kubernetes/manifests \
          --register-schedulable=false
        Restart=always
        RestartSec=5
        [Install]
        WantedBy=multi-user.target

  update:
    reboot-strategy: etcd-lock

write-files:
  - path: /opt/bin/host-rkt
    permissions: 0755
    owner: root:root
    content: |
      #!/bin/sh
      exec nsenter -m -u -i -n -p -t 1 -- /usr/bin/rkt "$@"

  - path: /etc/kubernetes/manifests/kube-apiserver.yml
    content: |
      apiVersion: v1
      kind: Pod
      metadata:
        name: kube-apiserver
        namespace: kube-system
      spec:
        hostNetwork: true
        containers:
        - name: kube-apiserver
          image: ${ hyperkube }
          command:
          - /hyperkube
          - apiserver
          - --admission-control=LimitRanger
          - --admission-control=NamespaceExists
          - --admission-control=NamespaceLifecycle
          - --admission-control=ResourceQuota
          - --admission-control=SecurityContextDeny
          - --admission-control=ServiceAccount
          - --allow-privileged=true
          - --client-ca-file=/etc/kubernetes/ssl/ca.pem
          - --cloud-provider=aws
          - --etcd-servers=http://etcd.${ internal-tld }:2379
          - --insecure-bind-address=0.0.0.0
          - --secure-port=443
          - --service-account-key-file=/etc/kubernetes/ssl/k8s-apiserver-key.pem
          - --service-cluster-ip-range=${ service-cluster-ip-range }
          - --tls-cert-file=/etc/kubernetes/ssl/k8s-apiserver.pem
          - --tls-private-key-file=/etc/kubernetes/ssl/k8s-apiserver-key.pem
          - --v=2
          livenessProbe:
            httpGet:
              host: 127.0.0.1
              port: 8080
              path: /healthz
            initialDelaySeconds: 15
            timeoutSeconds: 15
          ports:
          - containerPort: 443
            hostPort: 443
            name: https
          - containerPort: 8080
            hostPort: 8080
            name: local
          volumeMounts:
          - mountPath: /etc/kubernetes/ssl
            name: ssl-certs-kubernetes
            readOnly: true
          - mountPath: /etc/ssl/certs
            name: ssl-certs-host
            readOnly: true
        volumes:
        - hostPath:
            path: /etc/kubernetes/ssl
          name: ssl-certs-kubernetes
        - hostPath:
            path: /usr/share/ca-certificates
          name: ssl-certs-host

  - path: /etc/kubernetes/manifests/kube-controller-manager.yml
    content: |
      apiVersion: v1
      kind: Pod
      metadata:
        name: kube-controller-manager
        namespace: kube-system
      spec:
        hostNetwork: true
        containers:
        - name: kube-controller-manager
          image: ${ hyperkube }
          command:
          - /hyperkube
          - controller-manager
          - --cloud-provider=aws
          - --leader-elect=true
          - --master=http://127.0.0.1:8080
          - --root-ca-file=/etc/kubernetes/ssl/ca.pem
          - --service-account-private-key-file=/etc/kubernetes/ssl/k8s-apiserver-key.pem
          resources:
            requests:
              cpu: 200m
          livenessProbe:
            httpGet:
              host: 127.0.0.1
              path: /healthz
              port: 10252
            initialDelaySeconds: 15
            timeoutSeconds: 1
          volumeMounts:
          - mountPath: /etc/kubernetes/ssl
            name: ssl-certs-kubernetes
            readOnly: true
          - mountPath: /etc/ssl/certs
            name: ssl-certs-host
            readOnly: true
        volumes:
        - hostPath:
            path: /etc/kubernetes/ssl
          name: ssl-certs-kubernetes
        - hostPath:
            path: /usr/share/ca-certificates
          name: ssl-certs-host

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
          image: ${ hyperkube }
          command:
          - /hyperkube
          - proxy
          - --master=http://127.0.0.1:8080
          - --proxy-mode=iptables
          securityContext:
            privileged: true
          volumeMounts:
          - mountPath: /etc/ssl/certs
            name: ssl-certs-host
            readOnly: true
        volumes:
        - hostPath:
            path: /usr/share/ca-certificates
          name: ssl-certs-host

  - path: /etc/kubernetes/manifests/kube-scheduler.yml
    content: |
      apiVersion: v1
      kind: Pod
      metadata:
        name: kube-scheduler
        namespace: kube-system
      spec:
        hostNetwork: true
        containers:
        - name: kube-scheduler
          image: ${ hyperkube }
          command:
          - /hyperkube
          - scheduler
          - --leader-elect=true
          - --master=http://127.0.0.1:8080
          resources:
            requests:
              cpu: 100m
          livenessProbe:
            httpGet:
              host: 127.0.0.1
              path: /healthz
              port: 10251
            initialDelaySeconds: 15
            timeoutSeconds: 1

  - path: /etc/logrotate.d/docker-containers
    content: |
      /var/lib/docker/containers/*/*.log {
        rotate 7
        daily
        compress
        size=1M
        missingok
        delaycompress
        copytruncate
      }

EOF

  vars {
    bucket = "${ var.bucket-prefix }"
    cluster-domain = "${ var.cluster-domain }"
    cluster-token = "etcd-cluster-${ var.name }"
    dns-service-ip = "${ var.dns-service-ip }"
    etc-tar = "/manifests/etc.tar"
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    hostname = "etcd${ count.index + 1 }"
    hyperkube = "${ var.hyperkube-image }:${ var.hyperkube-tag }"
    hyperkube-image = "${ var.hyperkube-image }"
    hyperkube-tag = "${ var.hyperkube-tag }"
    internal-tld = "${ var.internal-tld }"
    pod-ip-range = "${ var.pod-ip-range }"
    region = "${ var.region }"
    service-cluster-ip-range = "${ var.service-cluster-ip-range }"
    ssl-tar = "ssl/k8s-apiserver.tar"
  }
}
