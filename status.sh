#!/bin/bash

# | ♪: 100% | sda1: 112,4 GiB | W:  79% at '- scrat 4 -' 192.168.0.69 (130 Mb/s / 2,4 GHz) | load: 0,48 | CPU: 06% | T: 39 °C | 2020-06-21 23:02:03

# i3status -c $HOME/.config/i3/status.conf | while :;
# do
    # read line;
    # xsetroot -name "$line" || exit 1;
# done
# sound volume | df | net | load | cpu % | temparature | date

# Configuration
SEP="|"
IF_NAME=wlp3s0
FILESYSTEM=sda1

# Variables
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}
CPU_COUNT=`grep processor /proc/cpuinfo | wc -l`

function setup_date() {
    date "+%a %x %X"
}

function setup_net() {
    TX=$(cat /sys/class/net/${IF_NAME}/statistics/tx_bytes)
    TX_OLD=$([ -f ${CACHE}/netstat ] && cat ${CACHE}/netstat | cut -d' ' -f 1\
        || echo 0)
    RX=$(cat /sys/class/net/${IF_NAME}/statistics/rx_bytes)
    RX_OLD=$([ -f ${CACHE}/netstat ] && cat ${CACHE}/netstat | cut -d' ' -f 2\
        || echo 0)
    TX_CAL=$(( (TX - TX_OLD) ))
    RX_CAL=$(( (RX - RX_OLD) ))
    VALUES=("B  " "KiB" "MiB" "GiB" "TiB")
    TX_POS=0
    RX_POS=0
    while [ ${TX_CAL} -ge 1024 ]; do
        TX_CAL=$(( TX_CAL / 1024 ))
        TX_POS=$(( TX_POS + 1 ))
    done
    while [ ${RX_CAL} -ge 1024 ]; do
        RX_CAL=$(( RX_CAL / 1024 ))
        RX_POS=$(( RX_POS + 1 ))
    done

    SSID=$(iwgetid | cut -d"\"" -f 2)

    printf "%s:⬇%4d%3s ⬆%4d%3s\\n" "${SSID}" "${RX_CAL}" "${VALUES[${RX_POS}]}" \
        "${TX_CAL}" "${VALUES[${TX_POS}]}"
    echo "${TX} ${RX}" > ${CACHE}/netstat
}

function setup_df () {
    df -hT | grep ${FILESYSTEM} | awk '{print "🖫:"$5}'
}

function setup_ram () {
    free -h | grep Mem | awk '{print $1$3}'
}

function setup_cpu() {
    printf "%2d" "$(top -b -n1 | grep ^%Cpu | awk '{print 100-$8}')"
}

function setup_thermal() {
    CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    printf "%d°c" $(( CPU_TEMP / 1000))
}

function setup_sound_volume() {
    VOLUME=$(pactl list sinks | grep '^[[:space:]]Volume:' | sed -e 's,.* \([0-9][0-9]*%\).*,\1,')
    ICON=$(awk -F"[][]" '/dB/ { if ($6 == "on") {icon="🔊"} else {icon="🔇"}; print icon }' <(amixer sget Master))
    echo "${VOLUME}${ICON}"
}

while :; do
    DATE=$(setup_date)
    NET=$(setup_net)
    DF=$(setup_df)
    RAM=$(setup_ram)
    CPU_TEMP=$(setup_thermal)
    CPU_UTIL=$(setup_cpu)
    VOLUME=$(setup_sound_volume)
    STATUS="♪:${VOLUME}${SEP}🧠:${CPU_UTIL}% 🌡${CPU_TEMP}${SEP}${RAM}${SEP}${DF}${SEP}${NET}${SEP}${DATE}"
    # echo "$STATUS" || exit 1
    xsetroot -name "$STATUS" || exit 1
    sleep 1s
done

