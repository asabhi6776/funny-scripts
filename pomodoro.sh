#!/usr/bin/env bash
set -euo pipefail

# Defaults
WORK_MIN=25
SHORT_MIN=5
LONG_MIN=15
LONG_EVERY=4

usage() {
  cat <<EOF
Pomodoro timer that repeats until you press Ctrl+C

Usage: $(basename "$0") [-w work_min] [-s short_min] [-l long_min] [-n long_every]
Defaults: work=$WORK_MIN, short=$SHORT_MIN, long=$LONG_MIN, long-every=$LONG_EVERY
Example: $(basename "$0") -w 50 -s 10 -l 20 -n 2
EOF
}

# Parse flags
while getopts ":w:s:l:n:h" opt; do
  case "$opt" in
    w) WORK_MIN=${OPTARG} ;;
    s) SHORT_MIN=${OPTARG} ;;
    l) LONG_MIN=${OPTARG} ;;
    n) LONG_EVERY=${OPTARG} ;;
    h) usage; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage; exit 1 ;;
  esac
done

# Colors (fall back if terminal doesn't support)
if tput colors &>/dev/null; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  RED=$(tput setaf 1); GREEN=$(tput setaf 2); CYAN=$(tput setaf 6); YELLOW=$(tput setaf 3)
else
  BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; CYAN=""; YELLOW=""
fi

# Clean exit on Ctrl+C
cleanup() {
  echo
  echo "${DIM}Exiting Pomodoro. Stay awesome!${RESET}"
  exit 0
}
trap cleanup INT

# Notification helpers
ding() {
  # Terminal bell (always)
  printf '\a'
  # Desktop notify (best-effort)
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Pomodoro" "$1"
  elif command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "Pomodoro" -message "$1"
  elif [[ "$OSTYPE" == darwin* ]]; then
    osascript -e 'display notification "'"$1"'" with title "Pomodoro"' >/dev/null 2>&1 || true
  fi
}

# Pretty countdown: countdown <seconds> <label>
countdown() {
  local total=$1; shift
  local label="$*"
  local start=$(date +%s)
  local end=$(( start + total ))
  while :; do
    local now=$(date +%s)
    local remain=$(( end - now ))
    (( remain <= 0 )) && break
    local m=$(( remain / 60 ))
    local s=$(( remain % 60 ))

    # Simple progress bar
    local done=$(( ( (total - remain) * 20 ) / total ))
    local bar=$(printf "%-${done}s" | tr ' ' '#')
    local space=$(printf "%-$((20 - done))s")

    printf "\r${DIM}[%-20s]${RESET} ${BOLD}%s${RESET}  ${CYAN}%02d:%02d${RESET}" "${bar}${space}" "$label" "$m" "$s"
    sleep 1
  done
  printf "\r%*s\r" 80 ""  # clear line
}

echo "${BOLD}Pomodoro started.${RESET} Press ${YELLOW}Ctrl+C${RESET} to quit anytime."
echo "Work: ${WORK_MIN}m  Short: ${SHORT_MIN}m  Long: ${LONG_MIN}m  Long-every: ${LONG_EVERY}"

cycle=0
total_sessions=0

while :; do
  for i in $(seq 1 "$LONG_EVERY"); do
    # Work session
    ((total_sessions++))
    title="Focus #$total_sessions"
    echo "${GREEN}${BOLD}$title${RESET} — $(date +'%H:%M')"
    countdown $(( WORK_MIN * 60 )) "Focus"
    ding "Focus done. Take a break!"

    # Decide break type
    if (( i == LONG_EVERY )); then
      echo "${CYAN}${BOLD}Long Break${RESET} — $(date +'%H:%M')"
      countdown $(( LONG_MIN * 60 )) "Long break"
      ding "Long break done. Back to focus!"
    else
      echo "${CYAN}${BOLD}Short Break${RESET} — $(date +'%H:%M')"
      countdown $(( SHORT_MIN * 60 )) "Short break"
      ding "Short break done. Back to focus!"
    fi
  done
  ((cycle++))
  echo "${DIM}Completed $cycle cycle(s) of $LONG_EVERY sessions.${RESET}"
done
