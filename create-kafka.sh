#!/usr/bin/env bash
set -C -e -o pipefail

docker pull confluentinc/confluent-init-container:2.4.0
docker pull confluentinc/cp-zookeeper:7.2.0
docker pull confluentinc/cp-server:7.2.0
docker pull confluentinc/cp-server-connect:7.2.0
docker pull confluentinc/cp-ksqldb-server:7.2.0
docker pull confluentinc/cp-enterprise-control-center:7.2.0
docker pull confluentinc/cp-schema-registry:7.2.0
docker pull confluentinc/cp-kafka-rest:7.2.0
docker pull confluentinc/cp-kafka-mqtt:7.2.0

if [ ! -f "/usr/local/bin/kubectl-confluent" ] 
then
    echo “confluent-cli does not exist.” 
    curl -O https://confluent-for-kubernetes.s3-us-west-1.amazonaws.com/confluent-for-kubernetes-2.4.1.tar.gz
    mkdir confluent
    sudo tar -xvf confluent/confluent-for-kubernetes-2.4.1-20220801/kubectl-plugin/kubectl-confluent-darwin-arm64.tar.gz -C /usr/local/bin/
else
	echo “confluent-cli already installed….skipping”
fi

kubectl create namespace confluent

kubectl config set-context --current --namespace confluent

helm repo add confluentinc https://packages.confluent.io/helm 

helm repo update

helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes

kubectl apply -f https://raw.githubusercontent.com/confluentinc/confluent-kubernetes-examples/master/quickstart-deploy/confluent-platform-singlenode.yaml



kubectl confluent status
