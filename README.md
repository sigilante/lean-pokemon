# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis is that it is not: the game has no token generation, and a
Pokémon whose damage reaches its HP is Knocked Out, so no usable unbounded store exists.

Status: early. The model covers a core of the rules (state, a ten-primitive effect language,
a move relation). For that model, and for any start state with no pending Knock Out, it proves:

* play permutes the cards in the game (`Reach.perm`);
* the reachable states are finite up to a clamp (`Reach.finite`): cap the damage on the
  opponent's Active Pokémon at its HP, and the clamps of all reachable states lie in one
  finite list. The clamp is a bisimulation (`Reach.clamp_sim`), so damage above HP cannot be
  observed by play.

The unclamped state space is infinite: one effect can place arbitrarily many damage counters
before the Knock Out is taken. The finite list is not computed, depends on the start state,
and gives no size bound; decidability of reachability follows in principle but is not
formalized. These are theorems about the model, not yet about the printed game: they cover
only decks whose card text is expressible in `Pokemon.Effect`, and the model's departures
from the rulebook are listed at the top of `Pokemon/Rules.lean`.

Build: `lake build` (core Lean only, no dependencies). `Pokemon/Audit.lean` prints the axioms
of every theorem; CI fails unless they are a subset of `propext`, `Quot.sound`.

Licence: MIT (see `LICENSE`).
