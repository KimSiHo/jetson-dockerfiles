#!/bin/bash

DS=/opt/nvidia/deepstream/deepstream
VISION_COMMON=/opt/vision-common

export GST_PLUGIN_PATH=$DS/lib/gst-plugins:$GST_PLUGIN_PATH
export LD_LIBRARY_PATH=$VISION_COMMON/lib:$DS/lib:$DS/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
export GST_PLUGIN_PATH_1_0=$GST_PLUGIN_PATH

exec "${@:-bash}"
