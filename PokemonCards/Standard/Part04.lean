/-
Imported Standard cards, part 4 of 9 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.8.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part04
open Pokemon

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

/-- Regigigas (sv8pt5-86). Records: sv8pt5-86. -/
def sv8pt5_86 : Card := .pokemon
  { name := "Regigigas", stage := .basic, evolvesFrom := none,
    hp := 16, type := .colorless, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Jewel Breaker", cost := [.colorless, .colorless, .colorless, .colorless], damage := 0,
        effect := .ite (.top .opp .tera) (.damage (.const 33)) (.damage (.const 10)),
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

/-- Hawlucha (sv8pt5-89). Records: sv8pt5-89. -/
def sv8pt5_89 : Card := .pokemon
  { name := "Hawlucha", stage := .basic, evolvesFrom := none,
    hp := 8, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rising Tackle", cost := [.colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 6)) (.damage (.const 1)),
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

/-- Meowscarada (sv9-18). Records: sv9-18. Caveats: selfBench. -/
def sv9_18 : Card := .pokemon
  { name := "Meowscarada", stage := .stage2, evolvesFrom := some "Floragato",
    hp := 16, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Showtime", use := .once,
        spot := some .bench, cond := none,
        effect := .self .switchIn }],
    attacks := [
      { name := "Rising Bloom", cost := [.colorless, .colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 18)) (.damage (.const 9)),
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

/-- Wailord (sv9-41). Records: sv9-41, sv9-162. -/
def sv9_41 : Card := .pokemon
  { name := "Wailord", stage := .stage1, evolvesFrom := some "Wailmer",
    hp := 24, type := .water, retreat := 4, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hydro Pump", cost := [.colorless, .colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 1) (.count (.energy .own (.energyOf .water)) 5)),
        gx := false }] }

/-- Regice (sv9-42). Records: sv9-42. Caveats: benchMods. -/
def sv9_42 : Card := .pokemon
  { name := "Regice", stage := .basic, evolvesFrom := none,
    hp := 12, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Icicle", cost := [.water, .colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Blizzard", cost := [.water, .colorless, .colorless], damage := 9,
        effect := .spreadDamage .opp 1,
        gx := false }] }

/-- Alolan Geodude (sv9-44). Records: sv9-44. -/
def sv9_44 : Card := .pokemon
  { name := "Alolan Geodude", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knuckle Punch", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Tiny Charge", cost := [.lightning, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Alolan Graveler (sv9-45). Records: sv9-45. -/
def sv9_45 : Card := .pokemon
  { name := "Alolan Graveler", stage := .stage1, evolvesFrom := some "Alolan Geodude",
    hp := 10, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Tackle", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Electric Punch", cost := [.lightning, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Alolan Golem (sv9-46). Records: sv9-46. Caveats: recoil. -/
def sv9_46 : Card := .pokemon
  { name := "Alolan Golem", stage := .stage2, evolvesFrom := some "Alolan Graveler",
    hp := 18, type := .lightning, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Electromagnetic Catapult", cost := [.lightning], damage := 0,
        effect := .damage (.many (.const 7)),
        gx := false },
      { name := "Megaton Fall", cost := [.lightning, .colorless], damage := 16,
        effect := .selfDamage 4,
        gx := false }] }

/-- Tapu Koko ex (sv9-51). Records: sv9-51. -/
def sv9_51 : Card := .pokemon
  { name := "Tapu Koko ex", stage := .basic, evolvesFrom := none,
    hp := 20, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Linked Lightning", cost := [.lightning, .colorless], damage := 0,
        effect := .damage (.add (.const 6) (.count (.bench .own .pokemon) 2)),
        gx := false }] }

/-- Iono's Tadbulb (sv9-52). Records: sv9-52, me2pt5-69. -/
def sv9_52 : Card := .pokemon
  { name := "Iono's Tadbulb", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tiny Charge", cost := [.lightning, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Iono's Wattrel (sv9-54). Records: sv9-54, me2pt5-71, me2pt5-231. -/
def sv9_54 : Card := .pokemon
  { name := "Iono's Wattrel", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Quick Attack", cost := [.lightning], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Alolan Marowak (sv9-57). Records: sv9-57. Caveats: koAttackWide. -/
def sv9_57 : Card := .pokemon
  { name := "Alolan Marowak", stage := .stage1, evolvesFrom := some "Cubone",
    hp := 12, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Retaliate", cost := [.psychic], damage := 0,
        effect := .ite (.countGe (.koLast .own true) 1) (.damage (.const 12)) (.damage (.const 3)),
        gx := false },
      { name := "Will-O-Wisp", cost := [.psychic, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Shuppet (sv9-59). Records: sv9-59, me2pt5-90. -/
def sv9_59 : Card := .pokemon
  { name := "Shuppet", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spooky Shot", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Beldum (sv9-61). Records: sv9-61. -/
def sv9_61 : Card := .pokemon
  { name := "Beldum", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spinning Attack", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Beam", cost := [.psychic, .psychic], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Metang (sv9-62). Records: sv9-62. -/
def sv9_62 : Card := .pokemon
  { name := "Metang", stage := .stage1, evolvesFrom := some "Beldum",
    hp := 10, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Psypunch", cost := [.psychic], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Zen Headbutt", cost := [.psychic, .psychic], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Oricorio (sv9-65). Records: sv9-65. -/
def sv9_65 : Card := .pokemon
  { name := "Oricorio", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Spooky Shot", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lillie's Cutiefly (sv9-66). Records: sv9-66. -/
def sv9_66 : Card := .pokemon
  { name := "Lillie's Cutiefly", stage := .basic, evolvesFrom := none,
    hp := 3, type := .psychic, retreat := 0, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hold Still", cost := [.psychic], damage := 0,
        effect := .heal 1,
        gx := false }] }

/-- Mimikyu ex (sv9-69). Records: sv9-69. -/
def sv9_69 : Card := .pokemon
  { name := "Mimikyu ex", stage := .basic, evolvesFrom := none,
    hp := 19, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Mischievous Hands", cost := [.psychic, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .any) 2) (.choice (.seq (.counters 3) (.benchSome .opp 1 .any false 3)) (.benchSome .opp 2 .any false 3)) (.seq (.counters 3) (.benchSome .opp 1 .any false 3)),
        gx := false },
      { name := "Ghostly Trip", cost := [.psychic, .psychic, .colorless], damage := 12,
        effect := .inflict .confused,
        gx := false }] }

/-- Dhelmise (sv9-70). Records: sv9-70. Caveats: perPokemon. -/
def sv9_70 : Card := .pokemon
  { name := "Dhelmise", stage := .basic, evolvesFrom := none,
    hp := 13, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bind Down", cost := [.psychic, .colorless, .colorless], damage := 6,
        effect := .linger .opp .next (.lock .retreat),
        gx := false },
      { name := "Anchor Smash", cost := [.psychic, .psychic, .colorless, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Impidimp (sv9-71). Records: sv9-71. -/
def sv9_71 : Card := .pokemon
  { name := "Impidimp", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Morgrem (sv9-72). Records: sv9-72. -/
def sv9_72 : Card := .pokemon
  { name := "Morgrem", stage := .stage1, evolvesFrom := some "Impidimp",
    hp := 9, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Light Punch", cost := [.psychic], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Smash Kick", cost := [.psychic, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Milcery (sv9-74). Records: sv9-74. -/
def sv9_74 : Card := .pokemon
  { name := "Milcery", stage := .basic, evolvesFrom := none,
    hp := 5, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Alcremie ex (sv9-75). Records: sv9-75. Caveats: noopUse. -/
def sv9_75 : Card := .pokemon
  { name := "Alcremie ex", stage := .stage1, evolvesFrom := some "Milcery",
    hp := 25, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Confectionary Gift", use := .once,
        spot := none, cond := none,
        effect := .fx (.ite (.countGe (.bench .own .pokemon) 1) (.choice (.heal 3) (.benchHeal 3)) (.heal 3)) }],
    attacks := [
      { name := "Whipped Shot", cost := [.psychic, .colorless, .colorless], damage := 16,
        effect := .skip,
        gx := false }] }

/-- Cubone (sv9-76). Records: sv9-76. -/
def sv9_76 : Card := .pokemon
  { name := "Cubone", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stampede", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Light Punch", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Swinub (sv9-77). Records: sv9-77, sv9-165. -/
def sv9_77 : Card := .pokemon
  { name := "Swinub", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Lunge Out", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Piloswine (sv9-78). Records: sv9-78. -/
def sv9_78 : Card := .pokemon
  { name := "Piloswine", stage := .stage1, evolvesFrom := some "Swinub",
    hp := 10, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Strength", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Impaling Tusk", cost := [.fighting, .fighting], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Larvitar (sv9-80). Records: sv9-80. -/
def sv9_80 : Card := .pokemon
  { name := "Larvitar", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Crunch", cost := [.colorless, .colorless], damage := 2,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Pupitar (sv9-81). Records: sv9-81. Caveats: recoil. -/
def sv9_81 : Card := .pokemon
  { name := "Pupitar", stage := .stage1, evolvesFrom := some "Larvitar",
    hp := 9, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Take Down", cost := [.colorless, .colorless], damage := 6,
        effect := .selfDamage 2,
        gx := false }] }

/-- Regirock (sv9-82). Records: sv9-82. Caveats: staticBench. -/
def sv9_82 : Card := .pokemon
  { name := "Regirock", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Rock Armor", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := some (.energy, 1), eff := .reduce 3 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Breaching Lariat", cost := [.fighting, .fighting, .fighting], damage := 0,
        effect := .damage (.const 12) { resist := true },
        gx := false }] }

/-- Pancham (sv9-83). Records: sv9-83. -/
def sv9_83 : Card := .pokemon
  { name := "Pancham", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Corkscrew Punch", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Focus Fist", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 5)) .skip,
        gx := false }] }

/-- Hop's Silicobra (sv9-86). Records: sv9-86. -/
def sv9_86 : Card := .pokemon
  { name := "Hop's Silicobra", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Turf Maker", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .stadium) (.upTo 1)) .shuffle,
        gx := false },
      { name := "Gnaw", cost := [.fighting, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Hop's Sandaconda (sv9-87). Records: sv9-87. Caveats: benchMods, perPokemon. -/
def sv9_87 : Card := .pokemon
  { name := "Hop's Sandaconda", stage := .stage1, evolvesFrom := some "Hop's Silicobra",
    hp := 14, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rumble", cost := [.fighting, .colorless], damage := 3,
        effect := .linger .opp .next (.lock .retreat),
        gx := false },
      { name := "Break Ground", cost := [.fighting, .colorless, .colorless], damage := 14,
        effect := .spreadDamage .own 2,
        gx := false }] }

/-- Toedscool (sv9-88). Records: sv9-88. -/
def sv9_88 : Card := .pokemon
  { name := "Toedscool", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spray Fluid", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Toedscruel (sv9-89). Records: sv9-89. -/
def sv9_89 : Card := .pokemon
  { name := "Toedscruel", stage := .stage1, evolvesFrom := some "Toedscool",
    hp := 13, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Secret Forest Path", use := .static [{ sel := .own, filt := .any, tgt := some .active, src := some .bench, need := none, eff := .retreatMinus 2 }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Mud Shot", cost := [.fighting, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Klawf (sv9-90). Records: sv9-90. -/
def sv9_90 : Card := .pokemon
  { name := "Klawf", stage := .basic, evolvesFrom := none,
    hp := 12, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Snipping Pincers", cost := [.colorless, .colorless], damage := 0,
        effect := .choice .skip (.choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) (.seq (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip))),
        gx := false },
      { name := "Hammer In", cost := [.fighting, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Koffing (sv9-91). Records: sv9-91. -/
def sv9_91 : Card := .pokemon
  { name := "Koffing", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tackle", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Suffocating Gas", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Paldean Wooper (sv9-93). Records: sv9-93, me2-102. -/
def sv9_93 : Card := .pokemon
  { name := "Paldean Wooper", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Trip Over", cost := [.darkness], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Paldean Clodsire ex (sv9-94). Records: sv9-94. Caveats: perPokemon. -/
def sv9_94 : Card := .pokemon
  { name := "Paldean Clodsire ex", stage := .stage1, evolvesFrom := some "Paldean Wooper",
    hp := 28, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Ring", cost := [.darkness, .colorless], damage := 6,
        effect := .seq (.inflict .poisoned) (.linger .opp .next (.lock .retreat)),
        gx := false },
      { name := "Giga Impact", cost := [.darkness, .darkness, .colorless], damage := 22,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- N's Zorua (sv9-97). Records: sv9-97, me2pt5-136. -/
def sv9_97 : Card := .pokemon
  { name := "N's Zorua", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lokix (sv9-100). Records: sv9-100. -/
def sv9_100 : Card := .pokemon
  { name := "Lokix", stage := .stage1, evolvesFrom := some "Nymble",
    hp := 12, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Low Sweep", cost := [.darkness], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Bombirdier (sv9-101). Records: sv9-101. Caveats: benchMods. -/
def sv9_101 : Card := .pokemon
  { name := "Bombirdier", stage := .basic, evolvesFrom := none,
    hp := 12, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Glide", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Drop Shot", cost := [.darkness, .darkness, .colorless], damage := 0,
        effect := .seq (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 12)) (.benchDamage .opp 12)) (.damage (.const 12))) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Escavalier (sv9-102). Records: sv9-102. Caveats: perPokemon. -/
def sv9_102 : Card := .pokemon
  { name := "Escavalier", stage := .stage1, evolvesFrom := some "Karrablast",
    hp := 12, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pierce", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Iron Buster", cost := [.metal, .colorless], damage := 12,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- N's Klink (sv9-103). Records: sv9-103. -/
def sv9_103 : Card := .pokemon
  { name := "N's Klink", stage := .basic, evolvesFrom := none,
    hp := 6, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Spin", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- N's Klang (sv9-104). Records: sv9-104. -/
def sv9_104 : Card := .pokemon
  { name := "N's Klang", stage := .stage1, evolvesFrom := some "N's Klink",
    hp := 9, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spinning Gears", cost := [.colorless], damage := 2,
        effect := .inflict .confused,
        gx := false },
      { name := "Confront", cost := [.metal, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- N's Klinklang (sv9-105). Records: sv9-105. -/
def sv9_105 : Card := .pokemon
  { name := "N's Klinklang", stage := .stage2, evolvesFrom := some "N's Klang",
    hp := 16, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Magnetic Blast", cost := [.colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Triple Smash", cost := [.metal, .metal, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 12)) (.choice (.damage (.const 24)) (.damage (.const 36)))),
        gx := false }] }

/-- Galarian Stunfisk (sv9-106). Records: sv9-106. Caveats: recoil. -/
def sv9_106 : Card := .pokemon
  { name := "Galarian Stunfisk", stage := .basic, evolvesFrom := none,
    hp := 10, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mud-Slap", cost := [.colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Bounding Bite", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .selfDamage 3,
        gx := false }] }

/-- Hop's Corviknight (sv9-108). Records: sv9-108. Caveats: benchMods, perPokemon. -/
def sv9_108 : Card := .pokemon
  { name := "Hop's Corviknight", stage := .stage2, evolvesFrom := some "Hop's Corvisquire",
    hp := 17, type := .metal, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shoot Through", cost := [.colorless], damage := 5,
        effect := .benchDamage .opp 5,
        gx := false },
      { name := "Steel Wing", cost := [.metal, .metal, .colorless], damage := 15,
        effect := .linger .own .next (.reduce 6),
        gx := false }] }

/-- Cufant (sv9-109). Records: sv9-109. -/
def sv9_109 : Card := .pokemon
  { name := "Cufant", stage := .basic, evolvesFrom := none,
    hp := 10, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rollout", cost := [.metal, .metal, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Copperajah (sv9-110). Records: sv9-110. -/
def sv9_110 : Card := .pokemon
  { name := "Copperajah", stage := .stage1, evolvesFrom := some "Cufant",
    hp := 19, type := .metal, retreat := 4, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.metal, .metal, .colorless], damage := 10,
        effect := .skip,
        gx := false },
      { name := "Mega Impact", cost := [.metal, .metal, .colorless, .colorless], damage := 16,
        effect := .skip,
        gx := false }] }

/-- Bagon (sv9-112). Records: sv9-112. Caveats: recoil. -/
def sv9_112 : Card := .pokemon
  { name := "Bagon", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Reckless Charge", cost := [.fire, .water], damage := 5,
        effect := .selfDamage 1,
        gx := false }] }

/-- Shelgon (sv9-113). Records: sv9-113. Caveats: perPokemon. -/
def sv9_113 : Card := .pokemon
  { name := "Shelgon", stage := .stage1, evolvesFrom := some "Bagon",
    hp := 10, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Guard Press", cost := [.colorless, .colorless], damage := 3,
        effect := .linger .own .next (.reduce 3),
        gx := false },
      { name := "Heavy Impact", cost := [.fire, .water, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Salamence ex (sv9-114). Records: sv9-114, sv9-177, sv9-187. Caveats: benchMods. -/
def sv9_114 : Card := .pokemon
  { name := "Salamence ex", stage := .stage2, evolvesFrom := some "Shelgon",
    hp := 32, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Wide Blast", cost := [.fire, .colorless, .colorless], damage := 0,
        effect := .spreadDamage .opp 5,
        gx := false },
      { name := "Dragon Impact", cost := [.fire, .water, .colorless, .colorless], damage := 30,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- N's Reshiram (sv9-116). Records: sv9-116, sv9-167, me2pt5-154. -/
def sv9_116 : Card := .pokemon
  { name := "N's Reshiram", stage := .basic, evolvesFrom := none,
    hp := 13, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Powerful Rage", cost := [.fire, .lightning], damage := 0,
        effect := .damage (.per .own 2),
        gx := false },
      { name := "Virtuous Flame", cost := [.fire, .fire, .lightning, .colorless], damage := 17,
        effect := .skip,
        gx := false }] }

/-- Sentret (sv9-118). Records: sv9-118. -/
def sv9_118 : Card := .pokemon
  { name := "Sentret", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smack", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Furret (sv9-119). Records: sv9-119, sv9-168. -/
def sv9_119 : Card := .pokemon
  { name := "Furret", stage := .stage1, evolvesFrom := some "Sentret",
    hp := 12, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.colorless], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Jet Headbutt", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Dunsparce (sv9-120). Records: sv9-120. -/
def sv9_120 : Card := .pokemon
  { name := "Dunsparce", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Trading Places", cost := [.colorless], damage := 0,
        effect := .switch .own,
        gx := false },
      { name := "Ram", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Dudunsparce ex (sv9-121). Records: sv9-121, sv9-178. Caveats: ignFxStadium. -/
def sv9_121 : Card := .pokemon
  { name := "Dudunsparce ex", stage := .stage1, evolvesFrom := some "Dunsparce",
    hp := 27, type := .colorless, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Tenacious Tail", cost := [.colorless], damage := 0,
        effect := .damage (.count (.inPlay .opp (.and .pokemon (.not .noRuleBox))) 6),
        gx := false },
      { name := "Destructive Drill", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.const 15) { fx := true },
        gx := false }] }

/-- Tropius (sv9-123). Records: sv9-123. -/
def sv9_123 : Card := .pokemon
  { name := "Tropius", stage := .basic, evolvesFrom := none,
    hp := 11, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fruit Bearing", cost := [.colorless], damage := 0,
        effect := .ifDone (.countGe (.pile .own .hand .any) 1) (.move .own .hand .discard .any (.exactly 1)) (.move .own (.top 3) .hand .any .all),
        gx := false },
      { name := "Gust", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Audino (sv9-124). Records: sv9-124. -/
def sv9_124 : Card := .pokemon
  { name := "Audino", stage := .basic, evolvesFrom := none,
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Beckon", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.pile .own .discard (.kind .supporter)) 1) (.move .own .discard .hand (.kind .supporter) (.exactly 1)) .skip,
        gx := false },
      { name := "Zen Headbutt", cost := [.colorless, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Minccino (sv9-125). Records: sv9-125. -/
def sv9_125 : Card := .pokemon
  { name := "Minccino", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slap", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Cinccino (sv9-126). Records: sv9-126. -/
def sv9_126 : Card := .pokemon
  { name := "Cinccino", stage := .stage1, evolvesFrom := some "Minccino",
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tail Smack", cost := [.colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Noibat (sv9-127). Records: sv9-127, sv9-169. -/
def sv9_127 : Card := .pokemon
  { name := "Noibat", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rapid Draw", cost := [.colorless], damage := 1,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false }] }

/-- Drampa (sv9-130). Records: sv9-130. -/
def sv9_130 : Card := .pokemon
  { name := "Drampa", stage := .basic, evolvesFrom := none,
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Dragon Claw", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Skwovet (sv9-131). Records: sv9-131. -/
def sv9_131 : Card := .pokemon
  { name := "Skwovet", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Gnaw", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Greedent (sv9-132). Records: sv9-132. -/
def sv9_132 : Card := .pokemon
  { name := "Greedent", stage := .stage1, evolvesFrom := some "Skwovet",
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gluttonous Tail", cost := [.colorless, .colorless], damage := 6,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false }] }

/-- Hop's Corvisquire (sv9-134). Records: sv9-134. -/
def sv9_134 : Card := .pokemon
  { name := "Hop's Corvisquire", stage := .stage1, evolvesFrom := some "Hop's Rookidee",
    hp := 9, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Speed Dive", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Razor Wing", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Hop's Wooloo (sv9-135). Records: sv9-135, sv9-170. -/
def sv9_135 : Card := .pokemon
  { name := "Hop's Wooloo", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smash Kick", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Hop's Dubwool (sv9-136). Records: sv9-136. Caveats: noopUse. -/
def sv9_136 : Card := .pokemon
  { name := "Hop's Dubwool", stage := .stage1, evolvesFrom := some "Hop's Wooloo",
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Defiant Horn", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.switch .opp) }],
    attacks := [
      { name := "Headbutt", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Cramorant (sv9-137). Records: sv9-137. -/
def sv9_137 : Card := .pokemon
  { name := "Cramorant", stage := .basic, evolvesFrom := none,
    hp := 11, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ceaseless Spitting", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.many (.const 5)),
        gx := false }] }

/-- Lechonk (sv9-139). Records: sv9-139. -/
def sv9_139 : Card := .pokemon
  { name := "Lechonk", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Oinkologne (sv9-140). Records: sv9-140. Caveats: perPokemon. -/
def sv9_140 : Card := .pokemon
  { name := "Oinkologne", stage := .stage1, evolvesFrom := some "Lechonk",
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aromatic Stomps", cost := [.colorless, .colorless], damage := 5,
        effect := .choice (.linger .opp .next (.lock .attack)) .skip,
        gx := false },
      { name := "Headbutt Bounce", cost := [.colorless, .colorless, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Squawkabilly (sv9-141). Records: sv9-141. -/
def sv9_141 : Card := .pokemon
  { name := "Squawkabilly", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Add On", cost := [.colorless], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Hyper Voice", cost := [.colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Iris's Fighting Spirit (sv9-149). Records: sv9-149, sv9-180, me2pt5-190, me2pt5-292. -/
def sv9_149 : Card := .trainer "Iris's Fighting Spirit" .supporter
    (.seq (.move .own .hand .discard .any (.exactly 1)) (.drawTo .own 6))

/-- Levincia (sv9-150). Records: sv9-150, sv10-244. Caveats: upTo0. -/
def sv9_150 : Card := .trainer "Levincia" .stadium
    (.move .own .discard .hand (.energyOf .lightning) (.upTo 2))

/-- Yanma (sv10-2). Records: sv10-2, sv10-183. -/
def sv10_2 : Card := .pokemon
  { name := "Yanma", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Whirlwind", cost := [.colorless], damage := 0,
        effect := .switch .opp,
        gx := false },
      { name := "Razor Wing", cost := [.grass, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Pineco (sv10-4). Records: sv10-4. -/
def sv10_4 : Card := .pokemon
  { name := "Pineco", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hang Down", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Shroomish (sv10-5). Records: sv10-5. -/
def sv10_5 : Card := .pokemon
  { name := "Shroomish", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rolling Tackle", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Breloom (sv10-6). Records: sv10-6. -/
def sv10_6 : Card := .pokemon
  { name := "Breloom", stage := .stage1, evolvesFrom := some "Shroomish",
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Damage Rush", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 3) (.many (.const 5))),
        gx := false },
      { name := "Mega Drain", cost := [.grass, .colorless, .colorless], damage := 9,
        effect := .heal 3,
        gx := false }] }

/-- Cynthia's Roselia (sv10-7). Records: sv10-7. -/
def sv10_7 : Card := .pokemon
  { name := "Cynthia's Roselia", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spike Sting", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Crustle (sv10-12). Records: sv10-12, sv10-186. Caveats: ignFxStadium, staticPreventBench. -/
def sv10_12 : Card := .pokemon
  { name := "Crustle", stage := .stage1, evolvesFrom := some "Dwebble",
    hp := 15, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Mysterious Rock Inn", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .prevent .ex }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Superb Scissors", cost := [.grass, .colorless, .colorless], damage := 0,
        effect := .damage (.const 12) { fx := true },
        gx := false }] }

/-- Fomantis (sv10-13). Records: sv10-13. -/
def sv10_13 : Card := .pokemon
  { name := "Fomantis", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cut Up", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lurantis (sv10-14). Records: sv10-14. -/
def sv10_14 : Card := .pokemon
  { name := "Lurantis", stage := .stage1, evolvesFrom := some "Fomantis",
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Razor Leaf", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Petal Blade Dance", cost := [.grass], damage := 0,
        effect := .ite (.countGe (.pile .own .hand (.energyOf .grass)) 2) (.seq (.move .own .hand .discard (.energyOf .grass) (.exactly 2)) (.damage (.const 13))) .skip,
        gx := false }] }

/-- Applin (sv10-16). Records: sv10-16. -/
def sv10_16 : Card := .pokemon
  { name := "Applin", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mini Drain", cost := [.grass], damage := 1,
        effect := .heal 1,
        gx := false }] }

/-- Team Rocket's Tarountula (sv10-19). Records: sv10-19, me2pt5-18. Caveats: recoil. -/
def sv10_19 : Card := .pokemon
  { name := "Team Rocket's Tarountula", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Take Down", cost := [.grass], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Smoliv (sv10-21). Records: sv10-21. -/
def sv10_21 : Card := .pokemon
  { name := "Smoliv", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Dolliv (sv10-22). Records: sv10-22. -/
def sv10_22 : Card := .pokemon
  { name := "Dolliv", stage := .stage1, evolvesFrom := some "Smoliv",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Nutrients", cost := [.grass], damage := 0,
        effect := .ite (.countGe (.bench .own .pokemon) 1) (.choice (.heal 4) (.benchHeal 4)) (.heal 4),
        gx := false },
      { name := "Tackle", cost := [.colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Growlithe (sv10-27). Records: sv10-27. -/
def sv10_27 : Card := .pokemon
  { name := "Growlithe", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Live Coal", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Dig Claws", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Arcanine (sv10-28). Records: sv10-28. -/
def sv10_28 : Card := .pokemon
  { name := "Arcanine", stage := .stage1, evolvesFrom := some "Growlithe",
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flare", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Punishing Fang", cost := [.fire, .colorless, .colorless], damage := 0,
        effect := .ite (.isType .opp .darkness) (.damage (.const 20)) (.damage (.const 10)),
        gx := false }] }

/-- Ponyta (sv10-29). Records: sv10-29. -/
def sv10_29 : Card := .pokemon
  { name := "Ponyta", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Headbutt", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- Rapidash (sv10-30). Records: sv10-30, sv10-189. -/
def sv10_30 : Card := .pokemon
  { name := "Rapidash", stage := .stage1, evolvesFrom := some "Ponyta",
    hp := 11, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Hurried Gait", use := .once,
        spot := none, cond := none,
        effect := .fx (.move .own (.top 1) .hand .any .all) }],
    attacks := [
      { name := "Fire Mane", cost := [.fire, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Ethan's Cyndaquil (sv10-32). Records: sv10-32. -/
def sv10_32 : Card := .pokemon
  { name := "Ethan's Cyndaquil", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ember", cost := [.fire], damage := 3,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Ethan's Quilava (sv10-33). Records: sv10-33. -/
def sv10_33 : Card := .pokemon
  { name := "Ethan's Quilava", stage := .stage1, evolvesFrom := some "Ethan's Cyndaquil",
    hp := 10, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Bonded by the Journey", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .deck .hand (.named "Ethan's Adventure") (.upTo 1)) .shuffle) }],
    attacks := [
      { name := "Combustion", cost := [.fire], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Ethan's Typhlosion (sv10-34). Records: sv10-34, sv10-190. -/
def sv10_34 : Card := .pokemon
  { name := "Ethan's Typhlosion", stage := .stage2, evolvesFrom := some "Ethan's Quilava",
    hp := 17, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Buddy Blast", cost := [.fire], damage := 0,
        effect := .damage (.add (.const 4) (.count (.pile .own .discard (.named "Ethan's Adventure")) 6)),
        gx := false },
      { name := "Steam Artillery", cost := [.fire, .fire, .colorless], damage := 16,
        effect := .skip,
        gx := false }] }

/-- Ethan's Slugma (sv10-35). Records: sv10-35, me2pt5-23. -/
def sv10_35 : Card := .pokemon
  { name := "Ethan's Slugma", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Steady Firebreathing", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Houndour (sv10-37). Records: sv10-37. -/
def sv10_37 : Card := .pokemon
  { name := "Team Rocket's Houndour", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Steady Firebreathing", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Houndoom (sv10-38). Records: sv10-38, sv10-191. -/
def sv10_38 : Card := .pokemon
  { name := "Team Rocket's Houndoom", stage := .stage1, evolvesFrom := some "Team Rocket's Houndour",
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cruel Coal", cost := [.fire], damage := 0,
        effect := .seq (.inflict .burned) (.inflict .confused),
        gx := false },
      { name := "Scorching Fire", cost := [.fire, .colorless], damage := 12,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Torchic (sv10-40). Records: sv10-40. -/
def sv10_40 : Card := .pokemon
  { name := "Torchic", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Combustion", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Combusken (sv10-41). Records: sv10-41. -/
def sv10_41 : Card := .pokemon
  { name := "Combusken", stage := .stage1, evolvesFrom := some "Torchic",
    hp := 10, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Combustion", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Double Kick", cost := [.fire, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 4)) (.damage (.const 8))),
        gx := false }] }

/-- Blaziken (sv10-42). Records: sv10-42, sv10-192. Caveats: benchMods. -/
def sv10_42 : Card := .pokemon
  { name := "Blaziken", stage := .stage2, evolvesFrom := some "Combusken",
    hp := 17, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Heat Blast", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false },
      { name := "Inferno Kick Flurry", cost := [.fire, .fire, .colorless], damage := 12,
        effect := .seq (.ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all)) (.benchDamage .opp 12),
        gx := false }] }

/-- Hearthflame Mask Ogerpon (sv10-44). Records: sv10-44. -/
def sv10_44 : Card := .pokemon
  { name := "Hearthflame Mask Ogerpon", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fire Kagura", cost := [.colorless], damage := 0,
        effect := .seq (.choice (.attach .own .deck (.energyOf .fire) .active .any) (.attach .own .deck (.energyOf .fire) .bench .any)) .shuffle,
        gx := false },
      { name := "Searing Flame", cost := [.fire, .fire, .colorless], damage := 8,
        effect := .inflict .burned,
        gx := false }] }

/-- Misty's Staryu (sv10-46). Records: sv10-46. -/
def sv10_46 : Card := .pokemon
  { name := "Misty's Staryu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bubble Beam", cost := [.water], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Misty's Starmie (sv10-47). Records: sv10-47. -/
def sv10_47 : Card := .pokemon
  { name := "Misty's Starmie", stage := .stage1, evolvesFrom := some "Misty's Staryu",
    hp := 10, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Abrupt Flash", cost := [.water], damage := 0,
        effect := .ite (.evolved .own) (.damage (.const 14)) (.damage (.const 6)),
        gx := false }] }

/-- Cynthia's Milotic (sv10-53). Records: sv10-53. Caveats: benchMods. -/
def sv10_53 : Card := .pokemon
  { name := "Cynthia's Milotic", stage := .stage1, evolvesFrom := some "Cynthia's Feebas",
    hp := 13, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aqua Split", cost := [.water, .colorless], damage := 6,
        effect := .benchSome .opp 2 .any true 3,
        gx := false }] }

/-- Clamperl (sv10-54). Records: sv10-54, sv10-195. Caveats: perPokemon. -/
def sv10_54 : Card := .pokemon
  { name := "Clamperl", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shell Press", cost := [.water], damage := 1,
        effect := .linger .own .next (.reduce 1),
        gx := false }] }

/-- Buizel (sv10-57). Records: sv10-57. -/
def sv10_57 : Card := .pokemon
  { name := "Buizel", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tail Whap", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Wave Splash", cost := [.water, .colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Floatzel (sv10-58). Records: sv10-58. Caveats: perPokemon. -/
def sv10_58 : Card := .pokemon
  { name := "Floatzel", stage := .stage1, evolvesFrom := some "Buizel",
    hp := 12, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Whirlpool", cost := [.colorless, .colorless], damage := 3,
        effect := .ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip,
        gx := false },
      { name := "Aqua Slash", cost := [.water, .colorless, .colorless], damage := 14,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Snover (sv10-59). Records: sv10-59. -/
def sv10_59 : Card := .pokemon
  { name := "Snover", stage := .basic, evolvesFrom := none,
    hp := 9, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Light Punch", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Icicle", cost := [.water, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Abomasnow (sv10-60). Records: sv10-60. -/
def sv10_60 : Card := .pokemon
  { name := "Abomasnow", stage := .stage1, evolvesFrom := some "Snover",
    hp := 15, type := .water, retreat := 4, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Lunge Out", cost := [.colorless, .colorless, .colorless], damage := 9,
        effect := .skip,
        gx := false },
      { name := "Frozen Wood", cost := [.water, .water, .water, .colorless], damage := 0,
        effect := .ite (.countGe (.energy .own (.energyOf .grass)) 2) (.damage (.const 24)) (.damage (.const 12)),
        gx := false }] }

/-- Arrokuda (sv10-62). Records: sv10-62. Caveats: recoil. -/
def sv10_62 : Card := .pokemon
  { name := "Arrokuda", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Charge", cost := [.water], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  sv8pt5_83,
  sv8pt5_84,
  sv8pt5_86,
  sv8pt5_88,
  sv8pt5_89,
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
  sv9_18,
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
  sv9_40,
  sv9_41,
  sv9_42,
  sv9_44,
  sv9_45,
  sv9_46,
  sv9_51,
  sv9_52,
  sv9_54,
  sv9_57,
  sv9_59,
  sv9_61,
  sv9_62,
  sv9_65,
  sv9_66,
  sv9_69,
  sv9_70,
  sv9_71,
  sv9_72,
  sv9_74,
  sv9_75,
  sv9_76,
  sv9_77,
  sv9_78,
  sv9_80,
  sv9_81,
  sv9_82,
  sv9_83,
  sv9_86,
  sv9_87,
  sv9_88,
  sv9_89,
  sv9_90,
  sv9_91,
  sv9_93,
  sv9_94,
  sv9_97,
  sv9_100,
  sv9_101,
  sv9_102,
  sv9_103,
  sv9_104,
  sv9_105,
  sv9_106,
  sv9_108,
  sv9_109,
  sv9_110,
  sv9_112,
  sv9_113,
  sv9_114,
  sv9_116,
  sv9_118,
  sv9_119,
  sv9_120,
  sv9_121,
  sv9_123,
  sv9_124,
  sv9_125,
  sv9_126,
  sv9_127,
  sv9_130,
  sv9_131,
  sv9_132,
  sv9_134,
  sv9_135,
  sv9_136,
  sv9_137,
  sv9_139,
  sv9_140,
  sv9_141,
  sv9_149,
  sv9_150,
  sv10_2,
  sv10_4,
  sv10_5,
  sv10_6,
  sv10_7,
  sv10_12,
  sv10_13,
  sv10_14,
  sv10_16,
  sv10_19,
  sv10_21,
  sv10_22,
  sv10_27,
  sv10_28,
  sv10_29,
  sv10_30,
  sv10_32,
  sv10_33,
  sv10_34,
  sv10_35,
  sv10_37,
  sv10_38,
  sv10_40,
  sv10_41,
  sv10_42,
  sv10_44,
  sv10_46,
  sv10_47,
  sv10_53,
  sv10_54,
  sv10_57,
  sv10_58,
  sv10_59,
  sv10_60,
  sv10_62]

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
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Lilligant"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Furfrou", "Regirock"] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = ["Toedscruel"] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 10 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 10)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = [] := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.koByAttack` (milestone M8b), by name. -/
theorem cards_trigKO : (cards.filter (Card.hasTrig .koByAttack)).map Card.label = ["Maractus"] := by decide +kernel

/-- The cards of this part whose triggered Abilities write a lingering modifier (milestone M8b), by name. -/
theorem cards_trigLingers : (cards.filter Card.trigLingers).map Card.label = [] := by decide +kernel

/-- The cards of this part whose triggered Abilities can return a card from a discard pile (milestone M8b), by name. -/
theorem cards_trigRecycles : (cards.filter Card.trigRecycles).map Card.label = [] := by decide +kernel

/-- Every triggered Ability of this part has no printed condition and an effect of the trigger
fragment (`Card.trigsOk`). -/
theorem cards_trigsOk : cards.all Card.trigsOk = true := by decide +kernel

/-- The cards of this part that are not `Card.tame` (a `drain` attack or a stored damage reduction), by
name. -/
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Paras", "Hop's Corviknight", "Shelgon", "Clamperl"] := by decide +kernel

end PokemonCards.Standard.Part04
