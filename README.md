# docker-ebusrt

An SRT Docker image based on [Alpine Linux][alpine].

**WARNING** : BETA VERSION , NOT GUARANTEED.

We only manage UDP files transfer, it's NOT for streaming live!
The code source is based on SRT dev branch, not master release yet. Bugs would be possible at any moment.

## Why?

We need robust UDP transfer for big files. So, we embed some extra services around SRT (Secure Reliable Transport).

## How to do?

Pull docker on source and destination machines. 

Destination machine : launch docker ebusrt image in listener mode, so it's always listening for receiving files.

Source machine : launch docker ebusrt image in caller mode, so it's always listening for sending files.

This is a very simple, robust and isolated process.

## 1 caller to 1 listener mode

Send files from 1 source repository {repository}/QUEUE to 1 destination {repository}/RECEIVE

### Usage

Source machine
This command run srt in caller mode, share tmp folder, configured with json
docker run -it -v /tmp:/tmp -v srt.json:srt.json -e "SRT_MODE=caller" ebusrt:latest

Destination machine
This command run srt in listener mode, share tmp folder, configured with json
docker run -it -v /tmp:/tmp -v srt.json:srt.json -e "SRT_MODE=listener" ebusrt:latest

## 1 caller to 1-n listener mode

not implemented yet

## 1-n caller to 1 listener mode

not implemented yet

## 1-n caller to 1 listener mode

not implemented yet

## Want to build your own ebusrt docker images ?

Get sources : git clone https://github.com/metairie/ebusrt.git

go inside srt-base folder : docker build . -t srt-base

go inside ebusrt-listener folder : docker build . -t ebusrt-listener

go inside ebu-caller folder : docker build . -t ebusrt-caller

## References
Secure Reliable Transport: [srt](https://github.com/Haivision/srt)

Docker Alpine: [alpine-packages](https://hub.docker.com/r/alpine/git/)
