/-
Imported Standard cards, part 3 of 11 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.20.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part03
open Pokemon

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

/-- Salazzle (sv7-24). Records: sv7-24, me2pt5-35, me2pt5-224. -/
def sv7_24 : Card := .pokemon
  { name := "Salazzle", stage := .stage1, evolvesFrom := some "Salandit",
    hp := 12, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Sudden Scorching", cost := [.colorless, .colorless], damage := 0,
        effect := .seq (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip) (.ite (.evolved .own) (.ite (.countGe (.pile .opp .hand .any) 2) (.move .opp .hand .discard .any (.exactly 2)) (.move .opp .hand .discard .any .all)) .skip),
        gx := false },
      { name := "Flamethrower", cost := [.fire, .colorless, .colorless], damage := 13,
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

/-- Lumineon (sv7-36). Records: sv7-36. -/
def sv7_36 : Card := .pokemon
  { name := "Lumineon", stage := .stage1, evolvesFrom := some "Finneon",
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Return", cost := [.colorless], damage := 2,
        effect := .choice (.drawTo .own 6) .skip,
        gx := false },
      { name := "Razor Fin", cost := [.water, .colorless], damage := 7,
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

/-- Galvantula ex (sv7-51). Records: sv7-51, sv7-159, sv7-168. -/
def sv7_51 : Card := .pokemon
  { name := "Galvantula ex", stage := .stage1, evolvesFrom := some "Joltik",
    hp := 26, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Charged Web", cost := [.lightning, .colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 22)) (.damage (.const 11)),
        gx := false },
      { name := "Fulgurite", cost := [.grass, .lightning, .fighting], damage := 18,
        effect := .seq (.discardEnergy .own .active .energy .all) (.linger .opp .next (.lock .item)),
        gx := false }] }

/-- Togedemaru (sv7-54). Records: sv7-54. -/
def sv7_54 : Card := .pokemon
  { name := "Togedemaru", stage := .basic, evolvesFrom := none,
    hp := 8, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electrifying Chance", cost := [.lightning], damage := 3,
        effect := .ite (.countGe (.prizes .own) 1) (.ite (.countGe (.prizes .own) 2) .skip (.inflict .paralyzed)) .skip,
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

/-- Medicham ex (sv7-80). Records: sv7-80, sv7-161. -/
def sv7_80 : Card := .pokemon
  { name := "Medicham ex", stage := .stage1, evolvesFrom := some "Meditite",
    hp := 26, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Chi-Atsu", cost := [.colorless, .colorless], damage := 0,
        effect := .hitBy .opp .active 1 .any false false (.toHp 5),
        gx := false },
      { name := "Yoga Kick", cost := [.fighting, .colorless, .colorless], damage := 0,
        effect := .damage (.const 19) { weak := true, resist := true },
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

/-- Diancie (sv7-86). Records: sv7-86. Caveats: specialCountCards. -/
def sv7_86 : Card := .pokemon
  { name := "Diancie", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Diffuse Reflection", cost := [.colorless], damage := 0,
        effect := .damage (.count (.energyAll .opp .specialEnergy) 4),
        gx := false },
      { name := "Power Gem", cost := [.fighting, .colorless], damage := 6,
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

/-- Falinks (sv7-88). Records: sv7-88. Caveats: usedLastBench. -/
def sv7_88 : Card := .pokemon
  { name := "Falinks", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Form Ranks", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false, selfLock := .note },
      { name := "All-Out Attack", cost := [.colorless, .colorless], damage := 0,
        effect := .ite (.usedLast .own) (.damage (.const 12)) (.damage (.const 3)),
        gx := false }] }

/-- Koraidon (sv7-90). Records: sv7-90. -/
def sv7_90 : Card := .pokemon
  { name := "Koraidon", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Resolute Fang", cost := [.fighting, .fighting], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 12)) (.damage (.const 5)),
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
        effect := .attach .own .discard .basicEnergy .bench .any,
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

/-- Melmetal (sv7-104). Records: sv7-104. -/
def sv7_104 : Card := .pokemon
  { name := "Melmetal", stage := .stage1, evolvesFrom := some "Meltan",
    hp := 16, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wrack Down", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Reforged Axe", cost := [.metal, .colorless, .colorless], damage := 0,
        effect := .ite (.hasTool .own) (.seq (.discardTools .own .active) (.damage (.const 25))) .skip,
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

/-- Archaludon (sv7-107). Records: sv7-107, sv7-155, sv8pt5-70. Caveats: energyOfCount, noRetreatLast. -/
def sv7_107 : Card := .pokemon
  { name := "Archaludon", stage := .stage1, evolvesFrom := some "Duraludon",
    hp := 18, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Metal Bridge", use := .static [{ sel := .own, filt := .any, tgt := none, src := none, need := some (.energyOf .metal, 1), eff := .noRetreat }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Iron Blaster", cost := [.metal, .metal, .colorless], damage := 16,
        effect := .skip,
        gx := false, selfLock := .all }] }

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

/-- Raging Bolt (sv7-111). Records: sv7-111. Caveats: benchMods. -/
def sv7_111 : Card := .pokemon
  { name := "Raging Bolt", stage := .basic, evolvesFrom := none,
    hp := 13, type := .dragon, retreat := 3, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunderburst Storm", cost := [.lightning, .fighting], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.count (.energy .own .energy) 3)) (.hitBy .opp .bench 1 .any false true (.count (.energy .own .energy) 3))) (.damage (.count (.energy .own .energy) 3)),
        gx := false },
      { name := "Dragon Headbutt", cost := [.lightning, .fighting, .colorless], damage := 13,
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

/-- Purugly (sv7-117). Records: sv7-117. Caveats: perPokemon, shieldReach. -/
def sv7_117 : Card := .pokemon
  { name := "Purugly", stage := .stage1, evolvesFrom := some "Glameow",
    hp := 12, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nyan Roll", cost := [.colorless, .colorless], damage := 8,
        effect := .choice (.seq (.linger .own .next .prevent) (.linger .own .next .shield)) .skip,
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

/-- Deluxe Bomb (sv7-134). Records: sv7-134. Caveats: aceSpec, trigAttached, trigAttacker, trigDamaged. -/
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

/-- Lacey (sv7-139). Records: sv7-139, sv7-166, sv7-172, sv8pt5-114, sv8pt5-175. -/
def sv7_139 : Card := .trainer "Lacey" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .own .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.move .own .hand .shuffle .any .all) (.ite (.countGe (.prizes .opp) 4) (.move .own (.top 4) .hand .any .all) (.move .own (.top 8) .hand .any .all))))

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

/-- Exeggutor (sv8-3). Records: sv8-3. Caveats: energyUnitsCount. -/
def sv8_3 : Card := .pokemon
  { name := "Exeggutor", stage := .stage1, evolvesFrom := some "Exeggcute",
    hp := 13, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Barrage O'Clock", cost := [.grass], damage := 0,
        effect := .damage (.heads (.add (.count (.energy .own .energy) 1) (.count (.energy .opp .energy) 1)) 6),
        gx := false }] }

/-- Durant ex (sv8-4). Records: sv8-4, sv8-215, sv8-236. Caveats: prizes6. -/
def sv8_4 : Card := .pokemon
  { name := "Durant ex", stage := .basic, evolvesFrom := none,
    hp := 19, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Sudden Shearing", use := .onPlay .bench,
        spot := none, cond := none,
        effect := .fx (.move .opp (.top 1) .discard .any .all) }],
    attacks := [
      { name := "Vengeful Crush", cost := [.grass, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 12) (.count (.prizesTaken .opp) 3)),
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

/-- Shiinotic (sv8-9). Records: sv8-9, sv8-194. -/
def sv8_9 : Card := .pokemon
  { name := "Shiinotic", stage := .stage1, evolvesFrom := some "Morelull",
    hp := 11, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Calming Light", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.ite (.cond .opp .asleep) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.inflict .asleep)) }],
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

/-- Zarude (sv8-11). Records: sv8-11. -/
def sv8_11 : Card := .pokemon
  { name := "Zarude", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Leaf Drain", cost := [.grass], damage := 2,
        effect := .heal 2,
        gx := false },
      { name := "Jungle Whip", cost := [.grass, .grass, .colorless], damage := 0,
        effect := .choice (.damage (.const 8)) (.seq (.returnEnergy .own .active .energy .all .hand) (.damage (.const 16))),
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

/-- Rabsca (sv8-14). Records: sv8-14. -/
def sv8_14 : Card := .pokemon
  { name := "Rabsca", stage := .stage1, evolvesFrom := some "Rellor",
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Triple Draw", cost := [.colorless], damage := 0,
        effect := .move .own (.top 3) .hand .any .all,
        gx := false },
      { name := "Counterturn", cost := [.grass], damage := 0,
        effect := .ite (.countGe (.pile .own .deck .any) 4) (.damage (.const 4)) (.damage (.const 24)),
        gx := false }] }

/-- Wo-Chien (sv8-15). Records: sv8-15. Caveats: benchMods. -/
def sv8_15 : Card := .pokemon
  { name := "Wo-Chien", stage := .basic, evolvesFrom := none,
    hp := 13, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hazardous Greed", cost := [.grass, .colorless], damage := 2,
        effect := .ite (.countGe (.pile .own .deck .any) 4) .skip (.benchSome .opp 2 .any true 12),
        gx := false },
      { name := "Entangling Whip", cost := [.grass, .grass, .colorless], damage := 13,
        effect := .move .own (.top 3) .discard .any .all,
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

/-- Paldean Tauros (sv8-18). Records: sv8-18. -/
def sv8_18 : Card := .pokemon
  { name := "Paldean Tauros", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rear Kick", cost := [.fire], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Spirited Tackle", cost := [.fire, .colorless, .colorless], damage := 0,
        effect := .ite (.top .opp (.stage .stage1)) (.damage (.const 18)) (.damage (.const 9)),
        gx := false }] }

/-- Ho-Oh (sv8-19). Records: sv8-19. -/
def sv8_19 : Card := .pokemon
  { name := "Ho-Oh", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flap", cost := [.fire, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Shining Blaze", cost := [.fire, .fire, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .own (.and .pokemon .tera)) 1) (.damage (.const 20)) (.damage (.const 10)),
        gx := false }] }

/-- Castform Sunny Form (sv8-20). Records: sv8-20, sv8-195. -/
def sv8_20 : Card := .pokemon
  { name := "Castform Sunny Form", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 0, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Singe", cost := [.fire], damage := 0,
        effect := .inflict .burned,
        gx := false },
      { name := "Sunny Assist", cost := [.fire, .colorless], damage := 5,
        effect := .shiftEnergy .own .active .energy .all .bench true,
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

/-- Skeledirge (sv8-31). Records: sv8-31. Caveats: shieldActive, shieldReach. -/
def sv8_31 : Card := .pokemon
  { name := "Skeledirge", stage := .stage2, evolvesFrom := some "Crocalor",
    hp := 18, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Unaware", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .shield .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Torcherto", cost := [.fire, .colorless], damage := 0,
        effect := .damage (.add (.const 6) (.add (.count (.bench .own .pokemon) 2) (.count (.bench .opp .pokemon) 2))),
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

/-- Armarouge (sv8-34). Records: sv8-34. Caveats: benchMods, energyOfCount. -/
def sv8_34 : Card := .pokemon
  { name := "Armarouge", stage := .stage1, evolvesFrom := some "Charcadet",
    hp := 14, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Combustion", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Crimson Blaster", cost := [.fire, .fire, .colorless], damage := 0,
        effect := .seq (.discardEnergy .own .active (.energyOf .fire) .all) (.benchDamage .opp 18),
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

/-- Paldean Tauros (sv8-39). Records: sv8-39. Caveats: moveUnits. -/
def sv8_39 : Card := .pokemon
  { name := "Paldean Tauros", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Upthrusting Horns", cost := [.colorless, .colorless], damage := 3,
        effect := .choice (.ite (.top .opp (.stage .stage2)) (.ite (.countGe (.energy .opp .energy) 2) (.returnEnergy .opp .active .energy (.exactly 2) .hand) (.returnEnergy .opp .active .energy .all .hand)) .skip) .skip,
        gx := false },
      { name := "Jet Headbutt", cost := [.water, .water, .colorless], damage := 10,
        effect := .skip,
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

/-- Milotic ex (sv8-42). Records: sv8-42, sv8-217, sv8-237. Caveats: shieldActive, shieldReach. -/
def sv8_42 : Card := .pokemon
  { name := "Milotic ex", stage := .stage1, evolvesFrom := some "Feebas",
    hp := 27, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Sparkling Scales", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .prevent .tera }, { sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .shield .tera }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Hypno Splash", cost := [.water, .colorless, .colorless], damage := 16,
        effect := .inflict .asleep,
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

/-- Black Kyurem ex (sv8-48). Records: sv8-48, sv8-218. Caveats: recoil. -/
def sv8_48 : Card := .pokemon
  { name := "Black Kyurem ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Ice Age", cost := [.colorless, .colorless, .colorless], damage := 9,
        effect := .ite (.isType .opp .dragon) (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Black Frost", cost := [.water, .water, .colorless, .colorless], damage := 25,
        effect := .selfDamage 3,
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
        effect := .fx (.seq (.move .own .hand .bottom .any (.exactly 1)) (.seq (.seq (.ite (.countGe (.pile .own .hand .any) 5) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.drawTo .own 5))) }],
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

/-- Iron Bundle (sv8-55). Records: sv8-55. Caveats: printedRetreat. -/
def sv8_55 : Card := .pokemon
  { name := "Iron Bundle", stage := .basic, evolvesFrom := none,
    hp := 10, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gusting Collision", cost := [.water, .water, .colorless], damage := 0,
        effect := .damage (.sub (.const 20) (.count (.retreat .opp) 5)),
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

/-- Magnezone (sv8-60). Records: sv8-60. Caveats: perPokemon. -/
def sv8_60 : Card := .pokemon
  { name := "Magnezone", stage := .stage2, evolvesFrom := some "Magneton",
    hp := 17, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mighty Magnetism", cost := [.lightning, .colorless, .colorless], damage := 8,
        effect := .seq (.inflict .confused) (.linger .opp .next (.lock .retreat)),
        gx := false },
      { name := "Zap Cannon", cost := [.lightning, .colorless, .colorless, .colorless], damage := 18,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- The cards of this part. -/
def cards : List Card := [
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
  sv7_18,
  sv7_19,
  sv7_20,
  sv7_22,
  sv7_23,
  sv7_24,
  sv7_25,
  sv7_26,
  sv7_27,
  sv7_29,
  sv7_31,
  sv7_33,
  sv7_34,
  sv7_35,
  sv7_36,
  sv7_37,
  sv7_38,
  sv7_39,
  sv7_40,
  sv7_41,
  sv7_43,
  sv7_46,
  sv7_47,
  sv7_48,
  sv7_51,
  sv7_54,
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
  sv7_80,
  sv7_81,
  sv7_82,
  sv7_83,
  sv7_84,
  sv7_85,
  sv7_86,
  sv7_87,
  sv7_88,
  sv7_90,
  sv7_91,
  sv7_94,
  sv7_95,
  sv7_97,
  sv7_98,
  sv7_99,
  sv7_100,
  sv7_102,
  sv7_103,
  sv7_104,
  sv7_105,
  sv7_106,
  sv7_107,
  sv7_108,
  sv7_109,
  sv7_111,
  sv7_112,
  sv7_113,
  sv7_114,
  sv7_116,
  sv7_117,
  sv7_120,
  sv7_121,
  sv7_122,
  sv7_124,
  sv7_125,
  sv7_126,
  sv7_127,
  sv7_134,
  sv7_137,
  sv7_139,
  sv8_2,
  sv8_3,
  sv8_4,
  sv8_5,
  sv8_6,
  sv8_8,
  sv8_9,
  sv8_10,
  sv8_11,
  sv8_12,
  sv8_13,
  sv8_14,
  sv8_15,
  sv8_16,
  sv8_17,
  sv8_18,
  sv8_19,
  sv8_20,
  sv8_21,
  sv8_22,
  sv8_23,
  sv8_24,
  sv8_25,
  sv8_27,
  sv8_28,
  sv8_29,
  sv8_30,
  sv8_31,
  sv8_32,
  sv8_33,
  sv8_34,
  sv8_36,
  sv8_39,
  sv8_40,
  sv8_41,
  sv8_42,
  sv8_43,
  sv8_44,
  sv8_46,
  sv8_47,
  sv8_48,
  sv8_49,
  sv8_50,
  sv8_51,
  sv8_52,
  sv8_53,
  sv8_54,
  sv8_55,
  sv8_58,
  sv8_60]

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
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Carracosta", "Victini"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Dubwool", "Cetitan"] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = ["Archaludon", "Gravity Gemstone"] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 25 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 25)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Deluxe Bomb", "Bruxish"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Drifloon", "Tornadus", "Volcarona"] := by decide +kernel

end PokemonCards.Standard.Part03
