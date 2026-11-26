import Pokemon.Marks

/-!
# Well-formed states, and no deadlock

`WellFormed` (defined in `Rules`) asks that both players have Prize cards while there is no
winner, that every Benched Pokémon has no Special Condition (since milestone M3 a Benched
Pokémon may be at or above its HP: that is a pending Knock Out, excluded by `Settled`), and (since
the review of milestone MV7b) that the owed-trigger marks are as play leaves them
(`GameState.MarksOk`, `Pokemon/Marks.lean`).

* `Move.wellFormed`, `Reach.wellFormed`: legal play preserves it (the marks by `Move.marksOk`).
* `Move.exists_move`: every state has a legal move (no hypothesis); `Move.progress`,
  `Reach.progress`: from a well-formed state with no winner some move is legal. In particular a
  pending Knock Out can always be taken: the batch step exists from every state that is not
  `Settled` (`KOBatch.exists_of`).
* `Move.knockOut_of_pending`, `Reach.knockOut_of_pending`: with no winner and a pending Knock
  Out (as after Checkup or an attack), the batch Knock Out step is legal: it Knocks Out every
  Pokémon in play (Active or Benched, of either player) at or above its HP, and each player's
  Prize list loses its top cards, as many as the Prize value of the opponent's Knocked Out
  Pokémon (or all that are left).
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

/-- Marking a Pokémon that moved (milestone MV7c) keeps it `Benched`. -/
theorem Benched.noteMove {p : InPlay} (h : Benched p) (ev : TrigEvent) (sp : Spot) :
    Benched (p.noteMove ev sp) :=
  h.of_eq (InPlay.noteMove_rot ev sp p) (InPlay.noteMove_poisoned ev sp p)
    (InPlay.noteMove_burned ev sp p) (InPlay.noteMove_poisonUp ev sp p)

theorem Benched.noteDown {p : InPlay} (h : Benched p) (w : Whose) : Benched (w.noteDown p) := by
  cases w
  · exact h.noteMove _ _
  · exact h

/-- An update that keeps Special Conditions and Poison strength keeps a Bench `BenchOk`. -/
theorem BenchOk.map {b : List InPlay} {U : InPlay → InPlay} (hb : BenchOk b)
    (hU : ∀ q, Benched q → Benched (U q)) : BenchOk (b.map U) := by
  intro p hp
  obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
  exact hU q (hb q hq)

/-- Dealing Energy cards keeps every Benched Pokémon `Benched` (milestone MV6). -/
theorem Deal.benchOk {tf : Filter} {t : List Card} {a a' : Option InPlay} {b b' : List InPlay}
    (h : Deal tf t a b a' b') (hb : BenchOk b) : BenchOk b' := by
  induction h with
  | nil => exact hb
  | active _ _ _ ih => exact ih hb
  | @bench e xs a q b₁ b₂ a' b' ht _ _ ih =>
      exact ih (benched_update rfl hb ((hb q (List.mem_append_right _ (.head _))).of_eq
        rfl rfl rfl rfl))

/-- Placing the cards taken from a window keeps every Benched Pokémon `Benched` (milestone MV6). -/
theorem Place.benchOk {i : Into} {t : List Card} {s s' : PlayerState} (h : Place i t s s')
    (hb : BenchOk s.bench) : BenchOk s'.bench := by
  cases h with
  | put hp => rw [hp.fields.2.2]; exact hb
  | bench _ _ =>
      intro x hx
      rcases List.mem_append.1 hx with hx | hx
      · exact hb x hx
      · obtain ⟨p, _, rfl⟩ := List.mem_map.1 hx
        exact ⟨rfl, rfl, rfl, rfl⟩
  | attach hd => exact hd.benchOk hb

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
  | toolsActive => exact hb
  | @toolsBench w s p b₁ b₂ hb' =>
      exact benched_update hb' hb ((hb p (mem hb')).of_eq rfl rfl rfl rfl)
  | toolsNone => exact hb
  | @look w src f q i rest s s₁ s' t r hs hq hr hp =>
      refine hp.benchOk ?_
      rw [hr.fields.2.2, Src.set_bench]; exact hb
  | retActive _ _ _ hp => rw [hp.fields.2.2]; exact hb
  | @retBench w f q d s s' p b₁ b₂ t r hb' hs hq hp =>
      rw [hp.fields.2.2]
      exact benched_update hb' hb ((hb p (mem hb')).of_eq rfl rfl rfl rfl)
  | retNone => exact hb

/-- Moving a damage counter keeps every Benched Pokémon `Benched` (milestone M8a). -/
theorem CMove.benchOk {f : Filter} {noKO : Bool} {a a' : Option InPlay} {b b' : List InPlay}
    (h : CMove f noKO hp a b a' b') (hb : BenchOk b) : BenchOk b' := by
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
            | exact benched_update h hb (Benched.noteDown ⟨rfl, rfl, rfl, rfl⟩ _)
            | exact hb,
          fun hb => by
            first
            | exact benched_update h hb (Benched.noteDown ⟨rfl, rfl, rfl, rfl⟩ _)
            | exact hb.map fun q hq => hq.of_eq rfl rfl rfl rfl
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
  | benchSome w m f dmg n h =>
      have hq : ∀ x, Benched x → Benched (x.hitWith dmg n) := fun x hx => by
        cases dmg
        · exact hx.of_eq rfl rfl rfl rfl
        · obtain ⟨-, -, -, -, e1, e2, e3, e4, -⟩ := x.hitBench_fields n
          exact hx.of_eq e1 e2 e3 e4
      cases w <;>
        exact ⟨fun hb => by
            first
            | exact h.forall_of hq hb
            | exact hb,
          fun hb => by
            first
            | exact h.forall_of hq hb
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

theorem WellFormed.of_frame {g g' : GameState} (hw : WellFormed g) (hf : Run.Frame g g')
    (hm : g'.MarksOk) : WellFormed g' := by
  obtain ⟨f1, f2, f3, f4, f5, _, _⟩ := hf
  refine ⟨fun hn => ?_, f1 hw.2.1, f2 hw.2.2.1, hm⟩
  rw [f3, f4]; exact hw.1 (f5 ▸ hn)

/-- Clearing the record keeps the frame (milestone MV7b). -/
theorem Run.Frame.unpend (g : GameState) : Run.Frame g g.unpend :=
  ⟨fun hb => hb.map fun _ hq => hq.of_eq rfl rfl rfl rfl,
    fun hb => hb.map fun _ hq => hq.of_eq rfl rfl rfl rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- The frame of an effect's resolution seen from the other side (milestone M8b). -/
theorem Run.Frame.unswap {g g₁ : GameState} (h : Run.Frame g.swap g₁) : Run.Frame g g₁.swap := by
  obtain ⟨f1, f2, f3, f4, f5, f6, f7⟩ := h
  refine ⟨f2, f1, f4, f3, f5, ?_, f7⟩
  show (!g₁.curIsFirst) = g.curIsFirst
  rw [f6]; show (!!g.curIsFirst) = g.curIsFirst; rw [Bool.not_not]

theorem Run.Frame.trans {g₁ g₂ g₃ : GameState} (a : Run.Frame g₁ g₂) (b : Run.Frame g₂ g₃) :
    Run.Frame g₁ g₃ := by
  obtain ⟨a1, a2, a3, a4, a5, a6, a7⟩ := a
  obtain ⟨b1, b2, b3, b4, b5, b6, b7⟩ := b
  exact ⟨fun h => b1 (a1 h), fun h => b2 (a2 h), b3.trans a3, b4.trans a4, b5.trans a5,
    b6.trans a6, b7.trans a7⟩

/-- **A trigger resolution keeps the Benches as the rules leave them, the Prize cards and the
outcome** (milestone M8b). -/
theorem Fire.frame {ev : TrigEvent} {l : List Ability} {g g' : GameState} (h : Fire ev l g g') :
    Run.Frame g g' := by
  induction h with
  | nil => exact ⟨id, id, rfl, rfl, rfl, rfl, rfl⟩
  | run _ hr _ ih => exact hr.frame.unswap.trans ih
  | decline _ _ ih => exact ih

/-- The player to move's own triggers (milestone MV7c) keep the frame. -/
theorem FireMine.frame {u d : List Ability} {g g' : GameState} (h : FireMine u d g g') :
    Run.Frame g g' := by
  obtain ⟨g₁, g₂, h₁, h₂, rfl⟩ := h
  exact (h₁.frame.trans h₂.frame).unswap

/-- **The resolution of the owed triggers keeps the frame** of the state with the record cleared
(milestone MV7c). -/
theorem Owed.frame {g g' : GameState} (h : Owed g g') : Run.Frame g.unpend g' := by
  cases h with
  | mineFirst _ _ _ hm ht => exact hm.frame.trans ht.frame
  | oppFirst _ _ _ ht hm => exact ht.frame.trans hm.frame

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

/-! ## The batch Knock Out step: outcome, well-formedness, existence -/

/-- No outcome only when neither player wins in any way. -/
theorem Outcome.ofWays_eq_none {b : Bool} {wc wo : Nat} (h : Outcome.ofWays b wc wo = none) :
    wc = 0 ∧ wo = 0 := by
  unfold Outcome.ofWays at h
  split at h
  · next e =>
      split at h
      · next e0 => exact ⟨e0, e ▸ e0⟩
      · cases h
  · split at h <;> cases h

/-- No way of winning: no last Prize card taken, and the opponent has a Pokémon in play. -/
theorem winWays_eq_zero {n : Nat} {taker other : PlayerState} (h : winWays n taker other = 0) :
    taker.prizeWin n = false ∧ other.noPokemon = false := by
  unfold winWays at h
  refine ⟨?_, ?_⟩
  · cases e : taker.prizeWin n
    · rfl
    · simp [e] at h
  · cases e : other.noPokemon
    · rfl
    · simp [e] at h

/-- The check of a game that is over leaves it over, with the same outcome. -/
theorem GameState.koStep_winner_of_some {g : GameState} {o : Outcome} (h : g.winner = some o) :
    g.koStep.winner = some o := by
  simp only [GameState.koStep, h]

/-- A check with no outcome: neither player wins in any way. -/
theorem GameState.koStep_winner_none {g : GameState} (h : g.koStep.winner = none) :
    g.winner = none ∧ winWays (g.koVal .opp) g.cur (g.koOf .opp) = 0 ∧
      winWays (g.koVal .own) g.opp (g.koOf .own) = 0 := by
  cases hn : g.winner with
  | some o => rw [g.koStep_winner_of_some hn] at h; cases h
  | none =>
      simp only [GameState.koStep, hn] at h
      exact ⟨rfl, Outcome.ofWays_eq_none h⟩

/-- A player who still has Prize cards and has not taken their last one has Prize cards left. -/
theorem prizes_of_not_prizeWin {n : Nat} {s : PlayerState} (hp : s.prizes ≠ [])
    (h : s.prizeWin n = false) : (s.takePrizes n).prizes ≠ [] := by
  cases n with
  | zero => simpa [PlayerState.takePrizes] using hp
  | succ n =>
      have ho : s.prizesOut (n + 1) = false := by
        simpa [PlayerState.prizeWin] using h
      exact prizes_of_not_out ho

/-- A promotion keeps every Benched Pokémon `Benched`. -/
theorem Promote.benchOk {a a' : Option InPlay} {b b' : List InPlay} (h : Promote a b a' b')
    (hb : BenchOk b) : BenchOk b' := by
  cases h with
  | keep => exact hb
  | pick => exact fun p hp => hb p (mem_append_cons_of_mem _ hp)

/-- The check keeps every Benched Pokémon `Benched`: the Bench only loses Pokémon. -/
theorem PlayerState.koOut_benchOk {ta tb : InPlay → Bool} {s : PlayerState} (hb : BenchOk s.bench) :
    BenchOk (s.koOut ta tb).bench :=
  fun p hp => hb p (List.mem_filter.1 hp).1

/-- **The batch Knock Out step preserves well-formedness**: a player who has not won still has
Prize cards, and the Benches only lose Pokémon. -/
theorem KOBatch.wellFormed {g g' : GameState} (h : KOBatch g g') (hw : WellFormed g) :
    WellFormed g' := by
  have hbc : BenchOk g.koStep.cur.bench :=
    PlayerState.koOut_benchOk (ta := g.koT .own .active) (tb := g.koT .own .bench) hw.2.1
  have hbo : BenchOk g.koStep.opp.bench :=
    PlayerState.koOut_benchOk (ta := g.koT .opp .active) (tb := g.koT .opp .bench) hw.2.2.1
  have hm := h.marksOk hw.2.2.2
  cases h with
  | won _ hk => exact ⟨fun hn => absurd hn hk, hbc, hbo, hm⟩
  | go _ hk hc ho =>
      obtain ⟨hn, h1, h2⟩ := GameState.koStep_winner_none hk
      have hp := hw.1 hn
      refine ⟨fun _ => ⟨?_, ?_⟩, hc.benchOk hbc, ho.benchOk hbo, hm⟩
      · exact prizes_of_not_prizeWin (s := g.koOf .own) hp.1 (winWays_eq_zero h1).1
      · exact prizes_of_not_prizeWin (s := g.koOf .opp) hp.2 (winWays_eq_zero h2).1

/-- A player with a Pokémon in play can fill their Active Spot. -/
theorem Promote.exists_of {a : Option InPlay} {b : List InPlay}
    (h : (a.isNone && b.isEmpty) = false) : ∃ a' b', Promote a b a' b' := by
  cases a with
  | some p => exact ⟨_, _, .keep⟩
  | none =>
      cases b with
      | nil => simp at h
      | cons q qs => exact ⟨_, _, .pick (b₁ := [])⟩

/-- After a batch step with no outcome both Active Spots are filled (milestone M8b). -/
theorem KOBatch.bothActive {g g₁ : GameState} (h : KOBatch g g₁) (hw : g₁.winner = none) :
    g₁.BothActive := by
  cases h with
  | won _ hk => exact absurd hw hk
  | go _ _ hc ho =>
      have e : ∀ {a b a' b'}, Promote a b a' b' → a'.isSome = true := by
        intro a b a' b' hp; cases hp <;> rfl
      have ep : ∀ (o : Option InPlay), o.isSome = true →
          Option.isSome (if g.promoUp then o.map (InPlay.noteMove .movedUp .active) else o) = true :=
        fun o h => by split <;> simp_all
      exact ⟨ep _ (e hc), e ho⟩

/-- **The triggers of a batch step can always be resolved** (milestone M8b): every batch step is
followed by some resolution of the triggers it fires, so the batch move exists whenever the step
does. -/
theorem KOBatch.trigs_exist {g g₁ : GameState} (h : KOBatch g g₁) :
    ∃ g' l, l.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack l g₁ g' := by
  cases hw : g₁.winner with
  | some o =>
      refine ⟨g₁, [], ?_, .nil _⟩
      rw [GameState.batchTrigs_of_won (by rw [hw]; exact fun e => nomatch e)]
  | none =>
      obtain ⟨g', ht⟩ := Fire.exists (l := g.batchTrigs g₁)
        (fun _ hab => GameState.batchTrigs_trigOk hab) (h.bothActive hw)
      exact ⟨g', _, .refl _, ht⟩

/-- **A batch Knock Out step exists** from every state that is not `Calm` (before milestone MV7:
`Settled`, which meant the same) and has no trigger ready to resolve (`hq`, milestone MV7; a pending
trigger resolves first): the check, and, if
nobody wins, a promotion for each player with an empty Active Spot (who has a Benched Pokémon,
since otherwise the opponent would win). -/
theorem KOBatch.exists_of {g : GameState} (hu : ¬ Calm g)
    (hq : g.pend = false ∨ ¬ g.BothActive := by first | exact .inl rfl | assumption) :
    ∃ g', KOBatch g g' := by
  cases hw : g.koStep.winner with
  | some o => exact ⟨_, .won hu (by rw [hw]; exact fun h => nomatch h) hq⟩
  | none =>
      obtain ⟨_, h1, h2⟩ := GameState.koStep_winner_none hw
      obtain ⟨ac, bc, hc⟩ := Promote.exists_of (a := g.koStep.cur.active) (b := g.koStep.cur.bench)
        (winWays_eq_zero h2).2
      obtain ⟨ao, bo, ho⟩ := Promote.exists_of (a := g.koStep.opp.active) (b := g.koStep.opp.bench)
        (winWays_eq_zero h1).2
      exact ⟨_, .go hu hw hc ho hq⟩

theorem Resolve.wellFormed {g g' : GameState} (h : Resolve g g') (hw : WellFormed g) :
    WellFormed g' := by
  induction h with
  | done => exact hw
  | step _ hm _ ih => exact ih (hm.wellFormed hw)
  | trigger _ _ _ ho _ ih =>
      exact ih (WellFormed.of_frame hw ((Run.Frame.unpend _).trans ho.frame) ho.marksOk)

/-- Resolving a Trainer card's effect, Knock Outs included, preserves well-formedness. -/
theorem TRun.wellFormed {e : Effect} {g g' : GameState} (h : TRun e g g') (hw : WellFormed g) :
    WellFormed g' := by
  induction h with
  | prim _ _ hr hk => exact hk.wellFormed (WellFormed.of_frame hw hr.frame (hr.marksOk hw.2.2.2))
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
  | trigger _ _ _ _ _ ih => exact ih

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
  have hsv : x.markUsed.sv = x.sv := rfl
  cases h with
  | active ha =>
      have hsf : GameState.SameField g { g with cur := { g.cur with active := some x.markUsed } } :=
        ⟨by simp only [PlayerState.field, fieldOf, ha, hsv], rfl, rfl, rfl⟩
      refine ⟨fun w sp p hp => ?_, by simp, h2⟩
      rw [hsf.hpOf w sp rfl]
      cases w <;> cases sp
      · simp only [GameState.In, GameState.side, Option.some.injEq] at hp
        subst hp; exact hk .own .active x ha
      · exact hk .own .bench p hp
      · exact hk .opp .active p hp
      · exact hk .opp .bench p hp
  | @bench b₁ b₂ hb =>
      have hsf : GameState.SameField g
          { g with cur := { g.cur with bench := b₁ ++ x.markUsed :: b₂ } } :=
        ⟨by simp only [PlayerState.field, fieldOf, hb, List.map_append, List.map_cons, hsv], rfl,
          rfl, rfl⟩
      refine ⟨fun w sp p hp => ?_, h1, h2⟩
      rw [hsf.hpOf w sp rfl]
      cases w <;> cases sp
      · exact hk .own .active p hp
      · simp only [GameState.In, GameState.side] at hp
        rcases List.mem_append.1 hp with hp | hp
        · exact hk .own .bench p (by show p ∈ g.cur.bench; rw [hb]; exact List.mem_append_left _ hp)
        · cases hp with
          | head => exact hk .own .bench x (by show x ∈ g.cur.bench; rw [hb]; exact List.mem_append_right _ (.head _))
          | tail _ hp =>
              exact hk .own .bench p (by show p ∈ g.cur.bench; rw [hb]; exact List.mem_append_right _ (.tail _ hp))
      · exact hk .opp .active p hp
      · exact hk .opp .bench p hp

/-- Marking a Pokémon as having used an Ability keeps well-formedness (milestone M8a). -/
theorem UseAt.wellFormed {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁)
    (hw : WellFormed g) : WellFormed g₁ := by
  have hm := h.marksOk hw.2.2.2
  cases h with
  | active ha => exact ⟨hw.1, hw.2.1, hw.2.2.1, hm⟩
  | bench hb =>
      exact ⟨hw.1, benched_update hb hw.2.1 (let h := hw.2.1 x (hb ▸ List.mem_append_right _
        (.head _)); ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩), hw.2.2.1, hm⟩

/-- A play from the hand keeps well-formedness (milestone M8a). -/
theorem PlayFromHand.wellFormed {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) (hw : WellFormed g) : WellFormed g₁ := by
  have hm := h.marksOk hw.2.2.2
  cases h with
  | basic hh hs hhp hb =>
      refine ⟨hw.1, fun p hp => ?_, hw.2.2.1, hm⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p hp
      · rw [List.mem_singleton] at hp; subst hp
        exact ⟨rfl, rfl, rfl, rfl⟩
  | evolve => exact ⟨hw.1, hw.2.1, hw.2.2.1, hm⟩
  | evolveBench hh hb => exact ⟨hw.1, benched_update hb hw.2.1 ⟨rfl, rfl, rfl, rfl⟩, hw.2.2.1, hm⟩

/-- Legal play preserves well-formedness. -/
theorem Move.wellFormed {g g' : GameState} (h : Move g g') (hw : WellFormed g) :
    WellFormed g' := by
  have hm := h.marksOk hw.2.2.2
  cases h with
  | playBasic hh hs hhp hb =>
      refine ⟨hw.1, fun p hp => ?_, hw.2.2.1, hm⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p hp
      · rw [List.mem_singleton] at hp; subst hp
        exact ⟨rfl, rfl, rfl, rfl⟩
  | attach hh hf ha => exact ⟨hw.1, hw.2.1, hw.2.2.1, hm⟩
  | evolve hh ha he hfr hf => exact ⟨hw.1, hw.2.1, hw.2.2.1, hm⟩
  | @attachBench l₁ l₂ t q b₁ b₂ hh hf hb =>
      exact ⟨hw.1, benched_update hb hw.2.1 (let h := hw.2.1 q (hb ▸ List.mem_append_right _
        (.head _)); ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩), hw.2.2.1, hm⟩
  | evolveBench hh hb => exact ⟨hw.1, benched_update hb hw.2.1 ⟨rfl, rfl, rfl, rfl⟩, hw.2.2.1, hm⟩
  | retreat ha hb hr he hp hs hbt hst hl hat =>
      rename_i a q b₁ b₂ _ _
      refine ⟨hw.1, fun p hp => ?_, BenchOk.map hw.2.2.1 fun _ hq => hq.of_eq rfl rfl rfl rfl, hm⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hw.2.1 p (by rw [hb]; exact List.mem_append_left _ hp)
      · cases hp with
        | head => exact Benched.noteMove ⟨rfl, rfl, rfl, rfl⟩ _ _
        | tail _ hp =>
            exact hw.2.1 p (by rw [hb]; exact List.mem_append_right _ (.tail _ hp))
  | item hh hbt hst hr => exact hr.wellFormed ⟨hw.1, hw.2.1, hw.2.2.1, hw.2.2.2⟩
  | supporter hh hs hbt hst hr => exact hr.wellFormed ⟨hw.1, hw.2.1, hw.2.2.1, hw.2.2.2⟩
  | stadiumUse _ _ _ _ _ hr => exact hr.wellFormed hw
  | stadium => exact ⟨hw.1, hw.2.1, hw.2.2.1, hm⟩
  | tool => exact ⟨hw.1, hw.2.1, hw.2.2.1, hm⟩
  | @toolBench l₁ l₂ n gr q b₁ b₂ hh hb =>
      exact ⟨hw.1, benched_update hb hw.2.1 (let h := hw.2.1 q (hb ▸ List.mem_append_right _
        (.head _)); ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩), hw.2.2.1, hm⟩
  | ability hu _ _ _ _ _ _ _ _ hr => exact hr.wellFormed (hu.wellFormed hw)
  | onPlay hp _ _ _ _ _ hr => exact hr.wellFormed (hp.wellFormed hw)
  | attack ha hm' hc hs hn hf hbt hst hr _ _ _ _ ht =>
      have h1 := WellFormed.of_frame (WellFormed.of_frame hw hr.frame (hr.marksOk hw.2.2.2)) ht.frame
        (ht.marksOk (hr.marksOk hw.2.2.2))
      exact ⟨h1.1, h1.2.1, h1.2.2.1, hm⟩
  | attackConfused ha hm' hc hs hn hf => exact ⟨hw.1, hw.2.1, hw.2.2.1, hm⟩
  | knockOuts h _ ht => exact WellFormed.of_frame (h.wellFormed hw) ht.frame hm
  | trigger _ _ ho => exact WellFormed.of_frame hw ((Run.Frame.unpend _).trans ho.frame) hm
  | endTurn fa sa ca fb sb cb ha hb hk hbt hco hcc =>
      refine ⟨fun hn => ⟨(hw.1 hn).2, (hw.1 hn).1⟩, hco.benched hw.2.2.1, hcc.benched ?_, hm⟩
      intro p hp
      obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
      exact hw.2.1 q hq
  | startTurn hbt ha hb hk hd => exact ⟨hw.1, hw.2.1, hw.2.2.1, hm⟩
  | deckOut hbt ha hb hk hd => exact ⟨fun hn => by simp at hn, hw.2.1, hw.2.2.1, hm⟩

/-- Legal play from a well-formed state stays well formed. -/
theorem Reach.wellFormed {g₀ g : GameState} (h₀ : WellFormed g₀) (h : Reach g₀ g) :
    WellFormed g := by
  induction h with
  | refl => exact h₀
  | step _ _ hm ih => exact hm.wellFormed ih

/-- An Active spot is empty, holds a Pokémon below its HP `H`, or holds one at or above it
(milestone M6: `H` is any function, the derived HP of the state). -/
theorem active_split (H : InPlay → Nat) (o : Option InPlay) :
    (∃ a, o = some a ∧ H a ≤ a.damage) ∨ ∀ a, o = some a → a.damage < H a := by
  cases o with
  | none => exact .inr fun _ h => by cases h
  | some a =>
      rcases Nat.lt_or_ge a.damage (H a) with h | h
      · exact .inr fun a' h' => by cases h'; exact h
      · exact .inl ⟨a, rfl, h⟩

/-- A Bench has a Pokémon at or above its HP `H`, or every Pokémon on it is below it. -/
theorem bench_split (H : InPlay → Nat) : ∀ l : List InPlay,
    (∃ b₁ p b₂, l = b₁ ++ p :: b₂ ∧ H p ≤ p.damage) ∨ ∀ p ∈ l, p.damage < H p
  | [] => .inr fun _ h => nomatch h
  | q :: qs => by
      rcases Nat.lt_or_ge q.damage (H q) with h | h
      · rcases bench_split H qs with ⟨b₁, p, b₂, e, hk⟩ | hall
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

theorem optFilter_eq_some {t : InPlay → Bool} {o : Option InPlay} {x : InPlay}
    (h : optFilter t o = some x) : o = some x ∧ t x = true := by
  cases o with
  | none => cases h
  | some p =>
      simp only [optFilter] at h
      split at h
      · next ht => cases h; exact ⟨rfl, ht⟩
      · cases h

/-- **What survives the check**: a Pokémon in play after the check was in play at the same place
before it, below its HP there. -/
theorem GameState.koStep_survivor {g : GameState} {w : Whose} {sp : Spot} {x : InPlay}
    (h : g.koStep.In w sp x) : g.In w sp x ∧ x.damage < g.hpOf w sp x := by
  have key : ∀ (s : PlayerState) (sp : Spot) (ta tb : InPlay → Bool),
      (match sp with
        | .active => (s.koOut ta tb).active = some x
        | .bench => x ∈ (s.koOut ta tb).bench) →
      (match sp with
        | .active => s.active = some x ∧ ta x = false
        | .bench => x ∈ s.bench ∧ tb x = false) := by
    intro s sp ta tb hx
    cases sp with
    | active =>
        obtain ⟨h1, h2⟩ := optFilter_eq_some hx
        exact ⟨h1, by simpa using h2⟩
    | bench =>
        obtain ⟨h1, h2⟩ := List.mem_filter.1 hx
        exact ⟨h1, by simpa using h2⟩
  have hlt : ∀ {w sp}, g.koT w sp x = false → x.damage < g.hpOf w sp x := fun e => by
    simp only [GameState.koT, decide_eq_false_iff_not, Nat.not_le] at e; exact e
  cases w <;> cases sp
  · obtain ⟨h1, h2⟩ := key g.cur .active (g.koT .own .active) (g.koT .own .bench) h
    exact ⟨h1, hlt h2⟩
  · obtain ⟨h1, h2⟩ := key g.cur .bench (g.koT .own .active) (g.koT .own .bench) h
    exact ⟨h1, hlt h2⟩
  · obtain ⟨h1, h2⟩ := key g.opp .active (g.koT .opp .active) (g.koT .opp .bench) h
    exact ⟨h1, hlt h2⟩
  · obtain ⟨h1, h2⟩ := key g.opp .bench (g.koT .opp .active) (g.koT .opp .bench) h
    exact ⟨h1, hlt h2⟩

/-- A promotion takes the new Active Pokémon from the Bench, and the Bench only loses Pokémon. -/
theorem Promote.mem {a a' : Option InPlay} {b b' : List InPlay} (h : Promote a b a' b') :
    (∀ x, a' = some x → a = some x ∨ x ∈ b) ∧ ∀ x ∈ b', x ∈ b := by
  cases h with
  | keep => exact ⟨fun x hx => .inl hx, fun x hx => hx⟩
  | pick =>
      refine ⟨fun x hx => .inr ?_, fun x hx => mem_append_cons_of_mem _ hx⟩
      cases hx; exact List.mem_append_right _ (.head _)

/-- **What survives a batch Knock Out step**: every Pokémon in play afterwards was in play before
it, below its HP at some place it then held (its own place, or the Bench for a promoted Pokémon),
up to the owed-trigger mark of the player to move's promoted Pokémon (milestone MV7c: a promotion in
the owner's own turn raises the `movedUp` event, `InPlay.noteMove`, which changes only the mark and
the `used` flag). No Pokémon at or above its HP at its place survives the check, and in particular
none is rescued by a promotion. (Milestone MV7c changed the statement: the survivor `x` is the
Pokémon `x₀` of the state before, or `x₀` marked.) -/
theorem KOBatch.survivor {g g' : GameState} (h : KOBatch g g') {w : Whose} {sp : Spot} {x : InPlay}
    (hx : g'.In w sp x) : ∃ sp₀ x₀, g.In w sp₀ x₀ ∧ x₀.damage < g.hpOf w sp₀ x₀ ∧
      (x = x₀ ∨ x = x₀.noteMove .movedUp .active) := by
  cases h with
  | won => exact ⟨sp, x, (g.koStep_survivor hx).1, (g.koStep_survivor hx).2, .inl rfl⟩
  | @go ac ao bc bo _ _ hc ho =>
      have to : ∀ sp₀ x₀, g.koStep.In w sp₀ x₀ → (x = x₀ ∨ x = x₀.noteMove .movedUp .active) →
          ∃ sp₀ x₀, g.In w sp₀ x₀ ∧ x₀.damage < g.hpOf w sp₀ x₀ ∧
            (x = x₀ ∨ x = x₀.noteMove .movedUp .active) :=
        fun sp₀ x₀ h e => ⟨sp₀, x₀, (g.koStep_survivor h).1, (g.koStep_survivor h).2, e⟩
      cases w <;> cases sp
      · have hx' : (if g.promoUp then ac.map (InPlay.noteMove .movedUp .active) else ac) = some x := hx
        split at hx'
        · cases hac : ac with
          | none => rw [hac] at hx'; cases hx'
          | some x₀ =>
              rw [hac] at hx' hc
              cases hx'
              rcases hc.mem.1 x₀ rfl with e | e
              · exact to .active x₀ e (.inr rfl)
              · exact to .bench x₀ e (.inr rfl)
        · rcases hc.mem.1 x hx' with e | e
          · exact to .active x e (.inl rfl)
          · exact to .bench x e (.inl rfl)
      · exact to .bench x (hc.mem.2 x hx) (.inl rfl)
      · rcases ho.mem.1 x hx with e | e
        · exact to .active x e (.inl rfl)
        · exact to .bench x e (.inl rfl)
      · exact to .bench x (ho.mem.2 x hx) (.inl rfl)

/-- The Prize cards and discard piles after a batch Knock Out step are those of the check. -/
theorem KOBatch.piles {g g' : GameState} (h : KOBatch g g') :
    g'.cur.prizes = g.koStep.cur.prizes ∧ g'.opp.prizes = g.koStep.opp.prizes ∧
      g'.cur.discard = g.koStep.cur.discard ∧ g'.opp.discard = g.koStep.opp.discard ∧
      g'.winner = g.koStep.winner := by
  cases h <;> exact ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem optPrizes_filter_eq_zero {t : InPlay → Bool} {o : Option InPlay}
    (h : optPrizes (optFilter t o) = 0) : ∀ p, o = some p → t p = false := by
  intro p hp
  subst hp
  cases e : t p
  · rfl
  · have := p.top.prizeCount_pos
    simp [optFilter, e, optPrizes] at h; omega

theorem benchPrizes_filter_eq_zero {t : InPlay → Bool} :
    ∀ {b : List InPlay}, benchPrizes (b.filter t) = 0 → ∀ p ∈ b, t p = false
  | [], _ => fun _ h => nomatch h
  | q :: qs, h => by
      have hq := q.top.prizeCount_pos
      cases e : t q
      · simp only [List.filter_cons, e, Bool.false_eq_true, ite_false] at h
        intro p hp
        cases hp with
        | head => exact e
        | tail _ hp => exact benchPrizes_filter_eq_zero h p hp
      · simp only [List.filter_cons, e, ite_true, benchPrizes] at h
        omega

/-- With nothing to Knock Out on a side, its Prize value is 0, and conversely a side with Prize
value 0 has no Pokémon at or above its HP. -/
theorem GameState.koVal_eq_zero {g : GameState} {w : Whose} (h : g.koVal w = 0) :
    ∀ sp p, g.In w sp p → p.damage < g.hpOf w sp p := by
  have h1 : optPrizes (optFilter (g.koT w .active) (g.side w).active) = 0 := by
    simp only [GameState.koVal, PlayerState.koValue] at h; omega
  have h2 : benchPrizes ((g.side w).bench.filter (g.koT w .bench)) = 0 := by
    simp only [GameState.koVal, PlayerState.koValue] at h; omega
  intro sp p hp
  have e : g.koT w sp p = false := by
    cases sp
    · exact optPrizes_filter_eq_zero h1 p hp
    · exact benchPrizes_filter_eq_zero h2 p hp
  simpa [GameState.koT] using e

/-- **A pending Knock Out is taken by the batch step.** In a well-formed state with no winner and
a pending Knock Out (for instance between turns, after Checkup, or after an attack that damaged a
Benched Pokémon), the batch Knock Out step is legal. It Knocks Out every Pokémon in play at or
above its HP, of both players, at least one Prize card's worth (`0 < koVal .own + koVal .opp`);
each player's Prize list loses its top cards, as many as the Prize value of the opponent's Knocked
Out Pokémon (`koVal`: 1 for each, 2 for a Pokémon ex, 3 for a Mega Evolution Pokémon ex, added up),
or all that are left (`List.drop`; so its length shrinks by exactly that value, or to 0,
`takePrizes_length`); each player's discard pile is the check's (`koOf`: the Knocked Out Pokémon
with every card attached on top of the old pile); and every Pokémon in play afterwards was below
its HP in the state before the step (at the place it then held). It need not be below its HP
afterwards: a removal or a promotion can lower derived HP, and the check then repeats
(`KOBatch`).

Milestone M3 changed the statement (exact Prize count of one Pokémon instead of one Prize card).
Milestone batch-KO changed it again. Before it the move Knocked Out one Pokémon `x` at or above
its HP, which the statement named; the taker's Prize list shrank by `min x.top.prizeCount` cards (a
statement about lengths) and the other player's Prize list was unchanged (an equality of lists).
The step now Knocks Out every pending Pokémon at once, and the statement names none of them; it
gives both players' Prize lists, each the old list with its top `koVal` cards dropped. When exactly
one Pokémon is pending, one `koVal` is its Prize value and the other is 0 (`drop 0`: that list is
unchanged), which gives the old Prize conclusions, but not the old statement, which named the
Pokémon. Milestone M8b changed it once more: the move is the batch step `g₁` followed by the
`koByAttack` triggers it fires (`Fire`, from `g₁` to the move's result `g'`; none before the turn's
attack, and then `g' = g₁`); the conclusions about Prize cards, discard piles and survivors are
about the batch step `g₁`, as before. The hypotheses `WellFormed g` and `g.winner = none` are
no longer used (the old moves needed the taker to have a Prize card left); the statement keeps
them. Milestone MV7 added the hypothesis `g.pend = false`: a pending trigger resolves before the
Knock Out check (`Move.trigger`), so from a state with one pending the batch step is not a move.
Milestone MV7c changed the survivors' conjunct: a survivor is a Pokémon of the state before, or (the
player to move's Pokémon promoted in their own turn) that Pokémon with its `movedUp` mark
(`KOBatch.survivor`). -/
theorem Move.knockOut_of_pending {g : GameState} (_hw : WellFormed g) (_hn : g.winner = none)
    (hk : ¬ DamageBounded g) (hpd : g.pend = false) :
    ∃ g₁ g', Move g g' ∧ KOBatch g g₁ ∧
      (∃ l, l.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack l g₁ g') ∧ (g.attacked = false → g' = g₁) ∧
      0 < g.koVal .own + g.koVal .opp ∧
      g₁.cur.prizes = g.cur.prizes.drop (g.koVal .opp) ∧
      g₁.opp.prizes = g.opp.prizes.drop (g.koVal .own) ∧
      g₁.cur.discard = (g.koOf .own).discard ∧ g₁.opp.discard = (g.koOf .opp).discard ∧
      (∀ w sp x, g₁.In w sp x → ∃ sp₀ x₀, g.In w sp₀ x₀ ∧ x₀.damage < g.hpOf w sp₀ x₀ ∧
        (x = x₀ ∨ x = x₀.noteMove .movedUp .active)) := by
  obtain ⟨g₁, hb⟩ := KOBatch.exists_of (fun hs => hk hs.1) (.inl hpd)
  obtain ⟨p1, p2, d1, d2, -⟩ := hb.piles
  obtain ⟨g', l, hl, ht⟩ := hb.trigs_exist
  refine ⟨g₁, g', .knockOuts hb hl ht, hb, ⟨l, hl, ht⟩,
    fun ha => Move.eq_of_batchTrigs_nil hl ht (GameState.batchTrigs_of_not_attacked ha), ?_, ?_, ?_,
    d1, d2, fun w sp x hx => hb.survivor hx⟩
  · apply Nat.pos_of_ne_zero
    intro h0
    have h1 : g.koVal .own = 0 := by omega
    have h2 : g.koVal .opp = 0 := by omega
    apply hk
    intro w sp p hp
    cases w
    · exact g.koVal_eq_zero h1 sp p hp
    · exact g.koVal_eq_zero h2 sp p hp
  · rw [p1]; rfl
  · rw [p2]; rfl

/-- **A pending Knock Out is taken by the batch step**, for play: from a well-formed start, every
reachable state with no winner and a pending Knock Out has the batch Knock Out step, with the Prize
lists, discard piles and survivors of `Move.knockOut_of_pending` (statement changed by milestones
M3 and batch-KO, see there; milestone MV7 added `g.pend = false`, see there). -/
theorem Reach.knockOut_of_pending {g₀ g : GameState} (h₀ : WellFormed g₀) (h : Reach g₀ g)
    (hn : g.winner = none) (hk : ¬ DamageBounded g) (hpd : g.pend = false) :
    ∃ g₁ g', Move g g' ∧ KOBatch g g₁ ∧
      (∃ l, l.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack l g₁ g') ∧ (g.attacked = false → g' = g₁) ∧
      0 < g.koVal .own + g.koVal .opp ∧
      g₁.cur.prizes = g.cur.prizes.drop (g.koVal .opp) ∧
      g₁.opp.prizes = g.opp.prizes.drop (g.koVal .own) ∧
      g₁.cur.discard = (g.koOf .own).discard ∧ g₁.opp.discard = (g.koOf .opp).discard ∧
      (∀ w sp x, g₁.In w sp x → ∃ sp₀ x₀, g.In w sp₀ x₀ ∧ x₀.damage < g.hpOf w sp₀ x₀ ∧
        (x = x₀ ∨ x = x₀.noteMove .movedUp .active)) :=
  Move.knockOut_of_pending (h.wellFormed h₀) hn hk hpd

/-- Whether a Knock Out is pending is decided by looking at the Pokémon in play (no choice
principle is used). -/
theorem damageBounded_or_pending (g : GameState) : DamageBounded g ∨ ¬ DamageBounded g := by
  rcases active_split (g.hpOf .own .active) g.cur.active with ⟨a, ha, hka⟩ | hca
  · exact .inr fun hk => absurd (hk .own .active a ha) (Nat.not_lt.2 hka)
  rcases active_split (g.hpOf .opp .active) g.opp.active with ⟨a, ha, hka⟩ | hoa
  · exact .inr fun hk => absurd (hk .opp .active a ha) (Nat.not_lt.2 hka)
  rcases bench_split (g.hpOf .own .bench) g.cur.bench with ⟨b₁, q, b₂, e, hkq⟩ | hcb
  · have hm : q ∈ g.cur.bench := by rw [e]; exact List.mem_append_right _ (.head _)
    exact .inr fun hk => absurd (hk .own .bench q hm) (Nat.not_lt.2 hkq)
  rcases bench_split (g.hpOf .opp .bench) g.opp.bench with ⟨b₁, q, b₂, e, hkq⟩ | hob
  · have hm : q ∈ g.opp.bench := by rw [e]; exact List.mem_append_right _ (.head _)
    exact .inr fun hk => absurd (hk .opp .bench q hm) (Nat.not_lt.2 hkq)
  refine .inl fun w sp p hp => ?_
  cases w <;> cases sp
  · exact hca p hp
  · exact hcb p hp
  · exact hoa p hp
  · exact hob p hp

/-- **No deadlock, in every state.** Every state has a legal move: (milestone MV7) the resolution
of a pending trigger if both Active Spots are filled (`Move.trigger`,
`GameState.BothActive.trigs_exist`); otherwise the batch Knock Out step if the
state is not `Calm` (a Pokémon in play at or above its HP, or an empty Active Spot; the step
exists in every such state, `KOBatch.exists_of`: if a player takes more Prize cards than remain
they win, a player with no Pokémon to promote loses, both at once give the rulebook's simultaneous
outcome, and otherwise every empty Active Spot is filled); otherwise the end of the turn, or
between turns the draw (or a loss by decking out). No hypothesis is needed (milestone batch-KO);
`Reach` makes no move once the game is over, so for play the statement that matters is
`Reach.progress`. -/
theorem Move.exists_move (g : GameState) : ∃ g', Move g g' := by
  by_cases hr : g.pend = true ∧ g.BothActive
  · obtain ⟨g', ht⟩ := hr.2.trigs_exist
    exact ⟨g', .trigger hr.2 hr.1 ht⟩
  have hq : g.pend = false ∨ ¬ g.BothActive := by
    cases hpd : g.pend with
    | false => exact .inl rfl
    | true => exact .inr fun hb => hr ⟨hpd, hb⟩
  by_cases hs : Calm g
  · have hpd : g.pend = false := by
      rcases hq with h | h
      · exact h
      · exact absurd hs.bothActive h
    obtain ⟨hk, hc, ho⟩ := hs
    match ha : g.opp.active, hb : g.cur.active with
    | none, _ => exact absurd ha ho
    | some _, none => exact absurd hb hc
    | some a, some b =>
        match hbt : g.between with
        | false => exact ⟨_, .endTurn false false false false false false ha hb hk hbt
            (BenchChar.refl _) (BenchChar.refl _) hpd⟩
        | true =>
            match hd : g.cur.deck with
            | [] => exact ⟨_, .deckOut hbt ha hb hk hd hpd⟩
            | c :: d => exact ⟨_, .startTurn hbt ha hb hk hd hpd⟩
  · obtain ⟨g₁, hm⟩ := KOBatch.exists_of hs hq
    obtain ⟨g', l, hl, ht⟩ := hm.trigs_exist
    exact ⟨g', .knockOuts hm hl ht⟩

/-- **No deadlock.** In a well-formed state with no winner, some move is legal (`Move.exists_move`,
which needs neither hypothesis). Since milestone batch-KO the proof uses neither hypothesis; the
statement keeps them. -/
theorem Move.progress {g : GameState} (_hw : WellFormed g) (_hn : g.winner = none) :
    ∃ g', Move g g' :=
  Move.exists_move g

/-- **No deadlock**, for play: from a well-formed start, every reachable state with no winner
has a legal move. -/
theorem Reach.progress {g₀ g : GameState} (h₀ : WellFormed g₀) (h : Reach g₀ g)
    (hn : g.winner = none) : ∃ g', Move g g' :=
  Move.progress (h.wellFormed h₀) hn

end Pokemon
