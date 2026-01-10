#!/bin/bash

# Icon mapping for applications
# Returns an appropriate icon for a given application name
# Based on omerxx's comprehensive app mapping

case $1 in
# Browsers
"Safari" | "Safari Technology Preview")
	echo "󰀹"
	;;
"Google Chrome" | "Chrome")
	echo ""
	;;
"Brave Browser" | "Brave")
	echo "󰖟"
	;;
"Arc")
	echo "󰞍"
	;;
"Firefox" | "Firefox Developer Edition")
	echo ""
	;;
"Microsoft Edge")
	echo "󰇩"
	;;
"Opera")
	echo ""
	;;

# Terminals
"Ghostty" | "ghostty")
	echo "👻"
	;;
"iTerm2" | "iTerm")
	echo ""
	;;
"Terminal" | "Terminal.app")
	echo ""
	;;
"Alacritty")
	echo""
	;;
"kitty")
	echo "󰄛"
	;;
"Ghostty")
	echo "󰊠"
	;;

# Development
"Code" | "Visual Studio Code" | "VSCode")
	echo "󰨞"
	;;
"Xcode")
	echo"󰀵"
	;;
"Android Studio")
	echo""
	;;
"IntelliJ IDEA" | "IntelliJ")
	echo""
	;;
"PyCharm")
	echo""
	;;
"WebStorm")
	echo""
	;;
"Neovim" | "VimR" | "MacVim")
	echo""
	;;
"Sublime Text")
	echo""
	;;

# Communication
"Slack")
	echo "󰒱"
	;;
"Discord")
	echo"󰙯"
	;;
"Telegram" | "Telegram Desktop")
	echo""
	;;
"Messages" | "Nachrichten")
	echo"󰍦"
	;;
"WhatsApp")
	echo""
	;;
"Signal")
	echo"󰍡"
	;;
"Zoom" | "zoom.us")
	echo""
	;;
"Microsoft Teams" | "Teams")
	echo"󰊻"
	;;
"Skype")
	echo""
	;;

# Mail
"Mail" | "邮件")
	echo"󰇮"
	;;
"Spark")
	echo"󰇮"
	;;
"Outlook" | "Microsoft Outlook")
	echo"󰴢"
	;;
"Thunderbird")
	echo""
	;;

# Productivity
"Notion")
	echo"󰈚"
	;;
"Obsidian")
	echo""
	;;
"Notes" | "备忘录")
	echo"󱞎"
	;;
"Reminders" | "提醒事项")
	echo""
	;;
"Todoist")
	echo""
	;;
"Trello")
	echo""
	;;
"Asana")
	echo""
	;;
"OneNote")
	echo"󰝇"
	;;
"Evernote")
	echo""
	;;

# Design
"Figma")
	echo""
	;;
"Sketch")
	echo""
	;;
"Adobe Photoshop" | "Photoshop")
	echo""
	;;
"Adobe Illustrator" | "Illustrator")
	echo""
	;;
"Adobe XD")
	echo""
	;;
"Blender")
	echo"󰂫"
	;;
"Affinity Designer")
	echo""
	;;
"Affinity Photo")
	echo""
	;;

# Media
"Spotify")
	echo""
	;;
"Music" | "音乐")
	echo"󰝚"
	;;
"TV" | "Apple TV")
	echo"󰝆"
	;;
"VLC")
	echo"󰕼"
	;;
"IINA")
	echo"󰕼"
	;;
"mpv")
	echo""
	;;
"QuickTime Player" | "QuickTime")
	echo""
	;;
"Final Cut Pro")
	echo""
	;;
"Adobe Premiere Pro" | "Premiere Pro")
	echo""
	;;

# System & Utilities
"Finder" | "访达")
	echo"󰀶"
	;;
"System Settings" | "System Preferences" | "系统设置")
	echo""
	;;
"Activity Monitor")
	echo"󰔰"
	;;
"Calculator" | "计算器")
	echo"󰃬"
	;;
"Calendar" | "日历")
	echo""
	;;
"Contacts" | "通讯录")
	echo"󰛃"
	;;
"Home")
	echo"󰋜"
	;;
"Photos" | "照片")
	echo"󰉏"
	;;
"Preview")
	echo""
	;;
"App Store")
	echo""
	;;

# DevOps & Cloud
"Docker" | "Docker Desktop")
	echo""
	;;
"Kubernetes")
	echo"󱃾"
	;;
"TablePlus")
	echo"󰆼"
	;;
"Postman")
	echo""
	;;
"Insomnia")
	echo""
	;;

# Virtualization
"UTM")
	echo"󰢹"
	;;
"Parallels Desktop" | "Parallels")
	echo""
	;;
"VMware Fusion")
	echo""
	;;
"VirtualBox")
	echo""
	;;

# Office
"Microsoft Word" | "Word")
	echo"󰈬"
	;;
"Microsoft Excel" | "Excel")
	echo"󰈛"
	;;
"Microsoft PowerPoint" | "PowerPoint")
	echo"󰈧"
	;;
"Pages")
	echo""
	;;
"Numbers")
	echo""
	;;
"Keynote")
	echo""
	;;

# Reading & Reference
"Books" | "图书")
	echo"󰂺"
	;;
"PDF Expert")
	echo""
	;;
"Kindle")
	echo""
	;;
"Reeder")
	echo""
	;;

# Gaming
"Steam")
	echo""
	;;
"Epic Games")
	echo""
	;;

# Security & VPN
"1Password")
	echo""
	;;
"Bitwarden")
	echo""
	;;

# Default fallback
*)
	echo""
	;;
esac
