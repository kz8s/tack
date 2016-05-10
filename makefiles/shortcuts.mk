addons:
	kubectl get pods --namespace=kube-system

dns:
	kubectl exec busybox -- nslookup kubernetes

nodes:
	kubectl get nodes

.PHONY: addons dns nodes
