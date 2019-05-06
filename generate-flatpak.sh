#!/usr/bin/env bash

SUCCESS_CODE=0
ERROR_CODE=1

source ~/.rvm/scripts/rvm

printf "generating bitmarkd flatpak file\n"
ruby bitmarkd.rb

if [ "$?" != "$SUCCESS_CODE" ]; then
    printf "error generate bitmarkd flatpak file\n"
    exit "$ERROR_CODE"
fi

printf "generating recorderd flatpak file\n"
ruby recorderd.rb

if [ "$?" != "$SUCCESS_CODE" ]; then
    printf "error generate recorderd flatpak file\n"
    exit "$ERROR_CODE"
fi

exit "$SUCCESS_CODE"
