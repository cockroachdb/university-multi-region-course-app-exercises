#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function help {
    echo "This command will build the student package for the course."
    echo ""
    echo "USAGE: build_student_package.sh <package_name> <source> <destination>"
    echo ""
    echo "<package_name>     The name of the student package (will be used in the archive name)"
    echo "<source>           The root exercises folder."
    echo "<destination>      The folder to build the exercises in."
}

PACKAGE_NAME=${1:-}
SOURCE_FOLDER=${2:-}
DESTINATION_FOLDER=${3:-}

if [ -z $PACKAGE_NAME ] || [ -z $SOURCE_FOLDER ] || [ -z $DESTINATION_FOLDER ]
then
    help
    exit 0
fi

PACKAGE_FOLDER=$DESTINATION_FOLDER/$PACKAGE_NAME

EXERCISES=($(ls $SOURCE_FOLDER | grep '^[0-9]' | sort))
INITIAL_STATE=${EXERCISES[0]}

echo "Building from $SOURCE_FOLDER to $PACKAGE_FOLDER"

if [ -d $PACKAGE_FOLDER ]
then
    echo "[WARNING] Detecting an existing folder at $PACKAGE_FOLDER. Was there an aborted build?"
    exit 0
fi

echo "Setting up"
mkdir -p $PACKAGE_FOLDER
mkdir -p $PACKAGE_FOLDER/solutions
mkdir -p $PACKAGE_FOLDER/exercises

echo "Building initial state from $INITIAL_STATE"
cp -r $SOURCE_FOLDER/$INITIAL_STATE/* $PACKAGE_FOLDER/exercises

for EXERCISE in ${EXERCISES[@]};
do
  echo "Building solution $EXERCISE"
  cp -r $SOURCE_FOLDER/$EXERCISE $PACKAGE_FOLDER/solutions
done

echo "Zipping"
WORKING=$PWD
cd $DESTINATION_FOLDER
zip -rq $PACKAGE_NAME.zip $PACKAGE_NAME/*
cd $WORKING

echo "Cleaning up"
rm -rf $PACKAGE_FOLDER

echo "Student package built at: $DESTINATION_FOLDER/$PACKAGE_NAME.zip"