import Pokemon.WellFormed

/-!
# Damage and Poison strength: what is bounded, and a clamp that makes the rest bounded

Two numeric components of the state can be made large by legal play: damage (on the
opponent's Active Pokémon during a turn, `counters_unbounded`; on either Active Pokémon after
Checkup) and the Poison strength `poisonUp` of a Poisoned Pokémon (`poisonUp_unbounded`).
This file shows that the excess carries no information.

* `InPlay.clampWith c` caps `poisonUp` at the printed HP, and, when `c` is true, caps the
  damage at the HP too. `GameState.clamp` applies `clampWith true` to the OPPONENT'S Active
  Pokémon, and to the player's own Active Pokémon `clampWith g.between`: damage is capped
  there only between turns. Nothing else changes.
* `Run.clamp_sim` (during a turn), `Move.clamp_sim`, `Reach.clamp_sim`: states with the same
  clamp have the same moves, up to the same clamp. So the kernel of `clamp` is a (strong)
  bisimulation for `Move`, and every question about legal play that does not read the
  capped quantities above HP can be asked of the clamped states instead.
* `Reach.activeLe`: from a `DamageBounded`, `WellFormed` start, during every turn the player's
  own Active Pokémon has at most `maxHp g₀.allCards + 3` damage counters.
* `Move.damageBounded_of_startTurn`: the turn proper starts with no pending Knock Out.
  `Move.endTurn_pending_ko`: the earlier `Move.damageBounded_of_turn` is false with Checkup.

Why the clamp is sound. Poison strength is read only by Checkup, which adds it to damage, and
by nothing else (`poisonUp` effects add to it, curing resets it). Damage on the opponent's
Active Pokémon, and on either Active Pokémon between turns, is read only by the Knock Out
test `hp ≤ damage` and its negation (no effect heals the opponent, and no effect resolves
between turns). Both are threshold tests at HP, and `min (d + u) h` depends on `u` only through
`min u h`.

Why the player's own Active Pokémon keeps its exact damage during a turn. It can exceed its
HP then (after evolving into a card with less HP, or from Confusion), but `heal` reads its
damage exactly (`5 - 2 = 3 ≥ 3` while `min 5 3 - 2 = 1 < 3`), so clamping it would not be a
bisimulation. Its damage is instead bounded by `Reach.activeLe`: the turn starts with it below
HP, evolution keeps the damage, and Confusion adds 3 counters at most once per turn (it uses
the turn's attack). Checkup damage, which Croagunk can make arbitrarily large, lands only
between turns, where heal cannot run and the clamp caps it.
-/

namespace Pokemon

/-- Poison strength capped at the printed HP and, if `c`, damage capped at the printed HP. -/
def InPlay.clampWith (c : Bool) (p : InPlay) : InPlay :=
  { p with damage := if c then min p.damage p.top.hp else p.damage,
           poisonUp := min p.poisonUp p.top.hp }

/-- Cap the damage and the Poison strength on the opponent's Active Pokémon, and the Poison
strength on the player's own Active Pokémon, at the printed HP; between turns, cap the damage
on the player's own Active Pokémon too. Every other component, including the damage on every
Benched Pokémon, is unchanged. -/
def GameState.clamp (g : GameState) : GameState :=
  { g with cur := { g.cur with active := g.cur.active.map (InPlay.clampWith g.between) },
           opp := { g.opp with active := g.opp.active.map (InPlay.clampWith true) } }

/-! ## Turn boundaries -/

theorem Run.curIsFirst_eq {e : Effect} {g g' : GameState} (h : Run e g g') :
    g'.curIsFirst = g.curIsFirst :=
  h.frame.2.2.2.2.2.1

theorem Run.between_eq {e : Effect} {g g' : GameState} (h : Run e g g') :
    g'.between = g.between :=
  h.frame.2.2.2.2.2.2

/-- The turn proper begins (the move out of the between-turns phase, `startTurn`) only in a
state with no pending Knock Out. This replaces the earlier `Move.damageBounded_of_turn`, which
is false once Checkup places damage (`Move.endTurn_pending_ko`). -/
theorem Move.damageBounded_of_startTurn {g g' : GameState} (h : Move g g')
    (hb : g.between = true) (hb' : g'.between = false) : DamageBounded g' := by
  cases h with
  | startTurn hbt ha hb hk hd => exact hk
  | _ =>
      first
      | exact absurd (hb.symm.trans hb') (by decide)
      | exact absurd (hb.symm.trans ‹g.between = false›) (by decide)
      | exact absurd hb' (by decide)

/-! ## The clamp is a bisimulation -/

namespace InPlay

/-- Two Pokémon with the same `clampWith c`: equal except in damage and Poison strength. -/
structure Agree (c : Bool) (q p : InPlay) : Prop where
  top : q.top = p.top
  under : q.under = p.under
  energy : q.energy = p.energy
  tools : q.tools = p.tools
  rot : q.rot = p.rot
  poisoned : q.poisoned = p.poisoned
  burned : q.burned = p.burned
  fresh : q.fresh = p.fresh
  damage : (if c then min q.damage q.top.hp else q.damage)
    = (if c then min p.damage p.top.hp else p.damage)
  poisonUp : min q.poisonUp q.top.hp = min p.poisonUp p.top.hp

theorem agree_of_clamp {c : Bool} {q p : InPlay} (h : q.clampWith c = p.clampWith c) :
    Agree c q p := by
  have h1 := congrArg InPlay.top h
  have h2 := congrArg InPlay.under h
  have h3 := congrArg InPlay.energy h
  have h4 := congrArg InPlay.tools h
  have h5 := congrArg InPlay.rot h
  have h6 := congrArg InPlay.poisoned h
  have h7 := congrArg InPlay.burned h
  have h8 := congrArg InPlay.fresh h
  have h9 := congrArg InPlay.damage h
  have h10 := congrArg InPlay.poisonUp h
  exact ⟨h1, h2, h3, h4, h5, h6, h7, h8, h9, h10⟩

theorem clamp_of_agree {c : Bool} {q p : InPlay} (h : Agree c q p) :
    q.clampWith c = p.clampWith c := by
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h9, h10⟩ := h
  cases q; cases p
  simp only at h1 h2 h3 h4 h5 h6 h7 h8 h9 h10
  subst h1 h2 h3 h4 h5 h6 h7 h8
  simp only [clampWith, h9, h10]

theorem Agree.damage_eq_of_lt {c : Bool} {q p : InPlay} (h : Agree c q p)
    (hl : p.damage < p.top.hp) : q.damage = p.damage := by
  have hd := h.damage
  rw [h.top] at hd
  cases c <;> simp only [Bool.false_eq_true, ite_false, ite_true] at hd <;> omega

theorem Agree.damage_eq {q p : InPlay} (h : Agree false q p) : q.damage = p.damage := h.damage

theorem Agree.ko {c : Bool} {q p : InPlay} (h : Agree c q p) (hk : p.top.hp ≤ p.damage) :
    q.top.hp ≤ q.damage := by
  have hd := h.damage
  rw [h.top] at hd ⊢
  cases c <;> simp only [Bool.false_eq_true, ite_false, ite_true] at hd <;> omega

theorem Agree.lt {c : Bool} {q p : InPlay} (h : Agree c q p) (hl : p.damage < p.top.hp) :
    q.damage < q.top.hp := by
  rw [h.damage_eq_of_lt hl, h.top]; exact hl

theorem Agree.cardList {c : Bool} {q p : InPlay} (h : Agree c q p) : q.cardList = p.cardList := by
  simp only [InPlay.cardList, h.top, h.under, h.energy, h.tools]

/-- Agreement with equal damage, at any cap. -/
theorem Agree.recap {c c' : Bool} {q p : InPlay} (h : Agree c q p) (hd : q.damage = p.damage) :
    Agree c' q p :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh,
    by rw [hd, h.top], h.poisonUp⟩

theorem Agree.of_eq {c : Bool} {q p : InPlay} (h1 : q.top = p.top) (h2 : q.under = p.under)
    (h3 : q.energy = p.energy) (h4 : q.tools = p.tools) (h5 : q.rot = p.rot)
    (h6 : q.poisoned = p.poisoned) (h7 : q.burned = p.burned) (h8 : q.fresh = p.fresh)
    (hd : q.damage = p.damage) (hu : min q.poisonUp q.top.hp = min p.poisonUp p.top.hp) :
    Agree c q p :=
  ⟨h1, h2, h3, h4, h5, h6, h7, h8, by rw [hd, h1], hu⟩

/-- With equal damage, agreeing Pokémon differ at most in Poison strength. -/
theorem Agree.eq_upd {c : Bool} {q p : InPlay} (h : Agree c q p) (hd : q.damage = p.damage) :
    q = { p with poisonUp := q.poisonUp } := by
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, _, _⟩ := h
  cases q; cases p
  simp only at h1 h2 h3 h4 h5 h6 h7 h8 hd
  subst h1 h2 h3 h4 h5 h6 h7 h8 hd
  rfl

theorem clampWith_setPoisonUp {c : Bool} (x : InPlay) (u : Nat)
    (h : min u x.top.hp = min x.poisonUp x.top.hp) :
    clampWith c { x with poisonUp := u } = clampWith c x := by
  cases x
  simp only [clampWith] at h ⊢
  rw [h]

/-- Agreeing Pokémon with equal damage stay agreeing under an update `U` that touches neither
the top card nor the Poison strength. -/
theorem Agree.clamp_map {c c' : Bool} {q p : InPlay} (h : Agree c q p)
    (hd : q.damage = p.damage) (U : InPlay → InPlay)
    (hU : ∀ u, U { p with poisonUp := u } = { U p with poisonUp := u })
    (htop : (U p).top = p.top) (hpu : (U p).poisonUp = p.poisonUp) :
    clampWith c' (U q) = clampWith c' (U p) := by
  have hu := h.poisonUp
  rw [h.top] at hu
  rw [h.eq_upd hd, hU]
  apply clampWith_setPoisonUp
  rw [htop, hpu]
  exact hu

end InPlay

open InPlay in
/-- Agreement survives every update the moves and effects make to one Pokémon. -/
theorem InPlay.Agree.upd {c : Bool} {q p : InPlay} (h : Agree c q p) :
    (∀ e, Agree c { q with energy := e } { p with energy := e }) ∧
    (∀ n, Agree c { q with damage := q.damage + n } { p with damage := p.damage + n }) ∧
    (∀ n, Agree c { q with poisonUp := q.poisonUp + n } { p with poisonUp := p.poisonUp + n }) ∧
    (∀ k, Agree c (q.inflict k) (p.inflict k)) ∧
    Agree c q.cure p.cure ∧ Agree c q.unfresh p.unfresh := by
  have hd := h.damage
  have hu := h.poisonUp
  rw [h.top] at hd hu
  refine ⟨fun e => ⟨h.top, h.under, rfl, h.tools, h.rot, h.poisoned, h.burned, h.fresh,
      h.damage, h.poisonUp⟩,
    fun n => ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, ?_,
      h.poisonUp⟩,
    fun n => ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh,
      h.damage, ?_⟩,
    fun k => ?_,
    ⟨h.top, h.under, h.energy, h.tools, rfl, rfl, rfl, h.fresh, h.damage, by simp [InPlay.cure]⟩,
    ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, rfl, h.damage,
      h.poisonUp⟩⟩
  · show (if c then min (q.damage + n) q.top.hp else q.damage + n)
      = (if c then min (p.damage + n) p.top.hp else p.damage + n)
    rw [h.top]
    cases c <;> simp only [Bool.false_eq_true, ite_false, ite_true] at hd ⊢ <;> omega
  · show min (q.poisonUp + n) q.top.hp = min (p.poisonUp + n) p.top.hp
    rw [h.top]; omega
  · cases k <;>
      exact ⟨h.top, h.under, h.energy, h.tools, by first | rfl | exact h.rot,
        by first | rfl | exact h.poisoned, by first | rfl | exact h.burned, h.fresh,
        h.damage, h.poisonUp⟩

/-- Checkup preserves agreement when the damage is equal, and then the results agree with
damage capped. -/
theorem InPlay.Agree.checkup {c : Bool} {q p : InPlay} (h : Agree c q p)
    (hd : q.damage = p.damage) (o f s : Bool) :
    Agree true (q.checkup o f s) (p.checkup o f s) := by
  have hu := h.poisonUp
  rw [h.top] at hu
  refine ⟨h.top, h.under, h.energy, h.tools, ?_, h.poisoned, ?_, h.fresh, ?_, h.poisonUp⟩
  · simp only [InPlay.checkup, h.rot]
  · simp only [InPlay.checkup, h.burned]
  · show min (q.damage + (if q.poisoned then 1 + q.poisonUp else 0) +
        (if q.burned then 2 else 0)) q.top.hp
      = min (p.damage + (if p.poisoned then 1 + p.poisonUp else 0) +
        (if p.burned then 2 else 0)) p.top.hp
    rw [h.top, hd, h.poisoned, h.burned]
    cases p.poisoned <;> cases p.burned <;>
      simp only [Bool.false_eq_true, ite_false, ite_true] <;> omega

/-- Two states with the same clamp differ at most in the two Active Pokémon, and there only
as `Agree` allows. -/
theorem GameState.clamp_inv {g₁ g₂ : GameState} (h : g₁.clamp = g₂.clamp) :
    ∃ c₂ a₂, g₂ = { g₁ with cur := { g₁.cur with active := c₂ },
                            opp := { g₁.opp with active := a₂ } } ∧
      c₂.map (InPlay.clampWith g₁.between) = g₁.cur.active.map (InPlay.clampWith g₁.between) ∧
      a₂.map (InPlay.clampWith true) = g₁.opp.active.map (InPlay.clampWith true) := by
  have hb : g₁.between = g₂.between := by
    have := congrArg GameState.between h
    exact this
  have hc : g₂.cur.active.map (InPlay.clampWith g₂.between)
      = g₁.cur.active.map (InPlay.clampWith g₁.between) :=
    (congrArg (fun g => g.cur.active) h).symm
  rw [← hb] at hc
  refine ⟨g₂.cur.active, g₂.opp.active, ?_, hc, (congrArg (fun g => g.opp.active) h).symm⟩
  have e : g₂ = { g₂.clamp with cur := { g₂.clamp.cur with active := g₂.cur.active },
                                opp := { g₂.clamp.opp with active := g₂.opp.active } } := rfl
  refine e.trans ?_
  rw [← h]
  rfl

/-- From `o.map f = some (f a)`, a `q` with `o = some q` that agrees with `a`. -/
theorem agree_of_map {c : Bool} {o : Option InPlay} {a : InPlay}
    (h : o.map (InPlay.clampWith c) = (some a).map (InPlay.clampWith c)) :
    ∃ q, o = some q ∧ InPlay.Agree c q a := by
  rw [Option.map_some] at h
  obtain ⟨q, rfl, hq⟩ := Option.map_eq_some_iff.1 h
  exact ⟨q, rfl, InPlay.agree_of_clamp hq⟩

theorem none_of_map {c : Bool} {o : Option InPlay}
    (h : o.map (InPlay.clampWith c) = (none : Option InPlay).map (InPlay.clampWith c)) :
    o = none :=
  Option.map_eq_none_iff.1 h

/-- The kernel of `clamp` is a bisimulation for `Run`, during a turn (effects resolve only
then). -/
theorem Run.clamp_sim {e : Effect} {g₁ g₁' : GameState} (h : Run e g₁ g₁') :
    ∀ {g₂ : GameState}, g₁.clamp = g₂.clamp → g₁.between = false →
      ∃ g₂', Run e g₂ g₂' ∧ g₁'.clamp = g₂'.clamp := by
  induction h with
  | skip g => intro g₂ hc _; exact ⟨g₂, .skip g₂, hc⟩
  | draw h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      exact ⟨_, .draw h, by simp only [GameState.clamp, hbt, hc₂, ha₂]⟩
  | drawEmpty h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      exact ⟨_, .drawEmpty h, hc⟩
  | @heal g p n h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have hq' : InPlay.Agree false { q with damage := q.damage - n }
          { p with damage := p.damage - n } :=
        ⟨hq.top, hq.under, hq.energy, hq.tools, hq.rot, hq.poisoned, hq.burned, hq.fresh,
          by show q.damage - n = p.damage - n; rw [hq.damage_eq], hq.poisonUp⟩
      exact ⟨_, .heal n rfl, by
        simp only [GameState.clamp, hbt, Option.map_some, InPlay.clamp_of_agree hq', ha₂]⟩
  | counters n h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .counters n rfl, by
        simp only [GameState.clamp, hbt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n)]⟩
  | inflict k h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .inflict k rfl, by
        simp only [GameState.clamp, hbt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.2.2.1 k)]⟩
  | poisonUp n h hp =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUp n rfl (hq.poisoned.trans hp), by
        simp only [GameState.clamp, hbt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.2.1 n)]⟩
  | poisonUpSkip n h hp =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUpSkip n rfl (hq.poisoned.trans hp), hc⟩
  | cure h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .cure rfl, by
        simp only [GameState.clamp, hbt, Option.map_some, ha₂,
          InPlay.clamp_of_agree hq.upd.2.2.2.2.1]⟩
  | shuffle h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      exact ⟨_, .shuffle h, by simp only [GameState.clamp, hbt, hc₂, ha₂]⟩
  | search h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      exact ⟨_, .search h, by simp only [GameState.clamp, hbt, hc₂, ha₂]⟩
  | handToBottom h =>
      intro g₂ hc hbt
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [hbt] at hc₂
      exact ⟨_, .handToBottom h, by simp only [GameState.clamp, hbt, hc₂, ha₂]⟩
  | seq r₁ _ ih₁ ih₂ =>
      intro g₂ hc hbt
      obtain ⟨g₂', h₁, hc'⟩ := ih₁ hc hbt
      obtain ⟨g₂'', h₂, hc''⟩ := ih₂ hc' (r₁.between_eq.trans hbt)
      exact ⟨g₂'', .seq h₁ h₂, hc''⟩
  | choiceL _ ih =>
      intro g₂ hc hbt
      obtain ⟨g₂', h₁, hc'⟩ := ih hc hbt
      exact ⟨g₂', .choiceL h₁, hc'⟩
  | choiceR _ ih =>
      intro g₂ hc hbt
      obtain ⟨g₂', h₁, hc'⟩ := ih hc hbt
      exact ⟨g₂', .choiceR h₁, hc'⟩
  | iterNil a g => intro g₂ hc _; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons r₁ _ ih₁ ih₂ =>
      intro g₂ hc hbt
      obtain ⟨g₂', h₁, hc'⟩ := ih₁ hc hbt
      obtain ⟨g₂'', h₂, hc''⟩ := ih₂ hc' (r₁.between_eq.trans hbt)
      exact ⟨g₂'', .iterCons h₁ h₂, hc''⟩

theorem GameState.damageBounded_of_clamp {g₁ g₂ : GameState} (h : g₁.clamp = g₂.clamp)
    (hk : DamageBounded g₁) : DamageBounded g₂ := by
  obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv h
  intro p hp
  rcases hp with hp | hp | hp | hp
  · simp only at hp
    rw [hp, Option.map_some] at hc₂
    obtain ⟨a, ha, hfa⟩ := Option.map_eq_some_iff.1 hc₂.symm
    exact (InPlay.agree_of_clamp hfa.symm).lt (hk a (Or.inl ha))
  · exact hk p (Or.inr (Or.inl hp))
  · simp only at hp
    rw [hp, Option.map_some] at ha₂
    obtain ⟨a, ha, hfa⟩ := Option.map_eq_some_iff.1 ha₂.symm
    exact (InPlay.agree_of_clamp hfa.symm).lt (hk a (Or.inr (Or.inr (Or.inl ha))))
  · exact hk p (Or.inr (Or.inr (Or.inr hp)))

/-- The kernel of `clamp` is a bisimulation for `Move`: if `g₁` and `g₂` have the same
clamp, every move from `g₁` is matched by a move from `g₂` to a state with the same clamp.
(The relation is symmetric, so this gives both directions.) -/
theorem Move.clamp_sim {g₁ g₁' g₂ : GameState} (h : Move g₁ g₁')
    (hc : g₁.clamp = g₂.clamp) : ∃ g₂', Move g₂ g₂' ∧ g₁'.clamp = g₂'.clamp := by
  have hk₂ := GameState.damageBounded_of_clamp hc
  obtain ⟨c₂, a₂, hg, hc₂, ha₂⟩ := GameState.clamp_inv hc
  cases h with
  | playBasic hh hs hhp hb hbt =>
      subst hg
      exact ⟨_, .playBasic hh hs hhp hb hbt, by simp only [GameState.clamp, hc₂, ha₂]⟩
  | @attach l₁ l₂ t a hh hf ha hbt =>
      subst hg
      rw [ha, hbt] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have key := hq.clamp_map (c' := false) hq.damage_eq
        (fun x => { x with energy := Card.energy t :: x.energy }) (fun _ => rfl) rfl rfl
      exact ⟨_, .attach hh hf rfl hbt, by
        simp only [GameState.clamp, hbt, Option.map_some, ha₂, key]⟩
  | evolve hh ha he hfr hf hbt =>
      subst hg
      rw [ha, hbt] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd hq.damage_eq
      refine ⟨_, .evolve hh rfl (by rw [hq.top]; exact he) (hq.fresh.trans hfr) hf hbt, ?_⟩
      rw [e]
      simp only [GameState.clamp, hbt, ha₂]
  | retreat ha hb hr he hp hk hs hbt =>
      subst hg
      rw [ha, hbt] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd hq.damage_eq
      refine ⟨_, .retreat rfl hb hr (hq.energy.trans he) (by rw [hq.top]; exact hp)
        (hq.lt hk) (by rw [hq.rot]; exact hs) hbt, ?_⟩
      rw [e]
      simp only [GameState.clamp, hbt, ha₂]
  | @item g' l₁ l₂ n e hh hbt hr =>
      obtain ⟨g₂', hr', hc'⟩ := Run.clamp_sim hr (g₂ := { g₂ with cur := { g₂.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.clamp, hc₂, ha₂]) hbt
      exact ⟨g₂', .item (by subst hg; exact hh) (by subst hg; exact hbt) hr', hc'⟩
  | @supporter g' l₁ l₂ n e hh hs hbt hr =>
      obtain ⟨g₂', hr', hc'⟩ := Run.clamp_sim hr (g₂ := { g₂ with cur := { g₂.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.clamp, hc₂, ha₂]) hbt
      exact ⟨g₂', .supporter (by subst hg; exact hh) (by subst hg; exact hs)
        (by subst hg; exact hbt) hr', hc'⟩
  | attack ha hm hc' hs hn hf hbt hr =>
      obtain ⟨g₂', hr', hc''⟩ := Run.clamp_sim hr hc hbt
      subst hg
      rw [ha, hbt] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      refine ⟨_, .attack rfl (by rw [hq.top]; exact hm) (by rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hr', ?_⟩
      have := congrArg (fun g : GameState => ({ g with attacked := true } : GameState)) hc''
      exact this
  | attackConfused ha hm hc' hs hn hf hbt =>
      subst hg
      rw [ha, hbt] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .attackConfused rfl (by rw [hq.top]; exact hm) (by rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt, by
        simp only [GameState.clamp, hbt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.upd.2.1 3)]⟩
  | knockOut ha hk hp =>
      subst hg
      rw [ha] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .knockOut rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, Option.map_none, hc₂, hq.cardList]⟩
  | promote ha hb =>
      subst hg
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .promote rfl hb, by simp only [GameState.clamp, hc₂]⟩
  | noPokemon ha hb =>
      subst hg
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .noPokemon rfl hb, by simp only [GameState.clamp, hc₂, ha, Option.map_none]⟩
  | knockOutOwn ha hk hp =>
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .knockOutOwn rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, Option.map_none, ha₂, hq.cardList]⟩
  | promoteOwn ha hb =>
      subst hg
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .promoteOwn rfl hb, by simp only [GameState.clamp, ha₂]⟩
  | noPokemonOwn ha hb =>
      subst hg
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .noPokemonOwn rfl hb, by simp only [GameState.clamp, ha₂, ha, Option.map_none]⟩
  | endTurn fa sa fb sb ha hb hk hbt =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb, hbt] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      have h1 := hqa.checkup (hqa.damage_eq_of_lt (hk _ (Or.inr (Or.inr (Or.inl ha))))) false fa sa
      have h2 := hqb.upd.2.2.2.2.2.checkup hqb.damage_eq true fb sb
      refine ⟨_, .endTurn fa sa fb sb rfl rfl hk' hbt, ?_⟩
      simp only [GameState.clamp, PlayerState.unfresh, Option.map_some, hb,
        InPlay.clamp_of_agree h1, InPlay.clamp_of_agree h2]
  | startTurn hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb, hbt] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      have h1 : InPlay.Agree false qb _ :=
        hqb.recap (hqb.damage_eq_of_lt (hk _ (Or.inl hb)))
      refine ⟨_, .startTurn hbt rfl rfl hk' hd, ?_⟩
      simp only [GameState.clamp, Option.map_some, ha, hb, InPlay.clamp_of_agree hqa,
        InPlay.clamp_of_agree h1]
  | deckOut hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      exact ⟨_, .deckOut hbt rfl rfl hk' hd, by
        simp only [GameState.clamp, Option.map_some, ha, hb, InPlay.clamp_of_agree hqa,
          InPlay.clamp_of_agree hqb]⟩

/-- The kernel of `clamp` is a bisimulation for `Reach`: from start states with the same
clamp, the same clamped states are reachable. -/
theorem Reach.clamp_sim {g₀ h₀ g₁ : GameState} (h : Reach g₀ g₁) (hc : g₀.clamp = h₀.clamp) :
    ∃ g₂, Reach h₀ g₂ ∧ g₁.clamp = g₂.clamp := by
  induction h with
  | refl => exact ⟨h₀, .refl _, hc⟩
  | step _ hw hm ih =>
      obtain ⟨g₂, hr, hc'⟩ := ih
      obtain ⟨g₂', hm', hc''⟩ := hm.clamp_sim hc'
      have hw' : g₂.winner = none := by
        have e := congrArg GameState.winner hc'
        exact e.symm.trans hw
      exact ⟨g₂', .step hr hw' hm', hc''⟩

/-! ## Damage on the player's own Active Pokémon is bounded -/

/-- The largest printed HP among the Pokémon cards in a list (0 if there are none). -/
def maxHp : List Card → Nat
  | [] => 0
  | .pokemon p :: cs => max p.hp (maxHp cs)
  | _ :: cs => maxHp cs

theorem hp_le_maxHp {p : PokemonCard} : ∀ {cs : List Card}, Card.pokemon p ∈ cs → p.hp ≤ maxHp cs
  | [], h => nomatch h
  | c :: cs, h => by
      cases h with
      | head => simp only [maxHp]; omega
      | tail _ h =>
          have := hp_le_maxHp h
          cases c <;> simp only [maxHp] <;> omega

theorem GameState.top_mem_cur_active {g : GameState} {a : InPlay}
    (ha : g.cur.active = some a) : Card.pokemon a.top ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, optCardList, ha, InPlay.cardList]

theorem GameState.top_mem_opp_active {g : GameState} {a : InPlay}
    (ha : g.opp.active = some a) : Card.pokemon a.top ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, optCardList, ha, InPlay.cardList]

theorem mem_benchCardList {p : InPlay} {x : Card} (hx : x ∈ p.cardList) :
    ∀ {b : List InPlay}, p ∈ b → x ∈ benchCardList b
  | _ :: _, .head _ => List.mem_append_left _ hx
  | _ :: _, .tail _ h => List.mem_append_right _ (mem_benchCardList hx h)

theorem GameState.top_mem_cur_bench {g : GameState} {a : InPlay}
    (ha : a ∈ g.cur.bench) : Card.pokemon a.top ∈ g.allCards := by
  have := mem_benchCardList (x := Card.pokemon a.top) (.head _) ha
  simp [GameState.allCards, PlayerState.allCards, this]

theorem GameState.top_mem_opp_bench {g : GameState} {a : InPlay}
    (ha : a ∈ g.opp.bench) : Card.pokemon a.top ∈ g.allCards := by
  have := mem_benchCardList (x := Card.pokemon a.top) (.head _) ha
  simp [GameState.allCards, PlayerState.allCards, this]

/-- During a turn, the player's own Active Pokémon has at most `M + 3` damage counters, and
at most `M` before the player has attacked this turn. (Between turns its damage is capped by
the clamp instead.) -/
def ActiveLe (M : Nat) (g : GameState) : Prop :=
  g.between = false →
    ∀ p, g.cur.active = some p → p.damage ≤ M + 3 ∧ (g.attacked = false → p.damage ≤ M)

theorem Run.activeLe {e : Effect} {g g' : GameState} {M : Nat} (h : Run e g g') :
    ActiveLe M g → ActiveLe M g' := by
  induction h with
  | heal n h =>
      intro hJ hbt p hp
      cases hp
      have := hJ hbt _ h
      exact ⟨Nat.le_trans (Nat.sub_le _ _) this.1,
        fun hn => Nat.le_trans (Nat.sub_le _ _) (this.2 hn)⟩
  | cure h => intro hJ hbt p hp; cases hp; have := hJ hbt _ h; exact this
  | seq _ _ ih₁ ih₂ => intro hJ; exact ih₂ (ih₁ hJ)
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterCons _ _ ih₁ ih₂ => intro hJ; exact ih₂ (ih₁ hJ)
  | _ => exact id

theorem Move.activeLe {g g' : GameState} {M : Nat} (h : Move g g')
    (hM : ∀ p, Card.pokemon p ∈ g.allCards → p.hp ≤ M) (hw : WellFormed g)
    (hJ : ActiveLe M g) : ActiveLe M g' := by
  have hbench : ∀ q ∈ g.cur.bench, q.damage ≤ M := fun q hq =>
    Nat.le_of_lt (Nat.lt_of_lt_of_le (hw.2.1 q hq).1 (hM _ (GameState.top_mem_cur_bench hq)))
  cases h with
  | playBasic hh hs hhp hb hbt => exact hJ
  | attach hh hf ha hbt => intro _ p hp; cases hp; have := hJ hbt _ ha; exact this
  | evolve hh ha he hfr hf hbt => intro _ p hp; cases hp; have := hJ hbt _ ha; exact this
  | retreat ha hb hr he hp' hk hs hbt =>
      rename_i a q b₁ b₂ _ _
      intro _ p hp; cases hp
      have := hbench q (by rw [hb]; exact List.mem_append_right _ (.head _))
      exact ⟨by omega, fun _ => this⟩
  | item hh hbt hr => exact hr.activeLe hJ
  | supporter hh hs hbt hr => exact hr.activeLe hJ
  | attack ha hm hc hs hn hf hbt hr =>
      intro hb' p hp
      exact ⟨(hr.activeLe hJ hb' p hp).1, fun h => nomatch h⟩
  | attackConfused ha hm hc hs hn hf hbt =>
      intro _ p hp; cases hp
      have := (hJ hbt _ ha).2 hn
      exact ⟨by simp only; omega, fun h => nomatch h⟩
  | knockOut ha hk hp => exact hJ
  | promote ha hb => exact hJ
  | noPokemon ha hb => exact hJ
  | knockOutOwn ha hk hp => intro _ p hp; cases hp
  | promoteOwn ha hb =>
      rename_i q b₁ b₂
      intro _ p hp; cases hp
      have := hbench q (by rw [hb]; exact List.mem_append_right _ (.head _))
      exact ⟨by omega, fun _ => this⟩
  | noPokemonOwn ha hb => exact hJ
  | endTurn fa sa fb sb ha hb hk hbt => intro h; nomatch h
  | startTurn hbt ha hb hk hd =>
      intro _ p hp
      have := Nat.le_of_lt (Nat.lt_of_lt_of_le (hk p (Or.inl hp))
        (hM _ (GameState.top_mem_cur_active hp)))
      exact ⟨by omega, fun _ => this⟩
  | deckOut hbt ha hb hk hd => exact hJ

/-- From a well-formed start with no pending Knock Out, during every turn of play the player's
own Active Pokémon has at most `maxHp g₀.allCards + 3` damage counters. -/
theorem Reach.activeLe {g₀ g : GameState} (h₀ : DamageBounded g₀) (hw : WellFormed g₀)
    (h : Reach g₀ g) : ActiveLe (maxHp g₀.allCards) g := by
  induction h with
  | refl =>
      intro _ p hp
      have := Nat.le_of_lt (Nat.lt_of_lt_of_le (h₀ p (Or.inl hp))
        (hp_le_maxHp (GameState.top_mem_cur_active hp)))
      exact ⟨by omega, fun _ => this⟩
  | step hr _ hm ih =>
      exact hm.activeLe (fun p hp => hp_le_maxHp ((hr.perm.mem_iff).1 hp))
        (hr.wellFormed hw) ih

/-! ## The old turn-boundary statement fails: Checkup leaves a pending Knock Out -/

/-- A Basic Pokémon with 10 HP (one counter). -/
def cxCard : PokemonCard := ⟨"", .basic, none, 1, .grass, [], 0⟩

def cxSide (a : InPlay) : PlayerState :=
  ⟨[], [], [], [], [], some a, [], none, false, false, false, false, false⟩

/-- Both Active Pokémon have 10 HP and no damage; the opponent's is Poisoned. -/
def cxState : GameState :=
  ⟨cxSide (InPlay.ofBasic cxCard), cxSide { InPlay.ofBasic cxCard with poisoned := true },
    true, false, false, false, none⟩

/-- `Move.damageBounded_of_turn` (every move that passes the turn yields a state with no
pending Knock Out) is false in the model with Checkup: ending the turn from a state with no
pending Knock Out Poisons the opponent's 10-HP Active Pokémon to its HP. The Knock Out is then
taken between turns (`knockOutOwn`), before `startTurn`. -/
theorem Move.endTurn_pending_ko :
    ∃ g g', Move g g' ∧ DamageBounded g ∧ g'.curIsFirst ≠ g.curIsFirst ∧
      ¬ DamageBounded g' := by
  have hk : DamageBounded cxState := by
    intro p hp
    rcases hp with hp | hp | hp | hp
    · cases hp; decide
    · cases hp
    · cases hp; decide
    · cases hp
  refine ⟨cxState, _, .endTurn false false false false rfl rfl hk rfl, hk, by decide, ?_⟩
  intro hk'
  have := hk' _ (Or.inl rfl)
  exact absurd this (by decide)

end Pokemon
