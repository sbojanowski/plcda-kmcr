#!/bin/bash

SAXON_JAR="saxon9he.jar"
XSLT_PATH="./compiled-schematrons"
XSLT_EXTENSION="sch"

EXAMPLE_FILE=$1


if [[ $# -ne 1 ]]; then
     echo "Usage: validate-example.sh [exampleFile]"
     exit
fi

if [ ! -f $EXAMPLE_FILE ]; then
    echo "File '$EXAMLE_FILE' not found!"
    exit
fi

TEMPLATE_ID=$(xmllint --xpath "string(/*[local-name()='ClinicalDocument']/*[local-name()='templateId'][@extension]/@root)" "$EXAMPLE_FILE")
XSLT_FILE="$XSLT_PATH/$TEMPLATE_ID.$XSLT_EXTENSION"

if [ ! -f $XSLT_FILE ]; then
    echo "Compiled schematron (XSLT) file '$XSLT_FILE' not found."
    exit
fi

# Generating validation as a XSLT trasformation using compiled schematron file in a form of XSLT stylesheet
java -jar "$SAXON_JAR" -xsl:"$XSLT_FILE" -s:"$EXAMPLE_FILE" -o:"$EXAMPLE_FILE.out"

