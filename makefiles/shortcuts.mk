addons:
	kubectl get pods --namespace=kube-system

dns:
	kubectl exec busybox -- nslookup kubernetes

nodes:
	kubectl get nodes

pods:
	@kubectl get pods --all-namespaces

.PHONY: addons dns nodes pods
