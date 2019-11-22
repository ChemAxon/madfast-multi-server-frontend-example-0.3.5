#!/bin/bash

SRV1_PORT=18085
SRV2_PORT=18086
SRV3_PORT=18087
SRV3_PORT=18088


# See https://stackoverflow.com/questions/2924422/how-do-i-determine-if-a-web-page-exists-with-shell-scripting

if curl --output /dev/null --silent --head --fail "http://localhost:$SRV1_PORT" ; then
    echo "Server 1 alive (on port $SRV1_PORT)"
else
    echo "Server 1 not available"
fi

if curl --output /dev/null --silent --head --fail "http://localhost:$SRV2_PORT" ; then
    echo "Server 2 alive (on port $SRV2_PORT)"
else
    echo "Server 2 not available"
fi

if curl --output /dev/null --silent --head --fail "http://localhost:$SRV3_PORT" ; then
    echo "Server 3 alive (on port $SRV3_PORT)"
else
    echo "Server 3 not available"
fi

if curl --output /dev/null --silent --head --fail "http://localhost:$SRV4_PORT" ; then
    echo "Server 4 alive (on port $SRV4_PORT)"
else
    echo "Server 4 not available"
fi
