#!/bin/bash
#VERSION: 0.3

VERSION="0.3"
NAME="Big-Red-Button"
REPO="http://vcs.cshl.edu/gitlab/bsr/big_red_buttons.git"
REMOTES_INCOMING="gitlab,master,http://vcs.cshl.edu/gitlab/bsr/big_red_buttons.git"
REMOTES_OUTGOING="gitlab,master,http://vcs.cshl.edu/gitlab/bsr/big_red_buttons.git"
RELEASE_BRANCH="master"
LOG="$( which big_red_button.sh | sed "s/$(basename "$( which "big_red_button.sh" )" )//g" )/log/$NAME-$(date "+%Y-%m-%d")"
FILES_TO_UPDATE="brb_big_red_button.sh"
SPECIAL_INSTRUCTIONS () {
 MSG "Special Instructions" 
}
