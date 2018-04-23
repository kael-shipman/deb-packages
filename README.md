My Debian Package Development Repo
===============================================================================

This is the repo in which I'll develop most, if not all, of my personal Debian packages.

## Usage

If for some reason you'd like to replicate my packages (or use this repo as inspiration for your own such repo), here's how my system currently works:

First, make sure you've cloned the repo and have installed the basic dependencies (`sudo apt-get install reprepro dpkg-dev`)

Next all you have to do is build whichever package you want using `dpkg --build path/to/package-source-dir /path/to/target-dir`, BUT, it can actually get somewhat complicated because there are a many small details that will actually make your package usable. Here's what I can think of right now:

1. Bump the version in `DEBIAN/control`, if necessary.
2. Update the estimated size in `DEBIAN/control`. I don't hard-code this because obviously it changes with development.
3. Update md5 hashes using something like this:
```sh
files=$(find "$PKGDIR" -not -type d -not -path "*DEBIAN*")
if [ ! -z "$files" ]; then
    md5sum $files > "$PKGDIR/DEBIAN/md5sums"
    repl=$(echo "$PKGDIR/" | sed 's/\//\\\//g') # escape slashes in pathnam
    sed -i "s/$repl//g" "$PKGDIR/DEBIAN/md5sums" # make files in md5sums relative to package root
else
    echo > "$PKGDIR/DEBIAN/md5sums"
fi
```
4. Change all package files to root. Debian will restore file permissions and ownership _exactly as they are when you build the package,_ so if you leave them owned by your user, you may run into weird behavior after install.

If you do all that before you run `dpkg --build ....` then you should have a successfully built package that you can install.

Hosting it on a repo is another issue that I'm not going to address here.
