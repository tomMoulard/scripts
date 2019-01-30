#!/bin/bash

# Call:
# ./template.sh <template folder> <dmenu number of lines> <preview lenght>

# Default values
# dmenu line number -> 10
# preview length -> 100

# What is?
# Uses dmenu to load some code sample in your clipboard using xclip

# Output:
# A dmenu list (dmenu -l) with a formating like:
# [CPP] Class   : "class TEMPLATE\n{..."
# [C]   Header  : "#ifndef TEMPLATE_..."
# [C]   Makefile: "CC = gcc\nCFLAGS ..."
# [SH]  script  : "#!/bin/bash\nCOUN..."

# Load templates from folder given as first argument
# Each file extention shall give the template format:
# CPP
#  - Class.cc
# C
#  - Header.c
#  - Makefile.c
# SH
#  - script.sh

DMENU_PROMT="template"
NUMBER_OF_LINE=10
PREVIEW_LENGHT=100
declare -A FIELDS
if [ "$2" != "" ];then
    NUMBER_OF_LINE=$2
fi
if [ "$3" != "" ];then
    PREVIEW_LENGHT=$3
fi

# load_file_preview <file> <file tag>
# store result in PREVIEW_FILE
load_file_preview (){
    PREVIEW_FILE="$(head -c $PREVIEW_LENGHT $1 | sed ':a;N;$!ba;s/\n/\\\\n/g')"
    PREVIEW_FILENAME=$(echo $1 | rev | cut -f 1 -d "/" | rev)
    PREVIEW_TAG="[$(echo $2 | rev | cut -f 1 -d "/" | rev)]"
    PREVIEW_FILENAME="$(echo $PREVIEW_FILENAME | cut -f 1 -d '.')"
    PREVIEW_FILE="${PREVIEW_TAG} ${PREVIEW_FILENAME}: '${PREVIEW_FILE}...'"
}

# build_folder_preview <folder>
# store string result in PREVIEW_FOLDER and array in FIELDS
build_folder_preview (){
    FIRST=1
    for FOLDER in $1/*; do
        for FILE in $FOLDER/*; do
            load_file_preview $FILE $FOLDER
            if [ $FIRST -eq 1 ];then
                PREVIEW_FOLDER="${PREVIEW_FILE}"
                FIRST=0
            else
                PREVIEW_FOLDER="${PREVIEW_FOLDER}\n${PREVIEW_FILE}"
            fi
            FIELDS["$FILE"]="$PREVIEW_FILE"
        done
    done
}

# copy_from_file <file>
# Store the content of the file in the cliboard
copy_from_file() {
    xclip -selection clipboard $1
}

build_folder_preview $1
QUERY_RESULT=$(echo -e "$PREVIEW_FOLDER" \
    | dmenu -l $NUMBER_OF_LINE -i -p $DMENU_PROMT     \
    | sed "s|[\\]|\\\\\\\\|g")
# Should use copy_from_file ${FIELDS["$KEY"]} and invert the key/value in the
# hash table
for KEY in ${!FIELDS[@]}; do
    if [ "${FIELDS["$KEY"]}" == "$QUERY_RESULT" ]; then
        copy_from_file $KEY
        exit 0;
    fi
done