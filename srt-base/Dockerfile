FROM alpine:latest as builder

RUN apk update && apk add tcl pkgconfig openssl-dev cmake gcc g++ make automake git bash ncftp

RUN git clone -b dev https://github.com/Haivision/srt.git \
    && cd srt \
    && git reset --hard 9e8c640aad65c420d712cde259b3fc94a0ff2770 \
    && ./configure \
    && make \
    && make install \
    && tar cvzf srt.tar.gz $(cat install_manifest.txt)

# ------------------------------------------

FROM alpine:latest

RUN apk update && apk add bash ncftp libcrypto1.0 libstdc++ libgcc

RUN wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/bin/jq \
    && chmod 755 /usr/bin/jq

COPY --from=builder /srt/srt.tar.gz .

RUN tar xvzf srt.tar.gz -C /

EXPOSE 8080/udp

