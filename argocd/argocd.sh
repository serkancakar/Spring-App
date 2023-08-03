#!/bin/bash

# Creating environment variables

export ARGOCD_SERVICE_IP=$(kubectl get service argocd-server -n argocd -o jsonpath='{.status.LoadBalancer.ingress[0].ip0}')
export ARGOCD_SERVICE_PORT=$(kubectl get service argocd-server -n argocd -o jsonpath='{.spec.ports[0].port}')
export ARGOCD_SERVER_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d) 

# Installing ArgoCD

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Changing Kubernetes service to Load Balancer

kubectl patch service argocd-server -n argocd -p '{"spec":{"type": "LoadBalancer"}}'

# ArgoCD CLI Installation

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Login to ArgoCD server for implementing new app

argocd login $ARGOCD_SERVICE_IP:$ARGOCD_SERVICE_PORT --username admin --password $ARGOCD_SERVER_PASSWORD --insecure

# Creating the Application

kubectl create -f spring-argocd.yaml
