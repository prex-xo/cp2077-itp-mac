
// Mac replacements for functions the Windows Codeware adds but NightCity Console's Mac Codeware lacks.

// Windows: EntityID.ToHash (64-bit). Mac vanilla only has a 32-bit hash.
public func ITPMacEntityHash(id: EntityID) -> Uint64 {
  return Cast<Uint64>(EntityID.GetHash(id));
}

// Windows: player.GetComponents(). Mac has no way to list components, so look up the known body ones by name.
// TODO(stage1 test): confirm these names exist on V; add more as found.
public func ITPMacPlayerComponents(player: ref<PlayerPuppet>) -> array<ref<IComponent>> {
  let names: array<CName> = [
    n"t0_000_pwa_base__full", n"l0_000_pwa_base__cs_flat", n"a0_000_pwa_base__full", n"hh_000_pwa_base__full",
    n"n0_000_pwa_base__full", n"a0_000_pwa_base", n"hh_000_pwa_base", n"n0_000_pwa_base",
    n"tpp_camera_force_pwa_base_full"
  ];
  let result: array<ref<IComponent>>;
  if !IsDefined(player) {
    return result;
  };
  let i: Int32 = 0;
  while i < ArraySize(names) {
    let c: ref<IComponent> = player.FindComponentByName(names[i]);
    if IsDefined(c) {
      ArrayPush(result, c);
    };
    i += 1;
  };
  return result;
}
