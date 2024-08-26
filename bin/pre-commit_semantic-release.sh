#!/bin/sh

###############################################################################
# (A) Update app version with `${nextRelease.version}`
###############################################################################
sed -i -e "s_^\(set(VERSION\s\+\"\).*\(\")\)\$_\1${1}\2_" CMakeLists.txt
sed -i -e "s_^\(\s\+readonly property var appVersion: \"\).*\(\"\)\$_\1${1}\2_" src/app/qml/main.qml
