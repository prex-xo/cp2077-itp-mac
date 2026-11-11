# Immersive Third Person for Cyberpunk 2077 on Mac (unofficial port kit)

A personal-use port of **Immersive Third Person – Best Of Both Worlds** to the native macOS version of Cyberpunk 2077,
running on [NightCity Console for Mac](https://github.com/ysrdevs/nightcity-console-mac).

## Credit: this is CybrDrake's mod

**All the original work belongs to [CybrDrake](https://www.nexusmods.com/cyberpunk2077/mods/32203).**
The camera system, the animation graph and animations, the scripts, the art and the whole design are theirs.
This repository only contains the small amount of glue code needed to make that mod run on a Mac, and it is
**not affiliated with or endorsed by CybrDrake**.

- Original mod (Nexus): https://www.nexusmods.com/cyberpunk2077/mods/32203
- Ported from version **2.0.1**.
- **This repository contains none of the original mod's files.** You download them yourself from Nexus (see below).
  That is on purpose: it is CybrDrake's work, not mine to redistribute.
- This is a fan port for personal, single-player use. It needs the original mod to work, so please download it from CybrDrake's
  Nexus page (and endorse it there if you like it): everything that matters here is their work.

## Demo video

[![Watch the demo video](https://img.youtube.com/vi/Qqs_4r0ztXE/hqdefault.jpg)](https://youtu.be/Qqs_4r0ztXE)

Video: https://youtu.be/Qqs_4r0ztXE (unlisted on YouTube, so it is only reachable from this link).

## What works (status)

Roughly **60% of the whole port** is done. The part you use every day (camera and controls) is in good shape.

| Feature | Status |
|---|---|
| Toggle third person (G) | works |
| Third-person camera (the original's separate `tppCamera`), head and clothes | works |
| Smooth first-to-third-person transition | works (the way back to first person is not polished yet) |
| Automatic first person: weapon drawn, vehicles, cutscenes and dialogue, braindance, scanner / quickhack view (Tab), elevators, other bodies (e.g. behavioral imprint) | works (returning after the long imprint mission still untested) |
| 5 camera profiles, each with its own side / distance / height / FOV in the settings menu | works |
| Shoulder zoom, front view, quick first person | works |
| **Free look**: automatic while V stands still; normal third person once she moves | works |
| Wall collision (camera pulls in at walls) | works (static world and visibility geometry; not cars/props) |
| Camera motion: dynamic distance, walking bob, shake, crouch/sprint height | works (no slide tilt / landing shake yet) |
| Settings menu (Mod Settings) | works |
| **Animations** (the mod's third-person animation sets, installed as one extra archive) | works, see the animation note below |
| First person at terminals / devices, takedowns, left-hand cyberware | not done yet |
| Dash, auto-vault, sprint-stop and consumable animations (scripts are in the mod but dormant) | not done yet |
| 360° / GTA-style movement, loot range, head guard, scene redirect | not done (these are done by the original's Windows DLL) |

## Requirements

- A Mac with **Cyberpunk 2077 from Steam, native macOS version, patch 2.5.0 (build 5814786)**. Only that build was tested.
- **NightCity Console for Mac 1.9.0** (the app *NightCity Console*) by ysrdevs (provides RED4ext, ArchiveXL, TweakXL, Codeware, Input Loader and Mod Settings for the Mac game):
  https://github.com/ysrdevs/nightcity-console-mac/releases
- The original mod from Nexus (free Nexus account): https://www.nexusmods.com/cyberpunk2077/mods/32203
  Download the main file **"Immersive Third Person V2" 2.0.1** and unzip it somewhere. It is a big download (about 1.2 GB).
- Python 3 (comes with the Xcode command line tools: run `xcode-select --install` if `python3` is missing).

## Install: step by step

1. **Install NightCity Console 1.9.0:** download it from its releases page, drag **NightCity Console** into your Applications folder and open it
   (it does **not** have to go into the game folder). In the app, click **Install**. This installs the runtime and frameworks into the game
   (`red4ext/plugins/ArchiveXL`, `input_loader`, `ModSettings`, ..., the script compiler, and re-signs the game binary so mods can load).
   Then click **Play** once to check that the game starts, and quit the game. NightCity Console has an install video and a guide in the app.
2. **Download and unzip the original mod** from the Nexus link above. Remember the folder it unzipped to.
3. **Clone this repo:**
   ```sh
   git clone https://github.com/prex-xo/cp2077-itp-mac.git
   cd cp2077-itp-mac
   ```
4. **Run the installer**, giving it the unzipped mod folder. Try the dry run first: it builds and test-compiles but changes nothing in the game.
   ```sh
   ./scripts/install.sh "/path/to/unzipped/mod" --dry-run
   ./scripts/install.sh "/path/to/unzipped/mod"
   ```
   What it does: reads the original's scripts from *your* folder, applies the Mac patches from `scripts/make_port.py`, adds our own three files,
   test-compiles everything with the game's script compiler, then copies into the game:
   - `r6/scripts/immersive_third_person/` (original scripts, patched, plus our `zz_itp_mac_*.reds`)
   - `r6/tweaks/immersive_third_person/` (original tweak files)
   - `r6/input/itp_mac_input.xml` (our hotkeys, loaded by Input Loader)
   - `archive/Mac/mod/immersive_third_person.archive` and `..._v_lipsync_en.archive` (original's archives: they contain the third-person camera component and the animation graph)
   - `archive/Mac/mod/itp_mac_tpp_animsets.archive` (the animation swap, **built on your Mac from your copy of the mod**, see the note below; use `--no-animations` to skip it)
   - a manifest in `red4ext/nightcity/mods/`
   It only **adds** files; it never overwrites game files.
5. **Start the game with NightCity Console's Play button** (not directly from Steam: mods only load when NightCity Console starts the game). NCC compiles the scripts and starts the game with the frameworks injected.
   Make a manual save first the first time.
6. **In game:** load a save and press **G**.

To remove everything: `./scripts/uninstall.sh`.

**After a game or NightCity Console update:** click **Install** (or "Reinstall NightCity Console") in the app again. If the mod stops loading, run
`./scripts/uninstall.sh` and then `./scripts/install.sh ...` again. NightCity Console blocks mod changes while the game is running, and so does the installer.

If the installer says the scripts don't compile, you most likely have a different version of the original mod or of the game. Send me the error text.

## Updating from an older version

If you already installed an earlier version, update like this (your Mod Settings values are kept, except the old single side / distance / height / FOV
settings, which became one page per camera profile):

```sh
cd cp2077-itp-mac
git pull
./scripts/update.sh "/path/to/unzipped/mod"
```

`update.sh` removes the old install and installs the new one (it asks whether you want the animation swap). Quit the game first.
If you prefer, run `./scripts/uninstall.sh` and then `./scripts/install.sh "/path/to/unzipped/mod"` yourself.

## Controls

Third person is toggled with the game's walk-toggle key (**G** by default). The other keys come from `r6/input/itp_mac_input.xml`
(edit the `IK_...` names to change them; they were chosen because the game leaves them unused):

| Key | Action |
|---|---|
| `G` | third person on/off |
| `.` | switch the automatic free look on/off |
| `,` | quick first person (hold) |
| `;` | shoulder zoom (hold) |
| `'` | front view (hold) |
| `[` / `]` | previous / next camera profile (5) |

**Free look** is automatic: when V stands still for a moment, the mouse orbits the camera around her (her body stays put).
As soon as she moves, the camera swings back behind her and it is normal third person.

Settings are in the game's **Settings → Mod Settings → Immersive Third Person** page: an **Active camera profile** selector (shows which of the 5 profiles is on and follows the `[` `]` keys) and one page per camera profile
(side, distance, height, FOV), wall collision, camera start delay (tune it if V's head appears later than the camera),
look speeds, automatic free look, first person in the scanner and in elevators, camera motion, on-screen messages.

## Animations: please read

The mod's big feature is full-body third-person animation. On Windows a DLL swaps the animation sets in memory; a Windows DLL cannot run on Mac.
So the installer does the swap **statically**: it builds one extra archive from your copy of the mod,
`archive/Mac/mod/itp_mac_tpp_animsets.archive` (about 520 MB, 660 animation sets), which replaces the game's own animation sets for V.

- **No game file is edited.** It is an extra file that the game loads after its own archives.
- It affects **first and third person**, because there is no live switching on Mac. In testing, first person looked fine and third person got
  full-body movement, but this is new, so **if anything looks wrong with V's animations, switch it off**:
  ```sh
  ./scripts/animations.sh off      # back to the game's own animations (the file is only renamed)
  ./scripts/animations.sh on       # on again
  ./scripts/animations.sh status
  ```
  Quit the game first. Prefer clicking? Double-click **`scripts/Animations OFF.command`** (or **`Animations ON.command`**).
  The installer also asks whether you want the animation swap; `--no-animations` skips it, `--yes` answers yes without asking.
  (A Mod Settings switch is not possible: the game loads its archives when it starts, so an in-game menu cannot turn one off.)
- Everything else (camera, free look, settings) works with the animation swap on or off.


## How it works (short)

- The original mod = Lua brain (Cyber Engine Tweaks, Windows only) + redscript + archives + a Windows DLL. Mac has no CET and cannot load the DLL.
- The original's **redscript and archives run on Mac almost unchanged**; only a few functions from the Windows Codeware are missing, which `make_port.py` patches.
- The Lua "brain" is re-implemented here in redscript (`port/itp_mac_camera.reds`), using the original's own separate `tppCamera` component
  (so the game's normal camera is never fought) and the same formulas. Settings are `port/itp_mac_settings.reds`.
- Several formulas and default values (camera offsets, shoulder zoom, camera-motion maths) are re-implemented from reading the original's `init.lua` and `camera_motion.lua`: the design is CybrDrake's.
- The DLL's features are **not** ported yet. See below.

## Roadmap: Stage 3 and further

**Stage 3: animations (works as a static swap).**
The original ships ~1,390 third-person animation sets and its Windows DLL swaps them in **live**. Here the same job is done statically
(see the animation note above): 660 sets are replaced through one extra archive. Still open:
- one more set (consumable / buff clips, 15 MB) has no partner in the game and must be *added* to V, which the static swap does not do yet;
- no live switching between first- and third-person versions (the third-person versions are used in both);
- a native Mac RED4ext plugin could still do the live swap like the DLL (needs disassembling the DLL; much easier with the author's help).

**Stage 4: the DLL's other features (not done).**
360° movement, loot pickup range, head render guard, scene redirect. Also the old known bugs: blurry/blocky head in some views, and spine bending when aiming.

**Smaller open items:** first person at terminals/devices, takedowns and left-hand cyberware; waking up the original's dormant dash, auto-vault and consumable features; a key-binding page; slide tilt and landing shake; a smoother return to first person.

Anyone who knows how the DLL swaps animation sets is very welcome to get in touch.

## Future plan: NightCity Console "Optional Mods"

NightCity Console ships a set of **Optional Mods** (ported mods that install from inside the app, no manual steps):
see [`native25/optional-mods`](https://github.com/ysrdevs/nightcity-console-mac/tree/main/native25/optional-mods)
in its repository.

The plan is to propose this port there as a **pull request**, so that in the end you won't need to clone this repo or run any
script: you would pick it in NightCity Console. Nothing has been submitted yet, and whether and how it gets accepted is up to
NightCity Console's maintainer. Until then, this repository is the way to install it.

NightCity Console links:
- Project: https://github.com/ysrdevs/nightcity-console-mac
- Releases (downloads): https://github.com/ysrdevs/nightcity-console-mac/releases
- Optional mods folder: https://github.com/ysrdevs/nightcity-console-mac/tree/main/native25/optional-mods

## Notes

- Do not mix with other mods that replace the player's entity or animation graph.
- Only tested by one person on one machine (Apple M5 Pro, macOS 27.2). Expect rough edges.
- Everything here is for single-player, personal use, on your own legally owned copy of the game.
