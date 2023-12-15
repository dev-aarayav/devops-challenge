# Additional relevant information of docker challenge

### Explanation of bash test into IF STATEMENT:
- ```if [ -e "$HOST_PATH" ]```: Checks if the path exists regardless of the type (file, directory, symlink, etc.). -d: Specifically checks if the path is a directory. -f: Specifically checks if the path is a regular file.


### Explanation of docker commands:

1.  docker images -q "$IMAGE_NAME" &>/dev/null:
    - ```q```: used to display only image ID.
    - ```"&>/dev/null"```: redirects both standard output and error output to /dev/null to suppress any output on the console.
2. docker run -d -p 8000:80 -v "$HOST_PATH":/usr/share/nginx/html --name mynginx "$IMAGE_NAME"
    - ```-d```: flag used to run the container in detahced mode.
    -  ```-p 80:80```: Maps port 80 of the host to port 80 of the container.
    - ```-v```: Mounts the local directory into the container where Nginx serves files.
    *NOTE: Here, ```-v``` "$HOST_PATH":/usr/share/nginx/html mounts the $HOST_PATH directory from the host machine Into the /usr/share/nginx/html directory inside the Nginx Docker container. This connection allows Nginx within the container to serve files located in $HOST_PATH to users accessing the server.*
3. ```cat /etc/group | grep docker```: OPTIONAL, When settip up Docker, I had to use the following command to search for user "aarayav" in "group" file to check if is part of Docker group (also display group ID)


- PEDNING: Include any additional commands needed to complete the setup or for file downloading purposes. For example, you might include commands to add files to the directory mounted in the Nginx container or curl/wget commands for downloading files.