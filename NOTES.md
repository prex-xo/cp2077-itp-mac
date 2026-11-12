# Technical notes

Findings from porting Immersive Third Person 2.0.1 to NightCity Console 1.9.0 / Cyberpunk 2077 2.5.0 (macOS).

- scc (the redscript compiler) finds the base cache relative to the scripts folder (`r6/scripts` next to `r6/cache`); compile tests need that layout.
- NCC's Mac Codeware lacks `Entity.GetComponents`, `EntityID.ToHash/FromHash`, `entMorphTargetSkinnedMeshComponent.morphResource`, `entSkinnedMeshComponent.mesh`,
  `IComponent.appearanceName/appearancePath`, `*.RefreshAppearance`. `scripts/make_port.py` patches the original's uses of them
  (components are now looked up by name in `port/itp_mac_compat.reds`; the name list is a best guess).
- Mac class names: `CameraComponent`, `FPPCameraComponent`, `TPPCameraComponent`. `gameAnimFeature_TPPRepresentation` is already declared.
- Archives in `archive/Mac/mod` DO override vanilla resources (the mod replaces the player entity templates and the animation graph).
- **The camera:** the original's archive adds a separate camera component `tppCamera` to V. Moving the normal first-person camera does not work:
  the game rewrites its transform every frame (result: the view flickers between first and third person). Activate `tppCamera` instead and set its local
  position/orientation (local frame: x right, y forward, z up; orbit pitch about X, yaw about Z).
- Free look: `FPPCameraComponent` has native properties `headingLocked`, `yawMaxLeft`, `yawMaxRight`, `pitchMax`, `pitchMin`. Declare them with `@addField(...) public native let`.
  `headingLocked` stops the body turning with the mouse; accumulate `CameraMouseX` ourselves and orbit `tppCamera`.
- Input Loader (Mac) merges `r6/input/*.xml`; new actions must also be registered with `RegisterInputListener(this, n"ACTION")` on the player to reach `OnAction`.
- Body swaps (behavioral imprint, flashbacks): the controlled object differs from V's puppet; V's `tppCamera` would still be active. Check
  `PlayerSystem.GetLocalPlayerControlledGameObject()` against the puppet and release the camera.
- Wall collision: `SpatialQueriesSystem.SyncRaycastByCollisionGroup(from, to, n"Static", result, true, false)`.
- Mod Settings annotations work as on Windows (`@runtimeProperty("ModSettings.mod", ...)`); a settings object must be created and passed to `ModSettings.RegisterListenerToClass`.

## Animations (static swap)
- The mod's archive holds 1,386 animation sets; the DLL's table maps ~656 vanilla sets to the mod's third-person versions (stored in `scripts/animset_map.json`, hashes only).
  `scripts/build_swap_archive.py` copies each third-person set's data (no recompression) into a new RDAR archive under the **vanilla** hash.
  Archives in `archive/Mac/mod` override the game's own records, so no official archive is edited and removing the file undoes it.
- Four more pairs (the main locomotion sets, woman and man, in `basegame_1_engine.archive`) were found by reading inside the sets (Kraken-decompressed header,
  matching clip names, skeleton and size): they are the mod's `074ea17b61664914`, `5efb1c71c3532595`, `5ba54ed3a6d3d4e4`, `603042cdf634f68f`.
  Four other "unmapped" mod sets are plain copies of vanilla sets (size = vanilla - 1). Set `3786bd49e4329763` (tpp_buff_*, tpp_consumable_* clips) has no vanilla partner and would have to be added to V.
- Camera/ transition findings: the first-person camera must not be snapped to neutral at the start; start the third-person view from the current first-person pitch and FOV.
- Elevators: the original forces first person (PSM `IsPlayerInsideElevator`); a plain `Static` ray does not see the cabin walls, `Visibility` helps.
- Scanner / quickhack view: PSM `Vision == Focus`.

- **First-person aim shift:** swapping the four main locomotion sets (the mod's `074ea17b..`, `5efb1c71..`, `5ba54ed3..`, `603042cd..`, which carry modified `fpp_*` clips) made the first-person camera shift while aiming. They are left out. The gun/aim sets are left out too (not proven to matter).
- The camera loop must not re-enable the mod's third-person animation states (`xtpp_custom`, `tpp_jump_latch`) while gliding back to first person, otherwise first person keeps them on.
- Mouse-axis listeners (`CameraMouseX/Y`, `CameraX/Y`): register once, never unregister (the game may use the same ones).

- **Key bindings page:** the game's callback system (Codeware `KeyInputEvent`, `GameInstance.GetCallbackSystem().RegisterCallback(n"Input/Key", ...)` with `InputTarget.Key(...)`) delivered no key presses on Mac.
  What works: Input Loader actions. The key file defines an action `ITP_K_<key>` for 67 keys; the script maps the pressed key (`EnumValueFromString("EInputKey", "IK_" + key)`) to the Mod Settings binding.
- **Consumable animation (woman):** V's entity files list the vanilla consumable sets by path (hash = FNV-1a 64 of the lowercase path), but the mod's third-person consumable/buff clips are in a set no entity lists
  (the DLL attaches it at runtime). Static workaround: let that set take the place of a rarely used set in the woman's entity list (`pwa_one_handed_blunt_dildo.anims`). The mod has no man's equivalent.
- **Auto vault:** bridge switch `SetAutoVault` (original option `sprintAutoVault`, default off).
- **Slide tilt / landing shake:** ported from `camera_motion.lua` (roll about the view axis, `q = yaw * pitch * roll`).
