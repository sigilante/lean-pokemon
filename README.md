# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis for the printed game is that it is not: the game has no token
generation, and a Pokémon whose damage reaches its HP is Knocked Out, and the survey of the
English card pool (S3) found no unbounded store that play can both write and read. The model
generalises some card text beyond what printed cards do (for instance, lingering damage
modifiers add up without limit); with those generalisations the model does have unbounded
stores, and the finiteness results below need a hypothesis on the deck that excludes them.

Status: early. The model covers a core of the rules: state; an effect language (`Pokemon.Effect`, 23 constructors) of nineteen
primitive effects (`skip` included) and four combinators (`ite`, `seq`, `choice`, `iter`), including the five
Special Conditions, a cure, Croagunk's stacking Poison ("This effect can be applied more than
once"), markers (Imprison, Shock-wave, Lightning Rod and Char as flags, the Coloring counter as a
type; placed on any Pokémon in play, removed from all of a player's Pokémon, Char damaging its
Active Pokémon at Checkup), lingering modifiers (per player, for this turn, the next turn, the
turn after, or the rest of the game, shifted at the end of every turn: a damage bonus, a damage
reduction, damage prevention, and locks on attacking, retreating and playing Items; bonuses and
reductions add up without limit; attack damage is done by `damage`, which applies them, and
`drain` heals by the damage done), and effects that read the state: a test on either
Active Pokémon (at least `n` damage counters, exactly `n`, a Special Condition, a marker, a
type), placing `k`
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
* **finiteness, for tame decks** (`Reach.finite`): let the clamp cap at the Pokémon's HP the
  damage and the Poison strength on both Active Pokémon, and cap every damage bonus and
  reduction at `bound` (a constant computed from the cards: more than every printed HP and every
  test constant). From a well-formed start whose cards are *tame* (no damage reduction, no
  `drain`) and with no reduction in effect (`GameState.Fit` at `bound`, which
  `GameState.fit_bound` gives), the clamps of all reachable states lie in one finite list, and
  the kernel of the clamp is a bisimulation for moves along reachable states (`Move.clamp_sim`,
  `Reach.clamp_sim`), so the excesses the clamp removes cannot be observed by play. This holds
  with the Trainer timing above. The list half alone (`Reach.clamp_mem`) holds from every
  well-formed start, but without tameness it says nothing about play: for decks that are not
  tame the clamp is not a simulation, for any cap `k ≥ 3` with a damage reduction
  (`Lingering.reduce_breaks_clamp`) and any cap `k ≥ 2` with `drain`
  (`Lingering.drain_breaks_clamp`); with rest-of-game modifiers, a reduction on one player and a
  bonus on the other are two persistent unbounded counters with an exact zero test, so no
  finiteness result is claimed for such decks.

Markers alone did not change the statements: they are finitely many flags per Pokémon, not
clamped, and enumerated by the list of `Reach.clamp_mem`. Printed Imprison and Shock-wave markers are uncapped counts; a flag
is exact for them because the cards only place one, remove all, and test for any
(`Markers.flag_exact`), and this is a stated assumption about the card pool.

Lingering modifiers change the statements: the clamp takes a cap `k`, and the bisimulation needs
a hypothesis on the deck (tameness, `GameState.Fit`). An unbounded damage bonus can be capped because it is read only through
the damage it adds to the opponent's Active Pokémon, which is read only by tests against card
constants and by the Knock Out test at HP; a bonus of `bound` or more acts as `bound` does. A
damage reduction breaks this: damage done is `n + bonus - reduction`, and a bonus above any cap
matters when an equally large reduction offsets it (`Lingering.reduce_breaks_clamp`, for every
cap `k ≥ 3`). So does `drain` after in-attack
self-damage, which reads the bonus exactly through the heal (`Lingering.drain_breaks_clamp`, for
every `k ≥ 2`). Expiry follows the turn structure:
`endTurn` shifts both stores, and `Store.add_now_shift` .. `Store.add_always_shift` state when
each kind of modifier is in effect. Printed bonuses and reductions are bounded by copies of their
cards times printed constants, and rest-of-game ones come only from once-per-game attacks
(survey S7), so the printed game does not reach the unbounded case; the model over-approximates
them on purpose, and the finiteness theorem covers only the tame decks.

For tame decks, effects that read damage do not break finiteness, but they change why it holds. Inside an
attack's effect the clamp is not a simulation: a test against 6 counters separates 5 from 6
counters on a 5-HP Pokémon (`Reads.run_clamp_not_sim`). Attack effects are instead simulated
with the player's own damage exact and the opponent's capped at `bound` (`Run.cap_sim`), and
every move that resolves an effect starts from a state with no Pokémon at or above its HP,
where equal clamps mean equal damage. Inside a Trainer effect the clamp is a simulation
(`TRun.clamp_sim`), since every step of it starts in such a state. The damage cap at move
boundaries stays at HP. The
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
computed, depends on the start state, and gives no size bound. For tame decks, the finite
quotient with the same moves (`Reach.finite`) means that reachability questions that depend only
on the clamp could be decided by exploring it, given a computable successor function for the
quotient; neither that function nor the decision procedure is formalized. For decks that are not
tame nothing of the kind is proved, and none is expected (see above). These are theorems about the model, not yet about
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
