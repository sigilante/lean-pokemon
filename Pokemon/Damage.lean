import Pokemon.WellFormed

/-!
# Damage, Poison strength and damage bonuses: a clamp that makes them bounded

Three numeric components of the state can be made large by legal play: damage on either Active
Pokémon (inside an attack's effect, `counters_unbounded`; an attack or Checkup can leave it far
above HP, and the Knock Out is then the next move; one step of a Trainer card's effect can too,
and the Knock Out is taken at once, inside the same move), the Poison strength `poisonUp` of a
Poisoned Pokémon (`poisonUp_unbounded`), and the lingering modifiers (`Store`): a damage bonus
or reduction is added up without limit (`Effect.linger` inside `iter`).

* `InPlay.clampWith c` caps `poisonUp` at the printed HP and treats damage as `c : Cap` says:
  exact, capped at the printed HP (`Cap.hp`), or capped at a constant (`Cap.upto k`).
  `GameState.clampAt co cp k` applies `clampWith co` to the Active Pokémon of the player to move
  and `clampWith cp` to the opponent's, and caps every damage bonus and reduction in both
  players' stores at `k`; nothing else changes.
* `GameState.clamp k` is `clampAt .hp .hp k`: the clamp at move boundaries. `GameState.rclamp k`
  is `clampAt .exact (.upto k) k`: the relation used inside an attack's effect (`Pokemon/Sim`),
  where the player's own damage is read exactly and the opponent's above `k` is not.
* `KOMove.clamp_sim`, `Resolve.clamp_sim`: the kernel of `clamp k` is a simulation for Knock
  Outs. The effect and move simulations are in `Pokemon/Sim.lean`.
* `Move.damageBounded_of_startTurn`: the turn proper starts with no pending Knock Out.
  `Move.endTurn_pending_ko`: the earlier `Move.damageBounded_of_turn` is false with Checkup.
-/

namespace Pokemon

/-- How a clamp treats the damage on one Active Pokémon. -/
inductive Cap where
  /-- not capped -/
  | exact
  /-- capped at the Pokémon's printed HP -/
  | hp
  /-- capped at `k` -/
  | upto (k : Nat)

/-- The damage on `p` as the cap `c` sees it. -/
def Cap.dmg : Cap → InPlay → Nat
  | .exact, p => p.damage
  | .hp, p => min p.damage p.top.hp
  | .upto k, p => min p.damage k

/-- Poison strength capped at the printed HP, damage as `c` says. -/
def InPlay.clampWith (c : Cap) (p : InPlay) : InPlay :=
  { p with damage := c.dmg p, poisonUp := min p.poisonUp p.top.hp }

/-- Damage bonus and reduction capped at `k`. -/
def Mods.cap (k : Nat) (m : Mods) : Mods :=
  { m with bonus := min m.bonus k, reduce := min m.reduce k }

/-- Every damage bonus and reduction in a store capped at `k`. -/
def Store.cap (k : Nat) (t : Store) : Store :=
  ⟨t.now.cap k, t.next.cap k, t.after.cap k, t.always.cap k⟩

/-- Clamp the player's Active Pokémon by `co`, the opponent's by `cp`, and both players' damage
bonuses and reductions at `k`. Every other component, including the damage on every Benched
Pokémon, is unchanged. -/
def GameState.clampAt (co cp : Cap) (k : Nat) (g : GameState) : GameState :=
  { g with cur := { g.cur with active := g.cur.active.map (InPlay.clampWith co),
                               mods := g.cur.mods.cap k },
           opp := { g.opp with active := g.opp.active.map (InPlay.clampWith cp),
                               mods := g.opp.mods.cap k } }

/-- The clamp at move boundaries: damage and Poison strength on both Active Pokémon capped at
the printed HP, damage bonuses and reductions capped at `k`. -/
def GameState.clamp (k : Nat) (g : GameState) : GameState := g.clampAt .hp .hp k

/-- The relation used inside an attack's effect: the player's own damage exact, the opponent's
capped at `k`, bonuses and reductions capped at `k`. -/
def GameState.rclamp (k : Nat) (g : GameState) : GameState := g.clampAt .exact (.upto k) k

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

/-! ## Agreement of one Pokémon -/

namespace InPlay

/-- Two Pokémon with the same `clampWith c`: equal except in damage and Poison strength. -/
structure Agree (c : Cap) (q p : InPlay) : Prop where
  top : q.top = p.top
  under : q.under = p.under
  energy : q.energy = p.energy
  tools : q.tools = p.tools
  rot : q.rot = p.rot
  poisoned : q.poisoned = p.poisoned
  burned : q.burned = p.burned
  fresh : q.fresh = p.fresh
  marks : q.marks = p.marks
  damage : c.dmg q = c.dmg p
  poisonUp : min q.poisonUp q.top.hp = min p.poisonUp p.top.hp

theorem agree_of_clamp {c : Cap} {q p : InPlay} (h : q.clampWith c = p.clampWith c) :
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

theorem clamp_of_agree {c : Cap} {q p : InPlay} (h : Agree c q p) :
    q.clampWith c = p.clampWith c := by
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, h9, h10⟩ := h
  cases q; cases p
  simp only at h1 h2 h3 h4 h5 h6 h7 h8 h10 h11
  subst h1 h2 h3 h4 h5 h6 h7 h8 h11
  simp only [clampWith, h9, h10]

/-- The damage as a cap sees it depends only on the damage and the top card. -/
theorem dmg_congr (c : Cap) {q p : InPlay} (ht : q.top = p.top) (hd : q.damage = p.damage) :
    c.dmg q = c.dmg p := by
  cases c <;> simp only [Cap.dmg, ht, hd]

/-- Agreement of the capped damage carries over to updates that keep the top card and the
damage. -/
theorem Agree.dmg_of {c : Cap} {q p q' p' : InPlay} (h : Agree c q p) (h1 : q'.top = q.top)
    (h2 : q'.damage = q.damage) (h3 : p'.top = p.top) (h4 : p'.damage = p.damage) :
    c.dmg q' = c.dmg p' :=
  (dmg_congr c h1 h2).trans (h.damage.trans (dmg_congr c h3 h4).symm)

theorem Agree.damage_eq {q p : InPlay} (h : Agree .exact q p) : q.damage = p.damage := h.damage

theorem Agree.damage_eq_of_lt {q p : InPlay} (h : Agree .hp q p) (hl : p.damage < p.top.hp) :
    q.damage = p.damage := by
  have hd := h.damage
  simp only [Cap.dmg, h.top] at hd
  omega

theorem Agree.ko {q p : InPlay} (h : Agree .hp q p) (hk : p.top.hp ≤ p.damage) :
    q.top.hp ≤ q.damage := by
  have hd := h.damage
  simp only [Cap.dmg, h.top] at hd ⊢
  omega

theorem Agree.lt {q p : InPlay} (h : Agree .hp q p) (hl : p.damage < p.top.hp) :
    q.damage < q.top.hp := by
  rw [h.damage_eq_of_lt hl, h.top]; exact hl

theorem Agree.cardList {c : Cap} {q p : InPlay} (h : Agree c q p) : q.cardList = p.cardList := by
  simp only [InPlay.cardList, h.top, h.under, h.energy, h.tools]

/-- Agreement with equal damage, at any cap. -/
theorem Agree.recap {c c' : Cap} {q p : InPlay} (h : Agree c q p) (hd : q.damage = p.damage) :
    Agree c' q p :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks,
    dmg_congr c' h.top hd, h.poisonUp⟩

/-- Agreement capped at `k` gives agreement at HP for a Pokémon whose HP is at most `k`. -/
theorem Agree.hp_of_upto {k : Nat} {q p : InPlay} (h : Agree (.upto k) q p)
    (hk : p.top.hp ≤ k) : Agree .hp q p := by
  have hd := h.damage
  simp only [Cap.dmg] at hd
  refine ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks, ?_,
    h.poisonUp⟩
  simp only [Cap.dmg, h.top]
  omega

/-- Below HP, agreement at HP is agreement with equal damage. -/
theorem Agree.exact_of_hp {q p : InPlay} (h : Agree .hp q p) (hl : p.damage < p.top.hp) :
    Agree .exact q p :=
  h.recap (h.damage_eq_of_lt hl)

/-- With equal damage, agreeing Pokémon differ at most in Poison strength. -/
theorem Agree.eq_upd {c : Cap} {q p : InPlay} (h : Agree c q p) (hd : q.damage = p.damage) :
    q = { p with poisonUp := q.poisonUp } := by
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, _, _⟩ := h
  cases q; cases p
  simp only at h1 h2 h3 h4 h5 h6 h7 h8 h11 hd
  subst h1 h2 h3 h4 h5 h6 h7 h8 h11 hd
  rfl

theorem clampWith_setPoisonUp {c : Cap} (x : InPlay) (u : Nat)
    (h : min u x.top.hp = min x.poisonUp x.top.hp) :
    clampWith c { x with poisonUp := u } = clampWith c x := by
  have hd : c.dmg { x with poisonUp := u } = c.dmg x := dmg_congr c rfl rfl
  simp only [clampWith, hd, h]

/-- Agreeing Pokémon with equal damage stay agreeing under an update `U` that touches neither
the top card nor the Poison strength. -/
theorem Agree.clamp_map {c c' : Cap} {q p : InPlay} (h : Agree c q p)
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

/-- Adding damage preserves agreement, at any cap. -/
theorem Agree.dmg_add {c : Cap} {q p : InPlay} (h : Agree c q p) (n : Nat) :
    c.dmg { q with damage := q.damage + n } = c.dmg { p with damage := p.damage + n } := by
  have hd := h.damage
  cases c <;> simp only [Cap.dmg, h.top] at hd ⊢ <;> omega

/-- Adding amounts that agree at the cap `k` preserves agreement at `k`. -/
theorem Agree.dmg_add_upto {k : Nat} {q p : InPlay} (h : Agree (.upto k) q p) {a b : Nat}
    (hab : min a k = min b k) :
    Cap.dmg (.upto k) { q with damage := q.damage + a } =
      Cap.dmg (.upto k) { p with damage := p.damage + b } := by
  have hd := h.damage
  simp only [Cap.dmg] at hd ⊢
  omega

end InPlay

open InPlay in
/-- Agreement survives every update the moves and effects make to one Pokémon. -/
theorem InPlay.Agree.upd {c : Cap} {q p : InPlay} (h : Agree c q p) :
    (∀ e, Agree c { q with energy := e } { p with energy := e }) ∧
    (∀ n, Agree c { q with damage := q.damage + n } { p with damage := p.damage + n }) ∧
    (∀ n, Agree c { q with poisonUp := q.poisonUp + n } { p with poisonUp := p.poisonUp + n }) ∧
    (∀ k, Agree c (q.inflict k) (p.inflict k)) ∧
    Agree c q.cure p.cure ∧ Agree c q.unfresh p.unfresh := by
  refine ⟨fun e => ⟨h.top, h.under, rfl, h.tools, h.rot, h.poisoned, h.burned, h.fresh,
      h.marks, h.dmg_of rfl rfl rfl rfl, h.poisonUp⟩,
    fun n => ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks,
      h.dmg_add n, h.poisonUp⟩,
    fun n => ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks,
      h.dmg_of rfl rfl rfl rfl, ?_⟩,
    fun k => ?_,
    ⟨h.top, h.under, h.energy, h.tools, rfl, rfl, rfl, h.fresh, h.marks,
      h.dmg_of rfl rfl rfl rfl, by simp [InPlay.cure]⟩,
    ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, rfl, h.marks,
      h.dmg_of rfl rfl rfl rfl, h.poisonUp⟩⟩
  · show min (q.poisonUp + n) q.top.hp = min (p.poisonUp + n) p.top.hp
    have hu := h.poisonUp
    rw [h.top] at hu ⊢; omega
  · have hd : c.dmg (q.inflict k) = c.dmg (p.inflict k) := by
      cases k <;> exact h.dmg_of rfl rfl rfl rfl
    cases k <;>
      exact ⟨h.top, h.under, h.energy, h.tools, by first | rfl | exact h.rot,
        by first | rfl | exact h.poisoned, by first | rfl | exact h.burned, h.fresh, h.marks,
        hd, h.poisonUp⟩

/-- Agreement survives a change of markers. -/
theorem InPlay.Agree.setMarks {c : Cap} {q p : InPlay} (h : Agree c q p) (f : Marks → Marks) :
    Agree c (q.setMarks f) (p.setMarks f) :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh,
    by simp only [InPlay.setMarks, h.marks], h.dmg_of rfl rfl rfl rfl, h.poisonUp⟩

theorem InPlay.clampWith_setMarks (c : Cap) (f : Marks → Marks) :
    InPlay.clampWith c ∘ InPlay.setMarks f = InPlay.setMarks f ∘ InPlay.clampWith c := by
  funext x
  have hd : c.dmg (x.setMarks f) = c.dmg x := InPlay.dmg_congr c rfl rfl
  show InPlay.clampWith c (x.setMarks f) = InPlay.setMarks f (InPlay.clampWith c x)
  unfold InPlay.clampWith
  rw [hd]
  rfl

/-- Changing markers on an Active Spot commutes with agreement. -/
theorem map_clamp_setMarks {c : Cap} (f : Marks → Marks) {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith c) = o₁.map (InPlay.clampWith c)) :
    (o₂.map (InPlay.setMarks f)).map (InPlay.clampWith c) =
      (o₁.map (InPlay.setMarks f)).map (InPlay.clampWith c) := by
  rw [Option.map_map, Option.map_map, InPlay.clampWith_setMarks, ← Option.map_map,
    ← Option.map_map, h]

/-- Checkup preserves agreement when the damage is equal, and then the results agree with
damage capped at HP. -/
theorem InPlay.Agree.checkup {c : Cap} {q p : InPlay} (h : Agree c q p)
    (hd : q.damage = p.damage) (o f s t : Bool) :
    Agree .hp (q.checkup o f s t) (p.checkup o f s t) := by
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
theorem InPlay.Agree.setDamage {c : Cap} {q p : InPlay} (h : Agree c q p) (d : Nat) :
    Agree c { q with damage := d } { p with damage := d } :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks,
    InPlay.dmg_congr c h.top rfl, h.poisonUp⟩

/-- Tests read only what agreement capped at `k` keeps equal, when their constants are below
`k`: a damage test against `n < k` cannot tell two damages apart that are equal or both at
least `k`. -/
theorem Test.eval_agree (t : Test) {k : Nat} {q p : InPlay} (h : InPlay.Agree (.upto k) q p)
    (hb : t.bound < k) : t.eval q = t.eval p := by
  have hd := h.damage
  simp only [Cap.dmg] at hd
  cases t with
  | atLeast w n =>
      simp only [Test.bound] at hb
      simp only [Test.eval]
      apply Bool.eq_iff_iff.2
      simp only [Nat.ble_eq]
      constructor <;> intro <;> omega
  | exactly w n =>
      simp only [Test.bound] at hb
      simp only [Test.eval]
      apply Bool.eq_iff_iff.2
      simp only [Nat.beq_eq]
      constructor <;> intro <;> omega
  | cond w c => cases c <;> simp only [Test.eval, InPlay.has, h.poisoned, h.burned, h.rot]
  | marked w m => simp only [Test.eval, h.marks]
  | isType w t =>
      have e : q.type = p.type := by simp only [InPlay.type, h.marks, h.top]
      show decide (q.type = t) = decide (p.type = t)
      rw [e]

/-! ## Capped stores -/

theorem Mods.cap_iff {k : Nat} {a b : Mods} :
    a.cap k = b.cap k ↔ min a.bonus k = min b.bonus k ∧ min a.reduce k = min b.reduce k ∧
      a.prevent = b.prevent ∧ a.noAttack = b.noAttack ∧ a.noRetreat = b.noRetreat ∧
      a.noItem = b.noItem := by
  cases a; cases b
  simp only [Mods.cap, Mods.mk.injEq]

theorem Store.cap_iff {k : Nat} {a b : Store} :
    a.cap k = b.cap k ↔ a.now.cap k = b.now.cap k ∧ a.next.cap k = b.next.cap k ∧
      a.after.cap k = b.after.cap k ∧ a.always.cap k = b.always.cap k := by
  cases a; cases b
  simp only [Store.cap, Store.mk.injEq]

theorem Mods.cap_merge {k : Nat} {a₁ a₂ b₁ b₂ : Mods} (ha : a₁.cap k = a₂.cap k)
    (hb : b₁.cap k = b₂.cap k) : (a₁.merge b₁).cap k = (a₂.merge b₂).cap k := by
  rw [Mods.cap_iff] at ha hb ⊢
  obtain ⟨a1, a2, a3, a4, a5, a6⟩ := ha
  obtain ⟨b1, b2, b3, b4, b5, b6⟩ := hb
  simp only [Mods.merge, a3, a4, a5, a6, b3, b4, b5, b6, and_true]
  exact ⟨by omega, by omega⟩

theorem Mods.cap_addMod {k : Nat} {a b : Mods} (h : a.cap k = b.cap k) (m : Mod) :
    (a.addMod m).cap k = (b.addMod m).cap k := by
  rw [Mods.cap_iff] at h ⊢
  obtain ⟨h1, h2, h3, h4, h5, h6⟩ := h
  cases m with
  | bonus n => simp only [Mods.addMod]; exact ⟨by omega, h2, h3, h4, h5, h6⟩
  | reduce n => simp only [Mods.addMod]; exact ⟨h1, by omega, h3, h4, h5, h6⟩
  | prevent => exact ⟨h1, h2, rfl, h4, h5, h6⟩
  | lock l => cases l <;> simp only [Mods.addMod] <;> simp only [*, and_self]

/-- The modifiers in effect agree at the cap when the stores do. -/
theorem Store.live_cap {k : Nat} {a b : Store} (h : a.cap k = b.cap k) :
    a.live.cap k = b.live.cap k := by
  rw [Store.cap_iff] at h
  exact Mods.cap_merge h.1 h.2.2.2

theorem Store.cap_add {k : Nat} {a b : Store} (h : a.cap k = b.cap k) (s : Slot) (m : Mod) :
    (a.add s m).cap k = (b.add s m).cap k := by
  rw [Store.cap_iff] at h ⊢
  obtain ⟨h1, h2, h3, h4⟩ := h
  cases s with
  | now => exact ⟨Mods.cap_addMod h1 m, h2, h3, h4⟩
  | next => exact ⟨h1, Mods.cap_addMod h2 m, h3, h4⟩
  | after => exact ⟨h1, h2, Mods.cap_addMod h3 m, h4⟩
  | always => exact ⟨h1, h2, h3, Mods.cap_addMod h4 m⟩

theorem Store.cap_shift {k : Nat} {a b : Store} (h : a.cap k = b.cap k) :
    a.shift.cap k = b.shift.cap k := by
  rw [Store.cap_iff] at h ⊢
  exact ⟨h.2.1, h.2.2.1, rfl, h.2.2.2⟩

/-! ## No damage reduction -/

/-- No damage reduction anywhere in a store. -/
def Store.NoReduce (t : Store) : Prop :=
  t.now.reduce = 0 ∧ t.next.reduce = 0 ∧ t.after.reduce = 0 ∧ t.always.reduce = 0

/-- No damage reduction in either player's store. -/
def GameState.NoReduce (g : GameState) : Prop := g.cur.mods.NoReduce ∧ g.opp.mods.NoReduce

theorem Store.NoReduce.live {t : Store} (h : t.NoReduce) : t.live.reduce = 0 := by
  simp only [Store.live, Mods.merge, h.1, h.2.2.2]

theorem Store.NoReduce.add {t : Store} (h : t.NoReduce) (s : Slot) (m : Mod)
    (hm : ∀ n, m ≠ .reduce n) : (t.add s m).NoReduce := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  cases m with
  | reduce n => exact absurd rfl (hm n)
  | bonus n => cases s <;> exact ⟨h1, h2, h3, h4⟩
  | prevent => cases s <;> exact ⟨h1, h2, h3, h4⟩
  | lock l => cases s <;> cases l <;> exact ⟨h1, h2, h3, h4⟩

theorem Store.NoReduce.shift {t : Store} (h : t.NoReduce) : t.shift.NoReduce :=
  ⟨h.2.1, h.2.2.1, rfl, h.2.2.2⟩

theorem Store.NoReduce.of_cap {k : Nat} (hk : 0 < k) {a b : Store} (h : a.cap k = b.cap k)
    (hb : b.NoReduce) : a.NoReduce := by
  rw [Store.cap_iff] at h
  obtain ⟨h1, h2, h3, h4⟩ := h
  rw [Mods.cap_iff] at h1 h2 h3 h4
  obtain ⟨b1, b2, b3, b4⟩ := hb
  refine ⟨?_, ?_, ?_, ?_⟩ <;> omega

/-- With no damage reduction, the damage done is the base damage plus the bonus, or nothing. -/
theorem dealtBy_of_noReduce {own opp : Store} (h : opp.NoReduce) (n : Nat) :
    dealtBy n own opp = if opp.live.prevent then 0 else n + own.live.bonus := by
  simp only [dealtBy, h.live, Nat.sub_zero]

/-- With no damage reduction, damage done agrees at the cap `k` when the stores do. -/
theorem dealtBy_cap {k : Nat} (hk : 0 < k) {c₁ c₂ o₁ o₂ : Store} (hc : c₂.cap k = c₁.cap k)
    (ho : o₂.cap k = o₁.cap k) (hn : o₁.NoReduce) (n : Nat) :
    min (dealtBy n c₂ o₂) k = min (dealtBy n c₁ o₁) k := by
  have hn₂ := Store.NoReduce.of_cap hk ho hn
  rw [dealtBy_of_noReduce hn, dealtBy_of_noReduce hn₂]
  have hc' := Mods.cap_iff.1 (Store.live_cap hc)
  have ho' := Mods.cap_iff.1 (Store.live_cap ho)
  rw [ho'.2.2.1]
  split
  · rfl
  · omega

/-- The flags in effect agree when the stores agree at a cap. -/
theorem Store.flags_of_cap {k : Nat} {a b : Store} (h : a.cap k = b.cap k) :
    a.live.prevent = b.live.prevent ∧ a.live.noAttack = b.live.noAttack ∧
      a.live.noRetreat = b.live.noRetreat ∧ a.live.noItem = b.live.noItem :=
  (Mods.cap_iff.1 (Store.live_cap h)).2.2

/-! ## Agreement of states -/

/-- Two states with the same `clampAt co cp k` differ at most in the two Active Pokémon, as
`Agree` allows, and in the damage bonuses and reductions above `k`. -/
theorem GameState.clamp_inv {co cp : Cap} {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.clampAt co cp k = g₂.clampAt co cp k) :
    ∃ c₂ a₂ m₁ m₂, g₂ = { g₁ with cur := { g₁.cur with active := c₂, mods := m₁ },
                                  opp := { g₁.opp with active := a₂, mods := m₂ } } ∧
      c₂.map (InPlay.clampWith co) = g₁.cur.active.map (InPlay.clampWith co) ∧
      a₂.map (InPlay.clampWith cp) = g₁.opp.active.map (InPlay.clampWith cp) ∧
      m₁.cap k = g₁.cur.mods.cap k ∧ m₂.cap k = g₁.opp.mods.cap k := by
  refine ⟨g₂.cur.active, g₂.opp.active, g₂.cur.mods, g₂.opp.mods, ?_,
    (congrArg (fun g => g.cur.active) h).symm, (congrArg (fun g => g.opp.active) h).symm,
    (congrArg (fun g => g.cur.mods) h).symm, (congrArg (fun g => g.opp.mods) h).symm⟩
  have e : g₂ = { g₂.clampAt co cp k with
      cur := { (g₂.clampAt co cp k).cur with active := g₂.cur.active, mods := g₂.cur.mods },
      opp := { (g₂.clampAt co cp k).opp with active := g₂.opp.active, mods := g₂.opp.mods } } :=
    rfl
  refine e.trans ?_
  rw [← h]
  rfl

/-- From `o.map f = some (f a)`, a `q` with `o = some q` that agrees with `a`. -/
theorem agree_of_map {c : Cap} {o : Option InPlay} {a : InPlay}
    (h : o.map (InPlay.clampWith c) = (some a).map (InPlay.clampWith c)) :
    ∃ q, o = some q ∧ InPlay.Agree c q a := by
  rw [Option.map_some] at h
  obtain ⟨q, rfl, hq⟩ := Option.map_eq_some_iff.1 h
  exact ⟨q, rfl, InPlay.agree_of_clamp hq⟩

theorem none_of_map {c : Cap} {o : Option InPlay}
    (h : o.map (InPlay.clampWith c) = (none : Option InPlay).map (InPlay.clampWith c)) :
    o = none :=
  Option.map_eq_none_iff.1 h

/-- Equal damage gives agreement at any cap. -/
theorem map_recap {c : Cap} {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith .exact) = o₁.map (InPlay.clampWith .exact)) :
    o₂.map (InPlay.clampWith c) = o₁.map (InPlay.clampWith c) := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [Option.map_some, InPlay.clamp_of_agree (hq.recap (c' := c) hq.damage_eq)]

/-- Below HP, agreement at HP gives equal damage. -/
theorem map_exact_of_hp {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith .hp) = o₁.map (InPlay.clampWith .hp))
    (hk : ∀ p, o₁ = some p → p.damage < p.top.hp) :
    o₂.map (InPlay.clampWith .exact) = o₁.map (InPlay.clampWith .exact) := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [Option.map_some, InPlay.clamp_of_agree (hq.exact_of_hp (hk p rfl))]

/-- For a Pokémon with HP at most `k`, agreement capped at `k` gives agreement at HP. -/
theorem map_hp_of_upto {k : Nat} {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith (.upto k)) = o₁.map (InPlay.clampWith (.upto k)))
    (hk : ∀ p, o₁ = some p → p.top.hp ≤ k) :
    o₂.map (InPlay.clampWith .hp) = o₁.map (InPlay.clampWith .hp) := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [Option.map_some, InPlay.clamp_of_agree (hq.hp_of_upto (hk p rfl))]

/-- The Active Pokémon read by a test, in states with the same `rclamp k`: they agree with
damage capped at `k` (the player's own agree exactly). -/
theorem GameState.activeOf_agree {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.rclamp k = g₂.rclamp k) {w : Whose} {p : InPlay} (hp : g₁.activeOf w = some p) :
    ∃ q, g₂.activeOf w = some q ∧ InPlay.Agree (.upto k) q p := by
  cases w with
  | own =>
      have e := (congrArg (fun g => g.cur.active) h).symm
      simp only [GameState.rclamp, GameState.clampAt] at e
      rw [show g₁.cur.active = some p from hp] at e
      obtain ⟨q, hq, ha⟩ := agree_of_map e
      exact ⟨q, hq, ha.recap ha.damage_eq⟩
  | opp =>
      have e := (congrArg (fun g => g.opp.active) h).symm
      simp only [GameState.rclamp, GameState.clampAt] at e
      rw [show g₁.opp.active = some p from hp] at e
      exact agree_of_map e

/-- With no pending Knock Out, equal `clamp k` gives equal `rclamp k`. -/
theorem GameState.rclamp_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k)
    (hk : DamageBounded g₁) : g₁.rclamp k = g₂.rclamp k := by
  obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv h
  simp only [GameState.rclamp, GameState.clampAt, hm₁, hm₂,
    map_exact_of_hp hc₂ fun p hp => hk p (Or.inl hp),
    map_recap (c := .upto k) (map_exact_of_hp ha₂ fun p hp => hk p (Or.inr (Or.inr (Or.inl hp))))]

/-- Equal `rclamp k` gives equal `clamp k` when the opponent's Active Pokémon has HP at most
`k`. -/
theorem GameState.clamp_of_rclamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.rclamp k = g₂.rclamp k)
    (hk : ∀ p, g₁.opp.active = some p → p.top.hp ≤ k) : g₁.clamp k = g₂.clamp k := by
  obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv h
  simp only [GameState.clamp, GameState.clampAt, hm₁, hm₂, map_recap (c := .hp) hc₂,
    map_hp_of_upto ha₂ hk]

theorem GameState.damageBounded_of_clamp {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.clamp k = g₂.clamp k) (hk : DamageBounded g₁) : DamageBounded g₂ := by
  obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, _, _⟩ := GameState.clamp_inv h
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

theorem GameState.settled_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k)
    (hs : Settled g₁) : Settled g₂ := by
  refine ⟨GameState.damageBounded_of_clamp h hs.1, fun hn => hs.2.1 ?_, fun hn => hs.2.2 ?_⟩
  · have e := congrArg (fun g => g.cur.active) h
    simp only [GameState.clamp, GameState.clampAt, hn, Option.map_none] at e
    exact Option.map_eq_none_iff.1 e
  · have e := congrArg (fun g => g.opp.active) h
    simp only [GameState.clamp, GameState.clampAt, hn, Option.map_none] at e
    exact Option.map_eq_none_iff.1 e

theorem GameState.winner_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k) :
    g₂.winner = g₁.winner :=
  (congrArg GameState.winner h).symm

/-! ## Knock Outs -/

/-- The kernel of `clamp k` is a simulation for Knock Out moves. -/
theorem KOMove.clamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} (h : KOMove g₁ g₁')
    (hc : g₁.clamp k = g₂.clamp k) : ∃ g₂', KOMove g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  obtain ⟨c₂, a₂, m₁, m₂, hg, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
  subst hg
  cases h with
  | knockOut ha hk hp =>
      rw [ha] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .knockOut rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_none, hc₂, hm₁, hm₂,
          hq.cardList]⟩
  | promote ha hb =>
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .promote rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, hm₁, hm₂]⟩
  | noPokemon ha hb =>
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .noPokemon rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, hm₁, hm₂, ha, Option.map_none]⟩
  | knockOutOwn ha hk hp =>
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .knockOutOwn rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_none, ha₂, hm₁, hm₂,
          hq.cardList]⟩
  | promoteOwn ha hb =>
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .promoteOwn rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, ha₂, hm₁, hm₂]⟩
  | noPokemonOwn ha hb =>
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .noPokemonOwn rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, ha₂, hm₁, hm₂, ha, Option.map_none]⟩

/-- The kernel of `clamp k` is a simulation for taking the Knock Outs. -/
theorem Resolve.clamp_sim {k : Nat} {g₁ g₁' : GameState} (h : Resolve g₁ g₁') :
    ∀ {g₂ : GameState}, g₁.clamp k = g₂.clamp k →
      ∃ g₂', Resolve g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
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

/-- The largest test constant in the effects of a list of cards. -/
def cardsTmax : List Card → Nat
  | [] => 0
  | c :: cs => max c.tmax (cardsTmax cs)

theorem tmax_le_cardsTmax {x : Card} : ∀ {cs : List Card}, x ∈ cs → x.tmax ≤ cardsTmax cs
  | [], h => nomatch h
  | c :: cs, h => by
      cases h with
      | head => simp only [cardsTmax]; omega
      | tail _ h =>
          have := tmax_le_cardsTmax h
          simp only [cardsTmax]; omega

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

theorem GameState.mem_allCards_of_hand {g : GameState} {x : Card} (hx : x ∈ g.cur.hand) :
    x ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, hx]

/-! ## The old turn-boundary statement fails: Checkup leaves a pending Knock Out -/

/-- A Basic Pokémon with 10 HP (one counter). -/
def cxCard : PokemonCard := ⟨"", .basic, none, 1, .grass, [], 0⟩

def cxSide (a : InPlay) : PlayerState :=
  ⟨[], [], [], [], [], some a, [], none, false, false, false, false, false, Store.empty⟩

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
  refine ⟨cxState, _, .endTurn false false false false false false rfl rfl hk rfl, hk,
    by decide, ?_⟩
  intro hk'
  have := hk' _ (Or.inl rfl)
  exact absurd this (by decide)

end Pokemon
