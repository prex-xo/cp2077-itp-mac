#!/bin/zsh
# Double-click to switch the animation swap OFF (the file is only renamed). Quit the game first.
cd "${0:A:h}/.." && ./scripts/animations.sh off
echo; read -k 1 "?Press any key to close this window."
