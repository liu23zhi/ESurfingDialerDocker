FROM ubuntu
WORKDIR /app

COPY ./ubuntu-base/ /app/ubuntu-base/
COPY ./configuration-chroot.sh /app/configuration-chroot.sh
RUN chmod -R 777 /app/configuration-chroot.sh
RUN sudo /app/configuration-chroot.sh
RUN sudo chmod -R 777 /app/configuration-chroot.sh
CMD ["/app/configuration-chroot.sh"]
RUN chroot /app/ubuntu-base/ /app/chroot-install.sh
CMD ["sudo chroot /app/ubuntu-base/ /usr/bin/env DIALER_USER=$DIALER_USER DIALER_PASSWORD=$DIALER_PASSWORD /app/run.sh"]
# RUN chmod -R 777 /app/	
# RUN cd /app/ESurfingDialerClient/ && ./tyxy
# RUN apt-get update && apt-get install iproute2 -y
# RUN pip3 install netifaces
# RUN pip3 install psutil
# RUN apt install iputils-ping
CMD ["/app/run.sh"]
