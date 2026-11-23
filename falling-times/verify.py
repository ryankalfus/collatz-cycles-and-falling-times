"""Counterexamples to Conjectures 5.1 and 5.2 of
S. Eliahou, J. Fromentin, R. Simonetto,
"Is the Syracuse falling time bounded by 12?", arXiv:2107.11160v4.

Run:  python3 verify.py      (standard library only, about one second)

Definitions as in the paper:
  T(n)   = n/2 if n is even, (3n+1)/2 if n is odd
  l(n)   = number of binary digits of n
  jp(n)  = T applied l(n) times                     (Definition 1.1)
  ft(n)  = least k >= 1 with jp^(k)(n) < n          (Definition 1.5)
  syr(x) = (3x+1)/2^v, 2^v the largest power of 2 dividing 3x+1
  sjp(n) = syr applied l(n) times                   (Definition 3.1)
  sft(n) = least k >= 1 with sjp^(k)(n) < n         (Definition 3.3)
"""


def T(n):
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def syr(x):
    m = 3 * x + 1
    while m % 2 == 0:
        m //= 2
    return m


def jump(n, step):
    for _ in range(n.bit_length()):
        n = step(n)
    return n


def falling_time(n, step):
    """Returns (falling time, binary lengths after each jump)."""
    x, lengths = n, []
    while True:
        x = jump(x, step)
        lengths.append(x.bit_length())
        if x < n:
            return len(lengths), lengths


if __name__ == "__main__":
    n = 1097 * 2**500 - 1
    assert n >= 2**500
    print("Conjecture 5.1 says ft(n) <= 4 for all n >= 2^500.")
    print("  n = 1097 * 2^500 - 1:  (ft, lengths) =", falling_time(n, T))

    m = 2**5001 - 1 - 320 * 2**4977
    assert m % 2 == 1 and m >= 2**5000 and m == 262139 * 2**4983 - 1
    print("Conjecture 5.2 says sft(n) <= 2 for all odd n >= 2^5000.")
    print("  n = 2^5001 - 1 - 320 * 2^4977:  (sft, lengths) =", falling_time(m, syr))

    print("Sanity check against the paper: ft(2^132 - 1) =",
          falling_time(2**132 - 1, T)[0], "(the paper states 5)")
