#FROM ubuntu
FROM python:latest
WORKDIR /app

# COPY ./ubuntu-base/ /app/ubuntu-base/
# COPY ./configuration-chroot.sh /app/configuration-chroot.sh
# # 安装软件包
# RUN apt update
# RUN apt install -y sudo inotify-tools

# COPY ./sync_files_for_chroot.sh /app/
# RUN sudo chmod -R 777 /app/sync_files_for_chroot.sh
# RUN sudo chmod -R 777 /app/configuration-chroot.sh
# RUN sudo /app/configuration-chroot.sh
# # #修正莫名其妙的文件丢失问题
# # COPY ./chroot-install.sh /app/ubuntu-base/app/
# # RUN chmod -R 777 /app/ubuntu-base/app//chroot-install.sh


# RUN sudo chroot /app/ubuntu-base/ "/app/chroot-install.sh"
# # CMD [ "echo "export DIALER_USER=$DIALER_USER" > /app/ubuntu-base/app/env_vars.sh" ]
# # CMD [ "echo "export DIALER_PASSWORD=$DIALER_PASSWORD" >> /app/ubuntu-base/app/env_vars.sh" ]
# # CMD [ "chmod +x /app/ubuntu-base/app/env_vars.sh" ]

# # CMD ["sudo chroot /app/ubuntu-base/ /app/env_vars.sh  && cd /app/ESurfingDialerClient/ && /app/run.sh"]
# # CMD ["/app/configuration-chroot.sh"]
# # CMD ["sudo", "chroot", "/app/ubuntu-base/", "sh", "-c", "export DIALER_USER=$DIALER_USER && export DIALER_PASSWORD=$DIALER_PASSWORD && cd /app/ESurfingDialerClient/ && exec /app/run.sh"]

# CMD ["sh", "-c", "/app/configuration-chroot.sh true"]


# X86 架构可以直接运行
RUN apt update && apt install -y python3 python3-dev python3-pip sudo python3-full
# 安装python3-venv包
RUN sudo apt install python3-venv
# 创建一个新的虚拟环境
#RUN python3 -m venv myenv
# 激活虚拟环境
#RUN source myenv/bin/activatr

COPY ./ESurfingDialerClient/ /app/ESurfingDialerClient/
# 奇奇怪怪的文件夹复制BUG
COPY ./run.py /app/ESurfingDialerClient/
COPY ./run.sh /app/
RUN chmod -R 777 /app/	
RUN ls -l /
RUN ls -l /app/
RUN ls -l /app/ESurfingDialerClient/
RUN cd /app/ESurfingDialerClient/ && ./tyxy
RUN apt-get update && apt-get install iproute2 -y
RUN pip3 install netifaces
RUN pip3 install psutil
RUN apt install iputils-ping
# 旧版参数
CMD ["/app/run.sh"]
