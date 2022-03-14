#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

MICROSERVICES=("rides" "users" "vehicles" "ui_gateway")
COMMAND=${1:-"help"}

function help {
    echo "Use this script to start or stop the services required to run the "
    echo "MovR application."
    echo ""
    echo "USAGE: run_movr.sh command <args>"
    echo ""
    echo "Commands:"
    echo "  start - Start all microservices and kafka."
    echo "  stop - Stop all microservices and kafka."
    echo "  help - print this text."
}

# Build an executable jar for a specific exercise.
function package_service_jars {
    local WORKING=$(pwd)
    echo "working in directory $WORKING"

    # Each service jar will be built separately
    for service in "${MICROSERVICES[@]}"
    do
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "CREATING JAR FOR $service"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        cd $service
         ../../../mvnw clean package -DskipTests spring-boot:repackage 
        cd $WORKING
    done
}

function start_kafka {
    docker-compose start kafka
}

function stop_kafka {
    docker-compose stop kafka
    docker-compose stop zookeeper
}

function start_services {
     local WORKING=$(pwd)

    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "STARTING Kafka"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    start_kafka

    package_service_jars

    >running_services.txt

    # Each service jar will be built separately
    for service in "${MICROSERVICES[@]}"
    do
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "STARTING $service"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        cd $service
            java -jar target/movr-$service-api-0.0.1-SNAPSHOT.jar > /dev/null &
            echo "$!" >> ../running_services.txt
        cd $WORKING
    done
    
}

function stop_services {
    input="running_services.txt"
    while IFS= read -r line
    do
        kill -9 "$line"
    done < "$input"

    stop_kafka

}

if [ "$COMMAND" = "start" ]; then
    start_services
elif [ "$COMMAND" = "stop" ]; then
    stop_services
elif [ "$COMMAND" = "help"]; then
    help
else
    echo "INVALID COMMAND: $COMMAND"
    help
    exit 1
fi

