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
minikube start --vm-driver=virtualbox

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

kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl delete -f srcs/nginx/nginx.yml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml

kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
# Ngxinx server with ingress controller
docker build -t services/nginx srcs/nginx/
sleep 1
# kubectl apply -f srcs/nginx/nginx.yml
# sleep 1

docker build -t services/mysql srcs/mysql/
sleep 1
docker build -t services/wordpress srcs/wordpress/
sleep 1
kubectl apply -f srcs/nginx/nginx.yml
sleep 1
kubectl apply -f srcs/mysql/my-sql.yml
sleep 1
kubectl apply -f srcs/wordpress/wordpress.yml
sleep 1

# Ingress controller
# docker pull alpine
# # cd srcs/nginx
# docker build -t nginx srcs/nginx/
# kubectl apply -f srcs/nginx/nginx.yml
# kubectl apply -f srcs/ingress/ingress.yml

# Start dashboard
minikube dashboard &

#bash
