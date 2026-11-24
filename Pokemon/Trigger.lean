import Pokemon.Zone

/-!
# Triggers: frame and existence (milestone M8b)

Facts about `Fire`, the resolution of triggered Abilities (`Pokemon/Rules.lean`), that the rest of
the development uses in place of the corresponding facts about `Run`.

* `GameState.ZoneOnly g g'`: `g'` differs from `g` at most in the five zones of each player (deck,
  hand, discard pile, Active Spot, Bench). Every effect of the trigger fragment (`Effect.trigOk`) has
  this frame (`Run.zoneOnly`), the frame is symmetric in the two players
  (`GameState.ZoneOnly.unswap`), and so every trigger resolution has it (`Fire.zoneOnly`): triggers
  change no turn flag, no Prize card, no store, no Stadium and no outcome.
* `Run.exists_of_trigOk`, `Fire.exists`: with both Active Spots filled, every effect of the
  fragment has a resolution, and so has every list of triggers; the trigger moves never get stuck.
-/

namespace Pokemon

/-- Everything of a player but the five zones. -/
def PlayerState.rest (s : PlayerState) :=
  (s.prizes, s.lost, s.energyAttached, s.supporterPlayed, s.retreated, s.gxUsed, s.vstarUsed,
    s.mods, s.hadTurn)

/-- Everything of the game but the players and `curIsFirst` (milestone MV7: with `pend`). -/
def GameState.rest (g : GameState) :=
  (g.firstTurn, g.attacked, g.between, g.winner, g.stadium, g.stadiumPlayed, g.stadiumUsed, g.pend)

/-- `g'` differs from `g` at most in the five zones of each player. -/
structure GameState.ZoneOnly (g g' : GameState) : Prop where
  first : g'.curIsFirst = g.curIsFirst
  rest : g'.rest = g.rest
  cur : g'.cur.rest = g.cur.rest
  opp : g'.opp.rest = g.opp.rest

namespace GameState.ZoneOnly

theorem refl (g : GameState) : GameState.ZoneOnly g g := ⟨rfl, rfl, rfl, rfl⟩

theorem trans {g₁ g₂ g₃ : GameState} (h₁ : GameState.ZoneOnly g₁ g₂)
    (h₂ : GameState.ZoneOnly g₂ g₃) : GameState.ZoneOnly g₁ g₃ :=
  ⟨h₂.first.trans h₁.first, h₂.rest.trans h₁.rest, h₂.cur.trans h₁.cur, h₂.opp.trans h₁.opp⟩

/-- The frame seen from the other side is the frame. -/
theorem unswap {g g₁ : GameState} (h : GameState.ZoneOnly g.swap g₁) :
    GameState.ZoneOnly g g₁.swap := by
  refine ⟨?_, h.rest, h.opp, h.cur⟩
  show (!g₁.curIsFirst) = g.curIsFirst
  rw [h.first]
  show (!!g.curIsFirst) = g.curIsFirst
  rw [Bool.not_not]

variable {g g' : GameState} (h : GameState.ZoneOnly g g')
include h

theorem firstTurn : g'.firstTurn = g.firstTurn := congrArg (·.1) h.rest
theorem attacked : g'.attacked = g.attacked := congrArg (·.2.1) h.rest
theorem between : g'.between = g.between := congrArg (·.2.2.1) h.rest
theorem winner : g'.winner = g.winner := congrArg (·.2.2.2.1) h.rest
theorem stadium : g'.stadium = g.stadium := congrArg (·.2.2.2.2.1) h.rest
theorem stadiumPlayed : g'.stadiumPlayed = g.stadiumPlayed := congrArg (·.2.2.2.2.2.1) h.rest
theorem stadiumUsed : g'.stadiumUsed = g.stadiumUsed := congrArg (·.2.2.2.2.2.2.1) h.rest
theorem pend : g'.pend = g.pend := congrArg (·.2.2.2.2.2.2.2) h.rest
theorem cur_prizes : g'.cur.prizes = g.cur.prizes := congrArg (·.1) h.cur
theorem opp_prizes : g'.opp.prizes = g.opp.prizes := congrArg (·.1) h.opp
theorem cur_lost : g'.cur.lost = g.cur.lost := congrArg (·.2.1) h.cur
theorem opp_lost : g'.opp.lost = g.opp.lost := congrArg (·.2.1) h.opp
theorem cur_energyAttached : g'.cur.energyAttached = g.cur.energyAttached :=
  congrArg (·.2.2.1) h.cur
theorem opp_energyAttached : g'.opp.energyAttached = g.opp.energyAttached :=
  congrArg (·.2.2.1) h.opp
theorem cur_supporterPlayed : g'.cur.supporterPlayed = g.cur.supporterPlayed :=
  congrArg (·.2.2.2.1) h.cur
theorem opp_supporterPlayed : g'.opp.supporterPlayed = g.opp.supporterPlayed :=
  congrArg (·.2.2.2.1) h.opp
theorem cur_retreated : g'.cur.retreated = g.cur.retreated := congrArg (·.2.2.2.2.1) h.cur
theorem opp_retreated : g'.opp.retreated = g.opp.retreated := congrArg (·.2.2.2.2.1) h.opp
theorem cur_gxUsed : g'.cur.gxUsed = g.cur.gxUsed := congrArg (·.2.2.2.2.2.1) h.cur
theorem opp_gxUsed : g'.opp.gxUsed = g.opp.gxUsed := congrArg (·.2.2.2.2.2.1) h.opp
theorem cur_vstarUsed : g'.cur.vstarUsed = g.cur.vstarUsed := congrArg (·.2.2.2.2.2.2.1) h.cur
theorem opp_vstarUsed : g'.opp.vstarUsed = g.opp.vstarUsed := congrArg (·.2.2.2.2.2.2.1) h.opp
theorem cur_mods : g'.cur.mods = g.cur.mods := congrArg (·.2.2.2.2.2.2.2.1) h.cur
theorem opp_mods : g'.opp.mods = g.opp.mods := congrArg (·.2.2.2.2.2.2.2.1) h.opp
theorem cur_hadTurn : g'.cur.hadTurn = g.cur.hadTurn := congrArg (·.2.2.2.2.2.2.2.2) h.cur
theorem opp_hadTurn : g'.opp.hadTurn = g.opp.hadTurn := congrArg (·.2.2.2.2.2.2.2.2) h.opp

end GameState.ZoneOnly

/-- **An effect of the trigger fragment changes only the zones.** -/
theorem Run.zoneOnly {e : Effect} {g g' : GameState} (h : Run e g g') :
    e.trigOk = true → GameState.ZoneOnly g g' := by
  induction h with
  | iteT _ _ _ _ => intro hk; simp [Effect.trigOk] at hk
  | iteF _ _ _ _ => intro hk; simp [Effect.trigOk] at hk
  | seq _ _ ih₁ ih₂ =>
      intro hk
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      exact (ih₁ hk.1).trans (ih₂ hk.2)
  | choiceL _ ih =>
      intro hk
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      exact ih hk.1
  | choiceR _ ih =>
      intro hk
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      exact ih hk.2
  | iterNil => intro hk; simp [Effect.trigOk] at hk
  | iterCons _ _ _ _ => intro hk; simp [Effect.trigOk] at hk
  | linger => intro hk; simp [Effect.trigOk] at hk
  | discardStadium => intro hk; simp [Effect.trigOk] at hk
  | @touchActive e w f g p he h => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | @touchBench e w f g q b₁ b₂ he h => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | unmark w m g => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | benchCounters w n h => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | benchCountersNone w n h => intro _; exact ⟨rfl, rfl, rfl, rfl⟩
  | spreadCounters w n g => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | benchSome w _ _ _ _ _ => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | switch w ha hb => intro hk; simp [Effect.trigOk] at hk
  | switchNone w hb => intro _; exact ⟨rfl, rfl, rfl, rfl⟩
  | benchDamage w n h => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | benchDamageNone w n h => intro _; exact ⟨rfl, rfl, rfl, rfl⟩
  | spreadDamage w n g => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | @zone e w g s' hw hz => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | _ => intro _; exact ⟨rfl, rfl, rfl, rfl⟩

/-- **A trigger resolution changes only the zones.** -/
theorem Fire.zoneOnly {ev : TrigEvent} {l : List Ability} {g g' : GameState}
    (h : Fire ev l g g') : GameState.ZoneOnly g g' := by
  induction h with
  | nil => exact .refl _
  | run hk hr _ ih => exact (hr.zoneOnly hk).unswap.trans ih
  | decline _ _ ih => exact ih

/-! ## Existence -/

/-- Take nothing. -/
theorem Split.keepAll (f : Filter) : ∀ l : List Card, Split f l [] l
  | [] => .nil
  | _ :: l => .keep (Split.keepAll f l)

/-- Take every card that passes the filter. -/
theorem Split.takeAll (f : Filter) :
    ∀ l : List Card, ∃ t r, Split f l t r ∧ ∀ x ∈ r, f.eval x = false
  | [] => ⟨[], [], .nil, fun _ h => nomatch h⟩
  | x :: l => by
      obtain ⟨t, r, hs, hr⟩ := Split.takeAll f l
      cases hx : f.eval x with
      | true => exact ⟨x :: t, r, .take hx hs, hr⟩
      | false =>
          refine ⟨t, x :: r, .keep hs, fun y hy => ?_⟩
          cases hy with
          | head => exact hx
          | tail _ hy => exact hr y hy

/-- Take the first `n` cards that pass the filter, or all of them if fewer pass (milestone MV6,
`Qty.most`). -/
theorem Split.takeMost (f : Filter) : ∀ (n : Nat) (l : List Card),
    ∃ t r, Split f l t r ∧ t.length ≤ n ∧ (t.length < n → ∀ x ∈ r, f.eval x = false)
  | _, [] => ⟨[], [], .nil, Nat.zero_le _, fun _ _ h => nomatch h⟩
  | 0, l => ⟨[], l, Split.keepAll f l, Nat.le_refl _, fun h => absurd h (Nat.not_lt_zero _)⟩
  | n + 1, x :: l => by
      cases hx : f.eval x with
      | true =>
          obtain ⟨t, r, hs, h1, h2⟩ := Split.takeMost f n l
          refine ⟨x :: t, r, .take hx hs, by simp only [List.length_cons]; omega, fun h => h2 ?_⟩
          simp only [List.length_cons] at h; omega
      | false =>
          obtain ⟨t, r, hs, h1, h2⟩ := Split.takeMost f (n + 1) l
          refine ⟨t, x :: r, .keep hs, h1, fun h y hy => ?_⟩
          cases hy with
          | head => exact hx
          | tail _ hy => exact h2 h y hy

/-- A quantity that cannot fail can always be taken. -/
theorem Qty.exists_ok {q : Qty} (hq : q.canFail = false) (f : Filter) (l : List Card) :
    ∃ t r, Split f l t r ∧ q.ok f t r := by
  cases q with
  | upTo n => exact ⟨[], l, Split.keepAll f l, Nat.zero_le _⟩
  | exactly n => simp [Qty.canFail] at hq
  | all =>
      obtain ⟨t, r, hs, hr⟩ := Split.takeAll f l
      exact ⟨t, r, hs, hr⟩
  | most n =>
      obtain ⟨t, r, hs, h1, h2⟩ := Split.takeMost f n l
      exact ⟨t, r, hs, h1, h2⟩

theorem Put.exists (d : Dst) (t : List Card) (s : PlayerState) : ∃ s', Put d t s s' := by
  cases d with
  | hand => exact ⟨_, .hand t s⟩
  | discard => exact ⟨_, .discard t s⟩
  | top => exact ⟨_, .top s (List.Perm.refl t)⟩
  | bottom => exact ⟨_, .bottom s (List.Perm.refl t)⟩
  | shuffle => exact ⟨_, .shuffle s (List.Perm.refl _)⟩

theorem isSome_iff' {o : Option InPlay} : o.isSome = true ↔ ∃ p, o = some p := by
  cases o <;> simp

/-- **A zone move of the trigger fragment has a resolution**, which keeps the Active Spot filled. -/
theorem ZStep.exists_of_trigOk {e : Effect} {w : Whose} (hw : e.zSide = some w)
    (hk : e.trigOk = true) {s : PlayerState} (ha : s.active.isSome = true) :
    ∃ s', ZStep e s s' ∧ s'.active.isSome = true := by
  cases e <;> simp only [Effect.zSide, reduceCtorEq] at hw
  case move w' src dst f q =>
    have hq : q.canFail = false := by simpa [Effect.trigOk] using hk
    obtain ⟨t, r, hs, hq'⟩ := Qty.exists_ok hq f (src.get s)
    obtain ⟨s', hp⟩ := Put.exists dst t (src.set r s)
    refine ⟨s', .move hs hq' hp, ?_⟩
    rw [hp.fields.2.1, Src.set_active]
    exact ha
  case drawTo w' n => exact ⟨_, .drawTo w' n s, ha⟩
  case attach w' src f sp tf => exact ⟨_, .attachNone w' src f sp tf s, ha⟩
  case putBench w' src f => exact ⟨_, .putBenchNone w' src f s, ha⟩
  case discardEnergy w' sp f q =>
    have hq : q.canFail = false := by simpa [Effect.trigOk] using hk
    cases sp with
    | active =>
        obtain ⟨a, ha'⟩ := isSome_iff'.1 ha
        obtain ⟨t, r, hs, hq'⟩ := Qty.exists_ok hq f a.energy
        exact ⟨_, .discardActive (w := w') ha' hs hq', rfl⟩
    | bench =>
        cases hb : s.bench with
        | nil => exact ⟨_, .discardNone (w := w') (f := f) (q := q) hb, ha⟩
        | cons p b =>
            obtain ⟨t, r, hs, hq'⟩ := Qty.exists_ok hq f p.energy
            exact ⟨_, .discardBench (w := w') (b₁ := []) (by rw [hb]; rfl) hs hq', ha⟩
  case moveEnergy w' f => exact ⟨_, .moveNone w' f s, ha⟩
  case discardTools w' sp =>
    cases sp with
    | active =>
        obtain ⟨a, ha'⟩ := isSome_iff'.1 ha
        exact ⟨_, .toolsActive (w := w') ha', rfl⟩
    | bench =>
        cases hb : s.bench with
        | nil => exact ⟨_, .toolsNone (w := w') hb, ha⟩
        | cons p b => exact ⟨_, .toolsBench (w := w') (b₁ := []) (by rw [hb]; rfl), ha⟩
  case look => simp [Effect.trigOk] at hk

/-- Both Active Spots are filled. -/
def GameState.BothActive (g : GameState) : Prop :=
  g.cur.active.isSome = true ∧ g.opp.active.isSome = true

theorem GameState.BothActive.swap {g : GameState} (h : g.BothActive) : g.swap.BothActive :=
  ⟨h.2, h.1⟩

theorem Run.exists_zone {e : Effect} {w : Whose} (hw : e.zSide = some w) (hk : e.trigOk = true)
    {g : GameState} (hb : g.BothActive) : ∃ g', Run e g g' ∧ g'.BothActive := by
  obtain ⟨s', hz, hs'⟩ := ZStep.exists_of_trigOk hw hk (s := g.side w)
    (by cases w; exact hb.1; exact hb.2)
  refine ⟨_, .zone hw hz, ?_⟩
  cases w
  · exact ⟨hs', hb.2⟩
  · exact ⟨hb.1, hs'⟩

/-- **Every effect of the trigger fragment has a resolution** when both Active Spots are filled,
and they stay filled. -/
theorem Run.exists_of_trigOk : ∀ {e : Effect}, e.trigOk = true → ∀ {g : GameState},
    g.BothActive → ∃ g', Run e g g' ∧ g'.BothActive
  | .skip, _, g, hb => ⟨g, .skip g, hb⟩
  | .draw, _, g, hb => by
      cases hd : g.cur.deck with
      | nil => exact ⟨g, .drawEmpty hd, hb⟩
      | cons c d => exact ⟨_, .draw hd, hb⟩
  | .counters n, _, g, hb => by
      obtain ⟨p, hp⟩ := isSome_iff'.1 hb.2
      exact ⟨_, .counters n hp, hb.1, rfl⟩
  | .inflict c, _, g, hb => by
      obtain ⟨p, hp⟩ := isSome_iff'.1 hb.2
      exact ⟨_, .inflict c hp, hb.1, rfl⟩
  | .shuffle, _, g, hb => ⟨_, .shuffle (List.Perm.refl _), hb⟩
  | .move .., hk, _, hb => Run.exists_zone rfl hk hb
  | .drawTo .., hk, _, hb => Run.exists_zone rfl hk hb
  | .attach .., hk, _, hb => Run.exists_zone rfl hk hb
  | .putBench .., hk, _, hb => Run.exists_zone rfl hk hb
  | .discardEnergy .., hk, _, hb => Run.exists_zone rfl hk hb
  | .moveEnergy .., hk, _, hb => Run.exists_zone rfl hk hb
  | .discardTools .., hk, _, hb => Run.exists_zone rfl hk hb
  | .seq a b, hk, g, hb => by
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      obtain ⟨g₁, h₁, hb₁⟩ := Run.exists_of_trigOk hk.1 hb
      obtain ⟨g₂, h₂, hb₂⟩ := Run.exists_of_trigOk hk.2 hb₁
      exact ⟨g₂, .seq h₁ h₂, hb₂⟩
  | .choice a b, hk, g, hb => by
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      obtain ⟨g₁, h₁, hb₁⟩ := Run.exists_of_trigOk hk.1 hb
      exact ⟨g₁, .choiceL h₁, hb₁⟩
  | .heal _, hk, _, _ | .poisonUp _, hk, _, _ | .cure, hk, _, _ | .search, hk, _, _
  | .handToBottom, hk, _, _ | .ite .., hk, _, _ | .scale .., hk, _, _ | .selfDamage _, hk, _, _
  | .healAll, hk, _, _ | .mark .., hk, _, _ | .unmark .., hk, _, _ | .color .., hk, _, _
  | .linger .., hk, _, _ | .damage _ _, hk, _, _ | .drain _, hk, _, _
  | .benchCounters .., hk, _, _ | .spreadCounters .., hk, _, _ | .benchHeal _, hk, _, _
  | .switch _, hk, _, _ | .benchDamage .., hk, _, _ | .spreadDamage .., hk, _, _
  | .moveCounter .., hk, _, _ | .discardStadium, hk, _, _ | .iter _, hk, _, _ => by
      simp [Effect.trigOk] at hk

/-- A trigger that fires on `ev` resolves an effect of the fragment. -/
theorem Ability.trigOk_of_trigOn {ev : TrigEvent} {sp : Spot} {ab : Ability}
    (h : ab.trigOn ev sp = true) : (ab.script ev.place).trigOk = true := by
  simp only [Ability.trigOn, Bool.and_eq_true] at h
  exact h.1.2

/-- A trigger that fires on an event that can come before the turn's attack recycles nothing
(milestone MV7). -/
theorem Ability.recFilters_of_trigOn {ev : TrigEvent} {sp : Spot} {ab : Ability}
    (h : ab.trigOn ev sp = true) (hl : ev.late = false) : (ab.script ev.place).recFilters = [] := by
  simp only [Ability.trigOn, Bool.and_eq_true, hl, Bool.false_or, List.isEmpty_iff] at h
  exact h.2

theorem InPlay.recFilters_of_mem_trigs {ev : TrigEvent} {sp : Spot} {p : InPlay} {ab : Ability}
    (h : ab ∈ p.trigs ev sp) (hl : ev.late = false) : (ab.script ev.place).recFilters = [] :=
  Ability.recFilters_of_trigOn (List.mem_filter.1 h).2 hl

theorem InPlay.trigOk_of_mem_trigs {ev : TrigEvent} {sp : Spot} {p : InPlay} {ab : Ability}
    (h : ab ∈ p.trigs ev sp) : (ab.script ev.place).trigOk = true :=
  Ability.trigOk_of_trigOn (List.mem_filter.1 h).2

theorem optTrigs_trigOk {ev : TrigEvent} {o : Option InPlay} {ab : Ability}
    (h : ab ∈ optTrigs ev o) : (ab.script ev.place).trigOk = true := by
  cases o with
  | none => nomatch h
  | some p => exact InPlay.trigOk_of_mem_trigs h

theorem GameState.koTrigs_trigOk {g : GameState} {ab : Ability} (h : ab ∈ g.koTrigs) :
    (ab.script TrigEvent.koByAttack.place).trigOk = true := by
  rcases List.mem_append.1 h with h | h
  · exact optTrigs_trigOk h
  · obtain ⟨p, _, hp⟩ := List.mem_flatMap.1 h
    exact InPlay.trigOk_of_mem_trigs hp

theorem GameState.batchTrigs_trigOk {g g₁ : GameState} {ab : Ability} (h : ab ∈ g.batchTrigs g₁) :
    (ab.script TrigEvent.koByAttack.place).trigOk = true := by
  unfold GameState.batchTrigs at h
  split at h
  · exact GameState.koTrigs_trigOk h
  · nomatch h

theorem GameState.benchedTrigs_trigOk {g : GameState} {ab : Ability} (h : ab ∈ g.benchedTrigs) :
    (ab.script TrigEvent.oppBenched.place).trigOk = true := by
  rcases List.mem_append.1 h with h | h
  · cases ha : g.opp.active with
    | none => rw [ha] at h; nomatch h
    | some p => rw [ha] at h; exact InPlay.trigOk_of_mem_trigs h
  · obtain ⟨p, _, hp⟩ := List.mem_flatMap.1 h
    exact InPlay.trigOk_of_mem_trigs hp

/-- **An `oppBenched` trigger recycles nothing** (milestone MV7): it fires before the turn's attack,
so `Ability.trigOn` admits only effects with no zone move out of a discard pile. -/
theorem GameState.benchedTrigs_recFilters {g : GameState} {ab : Ability} (h : ab ∈ g.benchedTrigs) :
    (ab.script TrigEvent.oppBenched.place).recFilters = [] := by
  rcases List.mem_append.1 h with h | h
  · cases ha : g.opp.active with
    | none => rw [ha] at h; nomatch h
    | some p => rw [ha] at h; exact InPlay.recFilters_of_mem_trigs h rfl
  · obtain ⟨p, _, hp⟩ := List.mem_flatMap.1 h
    exact InPlay.recFilters_of_mem_trigs hp rfl

/-- **Every list of triggers of the fragment can be resolved** when both Active Spots are filled
(every trigger resolving). -/
theorem Fire.exists {ev : TrigEvent} : ∀ {l : List Ability},
    (∀ ab ∈ l, (ab.script ev.place).trigOk = true) → ∀ {g : GameState}, g.BothActive →
      ∃ g', Fire ev l g g'
  | [], _, g, _ => ⟨g, .nil g⟩
  | ab :: l, hl, g, hb => by
      obtain ⟨g₁, hr, hb₁⟩ := Run.exists_of_trigOk (hl ab (.head _)) hb.swap
      obtain ⟨g₂, ht⟩ := Fire.exists (fun x hx => hl x (.tail _ hx)) (g := g₁.swap) hb₁.swap
      exact ⟨g₂, .run (hl ab (.head _)) hr ht⟩

/-- A `Calm` state has both Active Spots filled. -/
theorem Calm.bothActive {g : GameState} (h : Calm g) : g.BothActive :=
  ⟨Option.isSome_iff_ne_none.2 h.2.1, Option.isSome_iff_ne_none.2 h.2.2⟩

/-- **Pending triggers can always be resolved** (milestone MV7): from a `Calm` state, the opponent's
`oppBenched` triggers have a resolution (every one resolving) on the state with the record cleared. -/
theorem Calm.trigs_exist {g : GameState} (h : Calm g) :
    ∃ g', Fire .oppBenched g.benchedTrigs { g with pend := false } g' :=
  Fire.exists (fun _ hab => GameState.benchedTrigs_trigOk hab) (g := { g with pend := false })
    h.bothActive

end Pokemon
