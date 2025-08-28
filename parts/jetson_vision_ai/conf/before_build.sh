#!/bin/bash

if [ -e "$SCRIPT_BASE_PATH/parts/$PART/modules/$MODULE/before_build.sh" ]; then
  echo "$SCRIPT_BASE_PATH/parts/$PART/modules/$MODULE/before_build.sh exists."
  . "$SCRIPT_BASE_PATH/parts/$PART/modules/$MODULE/before_build.sh"
fi
