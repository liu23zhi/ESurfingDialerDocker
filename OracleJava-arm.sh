#!/bin/bash

cd ./Oracle-Docker-images/OracleJava/23/
chmod +x ./build.sh
# ./build.sh
#docker build --file Dockerfile --tag oracle/jdk:23-ol9 .
docker buildx build --platform linux/arm64 --file Dockerfile --tag oracle/jdk:23-ol9  --load .
