#!/bin/bash

USERNAME=pawlex
CURL=/usr/bin/curl
TARGET=~/.ssh/authorized_keys
TEMP=$TARGET.new

if [ -f $CURL ]; then
 $($CURL -s https://github.com/$USERNAME.keys -o $TEMP)
fi

if [ -s $TARGET.new ]; then
 mv -f $TEMP $TARGET
 chmod 600 $TARGET
fi

exit 0
