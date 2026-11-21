import Pokemon.Bounded
import Pokemon.Counter

/-!
# Faithful decks: the stores stay bounded, so the exact-store quotient is finite

`Pokemon/Bounded.lean` proves finiteness up to `xclamp` on the reachable states whose stores are
bounded. This file gives a condition on the deck under which every reachable state has bounded
stores, at a bound computed from the start state, and so finiteness for those decks without
further hypothesis.

**The deck condition** (`GameState.Faithful`, on the cards of the start state; play only
permutes cards, so it holds all game):
* `LoopFree` (clause 1): no effect, of an attack or of a Trainer card, contains a damage bonus
  or damage reduction (`linger … (bonus n)`, `linger … (reduce n)`) under `iter`. Locks and
  prevention may appear anywhere; they are flags.
* `GXOnly` (clause 2): every attack whose effect can write a rest-of-game damage bonus or
  reduction (`Slot.always`) is a GX attack (`Attack.gx`). Trainer cards may write rest-of-game
  amounts; their number is bounded by the cards (below).

**Why it bounds the stores.** Each resolution of a loop-free effect `e` adds at most
`e.amtAt s` to the amounts in slot `s` (`Run.slot_le`, `TRun.slot_le`). The writers are:
* Item and Supporter cards. A played Trainer goes to the discard pile, and **nothing in this
  model moves a card out of a discard pile**: no effect primitive, Knock Out or other move takes
  a card from a discard pile to the hand, deck or play (cards move from deck to hand, hand to
  deck bottom, Prizes to hand, and hand, play and Energy to the discard pile). So every Trainer
  card is played at most once per game, and the amounts written by Trainers over a whole game
  are at most the sum `cardsAmt` of their effects' amounts over the cards of the game. This uses
  no assumption about recycling loops: the model has none.
* Attacks. At most one attack per turn (`GameState.attacked`, reset only by `endTurn`), each
  writing at most `A = cardsAtkAmt` (the largest attack amount among the cards). Amounts written
  for this turn, the next or the one after expire within three turn boundaries (`Store.shift`),
  so at most three attacks' carried amounts are live at once. Rest-of-game amounts come only
  from GX attacks (clause 2), and the rule change below makes those once per player per game.

The invariant (`Faithful.Inv`) bounds, for each slot, the sum over both players by the start
stores, plus the Trainer amounts already discarded, plus `A` for each attack that can still be
live in that slot. `Faithful.reach_boundedStores` concludes `BoundedStores (storeBound g₀)` for
every reachable state, with `storeBound g₀ = storeTotal g₀ + cardsAmt C + 3 · cardsAtkAmt C`
(`C` the cards of `g₀`).

**Results.**
* `Faithful.reach_boundedStores`: for a start satisfying `Faithful`, every reachable state has
  stores bounded by `storeBound g₀`.
* `Faithful.xfinite`: from a well-formed `Faithful` start, the `xclamp`s of all reachable states
  lie in one finite list, and the kernel of `xclamp` is a two-way bisimulation along reachable
  states. No tameness: damage reduction (Iron Defender), `drain`, carried bonuses and
  reductions, and rest-of-game modifiers from GX attacks are all allowed.

**Rule change** (in `Pokemon/Rules.lean` and `Pokemon/Card.lean`): `Attack` has a new field
`gx`; `Move.attack` requires `atk.gx = true → g.cur.gxUsed = false` and sets the attacker's
`gxUsed` when `atk.gx` (the result's `gxUsed` is `atk.gx || gxUsed`). Before, `gxUsed` was never
read or written. Every theorem that mentions attacks was re-proved; `Counter.universal` is
unchanged in statement (its attacks have `gx = false`).

**What the condition does not cover.** Printed behaviours outside it, or outside the model:
* a card-recycling loop (returning Items from the discard pile) would replay a carried-modifier
  Item such as Iron Defender without bound; the model has no recycling, so the bound by card
  count is a property of the model, not a claim about the printed card pool;
* "attack twice", "attack again" after a Knock Out, and "take another turn" are not modelled;
  with them more than one attack's amounts would be written per turn;
* the Poet's guess-and-verify coupling (one replayable effect writing a this-turn and a carried
  modifier together) is excluded inside one effect by clause 1 (no amount under `iter`) and is
  harmless across effects: an attack writes a bounded amount once per turn, and an Item or
  Supporter is played at most once per game, so the replays needed to guess an unbounded value
  do not exist; a recycling loop would bring them back;
* rest-of-game modifiers from VSTAR Powers, Abilities or Stadiums are not modelled (`vstarUsed`
  is unused).
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

def Card.atkAmt : Card → Nat
  | .pokemon p => attacksAmt p.attacks
  | _ => 0

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

/-- Clause 1 for one card: every effect on it is loop-free. -/
def Card.loopFree : Card → Bool
  | .pokemon p => p.attacks.all fun a => a.effect.loopFree
  | .energy _ => true
  | .trainer _ _ e => e.loopFree

/-- **Clause 1** (`LoopFree`): no effect of any card in the game has a damage bonus or
reduction under `iter`. -/
def GameState.LoopFree (g : GameState) : Prop := ∀ x ∈ g.allCards, x.loopFree = true

/-- **Clause 2** (`GXOnly`): an attack that is not a GX attack writes no rest-of-game damage
bonus or reduction. -/
def GameState.GXOnly (g : GameState) : Prop :=
  ∀ p : PokemonCard, Card.pokemon p ∈ g.allCards → ∀ atk ∈ p.attacks, atk.gx = false →
    atk.effect.amtAt .always = 0

/-- **Faithful decks**: both clauses. -/
def GameState.Faithful (g : GameState) : Prop := g.LoopFree ∧ g.GXOnly

theorem GameState.LoopFree.of_perm {g g' : GameState} (h : g.LoopFree)
    (hp : g'.allCards.Perm g.allCards) : g'.LoopFree :=
  fun x hx => h x (hp.mem_iff.1 hx)

theorem GameState.GXOnly.of_perm {g g' : GameState} (h : g.GXOnly)
    (hp : g'.allCards.Perm g.allCards) : g'.GXOnly :=
  fun p hx => h p (hp.mem_iff.1 hx)

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
  | linger w s m g =>
      intro _ s'
      rw [GameState.slotAmt_linger]
      exact Nat.le_refl _
  | _ => intro _ s; exact Nat.le_add_right _ _

/-! ## What else a resolution keeps -/

/-- What every resolution and every Knock Out keeps: the discard piles only grow, and the
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

theorem Run.keeps {e : Effect} {g g' : GameState} (h : Run e g g') : Keeps g g' := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact Keeps.refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | @touchActive e w f g p he h => cases w <;> exact ⟨Nat.le_refl _, rfl, rfl, rfl⟩
  | @touchBench e w f g q b₁ b₂ he h => cases w <;> exact ⟨Nat.le_refl _, rfl, rfl, rfl⟩
  | unmark w m g => cases w <;> exact ⟨Nat.le_refl _, rfl, rfl, rfl⟩
  | linger w s m g => cases w <;> exact ⟨Nat.le_refl _, rfl, rfl, rfl⟩
  | _ => exact ⟨Nat.le_refl _, rfl, rfl, rfl⟩

theorem KOMove.keeps {g g' : GameState} (h : KOMove g g') :
    Keeps g g' ∧ ∀ s, g'.slotAmt s = g.slotAmt s := by
  cases h with
  | knockOut =>
      refine ⟨⟨?_, rfl, rfl, rfl⟩, fun _ => rfl⟩
      simp only [GameState.discAmt, cardsAmt_append]; omega
  | knockOutOwn =>
      refine ⟨⟨?_, rfl, rfl, rfl⟩, fun _ => rfl⟩
      simp only [GameState.discAmt, cardsAmt_append]; omega
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

theorem TRun.keeps {e : Effect} {g g' : GameState} (h : TRun e g g') : Keeps g g' := by
  induction h with
  | prim _ _ hr hk => exact hr.keeps.trans hk.keeps.1
  | stop => exact Keeps.refl _
  | iteT _ _ _ _ ih => exact ih
  | iteF _ _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact Keeps.refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₁.trans ih₂

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

/-- **Every move preserves the invariant**, for cards satisfying both clauses whose attacks
write at most `A`. -/
theorem Inv.move {S A : Nat} {g g' : GameState} (hm : Move g g') (hi : Inv S A g)
    (hL : g.LoopFree) (hG : g.GXOnly)
    (hA : ∀ x ∈ g.allCards, x.atkAmt ≤ A) : Inv S A g' := by
  cases hm with
  | playBasic => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | attach => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | evolve => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | retreat =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append]; omega
  | @item g' l₁ l₂ n e hh hbt hst hr hl =>
      have hx : Card.trainer n .item e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hlf : e.loopFree = true := hL _ (GameState.mem_allCards_of_hand hx)
      have hk := hr.keeps
      refine hi.trainer ⟨Nat.le_trans ?_ hk.disc, hk.attacked, hk.gxCur, hk.gxOpp⟩
        e.amtAt (hr.slot_le hlf) e.amtAt_le_amt (Nat.le_trans ?_ hk.disc)
      · simp only [GameState.discAmt, cardsAmt]; omega
      · simp only [GameState.discAmt, cardsAmt, Card.amt]; omega
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr =>
      have hx : Card.trainer n .supporter e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hlf : e.loopFree = true := hL _ (GameState.mem_allCards_of_hand hx)
      have hk := hr.keeps
      refine hi.trainer ⟨Nat.le_trans ?_ hk.disc, hk.attacked, hk.gxCur, hk.gxOpp⟩
        e.amtAt (hr.slot_le hlf) e.amtAt_le_amt (Nat.le_trans ?_ hk.disc)
      · simp only [GameState.discAmt, cardsAmt]; omega
      · simp only [GameState.discAmt, cardsAmt, Card.amt]; omega
  | @attack g'' a atk ha hm hc hs hn hf hbt hst hr hl hgx =>
      show Inv S A (atkRes atk g'')
      have hmem := GameState.top_mem_cur_active ha
      have hlf : atk.effect.loopFree = true := List.all_eq_true.1 (hL _ hmem) atk hm
      have hamt : atk.effect.amt ≤ A := by
        have h1 := attacksAmt_mem hm
        have h2 := hA _ hmem
        simp only [Card.atkAmt] at h2
        omega
      have hk := hr.keeps
      have hsl := hr.slot_le (by simp only [Effect.loopFree, hlf, Bool.and_self])
      have hs' : ∀ s, (atkRes atk g'').slotAmt s ≤ g.slotAmt s + A := by
        intro s
        have h1 := hsl s
        have h2 := atk.effect.amtAt_le_amt s
        simp only [Effect.amtAt, Nat.zero_add] at h1
        rw [atkRes_slotAmt]
        omega
      refine hi.attack hn rfl hs' ?_ hk.disc
      have hal := hsl .always
      simp only [Effect.amtAt, Nat.zero_add] at hal
      rw [atkRes_slotAmt]
      cases hgv : atk.gx with
      | false =>
          have h0 := hG _ hmem atk hm hgv
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
      simp only [GameState.discAmt, cardsAmt_append]; omega
  | promote => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | noPokemon => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | knockOutOwn =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append]; omega
  | promoteOwn => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | noPokemonOwn => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | endTurn =>
      exact hi.endTurn rfl (Nat.add_comm _ _) (Nat.add_comm _ _) (Nat.add_comm _ _)
        (Nat.add_comm _ _) rfl (Nat.add_comm _ _)
  | startTurn => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | deckOut => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _

/-- The bound on the stores of every state reachable from `g₀`: the start stores, plus every
Trainer amount among the cards, plus three attacks' worth. -/
def storeBound (g₀ : GameState) : Nat :=
  g₀.storeTotal + cardsAmt g₀.allCards + 3 * cardsAtkAmt g₀.allCards

theorem reach_inv {g₀ g : GameState} (hF : g₀.Faithful) (h : Reach g₀ g) :
    Inv g₀.storeTotal (cardsAtkAmt g₀.allCards) g := by
  induction h with
  | refl => exact Inv.start _ _
  | step hr _ hm ih =>
      have hp := hr.perm
      exact ih.move hm (hF.1.of_perm hp) (hF.2.of_perm hp)
        (fun x hx => atkAmt_le_cardsAtkAmt (hp.mem_iff.1 hx))

theorem modsLe_of {B : Nat} {m : Mods} (h : m.amt ≤ B) : Enum.ModsLe B m := by
  unfold Mods.amt at h
  exact ⟨by omega, by omega⟩

/-- **For a faithful deck the stores stay bounded.** From a start state `g₀` satisfying
`Faithful`, every reachable state has, in both players' stores, every slot's damage bonus and
damage reduction at most `storeBound g₀`, which is computed from the start state's stores and
cards. -/
theorem reach_boundedStores {g₀ g : GameState} (hF : g₀.Faithful) (h : Reach g₀ g) :
    g.BoundedStores (storeBound g₀) := by
  have hi := reach_inv hF h
  have hd : g.discAmt ≤ cardsAmt g₀.allCards :=
    Nat.le_trans g.discAmt_le (Nat.le_of_eq (cardsAmt_perm h.perm))
  have ha := atkT_le (cardsAtkAmt g₀.allCards) g
  have hx := gxT_le (cardsAtkAmt g₀.allCards) g
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

/-- **Finiteness for faithful decks.** Let `g₀` be a well-formed start state whose cards
satisfy `Faithful` (no damage bonus or reduction under `iter`; rest-of-game bonuses and
reductions only from GX attacks, which the rules make once per player per game). Then

* the `xclamp`s of all states reachable from `g₀` lie in one finite list `L`; and
* the kernel of `xclamp` is a two-way bisimulation along reachable states: if `g₁` is reachable
  and `g₂` has the same `xclamp`, every move from either is matched by a move from the other to
  a state with the same `xclamp`.

So the quotient of the reachable states by `xclamp` is a finite transition system with the same
moves. Unlike `Reach.finite`, this allows damage reduction, `drain`, and carried and
rest-of-game modifiers. The list is not computed and the quotient's moves are not shown
computable. -/
theorem xfinite {g₀ : GameState} (hw : WellFormed g₀) (hF : g₀.Faithful) :
    (∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp ∈ L) ∧
      ∀ g₁ g₂, Reach g₀ g₁ → g₁.xclamp = g₂.xclamp →
        (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp) ∧
        (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧ g₂'.xclamp = g₁'.xclamp) := by
  obtain ⟨L, hL⟩ := Reach.xclamp_mem_bounded hw (storeBound g₀)
  exact ⟨⟨L, fun g h => hL g h (reach_boundedStores hF h)⟩,
    fun _ _ h hc => Reach.xclamp_bisim h hc⟩

end Faithful

end Pokemon
