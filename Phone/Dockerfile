FROM azul/zulu-openjdk:23-latest
CMD ["exit"]
WORKDIR /app
COPY run.sh /app
COPY client.jar /app
RUN chmod -R 777 /app
CMD ["./run.sh"]
