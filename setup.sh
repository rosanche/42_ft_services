#! /bin/bash

set -x

export MAC_42=1
export sudo='';
export driver='docker'

if [ $MAC_42 -eq 1 ]
then
    export sudo=''
    export driver='virtualbox'
    export MINIKUBE_HOME=/goinfre/${USER}/
    # Install and verify that docker is running
    docker-machine create default
    docker-machine start
fi

sed_configs () {
    sed -i.bak 's/MINIKUBE_IP/'"$1"'/g' $2
    echo "configured $2 with $1"
    sleep 1
}

sed_configs_back () {
    sed -i.bak "s/$1/""MINIKUBE_IP"'/g' $2
    echo "deconfigured $2"
    sleep 1
}

build_apply () {
    docker build -t services/$1 srcs/$1
    sleep 1
    kubectl apply -f srcs/$1/$1.yml
}

# # # Install and launch minikube
$sudo minikube start --vm-driver=$driver  --bootstrapper=kubeadm

if [[ $? == 0 ]]
then
    eval $($sudo minikube docker-env)
    printf "Minikube started\n"
else
    $sudo minikube delete
    printf "Error occured\n"
    exit
fi

# Minikube IP
MINIKUBE_IP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"

sed_list="srcs/telegraf/telegraf.conf"

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

if [ $MAC_42 -eq 1 ]
then
    kubectl apply -f srcs/metallb.yml
    sed_configs 192.168.99.127 srcs/ftps/setup.sh
    sed_configs 192.168.99.125 srcs/mysql/wordpress.sql
else
    kubectl apply -f srcs/metallbVM.yml
    sed_configs 172.17.0.5 srcs/ftps/setup.sh
    sed_configs 172.17.0.3 srcs/mysql/wordpress.sql
fi

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

# Start dashboard
$sudo minikube dashboard &
