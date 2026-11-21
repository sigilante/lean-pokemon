import Pokemon.Effect

/-!
# Moves

`Move g g'` is one legal step of the game from the point of view of the player to move.
`Reach g₀ g` is reachability by legal play; no move is available once a winner is set.

Known gaps (each is a place where this model is simpler than the rulebook):
* setup, mulligans and the opening coin flip are not modelled; start from a set-up state;
* Energy is attached to, and evolution applied to, the Active Pokémon only;
* attack costs are checked by Energy count, not type; Weakness and Resistance are absent;
* Knock Outs are separate moves that must all be taken before the turn can end, rather than
  being checked at the rulebook's fixed points; only Active Pokémon can be Knocked Out, which
  suffices while no effect damages the Bench; a Knock Out always gives exactly one Prize;
  until its Knock Out is taken, a Pokémon at or above its HP stays in play and can still be
  affected: in particular, the player's own Active Pokémon, after evolving into a card with
  less HP or taking 3 counters from Confusion, can still attack, take Energy, or be healed
  back below its HP (the rulebook would Knock it Out at once, or at the end of the attack);
* HP is the printed value: there are no HP modifiers (the survey's loophole L1);
* there are no markers (Imprison, Shock-wave), which the survey found to be uncapped counts;
* effects cannot read the state: no "for each" counts, no full-HP or zero tests, and no
  lingering "this turn" modifiers, so the interface a counter machine needs is absent by
  construction, not by theorem;
* an attack does not end the turn; the first player may play a Supporter on the first turn;
  each player has their own Stadium slot;
* Special Conditions: effects apply them only to the opponent's Active Pokémon (`inflict`) and
  remove them only from the player's own Active Pokémon (`cure`); the variants with a number
  ("put 2 damage counters instead of 1 on the Poisoned Pokémon") are absent; poisoning a
  Pokémon that is already Poisoned keeps its `poisonUp` (no ruling was found either way);
  Croagunk's cumulative increase is modelled as a number on the Pokémon (`poisonUp`) that
  lasts until Poison ends, not as a lingering effect; a Confused Pokémon whose flip is tails
  uses up the turn's attack, and its attack must be one it could otherwise use;
* Pokémon Checkup (Poison, Burn, Sleep, Paralysis recovery) is absent: Special Conditions are
  applied, stop attacks and retreats, and Confusion is resolved, but they have no
  between-turns effect;
* Stadium and Tool cards occupy state but have no move; Abilities are absent;
* start states are not required to be well formed; from a `WellFormed` start no reachable
  state without a winner is stuck (`Reach.progress`), but from other starts (e.g. no winner and
  an empty Prize list) a pending Knock Out may be impossible to take;
* the "no evolving on your first turn" rule is applied to the first turn of the game only.
-/

namespace Pokemon

/-- No Knock Out is pending: every Pokémon in play has fewer damage counters than its HP.
`endTurn` requires it. It is NOT an invariant of all reachable states (`counters_unbounded`);
`Damage` proves it at turn boundaries and bounds damage elsewhere. -/
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

inductive Move : GameState → GameState → Prop where
  /-- put a Basic Pokémon from hand onto the Bench -/
  | playBasic {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂)
      (hs : p.stage = .basic) (hhp : 0 < p.hp)
      (hb : g.cur.bench.length < benchLimit) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, bench := g.cur.bench ++ [InPlay.ofBasic p] } }
  /-- attach one Energy card from hand to the Active Pokémon, once per turn -/
  | attach {g : GameState} {l₁ l₂ : List Card} {t : EType} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.energy t :: l₂)
      (hf : g.cur.energyAttached = false) (ha : g.cur.active = some a) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, energyAttached := true,
        active := some { a with energy := Card.energy t :: a.energy } } }
  /-- evolve the Active Pokémon; Special Conditions are removed -/
  | evolve {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (ha : g.cur.active = some a)
      (he : p.evolvesFrom = some a.top.name) (hfr : a.fresh = false)
      (hf : g.firstTurn = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂,
        active := some { a with
          top := p, under := Card.pokemon a.top :: a.under,
          rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true } } }
  /-- retreat: discard Energy equal to the retreat cost and swap with a Benched Pokémon -/
  | retreat {g : GameState} {a q : InPlay} {b₁ b₂ : List InPlay} {paid rest : List Card}
      (ha : g.cur.active = some a) (hb : g.cur.bench = b₁ ++ q :: b₂)
      (hr : g.cur.retreated = false) (he : a.energy = paid ++ rest)
      (hp : paid.length = a.top.retreat) (hk : a.damage < a.top.hp)
      (hs : a.rot.canAct = true) :
      Move g { g with cur := { g.cur with
        active := some q,
        bench := b₁ ++ { a with
          energy := rest, rot := .none, poisoned := false, burned := false, poisonUp := 0 } :: b₂,
        discard := paid ++ g.cur.discard, retreated := true } }
  /-- play an Item card: it goes to the discard pile and its effect resolves -/
  | item {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .item e :: l₂)
      (hr : Run e { g with cur := { g.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } g') :
      Move g g'
  /-- play a Supporter card, once per turn -/
  | supporter {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .supporter e :: l₂)
      (hs : g.cur.supporterPlayed = false)
      (hr : Run e { g with cur := { g.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g.cur.discard } } g') :
      Move g g'
  /-- attack: place the base damage, then resolve the attack's effect. An Asleep or
  Paralyzed Pokémon cannot attack; a Confused one can, when its coin flip is heads. -/
  | attack {g g' : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks)
      (hc : atk.cost.length ≤ a.energy.length) (hs : a.rot.canAct = true)
      (hn : g.attacked = false) (hf : g.firstTurn = false)
      (hr : Run (.seq (.counters atk.damage) atk.effect) g g') :
      Move g { g' with attacked := true }
  /-- a Confused Pokémon tries to attack and the coin flip is tails: the attack does not
  happen, and the attacker gets 3 damage counters -/
  | attackConfused {g : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks)
      (hc : atk.cost.length ≤ a.energy.length) (hs : a.rot = .confused)
      (hn : g.attacked = false) (hf : g.firstTurn = false) :
      Move g { g with
        cur := { g.cur with active := some { a with damage := a.damage + 3 } },
        attacked := true }
  /-- Knock Out the opponent's Active Pokémon and take a Prize card -/
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
  /-- Knock Out the player's own Active Pokémon (e.g. after evolving into a card with
  less HP); the opponent takes a Prize card -/
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
  /-- end the turn; the opponent draws. Requires both Active Pokémon and no pending
  Knock Out anywhere. -/
  | endTurn {g : GameState} {a b : InPlay} {c : Card} {d : List Card}
      (ha : g.opp.active = some a) (hb : g.cur.active = some b) (hk : DamageBounded g)
      (hd : g.opp.deck = c :: d) :
      Move g
        { cur := { g.opp with
            deck := d, hand := c :: g.opp.hand,
            energyAttached := false, supporterPlayed := false, retreated := false },
          opp := g.cur.unfresh,
          curIsFirst := !g.curIsFirst, firstTurn := false, attacked := false,
          winner := g.winner }
  /-- end the turn; the opponent cannot draw and loses -/
  | deckOut {g : GameState} {a b : InPlay}
      (ha : g.opp.active = some a) (hb : g.cur.active = some b) (hk : DamageBounded g)
      (hd : g.opp.deck = []) :
      Move g { g with winner := some g.curIsFirst }

/-- Reachability by legal play. No move is made once the game has a winner. -/
inductive Reach : GameState → GameState → Prop where
  | refl (g : GameState) : Reach g g
  | step {g₀ g g' : GameState} : Reach g₀ g → g.winner = none → Move g g' → Reach g₀ g'

end Pokemon
