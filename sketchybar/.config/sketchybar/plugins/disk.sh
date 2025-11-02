#!/bin/bash

# Disk usage monitoring plugin for Sketchybar

source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

# Get disk usage for root volume
DISK_USAGE=$(df -H / | awk 'NR==2 {print $5}' | tr -d '%')

# Color code based on usage
if [ "$DISK_USAGE" -ge 90 ]; then
  COLOR="$ERROR_COLOR"
elif [ "$DISK_USAGE" -ge 70 ]; then
  COLOR="$WARNING_COLOR"
else
  COLOR="$SUCCESS_COLOR"
fi

# Update sketchybar
sketchybar --set "$NAME" \
  icon="$ICON_DISK" \
  icon.color="$COLOR" \
  label="${DISK_USAGE}%" \
  label.color="$COLOR"
