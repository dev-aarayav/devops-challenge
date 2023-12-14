#!/bin/bash

# Function to install Docker on Ubuntu OS
docker_inst() {
    echo "Starting Docker installation..."
    
    # Update package lists
    sudo apt-get update

    # Install prerequisites
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Add Docker repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Update package lists
    sudo apt-get update

    # Install Docker CE
    sudo apt-get install -y docker-ce

    # Check Docker version
    docker --version

    # Verify that the Docker Engine installation is successful by running the "hello-world" image. This command downloads 
    # a test image and runs it in a container. When container runs it prints a confirmation message and exits.
    sudo docker run hello-world
}

# Call the function to install Docker
docker_inst