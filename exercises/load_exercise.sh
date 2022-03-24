#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

function help {
    echo "This command will initialize your selected exercise by copying"
    echo " the previous exercise code into the current exercise directory."
    echo ""
    echo "USAGE: load_exercise.sh <exercise number>"
    echo ""
    echo "<exercise number> Use the Exercise numbers (eg. 01) to select the exercise."
    echo "WARNING:          RUNNING THIS COMMAND WILL OVERWRITE ANY CODE OR TESTS THE SELECTED EXERCISE. "
    echo "       :          IF YOU HAVE MADE CHANGES TO THE CODE OR TESTS, YOU WILL LOSE THEM."

}

if [ -z $1 ]
then
  help
  exit 0
else
  SELECTED_EXERCISE=$1
  PREVIOUS_EXERCISE=$(($SELECTED_EXERCISE-1))
fi

EXERCISE_CODE=(
    "movr/rides/data"
    "movr/users/data"
    "movr/vehicles/data"
)

PREVIOUS_EXERCISE_FOLDER=$(find . -maxdepth 1 -type d -name "*$PREVIOUS_EXERCISE*" -print -quit)
CURRENT_EXERCISE_FOLDER=$(find . -maxdepth 1 -type d -name "*$SELECTED_EXERCISE*" -print -quit)

function test {
    if [ -z $PREVIOUS_EXERCISE_FOLDER ]
    then
        echo "Unable to find the requested exercise: $PREVIOUS_EXERCISE"
        help
        exit 0
    fi

    for folder in ${EXERCISE_CODE[@]};
    do
        PREVIOUS_EXERCISE_CODE=$PREVIOUS_EXERCISE_FOLDER/$folder
        CURRENT_EXERCISE_CODE=$CURRENT_EXERCISE_FOLDER/$folder
        echo "Loading your $PREVIOUS_EXERCISE_CODE code to current exercise: $CURRENT_EXERCISE_CODE"
        cp -rf $PREVIOUS_EXERCISE_CODE/* $CURRENT_EXERCISE_CODE
    done
}

test