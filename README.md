# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis is that it is not: the game has no token generation, and a
Pokémon whose damage reaches its HP is Knocked Out, so no usable unbounded store exists.

Status: early. The model covers a core of the rules: state; an effect language of thirteen
primitives, including the five Special Conditions, a cure, and Croagunk's stacking Poison
("This effect can be applied more than once"); a move relation with Confusion, Sleep and
Paralysis blocking play; and Pokémon Checkup between turns (Poison, Burn, Sleep, Paralysis,
then Knock Outs). For that model it proves:

* play permutes the cards in the game (`Reach.perm`);
* from a well-formed start (`WellFormed`: both players have Prizes while there is no winner;
  Benched Pokémon are below HP with no Special Condition), no reachable state without a winner
  is stuck (`Reach.progress`); in particular the Knock Outs that Checkup causes can always be
  taken;
* the reachable states are finite up to a clamp (`Reach.finite`, from a well-formed start
  with no pending Knock Out): cap at the Pokémon's HP the damage on the opponent's Active
  Pokémon, the damage on the player's own Active Pokémon between turns, and the Poison
  strength on both Active Pokémon, and the clamps of all reachable states lie in one finite
  list. The clamp is a bisimulation (`Reach.clamp_sim`), so these excesses cannot be observed
  by play.

The unclamped state space is infinite: one effect can place arbitrarily many damage counters
before the Knock Out is taken, or raise Poison strength arbitrarily high. Checkup can leave a
Pokémon at or above its HP when the turn passes (`Move.endTurn_pending_ko`); the Knock Out is
taken between turns, before the next draw (`Move.damageBounded_of_startTurn`). The finite list
is not computed, depends on the start state, and gives no size bound; decidability of
reachability follows in principle but is not formalized. These are theorems about the model,
not yet about the printed game: they cover only decks whose card text is expressible in
`Pokemon.Effect`, and the model's departures from the rulebook are listed at the top of
`Pokemon/Rules.lean`.

Build: `lake build` (core Lean only, no dependencies). `Pokemon/Audit.lean` runs
`#audit_namespace Pokemon` (defined in `Pokemon/AuditCmd.lean`), which checks every theorem
declared in the project, private and generated ones included, and fails the build if any
depends on an axiom other than `propext` and `Quot.sound` (so `sorry` fails it too) or if a
file under `Pokemon/` is not imported. `scripts/audit.sh build.log` then fails CI unless the
log shows the gate's success line and no error or `sorry`.

Licence: MIT (see `LICENSE`).
