#!/bin/bash

VISION_COMMON=/opt/vision-common

export LD_LIBRARY_PATH=$VISION_COMMON/lib:$LD_LIBRARY_PATH

export QT_QPA_PLATFORM=wayland
export QT_PLUGIN_PATH=/usr/lib/aarch64-linux-gnu/qt5/plugins
export QML2_IMPORT_PATH=/usr/lib/aarch64-linux-gnu/qt5/qml
export QML_IMPORT_PATH=/usr/lib/aarch64-linux-gnu/qt5/qml

exec "${@:-bash}"
