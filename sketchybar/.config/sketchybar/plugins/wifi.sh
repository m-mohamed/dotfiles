#!/bin/bash

# WiFi status plugin for Sketchybar (macOS 15+ compatible)

source "$HOME/.config/sketchybar/icons.sh"

# Get WiFi interface name
WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')

# Get SSID using ipconfig (works on macOS 15+)
SSID=$(ipconfig getsummary "$WIFI_INTERFACE" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}')

# Check if connected (SSID exists and not redacted)
if [ -n "$SSID" ] && [ "$SSID" != "<redacted>" ]; then
  sketchybar --set "$NAME" icon="$ICON_WIFI" label="$SSID"
else
  # Check if WiFi is active but SSID is redacted (macOS privacy)
  if ipconfig getsummary "$WIFI_INTERFACE" 2>/dev/null | grep -q "SSID :"; then
    # Connected but SSID hidden - show generic "Connected"
    sketchybar --set "$NAME" icon="$ICON_WIFI" label="Connected"
  else
    # Actually disconnected
    sketchybar --set "$NAME" icon="$ICON_WIFI_OFF" label="Disconnected"
  fi
fi
