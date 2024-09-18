#!/bin/bash

# This script is a wrapper for Apollos codegeneration.
#
# Parameters
# -d true|false, default false
# If set to true, the script only run the code generation if if any 
# changed, unstashed .graphql files were found.

# exit immediately if any line fails
set -e 

# Parse script parameters
diffonly="false"
changedfiles=0
while getopts d: flag
do
    case "${flag}" in
        d) diffonly=${OPTARG};;
    esac
done
echo "diffonly: $diffonly";



if [ "$diffonly" = "true" ]; then
  echo "Checking if any .graphql files were changed"

  # the following few lines try to find changed files, 
  # so we skip linting for unchanged files and actually skip linting
  # alltogether if there are absolutely no files changed

  # unstaged files
  while read filename; do 
    changedfiles=$((changedfiles + 1))
  done < <(git diff --relative --name-only $SRCROOT | grep ".graphql\|API.*.swift")

  echo "${changedfiles} changed files found"
fi

if [[ $changedfiles > 0 || "$diffonly" = "false" ]]; then
  echo "Executing Apollo Script"

  SCRIPT_PATH="${BUILD_DIR%}/../../SourcePackages/checkouts/apollo-ios/scripts"
  cd "${SRCROOT}/Source"

  NODE_TLS_REJECT_UNAUTHORIZED=0 "${SCRIPT_PATH}"/run-bundled-codegen.sh codegen:generate --target=swift --includes=./**/Common/*.graphql --endpoint=https://www.labamboss.com/de/api/graphql Apollo/API.swift
  NODE_TLS_REJECT_UNAUTHORIZED=0 "${SCRIPT_PATH}"/run-bundled-codegen.sh codegen:generate --target=swift --includes=./**/US/*.graphql --endpoint=https://www.labamboss.com/us/api/graphql Apollo/API_US.swift
  NODE_TLS_REJECT_UNAUTHORIZED=0 "${SCRIPT_PATH}"/run-bundled-codegen.sh codegen:generate --target=swift --includes=./**/DE/*.graphql --endpoint=https://www.labamboss.com/de/api/graphql Apollo/API_DE.swift
else
  echo "No .graphql files were modified and are unstaged. Skipping Apollo script execution"
  exit 0
fi