#!/bin/bash

# Domain & IP
DOMAIN="enet.10000.gd.cn"
IP1="125.88.59.131"
IP2="61.140.12.23"

# check IP function
check_ip() {
    ping -c 1 $1 &> /dev/null
    return $?
}

# update hosts function
update_hosts() {
    echo "$1 $DOMAIN" | tee -a /etc/hosts > /dev/null
}

# infinity check
while true; do
    # check IP1
    if check_ip $IP1; then
	{
	    echo "$(sed '/^$IP1 $DOMAIN/d' /etc/hosts)" > /etc/hosts.tmp && mv /etc/hosts.tmp /etc/hosts
	    echo "$(sed '/^$IP2 $DOMAIN/d' /etc/hosts)" > /etc/hosts.tmp && mv /etc/hosts.tmp /etc/hosts
            PRIMARY_IP=$IP1
	    update_hosts "$PRIMARY_IP"
	}
    else
	{
	    echo "$(sed '/^$IP1 $DOMAIN/d' /etc/hosts)" > /etc/hosts.tmp && mv /etc/hosts.tmp /etc/hosts
            echo "$(sed '/^$IP2 $DOMAIN/d' /etc/hosts)" > /etc/hosts.tmp && mv /etc/hosts.tmp /etc/hosts
	    PRIMARY_IP=$IP2
	    update_hosts "$PRIMARY_IP"
	}
    fi

    # check every 10 seconds
    sleep 10
done
