#!/bin/zsh
# Installs the Immersive Third Person Mac port. Only ADDS new files to the game; uninstall.sh removes them again.
# Usage: ./scripts/install.sh <unzipped original mod folder> [game folder] [--dry-run] [--no-animations] [--static-animations] [--yes]
# Animations: by default the live animation swap (the ITPMac plugin, built here from your copy of the mod) gives V the mod's third-person animations
# only while third person is on. --static-animations uses the older way instead (big archive files that replace the game's animations in both views).
# --no-animations installs neither.
set -eu
HERE="${0:A:h:h}"
DEFAULT_GAME="$HOME/Library/Application Support/Steam/steamapps/common/Cyberpunk 2077"
MOD=""; GAME=""; DRY=0; LIVE=1; STATIC=0; CONS=1; YES=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1;;
    --no-animations) LIVE=0; STATIC=0; CONS=0;;
    --static-animations) LIVE=0; STATIC=1; CONS=1;;
    --yes) YES=1;;
    --*) echo "unknown option $a"; exit 1;;
    *) if [[ -z "$MOD" ]]; then MOD="$a"; elif [[ -z "$GAME" ]]; then GAME="$a"; fi;;
  esac
done
GAME="${GAME:-$DEFAULT_GAME}"
[[ -n "$MOD" ]] || { echo "usage: $0 <unzipped original mod folder> [game folder] [--dry-run] [--no-animations] [--static-animations] [--yes]"; exit 1; }
if (( LIVE || STATIC )) && [[ "$DRY" != "1" && "$YES" != "1" && -t 0 ]]; then
  if (( LIVE )); then
    echo "The live animation swap gives V the mod's third-person animations while third person is on, and the game's own ones in first person."
    echo "It adds a small plugin (built here from your copy of the mod) to the game; nothing in the game is edited. You can switch it off in Mod Settings."
  else
    echo "The animation swap replaces the game's own animations for V (first and third person) with the mod's third-person ones."
    echo "No game file is edited, and you can switch it off any time with ./scripts/animations.sh off (or double-click 'Animations OFF.command')."
  fi
  read "ans?Install the animations? [Y/n] "
  [[ "$ans" == [nN]* ]] && { LIVE=0; STATIC=0; CONS=0; }
fi
MOD="${MOD:A}"
# the unzipped folder may have an extra level (macOS Archive Utility): find the real mod root
_found="$(find "$MOD" -maxdepth 5 -type d -path '*r6/scripts/immersive_third_person' 2>/dev/null | head -1)"
[[ -n "$_found" ]] && MOD="${_found%/r6/scripts/immersive_third_person}"
die() { echo "ERROR: $*" >&2; exit 1; }

[[ -x "$GAME/engine/tools/scc" ]] || die "game not found at: $GAME (pass the game folder as 2nd argument)"
[[ -d "$GAME/red4ext/plugins/ArchiveXL" && -d "$GAME/red4ext/plugins/input_loader" && -d "$GAME/red4ext/plugins/ModSettings" && -d "$GAME/r6/scripts/zz_nightcity_plugins" ]] || die "NightCity Console's runtime is not installed in the game yet: open the NightCity Console app, click Install (then Play once), quit the game, and run this again."
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

echo "1/6 building the Mac scripts ..."
BUILD="$HERE/build"
python3 -I "$HERE/scripts/make_port.py" "$MOD" "$BUILD"

PLUGIN_OK=0
if (( LIVE )); then
  echo "2/6 building the live animation swap plugin from your copy of the mod ..."
  mkdir -p "$BUILD/plugin"
  if python3 -I "$HERE/scripts/make_pairs.py" "$MOD" "$BUILD/plugin/pairs.inc" && "$HERE/scripts/build_plugin.sh" "$BUILD/plugin" "$BUILD/ITPMac.dylib"; then
    if [[ -x "$GAME/red4ext/bin/red4ext_plugin_check" ]]; then
      "$GAME/red4ext/bin/red4ext_plugin_check" "$GAME/red4ext/bin/x64/cyberpunk2077_addresses.json" "$BUILD/ITPMac.dylib" && PLUGIN_OK=1
    else
      PLUGIN_OK=1
    fi
  fi
  if (( ! PLUGIN_OK )); then
    echo "WARNING: the plugin could not be built or checked (see above), so the live animation swap is left out."
    echo "         Everything else is installed. You can try ./scripts/install.sh again later, or use --static-animations."
  fi
fi
(( PLUGIN_OK )) || rm -f "$BUILD/r6/scripts/immersive_third_person/zz_itp_mac_liveswap.reds"   # that script file needs the plugin: never install it alone

echo "3/6 test-compiling (nothing is changed in the game) ..."
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

if (( STATIC )); then
  echo "4/6 building the static animation swap from your copy of the mod (about 420 MB) ..."
  python3 -I "$HERE/scripts/build_swap_archive.py" "$ARCH/immersive_third_person.archive" "$HERE/scripts/animset_map.json" "$BUILD/itp_mac_tpp_animsets.archive" | tail -1
  python3 -I "$HERE/scripts/verify_swap_archive.py" "$BUILD/itp_mac_tpp_animsets.archive" "$ARCH/immersive_third_person.archive" "$HERE/scripts/animset_map.json" | tail -1
  python3 -I "$HERE/scripts/build_swap_archive.py" "$ARCH/immersive_third_person.archive" "$HERE/scripts/animset_map_aim.json" "$BUILD/itp_mac_tpp_aim.archive" | tail -1
  python3 -I "$HERE/scripts/verify_swap_archive.py" "$BUILD/itp_mac_tpp_aim.archive" "$ARCH/immersive_third_person.archive" "$HERE/scripts/animset_map_aim.json" | tail -1
fi
if (( CONS )); then
  echo "4/6 building the healing / pickup animation file (6 MB) ..."
  python3 -I "$HERE/scripts/build_swap_archive.py" "$ARCH/immersive_third_person.archive" "$HERE/scripts/consumables_map.json" "$BUILD/itp_mac_consumables.archive" | tail -1
  python3 -I "$HERE/scripts/verify_swap_archive.py" "$BUILD/itp_mac_consumables.archive" "$ARCH/immersive_third_person.archive" "$HERE/scripts/consumables_map.json" | tail -1
fi
(( LIVE || STATIC || CONS )) || echo "4/6 animations skipped (--no-animations)"
[[ "$DRY" == "1" ]] && { echo "dry run finished: nothing installed."; exit 0; }

echo "5/6 copying files into the game ..."
mkdir -p "$GAME/r6/scripts" "$GAME/r6/tweaks" "$GAME/r6/input" "$GAME/archive/Mac/mod" "$GAME/red4ext/nightcity/mods"
cp -R "$BUILD/r6/scripts/immersive_third_person" "$GAME/r6/scripts/"
cp -R "$MOD/r6/tweaks/immersive_third_person" "$GAME/r6/tweaks/"
cp "$HERE/port/input/itp_mac_input.xml" "$GAME/r6/input/itp_mac_input.xml"
for f in immersive_third_person.archive immersive_third_person_v_lipsync_en.archive; do
  cp "$ARCH/$f" "$GAME/archive/Mac/mod/$f"
  cmp "$ARCH/$f" "$GAME/archive/Mac/mod/$f" || die "copy of $f is corrupt"
done
if (( STATIC )); then
  cp "$BUILD/itp_mac_tpp_animsets.archive" "$GAME/archive/Mac/mod/itp_mac_tpp_animsets.archive"
  cmp "$BUILD/itp_mac_tpp_animsets.archive" "$GAME/archive/Mac/mod/itp_mac_tpp_animsets.archive" || die "copy of the animation archive is corrupt"
  cp "$BUILD/itp_mac_tpp_aim.archive" "$GAME/archive/Mac/mod/itp_mac_tpp_aim.archive"
  cmp "$BUILD/itp_mac_tpp_aim.archive" "$GAME/archive/Mac/mod/itp_mac_tpp_aim.archive" || die "copy of the aim archive is corrupt"
fi
if (( CONS )); then
  cp "$BUILD/itp_mac_consumables.archive" "$GAME/archive/Mac/mod/itp_mac_consumables.archive"
  cmp "$BUILD/itp_mac_consumables.archive" "$GAME/archive/Mac/mod/itp_mac_consumables.archive" || die "copy of the consumables archive is corrupt"
fi
if (( PLUGIN_OK )); then
  mkdir -p "$GAME/red4ext/plugins/ITPMac"
  cp "$BUILD/ITPMac.dylib" "$GAME/red4ext/plugins/ITPMac/ITPMac.dylib"
  cmp "$BUILD/ITPMac.dylib" "$GAME/red4ext/plugins/ITPMac/ITPMac.dylib" || die "copy of the plugin is corrupt"
fi
# NOTE: immersive_third_person.archive.xl (body patch) is intentionally NOT installed: the port was tested without it.

echo "6/6 writing the mod manifest ..."
python3 -I - "$GAME" "$GAME/red4ext/nightcity/mods/immersive-third-person-mac-port.json" "$STATIC" "$CONS" "$PLUGIN_OK" <<'PY'
import json, os, sys
g, m, static, cons, plugin = sys.argv[1:]
files = [os.path.join(g, "r6/input/itp_mac_input.xml")]
for d in ("r6/scripts/immersive_third_person", "r6/tweaks/immersive_third_person"):
    for r, _, fs in os.walk(os.path.join(g, d)):
        files += [os.path.join(r, f) for f in fs]
names = ["immersive_third_person.archive", "immersive_third_person_v_lipsync_en.archive"] + (["itp_mac_tpp_animsets.archive", "itp_mac_tpp_aim.archive"] if static == "1" else []) + (["itp_mac_consumables.archive"] if cons == "1" else [])
files += [os.path.join(g, "archive/Mac/mod", f) for f in names]
if plugin == "1":
    files.append(os.path.join(g, "red4ext/plugins/ITPMac/ITPMac.dylib"))
json.dump({"name": "immersive-third-person-mac-port", "source": "mac port (own patches + your copy of the original mod)", "files": sorted(files)}, open(m, "w"), indent=2)
PY
echo
echo "Done. Start the game with NightCity Console's Play button, load a save, press G."
if (( PLUGIN_OK )); then
cat <<'NOTE'

NOTE ABOUT ANIMATIONS: the live animation swap is on. While third person is on, V uses the mod's third-person animations; in first person she
uses the game's own. It works through a small plugin (red4ext/plugins/ITPMac). Switch it off in Mod Settings -> Gameplay animations -> "Live animation swap".
NOTE
fi
if (( STATIC )); then
cat <<'NOTE'

NOTE ABOUT ANIMATIONS: the static animation swap replaces the game's own animation sets for V in BOTH first and third person
(archive/Mac/mod/itp_mac_tpp_animsets.archive, itp_mac_tpp_aim.archive and itp_mac_consumables.archive); no game file is edited.
If anything looks wrong with V's animations, switch it off with:   ./scripts/animations.sh off        (and back on with: ./scripts/animations.sh on)
NOTE
fi
echo "Remove everything any time with ./scripts/uninstall.sh"
