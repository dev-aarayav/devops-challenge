# FUNCTIONALITY


# Initiate Minikube cluster

minikube delete
minikube start --kubernetes-version=v1.27.0

# Download Helm binary
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

# Install Helm
chmod 700 get_helm.sh
./get_helm.sh

# Add Harbor Helm repository
helm repo add harbor https://helm.goharbor.io

# Install Harbor chart (adjust values as needed)
helm install harbor harbor/harbor

# Function to check if Harbor is running and accesible within Minikube cluster.
check_harbor() {
    HARBOR_URL="http://$(minikube ip):<HARBOR_PORT>"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $HARBOR_URL)
    
    if [ $RESPONSE -eq 200 ]; then
        echo "Harbor is running and accessible at $HARBOR_URL"
    else
        echo "Harbor is not accessible at $HARBOR_URL"
    fi
}

# Function to upload Docker images into Harbor registry
upload_to_harbor() {
    # Build the Docker image
    # docker build -t <image-name>:<tag> <path-to-dockerfile>
    docker build -t my-image:v1 /path/to/Dockerfile
    
    # Tag the image for Harbor registry
    # docker tag <image-name>:<tag> <harbor-registry>/<project>/<image-name>:<tag>
    docker tag my-image:v1 localhost:5000/my-project/my-image:v1

    # Push the image to Harbor registry
    # docker push <harbor-registry>/<project>/<image-name>:<tag>
    docker push localhost:5000/my-project/my-image:v1
}

# Function to pull  Docker images from Harbor registry
pull_from_harbor() {
    # Pull the image from Harbor registry
    # docker pull <harbor-registry>/<project>/<image-name>:<tag>
    docker pull localhost:5000/my-project/my-image:v1
}
