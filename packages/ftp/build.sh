#!/bin/bash
#https://launchpad.net/ubuntu/+archive/primary/+files/netkit-ftp_0.17.orig.tar.gz
VERSION=0.17
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=ftp
DOWNLOAD_URL=https://launchpad.net/ubuntu/+archive/primary/+files/netkit-${NAME}_${VVERSION}.orig.$SUFFIX

. ../../env.sh

BUILD_DIR=$STAGING/netkit-$NAME-$VERSION
TARGET=$BUILD_DIR/$NAME
DEB=$BUILD_DIR/$NAME-${VERSION}_kbox4_${DEB_ARCH}.deb

if [ -f $DEB ]; then
  echo $DEB exists -- delete it to rebuild
  exit 0;
fi

if [ ! -d $BUILD_DIR ]; then 
  mkdir -p $STAGING/tarballs
  TARBALL=$STAGING/tarballs/$NAME-$VERSION.$SUFFIX
  if [ ! -f $TARBALL ]; then 
    echo "Downloading $VERSION"
    wget -O $TARBALL $DOWNLOAD_URL 
  else
    echo "Using cached $TARBALL"
  fi 
  mkdir -p $STAGING
  (cd $STAGING; tar xfvz $TARBALL)
else
  echo "Building cached $VERSION"
fi


echo Patching

patch $BUILD_DIR/ftp/ftp_var.h patch_ftp_var.h
patch $BUILD_DIR/ftp/cmds.c patch_cmds.c

echo Compiling

mkdir -p $BUILD_DIR/ftp/arpa/
cp /usr/include/arpa/ftp.h $BUILD_DIR/ftp/arpa/

(cd $BUILD_DIR/ftp; $CC -fpie -fpic -pie -I . -D__USE_READLINE__ -o ftp *.c -lreadline -lhistory -lncurses)

mkdir -p $BUILD_DIR/image/usr/bin
mkdir -p $BUILD_DIR/image/usr/share/man/man1
cp -p $BUILD_DIR/ftp/ftp $BUILD_DIR/image/usr/bin/
cp -p $BUILD_DIR/ftp/ftp.1 $BUILD_DIR/image/usr/share/man/man1/

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 


