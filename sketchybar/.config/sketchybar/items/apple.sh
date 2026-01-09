#!/bin/bash

# Apple menu with popup

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"

# Main Apple logo item
sketchybar --add item apple.logo left \
	--set apple.logo \
	icon="$ICON_APPLE" \
	icon.font="SF Pro:Black:16.0" \
	icon.color="$HIGHLIGHT_COLOR" \
	padding_left=12 \
	padding_right=12 \
	click_script="sketchybar --set apple.logo popup.drawing=toggle" \
	popup.drawing=off

# Popup: System Preferences
sketchybar --add item apple.prefs popup.apple.logo \
	--set apple.prefs \
	icon="􀍟" \
	label="Preferences" \
	click_script="open 'x-apple.systempreferences:' && $POPUP_OFF"

# Popup: Activity Monitor
sketchybar --add item apple.activity popup.apple.logo \
	--set apple.activity \
	icon="􀐚" \
	label="Activity" \
	click_script="open -a 'Activity Monitor' && $POPUP_OFF"

# Popup: Lock Screen
sketchybar --add item apple.lock popup.apple.logo \
	--set apple.lock \
	icon="􀎠" \
	label="Lock Screen" \
	click_script="pmset displaysleepnow && $POPUP_OFF"
