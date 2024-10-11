#!/bin/sh
#cd./Phone
#docker build -t esurfingdockerphone .
docker buildx build --platform linux/amrm4 --tag esurfingdockerphone --load .
#docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
