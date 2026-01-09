#!/bin/bash

# Clock plugin with calendar popup
# Click to toggle month calendar view

source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

# Get calendar for current month with highlighted today
MONTH_CALENDAR=$(cal | sed 's/^/  /')
TODAY=$(date +%e)
MONTH_CALENDAR=$(echo "$MONTH_CALENDAR" | sed "s/ $TODAY / [$TODAY] /g")

# Update clock
sketchybar --set "$NAME" \
  icon="$ICON_CLOCK" \
  label="$(date '+%a %d %b %I:%M %p')"

# Create/update popup
sketchybar --add item clock.popup popup."$NAME" 2>/dev/null
sketchybar --set clock.popup \
  icon="􀉉" \
  icon.color="$ACCENT_COLOR" \
  label="$MONTH_CALENDAR" \
  label.font="SF Mono:Regular:11.0" \
  background.color="$ITEM_BG_COLOR_SOLID" \
  background.corner_radius=9 \
  background.padding_left=8 \
  background.padding_right=8

