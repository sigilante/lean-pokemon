# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis for the printed game is that it is not: the game has no token
generation, and a Pokémon whose damage reaches its HP is Knocked Out, and the survey of the
English card pool (S3) found no unbounded store that play can both write and read. The model
generalises some card text beyond what printed cards do (for instance, lingering damage
modifiers add up without limit); with those generalisations the model does have unbounded
stores, and the finiteness results below need a hypothesis on the deck: tame decks
(`Reach.finite`) or faithful decks (`Faithful.xfinite`); neither class contains the other.

Status: early. The model covers a core of the rules: state; an effect language (`Pokemon.Effect`, 23 constructors) of nineteen
primitive effects (`skip` included) and four combinators (`ite`, `seq`, `choice`, `iter`), including the five
Special Conditions, a cure, Croagunk's stacking Poison ("This effect can be applied more than
once"), markers (Imprison, Shock-wave, Lightning Rod and Char as flags, the Coloring counter as a
type; placed on any Pokémon in play, removed from all of a player's Pokémon, Char damaging its
Active Pokémon at Checkup), lingering modifiers (per player, for this turn, the next turn, the
turn after, or the rest of the game, shifted at the end of every turn: a damage bonus, a damage
reduction, damage prevention, and locks on attacking, retreating and playing Items; bonuses and
reductions add up without limit, and enter the damage calculation described below), and effects
that read the state: a test on either
Active Pokémon (at least `n` damage counters, exactly `n`, a Special Condition, a marker, a
type), placing `k`
counters on the opponent's Active Pokémon for each damage counter on either Active Pokémon
(Lunala's doubling is the case `k = 1` on the opponent's), damage to the player's own Active
Pokémon, and healing all of its damage; a move relation in which an Asleep or Paralyzed
Pokémon can neither attack nor retreat and a Confused Pokémon's attack can fail (tails: no
attack, and 3 damage counters on itself); the rulebook's turn (milestone M1): an attack, or a
failed Confused attempt, ends the turn, so only its Knock Outs and the end of the turn follow
(`Move.after_attack`); the starting player cannot attack or play a Supporter on the first turn
of the game, and neither player can evolve on their own first turn (`PlayerState.hadTurn`) or
evolve a Pokémon put into play or evolved that turn (these bans assume a start state whose
turn flags are consistent, `GameState.FlagsOk`, which the model does not require of a start
state but which play preserves, `Reach.flagsOk`; the bans on the first turn of the game are theorems under it (the second player's
evolution ban on their own first turn is a premise of the move, not a theorem),
`Move.firstTurn_no_attack` and the like; after an attack a move either takes Knock Outs or
gives exactly the state that ending the turn gives, `Move.after_attack_passTurn`); one Energy attachment, one Supporter and
one retreat per turn; a new Poison replaces the old one, resetting its strength; Basic Energy
cards of the nine Basic types; typed attack costs, each typed symbol paid by Energy of its type
and each Colorless symbol by any Energy (`Pays`, a matching, decided by `payable`);
Weakness ×2 and Resistance −N on the Defending (Active) Pokémon; and the rulebook's damage
calculation, made once per attack (`dealtBy`: stop at base damage 0, the attacker's bonus,
Weakness, Resistance, the defender's reduction or prevention; an attack has at most one damage
step, whose amount its text may compute from the damage on either Active Pokémon, `Amt`, and
Item and Supporter effects have none); one Stadium slot shared by both players (state only: no move
plays a Stadium yet); the Knock Out timing: once a move
leaves a Pokémon at or above its HP, it must be Knocked Out and replaced before any other
move (`Settled`); inside an attack's effect damage may exceed HP and be read, and the Knock
Out comes after the attack; inside an Item or Supporter card's effect (`TRun`) every Knock
Out is taken at once after the step that causes it (a Prize card, which may win the game;
promotion of a Benched Pokémon; or a loss), the rest of the effect acts on the new board,
and a finished game stops the effect (Knock Outs after an attack and after Checkup are the
English rulebook's; the immediate Knock Outs at other times come from the Pokémon Asia
*Advanced Player's Rulebook*, and survey S9 found no English rule for them, a provenance
problem recorded in the Known gaps); and Pokémon Checkup between turns (Poison, Burn,
Sleep, Paralysis, then Knock Outs). The sources of the turn rules, and where the 2023
rulebook, the later sources and the model differ, are listed at the top of
`Pokemon/Rules.lean`. For that model it proves:

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
  reduction at `2 · bound` (`bound` is a constant computed from the cards: more than every
  printed HP, every Resistance and every test constant; the factor 2 absorbs Resistance, which is
  subtracted after the bonus, `dealtBy_cap`; Weakness, which doubles, needs no larger cap). From a well-formed start whose cards are *tame* (no damage reduction, no
  `drain`) and with no reduction in effect (`GameState.Fit` at `bound`, which
  `GameState.fit_bound` gives), the clamps of all reachable states lie in one finite list, and
  the kernel of the clamp is a bisimulation for moves along reachable states (`Move.clamp_sim`,
  `Reach.clamp_sim`), so the excesses the clamp removes cannot be observed by play. This holds
  with the Trainer timing above. The list half alone (`Reach.clamp_mem`) holds from every
  well-formed start, but without tameness it says nothing about play: for every cap `k ≥ 3`
  there is a deck with a damage reduction for which the clamp is not a simulation
  (`Lingering.reduce_breaks_clamp`), and for every cap `k ≥ 2` a deck with `drain`
  (`Lingering.drain_breaks_clamp`); with rest-of-game modifiers, a reduction on one player and a
  bonus on the other are two persistent unbounded counters with an exact zero test, and the
  model then simulates two-counter machines (next item).
* **universality, for the generalisation** (`Counter.universal`, `Pokemon/Counter.lean`):
  generalised beyond printed cards so that rest-of-game damage bonuses and reductions
  accumulate without limit and can be granted by an ordinary attack every turn, the model
  admits, for every two-counter machine `M`, a well-formed game state from which a designated
  marker is reachable under legal play by both players if and only if `M` halts; with Minsky's
  theorem, reachability in this generalised model is undecidable (the reduction is
  machine-checked, the appeal to Minsky's theorem is not), and nothing follows for the printed
  card pool. The start `start M a b` uses cards in the existing effect language; neither of its
  attacks is a GX attack, so the once-per-game GX rule (next item) does not restrict them; every configuration `M` reaches is encoded by a reachable state
  (`Counter.simulate`, whose proof uses six fixed moves per machine step), and the converse
  direction (`Counter.halts_of_haltMarked`) covers every line of play, not only the intended
  one (a player who declines to attack, or attaches the Energy, decks out at their next draw,
  and the game ends without the mark). The construction relies on: (1) rest-of-game damage
  bonuses and reductions that add up without limit and are placed by an attack used every
  turn, including an attack that grants the *opponent* a reduction (printed cards give
  rest-of-game modifiers only through once-per-game attacks, survey S7 §C); (2) `damage` read
  by a test later in the same attack, using the model's freedom to order primitives; (3) a
  printed HP that grows with the machine; (4) a halt mark placed on the player's own Pokémon,
  whereas printed markers target the opponent (this affects only the observable); (5) a
  hand-built start (an Active Pokémon and one Energy each, one Prize, no set-up), not shown
  reachable from a legal set-up, with padding to legal deck size not proved harmless; and (6)
  `ite`, `healAll`, `selfDamage`, `counters`, `mark` and `handToBottom` as general primitives
  combined in one attack. It does not rely on an attack not ending the turn (each player
  attacks once and the turn ends; re-checked under the rule that an attack ends the turn), on a
  bonus being added to base damage 0 (the zero test is the damage step `damage (const 1)`, with
  base damage 1), on attack costs being counted rather than typed (costs are typed and empty),
  on modifiers being per player rather than per Pokémon (one Pokémon each, no Bench), or on the
  absence of Weakness and Resistance (the Clock and the Tape have neither, and each attack makes
  the damage calculation at most once; re-checked under milestone M4).
  Separately, `Counter.not_finite_up_to` shows that for one witness deck the reachable states
  are not finite up to any equivalence fine enough to recover the encoded configuration. That
  is a statement about how states are represented, not about play: its machine never reads its
  counter, so the extra states differ only in a reduction nothing observes, and it is not the
  counterpart of `Reach.finite` (a finite bisimulation quotient). The behavioural counterpart
  is `Counter.universal` with Minsky's theorem (prose), which rules out a uniform computable
  finite abstraction; for any single machine a finite quotient respecting the halt question
  exists, non-constructively.

Markers alone did not change the statements: they are finitely many flags per Pokémon, not
clamped, and enumerated by the list of `Reach.clamp_mem`. Printed Imprison and Shock-wave markers are uncapped counts; a flag
is exact for them because the cards only place one, remove all, and test for any
(`Markers.flag_exact`), and this is a stated assumption about the card pool.

Lingering modifiers change the statements: the clamp takes a cap `k`, and the bisimulation needs
a hypothesis on the deck (tameness, `GameState.Fit`). An unbounded damage bonus can be capped because it is read only through
the damage it adds to the opponent's Active Pokémon, which is read only by tests against card
constants and by the Knock Out test at HP; a bonus of `2 · bound` or more acts as `2 · bound`
does (Weakness doubles the base damage plus bonus, which only raises it; Resistance, at most
`bound`, is what the factor 2 absorbs: with the stores capped at `bound` itself, a bonus of
`bound` and one of `bound + 1` against Resistance 3 do different damage below the cap,
`Calc.cap_at_k_fails`). A damage reduction breaks this: damage done by base damage `n ≥ 1` is
`n + bonus - reduction` without Weakness or Resistance,
and a bonus above any cap matters when an equally large reduction offsets it
(`Lingering.reduce_breaks_clamp`, for every cap `k ≥ 3`; its witness attack has base damage 1,
since base damage 0 does no damage). So does `drain` after in-attack
self-damage, which reads the bonus exactly through the heal (`Lingering.drain_breaks_clamp`, for
every `k ≥ 2`). Expiry follows the turn structure:
`endTurn` shifts both stores, and `Store.add_now_shift` .. `Store.add_always_shift` state when
each kind of modifier is in effect. Printed rest-of-game bonuses and reductions come only from
once-per-game attacks (survey S7), and same-turn ones are bounded by copies of their cards times
printed constants provided no card-recycling loop replays them, which is an empirical claim
about the card pool, not a theorem; on that claim the printed game does not reach the
unbounded case. A reduction carried into the opponent's turn does exist on a printed Item (Iron
Defender: "During your opponent's next turn, all of your Metal Pokémon take 30 less
damage…"), so printed decks are not all tame. The model over-approximates modifiers on purpose;
`Reach.finite` covers only the tame decks, and `Faithful.xfinite` (next paragraph) covers decks
with reductions such as Iron Defender's.

Exact stores. Both clamp counterexamples reach two states whose stores differ only above the
cap. The clamp `GameState.xclamp` (`Pokemon/Exact.lean`) caps damage and Poison strength on both
Active Pokémon at HP and keeps both stores exact, so those states are not identified. Every
reader of the stores sees equal values in two states with equal `xclamp`: the damage step
computes the same `dealtBy` (the same amount, Weakness, Resistance and stores; `drain` heals the
attacker by that amount), locks and prevention are flags in the stores, and `endTurn` shifts
equal stores; damage is read by tests, by `scale`, by the damage step's amount, by Checkup only
in states with no pending Knock Out, and by the Knock Out test at HP. Inside an attack damage is
kept exact on both Active Pokémon (every attack starts with no pending Knock Out, where `xclamp`
determines the damage; before milestone M4 the opponent's was capped, which a damage step that
reads it and `drain` that writes the amount to the attacker would break); damage done needs no
cap, however large in either direction, since it is computed from equal values. What the exact clamp gives up is boundedness of the stores, and with it
finiteness; the deck condition `Faithful` buys it back:

* **exact-store bisimulation, every deck** (`Move.xclamp_sim`, `Reach.xclamp_bisim`,
  `GameState.xclamp_bisim`): the kernel of `xclamp` is a two-way bisimulation, with no
  hypothesis on the cards; it holds for all pairs of states with equal `xclamp`, reachable or
  not (the reachability premise of `Reach.xclamp_bisim` is vacuous: take the start to be the
  state itself);
* **finiteness on bounded stores** (`Reach.xfinite_bounded`, `Pokemon/Bounded.lean`): from a
  well-formed start, for every `B` one finite list (depending only on the start and `B`)
  contains the `xclamp` of every reachable state satisfying `BoundedStores B` (every slot's
  bonus and reduction at most `B`). The bounded part is not closed under moves, so on its own
  this gives a finite set of classes and a bisimulation that may leave that set, not a finite
  quotient; the finite quotient is `Faithful.xfinite`;
* **finiteness for faithful decks** (`Faithful.xfinite`, `Pokemon/Faithful.lean`): a start is
  `Faithful` if no card's effect has a damage bonus or reduction under `iter` (`LoopFree`) and
  only GX attacks write rest-of-game bonuses or reductions (`GXOnly`). Then every reachable state
  satisfies `BoundedStores (storeBound g₀)` (`Faithful.reach_boundedStores`), where `storeBound`
  adds the start stores, the amounts of every Trainer card in the game, and three times the
  largest amount of one attack; so from a well-formed faithful start the `xclamp`s of all
  reachable states lie in one finite list, with the two-way bisimulation. The bound rests on
  three facts of the model: no card ever leaves a discard pile (no effect or move returns one),
  so each Item and Supporter is played at most once per game, with no assumption about
  recycling loops; at most one attack is made per turn; and carried amounts expire within three
  turn boundaries. Faithful decks may use damage reduction, `drain`, carried bonuses and
  reductions in attacks and Trainers (Iron Defender), and rest-of-game modifiers in GX attacks
  and in Trainer cards;
* **the rule change**: `Attack` has a field `gx`, and `Move.attack` lets a player use a GX
  attack only if they have not used one in the game, and records it (`PlayerState.gxUsed`,
  unused before); `Move.attackConfused` (a Confused Pokémon's failed attempt) has the same
  premise and does not record it (an unverified ruling, listed in the Known gaps of `Pokemon/Rules.lean`). Every earlier
  theorem was re-proved; `Counter.universal` is unchanged;
* **the dichotomy** (`Faithful.dichotomy`, `Pokemon/Dichotomy.lean`): the two-counter starts
  satisfy `LoopFree` (`Faithful.counter_loopFree`) and violate `GXOnly` whenever the machine's
  first instruction is not `halt` (`Faithful.counter_not_gxOnly`: their attacks, not GX attacks,
  write rest-of-game amounts); for `start countUp 0 0` the `xclamp`s of the reachable states lie
  in no finite list (`Faithful.xclamp_not_finite`, a statement about representation, as for
  `Counter.not_finite_up_to`). This is a sharpness result for the `GXOnly` clause, not a
  classification of decks: faithful decks are finite up to a two-way bisimulation; some decks
  that violate only `GXOnly` (the two-counter starts) simulate every two-counter machine, so
  that clause cannot be dropped from the theorem; nothing is proved about other decks that are
  not faithful, and some of them are finite (tame decks that violate `GXOnly` are covered by
  `Reach.finite`).

Which theorem applies. `Reach.finite` needs tame cards (no damage reduction, no `drain`) and no
reduction in effect at the start; it allows bonus writes under `iter` and rest-of-game bonuses
in attacks that are not GX attacks, and gives a coarser quotient (the clamp caps stored
bonuses). `Faithful.xfinite` allows damage reduction, `drain`, carried modifiers and Trainer
modifiers; it forbids amounts written under `iter` and rest-of-game amounts written by attacks
that are not GX attacks, and gives a finer quotient (the stores are kept exact). Neither class
contains the other; for decks in both, both theorems apply.

Not covered by `Faithful`, or not in the model: card recycling (returning Items from the
discard pile would replay a carried-modifier Item such as Iron Defender without bound; the
model has none, so "each Trainer once per game" is a fact about the model, not about the printed
card pool); "attack twice", "attack again" after a Knock Out, and extra turns (absent: more than
one attack's amounts per turn); rest-of-game modifiers from VSTAR Powers, Abilities or Stadiums
(absent); copy attacks, for instance copying a GX attack (absent); static modifiers and
modifiers from Pokémon Tools, Abilities or Special Energy (absent: every modifier is written by
an effect when it resolves); reductions restricted by type (printed Iron Defender protects Metal
Pokémon only, whereas the model's reduction protects all of a player's Pokémon); effects that
lock GX attacks (absent). The store bound rests on three absences in the model: no effect
returns a card from a discard pile, at most one attack is made per turn, and there are no extra
turns. Each exists on printed cards (Item- and Supporter-recycling cards; "attack twice"; "take
another turn"), so adding any of them to the model reopens the bound. The guess-and-verify
coupling of the Poet's second session (one replayable effect that writes a this-turn and a carried amount in lockstep) is excluded inside one effect by
`LoopFree`, and across effects it lacks the replays it needs: an attack writes a bounded amount
once per turn, and a Trainer card is played at most once per game. Recycling or extra attacks
would reopen it.

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
quotient; neither that function nor the decision procedure is formalized. The same holds for
faithful decks with the exact-store quotient (`Faithful.xfinite`). For the two-counter starts,
which violate `GXOnly` only, no such procedure exists uniformly: by the reduction of `Pokemon/Counter.lean` and
Minsky's theorem, reachability of the halt mark, as a problem over the family of its start
states, is undecidable in the generalised model (the reduction is proved; the appeal to
Minsky's theorem is not formalized). These are theorems about the model, not yet about
the printed game: they cover only decks whose card text is expressible in `Pokemon.Effect`,
and the model's departures from the rulebook are listed at the top of `Pokemon/Rules.lean`.
For Knock Out timing inside Trainer effects the remaining simplifications are these: Knock
Outs are checked after each primitive of the model's effect language (a printed sentence
written as several primitives gets a check between them); the replacement is promoted at once,
before the next step (no ruling on its timing was found); the Prize card is the top one; and
an effect that damages several Pokémon at once is not expressible, so the order of
simultaneous Knock Outs does not arise inside a Trainer effect. Up to these, the model's
Trainer timing is that of the Advanced Player's Rulebook (Pokémon Asia, 2025; the English
rulebook states no rule for it, see above) (an earlier version resolved a Trainer effect as a whole and
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
