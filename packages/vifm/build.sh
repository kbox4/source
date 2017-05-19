#!/bin/bash
#http://prdownloads.sourceforge.net/vifm/vifm-0.8.2.tar.bz2?download
VERSION=0.8.2
VVERSION=$VERSION
SUFFIX=tar.bz2
NAME=vifm
DOWNLOAD_URL=http://prdownloads.sourceforge.net/${NAME}/${NAME}-${VERSION}.tar.bz2?download

. ../../env.sh


BUILD_DIR=$STAGING/$NAME-$VERSION
TARGET=$BUILD_DIR/$NAME
DEB=$BUILD_DIR/$NAME-${VERSION}_kbox4_${DEB_ARCH}.deb

#if [ -f sod ]; then
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
  (cd $STAGING; tar xfj $TARBALL)
else
  echo "Building cached $VERSION"
fi


echo Patching Configure...

patch $BUILD_DIR/configure patch_configure

echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic" LDFLAGS="-pie -s" LIBS="-lncurses" STRIP=$STRIP ./configure --host=$CONFIG_HOST --prefix=/usr --with-gtk=no)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

echo "Patching"

#patch $BUILD_DIR/src/cmd_completion.c patch_cmd_completion.c
#patch $BUILD_DIR/src/utils/utils_nix.c patch_utils_nix.c

exit

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi

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



