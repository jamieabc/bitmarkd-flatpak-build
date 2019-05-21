#!/usr/bin/env bash

ERROR_CODE=1

if [ $# -ne 1 ]; then
    printf "please input public ip, abort..."
    exit "$ERROR_CODE"
fi

sudo apt install -y flatpak flatpak-builder

# install flatpak related libraries
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user
flatpak install -y flathub org.freedesktop.Platform//1.6 org.freedesktop.Sdk//1.6 --user

# install bitmarkd flatpak binary
wget https://s3-ap-northeast-1.amazonaws.com/bitmarkd-flatpak/bitmarkd.flatpak
# flatpak uninstall -y com.bitmark.bitmarkd
flatpak --user install -y bitmarkd.flatpak

# create bitmarkd data directory
mkdir -p ~/bitmarkd-data
cp bitmarkd.conf ~/bitmarkd-data/
flatpak run com.bitmark.bitmarkd --init
flatpak run com.bitmark.bitmarkd
