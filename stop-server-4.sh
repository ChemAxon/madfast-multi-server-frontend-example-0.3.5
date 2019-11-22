#!/bin/bash

SRV4_STOP_PORT=18103

STOPSECRET=stopme

echo "$STOPSECRET" | nc localhost $SRV4_STOP_PORT

echo "Stop requests sent to server 4"