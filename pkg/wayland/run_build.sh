#!/bin/bash
stty -echo
read -p "password:" password
stty echo
export PASSWORD="${password}"
make $@
unset PASSWORD
