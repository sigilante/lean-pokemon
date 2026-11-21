/-
Imported Standard cards, part 2 of 8 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.6.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part02
open Pokemon

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
        effect := .fx (.choice (.move .own (.top 1) .discard .any .all) .skip) }],
    attacks := [
      { name := "Pick and Stick", cost := [.lightning], damage := 0,
        effect := .seq (.choice (.attach .own .discard .energy .active .any) (.attach .own .discard .energy .bench .any)) (.choice (.attach .own .discard .energy .active .any) (.attach .own .discard .energy .bench .any)),
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

/-- Kadabra (sv6-81). Records: sv6-81. -/
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
        effect := .seq (.move .own .deck .hand .energy (.upTo 3)) .shuffle,
        gx := false },
      { name := "Spinning Attack", cost := [.psychic, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Florges (sv6-88). Records: sv6-88. Caveats: noopUse. -/
def sv6_88 : Card := .pokemon
  { name := "Florges", stage := .stage2, evolvesFrom := some "Floette",
    hp := 14, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Captivating Invitation", use := .once,
        spot := none, cond := none,
        effect := .fx (.choice (.ite (.countGe (.bench .opp .pokemon) 1) (.seq (.switch .opp) (.inflict .confused)) .skip) .skip) }],
    attacks := [
      { name := "Magical Shot", cost := [.psychic, .colorless], damage := 12,
        effect := .skip,
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

/-- Okidogi (sv6-111). Records: sv6-111, sv6pt5-74, sv8pt5-57. -/
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
        effect := .fx (.ite (.countGe (.pile .own .deck .any) 2) (.seq (.move .own (.top 2) .hand .any (.exactly 1)) (.move .own (.top 1) .bottom .any .all)) (.move .own (.top 1) .hand .any .all)) }],
    attacks := [
      { name := "Dragon Headbutt", cost := [.fire, .psychic], damage := 7,
        effect := .skip,
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

/-- Bug Catching Set (sv6-143). Records: sv6-143, sv8pt5-102. -/
def sv6_143 : Card := .trainer "Bug Catching Set" .item
    (.seq (.move .own (.top 7) .hand (.or (.ptype .grass) (.energyOf .grass)) (.upTo 2)) .shuffle)

/-- Cook (sv6-147). Records: sv6-147. Caveats: noopPlay. -/
def sv6_147 : Card := .trainer "Cook" .supporter
    (.heal 7)

/-- Hyper Aroma (sv6-152). Records: sv6-152. Caveats: aceSpec, upTo0. -/
def sv6_152 : Card := .trainer "Hyper Aroma" .item
    (.seq (.move .own .deck .hand (.stage .stage1) (.upTo 3)) .shuffle)

/-- Lucky Helmet (sv6-158). Records: sv6-158. Caveats: trigDamaged. -/
def sv6_158 : Card := .tool "Lucky Helmet"
  { holder := .pokemon,
    attacks := [],
    abilities := [
      { name := "Lucky Helmet", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.move .own (.top 2) .hand .any .all) }] }

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

/-- Golbat (sv6pt5-28). Records: sv6pt5-28. Caveats: perPokemon. -/
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
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Absol (sv6pt5-30). Records: sv6pt5-30. -/
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
        effect := .attach .own .discard .energy .bench .any,
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
        effect := .seq (.attach .own .deck .energy .active .any) .shuffle,
        gx := false },
      { name := "Hammer In", cost := [.colorless, .colorless, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Academy at Night (sv6pt5-54). Records: sv6pt5-54. -/
def sv6pt5_54 : Card := .trainer "Academy at Night" .stadium
    (.move .own .hand .top .any (.exactly 1))

/-- Dangerous Laser (sv6pt5-58). Records: sv6pt5-58. Caveats: aceSpec. -/
def sv6pt5_58 : Card := .trainer "Dangerous Laser" .item
    (.seq (.inflict .burned) (.inflict .confused))

/-- Night Stretcher (sv6pt5-61). Records: sv6pt5-61, sv8-251, me1-173, me2pt5-196. -/
def sv6pt5_61 : Card := .trainer "Night Stretcher" .item
    (.move .own .discard .hand (.or .pokemon .energy) (.exactly 1))

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

/-- Ponyta (sv7-19). Records: sv7-19. -/
def sv7_19 : Card := .pokemon
  { name := "Ponyta", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flop", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Rapidash (sv7-20). Records: sv7-20. -/
def sv7_20 : Card := .pokemon
  { name := "Rapidash", stage := .stage1, evolvesFrom := some "Ponyta",
    hp := 12, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Burning Run", cost := [.fire, .colorless], damage := 0,
        effect := .choice (.damage (.const 12)) (.damage (.const 6)),
        gx := false }] }

/-- Reshiram (sv7-22). Records: sv7-22. -/
def sv7_22 : Card := .pokemon
  { name := "Reshiram", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Heat Blast", cost := [.fire, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Salandit (sv7-23). Records: sv7-23, me2pt5-34. -/
def sv7_23 : Card := .pokemon
  { name := "Salandit", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ember", cost := [.fire], damage := 3,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Turtonator (sv7-25). Records: sv7-25, sv7-146. Caveats: perPokemon, recoil. -/
def sv7_25 : Card := .pokemon
  { name := "Turtonator", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ring of Fire", cost := [.fire, .colorless, .colorless], damage := 5,
        effect := .seq (.inflict .burned) (.linger .opp .next (.lock .retreat)),
        gx := false },
      { name := "Inferno Onrush", cost := [.fire, .fire, .colorless, .colorless], damage := 18,
        effect := .selfDamage 6,
        gx := false }] }

/-- Scorbunny (sv7-26). Records: sv7-26, me2pt5-36, me2pt5-225. -/
def sv7_26 : Card := .pokemon
  { name := "Scorbunny", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Quick Attack", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 2)) (.damage (.const 1)),
        gx := false }] }

/-- Raboot (sv7-27). Records: sv7-27, sv7-147, me2pt5-37. -/
def sv7_27 : Card := .pokemon
  { name := "Raboot", stage := .stage1, evolvesFrom := some "Scorbunny",
    hp := 9, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Low Sweep", cost := [.fire], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Combustion", cost := [.fire, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Charcadet (sv7-29). Records: sv7-29. -/
def sv7_29 : Card := .pokemon
  { name := "Charcadet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flare", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Lapras (sv7-31). Records: sv7-31. -/
def sv7_31 : Card := .pokemon
  { name := "Lapras", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Water Gun", cost := [.water], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Surf", cost := [.water, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Marill (sv7-33). Records: sv7-33. -/
def sv7_33 : Card := .pokemon
  { name := "Marill", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rollout", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Azumarill (sv7-34). Records: sv7-34. -/
def sv7_34 : Card := .pokemon
  { name := "Azumarill", stage := .stage1, evolvesFrom := some "Marill",
    hp := 12, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bubble Beam", cost := [.water, .colorless], damage := 6,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Finneon (sv7-35). Records: sv7-35. -/
def sv7_35 : Card := .pokemon
  { name := "Finneon", stage := .basic, evolvesFrom := none,
    hp := 5, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sprinkle Water", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Tirtouga (sv7-37). Records: sv7-37. -/
def sv7_37 : Card := .pokemon
  { name := "Tirtouga", stage := .stage1, evolvesFrom := some "Antique Cover Fossil",
    hp := 10, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Splashing Turn", cost := [.water, .water], damage := 7,
        effect := .switch .own,
        gx := false }] }

/-- Carracosta (sv7-38). Records: sv7-38. -/
def sv7_38 : Card := .pokemon
  { name := "Carracosta", stage := .stage2, evolvesFrom := some "Tirtouga",
    hp := 16, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Primal Knowledge", use := .static [{ sel := .own, filt := .any, tgt := none, src := none, need := none, eff := .bonus 3 (.and .pokemon (.not .basic)) }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Tidal Wave", cost := [.water, .water], damage := 15,
        effect := .skip,
        gx := false }] }

/-- Froakie (sv7-39). Records: sv7-39. -/
def sv7_39 : Card := .pokemon
  { name := "Froakie", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rain Splash", cost := [.water, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Frogadier (sv7-40). Records: sv7-40. -/
def sv7_40 : Card := .pokemon
  { name := "Frogadier", stage := .stage1, evolvesFrom := some "Froakie",
    hp := 9, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wave Splash", cost := [.water, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Greninja ex (sv7-41). Records: sv7-41. -/
def sv7_41 : Card := .pokemon
  { name := "Greninja ex", stage := .stage2, evolvesFrom := some "Frogadier",
    hp := 30, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Shifting Shuriken", cost := [.water, .colorless], damage := 0,
        effect := .choice (.damage (.const 20)) (.damage (.const 10)),
        gx := false }] }

/-- Chewtle (sv7-43). Records: sv7-43. -/
def sv7_43 : Card := .pokemon
  { name := "Chewtle", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.colorless, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Electabuzz (sv7-46). Records: sv7-46. -/
def sv7_46 : Card := .pokemon
  { name := "Electabuzz", stage := .basic, evolvesFrom := none,
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.lightning], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Magnum Punch", cost := [.lightning, .lightning], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Electivire (sv7-47). Records: sv7-47. -/
def sv7_47 : Card := .pokemon
  { name := "Electivire", stage := .stage1, evolvesFrom := some "Electabuzz",
    hp := 15, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electroslug", cost := [.lightning], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Unleash Lightning", cost := [.lightning, .lightning], damage := 22,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Chinchou (sv7-48). Records: sv7-48. -/
def sv7_48 : Card := .pokemon
  { name := "Chinchou", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Voltage", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 2)) (.damage (.const 4))),
        gx := false }] }

/-- Zeraora (sv7-55). Records: sv7-55, sv7-151. -/
def sv7_55 : Card := .pokemon
  { name := "Zeraora", stage := .basic, evolvesFrom := none,
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Combat Thunder", cost := [.lightning, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.count (.bench .opp .pokemon) 2)),
        gx := false }] }

/-- Pawmi (sv7-56). Records: sv7-56. Caveats: benchMods. -/
def sv7_56 : Card := .pokemon
  { name := "Pawmi", stage := .basic, evolvesFrom := none,
    hp := 4, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Targeted Spark", cost := [.lightning], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 2)) (.benchDamage .opp 2)) (.damage (.const 2)),
        gx := false }] }

/-- Slowpoke (sv7-57). Records: sv7-57. -/
def sv7_57 : Card := .pokemon
  { name := "Slowpoke", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dangle Tail", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.pile .own .discard .pokemon) 1) (.move .own .discard .hand .pokemon (.exactly 1)) .skip,
        gx := false },
      { name := "Tackle", cost := [.psychic, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Mewtwo (sv7-59). Records: sv7-59. -/
def sv7_59 : Card := .pokemon
  { name := "Mewtwo", stage := .basic, evolvesFrom := none,
    hp := 13, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Super Psy Bolt", cost := [.psychic, .psychic, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Drifloon (sv7-60). Records: sv7-60. Caveats: perPokemon. -/
def sv7_60 : Card := .pokemon
  { name := "Drifloon", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Expand", cost := [.psychic], damage := 1,
        effect := .linger .own .next (.reduce 1),
        gx := false }] }

/-- Comfey (sv7-63). Records: sv7-63. -/
def sv7_63 : Card := .pokemon
  { name := "Comfey", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flower Shower", cost := [.psychic], damage := 0,
        effect := .seq (.move .own (.top 3) .hand .any .all) (.move .opp (.top 3) .hand .any .all),
        gx := false },
      { name := "Play Rough", cost := [.psychic], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Milcery (sv7-64). Records: sv7-64, sv7-152. -/
def sv7_64 : Card := .pokemon
  { name := "Milcery", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mumble", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Fidough (sv7-66). Records: sv7-66. -/
def sv7_66 : Card := .pokemon
  { name := "Fidough", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pleasant Aroma", cost := [.colorless], damage := 0,
        effect := .seq (.putBench .own .deck .basic) .shuffle,
        gx := false },
      { name := "Stampede", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Flittle (sv7-68). Records: sv7-68. -/
def sv7_68 : Card := .pokemon
  { name := "Flittle", stage := .basic, evolvesFrom := none,
    hp := 5, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Peck", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Espathra (sv7-69). Records: sv7-69. -/
def sv7_69 : Card := .pokemon
  { name := "Espathra", stage := .stage1, evolvesFrom := some "Flittle",
    hp := 13, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Psychic Flash", cost := [.psychic], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Greavard (sv7-70). Records: sv7-70. -/
def sv7_70 : Card := .pokemon
  { name := "Greavard", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Paw Shake Punch", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Bite", cost := [.psychic, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Cubone (sv7-72). Records: sv7-72. Caveats: recoil. -/
def sv7_72 : Card := .pokemon
  { name := "Cubone", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.fighting], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Rhyhorn (sv7-74). Records: sv7-74. -/
def sv7_74 : Card := .pokemon
  { name := "Rhyhorn", stage := .basic, evolvesFrom := none,
    hp := 10, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Horn Attack", cost := [.fighting, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Rhydon (sv7-75). Records: sv7-75. -/
def sv7_75 : Card := .pokemon
  { name := "Rhydon", stage := .stage1, evolvesFrom := some "Rhyhorn",
    hp := 14, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Destructive Horn", cost := [.fighting, .colorless, .colorless], damage := 8,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Meditite (sv7-77). Records: sv7-77. -/
def sv7_77 : Card := .pokemon
  { name := "Meditite", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Beat", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Meditite (sv7-78). Records: sv7-78, sv7-153. -/
def sv7_78 : Card := .pokemon
  { name := "Meditite", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Calm Mind", cost := [.colorless], damage := 0,
        effect := .heal 2,
        gx := false },
      { name := "Chop", cost := [.fighting, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Medicham (sv7-79). Records: sv7-79. -/
def sv7_79 : Card := .pokemon
  { name := "Medicham", stage := .stage1, evolvesFrom := some "Meditite",
    hp := 11, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Smash", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 4)) (.damage (.const 8))),
        gx := false }] }

/-- Riolu (sv7-81). Records: sv7-81. -/
def sv7_81 : Card := .pokemon
  { name := "Riolu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Punch", cost := [.fighting, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Lucario ex (sv7-82). Records: sv7-82. -/
def sv7_82 : Card := .pokemon
  { name := "Lucario ex", stage := .stage1, evolvesFrom := some "Riolu",
    hp := 25, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Low Kick", cost := [.fighting, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Aura Knuckle", cost := [.fighting, .fighting, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Mienfoo (sv7-83). Records: sv7-83. -/
def sv7_83 : Card := .pokemon
  { name := "Mienfoo", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knock Off", cost := [.fighting], damage := 1,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Mienshao (sv7-84). Records: sv7-84. -/
def sv7_84 : Card := .pokemon
  { name := "Mienshao", stage := .stage1, evolvesFrom := some "Mienfoo",
    hp := 9, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gale Roundhouse", cost := [.fighting], damage := 0,
        effect := .ite (.countGe (.pile .opp .hand .any) 6) (.damage (.const 3)) (.damage (.const 9)),
        gx := false }] }

/-- Pancham (sv7-85). Records: sv7-85. -/
def sv7_85 : Card := .pokemon
  { name := "Pancham", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leer", cost := [.colorless], damage := 0,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Low Kick", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Crabrawler (sv7-87). Records: sv7-87. -/
def sv7_87 : Card := .pokemon
  { name := "Crabrawler", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Vise Grip", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Crabhammer", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Gulpin (sv7-91). Records: sv7-91, sv7-154. -/
def sv7_91 : Card := .pokemon
  { name := "Gulpin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Drool", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Super Poison Breath", cost := [.darkness, .darkness, .colorless], damage := 3,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Impidimp (sv7-94). Records: sv7-94. -/
def sv7_94 : Card := .pokemon
  { name := "Impidimp", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smack", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Claw Slash", cost := [.darkness, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Morgrem (sv7-95). Records: sv7-95. -/
def sv7_95 : Card := .pokemon
  { name := "Morgrem", stage := .stage1, evolvesFrom := some "Impidimp",
    hp := 9, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Darkness Fang", cost := [.darkness, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Bombirdier (sv7-97). Records: sv7-97. Caveats: recoil. -/
def sv7_97 : Card := .pokemon
  { name := "Bombirdier", stage := .basic, evolvesFrom := none,
    hp := 10, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.darkness, .colorless], damage := 7,
        effect := .selfDamage 2,
        gx := false }] }

/-- Jirachi (sv7-98). Records: sv7-98. Caveats: mayFail. -/
def sv7_98 : Card := .pokemon
  { name := "Jirachi", stage := .basic, evolvesFrom := none,
    hp := 8, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Swelling Wish", cost := [.colorless], damage := 0,
        effect := .attach .own .discard .energy .bench .any,
        gx := false },
      { name := "Slap", cost := [.metal, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Klink (sv7-99). Records: sv7-99. -/
def sv7_99 : Card := .pokemon
  { name := "Klink", stage := .basic, evolvesFrom := none,
    hp := 6, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Allure", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Beam", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Klang (sv7-100). Records: sv7-100. Caveats: recoil. -/
def sv7_100 : Card := .pokemon
  { name := "Klang", stage := .stage1, evolvesFrom := some "Klink",
    hp := 9, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Iron Tackle", cost := [.colorless, .colorless], damage := 6,
        effect := .selfDamage 2,
        gx := false }] }

/-- Meltan (sv7-102). Records: sv7-102. -/
def sv7_102 : Card := .pokemon
  { name := "Meltan", stage := .basic, evolvesFrom := none,
    hp := 6, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stampede", cost := [.metal], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Beam", cost := [.metal, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Meltan (sv7-103). Records: sv7-103. -/
def sv7_103 : Card := .pokemon
  { name := "Meltan", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knickknack Carrying", cost := [.metal], damage := 0,
        effect := .seq (.move .own .deck .hand .tool (.upTo 1)) .shuffle,
        gx := false },
      { name := "Ram", cost := [.metal, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Melmetal ex (sv7-105). Records: sv7-105. -/
def sv7_105 : Card := .pokemon
  { name := "Melmetal ex", stage := .stage1, evolvesFrom := some "Meltan",
    hp := 28, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Iron Swing", cost := [.metal, .metal, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 10)) (.damage (.const 20))),
        gx := false }] }

/-- Duraludon (sv7-106). Records: sv7-106, sv8pt5-69. -/
def sv7_106 : Card := .pokemon
  { name := "Duraludon", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hammer In", cost := [.metal], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Raging Hammer", cost := [.metal, .metal, .colorless], damage := 0,
        effect := .damage (.add (.const 8) (.per .own 1)),
        gx := false }] }

/-- Varoom (sv7-108). Records: sv7-108. -/
def sv7_108 : Card := .pokemon
  { name := "Varoom", stage := .basic, evolvesFrom := none,
    hp := 8, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Revavroom (sv7-109). Records: sv7-109. -/
def sv7_109 : Card := .pokemon
  { name := "Revavroom", stage := .stage1, evolvesFrom := some "Varoom",
    hp := 15, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Outta-Control Dash", cost := [.metal, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Tauros (sv7-112). Records: sv7-112. -/
def sv7_112 : Card := .pokemon
  { name := "Tauros", stage := .basic, evolvesFrom := none,
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Destructive Horn", cost := [.colorless, .colorless, .colorless], damage := 7,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Eevee (sv7-113). Records: sv7-113. -/
def sv7_113 : Card := .pokemon
  { name := "Eevee", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.putBench .own .deck .basic) .shuffle,
        gx := false },
      { name := "Gnaw", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Hoothoot (sv7-114). Records: sv7-114. -/
def sv7_114 : Card := .pokemon
  { name := "Hoothoot", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Triple Stab", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.choice (.damage (.const 2)) (.damage (.const 3)))),
        gx := false }] }

/-- Glameow (sv7-116). Records: sv7-116. -/
def sv7_116 : Card := .pokemon
  { name := "Glameow", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hook", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Tornadus (sv7-120). Records: sv7-120. Caveats: perPokemon. -/
def sv7_120 : Card := .pokemon
  { name := "Tornadus", stage := .basic, evolvesFrom := none,
    hp := 11, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knuckle Punch", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Storm Barrier", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .linger .own .next (.reduce 5),
        gx := false }] }

/-- Fletchling (sv7-121). Records: sv7-121. -/
def sv7_121 : Card := .pokemon
  { name := "Fletchling", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Send Back", cost := [.colorless], damage := 1,
        effect := .switch .opp,
        gx := false }] }

/-- Fletchinder (sv7-122). Records: sv7-122. -/
def sv7_122 : Card := .pokemon
  { name := "Fletchinder", stage := .stage1, evolvesFrom := some "Fletchling",
    hp := 9, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Speed Dive", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Wooloo (sv7-124). Records: sv7-124. -/
def sv7_124 : Card := .pokemon
  { name := "Wooloo", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knock Over", cost := [.colorless, .colorless], damage := 3,
        effect := .choice .discardStadium .skip,
        gx := false }] }

/-- Dubwool (sv7-125). Records: sv7-125. Caveats: staticBench. -/
def sv7_125 : Card := .pokemon
  { name := "Dubwool", stage := .stage1, evolvesFrom := some "Wooloo",
    hp := 13, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Soft Wool", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 3 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Knock Over", cost := [.colorless, .colorless], damage := 7,
        effect := .choice .discardStadium .skip,
        gx := false }] }

/-- Lechonk (sv7-126). Records: sv7-126. -/
def sv7_126 : Card := .pokemon
  { name := "Lechonk", stage := .basic, evolvesFrom := none,
    hp := 5, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rear Kick", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Cyclizar (sv7-127). Records: sv7-127. -/
def sv7_127 : Card := .pokemon
  { name := "Cyclizar", stage := .basic, evolvesFrom := none,
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tail Snap", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Speed Attack", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Deluxe Bomb (sv7-134). Records: sv7-134. Caveats: aceSpec, trigAttacker, trigDamaged. -/
def sv7_134 : Card := .tool "Deluxe Bomb"
  { holder := .pokemon,
    attacks := [],
    abilities := [
      { name := "Deluxe Bomb", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.seq (.counters 12) (.discardTools .own .active)) }] }

/-- Gravity Gemstone (sv7-137). Records: sv7-137. -/
def sv7_137 : Card := .tool "Gravity Gemstone"
  { holder := .pokemon,
    attacks := [],
    abilities := [],
    statics := [
      { sel := .all, filt := .any, tgt := some .active, src := some .active, need := none, eff := .retreatPlus 1 }] }

/-- Exeggcute (sv8-2). Records: sv8-2. -/
def sv8_2 : Card := .pokemon
  { name := "Exeggcute", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Absorb", cost := [.colorless], damage := 1,
        effect := .heal 1,
        gx := false }] }

/-- Scatterbug (sv8-5). Records: sv8-5. -/
def sv8_5 : Card := .pokemon
  { name := "Scatterbug", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.putBench .own .deck .basic) .shuffle,
        gx := false }] }

/-- Spewpa (sv8-6). Records: sv8-6. -/
def sv8_6 : Card := .pokemon
  { name := "Spewpa", stage := .stage1, evolvesFrom := some "Scatterbug",
    hp := 8, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wander About", cost := [.colorless], damage := 0,
        effect := .switch .own,
        gx := false },
      { name := "Tackle", cost := [.grass], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Morelull (sv8-8). Records: sv8-8. -/
def sv8_8 : Card := .pokemon
  { name := "Morelull", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Attach", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
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
  sv6_86,
  sv6_87,
  sv6_88,
  sv6_97,
  sv6_98,
  sv6_99,
  sv6_101,
  sv6_103,
  sv6_108,
  sv6_109,
  sv6_111,
  sv6_113,
  sv6_115,
  sv6_116,
  sv6_118,
  sv6_119,
  sv6_120,
  sv6_121,
  sv6_124,
  sv6_126,
  sv6_128,
  sv6_129,
  sv6_137,
  sv6_139,
  sv6_143,
  sv6_147,
  sv6_152,
  sv6_158,
  sv6pt5_3,
  sv6pt5_6,
  sv6pt5_7,
  sv6pt5_10,
  sv6pt5_11,
  sv6pt5_13,
  sv6pt5_14,
  sv6pt5_16,
  sv6pt5_18,
  sv6pt5_23,
  sv6pt5_25,
  sv6pt5_27,
  sv6pt5_28,
  sv6pt5_30,
  sv6pt5_31,
  sv6pt5_41,
  sv6pt5_43,
  sv6pt5_44,
  sv6pt5_48,
  sv6pt5_49,
  sv6pt5_51,
  sv6pt5_52,
  sv6pt5_53,
  sv6pt5_54,
  sv6pt5_58,
  sv6pt5_61,
  sv7_2,
  sv7_4,
  sv7_5,
  sv7_7,
  sv7_9,
  sv7_10,
  sv7_12,
  sv7_15,
  sv7_16,
  sv7_17,
  sv7_18,
  sv7_19,
  sv7_20,
  sv7_22,
  sv7_23,
  sv7_25,
  sv7_26,
  sv7_27,
  sv7_29,
  sv7_31,
  sv7_33,
  sv7_34,
  sv7_35,
  sv7_37,
  sv7_38,
  sv7_39,
  sv7_40,
  sv7_41,
  sv7_43,
  sv7_46,
  sv7_47,
  sv7_48,
  sv7_55,
  sv7_56,
  sv7_57,
  sv7_59,
  sv7_60,
  sv7_63,
  sv7_64,
  sv7_66,
  sv7_68,
  sv7_69,
  sv7_70,
  sv7_72,
  sv7_74,
  sv7_75,
  sv7_77,
  sv7_78,
  sv7_79,
  sv7_81,
  sv7_82,
  sv7_83,
  sv7_84,
  sv7_85,
  sv7_87,
  sv7_91,
  sv7_94,
  sv7_95,
  sv7_97,
  sv7_98,
  sv7_99,
  sv7_100,
  sv7_102,
  sv7_103,
  sv7_105,
  sv7_106,
  sv7_108,
  sv7_109,
  sv7_112,
  sv7_113,
  sv7_114,
  sv7_116,
  sv7_120,
  sv7_121,
  sv7_122,
  sv7_124,
  sv7_125,
  sv7_126,
  sv7_127,
  sv7_134,
  sv7_137,
  sv8_2,
  sv8_5,
  sv8_6,
  sv8_8]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = ["Okidogi"] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Okidogi", "Carracosta"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Dubwool"] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = ["Gravity Gemstone"] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 10 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 10)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Lucky Helmet", "Deluxe Bomb"] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.koByAttack` (milestone M8b), by name. -/
theorem cards_trigKO : (cards.filter (Card.hasTrig .koByAttack)).map Card.label = [] := by decide +kernel

/-- The cards of this part whose triggered Abilities write a lingering modifier (milestone M8b), by name. -/
theorem cards_trigLingers : (cards.filter Card.trigLingers).map Card.label = [] := by decide +kernel

/-- The cards of this part whose triggered Abilities can return a card from a discard pile (milestone M8b), by name. -/
theorem cards_trigRecycles : (cards.filter Card.trigRecycles).map Card.label = [] := by decide +kernel

/-- Every triggered Ability of this part has no printed condition and an effect of the trigger
fragment (`Card.trigsOk`). -/
theorem cards_trigsOk : cards.all Card.trigsOk = true := by decide +kernel

/-- The cards of this part that are not `Card.tame` (a `drain` attack or a stored damage reduction), by
name. -/
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Varoom", "Drifloon", "Tornadus"] := by decide +kernel

end PokemonCards.Standard.Part02
