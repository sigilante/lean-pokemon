/-
Imported Standard cards, part 2 of 11 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.16.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part02
open Pokemon

/-- Sunkern (sv6-6). Records: sv6-6. -/
def sv6_6 : Card := .pokemon
  { name := "Sunkern", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bullet Seed", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.choice (.damage (.const 2)) (.choice (.damage (.const 3)) (.damage (.const 4))))),
        gx := false }] }

/-- Sunflora (sv6-7). Records: sv6-7, sv6-169. Caveats: energyOfCount. -/
def sv6_7 : Card := .pokemon
  { name := "Sunflora", stage := .stage1, evolvesFrom := some "Sunkern",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Redirected Sunlight", cost := [.grass], damage := 0,
        effect := .damage (.count (.energyAll .opp (.energyOf .fire)) 6),
        gx := false },
      { name := "Mega Drain", cost := [.grass, .colorless], damage := 5,
        effect := .heal 3,
        gx := false }] }

/-- Heracross (sv6-8). Records: sv6-8. -/
def sv6_8 : Card := .pokemon
  { name := "Heracross", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Body Slam", cost := [.grass, .colorless, .colorless], damage := 6,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Seismic Toss", cost := [.grass, .colorless, .colorless, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Phantump (sv6-12). Records: sv6-12. -/
def sv6_12 : Card := .pokemon
  { name := "Phantump", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leech Seed", cost := [.grass, .colorless], damage := 2,
        effect := .heal 2,
        gx := false }] }

/-- Trevenant (sv6-13). Records: sv6-13. -/
def sv6_13 : Card := .pokemon
  { name := "Trevenant", stage := .stage1, evolvesFrom := some "Phantump",
    hp := 12, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Giga Drain", cost := [.grass, .colorless], damage := 0,
        effect := .drain (.const 5),
        gx := false },
      { name := "Forest Dump", cost := [.grass, .grass, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Grookey (sv6-14). Records: sv6-14. -/
def sv6_14 : Card := .pokemon
  { name := "Grookey", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smash Kick", cost := [.grass], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Branch Poke", cost := [.grass, .grass], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Applin (sv6-17). Records: sv6-17. -/
def sv6_17 : Card := .pokemon
  { name := "Applin", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tumbling Attack", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Iron Leaves (sv6-19). Records: sv6-19. Caveats: koAttackWide. -/
def sv6_19 : Card := .pokemon
  { name := "Iron Leaves", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Recovery Net", cost := [.grass], damage := 0,
        effect := .move .own .discard .hand .pokemon (.upTo 2),
        gx := false },
      { name := "Avenging Edge", cost := [.grass, .colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.koLast .own true) 1) (.damage (.const 16)) (.damage (.const 10)),
        gx := false }] }

/-- Poltchageist (sv6-21). Records: sv6-21. -/
def sv6_21 : Card := .pokemon
  { name := "Poltchageist", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tea Server", cost := [.grass], damage := 0,
        effect := .ite (.countGe (.pile .own .discard (.energyOf .grass)) 1) (.move .own .discard .hand (.energyOf .grass) (.exactly 1)) .skip,
        gx := false },
      { name := "Surprise Attack", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Vulpix (sv6-26). Records: sv6-26. -/
def sv6_26 : Card := .pokemon
  { name := "Vulpix", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Live Coal", cost := [.fire, .fire], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Ninetales (sv6-27). Records: sv6-27. -/
def sv6_27 : Card := .pokemon
  { name := "Ninetales", stage := .stage1, evolvesFrom := some "Vulpix",
    hp := 12, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Eerie Glow", cost := [.fire, .fire], damage := 9,
        effect := .seq (.inflict .burned) (.inflict .confused),
        gx := false }] }

/-- Slugma (sv6-28). Records: sv6-28. -/
def sv6_28 : Card := .pokemon
  { name := "Slugma", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hot Magma", cost := [.fire, .colorless], damage := 2,
        effect := .inflict .burned,
        gx := false }] }

/-- Torkoal (sv6-30). Records: sv6-30, sv6-172. Caveats: perPokemon. -/
def sv6_30 : Card := .pokemon
  { name := "Torkoal", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ramming Shell", cost := [.fire, .colorless], damage := 3,
        effect := .linger .own .next (.reduce 3),
        gx := false },
      { name := "Fire Spin", cost := [.fire, .colorless, .colorless], damage := 11,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Chimchar (sv6-31). Records: sv6-31. -/
def sv6_31 : Card := .pokemon
  { name := "Chimchar", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Firebreathing", cost := [.fire, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Monferno (sv6-32). Records: sv6-32. -/
def sv6_32 : Card := .pokemon
  { name := "Monferno", stage := .stage1, evolvesFrom := some "Chimchar",
    hp := 9, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Chop", cost := [.fire, .colorless], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Heat Blow", cost := [.fire, .fire, .colorless], damage := 8,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Darumaka (sv6-34). Records: sv6-34. Caveats: recoil. -/
def sv6_34 : Card := .pokemon
  { name := "Darumaka", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Strength", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Fire Tackle", cost := [.fire, .fire], damage := 5,
        effect := .selfDamage 2,
        gx := false }] }

/-- Darmanitan (sv6-35). Records: sv6-35. Caveats: recoil. -/
def sv6_35 : Card := .pokemon
  { name := "Darmanitan", stage := .stage1, evolvesFrom := some "Darumaka",
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Tackle", cost := [.fire, .fire], damage := 6,
        effect := .skip,
        gx := false },
      { name := "Inferno Onrush", cost := [.fire, .fire, .fire], damage := 21,
        effect := .selfDamage 7,
        gx := false }] }

/-- Litwick (sv6-36). Records: sv6-36. -/
def sv6_36 : Card := .pokemon
  { name := "Litwick", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.fire], damage := 0,
        effect := .seq (.putBench .own .deck .basic) .shuffle,
        gx := false },
      { name := "Live Coal", cost := [.fire, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lampent (sv6-37). Records: sv6-37. -/
def sv6_37 : Card := .pokemon
  { name := "Lampent", stage := .stage1, evolvesFrom := some "Litwick",
    hp := 8, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Live Coal", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Burn It All Up", cost := [.fire, .colorless], damage := 6,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Chandelure (sv6-38). Records: sv6-38. -/
def sv6_38 : Card := .pokemon
  { name := "Chandelure", stage := .stage2, evolvesFrom := some "Lampent",
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Alluring Light", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .opp .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.move .own (.top 1) .hand .any .all) (.move .opp (.top 1) .hand .any .all))) }],
    attacks := [
      { name := "Mind Ruler", cost := [.fire], damage := 0,
        effect := .damage (.count (.pile .opp .hand .any) 3),
        gx := false }] }

/-- Hearthflame Mask Ogerpon ex (sv6-40). Records: sv6-40, sv6-192, sv6-212. -/
def sv6_40 : Card := .pokemon
  { name := "Hearthflame Mask Ogerpon ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Wrathful Hearth", cost := [.fire, .colorless, .colorless], damage := 0,
        effect := .damage (.per .own 2),
        gx := false },
      { name := "Dynamic Blaze", cost := [.fire, .fire, .fire], damage := 0,
        effect := .seq (.ite (.top .opp (.not .basic)) (.damage (.const 28)) (.damage (.const 14))) (.ite (.top .opp (.not .basic)) (.discardEnergy .own .active .energy .all) .skip),
        gx := false }] }

/-- Poliwag (sv6-41). Records: sv6-41. -/
def sv6_41 : Card := .pokemon
  { name := "Poliwag", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stampede", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Tail Rap", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 2)) (.damage (.const 4))),
        gx := false }] }

/-- Poliwhirl (sv6-42). Records: sv6-42. -/
def sv6_42 : Card := .pokemon
  { name := "Poliwhirl", stage := .stage1, evolvesFrom := some "Poliwag",
    hp := 10, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hypnosis", cost := [.water], damage := 0,
        effect := .inflict .asleep,
        gx := false },
      { name := "Double Slap", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 3)) (.damage (.const 6))),
        gx := false }] }

/-- Seaking (sv6-45). Records: sv6-45. -/
def sv6_45 : Card := .pokemon
  { name := "Seaking", stage := .stage1, evolvesFrom := some "Goldeen",
    hp := 9, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Peck Off", cost := [.water], damage := 0,
        effect := .seq (.discardTools .opp .active) (.damage (.const 5)),
        gx := false },
      { name := "Horn Drill", cost := [.colorless, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Corphish (sv6-47). Records: sv6-47. -/
def sv6_47 : Card := .pokemon
  { name := "Corphish", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Vise Grip", cost := [.water, .water, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Crawdaunt (sv6-48). Records: sv6-48. -/
def sv6_48 : Card := .pokemon
  { name := "Crawdaunt", stage := .stage1, evolvesFrom := some "Corphish",
    hp := 13, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Snip Snip", cost := [.water, .colorless], damage := 4,
        effect := .choice .skip (.choice (.move .opp (.top 1) .discard .any .all) (.seq (.move .opp (.top 1) .discard .any .all) (.move .opp (.top 1) .discard .any .all))),
        gx := false },
      { name := "Rampaging Hammer", cost := [.water, .water, .colorless], damage := 18,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Feebas (sv6-49). Records: sv6-49. -/
def sv6_49 : Card := .pokemon
  { name := "Feebas", stage := .basic, evolvesFrom := none,
    hp := 3, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flail", cost := [.water], damage := 0,
        effect := .damage (.per .own 1),
        gx := false }] }

/-- Snorunt (sv6-51). Records: sv6-51. -/
def sv6_51 : Card := .pokemon
  { name := "Snorunt", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Astonish", cost := [.water, .colorless], damage := 2,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .shuffle .any (.exactly 1)) .skip,
        gx := false }] }

/-- Glalie (sv6-52). Records: sv6-52. -/
def sv6_52 : Card := .pokemon
  { name := "Glalie", stage := .stage1, evolvesFrom := some "Snorunt",
    hp := 12, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Damage Beat", cost := [.water], damage := 0,
        effect := .damage (.per .opp 2),
        gx := false },
      { name := "Crazy Headbutt", cost := [.water, .colorless, .colorless], damage := 14,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Phione (sv6-55). Records: sv6-55, sv6-175. Caveats: energyUnitsCount. -/
def sv6_55 : Card := .pokemon
  { name := "Phione", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Beckon", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.pile .own .discard (.kind .supporter)) 1) (.move .own .discard .hand (.kind .supporter) (.exactly 1)) .skip,
        gx := false },
      { name := "Energy Press", cost := [.water], damage := 0,
        effect := .damage (.count (.energy .opp .energy) 2),
        gx := false }] }

/-- Froakie (sv6-56). Records: sv6-56. -/
def sv6_56 : Card := .pokemon
  { name := "Froakie", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flock", cost := [.water], damage := 0,
        effect := .seq (.seq (.putBench .own .deck (.named "Froakie")) (.putBench .own .deck (.named "Froakie"))) .shuffle,
        gx := false },
      { name := "Flop", cost := [.water], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Frogadier (sv6-57). Records: sv6-57. -/
def sv6_57 : Card := .pokemon
  { name := "Frogadier", stage := .stage1, evolvesFrom := some "Froakie",
    hp := 9, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Numbing Water", cost := [.water], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Cramorant (sv6-58). Records: sv6-58, sv6-176. Caveats: benchMods. -/
def sv6_58 : Card := .pokemon
  { name := "Cramorant", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Water Gun", cost := [.water], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Spit Shot", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .seq (.discardEnergy .own .active .energy .all) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 12)) (.benchDamage .opp 12)) (.damage (.const 12))),
        gx := false }] }

/-- Finizen (sv6-59). Records: sv6-59. -/
def sv6_59 : Card := .pokemon
  { name := "Finizen", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aqua Slash", cost := [.water], damage := 3,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Iron Bundle (sv6-62). Records: sv6-62. -/
def sv6_62 : Card := .pokemon
  { name := "Iron Bundle", stage := .basic, evolvesFrom := none,
    hp := 9, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Interjet", cost := [.water, .colorless], damage := 6,
        effect := .ifDone (.countGe (.bench .own .pokemon) 1) (.switch .own) (.switch .opp),
        gx := false }] }

/-- Zapdos (sv6-65). Records: sv6-65. -/
def sv6_65 : Card := .pokemon
  { name := "Zapdos", stage := .basic, evolvesFrom := none,
    hp := 12, type := .lightning, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunder Wave", cost := [.lightning], damage := 0,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Thunderbolt", cost := [.lightning, .lightning, .colorless], damage := 19,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Shinx (sv6-66). Records: sv6-66. Caveats: hiddenInfo. -/
def sv6_66 : Card := .pokemon
  { name := "Shinx", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Curiosity", cost := [.colorless], damage := 0,
        effect := .skip,
        gx := false },
      { name := "Static Shock", cost := [.lightning, .lightning], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Luxio (sv6-67). Records: sv6-67. Caveats: perPokemon. -/
def sv6_67 : Card := .pokemon
  { name := "Luxio", stage := .stage1, evolvesFrom := some "Shinx",
    hp := 9, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Big Bite", cost := [.lightning, .lightning], damage := 6,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Luxray ex (sv6-68). Records: sv6-68, sv6-195. -/
def sv6_68 : Card := .pokemon
  { name := "Luxray ex", stage := .stage2, evolvesFrom := some "Luxio",
    hp := 31, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Piercing Gaze", cost := [.colorless, .colorless], damage := 12,
        effect := .move .opp .hand .discard .any (.most 1),
        gx := false },
      { name := "Volt Strike", cost := [.lightning, .lightning], damage := 25,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Emolga (sv6-69). Records: sv6-69. Caveats: benchMods. -/
def sv6_69 : Card := .pokemon
  { name := "Emolga", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sky Wave", cost := [.colorless], damage := 1,
        effect := .seq (.spreadDamage .own 1) (.spreadDamage .opp 1),
        gx := false }] }

/-- Helioptile (sv6-70). Records: sv6-70. -/
def sv6_70 : Card := .pokemon
  { name := "Helioptile", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Static Shock", cost := [.lightning], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Heliolisk (sv6-71). Records: sv6-71, sv6-177. Caveats: recoil. -/
def sv6_71 : Card := .pokemon
  { name := "Heliolisk", stage := .stage1, evolvesFrom := some "Helioptile",
    hp := 10, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wild Charge", cost := [.lightning], damage := 7,
        effect := .selfDamage 2,
        gx := false }] }

/-- Morpeko (sv6-72). Records: sv6-72. -/
def sv6_72 : Card := .pokemon
  { name := "Morpeko", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Snack Seek", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own (.top 1) .any (.upTo 1) (.put .discard) .top)) }],
    attacks := [
      { name := "Pick and Stick", cost := [.lightning], damage := 0,
        effect := .seq (.choice (.attach .own .discard .basicEnergy .active .any) (.attach .own .discard .basicEnergy .bench .any)) (.choice (.attach .own .discard .basicEnergy .active .any) (.attach .own .discard .basicEnergy .bench .any)),
        gx := false }] }

/-- Tadbulb (sv6-73). Records: sv6-73. -/
def sv6_73 : Card := .pokemon
  { name := "Tadbulb", stage := .basic, evolvesFrom := none,
    hp := 5, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Electro Ball", cost := [.lightning, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Bellibolt (sv6-74). Records: sv6-74. -/
def sv6_74 : Card := .pokemon
  { name := "Bellibolt", stage := .stage1, evolvesFrom := some "Tadbulb",
    hp := 14, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunder Shock", cost := [.lightning, .colorless], damage := 5,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Electric Ball", cost := [.lightning, .lightning, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Wattrel (sv6-75). Records: sv6-75, sv6-178. -/
def sv6_75 : Card := .pokemon
  { name := "Wattrel", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunder Shock", cost := [.lightning], damage := 1,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Kilowattrel (sv6-76). Records: sv6-76. Caveats: perPokemon. -/
def sv6_76 : Card := .pokemon
  { name := "Kilowattrel", stage := .stage1, evolvesFrom := some "Wattrel",
    hp := 12, type := .lightning, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wind Power Charge", cost := [.colorless], damage := 1,
        effect := .linger .own .after (.bonus 12),
        gx := false },
      { name := "Strong Volt", cost := [.lightning, .colorless], damage := 10,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Clefairy (sv6-78). Records: sv6-78, me2pt5-74. -/
def sv6_78 : Card := .pokemon
  { name := "Clefairy", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Moon Kick", cost := [.colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Kadabra (sv6-81). Records: sv6-81. Caveats: energyUnitsCount. -/
def sv6_81 : Card := .pokemon
  { name := "Kadabra", stage := .stage1, evolvesFrom := some "Abra",
    hp := 8, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Psychic", cost := [.psychic], damage := 0,
        effect := .damage (.add (.const 1) (.count (.energy .opp .energy) 3)),
        gx := false }] }

/-- Girafarig (sv6-83). Records: sv6-83. Caveats: benchMods. -/
def sv6_83 : Card := .pokemon
  { name := "Girafarig", stage := .basic, evolvesFrom := none,
    hp := 10, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dual Headbutt", cost := [.colorless], damage := 3,
        effect := .benchDamage .own 1,
        gx := false }] }

/-- Farigiraf (sv6-84). Records: sv6-84. -/
def sv6_84 : Card := .pokemon
  { name := "Farigiraf", stage := .stage1, evolvesFrom := some "Girafarig",
    hp := 14, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "One-derful Rumble", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .own (.stage .stage1)) 4),
        gx := false },
      { name := "Eerie Wave", cost := [.psychic, .colorless, .colorless], damage := 8,
        effect := .inflict .confused,
        gx := false }] }

/-- Flabébé (sv6-86). Records: sv6-86. -/
def sv6_86 : Card := .pokemon
  { name := "Flabébé", stage := .basic, evolvesFrom := none,
    hp := 4, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bind Wound", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.bench .own .pokemon) 1) (.choice (.heal 3) (.benchHeal 3)) (.heal 3),
        gx := false },
      { name := "Fairy Wind", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Floette (sv6-87). Records: sv6-87. -/
def sv6_87 : Card := .pokemon
  { name := "Floette", stage := .stage1, evolvesFrom := some "Flabébé",
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Minor Errand-Running", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .basicEnergy (.upTo 3)) .shuffle,
        gx := false },
      { name := "Spinning Attack", cost := [.psychic, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Florges (sv6-88). Records: sv6-88. -/
def sv6_88 : Card := .pokemon
  { name := "Florges", stage := .stage2, evolvesFrom := some "Floette",
    hp := 14, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Captivating Invitation", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.bench .opp .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.seq (.switch .opp) (.inflict .confused)) .skip)) }],
    attacks := [
      { name := "Magical Shot", cost := [.psychic, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Slurpuff (sv6-90). Records: sv6-90. -/
def sv6_90 : Card := .pokemon
  { name := "Slurpuff", stage := .stage1, evolvesFrom := some "Swirlix",
    hp := 12, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slurp Slurp", cost := [.psychic, .colorless], damage := 0,
        effect := .choice (.seq (.damage (.const 0)) (.inflict .confused)) (.choice (.damage (.const 9)) (.damage (.const 18))),
        gx := false }] }

/-- Sandshrew (sv6-97). Records: sv6-97. -/
def sv6_97 : Card := .pokemon
  { name := "Sandshrew", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rollout", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Double Scratch", cost := [.fighting, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 2)) (.damage (.const 4))),
        gx := false }] }

/-- Sandslash (sv6-98). Records: sv6-98. Caveats: benchMods. -/
def sv6_98 : Card := .pokemon
  { name := "Sandslash", stage := .stage1, evolvesFrom := some "Sandshrew",
    hp := 12, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dig Claws", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Earthquake", cost := [.fighting, .colorless], damage := 12,
        effect := .spreadDamage .own 1,
        gx := false }] }

/-- Hisuian Growlithe (sv6-99). Records: sv6-99, sv6-181. Caveats: recoil. -/
def sv6_99 : Card := .pokemon
  { name := "Hisuian Growlithe", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Blazing Destruction", cost := [], damage := 0,
        effect := .discardStadium,
        gx := false },
      { name := "Take Down", cost := [.fighting, .colorless], damage := 4,
        effect := .selfDamage 1,
        gx := false }] }

/-- Nosepass (sv6-101). Records: sv6-101. Caveats: perPokemon. -/
def sv6_101 : Card := .pokemon
  { name := "Nosepass", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Power Rush", cost := [.colorless, .colorless, .colorless], damage := 6,
        effect := .choice .skip (.linger .own .after (.lock .attack)),
        gx := false }] }

/-- Probopass (sv6-102). Records: sv6-102, sv6-182. -/
def sv6_102 : Card := .pokemon
  { name := "Probopass", stage := .stage1, evolvesFrom := some "Nosepass",
    hp := 14, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Assault Laser", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .ite (.hasTool .opp) (.damage (.const 16)) (.damage (.const 8)),
        gx := false },
      { name := "Land Crush", cost := [.fighting, .colorless, .colorless, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Timburr (sv6-103). Records: sv6-103, sv6-183. -/
def sv6_103 : Card := .pokemon
  { name := "Timburr", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Best Punch", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 4)) .skip,
        gx := false }] }

/-- Greninja ex (sv6-106). Records: sv6-106, sv6-198, sv6-214. Caveats: benchMods, discardUnits, searchAny. -/
def sv6_106 : Card := .pokemon
  { name := "Greninja ex", stage := .stage2, evolvesFrom := some "Frogadier",
    hp := 31, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Shinobi Blade", cost := [.water], damage := 17,
        effect := .seq (.move .own .deck .hand .any (.upTo 1)) .shuffle,
        gx := false },
      { name := "Mirage Barrage", cost := [.water, .colorless, .colorless], damage := 0,
        effect := .seq (.ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all)) (.ite (.countGe (.bench .opp .any) 2) (.choice (.seq (.damage (.const 12)) (.benchSome .opp 1 .any true 12)) (.benchSome .opp 2 .any true 12)) (.seq (.damage (.const 12)) (.benchSome .opp 1 .any true 12))),
        gx := false }] }

/-- Glimmet (sv6-108). Records: sv6-108. -/
def sv6_108 : Card := .pokemon
  { name := "Glimmet", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rock Shot", cost := [.fighting], damage := 3,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Glimmora (sv6-109). Records: sv6-109. -/
def sv6_109 : Card := .pokemon
  { name := "Glimmora", stage := .stage1, evolvesFrom := some "Glimmet",
    hp := 13, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stun Poison", cost := [.colorless], damage := 0,
        effect := .choice (.seq (.inflict .paralyzed) (.inflict .poisoned)) .skip,
        gx := false },
      { name := "Venoshock", cost := [.fighting], damage := 0,
        effect := .ite (.cond .opp .poisoned) (.damage (.const 13)) (.damage (.const 3)),
        gx := false }] }

/-- Okidogi (sv6-111). Records: sv6-111, sv6pt5-74, sv8pt5-57. Caveats: energyOfCount. -/
def sv6_111 : Card := .pokemon
  { name := "Okidogi", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Adrena-Power", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := some (.energyOf .darkness, 1), eff := .hpPlus (.const 10) }, { sel := .self, filt := .any, tgt := none, src := none, need := some (.energyOf .darkness, 1), eff := .bonus 10 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Good Punch", cost := [.fighting, .fighting], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Cornerstone Mask Ogerpon ex (sv6-112). Records: sv6-112, sv6-199, sv6-215. Caveats: abilityByTool, ignFxStadium, staticPreventBench. -/
def sv6_112 : Card := .pokemon
  { name := "Cornerstone Mask Ogerpon ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [
      { name := "Cornerstone Stance", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .prevent .hasAbility }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Demolish", cost := [.fighting, .colorless, .colorless], damage := 0,
        effect := .damage (.const 14) { weak := true, resist := true, fx := true },
        gx := false }] }

/-- Poochyena (sv6-113). Records: sv6-113. -/
def sv6_113 : Card := .pokemon
  { name := "Poochyena", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Continuous Steps", cost := [.darkness], damage := 0,
        effect := .damage (.many (.const 1)),
        gx := false },
      { name := "Darkness Fang", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Mightyena (sv6-114). Records: sv6-114. Caveats: perPokemon. -/
def sv6_114 : Card := .pokemon
  { name := "Mightyena", stage := .stage1, evolvesFrom := some "Poochyena",
    hp := 12, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hunting Pack", cost := [.darkness], damage := 0,
        effect := .ite (.countGe (.bench .own (.named "Mightyena")) 1) (.damage (.const 12)) (.damage (.const 3)),
        gx := false },
      { name := "Corner", cost := [.darkness, .colorless], damage := 6,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Venipede (sv6-115). Records: sv6-115. -/
def sv6_115 : Card := .pokemon
  { name := "Venipede", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spit Poison", cost := [.darkness], damage := 0,
        effect := .inflict .poisoned,
        gx := false },
      { name := "Spinning Attack", cost := [.darkness, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Whirlipede (sv6-116). Records: sv6-116. Caveats: perPokemon. -/
def sv6_116 : Card := .pokemon
  { name := "Whirlipede", stage := .stage1, evolvesFrom := some "Venipede",
    hp := 10, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Ring", cost := [.darkness], damage := 0,
        effect := .seq (.inflict .poisoned) (.linger .opp .next (.lock .retreat)),
        gx := false },
      { name := "Spinning Attack", cost := [.darkness, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Brute Bonnet (sv6-118). Records: sv6-118. -/
def sv6_118 : Card := .pokemon
  { name := "Brute Bonnet", stage := .basic, evolvesFrom := none,
    hp := 12, type := .darkness, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Spray", cost := [.darkness], damage := 0,
        effect := .inflict .poisoned,
        gx := false },
      { name := "Relentless Punches", cost := [.darkness, .darkness, .darkness], damage := 0,
        effect := .damage (.add (.const 5) (.per .opp 5)),
        gx := false }] }

/-- Skarmory (sv6-119). Records: sv6-119. -/
def sv6_119 : Card := .pokemon
  { name := "Skarmory", stage := .basic, evolvesFrom := none,
    hp := 12, type := .metal, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cutting Wind", cost := [.metal], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Big Storm", cost := [.colorless, .colorless, .colorless], damage := 9,
        effect := .discardStadium,
        gx := false }] }

/-- Aron (sv6-120). Records: sv6-120. Caveats: recoil. -/
def sv6_120 : Card := .pokemon
  { name := "Aron", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double-Edge", cost := [.metal], damage := 2,
        effect := .selfDamage 1,
        gx := false }] }

/-- Lairon (sv6-121). Records: sv6-121, sv6-184. Caveats: recoil. -/
def sv6_121 : Card := .pokemon
  { name := "Lairon", stage := .stage1, evolvesFrom := some "Aron",
    hp := 11, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Steel Tackle", cost := [.metal], damage := 4,
        effect := .selfDamage 2,
        gx := false },
      { name := "Metal Claw", cost := [.metal, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Heatran (sv6-123). Records: sv6-123. Caveats: anyAmount60, energyOfBasic, energyOfCount, trigAttacker, trigDamaged. -/
def sv6_123 : Card := .pokemon
  { name := "Heatran", stage := .basic, evolvesFrom := none,
    hp := 14, type := .metal, retreat := 4, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Incandescent Body", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.inflict .burned) }],
    attacks := [
      { name := "Steel Burst", cost := [.metal, .colorless, .colorless], damage := 0,
        effect := .choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 0)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 0))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 1)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 5)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 2)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 10)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 3)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 15)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 4)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 20)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 5)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 25)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 6)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 30)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 7)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 35)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 8)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 40)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 9)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 45)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 10)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 50)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 11)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 55)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 12)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 60)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 13)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 65)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 14)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 70)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 15)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 75)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 16)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 80)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 17)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 85)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 18)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 90)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 19)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 95)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 20)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 100)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 21)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 105)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 22)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 110)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 23)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 115)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 24)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 120)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 25)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 125)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 26)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 130)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 27)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 135)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 28)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 140)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 29)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 145)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 30)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 150)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 31)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 155)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 32)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 160)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 33)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 165)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 34)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 170)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 35)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 175)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 36)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 180)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 37)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 185)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 38)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 190)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 39)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 195)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 40)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 200)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 41)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 205)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 42)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 210)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 43)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 215)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 44)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 220)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 45)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 225)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 46)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 230)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 47)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 235)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 48)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 240)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 49)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 245)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 50)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 250)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 51)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 255)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 52)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 260)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 53)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 265)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 54)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 270)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 55)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 275)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 56)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 280)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 57)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 285)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 58)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 290)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 59)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 295)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .metal) (.exactly 60)) (.ite (.countGe (.energy .own (.energyOf .metal)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 300))),
        gx := false }] }

/-- Varoom (sv6-124). Records: sv6-124. Caveats: mayFail. -/
def sv6_124 : Card := .pokemon
  { name := "Varoom", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Metal Coating", cost := [.colorless], damage := 0,
        effect := .attach .own .discard (.energyOf .metal) .active .any,
        gx := false },
      { name := "Ram", cost := [.metal, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Revavroom (sv6-125). Records: sv6-125. Caveats: koAttackWide. -/
def sv6_125 : Card := .pokemon
  { name := "Revavroom", stage := .stage1, evolvesFrom := some "Varoom",
    hp := 14, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rally Back", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.koLast .own true) 1) (.damage (.const 12)) (.damage (.const 3)),
        gx := false },
      { name := "Running Charge", cost := [.metal, .colorless, .colorless], damage := 0,
        effect := .damage (.many (.const 10)),
        gx := false }] }

/-- Applin (sv6-126). Records: sv6-126, sv6-185. -/
def sv6_126 : Card := .pokemon
  { name := "Applin", stage := .basic, evolvesFrom := none,
    hp := 4, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Find a Friend", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle,
        gx := false },
      { name := "Rolling Tackle", cost := [.grass, .fire], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Dipplin (sv6-127). Records: sv6-127. -/
def sv6_127 : Card := .pokemon
  { name := "Dipplin", stage := .stage1, evolvesFrom := some "Applin",
    hp := 8, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Syrup Catcher", cost := [.grass, .fire], damage := 0,
        effect := .seq (.switch .opp) (.ite (.countGe (.bench .opp .pokemon) 1) (.damage (.const 7)) .skip),
        gx := false }] }

/-- Dreepy (sv6-128). Records: sv6-128, sv8pt5-71, me2pt5-158, me2pt5-247. -/
def sv6_128 : Card := .pokemon
  { name := "Dreepy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Petty Grudge", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Bite", cost := [.fire, .psychic], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Drakloak (sv6-129). Records: sv6-129, sv8pt5-72, me2pt5-159, me2pt5-248. -/
def sv6_129 : Card := .pokemon
  { name := "Drakloak", stage := .stage1, evolvesFrom := some "Dreepy",
    hp := 9, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Recon Directive", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.pile .own .deck .any) 2) (.seq (.move .own (.top 2) .hand .any (.exactly 1)) (.move .own (.top 1) .bottom .any .all)) (.move .own (.top 1) .hand .any .all))) }],
    attacks := [
      { name := "Dragon Headbutt", cost := [.fire, .psychic], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Dragapult ex (sv6-130). Records: sv6-130, sv6-200. -/
def sv6_130 : Card := .pokemon
  { name := "Dragapult ex", stage := .stage2, evolvesFrom := some "Drakloak",
    hp := 32, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Jet Headbutt", cost := [.colorless], damage := 7,
        effect := .skip,
        gx := false },
      { name := "Phantom Dive", cost := [.fire, .psychic], damage := 20,
        effect := .seq (.benchCounters .opp 1) (.seq (.benchCounters .opp 1) (.seq (.benchCounters .opp 1) (.seq (.benchCounters .opp 1) (.seq (.benchCounters .opp 1) (.benchCounters .opp 1))))),
        gx := false }] }

/-- Chansey (sv6-133). Records: sv6-133, sv6-187. Caveats: mayFail. -/
def sv6_133 : Card := .pokemon
  { name := "Chansey", stage := .basic, evolvesFrom := none,
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lucky Attachment", cost := [.colorless], damage := 0,
        effect := .choice (.attach .own .hand .basicEnergy .active .any) (.attach .own .hand .basicEnergy .bench .any),
        gx := false },
      { name := "Boundless Power", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Blissey ex (sv6-134). Records: sv6-134, sv6-201. Caveats: moveMayFail. -/
def sv6_134 : Card := .pokemon
  { name := "Blissey ex", stage := .stage1, evolvesFrom := some "Chansey",
    hp := 30, type := .colorless, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Happy Switch", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.seq (.ite (.countGe (.energyAll .own .basicEnergy) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.moveEnergy .own .basicEnergy)) }],
    attacks := [
      { name := "Return", cost := [.colorless, .colorless, .colorless], damage := 18,
        effect := .choice (.drawTo .own 6) .skip,
        gx := false }] }

/-- Aipom (sv6-137). Records: sv6-137. -/
def sv6_137 : Card := .pokemon
  { name := "Aipom", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hang Down", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Playful Kick", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Ambipom (sv6-138). Records: sv6-138. -/
def sv6_138 : Card := .pokemon
  { name := "Ambipom", stage := .stage1, evolvesFrom := some "Aipom",
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Wicked Tail", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.choice .skip (.choice (.move .opp .hand .shuffle .any (.most 1)) (.move .opp .hand .shuffle .any (.most 2)))) }],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Ducklett (sv6-139). Records: sv6-139. -/
def sv6_139 : Card := .pokemon
  { name := "Ducklett", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Draw", cost := [.colorless], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Razor Wing", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Swanna (sv6-140). Records: sv6-140. -/
def sv6_140 : Card := .pokemon
  { name := "Swanna", stage := .stage1, evolvesFrom := some "Ducklett",
    hp := 11, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fighting Wings", cost := [.colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 11)) (.damage (.const 2)),
        gx := false },
      { name := "Gust", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Accompanying Flute (sv6-142). Records: sv6-142. Caveats: oppBenchFresh. -/
def sv6_142 : Card := .trainer "Accompanying Flute" .item
    (.seq (.ite (.countGe (.pile .opp .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .opp (.top 5) .basic (.upTo 5) .bench .shuffle))

/-- Bug Catching Set (sv6-143). Records: sv6-143, sv8pt5-102. -/
def sv6_143 : Card := .trainer "Bug Catching Set" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own (.top 7) .hand (.or (.ptype .grass) (.energyOf .grass)) (.upTo 2)) .shuffle))

/-- Cook (sv6-147). Records: sv6-147. -/
def sv6_147 : Card := .trainer "Cook" .supporter
    (.seq (.ite (.atLeast .own 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.heal 7))

/-- Enhanced Hammer (sv6-148). Records: sv6-148, sv6-224. -/
def sv6_148 : Card := .trainer "Enhanced Hammer" .item
    (.ite (.countGe (.energyAll .opp .specialEnergy) 1) (.choice (.discardEnergy .opp .active .specialEnergy (.exactly 1)) (.ite (.countGe (.bench .opp .pokemon) 1) (.discardEnergy .opp .bench .specialEnergy (.exactly 1)) (.move .own (.top 0) .hand .any (.exactly 1)))) (.move .own (.top 0) .hand .any (.exactly 1)))

/-- Hassel (sv6-151). Records: sv6-151, sv6-205. Caveats: koCheckup, upTo0. -/
def sv6_151 : Card := .trainer "Hassel" .supporter
    (.seq (.ite (.countGe (.koLast .own false) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own (.top 8) .hand .any (.upTo 3)) .shuffle)))

/-- Hyper Aroma (sv6-152). Records: sv6-152. Caveats: aceSpec, upTo0. -/
def sv6_152 : Card := .trainer "Hyper Aroma" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.stage .stage1) (.upTo 3)) .shuffle))

/-- Lana's Aid (sv6-155). Records: sv6-155, sv6-207, sv6-219. Caveats: upTo0. -/
def sv6_155 : Card := .trainer "Lana's Aid" .supporter
    (.seq (.ite (.countGe (.pile .own .discard (.or (.and .pokemon .noRuleBox) .basicEnergy)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own .discard .hand (.or (.and .pokemon .noRuleBox) .basicEnergy) (.upTo 3)))

/-- Lucky Helmet (sv6-158). Records: sv6-158. Caveats: trigAttached, trigDamaged. -/
def sv6_158 : Card := .tool "Lucky Helmet"
  { holder := .pokemon,
    attacks := [],
    abilities := [
      { name := "Lucky Helmet", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.move .own (.top 2) .hand .any .all) }] }

/-- Raifort (sv6-161). Records: sv6-161. -/
def sv6_161 : Card := .trainer "Raifort" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own (.top 5) .any (.upTo 5) (.put .discard) .top))

/-- Secret Box (sv6-163). Records: sv6-163. Caveats: aceSpec. -/
def sv6_163 : Card := .trainer "Secret Box" .item
    (.seq (.move .own .hand .discard .any (.exactly 3)) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.seq (.move .own .deck .hand (.kind .item) (.upTo 1)) (.seq (.move .own .deck .hand .tool (.upTo 1)) (.seq (.move .own .deck .hand (.kind .supporter) (.upTo 1)) (.move .own .deck .hand (.kind .stadium) (.upTo 1))))) .shuffle)))

/-- Unfair Stamp (sv6-165). Records: sv6-165. Caveats: aceSpec, koCheckup. -/
def sv6_165 : Card := .trainer "Unfair Stamp" .item
    (.seq (.ite (.countGe (.koLast .own false) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .own .hand .any) 1) .skip (.ite (.countGe (.pile .opp .deck .any) 1) .skip (.ite (.countGe (.pile .opp .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))))) (.seq (.seq (.move .own .hand .shuffle .any .all) (.move .opp .hand .shuffle .any .all)) (.seq (.move .own (.top 5) .hand .any .all) (.move .opp (.top 2) .hand .any .all)))))

/-- Luminous Energy (sv6-226). Records: sv6-226. -/
def sv6_226 : Card := .energy (.special "Luminous Energy" [[.grass, .fire, .water, .lightning, .psychic, .fighting, .darkness, .metal, .fairy, .dragon, .colorless]] { alt := some (.otherSpecial, [[.colorless]]) })

/-- Rowlet (sv6pt5-3). Records: sv6pt5-3. -/
def sv6pt5_3 : Card := .pokemon
  { name := "Rowlet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Add On", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Leafage", cost := [.grass], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Dartrix (sv6pt5-4). Records: sv6pt5-4. -/
def sv6pt5_4 : Card := .pokemon
  { name := "Dartrix", stage := .stage1, evolvesFrom := some "Rowlet",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "United Wings", cost := [.colorless], damage := 0,
        effect := .damage (.count (.pile .own .discard (.and .pokemon (.hasAttack "United Wings"))) 2),
        gx := false },
      { name := "Cutting Wind", cost := [.grass], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Decidueye (sv6pt5-5). Records: sv6pt5-5. -/
def sv6pt5_5 : Card := .pokemon
  { name := "Decidueye", stage := .stage2, evolvesFrom := some "Dartrix",
    hp := 15, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stock Up on Feathers", cost := [.colorless], damage := 0,
        effect := .drawTo .own 7,
        gx := false },
      { name := "Power Shot", cost := [.grass], damage := 0,
        effect := .ite (.countGe (.pile .own .hand (.energyOf .grass)) 1) (.seq (.move .own .hand .discard (.energyOf .grass) (.exactly 1)) (.damage (.const 17))) .skip,
        gx := false }] }

/-- Tapu Bulu (sv6pt5-6). Records: sv6pt5-6, sv6pt5-65. Caveats: recoil. -/
def sv6pt5_6 : Card := .pokemon
  { name := "Tapu Bulu", stage := .basic, evolvesFrom := none,
    hp := 14, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wood Hammer", cost := [.grass, .grass, .colorless, .colorless], damage := 22,
        effect := .selfDamage 3,
        gx := false }] }

/-- Houndour (sv6pt5-7). Records: sv6pt5-7. -/
def sv6pt5_7 : Card := .pokemon
  { name := "Houndour", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Rear Kick", cost := [.fire, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Houndoom (sv6pt5-8). Records: sv6pt5-8, sv6pt5-66. Caveats: benchMods, perPokemon. -/
def sv6pt5_8 : Card := .pokemon
  { name := "Houndoom", stage := .stage1, evolvesFrom := some "Houndour",
    hp := 12, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Snarl", cost := [.fire, .colorless, .colorless], damage := 10,
        effect := .linger .opp .next (.weaken 10),
        gx := false }] }

/-- Horsea (sv6pt5-10). Records: sv6pt5-10, sv6pt5-67. -/
def sv6pt5_10 : Card := .pokemon
  { name := "Horsea", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hold Still", cost := [.water], damage := 0,
        effect := .heal 3,
        gx := false },
      { name := "Razor Fin", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Seadra (sv6pt5-11). Records: sv6pt5-11. -/
def sv6pt5_11 : Card := .pokemon
  { name := "Seadra", stage := .stage1, evolvesFrom := some "Horsea",
    hp := 9, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Backup", cost := [.water], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 3)) .shuffle,
        gx := false },
      { name := "Sharp Fin", cost := [.colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Sneasel (sv6pt5-13). Records: sv6pt5-13, me2pt5-44. Caveats: perPokemon. -/
def sv6pt5_13 : Card := .pokemon
  { name := "Sneasel", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cut", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Beset", cost := [.water, .water], damage := 3,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Weavile (sv6pt5-14). Records: sv6pt5-14, me2pt5-45, me2pt5-228. -/
def sv6pt5_14 : Card := .pokemon
  { name := "Weavile", stage := .stage1, evolvesFrom := some "Sneasel",
    hp := 10, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.water], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Hail Claw", cost := [.water, .water], damage := 7,
        effect := .seq (.discardEnergy .own .active .energy .all) (.inflict .paralyzed),
        gx := false }] }

/-- Drowzee (sv6pt5-16). Records: sv6pt5-16. Caveats: hiddenInfo. -/
def sv6pt5_16 : Card := .pokemon
  { name := "Drowzee", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Eerie Gaze", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Duskull (sv6pt5-18). Records: sv6pt5-18, sv6pt5-68, sv8pt5-35. -/
def sv6pt5_18 : Card := .pokemon
  { name := "Duskull", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Come and Get You", cost := [.psychic], damage := 0,
        effect := .seq (.putBench .own .discard (.named "Duskull")) (.seq (.putBench .own .discard (.named "Duskull")) (.putBench .own .discard (.named "Duskull"))),
        gx := false },
      { name := "Mumble", cost := [.psychic, .psychic], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Dusclops (sv6pt5-19). Records: sv6pt5-19, sv6pt5-69, sv8pt5-36. Caveats: koCounters, selfBench, selfKOBench, selfKOTiming. -/
def sv6pt5_19 : Card := .pokemon
  { name := "Dusclops", stage := .stage1, evolvesFrom := some "Duskull",
    hp := 9, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Cursed Blast", use := .once,
        spot := none, cond := none,
        effect := .seq (.fx (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 5) (.benchCounters .opp 5)) (.counters 5))) (.self (.counters 9999)) }],
    attacks := [
      { name := "Will-O-Wisp", cost := [.psychic, .psychic], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Dusknoir (sv6pt5-20). Records: sv6pt5-20, sv6pt5-70, sv8pt5-37. Caveats: koCounters, perPokemon, selfBench, selfKOBench, selfKOTiming. -/
def sv6pt5_20 : Card := .pokemon
  { name := "Dusknoir", stage := .stage2, evolvesFrom := some "Dusclops",
    hp := 16, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Cursed Blast", use := .once,
        spot := none, cond := none,
        effect := .seq (.fx (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 13) (.benchCounters .opp 13)) (.counters 13))) (.self (.counters 9999)) }],
    attacks := [
      { name := "Shadow Bind", cost := [.psychic, .psychic, .colorless], damage := 15,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Croagunk (sv6pt5-23). Records: sv6pt5-23. -/
def sv6pt5_23 : Card := .pokemon
  { name := "Croagunk", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Light Punch", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Frog Hop", cost := [.fighting, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Toxicroak (sv6pt5-24). Records: sv6pt5-24. -/
def sv6pt5_24 : Card := .pokemon
  { name := "Toxicroak", stage := .stage1, evolvesFrom := some "Croagunk",
    hp := 13, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Corkscrew Punch", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Clean Hit", cost := [.fighting, .colorless, .colorless], damage := 0,
        effect := .ite (.top .opp (.not .basic)) (.damage (.const 18)) (.damage (.const 9)),
        gx := false }] }

/-- Bloodmoon Ursaluna (sv6pt5-25). Records: sv6pt5-25, sv8pt5-54. Caveats: selfBench, upTo0. -/
def sv6pt5_25 : Card := .pokemon
  { name := "Bloodmoon Ursaluna", stage := .basic, evolvesFrom := none,
    hp := 15, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Battle-Hardened", use := .onPlay .bench,
        spot := none, cond := none,
        effect := .seq (.self (.attach .hand (.energyOf .fighting))) (.self (.attach .hand (.energyOf .fighting))) }],
    attacks := [
      { name := "Mad Bite", cost := [.fighting, .fighting, .colorless], damage := 0,
        effect := .damage (.add (.const 10) (.per .opp 3)),
        gx := false }] }

/-- Slither Wing (sv6pt5-26). Records: sv6pt5-26. -/
def sv6pt5_26 : Card := .pokemon
  { name := "Slither Wing", stage := .basic, evolvesFrom := none,
    hp := 14, type := .fighting, retreat := 3, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Iron Smasher", cost := [.fighting, .colorless], damage := 0,
        effect := .ite (.countGe (.inPlay .opp (.and .pokemon (.or (.or (.or (.nameIn ["Ciphermaniac's Codebreaking", "Future Booster Energy Capsule", "Iron Boulder", "Iron Boulder ex", "Iron Bundle", "Iron Crown", "Iron Crown ex", "Iron Hands", "Iron Jugulis", "Iron Leaves", "Iron Leaves ex", "Iron Moth", "Iron Thorns", "Iron Thorns ex", "Iron Treads", "Iron Valiant", "Reboot Pod"]) (.and (.named "Miraidon") (.hasAttack "Peak Acceleration"))) (.and (.named "Miraidon") (.hasAttack "C.O.D.E.: Protect"))) (.and (.named "Miraidon ex") (.hasAttack "Repulsion Bolt"))))) 1) (.damage (.const 14)) (.damage (.const 2)),
        gx := false },
      { name := "Smashing Wing", cost := [.fighting, .fighting, .colorless], damage := 13,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Zubat (sv6pt5-27). Records: sv6pt5-27. -/
def sv6pt5_27 : Card := .pokemon
  { name := "Zubat", stage := .basic, evolvesFrom := none,
    hp := 5, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lead", cost := [.darkness], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .supporter) (.upTo 1)) .shuffle,
        gx := false },
      { name := "Darkness Fang", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Golbat (sv6pt5-28). Records: sv6pt5-28. -/
def sv6pt5_28 : Card := .pokemon
  { name := "Golbat", stage := .stage1, evolvesFrom := some "Zubat",
    hp := 8, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Speed Dive", cost := [.darkness], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Pitch-Black Blade", cost := [.darkness, .colorless], damage := 8,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Crobat (sv6pt5-29). Records: sv6pt5-29. Caveats: poisonStrength. -/
def sv6pt5_29 : Card := .pokemon
  { name := "Crobat", stage := .stage2, evolvesFrom := some "Golbat",
    hp := 13, type := .darkness, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Shadowy Envoy", use := .once,
        spot := none, cond := some (.countGe (.played .own (.and (.kind .supporter) (.named "Janine's Secret Art"))) 1),
        effect := .fx (.seq (.seq (.ite (.countGe (.pile .own .hand .any) 8) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.drawTo .own 8)) }],
    attacks := [
      { name := "Poison Fang", cost := [.darkness, .colorless], damage := 12,
        effect := .seq (.inflict .poisoned) (.poisonUp 1),
        gx := false }] }

/-- Absol (sv6pt5-30). Records: sv6pt5-30. Caveats: energyOfCount. -/
def sv6pt5_30 : Card := .pokemon
  { name := "Absol", stage := .basic, evolvesFrom := none,
    hp := 11, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Darkfall", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.energyAll .own (.energyOf .darkness)) 3) (.damage (.const 7)) (.damage (.const 2)),
        gx := false }] }

/-- Zorua (sv6pt5-31). Records: sv6pt5-31, sv6pt5-75. -/
def sv6pt5_31 : Card := .pokemon
  { name := "Zorua", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stampede", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Double Scratch", cost := [.darkness, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 2)) (.damage (.const 4))),
        gx := false }] }

/-- Zoroark (sv6pt5-32). Records: sv6pt5-32. -/
def sv6pt5_32 : Card := .pokemon
  { name := "Zoroark", stage := .stage1, evolvesFrom := some "Zorua",
    hp := 12, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Illusory Hijacking", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .opp .ex) 6),
        gx := false },
      { name := "Claw Slash", cost := [.darkness, .colorless, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Fezandipiti ex (sv6pt5-38). Records: sv6pt5-38, sv6pt5-84, sv6pt5-92, me2pt5-142, me2pt5-288. Caveats: benchMods, koCheckup, onePerName. -/
def sv6pt5_38 : Card := .pokemon
  { name := "Fezandipiti ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Flip the Script", use := .once,
        spot := none, cond := some (.countGe (.koLast .own false) 1),
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 3) .hand .any .all)) }],
    attacks := [
      { name := "Cruel Arrow", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 10)) (.benchDamage .opp 10)) (.damage (.const 10)),
        gx := false }] }

/-- Cufant (sv6pt5-41). Records: sv6pt5-41, sv6pt5-76. -/
def sv6pt5_41 : Card := .pokemon
  { name := "Cufant", stage := .basic, evolvesFrom := none,
    hp := 10, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.metal, .colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Confront", cost := [.metal, .metal, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Varoom (sv6pt5-43). Records: sv6pt5-43. Caveats: perPokemon. -/
def sv6pt5_43 : Card := .pokemon
  { name := "Varoom", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rigidify", cost := [.metal], damage := 0,
        effect := .linger .own .next (.reduce 3),
        gx := false },
      { name := "Headbutt Bounce", cost := [.metal, .metal], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Axew (sv6pt5-44). Records: sv6pt5-44. -/
def sv6pt5_44 : Card := .pokemon
  { name := "Axew", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Sharp Fang", cost := [.fighting, .metal], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Haxorus (sv6pt5-46). Records: sv6pt5-46. Caveats: koCounters. -/
def sv6pt5_46 : Card := .pokemon
  { name := "Haxorus", stage := .stage2, evolvesFrom := some "Fraxure",
    hp := 17, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bring Down the Axe", cost := [.fighting], damage := 0,
        effect := .ite (.countGe (.energy .opp .specialEnergy) 1) (.counters 9999) .skip,
        gx := false },
      { name := "Dragon Pulse", cost := [.fighting, .metal], damage := 23,
        effect := .move .own (.top 3) .discard .any .all,
        gx := false }] }

/-- Meowth (sv6pt5-48). Records: sv6pt5-48, me2-106. -/
def sv6pt5_48 : Card := .pokemon
  { name := "Meowth", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fury Swipes", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 2)) (.choice (.damage (.const 4)) (.damage (.const 6)))),
        gx := false }] }

/-- Persian (sv6pt5-49). Records: sv6pt5-49, sv6pt5-78. -/
def sv6pt5_49 : Card := .pokemon
  { name := "Persian", stage := .stage1, evolvesFrom := some "Meowth",
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fury Swipes", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 5)) (.choice (.damage (.const 10)) (.damage (.const 15)))),
        gx := false },
      { name := "Slashing Claw", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Furfrou (sv6pt5-51). Records: sv6pt5-51. Caveats: mayFail. -/
def sv6pt5_51 : Card := .pokemon
  { name := "Furfrou", stage := .basic, evolvesFrom := none,
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Energy Assist", cost := [.colorless], damage := 3,
        effect := .attach .own .discard .basicEnergy .bench .any,
        gx := false }] }

/-- Stufful (sv6pt5-52). Records: sv6pt5-52. Caveats: recoil. -/
def sv6pt5_52 : Card := .pokemon
  { name := "Stufful", stage := .basic, evolvesFrom := none,
    hp := 8, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Take Down", cost := [.colorless], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Bewear (sv6pt5-53). Records: sv6pt5-53, sv6pt5-79. -/
def sv6pt5_53 : Card := .pokemon
  { name := "Bewear", stage := .stage1, evolvesFrom := some "Stufful",
    hp := 13, type := .colorless, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Power Charger", cost := [.colorless], damage := 3,
        effect := .seq (.attach .own .deck .basicEnergy .active .any) .shuffle,
        gx := false },
      { name := "Hammer In", cost := [.colorless, .colorless, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Academy at Night (sv6pt5-54). Records: sv6pt5-54. -/
def sv6pt5_54 : Card := .trainer "Academy at Night" .stadium
    (.move .own .hand .top .any (.exactly 1))

/-- Colress's Tenacity (sv6pt5-57). Records: sv6pt5-57, sv6pt5-87. -/
def sv6pt5_57 : Card := .trainer "Colress's Tenacity" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.seq (.move .own .deck .hand (.kind .stadium) (.upTo 1)) (.move .own .deck .hand .energy (.upTo 1))) .shuffle))

/-- Dangerous Laser (sv6pt5-58). Records: sv6pt5-58. Caveats: aceSpec. -/
def sv6pt5_58 : Card := .trainer "Dangerous Laser" .item
    (.seq (.ite (.cond .opp .burned) (.ite (.cond .opp .confused) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) .skip) (.seq (.inflict .burned) (.inflict .confused)))

/-- Night Stretcher (sv6pt5-61). Records: sv6pt5-61, sv8-251, me1-173, me2pt5-196. -/
def sv6pt5_61 : Card := .trainer "Night Stretcher" .item
    (.move .own .discard .hand (.or .pokemon .basicEnergy) (.exactly 1))

/-- Ledyba (sv7-2). Records: sv7-2. -/
def sv7_2 : Card := .pokemon
  { name := "Ledyba", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt Bounce", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Celebi (sv7-4). Records: sv7-4. -/
def sv7_4 : Card := .pokemon
  { name := "Celebi", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Leaf Step", cost := [.grass], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Lileep (sv7-5). Records: sv7-5, sv7-145. Caveats: perPokemon. -/
def sv7_5 : Card := .pokemon
  { name := "Lileep", stage := .stage1, evolvesFrom := some "Antique Root Fossil",
    hp := 10, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bind Down", cost := [.grass], damage := 5,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Carnivine (sv7-7). Records: sv7-7. -/
def sv7_7 : Card := .pokemon
  { name := "Carnivine", stage := .basic, evolvesFrom := none,
    hp := 11, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nosh", cost := [.colorless], damage := 0,
        effect := .heal 4,
        gx := false },
      { name := "Loom Over", cost := [.grass, .colorless, .colorless], damage := 0,
        effect := .damage (.sub (.const 13) (.per .own 1)),
        gx := false }] }

/-- Mow Rotom (sv7-8). Records: sv7-8. -/
def sv7_8 : Card := .pokemon
  { name := "Mow Rotom", stage := .basic, evolvesFrom := none,
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reaping Dash", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.discardTools .opp .active) (.discardEnergy .opp .active .specialEnergy .all)) (.damage (.const 3)),
        gx := false }] }

/-- Grubbin (sv7-9). Records: sv7-9, me2pt5-17. -/
def sv7_9 : Card := .pokemon
  { name := "Grubbin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ambush", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 1)),
        gx := false }] }

/-- Gossifleur (sv7-10). Records: sv7-10. -/
def sv7_10 : Card := .pokemon
  { name := "Gossifleur", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Spin", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- Applin (sv7-12). Records: sv7-12, sv8pt5-9. -/
def sv7_12 : Card := .pokemon
  { name := "Applin", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spray Fluid", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Nymble (sv7-15). Records: sv7-15. -/
def sv7_15 : Card := .pokemon
  { name := "Nymble", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Lokix (sv7-16). Records: sv7-16. -/
def sv7_16 : Card := .pokemon
  { name := "Lokix", stage := .stage1, evolvesFrom := some "Nymble",
    hp := 11, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spiral Kick", cost := [.colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Toedscool (sv7-17). Records: sv7-17. -/
def sv7_17 : Card := .pokemon
  { name := "Toedscool", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.grass], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Gentle Slap", cost := [.grass, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Toedscruel (sv7-18). Records: sv7-18. -/
def sv7_18 : Card := .pokemon
  { name := "Toedscruel", stage := .stage1, evolvesFrom := some "Toedscool",
    hp := 14, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mega Drain", cost := [.grass, .colorless], damage := 3,
        effect := .heal 3,
        gx := false },
      { name := "Whip Smash", cost := [.grass, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  sv6_6,
  sv6_7,
  sv6_8,
  sv6_12,
  sv6_13,
  sv6_14,
  sv6_17,
  sv6_19,
  sv6_21,
  sv6_26,
  sv6_27,
  sv6_28,
  sv6_30,
  sv6_31,
  sv6_32,
  sv6_34,
  sv6_35,
  sv6_36,
  sv6_37,
  sv6_38,
  sv6_40,
  sv6_41,
  sv6_42,
  sv6_45,
  sv6_47,
  sv6_48,
  sv6_49,
  sv6_51,
  sv6_52,
  sv6_55,
  sv6_56,
  sv6_57,
  sv6_58,
  sv6_59,
  sv6_62,
  sv6_65,
  sv6_66,
  sv6_67,
  sv6_68,
  sv6_69,
  sv6_70,
  sv6_71,
  sv6_72,
  sv6_73,
  sv6_74,
  sv6_75,
  sv6_76,
  sv6_78,
  sv6_81,
  sv6_83,
  sv6_84,
  sv6_86,
  sv6_87,
  sv6_88,
  sv6_90,
  sv6_97,
  sv6_98,
  sv6_99,
  sv6_101,
  sv6_102,
  sv6_103,
  sv6_106,
  sv6_108,
  sv6_109,
  sv6_111,
  sv6_112,
  sv6_113,
  sv6_114,
  sv6_115,
  sv6_116,
  sv6_118,
  sv6_119,
  sv6_120,
  sv6_121,
  sv6_123,
  sv6_124,
  sv6_125,
  sv6_126,
  sv6_127,
  sv6_128,
  sv6_129,
  sv6_130,
  sv6_133,
  sv6_134,
  sv6_137,
  sv6_138,
  sv6_139,
  sv6_140,
  sv6_142,
  sv6_143,
  sv6_147,
  sv6_148,
  sv6_151,
  sv6_152,
  sv6_155,
  sv6_158,
  sv6_161,
  sv6_163,
  sv6_165,
  sv6_226,
  sv6pt5_3,
  sv6pt5_4,
  sv6pt5_5,
  sv6pt5_6,
  sv6pt5_7,
  sv6pt5_8,
  sv6pt5_10,
  sv6pt5_11,
  sv6pt5_13,
  sv6pt5_14,
  sv6pt5_16,
  sv6pt5_18,
  sv6pt5_19,
  sv6pt5_20,
  sv6pt5_23,
  sv6pt5_24,
  sv6pt5_25,
  sv6pt5_26,
  sv6pt5_27,
  sv6pt5_28,
  sv6pt5_29,
  sv6pt5_30,
  sv6pt5_31,
  sv6pt5_32,
  sv6pt5_38,
  sv6pt5_41,
  sv6pt5_43,
  sv6pt5_44,
  sv6pt5_46,
  sv6pt5_48,
  sv6pt5_49,
  sv6pt5_51,
  sv6pt5_52,
  sv6pt5_53,
  sv6pt5_54,
  sv6pt5_57,
  sv6pt5_58,
  sv6pt5_61,
  sv7_2,
  sv7_4,
  sv7_5,
  sv7_7,
  sv7_8,
  sv7_9,
  sv7_10,
  sv7_12,
  sv7_15,
  sv7_16,
  sv7_17,
  sv7_18]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing, a Special Energy card whose payload models nothing or sets `rest`). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = ["Okidogi"] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Okidogi"] := by decide +kernel

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
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Heatran", "Lucky Helmet"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Trevenant", "Torkoal", "Houndoom", "Varoom"] := by decide +kernel

end PokemonCards.Standard.Part02
