FROM oracle/jdk:21-ol9
CMD ["exit"]
WORKDIR /app
COPY run.sh /app
COPY client.jar /app
RUN chmod -R 777.
CMD ["./run.sh"]
