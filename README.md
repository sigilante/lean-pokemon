# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis is that it is not: the game has no token generation, and a
Pokémon whose damage reaches its HP is Knocked Out, so no usable unbounded store exists.

Status: early. The model covers a core of the rules: state; an effect language of thirteen
primitives, including the five Special Conditions, a cure, and Croagunk's stacking Poison
("This effect can be applied more than once"); a move relation in which an Asleep or
Paralyzed Pokémon can neither attack nor retreat and a Confused Pokémon's attack can fail
(tails: no attack, and 3 damage counters on itself); and Pokémon Checkup between turns
(Poison, Burn, Sleep, Paralysis, then Knock Outs). For that model it proves:

* play permutes the cards in the game (`Reach.perm`);
* from a well-formed start (`WellFormed`: both players have Prizes while there is no winner;
  Benched Pokémon are below HP with no Special Condition), no reachable state without a winner
  is stuck (`Reach.progress`), and if a Knock Out is pending (as after Checkup), a move that
  Knocks Out an Active Pokémon and takes a Prize card is legal (`Reach.knockOut_of_pending`);
* the reachable states are finite up to a clamp (`Reach.finite`, from a well-formed start
  with no pending Knock Out): cap at the Pokémon's HP the damage on the opponent's Active
  Pokémon, the damage on the player's own Active Pokémon between turns, and the Poison
  strength on both Active Pokémon, and the clamps of all reachable states lie in one finite
  list. The clamp is a bisimulation (`Reach.clamp_sim`), so these excesses cannot be observed
  by play.

The unclamped reachable state space is infinite (`Infinite.not_finite`): from a well-formed
start with no pending Knock Out, one Item that Poisons the opponent's Active Pokémon and then
raises its Poison strength any number of times reaches infinitely many states, none with a
pending Knock Out (`Reach.infinite_damageBounded`; so the earlier finiteness statement without
the clamp is false). One effect can also place arbitrarily many damage counters before the
Knock Out is taken (`counters_unbounded`). Checkup can leave a Pokémon at or above its HP when
the turn passes, in play reached from a well-formed start
(`Infinite.endTurn_pending_ko_reachable`); the Knock Out is taken between turns, before the
next draw (`Move.damageBounded_of_startTurn`). The finite list is not computed, depends on the
start state, and gives no size bound; decidability of reachability follows in principle but is
not formalized. These are theorems about the model, not yet about the printed game: they cover
only decks whose card text is expressible in `Pokemon.Effect`, and the model's departures from
the rulebook are listed at the top of `Pokemon/Rules.lean`.

Build: `lake build` (core Lean only, no dependencies). `Pokemon/Audit.lean` runs
`#audit_namespace Pokemon` (defined in `Pokemon/AuditCmd.lean`), which checks every theorem
declared in the project, private and generated ones included, and fails the build if any
depends on an axiom other than `propext` and `Quot.sound` (so `sorry` fails it too) or if a
file under `Pokemon/` is not imported. `scripts/audit.sh build.log` then fails CI unless the
log shows the gate's success line and no error or `sorry`.

Licence: MIT (see `LICENSE`).
