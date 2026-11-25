import Pokemon.Provision

/-!
# Counts and history, milestone MV9 (survey S23)

Two additions to the model, and witnesses for them and for one new use of an existing construct.

**Filters on printed data** (no new state): `Filter.megaEx` (a Mega Evolution Pokémon ex, the rule
box `megaEx`), `Filter.resists t` (a printed Resistance to type `t`), `Filter.abilityNamed n` (a
printed Ability named `n`) and `Filter.nameIn ns` (a printed name in the list `ns`; the importer
writes the printed subtypes "Ancient" and "Future", which the model's cards do not carry, with it,
over the names of its card pool). Each reads the printed card, which both clamps keep, so no clamp
theorem changed.

**The Supporter record** (`PlayerState.supCard`, read by `Count.played w f`): the Supporter card
the player played from the hand this turn. `Move.supporter` writes it when the card is played,
before its effect resolves, with the card it plays; `Move.endTurn` clears it for the player whose
turn starts (with `supporterPlayed`), and keeps the other player's, which that player's opponent
then reads as "during their last turn". It is a card of the game: along play every record is a card
of the start state or a record of the start state (`Reach.supCard_mem`, by `Move.supCard_mem`), so
the finite list of `Reach.clamp_mem` enumerates it from the start's cards and records
(`Enum.states C R`, `Reach.clamp_mem_states`), and `Reach.finite`, `Reach.clamp_mem` and
`StoreSafe.xfinite` keep their statements. Both clamps copy it (they change only damage, Poison
strength and the stores), so `Count.val_clampAt` and `Count.val_xclampAt` gained one case each
(`rfl`) and stayed equalities at every cap.

**Use history** ("If this Pokémon used X during your last turn"): no new construct. The importer
(0.16.0) writes it with the use record of milestone MV6 (`Attack.selfLock := .note`, `Test.usedLast`),
set on the attacker by `GameState.afterAttack` when X is used, brought into force by the end of its
owner's turn (`LockState.shift`), and ended when the Pokémon moves to the Bench or evolves
(`InPlay.unlock`), which print says of effects of attacks but not of this history (a reading,
Known gaps). The witnesses below follow one record through the four moves of a round: written in
the player's turn, in force in their next turn.
-/

namespace Pokemon.Played

open Trainer

/-! ## Filters on printed data -/

def megaMon : PokemonCard :=
  ⟨"Mega M ex", .stage1, some "M", 30, .fire, [], 2, none, some (.fighting, 3), .megaEx, false, []⟩

def exMon : PokemonCard := { megaMon with name := "M ex", ruleBox := .ex, resistance := none }

def sneak : Ability := ⟨"Hide 'n' Sneak", .static [], none, none, .fx .skip⟩

def sneaker : PokemonCard := { big with name := "Sneaker", abilities := [sneak] }

/-- **The new filters on printed cards.** A Mega Evolution Pokémon ex passes `megaEx`, a Pokémon
ex does not; Fighting Resistance passes `resists .fighting` and not `resists .water`; a printed
Ability passes `abilityNamed` by its name only; `nameIn` passes a Pokémon or Trainer whose name is
listed, and no Basic Energy card. -/
theorem filters_eval :
    Filter.megaEx.eval (.pokemon megaMon) = true ∧ Filter.megaEx.eval (.pokemon exMon) = false ∧
    (Filter.resists .fighting).eval (.pokemon megaMon) = true ∧
    (Filter.resists .water).eval (.pokemon megaMon) = false ∧
    (Filter.resists .fighting).eval (.pokemon exMon) = false ∧
    (Filter.abilityNamed "Hide 'n' Sneak").eval (.pokemon sneaker) = true ∧
    (Filter.abilityNamed "Other").eval (.pokemon sneaker) = false ∧
    (Filter.nameIn ["Big", "Emma"]).eval (.pokemon big) = true ∧
    (Filter.nameIn ["Big", "Emma"]).eval (.trainer "Emma" .supporter .skip) = true ∧
    (Filter.nameIn ["Big", "Emma"]).eval (.pokemon sneaker) = false ∧
    (Filter.nameIn ["Big", "Emma"]).eval (.energy (.basic .fire)) = false := by decide

/-! ## The Supporter record -/

/-- A Supporter that does nothing. -/
def emma : Card := .trainer "Emma" .supporter .skip

/-- "If you played Emma from your hand during this turn, this attack does 60 more damage" on a
10-damage attack (Espurr me4-36). -/
def buddy : Attack :=
  ⟨"Buddy", [], 0,
    .ite (.countGe (.played .own (.named "Emma")) 1) (.damage (.const 7)) (.damage (.const 1)),
    false, .none⟩

def espurr : PokemonCard := { big with name := "Espurr", attacks := [buddy] }

/-- The player to move has Espurr Active and Emma in hand; not the first turn of the game. -/
def start : GameState :=
  ⟨side [emma] [.energy .fire] (InPlay.ofBasic espurr) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [], true, false, false, false, none, none, false,
    false, false⟩

theorem start_wellFormed : WellFormed start := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> cases hp

theorem start_settled : Settled start := (GameState.settled_iff _).2 (by decide)

/-- `start` after Emma is played. -/
def played : GameState :=
  { start with
    cur := { start.cur with hand := [], discard := [emma], supporterPlayed := true,
                            supCard := some emma } }

theorem played_settled : Settled played := (GameState.settled_iff _).2 (by decide)

theorem move_played : Move start played :=
  .supporter (l₁ := []) (l₂ := []) (n := "Emma") rfl rfl rfl start_settled
    (.prim rfl rfl (.skip _) (.done (.inl ((GameState.settled_iff _).2 (by decide))))) rfl rfl rfl rfl

/-- **Witness: the record is written when the Supporter is played** and names that card: from a
well-formed, `Settled` start, playing Emma is a legal move after which "you played Emma this turn"
holds and "you played Tarragon this turn" does not. -/
theorem supporter_writes :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      (Count.played .own (.named "Emma")).val g = 1 ∧
      (Count.played .own (.named "Tarragon")).val g = 0 :=
  ⟨start_wellFormed, start_settled, played, move_played, rfl, rfl⟩

/-- **Witness: an attack reads the record of the turn.** After Emma, the attack does 70; without
it (from `start`), 10. -/
theorem buddy_after_emma :
    (∃ g, Move played g ∧ g.opp.active = some { InPlay.ofBasic big with damage := 7 }) ∧
    (∃ g, Move start g ∧ g.opp.active = some { InPlay.ofBasic big with damage := 1 }) := by
  have hr : Run buddy.script played _ :=
    .iteT (p := InPlay.ofBasic espurr) rfl (by decide) (.damage (.const 7 _) rfl)
  have hr' : Run buddy.script start _ :=
    .iteF (p := InPlay.ofBasic espurr) rfl (by decide) (.damage (.const 1 _) rfl)
  exact ⟨⟨_, .attack (hlk := rfl) (atk := buddy) rfl (.head _) (.nil _) rfl rfl rfl rfl
      played_settled hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
      rfl⟩,
    ⟨_, .attack (hlk := rfl) (atk := buddy) rfl (.head _) (.nil _) rfl rfl rfl rfl
      start_settled hr' rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr' rfl) (.nil _),
      rfl⟩⟩

/-- **Witness: the end of the turn clears the record of the player whose turn starts**, and the
record of the player whose turn ended stays, read by the new player to move as their opponent's
last turn. -/
theorem endTurn_clears :
    ∃ g, Move played g ∧ (Count.played .own .any).val g = 0 ∧
      (Count.played .opp (.named "Emma")).val g = 1 :=
  ⟨_, .endTurn_of_zero false false false false false false rfl rfl played_settled.1 rfl .nil .nil
    (by decide) (by decide), rfl, rfl⟩

/-! ## Use history across a round (the importer's reading of "used X during your last turn") -/

/-- "Form Ranks": an attack that records its use (`AtkLock.note`). -/
def ranks : Attack := ⟨"Ranks", [], 0, .damage (.const 1), false, .note⟩

/-- "If this Pokémon used Ranks during your last turn, this attack does 90 more damage" on a
30-damage attack (Falinks sv7-88). -/
def allOut : Attack :=
  ⟨"All-Out", [], 0, .ite (.usedLast .own) (.damage (.const 12)) (.damage (.const 3)), false, .none⟩

def falinks : PokemonCard := { big with name := "Falinks", attacks := [ranks, allOut] }

/-- The player to move has Falinks Active; both decks hold a card for the draw. -/
def r0 : GameState :=
  ⟨{ side [] [.energy .fire] (InPlay.ofBasic falinks) [] with deck := [.energy .grass, .energy .grass] },
    { side [] [.energy .fire] (InPlay.ofBasic big) [] with deck := [.energy .grass, .energy .grass] },
    true, false, false, false, none, none, false, false, false⟩

theorem r0_settled : Settled r0 := (GameState.settled_iff _).2 (by decide)

/-- **Witness: a use record written in the player's turn is in force in their next turn.** From a
`Settled` start the player uses Ranks (10 damage; the attack ends the turn), the opponent's turn
starts with the draw and ends, and the player's next turn starts with the draw; then All-Out does
120, not 30: the opponent's Active Pokémon has 1 + 12 damage counters. Six legal moves. -/
theorem usedLast_next_turn :
    ∃ g₁ g₂ g₃ g₄ g₅ g₆, Move r0 g₁ ∧ Move g₁ g₂ ∧ Move g₂ g₃ ∧ Move g₃ g₄ ∧ Move g₄ g₅ ∧
      Move g₅ g₆ ∧ (g₆.opp.active.map InPlay.damage) = some 13 := by
  have hr : Run ranks.script r0 _ := .damage (.const 1 _) rfl
  refine ⟨_, _, _, _, _, _,
    .attack (hlk := rfl) (atk := ranks) rfl (.head _) (.nil _) rfl rfl rfl rfl
      r0_settled hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    .endTurn_of_zero false false false false false false rfl rfl
      ((GameState.settled_iff _).2 (by decide)).1 rfl .nil .nil (by decide) (by decide),
    .startTurn rfl rfl rfl ((GameState.settled_iff _).2 (by decide)).1 rfl,
    .endTurn_of_zero false false false false false false rfl rfl
      ((GameState.settled_iff _).2 (by decide)).1 rfl .nil .nil (by decide) (by decide),
    .startTurn rfl rfl rfl ((GameState.settled_iff _).2 (by decide)).1 rfl,
    .attack (hlk := rfl) (atk := allOut) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      ((GameState.settled_iff _).2 (by decide))
      (.iteT rfl (by decide) (.damage (.const 12 _) rfl)) rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil (.iteT rfl (by decide) (.damage (.const 12 _) rfl)) rfl) (.nil _), rfl⟩

/-- The departure the importer caveats (`usedLastBench`): moving to the Bench ends the record
(`InPlay.unlock`), so after a trip to the Bench the test is false. -/
theorem usedLast_cleared_on_bench (p : InPlay) (g : GameState) :
    (Test.usedLast .own).eval g p.unlock = false := rfl

end Pokemon.Played
