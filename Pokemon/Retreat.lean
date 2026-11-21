import Pokemon.Trainer

/-!
# Retreat: the player chooses which Energy to discard

"To retreat, you must discard 1 Energy from your Active Pokémon for each [✱] listed in its
Retreat Cost" (rulebook 2026 p. 12): the player chooses which. `Move.retreat` discards any
sub-multiset of the attached Energy of the right size (`Split .any a.energy paid rest`). Before
this change it discarded only a prefix of the list (`a.energy = paid ++ rest`), that is the Energy
attached last, since `attach` puts the new card at the head.

Witnesses: a Pokémon with a Retreat Cost of 1 and two Energy of different types (Fire attached
first, then Water) retreats discarding the first-attached one (`discard_first`) and, separately,
the second (`discard_second`).
-/

namespace Pokemon.Retreat

open Trainer

/-- `big` (Retreat Cost 1) with Water attached after Fire: the list is newest first. -/
def mon : InPlay := { InPlay.ofBasic big with energy := [.energy .water, .energy .fire] }

/-- The player to move has `mon` Active and one Benched `big`; the opponent has `big`. -/
def start : GameState :=
  ⟨side [] [.energy .fire] mon [InPlay.ofBasic big],
    side [] [.energy .fire] (InPlay.ofBasic big) [], true, false, false, false, none, none, false,
    false⟩

theorem start_settled : Settled start := (GameState.settled_iff _).2 (by decide)

/-- **The first-attached Energy (Fire) can be discarded**, keeping Water. -/
theorem discard_first :
    ∃ g', Move start g' ∧ g'.cur.discard = [.energy .fire] ∧
      g'.cur.bench.map InPlay.energy = [[.energy .water]] :=
  ⟨_, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl (.keep (.take rfl .nil)) (by decide) rfl rfl
    start_settled rfl rfl, rfl, rfl⟩

/-- **The second-attached Energy (Water) can be discarded**, keeping Fire. -/
theorem discard_second :
    ∃ g', Move start g' ∧ g'.cur.discard = [.energy .water] ∧
      g'.cur.bench.map InPlay.energy = [[.energy .fire]] :=
  ⟨_, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl (.take rfl (.keep .nil)) (by decide) rfl rfl
    start_settled rfl rfl, rfl, rfl⟩

end Pokemon.Retreat
