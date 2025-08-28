#!/bin/bash

mkdir -p /var/log/vision
chown great:great /var/log/vision

exec su -s /bin/bash great -c "/home/great/scripts/manage_application.sh"
