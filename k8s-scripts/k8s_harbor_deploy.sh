#!/bin/bash

# ---------------- GLOBAL VARIABLES

# errores
# ./test.sh: line 174: unexpected EOF while looking for matching `"'
# ./test.sh: line 179: syntax error: unexpected end of file


# ---------------- FUNCTIONS

# 01 Function to install Docker
docker_setup() {
    echo "Starting Docker installation..."

    # Check if Docker is already installed
    if command -v docker &>/dev/null
    then
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
    if ! docker --version > /dev/null 2>&1; then
        echo "Failed to verify Docker installation. Please check manually."
        exit 1
    fi

    # Test Docker installation by running a simple containerized application
    if ! sudo docker run hello-world > /dev/null 2>&1; then
        echo "Failed to run hello-world container. Docker installation might be incomplete."
        exit 1
    fi

    echo "Docker installation completed..."
    echo "--------------------------------"
    echo "--------------------------------"
    sleep 5
} # end of docker_setup() function

# 02 Function to install and initialize Minikube
install_minikube() {

    echo "Starting Minikube Installation process..."

    # Check if Minikube is already installed
    if command -v minikube &>/dev/null
    then
        echo "Minikube is already installed..."
        echo "Minikube current version: $(minikube version)"
        echo "Proceeding with Minikube cluster initialization..."

            # Start Minikube cluster
        if ! minikube start --driver=docker # If command fails, then exit 1
        then
            echo "Failed to start Minikube cluster. Exiting script..."
            exit 1
        fi

        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5
        # Add other steps or function calls here if needed
        return
    fi

    echo "Minikube is not yet installed..."
    echo "Downloading and installing Minikube..."

    # Step 1: Download and install Minikube
    sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube /usr/local/bin/

    # Step 2: Start Minikube cluster
    if ! minikube start --driver=docker # If command fails, then exit 1
    then
        echo "Failed to start Minikube cluster. Exiting."
        exit 1
    fi

    # Step 3: Verify Minikube installation
    if ! minikube status
    then
        echo "Failed to verify Minikube installation. Exiting."
        exit 1
    fi

    echo "Minikube installation complete."
    echo "--------------------------------"
    echo "--------------------------------"
    sleep 5
}

# 03 Function to install Kubernetes tools only
k8s_tools_install() {
    echo "Starting Kubernetes tools installation..."

    # Step 2: Download and add the GPG key for Kubernetes
    if ! curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -; then
        echo "Failed to add Kubernetes GPG key. Exiting."
        exit 1
    fi

    # Step 3: Add the Kubernetes repository to your system
    sudo add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
    sudo apt-get update

    # Install Kubernetes tools (latest versions)
    if ! sudo apt-get install -y kubectl=1.27.0-00 kubelet=1.27.0-00 kubeadm=1.27.0-00
    then
        echo "Failed to install Kubernetes tools. Exiting..."
        exit 1
    fi

    echo "Kubernetes tools installation complete..."
    echo "Proceeding with next steps..."
    echo "--------------------------------"
    echo "--------------------------------"
    sleep 5 # pause 
}

# 04 Function to check if Kubernetes tools are installed
k8s_tools_validation() {
    local tools_missing=0

    # Check if kubectl is installed and get version
    if ! command -v kubectl &>/dev/null
    then
        echo "kubectl is not installed."
        tools_missing=1
    else
        echo "Kubectl current version: $(kubectl version --client=true --short | grep 'Client Version')"

    # Check if kubelet is installed and get version
    if ! command -v kubelet &>/dev/null
    then
        echo "kubelet is not installed."
        tools_missing=1
    else
        echo "Kubelet current version: $(kubelet --version)"
    fi

    # Check if kubeadm is installed and get version
    if ! command -v kubeadm &>/dev/null
    then
        echo "kubeadm is not installed."
        tools_missing=1
    else
        echo "Kubeadm current version: $(kubeadm version -o short)"
    fi

    # If any tool is missing, attempt installation
    if [ $tools_missing -eq 1 ]
    then
        echo "Attempting to install Kubernetes tools..."
        k8s_tools_install # Call function 04 to install Kuberentes tools
        k8s_tools_validation # Recheck after attempted installation
    else
        # If all tools are installed, proceed
        echo "Kubernetes tools are already installed..."
        echo "Proceeding with next steps..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5 # Pause for better understanding
    fi
}

# ---------------- START OF SCRIPT

echo "Initializing K8s/Minikube script process..."

# Step 0: Call function 01 to verify Docker installation.
docker_setup

# Step 0: Call function 02 to install Minikube and if Docker engine is installed:
install_minikube

# Step 0: Call function 03 to validate if K8s tools are installed if not exit 1:
k8s_tools_validation

echo "Task completed..."
echo "--------------------------------"
echo "--------------------------------"
sleep 5