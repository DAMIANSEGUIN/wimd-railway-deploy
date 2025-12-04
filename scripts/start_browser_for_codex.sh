#!/bin/bash
# This script ensures Chromium is closed and then restarts it with the correct
# profile and extensions for CodexCapture testing.

echo "Ensuring all Chromium instances are closed..."
killall Chromium 2>/dev/null
sleep 1

echo "Launching Chromium with CodexCapture for testing..."
/Applications/Chromium.app/Contents/MacOS/Chromium \
  --user-data-dir=/Users/damianseguin/CodexChromiumProfile \
  --load-extension=/Users/damianseguin/CodexTools/CodexCapture \
  "$@" &

echo "Browser launched. If the window does not appear, please check for errors in the terminal."
