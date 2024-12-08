FROM ghcr.io/graalvm/jdk-community:23.0.1
CMD ["exit"]
WORKDIR /app
COPY run.sh /app
COPY client.jar /app
RUN chmod -R 777 /app
CMD ["./run.sh"]
