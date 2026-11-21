import Pokemon.Bench

/-!
# Spread damage and counters (milestone MV2, stage 2)

Survey S13 §B. Three shapes of today's Standard place damage or counters on several of the
opponent's Pokémon chosen by the attacker:

* "Put 6 damage counters on your opponent's Benched Pokémon in any way you like" (Dragapult ex
  sv6-130; with "your opponent's Pokémon", Sinistcha sv6-22): `Effect.spreadAny`, one counter at
  a time on a chosen Pokémon, `N` times (`Effect.rep`). Every distribution of `N` counters is a
  resolution and nothing else is. Inside an attack no Knock Out is taken between the counters,
  as printed; inside an Item or Supporter (`TRun`) each counter would be followed by the Knock Out
  check, so the form is exact for attacks, which every card of the shape is.
* "This attack does 120 damage to 2 of your opponent's Pokémon" (Greninja ex sv6-106) and "… to 2
  of your opponent's Benched Pokémon" (Hydreigon ex sv8-119): `Effect.hitSome` and the primitive
  `Effect.benchSome` (`M` distinct Benched Pokémon, `Hits`). Damage to the Active Pokémon is the
  attack's damage step (Weakness, Resistance and every modifier apply); damage to Benched Pokémon
  takes no Weakness or Resistance (rulebook 2023 p. 14) and, in the model, no other modifier
  either (the existing departure of `benchDamage`, Known gaps). A Tera Pokémon on the Bench takes
  none.
* "Choose 2 of your opponent's Pokémon and put 3 damage counters on each of them" (Mimikyu ex
  sv9-69): `Effect.countersSome`.

`benchSome` places damage on several Benched Pokémon in one step. Both clamps are simulations for
it (`Hits.transfer`: the chosen Pokémon are chosen by their top card, which the clamps keep, and
the clamps commute with adding damage up to agreement), and its Knock Outs are taken by the one
batch step that follows (after the attack, or after the step inside a Trainer effect):
`twoBenchKOs_reachable` Knocks Out two Benched Pokémon in one batch, leaving the third.
-/

namespace Pokemon

/-- `n` copies of `e` in sequence (`skip` for 0). -/
def Effect.rep (e : Effect) : Nat → Effect
  | 0 => .skip
  | n + 1 => .seq e (e.rep n)

/-- "Put `n` damage counters on your opponent's Pokémon in any way you like" (`bench = false`) or
"… on your opponent's Benched Pokémon …" (`bench = true`). -/
def Effect.spreadAny (bench : Bool) (n : Nat) : Effect :=
  if bench then (Effect.benchCounters .opp 1).rep n
  else (Effect.choice (.counters 1) (.benchCounters .opp 1)).rep n

/-- "This attack does `n` damage to `m` of your opponent's Pokémon" (`m ≥ 1`): the Active Pokémon
by the damage step and `m - 1` Benched Pokémon, or `m` Benched Pokémon when the Bench has that
many; the Active Pokémon must be chosen when the Bench has fewer than `m`. -/
def Effect.hitSome (m n : Nat) : Effect :=
  .ite (.countGe (.bench .opp .any) m)
    (.choice (.seq (.damage (.const n)) (.benchSome .opp (m - 1) .any true n))
      (.benchSome .opp m .any true n))
    (.seq (.damage (.const n)) (.benchSome .opp (m - 1) .any true n))

/-- "Choose `m` of your opponent's Pokémon and put `n` damage counters on each of them." -/
def Effect.countersSome (m n : Nat) : Effect :=
  .ite (.countGe (.bench .opp .any) m)
    (.choice (.seq (.counters n) (.benchSome .opp (m - 1) .any false n))
      (.benchSome .opp m .any false n))
    (.seq (.counters n) (.benchSome .opp (m - 1) .any false n))

/-- The spread forms are well formed in an attack: one damage step on each line. -/
theorem Effect.hitSome_wf (m n : Nat) :
    (⟨"Spread", [], 0, Effect.hitSome m n, false⟩ : Attack).wf = true := rfl

/-- `rep` of a hit-free effect is hit-free, so the counters forms are usable anywhere. -/
theorem Effect.rep_hitFree {e : Effect} (h : e.hitFree = true) : ∀ n, (e.rep n).hitFree = true
  | 0 => rfl
  | n + 1 => by simp only [Effect.rep, Effect.hitFree, h, Effect.rep_hitFree h n, Bool.and_self]

/-- `Hits` keeps the length of the Bench. -/
theorem Hits.length_eq {U : InPlay → InPlay} {f : Filter} {k : Nat} {b b' : List InPlay}
    (h : Hits U f k b b') : b'.length = b.length :=
  h.congr List.length fun _ _ _ _ _ he => by simp only [List.length_cons, he]

/-- `Hits` changes exactly `k` Pokémon: at most the Bench's size, each chosen once. -/
theorem Hits.le_length {U : InPlay → InPlay} {f : Filter} {k : Nat} {b b' : List InPlay}
    (h : Hits U f k b b') : k ≤ b.length := by
  induction h with
  | nil => exact Nat.le_refl _
  | hit _ _ ih => simp only [List.length_cons]; exact Nat.succ_le_succ ih
  | keep _ ih => simp only [List.length_cons]; exact Nat.le_succ_of_le ih

namespace Spread

open Trainer Bench

/-- "Put 5 damage counters on each of 2 of your opponent's Benched Pokémon." -/
def spread2 : Card := .trainer "Spread2" .item (.benchSome .opp 2 .any false 5)

/-- The opponent has `big` Active and on the Bench two 50-HP Pokémon around a 100-HP one; the
player to move has three Prize cards and `spread2` in hand. -/
def start : GameState :=
  ⟨side [spread2] [.energy .fire, .energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic big)
      [InPlay.ofBasic low, InPlay.ofBasic big, InPlay.ofBasic low],
    true, false, false, false, none, none, false, false⟩

theorem start_wellFormed : WellFormed start := by
  refine ⟨fun _ => ⟨by simp [start, Trainer.side], by simp [start, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem start_settled : Settled start :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by
      simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl | rfl <;> decide)

/-- The two 50-HP Pokémon are chosen. -/
theorem hits_two : Hits (InPlay.hitWith false 5) .any
    (min 2 (benchElig .any (start.side .opp).bench)) (start.side .opp).bench
    [(InPlay.ofBasic low).hitWith false 5, InPlay.ofBasic big,
      (InPlay.ofBasic low).hitWith false 5] :=
  .hit rfl (.keep (.hit rfl .nil))

/-- **Witness: one spread Knocks Out two Benched Pokémon in one batch.** From a well-formed,
`Settled` start, `spread2` puts 5 damage counters on each of two of the opponent's Benched
Pokémon, both 50-HP; the one batch Knock Out step after that step takes both (the player takes
two Prize cards), and the opponent's 100-HP Benched Pokémon and Active Pokémon stay. -/
theorem twoBenchKOs_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧
      g.opp.bench = [InPlay.ofBasic big] ∧ g.opp.active = g₀.opp.active ∧
      g.cur.prizes.length + 2 = g₀.cur.prizes.length ∧ g.winner = none := by
  have hm : Move start _ :=
    .item (l₁ := []) (l₂ := []) (n := "Spread2") rfl rfl start_settled
      (.prim rfl rfl (.benchSome .opp 2 .any false 5 hits_two)
        (.step rfl (.go (by decide) rfl .keep .keep)
          (.done (.inl ((GameState.settled_iff _).2 (by decide)))))) rfl rfl rfl rfl
  exact ⟨start, start_wellFormed, start_settled, _, hm, .step (.refl _) rfl hm, rfl, rfl, rfl, rfl⟩

/-- With a Bench of one, "2 of your opponent's Benched Pokémon" hits that one: the count is
`min 2 1`. -/
theorem hits_all_if_fewer :
    Hits (InPlay.hitWith true 3) .any (min 2 (benchElig .any [InPlay.ofBasic big]))
      [InPlay.ofBasic big] [(InPlay.ofBasic big).hitWith true 3] :=
  .hit rfl .nil

end Spread

end Pokemon
