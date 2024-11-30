#!/bin/bash

mkdir prism
mkdir prism/boot
mkdir prism/boot/grub
mkdir assembly_line
mkdir assembly_line/packages
mkdir assembly_line/bsd
mkdir assembly_line/bsd/world
mkdir assembly_line/elf_bin
touch prism/boot/grub/grub.cfg

cat >/prism/boot/grub/grub.cfg <<EOL
set default=0
set timeout=0
menuentry "PRISM OS" {
    set root='(hd96)'
    multiboot /boot/kernel.bin
    init=/boot/init.sh
}
...
EOL

git clone https://git.freebsd.org/src.git
git clone https://github.com/alpinelinux/apk-tools
git clone https://github.com/mirror/busybox
git clone https://github.com/bminor/musl
mv src freebsd-src

cd freebsd-src
./build.sh
./config
make world
make kernel
make installworld DESTDIR=../assembly_line/bsd/world
make installkernel DESTDIR=../assembly_line/bsd
mv ../assembly_line/bsd/kernel ../assembly_line/elf_bin/kernel.elf
mv ../assembly_line/bsd/world/* ../prism/boot/
cd ..

cd apk-tools
meson setup -Dc_link_args="-static" -Dprefer_static=true -Ddefault_library=static build
ninja -C build src/apk
mv build/src/apk ../assembly_line/packages/apk
cd ..

cd busybox
make
mv *.ko ../assembly_line/packages/
cd ..

cd musl
make
mv *.so ../assembly_line/packages/
cd ..

for file in ./assembly_line/packages*.so; do
    objcopy --input binary --output elf64-x86-64 --binary-architecture i386:x86-64 $file.so $file.elf
done

for file in ./assembly_line/packages*.ko; do
    mv $file.ko $file.elf
done

for file in ./assembly_line/packages*.o; do
    mv $file.o $file.elf
done

ld -r ./assembly_line/packages/*.elf -o ./assembly_line/elf_bin/packages.elf

ld -r ./assembly_line/elf_bin/*.elf -o ./assembly_line/elf_bin/final_prism.elf
objcopy -O binary ./assembly_line/elf_bin/final_prism.elf ./prism/boot/kernel.bin

grub-mkrescue -o prism.iso prism/
dd prism.iso of=prism.img bs=4M
zip -r prism.img.zip prism.img
rm prism.iso
rm prism.img
rm -rf prism
rm -rf freebsd-src
rm -rf apk-tools
rm -rf busybox
rm -rf musl
rm -rf assembly_line