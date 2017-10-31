#!/bin/bash

# script dir
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

# params
FILE=$1
USER_ID=$2
if [ -z $USER_ID ]; then
    # default user id
    USER_ID=1
fi

# fetch host port
PORT=$($BASE_DIR/es/es_port.sh)
if [ -z "$PORT" ]; then
    echo "Please ensure standard-5x-ubuntu-1604 docker container is running (kitchen converge)"
    echo "Running containers:"
    docker container list
    exit 1
fi

if [ -z $FILE ]; then
    echo "Fetching all historical_data/doc:"
    curl -X GET "localhost:$PORT/historical_data/doc/_search?pretty" -H 'Content-Type: application/json' -d "{}"
    exit 0
fi

echo "Fetching aggregated values using query template $FILE:"
# replace user id placeholder in query template $FILE
# and execute the query
sed "s/%USER_ID%/$USER_ID/" $FILE | curl -X GET "localhost:$PORT/historical_data/doc/_search?pretty" -H 'Content-Type: application/json' -d @-

exit 0
