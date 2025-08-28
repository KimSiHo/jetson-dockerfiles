#!/bin/bash

function sound() {
    play -n synth 1
}

trap 'sound' EXIT

# -----------------------------------------------------------------------------
# Environment Variable Prerequisites
#
#   Do not set the variables in this script. Instead put them into a script
#   ./parts/PART/conf/before_build.sh to keep your customizations separate.
#
#
#   ref. "docker run [OPTIONS] IMAGE [COMMAND] [ARG...]"
#
#
#   DOCKER_BUILD_OPTS      docker build 에 넘겨줄 OPTIONS.
#                        e.g.) export DOCKER_BUILD_OPTS="--network host --build-arg JDK=$JDK"
#
#   DOCKER_BUILD_ARGS      docker build 에 넘겨줄 COMMAND 와 ARG.
#                        e.g.) export DOCKER_BUILD_ARGS="/home/great/scripts/manage_application.sh start"
#
# -----------------------------------------------------------------------------

# Inner script가 exit 1로 에러 발생되면 즉시 build.sh 도 종료해야 함.
set -e

SCRIPT_BASE_PATH=$(pwd)
. "$SCRIPT_BASE_PATH/conf/env.sh"
. "$SCRIPT_BASE_PATH/scripts/arg_parser.sh"

# 빌드 옵션 로드, 빌드 전 작업 수행
if [ -e "$SCRIPT_BASE_PATH/parts/$PART/conf/before_build.sh" ]; then
    echo "$SCRIPT_BASE_PATH/parts/$PART/conf/before_build.sh exists."
    . "$SCRIPT_BASE_PATH/parts/$PART/conf/before_build.sh"
fi

BUILD_OPTS=""
if [ ! -z "$DOCKER_BUILD_OPTS" ] ; then
    BUILD_OPTS="$DOCKER_BUILD_OPTS"
fi

BUILD_ARGS=
if [ ! -z "$DOCKER_BUILD_ARGS" ] ; then
    BUILD_ARGS="$DOCKER_BUILD_ARGS"
fi

if [ "$IS_COMMON_PART" = true ] ; then
  BUILD_OPTS="$BUILD_OPTS \
  --network host"
  BUILD_ARGS="$BUILD_ARGS \
  --build-arg MODULE=$MODULE \
  --build-arg TAG=$TAG \
  "
else
  BUILD_OPTS="$BUILD_OPTS"
  BUILD_ARGS="$BUILD_ARGS \
  --build-arg PHASE=$PHASE \
  --build-arg MODULE=$MODULE \
  --build-arg TAG=$TAG
  "
fi

BUILD_OPTS_WITH_SPECIFIC_TAG="-t $DOCKER_IMAGE_URL $BUILD_OPTS"
BUILD_OPTS_WITH_LATEST_TAG="-t $DOCKER_LATEST_IMAGE_URL $BUILD_OPTS"

docker run --rm --privileged tonistiigi/binfmt --install all

echo "
=== build command start ===
docker buildx build --platform linux/arm64 --load $BUILD_OPTS_WITH_SPECIFIC_TAG $BUILD_ARGS -f $DOCKERFILE $DOCKER_FILE_HOME
=== build command end ===
"
docker buildx build --platform linux/arm64 --load $BUILD_OPTS_WITH_SPECIFIC_TAG $BUILD_ARGS -f $DOCKERFILE $DOCKER_FILE_HOME

if [ ! -z "${DOCKER_LATEST_IMAGE_URL}" ] ; then
  echo "
=== latest tag build command start ===
docker buildx build --platform linux/arm64 --load $BUILD_OPTS_WITH_LATEST_TAG $BUILD_ARGS -f $DOCKERFILE $DOCKER_FILE_HOME
=== latest tag build command end ===
"
  docker buildx build --platform linux/arm64 --load $BUILD_OPTS_WITH_LATEST_TAG $BUILD_ARGS -f $DOCKERFILE $DOCKER_FILE_HOME
fi

if [ -e "$SCRIPT_BASE_PATH/parts/$PART/conf/after_build.sh" ]; then
    echo "$SCRIPT_BASE_PATH/parts/$PART/conf/after_build.sh exists."
    . "$SCRIPT_BASE_PATH/parts/$PART/conf/after_build.sh"
fi
