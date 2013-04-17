#!/bin/bash

while true; do
    /usr/bin/mail-notification.bin "$@"
    case $? in
        139|134)
            ;;
        *)
            break
            ;;
    esac
    sleep 1
done
