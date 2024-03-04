#!/bin/bash

# Get the current directory as a absolute path.
KERNEL_DIR="$(pwd)"
PARENT="$(dirname "$KERNEL_DIR")"

main() {
    echo "[+] Starting."
    get_deps
    get_build_deps
    if ! which dtc 2>&1 >/dev/null; then build_dtc; fi
    echo "[+] Done."
}

get_deps() {
    echo "[+] Getting build dependancies from apt."

    if ! which git 2>&1 >/dev/null; then sudo apt install -y git; fi
    if ! which mkbootimg 2>&1 >/dev/null; then sudo apt install -y mkbootimg; fi
    if ! which make 2>&1 >/dev/null; then sudo apt install -y make; fi
    if ! which zipalign 2>&1 >/dev/null; then sudo apt install -y zipalign; fi

    if ! which pkg-config 2>&1 >/dev/null; then sudo apt install -y pkg-config; fi
    if ! which flex 2>&1 >/dev/null; then sudo apt install -y flex; fi
    if ! which bison 2>&1 >/dev/null; then sudo apt install -y bison; fi
    
    if ! which fakeroot 2>&1 >/dev/null; then sudo apt install -y fakeroot; fi
    if ! which lz4 2>&1 >/dev/null; then sudo apt install -y lz4; fi

    if ! dpkg -l libncurses5-dev 2>&1 >/dev/null; then sudo apt install -y libncurses5-dev; fi

    # The version of device tree compiler (DTC) in the apt repo is too old and results in a completion error, so lets get rid of it.
    sudo apt purge -y device-tree-compiler
}

get_build_deps() {
    echo "[+] Getting build dependancies from github"
    cd $PARENT
    # if [ ! -e dtc ]; then git clone git://git.kernel.org/pub/scm/utils/dtc/dtc.git; fi
    if [ ! -e dtc ]; then git clone https://github.com/dgibson/dtc.git; fi
    if [ ! -e AnyKernel3 ]; then git clone https://github.com/arter97/AnyKernel3.git; fi
    if [ ! -e arm32-gcc ]; then 
        git clone https://github.com/arter97/arm32-gcc.git
        cd arm32-gcc
        # There are probably newer commits that work, but these was around the time I was working on it
        git checkout 28cb8b1061c9af241929a112587b1a1698b8a19b
    fi
    if [ ! -e arm64-gcc ]; then 
        git clone https://github.com/arter97/arm64-gcc.git; 
        cd arm64-gcc
        # There are probably newer commits that work, but these was around the time I was working on it
        git checkout c2a52681bb9763e4f47348f8da5d8a097e070611
    fi
}

# Install the latest version of Device Tree Compiler
build_dtc() {
    echo "[+] Building DTC"
    cd $PARENT/dtc
    make -j$(nproc) NO_PYTHON=1
    export PATH=$PATH:$(pwd)
}

main
