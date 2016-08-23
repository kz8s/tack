addons:
	kubectl get pods --namespace=kube-system

dns:
	kubectl exec busybox -- nslookup kubernetes

nodes:
	kubectl get nodes

pods:
	@kubectl get po --namespace=kube-system | grep -v Running

.PHONY: addons dns nodes pods
