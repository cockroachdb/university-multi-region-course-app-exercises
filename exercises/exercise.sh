#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

function help {
    echo "This command will initialize your selected exercise by copying"
    echo " the previous exercise code into the current exercise directory."
    echo ""
    echo "USAGE: <command> <exercise number>"
    echo ""
    echo "<command> stage  - load your previous exercise code into the chosen exercise folder. "
    echo "<command> solve -  load the solution to the chosen exercise into the current exercise folder. "
    echo "<exercise number>  Use the Exercise numbers (eg. 01) to select the exercise."
    echo "WARNING:           RUNNING THIS COMMAND WILL OVERWRITE ANY CODE OR TESTS THE SELECTED EXERCISE. "
    echo "       :           IF YOU HAVE MADE CHANGES TO THE CODE OR TESTS, YOU WILL LOSE THEM."

}
# default the args to blank strings ${1:-} so they are not interpreted as unbound variables
if [[ -z ${1:-} || -z ${2:-} ]]; 
then
  help
  exit 0
else
  COMMAND=$1
  SELECTED_EXERCISE=$2
fi

EXERCISE_CODE=(
    "movr/rides/data"
    "movr/users/data"
    "movr/vehicles/data"
)

CURRENT_EXERCISE_FOLDER=$(find . -maxdepth 1 -type d -name "*$SELECTED_EXERCISE*" -print -quit)

function load_exercise {
    PREVIOUS_EXERCISE=$(($SELECTED_EXERCISE-1))
    if (("$PREVIOUS_EXERCISE" < "1"))
    then 
        PREVIOUS_EXERCISE="00"
    fi
    PREVIOUS_EXERCISE_FOLDER=$(find . -maxdepth 1 -type d -name "*$PREVIOUS_EXERCISE*" -print -quit)

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
        echo "Copying your code from $PREVIOUS_EXERCISE_CODE to current exercise: $CURRENT_EXERCISE_CODE"
        cp -rf $PREVIOUS_EXERCISE_CODE/* $CURRENT_EXERCISE_CODE
    done
}

function load_solution {
    SOLUTION_FOLDER=solutions
    EXERCISE_FOLDER=$(find $SOLUTION_FOLDER -maxdepth 1 -type d -name "*$SELECTED_EXERCISE*" -print -quit)

    for folder in ${EXERCISE_CODE[@]};
    do
        SOLUTION=$EXERCISE_FOLDER/$folder
        EXERCISE=$CURRENT_EXERCISE_FOLDER/$folder
        
        echo "Pulling Solution from $SOLUTION to $EXERCISE"

        if [ ! -d $SOLUTION ]
        then
            echo "WARNING: Unable to find tests for in the requested folder: $SOLUTION...skipping"
        fi
    
        cp -rf $SOLUTION/* $EXERCISE
    done
}

if [ "$COMMAND" = "stage" ]; then
    echo "staging exercise $SELECTED_EXERCISE"
    load_exercise
elif [ "$COMMAND" = "solve" ]; then
    echo "loading solution $SELECTED_EXERCISE"
    load_solution
elif [ "$COMMAND" = "help"]; then
    help
else
    echo "INVALID COMMAND: $COMMAND $SELECTED_EXERCISE"
    help
    exit 1
fi