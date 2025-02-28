#!/bin/bash
# (c) Sebastian Bojanowski, HL7 Poland
# Script for generating runtime release based on DECOR project

. shared-functions.sh

SAXON_JAR="../saxon/saxon9he.jar"
DECOR2SCHEMATRON_XSLT="../decor-core-runtime/DECOR2schematron.xsl"

DECOR_FILE=$1
TARGET_PATH=$2
MODE="runtime"

if [[ $# -ne 2 ]]; then
     echo "Usage: create-runtime-release.sh [decor-file-path] [target-path]"
     echo "  Parameters:"
     echo "    - decor-file-path: path to DECOR specification XML file"
     echo "    - target-path: target path where generated artifacts should be placed"
     exit 1
fi

DECOR_BASE_FILE=$(basename "$DECOR_FILE")
DECOR_BASE_PATH=${DECOR_FILE%/*}
CONFIG_FILE="../decor-configuration/decor-parameters.${MODE}.xml"

if [ ! -f $DECOR_FILE ]; then
    echo "DECOR file $DECOR_FILE not found!"
    exit 1
fi

if [ ! -f $CONFIG_FILE ]; then
    echo "Configuration file $CONFIG_FILE not found!"
    exit 1
fi

if [ ! -f $SAXON_JAR ]; then
    echo "Saxon XSLT engine jar not found!"
    exit 1
fi

if [ ! -f $DECOR2SCHEMATRON_XSLT ]; then
    echo "Required ART-DECOR XSLT stylesheet not found: $SECOR2SCHEMATRON_XSLT"
    exit 1
fi

DECOR_PREFIX=$(xmllint --xpath "string(/decor/project/@prefix)" "$DECOR_FILE")

#Create directory for release files
init-directory "$TARGET_PATH"

#Copying configuration file
cp -rf "$CONFIG_FILE" "$DECOR_BASE_PATH/decor-parameters.xml"


#Perform transformation
java -jar "$SAXON_JAR" -xsl:"$DECOR2SCHEMATRON_XSLT" -s:"$DECOR_FILE" -o:"$TARGET_PATH/${DECOR_BASE_FILE%%.*}.out.${DECOR_BASE_FILE##*.}"

#Move files from generated directory to target path
mv "$TARGET_PATH/${DECOR_PREFIX}${MODE}"-develop/* $TARGET_PATH

#Remove unnecessary files and directories generated during XSLT trasformation process
rm -rf "$TARGET_PATH/${DECOR_PREFIX}${MODE}"-develop
rm "$TARGET_PATH/${DECOR_BASE_FILE%%.*}.out.${DECOR_BASE_FILE##*.}"

#Remove configuration file
rm "$DECOR_BASE_PATH/decor-parameters.xml"