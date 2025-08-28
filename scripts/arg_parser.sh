#!/bin/bash

usage="[ERROR] Bad Argument
Usage: ./$(basename "$0") MANDATORY [OPTIONAL]
MANDATORY
    --part          part
    -m|--module     module
    -p|--phase      build phase(common PART에서만 optional)
OPTIONAL
    -t|--tag        docker image tag. YYYYMMDD로 표기. 'time' 사용 시 당일로, 미기재시 'latest'로 변환.
"

echo "===Parse arguments start==="
# parse args
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --part)
    PART="$2"
    shift 2
    ;;
    -p|--phase)
    PHASE="$2"
    shift 2
    ;;
    -m|--module)
    MODULE="$2"
    shift 2
    ;;
    -t|--tag)
    TAG="$2"
    shift 2
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac

done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z "$PART" ] || [ -z "$MODULE" ]; then
    echo "$usage"
    exit 1
fi

# process part
echo "* Parse argument - \$PART"
if [[ " ${PART_LIST[@]} " =~ " $PART " ]]; then
  echo "part param ok [$PART]"
else
  echo "[ERROR] unknown part! [$PART] / available part list : [${PART_LIST[*]}]"
  exit 1
fi
. "$SCRIPT_BASE_PATH/parts/$PART/conf/env.sh"

# process phase
echo "* Parse argument - \$PHASE"
if [ "$IS_COMMON_PART" = false ] ; then
  if [ -z "$PHASE" ]; then
      echo "$usage"
      exit 1
  fi

  if [[ " ${PHASE_LIST[@]} " =~ " $PHASE " ]]; then
    echo "phase param ok [$PHASE]"
  else
    echo "[ERROR] unknown phase! [$PHASE] / available phase list : [${PHASE_LIST[*]}]"
    exit 1
  fi
else
  echo "IS_COMMON_PART : $IS_COMMON_PART"
fi

# process module
echo "* Parse argument - \$MODULE"
declare -a MODULE_LIST=($(ls $SCRIPT_BASE_PATH/parts/$PART/modules))
if [[ " ${MODULE_LIST[@]} " =~ " $MODULE " ]]; then
  echo "module param ok [$MODULE]"
else
  echo "[ERROR] unknown module! [$MODULE] / available module list : [${MODULE_LIST[*]}]"
  exit 1
fi

# process tag
echo "* Parse argument - \$TAG"
if [ -z $TAG ]
then
  if [ "${NOT_ALLOWED_USING_LATEST_TAG}" == true ]; then
    echo "[ERROR] tag must be specified!"
    exit 1
  fi

  TAG='latest'
elif [ $TAG = 'time' ]
then
  TAG=$(date +%Y%m%d)
fi
echo "tag param ok [$TAG]"

echo "===summary==="
echo "PART : $PART"
if [ "$IS_COMMON_PART" = false ] ; then
  echo "PHASE : $PHASE"
else
  echo "IS_COMMON_PART : $IS_COMMON_PART"
fi
echo "MODULE : $MODULE"
echo "TAG : $TAG"
echo "===Parse arguments end==="

echo ""
echo "* Prepare environment start"

# docker image url
if [ "$IS_COMMON_PART" = true ] ; then
  REPOSITORY_NAME="$MODULE"
else
  REPOSITORY_NAME="$MODULE/$PHASE"
fi

DOCKER_FILE_HOME="$SCRIPT_BASE_PATH/parts/$PART/modules/$MODULE"
DOCKER_IMAGE_URL="$REPOSITORY_NAME:$TAG"
if [ "${NOT_ALLOWED_USING_LATEST_TAG}" != true ]; then
  DOCKER_LATEST_IMAGE_URL="$REPOSITORY_NAME:latest"
fi
# PHASE 기반 Dockerfile 있으면 사용 없으면 PHASE 공용 기본 도커 파일
if [ -n "$PHASE" ] && [ -f "$DOCKER_FILE_HOME/Dockerfile.$PHASE" ]; then
  DOCKERFILE="$DOCKER_FILE_HOME/Dockerfile.$PHASE"
else
  DOCKERFILE="$DOCKER_FILE_HOME/Dockerfile"
fi

echo "REPOSITORY_NAME : $REPOSITORY_NAME"
echo "DOCKER_FILE_HOME : $DOCKER_FILE_HOME"
echo "DOCKER_IMAGE_URL : $DOCKER_IMAGE_URL"
echo "DOCKERFILE : $DOCKERFILE"
[[ ! -z "${DOCKER_LATEST_IMAGE_URL}" ]] && echo "DOCKER_LATEST_IMAGE_URL : ${DOCKER_LATEST_IMAGE_URL}"

echo "* Prepare environment end"
echo ""
