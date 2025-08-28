#!/bin/bash

GIT_REF=$(python3 $SCRIPT_BASE_PATH/scripts/get_latest_git_ref.py vision-common)
echo "GIT_REF: $GIT_REF"

DOCKER_BUILD_ARGS="
$DOCKER_BUILD_ARGS
--build-arg GIT_REF=$GIT_REF
"
