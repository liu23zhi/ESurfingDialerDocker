FROM azul/zulu-openjdk:21-jdk-crac-latest
CMD ["exit"]
WORKDIR /app
COPY host.sh /app
COPY run.sh /app
COPY client.jar /app
RUN chmod -R 777 /app
CMD ["./run.sh"]
