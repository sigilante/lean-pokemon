/-
Imported Standard cards, part 4 of 7 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.2.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part04
open Pokemon

/-- Sentret (sv9-118). Records: sv9-118. -/
def sv9_118 : Card := .pokemon
  { name := "Sentret", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Smack", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Furret (sv9-119). Records: sv9-119, sv9-168. -/
def sv9_119 : Card := .pokemon
  { name := "Furret", stage := .stage1, evolvesFrom := some "Sentret",
    hp := 12, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Trading Places", cost := [.colorless], damage := 0,
        effect := .switch .own,
        gx := false },
      { name := "Ram", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Audino (sv9-124). Records: sv9-124. -/
def sv9_124 : Card := .pokemon
  { name := "Audino", stage := .basic, evolvesFrom := none,
    hp := 11, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Slap", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Cinccino (sv9-126). Records: sv9-126. -/
def sv9_126 : Card := .pokemon
  { name := "Cinccino", stage := .stage1, evolvesFrom := some "Minccino",
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Tail Smack", cost := [.colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Noibat (sv9-127). Records: sv9-127, sv9-169. -/
def sv9_127 : Card := .pokemon
  { name := "Noibat", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Rapid Draw", cost := [.colorless], damage := 1,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false }] }

/-- Drampa (sv9-130). Records: sv9-130. -/
def sv9_130 : Card := .pokemon
  { name := "Drampa", stage := .basic, evolvesFrom := none,
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Gluttonous Tail", cost := [.colorless, .colorless], damage := 6,
        effect := .move .own (.top 2) .hand .any .all,
        gx := false }] }

/-- Hop's Corvisquire (sv9-134). Records: sv9-134. -/
def sv9_134 : Card := .pokemon
  { name := "Hop's Corvisquire", stage := .stage1, evolvesFrom := some "Hop's Rookidee",
    hp := 9, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Smash Kick", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Cramorant (sv9-137). Records: sv9-137. -/
def sv9_137 : Card := .pokemon
  { name := "Cramorant", stage := .basic, evolvesFrom := none,
    hp := 11, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Ceaseless Spitting", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.many (.const 5)),
        gx := false }] }

/-- Lechonk (sv9-139). Records: sv9-139. -/
def sv9_139 : Card := .pokemon
  { name := "Lechonk", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Ram", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Oinkologne (sv9-140). Records: sv9-140. Caveats: perPokemon. -/
def sv9_140 : Card := .pokemon
  { name := "Oinkologne", stage := .stage1, evolvesFrom := some "Lechonk",
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
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

/-- Yanma (sv10-2). Records: sv10-2, sv10-183. -/
def sv10_2 : Card := .pokemon
  { name := "Yanma", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Hang Down", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Shroomish (sv10-5). Records: sv10-5. -/
def sv10_5 : Card := .pokemon
  { name := "Shroomish", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rolling Tackle", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Breloom (sv10-6). Records: sv10-6. -/
def sv10_6 : Card := .pokemon
  { name := "Breloom", stage := .stage1, evolvesFrom := some "Shroomish",
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Spike Sting", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Fomantis (sv10-13). Records: sv10-13. -/
def sv10_13 : Card := .pokemon
  { name := "Fomantis", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Cut Up", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Applin (sv10-16). Records: sv10-16. -/
def sv10_16 : Card := .pokemon
  { name := "Applin", stage := .basic, evolvesFrom := none,
    hp := 4, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Mini Drain", cost := [.grass], damage := 1,
        effect := .heal 1,
        gx := false }] }

/-- Team Rocket's Tarountula (sv10-19). Records: sv10-19, me2pt5-18. Caveats: recoil. -/
def sv10_19 : Card := .pokemon
  { name := "Team Rocket's Tarountula", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Take Down", cost := [.grass], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Smoliv (sv10-21). Records: sv10-21. -/
def sv10_21 : Card := .pokemon
  { name := "Smoliv", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Ram", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Dolliv (sv10-22). Records: sv10-22. -/
def sv10_22 : Card := .pokemon
  { name := "Dolliv", stage := .stage1, evolvesFrom := some "Smoliv",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Double Headbutt", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 1)) (.damage (.const 2))),
        gx := false }] }

/-- Ethan's Cyndaquil (sv10-32). Records: sv10-32. -/
def sv10_32 : Card := .pokemon
  { name := "Ethan's Cyndaquil", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Ember", cost := [.fire], damage := 3,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Ethan's Slugma (sv10-35). Records: sv10-35, me2pt5-23. -/
def sv10_35 : Card := .pokemon
  { name := "Ethan's Slugma", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Steady Firebreathing", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Houndour (sv10-37). Records: sv10-37. -/
def sv10_37 : Card := .pokemon
  { name := "Team Rocket's Houndour", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Steady Firebreathing", cost := [.fire], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Houndoom (sv10-38). Records: sv10-38, sv10-191. -/
def sv10_38 : Card := .pokemon
  { name := "Team Rocket's Houndoom", stage := .stage1, evolvesFrom := some "Team Rocket's Houndour",
    hp := 13, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Bubble Beam", cost := [.water], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Clamperl (sv10-54). Records: sv10-54, sv10-195. Caveats: perPokemon. -/
def sv10_54 : Card := .pokemon
  { name := "Clamperl", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Shell Press", cost := [.water], damage := 1,
        effect := .linger .own .next (.reduce 1),
        gx := false }] }

/-- Buizel (sv10-57). Records: sv10-57. -/
def sv10_57 : Card := .pokemon
  { name := "Buizel", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
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
    attacks := [
      { name := "Reckless Charge", cost := [.water], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Cetoddle (sv10-64). Records: sv10-64. -/
def sv10_64 : Card := .pokemon
  { name := "Cetoddle", stage := .basic, evolvesFrom := none,
    hp := 10, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Gentle Slap", cost := [.water, .colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Frost Smash", cost := [.water, .water, .water, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Wellspring Mask Ogerpon (sv10-67). Records: sv10-67. -/
def sv10_67 : Card := .pokemon
  { name := "Wellspring Mask Ogerpon", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Water Kagura", cost := [.colorless], damage := 0,
        effect := .seq (.choice (.attach .own .deck (.energyOf .water) .active .any) (.attach .own .deck (.energyOf .water) .bench .any)) .shuffle,
        gx := false },
      { name := "Bubble Drain", cost := [.water, .water, .colorless], damage := 10,
        effect := .heal 3,
        gx := false }] }

/-- Electabuzz (sv10-68). Records: sv10-68. -/
def sv10_68 : Card := .pokemon
  { name := "Electabuzz", stage := .basic, evolvesFrom := none,
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Electroslug", cost := [.lightning, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Ethan's Pichu (sv10-71). Records: sv10-71. -/
def sv10_71 : Card := .pokemon
  { name := "Ethan's Pichu", stage := .basic, evolvesFrom := none,
    hp := 3, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Zapping Draw", cost := [], damage := 3,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false }] }

/-- Team Rocket's Mareep (sv10-72). Records: sv10-72. -/
def sv10_72 : Card := .pokemon
  { name := "Team Rocket's Mareep", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Procurement", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .item) (.upTo 1)) .shuffle,
        gx := false },
      { name := "Tiny Bolt", cost := [.lightning], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Flaaffy (sv10-73). Records: sv10-73. -/
def sv10_73 : Card := .pokemon
  { name := "Team Rocket's Flaaffy", stage := .stage1, evolvesFrom := some "Team Rocket's Mareep",
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Thunder Shock", cost := [.lightning, .colorless], damage := 5,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Electrike (sv10-75). Records: sv10-75, sv10-196. -/
def sv10_75 : Card := .pokemon
  { name := "Electrike", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rear Kick", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Tiny Bolt", cost := [.lightning, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Manectric (sv10-76). Records: sv10-76. Caveats: benchMods. -/
def sv10_76 : Card := .pokemon
  { name := "Manectric", stage := .stage1, evolvesFrom := some "Electrike",
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Zap Kick", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Flash Impact", cost := [.lightning, .colorless], damage := 12,
        effect := .benchDamage .own 4,
        gx := false }] }

/-- Team Rocket's Drowzee (sv10-79). Records: sv10-79. -/
def sv10_79 : Card := .pokemon
  { name := "Team Rocket's Drowzee", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Hypnotic Ray", cost := [.psychic], damage := 1,
        effect := .inflict .asleep,
        gx := false }] }

/-- Steven's Claydol (sv10-84). Records: sv10-84. -/
def sv10_84 : Card := .pokemon
  { name := "Steven's Claydol", stage := .stage1, evolvesFrom := some "Steven's Baltoy",
    hp := 12, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Eerie Light", cost := [.psychic], damage := 2,
        effect := .inflict .confused,
        gx := false },
      { name := "Clay Blast", cost := [.psychic, .psychic, .colorless], damage := 22,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Team Rocket's Chingling (sv10-85). Records: sv10-85. -/
def sv10_85 : Card := .pokemon
  { name := "Team Rocket's Chingling", stage := .basic, evolvesFrom := none,
    hp := 3, type := .psychic, retreat := 0, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Chiming Commotion", cost := [], damage := 0,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Mankey (sv10-90). Records: sv10-90. -/
def sv10_90 : Card := .pokemon
  { name := "Mankey", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Wild Kick", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Team Rocket's Larvitar (sv10-94). Records: sv10-94. -/
def sv10_94 : Card := .pokemon
  { name := "Team Rocket's Larvitar", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Mountain Munch", cost := [.colorless], damage := 1,
        effect := .move .opp (.top 1) .discard .any .all,
        gx := false }] }

/-- Nosepass (sv10-97). Records: sv10-97. -/
def sv10_97 : Card := .pokemon
  { name := "Nosepass", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Headbutt", cost := [.fighting], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Rock Throw", cost := [.colorless, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Meditite (sv10-99). Records: sv10-99. -/
def sv10_99 : Card := .pokemon
  { name := "Meditite", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Steady Punch", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Hippopotas (sv10-105). Records: sv10-105. -/
def sv10_105 : Card := .pokemon
  { name := "Hippopotas", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Push Down", cost := [.fighting], damage := 1,
        effect := .switch .opp,
        gx := false }] }

/-- Mudbray (sv10-107). Records: sv10-107. -/
def sv10_107 : Card := .pokemon
  { name := "Mudbray", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Running Charge", cost := [.fighting, .colorless], damage := 0,
        effect := .damage (.many (.const 4)),
        gx := false }] }

/-- Arven's Toedscool (sv10-109). Records: sv10-109. Caveats: recoil. -/
def sv10_109 : Card := .pokemon
  { name := "Arven's Toedscool", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Slight Intrusion", cost := [.colorless], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Arven's Toedscruel (sv10-110). Records: sv10-110. Caveats: recoil. -/
def sv10_110 : Card := .pokemon
  { name := "Arven's Toedscruel", stage := .stage1, evolvesFrom := some "Arven's Toedscool",
    hp := 14, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Pull", cost := [.colorless], damage := 0,
        effect := .switch .opp,
        gx := false },
      { name := "Reckless Charge", cost := [.colorless, .colorless, .colorless], damage := 12,
        effect := .selfDamage 3,
        gx := false }] }

/-- Cornerstone Mask Ogerpon (sv10-111). Records: sv10-111. -/
def sv10_111 : Card := .pokemon
  { name := "Cornerstone Mask Ogerpon", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rock Kagura", cost := [.colorless], damage := 0,
        effect := .seq (.choice (.attach .own .deck (.energyOf .fighting) .active .any) (.attach .own .deck (.energyOf .fighting) .bench .any)) .shuffle,
        gx := false },
      { name := "Mountain Ramming", cost := [.fighting, .fighting, .colorless], damage := 10,
        effect := .move .opp (.top 1) .discard .any .all,
        gx := false }] }

/-- Team Rocket's Ekans (sv10-112). Records: sv10-112. -/
def sv10_112 : Card := .pokemon
  { name := "Team Rocket's Ekans", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Drag Down", cost := [.colorless], damage := 0,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Gnaw", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Nidoran♀ (sv10-114). Records: sv10-114. -/
def sv10_114 : Card := .pokemon
  { name := "Team Rocket's Nidoran♀", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Surprise Attack", cost := [.darkness], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Team Rocket's Nidoran♂ (sv10-117). Records: sv10-117. -/
def sv10_117 : Card := .pokemon
  { name := "Team Rocket's Nidoran♂", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Pierce", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Hammer In", cost := [.darkness, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Nidorino (sv10-118). Records: sv10-118. -/
def sv10_118 : Card := .pokemon
  { name := "Team Rocket's Nidorino", stage := .stage1, evolvesFrom := some "Team Rocket's Nidoran♂",
    hp := 10, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Hammer In", cost := [.darkness, .colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Horn Rend", cost := [.darkness, .darkness, .colorless], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 12)) (.damage (.const 6)),
        gx := false }] }

/-- Team Rocket's Nidoking ex (sv10-119). Records: sv10-119, sv10-216, sv10-233. Caveats: poisonStrength. -/
def sv10_119 : Card := .pokemon
  { name := "Team Rocket's Nidoking ex", stage := .stage2, evolvesFrom := some "Team Rocket's Nidorino",
    hp := 33, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    attacks := [
      { name := "Tainted Horn", cost := [.darkness, .darkness, .colorless], damage := 10,
        effect := .seq (.inflict .poisoned) (.poisonUp 7),
        gx := false },
      { name := "Kingly Impact", cost := [.darkness, .darkness, .darkness, .colorless], damage := 24,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Zubat (sv10-120). Records: sv10-120. -/
def sv10_120 : Card := .pokemon
  { name := "Team Rocket's Zubat", stage := .basic, evolvesFrom := none,
    hp := 5, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Poison Spray", cost := [.darkness], damage := 0,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Marnie's Scraggy (sv10-132). Records: sv10-132. -/
def sv10_132 : Card := .pokemon
  { name := "Marnie's Scraggy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Crunch", cost := [.darkness, .darkness, .colorless], damage := 5,
        effect := .ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Marnie's Scrafty (sv10-133). Records: sv10-133. Caveats: recoil. -/
def sv10_133 : Card := .pokemon
  { name := "Marnie's Scrafty", stage := .stage1, evolvesFrom := some "Marnie's Scraggy",
    hp := 12, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rear Kick", cost := [.darkness], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Wild Tackle", cost := [.darkness, .darkness, .colorless], damage := 16,
        effect := .selfDamage 3,
        gx := false }] }

/-- Marnie's Impidimp (sv10-134). Records: sv10-134. -/
def sv10_134 : Card := .pokemon
  { name := "Marnie's Impidimp", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Filch", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Corkscrew Punch", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Marnie's Morgrem (sv10-135). Records: sv10-135. -/
def sv10_135 : Card := .pokemon
  { name := "Marnie's Morgrem", stage := .stage1, evolvesFrom := some "Marnie's Impidimp",
    hp := 10, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Corkscrew Punch", cost := [.darkness, .darkness], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Marnie's Morpeko (sv10-137). Records: sv10-137. -/
def sv10_137 : Card := .pokemon
  { name := "Marnie's Morpeko", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 0, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Spiky Wheel", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.count (.energy .own (.energyOf .darkness)) 4)),
        gx := false }] }

/-- Arven's Maschiff (sv10-138). Records: sv10-138. -/
def sv10_138 : Card := .pokemon
  { name := "Arven's Maschiff", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Stampede", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Confront", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Skarmory (sv10-141). Records: sv10-141. Caveats: perPokemon. -/
def sv10_141 : Card := .pokemon
  { name := "Skarmory", stage := .basic, evolvesFrom := none,
    hp := 11, type := .metal, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Roost", cost := [.colorless], damage := 0,
        effect := .seq (.heal 5) (.linger .own .after (.lock .retreat)),
        gx := false },
      { name := "Metal Claw", cost := [.metal, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Steven's Beldum (sv10-143). Records: sv10-143. -/
def sv10_143 : Card := .pokemon
  { name := "Steven's Beldum", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Ram", cost := [.metal, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Steven's Metang (sv10-144). Records: sv10-144. Caveats: perPokemon. -/
def sv10_144 : Card := .pokemon
  { name := "Steven's Metang", stage := .stage1, evolvesFrom := some "Steven's Beldum",
    hp := 10, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Metal Slash", cost := [.metal, .colorless], damage := 7,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Team Rocket's Rattata (sv10-147). Records: sv10-147. -/
def sv10_147 : Card := .pokemon
  { name := "Team Rocket's Rattata", stage := .basic, evolvesFrom := none,
    hp := 5, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Dangerous Incisors", cost := [.colorless], damage := 1,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Kangaskhan (sv10-151). Records: sv10-151, sv10-204. -/
def sv10_151 : Card := .pokemon
  { name := "Kangaskhan", stage := .basic, evolvesFrom := none,
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Dizzy Punch", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 9)) (.damage (.const 18))),
        gx := false }] }

/-- Taillow (sv10-156). Records: sv10-156. -/
def sv10_156 : Card := .pokemon
  { name := "Taillow", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Wing Attack", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Swellow (sv10-157). Records: sv10-157. -/
def sv10_157 : Card := .pokemon
  { name := "Swellow", stage := .stage1, evolvesFrom := some "Taillow",
    hp := 10, type := .colorless, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Add On", cost := [.colorless], damage := 0,
        effect := .move .own (.top 3) .hand .any .all,
        gx := false },
      { name := "Speed Wing", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Squawkabilly (sv10-160). Records: sv10-160. -/
def sv10_160 : Card := .pokemon
  { name := "Squawkabilly", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Push Down", cost := [.colorless], damage := 2,
        effect := .choice (.switch .opp) .skip,
        gx := false }] }

/-- Energy Recycler (sv10-164). Records: sv10-164, me3-108. Caveats: upTo0. -/
def sv10_164 : Card := .trainer "Energy Recycler" .item
    (.move .own .discard .shuffle .energy (.upTo 5))

/-- Sacred Ash (sv10-168). Records: sv10-168, me3-115. Caveats: upTo0. -/
def sv10_168 : Card := .trainer "Sacred Ash" .item
    (.move .own .discard .shuffle .pokemon (.upTo 5))

/-- Team Rocket's Petrel (sv10-176). Records: sv10-176, sv10-226, me2pt5-207. -/
def sv10_176 : Card := .trainer "Team Rocket's Petrel" .supporter
    (.seq (.move .own .deck .hand .trainer (.upTo 1)) .shuffle)

/-- Team Rocket's Venture Bomb (sv10-179). Records: sv10-179. -/
def sv10_179 : Card := .trainer "Team Rocket's Venture Bomb" .item
    (.choice (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 2) (.benchCounters .opp 2)) (.counters 2)) (.selfDamage 2))

/-- Sewaddle (rsv10pt5-1). Records: rsv10pt5-1, rsv10pt5-87. -/
def rsv10pt5_1 : Card := .pokemon
  { name := "Sewaddle", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Bug Bite", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Cottonee (rsv10pt5-4). Records: rsv10pt5-4, rsv10pt5-90. -/
def rsv10pt5_4 : Card := .pokemon
  { name := "Cottonee", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Absorb", cost := [.grass], damage := 1,
        effect := .heal 1,
        gx := false }] }

/-- Deerling (rsv10pt5-6). Records: rsv10pt5-6, rsv10pt5-91. -/
def rsv10pt5_6 : Card := .pokemon
  { name := "Deerling", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Rear Kick", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Sawsbuck (rsv10pt5-7). Records: rsv10pt5-7, rsv10pt5-92. -/
def rsv10pt5_7 : Card := .pokemon
  { name := "Sawsbuck", stage := .stage1, evolvesFrom := some "Deerling",
    hp := 13, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Push Down", cost := [.colorless, .colorless], damage := 5,
        effect := .switch .opp,
        gx := false },
      { name := "Solar Beam", cost := [.grass, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Accelgor (rsv10pt5-9). Records: rsv10pt5-9, rsv10pt5-94. -/
def rsv10pt5_9 : Card := .pokemon
  { name := "Accelgor", stage := .stage1, evolvesFrom := some "Shelmet",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Acid Spray", cost := [.grass], damage := 5,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Virizion (rsv10pt5-10). Records: rsv10pt5-10, rsv10pt5-95. Caveats: perPokemon. -/
def rsv10pt5_10 : Card := .pokemon
  { name := "Virizion", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Giga Drain", cost := [.grass], damage := 0,
        effect := .drain (.const 3),
        gx := false },
      { name := "Emerald Blade", cost := [.grass, .grass, .colorless], damage := 13,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Tepig (rsv10pt5-11). Records: rsv10pt5-11, rsv10pt5-96. -/
def rsv10pt5_11 : Card := .pokemon
  { name := "Tepig", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Tackle", cost := [.fire], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Rollout", cost := [.fire, .fire], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Pignite (rsv10pt5-12). Records: rsv10pt5-12, rsv10pt5-97. -/
def rsv10pt5_12 : Card := .pokemon
  { name := "Pignite", stage := .stage1, evolvesFrom := some "Tepig",
    hp := 11, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Combustion", cost := [.fire], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Heat Crash", cost := [.fire, .fire, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Pansear (rsv10pt5-14). Records: rsv10pt5-14, rsv10pt5-99. -/
def rsv10pt5_14 : Card := .pokemon
  { name := "Pansear", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Scratch", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Simisear (rsv10pt5-15). Records: rsv10pt5-15, rsv10pt5-100. -/
def rsv10pt5_15 : Card := .pokemon
  { name := "Simisear", stage := .stage1, evolvesFrom := some "Pansear",
    hp := 10, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Lampent (rsv10pt5-17). Records: rsv10pt5-17, rsv10pt5-102. -/
def rsv10pt5_17 : Card := .pokemon
  { name := "Lampent", stage := .stage1, evolvesFrom := some "Litwick",
    hp := 8, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Fire Blast", cost := [.fire], damage := 5,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Chandelure (rsv10pt5-18). Records: rsv10pt5-18, rsv10pt5-103. -/
def rsv10pt5_18 : Card := .pokemon
  { name := "Chandelure", stage := .stage2, evolvesFrom := some "Lampent",
    hp := 15, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Incendiary Pillar", cost := [.fire], damage := 0,
        effect := .ite (.countGe (.pile .own .discard (.energyOf .fire)) 10) (.damage (.const 15)) (.damage (.const 5)),
        gx := false },
      { name := "Burn It All Up", cost := [.fire, .fire], damage := 18,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Heatmor (rsv10pt5-19). Records: rsv10pt5-19, rsv10pt5-104. -/
def rsv10pt5_19 : Card := .pokemon
  { name := "Heatmor", stage := .basic, evolvesFrom := none,
    hp := 12, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Licking Catch", cost := [.fire], damage := 0,
        effect := .seq (.move .own .deck .hand (.or (.ptype .fire) (.energyOf .fire)) (.upTo 3)) .shuffle,
        gx := false },
      { name := "Fire Claws", cost := [.fire, .fire], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Oshawott (rsv10pt5-21). Records: rsv10pt5-21, rsv10pt5-105. -/
def rsv10pt5_21 : Card := .pokemon
  { name := "Oshawott", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Tackle", cost := [.water], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Water Gun", cost := [.water, .water], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Dewott (rsv10pt5-22). Records: rsv10pt5-22, rsv10pt5-106. -/
def rsv10pt5_22 : Card := .pokemon
  { name := "Dewott", stage := .stage1, evolvesFrom := some "Oshawott",
    hp := 10, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Energized Shell", cost := [.water], damage := 0,
        effect := .damage (.count (.energy .own .energy) 3),
        gx := false }] }

/-- Ducklett (rsv10pt5-25). Records: rsv10pt5-25, rsv10pt5-109. -/
def rsv10pt5_25 : Card := .pokemon
  { name := "Ducklett", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Firefighting", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.energy .opp (.energyOf .fire)) 1) (.discardEnergy .opp .active (.energyOf .fire) (.exactly 1)) .skip,
        gx := false },
      { name := "Wing Attack", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Swanna (rsv10pt5-26). Records: rsv10pt5-26, rsv10pt5-110. -/
def rsv10pt5_26 : Card := .pokemon
  { name := "Swanna", stage := .stage1, evolvesFrom := some "Ducklett",
    hp := 12, type := .water, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Flap", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Air Slash", cost := [.colorless, .colorless, .colorless], damage := 12,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Vanillite (rsv10pt5-27). Records: rsv10pt5-27, rsv10pt5-111. -/
def rsv10pt5_27 : Card := .pokemon
  { name := "Vanillite", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Beat", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Ice Edge", cost := [.water, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Vanillish (rsv10pt5-28). Records: rsv10pt5-28, rsv10pt5-112. -/
def rsv10pt5_28 : Card := .pokemon
  { name := "Vanillish", stage := .stage1, evolvesFrom := some "Vanillite",
    hp := 9, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Ram", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Ice Beam", cost := [.water, .colorless, .colorless], damage := 5,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Blitzle (rsv10pt5-31). Records: rsv10pt5-31, rsv10pt5-114. -/
def rsv10pt5_31 : Card := .pokemon
  { name := "Blitzle", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Smash Kick", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Zap Kick", cost := [.lightning, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Zebstrika (rsv10pt5-32). Records: rsv10pt5-32, rsv10pt5-115. Caveats: benchMods. -/
def rsv10pt5_32 : Card := .pokemon
  { name := "Zebstrika", stage := .stage1, evolvesFrom := some "Blitzle",
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Smash Kick", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Electrobullet", cost := [.lightning, .lightning, .colorless], damage := 10,
        effect := .benchDamage .opp 3,
        gx := false }] }

/-- Joltik (rsv10pt5-33). Records: rsv10pt5-33, rsv10pt5-116. -/
def rsv10pt5_33 : Card := .pokemon
  { name := "Joltik", stage := .basic, evolvesFrom := none,
    hp := 4, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Surprise Attack", cost := [.lightning], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Stunfisk (rsv10pt5-35). Records: rsv10pt5-35, rsv10pt5-118. -/
def rsv10pt5_35 : Card := .pokemon
  { name := "Stunfisk", stage := .basic, evolvesFrom := none,
    hp := 11, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Muddy Bolt", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.energy .own (.energyOf .fighting)) 1) (.damage (.const 4)) (.damage (.const 2)),
        gx := false },
      { name := "Flop", cost := [.lightning, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Woobat (rsv10pt5-36). Records: rsv10pt5-36, rsv10pt5-119. -/
def rsv10pt5_36 : Card := .pokemon
  { name := "Woobat", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Heart Stamp", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Yamask (rsv10pt5-39). Records: rsv10pt5-39, rsv10pt5-122. -/
def rsv10pt5_39 : Card := .pokemon
  { name := "Yamask", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Focused Wish", cost := [.psychic, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Gothita (rsv10pt5-41). Records: rsv10pt5-41, rsv10pt5-124. -/
def rsv10pt5_41 : Card := .pokemon
  { name := "Gothita", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Super Psy Bolt", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Frillish (rsv10pt5-44). Records: rsv10pt5-44, rsv10pt5-126. -/
def rsv10pt5_44 : Card := .pokemon
  { name := "Frillish", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Oceanic Gloom", cost := [.psychic], damage := 2,
        effect := .linger .opp .next (.lock .item),
        gx := false }] }

/-- Archen (rsv10pt5-50). Records: rsv10pt5-50, rsv10pt5-131. -/
def rsv10pt5_50 : Card := .pokemon
  { name := "Archen", stage := .stage1, evolvesFrom := some "Antiuqe Plume Fossil",
    hp := 8, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Acrobatics", cost := [.fighting, .colorless], damage := 0,
        effect := .choice (.damage (.const 3)) (.choice (.damage (.const 6)) (.damage (.const 9))),
        gx := false }] }

/-- Mienfoo (rsv10pt5-52). Records: rsv10pt5-52, rsv10pt5-133. -/
def rsv10pt5_52 : Card := .pokemon
  { name := "Mienfoo", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Kick", cost := [.fighting], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Purrloin (rsv10pt5-55). Records: rsv10pt5-55, rsv10pt5-136. -/
def rsv10pt5_55 : Card := .pokemon
  { name := "Purrloin", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Invite Evil", cost := [.darkness], damage := 0,
        effect := .seq (.move .own .deck .hand (.ptype .darkness) (.upTo 3)) .shuffle,
        gx := false }] }

/-- Liepard (rsv10pt5-56). Records: rsv10pt5-56, rsv10pt5-137. -/
def rsv10pt5_56 : Card := .pokemon
  { name := "Liepard", stage := .stage1, evolvesFrom := some "Purrloin",
    hp := 11, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Knock Off", cost := [.darkness], damage := 5,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Scraggy (rsv10pt5-57). Records: rsv10pt5-57, rsv10pt5-138. -/
def rsv10pt5_57 : Card := .pokemon
  { name := "Scraggy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Headbutt", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Invade", cost := [.darkness, .darkness], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Trubbish (rsv10pt5-59). Records: rsv10pt5-59, rsv10pt5-140. -/
def rsv10pt5_59 : Card := .pokemon
  { name := "Trubbish", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Drool", cost := [.darkness], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Sludge Bomb", cost := [.darkness, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Garbodor (rsv10pt5-60). Records: rsv10pt5-60, rsv10pt5-141. -/
def rsv10pt5_60 : Card := .pokemon
  { name := "Garbodor", stage := .stage1, evolvesFrom := some "Trubbish",
    hp := 14, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Suffocating Gas", cost := [.darkness], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Gunk Shot", cost := [.darkness, .darkness, .colorless], damage := 12,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Zorua (rsv10pt5-61). Records: rsv10pt5-61, rsv10pt5-142. Caveats: recoil. -/
def rsv10pt5_61 : Card := .pokemon
  { name := "Zorua", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Take Down", cost := [.darkness], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Vullaby (rsv10pt5-63). Records: rsv10pt5-63, rsv10pt5-144. -/
def rsv10pt5_63 : Card := .pokemon
  { name := "Vullaby", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Playful Kick", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Deino (rsv10pt5-65). Records: rsv10pt5-65, rsv10pt5-146. -/
def rsv10pt5_65 : Card := .pokemon
  { name := "Deino", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Body Slam", cost := [.colorless, .colorless], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Darkness Fang", cost := [.darkness, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Zweilous (rsv10pt5-66). Records: rsv10pt5-66, rsv10pt5-147. -/
def rsv10pt5_66 : Card := .pokemon
  { name := "Zweilous", stage := .stage1, evolvesFrom := some "Deino",
    hp := 11, type := .darkness, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Double Hit", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 4)) (.damage (.const 8))),
        gx := false },
      { name := "Pitch-Black Fangs", cost := [.darkness, .darkness, .colorless, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Ferroseed (rsv10pt5-68). Records: rsv10pt5-68, rsv10pt5-148. -/
def rsv10pt5_68 : Card := .pokemon
  { name := "Ferroseed", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    attacks := [
      { name := "Zzzt", cost := [.metal], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Metal Claw", cost := [.metal, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Patrat (rsv10pt5-72). Records: rsv10pt5-72, rsv10pt5-152. -/
def rsv10pt5_72 : Card := .pokemon
  { name := "Patrat", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Procurement", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand (.kind .item) (.upTo 1)) .shuffle,
        gx := false },
      { name := "Gnaw", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Lillipup (rsv10pt5-74). Records: rsv10pt5-74, rsv10pt5-154. -/
def rsv10pt5_74 : Card := .pokemon
  { name := "Lillipup", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Play Rough", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Herdier (rsv10pt5-75). Records: rsv10pt5-75, rsv10pt5-155. -/
def rsv10pt5_75 : Card := .pokemon
  { name := "Herdier", stage := .stage1, evolvesFrom := some "Lillipup",
    hp := 9, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Roar", cost := [.colorless], damage := 0,
        effect := .switch .opp,
        gx := false },
      { name := "Lunge Out", cost := [.colorless, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Cheren (rsv10pt5-81). Records: rsv10pt5-81, me2pt5-258. -/
def rsv10pt5_81 : Card := .trainer "Cheren" .supporter
    (.move .own (.top 3) .hand .any .all)

/-- Energy Retrieval (rsv10pt5-82). Records: rsv10pt5-82, me4-108. Caveats: upTo0. -/
def rsv10pt5_82 : Card := .trainer "Energy Retrieval" .item
    (.move .own .discard .hand .energy (.upTo 2))

/-- Victini (rsv10pt5-172). Records: rsv10pt5-172, zsv10pt5-12, zsv10pt5-171. -/
def rsv10pt5_172 : Card := .pokemon
  { name := "Victini", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "V-Force", cost := [.fire, .fire], damage := 0,
        effect := .ite (.countGe (.bench .own .pokemon) 5) (.damage (.const 12)) .skip,
        gx := false }] }

/-- Snivy (zsv10pt5-1). Records: zsv10pt5-1, zsv10pt5-87. -/
def zsv10pt5_1 : Card := .pokemon
  { name := "Snivy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Tackle", cost := [.grass], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Vine Whip", cost := [.grass, .grass], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Servine (zsv10pt5-2). Records: zsv10pt5-2, zsv10pt5-88. -/
def zsv10pt5_2 : Card := .pokemon
  { name := "Servine", stage := .stage1, evolvesFrom := some "Snivy",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Wrap", cost := [.grass], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Vine Whip", cost := [.grass, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Pansage (zsv10pt5-4). Records: zsv10pt5-4, zsv10pt5-89. -/
def zsv10pt5_4 : Card := .pokemon
  { name := "Pansage", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Scratch", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Simisage (zsv10pt5-5). Records: zsv10pt5-5, zsv10pt5-90. -/
def zsv10pt5_5 : Card := .pokemon
  { name := "Simisage", stage := .stage1, evolvesFrom := some "Pansage",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Lilligant (zsv10pt5-7). Records: zsv10pt5-7, zsv10pt5-92. -/
def zsv10pt5_7 : Card := .pokemon
  { name := "Lilligant", stage := .stage1, evolvesFrom := some "Petilil",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Bemusing Aroma", cost := [.grass], damage := 3,
        effect := .choice (.seq (.inflict .paralyzed) (.inflict .poisoned)) (.inflict .confused),
        gx := false },
      { name := "Cut", cost := [.grass, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Foongus (zsv10pt5-10). Records: zsv10pt5-10, zsv10pt5-95. -/
def zsv10pt5_10 : Card := .pokemon
  { name := "Foongus", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Toxic Spore", cost := [.colorless], damage := 0,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Amoonguss (zsv10pt5-11). Records: zsv10pt5-11, zsv10pt5-96. -/
def zsv10pt5_11 : Card := .pokemon
  { name := "Amoonguss", stage := .stage1, evolvesFrom := some "Foongus",
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Dangerous Reaction", cost := [.colorless], damage := 0,
        effect := .ite (.cond .opp .asleep) (.damage (.const 15)) (.ite (.cond .opp .burned) (.damage (.const 15)) (.ite (.cond .opp .confused) (.damage (.const 15)) (.ite (.cond .opp .paralyzed) (.damage (.const 15)) (.ite (.cond .opp .poisoned) (.damage (.const 15)) (.damage (.const 3)))))),
        gx := false },
      { name := "Seed Bomb", cost := [.grass, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Darumaka (zsv10pt5-13). Records: zsv10pt5-13, zsv10pt5-97. -/
def zsv10pt5_13 : Card := .pokemon
  { name := "Darumaka", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Will-O-Wisp", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Darmanitan (zsv10pt5-14). Records: zsv10pt5-14, zsv10pt5-98. -/
def zsv10pt5_14 : Card := .pokemon
  { name := "Darmanitan", stage := .stage1, evolvesFrom := some "Darumaka",
    hp := 14, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Searing Flame", cost := [.fire, .colorless], damage := 5,
        effect := .inflict .burned,
        gx := false },
      { name := "Smashing Headbutt", cost := [.fire, .colorless, .colorless, .colorless], damage := 18,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Panpour (zsv10pt5-17). Records: zsv10pt5-17, zsv10pt5-101. -/
def zsv10pt5_17 : Card := .pokemon
  { name := "Panpour", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Collect", cost := [.colorless], damage := 0,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false },
      { name := "Scratch", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Simipour (zsv10pt5-18). Records: zsv10pt5-18, zsv10pt5-102. -/
def zsv10pt5_18 : Card := .pokemon
  { name := "Simipour", stage := .stage1, evolvesFrom := some "Panpour",
    hp := 10, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Tirtouga (zsv10pt5-22). Records: zsv10pt5-22, zsv10pt5-106. -/
def zsv10pt5_22 : Card := .pokemon
  { name := "Tirtouga", stage := .stage1, evolvesFrom := some "Antique Cover Fossil",
    hp := 10, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Ancient Seaweed", cost := [.water], damage := 0,
        effect := .damage (.count (.pile .opp .discard (.kind .item)) 3),
        gx := false },
      { name := "Surf", cost := [.water, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Cubchoo (zsv10pt5-25). Records: zsv10pt5-25, zsv10pt5-109. Caveats: perPokemon. -/
def zsv10pt5_25 : Card := .pokemon
  { name := "Cubchoo", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Snotted Up", cost := [.water], damage := 1,
        effect := .linger .opp .next (.lock .attack),
        gx := false }] }

/-- Beartic (zsv10pt5-26). Records: zsv10pt5-26, zsv10pt5-110. Caveats: perPokemon. -/
def zsv10pt5_26 : Card := .pokemon
  { name := "Beartic", stage := .stage1, evolvesFrom := some "Cubchoo",
    hp := 15, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Continuous Headbutt", cost := [.colorless], damage := 0,
        effect := .damage (.many (.const 5)),
        gx := false },
      { name := "Sheer Cold", cost := [.water, .water, .water, .colorless], damage := 15,
        effect := .linger .opp .next (.lock .attack),
        gx := false }] }

/-- Emolga (zsv10pt5-29). Records: zsv10pt5-29, zsv10pt5-112. -/
def zsv10pt5_29 : Card := .pokemon
  { name := "Emolga", stage := .basic, evolvesFrom := none,
    hp := 7, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Call for Family", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic)) .shuffle,
        gx := false },
      { name := "Static Shock", cost := [.lightning], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Tynamo (zsv10pt5-30). Records: zsv10pt5-30, zsv10pt5-113, me2pt5-59. -/
def zsv10pt5_30 : Card := .pokemon
  { name := "Tynamo", stage := .basic, evolvesFrom := none,
    hp := 4, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    attacks := [
      { name := "Hold Still", cost := [.colorless], damage := 0,
        effect := .heal 1,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  sv9_118,
  sv9_119,
  sv9_120,
  sv9_124,
  sv9_125,
  sv9_126,
  sv9_127,
  sv9_130,
  sv9_131,
  sv9_132,
  sv9_134,
  sv9_135,
  sv9_137,
  sv9_139,
  sv9_140,
  sv9_141,
  sv9_149,
  sv10_2,
  sv10_4,
  sv10_5,
  sv10_6,
  sv10_7,
  sv10_13,
  sv10_16,
  sv10_19,
  sv10_21,
  sv10_22,
  sv10_27,
  sv10_28,
  sv10_29,
  sv10_32,
  sv10_35,
  sv10_37,
  sv10_38,
  sv10_40,
  sv10_41,
  sv10_42,
  sv10_44,
  sv10_46,
  sv10_54,
  sv10_57,
  sv10_58,
  sv10_59,
  sv10_60,
  sv10_62,
  sv10_64,
  sv10_67,
  sv10_68,
  sv10_71,
  sv10_72,
  sv10_73,
  sv10_75,
  sv10_76,
  sv10_79,
  sv10_84,
  sv10_85,
  sv10_90,
  sv10_94,
  sv10_97,
  sv10_99,
  sv10_105,
  sv10_107,
  sv10_109,
  sv10_110,
  sv10_111,
  sv10_112,
  sv10_114,
  sv10_117,
  sv10_118,
  sv10_119,
  sv10_120,
  sv10_132,
  sv10_133,
  sv10_134,
  sv10_135,
  sv10_137,
  sv10_138,
  sv10_141,
  sv10_143,
  sv10_144,
  sv10_147,
  sv10_151,
  sv10_156,
  sv10_157,
  sv10_160,
  sv10_164,
  sv10_168,
  sv10_176,
  sv10_179,
  rsv10pt5_1,
  rsv10pt5_4,
  rsv10pt5_6,
  rsv10pt5_7,
  rsv10pt5_9,
  rsv10pt5_10,
  rsv10pt5_11,
  rsv10pt5_12,
  rsv10pt5_14,
  rsv10pt5_15,
  rsv10pt5_17,
  rsv10pt5_18,
  rsv10pt5_19,
  rsv10pt5_21,
  rsv10pt5_22,
  rsv10pt5_25,
  rsv10pt5_26,
  rsv10pt5_27,
  rsv10pt5_28,
  rsv10pt5_31,
  rsv10pt5_32,
  rsv10pt5_33,
  rsv10pt5_35,
  rsv10pt5_36,
  rsv10pt5_39,
  rsv10pt5_41,
  rsv10pt5_44,
  rsv10pt5_50,
  rsv10pt5_52,
  rsv10pt5_55,
  rsv10pt5_56,
  rsv10pt5_57,
  rsv10pt5_59,
  rsv10pt5_60,
  rsv10pt5_61,
  rsv10pt5_63,
  rsv10pt5_65,
  rsv10pt5_66,
  rsv10pt5_68,
  rsv10pt5_72,
  rsv10pt5_74,
  rsv10pt5_75,
  rsv10pt5_81,
  rsv10pt5_82,
  rsv10pt5_172,
  zsv10pt5_1,
  zsv10pt5_2,
  zsv10pt5_4,
  zsv10pt5_5,
  zsv10pt5_7,
  zsv10pt5_10,
  zsv10pt5_11,
  zsv10pt5_13,
  zsv10pt5_14,
  zsv10pt5_17,
  zsv10pt5_18,
  zsv10pt5_22,
  zsv10pt5_25,
  zsv10pt5_26,
  zsv10pt5_29,
  zsv10pt5_30]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

end PokemonCards.Standard.Part04
