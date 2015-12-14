# BIG RED BUTTON 
## Introduction
The basic concept behind BIG RED BUTTON is to be a kind of poor mans git [release runway](https://en.wikipedia.org/wiki/Software_release_life_cycle) by running the script code is automatically updated and pushed out to locations that it can be picked up by others. The code iteslf is simple, and runinng code is simple as well:

`big_red_button.sh -c "config" -v "new version"`

this will utilize the code from the config to download the repos described in the config, update the code with versioning instructions and run any specail instructions (like uploading to pypi). BIG RED BUTTON works by downloading the repo to a directory under your home direcotry called "./releases" after the release BIG RED BUTTON deletes the local copy of the repo. 
## Installation 
Installation consists of two parts, one clone big red button:

`git clone git@vcs.cshl.edu:bsr/big_red_buttons.git`

Then add the repo to your path in your bashrc:

`PATH=$PATH:/path/to/big/red/buttons`

## Other options

NOTE: there is a huge difference between -V and -v where -V is the current version of Big Red Button running, -v is the the software version you would like to upgrade too. 

```
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
"
}
```
## Contact
> Developer: David Molik

> Email: dmolik@cshl.edu