FROM ubuntu:16.04

RUN apt-get update && \
    apt-get -y install \
      apt-transport-https \
      curl \
      software-properties-common

#install azcopy
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-add-repository https://packages.microsoft.com/ubuntu/16.04/prod && \
    apt-get update && apt-get install -y azcopy

#install mongo cli tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
    apt-get update && apt-get install -y mongodb-org-tools

WORKDIR /tmp

COPY backup_mongo.sh .
RUN chmod a+x backup_mongo.sh
ENTRYPOINT [ "./backup_mongo.sh" ]
