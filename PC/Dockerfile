FROM ubuntu
WORKDIR /app

COPY ./ubuntu-base/ /app/ubuntu-base/
COPY ./configuration-chroot.sh /app/configuration-chroot.sh
# 安装软件包
RUN apt update
RUN apt install -y sudo inotify-tools

COPY ./sync_files_for_chroot.sh /app/
RUN sudo chmod -R 777 /app/sync_files_for_chroot.sh
RUN sudo chmod -R 777 /app/configuration-chroot.sh
RUN sudo /app/configuration-chroot.sh
COPY ./chroot-install.sh /app/
RUN sudo chroot /app/ubuntu-base/ "/app/chroot-install.sh"
# CMD [ "echo "export DIALER_USER=$DIALER_USER" > /app/ubuntu-base/app/env_vars.sh" ]
# CMD [ "echo "export DIALER_PASSWORD=$DIALER_PASSWORD" >> /app/ubuntu-base/app/env_vars.sh" ]
# CMD [ "chmod +x /app/ubuntu-base/app/env_vars.sh" ]

# CMD ["sudo chroot /app/ubuntu-base/ /app/env_vars.sh  && cd /app/ESurfingDialerClient/ && /app/run.sh"]
# CMD ["/app/configuration-chroot.sh"]
# CMD ["sudo", "chroot", "/app/ubuntu-base/", "sh", "-c", "export DIALER_USER=$DIALER_USER && export DIALER_PASSWORD=$DIALER_PASSWORD && cd /app/ESurfingDialerClient/ && exec /app/run.sh"]

CMD ["sh", "-c", "/app/configuration-chroot.sh true"]


# RUN chmod -R 777 /app/	
# RUN cd /app/ESurfingDialerClient/ && ./tyxy
# RUN apt-get update && apt-get install iproute2 -y
# RUN pip3 install netifaces
# RUN pip3 install psutil
# RUN apt install iputils-ping
#旧版参数
#CMD ["/app/run.sh"]
