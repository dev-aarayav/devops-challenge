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



# Check Harbor Registry availability
check_harbor_availability

# Call of the function to build, upload or pull docker image into Harbor registry.
manage_image