/-
Imported Standard cards, part 9 of 11 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.17.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part09
open Pokemon

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

/-- Wimpod (me4-25). Records: me4-25. -/
def me4_25 : Card := .pokemon
  { name := "Wimpod", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Corkscrew Punch", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Mareep (me4-27). Records: me4-27. -/
def me4_27 : Card := .pokemon
  { name := "Mareep", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunder Wave", cost := [.lightning, .colorless], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Flaaffy (me4-28). Records: me4-28. -/
def me4_28 : Card := .pokemon
  { name := "Flaaffy", stage := .stage1, evolvesFrom := some "Mareep",
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Disconnect", cost := [.lightning, .colorless], damage := 4,
        effect := .linger .opp .next (.lock .item),
        gx := false }] }

/-- Deoxys (me4-31). Records: me4-31. Caveats: energyUnitsCount. -/
def me4_31 : Card := .pokemon
  { name := "Deoxys", stage := .basic, evolvesFrom := none,
    hp := 11, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Genome Charge", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.attach .own .deck (.energyOf .psychic) .active .any) (.attach .own .deck (.energyOf .psychic) .active .any)) .shuffle,
        gx := false },
      { name := "Psychic", cost := [.psychic, .psychic, .colorless], damage := 0,
        effect := .damage (.add (.const 8) (.count (.energy .opp .energy) 2)),
        gx := false }] }

/-- Deoxys (me4-32). Records: me4-32. Caveats: benchMods. -/
def me4_32 : Card := .pokemon
  { name := "Deoxys", stage := .basic, evolvesFrom := none,
    hp := 12, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Psyspear", cost := [.psychic, .psychic, .psychic], damage := 12,
        effect := .ite (.countGe (.energy .own .energy) 5) (.benchDamage .opp 12) .skip,
        gx := false }] }

/-- Deoxys (me4-34). Records: me4-34. -/
def me4_34 : Card := .pokemon
  { name := "Deoxys", stage := .basic, evolvesFrom := none,
    hp := 10, type := .psychic, retreat := 0, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Psyspeed", cost := [.psychic], damage := 3,
        effect := .choice (.drawTo .own 5) .skip,
        gx := false }] }

/-- Espurr (me4-36). Records: me4-36. -/
def me4_36 : Card := .pokemon
  { name := "Espurr", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Buddy Attack", cost := [.psychic], damage := 0,
        effect := .ite (.countGe (.played .own (.and (.kind .supporter) (.named "Emma"))) 1) (.damage (.const 7)) (.damage (.const 1)),
        gx := false }] }

/-- Meowstic (me4-37). Records: me4-37. Caveats: moveAnyPair. -/
def me4_37 : Card := .pokemon
  { name := "Meowstic", stage := .stage1, evolvesFrom := some "Espurr",
    hp := 10, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tricky Steps", cost := [.psychic, .colorless], damage := 8,
        effect := .choice (.moveEnergy .opp .energy) .skip,
        gx := false }] }

/-- Pumpkaboo (me4-40). Records: me4-40. -/
def me4_40 : Card := .pokemon
  { name := "Pumpkaboo", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stampede", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Xerneas (me4-42). Records: me4-42, me4-91. Caveats: energyOfCount. -/
def me4_42 : Card := .pokemon
  { name := "Xerneas", stage := .basic, evolvesFrom := none,
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Geo Storm", cost := [.psychic, .psychic, .psychic], damage := 0,
        effect := .damage (.count (.energyAll .own (.energyOf .psychic)) 3),
        gx := false }] }

/-- Sudowoodo (me4-43). Records: me4-43. -/
def me4_43 : Card := .pokemon
  { name := "Sudowoodo", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Trials and Trip-ulations", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand (.named "Transformation Tome") (.upTo 2)) .shuffle,
        gx := false },
      { name := "Rock Hurl", cost := [.fighting], damage := 0,
        effect := .damage (.const 3) { resist := true },
        gx := false }] }

/-- Phanpy (me4-44). Records: me4-44. -/
def me4_44 : Card := .pokemon
  { name := "Phanpy", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mud-Slap", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Rollout", cost := [.colorless, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Donphan (me4-45). Records: me4-45. Caveats: perPokemon. -/
def me4_45 : Card := .pokemon
  { name := "Donphan", stage := .stage1, evolvesFrom := some "Phanpy",
    hp := 15, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "No Reprieve", cost := [.fighting], damage := 2,
        effect := .linger .own .after (.bonus 12),
        gx := false },
      { name := "Smashing Headbutt", cost := [.fighting, .colorless, .colorless, .colorless], damage := 18,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Baltoy (me4-46). Records: me4-46. -/
def me4_46 : Card := .pokemon
  { name := "Baltoy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Continuous Spin", cost := [.fighting], damage := 0,
        effect := .damage (.many (.const 3)),
        gx := false }] }

/-- Mega Gallade ex (me4-48). Records: me4-48. -/
def me4_48 : Card := .pokemon
  { name := "Mega Gallade ex", stage := .stage2, evolvesFrom := some "Kirlia",
    hp := 35, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Gale Slash", cost := [.fighting], damage := 0,
        effect := .ite (.atLeast .own 1) (.damage (.const 5)) (.damage (.const 20)),
        gx := false },
      { name := "Marvelous Edge", cost := [.fighting, .fighting, .colorless], damage := 24,
        effect := .skip,
        gx := false }] }

/-- Zubat (me4-49). Records: me4-49. -/
def me4_49 : Card := .pokemon
  { name := "Zubat", stage := .basic, evolvesFrom := none,
    hp := 4, type := .darkness, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Supersonic", cost := [.darkness], damage := 0,
        effect := .inflict .confused,
        gx := false }] }

/-- Crobat (me4-51). Records: me4-51, me4-93. -/
def me4_51 : Card := .pokemon
  { name := "Crobat", stage := .stage2, evolvesFrom := some "Golbat",
    hp := 13, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Nighttime Maneuvers", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own .deck .any (.most 1) (.put .top) .shuffle)) }],
    attacks := [
      { name := "Poison Sound Wave", cost := [.darkness], damage := 8,
        effect := .seq (.inflict .confused) (.inflict .poisoned),
        gx := false }] }

/-- Qwilfish (me4-52). Records: me4-52. Caveats: trigAttacker, trigDamaged. -/
def me4_52 : Card := .pokemon
  { name := "Qwilfish", stage := .basic, evolvesFrom := none,
    hp := 9, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Poison Point", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.inflict .poisoned) }],
    attacks := [
      { name := "Venoshock", cost := [.darkness], damage := 0,
        effect := .ite (.cond .opp .poisoned) (.damage (.const 8)) (.damage (.const 3)),
        gx := false }] }

/-- Stunky (me4-53). Records: me4-53. -/
def me4_53 : Card := .pokemon
  { name := "Stunky", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Skuntank (me4-54). Records: me4-54. -/
def me4_54 : Card := .pokemon
  { name := "Skuntank", stage := .stage1, evolvesFrom := some "Stunky",
    hp := 11, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rear Kick", cost := [.darkness], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Smash Turn", cost := [.darkness, .darkness, .colorless], damage := 10,
        effect := .switch .own,
        gx := false }] }

/-- Krookodile ex (me4-55). Records: me4-55. Caveats: perPokemon. -/
def me4_55 : Card := .pokemon
  { name := "Krookodile ex", stage := .stage2, evolvesFrom := some "Krokorok",
    hp := 32, type := .darkness, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Corner", cost := [.darkness, .colorless], damage := 8,
        effect := .linger .opp .next (.lock .retreat),
        gx := false },
      { name := "Strong Bite", cost := [.darkness, .darkness, .colorless], damage := 0,
        effect := .ite (.hasTool .own) (.damage (.const 28)) (.damage (.const 14)),
        gx := false }] }

/-- Trubbish (me4-56). Records: me4-56. -/
def me4_56 : Card := .pokemon
  { name := "Trubbish", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Acid Spray", cost := [.darkness], damage := 1,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Skrelp (me4-58). Records: me4-58. -/
def me4_58 : Card := .pokemon
  { name := "Skrelp", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hook", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Beldum (me4-59). Records: me4-59. -/
def me4_59 : Card := .pokemon
  { name := "Beldum", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.metal], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Beam", cost := [.metal, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Metang (me4-60). Records: me4-60, me4-94. Caveats: perPokemon. -/
def me4_60 : Card := .pokemon
  { name := "Metang", stage := .stage1, evolvesFrom := some "Beldum",
    hp := 10, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Metal Claw", cost := [.metal], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Guard Press", cost := [.metal, .metal, .colorless], damage := 7,
        effect := .linger .own .next (.reduce 3),
        gx := false }] }

/-- Ferroseed (me4-62). Records: me4-62. -/
def me4_62 : Card := .pokemon
  { name := "Ferroseed", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Tackle", cost := [.metal, .metal], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Goomy (me4-66). Records: me4-66. -/
def me4_66 : Card := .pokemon
  { name := "Goomy", stage := .basic, evolvesFrom := none,
    hp := 6, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Absorb", cost := [.water, .psychic], damage := 3,
        effect := .heal 3,
        gx := false }] }

/-- Sliggoo (me4-67). Records: me4-67, me4-95. -/
def me4_67 : Card := .pokemon
  { name := "Sliggoo", stage := .stage1, evolvesFrom := some "Goomy",
    hp := 9, type := .dragon, retreat := 3, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.water, .psychic], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Watchog (me4-71). Records: me4-71, me4-97. -/
def me4_71 : Card := .pokemon
  { name := "Watchog", stage := .stage1, evolvesFrom := some "Patrat",
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Snap Inspection", cost := [.colorless], damage := 0,
        effect := .choice .skip (.choice (.move .opp .hand .shuffle .any (.most 1)) (.choice (.move .opp .hand .shuffle .any (.most 2)) (.move .opp .hand .shuffle .any (.most 3)))),
        gx := false },
      { name := "Low Kick", cost := [.colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Minccino (me4-72). Records: me4-72. Caveats: recoil. -/
def me4_72 : Card := .pokemon
  { name := "Minccino", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Take Down", cost := [.colorless], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Great Haul Net (me4-78). Records: me4-78. Caveats: upTo0. -/
def me4_78 : Card := .trainer "Great Haul Net" .item
    (.seq (.ite (.countGe (.pile .own .discard (.energyOf .water)) 1) .skip (.ite (.countGe (.pile .own .discard (.ptype .water)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.choice (.move .own .discard .shuffle (.ptype .water) (.upTo 3)) (.choice (.move .own .discard .shuffle (.energyOf .water) (.upTo 3)) (.seq (.move .own .discard .shuffle (.ptype .water) (.upTo 3)) (.move .own .discard .shuffle (.energyOf .water) (.upTo 3))))))

/-- Prism Tower (me4-80). Records: me4-80, me4-111. -/
def me4_80 : Card := .trainer "Prism Tower" .stadium
    (.seq (.move .own .hand .discard .any (.exactly 2)) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 1) .hand .any .all)))

/-- Special Red Card (me4-82). Records: me4-82, me4-113. -/
def me4_82 : Card := .trainer "Special Red Card" .item
    (.seq (.ite (.countGe (.prizes .opp) 4) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.seq (.ite (.countGe (.pile .opp .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .opp .hand .bottom .any .all) (.move .opp (.top 3) .hand .any .all))))

/-- Magnetic Metal Energy (me4-85). Records: me4-85. Caveats: noRetreatLast. -/
def me4_85 : Card := .energy (.special "Magnetic Metal Energy" [[.metal]] { grant := { holder := .ptype .metal, attacks := [], abilities := [], statics := [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .noRetreat }] } })

/-- Tropius (me5-1). Records: me5-1. -/
def me5_1 : Card := .pokemon
  { name := "Tropius", stage := .basic, evolvesFrom := none,
    hp := 11, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fruity Aroma", cost := [.colorless], damage := 0,
        effect := .look .own (.top 6) .pokemon (.upTo 6) (.put .hand) .shuffle,
        gx := false },
      { name := "Solar Beam", cost := [.grass, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Grubbin (me5-2). Records: me5-2. -/
def me5_2 : Card := .pokemon
  { name := "Grubbin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "String Shot", cost := [.colorless], damage := 1,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Fomantis (me5-3). Records: me5-3, me5-85. Caveats: recoil. -/
def me5_3 : Card := .pokemon
  { name := "Fomantis", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.grass], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Mega Delphox ex (me5-8). Records: me5-8. -/
def me5_8 : Card := .pokemon
  { name := "Mega Delphox ex", stage := .stage2, evolvesFrom := some "Braixen",
    hp := 35, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [],
    attacks := [
      { name := "Trick Portal", cost := [.fire], damage := 0,
        effect := .look .own (.top 9) .pokemon (.upTo 9) .bench .shuffle,
        gx := false },
      { name := "Eerie Glow", cost := [.fire, .colorless, .colorless], damage := 20,
        effect := .seq (.inflict .burned) (.inflict .confused),
        gx := false }] }

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

/-- The cards of this part. -/
def cards : List Card := [
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
  me3_42,
  me3_43,
  me3_44,
  me3_45,
  me3_48,
  me3_49,
  me3_51,
  me3_52,
  me3_54,
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
  me4_23,
  me4_25,
  me4_27,
  me4_28,
  me4_31,
  me4_32,
  me4_34,
  me4_36,
  me4_37,
  me4_40,
  me4_42,
  me4_43,
  me4_44,
  me4_45,
  me4_46,
  me4_48,
  me4_49,
  me4_51,
  me4_52,
  me4_53,
  me4_54,
  me4_55,
  me4_56,
  me4_58,
  me4_59,
  me4_60,
  me4_62,
  me4_66,
  me4_67,
  me4_71,
  me4_72,
  me4_78,
  me4_80,
  me4_82,
  me4_85,
  me5_1,
  me5_2,
  me5_3,
  me5_8,
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
  me5_49]

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
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = ["Magnetic Metal Energy"] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 25 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 25)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Team Rocket's Hypnotizer", "Qwilfish"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Mega Pyroar ex", "Metang"] := by decide +kernel

end PokemonCards.Standard.Part09
