#!/bin/bash
#VERSION: 0.3

VERSION="0.3"
NAME="Big-Red-Button"
REPO="git@github.com:status-five/BIG-RED-BUTTON.git"
REMOTES_INCOMING="github,master,git@github.com:status-five/BIG-RED-BUTTON.git gitlab,master,git@vcs.cshl.edu:dmolik/BIG-RED-BUTTON.git"
REMOTES_OUTGOING="github,master,git@github.com:status-five/BIG-RED-BUTTON.git gitlab,master,git@vcs.cshl.edu:dmolik/BIG-RED-BUTTON.git"
RELEASE_BRANCH="master"
LOG="$( which big_red_button.sh | sed "s/$(basename "$( which "big_red_button.sh" )" )//g" )/log/$NAME-$(date "+%Y-%m-%d")"
FILES_TO_UPDATE="brb_big_red_button.sh"
SPECIAL_INSTRUCTIONS () {
 MSG "Special Instructions" 
}
