#!/bin/bash

# Memory monitoring item
# Shows memory usage percentage

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

sketchybar --add item memory right \
	--set memory \
	icon="$ICON_MEMORY" \
	icon.color="$TEXT_COLOR" \
	icon.font="SF Pro:Bold:14.0" \
	label="..." \
	label.color="$TEXT_COLOR" \
	label.font="SF Pro:Semibold:13.0" \
	script="$PLUGIN_DIR/memory.sh" \
	background.color="$ITEM_BG_COLOR" \
	background.corner_radius=9 \
	background.height=28 \
	--subscribe memory system_stats
