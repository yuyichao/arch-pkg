#!/bin/bash

set -e

files=($(curl -X GET https://api.bintray.com/packages/yuyichao/ArchPkg/arch/versions/0.0/files | jq -r '.[].name'))

declare -A latest_ver
declare -A latest_file

for file in "${files[@]}"; do
    [[ $file =~ ^(.*)-([^-]*-[^-]*)-([^-.]*)\.pkg\..* ]]
    pkgname=${BASH_REMATCH[1]}
    fullver=${BASH_REMATCH[2]}
    arch=${BASH_REMATCH[3]}
    key=$pkgname-$arch
    if [[ -n ${latest_ver["$key"]} ]]; then
        [[ $(vercmp ${latest_ver[$key]} ${fullver}) = -1 ]] || continue
    fi
    latest_ver["$key"]=$fullver
    latest_file["$key"]=$file
done

dir=.pkg_upload_tmp
rm -rf --one-file-system "$dir"
mkdir $dir
pushd $dir
for key in "${!latest_ver[@]}"; do
    ver=${latest_ver[$key]}
    file=${latest_file[$key]}
    wget "https://bintray.com/yuyichao/ArchPkg/download_file?file_path=$file" \
         -O "$file"
    gpg --detach-sign "$file"
done
sftp -b /dev/stdin build.archlinuxcn.org:repo <<EOF
progress
put *
EOF
popd
