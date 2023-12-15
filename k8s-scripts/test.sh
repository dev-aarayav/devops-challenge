#!/bin/bash

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


# Previos steps to run safely
echo "Running package update & upgrade..."
sudo apt-get update && sudo apt upgrade -y
echo "Completed package update & upgrade..."
chmod 755 ${SCRIPT} # Granting execution access to file
echo "Script '$SCRIPT' is now executable."
echo "--------------------------------"
echo "--------------------------------"
sleep 5 # Pausing execution 2 for 5 seconds for clarity in second cycle.

# Call the function to install Minikube
install_minikube
