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
  a card from a discard pile to the hand, deck or play (cards move from deck to hand, from hand
  to deck, play or discard pile, from Prizes to hand, and from play to the discard pile). So
  every Trainer card is played at most once per game, and the amounts written by Trainers over
  a whole game are at most the sum `cardsAmt` of their effects' amounts over the cards of the
  game (the proof tracks the Trainer amounts in the discard piles, which never decrease,
  `Keeps.disc`). This uses no assumption about recycling loops: the model has none.
* Attacks. At most one attack per turn (`GameState.attacked`, reset only by `endTurn`), each
  writing at most `A = cardsAtkAmt` (the largest attack amount among the cards). Amounts written
  for this turn, the next or the one after expire within three turn boundaries (`Store.shift`),
  so at most three attacks' carried amounts are live at once. Rest-of-game amounts written by
  attacks come only from GX attacks (clause 2), and the rule change below makes those once per
  player per game.

The invariant (`Faithful.Inv`) bounds, for each slot, the sum over both players by the start
stores, plus the Trainer amounts already discarded, plus `A` for each attack that can still be
live in that slot. `Faithful.reach_boundedStores` concludes `BoundedStores (storeBound g₀)` for
every reachable state, with `storeBound g₀ = storeTotal g₀ + cardsAmt C + 3 · cardsAtkAmt C`
(`C` the cards of `g₀`).

**Results.**
* `Faithful.reach_boundedStores`: for a start satisfying `Faithful`, every reachable state has
  stores bounded by `storeBound g₀`.
* `Faithful.xfinite`: from any `Faithful` start (well-formed or not), the `xclamp`s of all reachable states
  lie in one finite list, and the kernel of `xclamp` is a two-way bisimulation along reachable
  states. No tameness: damage reduction (Iron Defender), `drain`, carried bonuses and
  reductions, and rest-of-game modifiers from GX attacks are all allowed.
* `Pokemon/Dichotomy.lean`: the two-counter starts of `Pokemon/Counter.lean` satisfy clause 1
  and, when the machine's first instruction is not `halt`, violate clause 2
  (`Faithful.counter_loopFree`, `Faithful.counter_not_gxOnly`); `Faithful.dichotomy` states both
  sides together. It shows that clause 2 cannot be dropped; it does not classify the decks that
  are not faithful.

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
  is unused);
* copy attacks (using another Pokémon's attack, for instance copying a GX attack) are not
  modelled; the once-per-game rule and clause 2 are stated for the attacks printed on the
  attacker;
* static modifiers, and modifiers from Pokémon Tools, Abilities or Special Energy, are not
  modelled: every modifier here is written by an effect when it resolves;
* reductions restricted by type are not modelled: printed Iron Defender protects Metal Pokémon
  only, whereas the model's reduction protects all of a player's Pokémon;
* effects that lock GX attacks (forbid the opponent to use them) are not modelled.

The store bound rests on three absences in the model: no effect returns a card from a discard
pile, at most one attack is made per turn, and there are no extra turns. Each of the three
exists on printed cards (Item- and Supporter-recycling cards; "attack twice"; "take another
turn"), so adding any of them to the model reopens the bound.
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

/-- The recycling filters of a card's effects that are not attacks: in the model, a Trainer
card's effect (there are no Abilities, and no move plays a Stadium). -/
def Card.trainerRec : Card → List Filter
  | .trainer _ _ e => e.recFilters
  | _ => []

/-- The recycling filters of all of a card's effects, attacks included. -/
def Card.allRec : Card → List Filter
  | .pokemon p => attacksRec p.attacks
  | .trainer _ _ e => e.recFilters
  | _ => []

/-- The amount a card writes when it is played, if it is a Trainer card that is not a Supporter
(a Supporter is played at most once per turn by the rules). -/
def Card.wAmt : Card → Nat
  | .trainer _ k e => if k = .supporter then 0 else e.amt
  | _ => 0

/-- The rest-of-game amount a Trainer card writes when it is played. -/
def Card.alAmt : Card → Nat
  | .trainer _ _ e => e.amtAt .always
  | _ => 0

theorem Card.wAmt_tw : TrainerWeight Card.wAmt := ⟨fun _ => rfl, fun _ => rfl⟩
theorem Card.alAmt_tw : TrainerWeight Card.alAmt := ⟨fun _ => rfl, fun _ => rfl⟩

theorem Card.wAmt_le : ∀ c : Card, c.wAmt ≤ c.amt
  | .trainer _ k e => by simp only [Card.wAmt, Card.amt]; split <;> omega
  | .pokemon _ => Nat.le_refl _
  | .energy _ => Nat.le_refl _

theorem Card.alAmt_le : ∀ c : Card, c.alAmt ≤ c.amt
  | .trainer _ _ e => e.amtAt_le_amt .always
  | .pokemon _ => Nat.le_refl _
  | .energy _ => Nat.le_refl _

theorem GameState.discW_le {w : Card → Nat} (hw : ∀ c, w c ≤ c.amt) (g : GameState) :
    g.discW w ≤ cardsAmt g.allCards := by
  have h1 := wsum_le w Card.amt hw g.cur.discard
  have h2 := wsum_le w Card.amt hw g.opp.discard
  have h3 := g.discAmt_le
  simp only [GameState.discAmt, cardsAmt_eq] at h3
  simp only [GameState.discW, cardsAmt_eq]; omega

/-- **Clause 3** (`RecycleSafe`, milestone MV): (a) no effect that is not an attack (a Trainer
card's effect) can return from a discard pile to a hand or deck a card of the game that writes a
damage bonus or reduction, unless that card is a Supporter; and (b) no effect at all, attacks
included, can return a card that writes a rest-of-game bonus or reduction. "Can return": the
filter of one of its zone moves out of a discard pile admits the card (`Effect.recFilters`).
Attacks may recycle every other card: an attack ends the turn. Decidable (a finite check over
pairs of a recycling filter and a card of the game). -/
def GameState.RecycleSafe (g : GameState) : Prop :=
  (∀ x ∈ g.allCards, ∀ f ∈ x.trainerRec, ∀ y ∈ g.allCards, f.eval y = true → y.wAmt = 0) ∧
  (∀ x ∈ g.allCards, ∀ f ∈ x.allRec, ∀ y ∈ g.allCards, f.eval y = true → y.alAmt = 0)

instance (g : GameState) : Decidable g.RecycleSafe := by
  unfold GameState.RecycleSafe; infer_instance

/-- No effect of any card of the game moves a card out of a discard pile to a hand or deck. -/
def GameState.NoRecycle (g : GameState) : Prop := ∀ x ∈ g.allCards, x.allRec = []

theorem GameState.NoRecycle.recycleSafe {g : GameState} (h : g.NoRecycle) : g.RecycleSafe := by
  refine ⟨fun x hx f hf => ?_, fun x hx f hf => ?_⟩
  · have e : x.trainerRec = [] := by
      cases x with
      | trainer n k e => exact h _ hx
      | _ => rfl
    rw [e] at hf; nomatch hf
  · rw [h x hx] at hf; nomatch hf

theorem GameState.RecycleSafe.of_perm {g g' : GameState} (h : g.RecycleSafe)
    (hp : g'.allCards.Perm g.allCards) : g'.RecycleSafe :=
  ⟨fun x hx f hf y hy => h.1 x (hp.mem_iff.1 hx) f hf y (hp.mem_iff.1 hy),
    fun x hx f hf y hy => h.2 x (hp.mem_iff.1 hx) f hf y (hp.mem_iff.1 hy)⟩

theorem GameState.NoRecycle.of_perm {g g' : GameState} (h : g.NoRecycle)
    (hp : g'.allCards.Perm g.allCards) : g'.NoRecycle :=
  fun x hx => h x (hp.mem_iff.1 hx)

/-- **Faithful decks** (milestone MV: three clauses). For a deck with no recycling (every deck
before milestone MV) clause 3 holds (`GameState.NoRecycle.recycleSafe`), and `Faithful` means what
it meant before: `LoopFree ∧ GXOnly`. -/
def GameState.Faithful (g : GameState) : Prop := g.LoopFree ∧ g.GXOnly ∧ g.RecycleSafe

theorem attacksRec_nil {p : PokemonCard} (h : (Card.pokemon p).allRec = []) {atk : Attack}
    (hm : atk ∈ p.attacks) : atk.effect.recFilters = [] := by
  cases e : atk.effect.recFilters with
  | nil => rfl
  | cons f fs =>
      have := attacksRec_mem (f := f) hm (by rw [e]; exact .head _)
      simp only [Card.allRec] at h
      rw [h] at this; nomatch this

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
    (hL : g.LoopFree) (hG : g.GXOnly) (hN : g.NoRecycle)
    (hA : ∀ x ∈ g.allCards, x.atkAmt ≤ A) : Inv S A g' := by
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
  | @attack g'' a atk ha hm hc hs hn hf hbt hst hr hl hgx =>
      show Inv S A (atkRes atk g'')
      have hmem := GameState.top_mem_cur_active ha
      have hlf : atk.effect.loopFree = true := List.all_eq_true.1 (hL _ hmem) atk hm
      have hamt : atk.effect.amt ≤ A := by
        have h1 := attacksAmt_mem hm
        have h2 := hA _ hmem
        simp only [Card.atkAmt] at h2
        omega
      have hk := hr.keeps (by rw [Attack.script_recFilters]; exact attacksRec_nil (hN _ hmem) hm)
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
    (h : Reach g₀ g) :
    Inv g₀.storeTotal (cardsAtkAmt g₀.allCards) g := by
  induction h with
  | refl => exact Inv.start _ _
  | step hr _ hm ih =>
      have hp := hr.perm
      exact ih.move hm (hL.of_perm hp) (hG.of_perm hp) (hN.of_perm hp)
        (fun x hx => atkAmt_le_cardsAtkAmt (hp.mem_iff.1 hx))

theorem modsLe_of {B : Nat} {m : Mods} (h : m.amt ≤ B) : Enum.ModsLe B m := by
  unfold Mods.amt at h
  exact ⟨by omega, by omega⟩

/-- **Without recycling, the bound of master.** From a start state `g₀` satisfying clauses 1 and
2 whose cards recycle nothing (`NoRecycle`: no effect moves a card out of a discard pile to a hand
or deck; every deck before milestone MV), every reachable state has every slot's bonus and
reduction at most `storeBoundNR g₀`: each Trainer card is then played at most once per game. This
is the statement `reach_boundedStores` had before milestone MV, with its bound. -/
theorem reach_boundedStores_noRecycle {g₀ g : GameState} (hL : g₀.LoopFree) (hG : g₀.GXOnly)
    (hN : g₀.NoRecycle) (h : Reach g₀ g) : g.BoundedStores (storeBoundNR g₀) := by
  have hi := reach_inv hL hG hN h
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
one turn, under clause 3: before the turn's attack no effect returns a non-Supporter writer from a
discard pile, so each such card is played at most once in the turn, and at most one Supporter is.
The invariant tracks, as witnesses, the amount `X₀` Trainers wrote this turn, `X₁` last turn and
`X₂` the turn before (each at most `2 P`, `P` the Trainer amounts of all cards), and the weight
`D` of the non-Supporter writers in the discard piles when the turn began; carried amounts expire
within three turn boundaries, as for attacks. The rest-of-game slot is bounded as before, by the
rest-of-game Trainer amounts in the discard piles, which no effect recycles (clause 3 (b)). -/

/-- `P` once the player to move has played a Supporter this turn, else 0. -/
def supT (P : Nat) (g : GameState) : Nat := if g.cur.supporterPlayed then P else 0

theorem supT_le (P : Nat) (g : GameState) : supT P g ≤ P := by
  unfold supT; split <;> omega

/-- **The per-turn invariant.** -/
structure TInv (S A P : Nat) (g : GameState) (X₀ X₁ X₂ D : Nat) : Prop where
  x0 : X₀ ≤ P + P
  x1 : X₁ ≤ P + P
  x2 : X₂ ≤ P + P
  turn : g.attacked = false → D + X₀ ≤ g.discW Card.wAmt + supT P g
  after : g.slotAmt .after ≤ S + X₀ + atkT A g
  next : g.slotAmt .next ≤ S + X₀ + X₁ + A + atkT A g
  now : g.slotAmt .now ≤ S + X₀ + X₁ + X₂ + A + A + atkT A g
  always : g.slotAmt .always ≤ S + g.discW Card.alAmt + gxT A g

theorem TInv.start (g : GameState) (A P : Nat) :
    TInv g.storeTotal A P g 0 0 0 (g.discW Card.wAmt) := by
  refine ⟨Nat.zero_le _, Nat.zero_le _, Nat.zero_le _, fun _ => by omega, ?_, ?_, ?_, ?_⟩ <;>
    simp only [GameState.storeTotal] <;> omega

/-- A step that writes nothing and recycles no weighted card. -/
theorem TInv.frame {S A P X₀ X₁ X₂ D : Nat} {g g' : GameState} (hi : TInv S A P g X₀ X₁ X₂ D)
    (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s) (hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt)
    (hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt) (ha : atkT A g ≤ atkT A g')
    (ht : g'.attacked = false → g.attacked = false ∧ supT P g ≤ supT P g')
    (hx : gxT A g ≤ gxT A g') : TInv S A P g' X₀ X₁ X₂ D := by
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now; have h4 := hs .always
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  refine ⟨hi.x0, hi.x1, hi.x2, fun hf => ?_, by omega, by omega, by omega, by omega⟩
  obtain ⟨hg, hsup⟩ := ht hf
  have := hi.turn hg
  omega

/-- A step that changes no flag, store or discard pile weight of interest. -/
theorem TInv.same {S A P X₀ X₁ X₂ D : Nat} {g g' : GameState} (hi : TInv S A P g X₀ X₁ X₂ D)
    (hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt) (hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt)
    (ha : g'.attacked = g.attacked) (hsp : g'.cur.supporterPlayed = g.cur.supporterPlayed)
    (hgc : g'.cur.gxUsed = g.cur.gxUsed) (hgo : g'.opp.gxUsed = g.opp.gxUsed)
    (hs : ∀ s, g'.slotAmt s = g.slotAmt s) : TInv S A P g' X₀ X₁ X₂ D :=
  hi.frame (fun s => Nat.le_of_eq (hs s)) hW hAl (Nat.le_of_eq (atkT_congr ha).symm)
    (fun hf => ⟨ha ▸ hf, by simp only [supT, hsp]; exact Nat.le_refl _⟩)
    (Nat.le_of_eq (gxT_congr hgc hgo).symm)

/-- The end of the turn: the witnesses move one turn back. -/
theorem TInv.endTurn {S A P X₀ X₁ X₂ D : Nat} {g g' : GameState} (hi : TInv S A P g X₀ X₁ X₂ D)
    (h0 : g'.slotAmt .after = 0) (h1 : g'.slotAmt .next = g.slotAmt .after)
    (h2 : g'.slotAmt .now = g.slotAmt .next) (h3 : g'.slotAmt .always = g.slotAmt .always)
    (hd : g'.discW Card.alAmt = g.discW Card.alAmt) (ha : atkT A g' = 0)
    (hx : gxT A g' = gxT A g) : TInv S A P g' 0 X₀ X₁ (g'.discW Card.wAmt) := by
  have := atkT_le A g
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨Nat.zero_le _, hi.x0, hi.x1, fun _ => by omega, by omega, by omega, by omega, by omega⟩

/-- **Every move preserves the per-turn invariant**, for cards satisfying the three clauses
whose attacks write at most `A` and whose Trainer amounts add up to at most `P`. -/
theorem TInv.move {S A P X₀ X₁ X₂ D : Nat} {g g' : GameState} (hm : Move g g')
    (hi : TInv S A P g X₀ X₁ X₂ D) (hL : g.LoopFree) (hG : g.GXOnly) (hR : g.RecycleSafe)
    (hA : ∀ x ∈ g.allCards, x.atkAmt ≤ A) (hP : cardsAmt g.allCards ≤ P) :
    ∃ Y₀ Y₁ Y₂ E, TInv S A P g' Y₀ Y₁ Y₂ E := by
  have hP' : cardsAmt g'.allCards ≤ P := by rw [cardsAmt_perm hm.perm]; exact hP
  have hWle : g'.discW Card.wAmt ≤ P := Nat.le_trans (GameState.discW_le Card.wAmt_le g') hP'
  have hsP := supT_le P g'
  cases hm with
  | playBasic => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | attach => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | evolve => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | attachBench => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | evolveBench => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | retreat =>
      exact ⟨_, _, _, _, hi.same (by simp only [GameState.discW, wsum_append]; omega)
        (by simp only [GameState.discW, wsum_append]; omega) rfl rfl rfl rfl fun _ => rfl⟩
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
      have h1 := hsl .after; have h2 := hsl .next; have h3 := hsl .now; have h4 := hsl .always
      have w1 := e.amtAt_le_amt .after; have w2 := e.amtAt_le_amt .next
      have w3 := e.amtAt_le_amt .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀ + e.amt, X₁, X₂, D, by omega, hi.x1, hi.x2, fun _ => by omega, by omega, by omega,
        by omega, by omega⟩
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
      have h1 := hsl .after; have h2 := hsl .next; have h3 := hsl .now; have h4 := hsl .always
      have w1 := e.amtAt_le_amt .after; have w2 := e.amtAt_le_amt .next
      have w3 := e.amtAt_le_amt .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀ + e.amt, X₁, X₂, D, by omega, hi.x1, hi.x2, fun _ => by omega, by omega, by omega,
        by omega, by omega⟩
  | @attack g'' a atk ha hm hc hs hn hf hbt hst hr hl hgx =>
      show ∃ Y₀ Y₁ Y₂ E, TInv S A P (atkRes atk g'') Y₀ Y₁ Y₂ E
      have hmem := GameState.top_mem_cur_active ha
      have hlf : atk.effect.loopFree = true := List.all_eq_true.1 (hL _ hmem) atk hm
      have hamt : atk.effect.amt ≤ A := by
        have h1 := attacksAmt_mem hm
        have h2 := hA _ hmem
        simp only [Card.atkAmt] at h2
        omega
      have hfk := hr.flags_keep
      have hAl : g.discW Card.alAmt ≤ (atkRes atk g'').discW Card.alAmt :=
        hr.disc_mono Card.alAmt_tw (C := g.allCards)
          (fun f hf y hy hfy => hR.2 _ hmem f
            (attacksRec_mem hm (by rw [Attack.script_recFilters] at hf; exact hf)) y hy hfy)
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
            have h0 := hG _ hmem atk hm hgv
            rw [h0] at hal
            rw [atkRes_gxT_false hgv hfk.gxCur hfk.gxOpp]
            omega
        | true =>
            rw [atkRes_gxT_true hgv (hgx hgv) hfk.gxOpp]
            have := atk.effect.amtAt_le_amt .always
            omega
      have h1 := hs' .after; have h2 := hs' .next; have h3 := hs' .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀, X₁, X₂, D, hi.x0, hi.x1, hi.x2, fun h => absurd h (by simp [atkRes]),
        by omega, by omega, by omega, by omega⟩
  | attackConfused =>
      exact ⟨_, _, _, _, hi.frame (fun _ => Nat.le_refl _) (Nat.le_refl _) (Nat.le_refl _)
        (atkT_le A g) (fun h => absurd h (by simp)) (Nat.le_refl _)⟩
  | knockOut =>
      exact ⟨_, _, _, _, hi.same
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        rfl rfl rfl rfl fun _ => rfl⟩
  | promote => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | noPokemon => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | knockOutOwn =>
      exact ⟨_, _, _, _, hi.same
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        rfl rfl rfl rfl fun _ => rfl⟩
  | knockOutBench =>
      exact ⟨_, _, _, _, hi.same
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        rfl rfl rfl rfl fun _ => rfl⟩
  | knockOutBenchOwn =>
      exact ⟨_, _, _, _, hi.same
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        (by simp only [GameState.discW, wsum_append, PlayerState.takePrizes]; omega)
        rfl rfl rfl rfl fun _ => rfl⟩
  | promoteOwn => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | noPokemonOwn => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | endTurn =>
      exact ⟨_, _, _, _, hi.endTurn rfl (Nat.add_comm _ _) (Nat.add_comm _ _) (Nat.add_comm _ _)
        (Nat.add_comm _ _) rfl (Nat.add_comm _ _)⟩
  | startTurn => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩
  | deckOut => exact ⟨_, _, _, _, hi.same (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      fun _ => rfl⟩

/-- The bound on the stores of every state reachable from `g₀` (milestone MV): the start stores,
plus six times the Trainer amounts of the cards (three turns of Trainer writes, each at most twice
the Trainer amounts), plus three attacks' worth. Before milestone MV the bound was
`storeBoundNR g₀`, which still holds for decks that recycle nothing
(`reach_boundedStores_noRecycle`). -/
def storeBound (g₀ : GameState) : Nat :=
  g₀.storeTotal + 6 * cardsAmt g₀.allCards + 3 * cardsAtkAmt g₀.allCards

theorem reach_tinv {g₀ g : GameState} (hF : g₀.Faithful) (h : Reach g₀ g) :
    ∃ X₀ X₁ X₂ D, TInv g₀.storeTotal (cardsAtkAmt g₀.allCards) (cardsAmt g₀.allCards) g
      X₀ X₁ X₂ D := by
  induction h with
  | refl => exact ⟨_, _, _, _, TInv.start _ _ _⟩
  | step hr _ hm ih =>
      obtain ⟨X₀, X₁, X₂, D, hi⟩ := ih
      have hp := hr.perm
      exact hi.move hm (hF.1.of_perm hp) (hF.2.1.of_perm hp) (hF.2.2.of_perm hp)
        (fun x hx => atkAmt_le_cardsAtkAmt (hp.mem_iff.1 hx))
        (Nat.le_of_eq (cardsAmt_perm hp))

/-- **For a faithful deck the stores stay bounded.** From a start state `g₀` satisfying
`Faithful` (clauses 1–3), every reachable state has, in both players' stores, every slot's damage
bonus and damage reduction at most `storeBound g₀`, which is computed from the start state's stores
and cards. Milestone MV changed the hypothesis (clause 3, `RecycleSafe`, which every deck without
recycling satisfies) and the bound (`storeBound` now counts six times the Trainer amounts, a
per-turn count; the per-game bound of master is `reach_boundedStores_noRecycle`). -/
theorem reach_boundedStores {g₀ g : GameState} (hF : g₀.Faithful) (h : Reach g₀ g) :
    g.BoundedStores (storeBound g₀) := by
  obtain ⟨X₀, X₁, X₂, D, hi⟩ := reach_tinv hF h
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
reductions only from GX attacks, which the rules make once per player per game). Then

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
