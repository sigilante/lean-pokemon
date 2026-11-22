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
  has a resolution exactly when `t` holds (`Run.ifDone_exact`): proved for an `exactly n` discard
  from the hand with `t` the count of the hand ("Discard a card from your hand. If you do, draw 2
  cards", Klefki sv8-128: `t = countGe (pile own hand any) 1`; `Run.ifDone_discardHand`) and for an
  `exactly n` discard of Energy from the Active Pokémon with `t` the count of its Energy
  (`Run.ifDone_discardActive`). For other A the importer must choose the test; a switch with `t`
  on `Count.bench` is not covered by `Run.ifDone_exact` (`switch` also resolves, doing nothing, on
  an empty Bench, so there the test, failing, is what keeps B from following). "If you can't, this
  attack does nothing" (Decidueye sv6pt5-5, Lurantis sv10-14) is the same form with the rest of
  the attack as B. "You may A. If you do, B" is exact only if no resolution of A leaves the state
  as it was (`Run.mayDo_exact`; the section "When the derived forms are exact" lists the
  primitives that can resolve doing nothing).
* "Discard up to N … and this attack does K damage for each card you discarded in this way" is
  `Effect.forUpTo f N`, the choice of `f i` for some `i ≤ N` (`Run.forUpTo_iff`), with
  `f i = seq (discardEnergy … (exactly i)) (damage (const (K * i)))`: the number of cards discarded
  is the branch index, so the amount reads it without a log. For a printed "any amount" (2026
  rulebook p. 21: "you can choose 0") the bound N is the most cards the cost can take: a cost of
  `exactly i` Energy from the Active Pokémon has no resolution beyond the Energy attached
  (`discardActive_le`), so `forUpTo f N` is exact as soon as N is at least that
  (`forUpTo_complete`, whose hypothesis is discharged per card; `Run.forUpTo_discardActive` does it
  for a discard of Energy from the Active Pokémon); a legal deck has exactly 60 cards (2026
  rulebook p. 22), but the model does not require legal decks.

These are derived forms: every function on effects (`hitFree`, `oneHit`, `switchSafe`, `trigOk`,
`tame`, `tmax`, the clauses of `StoreSafe`, `LoopFree`, `RecycleSafe`'s writers and recyclers) reads
them through their `choice`, `seq`, `ite` and `skip`, so no theorem needed a new case. A predicate
that treats `choice` as a conjunction holds of `forUpTo f N` when it holds of every branch
(`forUpTo_all`); a consequence that recycles or writes a modifier is a branch like any other and is
counted. In a Trainer effect (`TRun`) the Knock Out check runs between A and B, as between any two
steps, and a finished game stops the effect before B (`TRun.mayDo_iff`, `TRun.ifDone_iff`,
`TRun.forUpTo_iff`; the exactness lemmas of the last section are stated for `Run` only).

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

/-- "You may A. If you do, B." under the Trainer semantics (`TRun`), with Knock Outs between steps.
The first disjunct, "nothing", is `TRun .skip g g'`, not `g' = g`: from a finished game it is
`g' = g` (`TRun.stop`); otherwise it is the Knock Out step `Resolve g g'` after the empty step,
which is `g' = g` when `g` is `Settled`. -/
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

/-- **"A. If you do, B." under the Trainer semantics** (`TRun`): the analogue of `Run.ifDone_iff`.
A finished game is left as it is (`TRun.stop`); otherwise the test is made on the Active Pokémon
it reads, and either it holds and A then B resolve, or it fails and the empty step resolves (with
its Knock Out step, as in `TRun.mayDo_iff`). -/
theorem TRun.ifDone_iff {t : Test} {a b : Effect} {g g' : GameState} :
    TRun (Effect.ifDone t a b) g g' ↔ (g.winner ≠ none ∧ g' = g) ∨
      (g.winner = none ∧ ∃ p, g.activeOf t.whose = some p ∧
        ((t.eval g p = true ∧ ∃ g₁, TRun a g g₁ ∧ TRun b g₁ g') ∨
          (t.eval g p = false ∧ TRun .skip g g'))) := by
  constructor
  · intro h
    cases h with
    | prim he => cases he
    | stop hn => exact .inl ⟨hn, rfl⟩
    | iteT hn hp ht h =>
        cases h with
        | prim he => cases he
        | stop hw => exact absurd hn hw
        | seq h₁ h₂ => exact .inr ⟨hn, _, hp, .inl ⟨ht, _, h₁, h₂⟩⟩
    | iteF hn hp ht h => exact .inr ⟨hn, _, hp, .inr ⟨ht, h⟩⟩
  · rintro (⟨hn, rfl⟩ | ⟨hn, p, hp, ⟨ht, g₁, h₁, h₂⟩ | ⟨ht, h⟩⟩)
    · exact .stop hn
    · exact .iteT hn hp ht (.seq h₁ h₂)
    · exact .iteF hn hp ht h

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

/-! ## When the derived forms are exact

`Run.ifDone_iff`, `Run.mayDo_iff` and `Run.forUpTo_iff` say what the forms resolve to; whether that
is the printed text depends on A.

* `mayDo A B` reads "if you do" as "if the branch that does A was taken". That is the printed
  sentence only if every resolution of A does something: otherwise B can follow a resolution of A
  that changed nothing. Primitives with a resolution that changes nothing (from the `Run` and
  `ZStep` rules): always `skip`, `iter` (zero rounds), `attach` (`attachNone`), `putBench`
  (`putBenchNone`), `moveEnergy` (`moveNone`), a `move` or `discardEnergy` with `upTo n` (taking
  no card) or `exactly 0`; in some states `draw` (empty deck, `drawEmpty`), `drawTo` (hand already
  full enough), `move … .all` (no card passes), `discardEnergy`, `discardTools`, `benchCounters`,
  `benchDamage`, `benchHeal` and `switch` on an empty Bench (`discardNone`, `toolsNone`, the
  `…None` rules), `spreadCounters`, `spreadDamage` and `benchSome` with no Pokémon hit,
  `poisonUp` on a Pokémon that is not Poisoned (`poisonUpSkip`), `shuffle` (the same order),
  `unmark` (no marker), `cure` (no Special Condition), `heal`, `healAll` and `benchHeal` (no
  damage), `handToBottom` (empty hand), `discardStadium` (no Stadium), `discardTools` (no Tool),
  `mark`, `color` and `inflict` (already set), `benchDamage` on a Tera Pokémon, and the amount
  primitives at 0. The list is a guide, not a theorem: what `mayDo` needs is the hypothesis of
  `Run.mayDo_exact`, that every resolution of A changes the state. `Run.mayDo_exact` gives the exact reading
  when A always changes the state; the costs below do (`Run.discardHand_ne`,
  `Run.discardActive_ne`).
* `ifDone t A B` is exact when `t` holds exactly when A has a resolution (`Run.ifDone_exact`). A
  test that holds where A has none leaves the whole effect without a resolution there (an attack
  with no resolution is not a legal move); a test that fails where A has one skips both A and B.
  `Run.ifDone_discardHand` and `Run.ifDone_discardActive` discharge this for the census's commonest
  costs, "discard N cards from your hand" (N = 1: Klefki) and "discard N Energy from this Pokémon",
  with the count test on the same cards.
* `forUpTo f N` for "any amount" needs `Run.forUpTo_complete`'s hypothesis per card;
  `Run.forUpTo_discardActive` discharges it for "discard any amount of Energy from this Pokémon"
  once `N` is at least the Energy that passes the filter. -/

/-- Cards passing the filter can be taken in any number up to how many there are, and no more. -/
theorem Split.taken_count {f : Filter} {l t r : List Card} (h : Split f l t r) :
    t.length ≤ l.countP f.eval := by
  induction h with
  | nil => exact Nat.le_refl _
  | take hx _ ih =>
      simp only [List.length_cons, List.countP_cons, hx, ite_true]
      exact Nat.succ_le_succ ih
  | keep _ ih =>
      simp only [List.countP_cons]
      exact Nat.le_trans ih (Nat.le_add_right _ _)

theorem Split.exists_exactly (f : Filter) : ∀ (l : List Card) {n : Nat},
    n ≤ l.countP f.eval → ∃ t r, Split f l t r ∧ t.length = n
  | [], n, h => ⟨[], [], .nil, (Nat.le_zero.1 h).symm⟩
  | x :: l, n, h => by
      cases n with
      | zero => exact ⟨[], x :: l, Split.keepAll f _, rfl⟩
      | succ n =>
          cases hx : f.eval x with
          | true =>
              simp only [List.countP_cons, hx, ite_true] at h
              obtain ⟨t, r, hs, ht⟩ := Split.exists_exactly f l (Nat.le_of_succ_le_succ h)
              exact ⟨x :: t, r, .take hx hs, by rw [List.length_cons, ht]⟩
          | false =>
              simp only [List.countP_cons, hx, Bool.false_eq_true, ite_false, Nat.add_zero] at h
              obtain ⟨t, r, hs, ht⟩ := Split.exists_exactly f l h
              exact ⟨t, x :: r, .keep hs, ht⟩

/-- **`ifDone` is exact when its test is the feasibility of A**: then either A had a resolution
and A and B resolve, or A had none and nothing happens. -/
theorem Run.ifDone_exact {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay}
    (hp : g.activeOf t.whose = some p) (hf : t.eval g p = true ↔ ∃ g₁, Run a g g₁) :
    Run (Effect.ifDone t a b) g g' ↔
      (∃ g₁, Run a g g₁ ∧ Run b g₁ g') ∨ ((¬∃ g₁, Run a g g₁) ∧ g' = g) := by
  rw [Run.ifDone_iff]
  constructor
  · rintro ⟨q, hq, ⟨-, h⟩ | ⟨ht, e⟩⟩
    · exact .inl h
    · obtain rfl : p = q := Option.some.inj (hp.symm.trans hq)
      exact .inr ⟨fun h => absurd (hf.2 h) (by rw [ht]; decide), e⟩
  · rintro (⟨g₁, h₁, h₂⟩ | ⟨hn, e⟩)
    · exact ⟨p, hp, .inl ⟨hf.2 ⟨g₁, h₁⟩, g₁, h₁, h₂⟩⟩
    · refine ⟨p, hp, .inr ⟨?_, e⟩⟩
      cases h : t.eval g p with
      | false => rfl
      | true => exact absurd (hf.1 h) hn

/-- **`mayDo` is exact when every resolution of A changes the state**: "if you do" is then the
branch that did A, and that branch did something. -/
theorem Run.mayDo_exact {a b : Effect} {g g' : GameState} (hA : ∀ g₁, Run a g g₁ → g₁ ≠ g) :
    Run (Effect.mayDo a b) g g' ↔ g' = g ∨ ∃ g₁, g₁ ≠ g ∧ Run a g g₁ ∧ Run b g₁ g' := by
  rw [Run.mayDo_iff]
  constructor
  · rintro (e | ⟨g₁, h₁, h₂⟩)
    · exact .inl e
    · exact .inr ⟨g₁, hA g₁ h₁, h₁, h₂⟩
  · rintro (e | ⟨g₁, -, h₁, h₂⟩)
    · exact .inl e
    · exact .inr ⟨g₁, h₁, h₂⟩

/-- The side of the player an update is made to. -/
theorem GameState.side_updSide (w : Whose) (F : PlayerState → PlayerState) (g : GameState) :
    (g.updSide w F).side w = F (g.side w) := by
  cases w <;> rfl

/-! ### "Discard N cards from your hand" -/

/-- **Feasibility**: "discard `n` cards [passing `f`] from your hand" has a resolution exactly when
the hand holds `n` such cards. -/
theorem Run.discardHand_exists {w : Whose} {f : Filter} {n : Nat} {g : GameState} :
    (∃ g₁, Run (.move w .hand .discard f (.exactly n)) g g₁) ↔
      n ≤ (Count.pile w .hand f).val g := by
  constructor
  · rintro ⟨g₁, h⟩
    cases h with
    | zone hw hz =>
        simp only [Effect.zSide, Option.some.injEq] at hw
        subst hw
        cases hz with
        | move hs hq _ =>
            simp only [Qty.ok] at hq
            rw [← hq]
            exact Split.taken_count hs
    | touchActive he => simp [Effect.touch] at he
    | touchBench he => simp [Effect.touch] at he
  · intro h
    obtain ⟨t, r, hs, ht⟩ := Split.exists_exactly f (g.side w).hand h
    exact ⟨_, .zone rfl (.move (src := .hand) hs ht (.discard _ _))⟩

/-- **The action is performed**: every resolution takes `n` cards passing `f` from the hand and puts
them on the discard pile, and changes nothing else of the player's zones. -/
theorem Run.discardHand_does {w : Whose} {f : Filter} {n : Nat} {g g' : GameState}
    (h : Run (.move w .hand .discard f (.exactly n)) g g') :
    ∃ t r, Split f (g.side w).hand t r ∧ t.length = n ∧ (g'.side w).hand = r ∧
      (g'.side w).discard = t ++ (g.side w).discard := by
  cases h with
  | zone hw hz =>
      simp only [Effect.zSide, Option.some.injEq] at hw
      subst hw
      cases hz with
      | move hs hq hp =>
          cases hp
          exact ⟨_, _, hs, hq, by rw [GameState.side_updSide]; rfl,
            by rw [GameState.side_updSide]; rfl⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

/-- A discard of at least one card always changes the state. -/
theorem Run.discardHand_ne {w : Whose} {f : Filter} {n : Nat} {g g' : GameState} (hn : 0 < n)
    (h : Run (.move w .hand .discard f (.exactly n)) g g') : g' ≠ g := by
  intro e
  obtain ⟨t, r, -, ht, -, hd⟩ := Run.discardHand_does h
  rw [e] at hd
  have hl := congrArg List.length hd
  rw [List.length_append, ht] at hl
  clear hd e h
  omega

/-- **"Discard N cards from your hand. If you do, B" is exact**, with the count test on the hand
(Klefki's Stick 'n' Draw is `n = 1`, `f = any`, `w = own`). -/
theorem Run.ifDone_discardHand {w : Whose} {f : Filter} {n : Nat} {b : Effect} {g g' : GameState}
    {p : InPlay} (hp : g.cur.active = some p) :
    Run (Effect.ifDone (.countGe (.pile w .hand f) n) (.move w .hand .discard f (.exactly n)) b)
        g g' ↔
      (∃ g₁, Run (.move w .hand .discard f (.exactly n)) g g₁ ∧ Run b g₁ g') ∨
        ((¬∃ g₁, Run (.move w .hand .discard f (.exactly n)) g g₁) ∧ g' = g) :=
  Run.ifDone_exact hp (Nat.ble_eq.to_iff.trans Run.discardHand_exists.symm)

/-! ### "Discard N Energy from this Pokémon" -/

/-- **Feasibility**: "discard `n` Energy [passing `f`] from your Active Pokémon" has a resolution
exactly when that many are attached. -/
theorem Run.discardActive_exists {w : Whose} {f : Filter} {n : Nat} {g : GameState} {a : InPlay}
    (ha : (g.side w).active = some a) :
    (∃ g₁, Run (.discardEnergy w .active f (.exactly n)) g g₁) ↔
      n ≤ (Count.energy w f).val g := by
  have hv : (Count.energy w f).val g = a.energy.countP f.eval := by
    simp only [Count.val, ha, Option.map_some, Option.getD_some]
  rw [hv]
  constructor
  · rintro ⟨g₁, h⟩
    cases h with
    | zone hw hz =>
        simp only [Effect.zSide, Option.some.injEq] at hw
        subst hw
        cases hz with
        | discardActive ha' hs hq =>
            obtain rfl : a = _ := Option.some.inj (ha.symm.trans ha')
            simp only [Qty.ok] at hq
            rw [← hq]
            exact Split.taken_count hs
    | touchActive he => simp [Effect.touch] at he
    | touchBench he => simp [Effect.touch] at he
  · intro h
    obtain ⟨t, r, hs, ht⟩ := Split.exists_exactly f a.energy h
    exact ⟨_, .zone rfl (.discardActive ha hs ht)⟩

/-- **The action is performed**: every resolution takes `n` Energy passing `f` off the Active
Pokémon and puts them on the discard pile. -/
theorem Run.discardActive_does {w : Whose} {f : Filter} {n : Nat} {g g' : GameState}
    (h : Run (.discardEnergy w .active f (.exactly n)) g g') :
    ∃ a t r, (g.side w).active = some a ∧ Split f a.energy t r ∧ t.length = n ∧
      (g'.side w).active = some { a with energy := r } ∧
      (g'.side w).discard = t ++ (g.side w).discard := by
  cases h with
  | zone hw hz =>
      simp only [Effect.zSide, Option.some.injEq] at hw
      subst hw
      cases hz with
      | discardActive ha hs hq =>
          exact ⟨_, _, _, ha, hs, hq, by rw [GameState.side_updSide]; rfl,
            by rw [GameState.side_updSide]; rfl⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

/-- A discard of at least one Energy always changes the state. -/
theorem Run.discardActive_ne {w : Whose} {f : Filter} {n : Nat} {g g' : GameState} (hn : 0 < n)
    (h : Run (.discardEnergy w .active f (.exactly n)) g g') : g' ≠ g := by
  intro e
  obtain ⟨a, t, r, -, -, ht, -, hd⟩ := Run.discardActive_does h
  rw [e] at hd
  have hl := congrArg List.length hd
  rw [List.length_append, ht] at hl
  clear hd e h
  omega

/-- **"Discard N Energy from this Pokémon. If you do, B" is exact**, with the count test on the
attacker's Energy. -/
theorem Run.ifDone_discardActive {f : Filter} {n : Nat} {b : Effect} {g g' : GameState}
    {p : InPlay} (hp : g.cur.active = some p) :
    Run (Effect.ifDone (.countGe (.energy .own f) n) (.discardEnergy .own .active f (.exactly n)) b)
        g g' ↔
      (∃ g₁, Run (.discardEnergy .own .active f (.exactly n)) g g₁ ∧ Run b g₁ g') ∨
        ((¬∃ g₁, Run (.discardEnergy .own .active f (.exactly n)) g g₁) ∧ g' = g) :=
  Run.ifDone_exact hp (Nat.ble_eq.to_iff.trans (Run.discardActive_exists (w := .own) hp).symm)

/-- **"Discard any amount of Energy from this Pokémon, and K damage for each" is covered** by
`forUpTo` once the bound `N` is at least the Energy passing the filter: every resolution of a branch
`f i` is a resolution of `forUpTo f N`. -/
theorem Run.forUpTo_discardActive {w : Whose} {fl : Filter} {k : Nat → Effect} {g g' : GameState}
    {a : InPlay} {N i : Nat} (ha : (g.side w).active = some a)
    (hN : (Count.energy w fl).val g ≤ N)
    (h : Run (.seq (.discardEnergy w .active fl (.exactly i)) (k i)) g g') :
    Run (Effect.forUpTo (fun j => .seq (.discardEnergy w .active fl (.exactly j)) (k j)) N) g g' :=
  Run.forUpTo_complete (fun j g₁ hj => by
    obtain ⟨g₂, h₂, -⟩ := Run.seq_inv hj
    exact Nat.le_trans ((Run.discardActive_exists ha).1 ⟨g₂, h₂⟩) hN) h

namespace IfDo

open Trainer InPlayTests

/-- Klefki sv8-128, Stick 'n' Draw: "Discard a card from your hand. If you do, draw 2 cards." -/
def stickDraw : Attack :=
  ⟨"Stick 'n' Draw", [], 0, .ifDone (.countGe (.pile .own .hand .any) 1)
    (.move .own .hand .discard .any (.exactly 1)) (.move .own (.top 2) .hand .any .all), false, .none⟩

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
    .attack (hlk := rfl) (atk := stickDraw) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled_draws hr rfl
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
    .attack (hlk := rfl) (atk := stickDraw) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled_empty hr rfl
      (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩, ?_⟩
  intro g' h
  obtain ⟨p, hp, ⟨ht, -⟩ | ⟨-, e⟩⟩ := Run.ifDone_iff.1 h
  · cases hp; exact absurd ht (by decide)
  · exact e

end IfDo

end Pokemon
