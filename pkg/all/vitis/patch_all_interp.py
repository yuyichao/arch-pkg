#!/usr/bin/env python

import sys
import lief
import os
import os.path
import stat

def try_patch_file(path, pkgdir):
    if not os.path.isfile(path) or not lief.is_elf(path):
        return
    binary = lief.parse(path)
    if not binary.has_interpreter:
        return
    old_interp = binary.interpreter
    if old_interp.endswith('/ld-linux-x86-64.so.2'):
        if (old_interp == '/lib64/ld-linux-x86-64.so.2' or
                old_interp == '/usr/lib64/ld-linux-x86-64.so.2' or
                old_interp == '/usr/lib/ld-linux-x86-64.so.2'):
            return
        binary.interpreter = '/lib/ld-linux-x86-64.so.2'
    elif old_interp.startswith(pkgdir + '/'):
        binary.interpreter = old_interp[len(pkgdir):]

    if old_interp == binary.interpreter:
        return

    print("Patching .interp for %s to %s" % (path, binary.interpreter))

    os.remove(path)
    binary.write(path)
    st = os.stat(path)
    os.chmod(path, st.st_mode | stat.S_IEXEC)

def patch_all_elf(root, pkgdir):
    pkgdir = pkgdir.rstrip('/')
    for r, d, fs in os.walk(root):
        for f in fs:
            try_patch_file(os.path.join(r, f), pkgdir)

if __name__ == '__main__':
    patch_all_elf(sys.argv[1], sys.argv[2])
