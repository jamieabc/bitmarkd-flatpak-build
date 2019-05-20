#!/usr/bin/env bash

SUCCESS_CODE=0
ERROR_CODE=1

source ~/.rvm/scripts/rvm

help() {
    printf "Usage: generate-flatpak.sh tag\n"
    printf "\ttag: github tag number, e.g. v0.10.6"
}

if [ "$1" = "" ]; then
    help
    exit "$ERROR_CODE"
fi

tag=$1

printf "generating bitmarkd flatpak file\n"
ruby bitmarkd.rb "$tag"

if [ "$?" != "$SUCCESS_CODE" ]; then
    printf "error generate bitmarkd flatpak file\n"
    exit "$ERROR_CODE"
fi

printf "generating recorderd flatpak file\n"
ruby recorderd.rb "$tag"

if [ "$?" != "$SUCCESS_CODE" ]; then
    printf "error generate recorderd flatpak file\n"
    exit "$ERROR_CODE"
fi

exit "$SUCCESS_CODE"
