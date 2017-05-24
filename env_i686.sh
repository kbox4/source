# Android NDK instalation directory and related bits
# Stand-alone toolchain
NDK=/home/kevin/lib/android-14-toolchain-x86/

# Full NDK installation directory
NDK_HOME=/home/kevin/lib/android-ndk-r14b

# Ordinary (Java-based) Android SDK
ANDROID_SDK=/home/kevin/lib/android-sdk-linux
# The version of the builds tools under the SDK build-tools directory
SDK_BUILD_TOOLS_VERSION=19.0.1

SYSROOT=$NDK/sysroot/
ANDROID_PLATFORM_NAME=i686-linux-androideabi
ANDROID_PLATFORM_DIR=$NDK/platforms/android-16/arch-x86
CC_PREFIX=${NDK}/bin/i686-linux-android-

# Utilities in the android NDK toolchain -- it should not be necessary 
#  to change these
CC=${CC_PREFIX}gcc
CXX=${CC_PREFIX}g++
STRIP=${CC_PREFIX}strip

# Specify the staging directory, where downloadeds will be unpacked and processed
STAGING=/home/kevin/lib/kbox4_staging/i686

# Where to put the built binaries and packages
DIST=/home/kevin/lib/kbox4_dist/

# The value of the "arch" attribute, to put in .deb packages, etc. Not used
#  in build configuration (see CONFIG_HOST)
DEB_ARCH=i686

# These settings are passed as the --host and --build switches of configure scripts
# Some configure scripts need a long host (which is to say, target) name, and some a
#  short one -- there doesn't seem to be much consistency here.
CONFIG_HOST=arm
CONFIG_FULLHOST=i686-linux-androideabi
CONFIG_BUILD=i686

export CC
