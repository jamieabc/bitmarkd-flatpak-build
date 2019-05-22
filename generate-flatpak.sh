#!/usr/bin/env bash

SUCCESS_CODE=0
ERROR_CODE=1

source ~/.rvm/scripts/rvm

help() {
    printf "Usage: generate-flatpak.sh git_tag\n"
    printf "\tgit_tag: github tag string, e.g. v0.10.6"
}

if [ $# -eq 0 ]; then
    help
    exit "$ERROR_CODE"
fi

# git git_tag string
git_tag=$1

printf "generating bitmarkd flatpak file\n"
ruby bitmarkd.rb "$git_tag"

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
