#!/bin/bash

if [[ "$VER" != "" ]];then
    set -- $VER  $@



echo "Downloading '$@'"


sudo bash -c "$(curl -sLfo- https://raw.githubusercontent.com/click23/hid/refs/heads/main/download_install.sh)"
exit $?



mkdir -p /tmp/hiddify/
chmod 600 /tmp/hiddify/
rm -rf /tmp/hiddify/*
curl -sL -o /tmp/hiddify/hiddify_installer.sh https://raw.githubusercontent.com/hiddify/Hiddify-Manager/main/common/hiddify_installer.sh
curl -sL -o /tmp/hiddify/utils.sh https://raw.githubusercontent.com/hiddify/Hiddify-Manager/main/common/utils.sh
chmod 700 /tmp/hiddify/*

/tmp/hiddify/hiddify_installer.sh $@
