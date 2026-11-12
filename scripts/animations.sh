#!/bin/zsh
# Switch the animation swap (two extra archive files) on or off without touching anything else. It only renames the files, never deletes them.
# Usage: ./scripts/animations.sh on|off|status [game folder]
GAME="${2:-$HOME/Library/Application Support/Steam/steamapps/common/Cyberpunk 2077}"
M="$GAME/archive/Mac/mod"; NAMES=(itp_mac_tpp_animsets.archive itp_mac_consumables.archive)
pgrep -x Cyberpunk2077 >/dev/null && { echo "the game is running: quit it first."; exit 1; }
case "$1" in
  off) n=0; for N in $NAMES; do [[ -e "$M/$N" ]] && mv "$M/$N" "$M/$N.disabled" && n=$((n+1)); done
       (( n )) && echo "Animation swap is OFF ($n file(s) kept as .disabled)." || echo "The animation swap is not installed or already off.";;
  on)  n=0; for N in $NAMES; do [[ -e "$M/$N.disabled" && ! -e "$M/$N" ]] && mv "$M/$N.disabled" "$M/$N" && n=$((n+1)); done
       (( n )) && echo "Animation swap is ON." || { [[ -e "$M/${NAMES[1]}" ]] && echo "Already on." || echo "Not installed: run ./scripts/install.sh again (without --no-animations)."; };;
  status) if [[ -e "$M/${NAMES[1]}" ]]; then echo "ON"; elif [[ -e "$M/${NAMES[1]}.disabled" ]]; then echo "OFF (disabled)"; else echo "not installed"; fi;;
  *) echo "usage: $0 on|off|status [game folder]";;
esac
