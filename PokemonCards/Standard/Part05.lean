/-
Imported Standard cards, part 5 of 10 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.10.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part05
open Pokemon

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

/-- Brock's Scouting (sv9-146). Records: sv9-146, sv9-179. Caveats: upTo0. -/
def sv9_146 : Card := .trainer "Brock's Scouting" .supporter
    (.seq (.choice (.move .own .deck .hand .basic (.upTo 2)) (.move .own .deck .hand (.and .pokemon (.not .basic)) (.upTo 1))) .shuffle)

/-- Hop's Bag (sv9-147). Records: sv9-147. Caveats: upTo0. -/
def sv9_147 : Card := .trainer "Hop's Bag" .item
    (.seq (.seq (.putBench .own .deck (.and .basic (.namePrefix "Hop's "))) (.putBench .own .deck (.and .basic (.namePrefix "Hop's ")))) .shuffle)

/-- Iris's Fighting Spirit (sv9-149). Records: sv9-149, sv9-180, me2pt5-190, me2pt5-292. -/
def sv9_149 : Card := .trainer "Iris's Fighting Spirit" .supporter
    (.seq (.move .own .hand .discard .any (.exactly 1)) (.drawTo .own 6))

/-- Levincia (sv9-150). Records: sv9-150, sv10-244. Caveats: upTo0. -/
def sv9_150 : Card := .trainer "Levincia" .stadium
    (.move .own .discard .hand (.energyOf .lightning) (.upTo 2))

/-- Postwick (sv9-154). Records: sv9-154. -/
def sv9_154 : Card := .trainer "Postwick" .stadium
    .skip [
      { sel := .all, filt := .and .pokemon (.namePrefix "Hop's "), tgt := none, src := none, need := none, eff := .bonus 3 .any }]

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

/-- Cynthia's Roserade (sv10-8). Records: sv10-8, sv10-184. -/
def sv10_8 : Card := .pokemon
  { name := "Cynthia's Roserade", stage := .stage1, evolvesFrom := some "Cynthia's Roselia",
    hp := 13, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Cheer On to Glory", use := .static [{ sel := .own, filt := .and .pokemon (.namePrefix "Cynthia's "), tgt := none, src := none, need := none, eff := .bonus 3 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Leaf Step", cost := [.grass, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Mow Rotom (sv10-9). Records: sv10-9. -/
def sv10_9 : Card := .pokemon
  { name := "Mow Rotom", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Trimming Mower", cost := [.grass], damage := 2,
        effect := .discardStadium,
        gx := false },
      { name := "Gadget Show", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.tools .own) 3),
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

/-- Team Rocket's Spidops (sv10-20). Records: sv10-20, sv10-187, me2pt5-19. Caveats: mayFail, selfBench. -/
def sv10_20 : Card := .pokemon
  { name := "Team Rocket's Spidops", stage := .stage1, evolvesFrom := some "Team Rocket's Tarountula",
    hp := 13, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Charging Up", use := .once,
        spot := none, cond := none,
        effect := .self (.attach .discard .energy) }],
    attacks := [
      { name := "Rocket Rush", cost := [.grass, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .own (.and .pokemon (.namePrefix "Team Rocket's "))) 3),
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

/-- Teal Mask Ogerpon (sv10-26). Records: sv10-26. -/
def sv10_26 : Card := .pokemon
  { name := "Teal Mask Ogerpon", stage := .basic, evolvesFrom := none,
    hp := 11, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Grass Kagura", cost := [.colorless], damage := 0,
        effect := .seq (.choice (.attach .own .deck (.energyOf .grass) .active .any) (.attach .own .deck (.energyOf .grass) .bench .any)) .shuffle,
        gx := false },
      { name := "Ogre's Hammer", cost := [.grass, .grass, .colorless], damage := 12,
        effect := .skip,
        gx := false, selfLock := .this }] }

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

/-- Heat Rotom (sv10-43). Records: sv10-43. -/
def sv10_43 : Card := .pokemon
  { name := "Heat Rotom", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Singe", cost := [.fire], damage := 0,
        effect := .inflict .burned,
        gx := false },
      { name := "Gadget Show", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.tools .own) 3),
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

/-- Misty's Lapras (sv10-50). Records: sv10-50, sv10-194. -/
def sv10_50 : Card := .pokemon
  { name := "Misty's Lapras", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Swim Together", cost := [.water], damage := 0,
        effect := .seq (.move .own .deck .hand (.and .pokemon (.namePrefix "Misty's ")) (.upTo 3)) .shuffle,
        gx := false },
      { name := "Surf", cost := [.water, .colorless], damage := 6,
        effect := .skip,
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

/-- Floatzel (sv10-58). Records: sv10-58. -/
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
        effect := .skip,
        gx := false, selfLock := .all }] }

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

/-- Cetoddle (sv10-64). Records: sv10-64. -/
def sv10_64 : Card := .pokemon
  { name := "Cetoddle", stage := .basic, evolvesFrom := none,
    hp := 10, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Electroslug", cost := [.lightning, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Electivire ex (sv10-69). Records: sv10-69, sv10-212. Caveats: benchMods. -/
def sv10_69 : Card := .pokemon
  { name := "Electivire ex", stage := .stage1, evolvesFrom := some "Electabuzz",
    hp := 28, type := .lightning, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Dual Bolt", cost := [.lightning, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .any) 2) (.choice (.seq (.damage (.const 5)) (.benchSome .opp 1 .any true 5)) (.benchSome .opp 2 .any true 5)) (.seq (.damage (.const 5)) (.benchSome .opp 1 .any true 5)),
        gx := false },
      { name := "High-Voltage Press", cost := [.lightning, .lightning, .colorless], damage := 0,
        effect := .ite (.countGe (.energy .own .energy) 5) (.damage (.const 28)) (.damage (.const 18)),
        gx := false }] }

/-- Ethan's Pichu (sv10-71). Records: sv10-71. -/
def sv10_71 : Card := .pokemon
  { name := "Ethan's Pichu", stage := .basic, evolvesFrom := none,
    hp := 3, type := .lightning, retreat := 0, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Zapping Draw", cost := [], damage := 3,
        effect := .move .own (.top 1) .hand .any .all,
        gx := false }] }

/-- Team Rocket's Mareep (sv10-72). Records: sv10-72. -/
def sv10_72 : Card := .pokemon
  { name := "Team Rocket's Mareep", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Thunder Shock", cost := [.lightning, .colorless], damage := 5,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false }] }

/-- Electrike (sv10-75). Records: sv10-75, sv10-196. -/
def sv10_75 : Card := .pokemon
  { name := "Electrike", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Zap Kick", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Flash Impact", cost := [.lightning, .colorless], damage := 12,
        effect := .benchDamage .own 4,
        gx := false }] }

/-- Rotom (sv10-77). Records: sv10-77, sv10-197. -/
def sv10_77 : Card := .pokemon
  { name := "Rotom", stage := .basic, evolvesFrom := none,
    hp := 6, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Astonish", cost := [.lightning], damage := 2,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .shuffle .any (.exactly 1)) .skip,
        gx := false },
      { name := "Gadget Show", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.tools .own) 3),
        gx := false }] }

/-- Zeraora (sv10-78). Records: sv10-78. Caveats: benchMods. -/
def sv10_78 : Card := .pokemon
  { name := "Zeraora", stage := .basic, evolvesFrom := none,
    hp := 10, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scratch", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false },
      { name := "Thunder Raid", cost := [.lightning, .lightning, .lightning], damage := 0,
        effect := .seq (.discardEnergy .own .active .energy .all) (.benchSome .opp 1 .ex true 21),
        gx := false }] }

/-- Team Rocket's Drowzee (sv10-79). Records: sv10-79. -/
def sv10_79 : Card := .pokemon
  { name := "Team Rocket's Drowzee", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hypnotic Ray", cost := [.psychic], damage := 1,
        effect := .inflict .asleep,
        gx := false }] }

/-- Steven's Baltoy (sv10-83). Records: sv10-83. -/
def sv10_83 : Card := .pokemon
  { name := "Steven's Baltoy", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Summoning Sign", cost := [.colorless], damage := 0,
        effect := .seq (.seq (.putBench .own .deck (.and .basic (.namePrefix "Steven's "))) (.putBench .own .deck (.and .basic (.namePrefix "Steven's ")))) .shuffle,
        gx := false },
      { name := "Psychic Sphere", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Steven's Claydol (sv10-84). Records: sv10-84. -/
def sv10_84 : Card := .pokemon
  { name := "Steven's Claydol", stage := .stage1, evolvesFrom := some "Steven's Baltoy",
    hp := 12, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Chiming Commotion", cost := [], damage := 0,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Mankey (sv10-90). Records: sv10-90. -/
def sv10_90 : Card := .pokemon
  { name := "Mankey", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wild Kick", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Primeape (sv10-91). Records: sv10-91. -/
def sv10_91 : Card := .pokemon
  { name := "Primeape", stage := .stage1, evolvesFrom := some "Mankey",
    hp := 11, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Drag Off", cost := [.fighting], damage := 0,
        effect := .seq (.switch .opp) (.ite (.countGe (.bench .opp .pokemon) 1) (.damage (.const 3)) .skip),
        gx := false }] }

/-- Team Rocket's Larvitar (sv10-94). Records: sv10-94. -/
def sv10_94 : Card := .pokemon
  { name := "Team Rocket's Larvitar", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mountain Munch", cost := [.colorless], damage := 1,
        effect := .move .opp (.top 1) .discard .any .all,
        gx := false }] }

/-- Nosepass (sv10-97). Records: sv10-97. -/
def sv10_97 : Card := .pokemon
  { name := "Nosepass", stage := .basic, evolvesFrom := none,
    hp := 8, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Steady Punch", cost := [.fighting], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Regirock ex (sv10-101). Records: sv10-101, sv10-214, me2pt5-107. -/
def sv10_101 : Card := .pokemon
  { name := "Regirock ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Regi Charge", cost := [.colorless], damage := 0,
        effect := .seq (.attach .own .discard (.energyOf .fighting) .active .any) (.attach .own .discard (.energyOf .fighting) .active .any),
        gx := false },
      { name := "Giant Rock", cost := [.fighting, .colorless, .colorless, .colorless], damage := 0,
        effect := .ite (.top .opp (.stage .stage2)) (.damage (.const 28)) (.damage (.const 14)),
        gx := false }] }

/-- Cynthia's Gible (sv10-102). Records: sv10-102, me2pt5-109. -/
def sv10_102 : Card := .pokemon
  { name := "Cynthia's Gible", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rock Hurl", cost := [.fighting], damage := 0,
        effect := .damage (.const 2) { resist := true },
        gx := false }] }

/-- Cynthia's Gabite (sv10-103). Records: sv10-103, me2pt5-110. -/
def sv10_103 : Card := .pokemon
  { name := "Cynthia's Gabite", stage := .stage1, evolvesFrom := some "Cynthia's Gible",
    hp := 10, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Champion's Call", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .deck .hand (.and .pokemon (.namePrefix "Cynthia's ")) (.upTo 1)) .shuffle) }],
    attacks := [
      { name := "Dragonslice", cost := [.fighting], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Cynthia's Garchomp ex (sv10-104). Records: sv10-104, sv10-215, sv10-232, sv10-241, me2pt5-111. -/
def sv10_104 : Card := .pokemon
  { name := "Cynthia's Garchomp ex", stage := .stage2, evolvesFrom := some "Cynthia's Gabite",
    hp := 33, type := .fighting, retreat := 0, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Corkscrew Dive", cost := [.fighting], damage := 10,
        effect := .choice (.drawTo .own 6) .skip,
        gx := false },
      { name := "Draconic Buster", cost := [.fighting, .fighting], damage := 26,
        effect := .discardEnergy .own .active .energy .all,
        gx := false }] }

/-- Hippopotas (sv10-105). Records: sv10-105. -/
def sv10_105 : Card := .pokemon
  { name := "Hippopotas", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Push Down", cost := [.fighting], damage := 1,
        effect := .switch .opp,
        gx := false }] }

/-- Mudbray (sv10-107). Records: sv10-107. -/
def sv10_107 : Card := .pokemon
  { name := "Mudbray", stage := .basic, evolvesFrom := none,
    hp := 9, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Running Charge", cost := [.fighting, .colorless], damage := 0,
        effect := .damage (.many (.const 4)),
        gx := false }] }

/-- Mudsdale (sv10-108). Records: sv10-108. Caveats: staticBench. -/
def sv10_108 : Card := .pokemon
  { name := "Mudsdale", stage := .stage1, evolvesFrom := some "Mudbray",
    hp := 15, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Mud Coat", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 3 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Heavy Impact", cost := [.fighting, .fighting, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Arven's Toedscool (sv10-109). Records: sv10-109. Caveats: recoil. -/
def sv10_109 : Card := .pokemon
  { name := "Arven's Toedscool", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slight Intrusion", cost := [.colorless], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Arven's Toedscruel (sv10-110). Records: sv10-110. Caveats: recoil. -/
def sv10_110 : Card := .pokemon
  { name := "Arven's Toedscruel", stage := .stage1, evolvesFrom := some "Arven's Toedscool",
    hp := 14, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
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
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Surprise Attack", cost := [.darkness], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Team Rocket's Nidoqueen (sv10-116). Records: sv10-116. -/
def sv10_116 : Card := .pokemon
  { name := "Team Rocket's Nidoqueen", stage := .stage2, evolvesFrom := some "Team Rocket's Nidorina",
    hp := 17, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Love Impact", cost := [.darkness], damage := 0,
        effect := .ite (.countGe (.bench .own (.and .pokemon (.nameHas "Nidoking"))) 1) (.damage (.const 18)) (.damage (.const 6)),
        gx := false },
      { name := "Mega Kick", cost := [.darkness, .darkness], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Nidoran♂ (sv10-117). Records: sv10-117. -/
def sv10_117 : Card := .pokemon
  { name := "Team Rocket's Nidoran♂", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
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
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Poison Spray", cost := [.darkness], damage := 0,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Team Rocket's Golbat (sv10-121). Records: sv10-121. -/
def sv10_121 : Card := .pokemon
  { name := "Team Rocket's Golbat", stage := .stage1, evolvesFrom := some "Team Rocket's Zubat",
    hp := 8, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Sneaky Bite", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 2) (.benchCounters .opp 2)) (.counters 2)) }],
    attacks := [
      { name := "Confuse Ray", cost := [.darkness], damage := 3,
        effect := .inflict .confused,
        gx := false }] }

/-- Team Rocket's Muk (sv10-124). Records: sv10-124. Caveats: perPokemon. -/
def sv10_124 : Card := .pokemon
  { name := "Team Rocket's Muk", stage := .stage1, evolvesFrom := some "Team Rocket's Grimer",
    hp := 15, type := .darkness, retreat := 4, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gooped Up", cost := [.darkness, .colorless], damage := 4,
        effect := .seq (.inflict .confused) (.linger .opp .next (.lock .retreat)),
        gx := false },
      { name := "Hazardous Venom", cost := [.darkness, .darkness, .colorless], damage := 0,
        effect := .damage (.count (.conds .opp) 10),
        gx := false }] }

/-- Team Rocket's Koffing (sv10-125). Records: sv10-125. Caveats: trigDamaged, upTo0. -/
def sv10_125 : Card := .pokemon
  { name := "Team Rocket's Koffing", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Smog Signals", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.seq (.seq (.putBench .own .deck (.and .pokemon (.nameHas "Koffing"))) (.putBench .own .deck (.and .pokemon (.nameHas "Koffing")))) .shuffle) }],
    attacks := [
      { name := "Leaking Gas", cost := [.darkness, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Team Rocket's Weezing (sv10-126). Records: sv10-126, sv10-199. -/
def sv10_126 : Card := .pokemon
  { name := "Team Rocket's Weezing", stage := .stage1, evolvesFrom := some "Team Rocket's Koffing",
    hp := 13, type := .darkness, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Explode Together Now", cost := [.darkness, .colorless], damage := 0,
        effect := .damage (.add (.count (.inPlay .own (.and .pokemon (.or (.nameHas "Koffing") (.nameHas "Weezing")))) 4) (.count (.inPlay .opp (.and .pokemon (.or (.nameHas "Koffing") (.nameHas "Weezing")))) 4)),
        gx := false }] }

/-- Marnie's Purrloin (sv10-130). Records: sv10-130. -/
def sv10_130 : Card := .pokemon
  { name := "Marnie's Purrloin", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pointy Nails", cost := [.darkness], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 6)) (.damage (.const 2)),
        gx := false }] }

/-- Marnie's Liepard (sv10-131). Records: sv10-131. -/
def sv10_131 : Card := .pokemon
  { name := "Marnie's Liepard", stage := .stage1, evolvesFrom := some "Marnie's Purrloin",
    hp := 10, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Pointy Claws", cost := [.darkness, .darkness], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 14)) (.damage (.const 7)),
        gx := false }] }

/-- Marnie's Scraggy (sv10-132). Records: sv10-132. -/
def sv10_132 : Card := .pokemon
  { name := "Marnie's Scraggy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Crunch", cost := [.darkness, .darkness, .colorless], damage := 5,
        effect := .ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Marnie's Scrafty (sv10-133). Records: sv10-133. Caveats: recoil. -/
def sv10_133 : Card := .pokemon
  { name := "Marnie's Scrafty", stage := .stage1, evolvesFrom := some "Marnie's Scraggy",
    hp := 12, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Corkscrew Punch", cost := [.darkness, .darkness], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Marnie's Morpeko (sv10-137). Records: sv10-137. -/
def sv10_137 : Card := .pokemon
  { name := "Marnie's Morpeko", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 0, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Spiky Wheel", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 2) (.count (.energy .own (.energyOf .darkness)) 4)),
        gx := false }] }

/-- Arven's Maschiff (sv10-138). Records: sv10-138. -/
def sv10_138 : Card := .pokemon
  { name := "Arven's Maschiff", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stampede", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Confront", cost := [.colorless, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Arven's Mabosstiff ex (sv10-139). Records: sv10-139, sv10-218, sv10-235. -/
def sv10_139 : Card := .pokemon
  { name := "Arven's Mabosstiff ex", stage := .stage1, evolvesFrom := some "Arven's Maschiff",
    hp := 27, type := .darkness, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Vigorous Tackle", cost := [.colorless], damage := 0,
        effect := .ite (.atLeast .own 1) (.damage (.const 3)) (.damage (.const 15)),
        gx := false },
      { name := "Boss Headbutt", cost := [.colorless, .colorless, .colorless], damage := 21,
        effect := .skip,
        gx := false, selfLock := .this }] }

/-- Skarmory (sv10-141). Records: sv10-141. Caveats: perPokemon. -/
def sv10_141 : Card := .pokemon
  { name := "Skarmory", stage := .basic, evolvesFrom := none,
    hp := 11, type := .metal, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Roost", cost := [.colorless], damage := 0,
        effect := .seq (.heal 5) (.linger .own .after (.lock .retreat)),
        gx := false },
      { name := "Metal Claw", cost := [.metal, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Steven's Skarmory (sv10-142). Records: sv10-142. Caveats: benchMods. -/
def sv10_142 : Card := .pokemon
  { name := "Steven's Skarmory", stage := .basic, evolvesFrom := none,
    hp := 12, type := .metal, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Razor Wing", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Sonic Double", cost := [.metal, .metal, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .any) 2) (.choice (.seq (.damage (.const 5)) (.benchSome .opp 1 .any true 5)) (.benchSome .opp 2 .any true 5)) (.seq (.damage (.const 5)) (.benchSome .opp 1 .any true 5)),
        gx := false }] }

/-- Steven's Beldum (sv10-143). Records: sv10-143. -/
def sv10_143 : Card := .pokemon
  { name := "Steven's Beldum", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.metal, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Steven's Metang (sv10-144). Records: sv10-144. -/
def sv10_144 : Card := .pokemon
  { name := "Steven's Metang", stage := .stage1, evolvesFrom := some "Steven's Beldum",
    hp := 10, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Metal Slash", cost := [.metal, .colorless], damage := 7,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Team Rocket's Rattata (sv10-147). Records: sv10-147. -/
def sv10_147 : Card := .pokemon
  { name := "Team Rocket's Rattata", stage := .basic, evolvesFrom := none,
    hp := 5, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dangerous Incisors", cost := [.colorless], damage := 1,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Team Rocket's Raticate (sv10-148). Records: sv10-148, sv10-202. Caveats: recoil. -/
def sv10_148 : Card := .pokemon
  { name := "Team Rocket's Raticate", stage := .stage1, evolvesFrom := some "Team Rocket's Rattata",
    hp := 9, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reckless Abandon", cost := [.colorless], damage := 9,
        effect := .choice (.selfDamage 9) .skip,
        gx := false }] }

/-- Team Rocket's Meowth (sv10-149). Records: sv10-149, sv10-203, me2pt5-161. -/
def sv10_149 : Card := .pokemon
  { name := "Team Rocket's Meowth", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Paw-cket Pilfer", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .shuffle .any (.exactly 1)) .skip,
        gx := false },
      { name := "Fury Swipes", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 2)) (.choice (.damage (.const 4)) (.damage (.const 6)))),
        gx := false }] }

/-- Kangaskhan (sv10-151). Records: sv10-151, sv10-204. -/
def sv10_151 : Card := .pokemon
  { name := "Kangaskhan", stage := .basic, evolvesFrom := none,
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Dizzy Punch", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 9)) (.damage (.const 18))),
        gx := false }] }

/-- Tauros (sv10-152). Records: sv10-152. -/
def sv10_152 : Card := .pokemon
  { name := "Tauros", stage := .basic, evolvesFrom := none,
    hp := 13, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Horn Attack", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Clean Hit", cost := [.colorless, .colorless], damage := 0,
        effect := .ite (.top .opp (.not .basic)) (.damage (.const 10)) (.damage (.const 5)),
        gx := false }] }

/-- Team Rocket's Porygon (sv10-153). Records: sv10-153. -/
def sv10_153 : Card := .pokemon
  { name := "Team Rocket's Porygon", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hacking", cost := [.colorless], damage := 0,
        effect := .ifDone (.countGe (.pile .own .hand .any) 1) (.move .own .hand .discard .any (.exactly 1)) (.ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip),
        gx := false }] }

/-- Team Rocket's Porygon2 (sv10-154). Records: sv10-154. -/
def sv10_154 : Card := .pokemon
  { name := "Team Rocket's Porygon2", stage := .stage1, evolvesFrom := some "Team Rocket's Porygon",
    hp := 9, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "R Command", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.count (.pile .own .discard (.and (.kind .supporter) (.nameHas "Team Rocket"))) 2),
        gx := false }] }

/-- Team Rocket's Porygon-Z (sv10-155). Records: sv10-155. -/
def sv10_155 : Card := .pokemon
  { name := "Team Rocket's Porygon-Z", stage := .stage2, evolvesFrom := some "Team Rocket's Porygon2",
    hp := 14, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Reconstitute", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .hand .discard .any (.exactly 2)) (.move .own (.top 1) .hand .any .all)) }],
    attacks := [
      { name := "R Command", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.pile .own .discard (.and (.kind .supporter) (.nameHas "Team Rocket"))) 2),
        gx := false }] }

/-- Taillow (sv10-156). Records: sv10-156. -/
def sv10_156 : Card := .pokemon
  { name := "Taillow", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wing Attack", cost := [.colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Swellow (sv10-157). Records: sv10-157. -/
def sv10_157 : Card := .pokemon
  { name := "Swellow", stage := .stage1, evolvesFrom := some "Taillow",
    hp := 10, type := .colorless, retreat := 0, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Add On", cost := [.colorless], damage := 0,
        effect := .move .own (.top 3) .hand .any .all,
        gx := false },
      { name := "Speed Wing", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Arven's Skwovet (sv10-158). Records: sv10-158. -/
def sv10_158 : Card := .pokemon
  { name := "Arven's Skwovet", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gnaw Through", cost := [.colorless], damage := 0,
        effect := .seq (.discardTools .opp .active) (.damage (.const 1)),
        gx := false }] }

/-- Arven's Greedent (sv10-159). Records: sv10-159, sv10-205. Caveats: upTo0. -/
def sv10_159 : Card := .pokemon
  { name := "Arven's Greedent", stage := .stage1, evolvesFrom := some "Arven's Skwovet",
    hp := 12, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Greedy Order", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.move .own .discard .hand (.named "Arven's Sandwich") (.upTo 2)) }],
    attacks := [
      { name := "Rolling Tackle", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Squawkabilly (sv10-160). Records: sv10-160. -/
def sv10_160 : Card := .pokemon
  { name := "Squawkabilly", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Push Down", cost := [.colorless], damage := 2,
        effect := .choice (.switch .opp) .skip,
        gx := false }] }

/-- Cynthia's Power Weight (sv10-162). Records: sv10-162. -/
def sv10_162 : Card := .tool "Cynthia's Power Weight"
  { holder := .and .pokemon (.namePrefix "Cynthia's "),
    attacks := [],
    abilities := [],
    statics := [
      { sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .hpPlus (.const 7) }] }

/-- Energy Recycler (sv10-164). Records: sv10-164, me3-108. Caveats: upTo0. -/
def sv10_164 : Card := .trainer "Energy Recycler" .item
    (.move .own .discard .shuffle .energy (.upTo 5))

/-- Ethan's Adventure (sv10-165). Records: sv10-165, sv10-221, sv10-236. Caveats: upTo0. -/
def sv10_165 : Card := .trainer "Ethan's Adventure" .supporter
    (.seq (.move .own .deck .hand (.or (.and .pokemon (.namePrefix "Ethan's ")) (.energyOf .fire)) (.upTo 3)) .shuffle)

/-- Granite Cave (sv10-166). Records: sv10-166. Caveats: staticBench. -/
def sv10_166 : Card := .trainer "Granite Cave" .stadium
    .skip [
      { sel := .all, filt := .and .pokemon (.namePrefix "Steven's "), tgt := none, src := none, need := none, eff := .reduce 3 .any }]

/-- Sacred Ash (sv10-168). Records: sv10-168, me3-115. Caveats: upTo0. -/
def sv10_168 : Card := .trainer "Sacred Ash" .item
    (.move .own .discard .shuffle .pokemon (.upTo 5))

/-- Spikemuth Gym (sv10-169). Records: sv10-169. -/
def sv10_169 : Card := .trainer "Spikemuth Gym" .stadium
    (.seq (.move .own .deck .hand (.and .pokemon (.namePrefix "Marnie's ")) (.upTo 1)) .shuffle)

/-- Team Rocket's Great Ball (sv10-175). Records: sv10-175, me2pt5-205. -/
def sv10_175 : Card := .trainer "Team Rocket's Great Ball" .item
    (.seq (.choice (.move .own .deck .hand (.and (.and .pokemon (.not .basic)) (.namePrefix "Team Rocket's ")) (.upTo 1)) (.move .own .deck .hand (.and .basic (.namePrefix "Team Rocket's ")) (.upTo 1))) .shuffle)

/-- Team Rocket's Petrel (sv10-176). Records: sv10-176, sv10-226, me2pt5-207. -/
def sv10_176 : Card := .trainer "Team Rocket's Petrel" .supporter
    (.seq (.move .own .deck .hand .trainer (.upTo 1)) .shuffle)

/-- Team Rocket's Transceiver (sv10-178). Records: sv10-178, me2pt5-209, me2pt5-263. -/
def sv10_178 : Card := .trainer "Team Rocket's Transceiver" .item
    (.seq (.move .own .deck .hand (.and (.kind .supporter) (.nameHas "Team Rocket")) (.upTo 1)) .shuffle)

/-- Team Rocket's Venture Bomb (sv10-179). Records: sv10-179. -/
def sv10_179 : Card := .trainer "Team Rocket's Venture Bomb" .item
    (.choice (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 2) (.benchCounters .opp 2)) (.counters 2)) (.selfDamage 2))

/-- TM Machine (sv10-181). Records: sv10-181. Caveats: upTo0. -/
def sv10_181 : Card := .trainer "TM Machine" .item
    (.seq (.move .own .deck .hand (.and .tool (.nameHas "Technical Machine")) (.upTo 3)) .shuffle)

/-- Sewaddle (rsv10pt5-1). Records: rsv10pt5-1, rsv10pt5-87. -/
def rsv10pt5_1 : Card := .pokemon
  { name := "Sewaddle", stage := .basic, evolvesFrom := none,
    hp := 5, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bug Bite", cost := [.grass], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Swadloon (rsv10pt5-2). Records: rsv10pt5-2, rsv10pt5-88. Caveats: noopUse. -/
def rsv10pt5_2 : Card := .pokemon
  { name := "Swadloon", stage := .stage1, evolvesFrom := some "Sewaddle",
    hp := 8, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Healing Leaves", use := .once,
        spot := none, cond := none,
        effect := .fx (.heal 2) }],
    attacks := [
      { name := "Bug Buzz", cost := [.grass, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Cottonee (rsv10pt5-4). Records: rsv10pt5-4, rsv10pt5-90. -/
def rsv10pt5_4 : Card := .pokemon
  { name := "Cottonee", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Absorb", cost := [.grass], damage := 1,
        effect := .heal 1,
        gx := false }] }

/-- Deerling (rsv10pt5-6). Records: rsv10pt5-6, rsv10pt5-91. -/
def rsv10pt5_6 : Card := .pokemon
  { name := "Deerling", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rear Kick", cost := [.colorless, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Sawsbuck (rsv10pt5-7). Records: rsv10pt5-7, rsv10pt5-92. -/
def rsv10pt5_7 : Card := .pokemon
  { name := "Sawsbuck", stage := .stage1, evolvesFrom := some "Deerling",
    hp := 13, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Acid Spray", cost := [.grass], damage := 5,
        effect := .choice (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip) .skip,
        gx := false }] }

/-- Virizion (rsv10pt5-10). Records: rsv10pt5-10, rsv10pt5-95. -/
def rsv10pt5_10 : Card := .pokemon
  { name := "Virizion", stage := .basic, evolvesFrom := none,
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Giga Drain", cost := [.grass], damage := 0,
        effect := .drain (.const 3),
        gx := false },
      { name := "Emerald Blade", cost := [.grass, .grass, .colorless], damage := 13,
        effect := .skip,
        gx := false, selfLock := .all }] }

/-- Tepig (rsv10pt5-11). Records: rsv10pt5-11, rsv10pt5-96. -/
def rsv10pt5_11 : Card := .pokemon
  { name := "Tepig", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Combustion", cost := [.fire], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Heat Crash", cost := [.fire, .fire, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Emboar (rsv10pt5-13). Records: rsv10pt5-13, rsv10pt5-98. Caveats: mayFail. -/
def rsv10pt5_13 : Card := .pokemon
  { name := "Emboar", stage := .stage2, evolvesFrom := some "Pignite",
    hp := 18, type := .fire, retreat := 4, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Inferno Fandango", use := .unlimited,
        spot := none, cond := none,
        effect := .fx (.choice (.attach .own .hand (.energyOf .fire) .active .any) (.attach .own .hand (.energyOf .fire) .bench .any)) }],
    attacks := [
      { name := "Heat Crash", cost := [.fire, .fire, .fire, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Pansear (rsv10pt5-14). Records: rsv10pt5-14, rsv10pt5-99. -/
def rsv10pt5_14 : Card := .pokemon
  { name := "Pansear", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Litwick (rsv10pt5-16). Records: rsv10pt5-16, rsv10pt5-101. -/
def rsv10pt5_16 : Card := .pokemon
  { name := "Litwick", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Brighten and Burn", cost := [.fire], damage := 0,
        effect := .choice (.move .own (.top 1) .discard .any .all) .skip,
        gx := false }] }

/-- Lampent (rsv10pt5-17). Records: rsv10pt5-17, rsv10pt5-102. -/
def rsv10pt5_17 : Card := .pokemon
  { name := "Lampent", stage := .stage1, evolvesFrom := some "Litwick",
    hp := 8, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fire Blast", cost := [.fire], damage := 5,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Chandelure (rsv10pt5-18). Records: rsv10pt5-18, rsv10pt5-103. -/
def rsv10pt5_18 : Card := .pokemon
  { name := "Chandelure", stage := .stage2, evolvesFrom := some "Lampent",
    hp := 15, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Licking Catch", cost := [.fire], damage := 0,
        effect := .seq (.move .own .deck .hand (.or (.ptype .fire) (.energyOf .fire)) (.upTo 3)) .shuffle,
        gx := false },
      { name := "Fire Claws", cost := [.fire, .fire], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Reshiram ex (rsv10pt5-20). Records: rsv10pt5-20, rsv10pt5-158, rsv10pt5-166, rsv10pt5-173. Caveats: prizes6. -/
def rsv10pt5_20 : Card := .pokemon
  { name := "Reshiram ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Blazing Burst", cost := [.fire, .fire, .colorless], damage := 0,
        effect := .seq (.damage (.add (.const 13) (.count (.prizesTaken .opp) 5))) (.ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip),
        gx := false }] }

/-- Oshawott (rsv10pt5-21). Records: rsv10pt5-21, rsv10pt5-105. -/
def rsv10pt5_21 : Card := .pokemon
  { name := "Oshawott", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Energized Shell", cost := [.water], damage := 0,
        effect := .damage (.count (.energy .own .energy) 3),
        gx := false }] }

/-- Samurott (rsv10pt5-23). Records: rsv10pt5-23, rsv10pt5-107. Caveats: noopUse. -/
def rsv10pt5_23 : Card := .pokemon
  { name := "Samurott", stage := .stage2, evolvesFrom := some "Dewott",
    hp := 16, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Torrential Whirlpool", use := .once,
        spot := none, cond := none,
        effect := .fx (.ite (.countGe (.bench .own .pokemon) 1) (.seq (.switch .own) (.switch .opp)) .skip) }],
    attacks := [
      { name := "Energized Slash", cost := [.water], damage := 0,
        effect := .damage (.add (.const 3) (.count (.energy .own .energy) 5)),
        gx := false }] }

/-- Ducklett (rsv10pt5-25). Records: rsv10pt5-25, rsv10pt5-109. -/
def rsv10pt5_25 : Card := .pokemon
  { name := "Ducklett", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Firefighting", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.energy .opp (.energyOf .fire)) 1) (.discardEnergy .opp .active (.energyOf .fire) (.exactly 1)) .skip,
        gx := false },
      { name := "Wing Attack", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  sv9_136,
  sv9_137,
  sv9_139,
  sv9_140,
  sv9_141,
  sv9_146,
  sv9_147,
  sv9_149,
  sv9_150,
  sv9_154,
  sv10_2,
  sv10_4,
  sv10_5,
  sv10_6,
  sv10_7,
  sv10_8,
  sv10_9,
  sv10_12,
  sv10_13,
  sv10_14,
  sv10_16,
  sv10_19,
  sv10_20,
  sv10_21,
  sv10_22,
  sv10_26,
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
  sv10_43,
  sv10_44,
  sv10_46,
  sv10_47,
  sv10_50,
  sv10_53,
  sv10_54,
  sv10_57,
  sv10_58,
  sv10_59,
  sv10_60,
  sv10_62,
  sv10_64,
  sv10_67,
  sv10_68,
  sv10_69,
  sv10_71,
  sv10_72,
  sv10_73,
  sv10_75,
  sv10_76,
  sv10_77,
  sv10_78,
  sv10_79,
  sv10_83,
  sv10_84,
  sv10_85,
  sv10_90,
  sv10_91,
  sv10_94,
  sv10_97,
  sv10_99,
  sv10_101,
  sv10_102,
  sv10_103,
  sv10_104,
  sv10_105,
  sv10_107,
  sv10_108,
  sv10_109,
  sv10_110,
  sv10_111,
  sv10_112,
  sv10_114,
  sv10_116,
  sv10_117,
  sv10_118,
  sv10_119,
  sv10_120,
  sv10_121,
  sv10_124,
  sv10_125,
  sv10_126,
  sv10_130,
  sv10_131,
  sv10_132,
  sv10_133,
  sv10_134,
  sv10_135,
  sv10_137,
  sv10_138,
  sv10_139,
  sv10_141,
  sv10_142,
  sv10_143,
  sv10_144,
  sv10_147,
  sv10_148,
  sv10_149,
  sv10_151,
  sv10_152,
  sv10_153,
  sv10_154,
  sv10_155,
  sv10_156,
  sv10_157,
  sv10_158,
  sv10_159,
  sv10_160,
  sv10_162,
  sv10_164,
  sv10_165,
  sv10_166,
  sv10_168,
  sv10_169,
  sv10_175,
  sv10_176,
  sv10_178,
  sv10_179,
  sv10_181,
  rsv10pt5_1,
  rsv10pt5_2,
  rsv10pt5_4,
  rsv10pt5_6,
  rsv10pt5_7,
  rsv10pt5_9,
  rsv10pt5_10,
  rsv10pt5_11,
  rsv10pt5_12,
  rsv10pt5_13,
  rsv10pt5_14,
  rsv10pt5_15,
  rsv10pt5_16,
  rsv10pt5_17,
  rsv10pt5_18,
  rsv10pt5_19,
  rsv10pt5_20,
  rsv10pt5_21,
  rsv10pt5_22,
  rsv10pt5_23,
  rsv10pt5_25]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = ["Cynthia's Power Weight"] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Postwick", "Cynthia's Roserade"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Mudsdale", "Granite Cave"] := by decide +kernel

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
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Team Rocket's Koffing"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Clamperl", "Virizion"] := by decide +kernel

end PokemonCards.Standard.Part05
