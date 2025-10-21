#Install ArgoCD

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Edit the service can change the service type from ClusterIP to NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}' 

Fetch Password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
