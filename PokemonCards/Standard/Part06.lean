/-
Imported Standard cards, part 6 of 8 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.5.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part06
open Pokemon

/-- Fearow (me1-103). Records: me1-103. -/
def me1_103 : Card := .pokemon
  { name := "Fearow", stage := .stage1, evolvesFrom := some "Spearow",
    hp := 10, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Repeating Drill", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 3)) (.choice (.damage (.const 6)) (.choice (.damage (.const 9)) (.choice (.damage (.const 12)) (.damage (.const 15)))))),
        gx := false }] }

/-- Mega Kangaskhan ex (me1-104). Records: me1-104, me1-164, me1-182. Caveats: onePerName. -/
def me1_104 : Card := .pokemon
  { name := "Mega Kangaskhan ex", stage := .basic, evolvesFrom := none,
    hp := 30, type := .colorless, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [
      { name := "Run Errand", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.move .own (.top 2) .hand .any .all) }],
    attacks := [
      { name := "Rapid-Fire Combo", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 20) (.many (.const 5))),
        gx := false }] }

/-- Lopunny (me1-108). Records: me1-108. Caveats: benchMods. -/
def me1_108 : Card := .pokemon
  { name := "Lopunny", stage := .stage1, evolvesFrom := some "Buneary",
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dashing Kick", cost := [.colorless], damage := 0,
        effect := .benchDamage .opp 5,
        gx := false },
      { name := "Spiral Kick", cost := [.colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Yungoos (me1-109). Records: me1-109. -/
def me1_109 : Card := .pokemon
  { name := "Yungoos", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Gnaw", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Stufful (me1-111). Records: me1-111, me1-154. -/
def me1_111 : Card := .pokemon
  { name := "Stufful", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Light Punch", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Flop", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Boss's Orders (me1-114). Records: me1-114, me2pt5-183, me2pt5-256. Caveats: noopPlay. -/
def me1_114 : Card := .trainer "Boss's Orders" .supporter
    (.switch .opp)

/-- Fighting Gong (me1-116). Records: me1-116, me1-168, me2pt5-187. -/
def me1_116 : Card := .trainer "Fighting Gong" .item
    (.seq (.move .own .deck .hand (.or (.energyOf .fighting) (.and .basic (.ptype .fighting))) (.upTo 1)) .shuffle)

/-- Repel (me1-126). Records: me1-126. Caveats: noopPlay. -/
def me1_126 : Card := .trainer "Repel" .item
    (.switch .opp)

/-- Switch (me1-130). Records: me1-130, me2-123, me55-127. Caveats: noopPlay. -/
def me1_130 : Card := .trainer "Switch" .item
    (.switch .own)

/-- Ultra Ball (me1-131). Records: me1-131, me2pt5-213, me2pt5-264, me55-128. -/
def me1_131 : Card := .trainer "Ultra Ball" .item
    (.seq (.move .own .hand .discard .any (.exactly 2)) (.seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle))

/-- Oddish (me2-1). Records: me2-1. -/
def me2_1 : Card := .pokemon
  { name := "Oddish", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Seed Bomb", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Gloom (me2-2). Records: me2-2. Caveats: benchMods. -/
def me2_2 : Card := .pokemon
  { name := "Gloom", stage := .stage1, evolvesFrom := some "Oddish",
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Disperse Drool", cost := [.grass], damage := 2,
        effect := .seq (.spreadDamage .own 2) (.spreadDamage .opp 2),
        gx := false }] }

/-- Lotad (me2-5). Records: me2-5. -/
def me2_5 : Card := .pokemon
  { name := "Lotad", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.grass, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Lombre (me2-6). Records: me2-6. -/
def me2_6 : Card := .pokemon
  { name := "Lombre", stage := .stage1, evolvesFrom := some "Lotad",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mega Drain", cost := [.grass, .colorless], damage := 3,
        effect := .heal 3,
        gx := false }] }

/-- Nymble (me2-9). Records: me2-9, me2-96. -/
def me2_9 : Card := .pokemon
  { name := "Nymble", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flail Around", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.choice (.damage (.const 2)) (.damage (.const 3)))),
        gx := false }] }

/-- Charmeleon (me2-12). Records: me2-12. -/
def me2_12 : Card := .pokemon
  { name := "Charmeleon", stage := .stage1, evolvesFrom := some "Charmander",
    hp := 11, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Steady Firebreathing", cost := [.fire], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Darumaka (me2-15). Records: me2-15. -/
def me2_15 : Card := .pokemon
  { name := "Darumaka", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Blaze Ball", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 1) (.count (.energy .own (.energyOf .fire)) 2)),
        gx := false }] }

/-- Darmanitan (me2-16). Records: me2-16. -/
def me2_16 : Card := .pokemon
  { name := "Darmanitan", stage := .stage1, evolvesFrom := some "Darumaka",
    hp := 15, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Blaze Ball", cost := [.colorless, .colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 4) (.count (.energy .own (.energyOf .fire)) 4)),
        gx := false }] }

/-- Reshiram (me2-17). Records: me2-17. Caveats: recoil. -/
def me2_17 : Card := .pokemon
  { name := "Reshiram", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Combustion", cost := [.fire], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Burning Flare", cost := [.fire, .fire, .fire, .fire], damage := 24,
        effect := .selfDamage 6,
        gx := false }] }

/-- Charcadet (me2-19). Records: me2-19. -/
def me2_19 : Card := .pokemon
  { name := "Charcadet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gather Strength", cost := [.fire], damage := 0,
        effect := .seq (.move .own .deck .hand .energy (.upTo 2)) .shuffle,
        gx := false },
      { name := "Chop", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Seel (me2-21). Records: me2-21. -/
def me2_21 : Card := .pokemon
  { name := "Seel", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bubble Drain", cost := [.water, .colorless], damage := 2,
        effect := .heal 2,
        gx := false }] }

/-- Dewgong (me2-22). Records: me2-22, me2-97. Caveats: staticBench. -/
def me2_22 : Card := .pokemon
  { name := "Dewgong", stage := .stage1, evolvesFrom := some "Seel",
    hp := 13, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Thick Fat", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 3 (.or (.ptype .fire) (.ptype .water)) }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Slam", cost := [.water, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 7)) (.damage (.const 14))),
        gx := false }] }

/-- Swinub (me2-23). Records: me2-23. -/
def me2_23 : Card := .pokemon
  { name := "Swinub", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stampede", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Icy Snow", cost := [.water, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Piloswine (me2-24). Records: me2-24. -/
def me2_24 : Card := .pokemon
  { name := "Piloswine", stage := .stage1, evolvesFrom := some "Swinub",
    hp := 10, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rising Lunge", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 6)) (.damage (.const 3)),
        gx := false },
      { name := "Frost Smash", cost := [.water, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Suicune (me2-26). Records: me2-26. -/
def me2_26 : Card := .pokemon
  { name := "Suicune", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Crystal Fall", cost := [.water, .water], damage := 0,
        effect := .ite (.countGe (.energyAll .own (.energyOf .water)) 4) (.damage (.const 12)) (.damage (.const 3)),
        gx := false }] }

/-- Piplup (me2-27). Records: me2-27, me2-98. -/
def me2_27 : Card := .pokemon
  { name := "Piplup", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Support", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .supporter) (.upTo 1)) .shuffle,
        gx := false },
      { name := "Tackle", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Prinplup (me2-28). Records: me2-28. Caveats: benchMods. -/
def me2_28 : Card := .pokemon
  { name := "Prinplup", stage := .stage1, evolvesFrom := some "Piplup",
    hp := 10, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Peck", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Targeted Dive", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .benchDamage .opp 7,
        gx := false }] }

/-- Yamper (me2-30). Records: me2-30, me2-99. -/
def me2_30 : Card := .pokemon
  { name := "Yamper", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Play Rough", cost := [.lightning, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Boltund (me2-31). Records: me2-31. -/
def me2_31 : Card := .pokemon
  { name := "Boltund", stage := .stage1, evolvesFrom := some "Yamper",
    hp := 13, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electric Run", cost := [.lightning, .colorless], damage := 0,
        effect := .choice (.damage (.const 14)) (.damage (.const 7)),
        gx := false }] }

/-- Pawmo (me2-33). Records: me2-33. -/
def me2_33 : Card := .pokemon
  { name := "Pawmo", stage := .stage1, evolvesFrom := some "Pawmi",
    hp := 9, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electric Punch", cost := [.lightning, .lightning], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Misdreavus (me2-35). Records: me2-35. -/
def me2_35 : Card := .pokemon
  { name := "Misdreavus", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Petty Grudge", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Snubbull (me2-37). Records: me2-37. -/
def me2_37 : Card := .pokemon
  { name := "Snubbull", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.psychic, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Granbull (me2-38). Records: me2-38. -/
def me2_38 : Card := .pokemon
  { name := "Granbull", stage := .stage1, evolvesFrom := some "Snubbull",
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.psychic, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Finishing Blow", cost := [.psychic, .psychic, .colorless], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 18)) (.damage (.const 9)),
        gx := false }] }

/-- Cresselia (me2-39). Records: me2-39. -/
def me2_39 : Card := .pokemon
  { name := "Cresselia", stage := .basic, evolvesFrom := none,
    hp := 12, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Swelling Light", cost := [.psychic], damage := 0,
        effect := .seq (.seq (.attach .own .deck (.energyOf .psychic) .active .any) (.attach .own .deck (.energyOf .psychic) .active .any)) .shuffle,
        gx := false },
      { name := "Aurora Beam", cost := [.psychic, .psychic, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Mimikyu (me2-42). Records: me2-42. -/
def me2_42 : Card := .pokemon
  { name := "Mimikyu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.putBench .own .deck .basic) .shuffle,
        gx := false },
      { name := "Scratch", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Milcery (me2-43). Records: me2-43. -/
def me2_43 : Card := .pokemon
  { name := "Milcery", stage := .basic, evolvesFrom := none,
    hp := 5, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Draining Kiss", cost := [.psychic], damage := 1,
        effect := .heal 1,
        gx := false }] }

/-- Alcremie (me2-44). Records: me2-44. -/
def me2_44 : Card := .pokemon
  { name := "Alcremie", stage := .stage1, evolvesFrom := some "Milcery",
    hp := 9, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sweet Circle", cost := [.psychic], damage := 0,
        effect := .damage (.add (.const 2) (.count (.bench .own .pokemon) 2)),
        gx := false }] }

/-- Zacian (me2-45). Records: me2-45, me2-100. -/
def me2_45 : Card := .pokemon
  { name := "Zacian", stage := .basic, evolvesFrom := none,
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Limit Break", cost := [.psychic, .colorless], damage := 0,
        effect := .ite (.countGe (.prizes .opp) 4) (.damage (.const 5)) (.damage (.const 14)),
        gx := false }] }

/-- Bramblin (me2-46). Records: me2-46. -/
def me2_46 : Card := .pokemon
  { name := "Bramblin", stage := .basic, evolvesFrom := none,
    hp := 5, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sneaky Placement", cost := [.psychic], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 1) (.benchCounters .opp 1)) (.counters 1),
        gx := false }] }

/-- Brambleghast (me2-47). Records: me2-47. -/
def me2_47 : Card := .pokemon
  { name := "Brambleghast", stage := .stage1, evolvesFrom := some "Bramblin",
    hp := 10, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Prison Panic", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.inflict .confused) }],
    attacks := [
      { name := "Psychic Sphere", cost := [.psychic, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Gligar (me2-49). Records: me2-49. -/
def me2_49 : Card := .pokemon
  { name := "Gligar", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Jab", cost := [.fighting], damage := 1,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Gliscor (me2-50). Records: me2-50. Caveats: perPokemon. -/
def me2_50 : Card := .pokemon
  { name := "Gliscor", stage := .stage1, evolvesFrom := some "Gligar",
    hp := 12, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Ring", cost := [.fighting], damage := 5,
        effect := .seq (.inflict .poisoned) (.linger .opp .next (.lock .retreat)),
        gx := false }] }

/-- Trapinch (me2-51). Records: me2-51. -/
def me2_51 : Card := .pokemon
  { name := "Trapinch", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Headbutt", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- Vibrava (me2-52). Records: me2-52. -/
def me2_52 : Card := .pokemon
  { name := "Vibrava", stage := .stage1, evolvesFrom := some "Trapinch",
    hp := 9, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Super Vibration", cost := [.fighting, .fighting], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Gastly (me2-54). Records: me2-54, me2pt5-123. -/
def me2_54 : Card := .pokemon
  { name := "Gastly", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Petty Grudge", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Haunter (me2-55). Records: me2-55, me2pt5-124. -/
def me2_55 : Card := .pokemon
  { name := "Haunter", stage := .stage1, evolvesFrom := some "Gastly",
    hp := 10, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spooky Shot", cost := [.darkness], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Murkrow (me2-57). Records: me2-57. -/
def me2_57 : Card := .pokemon
  { name := "Murkrow", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ambush", cost := [.darkness], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Carvanha (me2-60). Records: me2-60. Caveats: recoil. -/
def me2_60 : Card := .pokemon
  { name := "Carvanha", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.darkness], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Mega Sharpedo ex (me2-61). Records: me2-61, me2-113, me2-127. -/
def me2_61 : Card := .pokemon
  { name := "Mega Sharpedo ex", stage := .stage1, evolvesFrom := some "Carvanha",
    hp := 33, type := .darkness, retreat := 0, weakness := some .grass,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Greedy Fang", cost := [.darkness], damage := 7,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Hungry Jaws", cost := [.darkness, .darkness], damage := 0,
        effect := .ite (.atLeast .own 1) (.damage (.const 27)) (.damage (.const 12)),
        gx := false }] }

/-- Absol (me2-63). Records: me2-63. -/
def me2_63 : Card := .pokemon
  { name := "Absol", stage := .basic, evolvesFrom := none,
    hp := 11, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Allure", cost := [.colorless], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Dark Cutter", cost := [.darkness, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Sandile (me2-64). Records: me2-64. -/
def me2_64 : Card := .pokemon
  { name := "Sandile", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Rear Kick", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Krokorok (me2-65). Records: me2-65. -/
def me2_65 : Card := .pokemon
  { name := "Krokorok", stage := .stage1, evolvesFrom := some "Sandile",
    hp := 10, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.darkness], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Confront", cost := [.darkness, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Toxel (me2-67). Records: me2-67. -/
def me2_67 : Card := .pokemon
  { name := "Toxel", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.darkness], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Playful Kick", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Eternatus (me2-69). Records: me2-69. Caveats: perPokemon. -/
def me2_69 : Card := .pokemon
  { name := "Eternatus", stage := .basic, evolvesFrom := none,
    hp := 15, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shatter", cost := [.darkness, .darkness], damage := 5,
        effect := .discardStadium,
        gx := false },
      { name := "Power Rush", cost := [.darkness, .darkness, .darkness], damage := 13,
        effect := .choice .skip (.linger .own .after (.lock .attack)),
        gx := false }] }

/-- Bronzor (me2-71). Records: me2-71. Caveats: perPokemon. -/
def me2_71 : Card := .pokemon
  { name := "Bronzor", stage := .basic, evolvesFrom := none,
    hp := 8, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Iron Defense", cost := [.colorless], damage := 0,
        effect := .choice (.linger .own .next .prevent) .skip,
        gx := false },
      { name := "Rollout", cost := [.colorless, .colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Togedemaru (me2-73). Records: me2-73, me2-104. -/
def me2_73 : Card := .pokemon
  { name := "Togedemaru", stage := .basic, evolvesFrom := none,
    hp := 8, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Find a Friend", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle,
        gx := false },
      { name := "Gnaw", cost := [.metal], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Duraludon (me2-74). Records: me2-74. -/
def me2_74 : Card := .pokemon
  { name := "Duraludon", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hyper Beam", cost := [.metal, .metal, .metal], damage := 7,
        effect := .ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Jigglypuff (me2-76). Records: me2-76. -/
def me2_76 : Card := .pokemon
  { name := "Jigglypuff", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ball Roll", cost := [.colorless], damage := 0,
        effect := .damage (.many (.const 2)),
        gx := false }] }

/-- Zigzagoon (me2-81). Records: me2-81. -/
def me2_81 : Card := .pokemon
  { name := "Zigzagoon", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Surprise Attack", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Buneary (me2-83). Records: me2-83. -/
def me2_83 : Card := .pokemon
  { name := "Buneary", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Run Around", cost := [.colorless], damage := 0,
        effect := .switch .own,
        gx := false },
      { name := "Kick", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Firebreather (me2-89). Records: me2-89, me2-119. Caveats: upTo0. -/
def me2_89 : Card := .trainer "Firebreather" .supporter
    (.seq (.move .own .deck .hand (.energyOf .fire) (.upTo 7)) .shuffle)

/-- Erika's Oddish (me2pt5-1). Records: me2pt5-1. Caveats: recoil. -/
def me2pt5_1 : Card := .pokemon
  { name := "Erika's Oddish", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.grass], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Erika's Gloom (me2pt5-2). Records: me2pt5-2. -/
def me2pt5_2 : Card := .pokemon
  { name := "Erika's Gloom", stage := .stage1, evolvesFrom := some "Erika's Oddish",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Spray", cost := [.grass, .colorless], damage := 5,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Erika's Bellsprout (me2pt5-4). Records: me2pt5-4. -/
def me2pt5_4 : Card := .pokemon
  { name := "Erika's Bellsprout", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Vine Slap", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Erika's Weepinbell (me2pt5-5). Records: me2pt5-5. Caveats: perPokemon. -/
def me2pt5_5 : Card := .pokemon
  { name := "Erika's Weepinbell", stage := .stage1, evolvesFrom := some "Erika's Bellsprout",
    hp := 9, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Melt", cost := [.grass], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Leafy Cyclone", cost := [.grass, .colorless], damage := 7,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Bayleef (me2pt5-9). Records: me2pt5-9. -/
def me2pt5_9 : Card := .pokemon
  { name := "Bayleef", stage := .stage1, evolvesFrom := some "Chikorita",
    hp := 10, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leaf Step", cost := [.grass, .grass], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Mega Meganium ex (me2pt5-10). Records: me2pt5-10, me2pt5-272. -/
def me2pt5_10 : Card := .pokemon
  { name := "Mega Meganium ex", stage := .stage2, evolvesFrom := some "Bayleef",
    hp := 36, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Giant Bouquet", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 7) (.count (.energy .own (.energyOf .grass)) 5)),
        gx := false }] }

/-- Wurmple (me2pt5-11). Records: me2pt5-11. -/
def me2pt5_11 : Card := .pokemon
  { name := "Wurmple", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bug Bite", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Cascoon (me2pt5-14). Records: me2pt5-14. -/
def me2pt5_14 : Card := .pokemon
  { name := "Cascoon", stage := .stage1, evolvesFrom := some "Wurmple",
    hp := 9, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Trading Places", cost := [.grass], damage := 0,
        effect := .switch .own,
        gx := false }] }

/-- Charmander (me2pt5-20). Records: me2pt5-20. -/
def me2pt5_20 : Card := .pokemon
  { name := "Charmander", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fire Claws", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Charmeleon (me2pt5-21). Records: me2pt5-21. -/
def me2pt5_21 : Card := .pokemon
  { name := "Charmeleon", stage := .stage1, evolvesFrom := some "Charmander",
    hp := 10, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Heat Blast", cost := [.fire, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Entei (me2pt5-25). Records: me2pt5-25. -/
def me2pt5_25 : Card := .pokemon
  { name := "Entei", stage := .basic, evolvesFrom := none,
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flare Fall", cost := [.fire, .fire], damage := 0,
        effect := .ite (.countGe (.energyAll .own (.energyOf .fire)) 4) (.damage (.const 12)) (.damage (.const 3)),
        gx := false }] }

/-- Camerupt (me2pt5-28). Records: me2pt5-28. -/
def me2pt5_28 : Card := .pokemon
  { name := "Camerupt", stage := .stage1, evolvesFrom := some "Numel",
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Roasting Burn", cost := [.fire], damage := 0,
        effect := .ite (.cond .opp .burned) (.damage (.const 11)) .skip,
        gx := false },
      { name := "Power Stomp", cost := [.fire, .colorless, .colorless, .colorless], damage := 17,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Tepig (me2pt5-29). Records: me2pt5-29. -/
def me2pt5_29 : Card := .pokemon
  { name := "Tepig", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Steady Firebreathing", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Pignite (me2pt5-30). Records: me2pt5-30. -/
def me2pt5_30 : Card := .pokemon
  { name := "Pignite", stage := .stage1, evolvesFrom := some "Tepig",
    hp := 11, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Super Singe", cost := [.fire, .fire, .colorless], damage := 7,
        effect := .inflict .burned,
        gx := false }] }

/-- Mega Emboar ex (me2pt5-31). Records: me2pt5-31, me2pt5-273. Caveats: recoil. -/
def me2pt5_31 : Card := .pokemon
  { name := "Mega Emboar ex", stage := .stage2, evolvesFrom := some "Pignite",
    hp := 38, type := .fire, retreat := 4, weakness := some .water,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Crimson Blast", cost := [.fire, .fire, .colorless], damage := 32,
        effect := .selfDamage 6,
        gx := false }] }

/-- Totodile (me2pt5-41). Records: me2pt5-41. Caveats: recoil. -/
def me2pt5_41 : Card := .pokemon
  { name := "Totodile", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slight Intrusion", cost := [.water, .water], damage := 4,
        effect := .selfDamage 1,
        gx := false }] }

/-- Croconaw (me2pt5-42). Records: me2pt5-42. -/
def me2pt5_42 : Card := .pokemon
  { name := "Croconaw", stage := .stage1, evolvesFrom := some "Totodile",
    hp := 10, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Crunch", cost := [.water, .water], damage := 5,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Mega Feraligatr ex (me2pt5-43). Records: me2pt5-43, me2pt5-274. -/
def me2pt5_43 : Card := .pokemon
  { name := "Mega Feraligatr ex", stage := .stage2, evolvesFrom := some "Croconaw",
    hp := 37, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Mortal Crunch", cost := [.water, .water, .colorless], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 40)) (.damage (.const 20)),
        gx := false }] }

/-- Snorunt (me2pt5-46). Records: me2pt5-46, me2pt5-227. -/
def me2pt5_46 : Card := .pokemon
  { name := "Snorunt", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Chilly", cost := [.water], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Mega Froslass ex (me2pt5-47). Records: me2pt5-47, me2pt5-265, me2pt5-275. -/
def me2pt5_47 : Card := .pokemon
  { name := "Mega Froslass ex", stage := .stage1, evolvesFrom := some "Snorunt",
    hp := 31, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Resentful Refrain", cost := [.water], damage := 0,
        effect := .damage (.count (.pile .opp .hand .any) 5),
        gx := false },
      { name := "Absolute Snow", cost := [.water, .colorless, .colorless], damage := 15,
        effect := .inflict .asleep,
        gx := false }] }

/-- N's Vanillite (me2pt5-49). Records: me2pt5-49. -/
def me2pt5_49 : Card := .pokemon
  { name := "N's Vanillite", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Icy Snow", cost := [.water, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- N's Vanillish (me2pt5-50). Records: me2pt5-50. Caveats: perPokemon. -/
def me2pt5_50 : Card := .pokemon
  { name := "N's Vanillish", stage := .stage1, evolvesFrom := some "N's Vanillite",
    hp := 10, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flop", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Sheer Cold", cost := [.water, .colorless, .colorless], damage := 6,
        effect := .linger .opp .next (.lock .attack),
        gx := false }] }

/-- Snom (me2pt5-52). Records: me2pt5-52. -/
def me2pt5_52 : Card := .pokemon
  { name := "Snom", stage := .basic, evolvesFrom := none,
    hp := 5, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Icicle", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

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

/-- Raichu (me2pt5-56). Records: me2pt5-56. -/
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

/-- Azumarill ex (me2pt5-84). Records: me2pt5-84. Caveats: moveAnyPair, noopUse. -/
def me2pt5_84 : Card := .pokemon
  { name := "Azumarill ex", stage := .stage1, evolvesFrom := some "Marill",
    hp := 27, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Bubble Gathering", use := .unlimited,
        spot := none, cond := none,
        effect := .self (.energyTo .energy) }],
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

/-- Hoopa (me2pt5-141). Records: me2pt5-141. Caveats: perPokemon. -/
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
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

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

/-- Mega Dragonite ex (me2pt5-152). Records: me2pt5-152, me2pt5-271, me2pt5-290, me2pt5-295. Caveats: noopUse. -/
def me2pt5_152 : Card := .pokemon
  { name := "Mega Dragonite ex", stage := .stage2, evolvesFrom := some "Dragonair",
    hp := 37, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [
      { name := "Sky Transport", use := .once,
        spot := none, cond := none,
        effect := .fx (.switch .own) }],
    attacks := [
      { name := "Ryuno Glide", cost := [.water, .lightning, .lightning], damage := 33,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

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

/-- Delcatty (me2pt5-166). Records: me2pt5-166. -/
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
        effect := .seq (.move .own .deck .hand .energy (.upTo 2)) .shuffle,
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

/-- Mega Audino ex (me2pt5-172). Records: me2pt5-172, me2pt5-253. -/
def me2pt5_172 : Card := .pokemon
  { name := "Mega Audino ex", stage := .basic, evolvesFrom := none,
    hp := 27, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Kaleidowaltz", cost := [.colorless], damage := 0,
        effect := .choice .skip (.choice (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) .shuffle) (.choice (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) .shuffle)) (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) .shuffle))))),
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

/-- Canari (me2pt5-185). Records: me2pt5-185, me2pt5-257, me2pt5-291. Caveats: upTo0. -/
def me2pt5_185 : Card := .trainer "Canari" .supporter
    (.seq (.move .own .hand .discard .any (.exactly 1)) (.seq (.move .own .deck .hand (.ptype .lightning) (.upTo 4)) .shuffle))

/-- Light Ball (me2pt5-191). Records: me2pt5-191. -/
def me2pt5_191 : Card := .tool "Light Ball"
  { holder := .named "Pikachu ex",
    attacks := [],
    abilities := [],
    statics := [
      { sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .bonus 5 (.and .pokemon (.not .noRuleBox)) }] }

/-- Thick Scale (me2pt5-211). Records: me2pt5-211. Caveats: staticBench. -/
def me2pt5_211 : Card := .tool "Thick Scale"
  { holder := .ptype .dragon,
    attacks := [],
    abilities := [],
    statics := [
      { sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 5 (.or (.ptype .grass) (.or (.ptype .fire) (.or (.ptype .water) (.ptype .lightning)))) }] }

/-- Urbain (me2pt5-214). Records: me2pt5-214. -/
def me2pt5_214 : Card := .trainer "Urbain" .supporter
    (.move .own (.top 3) .hand .any .all)

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
        effect := .seq (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 9)) (.benchDamage .opp 9)) (.damage (.const 9))) (.discardEnergy .own .active .energy .all),
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

/-- Talonflame (me3-14). Records: me3-14, me3-91. Caveats: noopUse. -/
def me3_14 : Card := .pokemon
  { name := "Talonflame", stage := .stage2, evolvesFrom := some "Fletchinder",
    hp := 15, type := .fire, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Sky Hunt", use := .once,
        spot := none, cond := none,
        effect := .fx (.choice (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip) .skip) }],
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

/-- Dewgong (me3-19). Records: me3-19. Caveats: moveAnyPair, noopUse. -/
def me3_19 : Card := .pokemon
  { name := "Dewgong", stage := .stage1, evolvesFrom := some "Seel",
    hp := 13, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Wash Out", use := .unlimited,
        spot := none, cond := none,
        effect := .fx (.moveEnergy .own (.energyOf .water)) }],
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

/-- Lapras ex (me3-22). Records: me3-22. -/
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

/-- Meowstic (me3-34). Records: me3-34. -/
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
        effect := .fx (.seq (.move .own .deck .hand (.energyOf .psychic) (.upTo 2)) .shuffle) }],
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

/-- The cards of this part. -/
def cards : List Card := [
  me1_103,
  me1_104,
  me1_108,
  me1_109,
  me1_111,
  me1_114,
  me1_116,
  me1_126,
  me1_130,
  me1_131,
  me2_1,
  me2_2,
  me2_5,
  me2_6,
  me2_9,
  me2_12,
  me2_15,
  me2_16,
  me2_17,
  me2_19,
  me2_21,
  me2_22,
  me2_23,
  me2_24,
  me2_26,
  me2_27,
  me2_28,
  me2_30,
  me2_31,
  me2_33,
  me2_35,
  me2_37,
  me2_38,
  me2_39,
  me2_42,
  me2_43,
  me2_44,
  me2_45,
  me2_46,
  me2_47,
  me2_49,
  me2_50,
  me2_51,
  me2_52,
  me2_54,
  me2_55,
  me2_57,
  me2_60,
  me2_61,
  me2_63,
  me2_64,
  me2_65,
  me2_67,
  me2_69,
  me2_71,
  me2_73,
  me2_74,
  me2_76,
  me2_81,
  me2_83,
  me2_89,
  me2pt5_1,
  me2pt5_2,
  me2pt5_4,
  me2pt5_5,
  me2pt5_9,
  me2pt5_10,
  me2pt5_11,
  me2pt5_14,
  me2pt5_20,
  me2pt5_21,
  me2pt5_25,
  me2pt5_28,
  me2pt5_29,
  me2pt5_30,
  me2pt5_31,
  me2pt5_41,
  me2pt5_42,
  me2pt5_43,
  me2pt5_46,
  me2pt5_47,
  me2pt5_49,
  me2pt5_50,
  me2pt5_52,
  me2pt5_55,
  me2pt5_56,
  me2pt5_58,
  me2pt5_63,
  me2pt5_77,
  me2pt5_84,
  me2pt5_86,
  me2pt5_93,
  me2pt5_94,
  me2pt5_102,
  me2pt5_103,
  me2pt5_108,
  me2pt5_114,
  me2pt5_115,
  me2pt5_118,
  me2pt5_119,
  me2pt5_130,
  me2pt5_131,
  me2pt5_132,
  me2pt5_134,
  me2pt5_138,
  me2pt5_139,
  me2pt5_141,
  me2pt5_144,
  me2pt5_145,
  me2pt5_146,
  me2pt5_147,
  me2pt5_150,
  me2pt5_152,
  me2pt5_156,
  me2pt5_163,
  me2pt5_165,
  me2pt5_166,
  me2pt5_167,
  me2pt5_168,
  me2pt5_169,
  me2pt5_172,
  me2pt5_173,
  me2pt5_174,
  me2pt5_185,
  me2pt5_191,
  me2pt5_211,
  me2pt5_214,
  me3_1,
  me3_2,
  me3_4,
  me3_5,
  me3_7,
  me3_10,
  me3_11,
  me3_13,
  me3_14,
  me3_15,
  me3_16,
  me3_18,
  me3_19,
  me3_20,
  me3_22,
  me3_23,
  me3_26,
  me3_30,
  me3_33,
  me3_34,
  me3_35,
  me3_36,
  me3_37]

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
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Light Ball"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.reduces)).map Card.label = ["Dewgong", "Thick Scale"] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = [] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 10 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 10)) = true := by decide +kernel

end PokemonCards.Standard.Part06
