#!/bin/bash

# Network traffic monitoring plugin
# Shows download and upload speeds

source "$HOME/.config/sketchybar/colors.sh"

# Get network interface (usually en0 for WiFi, en1 for Ethernet)
INTERFACE=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')

if [ -z "$INTERFACE" ]; then
	# No active network
	sketchybar --set "$NAME" label="---" label.color="$INACTIVE_COLOR"
	exit 0
fi

# Get current bytes
CURRENT_RX=$(netstat -ibn | awk -v interface="$INTERFACE" '$1 == interface {print $7; exit}')
CURRENT_TX=$(netstat -ibn | awk -v interface="$INTERFACE" '$1 == interface {print $10; exit}')

# Read previous values
CACHE_DIR="/tmp/sketchybar_network"
mkdir -p "$CACHE_DIR"
PREV_FILE="$CACHE_DIR/prev"

if [ -f "$PREV_FILE" ]; then
	read PREV_RX PREV_TX < "$PREV_FILE"

	# Calculate speed (bytes per 2 seconds = update_freq)
	RX_SPEED=$(( (CURRENT_RX - PREV_RX) / 2 / 1024 ))  # KB/s
	TX_SPEED=$(( (CURRENT_TX - PREV_TX) / 2 / 1024 ))  # KB/s

	# Hide if speed is very low
	if [ "$RX_SPEED" -lt 1 ] && [ "$TX_SPEED" -lt 1 ]; then
		sketchybar --set "$NAME" drawing=off
	else
		sketchybar --set "$NAME" \
			drawing=on \
			label="↓${RX_SPEED} ↑${TX_SPEED}" \
			label.color="$INFO_COLOR"
	fi
fi

# Save current values
echo "$CURRENT_RX $CURRENT_TX" > "$PREV_FILE"
