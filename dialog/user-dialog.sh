#!/bin/bash
# UserDialog.sh
# Contains reusable dialog functions for macOS shell scripts

# Show a dialog with a message, title, and optional icon
# Usage: show_user_dialog "Title" "Message" ["/path/to/icon.icns"]
show_user_dialog() {
  
  local title="$1"
  local message="$2"
  local icon="$3"

  if [[ -n "$icon" && -e "$icon" ]]; then
    /usr/bin/osascript -e 'display dialog "'"$message"'" with title "'"$title"'" with icon POSIX file "'"$icon"'" buttons {"Okay"} default button 1 giving up after 15'
  else
    /usr/bin/osascript -e 'display dialog "'"$message"'" with title "'"$title"'" buttons {"Okay"} default button 1 giving up after 15'
  fi
}

export -f show_user_dialog
