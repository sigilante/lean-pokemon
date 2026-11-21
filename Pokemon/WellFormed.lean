import Pokemon.Conservation

/-!
# Well-formed states, and no deadlock

`WellFormed` (defined in `Rules`) asks that both players have Prize cards while there is no
winner, and that every Benched Pokémon has no Special Condition (since milestone M3 a Benched
Pokémon may be at or above its HP: that is a pending Knock Out, excluded by `Settled`).

* `Move.wellFormed`, `Reach.wellFormed`: legal play preserves it.
* `Move.progress`, `Reach.progress`: from a well-formed state with no winner some move is
  legal. In particular a pending Knock Out can always be taken: the player who takes the Prize
  has one, and the Pokémon that must be promoted afterwards is on the Bench or the game is won.
* `Move.knockOut_of_pending`, `Reach.knockOut_of_pending`: with no winner and a pending Knock
  Out (as after Checkup or an attack), a move is legal that Knocks Out a Pokémon in play (Active
  or Benched, of either player) at or above its HP, and the taker's Prize list shrinks by exactly
  that Pokémon's Prize count, or by all that are left.
-/

namespace Pokemon

/-- A Pokémon with its markers and damage counters removed. -/
def InPlay.bare (p : InPlay) : InPlay := { p with marks := Marks.empty, damage := 0 }

/-- Replacing one Benched Pokémon by a `Benched` one keeps the Bench `Benched`. -/
theorem benched_update {b b₁ b₂ : List InPlay} {q x : InPlay} (hb : b = b₁ ++ q :: b₂)
    (hw : ∀ p ∈ b, Benched p) (hx : Benched x) : ∀ p ∈ b₁ ++ x :: b₂, Benched p := by
  intro p hp
  rcases List.mem_append.1 hp with hp | hp
  · exact hw p (by rw [hb]; exact List.mem_append_left _ hp)
  · cases hp with
    | head => exact hx
    | tail _ hp => exact hw p (by rw [hb]; exact List.mem_append_right _ (.tail _ hp))

/-- Every Pokémon on a Bench is `Benched`. -/
def BenchOk (b : List InPlay) : Prop := ∀ p ∈ b, Benched p

/-- A Pokémon with the Special Conditions and Poison strength of a `Benched` one is `Benched`. -/
theorem Benched.of_eq {p q : InPlay} (h : Benched q) (h1 : p.rot = q.rot)
    (h2 : p.poisoned = q.poisoned) (h3 : p.burned = q.burned) (h4 : p.poisonUp = q.poisonUp) :
    Benched p :=
  ⟨h1 ▸ h.1, h2 ▸ h.2.1, h3 ▸ h.2.2.1, h4 ▸ h.2.2.2⟩

/-- An update that keeps Special Conditions and Poison strength keeps a Bench `BenchOk`. -/
theorem BenchOk.map {b : List InPlay} {U : InPlay → InPlay} (hb : BenchOk b)
    (hU : ∀ q, Benched q → Benched (U q)) : BenchOk (b.map U) := by
  intro p hp
  obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
  exact hU q (hb q hq)

/-- A zone step keeps every Benched Pokémon `Benched`: it changes only attached Energy, and a
Pokémon it puts onto the Bench is a Basic Pokémon just put into play. -/
theorem ZStep.benchOk {e : Effect} {s s' : PlayerState} (h : ZStep e s s') (hb : BenchOk s.bench) :
    BenchOk s'.bench := by
  have mem : ∀ {b b₁ b₂ : List InPlay} {q : InPlay}, b = b₁ ++ q :: b₂ → q ∈ b :=
    fun e => by rw [e]; exact List.mem_append_right _ (.head _)
  cases h with
  | @move w src dst f q s s' t r hs hq hp => rw [hp.fields.2.2, Src.set_bench]; exact hb
  | drawTo => exact hb
  | @attachActive w src f tf s r t a hs ha ht =>
      show BenchOk (src.set r s).bench; rw [Src.set_bench]; exact hb
  | @attachBench w src f tf s r t q b₁ b₂ hs hb' ht =>
      exact benched_update hb' hb ((hb q (mem hb')).of_eq rfl rfl rfl rfl)
  | attachNone => exact hb
  | @putBench w src f s r p hs hst hhp hbl =>
      intro x hx
      rcases List.mem_append.1 hx with hx | hx
      · exact hb x hx
      · rw [List.mem_singleton] at hx; subst hx; exact ⟨rfl, rfl, rfl, rfl⟩
  | putBenchNone => exact hb
  | discardActive => exact hb
  | @discardBench w f q s p b₁ b₂ t r hb' hs hq =>
      exact benched_update hb' hb ((hb p (mem hb')).of_eq rfl rfl rfl rfl)
  | discardNone => exact hb
  | @moveAB w f s a q b₁ b₂ e₁ e₂ x ha he hx hb' =>
      exact benched_update hb' hb ((hb q (mem hb')).of_eq rfl rfl rfl rfl)
  | @moveBA w f s a q b₁ b₂ e₁ e₂ x ha hb' he hx =>
      exact benched_update hb' hb ((hb q (mem hb')).of_eq rfl rfl rfl rfl)
  | @moveBB w f s q q' b₁ b₂ c₁ c₂ e₁ e₂ x hb' he hx hc =>
      have h1 : BenchOk (b₁ ++ { q with energy := e₁ ++ e₂ } :: b₂) :=
        benched_update hb' hb ((hb q (mem hb')).of_eq rfl rfl rfl rfl)
      rw [hc] at h1
      exact benched_update rfl h1 ((h1 q' (mem rfl)).of_eq rfl rfl rfl rfl)
  | moveNone => exact hb

/-- Moving a damage counter keeps every Benched Pokémon `Benched` (milestone M8a). -/
theorem CMove.benchOk {f : Filter} {noKO : Bool} {a a' : Option InPlay} {b b' : List InPlay}
    (h : CMove f noKO a b a' b') (hb : BenchOk b) : BenchOk b' := by
  have mem : ∀ {b₁ b₂ : List InPlay} {q : InPlay}, q ∈ b₁ ++ q :: b₂ :=
    List.mem_append_right _ (.head _)
  cases h with
  | @ab x q b₁ b₂ => exact benched_update rfl hb ((hb q mem).of_eq rfl rfl rfl rfl)
  | @ba x q b₁ b₂ => exact benched_update rfl hb ((hb q mem).of_eq rfl rfl rfl rfl)
  | @bb _ q r b₁ b₂ c₁ c₂ hq hd hc =>
      have h1 : BenchOk (b₁ ++ { q with damage := q.damage - 1 } :: b₂) :=
        benched_update rfl hb ((hb q mem).of_eq rfl rfl rfl rfl)
      rw [hc] at h1
      exact benched_update rfl h1 ((h1 r mem).of_eq rfl rfl rfl rfl)

/-- What resolving an effect never changes: that every Benched Pokémon is `Benched` (effects
change Benched Pokémon only in markers and damage counters, and a Pokémon that a switch puts on
the Bench is cured, milestone M3), the Prizes, the winner, who is first, and the phase of the
turn. (Before milestone M3 the Benches themselves were unchanged except for markers.) -/
def Run.Frame (g g' : GameState) : Prop :=
  (BenchOk g.cur.bench → BenchOk g'.cur.bench) ∧ (BenchOk g.opp.bench → BenchOk g'.opp.bench) ∧
    g'.cur.prizes = g.cur.prizes ∧ g'.opp.prizes = g.opp.prizes ∧
    g'.winner = g.winner ∧ g'.curIsFirst = g.curIsFirst ∧ g'.between = g.between

theorem Run.frame {e : Effect} {g g' : GameState} (h : Run e g g') : Run.Frame g g' := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ =>
      obtain ⟨a1, a2, a3, a4, a5, a6, a7⟩ := ih₁
      obtain ⟨b1, b2, b3, b4, b5, b6, b7⟩ := ih₂
      exact ⟨fun h => b1 (a1 h), fun h => b2 (a2 h), b3.trans a3, b4.trans a4, b5.trans a5,
        b6.trans a6, b7.trans a7⟩
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterCons _ _ ih₁ ih₂ =>
      obtain ⟨a1, a2, a3, a4, a5, a6, a7⟩ := ih₁
      obtain ⟨b1, b2, b3, b4, b5, b6, b7⟩ := ih₂
      exact ⟨fun h => b1 (a1 h), fun h => b2 (a2 h), b3.trans a3, b4.trans a4, b5.trans a5,
        b6.trans a6, b7.trans a7⟩
  | @touchActive e w f g p he h => cases w <;> exact ⟨id, id, rfl, rfl, rfl, rfl, rfl⟩
  | @touchBench e w f g q b₁ b₂ he h =>
      cases w <;> simp only [GameState.side] at h <;>
        exact ⟨fun hb => by
            first
            | exact benched_update h hb
                ((hb q (by rw [h]; exact List.mem_append_right _ (.head _))).of_eq rfl rfl rfl rfl)
            | exact hb,
          fun hb => by
            first
            | exact benched_update h hb
                ((hb q (by rw [h]; exact List.mem_append_right _ (.head _))).of_eq rfl rfl rfl rfl)
            | exact hb, rfl, rfl, rfl, rfl, rfl⟩
  | unmark w m g =>
      cases w <;>
        exact ⟨fun hb => by
            first
            | exact hb.map fun q hq => hq.of_eq rfl rfl rfl rfl
            | exact hb,
          fun hb => by
            first
            | exact hb.map fun q hq => hq.of_eq rfl rfl rfl rfl
            | exact hb, rfl, rfl, rfl, rfl, rfl⟩
  | linger w s m g => cases w <;> exact ⟨id, id, rfl, rfl, rfl, rfl, rfl⟩
  | @benchCounters g q b₁ b₂ w n h =>
      cases w <;> simp only [GameState.side] at h <;>
        exact ⟨fun hb => by
            first
            | exact benched_update h hb
                ((hb q (by rw [h]; exact List.mem_append_right _ (.head _))).of_eq rfl rfl rfl rfl)
            | exact hb,
          fun hb => by
            first
            | exact benched_update h hb
                ((hb q (by rw [h]; exact List.mem_append_right _ (.head _))).of_eq rfl rfl rfl rfl)
            | exact hb, rfl, rfl, rfl, rfl, rfl⟩
  | spreadCounters w n g =>
      cases w <;>
        exact ⟨fun hb => by
            first
            | exact hb.map fun q hq => hq.of_eq rfl rfl rfl rfl
            | exact hb,
          fun hb => by
            first
            | exact hb.map fun q hq => hq.of_eq rfl rfl rfl rfl
            | exact hb, rfl, rfl, rfl, rfl, rfl⟩
  | @benchHeal g q b₁ b₂ n h =>
      exact ⟨fun hb => benched_update h hb
          ((hb q (by rw [h]; exact List.mem_append_right _ (.head _))).of_eq rfl rfl rfl rfl),
        id, rfl, rfl, rfl, rfl, rfl⟩
  | @switch g a q b₁ b₂ w ha h =>
      cases w <;> simp only [GameState.side] at h <;>
        exact ⟨fun hb => by
            first
            | exact benched_update h hb ⟨rfl, rfl, rfl, rfl⟩
            | exact hb,
          fun hb => by
            first
            | exact benched_update h hb ⟨rfl, rfl, rfl, rfl⟩
            | exact hb, rfl, rfl, rfl, rfl, rfl⟩
  | @benchDamage g q b₁ b₂ w n h =>
      have hq : ∀ x, Benched x → Benched (x.hitBench n) := fun x hx => by
        obtain ⟨-, -, -, -, e1, e2, e3, e4, -⟩ := x.hitBench_fields n
        exact hx.of_eq e1 e2 e3 e4
      cases w <;> simp only [GameState.side] at h <;>
        exact ⟨fun hb => by
            first
            | exact benched_update h hb
                (hq q (hb q (by rw [h]; exact List.mem_append_right _ (.head _))))
            | exact hb,
          fun hb => by
            first
            | exact benched_update h hb
                (hq q (hb q (by rw [h]; exact List.mem_append_right _ (.head _))))
            | exact hb, rfl, rfl, rfl, rfl, rfl⟩
  | spreadDamage w n g =>
      have hq : ∀ x, Benched x → Benched (x.hitBench n) := fun x hx => by
        obtain ⟨-, -, -, -, e1, e2, e3, e4, -⟩ := x.hitBench_fields n
        exact hx.of_eq e1 e2 e3 e4
      cases w <;>
        exact ⟨fun hb => by
            first
            | exact hb.map hq
            | exact hb,
          fun hb => by
            first
            | exact hb.map hq
            | exact hb, rfl, rfl, rfl, rfl, rfl⟩
  | @zone e w g s' hw hz =>
      cases w with
      | own => exact ⟨fun hb => hz.benchOk hb, id, rfl, rfl, rfl, rfl, rfl⟩
      | opp => exact ⟨id, fun hb => hz.benchOk hb, rfl, rfl, rfl, rfl, rfl⟩
  | moveCounter h => exact ⟨fun hb => h.benchOk hb, id, rfl, rfl, rfl, rfl, rfl⟩
  | _ => exact ⟨id, id, rfl, rfl, rfl, rfl, rfl⟩

/-- Markers do not matter to `Benched`. -/
theorem benched_of_map {b b' : List InPlay}
    (h : b'.map InPlay.bare = b.map InPlay.bare) (hb : ∀ p ∈ b, Benched p) :
    ∀ p ∈ b', Benched p := by
  intro p hp
  have hm : p.bare ∈ b.map InPlay.bare := h ▸ List.mem_map_of_mem hp
  obtain ⟨q, hq, e⟩ := List.mem_map.1 hm
  obtain ⟨h2, h3, h4, h5⟩ := hb q hq
  have er : q.rot = p.rot := by
    have := congrArg InPlay.rot e; exact this
  have ep : q.poisoned = p.poisoned := by
    have := congrArg InPlay.poisoned e; exact this
  have eb : q.burned = p.burned := by
    have := congrArg InPlay.burned e; exact this
  have eu : q.poisonUp = p.poisonUp := by
    have := congrArg InPlay.poisonUp e; exact this
  exact ⟨er ▸ h2, ep ▸ h3, eb ▸ h4, eu ▸ h5⟩

theorem WellFormed.of_frame {g g' : GameState} (hw : WellFormed g) (hf : Run.Frame g g') :
    WellFormed g' := by
  obtain ⟨f1, f2, f3, f4, f5, _, _⟩ := hf
  refine ⟨fun hn => ?_, f1 hw.2.1, f2 hw.2.2⟩
  rw [f3, f4]; exact hw.1 (f5 ▸ hn)

theorem mem_append_cons_of_mem {α : Type} {x : α} {b₁ b₂ : List α} (y : α)
    (h : x ∈ b₁ ++ b₂) : x ∈ b₁ ++ y :: b₂ := by
  rcases List.mem_append.1 h with h | h
  · exact List.mem_append_left _ h
  · exact List.mem_append_right _ (.tail _ h)

/-- Char counters keep a Bench `Benched`: they change only damage. -/
theorem BenchChar.benched {b b' : List InPlay} (h : BenchChar b b') (hb : ∀ p ∈ b, Benched p) :
    ∀ p ∈ b', Benched p := by
  induction h with
  | nil => exact hb
  | cons hs _ ih =>
      intro p hp
      cases hp with
      | head =>
          cases hs with
          | keep => exact hb _ (.head _)
          | burn =>
              have h := hb _ (.head _)
              exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩
      | tail _ hp => exact ih (fun q hq => hb q (.tail _ hq)) p hp

/-- A player who has not taken their last Prize card has Prize cards left. -/
theorem prizes_of_not_out {n : Nat} {s : PlayerState} (h : s.prizesOut n = false) :
    (s.takePrizes n).prizes ≠ [] := by
  simp only [PlayerState.prizesOut, PlayerState.takePrizes] at h ⊢
  intro e; rw [e] at h; cases h

/-- A Knock Out move preserves well-formedness. -/
theorem KOMove.wellFormed {g g' : GameState} (h : KOMove g g') (hw : WellFormed g) :
    WellFormed g' := by
  cases h with
  | @knockOut p c ps ha hk hp =>
      refine ⟨fun hn => ?_, hw.2.1, hw.2.2⟩
      cases ho : g.cur.prizesOut p.top.prizeCount with
      | true => simp [ho] at hn
      | false =>
          simp only [ho, Bool.false_eq_true, ite_false] at hn
          exact ⟨prizes_of_not_out ho, (hw.1 hn).2⟩
  | promote ha hb =>
      refine ⟨hw.1, hw.2.1, fun p hp => hw.2.2 p ?_⟩
      rw [hb]; exact mem_append_cons_of_mem _ hp
  | noPokemon ha hb => exact ⟨fun hn => by simp at hn, hw.2.1, hw.2.2⟩
  | @knockOutOwn p c ps ha hk hp =>
      refine ⟨fun hn => ?_, hw.2.1, hw.2.2⟩
      cases ho : g.opp.prizesOut p.top.prizeCount with
      | true => simp [ho] at hn
      | false =>
          simp only [ho, Bool.false_eq_true, ite_false] at hn
          exact ⟨(hw.1 hn).1, prizes_of_not_out ho⟩
  | @knockOutBench p b₁ b₂ c ps hb hk hp =>
      refine ⟨fun hn => ?_, hw.2.1, fun q hq => hw.2.2 q ?_⟩
      · cases ho : g.cur.prizesOut p.top.prizeCount with
        | true => simp [ho] at hn
        | false =>
            simp only [ho, Bool.false_eq_true, ite_false] at hn
            exact ⟨prizes_of_not_out ho, (hw.1 hn).2⟩
      · rw [hb]; exact mem_append_cons_of_mem _ hq
  | @knockOutBenchOwn p b₁ b₂ c ps hb hk hp =>
      refine ⟨fun hn => ?_, fun q hq => hw.2.1 q ?_, hw.2.2⟩
      · cases ho : g.opp.prizesOut p.top.prizeCount with
        | true => simp [ho] at hn
        | false =>
            simp only [ho, Bool.false_eq_true, ite_false] at hn
            exact ⟨(hw.1 hn).1, prizes_of_not_out ho⟩
      · rw [hb]; exact mem_append_cons_of_mem _ hq
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

/-- Marking a Pokémon as having used an Ability keeps `Settled` (milestone M8a): damage and
HP are unchanged. -/
theorem UseAt.settled {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁)
    (hs : Settled g) : Settled g₁ := by
  obtain ⟨hk, h1, h2⟩ := hs
  cases h with
  | active ha =>
      refine ⟨fun p hp => ?_, by simp, h2⟩
      rcases hp with hp | hp | hp | hp
      · simp only [Option.some.injEq] at hp; subst hp; exact hk x (.inl ha)
      · exact hk p (.inr (.inl hp))
      · exact hk p (.inr (.inr (.inl hp)))
      · exact hk p (.inr (.inr (.inr hp)))
  | bench hb =>
      refine ⟨fun p hp => ?_, h1, h2⟩
      rcases hp with hp | hp | hp | hp
      · exact hk p (.inl hp)
      · simp only at hp
        rcases List.mem_append.1 hp with hp | hp
        · exact hk p (.inr (.inl (by rw [hb]; exact List.mem_append_left _ hp)))
        · cases hp with
          | head => exact hk x (.inr (.inl (by rw [hb]; exact List.mem_append_right _ (.head _))))
          | tail _ hp =>
              exact hk p (.inr (.inl (by rw [hb]; exact List.mem_append_right _ (.tail _ hp))))
      · exact hk p (.inr (.inr (.inl hp)))
      · exact hk p (.inr (.inr (.inr hp)))

/-- Marking a Pokémon as having used an Ability keeps well-formedness (milestone M8a). -/
theorem UseAt.wellFormed {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁)
    (hw : WellFormed g) : WellFormed g₁ := by
  cases h with
  | active ha => exact hw
  | bench hb =>
      exact ⟨hw.1, benched_update hb hw.2.1 (let h := hw.2.1 x (hb ▸ List.mem_append_right _
        (.head _)); ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩), hw.2.2⟩

/-- A play from the hand keeps well-formedness (milestone M8a). -/
theorem PlayFromHand.wellFormed {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) (hw : WellFormed g) : WellFormed g₁ := by
  cases h with
  | basic hh hs hhp hb =>
      refine ⟨hw.1, fun p hp => ?_, hw.2.2⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p hp
      · rw [List.mem_singleton] at hp; subst hp
        exact ⟨rfl, rfl, rfl, rfl⟩
  | evolve => exact hw
  | evolveBench hh hb => exact ⟨hw.1, benched_update hb hw.2.1 ⟨rfl, rfl, rfl, rfl⟩, hw.2.2⟩

/-- Legal play preserves well-formedness. -/
theorem Move.wellFormed {g g' : GameState} (h : Move g g') (hw : WellFormed g) :
    WellFormed g' := by
  cases h with
  | playBasic hh hs hhp hb =>
      refine ⟨hw.1, fun p hp => ?_, hw.2.2⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p hp
      · rw [List.mem_singleton] at hp; subst hp
        exact ⟨rfl, rfl, rfl, rfl⟩
  | attach hh hf ha => exact hw
  | evolve hh ha he hfr hf => exact hw
  | @attachBench l₁ l₂ t q b₁ b₂ hh hf hb =>
      exact ⟨hw.1, benched_update hb hw.2.1 (let h := hw.2.1 q (hb ▸ List.mem_append_right _
        (.head _)); ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩), hw.2.2⟩
  | evolveBench hh hb => exact ⟨hw.1, benched_update hb hw.2.1 ⟨rfl, rfl, rfl, rfl⟩, hw.2.2⟩
  | retreat ha hb hr he hp hs hbt hst hl hat =>
      rename_i a q b₁ b₂ _ _
      refine ⟨hw.1, fun p hp => ?_, hw.2.2⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p (by rw [hb]; exact List.mem_append_left _ hp)
      · cases hp with
        | head => exact ⟨rfl, rfl, rfl, rfl⟩
        | tail _ hp =>
            exact hw.2.1 p (by rw [hb]; exact List.mem_append_right _ (.tail _ hp))
  | item hh hbt hst hr => exact hr.wellFormed hw
  | supporter hh hs hbt hst hr => exact hr.wellFormed hw
  | stadiumUse _ _ _ _ _ hr => exact hr.wellFormed hw
  | stadium => exact hw
  | tool => exact hw
  | @toolBench l₁ l₂ n gr q b₁ b₂ hh hb =>
      exact ⟨hw.1, benched_update hb hw.2.1 (let h := hw.2.1 q (hb ▸ List.mem_append_right _
        (.head _)); ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩), hw.2.2⟩
  | ability hu _ _ _ _ _ _ _ _ hr => exact hr.wellFormed (hu.wellFormed hw)
  | onPlay hp _ _ _ _ _ hr => exact hr.wellFormed (hp.wellFormed hw)
  | attack ha hm hc hs hn hf hbt hst hr => exact WellFormed.of_frame hw hr.frame
  | attackConfused ha hm hc hs hn hf => exact hw
  | @knockOut p c ps ha hk hp =>
      refine ⟨fun hn => ?_, hw.2.1, hw.2.2⟩
      cases ho : g.cur.prizesOut p.top.prizeCount with
      | true => simp [ho] at hn
      | false =>
          simp only [ho, Bool.false_eq_true, ite_false] at hn
          exact ⟨prizes_of_not_out ho, (hw.1 hn).2⟩
  | promote ha hb =>
      refine ⟨hw.1, hw.2.1, fun p hp => hw.2.2 p ?_⟩
      rw [hb]; exact mem_append_cons_of_mem _ hp
  | noPokemon ha hb => exact ⟨fun hn => by simp at hn, hw.2.1, hw.2.2⟩
  | @knockOutOwn p c ps ha hk hp =>
      refine ⟨fun hn => ?_, hw.2.1, hw.2.2⟩
      cases ho : g.opp.prizesOut p.top.prizeCount with
      | true => simp [ho] at hn
      | false =>
          simp only [ho, Bool.false_eq_true, ite_false] at hn
          exact ⟨(hw.1 hn).1, prizes_of_not_out ho⟩
  | @knockOutBench p b₁ b₂ c ps hb hk hp =>
      refine ⟨fun hn => ?_, hw.2.1, fun q hq => hw.2.2 q ?_⟩
      · cases ho : g.cur.prizesOut p.top.prizeCount with
        | true => simp [ho] at hn
        | false =>
            simp only [ho, Bool.false_eq_true, ite_false] at hn
            exact ⟨prizes_of_not_out ho, (hw.1 hn).2⟩
      · rw [hb]; exact mem_append_cons_of_mem _ hq
  | @knockOutBenchOwn p b₁ b₂ c ps hb hk hp =>
      refine ⟨fun hn => ?_, fun q hq => hw.2.1 q ?_, hw.2.2⟩
      · cases ho : g.opp.prizesOut p.top.prizeCount with
        | true => simp [ho] at hn
        | false =>
            simp only [ho, Bool.false_eq_true, ite_false] at hn
            exact ⟨(hw.1 hn).1, prizes_of_not_out ho⟩
      · rw [hb]; exact mem_append_cons_of_mem _ hq
  | promoteOwn ha hb =>
      refine ⟨hw.1, fun p hp => hw.2.1 p ?_, hw.2.2⟩
      rw [hb]; exact mem_append_cons_of_mem _ hp
  | noPokemonOwn ha hb => exact ⟨fun hn => by simp at hn, hw.2.1, hw.2.2⟩
  | endTurn fa sa ca fb sb cb ha hb hk hbt hco hcc =>
      refine ⟨fun hn => ⟨(hw.1 hn).2, (hw.1 hn).1⟩, hco.benched hw.2.2, hcc.benched ?_⟩
      intro p hp
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

/-- An Active spot is empty, holds a Pokémon below its HP, or holds one at or above its HP. -/
theorem active_split (o : Option InPlay) :
    (∃ a, o = some a ∧ a.top.hp ≤ a.damage) ∨ ∀ a, o = some a → a.damage < a.top.hp := by
  cases o with
  | none => exact .inr fun _ h => by cases h
  | some a =>
      rcases Nat.lt_or_ge a.damage a.top.hp with h | h
      · exact .inr fun a' h' => by cases h'; exact h
      · exact .inl ⟨a, rfl, h⟩

/-- A Bench has a Pokémon at or above its HP, or every Pokémon on it is below its HP. -/
theorem bench_split : ∀ l : List InPlay,
    (∃ b₁ p b₂, l = b₁ ++ p :: b₂ ∧ p.top.hp ≤ p.damage) ∨ ∀ p ∈ l, p.damage < p.top.hp
  | [] => .inr fun _ h => nomatch h
  | q :: qs => by
      rcases Nat.lt_or_ge q.damage q.top.hp with h | h
      · rcases bench_split qs with ⟨b₁, p, b₂, e, hk⟩ | hall
        · exact .inl ⟨q :: b₁, p, b₂, by rw [e]; rfl, hk⟩
        · exact .inr fun p hp => by
            cases hp with
            | head => exact h
            | tail _ hp => exact hall p hp
      · exact .inl ⟨[], q, qs, rfl, h⟩

theorem PokemonCard.prizeCount_pos (d : PokemonCard) : 0 < d.prizeCount := RuleBox.prizes_pos _

theorem PokemonCard.prizeCount_le (d : PokemonCard) : d.prizeCount ≤ 3 := RuleBox.prizes_le _

/-- Taking `n` Prize cards shrinks the Prize list by exactly `min n` (its length). -/
theorem takePrizes_length (s : PlayerState) (n : Nat) :
    (s.takePrizes n).prizes.length + min n s.prizes.length = s.prizes.length := by
  simp only [PlayerState.takePrizes, List.length_drop]
  omega

/-- In a well-formed state with no winner, the player to move has a Prize card left. -/
theorem WellFormed.curPrizes {g : GameState} (hw : WellFormed g) (hn : g.winner = none) :
    ∃ c ps, g.cur.prizes = c :: ps := by
  cases e : g.cur.prizes with
  | nil => exact absurd e (hw.1 hn).1
  | cons c ps => exact ⟨c, ps, rfl⟩

/-- In a well-formed state with no winner, the opponent has a Prize card left. -/
theorem WellFormed.oppPrizes {g : GameState} (hw : WellFormed g) (hn : g.winner = none) :
    ∃ c ps, g.opp.prizes = c :: ps := by
  cases e : g.opp.prizes with
  | nil => exact absurd e (hw.1 hn).2
  | cons c ps => exact ⟨c, ps, rfl⟩

/-- **A pending Knock Out can be taken.** In a well-formed state with no winner and a pending
Knock Out (for instance between turns, after Checkup, or after an attack that damaged a Benched
Pokémon), some Knock Out move is legal. It Knocks Out a Pokémon `x` in play whose damage is at
least its HP: the opponent's Active or Benched Pokémon, and then the player to move takes Prize
cards, or the player's own, and then the opponent does. The taker's Prize list shrinks by exactly
`min x.top.prizeCount` (its length): the Knocked Out Pokémon's Prize count (1, 2 or 3), or all
that are left; the other player's Prize list is unchanged. Since the taker has a Prize card
(`WellFormed`) and every Prize count is at least 1, at least one Prize card is taken.

Milestone M3 changed the statement. Before it, every Knock Out gave exactly one Prize card and the
conclusion was that the total of both Prize lists drops by exactly one; that is the case
`x.top.prizeCount = 1` of this statement. The Knock Out move may now be one of a Benched Pokémon
(`Move.knockOutBench`, `Move.knockOutBenchOwn`), and it is also a `KOMove`. -/
theorem Move.knockOut_of_pending {g : GameState} (hw : WellFormed g) (hn : g.winner = none)
    (hk : ¬ DamageBounded g) :
    ∃ (g' : GameState) (x : InPlay), Move g g' ∧ KOMove g g' ∧ x.top.hp ≤ x.damage ∧
      (((g.opp.active = some x ∨ x ∈ g.opp.bench) ∧
          g'.cur.prizes.length + min x.top.prizeCount g.cur.prizes.length =
            g.cur.prizes.length ∧ g'.opp.prizes = g.opp.prizes) ∨
        ((g.cur.active = some x ∨ x ∈ g.cur.bench) ∧
          g'.opp.prizes.length + min x.top.prizeCount g.opp.prizes.length =
            g.opp.prizes.length ∧ g'.cur.prizes = g.cur.prizes)) := by
  rcases active_split g.opp.active with ⟨a, ho, hka⟩ | hoa
  · obtain ⟨c, ps, hp⟩ := hw.curPrizes hn
    exact ⟨_, a, .knockOut ho hka hp, .knockOut ho hka hp, hka,
      .inl ⟨.inl ho, takePrizes_length _ _, rfl⟩⟩
  rcases active_split g.cur.active with ⟨b, hc, hkb⟩ | hca
  · obtain ⟨c, ps, hp⟩ := hw.oppPrizes hn
    exact ⟨_, b, .knockOutOwn hc hkb hp, .knockOutOwn hc hkb hp, hkb,
      .inr ⟨.inl hc, takePrizes_length _ _, rfl⟩⟩
  rcases bench_split g.opp.bench with ⟨b₁, q, b₂, e, hkq⟩ | hob
  · have hm : q ∈ g.opp.bench := by rw [e]; exact List.mem_append_right _ (.head _)
    obtain ⟨c, ps, hp⟩ := hw.curPrizes hn
    exact ⟨_, q, .knockOutBench e hkq hp, .knockOutBench e hkq hp, hkq,
      .inl ⟨.inr hm, takePrizes_length _ _, rfl⟩⟩
  rcases bench_split g.cur.bench with ⟨b₁, q, b₂, e, hkq⟩ | hcb
  · have hm : q ∈ g.cur.bench := by rw [e]; exact List.mem_append_right _ (.head _)
    obtain ⟨c, ps, hp⟩ := hw.oppPrizes hn
    exact ⟨_, q, .knockOutBenchOwn e hkq hp, .knockOutBenchOwn e hkq hp, hkq,
      .inr ⟨.inr hm, takePrizes_length _ _, rfl⟩⟩
  refine absurd (fun p hp => ?_) hk
  rcases hp with hp | hp | hp | hp
  · exact hca p hp
  · exact hcb p hp
  · exact hoa p hp
  · exact hob p hp

/-- **A pending Knock Out can be taken**, for play: from a well-formed start, every reachable
state with no winner and a pending Knock Out has a Knock Out move of a Pokémon in play at or
above its HP, whose taker's Prize list shrinks by exactly that Pokémon's Prize count or all that
are left, as in `Move.knockOut_of_pending` (statement changed by milestone M3, see there). -/
theorem Reach.knockOut_of_pending {g₀ g : GameState} (h₀ : WellFormed g₀) (h : Reach g₀ g)
    (hn : g.winner = none) (hk : ¬ DamageBounded g) :
    ∃ (g' : GameState) (x : InPlay), Move g g' ∧ KOMove g g' ∧ x.top.hp ≤ x.damage ∧
      (((g.opp.active = some x ∨ x ∈ g.opp.bench) ∧
          g'.cur.prizes.length + min x.top.prizeCount g.cur.prizes.length =
            g.cur.prizes.length ∧ g'.opp.prizes = g.opp.prizes) ∨
        ((g.cur.active = some x ∨ x ∈ g.cur.bench) ∧
          g'.opp.prizes.length + min x.top.prizeCount g.opp.prizes.length =
            g.opp.prizes.length ∧ g'.cur.prizes = g.cur.prizes)) :=
  Move.knockOut_of_pending (h.wellFormed h₀) hn hk

/-- Whether a Knock Out is pending is decided by looking at the Pokémon in play (no choice
principle is used). -/
theorem damageBounded_or_pending (g : GameState) : DamageBounded g ∨ ¬ DamageBounded g := by
  rcases active_split g.cur.active with ⟨a, ha, hka⟩ | hca
  · exact .inr fun hk => absurd (hk a (Or.inl ha)) (Nat.not_lt.2 hka)
  rcases active_split g.opp.active with ⟨a, ha, hka⟩ | hoa
  · exact .inr fun hk => absurd (hk a (Or.inr (Or.inr (Or.inl ha)))) (Nat.not_lt.2 hka)
  rcases bench_split g.cur.bench with ⟨b₁, q, b₂, e, hkq⟩ | hcb
  · have hm : q ∈ g.cur.bench := by rw [e]; exact List.mem_append_right _ (.head _)
    exact .inr fun hk => absurd (hk q (Or.inr (Or.inl hm))) (Nat.not_lt.2 hkq)
  rcases bench_split g.opp.bench with ⟨b₁, q, b₂, e, hkq⟩ | hob
  · have hm : q ∈ g.opp.bench := by rw [e]; exact List.mem_append_right _ (.head _)
    exact .inr fun hk => absurd (hk q (Or.inr (Or.inr (Or.inr hm)))) (Nat.not_lt.2 hkq)
  refine .inl fun p hp => ?_
  rcases hp with hp | hp | hp | hp
  · exact hca p hp
  · exact hcb p hp
  · exact hoa p hp
  · exact hob p hp

/-- **No deadlock.** In a well-formed state with no winner, some move is legal: a promotion or
a loss if an Active Spot is empty; a Knock Out (of an Active or a Benched Pokémon) if one is
pending; otherwise the end of the turn, or between turns the draw (or a loss by decking out). -/
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
  rcases damageBounded_or_pending g with hk | hk
  · match hbt : g.between with
    | false => exact ⟨_, .endTurn false false false false false false ho hc hk hbt
        (BenchChar.refl _) (BenchChar.refl _)⟩
    | true =>
        match hd : g.cur.deck with
        | [] => exact ⟨_, .deckOut hbt ho hc hk hd⟩
        | c :: d => exact ⟨_, .startTurn hbt ho hc hk hd⟩
  · obtain ⟨g', _, hm, -⟩ := Move.knockOut_of_pending hw hn hk
    exact ⟨g', hm⟩

/-- **No deadlock**, for play: from a well-formed start, every reachable state with no winner
has a legal move. -/
theorem Reach.progress {g₀ g : GameState} (h₀ : WellFormed g₀) (h : Reach g₀ g)
    (hn : g.winner = none) : ∃ g', Move g g' :=
  Move.progress (h.wellFormed h₀) hn

end Pokemon
