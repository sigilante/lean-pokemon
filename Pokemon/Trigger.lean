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
    s.mods, s.hadTurn, s.supCard)

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
theorem cur_hadTurn : g'.cur.hadTurn = g.cur.hadTurn := congrArg (·.2.2.2.2.2.2.2.2.1) h.cur
theorem opp_hadTurn : g'.opp.hadTurn = g.opp.hadTurn := congrArg (·.2.2.2.2.2.2.2.2.1) h.opp
/-- (milestone MV9) the Supporter record is in the frame -/
theorem cur_supCard : g'.cur.supCard = g.cur.supCard := congrArg (·.2.2.2.2.2.2.2.2.2) h.cur
theorem opp_supCard : g'.opp.supCard = g.opp.supCard := congrArg (·.2.2.2.2.2.2.2.2.2) h.opp

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
  | hitByActive w _ _ _ _ _ _ _ => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | hitByBench w _ _ _ _ _ _ => intro _; cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
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
  | vacant _ _ _ _ ih => exact ih

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

/-! ### Energy discards by what the cards provide (milestone MV8) -/

/-- A split can take any sub-list of what it takes, the rest kept. -/
theorem Split.of_sublist {f : Filter} {l t r : List Card} (h : Split f l t r) :
    ∀ {t' : List Card}, t'.Sublist t → ∃ r', Split f l t' r' := by
  induction h with
  | nil =>
      intro t' hs
      rw [List.sublist_nil.1 hs]
      exact ⟨[], .nil⟩
  | @take x l t r hx _ ih =>
      intro t' hs
      cases hs with
      | cons _ hs =>
          obtain ⟨r', h'⟩ := ih hs
          exact ⟨x :: r', .keep h'⟩
      | cons_cons _ hs =>
          obtain ⟨r', h'⟩ := ih hs
          exact ⟨r', .take hx h'⟩
  | @keep x l t r _ ih =>
      intro t' hs
      obtain ⟨r', h'⟩ := ih hs
      exact ⟨x :: r', .keep h'⟩

/-- A split shares out the weights. -/
theorem Split.sum_map {f : Filter} {l t r : List Card} (h : Split f l t r) (w : Card → Nat) :
    (l.map w).sum = (t.map w).sum + (r.map w).sum := by
  induction h with
  | nil => rfl
  | take _ _ ih => simp only [List.map_cons, List.sum_cons, ih]; omega
  | keep _ ih => simp only [List.map_cons, List.sum_cons, ih]; omega

theorem sum_map_erase {w : Card → Nat} {x : Card} : ∀ {t : List Card}, x ∈ t →
    ((t.erase x).map w).sum + w x = (t.map w).sum ∧ (t.erase x).length + 1 = t.length
  | y :: t, hx => by
      rw [List.erase_cons]
      cases h : (y == x) with
      | true =>
          have := eq_of_beq h; subst this
          simp only [ite_true, List.map_cons, List.sum_cons, List.length_cons]
          exact ⟨Nat.add_comm _ _, trivial⟩
      | false =>
          have hne : y ≠ x := fun e => by subst e; simp at h
          have hx' : x ∈ t := by
            cases hx with
            | head => exact absurd rfl hne
            | tail _ h => exact h
          simp only [Bool.false_eq_true, ite_false, List.map_cons, List.sum_cons, List.length_cons]
          obtain ⟨h1, h2⟩ := sum_map_erase (w := w) hx'
          exact ⟨by rw [Nat.add_assoc, h1], by rw [h2]⟩

theorem all_false {p : Nat → Bool} : ∀ {l : List Nat}, l.all p = false → ∃ u ∈ l, p u = false
  | [], h => nomatch h
  | u :: l, h => by
      rw [List.all_cons] at h
      cases hu : p u with
      | false => exact ⟨u, .head _, hu⟩
      | true =>
          rw [hu, Bool.true_and] at h
          obtain ⟨v, hv, hp⟩ := all_false h
          exact ⟨v, .tail _ hv, hp⟩

/-- **Cards that provide at least `n` hold a payment of `n` with no card superfluous** (milestone
MV8): drop superfluous cards one at a time. -/
theorem exists_paid_sublist (w : Card → Nat) (n : Nat) :
    ∀ (t : List Card), n ≤ (t.map w).sum →
      ∃ t' : List Card, t'.Sublist t ∧ retreatPaid n (t'.map w) = true
  | t, h => by
    cases hp : retreatPaid n (t.map w) with
    | true => exact ⟨t, List.Sublist.refl t, hp⟩
    | false =>
        unfold retreatPaid at hp
        rw [Nat.ble_eq_true_of_le h, Bool.true_and] at hp
        obtain ⟨u, hu, hn⟩ := all_false hp
        obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hu
        have hn' : n ≤ (t.map w).sum - w x := by
          apply Nat.le_of_not_lt
          intro hlt
          rw [(Nat.blt_eq ▸ hlt : Nat.blt _ _ = true)] at hn
          exact Bool.noConfusion hn
        obtain ⟨hs, hl⟩ := sum_map_erase (w := w) hx
        have hlen : (t.erase x).length < t.length := by rw [← hl]; exact Nat.lt_succ_self _
        have hle : n ≤ ((t.erase x).map w).sum := by
          clear hp hu hn hlen
          omega
        obtain ⟨t', h1, h2⟩ := exists_paid_sublist w n (t.erase x) hle
        exact ⟨t', h1.trans List.erase_sublist, h2⟩
  termination_by t => t.length

/-- **An Energy discard of `n` is possible exactly when the cards passing the filter provide at
least `n`** (milestone MV8), the cards failing the filter weighing nothing. -/
theorem Split.exists_paid {f : Filter} {w : Card → Nat} (hw : ∀ x, f.eval x = false → w x = 0)
    {l : List Card} {n : Nat} (h : n ≤ (l.map w).sum) :
    ∃ t r, Split f l t r ∧ retreatPaid n (t.map w) = true := by
  obtain ⟨t, r, hs, hr⟩ := Split.takeAll f l
  have h0 : (r.map w).sum = 0 := by
    have : ∀ x ∈ r, w x = 0 := fun x hx => hw x (hr x hx)
    clear hs hr h
    induction r with
    | nil => rfl
    | cons y r ih =>
        rw [List.map_cons, List.sum_cons, this y (.head _), ih fun z hz => this z (.tail _ hz)]
  have hsum := hs.sum_map w
  obtain ⟨t', h1, h2⟩ := exists_paid_sublist w n t (by omega)
  obtain ⟨r', h3⟩ := hs.of_sublist h1
  exact ⟨t', r', h3, h2⟩

/-- An Energy discard that cannot fail has a resolution (milestone MV8, `Qty.okE`). -/
theorem Qty.exists_okE {q : Qty} (hq : q.canFail = false) {f : Filter} {w : Card → Nat}
    (l : List Card) :
    ∃ t r, Split f l t r ∧ q.okE w f t r := by
  cases q with
  | upTo n => exact ⟨[], l, Split.keepAll f l, 0, Nat.zero_le _, rfl⟩
  | exactly n => simp [Qty.canFail] at hq
  | all =>
      obtain ⟨t, r, hs, hr⟩ := Split.takeAll f l
      exact ⟨t, r, hs, hr⟩
  | most n =>
      obtain ⟨t, r, hs, hr⟩ := Split.takeAll f l
      cases Nat.lt_or_ge ((t.map w).sum) n with
      | inl hlt => exact ⟨t, r, hs, .inr ⟨hlt, hr⟩⟩
      | inr hge =>
          obtain ⟨t', h1, h2⟩ := exists_paid_sublist w n t hge
          obtain ⟨r', h3⟩ := hs.of_sublist h1
          exact ⟨t', r', h3, .inl h2⟩

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
        obtain ⟨t, r, hs, hq'⟩ := Qty.exists_okE hq a.energy
        exact ⟨_, .discardActive (w := w') ha' hs hq', rfl⟩
    | bench =>
        cases hb : s.bench with
        | nil => exact ⟨_, .discardNone (w := w') (f := f) (q := q) hb, ha⟩
        | cons p b =>
            obtain ⟨t, r, hs, hq'⟩ :=
              Qty.exists_okE hq p.energy
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
  case returnEnergy => simp [Effect.trigOk] at hk
  case shiftEnergy => simp [Effect.trigOk] at hk
  case returnPokemon => simp [Effect.trigOk] at hk

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
  | .moveCounter .., hk, _, _ | .discardStadium, hk, _, _ | .iter _, hk, _, _
  | .returnEnergy .., hk, _, _ | .shiftEnergy .., hk, _, _ | .returnPokemon .., hk, _, _ => by
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

/-- An owed trigger (milestone MV7b) is an `oppBenched` trigger of a Pokémon at some spot. -/
theorem GameState.mem_owedTrigs {g : GameState} {ab : Ability} (h : ab ∈ g.owedTrigs) :
    ∃ (p : InPlay) (sp : Spot), ab ∈ p.trigs .oppBenched sp := by
  have hp : ∀ p : InPlay, ab ∈ p.owed → ∃ (q : InPlay) (sp : Spot), ab ∈ q.trigs .oppBenched sp :=
    fun p hp => by
    unfold InPlay.owed at hp
    split at hp
    · nomatch hp
    · exact ⟨p, _, hp⟩
  rcases List.mem_append.1 h with h | h
  · cases ha : g.opp.active with
    | none => rw [ha] at h; nomatch h
    | some p => rw [ha] at h; exact hp p h
  · obtain ⟨p, _, h'⟩ := List.mem_flatMap.1 h
    exact hp p h'

theorem GameState.owedTrigs_trigOk {g : GameState} {ab : Ability} (h : ab ∈ g.owedTrigs) :
    (ab.script TrigEvent.oppBenched.place).trigOk = true := by
  obtain ⟨_, _, h⟩ := GameState.mem_owedTrigs h
  exact InPlay.trigOk_of_mem_trigs h

/-- **An owed trigger recycles nothing** (milestone MV7b), as every `oppBenched` trigger. -/
theorem GameState.owedTrigs_recFilters {g : GameState} {ab : Ability} (h : ab ∈ g.owedTrigs) :
    (ab.script TrigEvent.oppBenched.place).recFilters = [] := by
  obtain ⟨_, _, h⟩ := GameState.mem_owedTrigs h
  exact InPlay.recFilters_of_mem_trigs h rfl

/-- Clearing the record keeps both Active Spots filled. -/
theorem GameState.BothActive.unpend {g : GameState} (h : g.BothActive) : g.unpend.BothActive := by
  refine ⟨?_, ?_⟩
  · show (g.cur.active.map InPlay.clearOwe).isSome = true
    rw [Option.isSome_map]; exact h.1
  · show (g.opp.active.map InPlay.clearOwe).isSome = true
    rw [Option.isSome_map]; exact h.2

/-! ## The player to move's own triggers (milestone MV7c) -/

/-- The frame, both states exchanged. -/
theorem GameState.ZoneOnly.swap {g g' : GameState} (h : GameState.ZoneOnly g g') :
    GameState.ZoneOnly g.swap g'.swap := by
  refine ⟨?_, h.rest, h.opp, h.cur⟩
  show (!g'.curIsFirst) = !g.curIsFirst
  rw [h.first]

/-- **The player to move's own triggers change only the zones.** -/
theorem FireMine.zoneOnly {u d : List Ability} {g g' : GameState} (h : FireMine u d g g') :
    GameState.ZoneOnly g g' := by
  obtain ⟨g₁, g₂, h₁, h₂, rfl⟩ := h
  exact (h₁.zoneOnly.trans h₂.zoneOnly).unswap

/-- **The resolution of the owed triggers changes only the zones** of the state with the record and
the marks cleared (milestone MV7c). -/
theorem Owed.zoneOnly {g g' : GameState} (h : Owed g g') : GameState.ZoneOnly g.unpend g' := by
  cases h with
  | mineFirst _ _ _ hm ht => exact hm.zoneOnly.trans ht.zoneOnly
  | oppFirst _ _ _ ht hm => exact ht.zoneOnly.trans hm.zoneOnly

/-- The owed `movedUp` and `movedDown` triggers are triggers of their event, at their place. -/
theorem GameState.mem_upOwed {g : GameState} {ab : Ability} (h : ab ∈ g.upOwed) :
    ∃ p : InPlay, ab ∈ p.trigs .movedUp .active := by
  have hp : ∀ p : InPlay, ab ∈ p.owedUp → ab ∈ p.trigs .movedUp .active := fun p hp => by
    unfold InPlay.owedUp at hp
    split at hp
    · exact hp
    · nomatch hp
  rcases List.mem_append.1 h with h | h
  · cases ha : g.cur.active with
    | none => rw [ha] at h; nomatch h
    | some p => rw [ha] at h; exact ⟨p, hp p h⟩
  · obtain ⟨p, _, h'⟩ := List.mem_flatMap.1 h
    exact ⟨p, hp p h'⟩

theorem GameState.mem_downOwed {g : GameState} {ab : Ability} (h : ab ∈ g.downOwed) :
    ∃ p : InPlay, ab ∈ p.trigs .movedDown .bench := by
  have hp : ∀ p : InPlay, ab ∈ p.owedDown → ab ∈ p.trigs .movedDown .bench := fun p hp => by
    unfold InPlay.owedDown at hp
    split at hp
    · exact hp
    · nomatch hp
  rcases List.mem_append.1 h with h | h
  · cases ha : g.cur.active with
    | none => rw [ha] at h; nomatch h
    | some p => rw [ha] at h; exact ⟨p, hp p h⟩
  · obtain ⟨p, _, h'⟩ := List.mem_flatMap.1 h
    exact ⟨p, hp p h'⟩

theorem GameState.upOwed_trigOk {g : GameState} {ab : Ability} (h : ab ∈ g.upOwed) :
    (ab.script TrigEvent.movedUp.place).trigOk = true := by
  obtain ⟨_, h⟩ := GameState.mem_upOwed h
  exact InPlay.trigOk_of_mem_trigs h

theorem GameState.downOwed_trigOk {g : GameState} {ab : Ability} (h : ab ∈ g.downOwed) :
    (ab.script TrigEvent.movedDown.place).trigOk = true := by
  obtain ⟨_, h⟩ := GameState.mem_downOwed h
  exact InPlay.trigOk_of_mem_trigs h

/-- **The player to move's own triggers recycle nothing** (milestone MV7c): they fire before the
turn's attack (`TrigEvent.late = false`), as `oppBenched` ones. -/
theorem GameState.upOwed_recFilters {g : GameState} {ab : Ability} (h : ab ∈ g.upOwed) :
    (ab.script TrigEvent.movedUp.place).recFilters = [] := by
  obtain ⟨_, h⟩ := GameState.mem_upOwed h
  exact InPlay.recFilters_of_mem_trigs h rfl

theorem GameState.downOwed_recFilters {g : GameState} {ab : Ability} (h : ab ∈ g.downOwed) :
    (ab.script TrigEvent.movedDown.place).recFilters = [] := by
  obtain ⟨_, h⟩ := GameState.mem_downOwed h
  exact InPlay.recFilters_of_mem_trigs h rfl

/-- `Fire.exists`, keeping both Active Spots filled. -/
theorem Fire.exists_both {ev : TrigEvent} : ∀ {l : List Ability},
    (∀ ab ∈ l, (ab.script ev.place).trigOk = true) → ∀ {g : GameState}, g.BothActive →
      ∃ g', Fire ev l g g' ∧ g'.BothActive
  | [], _, g, hb => ⟨g, .nil g, hb⟩
  | ab :: l, hl, g, hb => by
      obtain ⟨g₁, hr, hb₁⟩ := Run.exists_of_trigOk (hl ab (.head _)) hb.swap
      obtain ⟨g₂, ht, hb₂⟩ := Fire.exists_both (fun x hx => hl x (.tail _ hx)) (g := g₁.swap) hb₁.swap
      exact ⟨g₂, .run (hl ab (.head _)) hr ht, hb₂⟩

/-- **Pending triggers can always be resolved** (milestone MV7; since milestone MV7c the owed
triggers of both players): from a state with both Active Spots filled, the owed triggers have a
resolution (every one resolving, the player to move's first). -/
theorem GameState.BothActive.trigs_exist {g : GameState} (h : g.BothActive) : ∃ g', Owed g g' := by
  obtain ⟨g₁, h₁, hb₁⟩ := Fire.exists_both (ev := .movedUp) (l := g.upOwed)
    (fun _ hab => GameState.upOwed_trigOk hab) (g := g.unpend.swap) h.unpend.swap
  obtain ⟨g₂, h₂, hb₂⟩ := Fire.exists_both (ev := .movedDown) (l := g.downOwed)
    (fun _ hab => GameState.downOwed_trigOk hab) hb₁
  obtain ⟨g₃, h₃⟩ := Fire.exists (ev := .oppBenched) (l := g.owedTrigs)
    (fun _ hab => GameState.owedTrigs_trigOk hab) (g := g₂.swap) hb₂.swap
  exact ⟨g₃, .mineFirst (.refl _) (.refl _) (.refl _) ⟨g₁, g₂, h₁, h₂, rfl⟩ h₃⟩

/-- No own trigger, no change. -/
theorem FireMine.nil (g : GameState) : FireMine [] [] g g :=
  ⟨g.swap, g.swap, .nil _, .nil _, (GameState.swap_swap g).symm⟩

theorem FireMine.nil_eq {g g' : GameState} (h : FireMine [] [] g g') : g' = g := by
  obtain ⟨g₁, g₂, h₁, h₂, rfl⟩ := h
  rw [h₂.nil_eq, h₁.nil_eq, GameState.swap_swap]

/-- **The owed triggers when the player to move owes none** (milestone MV7c): the opponent's
`oppBenched` triggers alone, as before milestone MV7c. -/
theorem Owed.of_opp {g g' : GameState} {l : List Ability} (hu : g.upOwed = [])
    (hd : g.downOwed = []) (hl : l.Perm g.owedTrigs) (ht : Fire .oppBenched l g.unpend g') :
    Owed g g' :=
  .mineFirst (u := []) (d := []) (by rw [hu]) (by rw [hd]) hl (FireMine.nil _) ht

/-- Every resolution of the owed triggers when the player to move owes none is a resolution of the
opponent's alone. -/
theorem Owed.opp_inv {g g' : GameState} (h : Owed g g') (hu : g.upOwed = [])
    (hd : g.downOwed = []) : ∃ l, l.Perm g.owedTrigs ∧ Fire .oppBenched l g.unpend g' := by
  cases h with
  | mineFirst hu' hd' hl hm ht =>
      rw [hu] at hu'; rw [hd] at hd'
      rw [List.Perm.eq_nil hu', List.Perm.eq_nil hd'] at hm
      rw [hm.nil_eq] at ht
      exact ⟨_, hl, ht⟩
  | oppFirst hu' hd' hl ht hm =>
      rw [hu] at hu'; rw [hd] at hd'
      rw [List.Perm.eq_nil hu', List.Perm.eq_nil hd'] at hm
      rw [hm.nil_eq]
      exact ⟨_, hl, ht⟩

/-- **The owed triggers when the opponent owes none** (milestone MV7c): the player to move's own. -/
theorem Owed.of_mine {g g' : GameState} {u d : List Ability} (ho : g.owedTrigs = [])
    (hu : u.Perm g.upOwed) (hd : d.Perm g.downOwed) (hm : FireMine u d g.unpend g') : Owed g g' :=
  .mineFirst hu hd (l := []) (by rw [ho]) hm (.nil _)

/-- Every resolution of the owed triggers when the opponent owes none is one of the player to
move's own. -/
theorem Owed.mine_inv {g g' : GameState} (h : Owed g g') (ho : g.owedTrigs = []) :
    ∃ u d, u.Perm g.upOwed ∧ d.Perm g.downOwed ∧ FireMine u d g.unpend g' := by
  cases h with
  | mineFirst hu hd hl hm ht =>
      rw [ho] at hl
      rw [List.Perm.eq_nil hl] at ht
      rw [ht.nil_eq]
      exact ⟨_, _, hu, hd, hm⟩
  | oppFirst hu hd hl ht hm =>
      rw [ho] at hl
      rw [List.Perm.eq_nil hl] at ht
      rw [ht.nil_eq] at hm
      exact ⟨_, _, hu, hd, hm⟩

/-- `GameState.BothActive.trigs_exist` from a `Calm` state. -/
theorem Calm.trigs_exist {g : GameState} (h : Calm g) : ∃ g', Owed g g' :=
  h.bothActive.trigs_exist

end Pokemon
