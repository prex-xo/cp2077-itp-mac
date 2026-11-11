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

## What works (status)

Roughly **60% of the whole port** is done. The part you use every day (camera and controls) is in good shape.

| Feature | Status |
|---|---|
| Toggle third person (G) | works |
| Third-person camera (the original's separate `tppCamera`), head and clothes | works |
| Automatic first person: weapon drawn, vehicles, cutscenes and dialogue, braindance, other bodies (e.g. behavioral imprint) | works (returning after the long imprint mission still untested) |
| Camera profiles (5), shoulder zoom, front view, quick first person | works |
| **Free look** (toggle) | works |
| Wall collision (camera pulls in at walls) | works (static world only; not cars/props) |
| Camera motion: dynamic distance, walking bob, shake, crouch/sprint height | works (no slide tilt / landing shake yet) |
| Settings menu (Mod Settings) | works |
| Animations from the mod's archive | partial: see Stage 3 |
| First person at terminals / devices | not done (no reliable game signal found yet) |
| 360° movement, loot range, head guard, scene redirect | not done (these are done by the original's Windows DLL) |

## Requirements

- A Mac with **Cyberpunk 2077 from Steam, native macOS version, patch 2.5.0 (build 5814786)**. Only that build was tested.
- **NightCity Console for Mac 1.9.0** (the app *NightCity Console*) by ysrdevs (provides RED4ext, ArchiveXL, TweakXL, Codeware, Input Loader and Mod Settings for the Mac game):
  https://github.com/ysrdevs/nightcity-console-mac/releases
- The original mod from Nexus (free Nexus account): https://www.nexusmods.com/cyberpunk2077/mods/32203
  Download the main file **"Immersive Third Person V2" 2.0.1** and unzip it somewhere. It is a big download (about 1.2 GB).
- Python 3 (comes with the Xcode command line tools: run `xcode-select --install` if `python3` is missing).

## Install: step by step

1. **Install NightCity Console 1.9.0** (the app is called **NightCity Console**; see its releases page for the download and its own instructions).
   It can stay wherever you put it (for example `/Applications`); it does **not** have to go into the game folder.
   Open it and press **Play once**. This installs the frameworks into the game folder (`red4ext/plugins/ArchiveXL`, `input_loader`, `ModSettings`, ...).
   Quit the game afterwards.
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
   - a manifest in `red4ext/nightcity/mods/`
   It only **adds** files; it never overwrites game files.
5. **Start the game with NightCity Console's Play button.** NCC compiles the scripts and starts the game with the frameworks injected.
   Make a manual save first the first time.
6. **In game:** load a save and press **G**.

To remove everything: `./scripts/uninstall.sh`.

If the installer says the scripts don't compile, you most likely have a different version of the original mod or of the game. Send me the error text.

## Controls

Third person is toggled with the game's walk-toggle key (**G** by default). The other keys come from `r6/input/itp_mac_input.xml`
(edit the `IK_...` names to change them; they were chosen because the game leaves them unused):

| Key | Action |
|---|---|
| `G` | third person on/off |
| `.` | free look on/off (camera orbits around V; V's body stays put) |
| `,` | quick first person (hold) |
| `;` | shoulder zoom (hold) |
| `'` | front view (hold) |
| `[` / `]` | previous / next camera profile (5) |

Settings (distance, side, height, FOV, wall collision, look speeds, camera motion, on-screen messages) are in the game's
**Settings → Mod Settings → Immersive Third Person** page.

## How it works (short)

- The original mod = Lua brain (Cyber Engine Tweaks, Windows only) + redscript + archives + a Windows DLL. Mac has no CET and cannot load the DLL.
- The original's **redscript and archives run on Mac almost unchanged**; only a few functions from the Windows Codeware are missing, which `make_port.py` patches.
- The Lua "brain" is re-implemented here in redscript (`port/itp_mac_camera.reds`), using the original's own separate `tppCamera` component
  (so the game's normal camera is never fought) and the same formulas. Settings are `port/itp_mac_settings.reds`.
- Several formulas and default values (camera offsets, shoulder zoom, camera-motion maths) are re-implemented from reading the original's `init.lua` and `camera_motion.lua`: the design is CybrDrake's.
- The DLL's features are **not** ported yet. See below.

## Roadmap: Stage 3 and further

**Stage 3: animations (not done; partly works today).**
The original ships ~1,390 third-person animation sets. On Windows its DLL swaps them into the game **live** (in memory), switching between
first-person and third-person versions. A Windows DLL cannot run on Mac, so today only what the archive's animation graph provides works
(running and walking look right; some other actions can look stiff or like first-person).
Two possible routes:
- **A. Static swap:** put the third-person sets permanently into the archives. Works (tried before on ~500 sets), no live switching, and it means editing game archives (backups needed).
- **B. A native Mac RED4ext plugin** that does the live swap like the DLL. Needs disassembling the Windows DLL; much easier with the author's help or source.

**Stage 4: the DLL's other features (not done).**
360° movement, loot pickup range, head render guard, scene redirect. Also the old known bugs: blurry/blocky head in some views, and spine bending when aiming.

**Smaller open items:** first person at terminals/devices, slide tilt and landing shake, free look refinements.

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
