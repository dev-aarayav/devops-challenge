# Technical Challenge
### by Alexander Araya Vega

### 1. Nginx web server to expose files for download
- Prerequisites (Windows)
    - Install WSL, follow [official documentation](https://techcommunity.microsoft.com/t5/windows-11/how-to-install-the-linux-windows-subsystem-in-windows-11/m-p/2701207/page/2)
    - Install Ubuntu OS <18.x.x from [Microsoft Store](https://www.microsoft.com/store/productId/9MTTCL66CPXJ?ocid=pdpshare)

- Instructions
    - Clone the project locally in Ubuntu machine.
    - Open folder "docker-scripts" and use script ```nginx_setup.sh```
    - Execution command for the script: ```$ ./nginx_setup.sh nginx```
    - Run the following command and check if the Docker container is running: ```$ docker ps```
     * NOTE: It should display an output like below:
     ![Dcoker ps output](image.png)
    - Open a web browser and access http://localhost:8000 to see Nginx index web page running.
     * NOTE: It should display the following text in browser:


