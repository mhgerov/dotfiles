#!/usr/bin/env bash

killall -q polybar

while pgrep -x polybar >/dev/null; do
  sleep 0.2
done

MONITORS="$(polybar --list-monitors | awk -F: '{print $1}')"

PRIMARY="$(xrandr --query | awk '/ primary / {print $1; exit}')"

# Fall back if xrandr's primary is unset or not an active polybar monitor
# (e.g. the primary flag is stuck on a disabled output like eDP-1).
if [ -z "$PRIMARY" ] || ! printf '%s\n' "$MONITORS" | grep -qx "$PRIMARY"; then
  PRIMARY="$(printf '%s\n' "$MONITORS" | head -n1)"
fi

printf '%s\n' "$MONITORS" | while read -r m; do
  if [ "$m" = "$PRIMARY" ]; then
    MONITOR="$m" polybar main -c "$HOME/.config/polybar/config.ini" &
  else
    MONITOR="$m" polybar secondary -c "$HOME/.config/polybar/config.ini" &
  fi
done
