#!/bin/bash
#http://lftp.yar.ru/ftp/lftp-4.7.7.tar.gz

VERSION=4.6.0
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=lftp
DOWNLOAD_URL=http://lftp.yar.ru/ftp/$NAME-$VVERSION.$SUFFIX

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
  (cd $STAGING; tar xfvz $TARBALL)
else
  echo "Building cached $VERSION"
fi

echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic -I${SYSROOT}/usr/include/ncurses" CXXFLAGS="-fpie -fpic -I${SYSROOT}/usr/include/ncurses" LDFLAGS="-pie -s" LIBS=-lncurses ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ./configure --host=$CONFIG_FULLHOST --prefix=/usr --without-gnutls --with-openssl --with-readline-inc=${SYSROOT}/usr/include/readline)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

echo "Patching"

patch $BUILD_DIR/src/Resolver.cc patch_Resolver.cc
patch $BUILD_DIR/lib/config.h patch_config.h
patch $BUILD_DIR/src/nl_langinfo.c patch_nl_langinfo.c

echo "Running make"

(cd $BUILD_DIR; make CC=$CC CXX=$CXX CFLAGS="-fpie -fpic -I/usr/include/ncurses")

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



