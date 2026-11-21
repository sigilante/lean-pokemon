import Pokemon.Faithful

/-!
# The two sides together: faithful decks are finite, the two-counter decks are not faithful

`Pokemon/Faithful.lean` proves finiteness up to the exact-store clamp for decks satisfying
`GameState.Faithful`, which has three clauses: `LoopFree` (no damage bonus or reduction under
`iter`), `GXOnly` (rest-of-game bonuses and reductions only in GX attacks) and, since milestone MV,
`RecycleSafe` (no recycling of modifier writers within a turn, none of rest-of-game writers),
and, since milestone M8a, `AbilitySafe` (no "as often as you like" Ability writes a damage bonus or
reduction, no Ability a rest-of-game one).
`Pokemon/Counter.lean` proves that the generalised model simulates every two-counter machine.
This file shows that clause 2 cannot be dropped from the finiteness theorem: the two-counter
starts satisfy clauses 1, 3 and 4 (they recycle nothing and have no Abilities), violate clause 2 (when the machine's first
instruction is not `halt`), and simulate every two-counter machine. (That clause 3 cannot be
dropped either is `Recycle.recycling_breaks_bound`.) It is a sharpness result for clause 2, not a
classification of decks: faithful decks are finite up to a two-way bisimulation; some decks
that violate only clause 2 (the two-counter starts) are universal; nothing is proved here about
other non-faithful decks, and some of them are finite (for instance tame decks that violate
clause 2, covered by `Reach.finite`).

* `Faithful.counter_loopFree`: every two-counter start `Counter.start M a b` satisfies clause 1.
* `Faithful.counter_recycleSafe` (milestone MV): it satisfies clause 3 (`counter_noRecycle`: no
  effect of its cards moves a card out of a discard pile).
* `Faithful.counter_abilitySafe` (milestone M8a): it satisfies clause 4 (no Abilities).
* `Faithful.counter_stadiumSafe` (milestone M5): it satisfies clause 5 (no Stadium).
* `Faithful.counter_not_gxOnly`: it violates clause 2 whenever the machine's initial
  instruction is not `halt`: the Clock's or the Tape's attack, neither a GX attack, writes a
  rest-of-game damage bonus or reduction (an increment writes a reduction, a decrement a bonus;
  the Clock runs every instruction except tests of counter two, which the Tape runs).
* `Faithful.xclamp_not_finite`: for `Counter.start Counter.countUp 0 0` (a clause-2 violator)
  the `xclamp`s of the reachable states lie in no finite list, so `Reach.xfinite_bounded`
  needs its bound on the stores, and the finiteness of `Faithful.xfinite` fails once clause 2
  is dropped. (As for `Counter.not_finite_up_to`, this is about representation: `countUp`
  never reads its counter. The behavioural statement is `Counter.universal`.)
* `Faithful.dichotomy`: finiteness with a two-way bisimulation for every well-formed faithful
  deck; for every two-counter machine whose initial instruction is not `halt`, a well-formed
  start that satisfies clause 1, violates clause 2, and reaches the halt mark exactly when the
  machine halts.

A machine whose initial instruction is `halt` halts at once; its start may or may not satisfy
clause 2 (the Clock's attack still contains the instructions of other states), and nothing is
claimed about it here.
-/

namespace Pokemon.Faithful

open Counter

theorem loopFree_sel {w : Whose} {f : Nat → Effect} :
    ∀ {l : List Nat}, (∀ v ∈ l, (f v).loopFree = true) → (sel w f l).loopFree = true
  | [], _ => rfl
  | v :: l, h => by
      simp only [sel, Effect.loopFree, Bool.and_eq_true]
      exact ⟨h v (.head _), loopFree_sel (fun u hu => h u (.tail _ hu))⟩

theorem amtAt_sel {s : Slot} {w : Whose} {f : Nat → Effect} :
    ∀ {l : List Nat} {v : Nat}, v ∈ l → (f v).amtAt s ≤ (sel w f l).amtAt s
  | _ :: _, _, .head _ => by simp only [sel, Effect.amtAt]; omega
  | _ :: _, _, .tail _ h => by
      have := amtAt_sel (s := s) (w := w) (f := f) h
      simp only [sel, Effect.amtAt]; omega

theorem stepAOf_loopFree (w : Nat) (i : Instr) : (stepAOf w i).loopFree = true := by
  cases i with
  | inc r q => cases r <;> rfl
  | jz r q₁ q₂ => cases r <;> rfl
  | halt => rfl

theorem stepBOf_loopFree (w q : Nat) (i : Instr) : (stepBOf w q i).loopFree = true := by
  cases i with
  | inc r q => cases r <;> rfl
  | jz r q₁ q₂ => cases r <;> rfl
  | halt => rfl

theorem effA_loopFree (M : Machine) : (effA M).loopFree = true := by
  have h1 : (normA M).loopFree = true := loopFree_sel (fun _ _ => rfl)
  have h2 := loopFree_sel (w := .own) (f := fun q => stepAOf (W M) (M.instr q))
    (l := List.range (V M)) (fun _ _ => stepAOf_loopFree _ _)
  simp only [effA, Effect.loopFree, h1, h2, Bool.and_self]

theorem effB_loopFree (M : Machine) : (effB M).loopFree = true := by
  have h2 := loopFree_sel (w := .opp) (f := fun q => stepBOf (W M) q (M.instr q))
    (l := List.range (V M)) (fun _ _ => stepBOf_loopFree _ _ _)
  simp only [effB, Effect.loopFree, h2, Bool.and_self]

theorem start_allCards (M : Machine) (a b : Nat) :
    (start M a b).allCards = [.energy .grass, .energy .grass, .pokemon (clock M),
      .energy .grass, .energy .grass, .pokemon (tape M)] := rfl

/-- **The two-counter decks satisfy clause 1**: none of their effects has a damage bonus or
reduction under `iter` (they have no `iter` at all). -/
theorem counter_loopFree (M : Machine) (a b : Nat) : (start M a b).LoopFree := by
  intro x hx
  rw [start_allCards] at hx
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl
  · rfl
  · rfl
  · simp only [Card.loopFree, clock, atkA, List.all_cons, List.all_nil, effA_loopFree,
      Bool.and_self]
  · rfl
  · rfl
  · simp only [Card.loopFree, tape, atkB, List.all_cons, List.all_nil, effB_loopFree,
      Bool.and_self]

theorem recFilters_sel {w : Whose} {f : Nat → Effect} :
    ∀ {l : List Nat}, (∀ v ∈ l, (f v).recFilters = []) → (sel w f l).recFilters = []
  | [], _ => rfl
  | v :: l, h => by
      simp only [sel, Effect.recFilters, h v (.head _),
        recFilters_sel (fun u hu => h u (.tail _ hu)), List.append_nil]

theorem stepAOf_recFilters (w : Nat) (i : Instr) : (stepAOf w i).recFilters = [] := by
  cases i with
  | inc r q => cases r <;> rfl
  | jz r q₁ q₂ => cases r <;> rfl
  | halt => rfl

theorem stepBOf_recFilters (w q : Nat) (i : Instr) : (stepBOf w q i).recFilters = [] := by
  cases i with
  | inc r q => cases r <;> rfl
  | jz r q₁ q₂ => cases r <;> rfl
  | halt => rfl

/-- **The two-counter decks recycle nothing** (milestone MV), so they satisfy clause 3: no effect
of theirs moves a card out of a discard pile. -/
theorem counter_noRecycle (M : Machine) (a b : Nat) : (start M a b).NoRecycle := by
  have h1 : (normA M).recFilters = [] := recFilters_sel (fun _ _ => rfl)
  have h2 := recFilters_sel (w := .own) (f := fun q => stepAOf (W M) (M.instr q))
    (l := List.range (V M)) (fun _ _ => stepAOf_recFilters _ _)
  have h3 := recFilters_sel (w := .opp) (f := fun q => stepBOf (W M) q (M.instr q))
    (l := List.range (V M)) (fun _ _ => stepBOf_recFilters _ _ _)
  intro x hx
  rw [start_allCards] at hx
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl
  · rfl
  · rfl
  · simp only [Card.allRec, clock, atkA, attacksRec, abilitiesRec, effA, Effect.recFilters, h1,
      h2, List.append_nil]
  · rfl
  · rfl
  · simp only [Card.allRec, tape, atkB, attacksRec, abilitiesRec, effB, Effect.recFilters, h3,
      List.append_nil]

theorem counter_recycleSafe (M : Machine) (a b : Nat) : (start M a b).RecycleSafe :=
  (counter_noRecycle M a b).recycleSafe

/-- **The two-counter decks satisfy clause 4** (milestone M8a): their Pokémon have no Abilities. -/
theorem counter_abilitySafe (M : Machine) (a b : Nat) : (start M a b).AbilitySafe := by
  intro x hx
  rw [start_allCards] at hx
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-- **The two-counter decks satisfy clause 5** (milestone M5): they have no Stadium cards. -/
theorem counter_stadiumSafe (M : Machine) (a b : Nat) : (start M a b).StadiumSafe := by
  intro x hx
  rw [start_allCards] at hx
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-- **The two-counter decks violate clause 2** when the machine's initial instruction is not
`halt`: the Clock's attack (`atkA`) or the Tape's (`atkB`), neither a GX attack, writes a
rest-of-game damage bonus or reduction. -/
theorem counter_not_gxOnly (M : Machine) (a b : Nat) (h : M.instr 0 ≠ .halt) :
    ¬ (start M a b).GXOnly := by
  intro hG
  have hA : (effA M).amtAt .always = 0 :=
    hG (.pokemon (clock M)) (by rw [start_allCards]; simp) (atkA M) (.head _) rfl
  have hB : (effB M).amtAt .always = 0 :=
    hG (.pokemon (tape M)) (by rw [start_allCards]; simp) (atkB M) (.head _) rfl
  have h0 : 0 ∈ List.range (V M) := List.mem_range.2 (Machine.span_pos M)
  have lA : (stepAOf (W M) (M.instr 0)).amtAt .always ≤ (effA M).amtAt .always := by
    have := amtAt_sel (s := .always) (w := .own) (f := fun q => stepAOf (W M) (M.instr q)) h0
    simp only [effA, Effect.amtAt] at this ⊢; omega
  have lB : (stepBOf (W M) 0 (M.instr 0)).amtAt .always ≤ (effB M).amtAt .always := by
    have := amtAt_sel (s := .always) (w := .opp) (f := fun q => stepBOf (W M) q (M.instr q)) h0
    simp only [effB, Effect.amtAt] at this ⊢; omega
  rw [hA] at lA
  rw [hB] at lB
  generalize M.instr 0 = i at h lA lB
  cases i with
  | inc r q =>
      cases r <;> simp [stepAOf, setPc, Effect.amtAt, Mod.amt] at lA
  | jz r q₁ q₂ =>
      cases r
      · simp [stepAOf, setPc, Effect.amtAt, Mod.amt] at lA
      · simp [stepBOf, Effect.amtAt, Mod.amt] at lB
  | halt => exact h rfl

/-- The exact-store clamp is idempotent. -/
theorem InPlay.clampWith_hp_idem (p : InPlay) :
    (p.clampWith .hp).clampWith .hp = p.clampWith .hp := by
  simp only [InPlay.clampWith, Cap.dmg, Nat.min_assoc, Nat.min_self]

theorem xclamp_idem (g : GameState) : g.xclamp.xclamp = g.xclamp := by
  have hf : InPlay.clampWith .hp ∘ InPlay.clampWith .hp = InPlay.clampWith .hp :=
    funext InPlay.clampWith_hp_idem
  simp only [GameState.xclamp, GameState.xclampAt, Option.map_map, List.map_map, hf]

/-- States with the same `xclamp` encode the same configuration. -/
theorem Encodes.inj_xclamp {M : Machine} {c c' : Config} {g g' : GameState} (h : Encodes M c g)
    (h' : Encodes M c' g') (hx : g.xclamp = g'.xclamp) : c = c' := by
  obtain ⟨s, rfl, hg, -, -, hs, -⟩ := h
  obtain ⟨s', rfl, hg', -, -, hs', -⟩ := h'
  obtain ⟨p, hp, ht, -, -, -, hd, -⟩ := hs.cur.active
  obtain ⟨p', hp', ht', -, -, -, hd', -⟩ := hs'.cur.active
  have e := congrArg (fun g => g.cur.active) hx
  simp only [GameState.xclamp, GameState.xclampAt, hp, hp', Option.map_some,
    Option.some.injEq] at e
  have ed : min p.damage p.top.hp = min p'.damage p'.top.hp := congrArg InPlay.damage e
  rw [ht, ht', hd, hd'] at ed
  have hA := hg.hpA false true
  have hA' := hg'.hpA false true
  obtain ⟨m₁, m₂⟩ := GameState.mods_of_xclamp hx
  have e1 := storeOf_inj (hs.cur.mods.symm.trans (m₁.trans hs'.cur.mods))
  have e2 := storeOf_inj (hs.opp.mods.symm.trans (m₂.trans hs'.opp.mods))
  obtain ⟨hq, hrA, -⟩ := hg
  obtain ⟨hq', hrA', -⟩ := hg'
  simp only [pkA, pkB] at ed hA hA' e1 e2
  have hW : W M = 2 * V M := rfl
  simp only [Abs.cfg, Config.mk.injEq]
  refine ⟨?_, ?_, ?_⟩ <;> omega

/-- **Without a bound on the stores, the exact-store quotient can be infinite.** From the
well-formed start `Counter.start Counter.countUp 0 0`, which satisfies clause 1 and violates
clause 2, the `xclamp`s of the reachable states lie in no finite list. Like
`Counter.not_finite_up_to`, this is about how states are represented (`countUp` never reads its
counter); the behavioural statement is `Counter.universal`. -/
theorem xclamp_not_finite :
    ¬ ∃ L : List GameState, ∀ g, Reach (start countUp 0 0) g → g.xclamp ∈ L := by
  intro ⟨L, hL⟩
  refine not_finite_up_to (fun g h => g.xclamp = h.xclamp) ⟨fun _ => rfl, Eq.symm, Eq.trans⟩
    (fun c c' g g' h h' e => Encodes.inj_xclamp h h' e) ⟨L, fun g h => ⟨g.xclamp, hL g h, ?_⟩⟩
  exact (xclamp_idem g).symm

/-- **The dichotomy** (a sharpness result for clause 2, `GXOnly`, not a partition of decks).
Items 2 and 3 show that clause 2 cannot be dropped from item 1. They concern the two-counter
starts only: a deck that is not `Faithful` need not be universal or infinite (tame decks that
violate clause 2 are finite by `Reach.finite`), and nothing is claimed about other
non-faithful decks.

1. *Finite side.* For every well-formed start whose cards satisfy `Faithful` (well-formedness is
   not used: `Faithful.xfinite` holds from any start; the premise is kept so the statement is
   unchanged) (clause 1,
   `LoopFree`: no damage bonus or reduction under `iter`; clause 2, `GXOnly`: rest-of-game
   bonuses and reductions only in GX attacks, which are once per player per game; clause 3,
   `RecycleSafe`, since milestone MV; clause 4, `AbilitySafe`, since milestone M8a; clause 5,
   `StadiumSafe`, since milestone M5), the
   `xclamp`s of the reachable states lie in one finite list and the kernel of `xclamp` is a
   two-way bisimulation along reachable states.
2. *Universal side.* For every two-counter machine `M` whose initial instruction is not `halt`
   and all inputs `a`, `b`, the start `Counter.start M a b` is well formed, satisfies clauses 1,
   3, 4 and 5 (clause 3 added by milestone MV, clause 4 by milestone M8a: its Pokémon have no
   Abilities; clause 5 by milestone M5: it has no Stadium), violates clause 2, and reaches a
   halt-marked state exactly when `M` halts from `(0, a, b)`.
3. *The bound is needed.* For `Counter.start Counter.countUp 0 0` the `xclamp`s of the
   reachable states lie in no finite list.

With Minsky's theorem (prose, not formalised), item 2 makes reachability of the halt mark
undecidable over the family of two-counter starts, each of which violates clause 2 only. -/
theorem dichotomy :
    (∀ g₀ : GameState, WellFormed g₀ → g₀.Faithful →
      (∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp ∈ L) ∧
      ∀ g₁ g₂, Reach g₀ g₁ → g₁.xclamp = g₂.xclamp →
        (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp) ∧
        (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧ g₂'.xclamp = g₁'.xclamp)) ∧
    (∀ (M : Machine) (a b : Nat), M.instr 0 ≠ .halt →
      WellFormed (start M a b) ∧ (start M a b).LoopFree ∧ (start M a b).RecycleSafe ∧
        (start M a b).AbilitySafe ∧ (start M a b).StadiumSafe ∧ ¬ (start M a b).GXOnly ∧
      ((∃ g, Reach (start M a b) g ∧ HaltMarked g) ↔ M.Halts (Machine.init a b))) ∧
    ¬ ∃ L : List GameState, ∀ g, Reach (start countUp 0 0) g → g.xclamp ∈ L :=
  ⟨fun _ _ hF => xfinite hF,
    fun M a b h => ⟨start_wellFormed M a b, counter_loopFree M a b, counter_recycleSafe M a b,
      counter_abilitySafe M a b, counter_stadiumSafe M a b, counter_not_gxOnly M a b h,
      (universal M a b).2.2.2⟩,
    xclamp_not_finite⟩

end Pokemon.Faithful
