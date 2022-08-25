FROM registry.access.redhat.com/ubi8/python-38


# Add application sources with correct permissions for OpenShift
COPY requirements.txt requirements.txt

# Install the dependencies
RUN pip install -U "pip>=19.3.1" && \
    pip install -r requirements.txt 

COPY . .

# Run the application
CMD gunicorn -b 0.0.0.0:8081 wsgi
