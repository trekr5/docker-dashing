#Dockerfile for Dashing

FROM ubuntu:14.04

MAINTAINER Angela Ebirim <angela.ebirim@justgiving.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

#Runit
RUN apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#required
RUN apt-get install -y build-essential ruby1.9.1 ruby1.9.1-dev libxslt-dev libxml2-dev zlib1g-dev
RUN gem install dashing --no-rdoc --no-ri
RUN gem install bundler --no-rdoc --no-ri

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#nodejs
RUN apt-get install -y python-software-properties
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y nodejs

EXPOSE 3030
ENV DASHBOARD new_graphite 

RUN dashing new $DASHBOARD && \
    chmod 777 $DASHBOARD && \
    cd $DASHBOARD && \
    bundle

CMD cd /$DASHBOARD;dashing start
RUN echo "dashing started..."
