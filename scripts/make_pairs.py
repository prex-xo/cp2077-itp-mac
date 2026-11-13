#!/usr/bin/env python3
"""Writes pairs.inc (the table of animation set hashes the ITPMac plugin needs) from the user's own copy of the original mod.
Usage: make_pairs.py <unzipped original mod folder> <output pairs.inc>
The table sits in the original mod's Windows DLL (version 2.0.1); nothing from it is stored in this repo. If the DLL is a different
version the script stops, because the table position would be different."""
import hashlib, os, struct, sys

KNOWN_SHA256 = "cbd47d32eb9cb5656921b4243737ae47105f0c717e741951f492f9a8cc4b6864"   # ImmersiveThirdPerson.dll of mod version 2.0.1
OFFSET, COUNT = 0x23580, 753

def main():
    mod, out = sys.argv[1], sys.argv[2]
    dll = None
    for root, _, files in os.walk(mod):
        if "ImmersiveThirdPerson.dll" in files:
            dll = os.path.join(root, "ImmersiveThirdPerson.dll"); break
    if not dll:
        sys.exit("ImmersiveThirdPerson.dll was not found in the mod folder (it is in red4ext/plugins/ImmersiveThirdPerson/).")
    data = open(dll, "rb").read()
    if hashlib.sha256(data).hexdigest() != KNOWN_SHA256:
        sys.exit("This is not the DLL of mod version 2.0.1, so the animation table cannot be read safely. Use version 2.0.1 of the mod.")
    recs = [struct.unpack_from("<QQQQ", data, OFFSET + 32 * i) for i in range(COUNT)]
    if any(r[3] not in (0, 1) for r in recs) or any(r[1] == 0 and r[2] == 0 for r in recs):   # a set may lack variant A (male only) but never both
        sys.exit("The animation table in the DLL does not look as expected.")
    with open(out, "w") as f:
        f.write("// generated from the original mod's DLL by make_pairs.py: {vanilla set, variant A, variant B, flag}\n")
        for a, b, c, e in recs:
            f.write("{0x%016xull,0x%016xull,0x%016xull,%d},\n" % (a, b, c, e))
    print("wrote %s (%d animation sets)" % (out, COUNT))

main()
