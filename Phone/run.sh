#!/bin/sh
nohup ./host.sh &
java -jar client.jar -u ${DIALER_USER} -p ${DIALER_PASSWORD}
