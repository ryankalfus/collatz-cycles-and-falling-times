# Two conjectures on Syracuse falling times are false

**Status (2026-11-23, version 3).** Both counterexamples are checked by the Lean kernel and were recomputed independently five times. All of this work, including every check and review, was done by AI agents (Anthropic's Claude) run by Ryan Kalfus. No human mathematician has reviewed it. The paper's authors were e-mailed on 22 November 2026; there was no reply at the time of writing.

## 1. The conjectures

S. Eliahou, J. Fromentin and R. Simonetto, *Is the Syracuse falling time bounded by 12?*, [arXiv:2107.11160v4](https://arxiv.org/abs/2107.11160v4) (20 October 2021).

The paper also appeared as a chapter of *Combinatorial and Additive Number Theory V*, Springer Proceedings in Mathematics & Statistics, 2022, pp. 139–152, doi:10.1007/978-3-031-10796-2_7. **Everything below refers to arXiv v4.** The Springer chapter was not available to us. Since the thresholds changed between arXiv versions, the chapter's statements should be compared before this note is used.

Definitions, as in the paper:

- T(n) = n/2 for even n and (3n + 1)/2 for odd n.
- ℓ = ⌊log₂(n) + 1⌋, equivalently ⌊log₂ n⌋ + 1: the number of binary digits of n.
- The *jump function* is jp(n) = T^(ℓ)(n): apply T exactly ℓ times.
- The *falling time* ft(n), for n ≥ 3, is the least k ≥ 1 with jp^(k)(n) < n.
- syr(x) = (3x + 1)/2^ν for odd x, where 2^ν is the largest power of 2 dividing 3x + 1.
- sjp(n) = syr^(ℓ)(n), and the *Syracuse falling time* sft(n), for odd n ≠ 1, is the least k ≥ 1 with sjp^(k)(n) < n.

The two conjectures, quoted from Section 5 of v4:

> **Conjecture 5.1.** We have ft(n) ≤ 4 for all n ≥ 2^500.
>
> **Conjecture 5.2.** We have sft(n) ≤ 2 for all odd n ≥ 2^5000.

The paper notes that the first threshold "cannot be significantly lowered, since ft(2^132 − 1) = 5". Version 3 had the threshold 2^150. The second threshold is, in the paper's words, "inspired by" the family 2^ℓ − 1, for which the authors computed sft(2^ℓ − 1) = 2 for all ℓ from 4,625 to 500,000.

## 2. Counterexamples

**Theorem 1.** Let n₀ = 1097·2^500 − 1, a number of 511 binary digits. Then ft(n₀) = 5.

**Theorem 2.** Let m₀ = 2^5001 − 1 − 320·2^4977 = 262139·2^4983 − 1, an odd number of 5,001 binary digits. Then sft(m₀) = 3.

Binary lengths after each jump:

| Start | Digits | After jump 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| n₀ (jp) | 511 | 800 | 647 | 567 | 517 | 425 |
| m₀ (sjp) | 5,001 | 7,912 | 5,038 | 3,152 | | |

A number with more digits than the start is larger than the start, so the table shows ft(n₀) > 4 and sft(m₀) > 2.

## 3. How common they are

Both witnesses have the form c·2^b − 1, which begins with b consecutive odd steps, and both were found by searching structured families of this kind. The paper's thresholds were inspired by the case c = 1.

| Family | Range scanned | Result |
|---|---|---|
| ft, n = c·2^500 − 1 | odd c < 4,096 | 2 with ft ≥ 5: c = 1097 and c = 3291 |
| ft, n = c·2^1000 − 1 | odd c < 303,303 | none |
| ft, n = c·2^2000 − 1 | odd c < 85,999 | none |
| sft, n = c·2^4990 − 1 | odd c from 2,049 to 2,647 | 1 of 300 with sft ≥ 3: c = 2167 |

So both conjectures fail at their stated thresholds. For ft, failures thin out quickly with size, as the paper expects. For sft only one size was scanned, so nothing is claimed about larger sizes. Whether either conjecture holds with a larger threshold is open. A random-walk model of the jumps predicts that failures exist at every size but become exponentially rare; that is a heuristic, not a result.

## 4. Verification

**Lean.** [EFSCounterexamples.lean](EFSCounterexamples.lean) imports only Lean's core library. It states the definitions above, the two conjectures as `Conjecture51` and `Conjecture52`, and proves:

- `not_conjecture51 : ¬ Conjecture51` and `not_conjecture52 : ¬ Conjecture52`;
- `ftLE_n₀` and `sftLE_m₀`, which with the above give ft(n₀) = 5 and sft(m₀) = 3 exactly;
- `lens_n₀` and `lens_m₀`, the table of section 2;
- `anchor_ft`, the paper's own value ft(2^132 − 1) = 5, recomputed from the file's definitions;
- `oddPart_spec`: the file's `oddPart n` is odd and n is a power of 2 times it. That determines it as the largest odd factor.

All arithmetic is evaluated by the Lean kernel (`decide +kernel`), so no compiler is trusted; `native_decide` is not used. The file checks in about 10 seconds with Lean 4.35.0. The axioms used are `propext`, `Quot.sound` and, in one helper lemma, `Classical.choice`. Output of the check: [check.log](check.log).

One proof detail: the first 4,982 Syracuse steps from m₀ are a pure rise. The file takes 4,981 of them through a closed form proved in general (`iter_syr_rise`) and evaluates the remaining 20 steps of the first jump directly.

**Independent recomputation.** The values of section 2 were recomputed by five programs written separately, by different AI agents that did not share code: the agent that found the examples, a coordinating agent, and three reviewing agents. [verify.py](verify.py) is a standalone script that recomputes them in about a second. The scans of section 3 are in [family_scan.py](family_scan.py).

**Review.** A reviewing agent compared every Lean definition with the v4 PDF, read the definition of `Nat.log2` in the Lean sources, recompiled the file, confirmed that false variants of the claims are rejected, and recomputed the first and last rows of the table in section 3: [../reviews/falling-times-referee.md](../reviews/falling-times-referee.md). Its verdict was minor revision with no fatal finding; this version applies its corrections. It put the probability that both counterexamples are correct against the v4 definitions at 0.995.

## 5. What is not affected

The paper's main conjectures are global bounds: Conjecture 2.4 (ft(n) ≤ B for all n ≥ 3, for some B ≥ 16) and Conjecture 3.7 (sft(n) ≤ C for all n ≡ 3 mod 4, for some C ≥ 10, with C = 12 the "safer" choice of the title). Nothing here bears on them.

## 6. Prior art

A search found no published counterexample: all four arXiv versions, the citation lists at Semantic Scholar and OpenAlex, the authors' later papers, archived copies of their homepages, and the usual forums. The paper invites readers who find an n ≥ 2^500 with ft(n) ≥ 5 to e-mail the authors, who would record it on a dedicated webpage; no such page is linked from their archived sites. Not read: the Springer chapter and one paywalled citing paper.

## 7. Open items

- The Springer chapter's Conjectures 5.1 and 5.2 have not been compared with arXiv v4.
- No human has compared the Lean definitions with the paper.
- A check with independent Lean kernels has not been run.

## How to check

```
python3 verify.py                  # about one second
lean EFSCounterexamples.lean       # Lean 4.35.0, about ten seconds, no dependencies
python3 family_scan.py             # the short scans of section 3; add --long for the rest
```
