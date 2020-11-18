#!/bin/bash

USAGE="$0 <output_file> video_files...
$0 -h|--help
Arguments:
\t-h|--help\tdisplay this help
"

# Get output file name
OUTPUT="$1"
if [[ "${OUTPUT}" == "" || "${OUTPUT}" == "-h" || "${OUTPUT}" == "--help" ]]; then
    printf "%s\n" "$USAGE"
    exit 1
fi

# Remove output file name from arg pool
shift

# Building file list
FILE_LIST_FILE=$(mktemp)
for FILE in "$@"; do
    printf "file '%s'\n" "${PWD}/${FILE}" >> "${FILE_LIST_FILE}"
done

# See https://trac.ffmpeg.org/wiki/Concatenate
ffmpeg -loglevel warning -f concat -safe 0 -i "${FILE_LIST_FILE}" -c copy "${OUTPUT}"

# Cleaning files
rm -fr "${FILE_LIST_FILE}"
