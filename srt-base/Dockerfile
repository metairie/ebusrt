FROM alpine:latest

MAINTAINER Metairie Stephane EBU:0.1

RUN mkdir /opt
WORKDIR /opt

RUN apk update
RUN apk add tcl pkgconfig openssl-dev cmake gcc g++ make automake git
RUN git clone -b dev  https://github.com/Haivision/srt.git && \
 cd srt && ./configure && make && make install