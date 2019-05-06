#!/usr/bin/env bash

SUCCESS_CODE=0
ERROR_CODE=1

ruby bitmarkd.rb

if [ "$?" != "$SUCCESS_CODE" ]; then
    printf "error generate bitmarkd flatpak file"
    exit "$ERROR_CODE"
fi

ruby recorderd.rb

if [ "$?" != "$SUCCESS_CODE" ]; then
    printf "error generate recorderd flatpak file"
    exit "$ERROR_CODE"
fi

exit "$SUCCESS_CODE"
