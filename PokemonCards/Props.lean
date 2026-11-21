import Pokemon.Faithful

/-!
# Checks on imported cards

Hand-written (not generated). The importer (`tools/importer/`) writes printed Standard cards as
terms of the model's `Card` type in `PokemonCards/Standard/Part*.lean`. This file gives the
decidable checks those files prove of every card, and the lemmas that turn them into the
statements the model's theorems use. Every check is stated with the model's own predicates
(`Card.attacks` and `Card.abilities`, which since milestone M5 include what a Pokémon Tool gives;
`Card.loopFree`, `Card.abilitySafe`, `Card.stadiumSafe`, `Card.freeRec`, `Card.allRec`,
`Card.wAmt`, `Card.alAmt`); nothing here redefines a clause.

* `Card.importOk`: every attack the card has or gives is well formed (`Attack.wf`, a premise of
  `Move.attack`); a Trainer's effect (an Item's or Supporter's, or since milestone M5 a Stadium's)
  is `hitFree` and `benchHitFree` (premises of `Move.item`, `Move.supporter` and
  `Move.stadiumUse`); every script of every Ability the card has or gives is `hitFree` and
  `benchHitFree` (premises of `Move.ability` and `Move.onPlay`); the card satisfies clause 1 of
  `Faithful` (`Card.loopFree`), the per-card part of clause 2 (`GXOnly`: an attack that is not a
  GX attack writes no rest-of-game bonus or reduction), clause 4 (`Card.abilitySafe`) and clause 5
  (`Card.stadiumSafe`: a Stadium's effect writes no rest-of-game bonus or reduction).
* `recSafeB C`: clause 3 of `Faithful` (`RecycleSafe`) for every game whose cards all come from `C`,
  as one Boolean over the recycling filters of `C` (`Card.freeRec`, which counts "as often as you
  like" Abilities with Items and Supporters and, since milestone M5, not Stadiums, whose uses are
  bounded per turn; and `Card.allRec`) and the modifier writers of `C`.
* `faithful_of`: from both, every game whose cards all come from `C` is `Faithful` (all five
  clauses), so `Faithful.xfinite` applies to it.
* `nodupFp`: a check that a list of cards has no two equal terms, cheap enough for the kernel on
  the whole imported list (`nodup_of_nodupFp`).

These are facts about the Lean terms; whether a term says what its printed card says is the
importer's claim, checked by eye in survey S11, not by Lean.
-/

namespace Pokemon

/-- Every attack the card has or (a Tool, milestone M5) gives is well formed (`Attack.wf`). -/
def Card.attacksWf (c : Card) : Bool := c.attacks.all Attack.wf

/-- A Trainer's effect (an Item's or a Supporter's when played, a Stadium's when used) has no
attack damage step and no attack damage to the Bench. -/
def Card.trainerOk : Card → Bool
  | .trainer _ _ e _ => e.hitFree && e.benchHitFree
  | _ => true

/-- The per-card part of `GXOnly`: an attack the card has or gives that is not a GX attack writes no
rest-of-game damage bonus or reduction. -/
def Card.gxOk (c : Card) : Bool := c.attacks.all fun a => a.gx || a.effect.amtAt .always == 0

/-- Every script of every Ability the card has or gives has no attack damage step and no attack
damage to the Bench (`Move.ability` and `Move.onPlay` require both of the script they resolve). -/
def Card.abilitiesOk (c : Card) : Bool :=
  c.abilities.all fun ab => ab.scripts.all fun e => e.hitFree && e.benchHitFree

/-- The per-card checks every imported card passes. -/
def Card.importOk (c : Card) : Bool :=
  c.attacksWf && c.trainerOk && c.abilitiesOk && c.loopFree && c.gxOk && c.abilitySafe &&
    c.stadiumSafe

/-- Any lingering modifier (bonus, reduction, prevention or lock) anywhere in the effect. -/
def Effect.lingers : Effect → Bool
  | .linger _ _ _ => true
  | .ite _ a b => a.lingers || b.lingers
  | .seq a b => a.lingers || b.lingers
  | .choice a b => a.lingers || b.lingers
  | .iter a => a.lingers
  | _ => false

/-- A Trainer card's effect (an Item's or Supporter's when played, a Stadium's when used), `skip`
for other cards. -/
def Card.trainerEffect : Card → Effect
  | .trainer _ _ e _ => e
  | _ => .skip

/-- The card writes a lingering damage bonus or reduction (`Effect.writes`) in an attack or an
Ability it has or gives (any script), or as a Trainer. -/
def Card.writesAmt (c : Card) : Bool :=
  (c.attacks.any fun a => a.effect.writes) || (c.abilities.any fun ab => ab.scripts.any Effect.writes) ||
    c.trainerEffect.writes

/-- The card writes any lingering modifier (in an attack or Ability it has or gives, or as a
Trainer). -/
def Card.lingers (c : Card) : Bool :=
  (c.attacks.any fun a => a.effect.lingers) || (c.abilities.any fun ab => ab.scripts.any Effect.lingers) ||
    c.trainerEffect.lingers

/-- An Ability the card has or gives writes a lingering damage bonus or reduction (in any script). -/
def Card.abilityWrites (c : Card) : Bool := c.abilities.any fun ab => ab.scripts.any Effect.writes

/-- An Ability the card has or gives writes any lingering modifier (in any of its scripts). -/
def Card.abilityLingers (c : Card) : Bool := c.abilities.any fun ab => ab.scripts.any Effect.lingers

/-- The card has or gives an "as often as you like" Ability. -/
def Card.hasUnlimited (c : Card) : Bool := c.abilities.any fun ab => ab.use == .unlimited

/-- The card has or gives an Ability that can return a card from a discard pile
(`Effect.recFilters` of one of its scripts). -/
def Card.abilityRecycles (c : Card) : Bool :=
  c.abilities.any fun ab => ab.scripts.any fun e => !e.recFilters.isEmpty

/-- The printed name (Basic Energy cards are labelled by kind only). -/
def Card.label : Card → String
  | .pokemon p => p.name
  | .trainer n _ _ _ => n
  | .tool n _ => n
  | .energy _ => "Basic Energy"

end Pokemon

namespace PokemonCards

open Pokemon

/-- Clause 3 of `Faithful` for the pool `C`, decidable by evaluation: no recycling filter of an Item
or Supporter or of an "as often as you like" Ability of `C` (`Card.freeRec`; since milestone M5 a
Stadium's effect is not a free recycler) admits a card of `C` that is an Item writing a bonus or
reduction (`Card.wAmt`), and no recycling filter of any effect of `C`, attacks, Abilities and
Stadium effects included (`Card.allRec`), admits a card of `C` that writes a rest-of-game bonus or
reduction when played (`Card.alAmt`). -/
def recSafeB (C : List Card) : Bool :=
  ((C.flatMap Card.freeRec).all fun f => (C.filter fun y => y.wAmt != 0).all fun y => !f.eval y) &&
  ((C.flatMap Card.allRec).all fun f => (C.filter fun y => y.alAmt != 0).all fun y => !f.eval y)

/-- `recSafeB C` gives `RecycleSafe` for every game whose cards all come from `C`. -/
theorem recycleSafe_of {C : List Card} (h : recSafeB C = true) (g : GameState)
    (hg : ∀ x ∈ g.allCards, x ∈ C) : g.RecycleSafe := by
  unfold recSafeB at h
  rw [Bool.and_eq_true] at h
  obtain ⟨h1, h2⟩ := h
  refine ⟨fun x hx f hf y hy hfy => ?_, fun x hx f hf y hy hfy => ?_⟩
  · cases hw : y.wAmt with
    | zero => rfl
    | succ n =>
      have hf' : f ∈ C.flatMap Card.freeRec := List.mem_flatMap.2 ⟨x, hg x hx, hf⟩
      have hy' : y ∈ C.filter (fun y => y.wAmt != 0) := List.mem_filter.2 ⟨hg y hy, by simp [hw]⟩
      have := List.all_eq_true.1 (List.all_eq_true.1 h1 f hf') y hy'
      rw [hfy] at this
      exact absurd this (by decide)
  · cases hw : y.alAmt with
    | zero => rfl
    | succ n =>
      have hf' : f ∈ C.flatMap Card.allRec := List.mem_flatMap.2 ⟨x, hg x hx, hf⟩
      have hy' : y ∈ C.filter (fun y => y.alAmt != 0) := List.mem_filter.2 ⟨hg y hy, by simp [hw]⟩
      have := List.all_eq_true.1 (List.all_eq_true.1 h2 f hf') y hy'
      rw [hfy] at this
      exact absurd this (by decide)

theorem importOk_parts {c : Card} (h : c.importOk = true) :
    c.attacksWf = true ∧ c.trainerOk = true ∧ c.abilitiesOk = true ∧ c.loopFree = true ∧
      c.gxOk = true ∧ c.abilitySafe = true ∧ c.stadiumSafe = true := by
  simp only [Card.importOk, Bool.and_eq_true] at h
  obtain ⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩ := h
  exact ⟨h1, h2, h3, h4, h5, h6, h7⟩

/-- Every attack a card of a checked pool has or (a Tool) gives is well formed (`Attack.wf`, a
premise of `Move.attack` and `Move.attackConfused`). -/
theorem attacks_wf_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ a ∈ c.attacks, a.wf = true :=
  fun c hc a ha => List.all_eq_true.1 (importOk_parts (List.all_eq_true.1 h c hc)).1 a ha

theorem trainers_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ n k e ss, c = .trainer n k e ss → e.hitFree = true ∧ e.benchHitFree = true := by
  intro c hc n k e ss he
  have := (importOk_parts (List.all_eq_true.1 h c hc)).2.1
  subst he
  simpa only [Card.trainerOk, Bool.and_eq_true] using this

theorem loopFree_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, c.loopFree = true :=
  fun c hc => (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.1

/-- The per-card part of clause 2 for every card of a checked pool, over the attacks each card has
or (a Tool) gives (`Card.attacks`, as `GameState.GXOnly` reads them). -/
theorem gxOnly_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ atk ∈ c.attacks, atk.gx = false → atk.effect.amtAt .always = 0 := by
  intro c hc atk ha hgx
  have := (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.2.1
  have h2 := List.all_eq_true.1 this atk ha
  rw [hgx, Bool.false_or] at h2
  exact Nat.eq_of_beq_eq_true h2

/-- Clause 4 for every card of a checked pool. -/
theorem abilitySafe_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, c.abilitySafe = true :=
  fun c hc => (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.2.2.1

/-- Clause 5 for every card of a checked pool. -/
theorem stadiumSafe_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, c.stadiumSafe = true :=
  fun c hc => (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.2.2.2

/-- Every script of every Ability a card of a checked pool has or (a Tool) gives has no attack
damage, on the Active Pokémon or the Bench (the premises `hnd` and `hbh` of `Move.ability` and
`Move.onPlay`). -/
theorem abilities_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ ab ∈ c.abilities, ∀ e ∈ ab.scripts, e.hitFree = true ∧ e.benchHitFree = true := by
  intro c hc ab hab e he
  have := (importOk_parts (List.all_eq_true.1 h c hc)).2.2.1
  have h2 := List.all_eq_true.1 (List.all_eq_true.1 this ab hab) e he
  simpa only [Bool.and_eq_true] using h2

/-! ### Distinct terms

`List.Nodup` of a thousand `Card` terms by `decide` compares every pair with the derived
`DecidableEq`, which the kernel evaluates slowly and with much memory. `nodupFp` first compares a
cheap fingerprint (`cardFp`, a natural number from HP, retreat, type, Weakness and each attack's
damage and cost length), and compares the terms only when the fingerprints agree; `nodupFp_append`
and `crossOk_append_left` let a long list be checked block by block. The fingerprint is used only
to skip comparisons: whatever it is, `nodupFp l = true` gives `l.Nodup`. -/

/-- The position of a type in `EType`'s declaration. -/
def etypeIdx : EType → Nat
  | .grass => 0 | .fire => 1 | .water => 2 | .lightning => 3 | .psychic => 4 | .fighting => 5
  | .darkness => 6 | .metal => 7 | .fairy => 8 | .dragon => 9 | .colorless => 10

/-- A fingerprint of a card; equal cards have equal fingerprints. -/
def cardFp : Card → Nat
  | .pokemon p => (p.attacks.foldl (fun h a => (h * 64 + a.damage) * 8 + a.cost.length)
      (((p.hp * 8 + p.retreat) * 16 + etypeIdx p.type) * 16 +
        (match p.weakness with | some t => etypeIdx t + 1 | none => 0))) * 3
  | .energy _ => 1
  | .trainer _ _ _ _ => 2
  | .tool _ _ => 4

/-- No card of `l₁` is the same term as a card of `l₂`. -/
def crossOk (l₁ l₂ : List Card) : Bool :=
  l₁.all fun a => l₂.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)

/-- No two entries of the list are the same term. -/
def nodupFp : List Card → Bool
  | [] => true
  | a :: l => crossOk [a] l && nodupFp l

theorem crossOk_append_left (l₁ l₂ l₃ : List Card) :
    crossOk (l₁ ++ l₂) l₃ = (crossOk l₁ l₃ && crossOk l₂ l₃) := by
  simp only [crossOk, List.all_append]

theorem crossOk_cons_left (a : Card) (l₁ l₃ : List Card) :
    crossOk (a :: l₁) l₃ = (crossOk [a] l₃ && crossOk l₁ l₃) := by
  simp only [crossOk, List.all_cons, List.all_nil, Bool.and_true]

theorem crossOk_append_right (l₁ l₂ l₃ : List Card) :
    crossOk l₁ (l₂ ++ l₃) = (crossOk l₁ l₂ && crossOk l₁ l₃) := by
  induction l₁ with
  | nil => rfl
  | cons a l ih =>
    rw [crossOk_cons_left, ih, crossOk_cons_left a l l₂, crossOk_cons_left a l l₃]
    simp only [crossOk, List.all_cons, List.all_nil, Bool.and_true, List.all_append]
    cases (l₂.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)) <;>
    cases (l₃.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)) <;>
    cases (l.all fun a => l₂.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)) <;>
    cases (l.all fun a => l₃.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)) <;> rfl

theorem nodupFp_append (l₁ l₂ : List Card) :
    nodupFp (l₁ ++ l₂) = (nodupFp l₁ && nodupFp l₂ && crossOk l₁ l₂) := by
  induction l₁ with
  | nil => simp [nodupFp, crossOk]
  | cons a l ih =>
    simp only [List.cons_append, nodupFp, ih, crossOk_append_right, crossOk_cons_left a l l₂]
    cases crossOk [a] l <;> cases crossOk [a] l₂ <;> cases nodupFp l <;> cases nodupFp l₂ <;>
      cases crossOk l l₂ <;> rfl

/-- `nodupFp` decides `List.Nodup` (in one direction, which is all the generated files use). -/
theorem nodup_of_nodupFp {l : List Card} (h : nodupFp l = true) : l.Nodup := by
  induction l with
  | nil => exact List.nodup_nil
  | cons a l ih =>
    rw [nodupFp, Bool.and_eq_true] at h
    refine List.nodup_cons.2 ⟨fun hm => ?_, ih h.2⟩
    have := List.all_eq_true.1 (List.all_eq_true.1 h.1 a (List.mem_singleton_self a)) a hm
    rw [decide_eq_true rfl, decide_eq_true rfl] at this
    exact absurd this (by decide)

/-- **Faithful decks from a checked pool.** If every card of `C` passes `Card.importOk` and
`recSafeB C` holds, every game whose cards all come from `C` is `Faithful`: `LoopFree`, `GXOnly`,
`RecycleSafe`, `AbilitySafe` and `StadiumSafe`. -/
theorem faithful_of {C : List Card} (h : C.all Card.importOk = true) (hr : recSafeB C = true)
    (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ C) : g.Faithful :=
  ⟨fun x hx => loopFree_of h x (hg x hx),
   fun c hc atk ha hgx => gxOnly_of h c (hg c hc) atk ha hgx,
   recycleSafe_of hr g hg,
   fun x hx => abilitySafe_of h x (hg x hx),
   fun x hx => stadiumSafe_of h x (hg x hx)⟩

end PokemonCards
