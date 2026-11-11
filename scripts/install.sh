#!/bin/zsh
# Installs the Immersive Third Person Mac port. Only ADDS new files to the game; uninstall.sh removes them again.
# Usage: ./scripts/install.sh <unzipped original mod folder> [game folder] [--dry-run]
set -eu
HERE="${0:A:h:h}"
MOD="${1:-}"; GAME="${2:-$HOME/Library/Application Support/Steam/steamapps/common/Cyberpunk 2077}"; DRY=0
for a in "$@"; do [[ "$a" == "--dry-run" ]] && DRY=1; done
[[ "$GAME" == "--dry-run" ]] && GAME="$HOME/Library/Application Support/Steam/steamapps/common/Cyberpunk 2077"
[[ -n "$MOD" && "$MOD" != "--dry-run" ]] || { echo "usage: $0 <unzipped original mod folder> [game folder] [--dry-run]"; exit 1; }
MOD="${MOD:A}"
die() { echo "ERROR: $*" >&2; exit 1; }

[[ -x "$GAME/engine/tools/scc" ]] || die "game not found at: $GAME (pass the game folder as 2nd argument)"
[[ -d "$GAME/red4ext/plugins/ArchiveXL" && -d "$GAME/red4ext/plugins/input_loader" && -d "$GAME/red4ext/plugins/ModSettings" ]] || die "NightCity Console's frameworks are not installed in the game yet: open the NightCity Console app and press Play once, then quit the game and run this again."
build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$GAME/Cyberpunk2077.app/Contents/Info.plist" 2>/dev/null || true)"
[[ "$build" == "5814786" ]] || echo "WARNING: game build is '$build', this was made for 5814786 (2.5.0)."
[[ "$DRY" != "1" ]] && pgrep -x Cyberpunk2077 >/dev/null && die "the game is running: quit it first."
ARCH="$(find "$MOD" -type d -path '*archive/pc/mod' | head -1)"
[[ -f "$ARCH/immersive_third_person.archive" && -f "$ARCH/immersive_third_person_v_lipsync_en.archive" ]] || die "the two .archive files were not found in the mod folder."
[[ -d "$MOD/r6/tweaks/immersive_third_person" ]] || die "r6/tweaks/immersive_third_person not found in the mod folder."
if [[ "$DRY" != "1" ]]; then
  for d in r6/scripts/immersive_third_person r6/tweaks/immersive_third_person; do
    [[ -e "$GAME/$d" ]] && die "$d already exists in the game: run ./scripts/uninstall.sh first."
  done
fi

echo "1/4 building the Mac scripts ..."
BUILD="$HERE/build"
python3 -I "$HERE/scripts/make_port.py" "$MOD" "$BUILD"

echo "2/4 test-compiling (nothing is changed in the game) ..."
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/r6"
cp -R "$GAME/r6/scripts" "$T/r6/scripts"; rm -rf "$T/r6/scripts/immersive_third_person"
cp -R "$BUILD/r6/scripts/immersive_third_person" "$T/r6/scripts/"
cp -R "$GAME/r6/cache" "$T/r6/cache"; rm -rf "$T/r6/cache/modded"
(cd "$GAME" && ./engine/tools/scc -compile "$T/r6/scripts" -outputCacheFile "$T/out.redscripts" > "$T/scc.log" 2>&1) || true
if ! grep -q 'Output successfully saved' "$T/scc.log"; then
  grep -A4 ERROR "$T/scc.log" | head -40
  die "the scripts do not compile (see above). Nothing was installed."
fi
echo "    compiles OK"
[[ "$DRY" == "1" ]] && { echo "dry run finished: nothing installed."; exit 0; }

echo "3/4 copying files into the game ..."
mkdir -p "$GAME/r6/scripts" "$GAME/r6/tweaks" "$GAME/r6/input" "$GAME/archive/Mac/mod" "$GAME/red4ext/nightcity/mods"
cp -R "$BUILD/r6/scripts/immersive_third_person" "$GAME/r6/scripts/"
cp -R "$MOD/r6/tweaks/immersive_third_person" "$GAME/r6/tweaks/"
cp "$HERE/port/input/itp_mac_input.xml" "$GAME/r6/input/itp_mac_input.xml"
for f in immersive_third_person.archive immersive_third_person_v_lipsync_en.archive; do
  cp "$ARCH/$f" "$GAME/archive/Mac/mod/$f"
  cmp "$ARCH/$f" "$GAME/archive/Mac/mod/$f" || die "copy of $f is corrupt"
done
# NOTE: immersive_third_person.archive.xl (body patch) is intentionally NOT installed: the port was tested without it.

echo "4/4 writing the mod manifest ..."
python3 -I - "$GAME" "$GAME/red4ext/nightcity/mods/immersive-third-person-mac-port.json" <<'PY'
import json, os, sys
g, m = sys.argv[1:]
files = [os.path.join(g, "r6/input/itp_mac_input.xml")]
for d in ("r6/scripts/immersive_third_person", "r6/tweaks/immersive_third_person"):
    for r, _, fs in os.walk(os.path.join(g, d)):
        files += [os.path.join(r, f) for f in fs]
files += [os.path.join(g, "archive/Mac/mod", f) for f in ("immersive_third_person.archive", "immersive_third_person_v_lipsync_en.archive")]
json.dump({"name": "immersive-third-person-mac-port", "source": "mac port (own patches + your copy of the original mod)", "files": sorted(files)}, open(m, "w"), indent=2)
PY
echo
echo "Done. Start the game with NightCity Console's Play button, load a save, press G."
echo "Undo any time with ./scripts/uninstall.sh"
