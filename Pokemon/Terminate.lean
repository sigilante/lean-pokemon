import Pokemon.WellFormed

/-!
# The repeated Knock Out check terminates

After a batch Knock Out step (`KOBatch`) the state may again be not `Settled` (a removal or a
promotion changed derived HP), and another batch follows (`Resolve`, `Move.knockOuts`). This file
proves that the repetition ends.

* `GameState.koMeasure`: twice the number of Pokémon in play (both players, Active and Bench) plus
  the number of empty Active Spots.
* `KOBatch.koMeasure_lt`: a batch that leaves the game without an outcome lowers the measure. A
  batch from a state with a pending Knock Out removes at least one Pokémon (and the promotions,
  which fill every empty Active Spot, move a Pokémon without removing one); a batch from a state
  with no pending Knock Out has an empty Active Spot to fill.
* `KOBatch.acc`: every chain of batch steps, each taken while the game has no outcome (as in
  `Resolve`), is finite (accessibility of the converse relation).
* `Resolve.exists`: every state has a `Resolve` result, and every result is `Settled` or has an
  outcome. So every primitive step of a Trainer effect can always be resolved.
* `KOChain`, `Resolve.chain`, `KOChain.length_le`: a `Resolve` result from a state with no pending
  trigger is reached by a chain of at most `koMeasure g + 1` batches. With a trigger pending
  (milestone MV7) `Resolve` resolves it first when both Active Spots are filled (`Resolve.trigger`,
  `Resolve.trigger_first`), then at most `koMeasure + 1` batches measured after the triggers
  (`Resolve.chain_le_pend`; no bound in the measure before them is proved); no trigger sets the
  record again, so `Resolve.exists` recurses on the record first.

All proofs are constructive (the axiom gate of `Pokemon/Audit.lean`).
-/

namespace Pokemon

/-- 1 for a Pokémon, 0 for none. -/
def optCount : Option InPlay → Nat
  | none => 0
  | some _ => 1

/-- The number of the player's Pokémon in play, Active and Benched. -/
def PlayerState.inPlayCount (s : PlayerState) : Nat := optCount s.active + s.bench.length

/-- 1 if the player's Active Spot is empty, 0 otherwise. -/
def PlayerState.emptyActive (s : PlayerState) : Nat := 1 - optCount s.active

/-- **The termination measure of the repeated check**: twice the number of Pokémon in play (both
players, Active and Bench) plus the number of empty Active Spots. -/
def GameState.koMeasure (g : GameState) : Nat :=
  2 * (g.cur.inPlayCount + g.opp.inPlayCount) + (g.cur.emptyActive + g.opp.emptyActive)

/-- Marking a promoted Pokémon (milestone MV7c) does not change the count. -/
theorem optCount_promo (b : Bool) (f : InPlay → InPlay) (o : Option InPlay) :
    optCount (if b then o.map f else o) = optCount o := by
  cases b <;> cases o <;> rfl

theorem optCount_le_one (o : Option InPlay) : optCount o ≤ 1 := by
  cases o <;> simp [optCount]

/-- The check splits an optional Pokémon into the kept and the removed one. -/
theorem optCount_filter (t : InPlay → Bool) (o : Option InPlay) :
    optCount (optFilter (fun p => !t p) o) + optCount (optFilter t o) = optCount o := by
  cases o with
  | none => rfl
  | some p => cases h : t p <;> simp [optFilter, optCount, h]

/-- The check splits a Bench into the kept and the removed Pokémon. -/
theorem koLength_split (t : InPlay → Bool) :
    ∀ l : List InPlay, (l.filter (fun p => !t p)).length + (l.filter t).length = l.length
  | [] => rfl
  | q :: qs => by
      have ih := koLength_split t qs
      cases h : t q <;> simp [h] <;> omega

/-- The Prize value of a removed optional Pokémon is at most 3 per Pokémon. -/
theorem optPrizes_le (o : Option InPlay) : optPrizes o ≤ 3 * optCount o := by
  cases o with
  | none => simp [optPrizes, optCount]
  | some p => simpa [optPrizes, optCount] using p.top.prizeCount_le

/-- The Prize value of removed Benched Pokémon is at most 3 per Pokémon. -/
theorem benchPrizes_le : ∀ l : List InPlay, benchPrizes l ≤ 3 * l.length
  | [] => by simp [benchPrizes]
  | q :: qs => by
      have ih := benchPrizes_le qs
      have hq := q.top.prizeCount_le
      simp only [benchPrizes, List.length_cons]
      omega

/-- The Pokémon the check removes from a player: their number, and the Prize value is at most 3
for each. -/
theorem PlayerState.koOut_inPlay (ta tb : InPlay → Bool) (s : PlayerState) :
    (s.koOut ta tb).inPlayCount + (optCount (optFilter ta s.active) + (s.bench.filter tb).length) =
        s.inPlayCount ∧
      s.koValue ta tb ≤ 3 * (optCount (optFilter ta s.active) + (s.bench.filter tb).length) := by
  have h1 := optCount_filter ta s.active
  have h2 := koLength_split tb s.bench
  have h3 := optPrizes_le (optFilter ta s.active)
  have h4 := benchPrizes_le (s.bench.filter tb)
  refine ⟨?_, ?_⟩
  · simp only [PlayerState.inPlayCount, PlayerState.koOut]
    omega
  · simp only [PlayerState.koValue]
    omega

/-- After the check, a player keeps at most the Pokémon they had, and fewer if the opponent takes a
Prize card for one of them. -/
theorem GameState.koStep_count (g : GameState) (w : Whose) :
    (g.koOf w).inPlayCount ≤ (g.side w).inPlayCount ∧
      (0 < g.koVal w → (g.koOf w).inPlayCount < (g.side w).inPlayCount) := by
  obtain ⟨h1, h2⟩ := PlayerState.koOut_inPlay (g.koT w .active) (g.koT w .bench) (g.side w)
  refine ⟨?_, fun hp => ?_⟩
  · simp only [GameState.koOf]; omega
  · simp only [GameState.koOf]
    simp only [GameState.koVal] at hp
    omega

/-- A promotion moves a Pokémon from the Bench to the Active Spot: the count is unchanged and the
Active Spot is filled. -/
theorem Promote.count {a a' : Option InPlay} {b b' : List InPlay} (h : Promote a b a' b') :
    optCount a' + b'.length = optCount a + b.length ∧ optCount a' = 1 := by
  cases h with
  | keep => exact ⟨rfl, rfl⟩
  | pick =>
      refine ⟨?_, rfl⟩
      simp only [optCount, List.length_append, List.length_cons]
      omega

/-- A state that is not `Calm` has a pending Knock Out (some Prize value to take) or an empty
Active Spot. (Before milestone MV7 the hypothesis was `¬ Settled g`, which meant the same.) -/
theorem koVal_pos_or_empty {g : GameState} (hu : ¬ Calm g) :
    0 < g.koVal .own + g.koVal .opp ∨ 0 < g.cur.emptyActive + g.opp.emptyActive := by
  rcases damageBounded_or_pending g with hk | hk
  · right
    have e1 := optCount_le_one g.cur.active
    have e2 := optCount_le_one g.opp.active
    cases hc : g.cur.active with
    | none =>
        simp only [PlayerState.emptyActive, hc, optCount]
        omega
    | some a =>
        cases ho : g.opp.active with
        | none =>
            simp only [PlayerState.emptyActive, ho, optCount]
            omega
        | some b =>
            have hs : Calm g :=
              ⟨hk, (by rw [hc]; exact fun e => nomatch e), (by rw [ho]; exact fun e => nomatch e)⟩
            exact absurd hs hu
  · left
    apply Nat.pos_of_ne_zero
    intro h0
    have h1 : g.koVal .own = 0 := by omega
    have h2 : g.koVal .opp = 0 := by omega
    apply hk
    intro w sp p hp
    cases w
    · exact g.koVal_eq_zero h1 sp p hp
    · exact g.koVal_eq_zero h2 sp p hp

/-- **A batch Knock Out step lowers the measure** unless it ends the game. The step is `go`: the
check removes `k` Pokémon and the promotions fill both Active Spots without changing the count, so
the measure goes from `2n + e` to `2(n − k)`; and `k > 0` or `e > 0`, since the state was not
`Calm` (`koVal_pos_or_empty`). -/
theorem KOBatch.koMeasure_lt {g g' : GameState} (h : KOBatch g g') (hw : g'.winner = none) :
    g'.koMeasure < g.koMeasure := by
  cases h with
  | won _ hk => exact absurd hw hk
  | go hu _ hc ho =>
      obtain ⟨hc1, hc2⟩ := hc.count
      obtain ⟨ho1, ho2⟩ := ho.count
      obtain ⟨co, co'⟩ := g.koStep_count .own
      obtain ⟨cp, cp'⟩ := g.koStep_count .opp
      have ecur : optCount g.koStep.cur.active + g.koStep.cur.bench.length =
          (g.koOf .own).inPlayCount := rfl
      have eopp : optCount g.koStep.opp.active + g.koStep.opp.bench.length =
          (g.koOf .opp).inPlayCount := rfl
      have hpos := koVal_pos_or_empty hu
      have hsc : (g.side .own) = g.cur := rfl
      have hso : (g.side .opp) = g.opp := rfl
      rw [hsc] at co co'
      rw [hso] at cp cp'
      simp only [GameState.koMeasure, PlayerState.inPlayCount, PlayerState.emptyActive,
        GameState.afterBatch, GameState.withPlay, optCount_promo]
      simp only [PlayerState.inPlayCount] at co co' cp cp' ecur eopp
      have ea1 := optCount_le_one g.cur.active
      have ea2 := optCount_le_one g.opp.active
      rcases hpos with hp | hp
      · rcases Nat.eq_zero_or_pos (g.koVal .own) with h0 | h0
        · have := cp' (by omega)
          omega
        · have := co' h0
          omega
      · simp only [PlayerState.emptyActive] at hp
        omega

/-- The batch steps of `Resolve`: a batch Knock Out step taken while the game has no outcome. -/
def KOStep (g g' : GameState) : Prop := g.winner = none ∧ KOBatch g g'

/-- **Every chain of batch Knock Out steps is finite.** No infinite sequence of batch steps, each
taken while the game has no outcome (as `Resolve` takes them), starts from `g`: `g` is accessible
for the converse of `KOStep`. A step to a state with an outcome ends the chain (no step is taken
from it); every other step lowers `koMeasure` (`KOBatch.koMeasure_lt`). -/
theorem KOBatch.acc (g : GameState) : Acc (fun b a => KOStep a b) g := by
  have key : ∀ n g, g.koMeasure = n → (g.winner = none → Acc (fun b a => KOStep a b) g) := by
    intro n
    induction n using Nat.strongRecOn with
    | ind n ih =>
        intro g hn _
        refine Acc.intro g fun g' ⟨_, hm⟩ => ?_
        cases hw : g'.winner with
        | none => exact ih _ (hn ▸ hm.koMeasure_lt hw) g' rfl hw
        | some o => exact Acc.intro g' fun _ ⟨hn', _⟩ => by rw [hw] at hn'; cases hn'
  cases hw : g.winner with
  | none => exact key _ g rfl hw
  | some o => exact Acc.intro g fun _ ⟨hn', _⟩ => by rw [hw] at hn'; cases hn'

/-- The batch steps form a well-founded relation (converse of `KOStep`). -/
theorem KOStep.wellFounded : WellFounded (fun b a => KOStep a b) := ⟨KOBatch.acc⟩

/-- The Prize cards left, both players. -/
def GameState.prizesLeft (g : GameState) : Nat := g.cur.prizes.length + g.opp.prizes.length

theorem prizes_drop_of_not_win {n : Nat} {s : PlayerState} (h : s.prizeWin n = false) :
    (s.prizes.drop n).length + n = s.prizes.length := by
  cases n with
  | zero => simp
  | succ n =>
      have ho : (s.prizes.drop (n + 1)).isEmpty = false := by
        simpa [PlayerState.prizeWin, PlayerState.prizesOut] using h
      cases e : s.prizes.drop (n + 1) with
      | nil => rw [e] at ho; cases ho
      | cons x xs =>
          have := congrArg List.length e
          simp only [List.length_drop, List.length_cons] at this
          simp only [List.length_cons]
          omega

/-- **A batch that leaves the game going takes exactly the Prize value of what it Knocked Out.** -/
theorem KOBatch.prizes_eq {g g₁ : GameState} (h : KOBatch g g₁) (hw : g₁.winner = none) :
    g₁.prizesLeft + (g.koVal .own + g.koVal .opp) = g.prizesLeft := by
  obtain ⟨p1, p2, -, -, pw⟩ := h.piles
  obtain ⟨-, h1, h2⟩ := GameState.koStep_winner_none (pw ▸ hw)
  have a1 := prizes_drop_of_not_win (winWays_eq_zero h1).1
  have a2 := prizes_drop_of_not_win (winWays_eq_zero h2).1
  have e1 : g₁.cur.prizes = g.cur.prizes.drop (g.koVal .opp) := p1
  have e2 : g₁.opp.prizes = g.opp.prizes.drop (g.koVal .own) := p2
  simp only [GameState.prizesLeft, e1, e2]
  omega

/-- A batch that promotes the player to move's Pokémon in their own turn (milestone MV7c,
`GameState.promoUp`) Knocks Out their Active Pokémon: the opponent takes at least one Prize card. -/
theorem GameState.koVal_pos_of_promoUp {g : GameState} (h : g.promoUp = true) :
    0 < g.koVal .own := by
  simp only [GameState.promoUp, Bool.and_eq_true] at h
  obtain ⟨⟨-, ha⟩, hk⟩ := h
  obtain ⟨a, ha⟩ := Option.isSome_iff_exists.1 ha
  have e : g.koStep.cur.active = optFilter (fun p => !g.koT .own .active p) g.cur.active := rfl
  rw [e, ha] at hk
  have ht : g.koT .own .active a = true := by
    cases ht : g.koT .own .active a
    · simp [optFilter, ht] at hk
    · rfl
  have hp := a.top.prizeCount_pos
  simp only [GameState.koVal, PlayerState.koValue, GameState.side, ha, optFilter, ht, ite_true,
    optPrizes]
  omega

/-- **Every state can be resolved.** From every state some `Resolve` result exists, and every such
result is `Settled` or has an outcome. So `Resolve` never gets stuck and every primitive step of a
Trainer effect can be followed by its Knock Outs (`TRun.prim`). Since milestone MV7c a batch can set
the pending-trigger record (the player to move's promotion in their own turn, `GameState.promoUp`),
so the recursion is on the Prize cards left first (such a batch Knocks Out the player's Active
Pokémon and takes a Prize card), then on the record, then on `koMeasure`. -/
theorem Resolve.exists (g : GameState) :
    ∃ g', Resolve g g' ∧ (Settled g' ∨ g'.winner ≠ none) := by
  -- a batch that goes on either takes Prize cards, or keeps them, the record and lowers `koMeasure`
  have batch : ∀ {g g₁ : GameState}, KOBatch g g₁ → g.winner = none → g₁.winner = none →
      g₁.prizesLeft < g.prizesLeft ∨
        (g₁.prizesLeft = g.prizesLeft ∧ g₁.pend = g.pend ∧ g₁.koMeasure < g.koMeasure) := by
    intro g g₁ hm _ hw₁
    have hp := hm.prizes_eq hw₁
    rcases Nat.eq_zero_or_pos (g.koVal .own + g.koVal .opp) with h0 | h0
    · have hpu : g.promoUp = false := by
        cases e : g.promoUp
        · rfl
        · have := GameState.koVal_pos_of_promoUp e; omega
      exact .inr ⟨by omega, hm.pend_eq_of hpu, hm.koMeasure_lt hw₁⟩
    · exact .inl (by omega)
  have key : ∀ P g, g.prizesLeft = P → ∃ g', Resolve g g' := by
    intro P
    induction P using Nat.strongRecOn with
    | ind P ihP =>
        -- with no trigger pending: batch steps, until a batch takes Prize cards (`ihP`)
        have key₀ : ∀ n g, g.prizesLeft = P → g.koMeasure = n → g.pend = false →
            ∃ g', Resolve g g' := by
          intro n
          induction n using Nat.strongRecOn with
          | ind n ih =>
              intro g hP hn hp
              cases hw : g.winner with
              | some o => exact ⟨g, .done (.inr (by rw [hw]; exact fun e => nomatch e))⟩
              | none =>
                  by_cases hs : Calm g
                  · exact ⟨g, .done (.inl (hs.settled hp))⟩
                  · obtain ⟨g₁, hm⟩ := KOBatch.exists_of hs (.inl hp)
                    cases hw₁ : g₁.winner with
                    | some o =>
                        exact ⟨g₁, .step hw hm (.done (.inr (by rw [hw₁]; exact fun e => nomatch e)))⟩
                    | none =>
                        rcases batch hm hw hw₁ with hlt | ⟨he, hpe, hlt⟩
                        · obtain ⟨g', hr⟩ := ihP _ (hP ▸ hlt) g₁ rfl
                          exact ⟨g', .step hw hm hr⟩
                        · obtain ⟨g', hr⟩ := ih _ (hn ▸ hlt) g₁ (he.trans hP) rfl (hpe.trans hp)
                          exact ⟨g', .step hw hm hr⟩
        -- with one pending (milestone MV7): the triggers first, once both Active Spots are filled
        -- (before that, batch steps), then `key₀`
        intro g hP
        have key₁ : ∀ n g, g.prizesLeft = P → g.koMeasure = n → ∃ g', Resolve g g' := by
          intro n
          induction n using Nat.strongRecOn with
          | ind n ih =>
              intro g hP hn
              cases hw : g.winner with
              | some o => exact ⟨g, .done (.inr (by rw [hw]; exact fun e => nomatch e))⟩
              | none =>
                  by_cases hr : g.pend = true ∧ g.BothActive
                  · obtain ⟨g₁, ho⟩ := hr.2.trigs_exist
                    have z := ho.zoneOnly
                    have hP₁ : g₁.prizesLeft = P := by
                      simp only [GameState.prizesLeft, z.cur_prizes, z.opp_prizes]
                      exact hP
                    obtain ⟨g', hr'⟩ := key₀ _ g₁ hP₁ rfl z.pend
                    exact ⟨g', .trigger hw hr.2 hr.1 ho hr'⟩
                  have hq : g.pend = false ∨ ¬ g.BothActive := by
                    cases hpd : g.pend with
                    | false => exact .inl rfl
                    | true => exact .inr fun hb => hr ⟨hpd, hb⟩
                  by_cases hs : Calm g
                  · have hp : g.pend = false := by
                      rcases hq with h | h
                      · exact h
                      · exact absurd hs.bothActive h
                    exact ⟨g, .done (.inl (hs.settled hp))⟩
                  · obtain ⟨g₁, hm⟩ := KOBatch.exists_of hs hq
                    cases hw₁ : g₁.winner with
                    | some o =>
                        exact ⟨g₁, .step hw hm (.done (.inr (by rw [hw₁]; exact fun e => nomatch e)))⟩
                    | none =>
                        rcases batch hm hw hw₁ with hlt | ⟨he, -, hlt⟩
                        · obtain ⟨g', hr'⟩ := ihP _ (hP ▸ hlt) g₁ rfl
                          exact ⟨g', .step hw hm hr'⟩
                        · obtain ⟨g', hr'⟩ := ih _ (hn ▸ hlt) g₁ (he.trans hP) rfl
                          exact ⟨g', .step hw hm hr'⟩
        exact key₁ _ g hP rfl
  obtain ⟨g', hr⟩ := key _ g rfl
  exact ⟨g', hr, hr.settled_or_won⟩

/-! ## Games without a trigger of one event (milestone MV7c) -/

/-- A card with no triggered Ability of the event `ev` (of its own, or given by it as a Tool). -/
def Card.evFree (ev : TrigEvent) (c : Card) : Bool := c.abilities.all fun ab => ab.use.event != some ev

/-- No card of the game has a triggered Ability of the event `ev` (milestone MV7c). Play keeps it
(`GameState.EvFree.of_perm`). -/
def GameState.EvFree (ev : TrigEvent) (g : GameState) : Prop := ∀ c ∈ g.allCards, c.evFree ev = true

theorem GameState.EvFree.of_perm {ev : TrigEvent} {g g' : GameState} (h : g.EvFree ev)
    (hp : g'.allCards.Perm g.allCards) : g'.EvFree ev :=
  fun c hc => h c (hp.mem_iff.1 hc)

/-- A Pokémon made of cards with no trigger of the event has none. -/
theorem InPlay.trigs_nil_of_evFree {ev : TrigEvent} {p : InPlay}
    (h : ∀ c ∈ p.cardList, c.evFree ev = true) (sp : Spot) : p.trigs ev sp = [] := by
  unfold InPlay.trigs
  refine filter_nil_of fun ab hab => ?_
  have hev : (ab.use.event != some ev) = true := by
    rcases List.mem_append.1 hab with h1 | h1
    · have := h (.pokemon p.top) (.head _)
      simp only [Card.evFree, Card.abilities, List.all_eq_true] at this
      exact this ab h1
    · obtain ⟨c, hc, hab'⟩ := List.mem_flatMap.1 h1
      have := h c (.tail _ (List.mem_append_right _ hc))
      simp only [Card.evFree, List.all_eq_true] at this
      exact this ab (Card.grantAbilities_sub hab')
  simp only [bne] at hev
  simp only [Ability.trigOn]
  revert hev
  cases (ab.use.event == some ev) <;> intro hev
  · rfl
  · cases hev

/-- **With no `movedUp` trigger in the game, the batch Knock Out step keeps the record** (milestone
MV7c; before it, always): the promoted Pokémon owes nothing. -/
theorem KOBatch.pend_eq_of_upFree {g g' : GameState} (h : KOBatch g g')
    (hf : g.EvFree .movedUp) : g'.pend = g.pend := by
  cases h with
  | won => rfl
  | @go ac ao bc bo _ _ hc _ _ =>
      show (g.pend || g.promoFires ac) = g.pend
      have : g.promoFires ac = false := by
        cases ac with
        | none => simp [GameState.promoFires]
        | some x =>
            have hx : g.In .own .active x ∨ g.In .own .bench x := by
              rcases hc.mem.1 x rfl with e | e
              · exact .inl (GameState.koStep_survivor (w := .own) (sp := .active) e).1
              · exact .inr (GameState.koStep_survivor (w := .own) (sp := .bench) e).1
            have hcards : ∀ c ∈ x.cardList, c.evFree .movedUp = true := fun c hcx => by
              rcases hx with e | e
              · exact hf c (GameState.mem_allCards_of_cur_active e hcx)
              · exact hf c (GameState.mem_allCards_of_cur_bench e hcx)
            simp [GameState.promoFires, InPlay.fires, InPlay.trigs_nil_of_evFree hcards]
      rw [this, Bool.or_false]

/-- `KOChain n g g'`: `n` batch Knock Out steps from `g` to `g'`, each taken while the game has no
outcome. -/
inductive KOChain : Nat → GameState → GameState → Prop where
  | refl (g : GameState) : KOChain 0 g g
  | step {n : Nat} {g g₁ g' : GameState} (hn : g.winner = none) (hm : KOBatch g g₁)
      (hr : KOChain n g₁ g') : KOChain (n + 1) g g'

/-- **A bound on the number of batches**: a chain of `n` batch steps from `g` has
`n ≤ koMeasure g + 1` (every step but the last leaves the game without an outcome and lowers the
measure). -/
theorem KOChain.length_le {n : Nat} {g g' : GameState} (h : KOChain n g g') :
    n ≤ g.koMeasure + 1 := by
  induction h with
  | refl => exact Nat.zero_le _
  | @step n g g₁ g' _ hm hr ih =>
      cases hr with
      | refl => exact Nat.succ_le_succ (Nat.zero_le _)
      | step hn₁ _ _ =>
          have := hm.koMeasure_lt hn₁
          omega

/-- A `Resolve` result from a state with no pending trigger is reached by a chain of batch steps.
(Milestone MV7 added the hypothesis `g.pend = false`: from a state with a trigger pending the
resolution is a chain to a state with both Active Spots filled (`BothActive`), the triggers (`Resolve.trigger`), then a chain from their
result, which has none pending. Milestone MV7c added the hypothesis that no card of the game has a
`movedUp` trigger: otherwise a batch that promotes the player to move's Pokémon in their own turn
can set the record, and a resolution of triggers follows; `Resolve.exists` covers that case.) -/
theorem Resolve.chain {g g' : GameState} (h : Resolve g g') (hp : g.pend = false)
    (hf : g.EvFree .movedUp) : ∃ n, KOChain n g g' := by
  induction h with
  | done => exact ⟨0, .refl _⟩
  | step hn hm _ ih =>
      obtain ⟨n, hc⟩ := ih ((hm.pend_eq_of_upFree hf).trans hp) (hf.of_perm hm.perm)
      exact ⟨n + 1, .step hn hm hc⟩
  | trigger _ _ hp' => rw [hp] at hp'; cases hp'

/-- **`Resolve` takes at most `koMeasure g + 1` batches**, from a state with no pending trigger
(hypothesis added by milestone MV7, see `Resolve.chain`). With a trigger pending the bound is
`Resolve.chain_le_pend` (in two parts: no bound in terms of `koMeasure g` alone is proved, since the
triggers' effects can put Pokémon into play and raise `koMeasure`). Milestone MV7c added the
hypothesis `g.EvFree .movedUp` (see `Resolve.chain`). -/
theorem Resolve.chain_le {g g' : GameState} (h : Resolve g g') (hp : g.pend = false)
    (hf : g.EvFree .movedUp) : ∃ n, KOChain n g g' ∧ n ≤ g.koMeasure + 1 := by
  obtain ⟨n, hc⟩ := h.chain hp hf
  exact ⟨n, hc, hc.length_le⟩

/-- **The shape of every resolution** (milestone MV7), in a game with no `movedUp` trigger
(hypothesis added by milestone MV7c): a chain of at most `koMeasure g + 1` batch steps; or such a
chain to a state `g₁` with both Active Spots filled and a trigger pending, the resolution of its owed
triggers (`Owed`; once: nothing sets the record again in such a game), and a chain of at most
`koMeasure g₂ + 1` batch steps from their result `g₂`. So a resolution takes at most
`(koMeasure g + 1) + 1 + (koMeasure g₂ + 1)` steps. No bound in terms of `koMeasure g` alone is
proved: the triggers' effects can put Pokémon into play, which raises `koMeasure`. From a state
with both Active Spots filled the first chain is empty (`Resolve.trigger_first`). With a `movedUp`
trigger in the game, a batch can promote the player to move's Pokémon in their own turn and set the
record again; every resolution still ends (`Resolve.exists`: each such batch takes a Prize card),
but this shape is not claimed. -/
theorem Resolve.chain_le_pend {g g' : GameState} (h : Resolve g g') (hf : g.EvFree .movedUp) :
    (∃ n, KOChain n g g' ∧ n ≤ g.koMeasure + 1) ∨
      ∃ n₁ g₁ g₂ n₂, KOChain n₁ g g₁ ∧ n₁ ≤ g.koMeasure + 1 ∧ g₁.winner = none ∧
        g₁.BothActive ∧ g₁.pend = true ∧ Owed g₁ g₂ ∧ KOChain n₂ g₂ g' ∧
        n₂ ≤ g₂.koMeasure + 1 := by
  induction h with
  | done => exact .inl ⟨0, .refl _, Nat.zero_le _⟩
  | step hn hm _ ih =>
      rcases ih (hf.of_perm hm.perm) with ⟨n, hc, -⟩ | ⟨n₁, g₁, g₂, n₂, hc, -, h1, h2, h3, h4, h5, h6⟩
      · exact .inl ⟨n + 1, .step hn hm hc, (KOChain.step hn hm hc).length_le⟩
      · exact .inr ⟨n₁ + 1, g₁, g₂, n₂, .step hn hm hc, (KOChain.step hn hm hc).length_le,
          h1, h2, h3, h4, h5, h6⟩
  | @trigger g g₁ g' hn hb hp ho hr _ =>
      obtain ⟨n, hc, hle⟩ := hr.chain_le ho.zoneOnly.pend
        (hf.of_perm (ho.perm.trans (.of_eq (GameState.allCards_unpend _))))
      exact .inr ⟨0, g, g₁, n, .refl _, Nat.zero_le _, hn, hb, hp, ho, hc, hle⟩

/-- **A pending trigger resolves first** (milestone MV7): from a state with both Active Spots filled,
a trigger pending and no outcome, every resolution begins with the owed triggers (no batch Knock Out
step comes before them: `KOBatch` needs no trigger ready), then, in a game with no `movedUp` trigger
(hypothesis added by milestone MV7c), at most `koMeasure g₂ + 1` batch steps from their result
`g₂`. So inside a Trainer, Stadium or Ability effect the triggers raised by a step see the Pokémon
in play as that step left them. -/
theorem Resolve.trigger_first {g g' : GameState} (h : Resolve g g') (hb : g.BothActive)
    (hp : g.pend = true) (hn : g.winner = none) (hf : g.EvFree .movedUp) :
    ∃ g₂ n, Owed g g₂ ∧ KOChain n g₂ g' ∧ n ≤ g₂.koMeasure + 1 := by
  cases h with
  | done h =>
      rcases h with hs | hw
      · rw [hs.2.2.2] at hp; cases hp
      · exact absurd hn hw
  | step _ hm _ =>
      rcases hm.not_ready with hq | hq
      · rw [hq] at hp; cases hp
      · exact absurd hb hq
  | trigger _ _ _ ho hr =>
      obtain ⟨n, hc, hle⟩ := hr.chain_le ho.zoneOnly.pend
        (hf.of_perm (ho.perm.trans (.of_eq (GameState.allCards_unpend _))))
      exact ⟨_, n, ho, hc, hle⟩

/-! ## With triggers (milestone M8b)

Since milestone M8b the batch move (`Move.knockOuts`) ends with the `koByAttack` triggers of the
opponent's Pokémon it Knocked Out after the turn's attack (`Fire`). A trigger's effect can put
Pokémon into play (`putBench`) and damage counters on any Active Pokémon, so it can raise
`koMeasure` and cause further Knock Outs: a chain batch → trigger → Knock Out → batch → trigger …
Every such chain ends, by a lexicographic measure: the Prize cards left (both players), then
`koMeasure`.

* A batch that Knocks Out some Pokémon and leaves the game going takes Prize cards: each Knocked Out
  Pokémon is worth at least one, and a player who would take as many as they have left has won
  (`KOBatch.prizes_lt`). Triggers move no Prize card (`Fire.zoneOnly`). So the Prize cards left fall.
* A batch that Knocks Out nothing fires no trigger (`GameState.koTrigs_of_koVal`) and fills an empty
  Active Spot, so `koMeasure` falls (`KOBatch.koMeasure_lt`) and the Prize cards stay.

Nothing returns a Prize card in the model, so the triggers of one game fire on at most as many
Knock Outs as there are Prize cards left plus the Knock Outs of the last check. The bound rests on
every Knock Out giving a Prize card: the printed effects "your opponent takes 1 fewer Prize card",
"can't take any Prize cards for it" (Shedinja, Lillie's Pearl, Munkidori ex, Mega Gengar ex,
Legendary Summit; survey S12) are not in the model; with them a Knock Out trigger that puts its own
card back into play and damages it could repeat with no Prize card taken. -/

/-- A check that Knocks Out none of the opponent's Pokémon fires no trigger. -/
theorem GameState.koTrigs_of_koVal {g : GameState} (h : g.koVal .opp = 0) : g.koTrigs = [] := by
  have hz := g.koVal_eq_zero h
  have h1 : optFilter (g.koT .opp .active) g.opp.active = none := by
    cases ha : g.opp.active with
    | none => rfl
    | some p =>
        have : g.koT .opp .active p = false := by
          simpa [GameState.koT] using hz .active p ha
        simp only [optFilter, this, Bool.false_eq_true, ite_false]
  have h2 : g.opp.bench.filter (g.koT .opp .bench) = [] :=
    filter_nil_of fun p hp => by simpa [GameState.koT] using hz .bench p hp
  unfold GameState.koTrigs
  rw [h1, h2]; rfl

/-- A step of the repeated check with its triggers: the batch move (`Move.knockOuts`) taken while
the game has no outcome. -/
def KOMove (g g' : GameState) : Prop :=
  g.winner = none ∧ ∃ g₁ l, KOBatch g g₁ ∧ l.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack l g₁ g'

/-- **The measure falls**: a step of the repeated check that leaves the game going lowers the Prize
cards left, or keeps them and lowers `koMeasure`. -/
theorem KOMove.lt {g g' : GameState} (h : KOMove g g') (hw : g'.winner = none) :
    g'.prizesLeft < g.prizesLeft ∨
      (g'.prizesLeft = g.prizesLeft ∧ g'.koMeasure < g.koMeasure) := by
  obtain ⟨-, g₁, l, hb, hl, ht⟩ := h
  have z := ht.zoneOnly
  have hw₁ : g₁.winner = none := z.winner.symm.trans hw
  have hp := hb.prizes_eq hw₁
  have ep : g'.prizesLeft = g₁.prizesLeft := by
    simp only [GameState.prizesLeft, z.cur_prizes, z.opp_prizes]
  rcases Nat.eq_zero_or_pos (g.koVal .own + g.koVal .opp) with h0 | h0
  · have hn : g.batchTrigs g₁ = [] := by
      unfold GameState.batchTrigs
      rw [GameState.koTrigs_of_koVal (by omega)]
      split <;> rfl
    have e := Move.eq_of_batchTrigs_nil hl ht hn
    subst e
    exact .inr ⟨by omega, hb.koMeasure_lt hw⟩
  · exact .inl (by omega)

/-- **Every chain of batch moves with their triggers is finite** (milestone M8b): no infinite
sequence of `Move.knockOuts`, each taken while the game has no outcome, starts from `g`. -/
theorem KOMove.acc (g : GameState) : Acc (fun b a => KOMove a b) g := by
  have key : ∀ P n g, g.prizesLeft = P → g.koMeasure = n → g.winner = none →
      Acc (fun b a => KOMove a b) g := by
    intro P
    induction P using Nat.strongRecOn with
    | ind P ihP =>
        intro n
        induction n using Nat.strongRecOn with
        | ind n ihn =>
            intro g hP hn _
            refine Acc.intro g fun g' hm => ?_
            cases hw : g'.winner with
            | some o => exact Acc.intro g' fun _ ⟨hn', _⟩ => by rw [hw] at hn'; cases hn'
            | none =>
                rcases hm.lt hw with h | ⟨h1, h2⟩
                · exact ihP _ (hP ▸ h) _ g' rfl rfl hw
                · exact ihn _ (hn ▸ h2) g' (h1.trans hP) rfl hw
  cases hw : g.winner with
  | none => exact key _ _ g rfl rfl hw
  | some o => exact Acc.intro g fun _ ⟨hn', _⟩ => by rw [hw] at hn'; cases hn'

/-- A step of the repeated check that takes no Prize card keeps the pending-trigger record
(milestone MV7c): it Knocks Out nothing, so it promotes no Pokémon of the player to move after a
Knock Out of their Active Pokémon. -/
theorem KOMove.pend_of_prizes {g g' : GameState} (h : KOMove g g') (hw : g'.winner = none)
    (he : g'.prizesLeft = g.prizesLeft) : g'.pend = g.pend := by
  obtain ⟨-, g₁, l, hb, -, ht⟩ := h
  have z := ht.zoneOnly
  have hw₁ : g₁.winner = none := z.winner.symm.trans hw
  have hp := hb.prizes_eq hw₁
  have ep : g'.prizesLeft = g₁.prizesLeft := by
    simp only [GameState.prizesLeft, z.cur_prizes, z.opp_prizes]
  have hpu : g.promoUp = false := by
    cases e : g.promoUp
    · rfl
    · have := GameState.koVal_pos_of_promoUp e; omega
  exact z.pend.trans (hb.pend_eq_of hpu)

/-- **The repeated Knock Out check with its triggers ends, for play** (milestone M8b): there is no
infinite sequence of moves through states that are not `Settled` (from such a state the only moves
are the batch move with its triggers and, since milestone MV7, the resolution of pending triggers,
`Move.batch_of_not_settled`). The measure is the Prize cards left, then the record, then
`koMeasure` (milestone MV7c; before it, the record first, which no batch set): a batch move that
Knocks Out a Pokémon takes Prize cards (and since milestone MV7c it may set the record, when it
promotes the player to move's Pokémon in their own turn); one that Knocks Out none keeps the Prize
cards and the record and lowers `koMeasure`; the resolution of the triggers keeps the Prize cards and
clears the record, and no trigger sets it. So a chain of Knock Outs and triggers started by one move
(an attack's Knock Outs, and the Knock Outs the `koByAttack` triggers cause) ends in a `Settled`
state or with an outcome. -/
theorem Move.unsettled_acc (g : GameState) :
    Acc (fun b a => ¬ Settled a ∧ a.winner = none ∧ Move a b) g := by
  have fin : ∀ g : GameState, g.winner ≠ none →
      Acc (fun b a => ¬ Settled a ∧ a.winner = none ∧ Move a b) g :=
    fun g hw => Acc.intro g fun _ ⟨_, hn, _⟩ => absurd hn hw
  have key : ∀ P g, g.prizesLeft = P → Acc (fun b a => ¬ Settled a ∧ a.winner = none ∧ Move a b) g := by
    intro P
    induction P using Nat.strongRecOn with
    | ind P ihP =>
        -- with no trigger pending, only batch moves follow
        have k₀ : ∀ n g, g.prizesLeft = P → g.koMeasure = n → g.pend = false →
            Acc (fun b a => ¬ Settled a ∧ a.winner = none ∧ Move a b) g := by
          intro n
          induction n using Nat.strongRecOn with
          | ind n ih =>
              intro g hP hn hp
              refine Acc.intro g fun g' ⟨hu, hw, hm⟩ => ?_
              rcases hm.batch_of_not_settled hu with ⟨g₁, l, hb, hl, ht⟩ | ⟨-, hp', -⟩
              · have hk : KOMove g g' := ⟨hw, g₁, l, hb, hl, ht⟩
                cases hw' : g'.winner with
                | some o => exact fin g' (by rw [hw']; exact fun e => nomatch e)
                | none =>
                    rcases hk.lt hw' with h | ⟨h1, h2⟩
                    · exact ihP _ (hP ▸ h) g' rfl
                    · exact ih _ (hn ▸ h2) g' (h1.trans hP) rfl
                        ((hk.pend_of_prizes hw' h1).trans hp)
              · rw [hp] at hp'; cases hp'
        -- with one pending: batch moves, or its resolution, which clears it
        have k₁ : ∀ n g, g.prizesLeft = P → g.koMeasure = n →
            Acc (fun b a => ¬ Settled a ∧ a.winner = none ∧ Move a b) g := by
          intro n
          induction n using Nat.strongRecOn with
          | ind n ih =>
              intro g hP hn
              refine Acc.intro g fun g' ⟨hu, hw, hm⟩ => ?_
              rcases hm.batch_of_not_settled hu with ⟨g₁, l, hb, hl, ht⟩ | ⟨-, -, ho⟩
              · have hk : KOMove g g' := ⟨hw, g₁, l, hb, hl, ht⟩
                cases hw' : g'.winner with
                | some o => exact fin g' (by rw [hw']; exact fun e => nomatch e)
                | none =>
                    rcases hk.lt hw' with h | ⟨h1, h2⟩
                    · exact ihP _ (hP ▸ h) g' rfl
                    · exact ih _ (hn ▸ h2) g' (h1.trans hP) rfl
              · have z := ho.zoneOnly
                have hP' : g'.prizesLeft = P := by
                  simp only [GameState.prizesLeft, z.cur_prizes, z.opp_prizes]
                  exact hP
                exact k₀ _ g' hP' rfl z.pend
        exact fun g hP => k₁ _ g hP rfl
  exact key _ g rfl

end Pokemon
