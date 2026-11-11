#!/usr/bin/env python3
"""Builds the Mac scripts: original mod's redscripts (read from YOUR copy of the mod) + our patches + our own files.
Usage: python3 -I scripts/make_port.py <unzipped original mod folder> <output folder>
Nothing of the original mod is stored in this repository; it is read from the folder you pass in."""
import os, shutil, sys

if len(sys.argv) != 3:
    sys.exit(__doc__)
mod, out = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = os.path.join(mod, "r6", "scripts", "immersive_third_person")
if not os.path.isdir(src):
    sys.exit(f"Not the original mod folder: {src} not found. Unzip the Nexus download and pass that folder.")
dst = os.path.join(out, "r6", "scripts", "immersive_third_person")
shutil.rmtree(out, ignore_errors=True)
os.makedirs(dst)
for f in os.listdir(src):
    if f.endswith(".reds"):
        shutil.copy(os.path.join(src, f), dst)

def patch(fn, old, new, count):
    p = os.path.join(dst, fn)
    s = open(p, encoding="utf-8").read()
    n = s.count(old)
    if n != count:
        sys.exit(f"{fn}: expected {count} x {old!r}, found {n}. Is this really Immersive Third Person 2.0.1 (Nexus 32203)?")
    open(p, "w", encoding="utf-8").write(s.replace(old, new))

# Windows-Codeware functions that NightCity Console's Mac Codeware does not provide
B = "tpp_camera_bridge.reds"
patch(B, "player.GetComponents()", "ITPMacPlayerComponents(player)", 7)
patch(B, "ResRef.ToString(ResourceAsyncRef.GetPath(morph.morphResource))", '"morph"', 1)
patch(B, "      morph.RefreshAppearance();\n", "", 1)
patch(B, "ResRef.ToString(ResourceAsyncRef.GetPath(skinned.mesh))", '"skinned"', 1)
patch(B, "      skinned.RefreshAppearance();\n", "", 1)
patch(B, "    component.RefreshAppearance();\n", "", 1)
patch(B, "NameToString(body.appearanceName)", '""', 1)
patch(B, "NameToString(component.appearanceName)", '""', 4)
patch(B, "ResRef.ToString(component.appearancePath)", '""', 5)
patch("tpp_camera_api.reds", "EntityID.ToHash(id)", "ITPMacEntityHash(id)", 2)
patch("tpp_camera_headlook.reds",
      "return EntityID.FromHash(Cast<Uint64>(this.addonHigh) * 4294967296ul + (Cast<Uint64>(this.addonLow) & 4294967295ul));",
      "let none: EntityID;\n    return none;", 1)

# our own files
for name, target in (("itp_mac_compat.reds", "zz_itp_mac_compat.reds"),
                     ("itp_mac_camera.reds", "zz_itp_mac_camera.reds"),
                     ("itp_mac_settings.reds", "zz_itp_mac_settings.reds")):
    shutil.copy(os.path.join(root, "port", name), os.path.join(dst, target))
print("built:", dst)
