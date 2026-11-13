# Immersive Third Person for Cyberpunk 2077 on Mac

Third-person camera for the **native Mac version** of Cyberpunk 2077. It is an unofficial port of the PC mod
**Immersive Third Person - Best Of Both Worlds** by CybrDrake, running on [NightCity Console for Mac](https://github.com/ysrdevs/nightcity-console-mac).

## Credit: this is CybrDrake's mod

**All the original work belongs to [CybrDrake](https://www.nexusmods.com/cyberpunk2077/mods/32203).**
The camera system, the animations, the scripts and the design are theirs. This repo only contains the glue code that makes their mod run on a Mac.
It is **not affiliated with or endorsed by CybrDrake**.

- Original mod (Nexus): https://www.nexusmods.com/cyberpunk2077/mods/32203 (ported from version **2.0.1**)
- **This repo contains none of the original mod's files.** You download them yourself from Nexus, and the installer builds the Mac version from your copy.
- Please endorse the original mod on Nexus if you like it.

## Demo video

[![Watch the demo video](https://img.youtube.com/vi/131FJ6Wov84/hqdefault.jpg)](https://youtu.be/131FJ6Wov84)

Video link: https://youtu.be/131FJ6Wov84

## What you get

Press **G** to switch between first and third person. Everything below works:

- **Smooth switching** into and out of third person, with V's head there at once (see the tip below).
- **Automatic first person** when it makes sense: weapon drawn, vehicles, scanner / quickhacks (Tab), braindance, and when you control someone else (like the behavioral imprint). Putting your weapon away brings third person back, in combat or not. Pressing a weapon key (1 to 4) starts the switch right away, so the camera does not jump when the gun appears.
- **Cutscenes and actions in third person** (your choice, both off by default): sitting, lying down, drinking coffee, eating, washing, scrubbing, drinking water, conversations, and real cinematic cutscenes. While sitting you can look around with the mouse. It works in several cutscenes, for example the quiet scene with Judy in the screenshot description below.
- **5 camera profiles** you can edit, **shoulder zoom**, **front view**, **quick first-person peek**, and **free look**.
- The camera **pulls in at walls** instead of going through them.
- **Camera motion**: bob when walking, shake when running, drop when crouching or sliding, lean when sliding, bump when landing hard.
- **The mod's animations**: dash, healing animation (female V), idle animations, **loot pickup animation** (female V) with a speed setting, and an optional **auto vault** while sprinting.
- **Head follows camera**: when V stands still, her head turns to where the camera looks.
- A **settings page** in the game and **rebindable keys**.

### Screenshot: third person in a cutscene

During testing, third person also worked in several cutscenes. One example is the quiet scene with Judy at the window (Judy's arm around V's shoulders, the camera behind both of them, subtitle "But as of right now... I've still got a reason to stay."). V was in third person the whole time, with the dialogue choice shown as usual.
Cutscenes are made for first person, so V can look a little stiff in some of them. That is why the cutscene options are off by default.

### Tip: remove the late head

If V's head appears a moment after you switch to third person, open **Mod Settings → Immersive Third Person → Camera** and set **Transition time** to the lowest value (**0.10**). The head then shows up instantly with no blur in testing.

## All settings

Everything is under **Settings → Mod Settings → Immersive Third Person**. Defaults are in brackets.

### Key bindings
| Setting | What it does |
|---|---|
| Use these key bindings (off) | On: the keys below are used and the key file is ignored. Off: the default keys are used. Pick keys the game does not use. |
| Free look on/off (`.`) | Orbit the camera around V. It ends by itself when V moves. |
| Quick first person, hold (`,`) | Look through V's eyes while held. |
| Shoulder zoom, hold (`;`) | Closer camera while held. |
| Front view, hold (`'`) | Camera in front of V while held. |
| Previous / next camera profile (`[` and `]`) | Cycle the profiles. |

### Camera
| Setting | What it does |
|---|---|
| Active camera profile (1) | Which of the 5 profiles is on. Also changes with the profile keys. |
| Transition time (0.7 s, range 0.1 to 1.5) | How long the camera glides from first person to behind V. **Set it to 0.10 for an instant head.** |
| Smooth switching (on) | Glide between views. Off switches almost instantly. |
| Camera start delay (0.10 s) | How long the camera waits after you press G, so the head can appear first. |
| Camera distance in elevators (1.2 m) | Maximum camera distance inside an elevator, so it stays in the cabin. |
| Wall collision (on) | The camera moves closer to V instead of going through walls. |
| Closest camera distance (0.70 m) | The camera never comes closer to V's head than this when a wall is in the way. |
| Wall distance (0.25 m) | Gap kept between the camera and a wall. |
| Keep the head loaded, experimental (off) | Keeps V's third-person head attached in first person, so it is already there. If you see hair or the head in first person, turn it off. |

### Controls
| Setting | What it does |
|---|---|
| Vertical look speed (0.10) | Mouse speed up and down. |
| Free look speed (0.10) | How fast the camera orbits in free look. |
| Camera smoothing (0.12) | Lower is smoother and slower, higher is snappier. |
| Invert camera horizontal (off) | Reverses sideways movement in free look and while sitting. |
| Invert vertical look (off) | Reverses up and down. |
| First person in scanner / quickhacks (on) | First person while the scanner (Tab) is open, because third person makes that view choppy. |
| Third person at terminals and devices (off) | On: stay in third person at terminals, computers and vending machines. |
| Third person in elevators (off) | On: stay in third person inside elevators. |
| Profiles the keys cycle through (5) | How many profiles the next and previous keys cycle through. |
| Remember perspective (off) | After loading a save, go back to third person if you left it on. |

### Cutscenes and actions
| Setting | What it does |
|---|---|
| Third person during actions and interactions (off) | Sitting, lying down, coffee, eating, washing, scrubbing, drinking water, conversations and similar. Off: first person during them. |
| Third person in cutscenes (off) | Cinematic cutscenes. Off: first person. On: third person, V can look stiff. |

### Camera profile 1 to 5 (one page each)
Each profile has: **Side offset** (right of V, negative = left shoulder), **Distance** (behind V), **Height**, **Field of view**, **Shoulder angle** (swings the camera around V) and **Head angle** (tilts the camera up or down). Defaults: profile 1 is 0.4 / 2.7 / 1.6, profile 2 is 0.55 / 1.6 / 1.55, profile 3 is 0 / 2.2 / 1.9, profile 4 is 0.7 / 3.6 / 1.7, profile 5 is 0 / 2.7 / 1.3 (side / distance / height), all with field of view 60.

### Camera motion
| Setting | What it does |
|---|---|
| Camera motion (on) | Walking bob, running shake and a camera that pulls back when you speed up. |
| Motion strength (1.0) | How strong the motion is. |
| Dynamic distance (on) | The camera pulls back a little when you walk, jog and sprint. |
| Dynamic height (on) | The camera drops when you crouch, slide or sprint. |

### Gameplay animations
| Setting | What it does |
|---|---|
| Original gameplay animations (on) | The original mod's own scripts for dash, consumables, pickup and similar. Turn it off if movement feels wrong. The next four settings need it on. |
| Auto vault while sprinting (off) | V vaults or climbs obstacles while sprinting, without pressing jump. |
| Item pickup animation (on) | V reaches out with her hand when she picks up loot (female V only). |
| Head follows camera (on) | While V stands still, her head turns toward where the camera looks. |
| Head turns to the person you talk to (off) | During conversations V looks at the speaker. |
| Head follows camera in cutscenes and while sitting (off) | Off: head follow only in normal gameplay. On: also in cutscenes, dialogue scenes and while sitting. |

### Pickup animation
| Setting | What it does |
|---|---|
| Pickup animation speed (2.0, range 1 to 4) | How fast the hand reaches out. 1 is the original speed. Only V is sped up, and only while the pickup plays. |

### Weapon camera (experimental, not being worked on)
The setting **Shoulder camera with a weapon (off)** keeps third person with a close over-the-shoulder camera while you aim. Its page sets the side offset (0.45), distance (0.80), height (1.60) and field of view (42). It is kept in the mod, but it is an experiment. With a gun, V's arms look stiff because the original mod has no third-person gun animations.

### Misc
| Setting | What it does |
|---|---|
| Show on-screen messages (off) | Small messages when third person, free look or a profile changes. Also shows when the pickup animation and head follow start. |
| Camera profile messages (on) | A message naming the profile when you switch it. |
| Camera-blocked messages (on) | A message saying why third person did not start. |

## Known issues

- **Stiff arms with a gun** in third person (the original mod has no third-person gun animations).
- Cutscenes can look a little stiff in third person, which is why those options are off by default.
- Tested mostly with **female V**. Male V works the same way, but has not been tested as much, and the healing and pickup animations only exist for female V (the original mod has none for male V).
- Tested by one person on one Mac (Apple M5 Pro, macOS 27.2). Expect some rough edges.

## What is not ported

The original mod also has a small Windows program (a DLL) that does a few extra jobs. A Windows DLL cannot run on a Mac, so these are **not ported**:

- GTA-style "run in any direction relative to the camera" movement,
- the head render guard (stops V's head fading when the camera is very close),
- the scene redirect (makes V use the mod's animations inside cutscenes, so V can look stiff there).

Also left out: the original's developer API and its window (Mod Settings replaces the window), about 300 animation sets that could not be identified, and the four main movement sets (they shifted the first-person aim).

## Future plan

- **A native Mac plugin** could bring the DLL features over, using NightCity Console's RED4ext. It would mean reverse engineering the DLL and finding the matching functions in the Mac game, which is a large job with an uncertain result. The first candidate would be the GTA-style movement. Details are in [NOTES.md](NOTES.md).
- Asking the original author how the DLL does these jobs would save most of the work.
- Proposing this port as a NightCity Console "Optional Mod" (see below).

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

All other settings are listed in **All settings** above.

## The animation swap: please read

On Windows, a DLL swaps the mod's animations in while you play. That is not possible on a Mac, so the installer does it **once, before the game starts**:
it builds three extra files from your copy of the mod and puts them next to the game's files:

- `itp_mac_tpp_animsets.archive` (about 80 MB): the mod's third-person versions of V's everyday animations (walking, idles, world actions). It leaves out the main movement sets, the gun/aim sets and the quest-scene sets on purpose, because those made first-person aiming shift or cutscenes look stiff.
- `itp_mac_tpp_aim.archive` (about 90 MB): the mod's versions of the gun/aim movement sets. You will hardly see a difference.
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
- If anyone knows how the original DLL swaps animations while playing, you are very welcome to get in touch.
