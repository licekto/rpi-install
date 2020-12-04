#!/bin/bash

#set -xe

partitions() {
    local dev=$1
    echo "o
    n
    p
    1
    
    +200M
    t
    c
    n
    p
    2
    
    
    w
    " | fdisk $dev
}

if [ `whoami` != 'root' ]; then
    echo >&2 "Must run as root!"
    exit 1
fi

if [ $# != 1 ]; then
    echo >&2 "Device to be formated is needed"
    exit 1
fi

LOG_FILE="install.log"
DEV=$1
DEV1="${DEV}1"
DEV2="${DEV}2"
WORK_DIR=/tmp/rpi
BOOT_DIR="/tmp/rpi/boot"
ROOT_DIR="/tmp/rpi/root"
IMAGE="ArchLinuxARM-rpi-latest.tar.gz"

echo "Preparing partitions..."
{
lsblk
partitions $DEV
mkfs.vfat $DEV1
mkdir -p $BOOT_DIR
mount $DEV1 $BOOT_DIR

mkfs.ext4 $DEV2
mkdir -p $ROOT_DIR
mount $DEV2 $ROOT_DIR

lsblk
} > $LOG_FILE 2>&1

wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz --directory-prefix=/tmp/rpi
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz.md5 --directory-prefix=/tmp/rpi
#mkdir -p /tmp/rpi
#cp ArchLinuxARM-rpi-latest.tar.gz /tmp/rpi
#cp ArchLinuxARM-rpi-latest.tar.gz.md5 /tmp/rpi

echo "Extracting the root filesystem..."
{
diff <(md5sum $WORK_DIR/$IMAGE | awk '{ print $1 }') <(cat $WORK_DIR/$IMAGE.md5 | awk '{ print $1 }')
if [ $? != 0 ]; then
    echo >&2 "Invalid image!"
    exit 1
fi
bsdtar -xpf $WORK_DIR/$IMAGE -C $ROOT_DIR
sync

mv $ROOT_DIR/boot/* $BOOT_DIR
umount $BOOT_DIR $ROOT_DIR

rm -r $WORK_DIR
} >> $LOG_FILE 2>&1
