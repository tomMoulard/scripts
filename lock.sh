#!/bin/sh

# Lock script
# Using https://github.com/Raymo111/i3lock-color

FILE=/tmp/screen.png

scrot ${FILE}
# convert ${FILE} -filter Gaussian -blur 0x8 ${FILE}
convert ${FILE} -blur 0x8 ${FILE}

notify-send "DUNST_COMMAND_PAUSE"
nmcli networking off
nmcli r wifi off

i3lock -t  -i ${FILE} \
    --clock --force-clock \
    --veriftext='' --wrongtext='' --lockfailedtext="" \
    --ring-width=20 --line-uses-inside --insidecolor=00000000

notify-send "DUNST_COMMAND_RESUME"
nmcli networking on
nmcli r wifi on

rm ${FILE}
