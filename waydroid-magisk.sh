#!/usr/bin/env bash
#####################################################################
#   Waydroid Magisk Setup
#####################################################################
#
# Integrate Magisk Delta on Waydroid

abort(){   echo "$1"; exit 1;    }
set -o standalone || abort "! busybox sh doesn't support standalone mode"

[ "$(id -u)" == 0 ] || abort "! Please run script in root shell"

mkdir -p /data/local/tmp
cd /data/local/tmp || abort "! Cannot change dir to /data/local/tmp"
test -f magisk.apk || abort "! magisk.apk not found in /data/local/tmp"
/system/bin/pm install -r $(pwd)/magisk.apk

# Extract files from APK
unzip -oj magisk.apk 'assets/util_functions.sh' 'res/raw/manager.sh'
. ./util_functions.sh
. ./manager.sh

api_level_arch_detect

unzip -oj magisk.apk "lib/$ABI/*" "lib/$ABI32/libmagisk32.so" -x "lib/$ABI/libbusybox.so"
for file in lib*.so; do
  chmod 755 $file
  mv "$file" "${file:3:${#file}-6}"
done



# Magisk stuff
mkdir -p $MAGISKBIN 2>/dev/null
unzip -oj magisk.apk 'assets/*' -x 'assets/chromeos/*' \
-x 'assets/bootctl' -x 'assets/main.jar'
mkdir $NVBASE/modules 2>/dev/null
mkdir $POSTFSDATAD 2>/dev/null
mkdir $SERVICED 2>/dev/null

direct_install_system /data/local/tmp
