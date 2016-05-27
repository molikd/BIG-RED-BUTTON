#!/bin/bash

HELP() {
  echo "Welcome to the Big Red Button, the safe way to release code to production, running is as simple as 

big_red_button.sh -c \"the name of my config\" -v \"the version I want to update to\"

but what are my full options?

   -h is the help msg, this will display the help message and exit
   -V is the Version info of Big Red Button, this will display the Big Red Button version and exit
   -f is for force, please do not ever use force
   -c is the name of the config
   -v is the version you want to update too in the software to be released. 
   -n is your name (this is optional, but you have to also give -e if you're going to use it)
   -e is your email (this is optional, but you have to also give -n if you're going to use it)
   -l is an optional log file, if you'd like
" >&2;
  exit 1;
}

BRB_VERSION() {
  echo "VERSION=0.3" >&2;
  exit 1;
}

MSG() {
  [ -t 1 ] && echo "[ $(date) ]: $1" >&2;
  [ ! -z "$LOG" ] && echo "[ $(date) ]: $1" >> "$LOG"
}

CONTINUE() {
  if [ -z "$force" ]; then
    echo "$1" >&2;
    read cont
    case "$cont" in
      Y|y|yes|Yes|YES )
      ;;
      N|n|no|No|NO )
        MSG "NO ENTERED, exiting"; rm -rf ~/.releases/$NAME ; exit 1;
      ;;
      *) 
        echo "Invalid input You entered: $cont" >&2;
	    CONTINUE
      ;;
    esac
  fi
}

VERSION_CLEANING() {
  echo "$1" | sed -e 's/\\//g' -e  's/\./\\\./g' || { MSG "unable to clean version, exiting"; exit 1; }
}

FILE_VERSIONING() {
  spellings="version Version VERSION";
  for cap in $spellings; do 
    sed -i'' -e "s/$cap $VERSION/$cap $version/g" $1;               #ex: version 0.0.0
    sed -i'' -e "s/$cap:$VERSION/$cap:$version/g" $1;               #ex: version:0.0.0
    sed -i'' -e "s/$cap: $VERSION/$cap: $version/g" $1;             #ex: version: 0.0.0
    sed -i'' -e "s/$cap=$VERSION/$cap=$version/g" $1;               #ex: version=0.0.0
    sed -i'' -e "s/$cap=\"$VERSION\"/$cap=\"$version\"/g" $1;       #ex: version="0.0.0"
    sed -i'' -e "s/$cap = \"$VERSION\"/$cap = \"$version\"/g" $1;   #ex: version = "0.0.0",
    sed -i'' -e "s/$cap=\'$VERSION\'/$cap=\'$version\'/g" $1;       #ex: version='0.0.0'
    sed -i'' -e "s/$cap => \'$VERSION\'/$cap => \'$version\'/g" $1; #ex: version => '0.0.0'
    sed -i'' -e "s/\:$cap\: $VERSION/\:$cap\: $version/g" $1;       #ex: :version: 0.0.0
    sed -i'' -e "s/@$cat\: $VERSION/@$cat\: $version/g" $1;         #ex: @version: 0.0.0
  done 
}

while getopts ":hVfc:v:n:e:l:" opt; do
 case "${opt}" in
  h)
    HELP; 
  ;;
  V)
    BRB_VERSION;
  ;;
  f)
    force="on";
  ;;
  c)
    config=${OPTARG};
  ;;
  v)
    version=${OPTARG};
  ;;
  n)
    name=${OPTARG};
  ;;
  e)
    email=${OPTARG};
  ;;
  l)
    LOG=${OPTARG};
  ;;
 esac
done

#check big red button
cd "$( which big_red_button.sh | sed "s/$(basename "$( which "big_red_button.sh" )" )//g" )" || { MSG "problems with cding into big_red_buttons, exiting"; exit 1; };
git commit --allow-empty -am "starting a new release" || { MSG "big red button not being run from a repo, exiting"; exit 1; };
MSG "Big Red Button at \"$( pwd )\"";

#check names and emails why not
[ ! -z "$name" ] && { [ -z "$email" ] && { MSG "If you're going to supply a name, supply a email as well"; exit 1; } }
[ ! -z "$email" ] && { [ -z "$name" ] && { MSG "If you're going to supply an email, supply a name as well"; exit 1; } }
[ -z "$name" ] && { [ -z "$(git config user.name)" ] && { name="Molik, David"; git config user.name "Molik, David"; } }
[ -z "$email" ]  && { [ -z "$(git config user.email)" ] && { email="dmolik@cshl.edu"; git config user.email "dmolik@cshl.edu"; } } 

#check logging and interactive mode requirements
[ ! -z "$force" ] && MSG "Program running in force mode, this is not recomended";
[ ! -t 1 ] && { [ -z "$LOG" ] && { MSG "Programing running in non-interactive shell without Logging, exiting"; exit 1; } }

#check that I'm the latest version of myself
MSG "checking and updating myself"
git checkout master || { MSG "not being run from within my git repo, exiting"; exit 1; }
git pull origin master || { MSG "cannot update myself, exiting"; exit 1; }

#check that new version was given and that config exists
CONTINUE "Continue with config: \"$config\" and version: \"$version\" ? (y/n)";
[ -z "$version" ] && { MSG "No new version given, exiting"; rm -rf ;exit 1; }
source $config || { MSG "SOURCE FAILED, check config name, exiting"; exit 1; }

#check that nessacary config options have been set 
MSG "checking config"
[ -z "$VERSION" ] && { MSG "No VERSION in config, exiting"; exit 1; }
[ -z "$NAME" ] && { MSG "No NAME in config, exiting"; exit 1; }
[ -z "$REPO" ] && { MSG "No REPO in config, exiting"; exit 1; }
[ -z "$REMOTES_INCOMING" ] && { MSG "No REMOTES_INCOMING in config, exiting"; exit 1; }
[ -z "$REMOTES_OUTGOING" ] && { MSG "NO REMOTES_OUTGOING in config, exiting"; exit 1; }
[ -z "$RELEASE_BRANCH" ] && { MSG "No RELEASE_BRANCH in config, exiting"; exit 1; }

#check version cleaning
version=$( VERSION_CLEANING "$version" );
VERSION=$( VERSION_CLEANING "$VERSION" );
MSG "Old version is now \"$VERSION\" and new version is now \"$version\""

#directory and repo creation
mkdir ~/.releases || MSG "could not create releases, perhaps it already exists";
cd ~/.releases || { MSG "could not cd into releases, exiting"; exit 1; }
git clone "$REPO" "$NAME" || { MSG "could not clone \"$NAME\" into releases, exiting"; exit 1; }

#fetch and merge all locations of repo 
cd ~/.releases/$NAME || { MSG "could'nt find repo, exiting"; exit 1; }
git init
MSG "Starting Git source update";
for remote_repo in $REMOTES_INCOMING; do
  remote=$( echo $remote_repo | awk -F',' '{print $1}' );
  branch=$( echo $remote_repo | awk -F',' '{print $2}' );
  urlloc=$( echo $remote_repo | awk -F',' '{print $3}' );
  MSG "utilizing remote: \"$remote\" and branch: \"$branch\"";
  git remote add $remote $urlloc || { MSG "unable to add remote: \"$remote\""; exit 1; }
  git checkout $RELEASE_BRANCH || { MSG "unable to find release branch: \"$RELEASE_BRANCH\""; exit 1; }
  git fetch $remote || { MSG "unable to find remote: \"$remote\""; exit 1; }
  MSG "checking git diff between \"$RELEASE_BRANCH\" and \"$remote/$branch\"";
  git diff $RELEASE_BRANCH..$remote/$branch;
  CONTINUE "Is git diff okay? (y/n)";
  git merge "$remote/$branch" || { MSG "problems in merge with remote \"$remote\" and branch \"$branch\""; exit 1; }
done

#update versioning, Version types handled:
# Version|version|VERSION
# (space)X|='X'|=X|="X"
MSG "Version updating in files"
for file in $FILES_TO_UPDATE; do
  MSG "updating \"$file\" with versioning";
  FILE_VERSIONING "$file"
done

#if not forcing, check that versioning went ok
if [ -z "$force" ]; then
  MSG "Versioning updated, manual check"
  for file in $FILES_TO_UPDATE; do
    echo "In file $file:" >&2;
    cat $file | grep -n "[Vv][Ee][Rr][Ss][Ii][Oo][Nn][^a-zA-Z0-9]*$VERSION";
    cat $file | grep -n "[Vv][Ee][Rr][Ss][Ii][Oo][Nn][^a-zA-Z0-9]*$version";
  done
  CONTINUE "Does versioning look ok? (y/n)"
fi

# Git commit and tag changes
git commit --allow-empty -am "Git Runway Automation for \"$NAME\", version: \"$version\" on $(date "+%Y-%m-%d")" || { MSG "problems with git commit, exiting"; exit 1; }
git tag -a "$( echo "$version" | sed 's/\\//g' )" -m "Version: $( echo "$version" | sed 's/\\//g' ), created on $(date "+%Y-%m-%d"), by git automated runway" || { MSG "problems with git tag, exiting"; exit 1; }

#run special instructions (pypi, CPAN)
MSG "Utilizing Special Instructions";
SPECIAL_INSTRUCTIONS

#push changes upstream
for remote_repo in $REMOTES_OUTGOING; do
  remote=$( echo $remote_repo | awk -F',' '{print $1}' );
  branch=$( echo $remote_repo | awk -F',' '{print $2}' );
  urlloc=$( echo $remote_repo | awk -F',' '{print $3}' );
  MSG "pushing changes upstream, remote: \"$remote\"";
  git push "$remote" "$branch" || MSG "no changes pushed $remote, possible failure";
  git push "$remote" "$branch" --tags || { MSG "problems with git push";}
done

#remove repo 
rm -rf "$RELEASES_DIR/$NAME" || MSG "unable to remove releases";

#update the config with the new version
cd "$( which big_red_button.sh | sed "s/$(basename "$( which "big_red_button.sh" )" )//g" )" || MSG "problems with cding into big_red_buttons";
FILE_VERSIONING $config
MSG "config updated with new version";
git add . || MSG "big red button repo not able to add";
git commit --allow-empty -am "updated versioning for config \"$config\", for $NAME, to $( echo "$version" | sed 's/\\//g' )"  || MSG "big red button not able to commit";
git push || MSG "no changes pushed to big red button repo, possible failure";
git push --tags origin master || MSG "unable to push to big red button repo";
MSG "Done.";
