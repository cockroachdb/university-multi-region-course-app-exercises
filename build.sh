#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

COURSE_ID="my_course"
EXERCISE_FOLDER="exercises"
EXERCISES=($(ls $EXERCISE_FOLDER | grep '^[0-9]'))
MICROSERVICES=("movr/rides" "movr/users" "movr/vehicles" "movr/ui_gateway")
COMMAND=${1:-"help"}

function help {
    echo "This script is intended to contain the commands that can be executed to"
    echo "build various components for the course."
    echo "Custom logic for the individual course may be embedded in this script."
    echo "Re-usable logic should be put into scripts in the build-scripts folder."
    echo ""
    echo "USAGE: build.sh command <args>"
    echo ""
    echo "Commands:"
    echo "  verify - Run all tests for all exercises."
    echo "  package - build the student archive to the target folder."
    echo "  slides - build the Reveal.js slides."
    echo "  pdfs - build individual pdfs for the slide sections."
    echo "  transcripts - build the video transcripts."
    echo "  extract <archive> [--force | -f] - Extract an EdX backup archive and copy all units into the edx folder. Note: Specifying '--force' or '-f' will delete the existing directory first."
    echo "  help - print this text."
}

# Loop through each exercise and execute the tests.
function verify_all_exercises {    
    local WORKING=$(pwd)

    for exercise in "${EXERCISES[@]}"
    do
        echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        echo VERIFYING EXERCISE $exercise
        echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        cd $EXERCISE_FOLDER/$exercise
        run_all_tests
        cd $WORKING
    
    done
}

# Execute the tests for a specific exercise.
function run_all_tests {
    local WORKING=$(pwd)

    # NOTE This is custom logic. This course has multiple microservices and so we need to
    # execute the tests for each service individually.
    for service in "${MICROSERVICES[@]}"
    do
        echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        echo RUNNING TESTS FOR $service
        echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        cd $service
        ./mvnw clean test
        cd $WORKING
    done
}

# Build the downloadable Zip that the students will use when setting up their course.
# This Zip will ideally contain all of the files the students need.
function build_student_package {
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo PACKAGING STUDENT REPO
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ./build-scripts/build_student_package.sh $COURSE_ID exercises target
}

# Build the Reveal.js presentation slides.
# The raw slides contain additional data that is unnecessary for a presentation.
# Eg. Scripts and Animations
# This will strip out the unnecessary parts and leave behind the basic presentation.
function build_slides {
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo BUILDING SLIDES
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ./build-scripts/build_slides.sh slides target/slides
}

# Extract the Transcripts from the Reveal.js presentation
# This extracts everything in the /script script/ tags.
function build_transcripts {
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo BUILDING TRANSCRIPTS
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ./build-scripts/build_transcripts.sh slides target/transcripts
}

# Build PDF versions of the slides.
# It will build a PDF for each individual slide section.
# It will also build a final PDF that includes the entire presentation.
function build_pdfs {
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo BUILDING PDFS
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ./build-scripts/build_pdf.sh slides target/pdfs
}

# Delete the target folder.
function clean {
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo CLEANING TARGET FOLDER
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    rm -rf target/*
}

# Extract the HTML, XML, and Markdown from an EdX backup.
# This can be used to allow easier Diffs and PRs in Github.
# It also creates a folder which can be searched if we are looking for specific text.
function extract_edx_export {
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo EXTRACTING EDX CONTENT
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    archive=$1
    force=$2

    if [ -z $archive ]
    then
        echo "extract requires a path to the EdX archive."
        echo "  eg. ./build.sh extract <path_to_archive>"
        exit 1
    fi

    if [ "$force" = "--force" ] || [ "$force" = "-f" ]; then
        rm -rf edx
    fi

    ./build-scripts/extract_units.sh $archive edx
}

# Determine which command is being requested, and execute it.
if [ "$COMMAND" = "verify" ]; then
    verify_all_exercises
elif [ "$COMMAND" = "package" ]; then
    build_student_package
elif [ "$COMMAND" = "slides" ]; then
    build_slides
elif [ "$COMMAND" = "transcripts" ]; then
    build_transcripts
elif [ "$COMMAND" = "extract" ]; then
    extract_edx_export ${2:-""} ${3:-""}
elif [ "$COMMAND" = "pdfs" ]; then
    build_pdfs
elif [ "$COMMAND" = "clean" ]; then
    clean
elif [ "$COMMAND" = "help" ]; then
    help
else
    echo "INVALID COMMAND: $COMMAND"
    help
    exit 1
fi