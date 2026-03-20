#!/usr/bin/env bash

# Kill existing bars
killall -q polybar

# Wait until processes are shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bar
polybar main &
