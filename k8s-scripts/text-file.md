### Additional information of Kubernetes solution.

### Required commands to stop and clean up services after running your script to reset the environment:
- List all Helm releases across all namespaces (-A flag): ```helm list -A```
- Remove Helm Release (Harbor deployment): ```helm uninstall <release-name>```

(ONLY IF IS NOT DEFAULT NAMESPACE)
- Get K8s Namespaces: ```kubectl get namespaces```
- Reset K8s Namespace: ```kubectl delete namespace <namespace-name>```
- Delete all pods from Namespace: ```kubectl delete pods --all -n default```
- Delete specific K8s resources: ```kubectl delete <resource_type> -l <label_selector> -n default```

- Stop Minikube: ```minikube stop```
- Delete Minikube: ```minikube delete```
- List Docker images: ```docker images```
- Remove Docker Images: ```docker rmi <image-name>``

### Meaning of each Docker command flag (with VARIABLE):
- docker build -t "$IMAGE_NAME:$TAG" "$DIR_DCK": ```docker build -t <image-name>:<tag> <path-to-dockerfile>```
- docker tag "$IMAGE_NAME:$TAG" "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE_NAME:$TAG": ```docker tag <image-name>:<tag> <harbor-registry>/<project>/<image-name>:<tag>```
- docker push "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE_NAME:$TAG": ```docker push <harbor-registry>/<project>/<image-name>:<tag>```
- docker pull "$HARBOR_REGISTRY/$PROJECT_NAME/$IMAGE:$TAG": ```docker pull <harbor-registry>/<project>/<image-name>:<tag>```

### Explanation of multiple script commands:
1. ```IMAGE_EXISTS=$(docker pull localhost:5000/my-project/my-image:v1 2>&1 | grep -c "manifest unknown")```: 
    - Docker pull localhost:5000/my-project/my-image:v1: This part attempts to pull the specified image (my-image:v1) from the Harbor registry running at localhost:5000. The 2>&1 part at the end of the command redirects both standard output and standard error to the same stream.
    - grep -c "manifest unknown": The | (pipe) symbol takes the output from the previous command (docker pull) and passes it to grep, a command-line utility for searching patterns. -c in grep -c counts the number of lines that match the pattern provided. Here, grep -c "manifest unknown" searches for the phrase "manifest unknown" in the output of the docker pull command.
    - Putting it together: The command docker pull localhost:5000/my-project/my-image:v1 2>&1 | grep -c "manifest unknown" attempts to pull the image my-image:v1 from the specified Harbor registry. If the image does not exist in the registry, Docker returns an error with the message "manifest unknown." The grep -c command counts how many times this error message appears in the output.
    - So, the variable IMAGE_EXISTS will contain the count of occurrences of "manifest unknown" in the output of docker pull. If the image doesn't exist in the registry, IMAGE_EXISTS will be 1 (indicating one occurrence of "manifest unknown"), and if the image does exist, IMAGE_EXISTS will be 0 (indicating no occurrences).
2. ```helm show values harbor/harbor```:
    - Command used to display all the Harbor default values for configuration.
    - The output can be used as reference to create own ```values.yaml``` and create a Helm Chart.

### Namespaces available in Minikube cluster
- default: This is the default namespace where resources are created if no other namespace is specified.
- kube-node-lease: This namespace holds node lease objects that nodes use to declare their health status to the control plane.
- kube-public: This namespace contains resources that should be made available to all users, typically used for cluster information.
- kube-system: This namespace contains Kubernetes system resources and control plane components like kube-dns, kube-proxy, etc.

### Pods available for Harbor namespace (default)
- harbor-core: Core Harbor services
- harbor-database: Harbor's database service
- harbor-jobservice: Job service responsible for background jobs in Harbor
- harbor-portal: The Harbor web portal interface
- harbor-redis: Redis service used by Harbor
- harbor-registry: Registry service where Docker images are stored
- harbor-trivy: Security scanner service (Trivy) for vulnerabilities in images

Each of these pods represents a different component or service within the Harbor deployment, contributing to its functionality as a container registry and image management system.



# ./test2.sh /home/aarayav/root/devops-challenge/k8s-scripts/py_app/ py-image py-project