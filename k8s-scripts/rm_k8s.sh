#!/bin/bash

# Function to uninstall Minikube
uninstall_minikube() {
    echo "Uninstalling Minikube..."
    sudo minikube stop
    sudo minikube delete
    sudo rm -rf ~/.minikube
    sudo rm -rf /usr/local/bin/minikube
    echo "Minikube has been uninstalled."
    echo "--------------------------------"
}

# Function to uninstall Kubernetes tools
uninstall_kubernetes_tools() {
    echo "Uninstalling Kubernetes tools..."
    sudo apt-get remove kubectl kubelet kubeadm kubernetes-cni -y
    echo "Kubernetes tools have been uninstalled."
    echo "--------------------------------"
}

# Function to completely remove Kubernetes and Minikube
remove_kubernetes_minikube() {
    uninstall_minikube
    uninstall_kubernetes_tools
    echo "Kubernetes and Minikube have been completely removed."
}

# Confirm action before removal
read -p "This will completely remove Kubernetes and Minikube. Do you want to proceed? (yes/no): " choice
case "$choice" in
  yes|YES|y|Y ) 
    remove_kubernetes_minikube ;;
  * ) 
    echo "Aborting removal process." ;;
esac
