# Commands below to help install microk8s

# Step 1
snap install kubectl -classic
kubectl version --client
sudo snap install microk8s --classic
sudo usermod -a -G microk8s <username>
sudo chown -R <username> ~/.kube
newgrp microk8s
microk8s kubectl get nodes

# Step 2
cd $HOME
mkdir .kube
cd .kube
microk8s config > config
microk8s start

# Step 3 - Might have to add SSH keys so go back to github account - settings - ssh keys - add new ssh key
- git clone git@github.com:<docker_hub_name>/react-article-display.git
- cd react-article-display
- docker build -t <docker_hub_name>/react-article-display:demo .
- docker run -d -p 3000:80 <docker_hub_name>/react-article-display:demo
localhost:3000
- docker stop <see string above from previous command>
- docker login
- docker push <image name>

# Step 4
- kubectl run my-app-image --image <above>
- kubectl get pods
- kubectl port-forward my-app-image 3000:80