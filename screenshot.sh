#!/bin/sh

VERSION=1
PICTURE_PATH="$HOME/Pictures/$(printf 'Screenshot from %s %s.png' $(date +'%Y-%m-%d %H-%M-%S'))"

USAGE="
Usage: $0 OPTION\n
Wrappes screenshots utility\n\n
OPTION:\n
\t-f --full(default)\tTakes a screenshot of the whole screen\n
\t-s --select\t\tTakes a screenshot of a selection of the screen\n
Version: ${VERSION}
"

[ "$1" = "" ] && echo $USAGE && exit 1

case $1 in
    -f|--full)
        scrot "$PICTURE_PATH"
        ;;
    -s|--select)
        import "$PICTURE_PATH"
        ;;
    *)
    echo $USAGE && exit 1
esac
