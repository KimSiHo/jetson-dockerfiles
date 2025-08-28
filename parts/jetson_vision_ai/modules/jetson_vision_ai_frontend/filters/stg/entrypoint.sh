#!/bin/bash

mkdir -p /run/sshd
/usr/sbin/sshd -D &

mkdir -p /var/log/vision
chown great:great /var/log/vision

exec su -s /bin/bash great -c "/home/great/scripts/manage_application.sh"
