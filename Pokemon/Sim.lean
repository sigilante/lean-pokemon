import Pokemon.Damage

/-!
# The clamp is a bisimulation (for tame decks)

`GameState.clamp k` caps damage and Poison strength on both Active Pokémon at their HP, and every
damage bonus and reduction in both players' stores at `k`. This file proves that its kernel is a
bisimulation for moves, for a deck whose cards are *tame* (no damage reduction, no `drain`),
whose test constants are below `k`, and whose printed HP is at most `k` (`GameState.Fit`).
`Pokemon/Lingering.lean` shows that neither tameness condition can be dropped: with a damage
reduction the kernel of `clamp k` is not a simulation for any `k ≥ 3`, with `drain` for any
`k ≥ 2`.

* `Run.cap_sim`: inside an attack's effect, the kernel of `rclamp k` (the player's own damage
  exact; the opponent's damage, and the damage bonuses, capped at `k`) is a simulation. A bonus
  is read only by `damage`, which adds it to the opponent's damage; a test reads that damage
  only against a constant below `k`, so it cannot tell `k` from anything larger, and a damage of
  at least `k` is at least the opponent's HP, so the Knock Out after the attack takes it either
  way.
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
  | linger w s m g =>
      intro ht hn
      have hm : ∀ n, m ≠ .reduce n := by
        intro n hm; subst hm; simp [Effect.tame] at ht
      cases w with
      | own => exact ⟨hn.1.add s m hm, hn.2⟩
      | opp => exact ⟨hn.1, hn.2.add s m hm⟩
  | drain => intro ht; simp [Effect.tame] at ht
  | _ => intro _ hn; exact hn

theorem KOMove.noReduce {g g' : GameState} (h : KOMove g g') (hn : g.NoReduce) : g'.NoReduce := by
  cases h <;> exact hn

theorem Resolve.noReduce {g g' : GameState} (h : Resolve g g') (hn : g.NoReduce) :
    g'.NoReduce := by
  induction h with
  | done => exact hn
  | step _ hm _ ih => exact ih (hm.noReduce hn)

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

/-- **Inside an attack's effect, the kernel of `rclamp k` is a simulation**, for a tame effect
whose test constants are below `k`, from a state with no damage reduction. Two states that agree
except in the opponent's damage at or above `k`, the damage bonuses at or above `k`, and Poison
strength above HP have the same effect resolutions, up to the same relation. -/
theorem Run.cap_sim {k : Nat} (hk0 : 0 < k) {e : Effect} {g₁ g₁' : GameState}
    (h : Run e g₁ g₁') :
    e.tame = true → e.tmax < k → g₁.NoReduce → ∀ {g₂ : GameState}, g₁.rclamp k = g₂.rclamp k →
      ∃ g₂', Run e g₂ g₂' ∧ g₁'.rclamp k = g₂'.rclamp k := by
  induction h with
  | skip g => intro _ _ _ g₂ hc; exact ⟨g₂, .skip g₂, hc⟩
  | draw h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .draw h, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂]⟩
  | drawEmpty h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .drawEmpty h, hc⟩
  | @heal g p n h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have hq' : InPlay.Agree .exact { q with damage := q.damage - n }
          { p with damage := p.damage - n } := by
        rw [hq.damage_eq]; exact hq.setDamage _
      exact ⟨_, .heal n rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some,
          InPlay.clamp_of_agree hq', ha₂, hm₁, hm₂]⟩
  | counters n h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .counters n rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n)]⟩
  | inflict c h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .inflict c rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.2.2.1 c)]⟩
  | poisonUp n h hp =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUp n rfl (hq.poisoned.trans hp), by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.2.1 n)]⟩
  | poisonUpSkip n h hp =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUpSkip n rfl (hq.poisoned.trans hp), hc⟩
  | cure h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .cure rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂,
          InPlay.clamp_of_agree hq.upd.2.2.2.2.1]⟩
  | iteT h ht' _ ih =>
      intro ht hb hn g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih ht.1 (by omega) hn hc
      exact ⟨g₂', .iteT hq (by rw [Test.eval_agree _ hqa (by omega)]; exact ht') r', hc'⟩
  | iteF h ht' _ ih =>
      intro ht hb hn g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih ht.2 (by omega) hn hc
      exact ⟨g₂', .iteF hq (by rw [Test.eval_agree _ hqa (by omega)]; exact ht') r', hc'⟩
  | @scale g p q w k' hs h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q₂, rfl, hq⟩ := agree_of_map ha₂
      cases w with
      | own =>
          change g.cur.active = some p at hs
          rw [hs] at hc₂
          obtain ⟨s, rfl, hsa⟩ := agree_of_map hc₂
          have hq' : InPlay.Agree (.upto k) { q₂ with damage := q₂.damage + k' * s.damage }
              { q with damage := q.damage + k' * p.damage } := by
            rw [hsa.damage_eq]; exact hq.upd.2.1 _
          exact ⟨_, .scale .own k' rfl rfl, by
            simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hs, hm₁, hm₂,
              InPlay.clamp_of_agree hq', InPlay.clamp_of_agree hsa]⟩
      | opp =>
          change g.opp.active = some p at hs
          have e : q = p := Option.some.inj (h.symm.trans hs)
          subst e
          have hd := hq.damage
          simp only [Cap.dmg] at hd
          have hq' : InPlay.Agree (.upto k) { q₂ with damage := q₂.damage + k' * q₂.damage }
              { q with damage := q.damage + k' * q.damage } :=
            ⟨hq.top, hq.under, hq.energy, hq.tools, hq.rot, hq.poisoned, hq.burned, hq.fresh,
              hq.marks, by simp only [Cap.dmg]; exact min_add_mul hd k', hq.poisonUp⟩
          exact ⟨_, .scale .opp k' rfl rfl, by
            simp only [GameState.rclamp, GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
              InPlay.clamp_of_agree hq']⟩
  | @selfDamage g p n h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .selfDamage n rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n)]⟩
  | @healAll g p h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .healAll rfl, by
        simp only [GameState.rclamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.setDamage 0)]⟩
  | @touchActive e w f g p he h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h] at hc₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, Option.map_some,
              ha₂, hm₁, hm₂, InPlay.clamp_of_agree (hq.setMarks f)]⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h] at ha₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, Option.map_some,
              hc₂, hm₁, hm₂, InPlay.clamp_of_agree (hq.setMarks f)]⟩
  | @touchBench e w f g q b₁ b₂ he h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .touchBench he h, by
          simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁,
            hm₂]⟩
  | unmark w m g =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .unmark _ m _, by
          simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, PlayerState.unmark,
            hc₂, ha₂, hm₁, hm₂, map_clamp_setMarks _ hc₂, map_clamp_setMarks _ ha₂]⟩
  | linger w s m g =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      cases w <;>
        exact ⟨_, .linger _ s m _, by
          simp only [GameState.rclamp, GameState.clampAt, GameState.updSide, hc₂, ha₂, hm₁, hm₂,
            Store.cap_add hm₁, Store.cap_add hm₂]⟩
  | @damage g p n h =>
      intro _ _ hn g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      have hq' : InPlay.Agree (.upto k) { q with damage := q.damage + dealtBy n m₁ m₂ }
          { p with damage := p.damage + dealtBy n g.cur.mods g.opp.mods } :=
        ⟨hq.top, hq.under, hq.energy, hq.tools, hq.rot, hq.poisoned, hq.burned, hq.fresh,
          hq.marks, hq.dmg_add_upto (dealtBy_cap hk0 hm₁ hm₂ hn.2 n), hq.poisonUp⟩
      exact ⟨_, .damage n rfl, by
        simp only [GameState.rclamp, GameState.clampAt, GameState.dealt, Option.map_some, hc₂,
          hm₁, hm₂, InPlay.clamp_of_agree hq']⟩
  | drain => intro ht; simp [Effect.tame] at ht
  | shuffle h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .shuffle h, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂]⟩
  | search h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .search h, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂]⟩
  | handToBottom h =>
      intro _ _ _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .handToBottom h, by
        simp only [GameState.rclamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂]⟩
  | seq h₁ _ ih₁ ih₂ =>
      intro ht hb hn g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ ht.1 (by omega) hn hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ ht.2 (by omega) (h₁.noReduce ht.1 hn) hc'
      exact ⟨g₂'', .seq r₁ r₂, hc''⟩
  | choiceL _ ih =>
      intro ht hb hn g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih ht.1 (by omega) hn hc
      exact ⟨g₂', .choiceL r, hc'⟩
  | choiceR _ ih =>
      intro ht hb hn g₂ hc
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih ht.2 (by omega) hn hc
      exact ⟨g₂', .choiceR r, hc'⟩
  | iterNil a g => intro _ _ _ g₂ hc; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons h₁ _ ih₁ ih₂ =>
      intro ht hb hn g₂ hc
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ ht hb hn hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ ht hb (h₁.noReduce ht hn) hc'
      exact ⟨g₂'', .iterCons r₁ r₂, hc''⟩

/-! ## Trainer effects -/

/-- Every Pokémon card in the game has HP at most `k`. -/
def GameState.HpLe (k : Nat) (g : GameState) : Prop :=
  ∀ p : PokemonCard, Card.pokemon p ∈ g.allCards → p.hp ≤ k

theorem GameState.HpLe.of_perm {k : Nat} {g g' : GameState} (h : g.HpLe k)
    (hp : g'.allCards.Perm g.allCards) : g'.HpLe k :=
  fun p hm => h p (hp.mem_iff.1 hm)

/-- **The kernel of `clamp k` is a simulation for Trainer effects** (`TRun`), from a state that
is `Settled` or finished, for a tame effect with test constants below `k`, with no damage
reduction and every HP at most `k`. -/
theorem TRun.clamp_sim {k : Nat} (hk0 : 0 < k) {e : Effect} {g₁ g₁' : GameState}
    (h : TRun e g₁ g₁') :
    e.tame = true → e.tmax < k → g₁.NoReduce → g₁.HpLe k → ∀ {g₂ : GameState},
      g₁.clamp k = g₂.clamp k → (Settled g₁ ∨ g₁.winner ≠ none) →
        ∃ g₂', TRun e g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  induction h with
  | prim he hn hr hk =>
      intro ht hb hnr hhp g₂ hc hs
      have hs : Settled _ := hs.resolve_right (fun h => h hn)
      obtain ⟨m₂, hr₂, hcm⟩ := Run.cap_sim hk0 hr ht hb hnr (GameState.rclamp_of_clamp hc hs.1)
      have hhp' := hhp.of_perm hr.perm
      obtain ⟨g₂', hk₂, hc'⟩ := hk.clamp_sim (k := k)
        (GameState.clamp_of_rclamp hcm fun p hp => hhp' _ (GameState.top_mem_opp_active hp))
      exact ⟨g₂', .prim he (by rw [GameState.winner_of_clamp hc]; exact hn) hr₂ hk₂, hc'⟩
  | stop hn =>
      intro _ _ _ _ g₂ hc _
      exact ⟨g₂, .stop (by rw [GameState.winner_of_clamp hc]; exact hn), hc⟩
  | iteT hn h ht' _ ih =>
      intro ht hb hnr hhp g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree (GameState.rclamp_of_clamp hc hs'.1) h
      obtain ⟨g₂', r', hc'⟩ := ih ht.1 (by omega) hnr hhp hc hs
      exact ⟨g₂', .iteT (by rw [GameState.winner_of_clamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ hqa (by omega)]; exact ht') r', hc'⟩
  | iteF hn h ht' _ ih =>
      intro ht hb hnr hhp g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      simp only [Effect.tame, Bool.and_eq_true] at ht
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.activeOf_agree (GameState.rclamp_of_clamp hc hs'.1) h
      obtain ⟨g₂', r', hc'⟩ := ih ht.2 (by omega) hnr hhp hc hs
      exact ⟨g₂', .iteF (by rw [GameState.winner_of_clamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ hqa (by omega)]; exact ht') r', hc'⟩
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
every Pokémon card has HP at most `k`; every card is tame (no damage reduction, no `drain`) and
its test constants are below `k`; and no damage reduction is in effect. -/
def GameState.Fit (k : Nat) (g : GameState) : Prop :=
  0 < k ∧ g.HpLe k ∧ (∀ x ∈ g.allCards, x.tame = true ∧ x.tmax < k) ∧ g.NoReduce

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

/-- The effect an attack resolves is tame, with test constants below `k`. -/
theorem GameState.Fit.attack {k : Nat} {g : GameState} (hF : g.Fit k) {a : InPlay} {atk : Attack}
    (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks) :
    (Effect.seq (.damage atk.damage) atk.effect).tame = true ∧
      (Effect.seq (.damage atk.damage) atk.effect).tmax < k := by
  obtain ⟨ht, hb⟩ := hF.2.2.1 _ (GameState.top_mem_cur_active ha)
  simp only [Card.tame, Card.tmax] at ht hb
  have h1 := attacksTame_mem ht hm
  have h2 := attacksTmax_mem (as := a.top.attacks) hm
  refine ⟨?_, ?_⟩
  · simp only [Effect.tame, h1, Bool.and_self]
  · simp only [Effect.tmax]; omega

/-- The effect of a Trainer card in hand is tame, with test constants below `k`. -/
theorem GameState.Fit.trainer {k : Nat} {g : GameState} (hF : g.Fit k) {n : String}
    {t : TrainerKind} {e : Effect} {l₁ l₂ : List Card}
    (hh : g.cur.hand = l₁ ++ Card.trainer n t e :: l₂) : e.tame = true ∧ e.tmax < k := by
  have hx : Card.trainer n t e ∈ g.cur.hand := by
    rw [hh]; exact List.mem_append_right _ (.head _)
  exact hF.2.2.1 _ (GameState.mem_allCards_of_hand hx)

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
  | @attack g' a atk ha hm hc hs hn' hf hbt hst hr =>
      have h1 := ht _ (GameState.top_mem_cur_active ha)
      simp only [Card.tame] at h1
      have h2 := attacksTame_mem h1 hm
      exact hr.noReduce (by simp only [Effect.tame, h2, Bool.and_self]) hn
  | endTurn => exact ⟨hn.2.shift, hn.1.shift⟩
  | _ => exact hn

/-- Play preserves `Fit k`: the cards are permuted, and no damage reduction comes into effect. -/
theorem Move.fit {k : Nat} {g g' : GameState} (h : Move g g') (hF : g.Fit k) : g'.Fit k :=
  ⟨hF.1, hF.2.1.of_perm h.perm, fun x hx => hF.2.2.1 x (h.perm.mem_iff.1 hx),
    h.noReduce (fun x hx => (hF.2.2.1 x hx).1) hF.2.2.2⟩

theorem Reach.fit {k : Nat} {g₀ g : GameState} (h : Reach g₀ g) (hF : g₀.Fit k) : g.Fit k := by
  induction h with
  | refl => exact hF
  | step _ _ hm ih => exact hm.fit ih

theorem optCardList_of_map {c : Cap} {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith c) = o₁.map (InPlay.clampWith c)) :
    optCardList o₂ = optCardList o₁ := by
  cases o₁ with
  | none => rw [none_of_map h]
  | some p =>
      obtain ⟨q, rfl, hq⟩ := agree_of_map h
      simp only [optCardList, hq.cardList]

/-- `Fit k` transfers along equal clamps. -/
theorem GameState.Fit.of_clamp {k : Nat} {g₁ g₂ : GameState} (hF : g₁.Fit k)
    (hc : g₁.clamp k = g₂.clamp k) : g₂.Fit k := by
  obtain ⟨c₂, a₂, m₁, m₂, rfl, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
  have hcards : ({ g₁ with
      cur := { g₁.cur with active := c₂, mods := m₁ },
      opp := { g₁.opp with active := a₂, mods := m₂ } } : GameState).allCards.Perm
        g₁.allCards := by
    have e₁ := optCardList_of_map hc₂
    have e₂ := optCardList_of_map ha₂
    simp only [GameState.allCards, PlayerState.allCards, e₁, e₂]
    exact .refl _
  exact ⟨hF.1, hF.2.1.of_perm hcards, fun x hx => hF.2.2.1 x (hcards.mem_iff.1 hx),
    Store.NoReduce.of_cap hF.1 hm₁ hF.2.2.2.1, Store.NoReduce.of_cap hF.1 hm₂ hF.2.2.2.2⟩

/-- **The kernel of `clamp k` is a bisimulation for `Move`**, for a state that is `Fit k`: if
`g₁` and `g₂` have the same clamp, every move from `g₁` is matched by a move from `g₂` to a state
with the same clamp. (`Fit k` transfers to `g₂`, `GameState.Fit.of_clamp`, so this gives both
directions.) -/
theorem Move.clamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} (hF : g₁.Fit k) (h : Move g₁ g₁')
    (hc : g₁.clamp k = g₂.clamp k) : ∃ g₂', Move g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  have hk₂ := GameState.damageBounded_of_clamp hc
  have hs₂ := GameState.settled_of_clamp hc
  obtain ⟨c₂, a₂, m₁, m₂, hg, hc₂, ha₂, hm₁, hm₂⟩ := GameState.clamp_inv hc
  have hfl := Store.flags_of_cap hm₁
  cases h with
  | playBasic hh hs hhp hb hbt hst =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, .playBasic hh hs hhp hb hbt hs', by
        simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂]⟩
  | @attach l₁ l₂ t a hh hf ha hbt hst =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have key := hq.clamp_map (c' := .hp) (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
        (fun x => { x with energy := Card.energy t :: x.energy }) (fun _ => rfl) rfl rfl
      exact ⟨_, .attach hh hf rfl hbt hs', by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂, key]⟩
  | @evolve l₁ l₂ p a hh ha he hfr hf hbt hst =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
      refine ⟨_, .evolve hh rfl (by rw [hq.top]; exact he) (hq.fresh.trans hfr) hf hbt hs', ?_⟩
      rw [e]
      simp only [GameState.clamp, GameState.clampAt, ha₂, hm₁, hm₂]
  | @retreat a q' b₁ b₂ paid rest ha hb hr he hp hs hbt hst hl =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
      refine ⟨_, .retreat rfl hb hr (hq.energy.trans he) (by rw [hq.top]; exact hp)
        (by rw [hq.rot]; exact hs) hbt hs' (by rw [hfl.2.2.1]; exact hl), ?_⟩
      rw [e]
      simp only [GameState.clamp, GameState.clampAt, ha₂, hm₁, hm₂]
  | @item g' l₁ l₂ n e hh hbt hst hr hl =>
      have hs' := hs₂ hst
      obtain ⟨ht, hb⟩ := hF.trainer hh
      have hp : ({ g₁ with cur := { g₁.cur with
          hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g₁.cur.discard } } :
          GameState).allCards.Perm g₁.allCards := by perm_count [hh]
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim hF.1 ht hb hF.2.2.2 (hF.2.1.of_perm hp)
        (g₂ := { g₂ with cur := { g₂.cur with
          hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂])
        (.inl hst)
      exact ⟨g₂', .item (by subst hg; exact hh) (by subst hg; exact hbt) hs' hr'
        (by subst hg; rw [hfl.2.2.2]; exact hl), hc'⟩
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr =>
      have hs' := hs₂ hst
      obtain ⟨ht, hb⟩ := hF.trainer hh
      have hp : ({ g₁ with cur := { g₁.cur with
          hand := l₁ ++ l₂, supporterPlayed := true,
          discard := Card.trainer n .supporter e :: g₁.cur.discard } } :
          GameState).allCards.Perm g₁.allCards := by perm_count [hh]
      obtain ⟨g₂', hr', hc'⟩ := hr.clamp_sim hF.1 ht hb hF.2.2.2 (hF.2.1.of_perm hp)
        (g₂ := { g₂ with cur := { g₂.cur with
          hand := l₁ ++ l₂, supporterPlayed := true,
          discard := Card.trainer n .supporter e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, hm₁, hm₂])
        (.inl hst)
      exact ⟨g₂', .supporter (by subst hg; exact hh) (by subst hg; exact hs)
        (by subst hg; exact hbt) hs' hr', hc'⟩
  | @attack g' a atk ha hm hc' hs hn hf hbt hst hr hl hgx =>
      have hs' := hs₂ hst
      obtain ⟨ht, hb⟩ := hF.attack ha hm
      obtain ⟨g₂', hr', hc''⟩ := Run.cap_sim hF.1 hr ht hb hF.2.2.2
        (GameState.rclamp_of_clamp hc hst.1)
      have hhp := hF.2.1.of_perm hr.perm
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      refine ⟨_, .attack rfl (by rw [hq.top]; exact hm) (by rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hs' hr' (by rw [hfl.2.1]; exact hl) hgx, ?_⟩
      have := congrArg (fun g : GameState => ({ g with
        attacked := true, cur := { g.cur with gxUsed := atk.gx || g.cur.gxUsed } } :
        GameState)) hc''
      exact GameState.clamp_of_rclamp this
        (fun p hp => hhp _ (GameState.top_mem_opp_active (g := g') hp))
  | attackConfused ha hm hc' hs hn hf hbt hst hl =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .attackConfused rfl (by rw [hq.top]; exact hm) (by rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hs' (by rw [hfl.2.1]; exact hl), by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.1 3)]⟩
  | knockOut ha hk hp =>
      subst hg
      rw [ha] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .knockOut rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_none, hc₂, hm₁, hm₂,
          hq.cardList]⟩
  | promote ha hb =>
      subst hg
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .promote rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, hm₁, hm₂]⟩
  | noPokemon ha hb =>
      subst hg
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .noPokemon rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, hc₂, hm₁, hm₂, ha, Option.map_none]⟩
  | knockOutOwn ha hk hp =>
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .knockOutOwn rfl (hq.ko hk) hp, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_none, ha₂, hm₁, hm₂,
          hq.cardList]⟩
  | promoteOwn ha hb =>
      subst hg
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .promoteOwn rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, ha₂, hm₁, hm₂]⟩
  | noPokemonOwn ha hb =>
      subst hg
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .noPokemonOwn rfl hb, by
        simp only [GameState.clamp, GameState.clampAt, ha₂, hm₁, hm₂, ha, Option.map_none]⟩
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
        InPlay.clamp_of_agree h1, InPlay.clamp_of_agree h2, Store.cap_shift hm₁,
        Store.cap_shift hm₂]
  | startTurn hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      refine ⟨_, .startTurn hbt rfl rfl hk' hd, ?_⟩
      simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha, hb, hm₁, hm₂,
        InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb]
  | deckOut hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      exact ⟨_, .deckOut hbt rfl rfl hk' hd, by
        simp only [GameState.clamp, GameState.clampAt, Option.map_some, ha, hb, hm₁, hm₂,
          InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb]⟩

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
