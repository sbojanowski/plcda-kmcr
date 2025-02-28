#!/bin/bash
. shared-functions.sh

# Log file

# Static paths and files
DECOR_PATH="../"
PARTIAL_DECOR_PATH="$DECOR_PATH/partial"
TARGET_PATH="../output"
ASSETS_PATH="../decor-core-html/assets"

DECOR_FILE="$DECOR_PATH/plcda-decor.xml"
FINAL_FILE="$DECOR_PATH/plcda-decor.xml"

LOG_FILE="$TARGET_PATH/log_$(date +"%Y%m%dT%H%M%S")"

# Script file paths
MODIFY_DECOR_SCRIPT="./modify-decor.sh"
RUNTIME_RELEASE_SCRIPT="./create-runtime-release.sh"
HTML_RELEASE_SCRIPT="./create-html-release.sh"
COMPILE_SCHEMATRON_SCRIPT="./compile-schematron.sh"

VERSION="1.3.2"
TEMPLATES=(
    "plCdaParamedicRescueSummaryNote"
    "plCdaParamedicAirRescueSummaryNote"
)

DECOR_PREFIX=$(xmllint --xpath "string(/decor/project/@prefix)" "$DECOR_FILE")

RUNTIME_PATH="$TARGET_PATH/${DECOR_PREFIX}runtime"
HTML_PATH="$TARGET_PATH/${DECOR_PREFIX}html"
VALIDATION_XSLT_PATH="$TARGET_PATH/${DECOR_PREFIX}validation-xslt"

# Release generation init 729 993 102

init-directory "$TARGET_PATH"

print-script-title "Polska Implementacja Krajowa HL7 CDA - Generator wydania (wersja: $VERSION)"
print-task-group-caption "Przygotowanie pliku DECOR do generowania wydania"

# Fixing closed templates
# print-task-caption "Modyfikacja pliku DECOR - generowanie dodatkowych reguł dla szablonów zamkniętych"
# exec-and-print-task-result "$MODIFY_DECOR_SCRIPT fix-closed-templates $DECOR_FILE $DECOR_PATH"

# Generating sigle document template DECOR files
init-directory "$PARTIAL_DECOR_PATH"
for TEMPLATE in "${TEMPLATES[@]}"
do
    print-task-caption "Generowanie pliku DECOR dla szablonu $TEMPLATE i wszystkich szablonów podrzednych"
    exec-and-print-task-result "$MODIFY_DECOR_SCRIPT single-document-template $FINAL_FILE $PARTIAL_DECOR_PATH $TEMPLATE"
done

# Removing fixed temporary DECOR files
# print-task-caption "Usuwanie plików tymczasowych potrzebnych do wygenerowania plików DECOR dla poszczególnych szablonów"
# exec-and-print-task-result "rm $DECOR_PATH/*fixed.xml*"

# Generating DECOR runtime releases (schematrons)
print-task-group-caption "Generowanie plików schematron'owych dla poszczególnych szablonów dokumentów"
init-directory "$RUNTIME_PATH"
for TEMPLATE in "${TEMPLATES[@]}"
do
    print-task-caption "Generowanie plików schematron'owych dla szablonu $TEMPLATE"
    exec-and-print-task-result "$RUNTIME_RELEASE_SCRIPT $PARTIAL_DECOR_PATH/${DECOR_PREFIX}decor-${TEMPLATE}.xml $RUNTIME_PATH/${DECOR_PREFIX}runtime-$TEMPLATE"
done

# Compiling schematrons - generating validation XSLT stylsheets
print-task-group-caption "Generowanie walidujących plików XSLT na podstawie utworzonych plików wydań schematon'owych."
init-directory "$VALIDATION_XSLT_PATH"
for TEMPLATE in "${TEMPLATES[@]}"
do
    print-task-caption "Generowanie walidującego pliku XSLT dla szablonu $TEMPLATE"
    exec-and-print-task-result "$COMPILE_SCHEMATRON_SCRIPT $RUNTIME_PATH/${DECOR_PREFIX}runtime-$TEMPLATE/${DECOR_PREFIX}${TEMPLATE}.sch $TEMPLATE $VALIDATION_XSLT_PATH"
done

# Generating DECOR publication release (html)
print-task-group-caption "Generowanie wydania HTML"
init-directory "$HTML_PATH"
print-task-caption "Generowanie wydania HTML dla wszystkich szablonów dokumentów"
exec-and-print-task-result "$HTML_RELEASE_SCRIPT $DECOR_FILE $HTML_PATH"

print-task-caption "Kopiowanie zasobów dla wydania HTML (assets)"
init-directory "$TARGET_PATH/assets"
exec-and-print-task-result "cp -rf $ASSETS_PATH/* $TARGET_PATH/assets"