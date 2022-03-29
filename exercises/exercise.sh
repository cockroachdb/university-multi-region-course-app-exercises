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

# if you try to load exercise 0 without this, exercise 6 is loaded instead
if (("$SELECTED_EXERCISE" < "1"))
    then 
        SELECTED_EXERCISE="00"
fi

EXERCISE_CODE=(
    "movr/cockroach"
    "movr/rides/data"
    "movr/users/data"
    "movr/vehicles/data"
    "movr/pricing/data"
)

CURRENT_EXERCISE_FOLDER=$(find . -maxdepth 1 -type d -name "*$SELECTED_EXERCISE*" -print -quit)


# cockroach ./run.sh script can change between exercises and should be loaded prior to starting the exercise
function load_exercise {
    COCKROACH_FOLDER="movr/cockroach"
    SOLUTION_FOLDER=../solutions
    EXERCISE_FOLDER=$(find $SOLUTION_FOLDER -maxdepth 1 -type d -name "*$SELECTED_EXERCISE*" -print -quit)

    echo "Initializing cockroach folder from $EXERCISE_FOLDER"
    cp -rf $EXERCISE_FOLDER/$COCKROACH_FOLDER/* ./$COCKROACH_FOLDER
}

function load_solution {
    SOLUTION_FOLDER=../solutions
    EXERCISE_FOLDER=$(find $SOLUTION_FOLDER -maxdepth 1 -type d -name "*$SELECTED_EXERCISE*" -print -quit)

    for folder in ${EXERCISE_CODE[@]};
    do
        SOLUTION=$EXERCISE_FOLDER/$folder
        EXERCISE=./$folder
        
        echo "Pulling Solution from $SOLUTION to $EXERCISE"

        if [ ! -d $SOLUTION ]
        then
            echo "WARNING: Unable to find a solution in the requested folder: $SOLUTION...skipping"
        fi
    
        cp -rf $SOLUTION/* $EXERCISE
    done
}

if [ "$COMMAND" = "load" ]; then
    echo "load exercise $SELECTED_EXERCISE"
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