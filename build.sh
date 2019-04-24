#!/usr/bin/env bash

SUCCESS_CODE=0
ERROR_CODE=1
result=$SUCCESS_CODE

help() {
    printf "Usage:\n"
    printf "build.sh [file] [repo-name]\n"
    printf "file: flatpak json file'"
    printf "repo-name: repository name, e.g. bitmarkd, recorderd, etc."
}

check_execution() {
    if [ $result -ne $SUCCESS_CODE ]; then
        printf "*** execution %s fail, abort ***\n" "$1"
        exit $ERROR_CODE
    fi
}

measure_time() {
    s=$(date +%s)
    "$@"
    result=$?
    printf "*** execution takes %s seconds ***\n" $(($(date +%s) - s))
}

if [ "$1" = "" ] || [ "$2" = "" ]; then
    help
    exit $ERROR_CODE
fi

FLATPAK_FILE=$1
FLATPAK_REPO=$2

printf "*** start building %s flatpak ***\n" "$FLATPAK_REPO"
measure_time flatpak-builder --repo=repo --force-clean build "${FLATPAK_FILE}"
check_execution "build flatpak"
printf "*** end building %s flatpak ***\n" "$FLATPAK_REPO"

printf "*** start bundling %s flatpak ***\n" "$FLATPAK_REPO"
measure_time flatpak build-bundle repo "${FLATPAK_REPO}.flatpak" "com.bitmark.${FLATPAK_REPO}"
check_execution "bundle flatpak"
printf "*** end bundling %s flatpak ***\n" "$FLATPAK_REPO"
