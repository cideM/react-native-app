#!/bin/sh

export PATH="$PATH:/opt/homebrew/bin"
if which mint > /dev/null && ([ -d /usr/local/Cellar/libxml2 ] || [ -f /usr/lib/libxml2.dylib ] || [ -d /opt/homebrew/opt/libxml2 ]); then
  unset SDKROOT
  YML="${SRCROOT}/Configs/swiftgen.yml"
  echo $YML
  cd ..
  SWIFTGEN="mint run SwiftGen"
else
  echo "error: mint is not installed. Please install it via brew install mint and run mint bootstrap to install all dependencies. Also please make sure you install libxml2.dylib first with using brew like this: brew install libxml2."  
  exit 0
fi

mint run SwiftGen --version
mint run SwiftGen config run --config $YML
