#!/usr/bin/env python3
"""Checks a swap archive against the mod archive and the map: structure, CRC, every record's bytes identical to its source.
Usage: python3 -I verify_swap_archive.py <out.archive> <mod.archive> <animset_replacements.json>"""
import json, struct, sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from build_swap_archive import Rdar, crc64
out, mod, mp = sys.argv[1:4]
o, m = Rdar(out), Rdar(mod)
ok = True
def check(c, msg):
    global ok
    print(('OK   ' if c else 'FAIL ') + msg)
    ok = ok and c
check(o.header[:4] == b'RDAR', 'header magic')
check(crc64(o.index[16:]) == struct.unpack('<Q', o.index[8:16])[0], 'index CRC')
import os
check(os.path.getsize(out) % 4096 == 0, 'file size 4096-aligned')
pairs = {int(p['target'], 16): int(p['source'], 16) for p in json.load(open(mp))['replace']}
hs = [struct.unpack('<Q', r[:8])[0] for r in o.rec]
check(hs == sorted(hs), 'records sorted by hash')
check(len(set(hs)) == len(hs), 'no duplicate hashes')
check(all(h in pairs for h in hs), 'every record is a target of the map')
bad = 0
with open(out, 'rb') as of, open(mod, 'rb') as mf:
    for r in o.rec:
        h = struct.unpack('<Q', r[:8])[0]
        sr = m.by_hash[pairs[h]]
        a, b = struct.unpack('<II', r[20:28]); sa, sb = struct.unpack('<II', sr[20:28])
        if (b - a) != (sb - sa) or r[8:20] != sr[8:20] or r[36:] != sr[36:]:
            bad += 1; continue
        for i in range(b - a):
            oo, zs, sz = o.seg[a + i]; mo, zs2, sz2 = m.seg[sa + i]
            of.seek(oo); mf.seek(mo)
            if zs != zs2 or sz != sz2 or of.read(zs) != mf.read(zs2):
                bad += 1; break
check(bad == 0, f'all {len(o.rec)} records byte-identical to their source sets ({bad} bad)')
print('ALL CHECKS PASSED' if ok else 'SOMETHING FAILED')
sys.exit(0 if ok else 1)
