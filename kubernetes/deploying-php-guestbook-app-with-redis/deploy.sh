#!/usr/bin/env bash

kubectl apply -f redis-master-deployment.yaml
kubectl apply -f redis-master-service.yaml

kubectl apply -f redis-slave-deployment.yaml
kubectl apply -f redis-slave-service.yaml

kubectl apply -f front-end-deployment.yaml
kubectl apply -f front-end-service.yaml