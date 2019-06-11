#!/bin/sh

if [ ! -d "$HOME/.scripts" ]; then
    mkdir -p "$HOME/.scripts"
fi

NAME="$(basename "$0")"

for FILE in *.sh; do
    if [ "$NAME" != "$FILE" ] && [ ! -e "$HOME/.scripts/$FILE" ]; then
        ln -s "$PWD/$FILE" "$HOME/.scripts"
    fi
done
