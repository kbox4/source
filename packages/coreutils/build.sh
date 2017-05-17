#!/bin/bash
#https://ftp.gnu.org/gnu/coreutils/coreutils-8.27.tar.xz

VERSION=8.27
VVERSION=$VERSION
SUFFIX=tar.xz
NAME=coreutils
DOWNLOAD_URL=https://ftp.gnu.org/gnu/coreutils/$NAME-$VVERSION.$SUFFIX

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


echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-std=c99 -fpie -fpic" CXXFLAGS="-fpie -fpic" LDFLAGS="-pie" ./configure --host=$CONFIG_HOST --prefix=/usr --with-readline)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

echo "Patching"

patch $BUILD_DIR/src/pinky.c patch_pinky.c
patch $BUILD_DIR/src/dd.c patch_dd.c
patch $BUILD_DIR/src/shred.c patch_shred.c

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

# Sigh -- ignore errors :/

mkdir -p $BUILD_DIR/image/bin
mkdir -p $BUILD_DIR/image/usr/share/man/man1

COMMANDS=(chroot df nice pinky stdbuf stty timeout users who b2sum base64 base32 basename cat chcon chgrp chmod chown cksum comm cp csplit cut date dd dir dircolors dirname du echo env expand expr factor false fmt fold ginstall groups head id join kill link logname ls md5sum mkdir mkfifo mknod mktemp mv nl nproc nohup numfmt od paste pathchk pr printenv printf ptx pwd readlink realpath rmdir runcon seq sha1sum sha224sum sha256sum sha384sum sha512sum shred shuf sleep sort split stat sum sync tac tail tee test touch tr true truncate tsort tty uname unexpand uniq unlink vdir wc whoami test touch tr true truncate tsort tty uname unexpand uniq unlink vdir wc whoami yes)

for i in ${!COMMANDS[*]} ; do
  command=${COMMANDS[$i]}
  $STRIP $BUILD_DIR/src/$command
  cp -p $BUILD_DIR/src/$command $BUILD_DIR/image/bin/
  help2man $command > $BUILD_DIR/image/usr/share/man/man1/$command.1
done

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



