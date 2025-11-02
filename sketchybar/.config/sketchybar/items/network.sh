#!/bin/bash

# Network monitoring item
# Shows download/upload speeds

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

sketchybar --add item network right \
	--set network \
	icon="$ICON_NETWORK" \
	icon.color="$TEXT_COLOR" \
	icon.font="SF Pro:Bold:14.0" \
	label="..." \
	label.color="$TEXT_COLOR" \
	label.font="SF Pro:Semibold:11.0" \
	update_freq=2 \
	script="$PLUGIN_DIR/network.sh" \
	background.color="$ITEM_BG_COLOR" \
	background.corner_radius=9 \
	background.height=28
