#!/bin/bash

pkg=$1

export PKGDEST=$PWD/pkgdir
export MAKEFLAGS="-j2"
cd archlinuxcn/$pkg && makepkg -s --noconfirm
