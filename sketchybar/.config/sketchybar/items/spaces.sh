#!/bin/bash

# Workspace indicators with dynamic creation
# Automatically creates workspace items from aerospace configuration

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

# Register aerospace workspace change event
sketchybar --add event aerospace_workspace_change

# Dynamically create workspace items from aerospace
for sid in $(/opt/homebrew/bin/aerospace list-workspaces --all 2>/dev/null); do
	SID_LOWER=$(echo "$sid" | tr '[:upper:]' '[:lower:]')

	sketchybar --add item "space.$SID_LOWER" left \
		--set "space.$SID_LOWER" \
		icon="$sid" \
		icon.font="SF Pro:Bold:14.0" \
		icon.padding_left=15 \
		icon.padding_right=4 \
		icon.color="$INACTIVE_COLOR" \
		icon.highlight_color="$HIGHLIGHT_COLOR" \
		label="" \
		label.font="sketchybar-app-font:Regular:16.0" \
		label.padding_left=2 \
		label.padding_right=15 \
		label.drawing=on \
		label.y_offset=-1 \
		background.color="0x44ffffff" \
		background.corner_radius=5 \
		background.height=30 \
		background.padding_left=2 \
		background.padding_right=2 \
		background.drawing=off \
		click_script="/opt/homebrew/bin/aerospace workspace $sid" \
		script="$PLUGIN_DIR/aerospacer.sh $sid" \
		--subscribe "space.$SID_LOWER" aerospace_workspace_change front_app_switched
done

# Add separator after workspaces
sketchybar --add item spaces_separator left \
	--set spaces_separator \
	icon="│" \
	icon.font="SF Pro:Light:16.0" \
	icon.color="$INACTIVE_COLOR" \
	padding_left=4 \
	padding_right=4 \
	label.drawing=off \
	background.drawing=off
