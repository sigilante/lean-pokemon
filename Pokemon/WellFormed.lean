import Pokemon.Conservation

/-!
# Well-formed states, and no deadlock

`WellFormed` (defined in `Rules`) asks that both players have Prize cards while there is no
winner, and that every Benched Pokémon is below its HP and has no Special Condition.

* `Move.wellFormed`, `Reach.wellFormed`: legal play preserves it.
* `Move.progress`, `Reach.progress`: from a well-formed state with no winner some move is
  legal. In particular a pending Knock Out can always be taken: the player who takes the Prize
  has one, and the Pokémon that must be promoted afterwards is on the Bench or the game is won.
-/

namespace Pokemon

/-- What resolving an effect never changes. -/
def Run.Frame (g g' : GameState) : Prop :=
  g'.cur.bench = g.cur.bench ∧ g'.opp.bench = g.opp.bench ∧
    g'.cur.prizes = g.cur.prizes ∧ g'.opp.prizes = g.opp.prizes ∧
    g'.winner = g.winner ∧ g'.curIsFirst = g.curIsFirst

theorem Run.frame {e : Effect} {g g' : GameState} (h : Run e g g') : Run.Frame g g' := by
  induction h with
  | seq _ _ ih₁ ih₂ =>
      obtain ⟨a1, a2, a3, a4, a5, a6⟩ := ih₁
      obtain ⟨b1, b2, b3, b4, b5, b6⟩ := ih₂
      exact ⟨b1.trans a1, b2.trans a2, b3.trans a3, b4.trans a4, b5.trans a5, b6.trans a6⟩
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterCons _ _ ih₁ ih₂ =>
      obtain ⟨a1, a2, a3, a4, a5, a6⟩ := ih₁
      obtain ⟨b1, b2, b3, b4, b5, b6⟩ := ih₂
      exact ⟨b1.trans a1, b2.trans a2, b3.trans a3, b4.trans a4, b5.trans a5, b6.trans a6⟩
  | _ => exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem WellFormed.of_frame {g g' : GameState} (hw : WellFormed g) (hf : Run.Frame g g') :
    WellFormed g' := by
  obtain ⟨f1, f2, f3, f4, f5, _⟩ := hf
  refine ⟨fun hn => ?_, ?_, ?_⟩
  · rw [f3, f4]; exact hw.1 (f5 ▸ hn)
  · rw [f1]; exact hw.2.1
  · rw [f2]; exact hw.2.2

theorem mem_append_cons_of_mem {α : Type} {x : α} {b₁ b₂ : List α} (y : α)
    (h : x ∈ b₁ ++ b₂) : x ∈ b₁ ++ y :: b₂ := by
  rcases List.mem_append.1 h with h | h
  · exact List.mem_append_left _ h
  · exact List.mem_append_right _ (.tail _ h)

/-- Legal play preserves well-formedness. -/
theorem Move.wellFormed {g g' : GameState} (h : Move g g') (hw : WellFormed g) :
    WellFormed g' := by
  cases h with
  | playBasic hh hs hhp hb =>
      refine ⟨hw.1, fun p hp => ?_, hw.2.2⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p hp
      · rw [List.mem_singleton] at hp; subst hp
        exact ⟨hhp, rfl, rfl, rfl, rfl⟩
  | attach hh hf ha => exact hw
  | evolve hh ha he hfr hf => exact hw
  | retreat ha hb hr he hp hk hs =>
      rename_i a q b₁ b₂ _ _
      refine ⟨hw.1, fun p hp => ?_, hw.2.2⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p (by rw [hb]; exact List.mem_append_left _ hp)
      · cases hp with
        | head => exact ⟨hk, rfl, rfl, rfl, rfl⟩
        | tail _ hp =>
            exact hw.2.1 p (by rw [hb]; exact List.mem_append_right _ (.tail _ hp))
  | item hh hr => exact WellFormed.of_frame hw hr.frame
  | supporter hh hs hr => exact WellFormed.of_frame hw hr.frame
  | attack ha hm hc hs hn hf hr => exact WellFormed.of_frame hw hr.frame
  | attackConfused ha hm hc hs hn hf => exact hw
  | knockOut ha hk hp =>
      rename_i p c ps
      refine ⟨fun hn => ?_, hw.2.1, hw.2.2⟩
      cases ps with
      | nil => simp at hn
      | cons c' ps' =>
          simp only [List.isEmpty_cons, Bool.false_eq_true, ite_false] at hn
          exact ⟨List.cons_ne_nil _ _, (hw.1 hn).2⟩
  | promote ha hb =>
      refine ⟨hw.1, hw.2.1, fun p hp => hw.2.2 p ?_⟩
      rw [hb]; exact mem_append_cons_of_mem _ hp
  | noPokemon ha hb => exact ⟨fun hn => by simp at hn, hw.2.1, hw.2.2⟩
  | knockOutOwn ha hk hp =>
      rename_i p c ps
      refine ⟨fun hn => ?_, hw.2.1, hw.2.2⟩
      cases ps with
      | nil => simp at hn
      | cons c' ps' =>
          simp only [List.isEmpty_cons, Bool.false_eq_true, ite_false] at hn
          exact ⟨(hw.1 hn).1, List.cons_ne_nil _ _⟩
  | promoteOwn ha hb =>
      refine ⟨hw.1, fun p hp => hw.2.1 p ?_, hw.2.2⟩
      rw [hb]; exact mem_append_cons_of_mem _ hp
  | noPokemonOwn ha hb => exact ⟨fun hn => by simp at hn, hw.2.1, hw.2.2⟩
  | endTurn ha hb hk hd =>
      refine ⟨fun hn => ⟨(hw.1 hn).2, (hw.1 hn).1⟩, hw.2.2, fun p hp => ?_⟩
      obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
      exact hw.2.1 q hq
  | deckOut ha hb hk hd => exact ⟨fun hn => by simp at hn, hw.2.1, hw.2.2⟩

/-- Legal play from a well-formed state stays well formed. -/
theorem Reach.wellFormed {g₀ g : GameState} (h₀ : WellFormed g₀) (h : Reach g₀ g) :
    WellFormed g := by
  induction h with
  | refl => exact h₀
  | step _ _ hm ih => exact hm.wellFormed ih

/-- **No deadlock.** In a well-formed state with no winner, some move is legal. -/
theorem Move.progress {g : GameState} (hw : WellFormed g) (hn : g.winner = none) :
    ∃ g', Move g g' := by
  match ho : g.opp.active with
  | none =>
      match hb : g.opp.bench with
      | [] => exact ⟨_, .noPokemon ho hb⟩
      | q :: qs => exact ⟨_, .promote (b₁ := []) ho hb⟩
  | some a =>
  match hc : g.cur.active with
  | none =>
      match hb : g.cur.bench with
      | [] => exact ⟨_, .noPokemonOwn hc hb⟩
      | q :: qs => exact ⟨_, .promoteOwn (b₁ := []) hc hb⟩
  | some b =>
  rcases Nat.lt_or_ge a.damage a.top.hp with hka | hka
  · rcases Nat.lt_or_ge b.damage b.top.hp with hkb | hkb
    · have hk : DamageBounded g := by
        intro p hp
        rcases hp with hp | hp | hp | hp
        · rw [hc] at hp; cases hp; exact hkb
        · exact (hw.2.1 p hp).1
        · rw [ho] at hp; cases hp; exact hka
        · exact (hw.2.2 p hp).1
      match hd : g.opp.deck with
      | [] => exact ⟨_, .deckOut ho hc hk hd⟩
      | c :: d => exact ⟨_, .endTurn ho hc hk hd⟩
    · match hp : g.opp.prizes with
      | [] => exact absurd hp (hw.1 hn).2
      | c :: ps => exact ⟨_, .knockOutOwn hc hkb hp⟩
  · match hp : g.cur.prizes with
    | [] => exact absurd hp (hw.1 hn).1
    | c :: ps => exact ⟨_, .knockOut ho hka hp⟩

/-- **No deadlock**, for play: from a well-formed start, every reachable state with no winner
has a legal move. -/
theorem Reach.progress {g₀ g : GameState} (h₀ : WellFormed g₀) (h : Reach g₀ g)
    (hn : g.winner = none) : ∃ g', Move g g' :=
  Move.progress (h.wellFormed h₀) hn

end Pokemon
