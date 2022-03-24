@echo off
:: delayed expansion is needed to enable the !variable! syntax. https://ss64.com/nt/delayedexpansion.html
setlocal enabledelayedexpansion
SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0

set COMMAND=%1
set SELECTED_EXERCISE=%2
set /A previous_exercise=%SELECTED_EXERCISE%-1

set SUB_FOLDERS=movr\rides\data movr\vehicles\data movr\users\data 

:help
    echo This command will copy the provided solutions into your exercises directory.
    echo USAGE: "command" "exercise number"
    echo "<command> - stage" load your previous exercise code into the chosen exercise folder.
    echo "<command> - solve" load the solution to the chosen exercise into the current exercise folder.             
    echo "exercise number"   Use the Exercise numbers (eg. 01) to select the exercise.
    echo WARNING:            RUNNING THIS COMMAND WILL OVERWRITE YOUR CODE. MAKE SURE YOU ACTUALLY WANT TO DO THAT.
EXIT /B 0

if [%SELECTED_EXERCISE%]==[] || [%COMMAND%]==[] (
    CALL :help
    EXIT /B 1
) ELSE (
    for /f %%i in ('dir %cd%\* /b ^| findstr %EXERCISE%') do (
        set current_exercise_folder=\%%i
    )

    if "%COMMAND%"=="stage" goto load_exercise
    if "%COMMAND%"=="solve" goto load_solution
    goto :help
)

:load_exercise
    for /f %%i in ('dir %cd%\* /b ^| findstr %previous_exercise%') do (
        set PREVIOUS_EXERCISE_FOLDER=%cd%\%%i
    )

    if [!current_exercise_folder!]==[] (
        echo Unable to find a solution for the requested exercise: %EXERCISE%
        echo USAGE: solve "exercise number (example 01, 02, etc)"
    exit /B 1
    )

    for %%f in (%SUB_FOLDERS%) do (
        set PREVIOUS_EXERCISE_CODE=!PREVIOUS_EXERCISE_FOLDER!\%%f
        set CURRENT_EXERCISE_CODE=!current_exercise_folder!\%%f

        echo Loading code from !PREVIOUS_EXERCISE_CODE! to !CURRENT_EXERCISE_CODE!

        if not exist !PREVIOUS_EXERCISE_CODE!\ (
        echo WARNING: Unable to find SQL in the requested folder: !PREVIOUS_EXERCISE_CODE!...skipping
        )

        rmdir /s/q !EXERCISE!
        if not exist !EXERCISE! mkdir !EXERCISE!
        xcopy /s/q !SOLUTION!\* !EXERCISE!\ 1>NUL
    )
EXIT /B 0

:load_solution
    set SOLUTION_FOLDER=solutions

    for /f %%i in ('dir %SOLUTION_FOLDER%\* /b ^| findstr %EXERCISE%') do (
        set EXERCISE_FOLDER=%SOLUTION_FOLDER%\%%i
    )

    if [!EXERCISE_FOLDER!]==[] (
        echo Unable to find a solution for the requested exercise: %EXERCISE%
        echo USAGE: solve "exercise number (example 01, 02, etc)"
    exit /B 1
    )

    for %%f in (%SUB_FOLDERS%) do (
        set SOLUTION=!EXERCISE_FOLDER!\%%f
        set EXERCISE=!current_exercise_folder!\%%f

        echo Loading Solution from !SOLUTION! to !EXERCISE!

        if not exist !SOLUTION!\ (
        echo WARNING: Unable to find tests in the requested folder: !SOLUTION!...skipping
        )

        rmdir /s/q !EXERCISE!
        if not exist !EXERCISE! mkdir !EXERCISE!
        xcopy /s/q !SOLUTION!\* !EXERCISE!\ 1>NUL
    )
EXIT /B 0