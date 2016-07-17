#!/bin/bash

pkg=$1
arch=$2

cachedir=$PWD/cache.$arch/$pkg
export PKGDEST=$PWD/pkgdir
export MAKEFLAGS="-j2"

# Setup keys
sudo pacman-key --init
sudo pacman-key -r 4209170B
sudo pacman-key --lsign-key 4209170B
sudo pacman-key --populate archlinux
sudo pacman-key --populate archlinuxcn

# Setup package dir
rm -rf pkgdir
mkdir pkgdir
mkdir -p "$cachedir"
git clone git://github.com/archlinuxcn/repo archlinuxcn

# Build package
cd archlinuxcn/$pkg && makepkg -s --noconfirm
