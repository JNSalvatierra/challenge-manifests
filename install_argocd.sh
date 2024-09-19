#!/bin/bash
#Instalar ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

#Clonar el repo con los manifiestos
git clone https://github.com/JNSalvatierra/challenge-manifests.git

#Aplicar los .yml que se encuentren dentro del directorio argocd (Apps ArgoCD)
for manifiesto in ./challenge-manifests/argocd/*.yml; do
	if [[ -f "$manifiesto" ]]; then
		echo "Aplicando $manifiesto..."
		kubectl apply -f "$manifiesto"
	else
		"No hay manifiestos para aplicar en el directorio"
	fi
done

#Cambiar la Pass de usuario Admin y Forwardear ArgoCD para poder utilizarlo.
sleep 10
argo_pass=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
kubectl port-forward svc/argocd-server -n argocd 8081:443 > /dev/null 2>&1 &
sleep 10
argocd login localhost:8081 --username admin --password $argo_pass --insecure
argocd account update-password --current-password $argo_pass --new-password password
