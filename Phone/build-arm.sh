#!/bin/sh
#cd./Phone
#docker build -t esurfingdockerphone .
docker buildx build --platform linux/amd64 --tag esurfingdockerphone .
#docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
