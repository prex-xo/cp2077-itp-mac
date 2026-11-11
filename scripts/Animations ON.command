#!/bin/zsh
# Double-click to switch the animation swap back ON. Quit the game first.
cd "${0:A:h}/.." && ./scripts/animations.sh on
echo; read -k 1 "?Press any key to close this window."
