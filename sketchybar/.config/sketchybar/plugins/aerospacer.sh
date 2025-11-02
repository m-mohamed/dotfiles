#!/bin/bash

# AeroSpace workspace indicator with app icons

source "$HOME/.config/sketchybar/colors.sh"

WORKSPACE=$1
WORKSPACE_LOWER=$(echo "$WORKSPACE" | tr '[:upper:]' '[:lower:]')
NAME="space.$WORKSPACE_LOWER"
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

# Get list of apps in this workspace
APPS=$(/opt/homebrew/bin/aerospace list-windows --workspace "$WORKSPACE" --format "%{app-name}" 2>/dev/null | sort -u)

# Build icon string from running apps
ICON_STRIP=""
if [ "$APPS" != "" ]; then
	while IFS= read -r APP; do
		ICON_RESULT=$("$PLUGIN_DIR/icon_map_omerxx.sh" "$APP")
		ICON_STRIP+=" $ICON_RESULT"
	done <<< "$APPS"
fi

# Get focused workspace (from event or by querying aerospace)
if [ -z "$FOCUSED_WORKSPACE" ]; then
	FOCUSED_WORKSPACE=$(/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null)
fi

# Update workspace indicator
if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
	sketchybar --set "$NAME" \
		icon.color="0xfff7768e" \
		label="$ICON_STRIP" \
		background.drawing=on
else
	sketchybar --set "$NAME" \
		icon.color="$INACTIVE_COLOR" \
		label="$ICON_STRIP" \
		background.drawing=off
fi
