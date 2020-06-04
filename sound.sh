#!/bin/sh
USAGE="Usage $0 {toggle|up|down|mute|set}
"

STEP=2
MUTE_VAL=0

case "$1" in
    toggle)
        amixer -D pulse sset Master toggle
        ;;
    up)
        amixer -D pulse sset Master ${STEP}%+
        ;;
    down)
        amixer -D pulse sset Master ${STEP}%-
        ;;
    mute)
        amixer -D pulse sset Master ${MUTE_VAL}%
        ;;
    set)
        amixer -D pulse sset Master ${2}%
        ;;
    *)
        printf "$USAGE"
        exit 1
        ;;
esac
