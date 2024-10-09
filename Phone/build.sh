#!/bin/sh
#cd./Phone
docker build -t ${{ env.Amd_Phone_Docker_Local_Name }} .
#docker save esurfingdockerphoneamd64 -o./ESurfingDockerPhone.tar.gz