#!/bin/bash

# This validation checks if the number of arguments ($#) passed to the script is less than 3.
if [ $# -lt 3 ]
then
    echo "Please provide all required arguments to run the script. Please refer to README file."
    exit 1
fi

# Execution command for the second script: ```$ ./k8s_harbor_deploy.sh <docker-image-path> <image-name> <project-name>```
    # 1. ```<docker-image-path>```: You have to define a path where the docker image will be available.
    # 2. ```<image-name>```: Here is where you define the name of the docker image for building and Harbor purposes.
    # 3. ```<project-name>```: For Harbor registry you have to specify a directory (project-name) where each project (docker image) will be stored.
    # 4. NOTE: This call will build the Docker image from the specified directory, tag it with the image custom name, create a custom directory name inside of Harbor and define a
        # - If you omit the second parameter, it will default to "harbor-image". 
        # - If you omit the third parameter, it will default to "aarayav-project". 

# ------------- SCRIPT GLOBAL VARIABLES

DOCKER_DIR=$1 # First argument assigned
IMAGE_NAME=$2 # Second argument assigned
PROJECT_NAME=$3 # Third argument assigned
cluster_namespace="harbor" #Name
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


# ------------- START OF SCRIPT

# Step 0: Valdiation of Harbor pods running in K8s cluster...
echo "Starting Harbor pods validation..."

echo "Starting Harbor pods validation..."

# Loop validation to verify that all pods in cluster are in "Running" status
while true; do
    RUNNING_PODS=$(kubectl get pods -n "$cluster_namespace" --selector=app=harbor --field-selector=status.phase=Running | grep -c Running)
    TOTAL_PODS=$(kubectl get pods -n "$cluster_namespace" --selector=app=harbor | grep -c Running)

    # Testing Purposes
    echo "Waiting for Harbor pods to be ready..."
    echo "RUNNING_PODS: $RUNNING_PODS"
    echo "TOTAL_PODS: $TOTAL_PODS"

    if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -ne 0 ]
    then
        echo "All pods $TOTAL_PODS from $cluster_namespace namespace are running..."
        echo "Harbor deployment is ready!"
        break
    elif [ "$TOTAL_PODS" -eq 0 ]; then
        echo "No pods found in $cluster_namespace namespace. Please check the deployment."
        exit 1
    else
        sleep 5  # Adjust sleep duration as needed
    fi
done

# Check Harbor Registry availability
check_harbor_availability

# Call of the function to build, upload or pull docker image into Harbor registry.
manage_image