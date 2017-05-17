. ../../env.sh

VERSION=0.0.1
NAME=java-support
BUILD_DIR=$STAGING/$NAME-$VERSION

DX=$ANDROID_SDK/build-tools/19.0.1/dx
ANDROIDJAR=$ANDROID_SDK/platforms/android-10/android.jar

DEB=$BUILD_DIR/$NAME-${VERSION}_kbox4_${DEB_ARCH}.deb

mkdir -p $BUILD_DIR/target/tools
mkdir -p $BUILD_DIR/target/dx

if [ -f sodit ] ; then

javac -target 1.6 -source 1.6  -d $BUILD_DIR/target/tools  src/com/sun/tools/javac/*.java src/com/sun/tools/javac/main/*.java src/com/sun/tools/javac/util/*.java src/com/sun/tools/javac/code/*.java src/com/sun/tools/javac/jvm/*.java src/com/sun/tools/javac/processing/*.java src/com/sun/source/util/*.java src/com/sun/tools/javac/tree/*.java src/com/sun/tools/javac/file/*.java src/com/sun/tools/javac/parser/*.java src/com/sun/tools/javac/comp/*.java src/com/sun/tools/javac/model/*.java src/com/sun/source/tree/*.java src/com/sun/tools/javac/api/*.java src/javax/tools/*.java src/com/sun/tools/javac/util/*.java src/javax/lang/model/element/*.java src/javax/lang/model/type/*.java src/javax/lang/model/util/*.java src/javax/annotation/processing/*.java src/javax/lang/model/*.java src/com/sun/source/tree/*.java src/com/sun/source/util/*.java src/com/sun/tools/javac/sym/*.java 

javac -target 1.6 -source 1.6 -d $BUILD_DIR/target/dx src/com/android/dx/*.java src/com/android/dx/ssa/*.java src/com/android/dx/ssa/back/*.java src/com/android/dx/rop/*.java src/com/android/dx/rop/cst/*.java src/com/android/dx/rop/annotation/*.java src/com/android/dx/rop/code/*.java src/com/android/dx/rop/type/*.java src/com/android/dx/util/*.java src/com/android/dx/command/*.java src/com/android/dx/command/dexer/*.java src/com/android/dx/command/dump/*.java src/com/android/dx/command/annotool/*.java src/com/android/dx/dex/file/*.java src/com/android/dx/dex/code/*.java src/com/android/dx/dex/code/form/*.java  src/com/android/dx/dex/cf/*.java src/com/android/dx/cf/iface/*.java src/com/android/dx/cf/attrib/*.java src/com/android/dx/cf/direct/*.java src/com/android/dx/cf/cst/*.java src/com/android/dx/cf/code/*.java


(cd $BUILD_DIR/target/dx; zip -r ../dx.jar .)
(cd $BUILD_DIR/target/tools; zip -r ../tools.jar .)

$DX --dex --output=$BUILD_DIR/target/dx.dex $BUILD_DIR/target/dx.jar
$DX --dex --output=$BUILD_DIR/target/tools.dex $BUILD_DIR/target/tools.jar

fi

mkdir -p $BUILD_DIR/image/usr/share/java-support
mkdir -p $BUILD_DIR/image/usr/bin
mkdir -p $BUILD_DIR/image/usr/lib

cp $BUILD_DIR/target/dx.dex $BUILD_DIR/image/usr/share/java-support/
cp $BUILD_DIR/target/tools.dex $BUILD_DIR/image/usr/share/java-support/
cp properties/tools.properties $BUILD_DIR/image/usr/share/java-support/
cp $ANDROIDJAR $BUILD_DIR/image/usr/share/java-support/
cp -p bin/* $BUILD_DIR/image/usr/bin/

mkdir -p $BUILD_DIR/out
sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control
mkdir -p $BUILD_DIR/image/data
(cd $BUILD_DIR/image/data; ln -sf /android_root/data/dalvik-cache .)
(cd $BUILD_DIR/image; ln -sf /system/lib/libjavacrypto.so usr/lib/libjavacrypto.so)
(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".")
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB 
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/




