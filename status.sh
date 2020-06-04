#!/bin/bash

i3status -c $HOME/.config/i3/status.conf | while :;
do
    read line;
    xsetroot -name "$line" || exit 1;
done
