# Arch Linux ARM for Apple Silicon Macs

This is basically a scriptification of 
[thalamus/ArchLinuxARM-M1](https://gist.github.com/thalamus/561d028ff5b66310fac1224f3d023c12) so most of the credit goes to tbe author of the gist. 
I also use GitHub Actions to build a release nightly (If anyone knows the schedule for archlinuxarm rootfs image releases let me know and I'll adjust)
## Download

Download the latest nightly build here: 

## Booting the image

Make sure you have a patched qemu-system-aarch64 (the one from homebrew boots with hvf acceleration but networking appears completely broken and won't be fixed until qemu 6.2) in your $PATH. I used the one from [canonical/multipass](https://github.com/canonical/multipass/issues/1857#issuecomment-932232353) which is installed to `/Library/Application Support/com.canonical.multipass/bin/qemu-system-aarch64` on my M1 Macbook Air. 

Once you have qemu-system-aarch64, then run the below command in the folder you extracted `alarm.zip` to:
```
qemu-system-aarch64 -L ~/bin/qemu/share/qemu \
	-smp 8 \
	-machine virt,accel=hvf,highmem=off \
	-cpu cortex-a72 -m 4096 \
	-drive "if=pflash,media=disk,id=drive0,file=flash0.img,cache=writethrough,format=raw" \
	-drive "if=pflash,media=disk,id=drive1,file=flash1.img,cache=writethrough,format=raw" \
	-drive "if=virtio,media=disk,id=drive2,file=archlinux.qcow2,cache=writethrough,format=qcow2" \

    #   IMPORTANT NOTE: Depending on your version of qemu, `vmnet-macos` might not work. 
    #   The gist these scripts are based on uses a user nic with a hostfwd:
    #       -nic user,model=virtio-net-pci,hostfwd=tcp::50022-:22 -nographic \
    #   If you use UTM's qemu-system-aarch64, you would then need to connect to your arch vm via SSH over port 50022. 

	-nic vmnet-macos,mode=shared,model=virtio-net-pci \ # works with the qemu-system-aarch64 in canonical/multipass

	-device virtio-rng-device -device virtio-balloon-device -device virtio-keyboard-device \
	-device virtio-mouse-device -device virtio-serial-device -device virtio-tablet-device \
	-object cryptodev-backend-builtin,id=cryptodev0 \
	-device virtio-crypto-pci,id=crypto0,cryptodev=cryptodev0
```
## Building an image

```
git clone 
cd 
./build.sh
./boot.exp
```

License (if I'm doing this wrong let me know)
```
/* 
 * This document is provided to the public domain under the 
 * terms of the Creative Commons CC0 public domain license
 */
```