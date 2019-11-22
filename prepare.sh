#!/bin/bash
#
# MadFast multi server example
#
#

set -e # Die on nonzero return status
set -u # Die on unset variables
set -o pipefail # We invoke commands in pipes in order to "tee" their outputs to logs.

# Files, locations -----------------------------------------------------------------------------------------------------------------------------------
# Make sure MadFast CLI distribution 0.3.5 is unpacked or linked here
APP_HOME=./madfast-cli-0.3.5/

# Example small molecule sets shipped with MadFast distribution
VITAMINS_SMI_GZ="$APP_HOME/data/molecules/vitamins/vitamins.smi.gz"
ANTIBIOTICS_SMI_GZ="$APP_HOME/data/molecules/antibiotics/antibiotics.smi.gz"
PUBCHEM1K_SDF_GZ="$APP_HOME/data/molecules/pubchem-compound/pubchem-compound-rnd-1k.sdf.gz"
DRUGBANK_SMI_GZ="$APP_HOME/data/molecules/drugbank/drugbank-common_name.smi.gz"
ESSENTIALS_SMI_GZ="$APP_HOME/data/molecules/who-essential-medicines/who-essential-medicines.smi.gz"

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

if [ ! -d "$APP_HOME" ] ; then echo "Error! APP home \"$APP_HOME\" not found." ; exit -1 ; fi
if [ ! -f "$ANTIBIOTICS_SMI_GZ" ] ; then echo "ERROR! File \"$ANTIBIOTICS_SMI_GZ\" not found." ; exit -1 ; fi
if [ ! -f "$VITAMINS_SMI_GZ" ] ; then echo "ERROR! File \"$VITAMINS_SMI_GZ\" not found." ; exit -1 ; fi
if [ ! -f "$PUBCHEM1K_SDF_GZ" ] ; then echo "ERROR! File \"$PUBCHEM1K_SDF_GZ\" not found." ; exit -1 ; fi
if [ ! -f "$DRUGBANK_SMI_GZ" ] ; then echo "ERROR! File \"$DRUGBANK_SMI_GZ\" not found." ; exit -1 ; fi
if [ ! -f "$ESSENTIALS_SMI_GZ" ] ; then echo "ERROR! File \"$ESSENTIALS_SMI_GZ\" not found." ; exit -1 ; fi

# Prepare binary storages when needed ----------------------------------------------------------------------------------------------------------------
# 
# For detais see https://disco.chemaxon.com/products/madfast/latest/doc/rest-api-example.html

if [ ! -d "$SRV1_WORKDIR" ] ; then
    mkdir -p "$SRV1_WORKDIR"
    "${APP_HOME}/bin/createMms.sh" -in "$ANTIBIOTICS_SMI_GZ" -out "$SRV1_WORKDIR/antibiotics-mms.bin" -name  "$SRV1_WORKDIR/antibiotics-id.bin"
    "${APP_HOME}/bin/buildStorage.sh" -in "$ANTIBIOTICS_SMI_GZ" -out "$SRV1_WORKDIR/antibiotics-cfp7.bin" -context createSimpleCfp7Context
    "${APP_HOME}/bin/createMms.sh" -in "$VITAMINS_SMI_GZ" -out "$SRV1_WORKDIR/vitamins-mms.bin" -name  "$SRV1_WORKDIR/vitamins-id.bin"
    "${APP_HOME}/bin/buildStorage.sh" -in "$VITAMINS_SMI_GZ" -out "$SRV1_WORKDIR/vitamins-cfp7.bin" -context createSimpleCfp7Context
fi

if [ ! -d "$SRV2_WORKDIR" ] ; then
    mkdir -p "$SRV2_WORKDIR"
    "${APP_HOME}/bin/buildStorage.sh" -in "$ESSENTIALS_SMI_GZ" -out "$SRV2_WORKDIR/essentials-cfp7.bin" -context createSimpleCfp7Context
    "${APP_HOME}/bin/createMms.sh" -in "$ESSENTIALS_SMI_GZ" -out "$SRV2_WORKDIR/essentials-mms.bin" -name  "$SRV2_WORKDIR/essentials-id.bin"


    "${APP_HOME}/bin/buildStorage.sh" -in "$PUBCHEM1K_SDF_GZ" -out "$SRV2_WORKDIR/pubchem1k-cfp7.bin" -context createSimpleCfp7Context
    "${APP_HOME}/bin/createMms.sh" -in "$PUBCHEM1K_SDF_GZ" -out "$SRV2_WORKDIR/pubchem1k-mms.bin" -name  "$SRV2_WORKDIR/pubchem1k-id.bin"

    # Also create slowly loading resource
    # See https://disco.chemaxon.com/products/madfast/latest/doc/asynchronous-server-loading.html

    # Create the binary storage
    java -cp "${APP_HOME}/lib/classpath.jar" com.chemaxon.overlap.wui.SlowlyDeserializingMms > "$SRV2_WORKDIR/a.bin"


fi

if [ ! -d "$SRV3_WORKDIR" ] ; then
    mkdir -p "$SRV3_WORKDIR"
    "${APP_HOME}/bin/buildStorage.sh" -in "$ESSENTIALS_SMI_GZ" -out "$SRV3_WORKDIR/essentials-cfp7.bin" -context createSimpleCfp7Context
    "${APP_HOME}/bin/createMms.sh" -in "$ESSENTIALS_SMI_GZ" -out "$SRV3_WORKDIR/essentials-mms.bin" -name  "$SRV3_WORKDIR/essentials-id.bin"


    "${APP_HOME}/bin/buildStorage.sh" -in "$PUBCHEM1K_SDF_GZ" -out "$SRV3_WORKDIR/pubchem1k-cfp7.bin" -context createSimpleCfp7Context
    "${APP_HOME}/bin/createMms.sh" -in "$PUBCHEM1K_SDF_GZ" -out "$SRV3_WORKDIR/pubchem1k-mms.bin" -name  "$SRV3_WORKDIR/pubchem1k-id.bin"

    # Also create slowly loading resource
    # See https://disco.chemaxon.com/products/madfast/latest/doc/asynchronous-server-loading.html

    # Create the binary storage
    java -cp "${APP_HOME}/lib/classpath.jar" com.chemaxon.overlap.wui.SlowlyDeserializingMms > "$SRV3_WORKDIR/a.bin"


fi


if [ ! -d "$SRV4_WORKDIR" ] ; then
    mkdir -p "$SRV4_WORKDIR"
    "${APP_HOME}/bin/createMms.sh" -in "$DRUGBANK_SMI_GZ" -out "$SRV4_WORKDIR/drugbank-mms.bin" -name  "$SRV4_WORKDIR/drugbank-id.bin"
    "${APP_HOME}/bin/buildStorage.sh" -in "$DRUGBANK_SMI_GZ" -out "$SRV4_WORKDIR/drugbank-cfp7.bin" -context createSimpleCfp7Context
fi

echo
echo
echo "All preparation done"






