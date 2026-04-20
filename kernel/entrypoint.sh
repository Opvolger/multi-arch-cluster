#!/bin/bash
mkdir -p source

tar -xf linux-6.19.13.tar.xz -C source
rm source/linux-6.19.13/.gitignore
cp config source/linux-6.19.13/.config

cd source/linux-6.19.13
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
scripts/config --disable DEBUG_INFO
scripts/config --disable MODULE_SIG

make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- DPKG_FLAGS=-d -j 16 bindeb-pkg
