#!/bin/bash

# Colors for output
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
PURPLE="\033[1;35m"
RESET="\033[0m"

# Icons with Nerd Font
USER_ICON=""          # User icon
OS_ICON=""            # OS icon (Arch Linux styled, for macOS replace as needed)
CPU_ICON=""           # CPU icon
BATTERY_ICON=""       # Battery icon
TEMP_ICON=""          # Temperature icon
WM_ICON="缾"            # Window manager icon
UPTIME_ICON=""        # Uptime icon
MEMORY_ICON=""        # Memory icon
DISK_ICON=""          # Disk icon
IP_ICON=""            # IP icon

# User and host information
USER_INFO="${GREEN}${USER_ICON} $(whoami)@$(hostname)"

# Operating System
OS="${CYAN}${OS_ICON} $(sw_vers -productName) $(sw_vers -productVersion)"

# CPU Information
CPU="${PURPLE}${CPU_ICON} $(sysctl -n machdep.cpu.brand_string)"

# Battery and Temperature (Temperature may not be accessible without third-party tools)
BATTERY="${YELLOW}${BATTERY_ICON} $(pmset -g batt | grep -Eo '\d+%' | head -1)"
TEMP="${RED}${TEMP_ICON} Not Available"  # macOS doesn’t provide CPU temp directly; consider using `istats` tool if needed

# Window Manager (for macOS, typically Finder/Desktop Environment)
WM="${RED}${WM_ICON}Finder"

# Uptime
#UPTIME="${PURPLE}${UPTIME_ICON} $(uptime | awk -F'( |,|:)+' '{print $4" hrs, "$5" mins"}')"
UPTIME="${PURPLE}${UPTIME_ICON} $(uptime | awk -F'( |,|:)+' '{print $4 " " $5}')"

# Memory Usage
MEMORY_INFO=$(vm_stat | awk '/free/ {free=$3} /active/ {active=$3} /inactive/ {inactive=$3} /wired/ {wired=$3} /speculative/ {spec=$3} END {print free, active, inactive, wired, spec}')
MEMORY_USED_MB=$((($(echo $MEMORY_INFO | awk '{print $2+$3+$4+$5}')*4096) / 1024 / 1024))
MEMORY_TOTAL_MB=$((($(sysctl -n hw.memsize) / 1024 / 1024)))
MEMORY="${GREEN}${MEMORY_ICON} ${MEMORY_USED_MB} / ${MEMORY_TOTAL_MB} MB ($(awk "BEGIN {printf \"%.2f\", ($MEMORY_USED_MB/$MEMORY_TOTAL_MB)*100}")%)"

# Disk Usage
DISK_INFO=$(df -h / | tail -1 | awk '{print $3" / "$2" ("$5")"}')
DISK="${CYAN}${DISK_ICON} ${DISK_INFO}"

# IP Address
IP="${YELLOW}${IP_ICON} $(ipconfig getifaddr en0)"

# Emoji icons
ICONS="🍀🌸🐱🐶🐹🐰"

# Print the output
clear
echo -e "============================================"
echo -e "   ${USER_INFO}${RESET}"
echo -e "   ${OS}${RESET}"
echo -e "   ${CPU}${RESET}"
echo -e "   ${BATTERY}${RESET}"
echo -e "   ${TEMP}${RESET}"
echo -e "   ${WM}${RESET}"
echo -e "   ${UPTIME}${RESET}"
echo -e "   ${MEMORY}${RESET}"
echo -e "   ${DISK}${RESET}"
echo -e "   ${IP}${RESET}"
echo -e "   ${ICONS}${RESET}"
echo -e "============================================"