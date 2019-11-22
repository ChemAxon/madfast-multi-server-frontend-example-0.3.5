#!/bin/bash

SRV1_STOP_PORT=18100
SRV2_STOP_PORT=18101
SRV3_STOP_PORT=18102
SRV4_STOP_PORT=18103

STOPSECRET=stopme

echo "$STOPSECRET" | nc localhost $SRV1_STOP_PORT
echo "$STOPSECRET" | nc localhost $SRV2_STOP_PORT
echo "$STOPSECRET" | nc localhost $SRV3_STOP_PORT
echo "$STOPSECRET" | nc localhost $SRV4_STOP_PORT

echo "Stop requests sent to all servers"