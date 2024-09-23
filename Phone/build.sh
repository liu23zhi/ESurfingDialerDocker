#!/bin/sh
docker build -t esurfingdockerphone .
docker save esurfingdockerphone -o ESurfingDockerPhone.tar.gz
