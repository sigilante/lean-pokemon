import Pokemon.Ignore

/-!
# Effect vocabulary 4, stage 1: name filters and counts of printed data (milestone MV4)

Survey S17 §A–B. Two filters on the printed name and five counts, none of which reads damage or
needs new state:

* `Filter.namePrefix p`: the printed name begins with `p` ("Iono's Pokémon" is
  `and pokemon (namePrefix "Iono's ")`); `Filter.nameHas s`: the printed name contains `s` ("a
  Supporter card that has \"Team Rocket\" in its name"). Both compare the UTF-8 bytes of the names
  (`nameBytes`), so `Filter.eval` stays a `Bool` that the kernel evaluates.
* `Count.tools w` (Pokémon Tools attached to all of the `w` player's Pokémon), `Count.conds w`
  (Special Conditions on the `w` Active Pokémon, 0 to 3), `Count.prizesTaken w` (6 less the Prize
  cards left), `Count.energyTypes w` (distinct types of Basic Energy attached to all of the `w`
  player's Pokémon) and `Count.supporter w` (the `w` player's Supporter flag of the turn).

Every new count reads cards, Special Condition flags, Prize cards or a turn flag, which both clamps
keep exactly, so `Count.val_clampAt` and `Count.val_xclampAt` gained one case each and stayed
equalities; no clamp theorem needed a hypothesis. A count of damage counters on several Pokémon
(Azelf sv8-80) is not a count of the model: it is not clamp-exact (S17 §B).

The witnesses below are legal attacks from well-formed, `Settled` states whose damage is computed
from a new count, and evaluations of the filters on printed names.
-/

namespace Pokemon.Vocab4

open Trainer InPlayTests

/-! ## Name filters -/

/-- "Iono's Pokémon": a Pokémon card whose name begins with "Iono's ". -/
def ionos : Filter := .and .pokemon (.namePrefix "Iono's ")

def ionoVoltorb : PokemonCard := ⟨"Iono's Voltorb", .basic, none, 6, .lightning, [], 1, none, none,
  .none, false, []⟩

def voltorb : PokemonCard := { ionoVoltorb with name := "Voltorb" }

/-- The filter passes Iono's Voltorb, not Voltorb, and not the Supporter card "Iono" (no
apostrophe-s), nor a Trainer whose name begins with "Iono's " (it is not a Pokémon). -/
theorem ionos_eval : ionos.eval (.pokemon ionoVoltorb) = true ∧
    ionos.eval (.pokemon voltorb) = false ∧
    ionos.eval (.trainer "Iono" .supporter .skip) = false ∧
    ionos.eval (.trainer "Iono's Bellibolt" .item .skip) = false := by decide

/-- "a Supporter card that has \"Team Rocket\" in its name" passes Team Rocket's Petrel and not
Arven; "a Pokémon that has \"Koffing\" in its name" passes Team Rocket's Koffing and Koffing, and
not Weezing. -/
theorem nameHas_eval :
    (Filter.and (.kind .supporter) (.nameHas "Team Rocket")).eval
        (.trainer "Team Rocket's Petrel" .supporter .skip) = true ∧
      (Filter.and (.kind .supporter) (.nameHas "Team Rocket")).eval
        (.trainer "Arven" .supporter .skip) = false ∧
      (Filter.and .pokemon (.nameHas "Koffing")).eval
        (.pokemon { ionoVoltorb with name := "Team Rocket's Koffing" }) = true ∧
      (Filter.and .pokemon (.nameHas "Koffing")).eval
        (.pokemon { ionoVoltorb with name := "Koffing" }) = true ∧
      (Filter.and .pokemon (.nameHas "Koffing")).eval
        (.pokemon { ionoVoltorb with name := "Weezing" }) = false := by decide

/-- A Basic Energy card has no name the filters read. -/
theorem name_energy (p : String) : (Filter.namePrefix p).eval (.energy .fire) = false ∧
    (Filter.nameHas p).eval (.energy .fire) = false := ⟨rfl, rfl⟩

/-! ## Counts -/

/-- A Tool that gives nothing. -/
def band : Card := .tool "Band" ToolGrant.none

/-- "This attack does 30 damage for each Pokémon Tool attached to all of your Pokémon" (Mow Rotom
sv10-9). -/
def gadget : Attack := ⟨"Gadget Show", [], 0, .damage (.count (.tools .own) 3), false, .none⟩

/-- "This attack does 100 damage for each Special Condition affecting your opponent's Active
Pokémon" (Cradily sv7-6). -/
def rootDrain : Attack := ⟨"Root Drain", [], 0, .damage (.count (.conds .opp) 10), false, .none⟩

/-- "This attack does 60 damage for each Prize card your opponent has taken" (Pecharunt ex
sv6pt5-39). -/
def poisonChain : Attack := ⟨"Poison Chain", [], 0, .damage (.count (.prizesTaken .opp) 6), false, .none⟩

def rotom : PokemonCard := ⟨"Rotom", .basic, none, 10, .colorless, [gadget, rootDrain, poisonChain],
  1, none, none, .none, false, []⟩

/-- The attacker, with a Tool. -/
def rotomIn : InPlay := { InPlay.ofBasic rotom with tools := [band] }

/-- A Benched Pokémon with a Tool. -/
def benchIn : InPlay := { InPlay.ofBasic big with tools := [band] }

/-- The defender: Asleep, Poisoned and Burned. -/
def sick : InPlay := { InPlay.ofBasic big with rot := .asleep, poisoned := true, burned := true }

/-- The player to move has `rotomIn` Active and `benchIn` on the Bench; the opponent has `sick`
Active and one Prize card left (so has taken 5). -/
def start : GameState :=
  ⟨side [] [.energy .fire] rotomIn [benchIn], side [] [.energy .fire] sick [],
    true, false, false, false, none, none, false, false, false⟩

theorem start_wellFormed : WellFormed start := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_, .of_b rfl⟩
  · intro p hp
    simp only [start, side, List.mem_singleton] at hp
    subst hp
    exact ⟨rfl, rfl, rfl, rfl⟩
  · intro p hp; cases hp

theorem start_settled : Settled start := (GameState.settled_iff _).2 (by decide)

/-- The four counts in `start`: two Tools, three Special Conditions, five Prize cards taken by the
opponent and none by the player to move (one Prize card left each, 6 at the start), and the
opponent's Supporter flag clear. -/
theorem start_counts : (Count.tools .own).val start = 2 ∧ (Count.tools .opp).val start = 0 ∧
    (Count.conds .opp).val start = 3 ∧ (Count.conds .own).val start = 0 ∧
    (Count.prizesTaken .opp).val start = 5 ∧ (Count.supporter .opp).val start = 0 := by decide

/-- **Witness: damage for each Tool.** From a well-formed, `Settled` state, the attack is legal and
does 60 damage (two Tools): 6 damage counters on the defender. -/
theorem gadget_two_tools :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      g.opp.active = some { sick with damage := 6 } :=
  ⟨start_wellFormed, start_settled, _,
    Move.attackOpen (hlk := rfl) (atk := gadget) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled
      (.damage (.count _ 3 _) rfl) rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil (.damage (.count _ 3 _) rfl) rfl) (.nil _), rfl⟩

/-- **Witness: damage for each Special Condition**: 300 damage against an Asleep, Poisoned and
Burned defender. -/
theorem rootDrain_three :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      g.opp.active = some { sick with damage := 30 } :=
  ⟨start_wellFormed, start_settled, _,
    Move.attackOpen (hlk := rfl) (atk := rootDrain) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl start_settled
      (.damage (.count _ 10 _) rfl) rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil (.damage (.count _ 10 _) rfl) rfl) (.nil _), rfl⟩

/-- **Witness: damage for each Prize card the opponent has taken**: five taken, 300 damage. -/
theorem poisonChain_five :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      g.opp.active = some { sick with damage := 30 } :=
  ⟨start_wellFormed, start_settled, _,
    Move.attackOpen (hlk := rfl) (atk := poisonChain) rfl (.tail _ (.tail _ (.head _))) (.nil _) rfl rfl rfl rfl
      start_settled (.damage (.count _ 6 _) rfl) rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil (.damage (.count _ 6 _) rfl) rfl) (.nil _), rfl⟩

/-- Types of Basic Energy: Fire, Fire and Water attached across two Pokémon are two types. -/
theorem energyTypes_two :
    (Count.energyTypes .own).val
      { start with cur := { start.cur with
        active := some { rotomIn with energy := [.energy .fire, .energy .fire] },
        bench := [{ benchIn with energy := [.energy .water] }] } } = 2 := by decide

/-- The Supporter count reads the turn's flag. -/
theorem supporter_flag :
    (Count.supporter .own).val { start with cur := { start.cur with supporterPlayed := true } } = 1 :=
  rfl

end Pokemon.Vocab4
