# Install and verify that docker is running
bash init_docker.sh
if [[ $? == 0 ]]
then
    printf "Docker is running\n"
else
    printf "Docker can't run\n"
    exit
fi

# Install and launch minikube
# minikube delete
# rm -rf ~/.minikube
# mkdir -p /goinfre/${USER}/.minikube
# ln -sf /goinfre/${USER}/.minikube ~/.minikube
# chmod u+s /Users/rosanche/.minikube/bin/docker-machine-driver-hyperkit 
# chown root:wheel /Users/rosanche/.minikube/bin/docker-machine-driver-hyperkit && sudo chmod u+s /Users/rosanche/.minikube/bin/docker-machine-driver-hyperkit
export MINIKUBE_HOME=/goinfre/${USER}/
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

# Ingress controller
docker pull alpine
# cd srcs/nginx
docker build -t nginx srcs/nginx/
kubectl apply -f srcs/nginx/nginx.yml
kubectl apply -f srcs/ingress/ingress.yml

bash