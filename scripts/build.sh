#!/bin/bash

set -e


# Include libpkgbuilder, but don't call the build function
if [ -z "$KSSTDLIBS_PATH" ]; then 
    KSSTDLIBS_PATH=/usr/lib/ks-std-libs
fi
if [ ! -e "$KSSTDLIBS_PATH/libpkgbuilder.sh" ]; then
    >&2 echo
    >&2 echo "E: Your system doesn't appear to have ks-std-libs installed. (Looking for"
    >&2 echo "   library 'libpkgbuilder.sh' in $KSSTDLIBS_PATH. To define a different"
    >&2 echo "   place to look for this file, just export the 'KSSTDLIBS_PATH' environment"
    >&2 echo "   variable.)"
    >&2 echo
    exit 4
fi
. "$KSSTDLIBS_PATH/libpkgbuilder.sh"

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

    sudo cp -a "$pkg" build/
    build_deb_package "$pkg" "build"
    rm -R build/"$(basename "$pkg")"
}

if [ -n "$1" ]; then
    build "$1"
else
    for p in dev/*; do
        if [ ! -d "$p" ] || [ "$(basename "$p")" == "pkg-skel" ]; then
            continue
        fi

        build "$p"
    done
fi

