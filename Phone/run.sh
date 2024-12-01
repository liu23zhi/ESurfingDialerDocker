#!/bin/sh
echo "Asia/Shanghai" > /etc/timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
java -jar client.jar -u ${DIALER_USER} -p ${DIALER_PASSWORD}
