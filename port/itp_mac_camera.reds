// ITPMac camera v3: body-space over-the-shoulder camera for the native macOS build.
// Own code. Toggle: G (the game's ToggleWalk action).
//
// Why this is more complex than "just offset the camera": the vanilla game has no
// third-person camera component on the player, and the third-person body has no
// animations, so the head the FPP camera is parented to ends up bent over/flipped.
// So we snapshot the head transform once, then drive the camera from the BODY's
// position and facing, converting into head coordinates with that snapshot.


// ---- tunables ---------------------------------------------------------------
public func ITPMCfgSide() -> Float { return 0.40; }      // metres to the right of V
public func ITPMCfgDist() -> Float { return 2.70; }      // metres behind
public func ITPMCfgPivotHeight() -> Float { return 1.60; } // orbit pivot above feet
public func ITPMCfgPitchPerUnitStick() -> Float { return 0.8; }
public func ITPMCfgPivotZ() -> Float { return 1.55; }       // height of the point the wall check starts from (V's head)
public func ITPMCfgKeyDebug() -> Bool { return false; }  // shows a message for each ITP key (testing)
public func ITPMCfgDebug() -> Bool { return false; }       // on-screen pitch/mouse readout
public func ITPMCfgConjugate() -> Bool { return false; }  // flip if rotation looks mirrored
public func ITPMCfgMinHeight() -> Float { return 0.40; }  // camera never lower than this above V's feet
public func ITPMCfgPitchMin() -> Float { return -60.0; }   // look down limit (degrees)
public func ITPMCfgPitchMax() -> Float { return 50.0; }    // look up limit (degrees)
public func ITPMCfgSnapshotDelay() -> Float { return 0.4; }
// -----------------------------------------------------------------------------

@addField(PlayerPuppet) public let m_itpTppOn: Bool;      // third person is actually active right now
@addField(PlayerPuppet) public let m_itpWanted: Bool;     // what the user asked for with G
@addField(PlayerPuppet) public let m_itpPitch: Float;
@addField(PlayerPuppet) public let m_itpUseTpp: Bool;
@addField(PlayerPuppet) public let m_itpProfile: Int32;      // 0..4, camera preset
@addField(PlayerPuppet) public let m_itpShoulder: Bool;      // hold: shoulder zoom
@addField(PlayerPuppet) public let m_itpShoulderB: Float;    // 0..1 blend
@addField(PlayerPuppet) public let m_itpFront: Bool;         // hold: front view
@addField(PlayerPuppet) public let m_itpQuick: Bool;         // hold: quick first person
@addField(PlayerPuppet) public let m_itpFovSet: Float;   // using the mod's own tppCamera component
@addField(PlayerPuppet) public let m_itpSetSince: Bool;
@addField(PlayerPuppet) public let m_itpSkips: Int32;
@addField(PlayerPuppet) public let m_itpPrevW: Vector4;
@addField(PlayerPuppet) public let m_itpPrevCX: Vector4;
@addField(PlayerPuppet) public let m_itpLP: Vector4;   // local position we set last tick
@addField(PlayerPuppet) public let m_itpUx: Vector4;   // local orientation we set last tick, as 3 axes
@addField(PlayerPuppet) public let m_itpUy: Vector4;   // (expressed in head/parent coordinates)
@addField(PlayerPuppet) public let m_itpUz: Vector4;

@addMethod(PlayerPuppet)
public func ITPMNotify(text: String) -> Void {
  if !this.ITPMSet().showMessages {
    return;
  }
  let defs: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
  let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(defs.UI_Notifications);
  let msg: SimpleScreenMessage;
  msg.isShown = true;
  msg.duration = 4.0;
  msg.message = text;
  bb.SetVariant(defs.UI_Notifications.OnscreenMessage, ToVariant(msg), true);
}

// world vector -> parent (head) coordinates, given camera world axes c* and the
// parent-space axes u* that we applied last tick:  Rp^-1 v = sum (v.c_i) u_i
public func ITPMToParent(v: Vector4, cx: Vector4, cy: Vector4, cz: Vector4, ux: Vector4, uy: Vector4, uz: Vector4) -> Vector4 {
  let a: Float = ITPMDot(v, cx);
  let b: Float = ITPMDot(v, cy);
  let c: Float = ITPMDot(v, cz);
  return new Vector4(ux.X * a + uy.X * b + uz.X * c, ux.Y * a + uy.Y * b + uz.Y * c, ux.Z * a + uy.Z * b + uz.Z * c, 0.0);
}

public func ITPMDot(a: Vector4, b: Vector4) -> Float {
  return a.X * b.X + a.Y * b.Y + a.Z * b.Z;
}

public func ITPMRotMatToQuat(m00: Float, m01: Float, m02: Float, m10: Float, m11: Float, m12: Float, m20: Float, m21: Float, m22: Float) -> Quaternion {
  let q: Quaternion;
  let tr: Float = m00 + m11 + m22;
  let s: Float;
  if tr > 0.0 {
    s = SqrtF(tr + 1.0) * 2.0;
    q.r = 0.25 * s;
    q.i = (m21 - m12) / s;
    q.j = (m02 - m20) / s;
    q.k = (m10 - m01) / s;
  } else {
    if m00 > m11 && m00 > m22 {
      s = SqrtF(1.0 + m00 - m11 - m22) * 2.0;
      q.r = (m21 - m12) / s;
      q.i = 0.25 * s;
      q.j = (m01 + m10) / s;
      q.k = (m02 + m20) / s;
    } else {
      if m11 > m22 {
        s = SqrtF(1.0 + m11 - m00 - m22) * 2.0;
        q.r = (m02 - m20) / s;
        q.i = (m01 + m10) / s;
        q.j = 0.25 * s;
        q.k = (m12 + m21) / s;
      } else {
        s = SqrtF(1.0 + m22 - m00 - m11) * 2.0;
        q.r = (m10 - m01) / s;
        q.i = (m02 + m20) / s;
        q.j = (m12 + m21) / s;
        q.k = 0.25 * s;
      }
    }
  }
  if ITPMCfgConjugate() {
    q.i = -q.i;
    q.j = -q.j;
    q.k = -q.k;
  }
  return q;
}

// Third-person head: the game already has head items for this (Items.PlayerWaTppHead / MaTppHead).
// The original mod puts one into the AttachmentSlots.TppHead slot; so do we.
@addMethod(PlayerPuppet)
public func ITPMEquipTppHead(equip: Bool, verbose: Bool) -> Bool {
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
  let slot: TweakDBID = t"AttachmentSlots.TppHead";
  if !equip {
    return ts.RemoveItemFromSlot(this, slot, true, true, true);
  }
  let rec: TweakDBID = t"Items.PlayerWaTppHead";
  if Equals(this.GetResolvedGenderName(), n"Male") {
    rec = t"Items.PlayerMaTppHead";
  }
  let id: ItemID = ItemID.FromTDBID(rec);
  let gave: Bool = false;
  if !ts.HasItem(this, id) {
    gave = ts.GiveItem(this, id, 1);
  }
  // the original mod clears the slot first
  let removed: Bool = ts.RemoveItemFromSlot(this, slot, true, true, true);
  let added: Bool = ts.AddItemToSlot(this, slot, id);
  if !added && verbose {
    this.ITPMNotify("head FAILED: gave=" + ToString(gave) + " has=" + ToString(ts.HasItem(this, id)) + " removed=" + ToString(removed) + " added=" + ToString(added));
  }
  return added;
}

public class ITPMHeadRetryCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let attempt: Int32;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || !p.m_itpTppOn {
      return;
    }
    let last: Bool = this.attempt >= 6;
    if p.ITPMEquipTppHead(true, last) {
      return;
    }
    if !last {
      let cb: ref<ITPMHeadRetryCallback> = new ITPMHeadRetryCallback();
      cb.player = p;
      cb.attempt = this.attempt + 1;
      GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(cb, 0.5, true);
    }
  }
}

// The mod's animation graph keeps its custom third-person states behind an animation-wrapper
// switch called "xtpp_custom" (plus a few float inputs). The original mod's Lua flips them on.
@addMethod(PlayerPuppet)
public func ITPMCustomAnims(on: Bool) -> Void {
  let v: Float = on ? 1.0 : 0.0;
  AnimationControllerComponent.SetAnimWrapperWeight(this, n"xtpp_custom", v);
  AnimationControllerComponent.SetInputFloat(this, n"tpp_jump_latch", v);
}

@addMethod(PlayerPuppet)
public func ITPMResetCamera() -> Void {
  let cam: ref<IPlacedComponent> = this.FindComponentByName(n"camera") as IPlacedComponent;
  if IsDefined(cam) {
    cam.SetLocalPosition(new Vector4(0.0, 0.0, 0.0, 0.0));
    cam.SetLocalOrientation(new Quaternion(0.0, 0.0, 0.0, 1.0));
  }
  this.m_itpSetSince = false;
  this.m_itpSkips = 0;
  this.m_itpLP = new Vector4(0.0, 0.0, 0.0, 0.0);
  this.m_itpUx = new Vector4(1.0, 0.0, 0.0, 0.0);
  this.m_itpUy = new Vector4(0.0, 1.0, 0.0, 0.0);
  this.m_itpUz = new Vector4(0.0, 0.0, 1.0, 0.0);
}

@addMethod(PlayerPuppet)
public func ITPMUpdateCamera() -> Void {
  let cam: ref<IPlacedComponent> = this.FindComponentByName(n"camera") as IPlacedComponent;
  if !IsDefined(cam) {
    return;
  }
  let f: Vector4 = this.GetWorldForward();
  let l: Float = SqrtF(f.X * f.X + f.Y * f.Y);
  if l < 0.001 {
    return;
  }
  let fx: Float = f.X / l;
  let fy: Float = f.Y / l;

  // live camera transform: world axes of the camera and its world position
  let m: Matrix = cam.GetLocalToWorld();
  let cx: Vector4 = m.X;
  let cy: Vector4 = m.Y;
  let cz: Vector4 = m.Z;
  // STALE GUARD: the game refreshes the camera's world matrix once per frame, but this runs on a 10 ms timer.
  // If we already moved the camera and the matrix hasn't changed, it is stale: correcting from it makes the camera jump.
  if this.m_itpSetSince && this.m_itpSkips < 3
      && m.W.X == this.m_itpPrevW.X && m.W.Y == this.m_itpPrevW.Y && m.W.Z == this.m_itpPrevW.Z
      && cx.X == this.m_itpPrevCX.X && cx.Y == this.m_itpPrevCX.Y && cx.Z == this.m_itpPrevCX.Z {
    this.m_itpSkips += 1;
    return;
  }
  this.m_itpSkips = 0;
  this.m_itpPrevW = new Vector4(m.W.X, m.W.Y, m.W.Z, 0.0);
  this.m_itpPrevCX = new Vector4(cx.X, cx.Y, cx.Z, 0.0);
  this.m_itpSetSince = true;
  let ux: Vector4 = this.m_itpUx;
  let uy: Vector4 = this.m_itpUy;
  let uz: Vector4 = this.m_itpUz;
  let lp: Vector4 = this.m_itpLP;
  // head (parent) world origin = camera world pos minus the offset we applied, rotated to world
  let a0: Float = ITPMDot(ux, lp);
  let a1: Float = ITPMDot(uy, lp);
  let a2: Float = ITPMDot(uz, lp);
  let wp: Vector4 = new Vector4(
    m.W.X - (cx.X * a0 + cy.X * a1 + cz.X * a2),
    m.W.Y - (cx.Y * a0 + cy.Y * a1 + cz.Y * a2),
    m.W.Z - (cx.Z * a0 + cy.Z * a1 + cz.Z * a2), 0.0);

  let p: Vector4 = this.GetWorldPosition();
  this.m_itpPitchS += (this.m_itpPitch - this.m_itpPitchS) * this.ITPMSet().smooth;
  let pr: Float = Deg2Rad(this.m_itpPitchS);
  let cp: Float = CosF(pr);
  let sp: Float = SinF(pr);
  // desired camera basis in world: right, look direction, up
  let dx: Vector4 = new Vector4(fy, -fx, 0.0, 0.0);
  let dy: Vector4 = new Vector4(cp * fx, cp * fy, sp, 0.0);
  let dz: Vector4 = new Vector4(dx.Y * dy.Z - dx.Z * dy.Y, dx.Z * dy.X - dx.X * dy.Z, dx.X * dy.Y - dx.Y * dy.X, 0.0);
  // desired world position: orbit around a pivot above V's feet, never below the floor limit
  let wd: Vector4 = new Vector4(
    p.X + dx.X * ITPMCfgSide() - dy.X * ITPMCfgDist(),
    p.Y + dx.Y * ITPMCfgSide() - dy.Y * ITPMCfgDist(),
    p.Z + ITPMCfgPivotHeight() + dx.Z * ITPMCfgSide() - dy.Z * ITPMCfgDist(),
    0.0);
  wd.Z = MaxF(wd.Z, p.Z + ITPMCfgMinHeight());
  let d: Vector4 = new Vector4(wd.X - wp.X, wd.Y - wp.Y, wd.Z - wp.Z, 0.0);

  let newL: Vector4 = ITPMToParent(d, cx, cy, cz, ux, uy, uz);
  let nx: Vector4 = ITPMToParent(dx, cx, cy, cz, ux, uy, uz);
  let ny: Vector4 = ITPMToParent(dy, cx, cy, cz, ux, uy, uz);
  let nz: Vector4 = ITPMToParent(dz, cx, cy, cz, ux, uy, uz);
  cam.SetLocalPosition(newL);
  cam.SetLocalOrientation(ITPMRotMatToQuat(nx.X, ny.X, nz.X, nx.Y, ny.Y, nz.Y, nx.Z, ny.Z, nz.Z));
  this.m_itpLP = newL;
  this.m_itpUx = nx;
  this.m_itpUy = ny;
  this.m_itpUz = nz;
}

// ---- the original mod's way: a separate camera component on V called "tppCamera", switched on with Activate ----

// ---- camera motion: port of the original's camera_motion.lua (core parts) ----
@addField(PlayerPuppet) public let m_itpMT: Float;
@addField(PlayerPuppet) public let m_itpMPos: Vector4;
@addField(PlayerPuppet) public let m_itpMSpeed: Float;
@addField(PlayerPuppet) public let m_itpMSlow: Float;
@addField(PlayerPuppet) public let m_itpMDist: Float;
@addField(PlayerPuppet) public let m_itpMHeight: Float;
@addField(PlayerPuppet) public let m_itpMPhase: Float;
@addField(PlayerPuppet) public let m_itpMClock: Float;
@addField(PlayerPuppet) public let m_itpMSprint: Float;
@addField(PlayerPuppet) public let m_itpMShake: Float;
@addField(PlayerPuppet) public let m_itpMAccel: Float;
@addField(PlayerPuppet) public let m_itpMX: Float;
@addField(PlayerPuppet) public let m_itpMY: Float;
@addField(PlayerPuppet) public let m_itpMZ: Float;
@addField(PlayerPuppet) public let m_itpMYaw: Float;
@addField(PlayerPuppet) public let m_itpMPitch: Float;

public func ITPMApproach(cur: Float, target: Float, response: Float, dt: Float) -> Float {
  if response <= 0.0001 {
    return target;
  }
  return cur + (target - cur) * (1.0 - ExpF(-4.0 / response * dt));
}

public func ITPMSmoothstep(e0: Float, e1: Float, v: Float) -> Float {
  if e1 <= e0 {
    return v >= e1 ? 1.0 : 0.0;
  }
  let t: Float = ClampF((v - e0) / (e1 - e0), 0.0, 1.0);
  return t * t * (3.0 - 2.0 * t);
}

public func ITPMSpeedPull(speed: Float) -> Float {
  if speed <= 0.30 {
    return 0.0;
  }
  if speed <= 2.20 {
    return 0.25 * ITPMSmoothstep(0.30, 2.20, speed);
  }
  if speed <= 5.80 {
    return 0.25 + 0.25 * ITPMSmoothstep(2.20, 5.80, speed);
  }
  return 0.50 + 0.25 * ITPMSmoothstep(5.80, 7.20, speed);
}

@addMethod(PlayerPuppet)
public func ITPMMotionReset() -> Void {
  this.m_itpMT = 0.0;
  this.m_itpMSpeed = 0.0;
  this.m_itpMSlow = 0.0;
  this.m_itpMDist = 0.0;
  this.m_itpMHeight = 0.0;
  this.m_itpMX = 0.0;
  this.m_itpMY = 0.0;
  this.m_itpMZ = 0.0;
  this.m_itpMYaw = 0.0;
  this.m_itpMPitch = 0.0;
}

@addMethod(PlayerPuppet)
public func ITPMMotionStep() -> Void {
  let set: ref<ITPMSettings> = this.ITPMSet();
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  let pos: Vector4 = this.GetWorldPosition();
  let first: Bool = this.m_itpMT <= 0.0;
  let dt: Float = ClampF(now - this.m_itpMT, 0.0, 0.1);
  if !first && dt < 0.0005 {
    return;                                         // same frame, nothing new
  }
  let travel: Float = 0.0;
  if !first {
    let dx: Float = pos.X - this.m_itpMPos.X;
    let dy: Float = pos.Y - this.m_itpMPos.Y;
    travel = SqrtF(dx * dx + dy * dy);
    if travel > 1.5 {
      travel = 0.0;                                 // teleport / fast travel
    }
  }
  this.m_itpMT = now;
  this.m_itpMPos = pos;
  if first || dt <= 0.0 {
    return;
  }
  let raw: Float = travel / dt;
  this.m_itpMSpeed += (raw - this.m_itpMSpeed) * MinF(1.0, dt / 0.08);   // smooth the speed
  let speed: Float = this.m_itpMSpeed;

  if !set.motion {
    this.ITPMMotionReset();
    this.m_itpMT = now;
    this.m_itpMPos = pos;
    return;
  }
  let d: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
  let psm: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), d.PlayerStateMachine);
  let loco: Int32 = IsDefined(psm) ? psm.GetInt(d.PlayerStateMachine.LocomotionDetailed) : 1;
  let crouch: Bool = loco == EnumInt(gamePSMDetailedLocomotionStates.Crouch);
  let sprint: Bool = loco == EnumInt(gamePSMDetailedLocomotionStates.Sprint) || speed >= 5.8;
  let slide: Bool = loco == EnumInt(gamePSMDetailedLocomotionStates.Slide);

  // distance grows with speed
  let pull: Float = set.dynamicDistance ? ITPMSpeedPull(speed) : 0.0;
  this.m_itpMDist = ITPMApproach(this.m_itpMDist, pull, pull < this.m_itpMDist ? 0.70 : 0.25, dt);
  // camera drops when crouching / sliding / sprinting
  let ht: Float = 0.0;
  if set.dynamicHeight {
    if crouch { ht = -0.55; }
    if slide { ht = -0.80; }
    if sprint && !crouch && !slide { ht = -0.35; }
  }
  this.m_itpMHeight = ITPMApproach(this.m_itpMHeight, ht, ht >= -0.0001 && this.m_itpMHeight < -0.0001 ? 0.70 : 0.30, dt);

  let strength: Float = ClampF(set.motionStrength, 0.0, 5.0);
  let amp: Float = strength / 1.5;
  this.m_itpMClock += dt;
  this.m_itpMPhase += travel * (6.2831853 / 1.40);
  this.m_itpMSprint = ITPMApproach(this.m_itpMSprint, sprint ? 1.0 : 0.0, 0.25, dt);
  let shakeT: Float = 0.0;
  if sprint {
    shakeT = 1.50;
  } else {
    if speed >= 3.5 {
      shakeT = 0.50;
    } else {
      if speed >= 0.30 {
        shakeT = 0.25;
      }
    }
  }
  this.m_itpMShake = ITPMApproach(this.m_itpMShake, shakeT, 0.25, dt);
  // tilt when speeding up / slowing down
  this.m_itpMSlow += (speed - this.m_itpMSlow) * MinF(1.0, dt / 0.30);
  let goal: Float = ClampF(-((speed - this.m_itpMSlow) / 0.30) * 0.08, -0.70, 0.70) * 2.0;
  this.m_itpMAccel = ITPMApproach(this.m_itpMAccel, goal, 0.12, dt);

  let mx: Float = 0.0;
  let my: Float = 0.0;
  let mz: Float = 0.0;
  let myaw: Float = 0.0;
  let mpitch: Float = 0.0;
  let tau: Float = 6.2831853;
  if strength > 0.0 {
    if speed < 0.30 && !crouch {
      mz += 0.006 * 2.0 * SinF(this.m_itpMClock * tau * 0.25);
      mpitch += 0.12 * 2.0 * SinF(this.m_itpMClock * tau * 0.25 + 1.5707963);
    } else {
      if speed >= 0.30 && !sprint {
        mz += 0.012 * SinF(this.m_itpMPhase * 2.0);
        mpitch += 0.20 * SinF(this.m_itpMPhase);
      }
    }
    mx += 0.010 * this.m_itpMShake * SinF(this.m_itpMClock * tau * 7.1);
    my += 0.006 * this.m_itpMShake * SinF(this.m_itpMClock * tau * 5.3 + 0.7);
    myaw += 0.35 * this.m_itpMShake * SinF(this.m_itpMClock * tau * 4.1);
    mpitch += this.m_itpMAccel;
  }
  this.m_itpMX = mx * amp;
  this.m_itpMY = my * amp;
  this.m_itpMZ = mz * amp;
  this.m_itpMYaw = myaw * amp;
  this.m_itpMPitch = mpitch * amp;
}

// Five camera presets (cycled with the profile keys). 0 = the default view.  k: 0 side, 1 distance, 2 height
public func ITPMProfileVal(set: ref<ITPMSettings>, idx: Int32, k: Int32) -> Float {
  let side: array<Float> = [0.40, 0.55, 0.00, 0.70, -0.40];
  let dist: array<Float> = [2.70, 1.60, 2.20, 3.60, 2.70];
  let high: array<Float> = [1.60, 1.55, 1.90, 1.70, 1.60];
  let i: Int32 = Clamp(idx, 0, 4);
  if i == 0 {
    // profile 1 is the user's own (Mod Settings)
    if k == 0 { return set.side; }
    if k == 1 { return set.distance; }
    return set.height;
  }
  if k == 0 {
    return side[i];
  }
  if k == 1 {
    return dist[i];
  }
  return high[i];
}

@addMethod(PlayerPuppet)
public func ITPMUpdateTppCam() -> Void {
  let cam: ref<IPlacedComponent> = this.FindComponentByName(n"tppCamera") as IPlacedComponent;
  if !IsDefined(cam) {
    return;
  }
  this.m_itpPitchS += (this.m_itpPitch - this.m_itpPitchS) * this.ITPMSet().smooth;
  this.m_itpShoulderB += ((this.m_itpShoulder ? 1.0 : 0.0) - this.m_itpShoulderB) * 0.2;
  this.ITPMMotionStep();
  let b: Float = this.m_itpShoulderB;
  let th: Float = Deg2Rad(this.m_itpPitchS + this.m_itpMPitch);
  let sideP: Float = ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 0);
  let sgn: Float = sideP < 0.0 ? -1.0 : 1.0;
  // shoulder zoom blends the preset toward: side 0.45, distance 0.80, height 1.60, FOV 42 (original defaults)
  let side: Float = sideP + (sgn * 0.45 - sideP) * b + this.m_itpMX;
  let dist: Float = ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 1) + (0.80 - ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 1)) * b + this.m_itpMDist * (1.0 - b);
  let high: Float = ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 2) + (1.60 - ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 2)) * b + this.m_itpMHeight + this.m_itpMZ;
  let z: Float = MaxF(high - dist * SinF(th), ITPMCfgMinHeight());
  let s: Float = SinF(th * 0.5);
  let c: Float = CosF(th * 0.5);
  // free look returns smoothly to behind V when released
  if !this.m_itpFree && !this.m_itpFront && this.m_itpYaw != 0.0 {
    let step: Float = 8.0;
    if AbsF(this.m_itpYaw) <= step {
      this.m_itpYaw = 0.0;
    } else {
      this.m_itpYaw -= step * (this.m_itpYaw > 0.0 ? 1.0 : -1.0);
    }
  }
  // camera yaw around V: free look yaw, plus 180 degrees for front view
  let yaw: Float = this.m_itpYaw + (this.m_itpFront ? 180.0 : 0.0) + this.m_itpMYaw;
  let ph: Float = Deg2Rad(yaw);
  let ox: Float = side;
  let oy: Float = -dist * CosF(th) + this.m_itpMY;
  let lx: Float = ox * CosF(ph) - oy * SinF(ph);
  let ly: Float = ox * SinF(ph) + oy * CosF(ph);
  // ---- wall collision: ray from V's head to the wanted camera spot; pull the camera in if a wall is in between ----
  let pz: Float = ITPMCfgPivotZ();
  let fwd: Vector4 = this.GetWorldForward();
  let fl: Float = SqrtF(fwd.X * fwd.X + fwd.Y * fwd.Y);
  if this.ITPMSet().collision && fl > 0.001 {
    let fx: Float = fwd.X / fl;
    let fy: Float = fwd.Y / fl;
    let pos: Vector4 = this.GetWorldPosition();
    // local (x right, y forward, z up) -> world
    let sx: Float = pos.X;
    let sy: Float = pos.Y;
    let sz2: Float = pos.Z + pz;
    let ex: Float = pos.X + fy * lx + fx * ly;
    let ey: Float = pos.Y - fx * lx + fy * ly;
    let ez: Float = pos.Z + z;
    let dx: Float = ex - sx;
    let dy: Float = ey - sy;
    let dz: Float = ez - sz2;
    let full: Float = SqrtF(dx * dx + dy * dy + dz * dz);
    let target: Float = 1.0;
    if full > 0.05 {
      let res: TraceResult;
      let hit: Bool = GameInstance.GetSpatialQueriesSystem(this.GetGame()).SyncRaycastByCollisionGroup(new Vector4(sx, sy, sz2, 1.0), new Vector4(ex, ey, ez, 1.0), n"Static", res, true, false);
      if hit && TraceResult.IsValid(res) {
        let hp: Vector4 = Cast<Vector4>(res.position);
        let hd: Float = SqrtF((hp.X - sx) * (hp.X - sx) + (hp.Y - sy) * (hp.Y - sy) + (hp.Z - sz2) * (hp.Z - sz2));
        target = ClampF((hd - this.ITPMSet().collisionMargin) / full, 0.10, 1.0);
      }
    }
    if target < this.m_itpColl {
      this.m_itpColl = target;                      // wall in the way: pull in at once
    } else {
      this.m_itpColl += (target - this.m_itpColl) * 0.08;   // ease back out
    }
    lx = lx * this.m_itpColl;
    ly = ly * this.m_itpColl;
    z = pz + (z - pz) * this.m_itpColl;
  }
  cam.SetLocalPosition(new Vector4(lx, ly, z, 1.0));
  let sz: Float = SinF(ph * 0.5);
  let cz: Float = CosF(ph * 0.5);
  cam.SetLocalOrientation(new Quaternion(cz * s, sz * s, sz * c, cz * c));
  let baseFov: Float = this.ITPMSet().fov;
  let fov: Float = baseFov + (MinF(baseFov, 42.0) - baseFov) * b;
  if AbsF(fov - this.m_itpFovSet) > 0.05 {
    (cam as CameraComponent).SetFOV(fov);
    this.m_itpFovSet = fov;
  }
}

@addMethod(PlayerPuppet)
public func ITPMStartTppCam() -> Bool {
  let cam: ref<CameraComponent> = this.FindComponentByName(n"tppCamera") as CameraComponent;
  if !IsDefined(cam) {
    return false;
  }
  this.m_itpUseTpp = true;
  this.m_itpFovSet = 0.0;
  this.m_itpColl = 1.0;
  this.ITPMMotionReset();
  if ITPMCfgKeyDebug() {
    this.ITPMNotify("tppCamera class: " + NameToString(cam.GetClassName()));
  }
  this.ITPMUpdateTppCam();
  cam.Activate(0.2);
  return true;
}

@addMethod(PlayerPuppet)
public func ITPMStopTppCam() -> Void {
  if !this.m_itpUseTpp {
    return;
  }
  if this.m_itpFree {
    this.ITPMFreeLook(false);
  }
  this.m_itpYaw = 0.0;
  this.m_itpUseTpp = false;
  if !this.ITPMControlsOwnBody() {
    // the player now controls another body: don't touch V's first-person camera, just release ours
    let tpp: ref<CameraComponent> = this.FindComponentByName(n"tppCamera") as CameraComponent;
    if IsDefined(tpp) {
      tpp.Deactivate(0.0);
    }
    return;
  }
  let fpp: ref<FPPCameraComponent> = this.FindComponentByName(n"camera") as FPPCameraComponent;
  if IsDefined(fpp) {
    fpp.ResetPitch();
    fpp.Activate(0.2);
  }
}

public class ITPMStartCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || !p.m_itpTppOn {
      return;
    }
    p.ITPMResetCamera();
    if !p.ITPMStartTppCam() {
      p.ITPMNotify("ITPMac: third person is not available for this body");
      p.m_itpWanted = false;
      p.ITPMSetThirdPerson(false);
      return;
    }
    // head: the game's own activation event attaches it; do NOT re-equip it here
    let hdc: ref<ITPMHeadDiagCallback> = new ITPMHeadDiagCallback();
    hdc.player = p;
    GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(hdc, 0.8, true);
    let cb: ref<ITPMKeepCallback> = new ITPMKeepCallback();
    cb.player = p;
    GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(cb, 0.05, true);
  }
}

public class ITPMKeepCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || !p.m_itpTppOn {
      return;
    }
    if p.m_itpUseTpp {
      p.ITPMUpdateTppCam();
    } else {
      p.ITPMUpdateCamera();
    }
    p.m_itpTick += 1;
    if ITPMCfgDebug() && p.m_itpTick % 50 == 0 {
      p.ITPMNotify("pitch=" + FloatToStringPrec(p.m_itpPitch, 1) + "  rawMouseY=" + FloatToStringPrec(p.m_itpRaw, 3) + "  maxRaw=" + FloatToStringPrec(p.m_itpRawMax, 3));
    }
    if p.m_itpTick % 25 == 0 {
      p.ITPMCustomAnims(true);
    }
    let cb: ref<ITPMKeepCallback> = new ITPMKeepCallback();
    cb.player = p;
    GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(cb, 0.01, true);
  }
}

@addField(PlayerPuppet) public let m_itpAnimWarned: Bool;
@addField(PlayerPuppet) public let m_itpTick: Int32;
@addField(PlayerPuppet) public let m_itpLastPos: Vector4;
@addField(PlayerPuppet) public let m_itpExpShown: Int32;
@addField(PlayerPuppet) public let m_itpIdle: Int32;   // 0.1 s samples with no movement
@addField(PlayerPuppet) public let m_itpPitchS: Float;
@addField(PlayerPuppet) public let m_itpEvtY: Int32;
@addField(PlayerPuppet) public let m_itpNames: String;
@addField(PlayerPuppet) public let m_itpRaw: Float;
@addField(PlayerPuppet) public let m_itpRawMax: Float;

// Tell the animation graph whether to use the stiff "scene" third-person pose.
// Off = the normal locomotion animations (walking, jumping...).
@addMethod(PlayerPuppet)
public func ITPMApplyTppAnim(active: Bool) -> Bool {
  let feature: ref<gameAnimFeature_TPPRepresentation> = new gameAnimFeature_TPPRepresentation();
  if !IsDefined(feature) {
    return false;
  }
  feature.IsActive = active;
  AnimationControllerComponent.ApplyFeature(this, n"TPPRepresentation", feature);
  return true;
}

public class ITPMAnimCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || !p.m_itpTppOn {
      return;
    }
    if !p.ITPMApplyTppAnim(false) && !p.m_itpAnimWarned {
      p.m_itpAnimWarned = true;
      p.ITPMNotify("ITPMac: anim feature class not available");
    }
    let cb: ref<ITPMAnimCallback> = new ITPMAnimCallback();
    cb.player = p;
    GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(cb, 0.4, true);
  }
}

public class ITPMOffCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || p.m_itpTppOn {
      return;
    }
    let sys: ref<TakeOverControlSystem> = GameInstance.GetScriptableSystemsContainer(p.GetGame()).Get(n"TakeOverControlSystem") as TakeOverControlSystem;
    sys.EnablePlayerTPPRepresenation(false);
  }
}

public class ITPMHeadDiagCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || !p.m_itpTppOn {
      return;
    }
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(p.GetGame());
    let occupied: Bool = IsDefined(ts.GetItemInSlot(p, t"AttachmentSlots.TppHead"));
    // the vanilla second step of the vehicle third-person switch
    let fin: ref<FinalizeActivationTPPRepresentationEvent> = new FinalizeActivationTPPRepresentationEvent();
    p.QueueEvent(fin);
    if ITPMCfgDebug() {
      p.ITPMNotify("HEAD slot occupied=" + ToString(occupied) + "; finalize event sent");
    }
  }
}

@addMethod(PlayerPuppet)
public func ITPMSetThirdPerson(enable: Bool) -> Void {
  let cam: ref<IPlacedComponent> = this.FindComponentByName(n"camera") as IPlacedComponent;
  if !IsDefined(cam) {
    this.ITPMNotify("ITPMac: first-person camera component not found");
    return;
  }
  let sys: ref<TakeOverControlSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"TakeOverControlSystem") as TakeOverControlSystem;
  if enable {
    this.m_itpTppOn = true;
    this.m_itpPitch = 0.0;
    this.m_itpPitchS = 0.0;
    this.m_itpEvtY = 0;
    this.m_itpRawMax = 0.0;
    this.m_itpNames = "";
    this.RegisterInputListener(this, n"CameraMouseY");
    this.RegisterInputListener(this, n"CameraY");
    this.RegisterInputListener(this, n"CameraMouseX");
    this.RegisterInputListener(this, n"CameraX");
    // vehicle-style activation: the game's own event (sets up the head/body properly)
    let act: ref<ActivateTPPRepresentationEvent> = new ActivateTPPRepresentationEvent();
    this.QueueEvent(act);
    let cb: ref<ITPMStartCallback> = new ITPMStartCallback();
    cb.player = this;
    GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(cb, ITPMCfgSnapshotDelay(), true);
    this.ITPMCustomAnims(true);
    ITPMBridgeSwitch(this, true);
    this.ITPMNotify("ITPMac: third person ON");
  } else {
    this.m_itpTppOn = false;
    this.UnregisterInputListener(this, n"CameraMouseY");
    this.UnregisterInputListener(this, n"CameraY");
    this.UnregisterInputListener(this, n"CameraMouseX");
    this.UnregisterInputListener(this, n"CameraX");
    this.ITPMEquipTppHead(false, false);
    this.ITPMStopTppCam();
    this.ITPMResetCamera();
    this.ITPMCustomAnims(false);
    this.ITPMApplyTppAnim(true);
    let ocb: ref<ITPMOffCallback> = new ITPMOffCallback();
    ocb.player = this;
    GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(ocb, 0.25, true);
    ITPMBridgeSwitch(this, false);
    this.ITPMNotify("ITPMac: third person OFF");
  }
}

// ---- weapon handling: weapon in hand => first person; holstered => third person if wanted ----
@addMethod(PlayerPuppet)
public func ITPMWeaponDrawn() -> Bool {
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
  return IsDefined(ts.GetItemInSlot(this, t"AttachmentSlots.WeaponRight"));
}

@addField(PlayerPuppet) public let m_itpHold: Int32;   // polls (0.1 s each) left before third person may come back

// false while the player controls a different body (behavioral imprint, Johnny flashbacks, ...): our camera belongs to V's body only.
@addMethod(PlayerPuppet)
public func ITPMControlsOwnBody() -> Bool {
  let c: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
  return IsDefined(c) && Equals(c.GetEntityID(), this.GetEntityID());
}

// How long (in 0.1 s polls) third person must stay off right now; 0 = nothing blocks it.
// Delays follow the original mod's autoPerspective settings.
@addMethod(PlayerPuppet)
public func ITPMBlockHold() -> Int32 {
  let hold: Int32 = 0;
  if !this.ITPMControlsOwnBody() {
    hold = 10;                                   // another body is controlled -> first person only
  }
  if this.m_itpQuick {
    hold = 3;                                    // quick first person key held
  }
  if this.ITPMWeaponDrawn() {
    hold = 3;                                    // weapon holstered -> back after 0.3 s
  }
  if VehicleComponent.IsMountedToVehicle(this.GetGame(), this) {
    hold = Max(hold, 4);                        // left a vehicle -> back after 0.4 s
  }
  let d: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
  let psm: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), d.PlayerStateMachine);
  if IsDefined(psm) && psm.GetInt(d.PlayerStateMachine.SceneTier) > 1 {
    hold = Max(hold, 15);                       // cutscene / dialogue / staged scene -> back after 1.5 s
  }
  if GameInstance.GetBlackboardSystem(this.GetGame()).Get(d.Braindance).GetBool(d.Braindance.IsActive) {
    hold = Max(hold, 10);
  }
  return hold;
}

@addMethod(PlayerPuppet)
public func ITPMSync() -> Void {
  let h: Int32 = this.ITPMBlockHold();
  if h > 0 {
    this.m_itpHold = h;
  } else {
    if this.m_itpHold > 0 {
      this.m_itpHold -= 1;
    }
  }
  let target: Bool = this.m_itpWanted && this.m_itpHold == 0;
  if NotEquals(target, this.m_itpTppOn) {
    this.ITPMSetThirdPerson(target);
  }
}

public class ITPMPollCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || !p.m_itpWanted {
      return;
    }
    p.ITPMSync();
    let cb: ref<ITPMPollCallback> = new ITPMPollCallback();
    cb.player = p;
    GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(cb, 0.1, true);
  }
}


// Native properties of the first-person camera that the original mod uses for free look.
@addField(FPPCameraComponent) public native let headingLocked: Bool;
@addField(FPPCameraComponent) public native let yawMaxLeft: Float;
@addField(FPPCameraComponent) public native let yawMaxRight: Float;
@addField(FPPCameraComponent) public native let pitchMax: Float;
@addField(FPPCameraComponent) public native let pitchMin: Float;


@addMethod(PlayerPuppet)
public func ITPMWrapDeg(a: Float) -> Float {
  let r: Float = a;
  while r > 180.0 { r -= 360.0; }
  while r < -180.0 { r += 360.0; }
  return r;
}

@addField(PlayerPuppet) public let m_itpColl: Float;      // 0.1..1 how far out the camera may go (wall collision)
@addField(PlayerPuppet) public let m_itpFree: Bool;
@addField(PlayerPuppet) public let m_itpYaw: Float;       // camera yaw around V in degrees (free look / front view)

// Free look: the original sets headingLocked + wide yaw/pitch limits on the cameras, so the mouse turns the camera
// instead of V's body. On release it resets the camera to straight behind V.
@addMethod(PlayerPuppet)
public func ITPMFreeLook(on: Bool) -> Void {
  if !this.m_itpUseTpp {
    return;
  }
  let fpp: ref<FPPCameraComponent> = this.FindComponentByName(n"camera") as FPPCameraComponent;
  if !IsDefined(fpp) {
    return;
  }
  this.m_itpFree = on;
  if on {
    fpp.yawMaxLeft = 3600.0;
    fpp.yawMaxRight = -3600.0;
    fpp.pitchMax = 100.0;
    fpp.pitchMin = -100.0;
    fpp.headingLocked = true;
  } else {
    fpp.headingLocked = false;
    fpp.SetLocalOrientation(new Quaternion(0.0, 0.0, 0.0, 1.0));
    fpp.ResetPitch();
  }
}

// ---- extra hotkeys (defined in r6/input/itp_mac_input.xml, loaded by Input Loader) ----
@addMethod(PlayerPuppet)
public func ITPMHandleAction(name: CName, action: ListenerAction) -> Bool {
  let down: Bool = ListenerAction.IsButtonJustPressed(action);
  let up: Bool = ListenerAction.IsButtonJustReleased(action);
  if (down || up) && StrBeginsWith(NameToString(name), "ITP_") && ITPMCfgKeyDebug() {
    this.ITPMNotify("ITP key " + NameToString(name) + (down ? " pressed" : " released"));
  }
  if Equals(name, n"ITP_FreeLook") {
    if down && this.m_itpUseTpp {
      this.ITPMFreeLook(!this.m_itpFree);          // toggle: press once to start, again to stop
      this.ITPMNotify(this.m_itpFree ? "Free look ON" : "Free look OFF");
    }
    return true;
  }
  if Equals(name, n"ITP_QuickFpp") {
    if down { this.m_itpQuick = true; }
    if up { this.m_itpQuick = false; }
    return true;
  }
  if Equals(name, n"ITP_Shoulder") {
    if down { this.m_itpShoulder = true; }
    if up { this.m_itpShoulder = false; }
    return true;
  }
  if Equals(name, n"ITP_Front") {
    if down { this.m_itpFront = true; }
    if up { this.m_itpFront = false; }
    return true;
  }
  if Equals(name, n"ITP_ProfileNext") || Equals(name, n"ITP_ProfilePrev") {
    if down {
      let step: Int32 = Equals(name, n"ITP_ProfileNext") ? 1 : 4;
      this.m_itpProfile = (this.m_itpProfile + step) % 5;
      this.ITPMNotify("Camera profile " + ToString(this.m_itpProfile + 1) + " of 5");
    }
    return true;
  }
  return false;
}

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
  let result: Bool = wrappedMethod(action, consumer);
  let name: CName = ListenerAction.GetName(action);
  if this.ITPMHandleAction(name, action) {
    return result;
  }
  if Equals(name, n"ToggleWalk") && ListenerAction.IsButtonJustPressed(action) {
    this.m_itpWanted = !this.m_itpWanted;
    if this.m_itpWanted {
      this.m_itpHold = 0;
      let pcb: ref<ITPMPollCallback> = new ITPMPollCallback();
      pcb.player = this;
      GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(pcb, 0.25, true);
      if this.ITPMWeaponDrawn() {
        this.ITPMNotify("ITPMac: third person will start when the weapon is lowered");
      }
    } else {
      if !this.m_itpTppOn {
        this.ITPMNotify("ITPMac: third person OFF");
      }
    }
    this.ITPMSync();
  } else {
    if this.m_itpTppOn {
      let nm: String = NameToString(name);
      if (StrContains(nm, "ouse") || StrContains(nm, "amera") || StrContains(nm, "stick") || StrContains(nm, "ook")) && !StrContains(this.m_itpNames, nm) && StrLen(this.m_itpNames) < 220 {
        this.m_itpNames += nm + ",";
      }
      let sign: Float = this.ITPMSet().invertPitch ? -1.0 : 1.0;
      if this.m_itpFree && (Equals(name, n"CameraMouseX") || Equals(name, n"mouse_x")) {
        this.m_itpYaw = this.ITPMWrapDeg(this.m_itpYaw - ClampF(ListenerAction.GetValue(action) * this.ITPMSet().freeLookSens, -6.0, 6.0));
      }
      if this.m_itpFree && Equals(name, n"CameraX") {
        this.m_itpYaw = this.ITPMWrapDeg(this.m_itpYaw - ListenerAction.GetValue(action) * ITPMCfgPitchPerUnitStick());
      }
      if Equals(name, n"CameraMouseY") || Equals(name, n"mouse_y") {
        this.m_itpRaw = ListenerAction.GetValue(action);
        this.m_itpEvtY += 1;
        if AbsF(this.m_itpRaw) > this.m_itpRawMax {
          this.m_itpRawMax = AbsF(this.m_itpRaw);
        }
        this.m_itpPitch = ClampF(this.m_itpPitch + sign * ClampF(ListenerAction.GetValue(action) * this.ITPMSet().pitchSens, -1.5, 1.5), ITPMCfgPitchMin(), ITPMCfgPitchMax());
      } else {
        if Equals(name, n"CameraY") {
          this.m_itpPitch = ClampF(this.m_itpPitch + sign * ListenerAction.GetValue(action) * ITPMCfgPitchPerUnitStick(), ITPMCfgPitchMin(), ITPMCfgPitchMax());
        }
      }
    }
  }
  return result;
}

// ---- hooks into the original mod's own redscript (its "bridge") ----------------------------
// Tells the bridge TPP is on/off and swaps V's clothes between their first/third-person versions
// (what the Lua did through bridge:ApplyVisibleRenderPerspective). Set to false to test the camera alone.
public func ITPMUseBridge() -> Bool { return false; }

public class ITPMBridgeCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let tpp: Bool;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || NotEquals(p.m_itpTppOn, this.tpp) {
      return;
    }
    let bridge: ref<TPPCameraVisibleRenderBridge> = GameInstance.GetScriptableSystemsContainer(p.GetGame()).Get(n"TPPCameraVisibleRenderBridge") as TPPCameraVisibleRenderBridge;
    if IsDefined(bridge) {
      bridge.ApplyVisibleRenderPerspective(this.tpp ? "TPP" : "FPP");
    }
  }
}

public func ITPMBridgeSwitch(p: ref<PlayerPuppet>, tpp: Bool) -> Void {
  if !ITPMUseBridge() {
    return;
  }
  let bridge: ref<TPPCameraVisibleRenderBridge> = GameInstance.GetScriptableSystemsContainer(p.GetGame()).Get(n"TPPCameraVisibleRenderBridge") as TPPCameraVisibleRenderBridge;
  if !IsDefined(bridge) {
    return;
  }
  bridge.SetTppActive(tpp, false, false);
  let cb: ref<ITPMBridgeCallback> = new ITPMBridgeCallback();
  cb.player = p;
  cb.tpp = tpp;
  GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(cb, tpp ? 0.9 : 0.1, true);
}

// The mod shows a Windows-flavoured welcome popup once per save; mark it as already seen.
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  this.RegisterInputListener(this, n"ITP_QuickFpp");
  this.RegisterInputListener(this, n"ITP_Shoulder");
  this.RegisterInputListener(this, n"ITP_Front");
  this.RegisterInputListener(this, n"ITP_ProfilePrev");
  this.RegisterInputListener(this, n"ITP_ProfileNext");
  this.RegisterInputListener(this, n"ITP_FreeLook");
  GameInstance.GetQuestsSystem(this.GetGame()).SetFact(n"immersive_third_person_notice_seen", 1);
  return wrappedMethod();
}
