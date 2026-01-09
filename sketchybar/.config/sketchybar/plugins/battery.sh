#!/bin/bash

# Battery monitoring plugin - Uses stats_provider for event-driven updates
# Community standard approach with Nerd Font icons

source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

# Get battery percentage from stats_provider environment variable
PERCENTAGE="${BATTERY_PERCENTAGE:-0}"

# Remove any units if present
PERCENTAGE=$(echo "$PERCENTAGE" | sed 's/[^0-9.]//g')
PERCENTAGE_INT=$(printf "%.0f" "$PERCENTAGE")

# Check if charging (requires pmset for now, stats_provider doesn't provide state)
CHARGING=$(pmset -g batt | grep 'AC Power')

# Select SF Symbol icon based on battery level (using icon variables from icons.sh)
if [ -n "$CHARGING" ]; then
  ICON="$ICON_BATTERY_CHARGING"  # Charging icon
elif [ "$PERCENTAGE_INT" -ge 90 ]; then
  ICON="$ICON_BATTERY_100"  # Battery full
elif [ "$PERCENTAGE_INT" -ge 60 ]; then
  ICON="$ICON_BATTERY_75"  # Battery 75%
elif [ "$PERCENTAGE_INT" -ge 40 ]; then
  ICON="$ICON_BATTERY_50"  # Battery 50%
elif [ "$PERCENTAGE_INT" -ge 20 ]; then
  ICON="$ICON_BATTERY_25"  # Battery 25%
else
  ICON="$ICON_BATTERY_0"  # Battery low
fi

# Color code based on percentage
if [ "$PERCENTAGE_INT" -lt 20 ] && [ -z "$CHARGING" ]; then
  COLOR="$ERROR_COLOR"
elif [ "$PERCENTAGE_INT" -lt 50 ]; then
  COLOR="$WARNING_COLOR"
else
  COLOR="$SUCCESS_COLOR"
fi

# Update sketchybar
sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color="$COLOR" \
  label="${PERCENTAGE_INT}%" \
  label.color="$COLOR"
