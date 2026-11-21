# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis is that it is not: the game has no token generation, and a
Pokémon whose damage reaches its HP is Knocked Out, so no usable unbounded store exists.

Status: early. The model covers a core of the rules: state; an effect language of seventeen
primitives, including the five Special Conditions, a cure, Croagunk's stacking Poison ("This
effect can be applied more than once"), and effects that read the state: a test on either
Active Pokémon (at least `n` damage counters, exactly `n`, a Special Condition), placing `k`
counters on the opponent's Active Pokémon for each damage counter on either Active Pokémon
(Lunala's doubling is the case `k = 1` on the opponent's), damage to the player's own Active
Pokémon, and healing all of its damage; a move relation in which an Asleep or Paralyzed
Pokémon can neither attack nor retreat and a Confused Pokémon's attack can fail (tails: no
attack, and 3 damage counters on itself); the rulebook's Knock Out timing: once a move
leaves a Pokémon at or above its HP, it must be Knocked Out and replaced before any other
move (`Settled`); inside an attack's effect damage may exceed HP and be read, and the Knock
Out comes after the attack; inside an Item or Supporter card's effect (`TRun`) every Knock
Out is taken at once after the step that causes it (a Prize card, which may win the game;
promotion of a Benched Pokémon; or a loss), the rest of the effect acts on the new board,
and a finished game stops the effect; and Pokémon Checkup between turns (Poison, Burn,
Sleep, Paralysis, then Knock Outs). For that model it proves:

* play permutes the cards in the game (`Reach.perm`), Knock Outs inside Trainer effects
  included (`TRun.perm`);
* Knock Out timing inside Trainer effects (`TRun.guarded`, `TRun.iff_guarded`): from a
  `Settled` state, as every Item and Supporter starts, every primitive step and every test of
  the effect starts in a `Settled` state, so no step runs while a Pokémon is at or above its
  HP; the effect ends `Settled` or with the game over (`TRun.settled_or_won`), and a finished
  game resolves nothing more (`TRun.of_won`). Single legal moves from well-formed starts
  witness behaviours the earlier model lacked: an Item `seq (selfDamage 5)
  (heal 5)` Knocks Out its player's 50-HP Active Pokémon after the first step
  (`Trainer.selfKO_reachable`); an Item `iter (counters 5)`, read as "as often as you like,
  put 5 damage counters on the opponent's Active Pokémon", Knocks Out the opponent's Active
  Pokémon, the opponent promotes, and the next round hits the new Active Pokémon
  (`Trainer.koThenHit_reachable`; read instead as "flip until tails, 5 counters per heads",
  this outcome is a consequence of the model's check between primitives, not rulebook
  behaviour, since the printed card places all its counters at once); an Item takes the last Prize card in mid-effect and the
  rest of it is not resolved (`Trainer.winMidEffect_reachable`);
* from a well-formed start (`WellFormed`: both players have Prizes while there is no winner;
  Benched Pokémon are below HP with no Special Condition), no reachable state without a winner
  is stuck (`Reach.progress`), and if a Knock Out is pending, a move that Knocks Out an Active
  Pokémon and takes a Prize card is legal (`Reach.knockOut_of_pending`); a move never changes
  an Active Pokémon at or above its HP except by Knocking it Out (`Move.pending_untouched`);
* the reachable states are finite up to a clamp (`Reach.finite`, from a well-formed start):
  cap at the Pokémon's HP the damage and the Poison strength on both Active Pokémon, and the
  clamps of all reachable states lie in one finite list. The clamp is a bisimulation for moves
  (`Move.clamp_sim`, `Reach.clamp_sim`), so these excesses cannot be observed by play. Both hold
  with the Trainer timing above.

Effects that read damage do not break finiteness, but they change why it holds. Inside an
attack's effect the clamp is not a simulation: a test against 6 counters separates 5 from 6
counters on a 5-HP Pokémon (`Reads.run_clamp_not_sim`). Attack effects are instead simulated
with damage exact (`Run.exact_sim`), and every move that resolves an effect starts from a
state with no Pokémon at or above its HP, where equal clamps mean equal damage. Inside a
Trainer effect the clamp is a simulation (`TRun.clamp_sim`), since every step of it starts in
such a state. The cap stays at HP; no larger cap computed from the cards is needed. The
earlier bound on the player's own Active Pokémon during a turn (at most `maxHp + 3` counters)
is false once an attack's effect can damage it (`Reads.activeLe_false`) and is no longer used.

The unclamped reachable state space is infinite (`Infinite.not_finite`): from a well-formed
start with no pending Knock Out, one Item that Poisons the opponent's Active Pokémon and then
raises its Poison strength any number of times reaches infinitely many states, none with a
pending Knock Out (`Reach.infinite_damageBounded`). One attack's effect can also place
arbitrarily many damage counters before the Knock Out is taken (`counters_unbounded`). Checkup
can leave a Pokémon at or above its HP when the turn passes, in play reached from a
well-formed start (`Infinite.endTurn_pending_ko_reachable`); the Knock Out is taken between
turns, before the next draw (`Move.damageBounded_of_startTurn`). The finite list is not
computed, depends on the start state, and gives no size bound; decidability of reachability
follows in principle but is not formalized. These are theorems about the model, not yet about
the printed game: they cover only decks whose card text is expressible in `Pokemon.Effect`,
and the model's departures from the rulebook are listed at the top of `Pokemon/Rules.lean`.
For Knock Out timing inside Trainer effects the remaining simplifications are these: Knock
Outs are checked after each primitive of the model's effect language (a printed sentence
written as several primitives gets a check between them); the replacement is promoted at once,
before the next step (no ruling on its timing was found); the Prize card is the top one; and
an effect that damages several Pokémon at once is not expressible, so the order of
simultaneous Knock Outs does not arise inside a Trainer effect. Up to these, the model's
Trainer timing is the rulebook's (an earlier version resolved a Trainer effect as a whole and
could read and heal damage above HP; that defect is gone). Two of these simplifications can
still lose printed outcomes, so transfer to the printed game by inclusion needs them as named
caveats: where a printed sentence is atomic but is written as several primitives, the check
between them removes the outcome in which the whole sentence acts on the original Pokémon
(e.g. `seq (counters 5) (scale opp 1)` against a 5-HP Active always doubles the promoted
Pokémon's damage); and immediate promotion removes outcomes in which later steps find an
empty Active Spot. Neither makes finiteness easier: the atomic reading is the attack case,
and deferred promotion is a finite-branching variant. The other listed departures remain.

Build: `lake build` (core Lean only, no dependencies). `Pokemon/Audit.lean` runs
`#audit_namespace Pokemon` (defined in `Pokemon/AuditCmd.lean`), which checks every theorem
declared in the project, private and generated ones included, and fails the build if any
depends on an axiom other than `propext` and `Quot.sound` (so `sorry` fails it too) or if a
file under `Pokemon/` is not imported. `scripts/audit.sh build.log` then fails CI unless the
log shows the gate's success line and no error or `sorry`.

Licence: MIT (see `LICENSE`).
