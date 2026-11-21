/-
Imported Standard cards, part 8 of 8 (58 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.5.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part08
open Pokemon

/-- Hakamo-o (me55-111). Records: me55-111. -/
def me55_111 : Card := .pokemon
  { name := "Hakamo-o", stage := .stage1, evolvesFrom := some "Jangmo-o",
    hp := 9, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sharp Fang", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Dragon Claw", cost := [.lightning, .fighting], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Kommo-o (me55-112). Records: me55-112, me55-143. -/
def me55_112 : Card := .pokemon
  { name := "Kommo-o", stage := .stage2, evolvesFrom := some "Hakamo-o",
    hp := 18, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Blazing Uppercut", cost := [.lightning, .fighting, .colorless], damage := 25,
        effect := .skip,
        gx := false }] }

/-- Meowth (me55-113). Records: me55-113, me55-144. -/
def me55_113 : Card := .pokemon
  { name := "Meowth", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pay Day", cost := [.colorless, .colorless], damage := 3,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false }] }

/-- Kangaskhan (me55-114). Records: me55-114. -/
def me55_114 : Card := .pokemon
  { name := "Kangaskhan", stage := .basic, evolvesFrom := none,
    hp := 13, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rage", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.per .own 1)),
        gx := false },
      { name := "Mega Punch", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Eevee (me55-117). Records: me55-117, me55-118. -/
def me55_117 : Card := .pokemon
  { name := "Eevee", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Quick Attack", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Hisuian Zorua (me55-122). Records: me55-122, me55-145. -/
def me55_122 : Card := .pokemon
  { name := "Hisuian Zorua", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Minior (me55-124). Records: me55-124. Caveats: benchMods. -/
def me55_124 : Card := .pokemon
  { name := "Minior", stage := .basic, evolvesFrom := none,
    hp := 9, type := .colorless, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shoot Meteors", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .seq (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 12)) (.benchDamage .opp 12)) (.damage (.const 12))) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Heracross (me6-1). Records: me6-1. Caveats: recoil. -/
def me6_1 : Card := .pokemon
  { name := "Heracross", stage := .basic, evolvesFrom := none,
    hp := 13, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spike Draw", cost := [.grass], damage := 2,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "High Horsepower", cost := [.grass, .grass, .colorless], damage := 13,
        effect := .selfDamage 3,
        gx := false }] }

/-- Surskit (me6-2). Records: me6-2. -/
def me6_2 : Card := .pokemon
  { name := "Surskit", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Multiply", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck (.named "Surskit")) (.putBench .own .deck (.named "Surskit"))) .shuffle,
        gx := false },
      { name := "Bug Bite", cost := [.grass], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Cacnea (me6-4). Records: me6-4. -/
def me6_4 : Card := .pokemon
  { name := "Cacnea", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knock Away", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 2)) (.damage (.const 1)),
        gx := false }] }

/-- Shaymin (me6-8). Records: me6-8. Caveats: benchMods. -/
def me6_8 : Card := .pokemon
  { name := "Shaymin", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Overrun", cost := [.grass], damage := 2,
        effect := .benchDamage .opp 2,
        gx := false }] }

/-- Virizion (me6-9). Records: me6-9. -/
def me6_9 : Card := .pokemon
  { name := "Virizion", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Draw", cost := [.colorless], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Solar Beam", cost := [.grass, .grass, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Mega Golisopod ex (me6-11). Records: me6-11, me6-118, me6-135. Caveats: perPokemon. -/
def me6_11 : Card := .pokemon
  { name := "Mega Golisopod ex", stage := .stage1, evolvesFrom := some "Wimpod",
    hp := 34, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Finishing Blow", cost := [.grass], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 22)) (.damage (.const 6)),
        gx := false },
      { name := "Quadruple Hold", cost := [.colorless, .colorless, .colorless], damage := 16,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Sprigatito (me6-12). Records: me6-12, me6-105. -/
def me6_12 : Card := .pokemon
  { name := "Sprigatito", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Play Rough", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Floragato (me6-13). Records: me6-13. -/
def me6_13 : Card := .pokemon
  { name := "Floragato", stage := .stage1, evolvesFrom := some "Sprigatito",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.grass, .grass], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Smoliv (me6-15). Records: me6-15. -/
def me6_15 : Card := .pokemon
  { name := "Smoliv", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spray Fluid", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Dolliv (me6-16). Records: me6-16. -/
def me6_16 : Card := .pokemon
  { name := "Dolliv", stage := .stage1, evolvesFrom := some "Smoliv",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leaf Step", cost := [.grass], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Arboliva (me6-17). Records: me6-17. Caveats: noopUse. -/
def me6_17 : Card := .pokemon
  { name := "Arboliva", stage := .stage2, evolvesFrom := some "Dolliv",
    hp := 15, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Slippery Oil", use := .once,
        spot := none, cond := none,
        effect := .fx (.switch .opp) }],
    attacks := [
      { name := "Mega Drain", cost := [.grass, .colorless], damage := 10,
        effect := .heal 3,
        gx := false }] }

/-- Growlithe (me6-18). Records: me6-18, me6-106. -/
def me6_18 : Card := .pokemon
  { name := "Growlithe", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Roar", cost := [.colorless], damage := 0,
        effect := .switch .opp,
        gx := false },
      { name := "Rear Kick", cost := [.fire, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Arcanine (me6-19). Records: me6-19. Caveats: recoil. -/
def me6_19 : Card := .pokemon
  { name := "Arcanine", stage := .stage1, evolvesFrom := some "Growlithe",
    hp := 15, type := .fire, retreat := 4, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fervent Fang", cost := [.fire, .colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.prizes .opp) 5) (.damage (.const 9)) (.damage (.const 18)),
        gx := false },
      { name := "Heat Tackle", cost := [.fire, .fire, .colorless, .colorless], damage := 20,
        effect := .selfDamage 5,
        gx := false }] }

/-- Magmar (me6-20). Records: me6-20. -/
def me6_20 : Card := .pokemon
  { name := "Magmar", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gather Strength", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .energy (.upTo 2)) .shuffle,
        gx := false },
      { name := "Combustion", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Heatmor (me6-24). Records: me6-24. -/
def me6_24 : Card := .pokemon
  { name := "Heatmor", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Destructive Flame", cost := [.fire], damage := 3,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Frillish (me6-27). Records: me6-27. -/
def me6_27 : Card := .pokemon
  { name := "Frillish", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hook", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Jellicent (me6-28). Records: me6-28. -/
def me6_28 : Card := .pokemon
  { name := "Jellicent", stage := .stage1, evolvesFrom := some "Frillish",
    hp := 12, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Deep Sea Draw", use := .once,
        spot := none, cond := none,
        effect := .fx (.ite (.countGe (.pile .own .deck .any) 1) (.seq (.move .own (.top 1) .hand .any .all) (.choice (.move .own .hand .bottom .any (.exactly 1)) .skip)) .skip) }],
    attacks := [
      { name := "Gentle Slap", cost := [.water, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Wishiwashi ex (me6-29). Records: me6-29, me6-120. Caveats: noopUse. -/
def me6_29 : Card := .pokemon
  { name := "Wishiwashi ex", stage := .basic, evolvesFrom := none,
    hp := 26, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Oceanic Gain", use := .once,
        spot := some .active, cond := none,
        effect := .self (.heal 5) }],
    attacks := [
      { name := "Hydro Splash", cost := [.water, .water, .water, .colorless], damage := 22,
        effect := .skip,
        gx := false }] }

/-- Electabuzz (me6-30). Records: me6-30. -/
def me6_30 : Card := .pokemon
  { name := "Electabuzz", stage := .basic, evolvesFrom := none,
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Headbutt", cost := [.lightning, .lightning, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Jolteon (me6-32). Records: me6-32. -/
def me6_32 : Card := .pokemon
  { name := "Jolteon", stage := .stage1, evolvesFrom := some "Eevee",
    hp := 11, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.lightning], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Thunderbolt", cost := [.lightning, .lightning, .lightning], damage := 22,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Rotom (me6-34). Records: me6-34. -/
def me6_34 : Card := .pokemon
  { name := "Rotom", stage := .basic, evolvesFrom := none,
    hp := 8, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunder Shock", cost := [.lightning, .colorless], damage := 5,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Pincurchin (me6-36). Records: me6-36, me6-109. -/
def me6_36 : Card := .pokemon
  { name := "Pincurchin", stage := .basic, evolvesFrom := none,
    hp := 8, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Energy Crush", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.energyAll .opp .energy) 2),
        gx := false }] }

/-- Pawmi (me6-37). Records: me6-37. -/
def me6_37 : Card := .pokemon
  { name := "Pawmi", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Quick Attack", cost := [.lightning], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Pawmo (me6-38). Records: me6-38. -/
def me6_38 : Card := .pokemon
  { name := "Pawmo", stage := .stage1, evolvesFrom := some "Pawmi",
    hp := 9, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electro Ball", cost := [.lightning], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Pawmot (me6-39). Records: me6-39. Caveats: mayFail. -/
def me6_39 : Card := .pokemon
  { name := "Pawmot", stage := .stage2, evolvesFrom := some "Pawmo",
    hp := 15, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Generator's Touch", use := .once,
        spot := none, cond := none,
        effect := .fx (.choice (.attach .own .discard (.energyOf .lightning) .active .any) (.attach .own .discard (.energyOf .lightning) .bench .any)) }],
    attacks := [
      { name := "Electric Punch", cost := [.lightning, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Drowzee (me6-43). Records: me6-43. -/
def me6_43 : Card := .pokemon
  { name := "Drowzee", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pound", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Hypno (me6-44). Records: me6-44. -/
def me6_44 : Card := .pokemon
  { name := "Hypno", stage := .stage1, evolvesFrom := some "Drowzee",
    hp := 12, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mind Ruler", cost := [.psychic], damage := 0,
        effect := .damage (.count (.pile .opp .hand .any) 2),
        gx := false },
      { name := "Hypnoblast", cost := [.psychic, .colorless], damage := 5,
        effect := .inflict .asleep,
        gx := false }] }

/-- Golett (me6-46). Records: me6-46. -/
def me6_46 : Card := .pokemon
  { name := "Golett", stage := .basic, evolvesFrom := none,
    hp := 9, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Light Punch", cost := [.psychic, .psychic], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Onix (me6-51). Records: me6-51. Caveats: perPokemon. -/
def me6_51 : Card := .pokemon
  { name := "Onix", stage := .basic, evolvesFrom := none,
    hp := 12, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Guard Press", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .linger .own .next (.reduce 3),
        gx := false }] }

/-- Nidoran♀ (me6-55). Records: me6-55. -/
def me6_55 : Card := .pokemon
  { name := "Nidoran♀", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Find a Friend", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle,
        gx := false },
      { name := "Gnaw", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Nidorina (me6-56). Records: me6-56. -/
def me6_56 : Card := .pokemon
  { name := "Nidorina", stage := .stage1, evolvesFrom := some "Nidoran♀",
    hp := 9, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.darkness, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Nidoqueen (me6-57). Records: me6-57. Caveats: noopUse, perPokemon. -/
def me6_57 : Card := .pokemon
  { name := "Nidoqueen", stage := .stage2, evolvesFrom := some "Nidorina",
    hp := 17, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Maternal Call", use := .once,
        spot := none, cond := none,
        effect := .fx (.choice (.switch .opp) .skip) }],
    attacks := [
      { name := "Giga Impact", cost := [.darkness, .colorless, .colorless], damage := 15,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Carvanha (me6-61). Records: me6-61. -/
def me6_61 : Card := .pokemon
  { name := "Carvanha", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ambush", cost := [.darkness, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Sharpedo (me6-62). Records: me6-62. -/
def me6_62 : Card := .pokemon
  { name := "Sharpedo", stage := .stage1, evolvesFrom := some "Carvanha",
    hp := 12, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Crunch", cost := [.darkness, .colorless], damage := 6,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Darkrai (me6-63). Records: me6-63. -/
def me6_63 : Card := .pokemon
  { name := "Darkrai", stage := .basic, evolvesFrom := none,
    hp := 12, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shadow-Clad", cost := [.darkness], damage := 0,
        effect := .seq (.seq (.attach .own .deck (.energyOf .darkness) .active .any) (.attach .own .deck (.energyOf .darkness) .active .any)) .shuffle,
        gx := false },
      { name := "Dark Cutter", cost := [.darkness, .darkness, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Purrloin (me6-64). Records: me6-64. -/
def me6_64 : Card := .pokemon
  { name := "Purrloin", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dig Claws", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Liepard (me6-65). Records: me6-65. -/
def me6_65 : Card := .pokemon
  { name := "Liepard", stage := .stage1, evolvesFrom := some "Purrloin",
    hp := 11, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Follow-Up Claw", cost := [.darkness], damage := 0,
        effect := .damage (.per .opp 2),
        gx := false },
      { name := "Slash", cost := [.darkness, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Zorua (me6-66). Records: me6-66, me6-112. -/
def me6_66 : Card := .pokemon
  { name := "Zorua", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stampede", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Scratch", cost := [.darkness, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Inkay (me6-68). Records: me6-68, me6-113. -/
def me6_68 : Card := .pokemon
  { name := "Inkay", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knock Off", cost := [.darkness], damage := 1,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

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

/-- Aarune (me6-89). Records: me6-89, me6-125, me6-139. Caveats: upTo0. -/
def me6_89 : Card := .trainer "Aarune" .supporter
    (.seq (.move .own .deck .hand (.or (.kind .supporter) (.kind .stadium)) (.upTo 3)) .shuffle)

/-- The cards of this part. -/
def cards : List Card := [
  me55_111,
  me55_112,
  me55_113,
  me55_114,
  me55_117,
  me55_122,
  me55_124,
  me6_1,
  me6_2,
  me6_4,
  me6_8,
  me6_9,
  me6_11,
  me6_12,
  me6_13,
  me6_15,
  me6_16,
  me6_17,
  me6_18,
  me6_19,
  me6_20,
  me6_24,
  me6_27,
  me6_28,
  me6_29,
  me6_30,
  me6_32,
  me6_34,
  me6_36,
  me6_37,
  me6_38,
  me6_39,
  me6_43,
  me6_44,
  me6_46,
  me6_51,
  me6_55,
  me6_56,
  me6_57,
  me6_61,
  me6_62,
  me6_63,
  me6_64,
  me6_65,
  me6_66,
  me6_68,
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
  me6_87,
  me6_89]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = [] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = [] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.reduces)).map Card.label = [] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = [] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 10 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 10)) = true := by decide +kernel

end PokemonCards.Standard.Part08
