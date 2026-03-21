#!/usr/bin/env bash

killall -q polybar

while pgrep -x polybar >/dev/null; do
  sleep 0.2
done

PRIMARY="$(xrandr --query | awk '/ primary / {print $1; exit}')"

if [ -z "$PRIMARY" ]; then
  PRIMARY="$(polybar --list-monitors | awk -F: 'NR==1{print $1}')"
fi

polybar --list-monitors | awk -F: '{print $1}' | while read -r m; do
  if [ "$m" = "$PRIMARY" ]; then
    MONITOR="$m" polybar main -c "$HOME/.config/polybar/config.ini" &
  else
    MONITOR="$m" polybar secondary -c "$HOME/.config/polybar/config.ini" &
  fi
done
