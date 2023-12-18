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

# 02 Function to install and initialize Minikube cluster
install_minikube() {

echo "Starting Minikube Installation process..."

    local minikube_installed=$(command -v minikube &>/dev/null && echo "true" || echo "false")

    if [ "$minikube_installed" = "true" ]; then
        echo "Minikube is already installed..."
        echo "Minikube current version: $(minikube version)"
    else
        echo "Minikube is not yet installed..."
        echo "Downloading and installing Minikube..."

        # Step 1: Download and install Minikube
        sudo curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo chmod +x /usr/local/bin/minikube
    fi

    # Step 2: Start Minikube cluster
    echo "Starting Minikube cluster..."
    minikube delete # Necessary to avoid initializing K8s cluster with desired version.
    if ! minikube start --kubernetes-version=v1.27.0 --driver=docker
    then
        echo "Failed to start Minikube cluster. Exiting scritpt..."
        exit 1
    fi

    # Function to validate Minikube cluster readiness
    validate_minikube_cluster() {
        echo "Validating Minikube cluster..."
        while true
        do
            STATUS=$(kubectl get nodes --no-headers | grep "Ready")
            if [ -n "$STATUS" ]
            then
                echo "Minikube nodes are ready:"
                kubectl get nodes
                break
            else
                echo "Still waiting for Minikube to be ready..."
                sleep 5  # Adjust the sleep duration as needed
            fi
        done
    }

    # Call function "validate_minikube_cluster"
    validate_minikube_cluster
    echo "Minikube initialized correctly..."

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
    fi

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

# 05 Function to validate existance of Helm or Helm installation:
install_helm() {
    echo "Starting Helm installation..."

    # Contain a string "true" if Helm installed and accesible, otherwise "false" if not found
    local helm_installed=$(command -v helm &>/dev/null && echo "true" || echo "false")

    # Verification of Helm installation.
    if [ "$helm_installed" = "true" ]
    then
        echo "Helm is already installed..."
        echo "Helm version: $(helm version --short)"
    else
        echo "Downloading Helm binary..."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

        echo "Running Helm installation script..."
        chmod 700 get_helm.sh
        ./get_helm.sh # script

        # Validate if exit status of script not equal to cero
        if [ $? -ne 0 ]
        then
            echo "Failed to install Helm. Exiting script..."
            exit 1
        fi
    fi

    # Verify Helm version after installation.
    if ! helm version &>/dev/null
    then
        echo "Failed to verify Helm installation. Exiting script..."
        exit 1
    fi

    echo "Helm installation completed..."
    echo "-------------------------------"
    echo "-------------------------------"
    sleep 5
}


# ---------------- START OF SCRIPT

echo "Initializing K8s/Minikube script process..."

# Step 0: Call function 01 to verify Docker installation.
docker_setup

# Step 0: Call function 02 to install Minikube and if Docker engine is installed:
install_minikube

# Step 0: Call function 03 to validate if K8s tools are installed if not exit 1:
k8s_tools_validation

# Resoponse related Minikube setup finished correclty.
echo "Minikube ready..."
echo "--------------------------------"
echo "--------------------------------"
sleep 5

# Step 0: Call function 05 to install Helm
install_helm


# Finish script
echo "Task completed..."
echo "--------------------------------"
echo "--------------------------------"
sleep 5