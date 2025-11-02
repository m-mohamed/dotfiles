#!/bin/bash

# CPU monitoring item
# Shows CPU usage percentage with color coding

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

sketchybar --add item cpu right \
	--set cpu \
	icon="$ICON_CPU" \
	icon.color="$TEXT_COLOR" \
	icon.font="SF Pro:Bold:14.0" \
	label="..." \
	label.color="$TEXT_COLOR" \
	label.font="SF Pro:Semibold:13.0" \
	script="$PLUGIN_DIR/cpu.sh" \
	background.color="$ITEM_BG_COLOR" \
	background.corner_radius=9 \
	background.height=28 \
	--subscribe cpu system_stats
