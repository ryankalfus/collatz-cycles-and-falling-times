"""Checks for the note cycles-window-theorem.pdf in this folder.

Run:  python3 cycle_window_check.py      (about 20 seconds)

A "rise block" from odd x: write x + 1 = 2^k * s (s odd); k odd steps of
T lead to 3^k * s - 1; then l = v2(3^k * s - 1) even steps lead to the
next odd number.  A window is r consecutive rises with the r - 1 falls
between them; its length is J = k_0 + l_0 + ... + k_{r-1}.

Part 1 verifies the window identity (a sum of 2r integers equal to 0,
all of the form +-2^a 3^b except two) and the 2-adic valuation pattern
that rules out vanishing subsums.
Part 2 looks for windows that are long compared with log2(x + 1).  The
candidate theorem says the excess J - log2(x + 1) is at most
eps * log2(x) + C(r, eps).  A structured family with linear excess would
refute the derivation.
"""
import random
from math import comb, gcd, log2


def v2(n):
    return (n & -n).bit_length() - 1


def blocks(x, r):
    ks, ls, ss = [], [], []
    for i in range(r):
        y = x + 1
        k = v2(y)
        ks.append(k)
        ss.append(y >> k)
        if i == r - 1:
            break
        top = 3**k * ss[-1] - 1
        l = v2(top)
        ls.append(l)
        x = top >> l
    return ks, ls, ss


def window_terms(ks, ls, ss):
    """The 2r terms, after dividing the identity by 2^k_0."""
    r = len(ks)
    out = [3 ** sum(ks[:-1]) * ss[0]]                      # A
    for j in range(r - 1):
        a = sum(ks[j + 1:r - 1])
        b = sum(ks[i] + ls[i] for i in range(j)) + ks[j] - ks[0]
        out.append(-(3**a) * 2**b)                         # N_j
        out.append(3**a * 2 ** (b + ls[j]))                # P_j
    vB = sum(ks[i] + ls[i] for i in range(r - 1)) - ks[0] + ks[-1]
    out.append(-(2**vB) * ss[-1])                          # B
    return out


print("Part 1: identity and valuation pattern on random windows")
random.seed(1)
n_checked = 0
n_subsums = 0
for r in (2, 3, 4, 5, 8):
    for bits in (1, 8, 40, 200, 1000):      # bits = 1 is the start x0 = 1
        for _ in range(400 if bits > 1 else 1):
            x = random.getrandbits(bits) | 1
            ks, ls, ss = blocks(x, r)
            t = window_terms(ks, ls, ss)
            assert len(t) == 2 * r and sum(t) == 0
            vals = [v2(abs(u)) for u in t]
            assert vals[0] == 0 and vals[1] == 0          # A and N_0 are odd
            assert all(vals[i] < vals[i + 1] for i in range(1, 2 * r - 1))
            g = 0
            for u in t:
                g = gcd(g, abs(u))
            assert g == 1                                  # Lemma 3(3)
            if r <= 4 and bits <= 40:                      # Lemma 3(2), brute force
                for mask in range(1, (1 << (2 * r)) - 1):
                    assert sum(u for i, u in enumerate(t) if mask >> i & 1) != 0
                    n_subsums += 1
            # S-free parts: only A and B carry one, and their product is
            # at most (x + 1) * max|term| / 2^J
            J = sum(ks) + sum(ls)
            assert ss[0] * ss[-1] * 2**J <= (x + 1) * max(abs(u) for u in t)
            n_checked += 1
print(f"   {n_checked} windows: sum = 0, valuations 0, 0, then strictly increasing, "
      f"gcd = 1, cofactor bound holds; {n_subsums} proper subsums checked, none zero")

print("Part 2a: every odd x < 2^22, max excess J_r - log2(x + 1) by bit length")
LIMIT = 1 << 22
best = {r: {} for r in (2, 3, 4)}
for x in range(3, LIMIT, 2):          # x = 1 is the trivial cycle
    n = x.bit_length()
    ks, ls, _ = blocks(x, 4)
    J = 0
    for r in (2, 3, 4):
        J = sum(ks[:r]) + sum(ls[:r - 1])
        e = J - log2(x + 1)
        cur = best[r].get(n)
        if cur is None or e > cur[0]:
            best[r][n] = (e, x)
print("   bits   r=2 (heur)   r=3 (heur)   r=4 (heur)      heur = log2 C(bits, 2r-1)")
for n in (6, 8, 10, 12, 14, 16, 18, 20, 22):
    row = [f"{best[r][n][0]:5.1f} ({log2(max(1, comb(n, 2 * r - 1))):4.1f})" for r in (2, 3, 4)]
    print(f"   {n:4d}   " + "   ".join(row))
for r in (2, 3, 4):
    e, x = max(best[r].values())
    print(f"   r={r}: largest excess {e:.2f} at x = {x} ({x.bit_length()} bits)")

print("Part 2b: structured starts x = 2^b * s - 1, b <= 600, odd s < 2^11")
for r in (2, 3):
    top = []
    for b in range(2, 601):
        for s in range(1, 1 << 11, 2):
            x = (s << b) - 1
            ks, ls, _ = blocks(x, r)
            J = sum(ks) + sum(ls)
            top.append((J - log2(x + 1), b, s))
    top.sort(reverse=True)
    by_range = [max(t[0] for t in top if lo <= t[1] < hi)
                for lo, hi in ((2, 150), (150, 300), (300, 450), (450, 601))]
    print(f"   r={r}: max excess by b-range [2,150) [150,300) [300,450) [450,600]: "
          + ", ".join(f"{v:.1f}" for v in by_range)
          + f"; overall top (excess, b, s) = ({top[0][0]:.1f}, {top[0][1]}, {top[0][2]})")
