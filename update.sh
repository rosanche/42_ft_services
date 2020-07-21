#! /bin/bash

sed_configs () {
    sed -i.bak 's/MINIKUBE_IP/'"$1"'/g' $2
    sleep 1
}

sed_configs_back () {
    sed -i.bak "s/$1/""MINIKUBE_IP"'/g' $2
    sleep 1
}

build_apply () {
    docker build -t services/$1 srcs/$1
    sleep 1
    kubectl apply -f srcs/$1/$1.yml
}

# Minikube IP
MINIKUBE_IP=`minikube ip`
sed_list="srcs/telegraf/telegraf.conf srcs/ftps/setup.sh srcs/mysql/wordpress.sql"

# File configuration
for name in $sed_list
do
    sed_configs $MINIKUBE_IP $name
done

# Delete all pods
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl delete -f srcs/nginx/nginx.yml
kubectl delete -f srcs/mysql/mysql.yml
kubectl delete -f srcs/wordpress/wordpress.yml
kubectl delete -f srcs/phpmyadmin/phpmyadmin.yml
kubectl delete -f srcs/ftps/ftps.yml
kubectl delete -f srcs/grafana/grafana.yml
kubectl delete -f srcs/influxdb/influxdb.yml
kubectl delete -f srcs/telegraf/telegraf.yml


# Install metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

services="nginx mysql wordpress phpmyadmin ftps influxdb telegraf grafana"

kubectl apply -f srcs/metallb.yml
# build images and apply deployments
for service in $services
do
    build_apply $service
done

# File deconfiguration
for name in $sed_list
do
    sed_configs_back $MINIKUBE_IP $name
done
