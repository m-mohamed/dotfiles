#!/bin/bash

# Memory usage monitoring plugin
# Reads from stats_provider environment variables (event-driven, no spawning)

source "$HOME/.config/sketchybar/colors.sh"

# Read memory usage from environment variable set by stats_provider
# No external commands = no process spawning!
MEM_PERCENTAGE="${RAM_USAGE:-0}"

# Remove any units if present
MEM_PERCENTAGE=$(echo "$MEM_PERCENTAGE" | sed 's/[^0-9.]//g')

# Convert to integer for comparison
MEM_PERCENTAGE_INT=$(printf "%.0f" "$MEM_PERCENTAGE")

# Color code based on usage
if [ "$MEM_PERCENTAGE_INT" -lt 60 ]; then
	COLOR="$SUCCESS_COLOR"
elif [ "$MEM_PERCENTAGE_INT" -lt 80 ]; then
	COLOR="$WARNING_COLOR"
else
	COLOR="$ERROR_COLOR"
fi

# Update sketchybar (icon + label colored)
sketchybar --set "$NAME" \
	icon.color="$COLOR" \
	label="${MEM_PERCENTAGE_INT}%" \
	label.color="$COLOR"
