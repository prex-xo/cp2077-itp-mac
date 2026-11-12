# Immersive Third Person for Cyberpunk 2077 on Mac

Third-person camera for the **native Mac version** of Cyberpunk 2077. It is an unofficial port of the PC mod
**Immersive Third Person - Best Of Both Worlds** by CybrDrake, running on [NightCity Console for Mac](https://github.com/ysrdevs/nightcity-console-mac).

## Credit: this is CybrDrake's mod

**All the original work belongs to [CybrDrake](https://www.nexusmods.com/cyberpunk2077/mods/32203).**
The camera system, the animations, the scripts and the design are theirs. This repo only contains the glue code that makes their mod run on a Mac.
It is **not affiliated with or endorsed by CybrDrake**.

- Original mod (Nexus): https://www.nexusmods.com/cyberpunk2077/mods/32203 (ported from version **2.0.1**)
- **This repo contains none of the original mod's files.** You download them yourself from Nexus, and the installer builds the Mac version from your copy.
- Please endorse the original mod on Nexus if you like it. It is a fan port for personal, single-player use.

## Demo video

[![Watch the demo video](https://img.youtube.com/vi/Qqs_4r0ztXE/hqdefault.jpg)](https://youtu.be/Qqs_4r0ztXE)

(Unlisted on YouTube, so it is only reachable from this link: https://youtu.be/Qqs_4r0ztXE)

## What you get

Press **G** to switch between first and third person. Everything below works:

- **Smooth switching** into and out of third person.
- **Automatic first person** when it makes sense: weapon drawn, combat, vehicles, cutscenes and dialogue, scanner / quickhacks (Tab), elevators, terminals, sitting down, and when you control someone else (like the behavioral imprint).
- **5 camera profiles** you can edit, **shoulder zoom**, **front view**, **quick first-person peek**, and **free look**.
- The camera **pulls in at walls** instead of going through them.
- **Camera motion**: bob when walking, shake when running, drop when crouching or sliding, lean when sliding, bump when landing hard.
- **The mod's animations**: dash, healing animation (woman), idle animations, and an optional **auto vault** while sprinting.
- A **settings page** in the game and **rebindable keys**.

## Known issues

- **The head appears a little late** when you switch to third person (the game takes a moment to load her head). This will be improved in a future update.
- Tested mostly with **female V**. Male V works the same way, but has not been tested as much, and the healing animation only exists for female V (the original mod has none for male V).
- Tested by one person on one Mac (Apple M5 Pro, macOS 27.2). Expect some rough edges.

## What is not ported

The original mod also has a small Windows program (a DLL) that does a few extra jobs. Those are **not ported**, because a Windows DLL cannot run on a Mac:

- GTA-style "run in any direction relative to the camera" movement,
- the head render guard,
- third person during cutscenes (the "scene redirect"),
- a fix for the spine bending while aiming.

These are optional edge cases: this port goes to first person for weapons, scenes and vehicles anyway. The loot-pickup hand animation is also not included.

## What you need

- A Mac with **Cyberpunk 2077 from Steam (native macOS), patch 2.5.0**. Only that version was tested.
- **NightCity Console for Mac 1.9.0** (by ysrdevs): https://github.com/ysrdevs/nightcity-console-mac/releases
- The **original mod** from Nexus (free account): https://www.nexusmods.com/cyberpunk2077/mods/32203
  Download the main file **"Immersive Third Person V2" 2.0.1** and unzip it somewhere (about 1.2 GB).
- Python 3 (it comes with the Xcode command line tools: run `xcode-select --install` if `python3` is missing).

## Install

1. **Install NightCity Console.** Drag the app to your Applications folder and open it. Click **Install**, then click **Play** once to check that the game starts. Quit the game.
2. **Download and unzip the original mod** from the Nexus link above.
3. **Get this repo:**
   ```sh
   git clone https://github.com/prex-xo/cp2077-itp-mac.git
   cd cp2077-itp-mac
   ```
4. **Run the installer** with the folder you unzipped (add `--dry-run` first if you want to check without changing anything):
   ```sh
   ./scripts/install.sh "/path/to/unzipped/mod"
   ```
   It builds the Mac scripts from your copy, test-compiles them, and copies everything into the game. It only **adds** files and never overwrites game files.
   It asks if you want the animation swap (see below).
5. **Start the game with NightCity Console's Play button** (not directly from Steam), load a save, and press **G**.

To remove everything: `./scripts/uninstall.sh`

If the installer says the scripts do not compile, you probably have a different version of the mod or the game. Please send me the error text.

## Updating

```sh
cd cp2077-itp-mac
git pull
./scripts/update.sh "/path/to/unzipped/mod"
```

Quit the game first. Your settings are kept. After a game or NightCity Console update, click **Install** in NightCity Console again.

## Controls

**G** switches third person on and off (it is the game's own walk-toggle key). The other keys:

| Key | What it does |
|---|---|
| `.` | free look on/off (it ends by itself when V moves) |
| `,` | quick first person (hold) |
| `;` | shoulder zoom (hold) |
| `'` | front view (hold) |
| `[` and `]` | previous / next camera profile |

**Change the keys:** in the game, go to **Settings → Mod Settings → Immersive Third Person → Key bindings**, turn on *Use these key bindings*, and pick a key for each action.
Choose keys the game does not use (M = map, J = journal and I = inventory would do both things).

**Other settings** are on the same page: camera profiles (side, distance, height, FOV), transition time, how close the camera may come to a wall,
look speed, first person in combat / scanner / elevators, camera motion, auto vault (off by default), and on-screen messages.

## The animation swap: please read

On Windows, a DLL swaps the mod's animations in while you play. That is not possible on a Mac, so the installer does it **once, before the game starts**:
it builds two extra files from your copy of the mod and puts them next to the game's files:

- `itp_mac_tpp_animsets.archive` (about 410 MB): the mod's animations for V.
- `itp_mac_consumables.archive` (6 MB, female V only): the healing animation.

No game file is edited. The swap also applies in first person (it cannot change while you play). In testing, first person looked normal, but if **anything looks wrong with V's animations, switch it off**:

```sh
./scripts/animations.sh off      # back to the game's own animations (files are only renamed)
./scripts/animations.sh on       # on again
```

Quit the game first. You can also double-click **`scripts/Animations OFF.command`** or **`Animations ON.command`**.
You can skip the swap at install time with `--no-animations`. The rest of the mod (camera, free look, settings) works with the swap on or off.

## How it works (short)

- The original mod = a Lua script (Windows only) + game scripts + archives + a Windows DLL. A Mac has no Lua mod loader and cannot run the DLL.
- The original's game scripts and archives run on a Mac almost unchanged. A small patch script fixes the few Windows-only calls.
- The Lua part is rewritten here as game scripts (`port/`). It uses the original's own separate third-person camera and the same numbers and formulas.
  The design is CybrDrake's.
- More technical notes are in [NOTES.md](NOTES.md).

## Plan: NightCity Console "Optional Mods"

NightCity Console has an **Optional Mods** section (mods that install from inside the app). The plan is to propose this port there as a pull request, so that in the end you would not need
to clone this repo or run a script. Nothing is submitted yet, and it is up to NightCity Console's maintainer. Until then, this repo is the way to install it.

- NightCity Console: https://github.com/ysrdevs/nightcity-console-mac
- Its releases: https://github.com/ysrdevs/nightcity-console-mac/releases
- Its optional mods folder: https://github.com/ysrdevs/nightcity-console-mac/tree/main/native25/optional-mods

## Notes

- Do not mix this with other mods that replace the player's entity or animation graph.
- For single-player, personal use, on your own legally owned copy of the game.
- If anyone knows how the original DLL swaps animations while playing, you are very welcome to get in touch.
