import Pokemon.EnergyText

/-!
# Provision that depends on the holder; holder restrictions (milestone MV8, stage 3)

Survey S22. What a Special Energy card provides may depend on its holder (`EnergyText.alt`, read by
`EnergyCard.unitsAt` through `Card.unitsOn`): on the holder's top card (Prism Energy: a Basic
Pokémon; Neo Upper Energy: a Stage 2 Pokémon) or on the other cards attached to it (Luminous Energy:
another Special Energy card). Every reader of Energy by what it provides goes through `Card.unitsOn`
(attack costs, Retreat Cost, counts, discards; `Pokemon/Units.lean`), so these cards pay, count and
are discarded by what they provide on their holder at that moment; a Basic Energy card provides one
unit of its type wherever it is (`Card.unitsOn_basic`, by definition), so no theorem about Basic
Energy changed.

A holder restriction (`EnergyText.only`: "This card can only be attached to a Team Rocket's Pokémon")
is a premise of every attachment (`Move.attach`, `Move.attachBench`, `ZStep.attachActive`,
`ZStep.attachBench`, `Deal`) and of every move of the card to another Pokémon (`ZStep.moveAB`,
`moveBA`, `moveBB`): `Card.attachOk`. "If this card is attached to anything other than a Team
Rocket's Pokémon, discard this card": the model never lets the card reach another Pokémon, so the
rule never applies, except through evolution, which the model does not check; in the card data
every one of the 38 cards that evolve from a "Team Rocket's" Pokémon is itself one (survey S22), so
for the card pool no evolution reaches the rule. A move of the card onto another Pokémon, which print
allows and then discards the card, is absent (a subset of print; Known gaps).

Expressible (not imported) with this file's terms, witnessed below: Prism Energy (zsv10pt5-86,
me2pt5-216), Neo Upper Energy (sv5-162; ACE SPEC is deck construction, not modelled), Luminous Energy
(sv6-226), Team Rocket's Energy (sv10-182, me2pt5-217).
-/

namespace Pokemon.Provision

open Trainer EnergyText

/-- Every type of Energy. -/
def allTypes : List EType :=
  [.grass, .fire, .water, .lightning, .psychic, .fighting, .darkness, .metal, .fairy, .dragon,
    .colorless]

/-- Prism Energy: "As long as this card is attached to a Pokémon, it provides Colorless Energy. If
this card is attached to a Basic Pokémon, this card provides every type of Energy but provides only
1 Energy at a time." -/
def prism : Card := .energy <| .special "Prism Energy" [[.colorless]]
  { alt := some (.holder .basic, [allTypes]) }

/-- Neo Upper Energy: "… it provides Colorless Energy. If this card is attached to a Stage 2
Pokémon, this card provides every type of Energy but provides only 2 Energy at a time." -/
def neoUpper : Card := .energy <| .special "Neo Upper Energy" [[.colorless]]
  { alt := some (.holder (.stage .stage2), [allTypes, allTypes]) }

/-- Luminous Energy: "… it provides every type of Energy but provides only 1 Energy at a time. If
the Pokémon this card is attached to has any other Special Energy attached, this card provides
Colorless Energy instead." -/
def luminous : Card := .energy <| .special "Luminous Energy" [allTypes]
  { alt := some (.otherSpecial, [[.colorless]]) }

/-- Team Rocket's Energy: "This card can only be attached to a Team Rocket's Pokémon. If this card
is attached to anything other than a Team Rocket's Pokémon, discard this card. As long as this card
is attached to a Pokémon, it provides 2 in any combination of Psychic Energy and Darkness Energy." -/
def rocket : Card := .energy <| .special "Team Rocket's Energy"
  [[.psychic, .darkness], [.psychic, .darkness]] { only := .namePrefix "Team Rocket's" }

theorem not_inert : prism.inert = false ∧ neoUpper.inert = false ∧ luminous.inert = false ∧
    rocket.inert = false := by decide

/-- A Stage 1 and a Stage 2 Pokémon, and a Team Rocket's Pokémon. -/
def stage1Mon : PokemonCard :=
  { grassMon with name := "Leafier", stage := .stage1, evolvesFrom := some "Leafy" }
def stage2Mon : PokemonCard :=
  { grassMon with name := "Leafiest", stage := .stage2, evolvesFrom := some "Leafier" }
def rocketMon : PokemonCard := { psyMon with name := "Team Rocket's Mimikyu" }

/-- The units the attached cards `e` provide on a holder `p`. -/
def unitsOf (p : PokemonCard) (e : List Card) : List (List EType) :=
  ({ InPlay.ofBasic p with energy := e } : InPlay).units

/-- **Prism Energy** pays a Fire symbol on a Basic Pokémon, and only a Colorless one on a Stage 1
Pokémon. -/
theorem prism_pays : Pays [.fire] (unitsOf grassMon [prism]) ∧
    ¬ Pays [.fire] (unitsOf stage1Mon [prism]) ∧ Pays [.colorless] (unitsOf stage1Mon [prism]) := by
  decide

/-- **Neo Upper Energy** pays two typed symbols on a Stage 2 Pokémon, and one Colorless symbol on a
Basic Pokémon. -/
theorem neoUpper_pays : Pays [.fire, .water] (unitsOf stage2Mon [neoUpper]) ∧
    ¬ Pays [.fire] (unitsOf grassMon [neoUpper]) ∧
    ¬ Pays [.colorless, .colorless] (unitsOf grassMon [neoUpper]) := by decide

/-- **Luminous Energy** pays a Water symbol alone or with Basic Energy, and only Colorless with
another Special Energy attached; two Luminous Energy make each other Colorless. -/
theorem luminous_pays : Pays [.water] (unitsOf grassMon [luminous]) ∧
    Pays [.water] (unitsOf grassMon [luminous, .energy .fire]) ∧
    ¬ Pays [.water] (unitsOf grassMon [luminous, spikyE]) ∧
    ¬ Pays [.water] (unitsOf grassMon [luminous, luminous]) := by decide

/-- **Neo Upper Energy pays a Retreat Cost of 2 on a Stage 2 Pokémon, and 1 elsewhere** (counted by
what it provides there, `retreatPaid`). -/
theorem neoUpper_retreat :
    retreatPaid 2 ([neoUpper].map
      ({ InPlay.ofBasic stage2Mon with energy := [neoUpper] } : InPlay).unitCount) = true ∧
    retreatPaid 2 ([neoUpper].map
      ({ InPlay.ofBasic grassMon with energy := [neoUpper] } : InPlay).unitCount) = false := by
  decide

/-- **Team Rocket's Energy may be attached only to a Team Rocket's Pokémon.** -/
theorem rocket_only : rocket.attachOk rocketMon = true ∧ rocket.attachOk psyMon = false := by decide

/-- **Witness: the turn's attachment of Team Rocket's Energy to a Team Rocket's Pokémon**, which then
pays a Psychic and a Darkness symbol. -/
theorem attach_rocket : ∃ g a, Move (st rocketMon [] [rocket]) g ∧ g.cur.active = some a ∧
    Pays [.psychic, .darkness] a.units :=
  ⟨_, _, .attach (l₁ := []) (l₂ := []) rfl rfl rfl rfl ((GameState.settled_iff _).2 (by decide)) rfl
    rfl, rfl, by decide⟩

end Pokemon.Provision
