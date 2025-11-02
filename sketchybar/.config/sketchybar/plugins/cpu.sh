#!/bin/bash

# CPU usage monitoring plugin
# Reads from stats_provider environment variables (event-driven, no spawning)

source "$HOME/.config/sketchybar/colors.sh"

# Read CPU usage from environment variable set by stats_provider
# No external commands = no process spawning!
CPU_USAGE="${CPU_USAGE:-0}"

# Remove any units if present
CPU_USAGE=$(echo "$CPU_USAGE" | sed 's/[^0-9.]//g')

# Convert to integer for comparison
CPU_USAGE_INT=$(printf "%.0f" "$CPU_USAGE")

# Color code based on usage
if [ "$CPU_USAGE_INT" -lt 30 ]; then
	COLOR="$SUCCESS_COLOR"
elif [ "$CPU_USAGE_INT" -lt 60 ]; then
	COLOR="$WARNING_COLOR"
else
	COLOR="$ERROR_COLOR"
fi

# Update sketchybar (icon + label colored)
sketchybar --set "$NAME" \
	icon.color="$COLOR" \
	label="${CPU_USAGE_INT}%" \
	label.color="$COLOR"
