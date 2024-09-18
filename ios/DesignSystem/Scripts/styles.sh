#!/bin/sh

# Argument "directory" is required
DIR=$1
if [ -z "$DIR" ]
then
  echo "Output <directory> required"
  exit 1
fi

# Argument "classname" is required
CLASS=$2
if [ -z "$CLASS" ]
then
  echo "Output <classname> required"
  exit 1
fi

# This can be run directly via terminal or via xcode target
# But special handling for the tmp directory is required ...
TMP=$TEMP_DIR # $TEMP_DIR will be empty when not running the script via xcode
if [ -z "$TMP" ]
then
  TMP=$TMPDIR # Use the bash tmp directory instead
else
  TMP=$TEMP_DIR"/" # Bash's tmp dir has a trailing slash, which is missing in xcode
fi

# Path shorthands ...
SWIFT=$CLASS".swift"
TARGET=$DIR$SWIFT
echo "Target:" $TARGET
echo "Temp:" $TMP

SOURCE=$TMP"amboss-design-system/build-tokens/ios/Tokens.swift" # Source tokens file

printf "🐙 Cloning design spec repository ...\n\n"
cd $TMP
rm -rf $TMP/amboss-design-system
git clone "git@github.com:amboss-mededu/amboss-design-system.git" -b mobile-ds-exp --depth 1
printf "\n"
yes | cp $SOURCE $TARGET
printf "\n\n🏁 Finished updating design files at:\n$TARGET"
open $TARGET
