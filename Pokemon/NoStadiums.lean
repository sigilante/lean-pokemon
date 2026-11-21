import Pokemon.NoAbilities

/-!
# Decks without Stadiums (milestone M5)

Milestone M5 changed `Faithful` in three places that matter only for Stadium cards: clause 5
(`StadiumSafe`) is new; clause 3 (`RecycleSafe`) no longer counts a Stadium as a writer that may
not be recycled, nor a Stadium's effect as a free recycler (`Card.wAmt`, `Card.alAmt`,
`Card.freeRec`); and the store bound has a Stadium term (`cardsStQ`). For a game in which no card
is a Stadium, these lemmas show that each change is void: clause 5 holds, clause 3 is the clause
of milestone M8a word for word (`RecycleSafeM8a`, its definitions copied from milestone M8a), the
Stadium term is 0, and the hypothesis `StadiumQuiet` that `reach_boundedStores_noRecycle` gained
holds. Tools change nothing here: a Tool's grant enters the clauses only through `Card.attacks` and
`Card.abilities`, and a Tool with an empty grant (`ToolGrant.none`) adds no attack and no Ability.
-/

namespace Pokemon

/-- Is the card a Stadium? -/
def Card.isStadium : Card → Bool
  | .trainer _ .stadium _ => true
  | _ => false

/-- No card of the game is a Stadium. -/
def GameState.NoStadiums (g : GameState) : Prop := ∀ x ∈ g.allCards, x.isStadium = false

theorem GameState.NoStadiums.of_perm {g g' : GameState} (h : g.NoStadiums)
    (hp : g'.allCards.Perm g.allCards) : g'.NoStadiums :=
  fun x hx => h x (hp.mem_iff.1 hx)

/-- Without Stadiums, clause 5 of `Faithful` (`StadiumSafe`) holds. -/
theorem GameState.NoStadiums.safe {g : GameState} (h : g.NoStadiums) : g.StadiumSafe := by
  intro x hx
  have := h x hx
  cases x with
  | trainer n k e => cases k <;> first | rfl | cases this
  | _ => rfl

/-- Without Stadiums, `StadiumQuiet` holds. -/
theorem GameState.NoStadiums.quiet {g : GameState} (h : g.NoStadiums) : g.StadiumQuiet :=
  fun _ _ hx => by have := h _ hx; simp [Card.isStadium] at this

/-- Without Stadiums, the Stadium weight of a list of cards is 0. -/
theorem cardsStQ_zero (P : Nat) : ∀ C : List Card, (∀ x ∈ C, x.isStadium = false) →
    cardsStQ P C = 0
  | [], _ => rfl
  | c :: cs, h => by
      have ih := cardsStQ_zero P cs (fun x hx => h x (.tail _ hx))
      have hc := h c (.head _)
      have e : c.stQ P = 0 := by
        cases c with
        | trainer n k e => cases k <;> first | rfl | cases hc
        | _ => rfl
      simp [cardsStQ, e, ih]

/-! ## Clause 3 as it was before milestone M5 -/

/-- `Card.freeRec` of milestone M8a. -/
def Card.freeRecM8a : Card → List Filter
  | .trainer _ _ e => e.recFilters
  | .pokemon p => unlimitedRec p.abilities
  | .tool _ gr => unlimitedRec gr.abilities
  | _ => []

/-- `Card.wAmt` of milestone M8a. -/
def Card.wAmtM8a : Card → Nat
  | .trainer _ k e => if k = .supporter then 0 else e.amt
  | _ => 0

/-- `Card.alAmt` of milestone M8a. -/
def Card.alAmtM8a : Card → Nat
  | .trainer _ _ e => e.amtAt .always
  | _ => 0

/-- `GameState.RecycleSafe` of milestone M8a. -/
def GameState.RecycleSafeM8a (g : GameState) : Prop :=
  (∀ x ∈ g.allCards, ∀ f ∈ x.freeRecM8a, ∀ y ∈ g.allCards, f.eval y = true → y.wAmtM8a = 0) ∧
  (∀ x ∈ g.allCards, ∀ f ∈ x.allRec, ∀ y ∈ g.allCards, f.eval y = true → y.alAmtM8a = 0)

theorem Card.freeRec_eq {x : Card} (h : x.isStadium = false) : x.freeRec = x.freeRecM8a := by
  cases x with
  | trainer n k e => cases k <;> first | rfl | cases h
  | _ => rfl

theorem Card.wAmt_eq {x : Card} (h : x.isStadium = false) : x.wAmt = x.wAmtM8a := by
  cases x with
  | trainer n k e => cases k <;> first | rfl | cases h
  | _ => rfl

theorem Card.alAmt_eq {x : Card} (h : x.isStadium = false) : x.alAmt = x.alAmtM8a := by
  cases x with
  | trainer n k e => cases k <;> first | rfl | cases h
  | _ => rfl

/-- **Without Stadiums, clause 3 is the clause of milestone M8a.** -/
theorem GameState.NoStadiums.recycleSafe_iff {g : GameState} (h : g.NoStadiums) :
    g.RecycleSafe ↔ g.RecycleSafeM8a := by
  constructor
  · intro ⟨h1, h2⟩
    refine ⟨fun x hx f hf y hy hfy => ?_, fun x hx f hf y hy hfy => ?_⟩
    · rw [← Card.wAmt_eq (h y hy)]
      exact h1 x hx f (by rw [Card.freeRec_eq (h x hx)]; exact hf) y hy hfy
    · rw [← Card.alAmt_eq (h y hy)]
      exact h2 x hx f hf y hy hfy
  · intro ⟨h1, h2⟩
    refine ⟨fun x hx f hf y hy hfy => ?_, fun x hx f hf y hy hfy => ?_⟩
    · rw [Card.wAmt_eq (h y hy)]
      exact h1 x hx f (by rw [← Card.freeRec_eq (h x hx)]; exact hf) y hy hfy
    · rw [Card.alAmt_eq (h y hy)]
      exact h2 x hx f hf y hy hfy

/-- **Without Stadiums, `Faithful` is the four-clause condition of milestone M8a**, its clause 3
word for word. -/
theorem GameState.NoStadiums.faithful_iff {g : GameState} (h : g.NoStadiums) :
    g.Faithful ↔ g.LoopFree ∧ g.GXOnly ∧ g.RecycleSafeM8a ∧ g.AbilitySafe :=
  ⟨fun ⟨a, b, c, d, _⟩ => ⟨a, b, h.recycleSafe_iff.1 c, d⟩,
    fun ⟨a, b, c, d⟩ => ⟨a, b, h.recycleSafe_iff.2 c, d, h.safe⟩⟩

/-- **Without Stadiums, the store bound is the bound of milestone M8a.** -/
theorem GameState.NoStadiums.storeBound {g : GameState} (h : g.NoStadiums) :
    Faithful.storeBound g =
      g.storeTotal + 6 * cardsAmt g.allCards +
        3 * (cardsAbQ (cardsAmt g.allCards) g.allCards * potBound g.allCards.length) +
        3 * cardsAtkAmt g.allCards := by
  simp [Faithful.storeBound, cardsStQ_zero _ _ h]

/-- **Without Abilities and Stadiums, the store bound is the bound of milestone MV.** -/
theorem GameState.NoStadiums.storeBound_noAbilities {g : GameState} (h : g.NoStadiums)
    (ha : g.NoAbilities) :
    Faithful.storeBound g = g.storeTotal + 6 * cardsAmt g.allCards + 3 * cardsAtkAmt g.allCards := by
  simp [Faithful.storeBound, cardsStQ_zero _ _ h, cardsAbQ_zero _ _ ha]

/-- Without Stadiums, the per-game bound `reach_boundedStores_noRecycle` has the hypotheses it had
before milestone M5. -/
theorem GameState.NoStadiums.reach_boundedStores_noRecycle {g₀ g : GameState}
    (hs : g₀.NoStadiums) (hL : g₀.LoopFree) (hG : g₀.GXOnly) (hN : g₀.NoRecycle)
    (hQ : g₀.AbilityQuiet) (h : Reach g₀ g) : g.BoundedStores (Faithful.storeBoundNR g₀) :=
  Faithful.reach_boundedStores_noRecycle hL hG hN hQ hs.quiet h

end Pokemon
