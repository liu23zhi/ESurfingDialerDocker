#!/bin/sh
#cd./Phone
#docker build -t esurfingdockerpc .
docker buildx build --platform linux/amd64 --tag esurfingdockerpc --load .
#docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
