#!/bin/bash
#https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tgz

VERSION=3.4.3
VVERSION=$VERSION
SUFFIX=tgz
NAME=Python
DOWNLOAD_URL=http://www.python.org/ftp/python/$VERSION/${NAME}-${VVERSION}.$SUFFIX

. ../../env.sh

BUILD_DIR=$STAGING/${NAME}-$VERSION
TARGET=$BUILD_DIR/$NAME
DEB=$BUILD_DIR/$NAME-${VERSION}_kbox4_${DEB_ARCH}.deb

PATH=$NDK/bin:$PATH
export $PATH

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

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic -I${SYSROOT}/usr/include/ncurses -I${SYSROOT}/usr/include/openssl" CXXFLAGS="-fpie -fpic -I${SYSROOT}/usr/include/ncurses -I${SYSROOT}/usr/include/openssl" CPPFLAGS="-I${SYSROOT}/usr/include/ncurses -I${SYSROOT}/usr/include/openssl" LDFLAGS="-v -v -lm" ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ./configure ac_cv_file__dev_ptmx=yes ac_cv_file__dev_ptc=no LIBS=-lm --build=i686 --host=$CONFIG_FULLHOST --prefix=/usr --disable-ipv6)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi


patch $BUILD_DIR/Modules/posixmodule.c patch_posixmodule.c
patch $BUILD_DIR/Modules/pwdmodule.c patch_pwdmodule.c
patch $BUILD_DIR/Python/pythonrun.c patch_pythonrun.c

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi

# Sigh. We need to build the binary again, because it needs -pie whilst the SOs need
# -fPIC

rm $BUILD_DIR/python
mv $BUILD_DIR/Makefile $BUILD_DIR/Makefile.orig
sed -re 's/-v -v/-pie/' $BUILD_DIR/Makefile.orig > $BUILD_DIR/Makefile

#echo Building again with -pie flag

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



