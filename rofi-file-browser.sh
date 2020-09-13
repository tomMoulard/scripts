#!/usr/bin/env bash

# Various options for the file browser script:
ROFI_FB_GENERIC_FO="xdg-open" # command used for opening the selection
ROFI_FB_PREV_LOC_FILE=~/.local/share/rofi/rofi_fb_prevloc
ROFI_FB_HISTORY_FILE=~/.local/share/rofi/rofi_fb_history
ROFI_FB_HISTORY_MAXCOUNT=5 # maximum number of history entries
# Comment the next variable to always start in the last visited directory,
# otherwise rofi_fb will start in the specified directory:
ROFI_FB_START_DIR=$HOME # starting directory
# Uncomment the following line to disable history:
# ROFI_FB_NO_HISTORY=1


# Create the directory for the files of the script
[ ! -d $(dirname "${ROFI_FB_PREV_LOC_FILE}") ] && mkdir -p "$(dirname "${ROFI_FB_PREV_LOC_FILE}")"
[ ! -d $(dirname "${ROFI_FB_HISTORY_FILE}") ] && mkdir -p "$(dirname "${ROFI_FB_HISTORY_FILE}")"

# Initialize $ROFI_FB_CUR_DIR
if [ -d "${ROFI_FB_START_DIR}" ]
then
    ROFI_FB_CUR_DIR="${ROFI_FB_START_DIR}"
else
    ROFI_FB_CUR_DIR="$PWD"
fi

# Read last location, otherwise we default to $ROFI_FB_START_DIR or $PWD.
[ -f "${ROFI_FB_PREV_LOC_FILE}" ] && ROFI_FB_CUR_DIR=$(cat "${ROFI_FB_PREV_LOC_FILE}")

# Handle argument.
if [ -n "$@" ]
then
    if [[ "$@" == /* ]]
    then
        ROFI_FB_CUR_DIR="$@"
    else
        ROFI_FB_CUR_DIR="${ROFI_FB_CUR_DIR}/$@"
    fi
fi

# If argument is no directory.
if [ ! -d "${ROFI_FB_CUR_DIR}" ]
then
    if [ -x "${ROFI_FB_CUR_DIR}" ]
    then
        coproc ( "${ROFI_FB_CUR_DIR}"  > /dev/null 2>&1 )
        exec 1>&-
        exit;
    elif [ -f "${ROFI_FB_CUR_DIR}" ]
    then
        if [[ "${ROFI_FB_NO_HISTORY}" -ne 1 ]]
        then
            # Append selected entry to history and remove exceeding entries
            sed -i "s|${ROFI_FB_CUR_DIR}|##deleted##|g" "${ROFI_FB_HISTORY_FILE}"
            sed -i '/##deleted##/d' "${ROFI_FB_HISTORY_FILE}"
            echo "${ROFI_FB_CUR_DIR}" >> "${ROFI_FB_HISTORY_FILE}"
            if [ $( wc -l < "${ROFI_FB_HISTORY_FILE}" ) -gt ${ROFI_FB_HISTORY_MAXCOUNT} ]
            then
                sed -i 1d "${ROFI_FB_HISTORY_FILE}"
            fi
        fi
        # Open the selected entry with $ROFI_FB_GENERIC_FO
        coproc ( "${ROFI_FB_GENERIC_FO}" "${ROFI_FB_CUR_DIR}"  > /dev/null  2>&1 )
        if [ -d "${ROFI_FB_START_DIR}" ]
        then
            echo "${ROFI_FB_START_DIR}" > "${ROFI_FB_PREV_LOC_FILE}"
        fi
        exit;
    fi
    exit;
fi

# Process current dir.
if [ -n "${ROFI_FB_CUR_DIR}" ]
then
    ROFI_FB_CUR_DIR=$(readlink -e "${ROFI_FB_CUR_DIR}")
    echo "${ROFI_FB_CUR_DIR}" > "${ROFI_FB_PREV_LOC_FILE}"
    pushd "${ROFI_FB_CUR_DIR}" >/dev/null
fi

# Output to rofi
if [[ "${ROFI_FB_NO_HISTORY}" -ne 1 ]]
then
    tac "${ROFI_FB_HISTORY_FILE}" | grep "${ROFI_FB_CUR_DIR}"
fi
echo ".."
ls -a
# vim:sw=4:ts=4:et:
