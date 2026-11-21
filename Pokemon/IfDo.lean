import Pokemon.Ignore

/-!
# "If you do" and "for each … in this way" (milestone MV3, stage 2)

Survey S15 §2: 81 refused Standard cards make an effect depend on whether, or how many times, an
earlier optional or partial action of the same text happened. The commonest shapes need no new
primitive and no record of what happened: the consequence reads the branch the resolution took.

* "You may A. If you do, B." is `Effect.mayDo a b = choice (seq a b) skip` (`Run.mayDo_iff`:
  either nothing, or A and then B on the state A left). Dondozo ex sv10-66: "You may do 120 more
  damage. If you do, this Pokémon also does 50 damage to itself."
* "A. If you do, B.", where A must be done when it can be, is `Effect.ifDone t a b =
  ite t (seq a b) skip`, with `t` a test that A can be done (`Run.ifDone_iff`). It is exact when A
  has a resolution exactly when `t` holds: an `exactly n` cost on a zone whose count `t` reads
  ("Discard a card from your hand. If you do, draw 2 cards", Klefki sv8-128: `t = countGe (pile own
  hand any) 1`), a switch with a nonempty Bench (`t` on `Count.bench`). "If you can't, this attack
  does nothing" (Decidueye sv6pt5-5, Lurantis sv10-14) is the same form with the rest of the attack
  as B.
* "Discard up to N … and this attack does K damage for each card you discarded in this way" is
  `Effect.forUpTo f N`, the choice of `f i` for some `i ≤ N` (`Run.forUpTo_iff`), with
  `f i = seq (discardEnergy … (exactly i)) (damage (const (K * i)))`: the number of cards discarded
  is the branch index, so the amount reads it without a log. For a printed "any amount" (2026
  rulebook p. 20: "you can choose 0") the bound N is the most cards the cost can take: a cost of
  `exactly i` Energy from the Active Pokémon has no resolution beyond the Energy attached
  (`discardActive_le`), so `forUpTo f N` is exact as soon as N is at least that
  (`forUpTo_complete`); a legal deck has at most 60 cards (2026 rulebook p. 21).

These are derived forms: every function on effects (`hitFree`, `oneHit`, `switchSafe`, `trigOk`,
`tame`, `tmax`, the clauses of `Faithful`, `LoopFree`, `RecycleSafe`'s writers and recyclers) reads
them through their `choice`, `seq`, `ite` and `skip`, so no theorem needed a new case. A predicate
that treats `choice` as a conjunction holds of `forUpTo f N` when it holds of every branch
(`forUpTo_all`); a consequence that recycles or writes a modifier is a branch like any other and is
counted. In a Trainer effect (`TRun`) the Knock Out check runs between A and B, as between any two
steps, and a finished game stops the effect before B (`TRun.mayDo_iff` is stated for `TRun` too).

Not implemented (Known gaps): "If you attached Energy in this way" and "If you put any Pokémon onto
your Bench in this way" (7 cards): `attach` and `putBench` may always do nothing in the model, so
a consequence written after them could follow an attachment that did not happen; "If you healed
any damage in this way … that Pokémon" (3); "for each different type revealed" (1).

Witnesses: `klefki_draws` (the consequence happens: a legal attack discards one card and draws
two) and `klefki_empty` (the consequence does not happen: with an empty hand the same attack is a
legal move, and every resolution of its effect changes nothing).
-/

namespace Pokemon

/-- "You may A. If you do, B." -/
def Effect.mayDo (a b : Effect) : Effect := .choice (.seq a b) .skip

/-- "A. If you do, B.", where `t` says that A can be done. -/
def Effect.ifDone (t : Test) (a b : Effect) : Effect := .ite t (.seq a b) .skip

/-- `f i` for some `i ≤ n`: "for each card … in this way", the number chosen being the branch. -/
def Effect.forUpTo (f : Nat → Effect) : Nat → Effect
  | 0 => f 0
  | n + 1 => .choice (Effect.forUpTo f n) (f (n + 1))

/-! ## Inversion of the combinators -/

theorem Run.skip_inv {g g' : GameState} (h : Run .skip g g') : g' = g := by
  cases h with
  | skip => rfl
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw

theorem Run.seq_inv {a b : Effect} {g g' : GameState} (h : Run (.seq a b) g g') :
    ∃ g₁, Run a g g₁ ∧ Run b g₁ g' := by
  cases h with
  | seq h₁ h₂ => exact ⟨_, h₁, h₂⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw

theorem Run.choice_inv {a b : Effect} {g g' : GameState} (h : Run (.choice a b) g g') :
    Run a g g' ∨ Run b g g' := by
  cases h with
  | choiceL h => exact .inl h
  | choiceR h => exact .inr h
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw

theorem Run.ite_inv {t : Test} {a b : Effect} {g g' : GameState} (h : Run (.ite t a b) g g') :
    ∃ p, g.activeOf t.whose = some p ∧
      ((t.eval g p = true ∧ Run a g g') ∨ (t.eval g p = false ∧ Run b g g')) := by
  cases h with
  | iteT hp ht h => exact ⟨_, hp, .inl ⟨ht, h⟩⟩
  | iteF hp ht h => exact ⟨_, hp, .inr ⟨ht, h⟩⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw

/-- **"You may A. If you do, B."**: nothing, or A and then B. -/
theorem Run.mayDo_iff {a b : Effect} {g g' : GameState} :
    Run (Effect.mayDo a b) g g' ↔ g' = g ∨ ∃ g₁, Run a g g₁ ∧ Run b g₁ g' := by
  constructor
  · intro h
    rcases Run.choice_inv h with h | h
    · exact .inr (Run.seq_inv h)
    · exact .inl (Run.skip_inv h)
  · rintro (rfl | ⟨g₁, h₁, h₂⟩)
    · exact .choiceR (.skip _)
    · exact .choiceL (.seq h₁ h₂)

/-- **"A. If you do, B."**: when the test holds, A and then B; when it fails, nothing. -/
theorem Run.ifDone_iff {t : Test} {a b : Effect} {g g' : GameState} :
    Run (Effect.ifDone t a b) g g' ↔ ∃ p, g.activeOf t.whose = some p ∧
      ((t.eval g p = true ∧ ∃ g₁, Run a g g₁ ∧ Run b g₁ g') ∨ (t.eval g p = false ∧ g' = g)) := by
  constructor
  · intro h
    obtain ⟨p, hp, ⟨ht, h⟩ | ⟨ht, h⟩⟩ := Run.ite_inv h
    · exact ⟨p, hp, .inl ⟨ht, Run.seq_inv h⟩⟩
    · exact ⟨p, hp, .inr ⟨ht, Run.skip_inv h⟩⟩
  · rintro ⟨p, hp, ⟨ht, g₁, h₁, h₂⟩ | ⟨ht, rfl⟩⟩
    · exact .iteT hp ht (.seq h₁ h₂)
    · exact .iteF hp ht (.skip _)

/-- **"For each … in this way"**: a resolution of `forUpTo f n` is a resolution of `f i` for some
`i ≤ n`, and every such resolution is one. -/
theorem Run.forUpTo_iff {f : Nat → Effect} {g g' : GameState} : ∀ {n : Nat},
    Run (Effect.forUpTo f n) g g' ↔ ∃ i, i ≤ n ∧ Run (f i) g g'
  | 0 => ⟨fun h => ⟨0, Nat.le_refl _, h⟩, fun ⟨i, hi, h⟩ => by
      rw [Nat.le_zero.1 hi] at h; exact h⟩
  | n + 1 => by
      constructor
      · intro h
        rcases Run.choice_inv h with h | h
        · obtain ⟨i, hi, h⟩ := (Run.forUpTo_iff (n := n)).1 h
          exact ⟨i, Nat.le_succ_of_le hi, h⟩
        · exact ⟨n + 1, Nat.le_refl _, h⟩
      · rintro ⟨i, hi, h⟩
        rcases Nat.lt_or_ge i (n + 1) with hl | hl
        · exact .choiceL ((Run.forUpTo_iff (n := n)).2 ⟨i, Nat.le_of_lt_succ hl, h⟩)
        · rw [Nat.le_antisymm hi hl] at h; exact .choiceR h

/-- `forUpTo f n` is exact for an unbounded "any amount" once `n` covers every `i` for which
`f i` has a resolution. -/
theorem Run.forUpTo_complete {f : Nat → Effect} {g g' : GameState} {n i : Nat}
    (hb : ∀ j g₁, Run (f j) g g₁ → j ≤ n) (h : Run (f i) g g') : Run (Effect.forUpTo f n) g g' :=
  Run.forUpTo_iff.2 ⟨i, hb i g' h, h⟩

/-- The same three forms under the Trainer semantics (`TRun`), with Knock Outs between steps. -/
theorem TRun.mayDo_iff {a b : Effect} {g g' : GameState} :
    TRun (Effect.mayDo a b) g g' ↔ TRun .skip g g' ∨ ∃ g₁, TRun a g g₁ ∧ TRun b g₁ g' := by
  constructor
  · intro h
    cases h with
    | prim he => cases he
    | stop hn => exact .inl (.stop hn)
    | choiceL h =>
        cases h with
        | prim he => cases he
        | stop hn => exact .inr ⟨_, .stop hn, .stop hn⟩
        | seq h₁ h₂ => exact .inr ⟨_, h₁, h₂⟩
    | choiceR h => exact .inl h
  · rintro (h | ⟨g₁, h₁, h₂⟩)
    · exact .choiceR h
    · exact .choiceL (.seq h₁ h₂)

theorem TRun.forUpTo_iff {f : Nat → Effect} {g g' : GameState} (hn : g.winner = none) :
    ∀ {n : Nat}, TRun (Effect.forUpTo f n) g g' ↔ ∃ i, i ≤ n ∧ TRun (f i) g g'
  | 0 => ⟨fun h => ⟨0, Nat.le_refl _, h⟩, fun ⟨i, hi, h⟩ => by
      rw [Nat.le_zero.1 hi] at h; exact h⟩
  | n + 1 => by
      constructor
      · intro h
        cases h with
        | prim he => cases he
        | stop hw => exact absurd hn hw
        | choiceL h =>
            obtain ⟨i, hi, h⟩ := (TRun.forUpTo_iff hn (n := n)).1 h
            exact ⟨i, Nat.le_succ_of_le hi, h⟩
        | choiceR h => exact ⟨n + 1, Nat.le_refl _, h⟩
      · rintro ⟨i, hi, h⟩
        rcases Nat.lt_or_ge i (n + 1) with hl | hl
        · exact .choiceL ((TRun.forUpTo_iff hn (n := n)).2 ⟨i, Nat.le_of_lt_succ hl, h⟩)
        · rw [Nat.le_antisymm hi hl] at h; exact .choiceR h

/-- A predicate on effects that reads `choice` as a conjunction (`hitFree`, `oneHit`, `switchSafe`,
`trigOk`, `tame`, `benchHitFree`, `ownFree`) holds of `forUpTo f n` when it holds of each branch. -/
theorem Effect.forUpTo_all {P : Effect → Bool} (hP : ∀ a b, P (.choice a b) = (P a && P b))
    {f : Nat → Effect} : ∀ {n : Nat}, (∀ i, i ≤ n → P (f i) = true) → P (Effect.forUpTo f n) = true
  | 0, h => h 0 (Nat.le_refl _)
  | n + 1, h => by
      rw [Effect.forUpTo, hP, Effect.forUpTo_all hP (fun i hi => h i (Nat.le_succ_of_le hi)),
        h (n + 1) (Nat.le_refl _), Bool.and_self]

/-- The cards taken by a split are at most the cards split. -/
theorem Split.taken_le {f : Filter} {l t r : List Card} (h : Split f l t r) :
    t.length ≤ l.length := by
  induction h with
  | nil => exact Nat.le_refl _
  | take _ _ ih => simp only [List.length_cons]; omega
  | keep _ ih => simp only [List.length_cons]; omega

/-- An `exactly i` discard of Energy from the `w` player's Active Pokémon has a resolution only if
at least `i` Energy cards are attached: so "discard any amount" is covered by `forUpTo` up to the
Energy attached. -/
theorem discardActive_le {w : Whose} {f : Filter} {i : Nat} {g g' : GameState}
    (h : Run (.discardEnergy w .active f (.exactly i)) g g') :
    ∃ a, (g.side w).active = some a ∧ i ≤ a.energy.length := by
  cases h with
  | zone hw hz =>
      simp only [Effect.zSide, Option.some.injEq] at hw
      subst hw
      cases hz with
      | discardActive ha hs hq =>
          refine ⟨_, ha, ?_⟩
          simp only [Qty.ok] at hq
          rw [← hq]
          exact Split.taken_le hs
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

namespace IfDo

open Trainer InPlayTests

/-- Klefki sv8-128, Stick 'n' Draw: "Discard a card from your hand. If you do, draw 2 cards." -/
def stickDraw : Attack :=
  ⟨"Stick 'n' Draw", [], 0, .ifDone (.countGe (.pile .own .hand .any) 1)
    (.move .own .hand .discard .any (.exactly 1)) (.move .own (.top 2) .hand .any .all), false⟩

def klefki : PokemonCard := ⟨"Klefki", .basic, none, 7, .psychic, [stickDraw], 1, none, none,
  .none, false, []⟩

/-- The player has `hand` and a deck of two cards; the opponent `big`. -/
def start (hand : List Card) : GameState :=
  ⟨{ side hand [.energy .fire] (InPlay.ofBasic klefki) [] with
      deck := [.energy .grass, .energy .water] },
    side [] [.energy .fire] (InPlay.ofBasic big) [], true, false, false, false, none, none, false,
    false⟩

theorem start_wellFormed (hand : List Card) : WellFormed (start hand) := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_⟩ <;>
    intro p hp <;> cases hp

theorem start_settled_draws : Settled (start [.energy .fire]) :=
  (GameState.settled_iff _).2 (by decide)

theorem start_settled_empty : Settled (start []) := (GameState.settled_iff _).2 (by decide)

/-- **Witness: the consequence happens.** With one card in hand, the attack is a legal move from a
well-formed, `Settled` state; the card is discarded and two are drawn. -/
theorem klefki_draws :
    WellFormed (start [.energy .fire]) ∧ Settled (start [.energy .fire]) ∧
      ∃ g, Move (start [.energy .fire]) g ∧ g.cur.hand = [.energy .grass, .energy .water] ∧
        g.cur.discard = [.energy .fire] := by
  have hr : Run stickDraw.script (start [.energy .fire]) _ :=
    .iteT (p := InPlay.ofBasic klefki) rfl (by decide)
      (.seq (.zone rfl (.move (.take rfl .nil) rfl (.discard _ _)))
        (.zone rfl (.move (.take rfl (.take rfl .nil)) (fun _ h => nomatch h) (.hand _ _))))
  exact ⟨start_wellFormed _, start_settled_draws, _,
    .attack (atk := stickDraw) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled_draws hr rfl
      (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _), rfl, rfl⟩

/-- **Witness: the consequence does not happen.** With an empty hand the attack is still a legal
move, and every resolution of its effect leaves the state as it was: nothing is drawn. -/
theorem klefki_empty :
    WellFormed (start []) ∧ Settled (start []) ∧
      (∃ g, Move (start []) g ∧ g.cur.hand = []) ∧
      ∀ g', Run stickDraw.script (start []) g' → g' = start [] := by
  have hr : Run stickDraw.script (start []) (start []) :=
    .iteF (p := InPlay.ofBasic klefki) rfl (by decide) (.skip _)
  refine ⟨start_wellFormed _, start_settled_empty, ⟨_,
    .attack (atk := stickDraw) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled_empty hr rfl
      (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩, ?_⟩
  intro g' h
  obtain ⟨p, hp, ⟨ht, -⟩ | ⟨-, e⟩⟩ := Run.ifDone_iff.1 h
  · cases hp; exact absurd ht (by decide)
  · exact e

end IfDo

end Pokemon
