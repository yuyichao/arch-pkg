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
mkdir -p $dir
pushd $dir
upload_cmd=''
for key in "${!latest_ver[@]}"; do
    file=${latest_file[$key]}
    if [[ -f ${file} ]] && [[ -f ${file}.sig ]]; then
        continue
    fi
    upload_cmd="$upload_cmd"$'\n'"put ${file}"$'\n'"put ${file}.sig"
    wget "https://bintray.com/yuyichao/ArchPkg/download_file?file_path=$file" \
         -O "$file"
    gpg --detach-sign "$file"
done
sftp -b /dev/stdin build.archlinuxcn.org:repo <<EOF
progress
$upload_cmd
EOF
popd
