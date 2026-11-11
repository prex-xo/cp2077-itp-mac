// Immersive Third Person (Mac port): settings page in NightCity Console's Mod Settings (Settings > Mod Settings).
// Own code. Values are saved by Mod Settings. Hotkeys are NOT here: they live in r6/input/itp_mac_input.xml.

public class ITPMSettings {
  // ---- Camera ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.displayName", "Side offset")
  @runtimeProperty("ModSettings.description", "How far the camera sits to the right of V (negative = left shoulder). Camera profile 1.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "-1.5")
  @runtimeProperty("ModSettings.max", "1.5")
  public let side: Float = 0.40;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Distance")
  @runtimeProperty("ModSettings.description", "How far behind V the camera sits. Camera profile 1.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "8.0")
  public let distance: Float = 2.70;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Height")
  @runtimeProperty("ModSettings.description", "Camera height above V's feet. Camera profile 1.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.6")
  @runtimeProperty("ModSettings.max", "3.0")
  public let height: Float = 1.60;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Field of view")
  @runtimeProperty("ModSettings.description", "Third-person field of view in degrees.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "30.0")
  @runtimeProperty("ModSettings.max", "110.0")
  public let fov: Float = 60.0;

  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Camera")
  @runtimeProperty("ModSettings.displayName", "Wall collision")
  @runtimeProperty("ModSettings.description", "The camera moves closer to V instead of going through walls.")
  public let collision: Bool = true;

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

  // ---- Misc ----
  @runtimeProperty("ModSettings.mod", "Immersive Third Person")
  @runtimeProperty("ModSettings.category", "Misc")
  @runtimeProperty("ModSettings.category.order", "30")
  @runtimeProperty("ModSettings.displayName", "Show on-screen messages")
  @runtimeProperty("ModSettings.description", "Small messages when third person, free look or a camera profile changes.")
  public let showMessages: Bool = false;
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
