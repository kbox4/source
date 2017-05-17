#!/bin/bash
#https://www.nano-editor.org/dist/v2.8/nano-2.8.2.tar.xz

VERSION=2.8.2
VVERSION=$VERSION
SUFFIX=tar.xz
NAME=nano
DOWNLOAD_URL=https://www.nano-editor.org/dist/v2.8/$NAME-$VVERSION.$SUFFIX

. ../../env.sh

BUILD_DIR=$STAGING/$NAME-$VERSION
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
  (cd $STAGING; tar xfvJ $TARBALL)
else
  echo "Building cached $VERSION"
fi

echo Patching Configure...

patch $BUILD_DIR/configure patch_configure

echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic -I${SYSROOT}/usr/include/ncurses" CPPLAGS="-I${SYSROOT}/usr/include/ncurses" CXXFLAGS="-fpie -fpic -I${SYSROOT}/usr/include/ncurses" LDFLAGS="-pie -s" ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ./configure --host=$CONFIG_HOST --prefix=/usr --enable-widec=no)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

echo Patching after Configure...

patch $BUILD_DIR/config.h patch_config.h

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi

mkdir -p $BUILD_DIR/image/

echo "Running make install"
(cd $BUILD_DIR; make DESTDIR=`pwd`/image install)

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



