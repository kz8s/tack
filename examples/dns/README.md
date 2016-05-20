# Testing DNS

Ported from [kubernetes/kubernetes/examples/cluster-dns](https://github.com/kubernetes/kubernetes/tree/release-1.2/examples/cluster-dns).


```bash
kubectl create namespace dev
kubectl create namespace prod
kubectl label namespace dev name=dev
kubectl label namespace prod name=prod 
```
