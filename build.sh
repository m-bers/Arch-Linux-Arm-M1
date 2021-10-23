#!/bin/bash
set -o xtrace

sudo apt-get -y update && apt-get -y install qemu-system-aarch64 qemu-utils libarchive-tools expect libguestfs-tools
wget -nc -q http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
wget -nc -q https://github.com/qemu/qemu/raw/master/pc-bios/edk2-aarch64-code.fd.bz2
qemu-img create archlinux.img 16G

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk archlinux.img
  g     # create a GPT partition table
  n     # new partition
  1     # partition number 1
        # default - start at beginning of disk 
  +512M # 512 MB EFI parttion
  t     # change type
  1     # EFI system
  n     # new partition
  2     # partion number 2
        # default, start immediately after preceding partition
        # default, extend partition to end of disk
  w     # write the partition table
EOF
{
  read -r _ _ EFI _  # first line:  read third word into efi
  read -r _ _ EXT4 _   # second line: read third word into ext4
} < <(sudo kpartx -av archlinux.img)

sudo mkfs.vfat /dev/mapper/$EFI
sudo mkfs.ext4 /dev/mapper/$EXT4
mkdir root
sudo mount /dev/mapper/$EXT4 root
mkdir root/boot
sudo mount /dev/mapper/$EFI root/boot
sudo bsdtar -xpf ArchLinuxARM-aarch64-latest.tar.gz -C root
EFI_UUID=$(blkid -s UUID -o value /dev/mapper/$EFI)
EXT4_UUID=$(blkid -s UUID -o value /dev/mapper/$EXT4)
cat <<EOF > root/etc/fstab
/dev/disk/by-uuid/$EXT4_UUID / ext4 defaults 0 0
/dev/disk/by-uuid/$EFI_UUID /boot vfat defaults 0 0
EOF
cat <<EOF > root/boot/startup.nsh
Image root=UUID=$EXT4_UUID rw initrd=\initramfs-linux.img
EOF
echo "DefaultTimeoutStopSec=300s" >> root/etc/systemd/system.conf
sudo cp setupefi.sh root/root
sudo umount root/boot
sudo umount root
sudo kpartx -d archlinux.img
sudo sync
qemu-img convert -O qcow2 archlinux.img setup.qcow2
truncate -s 64M flash0.img
truncate -s 64M flash1.img
bzip2 -d edk2-aarch64-code.fd.bz2
dd if=edk2-aarch64-code.fd of=flash0.img conv=notrunc
sudo ./boot.exp
virt-sparsify setup.qcow2 archlinux.qcow2
tar czf archlinux.tar.gz archlinux.qcow2 flash0.img flash1.img