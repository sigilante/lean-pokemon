import Pokemon.Dichotomy
import Pokemon.Trainer

/-!
# Recycling breaks the per-game store bound (milestone MV)

Before milestone MV the store-safe bound (`StoreSafe.reach_boundedStores`) counted each Trainer
card's modifier writes once per game, because nothing left a discard pile. With recycling a
Trainer card can be played again, and the per-game count is false. This file proves that the
first two clauses of `GameState.StoreSafe` (`LoopFree`, `GXOnly`, which were the whole of
`StoreSafe` before milestone MV) no longer bound the stores; clause 3 (`RecycleSafe`) is what the
restored theorem adds.

**The witness** (`recycling_breaks_bound`). The player to move has, in hand, `ironDefender`
(an Item modelled on Iron Defender me1-118: "During your opponent's next turn, all of your …
Pokémon take 30 less damage", here `linger .own .next (.reduce 3)`, protecting all of the
player's Pokémon as the model's reductions do) and `recA`; `recB` is in the discard pile. `recA`
and `recB` are two Items with the same text, "Put up to 2 Item cards from your discard pile into
your hand" (`move .own .discard .hand (.kind .item) (.upTo 2)`).

The recycling shape is two Items, each of which returns the other one together with the
modifier writer, so each round pays no net card. One round, all in the same turn, with no attack
and no draw: play `ironDefender` (3 more reduction); play `recA`, which returns `ironDefender` and
`recB`; play `ironDefender` again; play `recB`, which returns `ironDefender` and `recA`. The state is
then the start state with 6 more reduction (`reach_round`), so every multiple of 6 is reached.
Neither recycler returns itself: the loop does not use the model's order of play, in which a played
Item is in the discard pile while its effect resolves (the rulebook discards it afterwards, a
departure listed in the Known gaps).

No card in today's Standard has this shape (survey S10: the only Items that an effect usable
in the same turn without attacking can return are Arven's Sandwich and the Antique Fossils, which
write no modifier), and printed Standard decks satisfy clause 3. The witness shows what clause 3
excludes, not a printed loop.
-/

namespace Pokemon.Recycle

/-- An Item modelled on Iron Defender: a carried damage reduction of 3 counters for the player
during the opponent's next turn. -/
def ironDefender : Card := .trainer "Iron Defender" .item (.linger .own .next (.reduce 3))

/-- "Put up to 2 Item cards from your discard pile into your hand." -/
def recycleEff : Effect := .move .own .discard .hand (.kind .item) (.upTo 2)

def recA : Card := .trainer "Recycler A" .item recycleEff
def recB : Card := .trainer "Recycler B" .item recycleEff

def guard : PokemonCard := ⟨"Guard", .basic, none, 10, .metal, [], 1, none, none, .none, false, []⟩

/-- A store with a carried reduction of `r` in the next turn's slot. -/
def store (r : Nat) : Store := ⟨Mods.empty, { Mods.empty with reduce := r }, Mods.empty, Mods.empty⟩

def pl (hand discard : List Card) (r : Nat) : PlayerState :=
  ⟨[], hand, discard, [.energy .metal], [], some (InPlay.ofBasic guard), [], false, false, false,
    false, false, store r, true, KOHist.empty⟩

def gs (hand discard : List Card) (r : Nat) : GameState :=
  ⟨pl hand discard r, pl [] [] 0, true, false, false, false, none, none, false, false, false⟩

/-- The start of a round. -/
def st (r : Nat) : GameState := gs [ironDefender, recA] [recB] r

theorem gs_settled (hand discard : List Card) (r : Nat) : Settled (gs hand discard r) :=
  Trainer.settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by cases hp)

theorem move1 (r : Nat) : Move (st r) (gs [recA] [ironDefender, recB] (r + 3)) :=
  .item (l₁ := []) (l₂ := [recA]) (n := "Iron Defender") rfl rfl (gs_settled _ _ _)
    (.prim rfl rfl (.linger .own .next (.reduce 3) _) (.done (.inl (gs_settled _ _ _))))
    rfl rfl rfl rfl

theorem move2 (r : Nat) :
    Move (gs [recA] [ironDefender, recB] (r + 3)) (gs [ironDefender, recB] [recA] (r + 3)) :=
  .item (l₁ := []) (l₂ := []) (n := "Recycler A") rfl rfl (gs_settled _ _ _)
    (.prim rfl rfl
      (.zone (w := .own) rfl
        (.move (src := .discard) (.keep (.take rfl (.take rfl .nil))) (by unfold Qty.ok; decide) (.hand _ _)))
      (.done (.inl (gs_settled _ _ _))))
    rfl rfl rfl rfl

theorem move3 (r : Nat) :
    Move (gs [ironDefender, recB] [recA] (r + 3)) (gs [recB] [ironDefender, recA] (r + 3 + 3)) :=
  .item (l₁ := []) (l₂ := [recB]) (n := "Iron Defender") rfl rfl (gs_settled _ _ _)
    (.prim rfl rfl (.linger .own .next (.reduce 3) _) (.done (.inl (gs_settled _ _ _))))
    rfl rfl rfl rfl

theorem move4 (r : Nat) : Move (gs [recB] [ironDefender, recA] (r + 3 + 3)) (st (r + 3 + 3)) :=
  .item (l₁ := []) (l₂ := []) (n := "Recycler B") rfl rfl (gs_settled _ _ _)
    (.prim rfl rfl
      (.zone (w := .own) rfl
        (.move (src := .discard) (.keep (.take rfl (.take rfl .nil))) (by unfold Qty.ok; decide) (.hand _ _)))
      (.done (.inl (gs_settled _ _ _))))
    rfl rfl rfl rfl

/-- **One round**: four Item plays in one turn add 6 to the carried reduction and return to the
start of a round. -/
theorem reach_round (r : Nat) : Reach (st r) (st (r + 3 + 3)) :=
  .step (.step (.step (.step (.refl _) rfl (move1 r)) rfl (move2 r)) rfl (move3 r)) rfl (move4 r)

theorem reach_trans {g₀ g g' : GameState} (h₁ : Reach g₀ g) (h₂ : Reach g g') : Reach g₀ g' := by
  induction h₂ with
  | refl => exact h₁
  | step _ hn hm ih => exact .step ih hn hm

theorem reach_st (k : Nat) : Reach (st 0) (st (6 * k)) := by
  induction k with
  | zero => exact .refl _
  | succ k ih =>
      have e : 6 * (k + 1) = 6 * k + 3 + 3 := by omega
      rw [e]
      exact reach_trans ih (reach_round _)

theorem st_wellFormed : WellFormed (st 0) :=
  ⟨fun _ => ⟨by simp [st, gs, pl], by simp [st, gs, pl]⟩, (fun p hp => by cases hp),
    (fun p hp => by cases hp)⟩

theorem st_loopFree : (st 0).LoopFree := by
  unfold GameState.LoopFree; decide

theorem st_gxOnly : (st 0).GXOnly :=
  GameState.GXOnly.of_noAttacks (by decide)

/-- The start violates clause 3: `recA`, an Item, can return `ironDefender`, a non-Supporter
card that writes a damage reduction. -/
theorem st_not_recycleSafe : ¬ (st 0).RecycleSafe := by
  intro h
  have := h.1 recA (by decide) (.kind .item) (.head _) ironDefender (by decide) rfl
  exact absurd this (by decide)

/-- The carried reduction of the player to move. -/
def red (g : GameState) : Nat := g.cur.mods.next.reduce

theorem red_xclamp (g : GameState) : red (g.xclamp K) = red g := rfl

/-- **Recycling breaks the store bound** (milestone MV). There is a well-formed start satisfying
clauses 1, 2, 4 and 5 of `StoreSafe` (`LoopFree`, `GXOnly`: the whole of `StoreSafe` before milestone
MV; `AbilitySafe`, `StadiumSafe`, added later and satisfied: the deck has no Ability and no Stadium)
and violating clause 3 (`RecycleSafe`), whose reachable states have unbounded stores, and whose
reachable states' `xclamp`s lie in no finite list. The recycling shape is two Items each returning
the other and the writer `ironDefender` from the discard pile within one turn (see the module
docstring). So clause 3, or some other condition on recycling, is needed for
`StoreSafe.reach_boundedStores` and the finiteness half of `StoreSafe.xfinite`. -/
theorem recycling_breaks_bound :
    ∃ g₀ : GameState, WellFormed g₀ ∧ g₀.LoopFree ∧ g₀.GXOnly ∧ ¬ g₀.RecycleSafe ∧
      g₀.AbilitySafe ∧ g₀.StadiumSafe ∧ (∀ B, ∃ g, Reach g₀ g ∧ ¬ g.BoundedStores B) ∧
      ¬ ∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp K ∈ L := by
  refine ⟨st 0, st_wellFormed, st_loopFree, st_gxOnly, st_not_recycleSafe, by decide, by decide,
    fun B => ?_, ?_⟩
  · refine ⟨st (6 * (B + 1)), reach_st _, fun hb => ?_⟩
    have := hb.1.2.1.2
    simp only [st, gs, pl, store] at this
    omega
  · intro ⟨L, hL⟩
    let n := (L.map red).sum + 1
    have hm := hL (st (6 * n)) (reach_st n)
    have : red ((st (6 * n)).xclamp K) ≤ (L.map red).sum := Infinite.le_sum (List.mem_map_of_mem hm)
    rw [red_xclamp] at this
    simp only [red, st, gs, pl, store, n] at this
    omega

/-! ## Printed recycling shapes satisfy clause 3 -/

/-- Energy Retrieval me4-108: "Put up to 2 Basic Energy cards from your discard pile into your
hand." -/
def energyRetrieval : Card :=
  .trainer "Energy Retrieval" .item (.move .own .discard .hand .energy (.upTo 2))

/-- Night Stretcher me1-173: "Put a Pokémon or a Basic Energy card from your discard pile into
your hand." -/
def nightStretcher : Card :=
  .trainer "Night Stretcher" .item (.move .own .discard .hand (.or .pokemon .energy) (.upTo 1))

/-- Dedenne sv8-87's attack: "Put a Trainer card from your discard pile into your hand." (an
attack, which ends the turn). -/
def dedenne : PokemonCard :=
  ⟨"Dedenne", .basic, none, 7, .lightning,
    [⟨"Recycle", [], 0, .move .own .discard .hand .trainer (.upTo 1), false, .none⟩], 1, none, none,
    .none, false, []⟩

/-- A deck with Iron Defender, the two printed Item recyclers above, and an attack that returns any
Trainer card: clause 3 holds (decided), since no Item returns Iron Defender and an attack may.
Swapping in `recA` (an Item that returns Items) breaks it. -/
theorem printed_shapes_recycleSafe :
    (gs [ironDefender, energyRetrieval, nightStretcher, .pokemon dedenne] [] 0).RecycleSafe ∧
      ¬ (gs [ironDefender, recA, .pokemon dedenne] [] 0).RecycleSafe := by
  refine ⟨by decide, fun h => ?_⟩
  have := h.1 recA (by decide) (.kind .item) (.head _) ironDefender (by decide) rfl
  exact absurd this (by decide)

end Pokemon.Recycle
