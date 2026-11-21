/-
Imported Standard cards, part 6 of 7 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.1.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part06
open Pokemon

/-- Erika's Bellsprout (me2pt5-4). Records: me2pt5-4. -/
def me2pt5_4 : Card := .pokemon
  { name := "Erika's Bellsprout", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Vine Slap", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Erika's Weepinbell (me2pt5-5). Records: me2pt5-5. Caveats: perPokemon. -/
def me2pt5_5 : Card := .pokemon
  { name := "Erika's Weepinbell", stage := .stage1, evolvesFrom := some "Erika's Bellsprout",
    hp := 9, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Leaf Step", cost := [.grass, .grass], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Mega Meganium ex (me2pt5-10). Records: me2pt5-10, me2pt5-272. -/
def me2pt5_10 : Card := .pokemon
  { name := "Mega Meganium ex", stage := .stage2, evolvesFrom := some "Bayleef",
    hp := 36, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .megaEx, tera := false,
    attacks := [
      { name := "Giant Bouquet", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 7) (.count (.energy .own (.energyOf .grass)) 5)),
        gx := false }] }

/-- Wurmple (me2pt5-11). Records: me2pt5-11. -/
def me2pt5_11 : Card := .pokemon
  { name := "Wurmple", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Bug Bite", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Cascoon (me2pt5-14). Records: me2pt5-14. -/
def me2pt5_14 : Card := .pokemon
  { name := "Cascoon", stage := .stage1, evolvesFrom := some "Wurmple",
    hp := 9, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Trading Places", cost := [.grass], damage := 0,
        effect := .switch .own,
        gx := false }] }

/-- Budew (me2pt5-16). Records: me2pt5-16, me2pt5-221. -/
def me2pt5_16 : Card := .pokemon
  { name := "Budew", stage := .basic, evolvesFrom := none,
    hp := 3, type := .grass, retreat := 0, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Itchy Pollen", cost := [], damage := 1,
        effect := .linger .opp .next (.lock .item),
        gx := false }] }

/-- Charmander (me2pt5-20). Records: me2pt5-20. -/
def me2pt5_20 : Card := .pokemon
  { name := "Charmander", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Fire Claws", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Charmeleon (me2pt5-21). Records: me2pt5-21. -/
def me2pt5_21 : Card := .pokemon
  { name := "Charmeleon", stage := .stage1, evolvesFrom := some "Charmander",
    hp := 10, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Heat Blast", cost := [.fire, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Entei (me2pt5-25). Records: me2pt5-25. -/
def me2pt5_25 : Card := .pokemon
  { name := "Entei", stage := .basic, evolvesFrom := none,
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Flare Fall", cost := [.fire, .fire], damage := 0,
        effect := .ite (.countGe (.energyAll .own (.energyOf .fire)) 4) (.damage (.const 12)) (.damage (.const 3)),
        gx := false }] }

/-- Camerupt (me2pt5-28). Records: me2pt5-28. -/
def me2pt5_28 : Card := .pokemon
  { name := "Camerupt", stage := .stage1, evolvesFrom := some "Numel",
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Steady Firebreathing", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Pignite (me2pt5-30). Records: me2pt5-30. -/
def me2pt5_30 : Card := .pokemon
  { name := "Pignite", stage := .stage1, evolvesFrom := some "Tepig",
    hp := 11, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Super Singe", cost := [.fire, .fire, .colorless], damage := 7,
        effect := .inflict .burned,
        gx := false }] }

/-- Mega Emboar ex (me2pt5-31). Records: me2pt5-31, me2pt5-273. Caveats: recoil. -/
def me2pt5_31 : Card := .pokemon
  { name := "Mega Emboar ex", stage := .stage2, evolvesFrom := some "Pignite",
    hp := 38, type := .fire, retreat := 4, weakness := some .water,
    resistance := none, ruleBox := .megaEx, tera := false,
    attacks := [
      { name := "Crimson Blast", cost := [.fire, .fire, .colorless], damage := 32,
        effect := .selfDamage 6,
        gx := false }] }

/-- Totodile (me2pt5-41). Records: me2pt5-41. Caveats: recoil. -/
def me2pt5_41 : Card := .pokemon
  { name := "Totodile", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Slight Intrusion", cost := [.water, .water], damage := 4,
        effect := .selfDamage 1,
        gx := false }] }

/-- Croconaw (me2pt5-42). Records: me2pt5-42. -/
def me2pt5_42 : Card := .pokemon
  { name := "Croconaw", stage := .stage1, evolvesFrom := some "Totodile",
    hp := 10, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Crunch", cost := [.water, .water], damage := 5,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Mega Feraligatr ex (me2pt5-43). Records: me2pt5-43, me2pt5-274. -/
def me2pt5_43 : Card := .pokemon
  { name := "Mega Feraligatr ex", stage := .stage2, evolvesFrom := some "Croconaw",
    hp := 37, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .megaEx, tera := false,
    attacks := [
      { name := "Mortal Crunch", cost := [.water, .water, .colorless], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 40)) (.damage (.const 20)),
        gx := false }] }

/-- Snorunt (me2pt5-46). Records: me2pt5-46, me2pt5-227. -/
def me2pt5_46 : Card := .pokemon
  { name := "Snorunt", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Chilly", cost := [.water], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Mega Froslass ex (me2pt5-47). Records: me2pt5-47, me2pt5-265, me2pt5-275. -/
def me2pt5_47 : Card := .pokemon
  { name := "Mega Froslass ex", stage := .stage1, evolvesFrom := some "Snorunt",
    hp := 31, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .megaEx, tera := false,
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
    attacks := [
      { name := "Icicle", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Pikachu (me2pt5-55). Records: me2pt5-55. -/
def me2pt5_55 : Card := .pokemon
  { name := "Pikachu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Hundred-Hitting Ball", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 10) (.many (.const 10))),
        gx := false }] }

/-- Helioptile (me2pt5-63). Records: me2pt5-63. -/
def me2pt5_63 : Card := .pokemon
  { name := "Helioptile", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Zap Kick", cost := [.lightning, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Exeggcute (me2pt5-77). Records: me2pt5-77. -/
def me2pt5_77 : Card := .pokemon
  { name := "Team Rocket's Exeggcute", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Focused Wish", cost := [.psychic], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Swirlix (me2pt5-93). Records: me2pt5-93. -/
def me2pt5_93 : Card := .pokemon
  { name := "Swirlix", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Ram", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Slurpuff (me2pt5-94). Records: me2pt5-94, me2pt5-236. -/
def me2pt5_94 : Card := .pokemon
  { name := "Slurpuff", stage := .stage1, evolvesFrom := some "Swirlix",
    hp := 12, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Reckless Charge", cost := [.colorless], damage := 2,
        effect := .selfDamage 1,
        gx := false }] }

/-- Rolycoly (me2pt5-118). Records: me2pt5-118. -/
def me2pt5_118 : Card := .pokemon
  { name := "Rolycoly", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Mud-Slap", cost := [.fighting], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Carkol (me2pt5-119). Records: me2pt5-119. Caveats: perPokemon. -/
def me2pt5_119 : Card := .pokemon
  { name := "Carkol", stage := .stage1, evolvesFrom := some "Rolycoly",
    hp := 11, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Gnaw", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Galarian Linoone (me2pt5-131). Records: me2pt5-131. -/
def me2pt5_131 : Card := .pokemon
  { name := "Galarian Linoone", stage := .stage1, evolvesFrom := some "Galarian Zigzagoon",
    hp := 9, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Knock Off", cost := [.darkness, .colorless], damage := 2,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Vullaby (me2pt5-138). Records: me2pt5-138. -/
def me2pt5_138 : Card := .pokemon
  { name := "Vullaby", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Flap", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Mandibuzz ex (me2pt5-139). Records: me2pt5-139. Caveats: benchMods. -/
def me2pt5_139 : Card := .pokemon
  { name := "Mandibuzz ex", stage := .stage1, evolvesFrom := some "Vullaby",
    hp := 26, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    attacks := [
      { name := "Bone Shot", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 5)) (.benchDamage .opp 5),
        gx := false },
      { name := "Vulture Claw", cost := [.darkness, .colorless, .colorless], damage := 16,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Hoopa (me2pt5-141). Records: me2pt5-141. Caveats: perPokemon. -/
def me2pt5_141 : Card := .pokemon
  { name := "Hoopa", stage := .basic, evolvesFrom := none,
    hp := 12, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Push Down", cost := [.metal], damage := 1,
        effect := .switch .opp,
        gx := false }] }

/-- Bisharp (me2pt5-147). Records: me2pt5-147. -/
def me2pt5_147 : Card := .pokemon
  { name := "Bisharp", stage := .stage1, evolvesFrom := some "Pawniard",
    hp := 12, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Rapid Draw", cost := [.metal], damage := 5,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false }] }

/-- Dratini (me2pt5-150). Records: me2pt5-150. -/
def me2pt5_150 : Card := .pokemon
  { name := "Dratini", stage := .basic, evolvesFrom := none,
    hp := 8, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Headbutt", cost := [.water, .lightning], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Larry's Dunsparce (me2pt5-163). Records: me2pt5-163. -/
def me2pt5_163 : Card := .pokemon
  { name := "Larry's Dunsparce", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rising Lunge", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Skitty (me2pt5-165). Records: me2pt5-165. -/
def me2pt5_165 : Card := .pokemon
  { name := "Skitty", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Cat Kick", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Delcatty (me2pt5-166). Records: me2pt5-166. -/
def me2pt5_166 : Card := .pokemon
  { name := "Delcatty", stage := .stage1, evolvesFrom := some "Skitty",
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Kaleidowaltz", cost := [.colorless], damage := 0,
        effect := .seq (.choice .skip (.choice (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) (.choice (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)))) (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) (.seq (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any))) (.seq (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)) (.choice (.attach .own .deck .energy .active .any) (.attach .own .deck .energy .bench .any)))))))) .shuffle,
        gx := false },
      { name := "Ear Force", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.count (.energy .opp .energy) 8)),
        gx := false }] }

/-- Larry's Rufflet (me2pt5-173). Records: me2pt5-173. -/
def me2pt5_173 : Card := .pokemon
  { name := "Larry's Rufflet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Peck the Wound", cost := [.colorless, .colorless], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 10)) (.damage (.const 2)),
        gx := false }] }

/-- Larry's Braviary (me2pt5-174). Records: me2pt5-174. Caveats: perPokemon, recoil. -/
def me2pt5_174 : Card := .pokemon
  { name := "Larry's Braviary", stage := .stage1, evolvesFrom := some "Larry's Rufflet",
    hp := 13, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
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

/-- Ultra Ball (me2pt5-213). Records: me2pt5-213, me2pt5-264. -/
def me2pt5_213 : Card := .trainer "Ultra Ball" .item
    (.seq (.move .own .hand .discard .any (.exactly 2)) (.seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle))

/-- Urbain (me2pt5-214). Records: me2pt5-214. -/
def me2pt5_214 : Card := .trainer "Urbain" .supporter
    (.move .own (.top 3) .hand .any .all)

/-- Spinarak (me3-1). Records: me3-1. Caveats: perPokemon. -/
def me3_1 : Card := .pokemon
  { name := "Spinarak", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Gooey Thread", cost := [.grass], damage := 1,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Ariados (me3-2). Records: me3-2. Caveats: perPokemon. -/
def me3_2 : Card := .pokemon
  { name := "Ariados", stage := .stage1, evolvesFrom := some "Spinarak",
    hp := 11, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Poison Ring", cost := [.grass], damage := 5,
        effect := .seq (.inflict .poisoned) (.linger .opp .next (.lock .retreat)),
        gx := false }] }

/-- Snivy (me3-4). Records: me3-4. Caveats: recoil. -/
def me3_4 : Card := .pokemon
  { name := "Snivy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Reckless Charge", cost := [.grass], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Servine (me3-5). Records: me3-5. -/
def me3_5 : Card := .pokemon
  { name := "Servine", stage := .stage1, evolvesFrom := some "Snivy",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Solar Cutter", cost := [.grass], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Scatterbug (me3-7). Records: me3-7. -/
def me3_7 : Card := .pokemon
  { name := "Scatterbug", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Gnaw", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Rowlet (me3-10). Records: me3-10, me3-90. -/
def me3_10 : Card := .pokemon
  { name := "Rowlet", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Find a Friend", cost := [.grass], damage := 0,
        effect := .seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle,
        gx := false },
      { name := "Tackle", cost := [.colorless, .colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Fletchinder (me3-13). Records: me3-13. -/
def me3_13 : Card := .pokemon
  { name := "Fletchinder", stage := .stage1, evolvesFrom := some "Fletchling",
    hp := 9, type := .fire, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Flare", cost := [.fire, .fire], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Salandit (me3-15). Records: me3-15. -/
def me3_15 : Card := .pokemon
  { name := "Salandit", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Fire Claws", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Salazzle ex (me3-16). Records: me3-16, me3-101. Caveats: searchAny. -/
def me3_16 : Card := .pokemon
  { name := "Salazzle ex", stage := .stage1, evolvesFrom := some "Salandit",
    hp := 26, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
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
    attacks := [
      { name := "Rain Splash", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Wave Splash", cost := [.water, .water], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Staryu (me3-20). Records: me3-20. -/
def me3_20 : Card := .pokemon
  { name := "Staryu", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Water Gun", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lapras ex (me3-22). Records: me3-22. -/
def me3_22 : Card := .pokemon
  { name := "Lapras ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := false,
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
    attacks := [
      { name := "Icy Wind", cost := [.water, .colorless], damage := 5,
        effect := .inflict .asleep,
        gx := false }] }

/-- Shinx (me3-26). Records: me3-26. -/
def me3_26 : Card := .pokemon
  { name := "Shinx", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Double Scratch", cost := [.lightning], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- Clefairy (me3-30). Records: me3-30, me3-94. -/
def me3_30 : Card := .pokemon
  { name := "Clefairy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Sweet Scent", cost := [.colorless], damage := 0,
        effect := .choice (.heal 3) (.benchHeal 3),
        gx := false },
      { name := "Ram", cost := [.psychic], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Nosepass (me3-37). Records: me3-37. -/
def me3_37 : Card := .pokemon
  { name := "Nosepass", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rolling Rocks", cost := [.fighting, .fighting], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Probopass (me3-38). Records: me3-38, me3-96. -/
def me3_38 : Card := .pokemon
  { name := "Probopass", stage := .stage1, evolvesFrom := some "Nosepass",
    hp := 14, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rolling Rocks", cost := [.fighting, .fighting], damage := 6,
        effect := .skip,
        gx := false },
      { name := "Obliterating Nose", cost := [.fighting, .fighting, .fighting, .colorless], damage := 26,
        effect := .ite (.countGe (.energy .own .energy) 3) (.discardEnergy .own .active .energy (.exactly 3)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Binacle (me3-42). Records: me3-42. -/
def me3_42 : Card := .pokemon
  { name := "Binacle", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Double Draw", cost := [.fighting], damage := 0,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false },
      { name := "Scratch", cost := [.fighting, .fighting], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Tyrunt (me3-44). Records: me3-44. -/
def me3_44 : Card := .pokemon
  { name := "Tyrunt", stage := .stage1, evolvesFrom := some "Antique Jaw Fossil",
    hp := 10, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Get Angry", cost := [.fighting, .colorless], damage := 0,
        effect := .damage (.per .own 2),
        gx := false }] }

/-- Gastly (me3-48). Records: me3-48. -/
def me3_48 : Card := .pokemon
  { name := "Gastly", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Surprise Attack", cost := [.darkness], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Skorupi (me3-51). Records: me3-51. -/
def me3_51 : Card := .pokemon
  { name := "Skorupi", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Poison Jab", cost := [.darkness, .darkness], damage := 2,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Drapion (me3-52). Records: me3-52, me3-97. Caveats: recoil. -/
def me3_52 : Card := .pokemon
  { name := "Drapion", stage := .stage1, evolvesFrom := some "Skorupi",
    hp := 14, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Wrack Down", cost := [.darkness, .darkness], damage := 6,
        effect := .skip,
        gx := false },
      { name := "Hazardous Tail", cost := [.darkness, .darkness, .darkness], damage := 10,
        effect := .seq (.selfDamage 7) (.seq (.inflict .paralyzed) (.inflict .poisoned)),
        gx := false }] }

/-- Honedge (me3-56). Records: me3-56. -/
def me3_56 : Card := .pokemon
  { name := "Honedge", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Cut", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Aegislash (me3-58). Records: me3-58. Caveats: perPokemon. -/
def me3_58 : Card := .pokemon
  { name := "Aegislash", stage := .stage2, evolvesFrom := some "Doublade",
    hp := 15, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Slash", cost := [.colorless, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false },
      { name := "Metal Slash", cost := [.metal, .colorless, .colorless, .colorless], damage := 23,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Rattata (me3-60). Records: me3-60. Caveats: recoil. -/
def me3_60 : Card := .pokemon
  { name := "Rattata", stage := .basic, evolvesFrom := none,
    hp := 4, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Take Down", cost := [.colorless], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Bunnelby (me3-64). Records: me3-64. -/
def me3_64 : Card := .pokemon
  { name := "Bunnelby", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Smash Kick", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Diggersby (me3-65). Records: me3-65. Caveats: benchMods. -/
def me3_65 : Card := .pokemon
  { name := "Diggersby", stage := .stage1, evolvesFrom := some "Bunnelby",
    hp := 15, type := .colorless, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Earthquake", cost := [.colorless], damage := 14,
        effect := .spreadDamage .own 3,
        gx := false },
      { name := "Whap Down", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Energy Search (me3-72). Records: me3-72. -/
def me3_72 : Card := .trainer "Energy Search" .item
    (.seq (.move .own .deck .hand .energy (.upTo 1)) .shuffle)

/-- Hole-Digging Shovel (me3-74). Records: me3-74. -/
def me3_74 : Card := .trainer "Hole-Digging Shovel" .item
    (.move .own (.top 2) .discard .any .all)

/-- Poké Ball (me3-80). Records: me3-80. -/
def me3_80 : Card := .trainer "Poké Ball" .item
    (.seq (.choice (.move .own .deck .hand .pokemon (.upTo 1)) .skip) .shuffle)

/-- Pokémon Catcher (me3-82). Records: me3-82. -/
def me3_82 : Card := .trainer "Pokémon Catcher" .item
    (.choice (.switch .opp) .skip)

/-- Potion (me3-83). Records: me3-83. -/
def me3_83 : Card := .trainer "Potion" .item
    (.choice (.heal 3) (.benchHeal 3))

/-- Tarragon (me3-85). Records: me3-85, me3-116. Caveats: upTo0. -/
def me3_85 : Card := .trainer "Tarragon" .supporter
    (.move .own .discard .hand (.or (.ptype .fighting) (.energyOf .fighting)) (.upTo 4))

/-- Weedle (me4-1). Records: me4-1. -/
def me4_1 : Card := .pokemon
  { name := "Weedle", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Surprise Attack", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Chespin (me4-5). Records: me4-5, me4-87. -/
def me4_5 : Card := .pokemon
  { name := "Chespin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Singe", cost := [.fire], damage := 0,
        effect := .inflict .burned,
        gx := false }] }

/-- Ho-Oh (me4-10). Records: me4-10. -/
def me4_10 : Card := .pokemon
  { name := "Ho-Oh", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Flamethrower", cost := [.fire, .fire], damage := 8,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Litleo (me4-14). Records: me4-14. -/
def me4_14 : Card := .pokemon
  { name := "Litleo", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Tackle", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Remoraid (me4-16). Records: me4-16. -/
def me4_16 : Card := .pokemon
  { name := "Remoraid", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Sharp Fin", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Froakie (me4-20). Records: me4-20, me4-88. -/
def me4_20 : Card := .pokemon
  { name := "Froakie", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Thunder Wave", cost := [.lightning, .colorless], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Flaaffy (me4-28). Records: me4-28. -/
def me4_28 : Card := .pokemon
  { name := "Flaaffy", stage := .stage1, evolvesFrom := some "Mareep",
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Disconnect", cost := [.lightning, .colorless], damage := 4,
        effect := .linger .opp .next (.lock .item),
        gx := false }] }

/-- Deoxys (me4-31). Records: me4-31. -/
def me4_31 : Card := .pokemon
  { name := "Deoxys", stage := .basic, evolvesFrom := none,
    hp := 11, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Psyspear", cost := [.psychic, .psychic, .psychic], damage := 12,
        effect := .ite (.countGe (.energy .own .energy) 5) (.benchDamage .opp 12) .skip,
        gx := false }] }

/-- Pumpkaboo (me4-40). Records: me4-40. -/
def me4_40 : Card := .pokemon
  { name := "Pumpkaboo", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Stampede", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Xerneas (me4-42). Records: me4-42, me4-91. -/
def me4_42 : Card := .pokemon
  { name := "Xerneas", stage := .basic, evolvesFrom := none,
    hp := 13, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Geo Storm", cost := [.psychic, .psychic, .psychic], damage := 0,
        effect := .damage (.count (.energyAll .own (.energyOf .psychic)) 3),
        gx := false }] }

/-- Phanpy (me4-44). Records: me4-44. -/
def me4_44 : Card := .pokemon
  { name := "Phanpy", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Continuous Spin", cost := [.fighting], damage := 0,
        effect := .damage (.many (.const 3)),
        gx := false }] }

/-- Mega Gallade ex (me4-48). Records: me4-48. -/
def me4_48 : Card := .pokemon
  { name := "Mega Gallade ex", stage := .stage2, evolvesFrom := some "Kirlia",
    hp := 35, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .megaEx, tera := false,
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
    attacks := [
      { name := "Supersonic", cost := [.darkness], damage := 0,
        effect := .inflict .confused,
        gx := false }] }

/-- Stunky (me4-53). Records: me4-53. -/
def me4_53 : Card := .pokemon
  { name := "Stunky", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Scratch", cost := [.darkness], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Skuntank (me4-54). Records: me4-54. -/
def me4_54 : Card := .pokemon
  { name := "Skuntank", stage := .stage1, evolvesFrom := some "Stunky",
    hp := 11, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rear Kick", cost := [.darkness], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Smash Turn", cost := [.darkness, .darkness, .colorless], damage := 10,
        effect := .switch .own,
        gx := false }] }

/-- Trubbish (me4-56). Records: me4-56. -/
def me4_56 : Card := .pokemon
  { name := "Trubbish", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Acid Spray", cost := [.darkness], damage := 1,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Skrelp (me4-58). Records: me4-58. -/
def me4_58 : Card := .pokemon
  { name := "Skrelp", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Hook", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Beldum (me4-59). Records: me4-59. -/
def me4_59 : Card := .pokemon
  { name := "Beldum", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Rolling Tackle", cost := [.metal, .metal], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Goomy (me4-66). Records: me4-66. -/
def me4_66 : Card := .pokemon
  { name := "Goomy", stage := .basic, evolvesFrom := none,
    hp := 6, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Absorb", cost := [.water, .psychic], damage := 3,
        effect := .heal 3,
        gx := false }] }

/-- Sliggoo (me4-67). Records: me4-67, me4-95. -/
def me4_67 : Card := .pokemon
  { name := "Sliggoo", stage := .stage1, evolvesFrom := some "Goomy",
    hp := 9, type := .dragon, retreat := 3, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Gentle Slap", cost := [.water, .psychic], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Minccino (me4-72). Records: me4-72. Caveats: recoil. -/
def me4_72 : Card := .pokemon
  { name := "Minccino", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Take Down", cost := [.colorless], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Energy Retrieval (me4-108). Records: me4-108. Caveats: upTo0. -/
def me4_108 : Card := .trainer "Energy Retrieval" .item
    (.move .own .discard .hand .energy (.upTo 2))

/-- Grubbin (me5-2). Records: me5-2. -/
def me5_2 : Card := .pokemon
  { name := "Grubbin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "String Shot", cost := [.colorless], damage := 1,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Fomantis (me5-3). Records: me5-3, me5-85. Caveats: recoil. -/
def me5_3 : Card := .pokemon
  { name := "Fomantis", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Reckless Charge", cost := [.grass], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Centiskorch (me5-10). Records: me5-10. Caveats: recoil. -/
def me5_10 : Card := .pokemon
  { name := "Centiskorch", stage := .stage1, evolvesFrom := some "Sizzlipede",
    hp := 14, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Best Punch", cost := [.fire], damage := 0,
        effect := .choice (.damage (.const 4)) .skip,
        gx := false }] }

/-- Goldeen (me5-13). Records: me5-13, me5-87. -/
def me5_13 : Card := .pokemon
  { name := "Goldeen", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Pierce", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Wailmer (me5-15). Records: me5-15. -/
def me5_15 : Card := .pokemon
  { name := "Wailmer", stage := .basic, evolvesFrom := none,
    hp := 13, type := .water, retreat := 4, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Pound", cost := [.water], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Brionne (me5-19). Records: me5-19. -/
def me5_19 : Card := .pokemon
  { name := "Brionne", stage := .stage1, evolvesFrom := some "Popplio",
    hp := 9, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Hyper Voice", cost := [.water], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Finizen (me5-21). Records: me5-21. -/
def me5_21 : Card := .pokemon
  { name := "Finizen", stage := .basic, evolvesFrom := none,
    hp := 8, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Draining Fin", cost := [.water, .water], damage := 2,
        effect := .heal 2,
        gx := false }] }

/-- Electrike (me5-23). Records: me5-23. -/
def me5_23 : Card := .pokemon
  { name := "Electrike", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Vise Grip", cost := [.lightning], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Ram", cost := [.lightning, .lightning], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Mega Zeraora ex (me5-27). Records: me5-27, me5-98, me5-114. -/
def me5_27 : Card := .pokemon
  { name := "Mega Zeraora ex", stage := .basic, evolvesFrom := none,
    hp := 27, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .megaEx, tera := false,
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
    attacks := [
      { name := "Will-O-Wisp", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lampent (me5-37). Records: me5-37. -/
def me5_37 : Card := .pokemon
  { name := "Lampent", stage := .stage1, evolvesFrom := some "Litwick",
    hp := 9, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Spreading Light", cost := [.psychic], damage := 0,
        effect := .seq (.seq (.putBench .own .deck (.named "Lampent")) (.seq (.putBench .own .deck (.named "Lampent")) (.putBench .own .deck (.named "Lampent")))) .shuffle,
        gx := false }] }

/-- Primeape (me5-43). Records: me5-43. -/
def me5_43 : Card := .pokemon
  { name := "Primeape", stage := .stage1, evolvesFrom := some "Mankey",
    hp := 11, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Corkscrew Punch", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Cranidos (me5-44). Records: me5-44. -/
def me5_44 : Card := .pokemon
  { name := "Cranidos", stage := .stage1, evolvesFrom := some "Antique Skull Fossil",
    hp := 10, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Push Down", cost := [.fighting, .fighting], damage := 7,
        effect := .switch .opp,
        gx := false }] }

/-- Drilbur (me5-46). Records: me5-46. -/
def me5_46 : Card := .pokemon
  { name := "Drilbur", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Dig Claws", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Vullaby (me5-49). Records: me5-49. -/
def me5_49 : Card := .pokemon
  { name := "Vullaby", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Flap", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Gust", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  me2pt5_4,
  me2pt5_5,
  me2pt5_9,
  me2pt5_10,
  me2pt5_11,
  me2pt5_14,
  me2pt5_16,
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
  me2pt5_213,
  me2pt5_214,
  me3_1,
  me3_2,
  me3_4,
  me3_5,
  me3_7,
  me3_10,
  me3_13,
  me3_15,
  me3_16,
  me3_18,
  me3_20,
  me3_22,
  me3_23,
  me3_26,
  me3_30,
  me3_33,
  me3_34,
  me3_35,
  me3_37,
  me3_38,
  me3_42,
  me3_44,
  me3_48,
  me3_51,
  me3_52,
  me3_56,
  me3_58,
  me3_60,
  me3_64,
  me3_65,
  me3_72,
  me3_74,
  me3_80,
  me3_82,
  me3_83,
  me3_85,
  me4_1,
  me4_5,
  me4_6,
  me4_8,
  me4_10,
  me4_11,
  me4_12,
  me4_14,
  me4_16,
  me4_20,
  me4_21,
  me4_23,
  me4_25,
  me4_27,
  me4_28,
  me4_31,
  me4_32,
  me4_40,
  me4_42,
  me4_44,
  me4_45,
  me4_46,
  me4_48,
  me4_49,
  me4_53,
  me4_54,
  me4_56,
  me4_58,
  me4_59,
  me4_60,
  me4_62,
  me4_66,
  me4_67,
  me4_72,
  me4_108,
  me5_2,
  me5_3,
  me5_10,
  me5_11,
  me5_13,
  me5_15,
  me5_18,
  me5_19,
  me5_21,
  me5_23,
  me5_25,
  me5_27,
  me5_30,
  me5_36,
  me5_37,
  me5_43,
  me5_44,
  me5_46,
  me5_49]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

end PokemonCards.Standard.Part06
