import Pokemon.Faithful

/-!
# Checks on imported cards

Hand-written (not generated). The importer (`tools/importer/`) writes printed Standard cards as
terms of the model's `Card` type in `PokemonCards/Standard/Part*.lean`. This file gives the
decidable checks those files prove of every card, and the lemmas that turn them into the
statements the model's theorems use.

* `Card.importOk`: every attack is well formed (`Attack.wf`, a premise of `Move.attack`); a
  Trainer's effect is `hitFree` and `benchHitFree` (premises of `Move.item` and `Move.supporter`);
  every script of every Ability is `hitFree` and `benchHitFree` (premises of `Move.ability` and
  `Move.onPlay`); the card satisfies clause 1 of `Faithful` (`Card.loopFree`, Ability scripts
  included); its attacks satisfy the per-card part of clause 2 (`GXOnly`: an attack that is not a
  GX attack writes no rest-of-game bonus or reduction); and it satisfies clause 4
  (`Card.abilitySafe`: no "as often as you like" Ability writes a bonus or reduction, and no Ability
  a rest-of-game one).
* `recSafeB C`: clause 3 of `Faithful` (`RecycleSafe`) for every game whose cards all come from `C`,
  as one Boolean over the recycling filters of `C` (`Card.freeRec`, which counts "as often as you
  like" Abilities with Trainers, and `Card.allRec`) and the modifier writers of `C`.
* `faithful_of`: from both, every game whose cards all come from `C` is `Faithful` (all four
  clauses), so `Faithful.xfinite` applies to it.
* `nodupFp`: a check that a list of cards has no two equal terms, cheap enough for the kernel on
  the whole imported list (`nodup_of_nodupFp`).

These are facts about the Lean terms; whether a term says what its printed card says is the
importer's claim, checked by eye in survey S11, not by Lean.
-/

namespace Pokemon

/-- Every attack of the card is well formed (`Attack.wf`). -/
def Card.attacksWf : Card → Bool
  | .pokemon p => p.attacks.all Attack.wf
  | _ => true

/-- A Trainer's effect has no attack damage step and no attack damage to the Bench. -/
def Card.trainerOk : Card → Bool
  | .trainer _ _ e => e.hitFree && e.benchHitFree
  | _ => true

/-- The per-card part of `GXOnly`: an attack that is not a GX attack writes no rest-of-game damage
bonus or reduction. -/
def Card.gxOk : Card → Bool
  | .pokemon p => p.attacks.all fun a => a.gx || a.effect.amtAt .always == 0
  | _ => true

/-- Every script of every Ability of the card has no attack damage step and no attack damage to the
Bench (`Move.ability` and `Move.onPlay` require both of the script they resolve). -/
def Card.abilitiesOk : Card → Bool
  | .pokemon p => p.abilities.all fun ab => ab.scripts.all fun e => e.hitFree && e.benchHitFree
  | _ => true

/-- The per-card checks every imported card passes. -/
def Card.importOk (c : Card) : Bool :=
  c.attacksWf && c.trainerOk && c.abilitiesOk && c.loopFree && c.gxOk && c.abilitySafe

/-- Any lingering modifier (bonus, reduction, prevention or lock) anywhere in the effect. -/
def Effect.lingers : Effect → Bool
  | .linger _ _ _ => true
  | .ite _ a b => a.lingers || b.lingers
  | .seq a b => a.lingers || b.lingers
  | .choice a b => a.lingers || b.lingers
  | .iter a => a.lingers
  | _ => false

/-- The card writes a lingering damage bonus or reduction (`Effect.writes`) in an attack, in an
Ability (any of its scripts) or as a Trainer. -/
def Card.writesAmt : Card → Bool
  | .pokemon p => (p.attacks.any fun a => a.effect.writes) ||
      p.abilities.any fun ab => ab.scripts.any Effect.writes
  | .trainer _ _ e => e.writes
  | .energy _ => false

/-- The card writes any lingering modifier (in an attack, an Ability or as a Trainer). -/
def Card.lingers : Card → Bool
  | .pokemon p => (p.attacks.any fun a => a.effect.lingers) ||
      p.abilities.any fun ab => ab.scripts.any Effect.lingers
  | .trainer _ _ e => e.lingers
  | .energy _ => false

/-- An Ability of the card writes a lingering damage bonus or reduction (in any of its scripts). -/
def Card.abilityWrites : Card → Bool
  | .pokemon p => p.abilities.any fun ab => ab.scripts.any Effect.writes
  | _ => false

/-- An Ability of the card writes any lingering modifier (in any of its scripts). -/
def Card.abilityLingers : Card → Bool
  | .pokemon p => p.abilities.any fun ab => ab.scripts.any Effect.lingers
  | _ => false

/-- The card has an "as often as you like" Ability. -/
def Card.hasUnlimited : Card → Bool
  | .pokemon p => p.abilities.any fun ab => ab.use == .unlimited
  | _ => false

/-- The card has an Ability that can return a card from a discard pile (`Effect.recFilters` of one
of its scripts). -/
def Card.abilityRecycles : Card → Bool
  | .pokemon p => p.abilities.any fun ab => ab.scripts.any fun e => !e.recFilters.isEmpty
  | _ => false

/-- The printed name (Basic Energy cards are labelled by kind only). -/
def Card.label : Card → String
  | .pokemon p => p.name
  | .trainer n _ _ => n
  | .energy _ => "Basic Energy"

end Pokemon

namespace PokemonCards

open Pokemon

/-- Clause 3 of `Faithful` for the pool `C`, decidable by evaluation: no recycling filter of a
Trainer or of an "as often as you like" Ability of `C` (`Card.freeRec`) admits a card of `C` that is
a non-Supporter writer of a bonus or reduction (`Card.wAmt`), and no recycling filter of any effect
of `C`, attacks and Abilities included (`Card.allRec`), admits a card of `C` that writes a
rest-of-game bonus or reduction (`Card.alAmt`). -/
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
    c.attacksWf = true ∧ c.trainerOk = true ∧ c.loopFree = true ∧ c.gxOk = true ∧
      c.abilitiesOk = true ∧ c.abilitySafe = true := by
  simp only [Card.importOk, Bool.and_eq_true] at h
  exact ⟨h.1.1.1.1.1, h.1.1.1.1.2, h.1.1.2, h.1.2, h.1.1.1.2, h.2⟩

theorem attacks_wf_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ p, c = .pokemon p → ∀ a ∈ p.attacks, a.wf = true := by
  intro c hc p hp a ha
  have := (importOk_parts (List.all_eq_true.1 h c hc)).1
  subst hp
  exact List.all_eq_true.1 this a ha

theorem trainers_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ n k e, c = .trainer n k e → e.hitFree = true ∧ e.benchHitFree = true := by
  intro c hc n k e he
  have := (importOk_parts (List.all_eq_true.1 h c hc)).2.1
  subst he
  simpa only [Card.trainerOk, Bool.and_eq_true] using this

theorem loopFree_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, c.loopFree = true :=
  fun c hc => (importOk_parts (List.all_eq_true.1 h c hc)).2.2.1

theorem gxOnly_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ p, Card.pokemon p ∈ C → ∀ atk ∈ p.attacks, atk.gx = false → atk.effect.amtAt .always = 0 := by
  intro p hp atk ha hgx
  have := (importOk_parts (List.all_eq_true.1 h _ hp)).2.2.2.1
  have h2 := List.all_eq_true.1 this atk ha
  rw [hgx, Bool.false_or] at h2
  exact Nat.eq_of_beq_eq_true h2

/-- Clause 4 for every card of a checked pool. -/
theorem abilitySafe_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, c.abilitySafe = true :=
  fun c hc => (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.2.2

/-- Every script of every Ability of a card of a checked pool has no attack damage, on the Active
Pokémon or the Bench (the premises `hnd` and `hbh` of `Move.ability` and `Move.onPlay`). -/
theorem abilities_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ p, Card.pokemon p ∈ C → ∀ ab ∈ p.abilities, ∀ e ∈ ab.scripts,
      e.hitFree = true ∧ e.benchHitFree = true := by
  intro p hp ab hab e he
  have := (importOk_parts (List.all_eq_true.1 h _ hp)).2.2.2.2.1
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
  | .trainer _ _ _ => 2

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
`RecycleSafe` and `AbilitySafe`. -/
theorem faithful_of {C : List Card} (h : C.all Card.importOk = true) (hr : recSafeB C = true)
    (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ C) : g.Faithful :=
  ⟨fun x hx => loopFree_of h x (hg x hx),
   fun p hp atk ha hgx => gxOnly_of h p (hg _ hp) atk ha hgx,
   recycleSafe_of hr g hg,
   fun x hx => abilitySafe_of h x (hg x hx)⟩

end PokemonCards
