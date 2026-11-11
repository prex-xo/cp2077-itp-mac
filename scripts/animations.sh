#!/bin/zsh
# Switch the animation swap on or off without touching anything else. It only renames the file, never deletes it.
# Usage: ./scripts/animations.sh on|off|status [game folder]
GAME="${2:-$HOME/Library/Application Support/Steam/steamapps/common/Cyberpunk 2077}"
M="$GAME/archive/Mac/mod"; N="itp_mac_tpp_animsets.archive"
pgrep -x Cyberpunk2077 >/dev/null && { echo "the game is running: quit it first."; exit 1; }
case "$1" in
  off) if [[ -e "$M/$N" ]]; then mv "$M/$N" "$M/$N.disabled" && echo "Animation swap is OFF (the file is kept as $N.disabled)."; else echo "The animation swap is not installed or already off."; fi;;
  on)  if [[ -e "$M/$N.disabled" && ! -e "$M/$N" ]]; then mv "$M/$N.disabled" "$M/$N" && echo "Animation swap is ON."; elif [[ -e "$M/$N" ]]; then echo "Already on."; else echo "Not installed: run ./scripts/install.sh again (without --no-animations)."; fi;;
  status) if [[ -e "$M/$N" ]]; then echo "ON"; elif [[ -e "$M/$N.disabled" ]]; then echo "OFF (disabled)"; else echo "not installed"; fi;;
  *) echo "usage: $0 on|off|status [game folder]";;
esac
