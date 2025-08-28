#!/bin/bash

# -----------------------------------------------------------------------------
# Environment Variable Prerequisites
#
#   Do not set the variables in this script. Instead put them into a script
#   ./parts/PART/conf/before_run.sh to keep your customizations separate.
#
#
#   ref. "docker run [OPTIONS] IMAGE [COMMAND] [ARG...]"
#
#
#   DOCKER_RUN_OPTS      docker run 에 넘겨줄 OPTIONS.
#                        e.g.) export DOCKER_RUN_OPTS="--network host -v /host/mnt:/container/mnt --env VAR=val"
#
#   DOCKER_RUN_ARGS      docker run 에 넘겨줄 COMMAND 와 ARG.
#                        e.g.) export DOCKER_RUN_ARGS="/home1/irteam/scripts/manage_application.sh start"
#   
# -----------------------------------------------------------------------------

# to check errors in before_run.sh
set -e

SCRIPT_BASE_PATH=$(pwd)
. "$SCRIPT_BASE_PATH/conf/env.sh"
. "$SCRIPT_BASE_PATH/scripts/arg_parser.sh"

echo "=== start before_run.sh"
if [ -e "$SCRIPT_BASE_PATH/parts/$PART/conf/before_run.sh" ]; then
    echo "$SCRIPT_BASE_PATH/parts/$PART/conf/before_run.sh exists."
    . "$SCRIPT_BASE_PATH/parts/$PART/conf/before_run.sh"
fi
echo "=== finish before_run.sh"
set +e

# 컨테이너 종료
echo "=== stop previous container"
docker stop $MODULE
docker rm $MODULE
docker system prune -f

RUN_OPTS=
if [ ! -z "$DOCKER_RUN_OPTS" ] ; then
    RUN_OPTS="$RUN_OPTS $DOCKER_RUN_OPTS"
fi
RUN_OPTS="$RUN_OPTS --name $MODULE $DOCKER_IMAGE_URL"

RUN_ARGS=
if [ ! -z "$DOCKER_RUN_ARGS" ] ; then
    RUN_ARGS="$DOCKER_RUN_ARGS"
fi

echo "
=== run command start ===
docker run $RUN_OPTS $RUN_ARGS
=== run command end ===
"
docker run $RUN_OPTS $RUN_ARGS
sleep 3

docker ps -a

if [ -e "$SCRIPT_BASE_PATH/parts/$PART/conf/after_run.sh" ]; then
    echo "$SCRIPT_BASE_PATH/parts/$PART/conf/after_run.sh exists."
    . "$SCRIPT_BASE_PATH/parts/$PART/conf/after_run.sh"
fi
