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

export JENKINS_POD_NAME=$(kubectl get pods -n jenkins --no-headers -o custom-columns=":metadata.name")
export JENKINS_LOAD_BALANCER_IP=$(kubectl get service -n jenkins jenkins-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export DOCKER_HOST_IP=$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')

echo '##############################Echo variables.txt'

echo "$JENKINS_POD_NAME" > variables.txt
echo "$JENKINS_LOAD_BALANCER_IP" >> variables.txt
echo "$DOCKER_HOST_IP" >> variables.txt

cat variables.txt


echo '##############################Copying files'

kubectl cp proxy.groovy jenkins/$JENKINS_POD_NAME:/
kubectl cp credentials.xml jenkins/$JENKINS_POD_NAME:/
kubectl cp k8s-pipeline.xml jenkins/$JENKINS_POD_NAME:/
kubectl cp updatemanifest.xml jenkins/$JENKINS_POD_NAME:/
kubectl cp pod.sh jenkins/$JENKINS_POD_NAME:/
kubectl cp variables.txt jenkins/$JENKINS_POD_NAME:/

echo '##############################Copy to pod finished'

kubectl exec -n jenkins -it $JENKINS_POD_NAME -- /bin/bash -c "chmod +x pod.sh && bash ./pod.sh"

echo '##############################Exec completed'
