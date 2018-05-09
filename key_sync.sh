#!/bin/bash

USERNAME=pawlex
CURL=/usr/bin/curl
TARGET=~/.ssh/authorized_keys
TEMP=$TARGET.new

# if CURL is installed
if [ -f $CURL ]; then
 # Grab SSH Keys from github
 $($CURL -s https://github.com/$USERNAME.keys -o $TEMP)
fi

# If temp file exists and is not null
if [ -s $TARGET.new ]; then
 # Overwrite authorized_keys with that on github
 mv -f $TEMP $TARGET
 chmod 600 $TARGET
fi

exit 0
