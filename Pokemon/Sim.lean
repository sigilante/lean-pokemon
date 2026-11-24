import Pokemon.ZoneSim

/-!
# The clamp is a bisimulation (for tame decks)

`GameState.clamp k` caps damage and Poison strength on every Pokémon in play (both Active Pokémon
and, since milestone M3, every Benched Pokémon) at `k` (milestone M6: before it, at their printed
HP), and every damage bonus and reduction in both players' stores at `2 * k`. This file proves that
its kernel is a bisimulation for moves, for a deck whose cards are *tame* (no stored damage
reduction, no `drain`), whose test constants are below `k`, whose derived HP (bounded by `hpBound`
of the cards) is at most `k`, and whose printed Resistance plus the bound `sReduceBound` on the
static damage reduction is at most `k` (`GameState.Fit`, `GameState.HpLe`, `GameState.ReduceLe`;
milestone M6). A static reduction, unlike a stored one, is not an amount play can raise: the one in
force is bounded by the cards (`GameState.sReduce_le`), and is subtracted after Resistance
(`dealtBy_cap_reduce`). Derived HP is read only by Knock Out premises, against the
same value in two states with the same clamp (`GameState.sameField_of_clampAt`), and damage at or
above `k` is at or above every derived HP, so capping at `k` loses nothing. `Pokemon/Lingering.lean` shows that neither tameness
condition can be dropped: with a damage reduction the kernel of `clamp k` is not a simulation for
any `k ≥ 3`, with `drain` for any `k ≥ 2`.

* `Run.cap_sim`: inside an attack's effect, the kernel of `rclamp k` (the player's own damage
  exact; the opponent's damage capped at `k`, the damage bonuses at `2 * k`) is a simulation. A
  bonus is read only by the damage step, which adds `W · (n + bonus) − R` to the opponent's
  damage (Weakness `W` of 1 or 2, Resistance `R ≤ k`); a bonus of `2 * k` or more makes that at
  least `k` (`dealtBy_cap`); a test reads the opponent's damage only against a constant below
  `k`, so it cannot tell `k` from anything larger, and a damage of at least `k` is at least the
  opponent's HP, so the Knock Out after the attack takes it either way. The damage step's amount
  may read the opponent's damage (`Amt.per`): if that damage is below `k` it is the same in both
  states, and if not, the opponent's damage after the step is at least `k` in both, whatever
  the amounts.
* `TRun.clamp_sim`: the kernel of `clamp k` is a simulation for a Trainer card's effect from a
  `Settled` (or finished) state: each step starts `Settled`, where `clamp k` and `rclamp k`
  agree.
* `Move.clamp_sim`, `Reach.clamp_sim`: the kernel of `clamp k` is a (strong) bisimulation for
  `Move` and for `Reach`, under `GameState.Fit k`.
* `Run.noReduce`, `Move.noReduce`, `Move.fit`, `Reach.fit`: with tame cards, no damage reduction
  ever comes into effect, and `Fit k` is preserved by play.
-/

namespace Pokemon

/-! ## Damage reduction stays out of play -/

theorem Run.noReduce {e : Effect} {g g' : GameState} (h : Run e g g') :
    e.tame = true → g.NoReduce → g'.NoReduce := by
  induction h with
  | iteT _ _ _ ih =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih ht.1 hn
  | iteF _ _ _ ih =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih ht.2 hn
  | seq _ _ ih₁ ih₂ =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih₂ ht.2 (ih₁ ht.1 hn)
  | choiceL _ ih =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih ht.1 hn
  | choiceR _ ih =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih ht.2 hn
  | iterNil => intro _ hn; exact hn
  | iterCons _ _ ih₁ ih₂ => intro ht hn; exact ih₂ ht (ih₁ ht hn)
  | @touchActive e w f g p he h => intro _ hn; cases w <;> exact hn
  | @touchBench e w f g q b₁ b₂ he h => intro _ hn; cases w <;> exact hn
  | unmark w m g => intro _ hn; cases w <;> exact hn
  | benchCounters w n h => intro _ hn; cases w <;> exact hn
  | spreadCounters w n g => intro _ hn; cases w <;> exact hn
  | benchSome w _ _ _ _ _ => intro _ hn; cases w <;> exact hn
  | switch w ha hb => intro _ hn; cases w <;> exact hn
  | benchDamage w n h => intro _ hn; cases w <;> exact hn
  | spreadDamage w n g => intro _ hn; cases w <;> exact hn
  | @zone e w g s' hw hz => intro _ hn; cases w <;> exact hn
  | linger w s m g =>
      intro ht hn
      have hm : m.plain = true := by simpa [Effect.tame] using ht
      cases w with
      | own => exact ⟨hn.1.add s m hm, hn.2⟩
      | opp => exact ⟨hn.1, hn.2.add s m hm⟩
  | drain => intro ht; simp [Effect.tame] at ht
  | _ => intro _ hn; exact hn

theorem KOBatch.noReduce {g g' : GameState} (h : KOBatch g g') (hn : g.NoReduce) :
    g'.NoReduce := by
  cases h <;> exact hn

/-- A change of the zones only keeps the stores (milestone M8b). -/
theorem GameState.ZoneOnly.noReduce {g g' : GameState} (z : GameState.ZoneOnly g g')
    (h : g.NoReduce) : g'.NoReduce := by
  unfold GameState.NoReduce
  rw [z.cur_mods, z.opp_mods]
  exact h

theorem Resolve.noReduce {g g' : GameState} (h : Resolve g g') (hn : g.NoReduce) :
    g'.NoReduce := by
  induction h with
  | done => exact hn
  | step _ hm _ ih => exact ih (hm.noReduce hn)
  | trigger _ _ _ _ ht _ ih => exact ih (ht.zoneOnly.noReduce hn)

theorem TRun.noReduce {e : Effect} {g g' : GameState} (h : TRun e g g') :
    e.tame = true → g.NoReduce → g'.NoReduce := by
  induction h with
  | prim _ _ hr hk => intro ht hn; exact hk.noReduce (hr.noReduce ht hn)
  | stop => intro _ hn; exact hn
  | iteT _ _ _ _ ih =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih ht.1 hn
  | iteF _ _ _ _ ih =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih ht.2 hn
  | seq _ _ ih₁ ih₂ =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih₂ ht.2 (ih₁ ht.1 hn)
  | choiceL _ ih =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih ht.1 hn
  | choiceR _ ih =>
      intro ht hn; simp only [Effect.tame, Bool.and_eq_true] at ht; exact ih ht.2 hn
  | iterNil => intro _ hn; exact hn
  | iterCons _ _ ih₁ ih₂ => intro ht hn; exact ih₂ ht (ih₁ ht hn)

/-! ## Inside an attack's effect -/

/-- The HP bound of the cards in the game (`hpBound`, which bounds every derived HP,
`GameState.hpOf_le_hpBound`) is at most `k`, and every Pokémon card in the game has Resistance at
most `k` (milestone M4 added the Resistance: it is subtracted from damage after the bonus,
`dealtBy_cap`). Before milestone M6 the first half read "every Pokémon card has printed HP at most
`k`"; with no static effects `hpBound` is the largest printed HP (`hpBound_noStatics`). -/
def GameState.HpLe (k : Nat) (g : GameState) : Prop :=
  hpBound g.allCards ≤ k ∧ ∀ p : PokemonCard, Card.pokemon p ∈ g.allCards → p.resistAmt ≤ k

theorem GameState.HpLe.of_perm {k : Nat} {g g' : GameState} (h : g.HpLe k)
    (hp : g'.allCards.Perm g.allCards) : g'.HpLe k :=
  ⟨by rw [hpBound_perm hp]; exact h.1, fun p hm => h.2 p (hp.mem_iff.1 hm)⟩

/-- With every Resistance at most `k`, the Resistance in effect is at most `k`. -/
theorem GameState.HpLe.resist {k : Nat} {g : GameState} (h : g.HpLe k) : g.resist ≤ k :=
  GameState.resist_le fun _ hp => h.2 _ (GameState.top_mem_opp_active hp)

/-- Every derived HP is at most `k` (milestone M6). -/
theorem GameState.HpLe.below {k : Nat} {g : GameState} (h : g.HpLe k) : g.HpBelow k :=
  GameState.hpBelow_of_hpBound h.1

/-- Every Pokémon card in the game has Resistance at most `k` less the static reduction bound of
the cards (`sReduceBound`, milestone M6): Resistance and a static reduction are both subtracted
after the bonus, and together they are at most `k` (`dealtBy_cap_reduce`). With no static effects
this is the Resistance half of `HpLe k` (`sReduceBound_noStatics`). -/
def GameState.ReduceLe (k : Nat) (g : GameState) : Prop :=
  ∀ p : PokemonCard, Card.pokemon p ∈ g.allCards → p.resistAmt + sReduceBound g.allCards ≤ k

theorem GameState.ReduceLe.of_perm {k : Nat} {g g' : GameState} (h : g.ReduceLe k)
    (hp : g'.allCards.Perm g.allCards) : g'.ReduceLe k :=
  fun p hm => by rw [sReduceBound_perm hp]; exact h p (hp.mem_iff.1 hm)

/-- What `Run.cap_sim` and `TRun.clamp_sim` need of the cards (milestone M6): `HpLe k`, and
`ReduceLe k` (the Resistance and the static damage reduction in force are together at most `k`). -/
def GameState.CapOk (k : Nat) (g : GameState) : Prop := g.HpLe k ∧ g.ReduceLe k

/-- In states with the same `rclamp k`, an Active Pokémon of the first is matched by one of the
second; with the same damage if the opponent's damage is below `k`. -/
theorem GameState.activeOf_rclamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.rclamp k = g₂.rclamp k)
    (w : Whose) (p : InPlay) (hp : g₁.activeOf w = some p) :
    ∃ q, g₂.activeOf w = some q ∧ (w = .own ∨ p.damage < k → q.damage = p.damage) := by
  cases w with
  | own =>
      have e := (congrArg (fun g => g.cur.active) h).symm
      simp only [GameState.rclamp, GameState.clampAt] at e
      rw [show g₁.cur.active = some p from hp] at e
      obtain ⟨q, hq, ha⟩ := agree_of_map e
      exact ⟨q, hq, fun _ => ha.damage_eq⟩
  | opp =>
      have e := (congrArg (fun g => g.opp.active) h).symm
      simp only [GameState.rclamp, GameState.clampAt] at e
      rw [show g₁.opp.active = some p from hp] at e
      obtain ⟨q, hq, ha⟩ := agree_of_map e
      have hd := ha.damage
      simp only [Cap.dmg] at hd
      exact ⟨q, hq, fun hl => by
        rcases hl with hl | hl
        · cases hl
        · omega⟩

/-- Weakness and Resistance in effect agree in states with the same `rclamp k`. -/
theorem GameState.wr_of_rclamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.rclamp k = g₂.rclamp k) :
    g₂.weak = g₁.weak ∧ g₂.resist = g₁.resist := by
  obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, -, -, -, -⟩ := GameState.clamp_inv h
  exact GameState.wr_congr (map_type_top_of_map hc₂).1 (map_type_top_of_map ha₂).2

/-- A damage of at least `k` stays at least `k` when it is scaled. -/
theorem min_add_mul {a b k : Nat} (h : min a k = min b k) (c : Nat) :
    min (a + c * a) k = min (b + c * b) k := by
  rcases Nat.lt_or_ge a k with ha | ha
  · have : a = b := by omega
    subst this; rfl
  · have hb : k ≤ b := by omega
    have h1 : k ≤ a + c * a := Nat.le_trans ha (Nat.le_add_right _ _)
    have h2 : k ≤ b + c * b := Nat.le_trans hb (Nat.le_add_right _ _)
    rw [Nat.min_eq_right h1, Nat.min_eq_right h2]

/-- **Moving a damage counter reads exact values** (milestone M8a): between the player's own
Pokémon, whose damage both `rclamp` and `xrclamp` keep exact, a counter move from one state is
matched by the same move from a state whose Pokémon in play agree exactly (up to Poison strength
above the bound), to states that agree exactly. -/
theorem CMove.sim {f : Filter} {noKO : Bool} {hp hp₂ : Spot → InPlay → Nat}
    {a a' a₂ : Option InPlay} {b b' b₂ : List InPlay}
    (h : CMove f noKO hp a b a' b')
    (hhp : ∀ sp x y, x.sv = y.sv → hp₂ sp x = hp sp y)
    (ha : a₂.map (InPlay.clampWith K .exact) = a.map (InPlay.clampWith K .exact))
    (hb : b₂.map (InPlay.clampWith K .exact) = b.map (InPlay.clampWith K .exact)) :
    ∃ a₂' b₂', CMove f noKO hp₂ a₂ b₂ a₂' b₂' ∧
      a₂'.map (InPlay.clampWith K .exact) = a'.map (InPlay.clampWith K .exact) ∧
      b₂'.map (InPlay.clampWith K .exact) = b'.map (InPlay.clampWith K .exact) := by
  cases h with
  | @ab x q b₁ b₂' hx hd hk =>
      obtain ⟨x₂, rfl, hx₂⟩ := agree_of_map ha
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split hb
      have hr := InPlay.agree_of_clamp h2
      have k1 := hx₂.clamp_map (c' := .exact) hx₂.damage_eq
        (fun y => { y with damage := y.damage - 1 }) (fun _ => rfl) rfl rfl
      have k2 := hr.clamp_map (c' := .exact) hr.damage_eq (InPlay.addDamage 1) (fun _ => rfl)
        rfl rfl
      refine ⟨_, _, .ab (by rw [hx₂.top]; exact hx) (by rw [hx₂.damage_eq]; exact hd)
        (fun h => by rw [hr.damage_eq, hhp _ _ _ hr.sv]; exact hk h), ?_, ?_⟩
      · simp only [Option.map_some, k1]
      · simp only [List.map_append, List.map_cons, h1, h3, k2]
  | @ba x q b₁ b₂' hq hd hk =>
      obtain ⟨x₂, rfl, hx₂⟩ := agree_of_map ha
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split hb
      have hr := InPlay.agree_of_clamp h2
      have k1 := hx₂.clamp_map (c' := .exact) hx₂.damage_eq (InPlay.addDamage 1) (fun _ => rfl)
        rfl rfl
      have k2 := hr.clamp_map (c' := .exact) hr.damage_eq
        (fun y => { y with damage := y.damage - 1 }) (fun _ => rfl) rfl rfl
      refine ⟨_, _, .ba (by rw [hr.top]; exact hq) (by rw [hr.damage_eq]; exact hd)
        (fun h => by rw [hx₂.damage_eq, hhp _ _ _ hx₂.sv]; exact hk h), ?_, ?_⟩
      · simp only [Option.map_some, k1]
      · simp only [List.map_append, List.map_cons, h1, h3, k2]
  | @bb _ q r b₁ b₂' c₁ c₂ hq hd hc hne hk =>
      obtain ⟨d₁, q₂, d₂, rfl, h1, h2, h3⟩ := map_eq_split hb
      have hq₂ := InPlay.agree_of_clamp h2
      have k1 := hq₂.clamp_map (c' := .exact) hq₂.damage_eq
        (fun y => { y with damage := y.damage - 1 }) (fun _ => rfl) rfl rfl
      have hB : (d₁ ++ { q₂ with damage := q₂.damage - 1 } :: d₂).map (InPlay.clampWith K .exact) =
          (c₁ ++ r :: c₂).map (InPlay.clampWith K .exact) := by
        rw [← hc]; simp only [List.map_append, List.map_cons, h1, h3, k1]
      obtain ⟨e₁, r₂, e₂, hc₂, i1, i2, i3⟩ := map_eq_split hB
      have hr₂ := InPlay.agree_of_clamp i2
      have k2 := hr₂.clamp_map (c' := .exact) hr₂.damage_eq (InPlay.addDamage 1) (fun _ => rfl)
        rfl rfl
      refine ⟨a₂, _, .bb (by rw [hq₂.top]; exact hq) (by rw [hq₂.damage_eq]; exact hd) hc₂
        (by rw [length_of_map i1, length_of_map h1]; exact hne)
        (fun h => by rw [hr₂.damage_eq, hhp _ _ _ hr₂.sv]; exact hk h), ha, ?_⟩
      simp only [List.map_append, List.map_cons, i1, i3, k2]

theorem GameState.CapOk.of_perm {k : Nat} {g g' : GameState} (h : g.CapOk k)
    (hp : g'.allCards.Perm g.allCards) : g'.CapOk k :=
  ⟨h.1.of_perm hp, h.2.of_perm hp⟩

theorem GameState.CapOk.resist {k : Nat} {g : GameState} (h : g.CapOk k) : g.resist ≤ k :=
  h.1.resist

/-- **Inside an attack's effect, the kernel of `rclamp k` is a simulation**, for a tame effect
whose test constants are below `k`, from a state with no stored damage reduction and `CapOk k`.
Two states that agree except in the opponent's damage at or above `k`, the damage bonuses at or
above `2 * k`, and Poison strength above `k` have the same effect resolutions, up to the same
relation. -/
theorem Run.cap_sim {k : Nat} (hk0 : 0 < k) {e : Effect} {g₁ g₁' : GameState}
    (h : Run e g₁ g₁') :
    e.tame = true → e.tmax < k → g₁.NoReduce → g₁.CapOk k → ∀ {g₂ : GameState},
      g₁.rclamp k = g₂.rclamp k →
      ∃ g₂', Run e g₂ g₂' ∧ g₁'.rclamp k = g₂'.rclamp k := by
  induction h with
  | skip g => intro _ _ _ _ g₂ hc; exact ⟨g₂, .skip g₂, hc⟩
  | draw h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .draw h, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂]⟩
  | drawEmpty h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .drawEmpty h, hc⟩
  | @heal g p n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have hq' : InPlay.Agree k .exact { q with damage := q.damage - n }
          { p with damage := p.damage - n } := by
        rw [hq.damage_eq]; exact hq.setDamage _
      exact ⟨_, .heal n rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some,
          InPlay.clamp_of_agree hq', ha₂, hm₁, hm₂, he₁, he₂]⟩
  | counters n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .counters n rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n), he₁, he₂]⟩
  | inflict c h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .inflict c rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.2.2.1 c), he₁, he₂]⟩
  | poisonUp n h hp =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUp n rfl (hq.poisoned.trans hp), by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.2.1 n), he₁, he₂]⟩
  | poisonUpSkip n h hp =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUpSkip n rfl (hq.poisoned.trans hp), hc⟩
  | cure h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .cure rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂,
          InPlay.clamp_of_agree hq.upd.2.2.2.2.1, he₁, he₂]⟩
  | iteT h ht' _ ih =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih ht.1 (by omega) hn hR hc
      exact ⟨g₂', .iteT hq (by rw [Test.eval_agree _ (GameState.count_of_clampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | iteF h ht' _ ih =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih ht.2 (by omega) hn hR hc
      exact ⟨g₂', .iteF hq (by rw [Test.eval_agree _ (GameState.count_of_clampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | @scale g p q w k' hs h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q₂, rfl, hq⟩ := agree_of_map ha₂
      cases w with
      | own =>
          change g.cur.active = some p at hs
          rw [hs] at hc₂
          obtain ⟨s, rfl, hsa⟩ := agree_of_map hc₂
          have hq' : InPlay.Agree k (.upto k) { q₂ with damage := q₂.damage + k' * s.damage }
              { q with damage := q.damage + k' * p.damage } := by
            rw [hsa.damage_eq]; exact hq.upd.2.1 _
          exact ⟨_, .scale .own k' rfl rfl, by
            simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hs, hm₁, hm₂,
              InPlay.clamp_of_agree hq', InPlay.clamp_of_agree hsa, he₁, he₂]⟩
      | opp =>
          change g.opp.active = some p at hs
          have e : q = p := Option.some.inj (h.symm.trans hs)
          subst e
          have hd := hq.damage
          simp only [Cap.dmg] at hd
          have hq' : InPlay.Agree k (.upto k) { q₂ with damage := q₂.damage + k' * q₂.damage }
              { q with damage := q.damage + k' * q.damage } :=
            ⟨hq.top, hq.under, hq.energy, hq.tools, hq.rot, hq.poisoned, hq.burned, hq.fresh,
              hq.marks, hq.used, by simp only [Cap.dmg]; exact min_add_mul hd k', hq.poisonUp, hq.movedUp, hq.lk⟩
          exact ⟨_, .scale .opp k' rfl rfl, by
            simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
              InPlay.clamp_of_agree hq', he₁, he₂]⟩
  | @selfDamage g p n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .selfDamage n rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n), he₁, he₂]⟩
  | @healAll g p h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .healAll rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.setDamage 0), he₁, he₂]⟩
  | @touchActive e w f g p he h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h] at hc₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, Option.map_some,
              ha₂, hm₁, hm₂, InPlay.clamp_of_agree (hq.setMarks f), he₁, he₂]⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h] at ha₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, Option.map_some,
              hc₂, hm₁, hm₂, InPlay.clamp_of_agree (hq.setMarks f), he₁, he₂]⟩
  | @touchBench e w f g q b₁ b₂ he h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
          exact ⟨_, .touchBench (w := .own) he rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁,
              hm₂, he₂, List.map_append, List.map_cons, h1, h3, InPlay.clampWith_setMarks', h2]⟩
      | opp =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₂)
          exact ⟨_, .touchBench (w := .opp) he rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁,
              hm₂, he₁, List.map_append, List.map_cons, h1, h3, InPlay.clampWith_setMarks', h2]⟩
  | unmark w m g =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .unmark _ m _, by
          simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, PlayerState.unmark,
            hc₂, ha₂, hm₁, hm₂, map_clamp_setMarks _ hc₂, map_clamp_setMarks _ ha₂,
            bench_map_comm (InPlay.clampWith_setMarks' _ _) he₁,
            bench_map_comm (InPlay.clampWith_setMarks' _ _) he₂, he₁, he₂]⟩
  | linger w s m g =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .linger _ s m _, by
          simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂,
            Store.cap_add hm₁, Store.cap_add hm₂, he₁, he₂]⟩
  | @damage g p a ig n hv h =>
      intro _ _ hn hR g₂ hc
      have hwr := GameState.wr_of_rclamp hc
      have hsf := GameState.sameField_of_clampAt hc
      have hr : cond ig.resist 0 g.resist + g.sReduce ≤ k := by
        have h1 := hR.2 _ (GameState.top_mem_opp_active h)
        have h2 := g.sReduce_le
        have h3 : g.resist ≤ p.top.resistAmt :=
          GameState.resist_le fun d hd => by rw [h] at hd; cases hd; exact Nat.le_refl _
        have h4 : cond ig.resist 0 g.resist ≤ g.resist := by cases ig.resist <;> simp
        omega
      by_cases hlt : p.damage < k
      · have hv₂ := hv.congr (GameState.count_of_clampAt hc) fun w p' hp' => by
          obtain ⟨q', hq', hd'⟩ := GameState.activeOf_rclamp hc w p' hp'
          refine ⟨q', hq', hd' ?_⟩
          cases w with
          | own => exact .inl rfl
          | opp =>
              have e : p' = p := Option.some.inj (hp'.symm.trans h)
              rw [e]; exact .inr hlt
        obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
        rw [h] at ha₂
        obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
        refine ⟨_, .damage (ig := ig) hv₂ rfl, ?_⟩
        have hcap : min (GameState.dealtI ig n { g with
                cur := { g.cur with active := c₂, bench := e₁, mods := m₁ },
                opp := { g.opp with active := some q, bench := e₂, mods := m₂ } }) k =
            min (g.dealtI ig n) k := by
          simp only [GameState.dealtI, hwr.1, hwr.2, hsf.sBonus, hsf.sReduce, hsf.sPrevent]
          rcases Bool.eq_false_or_eq_true (cond ig.fx false g.sPrevent) with hc | hc <;>
            simp only [hc, ↓reduceIte, Bool.false_eq_true]
          exact dealtBy_cap_ign hk0 (Store.cap_add hm₁ _ _) hm₂ hn.2 (hn.1.add _ _ rfl) n _ ig.fx hr
        have hq' : InPlay.Agree k (.upto k)
            { q with damage := q.damage + GameState.dealtI ig n { g with
                cur := { g.cur with active := c₂, bench := e₁, mods := m₁ },
                opp := { g.opp with active := some q, bench := e₂, mods := m₂ } } }
            { p with damage := p.damage + g.dealtI ig n } :=
          ⟨hq.top, hq.under, hq.energy, hq.tools, hq.rot, hq.poisoned, hq.burned, hq.fresh,
            hq.marks, hq.used, hq.dmg_add_upto hcap, hq.poisonUp, hq.movedUp, hq.lk⟩
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree hq', he₁, he₂]
      · obtain ⟨n₂, hv₂⟩ := hv.transfer fun w p' hp' => by
          obtain ⟨q', hq', -⟩ := GameState.activeOf_rclamp hc w p' hp'
          exact ⟨q', hq'⟩
        obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
        rw [h] at ha₂
        obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
        refine ⟨_, .damage (ig := ig) hv₂ rfl, ?_⟩
        have hd := hq.damage
        simp only [Cap.dmg] at hd
        have hq' : InPlay.Agree k (.upto k)
            { q with damage := q.damage + GameState.dealtI ig n₂ { g with
                cur := { g.cur with active := c₂, bench := e₁, mods := m₁ },
                opp := { g.opp with active := some q, bench := e₂, mods := m₂ } } }
            { p with damage := p.damage + g.dealtI ig n } :=
          ⟨hq.top, hq.under, hq.energy, hq.tools, hq.rot, hq.poisoned, hq.burned, hq.fresh,
            hq.marks, hq.used, by simp only [Cap.dmg]; omega, hq.poisonUp, hq.movedUp, hq.lk⟩
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree hq', he₁, he₂]
  | @benchCounters g q b₁ b₂ w n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
          have hr := InPlay.agree_of_clamp h2
          exact ⟨_, .benchCounters (b₁ := d₁) .own n rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂, he₂,
              List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.upd.2.1 n)]⟩
      | opp =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₂)
          have hr := InPlay.agree_of_clamp h2
          exact ⟨_, .benchCounters (b₁ := d₁) .opp n rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂, he₁,
              List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.upd.2.1 n)]⟩
  | benchCountersNone w n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₁
          subst he₁
          exact ⟨_, .benchCountersNone .own n rfl, hc⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₂
          subst he₂
          exact ⟨_, .benchCountersNone .opp n rfl, hc⟩
  | spreadCounters w n g =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .spreadCounters _ n _, by
          simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂, he₁, he₂,
            bench_map_agree (U := InPlay.addDamage n) (fun x y h => h.upd.2.1 n) he₁,
            bench_map_agree (U := InPlay.addDamage n) (fun x y h => h.upd.2.1 n) he₂]⟩
  | benchSome w m f dmg n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          obtain ⟨e', h', he'⟩ := h.transfer (clampWith_hitWith dmg n) clampWith_top he₁
          rw [← benchElig_congr clampWith_top f he₁] at h'
          exact ⟨_, .benchSome .own m f dmg n h', by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂,
              he₂, he']⟩
      | opp =>
          simp only [GameState.side] at h
          obtain ⟨e', h', he'⟩ := h.transfer (clampWith_hitWith dmg n) clampWith_top he₂
          rw [← benchElig_congr clampWith_top f he₂] at h'
          exact ⟨_, .benchSome .opp m f dmg n h', by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂,
              he₁, he']⟩
  | moveCounter h =>
      intro _ _ _ _ g₂ hc
      have hsf := GameState.sameField_of_clampAt hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      obtain ⟨a₂', b₂', hm, ha', hb'⟩ := h.sim (fun sp _ _ hxy => hsf.hpOf .own sp hxy) hc₂ he₁
      exact ⟨_, .moveCounter hm, by
        simp only [GameState.rclamp, GameState.clampAt, ha', hb', ha₂, hm₁, hm₂, he₂]⟩
  | @benchHeal g q b₁ b₂ n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      have hr' : InPlay.Agree k .exact { r with damage := r.damage - n }
          { q with damage := q.damage - n } := by
        rw [hr.damage_eq]; exact hr.setDamage _
      exact ⟨_, .benchHeal n rfl, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₂, List.map_append, List.map_cons, h1, h3,
          InPlay.clamp_of_agree hr']⟩
  | @switch g a q b₁ b₂ w ha h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at ha h
          rw [ha] at hc₂
          obtain ⟨a', rfl, hqa⟩ := agree_of_map hc₂
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
          exact ⟨_, .switch (b₁ := d₁) .own rfl rfl, Whose.noteBenched_clampAt .own (by
            simp only [GameState.clampAt, GameState.updSide, ha₂, hm₁, hm₂, he₂, Option.map_some,
              List.map_append, List.map_cons, Whose.mover, InPlay.clampWith_moveUp, h1, h2, h3, InPlay.clamp_of_agree hqa.upd.2.2.2.2.1.unlock])⟩
      | opp =>
          simp only [GameState.side] at ha h
          rw [ha] at ha₂
          obtain ⟨a', rfl, hqa⟩ := agree_of_map ha₂
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₂)
          exact ⟨_, .switch (b₁ := d₁) .opp rfl rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, hm₁, hm₂, he₁, Option.map_some,
              List.map_append, List.map_cons, Whose.mover, id, h1, h2, h3, InPlay.clamp_of_agree hqa.upd.2.2.2.2.1.unlock,
              Whose.noteBenched]⟩
  | switchNone w h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₁
          subst he₁
          exact ⟨_, .switchNone .own rfl, hc⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₂
          subst he₂
          exact ⟨_, .switchNone .opp rfl, hc⟩
  | @benchDamage g q b₁ b₂ w n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
          have hr := InPlay.agree_of_clamp h2
          exact ⟨_, .benchDamage (b₁ := d₁) .own n rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂, he₂,
              List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.hitBench n)]⟩
      | opp =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₂)
          have hr := InPlay.agree_of_clamp h2
          exact ⟨_, .benchDamage (b₁ := d₁) .opp n rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂, he₁,
              List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.hitBench n)]⟩
  | benchDamageNone w n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₁
          subst he₁
          exact ⟨_, .benchDamageNone .own n rfl, hc⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₂
          subst he₂
          exact ⟨_, .benchDamageNone .opp n rfl, hc⟩
  | spreadDamage w n g =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .spreadDamage _ n _, by
          simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂, he₁, he₂,
            bench_map_agree (U := InPlay.hitBench n) (fun x y h => h.hitBench n) he₁,
            bench_map_agree (U := InPlay.hitBench n) (fun x y h => h.hitBench n) he₂]⟩
  | benchHealNone n h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h, List.map_nil, List.map_eq_nil_iff] at he₁
      subst he₁
      exact ⟨_, .benchHealNone n rfl, hc⟩
  | drain => intro ht; simp [Effect.tame] at ht
  | @zone e w g s' hw hz =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          obtain ⟨s₂', hz₂, hag⟩ := hz.sim (s₂ := { g.cur with active := c₂, bench := e₁, mods := m₁ })
            ⟨rfl, rfl, rfl, hc₂, he₁⟩
          exact ⟨_, .zone hw hz₂, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide,
              PlayerState.setZones, hag.deck, hag.hand, hag.discard, hag.active, hag.bench, ha₂,
              he₂, hm₁, hm₂]⟩
      | opp =>
          obtain ⟨s₂', hz₂, hag⟩ := hz.sim (s₂ := { g.opp with active := a₂, bench := e₂, mods := m₂ })
            ⟨rfl, rfl, rfl, ha₂, he₂⟩
          exact ⟨_, .zone hw hz₂, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide,
              PlayerState.setZones, hag.deck, hag.hand, hag.discard, hag.active, hag.bench, hc₂,
              he₁, hm₁, hm₂]⟩
  | shuffle h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .shuffle h, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂]⟩
  | search h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .search h, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂]⟩
  | handToBottom h =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .handToBottom h, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂]⟩
  | discardStadium g =>
      intro _ _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .discardStadium _, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂]⟩
  | seq h₁ _ ih₁ ih₂ =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ ht.1 (by omega) hn hR hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ ht.2 (by omega) (h₁.noReduce ht.1 hn) (hR.of_perm h₁.perm) hc'
      exact ⟨g₂'', .seq r₁ r₂, hc''⟩
  | choiceL _ ih =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih ht.1 (by omega) hn hR hc
      exact ⟨g₂', .choiceL r, hc'⟩
  | choiceR _ ih =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih ht.2 (by omega) hn hR hc
      exact ⟨g₂', .choiceR r, hc'⟩
  | iterNil a g => intro _ _ _ _ g₂ hc; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons h₁ _ ih₁ ih₂ =>
      intro ht hb hn hR g₂ hc
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ ht hb hn hR hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ ht hb (h₁.noReduce ht hn) (hR.of_perm h₁.perm) hc'
      exact ⟨g₂'', .iterCons r₁ r₂, hc''⟩

/-! ## Trainer effects -/

/-- **The kernel of `clamp k` is a simulation for Trainer effects** (`TRun`), from a state that
is `Settled` or finished, for a tame effect with test constants below `k`, with no stored damage
reduction and `CapOk k` (every derived HP at most `k`; every Resistance plus the static reduction
bound at most `k`). -/
theorem TRun.clamp_sim {k : Nat} (hk0 : 0 < k) {e : Effect} {g₁ g₁' : GameState}
    (h : TRun e g₁ g₁') :
    e.tame = true → e.tmax < k → g₁.NoReduce → g₁.CapOk k → ∀ {g₂ : GameState},
      g₁.clamp k = g₂.clamp k → (Settled g₁ ∨ g₁.winner ≠ none) →
        ∃ g₂', TRun e g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  induction h with
  | prim he hn hr hk =>
      intro ht hb hnr hhp g₂ hc hs
      have hs : Settled _ := hs.resolve_right (fun h => h hn)
      obtain ⟨m₂, hr₂, hcm⟩ := Run.cap_sim hk0 hr ht hb hnr hhp
        (GameState.rclamp_of_clamp hc hs.1 hhp.1.below)
      have hhp' := hhp.of_perm hr.perm
      obtain ⟨g₂', hk₂, hc'⟩ := hk.clamp_sim (k := k) hhp'.1.1 (GameState.clamp_of_rclamp hcm)
      exact ⟨g₂', .prim he (by rw [GameState.winner_of_clamp hc]; exact hn) hr₂ hk₂, hc'⟩
  | stop hn =>
      intro _ _ _ _ g₂ hc _
      exact ⟨g₂, .stop (by rw [GameState.winner_of_clamp hc]; exact hn), hc⟩
  | iteT hn h ht' _ ih =>
      intro ht hb hnr hhp g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ :=
        GameState.activeOf_agree (GameState.rclamp_of_clamp hc hs'.1 hhp.1.below) h
      obtain ⟨g₂', r', hc'⟩ := ih ht.1 (by omega) hnr hhp hc hs
      exact ⟨g₂', .iteT (by rw [GameState.winner_of_clamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ (GameState.count_of_clampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | iteF hn h ht' _ ih =>
      intro ht hb hnr hhp g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ :=
        GameState.activeOf_agree (GameState.rclamp_of_clamp hc hs'.1 hhp.1.below) h
      obtain ⟨g₂', r', hc'⟩ := ih ht.2 (by omega) hnr hhp hc hs
      exact ⟨g₂', .iteF (by rw [GameState.winner_of_clamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ (GameState.count_of_clampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | seq h₁ _ ih₁ ih₂ =>
      intro ht hb hnr hhp g₂ hc hs
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨m₂, r₁, hcm⟩ := ih₁ ht.1 (by omega) hnr hhp hc hs
      obtain ⟨g₂', r₂, hc'⟩ := ih₂ ht.2 (by omega) (h₁.noReduce ht.1 hnr)
        (hhp.of_perm h₁.perm) hcm (h₁.settled_or_won hs)
      exact ⟨g₂', .seq r₁ r₂, hc'⟩
  | choiceL _ ih =>
      intro ht hb hnr hhp g₂ hc hs
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih ht.1 (by omega) hnr hhp hc hs
      exact ⟨g₂', .choiceL r, hc'⟩
  | choiceR _ ih =>
      intro ht hb hnr hhp g₂ hc hs
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih ht.2 (by omega) hnr hhp hc hs
      exact ⟨g₂', .choiceR r, hc'⟩
  | iterNil a g => intro _ _ _ _ g₂ hc _; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons h₁ _ ih₁ ih₂ =>
      intro ht hb hnr hhp g₂ hc hs
      obtain ⟨m₂, r₁, hcm⟩ := ih₁ ht hb hnr hhp hc hs
      obtain ⟨g₂', r₂, hc'⟩ := ih₂ ht hb (h₁.noReduce ht hnr) (hhp.of_perm h₁.perm) hcm
        (h₁.settled_or_won hs)
      exact ⟨g₂', .iterCons r₁ r₂, hc'⟩

/-! ## Moves -/

/-- The conditions under which the kernel of `clamp k` is a bisimulation for moves: `0 < k`;
`HpLe k` (`hpBound` of the cards, which bounds every derived HP, and every Resistance at most `k`);
every card is tame (no stored damage reduction, no `drain` (since milestone MV6 also no step-2 penalty or step-5 increase, `Mod.plain`)) and its test constants are below `k`;
no damage reduction is stored; and `ReduceLe k` (every Resistance plus the static reduction bound
`sReduceBound` of the cards at most `k`; milestone M6). Static damage reductions are allowed: the
one in force is a function of the cards in play, bounded by `sReduceBound`, not an amount that
play can raise. -/
def GameState.Fit (k : Nat) (g : GameState) : Prop :=
  0 < k ∧ g.HpLe k ∧ (∀ x ∈ g.allCards, x.tame = true ∧ x.tmax < k) ∧ g.NoReduce ∧ g.ReduceLe k

theorem attacksTame_mem {atk : Attack} : ∀ {as : List Attack}, attacksTame as = true →
    atk ∈ as → atk.effect.tame = true
  | a :: as, h, hm => by
      simp only [attacksTame, Bool.and_eq_true] at h
      cases hm with
      | head => exact h.1
      | tail _ hm => exact attacksTame_mem h.2 hm

theorem attacksTmax_mem {atk : Attack} : ∀ {as : List Attack}, atk ∈ as →
    atk.effect.tmax ≤ attacksTmax as
  | a :: as, hm => by
      simp only [attacksTmax]
      cases hm with
      | head => omega
      | tail _ hm => have := attacksTmax_mem hm; omega

/-- An attack of a tame card (a Pokémon card's, or one a Tool gives) is tame, with test constants
at most the card's (milestone M5: any card). -/
theorem Card.attack_tame {c : Card} (h : c.tame = true) {atk : Attack} (hm : atk ∈ c.attacks) :
    atk.effect.tame = true ∧ atk.effect.tmax ≤ c.tmax := by
  cases c with
  | pokemon p =>
      simp only [Card.tame, Bool.and_eq_true] at h
      have := attacksTmax_mem (as := p.attacks) hm
      exact ⟨attacksTame_mem h.1 hm, by simp only [Card.tmax]; omega⟩
  | tool n gr =>
      simp only [Card.tame, Bool.and_eq_true] at h
      have := attacksTmax_mem (as := gr.attacks) hm
      exact ⟨attacksTame_mem h.1 hm, by simp only [Card.tmax]; omega⟩
  | _ => nomatch hm

/-- The effect an attack resolves is tame, with test constants below `k`. -/
theorem GameState.Fit.attack {k : Nat} {g : GameState} (hF : g.Fit k) {a : InPlay} {atk : Attack}
    (ha : g.cur.active = some a) (hm : atk ∈ a.attacks) :
    atk.script.tame = true ∧ atk.script.tmax < k := by
  obtain ⟨c, hc, hmc⟩ := InPlay.attack_mem hm
  obtain ⟨ht, hb⟩ := hF.2.2.1 _ (GameState.mem_allCards_of_cur_active ha hc)
  obtain ⟨h1, h2⟩ := Card.attack_tame ht hmc
  rw [Attack.script_tame, Attack.script_tmax]
  exact ⟨h1, by omega⟩

/-- The effect of a Trainer card in hand is tame, with test constants below `k`. -/
theorem GameState.Fit.trainer {k : Nat} {g : GameState} (hF : g.Fit k) {n : String}
    {t : TrainerKind} {e : Effect} {l₁ l₂ : List Card}
    (hh : g.cur.hand = l₁ ++ Card.trainer n t e :: l₂) : e.tame = true ∧ e.tmax < k := by
  have hx : Card.trainer n t e ∈ g.cur.hand := by
    rw [hh]; exact List.mem_append_right _ (.head _)
  exact hF.2.2.1 _ (GameState.mem_allCards_of_hand hx)

theorem abilitiesTame_mem {ab : Ability} : ∀ {as : List Ability}, abilitiesTame as = true →
    ab ∈ as → ∀ e ∈ ab.scripts, e.tame = true
  | a :: as, h, hm => by
      simp only [abilitiesTame, Bool.and_eq_true] at h
      cases hm with
      | head => exact List.all_eq_true.1 h.1
      | tail _ hm => exact abilitiesTame_mem h.2 hm

theorem abilitiesTmax_mem {ab : Ability} : ∀ {as : List Ability}, ab ∈ as →
    ab.tmax ≤ abilitiesTmax as
  | a :: as, hm => by
      simp only [abilitiesTmax]
      cases hm with
      | head => omega
      | tail _ hm => have := abilitiesTmax_mem hm; omega

/-- An Ability's test constants are below `k` when its card's are (milestone M8a; milestone M5:
any card, a Tool's granted Abilities included). -/
theorem Card.ability_tmax {c : Card} {ab : Ability} (hm : ab ∈ c.abilities) :
    ab.tmax ≤ c.tmax := by
  cases c with
  | pokemon p => have := abilitiesTmax_mem (as := p.abilities) hm; simp only [Card.tmax]; omega
  | tool n gr => have := abilitiesTmax_mem (as := gr.abilities) hm; simp only [Card.tmax]; omega
  | _ => nomatch hm

theorem Card.ability_tame {c : Card} (h : c.tame = true) {ab : Ability} (hm : ab ∈ c.abilities) :
    ∀ e ∈ ab.scripts, e.tame = true := by
  cases c with
  | pokemon p => simp only [Card.tame, Bool.and_eq_true] at h; exact abilitiesTame_mem h.2 hm
  | tool n gr => simp only [Card.tame, Bool.and_eq_true] at h; exact abilitiesTame_mem h.2 hm
  | _ => nomatch hm

/-- The effect of an Ability of a card in the game is tame, and its test constants, its
condition's included, are below `k` (milestone M8a). -/
theorem GameState.Fit.ability_of_mem {k : Nat} {g : GameState} (hF : g.Fit k) {c : Card}
    (hp : c ∈ g.allCards) {ab : Ability} (hm : ab ∈ c.abilities) :
    (∀ e ∈ ab.scripts, e.tame = true) ∧ ab.tmax < k := by
  obtain ⟨ht, hb⟩ := hF.2.2.1 _ hp
  have := Card.ability_tmax hm
  exact ⟨Card.ability_tame ht hm, by omega⟩

theorem GameState.Fit.ability {k : Nat} {g g₁ : GameState} (hF : g.Fit k) {x : InPlay}
    {sp : Spot} {ab : Ability} (hu : UseAt g x sp g₁) (hm : ab ∈ x.abilities) :
    (∀ e ∈ ab.scripts, e.tame = true) ∧ ab.tmax < k := by
  obtain ⟨c, hc, hmc⟩ := InPlay.ability_mem hm
  exact hF.ability_of_mem (hu.card_mem hc) hmc

theorem effectsTmax_mem {e : Effect} : ∀ {es : List Effect}, e ∈ es → e.tmax ≤ effectsTmax es
  | a :: as, hm => by
      simp only [effectsTmax]
      cases hm with
      | head => omega
      | tail _ hm => have := effectsTmax_mem hm; omega

theorem Ability.script_tmax_le (ab : Ability) (p : Option Spot) :
    (ab.script p).tmax ≤ ab.tmax := by
  have := effectsTmax_mem (ab.script_mem p)
  simp only [Ability.tmax]; omega

/-- An Ability's condition holds in a state with the same clamp, with no Knock Out pending
(milestone M8a). -/
theorem Ability.CondOk.of_clamp {k : Nat} {ab : Ability} {g₁ g₂ : GameState} (h : ab.CondOk g₁)
    (hc : g₁.clamp k = g₂.clamp k) (hk : DamageBounded g₁) (hb : ab.tmax < k)
    (hH : g₁.HpBelow k) : ab.CondOk g₂ := by
  unfold Ability.CondOk at h ⊢
  cases hcd : ab.cond with
  | none => trivial
  | some t =>
      rw [hcd] at h
      obtain ⟨p, hp, he⟩ := h
      have ht : t.bound < k := by simp only [Ability.tmax, hcd] at hb; omega
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree (GameState.rclamp_of_clamp hc hk hH) hp
      exact ⟨q, hq, by rw [Test.eval_agree _ (GameState.count_of_clampAt hc) hqa ht]; exact he⟩

/-- **Marking a Pokémon as having used an Ability commutes with the clamp** (milestone M8a):
the same Pokémon (the same card, the same flag) is in the
same place of a state with the same clamp, and marking it there gives the same clamp. -/
theorem UseAt.clamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} {x : InPlay} {sp : Spot}
    (hu : UseAt g₁ x sp g₁') (hc : g₁.clamp k = g₂.clamp k) :
    ∃ x' g₂', UseAt g₂ x' sp g₂' ∧ x'.top = x.top ∧ x'.used = x.used ∧
      x'.abilities = x.abilities ∧ g₁'.clamp k = g₂'.clamp k := by
  obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, hg, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
  subst hg
  cases hu with
  | active ha =>
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨q, _, .active rfl, hq.top, hq.used, hq.grants.2, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂, he₁, he₂,
          InPlay.clamp_of_agree hq.markUsed]⟩
  | @bench b₁ b₂ hb =>
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      exact ⟨r, _, .bench rfl, hr.top, hr.used, hr.grants.2, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₂, List.map_append,
          List.map_cons, h1, h3, InPlay.clamp_of_agree hr.markUsed]⟩

/-- **A play from the hand commutes with the clamp** (milestone M8a): from states with the same
clamp the same card can be played the same way, to states with the same clamp. -/
theorem PlayFromHand.clamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g₁ x w g₁') (hc : g₁.clamp k = g₂.clamp k) (hH : g₁.HpBelow k) :
    ∃ x' g₂', PlayFromHand g₂ x' w g₂' ∧ x'.top = x.top ∧ g₁'.clamp k = g₂'.clamp k := by
  have hs₂ := fun hs => GameState.settled_of_clamp hc hs hH
  obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, hg, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
  cases h with
  | basic hh hs hhp hb hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, _, .basic hh hs hhp (by rw [length_of_map he₁]; exact hb) hbt hs' hat, rfl, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂,
          List.map_append]⟩
  | @evolve l₁ l₂ p a hh ha he hfr hf hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
      refine ⟨_, _, .evolve hh rfl (by rw [hq.top]; exact he) (hq.fresh.trans hfr) hf hbt hs' hat,
        rfl, ?_⟩
      rw [e]
      simp only [GameState.clamp, GameState.clampAt, ha₂, hm₁, hm₂, he₁, he₂]
  | @evolveBench l₁ l₂ p q b₁ b₂ hh hb he hfr hf hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      have hlt : q.damage < k := hst.1.lt_bound hH (w := .own) (sp := .bench)
        (show q ∈ g₁.cur.bench by rw [hb]; exact List.mem_append_right _ (.head _))
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      have e := hr.eq_upd (hr.damage_eq_of_lt hlt)
      refine ⟨_, _, .evolveBench hh rfl (by rw [hr.top]; exact he) (hr.fresh.trans hfr) hf hbt hs'
        hat, rfl, ?_⟩
      rw [e]
      simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₂, List.map_append,
        List.map_cons, h1, h3]

/-- Whether the opponent's Active Pokémon's damage rose is read exactly through `rclamp`, when its
damage before is below the cap. -/
theorem GameState.damagedB_of_rclamp {k : Nat} {g₁ g₁' g₂ g₂' : GameState} {d₁ d₂ : InPlay}
    (h1 : g₁.opp.active = some d₁) (h2 : g₂.opp.active = some d₂) (hd : d₂.damage = d₁.damage)
    (hk : d₁.damage < k) (hc : g₁'.rclamp k = g₂'.rclamp k) :
    g₂.damagedB g₂' = g₁.damagedB g₁' := by
  have ha : g₂'.opp.active.map (InPlay.clampWith k (.upto k)) =
      g₁'.opp.active.map (InPlay.clampWith k (.upto k)) :=
    (congrArg (fun g => g.opp.active) hc).symm
  cases e : g₁'.opp.active with
  | none =>
      rw [e] at ha
      have hn := none_of_map ha
      simp only [GameState.damagedB, h1, h2, e, hn]
  | some p =>
      rw [e] at ha
      obtain ⟨q, hq', hq⟩ := agree_of_map ha
      have hdm := hq.damage
      simp only [Cap.dmg] at hdm
      simp only [GameState.damagedB, h1, h2, e, hq']
      apply decide_eq_decide.2
      constructor <;> intro <;> omega

/-- The `damaged` triggers of the opponent's Active Pokémon are read exactly through `rclamp`. -/
theorem GameState.optTrigs_of_rclamp {k : Nat} {g₁' g₂' : GameState}
    (hc : g₁'.rclamp k = g₂'.rclamp k) :
    optTrigs .damaged g₂'.opp.active = optTrigs .damaged g₁'.opp.active := by
  have ha : g₂'.opp.active.map (InPlay.clampWith k (.upto k)) =
      g₁'.opp.active.map (InPlay.clampWith k (.upto k)) :=
    (congrArg (fun g => g.opp.active) hc).symm
  cases e : g₁'.opp.active with
  | none =>
      rw [e] at ha
      simp only [none_of_map ha]
  | some p =>
      rw [e] at ha
      obtain ⟨q, hq', hq⟩ := agree_of_map ha
      simp only [optTrigs, hq', InPlay.trigs, hq.grants.2]

/-- **Inside an attack's effect, the kernel of `rclamp k` is a simulation for `HitRun`**
(milestone M8b), with the flags kept: `Run.cap_sim` on each step. A damage step whose defender is
below its derived HP is below the cap, so whether the step did damage is read exactly; at or above
its HP the flag is free (`HitRun.hit`). -/
theorem HitRun.cap_sim {k : Nat} (hk0 : 0 < k) {e : Effect} {g₁ g₁' : GameState} {hb sw : Bool}
    (h : HitRun e g₁ g₁' hb sw) :
    e.tame = true → e.tmax < k → g₁.NoReduce → g₁.CapOk k → ∀ {g₂ : GameState},
      g₁.rclamp k = g₂.rclamp k →
      ∃ g₂', HitRun e g₂ g₂' hb sw ∧ g₁'.rclamp k = g₂'.rclamp k := by
  induction h with
  | plain he h =>
      intro ht htm hn hR g₂ hc
      obtain ⟨g₂', r, hc'⟩ := Run.cap_sim hk0 h ht htm hn hR hc
      exact ⟨g₂', .plain he r, hc'⟩
  | @hit e g g' p b he h hp hb =>
      intro ht htm hn hR g₂ hc
      obtain ⟨g₂', r, hc'⟩ := Run.cap_sim hk0 h ht htm hn hR hc
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc (w := .opp) (p := p) hp
      refine ⟨g₂', .hit he r hq (fun hlt => ?_), hc'⟩
      have e1 : g₂.hpOf .opp .active q = g.hpOf .opp .active p :=
        (GameState.sameField_of_clampAt hc).hpOf .opp .active hqa.sv
      have hH : g.hpOf .opp .active p ≤ k := hR.1.below .opp .active p hp
      have hdm := hqa.damage
      simp only [Cap.dmg] at hdm
      have hqp : q.damage = p.damage := by omega
      rw [hb (by omega)]
      exact (GameState.damagedB_of_rclamp hp hq hqp (by omega) hc').symm
  | gust h =>
      intro ht htm hn hR g₂ hc
      obtain ⟨g₂', r, hc'⟩ := Run.cap_sim hk0 h ht htm hn hR hc
      have hl := congrArg (fun g => (g.opp.bench).length) hc
      simp only [GameState.rclamp, GameState.clampAt, List.length_map] at hl
      exact ⟨g₂', hl ▸ .gust r, hc'⟩
  | iteT h ht' _ ih =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih ht.1 (by omega) hn hR hc
      exact ⟨g₂', .iteT hq (by rw [Test.eval_agree _ (GameState.count_of_clampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | iteF h ht' _ ih =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih ht.2 (by omega) hn hR hc
      exact ⟨g₂', .iteF hq (by rw [Test.eval_agree _ (GameState.count_of_clampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | seq h₁ _ ih₁ ih₂ =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ ht.1 (by omega) hn hR hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ ht.2 (by omega) (h₁.run.noReduce ht.1 hn)
        (hR.of_perm h₁.run.perm) hc'
      exact ⟨g₂'', .seq r₁ r₂, hc''⟩
  | choiceL _ ih =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih ht.1 (by omega) hn hR hc
      exact ⟨g₂', .choiceL r, hc'⟩
  | choiceR _ ih =>
      intro ht hb hn hR g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih ht.2 (by omega) hn hR hc
      exact ⟨g₂', .choiceR r, hc'⟩
  | iterNil a g => intro _ _ _ _ g₂ hc; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons h₁ _ ih₁ ih₂ =>
      intro ht hb hn hR g₂ hc
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ ht hb hn hR hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ ht hb (h₁.run.noReduce ht hn) (hR.of_perm h₁.run.perm) hc'
      exact ⟨g₂'', .iterCons r₁ r₂, hc''⟩

/-- **Which `damaged` triggers an attack fires is the same under the clamp** (milestone M8b): the
resolution it rests on (`HitRun`) is matched, flags included, and the Abilities of the opponent's
Active Pokémon at the end are kept. -/
theorem HitTrig.clamp_sim {k : Nat} (hk0 : 0 < k) {atk : Attack} {g₁ g₁' : GameState}
    {l : List Ability} (h : HitTrig atk g₁ g₁' l) (ht : atk.script.tame = true)
    (hb : atk.script.tmax < k) (hn : g₁.NoReduce) (hR : g₁.CapOk k) {g₂ : GameState}
    (hc : g₁.rclamp k = g₂.rclamp k) :
    ∃ g₂', HitTrig atk g₂ g₂' l ∧ g₁'.rclamp k = g₂'.rclamp k := by
  cases h with
  | quiet hq =>
      obtain ⟨g₂', r, hc'⟩ := hq.cap_sim hk0 ht hb hn hR hc
      exact ⟨g₂', .quiet r, hc'⟩
  | fire hf hl =>
      obtain ⟨g₂', r, hc'⟩ := hf.cap_sim hk0 ht hb hn hR hc
      exact ⟨g₂', .fire r ((GameState.optTrigs_of_rclamp hc') ▸ hl), hc'⟩

theorem Move.noReduce {g g' : GameState} (h : Move g g')
    (ht : ∀ x ∈ g.allCards, x.tame = true) (hn : g.NoReduce) : g'.NoReduce := by
  cases h with
  | @item g' l₁ l₂ n e hh hbt hst hr =>
      have hx : Card.trainer n .item e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      exact hr.noReduce (ht _ (GameState.mem_allCards_of_hand hx)) hn
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr =>
      have hx : Card.trainer n .supporter e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      exact hr.noReduce (ht _ (GameState.mem_allCards_of_hand hx)) hn
  | @stadiumUse g' o n e ss hs _ _ _ _ hr =>
      exact hr.noReduce (ht _ (GameState.mem_allCards_of_stadium hs)) hn
  | @attack g' a atk ha hm hc hs hn' hf hbt hst hr _ _ _ _ _ _ ht' =>
      obtain ⟨c, hc, hmc⟩ := InPlay.attack_mem hm
      have h2 := (Card.attack_tame (ht _ (GameState.mem_allCards_of_cur_active ha hc)) hmc).1
      exact ht'.zoneOnly.noReduce (hr.noReduce (by rw [Attack.script_tame]; exact h2) hn)
  | @ability g₁ g' x sp ab hu hm _ _ _ _ _ _ _ hr =>
      obtain ⟨c, hc, hmc⟩ := InPlay.ability_mem hm
      exact hr.noReduce (Card.ability_tame (ht _ (hu.card_mem hc)) hmc _ (ab.script_mem _))
        (by cases hu <;> exact hn)
  | @onPlay g₁ g' x how w ab hp hm _ _ _ _ hr =>
      have h1 := ht _ hp.top_mem
      simp only [Card.tame, Bool.and_eq_true] at h1
      exact hr.noReduce (abilitiesTame_mem h1.2 hm _ (ab.script_mem _)) (by cases hp <;> exact hn)
  | endTurn => exact ⟨hn.2.shift, hn.1.shift⟩
  | knockOuts h _ ht' => exact ht'.zoneOnly.noReduce (h.noReduce hn)
  | trigger _ _ _ ht' => exact ht'.zoneOnly.noReduce hn
  | _ => exact hn

/-- Play preserves `Fit k`: the cards are permuted, and no stored damage reduction comes into
effect. -/
theorem Move.fit {k : Nat} {g g' : GameState} (h : Move g g') (hF : g.Fit k) : g'.Fit k :=
  ⟨hF.1, hF.2.1.of_perm h.perm, fun x hx => hF.2.2.1 x (h.perm.mem_iff.1 hx),
    h.noReduce (fun x hx => (hF.2.2.1 x hx).1) hF.2.2.2.1, hF.2.2.2.2.of_perm h.perm⟩

theorem Reach.fit {k : Nat} {g₀ g : GameState} (h : Reach g₀ g) (hF : g₀.Fit k) : g.Fit k := by
  induction h with
  | refl => exact hF
  | step _ _ hm ih => exact hm.fit ih

theorem optCardList_of_map {c : Cap} {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith K c) = o₁.map (InPlay.clampWith K c)) :
    optCardList o₂ = optCardList o₁ := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [optCardList, hq.cardList]

/-- `Fit k` transfers along equal clamps. -/
theorem GameState.Fit.of_clamp {k : Nat} {g₁ g₂ : GameState} (hF : g₁.Fit k)
    (hc : g₁.clamp k = g₂.clamp k) : g₂.Fit k := by
  obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
  have hcards : ({ g₁ with
      cur := { g₁.cur with active := c₂, bench := e₁, mods := m₁ },
      opp := { g₁.opp with active := a₂, bench := e₂, mods := m₂ } } : GameState).allCards.Perm
        g₁.allCards := by
    have f₁ := optCardList_of_map hc₂
    have f₂ := optCardList_of_map ha₂
    simp only [GameState.allCards, PlayerState.allCards, f₁, f₂, benchCardList_of_map he₁,
      benchCardList_of_map he₂]
    exact .refl _
  exact ⟨hF.1, hF.2.1.of_perm hcards, fun x hx => hF.2.2.1 x (hcards.mem_iff.1 hx),
    ⟨Store.NoReduce.of_cap (by have := hF.1; omega) hm₁ hF.2.2.2.1.1,
      Store.NoReduce.of_cap (by have := hF.1; omega) hm₂ hF.2.2.2.1.2⟩,
    hF.2.2.2.2.of_perm hcards⟩

/-- **The kernel of `clamp k` is a bisimulation for `Move`**, for a state that is `Fit k`: if
`g₁` and `g₂` have the same clamp, every move from `g₁` is matched by a move from `g₂` to a state
with the same clamp. (`Fit k` transfers to `g₂`, `GameState.Fit.of_clamp`, so this gives both
directions.) -/
theorem Move.clamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} (hF : g₁.Fit k) (h : Move g₁ g₁')
    (hc : g₁.clamp k = g₂.clamp k) : ∃ g₂', Move g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  have hH : g₁.HpBelow k := hF.2.1.below
  have hcap : g₁.CapOk k := ⟨hF.2.1, hF.2.2.2.2⟩
  have hsf := GameState.sameField_of_clampAt hc
  have hk₂ := fun hk => GameState.damageBounded_of_clamp hc hk hH
  have hs₂ := fun hs => GameState.settled_of_clamp hc hs hH
  obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, hg, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
  have hfl := Store.flags_of_cap hm₁
  cases h with
  | @trigger _ l hcl hp hl ht =>
      have hcl₂ := GameState.bothActive_of_clampAt hc hcl
      have hp₂ : g₂.pend = true := (GameState.pend_of_clampAt hc).trans hp
      have hT := GameState.benchedTrigs_of_clampAt hc
      have hc₀ : ({ g₁ with pend := false } : GameState).clamp k =
          ({ g₂ with pend := false } : GameState).clamp k :=
        congrArg (fun g : GameState => { g with pend := false }) hc
      obtain ⟨g₂', ht₂, hc'⟩ := ht.clamp_sim hc₀
      exact ⟨g₂', .trigger hcl₂ hp₂ (by rw [hT]; exact hl) ht₂, hc'⟩
  | playBasic hh hs hhp hb hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, .playBasic hh hs hhp (by rw [length_of_map he₁]; exact hb) hbt hs' hat, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂,
          List.map_append]⟩
  | @attach l₁ l₂ t a hh hf ha hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have key := hq.clamp_map (c' := .hp) (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
        (fun x => { x with energy := Card.energy t :: x.energy }) (fun _ => rfl) rfl rfl
      exact ⟨_, .attach hh hf rfl hbt hs' hat, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂, key, he₁, he₂]⟩
  | @evolve l₁ l₂ p a hh ha he hfr hf hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
      refine ⟨_, .evolve hh rfl (by rw [hq.top]; exact he) (hq.fresh.trans hfr) hf hbt hs' hat, ?_⟩
      rw [e]
      simp only [GameState.clamp, GameState.clampAt, ha₂, hm₁, hm₂, he₁, he₂]
  | @attachBench l₁ l₂ t q b₁ b₂ hh hf hb hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      exact ⟨_, .attachBench hh hf rfl hbt hs' hat, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₂, List.map_append, List.map_cons, h1, h3,
          hr.energy, InPlay.clamp_of_agree (hr.upd.1 (Card.energy t :: q.energy))]⟩
  | @evolveBench l₁ l₂ p q b₁ b₂ hh hb he hfr hf hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      have hlt : q.damage < k := hst.1.lt_bound hH (w := .own) (sp := .bench)
        (show q ∈ g₁.cur.bench by rw [hb]; exact List.mem_append_right _ (.head _))
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      have e := hr.eq_upd (hr.damage_eq_of_lt hlt)
      refine ⟨_, .evolveBench hh rfl (by rw [hr.top]; exact he) (hr.fresh.trans hfr) hf hbt hs'
        hat, ?_⟩
      rw [e]
      simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₂, List.map_append, List.map_cons, h1, h3]
  | @retreat a q' b₁ b₂ paid rest ha hb hr he hp hs hbt hst hl hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      refine ⟨_, .retreat rfl rfl hr (hq.energy ▸ he) (by rw [hsf.retreatOf hq.sv]; exact hp)
        (by rw [hq.rot]; exact hs) hbt hs' (by rw [hfl.2.2.1]; exact hl) hat, ?_⟩
      rw [e]
      refine GameState.noteBenched_clampAt ?_
      simp only [GameState.clampAt, ha₂, hm₁, hm₂, he₂, Option.map_some,
        List.map_append, List.map_cons, InPlay.clampWith_moveUp, h1, h2, h3]
  | @item g' l₁ l₂ n e hh hbt hst hr hl hat hnd hbh =>
      have hs' := hs₂ hst
      obtain ⟨ht, hb⟩ := hF.trainer hh
      have hp : ({ g₁ with cur := { g₁.cur with
          hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g₁.cur.discard } } :
          GameState).allCards.Perm g₁.allCards := by perm_count [hh]
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim hF.1 ht hb hF.2.2.2.1 (hcap.of_perm hp)
        (g₂ := { g₂ with cur := { g₂.cur with
          hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂])
        (.inl (hst.congr rfl rfl rfl rfl rfl rfl rfl))
      exact ⟨g₂', .item (by subst hg; exact hh) (by subst hg; exact hbt) hs' hr'
        (by subst hg; rw [hfl.2.2.2]; exact hl) (by subst hg; exact hat) hnd hbh, hc'⟩
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr hat hf hnd hbh =>
      have hs' := hs₂ hst
      obtain ⟨ht, hb⟩ := hF.trainer hh
      have hp : ({ g₁ with cur := { g₁.cur with
          hand := l₁ ++ l₂, supporterPlayed := true,
          discard := Card.trainer n .supporter e :: g₁.cur.discard } } :
          GameState).allCards.Perm g₁.allCards := by perm_count [hh]
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim hF.1 ht hb hF.2.2.2.1 (hcap.of_perm hp)
        (g₂ := { g₂ with cur := { g₂.cur with
          hand := l₁ ++ l₂, supporterPlayed := true,
          discard := Card.trainer n .supporter e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂])
        (.inl (hst.congr rfl rfl rfl rfl rfl rfl rfl))
      exact ⟨g₂', .supporter (by subst hg; exact hh) (by subst hg; exact hs)
        (by subst hg; exact hbt) hs' hr' (by subst hg; exact hat) (by subst hg; exact hf) hnd hbh, hc'⟩
  | @stadium l₁ l₂ n e ss hh hs hn hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, .stadium hh hs hn hbt hs' hat, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂]⟩
  | @stadiumUse g' o n e ss hs hu hbt hst hat hr hnd hbh =>
      have hs' := hs₂ hst
      obtain ⟨ht, hb⟩ := hF.2.2.1 _ (GameState.mem_allCards_of_stadium hs)
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim hF.1 ht hb hF.2.2.2.1 hcap
        (g₂ := { g₂ with stadiumUsed := true })
        (by subst hg; simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂])
        (.inl (hst.congr rfl rfl rfl rfl rfl rfl rfl))
      exact ⟨g₂', .stadiumUse (by subst hg; exact hs) (by subst hg; exact hu)
        (by subst hg; exact hbt) hs' (by subst hg; exact hat) hr' hnd hbh, hc'⟩
  | @tool l₁ l₂ n gr a hh ha ht hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have key := hq.clamp_map (c' := .hp) (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
        (fun x => { x with tools := [Card.tool n gr] }) (fun _ => rfl) rfl rfl
      exact ⟨_, .tool hh rfl (hq.tools.trans ht) hbt hs' hat, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂, key, he₁,
          he₂]⟩
  | @toolBench l₁ l₂ n gr q b₁ b₂ hh hb ht hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      exact ⟨_, .toolBench hh rfl (hr.tools.trans ht) hbt hs' hat, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₂, List.map_append,
          List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.setTools [Card.tool n gr])]⟩
  | @ability g₁m g' x sp ab hu hm hk hsp hn hcd hbt hst hat hr hnd hbh =>
      have hs' := hs₂ hst
      obtain ⟨ht, hb⟩ := hF.ability hu hm
      have hcd' := hcd.of_clamp hc hst.1 hb hH
      obtain ⟨x', g₂m, hu', hxt, hxu, hxa, hcm⟩ := hu.clamp_sim hc
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim hF.1 (ht _ (ab.script_mem _))
        (Nat.lt_of_le_of_lt (ab.script_tmax_le _) hb)
        (by cases hu <;> exact hF.2.2.2.1) (hcap.of_perm hu.perm) hcm (.inl (hu.settled hst))
      exact ⟨g₂', .ability hu' (hxa ▸ hm) hk hsp (hxu ▸ hn) hcd' (by subst hg; exact hbt) hs'
        (by subst hg; exact hat) hr' hnd hbh, hc'⟩
  | @onPlay g₁m g' x how w ab hp hm hk hw hst₁ hcd hr hnd hbh =>
      obtain ⟨ht, hb⟩ := hF.ability_of_mem hp.top_mem hm
      obtain ⟨x', g₂m, hp', hxt, hcm⟩ := hp.clamp_sim hc hH
      have hH₁ : g₁m.HpBelow k := (hF.2.1.of_perm hp.perm).below
      have hst₂ := GameState.settled_of_clamp hcm hst₁ hH₁
      have hcd' := hcd.of_clamp hcm hst₁.1 hb hH₁
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim hF.1 (ht _ (ab.script_mem _))
        (Nat.lt_of_le_of_lt (ab.script_tmax_le _) hb)
        (by cases hp <;> exact hF.2.2.2.1) (hcap.of_perm hp.perm) hcm (.inl hst₁)
      exact ⟨g₂', .onPlay hp' (hxt ▸ hm) hk hw hst₂ hcd' hr' hnd hbh, hc'⟩
  | @attack g' a atk ha hm hc' hs hn hf hbt hst hr hl hgx hw l g'' hd ht' hlk =>
      have hs' := hs₂ hst
      obtain ⟨ht, hb⟩ := hF.attack ha hm
      obtain ⟨g₂', hd', hc''⟩ := hd.clamp_sim hF.1 ht hb hF.2.2.2.1 hcap
        (GameState.rclamp_of_clamp hc hst.1 hH)
      have hr' := hd'.run
      obtain ⟨g₂'', ht₂, hc'''⟩ := ht'.clamp_sim (co := .exact) (cp := .upto k) (cbo := .exact)
        (cbp := .upto k) hc''
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      refine ⟨_, .attack rfl (by rw [hq.grants.1]; exact hm) (by unfold InPlay.units; rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) (by exact hn) (by exact hf) (by exact hbt) hs' hr'
        (by rw [hfl.2.1]; exact hl) (by exact hgx) hw hd' ht₂ (by rw [hq.lk]; exact hlk), ?_⟩
      have := congrArg (GameState.afterAttack atk.lockSet atk.gx) hc'''
      rw [← GameState.clampAt_afterAttack, ← GameState.clampAt_afterAttack] at this
      exact GameState.clamp_of_rclamp this
  | attackConfused ha hm hc' hs hn hf hbt hst hl hgx hw hlk =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .attackConfused rfl (by rw [hq.grants.1]; exact hm) (by unfold InPlay.units; rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hs' (by rw [hfl.2.1]; exact hl) hgx hw (by rw [hq.lk]; exact hlk), by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.1 3), he₁, he₂]⟩
  | @knockOuts g₁m g' l h hl ht =>
      obtain ⟨g₂m, h₂, e⟩ := h.clamp_sim hc hH
      have hbt : g₁.batchTrigs g₁m = g₂.batchTrigs g₂m := by
        have hat : g₁.attacked = g₂.attacked := congrArg (fun g => g.attacked) hc
        simp only [GameState.batchTrigs, hat, GameState.winner_of_clamp e,
          GameState.koTrigs_of_clamp hc hH (GameState.hpBelow_of_clamp hc hH)]
      obtain ⟨g₂', ht₂, e'⟩ := ht.clamp_sim (co := .hp) (cp := .hp) (cbo := .hp) (cbp := .hp) e
      exact ⟨g₂', .knockOuts h₂ (hbt ▸ hl) ht₂, e'⟩
  | endTurn fa sa ca fb sb cb ha hb hk hbt hco hcc =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      have h1 := hqa.checkup (hqa.damage_eq_of_lt (hk.lt_bound hH (w := .opp) (sp := .active) ha))
        false fa sa ca
      have h2 := hqb.upd.2.2.2.2.2.checkup
        (hqb.damage_eq_of_lt (hk.lt_bound hH (w := .own) (sp := .active) hb)) true fb sb cb
      have ee₂ := bench_exact_of_hp he₂ fun p hp => hk.lt_bound hH (w := .opp) (sp := .bench) hp
      have ee₁ := bench_map_comm (InPlay.clampWith_unfresh _)
        (bench_exact_of_hp he₁ fun p hp => hk.lt_bound hH (w := .own) (sp := .bench) hp)
      obtain ⟨bo', hbo, ebo⟩ := hco.sim ee₂
      obtain ⟨bc', hbc, ebc⟩ := hcc.sim ee₁
      refine ⟨_, .endTurn fa sa ca fb sb cb rfl rfl hk' hbt hbo hbc, ?_⟩
      simp only [GameState.clamp, GameState.clampAt, PlayerState.unfresh, Option.map_some, hb,
        InPlay.clamp_of_agree h1, InPlay.clamp_of_agree h2, Store.cap_shift hm₁,
        Store.cap_shift hm₂, bench_recap (c := .hp) ebo,
        bench_recap (c := .hp) ebc]
  | startTurn hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      refine ⟨_, .startTurn hbt rfl rfl hk' hd, ?_⟩
      simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha, hb, hm₁, hm₂,
        InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb, he₁, he₂]
  | deckOut hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      exact ⟨_, .deckOut hbt rfl rfl hk' hd, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha, hb, hm₁, hm₂,
          InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb, he₁, he₂]⟩

/-- **The kernel of `clamp k` is a bisimulation for `Reach`**, from a start that is `Fit k`:
from start states with the same clamp, the same clamped states are reachable. -/
theorem Reach.clamp_sim {k : Nat} {g₀ h₀ g₁ : GameState} (hF : g₀.Fit k) (h : Reach g₀ g₁)
    (hc : g₀.clamp k = h₀.clamp k) : ∃ g₂, Reach h₀ g₂ ∧ g₁.clamp k = g₂.clamp k := by
  induction h with
  | refl => exact ⟨h₀, .refl _, hc⟩
  | step hr hw hm ih =>
      obtain ⟨g₂, hr₂, hc'⟩ := ih
      obtain ⟨g₂', hm', hc''⟩ := hm.clamp_sim (hr.fit hF) hc'
      have hw' : g₂.winner = none := by
        have e := congrArg GameState.winner hc'
        exact e.symm.trans hw
      exact ⟨g₂', .step hr₂ hw' hm', hc''⟩

end Pokemon
