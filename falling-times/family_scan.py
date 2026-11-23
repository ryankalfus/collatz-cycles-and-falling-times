"""How common are counterexamples in the family c * 2^b - 1?

Run:  python3 family_scan.py          (about 10 seconds)
      python3 family_scan.py --long   (adds the two long scans, about 6 minutes)
Supports section 3 of README.md in this folder. Uses the paper's
definitions: jp(n) = T^len(n)(n), ft(n) = least k >= 1 with jp^k(n) < n,
and the Syracuse versions sjp, sft.
"""
import sys
import time


def T(n):
    return n >> 1 if n % 2 == 0 else (3 * n + 1) >> 1


def syr(n):
    m = 3 * n + 1
    return m >> ((m & -m).bit_length() - 1)


def falling_time(n, step, cap):
    x = n
    for k in range(1, cap + 1):
        for _ in range(x.bit_length()):
            x = step(x)
        if x < n:
            return k
    return cap + 1          # means "> cap"


print("ft over n = c * 2^b - 1, odd c < 2^12 (so n >= 2^b)")
for b in (500, 1000):
    t0 = time.time()
    hits = [c for c in range(1, 1 << 12, 2) if falling_time((c << b) - 1, T, 4) > 4]
    print(f"  b = {b}: {len(hits)} of 2048 have ft >= 5; smallest c: {hits[:12]}"
          f"   [{time.time() - t0:.0f} s]")

print("sft over n = c * 2^4990 - 1, odd c in [2^11, 2^11 + 600) (n >= 2^5000)")
t0 = time.time()
hits = []
cs = range((1 << 11) + 1, (1 << 11) + 600, 2)
for c in cs:
    n = (c << 4990) - 1
    assert n >= 1 << 5000
    if falling_time(n, syr, 2) > 2:
        hits.append(c)
print(f"  {len(hits)} of {len(cs)} have sft >= 3; c: {hits[:12]}   [{time.time() - t0:.0f} s]")

if "--long" in sys.argv:
    print("long scans: ft over n = c * 2^b - 1")
    for b, cmax in ((1000, 303303), (2000, 85999)):
        t0 = time.time()
        hits = [c for c in range(1, cmax, 2) if falling_time((c << b) - 1, T, 4) > 4]
        print(f"  b = {b}: odd c < {cmax}: {len(hits)} with ft >= 5 {hits[:5]}   [{time.time() - t0:.0f} s]")
