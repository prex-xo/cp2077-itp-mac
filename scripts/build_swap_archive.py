#!/usr/bin/env python3
"""Build ONE extra archive that makes the game use the mod's third-person animation sets.

For every pair (vanilla set hash 'target', mod third-person set hash 'source') it copies the mod set's data
(verbatim, no recompression) into a new archive under the VANILLA hash. The game loads archive/Mac/mod/* after its own
archives, so these records take the place of the vanilla sets. Nothing in the game is edited; remove the file to undo.

Usage: python3 -I build_swap_archive.py <mod immersive_third_person.archive> <animset_replacements.json> <out.archive> [--only-group NAME]
Reads the mod archive and the json; writes only <out.archive>.
"""
import json, os, struct, sys

POLY = 0xC96C5795D7870F42
_T = []
for i in range(256):
    c = i
    for _ in range(8):
        c = (c >> 1) ^ POLY if c & 1 else c >> 1
    _T.append(c)

def crc64(data):
    c = 0xFFFFFFFFFFFFFFFF
    for b in data:
        c = (c >> 8) ^ _T[(c ^ b) & 0xFF]
    return c ^ 0xFFFFFFFFFFFFFFFF

def align(n, a=4096):
    return (n + a - 1) // a * a

class Rdar:
    def __init__(self, path):
        self.path = path
        with open(path, 'rb') as f:
            self.header = f.read(52)
            assert self.header[:4] == b'RDAR', 'not an RDAR archive'
            self.ipos, = struct.unpack('<Q', self.header[8:16])
            self.isz, = struct.unpack('<I', self.header[16:20])
            f.seek(self.ipos)
            self.index = f.read(self.isz)
        self.n, self.nseg, self.ndep = struct.unpack('<III', self.index[16:28])
        self.rec = [self.index[28 + i * 56: 28 + (i + 1) * 56] for i in range(self.n)]
        so = 28 + self.n * 56
        self.seg = [struct.unpack('<QII', self.index[so + i * 16: so + (i + 1) * 16]) for i in range(self.nseg)]
        self.dep_off = so + self.nseg * 16
        self.by_hash = {struct.unpack('<Q', r[:8])[0]: r for r in self.rec}

def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    src_path, map_path, out_path = sys.argv[1:4]
    src = Rdar(src_path)
    if crc64(src.index[16:]) != struct.unpack('<Q', src.index[8:16])[0]:
        sys.exit('index CRC mismatch on the source archive, refusing to continue')
    pairs = json.load(open(map_path))['replace']
    only = None
    if '--only-list' in sys.argv:
        only = set(open(sys.argv[sys.argv.index('--only-list') + 1]).read().split())
    chosen = {}
    missing = 0
    for p in pairs:
        t, s = int(p['target'], 16), int(p['source'], 16)
        if only is not None and p['target'] not in only:
            continue
        if s not in src.by_hash:
            missing += 1
            continue
        chosen[t] = s
    print(f'{len(chosen)} sets to swap ({missing} source sets missing in the mod archive)')
    items = sorted(chosen.items())
    new_segs, new_recs, new_deps = [], [], []
    with open(src_path, 'rb') as sf, open(out_path, 'wb') as of:
        of.write(b'\0' * 4096)
        off = 4096
        for t, s in items:
            r = src.by_hash[s]
            a, b = struct.unpack('<II', r[20:28])
            first = len(new_segs)
            for i in range(a, b):
                so_, zs, sz = src.seg[i]
                sf.seek(so_)
                data = sf.read(zs)
                assert len(data) == zs
                of.write(data)
                new_segs.append((off, zs, sz))
                off += zs
            nr = bytearray(r)
            struct.pack_into('<Q', nr, 0, t)          # <- file it under the VANILLA hash
            struct.pack_into('<II', nr, 20, first, len(new_segs))
            ds, de = struct.unpack('<II', r[28:36])
            dstart = len(new_deps)
            for k in range(ds, de):
                new_deps.append(src.index[src.dep_off + 8 * k: src.dep_off + 8 * k + 8])
            struct.pack_into('<II', nr, 28, dstart, len(new_deps))
            new_recs.append(bytes(nr))
        body = b''.join(new_recs) + b''.join(struct.pack('<QII', *x) for x in new_segs) + b''.join(new_deps)
        head = bytearray(28)
        head[0:4] = src.index[0:4]
        struct.pack_into('<III', head, 16, len(new_recs), len(new_segs), len(new_deps))
        index = bytearray(bytes(head) + body)
        rel = src.isz - struct.unpack('<I', src.index[4:8])[0]
        struct.pack_into('<I', index, 4, len(index) - rel)
        struct.pack_into('<Q', index, 8, crc64(bytes(index[16:])))
        ipos = align(off)
        of.write(b'\0' * (ipos - off))
        of.write(bytes(index))
        fsize = align(ipos + len(index))
        of.write(b'\0' * (fsize - ipos - len(index)))
        hdr = bytearray(src.header)
        struct.pack_into('<Q', hdr, 8, ipos)
        struct.pack_into('<I', hdr, 16, len(index))
        struct.pack_into('<Q', hdr, 32, fsize)
        of.seek(0)
        of.write(bytes(hdr))
    print(f'wrote {out_path}: {fsize/1e6:.1f} MB, {len(new_recs)} records, {len(new_segs)} segments')

if __name__ == '__main__':
    main()
