> **About this file.** Report of an AI agent (Anthropic's Claude) instructed to act as a hostile referee. It reviewed version 2 of the cycles note; its corrections are applied in version 3 (`cycles/cycles-window-theorem.pdf`). Reproduced unedited apart from the removal of local file paths. It is not a human review.

# Referee report R1: "Collatz cycles have more than A·log K local minima"

Reviewed: the cycles note (version 2, 2026-11-22) and `cycle_window_check.py`; no other project file was read.

## 1. Verdict: minor revision

I tried to break it and could not. Theorem 1 is a correct, short corollary of Evertse's Corollary 1, which is quoted accurately. Theorem 2 and the Corollary follow from Theorem 1 and a polynomial bound on the cycle minimum. I re-derived every step, tested the lemmas and the algebra with independent code, enumerated all two-block windows up to 2,500 bits and all three-block windows up to 190 bits without finding linear excess, and found no earlier statement of the result. The defects sit around the proof, not in it: one citation is used outside its hypotheses (item 1), the "control that must fail" is analysed incompletely (item 2), and the numerical evidence and attribution are weaker than stated (items 4, 5). No FATAL item.

## 2. Errors and gaps

1. **GAP. Lemma 4, line 129.** Simons–de Weger (SdW) Lemma 12 is applied to every cycle. Its proof there reads: "We apply the Proposition on p. 160 of [Rh] with u₀ = 0, H = u₁ = K + L, and u₂ = −K. Together with Lemma 8 the result follows." Lemma 8 (K + L < 1.000001·δK) is proved from x_min > X₀, the computer-verification bound, for nontrivial cycles. Fix: the trivial cycle has minimum 1; any other cycle has K ≥ 2, and either min Ω < 32,800 < 153·2^14.3, or Λ < K/(3·min Ω) gives K + L ≤ e^0.46057·K and Rhin's H^(−13.3) applies. Any polynomial bound suffices. I could not open Rhin's paper; its range (H > 2, per a 2004 post by Steiner) I have only secondhand.

2. **GAP, in a remark, not in the proof. Remark 3, line 169.** It names only the Theorem E step. But the m = 1 rational cycles (a = 3^k − 2^k, d = 2^(k+l) − 3^k, map (3x + d)/2) already contradict the r = 1 case, which uses no Theorem E and has d^(2r−2) = 1. There the failing step is Lemma 4: for 3x + d it reads roughly min Ω < 153·d·K^14.3. Checked at k = 160: k₀ = 160 ≤ log₂(a + d) = 254 holds, while log₂(min Ω) = 253.6 against 14.3·log₂ K + 7.3 = 112. For r ≥ 2 both Lemma 4 and Theorem 1 pick up d.

3. **COSMETIC. Remark 2, line 168.** For 3x − 1 (the negative integers) "the same theorem" needs an exclusion. A window reaching the fixed point −1 has an infinite rise: y_j = 0, B = 0, Lemma 3 fails (x₀ = −3). The fixed point has m = 0, so Lemma 5 fails for it. Positivity is used openly in Lemmas 1, 4, 5 and 6, nowhere silently. With that exclusion the analogue is consistent with the cycles through −5 (K = 2, m = 1) and −17 (K = 7, m = 2), and with the 3x + 5 cycles (largest: K = 17, m = 6 and 7). These tests cannot discriminate: each map has finitely many known cycles.

4. **COSMETIC. Section 7, line 176.** "The largest excess … is 16.5 for r = 2, 21.2 for r = 3" is true only of the sample (s < 2^11, or x < 2^22). Complete enumeration gives, for r = 2, 22.45 at 70 bits (x₀ = 864306355882487185407), 29.15 at 500 bits, 30.77 at 2,420 bits; for r = 3, 35.44 at 186 bits. The heuristic should be log₂ C(bits, 2r − 1), not 2r − 2: the cofactor's size is a free parameter too. Growth is still logarithmic.

5. **COSMETIC. Lines 35 and 179–180.** The Corollary is Brox's theorem with 2 replaced by A. Say so, and cite Brox and Luca (section 4).

6. **COSMETIC. Lines 29 and 170.** Theorem 2 for (r, ε) follows from (r′, ε′) with r′ larger; the content is the Corollary. "r of order K/log K" is unsupported. The check script never tests Lemma 3(2), the gcd, or x₀ = 1.

## 3. What I verified, and how

**Lemmas 1–3, (2), (3), Lemma 6: correct.** Re-derived by hand, then tested with my own code (`a_lemmas.py`, blocks found by iterating T): every odd x₀ < 2^13 for r = 2..6, 8,400 random windows up to 2,000 bits, 3,510 starts 2^a·3^b·c − 1, x₀ = 1 for r ≤ 39, windows running into 1, 2, 1, 2. Lemma 3(2) was checked by brute force over all proper subsets for r ≤ 5. No two terms ever coincide in absolute value, and the argument concerns index sets anyway. r = 2 is fine.

**Theorem E: quoted correctly.** Read from the numdam scan, pp. 226–228. Corollary 1: "Let c, d be constants with c > 0, 0 ≤ d < 1, let S₀ be a finite set of prime numbers and let n be a positive integer. Then there are only finitely many tuples x = (x₀, x₁, …, x_n) of rational integers such that" (9) the sum is 0; (10) no subsum vanishes "for each proper, non-empty subset"; (11) gcd = 1; (12) Π_k (|x_k|·Π_{p∈S₀}|x_k|_p) ≤ c·‖x‖^d, with ‖x‖ = max |x_k| by his (2). Tuples, not projective points (that is his Theorem 1); nothing dropped.

**Section 4: correct.** The dichotomy has the right direction. (1 + ε)/(1 − 2.585ε) ≤ 1 + 7ε on (0, 1/6]. The map x₀ ↦ τ(x₀) is not injective (x₀ and T(x₀) inside one rise share a tuple) but finite-to-one, as argued. End-to-end test, r = 2, ε = 1/6, on every odd x₀ < 2^20 and every window with excess > 8 up to 700 bits (112,751 windows): each window outside the exceptional set satisfies J < (1 + 7ε)·log₂ y₀ + 1. Exceptional windows: 676 below 2^20, peaking at 17–18 bits; 78 above; none beyond 75 bits.

**Section 5: correct given Lemma 4.** Wrap-around is legitimate: Theorem 1 concerns N-orbits of arbitrary odd integers, and J_t ≤ J_r. Confirmed: u_{i+t} ≤ ρ·u_i; the sum in Step 2 (grid test); (δ − 1)/(δ·ln δ) = 0.8013; e^(13.3·0.46057)/3 = 152.47; K + L < 2.07K. SdW Theorem 3(d) reads "if m ≥ 527 875 035 then 1.7095 m < K < 15.108 mδ^m", as cited.

**Numerics (`d1`, `d2`, `d4`, `f_crosscheck`).** For r = 2, s₀ equals (1 − 2^(l₀))·3^(−k₀) mod 2^t at a run of zero bits [t, v) of that 2-adic number, and the excess is v − log₂ s₀. Scanning zero runs enumerates every window, with detectors for runs leaving the precision window (none fired); r = 3 likewise (C, 256-bit). The method agrees with brute force below 2^22; record holders were re-verified by iteration. Maximum excess for r = 2: 16.5 at 32–64 bits, 22.8 at 128–256, 25.3 at 512–1,024, 30.8 at 2,048–2,500. For r = 3: 22.9 at 32–64 bits, 35.4 at 128–190. Excess/bits falls from 0.32 to 0.013 (r = 2) and from 1.0 to 0.19 (r = 3). With 2-adic logarithms (s₀ < 2^11, l₀ ≤ 80, k₀ up to 2^400; r = 3 with s₀ < 32) the excess is log₂ k₀ + O(20). No linear family.

## 4. Prior art

- **Brox**, Acta Arith. 92 (2000). Full text sits behind a bot wall (https://eudml.org/doc/207379). SdW 2010, p. 4 (https://deweger.net/papers/%5B35a%5DSidW-3n+1-v1.44%5B2010%5D.pdf): "Brox [Br] showed that there are only finitely many m-cycles with m < 2 log K". Lagarias, bibliography II, entry 18 (https://arxiv.org/abs/math/0608208): "the number of 3x + 1 cycles C that have d(C) < 2log|C| is finite … in principle effective." Here d(C) = m and |C| = K.
- **Luca**, SUT J. Math. 41 (2005). PDF unreadable by my tools. Lagarias, entry 68: "there is an absolute constant C1 such that there are at least C1 log n ascents in any cycle." Ascents number at most m.
- **Hercher** (https://arxiv.org/abs/2201.00406), Lemma 20: n_{i+1} < n_i^δ, the same r = 1 bound as SdW Lemma 6. **Belaga**, Acta Arith. 106 (2003), "Effective polynomial upper bounds to perigees … of (3x + d)-cycles" (Lagarias, entry 11): bounds of the shape d·k^(c₀), matching the factor d of item 2.
- Searches for Collatz with S-unit, Subspace, Evertse or Schlickewei found only Verger-Gaugry, https://arxiv.org/abs/2611.14569 (three-term equation, divergent trajectories). Nothing with a constant above 1/ln δ, nothing of the form m/log K → ∞.
- Theorem 1 itself: for fixed l₀ the case r = 2 is a three-term statement of Mahler–Ridout type; uniformity in l₀ needs four terms, hence Evertse. I found no earlier statement.

## 5. Probabilities

- Theorem 2 correct: **0.94**. Residual risk: an oversight of mine, and Rhin's bound, seen only secondhand.
- Theorem 2 new: **0.70**. It extends Brox's 2 and SdW's 1/ln δ to every constant, ineffectively. I could not read Brox or Luca in full, and the step from Evertse to Theorem 1 is routine for a specialist.
