import Pokemon.StoreSafe

/-!
# Decks without Abilities

For a game in which no Pokémon card has an Ability, the Ability clauses of `StoreSafe` hold
trivially, the Ability term of the store bound vanishes, and `StoreSafe` is the three-clause
condition it was before Abilities entered the model. These lemmas make that explicit, so that
the results for such decks are visibly as strong as they were.
-/

namespace Pokemon

/-- No card of the game has an Ability, and (milestone M5) no Tool of the game gives one
(`Card.abilities`). -/
def GameState.NoAbilities (g : GameState) : Prop :=
  ∀ x ∈ g.allCards, x.abilities = []

/-- Without Abilities, `AbilityQuiet` holds. -/
theorem GameState.NoAbilities.quiet {g : GameState} (h : g.NoAbilities) : g.AbilityQuiet := by
  intro p hp ab hab
  have e : p.abilities = [] := h _ hp
  rw [e] at hab; nomatch hab

/-- Without Abilities, clause 4 of `StoreSafe` (`AbilitySafe`) holds. -/
theorem GameState.NoAbilities.safe {g : GameState} (h : g.NoAbilities) : g.AbilitySafe := by
  intro x hx
  cases x with
  | pokemon p =>
      have e : p.abilities = [] := h _ hx
      simp [Card.abilitySafe, e]
  | tool n gr =>
      have e : gr.abilities = [] := h _ hx
      simp [Card.abilitySafe, e]
  | energy t =>
      cases t with
      | basic => rfl
      | special m pr x =>
          have e : x.grant.abilities = [] := h _ hx
          simp [Card.abilitySafe, e]
  | _ => rfl

/-- Without Abilities, the Ability weight of a list of cards is 0. -/
theorem cardsAbQ_zero (P : Nat) : ∀ C : List Card, (∀ x ∈ C, x.abilities = []) → cardsAbQ P C = 0
  | [], _ => rfl
  | c :: cs, h => by
      have ih := cardsAbQ_zero P cs (fun x hx => h x (.tail _ hx))
      simp [cardsAbQ, Card.abQ, h c (.head _), abilitiesQ, ih]

/-- Without Abilities, the Ability term of the store bound vanishes: what is left is the bound of
the model before Abilities (milestone MV) and, since milestone M5, the Stadium term, which is 0
for a deck without Stadium cards (`GameState.NoStadiums.storeBound_noAbilities`). -/
theorem GameState.NoAbilities.storeBound {g : GameState} (h : g.NoAbilities) :
    StoreSafe.storeBound g =
      g.storeTotal + 6 * cardsAmt g.allCards + 6 * cardsStQ (cardsAmt g.allCards) g.allCards +
        3 * cardsAtkAmt g.allCards := by
  simp [StoreSafe.storeBound, cardsAbQ_zero _ _ h]

/-- Without Abilities, `StoreSafe` is its clauses other than clause 4 (milestone M5 added clause 5,
`StadiumSafe`; before it this lemma read "its first three clauses"). -/
theorem GameState.NoAbilities.storeSafe_iff {g : GameState} (h : g.NoAbilities) :
    g.StoreSafe ↔ g.LoopFree ∧ g.GXOnly ∧ g.RecycleSafe ∧ g.StadiumSafe :=
  ⟨fun ⟨a, b, c, _, d⟩ => ⟨a, b, c, d⟩, fun ⟨a, b, c, d⟩ => ⟨a, b, c, h.safe, d⟩⟩

end Pokemon
