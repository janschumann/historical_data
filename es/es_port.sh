#!/bin/bash

# fetch host port
PORT=$(docker container inspect $(docker container list | grep standard5xubuntu1604 | awk '{print $1}') | jq '.[0].NetworkSettings.Ports' | jq -r '.["9200/tcp"][].HostPort')
echo "$PORT"
if [ -z "$PORT" ]; then
    exit 1
fi
exit 0;
