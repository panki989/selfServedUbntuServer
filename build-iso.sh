#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo 'Must be root (UID 0)'
    exit 1
fi

set -ex

apt-get update -y
apt-get install -y --no-install-recommends \
    isolinux \
    syslinux \
    xorriso \
    curl

pushd /opt
if [[ ! -f 'ubuntu-20.04.2-live-server-amd64.iso' ]]; then
    curl -fsSL -O https://old-releases.ubuntu.com/releases/20.04/ubuntu-20.04.2-live-server-amd64.iso
fi
mkdir -p iso/nocloud/

# -osirrox on copy files from ISO image to disk filesystem
# -indev=the input drive from which to load ISO image
# -extract iso_rr_path disk_path: Copy the file objects at and
#  underneath iso_rr_path to their corresponding addresses at and underneath disk_path
/usr/bin/xorriso \
    -osirrox on \
    -indev 'ubuntu-20.04.2-live-server-amd64.iso' \
    -extract / iso

# Files are missing w bits, this will make them 644 rather than 444
chmod -R +w iso

touch iso/nocloud/meta-data
cp -a ~/user-data iso/nocloud/user-data

# Update boot flags with cloud-init autoinstall
# Modifies iso/isolinux/txt.cfg to look similar to:
# append   initrd=/casper/initrd quiet  autoinstall ds=nocloud;s=/cdrom/nocloud/ ---
/usr/bin/sed -i 's|---|autoinstall ds=nocloud\\\;s=/cdrom/nocloud/ ---|g' iso/boot/grub/grub.cfg
/usr/bin/sed -i 's|---|autoinstall ds=nocloud;s=/cdrom/nocloud/ ---|g' iso/isolinux/txt.cfg

# Disable mandatory md5 checksum on boot
/usr/bin/md5sum iso/.disk/info > iso/md5sum.txt
/usr/bin/sed -i 's|iso/|./|g' iso/md5sum.txt

# Create Install ISO from extracted dir
# https://www.ecma-international.org/wp-content/uploads/ECMA-119_4th_edition_june_2019.pdf
/usr/bin/xorriso \
    -as mkisofs \
    -r \
    -volid ubuntu-nsm-amd64 \
    -o 'self-ubuntu-20.04.2-live-server-amd64.iso' \
    -J \
    -l \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -isohybrid-apm-hfsplus \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin  \
    iso/boot \
    iso

/usr/bin/stat self-ubuntu-20.04.2-live-server-amd64.iso
popd

# To copy in shared vm folder
/usr/bin/mv /opt/self-ubuntu-20.04.2-live-server-amd64.iso /mnt/hgfs/vm_mount/

# Clear iso folder in opt dir to free space
/usr/bin/rm -rf /opt/iso
