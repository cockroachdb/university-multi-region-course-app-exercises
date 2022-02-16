#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function help {
    echo "This command will build the student package for the course."
    echo ""
    echo "USAGE: build_slides.sh <source> <destination>"
    echo ""
    echo "<source>       The source directory for the slides."
    echo "<destination>  The destination directory for the slides (Will be created if necessary)."
}


SOURCE_DIR=${1:-}
DESTINATION_DIR=${2:-}

if [ -z $SOURCE_DIR ] || [ -z $DESTINATION_DIR ]
then
    help
    exit 2
fi

SOURCE_FILES=$(ls $SOURCE_DIR/[0-9]*.md)

echo "CREATING $DESTINATION_DIR"
mkdir -p $DESTINATION_DIR

cp -r $SOURCE_DIR/ $DESTINATION_DIR/

for FILE in $SOURCE_FILES;
do
    echo "PROCESSING ${FILE##*/}"
    DESTINATION_FILE=$DESTINATION_DIR/${FILE##*/}
    # Delete everything between the /script...script/ and /animation...animation/ tags.
    sed '/\/script/,/script\//d' $FILE | sed '/\/animations/,/animations\//d' > $DESTINATION_FILE
done