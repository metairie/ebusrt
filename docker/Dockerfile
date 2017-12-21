FROM alpine:latest

MAINTAINER Metairie Stephane EBU:0.1

RUN apk update
RUN mkdir /opt
RUN apk add tcl pkgconfig openssl-dev cmake gcc g++ make automake git
RUN cd /opt && \
 git clone -b dev  https://github.com/Haivision/srt.git && \
 cd srt && \
 ./configure && \
 make && \
 make install
