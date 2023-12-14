#!/bin/bash

#VAR
SCRIPT="$0"
HOST_PATH="/home/aarayav/nginx_content"
HTML_CONTENT="<html>
<head>
    <title>CONGRATULATIONS!</title>
</head>
<body>
    <h1>You have successfully executed the Docker NGNIX automated script!</h1>
    <p>This is a sample index.html file created by a Bash script.</p>
</body>
</html>"

# Function to check if a Docker image exists
image_verf(){

    #ARGUMENT
    local IMAGE_NAME="$1"

    # Pull Nginx Docker image if not present
    if ! docker images -q "$IMAGE_NAME" &>/dev/null #doubt about exclamation mark
    then
        echo "Pulling docker image '$IMAGE_NAME'"
        docker pull "$IMAGE_NAME"
    fi

    # Check if the image exists now
    if docker images -q "$IMAGE_NAME" &>/dev/null
    then
        echo "The Docker image '$IMAGE_NAME' is installed."
        echo "Running Docker container named 'mynginx' from the '$IMAGE_NAME' image"
        docker run -d -p 8000:80 -v "$HOST_PATH":/usr/share/nginx/html --name mynginx "$IMAGE_NAME"

    else
        echo "The Docker image '$IMAGE_NAME' is not installed."
    fi
}

# Previos steps to run safely
echo "Running package update & upgrade"
sudo apt-get update
sudo apt-get update
echo "Completed package update & upgrade"

# Granting execution access to file
chmod 755 ${SCRIPT}
echo "Script '$SCRIPT' is now executable."

# Verification of directory existance
if [ -e "$HOST_PATH" ]
then
    chmod -R 777 "$HOST_PATH"
    echo "Path '$HOST_PATH' exists."
    echo "$HTML_CONTENT" > "$HOST_PATH/index.html"
    echo "index.html created for Nginx Server"
else
    echo "Path '$HOST_PATH' does not exist."
    mkdir -p "$HOST_PATH" # Create directory
    echo "Directory '$HOST_PATH' created."
    chmod -R 777 "$HOST_PATH"
    echo "Granted permissions that allow the Docker process to access it"
    echo "$HTML_CONTENT" > "$HOST_PATH/index.html"
    echo "index.html created for Nginx Server"

fi

# Call the function with the image name as an argument
image_verf "nginx"



#Others
# -e: Checks if the path exists regardless of the type (file, directory, symlink, etc.). -d: Specifically checks if the path is a directory. -f: Specifically checks if the path is a regular file.
# Explanation of docker image: -q used to display only image ID, "&>/dev/null"  redirects both standard output and error output to /dev/null to suppress any output on the console.
# -d > flag which runs the container in detahced mode. -p 80:80 > Maps port 80 of the host to port 80 of the container. -v > Mounts the local directory into the container where Nginx serves files.
