#!/bin/bash

# This validation checks if the number of arguments ($#) passed to the script is less than 3.
if [ $# -lt 3 ]
then
    echo "Please provide all required arguments to run the script. Please refer to README file."
    exit 1
fi

# ------------- SCRIPT GLOBAL VARIABLES

DOCKER_DIR=$1 # First argument assigned
IMAGE_NAME=$2 # Second argument assigned
PROJECT_NAME=$3 # Third argument assigned
K8S_NAMESPACE="harbor" #Name
HARBOR_REGISTRY="localhost:5000" 
TAG="v1"


# ------------- SCRIPT FUNCTIONS

# Function to upload Docker images into Harbor registry
upload_to_harbor() {

    docker build -t "$IMAGE_NAME:$TAG" "$DOCKER_DIR" # Build the Docker image
    docker tag "$IMAGE_NAME:$TAG" "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE_NAME:$TAG" # Tag the image for Harbor registry
    docker push "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE_NAME:$TAG" # Push the image to Harbor registry
    echo "Docker image uploaded into Harbor Registry..."
    sleep 5 # Stop here to understand better functionality.
}

# Function to check if Harbor UI is running and accessible within Minikube cluster.
check_harbor_availability() {
    HARBOR_URL="http://$(minikube ip):80" # This line constructs a URL for the Harbor service running on the Minikube 
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $HARBOR_URL) # HTTP Validation with curl

    if [ $RESPONSE -eq 200 ]
    then
        echo "Harbor is running and accessible at $HARBOR_URL"
        return 0  # Return success status
    else
        echo "Harbor is not accessible at $HARBOR_URL."
        echo "Exiting the script..."
        echo "-------------------------------"
        echo "-------------------------------"
        sleep 5 # Stop here to understand better functionality.
        exit 1  # Exit the script with a status code of 1
    fi
}

# Function to manage image actions based on existence in Harbor registry
manage_image() {

    if check_harbor_availability
    then
        IMAGE_EXISTS=$(docker pull "$HARBOR_REGISTRY/$PROJECT_NAME/$1:$TAG" 2>&1 | grep -c "manifest unknown")

        if [ $IMAGE_EXISTS -eq 0 ]
        then
            echo "Image exists in Harbor, pulling..."
            docker pull "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE:$TAG" # Pull the image from Harbor registry
        else
            echo "Image doesn't exist in Harbor, uploading..."
            upload_to_harbor "$1" "$2" "$3"
        fi
    else
        echo "Cannot manage image as Harbor is not accessible..."
        echo "-------------------------------"
        echo "-------------------------------"
        sleep 5 # Stop here to understand better functionality.
        exit 1  # Exit the script with a status code of 1
    fi
}

check_harbor_namespace() {

    # K8s Harbor namespace validation
    if kubectl get namespace "$cluster_namespace" &> /dev/null
    then
        echo "Namespace '$cluster_namespace' exists in the Minikube cluster."
    else
        echo "Namespace '$cluster_namespace' does not exist in the Minikube cluster."

        # Attempt to create the namespace
        if kubectl create namespace "$cluster_namespace" &> /dev/null
        then
            echo "Namespace '$cluster_namespace' created successfully."
        else
            echo "Failed to create namespace '$cluster_namespace'. Exiting..."
            exit 1  # Exit the script with a status code of 1 indicating an error
        fi
    fi
}

# ------------- START OF SCRIPT


# Initiate Minikube cluster
echo "Initializing Minikube cluster..."
# minikube delete
minikube start --kubernetes-version=v1.27.0
echo "-------------------------------"
echo "-------------------------------"
sleep 5 # Stop here to understand better functionality.

# Wait for Minikube to be ready
echo "Waiting for Minikube to be ready..."

# While loop for validation
while true
do
    STATUS=$(kubectl get nodes --no-headers | grep "Ready")

    if [ -n "$STATUS" ]; then
        echo "Still waiting for Minikube to be ready..."
        break
    fi

done

echo "Validation completed..."
echo "-------------------------------"
echo "-------------------------------"
sleep 5 # Stop to understand process
echo "Minikube is ready!"
sleep 5 # Stop to understand process


# Helm binary download
echo "Downloading Helm binary..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

# Helm Installation
echo "Installing Helm..."
chmod 700 get_helm.sh
./get_helm.sh

# Completion messages
echo "Helm installation completed..."
echo "-------------------------------"
echo "-------------------------------"
sleep 5 # Stop here to understand better functionality.

# Add Harbor Helm repository into local Helm setup
echo "Adding Harbor to local Helm setup..."
helm repo add harbor https://helm.goharbor.io
slep 3

# Harbor chart installation with Helm
helm install harbor harbor/harbor --namespace=$cluster_namespace
echo "Checking if namespace '$cluster_namespace' exists in the Minikube cluster..."


# Function to Check Harbor namespace existance
check_harbor_namespace

# Completion messages
echo "Validation completed..."
echo "-------------------------------"
echo "-------------------------------"
sleep 5 # Stop to understand process


echo "Starting with Harbor pods validation..."

# Valdiation of Harbor pods running in K8s cluster...
while true
do
    RUNNING_PODS=$(kubectl get pods -n $cluster_namespace --selector=app=harbor --field-selector=status.phase=Running | grep -c Running)
    TOTAL_PODS=$(kubectl get pods -n $cluster_namespace --selector=app=harbor | grep -c Running)

    # Testing Purposes
    echo "Waiting for Harbor pods to be ready..."
    echo "RUNNING_PODS: $RUNNING_PODS"
    echo "TOTAL_PODS: $TOTAL_PODS"

    if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ]
    then
        break
    fi
done

echo "Validation completed..."
echo "-------------------------------"
echo "-------------------------------"
sleep 5
echo "All pods from Harbor namespace are running..."
echo "Harbor deployment is ready!"

# Check Harbor Registry availability
check_harbor_availability

# Call of the function to build, upload or pull docker image into Harbor registry.
manage_image