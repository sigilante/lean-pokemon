import Pokemon.Rules

/-!
# Conservation of cards, and where finiteness can fail

`Reach.cards_eq`: legal play never changes the NUMBER of cards in the game, for decks whose
text is expressible in `Effect`. This is weaker than "no tokens": `Card` is an infinite type,
so a fixed count does not bound which cards are present. The statement finiteness needs is
that the cards in the game are a permutation of the starting cards; that is not yet proved.

`counters_unbounded`: inside the resolution of a single effect (a statement about `Run`, not
`Reach`), damage on the opponent's Active Pokémon is unbounded. `DamageBounded` therefore
cannot be an invariant of all reachable states. A finiteness theorem for this model has to
cover the mid-turn states too, e.g. by clamping damage at HP and showing the clamp is a
bisimulation. None of that is proved here.
-/

namespace Pokemon

theorem InPlay.cardList_length (p : InPlay) : p.cardList.length = p.cards := by
  simp [InPlay.cardList, InPlay.cards] <;> omega

theorem benchCards_append (a b : List InPlay) :
    benchCards (a ++ b) = benchCards a + benchCards b := by
  induction a with
  | nil => simp [benchCards]
  | cons p ps ih => simp [benchCards, ih] <;> omega

theorem benchCards_unfresh (b : List InPlay) :
    benchCards (b.map InPlay.unfresh) = benchCards b := by
  induction b with
  | nil => rfl
  | cons p ps ih => simp [benchCards, ih, InPlay.unfresh, InPlay.cards]

theorem optCards_unfresh (o : Option InPlay) :
    optCards (o.map InPlay.unfresh) = optCards o := by
  cases o <;> rfl

theorem PlayerState.cards_unfresh (s : PlayerState) : s.unfresh.cards = s.cards := by
  simp [PlayerState.unfresh, PlayerState.cards, benchCards_unfresh, optCards_unfresh]

/-- Resolving an effect never changes the number of cards in the game. -/
theorem Run.cards_eq {e : Effect} {g g' : GameState} (h : Run e g g') :
    g'.cards = g.cards := by
  induction h with
  | skip => rfl
  | draw h => simp [GameState.cards, PlayerState.cards, h] <;> omega
  | drawEmpty => rfl
  | heal n h => simp [GameState.cards, PlayerState.cards, optCards, InPlay.cards, h]
  | counters n h => simp [GameState.cards, PlayerState.cards, optCards, InPlay.cards, h]
  | shuffle h =>
      have := h.length_eq
      simp [GameState.cards, PlayerState.cards] <;> omega
  | search h => simp [GameState.cards, PlayerState.cards, h] <;> omega
  | handToBottom h =>
      have := h.length_eq
      simp [GameState.cards, PlayerState.cards] <;> omega
  | seq _ _ ih₁ ih₂ => rw [ih₂, ih₁]
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => rfl
  | iterCons _ _ ih₁ ih₂ => rw [ih₂, ih₁]

/-- A legal move never changes the number of cards in the game. -/
theorem Move.cards_eq {g g' : GameState} (h : Move g g') : g'.cards = g.cards := by
  cases h with
  | playBasic hh hs hhp hb =>
      simp [GameState.cards, PlayerState.cards, benchCards_append, benchCards,
        InPlay.ofBasic, InPlay.cards, hh] <;> omega
  | attach hh hf ha =>
      simp [GameState.cards, PlayerState.cards, optCards, InPlay.cards, hh, ha] <;> omega
  | evolve hh ha he hfr hf =>
      simp [GameState.cards, PlayerState.cards, optCards, InPlay.cards, hh, ha] <;> omega
  | retreat ha hb hr he hp hk =>
      simp [GameState.cards, PlayerState.cards, optCards, InPlay.cards, benchCards_append,
        benchCards, ha, hb, he] <;> omega
  | item hh hr =>
      rw [hr.cards_eq]
      simp [GameState.cards, PlayerState.cards, hh] <;> omega
  | supporter hh hs hr =>
      rw [hr.cards_eq]
      simp [GameState.cards, PlayerState.cards, hh] <;> omega
  | attack ha hm hc hn hf hr =>
      have := hr.cards_eq
      simpa [GameState.cards] using this
  | knockOut ha hk hp =>
      simp [GameState.cards, PlayerState.cards, optCards, InPlay.cardList_length, ha, hp]
        <;> omega
  | promote ha hb =>
      simp [GameState.cards, PlayerState.cards, optCards, benchCards_append, benchCards,
        ha, hb] <;> omega
  | noPokemon ha hb => rfl
  | knockOutOwn ha hk hp =>
      simp [GameState.cards, PlayerState.cards, optCards, InPlay.cardList_length, ha, hp]
        <;> omega
  | promoteOwn ha hb =>
      simp [GameState.cards, PlayerState.cards, optCards, benchCards_append, benchCards,
        ha, hb] <;> omega
  | noPokemonOwn ha hb => rfl
  | endTurn ha hb hk hd =>
      have := g.cur.cards_unfresh
      simp [GameState.cards, this]
      simp [PlayerState.cards, hd] <;> omega
  | deckOut ha hb hk hd => rfl

/-- Legal play never changes the number of cards in the game. -/
theorem Reach.cards_eq {g₀ g : GameState} (h : Reach g₀ g) : g.cards = g₀.cards := by
  induction h with
  | refl => rfl
  | step _ _ hm ih => rw [hm.cards_eq, ih]

/-- Inside one effect, damage on the opponent's Active Pokémon can reach any value:
"flip until tails, one counter per heads" is `iter (counters 1)`. -/
theorem counters_unbounded (n : Nat) :
    ∀ (g : GameState) (p : InPlay), g.opp.active = some p →
      ∃ g' p', Run (.iter (.counters 1)) g g' ∧ g'.opp.active = some p' ∧
        p'.damage = p.damage + n := by
  induction n with
  | zero => intro g p h; exact ⟨g, p, .iterNil _ _, h, rfl⟩
  | succ n ih =>
      intro g p h
      obtain ⟨g', p', hr, hp', hd⟩ :=
        ih { g with opp := { g.opp with active := some { p with damage := p.damage + 1 } } }
          { p with damage := p.damage + 1 } rfl
      exact ⟨g', p', .iterCons (.counters 1 h) hr, hp', by simp at hd; omega⟩

end Pokemon
