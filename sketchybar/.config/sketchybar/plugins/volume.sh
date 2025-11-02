#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

source "$HOME/.config/sketchybar/icons.sh"

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
    [6-9][0-9]|100) ICON="$ICON_VOLUME_100"
    ;;
    [3-5][0-9]) ICON="$ICON_VOLUME_66"
    ;;
    [1-9]|[1-2][0-9]) ICON="$ICON_VOLUME_33"
    ;;
    *) ICON="$ICON_VOLUME_0"
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%"
fi
