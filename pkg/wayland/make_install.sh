#!/bin/bash -e

unlock_install() {
    echo "Unlock for ${pkg_dir_name}"
    rm ../install.lock
}

lock_install() {
    echo "Locking for ${pkg_dir_name}"
    while ! ln -s $$ ../install.lock; do
        echo "Failed to lock for ${pkg_dir_name}. retry in 1s."
        sleep 1
    done
    ls --color /var/lib/pacman
    trap unlock_install 0
}

pkg_dir_name="$1"
echo "Making ${pkg_dir_name}"
makepkg -f > "${pkg_dir_name}.build.log"
source ./PKGBUILD
lock_install
expect -c "
spawn sudo pacman --noconfirm -U ${pkgname}-${pkgver}-${pkgrel}-x86_64.pkg.tar.xz
expect {
    \"*password*\" {
        send ${PASSWORD}\r;
        exp_continue;
    }
    \"*orry*try*again*\" {
        exit 1;
    }
}
wait
"

_pkgdir="/var/lib/pacman/local/${pkgname}-${pkgver}-${pkgrel}/"
ls --color "${_pkgdir}" || {
    echo "Cannot find ${_pkgdir}"
}

echo "Done $1"
