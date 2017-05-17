#!/bin/bash
#ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2

VERSION=7.4
VVERSION=$VERSION
SUFFIX=tar.bz2
NAME=vim
DOWNLOAD_URL=ftp://ftp.vim.org/pub/vim/unix/$NAME-$VVERSION.$SUFFIX

. ../../env.sh

BUILD_DIR=$STAGING/${NAME}74
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
  (cd $STAGING; tar xfvj $TARBALL)
else
  echo "Building cached $VERSION"
fi

echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic -fPIC" CPPFLAGS="-fpie -fpic -fPIC" LDFLAGS="-pie" vim_cv_toupper_broken=false vim_cv_terminfo=yes vim_cv_tty_group=world vim_cv_getcwd_broken=no vim_cv_stat_ignores_slash=no vim_cv_memmove_handles_overlap=no vim_cv_bcopy_handles_overlap=no vim_cv_memcpy_handles_overlap=no ./configure --host $CONFIG_HOST --prefix /usr  --with-tlib=ncurses)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

echo Patching source
patch $BUILD_DIR/src/mbyte.c patch_mbyte.c

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi

mkdir -p $BUILD_DIR/image/

echo "Running make install"
(cd $BUILD_DIR; make DESTDIR=`pwd`/image STRIP=$STRIP install)

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



