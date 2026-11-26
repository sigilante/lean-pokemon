/-
Imported Standard cards, part 9 of 11 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.20.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part09
open Pokemon

/-- Pikachu (me2pt5-55). Records: me2pt5-55. -/
def me2pt5_55 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tail Smack", cost := [.lightning], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Tiny Bolt", cost := [.lightning, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Raichu (me2pt5-56). Records: me2pt5-56. Caveats: energyOfBasic, energyOfCount. -/
def me2pt5_56 : Card := .pokemon
  { name := "Raichu", stage := .stage1, evolvesFrom := some "Pikachu",
    hp := 13, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Quick Blow", cost := [.lightning], damage := 0,
        effect := .choice (.damage (.const 7)) (.damage (.const 2)),
        gx := false },
      { name := "Strong Volt", cost := [.lightning, .lightning, .colorless], damage := 15,
        effect := .ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.discardEnergy .own .active (.energyOf .lightning) (.exactly 1)) .skip,
        gx := false }] }

/-- Voltorb ex (me2pt5-58). Records: me2pt5-58. -/
def me2pt5_58 : Card := .pokemon
  { name := "Voltorb ex", stage := .basic, evolvesFrom := none,
    hp := 17, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Hundred-Hitting Ball", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 10) (.many (.const 10))),
        gx := false }] }

/-- Stunfisk (me2pt5-62). Records: me2pt5-62. Caveats: perPokemon. -/
def me2pt5_62 : Card := .pokemon
  { name := "Stunfisk", stage := .basic, evolvesFrom := none,
    hp := 11, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pouncing Trap", cost := [.lightning], damage := 3,
        effect := .seq (.linger .opp .next (.lock .retreat)) (.linger .opp .after (.expose 10)),
        gx := false }] }

/-- Helioptile (me2pt5-63). Records: me2pt5-63. -/
def me2pt5_63 : Card := .pokemon
  { name := "Helioptile", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Zap Kick", cost := [.lightning, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Heliolisk (me2pt5-64). Records: me2pt5-64, me2pt5-229. Caveats: selfBench, upTo0. -/
def me2pt5_64 : Card := .pokemon
  { name := "Heliolisk", stage := .stage1, evolvesFrom := some "Helioptile",
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Frilled Generator", use := .once,
        spot := none, cond := some (.countGe (.played .own (.and (.kind .supporter) (.named "Canari"))) 1),
        effect := .seq (.fx (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.seq (.self (.attach .deck (.energyOf .lightning))) (.self (.attach .deck (.energyOf .lightning)))) (.fx .shuffle)) }],
    attacks := [
      { name := "Powerful Bolt", cost := [.lightning, .colorless, .colorless], damage := 0,
        effect := .damage (.heads (.count (.energy .own .energy) 1) 7),
        gx := false }] }

/-- Hop's Pincurchin ex (me2pt5-68). Records: me2pt5-68. Caveats: trigAttacker, trigDamaged. -/
def me2pt5_68 : Card := .pokemon
  { name := "Hop's Pincurchin ex", stage := .basic, evolvesFrom := none,
    hp := 20, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Counterattack Quills", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.counters 3) }],
    attacks := [
      { name := "Spiky Thunder", cost := [.lightning, .lightning, .colorless], damage := 12,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false }] }

/-- Miraidon ex (me2pt5-73). Records: me2pt5-73. -/
def me2pt5_73 : Card := .pokemon
  { name := "Miraidon ex", stage := .basic, evolvesFrom := none,
    hp := 22, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Slashing Claw", cost := [.lightning], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Hadron Spark", cost := [.lightning, .lightning, .colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 24)) (.damage (.const 12)),
        gx := false }] }

/-- Team Rocket's Exeggcute (me2pt5-77). Records: me2pt5-77. -/
def me2pt5_77 : Card := .pokemon
  { name := "Team Rocket's Exeggcute", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Focused Wish", cost := [.psychic], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Team Rocket's Exeggutor (me2pt5-78). Records: me2pt5-78. Caveats: koCounters, recoil. -/
def me2pt5_78 : Card := .pokemon
  { name := "Team Rocket's Exeggutor", stage := .stage1, evolvesFrom := some "Team Rocket's Exeggcute",
    hp := 14, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tri Kinesis", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 9999) (.benchCounters .opp 9999)) (.counters 9999)) .skip,
        gx := false },
      { name := "Double-Edge", cost := [.psychic, .colorless, .colorless], damage := 15,
        effect := .selfDamage 3,
        gx := false }] }

/-- Marill (me2pt5-83). Records: me2pt5-83, me2pt5-232. Caveats: perPokemon, shieldReach. -/
def me2pt5_83 : Card := .pokemon
  { name := "Marill", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hide", cost := [.colorless], damage := 0,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false },
      { name := "Flop", cost := [.psychic, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Azumarill ex (me2pt5-84). Records: me2pt5-84. Caveats: energyOfCount, moveAnyPair, moveMayFail. -/
def me2pt5_84 : Card := .pokemon
  { name := "Azumarill ex", stage := .stage1, evolvesFrom := some "Marill",
    hp := 27, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Bubble Gathering", use := .unlimited,
        spot := none, cond := none,
        effect := .seq (.fx (.seq (.ite (.countGe (.energyAll .own .energy) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))))) (.self (.energyTo .energy)) }],
    attacks := [
      { name := "Energized Balloon", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 6) (.count (.energy .own (.energyOf .psychic)) 4)),
        gx := false }] }

/-- Mismagius (me2pt5-86). Records: me2pt5-86. -/
def me2pt5_86 : Card := .pokemon
  { name := "Mismagius", stage := .stage1, evolvesFrom := some "Misdreavus",
    hp := 11, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Assassin's Magic", cost := [.psychic, .colorless], damage := 6,
        effect := .ite (.cond .opp .asleep) (.benchCounters .opp 6) (.ite (.cond .opp .burned) (.benchCounters .opp 6) (.ite (.cond .opp .confused) (.benchCounters .opp 6) (.ite (.cond .opp .paralyzed) (.benchCounters .opp 6) (.ite (.cond .opp .poisoned) (.benchCounters .opp 6) .skip)))),
        gx := false }] }

/-- Swirlix (me2pt5-93). Records: me2pt5-93. -/
def me2pt5_93 : Card := .pokemon
  { name := "Swirlix", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Slurpuff (me2pt5-94). Records: me2pt5-94, me2pt5-236. -/
def me2pt5_94 : Card := .pokemon
  { name := "Slurpuff", stage := .stage1, evolvesFrom := some "Swirlix",
    hp := 12, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.psychic], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Magical Shot", cost := [.psychic, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Hop's Phantump (me2pt5-95). Records: me2pt5-95. Caveats: perPokemon, shieldReach. -/
def me2pt5_95 : Card := .pokemon
  { name := "Hop's Phantump", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Splashing Dodge", cost := [.colorless], damage := 1,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false }] }

/-- Team Rocket's Diglett (me2pt5-100). Records: me2pt5-100. -/
def me2pt5_100 : Card := .pokemon
  { name := "Team Rocket's Diglett", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Relentless Burrowing", cost := [.fighting], damage := 0,
        effect := .iter (.move .opp (.top 1) .discard .any .all),
        gx := false }] }

/-- Hitmontop (me2pt5-102). Records: me2pt5-102, me2pt5-240. -/
def me2pt5_102 : Card := .pokemon
  { name := "Hitmontop", stage := .basic, evolvesFrom := none,
    hp := 10, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spin and Draw", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .hand .shuffle .any .all) (.move .own (.top 6) .hand .any .all),
        gx := false },
      { name := "Low Kick", cost := [.fighting, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Meditite (me2pt5-103). Records: me2pt5-103. -/
def me2pt5_103 : Card := .pokemon
  { name := "Meditite", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Gentle Slap", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Medicham (me2pt5-104). Records: me2pt5-104, me2pt5-241. -/
def me2pt5_104 : Card := .pokemon
  { name := "Medicham", stage := .stage1, evolvesFrom := some "Meditite",
    hp := 12, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Seventh Kick", cost := [.fighting], damage := 0,
        effect := .ite (.countGe (.pile .own .hand .any) 7) (.ite (.countGe (.pile .own .hand .any) 8) .skip (.damage (.const 15))) .skip,
        gx := false }] }

/-- Groudon (me2pt5-108). Records: me2pt5-108. Caveats: recoil. -/
def me2pt5_108 : Card := .pokemon
  { name := "Groudon", stage := .basic, evolvesFrom := none,
    hp := 14, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hammer In", cost := [.fighting, .fighting, .colorless], damage := 8,
        effect := .skip,
        gx := false },
      { name := "Megaton Fall", cost := [.fighting, .fighting, .colorless, .colorless], damage := 15,
        effect := .selfDamage 3,
        gx := false }] }

/-- Stunfisk ex (me2pt5-114). Records: me2pt5-114, me2pt5-252. Caveats: perPokemon. -/
def me2pt5_114 : Card := .pokemon
  { name := "Stunfisk ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Big Bite", cost := [.fighting], damage := 3,
        effect := .linger .opp .next (.lock .retreat),
        gx := false },
      { name := "Flopping Trap", cost := [.fighting, .colorless, .colorless], damage := 0,
        effect := .ite (.atLeast .own 1) (.damage (.const 20)) (.damage (.const 10)),
        gx := false }] }

/-- Pancham (me2pt5-115). Records: me2pt5-115. Caveats: recoil. -/
def me2pt5_115 : Card := .pokemon
  { name := "Pancham", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.colorless], damage := 2,
        effect := .selfDamage 1,
        gx := false }] }

/-- Rolycoly (me2pt5-118). Records: me2pt5-118. -/
def me2pt5_118 : Card := .pokemon
  { name := "Rolycoly", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mud-Slap", cost := [.fighting], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Carkol (me2pt5-119). Records: me2pt5-119. Caveats: perPokemon. -/
def me2pt5_119 : Card := .pokemon
  { name := "Carkol", stage := .stage1, evolvesFrom := some "Rolycoly",
    hp := 11, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Guard Press", cost := [.fighting], damage := 2,
        effect := .linger .own .next (.reduce 2),
        gx := false },
      { name := "Power Gem", cost := [.fighting, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Coalossal (me2pt5-120). Records: me2pt5-120. Caveats: benchMods, discardUnits. -/
def me2pt5_120 : Card := .pokemon
  { name := "Coalossal", stage := .stage2, evolvesFrom := some "Carkol",
    hp := 18, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tar Cannon", cost := [.fighting], damage := 0,
        effect := .ite (.countGe (.pile .own .discard (.energyOf .fighting)) 10) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 14)) (.benchDamage .opp 14)) (.damage (.const 14))) .skip,
        gx := false },
      { name := "Bulky Bump", cost := [.fighting, .colorless, .colorless, .colorless], damage := 22,
        effect := .ite (.countGe (.energy .own .energy) 3) (.discardEnergy .own .active .energy (.exactly 3)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Koraidon ex (me2pt5-121). Records: me2pt5-121. Caveats: koAttackWide. -/
def me2pt5_121 : Card := .pokemon
  { name := "Koraidon ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Orichalcum Fang", cost := [.fighting, .colorless], damage := 0,
        effect := .ite (.countGe (.koLast .own true) 1) (.damage (.const 17)) (.damage (.const 5)),
        gx := false },
      { name := "Impact Blow", cost := [.fighting, .fighting, .colorless], damage := 20,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Team Rocket's Honchkrow (me2pt5-127). Records: me2pt5-127. Caveats: anyAmount60. -/
def me2pt5_127 : Card := .pokemon
  { name := "Team Rocket's Honchkrow", stage := .stage1, evolvesFrom := some "Team Rocket's Murkrow",
    hp := 13, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rocket Feathers", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 0)) (.damage (.const 0))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 1)) (.damage (.const 6)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 2)) (.damage (.const 12)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 3)) (.damage (.const 18)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 4)) (.damage (.const 24)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 5)) (.damage (.const 30)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 6)) (.damage (.const 36)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 7)) (.damage (.const 42)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 8)) (.damage (.const 48)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 9)) (.damage (.const 54)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 10)) (.damage (.const 60)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 11)) (.damage (.const 66)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 12)) (.damage (.const 72)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 13)) (.damage (.const 78)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 14)) (.damage (.const 84)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 15)) (.damage (.const 90)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 16)) (.damage (.const 96)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 17)) (.damage (.const 102)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 18)) (.damage (.const 108)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 19)) (.damage (.const 114)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 20)) (.damage (.const 120)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 21)) (.damage (.const 126)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 22)) (.damage (.const 132)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 23)) (.damage (.const 138)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 24)) (.damage (.const 144)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 25)) (.damage (.const 150)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 26)) (.damage (.const 156)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 27)) (.damage (.const 162)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 28)) (.damage (.const 168)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 29)) (.damage (.const 174)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 30)) (.damage (.const 180)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 31)) (.damage (.const 186)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 32)) (.damage (.const 192)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 33)) (.damage (.const 198)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 34)) (.damage (.const 204)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 35)) (.damage (.const 210)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 36)) (.damage (.const 216)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 37)) (.damage (.const 222)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 38)) (.damage (.const 228)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 39)) (.damage (.const 234)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 40)) (.damage (.const 240)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 41)) (.damage (.const 246)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 42)) (.damage (.const 252)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 43)) (.damage (.const 258)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 44)) (.damage (.const 264)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 45)) (.damage (.const 270)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 46)) (.damage (.const 276)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 47)) (.damage (.const 282)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 48)) (.damage (.const 288)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 49)) (.damage (.const 294)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 50)) (.damage (.const 300)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 51)) (.damage (.const 306)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 52)) (.damage (.const 312)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 53)) (.damage (.const 318)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 54)) (.damage (.const 324)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 55)) (.damage (.const 330)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 56)) (.damage (.const 336)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 57)) (.damage (.const 342)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 58)) (.damage (.const 348)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 59)) (.damage (.const 354)))) (.seq (.move .own .hand .discard (.and (.kind .supporter) (.nameHas "Team Rocket")) (.exactly 60)) (.damage (.const 360))),
        gx := false },
      { name := "Hammer In", cost := [.darkness, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Galarian Zigzagoon (me2pt5-130). Records: me2pt5-130. -/
def me2pt5_130 : Card := .pokemon
  { name := "Galarian Zigzagoon", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Galarian Linoone (me2pt5-131). Records: me2pt5-131. -/
def me2pt5_131 : Card := .pokemon
  { name := "Galarian Linoone", stage := .stage1, evolvesFrom := some "Galarian Zigzagoon",
    hp := 9, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Claw Slash", cost := [.darkness, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Galarian Obstagoon (me2pt5-132). Records: me2pt5-132, me2pt5-245. -/
def me2pt5_132 : Card := .pokemon
  { name := "Galarian Obstagoon", stage := .stage2, evolvesFrom := some "Galarian Linoone",
    hp := 17, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scarring Shout", cost := [.darkness, .colorless], damage := 0,
        effect := .damage (.per .opp 7),
        gx := false },
      { name := "Punk Smash", cost := [.darkness, .colorless, .colorless], damage := 16,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Scraggy (me2pt5-134). Records: me2pt5-134. -/
def me2pt5_134 : Card := .pokemon
  { name := "Scraggy", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knock Off", cost := [.darkness, .colorless], damage := 2,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Mega Scrafty ex (me2pt5-135). Records: me2pt5-135, me2pt5-270, me2pt5-285. Caveats: trigAttacker, trigDamaged. -/
def me2pt5_135 : Card := .pokemon
  { name := "Mega Scrafty ex", stage := .stage1, evolvesFrom := some "Scraggy",
    hp := 33, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [
      { name := "Counterattacking Crest", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.counters 5) }],
    attacks := [
      { name := "Outlaw Leg", cost := [.darkness, .darkness, .colorless], damage := 16,
        effect := .seq (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip) (.move .opp (.top 1) .discard .any .all),
        gx := false }] }

/-- Vullaby (me2pt5-138). Records: me2pt5-138. -/
def me2pt5_138 : Card := .pokemon
  { name := "Vullaby", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flap", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Mandibuzz ex (me2pt5-139). Records: me2pt5-139. Caveats: benchMods. -/
def me2pt5_139 : Card := .pokemon
  { name := "Mandibuzz ex", stage := .stage1, evolvesFrom := some "Vullaby",
    hp := 26, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Bone Shot", cost := [.colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 5)) (.benchDamage .opp 5)) (.damage (.const 5)),
        gx := false },
      { name := "Vulture Claw", cost := [.darkness, .colorless, .colorless], damage := 16,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Hoopa (me2pt5-141). Records: me2pt5-141. -/
def me2pt5_141 : Card := .pokemon
  { name := "Hoopa", stage := .basic, evolvesFrom := none,
    hp := 12, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Filch", cost := [.colorless], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Knuckle Impact", cost := [.darkness, .darkness, .colorless], damage := 13,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Pecharunt (me2pt5-143). Records: me2pt5-143. Caveats: searchAny, trigKO. -/
def me2pt5_143 : Card := .pokemon
  { name := "Pecharunt", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Final Chain", use := .triggered .koByAttack false,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .deck .hand .any (.upTo 1)) .shuffle) }],
    attacks := [
      { name := "Mochi Rush", cost := [.darkness], damage := 0,
        effect := .ite (.usedLast .own) (.damage (.const 7)) (.damage (.const 2)),
        gx := false, selfLock := .note }] }

/-- Mawile (me2pt5-144). Records: me2pt5-144, me2pt5-246. -/
def me2pt5_144 : Card := .pokemon
  { name := "Mawile", stage := .basic, evolvesFrom := none,
    hp := 9, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Bite", cost := [.metal, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Registeel ex (me2pt5-145). Records: me2pt5-145. Caveats: perPokemon. -/
def me2pt5_145 : Card := .pokemon
  { name := "Registeel ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Regi Charge", cost := [.colorless], damage := 0,
        effect := .seq (.attach .own .discard (.energyOf .metal) .active .any) (.attach .own .discard (.energyOf .metal) .active .any),
        gx := false },
      { name := "Protecting Steel", cost := [.metal, .colorless, .colorless, .colorless], damage := 14,
        effect := .linger .own .next (.reduce 5),
        gx := false }] }

/-- Pawniard (me2pt5-146). Records: me2pt5-146. -/
def me2pt5_146 : Card := .pokemon
  { name := "Pawniard", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Push Down", cost := [.metal], damage := 1,
        effect := .switch .opp,
        gx := false }] }

/-- Bisharp (me2pt5-147). Records: me2pt5-147. -/
def me2pt5_147 : Card := .pokemon
  { name := "Bisharp", stage := .stage1, evolvesFrom := some "Pawniard",
    hp := 12, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rapid Draw", cost := [.metal], damage := 5,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false }] }

/-- Togedemaru ex (me2pt5-149). Records: me2pt5-149. Caveats: usedLastBench. -/
def me2pt5_149 : Card := .pokemon
  { name := "Togedemaru ex", stage := .basic, evolvesFrom := none,
    hp := 19, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Stun Needle", cost := [.metal], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Spiky Rolling", cost := [.metal, .colorless], damage := 0,
        effect := .ite (.usedLast .own) (.damage (.const 16)) (.damage (.const 8)),
        gx := false, selfLock := .note }] }

/-- Dratini (me2pt5-150). Records: me2pt5-150. -/
def me2pt5_150 : Card := .pokemon
  { name := "Dratini", stage := .basic, evolvesFrom := none,
    hp := 8, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.water, .lightning], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Mega Dragonite ex (me2pt5-152). Records: me2pt5-152, me2pt5-271, me2pt5-290, me2pt5-295. Caveats: discardUnits. -/
def me2pt5_152 : Card := .pokemon
  { name := "Mega Dragonite ex", stage := .stage2, evolvesFrom := some "Dragonair",
    hp := 37, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [
      { name := "Sky Transport", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.switch .own)) }],
    attacks := [
      { name := "Ryuno Glide", cost := [.water, .lightning, .lightning], damage := 33,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Rayquaza (me2pt5-153). Records: me2pt5-153. Caveats: movedUpPromotion. -/
def me2pt5_153 : Card := .pokemon
  { name := "Rayquaza", stage := .basic, evolvesFrom := none,
    hp := 12, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Breakthrough Assault", cost := [.lightning, .colorless], damage := 0,
        effect := .ite (.movedUp .own) (.damage (.const 11)) (.damage (.const 2)),
        gx := false },
      { name := "Dragon Claw", cost := [.fire, .lightning, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- N's Zekrom (me2pt5-155). Records: me2pt5-155. Caveats: ignFxStadium. -/
def me2pt5_155 : Card := .pokemon
  { name := "N's Zekrom", stage := .basic, evolvesFrom := none,
    hp := 13, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shred", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.const 7) { fx := true },
        gx := false },
      { name := "Rampaging Thunder", cost := [.fire, .lightning, .lightning, .colorless], damage := 25,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Noibat (me2pt5-156). Records: me2pt5-156. -/
def me2pt5_156 : Card := .pokemon
  { name := "Noibat", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knickknack Carrying", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .tool (.upTo 1)) .shuffle,
        gx := false },
      { name := "Bite", cost := [.psychic, .darkness], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Noivern (me2pt5-157). Records: me2pt5-157. Caveats: perPokemon, shieldReach. -/
def me2pt5_157 : Card := .pokemon
  { name := "Noivern", stage := .stage1, evolvesFrom := some "Noibat",
    hp := 12, type := .dragon, retreat := 0, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Agility", cost := [.colorless, .colorless], damage := 4,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false },
      { name := "Enhanced Blade", cost := [.psychic, .darkness], damage := 0,
        effect := .ite (.hasTool .own) (.damage (.const 14)) (.damage (.const 7)),
        gx := false }] }

/-- Team Rocket's Kangaskhan ex (me2pt5-162). Records: me2pt5-162. -/
def me2pt5_162 : Card := .pokemon
  { name := "Team Rocket's Kangaskhan ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Comet Punch", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 3)) (.choice (.damage (.const 6)) (.choice (.damage (.const 9)) (.damage (.const 12))))),
        gx := false },
      { name := "Wicked Impact", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.played .own (.and (.kind .supporter) (.nameHas "Team Rocket"))) 1) (.damage (.const 22)) (.damage (.const 12)),
        gx := false }] }

/-- Larry's Dunsparce (me2pt5-163). Records: me2pt5-163. -/
def me2pt5_163 : Card := .pokemon
  { name := "Larry's Dunsparce", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rising Lunge", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Larry's Dudunsparce ex (me2pt5-164). Records: me2pt5-164. -/
def me2pt5_164 : Card := .pokemon
  { name := "Larry's Dudunsparce ex", stage := .stage1, evolvesFrom := some "Larry's Dunsparce",
    hp := 27, type := .colorless, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Work Rush", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.heads (.count (.energy .own .energy) 1) 8),
        gx := false }] }

/-- Skitty (me2pt5-165). Records: me2pt5-165. -/
def me2pt5_165 : Card := .pokemon
  { name := "Skitty", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cat Kick", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Delcatty (me2pt5-166). Records: me2pt5-166. Caveats: energyUnitsCount. -/
def me2pt5_166 : Card := .pokemon
  { name := "Delcatty", stage := .stage1, evolvesFrom := some "Skitty",
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cat Kick", cost := [.colorless], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Energy Crush", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.energyAll .opp .energy) 4),
        gx := false }] }

/-- Zangoose ex (me2pt5-167). Records: me2pt5-167. Caveats: recoil. -/
def me2pt5_167 : Card := .pokemon
  { name := "Zangoose ex", stage := .basic, evolvesFrom := none,
    hp := 20, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Spike Draw", cost := [.colorless], damage := 2,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Wild Scissors", cost := [.colorless, .colorless, .colorless], damage := 18,
        effect := .selfDamage 3,
        gx := false }] }

/-- Larry's Starly (me2pt5-168). Records: me2pt5-168. -/
def me2pt5_168 : Card := .pokemon
  { name := "Larry's Starly", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Minor Errand-Running", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .basicEnergy (.upTo 2)) .shuffle,
        gx := false },
      { name := "Glide", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Larry's Staravia (me2pt5-169). Records: me2pt5-169. -/
def me2pt5_169 : Card := .pokemon
  { name := "Larry's Staravia", stage := .stage1, evolvesFrom := some "Larry's Starly",
    hp := 9, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flap", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Razor Wing", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Larry's Staraptor (me2pt5-170). Records: me2pt5-170, me2pt5-249. Caveats: benchMods, discardUnits. -/
def me2pt5_170 : Card := .pokemon
  { name := "Larry's Staraptor", stage := .stage2, evolvesFrom := some "Larry's Staravia",
    hp := 15, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Facade", cost := [.colorless], damage := 0,
        effect := .ite (.cond .own .burned) (.damage (.const 16)) (.ite (.cond .own .poisoned) (.damage (.const 16)) (.damage (.const 6))),
        gx := false },
      { name := "Feathery Strike", cost := [.colorless, .colorless, .colorless], damage := 15,
        effect := .seq (.ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all)) (.benchDamage .opp 5),
        gx := false }] }

/-- Mega Audino ex (me2pt5-172). Records: me2pt5-172, me2pt5-253. Caveats: energyUnitsCount. -/
def me2pt5_172 : Card := .pokemon
  { name := "Mega Audino ex", stage := .basic, evolvesFrom := none,
    hp := 27, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Kaleidowaltz", cost := [.colorless], damage := 0,
        effect := .choice .skip (.choice (.seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) .shuffle) (.choice (.seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) (.seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) .shuffle)) (.seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) (.seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) (.seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) .shuffle))))),
        gx := false },
      { name := "Ear Force", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.count (.energy .opp .energy) 8)),
        gx := false }] }

/-- Larry's Rufflet (me2pt5-173). Records: me2pt5-173. -/
def me2pt5_173 : Card := .pokemon
  { name := "Larry's Rufflet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Peck the Wound", cost := [.colorless, .colorless], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 10)) (.damage (.const 2)),
        gx := false }] }

/-- Larry's Braviary (me2pt5-174). Records: me2pt5-174. Caveats: perPokemon, recoil. -/
def me2pt5_174 : Card := .pokemon
  { name := "Larry's Braviary", stage := .stage1, evolvesFrom := some "Larry's Rufflet",
    hp := 13, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Clutch", cost := [.colorless, .colorless], damage := 5,
        effect := .linger .opp .next (.lock .retreat),
        gx := false },
      { name := "Brave Bird", cost := [.colorless, .colorless, .colorless], damage := 12,
        effect := .selfDamage 3,
        gx := false }] }

/-- Drampa (me2pt5-176). Records: me2pt5-176. -/
def me2pt5_176 : Card := .pokemon
  { name := "Drampa", stage := .basic, evolvesFrom := none,
    hp := 13, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Dragon Strike", cost := [.colorless, .colorless, .colorless], damage := 12,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Canari (me2pt5-185). Records: me2pt5-185, me2pt5-257, me2pt5-291. Caveats: upTo0. -/
def me2pt5_185 : Card := .trainer "Canari" .supporter
    (.seq (.move .own .hand .discard .any (.exactly 1)) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.ptype .lightning) (.upTo 4)) .shuffle)))

/-- Light Ball (me2pt5-191). Records: me2pt5-191. -/
def me2pt5_191 : Card := .tool "Light Ball"
  { holder := .named "Pikachu ex",
    attacks := [],
    abilities := [],
    statics := [
      { sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .bonus 5 (.and .pokemon (.not .noRuleBox)) }] }

/-- Poké Pad (me2pt5-198). Records: me2pt5-198, me3-81, me3-113, me55-126. -/
def me2pt5_198 : Card := .trainer "Poké Pad" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.and .pokemon .noRuleBox) (.upTo 1)) .shuffle))

/-- Team Rocket's Hypnotizer (me2pt5-206). Records: me2pt5-206. Caveats: trigAttached, trigAttacker, trigDamaged. -/
def me2pt5_206 : Card := .tool "Team Rocket's Hypnotizer"
  { holder := .and .pokemon (.namePrefix "Team Rocket's "),
    attacks := [],
    abilities := [
      { name := "Team Rocket's Hypnotizer", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.inflict .asleep) }] }

/-- Thick Scale (me2pt5-211). Records: me2pt5-211. Caveats: staticBench. -/
def me2pt5_211 : Card := .tool "Thick Scale"
  { holder := .ptype .dragon,
    attacks := [],
    abilities := [],
    statics := [
      { sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 5 (.or (.ptype .grass) (.or (.ptype .fire) (.or (.ptype .water) (.ptype .lightning)))) }] }

/-- Urbain (me2pt5-214). Records: me2pt5-214. -/
def me2pt5_214 : Card := .trainer "Urbain" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 3) .hand .any .all))

/-- Waitress (me2pt5-215). Records: me2pt5-215. Caveats: failToFind. -/
def me2pt5_215 : Card := .trainer "Waitress" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own (.top 6) .basicEnergy (.most 1) (.attach .any) .shuffle))

/-- Spinarak (me3-1). Records: me3-1. Caveats: perPokemon. -/
def me3_1 : Card := .pokemon
  { name := "Spinarak", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gooey Thread", cost := [.grass], damage := 1,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Ariados (me3-2). Records: me3-2. Caveats: perPokemon. -/
def me3_2 : Card := .pokemon
  { name := "Ariados", stage := .stage1, evolvesFrom := some "Spinarak",
    hp := 11, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Ring", cost := [.grass], damage := 5,
        effect := .seq (.inflict .poisoned) (.linger .opp .next (.lock .retreat)),
        gx := false }] }

/-- Shaymin (me3-3). Records: me3-3. -/
def me3_3 : Card := .pokemon
  { name := "Shaymin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 0, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Send Flowers", cost := [.grass], damage := 0,
        effect := .seq (.attach .own .deck .energy .bench (.ptype .grass)) .shuffle,
        gx := false },
      { name := "Leaf Step", cost := [.grass], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Snivy (me3-4). Records: me3-4. Caveats: recoil. -/
def me3_4 : Card := .pokemon
  { name := "Snivy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.grass], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Servine (me3-5). Records: me3-5. -/
def me3_5 : Card := .pokemon
  { name := "Servine", stage := .stage1, evolvesFrom := some "Snivy",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Solar Cutter", cost := [.grass], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Serperior (me3-6). Records: me3-6. -/
def me3_6 : Card := .pokemon
  { name := "Serperior", stage := .stage2, evolvesFrom := some "Servine",
    hp := 16, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Regal Command", cost := [.grass], damage := 0,
        effect := .damage (.add (.const 2) (.count (.bench .own .pokemon) 2)),
        gx := false },
      { name := "Solar Coiling", cost := [.grass, .grass, .grass], damage := 0,
        effect := .ite (.countGe (.pile .own .discard (.named "Rosa's Encouragement")) 1) (.damage (.const 25)) (.damage (.const 10)),
        gx := false }] }

/-- Scatterbug (me3-7). Records: me3-7. -/
def me3_7 : Card := .pokemon
  { name := "Scatterbug", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Spewpa (me3-8). Records: me3-8, me3-89. Caveats: perPokemon, shieldReach. -/
def me3_8 : Card := .pokemon
  { name := "Spewpa", stage := .stage1, evolvesFrom := some "Scatterbug",
    hp := 8, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hide", cost := [.grass], damage := 0,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false }] }

/-- Rowlet (me3-10). Records: me3-10, me3-90. -/
def me3_10 : Card := .pokemon
  { name := "Rowlet", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Find a Friend", cost := [.grass], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle,
        gx := false },
      { name := "Tackle", cost := [.colorless, .colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Dartrix (me3-11). Records: me3-11. Caveats: benchMods. -/
def me3_11 : Card := .pokemon
  { name := "Dartrix", stage := .stage1, evolvesFrom := some "Rowlet",
    hp := 10, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leafage", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Feather Shot", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .seq (.discardEnergy .own .active .energy .all) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 9)) (.benchDamage .opp 9)) (.damage (.const 9))),
        gx := false }] }

/-- Fletchinder (me3-13). Records: me3-13. -/
def me3_13 : Card := .pokemon
  { name := "Fletchinder", stage := .stage1, evolvesFrom := some "Fletchling",
    hp := 9, type := .fire, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flare", cost := [.fire, .fire], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Talonflame (me3-14). Records: me3-14, me3-91. -/
def me3_14 : Card := .pokemon
  { name := "Talonflame", stage := .stage2, evolvesFrom := some "Fletchinder",
    hp := 15, type := .fire, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Sky Hunt", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .opp .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.move .opp .hand .discard .any (.exactly 1)) .skip)) }],
    attacks := [
      { name := "Fire Wing", cost := [.fire, .fire], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Salandit (me3-15). Records: me3-15. -/
def me3_15 : Card := .pokemon
  { name := "Salandit", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fire Claws", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Salazzle ex (me3-16). Records: me3-16, me3-101. Caveats: searchAny. -/
def me3_16 : Card := .pokemon
  { name := "Salazzle ex", stage := .stage1, evolvesFrom := some "Salandit",
    hp := 26, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Nasty Plot", cost := [.fire], damage := 0,
        effect := .seq (.move .own .deck .hand .any (.upTo 2)) .shuffle,
        gx := false },
      { name := "Dire Nails", cost := [.fire, .fire], damage := 10,
        effect := .seq (.seq (.inflict .burned) (.inflict .poisoned)) (.switch .own),
        gx := false }] }

/-- Seel (me3-18). Records: me3-18. -/
def me3_18 : Card := .pokemon
  { name := "Seel", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rain Splash", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Wave Splash", cost := [.water, .water], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Dewgong (me3-19). Records: me3-19. Caveats: energyOfBasic, energyOfCount, moveAnyPair, moveMayFail. -/
def me3_19 : Card := .pokemon
  { name := "Dewgong", stage := .stage1, evolvesFrom := some "Seel",
    hp := 13, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Wash Out", use := .unlimited,
        spot := none, cond := none,
        effect := .fx (.seq (.seq (.ite (.countGe (.energyAll .own (.energyOf .water)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.moveEnergy .own (.energyOf .water))) }],
    attacks := [
      { name := "Wave Splash", cost := [.water, .water], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Staryu (me3-20). Records: me3-20. -/
def me3_20 : Card := .pokemon
  { name := "Staryu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Water Gun", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Mega Starmie ex (me3-21). Records: me3-21, me3-102, me3-118. Caveats: benchMods, ignFxStadium. -/
def me3_21 : Card := .pokemon
  { name := "Mega Starmie ex", stage := .stage1, evolvesFrom := some "Staryu",
    hp := 33, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Jetting Blow", cost := [.water], damage := 12,
        effect := .benchDamage .opp 5,
        gx := false },
      { name := "Nebula Beam", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.const 21) { weak := true, resist := true, fx := true },
        gx := false }] }

/-- Lapras ex (me3-22). Records: me3-22. Caveats: energyOfCount. -/
def me3_22 : Card := .pokemon
  { name := "Lapras ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Hydro Turn", cost := [.water], damage := 0,
        effect := .seq (.damage (.count (.energy .own (.energyOf .water)) 3)) (.switch .own),
        gx := false },
      { name := "Surf", cost := [.water, .water, .water], damage := 14,
        effect := .skip,
        gx := false }] }

/-- Amaura (me3-23). Records: me3-23. -/
def me3_23 : Card := .pokemon
  { name := "Amaura", stage := .stage1, evolvesFrom := some "Antique Sail Fossil",
    hp := 10, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Icy Wind", cost := [.water, .colorless], damage := 5,
        effect := .inflict .asleep,
        gx := false }] }

/-- Volcanion (me3-25). Records: me3-25. Caveats: energyOfCount. -/
def me3_25 : Card := .pokemon
  { name := "Volcanion", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Strength", cost := [.water, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Powerful Steam", cost := [.water, .water, .colorless], damage := 0,
        effect := .damage (.heads (.count (.energy .own (.energyOf .water)) 1) 9),
        gx := false }] }

/-- Shinx (me3-26). Records: me3-26. -/
def me3_26 : Card := .pokemon
  { name := "Shinx", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Scratch", cost := [.lightning], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- Luxray (me3-28). Records: me3-28. Caveats: discardUnits, prizes6. -/
def me3_28 : Card := .pokemon
  { name := "Luxray", stage := .stage2, evolvesFrom := some "Luxio",
    hp := 15, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Incessant Onslaught", cost := [.lightning, .colorless], damage := 0,
        effect := .damage (.count (.prizesTaken .own) 7),
        gx := false },
      { name := "Strong Volt", cost := [.lightning, .colorless, .colorless], damage := 20,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Clefairy (me3-30). Records: me3-30, me3-94. -/
def me3_30 : Card := .pokemon
  { name := "Clefairy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Follow Me", cost := [.psychic], damage := 0,
        effect := .switch .opp,
        gx := false },
      { name := "Flop", cost := [.psychic, .psychic], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Mawile (me3-32). Records: me3-32. -/
def me3_32 : Card := .pokemon
  { name := "Mawile", stage := .basic, evolvesFrom := none,
    hp := 11, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Eater", cost := [.psychic, .colorless], damage := 0,
        effect := .choice (.choice (.seq (.move .own .hand .discard .energy (.exactly 0)) (.damage (.const 0))) (.seq (.move .own .hand .discard .energy (.exactly 1)) (.damage (.const 6)))) (.seq (.move .own .hand .discard .energy (.exactly 2)) (.damage (.const 12))),
        gx := false }] }

/-- Espurr (me3-33). Records: me3-33, me3-95. -/
def me3_33 : Card := .pokemon
  { name := "Espurr", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nap", cost := [.colorless], damage := 0,
        effect := .heal 2,
        gx := false },
      { name := "Stampede", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Meowstic (me3-34). Records: me3-34. Caveats: energyUnitsCount. -/
def me3_34 : Card := .pokemon
  { name := "Meowstic", stage := .stage1, evolvesFrom := some "Espurr",
    hp := 10, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Perplex", cost := [.psychic], damage := 0,
        effect := .inflict .confused,
        gx := false },
      { name := "Psychic", cost := [.psychic], damage := 0,
        effect := .damage (.add (.const 3) (.count (.energy .opp .energy) 3)),
        gx := false }] }

/-- Spritzee (me3-35). Records: me3-35. -/
def me3_35 : Card := .pokemon
  { name := "Spritzee", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sweet Scent", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.bench .own .pokemon) 1) (.choice (.heal 3) (.benchHeal 3)) (.heal 3),
        gx := false },
      { name := "Ram", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Aromatisse (me3-36). Records: me3-36. Caveats: upTo0. -/
def me3_36 : Card := .pokemon
  { name := "Aromatisse", stage := .stage1, evolvesFrom := some "Spritzee",
    hp := 12, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Scent Collection", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.energyOf .psychic) (.upTo 2)) .shuffle)) }],
    attacks := [
      { name := "Draining Kiss", cost := [.psychic, .colorless], damage := 5,
        effect := .heal 3,
        gx := false }] }

/-- Nosepass (me3-37). Records: me3-37. -/
def me3_37 : Card := .pokemon
  { name := "Nosepass", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Rocks", cost := [.fighting, .fighting], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Probopass (me3-38). Records: me3-38, me3-96. -/
def me3_38 : Card := .pokemon
  { name := "Probopass", stage := .stage1, evolvesFrom := some "Nosepass",
    hp := 14, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Rocks", cost := [.fighting, .fighting], damage := 6,
        effect := .skip,
        gx := false },
      { name := "Obliterating Nose", cost := [.fighting, .fighting, .fighting, .colorless], damage := 26,
        effect := .ite (.countGe (.energy .own .energy) 3) (.discardEnergy .own .active .energy (.exactly 3)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Hippowdon (me3-40). Records: me3-40. -/
def me3_40 : Card := .pokemon
  { name := "Hippowdon", stage := .stage1, evolvesFrom := some "Hippopotas",
    hp := 15, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Twister Spewing", cost := [.fighting, .fighting, .colorless], damage := 8,
        effect := .ite (.countGe (.played .own (.and (.kind .supporter) (.named "Tarragon"))) 1) (.move .opp (.top 3) .discard .any .all) .skip,
        gx := false },
      { name := "Heavy Impact", cost := [.fighting, .fighting, .colorless, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Landorus (me3-41). Records: me3-41. -/
def me3_41 : Card := .pokemon
  { name := "Landorus", stage := .basic, evolvesFrom := none,
    hp := 12, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rock Tumble", cost := [.fighting, .fighting], damage := 0,
        effect := .damage (.const 5) { resist := true },
        gx := false },
      { name := "Screw Knuckle", cost := [.fighting, .fighting, .colorless], damage := 12,
        effect := .ite (.countGe (.energy .own .energy) 1) (.returnEnergy .own .active .energy (.exactly 1) .hand) .skip,
        gx := false }] }

/-- Binacle (me3-42). Records: me3-42. -/
def me3_42 : Card := .pokemon
  { name := "Binacle", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Draw", cost := [.fighting], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Scratch", cost := [.fighting, .fighting], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Barbaracle (me3-43). Records: me3-43. Caveats: mayFail. -/
def me3_43 : Card := .pokemon
  { name := "Barbaracle", stage := .stage1, evolvesFrom := some "Binacle",
    hp := 13, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Stone Arms", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.seq (.ite (.countGe (.pile .own .hand (.energyOf .fighting)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.bench .own (.ptype .fighting)) 1) .skip (.ite (.top .own (.ptype .fighting)) .skip (.move .own (.top 0) .hand .any (.exactly 1))))) (.choice (.attach .own .hand (.energyOf .fighting) .active (.ptype .fighting)) (.attach .own .hand (.energyOf .fighting) .bench (.ptype .fighting)))) }],
    attacks := [
      { name := "Hammer In", cost := [.fighting, .fighting, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Tyrunt (me3-44). Records: me3-44. -/
def me3_44 : Card := .pokemon
  { name := "Tyrunt", stage := .stage1, evolvesFrom := some "Antique Jaw Fossil",
    hp := 10, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Get Angry", cost := [.fighting, .colorless], damage := 0,
        effect := .damage (.per .own 2),
        gx := false }] }

/-- Tyrantrum (me3-45). Records: me3-45. -/
def me3_45 : Card := .pokemon
  { name := "Tyrantrum", stage := .stage2, evolvesFrom := some "Tyrunt",
    hp := 18, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Tyrannically Gutsy", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := some (.specialEnergy, 1), eff := .hpPlus (.const 15) }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Wreak Havoc", cost := [.fighting, .colorless], damage := 16,
        effect := .iter (.move .opp (.top 1) .discard .any .all),
        gx := false }] }

/-- Gastly (me3-48). Records: me3-48. -/
def me3_48 : Card := .pokemon
  { name := "Gastly", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Surprise Attack", cost := [.darkness], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Haunter (me3-49). Records: me3-49. -/
def me3_49 : Card := .pokemon
  { name := "Haunter", stage := .stage1, evolvesFrom := some "Gastly",
    hp := 10, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Haunt", cost := [.darkness], damage := 0,
        effect := .counters 3,
        gx := false }] }

/-- Skorupi (me3-51). Records: me3-51. -/
def me3_51 : Card := .pokemon
  { name := "Skorupi", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Jab", cost := [.darkness, .darkness], damage := 2,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Drapion (me3-52). Records: me3-52, me3-97. Caveats: recoil. -/
def me3_52 : Card := .pokemon
  { name := "Drapion", stage := .stage1, evolvesFrom := some "Skorupi",
    hp := 14, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wrack Down", cost := [.darkness, .darkness], damage := 6,
        effect := .skip,
        gx := false },
      { name := "Hazardous Tail", cost := [.darkness, .darkness, .darkness], damage := 10,
        effect := .seq (.selfDamage 7) (.seq (.inflict .paralyzed) (.inflict .poisoned)),
        gx := false }] }

/-- Chien-Pao (me3-54). Records: me3-54. -/
def me3_54 : Card := .pokemon
  { name := "Chien-Pao", stage := .basic, evolvesFrom := none,
    hp := 12, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Strafe", cost := [.darkness], damage := 2,
        effect := .choice (.switch .own) .skip,
        gx := false },
      { name := "Rising Blade", cost := [.darkness, .darkness, .colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 16)) (.damage (.const 8)),
        gx := false }] }

/-- Mega Skarmory ex (me3-55). Records: me3-55, me3-106. Caveats: benchMods. -/
def me3_55 : Card := .pokemon
  { name := "Mega Skarmory ex", stage := .basic, evolvesFrom := none,
    hp := 26, type := .metal, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Sonic Ripper", cost := [.metal, .metal, .colorless], damage := 0,
        effect := .seq (.returnEnergy .own .active .energy .all .shuffle) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 22)) (.benchDamage .opp 22)) (.damage (.const 22))),
        gx := false }] }

/-- Honedge (me3-56). Records: me3-56. -/
def me3_56 : Card := .pokemon
  { name := "Honedge", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cut", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Doublade (me3-57). Records: me3-57, me3-98. -/
def me3_57 : Card := .pokemon
  { name := "Doublade", stage := .stage1, evolvesFrom := some "Honedge",
    hp := 10, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Weaponized Swords", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.heads (.count (.pile .own .hand (.or (.named "Honedge") (.or (.named "Doublade") (.named "Aegislash")))) 1) 6),
        gx := false }] }

/-- Aegislash (me3-58). Records: me3-58. -/
def me3_58 : Card := .pokemon
  { name := "Aegislash", stage := .stage2, evolvesFrom := some "Doublade",
    hp := 15, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false },
      { name := "Metal Slash", cost := [.metal, .colorless, .colorless, .colorless], damage := 23,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Rattata (me3-60). Records: me3-60. Caveats: recoil. -/
def me3_60 : Card := .pokemon
  { name := "Rattata", stage := .basic, evolvesFrom := none,
    hp := 4, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Take Down", cost := [.colorless], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Bunnelby (me3-64). Records: me3-64. -/
def me3_64 : Card := .pokemon
  { name := "Bunnelby", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smash Kick", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Diggersby (me3-65). Records: me3-65. Caveats: benchMods. -/
def me3_65 : Card := .pokemon
  { name := "Diggersby", stage := .stage1, evolvesFrom := some "Bunnelby",
    hp := 15, type := .colorless, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Earthquake", cost := [.colorless], damage := 14,
        effect := .spreadDamage .own 3,
        gx := false },
      { name := "Whap Down", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Fletchling (me3-66). Records: me3-66. -/
def me3_66 : Card := .pokemon
  { name := "Fletchling", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Chirp", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand (.and .pokemon (.resists .fighting)) (.upTo 2)) .shuffle,
        gx := false },
      { name := "Peck", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Core Memory (me3-70). Records: me3-70. -/
def me3_70 : Card := .tool "Core Memory"
  { holder := .named "Mega Zygarde ex",
    attacks := [
      { name := "Geobuster", cost := [.fighting, .fighting, .fighting, .fighting], damage := 35,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }],
    abilities := [] }

/-- Crushing Hammer (me3-71). Records: me3-71, me5-105. -/
def me3_71 : Card := .trainer "Crushing Hammer" .item
    (.ite (.countGe (.energyAll .opp .energy) 1) (.choice (.choice (.discardEnergy .opp .active .energy (.exactly 1)) (.ite (.countGe (.bench .opp .pokemon) 1) (.discardEnergy .opp .bench .energy (.exactly 1)) (.move .own (.top 0) .hand .any (.exactly 1)))) .skip) (.move .own (.top 0) .hand .any (.exactly 1)))

/-- Energy Search (me3-72). Records: me3-72. -/
def me3_72 : Card := .trainer "Energy Search" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand .basicEnergy (.upTo 1)) .shuffle))

/-- Energy Swatter (me3-73). Records: me3-73. -/
def me3_73 : Card := .trainer "Energy Swatter" .item
    (.seq (.ite (.countGe (.pile .opp .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .opp .hand .bottom .energy (.most 1)))

/-- Hole-Digging Shovel (me3-74). Records: me3-74. -/
def me3_74 : Card := .trainer "Hole-Digging Shovel" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 2) .discard .any .all))

/-- Jacinthe (me3-75). Records: me3-75, me3-110, me3-122. Caveats: noopPlay. -/
def me3_75 : Card := .trainer "Jacinthe" .supporter
    (.seq (.ite (.atLeast .own 1) .skip (.ite (.countGe (.bench .own (.ptype .psychic)) 1) .skip (.ite (.top .own (.ptype .psychic)) (.move .own (.top 0) .hand .any (.exactly 1)) .skip))) (.ite (.countGe (.bench .own (.ptype .psychic)) 1) (.choice (.ite (.top .own (.ptype .psychic)) (.heal 15) (.move .own (.top 0) .hand .any (.exactly 1))) (.benchHealSome 1 (.ptype .psychic) (some 15))) (.ite (.top .own (.ptype .psychic)) (.heal 15) (.move .own (.top 0) .hand .any (.exactly 1)))))

/-- Judge (me3-76). Records: me3-76. -/
def me3_76 : Card := .trainer "Judge" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .own .hand .any) 1) .skip (.ite (.countGe (.pile .opp .deck .any) 1) .skip (.ite (.countGe (.pile .opp .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))))) (.seq (.move .own .hand .shuffle .any .all) (.seq (.move .own (.top 4) .hand .any .all) (.seq (.move .opp .hand .shuffle .any .all) (.move .opp (.top 4) .hand .any .all)))))

/-- Poké Ball (me3-80). Records: me3-80. -/
def me3_80 : Card := .trainer "Poké Ball" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle) .skip))

/-- Pokémon Catcher (me3-82). Records: me3-82, me6-129. -/
def me3_82 : Card := .trainer "Pokémon Catcher" .item
    (.seq (.ite (.countGe (.bench .opp .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.switch .opp) .skip))

/-- Potion (me3-83). Records: me3-83. Caveats: noopPlay. -/
def me3_83 : Card := .trainer "Potion" .item
    (.seq (.ite (.atLeast .own 1) .skip (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.ite (.countGe (.bench .own .pokemon) 1) (.choice (.heal 3) (.benchHeal 3)) (.heal 3)))

/-- Tarragon (me3-85). Records: me3-85, me3-116. Caveats: upTo0. -/
def me3_85 : Card := .trainer "Tarragon" .supporter
    (.seq (.ite (.countGe (.pile .own .discard (.or (.ptype .fighting) (.energyOf .fighting))) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own .discard .hand (.or (.ptype .fighting) (.energyOf .fighting)) (.upTo 4)))

/-- Growing Grass Energy (me3-86). Records: me3-86. -/
def me3_86 : Card := .energy (.special "Growing Grass Energy" [[.grass]] { grant := { holder := .ptype .grass, attacks := [], abilities := [], statics := [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .hpPlus (.const 2) }] } })

/-- Rocky Fighting Energy (me3-87). Records: me3-87. Caveats: shieldActive, shieldReach. -/
def me3_87 : Card := .energy (.special "Rocky Fighting Energy" [[.fighting]] { grant := { holder := .ptype .fighting, attacks := [], abilities := [], statics := [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .shield .any }] } })

/-- Weedle (me4-1). Records: me4-1. -/
def me4_1 : Card := .pokemon
  { name := "Weedle", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Surprise Attack", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Kakuna (me4-2). Records: me4-2. Caveats: staticBench. -/
def me4_2 : Card := .pokemon
  { name := "Kakuna", stage := .stage1, evolvesFrom := some "Weedle",
    hp := 8, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Exoskeleton", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 2 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Hang Down", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Beedrill ex (me4-3). Records: me4-3, me4-98. -/
def me4_3 : Card := .pokemon
  { name := "Beedrill ex", stage := .stage2, evolvesFrom := some "Kakuna",
    hp := 31, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Rumbling Bees", cost := [.grass], damage := 0,
        effect := .damage (.count (.inPlay .own (.or (.named "Beedrill") (.named "Beedrill ex"))) 11),
        gx := false }] }

/-- Chespin (me4-5). Records: me4-5, me4-87. -/
def me4_5 : Card := .pokemon
  { name := "Chespin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Beat", cost := [.grass], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Spike Sting", cost := [.grass, .grass], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Quilladin (me4-6). Records: me4-6. -/
def me4_6 : Card := .pokemon
  { name := "Quilladin", stage := .stage1, evolvesFrom := some "Chespin",
    hp := 10, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leafy Charge", cost := [.grass], damage := 2,
        effect := .seq (.attach .own .deck (.energyOf .grass) .active .any) .shuffle,
        gx := false },
      { name := "Vine Whip", cost := [.grass, .grass, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Vulpix (me4-8). Records: me4-8. -/
def me4_8 : Card := .pokemon
  { name := "Vulpix", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Singe", cost := [.fire], damage := 0,
        effect := .inflict .burned,
        gx := false }] }

/-- Ninetales (me4-9). Records: me4-9. -/
def me4_9 : Card := .pokemon
  { name := "Ninetales", stage := .stage1, evolvesFrom := some "Vulpix",
    hp := 12, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nine-Tailed Transfer", cost := [.fire], damage := 0,
        effect := .dumpCounters .any .active,
        gx := false },
      { name := "Will-O-Wisp", cost := [.fire, .fire], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Ho-Oh (me4-10). Records: me4-10. Caveats: energyOfBasic, energyOfCount. -/
def me4_10 : Card := .pokemon
  { name := "Ho-Oh", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flames of Revival", cost := [.fire], damage := 0,
        effect := .seq (.putBench .own .discard .basic) (.seq (.putBench .own .discard .basic) (.putBench .own .discard .basic)),
        gx := false },
      { name := "Bright Wing", cost := [.fire, .fire, .fire], damage := 13,
        effect := .ite (.countGe (.energy .own (.energyOf .fire)) 1) (.discardEnergy .own .active (.energyOf .fire) (.exactly 1)) .skip,
        gx := false }] }

/-- Fennekin (me4-11). Records: me4-11. -/
def me4_11 : Card := .pokemon
  { name := "Fennekin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Steady Firebreathing", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Braixen (me4-12). Records: me4-12. -/
def me4_12 : Card := .pokemon
  { name := "Braixen", stage := .stage1, evolvesFrom := some "Fennekin",
    hp := 10, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flamethrower", cost := [.fire, .fire], damage := 8,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Delphox (me4-13). Records: me4-13. Caveats: energyUnitsCount. -/
def me4_13 : Card := .pokemon
  { name := "Delphox", stage := .stage2, evolvesFrom := some "Braixen",
    hp := 16, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Flaring Magic", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .hand .discard (.energyOf .fire) (.exactly 1)) (.seq (.seq (.ite (.countGe (.pile .own .hand .any) 7) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.drawTo .own 7))) }],
    attacks := [
      { name := "Energized Storm", cost := [.fire, .fire], damage := 0,
        effect := .damage (.add (.count (.energyAll .own .energy) 3) (.count (.energyAll .opp .energy) 3)),
        gx := false }] }

/-- Litleo (me4-14). Records: me4-14. -/
def me4_14 : Card := .pokemon
  { name := "Litleo", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Mega Pyroar ex (me4-15). Records: me4-15, me4-99. Caveats: benchMods, perPokemon. -/
def me4_15 : Card := .pokemon
  { name := "Mega Pyroar ex", stage := .stage1, evolvesFrom := some "Litleo",
    hp := 34, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Ferocious Bellow", cost := [.fire, .colorless], damage := 8,
        effect := .linger .opp .next (.weaken 5),
        gx := false },
      { name := "Fiery Big Bang", cost := [.fire, .fire, .colorless], damage := 0,
        effect := .damage (.sub (.const 29) (.per .own 1)),
        gx := false }] }

/-- Remoraid (me4-16). Records: me4-16. -/
def me4_16 : Card := .pokemon
  { name := "Remoraid", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sharp Fin", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Keldeo (me4-19). Records: me4-19. Caveats: benchMods, moveAnyPair, moveMayFail. -/
def me4_19 : Card := .pokemon
  { name := "Keldeo", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shoot Through", cost := [.water], damage := 2,
        effect := .benchDamage .opp 2,
        gx := false },
      { name := "Reflect Energy", cost := [.water, .water], damage := 7,
        effect := .moveEnergy .own .energy,
        gx := false }] }

/-- Froakie (me4-20). Records: me4-20, me4-88. -/
def me4_20 : Card := .pokemon
  { name := "Froakie", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Water Gun", cost := [.water], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Frogadier (me4-21). Records: me4-21, me4-89. -/
def me4_21 : Card := .pokemon
  { name := "Frogadier", stage := .stage1, evolvesFrom := some "Froakie",
    hp := 10, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Summoning Jutsu", cost := [.water], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 3)) .shuffle,
        gx := false },
      { name := "Aqua Edge", cost := [.water, .water], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Mega Greninja ex (me4-22). Records: me4-22, me4-100, me4-116, me4-122. Caveats: energyOfBasic. -/
def me4_22 : Card := .pokemon
  { name := "Mega Greninja ex", stage := .stage2, evolvesFrom := some "Frogadier",
    hp := 35, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [
      { name := "Mortal Shuriken", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.move .own .hand .discard (.energyOf .water) (.exactly 1)) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 6) (.benchCounters .opp 6)) (.counters 6))) }],
    attacks := [
      { name := "Ninja Spinner", cost := [.water, .water], damage := 0,
        effect := .choice (.damage (.const 12)) (.seq (.returnEnergy .own .active (.energyOf .water) (.exactly 1) .hand) (.damage (.const 20))),
        gx := false }] }

/-- Bergmite (me4-23). Records: me4-23. -/
def me4_23 : Card := .pokemon
  { name := "Bergmite", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Chilly", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Frost Breath", cost := [.water, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  me2pt5_55,
  me2pt5_56,
  me2pt5_58,
  me2pt5_62,
  me2pt5_63,
  me2pt5_64,
  me2pt5_68,
  me2pt5_73,
  me2pt5_77,
  me2pt5_78,
  me2pt5_83,
  me2pt5_84,
  me2pt5_86,
  me2pt5_93,
  me2pt5_94,
  me2pt5_95,
  me2pt5_100,
  me2pt5_102,
  me2pt5_103,
  me2pt5_104,
  me2pt5_108,
  me2pt5_114,
  me2pt5_115,
  me2pt5_118,
  me2pt5_119,
  me2pt5_120,
  me2pt5_121,
  me2pt5_127,
  me2pt5_130,
  me2pt5_131,
  me2pt5_132,
  me2pt5_134,
  me2pt5_135,
  me2pt5_138,
  me2pt5_139,
  me2pt5_141,
  me2pt5_143,
  me2pt5_144,
  me2pt5_145,
  me2pt5_146,
  me2pt5_147,
  me2pt5_149,
  me2pt5_150,
  me2pt5_152,
  me2pt5_153,
  me2pt5_155,
  me2pt5_156,
  me2pt5_157,
  me2pt5_162,
  me2pt5_163,
  me2pt5_164,
  me2pt5_165,
  me2pt5_166,
  me2pt5_167,
  me2pt5_168,
  me2pt5_169,
  me2pt5_170,
  me2pt5_172,
  me2pt5_173,
  me2pt5_174,
  me2pt5_176,
  me2pt5_185,
  me2pt5_191,
  me2pt5_198,
  me2pt5_206,
  me2pt5_211,
  me2pt5_214,
  me2pt5_215,
  me3_1,
  me3_2,
  me3_3,
  me3_4,
  me3_5,
  me3_6,
  me3_7,
  me3_8,
  me3_10,
  me3_11,
  me3_13,
  me3_14,
  me3_15,
  me3_16,
  me3_18,
  me3_19,
  me3_20,
  me3_21,
  me3_22,
  me3_23,
  me3_25,
  me3_26,
  me3_28,
  me3_30,
  me3_32,
  me3_33,
  me3_34,
  me3_35,
  me3_36,
  me3_37,
  me3_38,
  me3_40,
  me3_41,
  me3_42,
  me3_43,
  me3_44,
  me3_45,
  me3_48,
  me3_49,
  me3_51,
  me3_52,
  me3_54,
  me3_55,
  me3_56,
  me3_57,
  me3_58,
  me3_60,
  me3_64,
  me3_65,
  me3_66,
  me3_70,
  me3_71,
  me3_72,
  me3_73,
  me3_74,
  me3_75,
  me3_76,
  me3_80,
  me3_82,
  me3_83,
  me3_85,
  me3_86,
  me3_87,
  me4_1,
  me4_2,
  me4_3,
  me4_5,
  me4_6,
  me4_8,
  me4_9,
  me4_10,
  me4_11,
  me4_12,
  me4_13,
  me4_14,
  me4_15,
  me4_16,
  me4_19,
  me4_20,
  me4_21,
  me4_22,
  me4_23]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing, a Special Energy card whose payload models nothing or sets `rest`). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = ["Tyrantrum", "Growing Grass Energy"] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Light Ball"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Thick Scale", "Kakuna"] := by decide +kernel

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
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Hop's Pincurchin ex", "Mega Scrafty ex", "Team Rocket's Hypnotizer"] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.koByAttack` (milestone M8b), by name. -/
theorem cards_trigKO : (cards.filter (Card.hasTrig .koByAttack)).map Card.label = ["Pecharunt"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Stunfisk", "Carkol", "Registeel ex", "Mega Pyroar ex"] := by decide +kernel

end PokemonCards.Standard.Part09
