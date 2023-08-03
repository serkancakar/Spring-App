#!/bin/bash/

cd /apps/jenkins/yamls

kubectl apply -f .

cd ..

# Creating environment variables

export JENKINS_POD_NAME=$(kubectl get pods -n jenkins --no-headers -o custom-columns=":metadata.name")     
export JENKINS_LOAD_BALANCER_IP=$(kubectl get service -n jenkins jenkins-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export DOCKER_HOST_IP=$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')

# For enabling proxy compatibility

kubectl cp proxy.groovy jenkins/$JENKINS_POD_NAME:/

# For deploying credentails and pipelines

kubectl cp credentials.xml jenkins/$JENKINS_POD_NAME:/
kubectl cp k8s-pipeline.xml jenkins/$JENKINS_POD_NAME:/
kubectl cp updatemanifest.xml jenkins/$JENKINS_POD_NAME:/

kubectl exec -it -n jenkins $JENKINS_POD_NAME -- /bin/bash

apt-get update
apt-get install wget, docker.io

wget http://$JENKINS_LOAD_BALANCER_IP/jnlpJars/jenkins-cli.jar

# Creating Jenkins credentials as file

touch creds
echo 'admin:admin' > creds

# Jenkins pluginlerin kurulumu
# ÖNEMLİ: Aşağıdaki pluginlerde kurulum esnasında yüklenen suggested pluginler yok. Örnek olarak git. Ona bir bak.

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -auth @creds install-plugin docker-plugin, maven-plugin, docker-java-api, docker-workflow -deploy

# Enable proxy compatibility

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -auth @creds groovy = < proxy.groovy

# Deploy Pipelines and Credentials

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -auth @creds create-credentials-by-xml system::system::jenkins _ < credentials.xml

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -auth @creds create-job k8s-pipeline < k8s-pipeline.xml

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -auth @creds create-job updatemanifest < updatemanifest.xml

# Building k8s-pipeline

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -auth @creds build -p DOCKER_HOST=tcp://$DOCKER_HOST_IP:2375


exit




