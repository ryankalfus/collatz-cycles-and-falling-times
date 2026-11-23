/-!
# Two conjectures on Syracuse falling times are false

Paper: S. Eliahou, J. Fromentin, R. Simonetto, *Is the Syracuse falling time bounded by 12?*,
arXiv:2107.11160v4 (20 Oct 2021).

* Conjecture 5.1: `ft(n) ≤ 4` for all `n ≥ 2^500`.
* Conjecture 5.2: `sft(n) ≤ 2` for all odd `n ≥ 2^5000`.

This file imports nothing beyond Lean's core library. Section 1 states the paper's
definitions and the two conjectures. Section 2 gives the witnesses. Section 3 is proof
machinery. Section 4 has the results. Every numerical fact is checked by the Lean kernel
(`decide +kernel`); `native_decide` is not used.

Check with:  `lean EFSCounterexamples.lean`   (Lean 4.35.0)
-/

namespace EFS

/-! ## 1. Definitions from the paper -/

/-- `f` applied `k` times: `iter f k x = f^(k)(x)`. -/
def iter (f : Nat → Nat) : Nat → Nat → Nat
  | 0, x => x
  | k + 1, x => iter f k (f x)

/-- The Collatz map: `T(n) = n/2` if `n` is even, `(3n+1)/2` if `n` is odd. -/
def T (n : Nat) : Nat := if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

/-- Binary length `ℓ = ⌊log₂ n⌋ + 1` (Definition 1.1). -/
def len (n : Nat) : Nat := Nat.log2 n + 1

/-- The jump function `jp(n) = T^(ℓ)(n)` (Definition 1.1). -/
def jp (n : Nat) : Nat := iter T (len n) n

/-- `ft(n) ≤ b`: some `k` with `1 ≤ k ≤ b` has `jp^(k)(n) < n` (Definition 1.5:
`ft(n)` is the least `k ≥ 1` with `jp^(k)(n) < n`). -/
def FtLE (n b : Nat) : Prop := ∃ k, 1 ≤ k ∧ k ≤ b ∧ iter jp k n < n

/-- Conjecture 5.1: "We have ft(n) ≤ 4 for all n ≥ 2^500." -/
def Conjecture51 : Prop := ∀ n, 2 ^ 500 ≤ n → FtLE n 4

/-- Halve `n` while it is even, at most `fuel` times. -/
def oddPartAux : Nat → Nat → Nat
  | 0, n => n
  | fuel + 1, n => if n % 2 = 0 then oddPartAux fuel (n / 2) else n

/-- The largest odd factor of `n` (see `oddPart_spec`). -/
def oddPart (n : Nat) : Nat := oddPartAux n n

/-- The Syracuse map: `syr(x)` is the largest odd factor of `3x + 1` (Section 3). -/
def syr (n : Nat) : Nat := oddPart (3 * n + 1)

/-- The Syracuse jump function `sjp(n) = syr^(ℓ)(n)` (Definition 3.1). -/
def sjp (n : Nat) : Nat := iter syr (len n) n

/-- `sft(n) ≤ b` (Definition 3.3). -/
def SftLE (n b : Nat) : Prop := ∃ k, 1 ≤ k ∧ k ≤ b ∧ iter sjp k n < n

/-- Conjecture 5.2: "We have sft(n) ≤ 2 for all odd n ≥ 2^5000." -/
def Conjecture52 : Prop := ∀ n, n % 2 = 1 → 2 ^ 5000 ≤ n → SftLE n 2

/-! ## 2. Witnesses -/

/-- Counterexample to Conjecture 5.1 (511 binary digits). -/
def n₀ : Nat := 1097 * 2 ^ 500 - 1

/-- Counterexample to Conjecture 5.2 (5001 binary digits). -/
def m₀ : Nat := 2 ^ 5001 - 1 - 320 * 2 ^ 4977

/-! ## 3. Proof machinery -/

/-! ### The odd part -/

theorem oddPartAux_spec : ∀ (fuel n : Nat), 0 < n → n ≤ fuel →
    oddPartAux fuel n % 2 = 1 ∧ ∃ k, n = 2 ^ k * oddPartAux fuel n := by
  intro fuel
  induction fuel with
  | zero => intro n h0 hle; omega
  | succ fuel ih =>
    intro n h0 hle
    rw [oddPartAux]
    split
    · next heven =>
      have hpos : 0 < n / 2 := by omega
      have hle' : n / 2 ≤ fuel := by omega
      obtain ⟨hodd, k, hk⟩ := ih (n / 2) hpos hle'
      refine ⟨hodd, k + 1, ?_⟩
      have h2 : n = 2 * (n / 2) := by omega
      rw [Nat.pow_succ, Nat.mul_comm (2 ^ k) 2, Nat.mul_assoc, ← hk]
      exact h2
    · next hodd =>
      refine ⟨by omega, 0, ?_⟩
      simp

/-- `oddPart n` is odd, and `n` is a power of two times `oddPart n`. -/
theorem oddPart_spec (n : Nat) (h : 0 < n) :
    oddPart n % 2 = 1 ∧ ∃ k, n = 2 ^ k * oddPart n :=
  oddPartAux_spec n n h (Nat.le_refl n)

theorem oddPartAux_pow (r : Nat) (hr : r % 2 = 1) :
    ∀ (k fuel : Nat), k ≤ fuel → oddPartAux fuel (2 ^ k * r) = r := by
  intro k
  induction k with
  | zero =>
    intro fuel _
    have h1 : 2 ^ 0 * r = r := by simp
    rw [h1]
    cases fuel with
    | zero => rfl
    | succ fuel =>
      rw [oddPartAux, ite_eq_right (by omega)]
  | succ k ih =>
    intro fuel hle
    cases fuel with
    | zero => omega
    | succ fuel =>
      have h1 : 2 ^ (k + 1) * r = 2 * (2 ^ k * r) := by
        rw [Nat.pow_succ, Nat.mul_comm (2 ^ k) 2, Nat.mul_assoc]
      have heven : (2 * (2 ^ k * r)) % 2 = 0 := by omega
      have hdiv : (2 * (2 ^ k * r)) / 2 = 2 ^ k * r := by omega
      rw [h1, oddPartAux, ite_eq_left heven, hdiv]
      exact ih fuel (by omega)

/-- If `n = 2^v * r` with `r` odd, then `oddPart n = r`. -/
theorem oddPart_of_decomp (n v r : Nat) (hodd : r % 2 = 1) (hn : 2 ^ v * r = n) :
    oddPart n = r := by
  subst hn
  have h1 : v < 2 ^ v := Nat.lt_two_pow_self
  have h2 : 2 ^ v ≤ 2 ^ v * r := Nat.le_mul_of_pos_right _ (by omega)
  exact oddPartAux_pow r hodd v _ (by omega)

/-- On `x ≡ 3 (mod 4)` the Syracuse map is `x ↦ (3x + 1)/2`. -/
theorem syr_of_mod4 (x : Nat) (h : x % 4 = 3) : syr x = (3 * x + 1) / 2 := by
  have h2 : 2 ^ 1 * ((3 * x + 1) / 2) = 3 * x + 1 := by
    rw [Nat.pow_one]; omega
  exact oddPart_of_decomp (3 * x + 1) 1 ((3 * x + 1) / 2) (by omega) h2

/-! ### Iteration -/

theorem iter_add (f : Nat → Nat) : ∀ (a b x : Nat), iter f (a + b) x = iter f b (iter f a x) := by
  intro a
  induction a with
  | zero => intro b x; rw [Nat.zero_add]; rfl
  | succ a ih =>
    intro b x
    have h : a + 1 + b = (a + b) + 1 := by omega
    rw [h]
    exact ih b (f x)

/-- A long rise in closed form: `syr^j (2^j * 4a - 1) = 3^j * 4a - 1`. -/
theorem iter_syr_rise : ∀ (j a : Nat), 0 < a →
    iter syr j (2 ^ j * (4 * a) - 1) = 3 ^ j * (4 * a) - 1 := by
  intro j
  induction j with
  | zero => intro a _; simp [iter]
  | succ j ih =>
    intro a ha
    have hw : 0 < 2 ^ j * a := Nat.mul_pos (Nat.two_pow_pos j) ha
    have e1 : 2 ^ (j + 1) * (4 * a) = 8 * (2 ^ j * a) := by
      rw [Nat.pow_succ]
      show 2 ^ j * 2 * (4 * a) = (2 * 4) * (2 ^ j * a)
      ac_rfl
    have e2 : 2 ^ j * (4 * (3 * a)) = 12 * (2 ^ j * a) := by
      show 2 ^ j * (4 * (3 * a)) = (4 * 3) * (2 ^ j * a)
      ac_rfl
    have e3 : 3 ^ (j + 1) * (4 * a) = 3 ^ j * (4 * (3 * a)) := by
      rw [Nat.pow_succ]
      ac_rfl
    show iter syr j (syr (2 ^ (j + 1) * (4 * a) - 1)) = 3 ^ (j + 1) * (4 * a) - 1
    rw [e1]
    have hx : (8 * (2 ^ j * a) - 1) % 4 = 3 := by omega
    have e4 : (3 * (8 * (2 ^ j * a) - 1) + 1) / 2 = 2 ^ j * (4 * (3 * a)) - 1 := by
      rw [e2]; omega
    rw [syr_of_mod4 _ hx, e4, ih (3 * a) (by omega), e3]

/-- A copy of `iter` that forces each value before the next step, so that kernel
evaluation does not build a tower of unevaluated applications. -/
def iterS (f : Nat → Nat) : Nat → Nat → Nat
  | 0, x => x
  | k + 1, x =>
    match f x with
    | 0 => iterS f k 0
    | y + 1 => iterS f k (y + 1)

theorem iterS_eq (f : Nat → Nat) : ∀ (k x : Nat), iterS f k x = iter f k x := by
  intro k
  induction k with
  | zero => intro x; rfl
  | succ k ih =>
    intro x
    rw [iterS, iter]
    cases f x with
    | zero => exact ih 0
    | succ y => exact ih (y + 1)

def jpS (n : Nat) : Nat := iterS T (len n) n
def sjpS (n : Nat) : Nat := iterS syr (len n) n

theorem jpS_eq (n : Nat) : jpS n = jp n := iterS_eq T (len n) n
theorem sjpS_eq (n : Nat) : sjpS n = sjp n := iterS_eq syr (len n) n

theorem iter_one (f : Nat → Nat) (x : Nat) : iter f 1 x = f x := rfl
theorem iter_two (f : Nat → Nat) (x : Nat) : iter f 2 x = f (f x) := rfl
theorem iter_three (f : Nat → Nat) (x : Nat) : iter f 3 x = f (f (f x)) := rfl
theorem iter_four (f : Nat → Nat) (x : Nat) : iter f 4 x = f (f (f (f x))) := rfl
theorem iter_five (f : Nat → Nat) (x : Nat) : iter f 5 x = f (f (f (f (f x)))) := rfl

/-! ### Falling times in terms of nested jumps -/

theorem ftLE_four_iff (n : Nat) :
    FtLE n 4 ↔ (jp n < n ∨ jp (jp n) < n ∨ jp (jp (jp n)) < n ∨ jp (jp (jp (jp n))) < n) := by
  constructor
  · rintro ⟨k, hk1, hk4, hlt⟩
    have hk : k = 1 ∨ k = 2 ∨ k = 3 ∨ k = 4 := by omega
    rcases hk with rfl | rfl | rfl | rfl
    · rw [iter_one] at hlt; exact Or.inl hlt
    · rw [iter_two] at hlt; exact Or.inr (Or.inl hlt)
    · rw [iter_three] at hlt; exact Or.inr (Or.inr (Or.inl hlt))
    · rw [iter_four] at hlt; exact Or.inr (Or.inr (Or.inr hlt))
  · rintro (h | h | h | h)
    · exact ⟨1, by omega, by omega, by rw [iter_one]; exact h⟩
    · exact ⟨2, by omega, by omega, by rw [iter_two]; exact h⟩
    · exact ⟨3, by omega, by omega, by rw [iter_three]; exact h⟩
    · exact ⟨4, by omega, by omega, by rw [iter_four]; exact h⟩

theorem ftLE_five_of (n : Nat) (h : jp (jp (jp (jp (jp n)))) < n) : FtLE n 5 :=
  ⟨5, by omega, by omega, by rw [iter_five]; exact h⟩

theorem sftLE_two_iff (n : Nat) : SftLE n 2 ↔ (sjp n < n ∨ sjp (sjp n) < n) := by
  constructor
  · rintro ⟨k, hk1, hk2, hlt⟩
    have hk : k = 1 ∨ k = 2 := by omega
    rcases hk with rfl | rfl
    · rw [iter_one] at hlt; exact Or.inl hlt
    · rw [iter_two] at hlt; exact Or.inr hlt
  · rintro (h | h)
    · exact ⟨1, by omega, by omega, by rw [iter_one]; exact h⟩
    · exact ⟨2, by omega, by omega, by rw [iter_two]; exact h⟩

theorem sftLE_three_of (n : Nat) (h : sjp (sjp (sjp n)) < n) : SftLE n 3 :=
  ⟨3, by omega, by omega, by rw [iter_three]; exact h⟩

/-! ## 4. Results -/

/-! ### Conjecture 5.1 -/

/-- `n₀ ≥ 2^500`, and `n₀` has 511 binary digits. -/
theorem n₀_size : 2 ^ 500 ≤ n₀ ∧ len n₀ = 511 := by decide +kernel

/-- `ft(n₀) > 4`. -/
theorem not_ftLE_n₀ : ¬ FtLE n₀ 4 := by
  rw [ftLE_four_iff]
  simp only [← jpS_eq]
  decide +kernel

/-- `ft(n₀) ≤ 5`, so `ft(n₀) = 5`. -/
theorem ftLE_n₀ : FtLE n₀ 5 := by
  apply ftLE_five_of
  simp only [← jpS_eq]
  decide +kernel

/-- **Conjecture 5.1 is false.** -/
theorem not_conjecture51 : ¬ Conjecture51 :=
  fun h => not_ftLE_n₀ (h n₀ n₀_size.1)

/-! ### Conjecture 5.2 -/

/-- `m₀` is odd, `m₀ ≥ 2^5000`, and `m₀` has 5001 binary digits. -/
theorem m₀_size : m₀ % 2 = 1 ∧ 2 ^ 5000 ≤ m₀ ∧ len m₀ = 5001 := by decide +kernel

/-- The first Syracuse jump of `m₀`. Since `m₀ + 1 = 2^4983 * 262139`, the first 4981 steps
are a rise with a closed form (`iter_syr_rise`); the last 20 steps are evaluated. -/
def w₁ : Nat := iterS syr 20 (3 ^ 4981 * (4 * 262139) - 1)

theorem sjp_m₀ : sjp m₀ = w₁ := by
  have hm : m₀ = 2 ^ 4981 * (4 * 262139) - 1 := by decide +kernel
  unfold sjp
  rw [m₀_size.2.2]
  show iter syr (4981 + 20) m₀ = w₁
  rw [iter_add, hm, iter_syr_rise 4981 262139 (by omega), ← iterS_eq]
  rfl

/-- `sft(m₀) > 2`. -/
theorem not_sftLE_m₀ : ¬ SftLE m₀ 2 := by
  rw [sftLE_two_iff, sjp_m₀, ← sjpS_eq w₁]
  decide +kernel

/-- `sft(m₀) ≤ 3`, so `sft(m₀) = 3`. -/
theorem sftLE_m₀ : SftLE m₀ 3 := by
  apply sftLE_three_of
  rw [sjp_m₀, ← sjpS_eq w₁, ← sjpS_eq (sjpS w₁)]
  decide +kernel

/-- **Conjecture 5.2 is false.** -/
theorem not_conjecture52 : ¬ Conjecture52 :=
  fun h => not_sftLE_m₀ (h m₀ m₀_size.1 m₀_size.2.1)

/-! ### Binary lengths after each jump (the figures quoted in the note) -/

theorem lens_n₀ : len (jp n₀) = 800 ∧ len (jp (jp n₀)) = 647 ∧ len (jp (jp (jp n₀))) = 567
    ∧ len (jp (jp (jp (jp n₀)))) = 517 ∧ len (jp (jp (jp (jp (jp n₀))))) = 425 := by
  simp only [← jpS_eq]
  decide +kernel

theorem lens_m₀ : len (sjp m₀) = 7912 ∧ len (sjp (sjp m₀)) = 5038
    ∧ len (sjp (sjp (sjp m₀))) = 3152 := by
  rw [sjp_m₀, ← sjpS_eq w₁, ← sjpS_eq (sjpS w₁)]
  decide +kernel

/-! ## 5. Anchor: a value stated in the paper, recomputed with the definitions above -/

/-- The paper reports `ft(2^132 - 1) = 5`. -/
theorem anchor_ft : ¬ FtLE (2 ^ 132 - 1) 4 ∧ FtLE (2 ^ 132 - 1) 5 := by
  refine ⟨?_, ?_⟩
  · rw [ftLE_four_iff]; simp only [← jpS_eq]; decide +kernel
  · apply ftLE_five_of; simp only [← jpS_eq]; decide +kernel

end EFS

#print axioms EFS.not_conjecture51
#print axioms EFS.not_conjecture52
#print axioms EFS.ftLE_n₀
#print axioms EFS.sftLE_m₀
#print axioms EFS.lens_n₀
#print axioms EFS.lens_m₀
#print axioms EFS.anchor_ft
#print axioms EFS.oddPart_spec
