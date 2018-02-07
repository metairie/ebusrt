FROM alpine:latest

MAINTAINER Metairie Stephane EBU:0.1

RUN mkdir /opt
WORKDIR /opt

RUN apk update
RUN apk add tcl pkgconfig openssl-dev cmake gcc g++ make automake git bash ncftp
RUN git clone -b dev  https://github.com/Haivision/srt.git && \
 cd srt && ./configure && make && make install

RUN wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
 mv jq-linux64 /usr/bin/jq -f && \
 chmod 755 /usr/bin/jq
