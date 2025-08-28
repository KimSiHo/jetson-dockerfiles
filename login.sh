#!/bin/bash

SCRIPT_BASE_PATH=$(pwd)
. "$SCRIPT_BASE_PATH/conf/credential.env"

GCHR_USER="$GCHR_USER"
GCHR_PASSWORD="$GCHR_PASSWORD"

echo "execute : docker login ghcr.io -u $GCHR_USER --password-stdin"
echo "$GCHR_PASSWORD" | docker login ghcr.io -u $GCHR_USER --password-stdin
