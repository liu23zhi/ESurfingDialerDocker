#!/bin/sh
#cd./Phone
#docker build -t esurfingdockerphone .
#docker pull azul/zulu-openjdk:21-jdk-crac-latest
docker buildx build --platform linux/amd64 --tag esurfingdockerphone --load .
#docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
