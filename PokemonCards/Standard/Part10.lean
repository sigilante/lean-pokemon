/-
Imported Standard cards, part 10 of 11 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.18.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part10
open Pokemon

/-- Sizzlipede (me5-9). Records: me5-9. -/
def me5_9 : Card := .pokemon
  { name := "Sizzlipede", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Controlled Burn", cost := [.fire], damage := 0,
        effect := .move .opp (.top 1) .discard .any .all,
        gx := false },
      { name := "Bug Out", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .seq (.damage (.count (.pile .own (.bottom 7) (.and .pokemon (.hasAttack "Bug Out"))) 5)) (.look .own (.bottom 7) .pokemon .all (.put .shuffle) .discard),
        gx := false }] }

/-- Centiskorch (me5-10). Records: me5-10. Caveats: recoil. -/
def me5_10 : Card := .pokemon
  { name := "Centiskorch", stage := .stage1, evolvesFrom := some "Sizzlipede",
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Controlled Burn", cost := [.fire], damage := 0,
        effect := .move .opp (.top 2) .discard .any .all,
        gx := false },
      { name := "Heat Tackle", cost := [.fire, .colorless, .colorless, .colorless], damage := 16,
        effect := .selfDamage 3,
        gx := false }] }

/-- Charcadet (me5-11). Records: me5-11. -/
def me5_11 : Card := .pokemon
  { name := "Charcadet", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Best Punch", cost := [.fire], damage := 0,
        effect := .choice (.damage (.const 4)) .skip,
        gx := false }] }

/-- Goldeen (me5-13). Records: me5-13, me5-87. -/
def me5_13 : Card := .pokemon
  { name := "Goldeen", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pierce", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Wailmer (me5-15). Records: me5-15. -/
def me5_15 : Card := .pokemon
  { name := "Wailmer", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 4, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Water Gun", cost := [.water, .water], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Wave Splash", cost := [.water, .water, .water], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Popplio (me5-18). Records: me5-18. -/
def me5_18 : Card := .pokemon
  { name := "Popplio", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pound", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Brionne (me5-19). Records: me5-19. -/
def me5_19 : Card := .pokemon
  { name := "Brionne", stage := .stage1, evolvesFrom := some "Popplio",
    hp := 9, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hyper Voice", cost := [.water], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Finizen (me5-21). Records: me5-21. -/
def me5_21 : Card := .pokemon
  { name := "Finizen", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Draining Fin", cost := [.water, .water], damage := 2,
        effect := .heal 2,
        gx := false }] }

/-- Palafin (me5-22). Records: me5-22. -/
def me5_22 : Card := .pokemon
  { name := "Palafin", stage := .stage1, evolvesFrom := some "Finizen",
    hp := 15, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knuckle Justice", cost := [.water, .water], damage := 0,
        effect := .ite (.countGe (.prizes .opp) 1) (.ite (.countGe (.prizes .opp) 2) (.damage (.const 8)) (.damage (.const 28))) (.damage (.const 8)),
        gx := false }] }

/-- Electrike (me5-23). Records: me5-23. -/
def me5_23 : Card := .pokemon
  { name := "Electrike", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.lightning], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Tackle", cost := [.lightning, .lightning], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Charjabug (me5-25). Records: me5-25. -/
def me5_25 : Card := .pokemon
  { name := "Charjabug", stage := .stage1, evolvesFrom := some "Grubbin",
    hp := 10, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Vise Grip", cost := [.lightning], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Ram", cost := [.lightning, .lightning], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Mega Zeraora ex (me5-27). Records: me5-27, me5-98, me5-114. Caveats: energyOfCount. -/
def me5_27 : Card := .pokemon
  { name := "Mega Zeraora ex", stage := .basic, evolvesFrom := none,
    hp := 27, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunderous Fist", cost := [.lightning], damage := 0,
        effect := .damage (.count (.energy .own (.energyOf .lightning)) 6),
        gx := false },
      { name := "Zepto Turn", cost := [.lightning, .lightning, .lightning], damage := 15,
        effect := .switch .own,
        gx := false }] }

/-- Slowbro (me5-30). Records: me5-30, me5-90. -/
def me5_30 : Card := .pokemon
  { name := "Slowbro", stage := .stage1, evolvesFrom := some "Slowpoke",
    hp := 13, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "All Out", cost := [.psychic], damage := 0,
        effect := .ite (.countGe (.pile .own .hand .any) 1) (.damage (.const 5)) (.damage (.const 21)),
        gx := false },
      { name := "Zen Headbutt", cost := [.colorless, .colorless, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Litwick (me5-36). Records: me5-36. -/
def me5_36 : Card := .pokemon
  { name := "Litwick", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Will-O-Wisp", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Dhelmise (me5-39). Records: me5-39, me5-91. -/
def me5_39 : Card := .pokemon
  { name := "Dhelmise", stage := .basic, evolvesFrom := none,
    hp := 14, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Vengeful Anchor", cost := [.psychic], damage := 0,
        effect := .ite (.countGe (.pile .own .discard (.and .pokemon (.abilityNamed "Hide 'n' Sneak"))) 4) (.damage (.const 17)) (.damage (.const 3)),
        gx := false }] }

/-- Marshadow (me5-40). Records: me5-40. Caveats: printedRetreat. -/
def me5_40 : Card := .pokemon
  { name := "Marshadow", stage := .basic, evolvesFrom := none,
    hp := 9, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shadowy Knot", cost := [.psychic], damage := 0,
        effect := .damage (.count (.retreat .opp) 3),
        gx := false }] }

/-- Primeape (me5-43). Records: me5-43. -/
def me5_43 : Card := .pokemon
  { name := "Primeape", stage := .stage1, evolvesFrom := some "Mankey",
    hp := 11, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Corkscrew Punch", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Cranidos (me5-44). Records: me5-44. -/
def me5_44 : Card := .pokemon
  { name := "Cranidos", stage := .stage1, evolvesFrom := some "Antique Skull Fossil",
    hp := 10, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Push Down", cost := [.fighting, .fighting], damage := 7,
        effect := .switch .opp,
        gx := false }] }

/-- Rampardos ex (me5-45). Records: me5-45, me5-100. Caveats: perPokemon. -/
def me5_45 : Card := .pokemon
  { name := "Rampardos ex", stage := .stage2, evolvesFrom := some "Cranidos",
    hp := 33, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Destructive Headbutting", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.ite (.countGe (.energy .opp .energy) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.discardEnergy .opp .active .energy (.exactly 1)) .skip)) }],
    attacks := [
      { name := "Rowdy Hammer", cost := [.fighting, .fighting], damage := 15,
        effect := .linger .own .after (.bonus 15),
        gx := false }] }

/-- Drilbur (me5-46). Records: me5-46. -/
def me5_46 : Card := .pokemon
  { name := "Drilbur", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Dig Claws", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Koraidon (me5-47). Records: me5-47. -/
def me5_47 : Card := .pokemon
  { name := "Koraidon", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Battle Claw", cost := [.fighting], damage := 0,
        effect := .ite (.top .opp (.not .basic)) (.damage (.const 6)) (.damage (.const 3)),
        gx := false },
      { name := "Gaia Impact", cost := [.fighting, .fighting, .colorless], damage := 19,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Vullaby (me5-49). Records: me5-49. -/
def me5_49 : Card := .pokemon
  { name := "Vullaby", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flap", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Gust", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Inkay (me5-51). Records: me5-51. -/
def me5_51 : Card := .pokemon
  { name := "Inkay", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Procurement", cost := [.darkness], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .item) (.upTo 1)) .shuffle,
        gx := false },
      { name := "Spinning Attack", cost := [.darkness, .darkness], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Malamar (me5-52). Records: me5-52. -/
def me5_52 : Card := .pokemon
  { name := "Malamar", stage := .stage1, evolvesFrom := some "Inkay",
    hp := 12, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Perplex", cost := [.darkness], damage := 0,
        effect := .inflict .confused,
        gx := false },
      { name := "Brain Crush", cost := [.darkness], damage := 0,
        effect := .ite (.cond .opp .confused) (.damage (.const 13)) .skip,
        gx := false }] }

/-- Nickit (me5-53). Records: me5-53. -/
def me5_53 : Card := .pokemon
  { name := "Nickit", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Rear Kick", cost := [.darkness, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Morpeko ex (me5-55). Records: me5-55, me5-102, me5-117. -/
def me5_55 : Card := .pokemon
  { name := "Morpeko ex", stage := .basic, evolvesFrom := none,
    hp := 18, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Wheely Draw", cost := [.darkness], damage := 0,
        effect := .seq (.move .own .hand .shuffle .any .all) (.move .own (.top 6) .hand .any .all),
        gx := false },
      { name := "Hangry Blaster", cost := [.darkness, .darkness], damage := 0,
        effect := .damage (.add (.const 4) (.per .own 4)),
        gx := false }] }

/-- Maschiff (me5-57). Records: me5-57. -/
def me5_57 : Card := .pokemon
  { name := "Maschiff", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.darkness, .darkness], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Mabosstiff (me5-58). Records: me5-58. Caveats: perPokemon. -/
def me5_58 : Card := .pokemon
  { name := "Mabosstiff", stage := .stage1, evolvesFrom := some "Maschiff",
    hp := 14, type := .darkness, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.darkness, .darkness], damage := 6,
        effect := .skip,
        gx := false },
      { name := "Plunging Headbutt", cost := [.darkness, .darkness, .darkness], damage := 21,
        effect := .linger .own .next (.expose 10),
        gx := false }] }

/-- Chi-Yu (me5-59). Records: me5-59. -/
def me5_59 : Card := .pokemon
  { name := "Chi-Yu", stage := .basic, evolvesFrom := none,
    hp := 9, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Whirling Envy", cost := [.darkness], damage := 0,
        effect := .ite (.atLeast .own 2) (.damage (.const 11) { weak := true }) (.damage (.const 2) { weak := true }),
        gx := false }] }

/-- Skarmory (me5-60). Records: me5-60. -/
def me5_60 : Card := .pokemon
  { name := "Skarmory", stage := .basic, evolvesFrom := none,
    hp := 12, type := .metal, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Steel Cutter", cost := [.metal], damage := 0,
        effect := .choice (.choice (.seq (.move .own .hand .discard (.energyOf .metal) (.exactly 0)) (.damage (.const 0))) (.seq (.move .own .hand .discard (.energyOf .metal) (.exactly 1)) (.damage (.const 4)))) (.seq (.move .own .hand .discard (.energyOf .metal) (.exactly 2)) (.damage (.const 8))),
        gx := false }] }

/-- Shieldon (me5-61). Records: me5-61. -/
def me5_61 : Card := .pokemon
  { name := "Shieldon", stage := .stage1, evolvesFrom := some "Antique Armor Fossil",
    hp := 10, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smithereen Smash", cost := [.metal, .colorless], damage := 5,
        effect := .ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Bronzor (me5-63). Records: me5-63. -/
def me5_63 : Card := .pokemon
  { name := "Bronzor", stage := .basic, evolvesFrom := none,
    hp := 8, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mirror Attack", cost := [.metal], damage := 0,
        effect := .ite (.isType .opp .metal) (.damage (.const 4)) (.damage (.const 1)),
        gx := false }] }

/-- Mega Excadrill ex (me5-65). Records: me5-65, me5-103. -/
def me5_65 : Card := .pokemon
  { name := "Mega Excadrill ex", stage := .stage1, evolvesFrom := some "Drilbur",
    hp := 34, type := .metal, retreat := 4, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Undermine", cost := [.metal, .metal], damage := 9,
        effect := .move .opp (.top 2) .discard .any .all,
        gx := false },
      { name := "Maximum Drilling", cost := [.metal, .metal, .metal], damage := 0,
        effect := .ite (.countGe (.energy .own .energy) 5) (.damage (.const 33)) (.damage (.const 20)),
        gx := false }] }

/-- Pikipek (me5-66). Records: me5-66. -/
def me5_66 : Card := .pokemon
  { name := "Pikipek", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Stab", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- Trumbeak (me5-67). Records: me5-67. Caveats: perPokemon, shieldReach. -/
def me5_67 : Card := .pokemon
  { name := "Trumbeak", stage := .stage1, evolvesFrom := some "Pikipek",
    hp := 9, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fly", cost := [.colorless], damage := 0,
        effect := .choice (.seq (.damage (.const 3)) (.seq (.linger .own .next .prevent) (.linger .own .next .shield))) .skip,
        gx := false }] }

/-- Toucannon (me5-68). Records: me5-68, me5-94. -/
def me5_68 : Card := .pokemon
  { name := "Toucannon", stage := .stage2, evolvesFrom := some "Trumbeak",
    hp := 15, type := .colorless, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Aerial Draw", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 1) .hand .any .all)) }],
    attacks := [
      { name := "Feather Rondo", cost := [.colorless], damage := 0,
        effect := .damage (.add (.const 6) (.add (.count (.bench .own .pokemon) 2) (.count (.bench .opp .pokemon) 2))),
        gx := false }] }

/-- Type: Null (me5-69). Records: me5-69. -/
def me5_69 : Card := .pokemon
  { name := "Type: Null", stage := .basic, evolvesFrom := none,
    hp := 11, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Power Edge", cost := [.colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Silvally (me5-70). Records: me5-70, me5-95. -/
def me5_70 : Card := .pokemon
  { name := "Silvally", stage := .stage1, evolvesFrom := some "Type: Null",
    hp := 14, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Call a Buddy", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.seq (.ite (.countGe (.pile .own .hand .any) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.move .own .deck .hand (.kind .supporter) (.upTo 1)) .shuffle)) }],
    attacks := [
      { name := "Air Slash", cost := [.colorless, .colorless, .colorless], damage := 13,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Bombirdier (me5-71). Records: me5-71. -/
def me5_71 : Card := .pokemon
  { name := "Bombirdier", stage := .basic, evolvesFrom := none,
    hp := 10, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Challenging Delivery", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.seq (.putBench .own .deck .pokemon) .shuffle) .skip,
        gx := false },
      { name := "Speed Wing", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Rust Syndicate Grunt (me5-81). Records: me5-81, me5-112. Caveats: koCheckup. -/
def me5_81 : Card := .trainer "Rust Syndicate Grunt" .supporter
    (.seq (.ite (.countGe (.koLast .own false) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.energyAll .opp .energy) 1) (.choice (.discardEnergy .opp .active .energy (.exactly 1)) (.ite (.countGe (.bench .opp .pokemon) 1) (.discardEnergy .opp .bench .energy (.exactly 1)) (.move .own (.top 0) .hand .any (.exactly 1)))) (.move .own (.top 0) .hand .any (.exactly 1))))

/-- Voltaic Lightning Energy (me5-84). Records: me5-84. -/
def me5_84 : Card := .energy (.special "Voltaic Lightning Energy" [[.lightning]] { grant := { holder := .ptype .lightning, attacks := [], abilities := [], statics := [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .bonus 2 .any }] } })

/-- Exeggcute (me55-1). Records: me55-1. -/
def me55_1 : Card := .pokemon
  { name := "Exeggcute", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hypnosis", cost := [.colorless], damage := 0,
        effect := .inflict .asleep,
        gx := false }] }

/-- Alolan Exeggutor (me55-2). Records: me55-2, me55-129. Caveats: energyOfCount. -/
def me55_2 : Card := .pokemon
  { name := "Alolan Exeggutor", stage := .stage1, evolvesFrom := some "Exeggcute",
    hp := 15, type := .grass, retreat := 4, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Scale Up", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := some (.energyOf .grass, 6), eff := .hpPlus (.const 25) }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Mega Drain", cost := [.grass, .colorless, .colorless, .colorless], damage := 15,
        effect := .heal 5,
        gx := false }] }

/-- Volbeat (me55-3). Records: me55-3. -/
def me55_3 : Card := .pokemon
  { name := "Volbeat", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Luring Glow", cost := [.grass], damage := 0,
        effect := .switch .opp,
        gx := false },
      { name := "Bug Buzz", cost := [.colorless, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Tropius (me55-5). Records: me55-5. Caveats: koAttackWide. -/
def me55_5 : Card := .pokemon
  { name := "Tropius", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rally Back", cost := [.grass, .colorless], damage := 0,
        effect := .ite (.countGe (.koLast .own true) 1) (.damage (.const 12)) (.damage (.const 3)),
        gx := false },
      { name := "Cutting Wind", cost := [.grass, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Cherubi (me55-6). Records: me55-6. Caveats: perPokemon, shieldReach. -/
def me55_6 : Card := .pokemon
  { name := "Cherubi", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hide", cost := [.colorless], damage := 0,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false },
      { name := "Flop", cost := [.grass], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Cherrim (me55-7). Records: me55-7. -/
def me55_7 : Card := .pokemon
  { name := "Cherrim", stage := .stage1, evolvesFrom := some "Cherubi",
    hp := 8, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Energy Gift", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) .shuffle,
        gx := false },
      { name := "Leafage", cost := [.grass, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Vivillon (me55-8). Records: me55-8. -/
def me55_8 : Card := .pokemon
  { name := "Vivillon", stage := .stage2, evolvesFrom := some "Spewpa",
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Guiding Dance", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle) .skip)) }],
    attacks := [
      { name := "Poison Powder", cost := [.grass, .colorless], damage := 6,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Vulpix (me55-9). Records: me55-9. -/
def me55_9 : Card := .pokemon
  { name := "Vulpix", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wild Kick", cost := [.fire], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Ninetales (me55-10). Records: me55-10. -/
def me55_10 : Card := .pokemon
  { name := "Ninetales", stage := .stage1, evolvesFrom := some "Vulpix",
    hp := 11, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flame Tail", cost := [.fire], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Victini (me55-13). Records: me55-13. -/
def me55_13 : Card := .pokemon
  { name := "Victini", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "V-Flame", cost := [.fire, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Reshiram (me55-14). Records: me55-14. Caveats: energyOfCount. -/
def me55_14 : Card := .pokemon
  { name := "Reshiram", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.fire, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Laser Flame", cost := [.fire, .colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.damage (.const 16)) (.damage (.const 8)),
        gx := false }] }

/-- Fuecoco ex (me55-15). Records: me55-15, me55-147. Caveats: prizes6. -/
def me55_15 : Card := .pokemon
  { name := "Fuecoco ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Singe", cost := [.fire], damage := 0,
        effect := .inflict .burned,
        gx := false },
      { name := "Cheerful Flame", cost := [.fire, .fire, .colorless], damage := 0,
        effect := .damage (.count (.prizesTaken .own) 7),
        gx := false }] }

/-- Slowpoke (me55-16). Records: me55-16. Caveats: perPokemon, shieldReach. -/
def me55_16 : Card := .pokemon
  { name := "Slowpoke", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Well-Hidden", cost := [.colorless], damage := 0,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false },
      { name := "Water Gun", cost := [.water, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lapras (me55-17). Records: me55-17, me55-131. -/
def me55_17 : Card := .pokemon
  { name := "Lapras", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ferry Across", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .supporter) (.upTo 1)) .shuffle,
        gx := false },
      { name := "Ice Beam", cost := [.water, .colorless, .colorless], damage := 8,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Kyogre (me55-19). Records: me55-19. Caveats: energyOfCount. -/
def me55_19 : Card := .pokemon
  { name := "Kyogre", stage := .basic, evolvesFrom := none,
    hp := 14, type := .water, retreat := 4, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hydro Pump", cost := [.colorless, .colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 6) (.count (.energy .own (.energyOf .water)) 3)),
        gx := false }] }

/-- Palkia (me55-20). Records: me55-20. -/
def me55_20 : Card := .pokemon
  { name := "Palkia", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wormhole", cost := [.water, .water, .colorless], damage := 10,
        effect := .ifDone (.countGe (.bench .own .pokemon) 1) (.switch .own) (.switch .opp),
        gx := false }] }

/-- Pikachu (me55-23). Records: me55-23. -/
def me55_23 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunder Shock", cost := [.lightning, .colorless], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Pikachu (me55-24). Records: me55-24. Caveats: recoil. -/
def me55_24 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Volt Tackle", cost := [.lightning, .colorless, .colorless], damage := 8,
        effect := .selfDamage 3,
        gx := false }] }

/-- Pikachu (me55-25). Records: me55-25. Caveats: benchMods. -/
def me55_25 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spark", cost := [.lightning, .colorless], damage := 2,
        effect := .benchDamage .opp 2,
        gx := false }] }

/-- Pikachu (me55-26). Records: me55-26. Caveats: hiddenInfo. -/
def me55_26 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Peer At", cost := [.colorless], damage := 0,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-27). Records: me55-27. -/
def me55_27 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 8, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nap", cost := [.colorless], damage := 0,
        effect := .heal 3,
        gx := false }] }

/-- Pikachu (me55-29). Records: me55-29. -/
def me55_29 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Find a Friend", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle,
        gx := false }] }

/-- Pikachu (me55-30). Records: me55-30. -/
def me55_30 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mach Bolt", cost := [.lightning], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-31). Records: me55-31. -/
def me55_31 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 5, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-32). Records: me55-32. -/
def me55_32 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 5, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scurry About", cost := [.colorless], damage := 0,
        effect := .switch .own,
        gx := false }] }

/-- Pikachu (me55-34). Records: me55-34. -/
def me55_34 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pika Chain", cost := [.lightning, .lightning, .lightning], damage := 0,
        effect := .damage (.count (.inPlay .own (.or (.named "Pikachu") (.named "Pikachu ex"))) 4),
        gx := false }] }

/-- Pikachu (me55-35). Records: me55-35. -/
def me55_35 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rollout", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-36). Records: me55-36. Caveats: recoil. -/
def me55_36 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slight Intrusion", cost := [.lightning, .colorless], damage := 4,
        effect := .selfDamage 1,
        gx := false }] }

/-- Pikachu (me55-37). Records: me55-37. -/
def me55_37 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Energized Tail", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .energy (.upTo 1)) .shuffle,
        gx := false },
      { name := "Pika Punch", cost := [.lightning, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-38). Records: me55-38. Caveats: benchMods. -/
def me55_38 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Targeted Spark", cost := [.lightning], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 2)) (.benchDamage .opp 2)) (.damage (.const 2)),
        gx := false }] }

/-- Pikachu (me55-39). Records: me55-39. -/
def me55_39 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Iron Tail", cost := [.colorless], damage := 0,
        effect := .damage (.many (.const 2)),
        gx := false }] }

/-- Pikachu (me55-41). Records: me55-41. -/
def me55_41 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hang Down", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Zap Kick", cost := [.lightning, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-44). Records: me55-44. Caveats: perPokemon, shieldReach. -/
def me55_44 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Agility", cost := [.colorless], damage := 1,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false }] }

/-- Pikachu (me55-45). Records: me55-45. -/
def me55_45 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nightime Stroll", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Static Shock", cost := [.lightning, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-46). Records: me55-46. -/
def me55_46 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Get Some Air", cost := [.colorless], damage := 0,
        effect := .cure,
        gx := false },
      { name := "Smash Kick", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-47). Records: me55-47. -/
def me55_47 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Play Rough", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Pikachu (me55-48). Records: me55-48. -/
def me55_48 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Store Up", cost := [.colorless], damage := 0,
        effect := .move .own .discard .hand .basicEnergy (.upTo 2),
        gx := false }] }

/-- Pikachu (me55-49). Records: me55-49. -/
def me55_49 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 8, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fighting Lightning", cost := [.lightning, .colorless, .colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 10)) (.damage (.const 2)),
        gx := false }] }

/-- Pikachu (me55-50). Records: me55-50. -/
def me55_50 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 8, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Satisfied Spark", cost := [.lightning, .lightning, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me55-51). Records: me55-51. Caveats: benchMods, energyOfCount. -/
def me55_51 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lightning Crash", cost := [.lightning, .lightning, .lightning], damage := 0,
        effect := .seq (.discardEnergy .own .active (.energyOf .lightning) .all) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 9)) (.benchDamage .opp 9)) (.damage (.const 9))),
        gx := false }] }

/-- Pikachu (me55-52). Records: me55-52. -/
def me55_52 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Angry Bolt", cost := [.lightning], damage := 0,
        effect := .damage (.add (.const 1) (.per .own 1)),
        gx := false }] }

/-- Pikachu ex (me55-53). Records: me55-53, me55-149. -/
def me55_53 : Card := .pokemon
  { name := "Pikachu ex", stage := .basic, evolvesFrom := none,
    hp := 19, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Pika-Pika Parade", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.seq (.putBench .own .deck .basic) (.seq (.putBench .own .deck .basic) (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic))))) .shuffle,
        gx := false },
      { name := "Thunderbolt", cost := [.lightning, .lightning, .colorless], damage := 20,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Zekrom (me55-56). Records: me55-56. Caveats: energyOfCount. -/
def me55_56 : Card := .pokemon
  { name := "Zekrom", stage := .basic, evolvesFrom := none,
    hp := 13, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.lightning, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Nitro Thunder", cost := [.lightning, .colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.energy .own (.energyOf .fire)) 1) (.damage (.const 16)) (.damage (.const 8)),
        gx := false }] }

/-- Zeraora (me55-57). Records: me55-57. Caveats: benchMods. -/
def me55_57 : Card := .pokemon
  { name := "Zeraora", stage := .basic, evolvesFrom := none,
    hp := 11, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rapid Draw", cost := [.colorless], damage := 2,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Electrobullet", cost := [.lightning, .colorless], damage := 5,
        effect := .benchDamage .opp 2,
        gx := false }] }

/-- Toxel (me55-58). Records: me55-58. -/
def me55_58 : Card := .pokemon
  { name := "Toxel", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Toxtricity (me55-59). Records: me55-59. -/
def me55_59 : Card := .pokemon
  { name := "Toxtricity", stage := .stage1, evolvesFrom := some "Toxel",
    hp := 13, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mach Bolt", cost := [.lightning, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Toxtricity (me55-60). Records: me55-60, me55-134. -/
def me55_60 : Card := .pokemon
  { name := "Toxtricity", stage := .stage1, evolvesFrom := some "Toxel",
    hp := 14, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Light Punch", cost := [.lightning], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Thunderous Bolt", cost := [.lightning, .colorless, .colorless], damage := 15,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Miraidon (me55-62). Records: me55-62. Caveats: energyOfBasic, energyOfCount. -/
def me55_62 : Card := .pokemon
  { name := "Miraidon", stage := .basic, evolvesFrom := none,
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mach Bolt", cost := [.lightning], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Electro Drift", cost := [.lightning, .lightning, .colorless], damage := 14,
        effect := .ite (.countGe (.energy .own (.energyOf .lightning)) 2) (.discardEnergy .own .active (.energyOf .lightning) (.exactly 2)) (.discardEnergy .own .active (.energyOf .lightning) .all),
        gx := false }] }

/-- Mewtwo ex (me55-64). Records: me55-64, me55-151, me55-157. Caveats: benchMods. -/
def me55_64 : Card := .pokemon
  { name := "Mewtwo ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Photon Bullets", cost := [.psychic, .psychic], damage := 0,
        effect := .seq (.ite (.top .opp .ex) (.damage (.const 5)) .skip) (.benchSome .opp 5 .ex true 5),
        gx := false },
      { name := "Psychic Powers", cost := [.psychic, .psychic, .psychic], damage := 23,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Mew (me55-65). Records: me55-65, me55-B, me55-G, me55-R. Caveats: energyUnitsCount. -/
def me55_65 : Card := .pokemon
  { name := "Mew", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Psychic", cost := [.psychic, .psychic], damage := 0,
        effect := .damage (.add (.const 1) (.count (.energy .opp .energy) 4)),
        gx := false }] }

/-- Marill (me55-67). Records: me55-67. -/
def me55_67 : Card := .pokemon
  { name := "Marill", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.psychic, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Azumarill (me55-68). Records: me55-68. -/
def me55_68 : Card := .pokemon
  { name := "Azumarill", stage := .stage1, evolvesFrom := some "Marill",
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Body Slam", cost := [.psychic, .psychic, .colorless], damage := 9,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Espeon ex (me55-70). Records: me55-70. -/
def me55_70 : Card := .pokemon
  { name := "Espeon ex", stage := .stage1, evolvesFrom := some "Eevee",
    hp := 26, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Solar Beatdown", cost := [.psychic, .colorless], damage := 0,
        effect := .damage (.add (.const 3) (.count (.bench .own .pokemon) 3)),
        gx := false }] }

/-- Sylveon ex (me55-71). Records: me55-71, me55-153. -/
def me55_71 : Card := .pokemon
  { name := "Sylveon ex", stage := .stage1, evolvesFrom := some "Eevee",
    hp := 27, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Colorful Harmony", cost := [.psychic, .colorless, .colorless], damage := 0,
        effect := .damage (.count (.energyTypes .own) 5),
        gx := false }] }

/-- Cresselia (me55-74). Records: me55-74. -/
def me55_74 : Card := .pokemon
  { name := "Cresselia", stage := .basic, evolvesFrom := none,
    hp := 12, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aurora Gain", cost := [.psychic, .colorless], damage := 3,
        effect := .heal 3,
        gx := false },
      { name := "Lunar Blast", cost := [.psychic, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Chandelure (me55-75). Records: me55-75, me55-137. -/
def me55_75 : Card := .pokemon
  { name := "Chandelure", stage := .stage2, evolvesFrom := some "Lampent",
    hp := 14, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Eerie Glow", cost := [.psychic, .psychic], damage := 13,
        effect := .seq (.inflict .burned) (.inflict .confused),
        gx := false }] }

/-- Xerneas (me55-76). Records: me55-76. -/
def me55_76 : Card := .pokemon
  { name := "Xerneas", stage := .basic, evolvesFrom := none,
    hp := 12, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Geonavigation", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .stadium) (.upTo 2)) .shuffle,
        gx := false },
      { name := "Aurora Horns", cost := [.psychic, .psychic, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Comfey (me55-77). Records: me55-77. -/
def me55_77 : Card := .pokemon
  { name := "Comfey", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Comforting Aroma", cost := [.colorless], damage := 0,
        effect := .benchHeal 8,
        gx := false },
      { name := "Magical Shot", cost := [.psychic], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Cosmog (me55-78). Records: me55-78. -/
def me55_78 : Card := .pokemon
  { name := "Cosmog", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Splash", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Cosmoem (me55-79). Records: me55-79. Caveats: perPokemon. -/
def me55_79 : Card := .pokemon
  { name := "Cosmoem", stage := .stage1, evolvesFrom := some "Cosmog",
    hp := 10, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stiffen", cost := [.colorless, .colorless], damage := 0,
        effect := .linger .own .next (.reduce 6),
        gx := false }] }

/-- Lunala (me55-80). Records: me55-80. -/
def me55_80 : Card := .pokemon
  { name := "Lunala", stage := .stage2, evolvesFrom := some "Cosmoem",
    hp := 16, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Midnight Ray", cost := [.psychic], damage := 0,
        effect := .damage (.add (.const 2) (.count (.pile .own .discard .energy) 2)),
        gx := false },
      { name := "Lunar Blast", cost := [.psychic, .colorless, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Gimmighoul (me55-81). Records: me55-81. Caveats: searchAny. -/
def me55_81 : Card := .pokemon
  { name := "Gimmighoul", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Strolls So Much", cost := [.colorless], damage := 0,
        effect := .choice (.seq (.move .own .deck .hand .any (.upTo 1)) .shuffle) .skip,
        gx := false }] }

/-- Groudon (me55-82). Records: me55-82. Caveats: benchMods. -/
def me55_82 : Card := .pokemon
  { name := "Groudon", stage := .basic, evolvesFrom := none,
    hp := 14, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Break Ground", cost := [.fighting, .fighting, .fighting, .fighting, .fighting], damage := 25,
        effect := .spreadDamage .own 2,
        gx := false }] }

/-- Lucario (me55-83). Records: me55-83. Caveats: benchMods. -/
def me55_83 : Card := .pokemon
  { name := "Lucario", stage := .stage1, evolvesFrom := some "Riolu",
    hp := 12, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aura Sphere", cost := [.fighting, .fighting, .colorless], damage := 10,
        effect := .benchDamage .opp 6,
        gx := false }] }

/-- Koraidon (me55-86). Records: me55-86. Caveats: energyOfBasic, energyOfCount. -/
def me55_86 : Card := .pokemon
  { name := "Koraidon", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Low Kick", cost := [.fighting, .fighting], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Collision Course", cost := [.fighting, .fighting, .colorless], damage := 14,
        effect := .ite (.countGe (.energy .own (.energyOf .fighting)) 2) (.discardEnergy .own .active (.energyOf .fighting) (.exactly 2)) (.discardEnergy .own .active (.energyOf .fighting) .all),
        gx := false }] }

/-- Nidoran ♀ (me55-87). Records: me55-87. Caveats: benchMods, perPokemon. -/
def me55_87 : Card := .pokemon
  { name := "Nidoran ♀", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Growl", cost := [.colorless], damage := 0,
        effect := .linger .opp .next (.weaken 3),
        gx := false },
      { name := "Headbutt", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Nidorina (me55-88). Records: me55-88. Caveats: noopUse. -/
def me55_88 : Card := .pokemon
  { name := "Nidorina", stage := .stage1, evolvesFrom := some "Nidoran ♀",
    hp := 9, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Share Happiness", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.atLeast .own 1) .skip (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.ite (.countGe (.bench .own .pokemon) 1) (.choice (.heal 3) (.benchHeal 3)) (.heal 3))) }],
    attacks := [
      { name := "Bite", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Alolan Meowth (me55-89). Records: me55-89, me55-139. -/
def me55_89 : Card := .pokemon
  { name := "Alolan Meowth", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pay Day", cost := [], damage := 1,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false }] }

/-- Umbreon (me55-91). Records: me55-91. Caveats: koAttackWide. -/
def me55_91 : Card := .pokemon
  { name := "Umbreon", stage := .stage1, evolvesFrom := some "Eevee",
    hp := 11, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Retaliate", cost := [.darkness], damage := 0,
        effect := .ite (.countGe (.koLast .own true) 1) (.damage (.const 13)) (.damage (.const 3)),
        gx := false },
      { name := "Darkness Fang", cost := [.darkness, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Umbreon ex (me55-92). Records: me55-92. -/
def me55_92 : Card := .pokemon
  { name := "Umbreon ex", stage := .stage1, evolvesFrom := some "Eevee",
    hp := 27, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Lunatic Claw", cost := [.darkness, .colorless], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 24)) (.damage (.const 10)),
        gx := false }] }

/-- Scraggy (me55-94). Records: me55-94, me55-140. -/
def me55_94 : Card := .pokemon
  { name := "Scraggy", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nitpick", cost := [.darkness], damage := 0,
        effect := .seq (.move .opp .hand .shuffle .any .all) (.move .opp (.top 4) .hand .any .all),
        gx := false },
      { name := "Corkscrew Punch", cost := [.darkness, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Zorua (me55-95). Records: me55-95. -/
def me55_95 : Card := .pokemon
  { name := "Zorua", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Darkness Fang", cost := [.darkness, .darkness], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Deino (me55-97). Records: me55-97. -/
def me55_97 : Card := .pokemon
  { name := "Deino", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Headbutt", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Zweilous (me55-98). Records: me55-98. -/
def me55_98 : Card := .pokemon
  { name := "Zweilous", stage := .stage1, evolvesFrom := some "Deino",
    hp := 10, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Hammer In", cost := [.darkness, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Hydreigon (me55-99). Records: me55-99. -/
def me55_99 : Card := .pokemon
  { name := "Hydreigon", stage := .stage2, evolvesFrom := some "Zweilous",
    hp := 17, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Three-Headed Bite", cost := [.darkness], damage := 0,
        effect := .choice .skip (.choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) (.choice (.seq (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip)) (.seq (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) (.seq (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip))))),
        gx := false },
      { name := "Pitch-Black Fangs", cost := [.darkness, .colorless], damage := 14,
        effect := .skip,
        gx := false }] }

/-- Galarian Meowth (me55-101). Records: me55-101, me55-141. -/
def me55_101 : Card := .pokemon
  { name := "Galarian Meowth", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pay Day", cost := [.colorless], damage := 1,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Treasure Rush", cost := [.metal], damage := 0,
        effect := .damage (.count (.pile .own .hand .any) 1),
        gx := false }] }

/-- Jirachi ex (me55-102). Records: me55-102, me55-155. Caveats: ignFxStadium. -/
def me55_102 : Card := .pokemon
  { name := "Jirachi ex", stage := .basic, evolvesFrom := none,
    hp := 16, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 2), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Wish Granter", cost := [.colorless], damage := 0,
        effect := .drawTo .own 7,
        gx := false },
      { name := "Swift", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.const 15) { weak := true, resist := true, fx := true },
        gx := false }] }

/-- Dialga (me55-103). Records: me55-103. -/
def me55_103 : Card := .pokemon
  { name := "Dialga", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reversed Clock", cost := [.colorless], damage := 0,
        effect := .move .own .discard .shuffle (.or .pokemon .basicEnergy) (.upTo 3),
        gx := false },
      { name := "Heavy Impact", cost := [.metal, .metal, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Ferrothorn (me55-104). Records: me55-104. Caveats: benchMods, recoil. -/
def me55_104 : Card := .pokemon
  { name := "Ferrothorn", stage := .stage1, evolvesFrom := some "Ferroseed",
    hp := 13, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spike Sting", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Kaboom Needles", cost := [.metal, .metal], damage := 0,
        effect := .seq (.damage (.const 5)) (.seq (.spreadDamage .opp 5) (.selfDamage 13)),
        gx := false }] }

/-- Solgaleo (me55-105). Records: me55-105. Caveats: selfBench, upTo0. -/
def me55_105 : Card := .pokemon
  { name := "Solgaleo", stage := .stage2, evolvesFrom := some "Cosmoem",
    hp := 17, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Sunrise", use := .once,
        spot := some .bench, cond := none,
        effect := .seq (.fx (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.seq (.self (.attach .deck (.energyOf .metal))) (.self (.attach .deck (.energyOf .metal)))) (.fx .shuffle)) }],
    attacks := [
      { name := "Sunsteel Strike", cost := [.metal, .metal, .colorless, .colorless], damage := 22,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Zacian (me55-106). Records: me55-106. -/
def me55_106 : Card := .pokemon
  { name := "Zacian", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hardened Blade", cost := [.metal], damage := 0,
        effect := .ite (.hasTool .own) (.damage (.const 6)) (.damage (.const 2)),
        gx := false },
      { name := "Slashing Strike", cost := [.metal, .metal, .colorless], damage := 12,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Zamazenta (me55-107). Records: me55-107. Caveats: perPokemon. -/
def me55_107 : Card := .pokemon
  { name := "Zamazenta", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fend Off", cost := [.metal], damage := 0,
        effect := .seq (.discardTools .opp .active) (.damage (.const 2)),
        gx := false },
      { name := "Shield Press", cost := [.metal, .metal, .colorless], damage := 10,
        effect := .linger .own .next (.reduce 5),
        gx := false }] }

/-- Salamence ex (me55-109). Records: me55-109, me55-156. -/
def me55_109 : Card := .pokemon
  { name := "Salamence ex", stage := .stage2, evolvesFrom := some "Shelgon",
    hp := 33, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Booming Call", cost := [.colorless], damage := 0,
        effect := .seq (.putBench .own .discard (.ptype .dragon)) (.seq (.putBench .own .discard (.ptype .dragon)) (.putBench .own .discard (.ptype .dragon))),
        gx := false },
      { name := "Dragon Pulse", cost := [.fire, .water], damage := 24,
        effect := .move .own (.top 2) .discard .any .all,
        gx := false }] }

/-- Jangmo-o (me55-110). Records: me55-110. Caveats: perPokemon. -/
def me55_110 : Card := .pokemon
  { name := "Jangmo-o", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Screech", cost := [.colorless], damage := 0,
        effect := .linger .opp .after (.expose 3),
        gx := false },
      { name := "Dragon Claw", cost := [.lightning, .fighting], damage := 4,
        effect := .skip,
        gx := false }] }

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

/-- Eevee (me55-116). Records: me55-116. -/
def me55_116 : Card := .pokemon
  { name := "Eevee", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fetch and Hide", cost := [.colorless], damage := 0,
        effect := .move .opp .hand .bottom (.kind .item) (.most 1),
        gx := false },
      { name := "Tackle", cost := [.colorless], damage := 1,
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

/-- Igglybuff (me55-120). Records: me55-120. Caveats: printedMaxHP. -/
def me55_120 : Card := .pokemon
  { name := "Igglybuff", stage := .basic, evolvesFrom := none,
    hp := 3, type := .colorless, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bouncy Circle", cost := [], damage := 0,
        effect := .damage (.count (.bench .own (.and .pokemon (.and (.hpLe 3) (.not (.hpLe 2))))) 3),
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
        effect := .seq (.discardEnergy .own .active .energy .all) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 12)) (.benchDamage .opp 12)) (.damage (.const 12))),
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

/-- Masquerain (me6-3). Records: me6-3, me6-104. Caveats: perPokemon. -/
def me6_3 : Card := .pokemon
  { name := "Masquerain", stage := .stage1, evolvesFrom := some "Surskit",
    hp := 11, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Frightening Pattern", cost := [.colorless], damage := 3,
        effect := .linger .opp .next (.lock .attack),
        gx := false },
      { name := "Bug Out", cost := [.grass], damage := 0,
        effect := .seq (.damage (.count (.pile .own (.bottom 7) (.and .pokemon (.hasAttack "Bug Out"))) 5)) (.look .own (.bottom 7) .pokemon .all (.put .shuffle) .discard),
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

/-- Cacturne (me6-5). Records: me6-5. Caveats: abilityByTool, benchMods. -/
def me6_5 : Card := .pokemon
  { name := "Cacturne", stage := .stage1, evolvesFrom := some "Cacnea",
    hp := 13, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Linear Attack", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 3)) (.benchDamage .opp 3)) (.damage (.const 3)),
        gx := false },
      { name := "Punishing Needles", cost := [.grass], damage := 0,
        effect := .damage (.add (.const 1) (.count (.inPlay .opp (.and .pokemon .hasAbility)) 5)),
        gx := false }] }

/-- Vespiquen (me6-7). Records: me6-7. -/
def me6_7 : Card := .pokemon
  { name := "Vespiquen", stage := .stage1, evolvesFrom := some "Combee",
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pierce", cost := [.grass], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Clean Hit", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .ite (.top .opp (.not .basic)) (.damage (.const 16)) (.damage (.const 8)),
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

/-- Arboliva (me6-17). Records: me6-17. -/
def me6_17 : Card := .pokemon
  { name := "Arboliva", stage := .stage2, evolvesFrom := some "Dolliv",
    hp := 15, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Slippery Oil", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.bench .opp .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.switch .opp)) }],
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

/-- The cards of this part. -/
def cards : List Card := [
  me5_9,
  me5_10,
  me5_11,
  me5_13,
  me5_15,
  me5_18,
  me5_19,
  me5_21,
  me5_22,
  me5_23,
  me5_25,
  me5_27,
  me5_30,
  me5_36,
  me5_39,
  me5_40,
  me5_43,
  me5_44,
  me5_45,
  me5_46,
  me5_47,
  me5_49,
  me5_51,
  me5_52,
  me5_53,
  me5_55,
  me5_57,
  me5_58,
  me5_59,
  me5_60,
  me5_61,
  me5_63,
  me5_65,
  me5_66,
  me5_67,
  me5_68,
  me5_69,
  me5_70,
  me5_71,
  me5_81,
  me5_84,
  me55_1,
  me55_2,
  me55_3,
  me55_5,
  me55_6,
  me55_7,
  me55_8,
  me55_9,
  me55_10,
  me55_13,
  me55_14,
  me55_15,
  me55_16,
  me55_17,
  me55_19,
  me55_20,
  me55_23,
  me55_24,
  me55_25,
  me55_26,
  me55_27,
  me55_29,
  me55_30,
  me55_31,
  me55_32,
  me55_34,
  me55_35,
  me55_36,
  me55_37,
  me55_38,
  me55_39,
  me55_41,
  me55_44,
  me55_45,
  me55_46,
  me55_47,
  me55_48,
  me55_49,
  me55_50,
  me55_51,
  me55_52,
  me55_53,
  me55_56,
  me55_57,
  me55_58,
  me55_59,
  me55_60,
  me55_62,
  me55_64,
  me55_65,
  me55_67,
  me55_68,
  me55_70,
  me55_71,
  me55_74,
  me55_75,
  me55_76,
  me55_77,
  me55_78,
  me55_79,
  me55_80,
  me55_81,
  me55_82,
  me55_83,
  me55_86,
  me55_87,
  me55_88,
  me55_89,
  me55_91,
  me55_92,
  me55_94,
  me55_95,
  me55_97,
  me55_98,
  me55_99,
  me55_101,
  me55_102,
  me55_103,
  me55_104,
  me55_105,
  me55_106,
  me55_107,
  me55_109,
  me55_110,
  me55_111,
  me55_112,
  me55_113,
  me55_114,
  me55_116,
  me55_117,
  me55_120,
  me55_122,
  me55_124,
  me6_1,
  me6_2,
  me6_3,
  me6_4,
  me6_5,
  me6_7,
  me6_8,
  me6_9,
  me6_11,
  me6_12,
  me6_13,
  me6_15,
  me6_16,
  me6_17,
  me6_18,
  me6_19]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing, a Special Energy card whose payload models nothing or sets `rest`). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = ["Alolan Exeggutor"] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Voltaic Lightning Energy"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = [] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = [] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 25 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 25)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = [] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.koByAttack` (milestone M8b), by name. -/
theorem cards_trigKO : (cards.filter (Card.hasTrig .koByAttack)).map Card.label = [] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.oppBenched` (milestone MV7) (milestone M8b), by name. -/
theorem cards_trigBenched : (cards.filter (Card.hasTrig .oppBenched)).map Card.label = [] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.movedUp` (milestone MV7c) (milestone M8b), by name. -/
theorem cards_trigMovedUp : (cards.filter (Card.hasTrig .movedUp)).map Card.label = [] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.movedDown` (milestone MV7c) (milestone M8b), by name. -/
theorem cards_trigMovedDown : (cards.filter (Card.hasTrig .movedDown)).map Card.label = [] := by decide +kernel

/-- The cards of this part whose triggered Abilities write a lingering modifier (milestone M8b), by name. -/
theorem cards_trigLingers : (cards.filter Card.trigLingers).map Card.label = [] := by decide +kernel

/-- The cards of this part whose triggered Abilities can return a card from a discard pile (milestone M8b), by name. -/
theorem cards_trigRecycles : (cards.filter Card.trigRecycles).map Card.label = [] := by decide +kernel

/-- Every triggered Ability of this part has no printed condition and an effect of the trigger
fragment (`Card.trigsOk`). -/
theorem cards_trigsOk : cards.all Card.trigsOk = true := by decide +kernel

/-- The cards of this part that are not `Card.tame` (a `drain` attack or a stored damage reduction), by
name. -/
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Mabosstiff", "Cosmoem", "Nidoran ♀", "Zamazenta", "Jangmo-o"] := by decide +kernel

end PokemonCards.Standard.Part10
