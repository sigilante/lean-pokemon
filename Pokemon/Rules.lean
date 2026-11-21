import Pokemon.Effect

/-!
# Moves

`Move g g'` is one legal step of the game from the point of view of the player to move.
`Reach g₀ g` is reachability by legal play; no move is available once a winner is set.

A turn has two phases, told apart by `GameState.between`. `endTurn` applies Pokémon Checkup
to both Active Pokémon and hands the move to the opponent with `between = true`; in that
phase only Knock Outs, promotions, and the draw that starts the turn proper (`startTurn`, or
`deckOut` if the deck is empty) are legal. Checkup is the only place where damage arrives
without a player's action; the Knock Outs it causes are therefore taken before anything else
can happen, as the rulebook requires.

An attack ends the turn: "Once you attack, your turn is over" (rulebook 2023 p. 13; "3) Attack.
Then, end your turn.", p. 9). `attack` and `attackConfused` (a Confused Pokémon's failed
attempt, which is still the turn's attack) set `GameState.attacked`, and every action of the
turn proper (`playBasic`, `attach`, `evolve`, `retreat`, `item`, `supporter`, `attack`,
`attackConfused`) requires `attacked = false`; so after an attack only its Knock Outs (and
promotions, or a loss) and `endTurn` are legal, and `endTurn` resets the flag. A player who
does not attack ends the turn by `endTurn` at any point of the turn proper.

Knock Out timing. The rulebook checks for Knock Outs at the end of every attack ("check to see
if any Pokémon were Knocked Out by the attack", 2023 p. 14) and at the end of every Pokémon
Checkup ("After both players have gone through these checks", p. 15). The model also takes a
Knock Out at once whenever damage reaches HP at any other time; that third clause is not in the
English rulebook (see the Known gaps for its source). The model follows these in two ways. Between moves: every move that is not part of resolving a Knock Out
(the six moves `knockOut`, `promote`, `noPokemon` and their `Own` versions) requires the state
to be `Settled`: no Pokémon in play is at or above its HP, and both Active Spots are filled.
So once a move leaves a Pokémon at or above its HP, the next moves must Knock it Out (and
promote a replacement) before anything else happens; nothing can read, heal or otherwise use
an over-HP Pokémon between moves. Inside a move: an attack's effect is resolved as a whole by
`Run`, so damage may exceed HP and the effect can read it, and the Knock Outs come after the
attack, as the rulebook says; an Item or Supporter's effect is resolved by `TRun`, which takes
every Knock Out at once after each primitive step (`Resolve`) and stops if the game is over, so
no step of a Trainer effect runs while a Pokémon is at or above its HP (`TRun.guarded`).

Sources of the turn rules (milestone M1). The rulebook quoted is the *Scarlet & Violet—151*
rulebook (©2023, `data/mew_rulebook_en.pdf`, survey S9); survey S8 read the *Surging Sparks*
rulebook (©2024) and a Professor Program post on the rule changes of February 2026. The model
follows the latest source; for the rules below the three agree except where noted.
* An attack ends the turn (2023 pp. 9, 13; 2024 the same, S8 B13). The failed Confused attempt
  also ends the turn: the rulebook says only that "the attack doesn't happen" (p. 16); the model
  reads the Confusion check as step C of using the attack (p. 20).
* First-turn bans (2023 pp. 11–13; 2024 the same, S8 B4, B8, B14): no attack and no Supporter
  for the starting player on the first turn of the game, no evolving on either player's own
  first turn. Card text that lifts them is absent from the model.
* Damage calculation stops at base damage 0 (2023 p. 20; 2024 the same, S8 F2). Since milestone
  M4 the stop is applied once per attack, to the base damage as the attack's text computes it.
* A new Poison replaces the old one (2023 p. 16; 2024 the same, S8 G7). That Croagunk's
  stacked increase ends with the replaced Poison is the model's reading; no ruling was found.
* Nine Basic Energy types (2023 glossary p. 39; S8 D1); `BasicEnergy`.
* One Stadium in play at a time (2023 p. 12; 2024 the same, S8 B9): one shared slot, state
  only.
* Simultaneous wins: the 2023 rulebook has Sudden Death (p. 21); the 2026 post replaced it with
  tiebreaker games (S8 J4, unverified against a rulebook); the model has neither (gaps).
* Knock Outs at times other than after an attack or Checkup: in neither English rulebook; the
  model's rule comes from another source (gaps).

Sources of the damage and Energy rules (milestone M4; the 2023 and 2024 rulebooks agree word for
word on the damage steps, survey S9 against S8 F2; S8 records no later change to these rules).
* Typed attack costs (2023 p. 13, Quaxwell: "the ◉ means you need to have 1 ◉ Energy attached.
  However, the ✱ means that any type of Energy can be used"; S8 D2): `Pays`, a matching of cost
  symbols to units of attached Energy. A Retreat Cost is paid by discarding "1 Energy from your
  Active Pokémon for each ✱ listed in its Retreat Cost" (p. 12); with Basic Energy only, one
  Energy card is one unit, as `retreat` counts.
* Weakness and Resistance (2023 p. 14: "If the attack does damage, your opponent's Active
  Pokémon takes more damage if it has Weakness to the attacker's type. It takes less damage from
  a Pokémon if it has Resistance to that Pokémon's type", and "Don't apply Weakness and
  Resistance for Benched Pokémon!"; S8 E1): `PokemonCard.weakness` (×2), `resistance` (−N).
  Attack damage reaches only the opponent's Active Pokémon in the model, so the Bench rule holds
  trivially. The attacker's type is `InPlay.type` (a Coloring counter changes it).
* The damage calculation (2023 p. 20, steps 1–6, quoted in `dealtBy`; S8 F2): one calculation
  per attack (`Effect.oneHit`, required by `Move.attack` through `Attack.wf`), on the base damage
  as the text computes it (`Amt`), then the attacker's bonus, Weakness, Resistance, the
  defender's reduction and prevention, each subtraction stopping at 0.
* Attack damage only from attacks (2023 p. 20, step 1: "If an attack tells you to put damage
  counters on a Pokémon, you have no more calculations to do because damage counters aren't
  affected by Weakness, Resistance, or any other effects"): Item and Supporter effects have no
  damage step (`Move.item`, `Move.supporter` require `Effect.hitFree`); their damage is written
  as damage counters (`counters`, `selfDamage`). A printed Trainer card whose text says "does
  damage", if there is one, would lose any modifier the rulebook applies to it; no search for
  such cards was made.

Known gaps (each is a place where this model is simpler than the rulebook):
* setup, mulligans and the opening coin flip are not modelled; start from a set-up state;
* Energy is attached to, and evolution applied to, the Active Pokémon only;
* attack costs are typed (milestone M4; rulebook 2023 p. 13): each typed symbol is paid by a
  unit of attached Energy of that type and each Colorless symbol by any unit, every unit paying
  one symbol (`Pays`, decided by `payable`); only Basic Energy exists, one unit of its type
  (`Card.provides`); Special Energy (several units, or units of several types), cost changes
  ("this attack costs ✱ less") and Energy that provides nothing in some states are absent. A
  Retreat Cost is still paid by discarding that many Energy cards, which with Basic Energy only
  is the rulebook's rule;
* Weakness is ×2 to one type and Resistance −N to one type, as printed today (S9: every Standard
  Weakness is ×2; Resistance −30, once −20). Absent: "+10" to "+40" Weakness on older cards,
  two Weaknesses or two Resistances on one card (dual-type Pokémon, S8 C6; a Pokémon has one
  type here), and effects that change or ignore Weakness or Resistance (S8 E2); Weakness and
  Resistance never apply to the Bench, which attack damage does not reach in this model;
* Knock Outs are separate moves, forced by `Settled` (above) before any other move; they are
  taken one at a time, in either order when several are pending, so when both players take
  their last Prize from the same attack or Checkup the first Knock Out taken decides the game
  (no Sudden Death, which the 2023 rulebook has, nor the tiebreaker game that replaced it in
  2026, survey S8 J4); a player with no Pokémon to promote loses at once; only Active Pokémon
  can be Knocked Out, which suffices while no effect damages the Bench; a Knock Out always
  gives exactly one Prize;
* the source of the Knock Out timing outside attacks and Checkup: survey S9 found no rule in
  the 2023 English rulebook (*Scarlet & Violet—151*) that Knock Outs are checked at once at
  other times, and survey S8 quotes none from the 2024 rulebook; the model's immediate Knock
  Outs in mid-effect (`TRun`) and its `Settled` premise on every other move rest on the Pokémon
  Asia *Advanced Player's Rulebook* (Ver. 3.4, 2025), quoted by survey S2 ("When to check for a
  Knock Out: At the end of an attack, At the end of Pokémon checkup, Anytime a Pokémon's
  remaining HP becomes zero, in addition to the above"), a document of another region's rules
  text. This milestone does not change the timing; it is a modelling decision until an English
  source confirms it;
* Knock Outs in mid-effect (Item and Supporter cards, `TRun`): they are checked after each
  primitive step of the model's effect language, so a printed sentence that the model writes
  as several primitives gets a check between them, and the outcome in which the whole
  sentence acts on the original Pokémon is then absent from the model (e.g.
  `seq (counters 5) (scale opp 1)` against a 5-HP Active always acts on the promoted
  Pokémon in its second step); the Knocked Out Pokémon's replacement is
  promoted at once, before the next step (no ruling was found on when the replacement is
  chosen in mid-effect; the promoted Pokémon is a nondeterministic choice, which covers the
  owner's choice, but outcomes in which later steps of the effect find an empty Active Spot
  are absent from the model); when a Prize ends the game, or its owner has no Pokémon to promote, the
  game ends and the rest of the effect is not resolved. Simultaneous Knock Outs cannot arise
  inside a Trainer effect here (each primitive step damages at most one Active Pokémon and
  starts `Settled`), so the order in which they are taken, and Sudden Death, do not arise
  there; a printed effect that damages several Pokémon at once is not expressible;
* a Knock Out takes the top card of the Prize list, whereas the rulebook lets the player
  choose any Prize card (a finite choice);
* HP is the printed value: there are no HP modifiers (the survey's loophole L1);
* markers (`Marks`): Imprison, Shock-wave, Lightning Rod and Char are flags, and the Coloring
  counter is a type. The printed Imprison and Shock-wave counts are uncapped, but only "has
  any" is read and removal takes them all, so a flag is exact for them (`Markers.flag_exact`;
  this is a modelling assumption about the card pool: a card that counted them would break it).
  Effects put a marker or a Coloring counter on any one of either player's Pokémon in play
  (`mark`, `color`; printed cards target the opponent's), remove a marker from all of either
  player's Pokémon (`unmark`; Tropius removes from its own player's), and test either Active
  Pokémon (`Test.marked`, `Test.isType`); markers are general primitives, usable any number of
  times and inside `iter`. Markers stay through evolution, retreat and promotion and leave play
  with the Pokémon (text is silent except for Char, which stays while in play). Char puts 2
  damage counters on tails at every Checkup, but only on an Active Pokémon: Checkup does not
  reach the Bench, so a Char counter on a Benched Pokémon does nothing until it is Active again
  (a restriction: the printed Char also damages a Benched Pokémon, which this model cannot Knock
  Out). Absent: the readers of Imprison (Poké-Powers and Poké-Bodies; Abilities are absent),
  tests on Benched Pokémon's markers ("Choose 1 of your opponent's Pokémon that has any
  Shock-wave markers", "any Pokémon with a Lightning Rod marker"), Dark Ivysaur bp-6's
  transient markers allocated by the opponent, and the marker-like states of S7 §3.3 (Poison
  payloads, delayed triggers, attack locks bound to one Pokémon, history flags, face-up Prizes);
* effects read only the two Active Pokémon: their damage (threshold and exact tests,
  `Test.atLeast` and `Test.exactly`; the proportional write `scale`), their Special
  Conditions (`Test.cond`), their markers (`Test.marked`) and their type (`Test.isType`); there
  are no tests or counts on Benched Pokémon, on Energy, on
  cards in hand, deck, discard pile or Prizes, on Poison strength, on HP ("if it has full HP",
  "remaining HP"), or on the lingering modifiers in effect; `scale` writes only to the
  opponent's Active Pokémon (Lunala cel25-15 doubles the damage on each of the opponent's
  Pokémon, Bench included); the damage step's amount (`Amt`) reads the damage on either
  Active Pokémon (`Amt.per`); the damage step itself reads the Weakness and Resistance of the
  opponent's Active Pokémon and the type of the player's;
* lingering modifiers (`Store`, `Effect.linger`): each player has a damage bonus for their
  attacks, a damage reduction and a damage prevention for attacks against their Pokémon, and
  locks on attacking, retreating and playing Items, for this turn, the next turn, the turn
  after, or the rest of the game; `endTurn` shifts the turns (`Store.shift`). Amounts add up
  without limit: `linger` is a general primitive, usable any number of times and inside
  `iter` (printed same-turn bonuses and reductions are bounded by copies times a constant if no
  card-recycling loop replays them, an empirical claim about the card pool; rest-of-game ones
  come from once-per-game GX attacks; a reduction carried into the opponent's turn exists on a
  printed Item, Iron Defender; the model over-approximates them).
  Modifiers belong to a player, not to one Pokémon: "this Pokémon takes 30 less damage during
  your opponent's next turn" protects whichever Pokémon that player has Active, and does not
  end when the Pokémon leaves the Active Spot or follow it to the Bench. Damage done by an
  attack is computed once per attack, by the rulebook's steps (`dealtBy`, 2023 p. 20): nothing
  if the base damage `n` is 0; otherwise `n` plus the attacker's bonus (step 2), doubled under
  Weakness (step 3), less Resistance (step 4), less the defender's reduction (step 5), each
  subtraction stopping at 0, or nothing under prevention; `counters` (damage counters, not
  damage) is not modified, as in the rulebook. The bonus is placed at step 2 and the reduction
  at step 5, which is what printed modifiers say ("… more damage … (before applying Weakness
  and Resistance)", "… less damage … (after applying Weakness and Resistance)", survey S9);
  modifiers that name the other step are not expressible. Absent: threshold
  prevention ("prevent damage of 40 or less"), prevention of effects, locks on Supporters,
  Stadiums, Abilities or Energy attachment, cost changes, effects that change Weakness,
  Resistance or type (other than the Coloring counter), "attack twice" and "take another turn",
  and "that much more damage" (damage taken last turn).
  Finiteness is proved for two classes of decks. *Tame decks* (`Reach.finite`): the clamp
  `GameState.clamp k`, which caps every bonus and reduction, is a bisimulation when no card adds
  a damage reduction or uses `drain` and no reduction is in effect at the start
  (`GameState.Fit`); for every cap `k ≥ 3` there is a deck with a reduction for which that clamp
  is not a simulation (`Lingering.reduce_breaks_clamp`), and for every `k ≥ 2` a deck with
  `drain` (`Lingering.drain_breaks_clamp`). *Faithful decks* (`Faithful.xfinite`): the clamp
  with exact stores, `GameState.xclamp`, is a bisimulation for every deck, on all pairs of
  states with equal `xclamp` (`Reach.xclamp_bisim`, `GameState.xclamp_bisim`), and its reachable
  values are finite when the stores stay bounded
  (`Reach.xfinite_bounded`), which holds for decks with no damage bonus or reduction under
  `iter` (`LoopFree`) and rest-of-game bonuses and reductions only in GX attacks (`GXOnly`;
  `Faithful.reach_boundedStores`). Faithful decks may use damage reduction, `drain`, and
  carried bonuses and reductions in attacks and Trainers. The bound uses that no card ever
  leaves a discard pile in this model, so each Trainer card is played at most once per game; a
  card-recycling effect, "attack twice" or extra turns would break it. The rest-of-game
  modifiers of non-GX attacks give two unbounded counters with an exact zero test, and the model
  simulates every two-counter machine (`Counter.universal`; this rests on the
  over-approximation of rest-of-game modifiers just described, on `damage` read by a test later
  in the same attack, on a printed HP chosen for the machine, and on the other departures listed
  in `Pokemon/Counter.lean`); its start states satisfy `LoopFree`, and violate `GXOnly` when the
  machine's first instruction is not `halt` (`Faithful.counter_not_gxOnly`), so the `GXOnly`
  clause cannot be dropped from `Faithful.xfinite` (`Faithful.dichotomy`, a sharpness result, not
  a classification: nothing is proved about other decks that are not faithful); with Minsky's theorem (prose) this rules out a uniform computable
  finite abstraction of the generalised model; for one such deck the reachable states are not
  finite up to the exact-store clamp, nor up to any equivalence fine enough to recover the
  machine's configuration, a statement about representation, not play
  (`Faithful.xclamp_not_finite`, `Counter.not_finite_up_to`);
* an attack's damage (milestone M4): an attack with a printed base damage and no damage text
  does that damage and then its effect (`Attack.script`); an attack whose text computes or
  conditions its damage has base damage field 0 and one damage step in its effect
  (`damage a`, `drain a`; at most one on each line of resolution, `Effect.oneHit`), whose
  amount `a` is evaluated once when the step is reached ("20 damage plus 10 more for each
  damage counter on the Defending Pokémon", Jynx base1-31, is `damage (add (const 2) (per opp
  1))`; with a reduction of 3 and 3 counters on the target it does (2 + 3) - 3 = 2,
  `Calc.dealtBy_jynx`). Effects before the damage step are the rulebook's "effects that happen
  before damage" (step F); effects after it see the damage placed. The amount language (`Amt`:
  constants, a multiple of the damage counters on either Active Pokémon, sums, truncated
  differences, and the sum of any number of copies, for "flip until tails") has no tests of its
  own: a damage that depends on a test, a coin flip or a choice is written with the damage step
  inside the branches of `ite` or `choice`, which also lets the same flip decide the damage and
  another effect. Not expressible: damage counts other than damage counters on the Active
  Pokémon (Energy, Benched Pokémon, cards in hand or discard pile), and two damage calculations
  in one attack (an attack that also damages a Benched Pokémon; the Bench is absent anyway).
  Generality lost
  against the earlier model: an attack can no longer make several damage steps (an `iter` of
  `damage`, which applied the modifiers per step and is not the rulebook's calculation), and
  Item and Supporter effects can no longer do attack damage (their printed counterparts place
  counters);
* `ite`, `scale`, `selfDamage` and `healAll` are general primitives, usable in any effect,
  any number of times and inside `iter`, whereas printed cards use them once, in fixed forms;
  the model over-approximates the printed texts;
* GX attacks (`Attack.gx`): a player who has used one (`PlayerState.gxUsed`) cannot use another
  in the same game; the flag is set by `Move.attack` (a rule added for `Pokemon/Faithful.lean`;
  before it, `gxUsed` was never read or written). A Confused Pokémon can try a GX attack
  (`attackConfused`) only under the same condition, and a failed attempt (tails) does not use it
  up: whether a failed Confused GX attempt uses up the once-per-game attack is an unverified
  ruling, and the model takes the answer "no"; VSTAR Powers are absent (`vstarUsed` is unused);
* Special Conditions: effects apply them only to the opponent's Active Pokémon (`inflict`) and
  remove them only from the player's own Active Pokémon (`cure`); the variants with a number
  ("put 2 damage counters instead of 1 on the Poisoned Pokémon") are absent; a new Poison
  replaces the old one, as the rulebook says (2023 p. 16, 2024 the same), so poisoning a
  Pokémon that is already Poisoned resets its Poison strength (`poisonUp`) to 0
  (`InPlay.inflict`); Croagunk's cumulative increase is modelled as a number on the Pokémon
  (`poisonUp`) that belongs to the Poisoned Condition: it lasts until Poison ends or is
  replaced, and stacks across uses of the attack, which raises an existing Poison and does not
  re-Poison (that the increase ends when a later attack re-Poisons the Pokémon is the model's
  reading of "replaces"; no ruling on it was found); a Confused Pokémon whose flip is tails
  ends the turn as an attack does (the rulebook: "the attack doesn't happen", p. 16; that the
  failed attempt still ends the turn is the model's reading of the attack steps, p. 20, in
  which the Confusion check is step C of using the attack), and its attack must be one it could
  otherwise use;
* Pokémon Checkup (`InPlay.checkup`) covers the five Special Conditions and the Char counter
  only: no Ability,
  Stadium or other "between turns" card effect exists in the model (so the rulebook's
  choice of order between Special Conditions and those effects does not arise); Burn uses the
  current rule (2 counters, then heads cures); Paralysis ends at the Checkup after its
  owner's turn, which is exact here because only the opponent's Pokémon can be Paralyzed;
  coin flips are nondeterministic choices, so the model is silent about probability;
* `poisonUp n` is a general effect primitive, usable in any effect and inside `iter`, whereas
  the printed card (Croagunk) raises Poison strength once per use of its attack; the model
  over-approximates it, and one Item can raise Poison strength without bound
  (`Infinite.not_finite_damageBounded`);
* effects damage only the two Active Pokémon (`counters`, `scale` on the opponent's,
  `selfDamage` on the player's own): no effect damages the Bench;
* `heal` and `healAll` remove damage from the player's own Active Pokémon only, not from the
  Bench nor from the opponent's Pokémon;
* Stadium and Tool cards occupy state but have no move (survey S8 B9, B10: milestone M5): the
  Stadium slot is one slot shared by both players (`GameState.stadium`, with the card's owner),
  as the rulebook has it, but it only holds a card of the start state; so the rules that come
  with playing a Stadium (one per turn, no Stadium of the same name, the old one discarded) and
  Tools (one per Pokémon) have nothing to act on yet; Abilities are absent;
* start states are not required to be well formed; from a `WellFormed` start no reachable
  state without a winner is stuck (`Reach.progress`), but from other starts (e.g. no winner and
  an empty Prize list) a pending Knock Out may be impossible to take; nor are they required to
  be consistent in their turn flags (`firstTurn` with `curIsFirst` and `hadTurn`; `attacked`
  with `between`): from a start with `firstTurn` true and the player's `hadTurn` already true,
  that player could evolve on the game's first turn. Consistency is `GameState.FlagsOk`
  (`Pokemon/Turn.lean`); play preserves it (`Reach.flagsOk`), and the first-turn bans are
  theorems under it (`Move.firstTurn_no_attack`, `GameState.FlagsOk.firstTurn_no_evolve`);
* first-turn rules are the rulebook's (2023 pp. 11–13; S8 records no later change): the
  starting player cannot attack or play a Supporter on the first turn of the game
  (`firstTurn`), and neither player can evolve on their own first turn (`hadTurn`); card text
  that lifts these bans ("If you go first, you can use this attack during your first turn",
  Delibird me1-105; 26 Standard cards, survey S9 part 2) is not expressible.
-/

namespace Pokemon

/-- No Knock Out is pending: every Pokémon in play has fewer damage counters than its HP.
Every move except the Knock Out moves requires it (through `Settled`, or directly). It is NOT
an invariant of all reachable states: an attack or Trainer card can leave a Pokémon at or above
its HP (then the Knock Out must be taken next), and so can Checkup
(`Infinite.endTurn_pending_ko_reachable`); it holds when the turn proper begins
(`Move.damageBounded_of_startTurn`). -/
def DamageBounded (g : GameState) : Prop :=
  ∀ p : InPlay,
    (g.cur.active = some p ∨ p ∈ g.cur.bench ∨ g.opp.active = some p ∨ p ∈ g.opp.bench) →
      p.damage < p.top.hp

/-- A Benched Pokémon as the rules leave it: below its HP and with no Special Condition. -/
def Benched (p : InPlay) : Prop :=
  p.damage < p.top.hp ∧ p.rot = .none ∧ p.poisoned = false ∧ p.burned = false ∧ p.poisonUp = 0

/-- Well-formed states: while there is no winner both players have Prize cards left, and
every Benched Pokémon is `Benched`. `Move` preserves it (`Move.wellFormed`). -/
def WellFormed (g : GameState) : Prop :=
  (g.winner = none → g.cur.prizes ≠ [] ∧ g.opp.prizes ≠ []) ∧
    (∀ p ∈ g.cur.bench, Benched p) ∧ ∀ p ∈ g.opp.bench, Benched p

/-- No Knock Out is pending and both Active Spots are filled. Every move except the six that
resolve Knock Outs (`knockOut`, `promote`, `noPokemon` and their `Own` versions) requires it,
so a pending Knock Out is taken, and the Pokémon replaced, before any other move. -/
def Settled (g : GameState) : Prop :=
  DamageBounded g ∧ g.cur.active ≠ none ∧ g.opp.active ≠ none

/-- The six moves that resolve a Knock Out, as a relation of their own: they are the moves
`Move.knockOut`, `Move.promote`, `Move.noPokemon`, `Move.knockOutOwn`, `Move.promoteOwn` and
`Move.noPokemonOwn`, with the same premises and results (`KOMove.move`). `Resolve` uses them to
take Knock Outs in the middle of a Trainer card's effect. -/
inductive KOMove : GameState → GameState → Prop where
  | knockOut {g : GameState} {p : InPlay} {c : Card} {ps : List Card}
      (ha : g.opp.active = some p) (hk : p.top.hp ≤ p.damage)
      (hp : g.cur.prizes = c :: ps) :
      KOMove g { g with
        opp := { g.opp with active := none, discard := p.cardList ++ g.opp.discard },
        cur := { g.cur with prizes := ps, hand := c :: g.cur.hand },
        winner := if ps.isEmpty then some g.curIsFirst else g.winner }
  | promote {g : GameState} {q : InPlay} {b₁ b₂ : List InPlay}
      (ha : g.opp.active = none) (hb : g.opp.bench = b₁ ++ q :: b₂) :
      KOMove g { g with opp := { g.opp with active := some q, bench := b₁ ++ b₂ } }
  | noPokemon {g : GameState} (ha : g.opp.active = none) (hb : g.opp.bench = []) :
      KOMove g { g with winner := some g.curIsFirst }
  | knockOutOwn {g : GameState} {p : InPlay} {c : Card} {ps : List Card}
      (ha : g.cur.active = some p) (hk : p.top.hp ≤ p.damage)
      (hp : g.opp.prizes = c :: ps) :
      KOMove g { g with
        cur := { g.cur with active := none, discard := p.cardList ++ g.cur.discard },
        opp := { g.opp with prizes := ps, hand := c :: g.opp.hand },
        winner := if ps.isEmpty then some (!g.curIsFirst) else g.winner }
  | promoteOwn {g : GameState} {q : InPlay} {b₁ b₂ : List InPlay}
      (ha : g.cur.active = none) (hb : g.cur.bench = b₁ ++ q :: b₂) :
      KOMove g { g with cur := { g.cur with active := some q, bench := b₁ ++ b₂ } }
  | noPokemonOwn {g : GameState} (ha : g.cur.active = none) (hb : g.cur.bench = []) :
      KOMove g { g with winner := some (!g.curIsFirst) }

/-- `Resolve g g'`: take every pending Knock Out now. Knock Out moves (`KOMove`: a Prize to the
other player, which may win the game; promotion of a Benched Pokémon chosen by its owner, a
nondeterministic choice; or a loss if no Pokémon is left) are made one after another until the
state is `Settled` or the game has a winner. Stopping earlier is not allowed: `done` requires
one of the two, and no `KOMove` exists from a `Settled` state. -/
inductive Resolve : GameState → GameState → Prop where
  | done {g : GameState} (h : Settled g ∨ g.winner ≠ none) : Resolve g g
  | step {g g₁ g' : GameState} (hn : g.winner = none) (hm : KOMove g g₁)
      (hr : Resolve g₁ g') : Resolve g g'

/-- **Resolution of a Trainer card's effect**, with the rulebook's Knock Out timing: a Pokémon
whose damage reaches its HP at any time other than during an attack or Checkup is Knocked Out
at once. Each primitive step (`Effect.isPrim`, resolved by one step of `Run`) is followed by
`Resolve`, which takes every Knock Out it caused, gives the Prize card and promotes the
replacement before the next step; the rest of the effect then acts on the new board. Once the
game has a winner the rest of the effect is not resolved (`stop`; `TRun.of_won`: a finished
game is the only result). Tests (`ite`) and primitive steps require that the game is not over.

Design. Of the two candidate semantics, the exact one (Knock Outs forced after every step) was
chosen over a superset (Knock Outs allowed but not forced at every step): the superset would
keep the model's ability to read and heal over-HP damage inside a Trainer effect, which the
printed game lacks, so it would only over-approximate, and its finiteness would have to be
proved anyway for the larger relation; the exact semantics costs no more to prove and makes
the clamp a simulation for whole Trainer effects (`TRun.clamp_sim`). `TRun.guarded` states the
timing: from a state that is `Settled` or finished, every primitive step and every test of a
resolution starts in a `Settled` state, so no step of a Trainer effect is executed while an
Active Pokémon is at or above its HP.

At most one Active Pokémon can reach its HP in one step (each damaging primitive damages one
Active Pokémon and the step starts `Settled`), so the order of simultaneous Knock Outs does not
arise inside a Trainer effect; `Resolve` nonetheless allows any order. -/
inductive TRun : Effect → GameState → GameState → Prop where
  | prim {e : Effect} {g g₁ g₂ : GameState} (he : e.isPrim = true) (hn : g.winner = none)
      (hr : Run e g g₁) (hk : Resolve g₁ g₂) : TRun e g g₂
  | stop {e : Effect} {g : GameState} (hn : g.winner ≠ none) : TRun e g g
  | iteT {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay} (hn : g.winner = none)
      (h : g.activeOf t.whose = some p) (ht : t.eval p = true) :
      TRun a g g' → TRun (.ite t a b) g g'
  | iteF {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay} (hn : g.winner = none)
      (h : g.activeOf t.whose = some p) (ht : t.eval p = false) :
      TRun b g g' → TRun (.ite t a b) g g'
  | seq {a b : Effect} {g₁ g₂ g₃ : GameState} :
      TRun a g₁ g₂ → TRun b g₂ g₃ → TRun (.seq a b) g₁ g₃
  | choiceL {a b : Effect} {g g' : GameState} : TRun a g g' → TRun (.choice a b) g g'
  | choiceR {a b : Effect} {g g' : GameState} : TRun b g g' → TRun (.choice a b) g g'
  | iterNil (a : Effect) (g : GameState) : TRun (.iter a) g g
  | iterCons {a : Effect} {g₁ g₂ g₃ : GameState} :
      TRun a g₁ g₂ → TRun (.iter a) g₂ g₃ → TRun (.iter a) g₁ g₃

inductive Move : GameState → GameState → Prop where
  /-- put a Basic Pokémon from hand onto the Bench -/
  | playBasic {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂)
      (hs : p.stage = .basic) (hhp : 0 < p.hp)
      (hb : g.cur.bench.length < benchLimit) (hbt : g.between = false) (hst : Settled g)
      (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, bench := g.cur.bench ++ [InPlay.ofBasic p] } }
  /-- attach one Energy card from hand to the Active Pokémon, once per turn -/
  | attach {g : GameState} {l₁ l₂ : List Card} {t : BasicEnergy} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.energy t :: l₂)
      (hf : g.cur.energyAttached = false) (ha : g.cur.active = some a)
      (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, energyAttached := true,
        active := some { a with energy := Card.energy t :: a.energy } } }
  /-- evolve the Active Pokémon; Special Conditions are removed. Not a Pokémon put into play or
  evolved this turn (`fresh`: "Neither player can evolve a Pokémon on its first turn in play",
  "you can't evolve it a second time the same turn"), and not on the player's own first turn
  (`hadTurn`: "neither player can evolve a Pokémon on that player's first turn unless a card
  says so"; rulebook 2023 p. 11) -/
  | evolve {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (ha : g.cur.active = some a)
      (he : p.evolvesFrom = some a.top.name) (hfr : a.fresh = false)
      (hf : g.cur.hadTurn = true) (hbt : g.between = false) (hst : Settled g)
      (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂,
        active := some { a with
          top := p, under := Card.pokemon a.top :: a.under,
          rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true } } }
  /-- retreat: discard Energy equal to the retreat cost and swap with a Benched Pokémon -/
  | retreat {g : GameState} {a q : InPlay} {b₁ b₂ : List InPlay} {paid rest : List Card}
      (ha : g.cur.active = some a) (hb : g.cur.bench = b₁ ++ q :: b₂)
      (hr : g.cur.retreated = false) (he : a.energy = paid ++ rest)
      (hp : paid.length = a.top.retreat)
      (hs : a.rot.canAct = true) (hbt : g.between = false) (hst : Settled g)
      (hl : g.cur.mods.live.noRetreat = false) (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        active := some q,
        bench := b₁ ++ { a with
          energy := rest, rot := .none, poisoned := false, burned := false, poisonUp := 0 } :: b₂,
        discard := paid ++ g.cur.discard, retreated := true } }
  /-- play an Item card: it goes to the discard pile and its effect resolves, with Knock Outs
  taken at once in mid-effect (`TRun`); not while an Item lock is in effect. Its effect has no
  attack damage step (`Effect.hitFree`): Trainer cards place damage counters -/
  | item {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .item e :: l₂) (hbt : g.between = false)
      (hst : Settled g)
      (hr : TRun e { g with cur := { g.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } g')
      (hl : g.cur.mods.live.noItem = false) (hat : g.attacked = false)
      (hnd : e.hitFree = true) :
      Move g g'
  /-- play a Supporter card, once per turn, and not on the first turn of the game ("The player
  who goes first cannot play a Supporter card on their first turn", rulebook 2023 p. 12); its
  effect resolves as an Item's does (`TRun`), and has no attack damage step -/
  | supporter {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .supporter e :: l₂)
      (hs : g.cur.supporterPlayed = false) (hbt : g.between = false) (hst : Settled g)
      (hr : TRun e { g with cur := { g.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g.cur.discard } } g')
      (hat : g.attacked = false) (hf : g.firstTurn = false) (hnd : e.hitFree = true) :
      Move g g'
  /-- attack: the attached Energy must pay the cost (`Pays`, typed); resolve the attack's script
  (`Attack.script`: the printed base damage then the effect, or the effect with its own damage
  step), making the rulebook's damage calculation at most once (`Attack.wf`, `Effect.oneHit`;
  `dealtBy`). The attack ends the turn (`attacked`): afterwards only Knock Outs and
  `endTurn` are legal. An Asleep or Paralyzed Pokémon cannot attack; a Confused one can, when
  its coin flip is heads; nobody can attack while an attack lock is in effect on them. A GX
  attack (`Attack.gx`) can be used only by a player who has not used one in this game, and
  using it records that (`PlayerState.gxUsed`). -/
  | attack {g g' : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks)
      (hc : Pays atk.cost a.units) (hs : a.rot.canAct = true)
      (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
      (hst : Settled g)
      (hr : Run atk.script g g')
      (hl : g.cur.mods.live.noAttack = false)
      (hgx : atk.gx = true → g.cur.gxUsed = false) (hw : atk.wf = true) :
      Move g { g' with attacked := true, cur := { g'.cur with gxUsed := atk.gx || g'.cur.gxUsed } }
  /-- a Confused Pokémon tries to attack and the coin flip is tails: the attack does not
  happen, and the attacker gets 3 damage counters; this still ends the turn (`attacked`). As for `attack`, a GX attack can be tried
  only by a player who has not used one in this game; the failed attempt does not use it up
  (an unverified ruling; see the Known gaps). -/
  | attackConfused {g : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks)
      (hc : Pays atk.cost a.units) (hs : a.rot = .confused)
      (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
      (hst : Settled g) (hl : g.cur.mods.live.noAttack = false)
      (hgx : atk.gx = true → g.cur.gxUsed = false) (hw : atk.wf = true) :
      Move g { g with
        cur := { g.cur with active := some { a with damage := a.damage + 3 } },
        attacked := true }
  /-- Knock Out the opponent's Active Pokémon and take a Prize card (during the turn or
  between turns) -/
  | knockOut {g : GameState} {p : InPlay} {c : Card} {ps : List Card}
      (ha : g.opp.active = some p) (hk : p.top.hp ≤ p.damage)
      (hp : g.cur.prizes = c :: ps) :
      Move g { g with
        opp := { g.opp with active := none, discard := p.cardList ++ g.opp.discard },
        cur := { g.cur with prizes := ps, hand := c :: g.cur.hand },
        winner := if ps.isEmpty then some g.curIsFirst else g.winner }
  /-- the opponent promotes a Benched Pokémon to the empty Active spot -/
  | promote {g : GameState} {q : InPlay} {b₁ b₂ : List InPlay}
      (ha : g.opp.active = none) (hb : g.opp.bench = b₁ ++ q :: b₂) :
      Move g { g with opp := { g.opp with active := some q, bench := b₁ ++ b₂ } }
  /-- the opponent has no Pokémon left to promote -/
  | noPokemon {g : GameState} (ha : g.opp.active = none) (hb : g.opp.bench = []) :
      Move g { g with winner := some g.curIsFirst }
  /-- Knock Out the player's own Active Pokémon (after evolving into a card with less HP,
  after Confusion, after an effect that damages it, or after Checkup); the opponent takes a
  Prize card -/
  | knockOutOwn {g : GameState} {p : InPlay} {c : Card} {ps : List Card}
      (ha : g.cur.active = some p) (hk : p.top.hp ≤ p.damage)
      (hp : g.opp.prizes = c :: ps) :
      Move g { g with
        cur := { g.cur with active := none, discard := p.cardList ++ g.cur.discard },
        opp := { g.opp with prizes := ps, hand := c :: g.opp.hand },
        winner := if ps.isEmpty then some (!g.curIsFirst) else g.winner }
  /-- the player promotes a Benched Pokémon to their own empty Active spot -/
  | promoteOwn {g : GameState} {q : InPlay} {b₁ b₂ : List InPlay}
      (ha : g.cur.active = none) (hb : g.cur.bench = b₁ ++ q :: b₂) :
      Move g { g with cur := { g.cur with active := some q, bench := b₁ ++ b₂ } }
  /-- the player has no Pokémon left to promote -/
  | noPokemonOwn {g : GameState} (ha : g.cur.active = none) (hb : g.cur.bench = []) :
      Move g { g with winner := some (!g.curIsFirst) }
  /-- end the turn: Pokémon Checkup on both Active Pokémon, with coin flips `fa`, `sa`, `ca`
  (Burn, Sleep, Char) for the opponent's and `fb`, `sb`, `cb` for the player's own; the
  lingering modifiers of this turn expire and the others move one turn closer (`Store.shift`);
  then the opponent becomes the player to move, between turns. Requires both Active Pokémon
  and no pending Knock Out anywhere. -/
  | endTurn {g : GameState} {a b : InPlay} (fa sa ca fb sb cb : Bool)
      (ha : g.opp.active = some a) (hb : g.cur.active = some b) (hk : DamageBounded g)
      (hbt : g.between = false) :
      Move g
        { cur := { g.opp with
            active := some (a.checkup false fa sa ca),
            energyAttached := false, supporterPlayed := false, retreated := false,
            mods := g.opp.mods.shift },
          opp := { g.cur.unfresh with
            active := some (b.unfresh.checkup true fb sb cb), mods := g.cur.mods.shift,
            hadTurn := true },
          curIsFirst := !g.curIsFirst, firstTurn := false, attacked := false,
          between := true, winner := g.winner, stadium := g.stadium }
  /-- begin the turn by drawing a card, once the Knock Outs from Checkup have all been taken
  and both Active Spots are filled -/
  | startTurn {g : GameState} {a b : InPlay} {c : Card} {d : List Card}
      (hbt : g.between = true) (ha : g.opp.active = some a) (hb : g.cur.active = some b)
      (hk : DamageBounded g) (hd : g.cur.deck = c :: d) :
      Move g { g with cur := { g.cur with deck := d, hand := c :: g.cur.hand }, between := false }
  /-- the player to move cannot draw at the beginning of the turn and loses -/
  | deckOut {g : GameState} {a b : InPlay}
      (hbt : g.between = true) (ha : g.opp.active = some a) (hb : g.cur.active = some b)
      (hk : DamageBounded g) (hd : g.cur.deck = []) :
      Move g { g with winner := some (!g.curIsFirst) }

/-- Reachability by legal play. No move is made once the game has a winner. -/
inductive Reach : GameState → GameState → Prop where
  | refl (g : GameState) : Reach g g
  | step {g₀ g g' : GameState} : Reach g₀ g → g.winner = none → Move g g' → Reach g₀ g'

/-- A Knock Out move is a move. -/
theorem KOMove.move {g g' : GameState} (h : KOMove g g') : Move g g' := by
  cases h with
  | knockOut ha hk hp => exact .knockOut ha hk hp
  | promote ha hb => exact .promote ha hb
  | noPokemon ha hb => exact .noPokemon ha hb
  | knockOutOwn ha hk hp => exact .knockOutOwn ha hk hp
  | promoteOwn ha hb => exact .promoteOwn ha hb
  | noPokemonOwn ha hb => exact .noPokemonOwn ha hb

end Pokemon
