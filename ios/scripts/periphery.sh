#!/bin/bash

if which periphery > /dev/null; then
  PERIPHERY="periphery"
else
  echo "error: periphery is not installed. Please refer to https://github.com/peripheryapp/periphery#installation for installation instructions"
  exit 0
fi

PERIPHERY scan