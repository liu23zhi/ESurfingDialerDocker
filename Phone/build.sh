#!/bin/sh
docker build -t esurfingdockerphone .
docker save esurfingdockerphone:later -o ESurfingDockerPhone.tar.gz
