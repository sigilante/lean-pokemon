import Pokemon.Conservation

/-!
# The owed-trigger marks (milestone MV7b, after review)

`GameState.noteBenched` marks each of the opponent's Pokémon that has an `oppBenched` trigger where
it is (`InPlay.owe`), and the resolution of the pending triggers fires the marked ones
(`GameState.owedTrigs`) and clears every mark (`GameState.unpend`). The review of stage 2 found
that nothing excluded a start state whose Pokémon already carry marks with no trigger pending: such
a mark fires at the next event as an owed trigger. `GameState.MarksOk` (in `Rules`, part of
`WellFormed`) says that no Pokémon of the player to move carries a mark and that the opponent's
carry none unless a trigger is pending. This file proves that every move keeps it:

* `Run.marks`: an effect's resolution keeps the mover's Pokémon unmarked, never clears the record,
  and marks the opponent's Pokémon only by raising the event, which sets the record; an effect of
  the trigger fragment (`Effect.trigOk`, no switch) changes neither the record nor any mark;
* `Fire.marks`, `KOBatch.marks`: triggers and the batch Knock Out step change no mark and keep the
  record;
* `Move.marksOk`, `Reach.marksOk`: legal play keeps `MarksOk`.
-/

namespace Pokemon

/-! ## Lists and options of Pokémon -/

theorem OptNoOwe.some_of {x : InPlay} (h : x.owe = none) : OptNoOwe (some x) := by
  intro p hp; cases hp; exact h

theorem OptNoOwe.some_eq {a : Option InPlay} {p x : InPlay} (h : OptNoOwe a) (ha : a = some p)
    (hx : x.owe = p.owe) : OptNoOwe (some x) :=
  OptNoOwe.some_of (hx.trans (h p ha))

theorem OptNoOwe.map_clear (a : Option InPlay) : OptNoOwe (a.map InPlay.clearOwe) := by
  cases a <;> intro p hp <;> cases hp <;> rfl

theorem OptNoOwe.none : OptNoOwe none := fun _ hp => nomatch hp

theorem OptNoOwe.map {a : Option InPlay} {f : InPlay → InPlay} (h : OptNoOwe a)
    (hf : ∀ p, (f p).owe = p.owe) : OptNoOwe (a.map f) := by
  cases a with
  | none => exact OptNoOwe.none
  | some p => exact OptNoOwe.some_of ((hf p).trans (h p rfl))

theorem ListNoOwe.mem {b b₁ b₂ : List InPlay} {q : InPlay} (hb : b = b₁ ++ q :: b₂)
    (h : ListNoOwe b) : q.owe = none :=
  h q (by rw [hb]; exact List.mem_append_right _ (.head _))

theorem ListNoOwe.upd {b b₁ b₂ : List InPlay} {q x : InPlay} (hb : b = b₁ ++ q :: b₂)
    (h : ListNoOwe b) (hx : x.owe = none) : ListNoOwe (b₁ ++ x :: b₂) := by
  intro p hp
  rcases List.mem_append.1 hp with hp | hp
  · exact h p (by rw [hb]; exact List.mem_append_left _ hp)
  · cases hp with
    | head => exact hx
    | tail _ hp => exact h p (by rw [hb]; exact List.mem_append_right _ (.tail _ hp))

/-- Replacing a Pokémon of a list by one with the same mark. -/
theorem ListNoOwe.upd' {b b₁ b₂ : List InPlay} {q x : InPlay} (hb : b = b₁ ++ q :: b₂)
    (h : ListNoOwe b) (hx : x.owe = q.owe) : ListNoOwe (b₁ ++ x :: b₂) :=
  h.upd hb (hx.trans (h.mem hb))

theorem ListNoOwe.map {b : List InPlay} {f : InPlay → InPlay} (h : ListNoOwe b)
    (hf : ∀ p, (f p).owe = p.owe) : ListNoOwe (b.map f) := by
  intro p hp
  obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
  exact (hf q).trans (h q hq)

theorem ListNoOwe.append {b c : List InPlay} (hb : ListNoOwe b) (hc : ListNoOwe c) :
    ListNoOwe (b ++ c) := by
  intro p hp
  rcases List.mem_append.1 hp with hp | hp
  · exact hb p hp
  · exact hc p hp

theorem ListNoOwe.sub {b c : List InPlay} (hb : ListNoOwe b) (hs : ∀ p ∈ c, p ∈ b) :
    ListNoOwe c := fun p hp => hb p (hs p hp)

theorem ListNoOwe.ofBasic (ps : List PokemonCard) : ListNoOwe (ps.map InPlay.ofBasic) := by
  intro p hp
  obtain ⟨q, _, rfl⟩ := List.mem_map.1 hp
  rfl

/-- The transformations of a Pokémon in play that the moves apply keep its mark. -/
theorem InPlay.inflict_owe (c : Condition) (p : InPlay) : (p.inflict c).owe = p.owe := by
  cases c <;> rfl

/-! ## Owed-trigger lemmas moved from `NoTriggers` -/

/-- A Pokémon with no `oppBenched` trigger where it is is not marked (milestone MV7b). -/
theorem InPlay.noteOwe_of_nil {sp : Spot} {p : InPlay} (h : p.trigs .oppBenched sp = []) :
    p.noteOwe sp = p := by
  unfold InPlay.noteOwe
  rw [h]
  rfl

/-- **With no trigger to record, raising the event changes nothing** (milestone MV7): the retreat
and the switch of the player's own Active Pokémon give the states they gave before MV7. -/
theorem GameState.noteBenched_of_nil {g : GameState} (h : g.benchedTrigs = []) :
    g.noteBenched = g := by
  have h1 : optTrigs .oppBenched g.opp.active = [] := (List.append_eq_nil_iff.1 h).1
  have h2 : g.opp.bench.flatMap (InPlay.trigs .oppBenched .bench) = [] :=
    (List.append_eq_nil_iff.1 h).2
  have ea : g.opp.active.map (InPlay.noteOwe .active) = g.opp.active := by
    cases ha : g.opp.active with
    | none => rfl
    | some p =>
        rw [ha] at h1
        simp only [Option.map_some, InPlay.noteOwe_of_nil (show p.trigs .oppBenched .active = [] from h1)]
  have eb : g.opp.bench.map (InPlay.noteOwe .bench) = g.opp.bench :=
    (List.map_congr_left fun p hp => InPlay.noteOwe_of_nil (List.flatMap_eq_nil_iff.1 h2 p hp)).trans
      (List.map_id _)
  unfold GameState.noteBenched
  rw [h, ea, eb]
  cases g; rename_i pend
  cases pend <;> rfl

/-! ## The invariant -/

theorem GameState.MarksOk.of_both {g : GameState} (hc : g.cur.NoMarks) (ho : g.opp.NoMarks) :
    g.MarksOk := ⟨hc, fun _ => ho⟩

/-- A step that keeps the record and keeps each side unmarked keeps `MarksOk`. -/
theorem GameState.MarksOk.of_keep {g g' : GameState} (hm : g.MarksOk) (hp : g'.pend = g.pend)
    (hc : g.cur.NoMarks → g'.cur.NoMarks) (ho : g.opp.NoMarks → g'.opp.NoMarks) : g'.MarksOk :=
  ⟨hc hm.1, fun h => ho (hm.2 (hp ▸ h))⟩

/-- Raising the event marks the opponent's Pokémon only when it sets the record. -/
theorem GameState.noteBenched_opp {g : GameState} (ho : g.pend = false → g.opp.NoMarks) :
    g.noteBenched.pend = false → g.noteBenched.opp.NoMarks := by
  intro hp
  have hp' : (g.pend || !g.benchedTrigs.isEmpty) = false := hp
  rw [Bool.or_eq_false_iff] at hp'
  have hn : g.benchedTrigs = [] := by
    have h2 := hp'.2
    simpa using h2
  rw [GameState.noteBenched_of_nil hn]
  exact ho hp'.1

/-- **Raising the event keeps `MarksOk`**: it marks only the opponent's Pokémon, and only those with
an `oppBenched` trigger, which sets the record. -/
theorem GameState.noteBenched_marksOk {g : GameState} (hc : g.cur.NoMarks)
    (ho : g.pend = false → g.opp.NoMarks) : g.noteBenched.MarksOk :=
  ⟨hc, GameState.noteBenched_opp ho⟩

theorem GameState.noteBenched_pend {g : GameState} (h : g.pend = true) : g.noteBenched.pend = true := by
  show (g.pend || _) = true
  rw [h, Bool.true_or]

/-- Clearing the record leaves no mark. -/
theorem GameState.unpend_marksOk {g : GameState} (hc : g.cur.NoMarks) : g.unpend.MarksOk :=
  .of_both hc ⟨OptNoOwe.map_clear _, fun p hp => by obtain ⟨q, _, rfl⟩ := List.mem_map.1 hp; rfl⟩

/-! ## One player's zones -/

theorem Deal.noOwe {tf : Filter} {t : List Card} {a a' : Option InPlay} {b b' : List InPlay}
    (h : Deal tf t a b a' b') (ha : OptNoOwe a) (hb : ListNoOwe b) : OptNoOwe a' ∧ ListNoOwe b' := by
  induction h with
  | nil => exact ⟨ha, hb⟩
  | active _ _ ih => exact ih (ha.some_eq rfl rfl) hb
  | bench _ _ ih => exact ih ha (hb.upd' rfl rfl)

theorem Put.noMarks {d : Dst} {t : List Card} {s s' : PlayerState} (h : Put d t s s')
    (hs : s.NoMarks) : s'.NoMarks := by
  cases h <;> exact hs

theorem Place.noMarks {i : Into} {t : List Card} {s s' : PlayerState} (h : Place i t s s')
    (hs : s.NoMarks) : s'.NoMarks := by
  cases h with
  | put hp => exact hp.noMarks hs
  | bench _ _ => exact ⟨hs.1, hs.2.append (ListNoOwe.ofBasic _)⟩
  | attach hd => exact hd.noOwe hs.1 hs.2

theorem Src.set_noMarks {src : Src} {r : List Card} {s : PlayerState} (hs : s.NoMarks) :
    (src.set r s).NoMarks := by
  cases src <;> exact hs

theorem ZStep.noMarks {e : Effect} {s s' : PlayerState} (h : ZStep e s s') (hs : s.NoMarks) :
    s'.NoMarks := by
  cases h with
  | move _ _ hp => exact hp.noMarks (Src.set_noMarks hs)
  | drawTo => exact hs
  | @attachActive w src f tf s r t a _ ha _ =>
      refine ⟨OptNoOwe.some_of (hs.1 a ha), ?_⟩
      show ListNoOwe (src.set r s).bench
      rw [Src.set_bench]; exact hs.2
  | @attachBench w src f tf s r t q b₁ b₂ _ hb _ =>
      refine ⟨?_, hs.2.upd' hb rfl⟩
      show OptNoOwe (src.set r s).active
      rw [Src.set_active]; exact hs.1
  | attachNone => exact hs
  | @putBench w src f s r p _ _ _ _ =>
      refine ⟨?_, hs.2.append (ListNoOwe.ofBasic [p])⟩
      show OptNoOwe (src.set r s).active
      rw [Src.set_active]; exact hs.1
  | putBenchNone => exact hs
  | discardActive ha => exact ⟨hs.1.some_eq ha rfl, hs.2⟩
  | discardBench hb => exact ⟨hs.1, hs.2.upd' hb rfl⟩
  | discardNone => exact hs
  | moveAB ha _ _ hb => exact ⟨hs.1.some_eq ha rfl, hs.2.upd' hb rfl⟩
  | moveBA ha hb => exact ⟨hs.1.some_eq ha rfl, hs.2.upd' hb rfl⟩
  | @moveBB w f s q q' b₁ b₂ c₁ c₂ e₁ e₂ x hb _ _ hc =>
      have h1 : ListNoOwe (b₁ ++ { q with energy := e₁ ++ e₂ } :: b₂) := hs.2.upd' hb rfl
      rw [hc] at h1
      exact ⟨hs.1, h1.upd' rfl rfl⟩
  | moveNone => exact hs
  | toolsActive ha => exact ⟨hs.1.some_eq ha rfl, hs.2⟩
  | toolsBench hb => exact ⟨hs.1, hs.2.upd' hb rfl⟩
  | toolsNone => exact hs
  | look _ _ hr hp => exact hp.noMarks (hr.noMarks (Src.set_noMarks hs))

theorem CMove.noOwe {f : Filter} {noKO : Bool} {hp : Spot → InPlay → Nat} {a a' : Option InPlay}
    {b b' : List InPlay} (h : CMove f noKO hp a b a' b') (ha : OptNoOwe a) (hb : ListNoOwe b) :
    OptNoOwe a' ∧ ListNoOwe b' := by
  cases h with
  | ab => exact ⟨ha.some_eq rfl rfl, hb.upd' rfl rfl⟩
  | ba => exact ⟨ha.some_eq rfl rfl, hb.upd' rfl rfl⟩
  | @bb _ q r b₁ b₂ c₁ c₂ _ _ hc =>
      have h1 : ListNoOwe (b₁ ++ { q with damage := q.damage - 1 } :: b₂) := hb.upd' rfl rfl
      rw [hc] at h1
      exact ⟨ha, h1.upd' rfl rfl⟩

theorem Promote.noOwe {a a' : Option InPlay} {b b' : List InPlay} (h : Promote a b a' b')
    (ha : OptNoOwe a) (hb : ListNoOwe b) : OptNoOwe a' ∧ ListNoOwe b' := by
  cases h with
  | keep => exact ⟨ha, hb⟩
  | pick =>
      exact ⟨OptNoOwe.some_of (hb.mem rfl), hb.sub fun p hp => by
        rcases List.mem_append.1 hp with hp | hp
        · exact List.mem_append_left _ hp
        · exact List.mem_append_right _ (.tail _ hp)⟩

theorem BenchChar.noOwe {b b' : List InPlay} (h : BenchChar b b') (hb : ListNoOwe b) :
    ListNoOwe b' := by
  induction h with
  | nil => exact hb
  | @cons p p' b b' hs _ ih =>
      intro x hx
      cases hx with
      | head =>
          cases hs with
          | keep => exact hb p (.head _)
          | burn => exact hb p (.head _)
      | tail _ hx => exact ih (fun q hq => hb q (.tail _ hq)) x hx

theorem PlayerState.koOut_noMarks {ta tb : InPlay → Bool} {s : PlayerState} (hs : s.NoMarks) :
    (s.koOut ta tb).NoMarks := by
  refine ⟨fun p hp => ?_, hs.2.sub fun p hp => (List.mem_filter.1 hp).1⟩
  show p.owe = none
  simp only [PlayerState.koOut] at hp
  cases ha : s.active with
  | none => rw [ha] at hp; cases hp
  | some x =>
      rw [ha] at hp
      simp only [optFilter] at hp
      split at hp
      · cases hp; exact hs.1 _ ha
      · cases hp

/-! ## Effects, triggers and the batch step -/

/-- **An effect's resolution and the marks.** It keeps the mover's Pokémon unmarked (1), never
clears the record (2), and leaves the opponent's Pokémon unmarked unless the record is set (3); an
effect of the trigger fragment (`Effect.trigOk`, which has no switch) keeps the record and the
opponent's Pokémon unmarked (4). -/
theorem Run.marks {e : Effect} {g g' : GameState} (h : Run e g g') :
    (g.cur.NoMarks → g'.cur.NoMarks) ∧ (g.pend = true → g'.pend = true) ∧
      ((g.pend = false → g.opp.NoMarks) → g'.pend = false → g'.opp.NoMarks) ∧
      (e.trigOk = true → g'.pend = g.pend ∧ (g.opp.NoMarks → g'.opp.NoMarks)) := by
  induction h with
  | skip => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | draw => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | drawEmpty => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | heal _ h => exact ⟨fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩, id, id, fun _ => ⟨rfl, id⟩⟩
  | counters _ h =>
      exact ⟨id, id, fun ho hp => ⟨(ho hp).1.some_eq h rfl, (ho hp).2⟩,
        fun _ => ⟨rfl, fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩⟩⟩
  | @inflict g p c h =>
      exact ⟨id, id,
        fun ho hp => ⟨(ho hp).1.some_eq h (p.inflict_owe c), (ho hp).2⟩,
        fun _ => ⟨rfl, fun ho => ⟨ho.1.some_eq h (p.inflict_owe c), ho.2⟩⟩⟩
  | poisonUp _ h =>
      exact ⟨id, id, fun ho hp => ⟨(ho hp).1.some_eq h rfl, (ho hp).2⟩,
        fun _ => ⟨rfl, fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩⟩⟩
  | poisonUpSkip => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | cure h => exact ⟨fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩, id, id, fun _ => ⟨rfl, id⟩⟩
  | shuffle => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | search => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | handToBottom => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | iteT _ _ _ ih => exact ⟨ih.1, ih.2.1, ih.2.2.1, fun ht => by simp [Effect.trigOk] at ht⟩
  | iteF _ _ _ ih => exact ⟨ih.1, ih.2.1, ih.2.2.1, fun ht => by simp [Effect.trigOk] at ht⟩
  | scale _ _ _ h =>
      exact ⟨id, id, fun ho hp => ⟨(ho hp).1.some_eq h rfl, (ho hp).2⟩,
        fun _ => ⟨rfl, fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩⟩⟩
  | selfDamage _ h =>
      exact ⟨fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩, id, id, fun _ => ⟨rfl, id⟩⟩
  | healAll h => exact ⟨fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩, id, id, fun _ => ⟨rfl, id⟩⟩
  | @touchActive e w f g p _ h =>
      cases w with
      | own => exact ⟨fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp =>
          exact ⟨id, id, fun ho hp => ⟨(ho hp).1.some_eq h rfl, (ho hp).2⟩,
            fun _ => ⟨rfl, fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩⟩⟩
  | @touchBench e w f g q b₁ b₂ _ h =>
      cases w with
      | own => exact ⟨fun hc => ⟨hc.1, hc.2.upd' h rfl⟩, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp =>
          exact ⟨id, id, fun ho hp => ⟨(ho hp).1, (ho hp).2.upd' h rfl⟩,
            fun _ => ⟨rfl, fun ho => ⟨ho.1, ho.2.upd' h rfl⟩⟩⟩
  | unmark w m g =>
      have hm : ∀ s : PlayerState, s.NoMarks → (s.unmark m).NoMarks := fun s hs =>
        ⟨hs.1.map fun _ => rfl, hs.2.map fun _ => rfl⟩
      cases w with
      | own => exact ⟨hm _, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp => exact ⟨id, id, fun ho hp => hm _ (ho hp), fun _ => ⟨rfl, hm _⟩⟩
  | linger w s m g => cases w <;> exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | damage _ h =>
      exact ⟨id, id, fun ho hp => ⟨(ho hp).1.some_eq h rfl, (ho hp).2⟩,
        fun _ => ⟨rfl, fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩⟩⟩
  | drain _ h hq =>
      exact ⟨fun hc => ⟨hc.1.some_eq hq rfl, hc.2⟩, id,
        fun ho hp => ⟨(ho hp).1.some_eq h rfl, (ho hp).2⟩,
        fun _ => ⟨rfl, fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩⟩⟩
  | benchCounters w n h =>
      cases w with
      | own => exact ⟨fun hc => ⟨hc.1, hc.2.upd' h rfl⟩, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp =>
          exact ⟨id, id, fun ho hp => ⟨(ho hp).1, (ho hp).2.upd' h rfl⟩,
            fun _ => ⟨rfl, fun ho => ⟨ho.1, ho.2.upd' h rfl⟩⟩⟩
  | benchCountersNone w => cases w <;> exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | spreadCounters w n g =>
      cases w with
      | own => exact ⟨fun hc => ⟨hc.1, hc.2.map fun _ => rfl⟩, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp =>
          exact ⟨id, id, fun ho hp => ⟨(ho hp).1, (ho hp).2.map fun _ => rfl⟩,
            fun _ => ⟨rfl, fun ho => ⟨ho.1, ho.2.map fun _ => rfl⟩⟩⟩
  | benchHeal n h => exact ⟨fun hc => ⟨hc.1, hc.2.upd' h rfl⟩, id, id, fun _ => ⟨rfl, id⟩⟩
  | benchHealNone => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | @switch g a q b₁ b₂ w ha hb =>
      cases w with
      | own =>
          exact ⟨fun hc => ⟨OptNoOwe.some_of (hc.2.mem hb : q.owe = none), hc.2.upd hb (hc.1 a ha)⟩,
            GameState.noteBenched_pend, GameState.noteBenched_opp,
            fun ht => by simp [Effect.trigOk] at ht⟩
      | opp =>
          exact ⟨id, id, fun ho hp => ⟨OptNoOwe.some_of ((ho hp).2.mem hb : q.owe = none),
              (ho hp).2.upd hb ((ho hp).1 a ha)⟩,
            fun _ => ⟨rfl, fun ho => ⟨OptNoOwe.some_of (ho.2.mem hb : q.owe = none), ho.2.upd hb (ho.1 a ha)⟩⟩⟩
  | switchNone w => cases w <;> exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | benchDamage w n h =>
      have hq : ∀ x : InPlay, (x.hitBench n).owe = x.owe := fun x => by
        unfold InPlay.hitBench; split <;> rfl
      cases w with
      | own => exact ⟨fun hc => ⟨hc.1, hc.2.upd' h (hq _)⟩, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp =>
          exact ⟨id, id, fun ho hp => ⟨(ho hp).1, (ho hp).2.upd' h (hq _)⟩,
            fun _ => ⟨rfl, fun ho => ⟨ho.1, ho.2.upd' h (hq _)⟩⟩⟩
  | benchDamageNone w => cases w <;> exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | spreadDamage w n g =>
      have hq : ∀ x : InPlay, (x.hitBench n).owe = x.owe := fun x => by
        unfold InPlay.hitBench; split <;> rfl
      cases w with
      | own => exact ⟨fun hc => ⟨hc.1, hc.2.map hq⟩, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp =>
          exact ⟨id, id, fun ho hp => ⟨(ho hp).1, (ho hp).2.map hq⟩,
            fun _ => ⟨rfl, fun ho => ⟨ho.1, ho.2.map hq⟩⟩⟩
  | benchSome w m f dmg n h =>
      have hq : ∀ x : InPlay, x.owe = none → (x.hitWith dmg n).owe = none := fun x hx => by
        cases dmg
        · exact hx
        · show (x.hitBench n).owe = none
          unfold InPlay.hitBench; split <;> exact hx
      cases w with
      | own => exact ⟨fun hc => ⟨hc.1, h.forall_of hq hc.2⟩, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp =>
          exact ⟨id, id, fun ho hp => ⟨(ho hp).1, h.forall_of hq (ho hp).2⟩,
            fun _ => ⟨rfl, fun ho => ⟨ho.1, h.forall_of hq ho.2⟩⟩⟩
  | @zone e w g s' _ hz =>
      cases w with
      | own => exact ⟨fun hc => hz.noMarks hc, id, id, fun _ => ⟨rfl, id⟩⟩
      | opp => exact ⟨id, id, fun ho hp => hz.noMarks (ho hp), fun _ => ⟨rfl, hz.noMarks⟩⟩
  | moveCounter h => exact ⟨fun hc => h.noOwe hc.1 hc.2, id, id, fun _ => ⟨rfl, id⟩⟩
  | discardStadium => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | seq _ _ ih₁ ih₂ =>
      refine ⟨fun h => ih₂.1 (ih₁.1 h), fun h => ih₂.2.1 (ih₁.2.1 h),
        fun h => ih₂.2.2.1 (ih₁.2.2.1 h), fun ht => ?_⟩
      simp only [Effect.trigOk, Bool.and_eq_true] at ht
      obtain ⟨a1, a2⟩ := ih₁.2.2.2 ht.1
      obtain ⟨b1, b2⟩ := ih₂.2.2.2 ht.2
      exact ⟨b1.trans a1, fun h => b2 (a2 h)⟩
  | choiceL _ ih =>
      refine ⟨ih.1, ih.2.1, ih.2.2.1, fun ht => ih.2.2.2 ?_⟩
      simp only [Effect.trigOk, Bool.and_eq_true] at ht; exact ht.1
  | choiceR _ ih =>
      refine ⟨ih.1, ih.2.1, ih.2.2.1, fun ht => ih.2.2.2 ?_⟩
      simp only [Effect.trigOk, Bool.and_eq_true] at ht; exact ht.2
  | iterNil => exact ⟨id, id, id, fun _ => ⟨rfl, id⟩⟩
  | iterCons _ _ ih₁ ih₂ =>
      exact ⟨fun h => ih₂.1 (ih₁.1 h), fun h => ih₂.2.1 (ih₁.2.1 h),
        fun h => ih₂.2.2.1 (ih₁.2.2.1 h), fun ht => by simp [Effect.trigOk] at ht⟩

/-- An effect's resolution keeps `MarksOk`. -/
theorem Run.marksOk {e : Effect} {g g' : GameState} (h : Run e g g') (hm : g.MarksOk) :
    g'.MarksOk :=
  ⟨h.marks.1 hm.1, h.marks.2.2.1 hm.2⟩

/-- **Triggers change no mark** (their effects are in the trigger fragment, which has no switch),
and keep the record. -/
theorem Fire.marks {ev : TrigEvent} {l : List Ability} {g g' : GameState} (h : Fire ev l g g') :
    g'.pend = g.pend ∧ (g.cur.NoMarks → g'.cur.NoMarks) ∧ (g.opp.NoMarks → g'.opp.NoMarks) := by
  induction h with
  | nil => exact ⟨rfl, id, id⟩
  | run hk hr _ ih =>
      have R := hr.marks
      obtain ⟨hp, ho⟩ := R.2.2.2 hk
      exact ⟨ih.1.trans hp, fun hc => ih.2.1 (ho hc), fun ho' => ih.2.2 (R.1 ho')⟩
  | decline _ _ ih => exact ih

theorem Fire.marksOk {ev : TrigEvent} {l : List Ability} {g g' : GameState} (h : Fire ev l g g')
    (hm : g.MarksOk) : g'.MarksOk :=
  hm.of_keep h.marks.1 h.marks.2.1 h.marks.2.2

/-- **The batch Knock Out step changes no mark** and keeps the record: it removes Pokémon and
promotes Benched ones. -/
theorem KOBatch.marks {g g' : GameState} (h : KOBatch g g') :
    g'.pend = g.pend ∧ (g.cur.NoMarks → g'.cur.NoMarks) ∧ (g.opp.NoMarks → g'.opp.NoMarks) := by
  have hc : g.cur.NoMarks → g.koStep.cur.NoMarks := fun hc =>
    PlayerState.koOut_noMarks (s := g.cur) hc
  have ho : g.opp.NoMarks → g.koStep.opp.NoMarks := fun ho =>
    PlayerState.koOut_noMarks (s := g.opp) ho
  cases h with
  | won => exact ⟨rfl, hc, ho⟩
  | go _ _ hpc hpo =>
      exact ⟨rfl, fun h => hpc.noOwe (hc h).1 (hc h).2, fun h => hpo.noOwe (ho h).1 (ho h).2⟩

theorem KOBatch.marksOk {g g' : GameState} (h : KOBatch g g') (hm : g.MarksOk) : g'.MarksOk :=
  hm.of_keep h.marks.1 h.marks.2.1 h.marks.2.2

theorem Resolve.marksOk {g g' : GameState} (h : Resolve g g') (hm : g.MarksOk) : g'.MarksOk := by
  induction h with
  | done => exact hm
  | step _ hb _ ih => exact ih (hb.marksOk hm)
  | trigger _ _ _ _ ht _ ih => exact ih (ht.marksOk (GameState.unpend_marksOk hm.1))

theorem TRun.marksOk {e : Effect} {g g' : GameState} (h : TRun e g g') (hm : g.MarksOk) :
    g'.MarksOk := by
  induction h with
  | prim _ _ hr hk => exact hk.marksOk (hr.marksOk hm)
  | stop => exact hm
  | iteT _ _ _ _ ih => exact ih hm
  | iteF _ _ _ _ ih => exact ih hm
  | seq _ _ ih₁ ih₂ => exact ih₂ (ih₁ hm)
  | choiceL _ ih => exact ih hm
  | choiceR _ ih => exact ih hm
  | iterNil => exact hm
  | iterCons _ _ ih₁ ih₂ => exact ih₂ (ih₁ hm)

theorem UseAt.marksOk {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁)
    (hm : g.MarksOk) : g₁.MarksOk := by
  cases h with
  | active ha => exact ⟨⟨hm.1.1.some_eq ha rfl, hm.1.2⟩, hm.2⟩
  | bench hb => exact ⟨⟨hm.1.1, hm.1.2.upd' hb rfl⟩, hm.2⟩

theorem PlayFromHand.marksOk {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) (hm : g.MarksOk) : g₁.MarksOk := by
  cases h with
  | basic => exact ⟨⟨hm.1.1, hm.1.2.append (ListNoOwe.ofBasic [_])⟩, hm.2⟩
  | evolve _ ha => exact ⟨⟨hm.1.1.some_eq ha rfl, hm.1.2⟩, hm.2⟩
  | evolveBench _ hb => exact ⟨⟨hm.1.1, hm.1.2.upd' hb rfl⟩, hm.2⟩

/-- **Legal play keeps `MarksOk`** (milestone MV7b, after review): no move marks the mover's
Pokémon, and the opponent's are marked only by raising the event, which sets the record that the
resolution clears with the marks. -/
theorem Move.marksOk {g g' : GameState} (h : Move g g') (hm : g.MarksOk) : g'.MarksOk := by
  cases h with
  | playBasic => exact ⟨⟨hm.1.1, hm.1.2.append (ListNoOwe.ofBasic [_])⟩, hm.2⟩
  | attach _ _ ha => exact ⟨⟨hm.1.1.some_eq ha rfl, hm.1.2⟩, hm.2⟩
  | evolve _ ha => exact ⟨⟨hm.1.1.some_eq ha rfl, hm.1.2⟩, hm.2⟩
  | attachBench _ _ hb => exact ⟨⟨hm.1.1, hm.1.2.upd' hb rfl⟩, hm.2⟩
  | evolveBench _ hb => exact ⟨⟨hm.1.1, hm.1.2.upd' hb rfl⟩, hm.2⟩
  | @retreat a q b₁ b₂ _ _ ha hb =>
      exact GameState.noteBenched_marksOk
        ⟨OptNoOwe.some_of (hm.1.2.mem hb : q.owe = none), hm.1.2.upd hb (hm.1.1 a ha)⟩ hm.2
  | item _ _ _ hr => exact hr.marksOk hm
  | supporter _ _ _ _ hr => exact hr.marksOk hm
  | stadium => exact hm
  | tool _ ha => exact ⟨⟨hm.1.1.some_eq ha rfl, hm.1.2⟩, hm.2⟩
  | toolBench _ hb => exact ⟨⟨hm.1.1, hm.1.2.upd' hb rfl⟩, hm.2⟩
  | stadiumUse _ _ _ _ _ hr => exact hr.marksOk hm
  | ability hu _ _ _ _ _ _ _ _ hr => exact hr.marksOk (hu.marksOk hm)
  | onPlay hp _ _ _ _ _ hr => exact hr.marksOk (hp.marksOk hm)
  | attack _ _ _ _ _ _ _ _ hr _ _ _ _ ht =>
      have h1 := ht.marksOk (hr.marksOk hm)
      exact ⟨⟨h1.1.1.map fun _ => rfl, h1.1.2⟩, h1.2⟩
  | attackConfused ha => exact ⟨⟨hm.1.1.some_eq ha rfl, hm.1.2⟩, hm.2⟩
  | knockOuts h _ ht => exact ht.marksOk (h.marksOk hm)
  | trigger _ _ _ ht => exact ht.marksOk (GameState.unpend_marksOk hm.1)
  | endTurn _ _ _ _ _ _ ha hb _ _ hco hcc hpd =>
      have ho := hm.2 hpd
      exact .of_both ⟨ho.1.some_eq ha rfl, hco.noOwe ho.2⟩
        ⟨hm.1.1.some_eq hb rfl, hcc.noOwe (hm.1.2.map fun _ => rfl)⟩
  | startTurn => exact hm
  | deckOut => exact hm

/-- Legal play from a state with `MarksOk` keeps it. -/
theorem Reach.marksOk {g₀ g : GameState} (h₀ : g₀.MarksOk) (h : Reach g₀ g) : g.MarksOk := by
  induction h with
  | refl => exact h₀
  | step _ _ hm ih => exact hm.marksOk ih

end Pokemon
