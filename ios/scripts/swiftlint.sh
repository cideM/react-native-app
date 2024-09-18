#!/bin/bash

# This script is a wrapper for SwiftLint. In order to execute this script
# SwiftLint must be installed via mint. In order to do so, install mint via
# > brew install mint
# and then install all mint dependencies via 
# > mint bootstrap
#
# Parameters
# -d true|false, default false
# Defines if SwiftLint should only be executed on the diff. Per default 
# SwiftLint is executed on all files. If true, SwiftLint will only be
# executed on stashed or unstashed changes.

# exit immediately if any line fails
set -e 
export PATH="$PATH:/opt/homebrew/bin"
# Parse script parameters
diffonly="false"
while getopts d: flag
do
    case "${flag}" in
        d) diffonly=${OPTARG};;
    esac
done
echo "diffonly: $diffonly";

# Ensure swiftlint is installed, and is installed via mint
if which mint > /dev/null; then
  unset SDKROOT
  SWIFTLINT="mint run SwiftLint"
else
  echo "error: mint is not installed. Please install it via brew install mint and run mint bootstrap to install all dependencies."
  exit 0
fi

cd ..
# print out the swiftlint version for debugging
$SWIFTLINT version

SWIFTLINT_CONFIG_FILE=$PWD/.swiftlint.yml

if [ "$diffonly" = "true" ]; then
  echo "fixing and linting only the diff"

  # the following few lines try to find changed files, 
  # so we skip linting for unchanged files and actually skip linting
  # alltogether if there are absolutely no files changed
  count=0
  # unstaged files
  while read filename; do 
    export SCRIPT_INPUT_FILE_$count="${filename}"
    count=$((count + 1))
  done < <(git diff --relative --name-only $SRCROOT | grep ".swift$")

  # staged files
  while read filename; do 
    export SCRIPT_INPUT_FILE_$count="${filename}"
    count=$((count + 1))
  done < <(git diff --relative --diff-filter=d --cached --name-only $SRCROOT | grep ".swift$")

  export SCRIPT_INPUT_FILE_COUNT=$count

  if (( $count > 0)); then
    echo "Found lintable files! Linting..."
    $SWIFTLINT --fix --use-script-input-files --config $SWIFTLINT_CONFIG_FILE
    $SWIFTLINT lint --use-script-input-files --config $SWIFTLINT_CONFIG_FILE
  else
      echo "No files to lint, the number of files found is $count"
      exit 0
  fi
else
  echo "fixing and linting all files"
  $SWIFTLINT --fix --config $SWIFTLINT_CONFIG_FILE
  $SWIFTLINT lint --config $SWIFTLINT_CONFIG_FILE 
fi
