#!/bin/bash

echo "#######################Exporting"

export JENKINS_POD_NAME=$(awk 'NR==1' variables.txt)
export JENKINS_LOAD_BALANCER_IP=$(awk 'NR==2' variables.txt)
export DOCKER_HOST_IP=$(awk 'NR==3' variables.txt)

if [[ ! -z "JENKINS_POD_NAME" ]]; then
    echo "It is okay"
    sleep 5
else
    exit 1
fi

apt-get update
apt-get install wget -y
apt-get install docker.io -y

echo "##########################Installation complete"

wget http://$JENKINS_LOAD_BALANCER_IP/jnlpJars/jenkins-cli.jar

# Creating admin user

# echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("admin", "admin")' |
# java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ groovy =

# Creating Jenkins credentials as file

touch creds
echo 'admin:admin' > creds

# Jenkins pluginlerin kurulumu
# ÖNEMLİ: Aşağıdaki pluginlerde kurulum esnasında yüklenen suggested pluginler yok. Örnek olarak git. Ona bir bak.

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -http -auth @creds install-plugin cloudbees-folder, docker-plugin, maven-plugin, docker-java-api, docker-workflow -deploy

# Enable proxy compatibility

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/  -http -auth @creds groovy = < proxy.groovy

# Deploy Pipelines and Credentials

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/  -http -auth @creds create-credentials-by-xml system::system::jenkins _ < credentials.xml

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/  -http -auth @creds create-job k8s-pipeline < k8s-pipeline.xml

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/  -http -auth @creds create-job updatemanifest < updatemanifest.xml

# Building k8s-pipeline

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/  -http -auth @creds build -p DOCKER_HOST=tcp://$DOCKER_HOST_IP:2375