#!/bin/bash

# VARIABLES
DOCKER_SCRIPT="$0"
HOST_PATH="/home/aarayav/nginx_content"
HTML_CONTENT="<html>
<head>
  <title>Nginx Server</title>
</head>
<body>
  <h1>Welcome to NGINX Server!</h1>
  <p>This is a simple HTML content in a Bash variable.</p>
</body>
</html>"


# ---------------------------------------------------

# Function to install Docker
docker_inst() {
    echo "Starting Docker installation..."
    sudo apt-get update # Update package lists
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common # Install prerequisites
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - # Add Docker GPG key
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" # Add Docker repository
    sudo apt-get update # Update package lists
    sudo apt-get install -y docker-ce # Install Docker CE
    docker --version # Check Docker version
    sudo docker run hello-world # Verify that the Docker Engine installation is successful by running the "hello-world" image
    echo "Docker installation completed..."
    echo "--------------------------------"
    echo "--------------------------------"
}


# Function to check if Docker is installed
check_docker_installed() {
    if ! command -v docker &>/dev/null
    then
        echo "Docker is not installed. Proceeding with installation..."
        # Call the function to install Docker
        docker_inst

        # Verification step after installation
        if ! command -v docker &>/dev/null; then
            echo "Docker installation failed. Please install Docker manually..."
            exit 1
        else
            echo "Docker installed successfully!"
            echo "Proceeding with next steps..."
            echo "--------------------------------"
            echo "--------------------------------"
            sleep 5 # Pausing execution for 5 seconds for clarity of this first cycle.
        fi
    else
        echo "Docker is already installed..."
        echo "Proceeding with next steps..."
        echo "--------------------------------"
        echo "--------------------------------"
        sleep 5 # Pausing execution for 5 seconds for clarity of this first cycle.
    fi
    
}

# Check if Docker is installed
check_docker_installed

# Function to check if Docker Nginx image exists & setup of Nginx Docker container.
nginx_setup(){

    #ARGUMENT
    local IMAGE_NAME="$1"

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

# Previos steps to run safely
echo "Running package update & upgrade..."
sudo apt-get update && sudo apt upgrade -y
echo "Completed package update & upgrade..."
chmod 755 ${DOCKER_SCRIPT} # Granting execution access to file
echo "DOCKER_SCRIPT '$DOCKER_SCRIPT' is now executable."
echo "--------------------------------"
echo "--------------------------------"
sleep 5 # Pausing execution 2 for 5 seconds for clarity in second cycle.

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
nginx_setup "nginx"