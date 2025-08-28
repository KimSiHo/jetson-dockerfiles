#!/bin/bash

DS=/opt/nvidia/deepstream/deepstream
VISION_COMMON=/opt/vision-common

export LD_LIBRARY_PATH=$VISION_COMMON/lib:$DS/lib:$DS/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH

export QT_QPA_PLATFORM=wayland
export QT_PLUGIN_PATH=/usr/lib/aarch64-linux-gnu/qt5/plugins
export QML2_IMPORT_PATH=/usr/lib/aarch64-linux-gnu/qt5/qml
export QML_IMPORT_PATH=/usr/lib/aarch64-linux-gnu/qt5/qml

export GST_PLUGIN_PATH=$DS/lib/gst-plugins:$GST_PLUGIN_PATH
export GST_PLUGIN_PATH_1_0=$GST_PLUGIN_PATH

export XDG_RUNTIME_DIR=/tmp

export SPDLOG_LEVEL=info

exec /usr/bin/tail -f /dev/null
