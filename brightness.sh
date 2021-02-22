#!/bin/bash

USAGE="Usage ${0} {full|up|down|set <value>}"

STEP=2    # Increment step (10x)
MAX=10    # Max screen brightness value (10x)
MIN=0     # Min screen brightness value (10x)
VAL=$(xrandr --prop --verbose | \
    grep -A10 " connected" | grep "Brightness" | \
    sed -e 's,.*: \([0-9][0-9]*.[0-9][0-9]*\).*,\1,')

setbrg () {
    # Bash does not have floats T_T
    VAL=$(python3 -c "print(int(${VAL} * 10))")
    if [[ "${1}" = "up" ]]; then
        RET=$(( VAL + STEP ))
    else
        RET=$(( VAL - STEP ))
    fi

    if [[ ${RET} -ge ${MAX} ]]; then
        RET=${MAX}
    elif [[ ${RET} -le ${MIN} ]]; then
        RET=${MIN}
    fi
    python3 -c "print(${RET} / 10)"
}

case "${1}" in
    full)
        xrandr --output "${SCREEN}" --brightness 1.0
        ;;
    up|down)
        xrandr --output "${SCREEN}" --brightness "$(setbrg "${1}")"
        ;;
    set)
        xrandr --output "${SCREEN}" --brightness "${2}"
        ;;
    *)
        echo -e "${USAGE}"
        exit 1
        ;;
esac
