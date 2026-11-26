import Pokemon.Conservation

/-!
# The owed-trigger marks (milestone MV7b, after review)

`GameState.noteBenched` marks each of the opponent's Pokémon that has an `oppBenched` trigger where
it is (`InPlay.owe`), and the resolution of the pending triggers fires the marked ones
(`GameState.owedTrigs`) and clears every mark (`GameState.unpend`). The review of stage 2 found
that nothing excluded a start state whose Pokémon already carry marks with no trigger pending: such
a mark fires at the next event as an owed trigger. `GameState.MarksOk` (in `Rules`, part of
`WellFormed`) says that no Pokémon carries a mark unless a trigger is pending (until milestone MV7c:
none on the player to move's Pokémon at all, and none on the opponent's unless a trigger is
pending; since MV7c the player's own moves mark the player's own Pokémon, `InPlay.noteMove`). This
file proves that every move keeps it:

* `Run.marks`: an effect's resolution never clears the record and keeps `MarksOk`: it marks
  Pokémon (of either player) only by a switch of the player's own Active Pokémon, which raises the
  events and sets the record when it marks; an effect of the trigger fragment (`Effect.trigOk`, no
  switch) changes neither the record nor any mark;
* `Fire.marks`, `FireMine.marks`, `Owed.marksOk`: triggers change no mark and keep the record, and
  the resolution of the owed triggers leaves none; `KOBatch.marksOk`: the batch Knock Out step marks
  the player's promoted Pokémon only when it sets the record;
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
and the switch of the player's own Active Pokémon give the states they gave before MV7 (since
milestone MV7c, when moreover no Pokémon of the player to move is marked, which holds when nothing
was pending and no Pokémon that moved owes a `movedUp` or `movedDown` trigger). -/
theorem GameState.noteBenched_of_nil {g : GameState} (h : g.benchedTrigs = [])
    (hc : g.cur.noMarksB = true) : g.noteBenched = g := by
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
  rw [h, ea, eb, hc]
  cases g; rename_i pend
  cases pend <;> rfl

/-! ## The invariant -/

theorem GameState.MarksOk.of_both {g : GameState} (hc : g.cur.NoMarks) (ho : g.opp.NoMarks) :
    g.MarksOk := fun _ => ⟨hc, ho⟩

/-- A step that keeps the record and keeps each side unmarked keeps `MarksOk`. -/
theorem GameState.MarksOk.of_keep {g g' : GameState} (hm : g.MarksOk) (hp : g'.pend = g.pend)
    (hc : g.cur.NoMarks → g'.cur.NoMarks) (ho : g.opp.NoMarks → g'.opp.NoMarks) : g'.MarksOk :=
  fun h => have h' := hm (hp ▸ h); ⟨hc h'.1, ho h'.2⟩

/-- **Raising the event keeps `MarksOk`** (since milestone MV7c whatever the player to move's
Pokémon carry): the record is set when the opponent has an `oppBenched` trigger in play (whose
holders it marks) or a Pokémon of the player to move is marked; otherwise nothing changes. -/
theorem GameState.noteBenched_marksOk {g : GameState} (ho : g.pend = false → g.opp.NoMarks) :
    g.noteBenched.MarksOk := by
  intro hp
  have hp' : ((g.pend || !g.benchedTrigs.isEmpty) || !g.cur.noMarksB) = false := hp
  simp only [Bool.or_eq_false_iff, Bool.not_eq_false', List.isEmpty_iff] at hp'
  rw [GameState.noteBenched_of_nil hp'.1.2 hp'.2]
  exact ⟨.of_b hp'.2, ho hp'.1.1⟩

theorem GameState.noteBenched_pend {g : GameState} (h : g.pend = true) : g.noteBenched.pend = true := by
  show (g.pend || _ || _) = true
  rw [h, Bool.true_or, Bool.true_or]

/-- Clearing the record leaves no mark (milestone MV7c: on either side). -/
theorem GameState.unpend_marksOk (g : GameState) : g.unpend.MarksOk :=
  .of_both ⟨OptNoOwe.map_clear _, fun p hp => by obtain ⟨q, _, rfl⟩ := List.mem_map.1 hp; rfl⟩
    ⟨OptNoOwe.map_clear _, fun p hp => by obtain ⟨q, _, rfl⟩ := List.mem_map.1 hp; rfl⟩

/-! ## One player's zones -/

theorem Deal.noOwe {tf : Filter} {t : List Card} {a a' : Option InPlay} {b b' : List InPlay}
    (h : Deal tf t a b a' b') (ha : OptNoOwe a) (hb : ListNoOwe b) : OptNoOwe a' ∧ ListNoOwe b' := by
  induction h with
  | nil => exact ⟨ha, hb⟩
  | active _ _ _ ih => exact ih (ha.some_eq rfl rfl) hb
  | bench _ _ _ ih => exact ih ha (hb.upd' rfl rfl)

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
  | retActive ha _ _ hp => exact hp.noMarks ⟨hs.1.some_eq ha rfl, hs.2⟩
  | retBench hb _ _ hp => exact hp.noMarks ⟨hs.1, hs.2.upd' hb rfl⟩
  | retNone => exact hs

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

/-- What a step that keeps the record and each side's marks keeps. -/
theorem marks_frame {e : Effect} {g g' : GameState} (hp : g'.pend = g.pend)
    (hc : g.cur.NoMarks → g'.cur.NoMarks) (ho : g.opp.NoMarks → g'.opp.NoMarks) :
    (g.pend = true → g'.pend = true) ∧ (g.MarksOk → g'.MarksOk) ∧
      (e.trigOk = true → g'.pend = g.pend ∧ (g.cur.NoMarks → g'.cur.NoMarks) ∧
        (g.opp.NoMarks → g'.opp.NoMarks)) :=
  ⟨fun h => hp.trans h, fun hm => hm.of_keep hp hc ho, fun _ => ⟨hp, hc, ho⟩⟩

/-- **An effect's resolution and the marks.** It never clears the record (1) and keeps `MarksOk`
(2): marks are written only by a switch of the player's own Active Pokémon, which raises the
events and sets the record when it marks (milestone MV7c: on either side); an effect of the trigger
fragment (`Effect.trigOk`, which has no switch) changes neither the record nor any mark (3). -/
theorem Run.marks {e : Effect} {g g' : GameState} (h : Run e g g') :
    (g.pend = true → g'.pend = true) ∧ (g.MarksOk → g'.MarksOk) ∧
      (e.trigOk = true → g'.pend = g.pend ∧ (g.cur.NoMarks → g'.cur.NoMarks) ∧
        (g.opp.NoMarks → g'.opp.NoMarks)) := by
  induction h with
  | skip => exact marks_frame rfl id id
  | draw => exact marks_frame rfl id id
  | drawEmpty => exact marks_frame rfl id id
  | heal _ h => exact marks_frame rfl (fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩) id
  | counters _ h => exact marks_frame rfl id (fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩)
  | @inflict g p c h => exact marks_frame rfl id (fun ho => ⟨ho.1.some_eq h (p.inflict_owe c), ho.2⟩)
  | poisonUp _ h => exact marks_frame rfl id (fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩)
  | poisonUpSkip => exact marks_frame rfl id id
  | cure h => exact marks_frame rfl (fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩) id
  | shuffle => exact marks_frame rfl id id
  | search => exact marks_frame rfl id id
  | handToBottom => exact marks_frame rfl id id
  | iteT _ _ _ ih => exact ⟨ih.1, ih.2.1, fun ht => by simp [Effect.trigOk] at ht⟩
  | iteF _ _ _ ih => exact ⟨ih.1, ih.2.1, fun ht => by simp [Effect.trigOk] at ht⟩
  | scale _ _ _ h => exact marks_frame rfl id (fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩)
  | selfDamage _ h => exact marks_frame rfl (fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩) id
  | healAll h => exact marks_frame rfl (fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩) id
  | @touchActive e w f g p _ h =>
      cases w with
      | own => exact marks_frame rfl (fun hc => ⟨hc.1.some_eq h rfl, hc.2⟩) id
      | opp => exact marks_frame rfl id (fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩)
  | @touchBench e w f g q b₁ b₂ _ h =>
      cases w with
      | own => exact marks_frame rfl (fun hc => ⟨hc.1, hc.2.upd' h rfl⟩) id
      | opp => exact marks_frame rfl id (fun ho => ⟨ho.1, ho.2.upd' h rfl⟩)
  | unmark w m g =>
      have hm : ∀ s : PlayerState, s.NoMarks → (s.unmark m).NoMarks := fun s hs =>
        ⟨hs.1.map fun _ => rfl, hs.2.map fun _ => rfl⟩
      cases w with
      | own => exact marks_frame rfl (hm _) id
      | opp => exact marks_frame rfl id (hm _)
  | linger w s m g => cases w <;> exact marks_frame rfl id id
  | damage _ h => exact marks_frame rfl id (fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩)
  | drain _ h hq =>
      exact marks_frame rfl (fun hc => ⟨hc.1.some_eq hq rfl, hc.2⟩) (fun ho => ⟨ho.1.some_eq h rfl, ho.2⟩)
  | benchCounters w n h =>
      cases w with
      | own => exact marks_frame rfl (fun hc => ⟨hc.1, hc.2.upd' h rfl⟩) id
      | opp => exact marks_frame rfl id (fun ho => ⟨ho.1, ho.2.upd' h rfl⟩)
  | benchCountersNone w => cases w <;> exact marks_frame rfl id id
  | spreadCounters w n g =>
      cases w with
      | own => exact marks_frame rfl (fun hc => ⟨hc.1, hc.2.map fun _ => rfl⟩) id
      | opp => exact marks_frame rfl id (fun ho => ⟨ho.1, ho.2.map fun _ => rfl⟩)
  | benchHeal n h => exact marks_frame rfl (fun hc => ⟨hc.1, hc.2.upd' h rfl⟩) id
  | benchHealNone => exact marks_frame rfl id id
  | @switch g a q b₁ b₂ w ha hb =>
      cases w with
      | own =>
          refine ⟨fun hp => ?_, fun hm => ?_, fun ht => by simp [Effect.trigOk] at ht⟩
          · simp only [Whose.noteBenched]; exact GameState.noteBenched_pend hp
          · simp only [Whose.noteBenched]; exact GameState.noteBenched_marksOk fun hp => (hm hp).2
      | opp =>
          exact marks_frame rfl id fun ho =>
            ⟨OptNoOwe.some_of (ho.2.mem hb : q.owe = none), ho.2.upd hb (ho.1 a ha)⟩
  | switchNone w => cases w <;> exact marks_frame rfl id id
  | benchDamage w n h =>
      have hq : ∀ x : InPlay, (x.hitBench n).owe = x.owe := fun x => by
        unfold InPlay.hitBench; split <;> rfl
      cases w with
      | own => exact marks_frame rfl (fun hc => ⟨hc.1, hc.2.upd' h (hq _)⟩) id
      | opp => exact marks_frame rfl id (fun ho => ⟨ho.1, ho.2.upd' h (hq _)⟩)
  | benchDamageNone w => cases w <;> exact marks_frame rfl id id
  | spreadDamage w n g =>
      have hq : ∀ x : InPlay, (x.hitBench n).owe = x.owe := fun x => by
        unfold InPlay.hitBench; split <;> rfl
      cases w with
      | own => exact marks_frame rfl (fun hc => ⟨hc.1, hc.2.map hq⟩) id
      | opp => exact marks_frame rfl id (fun ho => ⟨ho.1, ho.2.map hq⟩)
  | benchSome w m f dmg n h =>
      have hq : ∀ x : InPlay, x.owe = none → (x.hitWith dmg n).owe = none := fun x hx => by
        cases dmg
        · exact hx
        · show (x.hitBench n).owe = none
          unfold InPlay.hitBench; split <;> exact hx
      cases w with
      | own => exact marks_frame rfl (fun hc => ⟨hc.1, h.forall_of hq hc.2⟩) id
      | opp => exact marks_frame rfl id (fun ho => ⟨ho.1, h.forall_of hq ho.2⟩)
  | @zone e w g s' _ hz =>
      cases w with
      | own => exact marks_frame rfl (fun hc => hz.noMarks hc) id
      | opp => exact marks_frame rfl id (fun ho => hz.noMarks ho)
  | moveCounter h => exact marks_frame rfl (fun hc => h.noOwe hc.1 hc.2) id
  | discardStadium => exact marks_frame rfl id id
  | seq _ _ ih₁ ih₂ =>
      refine ⟨fun h => ih₂.1 (ih₁.1 h), fun h => ih₂.2.1 (ih₁.2.1 h), fun ht => ?_⟩
      simp only [Effect.trigOk, Bool.and_eq_true] at ht
      obtain ⟨a1, a2, a3⟩ := ih₁.2.2 ht.1
      obtain ⟨b1, b2, b3⟩ := ih₂.2.2 ht.2
      exact ⟨b1.trans a1, fun h => b2 (a2 h), fun h => b3 (a3 h)⟩
  | choiceL _ ih =>
      refine ⟨ih.1, ih.2.1, fun ht => ih.2.2 ?_⟩
      simp only [Effect.trigOk, Bool.and_eq_true] at ht; exact ht.1
  | choiceR _ ih =>
      refine ⟨ih.1, ih.2.1, fun ht => ih.2.2 ?_⟩
      simp only [Effect.trigOk, Bool.and_eq_true] at ht; exact ht.2
  | iterNil => exact marks_frame rfl id id
  | iterCons _ _ ih₁ ih₂ =>
      exact ⟨fun h => ih₂.1 (ih₁.1 h), fun h => ih₂.2.1 (ih₁.2.1 h),
        fun ht => by simp [Effect.trigOk] at ht⟩

/-- An effect's resolution keeps `MarksOk`. -/
theorem Run.marksOk {e : Effect} {g g' : GameState} (h : Run e g g') (hm : g.MarksOk) :
    g'.MarksOk :=
  h.marks.2.1 hm

/-- **Triggers change no mark** (their effects are in the trigger fragment, which has no switch),
and keep the record. -/
theorem Fire.marks {ev : TrigEvent} {l : List Ability} {g g' : GameState} (h : Fire ev l g g') :
    g'.pend = g.pend ∧ (g.cur.NoMarks → g'.cur.NoMarks) ∧ (g.opp.NoMarks → g'.opp.NoMarks) := by
  induction h with
  | nil => exact ⟨rfl, id, id⟩
  | run hk hr _ ih =>
      obtain ⟨hp, hc, ho⟩ := hr.marks.2.2 hk
      exact ⟨ih.1.trans hp, fun hc' => ih.2.1 (ho hc'), fun ho' => ih.2.2 (hc ho')⟩
  | decline _ _ ih => exact ih

theorem Fire.marksOk {ev : TrigEvent} {l : List Ability} {g g' : GameState} (h : Fire ev l g g')
    (hm : g.MarksOk) : g'.MarksOk :=
  hm.of_keep h.marks.1 h.marks.2.1 h.marks.2.2

/-- The player to move's own triggers (milestone MV7c) change no mark and keep the record. -/
theorem FireMine.marks {u d : List Ability} {g g' : GameState} (h : FireMine u d g g') :
    g'.pend = g.pend ∧ (g.cur.NoMarks → g'.cur.NoMarks) ∧ (g.opp.NoMarks → g'.opp.NoMarks) := by
  obtain ⟨g₁, g₂, h₁, h₂, rfl⟩ := h
  obtain ⟨p1, c1, o1⟩ := h₁.marks
  obtain ⟨p2, c2, o2⟩ := h₂.marks
  exact ⟨p2.trans p1, fun hc => o2 (o1 hc), fun ho => c2 (c1 ho)⟩

/-- **The resolution of the owed triggers leaves no mark and nothing pending** (milestone MV7c). -/
theorem Owed.marksOk {g g' : GameState} (h : Owed g g') : g'.MarksOk := by
  have hu := GameState.unpend_marksOk g
  cases h with
  | mineFirst _ _ _ hm ht =>
      obtain ⟨p1, c1, o1⟩ := hm.marks
      exact (hu.of_keep p1 c1 o1).of_keep ht.marks.1 ht.marks.2.1 ht.marks.2.2
  | oppFirst _ _ _ ht hm =>
      obtain ⟨p1, c1, o1⟩ := hm.marks
      exact (ht.marksOk hu).of_keep p1 c1 o1

/-- The marking of a promotion is the identity when the promoted Pokémon owes nothing. -/
theorem GameState.promo_of_not {g : GameState} {ac : Option InPlay} (h : g.promoFires ac = false) :
    (if g.promoUp then ac.map (InPlay.noteMove .movedUp .active) else ac) = ac := by
  cases hu : g.promoUp
  · rfl
  · simp only [GameState.promoFires, hu, Bool.true_and] at h
    cases ac with
    | none => rfl
    | some q =>
        simp only [Option.map_some, Option.getD_some] at h
        simp only [ite_true, Option.map_some, InPlay.noteMove_of_not h]

/-- **The batch Knock Out step keeps `MarksOk`**: it removes Pokémon and promotes Benched ones, and
(milestone MV7c) marks the player to move's promoted Pokémon only when it sets the record. -/
theorem KOBatch.marksOk {g g' : GameState} (h : KOBatch g g') (hm : g.MarksOk) : g'.MarksOk := by
  cases h with
  | won =>
      intro hp
      have h' := hm hp
      have kc : g.koStep.cur.NoMarks := PlayerState.koOut_noMarks (s := g.cur) h'.1
      have ko : g.koStep.opp.NoMarks := PlayerState.koOut_noMarks (s := g.opp) h'.2
      exact ⟨kc, ko⟩
  | @go ac ao bc bo _ _ hpc hpo =>
      intro hp
      have hp' : (g.pend || g.promoFires ac) = false := hp
      rw [Bool.or_eq_false_iff] at hp'
      have h' := hm hp'.1
      have kc : g.koStep.cur.NoMarks := PlayerState.koOut_noMarks (s := g.cur) h'.1
      have ko : g.koStep.opp.NoMarks := PlayerState.koOut_noMarks (s := g.opp) h'.2
      have hc := hpc.noOwe kc.1 kc.2
      have ho := hpo.noOwe ko.1 ko.2
      refine ⟨⟨?_, hc.2⟩, ho⟩
      show OptNoOwe (if g.promoUp then ac.map (InPlay.noteMove .movedUp .active) else ac)
      rw [GameState.promo_of_not hp'.2]
      exact hc.1

theorem Resolve.marksOk {g g' : GameState} (h : Resolve g g') (hm : g.MarksOk) : g'.MarksOk := by
  induction h with
  | done => exact hm
  | step _ hb _ ih => exact ih (hb.marksOk hm)
  | trigger _ _ _ ho _ ih => exact ih ho.marksOk

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
  | active ha => exact hm.of_keep rfl (fun hc => ⟨hc.1.some_eq ha rfl, hc.2⟩) id
  | bench hb => exact hm.of_keep rfl (fun hc => ⟨hc.1, hc.2.upd' hb rfl⟩) id

theorem PlayFromHand.marksOk {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) (hm : g.MarksOk) : g₁.MarksOk := by
  cases h with
  | basic => exact hm.of_keep rfl (fun hc => ⟨hc.1, hc.2.append (ListNoOwe.ofBasic [_])⟩) id
  | evolve _ ha => exact hm.of_keep rfl (fun hc => ⟨hc.1.some_eq ha rfl, hc.2⟩) id
  | evolveBench _ hb => exact hm.of_keep rfl (fun hc => ⟨hc.1, hc.2.upd' hb rfl⟩) id

/-- **Legal play keeps `MarksOk`** (milestone MV7b, after review; since milestone MV7c with marks
on both sides): Pokémon are marked only by raising an event, which sets the record that the
resolution clears with the marks. -/
theorem Move.marksOk {g g' : GameState} (h : Move g g') (hm : g.MarksOk) : g'.MarksOk := by
  cases h with
  | playBasic => exact hm.of_keep rfl (fun hc => ⟨hc.1, hc.2.append (ListNoOwe.ofBasic [_])⟩) id
  | attach _ _ ha => exact hm.of_keep rfl (fun hc => ⟨hc.1.some_eq ha rfl, hc.2⟩) id
  | evolve _ ha => exact hm.of_keep rfl (fun hc => ⟨hc.1.some_eq ha rfl, hc.2⟩) id
  | attachBench _ _ hb => exact hm.of_keep rfl (fun hc => ⟨hc.1, hc.2.upd' hb rfl⟩) id
  | evolveBench _ hb => exact hm.of_keep rfl (fun hc => ⟨hc.1, hc.2.upd' hb rfl⟩) id
  | retreat => exact GameState.noteBenched_marksOk fun hp => (hm hp).2
  | item _ _ _ hr => exact hr.marksOk hm
  | supporter _ _ _ _ hr => exact hr.marksOk hm
  | stadium => exact hm
  | tool _ ha => exact hm.of_keep rfl (fun hc => ⟨hc.1.some_eq ha rfl, hc.2⟩) id
  | toolBench _ hb => exact hm.of_keep rfl (fun hc => ⟨hc.1, hc.2.upd' hb rfl⟩) id
  | stadiumUse _ _ _ _ _ hr => exact hr.marksOk hm
  | ability hu _ _ _ _ _ _ _ _ hr => exact hr.marksOk (hu.marksOk hm)
  | onPlay hp _ _ _ _ _ hr => exact hr.marksOk (hp.marksOk hm)
  | attack _ _ _ _ _ _ _ _ hr _ _ _ _ ht =>
      exact (ht.marksOk (hr.marksOk hm)).of_keep rfl (fun hc => ⟨hc.1.map fun _ => rfl, hc.2⟩) id
  | attackConfused ha => exact hm.of_keep rfl (fun hc => ⟨hc.1.some_eq ha rfl, hc.2⟩) id
  | knockOuts h _ ht => exact ht.marksOk (h.marksOk hm)
  | trigger _ _ ho => exact ho.marksOk
  | endTurn _ _ _ _ _ _ ha hb _ _ hco hcc hpd =>
      have h' := hm hpd
      exact .of_both ⟨h'.2.1.some_eq ha rfl, hco.noOwe h'.2.2⟩
        ⟨h'.1.1.some_eq hb rfl, hcc.noOwe (h'.1.2.map fun _ => rfl)⟩
  | startTurn => exact hm
  | deckOut => exact hm

/-- Legal play from a state with `MarksOk` keeps it. -/
theorem Reach.marksOk {g₀ g : GameState} (h₀ : g₀.MarksOk) (h : Reach g₀ g) : g.MarksOk := by
  induction h with
  | refl => exact h₀
  | step _ _ hm ih => exact hm.marksOk ih

end Pokemon
