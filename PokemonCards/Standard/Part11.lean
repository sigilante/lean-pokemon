/-
Imported Standard cards, part 11 of 11 (95 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.19.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part11
open Pokemon

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

/-- Hisuian Zoroark (me55-123). Records: me55-123. -/
def me55_123 : Card := .pokemon
  { name := "Hisuian Zoroark", stage := .stage1, evolvesFrom := some "Hisuian Zorua",
    hp := 12, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Swirling Resentment", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .hitBy .opp .active 1 .any false false (.toHp 5),
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

/-- Meowscarada ex (me6-14). Records: me6-14. Caveats: benchMods. -/
def me6_14 : Card := .pokemon
  { name := "Meowscarada ex", stage := .stage2, evolvesFrom := some "Floragato",
    hp := 32, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Magical Bullet", cost := [.grass, .grass], damage := 12,
        effect := .hitBy .opp .bench 1 .any true true (.const 12),
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

/-- Magmar (me6-20). Records: me6-20. -/
def me6_20 : Card := .pokemon
  { name := "Magmar", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gather Strength", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .basicEnergy (.upTo 2)) .shuffle,
        gx := false },
      { name := "Combustion", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Torkoal (me6-22). Records: me6-22. -/
def me6_22 : Card := .pokemon
  { name := "Torkoal", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Searing Flame", cost := [.fire, .colorless], damage := 3,
        effect := .inflict .burned,
        gx := false },
      { name := "Combustion Blast", cost := [.fire, .fire, .colorless], damage := 12,
        effect := .skip,
        gx := false, selfLock := .this }] }

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

/-- Mantine (me6-25). Records: me6-25. -/
def me6_25 : Card := .pokemon
  { name := "Mantine", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Make Waves", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .hand .shuffle .any .all) (.seq (.move .own (.top 4) .hand .any .all) (.seq (.move .opp .hand .shuffle .any .all) (.move .opp (.top 4) .hand .any .all))),
        gx := false },
      { name := "Bubble Drain", cost := [.water, .colorless], damage := 3,
        effect := .heal 3,
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
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own (.top 1) .hand .any .all) (.choice (.move .own .hand .bottom .any (.exactly 1)) .skip))) }],
    attacks := [
      { name := "Gentle Slap", cost := [.water, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Wishiwashi ex (me6-29). Records: me6-29, me6-120. -/
def me6_29 : Card := .pokemon
  { name := "Wishiwashi ex", stage := .basic, evolvesFrom := none,
    hp := 26, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Oceanic Gain", use := .once,
        spot := some .active, cond := none,
        effect := .seq (.fx (.ite (.atLeast .own 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.self (.heal 5)) }],
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

/-- Electivire (me6-31). Records: me6-31, me6-108. Caveats: anyAmount60. -/
def me6_31 : Card := .pokemon
  { name := "Electivire", stage := .stage1, evolvesFrom := some "Electabuzz",
    hp := 14, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Body Slam", cost := [.colorless, .colorless], damage := 3,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Voltaic Hammer", cost := [.lightning, .lightning, .colorless, .colorless], damage := 0,
        effect := .choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.seq (.discardEnergy .own .active .basicEnergy (.exactly 0)) (.damage (.const 0))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 1)) (.damage (.const 6)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 2)) (.damage (.const 12)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 3)) (.damage (.const 18)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 4)) (.damage (.const 24)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 5)) (.damage (.const 30)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 6)) (.damage (.const 36)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 7)) (.damage (.const 42)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 8)) (.damage (.const 48)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 9)) (.damage (.const 54)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 10)) (.damage (.const 60)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 11)) (.damage (.const 66)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 12)) (.damage (.const 72)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 13)) (.damage (.const 78)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 14)) (.damage (.const 84)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 15)) (.damage (.const 90)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 16)) (.damage (.const 96)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 17)) (.damage (.const 102)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 18)) (.damage (.const 108)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 19)) (.damage (.const 114)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 20)) (.damage (.const 120)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 21)) (.damage (.const 126)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 22)) (.damage (.const 132)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 23)) (.damage (.const 138)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 24)) (.damage (.const 144)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 25)) (.damage (.const 150)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 26)) (.damage (.const 156)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 27)) (.damage (.const 162)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 28)) (.damage (.const 168)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 29)) (.damage (.const 174)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 30)) (.damage (.const 180)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 31)) (.damage (.const 186)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 32)) (.damage (.const 192)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 33)) (.damage (.const 198)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 34)) (.damage (.const 204)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 35)) (.damage (.const 210)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 36)) (.damage (.const 216)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 37)) (.damage (.const 222)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 38)) (.damage (.const 228)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 39)) (.damage (.const 234)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 40)) (.damage (.const 240)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 41)) (.damage (.const 246)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 42)) (.damage (.const 252)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 43)) (.damage (.const 258)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 44)) (.damage (.const 264)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 45)) (.damage (.const 270)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 46)) (.damage (.const 276)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 47)) (.damage (.const 282)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 48)) (.damage (.const 288)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 49)) (.damage (.const 294)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 50)) (.damage (.const 300)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 51)) (.damage (.const 306)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 52)) (.damage (.const 312)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 53)) (.damage (.const 318)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 54)) (.damage (.const 324)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 55)) (.damage (.const 330)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 56)) (.damage (.const 336)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 57)) (.damage (.const 342)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 58)) (.damage (.const 348)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 59)) (.damage (.const 354)))) (.seq (.discardEnergy .own .active .basicEnergy (.exactly 60)) (.damage (.const 360))),
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

/-- Pincurchin (me6-36). Records: me6-36, me6-109. Caveats: energyUnitsCount. -/
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
        effect := .fx (.seq (.ite (.countGe (.pile .own .discard (.energyOf .lightning)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.attach .own .discard (.energyOf .lightning) .active .any) (.attach .own .discard (.energyOf .lightning) .bench .any))) }],
    attacks := [
      { name := "Electric Punch", cost := [.lightning, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Wattrel (me6-40). Records: me6-40. Caveats: perPokemon, shieldReach. -/
def me6_40 : Card := .pokemon
  { name := "Wattrel", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Agility", cost := [.lightning], damage := 1,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false }] }

/-- Kilowattrel (me6-41). Records: me6-41. -/
def me6_41 : Card := .pokemon
  { name := "Kilowattrel", stage := .stage1, evolvesFrom := some "Wattrel",
    hp := 12, type := .lightning, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Raid", cost := [.lightning], damage := 0,
        effect := .ite (.evolved .own) (.damage (.const 12)) (.damage (.const 3)),
        gx := false },
      { name := "Speed Dive", cost := [.lightning, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Miraidon (me6-42). Records: me6-42. -/
def me6_42 : Card := .pokemon
  { name := "Miraidon", stage := .basic, evolvesFrom := none,
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Claw Slash", cost := [.lightning, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Flashing Bolt", cost := [.lightning, .lightning, .colorless], damage := 12,
        effect := .skip,
        gx := false, selfLock := .this }] }

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

/-- Sandslash (me6-50). Records: me6-50. Caveats: trigAttacker, trigDamaged. -/
def me6_50 : Card := .pokemon
  { name := "Sandslash", stage := .stage1, evolvesFrom := some "Sandshrew",
    hp := 11, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Counterattack Quills", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.counters 3) }],
    attacks := [
      { name := "Digging Claw", cost := [.fighting], damage := 6,
        effect := .move .opp (.top 1) .discard .any .all,
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

/-- Nidoqueen (me6-57). Records: me6-57. -/
def me6_57 : Card := .pokemon
  { name := "Nidoqueen", stage := .stage2, evolvesFrom := some "Nidorina",
    hp := 17, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Maternal Call", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.bench .opp .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.switch .opp) .skip)) }],
    attacks := [
      { name := "Giga Impact", cost := [.darkness, .colorless, .colorless], damage := 15,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Spinarak (me6-58). Records: me6-58. -/
def me6_58 : Card := .pokemon
  { name := "Spinarak", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Sting", cost := [.darkness], damage := 0,
        effect := .inflict .poisoned,
        gx := false },
      { name := "Bug Out", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .seq (.damage (.count (.pile .own (.bottom 7) (.and .pokemon (.hasAttack "Bug Out"))) 5)) (.look .own (.bottom 7) .pokemon .all (.put .shuffle) .discard),
        gx := false }] }

/-- Sableye (me6-60). Records: me6-60. Caveats: oppBenchFresh. -/
def me6_60 : Card := .pokemon
  { name := "Sableye", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lure Out", cost := [.darkness], damage := 0,
        effect := .look .opp (.top 5) .basic (.upTo 5) .bench .shuffle,
        gx := false },
      { name := "Ominous Eyes", cost := [.darkness, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 5) (.benchCounters .opp 5)) (.counters 5),
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

/-- Zoroark ex (me6-67). Records: me6-67. -/
def me6_67 : Card := .pokemon
  { name := "Zoroark ex", stage := .stage1, evolvesFrom := some "Zorua",
    hp := 27, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Riotous Beating", cost := [.darkness], damage := 0,
        effect := .damage (.add (.const 2) (.count (.bench .own .pokemon) 2)),
        gx := false },
      { name := "Slashing Strike", cost := [.darkness, .colorless, .colorless], damage := 21,
        effect := .skip,
        gx := false, selfLock := .this }] }

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

/-- Zarude (me6-71). Records: me6-71. -/
def me6_71 : Card := .pokemon
  { name := "Zarude", stage := .basic, evolvesFrom := none,
    hp := 13, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Corkscrew Punch", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Deadly Whip", cost := [.darkness, .colorless], damage := 0,
        effect := .choice (.damage (.const 20)) (.damage (.const 5)),
        gx := false }] }

/-- Druddigon (me6-72). Records: me6-72. -/
def me6_72 : Card := .pokemon
  { name := "Druddigon", stage := .basic, evolvesFrom := none,
    hp := 12, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Drag Off", cost := [.fire, .water], damage := 0,
        effect := .seq (.switch .opp) (.ite (.countGe (.bench .opp .pokemon) 1) (.damage (.const 4)) .skip),
        gx := false },
      { name := "Claw Slash", cost := [.colorless, .colorless, .colorless], damage := 8,
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

/-- Kommo-o (me6-75). Records: me6-75. -/
def me6_75 : Card := .pokemon
  { name := "Kommo-o", stage := .stage2, evolvesFrom := some "Hakamo-o",
    hp := 16, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Beat Scales", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own (.top 6) .basicEnergy (.upTo 6) (.attach (.ptype .dragon)) .shuffle)) }],
    attacks := [
      { name := "Hammer In", cost := [.lightning, .fighting, .colorless], damage := 17,
        effect := .skip,
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

/-- Delibird (me6-79). Records: me6-79. Caveats: failToFind. -/
def me6_79 : Card := .pokemon
  { name := "Delibird", stage := .basic, evolvesFrom := none,
    hp := 9, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Energizing Present", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own (.top 6) .energy (.most 1) (.put .hand) .bottom)) }],
    attacks := [
      { name := "Beat", cost := [.colorless], damage := 1,
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

/-- Altaria (me6-82). Records: me6-82, me6-116. Caveats: noRetreatLast. -/
def me6_82 : Card := .pokemon
  { name := "Altaria", stage := .stage1, evolvesFrom := some "Swablu",
    hp := 11, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Cottony Carrier", use := .static [{ sel := .own, filt := .basic, tgt := none, src := none, need := none, eff := .noRetreat }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Flap", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Mega Rayquaza ex (me6-84). Records: me6-84, me6-138, me6-141. Caveats: energyOfCount, failToFind, selfBench. -/
def me6_84 : Card := .pokemon
  { name := "Mega Rayquaza ex", stage := .basic, evolvesFrom := none,
    hp := 28, type := .colorless, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .megaEx, tera := false,
    abilities := [
      { name := "Ruler's Roar", use := .onPlay .bench,
        spot := none, cond := none,
        effect := .fx (.look .own (.top 4) .basicEnergy (.most 1) (.attach .any) .bottom) }],
    attacks := [
      { name := "Storm Emerald", cost := [.fire, .lightning, .colorless], damage := 0,
        effect := .damage (.count (.energyAll .own (.or (.energyOf .fire) (.energyOf .lightning))) 5),
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
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.or (.kind .supporter) (.kind .stadium)) (.upTo 3)) .shuffle))

/-- Zinnia's Trust (me6-103). Records: me6-103, me6-131, me6-140. Caveats: shiftFromMoved. -/
def me6_103 : Card := .trainer "Zinnia's Trust" .supporter
    (.seq (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.switch .own) (.shiftEnergy .own .bench .energy (.most 1) .active true)))

/-- The cards of this part. -/
def cards : List Card := [
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
  me55_123,
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
  me6_14,
  me6_15,
  me6_16,
  me6_17,
  me6_18,
  me6_19,
  me6_20,
  me6_22,
  me6_24,
  me6_25,
  me6_27,
  me6_28,
  me6_29,
  me6_30,
  me6_31,
  me6_32,
  me6_34,
  me6_36,
  me6_37,
  me6_38,
  me6_39,
  me6_40,
  me6_41,
  me6_42,
  me6_43,
  me6_44,
  me6_46,
  me6_50,
  me6_51,
  me6_55,
  me6_56,
  me6_57,
  me6_58,
  me6_60,
  me6_61,
  me6_62,
  me6_63,
  me6_64,
  me6_65,
  me6_66,
  me6_67,
  me6_68,
  me6_69,
  me6_70,
  me6_71,
  me6_72,
  me6_73,
  me6_74,
  me6_75,
  me6_76,
  me6_77,
  me6_78,
  me6_79,
  me6_80,
  me6_81,
  me6_82,
  me6_84,
  me6_86,
  me6_87,
  me6_89,
  me6_103]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing, a Special Energy card whose payload models nothing or sets `rest`). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = [] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = [] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = [] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = ["Altaria"] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 25 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 25)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Sandslash"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Zamazenta", "Jangmo-o", "Onix", "Jangmo-o"] := by decide +kernel

end PokemonCards.Standard.Part11
