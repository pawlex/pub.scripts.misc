#!/bin/bash

USERNAME=pawlex
CURL=/usr/bin/curl
TARGET=~/.ssh/authorized_keys
TEMP=$TARGET.new

if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
fi

# if CURL is installed
if [ -f $CURL ]; then
  # Grab SSH Keys from github
  $($CURL -s https://github.com/$USERNAME.keys -o $TEMP)
 else
  echo "key not updated.  curl is not installed"
  exit -1
fi

# If temp file exists and is not null
if [ -s $TEMP ]; then
 # Overwrite authorized_keys with that on github
 mv -f $TEMP $TARGET
 chmod 600 $TARGET
fi

exit 0
