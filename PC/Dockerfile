FROM ubuntu/python
WORKDIR /app
COPY ./ESurfingDialerClient/ /PC/ESurfingDialerClient/
RUN chmod -R +x /PC/ESurfingDialerClient/
COPY run.py /app
COPY run.sh /app
RUN cd /app/ESurfingDialerClient/ && ./tyxy
RUN apt-get update && apt-get install iproute2 -y
CMD ["./run.sh"]
