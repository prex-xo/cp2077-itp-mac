#!/bin/zsh
# Builds ITPMac.dylib from itpmac.cpp + pairs.inc and signs it ad-hoc like the other plugins. Touches nothing in the game.
# Usage: ./scripts/build_plugin.sh <folder containing pairs.inc> <output ITPMac.dylib>
set -eu
HERE="${0:A:h}"; IN="$1"; OUT="$2"
command -v clang++ >/dev/null || { echo "clang++ not found (install the Xcode command line tools: xcode-select --install)"; exit 2; }
mkdir -p "$IN/plugin_src"; cp "$HERE/itpmac.cpp" "$IN/plugin_src/"; cp "$IN/pairs.inc" "$IN/plugin_src/"
clang++ -std=c++20 -O2 -arch arm64 -dynamiclib -fvisibility=hidden -I"$IN/plugin_src" -o "$OUT" "$IN/plugin_src/itpmac.cpp"
codesign -s - -f "$OUT" >/dev/null 2>&1
echo "built $OUT"
