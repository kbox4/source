# This is the main install script. It is started from install.sh using
# busybox, so we can use proper busybox shell features rather than the
# restricted android stuff 
# It's important to bear in mind that the working directory at this
# point is wherever the self-extractor was run, and the busybox binary,
# and other installation artefacts, are in ./kbox4-base-install
echo Creating directories...
./kbox4-base-installer/busybox mkdir -p kbox4/lib
./kbox4-base-installer/busybox mkdir -p kbox4/bin
./kbox4-base-installer/busybox mkdir -p kbox4/etc
./kbox4-base-installer/busybox mkdir -p kbox4/var/lib/dpkg/status
./kbox4-base-installer/busybox mkdir -p kbox4/var/lib/dpkg/info
./kbox4-base-installer/busybox mkdir -p kbox4/tmp
./kbox4-base-installer/busybox mkdir -p kbox4/usr
./kbox4-base-installer/busybox mkdir -p kbox4/home/kbox

echo Installing busybox...
./kbox4-base-installer/busybox cp -p ./kbox4-base-installer/busybox kbox4/bin/ 
cd ./kbox4/bin
for c in `./busybox --list`; do ./busybox ln -sf busybox $c; done
cd ..

# Working directory is now kbox4 root
./bin/cp -p ../kbox4-base-installer/etc_profile ./etc/profile
./bin/cp -p ../kbox4-base-installer/libfakechroot.so ./lib/
./bin/cp -p ../kbox4-base-installer/kbox_shell ./bin/

echo Making symlinks...
./bin/rm -f proc
./bin/rm -f dev 
./bin/rm -f system 
./bin/rm -f storage 
./bin/rm -f sdcard 
./bin/rm -f android_root 
./bin/rm -f sbin 
./bin/ln -sf /proc proc
./bin/ln -sf /dev dev
./bin/ln -sf /system system
./bin/ln -sf /storage storage
./bin/ln -sf /sdcard sdcard
./bin/ln -sf / android_root
./bin/ln -sf bin sbin 


cd ..

# Working directory is now Android user home

rm -rf kbox4-base-installer

echo Done: KBOX shell is ./kbox4/bin/kbox_shell 

