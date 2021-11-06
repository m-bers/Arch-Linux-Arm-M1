[![nightly](https://github.com/m-bers/Arch-Linux-Arm-M1/actions/workflows/nightly.yml/badge.svg)](https://github.com/m-bers/Arch-Linux-Arm-M1/actions/workflows/nightly.yml)![GitHub all releases](https://img.shields.io/github/downloads/m-bers/Arch-Linux-Arm-M1/total)
# Arch Linux ARM for Apple Silicon Macs
This is basically a scriptification of 
[thalamus/ArchLinuxARM-M1](https://gist.github.com/thalamus/561d028ff5b66310fac1224f3d023c12) so most of the credit goes to the author of the gist. 
## Download
Get the latest release [here](https://github.com/m-bers/Arch-Linux-Arm-M1/releases/latest/download/archlinux.tar.gz)
## Booting the image

I'm using https://github.com/knazarov/homebrew-qemu-virgl because it seems to offer the best support for networking and graphics. I did not have much success with the qemu binary included in the homebrew repos, but this will probably be fixed when QEMU 6.2 releases. 

```zsh
# Install qemu (needs homebrew, get it here: https://brew.sh/)
brew install knazarov/qemu-virgl/qemu-virgl

# make a suitable directory for image and efivars
mkdir archlinux
cd archlinux

# Download latest release and extract 
curl -L https://github.com/m-bers/Arch-Linux-Arm-M1/releases/latest/download/archlinux.tar.gz | tar xzf -

# Boot Arch Linux ARM
sudo qemu-system-aarch64 -L ~/bin/qemu/share/qemu \
	-smp 8 \
	-machine virt,accel=hvf,highmem=off \
	-cpu cortex-a72 -m 4096 \
	-drive "if=pflash,media=disk,id=drive0,file=flash0.img,cache=writethrough,format=raw" \
	-drive "if=pflash,media=disk,id=drive1,file=flash1.img,cache=writethrough,format=raw" \
	-drive "if=virtio,media=disk,id=drive2,file=archlinux.qcow2,cache=writethrough,format=qcow2" \
	-nic vmnet-macos,mode=shared,model=virtio-net-pci \
	-device virtio-rng-device -device virtio-balloon-device -device virtio-keyboard-device \
	-device virtio-mouse-device -device virtio-serial-device -device virtio-tablet-device \
	-object cryptodev-backend-builtin,id=cryptodev0 \
	-device virtio-crypto-pci,id=crypto0,cryptodev=cryptodev0 \
	-nographic
```
## Building an image
On Ubuntu (I used 20.04):
```
git clone https://github.com/m-bers/Arch-Linux-Arm-M1.git
cd Arch-Linux-Arm-M1
sudo ./build.sh
```
