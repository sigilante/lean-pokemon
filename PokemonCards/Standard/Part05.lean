/-
Imported Standard cards, part 5 of 8 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.7.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part05
open Pokemon

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

/-- Steven's Metang (sv10-144). Records: sv10-144. Caveats: perPokemon. -/
def sv10_144 : Card := .pokemon
  { name := "Steven's Metang", stage := .stage1, evolvesFrom := some "Steven's Beldum",
    hp := 10, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Metal Slash", cost := [.metal, .colorless], damage := 7,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

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

/-- Virizion (rsv10pt5-10). Records: rsv10pt5-10, rsv10pt5-95. Caveats: perPokemon. -/
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
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

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

/-- Swanna (rsv10pt5-26). Records: rsv10pt5-26, rsv10pt5-110. -/
def rsv10pt5_26 : Card := .pokemon
  { name := "Swanna", stage := .stage1, evolvesFrom := some "Ducklett",
    hp := 12, type := .water, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
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
    abilities := [],
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
    abilities := [],
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
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Surprise Attack", cost := [.lightning], damage := 0,
        effect := .choice (.damage (.const 3)) .skip,
        gx := false }] }

/-- Stunfisk (rsv10pt5-35). Records: rsv10pt5-35, rsv10pt5-118. -/
def rsv10pt5_35 : Card := .pokemon
  { name := "Stunfisk", stage := .basic, evolvesFrom := none,
    hp := 11, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Heart Stamp", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Yamask (rsv10pt5-39). Records: rsv10pt5-39, rsv10pt5-122. -/
def rsv10pt5_39 : Card := .pokemon
  { name := "Yamask", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 2, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Focused Wish", cost := [.psychic, .colorless], damage := 0,
        effect := .choice (.damage (.const 4)) (.damage (.const 2)),
        gx := false }] }

/-- Gothita (rsv10pt5-41). Records: rsv10pt5-41, rsv10pt5-124. -/
def rsv10pt5_41 : Card := .pokemon
  { name := "Gothita", stage := .basic, evolvesFrom := none,
    hp := 7, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Super Psy Bolt", cost := [.psychic], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Frillish (rsv10pt5-44). Records: rsv10pt5-44, rsv10pt5-126. -/
def rsv10pt5_44 : Card := .pokemon
  { name := "Frillish", stage := .basic, evolvesFrom := none,
    hp := 8, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Oceanic Gloom", cost := [.psychic], damage := 2,
        effect := .linger .opp .next (.lock .item),
        gx := false }] }

/-- Archen (rsv10pt5-50). Records: rsv10pt5-50, rsv10pt5-131. -/
def rsv10pt5_50 : Card := .pokemon
  { name := "Archen", stage := .stage1, evolvesFrom := some "Antiuqe Plume Fossil",
    hp := 8, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Acrobatics", cost := [.fighting, .colorless], damage := 0,
        effect := .choice (.damage (.const 3)) (.choice (.damage (.const 6)) (.damage (.const 9))),
        gx := false }] }

/-- Mienfoo (rsv10pt5-52). Records: rsv10pt5-52, rsv10pt5-133. -/
def rsv10pt5_52 : Card := .pokemon
  { name := "Mienfoo", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Kick", cost := [.fighting], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Terrakion (rsv10pt5-54). Records: rsv10pt5-54, rsv10pt5-135. Caveats: koAttackWide. -/
def rsv10pt5_54 : Card := .pokemon
  { name := "Terrakion", stage := .basic, evolvesFrom := none,
    hp := 14, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Retaliate", cost := [.fighting, .colorless], damage := 0,
        effect := .ite (.countGe (.koLast .own true) 1) (.damage (.const 13)) (.damage (.const 5)),
        gx := false },
      { name := "Land Crush", cost := [.fighting, .fighting, .colorless], damage := 10,
        effect := .skip,
        gx := false }] }

/-- Purrloin (rsv10pt5-55). Records: rsv10pt5-55, rsv10pt5-136. -/
def rsv10pt5_55 : Card := .pokemon
  { name := "Purrloin", stage := .basic, evolvesFrom := none,
    hp := 6, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Invite Evil", cost := [.darkness], damage := 0,
        effect := .seq (.move .own .deck .hand (.ptype .darkness) (.upTo 3)) .shuffle,
        gx := false }] }

/-- Liepard (rsv10pt5-56). Records: rsv10pt5-56, rsv10pt5-137. -/
def rsv10pt5_56 : Card := .pokemon
  { name := "Liepard", stage := .stage1, evolvesFrom := some "Purrloin",
    hp := 11, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Knock Off", cost := [.darkness], damage := 5,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Scraggy (rsv10pt5-57). Records: rsv10pt5-57, rsv10pt5-138. -/
def rsv10pt5_57 : Card := .pokemon
  { name := "Scraggy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
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
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Take Down", cost := [.darkness], damage := 3,
        effect := .selfDamage 1,
        gx := false }] }

/-- Vullaby (rsv10pt5-63). Records: rsv10pt5-63, rsv10pt5-144. -/
def rsv10pt5_63 : Card := .pokemon
  { name := "Vullaby", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Playful Kick", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Deino (rsv10pt5-65). Records: rsv10pt5-65, rsv10pt5-146. -/
def rsv10pt5_65 : Card := .pokemon
  { name := "Deino", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
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
    abilities := [],
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
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Play Rough", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 3)) (.damage (.const 1)),
        gx := false }] }

/-- Herdier (rsv10pt5-75). Records: rsv10pt5-75, rsv10pt5-155. -/
def rsv10pt5_75 : Card := .pokemon
  { name := "Herdier", stage := .stage1, evolvesFrom := some "Lillipup",
    hp := 9, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Roar", cost := [.colorless], damage := 0,
        effect := .switch .opp,
        gx := false },
      { name := "Lunge Out", cost := [.colorless, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Bouffalant ex (rsv10pt5-77). Records: rsv10pt5-77, rsv10pt5-162, rsv10pt5-170. Caveats: staticBench. -/
def rsv10pt5_77 : Card := .pokemon
  { name := "Bouffalant ex", stage := .basic, evolvesFrom := none,
    hp := 22, type := .colorless, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Bouffer", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .reduce 3 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Gold Breaker", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 20)) (.damage (.const 10)),
        gx := false }] }

/-- Brave Bangle (rsv10pt5-80). Records: rsv10pt5-80. -/
def rsv10pt5_80 : Card := .tool "Brave Bangle"
  { holder := .pokemon,
    attacks := [],
    abilities := [],
    statics := [
      { sel := .self, filt := .noRuleBox, tgt := none, src := none, need := none, eff := .bonus 3 (.and .pokemon (.not .noRuleBox)) }] }

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
    abilities := [],
    attacks := [
      { name := "V-Force", cost := [.fire, .fire], damage := 0,
        effect := .ite (.countGe (.bench .own .pokemon) 5) (.damage (.const 12)) .skip,
        gx := false }] }

/-- Snivy (zsv10pt5-1). Records: zsv10pt5-1, zsv10pt5-87. -/
def zsv10pt5_1 : Card := .pokemon
  { name := "Snivy", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Wrap", cost := [.grass], damage := 2,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Vine Whip", cost := [.grass, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Serperior ex (zsv10pt5-3). Records: zsv10pt5-3, zsv10pt5-156, zsv10pt5-164. Caveats: searchAny. -/
def zsv10pt5_3 : Card := .pokemon
  { name := "Serperior ex", stage := .stage2, evolvesFrom := some "Servine",
    hp := 32, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Regal Cheer", use := .static [{ sel := .own, filt := .any, tgt := none, src := none, need := none, eff := .bonus 2 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Command the Grass", cost := [.grass, .colorless, .colorless, .colorless], damage := 15,
        effect := .seq (.move .own .deck .hand .any (.upTo 3)) .shuffle,
        gx := false }] }

/-- Pansage (zsv10pt5-4). Records: zsv10pt5-4, zsv10pt5-89. -/
def zsv10pt5_4 : Card := .pokemon
  { name := "Pansage", stage := .basic, evolvesFrom := none,
    hp := 7, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Lilligant (zsv10pt5-7). Records: zsv10pt5-7, zsv10pt5-92. -/
def zsv10pt5_7 : Card := .pokemon
  { name := "Lilligant", stage := .stage1, evolvesFrom := some "Petilil",
    hp := 10, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Toxic Spore", cost := [.colorless], damage := 0,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Amoonguss (zsv10pt5-11). Records: zsv10pt5-11, zsv10pt5-96. -/
def zsv10pt5_11 : Card := .pokemon
  { name := "Amoonguss", stage := .stage1, evolvesFrom := some "Foongus",
    hp := 12, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Will-O-Wisp", cost := [.fire, .colorless], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Darmanitan (zsv10pt5-14). Records: zsv10pt5-14, zsv10pt5-98. -/
def zsv10pt5_14 : Card := .pokemon
  { name := "Darmanitan", stage := .stage1, evolvesFrom := some "Darumaka",
    hp := 14, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Searing Flame", cost := [.fire, .colorless], damage := 5,
        effect := .inflict .burned,
        gx := false },
      { name := "Smashing Headbutt", cost := [.fire, .colorless, .colorless, .colorless], damage := 18,
        effect := .ite (.countGe (.energy .own .energy) 2) (.discardEnergy .own .active .energy (.exactly 2)) (.discardEnergy .own .active .energy .all),
        gx := false }] }

/-- Larvesta (zsv10pt5-15). Records: zsv10pt5-15, zsv10pt5-99. -/
def zsv10pt5_15 : Card := .pokemon
  { name := "Larvesta", stage := .basic, evolvesFrom := none,
    hp := 6, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Peck Off", cost := [.colorless], damage := 0,
        effect := .seq (.discardTools .opp .active) (.damage (.const 1)),
        gx := false }] }

/-- Volcarona (zsv10pt5-16). Records: zsv10pt5-16, zsv10pt5-100. -/
def zsv10pt5_16 : Card := .pokemon
  { name := "Volcarona", stage := .stage1, evolvesFrom := some "Larvesta",
    hp := 12, type := .fire, retreat := 1, weakness := some .water,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Torrid Scales", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .hand .discard (.energyOf .fire) (.exactly 1)) (.inflict .burned)) }],
    attacks := [
      { name := "Fire Wing", cost := [.fire, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Panpour (zsv10pt5-17). Records: zsv10pt5-17, zsv10pt5-101. -/
def zsv10pt5_17 : Card := .pokemon
  { name := "Panpour", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Gentle Slap", cost := [.colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Tympole (zsv10pt5-19). Records: zsv10pt5-19, zsv10pt5-103. -/
def zsv10pt5_19 : Card := .pokemon
  { name := "Tympole", stage := .basic, evolvesFrom := none,
    hp := 6, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Round", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .own (.and .pokemon (.hasAttack "Round"))) 2),
        gx := false }] }

/-- Palpitoad (zsv10pt5-20). Records: zsv10pt5-20, zsv10pt5-104. -/
def zsv10pt5_20 : Card := .pokemon
  { name := "Palpitoad", stage := .stage1, evolvesFrom := some "Tympole",
    hp := 9, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Round", cost := [.colorless, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .own (.and .pokemon (.hasAttack "Round"))) 4),
        gx := false },
      { name := "Wave Splash", cost := [.water, .colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Seismitoad (zsv10pt5-21). Records: zsv10pt5-21, zsv10pt5-105. -/
def zsv10pt5_21 : Card := .pokemon
  { name := "Seismitoad", stage := .stage2, evolvesFrom := some "Palpitoad",
    hp := 17, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Round", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.count (.inPlay .own (.and .pokemon (.hasAttack "Round"))) 7),
        gx := false },
      { name := "Hyper Voice", cost := [.water, .colorless, .colorless, .colorless], damage := 16,
        effect := .skip,
        gx := false }] }

/-- Tirtouga (zsv10pt5-22). Records: zsv10pt5-22, zsv10pt5-106. -/
def zsv10pt5_22 : Card := .pokemon
  { name := "Tirtouga", stage := .stage1, evolvesFrom := some "Antique Cover Fossil",
    hp := 10, type := .water, retreat := 3, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ancient Seaweed", cost := [.water], damage := 0,
        effect := .damage (.count (.pile .opp .discard (.kind .item)) 3),
        gx := false },
      { name := "Surf", cost := [.water, .colorless, .colorless], damage := 8,
        effect := .skip,
        gx := false }] }

/-- Alomomola (zsv10pt5-24). Records: zsv10pt5-24, zsv10pt5-108. Caveats: mayFail. -/
def zsv10pt5_24 : Card := .pokemon
  { name := "Alomomola", stage := .basic, evolvesFrom := none,
    hp := 11, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Gentle Fin", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.putBench .own .discard (.and .basic (.hpLe 7))) }],
    attacks := [
      { name := "Waterfall", cost := [.water, .colorless, .colorless], damage := 7,
        effect := .skip,
        gx := false }] }

/-- Cubchoo (zsv10pt5-25). Records: zsv10pt5-25, zsv10pt5-109. Caveats: perPokemon. -/
def zsv10pt5_25 : Card := .pokemon
  { name := "Cubchoo", stage := .basic, evolvesFrom := none,
    hp := 7, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Snotted Up", cost := [.water], damage := 1,
        effect := .linger .opp .next (.lock .attack),
        gx := false }] }

/-- Beartic (zsv10pt5-26). Records: zsv10pt5-26, zsv10pt5-110. Caveats: perPokemon. -/
def zsv10pt5_26 : Card := .pokemon
  { name := "Beartic", stage := .stage1, evolvesFrom := some "Cubchoo",
    hp := 15, type := .water, retreat := 3, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
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
    abilities := [],
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
    abilities := [],
    attacks := [
      { name := "Hold Still", cost := [.colorless], damage := 0,
        effect := .heal 1,
        gx := false }] }

/-- Eelektrik (zsv10pt5-31). Records: zsv10pt5-31, zsv10pt5-114, me2pt5-60. Caveats: mayFail. -/
def zsv10pt5_31 : Card := .pokemon
  { name := "Eelektrik", stage := .stage1, evolvesFrom := some "Tynamo",
    hp := 9, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Dynamotor", use := .once,
        spot := none, cond := none,
        effect := .fx (.attach .own .discard (.energyOf .lightning) .bench .any) }],
    attacks := [
      { name := "Electric Ball", cost := [.lightning, .lightning, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Eelektross (zsv10pt5-32). Records: zsv10pt5-32, zsv10pt5-115. -/
def zsv10pt5_32 : Card := .pokemon
  { name := "Eelektross", stage := .stage2, evolvesFrom := some "Eelektrik",
    hp := 16, type := .lightning, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Thunder Fang", cost := [.lightning], damage := 6,
        effect := .choice (.inflict .paralyzed) .skip,
        gx := false },
      { name := "Buzz Flip", cost := [.lightning, .lightning, .lightning, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 10)) (.choice (.damage (.const 20)) (.choice (.damage (.const 30)) (.damage (.const 40))))),
        gx := false }] }

/-- Thundurus (zsv10pt5-33). Records: zsv10pt5-33. -/
def zsv10pt5_33 : Card := .pokemon
  { name := "Thundurus", stage := .basic, evolvesFrom := none,
    hp := 12, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Charge", cost := [.colorless], damage := 0,
        effect := .seq (.attach .own .deck (.energyOf .lightning) .active .any) .shuffle,
        gx := false },
      { name := "Disaster Volt", cost := [.lightning, .colorless, .colorless], damage := 11,
        effect := .ite (.countGe (.energy .own .energy) 1) (.discardEnergy .own .active .energy (.exactly 1)) .skip,
        gx := false }] }

/-- Solosis (zsv10pt5-37). Records: zsv10pt5-37, zsv10pt5-118. -/
def zsv10pt5_37 : Card := .pokemon
  { name := "Solosis", stage := .basic, evolvesFrom := none,
    hp := 4, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Rollout", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Beheeyem (zsv10pt5-41). Records: zsv10pt5-41, zsv10pt5-121. -/
def zsv10pt5_41 : Card := .pokemon
  { name := "Beheeyem", stage := .stage1, evolvesFrom := some "Elgyem",
    hp := 9, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Calm Mind", cost := [.psychic], damage := 0,
        effect := .heal 4,
        gx := false },
      { name := "Psychic", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 8) (.count (.energy .opp .energy) 3)),
        gx := false }] }

/-- Golett (zsv10pt5-42). Records: zsv10pt5-42, zsv10pt5-122. -/
def zsv10pt5_42 : Card := .pokemon
  { name := "Golett", stage := .basic, evolvesFrom := none,
    hp := 9, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Best Punch", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 6)) .skip,
        gx := false }] }

/-- Golurk (zsv10pt5-43). Records: zsv10pt5-43, zsv10pt5-123. -/
def zsv10pt5_43 : Card := .pokemon
  { name := "Golurk", stage := .stage1, evolvesFrom := some "Golett",
    hp := 16, type := .psychic, retreat := 4, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Double Smash", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 8)) (.damage (.const 16))),
        gx := false },
      { name := "Golurk Hammer", cost := [.psychic, .psychic, .colorless, .colorless, .colorless], damage := 20,
        effect := .skip,
        gx := false }] }

/-- Drilbur (zsv10pt5-45). Records: zsv10pt5-45, zsv10pt5-124. -/
def zsv10pt5_45 : Card := .pokemon
  { name := "Drilbur", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Mud-Slap", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Corkscrew Punch", cost := [.fighting, .fighting], damage := 3,
        effect := .skip,
        gx := false }] }

/-- Timburr (zsv10pt5-47). Records: zsv10pt5-47, zsv10pt5-125. -/
def zsv10pt5_47 : Card := .pokemon
  { name := "Timburr", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Low Kick", cost := [.fighting], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Strength", cost := [.fighting, .colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Gurdurr (zsv10pt5-48). Records: zsv10pt5-48, zsv10pt5-126. -/
def zsv10pt5_48 : Card := .pokemon
  { name := "Gurdurr", stage := .stage1, evolvesFrom := some "Timburr",
    hp := 10, type := .fighting, retreat := 3, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Low Kick", cost := [.fighting], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Hammer Arm", cost := [.fighting, .colorless, .colorless], damage := 6,
        effect := .move .opp (.top 1) .discard .any .all,
        gx := false }] }

/-- Conkeldurr (zsv10pt5-49). Records: zsv10pt5-49, zsv10pt5-127. -/
def zsv10pt5_49 : Card := .pokemon
  { name := "Conkeldurr", stage := .stage2, evolvesFrom := some "Gurdurr",
    hp := 14, type := .fighting, retreat := 3, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Craftsmanship", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .hpPlus (.perEnergy (.energyOf .fighting) 4) }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Swing Around", cost := [.fighting, .colorless, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 10)) (.choice (.damage (.const 15)) (.damage (.const 20))),
        gx := false }] }

/-- Dwebble (zsv10pt5-51). Records: zsv10pt5-51, zsv10pt5-129. -/
def zsv10pt5_51 : Card := .pokemon
  { name := "Dwebble", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Flail", cost := [.colorless], damage := 0,
        effect := .damage (.per .own 1),
        gx := false },
      { name := "Dig Claws", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Landorus (zsv10pt5-53). Records: zsv10pt5-53, zsv10pt5-131. Caveats: benchMods, mayFail. -/
def zsv10pt5_53 : Card := .pokemon
  { name := "Landorus", stage := .basic, evolvesFrom := none,
    hp := 13, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Abundant Harvest", cost := [.colorless], damage := 0,
        effect := .attach .own .discard (.energyOf .fighting) .active .any,
        gx := false },
      { name := "Earthquake", cost := [.fighting, .colorless, .colorless], damage := 11,
        effect := .spreadDamage .own 1,
        gx := false }] }

/-- Venipede (zsv10pt5-54). Records: zsv10pt5-54, zsv10pt5-132. -/
def zsv10pt5_54 : Card := .pokemon
  { name := "Venipede", stage := .basic, evolvesFrom := none,
    hp := 8, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Poison Spray", cost := [.colorless], damage := 0,
        effect := .inflict .poisoned,
        gx := false }] }

/-- Whirlipede (zsv10pt5-55). Records: zsv10pt5-55, zsv10pt5-133. -/
def zsv10pt5_55 : Card := .pokemon
  { name := "Whirlipede", stage := .stage1, evolvesFrom := some "Venipede",
    hp := 10, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Venoshock", cost := [.colorless], damage := 0,
        effect := .ite (.cond .opp .poisoned) (.damage (.const 9)) (.damage (.const 3)),
        gx := false }] }

/-- Scolipede (zsv10pt5-56). Records: zsv10pt5-56, zsv10pt5-134. Caveats: trigAttacker, trigDamaged. -/
def zsv10pt5_56 : Card := .pokemon
  { name := "Scolipede", stage := .stage2, evolvesFrom := some "Whirlipede",
    hp := 16, type := .darkness, retreat := 3, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Poison Point", use := .triggered .damaged false,
        spot := some .active, cond := none,
        effect := .fx (.inflict .poisoned) }],
    attacks := [
      { name := "Venoshock", cost := [.darkness, .colorless], damage := 0,
        effect := .ite (.cond .opp .poisoned) (.damage (.const 18)) (.damage (.const 9)),
        gx := false }] }

/-- Sandile (zsv10pt5-57). Records: zsv10pt5-57, zsv10pt5-135. -/
def zsv10pt5_57 : Card := .pokemon
  { name := "Sandile", stage := .basic, evolvesFrom := none,
    hp := 7, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tighten Up", cost := [.darkness], damage := 1,
        effect := .ite (.countGe (.pile .opp .hand .any) 1) (.move .opp .hand .discard .any (.exactly 1)) .skip,
        gx := false }] }

/-- Krokorok (zsv10pt5-58). Records: zsv10pt5-58, zsv10pt5-136. -/
def zsv10pt5_58 : Card := .pokemon
  { name := "Krokorok", stage := .stage1, evolvesFrom := some "Sandile",
    hp := 10, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tighten Up", cost := [.darkness, .colorless], damage := 4,
        effect := .ite (.countGe (.pile .opp .hand .any) 2) (.move .opp .hand .discard .any (.exactly 2)) (.move .opp .hand .discard .any .all),
        gx := false }] }

/-- Krookodile (zsv10pt5-59). Records: zsv10pt5-59, zsv10pt5-137. -/
def zsv10pt5_59 : Card := .pokemon
  { name := "Krookodile", stage := .stage2, evolvesFrom := some "Krokorok",
    hp := 17, type := .darkness, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tighten Up", cost := [.darkness, .colorless], damage := 6,
        effect := .ite (.countGe (.pile .opp .hand .any) 2) (.move .opp .hand .discard .any (.exactly 2)) (.move .opp .hand .discard .any .all),
        gx := false },
      { name := "Cursed Slug", cost := [.darkness, .darkness, .colorless], damage := 0,
        effect := .ite (.countGe (.pile .opp .hand .any) 4) (.damage (.const 12)) (.damage (.const 24)),
        gx := false }] }

/-- Escavalier (zsv10pt5-60). Records: zsv10pt5-60, zsv10pt5-138. Caveats: recoil. -/
def zsv10pt5_60 : Card := .pokemon
  { name := "Escavalier", stage := .stage1, evolvesFrom := some "Karrablast",
    hp := 13, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wild Lances", cost := [.metal], damage := 9,
        effect := .selfDamage 3,
        gx := false }] }

/-- Klink (zsv10pt5-61). Records: zsv10pt5-61, zsv10pt5-139. Caveats: perPokemon. -/
def zsv10pt5_61 : Card := .pokemon
  { name := "Klink", stage := .basic, evolvesFrom := none,
    hp := 6, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hard Gears", cost := [.metal], damage := 1,
        effect := .linger .own .next (.reduce 1),
        gx := false }] }

/-- Klang (zsv10pt5-62). Records: zsv10pt5-62, zsv10pt5-140. Caveats: perPokemon. -/
def zsv10pt5_62 : Card := .pokemon
  { name := "Klang", stage := .stage1, evolvesFrom := some "Klink",
    hp := 9, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Hard Gears", cost := [.metal, .colorless], damage := 5,
        effect := .linger .own .next (.reduce 2),
        gx := false }] }

/-- Klinklang (zsv10pt5-63). Records: zsv10pt5-63, zsv10pt5-141. Caveats: staticBench. -/
def zsv10pt5_63 : Card := .pokemon
  { name := "Klinklang", stage := .stage2, evolvesFrom := some "Klang",
    hp := 15, type := .metal, retreat := 3, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Gear Coating", use := .static [{ sel := .own, filt := .any, tgt := none, src := none, need := some (.energyOf .metal, 1), eff := .reduce 2 .any }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Hammer In", cost := [.metal, .colorless, .colorless], damage := 12,
        effect := .skip,
        gx := false }] }

/-- Pawniard (zsv10pt5-64). Records: zsv10pt5-64, zsv10pt5-142. Caveats: perPokemon. -/
def zsv10pt5_64 : Card := .pokemon
  { name := "Pawniard", stage := .basic, evolvesFrom := none,
    hp := 6, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Corner", cost := [.metal], damage := 1,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Bisharp (zsv10pt5-65). Records: zsv10pt5-65, zsv10pt5-143. -/
def zsv10pt5_65 : Card := .pokemon
  { name := "Bisharp", stage := .stage1, evolvesFrom := some "Pawniard",
    hp := 12, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Cut Up", cost := [.metal], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Finishing Blow", cost := [.metal, .colorless], damage := 0,
        effect := .ite (.atLeast .opp 1) (.damage (.const 12)) (.damage (.const 6)),
        gx := false }] }

/-- Genesect ex (zsv10pt5-67). Records: zsv10pt5-67, zsv10pt5-161, zsv10pt5-169. Caveats: perPokemon, upTo0. -/
def zsv10pt5_67 : Card := .pokemon
  { name := "Genesect ex", stage := .basic, evolvesFrom := none,
    hp := 22, type := .metal, retreat := 2, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .ex, tera := false,
    abilities := [
      { name := "Metallic Signal", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.move .own .deck .hand (.and (.and .pokemon (.not .basic)) (.ptype .metal)) (.upTo 2)) .shuffle) }],
    attacks := [
      { name := "Protect Charge", cost := [.metal, .metal, .colorless], damage := 15,
        effect := .linger .own .next (.reduce 3),
        gx := false }] }

/-- Axew (zsv10pt5-68). Records: zsv10pt5-68, zsv10pt5-145. -/
def zsv10pt5_68 : Card := .pokemon
  { name := "Axew", stage := .basic, evolvesFrom := none,
    hp := 7, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Gather Strength", cost := [.colorless], damage := 0,
        effect := .seq (.move .own .deck .hand .energy (.upTo 2)) .shuffle,
        gx := false }] }

/-- Fraxure (zsv10pt5-69). Records: zsv10pt5-69, zsv10pt5-146. Caveats: perPokemon. -/
def zsv10pt5_69 : Card := .pokemon
  { name := "Fraxure", stage := .stage1, evolvesFrom := some "Axew",
    hp := 10, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite", cost := [.colorless], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Boundless Power", cost := [.fighting, .metal], damage := 9,
        effect := .linger .own .after (.lock .attack),
        gx := false }] }

/-- Pidove (zsv10pt5-71). Records: zsv10pt5-71, zsv10pt5-148. Caveats: hiddenInfo. -/
def zsv10pt5_71 : Card := .pokemon
  { name := "Pidove", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scout", cost := [.colorless], damage := 0,
        effect := .skip,
        gx := false },
      { name := "Stampede", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false }] }

/-- Minccino (zsv10pt5-75). Records: zsv10pt5-75, zsv10pt5-152. -/
def zsv10pt5_75 : Card := .pokemon
  { name := "Minccino", stage := .basic, evolvesFrom := none,
    hp := 6, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Tail Slap", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 2)) (.damage (.const 4))),
        gx := false }] }

/-- Cinccino (zsv10pt5-76). Records: zsv10pt5-76, zsv10pt5-153. -/
def zsv10pt5_76 : Card := .pokemon
  { name := "Cinccino", stage := .stage1, evolvesFrom := some "Minccino",
    hp := 10, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Do the Wave", cost := [.colorless], damage := 0,
        effect := .damage (.add (.const 2) (.count (.bench .own .pokemon) 2)),
        gx := false }] }

/-- Rufflet (zsv10pt5-77). Records: zsv10pt5-77, zsv10pt5-154. -/
def zsv10pt5_77 : Card := .pokemon
  { name := "Rufflet", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Peck", cost := [.colorless], damage := 1,
        effect := .skip,
        gx := false },
      { name := "Glide", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Braviary (zsv10pt5-78). Records: zsv10pt5-78, zsv10pt5-155. -/
def zsv10pt5_78 : Card := .pokemon
  { name := "Braviary", stage := .stage1, evolvesFrom := some "Rufflet",
    hp := 14, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aerial Ace", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 8)) (.damage (.const 4)),
        gx := false },
      { name := "Speed Wing", cost := [.colorless, .colorless, .colorless, .colorless], damage := 13,
        effect := .skip,
        gx := false }] }

/-- Air Balloon (zsv10pt5-79). Records: zsv10pt5-79. -/
def zsv10pt5_79 : Card := .tool "Air Balloon"
  { holder := .pokemon,
    attacks := [],
    abilities := [],
    statics := [
      { sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .retreatMinus 2 }] }

/-- Pokégear 3.0 (zsv10pt5-84). Records: zsv10pt5-84. -/
def zsv10pt5_84 : Card := .trainer "Pokégear 3.0" .item
    (.seq (.move .own (.top 7) .hand (.kind .supporter) (.upTo 1)) .shuffle)

/-- Bulbasaur (me1-1). Records: me1-1, me1-133. Caveats: perPokemon. -/
def me1_1 : Card := .pokemon
  { name := "Bulbasaur", stage := .basic, evolvesFrom := none,
    hp := 8, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bind Down", cost := [.grass], damage := 1,
        effect := .linger .opp .next (.lock .retreat),
        gx := false }] }

/-- Ivysaur (me1-2). Records: me1-2, me1-134. -/
def me1_2 : Card := .pokemon
  { name := "Ivysaur", stage := .stage1, evolvesFrom := some "Bulbasaur",
    hp := 11, type := .grass, retreat := 3, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Razor Leaf", cost := [.grass, .grass], damage := 6,
        effect := .skip,
        gx := false }] }

/-- Mega Venusaur ex (me1-3). Records: me1-3, me1-155, me1-177. Caveats: noopUse. -/
def me1_3 : Card := .pokemon
  { name := "Mega Venusaur ex", stage := .stage2, evolvesFrom := some "Ivysaur",
    hp := 38, type := .grass, retreat := 4, weakness := some .fire,
    resistance := none, ruleBox := .megaEx, tera := false,
    abilities := [
      { name := "Solar Transfer", use := .unlimited,
        spot := none, cond := none,
        effect := .fx (.moveEnergy .own (.energyOf .grass)) }],
    attacks := [
      { name := "Jungle Dump", cost := [.grass, .grass, .grass, .grass], damage := 24,
        effect := .heal 3,
        gx := false }] }

/-- Exeggcute (me1-4). Records: me1-4. -/
def me1_4 : Card := .pokemon
  { name := "Exeggcute", stage := .basic, evolvesFrom := none,
    hp := 6, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Jam-Packed", cost := [.colorless], damage := 0,
        effect := .seq (.attach .own .deck (.energyOf .grass) .active .any) .shuffle,
        gx := false }] }

/-- The cards of this part. -/
def cards : List Card := [
  sv10_105,
  sv10_107,
  sv10_108,
  sv10_109,
  sv10_110,
  sv10_111,
  sv10_112,
  sv10_114,
  sv10_117,
  sv10_118,
  sv10_119,
  sv10_120,
  sv10_121,
  sv10_130,
  sv10_131,
  sv10_132,
  sv10_133,
  sv10_134,
  sv10_135,
  sv10_137,
  sv10_138,
  sv10_141,
  sv10_142,
  sv10_143,
  sv10_144,
  sv10_147,
  sv10_151,
  sv10_152,
  sv10_156,
  sv10_157,
  sv10_158,
  sv10_159,
  sv10_160,
  sv10_164,
  sv10_168,
  sv10_176,
  sv10_179,
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
  rsv10pt5_17,
  rsv10pt5_18,
  rsv10pt5_19,
  rsv10pt5_21,
  rsv10pt5_22,
  rsv10pt5_23,
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
  rsv10pt5_54,
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
  rsv10pt5_77,
  rsv10pt5_80,
  rsv10pt5_81,
  rsv10pt5_82,
  rsv10pt5_172,
  zsv10pt5_1,
  zsv10pt5_2,
  zsv10pt5_3,
  zsv10pt5_4,
  zsv10pt5_5,
  zsv10pt5_7,
  zsv10pt5_10,
  zsv10pt5_11,
  zsv10pt5_13,
  zsv10pt5_14,
  zsv10pt5_15,
  zsv10pt5_16,
  zsv10pt5_17,
  zsv10pt5_18,
  zsv10pt5_19,
  zsv10pt5_20,
  zsv10pt5_21,
  zsv10pt5_22,
  zsv10pt5_24,
  zsv10pt5_25,
  zsv10pt5_26,
  zsv10pt5_29,
  zsv10pt5_30,
  zsv10pt5_31,
  zsv10pt5_32,
  zsv10pt5_33,
  zsv10pt5_37,
  zsv10pt5_41,
  zsv10pt5_42,
  zsv10pt5_43,
  zsv10pt5_45,
  zsv10pt5_47,
  zsv10pt5_48,
  zsv10pt5_49,
  zsv10pt5_51,
  zsv10pt5_53,
  zsv10pt5_54,
  zsv10pt5_55,
  zsv10pt5_56,
  zsv10pt5_57,
  zsv10pt5_58,
  zsv10pt5_59,
  zsv10pt5_60,
  zsv10pt5_61,
  zsv10pt5_62,
  zsv10pt5_63,
  zsv10pt5_64,
  zsv10pt5_65,
  zsv10pt5_67,
  zsv10pt5_68,
  zsv10pt5_69,
  zsv10pt5_71,
  zsv10pt5_75,
  zsv10pt5_76,
  zsv10pt5_77,
  zsv10pt5_78,
  zsv10pt5_79,
  zsv10pt5_84,
  me1_1,
  me1_2,
  me1_3,
  me1_4]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = ["Conkeldurr"] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Brave Bangle", "Serperior ex"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Mudsdale", "Bouffalant ex", "Klinklang"] := by decide +kernel

/-- The cards of this part with a static Retreat Cost effect (milestone M6), by name. -/
theorem cards_staticRetreat : (cards.filter (Card.hasStatic Static.isRetreat)).map Card.label = ["Air Balloon"] := by decide +kernel

/-- Every printed HP in this part is at most 38 counters (the largest over the imported pool). -/
theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ 38)) = true := by decide +kernel

/-- The HP units of every card's static effects in this part (`Card.hpGain`) are at most 10 counters
(the largest over the imported pool). -/
theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ 10)) = true := by decide +kernel

/-- The static damage reduction units of every card in this part (`Card.reduceGain`) are at most 5
counters (the largest over the imported pool). -/
theorem cards_reduceGain : cards.all (fun c => decide (c.reduceGain ≤ 5)) = true := by decide +kernel

/-- The cards of this part with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name. -/
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = ["Scolipede"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Virizion", "Klink", "Klang", "Genesect ex"] := by decide +kernel

end PokemonCards.Standard.Part05
