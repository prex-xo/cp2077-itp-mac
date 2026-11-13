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
  @runtimeProperty("ModSettings.displayName", "Smooth switching")
  @runtimeProperty("ModSettings.description", "The camera glides between first and third person. Off switches almost instantly.")
  public let smoothSwitch: Bool = true;

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
  @runtimeProperty("ModSettings.displayName", "Camera distance in elevators")
  @runtimeProperty("ModSettings.description", "Maximum camera distance inside an elevator (when third person in elevators is on), so the camera stays inside the cabin.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "3.0")
  public let elevatorDistance: Float = 1.2;

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
  @runtimeProperty("ModSettings.category", "Cutscenes and actions")
  @runtimeProperty("ModSettings.category.order", "13")
  @runtimeProperty("ModSettings.displayName", "Third person during actions and interactions")
  @runtimeProperty("ModSettings.description", "Sitting, lying down, drinking coffee, eating, washing, scrubbing, drinking water, conversations and similar actions. Off (default, like the original): first person during them. On: you stay in third person.")
  public let sceneTpp: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Third person at terminals and devices")
  @runtimeProperty("ModSettings.description", "Off (default, like the original): first person at terminals, computers, vending machines and controlled devices, because screens are hard to use from behind V. On: stay in third person there.")
  public let terminalTpp: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Cutscenes and actions")
  @runtimeProperty("ModSettings.displayName", "Third person in cutscenes")
  @runtimeProperty("ModSettings.description", "Off (default): first person during cinematic cutscenes. On: stay in third person. V can look a bit stiff there, because the scenes are made for first person.")
  public let sceneEverything: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Invert camera horizontal")
  @runtimeProperty("ModSettings.description", "Reverses the sideways camera movement in free look and while sitting.")
  public let invertX: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Profiles the keys cycle through")
  @runtimeProperty("ModSettings.description", "How many camera profiles the next and previous keys cycle through, counted from profile 1.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "2")
  @runtimeProperty("ModSettings.max", "5")
  public let hotkeyCount: Int32 = 5;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Controls")
  @runtimeProperty("ModSettings.displayName", "Remember perspective")
  @runtimeProperty("ModSettings.description", "When you load a save, go back to third person if you left it on (remembered per save).")
  public let rememberPerspective: Bool = false;

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
  @runtimeProperty("ModSettings.category", "Camera profile 1")
  @runtimeProperty("ModSettings.displayName", "Shoulder angle")
  @runtimeProperty("ModSettings.description", "Swings the camera around V toward one shoulder (degrees). Camera profile 1.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-60.0")
  @runtimeProperty("ModSettings.max", "60.0")
  public let p1shoulder: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 1")
  @runtimeProperty("ModSettings.displayName", "Head angle")
  @runtimeProperty("ModSettings.description", "Tilts the camera up or down (degrees). Camera profile 1.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-30.0")
  @runtimeProperty("ModSettings.max", "30.0")
  public let p1head: Float = 0.0;

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
  @runtimeProperty("ModSettings.category", "Camera profile 2")
  @runtimeProperty("ModSettings.displayName", "Shoulder angle")
  @runtimeProperty("ModSettings.description", "Swings the camera around V toward one shoulder (degrees). Camera profile 2.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-60.0")
  @runtimeProperty("ModSettings.max", "60.0")
  public let p2shoulder: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 2")
  @runtimeProperty("ModSettings.displayName", "Head angle")
  @runtimeProperty("ModSettings.description", "Tilts the camera up or down (degrees). Camera profile 2.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-30.0")
  @runtimeProperty("ModSettings.max", "30.0")
  public let p2head: Float = 0.0;

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
  @runtimeProperty("ModSettings.category", "Camera profile 3")
  @runtimeProperty("ModSettings.displayName", "Shoulder angle")
  @runtimeProperty("ModSettings.description", "Swings the camera around V toward one shoulder (degrees). Camera profile 3.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-60.0")
  @runtimeProperty("ModSettings.max", "60.0")
  public let p3shoulder: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 3")
  @runtimeProperty("ModSettings.displayName", "Head angle")
  @runtimeProperty("ModSettings.description", "Tilts the camera up or down (degrees). Camera profile 3.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-30.0")
  @runtimeProperty("ModSettings.max", "30.0")
  public let p3head: Float = 0.0;

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
  @runtimeProperty("ModSettings.category", "Camera profile 4")
  @runtimeProperty("ModSettings.displayName", "Shoulder angle")
  @runtimeProperty("ModSettings.description", "Swings the camera around V toward one shoulder (degrees). Camera profile 4.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-60.0")
  @runtimeProperty("ModSettings.max", "60.0")
  public let p4shoulder: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 4")
  @runtimeProperty("ModSettings.displayName", "Head angle")
  @runtimeProperty("ModSettings.description", "Tilts the camera up or down (degrees). Camera profile 4.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-30.0")
  @runtimeProperty("ModSettings.max", "30.0")
  public let p4head: Float = 0.0;

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

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 5")
  @runtimeProperty("ModSettings.displayName", "Shoulder angle")
  @runtimeProperty("ModSettings.description", "Swings the camera around V toward one shoulder (degrees). Camera profile 5.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-60.0")
  @runtimeProperty("ModSettings.max", "60.0")
  public let p5shoulder: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera profile 5")
  @runtimeProperty("ModSettings.displayName", "Head angle")
  @runtimeProperty("ModSettings.description", "Tilts the camera up or down (degrees). Camera profile 5.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-30.0")
  @runtimeProperty("ModSettings.max", "30.0")
  public let p5head: Float = 0.0;

  // ---- Weapon camera (used with "Shoulder camera with a weapon") ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Weapon camera")
  @runtimeProperty("ModSettings.category.order", "12")
  @runtimeProperty("ModSettings.displayName", "Shoulder camera with a weapon (experimental)")
  @runtimeProperty("ModSettings.description", "Off (default): first person when a weapon is drawn. On: stay in third person with a close over-the-shoulder camera whose aim follows the game's own aim. The aim animations were made for first person, so arms and spine may look odd.")
  public let weaponShoulder: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Weapon camera")
  @runtimeProperty("ModSettings.displayName", "Side offset")
  @runtimeProperty("ModSettings.description", "How far the camera sits to the right of V while a weapon is drawn (negative = left shoulder).")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "-1.5")
  @runtimeProperty("ModSettings.max", "1.5")
  public let wSide: Float = 0.45;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Weapon camera")
  @runtimeProperty("ModSettings.displayName", "Distance")
  @runtimeProperty("ModSettings.description", "How far behind V the camera sits while a weapon is drawn.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.3")
  @runtimeProperty("ModSettings.max", "4.0")
  public let wDist: Float = 0.80;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Weapon camera")
  @runtimeProperty("ModSettings.displayName", "Height")
  @runtimeProperty("ModSettings.description", "Camera height above V's feet while a weapon is drawn.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.8")
  @runtimeProperty("ModSettings.max", "2.5")
  public let wHeight: Float = 1.60;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Weapon camera")
  @runtimeProperty("ModSettings.displayName", "Field of view")
  @runtimeProperty("ModSettings.description", "Field of view while a weapon is drawn. Lower zooms in.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "30.0")
  @runtimeProperty("ModSettings.max", "110.0")
  public let wFov: Float = 42.0;

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

  // ---- Live animation swap (the Mac plugin) ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Gameplay animations")
  @runtimeProperty("ModSettings.displayName", "Live animation swap (experimental)")
  @runtimeProperty("ModSettings.description", "Uses the ITPMac plugin to give V the mod's third-person animations only while third person is on, and the game's own animations in first person. Needs the plugin and the original mod's archive. Experimental.")
  public let liveSwap: Bool = true;

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

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Gameplay animations")
  @runtimeProperty("ModSettings.displayName", "Item pickup animation")
  @runtimeProperty("ModSettings.description", "V reaches out with her hand when she picks up loot (female V only, the original mod has no male version). Needs \"Original gameplay animations\" on.")
  public let itemPickupAnim: Bool = true;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Pickup animation")
  @runtimeProperty("ModSettings.category.order", "26")
  @runtimeProperty("ModSettings.displayName", "Pickup animation speed")
  @runtimeProperty("ModSettings.description", "How fast V's hand reaches out when she picks something up. 1 = the original speed, higher = faster. Only V is sped up, and only while the pickup plays.")
  @runtimeProperty("ModSettings.step", "0.25")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "4.0")
  public let pickupSpeed: Float = 2.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Gameplay animations")
  @runtimeProperty("ModSettings.displayName", "Head follows camera")
  @runtimeProperty("ModSettings.description", "While V stands still, her head turns toward where the camera looks. Needs \"Original gameplay animations\" on.")
  public let headLook: Bool = true;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Gameplay animations")
  @runtimeProperty("ModSettings.displayName", "Head turns to the person you talk to")
  @runtimeProperty("ModSettings.description", "During conversations V looks at the speaker. Needs \"Head follows camera\" on.")
  public let headToNpc: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Gameplay animations")
  @runtimeProperty("ModSettings.displayName", "Head follows camera in cutscenes and while sitting")
  @runtimeProperty("ModSettings.description", "Off (default): V's head follows the camera only in normal gameplay, not in cutscenes, dialogue scenes or while sitting. On: it also does it there.")
  public let headInScenes: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Keep the head loaded (experimental)")
  @runtimeProperty("ModSettings.description", "Keeps V's third-person head attached even in first person, so it is already there when you switch (no late head). If you can see the head or hair in first person, turn this off.")
  public let keepHead: Bool = false;

  // ---- Misc ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Misc")
  @runtimeProperty("ModSettings.category.order", "30")
  @runtimeProperty("ModSettings.displayName", "Show on-screen messages")
  @runtimeProperty("ModSettings.description", "Small messages when third person, free look or a camera profile changes.")
  public let showMessages: Bool = false;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Misc")
  @runtimeProperty("ModSettings.displayName", "Camera profile messages")
  @runtimeProperty("ModSettings.description", "A small message naming the camera profile when you switch it (needs on-screen messages).")
  public let profileMessages: Bool = true;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Misc")
  @runtimeProperty("ModSettings.displayName", "Camera-blocked messages")
  @runtimeProperty("ModSettings.description", "When you press the toggle key and third person does not start, a message says why.")
  public let blockMessages: Bool = true;

  // value k (0 side, 1 distance, 2 height, 3 field of view) of camera profile idx (0..4)
  public func Val(idx: Int32, k: Int32) -> Float {
    if idx == 0 {
      if k == 0 { return this.p1side; }
      if k == 1 { return this.p1distance; }
      if k == 2 { return this.p1height; }
      if k == 4 { return this.p1shoulder; }
      if k == 5 { return this.p1head; }
      return this.p1fov;
    }
    if idx == 1 {
      if k == 0 { return this.p2side; }
      if k == 1 { return this.p2distance; }
      if k == 2 { return this.p2height; }
      if k == 4 { return this.p2shoulder; }
      if k == 5 { return this.p2head; }
      return this.p2fov;
    }
    if idx == 2 {
      if k == 0 { return this.p3side; }
      if k == 1 { return this.p3distance; }
      if k == 2 { return this.p3height; }
      if k == 4 { return this.p3shoulder; }
      if k == 5 { return this.p3head; }
      return this.p3fov;
    }
    if idx == 3 {
      if k == 0 { return this.p4side; }
      if k == 1 { return this.p4distance; }
      if k == 2 { return this.p4height; }
      if k == 4 { return this.p4shoulder; }
      if k == 5 { return this.p4head; }
      return this.p4fov;
    }
    if idx == 4 {
      if k == 0 { return this.p5side; }
      if k == 1 { return this.p5distance; }
      if k == 2 { return this.p5height; }
      if k == 4 { return this.p5shoulder; }
      if k == 5 { return this.p5head; }
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
