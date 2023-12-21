#!/bin/bash

# VARIABLES
IMAGE_NAME="$1"
DOCKER_SCRIPT="$0"
HOST_PATH="/home/aarayav/nginx_content"
HTML_CONTENT="<html>
<head>
  <title>Nginx Server</title>
</head>
<body>
  <h1>Welcome to NGINX Server!</h1>
  <p>This is a simple HTML content in a Bash variable.</p>
  <p>By Alexander Araya Vega</p>
</body>
</html>"


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


# Function to check if Docker Nginx image exists & setup of Nginx Docker container.
nginx_setup(){

    # Pull Nginx Docker image if not present
    if ! docker images -q "$IMAGE_NAME" &>/dev/null #doubt about exclamation mark
    then
        echo "Pulling docker image '$IMAGE_NAME'..."
        docker pull "$IMAGE_NAME"
    fi

    # Check if the image exists now
    if docker images -q "$IMAGE_NAME" &>/dev/null
    then
        echo "The Docker image '$IMAGE_NAME' is installed..."
        echo "Running Docker container named 'mynginx' from the '$IMAGE_NAME' image"
        docker run -d -p 8000:80 -v "$HOST_PATH":/usr/share/nginx/html --name mynginx "$IMAGE_NAME"
        echo "Docker Nginx configuration completed..."
        echo "Run 'docker ps' to check if Nginx container is running"
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5 # Pausing execution for 5 seconds for clarity of this first cycle.

    else
        echo "The Docker image '$IMAGE_NAME' is not installed..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5 # Pausing execution for 5 seconds for clarity of this first cycle.
    fi
}

# ---------------- LOGIC

# Call function for docker setup
docker_setup

# Verification of directory existance
if [ -e "$HOST_PATH" ]
then
    echo "Path '$HOST_PATH' exists..."
    cd "$HOST_PATH"
    rm index.html
    echo "$HTML_CONTENT" > "$HOST_PATH/index.html"
    echo "New 'index.html' file created for Nginx Server..."
else
    echo "Path '$HOST_PATH' does not exist."
    mkdir -p "$HOST_PATH" # Create directory
    echo "Directory '$HOST_PATH' created..."
    chmod -R 777 "$HOST_PATH"
    echo "Granted permissions that allow the Docker process to access it..."
    echo "$HTML_CONTENT" > "$HOST_PATH/index.html"
    echo "New index.html created for Nginx Server"
    echo "--------------------------------"
    echo "--------------------------------"
    sleep 5 # Pausing execution 2 for 5 seconds for clarity in second cycle.

fi

# Call the function with the image name as an argument
nginx_setup "$IMAGE_NAME"