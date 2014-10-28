@echo off

rm -rf build

::pub build
::"../dart-sdk/bin/pub" upgrade
"../dart-sdk/bin/pub" build
