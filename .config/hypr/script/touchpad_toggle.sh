#!/bin/sh
DEVICE="asue120c:00-04f3:31c1-touchpad"
STATUS_FILE="/tmp/touchpad_status"

if [[ -f "$STATUS_FILE" ]]; then
  STATUS=$(cat "$STATUS_FILE")
else
  STATUS="true"
fi

if [[ "$STATUS" == "true" ]]; then
  hyprctl keyword "device[$DEVICE]:enabled" false
  echo "false" >"$STATUS_FILE"
  notify-send "Touchpad disabled"
else
  hyprctl keyword "device[$DEVICE]:enabled" true
  echo "true" >"$STATUS_FILE"
  notify-send "Touchpad enabled"
fi
