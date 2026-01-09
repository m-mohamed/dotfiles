#!/bin/bash

# Volume click handler
# Left click: toggle mute
# Right click: open Sound Settings

case "$BUTTON" in
  "left")
    # Toggle mute
    osascript -e 'set volume output muted not (output muted of (get volume settings))'
    ;;
  "right")
    # Open Sound Settings
    open "x-apple.systempreferences:com.apple.Sound-Settings.extension"
    ;;
esac
