#!/bin/bash

echo '##############################Deploying resources'

cd ./yamls

kubectl apply -f .

cd ..

echo '##############################Deployed resources'

while [[ $(kubectl get pod -n jenkins -o jsonpath='{.items[].status.containerStatuses[].ready}') != true  ]]; do
    echo 'Waiting for pod to be ready'
    sleep 5
done  

# Creating environment variables

export JENKINS_POD_NAME=$(kubectl get pods -n jenkins --no-headers -o custom-columns=":metadata.name") > variables.txt  
export JENKINS_LOAD_BALANCER_IP=$(kubectl get service -n jenkins jenkins-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}') > variables.txt
export DOCKER_HOST_IP=$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}') > variables.txt

echo '##############################Copying files'

kubectl cp proxy.groovy jenkins/$JENKINS_POD_NAME:/
kubectl cp credentials.xml jenkins/$JENKINS_POD_NAME:/
kubectl cp k8s-pipeline.xml jenkins/$JENKINS_POD_NAME:/
kubectl cp updatemanifest.xml jenkins/$JENKINS_POD_NAME:/
kubectl cp pod.sh jenkins/$JENKINS_POD_NAME:/
kubectl cp variables.txt jenkins/$JENKINS_POD_NAME:/

echo '##############################Copy to pod finished'

kubectl -n jenkins exec -it $JENKINS_POD_NAME -- /bin/bash -c "chmod +x pod.sh export.sh && bash ./export.sh ./pod.sh"




