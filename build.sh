#!/bin/bash
mkdir prism
mkdir prism/boot
mkdir prism/boot/grub
mkdir assembly_line
mkdir assembly_line/packages
mkdir assembly_line/bsd
mkdir assembly_line/elf_bin
touch prism/boot/grub/grub.cfg
cat >/prism/boot/grub/grub.cfg <<EOL
set default=0
set timeout=0
menuentry "PRISM OS" {
    set root='(hd96)'
    multiboot /boot/kernel.bin
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
make installworld DESTDIR=../assembly_line/bsd
make installkernel DESTDIR=../assembly_line/bsd
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
make *.so ../assembly_line/packages/
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
grub-mkrescue -o prism.iso prism/
rm -rf prism
rm -rf freebsd-src
rm -rf apk-tools
rm -rf busybox
rm -rf musl
rm -rf assembly_line