# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis is that it is not: the game has no token generation, and
damage is capped by HP, so the reachable state space is finite.

Status: early. `master` holds a core model (state, a small effect language, a move relation)
and proves that legal play conserves the number of cards. Finiteness is not yet proved. The
model's departures from the rulebook are listed at the top of `Pokemon/Rules.lean`; theorems
speak only about decks whose card text is expressible in `Pokemon.Effect`.

Build: `lake build` (core Lean only, no dependencies). `Pokemon/Audit.lean` prints the axioms
of every theorem; CI fails unless they are a subset of `propext`, `Quot.sound`.

Licence: MIT (see `LICENSE`).
