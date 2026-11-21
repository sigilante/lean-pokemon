/-
Imported Standard cards, part 3 of 8 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.6.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part03
open Pokemon

/-- Shiinotic (sv8-9). Records: sv8-9, sv8-194. -/
def sv8_9 : Card := .pokemon
  { name := "Shiinotic", stage := .stage1, evolvesFrom := some "Morelull",
    hp := 11, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Calming Light", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.inflict .asleep) }],
    attacks := [
      { name := "Spiral Rush", cost := [.grass, .colorless], damage := 0,
        effect := .damage (.add (.const 6) (.many (.const 3))),
        gx := false }] }

/-- Dhelmise (sv8-10). Records: sv8-10. -/
def sv8_10 : Card := .pokemon
  { name := "Dhelmise", stage := .basic, evolvesFrom := none,
    hp := 13, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rescue Kedge", cost := [.colorless], damage := 0,
        effect := .move .own .discard .hand .pokemon (.upTo 2),
        gx := false },
      { name := "Annihilating Anchor", cost := [.grass, .colorless, .colorless], damage := 0,
        effect := .seq (.discardTools .opp .active) (.damage (.const 8)),
        gx := false }] }

/-- Capsakid (sv8-12). Records: sv8-12. -/
def sv8_12 : Card := .pokemon
  { name := "Capsakid", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt Bounce", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Rellor (sv8-13). Records: sv8-13, sv10-24. -/
def sv8_13 : Card := .pokemon
  { name := "Rellor", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Rollout", cost := [.grass], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Vulpix (sv8-16). Records: sv8-16. Caveats: recoil. -/
def sv8_16 : Card := .pokemon
  { name := "Vulpix", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Take Down", cost := [.fire], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Ninetales (sv8-17). Records: sv8-17. Caveats: benchMods. -/
def sv8_17 : Card := .pokemon
  { name := "Ninetales", stage := .stage1, evolvesFrom := some "Vulpix",
    hp := 12, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fire Soul", cost := [.fire], damage := 5,
        effect := .benchDamage .opp 3,
        gx := false }] }

/-- Victini (sv8-21). Records: sv8-21. -/
def sv8_21 : Card := .pokemon
  { name := "Victini", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Victory Cheer", use := .static [{ sel := .own, filt := .and (.and .pokemon (.not .basic)) (.ptype .fire), tgt := none, src := none, need := none, eff := .bonus 1 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Flare", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Pansear (sv8-22). Records: sv8-22. -/
def sv8_22 : Card := .pokemon
  { name := "Pansear", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Combustion", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Simisear (sv8-23). Records: sv8-23. -/
def sv8_23 : Card := .pokemon
  { name := "Simisear", stage := .stage1, evolvesFrom := some "Pansear",
    hp := 9, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Smash", cost := [.fire], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 7)) (.damage (.const 14))),
        gx := false }] }

/-- Larvesta (sv8-24). Records: sv8-24, sv8-196. -/
def sv8_24 : Card := .pokemon
  { name := "Larvesta", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Steady Firebreathing", cost := [.fire, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Volcarona (sv8-25). Records: sv8-25. Caveats: recoil. -/
def sv8_25 : Card := .pokemon
  { name := "Volcarona", stage := .stage1, evolvesFrom := some "Larvesta",
    hp := 14, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leech Life", cost := [.colorless], damage := 0,
        effect := .drain (.const 3),
        gx := false },
      { name := "Turbulent Wings", cost := [.fire, .colorless, .colorless], damage := 15,
        effect := .selfDamage 5,
        gx := false }] }

/-- Sizzlipede (sv8-27). Records: sv8-27. -/
def sv8_27 : Card := .pokemon
  { name := "Sizzlipede", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Live Coal", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Hook", cost := [.colorless, .colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Centiskorch (sv8-28). Records: sv8-28. Caveats: benchMods. -/
def sv8_28 : Card := .pokemon
  { name := "Centiskorch", stage := .stage1, evolvesFrom := some "Sizzlipede",
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Billowing Heat Wave", cost := [.fire], damage := 13,
        effect := .spreadDamage .own 3,
        gx := false },
      { name := "Heat Blast", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Fuecoco (sv8-29). Records: sv8-29. -/
def sv8_29 : Card := .pokemon
  { name := "Fuecoco", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Heat Burn", cost := [.fire, .colorless], damage := 2,
        effect := .inflict .burned,
        gx := false }] }

/-- Crocalor (sv8-30). Records: sv8-30. -/
def sv8_30 : Card := .pokemon
  { name := "Crocalor", stage := .stage1, evolvesFrom := some "Fuecoco",
    hp := 11, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Heat Breath", cost := [.fire, .colorless], damage := 0,
        effect := .choice (.damage (.const 8)) (.damage (.const 3)),
        gx := false }] }

/-- Charcadet (sv8-32). Records: sv8-32. -/
def sv8_32 : Card := .pokemon
  { name := "Charcadet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Will-O-Wisp", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Charcadet (sv8-33). Records: sv8-33. -/
def sv8_33 : Card := .pokemon
  { name := "Charcadet", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Light Punch", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Flamethrower", cost := [.fire, .fire, .colorless], damage := 7,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Ceruledge ex (sv8-36). Records: sv8-36, sv8pt5-147. -/
def sv8_36 : Card := .pokemon
  { name := "Ceruledge ex", stage := .stage1, evolvesFrom := some "Charcadet",
    hp := 27, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Abyssal Flames", cost := [.fire], damage := 0,
        effect := .damage (.add (.const 3) (.count (.pile .own .discard .energy) 2)),
        gx := false },
      { name := "Raging Amethyst", cost := [.fire, .psychic, .metal], damage := 28,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Mantine (sv8-40). Records: sv8-40. Caveats: benchMods. -/
def sv8_40 : Card := .pokemon
  { name := "Mantine", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wave Splash", cost := [.water], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Aqua Dive", cost := [.water, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 5)) (.benchDamage .opp 5)) (.damage (.const 5)),
        gx := false }] }

/-- Feebas (sv8-41). Records: sv8-41, sv8-198. -/
def sv8_41 : Card := .pokemon
  { name := "Feebas", stage := .basic, evolvesFrom := none,
    hp := 3, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leap Out", cost := [.colorless], damage := 0,
        effect := .switch .own,
        gx := false }] }

/-- Spheal (sv8-43). Records: sv8-43, sv8-199. -/
def sv8_43 : Card := .pokemon
  { name := "Spheal", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Powder Snow", cost := [.water], damage := 1,
        effect := .inflict .asleep,
        gx := false }] }

/-- Sealeo (sv8-44). Records: sv8-44. -/
def sv8_44 : Card := .pokemon
  { name := "Sealeo", stage := .stage1, evolvesFrom := some "Spheal",
    hp := 10, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lunge Out", cost := [.water], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Ice Ball", cost := [.water, .water], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Shellos (sv8-46). Records: sv8-46. -/
def sv8_46 : Card := .pokemon
  { name := "Shellos", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sprinkle Water", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Cryogonal (sv8-47). Records: sv8-47. -/
def sv8_47 : Card := .pokemon
  { name := "Cryogonal", stage := .basic, evolvesFrom := none,
    hp := 9, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call Sign", cost := [.water], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle,
        gx := false },
      { name := "Ice Beam", cost := [.water], damage := 3,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Bruxish (sv8-49). Records: sv8-49, sv8-200. Caveats: perPokemon, trigAttacker, trigDamaged. -/
def sv8_49 : Card := .pokemon
  { name := "Bruxish", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Counterattack", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.counters 3) }],
    attacks := [
      { name := "Big Bite", cost := [.water, .colorless], damage := 5,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Quaxly (sv8-50). Records: sv8-50. -/
def sv8_50 : Card := .pokemon
  { name := "Quaxly", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aerial Ace", cost := [.water], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Quaxwell (sv8-51). Records: sv8-51. -/
def sv8_51 : Card := .pokemon
  { name := "Quaxwell", stage := .stage1, evolvesFrom := some "Quaxly",
    hp := 10, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aqua Edge", cost := [.water], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Quaquaval (sv8-52). Records: sv8-52. -/
def sv8_52 : Card := .pokemon
  { name := "Quaquaval", stage := .stage2, evolvesFrom := some "Quaxwell",
    hp := 17, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Up-Tempo", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .hand .bottom .any (.exactly 1)) (.drawTo .own 5)) }],
    attacks := [
      { name := "Hydro Splash", cost := [.water, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Cetoddle (sv8-53). Records: sv8-53. -/
def sv8_53 : Card := .pokemon
  { name := "Cetoddle", stage := .basic, evolvesFrom := none,
    hp := 10, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Draining Fin", cost := [.water, .colorless], damage := 2,
        effect := .heal 2,
        gx := false }] }

/-- Cetitan (sv8-54). Records: sv8-54, sv8-201. Caveats: staticBench. -/
def sv8_54 : Card := .pokemon
  { name := "Cetitan", stage := .stage1, evolvesFrom := some "Cetoddle",
    hp := 18, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Solid Body", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 3 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Dangerous Mouth", cost := [.water, .colorless, .colorless, .colorless], damage := 15,
        effect := .skip,
        gx := false }] }

/-- Magnemite (sv8-58). Records: sv8-58. -/
def sv8_58 : Card := .pokemon
  { name := "Magnemite", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lightning Ball", cost := [.lightning], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Blitzle (sv8-62). Records: sv8-62. -/
def sv8_62 : Card := .pokemon
  { name := "Blitzle", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Add On", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Static Shock", cost := [.lightning, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Zebstrika (sv8-63). Records: sv8-63. -/
def sv8_63 : Card := .pokemon
  { name := "Zebstrika", stage := .stage1, evolvesFrom := some "Blitzle",
    hp := 13, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Kick", cost := [.lightning], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Mach Bolt", cost := [.lightning, .lightning, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Wattrel (sv8-66). Records: sv8-66. -/
def sv8_66 : Card := .pokemon
  { name := "Wattrel", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aerial Ace", cost := [.lightning], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Togepi (sv8-70). Records: sv8-70, me2pt5-80. -/
def sv8_70 : Card := .pokemon
  { name := "Togepi", stage := .basic, evolvesFrom := none,
    hp := 5, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pound", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Togetic (sv8-71). Records: sv8-71, me2pt5-81. -/
def sv8_71 : Card := .pokemon
  { name := "Togetic", stage := .stage1, evolvesFrom := some "Togepi",
    hp := 9, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Draining Kiss", cost := [.colorless, .colorless], damage := 3,
        effect := .heal 3,
        gx := false }] }

/-- Marill (sv8-73). Records: sv8-73. -/
def sv8_73 : Card := .pokemon
  { name := "Marill", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Tackle", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Latios (sv8-77). Records: sv8-77, sv8-203. Caveats: benchMods. -/
def sv8_77 : Card := .pokemon
  { name := "Latios", stage := .basic, evolvesFrom := none,
    hp := 12, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Skill Dive", cost := [.psychic, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 5)) (.benchDamage .opp 5)) (.damage (.const 5)),
        gx := false },
      { name := "Jet Headbutt", cost := [.psychic, .psychic, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Uxie (sv8-78). Records: sv8-78. -/
def sv8_78 : Card := .pokemon
  { name := "Uxie", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Painful Memories", cost := [.psychic], damage := 0,
        effect := .seq (.counters 2) (.spreadCounters .opp 2),
        gx := false }] }

/-- Sigilyph (sv8-81). Records: sv8-81. -/
def sv8_81 : Card := .pokemon
  { name := "Sigilyph", stage := .basic, evolvesFrom := none,
    hp := 11, type := .psychic, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Draw", cost := [.colorless], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Psy Bolt", cost := [.psychic, .colorless, .colorless], damage := 6,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Yamask (sv8-82). Records: sv8-82. -/
def sv8_82 : Card := .pokemon
  { name := "Yamask", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mumble", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Petty Grudge", cost := [.psychic, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Espurr (sv8-84). Records: sv8-84. Caveats: hiddenInfo. -/
def sv8_84 : Card := .pokemon
  { name := "Espurr", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "See Through", cost := [.colorless], damage := 0,
        effect := .skip,
        gx := false },
      { name := "Psyshot", cost := [.psychic, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Meowstic (sv8-85). Records: sv8-85. Caveats: noopUse. -/
def sv8_85 : Card := .pokemon
  { name := "Meowstic", stage := .stage1, evolvesFrom := some "Espurr",
    hp := 9, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Beckoning Tail", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .hand .discard (.named "Chill Teaser Toy") (.exactly 1)) (.switch .opp)) }],
    attacks := [
      { name := "Psyshot", cost := [.psychic, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Dedenne (sv8-87). Records: sv8-87. -/
def sv8_87 : Card := .pokemon
  { name := "Dedenne", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electromagnetic Sonar", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.pile .own .discard .trainer) 1) (.move .own .discard .hand .trainer (.exactly 1)) .skip,
        gx := false },
      { name := "Gnaw", cost := [.psychic], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Xerneas (sv8-88). Records: sv8-88. Caveats: perPokemon. -/
def sv8_88 : Card := .pokemon
  { name := "Xerneas", stage := .basic, evolvesFrom := none,
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aurora Gain", cost := [.psychic, .colorless], damage := 3,
        effect := .heal 3,
        gx := false },
      { name := "Giga Impact", cost := [.psychic, .psychic, .colorless], damage := 13,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Sandygast (sv8-90). Records: sv8-90. -/
def sv8_90 : Card := .pokemon
  { name := "Sandygast", stage := .basic, evolvesFrom := none,
    hp := 9, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sand Spray", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Tapu Lele (sv8-92). Records: sv8-92. -/
def sv8_92 : Card := .pokemon
  { name := "Tapu Lele", stage := .basic, evolvesFrom := none,
    hp := 11, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Perplex", cost := [.colorless, .colorless], damage := 2,
        effect := .inflict .confused,
        gx := false },
      { name := "Mental Crush", cost := [.psychic, .colorless, .colorless], damage := 0,
        effect := .ite (.cond .opp .confused) (.damage (.const 18)) (.damage (.const 9)),
        gx := false }] }

/-- Gimmighoul (sv8-97). Records: sv8-97. -/
def sv8_97 : Card := .pokemon
  { name := "Gimmighoul", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Minor Errand-Running", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .energy (.upTo 2)) .shuffle,
        gx := false },
      { name := "Tackle", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Mankey (sv8-98). Records: sv8-98. -/
def sv8_98 : Card := .pokemon
  { name := "Mankey", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dual Chop", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- Primeape (sv8-99). Records: sv8-99. -/
def sv8_99 : Card := .pokemon
  { name := "Primeape", stage := .stage1, evolvesFrom := some "Mankey",
    hp := 11, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sweep the Leg", cost := [.fighting], damage := 3,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false },
      { name := "Mega Punch", cost := [.fighting, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Phanpy (sv8-102). Records: sv8-102, sv8-205. -/
def sv8_102 : Card := .pokemon
  { name := "Phanpy", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.fighting], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Trapinch (sv8-104). Records: sv8-104. -/
def sv8_104 : Card := .pokemon
  { name := "Trapinch", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Bite", cost := [.fighting, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Drilbur (sv8-108). Records: sv8-108. -/
def sv8_108 : Card := .pokemon
  { name := "Drilbur", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Burrow", cost := [.colorless], damage := 0,
        effect := .move .opp (.top 1) .discard .any .all,
        gx := false },
      { name := "Mud-Slap", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Excadrill (sv8-109). Records: sv8-109. -/
def sv8_109 : Card := .pokemon
  { name := "Excadrill", stage := .stage1, evolvesFrom := some "Drilbur",
    hp := 12, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Digging Claw", cost := [.colorless], damage := 2,
        effect := .move .opp (.top 1) .discard .any .all,
        gx := false },
      { name := "Drill Smash", cost := [.fighting, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .own (.ptype .metal)) 1) (.damage (.const 14)) (.damage (.const 6)),
        gx := false }] }

/-- Clobbopus (sv8-112). Records: sv8-112, sv8-207. Caveats: recoil. -/
def sv8_112 : Card := .pokemon
  { name := "Clobbopus", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slight Intrusion", cost := [.fighting], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Deino (sv8-117). Records: sv8-117. -/
def sv8_117 : Card := .pokemon
  { name := "Deino", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stomp Off", cost := [.darkness], damage := 0,
        effect := .move .opp (.top 1) .discard .any .all,
        gx := false },
      { name := "Bite", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Zweilous (sv8-118). Records: sv8-118. -/
def sv8_118 : Card := .pokemon
  { name := "Zweilous", stage := .stage1, evolvesFrom := some "Deino",
    hp := 10, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stomp Off", cost := [.darkness], damage := 0,
        effect := .move .opp (.top 2) .discard .any .all,
        gx := false },
      { name := "Darkness Fang", cost := [.darkness, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Shroodle (sv8-120). Records: sv8-120. -/
def sv8_120 : Card := .pokemon
  { name := "Shroodle", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spray Fluid", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Alolan Diglett (sv8-122). Records: sv8-122. -/
def sv8_122 : Card := .pokemon
  { name := "Alolan Diglett", stage := .basic, evolvesFrom := none,
    hp := 5, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Surprise Attack", cost := [], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Skarmory (sv8-124). Records: sv8-124, sv8-209. Caveats: perPokemon. -/
def sv8_124 : Card := .pokemon
  { name := "Skarmory", stage := .basic, evolvesFrom := none,
    hp := 11, type := .metal, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Steel Wing", cost := [.metal, .colorless], damage := 5,
        effect := .linger .own .next (.reduce 3),
        gx := false }] }

/-- Registeel (sv8-125). Records: sv8-125. -/
def sv8_125 : Card := .pokemon
  { name := "Registeel", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Raging Hammer", cost := [.metal, .colorless], damage := 0,
        effect := .damage (.add (.const 6) (.per .own 1)),
        gx := false }] }

/-- Bronzor (sv8-126). Records: sv8-126. -/
def sv8_126 : Card := .pokemon
  { name := "Bronzor", stage := .basic, evolvesFrom := none,
    hp := 6, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shield Attack", cost := [.metal, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Bronzong (sv8-127). Records: sv8-127. -/
def sv8_127 : Card := .pokemon
  { name := "Bronzong", stage := .stage1, evolvesFrom := some "Bronzor",
    hp := 13, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spinning Attack", cost := [.metal, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Double Impact", cost := [.metal, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 10)) (.damage (.const 20))),
        gx := false }] }

/-- Duraludon (sv8-129). Records: sv8-129. -/
def sv8_129 : Card := .pokemon
  { name := "Duraludon", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Confront", cost := [.metal, .metal], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Duralubeam", cost := [.metal, .metal, .metal], damage := 13,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Iron Crown (sv8-132). Records: sv8-132. -/
def sv8_132 : Card := .pokemon
  { name := "Iron Crown", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Deleting Slash", cost := [.metal, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 3) (.damage (.const 12)) (.damage (.const 4)),
        gx := false },
      { name := "Slicing Blade", cost := [.metal, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Altaria (sv8-134). Records: sv8-134. Caveats: perPokemon. -/
def sv8_134 : Card := .pokemon
  { name := "Altaria", stage := .stage1, evolvesFrom := some "Swablu",
    hp := 12, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Humming Charge", cost := [.water], damage := 0,
        effect := .seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) .shuffle,
        gx := false },
      { name := "Cotton Wings", cost := [.water, .metal], damage := 10,
        effect := .choice (.linger .own .next .prevent) .skip,
        gx := false }] }

/-- Palkia (sv8-136). Records: sv8-136. -/
def sv8_136 : Card := .pokemon
  { name := "Palkia", stage := .basic, evolvesFrom := none,
    hp := 13, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Space Crash", cost := [.grass, .water], damage := 0,
        effect := .damage (.count (.energy .own .energy) 4),
        gx := false }] }

/-- Applin (sv8-138). Records: sv8-138. -/
def sv8_138 : Card := .pokemon
  { name := "Applin", stage := .basic, evolvesFrom := none,
    hp := 4, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nutrients", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.bench .own .pokemon) 1) (.choice (.heal 3) (.benchHeal 3)) (.heal 3),
        gx := false },
      { name := "Trip Over", cost := [.grass, .fire], damage := 0,
        effect := .choice (.damage (.const 5)) (.damage (.const 2)),
        gx := false }] }

/-- Flapple (sv8-139). Records: sv8-139, sv8-210. -/
def sv8_139 : Card := .pokemon
  { name := "Flapple", stage := .stage1, evolvesFrom := some "Applin",
    hp := 8, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Acidic Spit", cost := [.colorless], damage := 0,
        effect := .damage (.per .opp 2),
        gx := false },
      { name := "Speed Dive", cost := [.grass, .fire], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Appletun (sv8-140). Records: sv8-140, sv8-211. Caveats: perPokemon, recoil. -/
def sv8_140 : Card := .pokemon
  { name := "Appletun", stage := .stage1, evolvesFrom := some "Applin",
    hp := 9, type := .dragon, retreat := 3, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Melting Sweetness", cost := [.colorless, .colorless], damage := 5,
        effect := .linger .opp .next (.lock .attack),
        gx := false },
      { name := "Wild Tackle", cost := [.grass, .fire], damage := 13,
        effect := .selfDamage 2,
        gx := false }] }

/-- Snorlax (sv8-144). Records: sv8-144. -/
def sv8_144 : Card := .pokemon
  { name := "Snorlax", stage := .basic, evolvesFrom := none,
    hp := 15, type := .colorless, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spike Draw", cost := [.colorless], damage := 2,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Mega Punch", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Slakoth (sv8-145). Records: sv8-145, sv8-212. Caveats: perPokemon. -/
def sv8_145 : Card := .pokemon
  { name := "Slakoth", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Take It Easy", cost := [.colorless], damage := 0,
        effect := .seq (.heal 6) (.linger .own .after (.lock .retreat)),
        gx := false }] }

/-- Vigoroth (sv8-146). Records: sv8-146. -/
def sv8_146 : Card := .pokemon
  { name := "Vigoroth", stage := .stage1, evolvesFrom := some "Slakoth",
    hp := 9, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slashing Claw", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Swablu (sv8-148). Records: sv8-148. -/
def sv8_148 : Card := .pokemon
  { name := "Swablu", stage := .basic, evolvesFrom := none,
    hp := 5, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Disarming Voice", cost := [.colorless], damage := 1,
        effect := .inflict .confused,
        gx := false }] }

/-- Rufflet (sv8-152). Records: sv8-152. -/
def sv8_152 : Card := .pokemon
  { name := "Rufflet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flap", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Helioptile (sv8-154). Records: sv8-154. Caveats: recoil. -/
def sv8_154 : Card := .pokemon
  { name := "Helioptile", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tiny Bolt", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Reckless Charge", cost := [.colorless, .colorless, .colorless], damage := 4,
        effect := .selfDamage 1,
        gx := false }] }

/-- Heliolisk (sv8-155). Records: sv8-155. -/
def sv8_155 : Card := .pokemon
  { name := "Heliolisk", stage := .stage1, evolvesFrom := some "Helioptile",
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Parabolic Charge", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .energy (.upTo 4)) .shuffle,
        gx := false },
      { name := "Electroslug", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Tandemaus (sv8-157). Records: sv8-157. -/
def sv8_157 : Card := .pokemon
  { name := "Tandemaus", stage := .basic, evolvesFrom := none,
    hp := 4, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Play Rough", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 2)) (.damage (.const 1)),
        gx := false }] }

/-- Cyclizar ex (sv8-159). Records: sv8-159, sv8-228. Caveats: benchMods. -/
def sv8_159 : Card := .pokemon
  { name := "Cyclizar ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Break Through", cost := [.colorless, .colorless, .colorless], damage := 13,
        effect := .benchDamage .opp 3,
        gx := false },
      { name := "Zircon Road", cost := [.grass, .fire, .psychic], damage := 18,
        effect := .choice (.move .own (.top 5) .hand .any .all) .skip,
        gx := false }] }

/-- Amulet of Hope (sv8-162). Records: sv8-162. Caveats: aceSpec, searchAny, trigKO, upTo0. -/
def sv8_162 : Card := .tool "Amulet of Hope"
  { holder := .pokemon,
    attacks := [],
    abilities := [
      { name := "Amulet of Hope", use := .triggered .koByAttack false,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .deck .hand .any (.upTo 3)) .shuffle) }] }

/-- Cyrano (sv8-170). Records: sv8-170, sv8-230. Caveats: upTo0. -/
def sv8_170 : Card := .trainer "Cyrano" .supporter
    (.seq (.move .own .deck .hand (.and .pokemon (.not .noRuleBox)) (.upTo 3)) .shuffle)

/-- Gravity Mountain (sv8-177). Records: sv8-177, sv8-250. -/
def sv8_177 : Card := .trainer "Gravity Mountain" .stadium
    .skip [
      { sel := .all, filt := .stage .stage2, tgt := none, src := none, need := none, eff := .hpMinus 3 }]

/-- Jasmine's Gaze (sv8-178). Records: sv8-178, sv8-233, sv8-245. Caveats: benchMods. -/
def sv8_178 : Card := .trainer "Jasmine's Gaze" .supporter
    (.linger .own .next (.reduce 3))

/-- Lively Stadium (sv8-180). Records: sv8-180. -/
def sv8_180 : Card := .trainer "Lively Stadium" .stadium
    .skip [
      { sel := .all, filt := .basic, tgt := none, src := none, need := none, eff := .hpPlus (.const 3) }]

/-- Miracle Headset (sv8-183). Records: sv8-183. Caveats: aceSpec, upTo0. -/
def sv8_183 : Card := .trainer "Miracle Headset" .item
    (.move .own .discard .hand (.kind .supporter) (.upTo 2))

/-- Exeggcute (sv8pt5-1). Records: sv8pt5-1. -/
def sv8pt5_1 : Card := .pokemon
  { name := "Exeggcute", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.grass, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Exeggutor (sv8pt5-2). Records: sv8pt5-2. -/
def sv8pt5_2 : Card := .pokemon
  { name := "Exeggutor", stage := .stage1, evolvesFrom := some "Exeggcute",
    hp := 14, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mega Drain", cost := [.grass, .colorless], damage := 5,
        effect := .heal 3,
        gx := false },
      { name := "Solar Beam", cost := [.grass, .grass, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Pinsir (sv8pt5-3). Records: sv8pt5-3. -/
def sv8pt5_3 : Card := .pokemon
  { name := "Pinsir", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.grass, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Budew (sv8pt5-4). Records: sv8pt5-4, me2pt5-16, me2pt5-221. -/
def sv8pt5_4 : Card := .pokemon
  { name := "Budew", stage := .basic, evolvesFrom := none,
    hp := 3, type := .grass, retreat := 0, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Itchy Pollen", cost := [], damage := 1,
        effect := .linger .opp .next (.lock .item),
        gx := false }] }

/-- Litleo (sv8pt5-15). Records: sv8pt5-15. -/
def sv8pt5_15 : Card := .pokemon
  { name := "Litleo", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Combustion", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Headbutt", cost := [.fire, .fire, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Pyroar (sv8pt5-16). Records: sv8pt5-16. Caveats: perPokemon. -/
def sv8pt5_16 : Card := .pokemon
  { name := "Pyroar", stage := .stage1, evolvesFrom := some "Litleo",
    hp := 12, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fire Mane", cost := [.fire, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Flame Tackle", cost := [.fire, .fire, .colorless], damage := 16,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Slowpoke (sv8pt5-18). Records: sv8pt5-18. -/
def sv8pt5_18 : Card := .pokemon
  { name := "Slowpoke", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Water Gun", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Tail Whap", cost := [.water, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Suicune (sv8pt5-24). Records: sv8pt5-24. Caveats: benchMods. -/
def sv8pt5_24 : Card := .pokemon
  { name := "Suicune", stage := .basic, evolvesFrom := none,
    hp := 12, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Overrun", cost := [.colorless, .colorless], damage := 3,
        effect := .benchDamage .opp 3,
        gx := false },
      { name := "Aurora Beam", cost := [.water, .water, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Pikachu ex (sv8pt5-28). Records: sv8pt5-28. Caveats: recoil. -/
def sv8pt5_28 : Card := .pokemon
  { name := "Pikachu ex", stage := .basic, evolvesFrom := none,
    hp := 19, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Tail Whap", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Thunder", cost := [.lightning, .lightning, .colorless], damage := 22,
        effect := .selfDamage 3,
        gx := false }] }

/-- Spritzee (sv8pt5-38). Records: sv8pt5-38. -/
def sv8pt5_38 : Card := .pokemon
  { name := "Spritzee", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fairy Wind", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Aromatisse (sv8pt5-39). Records: sv8pt5-39. -/
def sv8pt5_39 : Card := .pokemon
  { name := "Aromatisse", stage := .stage1, evolvesFrom := some "Spritzee",
    hp := 12, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Perfume Press", cost := [.psychic, .colorless], damage := 6,
        effect := .inflict .confused,
        gx := false }] }

/-- Larvitar (sv8pt5-47). Records: sv8pt5-47. -/
def sv8pt5_47 : Card := .pokemon
  { name := "Larvitar", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Headbutt", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Pupitar (sv8pt5-48). Records: sv8pt5-48. -/
def sv8pt5_48 : Card := .pokemon
  { name := "Pupitar", stage := .stage1, evolvesFrom := some "Larvitar",
    hp := 9, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sand Spray", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Hammer In", cost := [.colorless, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Riolu (sv8pt5-50). Records: sv8pt5-50. -/
def sv8pt5_50 : Card := .pokemon
  { name := "Riolu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Quick Attack", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Hippopotas (sv8pt5-52). Records: sv8pt5-52. -/
def sv8pt5_52 : Card := .pokemon
  { name := "Hippopotas", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.colorless, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Hippowdon (sv8pt5-53). Records: sv8pt5-53. -/
def sv8pt5_53 : Card := .pokemon
  { name := "Hippowdon", stage := .stage1, evolvesFrom := some "Hippopotas",
    hp := 15, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sand Spray", cost := [.colorless, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false },
      { name := "Land Crush", cost := [.fighting, .colorless, .colorless, .colorless], damage := 14,
        effect := .skip,
        gx := false }] }

/-- Sneasel (sv8pt5-61). Records: sv8pt5-61. -/
def sv8pt5_61 : Card := .pokemon
  { name := "Sneasel", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 0, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Claw Slash", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Houndour (sv8pt5-62). Records: sv8pt5-62. -/
def sv8pt5_62 : Card := .pokemon
  { name := "Houndour", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Playful Kick", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Houndoom (sv8pt5-63). Records: sv8pt5-63. -/
def sv8pt5_63 : Card := .pokemon
  { name := "Houndoom", stage := .stage1, evolvesFrom := some "Houndour",
    hp := 12, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call to Muster", cost := [.darkness], damage := 0,
        effect := .seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) .shuffle,
        gx := false },
      { name := "Pitch-Black Fangs", cost := [.darkness, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Tyranitar ex (sv8pt5-64). Records: sv8pt5-64. -/
def sv8pt5_64 : Card := .pokemon
  { name := "Tyranitar ex", stage := .stage2, evolvesFrom := some "Pupitar",
    hp := 34, type := .darkness, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Grind", cost := [.colorless], damage := 0,
        effect := .damage (.count (.energy .own .energy) 5),
        gx := false },
      { name := "Tyrannical Crush", cost := [.darkness, .colorless, .colorless], damage := 15,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Bronzor (sv8pt5-66). Records: sv8pt5-66. -/
def sv8pt5_66 : Card := .pokemon
  { name := "Bronzor", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hammer In", cost := [.metal, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Bronzong (sv8pt5-67). Records: sv8pt5-67. Caveats: staticBench. -/
def sv8pt5_67 : Card := .pokemon
  { name := "Bronzong", stage := .stage1, evolvesFrom := some "Bronzor",
    hp := 13, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Protective Bell", use := .static [{ sel := .own, filt := .any, tgt := none, src := none, need := none, eff := .reduce 1 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Heavy Impact", cost := [.metal, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Heatran (sv8pt5-68). Records: sv8pt5-68. Caveats: perPokemon. -/
def sv8pt5_68 : Card := .pokemon
  { name := "Heatran", stage := .basic, evolvesFrom := none,
    hp := 13, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wrack Down", cost := [.metal, .colorless], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Iron Buster", cost := [.metal, .metal, .colorless], damage := 13,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Snorlax ex (sv8pt5-76). Records: sv8pt5-76. -/
def sv8pt5_76 : Card := .pokemon
  { name := "Snorlax ex", stage := .basic, evolvesFrom := none,
    hp := 26, type := .colorless, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Strength", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false },
      { name := "Toss-and-Turn Press", cost := [.colorless, .colorless, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 12)) (.choice (.damage (.const 24)) (.damage (.const 36)))),
        gx := false }] }

/-- Buneary (sv8pt5-83). Records: sv8pt5-83. -/
def sv8pt5_83 : Card := .pokemon
  { name := "Buneary", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smash Kick", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lopunny (sv8pt5-84). Records: sv8pt5-84. -/
def sv8pt5_84 : Card := .pokemon
  { name := "Lopunny", stage := .stage1, evolvesFrom := some "Buneary",
    hp := 9, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rear Kick", cost := [.colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Furfrou (sv8pt5-88). Records: sv8pt5-88. Caveats: staticBench. -/
def sv8pt5_88 : Card := .pokemon
  { name := "Furfrou", stage := .basic, evolvesFrom := none,
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Fur Coat", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 2 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Bite", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Noibat (sv8pt5-90). Records: sv8pt5-90. -/
def sv8pt5_90 : Card := .pokemon
  { name := "Noibat", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flap", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Noivern ex (sv8pt5-91). Records: sv8pt5-91. Caveats: recoil. -/
def sv8pt5_91 : Card := .pokemon
  { name := "Noivern ex", stage := .stage1, evolvesFrom := some "Noibat",
    hp := 27, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Strafe", cost := [.colorless], damage := 5,
        effect := .choice (.switch .own) .skip,
        gx := false },
      { name := "Sonic Blast", cost := [.colorless, .colorless, .colorless], damage := 22,
        effect := .selfDamage 3,
        gx := false }] }

/-- Friends in Paldea (sv8pt5-109). Records: sv8pt5-109, sv8pt5-137. -/
def sv8pt5_109 : Card := .trainer "Friends in Paldea" .supporter
    (.move .own (.top 3) .hand .any .all)

/-- Max Rod (sv8pt5-116). Records: sv8pt5-116. Caveats: aceSpec, upTo0. -/
def sv8pt5_116 : Card := .trainer "Max Rod" .item
    (.move .own .discard .hand (.or .pokemon .energy) (.upTo 5))

/-- Roto-Stick (sv8pt5-127). Records: sv8pt5-127. -/
def sv8pt5_127 : Card := .trainer "Roto-Stick" .item
    (.seq (.move .own (.top 4) .hand (.kind .supporter) (.upTo 4)) .shuffle)

/-- Treasure Tracker (sv8pt5-131). Records: sv8pt5-131. Caveats: aceSpec, upTo0. -/
def sv8pt5_131 : Card := .trainer "Treasure Tracker" .item
    (.seq (.move .own .deck .hand .tool (.upTo 5)) .shuffle)

/-- Caterpie (sv9-1). Records: sv9-1. -/
def sv9_1 : Card := .pokemon
  { name := "Caterpie", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bug Bite", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Paras (sv9-4). Records: sv9-4. -/
def sv9_4 : Card := .pokemon
  { name := "Paras", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leech Life", cost := [.grass], damage := 0,
        effect := .drain (.const 1),
        gx := false }] }

/-- Parasect (sv9-5). Records: sv9-5. -/
def sv9_5 : Card := .pokemon
  { name := "Parasect", stage := .stage1, evolvesFrom := some "Paras",
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spore", cost := [.colorless], damage := 0,
        effect := .inflict .asleep,
        gx := false },
      { name := "Scissor Swing", cost := [.grass, .colorless], damage := 0,
        effect := .choice (.damage (.const 6)) (.choice (.damage (.const 9)) (.damage (.const 12))),
        gx := false }] }

/-- Petilil (sv9-6). Records: sv9-6. -/
def sv9_6 : Card := .pokemon
  { name := "Petilil", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leaf Step", cost := [.grass, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Lilligant (sv9-7). Records: sv9-7. -/
def sv9_7 : Card := .pokemon
  { name := "Lilligant", stage := .stage1, evolvesFrom := some "Petilil",
    hp := 11, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Sunny Day", use := .static [{ sel := .own, filt := .or (.ptype .grass) (.ptype .fire), tgt := none, src := none, need := none, eff := .bonus 2 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Spinning Attack", cost := [.grass, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Maractus (sv9-8). Records: sv9-8, sv9-160. Caveats: perPokemon, trigAttacker, trigKO. -/
def sv9_8 : Card := .pokemon
  { name := "Maractus", stage := .basic, evolvesFrom := none,
    hp := 11, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Exploding Needles", use := .triggered .koByAttack false,
        spot := some .active, cond := none,
        effect := .fx (.counters 6) }],
    attacks := [
      { name := "Corner", cost := [.colorless], damage := 2,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Karrablast (sv9-9). Records: sv9-9. -/
def sv9_9 : Card := .pokemon
  { name := "Karrablast", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Push Down", cost := [.colorless], damage := 1,
        effect := .switch .opp,
        gx := false }] }

/-- Foongus (sv9-10). Records: sv9-10. -/
def sv9_10 : Card := .pokemon
  { name := "Foongus", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spore Ball", cost := [.grass], damage := 1,
        effect := .inflict .asleep,
        gx := false }] }

/-- Amoonguss ex (sv9-11). Records: sv9-11. -/
def sv9_11 : Card := .pokemon
  { name := "Amoonguss ex", stage := .stage1, evolvesFrom := some "Foongus",
    hp := 26, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Spore Ball", cost := [.grass], damage := 3,
        effect := .inflict .asleep,
        gx := false },
      { name := "Champignon's Swing", cost := [.grass, .colorless], damage := 0,
        effect := .choice (.damage (.const 18)) (.damage (.const 10)),
        gx := false }] }

/-- Shelmet (sv9-12). Records: sv9-12. Caveats: perPokemon. -/
def sv9_12 : Card := .pokemon
  { name := "Shelmet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shell Smack", cost := [.grass, .colorless], damage := 2,
        effect := .choice (.linger .own .next .prevent) .skip,
        gx := false }] }

/-- Accelgor (sv9-13). Records: sv9-13. -/
def sv9_13 : Card := .pokemon
  { name := "Accelgor", stage := .stage1, evolvesFrom := some "Shelmet",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poisonous Ploy", cost := [.grass, .colorless], damage := 7,
        effect := .seq (.seq (.inflict .confused) (.inflict .poisoned)) (.switch .own),
        gx := false }] }

/-- Durant (sv9-14). Records: sv9-14. -/
def sv9_14 : Card := .pokemon
  { name := "Durant", stage := .basic, evolvesFrom := none,
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Crunch", cost := [.grass, .colorless], damage := 5,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Virizion (sv9-15). Records: sv9-15. -/
def sv9_15 : Card := .pokemon
  { name := "Virizion", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leaf Drain", cost := [.grass, .colorless], damage := 3,
        effect := .heal 3,
        gx := false },
      { name := "Slicing Blade", cost := [.grass, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Sprigatito (sv9-16). Records: sv9-16. -/
def sv9_16 : Card := .pokemon
  { name := "Sprigatito", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tons of Treading", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.choice (.damage (.const 2)) (.damage (.const 3)))),
        gx := false }] }

/-- Nymble (sv9-19). Records: sv9-19. -/
def sv9_19 : Card := .pokemon
  { name := "Nymble", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rear Kick", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Magmar (sv9-20). Records: sv9-20. -/
def sv9_20 : Card := .pokemon
  { name := "Magmar", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Searing Flame", cost := [.fire, .colorless], damage := 3,
        effect := .choice (.inflict .burned) .skip,
        gx := false }] }

/-- Torchic (sv9-22). Records: sv9-22. -/
def sv9_22 : Card := .pokemon
  { name := "Torchic", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Combusken (sv9-23). Records: sv9-23. -/
def sv9_23 : Card := .pokemon
  { name := "Combusken", stage := .stage1, evolvesFrom := some "Torchic",
    hp := 9, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.fire, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Blaziken ex (sv9-24). Records: sv9-24. Caveats: mayFail, perPokemon. -/
def sv9_24 : Card := .pokemon
  { name := "Blaziken ex", stage := .stage2, evolvesFrom := some "Combusken",
    hp := 32, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Seething Spirit", use := .once,
        spot := none, cond := none,
        effect := .fx (.choice (.attach .own .discard .energy .active .any) (.attach .own .discard .energy .bench .any)) }],
    attacks := [
      { name := "Smolder-sault", cost := [.fire, .colorless], damage := 20,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Torkoal (sv9-25). Records: sv9-25. -/
def sv9_25 : Card := .pokemon
  { name := "Torkoal", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Live Coal", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Heat Blast", cost := [.fire, .fire, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- N's Darumaka (sv9-26). Records: sv9-26, me2pt5-32. -/
def sv9_26 : Card := .pokemon
  { name := "N's Darumaka", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Tackle", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Flare", cost := [.fire, .fire, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- N's Darmanitan (sv9-27). Records: sv9-27, me2pt5-33. Caveats: benchMods. -/
def sv9_27 : Card := .pokemon
  { name := "N's Darmanitan", stage := .stage1, evolvesFrom := some "N's Darumaka",
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Back Draft", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.pile .opp .discard .energy) 3),
        gx := false },
      { name := "Flamebody Cannon", cost := [.fire, .fire, .colorless], damage := 9,
        effect := .seq (.discardEnergy .own .active .energy .all) (.benchDamage .opp 9),
        gx := false }] }

/-- Larvesta (sv9-28). Records: sv9-28. -/
def sv9_28 : Card := .pokemon
  { name := "Larvesta", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Will-O-Wisp", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Volcarona (sv9-29). Records: sv9-29. -/
def sv9_29 : Card := .pokemon
  { name := "Volcarona", stage := .stage1, evolvesFrom := some "Larvesta",
    hp := 14, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smoldering Scales", cost := [.fire, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Reshiram ex (sv9-30). Records: sv9-30. -/
def sv9_30 : Card := .pokemon
  { name := "Reshiram ex", stage := .basic, evolvesFrom := none,
    hp := 22, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Fire Wing", cost := [.fire], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Scorching Fire", cost := [.fire, .fire, .colorless], damage := 20,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Articuno (sv9-32). Records: sv9-32, sv9-161. -/
def sv9_32 : Card := .pokemon
  { name := "Articuno", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Frigid Fluttering", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.attach .own .deck (.energyOf .water) .active .any) (.attach .own .deck (.energyOf .water) .active .any)) .shuffle,
        gx := false },
      { name := "Ice Blast", cost := [.water, .water, .colorless], damage := 11,
        effect := .skip,
        gx := false }] }

/-- Remoraid (sv9-33). Records: sv9-33. -/
def sv9_33 : Card := .pokemon
  { name := "Remoraid", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flail", cost := [.water], damage := 0,
        effect := .damage (.per .own 1),
        gx := false },
      { name := "Rain Splash", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lotad (sv9-35). Records: sv9-35. -/
def sv9_35 : Card := .pokemon
  { name := "Lotad", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Water Gun", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lombre (sv9-36). Records: sv9-36. Caveats: perPokemon. -/
def sv9_36 : Card := .pokemon
  { name := "Lombre", stage := .stage1, evolvesFrom := some "Lotad",
    hp := 9, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aqua Slash", cost := [.water, .water], damage := 7,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Wingull (sv9-38). Records: sv9-38. -/
def sv9_38 : Card := .pokemon
  { name := "Wingull", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flap", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Pelipper (sv9-39). Records: sv9-39. -/
def sv9_39 : Card := .pokemon
  { name := "Pelipper", stage := .stage1, evolvesFrom := some "Wingull",
    hp := 12, type := .water, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spit Up", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Speed Dive", cost := [.water, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Wailmer (sv9-40). Records: sv9-40. -/
def sv9_40 : Card := .pokemon
  { name := "Wailmer", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Surf", cost := [.colorless, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  sv8_9,
  sv8_10,
  sv8_12,
  sv8_13,
  sv8_16,
  sv8_17,
  sv8_21,
  sv8_22,
  sv8_23,
  sv8_24,
  sv8_25,
  sv8_27,
  sv8_28,
  sv8_29,
  sv8_30,
  sv8_32,
  sv8_33,
  sv8_36,
  sv8_40,
  sv8_41,
  sv8_43,
  sv8_44,
  sv8_46,
  sv8_47,
  sv8_49,
  sv8_50,
  sv8_51,
  sv8_52,
  sv8_53,
  sv8_54,
  sv8_58,
  sv8_62,
  sv8_63,
  sv8_66,
  sv8_70,
  sv8_71,
  sv8_73,
  sv8_77,
  sv8_78,
  sv8_81,
  sv8_82,
  sv8_84,
  sv8_85,
  sv8_87,
  sv8_88,
  sv8_90,
  sv8_92,
  sv8_97,
  sv8_98,
  sv8_99,
  sv8_102,
  sv8_104,
  sv8_108,
  sv8_109,
  sv8_112,
  sv8_117,
  sv8_118,
  sv8_120,
  sv8_122,
  sv8_124,
  sv8_125,
  sv8_126,
  sv8_127,
  sv8_129,
  sv8_132,
  sv8_134,
  sv8_136,
  sv8_138,
  sv8_139,
  sv8_140,
  sv8_144,
  sv8_145,
  sv8_146,
  sv8_148,
  sv8_152,
  sv8_154,
  sv8_155,
  sv8_157,
  sv8_159,
  sv8_162,
  sv8_170,
  sv8_177,
  sv8_178,
  sv8_180,
  sv8_183,
  sv8pt5_1,
  sv8pt5_2,
  sv8pt5_3,
  sv8pt5_4,
  sv8pt5_15,
  sv8pt5_16,
  sv8pt5_18,
  sv8pt5_24,
  sv8pt5_28,
  sv8pt5_38,
  sv8pt5_39,
  sv8pt5_47,
  sv8pt5_48,
  sv8pt5_50,
  sv8pt5_52,
  sv8pt5_53,
  sv8pt5_61,
  sv8pt5_62,
  sv8pt5_63,
  sv8pt5_64,
  sv8pt5_66,
  sv8pt5_67,
  sv8pt5_68,
  sv8pt5_76,
  sv8pt5_83,
  sv8pt5_84,
  sv8pt5_88,
  sv8pt5_90,
  sv8pt5_91,
  sv8pt5_109,
  sv8pt5_116,
  sv8pt5_127,
  sv8pt5_131,
  sv9_1,
  sv9_4,
  sv9_5,
  sv9_6,
  sv9_7,
  sv9_8,
  sv9_9,
  sv9_10,
  sv9_11,
  sv9_12,
  sv9_13,
  sv9_14,
  sv9_15,
  sv9_16,
  sv9_19,
  sv9_20,
  sv9_22,
  sv9_23,
  sv9_24,
  sv9_25,
  sv9_26,
  sv9_27,
  sv9_28,
  sv9_29,
  sv9_30,
  sv9_32,
  sv9_33,
  sv9_35,
  sv9_36,
  sv9_38,
  sv9_39,
  sv9_40]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = ["Gravity Mountain", "Lively Stadium"] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Victini", "Lilligant"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Cetitan", "Bronzong", "Furfrou"] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = [] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 10 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 10)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Bruxish"] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.koByAttack` (milestone M8b), by name. -/
theorem cards_trigKO : (cards.filter (Card.hasTrig .koByAttack)).map Card.label = ["Amulet of Hope", "Maractus"] := by decide +kernel

/-- The cards of this part whose triggered Abilities write a lingering modifier (milestone M8b), by name. -/
theorem cards_trigLingers : (cards.filter Card.trigLingers).map Card.label = [] := by decide +kernel

/-- The cards of this part whose triggered Abilities can return a card from a discard pile (milestone M8b), by name. -/
theorem cards_trigRecycles : (cards.filter Card.trigRecycles).map Card.label = [] := by decide +kernel

/-- Every triggered Ability of this part has no printed condition and an effect of the trigger
fragment (`Card.trigsOk`). -/
theorem cards_trigsOk : cards.all Card.trigsOk = true := by decide +kernel

/-- The cards of this part that are not `Card.tame` (a `drain` attack or a stored damage reduction), by
name. -/
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Volcarona", "Skarmory", "Jasmine's Gaze", "Paras"] := by decide +kernel

end PokemonCards.Standard.Part03
