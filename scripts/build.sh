#!/bin/bash

set -e


# Include libpkgbuilder, but don't call the build function
if [ -z "$KSSTDLIBS_PATH" ]; then 
    KSSTDLIBS_PATH=/usr/lib/ks-std-libs
fi
. require libpkgbuilder.sh "$KSSTDLIBS_PATH"

function build() {
    local pkg="$1"
    if [ -n "$pkg" ] && [ ! -d "$pkg" ] && [ ! -d "dev/$pkg" ]; then
        >&2 echo
        >&2 echo "E: The package you've specified, '$pkg', does not appear to be in the dev/ folder."
        >&2 echo
        exit 5
    fi
    if [ ! -d "$pkg" ]; then
        pkg="dev/$pkg"
    fi

    sudo cp -a "$pkg" "$builddir"
    build_deb_package "$pkg" "$builddir"
    sudo rm -Rf "$builddir/$(basename "$pkg")"
}

export builddir="./pkg-build"
if [ "$#" -gt 0 ]; then
    while [ "$#" -gt 0 ]; do
        build "$1"
        shift
    done
else
    for p in dev/*; do
        if [ ! -d "$p" ] || [ "$(basename "$p")" == "pkg-skel" ]; then
            continue
        fi

        build "$p"
    done
fi

