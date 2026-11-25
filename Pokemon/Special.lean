import Pokemon.Vocab4

/-!
# Special Energy as a card kind (milestone MV5, Part A)

Survey S18 §A. A Special Energy card is `Card.energy (.special name prov text)` (`EnergyCard`): a
name, what it provides while attached, and (since milestone MV8) a payload `text` (`EnergyText`; at
milestone MV5 there was no payload, and the terms of this file have the empty one, `{}`). It is
attached from the hand by the turn's Energy attachment (`Move.attach`, `Move.attachBench`) and by
effects (`ZStep.attachActive`, `ZStep.attachBench`), pays attack costs through `Pays` (since milestone
MV8 on what it provides on its holder, `InPlay.units`, `Card.unitsOn`; `Card.provides` is the
printed provision), is discarded by
retreating and by Energy discards, and goes to the discard pile with its Pokémon. Two new filters
tell the kinds apart (`Filter.basicEnergy`, `Filter.specialEnergy`); `Filter.energy` passes both and
`Filter.energyOf t` only Basic Energy. The name filters read a Special Energy card's name
("Spiky Energy", "Team Rocket's Energy").

What was not modelled at milestone MV5: every rider of the printed Special Energy cards (static,
triggered, on-attach, return-to-hand and discard text), provision that depends on the holder or on
other attached cards, restrictions on what the card may be attached to, and deck construction (the
4-copy rule, which counts Special Energy, and ACE SPEC). The terms of this file have the empty
payload and are therefore `Card.inert`: an importer must refuse them or caveat them. Since milestone
MV8 a payload (`EnergyText`) expresses some riders (`Pokemon/EnergyText.lean`, survey S22). What the change makes expressible is text that MENTIONS
Special Energy (Victini sv5-30, Enhanced Hammer sv6-148, Cinccino sv5-137); for a deck with no
Special Energy card such text is exact as far as this construct goes.

Both clamps keep attached cards exactly, so no clamp theorem changed, and no statement changed in
text: `Card.energy` takes an `EnergyCard` instead of a `BasicEnergy`, and the statements that name
`Card.energy t` (`Move.attach`, `Move.attachBench`, `ZStep.attachActive`, `ZStep.attachBench`) now
range over Special Energy too.
-/

namespace Pokemon.Special

open Trainer InPlayTests Vocab4

/-- Team Rocket's Energy (sv10-182), its provision only: "it provides 2 in any combination of
Psychic Energy and Darkness Energy". The attachment restriction and the discard rider are not
modelled. -/
def trE : Card := .energy <| .special "Team Rocket's Energy" [[.psychic, .darkness], [.psychic, .darkness]] {}

/-- Spiky Energy (sv9-159), its provision only: "it provides Colorless Energy". -/
def spiky : Card := .energy <| .special "Spiky Energy" [[.colorless]] {}

/-- **The filters tell Basic from Special Energy.** -/
theorem filters_eval :
    Filter.specialEnergy.eval trE = true ∧ Filter.specialEnergy.eval (.energy .psychic) = false ∧
    Filter.basicEnergy.eval trE = false ∧ Filter.basicEnergy.eval (.energy .psychic) = true ∧
    Filter.energy.eval trE = true ∧ Filter.energy.eval (.energy .psychic) = true ∧
    (Filter.energyOf .psychic).eval trE = false ∧
    (Filter.named "Spiky Energy").eval spiky = true ∧
    (Filter.namePrefix "Team Rocket's").eval trE = true := by decide

/-- **A Special Energy card with the empty payload is inert**: the model plays it with its
provision and nothing of the rest of its text, and says so. Since milestone MV8 the exact condition
is `Card.inert_special`: inert unless the payload models something (a granted static effect, Ability
or attack, an alternative provision, a holder restriction), and inert whenever it says a rider is not
modelled (`EnergyText.rest`). -/
theorem special_inert (n : String) (p : List (List EType)) :
    (Card.energy (.special n p {})).inert = true :=
  rfl

/-- Two Team Rocket's Energy units pay a Psychic and a Darkness symbol; one does not pay both. -/
theorem trE_pays : Pays [.psychic, .darkness] trE.provides ∧
    ¬ Pays [.psychic, .darkness] (spiky.provides ++ [[.psychic, .darkness]]) :=
  ⟨payable_iff.1 (by simp [trE, Card.provides, EnergyCard.units, payable, pick, EType.paidBy]),
    fun h => absurd (payable_iff.2 h)
      (by simp [spiky, Card.provides, EnergyCard.units, payable, pick, EType.paidBy])⟩

/-- The player to move holds Team Rocket's Energy. -/
def sStart : GameState := { start with cur := { start.cur with hand := [trE] } }

theorem sStart_settled : Settled sStart := (GameState.settled_iff _).2 (by decide)

/-- **Witness: the turn's Energy attachment attaches a Special Energy card**, and its units then
pay a Psychic and a Darkness symbol. -/
theorem attach_special : ∃ g a, Move sStart g ∧ g.cur.active = some a ∧ a.energy = [trE] ∧
    Pays [.psychic, .darkness] a.units :=
  ⟨_, _, .attach (t := .special "Team Rocket's Energy" [[.psychic, .darkness], [.psychic, .darkness]] {})
      (l₁ := []) (l₂ := []) rfl rfl rfl rfl sStart_settled rfl rfl, rfl, rfl,
    payable_iff.1 (by decide)⟩

/-- "Discard a Special Energy from your opponent's Active Pokémon" (Victini sv5-30, Cobalion
zsv10pt5-66). -/
def singeOff : Effect := .discardEnergy .opp .active .specialEnergy (.upTo 1)

/-- The opponent's Active Pokémon has a Special Energy and a Basic Fire Energy attached. -/
def sHit : GameState :=
  { start with opp := { start.opp with active := some { sick with energy := [spiky, .energy .fire] } } }

/-- **Witness: the Special Energy is discarded, the Basic Energy stays.** -/
theorem singeOff_discards : ∃ g, Run singeOff sHit g ∧
    g.opp.active = some { sick with energy := [.energy .fire] } ∧ g.opp.discard = [spiky] :=
  ⟨_, .zone rfl (.discardActive rfl (.take rfl (.keep .nil)) ⟨1, Nat.le_refl _, by decide⟩), rfl, rfl⟩

/-- **The filter takes no Basic Energy**: from Basic Fire Energy alone, the only split by
`specialEnergy` takes nothing, so the discard leaves the Pokémon as it was. -/
theorem special_split_basic {t r : List Card} (h : Split .specialEnergy [.energy .fire] t r) :
    t = [] ∧ r = [.energy .fire] := by
  cases h with
  | take hx => exact absurd hx (by decide)
  | keep hs => cases hs; exact ⟨rfl, rfl⟩

/-- "This attack does 70 damage for each Special Energy card attached to this Pokémon" (Cinccino
sv5-137) counts the Special Energy and not the Basic. -/
theorem count_special :
    (Count.energy .opp .specialEnergy).val sHit = 1 ∧ (Count.energy .opp .basicEnergy).val sHit = 1 ∧
    (Count.energy .opp .energy).val sHit = 2 := by decide

end Pokemon.Special
