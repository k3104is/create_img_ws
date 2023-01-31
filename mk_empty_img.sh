#!/bin/bash

#set -e
set -x

# Create an empty image as below and mount them
# ----------------------------------------------
# | boot(vfat) | rootfs(ext4) |
# ----------------------------------------------
rm -f image.img
dd if=/dev/zero of=image.img bs=1M count=1024
LOOP_DEV=$(losetup -f)
losetup $LOOP_DEV image.img
parted -a optimal $LOOP_DEV -s mklabel msdos \
  -s mkpart primary fat32 2048s   100MiB \
  -s mkpart primary ext4  100MiB  900MiB

fdisk -l ${LOOP_DEV}

mkfs.vfat -n 'boot' ${LOOP_DEV}p1
mkfs.ext4 -L 'rootfs' -O ^has_journal ${LOOP_DEV}p2
mkdir fs fs/boot fs/rootfs
mount ${LOOP_DEV}p1 fs/boot
mount ${LOOP_DEV}p2 fs/rootfs

# Copy all files on boot and rootfs to the corresponding partition
#cp -r ${BOOT_PATH}/* fs/boot/
#cp -a ${ROOTFS_PATH}/* fs/rootfs/

# Unmount all partitions
umount fs/boot
umount fs/rootfs
rm -rf fs
losetup -d $LOOP_DEV
