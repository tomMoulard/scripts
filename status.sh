#!/bin/bash

# Configuration
SEP="|"
IF_NAME=wlp3s0
# IF_NAME=usb0
FILESYSTEM=sda1
BAT=BAT0

# Variables
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}
# CPU_COUNT=$(grep -c processor /proc/cpuinfo)

function setup_date() {
    date "+%a %x %X"
}

function setup_net() {
    TX=$(cat /sys/class/net/${IF_NAME}/statistics/tx_bytes)
    TX_OLD=$([ -f "${CACHE}/netstat" ] && cut -d' ' -f 1 "${CACHE}/netstat" \
        || echo 0)
    RX=$(cat /sys/class/net/${IF_NAME}/statistics/rx_bytes)
    RX_OLD=$([ -f "${CACHE}/netstat" ] && cut -d' ' -f 2 "${CACHE}/netstat" \
        || echo 0)
    TX_CAL=$(( (TX - TX_OLD) ))
    RX_CAL=$(( (RX - RX_OLD) ))
    VALUES=("B" "K" "M" "G" "T")
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
    POWER=$(awk '/^\s*w/ { print "📶", int($3 * 100 / 70) "%"}' /proc/net/wireless)

    printf "%s:⬇%4d%s⬆%4d%s %s" "${SSID}"\
        "${RX_CAL}" "${VALUES[${RX_POS}]}" \
        "${TX_CAL}" "${VALUES[${TX_POS}]}" \
        "${POWER}"
    echo "${TX} ${RX}" > "${CACHE}/netstat"
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

function setup_wttr_report() {
    # see wttr.in/:help
    WEATHERREPORT="${CACHE}/weatherreport"
    [ "$(stat -c %y "${WEATHERREPORT}" 2>/dev/null | cut -d':' -f1)" = "$(date '+%Y-%m-%d %H')" ] || \
        timeout 1 curl -sf https://wttr.in/?format="%c%h+%t+%w+%m" \
            > "${WEATHERREPORT}"
    grep -v "Unknown location" "${WEATHERREPORT}" | \
        grep -v "Sorry" | \
        grep -v "running out of queries" | \
        grep -v "default" | \
        grep -v "new queries" | \
        grep -v "https://twitter.com/igor_chubin" | \
        grep -v "======"
    [ $(ls -als "${WEATHERREPORT}" | cut -d' ' -f 6) -eq 0 ] && rm "${WEATHERREPORT}"
}

function setup_battery() {
    ICON="🔋"
    CAPACITY=$(cat /sys/class/power_supply/${BAT}/capacity)
    STATUS=$(cat /sys/class/power_supply/${BAT}/status)
    if [[ "${STATUS}" == "Charging" ]]; then
        ICON="🔌"
    fi
    printf "${ICON}%2d%%${SEP}" "${CAPACITY}"

    # Send notifications
    POWERNOTIF="${CACHE}/powernotif"
    NOTIFIED=$(cat ${POWERNOTIF})
    NOTIFIED=${NOTIFIED:=0}
    if [[ ${CAPACITY} -le 10 ]]; then
        if [[ "0" == "${NOTIFIED}" ]]; then
            notify-send -u CRITICAL -c battery \
                "Battery Level Critical" "${CAPACITY}"
            echo "1" > ${POWERNOTIF}
        fi
    else
        echo "0" > ${POWERNOTIF}
    fi
}

while :; do
    STATUS="$(setup_date)"
    STATUS="$(setup_net)${SEP}${STATUS}"
    STATUS="$(setup_df)${SEP}${STATUS}"
    STATUS="$(setup_ram)${SEP}${STATUS}"
    STATUS="🧠:$(setup_cpu)% 🌡$(setup_thermal)${SEP}${STATUS}"
    STATUS="♪:$(setup_sound_volume)${SEP}${STATUS}"
    STATUS="$(setup_wttr_report)${SEP}${STATUS}"
    STATUS="$(setup_battery)${STATUS}"
    # echo "$STATUS" || exit 1
    xsetroot -name "$STATUS" || exit 1
    sleep 1s
done

