This project demonstrates object detection in both video and photo. To run locally;

Presumptions
- s2i installed on local
- docker desktop running

> cd object-detection-rest
> s2i build . registry.access.redhat.com/ubi8/python-38 object-detection-rest:latest
> docker run --rm -i -p 8081:8081 -t —name object-detection-rest object-detection-rest:latest
> docker inspect object-detection-rest | grep IPAddress

NOTE! ip address (REST-IPADDRESS) above will be used in the following steps

> cd ../object-detection-app
> s2i build . registry.access.redhat.com/ubi8/nodejs-14:latest object-detection-app:latest
> docker run --rm -i -p 8080:8080 -t --env OBJECT_DETECTION_URL=http://{REST_IPADDRESS}:8081/predictions object-detection-app:latest

Then to push to docker hub in order to use in kubesphere;

> cd object-detection-rest
> docker image tag object-detection-rest socrates12345/object-detection-rest:latest
> docker image push socrates12345/object-detection-rest:latest

> cd ../object-detection-app
> docker image tag object-detection-app socrates12345/object-detection-app:latest
> docker image push socrates12345/object-detection-app:latest

NOTE!

both directories include Dockerfile but please note, this is purely for demonstration purposes and is not needed, just to understand what the s2i tool is doing. This can be used as follows;

> cd object-detection-rest
> docker build -t object-detection-rest:latest .

then the run and push commands will be as above. Something is a little weired with the object-detection-app module though, hence strongly recommend using s2i since this is what the compute environment will run anyway, so a closer alignment there.



