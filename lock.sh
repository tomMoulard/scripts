#!/bin/sh

# Lock script
# Using https://github.com/Raymo111/i3lock-color

FILE=/tmp/screen.png

scrot ${FILE}
# convert ${FILE} -filter Gaussian -blur 0x8 ${FILE}
convert ${FILE} -blur 0x8 ${FILE}
i3lock -t  -i ${FILE} \
    --clock --force-clock \
    --veriftext='' --wrongtext='' \
    --ring-width=20 --line-uses-inside --insidecolor=00000000
rm ${FILE}
