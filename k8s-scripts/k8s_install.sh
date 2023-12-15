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
