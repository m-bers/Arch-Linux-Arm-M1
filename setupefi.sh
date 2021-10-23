 #!/bin/bash
set -o xtrace
export EXT4_UUID=$(blkid -s UUID -o value /dev/vda2)
rm /var/lib/pacman/db.lck # remove pacman lockfile?
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu --noconfirm efibootmgr
efibootmgr --disk /dev/vda --part 1 --create --label "Arch Linux ARM" --loader /Image --unicode "root=UUID=$EXT4_UUID rw initrd=\initramfs-linux.img" --verbose
poweroff
