#!/bin/bash

set -e

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
cd archlinuxcn/$pkg
get_pkgver() {
    (. PKGBUILD; echo $pkgver)
}
# Update version first
makepkg -s -o --noconfirm
if [[ -f $cachedir/version ]]; then
    oldver=$(cat "$cachedir/version")
    if [[ $(get_pkgver) = $oldver ]]; then
        echo "Version $oldver is already built. Skipping."
        exit 0
    fi
fi
makepkg -s -e --noconfirm
get_pkgver > $cachedir/version
