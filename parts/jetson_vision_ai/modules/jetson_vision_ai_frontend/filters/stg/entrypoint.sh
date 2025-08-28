#!/bin/bash

/usr/sbin/sshd -D -p 2222&

exec su - great -c "/home/great/scripts/manage_application.sh"
