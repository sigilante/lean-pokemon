import Pokemon.WellFormed

/-!
# Damage, Poison strength and damage bonuses: a clamp that makes them bounded

Three numeric components of the state can be made large by legal play: damage on either Active
Pokémon (inside an attack's effect, `counters_unbounded`; an attack or Checkup can leave it far
above HP, and the Knock Out is then the next move; one step of a Trainer card's effect can too,
and the Knock Out is taken at once, inside the same move), the Poison strength `poisonUp` of a
Poisoned Pokémon (`poisonUp_unbounded`), and the lingering modifiers (`Store`): a damage bonus
or reduction is added up without limit (`Effect.linger` inside `iter`).

* `InPlay.clampWith K c` caps `poisonUp` at the bound `K` and treats damage as `c : Cap` says:
  exact, capped at `K` (`Cap.hp`), or capped at a constant (`Cap.upto k`). Since milestone M6 HP
  is derived (`GameState.hpOf`) and `K` must bound every derived HP (`hpBound`); before M6 the
  caps were the printed HP.
  `GameState.clampAt co cp cbo cbp k` applies `clampWith co` to the Active Pokémon of the player
  to move, `clampWith cp` to the opponent's, `clampWith cbo` and `clampWith cbp` to their Benched
  Pokémon (milestone M3), and caps every damage bonus and reduction in both players' stores at
  `k`; nothing else changes.
* `GameState.clamp k` is `clampAt .hp .hp .hp .hp k`: the clamp at move boundaries (damage and
  Poison strength capped at `k`; `clampAt` caps the stores at `2 * k` itself, milestone M6).
  `GameState.rclamp k` is `clampAt .exact (.upto k) .exact (.upto k) k`: the relation used
  inside an attack's effect (`Pokemon/Sim`), where the player's own damage (Active and Bench) is
  read exactly and the opponent's above `k` is not. The stores are capped at twice the damage cap because Resistance
  is subtracted after the bonus (`dealtBy_cap`; milestone M4).
* `KOBatch.clamp_sim`, `Resolve.clamp_sim`: the kernel of `clamp k` is a simulation for the
  batch Knock Out step (the check commutes with the clamp, `GameState.koStep_clamp`). The effect and move simulations are in `Pokemon/Sim.lean`.
* `Move.damageBounded_of_startTurn`: the turn proper starts with no pending Knock Out.
  `Move.endTurn_pending_ko`: the earlier `Move.damageBounded_of_turn` is false with Checkup.
-/

namespace Pokemon

/-- How a clamp treats the damage on one Pokémon in play. -/
inductive Cap where
  /-- not capped -/
  | exact
  /-- capped at the clamp's bound `K`, a bound on every HP (milestone M6: before it, the
  Pokémon's printed HP) -/
  | hp
  /-- capped at `k` -/
  | upto (k : Nat)

/-- The damage on `p` as the cap `c` sees it, for a clamp with bound `K`. Since milestone M6 HP
is derived from the state (`GameState.hpOf`) and can rise above the printed HP, so `.hp` caps at
`K`, which the theorems require to bound every derived HP (`hpBound`), not at the printed HP. -/
def Cap.dmg (K : Nat) : Cap → InPlay → Nat
  | .exact, p => p.damage
  | .hp, p => min p.damage K
  | .upto k, p => min p.damage k

/-- Poison strength capped at the bound `K`, damage as `c` says. (Before milestone M6 the Poison
strength was capped at the printed HP; with derived HP above the printed HP that cap loses a Knock
Out at Checkup.) -/
def InPlay.clampWith (K : Nat) (c : Cap) (p : InPlay) : InPlay :=
  { p with damage := c.dmg K p, poisonUp := min p.poisonUp K }

/-- Damage bonus and reduction capped at `k`. -/
def Mods.cap (k : Nat) (m : Mods) : Mods :=
  { m with bonus := min m.bonus k, reduce := min m.reduce k }

/-- Every damage bonus and reduction in a store capped at `k`. -/
def Store.cap (k : Nat) (t : Store) : Store :=
  ⟨t.now.cap k, t.next.cap k, t.after.cap k, t.always.cap k⟩

/-- Clamp the player's Active Pokémon by `co`, the opponent's by `cp`, every Benched Pokémon of
the player to move by `cbo` and of the opponent by `cbp`, all with bound `k` (damage at `.hp` and
Poison strength capped at `k`), and both players' damage bonuses and reductions at `2 * k` (milestone
M6: the argument is the damage bound; before it, the argument was the store cap and the clamps
passed `2 * k`). Every other
component is unchanged. (Before milestone M3 the Benches were not clamped: no Benched Pokémon
could be damaged, and every Benched Pokémon was below its HP.) -/
def GameState.clampAt (co cp cbo cbp : Cap) (k : Nat) (g : GameState) : GameState :=
  { g with cur := { g.cur with active := g.cur.active.map (InPlay.clampWith k co),
                               bench := g.cur.bench.map (InPlay.clampWith k cbo),
                               mods := g.cur.mods.cap (2 * k) },
           opp := { g.opp with active := g.opp.active.map (InPlay.clampWith k cp),
                               bench := g.opp.bench.map (InPlay.clampWith k cbp),
                               mods := g.opp.mods.cap (2 * k) } }

/-- The clamp at move boundaries: damage and Poison strength on every Pokémon in play (both
Active Pokémon and, since milestone M3, every Benched Pokémon) capped at `k` (milestone M6: before
it, at the printed HP; the theorems take `k` at least every derived HP), damage bonuses and
reductions capped at `2 * k`. The stores are capped at twice
the damage cap because Resistance subtracts a card constant after the bonus is added: a bonus of
`2 * k` or more still does at least `k` damage after a Resistance of at most `k`
(`dealtBy_cap`); with the stores capped at `k` itself the kernel would not be a simulation (a
bonus of `k` and of `k + 1` against Resistance 3 do `k - 2` and `k - 1` damage from base damage
1). Weakness doubles, which can only raise the damage, and needs no larger cap. -/
def GameState.clamp (k : Nat) (g : GameState) : GameState := g.clampAt .hp .hp .hp .hp k

/-- The relation used inside an attack's effect: the damage on the player's own Pokémon (Active
and Benched) exact, on the opponent's Pokémon (Active and Benched) capped at `k` (Poison strength
capped at `k` throughout; milestone M6: before it, at the printed HP), bonuses and reductions capped
at `2 * k`. The opponent's Bench is
capped like the opponent's Active Pokémon because an effect can switch the two (`Effect.switch`,
milestone M3), and no effect reads the damage on the opponent's Benched Pokémon except to add
damage counters to it. -/
def GameState.rclamp (k : Nat) (g : GameState) : GameState :=
  g.clampAt .exact (.upto k) .exact (.upto k) k

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
  | startTurn hbt ha hb hk hd => exact hk.congr rfl rfl rfl rfl rfl rfl
  | onPlay hp => exact absurd (hb.symm.trans hp.between) (by decide)
  | knockOuts h _ ht =>
      exact absurd (hb.symm.trans (h.same.2.2.2.1.symm.trans (ht.zoneOnly.between.symm.trans hb')))
        (by decide)
  | _ =>
      first
      | exact absurd (hb.symm.trans hb') (by decide)
      | exact absurd (hb.symm.trans ‹g.between = false›) (by decide)
      | exact absurd hb' (by decide)

/-! ## Agreement of one Pokémon -/

namespace InPlay

/-- Two Pokémon with the same `clampWith K c`: equal except in damage and Poison strength. -/
structure Agree (K : Nat) (c : Cap) (q p : InPlay) : Prop where
  top : q.top = p.top
  under : q.under = p.under
  energy : q.energy = p.energy
  tools : q.tools = p.tools
  rot : q.rot = p.rot
  poisoned : q.poisoned = p.poisoned
  burned : q.burned = p.burned
  fresh : q.fresh = p.fresh
  marks : q.marks = p.marks
  used : q.used = p.used
  damage : c.dmg K q = c.dmg K p
  poisonUp : min q.poisonUp K = min p.poisonUp K

theorem agree_of_clamp {c : Cap} {q p : InPlay} (h : q.clampWith K c = p.clampWith K c) :
    Agree K c q p := by
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
  have h12 := congrArg InPlay.used h
  exact ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, h12, h9, h10⟩

theorem clamp_of_agree {c : Cap} {q p : InPlay} (h : Agree K c q p) :
    q.clampWith K c = p.clampWith K c := by
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, h12, h9, h10⟩ := h
  cases q; cases p
  simp only at h1 h2 h3 h4 h5 h6 h7 h8 h10 h11 h12
  subst h1 h2 h3 h4 h5 h6 h7 h8 h11 h12
  simp only [clampWith, h9, h10]

/-- The damage as a cap sees it depends only on the damage (since milestone M6; before it, on the
top card too, whose printed HP was the cap; the hypothesis on the top card is kept). -/
theorem dmg_congr (K : Nat) (c : Cap) {q p : InPlay} (_ht : q.top = p.top)
    (hd : q.damage = p.damage) : c.dmg K q = c.dmg K p := by
  cases c <;> simp only [Cap.dmg, hd]

/-- Agreement of the capped damage carries over to updates that keep the top card and the
damage. -/
theorem Agree.dmg_of {c : Cap} {q p q' p' : InPlay} (h : Agree K c q p) (h1 : q'.top = q.top)
    (h2 : q'.damage = q.damage) (h3 : p'.top = p.top) (h4 : p'.damage = p.damage) :
    c.dmg K q' = c.dmg K p' :=
  (dmg_congr K c h1 h2).trans (h.damage.trans (dmg_congr K c h3 h4).symm)

theorem Agree.damage_eq {q p : InPlay} (h : Agree K .exact q p) : q.damage = p.damage := h.damage

theorem Agree.damage_eq_of_lt {q p : InPlay} (h : Agree K .hp q p) (hl : p.damage < K) :
    q.damage = p.damage := by
  have hd := h.damage
  simp only [Cap.dmg] at hd
  omega

/-- Agreement at the bound `K` keeps a Knock Out at any HP `H ≤ K` (milestone M6: the HP is
derived, and equal in both states, `GameState.SameField.hpOf`). -/
theorem Agree.ko {q p : InPlay} (h : Agree K .hp q p) {H : Nat} (hH : H ≤ K)
    (hk : H ≤ p.damage) : H ≤ q.damage := by
  have hd := h.damage
  simp only [Cap.dmg] at hd
  omega

theorem Agree.lt {q p : InPlay} (h : Agree K .hp q p) {H : Nat} (hH : H ≤ K)
    (hl : p.damage < H) : q.damage < H := by
  rw [h.damage_eq_of_lt (Nat.lt_of_lt_of_le hl hH)]; exact hl

/-- Agreeing Pokémon have the same view (`InPlay.sv`): the same derived quantities. -/
theorem Agree.sv {c : Cap} {q p : InPlay} (h : Agree K c q p) : q.sv = p.sv := by
  simp only [InPlay.sv, h.top, h.energy, h.tools]

theorem Agree.cardList {c : Cap} {q p : InPlay} (h : Agree K c q p) : q.cardList = p.cardList := by
  simp only [InPlay.cardList, h.top, h.under, h.energy, h.tools]

/-- Agreement with equal damage, at any cap. -/
theorem Agree.recap {c c' : Cap} {q p : InPlay} (h : Agree K c q p) (hd : q.damage = p.damage) :
    Agree K c' q p :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks, h.used,
    dmg_congr K c' h.top hd, h.poisonUp⟩

/-- Agreement capped at the bound `K` is agreement at `.hp` (milestone M6: `.hp` caps at `K`; before
it, this needed the Pokémon's HP to be at most `k`). -/
theorem Agree.hp_of_upto {q p : InPlay} (h : Agree K (.upto K) q p) : Agree K .hp q p :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks, h.used,
    h.damage, h.poisonUp⟩

/-- Below the bound, agreement at `.hp` is agreement with equal damage. -/
theorem Agree.exact_of_hp {q p : InPlay} (h : Agree K .hp q p) (hl : p.damage < K) :
    Agree K .exact q p :=
  h.recap (h.damage_eq_of_lt hl)

/-- With equal damage, agreeing Pokémon differ at most in Poison strength. -/
theorem Agree.eq_upd {c : Cap} {q p : InPlay} (h : Agree K c q p) (hd : q.damage = p.damage) :
    q = { p with poisonUp := q.poisonUp } := by
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h11, h12, _, _⟩ := h
  cases q; cases p
  simp only at h1 h2 h3 h4 h5 h6 h7 h8 h11 h12 hd
  subst h1 h2 h3 h4 h5 h6 h7 h8 h11 h12 hd
  rfl

theorem clampWith_setPoisonUp {c : Cap} (x : InPlay) (u : Nat)
    (h : min u K = min x.poisonUp K) :
    clampWith K c { x with poisonUp := u } = clampWith K c x := by
  have hd : c.dmg K { x with poisonUp := u } = c.dmg K x := dmg_congr K c rfl rfl
  simp only [clampWith, hd, h]

/-- Agreeing Pokémon with equal damage stay agreeing under an update `U` that touches neither
the top card nor the Poison strength. -/
theorem Agree.clamp_map {c c' : Cap} {q p : InPlay} (h : Agree K c q p)
    (hd : q.damage = p.damage) (U : InPlay → InPlay)
    (hU : ∀ u, U { p with poisonUp := u } = { U p with poisonUp := u })
    (_htop : (U p).top = p.top) (hpu : (U p).poisonUp = p.poisonUp) :
    clampWith K c' (U q) = clampWith K c' (U p) := by
  have hu := h.poisonUp
  rw [h.eq_upd hd, hU]
  apply clampWith_setPoisonUp
  rw [hpu]
  exact hu

/-- Adding damage preserves agreement, at any cap. -/
theorem Agree.dmg_add {c : Cap} {q p : InPlay} (h : Agree K c q p) (n : Nat) :
    c.dmg K { q with damage := q.damage + n } = c.dmg K { p with damage := p.damage + n } := by
  have hd := h.damage
  cases c <;> simp only [Cap.dmg] at hd ⊢ <;> omega

/-- Adding amounts that agree at the cap `k` preserves agreement at `k`. -/
theorem Agree.dmg_add_upto {k : Nat} {q p : InPlay} (h : Agree K (.upto k) q p) {a b : Nat}
    (hab : min a k = min b k) :
    Cap.dmg K (.upto k) { q with damage := q.damage + a } =
      Cap.dmg K (.upto k) { p with damage := p.damage + b } := by
  have hd := h.damage
  simp only [Cap.dmg] at hd ⊢
  omega

end InPlay

open InPlay in
/-- Agreement survives every update the moves and effects make to one Pokémon. -/
theorem InPlay.Agree.upd {c : Cap} {q p : InPlay} (h : Agree K c q p) :
    (∀ e, Agree K c { q with energy := e } { p with energy := e }) ∧
    (∀ n, Agree K c { q with damage := q.damage + n } { p with damage := p.damage + n }) ∧
    (∀ n, Agree K c { q with poisonUp := q.poisonUp + n } { p with poisonUp := p.poisonUp + n }) ∧
    (∀ k, Agree K c (q.inflict k) (p.inflict k)) ∧
    Agree K c q.cure p.cure ∧ Agree K c q.unfresh p.unfresh := by
  refine ⟨fun e => ⟨h.top, h.under, rfl, h.tools, h.rot, h.poisoned, h.burned, h.fresh,
      h.marks, h.used, h.dmg_of rfl rfl rfl rfl, h.poisonUp⟩,
    fun n => ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks, h.used,
      h.dmg_add n, h.poisonUp⟩,
    fun n => ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks, h.used,
      h.dmg_of rfl rfl rfl rfl, ?_⟩,
    fun k => ?_,
    ⟨h.top, h.under, h.energy, h.tools, rfl, rfl, rfl, h.fresh, h.marks, h.used,
      h.dmg_of rfl rfl rfl rfl, by simp [InPlay.cure]⟩,
    ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, rfl, h.marks, rfl,
      h.dmg_of rfl rfl rfl rfl, h.poisonUp⟩⟩
  · show min (q.poisonUp + n) K = min (p.poisonUp + n) K
    have hu := h.poisonUp
    omega
  · have hd : c.dmg K (q.inflict k) = c.dmg K (p.inflict k) := by
      cases k <;> exact h.dmg_of rfl rfl rfl rfl
    cases k <;>
      exact ⟨h.top, h.under, h.energy, h.tools, by first | rfl | exact h.rot,
        by first | rfl | exact h.poisoned, by first | rfl | exact h.burned, h.fresh, h.marks, h.used,
        hd, by first | exact h.poisonUp | simp only [InPlay.inflict, Nat.zero_min]⟩

/-- Agreement survives marking an Ability as used (milestone M8a). -/
theorem InPlay.Agree.markUsed {c : Cap} {q p : InPlay} (h : Agree K c q p) :
    Agree K c q.markUsed p.markUsed :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks, rfl,
    h.dmg_of rfl rfl rfl rfl, h.poisonUp⟩

/-- Agreeing Pokémon have the same attacks and Abilities, their Tools' included (milestone M5). -/
theorem InPlay.Agree.grants {c : Cap} {q p : InPlay} (h : Agree K c q p) :
    q.attacks = p.attacks ∧ q.abilities = p.abilities := by
  simp only [InPlay.attacks, InPlay.abilities, h.top, h.tools, and_self]

/-- Agreement survives attaching a Tool (milestone M5). -/
theorem InPlay.Agree.setTools {c : Cap} {q p : InPlay} (h : Agree K c q p) (t : List Card) :
    Agree K c { q with tools := t } { p with tools := t } :=
  ⟨h.top, h.under, h.energy, rfl, h.rot, h.poisoned, h.burned, h.fresh, h.marks, h.used,
    h.dmg_of rfl rfl rfl rfl, h.poisonUp⟩

/-- Agreement survives a change of markers. -/
theorem InPlay.Agree.setMarks {c : Cap} {q p : InPlay} (h : Agree K c q p) (f : Marks → Marks) :
    Agree K c (q.setMarks f) (p.setMarks f) :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh,
    by simp only [InPlay.setMarks, h.marks], h.used, h.dmg_of rfl rfl rfl rfl, h.poisonUp⟩

theorem InPlay.clampWith_setMarks (c : Cap) (f : Marks → Marks) :
    InPlay.clampWith K c ∘ InPlay.setMarks f = InPlay.setMarks f ∘ InPlay.clampWith K c := by
  funext x
  have hd : c.dmg K (x.setMarks f) = c.dmg K x := InPlay.dmg_congr K c rfl rfl
  show InPlay.clampWith K c (x.setMarks f) = InPlay.setMarks f (InPlay.clampWith K c x)
  unfold InPlay.clampWith
  rw [hd]
  rfl

/-- Changing markers on an Active Spot commutes with agreement. -/
theorem map_clamp_setMarks {c : Cap} (f : Marks → Marks) {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith K c) = o₁.map (InPlay.clampWith K c)) :
    (o₂.map (InPlay.setMarks f)).map (InPlay.clampWith K c) =
      (o₁.map (InPlay.setMarks f)).map (InPlay.clampWith K c) := by
  rw [Option.map_map, Option.map_map, InPlay.clampWith_setMarks, ← Option.map_map,
    ← Option.map_map, h]

/-- Checkup preserves agreement when the damage is equal, and then the results agree with
damage capped at the bound `K` (`Cap.hp`). -/
theorem InPlay.Agree.checkup {c : Cap} {q p : InPlay} (h : Agree K c q p)
    (hd : q.damage = p.damage) (o f s t : Bool) :
    Agree K .hp (q.checkup o f s t) (p.checkup o f s t) := by
  have hu := h.poisonUp
  refine ⟨h.top, h.under, h.energy, h.tools, ?_, h.poisoned, ?_, h.fresh, h.marks, h.used, ?_,
    h.poisonUp⟩
  · simp only [InPlay.checkup, h.rot]
  · simp only [InPlay.checkup, h.burned]
  · show min (q.damage + (if q.poisoned then 1 + q.poisonUp else 0) +
        (if q.burned then 2 else 0) + (if q.marks.char && t then 2 else 0)) K
      = min (p.damage + (if p.poisoned then 1 + p.poisonUp else 0) +
        (if p.burned then 2 else 0) + (if p.marks.char && t then 2 else 0)) K
    rw [hd, h.poisoned, h.burned, h.marks]
    cases p.poisoned <;> cases p.burned <;> cases (p.marks.char && t) <;>
      simp only [Bool.false_eq_true, ite_false, ite_true] <;> omega

/-- Agreeing Pokémon given the same damage still agree. -/
theorem InPlay.Agree.setDamage {c : Cap} {q p : InPlay} (h : Agree K c q p) (d : Nat) :
    Agree K c { q with damage := d } { p with damage := d } :=
  ⟨h.top, h.under, h.energy, h.tools, h.rot, h.poisoned, h.burned, h.fresh, h.marks, h.used,
    InPlay.dmg_congr K c h.top rfl, h.poisonUp⟩

/-- The clamps keep every count: counts read zones, Prize cards, the cards of the Pokémon in play
and their attached Energy, never damage (milestone MV). -/
theorem Count.val_clampAt (c : Count) (co cp cbo cbp : Cap) (k : Nat) (g : GameState) :
    c.val (g.clampAt co cp cbo cbp k) = c.val g := by
  have t1 : ∀ (cb : Cap) (b : List InPlay),
      (b.map (InPlay.clampWith k cb)).map InPlay.top = b.map InPlay.top := fun cb b => by
    rw [List.map_map]; rfl
  have t2 : ∀ (cb : Cap) (b : List InPlay),
      (b.map (InPlay.clampWith k cb)).map InPlay.energy = b.map InPlay.energy := fun cb b => by
    rw [List.map_map]; rfl
  have t3 : ∀ (cb : Cap) (o : Option InPlay),
      (o.map (InPlay.clampWith k cb)).map InPlay.energy = o.map InPlay.energy := fun cb o => by
    cases o <;> rfl
  have t4 : ∀ (cb : Cap) (o : Option InPlay),
      (o.map (InPlay.clampWith k cb)).map InPlay.top = o.map InPlay.top := fun cb o => by
    cases o <;> rfl
  cases c with
  | pile w z f => cases w <;> cases z <;> rfl
  | prizes w => cases w <;> rfl
  | bench w f => cases w <;> simp only [Count.val, GameState.side, GameState.clampAt, t1]
  | energy w f => cases w <;> simp only [Count.val, GameState.side, GameState.clampAt, t3]
  | energyAll w f =>
      cases w <;> simp only [Count.val, GameState.side, GameState.clampAt, t2, t3]
  | inPlay w f => cases w <;> simp only [Count.val, GameState.side, GameState.clampAt, t1, t4]

/-- States with equal `clampAt` have equal counts. -/
theorem GameState.count_of_clampAt {co cp cbo cbp : Cap} {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.clampAt co cp cbo cbp k = g₂.clampAt co cp cbo cbp k) (c : Count) :
    c.val g₂ = c.val g₁ := by
  rw [← c.val_clampAt co cp cbo cbp k g₂, ← h, c.val_clampAt]

/-- Tests read only what agreement capped at `k` keeps equal, when their constants are below
`k`: a damage test against `n < k` cannot tell two damages apart that are equal or both at
least `k`; a count test reads counts, which are equal when `hv` says so (milestone MV). -/
theorem Test.eval_agree (t : Test) {k : Nat} {g₁ g₂ : GameState} {q p : InPlay}
    (hv : ∀ c : Count, c.val g₂ = c.val g₁) (h : InPlay.Agree K (.upto k) q p)
    (hb : t.bound < k) : t.eval g₂ q = t.eval g₁ p := by
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
  | countGe c n => simp only [Test.eval, hv c]
  | top w f => simp only [Test.eval, h.top]
  | hasTool w => simp only [Test.eval, h.tools]

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
  exact ⟨by clear a2 b2; omega, by clear a1 b1; omega⟩

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
  -- One reduction at a time: `omega` given all four stores' facts at once splits on every `min`.
  have key : ∀ {x y : Nat}, min x k = min y k → y = 0 → x = 0 := fun hm hy => by omega
  exact ⟨key h1.2.1 b1, key h2.2.1 b2, key h3.2.1 b3, key h4.2.1 b4⟩

/-- With no damage reduction, the damage done is the base damage plus the bonus, doubled under
Weakness, less Resistance; or nothing (base damage 0, or prevention). -/
theorem dealtBy_of_noReduce {own opp : Store} (h : opp.NoReduce) (n : Nat) (w : Bool) (r : Nat) :
    dealtBy n w r own opp = if n = 0 then 0 else if opp.live.prevent then 0 else
      (if w then 2 * (n + own.live.bonus) else n + own.live.bonus) - r := by
  simp only [dealtBy, h.live, Nat.sub_zero]

/-- **The cap survives Weakness and Resistance.** With no damage reduction and a Resistance of
at most `k`, damage done agrees at the cap `k` when the stores agree at the cap `2 * k`. If the
two bonuses differ, both are at least `2 * k`, and the damage is at least `n + 2 * k - r ≥ k` in
both states, with or without Weakness: doubling a quantity of at least `2 * k` keeps it at least
`2 * k` (`min (2 * b) …` and `2 * min b …` agree above the cap), so Weakness is harmless; it is
the subtraction of Resistance that needs the stores capped above the damage cap. -/
theorem dealtBy_cap {k : Nat} (hk : 0 < k) {c₁ c₂ o₁ o₂ : Store}
    (hc : c₂.cap (2 * k) = c₁.cap (2 * k)) (ho : o₂.cap (2 * k) = o₁.cap (2 * k))
    (hn : o₁.NoReduce) (n : Nat) (w : Bool) {r : Nat} (hr : r ≤ k) :
    min (dealtBy n w r c₂ o₂) k = min (dealtBy n w r c₁ o₁) k := by
  have hn₂ := Store.NoReduce.of_cap (by omega) ho hn
  rw [dealtBy_of_noReduce hn, dealtBy_of_noReduce hn₂]
  have hc' := Mods.cap_iff.1 (Store.live_cap hc)
  have ho' := Mods.cap_iff.1 (Store.live_cap ho)
  have hb := hc'.1
  rw [ho'.2.2.1]
  -- Only the bonus fact is needed below; the other `min` facts would make `omega` split on each.
  clear hc' ho'
  by_cases h0 : n = 0
  · simp only [h0, ↓reduceIte]
  · simp only [h0, ↓reduceIte]
    split
    · rfl
    · cases w
      · simp only [Bool.false_eq_true, ↓reduceIte]; omega
      · simp only [↓reduceIte]; omega

/-- With no stored reduction, adding a reduction `s` (as the static reduction enters the damage
calculation, `GameState.dealt`) subtracts `s` from the damage done. -/
theorem dealtBy_add_reduce {o : Store} (h : o.NoReduce) (n : Nat) (w : Bool) (r s : Nat)
    (c : Store) : dealtBy n w r c (o.add .always (.reduce s)) = dealtBy n w r c o - s := by
  obtain ⟨h1, -, -, h4⟩ := h
  simp only [dealtBy, Store.add, Store.live, Mods.merge, Mods.addMod, h1, h4]
  by_cases h0 : n = 0
  · simp only [h0, ↓reduceIte, Nat.zero_sub]
  · simp only [h0, ↓reduceIte]
    split
    · exact (Nat.zero_sub s).symm
    · omega

/-- **The cap survives one more bounded reduction** (milestone M6): `dealtBy_cap` with a reduction
`s` subtracted after Resistance (the static reduction, `GameState.dealt`), the same in both states,
and `r + s ≤ k`. If the two bonuses differ, both are at least `2 * k`, so the damage before the
reduction is at least `2 * k - r ≥ k + s`, and after it at least `k`, in both states. -/
theorem dealtBy_cap_reduce {k : Nat} (hk : 0 < k) {c₁ c₂ o₁ o₂ : Store}
    (hc : c₂.cap (2 * k) = c₁.cap (2 * k)) (ho : o₂.cap (2 * k) = o₁.cap (2 * k))
    (hn : o₁.NoReduce) (n : Nat) (w : Bool) {r s : Nat} (hr : r + s ≤ k) :
    min (dealtBy n w r c₂ (o₂.add .always (.reduce s))) k =
      min (dealtBy n w r c₁ (o₁.add .always (.reduce s))) k := by
  have hn₂ := Store.NoReduce.of_cap (by omega) ho hn
  rw [dealtBy_add_reduce hn, dealtBy_add_reduce hn₂, dealtBy_of_noReduce hn,
    dealtBy_of_noReduce hn₂]
  have hc' := Mods.cap_iff.1 (Store.live_cap hc)
  have ho' := Mods.cap_iff.1 (Store.live_cap ho)
  have hb := hc'.1
  rw [ho'.2.2.1]
  -- Only the bonus fact is needed below; the other `min` facts would make `omega` split on each.
  clear hc' ho'
  by_cases h0 : n = 0
  · simp only [h0, ↓reduceIte]
  · simp only [h0, ↓reduceIte]
    split
    · rfl
    · cases w
      · simp only [Bool.false_eq_true, ↓reduceIte]; omega
      · simp only [↓reduceIte]; omega

/-- The flags in effect agree when the stores agree at a cap. -/
theorem Store.flags_of_cap {k : Nat} {a b : Store} (h : a.cap k = b.cap k) :
    a.live.prevent = b.live.prevent ∧ a.live.noAttack = b.live.noAttack ∧
      a.live.noRetreat = b.live.noRetreat ∧ a.live.noItem = b.live.noItem :=
  (Mods.cap_iff.1 (Store.live_cap h)).2.2

/-! ## Agreement of states -/

/-- Two states with the same `clampAt co cp cb k` differ at most in the Pokémon in play, as
`Agree` allows, and in the damage bonuses and reductions above `2 * k`. -/
theorem GameState.clamp_inv {co cp cbo cbp : Cap} {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.clampAt co cp cbo cbp k = g₂.clampAt co cp cbo cbp k) :
    ∃ c₂ a₂ m₁ m₂ e₁ e₂, g₂ = { g₁ with
        cur := { g₁.cur with active := c₂, bench := e₁, mods := m₁ },
        opp := { g₁.opp with active := a₂, bench := e₂, mods := m₂ } } ∧
      c₂.map (InPlay.clampWith k co) = g₁.cur.active.map (InPlay.clampWith k co) ∧
      a₂.map (InPlay.clampWith k cp) = g₁.opp.active.map (InPlay.clampWith k cp) ∧
      m₁.cap (2 * k) = g₁.cur.mods.cap (2 * k) ∧ m₂.cap (2 * k) = g₁.opp.mods.cap (2 * k) ∧
      e₁.map (InPlay.clampWith k cbo) = g₁.cur.bench.map (InPlay.clampWith k cbo) ∧
      e₂.map (InPlay.clampWith k cbp) = g₁.opp.bench.map (InPlay.clampWith k cbp) := by
  refine ⟨g₂.cur.active, g₂.opp.active, g₂.cur.mods, g₂.opp.mods, g₂.cur.bench, g₂.opp.bench,
    ?_, (congrArg (fun g => g.cur.active) h).symm, (congrArg (fun g => g.opp.active) h).symm,
    (congrArg (fun g => g.cur.mods) h).symm, (congrArg (fun g => g.opp.mods) h).symm,
    (congrArg (fun g => g.cur.bench) h).symm, (congrArg (fun g => g.opp.bench) h).symm⟩
  have e : g₂ = { g₂.clampAt co cp cbo cbp k with
      cur := { (g₂.clampAt co cp cbo cbp k).cur with
        active := g₂.cur.active, bench := g₂.cur.bench, mods := g₂.cur.mods },
      opp := { (g₂.clampAt co cp cbo cbp k).opp with
        active := g₂.opp.active, bench := g₂.opp.bench, mods := g₂.opp.mods } } :=
    rfl
  refine e.trans ?_
  rw [← h]
  rfl

/-! ## Agreement of Benches -/

/-- Two lists with the same image under `f`, one split around an element: the other splits the
same way, with an element of the same image. -/
theorem map_eq_split {α β : Type} {f : α → β} {q : α} :
    ∀ {l b₁ b₂ : List α}, l.map f = (b₁ ++ q :: b₂).map f →
      ∃ c₁ q' c₂, l = c₁ ++ q' :: c₂ ∧ c₁.map f = b₁.map f ∧ f q' = f q ∧ c₂.map f = b₂.map f
  | [], [], _, h => by simp at h
  | x :: xs, [], b₂, h => by
      simp only [List.map_cons, List.nil_append, List.cons.injEq] at h
      exact ⟨[], x, xs, rfl, rfl, h.1, h.2⟩
  | [], _ :: _, _, h => by simp at h
  | x :: xs, y :: ys, b₂, h => by
      simp only [List.map_cons, List.cons_append, List.cons.injEq] at h
      obtain ⟨c₁, q', c₂, e, h1, h2, h3⟩ := map_eq_split (l := xs) (b₁ := ys) (b₂ := b₂)
        h.2
      exact ⟨x :: c₁, q', c₂, by rw [e]; rfl, by simp only [List.map_cons, h.1, h1], h2, h3⟩

/-- An element of a list has an element of the same image in every list with the same image. -/
theorem mem_of_map_eq {α β : Type} {f : α → β} {p : α} :
    ∀ {l₁ l₂ : List α}, l₂.map f = l₁.map f → p ∈ l₂ → ∃ q ∈ l₁, f p = f q
  | [], [], _, hp => nomatch hp
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h
  | y :: ys, x :: xs, h, hp => by
      simp only [List.map_cons, List.cons.injEq] at h
      cases hp with
      | head => exact ⟨y, .head _, h.1⟩
      | tail _ hp =>
          obtain ⟨q, hq, e⟩ := mem_of_map_eq h.2 hp
          exact ⟨q, .tail _ hq, e⟩

/-- Equal images under `f` give equal images under `f'`, if `f'` is determined by `f` on the
elements of the first list. -/
theorem map_transfer {α β γ : Type} {f : α → β} {f' : α → γ} :
    ∀ {l₁ l₂ : List α}, l₂.map f = l₁.map f → (∀ x ∈ l₁, ∀ y, f y = f x → f' y = f' x) →
      l₂.map f' = l₁.map f'
  | [], [], _, _ => rfl
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h
  | x :: xs, y :: ys, h, hx => by
      simp only [List.map_cons, List.cons.injEq] at h ⊢
      exact ⟨hx x (.head _) y h.1, map_transfer h.2 fun z hz => hx z (.tail _ hz)⟩

/-- Equal damage gives agreement at any cap, on a Bench. -/
theorem bench_recap {c : Cap} {b e : List InPlay}
    (h : e.map (InPlay.clampWith K .exact) = b.map (InPlay.clampWith K .exact)) :
    e.map (InPlay.clampWith K c) = b.map (InPlay.clampWith K c) :=
  map_transfer h fun _ _ _ hy =>
    InPlay.clamp_of_agree ((InPlay.agree_of_clamp hy).recap (InPlay.agree_of_clamp hy).damage_eq)

/-- On a Bench whose Pokémon are below the bound, agreement at `.hp` gives equal damage. -/
theorem bench_exact_of_hp {b e : List InPlay}
    (h : e.map (InPlay.clampWith K .hp) = b.map (InPlay.clampWith K .hp))
    (hk : ∀ p ∈ b, p.damage < K) :
    e.map (InPlay.clampWith K .exact) = b.map (InPlay.clampWith K .exact) :=
  map_transfer h fun x hx _ hy =>
    InPlay.clamp_of_agree ((InPlay.agree_of_clamp hy).exact_of_hp (hk x hx))

/-- A clamp commutes with an update of the Pokémon that does not touch damage, Poison strength
or the top card, on a Bench. -/
theorem bench_map_comm {c : Cap} {U : InPlay → InPlay}
    (hU : ∀ x, InPlay.clampWith K c (U x) = U (InPlay.clampWith K c x)) {b e : List InPlay}
    (h : e.map (InPlay.clampWith K c) = b.map (InPlay.clampWith K c)) :
    (e.map U).map (InPlay.clampWith K c) = (b.map U).map (InPlay.clampWith K c) := by
  have hc : InPlay.clampWith K c ∘ U = U ∘ InPlay.clampWith K c := funext hU
  rw [List.map_map, List.map_map, hc, ← List.map_map, ← List.map_map, h]

/-- Attack damage to a Benched Pokémon preserves agreement: the Tera flag is on the top card. -/
theorem InPlay.Agree.hitBench {c : Cap} {q p : InPlay} (h : InPlay.Agree K c q p) (n : Nat) :
    InPlay.Agree K c (q.hitBench n) (p.hitBench n) := by
  unfold InPlay.hitBench
  rw [h.top]
  split
  · exact h
  · exact h.upd.2.1 n

/-- Damage or counters from `Effect.benchSome` preserve agreement (milestone MV2). -/
theorem InPlay.Agree.hitWith {c : Cap} {q p : InPlay} (h : InPlay.Agree K c q p) (dmg : Bool)
    (n : Nat) : InPlay.Agree K c (q.hitWith dmg n) (p.hitWith dmg n) := by
  cases dmg
  · exact h.upd.2.1 n
  · exact h.hitBench n

theorem clampWith_hitWith {c : Cap} (dmg : Bool) (n : Nat) (x y : InPlay)
    (h : InPlay.clampWith K c y = InPlay.clampWith K c x) :
    InPlay.clampWith K c (y.hitWith dmg n) = InPlay.clampWith K c (x.hitWith dmg n) :=
  InPlay.clamp_of_agree ((InPlay.agree_of_clamp h).hitWith dmg n)

theorem clampWith_top {c : Cap} (x y : InPlay)
    (h : InPlay.clampWith K c y = InPlay.clampWith K c x) : y.top = x.top :=
  (InPlay.agree_of_clamp h).top

/-- An update that preserves agreement keeps two agreeing Benches agreeing. -/
theorem bench_map_agree {c : Cap} {U : InPlay → InPlay}
    (hU : ∀ x y, InPlay.Agree K c y x → InPlay.Agree K c (U y) (U x)) {b e : List InPlay}
    (h : e.map (InPlay.clampWith K c) = b.map (InPlay.clampWith K c)) :
    (e.map U).map (InPlay.clampWith K c) = (b.map U).map (InPlay.clampWith K c) := by
  rw [List.map_map, List.map_map]
  exact map_transfer h fun x _ y hy =>
    InPlay.clamp_of_agree (hU x y (InPlay.agree_of_clamp hy))

theorem InPlay.clampWith_unfresh (c : Cap) (x : InPlay) :
    InPlay.clampWith K c x.unfresh = (InPlay.clampWith K c x).unfresh := by
  have hd : c.dmg K x.unfresh = c.dmg K x := InPlay.dmg_congr K c rfl rfl
  show { x.unfresh with damage := c.dmg K x.unfresh, poisonUp := min x.poisonUp K } = _
  rw [hd]; rfl

theorem InPlay.clampWith_exact_addDamage (n : Nat) (x : InPlay) :
    InPlay.clampWith K .exact (x.addDamage n) = (InPlay.clampWith K .exact x).addDamage n := rfl

theorem InPlay.clampWith_setMarks' (c : Cap) (f : Marks → Marks) (x : InPlay) :
    InPlay.clampWith K c (x.setMarks f) = (InPlay.clampWith K c x).setMarks f := by
  have hd : c.dmg K (x.setMarks f) = c.dmg K x := InPlay.dmg_congr K c rfl rfl
  show { x.setMarks f with damage := c.dmg K (x.setMarks f), poisonUp := min x.poisonUp K }
    = _
  rw [hd]; rfl

/-- A clamp keeps the type and the top card of a Pokémon in play. -/
theorem map_type_top_of_map {c : Cap} {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith K c) = o₁.map (InPlay.clampWith K c)) :
    o₂.map InPlay.type = o₁.map InPlay.type ∧ o₂.map InPlay.top = o₁.map InPlay.top := by
  cases o₁ with
  | none =>
      cases o₂ with
      | none => exact ⟨rfl, rfl⟩
      | some q => simp at h
  | some p =>
      cases o₂ with
      | none => simp at h
      | some q =>
          simp only [Option.map_some, Option.some.injEq] at h ⊢
          exact ⟨(congrArg InPlay.type h : _), (congrArg InPlay.top h : _)⟩

/-- Weakness and Resistance depend only on the attacker's type and the defender's card. -/
theorem GameState.wr_congr {g₁ g₂ : GameState}
    (hc : g₂.cur.active.map InPlay.type = g₁.cur.active.map InPlay.type)
    (ho : g₂.opp.active.map InPlay.top = g₁.opp.active.map InPlay.top) :
    g₂.weak = g₁.weak ∧ g₂.resist = g₁.resist := by
  unfold GameState.weak GameState.resist
  cases h1 : g₁.cur.active <;> cases h2 : g₂.cur.active <;> cases h3 : g₁.opp.active <;>
    cases h4 : g₂.opp.active <;> simp_all

/-- The Resistance in effect is at most that printed on the opponent's Active Pokémon. -/
theorem GameState.resist_le {g : GameState} {k : Nat}
    (h : ∀ p, g.opp.active = some p → p.top.resistAmt ≤ k) : g.resist ≤ k := by
  unfold GameState.resist
  split
  · next a d _ hd => exact Nat.le_trans (d.top.resistTo_le _) (h d hd)
  · exact Nat.zero_le _

/-- From `o.map f = some (f a)`, a `q` with `o = some q` that agrees with `a`. -/
theorem agree_of_map {c : Cap} {o : Option InPlay} {a : InPlay}
    (h : o.map (InPlay.clampWith K c) = (some a).map (InPlay.clampWith K c)) :
    ∃ q, o = some q ∧ InPlay.Agree K c q a := by
  rw [Option.map_some] at h
  obtain ⟨q, rfl, hq⟩ := Option.map_eq_some_iff.1 h
  exact ⟨q, rfl, InPlay.agree_of_clamp hq⟩

theorem none_of_map {c : Cap} {o : Option InPlay}
    (h : o.map (InPlay.clampWith K c) = (none : Option InPlay).map (InPlay.clampWith K c)) :
    o = none :=
  Option.map_eq_none_iff.1 h

/-- Equal damage gives agreement at any cap. -/
theorem map_recap {c : Cap} {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith K .exact) = o₁.map (InPlay.clampWith K .exact)) :
    o₂.map (InPlay.clampWith K c) = o₁.map (InPlay.clampWith K c) := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [Option.map_some, InPlay.clamp_of_agree (hq.recap (c' := c) hq.damage_eq)]

/-- Below the bound, agreement at `.hp` gives equal damage. -/
theorem map_exact_of_hp {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith K .hp) = o₁.map (InPlay.clampWith K .hp))
    (hk : ∀ p, o₁ = some p → p.damage < K) :
    o₂.map (InPlay.clampWith K .exact) = o₁.map (InPlay.clampWith K .exact) := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [Option.map_some, InPlay.clamp_of_agree (hq.exact_of_hp (hk p rfl))]

/-- Agreement capped at the bound is agreement at `.hp` (milestone M6: no hypothesis on HP). -/
theorem map_hp_of_upto {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith K (.upto K)) = o₁.map (InPlay.clampWith K (.upto K))) :
    o₂.map (InPlay.clampWith K .hp) = o₁.map (InPlay.clampWith K .hp) := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [Option.map_some, InPlay.clamp_of_agree hq.hp_of_upto]

/-- The Active Pokémon read by a test, in states with the same `rclamp k`: they agree with
damage capped at `k` (the player's own agree exactly). -/
theorem GameState.activeOf_agree {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.rclamp k = g₂.rclamp k) {w : Whose} {p : InPlay} (hp : g₁.activeOf w = some p) :
    ∃ q, g₂.activeOf w = some q ∧ InPlay.Agree k (.upto k) q p := by
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

/-- **What the clamps keep of the derived quantities** (milestone M6): states with the same
`clampAt` have the same Pokémon in play up to damage and Poison strength, the same Stadium and the
same player to move, so the same derived HP, static modifiers and Retreat Costs. -/
theorem GameState.sameField_of_clampAt {co cp cbo cbp : Cap} {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.clampAt co cp cbo cbp k = g₂.clampAt co cp cbo cbp k) : GameState.SameField g₁ g₂ := by
  have hsv : ∀ (c : Cap) (p : InPlay), (InPlay.clampWith k c p).sv = p.sv := fun _ _ => rfl
  have e1 := congrArg (fun g => g.cur.field) h
  have e2 := congrArg (fun g => g.opp.field) h
  simp only [GameState.clampAt, PlayerState.field, fieldOf_map (hsv _) (hsv _)] at e1 e2
  exact ⟨by simp only [PlayerState.field]; exact e1.symm, by simp only [PlayerState.field]; exact e2.symm,
    (congrArg GameState.stadium h).symm, (congrArg GameState.curIsFirst h).symm⟩

/-- With no pending Knock Out and every HP at most `k`, every damage is below `k`. -/
theorem DamageBounded.lt_bound {g : GameState} {k : Nat} (hk : DamageBounded g)
    (hH : g.HpBelow k) {w : Whose} {sp : Spot} {p : InPlay} (hp : g.In w sp p) : p.damage < k :=
  Nat.lt_of_lt_of_le (hk w sp p hp) (hH w sp p hp)

/-- With no pending Knock Out and every HP at most `k`, equal `clamp k` gives equal `rclamp k`.
(Milestone M6 added `hH`: before it the clamp capped at the printed HP, which bounded the damage of
a Pokémon below its HP by definition.) -/
theorem GameState.rclamp_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k)
    (hk : DamageBounded g₁) (hH : g₁.HpBelow k) : g₁.rclamp k = g₂.rclamp k := by
  obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv h
  simp only [GameState.rclamp, GameState.clampAt, hm₁, hm₂,
    map_exact_of_hp hc₂ fun p hp => hk.lt_bound hH (w := .own) (sp := .active) hp,
    map_recap (c := .upto k) (map_exact_of_hp ha₂ fun p hp =>
      hk.lt_bound hH (w := .opp) (sp := .active) hp),
    bench_exact_of_hp he₁ fun p hp => hk.lt_bound hH (w := .own) (sp := .bench) hp,
    bench_recap (c := .upto k) (bench_exact_of_hp he₂ fun p hp =>
      hk.lt_bound hH (w := .opp) (sp := .bench) hp)]

/-- Agreement capped at the bound is agreement at `.hp`, on a Bench. -/
theorem bench_hp_of_upto {b e : List InPlay}
    (h : e.map (InPlay.clampWith K (.upto K)) = b.map (InPlay.clampWith K (.upto K))) :
    e.map (InPlay.clampWith K .hp) = b.map (InPlay.clampWith K .hp) :=
  map_transfer h fun _ _ _ hy => InPlay.clamp_of_agree (InPlay.agree_of_clamp hy).hp_of_upto

/-- Equal `rclamp k` gives equal `clamp k`. (Before milestone M6 this needed the opponent's
Pokémon to have printed HP at most `k`; the clamp now caps at `k` itself.) -/
theorem GameState.clamp_of_rclamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.rclamp k = g₂.rclamp k) :
    g₁.clamp k = g₂.clamp k := by
  obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv h
  simp only [GameState.clamp, GameState.clampAt, hm₁, hm₂, map_recap (c := .hp) hc₂,
    map_hp_of_upto ha₂, bench_recap (c := .hp) he₁, bench_hp_of_upto he₂]

/-- A Pokémon in play in a state with the same `clamp k` is matched by one at the same place that
agrees with it. -/
theorem GameState.in_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k)
    {w : Whose} {sp : Spot} {p : InPlay} (hp : g₂.In w sp p) :
    ∃ q, g₁.In w sp q ∧ InPlay.Agree k .hp p q := by
  obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, _, _, he₁, he₂⟩ := GameState.clamp_inv h
  cases w <;> cases sp <;> simp only [GameState.In, GameState.side] at hp ⊢
  · rw [hp, Option.map_some] at hc₂
    obtain ⟨a, ha, hfa⟩ := Option.map_eq_some_iff.1 hc₂.symm
    exact ⟨a, ha, InPlay.agree_of_clamp hfa.symm⟩
  · obtain ⟨q, hq, e⟩ := mem_of_map_eq he₁ hp
    exact ⟨q, hq, InPlay.agree_of_clamp e⟩
  · rw [hp, Option.map_some] at ha₂
    obtain ⟨a, ha, hfa⟩ := Option.map_eq_some_iff.1 ha₂.symm
    exact ⟨a, ha, InPlay.agree_of_clamp hfa.symm⟩
  · obtain ⟨q, hq, e⟩ := mem_of_map_eq he₂ hp
    exact ⟨q, hq, InPlay.agree_of_clamp e⟩

/-- With every HP at most `k`, equal `clamp k` keeps "no pending Knock Out" (milestone M6 added
`hH`). -/
theorem GameState.damageBounded_of_clamp {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.clamp k = g₂.clamp k) (hk : DamageBounded g₁) (hH : g₁.HpBelow k) :
    DamageBounded g₂ := by
  have hsf := GameState.sameField_of_clampAt h
  intro w sp p hp
  obtain ⟨q, hq, ha⟩ := GameState.in_of_clamp h hp
  rw [hsf.hpOf w sp ha.sv]
  exact ha.lt (hH w sp q hq) (hk w sp q hq)

theorem GameState.settled_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k)
    (hs : Settled g₁) (hH : g₁.HpBelow k) : Settled g₂ := by
  refine ⟨GameState.damageBounded_of_clamp h hs.1 hH, fun hn => hs.2.1 ?_, fun hn => hs.2.2 ?_⟩
  · have e := congrArg (fun g => g.cur.active) h
    simp only [GameState.clamp, GameState.clampAt, hn, Option.map_none] at e
    exact Option.map_eq_none_iff.1 e
  · have e := congrArg (fun g => g.opp.active) h
    simp only [GameState.clamp, GameState.clampAt, hn, Option.map_none] at e
    exact Option.map_eq_none_iff.1 e

theorem GameState.winner_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k) :
    g₂.winner = g₁.winner :=
  (congrArg GameState.winner h).symm

/-- **Char counters on agreeing Benches.** If two Benches agree exactly (equal damage), every
outcome of the Char flips on the first is matched by one on the second. -/
theorem BenchChar.sim {b b' : List InPlay} (h : BenchChar b b') :
    ∀ {e : List InPlay}, e.map (InPlay.clampWith K .exact) = b.map (InPlay.clampWith K .exact) →
      ∃ e', BenchChar e e' ∧
        e'.map (InPlay.clampWith K .exact) = b'.map (InPlay.clampWith K .exact) := by
  induction h with
  | nil =>
      intro e he
      rw [List.map_nil, List.map_eq_nil_iff] at he
      subst he
      exact ⟨[], .nil, rfl⟩
  | @cons p p' b b' hs _ ih =>
      intro e he
      cases e with
      | nil => simp at he
      | cons x xs =>
          simp only [List.map_cons, List.cons.injEq] at he
          obtain ⟨xs', hxs, exs⟩ := ih he.2
          have hx := InPlay.agree_of_clamp he.1
          cases hs with
          | keep => exact ⟨x :: xs', .cons (.keep x) hxs, by simp only [List.map_cons, he.1, exs]⟩
          | burn hc =>
              refine ⟨x.addDamage 2 :: xs', .cons (.burn (by rw [hx.marks]; exact hc)) hxs, ?_⟩
              simp only [List.map_cons, exs, InPlay.addDamage, InPlay.clamp_of_agree (hx.upd.2.1 2)]

/-- Agreeing Benches are made of the same cards. -/
theorem benchCardList_of_map {c : Cap} : ∀ {b e : List InPlay},
    e.map (InPlay.clampWith K c) = b.map (InPlay.clampWith K c) → benchCardList e = benchCardList b
  | [], [], _ => rfl
  | [], _ :: _, h => by simp at h
  | _ :: _, [], h => by simp at h
  | _ :: _, _ :: _, h => by
      simp only [List.map_cons, List.cons.injEq] at h
      simp only [benchCardList, (InPlay.agree_of_clamp h.1).cardList, benchCardList_of_map h.2]

/-- A clamp keeps the cards of a Bench. -/
theorem benchCardList_clamp (c : Cap) : ∀ b : List InPlay,
    benchCardList (b.map (InPlay.clampWith K c)) = benchCardList b
  | [] => rfl
  | p :: ps => by simp only [List.map_cons, benchCardList, benchCardList_clamp c ps]; rfl

/-- Agreeing Benches have the same length. -/
theorem length_of_map {α β : Type} {f : α → β} {b e : List α} (h : e.map f = b.map f) :
    e.length = b.length := by
  have := congrArg List.length h
  simpa only [List.length_map] using this

/-! ## Knock Outs -/

/-! ## The batch Knock Out step under the clamps

Both clamps update every Pokémon in play by one map (`InPlay.clampWith K .hp`), which keeps its
cards and its view, and caps damage at `K`; with every derived HP at most `K` the check's threshold
test is the same before and after (`hpOf ≤ min d K ↔ hpOf ≤ d`). So the check commutes with the
clamp (`GameState.koStep_clamp`), and promotions are matched place by place. -/

/-- Update the Pokémon in play of a player by `f` and their stores by `m`. -/
def PlayerState.mapPlay (f : InPlay → InPlay) (m : Store → Store) (s : PlayerState) :
    PlayerState :=
  { s with active := s.active.map f, bench := s.bench.map f, mods := m s.mods }

theorem optFilter_map {f : InPlay → InPlay} {t t' : InPlay → Bool} {o : Option InPlay}
    (h : ∀ p, o = some p → t' (f p) = t p) : optFilter t' (o.map f) = (optFilter t o).map f := by
  cases o with
  | none => rfl
  | some p =>
      have hp := h p rfl
      simp only [Option.map_some, optFilter, hp]
      split <;> rfl

theorem filter_map_of {f : InPlay → InPlay} {t t' : InPlay → Bool} :
    ∀ {b : List InPlay}, (∀ p ∈ b, t' (f p) = t p) → (b.map f).filter t' = (b.filter t).map f
  | [], _ => rfl
  | p :: ps, h => by
      have hp := h p (.head _)
      have ih := filter_map_of (b := ps) fun q hq => h q (.tail _ hq)
      simp only [List.map_cons, List.filter_cons, hp]
      split <;> simp only [ih, List.map_cons]

theorem optCardList_map {f : InPlay → InPlay} (hf : ∀ p, (f p).cardList = p.cardList) :
    ∀ o : Option InPlay, optCardList (o.map f) = optCardList o
  | none => rfl
  | some p => hf p

theorem benchCardList_map {f : InPlay → InPlay} (hf : ∀ p, (f p).cardList = p.cardList) :
    ∀ b : List InPlay, benchCardList (b.map f) = benchCardList b
  | [] => rfl
  | p :: ps => by simp only [List.map_cons, benchCardList, hf p, benchCardList_map hf ps]

theorem optPrizes_map {f : InPlay → InPlay} (hf : ∀ p, (f p).top = p.top) :
    ∀ o : Option InPlay, optPrizes (o.map f) = optPrizes o
  | none => rfl
  | some p => by simp only [Option.map_some, optPrizes, hf p]

theorem benchPrizes_map {f : InPlay → InPlay} (hf : ∀ p, (f p).top = p.top) :
    ∀ b : List InPlay, benchPrizes (b.map f) = benchPrizes b
  | [] => rfl
  | p :: ps => by simp only [List.map_cons, benchPrizes, hf p, benchPrizes_map hf ps]

/-- The check's removal commutes with a map of the Pokémon in play that keeps their cards and the
test. -/
theorem PlayerState.koOut_mapPlay {f : InPlay → InPlay} {m : Store → Store} {s : PlayerState}
    {ta tb ta' tb' : InPlay → Bool} (hc : ∀ p, (f p).cardList = p.cardList)
    (ha : ∀ p, s.active = some p → ta' (f p) = ta p) (hb : ∀ p ∈ s.bench, tb' (f p) = tb p) :
    (s.mapPlay f m).koOut ta' tb' = (s.koOut ta tb).mapPlay f m := by
  have ha' : ∀ p, s.active = some p → (fun p => !ta' p) (f p) = (fun p => !ta p) p :=
    fun p hp => by simp only [ha p hp]
  have hb' : ∀ p ∈ s.bench, (fun p => !tb' p) (f p) = (fun p => !tb p) p :=
    fun p hp => by simp only [hb p hp]
  simp only [PlayerState.koOut, PlayerState.mapPlay, optFilter_map ha,
    optFilter_map (t := fun p => !ta p) (t' := fun p => !ta' p) ha',
    filter_map_of hb, filter_map_of (t := fun p => !tb p) (t' := fun p => !tb' p) hb',
    optCardList_map hc, benchCardList_map hc]

theorem PlayerState.koValue_mapPlay {f : InPlay → InPlay} {m : Store → Store} {s : PlayerState}
    {ta tb ta' tb' : InPlay → Bool} (ht : ∀ p, (f p).top = p.top)
    (ha : ∀ p, s.active = some p → ta' (f p) = ta p) (hb : ∀ p ∈ s.bench, tb' (f p) = tb p) :
    (s.mapPlay f m).koValue ta' tb' = s.koValue ta tb := by
  simp only [PlayerState.koValue, PlayerState.mapPlay, optFilter_map ha, filter_map_of hb,
    optPrizes_map ht, benchPrizes_map ht]

theorem PlayerState.noPokemon_mapPlay (f : InPlay → InPlay) (m : Store → Store)
    (s : PlayerState) : (s.mapPlay f m).noPokemon = s.noPokemon := by
  cases ha : s.active <;> cases hb : s.bench <;>
    simp [PlayerState.noPokemon, PlayerState.mapPlay, ha, hb]

theorem winWays_mapPlay (f : InPlay → InPlay) (m : Store → Store) (n : Nat)
    (s o : PlayerState) : winWays n (s.mapPlay f m) (o.mapPlay f m) = winWays n s o := by
  simp only [winWays, PlayerState.noPokemon_mapPlay]
  rfl

/-- **The check commutes with a map of the Pokémon in play** that keeps each Pokémon's view and
cards and, at every Pokémon in play, the threshold test against its derived HP. -/
theorem GameState.koStep_mapPlay {f : InPlay → InPlay} {m : Store → Store} {g : GameState}
    (hsv : ∀ p, (f p).sv = p.sv) (hc : ∀ p, (f p).cardList = p.cardList)
    (ht : ∀ w sp p, g.In w sp p →
      decide (g.hpOf w sp p ≤ (f p).damage) = decide (g.hpOf w sp p ≤ p.damage)) :
    ({ g with cur := g.cur.mapPlay f m, opp := g.opp.mapPlay f m } : GameState).koStep =
      { g.koStep with cur := g.koStep.cur.mapPlay f m, opp := g.koStep.opp.mapPlay f m } := by
  have htop : ∀ p, (f p).top = p.top := fun p => congrArg SView.top (hsv p)
  have hsf : GameState.SameField g
      ({ g with cur := g.cur.mapPlay f m, opp := g.opp.mapPlay f m } : GameState) :=
    ⟨by simp only [PlayerState.field, PlayerState.mapPlay, fieldOf_map hsv hsv],
      by simp only [PlayerState.field, PlayerState.mapPlay, fieldOf_map hsv hsv], rfl, rfl⟩
  have hk : ∀ w sp p, g.In w sp p →
      ({ g with cur := g.cur.mapPlay f m, opp := g.opp.mapPlay f m } : GameState).koT w sp (f p) =
        g.koT w sp p := fun w sp p hp => by
    simp only [GameState.koT]
    rw [hsf.hpOf w sp (hsv p)]
    exact ht w sp p hp
  have hO : ∀ w, ({ g with cur := g.cur.mapPlay f m, opp := g.opp.mapPlay f m } :
      GameState).koOf w = (g.koOf w).mapPlay f m := fun w => by
    cases w
    · exact PlayerState.koOut_mapPlay hc (fun p hp => hk .own .active p hp)
        (fun p hp => hk .own .bench p hp)
    · exact PlayerState.koOut_mapPlay hc (fun p hp => hk .opp .active p hp)
        (fun p hp => hk .opp .bench p hp)
  have hV : ∀ w, ({ g with cur := g.cur.mapPlay f m, opp := g.opp.mapPlay f m } :
      GameState).koVal w = g.koVal w := fun w => by
    cases w
    · exact PlayerState.koValue_mapPlay htop (fun p hp => hk .own .active p hp)
        (fun p hp => hk .own .bench p hp)
    · exact PlayerState.koValue_mapPlay htop (fun p hp => hk .opp .active p hp)
        (fun p hp => hk .opp .bench p hp)
  have e1 := winWays_mapPlay f m (g.koVal .opp) g.cur (g.koOf .opp)
  have e2 := winWays_mapPlay f m (g.koVal .own) g.opp (g.koOf .own)
  simp only [GameState.koStep, hO, hV]
  simp only [e1, e2]
  rfl

theorem decide_le_min {H d K : Nat} (h : H ≤ K) : decide (H ≤ min d K) = decide (H ≤ d) := by
  apply decide_eq_decide.2
  constructor
  · intro h'; exact Nat.le_trans h' (Nat.min_le_left _ _)
  · intro h'; exact Nat.le_min.2 ⟨h', h⟩

/-- **The check commutes with the clamp**, when every derived HP is at most the cap. -/
theorem GameState.koStep_clamp {k : Nat} {g : GameState} (hH : g.HpBelow k) :
    (g.clamp k).koStep = g.koStep.clamp k :=
  GameState.koStep_mapPlay (f := InPlay.clampWith k .hp) (m := Store.cap (2 * k)) (g := g)
    (fun _ => rfl) (fun _ => rfl) (fun w sp p hp => decide_le_min (hH w sp p hp))

/-- Every Pokémon in play updated by `f`, every store by `m`. -/
def GameState.mapPlayAll (f : InPlay → InPlay) (m : Store → Store) (g : GameState) : GameState :=
  { g with cur := g.cur.mapPlay f m, opp := g.opp.mapPlay f m }

/-- **The `koByAttack` triggers a check fires commute with a map of the Pokémon in play** that
keeps each Pokémon's view and Abilities and the threshold test (milestone M8b). -/
theorem GameState.koTrigs_mapPlay {f : InPlay → InPlay} {m : Store → Store} {g : GameState}
    (hsv : ∀ p, (f p).sv = p.sv) (hab : ∀ p, (f p).abilities = p.abilities)
    (ht : ∀ w sp p, g.In w sp p →
      decide (g.hpOf w sp p ≤ (f p).damage) = decide (g.hpOf w sp p ≤ p.damage)) :
    (g.mapPlayAll f m).koTrigs = g.koTrigs := by
  have hsf : GameState.SameField g (g.mapPlayAll f m) :=
    ⟨by simp only [GameState.mapPlayAll, PlayerState.field, PlayerState.mapPlay, fieldOf_map hsv hsv],
      by simp only [GameState.mapPlayAll, PlayerState.field, PlayerState.mapPlay,
        fieldOf_map hsv hsv], rfl, rfl⟩
  have hk : ∀ w sp p, g.In w sp p → (g.mapPlayAll f m).koT w sp (f p) = g.koT w sp p :=
    fun w sp p hp => by
      simp only [GameState.koT]
      rw [hsf.hpOf w sp (hsv p)]
      exact ht w sp p hp
  have htr : ∀ ev sp p, (f p).trigs ev sp = p.trigs ev sp := fun ev sp p => by
    simp only [InPlay.trigs, hab p]
  have hopt : ∀ ev (o : Option InPlay), optTrigs ev (o.map f) = optTrigs ev o := fun ev o => by
    cases o with
    | none => rfl
    | some p => exact htr ev .active p
  have hfl : ∀ (b : List InPlay), (b.map f).flatMap (InPlay.trigs .koByAttack .bench) =
      b.flatMap (InPlay.trigs .koByAttack .bench) := fun b => by
    induction b with
    | nil => rfl
    | cons p ps ih => simp only [List.map_cons, List.flatMap_cons, htr, ih]
  have h1 : ∀ p, g.opp.active = some p →
      (g.mapPlayAll f m).koT .opp .active (f p) = g.koT .opp .active p :=
    fun p hp => hk .opp .active p hp
  have h2 : ∀ p ∈ g.opp.bench, (g.mapPlayAll f m).koT .opp .bench (f p) = g.koT .opp .bench p :=
    fun p hp => hk .opp .bench p hp
  show optTrigs .koByAttack (optFilter ((g.mapPlayAll f m).koT .opp .active) (g.opp.active.map f)) ++
      ((g.opp.bench.map f).filter ((g.mapPlayAll f m).koT .opp .bench)).flatMap
        (InPlay.trigs .koByAttack .bench) = g.koTrigs
  rw [optFilter_map h1, filter_map_of h2, hopt, hfl]
  rfl

/-- The triggers a check fires are the same in two states with the same clamp. -/
theorem GameState.koTrigs_of_clamp {k : Nat} {g₁ g₂ : GameState} (hc : g₁.clamp k = g₂.clamp k)
    (hH : g₁.HpBelow k) (hH₂ : g₂.HpBelow k) : g₁.koTrigs = g₂.koTrigs := by
  have e : ∀ {g : GameState}, g.HpBelow k → (g.clamp k).koTrigs = g.koTrigs := fun {g} h =>
    GameState.koTrigs_mapPlay (f := InPlay.clampWith k .hp) (m := Store.cap (2 * k)) (g := g)
      (fun _ => rfl) (fun _ => rfl) (fun w sp p hp => decide_le_min (h w sp p hp))
  rw [← e hH, hc, e hH₂]

/-- Every derived HP at most `k` carries over to a state with the same clamp. -/
theorem GameState.hpBelow_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k)
    (hH : g₁.HpBelow k) : g₂.HpBelow k := by
  have hsf := GameState.sameField_of_clampAt h
  intro w sp p hp
  obtain ⟨q, hq, ha⟩ := GameState.in_of_clamp h hp
  rw [hsf.hpOf w sp ha.sv]
  exact hH w sp q hq

/-- A promotion is matched, place by place, in a position with the same image under `f`. -/
theorem Promote.sim {f : InPlay → InPlay} {a₁ a₂ a₁' : Option InPlay} {b₁ b₂ b₁' : List InPlay}
    (h : Promote a₁ b₁ a₁' b₁') (ha : a₂.map f = a₁.map f) (hb : b₂.map f = b₁.map f) :
    ∃ a₂' b₂', Promote a₂ b₂ a₂' b₂' ∧ a₂'.map f = a₁'.map f ∧ b₂'.map f = b₁'.map f := by
  cases h with
  | @keep a b =>
      cases a₂ with
      | none => simp at ha
      | some a' => exact ⟨_, _, .keep, ha, hb⟩
  | @pick q c₁ c₂ =>
      cases a₂ with
      | some a' => simp at ha
      | none =>
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split hb
          exact ⟨_, _, .pick, by simp only [Option.map_some, h2],
            by simp only [List.map_append, h1, h3]⟩

/-- **The kernel of `clamp k` is a simulation for the batch Knock Out step**, when every derived
HP is at most `k`. -/
theorem KOBatch.clamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} (h : KOBatch g₁ g₁')
    (hc : g₁.clamp k = g₂.clamp k) (hH : g₁.HpBelow k) :
    ∃ g₂', KOBatch g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  have hH₂ := GameState.hpBelow_of_clamp hc hH
  have hks : g₁.koStep.clamp k = g₂.koStep.clamp k := by
    rw [← GameState.koStep_clamp hH, hc, GameState.koStep_clamp hH₂]
  have hwk := GameState.winner_of_clamp hks
  cases h with
  | won hu hw =>
      exact ⟨_, .won (fun hs => hu (GameState.settled_of_clamp hc.symm hs hH₂))
        (by rw [hwk]; exact hw), hks⟩
  | @go ac ao bc bo hu hw hpc hpo =>
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, hg, hc₂, ha₂, -, -, he₁, he₂⟩ := GameState.clamp_inv hks
      obtain ⟨ac', bc', hpc', hac, hbc⟩ := hpc.sim (a₂ := g₂.koStep.cur.active)
        (b₂ := g₂.koStep.cur.bench) (by rw [hg]; exact hc₂) (by rw [hg]; exact he₁)
      obtain ⟨ao', bo', hpo', hao, hbo⟩ := hpo.sim (a₂ := g₂.koStep.opp.active)
        (b₂ := g₂.koStep.opp.bench) (by rw [hg]; exact ha₂) (by rw [hg]; exact he₂)
      refine ⟨_, .go (fun hs => hu (GameState.settled_of_clamp hc.symm hs hH₂))
        (by rw [hwk]; exact hw) hpc' hpo', ?_⟩
      have e : ∀ X : GameState, ∀ a b c d, (X.withPlay a b c d).clamp k =
          (X.clamp k).withPlay (a.map (InPlay.clampWith k .hp)) (b.map (InPlay.clampWith k .hp))
            (c.map (InPlay.clampWith k .hp)) (d.map (InPlay.clampWith k .hp)) :=
        fun _ _ _ _ _ => rfl
      rw [e, e, hks, hac, hbc, hao, hbo]

/-- The kernel of `clamp k` is a simulation for taking the Knock Outs, when `hpBound` of the cards
is at most `k` (milestone M6 added the hypothesis: derived HP must be at most the cap). -/
theorem Resolve.clamp_sim {k : Nat} {g₁ g₁' : GameState} (h : Resolve g₁ g₁') :
    ∀ {g₂ : GameState}, hpBound g₁.allCards ≤ k → g₁.clamp k = g₂.clamp k →
      ∃ g₂', Resolve g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  induction h with
  | done h =>
      intro g₂ hH hc
      refine ⟨g₂, .done ?_, hc⟩
      rcases h with h | h
      · exact .inl (GameState.settled_of_clamp hc h (GameState.hpBelow_of_hpBound hH))
      · exact .inr (by rw [GameState.winner_of_clamp hc]; exact h)
  | step hn hm _ ih =>
      intro g₂ hH hc
      obtain ⟨m₂, hm₂, hcm⟩ := hm.clamp_sim hc (GameState.hpBelow_of_hpBound hH)
      obtain ⟨g₂', hr₂, hc'⟩ := ih (by rw [hpBound_perm hm.perm]; exact hH) hcm
      exact ⟨g₂', .step (by rw [GameState.winner_of_clamp hc]; exact hn) hm₂ hr₂, hc'⟩

/-! ## Bounds from the cards -/

/-- The largest Resistance printed on a Pokémon card of a list. -/
def maxResist : List Card → Nat
  | [] => 0
  | .pokemon p :: cs => max p.resistAmt (maxResist cs)
  | _ :: cs => maxResist cs

theorem resist_le_maxResist {p : PokemonCard} : ∀ {cs : List Card}, Card.pokemon p ∈ cs →
    p.resistAmt ≤ maxResist cs
  | [], h => nomatch h
  | c :: cs, h => by
      cases h with
      | head => simp only [maxResist]; omega
      | tail _ h =>
          have := resist_le_maxResist h
          cases c <;> simp only [maxResist] <;> omega

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

/-! ## The old turn-boundary statement fails: Checkup leaves a pending Knock Out -/

/-- A Basic Pokémon with 10 HP (one counter). -/
def cxCard : PokemonCard := ⟨"", .basic, none, 1, .grass, [], 0, none, none, .none, false, []⟩

def cxSide (a : InPlay) : PlayerState :=
  ⟨[], [], [], [], [], some a, [], false, false, false, false, false, Store.empty, true⟩

/-- Both Active Pokémon have 10 HP and no damage; the opponent's is Poisoned. -/
def cxState : GameState :=
  ⟨cxSide (InPlay.ofBasic cxCard), cxSide { InPlay.ofBasic cxCard with poisoned := true },
    true, false, false, false, none, none, false, false⟩

/-- `Move.damageBounded_of_turn` (every move that passes the turn yields a state with no
pending Knock Out) is false in the model with Checkup: ending the turn from a state with no
pending Knock Out Poisons the opponent's 10-HP Active Pokémon to its HP. The Knock Out is then
taken between turns (by the batch Knock Out step), before `startTurn`.

The witness `cxState` is not well formed (both Prize lists are empty and there is no winner)
and is not shown reachable; this theorem refutes only the statement about single moves.
`Infinite.endTurn_pending_ko_reachable` gives a witness reached by play from a well-formed
start with no pending Knock Out. -/
theorem Move.endTurn_pending_ko :
    ∃ g g', Move g g' ∧ DamageBounded g ∧ g'.curIsFirst ≠ g.curIsFirst ∧
      ¬ DamageBounded g' := by
  have hk : DamageBounded cxState := by
    intro w sp p hp
    cases w <;> cases sp <;>
      simp only [GameState.In, GameState.side, cxState, cxSide, Option.some.injEq,
        List.not_mem_nil] at hp
    · subst hp; decide
    · subst hp; decide
  refine ⟨cxState, _, .endTurn false false false false false false rfl rfl hk rfl .nil .nil, hk,
    by decide, ?_⟩
  intro hk'
  have := hk' .own .active _ rfl
  exact absurd this (by decide)

end Pokemon
