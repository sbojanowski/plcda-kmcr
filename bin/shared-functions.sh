#!/bin/bash

COLOR_NONE="\033[0m"
COLOR_WHITE="\033[1;37m"
COLOR_RED="\033[1;31m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_GREY="\033[1;37m"
COLOR_WHITE_ON_RED="\033[1;41m"
COLOR_WHITE_ON_GREEN="\033[1;42m"
COLOR_WHITE_ON_YELLOW="\033[1;43m"
COLOR_WHITE_ON_BLUE="\033[1;44m"

# Directory functions
function init-directory() {
    DIR_NAME=$1
    if [ ! -d $DIR_NAME ]; 
        then
            mkdir $DIR_NAME
        else
            rm -Rf $DIR_NAME/*
    fi
}

# Printing functions

function print-script-title() {
    TITLE=$1
    echo -e "\n\r${COLOR_WHITE_ON_BLUE}${TITLE}${COLOR_NONE}\n\r"
}

function print-task-group-caption() {
    CAPTION=$1
    echo -e "\n\r${COLOR_WHITE}${CAPTION}${COLOR_NONE}\n\r"
    echo "$(date +"%F_%T"): $CAPTION." >> "$LOG_FILE"
}

function print-task-caption() {
    CAPTION=$1
    echo -e -n "${COLOR_GREY}* ${COLOR_NONE}${CAPTION} ... "
    echo "$(date +"%F_%T"): $CAPTION." >> "$LOG_FILE"
}

function print-task-result-ok() {
    echo -e "${COLOR_WHITE}[${COLOR_GREEN}OK${COLOR_WHITE}]${COLOR_NONE}"
}

function print-task-result-fail() {
    echo -e "${COLOR_WHITE}[${COLOR_RED}BŁĄD${COLOR_WHITE}]${COLOR_NONE}"
}

function set-color-white() {
    echo -e "${COLOR_WHITE}"
}

function set-color-grey() {
    echo -e "${COLOR_GREY}"
}

function set-color-none() {
    echo -e "${COLOR_NONE}"
}

# Execution commands

function exec-and-print-task-result() {
    TASK_CMD=$1
    (eval "$TASK_CMD" 2>&1) >>"$LOG_FILE"

    if [ "$?" -eq "0" ]
    then
        print-task-result-ok
    else
        print-task-result-fail
    fi
}