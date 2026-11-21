/-
Imported Standard cards, part 1 of 8 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.3.0
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

/-- Armarouge ex (svp-105). Records: svp-105. -/
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
    (.choice (.move .own (.top 4) .hand .any .all) (.move .own (.top 2) .hand .any .all))

/-- Tatsugiri (svp-118). Records: svp-118, sv6-131, sv6-186. -/
def svp_118 : Card := .pokemon
  { name := "Tatsugiri", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Attract Customers", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.move .own (.top 6) .hand (.kind .supporter) (.upTo 1)) .shuffle) }],
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
        effect := .seq (.move .own .deck .hand .energy (.upTo 2)) .shuffle,
        gx := false },
      { name := "Ogre Comeback", cost := [.grass, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.count (.bench .opp .pokemon) 2)),
        gx := false }] }

/-- Kingdra ex (svp-131). Records: svp-131, sv6pt5-12, sv6pt5-80. -/
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

/-- Breloom (sv5-7). Records: sv5-7. Caveats: perPokemon. -/
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
        effect := .linger .own .after (.lock .attack),
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

/-- Deerling (sv5-16). Records: sv5-16, sv5-165. -/
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

/-- Ponyta (sv5-26). Records: sv5-26. -/
def sv5_26 : Card := .pokemon
  { name := "Ponyta", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Charge Energy", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .energy (.upTo 1)) .shuffle,
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

/-- Azumarill (sv5-65). Records: sv5-65. Caveats: perPokemon. -/
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
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

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

/-- Coalossal (sv5-95). Records: sv5-95. -/
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

/-- Tranquill (sv5-134). Records: sv5-134. Caveats: perPokemon. -/
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
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Buddy-Buddy Poffin (sv5-144). Records: sv5-144, sv6-223, sv8pt5-101, me1-167, me2pt5-184. Caveats: upTo0. -/
def sv5_144 : Card := .trainer "Buddy-Buddy Poffin" .item
    (.seq (.seq (.putBench .own .deck (.and .basic (.hpLe 7))) (.putBench .own .deck (.and .basic (.hpLe 7)))) .shuffle)

/-- Master Ball (sv5-153). Records: sv5-153. Caveats: aceSpec. -/
def sv5_153 : Card := .trainer "Master Ball" .item
    (.seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle)

/-- Tangela (sv6-1). Records: sv6-1. -/
def sv6_1 : Card := .pokemon
  { name := "Tangela", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Vine Slap", cost := [.grass, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Spinarak (sv6-4). Records: sv6-4. -/
def sv6_4 : Card := .pokemon
  { name := "Spinarak", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bug Bite", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

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

/-- Sunflora (sv6-7). Records: sv6-7, sv6-169. -/
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
        effect := .fx (.seq (.move .own (.top 1) .hand .any .all) (.move .opp (.top 1) .hand .any .all)) }],
    attacks := [
      { name := "Mind Ruler", cost := [.fire], damage := 0,
        effect := .damage (.count (.pile .opp .hand .any) 3),
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

/-- Crawdaunt (sv6-48). Records: sv6-48. Caveats: perPokemon. -/
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
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

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

/-- Phione (sv6-55). Records: sv6-55, sv6-175. -/
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
        effect := .seq (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 12)) (.benchDamage .opp 12)) (.damage (.const 12))) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Finizen (sv6-59). Records: sv6-59. Caveats: perPokemon. -/
def sv6_59 : Card := .pokemon
  { name := "Finizen", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aqua Slash", cost := [.water], damage := 3,
        effect := .linger .own .after (.lock .attack),
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
  svp_131,
  svp_148,
  svp_151,
  svp_155,
  svp_157,
  svp_162,
  sv5_2,
  sv5_3,
  sv5_4,
  sv5_6,
  sv5_7,
  sv5_11,
  sv5_14,
  sv5_16,
  sv5_18,
  sv5_19,
  sv5_20,
  sv5_22,
  sv5_23,
  sv5_26,
  sv5_27,
  sv5_28,
  sv5_32,
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
  sv5_51,
  sv5_53,
  sv5_54,
  sv5_55,
  sv5_57,
  sv5_58,
  sv5_59,
  sv5_64,
  sv5_65,
  sv5_66,
  sv5_67,
  sv5_68,
  sv5_70,
  sv5_71,
  sv5_74,
  sv5_75,
  sv5_82,
  sv5_83,
  sv5_85,
  sv5_86,
  sv5_87,
  sv5_89,
  sv5_90,
  sv5_91,
  sv5_93,
  sv5_94,
  sv5_95,
  sv5_100,
  sv5_101,
  sv5_102,
  sv5_103,
  sv5_105,
  sv5_106,
  sv5_110,
  sv5_113,
  sv5_116,
  sv5_117,
  sv5_120,
  sv5_125,
  sv5_126,
  sv5_127,
  sv5_130,
  sv5_132,
  sv5_134,
  sv5_144,
  sv5_153,
  sv6_1,
  sv6_4,
  sv6_6,
  sv6_7,
  sv6_8,
  sv6_12,
  sv6_13,
  sv6_14,
  sv6_17,
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
  sv6_41,
  sv6_42,
  sv6_47,
  sv6_48,
  sv6_49,
  sv6_52,
  sv6_55,
  sv6_56,
  sv6_57,
  sv6_58,
  sv6_59,
  sv6_65,
  sv6_66,
  sv6_67,
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
  sv6_83]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

end PokemonCards.Standard.Part01
