import Pokemon.Sim

/-!
# The damage calculation (milestone M4)

Facts about `dealtBy`, the rulebook's per-attack damage calculation (rulebook 2023 p. 20; the
steps are quoted in its docstring), and about how its two new readers of the damage bonus,
Weakness and Resistance, interact with the capped clamp of `Pokemon/Sim.lean`.

* `dealtBy_gnaw`: the rulebook's worked example (p. 14): Fuecoco's Gnaw, 10 damage, against
  Sprigatito, weak to Fire, does 20.
* `dealtBy_weak_bonus`: Weakness doubles the attacker's bonus too (step 2 comes before step 3),
  and the defender's reduction is subtracted after Weakness and Resistance (step 5).
* `dealtBy_le_weak`: Weakness never lowers the damage.
* `dealtBy_jynx`: an attack whose text adds to its base damage ("20 damage plus 10 more for each
  damage counter", Jynx base1-31) makes one calculation on the total: with a reduction of 3 and 3
  counters on the target it does `(2 + 3) - 3 = 2`. (Before M4 the model placed the scaled part
  with `scale`, outside the calculation, and did 3.)
* `cap_at_k_fails`: with the stores capped at the damage cap `k` itself, Resistance breaks the
  agreement `dealtBy_cap` needs: a bonus of `k` and one of `k + 1`, equal at the cap, do `k - 2`
  and `k - 1` from base damage 1 against Resistance 3. This is why `GameState.clamp k` caps the
  stores at `2 * k`.
* `weak_cap_comm`: doubling commutes with the cap above it: `min (2 * (n + b)) k` is
  `min (2 * (n + min b K)) k` whenever `K ≥ k`. So Weakness, a new reader that doubles a quantity
  containing an unbounded stored amount, needs no larger cap.
-/

namespace Pokemon

namespace Calc

/-- A store with a damage bonus `b` for this turn and nothing else. -/
def bonusStore (b : Nat) : Store := Store.empty.add .now (.bonus b)

/-- A store with a damage reduction `r` for this turn and nothing else. -/
def reduceStore (r : Nat) : Store := Store.empty.add .now (.reduce r)

/-- **The rulebook's example** (2023 p. 14): "Fuecoco's Gnaw attack does 10 damage. Then,
Sprigatito's Weakness of ×2 to ◉ Pokémon makes that 10 ×2 = 20 damage. So put 2 damage counters
on Sprigatito." -/
theorem dealtBy_gnaw : dealtBy 1 true 0 Store.empty Store.empty = 2 := rfl

/-- **Weakness doubles the bonus**, and the reduction comes after Weakness and Resistance:
`n` base damage with a bonus `b`, against Weakness, Resistance `r` and a reduction `d`, does
`(2 · (n + b) − r) − d`. -/
theorem dealtBy_weak_bonus {n : Nat} (hn : n ≠ 0) (b r d : Nat) :
    dealtBy n true r (bonusStore b) (reduceStore d) = (2 * (n + b) - r) - d := by
  simp [dealtBy, hn, bonusStore, reduceStore, Store.add, Store.live, Mods.merge, Mods.addMod,
    Store.empty, Mods.empty]

/-- **Weakness never lowers the damage.** -/
theorem dealtBy_le_weak (n r : Nat) (own opp : Store) :
    dealtBy n false r own opp ≤ dealtBy n true r own opp := by
  unfold dealtBy
  split
  · exact Nat.le_refl _
  · split
    · exact Nat.le_refl _
    · split
      · exact Nat.le_refl _
      · simp only [Bool.false_eq_true, ↓reduceIte]; omega

/-- **One calculation for an attack whose text adds to its damage** (Jynx base1-31, "20 damage
plus 10 more for each damage counter on the Defending Pokémon", written
`damage (add (const 2) (per opp 1))`): with 3 counters on the target and a reduction of 3, the
amount is `2 + 3` and the attack does `(2 + 3) - 3 = 2`. -/
theorem dealtBy_jynx : dealtBy (2 + 1 * 3) false 0 Store.empty (reduceStore 3) = 2 := rfl

/-- **Capping the stores at the damage cap fails with Resistance** (a fact about the damage
function, given as motivation for the `2k` store cap; it is not a game-level witness that a
`k`-capped clamp fails in play, and at `k = 2` its Resistance of 3 exceeds what `Fit 2`
allows). For every `k ≥ 2`, a bonus of `k` and one of `k + 1` are equal when capped at `k`,
but from base damage 1 against Resistance 3 they do `k - 2` and `k - 1` damage, which differ
below `k`. -/
theorem cap_at_k_fails (k : Nat) (hk : 2 ≤ k) :
    (bonusStore k).cap k = (bonusStore (k + 1)).cap k ∧
      min (dealtBy 1 false 3 (bonusStore k) Store.empty) k ≠
        min (dealtBy 1 false 3 (bonusStore (k + 1)) Store.empty) k := by
  refine ⟨?_, ?_⟩
  · simp only [bonusStore, Store.cap, Store.add, Store.empty, Mods.cap, Mods.addMod, Mods.empty]
    simp only [Nat.zero_add, Nat.min_self, Store.mk.injEq, Mods.mk.injEq, and_true]
    omega
  · simp [dealtBy, bonusStore, Store.add, Store.live, Mods.merge, Mods.addMod, Store.empty,
      Mods.empty]
    omega

/-- **Doubling commutes with a cap above the damage cap**: Weakness reads the stored bonus only
through `2 · (n + b)`, which a cap `K ≥ k` on `b` does not change below `k`. -/
theorem weak_cap_comm (n b k K : Nat) (hK : k ≤ K) :
    min (2 * (n + b)) k = min (2 * (n + min b K)) k := by
  omega

end Calc

end Pokemon
