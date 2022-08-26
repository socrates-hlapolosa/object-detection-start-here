This project demonstrates object detection in both video and photo. To run locally;
```
just incase, the two directories below are links from;
> https://github.com/rh-aiservices-bu/object-detection-rest
> https://github.com/rh-aiservices-bu/object-detection-app
> https://github.com/rh-aiservices-bu/object-detection-kafka-consumer.git
```

Presumptions
- s2i installed on local
- docker desktop running

```
$ cd object-detection-rest
$ s2i build . registry.access.redhat.com/ubi8/python-38 object-detection-rest:latest
$ docker run --rm -i -p 8081:8081 -t —name object-detection-rest object-detection-rest:latest
$ docker inspect object-detection-rest | grep IPAddress
```
NOTE! ip address (REST-IPADDRESS) above will be used in the following steps. To test that the rest service has been deployed successfully;
```
$ curl -i -X POST -H "Content-Type: application/json" http://localhost:8081/predictions --data-binary "@sample-requests/twodogs.json"
$cd ../object-detection-app
$ s2i build . registry.access.redhat.com/ubi8/nodejs-14:latest object-detection-app:latest
$ docker run --rm -i -p 8080:8080 -t --env OBJECT_DETECTION_URL=http://{REST_IPADDRESS}:8081/predictions object-detection-app:latest
```
Then to push to docker hub in order to use in kubesphere;
```
$ cd object-detection-rest
$ docker image tag object-detection-rest socrates12345/object-detection-rest:latest
$ docker image push socrates12345/object-detection-rest:latest

$ cd ../object-detection-app
$ docker image tag object-detection-app socrates12345/object-detection-app:latest
$ docker image push socrates12345/object-detection-app:latest
```
NOTE!

both directories include Dockerfile but please note, this is purely for demonstration purposes and is not needed, just to understand what the s2i tool is doing. This can be used as follows;
```
$ cd object-detection-rest
$ docker build -t object-detection-rest:latest .
```
then the run and push commands will be as above. Something is a little weired with the object-detection-app module though, hence strongly recommend using s2i since this is what the compute environment will run anyway, so a closer alignment there.

## Running on Kubernetes

Assumptions;
1. kubernetes is installed and running locally
2. helm locally installed
3. confluent cli locally installed

Steps;
1. to speed up the process, pull images first
2. create deployments

### Pull images

```
> $ docker pull socrates12345/object-detection-app
> $ docker pull socrates12345/object-detection-rest
```

### Create deployments

```
> $ kubectl apply -f object-detection-deployment.yaml
```

then to test;
> $ cd object-detection-app
> $ curl -i -X POST -H "Content-Type: application/json" http://localhost:8080/predictions --data-binary "@sample-requests/twodogs.json"

## Kafka Realtime consumption

Assumptions;

1. kubernetes is installed and running locally
2. helm locally installed
3. confluent cli locally installed

Steps;
1. clear all currently running deployments
2. install confluent
3. update app.py
4. build image
5. deploy application

### 1. Clear running deployments

```
$ kubectl delete -f object-detection-deployment.yaml
```
### 2. Install Confluent

```
$ ./create-kafka.sh
```
NOTE! can run the following command to see when all kafka componenets are up
```
$ watch -n 2 -d kubectl confluent status
```
then when all is up
```
$ http://localhost:80/
```
for the front end to be able to connect with the cluster will also need

```
$ kubectl port-forward controlcenter-0 9021:9021
```
### 3. Update project
Note! An issue was picked up that means you cant run the project as is from git
since kafka python will not connect to the kubernetes server without you specifying the
api_version property, hence the update

```
$ mv kafka-consumer-app.py object-detection-kafka-consumer
```
##### Lessons: 
1. for connections you only need the bootstrap_server, consumer_topic, producer_topic
2. always need api_version
3. group_id is what appears in the kafka console
4. the dns name of kafka is <service_name>.<namespace>.svc.cluster.local:9092
    so in this case kafka.confluent.svc.cluster.local:9092

### 4. Build image

```
$ cd object-detection-kafka-consumer
$ git commit -am "on the way"
$ s2i build . registry.access.redhat.com/ubi8/python-38 socrates12345/object-detection-kafka-consumer:latest
```

##### Lessons:
1. unlike when running foto, which uses a restfull endpoint, the video streams websocket to kafka
2. foto will make a http request, but the response comes as a websocket
3. the port forwarding above is for the frontend to be able to get to kubernetes it uses localhost address, not kubernetes FQDN
4. the environment variables for bootstrap_server will be kubernetes dns name while for front end will be localhost
5. go delete the any old images after running s2i above, old images just take space
6. s2i looks at latest commit, so if you make changes and dont commit, it wont work, your changes wont appear

### 5. Deploy application

```
$ kubectl apply -f ../object-detection-deployment-kafka.yaml
```

#### Note! In the deployment above, the container that runs kafka python client needs to be of the same namespace as kafka server, in this case confluent, else networking wont work

to stop everything afterwards;
```
$ kubectl delete -f ../object-detection-deployment-kafka.yaml
```