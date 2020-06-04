#!/bin/bash

USAGE="$0 [-s|--status] [-a|--audio] [-v|--video] files
$0 -h|--help
Arguments:
\t-h|--help\tdisplay this help
\t-s|--status\tdisplay each files encoding
\t-a|--audio\tConvert each files's audio to a proper encoding
\t-v|--video\tConvert each files's video to a proper encoding
\t-b|--both\tConvert each files's audio and video to a proper encoding
"

# OPTS="-threads 8"

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -s|--status)
        STATUS=YES
        shift # past argument
        ;;
        -a|--audio)
        OPTS="$OPTS  -c:a aac"
        shift # past argument
        ;;
        -v|--video)
        OPTS="$OPTS  -c:v libx264"
        shift # past argument
        ;;
        -b|--both)
        OPTS="$OPTS  -c:a aac"
        OPTS="$OPTS  -c:v libx264"
        shift # past argument
        ;;
        -h|--help)
        printf "$USAGE"
        exit 1
        shift # past argument
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

if [ 0 -eq ${#POSITIONAL[@]} ]; then
    printf "$USAGE"
    exit 1
fi

for FILE in "${POSITIONAL[@]}"
do
    if [ -n "$STATUS" ]; then
         mkvmerge --identify "$FILE"
         continue
    fi
    ffmpeg -i "$FILE" $OPTS "$FILE.mp4"
done
