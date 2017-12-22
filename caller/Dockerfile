FROM alpine:latest

MAINTAINER Metairie Stephane EBU:0.1

RUN mkdir /opt
WORKDIR /opt

RUN apk update
RUN apk add tcl pkgconfig openssl-dev cmake gcc g++ make automake git
RUN git clone -b dev  https://github.com/Haivision/srt.git && \
 cd srt && ./configure && make && make install

# Create the log file
RUN mkdir ebusrt && mkdir ebusrt/log && touch ebusrt/log/srt.log

# Copy ebusrt files
COPY scripts/listener.sh ebusrt/scripts/listener.sh
RUN chmod +x ebusrt/scripts/*

# start main command
#CMD /opt/ebusrt/scripts/listener.sh && : >> /opt/ebusrt/log/srt.log && tail -f /opt/ebusrt/log/srt.log
CMD echo "starting srt ..." && (/opt/ebusrt/scripts/listener.sh) && : >> /opt/ebusrt/log/srt.log && tail -f /opt/ebusrt/log/srt.log