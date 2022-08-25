FROM registry.access.redhat.com/ubi8/nodejs-14:latest 


# Add application sources
COPY . . 

# Install the dependencies
RUN npm install

# Run script uses standard ways to run the application
CMD npm run -d start
