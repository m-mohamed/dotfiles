#!/bin/bash

# AeroSpace workspace indicator plugin for Sketchybar
# Highlights active workspace and dims inactive ones

source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null || {
  # Fallback colors if colors.sh doesn't exist
  HIGHLIGHT_COLOR=0xff9ece6a
  ACCENT_COLOR=0xff7aa2f7
  INACTIVE_COLOR=0xff565f89
}

# Get the workspace this item represents (passed as argument)
WORKSPACE=$1

# Get current AeroSpace workspace
# Use environment variable from aerospace exec-on-workspace-change if available
if [ -n "$FOCUSED" ]; then
  CURRENT_WORKSPACE="$FOCUSED"
else
  # Fallback to calling aerospace directly
  CURRENT_WORKSPACE=$(/Applications/AeroSpace.app/Contents/MacOS/AeroSpace list-workspaces --focused 2>/dev/null)
fi

# Update colors based on whether this workspace is active
if [ "$WORKSPACE" = "$CURRENT_WORKSPACE" ]; then
  sketchybar --set $NAME \
    icon.color=$HIGHLIGHT_COLOR \
    label.color=$HIGHLIGHT_COLOR
else
  sketchybar --set $NAME \
    icon.color=$INACTIVE_COLOR \
    label.color=$INACTIVE_COLOR
fi
