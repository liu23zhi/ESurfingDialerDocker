#!/bin/bash

chmod +x ./Oracle-Docker-images/OracleJava/21/build.sh
cd ./Oracle-Docker-images/OracleJava/21/
#docker build --file Dockerfile.ol9 --tag oracle/jdk:21-ol9 .
docker buildx build --platform linux/amd64 --file Dockerfile.ol9 --tag oracle/jdk:21-ol9  --load .
#./build.sh 9
