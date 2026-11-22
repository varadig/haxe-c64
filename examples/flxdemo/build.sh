#!/usr/bin/env bash
# flixel64 demo: ./build.sh [--run]
cd "$(dirname "$0")" && ../../bin/haxe64 -cp src -main Main -o build/flxdemo.prg "$@"
