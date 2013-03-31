#!/bin/bash

while true; do
    /usr/bin/mail-notification.bin "$@"
    [ $? = 139 ] || break
    sleep 1
done
