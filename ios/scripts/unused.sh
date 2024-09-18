#!/bin/bash

# This script is a wrapper for the unused.rb
# script with some parameters already configured

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ruby $SCRIPT_DIR/unused.rb xcode --ignore API.swift