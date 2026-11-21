import Pokemon.WellFormed

/-!
# Damage and Poison strength: what is bounded, and a clamp that makes the rest bounded

Two numeric components of the state can be made large by legal play: damage on either Active
Pokémon (inside an attack's effect, `counters_unbounded`; an attack or Checkup can leave it far
above HP, and the Knock Out is then the next move; one step of a Trainer card's effect can too,
and the Knock Out is taken at once, inside the same move) and the Poison strength `poisonUp`
of a Poisoned Pokémon (`poisonUp_unbounded`). This file shows that the excess carries no
information at the level of moves.

* `InPlay.clampWith c` caps `poisonUp` at the printed HP, and, when `c` is true, caps the
  damage at the HP too. `GameState.clampAt c` applies it to both Active Pokémon; nothing else
  changes. `GameState.clamp` is `clampAt true`.
* `Run.exact_sim`: the kernel of `clampAt false` (equal damage everywhere, Poison strength
  equal up to HP) is a bisimulation for `Run`. Effects read damage exactly, so inside an
  effect only Poison strength may be capped; `Reads.run_clamp_not_sim` shows that the HP clamp
  of damage is NOT a simulation for `Run` once effects read damage.
* `TRun.clamp_sim` (with `KOMove.clamp_sim`, `Resolve.clamp_sim`): the kernel of `clamp` IS a
  simulation for a Trainer card's effect started in a `Settled` (or finished) state, because
  every test and primitive step of it starts `Settled` (`TRun.settled_or_won`).
* `Move.clamp_sim`, `Reach.clamp_sim`: states with the same `clamp` have the same moves, up to
  the same clamp. So the kernel of `clamp` is a (strong) bisimulation for `Move`, and every
  question about legal play that does not read the capped quantities above HP can be asked of
  the clamped states instead.
* `Move.damageBounded_of_startTurn`: the turn proper starts with no pending Knock Out.
  `Move.endTurn_pending_ko`: the earlier `Move.damageBounded_of_turn` is false with Checkup.

Why the clamp is sound at the level of moves. Every move that resolves an effect, and every
other move except the six that resolve Knock Outs, requires the state to be `Settled`: no
Pokémon in play is at or above its HP. In such a state the two clamps agree: damage below HP is
not capped, so states with the same `clamp` have the same damage (`map_exact_of_clamp`), and
`Run.exact_sim` applies to an attack's effect, and `TRun.clamp_sim` to a Trainer card's. A
Pokémon at or above its HP is read only by the Knock Out test `hp ≤ damage` and its negation, a
threshold test at HP. Poison strength is read only by Checkup, which adds it to damage that is
then capped at HP; `min (d + u) h` depends on `u` only through `min u h`. No effect reads Poison
strength.

The previous version of this file capped the damage on the player's own Active Pokémon only
between turns and bounded it during the turn by a separate invariant (`Reach.activeLe`, at most
`maxHp + 3`). With `selfDamage` that invariant is false (`Reads.activeLe_false`), and with the
Knock Out timing of `Settled` it is not needed: the clamp now caps both Active Pokémon always.
-/

namespace Pokemon

/-- Poison strength capped at the printed HP and, if `c`, damage capped at the printed HP. -/
def InPlay.clampWith (c : Bool) (p : InPlay) : InPlay :=
  { p with damage := if c then min p.damage p.top.hp else p.damage,
           poisonUp := min p.poisonUp p.top.hp }

/-- Apply `InPlay.clampWith c` to both Active Pokémon. Every other component, including the
damage on every Benched Pokémon, is unchanged. -/
def GameState.clampAt (c : Bool) (g : GameState) : GameState :=
  { g with cur := { g.cur with active := g.cur.active.map (InPlay.clampWith c) },
           opp := { g.opp with active := g.opp.active.map (InPlay.clampWith c) } }

/-- Cap the damage and the Poison strength on both Active Pokémon at the printed HP. -/
def GameState.clamp (g : GameState) : GameState := g.clampAt true

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
  marks : q.marks = p.marks
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
  have h11 := congrArg InPlay.marks h
  exact ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, h9, h10⟩

theorem clamp_of_agree {c : Bool} {q p : InPlay} (h : Agree c q p) :
    q.clampWith c = p.clampWith c := by
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, h9, h10⟩ := h
  cases q; cases p
  simp only at h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11
  subst h1 h2 h3 h4 h5 h6 h7 h8 h11
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
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks,
    by rw [hd, h.top], h.poisonUp⟩

theorem Agree.of_eq {c : Bool} {q p : InPlay} (h1 : q.top = p.top) (h2 : q.under = p.under)
    (h3 : q.energy = p.energy) (h4 : q.tools = p.tools) (h5 : q.rot = p.rot)
    (h6 : q.poisoned = p.poisoned) (h7 : q.burned = p.burned) (h8 : q.fresh = p.fresh)
    (h11 : q.marks = p.marks)
    (hd : q.damage = p.damage) (hu : min q.poisonUp q.top.hp = min p.poisonUp p.top.hp) :
    Agree c q p :=
  ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, by rw [hd, h1], hu⟩

/-- With equal damage, agreeing Pokémon differ at most in Poison strength. -/
theorem Agree.eq_upd {c : Bool} {q p : InPlay} (h : Agree c q p) (hd : q.damage = p.damage) :
    q = { p with poisonUp := q.poisonUp } := by
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, _, _⟩ := h
  cases q; cases p
  simp only at h1 h2 h3 h4 h5 h6 h7 h8 h11 hd
  subst h1 h2 h3 h4 h5 h6 h7 h8 h11 hd
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
      h.marks, h.damage, h.poisonUp⟩,
    fun n => ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks,
      ?_, h.poisonUp⟩,
    fun n => ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks,
      h.damage, ?_⟩,
    fun k => ?_,
    ⟨h.top, h.under, h.energy, h.tools, rfl, rfl, rfl, h.fresh, h.marks, h.damage,
      by simp [InPlay.cure]⟩,
    ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, rfl, h.marks, h.damage,
      h.poisonUp⟩⟩
  · show (if c then min (q.damage + n) q.top.hp else q.damage + n)
      = (if c then min (p.damage + n) p.top.hp else p.damage + n)
    rw [h.top]
    cases c <;> simp only [Bool.false_eq_true, ite_false, ite_true] at hd ⊢ <;> omega
  · show min (q.poisonUp + n) q.top.hp = min (p.poisonUp + n) p.top.hp
    rw [h.top]; omega
  · cases k <;>
      exact ⟨h.top, h.under, h.energy, h.tools, by first | rfl | exact h.rot,
        by first | rfl | exact h.poisoned, by first | rfl | exact h.burned, h.fresh, h.marks,
        h.damage, h.poisonUp⟩

/-- Agreement survives a change of markers. -/
theorem InPlay.Agree.setMarks {c : Bool} {q p : InPlay} (h : Agree c q p) (f : Marks → Marks) :
    Agree c (q.setMarks f) (p.setMarks f) :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh,
    by simp only [InPlay.setMarks, h.marks], h.damage, h.poisonUp⟩

theorem InPlay.clampWith_setMarks (c : Bool) (f : Marks → Marks) :
    InPlay.clampWith c ∘ InPlay.setMarks f = InPlay.setMarks f ∘ InPlay.clampWith c := rfl

/-- Removing markers from an Active Spot commutes with agreement. -/
theorem map_clamp_setMarks {c : Bool} (f : Marks → Marks) {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith c) = o₁.map (InPlay.clampWith c)) :
    (o₂.map (InPlay.setMarks f)).map (InPlay.clampWith c) =
      (o₁.map (InPlay.setMarks f)).map (InPlay.clampWith c) := by
  rw [Option.map_map, Option.map_map, InPlay.clampWith_setMarks, ← Option.map_map,
    ← Option.map_map, h]

/-- Checkup preserves agreement when the damage is equal, and then the results agree with
damage capped. -/
theorem InPlay.Agree.checkup {c : Bool} {q p : InPlay} (h : Agree c q p)
    (hd : q.damage = p.damage) (o f s t : Bool) :
    Agree true (q.checkup o f s t) (p.checkup o f s t) := by
  have hu := h.poisonUp
  rw [h.top] at hu
  refine ⟨h.top, h.under, h.energy, h.tools, ?_, h.poisoned, ?_, h.fresh, h.marks, ?_,
    h.poisonUp⟩
  · simp only [InPlay.checkup, h.rot]
  · simp only [InPlay.checkup, h.burned]
  · show min (q.damage + (if q.poisoned then 1 + q.poisonUp else 0) +
        (if q.burned then 2 else 0) + (if q.marks.char && t then 2 else 0)) q.top.hp
      = min (p.damage + (if p.poisoned then 1 + p.poisonUp else 0) +
        (if p.burned then 2 else 0) + (if p.marks.char && t then 2 else 0)) p.top.hp
    rw [h.top, hd, h.poisoned, h.burned, h.marks]
    cases p.poisoned <;> cases p.burned <;> cases (p.marks.char && t) <;>
      simp only [Bool.false_eq_true, ite_false, ite_true] <;> omega


/-- Agreeing Pokémon given the same damage still agree. -/
theorem InPlay.Agree.setDamage {c : Bool} {q p : InPlay} (h : Agree c q p) (d : Nat) :
    Agree c { q with damage := d } { p with damage := d } :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks,
    by show (if c then min d q.top.hp else d) = (if c then min d p.top.hp else d); rw [h.top],
    h.poisonUp⟩

/-- Tests read only what `Agree false` keeps equal. -/
theorem Test.eval_agree (t : Test) {q p : InPlay} (h : InPlay.Agree false q p) :
    t.eval q = t.eval p := by
  have hd : q.damage = p.damage := h.damage_eq
  cases t with
  | atLeast w n => simp only [Test.eval, hd]
  | exactly w n => simp only [Test.eval, hd]
  | cond w c => cases c <;> simp only [Test.eval, InPlay.has, h.poisoned, h.burned, h.rot]
  | marked w m => simp only [Test.eval, h.marks]
  | isType w t =>
      have e : q.type = p.type := by simp only [InPlay.type, h.marks, h.top]
      show decide (q.type = t) = decide (p.type = t)
      rw [e]

/-- The state with both Active Spots replaced. -/
theorem GameState.clampAt_upd (c : Bool) (g : GameState) (c₂ a₂ : Option InPlay) :
    ({ g with cur := { g.cur with active := c₂ }, opp := { g.opp with active := a₂ } }
      : GameState).clampAt c =
    { g with cur := { g.cur with active := c₂.map (InPlay.clampWith c) },
             opp := { g.opp with active := a₂.map (InPlay.clampWith c) } } := rfl

/-- Two states with the same `clampAt c` differ at most in the two Active Pokémon, and there
only as `Agree c` allows. -/
theorem GameState.clamp_inv {c : Bool} {g₁ g₂ : GameState} (h : g₁.clampAt c = g₂.clampAt c) :
    ∃ c₂ a₂, g₂ = { g₁ with cur := { g₁.cur with active := c₂ },
                            opp := { g₁.opp with active := a₂ } } ∧
      c₂.map (InPlay.clampWith c) = g₁.cur.active.map (InPlay.clampWith c) ∧
      a₂.map (InPlay.clampWith c) = g₁.opp.active.map (InPlay.clampWith c) := by
  refine ⟨g₂.cur.active, g₂.opp.active, ?_, (congrArg (fun g => g.cur.active) h).symm,
    (congrArg (fun g => g.opp.active) h).symm⟩
  have e : g₂ = { g₂.clampAt c with cur := { (g₂.clampAt c).cur with active := g₂.cur.active },
                                    opp := { (g₂.clampAt c).opp with active := g₂.opp.active } } :=
    rfl
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

/-- Equal damage gives the HP clamp. -/
theorem map_clamp_of_exact {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith false) = o₁.map (InPlay.clampWith false)) :
    o₂.map (InPlay.clampWith true) = o₁.map (InPlay.clampWith true) := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [Option.map_some, InPlay.clamp_of_agree (hq.recap (c' := true) hq.damage_eq)]

/-- Below HP, the HP clamp gives equal damage. -/
theorem map_exact_of_clamp {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith true) = o₁.map (InPlay.clampWith true))
    (hk : ∀ p, o₁ = some p → p.damage < p.top.hp) :
    o₂.map (InPlay.clampWith false) = o₁.map (InPlay.clampWith false) := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [Option.map_some,
        InPlay.clamp_of_agree (hq.recap (c' := false) (hq.damage_eq_of_lt (hk p rfl)))]

/-- The Active Pokémon read by a test, in a state with the same `clampAt c`. -/
theorem GameState.activeOf_agree {c : Bool} {g₁ g₂ : GameState} (h : g₁.clampAt c = g₂.clampAt c)
    {w : Whose} {p : InPlay} (hp : g₁.activeOf w = some p) :
    ∃ q, g₂.activeOf w = some q ∧ InPlay.Agree c q p := by
  cases w with
  | own =>
      have e := (congrArg (fun g => g.cur.active) h).symm
      simp only [GameState.clampAt] at e
      rw [show g₁.cur.active = some p from hp] at e
      exact agree_of_map e
  | opp =>
      have e := (congrArg (fun g => g.opp.active) h).symm
      simp only [GameState.clampAt] at e
      rw [show g₁.opp.active = some p from hp] at e
      exact agree_of_map e

/-- **The kernel of `clampAt false` is a bisimulation for `Run`.** Two states that agree
everywhere except in Poison strength above HP have the same effect resolutions, up to the
same relation. Damage is not capped: effects read it exactly (`Reads.run_clamp_not_sim`). -/
theorem Run.exact_sim {e : Effect} {g₁ g₁' : GameState} (h : Run e g₁ g₁') :
    ∀ {g₂ : GameState}, g₁.clampAt false = g₂.clampAt false →
      ∃ g₂', Run e g₂ g₂' ∧ g₁'.clampAt false = g₂'.clampAt false := by
  induction h with
  | skip g => intro g₂ hc; exact ⟨g₂, .skip g₂, hc⟩
  | draw h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .draw h, by simp only [GameState.clampAt, hc₂, ha₂]⟩
  | drawEmpty h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .drawEmpty h, hc⟩
  | @heal g p n h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have hq' : InPlay.Agree false { q with damage := q.damage - n }
          { p with damage := p.damage - n } := by
        rw [hq.damage_eq]; exact hq.setDamage _
      exact ⟨_, .heal n rfl, by
        simp only [GameState.clampAt, Option.map_some, InPlay.clamp_of_agree hq', ha₂]⟩
  | counters n h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .counters n rfl, by
        simp only [GameState.clampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n)]⟩
  | inflict k h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .inflict k rfl, by
        simp only [GameState.clampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.2.2.1 k)]⟩
  | poisonUp n h hp =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUp n rfl (hq.poisoned.trans hp), by
        simp only [GameState.clampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.2.1 n)]⟩
  | poisonUpSkip n h hp =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUpSkip n rfl (hq.poisoned.trans hp), hc⟩
  | cure h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .cure rfl, by
        simp only [GameState.clampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree hq.upd.2.2.2.2.1]⟩
  | iteT h ht _ ih =>
      intro g₂ hc
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih hc
      exact ⟨g₂', .iteT hq (by rw [Test.eval_agree _ hqa]; exact ht) r', hc'⟩
  | iteF h ht _ ih =>
      intro g₂ hc
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih hc
      exact ⟨g₂', .iteF hq (by rw [Test.eval_agree _ hqa]; exact ht) r', hc'⟩
  | @scale g p q w k hs h =>
      intro g₂ hc
      obtain ⟨s, hs₂, hsa⟩ := GameState.activeOf_agree hc hs
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q₂, rfl, hq⟩ := agree_of_map ha₂
      have hq' : InPlay.Agree false { q₂ with damage := q₂.damage + k * s.damage }
          { q with damage := q.damage + k * p.damage } := by
        rw [hq.damage_eq, hsa.damage_eq]; exact hq.setDamage _
      exact ⟨_, .scale w k hs₂ rfl, by
        simp only [GameState.clampAt, Option.map_some, hc₂, InPlay.clamp_of_agree hq']⟩
  | @selfDamage g p n h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .selfDamage n rfl, by
        simp only [GameState.clampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n)]⟩
  | @healAll g p h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .healAll rfl, by
        simp only [GameState.clampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.setDamage 0)]⟩
  | @touchActive e w f g p he h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h] at hc₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.clampAt, GameState.updSide, Option.map_some, ha₂,
              InPlay.clamp_of_agree (hq.setMarks f)]⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h] at ha₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.clampAt, GameState.updSide, Option.map_some, hc₂,
              InPlay.clamp_of_agree (hq.setMarks f)]⟩
  | @touchBench e w f g q b₁ b₂ he h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .touchBench he h, by simp only [GameState.clampAt, GameState.updSide, hc₂, ha₂]⟩
  | unmark w m g =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .unmark _ m _, by
          simp only [GameState.clampAt, GameState.updSide, PlayerState.unmark, hc₂, ha₂,
            map_clamp_setMarks _ hc₂, map_clamp_setMarks _ ha₂]⟩
  | shuffle h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .shuffle h, by simp only [GameState.clampAt, hc₂, ha₂]⟩
  | search h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .search h, by simp only [GameState.clampAt, hc₂, ha₂]⟩
  | handToBottom h =>
      intro g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .handToBottom h, by simp only [GameState.clampAt, hc₂, ha₂]⟩
  | seq _ _ ih₁ ih₂ =>
      intro g₂ hc
      obtain ⟨g₂', h₁, hc'⟩ := ih₁ hc
      obtain ⟨g₂'', h₂, hc''⟩ := ih₂ hc'
      exact ⟨g₂'', .seq h₁ h₂, hc''⟩
  | choiceL _ ih =>
      intro g₂ hc
      obtain ⟨g₂', h₁, hc'⟩ := ih hc
      exact ⟨g₂', .choiceL h₁, hc'⟩
  | choiceR _ ih =>
      intro g₂ hc
      obtain ⟨g₂', h₁, hc'⟩ := ih hc
      exact ⟨g₂', .choiceR h₁, hc'⟩
  | iterNil a g => intro g₂ hc; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons _ _ ih₁ ih₂ =>
      intro g₂ hc
      obtain ⟨g₂', h₁, hc'⟩ := ih₁ hc
      obtain ⟨g₂'', h₂, hc''⟩ := ih₂ hc'
      exact ⟨g₂'', .iterCons h₁ h₂, hc''⟩

/-- Equal `clampAt false` gives equal `clamp`. -/
theorem GameState.clamp_of_exact {g₁ g₂ : GameState} (h : g₁.clampAt false = g₂.clampAt false) :
    g₁.clamp = g₂.clamp := by
  obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv h
  simp only [GameState.clamp, GameState.clampAt, map_clamp_of_exact hc₂, map_clamp_of_exact ha₂]

/-- With no pending Knock Out, equal `clamp` gives equal `clampAt false`. -/
theorem GameState.exact_of_clamp {g₁ g₂ : GameState} (h : g₁.clamp = g₂.clamp)
    (hk : DamageBounded g₁) : g₁.clampAt false = g₂.clampAt false := by
  obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.clamp_inv h
  simp only [GameState.clampAt,
    map_exact_of_clamp hc₂ fun p hp => hk p (Or.inl hp),
    map_exact_of_clamp ha₂ fun p hp => hk p (Or.inr (Or.inr (Or.inl hp)))]

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

theorem GameState.settled_of_clamp {g₁ g₂ : GameState} (h : g₁.clamp = g₂.clamp)
    (hs : Settled g₁) : Settled g₂ := by
  refine ⟨GameState.damageBounded_of_clamp h hs.1, fun hn => hs.2.1 ?_, fun hn => hs.2.2 ?_⟩
  · have e := congrArg (fun g => g.cur.active) h
    simp only [GameState.clamp, GameState.clampAt, hn, Option.map_none] at e
    exact Option.map_eq_none_iff.1 e
  · have e := congrArg (fun g => g.opp.active) h
    simp only [GameState.clamp, GameState.clampAt, hn, Option.map_none] at e
    exact Option.map_eq_none_iff.1 e

/-- The kernel of `clamp` is a simulation for Knock Out moves. -/
theorem KOMove.clamp_sim {g₁ g₁' g₂ : GameState} (h : KOMove g₁ g₁')
    (hc : g₁.clamp = g₂.clamp) : ∃ g₂', KOMove g₂ g₂' ∧ g₁'.clamp = g₂'.clamp := by
  obtain ⟨c₂, a₂, hg, hc₂, ha₂⟩ := GameState.clamp_inv hc
  subst hg
  cases h with
  | knockOut ha hk hp =>
      rw [ha] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .knockOut rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_none, hc₂, hq.cardList]⟩
  | promote ha hb =>
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .promote rfl hb, by simp only [GameState.clamp, GameState.clampAt, hc₂]⟩
  | noPokemon ha hb =>
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .noPokemon rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha, Option.map_none]⟩
  | knockOutOwn ha hk hp =>
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .knockOutOwn rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_none, ha₂, hq.cardList]⟩
  | promoteOwn ha hb =>
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .promoteOwn rfl hb, by simp only [GameState.clamp, GameState.clampAt, ha₂]⟩
  | noPokemonOwn ha hb =>
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .noPokemonOwn rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, ha₂, ha, Option.map_none]⟩

theorem GameState.winner_of_clamp {g₁ g₂ : GameState} (h : g₁.clamp = g₂.clamp) :
    g₂.winner = g₁.winner :=
  (congrArg GameState.winner h).symm

/-- The kernel of `clamp` is a simulation for taking the Knock Outs. -/
theorem Resolve.clamp_sim {g₁ g₁' : GameState} (h : Resolve g₁ g₁') :
    ∀ {g₂ : GameState}, g₁.clamp = g₂.clamp →
      ∃ g₂', Resolve g₂ g₂' ∧ g₁'.clamp = g₂'.clamp := by
  induction h with
  | done h =>
      intro g₂ hc
      refine ⟨g₂, .done ?_, hc⟩
      rcases h with h | h
      · exact .inl (GameState.settled_of_clamp hc h)
      · exact .inr (by rw [GameState.winner_of_clamp hc]; exact h)
  | step hn hm _ ih =>
      intro g₂ hc
      obtain ⟨m₂, hm₂, hcm⟩ := hm.clamp_sim hc
      obtain ⟨g₂', hr₂, hc'⟩ := ih hcm
      exact ⟨g₂', .step (by rw [GameState.winner_of_clamp hc]; exact hn) hm₂ hr₂, hc'⟩

/-- **The kernel of `clamp` is a simulation for Trainer effects** (`TRun`), from a state that is
`Settled` or finished. Unlike `Run` (`Reads.run_clamp_not_sim`), a Trainer effect never reads
damage at or above HP: every test and primitive step starts `Settled` (`TRun.settled_or_won`),
where equal clamps mean equal damage, so `Run.exact_sim` applies to each step and the Knock Outs
that follow are simulated by `Resolve.clamp_sim`. -/
theorem TRun.clamp_sim {e : Effect} {g₁ g₁' : GameState} (h : TRun e g₁ g₁') :
    ∀ {g₂ : GameState}, g₁.clamp = g₂.clamp → (Settled g₁ ∨ g₁.winner ≠ none) →
      ∃ g₂', TRun e g₂ g₂' ∧ g₁'.clamp = g₂'.clamp := by
  induction h with
  | prim he hn hr hk =>
      intro g₂ hc hs
      have hs : Settled _ := hs.resolve_right (fun h => h hn)
      obtain ⟨m₂, hr₂, hcm⟩ := Run.exact_sim hr (GameState.exact_of_clamp hc hs.1)
      obtain ⟨g₂', hk₂, hc'⟩ := hk.clamp_sim (GameState.clamp_of_exact hcm)
      exact ⟨g₂', .prim he (by rw [GameState.winner_of_clamp hc]; exact hn) hr₂ hk₂, hc'⟩
  | stop hn =>
      intro g₂ hc _
      exact ⟨g₂, .stop (by rw [GameState.winner_of_clamp hc]; exact hn), hc⟩
  | iteT hn h ht _ ih =>
      intro g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree (GameState.exact_of_clamp hc hs'.1) h
      obtain ⟨g₂', r', hc'⟩ := ih hc hs
      exact ⟨g₂', .iteT (by rw [GameState.winner_of_clamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ hqa]; exact ht) r', hc'⟩
  | iteF hn h ht _ ih =>
      intro g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree (GameState.exact_of_clamp hc hs'.1) h
      obtain ⟨g₂', r', hc'⟩ := ih hc hs
      exact ⟨g₂', .iteF (by rw [GameState.winner_of_clamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ hqa]; exact ht) r', hc'⟩
  | seq h₁ _ ih₁ ih₂ =>
      intro g₂ hc hs
      obtain ⟨m₂, r₁, hcm⟩ := ih₁ hc hs
      obtain ⟨g₂', r₂, hc'⟩ := ih₂ hcm (h₁.settled_or_won hs)
      exact ⟨g₂', .seq r₁ r₂, hc'⟩
  | choiceL _ ih =>
      intro g₂ hc hs
      obtain ⟨g₂', r, hc'⟩ := ih hc hs
      exact ⟨g₂', .choiceL r, hc'⟩
  | choiceR _ ih =>
      intro g₂ hc hs
      obtain ⟨g₂', r, hc'⟩ := ih hc hs
      exact ⟨g₂', .choiceR r, hc'⟩
  | iterNil a g => intro g₂ hc _; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons h₁ _ ih₁ ih₂ =>
      intro g₂ hc hs
      obtain ⟨m₂, r₁, hcm⟩ := ih₁ hc hs
      obtain ⟨g₂', r₂, hc'⟩ := ih₂ hcm (h₁.settled_or_won hs)
      exact ⟨g₂', .iterCons r₁ r₂, hc'⟩

/-- **The kernel of `clamp` is a bisimulation for `Move`**: if `g₁` and `g₂` have the same
clamp, every move from `g₁` is matched by a move from `g₂` to a state with the same clamp.
(The relation is symmetric, so this gives both directions.) -/
theorem Move.clamp_sim {g₁ g₁' g₂ : GameState} (h : Move g₁ g₁')
    (hc : g₁.clamp = g₂.clamp) : ∃ g₂', Move g₂ g₂' ∧ g₁'.clamp = g₂'.clamp := by
  have hk₂ := GameState.damageBounded_of_clamp hc
  have hs₂ := GameState.settled_of_clamp hc
  have hx := GameState.exact_of_clamp hc
  obtain ⟨c₂, a₂, hg, hc₂, ha₂⟩ := GameState.clamp_inv hc
  cases h with
  | playBasic hh hs hhp hb hbt hst =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, .playBasic hh hs hhp hb hbt hs', by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂]⟩
  | @attach l₁ l₂ t a hh hf ha hbt hst =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have key := hq.clamp_map (c' := true) (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
        (fun x => { x with energy := Card.energy t :: x.energy }) (fun _ => rfl) rfl rfl
      exact ⟨_, .attach hh hf rfl hbt hs', by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha₂, key]⟩
  | @evolve l₁ l₂ p a hh ha he hfr hf hbt hst =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
      refine ⟨_, .evolve hh rfl (by rw [hq.top]; exact he) (hq.fresh.trans hfr) hf hbt hs', ?_⟩
      rw [e]
      simp only [GameState.clamp, GameState.clampAt, ha₂]
  | @retreat a q' b₁ b₂ paid rest ha hb hr he hp hs hbt hst =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
      refine ⟨_, .retreat rfl hb hr (hq.energy.trans he) (by rw [hq.top]; exact hp)
        (by rw [hq.rot]; exact hs) hbt hs', ?_⟩
      rw [e]
      simp only [GameState.clamp, GameState.clampAt, ha₂]
  | @item g' l₁ l₂ n e hh hbt hst hr =>
      have hs' := hs₂ hst
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim (g₂ := { g₂ with cur := { g₂.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂]) (.inl hst)
      exact ⟨g₂', .item (by subst hg; exact hh) (by subst hg; exact hbt) hs' hr', hc'⟩
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr =>
      have hs' := hs₂ hst
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim (g₂ := { g₂ with cur := { g₂.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂]) (.inl hst)
      exact ⟨g₂', .supporter (by subst hg; exact hh) (by subst hg; exact hs)
        (by subst hg; exact hbt) hs' hr', hc'⟩
  | @attack g' a atk ha hm hc' hs hn hf hbt hst hr =>
      have hs' := hs₂ hst
      obtain ⟨g₂', hr', hc''⟩ := Run.exact_sim hr (hx hst.1)
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      refine ⟨_, .attack rfl (by rw [hq.top]; exact hm) (by rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hs' hr', ?_⟩
      have := congrArg (fun g : GameState => ({ g with attacked := true } : GameState)) hc''
      exact GameState.clamp_of_exact this
  | attackConfused ha hm hc' hs hn hf hbt hst =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .attackConfused rfl (by rw [hq.top]; exact hm) (by rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hs', by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.upd.2.1 3)]⟩
  | knockOut ha hk hp =>
      subst hg
      rw [ha] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .knockOut rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_none, hc₂, hq.cardList]⟩
  | promote ha hb =>
      subst hg
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .promote rfl hb, by simp only [GameState.clamp, GameState.clampAt, hc₂]⟩
  | noPokemon ha hb =>
      subst hg
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .noPokemon rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha, Option.map_none]⟩
  | knockOutOwn ha hk hp =>
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .knockOutOwn rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_none, ha₂, hq.cardList]⟩
  | promoteOwn ha hb =>
      subst hg
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .promoteOwn rfl hb, by simp only [GameState.clamp, GameState.clampAt, ha₂]⟩
  | noPokemonOwn ha hb =>
      subst hg
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .noPokemonOwn rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, ha₂, ha, Option.map_none]⟩
  | endTurn fa sa ca fb sb cb ha hb hk hbt =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      have h1 := hqa.checkup (hqa.damage_eq_of_lt (hk _ (Or.inr (Or.inr (Or.inl ha))))) false
        fa sa ca
      have h2 := hqb.upd.2.2.2.2.2.checkup (hqb.damage_eq_of_lt (hk _ (Or.inl hb))) true fb sb cb
      refine ⟨_, .endTurn fa sa ca fb sb cb rfl rfl hk' hbt, ?_⟩
      simp only [GameState.clamp, GameState.clampAt, PlayerState.unfresh, Option.map_some, hb,
        InPlay.clamp_of_agree h1, InPlay.clamp_of_agree h2]
  | startTurn hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      refine ⟨_, .startTurn hbt rfl rfl hk' hd, ?_⟩
      simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha, hb,
        InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb]
  | deckOut hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      exact ⟨_, .deckOut hbt rfl rfl hk' hd, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha, hb,
          InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb]⟩

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

/-! ## Bounds from the cards -/

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
taken between turns (`knockOutOwn`), before `startTurn`.

The witness `cxState` is not well formed (both Prize lists are empty and there is no winner)
and is not shown reachable; this theorem refutes only the statement about single moves.
`Infinite.endTurn_pending_ko_reachable` gives a witness reached by play from a well-formed
start with no pending Knock Out. -/
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
  refine ⟨cxState, _, .endTurn false false false false false false rfl rfl hk rfl, hk, by decide, ?_⟩
  intro hk'
  have := hk' _ (Or.inl rfl)
  exact absurd this (by decide)

end Pokemon
