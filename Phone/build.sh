#!/bin/sh
#cd./Phone
docker build -t esurfingdockerphone .
docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
