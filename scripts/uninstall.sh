#!/bin/zsh
# Removes everything install.sh added. Safe to run twice. Usage: ./scripts/uninstall.sh [game folder]
GAME="${1:-$HOME/Library/Application Support/Steam/steamapps/common/Cyberpunk 2077}"
pgrep -x Cyberpunk2077 >/dev/null && { echo "the game is running: quit it first."; exit 1; }
rm -rf "$GAME/r6/scripts/immersive_third_person" "$GAME/r6/tweaks/immersive_third_person"
rm -f "$GAME/r6/input/itp_mac_input.xml" "$GAME/archive/Mac/mod/immersive_third_person.archive" "$GAME/archive/Mac/mod/immersive_third_person_v_lipsync_en.archive" "$GAME/red4ext/nightcity/mods/immersive-third-person-mac-port.json"
echo "Removed. The next launch through NightCity Console compiles the scripts without the mod."
