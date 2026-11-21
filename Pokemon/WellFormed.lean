import Pokemon.Conservation

/-!
# Well-formed states, and no deadlock

`WellFormed` (defined in `Rules`) asks that both players have Prize cards while there is no
winner, and that every Benched Pokémon is below its HP and has no Special Condition.

* `Move.wellFormed`, `Reach.wellFormed`: legal play preserves it.
* `Move.progress`, `Reach.progress`: from a well-formed state with no winner some move is
  legal. In particular a pending Knock Out can always be taken: the player who takes the Prize
  has one, and the Pokémon that must be promoted afterwards is on the Bench or the game is won.
* `Move.knockOut_of_pending`, `Reach.knockOut_of_pending`: with no winner and a pending Knock
  Out (as after Checkup), a move that Knocks Out an Active Pokémon and takes a Prize is legal.
-/

namespace Pokemon

/-- A Pokémon with its markers removed. -/
def InPlay.unmarked (p : InPlay) : InPlay := { p with marks := Marks.empty }

/-- What resolving an effect never changes: the Benches except for markers, the Prizes, the
winner, who is first, and the phase of the turn. -/
def Run.Frame (g g' : GameState) : Prop :=
  g'.cur.bench.map InPlay.unmarked = g.cur.bench.map InPlay.unmarked ∧
    g'.opp.bench.map InPlay.unmarked = g.opp.bench.map InPlay.unmarked ∧
    g'.cur.prizes = g.cur.prizes ∧ g'.opp.prizes = g.opp.prizes ∧
    g'.winner = g.winner ∧ g'.curIsFirst = g.curIsFirst ∧ g'.between = g.between

theorem Run.frame {e : Effect} {g g' : GameState} (h : Run e g g') : Run.Frame g g' := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ =>
      obtain ⟨a1, a2, a3, a4, a5, a6, a7⟩ := ih₁
      obtain ⟨b1, b2, b3, b4, b5, b6, b7⟩ := ih₂
      exact ⟨b1.trans a1, b2.trans a2, b3.trans a3, b4.trans a4, b5.trans a5, b6.trans a6,
        b7.trans a7⟩
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterCons _ _ ih₁ ih₂ =>
      obtain ⟨a1, a2, a3, a4, a5, a6, a7⟩ := ih₁
      obtain ⟨b1, b2, b3, b4, b5, b6, b7⟩ := ih₂
      exact ⟨b1.trans a1, b2.trans a2, b3.trans a3, b4.trans a4, b5.trans a5, b6.trans a6,
        b7.trans a7⟩
  | @touchActive e w f g p he h => cases w <;> exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  | @touchBench e w f g q b₁ b₂ he h =>
      cases w <;> simp only [GameState.side] at h <;>
        exact ⟨by simp [GameState.updSide, h, InPlay.unmarked, InPlay.setMarks],
          by simp [GameState.updSide, h, InPlay.unmarked, InPlay.setMarks], rfl, rfl, rfl, rfl,
          rfl⟩
  | unmark w m g =>
      cases w <;>
        exact ⟨by simp [GameState.updSide, PlayerState.unmark, InPlay.unmarked, InPlay.setMarks],
          by simp [GameState.updSide, PlayerState.unmark, InPlay.unmarked, InPlay.setMarks],
          rfl, rfl, rfl, rfl, rfl⟩
  | _ => exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- Markers do not matter to `Benched`. -/
theorem benched_of_map {b b' : List InPlay}
    (h : b'.map InPlay.unmarked = b.map InPlay.unmarked) (hb : ∀ p ∈ b, Benched p) :
    ∀ p ∈ b', Benched p := by
  intro p hp
  have hm : p.unmarked ∈ b.map InPlay.unmarked := h ▸ List.mem_map_of_mem hp
  obtain ⟨q, hq, e⟩ := List.mem_map.1 hm
  obtain ⟨h1, h2, h3, h4, h5⟩ := hb q hq
  have ed : q.damage = p.damage := by
    have := congrArg InPlay.damage e; exact this
  have et : q.top = p.top := by
    have := congrArg InPlay.top e; exact this
  have er : q.rot = p.rot := by
    have := congrArg InPlay.rot e; exact this
  have ep : q.poisoned = p.poisoned := by
    have := congrArg InPlay.poisoned e; exact this
  have eb : q.burned = p.burned := by
    have := congrArg InPlay.burned e; exact this
  have eu : q.poisonUp = p.poisonUp := by
    have := congrArg InPlay.poisonUp e; exact this
  exact ⟨ed ▸ et ▸ h1, er ▸ h2, ep ▸ h3, eb ▸ h4, eu ▸ h5⟩

theorem WellFormed.of_frame {g g' : GameState} (hw : WellFormed g) (hf : Run.Frame g g') :
    WellFormed g' := by
  obtain ⟨f1, f2, f3, f4, f5, _, _⟩ := hf
  refine ⟨fun hn => ?_, ?_, ?_⟩
  · rw [f3, f4]; exact hw.1 (f5 ▸ hn)
  · exact benched_of_map f1 hw.2.1
  · exact benched_of_map f2 hw.2.2

theorem mem_append_cons_of_mem {α : Type} {x : α} {b₁ b₂ : List α} (y : α)
    (h : x ∈ b₁ ++ b₂) : x ∈ b₁ ++ y :: b₂ := by
  rcases List.mem_append.1 h with h | h
  · exact List.mem_append_left _ h
  · exact List.mem_append_right _ (.tail _ h)

/-- A Knock Out move preserves well-formedness. -/
theorem KOMove.wellFormed {g g' : GameState} (h : KOMove g g') (hw : WellFormed g) :
    WellFormed g' := by
  cases h with
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

theorem Resolve.wellFormed {g g' : GameState} (h : Resolve g g') (hw : WellFormed g) :
    WellFormed g' := by
  induction h with
  | done => exact hw
  | step _ hm _ ih => exact ih (hm.wellFormed hw)

/-- Resolving a Trainer card's effect, Knock Outs included, preserves well-formedness. -/
theorem TRun.wellFormed {e : Effect} {g g' : GameState} (h : TRun e g g') (hw : WellFormed g) :
    WellFormed g' := by
  induction h with
  | prim _ _ hr hk => exact hk.wellFormed (WellFormed.of_frame hw hr.frame)
  | stop => exact hw
  | iteT _ _ _ _ ih => exact ih hw
  | iteF _ _ _ _ ih => exact ih hw
  | seq _ _ ih₁ ih₂ => exact ih₂ (ih₁ hw)
  | choiceL _ ih => exact ih hw
  | choiceR _ ih => exact ih hw
  | iterNil => exact hw
  | iterCons _ _ ih₁ ih₂ => exact ih₂ (ih₁ hw)

/-- Taking the Knock Outs ends in a `Settled` state or a finished game. -/
theorem Resolve.settled_or_won {g g' : GameState} (h : Resolve g g') :
    Settled g' ∨ g'.winner ≠ none := by
  induction h with
  | done h => exact h
  | step _ _ _ ih => exact ih

/-- **Trainer effects end settled.** A Trainer card's effect, resolved from a state that is
`Settled` or finished, ends in a state that is `Settled` or finished: no Knock Out is left
pending by it. -/
theorem TRun.settled_or_won {e : Effect} {g g' : GameState} (h : TRun e g g')
    (hs : Settled g ∨ g.winner ≠ none) : Settled g' ∨ g'.winner ≠ none := by
  induction h with
  | prim _ _ _ hk => exact hk.settled_or_won
  | stop hn => exact .inr hn
  | iteT _ _ _ _ ih => exact ih hs
  | iteF _ _ _ _ ih => exact ih hs
  | seq _ _ ih₁ ih₂ => exact ih₂ (ih₁ hs)
  | choiceL _ ih => exact ih hs
  | choiceR _ ih => exact ih hs
  | iterNil => exact hs
  | iterCons _ _ ih₁ ih₂ => exact ih₂ (ih₁ hs)

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
  | retreat ha hb hr he hp hs hbt hst =>
      rename_i a q b₁ b₂ _ _
      have hk : a.damage < a.top.hp := hst.1 a (Or.inl ha)
      refine ⟨hw.1, fun p hp => ?_, hw.2.2⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p (by rw [hb]; exact List.mem_append_left _ hp)
      · cases hp with
        | head => exact ⟨hk, rfl, rfl, rfl, rfl⟩
        | tail _ hp =>
            exact hw.2.1 p (by rw [hb]; exact List.mem_append_right _ (.tail _ hp))
  | item hh hbt hst hr => exact hr.wellFormed hw
  | supporter hh hs hbt hst hr => exact hr.wellFormed hw
  | attack ha hm hc hs hn hf hbt hst hr => exact WellFormed.of_frame hw hr.frame
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
  | endTurn fa sa ca fb sb cb ha hb hk hbt =>
      refine ⟨fun hn => ⟨(hw.1 hn).2, (hw.1 hn).1⟩, hw.2.2, fun p hp => ?_⟩
      obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
      exact hw.2.1 q hq
  | startTurn hbt ha hb hk hd => exact hw
  | deckOut hbt ha hb hk hd => exact ⟨fun hn => by simp at hn, hw.2.1, hw.2.2⟩

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
      match hbt : g.between with
      | false => exact ⟨_, .endTurn false false false false false false ho hc hk hbt⟩
      | true =>
          match hd : g.cur.deck with
          | [] => exact ⟨_, .deckOut hbt ho hc hk hd⟩
          | c :: d => exact ⟨_, .startTurn hbt ho hc hk hd⟩
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

/-- An Active spot is empty, holds a Pokémon below its HP, or holds one at or above its HP. -/
theorem active_split (o : Option InPlay) :
    (∃ a, o = some a ∧ a.top.hp ≤ a.damage) ∨ ∀ a, o = some a → a.damage < a.top.hp := by
  cases o with
  | none => exact .inr fun _ h => by cases h
  | some a =>
      rcases Nat.lt_or_ge a.damage a.top.hp with h | h
      · exact .inr fun a' h' => by cases h'; exact h
      · exact .inl ⟨a, rfl, h⟩

/-- **A pending Knock Out can be taken.** In a well-formed state with no winner and a pending
Knock Out (for instance between turns, after Checkup), some move Knocks Out an Active
Pokémon: it takes one Prize card. -/
theorem Move.knockOut_of_pending {g : GameState} (hw : WellFormed g) (hn : g.winner = none)
    (hk : ¬ DamageBounded g) :
    ∃ g', Move g g' ∧
      g'.cur.prizes.length + g'.opp.prizes.length + 1 =
        g.cur.prizes.length + g.opp.prizes.length := by
  have hopp : ∀ a, g.opp.active = some a → a.top.hp ≤ a.damage → ∃ g', Move g g' ∧
      g'.cur.prizes.length + g'.opp.prizes.length + 1 =
        g.cur.prizes.length + g.opp.prizes.length := by
    intro a ho hka
    match hp : g.cur.prizes with
    | [] => exact absurd hp (hw.1 hn).1
    | c :: ps => exact ⟨_, .knockOut ho hka hp, by simp; omega⟩
  have hcur : ∀ b, g.cur.active = some b → b.top.hp ≤ b.damage → ∃ g', Move g g' ∧
      g'.cur.prizes.length + g'.opp.prizes.length + 1 =
        g.cur.prizes.length + g.opp.prizes.length := by
    intro b hc hkb
    match hp : g.opp.prizes with
    | [] => exact absurd hp (hw.1 hn).2
    | c :: ps => exact ⟨_, .knockOutOwn hc hkb hp, by simp; omega⟩
  rcases active_split g.opp.active with ⟨a, ho, hka⟩ | hoa
  · exact hopp a ho hka
  rcases active_split g.cur.active with ⟨b, hc, hkb⟩ | hca
  · exact hcur b hc hkb
  refine absurd (fun p hp => ?_) hk
  rcases hp with hp | hp | hp | hp
  · exact hca p hp
  · exact (hw.2.1 p hp).1
  · exact hoa p hp
  · exact (hw.2.2 p hp).1

/-- **A pending Knock Out can be taken**, for play: from a well-formed start, every reachable
state with no winner and a pending Knock Out has a move that Knocks Out an Active Pokémon. -/
theorem Reach.knockOut_of_pending {g₀ g : GameState} (h₀ : WellFormed g₀) (h : Reach g₀ g)
    (hn : g.winner = none) (hk : ¬ DamageBounded g) :
    ∃ g', Move g g' ∧
      g'.cur.prizes.length + g'.opp.prizes.length + 1 =
        g.cur.prizes.length + g.opp.prizes.length :=
  Move.knockOut_of_pending (h.wellFormed h₀) hn hk

end Pokemon
