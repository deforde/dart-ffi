#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath ${0%/*})
cd $SCRIPT_DIR

if [[ ! -f dart_2.19.5-1_amd64.deb ]]; then
    curl -LO https://storage.googleapis.com/dart-archive/channels/stable/release/latest/linux_packages/dart_2.19.5-1_amd64.deb
    sudo dpkg -i dart_2.19.5-1_amd64.deb
fi

make -C native
dart main.dart
