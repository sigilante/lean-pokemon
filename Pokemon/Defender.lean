import Pokemon.Look

/-!
# Effect vocabulary 6, stage 2: defender modifiers outside steps 2 and 5 (milestone MV6)

Survey S19 §B. The rulebook's damage calculation (2026 p. 20) puts the attacker's effects at step 2
("before applying Weakness and Resistance") and the defender's at step 5 ("after applying Weakness
and Resistance"). Until this milestone the stores held a bonus at step 2 and a reduction at step 5.
Two printed kinds needed the other sign:

* "During your opponent's next turn, attacks used by the Defending Pokémon do 30 less damage
  (before applying Weakness and Resistance)" (11 refused Standard cards): a penalty on the
  opponent's attacks at step 2, `Mod.weaken n`, stored in `Mods.minus` and written
  `linger .opp .next (.weaken 3)`;
* "During your next turn, the Defending Pokémon takes 50 more damage from attacks (after applying
  Weakness and Resistance)" (4): an increase at step 5, `Mod.expose n`, stored in `Mods.more` and
  written `linger .opp .after (.expose 5)` ("this Pokémon takes 100 more damage" during the
  opponent's next turn is `linger .own .next (.expose 10)`).

Both are stored amounts. They enter `Mods.amt`, so the store bound and all five clauses of
`StoreSafe` govern their writers exactly as they govern a bonus or a reduction (`Mod.isAmt`,
`Mod.amt`); `LoopFreeNeeded.iter_weaken_breaks_bound` shows clause 1's reading of the new kind is
needed. The exact-store clamp keeps them exactly; the capped clamp caps them at `2 · bound`, and
tame decks (`Reach.finite`) may not write them (`Mod.plain`; `GameState.NoReduce` now also asks
that none is stored). Like every lingering modifier they belong to a player, not to the Defending
Pokémon (the departure listed in the Known gaps).

The third shape, "During your next turn, this Pokémon's [attack] does 60 more damage" (5 cards), is
not stored: the attack that writes it records its use on its Pokémon (`AtkLock.note`, in the
per-Pokémon lock state of milestone MV4) and the named attack tests the record (`Test.usedLast`)
and does its larger damage in that branch, so it is per Pokémon and exact.

Facts and witnesses:

* `weaken_before_weakness`, `expose_after_weakness`: the step matters. A penalty of 3 on an
  attacker of 6 against Weakness does `2 · (6 − 3) = 6`, where a reduction of 3 on the defender
  would leave `2 · 6 − 3 = 9`; an increase of 5 after Weakness and Resistance 3 gives
  `(2 · 5 − 3) + 5 = 12`, where a bonus of 5 would give `2 · (5 + 5) − 3 = 17`.
* `weaken_stops`: a penalty that brings the damage to 0 stops the calculation, so a step-5 increase
  does not apply ("Stop if the base damage is 0", read after step 2).
* `growl_witness`, `screech_witness`: attacks writing each new kind as legal moves from well-formed,
  `Settled` states; `next_in_effect` and `after_in_effect`: the stores' shifts put them in effect
  in the opponent's next turn and in the attacker's next turn.
* `mash_plain`, `mash_boosted`: an attack that records its use does 60 damage, and from a Pokémon
  whose record is in force 120.
-/

namespace Pokemon.Defender

open Trainer InPlayTests

/-! ## The damage calculation with the new kinds -/

/-- A store with a this-turn step-2 penalty `m`. -/
def minusStore (m : Nat) : Store := Store.empty.add .now (.weaken m)

/-- A store with a this-turn step-5 increase `m`. -/
def moreStore (m : Nat) : Store := Store.empty.add .now (.expose m)

/-- **A penalty comes before Weakness**: 60 damage less 30 against Weakness is 60; the same 30 as a
reduction on the defender, after Weakness, leaves 90. -/
theorem weaken_before_weakness :
    dealtBy 6 true 0 (minusStore 3) Store.empty = 6 ∧
      dealtBy 6 true 0 Store.empty (Calc.reduceStore 3) = 9 := ⟨rfl, rfl⟩

/-- **An increase comes after Weakness and Resistance**: 50 damage against Weakness and
Resistance 30 with 50 more is `(100 − 30) + 50 = 120`; the same 50 as the attacker's bonus would be
doubled: `2 · (50 + 50) − 30 = 170`. -/
theorem expose_after_weakness :
    dealtBy 5 true 3 Store.empty (moreStore 5) = 12 ∧
      dealtBy 5 true 3 (Calc.bonusStore 5) Store.empty = 17 := ⟨rfl, rfl⟩

/-- **A penalty that cancels the damage stops the calculation**: 20 damage less 20 does nothing,
even against a defender that takes 50 more. -/
theorem weaken_stops : dealtBy 2 false 0 (minusStore 2) (moreStore 5) = 0 := rfl

/-- A penalty written for the opponent's next turn is in effect in it (after one turn boundary),
and an increase written for the turn after is in effect two boundaries on. -/
theorem next_in_effect (t : Store) (n : Nat) :
    (t.add .next (.weaken n)).shift = t.shift.add .now (.weaken n) := rfl

theorem after_in_effect (t : Store) (n : Nat) :
    (t.add .after (.expose n)).shift.shift = t.shift.shift.add .now (.expose n) := rfl

/-! ## Witnesses -/

/-- "During your opponent's next turn, attacks used by the Defending Pokémon do 30 less damage
(before applying Weakness and Resistance)" (Pawmi me2-32, Growl). -/
def growl : Attack := ⟨"Growl", [], 0, .linger .opp .next (.weaken 3), false, .none⟩

/-- "During your next turn, the Defending Pokémon takes 50 more damage from attacks (after applying
Weakness and Resistance)" (Vibrava sv8-105, Screech). -/
def screech : Attack := ⟨"Screech", [], 0, .linger .opp .after (.expose 5), false, .none⟩

/-- "During your next turn, this Pokémon's Mash attack does 60 more damage (before applying
Weakness and Resistance)" (Metagross sv5-115's Meteor Mash, 60): the attack records its use
(`AtkLock.note`) and tests the record. -/
def mash : Attack :=
  ⟨"Mash", [], 0, .ite (.usedLast .own) (.damage (.const 12)) (.damage (.const 6)), false, .note⟩

def masher : PokemonCard := ⟨"Masher", .basic, none, 10, .colorless, [growl, screech, mash], 1,
  none, none, .none, false, []⟩

/-- The player to move has `a` Active; the opponent `big`. -/
def start (a : InPlay) : GameState :=
  ⟨side [] [.energy .fire] a [], side [] [.energy .fire] (InPlay.ofBasic big) [], true, false,
    false, false, none, none, false, false⟩

theorem start_wellFormed (a : InPlay) : WellFormed (start a) := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_⟩ <;>
    intro p hp <;> cases hp

/-- The attacker with no record. -/
def plainIn : InPlay := InPlay.ofBasic masher

/-- The attacker whose record of having used `mash` in its owner's last turn is in force. -/
def notedIn : InPlay := { InPlay.ofBasic masher with lk := { on := .note } }

theorem settled_plain : Settled (start plainIn) := (GameState.settled_iff _).2 (by decide)

theorem settled_noted : Settled (start notedIn) := (GameState.settled_iff _).2 (by decide)

/-- **Witness: the penalty is written** for the opponent's next turn by a legal attack. -/
theorem growl_witness :
    WellFormed (start plainIn) ∧ Settled (start plainIn) ∧ ∃ g, Move (start plainIn) g ∧
      g.opp.mods.next.minus = 3 := by
  have hr : Run growl.script (start plainIn) _ := .linger .opp .next (.weaken 3) _
  exact ⟨start_wellFormed _, settled_plain, _,
    .attack (hlk := rfl) (atk := growl) rfl (.head _) (.nil _) rfl rfl rfl rfl settled_plain hr rfl
      (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩

/-- **Witness: the increase is written** for the attacker's next turn by a legal attack. -/
theorem screech_witness :
    WellFormed (start plainIn) ∧ Settled (start plainIn) ∧ ∃ g, Move (start plainIn) g ∧
      g.opp.mods.after.more = 5 := by
  have hr : Run screech.script (start plainIn) _ := .linger .opp .after (.expose 5) _
  exact ⟨start_wellFormed _, settled_plain, _,
    .attack (hlk := rfl) (atk := screech) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      settled_plain hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    rfl⟩

/-- **Witness: without the record, 60 damage**, and the attacker records its use. -/
theorem mash_plain :
    WellFormed (start plainIn) ∧ Settled (start plainIn) ∧ ∃ g, Move (start plainIn) g ∧
      g.opp.active = some { InPlay.ofBasic big with damage := 6 } ∧
      (g.cur.active.map fun p => p.lk.new) = some .note := by
  have hr : Run mash.script (start plainIn) _ :=
    .iteF (p := plainIn) rfl (by decide) (.damage (.const 6 _) rfl)
  exact ⟨start_wellFormed _, settled_plain, _,
    .attack (hlk := rfl) (atk := mash) rfl (.tail _ (.tail _ (.head _))) (.nil _) rfl rfl rfl rfl
      settled_plain hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    rfl, rfl⟩

/-- **Witness: with the record in force, 120 damage.** -/
theorem mash_boosted :
    WellFormed (start notedIn) ∧ Settled (start notedIn) ∧ ∃ g, Move (start notedIn) g ∧
      g.opp.active = some { InPlay.ofBasic big with damage := 12 } := by
  have hr : Run mash.script (start notedIn) _ :=
    .iteT (p := notedIn) rfl (by decide) (.damage (.const 12 _) rfl)
  exact ⟨start_wellFormed _, settled_noted, _,
    .attack (hlk := rfl) (atk := mash) rfl (.tail _ (.tail _ (.head _))) (.nil _) rfl rfl rfl rfl
      settled_noted hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    rfl⟩

/-- The record is per Pokémon: a Pokémon sent to the Bench loses it (`InPlay.unlock`), as print
ends the effects of attacks on a Pokémon that moves to the Bench. -/
theorem record_cleared_on_bench : notedIn.unlock.lk.on = .none := rfl

end Pokemon.Defender
