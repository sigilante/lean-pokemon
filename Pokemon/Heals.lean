import Pokemon.EnergyMoves

/-!
# Healing several or filtered Benched Pokémon (milestone MV11, survey S25)

`Effect.benchHealSome m f n`: heal `m` distinct Benched Pokémon of the player whose card passes `f`,
chosen when the effect resolves, all of them if fewer pass; from each up to `n` damage counters
(`some n`) or all of them (`none`). Its semantics is `Hits (InPlay.healBy n)`, the relation of
`benchSome` with a heal in place of damage.

"Heal 30 damage from each of your Pokémon" is `seq (heal 3) (benchHealSome 5 .any (some 3))`
(5 = `benchLimit`, every Benched Pokémon); "Heal 100 damage from 1 of your Benched Ancient Pokémon",
`benchHealSome 1 F (some 10)`; "Heal all damage from 1 of your Benched Pokémon", `benchHealSome 1 .any
none`.

**The clamps.** The effect acts on the player's own Benched Pokémon only. Inside an attack the
player's own damage is kept exact by the capped clamp (`GameState.rclamp`: `Cap.exact` on the own
side), and the exact-store clamp keeps every damage exact inside an effect (`GameState.xrclamp`);
under `Cap.exact` a heal commutes with the clamp (`clampExact_healBy`, for `some n` and for "all"), so
`Run.cap_sim` and the exact simulation gained one case each and no statement changed. A heal of the
opponent's Pokémon would not commute with the capped clamp inside an attack (damage `d ≥ k` and `k`
have the same image, but `d - n` and `k - n` need not), which is why the language has none (survey
S25: Mega Floette ex me4-35 and Grisham me6-93 stay refused).

**What it keeps.** No zone, store or flag changes; the cards of every Pokémon are kept
(`InPlay.cardList_healBy`, so `Reach.perm` is unchanged); Special Conditions and markers are kept
(`Run.wellFormed`, `Run.noMarks` cases); the potential `abPot` is kept. No new state.

**Witnesses** (Item cards, legal moves from a well-formed, `Settled` start):
* `heal_each`: every Benched Pokémon is healed (positive);
* `heal_filtered`: with a filter, only the Benched Pokémon that passes it is healed, the other keeps
  its damage (negative: the filter is read);
* `heal_all`: all damage of one Benched Pokémon is removed.
General: `hits_pointwise` says, for every resolution in every state, that each Benched Pokémon is either
unchanged or passes the filter and is healed (`benchHealSome_cases`).
-/

namespace Pokemon.Heals

open Trainer

def hurtA : InPlay := { InPlay.ofBasic { big with name := "HurtA" } with damage := 4 }
def hurtB : InPlay := { InPlay.ofBasic { big with name := "HurtB", type := .psychic } with damage := 5 }

/-- The player to move has `big` Active and `hurtA` (4 counters, Grass) and `hurtB` (5 counters,
Psychic) on the Bench, and `c` in hand. -/
def start (c : Card) : GameState :=
  ⟨side [c] [.energy .fire] (InPlay.ofBasic big) [hurtA, hurtB],
    side [] [.energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none, false, false, false⟩

theorem start_wellFormed (c : Card) : WellFormed (start c) := by
  refine ⟨fun _ => ⟨by simp [start, Trainer.side], by simp [start, Trainer.side]⟩,
    fun p hp => ?_, (fun p hp => by cases hp), .of_b rfl⟩
  simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem start_settled (c : Card) : Settled (start c) :=
  settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by
      simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide)
    (fun p hp => by cases hp)

/-- "Heal 30 damage from each of your Benched Pokémon." -/
def healEach : Card := .trainer "HealEach" .item (.benchHealSome 5 .any (some 3))

/-- "Heal 30 damage from 1 of your Benched Psychic Pokémon." -/
def healPsychic : Card := .trainer "HealPsychic" .item (.benchHealSome 1 (.ptype .psychic) (some 3))

/-- "Heal all damage from 1 of your Benched Pokémon." -/
def healAllBench : Card := .trainer "HealAllBench" .item (.benchHealSome 1 .any none)

/-- **Witness: each Benched Pokémon.** Playing `healEach` is a legal move after which `hurtA` has 1
damage counter and `hurtB` 2. -/
theorem heal_each :
    WellFormed (start healEach) ∧ Settled (start healEach) ∧ ∃ g, Move (start healEach) g ∧
      g.cur.bench.map InPlay.damage = [1, 2] := by
  have hh : Hits (InPlay.healBy (some 3)) .any 2 [hurtA, hurtB]
      [hurtA.healBy (some 3), hurtB.healBy (some 3)] := .hit rfl (.hit rfl .nil)
  have hm : Move (start healEach) _ :=
    .item (l₁ := []) (l₂ := []) (n := "HealEach") rfl rfl (start_settled _)
      (.prim rfl rfl (.benchHealSome 5 .any (some 3) hh)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide) (by decide)
          (fun p hp => by cases hp))))) rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl⟩

/-- **Witness: the filter is read.** Playing `healPsychic` is a legal move after which the Psychic
`hurtB` has 2 damage counters and the Grass `hurtA` keeps its 4; and no resolution of it from the
start heals `hurtA` (`heal_filtered_only`). -/
theorem heal_filtered :
    WellFormed (start healPsychic) ∧ Settled (start healPsychic) ∧ ∃ g, Move (start healPsychic) g ∧
      g.cur.bench.map InPlay.damage = [4, 2] := by
  have hh : Hits (InPlay.healBy (some 3)) (.ptype .psychic) 1 [hurtA, hurtB]
      [hurtA, hurtB.healBy (some 3)] := .keep (.hit rfl .nil)
  have hm : Move (start healPsychic) _ :=
    .item (l₁ := []) (l₂ := []) (n := "HealPsychic") rfl rfl (start_settled _)
      (.prim rfl rfl (.benchHealSome 1 (.ptype .psychic) (some 3) hh)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide) (by decide)
          (fun p hp => by cases hp))))) rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl⟩

/-- Two Benches related place by place by `P` (core Lean has no `Pointwise`). -/
inductive Pointwise (P : InPlay → InPlay → Prop) : List InPlay → List InPlay → Prop where
  | nil : Pointwise P [] []
  | cons {x y : InPlay} {b b' : List InPlay} (h : P x y) (t : Pointwise P b b') :
      Pointwise P (x :: b) (y :: b')

/-- **General: what `Hits` does.** Each Pokémon of the new Bench is the old one at its place, or the
old one passed the filter and is changed by `U`. This does not count the changed places: that
exactly `k` are changed is in the definition of `Hits` and shown here only by the witnesses. -/
theorem hits_pointwise {U : InPlay → InPlay} {f : Filter} {k : Nat} {b b' : List InPlay}
    (h : Hits U f k b b') :
    Pointwise (fun x y => y = x ∨ (f.eval (.pokemon x.top) = true ∧ y = U x)) b b' := by
  induction h with
  | nil => exact .nil
  | hit hx _ ih => exact .cons (.inr ⟨hx, rfl⟩) ih
  | keep _ ih => exact .cons (.inl rfl) ih

/-- **General: a filtered heal heals only Pokémon that pass the filter**, for every resolution in
every state. -/
theorem benchHealSome_cases {m : Nat} {f : Filter} {n : Option Nat} {g g' : GameState}
    (h : Run (.benchHealSome m f n) g g') :
    Pointwise (fun x y => y = x ∨ (f.eval (.pokemon x.top) = true ∧ y = x.healBy n))
      g.cur.bench g'.cur.bench := by
  cases h with
  | benchHealSome _ _ _ hh => exact hits_pointwise hh
  | touchActive he _ => simp [Effect.touch] at he
  | touchBench he _ => simp [Effect.touch] at he
  | zone hw _ => simp [Effect.zSide] at hw

/-- **Negative witness: the Grass Pokémon is never healed by `healPsychic`'s effect** from the start
state: in every resolution `hurtA` keeps its 4 damage counters. -/
theorem heal_filtered_only {g : GameState}
    (h : Run (.benchHealSome 1 (.ptype .psychic) (some 3)) (start healPsychic) g) :
    g.cur.bench.head?.map InPlay.damage = some 4 := by
  have hc := benchHealSome_cases h
  simp only [start, Trainer.side] at hc
  generalize g.cur.bench = b' at hc ⊢
  cases hc with
  | cons h1 _ =>
      rcases h1 with e | ⟨hf, _⟩
      · simp only [e]; rfl
      · exact absurd hf (by decide)

/-- **Witness: all damage of one Benched Pokémon.** Playing `healAllBench` is a legal move after which
`hurtB` has no damage counters. -/
theorem heal_all :
    WellFormed (start healAllBench) ∧ Settled (start healAllBench) ∧ ∃ g, Move (start healAllBench) g ∧
      g.cur.bench.map InPlay.damage = [4, 0] := by
  have hh : Hits (InPlay.healBy none) .any 1 [hurtA, hurtB] [hurtA, hurtB.healBy none] :=
    .keep (.hit rfl .nil)
  have hm : Move (start healAllBench) _ :=
    .item (l₁ := []) (l₂ := []) (n := "HealAllBench") rfl rfl (start_settled _)
      (.prim rfl rfl (.benchHealSome 1 .any none hh)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide) (by decide)
          (fun p hp => by cases hp))))) rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl⟩

end Pokemon.Heals
