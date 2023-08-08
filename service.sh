#!/bin/bash

export POSTGRES_SERVICE_IP=$(kubectl get service -n postgres postgres-service -o jsonpath='{.spec.clusterIP}')
echo $POSTGRES_SERVICE_IP
export REDIS_SERVICE_IP=$(kubectl get service -n redis redis-service -o jsonpath='{.spec.clusterIP}')
echo $REDIS_SERVICE_IP

yaml_file="../spring/src/main/resources/application.yml"

sed -i "s/\b10.99.155.154\b/$POSTGRES_SERVICE_IP/g" "$yaml_file"
sed -i "s/10.97.44.83/$REDIS_SERVICE_IP/g" "$yaml_file