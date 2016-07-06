#! /bin/bash

BUILD_CMD="xcodebuild -scheme Watchdog -sdk iphonesimulator build"

which -s xcpretty
XCPRETTY_INSTALLED=$?

if [[ $TRAVIS || $XCPRETTY_INSTALLED == 0 ]]; then
  eval "${BUILD_CMD} | xcpretty"
else
  eval "$BUILD_CMD"
fi
