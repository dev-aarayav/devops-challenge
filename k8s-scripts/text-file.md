Explanation of command: ```IMAGE_EXISTS=$(docker pull localhost:5000/my-project/my-image:v1 2>&1 | grep -c "manifest unknown")```

docker pull localhost:5000/my-project/my-image:v1: This part attempts to pull the specified image (my-image:v1) from the Harbor registry running at localhost:5000. The 2>&1 part at the end of the command redirects both standard output and standard error to the same stream.

| grep -c "manifest unknown": The | (pipe) symbol takes the output from the previous command (docker pull) and passes it to grep, a command-line utility for searching patterns. -c in grep -c counts the number of lines that match the pattern provided. Here, grep -c "manifest unknown" searches for the phrase "manifest unknown" in the output of the docker pull command.

Putting it together:

The command docker pull localhost:5000/my-project/my-image:v1 2>&1 | grep -c "manifest unknown" attempts to pull the image my-image:v1 from the specified Harbor registry. If the image does not exist in the registry, Docker returns an error with the message "manifest unknown." The grep -c command counts how many times this error message appears in the output.

So, the variable IMAGE_EXISTS will contain the count of occurrences of "manifest unknown" in the output of docker pull. If the image doesn't exist in the registry, IMAGE_EXISTS will be 1 (indicating one occurrence of "manifest unknown"), and if the image does exist, IMAGE_EXISTS will be 0 (indicating no occurrences).


Description of commands 

docker build -t "$IMAGE_NAME:$TAG" "$DIR_DCK" # docker build -t <image-name>:<tag> <path-to-dockerfile>
docker tag "$IMAGE_NAME:$TAG" "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE_NAME:$TAG" # docker tag <image-name>:<tag> <harbor-registry>/<project>/<image-name>:<tag>
docker push "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE_NAME:$TAG" # docker push <harbor-registry>/<project>/<image-name>:<tag>

docker pull "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE:$TAG" # docker pull <harbor-registry>/<project>/<image-name>:<tag>

# /home/aarayav/root/devops-challenge/k8s-scripts/node_app/