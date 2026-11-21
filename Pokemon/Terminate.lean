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
* `KOChain`, `Resolve.chain`, `KOChain.length_le`: a `Resolve` result is reached by a chain of at
  most `koMeasure g + 1` batches.

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

/-- A state that is not `Settled` has a pending Knock Out (some Prize value to take) or an empty
Active Spot. -/
theorem koVal_pos_or_empty {g : GameState} (hu : ¬ Settled g) :
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
            have hs : Settled g :=
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
`Settled` (`koVal_pos_or_empty`). -/
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
        GameState.withPlay]
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

/-- **Every state can be resolved.** From every state some `Resolve` result exists, and every such
result is `Settled` or has an outcome. So `Resolve` never gets stuck and every primitive step of a
Trainer effect can be followed by its Knock Outs (`TRun.prim`). -/
theorem Resolve.exists (g : GameState) :
    ∃ g', Resolve g g' ∧ (Settled g' ∨ g'.winner ≠ none) := by
  have key : ∀ n g, g.koMeasure = n → ∃ g', Resolve g g' := by
    intro n
    induction n using Nat.strongRecOn with
    | ind n ih =>
        intro g hn
        cases hw : g.winner with
        | some o => exact ⟨g, .done (.inr (by rw [hw]; exact fun e => nomatch e))⟩
        | none =>
            by_cases hs : Settled g
            · exact ⟨g, .done (.inl hs)⟩
            · obtain ⟨g₁, hm⟩ := KOBatch.exists_of hs
              cases hw₁ : g₁.winner with
              | some o =>
                  exact ⟨g₁, .step hw hm (.done (.inr (by rw [hw₁]; exact fun e => nomatch e)))⟩
              | none =>
                  obtain ⟨g', hr⟩ := ih _ (hn ▸ hm.koMeasure_lt hw₁) g₁ rfl
                  exact ⟨g', .step hw hm hr⟩
  obtain ⟨g', hr⟩ := key _ g rfl
  exact ⟨g', hr, hr.settled_or_won⟩

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

/-- A `Resolve` result is reached by a chain of batch steps. -/
theorem Resolve.chain {g g' : GameState} (h : Resolve g g') : ∃ n, KOChain n g g' := by
  induction h with
  | done => exact ⟨0, .refl _⟩
  | step hn hm _ ih =>
      obtain ⟨n, hc⟩ := ih
      exact ⟨n + 1, .step hn hm hc⟩

/-- **`Resolve` takes at most `koMeasure g + 1` batches.** -/
theorem Resolve.chain_le {g g' : GameState} (h : Resolve g g') :
    ∃ n, KOChain n g g' ∧ n ≤ g.koMeasure + 1 := by
  obtain ⟨n, hc⟩ := h.chain
  exact ⟨n, hc, hc.length_le⟩

end Pokemon
