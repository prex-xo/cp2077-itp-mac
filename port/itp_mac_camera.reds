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
public func ITPMCfgSnapshotDelay() -> Float { return 0.05; }   // delay before the third-person camera starts (was 0.4)
public func ITPMCfgHeadDelay() -> Float { return 0.0; }       // delay of the head's final activation step (was 0.8, then 0.2; 0 = at once)
public func ITPMCfgBlend() -> Float { return 0.3; }            // camera blend time in seconds
// -----------------------------------------------------------------------------

@addField(PlayerPuppet) public let m_itpTppOn: Bool;      // third person is actually active right now
@addField(PlayerPuppet) public let m_itpWanted: Bool;     // what the user asked for with G
@addField(PlayerPuppet) public let m_itpPitch: Float;
@addField(PlayerPuppet) public let m_itpUseTpp: Bool;
@addField(PlayerPuppet) public let m_itpProfSeen: Int32;     // last value of the 'Active camera profile' setting that we know about (1..5)
@addField(PlayerPuppet) public let m_itpProfile: Int32;      // 0..4, camera preset
@addField(PlayerPuppet) public let m_itpShoulder: Bool;      // hold: shoulder zoom
@addField(PlayerPuppet) public let m_itpShoulderB: Float;    // 0..1 blend
@addField(PlayerPuppet) public let m_itpFront: Bool;         // hold: front view
@addField(PlayerPuppet) public let m_itpQuick: Bool;         // hold: quick first person
@addField(PlayerPuppet) public let m_itpFovSet: Float;
@addField(PlayerPuppet) public let m_itpFovCur: Float;
@addField(PlayerPuppet) public let m_itpGlideOut: Bool;     // gliding back to the first-person camera
@addField(PlayerPuppet) public let m_itpGOT0: Float;
@addField(PlayerPuppet) public let m_itpGOX: Float;         // glide-out start: last third-person pose
@addField(PlayerPuppet) public let m_itpGOY: Float;
@addField(PlayerPuppet) public let m_itpGOZ: Float;
@addField(PlayerPuppet) public let m_itpGOPitch: Float;
@addField(PlayerPuppet) public let m_itpGOYaw: Float;
@addField(PlayerPuppet) public let m_itpGOFov: Float;
@addField(PlayerPuppet) public let m_itpLX: Float;          // last applied third-person pose
@addField(PlayerPuppet) public let m_itpLY: Float;
@addField(PlayerPuppet) public let m_itpLZ: Float;
@addField(PlayerPuppet) public let m_itpLPitch: Float;
@addField(PlayerPuppet) public let m_itpLYaw: Float;
@addField(PlayerPuppet) public let m_itpGlide: Bool;        // our own first-person -> third-person glide is running
@addField(PlayerPuppet) public let m_itpGlideT0: Float;
@addField(PlayerPuppet) public let m_itpGSX: Float;         // glide start = the first-person camera, in V's body frame (x right, y forward, z up)
@addField(PlayerPuppet) public let m_itpGSY: Float;
@addField(PlayerPuppet) public let m_itpGSZ: Float;   // using the mod's own tppCamera component
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
  this.ITPMShow(text);
}

@addMethod(PlayerPuppet)
public func ITPMShow(text: String) -> Void {
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
  // like the original mod: its own clone of the game's TPP head item (defined in r6/tweaks/immersive_third_person/tpp_head.yaml), else the game's
  let rec: TweakDBID = t"Items.ImmersiveThirdPersonWaTppHead";
  if Equals(this.GetResolvedGenderName(), n"Male") {
    rec = t"Items.ImmersiveThirdPersonMaTppHead";
  }
  if !IsDefined(TweakDBInterface.GetItemRecord(rec)) {
    rec = t"Items.PlayerWaTppHead";
    if Equals(this.GetResolvedGenderName(), n"Male") {
      rec = t"Items.PlayerMaTppHead";
    }
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
      GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(cb, 0.15, true);
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
@addField(PlayerPuppet) public let m_itpMRoll: Float;       // camera roll in degrees (slide tilt)
@addField(PlayerPuppet) public let m_itpSlidePh: Float;     // 0..1 slide tilt phase
@addField(PlayerPuppet) public let m_itpLandT: Float;       // seconds since a hard landing started, -1 = none
@addField(PlayerPuppet) public let m_itpLandCD: Float;      // cooldown
@addField(PlayerPuppet) public let m_itpLandWas: Bool;

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
  this.m_itpMRoll = 0.0;
  this.m_itpSlidePh = 0.0;
  this.m_itpLandT = -1.0;
  this.m_itpLandCD = 0.0;
  this.m_itpLandWas = false;
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
  // slide tilt: lean the camera while sliding (eases in/out over 0.6 s, 20 degrees like the original)
  let sph: Float = this.m_itpSlidePh + (slide ? dt : -dt) / 0.6;
  this.m_itpSlidePh = ClampF(sph, 0.0, 1.0);
  let sEase: Float = this.m_itpSlidePh * this.m_itpSlidePh * (3.0 - 2.0 * this.m_itpSlidePh);
  // hard landing shake: a short dip and nod, at most once per second
  let hardLand: Bool = loco == EnumInt(gamePSMDetailedLocomotionStates.HardLand) || loco == EnumInt(gamePSMDetailedLocomotionStates.VeryHardLand);
  this.m_itpLandCD = MaxF(0.0, this.m_itpLandCD - dt);
  if hardLand && !this.m_itpLandWas && this.m_itpLandCD <= 0.0 {
    this.m_itpLandT = 0.0;
    this.m_itpLandCD = 1.0;
  }
  this.m_itpLandWas = hardLand;
  if this.m_itpLandT >= 0.0 {
    this.m_itpLandT += dt;
    if this.m_itpLandT > 0.45 {
      this.m_itpLandT = -1.0;
    }
  }

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
    if this.m_itpLandT >= 0.0 {
      let u: Float = this.m_itpLandT / 0.45;
      let env: Float = SinF(3.1415927 * u) * (1.0 - 0.35 * u);
      mz -= 0.07 * env;
      mpitch += 1.0 * env;
    }
  }
  this.m_itpMRoll = -20.0 * sEase * (strength > 0.0 ? 1.0 : 0.0);
  this.m_itpMX = mx * amp;
  this.m_itpMY = my * amp;
  this.m_itpMZ = mz * amp;
  this.m_itpMYaw = myaw * amp;
  this.m_itpMPitch = mpitch * amp;
}


// Keeps the 'Active camera profile' setting and the profile keys in sync (so the menu shows which profile is on).
public func ITPMPublishProfile(n: Int32) -> Void {
  let vars: array<ref<ConfigVar>> = ModSettings.GetVars(n"Immersive Third Person", n"Camera");
  for v in vars {
    if Equals(v.GetName(), n"activeProfile") {
      let iv: ref<ModConfigVarInt32> = v as ModConfigVarInt32;
      if IsDefined(iv) {
        iv.SetValue(n);
      }
    }
  }
}

@addMethod(PlayerPuppet)
public func ITPMSyncProfile() -> Void {
  let set: ref<ITPMSettings> = this.ITPMSet();
  if set.activeProfile != this.m_itpProfSeen {
    // changed in the menu (or first run): adopt it
    this.m_itpProfile = Clamp(set.activeProfile - 1, 0, 4);
    this.m_itpProfSeen = set.activeProfile;
  } else {
    if this.m_itpProfile + 1 != this.m_itpProfSeen {
      // changed with the keys: show it in the menu
      this.m_itpProfSeen = this.m_itpProfile + 1;
      set.activeProfile = this.m_itpProfSeen;
      ITPMPublishProfile(this.m_itpProfSeen);
    }
  }
}


// ---- the original's gameplay features: what its Lua sent to the mod's scripts every tick while third person is on ----
@addField(PlayerPuppet) public let m_itpFeatT: Float;

@addMethod(PlayerPuppet)
public func ITPMFeaturesTick(force: Bool) -> Void {
  if !this.ITPMSet().gameplayFeatures {
    return;
  }
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  if !force && now - this.m_itpFeatT < 0.2 {
    return;                                         // the heartbeat goes stale after 0.5 s, so refresh every 0.2 s
  }
  this.m_itpFeatT = now;
  let bridge: ref<TPPCameraVisibleRenderBridge> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"TPPCameraVisibleRenderBridge") as TPPCameraVisibleRenderBridge;
  if !IsDefined(bridge) {
    return;
  }
  let kind: Int32 = Equals(this.GetResolvedGenderName(), n"Male") ? 2 : 1;      // graph "dash kind": 1 = woman, 2 = man, 0 = off
  bridge.SetTppActive(true, false, false);
  bridge.SetConsumableGateEnabled(true);
  bridge.SetItemPlaneGateEnabled(true);
  bridge.SetWeaponDrawStaysTpp(false);
  AnimationControllerComponent.SetInputFloat(this, n"tpp_dash_kind", Cast<Float>(kind));
  bridge.SetDashConfig(true, kind, 0.50, 2.0833333);
  bridge.SetDashBackConfig(0.875, 2.0833333);
  bridge.SetDashSideConfig(0.50, 2.0833333);
  bridge.SetMaleLaneLive(true);
  bridge.SetAutoVault(this.ITPMSet().autoVault);
}

@addMethod(PlayerPuppet)
public func ITPMFeaturesPark() -> Void {
  let bridge: ref<TPPCameraVisibleRenderBridge> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"TPPCameraVisibleRenderBridge") as TPPCameraVisibleRenderBridge;
  if !IsDefined(bridge) {
    return;
  }
  AnimationControllerComponent.SetInputFloat(this, n"tpp_dash_kind", 0.0);
  bridge.SetDashConfig(true, 0, 0.50, 2.0833333);
  bridge.SetTppActive(false, false, false);
}


// true while the player aims down sights (the game's own aim state or zoom)
@addMethod(PlayerPuppet)
public func ITPMAiming() -> Bool {
  let d: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
  let b: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), d.PlayerStateMachine);
  return IsDefined(b) && (b.GetInt(d.PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) || b.GetFloat(d.PlayerStateMachine.ZoomLevel) > 1.05);
}

// Five camera presets (cycled with the profile keys). 0 = the default view.  k: 0 side, 1 distance, 2 height
public func ITPMProfileVal(set: ref<ITPMSettings>, idx: Int32, k: Int32) -> Float {
  return set.Val(Clamp(idx, 0, 4), k);     // every profile has its own values in Mod Settings
}

@addMethod(PlayerPuppet)
public func ITPMUpdateTppCam() -> Void {
  let cam: ref<IPlacedComponent> = this.FindComponentByName(n"tppCamera") as IPlacedComponent;
  if !IsDefined(cam) {
    return;
  }
  this.m_itpPitchS += (this.m_itpPitch - this.m_itpPitchS) * this.ITPMSet().smooth;
  this.ITPMSyncProfile();
  this.ITPMFeaturesTick(false);
  let dS: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
  let pS: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), dS.PlayerStateMachine);
  this.m_itpSitOrbit = IsDefined(pS) && (pS.GetInt(dS.PlayerStateMachine.IsInWorkspot) != 0 || pS.GetInt(dS.PlayerStateMachine.SceneTier) >= 3);
  this.ITPMSitLock(this.m_itpSitOrbit && IsDefined(pS) && pS.GetInt(dS.PlayerStateMachine.IsInWorkspot) != 0 && pS.GetInt(dS.PlayerStateMachine.SceneTier) < 3);
  let wShoulder: Bool = this.ITPMSet().weaponShoulder && this.ITPMWeaponDrawn() && this.ITPMAiming();                              // ... and the player aims: only then the weapon camera
  this.m_itpShoulderB += (((this.m_itpShoulder || wShoulder) ? 1.0 : 0.0) - this.m_itpShoulderB) * 0.2;
  // the up-and-down angle stays ours (mouse Y); the game's own first-person camera does not follow the mouse while third person is on
  this.ITPMMotionStep();
  let b: Float = this.m_itpShoulderB;
  let th: Float = Deg2Rad(this.m_itpPitchS + this.m_itpMPitch + ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 5));
  let sideP: Float = ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 0);
  let sgn: Float = sideP < 0.0 ? -1.0 : 1.0;
  // shoulder zoom blends the preset toward: side 0.45, distance 0.80, height 1.60, FOV 42 (original defaults)
  // while a weapon is drawn (shoulder camera mode) the 'Weapon camera' page sets the pose; the shoulder-zoom key keeps its fixed values
  let wcam: Bool = this.ITPMSet().weaponShoulder && this.ITPMWeaponDrawn() && this.ITPMAiming();
  let shSide: Float = wcam ? this.ITPMSet().wSide : sgn * 0.45;
  let shDist: Float = wcam ? this.ITPMSet().wDist : 0.80;
  let shHigh: Float = wcam ? this.ITPMSet().wHeight : 1.60;
  let shFov: Float = wcam ? this.ITPMSet().wFov : 42.0;
  let side: Float = sideP + (shSide - sideP) * b + this.m_itpMX;
  let dist: Float = ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 1) + (shDist - ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 1)) * b + this.m_itpMDist * (1.0 - b);
  let inElev: Bool = false;
  if !this.ITPMSet().elevatorTpp {
    inElev = false;
  } else {
    let d0: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
    let pb0: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), d0.PlayerStateMachine);
    inElev = IsDefined(pb0) && pb0.GetBool(d0.PlayerStateMachine.IsPlayerInsideElevator);
  }
  let high: Float = ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 2) + (shHigh - ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 2)) * b + this.m_itpMHeight + this.m_itpMZ;
  if inElev {
    dist = MinF(dist, this.ITPMSet().elevatorDistance);        // stay inside the cabin
    side = ClampF(side, -0.35, 0.35);
  }
  let z: Float = MaxF(high - dist * SinF(th), ITPMCfgMinHeight());
  let s: Float = SinF(th * 0.5);
  let c: Float = CosF(th * 0.5);
  // free look returns smoothly to behind V when released
  if !this.m_itpFree && !this.m_itpFront && !this.m_itpSitOrbit && this.m_itpYaw != 0.0 {
    let step: Float = 8.0;
    if AbsF(this.m_itpYaw) <= step {
      this.m_itpYaw = 0.0;
    } else {
      this.m_itpYaw -= step * (this.m_itpYaw > 0.0 ? 1.0 : -1.0);
    }
  }
  // camera yaw around V: free look yaw, plus 180 degrees for front view
  let yaw: Float = this.m_itpYaw + (this.m_itpFront ? 180.0 : 0.0) + this.m_itpMYaw + ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 4);
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
      let groups: array<CName> = [n"Static", n"Visibility", n"PlayerBlocker", n"Dynamic"];
      let gi: Int32 = 0;
      while gi < ArraySize(groups) {
        let res: TraceResult;
        let hit: Bool = GameInstance.GetSpatialQueriesSystem(this.GetGame()).SyncRaycastByCollisionGroup(new Vector4(sx, sy, sz2, 1.0), new Vector4(ex, ey, ez, 1.0), groups[gi], res, true, false);
        if hit && TraceResult.IsValid(res) {
          let hp: Vector4 = Cast<Vector4>(res.position);
          let hd: Float = SqrtF((hp.X - sx) * (hp.X - sx) + (hp.Y - sy) * (hp.Y - sy) + (hp.Z - sz2) * (hp.Z - sz2));
          target = MinF(target, ClampF((hd - this.ITPMSet().collisionMargin) / full, ClampF(this.ITPMSet().minDistance / full, 0.10, 1.0), 1.0));   // nearest wall of any group
        }
        gi += 1;
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
  if this.m_itpGlide {
    // our own glide from the first-person camera spot to the final spot: starts exactly where the first-person camera is,
    // pulls straight back, the shoulder offset eases in on the way (no sideways slide, no weird angle)
    let gt: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame())) - this.m_itpGlideT0;
    let g: Float = ClampF(gt / (this.ITPMSet().smoothSwitch ? MaxF(this.ITPMSet().blendTime, 0.1) : 0.05), 0.0, 1.0);
    let e: Float = g * g * (3.0 - 2.0 * g);
    lx = this.m_itpGSX + (lx - this.m_itpGSX) * e;
    ly = this.m_itpGSY + (ly - this.m_itpGSY) * e;
    z = this.m_itpGSZ + (z - this.m_itpGSZ) * e;
    if g >= 1.0 {
      this.m_itpGlide = false;
    }
  }
  this.m_itpLX = lx;
  this.m_itpLY = ly;
  this.m_itpLZ = z;
  this.m_itpLPitch = Rad2Deg(th);
  this.m_itpLYaw = yaw;
  cam.SetLocalPosition(new Vector4(lx, ly, z, 1.0));
  let sz: Float = SinF(ph * 0.5);
  let cz: Float = CosF(ph * 0.5);
  // roll about the view direction (slide tilt): q = yaw * pitch * roll
  let ai: Float = cz * s;
  let aj: Float = sz * s;
  let ak: Float = sz * c;
  let ar: Float = cz * c;
  let sr: Float = SinF(Deg2Rad(this.m_itpMRoll) * 0.5);
  let cr: Float = CosF(Deg2Rad(this.m_itpMRoll) * 0.5);
  cam.SetLocalOrientation(new Quaternion(ai * cr - ak * sr, ar * sr + aj * cr, ai * sr + ak * cr, ar * cr - aj * sr));
  // Free look (the `.` key) ends by itself as soon as V really moves, so running and turning stay normal third person.
  if this.m_itpFree {
    if this.m_itpMSpeed > 0.8 {
      this.m_itpFreeMove += 1;
    } else {
      this.m_itpFreeMove = 0;
    }
    if this.m_itpFreeMove >= 4 {
      this.ITPMFreeLook(false);
    }
  }
  let baseFov: Float = ITPMProfileVal(this.ITPMSet(), this.m_itpProfile, 3);
  let fov: Float = baseFov + ((wcam ? shFov : MinF(baseFov, shFov)) - baseFov) * b;
  if this.m_itpFovCur <= 1.0 {
    this.m_itpFovCur = fov;
  }
  this.m_itpFovCur += (fov - this.m_itpFovCur) * ClampF(0.010 / MaxF(this.ITPMSet().blendTime, 0.1) * 3.0, 0.02, 0.30);   // ease from the first-person FOV to the third-person FOV over about the glide time
  if AbsF(this.m_itpFovCur - this.m_itpFovSet) > 0.05 {
    (cam as CameraComponent).SetFOV(this.m_itpFovCur);
    this.m_itpFovSet = this.m_itpFovCur;
  }
}

@addMethod(PlayerPuppet)
public func ITPMStartTppCam() -> Bool {
  let cam: ref<CameraComponent> = this.FindComponentByName(n"tppCamera") as CameraComponent;
  if !IsDefined(cam) {
    return false;
  }
  this.m_itpGlideOut = false;
  this.m_itpUseTpp = true;
  this.m_itpFovSet = 0.0;
  this.m_itpFovCur = 0.0;
  let fppc: ref<CameraComponent> = this.FindComponentByName(n"camera") as CameraComponent;
  if IsDefined(fppc) {
    let ff: Float = fppc.GetFOV();
    if ff > 20.0 && ff < 150.0 {
      this.m_itpFovCur = ff;
      cam.SetFOV(ff);
      this.m_itpFovSet = ff;
    }
  }
  this.m_itpColl = 1.0;
  this.ITPMMotionReset();
  // where is the first-person camera, in V's body frame?
  this.m_itpGlide = false;
  let fcam: ref<IPlacedComponent> = this.FindComponentByName(n"camera") as IPlacedComponent;
  let pf: Vector4 = this.GetWorldForward();
  let pfl: Float = SqrtF(pf.X * pf.X + pf.Y * pf.Y);
  if IsDefined(fcam) && pfl > 0.001 {
    let fm: Matrix = fcam.GetLocalToWorld();
    let pp: Vector4 = this.GetWorldPosition();
    let fx0: Float = pf.X / pfl;
    let fy0: Float = pf.Y / pfl;
    let ddx: Float = fm.W.X - pp.X;
    let ddy: Float = fm.W.Y - pp.Y;
    this.m_itpGSX = ddx * fy0 - ddy * fx0;
    this.m_itpGSY = ddx * fx0 + ddy * fy0;
    this.m_itpGSZ = fm.W.Z - pp.Z;
    this.m_itpGlideT0 = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
    this.m_itpGlide = true;
  }
  if ITPMCfgKeyDebug() {
    this.ITPMNotify("tppCamera class: " + NameToString(cam.GetClassName()));
  }
  this.ITPMFeaturesTick(true);
  this.ITPMUpdateTppCam();
  cam.Activate(this.m_itpGlide ? 0.0 : this.ITPMSet().blendTime);   // with our own glide there is no engine blend
  return true;
}

@addMethod(PlayerPuppet)
public func ITPMStopTppCam() -> Void {
  if !this.m_itpUseTpp {
    return;
  }
  this.ITPMFeaturesPark();
  this.ITPMSitLock(false);
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

// ---- smooth return to first person: glide from the last third-person pose to the first-person camera, then hand over ----
// first-person camera in V's body frame: x, y, z, and its pitch in degrees in w
@addMethod(PlayerPuppet)
public func ITPMFppPose() -> Vector4 {
  let fcam: ref<IPlacedComponent> = this.FindComponentByName(n"camera") as IPlacedComponent;
  let pf: Vector4 = this.GetWorldForward();
  let pfl: Float = SqrtF(pf.X * pf.X + pf.Y * pf.Y);
  if !IsDefined(fcam) || pfl < 0.001 {
    return new Vector4(0.0, 0.0, 1.6, 0.0);
  }
  let fm: Matrix = fcam.GetLocalToWorld();
  let pp: Vector4 = this.GetWorldPosition();
  let fx0: Float = pf.X / pfl;
  let fy0: Float = pf.Y / pfl;
  let ddx: Float = fm.W.X - pp.X;
  let ddy: Float = fm.W.Y - pp.Y;
  return new Vector4(ddx * fy0 - ddy * fx0, ddx * fx0 + ddy * fy0, fm.W.Z - pp.Z, Rad2Deg(AsinF(ClampF(fm.Y.Z, -1.0, 1.0))));
}

@addMethod(PlayerPuppet)
public func ITPMFinishExit() -> Void {
  let fpp: ref<FPPCameraComponent> = this.FindComponentByName(n"camera") as FPPCameraComponent;
  if IsDefined(fpp) {
    fpp.Activate(0.0);                              // same pose and FOV as the glide's end: no visible cut
  }
  this.m_itpGlideOut = false;
  this.m_itpUseTpp = false;
  this.m_itpYaw = 0.0;
  if !this.m_itpTppOn {
    this.ITPMCustomAnims(false);                    // the mod's third-person animation states must be OFF in first person
    this.ITPMApplyTppAnim(true);
    this.ITPMEquipTppHead(false, false);
    let ocb: ref<ITPMOffCallback> = new ITPMOffCallback();
    ocb.player = this;
    GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(ocb, 0.1, true);
  }
}

@addMethod(PlayerPuppet)
public func ITPMGlideOutStep() -> Void {
  let cam: ref<IPlacedComponent> = this.FindComponentByName(n"tppCamera") as IPlacedComponent;
  if !IsDefined(cam) || !this.ITPMControlsOwnBody() {
    this.ITPMFinishExit();
    return;
  }
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  let g: Float = ClampF((now - this.m_itpGOT0) / (this.ITPMSet().smoothSwitch ? 0.35 : 0.05), 0.0, 1.0);
  let e: Float = g * g * (3.0 - 2.0 * g);
  let fp: Vector4 = this.ITPMFppPose();
  cam.SetLocalPosition(new Vector4(this.m_itpGOX + (fp.X - this.m_itpGOX) * e, this.m_itpGOY + (fp.Y - this.m_itpGOY) * e, this.m_itpGOZ + (fp.Z - this.m_itpGOZ) * e, 1.0));
  let th: Float = Deg2Rad(this.m_itpGOPitch + (fp.W - this.m_itpGOPitch) * e);
  let ph: Float = Deg2Rad(this.m_itpGOYaw * (1.0 - e));
  let s: Float = SinF(th * 0.5);
  let c: Float = CosF(th * 0.5);
  let sz: Float = SinF(ph * 0.5);
  let cz: Float = CosF(ph * 0.5);
  cam.SetLocalOrientation(new Quaternion(cz * s, sz * s, sz * c, cz * c));
  let fppc: ref<CameraComponent> = this.FindComponentByName(n"camera") as CameraComponent;
  if IsDefined(fppc) && this.m_itpGOFov > 20.0 {
    let ff: Float = fppc.GetFOV();
    if ff > 20.0 && ff < 150.0 {
      (cam as CameraComponent).SetFOV(this.m_itpGOFov + (ff - this.m_itpGOFov) * e);
    }
  }
  if g >= 1.0 {
    this.ITPMFinishExit();
  }
}

// starts the glide back; false = not possible, use the immediate exit
@addMethod(PlayerPuppet)
public func ITPMBeginExitGlide() -> Bool {
  if !this.m_itpUseTpp || !this.ITPMControlsOwnBody() {
    return false;
  }
  let tpp: ref<IPlacedComponent> = this.FindComponentByName(n"tppCamera") as IPlacedComponent;
  let fpp: ref<IPlacedComponent> = this.FindComponentByName(n"camera") as IPlacedComponent;
  if !IsDefined(tpp) || !IsDefined(fpp) {
    return false;
  }
  this.ITPMFeaturesPark();
  this.ITPMSitLock(false);
  if this.m_itpFree {
    this.ITPMFreeLook(false);
  }
  this.m_itpGOX = this.m_itpLX;
  this.m_itpGOY = this.m_itpLY;
  this.m_itpGOZ = this.m_itpLZ;
  this.m_itpGOPitch = this.m_itpLPitch;
  this.m_itpGOYaw = this.m_itpLYaw;
  this.m_itpGOFov = this.m_itpFovSet;
  this.m_itpGOT0 = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.m_itpGlide = false;
  this.m_itpGlideOut = true;
  // make sure the update loop keeps running during the glide even though third person is already "off"
  let cb: ref<ITPMKeepCallback> = new ITPMKeepCallback();
  cb.player = this;
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(cb, 0.0, true);
  return true;
}

public class ITPMStartCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || !p.m_itpTppOn {
      return;
    }
    if !p.ITPMStartTppCam() {
      p.ITPMNotify("ITPMac: third person is not available for this body");
      p.m_itpWanted = false;
      p.ITPMSetThirdPerson(false);
      return;
    }
    // head: the game's own activation event attaches it; do NOT re-equip it here
    let hdc: ref<ITPMHeadDiagCallback> = new ITPMHeadDiagCallback();
    hdc.player = p;
    if ITPMCfgHeadDelay() <= 0.001 {
      hdc.Call();                                   // send the head's final step right away
    } else {
      GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(hdc, ITPMCfgHeadDelay(), true);
    }
    let cb: ref<ITPMKeepCallback> = new ITPMKeepCallback();
    cb.player = p;
    GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(cb, 0.05, true);
  }
}

public class ITPMKeepCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || (!p.m_itpTppOn && !p.m_itpGlideOut) {
      return;
    }
    if p.m_itpGlideOut {
      // leaving third person: only move the camera. Do NOT touch the animation states here (they were switched off already)
      p.ITPMGlideOutStep();
      if p.m_itpGlideOut {
        let gcb: ref<ITPMKeepCallback> = new ITPMKeepCallback();
        gcb.player = p;
        GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(gcb, 0.01, true);
      }
      return;
    } else if p.m_itpUseTpp {
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


// "Remember perspective": after loading a save, go back to third person if it was on when the save was made.
public class ITPMRestoreCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let p: ref<PlayerPuppet> = this.player;
    if !IsDefined(p) || !p.ITPMSet().rememberPerspective || p.m_itpWanted {
      return;
    }
    if GameInstance.GetQuestsSystem(p.GetGame()).GetFact(n"itp_tpp_wanted") > 0 {
      p.m_itpWanted = true;
      p.m_itpHold = 0;
      let pcb: ref<ITPMPollCallback> = new ITPMPollCallback();
      pcb.player = p;
      GameInstance.GetDelaySystem(p.GetGame()).DelayCallback(pcb, 0.25, true);
      p.ITPMSync();
    }
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
    let fppView: ref<IPlacedComponent> = this.FindComponentByName(n"camera") as IPlacedComponent;
    if IsDefined(fppView) {
      let fm: Matrix = fppView.GetLocalToWorld();
      let startPitch: Float = ClampF(Rad2Deg(AsinF(ClampF(fm.Y.Z, -1.0, 1.0))), ITPMCfgPitchMin(), ITPMCfgPitchMax());
      this.m_itpPitch = startPitch;
      this.m_itpPitchS = startPitch;
    }
    this.m_itpEvtY = 0;
    this.m_itpRawMax = 0.0;
    this.m_itpNames = "";
    // vehicle-style activation: the game's own event (sets up the head/body properly)
    let act: ref<ActivateTPPRepresentationEvent> = new ActivateTPPRepresentationEvent();
    this.QueueEvent(act);
    // the original equips its own head item right away, in the same instant: do the same so the head is not waiting for the game
    if !this.ITPMEquipTppHead(true, false) {
      let hr: ref<ITPMHeadRetryCallback> = new ITPMHeadRetryCallback();
      hr.player = this;
      hr.attempt = 1;
      GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(hr, 0.1, true);
    }
    let cb: ref<ITPMStartCallback> = new ITPMStartCallback();
    cb.player = this;
    GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(cb, this.ITPMSet().startDelay, true);
    // the head's activation step goes out early (20 ms), the camera waits for startDelay; it is sent again when the camera starts
    let hdEarly: ref<ITPMHeadDiagCallback> = new ITPMHeadDiagCallback();
    hdEarly.player = this;
    GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(hdEarly, 0.02, true);
    this.ITPMCustomAnims(true);
    ITPMBridgeSwitch(this, true);
    this.ITPMNotify("ITPMac: third person ON");
  } else {
    this.m_itpTppOn = false;
    this.ITPMCustomAnims(false);
    this.ITPMApplyTppAnim(true);
    if !this.ITPMBeginExitGlide() {
      // not possible (other body, no cameras): the immediate exit
      this.ITPMEquipTppHead(false, false);
      this.ITPMStopTppCam();
      this.ITPMResetCamera();
      let ocb: ref<ITPMOffCallback> = new ITPMOffCallback();
      ocb.player = this;
      GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(ocb, 0.25, true);
    }
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

@addField(PlayerPuppet) public let m_itpWhy: String;       // why third person is blocked right now (for the message)
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
  let why: String = "";
  if !this.ITPMControlsOwnBody() {
    hold = 10;                                   // another body is controlled -> first person only
    why += "another body; ";
  }
  if this.m_itpQuick {
    hold = 3;                                    // quick first person key held
    why += "quick first person key; ";
  }
  if this.ITPMWeaponDrawn() && !this.ITPMSet().weaponShoulder {
    hold = 3;                                    // weapon holstered -> back after 0.3 s
    why += "weapon in hand; ";
  }
  if VehicleComponent.IsMountedToVehicle(this.GetGame(), this) {
    hold = Max(hold, 4);                        // left a vehicle -> back after 0.4 s
    why += "vehicle; ";
  }
  let d: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
  let psm: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), d.PlayerStateMachine);
  let sceneLimit: Int32 = !this.ITPMSet().sceneTpp ? 3 : (this.ITPMSet().sceneEverything ? 99 : 5);      // original: tier >= 3 is a scene; 'conversations and sit-downs' keeps tiers 3-4
  if IsDefined(psm) && psm.GetInt(d.PlayerStateMachine.SceneTier) >= sceneLimit {
    hold = Max(hold, 15);                       // cutscene / dialogue / staged scene -> back after 1.5 s
    why += "scene (tier " + ToString(psm.GetInt(d.PlayerStateMachine.SceneTier)) + "); ";
  }
  if IsDefined(psm) {
    // the original's "combat" group: in combat, takedowns, carrying a body, left-hand gadget or cyberware (1.25 s after it ends)
    let handBusy: Bool = psm.GetInt(d.PlayerStateMachine.Takedown) != 0 || psm.GetInt(d.PlayerStateMachine.BodyCarrying) != 0
      || psm.GetInt(d.PlayerStateMachine.CombatGadget) != 0 || psm.GetInt(d.PlayerStateMachine.LeftHandCyberware) != 0;
    // combat alone no longer keeps first person: after holstering a weapon you are back in third person, in combat or not
    if handBusy {
      hold = Max(hold, 13);
      why += "takedown/carry/gadget/cyberware; ";
    }
    // special actions: sitting/working at a workspot, forcing a door, personal-link hacks, terminals and controlled devices
    if psm.GetInt(d.PlayerStateMachine.IsInWorkspot) != 0 && !this.ITPMSet().sceneTpp {
      hold = Max(hold, 5);
      why += "sitting/workspot (the setting 'Third person in conversations and sit-downs' is off); ";
    }
    if psm.GetBool(d.PlayerStateMachine.IsForceOpeningDoor) || psm.GetBool(d.PlayerStateMachine.IsInteractingViaPersonalLink) {
      hold = Max(hold, 5);
      why += "door/personal link; ";
    }
    if psm.GetBool(d.PlayerStateMachine.IsUIZoomDevice) && !this.ITPMSet().terminalTpp {
      hold = Max(hold, 5);
      why += "terminal/device zoom; ";
    }
    if psm.GetBool(d.PlayerStateMachine.IsControllingDevice) && !this.ITPMSet().terminalTpp {
      hold = Max(hold, 5);
      why += "controlling a device (TV, camera...); ";
    }
  }
  if !this.ITPMSet().elevatorTpp && IsDefined(psm) && psm.GetBool(d.PlayerStateMachine.IsPlayerInsideElevator) {
    hold = Max(hold, 5);                         // inside an elevator -> first person (the cabin walls can be see-through to the camera)
    why += "elevator; ";
  }
  if this.ITPMSet().scannerFpp && IsDefined(psm) && psm.GetInt(d.PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) {
    hold = Max(hold, 3);                         // scanner / quickhack view (Tab): back after 0.3 s
    why += "scanner/quickhack view; ";
  }
  if GameInstance.GetBlackboardSystem(this.GetGame()).Get(d.Braindance).GetBool(d.Braindance.IsActive) {
    hold = Max(hold, 10);
    why += "braindance; ";
  }
  this.m_itpWhy = why;
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

// GTA-style movement: while free look is on, V moves relative to the camera's direction instead of her own facing.
// Uses the original mod's own bridge: Move360 makes the game's locomotion use "camera heading for movement".
@addMethod(PlayerPuppet)
public func ITPMMoveRelativeToCamera(on: Bool) -> Void {
  let bridge: ref<TPPCameraVisibleRenderBridge> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"TPPCameraVisibleRenderBridge") as TPPCameraVisibleRenderBridge;
  if !IsDefined(bridge) {
    return;
  }
  if on {
    bridge.SetTppActive(true, false, false);    // the bridge only acts while it is told third person is on (heartbeat)
    bridge.Move360SetAllowed(true);
  } else {
    bridge.Move360SetAllowed(false);
    bridge.SetTppActive(false, false, false);
  }
}

@addField(PlayerPuppet) public let m_itpSitOrbit: Bool;    // sitting or in a scene: the mouse orbits the camera (the body is locked by the game)
@addField(PlayerPuppet) public let m_itpFreeTick: Int32;
@addField(PlayerPuppet) public let m_itpKeySeen: Int32;
@addField(PlayerPuppet) public let m_itpFlSaved: Bool;     // the first-person camera's original values are saved (free look is on)
@addField(PlayerPuppet) public let m_itpFlYL: Float;
@addField(PlayerPuppet) public let m_itpFlYR: Float;
@addField(PlayerPuppet) public let m_itpFlPMax: Float;
@addField(PlayerPuppet) public let m_itpFlPMin: Float;
@addField(PlayerPuppet) public let m_itpFlHL: Bool;
@addField(PlayerPuppet) public let m_itpFlQ: Quaternion;
@addField(PlayerPuppet) public let m_itpFreeMove: Int32;   // consecutive ticks with V moving while free look is on
@addField(PlayerPuppet) public let m_itpWorldYaw: Float;   // free-look camera direction in the WORLD (degrees, counter-clockwise from north)

// V's body yaw in degrees, counter-clockwise positive (0 = +Y). Self-checks the sign of GetWorldYaw against the real forward vector.
@addMethod(PlayerPuppet)
public func ITPMBodyYaw() -> Float {
  let psi: Float = this.GetWorldYaw();
  let f: Vector4 = this.GetWorldForward();
  let r: Float = Deg2Rad(psi);
  let d1: Float = (-SinF(r) - f.X) * (-SinF(r) - f.X) + (CosF(r) - f.Y) * (CosF(r) - f.Y);
  let d2: Float = (SinF(r) - f.X) * (SinF(r) - f.X) + (CosF(r) - f.Y) * (CosF(r) - f.Y);
  return d1 <= d2 ? psi : -psi;
}

@addField(PlayerPuppet) public let m_itpFree: Bool;
@addField(PlayerPuppet) public let m_itpYaw: Float;       // camera yaw around V in degrees (free look / front view)


// Sitting by yourself (not a scripted scene): the game lets you look around with its own camera. Switch that off while third person
// is on, so the mouse only orbits OUR camera, exactly like in a mission scene where the game already holds its camera still.
@addField(PlayerPuppet) public let m_itpSlSaved: Bool;
@addField(PlayerPuppet) public let m_itpSlYL: Float;
@addField(PlayerPuppet) public let m_itpSlYR: Float;
@addField(PlayerPuppet) public let m_itpSlPMax: Float;
@addField(PlayerPuppet) public let m_itpSlPMin: Float;

@addMethod(PlayerPuppet)
public func ITPMSitLock(on: Bool) -> Void {
  let fpp: ref<FPPCameraComponent> = this.FindComponentByName(n"camera") as FPPCameraComponent;
  if !IsDefined(fpp) {
    return;
  }
  if on {
    if !this.m_itpSlSaved && !this.m_itpFlSaved {
      this.m_itpSlYL = fpp.yawMaxLeft;
      this.m_itpSlYR = fpp.yawMaxRight;
      this.m_itpSlPMax = fpp.pitchMax;
      this.m_itpSlPMin = fpp.pitchMin;
      this.m_itpSlSaved = true;
    }
    if this.m_itpSlSaved {
      fpp.yawMaxLeft = 0.0;
      fpp.yawMaxRight = 0.0;
      fpp.pitchMax = 0.0;
      fpp.pitchMin = 0.0;
    }
  } else {
    if this.m_itpSlSaved {
      fpp.yawMaxLeft = this.m_itpSlYL;
      fpp.yawMaxRight = this.m_itpSlYR;
      fpp.pitchMax = this.m_itpSlPMax;
      fpp.pitchMin = this.m_itpSlPMin;
      this.m_itpSlSaved = false;
    }
  }
}

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
  this.m_itpFreeMove = 0;
  if on {
    if !this.m_itpFlSaved {
      // remember the first-person camera exactly as the game had it, to give it back untouched afterwards
      this.m_itpFlYL = fpp.yawMaxLeft;
      this.m_itpFlYR = fpp.yawMaxRight;
      this.m_itpFlPMax = fpp.pitchMax;
      this.m_itpFlPMin = fpp.pitchMin;
      this.m_itpFlHL = fpp.headingLocked;
      this.m_itpFlQ = fpp.GetLocalOrientation();
      this.m_itpFlSaved = true;
    }
    fpp.yawMaxLeft = 3600.0;
    fpp.yawMaxRight = -3600.0;
    fpp.pitchMax = 100.0;
    fpp.pitchMin = -100.0;
    fpp.headingLocked = true;
  } else {
    if this.m_itpFlSaved {
      fpp.yawMaxLeft = this.m_itpFlYL;
      fpp.yawMaxRight = this.m_itpFlYR;
      fpp.pitchMax = this.m_itpFlPMax;
      fpp.pitchMin = this.m_itpFlPMin;
      fpp.headingLocked = this.m_itpFlHL;
      fpp.SetLocalOrientation(this.m_itpFlQ);         // the turn free look added to the camera is undone
      this.m_itpFlSaved = false;
    } else {
      fpp.headingLocked = false;
    }
  }
}

// ---- extra hotkeys (defined in r6/input/itp_mac_input.xml, loaded by Input Loader) ----
public func ITPMKeySuffixes() -> array<String> {
  return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "Period", "Comma", "Semicolon", "SingleQuote", "LeftBracket", "RightBracket", "Backslash", "Minus", "Equals", "Up", "Down", "Left", "Right", "Home", "End", "PageUp", "PageDown", "Insert", "Delete"];
}

// key bindings page: an action named ITP_K_<key> arrived; run the action whose bound key is that key
@addMethod(PlayerPuppet)
public func ITPMMenuKey(suffix: String, down: Bool, up: Bool) -> Bool {
  let set: ref<ITPMSettings> = this.ITPMSet();
  if !set.useMenuKeys {
    return true;
  }
  if down && this.m_itpKeySeen < 4 {
    this.m_itpKeySeen += 1;
    this.ITPMNotify("Key bindings: received key " + suffix);      // proof that key presses arrive (first 4 only)
  }
  let v: Int64 = EnumValueFromString("EInputKey", "IK_" + suffix);
  let k: EInputKey = IntEnum<EInputKey>(Cast<Int32>(v));
  if Equals(k, set.keyFreeLook) { return this.ITPMDoAction(n"ITP_FreeLook", down, up); }
  if Equals(k, set.keyQuick) { return this.ITPMDoAction(n"ITP_QuickFpp", down, up); }
  if Equals(k, set.keyShoulder) { return this.ITPMDoAction(n"ITP_Shoulder", down, up); }
  if Equals(k, set.keyFront) { return this.ITPMDoAction(n"ITP_Front", down, up); }
  if Equals(k, set.keyPrev) { return this.ITPMDoAction(n"ITP_ProfilePrev", down, up); }
  if Equals(k, set.keyNext) { return this.ITPMDoAction(n"ITP_ProfileNext", down, up); }
  return true;
}

@addMethod(PlayerPuppet)
public func ITPMHandleAction(name: CName, action: ListenerAction) -> Bool {
  // the key file's actions: when the menu key bindings are on, they are ignored (the keys below are used instead)
  if !StrBeginsWith(NameToString(name), "ITP_") {
    return false;
  }
  if StrBeginsWith(NameToString(name), "ITP_K_") {
    let nm: String = NameToString(name);
    return this.ITPMMenuKey(StrMid(nm, 6, StrLen(nm) - 6), ListenerAction.IsButtonJustPressed(action), ListenerAction.IsButtonJustReleased(action));
  }
  if this.ITPMSet().useMenuKeys {
    return true;
  }
  return this.ITPMDoAction(name, ListenerAction.IsButtonJustPressed(action), ListenerAction.IsButtonJustReleased(action));
}

@addMethod(PlayerPuppet)
public func ITPMDoAction(name: CName, down: Bool, up: Bool) -> Bool {
  if (down || up) && ITPMCfgKeyDebug() {
    this.ITPMNotify("ITP key " + NameToString(name) + (down ? " pressed" : " released"));
  }
  if Equals(name, n"ITP_FreeLook") {
    if down && this.m_itpUseTpp {
      this.ITPMFreeLook(!this.m_itpFree);          // toggle: press once to look around, again (or just move) to stop
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
      let n: Int32 = Clamp(this.ITPMSet().hotkeyCount, 2, 5);
      if this.m_itpProfile >= n {
        this.m_itpProfile = Equals(name, n"ITP_ProfileNext") ? 0 : n - 1;
      } else {
        this.m_itpProfile = (this.m_itpProfile + (Equals(name, n"ITP_ProfileNext") ? 1 : n - 1)) % n;
      }
      if this.ITPMSet().profileMessages {
        this.ITPMNotify("Camera profile " + ToString(this.m_itpProfile + 1) + " of 5 (active)");
      }
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
    GameInstance.GetQuestsSystem(this.GetGame()).SetFact(n"itp_tpp_wanted", this.m_itpWanted ? 1 : 0);   // remembered per save
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
    if this.m_itpWanted && !this.m_itpTppOn && this.m_itpHold > 0 && this.ITPMSet().blockMessages {
      // tell the player why third person does not start (shown even when on-screen messages are off)
      this.ITPMShow("Third person is waiting because of: " + this.m_itpWhy);
    }
  } else {
    if this.m_itpTppOn {
      let nm: String = NameToString(name);
      if (StrContains(nm, "ouse") || StrContains(nm, "amera") || StrContains(nm, "stick") || StrContains(nm, "ook")) && !StrContains(this.m_itpNames, nm) && StrLen(this.m_itpNames) < 220 {
        this.m_itpNames += nm + ",";
      }
      let sign: Float = this.ITPMSet().invertPitch ? -1.0 : 1.0;
      let xs: Float = this.ITPMSet().invertX ? -1.0 : 1.0;
      if (this.m_itpFree || this.m_itpSitOrbit) && (Equals(name, n"CameraMouseX") || Equals(name, n"mouse_x")) {
        this.m_itpYaw = this.ITPMWrapDeg(this.m_itpYaw - xs * ClampF(ListenerAction.GetValue(action) * this.ITPMSet().freeLookSens, -6.0, 6.0));
      }
      if (this.m_itpFree || this.m_itpSitOrbit) && Equals(name, n"CameraX") {
        this.m_itpYaw = this.ITPMWrapDeg(this.m_itpYaw - xs * ListenerAction.GetValue(action) * ITPMCfgPitchPerUnitStick());
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
  let rcb: ref<ITPMRestoreCallback> = new ITPMRestoreCallback();
  rcb.player = this;
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(rcb, 5.0, true);
  // mouse axes for the third-person camera: registered once, never unregistered (the game's own code may rely on them)
  this.RegisterInputListener(this, n"CameraMouseY");
  this.RegisterInputListener(this, n"CameraY");
  this.RegisterInputListener(this, n"CameraMouseX");
  this.RegisterInputListener(this, n"CameraX");
  let ksuf: array<String> = ITPMKeySuffixes();
  let ki: Int32 = 0;
  while ki < ArraySize(ksuf) {
    this.RegisterInputListener(this, StringToName("ITP_K_" + ksuf[ki]));
    ki += 1;
  }
  this.RegisterInputListener(this, n"ITP_QuickFpp");
  this.RegisterInputListener(this, n"ITP_Shoulder");
  this.RegisterInputListener(this, n"ITP_Front");
  this.RegisterInputListener(this, n"ITP_ProfilePrev");
  this.RegisterInputListener(this, n"ITP_ProfileNext");
  this.RegisterInputListener(this, n"ITP_FreeLook");
  GameInstance.GetQuestsSystem(this.GetGame()).SetFact(n"immersive_third_person_notice_seen", 1);
  return wrappedMethod();
}
