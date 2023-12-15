#!/bin/bash

K8S_SCRIPT="$0"
CMD_MK=$(minikube version)
CMD_KCTL=$(kubectl version --short)
CMD_KLET=$(kubelet --version)
CMD_KADM=$(kubeadm version)



# Function to install Docker
docker_inst() {
    echo "Starting Docker installation..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    docker --version
    sudo docker run hello-world
    echo "Docker installation completed..."
    echo "--------------------------------"
    echo "--------------------------------"
}

# Function to check if Docker is installed
check_docker_installed() {
    if ! command -v docker &>/dev/null
    then
        echo "Docker is not installed. Proceeding with installation..."
        # Call the function to install Docker
        docker_inst

        # Verification step after installation
        if ! command -v docker &>/dev/null; then
            echo "Docker installation failed. Please install Docker manually..."
            exit 1
        else
            echo "Docker installed successfully!"
            echo "Proceeding with next steps..."
            echo "--------------------------------"
            echo "--------------------------------"
            sleep 5
        fi
    else
        echo "Docker is already installed..."
        echo "Proceeding with next steps..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5
    fi
}

# Function to check if Minikube is installed
check_minikube_installed() {
    if ! command -v minikube &>/dev/null 
    then
        echo "Minikube is not installed. Proceeding with installation..."
        # Call the function to install Minikube
        install_minikube
    else
        echo "Minikube is already installed..."
        echo "Minikube current version '${CMD_MK}'"
        echo "Proceeding with next steps..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5
    fi
}

# Function to install Minikube
install_minikube() {
    echo "Starting Minikube installation..."

    # Check if Docker is installed
    check_docker_installed

    # Step 1: Download and install Minikube
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube /usr/local/bin/

    # Step 2: Start Minikube cluster
    minikube start --driver=docker

    # Step 3: Verify Minikube installation
    minikube status

    echo "Minikube installation complete."
    echo "--------------------------------"
    echo "--------------------------------"
    sleep 5
}


# Function to check if Kubernetes tools are installed
check_kubernetes_tools_installed() {
    if ! command -v kubectl &>/dev/null || ! command -v kubelet &>/dev/null || ! command -v kubeadm &>/dev/null
    then
        echo "Kubernetes tools are not installed. Proceeding with installation..."
        # Call the function to install Kubernetes tools
        install_kubernetes_tools
    else
        echo "Kubernetes tools are already installed..."
        echo "K8s kubctl current version '${CMD_KCTL}'"
        echo "K8s kubelet current version '${CMD_KLET}'"
        echo "K8s kubeadm current version '${CMD_KADM}'"
        echo "Proceeding with next steps..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5
        check_minikube_installed
    fi
}

# Function to install Kubernetes tools only
install_kubernetes_tools() {
    echo "Starting Kubernetes tools installation..."

    # Step 1: Install Kubernetes tools (kubectl, kubelet, kubeadm)
    sudo apt update
    # sudo apt install kubectl kubelet kubeadm -y
    sudo apt-get install -y kubectl=1.27.0-00 kubelet=1.27.0-00 kubeadm=1.27.0-00

    # Step 2: Download and add the GPG key for Kubernetes
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    # Step 3: Add the Kubernetes repository to your system
    sudo add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"

    echo "Kubernetes tools installation complete..."
    echo "Proceeding with next steps..."
    echo "--------------------------------"
    echo "--------------------------------"
    sleep 5
    check_minikube_installed
}


# Previos steps to run safely
echo "Running package update & upgrade..."
sudo apt-get update && sudo apt upgrade -y
echo "Completed package update & upgrade..."
chmod 755 ${K8S_SCRIPT} # Granting execution access to file
echo "Script '$K8S_SCRIPT' is now executable."
echo "--------------------------------"
echo "--------------------------------"
sleep 5 # Pausing execution 2 for 5 seconds for clarity in second cycle.

# K8s
check_kubernetes_tools_installed
echo "Task completed..."
echo "--------------------------------"
echo "--------------------------------"
sleep 5

# ------------------------------------------------------------------------
# FUNCTIONALITY

