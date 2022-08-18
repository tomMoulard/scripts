#!/bin/sh
USAGE="Usage ${0} {toggle|toggle-mic|up|down|mute|set <value>}"

STEP=2
MUTE_VAL=0
SINK=0 # pacmd list-sinks | grep -e 'name:' -e 'index:' | grep -e '[0-9]'
SINK="$(pacmd list-sinks | grep -e '* index:' | cut -d " " -f 5)"
SOURCE="$(pacmd list-sources | grep -e '* index:' | cut -d " " -f 5)"
# pactl list short | grep RUNNING | cut -d"	"  -f 1

set -x

notify() {
    MODE=$(amixer get Master | grep -E 'Playback.*?\[o' | grep -E -o '\[o.+\]')
    VOLUME=$(pactl list sinks | grep '^[[:space:]]Volume:' | sed -e 's,.* \([0-9][0-9]*%\).*,\1,')
    notify-send -u low "Sound Status" "${MODE} - ${VOLUME}"
}

notifyMic() {
    STATUS=$(pactl list sources | grep -e '^[[:space:]]Volume:' -e '^[[:space:]]Mute:' | sed -e 's,.* \([1-9][0-9]*%\).*,\1,')
    notify-send -u low "Sound Status" "${STATUS}"
}

case "${1}" in
    toggle)
        amixer -D pulse sset Master toggle && notify
        ;;
    toggle-mic)
        pactl set-source-mute "${SOURCE}" toggle && notifyMic
        ;;
    up)
        # amixer -D pulse sset Master "${STEP}%+"
        pactl set-sink-volume "${SINK}" "+${STEP}%"
        ;;
    down)
        # amixer -D pulse sset Master "${STEP}%-"
        pactl set-sink-volume "${SINK}" "-${STEP}%"
        ;;
    mute)
        amixer -D pulse sset Master "${MUTE_VAL}%" && notify
        ;;
    set)
        # amixer -D pulse sset Master "${2}%"
        pactl set-sink-volume "${SINK}" "${2}%" && notify
        ;;
    *)
        echo "${USAGE}"
        exit 1
        ;;
esac

set +x
