#!/bin/bash

mkdir prism
mkdir prism/boot
mkdir prism/boot/grub
mkdir prism/boot/fs
mkdir assembly_line
mkdir assembly_line/packages
mkdir assembly_line/bsd
mkdir assembly_line/bsd/world
mkdir assembly_line/elf_bin
mkdir prism/boot/loaded
touch prism/boot/grub/grub.cfg
touch prism/boot/init.sh
touch prism/boot/startup.ps1
touch prism/boot/api.ps1

touch prism_gui.py
cat >prism_gui.py <<EOL
from flask import *
import webview
import thread
import pyautogui
import random
import signal
import sys
import os

width = pyautogui.size()[0]
height = pyautogui.size()[1]

main_window = None

def signal_handler(signal, frame):
    sys.exit(0)

def kill_app():
    signal.signal(signal.SIGINT, signal_handler)
    webview.destroy_window(main_window)

def shutdown_prism():
    print("BEEF_SHUTDOWN_PRISM")
    kill_app()

def run_proton(path):
    os.system("cp -r fs/" + path + "* loaded/")
    print("BEEF_LAUNCHGAME_PRISM_PROTON")
    kill_app()

def run_wine(path):
    os.system("cp -r fs/" + path + "* loaded/")
    print("BEEF_LAUNCHGAME_PRISM_WINE")
    kill_app()

def run_winemono(path):
    os.system("cp -r fs/" + path + "* loaded/")
    print("BEEF_LAUNCHGAME_PRISM_WINEMONO")
    kill_app()

def run_elf(path):
    os.system("cp -r fs/" + path + "* loaded/")
    print("BEEF_LAUNCHGAME_PRISM_ELF")
    kill_app()

def run_appimage(path):
    os.system("cp -r fs/" + path + "* loaded/")
    print("BEEF_LAUNCHGAME_PRISM_APPIMAGE")
    kill_app()

app_port = random.randint(1000, 9999)

app = Flask(__name__)

@app.route('/')
def home():
    return render_template("index.html")

@app.route('/function_called', methods=['POST'])
def function_called():
    data = request.get_json()
    param = str(data.get('param')) + "()"
    eval(param)

def create_window():
    app.run(debug=False, port=app_port)
    main_window = webview.create_window('View GUI', 'http://localhost:' + str(app_port) + '/', width=width, height=height)

def main_app():
    app_thread = threading.Thread(target=create_window)
    thread.start()
    webview.start()

os.system("sudo systemctl restart")

...
EOL

pyinstaller --onefile prism_gui.py
mv dist/prism_gui prism/boot/gui.elf
rm -rf dist

rm prism_gui.py

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

cat >/prism/boot/init.sh <<EOL
#!/bin/ksh

pwsh ./startup.ps1

if [[ $? -ne 0 ]]; then
    apk add bash
    apk add powershell
    apk add dpkg
    apk add apt
    apk add flatpak
    apk add libgcompat
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak --user install com.valvesoftware.Steam
    flatpak --user install com.valvesoftware.Steam.CompatibilityTool.Proton-Exp
    mkdir /steam_compatdata/
    export STEAM_COMPAT_DATA_PATH="/steam_compatdata/"
    export WINEPREFIX="$STEAM_COMPAT_DATA_PATH/pfx"
    cd /.steam/steam/steamapps/common
    latest_proton=$(ls -d Proton* | sort -V | tail -n 1)
    cd ..
    cd ..
    cd ..
    cd ..
    export PROTON_FOLDER_PRISM="/.steam/steam/steamapps/common/$latest_proton"
    apk add wine
    wine-mono --install
    pwsh ./startup.ps1
fi
...
EOL

cat >prism/boot/startup.ps1 <<EOL
#!/usr/bin/powershell

./api.ps1

$prism_running = $true

while($prism_running) {
    ./gui.elf
    $output = Get-Process
    if($output -Contains "BEEF_SHUTDOWN_PRISM") {
        break
    } elseif($output -Contains "BEEF_LAUNCHGAME_PRISM_PROTON") {
        chmod +x /loaded/*
        RunExeViaProton -File "/loaded/index.exe"
    } elseif($output -Contains "BEEF_LAUNCHGAME_PRISM_WINE") {
        chmod +x /loaded/*
        RunExeViaWine -File "/loaded/index.exe"
    } elseif($output -Contains "BEEF_LAUNCHGAME_PRISM_WINEMONO") {
        chmod +x /loaded/*
        RunExeViaWineMono -File "/loaded/index.exe"
    } elseif($output -Contains "BEEF_LAUNCHGAME_PRISM_ELF") {
        chmod +x /loaded/*
        ./loaded/index.elf
    } elseif($output -Contains "BEEF_LAUNCHGAME_PRISM_APPIMAGE") {
        chmod +x /loaded/*
        ./loaded/index.AppImage
    }
}

shutdown -h now

...
EOL

cat >prism/boot/api.ps1 <<EOL
#!/usr/bin/powershell

function RunExeViaProton {
    param (
        [string]$File
    )
    eval "$PROTON_FOLDER_PRISM/proton run /fs/$File"
}

function RunExeViaWine {
    param (
        [string]$File
    )
    eval "wine /fs/$File"
}

function RunExeViaWineMono {
    param (
        [string]$File
    )
    eval "wine-mono /fs/$File"
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