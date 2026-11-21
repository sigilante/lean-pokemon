import Pokemon.Stadiums

/-!
# Clause 1 of `Faithful` is needed

Clauses 2 to 5 of `GameState.Faithful` each have a negative theorem showing that the store bound
fails without them (`Faithful.counter_not_gxOnly` and `Faithful.dichotomy` for clause 2,
`Recycle.recycling_breaks_bound` for clause 3, `Abilities.unlimited_writer_breaks_bound` for
clause 4, `Stadiums.stadium_writer_breaks_bound` for clause 5). This file gives one for clause 1
(`LoopFree`: no damage bonus or reduction written under `iter`).

* `iter_writer_breaks_bound`: a well-formed start satisfying clauses 2 to 5 and violating clause
  1, whose only Trainer card is an Item whose effect is `iter (linger .own .now (bonus 1))`
  ("as many times as you like, your attacks do 10 more damage this turn": no printed card has
  it), has reachable states with unbounded stores and `xclamp`s in no finite list. One play of
  the Item, with the `iter` unrolled `k` times, leaves a this-turn bonus of `k`.

As for `Recycle.recycling_breaks_bound` and `Stadiums.stadium_writer_breaks_bound`, the result is
about representation, not play: nothing reads the stored bonus (the Pokémon have no attacks), so
the unboundedly many states are not shown to differ in play.
-/

namespace Pokemon.LoopFreeNeeded

open Recycle Stadiums

/-- "Any number of times, your attacks do 10 more damage this turn": an Item whose effect writes a
damage bonus under `iter`. No printed card has it. -/
def pump : Card := .trainer "Pump" .item (.iter (.linger .own .now (.bonus 1)))

/-- A store with a this-turn damage bonus of `b`. -/
def nowB (b : Nat) : Store := ⟨{ Mods.empty with bonus := b }, Mods.empty, Mods.empty, Mods.empty⟩

def pl (hand discard : List Card) (t : Store) : PlayerState :=
  ⟨[], hand, discard, [.energy .metal], [], some mon, [], false, false, false, false, false, t,
    true, KOHist.empty⟩

/-- The start: the player to move holds `pump`, both players have the guard Active and no
modifiers. -/
def S0 : GameState :=
  ⟨pl [pump] [] (nowB 0), pl [] [] (nowB 0), true, false, false, false, none, none, false, false⟩

/-- After `pump` is played with its `iter` unrolled `b` times. -/
def T (b : Nat) : GameState :=
  ⟨pl [] [pump] (nowB b), pl [] [] (nowB 0), true, false, false, false, none, none, false, false⟩

theorem step (b : Nat) : TRun (.linger .own .now (.bonus 1)) (T b) (T (b + 1)) :=
  .prim rfl rfl (.linger .own .now (.bonus 1) _) (.done (.inl (settled_mon rfl rfl rfl rfl)))

theorem iterT : ∀ m b : Nat, TRun (.iter (.linger .own .now (.bonus 1))) (T b) (T (b + m))
  | 0, b => .iterNil _ _
  | m + 1, b => by
      have h := TRun.iterCons (step b) (iterT m (b + 1))
      rwa [show b + 1 + m = b + (m + 1) by omega] at h

/-- One play of `pump` reaches a this-turn bonus of `k`. -/
theorem reach_T (k : Nat) : Reach S0 (T k) := by
  have h := iterT k 0
  rw [Nat.zero_add] at h
  exact .step (.refl _) rfl
    (.item (l₁ := []) (l₂ := []) rfl rfl (settled_mon rfl rfl rfl rfl) h rfl rfl rfl rfl)

theorem S0_wellFormed : WellFormed S0 :=
  ⟨fun _ => ⟨by simp [S0, pl], by simp [S0, pl]⟩, (fun p hp => by cases hp),
    (fun p hp => by cases hp)⟩

theorem S0_allCards : S0.allCards =
    [pump, .energy .metal, .pokemon guard, .energy .metal, .pokemon guard] := rfl

theorem S0_not_loopFree : ¬ S0.LoopFree := by
  intro h
  have := h pump (by rw [S0_allCards]; simp)
  exact absurd this (by decide)

/-- The this-turn bonus of the player to move. -/
def bon (g : GameState) : Nat := g.cur.mods.now.bonus

theorem bon_xclamp (g : GameState) : bon (g.xclamp K) = bon g := rfl

/-- **A damage bonus written under `iter` breaks the store bound.** There is a well-formed start
satisfying clauses 2 to 5 of `Faithful` and violating clause 1 (`LoopFree`), whose reachable
states have unbounded stores and whose reachable states' `xclamp`s lie in no finite list: one
play of an Item whose effect is `iter (linger .own .now (bonus 1))` writes any this-turn bonus.
So clause 1, or some other condition on modifiers written under `iter`, is needed for
`Faithful.reach_boundedStores` and the finiteness half of `Faithful.xfinite`. The result is about
representation, not play: no Pokémon of the deck has an attack, so nothing reads the bonus. -/
theorem iter_writer_breaks_bound :
    ∃ g₀ : GameState, WellFormed g₀ ∧ ¬ g₀.LoopFree ∧ g₀.GXOnly ∧ g₀.RecycleSafe ∧
      g₀.AbilitySafe ∧ g₀.StadiumSafe ∧ (∀ B, ∃ g, Reach g₀ g ∧ ¬ g.BoundedStores B) ∧
      ¬ ∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp K ∈ L := by
  refine ⟨S0, S0_wellFormed, S0_not_loopFree,
    GameState.GXOnly.of_noAttacks (by rw [S0_allCards]; decide),
    by unfold GameState.RecycleSafe; rw [S0_allCards]; decide,
    by unfold GameState.AbilitySafe; rw [S0_allCards]; decide,
    by unfold GameState.StadiumSafe; rw [S0_allCards]; decide, fun B => ?_, ?_⟩
  · refine ⟨_, reach_T (B + 1), fun hb => ?_⟩
    have := hb.1.1.1
    simp only [T, pl, nowB] at this
    omega
  · intro ⟨L, hL⟩
    let n := (L.map bon).sum + 1
    have hm := hL _ (reach_T n)
    have : bon ((T n).xclamp K) ≤ (L.map bon).sum := Infinite.le_sum (List.mem_map_of_mem hm)
    rw [bon_xclamp] at this
    simp only [bon, T, pl, nowB, n] at this
    omega

end Pokemon.LoopFreeNeeded
