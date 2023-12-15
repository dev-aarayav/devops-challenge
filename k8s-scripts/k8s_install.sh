#!/bin/bash

# Verification of required packages such as kubect, kubeadm and kubelet
if ! command -v kubectl &>/dev/null || ! command -v kubeadm &>/dev/null || ! command -v kubelet &>/dev/null
then
    echo "Kubernetes dependencies are not installed."
    # Install Kubernetes dependencies or prompt the user for installation.
fi

# Check if Kubernetes is already initialized or running (cluster status)
kubectl cluster-info &>/dev/null
if [[ $? -eq 0 ]]
then
    echo "Kubernetes cluster is already initialized."
    # Further checks or actions based on cluster status.
else
    echo "Kubernetes cluster is not running or initialized."
    # Initiate Kubernetes cluster or prompt the user to start it.
fi


# Check cluster Nodes status
kubectl get nodes | grep -q 'Ready\s*\(.*\)\s*\(.*\)'
if [[ $? -eq 0 ]]
then
    echo "Kubernetes nodes are ready."
    # Additional checks or actions related to nodes.
else
    echo "Kubernetes nodes are not in a ready state."
    # Check node status or provide instructions to rectify node issues.
fi

# Check Kubernetes version
kubectl version --short | grep -q 'Server Version:\s*v1.21.*'
if [[ $? -eq 0 ]] 
then
    echo "Kubernetes v1.21 is installed."
    # Additional checks or actions based on the Kubernetes version.
else
    echo "Kubernetes v1.21 is not installed."
    # Provide instructions for upgrading or installing the correct version.
fi

# -----------------------------------------


# Function to install Kubernetes & Minikube
install_minikube() {
    echo "Starting Minikube installation..."

    # Check if Docker is installed
    check_docker_installed

    # Step 1: Install Kubernetes tools (kubectl, kubelet, kubeadm)
    sudo apt update
    sudo apt install kubectl kubelet kubeadm -y

    # Step 2: Download and add the GPG key for Kubernetes
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    # Step 3: Add the Kubernetes repository to your system
    sudo add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"

    # Step 4: Install Minikube
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube /usr/local/bin/

    # Step 5: Start Minikube cluster
    minikube start --driver=docker

    # Step 6: Verify Minikube installation
    minikube status

    echo "Minikube installation complete."
}