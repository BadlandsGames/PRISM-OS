git clone https://github.com/m8/elf-to-c-header.git
cd elf-to-c-header
g++ elf-to-c-header.cpp -o ../elf-to-c-header
cd ..
rm -rf elf-to-c-header
chmod +x ./elf-to-c-header