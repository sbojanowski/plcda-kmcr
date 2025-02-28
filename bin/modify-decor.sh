#!/bin/bash

SAXON_JAR="../saxon/saxon9he.jar"

FIX_CLOSED_TEMPLATES_XSLT="../xslt/iEHReu.DECOR.ClosedTemplatesFix.xsl"
REMOVE_OLD_TEMPLATES_XSLT="../xslt/iEHReu.DECOR.OldTemplatesRemove.xsl"
SINGLE_DOCUMENT_TEMPLATE_XSLT="../xslt/iEHReu.DECOR.SingleDocumentTemplate.xsl"

OPTION=$1
DECOR_FILE=$2
DECOR_BASE_FILE=$(basename "$DECOR_FILE")
TARGET_PATH=$3
TEMPLATE_NAME=$4


function fix-closed-templates {
    FIXED_OUTPUT_FILE="$TARGET_PATH/${DECOR_BASE_FILE%%.*}.fixed.${DECOR_BASE_FILE##*.}"
    java -jar "$SAXON_JAR" -xsl:"$FIX_CLOSED_TEMPLATES_XSLT" -s:"$DECOR_FILE" -o:"$FIXED_OUTPUT_FILE"
    sed -i -e "s/datatype\=\"uid\"/datatype\=\"oid\"/g" $FIXED_OUTPUT_FILE
}

function remove-old-templates {
    java -jar "$SAXON_JAR" -xsl:"$REMOVE_OLD_TEMPLATES_XSLT" -s:"$DECOR_FILE" -o:"$TARGET_PATH/${DECOR_BASE_FILE%%.*}.cleaned.${DECOR_BASE_FILE##*.}"
}

function single-document-template {
    if [ -z $TEMPLATE_NAME ]; then
        echo "Error: For single-document-template option templateName attribute is required."
        exit 1
    fi
    java -jar "$SAXON_JAR" -xsl:"$SINGLE_DOCUMENT_TEMPLATE_XSLT" -s:"$DECOR_FILE" -o:"$TARGET_PATH/${DECOR_BASE_FILE%%.*}-$TEMPLATE_NAME.${DECOR_BASE_FILE##*.}" "templateName=$TEMPLATE_NAME"
}


function print-usage {
     echo "Usage: modify-decor.sh option decorFile targetPath (templateName)"
     echo "Options:"
     echo "fix-closed-templates: Adds additinal schematron rules to templates marked as closed."
     echo "remove-old-templates: Creates modified DECOR project with old versions of templetes removed."
     echo "single-document-template: Creates modified DECOR project file with templates in the context of particular document template. Temmplate name is required"
}


if [[ $# -lt 3 ]]; then
    print-usage
    exit 1    
fi

case "$OPTION" in
    fix-closed-templates)
        fix-closed-templates
        ;;
    remove-old-templates)
        remove-old-templates
        ;;
    single-document-template)
        single-document-template
        ;;
    *)
        print-usage
        exit 1
esac
