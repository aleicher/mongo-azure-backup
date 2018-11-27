FROM ubuntu:16.04
RUN apt-get update && \
      apt-get -y install sudo apt-transport-https

#install azcopy: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod/ xenial main" > azure.list
RUN sudo cp ./azure.list /etc/apt/sources.list.d/
RUN sudo apt-key adv --keyserver packages.microsoft.com --recv-keys EB3E94ADBE1229CF
RUN sudo apt-get update && sudo apt-get install -y azcopy

#install mongo cli tools

RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN sudo apt-get update && sudo apt-get install -y mongodb-org-tools

WORKDIR /tmp
COPY backup_mongo.sh .
RUN chmod a+x backup_mongo.sh
