#!/bin/bash

# Volume scroll handler - adjust volume with mouse scroll
# Professional unixporn interaction

# $SCROLL_DELTA is positive for scroll up, negative for scroll down
VOLUME_CHANGE=5

if [ "$SCROLL_DELTA" -gt 0 ]; then
	# Scroll up - increase volume
	osascript -e "set volume output volume (output volume of (get volume settings) + $VOLUME_CHANGE)"
else
	# Scroll down - decrease volume
	osascript -e "set volume output volume (output volume of (get volume settings) - $VOLUME_CHANGE)"
fi
