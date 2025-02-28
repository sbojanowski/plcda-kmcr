#!/bin/bash

SAXON_JAR="../saxon/saxon9he.jar"
SCHEMATRON_ABSTRACT_EXPAND="../iso-schematron/iso_abstract_expand.xsl"
SCHEMATRON_DSDL_INCLUDE="../iso-schematron/iso_dsdl_include.xsl"
SCHEMATRON_SVRL_TO_XSLT2="../iso-schematron/iso_svrl_for_xslt2.xsl"
SCH_FILE=$1
SCH_BASE_PATH=${SCH_FILE%/*}
SOURCE_INCLUDE_PATH="$SCH_BASE_PATH/include"
TEMPLATE_ID=$2
TARGET_PATH=$3

if [[ $# -ne 3 ]]; then
     echo "Usage: compile-schematron.sh inputSchematronFile templateId targetPath"
     exit 1
fi

if [ ! -f $SCH_FILE ]; then
    echo "File $SCH_FILE not found!"
    exit 1
fi

if [ ! -d $TARGET_PATH ]; then
    echo "Provided $TARGET_PATH target path not found!"
    exit 1
fi

if [ ! -f $SAXON_JAR ]; then
    echo "Saxon XSLT engine jar not found!"
    exit 1
fi

if [ ! -f $SCHEMATRON_ABSTRACT_EXPAND ]; then
    echo "Required ISO Schematron XSLT stylesheet not found: $SCHEMATRON_ABSTRACT_EXPAND"
    exit 1
fi

if [ ! -f $SCHEMATRON_DSDL_INCLUDE ]; then
    echo "Required ISO Schematron XSLT stylesheet not found: $SCHEMATRON_DSDL_INCLUDE"
    exit 1
fi

if [ ! -f $SCHEMATRON_SVRL_TO_XSLT2 ]; then
    echo "Required ISO Schematron XSLT stylesheet not found: $SCHEMATRON_SVRL_TO_XSLT2"
    exit 1
fi

TARGET_INCLUDE_PATH="$TARGET_PATH/include"

if [ ! -d $TARGET_INCLUDE_PATH ]; then
    mkdir $TARGET_INCLUDE_PATH
fi

#First pass (iso_dsdl_include.xsl)
java -jar "$SAXON_JAR" -xsl:"$SCHEMATRON_DSDL_INCLUDE" -s:"$SCH_FILE" -o:"/tmp/$TEMPLATE_ID.pass1.out"
#Second pass (iso_abstract_expand.xsl)
java -jar "$SAXON_JAR" -xsl:"$SCHEMATRON_ABSTRACT_EXPAND" -s:"/tmp/$TEMPLATE_ID.pass1.out" -o:"/tmp/$TEMPLATE_ID.pass2.out"
#Final pass (iso_svrl_for_xslt2.xsl)
java -jar "$SAXON_JAR" -xsl:"$SCHEMATRON_SVRL_TO_XSLT2" -s:"/tmp/$TEMPLATE_ID.pass2.out" -o:"$TARGET_PATH/$TEMPLATE_ID.xsl"

# Copying runtime vocabulary definitions
\cp -Rf "$SOURCE_INCLUDE_PATH"/voc*.xml "$TARGET_INCLUDE_PATH"/