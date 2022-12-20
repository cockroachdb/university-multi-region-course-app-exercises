#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

function help {
    echo "This command will copy the provided setup files into your exercises directory."
    echo ""
    echo "USAGE: load_exercise.sh <search string>"
    echo ""
    echo "<search string>   A string that makes up all, or part, of the exercise name. Exercise numbers (eg. 01) are the simplest form of search."
    echo "WARNING:          RUNNING THIS COMMAND WILL OVERWRITE YOUR SQL FILES. YOU WILL LOSE ANY CHANGES YOU HAVE MADE CHANGES TO THE FILES."
}

EXERCISE=${1:-}

if [ -z $EXERCISE ]
then
    help
    exit 0
fi

SUB_FOLDERS=(
    "movr/cockroach"
    "movr/rides/data"
    "movr/vehicles/data"
    "movr/users/data"
    "movr/pricing/data"
)

SETUP_FOLDER=../setup

EXERCISE_FOLDER=$(find $SETUP_FOLDER -maxdepth 1 -type d -name "*$EXERCISE*" -print -quit)

if [ -z $EXERCISE_FOLDER ]
then
    echo "Unable to find a setup folder for the requested exercise: $EXERCISE"
    help
    exit 0
fi

for folder in ${SUB_FOLDERS[@]};
do
    SETUP=$EXERCISE_FOLDER/$folder
    EXERCISE=./$folder
    
    echo "Loading Tests from $SETUP to $EXERCISE"

    if [ ! -d $SETUP ]
    then
        echo "WARNING: Unable to find setup files in the requested folder: $SETUP...skipping"
    fi
  
    rm -rf $EXERCISE
    mkdir -p $EXERCISE
    cp -rp $SETUP/* $EXERCISE
done