#!/bin/bash

# Check if the namespace argument is provided
if [ -z "$1" ]
then
    echo "Please provide the required for argument to run script. Please refer to README file"
    exit 1
fi

# VARIABLES
HARBOR_REGISTRY="localhost:5000"
PROJECT_NAME="aarayav-project"
TAG="v1"

# Function to upload Docker images into Harbor registry
upload_to_harbor() {

    # LOCAL VARS
    DIR_DCK="$1" 
    IMAGE_NAME="${2:-harbor-image}" 
    PROJECT_NAME="${3:-$PROJECT_NAME}" # Reassigning the global variable if the third parameter is present

    docker build -t "$IMAGE_NAME:$TAG" "$DIR_DCK" # Build the Docker image
    docker tag "$IMAGE_NAME:$TAG" "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE_NAME:$TAG" # Tag the image for Harbor registry
    docker push "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE_NAME:$TAG" # Push the image to Harbor registry

}

# Function to pull  Docker images from Harbor registry
pull_from_harbor() {

    # LOCAL VARS
    IMAGE_NAME_PULL="$1"

    # Pull the image from Harbor registry
    docker pull "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE:$TAG" # docker pull <harbor-registry>/<project>/<image-name>:<tag>
}


# Function to check if Harbor UI is running and accesible within Minikube cluster. Then it uploads or pulls an image depending on existance...
check_and_manage_image() {
    HARBOR_URL="http://$(minikube ip):80" # exposed Ports can be 80 or 443
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $HARBOR_URL)

    if [ $RESPONSE -eq 200 ]
    then
        echo "Harbor is running and accessible at $HARBOR_URL"
        
        # Check if the specific image exists in the Harbor registry
        IMAGE_EXISTS=$(docker pull "$HARBOR_REGISTRY/$PROJECT_NAME/$1:$TAG" 2>&1 | grep -c "manifest unknown")
        
        if [ $IMAGE_EXISTS -eq 0 ] 
        then
            echo "Image exists in Harbor, pulling..."
            pull_from_harbor "$1"
        else
            echo "Image doesn't exist in Harbor, uploading..."
            upload_to_harbor "$1" "$2" "$3"
        fi
    else
        echo "Harbor is not accessible at $HARBOR_URL"
    fi
}

# Initiate Minikube cluster

echo "Initializing Minikube cluster {K_CTL}..."
minikube delete
minikube start --kubernetes-version=v1.27.0
echo "Minikube cluster up & running..."
echo "-------------------------------"
echo "-------------------------------"
sleep 5 # Stop here to understand better functionality.

# Wait for Minikube to be ready
echo "Waiting for Minikube to be ready..."
while true; do
    STATUS=$(kubectl get nodes --no-headers | grep "Ready")
    if [ -n "$STATUS" ]; then
        echo "Still waiting for Minikube to be ready"
        break
        echo "Validation completed..."
    fi
    sleep 5 # Stop to understand process
done
echo "Minikube is ready!"
sleep 5 # Stop to understand process


# Download Helm binary & installation
echo "Downloading Helm binary..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
echo "Installing Helm..."
chmod 700 get_helm.sh
./get_helm.sh
echo "Helm installation completed..."
echo "-------------------------------"
echo "-------------------------------"
sleep 5 # Stop here to understand better functionality.

# Add Harbor Helm repository & installation of Harbor chart from Helm Hub
echo "Starting download and installation of Harbor..."
helm repo add harbor https://helm.goharbor.io
helm install harbor harbor/harbor
echo "Harbor deployment completed..."
echo "-------------------------------"
echo "-------------------------------"
sleep 5 # Stop here to understand better functionality.

echo "Waiting for Harbor deployment to be ready..."
while true; do
    RUNNING_PODS=$(kubectl get pods -n <namespace> --selector=app=harbor --field-selector=status.phase=Running | grep -c Running)
    TOTAL_PODS=$(kubectl get pods -n <namespace> --selector=app=harbor | grep -c Running)

    # Testing Purposes
    echo "READY_PODS: $READY_PODS"
    echo "TOTAL_PODS: $TOTAL_PODS"


    if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ]; then
        break
    fi

    sleep 5
done

echo "All pods from Harbor namespace are running..."
echo "Harbor deployment is ready!"

# Call of the function to build, upload or pull docker image into Harbor registry.
check_and_manage_image