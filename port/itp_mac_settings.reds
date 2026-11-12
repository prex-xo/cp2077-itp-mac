// Immersive Third Person (Mac port): settings page in NightCity Console's Mod Settings (Settings > Mod Settings).
// Own code. Values are saved by Mod Settings. Hotkeys are NOT here: they live in r6/input/itp_mac_input.xml.

public class ITPMSettings {

  // ---- Key bindings (used when "Use these key bindings" is on) ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Key bindings")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.displayName", "Use these key bindings")
  @runtimeProperty("ModSettings.description", "On: the keys below are used and the key file (r6/input/itp_mac_input.xml) is IGNORED, so the default keys stop working. Off: the key file is used. Pick keys the game does not use (for example not M = map, J = journal, I = inventory), otherwise both actions happen. The third-person toggle is the game's own walk-toggle key (Settings > Controls), G by default.")
  public let useMenuKeys: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Key bindings")
  @runtimeProperty("ModSettings.displayName", "Free look on/off")
  @runtimeProperty("ModSettings.description", "Default key: . . With \"Use these key bindings\" on, this key replaces the default.")
  public let keyFreeLook: EInputKey = EInputKey.IK_Period;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Key bindings")
  @runtimeProperty("ModSettings.displayName", "Quick first person (hold)")
  @runtimeProperty("ModSettings.description", "Default key: , . With \"Use these key bindings\" on, this key replaces the default.")
  public let keyQuick: EInputKey = EInputKey.IK_Comma;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Key bindings")
  @runtimeProperty("ModSettings.displayName", "Shoulder zoom (hold)")
  @runtimeProperty("ModSettings.description", "Default key: ; . With \"Use these key bindings\" on, this key replaces the default.")
  public let keyShoulder: EInputKey = EInputKey.IK_Semicolon;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Key bindings")
  @runtimeProperty("ModSettings.displayName", "Front view (hold)")
  @runtimeProperty("ModSettings.description", "Default key: ' . With \"Use these key bindings\" on, this key replaces the default.")
  public let keyFront: EInputKey = EInputKey.IK_SingleQuote;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Key bindings")
  @runtimeProperty("ModSettings.displayName", "Previous camera profile")
  @runtimeProperty("ModSettings.description", "Default key: [ . With \"Use these key bindings\" on, this key replaces the default.")
  public let keyPrev: EInputKey = EInputKey.IK_LeftBracket;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Key bindings")
  @runtimeProperty("ModSettings.displayName", "Next camera profile")
  @runtimeProperty("ModSettings.description", "Default key: ] . With \"Use these key bindings\" on, this key replaces the default.")
  public let keyNext: EInputKey = EInputKey.IK_RightBracket;

  // ---- Camera ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.displayName", "Active camera profile")
  @runtimeProperty("ModSettings.description", "Which of the 5 camera profiles is on right now (1-5). Also changes when you press the profile keys. Each profile has its own page below.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "5")
  public let activeProfile: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Transition time")
  @runtimeProperty("ModSettings.description", "How long the camera glides from first person to behind V (seconds). V's head model needs a moment to appear; a longer glide hides that wait.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.1")
  @runtimeProperty("ModSettings.max", "1.5")
  public let blendTime: Float = 0.7;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Camera start delay")
  @runtimeProperty("ModSettings.description", "Seconds the camera waits after you press the toggle key, so V's head can appear first. Lower = faster camera, higher = head ready sooner than the camera moves.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "0.8")
  public let startDelay: Float = 0.10;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Wall collision")
  @runtimeProperty("ModSettings.description", "The camera moves closer to V instead of going through walls.")
  public let collision: Bool = true;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Closest camera distance")
  @runtimeProperty("ModSettings.description", "The camera never comes closer to V's head than this when a wall is in the way (metres). Too small and the game hides V's head.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.2")
  @runtimeProperty("ModSettings.max", "1.5")
  public let minDistance: Float = 0.70;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Wall distance")
  @runtimeProperty("ModSettings.description", "Gap kept between the camera and a wall, in metres.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.05")
  @runtimeProperty("ModSettings.max", "1.0")
  public let collisionMargin: Float = 0.25;

  // ---- Controls ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.category.order", "20")
  @runtimeProperty("ModSettings.displayName", "Vertical look speed")
  @runtimeProperty("ModSettings.description", "How fast the camera tilts up and down with the mouse.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.02")
  @runtimeProperty("ModSettings.max", "0.4")
  public let pitchSens: Float = 0.10;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Free look speed")
  @runtimeProperty("ModSettings.description", "How fast the camera orbits around V in free look.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.02")
  @runtimeProperty("ModSettings.max", "0.4")
  public let freeLookSens: Float = 0.10;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "First person in scanner / quickhacks")
  @runtimeProperty("ModSettings.description", "Switch to first person while the scanner / quickhack view (Tab) is open. Third person makes that slow-motion view choppy.")
  public let scannerFpp: Bool = true;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Third person while only in combat alert")
  @runtimeProperty("ModSettings.description", "Off (default, like the original): first person whenever you are in combat. On: stay in third person in combat as long as nothing is in your hand (a drawn weapon, takedowns and left-hand cyberware still switch).")
  public let alertTpp: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Third person in elevators")
  @runtimeProperty("ModSettings.description", "Off (default, like the original mod): first person inside elevators, because the camera can see through the cabin walls.")
  public let elevatorTpp: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Invert vertical look")
  public let invertPitch: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Camera smoothing")
  @runtimeProperty("ModSettings.description", "Lower = smoother and slower to follow, higher = snappier.")
  @runtimeProperty("ModSettings.step", "0.02")
  @runtimeProperty("ModSettings.min", "0.02")
  @runtimeProperty("ModSettings.max", "1.0")
  public let smooth: Float = 0.12;


  // ---- Camera profiles 1-5 (switch with [ and ]); each has its own values ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 1")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "Side offset")
  @runtimeProperty("ModSettings.description", "How far the camera sits to the right of V (negative = left shoulder). Camera profile 1.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "-1.5")
  @runtimeProperty("ModSettings.max", "1.5")
  public let p1side: Float = 0.4;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 1")
  @runtimeProperty("ModSettings.displayName", "Distance")
  @runtimeProperty("ModSettings.description", "How far behind V the camera sits. Camera profile 1.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "8.0")
  public let p1distance: Float = 2.7;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 1")
  @runtimeProperty("ModSettings.displayName", "Height")
  @runtimeProperty("ModSettings.description", "Camera height above V's feet. Camera profile 1.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.6")
  @runtimeProperty("ModSettings.max", "3.0")
  public let p1height: Float = 1.6;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 1")
  @runtimeProperty("ModSettings.displayName", "Field of view")
  @runtimeProperty("ModSettings.description", "Third-person field of view in degrees. Camera profile 1.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "30.0")
  @runtimeProperty("ModSettings.max", "110.0")
  public let p1fov: Float = 60.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 2")
  @runtimeProperty("ModSettings.category.order", "102")
  @runtimeProperty("ModSettings.displayName", "Side offset")
  @runtimeProperty("ModSettings.description", "How far the camera sits to the right of V (negative = left shoulder). Camera profile 2.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "-1.5")
  @runtimeProperty("ModSettings.max", "1.5")
  public let p2side: Float = 0.55;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 2")
  @runtimeProperty("ModSettings.displayName", "Distance")
  @runtimeProperty("ModSettings.description", "How far behind V the camera sits. Camera profile 2.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "8.0")
  public let p2distance: Float = 1.6;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 2")
  @runtimeProperty("ModSettings.displayName", "Height")
  @runtimeProperty("ModSettings.description", "Camera height above V's feet. Camera profile 2.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.6")
  @runtimeProperty("ModSettings.max", "3.0")
  public let p2height: Float = 1.55;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 2")
  @runtimeProperty("ModSettings.displayName", "Field of view")
  @runtimeProperty("ModSettings.description", "Third-person field of view in degrees. Camera profile 2.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "30.0")
  @runtimeProperty("ModSettings.max", "110.0")
  public let p2fov: Float = 60.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 3")
  @runtimeProperty("ModSettings.category.order", "103")
  @runtimeProperty("ModSettings.displayName", "Side offset")
  @runtimeProperty("ModSettings.description", "How far the camera sits to the right of V (negative = left shoulder). Camera profile 3.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "-1.5")
  @runtimeProperty("ModSettings.max", "1.5")
  public let p3side: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 3")
  @runtimeProperty("ModSettings.displayName", "Distance")
  @runtimeProperty("ModSettings.description", "How far behind V the camera sits. Camera profile 3.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "8.0")
  public let p3distance: Float = 2.2;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 3")
  @runtimeProperty("ModSettings.displayName", "Height")
  @runtimeProperty("ModSettings.description", "Camera height above V's feet. Camera profile 3.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.6")
  @runtimeProperty("ModSettings.max", "3.0")
  public let p3height: Float = 1.9;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 3")
  @runtimeProperty("ModSettings.displayName", "Field of view")
  @runtimeProperty("ModSettings.description", "Third-person field of view in degrees. Camera profile 3.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "30.0")
  @runtimeProperty("ModSettings.max", "110.0")
  public let p3fov: Float = 60.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 4")
  @runtimeProperty("ModSettings.category.order", "104")
  @runtimeProperty("ModSettings.displayName", "Side offset")
  @runtimeProperty("ModSettings.description", "How far the camera sits to the right of V (negative = left shoulder). Camera profile 4.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "-1.5")
  @runtimeProperty("ModSettings.max", "1.5")
  public let p4side: Float = 0.7;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 4")
  @runtimeProperty("ModSettings.displayName", "Distance")
  @runtimeProperty("ModSettings.description", "How far behind V the camera sits. Camera profile 4.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "8.0")
  public let p4distance: Float = 3.6;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 4")
  @runtimeProperty("ModSettings.displayName", "Height")
  @runtimeProperty("ModSettings.description", "Camera height above V's feet. Camera profile 4.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.6")
  @runtimeProperty("ModSettings.max", "3.0")
  public let p4height: Float = 1.7;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 4")
  @runtimeProperty("ModSettings.displayName", "Field of view")
  @runtimeProperty("ModSettings.description", "Third-person field of view in degrees. Camera profile 4.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "30.0")
  @runtimeProperty("ModSettings.max", "110.0")
  public let p4fov: Float = 60.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 5")
  @runtimeProperty("ModSettings.category.order", "105")
  @runtimeProperty("ModSettings.displayName", "Side offset")
  @runtimeProperty("ModSettings.description", "How far the camera sits to the right of V (negative = left shoulder). Camera profile 5.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "-1.5")
  @runtimeProperty("ModSettings.max", "1.5")
  public let p5side: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 5")
  @runtimeProperty("ModSettings.displayName", "Distance")
  @runtimeProperty("ModSettings.description", "How far behind V the camera sits. Camera profile 5.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "8.0")
  public let p5distance: Float = 2.7;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 5")
  @runtimeProperty("ModSettings.displayName", "Height")
  @runtimeProperty("ModSettings.description", "Camera height above V's feet. Camera profile 5.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.6")
  @runtimeProperty("ModSettings.max", "3.0")
  public let p5height: Float = 1.3;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 5")
  @runtimeProperty("ModSettings.displayName", "Field of view")
  @runtimeProperty("ModSettings.description", "Third-person field of view in degrees. Camera profile 5.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "30.0")
  @runtimeProperty("ModSettings.max", "110.0")
  public let p5fov: Float = 60.0;

  // ---- Camera motion (bob, shake, dynamic distance) ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera motion")
  @runtimeProperty("ModSettings.category.order", "15")
  @runtimeProperty("ModSettings.displayName", "Camera motion")
  @runtimeProperty("ModSettings.description", "Walking bob, running shake and a camera that pulls back when you speed up.")
  public let motion: Bool = true;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera motion")
  @runtimeProperty("ModSettings.displayName", "Motion strength")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  public let motionStrength: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera motion")
  @runtimeProperty("ModSettings.displayName", "Dynamic distance")
  @runtimeProperty("ModSettings.description", "The camera pulls back a little when you walk, jog and sprint.")
  public let dynamicDistance: Bool = true;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera motion")
  @runtimeProperty("ModSettings.displayName", "Dynamic height")
  @runtimeProperty("ModSettings.description", "The camera drops when you crouch, slide or sprint.")
  public let dynamicHeight: Bool = true;

  // ---- Original gameplay features ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Gameplay animations")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.displayName", "Original gameplay animations")
  @runtimeProperty("ModSettings.description", "Switches on the original mod's own scripts for dash, consumables, item pickup and similar actions. Experimental on Mac: turn it off if movement or actions feel wrong.")
  public let gameplayFeatures: Bool = true;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Gameplay animations")
  @runtimeProperty("ModSettings.displayName", "Auto vault while sprinting")
  @runtimeProperty("ModSettings.description", "V vaults or climbs obstacles in her way while sprinting, without pressing jump. Off by default, like the original mod. Needs \"Original gameplay animations\" on.")
  public let autoVault: Bool = false;

  // ---- Misc ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Misc")
  @runtimeProperty("ModSettings.category.order", "30")
  @runtimeProperty("ModSettings.displayName", "Show on-screen messages")
  @runtimeProperty("ModSettings.description", "Small messages when third person, free look or a camera profile changes.")
  public let showMessages: Bool = false;

  // value k (0 side, 1 distance, 2 height, 3 field of view) of camera profile idx (0..4)
  public func Val(idx: Int32, k: Int32) -> Float {
    if idx == 0 {
      if k == 0 { return this.p1side; }
      if k == 1 { return this.p1distance; }
      if k == 2 { return this.p1height; }
      return this.p1fov;
    }
    if idx == 1 {
      if k == 0 { return this.p2side; }
      if k == 1 { return this.p2distance; }
      if k == 2 { return this.p2height; }
      return this.p2fov;
    }
    if idx == 2 {
      if k == 0 { return this.p3side; }
      if k == 1 { return this.p3distance; }
      if k == 2 { return this.p3height; }
      return this.p3fov;
    }
    if idx == 3 {
      if k == 0 { return this.p4side; }
      if k == 1 { return this.p4distance; }
      if k == 2 { return this.p4height; }
      return this.p4fov;
    }
    if idx == 4 {
      if k == 0 { return this.p5side; }
      if k == 1 { return this.p5distance; }
      if k == 2 { return this.p5height; }
      return this.p5fov;
    }
    return this.p1side;
  }
}

// Keeps one settings object alive and registered with Mod Settings.
public class ITPMSettingsSystem extends ScriptableSystem {
  public let settings: ref<ITPMSettings>;

  public func Settings() -> ref<ITPMSettings> {
    if !IsDefined(this.settings) {
      this.settings = new ITPMSettings();
      ModSettings.RegisterListenerToClass(this.settings);
    }
    return this.settings;
  }

  private func OnAttach() -> Void {
    this.Settings();
  }
}

@addMethod(PlayerPuppet)
public func ITPMSet() -> ref<ITPMSettings> {
  let sys: ref<ITPMSettingsSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"ITPMSettingsSystem") as ITPMSettingsSystem;
  return sys.Settings();
}
