#!/bin/bash

# Usage: ./get_time.sh Asia/Kolkata or UTC etc.

if [ -z "$1" ]; then
  echo "Usage: $0 <Timezone>"
  echo "Example: $0 Asia/Kolkata"
  exit 1
fi

TIMEZONE="$1"

# Validate if timezone exists in system zoneinfo
if [ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
  echo "Error: Timezone '$TIMEZONE' not found in /usr/share/zoneinfo"
  exit 2
fi

CURRENT_TIME=$(TZ="$TIMEZONE" date +"%Y-%m-%d %H:%M:%S")
echo "Current time in $TIMEZONE: $CURRENT_TIME"
