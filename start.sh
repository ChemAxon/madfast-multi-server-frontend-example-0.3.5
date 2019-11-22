#!/bin/bash

echo
echo
echo
echo "======================================================================="
echo
echo "IMPORTANT! Make sure file \"additional/data/servers-info.json\" is filled"
echo "with proper server URLs."
echo
echo "======================================================================="
echo
echo

APP_HOME=./madfast-cli-0.3.5/


SRV1_WORKDIR=./server-1
SRV2_WORKDIR=./server-2
SRV3_WORKDIR=./server-3
SRV4_WORKDIR=./server-4


SRV1_PORT=18085
SRV2_PORT=18086
SRV3_PORT=18087
SRV4_PORT=18088

SRV1_STOP_PORT=18100
SRV2_STOP_PORT=18101
SRV3_STOP_PORT=18102
SRV4_STOP_PORT=18103

STOPSECRET=stopme

# Send stop requests

echo "$STOPSECRET" | nc localhost $SRV1_STOP_PORT
echo "$STOPSECRET" | nc localhost $SRV2_STOP_PORT
echo "$STOPSECRET" | nc localhost $SRV3_STOP_PORT
echo "$STOPSECRET" | nc localhost $SRV4_STOP_PORT


# Launch servers

"$APP_HOME/bin/gui.sh" \
    -mols -name:antibiotics:-mms:$SRV1_WORKDIR/antibiotics-mms.bin:-mid:$SRV1_WORKDIR/antibiotics-id.bin \
    -desc -name:antibiotics-cfp7:-desc:$SRV1_WORKDIR/antibiotics-cfp7.bin:-mols:antibiotics \
    -mols -name:vitamins:-mms:$SRV1_WORKDIR/vitamins-mms.bin:-mid:$SRV1_WORKDIR/vitamins-id.bin \
    -desc -name:vitamins-cfp7:-desc:$SRV1_WORKDIR/vitamins-cfp7.bin:-mols:vitamins \
    -allowedOrigins "*,*" \
    -additionalresourcedir additional/ \
    -port $SRV1_PORT \
    -nobrowse \
    -stopport $SRV1_STOP_PORT \
    -stopsecret $STOPSECRET \
    -earlyStart >> $SRV1_WORKDIR/gui.log 2>&1 &


"$APP_HOME/bin/gui.sh" \
    -mols -name:pubchem1k:-mms:$SRV2_WORKDIR/pubchem1k-mms.bin:-mid:$SRV2_WORKDIR/pubchem1k-id.bin \
    -mols -name:essentials:-mms:$SRV2_WORKDIR/essentials-mms.bin:-mid:$SRV2_WORKDIR/essentials-id.bin \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow0 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow1 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow2 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow3 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow4 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow5 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow6 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow7 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow8 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slow9 \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowA \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowB \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowC \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowD \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowE \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowF \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowG \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowH \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowI \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowJ \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowK \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowL \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowM \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowN \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowO \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowP \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowQ \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowR \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowS \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowT \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowU \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowV \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowW \
    -mols -mms:$SRV2_WORKDIR/a.bin:-name:slowZ \
    -desc -name:pubchem1k-cfp7:-desc:$SRV2_WORKDIR/pubchem1k-cfp7.bin:-mols:pubchem1k \
    -desc -name:essentials-cfp7:-desc:$SRV2_WORKDIR/essentials-cfp7.bin:-mols:essentials \
    -allowedOrigins "*,*" \
    -additionalresourcedir additional/ \
    -port $SRV2_PORT \
    -nobrowse \
    -stopport $SRV2_STOP_PORT \
    -stopsecret $STOPSECRET \
    -earlyStart >> $SRV2_WORKDIR/gui.log 2>&1 &


"$APP_HOME/bin/gui.sh" \
    -mols -name:pubchem1k:-mms:$SRV3_WORKDIR/pubchem1k-mms.bin:-mid:$SRV3_WORKDIR/pubchem1k-id.bin \
    -mols -name:essentials:-mms:$SRV3_WORKDIR/essentials-mms.bin:-mid:$SRV3_WORKDIR/essentials-id.bin \
    -mols -mms:$SRV3_WORKDIR/a.bin:-name:slow0 \
    -mols -mms:$SRV3_WORKDIR/a.bin:-name:slow1 \
    -mols -mms:$SRV3_WORKDIR/a.bin:-name:slow2 \
    -mols -mms:$SRV3_WORKDIR/a.bin:-name:slow3 \
    -desc -name:pubchem1k-cfp7:-desc:$SRV3_WORKDIR/pubchem1k-cfp7.bin:-mols:pubchem1k \
    -desc -name:essentials-cfp7:-desc:$SRV3_WORKDIR/essentials-cfp7.bin:-mols:essentials \
    -allowedOrigins "*,*" \
    -additionalresourcedir additional/ \
    -port $SRV3_PORT \
    -nobrowse \
    -stopport $SRV3_STOP_PORT \
    -stopsecret $STOPSECRET \
    -earlyStart >> $SRV3_WORKDIR/gui.log 2>&1 &

"$APP_HOME/bin/gui.sh" \
    -mols -name:drugbank:-mms:$SRV4_WORKDIR/drugbank-mms.bin:-mid:$SRV4_WORKDIR/drugbank-id.bin \
    -desc -name:drugbank-cfp7:-desc:$SRV4_WORKDIR/drugbank-cfp7.bin:-mols:drugbank \
    -allowedOrigins "*,*" \
    -additionalresourcedir additional/ \
    -port $SRV4_PORT \
    -nobrowse \
    -stopport $SRV4_STOP_PORT \
    -stopsecret $STOPSECRET \
    -earlyStart >> $SRV4_WORKDIR/gui.log 2>&1 &

echo "Launch request sent to all servers"
echo