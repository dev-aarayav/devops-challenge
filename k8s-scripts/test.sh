#!/bin/bash

# errores
# ./test.sh: line 174: unexpected EOF while looking for matching `"'
# ./test.sh: line 179: syntax error: unexpected end of file

# ---------------- FUNCTIONS

# Function to install Docker
docker_setup() {
    echo "Starting Docker installation..."

    # Check if Docker is already installed
    if command -v docker &>/dev/null; then
        echo "Docker is already installed."
        echo "Proceeding with next steps..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5
        # Add other steps or function calls here if needed
        return
    fi

    # Install necessary dependencies
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Fetch Docker's official GPG key and add it to the system keychain for package verification
    if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; then
        echo "Failed to add Docker's GPG key. Exiting."
        exit 1
    fi

    # Add the Docker repository to the system's sources
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Install Docker Community Edition
    if ! sudo apt-get install -y docker-ce; then
        echo "Failed to install Docker Community Edition. Exiting."
        exit 1
    fi

    # Check the installed Docker version
    if ! docker --version; then
        echo "Failed to verify Docker installation. Exiting."
        exit 1
    fi

    # Test Docker installation by running a simple containerized application
    if ! sudo docker run hello-world; then
        echo "Failed to run hello-world container. Exiting."
        exit 1
    fi

    echo "Docker installation completed..."
    echo "--------------------------------"
    echo "--------------------------------"
}


# Function to install Minikube
install_minikube() {

    echo "Starting Docker Verification..."

    # Check if Docker is installed
    docker_setup

    echo "Starting Minikube Installation..."

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

# Function to check if Minikube is installed
check_minikube_installed() {
    if ! command -v minikube &>/dev/null
    then
        echo "Minikube is not installed..."

        # Call the function install Minikube
        install_minikube
    else
        echo "Minikube is already installed..."
        echo "Minikube current version: $(minikube version)"
        echo "Proceeding with next steps..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5
        # Check other steps or call other functions here if needed
    fi
}

# Function to install Kubernetes tools only
install_kubernetes_tools() {

    echo "Starting Kubernetes tools installation..."
        
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
    sleep 5 # pause 

    # Call of function to check minikube installed in host
    check_minikube_installed
}

# Function to check if Kubernetes tools are installed
check_kubernetes_tools_installed() {
    local tools_missing=0

    # Check if kubectl is installed
    if ! command -v kubectl &>/dev/null
    then
        echo "kubectl is not installed."
        tools_missing=1
    fi

    # Check if kubelet is installed
    if ! command -v kubelet &>/dev/null
    then
        echo "kubelet is not installed."
        tools_missing=1
    fi

    # Check if kubeadm is installed
    if ! command -v kubeadm &>/dev/null
    then
        echo "kubeadm is not installed."
        tools_missing=1
    fi

    # If any tool is missing, install all Kubernetes tools
    if [ $tools_missing -eq 1 ]; then
        install_kubernetes_tools
    else
        # If all tools are installed, proceed
        echo "Kubernetes tools are already installed..."
        echo "Kubectl current version: $(kubectl version --short | grep 'Client Version')"
        echo "Kubelet current version: $(kubelet --version)"
        echo "Kubeadm current version: $(kubeadm version -o short)"
        echo "Proceeding with next steps..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5 # Pause for better understanding

        # Call of Minikube verification function
        check_minikube_installed
    fi
}

# Call of Kubernetes Verification function of tools installed
check_kubernetes_tools_installed


echo "Task completed..."
echo "--------------------------------"
echo "--------------------------------"
sleep 5
