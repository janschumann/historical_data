#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

# fetch host port
PORT=$($BASE_DIR/es/es_port.sh)
if [ -z "$PORT" ]; then
    echo "Please ensure standard-5x-ubuntu-1604 docker container is running (kitchen converge)"
    echo "Running containers:"
    docker container list
    exit 1
fi
echo "ES is running at localhost:$PORT"

# remove existing index if exists
EXISTS=$(curl --head -s -o /dev/null -w "%{http_code}" localhost:$PORT/historical_data?pretty)
if [ "$EXISTS" == "200" ]; then
    echo "Removing existing index ..."
    curl -X DELETE localhost:$PORT/historical_data
fi
echo
echo "Creating new index ..."
cd $BASE_DIR/es/queries
curl -X PUT "localhost:$PORT/historical_data?pretty" -H 'Content-Type: application/json' -d @mappings.json

echo
echo "Inserting data ..."
cd $BASE_DIR/es/data
for f in $(ls *.json); do
    echo "Creating data/$f"
    curl -X POST "localhost:$PORT/historical_data/doc/?pretty&pretty" -H 'Content-Type: application/json' -d @$f
done

echo "Done."

exit 0
