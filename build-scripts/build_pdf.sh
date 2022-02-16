#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function help {
    echo "This command will build PDFs for the slides."
    echo "It will build a single PDF for each chapter in the slides (Each Markdown File)."
    echo "It will also build a single PDF containing all of the slides."
    echo "It uses Decktape to process the files and will require you to install it first."
    echo "NOTE: It will take several minutes to build all of the PDFs."
    echo ""
    echo "USAGE: build_pdf.sh <source> <destination>"
    echo ""
    echo "<source>       The source directory for the slides."
    echo "<destination>  The destination directory for the pdfs (Will be created if necessary)."
}

function check_for_decktape() {
    if ! command -v decktape &> /dev/null
    then
        echo "---------------------------------------"
        echo "ERROR: DECKTAPE NOT INSTALLED"
        echo "---------------------------------------"
        echo "TO INSTALL DECKTAPE ON MAC"
        echo "> brew install node"
        echo "> npm install -g decktape"
        exit 1
    fi
}

function start_server() {
    echo "---------------------------------------"
    echo "EXECUTING REVEAL.JS PRESENTATION FROM $SOURCE_DIR/run.sh"
    echo "---------------------------------------" 

    trap 'terminate_server' EXIT
    WORKING_DIR=$(pwd)
    cd $SOURCE_DIR
    ./run.sh > /dev/null & 
    cd $WORKING_DIR

    while ! curl http://localhost:8001 &> /dev/null
    do
        echo "WAITING FOR HTTP SERVER"
        sleep 1
    done
}

function terminate_server() {
    echo ""
    echo "---------------------------------------" 
    echo "TERMINATING HTTP SERVER"
    echo "---------------------------------------" 
    PID=$(pgrep http-server || true)
    if [ -z $PID ]
    then
        echo "SERVER IS NOT RUNNING"
    else
        kill $PID
        echo "TERMINATED: $PID"
    fi
}

function process_individual_files() {
    echo "---------------------------------------"
    echo "BUILDING INDIVIDUAL PDFS FOR EACH SECTION"
    echo "---------------------------------------"

    SOURCE_FILES=$(ls $SOURCE_DIR/[0-9]*.md)
    FIRST_PAGE=1

    mkdir -p $DESTINATION_DIR

    for FILE in $SOURCE_FILES;
    do
        BASENAME=${FILE##*/}
        DEST_FILE=$DESTINATION_DIR/${BASENAME%.*}.pdf

        echo "---------------------------------------"
        echo "BUILDING $FILE to $DEST_FILE"
        echo "---------------------------------------"

        LAST_PAGE=$(($(cat $FILE | grep -o -- '^---$' | wc -l) + $FIRST_PAGE))

        decktape reveal --size='1920x1080' --slides $FIRST_PAGE-$LAST_PAGE --load-pause 1000 "$URL" "$DEST_FILE"

        FIRST_PAGE=$((LAST_PAGE + 1))
    done
}

function process_full_deck() {
    echo "---------------------------------------"
    echo "BUILDING FULL SLIDE DECK to $DESTINATION_DIR/slides.pdf"
    echo "---------------------------------------"

    decktape reveal --size='1920x1080' --load-pause 1000 "$URL" "$DESTINATION_DIR/slides.pdf"
}

SOURCE_DIR=${1:-}
DESTINATION_DIR=${2:-}
URL="http://localhost:8001"

if [ -z $SOURCE_DIR ] || [ -z $DESTINATION_DIR ]
then
    help
    exit 2
fi

check_for_decktape
start_server
process_individual_files
process_full_deck