#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function help {
    echo "This command will extract the contents from the units of an EdX backup file."
    echo ""
    echo "USAGE: extract_units.sh <source> <destination>"
    echo ""
    echo "<source>       The source tar.gz for the course."
    echo "<destination>  The destination directory for the html (must be created first)."
}

SOURCE_FILE=${1:-}
DESTINATION_DIR=${2:-}

if [ -z $SOURCE_FILE ] || [ -z $DESTINATION_DIR ]
then
    help
    exit 2
fi

if [ ! -f $SOURCE_FILE ]
then
    echo "The source file ($SOURCE_FILE) does not exist."
    exit 2
fi

if [ -d $DESTINATION_DIR ]
then
    echo "The destination folder ($DESTINATION_DIR) already exists."
    exit 2
fi

EXTRACTED_DIR=$DESTINATION_DIR/extracted
UNIT_SOURCE_DIR=$DESTINATION_DIR/extracted/course/vertical
HTML_SOURCE_DIR=$DESTINATION_DIR/extracted/course/html
PROBLEM_SOURCE_DIR=$DESTINATION_DIR/extracted/course/problem
VIDEO_SOURCE_DIR=$DESTINATION_DIR/extracted/course/video

function processUnits {
    echo "--------------------------"
    echo "PROCESSING ALL UNITS"
    echo "--------------------------"

    mkdir -p $EXTRACTED_DIR

    echo "EXTRACTING $SOURCE_FILE"

    tar -xzf $SOURCE_FILE -C $EXTRACTED_DIR 

    UNIT_FILES=$(ls $UNIT_SOURCE_DIR/*.xml)

    for FILE in $UNIT_FILES;
    do
        processUnit $FILE
    done;

    rm -rf $EXTRACTED_DIR
}

function processUnit {
    UNIT_FILE=$1
    DISPLAY_NAME=$(xmllint -xpath 'string(//vertical/@display_name)' $FILE | sed -e 's/[^A-Za-z0-9._-]/_/g')

    echo "--------------------------"
    echo "PROCESSING UNIT $DISPLAY_NAME"
    echo "--------------------------"

    UNIT_DESTINATION_DIR=$DESTINATION_DIR/units/$DISPLAY_NAME
    
    HTML_COUNT=$(xmllint --xpath 'count(//vertical/html)' $FILE)

    for (( i=1; i <= $HTML_COUNT; i++ )); do
        HTML_URL_NAME=$(xmllint -xpath "string(//vertical/html[$i]/@url_name)" $FILE)
        processHTML $HTML_SOURCE_DIR/$HTML_URL_NAME.html $UNIT_DESTINATION_DIR
    done

    PROBLEM_COUNT=$(xmllint --xpath 'count(//vertical/problem)' $FILE)

    for (( i=1; i <= $PROBLEM_COUNT; i++ )); do
        PROBLEM_URL_NAME=$(xmllint -xpath "string(//vertical/problem[$i]/@url_name)" $FILE)
        processProblem $PROBLEM_SOURCE_DIR/$PROBLEM_URL_NAME.xml $UNIT_DESTINATION_DIR
    done

    VIDEO_COUNT=$(xmllint --xpath 'count(//vertical/video)' $FILE)

    for (( i=1; i <= $VIDEO_COUNT; i++ )); do
        VIDEO_URL_NAME=$(xmllint -xpath "string(//vertical/video[$i]/@url_name)" $FILE)
        processVideo $VIDEO_SOURCE_DIR/$VIDEO_URL_NAME.xml $UNIT_DESTINATION_DIR
    done
}

function processHTML {
    HTML_FILE=$1
    HTML_DESTINATION_DIR=$2
    XML_FILE=${HTML_FILE%.html}.xml
    DISPLAY_NAME=$(xmllint -xpath 'string(//html/@display_name)' $XML_FILE | sed -e 's/[^A-Za-z0-9._-]/_/g')

    echo "PROCESSING HTML ($DISPLAY_NAME) FROM $HTML_FILE"

    mkdir -p $HTML_DESTINATION_DIR

    BASE_NAME=${XML_FILE##*/}
    SECTION_ID=${BASE_NAME%.xml}
    DESTINATION_FILE=$HTML_DESTINATION_DIR/${DISPLAY_NAME}_${SECTION_ID}.html
    cp $HTML_FILE $DESTINATION_FILE
}

function processProblem {
    PROBLEM_FILE=$1
    PROBLEM_DESTINATION_DIR=$2
    DISPLAY_NAME=$(xmllint -xpath 'string(//problem/@display_name)' $PROBLEM_FILE | sed -e 's/[^A-Za-z0-9._-]/_/g')

    echo "PROCESSING XML PROBLEM ($DISPLAY_NAME) FROM $PROBLEM_FILE"

    mkdir -p $PROBLEM_DESTINATION_DIR

    BASE_NAME=${PROBLEM_FILE##*/}
    SECTION_ID=${BASE_NAME%.xml}
    DESTINATION_FILE=$PROBLEM_DESTINATION_DIR/${DISPLAY_NAME}_${SECTION_ID}.xml
    cp $PROBLEM_FILE $DESTINATION_FILE

    MARKDOWN=$(xmllint -xpath 'string(//problem/@markdown)' $PROBLEM_FILE)

    if [ ! -z "$MARKDOWN" ] && [[ "$MARKDOWN" != "null" ]]
    then
        echo "EXTRACTING MARKDOWN PROBLEM ($DISPLAY_NAME) FROM $PROBLEM_FILE"
    
        MARKDOWN_FILE=$PROBLEM_DESTINATION_DIR/${DISPLAY_NAME}_${SECTION_ID}.md
        urldecode $MARKDOWN | sed s/\&\#10\;/\\n/g > $MARKDOWN_FILE
    fi
}

function processVideo {
    VIDEO_FILE=$1
    VIDEO_DESTINATION_DIR=$2
    DISPLAY_NAME=$(xmllint -xpath 'string(//video/@display_name)' $VIDEO_FILE | sed -e 's/[^A-Za-z0-9._-]/_/g')

    echo "PROCESSING VIDEO ($DISPLAY_NAME) FROM $VIDEO_FILE"

    mkdir -p $VIDEO_DESTINATION_DIR
      
    BASE_NAME=${VIDEO_FILE##*/}
    SECTION_ID=${BASE_NAME%.xml}
    DESTINATION_FILE=$VIDEO_DESTINATION_DIR/${DISPLAY_NAME}_${SECTION_ID}.xml
    cp $VIDEO_FILE $DESTINATION_FILE
}

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

processUnits