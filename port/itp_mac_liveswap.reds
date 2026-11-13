// Live animation swap through the ITPMac plugin (red4ext/plugins/ITPMac). This file is only installed together with the plugin: a native
// function that the game cannot find makes the game stop at startup.
// The plugin loads the mod's variant animation sets and exchanges their data with the game's sets while third person is on (what the
// original Windows DLL did), and puts the game's data back when third person ends.
public static native func ITPMacSwap(mode: Int32) -> Void;
@addField(PlayerPuppet) public let m_itpSwapT: Float;
@addField(PlayerPuppet) public let m_itpSwapOn: Bool;

@wrapMethod(PlayerPuppet)
public func ITPMLiveSwapTick(force: Bool) -> Void {
  wrappedMethod(force);
  if !this.ITPMSet().liveSwap {
    if this.m_itpSwapOn {
      ITPMacSwap(0);
      this.m_itpSwapOn = false;
    }
    return;
  }
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  if !force && now - this.m_itpSwapT < 1.0 {
    return;                                         // sets stream in and out, so look again every second
  }
  this.m_itpSwapT = now;
  ITPMacSwap(Equals(this.GetResolvedGenderName(), n"Male") ? 2 : 1);     // 1 = female V, 2 = male V (picks the right variant of each set)
  this.m_itpSwapOn = true;
}

@wrapMethod(PlayerPuppet)
public func ITPMLiveSwapPark() -> Void {
  wrappedMethod();
  if this.m_itpSwapOn {
    ITPMacSwap(0);
    this.m_itpSwapOn = false;
  }
}
