apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "KubeDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: ${DNS_SERVICE_IP}
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP

---

apiVersion: v1
kind: ReplicationController
metadata:
  name: kube-dns-v10
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    version: v10
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  selector:
    k8s-app: kube-dns
    version: v10
  template:
    metadata:
      labels:
        k8s-app: kube-dns
        version: v10
        kubernetes.io/cluster-service: "true"
    spec:
      containers:
      - name: kube2sky
        image: gcr.io/google_containers/kube2sky:1.12
        resources:
          limits:
            cpu: 100m
            memory: 50Mi
        args:
        # command = "/kube2sky"
        - -domain=cluster.local
        - -etcd-server=http://etcd.${INTERNAL_TLD}:2379
        - -kube_master_url=http://master.${INTERNAL_TLD}:8080
        - -v=6
        - -logtostderr
      - name: skydns
        image: kz8s/skydns:latest
        resources:
          limits:
            cpu: 100m
            memory: 50Mi
        args:
        # command = "/skydns"
        - -machines=http://etcd.${INTERNAL_TLD}:2379
        - -addr=0.0.0.0:53
        - -domain=cluster.local.
        # - -ns-rotate=false
        - -verbose=true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 1
          timeoutSeconds: 5
      - name: healthz
        image: gcr.io/google_containers/exechealthz:1.0
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
        args:
        - -cmd=nslookup kubernetes.default.svc.cluster.local 127.0.0.1 >/dev/null
        - -port=8080
        ports:
        - containerPort: 8080
          protocol: TCP
      dnsPolicy: Default
