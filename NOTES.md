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
