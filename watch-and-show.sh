#!/bin/env bash

# Builds and watches files

SYNCEXT="html"          # browser-sync will watches changes with this extension
WATCHEXT="adoc,tex,css" # nodemon will run the BUILDCMD when these files change
BUILDCMD="make"         # the command that runs when WATCHEXT files change

tmux new-window -d -n dev "browser-sync start --server --files \"*.${SYNCEXT}\" --no-open && killall node"
tmux split-window -t :dev "nodemon -L -e ${WATCHEXT} -x \"${BUILDCMD} && browser-sync reload\""

# http://localhost:3000/build/example.html
