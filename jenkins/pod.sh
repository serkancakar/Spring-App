#!/bin/bash

echo "#######################Exporting"

export JENKINS_POD_NAME=$(awk 'NR==1' variables.txt)
export JENKINS_LOAD_BALANCER_IP=$(awk 'NR==2' variables.txt)
export DOCKER_HOST_IP=$(awk 'NR==3' variables.txt)
export JENKINS_UI=$(cat /var/jenkins_home/secrets/initialAdminPassword)

echo $JENKINS_POD_NAME
echo $JENKINS_LOAD_BALANCER_IP
echo $DOCKER_HOST_IP
echo $JENKINS_UI

if [[ ! -z "JENKINS_POD_NAME" ]]; then
    echo "It is okay"
    sleep 5
else
    exit 1
fi

echo "#######################Installing packages"

apt-get update
apt-get install wget -y
apt-get install docker.io -y

echo "##########################Installation complete"

wget http://$JENKINS_LOAD_BALANCER_IP/jnlpJars/jenkins-cli.jar

echo "#######################Authentication"

touch creds
echo 'admin:admin' > creds

echo "#######################Login as admin"

#!/bin/bash

while true; do
    output=$(java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -http -auth @creds who-am-i 2>/dev/null)
    admin=$(echo "$output" | grep -o 'Authenticated as: [[:alnum:]]*' | awk '{print $NF}')

    if [ "$admin" = "admin" ]; then
        echo "Admin username: $admin"
        break
    else
        echo "You need to login with initial password: $JENKINS_UI"
        sleep 60 
    fi
done


echo "#######################Logged in"

plugins=("groovy" "cloudbees-folder" "docker-plugin" "maven-plugin" "docker-java-api" "docker-workflow")

for element in "${plugins[@]}"; do
  java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -http -auth @creds install-plugin $element -deploy
done


# Enable proxy compatibility

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -http -auth @creds groovy = < proxy.groovy

# Deploy Pipelines and Credentials

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -http -auth @creds create-credentials-by-xml system::system::jenkins _ < credentials.xml

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -http -auth @creds create-job k8s-pipeline < k8s-pipeline.xml

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -http -auth @creds create-job updatemanifest < updatemanifest.xml

# Building k8s-pipeline

java -jar jenkins-cli.jar -s http://$JENKINS_LOAD_BALANCER_IP/ -http -auth @creds build k8s-pipeline -p DOCKER_HOST=tcp://$DOCKER_HOST_IP:2375