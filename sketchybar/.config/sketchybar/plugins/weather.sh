#!/bin/bash

# Weather widget using wttr.in API
# Displays current temperature and conditions
# Click to open Weather.app

source "$HOME/.config/sketchybar/colors.sh"

# Location (use empty for automatic location based on IP)
LOCATION=""

# Fetch weather from wttr.in (format: "Condition +Temp°C")
WEATHER=$(curl -s "https://wttr.in/${LOCATION}?format=3" 2>/dev/null)

# If fetch failed, show placeholder
if [ -z "$WEATHER" ] || [ "$WEATHER" == "Unknown location" ]; then
	WEATHER="Weather N/A"
fi

# Weather icon (you can customize based on conditions)
ICON="􀇕"  # SF Symbol: cloud.sun.fill

# Update widget
sketchybar --set "$NAME" \
	icon="$ICON" \
	icon.color="$INFO_COLOR" \
	label="$WEATHER"
