import Pokemon.InPlayTests
import Pokemon.Calc

/-!
# Attacks whose damage ignores Weakness, Resistance or effects on the defender (milestone MV3, stage 1)

Survey S15 §1: 39 refused Standard cards print one of five variants of "This attack's damage isn't
affected by Weakness / Resistance / Weakness or Resistance / any effects on your opponent's Active
Pokémon / Weakness or Resistance, or by any effects on your opponent's Active Pokémon". The damage
step carries a flag record, `Ign` (`Effect.damage a ig`), and its damage is `GameState.dealtI ig n`:
the rulebook's calculation (2026 p. 20, steps 1–6, quoted in `dealtBy`) with step 3 (Weakness),
step 4 (Resistance) or step 5 ("other effects on your opponent's Active Pokémon": the defender's
stored reduction and prevention and its static reductions) switched off. Step 2, the attacker's own
bonuses, always applies. `dealtI {}` is `dealt` by definition (`GameState.dealtI_none`).

Both clamps keep it: the flag is part of the effect, and with it the calculation reads less of the
state than before (`dealtBy_cap_ign` for the capped clamp: with step 5 off both states read the
empty store; the exact clamp reads every quantity exactly). `Enum.bound` is unaffected: the capped
clamp needs Resistance plus static reduction at most the cap, and switching steps off only lowers
both (`Run.cap_sim`'s damage case, re-proved for every `Ign`). The damage step is still the one
`HitRun.hit` reads, so the `damaged` triggers fire exactly when the step raised the defender's
damage.

* `dealt_le_dealtI`: switching off Resistance or effects on the defender, and not Weakness, never
  lowers the damage (since milestone MV6: when no step-5 increase is in effect on the defender); `dealtI_le_dealt_weak`: switching off Weakness alone never raises it.
* `dealtI_le_open`: with step 5 off the damage is at most the unreduced value
  `dealtBy n w 0 own Store.empty`.
* Witnesses (`pierce_ignores`, `plain_reduced`): the same defender, with Resistance 3 to the
  attacker's type and a stored reduction of 2, takes `(6 − 3) − 2 = 1` from a plain 60-damage
  attack and 6 from one that ignores Resistance and effects on it, each a legal move from a
  well-formed, `Settled` state.
-/

namespace Pokemon

/-- A larger Resistance never raises the damage. -/
theorem dealtBy_resist_anti {n : Nat} {w : Bool} {r r' : Nat} (h : r ≤ r') (c o : Store) :
    dealtBy n w r' c o ≤ dealtBy n w r c o := by
  unfold dealtBy
  split
  · exact Nat.le_refl _
  · split
    · exact Nat.le_refl _
    · cases w <;> simp only [Bool.false_eq_true, ↓reduceIte] <;> omega

/-- Effects on the defender that do not raise the damage never raise it: the empty store (no
reduction, no prevention) gives at least as much as any store with no step-5 increase (milestone
MV6, `Mod.expose`; before it every store qualified) and a further reduction `s`. -/
theorem dealtBy_le_empty (n : Nat) (w : Bool) (r : Nat) (c o : Store) (s : Nat)
    (ho : o.live.more = 0) :
    dealtBy n w r c (o.add .always (.reduce s)) ≤
      dealtBy n w r c (Store.empty.add .always (.reduce 0)) := by
  have e3 : (o.add .always (.reduce s)).live.more = 0 := by
    simp only [Store.live, Store.add, Mods.merge, Mods.addMod] at ho ⊢; exact ho
  unfold dealtBy
  split
  · exact Nat.le_refl _
  · have e1 : (Store.empty.add .always (.reduce 0)).live.prevent = false := rfl
    have e2 : (Store.empty.add .always (.reduce 0)).live.reduce = 0 := rfl
    have e4 : (Store.empty.add .always (.reduce 0)).live.more = 0 := rfl
    rw [e1, e2, e3, e4]
    split
    · exact Nat.zero_le _
    · simp only [Nat.sub_zero, Nat.add_zero]
      exact Nat.sub_le _ _

/-- **Switching off Resistance or the effects on the defender never lowers the damage** (with
Weakness kept), when no step-5 increase is in effect on the defender (milestone MV6: switching off
"takes 50 more damage" lowers it; before MV6 there was no such effect and the hypothesis was
vacuous). -/
theorem GameState.dealt_le_dealtI (g : GameState) (n : Nat) {ig : Ign} (hw : ig.weak = false)
    (hm : g.opp.mods.live.more = 0) :
    g.dealt n ≤ g.dealtI ig n := by
  have hr : cond ig.resist 0 g.resist ≤ g.resist := by cases ig.resist <;> simp
  unfold GameState.dealtI GameState.dealt
  rw [hw]
  cases hf : ig.fx
  · simp only [Bool.cond_false]
    split
    · exact Nat.le_refl _
    · exact dealtBy_resist_anti hr _ _
  · simp only [Bool.cond_true, Bool.false_eq_true, ↓reduceIte]
    split
    · exact Nat.zero_le _
    · exact Nat.le_trans (dealtBy_le_empty _ _ _ _ _ _ hm) (dealtBy_resist_anti hr _ _)

/-- **Switching off Weakness alone never raises the damage.** -/
theorem GameState.dealtI_le_dealt_weak (g : GameState) (n : Nat) :
    g.dealtI { weak := true } n ≤ g.dealt n := by
  show (if g.sPrevent then 0 else dealtBy n false g.resist
      (g.cur.mods.add .always (.bonus g.sBonus)) (g.opp.mods.add .always (.reduce g.sReduce))) ≤
    (if g.sPrevent then 0 else dealtBy n g.weak g.resist
      (g.cur.mods.add .always (.bonus g.sBonus)) (g.opp.mods.add .always (.reduce g.sReduce)))
  split
  · exact Nat.le_refl _
  · cases g.weak
    · exact Nat.le_refl _
    · exact Calc.dealtBy_le_weak _ _ _ _

/-- With step 5 off, the damage is at most the unreduced value: the attacker's bonus applied,
Weakness as the flag says, no Resistance and nothing on the defender (no prevention either). -/
theorem GameState.dealtI_le_open (g : GameState) (n : Nat) {ig : Ign} (hf : ig.fx = true) :
    g.dealtI ig n ≤ dealtBy n (cond ig.weak false g.weak) 0
      (g.cur.mods.add .always (.bonus g.sBonus)) Store.empty := by
  unfold GameState.dealtI
  rw [hf]
  simp only [Bool.cond_true, Bool.false_eq_true, ↓reduceIte]
  exact dealtBy_resist_anti (Nat.zero_le _) _ _

namespace Ignore

open Trainer InPlayTests

/-- 60 damage (6 counters), with the full calculation. -/
def plain : Attack := ⟨"Plain", [], 0, .damage (.const 6), false, .none⟩

/-- 60 damage that "isn't affected by Resistance, or by any effects on your opponent's Active
Pokémon" (the Resistance half of Ledian svp-133's text, with its step-5 half). -/
def pierce : Attack := ⟨"Pierce", [], 0, .damage (.const 6) { resist := true, fx := true }, false, .none⟩

def driller : PokemonCard := ⟨"Driller", .basic, none, 10, .fighting, [plain, pierce], 1, none,
  none, .none, false, []⟩

/-- A defender with Resistance −30 to Fighting and 100 HP. -/
def rock : PokemonCard := ⟨"Rock", .basic, none, 10, .grass, [], 1, none, some (.fighting, 3),
  .none, false, []⟩

/-- The defender's player has a damage reduction of 2 (20) in effect this turn. -/
def guarded : Store := Store.empty.add .now (.reduce 2)

/-- `driller` against `rock`, whose player has the reduction `guarded`. -/
def start : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic driller) [],
    { side [] [.energy .fire] (InPlay.ofBasic rock) [] with mods := guarded },
    true, false, false, false, none, none, false, false⟩

theorem start_wellFormed : WellFormed start := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_⟩ <;>
    intro p hp <;> cases hp

theorem start_settled : Settled start := (GameState.settled_iff _).2 (by decide)

/-- The calculation both ways: `(6 − 3) − 2 = 1` with every step, 6 with Resistance and the
reduction switched off. -/
theorem start_dealt : start.dealt 6 = 1 ∧ start.dealtI { resist := true, fx := true } 6 = 6 :=
  ⟨rfl, rfl⟩

/-- **Witness: the plain attack is reduced** by Resistance and by the reduction: as a legal move
from a well-formed, `Settled` state, it puts 1 damage counter on the defender. -/
theorem plain_reduced :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      g.opp.active = some { InPlay.ofBasic rock with damage := 1 } :=
  ⟨start_wellFormed, start_settled, _,
    .attack (hlk := rfl) (atk := plain) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled
      (.damage (.const 6 _) rfl) rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil (.damage (.const 6 _) rfl) rfl) (.nil _), rfl⟩

/-- **Witness: the attack that ignores them does its full damage**: the same defender takes 6
damage counters. -/
theorem pierce_ignores :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      g.opp.active = some { InPlay.ofBasic rock with damage := 6 } :=
  ⟨start_wellFormed, start_settled, _,
    .attack (hlk := rfl) (atk := pierce) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl start_settled
      (.damage (.const 6 _) rfl) rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil (.damage (.const 6 _) rfl) rfl) (.nil _), rfl⟩

end Ignore

end Pokemon
