#!/usr/bin/env bash

kubectl delete -f filebeat-kubernetes.yaml
kubectl delete -f metricbeat-kubernetes.yaml
kubectl delete -f packetbeat-kubernetes.yaml
kubectl delete secret dynamic-logging -n kube-system