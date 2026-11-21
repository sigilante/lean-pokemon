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
follows it at the granularity of moves: every move that is not part of resolving a Knock Out
(the six moves `knockOut`, `promote`, `noPokemon` and their `Own` versions) requires the state
to be `Settled`: no Pokémon in play is at or above its HP, and both Active Spots are filled.
So once a move leaves a Pokémon at or above its HP, the next moves must Knock it Out (and
promote a replacement) before anything else happens; nothing can read, heal or otherwise use
an over-HP Pokémon between moves. Inside one move, during the resolution of one effect (one
`Run`), damage may exceed HP and effects can read it.

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
* an Item or Supporter's effect is resolved as a whole before any Knock Out is taken, as an
  attack is: the rulebook would Knock Out at once a Pokémon whose damage reaches its HP in
  the middle of a Trainer card's effect, so the model lets a Trainer card read (and heal)
  over-HP damage that the printed game would not; this over-approximates what play can do;
* HP is the printed value: there are no HP modifiers (the survey's loophole L1);
* there are no markers (Imprison, Shock-wave), which the survey found to be uncapped counts;
* effects read only the two Active Pokémon: their damage (threshold and exact tests,
  `Test.atLeast` and `Test.exactly`; the proportional write `scale`) and their Special
  Conditions (`Test.cond`); there are no tests or counts on Benched Pokémon, on Energy, on
  cards in hand, deck, discard pile or Prizes, on Poison strength, on HP ("if it has full HP",
  "remaining HP"), and no lingering "this turn" modifiers; `scale` writes only to the
  opponent's Active Pokémon (Lunala cel25-15 doubles the damage on each of the opponent's
  Pokémon, Bench included); "damage" in printed text, which Weakness and Resistance would
  modify, is modelled as damage counters, as for base damage;
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
* Pokémon Checkup (`InPlay.checkup`) covers the five Special Conditions only: no Ability,
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
      (hs : a.rot.canAct = true) (hbt : g.between = false) (hst : Settled g) :
      Move g { g with cur := { g.cur with
        active := some q,
        bench := b₁ ++ { a with
          energy := rest, rot := .none, poisoned := false, burned := false, poisonUp := 0 } :: b₂,
        discard := paid ++ g.cur.discard, retreated := true } }
  /-- play an Item card: it goes to the discard pile and its effect resolves -/
  | item {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .item e :: l₂) (hbt : g.between = false)
      (hst : Settled g)
      (hr : Run e { g with cur := { g.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } g') :
      Move g g'
  /-- play a Supporter card, once per turn -/
  | supporter {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .supporter e :: l₂)
      (hs : g.cur.supporterPlayed = false) (hbt : g.between = false) (hst : Settled g)
      (hr : Run e { g with cur := { g.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g.cur.discard } } g') :
      Move g g'
  /-- attack: place the base damage, then resolve the attack's effect. An Asleep or
  Paralyzed Pokémon cannot attack; a Confused one can, when its coin flip is heads. -/
  | attack {g g' : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks)
      (hc : atk.cost.length ≤ a.energy.length) (hs : a.rot.canAct = true)
      (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
      (hst : Settled g)
      (hr : Run (.seq (.counters atk.damage) atk.effect) g g') :
      Move g { g' with attacked := true }
  /-- a Confused Pokémon tries to attack and the coin flip is tails: the attack does not
  happen, and the attacker gets 3 damage counters -/
  | attackConfused {g : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks)
      (hc : atk.cost.length ≤ a.energy.length) (hs : a.rot = .confused)
      (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
      (hst : Settled g) :
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
  /-- end the turn: Pokémon Checkup on both Active Pokémon, with coin flips `fa`, `sa` (Burn,
  Sleep) for the opponent's and `fb`, `sb` for the player's own; then the opponent becomes the
  player to move, between turns. Requires both Active Pokémon and no pending Knock Out
  anywhere. -/
  | endTurn {g : GameState} {a b : InPlay} (fa sa fb sb : Bool)
      (ha : g.opp.active = some a) (hb : g.cur.active = some b) (hk : DamageBounded g)
      (hbt : g.between = false) :
      Move g
        { cur := { g.opp with
            active := some (a.checkup false fa sa),
            energyAttached := false, supporterPlayed := false, retreated := false },
          opp := { g.cur.unfresh with active := some (b.unfresh.checkup true fb sb) },
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

end Pokemon
