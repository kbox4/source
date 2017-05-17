#!/system/bin/sh
# This install.sh is auto-run when the self-extracting installer has finished.
# It just starts busybox with the 'real' install script
./kbox4-base-installer/busybox bash -c ./kbox4-base-installer/install-using-busybox.sh

