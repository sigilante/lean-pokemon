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

Knock Out timing. The rulebook checks for Knock Outs at the end of every attack, at the end of
every Pokémon Checkup, and at once whenever damage reaches HP at any other time. The model
follows it in two ways. Between moves: every move that is not part of resolving a Knock Out
(the six moves `knockOut`, `promote`, `noPokemon` and their `Own` versions) requires the state
to be `Settled`: no Pokémon in play is at or above its HP, and both Active Spots are filled.
So once a move leaves a Pokémon at or above its HP, the next moves must Knock it Out (and
promote a replacement) before anything else happens; nothing can read, heal or otherwise use
an over-HP Pokémon between moves. Inside a move: an attack's effect is resolved as a whole by
`Run`, so damage may exceed HP and the effect can read it, and the Knock Outs come after the
attack, as the rulebook says; an Item or Supporter's effect is resolved by `TRun`, which takes
every Knock Out at once after each primitive step (`Resolve`) and stops if the game is over, so
no step of a Trainer effect runs while a Pokémon is at or above its HP (`TRun.guarded`).

Known gaps (each is a place where this model is simpler than the rulebook):
* setup, mulligans and the opening coin flip are not modelled; start from a set-up state;
* Energy is attached to, and evolution applied to, the Active Pokémon only;
* attack costs are checked by Energy count, not type; Weakness and Resistance are absent;
* Knock Outs are separate moves, forced by `Settled` (above) before any other move; they are
  taken one at a time, in either order when several are pending, so when both players take
  their last Prize from the same attack or Checkup the first Knock Out taken decides the game
  (no Sudden Death); a player with no Pokémon to promote loses at once; only Active Pokémon
  can be Knocked Out, which suffices while no effect damages the Bench; a Knock Out always
  gives exactly one Prize;
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
  Pokémon, Bench included); "damage" in printed text, which Weakness and Resistance would
  modify, is modelled as damage counters, as for base damage;
* lingering modifiers (`Store`, `Effect.linger`): each player has a damage bonus for their
  attacks, a damage reduction and a damage prevention for attacks against their Pokémon, and
  locks on attacking, retreating and playing Items, for this turn, the next turn, the turn
  after, or the rest of the game; `endTurn` shifts the turns (`Store.shift`). Amounts add up
  without limit: `linger` is a general primitive, usable any number of times and inside
  `iter` (printed bonuses and reductions are bounded by copies times a constant, and
  rest-of-game ones come from once-per-game GX attacks; the model over-approximates them).
  Modifiers belong to a player, not to one Pokémon: "this Pokémon takes 30 less damage during
  your opponent's next turn" protects whichever Pokémon that player has Active, and does not
  end when the Pokémon leaves the Active Spot or follow it to the Bench. Damage done by an
  attack (`Effect.damage`, used for base damage) is `n + bonus - reduction`, or nothing under
  prevention; Weakness and Resistance are absent, so the order "bonus, then Weakness and
  Resistance, then reduction" collapses to this; `counters` (damage counters, not damage) is
  not modified, as in the rulebook. `damage` and `drain` are also usable in Trainer effects,
  where the printed game has no attack damage (an over-approximation). Absent: threshold
  prevention ("prevent damage of 40 or less"), prevention of effects, locks on Supporters,
  Stadiums, Abilities or Energy attachment, cost changes, Weakness and type changes, "attack
  twice" and "take another turn", and "that much more damage" (damage taken last turn).
  **Finiteness is proved only for tame decks** (`Reach.finite`): the clamp, which caps every
  bonus, is a bisimulation when no card adds a damage reduction or uses `drain` and no
  reduction is in effect at the start (`GameState.Fit`); with a reduction no cap `k ≥ 3` makes
  the clamp a simulation (`Lingering.reduce_breaks_clamp`), with `drain` no cap `k ≥ 2`
  (`Lingering.drain_breaks_clamp`); for such decks the model is not claimed to be finite up to
  any bisimulation (the rest-of-game modifiers give two unbounded counters with a zero test);
* an attack places its base damage before its effect resolves (`Move.attack`), so an effect
  that reads damage sees the base damage already placed; a printed bonus computed from the
  damage before the attack ("20 damage plus 10 more for each damage counter on the Defending
  Pokémon", Jynx base1-31) is written with base damage 0 and the counters in the effect
  (`seq (scale opp 1) (counters 2)`); the rulebook computes an attack's damage and then places
  it all at once, so the order of the model's primitives is a representation choice;
* `ite`, `scale`, `selfDamage` and `healAll` are general primitives, usable in any effect,
  any number of times and inside `iter`, whereas printed cards use them once, in fixed forms;
  the model over-approximates the printed texts;
* an attack does not end the turn; the first player may play a Supporter on the first turn;
  each player has their own Stadium slot;
* Special Conditions: effects apply them only to the opponent's Active Pokémon (`inflict`) and
  remove them only from the player's own Active Pokémon (`cure`); the variants with a number
  ("put 2 damage counters instead of 1 on the Poisoned Pokémon") are absent; poisoning a
  Pokémon that is already Poisoned keeps its `poisonUp` (no ruling was found either way);
  Croagunk's cumulative increase is modelled as a number on the Pokémon (`poisonUp`) that
  lasts until Poison ends, not as a lingering effect; a Confused Pokémon whose flip is tails
  uses up the turn's attack, and its attack must be one it could otherwise use;
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
* Stadium and Tool cards occupy state but have no move; Abilities are absent;
* start states are not required to be well formed; from a `WellFormed` start no reachable
  state without a winner is stuck (`Reach.progress`), but from other starts (e.g. no winner and
  an empty Prize list) a pending Knock Out may be impossible to take;
* the "no evolving on your first turn" rule is applied to the first turn of the game only.
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
      (hb : g.cur.bench.length < benchLimit) (hbt : g.between = false) (hst : Settled g) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, bench := g.cur.bench ++ [InPlay.ofBasic p] } }
  /-- attach one Energy card from hand to the Active Pokémon, once per turn -/
  | attach {g : GameState} {l₁ l₂ : List Card} {t : EType} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.energy t :: l₂)
      (hf : g.cur.energyAttached = false) (ha : g.cur.active = some a)
      (hbt : g.between = false) (hst : Settled g) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, energyAttached := true,
        active := some { a with energy := Card.energy t :: a.energy } } }
  /-- evolve the Active Pokémon; Special Conditions are removed -/
  | evolve {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (ha : g.cur.active = some a)
      (he : p.evolvesFrom = some a.top.name) (hfr : a.fresh = false)
      (hf : g.firstTurn = false) (hbt : g.between = false) (hst : Settled g) :
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
      (hl : g.cur.mods.live.noRetreat = false) :
      Move g { g with cur := { g.cur with
        active := some q,
        bench := b₁ ++ { a with
          energy := rest, rot := .none, poisoned := false, burned := false, poisonUp := 0 } :: b₂,
        discard := paid ++ g.cur.discard, retreated := true } }
  /-- play an Item card: it goes to the discard pile and its effect resolves, with Knock Outs
  taken at once in mid-effect (`TRun`); not while an Item lock is in effect -/
  | item {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .item e :: l₂) (hbt : g.between = false)
      (hst : Settled g)
      (hr : TRun e { g with cur := { g.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } g')
      (hl : g.cur.mods.live.noItem = false) :
      Move g g'
  /-- play a Supporter card, once per turn; its effect resolves as an Item's does (`TRun`) -/
  | supporter {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .supporter e :: l₂)
      (hs : g.cur.supporterPlayed = false) (hbt : g.between = false) (hst : Settled g)
      (hr : TRun e { g with cur := { g.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g.cur.discard } } g') :
      Move g g'
  /-- attack: do the base damage (with the lingering modifiers, `Effect.damage`), then resolve
  the attack's effect. An Asleep or Paralyzed Pokémon cannot attack; a Confused one can, when
  its coin flip is heads; nobody can attack while an attack lock is in effect on them. -/
  | attack {g g' : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks)
      (hc : atk.cost.length ≤ a.energy.length) (hs : a.rot.canAct = true)
      (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
      (hst : Settled g)
      (hr : Run (.seq (.damage atk.damage) atk.effect) g g')
      (hl : g.cur.mods.live.noAttack = false) :
      Move g { g' with attacked := true }
  /-- a Confused Pokémon tries to attack and the coin flip is tails: the attack does not
  happen, and the attacker gets 3 damage counters -/
  | attackConfused {g : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks)
      (hc : atk.cost.length ≤ a.energy.length) (hs : a.rot = .confused)
      (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
      (hst : Settled g) (hl : g.cur.mods.live.noAttack = false) :
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
            active := some (b.unfresh.checkup true fb sb cb), mods := g.cur.mods.shift },
          curIsFirst := !g.curIsFirst, firstTurn := false, attacked := false,
          between := true, winner := g.winner }
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
