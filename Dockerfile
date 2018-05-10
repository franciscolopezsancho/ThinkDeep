FROM openjdk:latest

ARG GIT_USERNAME
ARG GIT_TOKEN

# Check for mandatory build arguments
RUN : "${GIT_USERNAME:? needs to be set and non-empty.}" 
RUN : "${GIT_TOKEN:? needs to be set and non-empty.}" 


ENV LD_LIBRARY_PATH="/usr/lib:/usr/local/lib/python3.5/dist-packages:/usr/local/lib/python3.5/dist-packages/jep" 
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libpython3.5m.so" 

RUN apt-get update
RUN apt-get install -y python3 python3-pip 
RUN pip3 install --upgrade pip 
RUN pip3 install tensorflow keras h5py jep 


RUN apt-get install -y git 
RUN mkdir /opt/ThinkDeep && git clone https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/ThinkBigAnalytics/ThinkDeep.git /opt/ThinkDeep 

RUN apt-get install -y maven
RUN mvn install:install-file -Dfile=/usr/local/lib/python3.5/dist-packages/jep/jep-3.7.1.jar -DgroupId=jep -DartifactId=jep -Dversion=3.7.1 -Dpackaging=jar

WORKDIR /opt/ThinkDeep
RUN mvn clean install -Dmaven.test.skip=true

WORKDIR /opt/ThinkDeep/model-trainer
CMD ["mvn","spring-boot:run"]