import Pokemon.Faithful

/-!
# Decks without Abilities

For a game in which no Pokémon card has an Ability, the Ability clauses of `Faithful` hold
trivially, the Ability term of the store bound vanishes, and `Faithful` is the three-clause
condition it was before Abilities entered the model. These lemmas make that explicit, so that
the results for such decks are visibly as strong as they were.
-/

namespace Pokemon

/-- No Pokémon card of the game has an Ability. -/
def GameState.NoAbilities (g : GameState) : Prop :=
  ∀ p : PokemonCard, Card.pokemon p ∈ g.allCards → p.abilities = []

/-- Without Abilities, `AbilityQuiet` holds. -/
theorem GameState.NoAbilities.quiet {g : GameState} (h : g.NoAbilities) : g.AbilityQuiet := by
  intro p hp ab hab; rw [h p hp] at hab; nomatch hab

/-- Without Abilities, clause 4 of `Faithful` (`AbilitySafe`) holds. -/
theorem GameState.NoAbilities.safe {g : GameState} (h : g.NoAbilities) : g.AbilitySafe := by
  intro x hx
  cases x with
  | pokemon p => simp [Card.abilitySafe, h p hx]
  | _ => rfl

/-- Without Abilities, the Ability weight of a list of cards is 0. -/
theorem cardsAbQ_zero (P : Nat) : ∀ C : List Card,
    (∀ p : PokemonCard, Card.pokemon p ∈ C → p.abilities = []) → cardsAbQ P C = 0
  | [], _ => rfl
  | c :: cs, h => by
      have ih := cardsAbQ_zero P cs (fun p hp => h p (.tail _ hp))
      cases c with
      | pokemon p => simp [cardsAbQ, Card.abQ, h p (.head _), abilitiesQ, ih]
      | _ => simp [cardsAbQ, Card.abQ, ih]

/-- Without Abilities, the store bound is the bound of the model before Abilities. -/
theorem GameState.NoAbilities.storeBound {g : GameState} (h : g.NoAbilities) :
    Faithful.storeBound g =
      g.storeTotal + 6 * cardsAmt g.allCards + 3 * cardsAtkAmt g.allCards := by
  simp [Faithful.storeBound, cardsAbQ_zero _ _ h]

/-- Without Abilities, `Faithful` is its first three clauses. -/
theorem GameState.NoAbilities.faithful_iff {g : GameState} (h : g.NoAbilities) :
    g.Faithful ↔ g.LoopFree ∧ g.GXOnly ∧ g.RecycleSafe :=
  ⟨fun ⟨a, b, c, _⟩ => ⟨a, b, c⟩, fun ⟨a, b, c⟩ => ⟨a, b, c, h.safe⟩⟩

end Pokemon
