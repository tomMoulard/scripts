#!/bin/bash

VOLUME_MAX=200
STEP=1

x=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,' )
let "vol=$VOLUME_MAX - $1"
if [[ $x -le $vol ]]
then
    $psst pactl set-sink-volume @DEFAULT_SINK@ +$1% && pactl set-sink-mute @DEFAULT_SINK@ 0 $update
fi
