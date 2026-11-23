# Two results near the Collatz problem

**Read this first.** Everything here was found, written and checked by AI agents (Anthropic's Claude) run by Ryan Kalfus in November 2026. No human mathematician has reviewed any of it. The first result is machine-checked in Lean. The second is a written proof whose novelty is not established. Neither is a step toward proving the Collatz conjecture; both are results about its neighbourhood.

If you can confirm or refute either one, or know earlier work, please open an issue.

## 1. Two conjectures on Syracuse falling times are false

Folder: [falling-times/](falling-times/)

Eliahou, Fromentin and Simonetto ([arXiv:2107.11160v4](https://arxiv.org/abs/2107.11160v4)) define a *jump* as the Collatz map T applied ℓ times, where ℓ is the number of binary digits of n, and the *falling time* ft(n) as the number of jumps needed to get below n; sft is the same for the Syracuse map. They conjecture:

- **5.1:** ft(n) ≤ 4 for all n ≥ 2^500.
- **5.2:** sft(n) ≤ 2 for all odd n ≥ 2^5000.

Counterexamples:

| Number | Binary digits | Value |
|---|---|---|
| 1097·2^500 − 1 | 511 | ft = 5 |
| 2^5001 − 1 − 320·2^4977 | 5,001 | sft = 3 |

**Evidence.** [EFSCounterexamples.lean](falling-times/EFSCounterexamples.lean) states the paper's definitions and both conjectures and proves their negations. It imports only Lean's core library, every number is evaluated by the Lean kernel (no `native_decide`), and it checks in about ten seconds. [verify.py](falling-times/verify.py) recomputes the values in plain Python.

**Limits.**
- Only the stated thresholds are refuted. Failures are rare (2 of 2,048 candidates in one family at 2^500, none found above 2^1000), so the conjectures may hold with larger thresholds.
- The statements were taken from arXiv version 4. The published Springer chapter was not available and has not been compared.
- The paper's main conjectures, global bounds on ft and sft, are not affected.
- The authors were e-mailed on 22 November 2026.

Details: [falling-times/README.md](falling-times/README.md).

## 2. Collatz cycles have more than A·log K local minima

Folder: [cycles/](cycles/) · Note: [cycles-window-theorem.pdf](cycles/cycles-window-theorem.pdf) (6 pages)

Let a cycle of the Collatz map have K odd elements and m local minima.

**Claim.** For every constant A, only finitely many cycles have m ≤ A·ln K.

Known before: Brox (2000) for A = 2, and about 2.17 implicit in Simons–de Weger. The proof looks at windows of r consecutive rises of an orbit, writes each window as a sum of 2r integers that are products of 2s and 3s except for two, and applies Evertse's 1984 theorem on sums of S-units.

**Status.**
- Written proof only. Not formalized.
- It passed a blind re-derivation and a hostile review, both by AI agents. The referee's own estimates: 0.94 that it is correct, 0.70 that it is new.
- **Novelty is not established.** The searches could not open Brox's paper or Luca's 2005 paper in full.

**Limits.**
- Ineffective: no list of exceptional cycles and no bound on them.
- Equally true for 3x+d, which has cycles. It cannot exclude cycles.
- It concerns a set believed to contain only the trivial cycle.

**What would refute it.** An infinite family of windows whose length exceeds log₂ of the starting point by an amount linear in that logarithm would contradict Theorem 1 of the note. An earlier paper proving m / log K → ∞ would make it not new.

## How to check

```
python3 falling-times/verify.py                 # about one second
lean falling-times/EFSCounterexamples.lean      # Lean 4.35.0, about ten seconds
python3 cycles/cycle_window_check.py            # about 20 seconds
tectonic cycles/cycles-window-theorem.tex       # rebuilds the PDF
```

## What "checked" means here

| Claim | Checked by | Not checked |
|---|---|---|
| The two counterexamples | Lean kernel; five separately written programs; an AI referee who compared the Lean definitions with the arXiv text | Independent Lean kernels; the Springer chapter; any human |
| The cycles theorem | A blind re-derivation and a hostile referee, both AI; scripts testing the key identity and searching for counterexamples to the window bound | Lean; any human; the full text of Brox (2000) and Luca (2005) |

The two referee reports are in [reviews/](reviews/), unedited apart from the removal of local file paths.

## Licence

Code (Lean and Python) is under Apache-2.0, see [LICENSE](LICENSE). Text and the PDF are under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
