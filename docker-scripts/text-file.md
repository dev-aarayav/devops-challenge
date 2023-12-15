#Others
# -e: Checks if the path exists regardless of the type (file, directory, symlink, etc.). -d: Specifically checks if the path is a directory. -f: Specifically checks if the path is a regular file.
# Explanation of docker image: -q used to display only image ID, "&>/dev/null"  redirects both standard output and error output to /dev/null to suppress any output on the console.
# -d > flag which runs the container in detahced mode. -p 80:80 > Maps port 80 of the host to port 80 of the container. -v > Mounts the local directory into the container where Nginx serves files.
# The instruction "Deploy Nginx in Docker container connected to a local path to put files for download" means setting up Nginx within a Docker container while connecting a local directory from the host machine to the container. This connected directory serves as the location where files for download will be stored and made available through the Nginx server.
# Here, -v "$HOST_PATH":/usr/share/nginx/html mounts the $HOST_PATH directory from the host machine onto the /usr/share/nginx/html directory inside the Nginx Docker container. This connection allows Nginx within the container to serve files located in $HOST_PATH to users accessing the server.



- Seach for user "aarayav" in "group" file to check if is part of Docker group (also display group ID)
```cat /etc/group | grep docker```


- Include any additional commands needed to complete the setup or for file downloading purposes. For example, you might include commands to add files to the directory mounted in the Nginx container or curl/wget commands for downloading files.