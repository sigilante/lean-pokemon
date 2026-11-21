/-
Imported Standard cards, part 8 of 8 (11 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.3.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part08
open Pokemon

/-- Mega Malamar ex (me6-69). Records: me6-69, me6-123. -/
def me6_69 : Card := .pokemon
  { name := "Mega Malamar ex", stage := .stage1, evolvesFrom := some "Inkay",
    hp := 32, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Psychic Marionette", cost := [.darkness, .darkness], damage := 0,
        effect := .damage (.count (.bench .opp .pokemon) 7),
        gx := false },
      { name := "Eerie Wave", cost := [.darkness, .darkness, .darkness], damage := 20,
        effect := .inflict .confused,
        gx := false }] }

/-- Morpeko (me6-70). Records: me6-70. -/
def me6_70 : Card := .pokemon
  { name := "Morpeko", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Slap", cost := [.darkness], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Jangmo-o (me6-73). Records: me6-73. Caveats: perPokemon. -/
def me6_73 : Card := .pokemon
  { name := "Jangmo-o", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hard Head", cost := [.lightning, .fighting], damage := 3,
        effect := .linger .own .next (.reduce 3),
        gx := false }] }

/-- Hakamo-o (me6-74). Records: me6-74. -/
def me6_74 : Card := .pokemon
  { name := "Hakamo-o", stage := .stage1, evolvesFrom := some "Jangmo-o",
    hp := 10, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Smash", cost := [.lightning, .fighting], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 7)) (.damage (.const 14))),
        gx := false }] }

/-- Cyclizar (me6-76). Records: me6-76. Caveats: benchMods. -/
def me6_76 : Card := .pokemon
  { name := "Cyclizar", stage := .basic, evolvesFrom := none,
    hp := 12, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Break Through", cost := [.grass, .darkness, .colorless], damage := 11,
        effect := .benchDamage .opp 3,
        gx := false }] }

/-- Tauros (me6-77). Records: me6-77. -/
def me6_77 : Card := .pokemon
  { name := "Tauros", stage := .basic, evolvesFrom := none,
    hp := 13, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Raging Horns", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 5) (.per .own 1)),
        gx := false }] }

/-- Eevee (me6-78). Records: me6-78, me6-114. -/
def me6_78 : Card := .pokemon
  { name := "Eevee", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nap", cost := [.colorless], damage := 0,
        effect := .heal 2,
        gx := false },
      { name := "Headbutt", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Azurill (me6-80). Records: me6-80, me6-115. -/
def me6_80 : Card := .pokemon
  { name := "Azurill", stage := .basic, evolvesFrom := none,
    hp := 3, type := .colorless, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bouncy-Bounce Charge", cost := [], damage := 0,
        effect := .seq (.attach .own .deck .energy .bench .any) .shuffle,
        gx := false }] }

/-- Swablu (me6-81). Records: me6-81. -/
def me6_81 : Card := .pokemon
  { name := "Swablu", stage := .basic, evolvesFrom := none,
    hp := 5, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Run Around", cost := [.colorless], damage := 0,
        effect := .switch .own,
        gx := false },
      { name := "Peck", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Fletchling (me6-86). Records: me6-86. -/
def me6_86 : Card := .pokemon
  { name := "Fletchling", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Surprise Attack", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Fletchinder (me6-87). Records: me6-87. Caveats: perPokemon. -/
def me6_87 : Card := .pokemon
  { name := "Fletchinder", stage := .stage1, evolvesFrom := some "Fletchling",
    hp := 8, type := .colorless, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Clutch", cost := [.colorless, .colorless], damage := 4,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  me6_69,
  me6_70,
  me6_73,
  me6_74,
  me6_76,
  me6_77,
  me6_78,
  me6_80,
  me6_81,
  me6_86,
  me6_87]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

end PokemonCards.Standard.Part08
