FROM ebuit/srt-base:latest

MAINTAINER Metairie Stephane EBU:0.1

WORKDIR /opt

# Create the log file
RUN mkdir ebusrt && mkdir ebusrt/log && touch ebusrt/log/srt.log

# Copy ebusrt files
COPY scripts/listener.sh ebusrt/scripts/listener.sh
RUN chmod +x ebusrt/scripts/*

# start main command
CMD echo "starting srt ..." && (/opt/ebusrt/scripts/listener.sh) && : >> /opt/ebusrt/log/srt.log && tail -f /opt/ebusrt/log/srt.log