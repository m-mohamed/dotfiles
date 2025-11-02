#!/bin/bash

# Calendar popup for clock widget
# Shows current month calendar with highlighted current day

source "$HOME/.config/sketchybar/colors.sh"

# Get calendar for current month
MONTH_CALENDAR=$(cal | sed 's/^/  /')

# Highlight today's date
TODAY=$(date +%e)
MONTH_CALENDAR=$(echo "$MONTH_CALENDAR" | sed "s/ $TODAY / [$TODAY] /g")

# Create popup
sketchybar --add item calendar.popup popup.clock \
           --set calendar.popup \
                 icon="􀉉" \
                 icon.color="$ACCENT_COLOR" \
                 label="$MONTH_CALENDAR" \
                 label.font="SF Mono:Regular:11.0" \
                 background.color="$ITEM_BG_COLOR_SOLID" \
                 background.corner_radius=9 \
                 background.padding_left=8 \
                 background.padding_right=8

echo "Calendar popup created"
