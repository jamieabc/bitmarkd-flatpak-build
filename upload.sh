#!/usr/bin/env bash
set -e

source ~/.rvm/scripts/rvm

ERROR_CODE=1
BITMARKD_FLATPAK_BUNDLE="bitmarkd.flatpak"
RECORDERD_FLATPAK_BUNDLE="recorderd.flatpak"

if [ $# -ne 1 ]; then
    printf "Not enough argument\n"
    exit "$ERROR_CODE"
fi

tag=$1

ruby upload.rb "$tag" "$BITMARKD_FLATPAK_BUNDLE"
ruby upload.rb "$tag" "$RECORDERD_FLATPAK_BUNDLE"
