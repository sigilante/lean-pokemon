import Pokemon.Rules
import Pokemon.ListPerm

/-!
# Conservation of cards, and where finiteness can fail

`Run.perm`, `Move.perm`, `Reach.perm`: legal play permutes the cards in the game. The list
`GameState.allCards` of every physical card in every zone of a reachable state is a
permutation of that list for the start state, for decks whose text is expressible in
`Effect`. No card is created, destroyed or altered. `Reach.cards_eq` (the NUMBER of cards is
constant) is a corollary.

`counters_unbounded`: inside the resolution of a single effect (a statement about `Run`, not
`Reach`), damage on the opponent's Active Pokémon is unbounded. `DamageBounded` therefore
cannot be an invariant of all reachable states; `Damage` treats this with a clamp.
-/

namespace Pokemon

theorem InPlay.cardList_length (p : InPlay) : p.cardList.length = p.cards := by
  simp [InPlay.cardList, InPlay.cards] <;> omega

theorem optCardList_unfresh (o : Option InPlay) :
    optCardList (o.map InPlay.unfresh) = optCardList o := by
  cases o <;> rfl

theorem benchCardList_unfresh (b : List InPlay) :
    benchCardList (b.map InPlay.unfresh) = benchCardList b := by
  induction b with
  | nil => rfl
  | cons p ps ih => simp only [List.map, benchCardList, ih]; rfl

theorem benchCardList_append (a b : List InPlay) :
    benchCardList (a ++ b) = benchCardList a ++ benchCardList b := by
  induction a with
  | nil => rfl
  | cons p ps ih => simp only [List.cons_append, benchCardList, ih, List.append_assoc]

/-- Close a goal `l₁.Perm l₂` by comparing counts after unfolding `allCards`. -/
macro "perm_count" "[" hs:Lean.Parser.Tactic.simpLemma,* "]" : tactic =>
  `(tactic| (
    refine ListPerm.perm_of_count fun x => ?_
    simp only [GameState.allCards, PlayerState.allCards, List.count_append, List.count_cons,
      List.count_nil, optCardList, benchCardList, benchCardList_append, InPlay.cardList,
      InPlay.ofBasic, stadiumCardList, $hs,*] <;>
    omega))

/-- Resolving an effect permutes the cards in the game: no card is created, destroyed or
changed. -/
theorem Run.perm {e : Effect} {g g' : GameState} (h : Run e g g') :
    g'.allCards.Perm g.allCards := by
  induction h with
  | skip => exact .refl _
  | draw h => perm_count [h]
  | drawEmpty => exact .refl _
  | heal n h => perm_count [h]
  | counters n h => perm_count [h]
  | shuffle h =>
      have := fun x => h.count_eq x
      perm_count [this]
  | search h => perm_count [h]
  | handToBottom h =>
      have := fun x => h.count_eq x
      perm_count [this]
  | seq _ _ ih₁ ih₂ => exact ih₂.trans ih₁
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact .refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₂.trans ih₁

/-- A legal move permutes the cards in the game. -/
theorem Move.perm {g g' : GameState} (h : Move g g') : g'.allCards.Perm g.allCards := by
  cases h with
  | playBasic hh hs hhp hb => perm_count [hh]
  | attach hh hf ha => perm_count [hh, ha]
  | evolve hh ha he hfr hf => perm_count [hh, ha]
  | retreat ha hb hr he hp hk => perm_count [ha, hb, he]
  | item hh hr =>
      refine hr.perm.trans ?_
      perm_count [hh]
  | supporter hh hs hr =>
      refine hr.perm.trans ?_
      perm_count [hh]
  | attack ha hm hc hn hf hr => exact hr.perm
  | knockOut ha hk hp => perm_count [ha, hp]
  | promote ha hb => perm_count [ha, hb]
  | noPokemon ha hb => exact .refl _
  | knockOutOwn ha hk hp => perm_count [ha, hp]
  | promoteOwn ha hb => perm_count [ha, hb]
  | noPokemonOwn ha hb => exact .refl _
  | endTurn ha hb hk hd =>
      simp only [GameState.allCards, PlayerState.allCards, PlayerState.unfresh,
        optCardList_unfresh, benchCardList_unfresh]
      perm_count [hd]
  | deckOut ha hb hk hd => exact .refl _

/-- Legal play permutes the cards in the game: every reachable state holds exactly the
starting cards, each with its starting multiplicity. -/
theorem Reach.perm {g₀ g : GameState} (h : Reach g₀ g) : g.allCards.Perm g₀.allCards := by
  induction h with
  | refl => exact .refl _
  | step _ _ hm ih => exact hm.perm.trans ih

theorem optCards_eq_length (o : Option InPlay) : optCards o = (optCardList o).length := by
  cases o <;> simp [optCards, optCardList, InPlay.cardList_length]

theorem benchCards_eq_length (b : List InPlay) : benchCards b = (benchCardList b).length := by
  induction b with
  | nil => rfl
  | cons p ps ih => simp [benchCards, benchCardList, ih, InPlay.cardList_length]

theorem GameState.cards_eq_length (g : GameState) : g.cards = g.allCards.length := by
  cases hc : g.cur.stadium <;> cases ho : g.opp.stadium <;>
    simp [GameState.cards, GameState.allCards, PlayerState.cards, PlayerState.allCards,
      optCards_eq_length, benchCards_eq_length, stadiumCards, stadiumCardList, hc, ho] <;> omega

/-- Corollary of `Reach.perm`: legal play never changes the number of cards in the game. -/
theorem Reach.cards_eq {g₀ g : GameState} (h : Reach g₀ g) : g.cards = g₀.cards := by
  rw [GameState.cards_eq_length, GameState.cards_eq_length, h.perm.length_eq]

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
