import Pokemon.Bounded
import Pokemon.Counter
import Pokemon.Turn

/-!
# Faithful decks: the stores stay bounded, so the exact-store quotient is finite

`Pokemon/Bounded.lean` proves finiteness up to `xclamp` on the reachable states whose stores are
bounded. This file gives a condition on the deck under which every reachable state has bounded
stores, at a bound computed from the start state, and so finiteness for those decks without
further hypothesis.

**The deck condition** (`GameState.Faithful`, on the cards of the start state; play only
permutes cards, so it holds all game):
* `LoopFree` (clause 1): no effect, of an attack, a Trainer card or (milestone M8a) an Ability,
  contains a damage bonus or damage reduction (`linger … (bonus n)`, `linger … (reduce n)`) under
  `iter`. Locks and prevention may appear anywhere; they are flags.
* `GXOnly` (clause 2): every attack whose effect can write a rest-of-game damage bonus or
  reduction (`Slot.always`) is a GX attack (`Attack.gx`).
* `RecycleSafe` (clause 3, milestone MV): (a) no Trainer card's effect and (milestone M8a) no
  "as often as you like" Ability (`Card.freeRec`) can return from a discard pile to a hand or deck
  a card of the game that is not a Supporter and writes a damage bonus or reduction; (b) no effect
  at all, attacks and Abilities included, can return a Trainer card that writes a rest-of-game
  bonus or reduction. "Can return":
  the filter of one of its zone moves out of a discard pile admits the card. Attacks may recycle
  every other card (an attack ends the turn), and Energy and Pokémon cards may be recycled by any
  effect (they write nothing when played). Decidable. A deck with no recycling satisfies it
  (`GameState.NoRecycle.recycleSafe`), so for such decks `Faithful` means what it meant before
  milestone MV. Survey S10 §5 proposes property P ("no in-turn effect may return a non-Supporter
  modifier writer from the discard pile or from play to hand or deck; no Stadium of either deck
  either"); in the model's vocabulary (no Stadium play, no return from play) clause 3 (a) is P
  for Trainer effects, quantified over the cards of both decks together, extended to
  "as often as you like" Abilities but not to once-per-turn or on-play ones, which P covers and
  which the potential `abPot` bounds per turn instead (clause 4 only forbids their rest-of-game
  writes); clause 3 (b), which P lacks, is vacuous for every deck with no
  rest-of-game Trainer writer (all of today's Standard, survey S9 N3).
* `AbilitySafe` (clause 4, milestone M8a): no "as often as you like" Ability writes a damage bonus
  or reduction, and no Ability writes a rest-of-game one. Decidable; every deck without Abilities
  satisfies it.
* `StadiumSafe` (clause 5, milestone M5): no Stadium's effect writes a rest-of-game damage bonus
  or reduction. Decidable; every deck without Stadium cards satisfies it. Since milestone M5
  clause 3 also treats Stadiums differently: a Stadium card is not a writer that clause 3 (a)
  protects (playing it writes nothing; `Card.wAmt`, `Card.alAmt`), and a Stadium's effect is not
  a free recycler (`Card.freeRec`): its uses are bounded per turn instead. For a deck without
  Stadium cards clauses 3 and 5 say what they said before (`Pokemon/NoStadiums.lean`).

**Why it bounds the stores** (milestone MV: a per-turn count). Each resolution of a loop-free
effect `e` adds at most `e.amtAt s` to the amounts in slot `s` (`Run.slot_le`, `TRun.slot_le`).
The writers are:
* Item and Supporter cards. Within one turn, before the turn's attack, no effect returns a
  non-Supporter writer from a discard pile (clause 3 (a); `Run.disc_mono`: the writer weight of the
  discard piles does not drop), so each such card is played at most once in the turn, and at most
  one Supporter is played; so Trainers write at most `2 P` in one turn (`P = cardsAmt` of the
  cards). An attack may recycle a writer, but it ends the turn. Carried amounts expire within
  three turn boundaries (`Store.shift`), so at most three turns' Trainer writes are live. The
  rest-of-game slot holds only amounts of writers in the discard piles, which no effect recycles
  (clause 3 (b)), and of GX attacks.
* Abilities (milestone M8a). An "as often as you like" Ability writes nothing (clause 4) and
  recycles no writer (clause 3 (a)), so it is a step that keeps the count. Each use of a "once
  during your turn" Ability by a Pokémon that has not used one, and each on-play trigger, spends at
  least one unit of a potential of the player to move (`GameState.abPot`: their Pokémon in play
  not yet used, still able to evolve, the free places in play, and the opponent's Prize cards),
  which no move of the turn raises and which is at most `potBound` of the number of cards; each
  such use writes and recycles at most `Q` (`Ability.q`, `cardsAbQ`). The bound rests on there
  being no effect that returns a Pokémon in play to the hand or deck: a Pokémon leaves play only
  by a Knock Out, which costs a Prize card.
* Stadium effects (milestone M5). The player to move uses the Stadium in play at most once
  (`GameState.stadiumUsed`) and plays at most one Stadium (`GameState.stadiumPlayed`), whose effect
  is then usable once more; both flags are cleared at the end of the turn. So a turn has at most
  two Stadium uses (`GameState.stPot`), each writing and recycling at most `R` (`Card.stQ`,
  `cardsStQ`). A rest-of-game write by a Stadium would recur every turn (clause 5).
* Attacks. At most one attack per turn (`GameState.attacked`, reset only by `endTurn`), each
  writing at most `A = cardsAtkAmt` (the largest attack amount among the cards); three attacks'
  carried amounts at once; rest-of-game amounts only from GX attacks (clause 2), once per player per
  game.

Before milestone MV nothing left a discard pile, each Trainer card was played at most once per
game, and the bound counted the Trainer amounts once (`storeBoundNR`); that proof is kept for decks
that recycle nothing (`reach_boundedStores_noRecycle`). With recycling the per-game count is false:
`Recycle.recycling_breaks_bound` gives a deck satisfying clauses 1 and 2, violating clause 3, with
unbounded stores and infinitely many `xclamp` classes.

The per-turn invariant (`Faithful.TInv`) has as witnesses the Trainer and Ability amounts written
this turn, last turn and the turn before, the writer weight of the discard piles at the start of the
turn, and (milestone M8a) the potential at the start of the turn. `Faithful.reach_boundedStores`
concludes `BoundedStores (storeBound g₀)` for every reachable state, with `storeBound g₀ =
storeTotal g₀ + 6 · cardsAmt C + 3 · (Q · potBound |C|) + 3 · cardsAtkAmt C` (`C` the cards of
`g₀`, `Q = cardsAbQ (cardsAmt C) C`, which is 0 for a deck without Abilities).

**Results.**
* `Faithful.reach_boundedStores`: for a start satisfying `Faithful`, every reachable state has
  stores bounded by `storeBound g₀`.
* `Faithful.reach_boundedStores_noRecycle`: for a start satisfying clauses 1 and 2 whose cards
  recycle nothing and (milestone M8a) whose Abilities write nothing (`AbilityQuiet`), the bound of
  master, `storeBoundNR g₀ = storeTotal g₀ + cardsAmt C + 3 · cardsAtkAmt C`.
* `Faithful.xfinite`: from any `Faithful` start (well-formed or not), the `xclamp`s of all reachable states
  lie in one finite list, and the kernel of `xclamp` is a two-way bisimulation along reachable
  states. No tameness: damage reduction (Iron Defender), `drain`, carried bonuses and
  reductions, rest-of-game modifiers from GX attacks, and recycling within clause 3 are allowed.
* `Pokemon/Dichotomy.lean`: the two-counter starts of `Pokemon/Counter.lean` satisfy clauses 1
  and 3 and, when the machine's first instruction is not `halt`, violate clause 2
  (`Faithful.counter_loopFree`, `Faithful.counter_recycleSafe`, `Faithful.counter_not_gxOnly`).
* `Pokemon/Recycle.lean`: clause 3 cannot be dropped (`Recycle.recycling_breaks_bound`).
* `Pokemon/Abilities.lean` (milestone M8a): clause 4 cannot be dropped, nor clause 3 (a) for
  Abilities (`Abilities.unlimited_writer_breaks_bound`, `Abilities.unlimited_recycler_breaks_bound`);
  a once-per-turn recycler of a writer is faithful (`Abilities.once_recycler_faithful`), and so is
  a deck with Feraligatr's once-per-turn bonus (`Abilities.feraligatr_faithful`).

**Which theorem applies.** `Reach.finite` (`Pokemon/Finite.lean`) needs tame cards (no damage
reduction, no `drain`) and no reduction in effect at the start; it allows bonus writes under
`iter` and rest-of-game bonuses in attacks that are not GX attacks, and its quotient is coarser
(the clamp caps stored bonuses). `Faithful.xfinite` allows damage reduction, `drain`, carried
modifiers and Trainer modifiers; it forbids amounts written under `iter` and rest-of-game
amounts written by attacks that are not GX attacks, and its quotient is finer (the stores are
kept exact). Neither class contains the other; for decks in both, both theorems apply.

**Rule change** (in `Pokemon/Rules.lean` and `Pokemon/Card.lean`): `Attack` has a new field
`gx`; `Move.attack` requires `atk.gx = true → g.cur.gxUsed = false` and sets the attacker's
`gxUsed` when `atk.gx` (the result's `gxUsed` is `atk.gx || gxUsed`). `Move.attackConfused`
(the failed attempt of a Confused Pokémon) has the same premise and leaves `gxUsed` unchanged
(an unverified ruling; see the Known gaps in `Pokemon/Rules.lean`). Before, `gxUsed` was never
read or written. Every theorem that mentions attacks was re-proved; `Counter.universal` is
unchanged in statement (its attacks have `gx = false`).

**What the condition does not cover.** Printed behaviours outside it, or outside the model:
* static and triggered Abilities other than on-play ones (milestone M8b), and static Stadium and
  Tool effects (HP, damage and Retreat Cost modifiers, Bench size, Ability and Tool locks: a later
  milestone; the model plays such cards with no effect);
* returning a card from play to the hand or deck (Scoop Up Cyclone, and the Abilities of Abra,
  Dudunsparce and Misty's Psyduck) and devolution are not in the model; with them a Pokémon card
  could re-enter play within a turn, and the potential that bounds Ability uses would need
  another argument;
* the model lets a played Item or Supporter recycle itself (it is in the discard pile while its
  effect resolves; the rulebook discards it afterwards); clause 3 (a) covers that case, since it
  constrains every return from the discard pile;
* "attack twice", "attack again" after a Knock Out, and "take another turn" are not modelled;
  with them more than one attack's amounts would be written per turn;
* the Poet's guess-and-verify coupling (one replayable effect writing a this-turn and a carried
  modifier together) is excluded inside one effect by clause 1 and across effects by the per-turn
  count: within a turn each non-Supporter writer is played at most once and one Supporter at most;
  survey S10 §0 found no printed card that writes modifiers of two durations together;
* rest-of-game modifiers from VSTAR Powers are not modelled (`vstarUsed` is unused); from
  Abilities they are outside clause 4, from Stadium effects outside clause 5;
* copy attacks are not modelled; the once-per-game rule and clause 2 are stated for the attacks
  printed on the attacker;
* static modifiers, and modifiers from Pokémon Tools, static Abilities or Special Energy, are not
  modelled: every modifier here is written by an effect when it resolves;
* reductions restricted by type are not modelled: printed Iron Defender protects Metal Pokémon
  only, whereas the model's reduction protects all of a player's Pokémon;
* effects that lock GX attacks are not modelled.

The store bound rests on: at most one attack per turn, no extra turns, clause 3 for recycling,
clause 4 for "as often as you like" Abilities, clause 5 and the once-per-turn and one-play-per-turn
Stadium rules for Stadium effects, and the absence of returns from play.
-/

namespace Pokemon

/-! ## Amounts written by effects -/

/-- The amount a modifier adds to a store: a bonus or a reduction counts, a flag does not. -/
def Mod.amt : Mod → Nat
  | .bonus n => n
  | .reduce n => n
  | _ => 0

/-- Does the modifier carry an amount (a damage bonus or reduction)? -/
def Mod.isAmt : Mod → Bool
  | .bonus _ => true
  | .reduce _ => true
  | _ => false

theorem Mod.amt_of_not_isAmt {m : Mod} (h : m.isAmt = false) : m.amt = 0 := by
  cases m <;> first | rfl | cases h

/-- Does the effect contain a damage bonus or reduction anywhere? -/
def Effect.writes : Effect → Bool
  | .linger _ _ m => m.isAmt
  | .ite _ a b => a.writes || b.writes
  | .seq a b => a.writes || b.writes
  | .choice a b => a.writes || b.writes
  | .iter a => a.writes
  | _ => false

/-- **Clause 1, for one effect**: no damage bonus or reduction under `iter`. -/
def Effect.loopFree : Effect → Bool
  | .ite _ a b => a.loopFree && b.loopFree
  | .seq a b => a.loopFree && b.loopFree
  | .choice a b => a.loopFree && b.loopFree
  | .iter a => !a.writes
  | _ => true

/-- The largest amount one resolution of a loop-free effect adds to slot `s` (both players
together): sums along `seq`, the larger branch of `ite` and `choice`, nothing under `iter`. -/
def Effect.amtAt (s : Slot) : Effect → Nat
  | .linger _ s' m => if s' = s then m.amt else 0
  | .ite _ a b => max (a.amtAt s) (b.amtAt s)
  | .seq a b => a.amtAt s + b.amtAt s
  | .choice a b => max (a.amtAt s) (b.amtAt s)
  | _ => 0

/-- The amount over all four slots. -/
def Effect.amt (e : Effect) : Nat :=
  e.amtAt .now + e.amtAt .next + e.amtAt .after + e.amtAt .always

/-- The script of an attack writes what its effect writes: the base damage writes nothing. -/
theorem Attack.script_loopFree (atk : Attack) : atk.script.loopFree = atk.effect.loopFree := by
  unfold Attack.script
  split
  · rfl
  · simp only [Effect.loopFree, Bool.true_and]

theorem Attack.script_amtAt (atk : Attack) (s : Slot) :
    atk.script.amtAt s = atk.effect.amtAt s := by
  unfold Attack.script
  split
  · rfl
  · simp only [Effect.amtAt, Nat.zero_add]

theorem Effect.amtAt_le_amt (e : Effect) (s : Slot) : e.amtAt s ≤ e.amt := by
  cases s <;> simp only [Effect.amt] <;> omega

/-! ## Amounts in the stores -/

/-- The amount in one turn's modifiers. -/
def Mods.amt (m : Mods) : Nat := m.bonus + m.reduce

/-- One slot of a store. -/
def Store.at : Slot → Store → Mods
  | .now, t => t.now
  | .next, t => t.next
  | .after, t => t.after
  | .always, t => t.always

/-- The amounts in slot `s`, both players together. -/
def GameState.slotAmt (s : Slot) (g : GameState) : Nat :=
  (g.cur.mods.at s).amt + (g.opp.mods.at s).amt

/-- The amounts in all slots of both stores. -/
def GameState.storeTotal (g : GameState) : Nat :=
  g.slotAmt .now + g.slotAmt .next + g.slotAmt .after + g.slotAmt .always

theorem Mods.amt_addMod (m : Mods) (x : Mod) : (m.addMod x).amt = m.amt + x.amt := by
  cases x with
  | bonus n => simp only [Mods.addMod, Mods.amt, Mod.amt]; omega
  | reduce n => simp only [Mods.addMod, Mods.amt, Mod.amt]; omega
  | prevent => rfl
  | lock l => cases l <;> rfl

theorem Store.at_add (t : Store) (s s' : Slot) (x : Mod) :
    (t.add s x).at s' = if s = s' then (t.at s').addMod x else t.at s' := by
  cases s <;> cases s' <;> rfl

theorem GameState.slotAmt_linger (g : GameState) (w : Whose) (s s' : Slot) (m : Mod) :
    (g.updSide w fun p => { p with mods := p.mods.add s m }).slotAmt s' =
      g.slotAmt s' + (if s = s' then m.amt else 0) := by
  cases w <;> by_cases hs : s = s' <;>
    simp only [GameState.updSide, GameState.slotAmt, Store.at_add, hs, ite_true, ite_false,
      Mods.amt_addMod] <;> omega

/-! ## Amounts on cards, and the discard piles -/

/-- The amount a card's effect can write when it is played: a Trainer card's effect amount;
nothing for other cards (attacks are counted separately). -/
def Card.amt : Card → Nat
  | .trainer _ _ e => e.amt
  | _ => 0

def cardsAmt : List Card → Nat
  | [] => 0
  | c :: cs => c.amt + cardsAmt cs

theorem cardsAmt_append (l₁ l₂ : List Card) : cardsAmt (l₁ ++ l₂) = cardsAmt l₁ + cardsAmt l₂ := by
  induction l₁ with
  | nil => simp only [List.nil_append, cardsAmt]; omega
  | cons c cs ih => simp only [List.cons_append, cardsAmt, ih]; omega

theorem cardsAmt_perm {l l' : List Card} (h : l.Perm l') : cardsAmt l = cardsAmt l' := by
  induction h with
  | nil => rfl
  | cons x _ ih => simp only [cardsAmt, ih]
  | swap x y l => simp only [cardsAmt]; omega
  | trans _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/-- The Trainer amounts in both discard piles. -/
def GameState.discAmt (g : GameState) : Nat := cardsAmt g.cur.discard + cardsAmt g.opp.discard

theorem GameState.discAmt_le (g : GameState) : g.discAmt ≤ cardsAmt g.allCards := by
  simp only [GameState.discAmt, GameState.allCards, PlayerState.allCards, cardsAmt_append]
  omega

/-! ## Attacks -/

def attacksAmt : List Attack → Nat
  | [] => 0
  | a :: as => max a.effect.amt (attacksAmt as)

/-- The largest amount one attack of a card (a Pokémon card's, or since milestone M5 one a Tool
gives) can write. -/
def Card.atkAmt (c : Card) : Nat := attacksAmt c.attacks

/-- The largest amount one attack among the cards `C` can write. -/
def cardsAtkAmt : List Card → Nat
  | [] => 0
  | c :: cs => max c.atkAmt (cardsAtkAmt cs)

theorem attacksAmt_mem {atk : Attack} : ∀ {as : List Attack}, atk ∈ as →
    atk.effect.amt ≤ attacksAmt as
  | a :: as, hm => by
      simp only [attacksAmt]
      cases hm with
      | head => omega
      | tail _ hm => have := attacksAmt_mem hm; omega

theorem atkAmt_le_cardsAtkAmt {x : Card} : ∀ {cs : List Card}, x ∈ cs → x.atkAmt ≤ cardsAtkAmt cs
  | [], h => nomatch h
  | c :: cs, h => by
      cases h with
      | head => simp only [cardsAtkAmt]; omega
      | tail _ h =>
          have := atkAmt_le_cardsAtkAmt h
          simp only [cardsAtkAmt]; omega

/-! ## The deck condition -/

/-- Clause 1 for one card: every effect on it is loop-free (since milestone M8a, its Abilities'
effects included). -/
def Card.loopFree : Card → Bool
  | .pokemon p => (p.attacks.all fun a => a.effect.loopFree) &&
      p.abilities.all fun a => a.scripts.all fun e => e.loopFree
  | .energy _ => true
  | .trainer _ _ e => e.loopFree
  | .tool _ gr => (gr.attacks.all fun a => a.effect.loopFree) &&
      gr.abilities.all fun a => a.scripts.all fun e => e.loopFree

/-- **Clause 1** (`LoopFree`): no effect of any card in the game (attacks, Trainer cards and,
since milestone M8a, Abilities) has a damage bonus or reduction under `iter`. -/
def GameState.LoopFree (g : GameState) : Prop := ∀ x ∈ g.allCards, x.loopFree = true

/-- **Clause 2** (`GXOnly`): an attack that is not a GX attack writes no rest-of-game damage
bonus or reduction (since milestone M5 the attacks of every card are read, `Card.attacks`: a
Pokémon card's and those a Tool gives). -/
def GameState.GXOnly (g : GameState) : Prop :=
  ∀ c ∈ g.allCards, ∀ atk ∈ c.attacks, atk.gx = false → atk.effect.amtAt .always = 0

theorem Card.loopFree_attack {c : Card} (h : c.loopFree = true)
    {atk : Attack} (hm : atk ∈ c.attacks) : atk.effect.loopFree = true := by
  cases c with
  | pokemon p =>
      simp only [Card.loopFree, Bool.and_eq_true] at h
      exact List.all_eq_true.1 h.1 atk hm
  | tool n gr =>
      simp only [Card.loopFree, Bool.and_eq_true] at h
      exact List.all_eq_true.1 h.1 atk hm
  | _ => nomatch hm

theorem Card.loopFree_ability {c : Card} (h : c.loopFree = true)
    {ab : Ability} (hm : ab ∈ c.abilities) {e : Effect} (he : e ∈ ab.scripts) :
    e.loopFree = true := by
  cases c with
  | pokemon p =>
      simp only [Card.loopFree, Bool.and_eq_true] at h
      exact List.all_eq_true.1 (List.all_eq_true.1 h.2 ab hm) e he
  | tool n gr =>
      simp only [Card.loopFree, Bool.and_eq_true] at h
      exact List.all_eq_true.1 (List.all_eq_true.1 h.2 ab hm) e he
  | _ => nomatch hm

theorem GameState.LoopFree.of_perm {g g' : GameState} (h : g.LoopFree)
    (hp : g'.allCards.Perm g.allCards) : g'.LoopFree :=
  fun x hx => h x (hp.mem_iff.1 hx)

/-- A game in which no card has or gives an attack satisfies clause 2. -/
theorem GameState.GXOnly.of_noAttacks {g : GameState} (h : ∀ c ∈ g.allCards, c.attacks = []) :
    g.GXOnly :=
  fun c hc atk hm => by rw [h c hc] at hm; nomatch hm

theorem GameState.GXOnly.of_perm {g g' : GameState} (h : g.GXOnly)
    (hp : g'.allCards.Perm g.allCards) : g'.GXOnly :=
  fun c hx => h c (hp.mem_iff.1 hx)

/-! ## What one resolution writes -/

/-- An effect with no damage bonus or reduction adds nothing to any slot. -/
theorem Run.slot_nowrite {e : Effect} {g g' : GameState} (h : Run e g g') :
    e.writes = false → ∀ s, g'.slotAmt s ≤ g.slotAmt s := by
  induction h with
  | iteT _ _ _ ih =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw; exact ih hw.1 s
  | iteF _ _ _ ih =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw; exact ih hw.2 s
  | seq _ _ ih₁ ih₂ =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw
      exact Nat.le_trans (ih₂ hw.2 s) (ih₁ hw.1 s)
  | choiceL _ ih =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw; exact ih hw.1 s
  | choiceR _ ih =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw; exact ih hw.2 s
  | iterNil => intro _ s; exact Nat.le_refl _
  | iterCons _ _ ih₁ ih₂ => intro hw s; exact Nat.le_trans (ih₂ hw s) (ih₁ hw s)
  | @touchActive e w f g p he h => intro _ s; cases w <;> exact Nat.le_refl _
  | @touchBench e w f g q b₁ b₂ he h => intro _ s; cases w <;> exact Nat.le_refl _
  | unmark w m g => intro _ s; cases w <;> exact Nat.le_refl _
  | benchCounters w n h => intro _ s; cases w <;> exact Nat.le_refl _
  | spreadCounters w n g => intro _ s; cases w <;> exact Nat.le_refl _
  | switch w ha hb => intro _ s; cases w <;> exact Nat.le_refl _
  | benchDamage w n h => intro _ s; cases w <;> exact Nat.le_refl _
  | spreadDamage w n g => intro _ s; cases w <;> exact Nat.le_refl _
  | @zone e w g s' hw hz => intro _ s; cases w <;> exact Nat.le_refl _
  | linger w s m g =>
      intro hw s'
      rw [GameState.slotAmt_linger, Mod.amt_of_not_isAmt hw]
      simp only [ite_self, Nat.add_zero]; exact Nat.le_refl _
  | _ => intro _ s; exact Nat.le_refl _

/-- **One resolution of a loop-free effect adds at most `e.amtAt s` to slot `s`.** -/
theorem Run.slot_le {e : Effect} {g g' : GameState} (h : Run e g g') :
    e.loopFree = true → ∀ s, g'.slotAmt s ≤ g.slotAmt s + e.amtAt s := by
  induction h with
  | iteT _ _ _ ih =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih hb.1 s; simp only [Effect.amtAt]; omega
  | iteF _ _ _ ih =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih hb.2 s; simp only [Effect.amtAt]; omega
  | seq _ _ ih₁ ih₂ =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih₁ hb.1 s; have := ih₂ hb.2 s; simp only [Effect.amtAt]; omega
  | choiceL _ ih =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih hb.1 s; simp only [Effect.amtAt]; omega
  | choiceR _ ih =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih hb.2 s; simp only [Effect.amtAt]; omega
  | iterNil => intro _ s; exact Nat.le_add_right _ _
  | iterCons h₁ h₂ _ _ =>
      intro hb s
      simp only [Effect.loopFree, Bool.not_eq_eq_eq_not, Bool.not_true] at hb
      have e₁ := h₁.slot_nowrite hb s
      have e₂ := h₂.slot_nowrite (by simp only [Effect.writes]; exact hb) s
      exact Nat.le_trans (Nat.le_trans e₂ e₁) (Nat.le_add_right _ _)
  | @touchActive e w f g p he h => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | @touchBench e w f g q b₁ b₂ he h => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | unmark w m g => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | benchCounters w n h => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | spreadCounters w n g => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | switch w ha hb => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | benchDamage w n h => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | spreadDamage w n g => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | @zone e w g s' hw hz => intro _ s; cases w <;> exact Nat.le_add_right _ _
  | linger w s m g =>
      intro _ s'
      rw [GameState.slotAmt_linger]
      exact Nat.le_refl _
  | _ => intro _ s; exact Nat.le_add_right _ _

/-! ## Weights of discarded cards, and recycling (milestone MV) -/

/-- The sum of a weight over a list of cards. -/
def wsum (w : Card → Nat) : List Card → Nat
  | [] => 0
  | c :: cs => w c + wsum w cs

theorem wsum_append (w : Card → Nat) (l₁ l₂ : List Card) :
    wsum w (l₁ ++ l₂) = wsum w l₁ + wsum w l₂ := by
  induction l₁ with
  | nil => simp only [List.nil_append, wsum]; omega
  | cons c cs ih => simp only [List.cons_append, wsum, ih]; omega

theorem wsum_le (w w' : Card → Nat) (h : ∀ c, w c ≤ w' c) : ∀ l, wsum w l ≤ wsum w' l
  | [] => Nat.le_refl _
  | c :: cs => by
      have := h c; have := wsum_le w w' h cs; simp only [wsum]; omega

theorem wsum_zero (w : Card → Nat) : ∀ {l : List Card}, (∀ x ∈ l, w x = 0) → wsum w l = 0
  | [], _ => rfl
  | c :: cs, h => by
      simp only [wsum, h c (.head _), wsum_zero w (fun x hx => h x (.tail _ hx))]

theorem cardsAmt_eq (l : List Card) : cardsAmt l = wsum Card.amt l := by
  induction l with
  | nil => rfl
  | cons c cs ih => simp only [cardsAmt, wsum, ih]

theorem amt_le_cardsAmt {x : Card} : ∀ {l : List Card}, x ∈ l → x.amt ≤ cardsAmt l
  | _ :: _, .head _ => by simp only [cardsAmt]; omega
  | _ :: _, .tail _ h => by have := amt_le_cardsAmt h; simp only [cardsAmt]; omega

theorem Split.wsum_eq {f : Filter} {l t r : List Card} (h : Split f l t r) (w : Card → Nat) :
    Pokemon.wsum w l = Pokemon.wsum w t + Pokemon.wsum w r := by
  induction h with
  | nil => rfl
  | take _ _ ih => simp only [Pokemon.wsum, ih]; omega
  | keep _ ih => simp only [Pokemon.wsum, ih]; omega

/-- A weight carried only by Trainer cards. -/
def TrainerWeight (w : Card → Nat) : Prop :=
  (∀ t, w (.energy t) = 0) ∧ ∀ p, w (.pokemon p) = 0

/-- The weight of both discard piles. -/
def GameState.discW (w : Card → Nat) (g : GameState) : Nat :=
  wsum w g.cur.discard + wsum w g.opp.discard

theorem GameState.discAmt_eq (g : GameState) : g.discAmt = g.discW Card.amt := by
  simp only [GameState.discAmt, GameState.discW, cardsAmt_eq]

theorem Card.amt_tw : TrainerWeight Card.amt := ⟨fun _ => rfl, fun _ => rfl⟩

/-- The filters of an effect's zone moves out of a discard pile: what it can recycle to the hand
or the deck. (Attaching Energy or benching a Basic Pokémon from a discard pile moves an Energy or
a Pokémon card, which carries no Trainer amount.) -/
def Effect.recFilters : Effect → List Filter
  | .move _ .discard _ f _ => [f]
  | .ite _ a b => a.recFilters ++ b.recFilters
  | .seq a b => a.recFilters ++ b.recFilters
  | .choice a b => a.recFilters ++ b.recFilters
  | .iter a => a.recFilters
  | _ => []

/-- `e` recycles no card of `C` that has weight `w`. -/
def Effect.RecOk (w : Card → Nat) (C : List Card) (e : Effect) : Prop :=
  ∀ f ∈ e.recFilters, ∀ y ∈ C, f.eval y = true → w y = 0

theorem Effect.RecOk.left {w : Card → Nat} {C : List Card} {a b : Effect}
    (h : ∀ f ∈ a.recFilters ++ b.recFilters, ∀ y ∈ C, f.eval y = true → w y = 0) : a.RecOk w C :=
  fun f hf => h f (List.mem_append_left _ hf)

theorem Effect.RecOk.right {w : Card → Nat} {C : List Card} {a b : Effect}
    (h : ∀ f ∈ a.recFilters ++ b.recFilters, ∀ y ∈ C, f.eval y = true → w y = 0) : b.RecOk w C :=
  fun f hf => h f (List.mem_append_right _ hf)

theorem Effect.recOk_nil {w : Card → Nat} {C : List Card} {e : Effect} (h : e.recFilters = []) :
    e.RecOk w C := fun f hf => by rw [h] at hf; nomatch hf

theorem Put.wsum_discard (w : Card → Nat) {d : Dst} {t : List Card} {x y : PlayerState}
    (h : Put d t x y) : wsum w x.discard ≤ wsum w y.discard := by
  cases h <;> first | exact Nat.le_refl _ | (simp only [wsum_append]; omega)

/-- **A zone step lowers the weight of its player's discard pile only by recycling**: if every
card its recycling filters admit in that discard pile has weight 0, the weight does not drop. -/
theorem ZStep.disc_mono {w : Card → Nat} (hw : TrainerWeight w) {e : Effect} {s s' : PlayerState}
    (h : ZStep e s s')
    (hr : ∀ f ∈ e.recFilters, ∀ y ∈ s.discard, f.eval y = true → w y = 0) :
    wsum w s.discard ≤ wsum w s'.discard := by
  have src_ok : ∀ (src : Src) (f : Filter) (t r : List Card), Split f (src.get s) t r →
      (src = .discard → ∀ x ∈ t, w x = 0) → wsum w s.discard ≤ wsum w (src.set r s).discard := by
    intro src f t r hs hz
    cases src with
    | discard =>
        have := hs.wsum_eq w
        rw [wsum_zero w (hz rfl)] at this
        simp only [Src.get] at this
        simp only [Src.set]; omega
    | _ => exact Nat.le_refl _
  have one : ∀ (c : Card), w c = 0 → ∀ (src : Src) (x : Card), x ∈ [c] → src = .discard →
      w x = 0 := by
    intro c hc _ x hx _
    rw [List.mem_singleton] at hx; subst hx; exact hc
  cases h with
  | @move _ src dst f q _ _ t r hs hq hp =>
      refine Nat.le_trans (src_ok src f t r hs ?_) (hp.wsum_discard w)
      intro hsrc x hx
      subst hsrc
      exact hr f (.head _) x (hs.mem x hx) (hs.taken x hx)
  | @attachActive _ src f tf _ r t a hs ha ht =>
      exact src_ok src f _ r hs fun hsrc x hx => one _ (hw.1 t) src x hx hsrc
  | @attachBench _ src f tf _ r t q b₁ b₂ hs hb ht =>
      exact src_ok src f _ r hs fun hsrc x hx => one _ (hw.1 t) src x hx hsrc
  | @putBench _ src f _ r p hs hst hhp hb =>
      exact src_ok src f _ r hs fun hsrc x hx => one _ (hw.2 p) src x hx hsrc
  | discardActive => simp only [wsum_append]; omega
  | discardBench => simp only [wsum_append]; omega
  | toolsActive => simp only [wsum_append]; omega
  | toolsBench => simp only [wsum_append]; omega
  | _ => exact Nat.le_refl _

theorem GameState.mem_allCards_of_cur_discard {g : GameState} {x : Card} (hx : x ∈ g.cur.discard) :
    x ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, hx]

theorem GameState.mem_allCards_of_opp_discard {g : GameState} {x : Card} (hx : x ∈ g.opp.discard) :
    x ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, hx]

/-- **Resolving an effect lowers the weight of the discard piles only by recycling** a card
of weight: if `e` recycles no card of `C` of weight `w` and every card in the game is in `C`, the
weight of the discard piles does not drop. -/
theorem Run.disc_mono {w : Card → Nat} (hw : TrainerWeight w) {C : List Card} {e : Effect}
    {g g' : GameState} (h : Run e g g') :
    e.RecOk w C → (∀ y ∈ g.allCards, y ∈ C) → g.discW w ≤ g'.discW w := by
  induction h with
  | iteT _ _ _ ih => intro hr hC; exact ih (Effect.RecOk.left hr) hC
  | iteF _ _ _ ih => intro hr hC; exact ih (Effect.RecOk.right hr) hC
  | seq h₁ _ ih₁ ih₂ =>
      intro hr hC
      exact Nat.le_trans (ih₁ (Effect.RecOk.left hr) hC)
        (ih₂ (Effect.RecOk.right hr) fun y hy => hC y (h₁.perm.mem_iff.1 hy))
  | choiceL _ ih => intro hr hC; exact ih (Effect.RecOk.left hr) hC
  | choiceR _ ih => intro hr hC; exact ih (Effect.RecOk.right hr) hC
  | iterNil => intro _ _; exact Nat.le_refl _
  | iterCons h₁ _ ih₁ ih₂ =>
      intro hr hC
      exact Nat.le_trans (ih₁ hr hC) (ih₂ hr fun y hy => hC y (h₁.perm.mem_iff.1 hy))
  | @zone e w' g s' hw' hz =>
      intro hr hC
      cases w' with
      | own =>
          simp only [GameState.side] at hz
          have := hz.disc_mono hw fun f hf y hy hfy =>
            hr f hf y (hC y (GameState.mem_allCards_of_cur_discard hy)) hfy
          simp only [GameState.discW, GameState.updSide, PlayerState.setZones]; omega
      | opp =>
          simp only [GameState.side] at hz
          have := hz.disc_mono hw fun f hf y hy hfy =>
            hr f hf y (hC y (GameState.mem_allCards_of_opp_discard hy)) hfy
          simp only [GameState.discW, GameState.updSide, PlayerState.setZones]; omega
  | @touchActive e w f g p he h => intro _ _; cases w <;> exact Nat.le_refl _
  | @touchBench e w f g q b₁ b₂ he h => intro _ _; cases w <;> exact Nat.le_refl _
  | unmark w m g => intro _ _; cases w <;> exact Nat.le_refl _
  | benchCounters w n h => intro _ _; cases w <;> exact Nat.le_refl _
  | spreadCounters w n g => intro _ _; cases w <;> exact Nat.le_refl _
  | switch w ha hb => intro _ _; cases w <;> exact Nat.le_refl _
  | benchDamage w n h => intro _ _; cases w <;> exact Nat.le_refl _
  | spreadDamage w n g => intro _ _; cases w <;> exact Nat.le_refl _
  | linger w s m g => intro _ _; cases w <;> exact Nat.le_refl _
  | discardStadium g =>
      intro _ _; simp only [GameState.discW, wsum_append]; omega
  | _ => intro _ _; exact Nat.le_refl _

theorem KOMove.disc_mono (w : Card → Nat) {g g' : GameState} (h : KOMove g g') :
    g.discW w ≤ g'.discW w := by
  cases h <;>
    first
    | exact Nat.le_refl _
    | (simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)

theorem Resolve.disc_mono (w : Card → Nat) {g g' : GameState} (h : Resolve g g') :
    g.discW w ≤ g'.discW w := by
  induction h with
  | done => exact Nat.le_refl _
  | step _ hm _ ih => exact Nat.le_trans (hm.disc_mono w) ih

theorem TRun.disc_mono {w : Card → Nat} (hw : TrainerWeight w) {C : List Card} {e : Effect}
    {g g' : GameState} (h : TRun e g g') :
    e.RecOk w C → (∀ y ∈ g.allCards, y ∈ C) → g.discW w ≤ g'.discW w := by
  induction h with
  | prim _ _ hr hk => intro hc hC; exact Nat.le_trans (hr.disc_mono hw hc hC) (hk.disc_mono w)
  | stop => intro _ _; exact Nat.le_refl _
  | iteT _ _ _ _ ih => intro hr hC; exact ih (Effect.RecOk.left hr) hC
  | iteF _ _ _ _ ih => intro hr hC; exact ih (Effect.RecOk.right hr) hC
  | seq h₁ _ ih₁ ih₂ =>
      intro hr hC
      exact Nat.le_trans (ih₁ (Effect.RecOk.left hr) hC)
        (ih₂ (Effect.RecOk.right hr) fun y hy => hC y (h₁.perm.mem_iff.1 hy))
  | choiceL _ ih => intro hr hC; exact ih (Effect.RecOk.left hr) hC
  | choiceR _ ih => intro hr hC; exact ih (Effect.RecOk.right hr) hC
  | iterNil => intro _ _; exact Nat.le_refl _
  | iterCons h₁ _ ih₁ ih₂ =>
      intro hr hC
      exact Nat.le_trans (ih₁ hr hC) (ih₂ hr fun y hy => hC y (h₁.perm.mem_iff.1 hy))

/-! ## What else a resolution keeps -/

/-- The flags every resolution and every Knock Out keeps: `attacked` and the once-per-game flags. -/
structure Flags (g g' : GameState) : Prop where
  attacked : g'.attacked = g.attacked
  gxCur : g'.cur.gxUsed = g.cur.gxUsed
  gxOpp : g'.opp.gxUsed = g.opp.gxUsed

theorem Flags.trans {g₁ g₂ g₃ : GameState} (h₁ : Flags g₁ g₂) (h₂ : Flags g₂ g₃) : Flags g₁ g₃ :=
  ⟨h₂.attacked.trans h₁.attacked, h₂.gxCur.trans h₁.gxCur, h₂.gxOpp.trans h₁.gxOpp⟩

theorem Flags.refl (g : GameState) : Flags g g := ⟨rfl, rfl, rfl⟩

theorem Run.flags_keep {e : Effect} {g g' : GameState} (h : Run e g g') : Flags g g' := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact Flags.refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | @touchActive e w f g p he h => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | @touchBench e w f g q b₁ b₂ he h => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | unmark w m g => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | benchCounters w n h => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | spreadCounters w n g => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | switch w ha hb => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | benchDamage w n h => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | spreadDamage w n g => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | linger w s m g => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | @zone e w g s' hw hz => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | _ => exact ⟨rfl, rfl, rfl⟩

theorem KOMove.flags_keep {g g' : GameState} (h : KOMove g g') : Flags g g' := by
  cases h <;> exact ⟨rfl, rfl, rfl⟩

theorem Resolve.flags_keep {g g' : GameState} (h : Resolve g g') : Flags g g' := by
  induction h with
  | done => exact Flags.refl _
  | step _ hm _ ih => exact hm.flags_keep.trans ih

theorem TRun.flags_keep {e : Effect} {g g' : GameState} (h : TRun e g g') : Flags g g' := by
  induction h with
  | prim _ _ hr hk => exact hr.flags_keep.trans hk.flags_keep
  | stop => exact Flags.refl _
  | iteT _ _ _ _ ih => exact ih
  | iteF _ _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact Flags.refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/-- What a resolution keeps when it recycles nothing: the discard piles only grow, and the
`attacked` and once-per-game flags are unchanged. -/
structure Keeps (g g' : GameState) : Prop where
  disc : g.discAmt ≤ g'.discAmt
  attacked : g'.attacked = g.attacked
  gxCur : g'.cur.gxUsed = g.cur.gxUsed
  gxOpp : g'.opp.gxUsed = g.opp.gxUsed

theorem Keeps.trans {g₁ g₂ g₃ : GameState} (h₁ : Keeps g₁ g₂) (h₂ : Keeps g₂ g₃) :
    Keeps g₁ g₃ :=
  ⟨Nat.le_trans h₁.disc h₂.disc, h₂.attacked.trans h₁.attacked, h₂.gxCur.trans h₁.gxCur,
    h₂.gxOpp.trans h₁.gxOpp⟩

theorem Keeps.refl (g : GameState) : Keeps g g := ⟨Nat.le_refl _, rfl, rfl, rfl⟩

theorem Run.keeps {e : Effect} {g g' : GameState} (h : Run e g g') (hn : e.recFilters = []) :
    Keeps g g' :=
  have hf := h.flags_keep
  ⟨by
    have := h.disc_mono (C := g.allCards) Card.amt_tw (Effect.recOk_nil hn) fun _ hy => hy
    rw [GameState.discAmt_eq, GameState.discAmt_eq]; exact this,
   hf.attacked, hf.gxCur, hf.gxOpp⟩

theorem KOMove.keeps {g g' : GameState} (h : KOMove g g') :
    Keeps g g' ∧ ∀ s, g'.slotAmt s = g.slotAmt s := by
  cases h with
  | knockOut =>
      refine ⟨⟨?_, rfl, rfl, rfl⟩, fun _ => rfl⟩
      simp only [GameState.discAmt, cardsAmt_append, PlayerState.takePrizes]; omega
  | knockOutOwn =>
      refine ⟨⟨?_, rfl, rfl, rfl⟩, fun _ => rfl⟩
      simp only [GameState.discAmt, cardsAmt_append, PlayerState.takePrizes]; omega
  | knockOutBench =>
      refine ⟨⟨?_, rfl, rfl, rfl⟩, fun _ => rfl⟩
      simp only [GameState.discAmt, cardsAmt_append, PlayerState.takePrizes]; omega
  | knockOutBenchOwn =>
      refine ⟨⟨?_, rfl, rfl, rfl⟩, fun _ => rfl⟩
      simp only [GameState.discAmt, cardsAmt_append, PlayerState.takePrizes]; omega
  | promote => exact ⟨⟨Nat.le_refl _, rfl, rfl, rfl⟩, fun _ => rfl⟩
  | noPokemon => exact ⟨⟨Nat.le_refl _, rfl, rfl, rfl⟩, fun _ => rfl⟩
  | promoteOwn => exact ⟨⟨Nat.le_refl _, rfl, rfl, rfl⟩, fun _ => rfl⟩
  | noPokemonOwn => exact ⟨⟨Nat.le_refl _, rfl, rfl, rfl⟩, fun _ => rfl⟩

theorem Resolve.keeps {g g' : GameState} (h : Resolve g g') :
    Keeps g g' ∧ ∀ s, g'.slotAmt s = g.slotAmt s := by
  induction h with
  | done => exact ⟨Keeps.refl _, fun _ => rfl⟩
  | step _ hm _ ih =>
      obtain ⟨k₁, s₁⟩ := hm.keeps
      exact ⟨k₁.trans ih.1, fun s => (ih.2 s).trans (s₁ s)⟩

theorem TRun.keeps {e : Effect} {g g' : GameState} (h : TRun e g g') (hn : e.recFilters = []) :
    Keeps g g' :=
  have hf := h.flags_keep
  ⟨by
    have := h.disc_mono (C := g.allCards) Card.amt_tw (Effect.recOk_nil hn) fun _ hy => hy
    rw [GameState.discAmt_eq, GameState.discAmt_eq]; exact this,
   hf.attacked, hf.gxCur, hf.gxOpp⟩

theorem TRun.slot_nowrite {e : Effect} {g g' : GameState} (h : TRun e g g') :
    e.writes = false → ∀ s, g'.slotAmt s ≤ g.slotAmt s := by
  induction h with
  | prim _ _ hr hk => intro hw s; rw [hk.keeps.2 s]; exact hr.slot_nowrite hw s
  | stop => intro _ s; exact Nat.le_refl _
  | iteT _ _ _ _ ih =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw; exact ih hw.1 s
  | iteF _ _ _ _ ih =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw; exact ih hw.2 s
  | seq _ _ ih₁ ih₂ =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw
      exact Nat.le_trans (ih₂ hw.2 s) (ih₁ hw.1 s)
  | choiceL _ ih =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw; exact ih hw.1 s
  | choiceR _ ih =>
      intro hw s; simp only [Effect.writes, Bool.or_eq_false_iff] at hw; exact ih hw.2 s
  | iterNil => intro _ s; exact Nat.le_refl _
  | iterCons _ _ ih₁ ih₂ => intro hw s; exact Nat.le_trans (ih₂ hw s) (ih₁ hw s)

/-- **One resolution of a loop-free Trainer effect adds at most `e.amtAt s` to slot `s`**,
Knock Outs in mid-effect included. -/
theorem TRun.slot_le {e : Effect} {g g' : GameState} (h : TRun e g g') :
    e.loopFree = true → ∀ s, g'.slotAmt s ≤ g.slotAmt s + e.amtAt s := by
  induction h with
  | prim _ _ hr hk => intro hb s; rw [hk.keeps.2 s]; exact hr.slot_le hb s
  | stop => intro _ s; exact Nat.le_add_right _ _
  | iteT _ _ _ _ ih =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih hb.1 s; simp only [Effect.amtAt]; omega
  | iteF _ _ _ _ ih =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih hb.2 s; simp only [Effect.amtAt]; omega
  | seq _ _ ih₁ ih₂ =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih₁ hb.1 s; have := ih₂ hb.2 s; simp only [Effect.amtAt]; omega
  | choiceL _ ih =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih hb.1 s; simp only [Effect.amtAt]; omega
  | choiceR _ ih =>
      intro hb s; simp only [Effect.loopFree, Bool.and_eq_true] at hb
      have := ih hb.2 s; simp only [Effect.amtAt]; omega
  | iterNil => intro _ s; exact Nat.le_add_right _ _
  | iterCons h₁ h₂ _ _ =>
      intro hb s
      simp only [Effect.loopFree, Bool.not_eq_eq_eq_not, Bool.not_true] at hb
      have e₁ := h₁.slot_nowrite hb s
      have e₂ := h₂.slot_nowrite (by simp only [Effect.writes]; exact hb) s
      exact Nat.le_trans (Nat.le_trans e₂ e₁) (Nat.le_add_right _ _)

/-! ## Clause 3: recycling (milestone MV) -/

/-- The recycling filters of a list of attacks. -/
def attacksRec : List Attack → List Filter
  | [] => []
  | a :: as => a.effect.recFilters ++ attacksRec as

theorem attacksRec_mem {atk : Attack} {f : Filter} :
    ∀ {as : List Attack}, atk ∈ as → f ∈ atk.effect.recFilters → f ∈ attacksRec as
  | _ :: _, .head _, hf => List.mem_append_left _ hf
  | _ :: _, .tail _ h, hf => List.mem_append_right _ (attacksRec_mem h hf)

theorem Attack.script_recFilters (atk : Attack) :
    atk.script.recFilters = atk.effect.recFilters := by
  unfold Attack.script
  split
  · rfl
  · simp only [Effect.recFilters, List.nil_append]

/-- The recycling filters of a list of Abilities (milestone M8a). -/
def abilitiesRec : List Ability → List Filter
  | [] => []
  | a :: as => a.scripts.flatMap Effect.recFilters ++ abilitiesRec as

/-- The recycling filters of the "as often as you like" Abilities of a list (milestone M8a). -/
def unlimitedRec : List Ability → List Filter
  | [] => []
  | a :: as => (if a.use = .unlimited then a.scripts.flatMap Effect.recFilters else []) ++
      unlimitedRec as

theorem abilitiesRec_mem {ab : Ability} {e : Effect} {f : Filter} :
    ∀ {as : List Ability}, ab ∈ as → e ∈ ab.scripts → f ∈ e.recFilters → f ∈ abilitiesRec as
  | _ :: _, .head _, he, hf => List.mem_append_left _ (List.mem_flatMap.2 ⟨e, he, hf⟩)
  | _ :: _, .tail _ h, he, hf => List.mem_append_right _ (abilitiesRec_mem h he hf)

theorem unlimitedRec_mem {ab : Ability} {e : Effect} {f : Filter} :
    ∀ {as : List Ability}, ab ∈ as → ab.use = .unlimited → e ∈ ab.scripts → f ∈ e.recFilters →
      f ∈ unlimitedRec as
  | _ :: _, .head _, hu, he, hf =>
      List.mem_append_left _ (by simp only [hu, ite_true]; exact List.mem_flatMap.2 ⟨e, he, hf⟩)
  | _ :: _, .tail _ h, hu, he, hf => List.mem_append_right _ (unlimitedRec_mem h hu he hf)

theorem unlimitedRec_sub {f : Filter} : ∀ {as : List Ability}, f ∈ unlimitedRec as →
    f ∈ abilitiesRec as
  | [], h => h
  | a :: as, h => by
      simp only [unlimitedRec, abilitiesRec, List.mem_append] at h ⊢
      rcases h with h | h
      · split at h
        · exact .inl h
        · nomatch h
      · exact .inr (unlimitedRec_sub h)

/-- The recycling filters of a card's effects that a player can resolve again and again within
one turn before attacking, with no per-turn limit: a Trainer card's effect (each play spends the
card, but recycling can return it), and, since milestone M8a, a Pokémon card's "as often as you
like" Abilities. Attacks end the turn; "once during your turn" and on-play Abilities are bounded
per turn by the Pokémon in play and entering play (`GameState.abPot`). (Before milestone M8a this
was `Card.trainerRec`, the Trainer part.) -/
def Card.freeRec : Card → List Filter
  | .trainer _ k e => if k = .stadium then [] else e.recFilters
  | .pokemon p => unlimitedRec p.abilities
  | .tool _ gr => unlimitedRec gr.abilities
  | _ => []

/-- The recycling filters of all of a card's effects, attacks and (milestone M8a) Abilities
included. -/
def Card.allRec : Card → List Filter
  | .pokemon p => attacksRec p.attacks ++ abilitiesRec p.abilities
  | .trainer _ _ e => e.recFilters
  | .tool _ gr => attacksRec gr.attacks ++ abilitiesRec gr.abilities
  | _ => []

/-- The amount a card writes when it is played, if it is an Item card: a Supporter is played at
most once per turn by the rules, and (milestone M5) playing a Stadium writes nothing (its effect
is used by `Move.stadiumUse`, at most twice in a turn, and is counted by `Card.stQ`). -/
def Card.wAmt : Card → Nat
  | .trainer _ k e => if k = .item then e.amt else 0
  | _ => 0

/-- The rest-of-game amount an Item or Supporter card writes when it is played (milestone M5: a
Stadium writes nothing when played, and its effect writes no rest-of-game amount, clause 5). -/
def Card.alAmt : Card → Nat
  | .trainer _ k e => if k = .stadium then 0 else e.amtAt .always
  | _ => 0

theorem Card.wAmt_tw : TrainerWeight Card.wAmt := ⟨fun _ => rfl, fun _ => rfl⟩
theorem Card.alAmt_tw : TrainerWeight Card.alAmt := ⟨fun _ => rfl, fun _ => rfl⟩

theorem Card.wAmt_le : ∀ c : Card, c.wAmt ≤ c.amt
  | .trainer _ k e => by simp only [Card.wAmt, Card.amt]; split <;> omega
  | .pokemon _ => Nat.le_refl _
  | .energy _ => Nat.le_refl _
  | .tool _ _ => Nat.le_refl _

theorem Card.alAmt_le : ∀ c : Card, c.alAmt ≤ c.amt
  | .trainer _ k e => by
      simp only [Card.alAmt, Card.amt]; split
      · exact Nat.zero_le _
      · exact e.amtAt_le_amt .always
  | .pokemon _ => Nat.le_refl _
  | .energy _ => Nat.le_refl _
  | .tool _ _ => Nat.le_refl _

theorem GameState.discW_le {w : Card → Nat} (hw : ∀ c, w c ≤ c.amt) (g : GameState) :
    g.discW w ≤ cardsAmt g.allCards := by
  have h1 := wsum_le w Card.amt hw g.cur.discard
  have h2 := wsum_le w Card.amt hw g.opp.discard
  have h3 := g.discAmt_le
  simp only [GameState.discAmt, cardsAmt_eq] at h3
  simp only [GameState.discW, cardsAmt_eq]; omega

/-- **Clause 3** (`RecycleSafe`, milestone MV): (a) no Trainer card's effect and (milestone M8a)
no "as often as you like" Ability (`Card.freeRec`) can return from a discard pile to a hand or
deck a card of the game that writes a damage bonus or reduction, unless that card is a Supporter;
and (b) no effect at all, attacks and Abilities included, can return a card that writes a
rest-of-game bonus or reduction. "Can return": the filter of one of its zone moves out of a
discard pile admits the card (`Effect.recFilters`). Attacks may recycle every other card: an
attack ends the turn; so may "once during your turn" and on-play Abilities, which are used
boundedly often in a turn (`GameState.abPot`). Decidable (a finite check over pairs of a
recycling filter and a card of the game). For a deck without Abilities it is the clause of
milestone MV. -/
def GameState.RecycleSafe (g : GameState) : Prop :=
  (∀ x ∈ g.allCards, ∀ f ∈ x.freeRec, ∀ y ∈ g.allCards, f.eval y = true → y.wAmt = 0) ∧
  (∀ x ∈ g.allCards, ∀ f ∈ x.allRec, ∀ y ∈ g.allCards, f.eval y = true → y.alAmt = 0)

instance (g : GameState) : Decidable g.RecycleSafe := by
  unfold GameState.RecycleSafe; infer_instance

/-- No effect of any card of the game moves a card out of a discard pile to a hand or deck. -/
def GameState.NoRecycle (g : GameState) : Prop := ∀ x ∈ g.allCards, x.allRec = []

theorem GameState.NoRecycle.recycleSafe {g : GameState} (h : g.NoRecycle) : g.RecycleSafe := by
  refine ⟨fun x hx f hf => ?_, fun x hx f hf => ?_⟩
  · have e : f ∈ x.allRec := by
      cases x with
      | trainer n k e =>
          simp only [Card.freeRec] at hf
          split at hf
          · nomatch hf
          · exact hf
      | pokemon p => exact List.mem_append_right _ (unlimitedRec_sub hf)
      | tool n gr => exact List.mem_append_right _ (unlimitedRec_sub hf)
      | energy _ => nomatch hf
    rw [h x hx] at e; nomatch e
  · rw [h x hx] at hf; nomatch hf

theorem GameState.RecycleSafe.of_perm {g g' : GameState} (h : g.RecycleSafe)
    (hp : g'.allCards.Perm g.allCards) : g'.RecycleSafe :=
  ⟨fun x hx f hf y hy => h.1 x (hp.mem_iff.1 hx) f hf y (hp.mem_iff.1 hy),
    fun x hx f hf y hy => h.2 x (hp.mem_iff.1 hx) f hf y (hp.mem_iff.1 hy)⟩

theorem GameState.NoRecycle.of_perm {g g' : GameState} (h : g.NoRecycle)
    (hp : g'.allCards.Perm g.allCards) : g'.NoRecycle :=
  fun x hx => h x (hp.mem_iff.1 hx)

/-- The amount one use of an Ability can add to what is written in a turn, against the per-turn
count (milestone M8a): what its effect writes, plus `P` if it recycles (it may then return
Trainer writers of total amount at most `P`, the Trainer amounts of all the cards, to be played
again). For an Ability, the largest over its scripts. -/
def Effect.q (P : Nat) (e : Effect) : Nat :=
  e.amt + (if e.recFilters = [] then 0 else P)

def effectsQ (P : Nat) : List Effect → Nat
  | [] => 0
  | e :: es => max (e.q P) (effectsQ P es)

theorem effectsQ_mem {P : Nat} {e : Effect} : ∀ {es : List Effect}, e ∈ es → e.q P ≤ effectsQ P es
  | a :: as, hm => by
      simp only [effectsQ]
      cases hm with
      | head => omega
      | tail _ hm => have := effectsQ_mem (P := P) hm; omega

@[inherit_doc Effect.q]
def Ability.q (P : Nat) (ab : Ability) : Nat := effectsQ P ab.scripts

def abilitiesQ (P : Nat) : List Ability → Nat
  | [] => 0
  | a :: as => max (a.q P) (abilitiesQ P as)

/-- The largest `Ability.q P` among the Abilities a card has or (milestone M5) gives. -/
def Card.abQ (P : Nat) (c : Card) : Nat := abilitiesQ P c.abilities

/-- The largest `Ability.q P` among the cards `C` (0 for a deck without Abilities). -/
def cardsAbQ (P : Nat) : List Card → Nat
  | [] => 0
  | c :: cs => max (c.abQ P) (cardsAbQ P cs)

theorem abilitiesQ_mem {P : Nat} {ab : Ability} : ∀ {as : List Ability}, ab ∈ as →
    ab.q P ≤ abilitiesQ P as
  | a :: as, hm => by
      simp only [abilitiesQ]
      cases hm with
      | head => omega
      | tail _ hm => have := abilitiesQ_mem (P := P) hm; omega

theorem abQ_le_cardsAbQ {P : Nat} {x : Card} : ∀ {cs : List Card}, x ∈ cs →
    x.abQ P ≤ cardsAbQ P cs
  | [], h => nomatch h
  | c :: cs, h => by
      cases h with
      | head => simp only [cardsAbQ]; omega
      | tail _ h =>
          have := abQ_le_cardsAbQ (P := P) h
          simp only [cardsAbQ]; omega

theorem Ability.q_script {P : Nat} {ab : Ability} {e : Effect} (he : e ∈ ab.scripts) :
    e.q P ≤ ab.q P := effectsQ_mem he

theorem Ability.q_le {P : Nat} {C : List Card} {c : Card} (hp : c ∈ C)
    {ab : Ability} (hm : ab ∈ c.abilities) : ab.q P ≤ cardsAbQ P C :=
  Nat.le_trans (abilitiesQ_mem hm) (abQ_le_cardsAbQ (x := c) hp)

/-- **Clause 4** (`AbilitySafe`, milestone M8a), for one card: no "as often as you like" Ability writes a damage
bonus or reduction, and no Ability writes a rest-of-game one. "Once during your turn" and on-play
Abilities may write modifiers and recycle (within clause 3 (b)): they are used at most
`GameState.abPot` times in a turn. Decidable. Every deck without Abilities satisfies it. -/
def Card.abilitySafe : Card → Bool
  | .pokemon p => p.abilities.all fun ab => ab.scripts.all fun e =>
      (ab.use != .unlimited || e.amt == 0) && e.amtAt .always == 0
  | .tool _ gr => gr.abilities.all fun ab => ab.scripts.all fun e =>
      (ab.use != .unlimited || e.amt == 0) && e.amtAt .always == 0
  | _ => true

@[inherit_doc Card.abilitySafe]
def GameState.AbilitySafe (g : GameState) : Prop := ∀ x ∈ g.allCards, x.abilitySafe = true

instance (g : GameState) : Decidable g.AbilitySafe := by
  unfold GameState.AbilitySafe; infer_instance

theorem GameState.AbilitySafe.get {g : GameState} (h : g.AbilitySafe) {c : Card}
    (hp : c ∈ g.allCards) {ab : Ability} (hm : ab ∈ c.abilities) {e : Effect}
    (he : e ∈ ab.scripts) : (ab.use = .unlimited → e.amt = 0) ∧ e.amtAt .always = 0 := by
  have := h _ hp
  have : ((ab.use != .unlimited || e.amt == 0) && e.amtAt .always == 0) = true := by
    cases c with
    | pokemon p => exact List.all_eq_true.1 (List.all_eq_true.1 this ab hm) e he
    | tool n gr => exact List.all_eq_true.1 (List.all_eq_true.1 this ab hm) e he
    | _ => nomatch hm
  rw [Bool.and_eq_true] at this
  obtain ⟨h1, h2⟩ := this
  refine ⟨fun hu => ?_, Nat.eq_of_beq_eq_true h2⟩
  rw [hu] at h1
  exact Nat.eq_of_beq_eq_true h1

theorem GameState.AbilitySafe.of_perm {g g' : GameState} (h : g.AbilitySafe)
    (hp : g'.allCards.Perm g.allCards) : g'.AbilitySafe :=
  fun x hx => h x (hp.mem_iff.1 hx)

/-- No Ability writes a damage bonus or reduction (milestone M8a): the hypothesis under which the
per-game bound of decks that recycle nothing (`reach_boundedStores_noRecycle`) survives
Abilities. Every deck without Abilities satisfies it. -/
def GameState.AbilityQuiet (g : GameState) : Prop :=
  ∀ c ∈ g.allCards, ∀ ab ∈ c.abilities, ∀ e ∈ ab.scripts, e.amt = 0

theorem GameState.AbilityQuiet.of_perm {g g' : GameState} (h : g.AbilityQuiet)
    (hp : g'.allCards.Perm g.allCards) : g'.AbilityQuiet :=
  fun c hx => h c (hp.mem_iff.1 hx)

/-- **Clause 5** (`StadiumSafe`, milestone M5), for one card: a Stadium's effect writes no
rest-of-game damage bonus or reduction. A Stadium stays in play and its effect may be used in
every turn of either player without the card being played again, so a rest-of-game write there
would grow without limit (`Stadiums.stadium_writer_breaks_bound`). Other writes and recycling by
a Stadium are allowed: its uses are at most two in a turn (`GameState.stPot`), each paid for by
`Card.stQ`. Decidable; every deck without Stadium cards satisfies it. -/
def Card.stadiumSafe : Card → Bool
  | .trainer _ .stadium e => e.amtAt .always == 0
  | _ => true

@[inherit_doc Card.stadiumSafe]
def GameState.StadiumSafe (g : GameState) : Prop := ∀ x ∈ g.allCards, x.stadiumSafe = true

instance (g : GameState) : Decidable g.StadiumSafe := by
  unfold GameState.StadiumSafe; infer_instance

theorem GameState.StadiumSafe.get {g : GameState} (h : g.StadiumSafe) {n : String} {e : Effect}
    (hx : Card.trainer n .stadium e ∈ g.allCards) : e.amtAt .always = 0 :=
  Nat.eq_of_beq_eq_true (h _ hx)

theorem GameState.StadiumSafe.of_perm {g g' : GameState} (h : g.StadiumSafe)
    (hp : g'.allCards.Perm g.allCards) : g'.StadiumSafe :=
  fun x hx => h x (hp.mem_iff.1 hx)

/-- No Stadium's effect writes a damage bonus or reduction (milestone M5): the hypothesis under
which the per-game bound of decks that recycle nothing (`reach_boundedStores_noRecycle`) survives
Stadiums, whose effects are used every turn. Every deck without Stadium cards satisfies it. -/
def GameState.StadiumQuiet (g : GameState) : Prop :=
  ∀ (n : String) (e : Effect), Card.trainer n .stadium e ∈ g.allCards → e.amt = 0

theorem GameState.StadiumQuiet.of_perm {g g' : GameState} (h : g.StadiumQuiet)
    (hp : g'.allCards.Perm g.allCards) : g'.StadiumQuiet :=
  fun n e hx => h n e (hp.mem_iff.1 hx)

/-- What one use of a Stadium's effect can add to the per-turn count (milestone M5): `Effect.q`
of the effect, what it writes plus `P` if it recycles. 0 for every other card. -/
def Card.stQ (P : Nat) : Card → Nat
  | .trainer _ .stadium e => e.q P
  | _ => 0

/-- The largest `Card.stQ P` among the cards `C` (0 for a deck without Stadium cards). -/
def cardsStQ (P : Nat) : List Card → Nat
  | [] => 0
  | c :: cs => max (c.stQ P) (cardsStQ P cs)

theorem stQ_le_cardsStQ {P : Nat} {x : Card} : ∀ {cs : List Card}, x ∈ cs →
    x.stQ P ≤ cardsStQ P cs
  | [], h => nomatch h
  | c :: cs, h => by
      cases h with
      | head => simp only [cardsStQ]; omega
      | tail _ h =>
          have := stQ_le_cardsStQ (P := P) h
          simp only [cardsStQ]; omega

/-- **Faithful decks** (milestone MV: three clauses; milestone M8a: four; milestone M5: five, the
fifth `StadiumSafe`, which every deck without Stadium cards satisfies). For a deck with no
recycling (every deck before milestone MV) clause 3 holds (`GameState.NoRecycle.recycleSafe`), and
for a deck without Abilities clause 4 holds and clauses 1 and 3 say what they said before, so for
a deck with neither `Faithful` means what it meant before milestone MV: `LoopFree ∧ GXOnly`. -/
def GameState.Faithful (g : GameState) : Prop :=
  g.LoopFree ∧ g.GXOnly ∧ g.RecycleSafe ∧ g.AbilitySafe ∧ g.StadiumSafe

/-- A recycling filter of an attack of a card (a Pokémon card's, or one a Tool gives) is one of
the card's. -/
theorem Card.allRec_of_attack {c : Card} {atk : Attack} (hm : atk ∈ c.attacks) {f : Filter}
    (hf : f ∈ atk.effect.recFilters) : f ∈ c.allRec := by
  cases c with
  | pokemon p => exact List.mem_append_left _ (attacksRec_mem hm hf)
  | tool n gr => exact List.mem_append_left _ (attacksRec_mem hm hf)
  | _ => nomatch hm

/-- A recycling filter of an Ability of a card is one of the card's. -/
theorem Card.allRec_of_ability {c : Card} {ab : Ability} (hm : ab ∈ c.abilities) {e : Effect}
    (he : e ∈ ab.scripts) {f : Filter} (hf : f ∈ e.recFilters) : f ∈ c.allRec := by
  cases c with
  | pokemon p => exact List.mem_append_right _ (abilitiesRec_mem hm he hf)
  | tool n gr => exact List.mem_append_right _ (abilitiesRec_mem hm he hf)
  | _ => nomatch hm

/-- A recycling filter of an "as often as you like" Ability of a card is a free one. -/
theorem Card.freeRec_of_unlimited {c : Card} {ab : Ability} (hm : ab ∈ c.abilities)
    (hu : ab.use = .unlimited) {e : Effect} (he : e ∈ ab.scripts) {f : Filter}
    (hf : f ∈ e.recFilters) : f ∈ c.freeRec := by
  cases c with
  | pokemon p => exact unlimitedRec_mem hm hu he hf
  | tool n gr => exact unlimitedRec_mem hm hu he hf
  | _ => nomatch hm

theorem attacksRec_nil {c : Card} (h : c.allRec = []) {atk : Attack}
    (hm : atk ∈ c.attacks) : atk.effect.recFilters = [] := by
  cases e : atk.effect.recFilters with
  | nil => rfl
  | cons f fs =>
      have h' := Card.allRec_of_attack hm (f := f) (by rw [e]; exact .head _)
      rw [h] at h'; nomatch h'

theorem abilitiesRec_nil {c : Card} (h : c.allRec = []) {ab : Ability}
    (hm : ab ∈ c.abilities) {e' : Effect} (he : e' ∈ ab.scripts) : e'.recFilters = [] := by
  cases e : e'.recFilters with
  | nil => rfl
  | cons f fs =>
      have h' := Card.allRec_of_ability hm he (f := f) (by rw [e]; exact .head _)
      rw [h] at h'; nomatch h'

/-! ## Using an Ability (milestone M8a): what the marking keeps -/

theorem UseAt.slotAmt {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁)
    (s : Slot) : g₁.slotAmt s = g.slotAmt s := by
  cases h <;> rfl

theorem UseAt.discW {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁)
    (w : Card → Nat) : g₁.discW w = g.discW w := by
  cases h <;> rfl

theorem UseAt.discAmt {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    g₁.discAmt = g.discAmt := by
  cases h <;> rfl

theorem UseAt.flags {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    Flags g g₁ := by
  cases h <;> exact ⟨rfl, rfl, rfl⟩

theorem UseAt.supporterPlayed {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    g₁.cur.supporterPlayed = g.cur.supporterPlayed := by
  cases h <;> rfl

theorem PlayFromHand.slotAmt {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) (s : Slot) : g₁.slotAmt s = g.slotAmt s := by
  cases h <;> rfl

theorem PlayFromHand.discW {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) (wt : Card → Nat) : g₁.discW wt = g.discW wt := by
  cases h <;> rfl

theorem PlayFromHand.discAmt {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : g₁.discAmt = g.discAmt := by
  cases h <;> rfl

theorem PlayFromHand.flags {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : Flags g g₁ := by
  cases h <;> exact ⟨rfl, rfl, rfl⟩

theorem PlayFromHand.supporterPlayed {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : g₁.cur.supporterPlayed = g.cur.supporterPlayed := by
  cases h <;> rfl

/-! ## Counting Ability uses within a turn (milestone M8a)

A "once during your turn" Ability can be used once per turn by each Pokémon in play that has it,
and an on-play Ability once each time a Pokémon is played from the hand. Neither count is bounded
by the Bench alone: a Pokémon can enter play, be Knocked Out, and be replaced within the turn, and
an evolved Pokémon may use its new Ability. What bounds them is a potential, `GameState.abPot`, of
the player to move: one unit for each of their Pokémon in play that has not used an Ability this
turn, two for each that can still evolve this turn (`fresh = false`), two for each free place in
play (at most `benchLimit + 1`), and two for each Prize card the opponent has left. Within a turn
no move raises it; using an Ability on an unused Pokémon lowers it by one; playing a Basic Pokémon
or evolving lowers it by at least one (a new place is filled, or an evolution spent, and the new
Pokémon is unused); Knocking Out one of the player's own Pokémon frees a place but gives the
opponent at least one Prize card. So the uses of these Abilities in one turn are at most the
potential at the start of the turn, which is at most `potBound` of the number of cards. The bound
rests on the model having no effect that returns a Pokémon in play to the hand or deck (a Pokémon
leaves play only by a Knock Out, which costs a Prize card); with such an effect (Scoop Up Cyclone)
the same Pokémon card could re-enter play and use or trigger its Ability again. -/

/-- The weight of a Pokémon in play in the potential: 1 if it has not used an Ability this turn,
2 more if it can still evolve this turn. -/
def InPlay.abW (p : InPlay) : Nat := (if p.used then 0 else 1) + (if p.fresh then 0 else 2)

theorem InPlay.abW_le (p : InPlay) : p.abW ≤ 3 := by
  unfold InPlay.abW; split <;> split <;> omega

def abWs : List InPlay → Nat
  | [] => 0
  | p :: ps => p.abW + abWs ps

def abWo : Option InPlay → Nat
  | none => 0
  | some p => p.abW

def optN : Option InPlay → Nat
  | none => 0
  | some _ => 1

theorem optN_le (o : Option InPlay) : optN o ≤ 1 := by cases o <;> simp [optN]

/-- The potential of one player's Pokémon in play. -/
def PlayerState.abPot (s : PlayerState) : Nat :=
  abWo s.active + abWs s.bench + 2 * (benchLimit + 1 - (optN s.active + s.bench.length))

/-- **The potential of the player to move**: their Pokémon in play, and two units for each Prize
card the opponent has left. -/
def GameState.abPot (g : GameState) : Nat := g.cur.abPot + 2 * g.opp.prizes.length

theorem abWs_append (a b : List InPlay) : abWs (a ++ b) = abWs a + abWs b := by
  induction a with
  | nil => simp only [List.nil_append, abWs, Nat.zero_add]
  | cons p ps ih => simp only [List.cons_append, abWs, ih]; omega

theorem abWs_split {b₁ b₂ : List InPlay} {q q' : InPlay} (h : q'.abW = q.abW) :
    abWs (b₁ ++ q' :: b₂) = abWs (b₁ ++ q :: b₂) := by
  simp only [abWs_append, abWs, h]

theorem abWs_map {f : InPlay → InPlay} (hf : ∀ p, (f p).abW = p.abW) :
    ∀ b : List InPlay, abWs (b.map f) = abWs b
  | [] => rfl
  | p :: ps => by simp only [List.map_cons, abWs, hf p, abWs_map hf ps]

theorem abWo_map {f : InPlay → InPlay} (hf : ∀ p, (f p).abW = p.abW) :
    ∀ o : Option InPlay, abWo (o.map f) = abWo o
  | none => rfl
  | some p => hf p

theorem optN_map (f : InPlay → InPlay) : ∀ o : Option InPlay, optN (o.map f) = optN o
  | none => rfl
  | some _ => rfl

theorem abWs_le : ∀ b : List InPlay, abWs b ≤ 3 * b.length
  | [] => Nat.le_refl _
  | p :: ps => by
      have := p.abW_le; have := abWs_le ps
      simp only [abWs, List.length_cons]; omega

theorem abWo_le : ∀ o : Option InPlay, abWo o ≤ 3 * optN o
  | none => Nat.le_refl _
  | some p => by have := p.abW_le; simp only [abWo, optN]; omega

theorem InPlay.abW_hitBench (n : Nat) (p : InPlay) : (p.hitBench n).abW = p.abW := by
  unfold InPlay.hitBench; split <;> rfl

/-- A player state whose Pokémon in play have the same weights and number has the same potential. -/
theorem PlayerState.abPot_congr {s s' : PlayerState}
    (h₁ : abWo s'.active + abWs s'.bench = abWo s.active + abWs s.bench)
    (h₂ : optN s'.active + s'.bench.length = optN s.active + s.bench.length) :
    s'.abPot = s.abPot := by
  simp only [PlayerState.abPot]; omega

/-- **A zone step never raises its player's potential**; putting a Basic Pokémon onto the Bench
fills a place with an unused Pokémon. -/
theorem ZStep.abPot_le {e : Effect} {s s' : PlayerState} (h : ZStep e s s') :
    s'.abPot ≤ s.abPot := by
  cases h with
  | @move w src dst f q s s' t r hs hq hp =>
      obtain ⟨_, ha, hb⟩ := hp.fields
      exact Nat.le_of_eq (PlayerState.abPot_congr (by rw [ha, hb, Src.set_active, Src.set_bench])
        (by rw [ha, hb, Src.set_active, Src.set_bench]))
  | drawTo => exact Nat.le_refl _
  | @attachActive w src f tf s r t a hs ha ht =>
      have e : (a.addEnergy (.energy t)).abW = a.abW := rfl
      exact Nat.le_of_eq (PlayerState.abPot_congr (by simp only [Src.set_bench, ha, abWo, e])
        (by simp [ha, optN]))
  | @attachBench w src f tf s r t q b₁ b₂ hs hb ht =>
      exact Nat.le_of_eq (PlayerState.abPot_congr
        (by simp only [Src.set_active, hb, abWs_split (b₁ := b₁) (b₂ := b₂)
              (q := q) (q' := q.addEnergy (.energy t)) rfl])
        (by simp [hb]))
  | attachNone => exact Nat.le_refl _
  | @putBench w src f s r p hs hst hhp hb =>
      have h1 := optN_le s.active
      simp only [benchLimit] at hb
      simp only [PlayerState.abPot, Src.set_active, abWs_append, abWs,
        List.length_append, List.length_cons, List.length_nil, benchLimit]
      have : (InPlay.ofBasic p).abW = 1 := rfl
      omega
  | putBenchNone => exact Nat.le_refl _
  | @discardActive w f q s a t r ha hs hq =>
      have e : InPlay.abW { a with energy := r } = a.abW := rfl
      exact Nat.le_of_eq (PlayerState.abPot_congr (by simp only [ha, abWo, e])
        (by simp [ha, optN]))
  | @discardBench w f q s p b₁ b₂ t r hb hs hq =>
      exact Nat.le_of_eq (PlayerState.abPot_congr
        (by simp only [hb, abWs_split (b₁ := b₁) (b₂ := b₂) (q := p) (q' := { p with energy := r })
              rfl])
        (by simp [hb]))
  | discardNone => exact Nat.le_refl _
  | @moveAB w f s a q b₁ b₂ e₁ e₂ y ha he hx hb =>
      exact Nat.le_of_eq (PlayerState.abPot_congr
        (by simp only [ha, hb, abWo, abWs_split (b₁ := b₁) (b₂ := b₂) (q := q)
              (q' := q.addEnergy y) rfl]; rfl)
        (by simp [ha, hb, optN]))
  | @moveBA w f s a q b₁ b₂ e₁ e₂ y ha hb he hx =>
      exact Nat.le_of_eq (PlayerState.abPot_congr
        (by simp only [ha, hb, abWo, abWs_split (b₁ := b₁) (b₂ := b₂) (q := q)
              (q' := { q with energy := e₁ ++ e₂ }) rfl]; rfl)
        (by simp [ha, hb, optN]))
  | @moveBB w f s q q' b₁ b₂ c₁ c₂ e₁ e₂ y hb he hx hc =>
      have h3 := congrArg abWs hc
      have h4 := congrArg List.length hc
      rw [abWs_split (b₁ := b₁) (b₂ := b₂) (q := q) (q' := { q with energy := e₁ ++ e₂ }) rfl] at h3
      exact Nat.le_of_eq (PlayerState.abPot_congr
        (by simp only [hb, abWs_split (b₁ := c₁) (b₂ := c₂) (q := q') (q' := q'.addEnergy y) rfl,
              ← h3])
        (by simp only [hb, List.length_append, List.length_cons] at h4 ⊢; omega))
  | moveNone => exact Nat.le_refl _
  | @toolsActive w s a ha =>
      have e : InPlay.abW { a with tools := [] } = a.abW := rfl
      exact Nat.le_of_eq (PlayerState.abPot_congr (by simp only [ha, abWo, e])
        (by simp [ha, optN]))
  | @toolsBench w s p b₁ b₂ hb =>
      exact Nat.le_of_eq (PlayerState.abPot_congr
        (by simp only [hb, abWs_split (b₁ := b₁) (b₂ := b₂) (q := p) (q' := { p with tools := [] })
              rfl])
        (by simp [hb]))
  | toolsNone => exact Nat.le_refl _

/-- Moving a damage counter keeps the weights and the number of Pokémon in play. -/
theorem CMove.abPot {f : Filter} {noKO : Bool} {a a' : Option InPlay} {b b' : List InPlay}
    (h : CMove f noKO a b a' b') :
    abWo a' + abWs b' = abWo a + abWs b ∧ optN a' + b'.length = optN a + b.length := by
  cases h with
  | @ab x q b₁ b₂ =>
      have e1 : InPlay.abW { x with damage := x.damage - 1 } = x.abW := rfl
      have e2 : (q.addDamage 1).abW = q.abW := rfl
      simp only [abWo, optN, abWs_append, abWs, e1, e2, List.length_append, List.length_cons,
        and_self]
  | @ba x q b₁ b₂ =>
      have e1 : (x.addDamage 1).abW = x.abW := rfl
      have e2 : InPlay.abW { q with damage := q.damage - 1 } = q.abW := rfl
      simp only [abWo, optN, abWs_append, abWs, e1, e2, List.length_append, List.length_cons,
        and_self]
  | @bb a q r b₁ b₂ c₁ c₂ hq hd hc =>
      have e3 := congrArg abWs hc
      have e4 := congrArg List.length hc
      have e1 : InPlay.abW { q with damage := q.damage - 1 } = q.abW := rfl
      have e2 : (r.addDamage 1).abW = r.abW := rfl
      simp only [abWs_append, abWs, e1, List.length_append, List.length_cons] at e3 e4
      simp only [abWs_append, abWs, e2, List.length_append, List.length_cons]
      exact ⟨by omega, by omega⟩

/-- **No step of an effect raises the potential.** -/
theorem Run.abPot_le {e : Effect} {g g' : GameState} (h : Run e g g') : g'.abPot ≤ g.abPot := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact Nat.le_trans ih₂ ih₁
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact Nat.le_refl _
  | iterCons _ _ ih₁ ih₂ => exact Nat.le_trans ih₂ ih₁
  | @zone e w g s' hw hz =>
      cases w with
      | own =>
          have := hz.abPot_le
          simp only [GameState.side] at this
          simp only [GameState.abPot, GameState.updSide]
          have e2 : (g.cur.setZones s').abPot = s'.abPot := rfl
          omega
      | opp => exact Nat.le_refl _
  | @heal g p n h =>
      have e : ({ p with damage := p.damage - n } : InPlay).abW = p.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, h, abWo, optN, e]; omega
  | @cure g p h =>
      have e : p.cure.abW = p.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, h, abWo, optN, e]; omega
  | @selfDamage g p n h =>
      have e : ({ p with damage := p.damage + n } : InPlay).abW = p.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, h, abWo, optN, e]; omega
  | @healAll g p h =>
      have e : ({ p with damage := 0 } : InPlay).abW = p.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, h, abWo, optN, e]; omega
  | @drain g p q a n hv h hq =>
      have e : ({ q with damage := q.damage - g.dealt n } : InPlay).abW = q.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, hq, abWo, optN, e]; omega
  | linger w s m g => cases w <;> exact Nat.le_refl _
  | @touchActive e w f g p he h =>
      cases w with
      | own =>
          simp only [GameState.side] at h
          have e : (p.setMarks f).abW = p.abW := rfl
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot, h, abWo, optN, e]; omega
      | opp => exact Nat.le_refl _
  | @touchBench e w f g q b₁ b₂ he h =>
      cases w with
      | own =>
          simp only [GameState.side] at h
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot, h,
            abWs_split (b₁ := b₁) (b₂ := b₂) (q := q) (q' := q.setMarks f) rfl,
            List.length_append, List.length_cons]; omega
      | opp => exact Nat.le_refl _
  | unmark w m g =>
      cases w with
      | own =>
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot, PlayerState.unmark,
            abWo_map (f := InPlay.setMarks (Marks.set m false)) (fun _ => rfl),
            abWs_map (f := InPlay.setMarks (Marks.set m false)) (fun _ => rfl), optN_map,
            List.length_map]; omega
      | opp => exact Nat.le_refl _
  | @benchCounters g q b₁ b₂ w n h =>
      cases w with
      | own =>
          simp only [GameState.side] at h
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot, h,
            abWs_split (b₁ := b₁) (b₂ := b₂) (q := q) (q' := { q with damage := q.damage + n }) rfl,
            List.length_append, List.length_cons]; omega
      | opp => exact Nat.le_refl _
  | spreadCounters w n g =>
      cases w with
      | own =>
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot,
            abWs_map (f := InPlay.addDamage n) (fun _ => rfl), List.length_map]; omega
      | opp => exact Nat.le_refl _
  | @benchHeal g q b₁ b₂ n h =>
      simp only [GameState.abPot, PlayerState.abPot, h,
        abWs_split (b₁ := b₁) (b₂ := b₂) (q := q) (q' := { q with damage := q.damage - n }) rfl,
        List.length_append, List.length_cons]; omega
  | @switch g a q b₁ b₂ w ha hb =>
      cases w with
      | own =>
          simp only [GameState.side] at ha hb
          have e1 : a.cure.abW = a.abW := rfl
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot, ha, hb, abWo, optN,
            abWs_append, abWs, e1, List.length_append, List.length_cons]; omega
      | opp => exact Nat.le_refl _
  | @benchDamage g q b₁ b₂ w n h =>
      cases w with
      | own =>
          simp only [GameState.side] at h
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot, h,
            abWs_split (b₁ := b₁) (b₂ := b₂) (q := q) (InPlay.abW_hitBench n q),
            List.length_append, List.length_cons]; omega
      | opp => exact Nat.le_refl _
  | spreadDamage w n g =>
      cases w with
      | own =>
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot,
            abWs_map (InPlay.abW_hitBench n), List.length_map]; omega
      | opp => exact Nat.le_refl _
  | moveCounter h =>
      obtain ⟨h1, h2⟩ := h.abPot
      simp only [GameState.abPot, PlayerState.abPot]
      omega
  | _ => exact Nat.le_refl _

theorem prizes_takePrizes_le {n : Nat} {s : PlayerState} {c : Card} {ps : List Card}
    (hp : s.prizes = c :: ps) (hn : 0 < n) :
    (s.takePrizes n).prizes.length + 1 ≤ s.prizes.length := by
  simp only [PlayerState.takePrizes, List.length_drop, hp, List.length_cons]; omega

/-- **No Knock Out move raises the potential**: Knocking Out one of the player's own Pokémon
frees a place (two units) and gives the opponent at least one Prize card (two units). -/
theorem KOMove.abPot_le {g g' : GameState} (h : KOMove g g') : g'.abPot ≤ g.abPot := by
  cases h with
  | knockOut => exact Nat.le_refl _
  | promote => exact Nat.le_refl _
  | noPokemon => exact Nat.le_refl _
  | @knockOutOwn p c ps ha hk hp =>
      have := prizes_takePrizes_le (n := p.top.prizeCount) hp p.top.ruleBox.prizes_pos
      have := p.abW_le
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN]
      omega
  | @promoteOwn q b₁ b₂ ha hb =>
      simp only [GameState.abPot, PlayerState.abPot, ha, hb, abWo, optN, abWs_append, abWs,
        List.length_append, List.length_cons]; omega
  | noPokemonOwn => exact Nat.le_refl _
  | knockOutBench => exact Nat.le_refl _
  | @knockOutBenchOwn p b₁ b₂ c ps hb hk hp =>
      have := prizes_takePrizes_le (n := p.top.prizeCount) hp p.top.ruleBox.prizes_pos
      have := p.abW_le
      simp only [GameState.abPot, PlayerState.abPot, hb, abWs_append, abWs,
        List.length_append, List.length_cons]
      omega

theorem Resolve.abPot_le {g g' : GameState} (h : Resolve g g') : g'.abPot ≤ g.abPot := by
  induction h with
  | done => exact Nat.le_refl _
  | step _ hm _ ih => exact Nat.le_trans ih hm.abPot_le

theorem TRun.abPot_le {e : Effect} {g g' : GameState} (h : TRun e g g') : g'.abPot ≤ g.abPot := by
  induction h with
  | prim _ _ hr hk => exact Nat.le_trans hk.abPot_le hr.abPot_le
  | stop => exact Nat.le_refl _
  | iteT _ _ _ _ ih => exact ih
  | iteF _ _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact Nat.le_trans ih₂ ih₁
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact Nat.le_refl _
  | iterCons _ _ ih₁ ih₂ => exact Nat.le_trans ih₂ ih₁

/-- **A play from the hand lowers the potential by at least one**: a Basic Pokémon fills a place
(two units) and is unused (one unit); an evolution spends the Pokémon's evolution for the turn
(two units) and resets its use of an Ability (at most one unit). -/
theorem PlayFromHand.abPot {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : g₁.abPot + 1 ≤ g.abPot := by
  cases h with
  | @basic l₁ l₂ p hh hs hhp hb =>
      have := optN_le g.cur.active
      simp only [benchLimit] at hb
      have e : (InPlay.ofBasic p).abW = 1 := rfl
      simp only [GameState.abPot, PlayerState.abPot, abWs_append, abWs, e, List.length_append,
        List.length_cons, List.length_nil, benchLimit]
      omega
  | @evolve l₁ l₂ p a hh ha he hfr =>
      have : a.abW ≥ 2 := by unfold InPlay.abW; rw [hfr]; split <;> simp
      have e : InPlay.abW { a with
          top := p, under := Card.pokemon a.top :: a.under, rot := .none,
          poisoned := false, burned := false, poisonUp := 0, fresh := true, used := false } = 1 :=
        rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | @evolveBench l₁ l₂ p q b₁ b₂ hh hb he hfr =>
      have : q.abW ≥ 2 := by unfold InPlay.abW; rw [hfr]; split <;> simp
      have e : InPlay.abW { q with
          top := p, under := Card.pokemon q.top :: q.under, rot := .none,
          poisoned := false, burned := false, poisonUp := 0, fresh := true, used := false } = 1 :=
        rfl
      simp only [GameState.abPot, PlayerState.abPot, hb, abWs_append, abWs, e,
        List.length_append, List.length_cons]; omega

/-- **Using an Ability never raises the potential, and lowers it by one** when the Pokémon had
not used an Ability this turn. -/
theorem UseAt.abPot {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    g₁.abPot + (if x.used then 0 else 1) = g.abPot := by
  have e : x.markUsed.abW + (if x.used then 0 else 1) = x.abW := by
    unfold InPlay.abW InPlay.markUsed; cases x.used <;> simp <;> omega
  cases h with
  | active ha =>
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN]; omega
  | bench hb =>
      simp only [GameState.abPot, PlayerState.abPot, hb, abWs_append, abWs, List.length_append,
        List.length_cons]; omega

/-- The potential is at most `potBound` of the number of cards in the game. -/
def potBound (L : Nat) : Nat := 5 * L + 2 * (benchLimit + 1)

theorem GameState.abPot_le_bound (g : GameState) : g.abPot ≤ potBound g.allCards.length := by
  have h1 := abWo_le g.cur.active
  have h2 := abWs_le g.cur.bench
  have h3 : optN g.cur.active + g.cur.bench.length ≤ g.allCards.length := by
    have := Enum.length_le_benchCardList g.cur.bench
    have : optN g.cur.active ≤ (optCardList g.cur.active).length := by
      cases g.cur.active <;> simp [optN, optCardList, InPlay.cardList]
    simp only [GameState.allCards, PlayerState.allCards, List.length_append]; omega
  have h4 : g.opp.prizes.length ≤ g.allCards.length := by
    simp only [GameState.allCards, PlayerState.allCards, List.length_append]; omega
  simp only [GameState.abPot, PlayerState.abPot, potBound]; omega

/-! ## The invariant -/

namespace Faithful

/-- `A` if the player to move has attacked this turn, else 0. -/
def atkT (A : Nat) (g : GameState) : Nat := if g.attacked then A else 0

/-- `A` for each player who has used a GX attack. -/
def gxT (A : Nat) (g : GameState) : Nat :=
  (if g.cur.gxUsed then A else 0) + (if g.opp.gxUsed then A else 0)

theorem atkT_le (A : Nat) (g : GameState) : atkT A g ≤ A := by
  unfold atkT; split <;> omega

theorem gxT_le (A : Nat) (g : GameState) : gxT A g ≤ A + A := by
  unfold gxT; split <;> split <;> omega

/-- **The invariant.** For each slot, the amounts of both players together are at most `S`
(the start stores), plus the Trainer amounts in the discard piles, plus `A` for every attack
that may still be live in the slot: one for the turn after next, if this turn's attack has been
made; one more for the next turn (last turn's attack); one more for this turn; and, for the
rest of the game, one per GX attack used. -/
structure Inv (S A : Nat) (g : GameState) : Prop where
  after : g.slotAmt .after ≤ S + g.discAmt + atkT A g
  next : g.slotAmt .next ≤ S + g.discAmt + A + atkT A g
  now : g.slotAmt .now ≤ S + g.discAmt + A + A + atkT A g
  always : g.slotAmt .always ≤ S + g.discAmt + gxT A g

theorem Inv.start (g : GameState) (A : Nat) : Inv g.storeTotal A g := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp only [GameState.storeTotal] <;> omega

/-- A step that writes nothing, keeps the discards growing, and does not undo an attack or a
GX attack. -/
theorem Inv.frame {S A : Nat} {g g' : GameState} (hi : Inv S A g)
    (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s) (hd : g.discAmt ≤ g'.discAmt)
    (ha : atkT A g ≤ atkT A g') (hx : gxT A g ≤ gxT A g') : Inv S A g' := by
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now; have h4 := hs .always
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨by omega, by omega, by omega, by omega⟩

theorem atkT_congr {A : Nat} {g g' : GameState} (h : g'.attacked = g.attacked) :
    atkT A g' = atkT A g := by
  simp only [atkT, h]

theorem gxT_congr {A : Nat} {g g' : GameState} (h₁ : g'.cur.gxUsed = g.cur.gxUsed)
    (h₂ : g'.opp.gxUsed = g.opp.gxUsed) : gxT A g' = gxT A g := by
  simp only [gxT, h₁, h₂]

theorem Inv.keeps {S A : Nat} {g g' : GameState} (hi : Inv S A g) (hk : Keeps g g')
    (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s) : Inv S A g' :=
  hi.frame hs hk.disc (Nat.le_of_eq (atkT_congr hk.attacked).symm)
    (Nat.le_of_eq (gxT_congr hk.gxCur hk.gxOpp).symm)

/-- A Trainer card: its amounts are matched by the card's amount in the discard pile. -/
theorem Inv.trainer {S A W : Nat} {g g' : GameState} (hi : Inv S A g) (hk : Keeps g g')
    (w : Slot → Nat) (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s + w s) (hw : ∀ s, w s ≤ W)
    (hd : g.discAmt + W ≤ g'.discAmt) : Inv S A g' := by
  have ea := atkT_congr (A := A) hk.attacked
  have ex := gxT_congr (A := A) hk.gxCur hk.gxOpp
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now; have h4 := hs .always
  have w1 := hw .after; have w2 := hw .next; have w3 := hw .now; have w4 := hw .always
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨by omega, by omega, by omega, by omega⟩

/-- An attack: at most `A` in each slot, the rest-of-game slot only with a GX attack. -/
theorem Inv.attack {S A : Nat} {g g' : GameState} (hi : Inv S A g) (hn : g.attacked = false)
    (ha : g'.attacked = true) (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s + A)
    (hal : g'.slotAmt .always + gxT A g ≤ g.slotAmt .always + gxT A g')
    (hd : g.discAmt ≤ g'.discAmt) : Inv S A g' := by
  have e0 : atkT A g = 0 := by simp only [atkT, hn]; rfl
  have e1 : atkT A g' = A := by simp only [atkT, ha]; rfl
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨by omega, by omega, by omega, by omega⟩

/-- The end of the turn: every slot moves one turn closer, the player's attack is forgotten. -/
theorem Inv.endTurn {S A : Nat} {g g' : GameState} (hi : Inv S A g)
    (h0 : g'.slotAmt .after = 0) (h1 : g'.slotAmt .next = g.slotAmt .after)
    (h2 : g'.slotAmt .now = g.slotAmt .next) (h3 : g'.slotAmt .always = g.slotAmt .always)
    (hd : g'.discAmt = g.discAmt) (ha : atkT A g' = 0) (hx : gxT A g' = gxT A g) :
    Inv S A g' := by
  have := atkT_le A g
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨by omega, by omega, by omega, by omega⟩

/-- The state after an attack whose resolution ended in `g`. -/
def atkRes (atk : Attack) (g : GameState) : GameState :=
  { g with attacked := true, cur := { g.cur with gxUsed := atk.gx || g.cur.gxUsed } }

theorem atkRes_slotAmt (atk : Attack) (g : GameState) (s : Slot) :
    (atkRes atk g).slotAmt s = g.slotAmt s := rfl

theorem atkRes_gxT_false {A : Nat} {atk : Attack} {g g'' : GameState} (hgv : atk.gx = false)
    (h₁ : g''.cur.gxUsed = g.cur.gxUsed) (h₂ : g''.opp.gxUsed = g.opp.gxUsed) :
    gxT A (atkRes atk g'') = gxT A g := by
  simp only [gxT, atkRes, hgv, Bool.false_or, h₁, h₂]

theorem atkRes_gxT_true {A : Nat} {atk : Attack} {g g'' : GameState} (hgv : atk.gx = true)
    (hu : g.cur.gxUsed = false) (h₂ : g''.opp.gxUsed = g.opp.gxUsed) :
    gxT A (atkRes atk g'') = gxT A g + A := by
  simp only [gxT, atkRes, hgv, Bool.true_or, h₂, hu, ite_true]
  simp only [Bool.false_eq_true, ite_false]
  omega

/-- **Every move preserves the invariant**, for cards satisfying clauses 1 and 2 that recycle
nothing (`NoRecycle`), whose Abilities write nothing (`AbilityQuiet`, milestone M8a) and whose
attacks write at most `A`. -/
theorem Inv.move {S A : Nat} {g g' : GameState} (hm : Move g g') (hi : Inv S A g)
    (hL : g.LoopFree) (hG : g.GXOnly) (hN : g.NoRecycle) (hQ : g.AbilityQuiet)
    (hSQ : g.StadiumQuiet) (hA : ∀ x ∈ g.allCards, x.atkAmt ≤ A) : Inv S A g' := by
  cases hm with
  | playBasic => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | attach => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | evolve => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | attachBench => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | evolveBench => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | retreat =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append]; omega
  | @item g' l₁ l₂ n e hh hbt hst hr hl =>
      have hx : Card.trainer n .item e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hlf : e.loopFree = true := hL _ (GameState.mem_allCards_of_hand hx)
      have hk := hr.keeps (hN _ (GameState.mem_allCards_of_hand hx))
      refine hi.trainer ⟨Nat.le_trans ?_ hk.disc, hk.attacked, hk.gxCur, hk.gxOpp⟩
        e.amtAt (hr.slot_le hlf) e.amtAt_le_amt (Nat.le_trans ?_ hk.disc)
      · simp only [GameState.discAmt, cardsAmt]; omega
      · simp only [GameState.discAmt, cardsAmt, Card.amt]; omega
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr =>
      have hx : Card.trainer n .supporter e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hlf : e.loopFree = true := hL _ (GameState.mem_allCards_of_hand hx)
      have hk := hr.keeps (hN _ (GameState.mem_allCards_of_hand hx))
      refine hi.trainer ⟨Nat.le_trans ?_ hk.disc, hk.attacked, hk.gxCur, hk.gxOpp⟩
        e.amtAt (hr.slot_le hlf) e.amtAt_le_amt (Nat.le_trans ?_ hk.disc)
      · simp only [GameState.discAmt, cardsAmt]; omega
      · simp only [GameState.discAmt, cardsAmt, Card.amt]; omega
  | stadium =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append]; omega
  | @stadiumUse g'' o n e hs hu hbt hst hat hr hnd hbh =>
      have hxC := GameState.mem_allCards_of_stadium hs
      have hlf : e.loopFree = true := hL _ hxC
      have hk' := hr.keeps (hN _ hxC)
      have h0 := hSQ n e hxC
      refine hi.keeps ⟨hk'.disc, hk'.attacked, hk'.gxCur, hk'.gxOpp⟩ fun s => ?_
      have h1 := hr.slot_le hlf s; have h2 := e.amtAt_le_amt s
      simp only [GameState.slotAmt] at h1 ⊢; omega
  | tool => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | toolBench => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | @onPlay g₁ g'' x how w ab hp hm hk hw hst₁ hcd hr hnd hbh =>
      have hxC := hp.top_mem
      have he := ab.script_mem none
      have hlf := Card.loopFree_ability (hL _ hxC) hm he
      have hk' := hr.keeps (abilitiesRec_nil (hN _ hxC) hm he)
      have h0 := hQ _ hxC ab hm _ he
      have hsl := hr.slot_le hlf
      refine hi.keeps ⟨by rw [← hp.discAmt]; exact hk'.disc, hk'.attacked.trans hp.flags.attacked,
        hk'.gxCur.trans hp.flags.gxCur, hk'.gxOpp.trans hp.flags.gxOpp⟩ fun s => ?_
      have h1 := hsl s; have h2 := (ab.script none).amtAt_le_amt s; rw [hp.slotAmt] at h1; omega
  | @ability g₁ g'' x sp ab hu hm hk hsp hn hcd hbt hst hat hr hnd hbh =>
      obtain ⟨c, hcx, hmc⟩ := InPlay.ability_mem hm
      have hxC := hu.card_mem hcx
      have he := ab.script_mem (some sp)
      have hlf := Card.loopFree_ability (hL _ hxC) hmc he
      have hk' := hr.keeps (abilitiesRec_nil (hN _ hxC) hmc he)
      have h0 := hQ _ hxC ab hmc _ he
      have hsl := hr.slot_le hlf
      refine hi.keeps ⟨by rw [← hu.discAmt]; exact hk'.disc, hk'.attacked.trans hu.flags.attacked,
        hk'.gxCur.trans hu.flags.gxCur, hk'.gxOpp.trans hu.flags.gxOpp⟩ fun s => ?_
      have h1 := hsl s; have h2 := (ab.script (some sp)).amtAt_le_amt s; rw [hu.slotAmt] at h1
      omega
  | @attack g'' a atk ha hm hc hs hn hf hbt hst hr hl hgx =>
      show Inv S A (atkRes atk g'')
      obtain ⟨c, hcx, hmc⟩ := InPlay.attack_mem hm
      have hmem := GameState.mem_allCards_of_cur_active ha hcx
      have hlf : atk.effect.loopFree = true := Card.loopFree_attack (hL _ hmem) hmc
      have hamt : atk.effect.amt ≤ A := by
        have h1 := attacksAmt_mem hmc
        have h2 := hA _ hmem
        simp only [Card.atkAmt] at h2
        omega
      have hk := hr.keeps (by rw [Attack.script_recFilters]; exact attacksRec_nil (hN _ hmem) hmc)
      have hsl := hr.slot_le (by rw [Attack.script_loopFree]; exact hlf)
      have hs' : ∀ s, (atkRes atk g'').slotAmt s ≤ g.slotAmt s + A := by
        intro s
        have h1 := hsl s
        have h2 := atk.effect.amtAt_le_amt s
        rw [Attack.script_amtAt] at h1
        rw [atkRes_slotAmt]
        omega
      refine hi.attack hn rfl hs' ?_ hk.disc
      have hal := hsl .always
      rw [Attack.script_amtAt] at hal
      rw [atkRes_slotAmt]
      cases hgv : atk.gx with
      | false =>
          have h0 := hG _ hmem atk hmc hgv
          rw [h0] at hal
          rw [atkRes_gxT_false hgv hk.gxCur hk.gxOpp]
          omega
      | true =>
          rw [atkRes_gxT_true hgv (hgx hgv) hk.gxOpp]
          have := atk.effect.amtAt_le_amt .always
          omega
  | attackConfused =>
      exact hi.frame (fun _ => Nat.le_refl _) (Nat.le_refl _) (atkT_le A g) (Nat.le_refl _)
  | knockOut =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append, PlayerState.takePrizes]; omega
  | promote => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | noPokemon => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | knockOutOwn =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append, PlayerState.takePrizes]; omega
  | knockOutBench =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append, PlayerState.takePrizes]; omega
  | knockOutBenchOwn =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append, PlayerState.takePrizes]; omega
  | promoteOwn => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | noPokemonOwn => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | endTurn =>
      exact hi.endTurn rfl (Nat.add_comm _ _) (Nat.add_comm _ _) (Nat.add_comm _ _)
        (Nat.add_comm _ _) rfl (Nat.add_comm _ _)
  | startTurn => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | deckOut => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _

/-- The bound on the stores of every state reachable from `g₀` when no card recycles: the start
stores, plus every Trainer amount among the cards, plus three attacks' worth (the bound proved
before milestone MV, as `storeBound`). -/
def storeBoundNR (g₀ : GameState) : Nat :=
  g₀.storeTotal + cardsAmt g₀.allCards + 3 * cardsAtkAmt g₀.allCards

theorem reach_inv {g₀ g : GameState} (hL : g₀.LoopFree) (hG : g₀.GXOnly) (hN : g₀.NoRecycle)
    (hQ : g₀.AbilityQuiet) (hSQ : g₀.StadiumQuiet) (h : Reach g₀ g) :
    Inv g₀.storeTotal (cardsAtkAmt g₀.allCards) g := by
  induction h with
  | refl => exact Inv.start _ _
  | step hr _ hm ih =>
      have hp := hr.perm
      exact ih.move hm (hL.of_perm hp) (hG.of_perm hp) (hN.of_perm hp) (hQ.of_perm hp)
        (hSQ.of_perm hp) (fun x hx => atkAmt_le_cardsAtkAmt (hp.mem_iff.1 hx))

theorem modsLe_of {B : Nat} {m : Mods} (h : m.amt ≤ B) : Enum.ModsLe B m := by
  unfold Mods.amt at h
  exact ⟨by omega, by omega⟩

/-- **Without recycling, the bound of master.** From a start state `g₀` satisfying clauses 1 and
2 whose cards recycle nothing (`NoRecycle`: no effect moves a card out of a discard pile to a hand
or deck; every deck before milestone MV) and whose Abilities write nothing (`AbilityQuiet`, added
by milestone M8a: an Ability writes every turn, so its amounts are not counted once per game),
every reachable state has every slot's bonus and reduction at most `storeBoundNR g₀`: each Trainer
card is then played at most once per game. This is the statement `reach_boundedStores` had before
milestone MV, with its bound; for decks without Abilities the added hypothesis holds. -/
theorem reach_boundedStores_noRecycle {g₀ g : GameState} (hL : g₀.LoopFree) (hG : g₀.GXOnly)
    (hN : g₀.NoRecycle) (hQ : g₀.AbilityQuiet) (hSQ : g₀.StadiumQuiet) (h : Reach g₀ g) :
    g.BoundedStores (storeBoundNR g₀) := by
  have hi := reach_inv hL hG hN hQ hSQ h
  have hd : g.discAmt ≤ cardsAmt g₀.allCards :=
    Nat.le_trans g.discAmt_le (Nat.le_of_eq (cardsAmt_perm h.perm))
  have ha := atkT_le (cardsAtkAmt g₀.allCards) g
  have hx := gxT_le (cardsAtkAmt g₀.allCards) g
  have hn := hi.now; have hnx := hi.next; have haf := hi.after; have hal := hi.always
  have hB : ∀ s, g.slotAmt s ≤ storeBoundNR g₀ := by
    intro s; cases s <;> simp only [storeBoundNR] <;> omega
  have hc : ∀ s, (g.cur.mods.at s).amt ≤ storeBoundNR g₀ := fun s =>
    Nat.le_trans (Nat.le_add_right _ _) (hB s)
  have ho : ∀ s, (g.opp.mods.at s).amt ≤ storeBoundNR g₀ := fun s =>
    Nat.le_trans (Nat.le_add_left _ _) (hB s)
  exact ⟨⟨modsLe_of (hc .now), modsLe_of (hc .next), modsLe_of (hc .after),
      modsLe_of (hc .always)⟩,
    ⟨modsLe_of (ho .now), modsLe_of (ho .next), modsLe_of (ho .after), modsLe_of (ho .always)⟩⟩

/-! ## The per-turn invariant (milestone MV)

With recycling a Trainer card can be played more than once per game, so the amounts in the
discard piles no longer bound what Trainers have written. They still bound what Trainers write in
one turn, under clause 3: before the turn's attack no Trainer effect and no "as often as you like"
Ability returns a non-Supporter writer from a discard pile, so each such card is played at most
once in the turn, except after a once-per-turn or on-play Ability has returned it, and at most one
Supporter is. The invariant tracks, as witnesses, the amount `X₀` Trainers and Abilities wrote this
turn, `X₁` last turn and `X₂` the turn before (each at most `2 P + Q · K`, `P` the Trainer amounts
of all cards, `Q` what one bounded Ability use can write and recycle, `K` a bound on the
potential), the weight `D` of the non-Supporter writers in the discard piles when the turn began,
and the potential `E` when the turn began (milestone M8a); carried amounts expire within three turn
boundaries, as for attacks. The rest-of-game slot is bounded as before, by the rest-of-game
Trainer amounts in the discard piles, which no effect recycles (clause 3 (b)); no Ability writes
it (clause 4). -/

/-- `P` once the player to move has played a Supporter this turn, else 0. -/
def supT (P : Nat) (g : GameState) : Nat := if g.cur.supporterPlayed then P else 0

theorem supT_le (P : Nat) (g : GameState) : supT P g ≤ P := by
  unfold supT; split <;> omega

/-- **No move but the end of the turn raises the potential** (milestone M8a). -/
theorem _root_.Pokemon.Move.abPot_le {g g' : GameState} (hm : Move g g')
    (hc : g'.curIsFirst = g.curIsFirst) : g'.abPot ≤ g.abPot := by
  cases hm with
  | @playBasic l₁ l₂ p hh hs hhp hb hbt hst hat =>
      have := optN_le g.cur.active
      simp only [benchLimit] at hb
      have e : (InPlay.ofBasic p).abW = 1 := rfl
      simp only [GameState.abPot, PlayerState.abPot, abWs_append, abWs, e, List.length_append,
        List.length_cons, List.length_nil, benchLimit]
      omega
  | @attach l₁ l₂ t a hh hf ha =>
      have e : ({ a with energy := Card.energy t :: a.energy } : InPlay).abW = a.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | @evolve l₁ l₂ p a hh ha he hfr =>
      have : a.abW ≥ 2 := by unfold InPlay.abW; rw [hfr]; split <;> simp
      have e : InPlay.abW { a with
          top := p, under := Card.pokemon a.top :: a.under, rot := .none,
          poisoned := false, burned := false, poisonUp := 0, fresh := true, used := false } = 1 :=
        rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | @attachBench l₁ l₂ t q b₁ b₂ hh hf hb =>
      simp only [GameState.abPot, PlayerState.abPot, hb,
        abWs_split (b₁ := b₁) (b₂ := b₂) (q := q)
          (q' := { q with energy := Card.energy t :: q.energy }) rfl,
        List.length_append, List.length_cons]; omega
  | @evolveBench l₁ l₂ p q b₁ b₂ hh hb he hfr =>
      have : q.abW ≥ 2 := by unfold InPlay.abW; rw [hfr]; split <;> simp
      have e : InPlay.abW { q with
          top := p, under := Card.pokemon q.top :: q.under, rot := .none,
          poisoned := false, burned := false, poisonUp := 0, fresh := true, used := false } = 1 :=
        rfl
      simp only [GameState.abPot, PlayerState.abPot, hb, abWs_append, abWs, e,
        List.length_append, List.length_cons]; omega
  | @retreat a q b₁ b₂ paid rest ha hb =>
      have e : InPlay.abW { a with
          energy := rest, rot := .none, poisoned := false, burned := false, poisonUp := 0 } =
          a.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, hb, abWo, optN, abWs_append, abWs, e,
        List.length_append, List.length_cons]; omega
  | item _ _ _ hr => exact hr.abPot_le
  | supporter _ _ _ _ hr => exact hr.abPot_le
  | stadiumUse _ _ _ _ _ hr => exact hr.abPot_le
  | stadium => exact Nat.le_refl _
  | @tool l₁ l₂ n gr a hh ha =>
      have e : ({ a with tools := [Card.tool n gr] } : InPlay).abW = a.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | @toolBench l₁ l₂ n gr q b₁ b₂ hh hb =>
      simp only [GameState.abPot, PlayerState.abPot, hb,
        abWs_split (b₁ := b₁) (b₂ := b₂) (q := q)
          (q' := { q with tools := [Card.tool n gr] }) rfl,
        List.length_append, List.length_cons]; omega
  | ability hu _ _ _ _ _ _ _ _ hr =>
      have := hu.abPot
      exact Nat.le_trans hr.abPot_le (by omega)
  | onPlay hp _ _ _ _ _ hr =>
      have := hp.abPot
      exact Nat.le_trans hr.abPot_le (by omega)
  | attack _ _ _ _ _ _ _ _ hr => exact hr.abPot_le
  | @attackConfused a atk ha =>
      have e : ({ a with damage := a.damage + 3 } : InPlay).abW = a.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | knockOut ha hk hp => exact (KOMove.knockOut ha hk hp).abPot_le
  | promote ha hb => exact (KOMove.promote ha hb).abPot_le
  | noPokemon ha hb => exact (KOMove.noPokemon ha hb).abPot_le
  | knockOutOwn ha hk hp => exact (KOMove.knockOutOwn ha hk hp).abPot_le
  | promoteOwn ha hb => exact (KOMove.promoteOwn ha hb).abPot_le
  | noPokemonOwn ha hb => exact (KOMove.noPokemonOwn ha hb).abPot_le
  | knockOutBench hb hk hp => exact (KOMove.knockOutBench hb hk hp).abPot_le
  | knockOutBenchOwn hb hk hp => exact (KOMove.knockOutBenchOwn hb hk hp).abPot_le
  | endTurn => simp at hc
  | startTurn => exact Nat.le_refl _
  | deckOut => exact Nat.le_refl _

/-- **The Stadium uses still open to the player to move this turn** (milestone M5): one if the
Stadium in play has not been used (`GameState.stadiumUsed`), one more if no Stadium has been
played (`GameState.stadiumPlayed`): a Stadium played this turn is new and can be used once. Both
flags are cleared at the end of every turn, so it is 2 when a turn begins. Using the Stadium lowers
it by one; playing a Stadium makes it 1 from at least 1; nothing else in the turn changes it. -/
def _root_.Pokemon.GameState.stPot (g : GameState) : Nat :=
  (if g.stadiumUsed then 0 else 1) + (if g.stadiumPlayed then 0 else 1)

theorem _root_.Pokemon.GameState.stPot_le (g : GameState) : g.stPot ≤ 2 := by
  unfold GameState.stPot; split <;> split <;> omega

theorem _root_.Pokemon.GameState.stPot_congr {g g' : GameState} (h₁ : g'.stadiumPlayed = g.stadiumPlayed)
    (h₂ : g'.stadiumUsed = g.stadiumUsed) : g'.stPot = g.stPot := by
  simp only [GameState.stPot, h₁, h₂]

theorem _root_.Pokemon.UseAt.stFlags {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    g₁.stadiumPlayed = g.stadiumPlayed ∧ g₁.stadiumUsed = g.stadiumUsed := by
  cases h <;> exact ⟨rfl, rfl⟩

theorem _root_.Pokemon.PlayFromHand.stFlags {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) :
    g₁.stadiumPlayed = g.stadiumPlayed ∧ g₁.stadiumUsed = g.stadiumUsed := by
  cases h <;> exact ⟨rfl, rfl⟩

/-- **No move but the end of the turn raises the Stadium potential** (milestone M5). -/
theorem _root_.Pokemon.Move.stPot_le {g g' : GameState} (hm : Move g g')
    (hc : g'.curIsFirst = g.curIsFirst) : g'.stPot ≤ g.stPot := by
  cases hm with
  | item _ _ _ hr => exact Nat.le_of_eq (GameState.stPot_congr hr.stFlags.1 hr.stFlags.2)
  | supporter _ _ _ _ hr => exact Nat.le_of_eq (GameState.stPot_congr hr.stFlags.1 hr.stFlags.2)
  | @stadium l₁ l₂ n e hh hs =>
      cases hu : g.stadiumUsed <;> simp [GameState.stPot, hs, hu]
  | @stadiumUse g' o n e hs hu _ _ _ hr =>
      rw [GameState.stPot_congr hr.stFlags.1 hr.stFlags.2]
      simp [GameState.stPot, hu]
  | ability hu _ _ _ _ _ _ _ _ hr =>
      exact Nat.le_of_eq ((GameState.stPot_congr hr.stFlags.1 hr.stFlags.2).trans
        (GameState.stPot_congr hu.stFlags.1 hu.stFlags.2))
  | onPlay hp _ _ _ _ _ hr =>
      exact Nat.le_of_eq ((GameState.stPot_congr hr.stFlags.1 hr.stFlags.2).trans
        (GameState.stPot_congr hp.stFlags.1 hp.stFlags.2))
  | attack _ _ _ _ _ _ _ _ hr =>
      exact Nat.le_of_eq (GameState.stPot_congr hr.stFlags.1 hr.stFlags.2)
  | endTurn => simp at hc
  | _ => exact Nat.le_refl _

/-- **The per-turn invariant.** The witnesses: `X₀`, `X₁`, `X₂` the amounts that Trainer cards,
Abilities and (milestone M5) Stadium effects wrote this turn, last turn and the turn before; `D`
the weight of the Item writers in the discard piles when the turn began; and (milestone M8a) `E`
the potential `GameState.abPot` when the turn began. Within the turn, before its attack, the
potential does not rise (`pot`), and `turn` says what has been written so far is paid for: by the
Item writers that went to the discard piles (each such card played this turn), by the Supporter,
by `Q` for each unit of potential spent (each "once during your turn" or on-play Ability used; `Q`
bounds what one use writes, plus what it can recycle), and (milestone M5) by `R` for each Stadium
use (`GameState.stPot` counts the uses still open, two at the start of a turn; `R` bounds what
one use writes and recycles, `Card.stQ`). -/
structure TInv (S A P Q K R : Nat) (g : GameState) (X₀ X₁ X₂ D E : Nat) : Prop where
  x0 : X₀ ≤ P + P + Q * K + R * 2
  x1 : X₁ ≤ P + P + Q * K + R * 2
  x2 : X₂ ≤ P + P + Q * K + R * 2
  e : E ≤ K
  pot : g.attacked = false → g.abPot ≤ E
  turn : g.attacked = false →
    D + X₀ + Q * g.abPot + R * g.stPot ≤ g.discW Card.wAmt + supT P g + Q * E + R * 2
  after : g.slotAmt .after ≤ S + X₀ + atkT A g
  next : g.slotAmt .next ≤ S + X₀ + X₁ + A + atkT A g
  now : g.slotAmt .now ≤ S + X₀ + X₁ + X₂ + A + A + atkT A g
  always : g.slotAmt .always ≤ S + g.discW Card.alAmt + gxT A g

theorem TInv.start (g : GameState) (A P Q K R : Nat) (hK : g.abPot ≤ K) :
    TInv g.storeTotal A P Q K R g 0 0 0 (g.discW Card.wAmt) g.abPot := by
  have := Nat.mul_le_mul_left R g.stPot_le
  refine ⟨Nat.zero_le _, Nat.zero_le _, Nat.zero_le _, hK, fun _ => Nat.le_refl _,
    fun _ => by omega, ?_, ?_, ?_, ?_⟩ <;>
    simp only [GameState.storeTotal] <;> omega

/-- A step that writes nothing and recycles no weighted card. -/
theorem TInv.frame {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E)
    (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s) (hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt)
    (hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt) (ha : atkT A g ≤ atkT A g')
    (ht : g'.attacked = false → g.attacked = false ∧ supT P g ≤ supT P g' ∧
      g'.abPot ≤ g.abPot ∧ g'.stPot ≤ g.stPot)
    (hx : gxT A g ≤ gxT A g') : TInv S A P Q K R g' X₀ X₁ X₂ D E := by
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now; have h4 := hs .always
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  refine ⟨hi.x0, hi.x1, hi.x2, hi.e, fun hf => ?_, fun hf => ?_, by omega, by omega, by omega,
    by omega⟩
  · obtain ⟨hg, -, hp, -⟩ := ht hf
    exact Nat.le_trans hp (hi.pot hg)
  · obtain ⟨hg, hsup, hp, hq⟩ := ht hf
    have := hi.turn hg
    have := Nat.mul_le_mul_left Q hp
    have := Nat.mul_le_mul_left R hq
    omega

/-- A step that changes no flag, store or discard pile weight of interest. -/
theorem TInv.same {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E)
    (hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt) (hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt)
    (ha : g'.attacked = g.attacked) (hsp : g'.cur.supporterPlayed = g.cur.supporterPlayed)
    (hgc : g'.cur.gxUsed = g.cur.gxUsed) (hgo : g'.opp.gxUsed = g.opp.gxUsed)
    (hs : ∀ s, g'.slotAmt s = g.slotAmt s) (hp : g'.abPot ≤ g.abPot)
    (hq : g'.stPot ≤ g.stPot) :
    TInv S A P Q K R g' X₀ X₁ X₂ D E :=
  hi.frame (fun s => Nat.le_of_eq (hs s)) hW hAl (Nat.le_of_eq (atkT_congr ha).symm)
    (fun hf => ⟨ha ▸ hf, by simp only [supT, hsp]; exact Nat.le_refl _, hp, hq⟩)
    (Nat.le_of_eq (gxT_congr hgc hgo).symm)

/-- The end of the turn: the witnesses move one turn back, and the potential is counted afresh
for the new player to move. -/
theorem TInv.endTurn {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E)
    (h0 : g'.slotAmt .after = 0) (h1 : g'.slotAmt .next = g.slotAmt .after)
    (h2 : g'.slotAmt .now = g.slotAmt .next) (h3 : g'.slotAmt .always = g.slotAmt .always)
    (hd : g'.discW Card.alAmt = g.discW Card.alAmt) (ha : atkT A g' = 0)
    (hx : gxT A g' = gxT A g) (hK : g'.abPot ≤ K) :
    TInv S A P Q K R g' 0 X₀ X₁ (g'.discW Card.wAmt) g'.abPot := by
  have := atkT_le A g
  have := Nat.mul_le_mul_left R g'.stPot_le
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨Nat.zero_le _, hi.x0, hi.x1, hK, fun _ => Nat.le_refl _, fun _ => by omega, by omega,
    by omega, by omega, by omega⟩

theorem Card.wAmt_le_P {g : GameState} {P : Nat} (hP : cardsAmt g.allCards ≤ P) :
    g.discW Card.wAmt ≤ P :=
  Nat.le_trans (GameState.discW_le Card.wAmt_le g) hP

/-- **One bounded use** (milestone M8a; milestone M5 added the Stadium term): a step `g → g₁`
that changes no store, discard pile or flag and pays `C` in the potential (`Q` per unit of
`abPot`, `R` per unit of `stPot`), followed by the resolution of a loop-free effect `e` that
writes no rest-of-game amount, recycles no rest-of-game writer, and has `e.amt + (P if it
recycles)` at most `C`, keeps the per-turn invariant, with `e.amt` added to this turn's writes.
This is the case of a "once during your turn" Ability used by a Pokémon that had not used one and
of an on-play Ability (`C = Q`), and of a Stadium's effect (`C = R`). -/
theorem TInv.bounded_use {S A P Q K R X₀ X₁ X₂ D E C : Nat} {g g₁ g' : GameState} {e : Effect}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hat : g.attacked = false)
    (hpot₁ : g₁.abPot ≤ g.abPot)
    (hpay : Q * g₁.abPot + R * g₁.stPot + C ≤ Q * g.abPot + R * g.stPot)
    (hsl : ∀ s, g₁.slotAmt s = g.slotAmt s)
    (hW₁ : g₁.discW Card.wAmt = g.discW Card.wAmt)
    (hAl₁ : g₁.discW Card.alAmt = g.discW Card.alAmt)
    (hfl : Flags g g₁) (hsp : g₁.cur.supporterPlayed = g.cur.supporterPlayed)
    (hp₁ : g₁.allCards.Perm g.allCards)
    (hr : TRun e g₁ g') (hlf : e.loopFree = true) (hal : e.amtAt .always = 0)
    (hq : e.q P ≤ C)
    (hrec : ∀ f ∈ e.recFilters, ∀ y ∈ g.allCards, f.eval y = true → y.alAmt = 0)
    (hP : cardsAmt g.allCards ≤ P) :
    TInv S A P Q K R g' (X₀ + e.amt) X₁ X₂ D E := by
  have hP' : cardsAmt g'.allCards ≤ P := by rw [cardsAmt_perm (hr.perm.trans hp₁)]; exact hP
  have hWle : g'.discW Card.wAmt ≤ P := Card.wAmt_le_P hP'
  have hsP := supT_le P g'
  have hEK := Nat.mul_le_mul_left Q hi.e
  have hAl₀ := hr.disc_mono Card.alAmt_tw (C := g.allCards) hrec fun y hy => hp₁.mem_iff.1 hy
  have hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt := by rw [← hAl₁]; exact hAl₀
  have hsl' := hr.slot_le hlf
  have hp2 := hr.abPot_le
  have hQ2 := Nat.mul_le_mul_left Q hp2
  have hst2 : g'.stPot = g₁.stPot := GameState.stPot_congr hr.stFlags.1 hr.stFlags.2
  have hfk := hr.flags_keep
  have hst' := hr.sameTurn
  have hsup : supT P g' = supT P g := by
    simp only [supT, show g'.cur.supporterPlayed = g.cur.supporterPlayed from
      hst'.2.2.2.2.2.2.trans hsp]
  have hat' : atkT A g' = atkT A g := atkT_congr (hfk.attacked.trans hfl.attacked)
  have hgx : gxT A g' = gxT A g :=
    gxT_congr (hfk.gxCur.trans hfl.gxCur) (hfk.gxOpp.trans hfl.gxOpp)
  have hturn := hi.turn hat
  have hpg := hi.pot hat
  have hs' : ∀ s, g'.slotAmt s ≤ g.slotAmt s + e.amtAt s := fun s => by
    rw [← hsl s]; exact hsl' s
  have h1 := hs' .after; have h2 := hs' .next; have h3 := hs' .now; have h4 := hs' .always
  have w1 := e.amtAt_le_amt .after; have w2 := e.amtAt_le_amt .next
  have w3 := e.amtAt_le_amt .now
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  rw [hal] at h4
  unfold Effect.q at hq
  have hW : g.discW Card.wAmt + e.amt ≤ g'.discW Card.wAmt + C := by
    by_cases hrf : e.recFilters = []
    · simp only [hrf, ite_true] at hq
      have hW₀ := hr.disc_mono Card.wAmt_tw (C := g.allCards) (Effect.recOk_nil hrf)
        fun y hy => hp₁.mem_iff.1 hy
      rw [hW₁] at hW₀
      omega
    · simp only [hrf, ite_false] at hq
      have := Card.wAmt_le_P (g := g) hP
      omega
  have hR2 : R * g'.stPot = R * g₁.stPot := by rw [hst2]
  exact ⟨by omega, hi.x1, hi.x2, hi.e, fun _ => by omega, fun _ => by omega, by omega, by omega,
    by omega, by omega⟩

/-- **Every move preserves the per-turn invariant**, for cards satisfying the four clauses
whose attacks write at most `A`, whose Trainer amounts add up to at most `P`, whose Abilities
have `Ability.q P` at most `Q` (milestone M8a), and whose number bounds the potential by `K`. -/
theorem TInv.move {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState} (hm : Move g g')
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hL : g.LoopFree) (hG : g.GXOnly) (hR : g.RecycleSafe)
    (hAb : g.AbilitySafe) (hSS : g.StadiumSafe) (hA : ∀ x ∈ g.allCards, x.atkAmt ≤ A)
    (hP : cardsAmt g.allCards ≤ P)
    (hQ : ∀ c ∈ g.allCards, ∀ ab ∈ c.abilities, ab.q P ≤ Q)
    (hRq : ∀ x ∈ g.allCards, x.stQ P ≤ R) (hK : potBound g.allCards.length ≤ K) :
    ∃ Y₀ Y₁ Y₂ E' F, TInv S A P Q K R g' Y₀ Y₁ Y₂ E' F := by
  have hP' : cardsAmt g'.allCards ≤ P := by rw [cardsAmt_perm hm.perm]; exact hP
  have hWle : g'.discW Card.wAmt ≤ P := Card.wAmt_le_P hP'
  have hWle₀ : g.discW Card.wAmt ≤ P := Card.wAmt_le_P hP
  have hsP := supT_le P g'
  have hEK := Nat.mul_le_mul_left Q hi.e
  have hpot := hm.abPot_le
  have hstp := hm.stPot_le
  cases hm with
  | playBasic => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | attach => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | evolve => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | attachBench => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | evolveBench => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | retreat =>
      exact ⟨_, _, _, _, _, hi.same (by simp only [GameState.discW, wsum_append]; omega)
        (by simp only [GameState.discW, wsum_append]; omega) rfl rfl rfl rfl (fun _ => rfl)
        (hpot rfl) (hstp rfl)⟩
  | stadium =>
      exact ⟨_, _, _, _, _, hi.same (by simp only [GameState.discW, wsum_append]; omega)
        (by simp only [GameState.discW, wsum_append]; omega) rfl rfl rfl rfl (fun _ => rfl)
        (hpot rfl) (hstp rfl)⟩
  | tool => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | toolBench => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | @item g' l₁ l₂ n e hh hbt hst hr hl hat hnd hbh =>
      have hx : Card.trainer n .item e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hxC := GameState.mem_allCards_of_hand hx
      have hlf : e.loopFree = true := hL _ hxC
      have hp₁ : ({ g with cur := { g.cur with
          hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } :
          GameState).allCards.Perm g.allCards := by perm_count [hh]
      have hW₀ := hr.disc_mono Card.wAmt_tw (C := g.allCards)
        (fun f hf y hy hfy => hR.1 _ hxC f hf y hy hfy) fun y hy => hp₁.mem_iff.1 hy
      have hAl₀ := hr.disc_mono Card.alAmt_tw (C := g.allCards)
        (fun f hf y hy hfy => hR.2 _ hxC f hf y hy hfy) fun y hy => hp₁.mem_iff.1 hy
      have ew : Card.wAmt (.trainer n .item e) = e.amt := rfl
      have ea : Card.alAmt (.trainer n .item e) = e.amtAt .always := rfl
      have hW : g.discW Card.wAmt + e.amt ≤ g'.discW Card.wAmt := by
        simp only [GameState.discW, wsum] at hW₀ ⊢; omega
      have hAl : g.discW Card.alAmt + e.amtAt .always ≤ g'.discW Card.alAmt := by
        simp only [GameState.discW, wsum] at hAl₀ ⊢; omega
      have hf := hr.flags_keep
      have hst' := hr.sameTurn
      have hsl : ∀ s, g'.slotAmt s ≤ g.slotAmt s + e.amtAt s := hr.slot_le hlf
      have hsup : supT P g' = supT P g := by
        have e2 : g'.cur.supporterPlayed = g.cur.supporterPlayed := hst'.2.2.2.2.2.2
        simp only [supT, e2]
      have hat' : atkT A g' = atkT A g := atkT_congr hf.attacked
      have hgx : gxT A g' = gxT A g := gxT_congr hf.gxCur hf.gxOpp
      have hturn := hi.turn hat
      have hpg := hi.pot hat
      have hp := hpot hst'.1
      have hQp := Nat.mul_le_mul_left Q hp
      have hRp := Nat.mul_le_mul_left R (hstp hst'.1)
      have h1 := hsl .after; have h2 := hsl .next; have h3 := hsl .now; have h4 := hsl .always
      have w1 := e.amtAt_le_amt .after; have w2 := e.amtAt_le_amt .next
      have w3 := e.amtAt_le_amt .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀ + e.amt, X₁, X₂, D, E, by omega, hi.x1, hi.x2, hi.e,
        fun _ => Nat.le_trans hp hpg, fun _ => by omega, by omega, by omega, by omega, by omega⟩
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr hat hf hnd hbh =>
      have hx : Card.trainer n .supporter e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hxC := GameState.mem_allCards_of_hand hx
      have hlf : e.loopFree = true := hL _ hxC
      have hp₁ : ({ g with cur := { g.cur with
          hand := l₁ ++ l₂, supporterPlayed := true,
          discard := Card.trainer n .supporter e :: g.cur.discard } } :
          GameState).allCards.Perm g.allCards := by perm_count [hh]
      have hW₀ := hr.disc_mono Card.wAmt_tw (C := g.allCards)
        (fun f hf y hy hfy => hR.1 _ hxC f hf y hy hfy) fun y hy => hp₁.mem_iff.1 hy
      have hAl₀ := hr.disc_mono Card.alAmt_tw (C := g.allCards)
        (fun f hf y hy hfy => hR.2 _ hxC f hf y hy hfy) fun y hy => hp₁.mem_iff.1 hy
      have ew : Card.wAmt (.trainer n .supporter e) = 0 := rfl
      have ea : Card.alAmt (.trainer n .supporter e) = e.amtAt .always := rfl
      have hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt := by
        simp only [GameState.discW, wsum] at hW₀ ⊢; omega
      have hAl : g.discW Card.alAmt + e.amtAt .always ≤ g'.discW Card.alAmt := by
        simp only [GameState.discW, wsum] at hAl₀ ⊢; omega
      have hfk := hr.flags_keep
      have hst' := hr.sameTurn
      have hsl : ∀ s, g'.slotAmt s ≤ g.slotAmt s + e.amtAt s := hr.slot_le hlf
      have hsup0 : supT P g = 0 := by simp only [supT, hs]; rfl
      have hsup1 : supT P g' = P := by
        have e2 : g'.cur.supporterPlayed = true := hst'.2.2.2.2.2.2
        simp only [supT, e2]; rfl
      have hamt : e.amt ≤ P := Nat.le_trans (amt_le_cardsAmt hxC) hP
      have hat' : atkT A g' = atkT A g := atkT_congr hfk.attacked
      have hgx : gxT A g' = gxT A g := gxT_congr hfk.gxCur hfk.gxOpp
      have hturn := hi.turn hat
      have hpg := hi.pot hat
      have hp := hpot hst'.1
      have hQp := Nat.mul_le_mul_left Q hp
      have hRp := Nat.mul_le_mul_left R (hstp hst'.1)
      have h1 := hsl .after; have h2 := hsl .next; have h3 := hsl .now; have h4 := hsl .always
      have w1 := e.amtAt_le_amt .after; have w2 := e.amtAt_le_amt .next
      have w3 := e.amtAt_le_amt .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀ + e.amt, X₁, X₂, D, E, by omega, hi.x1, hi.x2, hi.e,
        fun _ => Nat.le_trans hp hpg, fun _ => by omega, by omega, by omega, by omega, by omega⟩
  | @stadiumUse g' o n e hs hu hbt hst hat hr hnd hbh =>
      have hxC := GameState.mem_allCards_of_stadium hs
      have hpay : Q * ({ g with stadiumUsed := true } : GameState).abPot +
          R * ({ g with stadiumUsed := true } : GameState).stPot + R ≤
          Q * g.abPot + R * g.stPot := by
        have e1 : ({ g with stadiumUsed := true } : GameState).stPot + 1 = g.stPot := by
          simp only [GameState.stPot, hu]; simp; omega
        have e2 : R * ({ g with stadiumUsed := true } : GameState).stPot + R = R * g.stPot := by
          rw [← e1, Nat.mul_add, Nat.mul_one]
        have e3 : Q * ({ g with stadiumUsed := true } : GameState).abPot = Q * g.abPot := rfl
        omega
      exact ⟨_, _, _, _, _, hi.bounded_use (g₁ := { g with stadiumUsed := true }) hat
        (Nat.le_refl _) hpay (fun _ => rfl) rfl rfl
        ⟨rfl, rfl, rfl⟩ rfl (List.Perm.refl _) hr (hL _ hxC) (hSS.get hxC) (hRq _ hxC)
        (fun f hf y hy hfy => hR.2 _ hxC f hf y hy hfy) hP⟩
  | @ability g₁ g' x sp ab hu hm hk hsp hn hcd hbt hst hat hr hnd hbh =>
      obtain ⟨c, hcx, hmc⟩ := InPlay.ability_mem hm
      have hxC := hu.card_mem hcx
      have he := ab.script_mem (some sp)
      have hlf := Card.loopFree_ability (hL _ hxC) hmc he
      have hsafe := hAb.get hxC hmc he
      have hrec : ∀ f ∈ (ab.script (some sp)).recFilters, ∀ y ∈ g.allCards, f.eval y = true →
          y.alAmt = 0 := fun f hf y hy hfy =>
        hR.2 _ hxC f (Card.allRec_of_ability hmc he hf) y hy hfy
      have hs₁ : g₁.stPot = g.stPot := GameState.stPot_congr hu.stFlags.1 hu.stFlags.2
      cases hab : ab.use with
      | onPlay w => rw [hab] at hk; cases hk
      | once =>
          have hu0 : x.used = false := hn hab
          have hpu := hu.abPot
          rw [hu0] at hpu
          have hpu' : g₁.abPot + 1 ≤ g.abPot := by simp at hpu; omega
          have hpay : Q * g₁.abPot + R * g₁.stPot + Q ≤ Q * g.abPot + R * g.stPot := by
            have := Nat.mul_le_mul_left Q hpu'
            rw [Nat.mul_add, Nat.mul_one] at this
            rw [hs₁]; omega
          exact ⟨_, _, _, _, _, hi.bounded_use hat (by omega) hpay hu.slotAmt (hu.discW _)
            (hu.discW _) hu.flags hu.supporterPlayed hu.perm hr hlf hsafe.2
            (Nat.le_trans (Ability.q_script he) (hQ _ hxC ab hmc)) hrec hP⟩
      | unlimited =>
          have hp₁ := hu.perm
          have hAl₀ := hr.disc_mono Card.alAmt_tw (C := g.allCards) hrec
            fun y hy => hp₁.mem_iff.1 hy
          have hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt := by rw [← hu.discW]; exact hAl₀
          have hsl := hr.slot_le hlf
          have hpu := hu.abPot
          have hp2 := hr.abPot_le
          have hfk := hr.flags_keep
          have hfu := hu.flags
          have hst' := hr.sameTurn
          have hsup : supT P g' = supT P g := by
            simp only [supT, show g'.cur.supporterPlayed = g.cur.supporterPlayed from
              hst'.2.2.2.2.2.2.trans hu.supporterPlayed]
          have hat' : atkT A g' = atkT A g := atkT_congr (hfk.attacked.trans hfu.attacked)
          have hgx : gxT A g' = gxT A g := gxT_congr (hfk.gxCur.trans hfu.gxCur)
            (hfk.gxOpp.trans hfu.gxOpp)
          have hturn := hi.turn hat
          have hpg := hi.pot hat
          have hs' : ∀ s, g'.slotAmt s ≤ g.slotAmt s + (ab.script (some sp)).amtAt s := fun s => by
            rw [← hu.slotAmt s]; exact hsl s
          have h1 := hs' .after; have h2 := hs' .next; have h3 := hs' .now
          have h4 := hs' .always
          have w1 := (ab.script (some sp)).amtAt_le_amt .after
          have w2 := (ab.script (some sp)).amtAt_le_amt .next
          have w3 := (ab.script (some sp)).amtAt_le_amt .now
          have := hi.after; have := hi.next; have := hi.now; have := hi.always
          rw [hsafe.2] at h4
          have h0 := hsafe.1 hab
          have hW₀ := hr.disc_mono Card.wAmt_tw (C := g.allCards)
            (fun f hf y hy hfy => hR.1 _ hxC f (Card.freeRec_of_unlimited hmc hab he hf) y hy hfy)
            fun y hy => hp₁.mem_iff.1 hy
          have hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt := by rw [← hu.discW]; exact hW₀
          have hp : g'.abPot ≤ g.abPot := Nat.le_trans hp2 (by omega)
          have hQp := Nat.mul_le_mul_left Q hp
          have hsq : g'.stPot = g.stPot :=
            (GameState.stPot_congr hr.stFlags.1 hr.stFlags.2).trans hs₁
          have hRp : R * g'.stPot = R * g.stPot := by rw [hsq]
          exact ⟨X₀, X₁, X₂, D, E, hi.x0, hi.x1, hi.x2, hi.e, fun _ => Nat.le_trans hp hpg,
            fun _ => by omega, by omega, by omega, by omega, by omega⟩
  | @onPlay g₁ g' x how w ab hp hm hk hw hst₁ hcd hr hnd hbh =>
      have hxC := hp.top_mem
      have he := ab.script_mem none
      have hsafe := hAb.get hxC hm he
      have hs₁ : g₁.stPot = g.stPot := GameState.stPot_congr hp.stFlags.1 hp.stFlags.2
      have hpay : Q * g₁.abPot + R * g₁.stPot + Q ≤ Q * g.abPot + R * g.stPot := by
        have := Nat.mul_le_mul_left Q hp.abPot
        rw [Nat.mul_add, Nat.mul_one] at this
        rw [hs₁]; omega
      exact ⟨_, _, _, _, _, hi.bounded_use hp.attacked (by have := hp.abPot; omega) hpay
        hp.slotAmt (hp.discW _) (hp.discW _) hp.flags hp.supporterPlayed hp.perm hr
        (Card.loopFree_ability (hL _ hxC) hm he) hsafe.2
        (Nat.le_trans (Ability.q_script he) (hQ _ hxC ab hm))
        (fun f hf y hy hfy => hR.2 _ hxC f (Card.allRec_of_ability (c := .pokemon x.top) hm he hf)
          y hy hfy) hP⟩
  | @attack g'' a atk ha hm hc hs hn hf hbt hst hr hl hgx =>
      show ∃ Y₀ Y₁ Y₂ E' F, TInv S A P Q K R (atkRes atk g'') Y₀ Y₁ Y₂ E' F
      obtain ⟨c, hcx, hmc⟩ := InPlay.attack_mem hm
      have hmem := GameState.mem_allCards_of_cur_active ha hcx
      have hlf : atk.effect.loopFree = true := Card.loopFree_attack (hL _ hmem) hmc
      have hamt : atk.effect.amt ≤ A := by
        have h1 := attacksAmt_mem hmc
        have h2 := hA _ hmem
        simp only [Card.atkAmt] at h2
        omega
      have hfk := hr.flags_keep
      have hAl : g.discW Card.alAmt ≤ (atkRes atk g'').discW Card.alAmt :=
        hr.disc_mono Card.alAmt_tw (C := g.allCards)
          (fun f hf y hy hfy => hR.2 _ hmem f
            (Card.allRec_of_attack hmc (by rw [Attack.script_recFilters] at hf; exact hf)) y hy hfy)
          fun _ hy => hy
      have hsl := hr.slot_le (by rw [Attack.script_loopFree]; exact hlf)
      have hs' : ∀ s, (atkRes atk g'').slotAmt s ≤ g.slotAmt s + A := by
        intro s
        have h1 := hsl s
        have h2 := atk.effect.amtAt_le_amt s
        rw [Attack.script_amtAt] at h1
        rw [atkRes_slotAmt]
        omega
      have e0 : atkT A g = 0 := by simp only [atkT, hn]; rfl
      have e1 : atkT A (atkRes atk g'') = A := rfl
      have hal' : (atkRes atk g'').slotAmt .always + gxT A g ≤
          g.slotAmt .always + gxT A (atkRes atk g'') := by
        have hal := hsl .always
        rw [Attack.script_amtAt] at hal
        rw [atkRes_slotAmt]
        cases hgv : atk.gx with
        | false =>
            have h0 := hG _ hmem atk hmc hgv
            rw [h0] at hal
            rw [atkRes_gxT_false hgv hfk.gxCur hfk.gxOpp]
            omega
        | true =>
            rw [atkRes_gxT_true hgv (hgx hgv) hfk.gxOpp]
            have := atk.effect.amtAt_le_amt .always
            omega
      have h1 := hs' .after; have h2 := hs' .next; have h3 := hs' .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀, X₁, X₂, D, E, hi.x0, hi.x1, hi.x2, hi.e, fun h => absurd h (by simp [atkRes]),
        fun h => absurd h (by simp [atkRes]), by omega, by omega, by omega, by omega⟩
  | attackConfused =>
      exact ⟨_, _, _, _, _, hi.frame (fun _ => Nat.le_refl _) (Nat.le_refl _) (Nat.le_refl _)
        (atkT_le A g) (fun h => absurd h (by simp)) (Nat.le_refl _)⟩
  | knockOut =>
      exact ⟨_, _, _, _, _, hi.same
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        rfl rfl rfl rfl (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | promote => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | noPokemon => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | knockOutOwn =>
      exact ⟨_, _, _, _, _, hi.same
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        rfl rfl rfl rfl (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | knockOutBench =>
      exact ⟨_, _, _, _, _, hi.same
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        rfl rfl rfl rfl (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | knockOutBenchOwn =>
      exact ⟨_, _, _, _, _, hi.same
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        rfl rfl rfl rfl (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | promoteOwn => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | noPokemonOwn => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | @endTurn a b bo bc fa sa ca fb sb cb ha hb hk hbt hco hcc =>
      refine ⟨_, _, _, _, _, hi.endTurn rfl (Nat.add_comm _ _) (Nat.add_comm _ _)
        (Nat.add_comm _ _) (Nat.add_comm _ _) rfl (Nat.add_comm _ _) ?_⟩
      have hperm := (Move.endTurn fa sa ca fb sb cb ha hb hk hbt hco hcc).perm
      exact Nat.le_trans (GameState.abPot_le_bound _) (by rw [hperm.length_eq]; exact hK)
  | startTurn => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | deckOut => exact ⟨_, _, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩

/-- The bound on the stores of every state reachable from `g₀` (milestone MV; milestone M8a
added the third term, milestone M5 the fourth): the start stores, plus three turns of Trainer,
Ability and Stadium writes (each turn at most twice the Trainer amounts of the cards, plus `Q` for
each unit of the potential, which is at most `potBound` of the number of cards, plus two Stadium
uses of at most `cardsStQ` each), plus three attacks' worth. For a deck without Abilities
`cardsAbQ` is 0, and for a deck without Stadium cards `cardsStQ` is 0; for a deck with neither the
bound is the bound of milestone MV, `storeTotal + 6 · cardsAmt + 3 · cardsAtkAmt`. The per-game
bound of master is `storeBoundNR g₀`, which still holds for decks that recycle nothing and whose
Abilities and Stadiums write nothing (`reach_boundedStores_noRecycle`). -/
def storeBound (g₀ : GameState) : Nat :=
  g₀.storeTotal + 6 * cardsAmt g₀.allCards +
    3 * (cardsAbQ (cardsAmt g₀.allCards) g₀.allCards * potBound g₀.allCards.length) +
    6 * cardsStQ (cardsAmt g₀.allCards) g₀.allCards +
    3 * cardsAtkAmt g₀.allCards

theorem reach_tinv {g₀ g : GameState} (hF : g₀.Faithful) (h : Reach g₀ g) :
    ∃ X₀ X₁ X₂ D E, TInv g₀.storeTotal (cardsAtkAmt g₀.allCards) (cardsAmt g₀.allCards)
      (cardsAbQ (cardsAmt g₀.allCards) g₀.allCards) (potBound g₀.allCards.length)
      (cardsStQ (cardsAmt g₀.allCards) g₀.allCards) g X₀ X₁ X₂ D E := by
  induction h with
  | refl => exact ⟨_, _, _, _, _, TInv.start _ _ _ _ _ _ (GameState.abPot_le_bound _)⟩
  | step hr _ hm ih =>
      obtain ⟨X₀, X₁, X₂, D, E, hi⟩ := ih
      have hp := hr.perm
      exact hi.move hm (hF.1.of_perm hp) (hF.2.1.of_perm hp) (hF.2.2.1.of_perm hp)
        (hF.2.2.2.1.of_perm hp) (hF.2.2.2.2.of_perm hp)
        (fun x hx => atkAmt_le_cardsAtkAmt (hp.mem_iff.1 hx))
        (Nat.le_of_eq (cardsAmt_perm hp))
        (fun p hx ab hab => Ability.q_le (hp.mem_iff.1 hx) hab)
        (fun x hx => stQ_le_cardsStQ (hp.mem_iff.1 hx))
        (by rw [hp.length_eq]; exact Nat.le_refl _)

/-- **For a faithful deck the stores stay bounded.** From a start state `g₀` satisfying
`Faithful` (clauses 1–5), every reachable state has, in both players' stores, every slot's damage
bonus and damage reduction at most `storeBound g₀`, which is computed from the start state's stores
and cards. Milestone MV changed the hypothesis (clause 3, `RecycleSafe`, which every deck without
recycling satisfies) and the bound (`storeBound` counts six times the Trainer amounts, a per-turn
count; the per-game bound of master is `reach_boundedStores_noRecycle`). Milestone M8a added
clause 4 (`AbilitySafe`) to the hypothesis and the Ability term to the bound; for a deck without
Abilities both changes are void. Milestone M5 added clause 5 (`StadiumSafe`) and the Stadium term;
for a deck without Stadium cards both are void (`Pokemon/NoStadiums.lean`). -/
theorem reach_boundedStores {g₀ g : GameState} (hF : g₀.Faithful) (h : Reach g₀ g) :
    g.BoundedStores (storeBound g₀) := by
  obtain ⟨X₀, X₁, X₂, D, E, hi⟩ := reach_tinv hF h
  have hd : g.discW Card.alAmt ≤ cardsAmt g₀.allCards :=
    Nat.le_trans (GameState.discW_le Card.alAmt_le g) (Nat.le_of_eq (cardsAmt_perm h.perm))
  have ha := atkT_le (cardsAtkAmt g₀.allCards) g
  have hx := gxT_le (cardsAtkAmt g₀.allCards) g
  have := hi.x0; have := hi.x1; have := hi.x2
  have hn := hi.now; have hnx := hi.next; have haf := hi.after; have hal := hi.always
  have hB : ∀ s, g.slotAmt s ≤ storeBound g₀ := by
    intro s; cases s <;> simp only [storeBound] <;> omega
  have hc : ∀ s, (g.cur.mods.at s).amt ≤ storeBound g₀ := fun s =>
    Nat.le_trans (Nat.le_add_right _ _) (hB s)
  have ho : ∀ s, (g.opp.mods.at s).amt ≤ storeBound g₀ := fun s =>
    Nat.le_trans (Nat.le_add_left _ _) (hB s)
  exact ⟨⟨modsLe_of (hc .now), modsLe_of (hc .next), modsLe_of (hc .after),
      modsLe_of (hc .always)⟩,
    ⟨modsLe_of (ho .now), modsLe_of (ho .next), modsLe_of (ho .after), modsLe_of (ho .always)⟩⟩


/-- **Finiteness for faithful decks.** Let `g₀` be any start state (well-formed or not) whose
cards satisfy `Faithful` (no damage bonus or reduction under `iter`; rest-of-game bonuses and
reductions only from GX attacks, which the rules make once per player per game; since milestone MV,
clause 3: no Trainer effect recycles a non-Supporter writer, and no effect a rest-of-game writer;
since milestone M8a, clause 3 (a) for "as often as you like" Abilities too, and clause 4: no such
Ability writes a bonus or reduction, no Ability a rest-of-game one).
Then

* the `xclamp`s of all states reachable from `g₀` lie in one finite list `L`; and
* the kernel of `xclamp` is a two-way bisimulation along reachable states: if `g₁` is reachable
  and `g₂` has the same `xclamp`, every move from either is matched by a move from the other to
  a state with the same `xclamp`.

So the quotient of the reachable states by `xclamp` is a finite transition system with the same
moves. Unlike `Reach.finite`, this allows damage reduction, `drain`, and carried and
rest-of-game modifiers (the latter only from GX attacks and Trainer cards); unlike
`Reach.finite`, it forbids amounts under `iter`. The bisimulation half holds for all pairs of
states with equal `xclamp` (`GameState.xclamp_bisim`). The list is not computed and the quotient's moves are not shown
computable. -/
theorem xfinite {g₀ : GameState} (hF : g₀.Faithful) :
    (∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp ∈ L) ∧
      ∀ g₁ g₂, Reach g₀ g₁ → g₁.xclamp = g₂.xclamp →
        (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp) ∧
        (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧ g₂'.xclamp = g₁'.xclamp) := by
  obtain ⟨L, hL⟩ := Reach.xclamp_mem_bounded (storeBound g₀)
  exact ⟨⟨L, fun g h => hL g h (reach_boundedStores hF h)⟩,
    fun _ _ h hc => Reach.xclamp_bisim h hc⟩

end Faithful

end Pokemon
