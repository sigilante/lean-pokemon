/-
Imported Standard cards, part 1 of 11 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.20.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part01
open Pokemon

/-- Fighting Energy (base1-97). Records: base1-97, base4-125, gym1-127, gym2-127, neo1-106, ecard1-160, ex1-105, ex9-106, ex13-110, ex16-108, dp1-128, hgss1-120, col1-93, bw1-110, xy1-137, g1-80, xy12-96, sm1-169, sm2-169, swsh6-233, swsh12pt5-157, sv1-258, sve-6, sve-14. -/
def base1_97 : Card := .energy .fighting

/-- Fire Energy (base1-98). Records: base1-98, base4-126, gym1-128, gym2-128, neo1-107, ecard1-161, ex1-108, tk1a-10, ex9-102, tk2b-11, ex13-106, ex16-104, dp1-124, hgss1-116, col1-89, bw1-106, xy1-133, g1-76, xy12-92, sm1-165, sm3-167, swsh8-284, swsh12pt5-153, sve-2, sve-10, sv3-230. -/
def base1_98 : Card := .energy .fire

/-- Grass Energy (base1-99). Records: base1-99, base4-127, gym1-129, gym2-129, neo1-108, ecard1-162, ex1-104, ex9-101, ex13-105, ex16-103, dp1-123, hgss1-115, col1-88, bw1-105, xy1-132, g1-75, xy12-91, sm1-164, sm2-167, swsh8-283, swsh12pt5-152, sve-1, sve-9, sv2-278. -/
def base1_99 : Card := .energy .grass

/-- Lightning Energy (base1-100). Records: base1-100, base4-128, gym1-130, gym2-130, neo1-109, ecard1-163, ex1-109, tk1b-10, ex9-104, tk2a-11, tk2b-12, ex13-108, ex16-106, dp1-126, hgss1-118, col1-91, bw1-108, xy1-135, g1-78, xy12-94, sm1-167, sm2-168, swsh7-235, swsh12pt5-155, sv1-257, sve-4, sve-12. -/
def base1_100 : Card := .energy .lightning

/-- Psychic Energy (base1-101). Records: base1-101, base4-129, gym1-131, gym2-131, neo1-110, ecard1-164, ex1-107, ex9-105, tk2a-12, ex13-109, ex16-107, dp1-127, hgss1-119, col1-92, bw1-109, xy1-136, g1-79, xy12-95, sm1-162, sm1-168, swsh6-232, swsh12pt5-156, sve-5, sve-13, sv3pt5-207. -/
def base1_101 : Card := .energy .psychic

/-- Water Energy (base1-102). Records: base1-102, base4-130, gym1-132, gym2-132, neo1-111, ecard1-165, ex1-106, ex9-103, ex13-107, ex16-105, dp1-125, hgss1-117, col1-90, bw1-107, xy1-134, g1-77, xy12-93, sm1-166, sm4-124, swsh6-231, swsh12pt5-154, sve-3, sve-11, sv2-279. -/
def base1_102 : Card := .energy .water

/-- Darkness Energy (dp1-129). Records: dp1-129, hgss1-121, col1-94, bw1-111, xy1-138, g1-81, xy12-97, sm1-170, sm3-168, swsh7-236, swsh12pt5-158, sve-7, sve-15, sv6pt5-98. -/
def dp1_129 : Card := .energy .darkness

/-- Metal Energy (dp1-130). Records: dp1-130, hgss1-122, col1-95, bw1-112, xy1-139, g1-82, xy12-98, sm1-163, sm1-171, swsh7-237, swsh12pt5-159, sve-8, sve-16, sv6pt5-99. -/
def dp1_130 : Card := .energy .metal

/-- Fairy Energy (xy1-140). Records: xy1-140, g1-83, xy12-99, sm1-172, sm3-169. -/
def xy1_140 : Card := .energy .fairy

/-- Sprigatito ex (svp-87). Records: svp-87, me2pt5-251. -/
def svp_87 : Card := .pokemon
  { name := "Sprigatito ex", stage := .basic, evolvesFrom := none,
    hp := 20, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Magical Leaf", cost := [.grass, .colorless, .colorless], damage := 10,
        effect := .heal 3,
        gx := false }] }

/-- Feraligatr (svp-89). Records: svp-89, sv5-41. Caveats: koBetweenSteps, perPokemon, selfBench. -/
def svp_89 : Card := .pokemon
  { name := "Feraligatr", stage := .stage2, evolvesFrom := some "Croconaw",
    hp := 18, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Torrential Heart", use := .once,
        spot := none, cond := none,
        effect := .seq (.self (.counters 5)) (.fx (.linger .own .now (.bonus 12))) }],
    attacks := [
      { name := "Giant Wave", cost := [.water, .water], damage := 16,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Metang (svp-90). Records: svp-90, sv5-114. -/
def svp_90 : Card := .pokemon
  { name := "Metang", stage := .stage1, evolvesFrom := some "Beldum",
    hp := 10, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Metal Maker", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own (.top 4) (.energyOf .metal) (.upTo 4) (.attach .any) .bottom)) }],
    attacks := [
      { name := "Beam", cost := [.metal, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Koraidon (svp-91). Records: svp-91, sv5-119. Caveats: ignFxStadium. -/
def svp_91 : Card := .pokemon
  { name := "Koraidon", stage := .basic, evolvesFrom := none,
    hp := 14, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Primordial Beatdown", cost := [.fighting, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .own (.and .pokemon (.or (.or (.or (.nameIn ["Ancient Booster Energy Capsule", "Awakening Drum", "Brute Bonnet", "Explorer's Guidance", "Flutter Mane", "Gouging Fire", "Gouging Fire ex", "Great Tusk", "Raging Bolt", "Raging Bolt ex", "Roaring Moon", "Sandy Shocks", "Scream Tail", "Scream Tail ex", "Slither Wing", "Walking Wake", "Walking Wake ex"]) (.and (.named "Koraidon") (.hasAttack "Primordial Beatdown"))) (.and (.named "Koraidon") (.hasAttack "Unrelenting Onslaught"))) (.and (.named "Koraidon ex") (.hasAttack "Retribution Strike"))))) 3),
        gx := false },
      { name := "Shred", cost := [.fire, .fighting, .colorless], damage := 0,
        effect := .damage (.const 13) { fx := true },
        gx := false }] }

/-- Armarouge ex (svp-105). Records: svp-105. Caveats: energyOfBasic, energyOfCount. -/
def svp_105 : Card := .pokemon
  { name := "Armarouge ex", stage := .stage1, evolvesFrom := some "Charcadet",
    hp := 26, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Armor Cannon", cost := [.fire, .fire, .colorless], damage := 20,
        effect := .ite (.countGe (.energy .own (.energyOf .fire)) 1) (.discardEnergy .own .active (.energyOf .fire) (.exactly 1)) .skip,
        gx := false }] }

/-- Pikachu ex (svp-106). Records: svp-106, me2pt5-276. -/
def svp_106 : Card := .pokemon
  { name := "Pikachu ex", stage := .basic, evolvesFrom := none,
    hp := 20, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunderbolt", cost := [.lightning, .lightning, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Mareep (svp-107). Records: svp-107. -/
def svp_107 : Card := .pokemon
  { name := "Mareep", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.lightning], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Lightning Ball", cost := [.lightning, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Flaaffy (svp-108). Records: svp-108. -/
def svp_108 : Card := .pokemon
  { name := "Flaaffy", stage := .stage1, evolvesFrom := some "Mareep",
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.lightning], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Electro Ball", cost := [.lightning, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Ampharos (svp-109). Records: svp-109. -/
def svp_109 : Card := .pokemon
  { name := "Ampharos", stage := .stage2, evolvesFrom := some "Flaaffy",
    hp := 16, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electric Ball", cost := [.lightning, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Darkrai ex (svp-110). Records: svp-110. -/
def svp_110 : Card := .pokemon
  { name := "Darkrai ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Wind of Darkness", cost := [.darkness, .colorless], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Night Impact", cost := [.darkness, .darkness, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Pawniard (svp-111). Records: svp-111. -/
def svp_111 : Card := .pokemon
  { name := "Pawniard", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pierce", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Bisharp (svp-112). Records: svp-112. -/
def svp_112 : Card := .pokemon
  { name := "Bisharp", stage := .stage1, evolvesFrom := some "Pawniard",
    hp := 10, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cut", cost := [.darkness], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Kingambit (svp-113). Records: svp-113. -/
def svp_113 : Card := .pokemon
  { name := "Kingambit", stage := .stage2, evolvesFrom := some "Bisharp",
    hp := 17, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Elbow Strike", cost := [.darkness], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Slicing Blade", cost := [.darkness, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Picnicker (svp-114). Records: svp-114. -/
def svp_114 : Card := .trainer "Picnicker" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.move .own (.top 4) .hand .any .all) (.move .own (.top 2) .hand .any .all)))

/-- Tatsugiri (svp-118). Records: svp-118, sv6-131, sv6-186. Caveats: failToFind. -/
def svp_118 : Card := .pokemon
  { name := "Tatsugiri", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Attract Customers", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own (.top 6) (.kind .supporter) (.most 1) (.put .hand) .shuffle)) }],
    attacks := [
      { name := "Surf", cost := [.fire, .water], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Snorlax (svp-122). Records: svp-122. -/
def svp_122 : Card := .pokemon
  { name := "Snorlax", stage := .basic, evolvesFrom := none,
    hp := 16, type := .colorless, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lazy Press", cost := [.colorless, .colorless, .colorless, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Teal Mask Ogerpon (svp-123). Records: svp-123, sv6-24. -/
def svp_123 : Card := .pokemon
  { name := "Teal Mask Ogerpon", stage := .basic, evolvesFrom := none,
    hp := 11, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mountain Stroll", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .basicEnergy (.upTo 2)) .shuffle,
        gx := false },
      { name := "Ogre Comeback", cost := [.grass, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.count (.bench .opp .pokemon) 2)),
        gx := false }] }

/-- Pecharunt (svp-129). Records: svp-129, svp-149. Caveats: perPokemon. -/
def svp_129 : Card := .pokemon
  { name := "Pecharunt", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Toxic Subjugation", use := .static [{ sel := .opp, filt := .any, tgt := none, src := some .active, need := none, eff := .condMore .poisoned 5 }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Poison Chain", cost := [.darkness, .colorless], damage := 1,
        effect := .seq (.inflict .poisoned) (.linger .opp .next (.lock .retreat)),
        gx := false }] }

/-- Kingdra ex (svp-131). Records: svp-131, sv6pt5-12, sv6pt5-80. Caveats: energyOfCount. -/
def svp_131 : Card := .pokemon
  { name := "Kingdra ex", stage := .stage2, evolvesFrom := some "Seadra",
    hp := 31, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "King's Order", cost := [.water], damage := 0,
        effect := .seq (.putBench .own .discard (.ptype .water)) (.seq (.putBench .own .discard (.ptype .water)) (.putBench .own .discard (.ptype .water))),
        gx := false },
      { name := "Hydro Pump", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 5) (.count (.energy .own (.energyOf .water)) 5)),
        gx := false }] }

/-- Drifblim (svp-135). Records: svp-135, sv7-61. Caveats: benchMods, recoil. -/
def svp_135 : Card := .pokemon
  { name := "Drifblim", stage := .stage1, evolvesFrom := some "Drifloon",
    hp := 13, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Everyone Explode Now", cost := [.psychic], damage := 0,
        effect := .seq (.damage (.count (.inPlay .own (.or (.named "Drifloon") (.named "Drifblim"))) 5)) (.seq (.hitBy .own .active 1 (.or (.named "Drifloon") (.named "Drifblim")) false false (.const 3)) (.benchSome .own 5 (.or (.named "Drifloon") (.named "Drifblim")) true 3)),
        gx := false }] }

/-- Noctowl (svp-141). Records: svp-141, sv7-115, sv8pt5-78. Caveats: upTo0. -/
def svp_141 : Card := .pokemon
  { name := "Noctowl", stage := .stage1, evolvesFrom := some "Hoothoot",
    hp := 10, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Jewel Seeker", use := .onPlay .evolve,
        spot := none, cond := some (.countGe (.inPlay .own (.and .pokemon .tera)) 1),
        effect := .fx (.seq (.move .own .deck .hand .trainer (.upTo 2)) .shuffle) }],
    attacks := [
      { name := "Speed Wing", cost := [.colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Miraidon (svp-148). Records: svp-148. -/
def svp_148 : Card := .pokemon
  { name := "Miraidon", stage := .basic, evolvesFrom := none,
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electric Claws", cost := [.lightning], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Mach Bolt", cost := [.lightning, .lightning], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Paradise Resort (svp-150). Records: svp-150. -/
def svp_150 : Card := .trainer "Paradise Resort" .stadium
    .skip [
      { sel := .all, filt := .named "Psyduck", tgt := none, src := none, need := none, eff := .retreatMinus 1 }]

/-- Gouging Fire (svp-151). Records: svp-151, sv8-38. -/
def svp_151 : Card := .pokemon
  { name := "Gouging Fire", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lunge Out", cost := [.fire], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Blazing Charge", cost := [.fire, .fire, .colorless], damage := 0,
        effect := .ite (.countGe (.prizes .opp) 5) (.damage (.const 10)) (.damage (.const 17)),
        gx := false }] }

/-- Chien-Pao (svp-152). Records: svp-152, sv8-56. -/
def svp_152 : Card := .pokemon
  { name := "Chien-Pao", stage := .basic, evolvesFrom := none,
    hp := 12, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Snow Sink", use := .onPlay .bench,
        spot := none, cond := none,
        effect := .fx .discardStadium }],
    attacks := [
      { name := "Icicle Loop", cost := [.water, .water, .colorless], damage := 12,
        effect := .ite (.countGe (.energy .own .energy) 1) (.returnEnergy .own .active .energy (.exactly 1) .hand) .skip,
        gx := false }] }

/-- Magneton (svp-153). Records: svp-153, svp-159, sv8-59. Caveats: koCounters, selfBench, selfKOBench, upTo0. -/
def svp_153 : Card := .pokemon
  { name := "Magneton", stage := .stage1, evolvesFrom := some "Magnemite",
    hp := 10, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Overvolt Discharge", use := .once,
        spot := none, cond := none,
        effect := .seq (.fx (.seq (.choice (.attach .own .discard .basicEnergy .active (.ptype .lightning)) (.attach .own .discard .basicEnergy .bench (.ptype .lightning))) (.seq (.choice (.attach .own .discard .basicEnergy .active (.ptype .lightning)) (.attach .own .discard .basicEnergy .bench (.ptype .lightning))) (.choice (.attach .own .discard .basicEnergy .active (.ptype .lightning)) (.attach .own .discard .basicEnergy .bench (.ptype .lightning)))))) (.self (.counters 9999)) }],
    attacks := [
      { name := "Electric Ball", cost := [.lightning, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Wooper (svp-155). Records: svp-155. -/
def svp_155 : Card := .pokemon
  { name := "Wooper", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scoop Water", cost := [.water], damage := 0,
        effect := .move .own .discard .shuffle (.energyOf .water) (.upTo 3),
        gx := false },
      { name := "Headbutt", cost := [.water], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Zapdos (svp-157). Records: svp-157. -/
def svp_157 : Card := .pokemon
  { name := "Zapdos", stage := .basic, evolvesFrom := none,
    hp := 11, type := .lightning, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Follow-Up Bolt", cost := [.lightning, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.per .opp 1)),
        gx := false },
      { name := "Drill Peck", cost := [.lightning, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Houndstone ex (svp-162). Records: svp-162. -/
def svp_162 : Card := .pokemon
  { name := "Houndstone ex", stage := .stage1, evolvesFrom := some "Greavard",
    hp := 26, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Horrifying Fang", cost := [.psychic, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 10) (.many (.const 2))),
        gx := false }] }

/-- Cinderace ex (svp-163). Records: svp-163, sv7-28, sv7-157, me2pt5-38. Caveats: benchMods. -/
def svp_163 : Card := .pokemon
  { name := "Cinderace ex", stage := .stage2, evolvesFrom := some "Raboot",
    hp := 32, type := .fire, retreat := 0, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Flare Strike", cost := [.fire, .colorless, .colorless], damage := 28,
        effect := .skip,
        gx := false, selfLock := .this },
      { name := "Garnet Volley", cost := [.fire, .fighting, .darkness], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 18)) (.benchDamage .opp 18)) (.damage (.const 18)),
        gx := false }] }

/-- Lapras ex (svp-164). Records: svp-164, sv7-32, sv7-158. -/
def svp_164 : Card := .pokemon
  { name := "Lapras ex", stage := .basic, evolvesFrom := none,
    hp := 22, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Power Splash", cost := [.water], damage := 0,
        effect := .damage (.count (.energy .own .energy) 4),
        gx := false },
      { name := "Larimar Rain", cost := [.water, .psychic, .metal], damage := 0,
        effect := .look .own (.top 20) .energy (.upTo 20) (.attach .any) .shuffle,
        gx := false }] }

/-- Scyther (sv5-1). Records: sv5-1. -/
def sv5_1 : Card := .pokemon
  { name := "Scyther", stage := .basic, evolvesFrom := none,
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cut Up", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Slashing Strike", cost := [.colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Pineco (sv5-2). Records: sv5-2. -/
def sv5_2 : Card := .pokemon
  { name := "Pineco", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Seedot (sv5-3). Records: sv5-3. Caveats: perPokemon. -/
def sv5_3 : Card := .pokemon
  { name := "Seedot", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rigidify", cost := [.grass], damage := 0,
        effect := .linger .own .next (.reduce 3),
        gx := false },
      { name := "Hang Down", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Nuzleaf (sv5-4). Records: sv5-4. -/
def sv5_4 : Card := .pokemon
  { name := "Nuzleaf", stage := .stage1, evolvesFrom := some "Seedot",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Corkscrew Punch", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Comet Slap", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 3)) (.choice (.damage (.const 6)) (.damage (.const 9)))),
        gx := false }] }

/-- Shroomish (sv5-6). Records: sv5-6. -/
def sv5_6 : Card := .pokemon
  { name := "Shroomish", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Headbutt", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false },
      { name := "Seed Bomb", cost := [.grass, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Breloom (sv5-7). Records: sv5-7. -/
def sv5_7 : Card := .pokemon
  { name := "Breloom", stage := .stage1, evolvesFrom := some "Shroomish",
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Punch", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Knuckle Impact", cost := [.grass, .colorless], damage := 12,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Roselia (sv5-8). Records: sv5-8. Caveats: trigAttacker, trigDamaged. -/
def sv5_8 : Card := .pokemon
  { name := "Roselia", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Poison Point", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.inflict .poisoned) }],
    attacks := [
      { name := "Leaf Step", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Roserade (sv5-9). Records: sv5-9. Caveats: perPokemon, trigAttacker, trigDamaged. -/
def sv5_9 : Card := .pokemon
  { name := "Roserade", stage := .stage1, evolvesFrom := some "Roselia",
    hp := 13, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Poison Point", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.inflict .poisoned) }],
    attacks := [
      { name := "Bind Down", cost := [.colorless, .colorless], damage := 7,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Turtwig (sv5-10). Records: sv5-10. Caveats: staticBench. -/
def sv5_10 : Card := .pokemon
  { name := "Turtwig", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Solid Shell", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 2 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Leafage", cost := [.grass, .colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Grotle (sv5-11). Records: sv5-11, sv5-164. Caveats: perPokemon. -/
def sv5_11 : Card := .pokemon
  { name := "Grotle", stage := .stage1, evolvesFrom := some "Turtwig",
    hp := 12, type := .grass, retreat := 4, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cut", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Ramming Shell", cost := [.grass, .colorless, .colorless], damage := 5,
        effect := .linger .own .next (.reduce 2),
        gx := false }] }

/-- Torterra ex (sv5-12). Records: sv5-12, sv5-185. -/
def sv5_12 : Card := .pokemon
  { name := "Torterra ex", stage := .stage2, evolvesFrom := some "Grotle",
    hp := 34, type := .grass, retreat := 4, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Forest March", cost := [.grass], damage := 0,
        effect := .damage (.count (.inPlay .own (.ptype .grass)) 3),
        gx := false },
      { name := "Jungle Hammer", cost := [.grass, .colorless, .colorless], damage := 15,
        effect := .heal 5,
        gx := false }] }

/-- Shaymin (sv5-13). Records: sv5-13. Caveats: benchMods. -/
def sv5_13 : Card := .pokemon
  { name := "Shaymin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 0, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pinpoint Dive", cost := [.grass], damage := 0,
        effect := .benchSome .opp 1 .ex true 6,
        gx := false },
      { name := "Rear Kick", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Cottonee (sv5-14). Records: sv5-14, sv8pt5-7. -/
def sv5_14 : Card := .pokemon
  { name := "Cottonee", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Triple Spin", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.choice (.damage (.const 2)) (.damage (.const 3)))),
        gx := false }] }

/-- Deerling (sv5-16). Records: sv5-16, sv5-165. Caveats: energyOfBasic, energyOfCount. -/
def sv5_16 : Card := .pokemon
  { name := "Deerling", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flop", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Leaf Litter Tackle", cost := [.grass, .colorless, .colorless], damage := 4,
        effect := .ite (.countGe (.energy .own (.energyOf .grass)) 1) (.discardEnergy .own .active (.energyOf .grass) (.exactly 1)) .skip,
        gx := false }] }

/-- Sawsbuck (sv5-17). Records: sv5-17, sv5-166. -/
def sv5_17 : Card := .pokemon
  { name := "Sawsbuck", stage := .stage1, evolvesFrom := some "Deerling",
    hp := 13, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Changing Seasons", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.kind .stadium) (.upTo 1)) .shuffle)) }],
    attacks := [
      { name := "Superpowered Horns", cost := [.grass, .colorless, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Grubbin (sv5-18). Records: sv5-18. -/
def sv5_18 : Card := .pokemon
  { name := "Grubbin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flock", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck (.named "Grubbin")) (.putBench .own .deck (.named "Grubbin"))) .shuffle,
        gx := false },
      { name := "Vise Grip", cost := [.colorless, .colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Dhelmise (sv5-19). Records: sv5-19. -/
def sv5_19 : Card := .pokemon
  { name := "Dhelmise", stage := .basic, evolvesFrom := none,
    hp := 13, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spinning Attack", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Steel Anchor", cost := [.grass, .grass, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .own (.ptype .metal)) 1) (.damage (.const 16)) (.damage (.const 8)),
        gx := false }] }

/-- Bramblin (sv5-20). Records: sv5-20. -/
def sv5_20 : Card := .pokemon
  { name := "Bramblin", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spike Sting", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Scovillain ex (sv5-22). Records: sv5-22. Caveats: perPokemon. -/
def sv5_22 : Card := .pokemon
  { name := "Scovillain ex", stage := .stage1, evolvesFrom := some "Capsakid",
    hp := 26, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Chili Snapper Bind", cost := [.colorless], damage := 0,
        effect := .seq (.inflict .burned) (.linger .opp .next (.lock .retreat)),
        gx := false },
      { name := "Two-Headed Crushing", cost := [.grass, .grass], damage := 14,
        effect := .seq (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip) (.move .opp (.top 1) .discard .any .all),
        gx := false }] }

/-- Rellor (sv5-23). Records: sv5-23. Caveats: recoil. -/
def sv5_23 : Card := .pokemon
  { name := "Rellor", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slight Intrusion", cost := [.colorless], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Rabsca (sv5-24). Records: sv5-24. Caveats: energyUnitsCount, shieldBench. -/
def sv5_24 : Card := .pokemon
  { name := "Rabsca", stage := .stage1, evolvesFrom := some "Rellor",
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Spherical Shield", use := .static [{ sel := .own, filt := .any, tgt := some .bench, src := none, need := none, eff := .prevent .any }, { sel := .own, filt := .any, tgt := some .bench, src := none, need := none, eff := .shield .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Psychic", cost := [.grass], damage := 0,
        effect := .damage (.add (.const 1) (.count (.energy .opp .energy) 3)),
        gx := false }] }

/-- Ponyta (sv5-26). Records: sv5-26. -/
def sv5_26 : Card := .pokemon
  { name := "Ponyta", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Charge Energy", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .basicEnergy (.upTo 1)) .shuffle,
        gx := false },
      { name := "Flame Tail", cost := [.fire, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Rapidash (sv5-27). Records: sv5-27. Caveats: recoil. -/
def sv5_27 : Card := .pokemon
  { name := "Rapidash", stage := .stage1, evolvesFrom := some "Ponyta",
    hp := 11, type := .fire, retreat := 0, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Combustion", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Inferno Onrush", cost := [.fire, .colorless], damage := 12,
        effect := .selfDamage 3,
        gx := false }] }

/-- Slugma (sv5-28). Records: sv5-28. -/
def sv5_28 : Card := .pokemon
  { name := "Slugma", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Roasting Heat", cost := [.fire], damage := 0,
        effect := .ite (.cond .opp .burned) (.damage (.const 5)) (.damage (.const 1)),
        gx := false }] }

/-- Magcargo (sv5-29). Records: sv5-29. Caveats: trigBenched. -/
def sv5_29 : Card := .pokemon
  { name := "Magcargo", stage := .stage1, evolvesFrom := some "Slugma",
    hp := 12, type := .fire, retreat := 4, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Lava Zone", use := .triggered .oppBenched false,
        spot := none, cond := none,
        effect := .fx (.inflict .burned) }],
    attacks := [
      { name := "Heat Blast", cost := [.fire, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Victini (sv5-30). Records: sv5-30. -/
def sv5_30 : Card := .pokemon
  { name := "Victini", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flippity Flap", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .hand .shuffle .any .all) (.move .own (.top 6) .hand .any .all),
        gx := false },
      { name := "Singe Off", cost := [.fire], damage := 3,
        effect := .ite (.countGe (.energy .opp .specialEnergy) 1) (.discardEnergy .opp .active .specialEnergy (.exactly 1)) .skip,
        gx := false }] }

/-- Litten (sv5-32). Records: sv5-32, sv5-167. -/
def sv5_32 : Card := .pokemon
  { name := "Litten", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fake Out", cost := [.fire], damage := 1,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Torracat (sv5-33). Records: sv5-33. -/
def sv5_33 : Card := .pokemon
  { name := "Torracat", stage := .stage1, evolvesFrom := some "Litten",
    hp := 10, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.fire], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Flare Strike", cost := [.fire, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Turtonator (sv5-35). Records: sv5-35. Caveats: benchMods. -/
def sv5_35 : Card := .pokemon
  { name := "Turtonator", stage := .basic, evolvesFrom := none,
    hp := 12, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spit-Out Shot", cost := [.fire, .colorless], damage := 0,
        effect := .benchDamage .opp 4,
        gx := false },
      { name := "Steam Artillery", cost := [.fire, .fire, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Sizzlipede (sv5-36). Records: sv5-36. Caveats: recoil. -/
def sv5_36 : Card := .pokemon
  { name := "Sizzlipede", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Heat Dive", cost := [.fire], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Centiskorch (sv5-37). Records: sv5-37. -/
def sv5_37 : Card := .pokemon
  { name := "Centiskorch", stage := .stage1, evolvesFrom := some "Sizzlipede",
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Singe", cost := [.fire], damage := 0,
        effect := .inflict .burned,
        gx := false },
      { name := "Charring Breath", cost := [.fire, .fire], damage := 0,
        effect := .ite (.cond .opp .burned) (.damage (.const 18)) .skip,
        gx := false }] }

/-- Totodile (sv5-39). Records: sv5-39. Caveats: perPokemon. -/
def sv5_39 : Card := .pokemon
  { name := "Totodile", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Big Bite", cost := [.water], damage := 1,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Croconaw (sv5-40). Records: sv5-40. -/
def sv5_40 : Card := .pokemon
  { name := "Croconaw", stage := .stage1, evolvesFrom := some "Totodile",
    hp := 9, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reverse Thrust", cost := [.water], damage := 3,
        effect := .switch .own,
        gx := false }] }

/-- Carvanha (sv5-42). Records: sv5-42. -/
def sv5_42 : Card := .pokemon
  { name := "Carvanha", stage := .basic, evolvesFrom := none,
    hp := 5, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wave Splash", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Sharpedo (sv5-43). Records: sv5-43. -/
def sv5_43 : Card := .pokemon
  { name := "Sharpedo", stage := .stage1, evolvesFrom := some "Carvanha",
    hp := 12, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Chew Off", cost := [.colorless, .colorless], damage := 5,
        effect := .choice .skip (.choice (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip) (.choice (.seq (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip) (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip)) (.seq (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip) (.seq (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip) (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip))))),
        gx := false },
      { name := "Jet Headbutt", cost := [.water, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Keldeo (sv5-44). Records: sv5-44. -/
def sv5_44 : Card := .pokemon
  { name := "Keldeo", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rapid Draw", cost := [.water], damage := 2,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Aqua Blade", cost := [.water, .water, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Snom (sv5-45). Records: sv5-45, sv5-168. -/
def sv5_45 : Card := .pokemon
  { name := "Snom", stage := .basic, evolvesFrom := none,
    hp := 5, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Powder Snow", cost := [.water], damage := 1,
        effect := .inflict .asleep,
        gx := false }] }

/-- Frosmoth (sv5-46). Records: sv5-46. Caveats: perPokemon. -/
def sv5_46 : Card := .pokemon
  { name := "Frosmoth", stage := .stage1, evolvesFrom := some "Snom",
    hp := 11, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Freezing Chill", cost := [.water, .water], damage := 10,
        effect := .linger .opp .next (.lock .attack),
        gx := false }] }

/-- Wiglett (sv5-47). Records: sv5-47. Caveats: recoil. -/
def sv5_47 : Card := .pokemon
  { name := "Wiglett", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lucky Find", cost := [.water], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .item) (.upTo 1)) .shuffle,
        gx := false },
      { name := "Aqua Bomb", cost := [.water, .water], damage := 4,
        effect := .selfDamage 2,
        gx := false }] }

/-- Finizen (sv5-48). Records: sv5-48. -/
def sv5_48 : Card := .pokemon
  { name := "Finizen", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rain Splash", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Sharp Fin", cost := [.water, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Palafin (sv5-49). Records: sv5-49. Caveats: recoil. -/
def sv5_49 : Card := .pokemon
  { name := "Palafin", stage := .stage1, evolvesFrom := some "Finizen",
    hp := 15, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Vanguard Punch", cost := [.water], damage := 13,
        effect := .hitBy .own .active 1 .any false false (.per 1),
        gx := false },
      { name := "Double Hit", cost := [.water, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 9)) (.damage (.const 18))),
        gx := false }] }

/-- Pikachu (sv5-51). Records: sv5-51. Caveats: benchMods. -/
def sv5_51 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Random Spark", cost := [.lightning], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 1)) (.benchDamage .opp 1)) (.damage (.const 1)),
        gx := false }] }

/-- Raichu (sv5-52). Records: sv5-52. Caveats: benchMods. -/
def sv5_52 : Card := .pokemon
  { name := "Raichu", stage := .stage1, evolvesFrom := some "Pikachu",
    hp := 13, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collateral Bolts", cost := [.lightning, .colorless], damage := 0,
        effect := .seq (.ite (.atLeast .opp 1) (.damage (.const 5)) .skip) (.seq (.hitBy .opp .bench 5 .any true true (.const 5)) (.hitBy .own .bench 5 .any true true (.const 5))),
        gx := false },
      { name := "Electric Ball", cost := [.lightning, .colorless, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Electabuzz (sv5-53). Records: sv5-53. -/
def sv5_53 : Card := .pokemon
  { name := "Electabuzz", stage := .basic, evolvesFrom := none,
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Chop", cost := [.lightning], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Electric Punch", cost := [.lightning, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Electivire (sv5-54). Records: sv5-54. -/
def sv5_54 : Card := .pokemon
  { name := "Electivire", stage := .stage1, evolvesFrom := some "Electabuzz",
    hp := 14, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Short-Circuit Knuckle", cost := [.colorless, .colorless], damage := 0,
        effect := .ite (.isType .opp .water) (.damage (.const 16)) (.ite (.countGe (.bench .opp (.ptype .water)) 1) (.damage (.const 16)) (.damage (.const 4))),
        gx := false },
      { name := "Electroslug", cost := [.lightning, .lightning, .colorless, .colorless], damage := 14,
        effect := .skip,
        gx := false }] }

/-- Charjabug (sv5-55). Records: sv5-55, sv5-169, me2pt5-65. -/
def sv5_55 : Card := .pokemon
  { name := "Charjabug", stage := .stage1, evolvesFrom := some "Grubbin",
    hp := 10, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Static Shock", cost := [.lightning, .lightning], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Vikavolt (sv5-56). Records: sv5-56. -/
def sv5_56 : Card := .pokemon
  { name := "Vikavolt", stage := .stage2, evolvesFrom := some "Charjabug",
    hp := 16, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mach Bolt", cost := [.lightning], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Circuit Cannon", cost := [.lightning, .lightning], damage := 0,
        effect := .damage (.add (.const 12) (.count (.bench .own (.named "Charjabug")) 8)),
        gx := false }] }

/-- Zeraora (sv5-57). Records: sv5-57. -/
def sv5_57 : Card := .pokemon
  { name := "Zeraora", stage := .basic, evolvesFrom := none,
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shocking Knuckle", cost := [.colorless], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Strong Volt", cost := [.lightning, .lightning, .colorless], damage := 12,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Yamper (sv5-58). Records: sv5-58. -/
def sv5_58 : Card := .pokemon
  { name := "Yamper", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Whimsy Tackle", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 2)) .skip,
        gx := false }] }

/-- Boltund (sv5-59). Records: sv5-59. -/
def sv5_59 : Card := .pokemon
  { name := "Boltund", stage := .stage1, evolvesFrom := some "Yamper",
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electrifying Dash", cost := [.colorless], damage := 5,
        effect := .seq (.seq (.attach .own .deck (.energyOf .lightning) .bench .any) (.attach .own .deck (.energyOf .lightning) .bench .any)) .shuffle,
        gx := false }] }

/-- Iron Hands (sv5-61). Records: sv5-61. -/
def sv5_61 : Card := .pokemon
  { name := "Iron Hands", stage := .basic, evolvesFrom := none,
    hp := 14, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Volt Wave", cost := [.lightning, .colorless], damage := 3,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Superalloy Hands", cost := [.lightning, .lightning, .colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 16)) (.damage (.const 8)),
        gx := false }] }

/-- Marill (sv5-64). Records: sv5-64. -/
def sv5_64 : Card := .pokemon
  { name := "Marill", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ball Roll", cost := [.colorless], damage := 0,
        effect := .damage (.many (.const 1)),
        gx := false },
      { name := "Magical Shot", cost := [.psychic, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Azumarill (sv5-65). Records: sv5-65. -/
def sv5_65 : Card := .pokemon
  { name := "Azumarill", stage := .stage1, evolvesFrom := some "Marill",
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Play Rough", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 6)) (.damage (.const 3)),
        gx := false },
      { name := "Power Tackle", cost := [.psychic, .colorless, .colorless], damage := 14,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Girafarig (sv5-66). Records: sv5-66. -/
def sv5_66 : Card := .pokemon
  { name := "Girafarig", stage := .basic, evolvesFrom := none,
    hp := 9, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Psychic Assault", cost := [.psychic, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.per .opp 1)),
        gx := false }] }

/-- Latias (sv5-67). Records: sv5-67. -/
def sv5_67 : Card := .pokemon
  { name := "Latias", stage := .basic, evolvesFrom := none,
    hp := 11, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Allure", cost := [.colorless], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Lagoon Flight", cost := [.psychic, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Bronzor (sv5-68). Records: sv5-68, sv5-170. -/
def sv5_68 : Card := .pokemon
  { name := "Bronzor", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mirror Attack", cost := [.psychic], damage := 0,
        effect := .ite (.isType .opp .psychic) (.damage (.const 4)) (.damage (.const 1)),
        gx := false }] }

/-- Solosis (sv5-70). Records: sv5-70. -/
def sv5_70 : Card := .pokemon
  { name := "Solosis", stage := .basic, evolvesFrom := none,
    hp := 4, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Surprise Attack", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Duosion (sv5-71). Records: sv5-71. -/
def sv5_71 : Card := .pokemon
  { name := "Duosion", stage := .stage1, evolvesFrom := some "Solosis",
    hp := 8, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Trick", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 3)) (.damage (.const 6))),
        gx := false }] }

/-- Reuniclus (sv5-72). Records: sv5-72, sv5-171. -/
def sv5_72 : Card := .pokemon
  { name := "Reuniclus", stage := .stage2, evolvesFrom := some "Duosion",
    hp := 12, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Summoning Gate", cost := [.colorless], damage := 0,
        effect := .look .own (.top 8) .pokemon (.upTo 8) .bench .shuffle,
        gx := false },
      { name := "Brain Shake", cost := [.psychic, .colorless], damage := 10,
        effect := .inflict .confused,
        gx := false }] }

/-- Elgyem (sv5-73). Records: sv5-73. Caveats: perPokemon, shieldReach. -/
def sv5_73 : Card := .pokemon
  { name := "Elgyem", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hide", cost := [.psychic], damage := 0,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false }] }

/-- Beheeyem (sv5-74). Records: sv5-74. -/
def sv5_74 : Card := .pokemon
  { name := "Beheeyem", stage := .stage1, evolvesFrom := some "Elgyem",
    hp := 10, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cosmic Beatdown", cost := [.psychic], damage := 0,
        effect := .damage (.add (.const 2) (.count (.bench .own .pokemon) 2)),
        gx := false }] }

/-- Cutiefly (sv5-75). Records: sv5-75, sv5-172. -/
def sv5_75 : Card := .pokemon
  { name := "Cutiefly", stage := .basic, evolvesFrom := none,
    hp := 3, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mini Drain", cost := [.colorless], damage := 1,
        effect := .heal 1,
        gx := false }] }

/-- Scream Tail (sv5-77). Records: sv5-77. -/
def sv5_77 : Card := .pokemon
  { name := "Scream Tail", stage := .basic, evolvesFrom := none,
    hp := 9, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Supportive Singing", cost := [.colorless], damage := 0,
        effect := .benchHealSome 1 (.and .pokemon (.or (.or (.or (.nameIn ["Ancient Booster Energy Capsule", "Awakening Drum", "Brute Bonnet", "Explorer's Guidance", "Flutter Mane", "Gouging Fire", "Gouging Fire ex", "Great Tusk", "Raging Bolt", "Raging Bolt ex", "Roaring Moon", "Sandy Shocks", "Scream Tail", "Scream Tail ex", "Slither Wing", "Walking Wake", "Walking Wake ex"]) (.and (.named "Koraidon") (.hasAttack "Primordial Beatdown"))) (.and (.named "Koraidon") (.hasAttack "Unrelenting Onslaught"))) (.and (.named "Koraidon ex") (.hasAttack "Retribution Strike")))) (some 10),
        gx := false },
      { name := "Hyper Voice", cost := [.colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Iron Valiant (sv5-79). Records: sv5-79. Caveats: benchMods. -/
def sv5_79 : Card := .pokemon
  { name := "Iron Valiant", stage := .basic, evolvesFrom := none,
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gemini Laser", cost := [.colorless], damage := 2,
        effect := .benchDamage .opp 2,
        gx := false },
      { name := "Zen Blade", cost := [.psychic, .psychic, .colorless], damage := 12,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Iron Valiant (sv5-80). Records: sv5-80. -/
def sv5_80 : Card := .pokemon
  { name := "Iron Valiant", stage := .basic, evolvesFrom := none,
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Calculation", cost := [.psychic], damage := 0,
        effect := .look .own (.top 4) .any (.exactly 0) (.put .top) .top,
        gx := false },
      { name := "Majestic Sword", cost := [.psychic, .psychic, .colorless], damage := 0,
        effect := .ite (.countGe (.played .own (.and (.kind .supporter) (.or (.or (.or (.nameIn ["Ciphermaniac's Codebreaking", "Future Booster Energy Capsule", "Iron Boulder", "Iron Boulder ex", "Iron Bundle", "Iron Crown", "Iron Crown ex", "Iron Hands", "Iron Jugulis", "Iron Leaves", "Iron Leaves ex", "Iron Moth", "Iron Thorns", "Iron Thorns ex", "Iron Treads", "Iron Valiant", "Reboot Pod"]) (.and (.named "Miraidon") (.hasAttack "Peak Acceleration"))) (.and (.named "Miraidon") (.hasAttack "C.O.D.E.: Protect"))) (.and (.named "Miraidon ex") (.hasAttack "Repulsion Bolt"))))) 1) (.damage (.const 20)) (.damage (.const 10)),
        gx := false }] }

/-- Meditite (sv5-82). Records: sv5-82. -/
def sv5_82 : Card := .pokemon
  { name := "Meditite", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slap", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Kick", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Medicham (sv5-83). Records: sv5-83. -/
def sv5_83 : Card := .pokemon
  { name := "Medicham", stage := .stage1, evolvesFrom := some "Meditite",
    hp := 12, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Low Sweep", cost := [.fighting], damage := 4,
        effect := .skip,
        gx := false },
      { name := "High Jump Kick", cost := [.colorless, .colorless, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Drilbur (sv5-85). Records: sv5-85. Caveats: upTo0. -/
def sv5_85 : Card := .pokemon
  { name := "Drilbur", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Dig Dig Dig", use := .onPlay .bench,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .deck .discard (.energyOf .fighting) (.upTo 3)) .shuffle) }],
    attacks := [
      { name := "Sand Spray", cost := [.fighting, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Excadrill (sv5-86). Records: sv5-86, sv5-174. Caveats: recoil. -/
def sv5_86 : Card := .pokemon
  { name := "Excadrill", stage := .stage1, evolvesFrom := some "Drilbur",
    hp := 13, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mud Shot", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Wild Tackle", cost := [.fighting, .fighting, .colorless], damage := 18,
        effect := .selfDamage 5,
        gx := false }] }

/-- Golett (sv5-87). Records: sv5-87. Caveats: perPokemon. -/
def sv5_87 : Card := .pokemon
  { name := "Golett", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Iron Defense", cost := [.fighting], damage := 0,
        effect := .choice (.linger .own .next .prevent) .skip,
        gx := false },
      { name := "Punch", cost := [.colorless, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Golurk (sv5-88). Records: sv5-88. Caveats: perPokemon. -/
def sv5_88 : Card := .pokemon
  { name := "Golurk", stage := .stage1, evolvesFrom := some "Golett",
    hp := 16, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Iron Defense", cost := [.fighting], damage := 0,
        effect := .choice (.linger .own .next .prevent) .skip,
        gx := false },
      { name := "Fighting Fist", cost := [.colorless, .colorless, .colorless, .colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 24)) (.damage (.const 12)),
        gx := false }] }

/-- Rockruff (sv5-89). Records: sv5-89. -/
def sv5_89 : Card := .pokemon
  { name := "Rockruff", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Paw Shake Punch", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Lycanroc (sv5-90). Records: sv5-90. -/
def sv5_90 : Card := .pokemon
  { name := "Lycanroc", stage := .stage1, evolvesFrom := some "Rockruff",
    hp := 12, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Turbo Edge", cost := [.colorless], damage := 5,
        effect := .seq (.attach .own .discard (.energyOf .fighting) .bench .any) (.attach .own .discard (.energyOf .fighting) .bench .any),
        gx := false }] }

/-- Mudbray (sv5-91). Records: sv5-91. -/
def sv5_91 : Card := .pokemon
  { name := "Mudbray", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smash Kick", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Mud-Slap", cost := [.fighting, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Rolycoly (sv5-93). Records: sv5-93. -/
def sv5_93 : Card := .pokemon
  { name := "Rolycoly", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Tackle", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Power Gem", cost := [.fighting, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Carkol (sv5-94). Records: sv5-94. -/
def sv5_94 : Card := .pokemon
  { name := "Carkol", stage := .stage1, evolvesFrom := some "Rolycoly",
    hp := 11, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knock Away", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 6)) (.damage (.const 2)),
        gx := false },
      { name := "Boulder Crush", cost := [.fighting, .colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Coalossal (sv5-95). Records: sv5-95. Caveats: energyOfCount. -/
def sv5_95 : Card := .pokemon
  { name := "Coalossal", stage := .stage2, evolvesFrom := some "Carkol",
    hp := 18, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gatling Tar", cost := [.fighting], damage := 0,
        effect := .damage (.add (.const 4) (.count (.energy .own (.energyOf .fire)) 8)),
        gx := false },
      { name := "Cragalanche", cost := [.fighting, .colorless, .colorless, .colorless], damage := 15,
        effect := .move .opp (.top 2) .discard .any .all,
        gx := false }] }

/-- Sandy Shocks (sv5-98). Records: sv5-98. Caveats: energyUnitsCount. -/
def sv5_98 : Card := .pokemon
  { name := "Sandy Shocks", stage := .basic, evolvesFrom := none,
    hp := 12, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Magnetic Burst", cost := [.fighting], damage := 0,
        effect := .ite (.countGe (.energyAll .own .energy) 3) (.damage (.const 9) { weak := true }) (.damage (.const 2) { weak := true }),
        gx := false },
      { name := "Power Gem", cost := [.fighting, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Ekans (sv5-100). Records: sv5-100. -/
def sv5_100 : Card := .pokemon
  { name := "Ekans", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Blend", cost := [.darkness], damage := 0,
        effect := .choice (.seq (.inflict .confused) (.inflict .poisoned)) .skip,
        gx := false },
      { name := "Bite", cost := [.darkness, .darkness], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Arbok (sv5-101). Records: sv5-101, sv5-176. -/
def sv5_101 : Card := .pokemon
  { name := "Arbok", stage := .stage1, evolvesFrom := some "Ekans",
    hp := 13, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Panic Poison", cost := [.darkness], damage := 0,
        effect := .seq (.inflict .burned) (.seq (.inflict .confused) (.inflict .poisoned)),
        gx := false },
      { name := "Darkness Fang", cost := [.darkness, .darkness], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Gastly (sv5-102). Records: sv5-102, sv5-177. -/
def sv5_102 : Card := .pokemon
  { name := "Gastly", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mysterious Beam", cost := [.darkness], damage := 0,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false },
      { name := "Suffocating Gas", cost := [.darkness, .darkness], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Haunter (sv5-103). Records: sv5-103. -/
def sv5_103 : Card := .pokemon
  { name := "Haunter", stage := .stage1, evolvesFrom := some "Gastly",
    hp := 9, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Super Poison Breath", cost := [.darkness, .darkness], damage := 3,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Poochyena (sv5-105). Records: sv5-105, me2pt5-128. -/
def sv5_105 : Card := .pokemon
  { name := "Poochyena", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw Off", cost := [.darkness, .colorless], damage := 0,
        effect := .choice (.damage (.const 5)) (.damage (.const 3)),
        gx := false }] }

/-- Mightyena (sv5-106). Records: sv5-106, me2pt5-129, me2pt5-243. -/
def sv5_106 : Card := .pokemon
  { name := "Mightyena", stage := .stage1, evolvesFrom := some "Poochyena",
    hp := 12, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Kick Away", cost := [.darkness, .colorless], damage := 5,
        effect := .switch .opp,
        gx := false },
      { name := "Sharp Fang", cost := [.darkness, .darkness, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Farigiraf ex (sv5-108). Records: sv5-108, sv5-194. Caveats: benchMods. -/
def sv5_108 : Card := .pokemon
  { name := "Farigiraf ex", stage := .stage1, evolvesFrom := some "Girafarig",
    hp := 26, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [
      { name := "Armor Tail", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .prevent (.and .basic .ex) }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Dirty Beam", cost := [.psychic, .colorless, .colorless], damage := 16,
        effect := .benchDamage .opp 3,
        gx := false }] }

/-- Roaring Moon (sv5-109). Records: sv5-109, sv8pt5-65. -/
def sv5_109 : Card := .pokemon
  { name := "Roaring Moon", stage := .basic, evolvesFrom := none,
    hp := 14, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Vengeance Fletching", cost := [.darkness, .darkness], damage := 0,
        effect := .damage (.add (.const 7) (.count (.pile .own .discard (.and .any (.or (.or (.or (.nameIn ["Ancient Booster Energy Capsule", "Awakening Drum", "Brute Bonnet", "Explorer's Guidance", "Flutter Mane", "Gouging Fire", "Gouging Fire ex", "Great Tusk", "Raging Bolt", "Raging Bolt ex", "Roaring Moon", "Sandy Shocks", "Scream Tail", "Scream Tail ex", "Slither Wing", "Walking Wake", "Walking Wake ex"]) (.and (.named "Koraidon") (.hasAttack "Primordial Beatdown"))) (.and (.named "Koraidon") (.hasAttack "Unrelenting Onslaught"))) (.and (.named "Koraidon ex") (.hasAttack "Retribution Strike"))))) 1)),
        gx := false },
      { name := "Speed Wing", cost := [.darkness, .colorless, .colorless, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Forretress (sv5-110). Records: sv5-110. Caveats: recoil. -/
def sv5_110 : Card := .pokemon
  { name := "Forretress", stage := .stage1, evolvesFrom := some "Pineco",
    hp := 13, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spike Cannon", cost := [.metal], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 3)) (.choice (.damage (.const 6)) (.damage (.const 9)))),
        gx := false },
      { name := "Steel Tackle", cost := [.colorless, .colorless, .colorless], damage := 13,
        effect := .selfDamage 4,
        gx := false }] }

/-- Mawile (sv5-112). Records: sv5-112. -/
def sv5_112 : Card := .pokemon
  { name := "Mawile", stage := .basic, evolvesFrom := none,
    hp := 9, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Invite and Strike", cost := [.colorless, .colorless], damage := 0,
        effect := .seq (.switch .opp) (.ite (.countGe (.bench .opp .pokemon) 1) (.damage (.const 3)) .skip),
        gx := false },
      { name := "Sharp Fang", cost := [.metal, .metal, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Beldum (sv5-113). Records: sv5-113. Caveats: recoil. -/
def sv5_113 : Card := .pokemon
  { name := "Beldum", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dig Claws", cost := [.metal], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Iron Tackle", cost := [.metal, .colorless, .colorless], damage := 5,
        effect := .selfDamage 1,
        gx := false }] }

/-- Metagross (sv5-115). Records: sv5-115, sv5-178. Caveats: discardUnits. -/
def sv5_115 : Card := .pokemon
  { name := "Metagross", stage := .stage2, evolvesFrom := some "Metang",
    hp := 18, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Meteor Mash", cost := [.metal], damage := 0,
        effect := .ite (.usedLast .own) (.damage (.const 12)) (.damage (.const 6)),
        gx := false, selfLock := .note },
      { name := "Luster Blast", cost := [.metal, .colorless, .colorless, .colorless], damage := 20,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Meltan (sv5-116). Records: sv5-116, sv5-179. -/
def sv5_116 : Card := .pokemon
  { name := "Meltan", stage := .basic, evolvesFrom := none,
    hp := 8, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.metal, .metal], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Melmetal (sv5-117). Records: sv5-117. -/
def sv5_117 : Card := .pokemon
  { name := "Melmetal", stage := .stage1, evolvesFrom := some "Meltan",
    hp := 16, type := .metal, retreat := 4, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hammer In", cost := [.metal, .metal, .colorless], damage := 12,
        effect := .skip,
        gx := false },
      { name := "Iron Bash", cost := [.metal, .metal, .metal, .metal, .colorless], damage := 23,
        effect := .skip,
        gx := false }] }

/-- Koraidon ex (sv5-120). Records: sv5-120. Caveats: recoil. -/
def sv5_120 : Card := .pokemon
  { name := "Koraidon ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Retribution Strike", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.per .own 1)),
        gx := false },
      { name := "Kaiser Tackle", cost := [.fire, .fighting, .fighting], damage := 28,
        effect := .selfDamage 6,
        gx := false }] }

/-- Miraidon ex (sv5-122). Records: sv5-122. -/
def sv5_122 : Card := .pokemon
  { name := "Miraidon ex", stage := .basic, evolvesFrom := none,
    hp := 22, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Repulsion Bolt", cost := [.lightning, .psychic], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 16)) (.damage (.const 6)),
        gx := false },
      { name := "Cyber Drive", cost := [.lightning, .psychic, .colorless], damage := 22,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Lickitung (sv5-124). Records: sv5-124, sv5-180. Caveats: oppBenchFresh. -/
def sv5_124 : Card := .pokemon
  { name := "Lickitung", stage := .basic, evolvesFrom := none,
    hp := 10, type := .colorless, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tongue Pull", cost := [.colorless], damage := 0,
        effect := .look .opp .hand .basic (.upTo 2) .bench .hand,
        gx := false },
      { name := "Strength", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Lickilicky (sv5-125). Records: sv5-125. -/
def sv5_125 : Card := .pokemon
  { name := "Lickilicky", stage := .stage1, evolvesFrom := some "Lickitung",
    hp := 15, type := .colorless, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Body Slam", cost := [.colorless, .colorless], damage := 5,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Tonguenado", cost := [.colorless, .colorless, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 7)) (.choice (.damage (.const 14)) (.choice (.damage (.const 21)) (.damage (.const 28))))),
        gx := false }] }

/-- Hoothoot (sv5-126). Records: sv5-126. Caveats: hiddenInfo. -/
def sv5_126 : Card := .pokemon
  { name := "Hoothoot", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Silent Wing", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Noctowl (sv5-127). Records: sv5-127. Caveats: searchAny. -/
def sv5_127 : Card := .pokemon
  { name := "Noctowl", stage := .stage1, evolvesFrom := some "Hoothoot",
    hp := 11, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Talon Hunt", cost := [.colorless, .colorless], damage := 7,
        effect := .seq (.move .own .deck .hand .any (.upTo 2)) .shuffle,
        gx := false }] }

/-- Dunsparce (sv5-128). Records: sv5-128, sv8pt5-79. Caveats: perPokemon, shieldReach. -/
def sv5_128 : Card := .pokemon
  { name := "Dunsparce", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Dig", cost := [.colorless, .colorless], damage := 3,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
        gx := false }] }

/-- Skitty (sv5-130). Records: sv5-130. -/
def sv5_130 : Card := .pokemon
  { name := "Skitty", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.putBench .own .deck .basic) .shuffle,
        gx := false },
      { name := "Tackle", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Delcatty (sv5-131). Records: sv5-131. -/
def sv5_131 : Card := .pokemon
  { name := "Delcatty", stage := .stage1, evolvesFrom := some "Skitty",
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tail Trickery", cost := [.colorless], damage := 3,
        effect := .inflict .confused,
        gx := false },
      { name := "Energy Blender", cost := [.colorless, .colorless, .colorless], damage := 11,
        effect := .iter (.moveEnergy .own .energy),
        gx := false }] }

/-- Chatot (sv5-132). Records: sv5-132, sv5-181. -/
def sv5_132 : Card := .pokemon
  { name := "Chatot", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "A Cappella", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic))) .shuffle,
        gx := false },
      { name := "Gust", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Tranquill (sv5-134). Records: sv5-134. -/
def sv5_134 : Card := .pokemon
  { name := "Tranquill", stage := .stage1, evolvesFrom := some "Pidove",
    hp := 8, type := .colorless, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Speed Dive", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Jet Wing", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Unfezant (sv5-135). Records: sv5-135. Caveats: moveUnits. -/
def sv5_135 : Card := .pokemon
  { name := "Unfezant", stage := .stage2, evolvesFrom := some "Tranquill",
    hp := 15, type := .colorless, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Opposing Winds", cost := [.colorless, .colorless], damage := 7,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 2) (.returnEnergy .opp .active .energy (.exactly 2) .hand) (.returnEnergy .opp .active .energy .all .hand)) .skip,
        gx := false },
      { name := "Boundless Power", cost := [.colorless, .colorless, .colorless], damage := 18,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Cinccino (sv5-137). Records: sv5-137, sv5-183. -/
def sv5_137 : Card := .pokemon
  { name := "Cinccino", stage := .stage1, evolvesFrom := some "Minccino",
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Special Roll", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.energy .own .specialEnergy) 7),
        gx := false }] }

/-- Iron Jugulis (sv5-139). Records: sv5-139. Caveats: trigAttacker, trigDamaged. -/
def sv5_139 : Card := .pokemon
  { name := "Iron Jugulis", stage := .basic, evolvesFrom := none,
    hp := 13, type := .colorless, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Automated Combat", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.counters 3) }],
    attacks := [
      { name := "Blasting Wind", cost := [.colorless, .colorless, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Buddy-Buddy Poffin (sv5-144). Records: sv5-144, sv6-223, sv8pt5-101, me1-167, me2pt5-184. Caveats: upTo0. -/
def sv5_144 : Card := .trainer "Buddy-Buddy Poffin" .item
    (.seq (.ite (.countGe (.bench .own .pokemon) 5) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.seq (.putBench .own .deck (.and .basic (.hpLe 7))) (.putBench .own .deck (.and .basic (.hpLe 7)))) .shuffle)))

/-- Ciphermaniac's Codebreaking (sv5-145). Records: sv5-145, sv5-198, sv8pt5-104. -/
def sv5_145 : Card := .trainer "Ciphermaniac's Codebreaking" .supporter
    (.seq .shuffle (.ite (.countGe (.pile .own .deck .any) 2) (.move .own .deck .top .any (.exactly 2)) (.ite (.countGe (.pile .own .deck .any) 1) (.move .own .deck .top .any .all) (.move .own .deck .top .any (.exactly 1)))))

/-- Eri (sv5-146). Records: sv5-146, sv5-199, sv5-210, sv8pt5-136. -/
def sv5_146 : Card := .trainer "Eri" .supporter
    (.seq (.ite (.countGe (.pile .opp .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.move .opp .hand .discard (.kind .item) (.most 1)) (.move .opp .hand .discard (.kind .item) (.most 2))))

/-- Explorer's Guidance (sv5-147). Records: sv5-147, sv5-200, sv8pt5-107. -/
def sv5_147 : Card := .trainer "Explorer's Guidance" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 2) (.move .own (.top 6) .hand .any (.exactly 2)) (.ite (.countGe (.pile .own .deck .any) 1) (.move .own (.top 6) .hand .any .all) (.move .own (.top 6) .hand .any (.exactly 1)))) (.move .own (.top 4) .discard .any .all))

/-- The cards of this part. -/
def cards : List Card := [
  base1_97,
  base1_98,
  base1_99,
  base1_100,
  base1_101,
  base1_102,
  dp1_129,
  dp1_130,
  xy1_140,
  svp_87,
  svp_89,
  svp_90,
  svp_91,
  svp_105,
  svp_106,
  svp_107,
  svp_108,
  svp_109,
  svp_110,
  svp_111,
  svp_112,
  svp_113,
  svp_114,
  svp_118,
  svp_122,
  svp_123,
  svp_129,
  svp_131,
  svp_135,
  svp_141,
  svp_148,
  svp_150,
  svp_151,
  svp_152,
  svp_153,
  svp_155,
  svp_157,
  svp_162,
  svp_163,
  svp_164,
  sv5_1,
  sv5_2,
  sv5_3,
  sv5_4,
  sv5_6,
  sv5_7,
  sv5_8,
  sv5_9,
  sv5_10,
  sv5_11,
  sv5_12,
  sv5_13,
  sv5_14,
  sv5_16,
  sv5_17,
  sv5_18,
  sv5_19,
  sv5_20,
  sv5_22,
  sv5_23,
  sv5_24,
  sv5_26,
  sv5_27,
  sv5_28,
  sv5_29,
  sv5_30,
  sv5_32,
  sv5_33,
  sv5_35,
  sv5_36,
  sv5_37,
  sv5_39,
  sv5_40,
  sv5_42,
  sv5_43,
  sv5_44,
  sv5_45,
  sv5_46,
  sv5_47,
  sv5_48,
  sv5_49,
  sv5_51,
  sv5_52,
  sv5_53,
  sv5_54,
  sv5_55,
  sv5_56,
  sv5_57,
  sv5_58,
  sv5_59,
  sv5_61,
  sv5_64,
  sv5_65,
  sv5_66,
  sv5_67,
  sv5_68,
  sv5_70,
  sv5_71,
  sv5_72,
  sv5_73,
  sv5_74,
  sv5_75,
  sv5_77,
  sv5_79,
  sv5_80,
  sv5_82,
  sv5_83,
  sv5_85,
  sv5_86,
  sv5_87,
  sv5_88,
  sv5_89,
  sv5_90,
  sv5_91,
  sv5_93,
  sv5_94,
  sv5_95,
  sv5_98,
  sv5_100,
  sv5_101,
  sv5_102,
  sv5_103,
  sv5_105,
  sv5_106,
  sv5_108,
  sv5_109,
  sv5_110,
  sv5_112,
  sv5_113,
  sv5_115,
  sv5_116,
  sv5_117,
  sv5_120,
  sv5_122,
  sv5_124,
  sv5_125,
  sv5_126,
  sv5_127,
  sv5_128,
  sv5_130,
  sv5_131,
  sv5_132,
  sv5_134,
  sv5_135,
  sv5_137,
  sv5_139,
  sv5_144,
  sv5_145,
  sv5_146,
  sv5_147]

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
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Turtwig"] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = ["Paradise Resort"] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 25 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 25)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Roselia", "Roserade", "Iron Jugulis"] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.koByAttack` (milestone M8b), by name. -/
theorem cards_trigKO : (cards.filter (Card.hasTrig .koByAttack)).map Card.label = [] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.oppBenched` (milestone MV7) (milestone M8b), by name. -/
theorem cards_trigBenched : (cards.filter (Card.hasTrig .oppBenched)).map Card.label = ["Magcargo"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Seedot", "Grotle"] := by decide +kernel

end PokemonCards.Standard.Part01
