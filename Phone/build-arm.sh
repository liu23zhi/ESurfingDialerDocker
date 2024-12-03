#!/bin/sh
#cd./Phone
#docker build -t esurfingdockerphone .
#docker buildx pull --platform linux/arm64 azul/zulu-openjdk:21-jdk-crac-latest
docker buildx build --platform linux/arm64 --tag esurfingdockerphone --load .
#docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
