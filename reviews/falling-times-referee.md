> **About this file.** Report of an AI agent (Anthropic's Claude) instructed to act as a hostile referee. It reviewed version 1 of the falling-times note; its corrections are applied in the current version (`falling-times/README.md`). Reproduced unedited. It is not a human review.

# Referee report R1: "Two conjectures on Syracuse falling times are false"

Independent hostile review, 2026-11-22. I read the note, the Lean file (sha256 261972c7…cbf62, which matches check.log), and the arXiv:2107.11160 v3 and v4 PDFs.

## Verdict

**Minor revision.** The mathematics is correct, and both counterexamples hold under the paper's definitions. There is no FATAL issue. The fixes concern presentation and one unchecked source.

## Findings

1. **GAP: the published version was not checked.** The note quotes arXiv v4. The chapter is Springer Proc. Math. Stat., *Combinatorial and Additive Number Theory V*, 2022, pp. 139–152, DOI 10.1007/978-3-031-10796-2_7 (per Crossref). The thresholds changed once already (v3: 2^150), so they may differ there too. *Fix:* write "as stated in arXiv v4", add the DOI and pages, and check the chapter or say it was not checked.

2. **GAP: internal jargon (status line, sections 4 and 7).** Phrases like "five separately written programs", "the plan's author, the coordinator, two referees and a search agent", "the comparator tool", "this project" and "Ryan's decision" are unverifiable to an outsider. They also hide that every checker was an AI agent. *Fix:* rewrite these parts for outside readers. State the authorship (AI-assisted, with a named human sender). Present the Lean certificate as the evidence, plus one reproducible script, instead of a head count.

3. **COSMETIC: section 3 says the thresholds were "calibrated on the case c = 1".** The paper says they were "inspired by" Conjectures 4.2 and 4.4, and it also cites semi-random search and a heuristic. *Fix:* "inspired mainly by the family 2^ℓ − 1".

4. **COSMETIC: `oddPart_spec` (section 4).** The lemma proves that oddPart n is odd and that n = 2^k·oddPart n. "Largest odd factor" then follows by uniqueness, which is not proved in Lean. The main theorems do not use the lemma; it is only the bridge to the paper's definition of syr. *Fix:* reword to say exactly that.

5. **COSMETIC: "the first 4,981 Syracuse steps … are a pure rise".** Since ν₂(m₀+1) = 4983, the pure rise is actually 4,982 steps. Using 4,981 is valid. *Fix:* "the file handles 4,981 of them in closed form".

6. **COSMETIC: the formula for ℓ.** The note writes ℓ = ⌊log₂ n⌋+1 "as in the paper", but the paper writes ⌊log₂(n)+1⌋. The two are equal. *Fix:* add "equivalently".

7. **COSMETIC: section 3 claims.**
   - "Failures thin out quickly" is supported only by the ft rows. The sft row has 1 failure in 300, which is not thin.
   - m₀ = 262139·2^4983 − 1 belongs to no scanned family, and the note never says how it was found.
   - *Fix:* limit the claim to ft, and add one line on where m₀ came from.

8. **COSMETIC, optional courtesy.** In v4, section 5 places its ft = 5 example in "[2^70, 2^71 − 1]", but that number has 171 bits, so this is a typo for 2^170. I recomputed its ft = 5.

## What I verified, and how

**Definitions against the v4 PDF.** Every definition matches:
- `T` matches the abstract, `jp` matches Def. 1.1, and `iter f k x` = f^(k)(x).
- `FtLE n b` (∃k, 1 ≤ k ≤ b, jp^(k)(n) < n) is exactly ft(n) ≤ b under Def. 1.5. This includes ft = ∞, and the inequality is strict.
- `Conjecture51` takes n ≥ 2^500, which lies inside n ≥ 3.
- `syr = oddPart(3n+1)` agrees with the paper's syr on odd numbers and always outputs an odd number, so orbits stay in O.
- `sjp`, `SftLE` and `Conjecture52` (odd, ≥ 2^5000) match Defs. 3.1 and 3.3 and Conjecture 5.2.
- `Nat.log2` in core (`Init/Data/Nat/Log2.lean`) is a structural recursion: 0 for n < 2, else 1 + log2(n/2). Its docstring gives log2 7 = 2 and log2 8 = 3, so it is ⌊log₂ n⌋. The `extern` attribute affects compiled code only.
- Kernel spot checks: len 1, 2, 7, 8 = 1, 2, 3, 4; jp(27) = 71, sjp(27) = 107.
- There is no off-by-one, and ft(n₀) is still 5 with ℓ±1 steps per jump.

**Certificate.**
- Recompiled with `lean -M 3000` (4.35.0): exit 0, no errors or warnings, 9.6 s.
- The axioms printed are the same as in check.log: propext and Quot.sound, plus Classical.choice in `oddPart_spec` only.
- Grep finds no sorry, native_decide, axiom, unsafe, implemented_by, extern, macro, notation, syntax, instance, attribute, set_option, open, universe, opaque or partial.
- The file has no imports, and no `Nat.*` names are shadowed. The non-ASCII characters are ordinary math notation.
- `#print` shows the unfolded conjecture statements as expected.
- Negative controls fail as they should: `decide +kernel` rejects jp⁵(n₀) ≥ n₀ and len(jp n₀) = 801.

**What the kernel evaluates:**
- 2^500 ≤ n₀ and len n₀ = 511;
- ¬(J¹<n₀ ∨ … ∨ J⁴<n₀) and J⁵<n₀, where Jᵏ is the k-fold iterate of `jpS`;
- m₀ is odd, 2^5000 ≤ m₀, len m₀ = 5001, and m₀ = 2^4981·(4·262139) − 1;
- ¬(w₁<m₀ ∨ sjpS w₁<m₀) and sjpS(sjpS w₁)<m₀, where w₁ is 20 syr steps from 3^4981·4·262139 − 1.

`iterS_eq` proves `jpS` = `jp` and `sjpS` = `sjp` by induction.

**Trust.** `decide +kernel` produces `of_decide_eq_true (Eq.refl true)`. The kernel reduces the Decidable instance itself, using GMP-accelerated Nat arithmetic. The trusted base is therefore the kernel plus GMP, with no compiler or evaluator.

**`iter_syr_rise`, checked by hand.**
- Let W = 2^j a ≥ 1. Then x = 8W − 1 ≡ 3 (mod 4).
- So syr(x) = 12W − 1 = 2^j·4(3a) − 1.
- The induction hypothesis at 3a then gives 3^(j+1)·4a − 1. Correct.
- m₀+1 = 262139·2^4983 = 2^4981·4·262139.
- 5001 = 4981 + 20 is used in the right order through `iter_add`.

**My own numbers.** I wrote my own Python (scratchpad `referee-efs/ref.py` and `scan.py`, with no imports from the authors' code). I first checked it against the paper's values: ft(41) = 8, ft(43) = 2, ft(199) = 1, sft(199) = 5, sft(27) = 6, ft(2^5−1) = ft(2^6−1) = 8, sft = 5 for both, and sft(2^24−1) = 4. Results:
- ft(n₀) = 5, with lengths 511 → 800, 647, 567, 517, 425;
- sft(m₀) = 3, with lengths 5001 → 7912, 5038, 3152;
- ft(2^132−1) = 5;
- table row 1: c ∈ {1097, 3291};
- table row 4: c = 2167 only, out of 300;
- I did not recompute the middle rows.

**Statements about the paper.** These are all accurate:
- Conjectures 5.1 and 5.2 and the 2^132 sentence are verbatim from v4.
- v3 had the 2^150 threshold, and already had 2^5000 for Conjecture 5.2.
- Proposition 4.3 and Conjecture 4.4 (ℓ from 4,625 to 500,000) are described correctly.
- Conjectures 2.4 (B ≥ 16) and 3.7 (C ≥ 10, n ≡ 3 mod 4, C = 12 "to be on a safer side") are described correctly.
- The e-mail invitation and the dedicated webpage are in v4 §5.2.
- v4 is dated 20 Oct 2021.

Section 6 unchecked.

## Probability

I put **0.995** on both counterexamples being correct against the arXiv v4 definitions. The residual risk is a misreading of the definitions, or the kernel. Whether the Springer chapter uses different thresholds is a separate question (finding 1).
