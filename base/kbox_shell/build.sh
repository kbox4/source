#!/bin/bash

VERSION=kbox_shell-0.0.1

. ../../env.sh

BUILD_DIR=$STAGING/$VERSION
TARGET=$BUILD_DIR/kbox_shell

if [ -f $TARGET ]; then
  echo $TARGET exists -- delete it to rebuild
  exit 0;
fi

mkdir -p $BUILD_DIR
cp -pr src/* $BUILD_DIR

echo "Running make"
(cd $BUILD_DIR; make)
