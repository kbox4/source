#!/bin/bash
#http://ftp.midnight-commander.org/mc-4.8.1.tar.xz
VERSION=4.8.1
VVERSION=$VERSION
SUFFIX=tar.bz2
NAME=mc
DOWNLOAD_URL=http://ftp.midnight-commander.org/${NAME}-4.8.1.tar.xz

. ../../env.sh

BUILD_DIR=$STAGING/$NAME-$VERSION
TARGET=$BUILD_DIR/$NAME
DEB=$BUILD_DIR/$NAME-${VERSION}_kbox4_${DEB_ARCH}.deb

#if [ -f skip ]; then
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
  (cd $STAGING; tar xfJ $TARBALL)
else
  echo "Building cached $VERSION"
fi

echo "Copying host files..."

mkdir -p $SYSROOT/usr/include/arpa/
cp /usr/include/arpa/ftp.h $SYSROOT/usr/include/arpa/

echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic -I$SYSROOT/usr/include/ncurses" LDFLAGS="-pie -s" LIBS="-lncurses" STRIP=$STRIP ./configure --host=$CONFIG_HOST --prefix=/usr --with-screen=ncurses)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

exit

echo "Patching"

patch $BUILD_DIR/src/filemanager/filegui.c patch_filegui.c
patch $BUILD_DIR/src/cons.handler.c patch_cons.handler.c
patch $BUILD_DIR/src/editor/editcmd.c patch_editcmd.c

#fi
#skip

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi

exit

echo "Running make install"

mkdir -p $BUILD_DIR/image/

(cd $BUILD_DIR; make CC=$CC DESTDIR=`pwd`/image install)

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



