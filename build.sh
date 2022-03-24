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
    echo "  clean - Delete the target folder."
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

# Delete the target folder.
function clean {
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo CLEANING TARGET FOLDER
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    rm -rf target/*
}

# Determine which command is being requested, and execute it.
if [ "$COMMAND" = "verify" ]; then
    # verify_all_exercises
    # this tests the movr application but not the SQL exercises
    # this needs another look for testing the SQL exercises 
    # as many are multi-region settings and not standard SQL to test
    run_all_tests
elif [ "$COMMAND" = "clean" ]; then
    clean
elif [ "$COMMAND" = "help" ]; then
    help
else
    echo "INVALID COMMAND: $COMMAND"
    help
    exit 1
fi