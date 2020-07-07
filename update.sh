# Delete all pods
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl delete -f srcs/nginx/nginx.yml
kubectl delete -f srcs/nginx/nginx.yml
kubectl delete -f srcs/mysql/my-sql.yml
kubectl delete -f srcs/wordpress/wordpress.yml
kubectl delete -f srcs/phpmyadmin/phpmyadmin.yml
kubectl delete -f srcs/ftps/ftps.yml


# Install metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# Build container
docker build -t services/nginx srcs/nginx/
sleep 1
docker build -t services/mysql srcs/mysql/
sleep 1
docker build -t services/wordpress srcs/wordpress/
sleep 1
docker build -t services/phpmyadmin srcs/phpmyadmin/
sleep 1
docker build -t services/ftps srcs/ftps/
sleep 1

# Apply pods and services
kubectl apply -f srcs/nginx/nginx.yml
sleep 1
kubectl apply -f srcs/mysql/my-sql.yml
sleep 1
kubectl apply -f srcs/wordpress/wordpress.yml
sleep 1
kubectl apply -f srcs/phpmyadmin/phpmyadmin.yml
sleep 1
kubectl apply -f srcs/ftps/ftps.yml
sleep 1

# Start dashboard
minikube dashboard &