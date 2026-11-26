/-
Imported Standard cards, part 8 of 11 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.20.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part08
open Pokemon

/-- Makuhita (me1-72). Records: me1-72. -/
def me1_72 : Card := .pokemon
  { name := "Makuhita", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Corkscrew Punch", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Confront", cost := [.fighting, .fighting], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Hariyama (me1-73). Records: me1-73. Caveats: recoil. -/
def me1_73 : Card := .pokemon
  { name := "Hariyama", stage := .stage1, evolvesFrom := some "Makuhita",
    hp := 15, type := .fighting, retreat := 3, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Heave-Ho Catcher", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.switch .opp) }],
    attacks := [
      { name := "Wild Press", cost := [.fighting, .fighting, .fighting], damage := 21,
        effect := .selfDamage 7,
        gx := false }] }

/-- Lunatone (me1-74). Records: me1-74, me2pt5-105. Caveats: onePerName. -/
def me1_74 : Card := .pokemon
  { name := "Lunatone", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Lunar Cycle", use := .once,
        spot := none, cond := some (.countGe (.inPlay .own (.named "Solrock")) 1),
        effect := .fx (.seq (.move .own .hand .discard (.energyOf .fighting) (.exactly 1)) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 3) .hand .any .all))) }],
    attacks := [
      { name := "Power Gem", cost := [.fighting, .fighting], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Solrock (me1-75). Records: me1-75, me2pt5-106. -/
def me1_75 : Card := .pokemon
  { name := "Solrock", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cosmic Beam", cost := [.fighting], damage := 0,
        effect := .ite (.countGe (.bench .own (.named "Lunatone")) 1) (.damage (.const 7) { weak := true, resist := true }) .skip,
        gx := false }] }

/-- Riolu (me1-76). Records: me1-76, me2pt5-112. -/
def me1_76 : Card := .pokemon
  { name := "Riolu", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Accelerating Stab", cost := [.fighting], damage := 3,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Mega Lucario ex (me1-77). Records: me1-77, me1-160, me1-179, me1-188. -/
def me1_77 : Card := .pokemon
  { name := "Mega Lucario ex", stage := .stage1, evolvesFrom := some "Riolu",
    hp := 34, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Aura Jab", cost := [.fighting], damage := 13,
        effect := .seq (.attach .own .discard (.energyOf .fighting) .bench .any) (.seq (.attach .own .discard (.energyOf .fighting) .bench .any) (.attach .own .discard (.energyOf .fighting) .bench .any)),
        gx := false },
      { name := "Mega Brave", cost := [.fighting, .fighting], damage := 27,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Croagunk (me1-78). Records: me1-78. -/
def me1_78 : Card := .pokemon
  { name := "Croagunk", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smack", cost := [.fighting], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Toxicroak (me1-79). Records: me1-79. Caveats: recoil. -/
def me1_79 : Card := .pokemon
  { name := "Toxicroak", stage := .stage1, evolvesFrom := some "Croagunk",
    hp := 13, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.fighting], damage := 7,
        effect := .selfDamage 2,
        gx := false }] }

/-- Stonjourner (me1-81). Records: me1-81. Caveats: benchMods. -/
def me1_81 : Card := .pokemon
  { name := "Stonjourner", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stony Kick", cost := [.fighting], damage := 2,
        effect := .benchDamage .opp 2,
        gx := false },
      { name := "Boundless Power", cost := [.fighting, .fighting, .colorless], damage := 14,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Nacli (me1-82). Records: me1-82. -/
def me1_82 : Card := .pokemon
  { name := "Nacli", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Naclstack (me1-83). Records: me1-83. -/
def me1_83 : Card := .pokemon
  { name := "Naclstack", stage := .stage1, evolvesFrom := some "Nacli",
    hp := 11, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rock Hurl", cost := [.fighting, .colorless], damage := 0,
        effect := .damage (.const 5) { resist := true },
        gx := false }] }

/-- Garganacl (me1-84). Records: me1-84, me1-147. -/
def me1_84 : Card := .pokemon
  { name := "Garganacl", stage := .stage2, evolvesFrom := some "Naclstack",
    hp := 18, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Powerful a-Salt", use := .static [{ sel := .own, filt := .ptype .fighting, tgt := none, src := none, need := none, eff := .bonus 3 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Hammer In", cost := [.fighting, .fighting, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Mega Absol ex (me1-86). Records: me1-86, me1-161, me1-180. Caveats: koCounters. -/
def me1_86 : Card := .pokemon
  { name := "Mega Absol ex", stage := .basic, evolvesFrom := none,
    hp := 28, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Terminal Period", cost := [.darkness, .colorless], damage := 0,
        effect := .ite (.exactly .opp 6) (.counters 9999) .skip,
        gx := false },
      { name := "Claw of Darkness", cost := [.darkness, .darkness, .colorless], damage := 20,
        effect := .move .opp .hand .discard .any (.most 1),
        gx := false }] }

/-- Yveltal (me1-88). Records: me1-88. Caveats: perPokemon. -/
def me1_88 : Card := .pokemon
  { name := "Yveltal", stage := .basic, evolvesFrom := none,
    hp := 11, type := .darkness, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Clutch", cost := [.darkness], damage := 2,
        effect := .linger .opp .next (.lock .retreat),
        gx := false },
      { name := "Dark Feather", cost := [.darkness, .darkness, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Nickit (me1-89). Records: me1-89. -/
def me1_89 : Card := .pokemon
  { name := "Nickit", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Darkness Fang", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Thievul (me1-90). Records: me1-90. -/
def me1_90 : Card := .pokemon
  { name := "Thievul", stage := .stage1, evolvesFrom := some "Nickit",
    hp := 12, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Greedy Hunt", cost := [.colorless], damage := 2,
        effect := .choice (.drawTo .own 6) .skip,
        gx := false },
      { name := "Pitch-Black Fangs", cost := [.darkness, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Shroodle (me1-91). Records: me1-91, me1-149. -/
def me1_91 : Card := .pokemon
  { name := "Shroodle", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Jab", cost := [.darkness, .colorless], damage := 2,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Steelix (me1-93). Records: me1-93, me1-150. -/
def me1_93 : Card := .pokemon
  { name := "Steelix", stage := .stage1, evolvesFrom := some "Onix",
    hp := 20, type := .metal, retreat := 4, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Welcoming Tail", cost := [.colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.prizes .own) 6) (.ite (.countGe (.prizes .own) 7) (.damage (.const 4)) (.damage (.const 24))) (.damage (.const 4)),
        gx := false },
      { name := "Skull Bash", cost := [.metal, .metal, .colorless, .colorless], damage := 14,
        effect := .skip,
        gx := false }] }

/-- Dialga (me1-95). Records: me1-95. -/
def me1_95 : Card := .pokemon
  { name := "Dialga", stage := .basic, evolvesFrom := none,
    hp := 14, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Beam", cost := [.metal], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Chrono Burst", cost := [.metal, .metal, .colorless], damage := 0,
        effect := .choice (.damage (.const 8)) (.seq (.returnEnergy .own .active .energy .all .shuffle) (.damage (.const 16))),
        gx := false }] }

/-- Tinkatink (me1-96). Records: me1-96. -/
def me1_96 : Card := .pokemon
  { name := "Tinkatink", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Beat", cost := [.metal], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Tinkatuff (me1-97). Records: me1-97. -/
def me1_97 : Card := .pokemon
  { name := "Tinkatuff", stage := .stage1, evolvesFrom := some "Tinkatink",
    hp := 9, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Haphazard Hammer", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip) }],
    attacks := [
      { name := "Light Punch", cost := [.metal], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Tinkaton (me1-98). Records: me1-98. Caveats: energyUnitsCount. -/
def me1_98 : Card := .pokemon
  { name := "Tinkaton", stage := .stage2, evolvesFrom := some "Tinkatuff",
    hp := 16, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Windup Swing", cost := [.metal], damage := 0,
        effect := .damage (.sub (.const 24) (.count (.energy .opp .energy) 6)),
        gx := false }] }

/-- Mega Latias ex (me1-100). Records: me1-100, me1-163, me1-181. -/
def me1_100 : Card := .pokemon
  { name := "Mega Latias ex", stage := .basic, evolvesFrom := none,
    hp := 28, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Strafe", cost := [.colorless], damage := 4,
        effect := .choice (.switch .own) .skip,
        gx := false },
      { name := "Illusory Impulse", cost := [.fire, .psychic, .colorless], damage := 30,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Spearow (me1-102). Records: me1-102, me1-151. -/
def me1_102 : Card := .pokemon
  { name := "Spearow", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pluck", cost := [.colorless], damage := 0,
        effect := .seq (.discardTools .opp .active) (.damage (.const 1)),
        gx := false }] }

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
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 2) .hand .any .all)) }],
    attacks := [
      { name := "Rapid-Fire Combo", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 20) (.many (.const 5))),
        gx := false }] }

/-- Miltank (me1-106). Records: me1-106. -/
def me1_106 : Card := .pokemon
  { name := "Miltank", stage := .basic, evolvesFrom := none,
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bellyful of Milk", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.ite (.countGe (.bench .own .pokemon) 1) (.choice .healAll (.benchHealSome 1 .any none)) .healAll) .skip,
        gx := false },
      { name := "Tackle", cost := [.colorless, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Buneary (me1-107). Records: me1-107. Caveats: benchMods, perPokemon. -/
def me1_107 : Card := .pokemon
  { name := "Buneary", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Charm", cost := [.colorless], damage := 0,
        effect := .linger .opp .next (.weaken 2),
        gx := false },
      { name := "Skip", cost := [.colorless], damage := 1,
        effect := .skip,
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

/-- Bewear (me1-112). Records: me1-112. -/
def me1_112 : Card := .pokemon
  { name := "Bewear", stage := .stage1, evolvesFrom := some "Stufful",
    hp := 13, type := .colorless, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knuckle Punch", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Hyper Lariat", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 20)) (.damage (.const 10)),
        gx := false }] }

/-- Boss's Orders (me1-114). Records: me1-114, me2pt5-183, me2pt5-256. -/
def me1_114 : Card := .trainer "Boss's Orders" .supporter
    (.seq (.ite (.countGe (.bench .opp .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.switch .opp))

/-- Energy Switch (me1-115). Records: me1-115, me5-107. Caveats: moveMayFail. -/
def me1_115 : Card := .trainer "Energy Switch" .item
    (.seq (.ite (.countGe (.energyAll .own .basicEnergy) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.moveEnergy .own .basicEnergy)))

/-- Fighting Gong (me1-116). Records: me1-116, me1-168, me2pt5-187. -/
def me1_116 : Card := .trainer "Fighting Gong" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.or (.energyOf .fighting) (.and .basic (.ptype .fighting))) (.upTo 1)) .shuffle))

/-- Lillie's Determination (me1-119). Records: me1-119, me1-169, me1-184, me2pt5-192. -/
def me1_119 : Card := .trainer "Lillie's Determination" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .own .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.move .own .hand .shuffle .any .all) (.ite (.countGe (.prizes .own) 6) (.ite (.countGe (.prizes .own) 7) (.move .own (.top 6) .hand .any .all) (.move .own (.top 8) .hand .any .all)) (.move .own (.top 6) .hand .any .all))))

/-- Mega Signal (me1-121). Records: me1-121, me1-171, me2pt5-193. -/
def me1_121 : Card := .trainer "Mega Signal" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.and .pokemon .megaEx) (.upTo 1)) .shuffle))

/-- Pokémon Center Lady (me1-123). Records: me1-123. Caveats: noopPlay. -/
def me1_123 : Card := .trainer "Pokémon Center Lady" .supporter
    (.seq (.ite (.atLeast .own 1) .skip (.ite (.countGe (.bench .own .pokemon) 1) .skip (.ite (.countGe (.conds .own) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))))) (.ite (.countGe (.bench .own .pokemon) 1) (.choice (.seq (.heal 6) .cure) (.benchHeal 6)) (.seq (.heal 6) .cure)))

/-- Repel (me1-126). Records: me1-126. -/
def me1_126 : Card := .trainer "Repel" .item
    (.seq (.ite (.countGe (.bench .opp .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.switch .opp))

/-- Switch (me1-130). Records: me1-130, me2-123, me55-127. -/
def me1_130 : Card := .trainer "Switch" .item
    (.seq (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.switch .own))

/-- Ultra Ball (me1-131). Records: me1-131, me2pt5-213, me2pt5-264, me55-128. -/
def me1_131 : Card := .trainer "Ultra Ball" .item
    (.seq (.move .own .hand .discard .any (.exactly 2)) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle)))

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

/-- Genesect (me2-8). Records: me2-8. Caveats: benchMods, energyOfCount. -/
def me2_8 : Card := .pokemon
  { name := "Genesect", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bug's Cannon", cost := [.grass], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.count (.energy .own (.energyOf .grass)) 2)) (.hitBy .opp .bench 1 .any false true (.count (.energy .own (.energyOf .grass)) 2))) (.damage (.count (.energy .own (.energyOf .grass)) 2)),
        gx := false },
      { name := "Speed Attack", cost := [.grass, .grass, .colorless], damage := 11,
        effect := .skip,
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

/-- Moltres (me2-14). Records: me2-14. -/
def me2_14 : Card := .pokemon
  { name := "Moltres", stage := .basic, evolvesFrom := none,
    hp := 12, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fighting Wings", cost := [.fire], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 11)) (.damage (.const 2)),
        gx := false }] }

/-- Darumaka (me2-15). Records: me2-15. Caveats: energyOfCount. -/
def me2_15 : Card := .pokemon
  { name := "Darumaka", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Blaze Ball", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 1) (.count (.energy .own (.energyOf .fire)) 2)),
        gx := false }] }

/-- Darmanitan (me2-16). Records: me2-16. Caveats: energyOfCount. -/
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
        effect := .seq (.move .own .deck .hand .basicEnergy (.upTo 2)) .shuffle,
        gx := false },
      { name := "Chop", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Ceruledge (me2-20). Records: me2-20. -/
def me2_20 : Card := .pokemon
  { name := "Ceruledge", stage := .stage1, evolvesFrom := some "Charcadet",
    hp := 14, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Infernal Slash", cost := [.fire], damage := 0,
        effect := .ite (.countGe (.pile .own .hand (.energyOf .fire)) 4) (.seq (.move .own .hand .discard (.energyOf .fire) (.exactly 4)) (.damage (.const 22))) .skip,
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

/-- Suicune (me2-26). Records: me2-26. Caveats: energyOfCount. -/
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

/-- Pawmi (me2-32). Records: me2-32. Caveats: benchMods, perPokemon. -/
def me2_32 : Card := .pokemon
  { name := "Pawmi", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Growl", cost := [.lightning], damage := 0,
        effect := .linger .opp .next (.weaken 3),
        gx := false },
      { name := "Tiny Charge", cost := [.lightning], damage := 1,
        effect := .skip,
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

/-- Pawmot (me2-34). Records: me2-34. Caveats: recoil. -/
def me2_34 : Card := .pokemon
  { name := "Pawmot", stage := .stage2, evolvesFrom := some "Pawmo",
    hp := 14, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Voltaic Fist", cost := [.lightning, .lightning], damage := 13,
        effect := .choice (.seq (.selfDamage 6) (.inflict .paralyzed)) .skip,
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

/-- Mismagius ex (me2-36). Records: me2-36, me2-112. Caveats: trigBenched. -/
def me2_36 : Card := .pokemon
  { name := "Mismagius ex", stage := .stage1, evolvesFrom := some "Misdreavus",
    hp := 26, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    abilities := [
      { name := "Swirling Prose", use := .triggered .oppBenched false,
        spot := some .active, cond := none,
        effect := .fx (.inflict .confused) }],
    attacks := [
      { name := "Hexa-Magic", cost := [.psychic, .psychic], damage := 15,
        effect := .choice (.drawTo .own 6) .skip,
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

/-- Meloetta (me2-40). Records: me2-40. -/
def me2_40 : Card := .pokemon
  { name := "Meloetta", stage := .basic, evolvesFrom := none,
    hp := 9, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Soothing Melody", cost := [.psychic], damage := 0,
        effect := .benchHealSome 1 (.ptype .psychic) (some 12),
        gx := false },
      { name := "Magical Shot", cost := [.psychic, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Mega Diancie ex (me2-41). Records: me2-41. Caveats: staticBench. -/
def me2_41 : Card := .pokemon
  { name := "Mega Diancie ex", stage := .basic, evolvesFrom := none,
    hp := 27, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [
      { name := "Diamond Coat", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 3 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Garland Ray", cost := [.psychic, .psychic], damage := 0,
        effect := .choice (.choice (.seq (.discardEnergy .own .active .energy (.exactly 0)) (.damage (.const 0))) (.seq (.discardEnergy .own .active .energy (.exactly 1)) (.damage (.const 12)))) (.seq (.discardEnergy .own .active .energy (.exactly 2)) (.damage (.const 24))),
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

/-- Flygon (me2-53). Records: me2-53, me2-101. Caveats: trigKO. -/
def me2_53 : Card := .pokemon
  { name := "Flygon", stage := .stage2, evolvesFrom := some "Vibrava",
    hp := 15, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Sandy Flapping", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.move .opp (.top 2) .discard .any .all) },
      { name := "Sandy Flapping", use := .triggered .koByAttack true,
        spot := some .active, cond := none,
        effect := .fx (.move .opp (.top 2) .discard .any .all) }],
    attacks := [
      { name := "Cutting Wind", cost := [.fighting, .fighting], damage := 13,
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

/-- Honchkrow (me2-58). Records: me2-58. Caveats: benchMods. -/
def me2_58 : Card := .pokemon
  { name := "Honchkrow", stage := .stage1, evolvesFrom := some "Murkrow",
    hp := 13, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wind of Darkness", cost := [.darkness], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Sniping Feathers", cost := [.darkness, .darkness, .colorless], damage := 0,
        effect := .seq (.ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all)) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 12)) (.benchDamage .opp 12)) (.damage (.const 12))),
        gx := false }] }

/-- Sableye (me2-59). Records: me2-59. -/
def me2_59 : Card := .pokemon
  { name := "Sableye", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cocky Claw", cost := [.darkness], damage := 0,
        effect := .ite (.countGe (.bench .own (.and (.stage .stage2) (.ptype .darkness))) 1) (.damage (.const 9)) (.damage (.const 2)),
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

/-- Krookodile (me2-66). Records: me2-66. Caveats: koAttackWide. -/
def me2_66 : Card := .pokemon
  { name := "Krookodile", stage := .stage2, evolvesFrom := some "Krokorok",
    hp := 17, type := .darkness, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Vengeful Fang", cost := [.darkness], damage := 0,
        effect := .ite (.countGe (.koLast .own true) 1) (.damage (.const 22)) (.damage (.const 6)),
        gx := false },
      { name := "Hammer In", cost := [.darkness, .colorless, .colorless, .colorless], damage := 16,
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

/-- Empoleon ex (me2-70). Records: me2-70, me2-114. Caveats: perPokemon, shieldActive, shieldReach. -/
def me2_70 : Card := .pokemon
  { name := "Empoleon ex", stage := .stage2, evolvesFrom := some "Prinplup",
    hp := 32, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .ex, tera := false,
    abilities := [
      { name := "Emperor's Stance", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .shield .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Iron Feathers", cost := [.metal, .metal, .colorless], damage := 21,
        effect := .linger .own .next (.reduce 6),
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

/-- Bronzong (me2-72). Records: me2-72. -/
def me2_72 : Card := .pokemon
  { name := "Bronzong", stage := .stage1, evolvesFrom := some "Bronzor",
    hp := 14, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Triple Draw", cost := [.colorless], damage := 0,
        effect := .move .own (.top 3) .hand .any .all,
        gx := false },
      { name := "Tool Drop", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.count (.tools .own) 4) (.count (.tools .opp) 4)),
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

/-- Wigglytuff (me2-77). Records: me2-77, me2-105. -/
def me2_77 : Card := .pokemon
  { name := "Wigglytuff", stage := .stage1, evolvesFrom := some "Jigglypuff",
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Round", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .own (.and .pokemon (.hasAttack "Round"))) 4),
        gx := false },
      { name := "Seismic Toss", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Aipom (me2-78). Records: me2-78. -/
def me2_78 : Card := .pokemon
  { name := "Aipom", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Astonish", cost := [.colorless, .colorless], damage := 2,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .shuffle .any (.exactly 1)) .skip,
        gx := false }] }

/-- Ambipom (me2-79). Records: me2-79, me2-107. Caveats: benchMods. -/
def me2_79 : Card := .pokemon
  { name := "Ambipom", stage := .stage1, evolvesFrom := some "Aipom",
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slap", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Dual Tail", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .seq (.ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all)) (.ite (.countGe (.bench .opp .any) 2) (.choice (.seq (.damage (.const 6)) (.benchSome .opp 1 .any true 6)) (.benchSome .opp 2 .any true 6)) (.seq (.damage (.const 6)) (.benchSome .opp 1 .any true 6))),
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

/-- Linoone (me2-82). Records: me2-82. Caveats: selfBench. -/
def me2_82 : Card := .pokemon
  { name := "Linoone", stage := .stage1, evolvesFrom := some "Zigzagoon",
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Excited Dash", use := .once,
        spot := some .bench, cond := some (.countGe (.inPlay .own (.and .pokemon .megaEx)) 1),
        effect := .self .switchIn }],
    attacks := [
      { name := "Slash", cost := [.colorless], damage := 7,
        effect := .skip,
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

/-- Mega Lopunny ex (me2-84). Records: me2-84, me2-115, me2-128. Caveats: ignFxStadium, movedUpPromotion. -/
def me2_84 : Card := .pokemon
  { name := "Mega Lopunny ex", stage := .stage1, evolvesFrom := some "Buneary",
    hp := 33, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Gale Thrust", cost := [.colorless], damage := 0,
        effect := .ite (.movedUp .own) (.damage (.const 23)) (.damage (.const 6)),
        gx := false },
      { name := "Spiky Hopper", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.const 16) { fx := true },
        gx := false }] }

/-- Dawn (me2-87). Records: me2-87, me2-118, me2-129. -/
def me2_87 : Card := .trainer "Dawn" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.seq (.move .own .deck .hand .basic (.upTo 1)) (.seq (.move .own .deck .hand (.stage .stage1) (.upTo 1)) (.move .own .deck .hand (.stage .stage2) (.upTo 1)))) .shuffle))

/-- Firebreather (me2-89). Records: me2-89, me2-119. Caveats: upTo0. -/
def me2_89 : Card := .trainer "Firebreather" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.energyOf .fire) (.upTo 7)) .shuffle))

/-- Jumbo Ice Cream (me2-91). Records: me2-91, me4-109. Caveats: energyUnitsCount. -/
def me2_91 : Card := .trainer "Jumbo Ice Cream" .item
    (.seq (.ite (.atLeast .own 1) .skip (.ite (.countGe (.energy .own .energy) 3) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.ite (.countGe (.energy .own .energy) 3) (.heal 8) (.move .own (.top 0) .hand .any (.exactly 1))))

/-- Punk Helmet (me2-92). Records: me2-92, me2-121. Caveats: trigAttached, trigAttacker, trigDamaged. -/
def me2_92 : Card := .tool "Punk Helmet"
  { holder := .ptype .darkness,
    attacks := [],
    abilities := [
      { name := "Punk Helmet", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.counters 4) }] }

/-- Wondrous Patch (me2-94). Records: me2-94, me3-117. Caveats: mayFail. -/
def me2_94 : Card := .trainer "Wondrous Patch" .item
    (.seq (.ite (.countGe (.pile .own .discard (.energyOf .psychic)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.ite (.countGe (.bench .own (.ptype .psychic)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.attach .own .discard (.energyOf .psychic) .bench (.ptype .psychic))))

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

/-- Erika's Vileplume ex (me2pt5-3). Records: me2pt5-3. Caveats: noopUse. -/
def me2pt5_3 : Card := .pokemon
  { name := "Erika's Vileplume ex", stage := .stage2, evolvesFrom := some "Erika's Gloom",
    hp := 31, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Lovely Fragrance", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.atLeast .own 1) .skip (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.heal 3) (.benchHealSome 5 .any (some 3)))) }],
    attacks := [
      { name := "Bloom Powder", cost := [.grass, .grass, .colorless], damage := 16,
        effect := .seq (.inflict .asleep) (.inflict .poisoned),
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

/-- Erika's Weepinbell (me2pt5-5). Records: me2pt5-5. -/
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
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Erika's Victreebel (me2pt5-6). Records: me2pt5-6. -/
def me2pt5_6 : Card := .pokemon
  { name := "Erika's Victreebel", stage := .stage2, evolvesFrom := some "Erika's Weepinbell",
    hp := 15, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flower Garden Rondo", cost := [.grass, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .own (.and .pokemon (.namePrefix "Erika's "))) 4),
        gx := false },
      { name := "Solar Beam", cost := [.grass, .grass, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Erika's Tangela (me2pt5-7). Records: me2pt5-7, me2pt5-218. -/
def me2pt5_7 : Card := .pokemon
  { name := "Erika's Tangela", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Gathering of Blossoms", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.and .pokemon (.namePrefix "Erika's ")) (.upTo 1)) .shuffle)) }],
    attacks := [
      { name := "Bind", cost := [.grass, .colorless], damage := 5,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Chikorita (me2pt5-8). Records: me2pt5-8. Caveats: benchMods, perPokemon. -/
def me2pt5_8 : Card := .pokemon
  { name := "Chikorita", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Growl", cost := [.colorless], damage := 0,
        effect := .linger .opp .next (.weaken 2),
        gx := false },
      { name := "Seed Bomb", cost := [.grass, .grass], damage := 3,
        effect := .skip,
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

/-- Mega Meganium ex (me2pt5-10). Records: me2pt5-10, me2pt5-272. Caveats: energyOfCount. -/
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

/-- Beautifly (me2pt5-13). Records: me2pt5-13, me2pt5-219. -/
def me2pt5_13 : Card := .pokemon
  { name := "Beautifly", stage := .stage2, evolvesFrom := some "Silcoon",
    hp := 13, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stun Spore", cost := [.grass], damage := 4,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Energy Straw", cost := [.grass], damage := 0,
        effect := .damage (.count (.pile .opp .hand .energy) 8),
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

/-- Dustox (me2pt5-15). Records: me2pt5-15, me2pt5-220. -/
def me2pt5_15 : Card := .pokemon
  { name := "Dustox", stage := .stage2, evolvesFrom := some "Cascoon",
    hp := 14, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Boisterous Wind", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.energy .opp .energy) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.returnEnergy .opp .active .energy (.exactly 1) .hand) .skip)) }],
    attacks := [
      { name := "Twilight Poison", cost := [.grass, .grass], damage := 10,
        effect := .seq (.inflict .asleep) (.inflict .poisoned),
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

/-- Mega Charizard Y ex (me2pt5-22). Records: me2pt5-22, me2pt5-294. Caveats: benchMods, discardUnits. -/
def me2pt5_22 : Card := .pokemon
  { name := "Mega Charizard Y ex", stage := .stage2, evolvesFrom := some "Charmeleon",
    hp := 36, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Explosion Y", cost := [.fire, .fire, .colorless], damage := 0,
        effect := .seq (.ite (.countGe (.energy .own .energy) 3) (.discardEnergy .own .active .energy (.exactly 3)) (.discardEnergy .own .active .energy .all)) (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 28)) (.benchDamage .opp 28)) (.damage (.const 28))),
        gx := false }] }

/-- Entei (me2pt5-25). Records: me2pt5-25. Caveats: energyOfCount. -/
def me2pt5_25 : Card := .pokemon
  { name := "Entei", stage := .basic, evolvesFrom := none,
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flare Fall", cost := [.fire, .fire], damage := 0,
        effect := .ite (.countGe (.energyAll .own (.energyOf .fire)) 4) (.damage (.const 12)) (.damage (.const 3)),
        gx := false }] }

/-- Numel (me2pt5-27). Records: me2pt5-27, me2pt5-223. Caveats: trigAttacker, trigDamaged. -/
def me2pt5_27 : Card := .pokemon
  { name := "Numel", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Incandescent Body", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.inflict .burned) }],
    attacks := [
      { name := "Combustion", cost := [.fire, .colorless], damage := 2,
        effect := .skip,
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

/-- Regice ex (me2pt5-48). Records: me2pt5-48. -/
def me2pt5_48 : Card := .pokemon
  { name := "Regice ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Regi Charge", cost := [.colorless], damage := 0,
        effect := .seq (.attach .own .discard (.energyOf .water) .active .any) (.attach .own .discard (.energyOf .water) .active .any),
        gx := false },
      { name := "Ice Prison", cost := [.water, .colorless, .colorless, .colorless], damage := 14,
        effect := .seq (.ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all)) (.inflict .paralyzed),
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

/-- N's Vanilluxe (me2pt5-51). Records: me2pt5-51. Caveats: benchMods. -/
def me2pt5_51 : Card := .pokemon
  { name := "N's Vanilluxe", stage := .stage2, evolvesFrom := some "N's Vanillish",
    hp := 15, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Snow Coating", cost := [.colorless, .colorless], damage := 0,
        effect := .seq (.hitBy .opp .active 1 .any false false (.per 1)) (.hitBy .opp .bench 5 .any false false (.per 1)),
        gx := false },
      { name := "Blizzard", cost := [.water, .colorless, .colorless], damage := 12,
        effect := .spreadDamage .opp 1,
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

/-- Frosmoth (me2pt5-53). Records: me2pt5-53. Caveats: energyOfBasic, moveAnyPair, moveMayFail. -/
def me2pt5_53 : Card := .pokemon
  { name := "Frosmoth", stage := .stage1, evolvesFrom := some "Snom",
    hp := 11, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Alluring Wings", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .opp .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.move .own (.top 1) .hand .any .all) (.move .opp (.top 1) .hand .any .all))) }],
    attacks := [
      { name := "Cold Cyclone", cost := [.water, .water], damage := 9,
        effect := .moveEnergy .own (.energyOf .water),
        gx := false }] }

/-- Glastrier (me2pt5-54). Records: me2pt5-54. Caveats: benchMods. -/
def me2pt5_54 : Card := .pokemon
  { name := "Glastrier", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ice Shot", cost := [.water], damage := 2,
        effect := .benchDamage .opp 2,
        gx := false },
      { name := "Frosty Typhoon", cost := [.water, .water, .water], damage := 13,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- The cards of this part. -/
def cards : List Card := [
  me1_72,
  me1_73,
  me1_74,
  me1_75,
  me1_76,
  me1_77,
  me1_78,
  me1_79,
  me1_81,
  me1_82,
  me1_83,
  me1_84,
  me1_86,
  me1_88,
  me1_89,
  me1_90,
  me1_91,
  me1_93,
  me1_95,
  me1_96,
  me1_97,
  me1_98,
  me1_100,
  me1_102,
  me1_103,
  me1_104,
  me1_106,
  me1_107,
  me1_108,
  me1_109,
  me1_111,
  me1_112,
  me1_114,
  me1_115,
  me1_116,
  me1_119,
  me1_121,
  me1_123,
  me1_126,
  me1_130,
  me1_131,
  me2_1,
  me2_2,
  me2_5,
  me2_6,
  me2_8,
  me2_9,
  me2_12,
  me2_14,
  me2_15,
  me2_16,
  me2_17,
  me2_19,
  me2_20,
  me2_21,
  me2_22,
  me2_23,
  me2_24,
  me2_26,
  me2_27,
  me2_28,
  me2_30,
  me2_31,
  me2_32,
  me2_33,
  me2_34,
  me2_35,
  me2_36,
  me2_37,
  me2_38,
  me2_39,
  me2_40,
  me2_41,
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
  me2_53,
  me2_54,
  me2_55,
  me2_57,
  me2_58,
  me2_59,
  me2_60,
  me2_61,
  me2_63,
  me2_64,
  me2_65,
  me2_66,
  me2_67,
  me2_69,
  me2_70,
  me2_71,
  me2_72,
  me2_73,
  me2_74,
  me2_76,
  me2_77,
  me2_78,
  me2_79,
  me2_81,
  me2_82,
  me2_83,
  me2_84,
  me2_87,
  me2_89,
  me2_91,
  me2_92,
  me2_94,
  me2pt5_1,
  me2pt5_2,
  me2pt5_3,
  me2pt5_4,
  me2pt5_5,
  me2pt5_6,
  me2pt5_7,
  me2pt5_8,
  me2pt5_9,
  me2pt5_10,
  me2pt5_11,
  me2pt5_13,
  me2pt5_14,
  me2pt5_15,
  me2pt5_20,
  me2pt5_21,
  me2pt5_22,
  me2pt5_25,
  me2pt5_27,
  me2pt5_28,
  me2pt5_29,
  me2pt5_30,
  me2pt5_31,
  me2pt5_41,
  me2pt5_42,
  me2pt5_43,
  me2pt5_46,
  me2pt5_47,
  me2pt5_48,
  me2pt5_49,
  me2pt5_50,
  me2pt5_51,
  me2pt5_52,
  me2pt5_53,
  me2pt5_54]

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
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Garganacl"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Dewgong", "Mega Diancie ex"] := by decide +kernel

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
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Punk Helmet", "Numel"] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.koByAttack` (milestone M8b), by name. -/
theorem cards_trigKO : (cards.filter (Card.hasTrig .koByAttack)).map Card.label = ["Flygon"] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.oppBenched` (milestone MV7) (milestone M8b), by name. -/
theorem cards_trigBenched : (cards.filter (Card.hasTrig .oppBenched)).map Card.label = ["Mismagius ex"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Buneary", "Pawmi", "Empoleon ex", "Chikorita"] := by decide +kernel

end PokemonCards.Standard.Part08
