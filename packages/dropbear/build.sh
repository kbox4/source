#!/bin/bash

VNUM=2016.74
VERSION=dropbear-$VNUM

. ../../env.sh

BUILD_DIR=$STAGING/$VERSION
TARGET=$BUILD_DIR/dbclient
CLIENT_DEB=$BUILD_DIR/sshclient_kbox4_${DEB_ARCH}.deb

if [ -f $CLIENT_DEB ]; then
  echo $CLIENT_DEB exists -- delete it to rebuild
  exit 0;
fi

if [ ! -d $BUILD_DIR ]; then 
  mkdir -p $STAGING/tarballs
  TARBALL=$STAGING/tarballs/$VERSION.tar.bz2
  if [ ! -f $TARBALL ]; then 
    echo "Downloading $VERSION"
    wget -O $TARBALL https://matt.ucc.asn.au/dropbear/releases/${VERSION}.tar.bz2
  else
    echo "Using cached $TARBALL"
  fi 
  mkdir -p $STAGING
  (cd $STAGING; tar xfvj $TARBALL)
else
  echo "Building cached $VERSION"
fi

echo Running configure...

(cd $BUILD_DIR; CC=$CC CFLAGS="-fpie -fpic" LDFLAGS="-pie" ./configure --host $CONFIG_HOST) 

echo "Patching source"
patch -R $BUILD_DIR/config.h patch_config.h
patch -R $BUILD_DIR/loginrec.c patch_loginrec.c
patch  $BUILD_DIR/cli-auth.c patch_cli_auth.c

#echo "Running make"
(cd $BUILD_DIR; make)

if [[ $? -ne 0 ]] ; then
    echo make failed ... stopping
    exit 1
fi

sed -e s/%ARCH%/$DEB_ARCH/ control > $BUILD_DIR/control

mkdir -p $BUILD_DIR/out
mkdir -p $BUILD_DIR/image/usr/bin
mkdir -p $BUILD_DIR/image/usr/share/man/man1
cp -p $TARGET $BUILD_DIR/image/usr/bin/
$STRIP $BUILD_DIR/image/usr/bin/dbclient
cp $BUILD_DIR/dbclient.1 $BUILD_DIR/image/usr/share/man/man1/ssh.1
cp $BUILD_DIR/dbclient.1 $BUILD_DIR/image/usr/share/man/man1/dbclient.1
cp $BUILD_DIR/dbclient $BUILD_DIR/image/usr/bin/
(cd $BUILD_DIR/image/usr/bin; ln -sf dbclient ssh)
(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $CLIENT_DEB
ar rcs $CLIENT_DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $CLIENT_DEB $DIST/ 

