#!/bin/bash

kubectl expose deployment haproxy-ingress --type=LoadBalancer --name=haproxy-ingress-lb-public -n haproxy-controller
kubectl get services/haproxy-ingress-lb-public -n haproxy-controller
echo "\n\n **** If EXTERNAL-IP is <pending> execute in your terminal -> 'kubectl get services/haproxy-ingress-lb-public -n haproxy-controller' ****"