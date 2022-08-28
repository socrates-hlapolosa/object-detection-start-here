#!/usr/bin/env bash
set -C -e -o pipefail

aws eks update-kubeconfig --region us-east-1 --name $1 --kubeconfig /Users/socrates/.kube/$1
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.3.0/kubesphere-installer.yaml --kubeconfig /Users/socrates/.kube/$1
kubectl apply -f kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.3.0/cluster-configuration.yaml --kubeconfig /Users/socrates/.kube/$1
kubectl create namespace confluent --kubeconfig /Users/socrates/.kube/$1
kubectl config set-context --current --namespace confluent --kubeconfig /Users/socrates/.kube/$1
helm repo add confluentinc https://packages.confluent.io/helm

helm repo update

helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes --kubeconfig /Users/socrates/.kube/$1

kubectl apply -f https://raw.githubusercontent.com/confluentinc/confluent-kubernetes-examples/master/quickstart-deploy/confluent-platform.yaml --kubeconfig /Users/socrates/.kube/$1
