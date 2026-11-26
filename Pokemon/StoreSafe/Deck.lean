import Pokemon.Turn
import Pokemon.WellFormed

/-! Part of `Pokemon/StoreSafe.lean` (see its module documentation): the amounts written by
effects, the deck condition `GameState.StoreSafe` and its clauses, and the counting of Ability
uses within a turn. It needs neither the damage clamps nor finiteness, so it builds alongside
those files. -/

namespace Pokemon

/-! ## Amounts written by effects -/

/-- The amount a modifier adds to a store: a bonus or a reduction counts, a flag does not. -/
def Mod.amt : Mod → Nat
  | .bonus n => n
  | .reduce n => n
  | .weaken n => n
  | .expose n => n
  | _ => 0

/-- Does the modifier carry an amount (a damage bonus or reduction; since milestone MV6 also a
step-2 penalty or a step-5 increase, which are stored and bounded like them)? -/
def Mod.isAmt : Mod → Bool
  | .bonus _ => true
  | .reduce _ => true
  | .weaken _ => true
  | .expose _ => true
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

/-! ### The attack as it resolves against a protected Pokémon (milestone MV10)

`Effect.shielded` only replaces primitives by `skip`: it writes no more, loops no more and recycles
exactly as the effect does. -/

theorem Effect.shielded_writes (e : Effect) : e.shielded.writes = true → e.writes = true := by
  induction e with
  | ite t a b iha ihb =>
      simp only [Effect.writes, Effect.shielded, Bool.or_eq_true]
      exact fun h => h.elim (fun h => .inl (iha h)) (fun h => .inr (ihb h))
  | seq a b iha ihb =>
      simp only [Effect.writes, Effect.shielded, Bool.or_eq_true]
      exact fun h => h.elim (fun h => .inl (iha h)) (fun h => .inr (ihb h))
  | choice a b iha ihb =>
      simp only [Effect.writes, Effect.shielded, Bool.or_eq_true]
      exact fun h => h.elim (fun h => .inl (iha h)) (fun h => .inr (ihb h))
  | iter a iha => simp only [Effect.writes, Effect.shielded]; exact iha
  | _ => intro h; unfold Effect.shielded at h; (try split at h) <;> simp_all [Effect.writes]

theorem Effect.shielded_loopFree (e : Effect) : e.loopFree = true → e.shielded.loopFree = true := by
  induction e with
  | ite t a b iha ihb =>
      simp only [Effect.loopFree, Effect.shielded, Bool.and_eq_true]; exact fun h => ⟨iha h.1, ihb h.2⟩
  | seq a b iha ihb =>
      simp only [Effect.loopFree, Effect.shielded, Bool.and_eq_true]; exact fun h => ⟨iha h.1, ihb h.2⟩
  | choice a b iha ihb =>
      simp only [Effect.loopFree, Effect.shielded, Bool.and_eq_true]; exact fun h => ⟨iha h.1, ihb h.2⟩
  | iter a _ =>
      simp only [Effect.loopFree, Effect.shielded, Bool.not_eq_true']
      intro h
      cases hw : a.shielded.writes
      · rfl
      · rw [Effect.shielded_writes a hw] at h; cases h
  | _ => intro h; unfold Effect.shielded; (try split) <;> simp_all [Effect.loopFree]

theorem Effect.shielded_amtAt (e : Effect) (s : Slot) : e.shielded.amtAt s ≤ e.amtAt s := by
  induction e with
  | ite t a b iha ihb => simp only [Effect.amtAt, Effect.shielded]; omega
  | seq a b iha ihb => simp only [Effect.amtAt, Effect.shielded]; omega
  | choice a b iha ihb => simp only [Effect.amtAt, Effect.shielded]; omega
  | iter a _ => simp only [Effect.amtAt, Effect.shielded]; omega
  | _ => unfold Effect.shielded; (try split) <;> simp_all [Effect.amtAt]

theorem Effect.shielded_recFilters (e : Effect) : e.shielded.recFilters = e.recFilters := by
  induction e with
  | ite t a b iha ihb => simp only [Effect.recFilters, Effect.shielded, iha, ihb]
  | seq a b iha ihb => simp only [Effect.recFilters, Effect.shielded, iha, ihb]
  | choice a b iha ihb => simp only [Effect.recFilters, Effect.shielded, iha, ihb]
  | iter a iha => simp only [Effect.recFilters, Effect.shielded, iha]
  | _ => unfold Effect.shielded; (try split) <;> simp_all [Effect.recFilters]

theorem Attack.against_loopFree (b : Bool) {atk : Attack} (h : atk.effect.loopFree = true) :
    (atk.against b).script.loopFree = true := by
  cases b
  · rw [Attack.against_false, Attack.script_loopFree]; exact h
  · rw [Attack.script_loopFree]; exact Effect.shielded_loopFree _ h

theorem Attack.against_amtAt_le (b : Bool) (atk : Attack) (s : Slot) :
    (atk.against b).script.amtAt s ≤ atk.effect.amtAt s := by
  cases b
  · rw [Attack.against_false, Attack.script_amtAt]; exact Nat.le_refl _
  · rw [Attack.script_amtAt]; exact Effect.shielded_amtAt _ s

theorem Effect.amtAt_le_amt (e : Effect) (s : Slot) : e.amtAt s ≤ e.amt := by
  cases s <;> simp only [Effect.amt] <;> omega

/-! ## Amounts in the stores -/

/-- The amount in one turn's modifiers (since milestone MV6 the step-2 penalty and the step-5
increase too). -/
def Mods.amt (m : Mods) : Nat := m.bonus + m.reduce + m.minus + m.more

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
  | shield => rfl
  | weaken n => simp only [Mods.addMod, Mods.amt, Mod.amt]; omega
  | expose n => simp only [Mods.addMod, Mods.amt, Mod.amt]; omega

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
  | .trainer _ _ e _ => e.amt
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
  | .energy (.basic _) => true
  | .energy (.special _ _ x) => (x.grant.attacks.all fun a => a.effect.loopFree) &&
      x.grant.abilities.all fun a => a.scripts.all fun e => e.loopFree
  | .trainer _ _ e _ => e.loopFree
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
  | energy t =>
      cases t with
      | basic => nomatch hm
      | special m pr x =>
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
  | energy t =>
      cases t with
      | basic => nomatch hm
      | special m pr x =>
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
  | benchSome w _ _ _ _ _ => intro _ s; cases w <;> exact Nat.le_refl _
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
  | benchSome w _ _ _ _ _ => intro _ s; cases w <;> exact Nat.le_add_right _ _
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

theorem Place.wsum_discard (w : Card → Nat) {i : Into} {t : List Card} {x y : PlayerState}
    (h : Place i t x y) : wsum w x.discard ≤ wsum w y.discard := by
  cases h with
  | put hp => exact hp.wsum_discard w
  | bench _ _ => exact Nat.le_refl _
  | attach _ => exact Nat.le_refl _

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
  | @look _ src f q i rest _ s₁ _ t r hs hq hput hp =>
      have hP := hp.wsum_discard w
      cases src with
      | discard =>
          have he := hs.wsum_eq w
          simp only [Src.get] at he
          by_cases hrd : rest = .discard
          · subst hrd
            have ht0 : wsum w t = 0 := wsum_zero w fun x hx =>
              hr f (by simp [Effect.recFilters]) x (hs.mem x hx) (hs.taken x hx)
            cases hput
            simp only [Src.set, wsum_append, wsum] at hP
            omega
          · have h0 : wsum w s.discard = 0 := wsum_zero w fun y hy =>
              hr .any (by simp [Effect.recFilters, hrd]) y hy rfl
            omega
      | _ =>
          have h1 := hput.wsum_discard w
          simp only [Src.set] at h1
          omega
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
  | benchSome w _ _ _ _ _ => intro _ _; cases w <;> exact Nat.le_refl _
  | switch w ha hb => intro _ _; cases w <;> exact Nat.le_refl _
  | benchDamage w n h => intro _ _; cases w <;> exact Nat.le_refl _
  | spreadDamage w n g => intro _ _; cases w <;> exact Nat.le_refl _
  | linger w s m g => intro _ _; cases w <;> exact Nat.le_refl _
  | discardStadium g =>
      intro _ _; simp only [GameState.discW, wsum_append]; omega
  | _ => intro _ _; exact Nat.le_refl _

theorem KOBatch.disc_mono (w : Card → Nat) {g g' : GameState} (h : KOBatch g g') :
    g.discW w ≤ g'.discW w := by
  obtain ⟨-, -, d1, d2, -⟩ := h.piles
  simp only [GameState.discW, d1, d2, GameState.koStep, PlayerState.takePrizes, GameState.koOf,
    PlayerState.koOut, GameState.side, PlayerState.noteKO, wsum_append]
  omega

theorem GameState.swap_discW (w : Card → Nat) (g : GameState) : g.swap.discW w = g.discW w :=
  Nat.add_comm _ _

/-- **A trigger resolution keeps the weight of the discard piles** when its triggers recycle no card
of positive weight. -/
theorem Fire.disc_mono {w : Card → Nat} (hw : TrainerWeight w) {C : List Card} {ev : TrigEvent}
    {l : List Ability} {g g' : GameState} (h : Fire ev l g g') :
    (∀ ab ∈ l, (ab.script ev.place).RecOk w C) → (∀ y ∈ g.allCards, y ∈ C) →
      g.discW w ≤ g'.discW w := by
  induction h with
  | nil => intro _ _; exact Nat.le_refl _
  | @run ab l g g₁ g₂ _ hr _ ih =>
      intro hl hC
      have hC' : ∀ y ∈ g.swap.allCards, y ∈ C := fun y hy => hC y (g.swap_perm.mem_iff.1 hy)
      have h1 := hr.disc_mono hw (hl _ (.head _)) hC'
      have h2 := ih (fun ab hab => hl ab (.tail _ hab)) (fun y hy =>
        hC' y (hr.perm.mem_iff.1 (g₁.swap_perm.mem_iff.1 hy)))
      rw [GameState.swap_discW] at h1 h2
      exact Nat.le_trans h1 h2
  | decline _ _ ih => intro hl hC; exact ih (fun ab hab => hl ab (.tail _ hab)) hC

/-- The player to move's own triggers (milestone MV7c) keep the weight of the discard piles: they
recycle nothing. -/
theorem FireMine.disc_mono {w : Card → Nat} (hw : TrainerWeight w) {u d : List Ability}
    {g g' : GameState} (h : FireMine u d g g')
    (hu : ∀ ab ∈ u, (ab.script TrigEvent.movedUp.place).recFilters = [])
    (hd : ∀ ab ∈ d, (ab.script TrigEvent.movedDown.place).recFilters = []) :
    g.discW w ≤ g'.discW w := by
  obtain ⟨g₁, g₂, h₁, h₂, rfl⟩ := h
  have a := h₁.disc_mono (C := g.swap.allCards) hw (fun ab hab => Effect.recOk_nil (hu ab hab))
    fun _ hy => hy
  have b := h₂.disc_mono (C := g₁.allCards) hw (fun ab hab => Effect.recOk_nil (hd ab hab))
    fun _ hy => hy
  rw [GameState.swap_discW] at a
  rw [GameState.swap_discW]
  exact Nat.le_trans a b

/-- **The resolution of the owed triggers keeps the weight of the discard piles** (milestone
MV7c): none of them recycles. -/
theorem Owed.disc_mono {w : Card → Nat} (hw : TrainerWeight w) {g g' : GameState} (h : Owed g g') :
    g.discW w ≤ g'.discW w := by
  have e : g.unpend.discW w = g.discW w := rfl
  rw [← e]
  cases h with
  | mineFirst hu hd hl hm ht =>
      exact Nat.le_trans
        (hm.disc_mono hw (fun ab hab => GameState.upOwed_recFilters (hu.mem_iff.1 hab))
          (fun ab hab => GameState.downOwed_recFilters (hd.mem_iff.1 hab)))
        (ht.disc_mono (C := _) hw
          (fun ab hab => Effect.recOk_nil (GameState.owedTrigs_recFilters (hl.mem_iff.1 hab)))
          (fun _ hy => hy))
  | oppFirst hu hd hl ht hm =>
      exact Nat.le_trans
        (ht.disc_mono (C := _) hw
          (fun ab hab => Effect.recOk_nil (GameState.owedTrigs_recFilters (hl.mem_iff.1 hab)))
          (fun _ hy => hy))
        (hm.disc_mono hw (fun ab hab => GameState.upOwed_recFilters (hu.mem_iff.1 hab))
          (fun ab hab => GameState.downOwed_recFilters (hd.mem_iff.1 hab)))

theorem Resolve.disc_mono {w : Card → Nat} (hw : TrainerWeight w) {g g' : GameState}
    (h : Resolve g g') : g.discW w ≤ g'.discW w := by
  induction h with
  | done => exact Nat.le_refl _
  | step _ hm _ ih => exact Nat.le_trans (hm.disc_mono w) ih
  | trigger _ _ _ ho _ ih => exact Nat.le_trans (ho.disc_mono hw) ih

theorem TRun.disc_mono {w : Card → Nat} (hw : TrainerWeight w) {C : List Card} {e : Effect}
    {g g' : GameState} (h : TRun e g g') :
    e.RecOk w C → (∀ y ∈ g.allCards, y ∈ C) → g.discW w ≤ g'.discW w := by
  induction h with
  | prim _ _ hr hk => intro hc hC; exact Nat.le_trans (hr.disc_mono hw hc hC) (hk.disc_mono hw)
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
  | benchSome w _ _ _ _ _ => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | switch w ha hb => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | benchDamage w n h => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | spreadDamage w n g => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | linger w s m g => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | @zone e w g s' hw hz => cases w <;> exact ⟨rfl, rfl, rfl⟩
  | _ => exact ⟨rfl, rfl, rfl⟩

theorem KOBatch.flags_keep {g g' : GameState} (h : KOBatch g g') : Flags g g' := by
  cases h <;> exact ⟨rfl, rfl, rfl⟩

theorem Fire.flags_keep {ev : TrigEvent} {l : List Ability} {g g' : GameState}
    (h : Fire ev l g g') : Flags g g' :=
  have z := h.zoneOnly
  ⟨z.attacked, z.cur_gxUsed, z.opp_gxUsed⟩

theorem Resolve.flags_keep {g g' : GameState} (h : Resolve g g') : Flags g g' := by
  induction h with
  | done => exact Flags.refl _
  | step _ hm _ ih => exact hm.flags_keep.trans ih
  | trigger _ _ _ ho _ ih =>
      have z := ho.zoneOnly
      exact ⟨ih.attacked.trans z.attacked, ih.gxCur.trans z.cur_gxUsed, ih.gxOpp.trans z.opp_gxUsed⟩

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

theorem KOBatch.keeps {g g' : GameState} (h : KOBatch g g') :
    Keeps g g' ∧ ∀ s, g'.slotAmt s = g.slotAmt s := by
  have hd : g.discAmt ≤ g'.discAmt := by
    obtain ⟨-, -, d1, d2, -⟩ := h.piles
    simp only [GameState.discAmt, d1, d2, GameState.koStep, PlayerState.takePrizes,
      GameState.koOf, PlayerState.koOut, GameState.side, PlayerState.noteKO, cardsAmt_append]
    omega
  cases h <;> exact ⟨⟨hd, rfl, rfl, rfl⟩, fun _ => rfl⟩

theorem Fire.slotAmt {ev : TrigEvent} {l : List Ability} {g g' : GameState}
    (h : Fire ev l g g') (s : Slot) : g'.slotAmt s = g.slotAmt s := by
  simp only [GameState.slotAmt, h.zoneOnly.cur_mods, h.zoneOnly.opp_mods]

/-- A trigger resolution keeps what `Keeps` asks, when its triggers recycle nothing. -/
theorem Fire.keeps {ev : TrigEvent} {l : List Ability} {g g' : GameState} (h : Fire ev l g g')
    (hn : ∀ ab ∈ l, (ab.script ev.place).recFilters = []) : Keeps g g' :=
  have hf := h.flags_keep
  ⟨by
    have := h.disc_mono (C := g.allCards) Card.amt_tw
      (fun ab hab => Effect.recOk_nil (hn ab hab)) fun _ hy => hy
    rw [GameState.discAmt_eq, GameState.discAmt_eq]; exact this,
   hf.attacked, hf.gxCur, hf.gxOpp⟩

/-- **The resolution of the owed triggers keeps what `Keeps` asks** (milestone MV7c): none of them
recycles, and they change no flag. -/
theorem Owed.keeps {g g' : GameState} (h : Owed g g') : Keeps g g' :=
  have z := h.zoneOnly
  ⟨by
    have := h.disc_mono (w := Card.amt) Card.amt_tw
    rw [GameState.discAmt_eq, GameState.discAmt_eq]; exact this,
   z.attacked, z.cur_gxUsed, z.opp_gxUsed⟩

theorem Owed.slotAmt {g g' : GameState} (h : Owed g g') (s : Slot) :
    g'.slotAmt s = g.slotAmt s := by
  simp only [GameState.slotAmt, h.zoneOnly.cur_mods, h.zoneOnly.opp_mods]; rfl

theorem Resolve.keeps {g g' : GameState} (h : Resolve g g') :
    Keeps g g' ∧ ∀ s, g'.slotAmt s = g.slotAmt s := by
  induction h with
  | done => exact ⟨Keeps.refl _, fun _ => rfl⟩
  | step _ hm _ ih =>
      obtain ⟨k₁, s₁⟩ := hm.keeps
      exact ⟨k₁.trans ih.1, fun s => (ih.2 s).trans (s₁ s)⟩
  | trigger _ _ _ ho _ ih =>
      have k₁ := ho.keeps
      exact ⟨⟨Nat.le_trans k₁.disc ih.1.disc, ih.1.attacked.trans k₁.attacked,
        ih.1.gxCur.trans k₁.gxCur, ih.1.gxOpp.trans k₁.gxOpp⟩,
        fun s => (ih.2 s).trans (ho.slotAmt s)⟩

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

theorem Attack.against_recFilters (b : Bool) (atk : Attack) :
    (atk.against b).script.recFilters = atk.effect.recFilters := by
  cases b
  · rw [Attack.against_false, Attack.script_recFilters]
  · rw [Attack.script_recFilters]; exact Effect.shielded_recFilters _

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
one turn before attacking, with no per-turn limit: an Item or Supporter card's effect (each play
spends the card, but recycling can return it), and, since milestone M8a, the "as often as you
like" Abilities of a Pokémon card and (milestone M5) those a Tool gives. Attacks end the turn;
"once during your turn" and on-play Abilities are bounded per turn by the Pokémon in play and
entering play (`GameState.abPot`); a Stadium's effect (milestone M5) is used at most twice in a
turn (`GameState.stPot`) and paid per use by `Card.stQ`. (Before milestone M8a this was
`Card.trainerRec`, the Trainer part; before milestone M5 it included Stadium effects.) -/
def Card.freeRec : Card → List Filter
  | .trainer _ k e _ => if k = .stadium then [] else e.recFilters
  | .pokemon p => unlimitedRec p.abilities
  | .tool _ gr => unlimitedRec gr.abilities
  | .energy (.special _ _ x) => unlimitedRec x.grant.abilities
  | _ => []

/-- The recycling filters of all of a card's effects, attacks and (milestone M8a) Abilities
included. -/
def Card.allRec : Card → List Filter
  | .pokemon p => attacksRec p.attacks ++ abilitiesRec p.abilities
  | .trainer _ _ e _ => e.recFilters
  | .tool _ gr => attacksRec gr.attacks ++ abilitiesRec gr.abilities
  | .energy (.special _ _ x) => attacksRec x.grant.attacks ++ abilitiesRec x.grant.abilities
  | _ => []

/-- The amount a card writes when it is played, if it is an Item card: a Supporter is played at
most once per turn by the rules, and (milestone M5) playing a Stadium writes nothing (its effect
is used by `Move.stadiumUse`, at most twice in a turn, and is counted by `Card.stQ`). -/
def Card.wAmt : Card → Nat
  | .trainer _ k e _ => if k = .item then e.amt else 0
  | _ => 0

/-- The rest-of-game amount an Item or Supporter card writes when it is played (milestone M5: a
Stadium writes nothing when played, and its effect writes no rest-of-game amount, clause 5). -/
def Card.alAmt : Card → Nat
  | .trainer _ k e _ => if k = .stadium then 0 else e.amtAt .always
  | _ => 0

theorem Card.wAmt_tw : TrainerWeight Card.wAmt := ⟨fun _ => rfl, fun _ => rfl⟩
theorem Card.alAmt_tw : TrainerWeight Card.alAmt := ⟨fun _ => rfl, fun _ => rfl⟩

theorem Card.wAmt_le : ∀ c : Card, c.wAmt ≤ c.amt
  | .trainer _ k e _ => by simp only [Card.wAmt, Card.amt]; split <;> omega
  | .pokemon _ => Nat.le_refl _
  | .energy _ => Nat.le_refl _
  | .tool _ _ => Nat.le_refl _

theorem Card.alAmt_le : ∀ c : Card, c.alAmt ≤ c.amt
  | .trainer _ k e _ => by
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

/-- **Clause 3** (`RecycleSafe`, milestone MV; revised in milestones M8a and M5):
(a) no free recycler (`Card.freeRec`: the effect of an Item or Supporter card, or an "as often as
you like" Ability of a Pokémon card or given by a Tool; not an attack, a "once during your turn"
or on-play Ability, a triggered Ability, or a Stadium's effect) can return from a discard pile to a hand or deck an
Item card of the game that writes a damage bonus or reduction (`Card.wAmt` is nonzero only for
Item cards: a Supporter is played at most once a turn, and Stadium and Tool cards write nothing
when played); and (b) no effect at all, attacks, Abilities and Stadium effects included, can
return an Item or Supporter card that writes a rest-of-game bonus or reduction (`Card.alAmt`).
"Can return": the filter of one of its zone moves out of a discard pile admits the card
(`Effect.recFilters`). Attacks may recycle every other card: an attack ends the turn; so may "once
during your turn" and on-play Abilities, which are used boundedly often in a turn
(`GameState.abPot`), and a Stadium's once-per-turn effect, which may also write a modifier other
than a rest-of-game one (clause 5) and is paid per use through `Card.stQ`, at most two uses a turn
(`GameState.stPot`). Triggered Abilities (milestone M8b) are not free recyclers either: a
`koByAttack` trigger fires only after the turn's attack (`GameState.batchTrigs`), when the per-turn
part of the invariant no longer applies, and a `damaged` trigger fires inside the attack; both are
bound by (b) like every effect. (A first M8b version counted them in (a); that was not needed, and
the class of store-safe decks is now larger.) Decidable (a finite check over pairs of a recycling
filter and a card of the game). For a deck without Abilities, Stadiums or Tools it is the clause of
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
      | energy t =>
          cases t with
          | basic => nomatch hf
          | special m pr x => exact List.mem_append_right _ (unlimitedRec_sub hf)
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
  | .energy (.special _ _ x) => x.grant.abilities.all fun ab => ab.scripts.all fun e =>
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
    | energy t =>
        cases t with
        | basic => nomatch hm
        | special m pr x => exact List.all_eq_true.1 (List.all_eq_true.1 this ab hm) e he
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
  | .trainer _ .stadium e _ => e.amtAt .always == 0
  | _ => true

@[inherit_doc Card.stadiumSafe]
def GameState.StadiumSafe (g : GameState) : Prop := ∀ x ∈ g.allCards, x.stadiumSafe = true

instance (g : GameState) : Decidable g.StadiumSafe := by
  unfold GameState.StadiumSafe; infer_instance

theorem GameState.StadiumSafe.get {g : GameState} (h : g.StadiumSafe) {n : String} {e : Effect}
    {ss : List Static}
    (hx : Card.trainer n .stadium e ss ∈ g.allCards) : e.amtAt .always = 0 :=
  Nat.eq_of_beq_eq_true (h _ hx)

theorem GameState.StadiumSafe.of_perm {g g' : GameState} (h : g.StadiumSafe)
    (hp : g'.allCards.Perm g.allCards) : g'.StadiumSafe :=
  fun x hx => h x (hp.mem_iff.1 hx)

/-- No Stadium's effect writes a damage bonus or reduction (milestone M5): the hypothesis under
which the per-game bound of decks that recycle nothing (`reach_boundedStores_noRecycle`) survives
Stadiums, whose effects are used every turn. Every deck without Stadium cards satisfies it. -/
def GameState.StadiumQuiet (g : GameState) : Prop :=
  ∀ (n : String) (e : Effect) (ss : List Static), Card.trainer n .stadium e ss ∈ g.allCards →
    e.amt = 0

theorem GameState.StadiumQuiet.of_perm {g g' : GameState} (h : g.StadiumQuiet)
    (hp : g'.allCards.Perm g.allCards) : g'.StadiumQuiet :=
  fun n e ss hx => h n e ss (hp.mem_iff.1 hx)

/-- What one use of a Stadium's effect can add to the per-turn count (milestone M5): `Effect.q`
of the effect, what it writes plus `P` if it recycles. 0 for every other card. -/
def Card.stQ (P : Nat) : Card → Nat
  | .trainer _ .stadium e _ => e.q P
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

/-- **Store-safe decks** (milestone MV: three clauses; milestone M8a: four; milestone M5: five, the
fifth `StadiumSafe`, which every deck without Stadium cards satisfies). For a deck with no
recycling (every deck before milestone MV) clause 3 holds (`GameState.NoRecycle.recycleSafe`), and
for a deck without Abilities clause 4 holds and clauses 1 and 3 say what they said before, so for
a deck with neither `StoreSafe` means what it meant before milestone MV: `LoopFree ∧ GXOnly`. -/
def GameState.StoreSafe (g : GameState) : Prop :=
  g.LoopFree ∧ g.GXOnly ∧ g.RecycleSafe ∧ g.AbilitySafe ∧ g.StadiumSafe

/-- A recycling filter of an attack of a card (a Pokémon card's, or one a Tool gives) is one of
the card's. -/
theorem Card.allRec_of_attack {c : Card} {atk : Attack} (hm : atk ∈ c.attacks) {f : Filter}
    (hf : f ∈ atk.effect.recFilters) : f ∈ c.allRec := by
  cases c with
  | pokemon p => exact List.mem_append_left _ (attacksRec_mem hm hf)
  | tool n gr => exact List.mem_append_left _ (attacksRec_mem hm hf)
  | energy t =>
      cases t with
      | basic => nomatch hm
      | special m pr x => exact List.mem_append_left _ (attacksRec_mem hm hf)
  | _ => nomatch hm

/-- A recycling filter of an Ability of a card is one of the card's. -/
theorem Card.allRec_of_ability {c : Card} {ab : Ability} (hm : ab ∈ c.abilities) {e : Effect}
    (he : e ∈ ab.scripts) {f : Filter} (hf : f ∈ e.recFilters) : f ∈ c.allRec := by
  cases c with
  | pokemon p => exact List.mem_append_right _ (abilitiesRec_mem hm he hf)
  | tool n gr => exact List.mem_append_right _ (abilitiesRec_mem hm he hf)
  | energy t =>
      cases t with
      | basic => nomatch hm
      | special m pr x => exact List.mem_append_right _ (abilitiesRec_mem hm he hf)
  | _ => nomatch hm

/-- A recycling filter of an "as often as you like" Ability of a card is a free one. -/
theorem Card.freeRec_of_unlimited {c : Card} {ab : Ability} (hm : ab ∈ c.abilities)
    (hu : ab.use = .unlimited) {e : Effect} (he : e ∈ ab.scripts) {f : Filter}
    (hf : f ∈ e.recFilters) : f ∈ c.freeRec := by
  cases c with
  | pokemon p => exact unlimitedRec_mem hm hu he hf
  | tool n gr => exact unlimitedRec_mem hm hu he hf
  | energy t =>
      cases t with
      | basic => nomatch hm
      | special m pr x => exact unlimitedRec_mem hm hu he hf
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
opponent at least one Prize card. Since milestone batch-KO one check can Knock Out several of the
player's Pokémon while the opponent has fewer Prize cards left than they take; the potential can
then rise, but the opponent has taken their last Prize card and the game is over
(`KOBatch.abPot_le` holds when the game goes on), so the per-turn invariant asks nothing of the
potential of a finished game (`TInv.pot`, `TInv.turn`). So the uses of these Abilities in one turn are at most the
potential at the start of the turn, which is at most `potBound` of the number of cards. The bound
rests on the model having no effect that returns a Pokémon in play to the hand or deck (a Pokémon
leaves play only by a Knock Out, which costs a Prize card); with such an effect (Scoop Up Cyclone)
the same Pokémon card could re-enter play and use or trigger its Ability again. -/

/-- The weight of a Pokémon in play in the potential: 1 if it has not used an Ability this turn,
2 more if it can still evolve this turn. -/
def InPlay.abW (p : InPlay) : Nat := (if p.used then 0 else 1) + (if p.fresh then 0 else 2)

theorem InPlay.abW_le (p : InPlay) : p.abW ≤ 3 := by
  unfold InPlay.abW; split <;> split <;> omega

/-- Marking a Pokémon that moved (milestone MV7c) spends its "once during your turn" limit: its
weight does not rise. -/
theorem InPlay.abW_noteMove (ev : TrigEvent) (sp : Spot) (p : InPlay) :
    (p.noteMove ev sp).abW ≤ p.abW := by
  unfold InPlay.noteMove
  split
  · simp only [InPlay.abW]; split <;> split <;> simp_all
  · exact Nat.le_refl _

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

/-- The state an attack leaves has the potential of the state before (milestone MV4: the lock on
the attacker changes no flag the potential reads). -/
theorem GameState.abPot_afterAttack (l : AtkLock) (x : Bool) (g : GameState) :
    (g.afterAttack l x).abPot = g.abPot := by
  have e1 : abWo (g.cur.active.map (InPlay.noteLock l)) = abWo g.cur.active := by
    cases g.cur.active <;> rfl
  have e2 : optN (g.cur.active.map (InPlay.noteLock l)) = optN g.cur.active := by
    cases g.cur.active <;> rfl
  simp only [GameState.abPot, GameState.afterAttack, PlayerState.abPot, e1, e2]

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

/-- Dealing Energy cards keeps the weights and the number of the Pokémon in play (milestone MV6). -/
theorem Deal.abW {tf : Filter} {t : List Card} {a a' : Option InPlay} {b b' : List InPlay}
    (h : Deal tf t a b a' b') :
    abWo a' + abWs b' = abWo a + abWs b ∧ optN a' + b'.length = optN a + b.length := by
  induction h with
  | nil => exact ⟨rfl, rfl⟩
  | @active e xs p b a' b' ht _ _ ih =>
      have e' : (p.addEnergy (.energy e)).abW = p.abW := rfl
      simp only [abWo, optN, e'] at ih ⊢
      exact ih
  | @bench e xs a q b₁ b₂ a' b' ht _ _ ih =>
      rw [abWs_split (b₁ := b₁) (b₂ := b₂) (q := q) (q' := q.addEnergy (.energy e)) rfl] at ih
      simp only [List.length_append, List.length_cons] at ih ⊢
      exact ih

/-- Placing the cards taken from a window never raises the potential (milestone MV6): a Pokémon
put onto the Bench fills a place with an unused Pokémon. -/
theorem Place.abPot_le {i : Into} {t : List Card} {s s' : PlayerState} (h : Place i t s s') :
    s'.abPot ≤ s.abPot := by
  cases h with
  | put hp =>
      obtain ⟨_, ha, hb⟩ := hp.fields
      exact Nat.le_of_eq (PlayerState.abPot_congr (by rw [ha, hb]) (by rw [ha, hb]))
  | @bench ps s hb hl =>
      have h1 := optN_le s.active
      have hw : ∀ l : List PokemonCard, abWs (l.map InPlay.ofBasic) = l.length := by
        intro l
        induction l with
        | nil => rfl
        | cons p l ih =>
            simp only [List.map_cons, abWs, ih, List.length_cons]
            have : (InPlay.ofBasic p).abW = 1 := rfl
            omega
      simp only [benchLimit] at hl
      simp only [PlayerState.abPot, abWs_append, hw, List.length_append, List.length_map,
        benchLimit]
      omega
  | attach hd =>
      obtain ⟨h1, h2⟩ := hd.abW
      exact Nat.le_of_eq (PlayerState.abPot_congr h1 h2)

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
  | @look w src f q i rest s s₁ s' t r hs hq hr hp =>
      obtain ⟨_, ha, hb⟩ := hr.fields
      have e : s₁.abPot = s.abPot := PlayerState.abPot_congr
        (by rw [ha, hb, Src.set_active, Src.set_bench]) (by rw [ha, hb, Src.set_active, Src.set_bench])
      exact e ▸ hp.abPot_le
  | toolsNone => exact Nat.le_refl _

/-- Moving a damage counter keeps the weights and the number of Pokémon in play. -/
theorem CMove.abPot {f : Filter} {noKO : Bool} {a a' : Option InPlay} {b b' : List InPlay}
    (h : CMove f noKO hp a b a' b') :
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
          have e1 : (Whose.noteDown .own a.cure.unlock).abW ≤ a.abW := InPlay.abW_noteMove _ _ _
          have e2 : (Whose.noteUp .own (Whose.mover .own q)).abW ≤ q.abW := InPlay.abW_noteMove _ _ _
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot, ha, hb, abWo, optN,
            abWs_append, abWs, List.length_append, List.length_cons, Whose.noteBenched,
            GameState.noteBenched]; omega
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
  | benchSome w m f dmg n h =>
      cases w with
      | own =>
          have hw : ∀ x : InPlay, (x.hitWith dmg n).abW = x.abW := fun x => by
            cases dmg
            · rfl
            · exact InPlay.abW_hitBench n x
          have e1 := h.congr abWs fun x y _ _ hy he => by
            rcases hy with rfl | rfl <;> simp only [abWs, he, hw]
          have e2 := h.congr List.length fun _ _ _ _ _ he => by simp only [List.length_cons, he]
          simp only [GameState.side] at e1 e2
          simp only [GameState.abPot, GameState.updSide, PlayerState.abPot, e1, e2]; omega
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

theorem abWs_filter (t : InPlay → Bool) : ∀ b : List InPlay,
    abWs b = abWs (b.filter t) + abWs (b.filter fun p => !t p)
  | [] => rfl
  | p :: ps => by
      have ih := abWs_filter t ps
      cases h : t p <;>
        simp only [List.filter_cons, h, Bool.not_false, Bool.not_true, ite_true,
          Bool.false_eq_true, ite_false, abWs, ih] <;> omega

theorem length_filter_split (t : InPlay → Bool) : ∀ b : List InPlay,
    b.length = (b.filter t).length + (b.filter fun p => !t p).length
  | [] => rfl
  | p :: ps => by
      have ih := length_filter_split t ps
      cases h : t p <;>
        simp only [List.filter_cons, h, Bool.not_false, Bool.not_true, ite_true,
          Bool.false_eq_true, ite_false, List.length_cons, ih] <;> omega

theorem abWo_filter (t : InPlay → Bool) (o : Option InPlay) :
    abWo o = abWo (optFilter t o) + abWo (optFilter (fun p => !t p) o) ∧
      optN o = optN (optFilter t o) + optN (optFilter (fun p => !t p) o) := by
  cases o with
  | none => exact ⟨rfl, rfl⟩
  | some p => cases h : t p <;> simp [optFilter, h, abWo, optN]

theorem optN_le_optPrizes : ∀ o : Option InPlay, optN o ≤ optPrizes o
  | none => Nat.le_refl _
  | some p => p.top.prizeCount_pos

theorem length_le_benchPrizes : ∀ b : List InPlay, b.length ≤ benchPrizes b
  | [] => Nat.le_refl _
  | p :: ps => by
      have := length_le_benchPrizes ps
      have := p.top.prizeCount_pos
      simp only [List.length_cons, benchPrizes]; omega

/-- The check's removal raises a player's potential by at most two units for each Pokémon removed
(the places it frees), and so by at most twice the Prize value of those Pokémon. -/
theorem PlayerState.koOut_abPot (ta tb : InPlay → Bool) (s : PlayerState) :
    (s.koOut ta tb).abPot ≤ s.abPot + 2 * s.koValue ta tb := by
  obtain ⟨a1, a2⟩ := abWo_filter ta s.active
  have b1 := abWs_filter tb s.bench
  have b2 := length_filter_split tb s.bench
  have c1 := optN_le_optPrizes (optFilter ta s.active)
  have c2 := length_le_benchPrizes (s.bench.filter tb)
  simp only [PlayerState.abPot, PlayerState.koOut, PlayerState.koValue]
  omega

/-- A promotion keeps the potential: the same Pokémon, in the same number of places. -/
theorem Promote.abPot {a a' : Option InPlay} {b b' : List InPlay} (h : Promote a b a' b') :
    abWo a' + abWs b' = abWo a + abWs b ∧ optN a' + b'.length = optN a + b.length := by
  cases h with
  | keep => exact ⟨rfl, rfl⟩
  | pick =>
      simp only [abWo, optN, abWs_append, abWs, List.length_append, List.length_cons]
      constructor <;> omega

/-- **The batch Knock Out step does not raise the potential, unless it ends the game.** Each of
the player's Knocked Out Pokémon frees a place (two units), and the opponent takes Prize cards for
it, at least one each (two units each); if the opponent has fewer Prize cards left than they take,
they have taken their last one and the game is over. (A batch can Knock Out several of the
player's Pokémon while the opponent's Prize cards run out: then the potential can rise, and the
game has ended; `TInv` asks nothing of the potential of a finished game.) Promotions move Pokémon
without changing the weights or the number of places. -/
theorem KOBatch.abPot_le {g g' : GameState} (h : KOBatch g g') (hw : g'.winner = none) :
    g'.abPot ≤ g.abPot := by
  obtain ⟨-, p2, -, -, pw⟩ := h.piles
  have hw' : g.koStep.winner = none := pw ▸ hw
  obtain ⟨-, -, h2⟩ := GameState.koStep_winner_none hw'
  have hpw := (winWays_eq_zero h2).1
  have hcur : g'.cur.abPot ≤ (g.koOf .own).abPot := by
    cases h with
    | won => exact Nat.le_refl _
    | @go ac ao bc bo _ _ hc _ =>
        obtain ⟨e1, e2⟩ := hc.abPot
        have k1 : abWo (if g.promoUp then ac.map (InPlay.noteMove .movedUp .active) else ac) ≤
            abWo ac := by
          split
          · cases ac with
            | none => exact Nat.le_refl _
            | some x => exact InPlay.abW_noteMove _ _ x
          · exact Nat.le_refl _
        have k2 : optN (if g.promoUp then ac.map (InPlay.noteMove .movedUp .active) else ac) =
            optN ac := by
          split
          · cases ac <;> rfl
          · rfl
        have e : (g.koOf .own).abPot = g.koStep.cur.abPot := rfl
        rw [e]
        simp only [PlayerState.abPot] at e1 e2 ⊢
        simp only [GameState.afterBatch, GameState.withPlay, k2]
        omega
  have hk : (g.koOf .own).abPot ≤ g.cur.abPot + 2 * g.koVal .own :=
    PlayerState.koOut_abPot (g.koT .own .active) (g.koT .own .bench) g.cur
  have hpr : g'.opp.prizes = g.opp.prizes.drop (g.koVal .own) := p2
  have hlen : g'.opp.prizes.length + g.koVal .own = g.opp.prizes.length := by
    rw [hpr, List.length_drop]
    cases e : g.koVal .own with
    | zero => omega
    | succ n =>
        rw [e] at hpw
        have ho : (g.opp.prizes.drop (n + 1)).isEmpty = false := by
          simpa [PlayerState.prizeWin, PlayerState.prizesOut] using hpw
        have : n + 1 < g.opp.prizes.length := by
          cases e2 : g.opp.prizes.drop (n + 1) with
          | nil => rw [e2] at ho; cases ho
          | cons x xs =>
              have := congrArg List.length e2
              simp only [List.length_drop, List.length_cons] at this
              omega
        omega
  simp only [GameState.abPot]
  omega

/-- An effect of the trigger fragment never raises the potential of the opponent of the player it
resolves for. -/
theorem Run.oppAbPot_le {e : Effect} {g g' : GameState} (h : Run e g g') :
    e.trigOk = true → g'.opp.abPot ≤ g.opp.abPot := by
  induction h with
  | seq _ _ ih₁ ih₂ =>
      intro hk
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      exact Nat.le_trans (ih₂ hk.2) (ih₁ hk.1)
  | choiceL _ ih =>
      intro hk; simp only [Effect.trigOk, Bool.and_eq_true] at hk; exact ih hk.1
  | choiceR _ ih =>
      intro hk; simp only [Effect.trigOk, Bool.and_eq_true] at hk; exact ih hk.2
  | @counters g p n h =>
      intro _
      have e : ({ p with damage := p.damage + n } : InPlay).abW = p.abW := rfl
      simp only [PlayerState.abPot, h, abWo, optN, e]; omega
  | @inflict g p c h =>
      intro _
      have e : (p.inflict c).abW = p.abW := by cases c <;> rfl
      simp only [PlayerState.abPot, h, abWo, optN, e]; omega
  | @zone e w g s' hw hz =>
      intro _
      cases w with
      | own => exact Nat.le_refl _
      | opp =>
          have := hz.abPot_le
          simp only [GameState.side] at this
          exact this
  | skip => intro _; exact Nat.le_refl _
  | draw => intro _; exact Nat.le_refl _
  | drawEmpty => intro _; exact Nat.le_refl _
  | shuffle => intro _; exact Nat.le_refl _
  | @touchActive e w f g p he h =>
      intro hk; cases e <;> simp [Effect.touch, Effect.trigOk] at he hk
  | @touchBench e w f g q b₁ b₂ he h =>
      intro hk; cases e <;> simp [Effect.touch, Effect.trigOk] at he hk
  | _ => intro hk; simp [Effect.trigOk] at hk

/-- **A trigger resolution does not raise the potential of the player to move**: it changes no
Prize card, and its effects on that player's Pokémon (the trigger owner's opponent's) never raise
their potential. -/
theorem Fire.abPot_le {ev : TrigEvent} {l : List Ability} {g g' : GameState}
    (h : Fire ev l g g') : g'.abPot ≤ g.abPot := by
  induction h with
  | nil => exact Nat.le_refl _
  | @run ab l g g₁ g₂ hk hr _ ih =>
      have h1 : g₁.opp.abPot ≤ g.cur.abPot := hr.oppAbPot_le hk
      have h2 : g₁.cur.prizes = g.opp.prizes := (hr.zoneOnly hk).cur_prizes
      have h3 : g₁.swap.abPot ≤ g.abPot := by
        show g₁.opp.abPot + 2 * g₁.cur.prizes.length ≤ g.cur.abPot + 2 * g.opp.prizes.length
        rw [h2]; omega
      exact Nat.le_trans ih h3
  | decline _ _ ih => exact ih

/-- Triggers resolved on the exchanged state do not raise the potential of the player to move of
the state before the exchange (milestone MV7c): each step is a resolution from that player's side,
and no resolution raises their potential (`Run.abPot_le`). -/
theorem Fire.swap_abPot_le {ev : TrigEvent} {l : List Ability} {g g' : GameState}
    (h : Fire ev l g g') : g'.swap.abPot ≤ g.swap.abPot := by
  induction h with
  | nil => exact Nat.le_refl _
  | @run ab l g g₁ g₂ hk hr _ ih =>
      have h1 := hr.abPot_le
      rw [GameState.swap_swap] at ih
      exact Nat.le_trans ih h1
  | decline _ _ ih => exact ih

/-- **The player to move's own triggers do not raise their potential** (milestone MV7c). -/
theorem FireMine.abPot_le {u d : List Ability} {g g' : GameState} (h : FireMine u d g g') :
    g'.abPot ≤ g.abPot := by
  obtain ⟨g₁, g₂, h₁, h₂, rfl⟩ := h
  have a := h₁.swap_abPot_le
  have b := h₂.swap_abPot_le
  rw [GameState.swap_swap] at a
  exact Nat.le_trans b a

/-- **The resolution of the owed triggers does not raise the potential** (milestone MV7c). -/
theorem Owed.abPot_le {g g' : GameState} (h : Owed g g') : g'.abPot ≤ g.abPot := by
  have e : g.unpend.abPot = g.abPot := by
    have ea : abWo (g.cur.active.map InPlay.clearOwe) = abWo g.cur.active := by
      cases g.cur.active <;> rfl
    have en : optN (g.cur.active.map InPlay.clearOwe) = optN g.cur.active := by
      cases g.cur.active <;> rfl
    simp only [GameState.abPot, GameState.unpend, PlayerState.abPot, ea, en,
      abWs_map (f := InPlay.clearOwe) (fun _ => rfl), List.length_map]
  rw [← e]
  cases h with
  | mineFirst _ _ _ hm ht => exact Nat.le_trans ht.abPot_le hm.abPot_le
  | oppFirst _ _ _ ht hm => exact Nat.le_trans hm.abPot_le ht.abPot_le

/-- A resolution that ends with no winner passed only through states with no winner. -/
theorem Resolve.winner_back {g g' : GameState} (h : Resolve g g') (hw : g'.winner = none) :
    g.winner = none := by
  cases h with
  | done => exact hw
  | step hn => exact hn
  | trigger hn => exact hn

theorem TRun.winner_back {e : Effect} {g g' : GameState} (h : TRun e g g') (hw : g'.winner = none) :
    g.winner = none := by
  induction h with
  | prim _ hn => exact hn
  | stop => exact hw
  | iteT hn => exact hn
  | iteF hn => exact hn
  | seq _ _ ih₁ ih₂ => exact ih₁ (ih₂ hw)
  | choiceL _ ih => exact ih hw
  | choiceR _ ih => exact ih hw
  | iterNil => exact hw
  | iterCons _ _ ih₁ ih₂ => exact ih₁ (ih₂ hw)

theorem Resolve.abPot_le {g g' : GameState} (h : Resolve g g') (hw : g'.winner = none) :
    g'.abPot ≤ g.abPot := by
  induction h with
  | done => exact Nat.le_refl _
  | step _ hm hr ih => exact Nat.le_trans (ih hw) (hm.abPot_le (hr.winner_back hw))
  | trigger _ _ _ ho _ ih => exact Nat.le_trans (ih hw) ho.abPot_le

/-- A Trainer effect's resolution does not raise the potential, unless it ends the game. -/
theorem TRun.abPot_le {e : Effect} {g g' : GameState} (h : TRun e g g') (hw : g'.winner = none) :
    g'.abPot ≤ g.abPot := by
  induction h with
  | prim _ _ hr hk => exact Nat.le_trans (hk.abPot_le hw) hr.abPot_le
  | stop => exact Nat.le_refl _
  | iteT _ _ _ _ ih => exact ih hw
  | iteF _ _ _ _ ih => exact ih hw
  | seq _ h₂ ih₁ ih₂ => exact Nat.le_trans (ih₂ hw) (ih₁ (h₂.winner_back hw))
  | choiceL _ ih => exact ih hw
  | choiceR _ ih => exact ih hw
  | iterNil => exact Nat.le_refl _
  | iterCons _ h₂ ih₁ ih₂ => exact Nat.le_trans (ih₂ hw) (ih₁ (h₂.winner_back hw))

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
          poisoned := false, burned := false, poisonUp := 0, fresh := true, used := false, lk := {} } = 1 :=
        rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | @evolveBench l₁ l₂ p q b₁ b₂ hh hb he hfr =>
      have : q.abW ≥ 2 := by unfold InPlay.abW; rw [hfr]; split <;> simp
      have e : InPlay.abW { q with
          top := p, under := Card.pokemon q.top :: q.under, rot := .none,
          poisoned := false, burned := false, poisonUp := 0, fresh := true, used := false, lk := {} } = 1 :=
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

/-! ## Triggers (milestone M8b)

A trigger resolution (`Fire`) changes only the zones (`Fire.zoneOnly`): it writes no store and keeps
the turn flags. What the store bound needs of it beyond that: it moves no card with an amount out of
a discard pile when its Abilities' recycling filters admit none (`Fire.disc_mono`; clause 3 (b)
reads every Ability, and clause 3 (a) is not needed: a `koByAttack` trigger fires after the turn's
attack, `GameState.attacked_of_batchTrigs`, where the per-turn part of the invariant is vacuous,
`TInv.same'`), and it does not raise the potential of the player to move (`Fire.abPot_le`): its
effects on that player's side (the opponent of the trigger's owner) add damage counters, a Special
Condition, or move cards, which never raise a player's potential. -/

theorem Ability.event_of_trigOn {ev : TrigEvent} {sp : Spot} {ab : Ability}
    (h : ab.trigOn ev sp = true) : ab.use.event = some ev := by
  simp only [Ability.trigOn, Bool.and_eq_true, beq_iff_eq] at h
  exact h.1.1.1.1

theorem InPlay.trigs_card {ev : TrigEvent} {sp : Spot} {p : InPlay} {ab : Ability}
    (h : ab ∈ p.trigs ev sp) : ∃ c ∈ p.cardList, ab ∈ c.abilities ∧ ab.use.event = some ev := by
  obtain ⟨hm, ht⟩ := List.mem_filter.1 h
  obtain ⟨c, hc, hmc⟩ := InPlay.ability_mem hm
  exact ⟨c, hc, hmc, Ability.event_of_trigOn ht⟩

/-- Every `damaged` trigger an attack can fire is an Ability of a card of the game. -/
theorem GameState.optTrigs_card {g : GameState} {ev : TrigEvent} {ab : Ability}
    (h : ab ∈ optTrigs ev g.opp.active) :
    ∃ c ∈ g.allCards, ab ∈ c.abilities ∧ ab.use.event = some ev := by
  cases ha : g.opp.active with
  | none => rw [ha] at h; nomatch h
  | some p =>
      rw [ha] at h
      obtain ⟨c, hc, hmc, he⟩ := InPlay.trigs_card h
      exact ⟨c, GameState.mem_allCards_of_opp_active ha hc, hmc, he⟩

/-- Every trigger a batch can fire is an Ability of a card of the game. -/
theorem GameState.koTrigs_card {g : GameState} {ab : Ability} (h : ab ∈ g.koTrigs) :
    ∃ c ∈ g.allCards, ab ∈ c.abilities ∧ ab.use.event = some .koByAttack := by
  rcases List.mem_append.1 h with h | h
  · cases ha : g.opp.active with
    | none => rw [ha] at h; nomatch h
    | some p =>
        rw [ha] at h
        cases ht : g.koT .opp .active p with
        | false => simp only [optFilter, ht, Bool.false_eq_true, ite_false] at h; nomatch h
        | true =>
            simp only [optFilter, ht, ite_true, optTrigs] at h
            obtain ⟨c, hc, hmc, he⟩ := InPlay.trigs_card h
            exact ⟨c, GameState.mem_allCards_of_opp_active ha hc, hmc, he⟩
  · obtain ⟨p, hp, hm⟩ := List.mem_flatMap.1 h
    obtain ⟨c, hc, hmc, he⟩ := InPlay.trigs_card hm
    exact ⟨c, GameState.mem_allCards_of_opp_bench (List.mem_filter.1 hp).1 hc, hmc, he⟩

theorem GameState.batchTrigs_card {g g₁ : GameState} {ab : Ability} (h : ab ∈ g.batchTrigs g₁) :
    ∃ c ∈ g.allCards, ab ∈ c.abilities ∧ ab.use.event = some .koByAttack := by
  unfold GameState.batchTrigs at h
  split at h
  · exact GameState.koTrigs_card h
  · nomatch h

end Pokemon
