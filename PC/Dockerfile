FROM python
WORKDIR /app
COPY run.py /app/
COPY run.sh /app/run.sh
COPY ./ESurfingDialerClient/ /app/ESurfingDialerClient/
RUN chmod -R 777 /app/	
RUN cd /app/ESurfingDialerClient/ && ./tyxy
RUN apt-get update && apt-get install iproute2 -y
CMD ["/app/run.sh"]
