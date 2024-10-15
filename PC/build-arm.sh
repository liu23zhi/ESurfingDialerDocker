#!/bin/sh
#cd./Phone
#docker build -t esurfingdockerpc .
mkdir -p ./ubuntu-base-24.04.1-base-amd64/app/
#cp ./run 
docker buildx build --platform linux/arm64 --tag esurfingdockerpc --load .
#docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
