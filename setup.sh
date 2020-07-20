#! /bin/bash

sed_configs () {
    sed -i.bak 's/MINIKUBE_IP/'"$1"'/g' $2
    sleep 1
}

sed_configs_back () {
    sed -i.bak "s/$1/""MINIKUBE_IP"'/g' $2
    sleep 1
}


# Install and verify that docker is running
# bash init_docker.sh
# docker-machine create default
# docker-machine start
# eval $(docker-machine env default)
# if [[ $? == 0 ]]
# then
#    printf "Docker is running\n"
# else
#    printf "Docker can't run\n"
#    exit
# fi

# # # Install and launch minikube
# minikube delete
# rm -rf ~/.minikube
# # mkdir -p /goinfre/${USER}/.minikube
# # ln -sf /goinfre/${USER}/.minikube ~/.minikube
# # chmod u+s /Users/rosanche/.minikube/bin/docker-machine-driver-hyperkit 
# # chown root:wheel /Users/rosanche/.minikube/bin/docker-machine-driver-hyperkit && sudo chmod u+s /Users/rosanche/.minikube/bin/docker-machine-driver-hyperkit
export MINIKUBE_HOME=/goinfre/${USER}/
# export MINIKUBE_HOME=/tmp
# minikube start --vm-driver=virtualbox
minikube start driver=virtualbox --bootstrapper=kubeadm

if [[ $? == 0 ]]
then
    eval $(minikube docker-env)
    printf "Minikube started\n"
    # bash -c 'bash ; minikube dashboard'
    # minikube dashboard
else
    minikube delete
    printf "Error occured\n"
    exit
fi

# Minikube IP
MINIKUBE_IP=`minikube ip`
sed_list="srcs/telegraf/telegraf.conf"

# # File configuration
# for name in $sed_list
# do
#     sed_configs $MINIKUBE_IP $name
# done

# sed -i.bak 's/MINIKUBE_IP/'"$MINIKUBE_IP"'/g' srcs/telegraf/telegraf.conf

# Delete all pods
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl delete -f srcs/nginx/nginx.yml
kubectl delete -f srcs/mysql/my-sql.yml
kubectl delete -f srcs/wordpress/wordpress.yml
kubectl delete -f srcs/phpmyadmin/phpmyadmin.yml
kubectl delete -f srcs/ftps/ftps.yml
kubectl delete -f srcs/grafana/grafana.yml


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
# docker build -t services/ftps srcs/ftps/
# sleep 1
docker build -t services/influxdb srcs/influxdb/
sleep 1
docker build -t services/telegraf srcs/telegraf/
sleep 1
docker build -t services/grafana srcs/grafana/
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
# kubectl apply -f srcs/ftps/ftps.yml
# sleep 1
kubectl apply -f srcs/influxdb/influxdb.yml
sleep 1
kubectl apply -f srcs/telegraf/telegraf.yml
sleep 1
kubectl apply -f srcs/grafana/grafana.yml
sleep 1
kubectl apply -f srcs/metallb.yml
sleep 1

# for name in $sed_list
# do
#     sed_configs_back $MINIKUBE_IP $name
# done

# Start dashboard
# minikube dashboard &
