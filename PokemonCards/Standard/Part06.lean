/-
Imported Standard cards, part 6 of 11 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.16.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part06
open Pokemon

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

/-- Marnie's Morpeko (sv10-137). Records: sv10-137. Caveats: energyOfCount. -/
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
        effect := .fx (.seq (.move .own .hand .discard .any (.exactly 2)) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 1) .hand .any .all))) }],
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

/-- Emcee's Hype (sv10-163). Records: sv10-163, sv10-220, me6-92, me6-128. -/
def sv10_163 : Card := .trainer "Emcee's Hype" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own (.top 2) .hand .any .all) (.ite (.countGe (.prizes .opp) 4) .skip (.move .own (.top 2) .hand .any .all))))

/-- Energy Recycler (sv10-164). Records: sv10-164, me3-108. Caveats: upTo0. -/
def sv10_164 : Card := .trainer "Energy Recycler" .item
    (.seq (.ite (.countGe (.pile .own .discard .basicEnergy) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own .discard .shuffle .basicEnergy (.upTo 5)))

/-- Ethan's Adventure (sv10-165). Records: sv10-165, sv10-221, sv10-236. Caveats: upTo0. -/
def sv10_165 : Card := .trainer "Ethan's Adventure" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.or (.and .pokemon (.namePrefix "Ethan's ")) (.energyOf .fire)) (.upTo 3)) .shuffle))

/-- Granite Cave (sv10-166). Records: sv10-166. Caveats: staticBench. -/
def sv10_166 : Card := .trainer "Granite Cave" .stadium
    .skip [
      { sel := .all, filt := .and .pokemon (.namePrefix "Steven's "), tgt := none, src := none, need := none, eff := .reduce 3 .any }]

/-- Sacred Ash (sv10-168). Records: sv10-168, me3-115. Caveats: upTo0. -/
def sv10_168 : Card := .trainer "Sacred Ash" .item
    (.seq (.ite (.countGe (.pile .own .discard .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own .discard .shuffle .pokemon (.upTo 5)))

/-- Spikemuth Gym (sv10-169). Records: sv10-169. -/
def sv10_169 : Card := .trainer "Spikemuth Gym" .stadium
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.and .pokemon (.namePrefix "Marnie's ")) (.upTo 1)) .shuffle))

/-- Team Rocket's Ariana (sv10-171). Records: sv10-171, sv10-224, sv10-237, me2pt5-202. -/
def sv10_171 : Card := .trainer "Team Rocket's Ariana" .supporter
    (.seq (.ite (.countGe (.inPlay .own (.and .pokemon (.not (.and .pokemon (.namePrefix "Team Rocket's "))))) 1) (.ite (.countGe (.pile .own .hand .any) 5) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) .skip) (.seq (.ite (.countGe (.inPlay .own (.and .pokemon (.not (.and .pokemon (.namePrefix "Team Rocket's "))))) 1) .skip (.ite (.countGe (.pile .own .hand .any) 8) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.inPlay .own (.and .pokemon (.not (.and .pokemon (.namePrefix "Team Rocket's "))))) 1) (.drawTo .own 5) (.drawTo .own 8)))))

/-- Team Rocket's Factory (sv10-173). Records: sv10-173, me2pt5-203. -/
def sv10_173 : Card := .trainer "Team Rocket's Factory" .stadium
    (.ite (.countGe (.played .own (.and (.kind .supporter) (.nameHas "Team Rocket"))) 1) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 2) .hand .any .all)) (.move .own (.top 0) .hand .any (.exactly 1)))

/-- Team Rocket's Great Ball (sv10-175). Records: sv10-175, me2pt5-205. -/
def sv10_175 : Card := .trainer "Team Rocket's Great Ball" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.choice (.move .own .deck .hand (.and (.and .pokemon (.not .basic)) (.namePrefix "Team Rocket's ")) (.upTo 1)) (.move .own .deck .hand (.and .basic (.namePrefix "Team Rocket's ")) (.upTo 1))) .shuffle))

/-- Team Rocket's Petrel (sv10-176). Records: sv10-176, sv10-226, me2pt5-207. -/
def sv10_176 : Card := .trainer "Team Rocket's Petrel" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand .trainer (.upTo 1)) .shuffle))

/-- Team Rocket's Transceiver (sv10-178). Records: sv10-178, me2pt5-209, me2pt5-263. -/
def sv10_178 : Card := .trainer "Team Rocket's Transceiver" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.and (.kind .supporter) (.nameHas "Team Rocket")) (.upTo 1)) .shuffle))

/-- Team Rocket's Venture Bomb (sv10-179). Records: sv10-179. -/
def sv10_179 : Card := .trainer "Team Rocket's Venture Bomb" .item
    (.choice (.ite (.countGe (.bench .opp .pokemon) 1) (.choice (.counters 2) (.benchCounters .opp 2)) (.counters 2)) (.selfDamage 2))

/-- TM Machine (sv10-181). Records: sv10-181. Caveats: upTo0. -/
def sv10_181 : Card := .trainer "TM Machine" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.and .tool (.nameHas "Technical Machine")) (.upTo 3)) .shuffle))

/-- Team Rocket's Energy (sv10-182). Records: sv10-182, me2pt5-217. Caveats: rocketMove, unitsReading. -/
def sv10_182 : Card := .energy (.special "Team Rocket's Energy" [[.psychic, .darkness], [.psychic, .darkness]] { only := .and .pokemon (.namePrefix "Team Rocket's ") })

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

/-- Swadloon (rsv10pt5-2). Records: rsv10pt5-2, rsv10pt5-88. -/
def rsv10pt5_2 : Card := .pokemon
  { name := "Swadloon", stage := .stage1, evolvesFrom := some "Sewaddle",
    hp := 8, type := .grass, retreat := 2, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Healing Leaves", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.atLeast .own 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.heal 2)) }],
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

/-- Whimsicott ex (rsv10pt5-5). Records: rsv10pt5-5, rsv10pt5-157, rsv10pt5-165. -/
def rsv10pt5_5 : Card := .pokemon
  { name := "Whimsicott ex", stage := .stage1, evolvesFrom := some "Cottonee",
    hp := 23, type := .grass, retreat := 0, weakness := some .fire,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Energy Gift", cost := [.grass], damage := 0,
        effect := .seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)))) .shuffle,
        gx := false },
      { name := "Wondrous Cotton", cost := [.grass], damage := 0,
        effect := .damage (.count (.pile .opp .hand .trainer) 5),
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
        effect := .fx (.seq (.ite (.countGe (.pile .own .hand (.energyOf .fire)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.attach .own .hand (.energyOf .fire) .active .any) (.attach .own .hand (.energyOf .fire) .bench .any))) }],
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

/-- Samurott (rsv10pt5-23). Records: rsv10pt5-23, rsv10pt5-107. Caveats: energyUnitsCount. -/
def rsv10pt5_23 : Card := .pokemon
  { name := "Samurott", stage := .stage2, evolvesFrom := some "Dewott",
    hp := 16, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Torrential Whirlpool", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.switch .own) (.switch .opp))) }],
    attacks := [
      { name := "Energized Slash", cost := [.water], damage := 0,
        effect := .damage (.add (.const 3) (.count (.energy .own .energy) 5)),
        gx := false }] }

/-- Ducklett (rsv10pt5-25). Records: rsv10pt5-25, rsv10pt5-109. Caveats: energyOfBasic, energyOfCount. -/
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

/-- Vanilluxe (rsv10pt5-29). Records: rsv10pt5-29, rsv10pt5-113. -/
def rsv10pt5_29 : Card := .pokemon
  { name := "Vanilluxe", stage := .stage2, evolvesFrom := some "Vanillish",
    hp := 15, type := .water, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ram", cost := [.colorless, .colorless], damage := 6,
        effect := .skip,
        gx := false },
      { name := "Double Freeze", cost := [.water, .colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.seq (.damage (.const 9)) (.inflict .paralyzed)) (.seq (.damage (.const 18)) (.inflict .paralyzed))),
        gx := false }] }

/-- Keldeo ex (rsv10pt5-30). Records: rsv10pt5-30, rsv10pt5-159, rsv10pt5-167. Caveats: ignFxStadium, movedUpPromotion. -/
def rsv10pt5_30 : Card := .pokemon
  { name := "Keldeo ex", stage := .basic, evolvesFrom := none,
    hp := 21, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Gale Thrust", cost := [.water, .colorless], damage := 0,
        effect := .ite (.movedUp .own) (.damage (.const 12)) (.damage (.const 3)),
        gx := false },
      { name := "Sonic Edge", cost := [.water, .colorless, .colorless], damage := 0,
        effect := .damage (.const 12) { fx := true },
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

/-- Galvantula (rsv10pt5-34). Records: rsv10pt5-34, rsv10pt5-117. Caveats: anyAmount60, energyOfBasic, energyOfCount. -/
def rsv10pt5_34 : Card := .pokemon
  { name := "Galvantula", stage := .stage1, evolvesFrom := some "Joltik",
    hp := 9, type := .lightning, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Discharge", cost := [.lightning], damage := 0,
        effect := .choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.choice (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 0)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 0))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 1)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 5)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 2)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 10)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 3)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 15)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 4)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 20)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 5)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 25)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 6)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 30)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 7)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 35)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 8)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 40)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 9)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 45)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 10)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 50)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 11)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 55)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 12)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 60)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 13)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 65)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 14)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 70)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 15)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 75)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 16)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 80)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 17)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 85)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 18)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 90)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 19)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 95)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 20)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 100)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 21)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 105)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 22)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 110)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 23)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 115)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 24)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 120)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 25)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 125)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 26)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 130)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 27)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 135)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 28)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 140)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 29)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 145)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 30)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 150)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 31)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 155)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 32)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 160)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 33)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 165)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 34)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 170)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 35)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 175)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 36)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 180)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 37)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 185)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 38)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 190)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 39)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 195)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 40)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 200)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 41)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 205)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 42)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 210)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 43)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 215)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 44)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 220)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 45)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 225)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 46)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 230)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 47)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 235)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 48)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 240)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 49)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 245)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 50)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 250)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 51)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 255)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 52)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 260)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 53)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 265)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 54)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 270)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 55)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 275)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 56)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 280)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 57)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 285)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 58)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 290)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 59)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 295)))) (.seq (.seq (.discardEnergy .own .active (.energyOf .lightning) (.exactly 60)) (.ite (.countGe (.energy .own (.energyOf .lightning)) 1) (.move .own (.top 0) .hand .any (.exactly 1)) .skip)) (.damage (.const 300))),
        gx := false }] }

/-- Stunfisk (rsv10pt5-35). Records: rsv10pt5-35, rsv10pt5-118. Caveats: energyOfCount. -/
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

/-- Sigilyph (rsv10pt5-38). Records: rsv10pt5-38, rsv10pt5-121. Caveats: benchMods, perPokemon. -/
def rsv10pt5_38 : Card := .pokemon
  { name := "Sigilyph", stage := .basic, evolvesFrom := none,
    hp := 12, type := .psychic, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reflect", cost := [.colorless], damage := 0,
        effect := .linger .own .next (.reduce 4),
        gx := false },
      { name := "Telekinesis", cost := [.psychic, .colorless, .colorless], damage := 0,
        effect := .ite (.countGe (.bench .opp .pokemon) 1) (.choice (.damage (.const 7) { weak := true, resist := true }) (.benchDamage .opp 7)) (.damage (.const 7) { weak := true, resist := true }),
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

/-- Gothorita (rsv10pt5-42). Records: rsv10pt5-42, rsv10pt5-125. -/
def rsv10pt5_42 : Card := .pokemon
  { name := "Gothorita", stage := .stage1, evolvesFrom := some "Gothita",
    hp := 9, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fortunate Eye", cost := [.psychic], damage := 0,
        effect := .look .opp (.top 5) .any (.exactly 0) (.put .top) .top,
        gx := false },
      { name := "Psyshot", cost := [.psychic, .colorless], damage := 4,
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

/-- Boldore (rsv10pt5-47). Records: rsv10pt5-47, rsv10pt5-128. -/
def rsv10pt5_47 : Card := .pokemon
  { name := "Boldore", stage := .stage1, evolvesFrom := some "Roggenrola",
    hp := 11, type := .fighting, retreat := 3, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Smack Down", cost := [.fighting], damage := 0,
        effect := .ite (.top .opp (.resists .fighting)) (.damage (.const 8)) (.damage (.const 3)),
        gx := false },
      { name := "Power Gem", cost := [.fighting, .fighting, .fighting], damage := 9,
        effect := .skip,
        gx := false }] }

/-- Sawk (rsv10pt5-49). Records: rsv10pt5-49, rsv10pt5-130. -/
def rsv10pt5_49 : Card := .pokemon
  { name := "Sawk", stage := .basic, evolvesFrom := none,
    hp := 11, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Elbow Strike", cost := [.fighting], damage := 3,
        effect := .skip,
        gx := false },
      { name := "Rising Chop", cost := [.fighting], damage := 0,
        effect := .ite (.top .opp .ex) (.damage (.const 9) { weak := true, resist := true }) .skip,
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

/-- Mienshao (rsv10pt5-53). Records: rsv10pt5-53, rsv10pt5-134. -/
def rsv10pt5_53 : Card := .pokemon
  { name := "Mienshao", stage := .stage1, evolvesFrom := some "Mienfoo",
    hp := 10, type := .fighting, retreat := 1, weakness := some .psychic,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Low Sweep", cost := [.fighting], damage := 4,
        effect := .skip,
        gx := false },
      { name := "Smash Uppercut", cost := [.fighting, .fighting], damage := 0,
        effect := .damage (.const 8) { resist := true },
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

/-- Scrafty (rsv10pt5-58). Records: rsv10pt5-58, rsv10pt5-139. -/
def rsv10pt5_58 : Card := .pokemon
  { name := "Scrafty", stage := .stage1, evolvesFrom := some "Scraggy",
    hp := 12, type := .darkness, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Ruffians Attack", cost := [.darkness, .darkness], damage := 0,
        effect := .damage (.heads (.count (.inPlay .own (.ptype .darkness)) 1) 6),
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

/-- Mandibuzz (rsv10pt5-64). Records: rsv10pt5-64, rsv10pt5-145. Caveats: oppBenchFresh. -/
def rsv10pt5_64 : Card := .pokemon
  { name := "Mandibuzz", stage := .stage1, evolvesFrom := some "Vullaby",
    hp := 11, type := .darkness, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [
      { name := "Look for Prey", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .opp .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.bench .opp .pokemon) 5) (.look .opp .hand .any (.exactly 0) (.put .hand) .hand) (.look .opp .hand (.and .basic (.hpLe 7)) (.most 1) .bench .hand))) }],
    attacks := [
      { name := "Cutting Wind", cost := [.colorless, .colorless, .colorless], damage := 9,
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

/-- Durant (rsv10pt5-70). Records: rsv10pt5-70, rsv10pt5-150. -/
def rsv10pt5_70 : Card := .pokemon
  { name := "Durant", stage := .basic, evolvesFrom := none,
    hp := 11, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Bite Together", cost := [.colorless], damage := 0,
        effect := .ite (.countGe (.bench .own (.named "Durant")) 1) (.damage (.const 4)) (.damage (.const 2)),
        gx := false },
      { name := "Vise Grip", cost := [.metal, .colorless], damage := 5,
        effect := .skip,
        gx := false }] }

/-- Druddigon (rsv10pt5-71). Records: rsv10pt5-71, rsv10pt5-151. Caveats: ignFxStadium. -/
def rsv10pt5_71 : Card := .pokemon
  { name := "Druddigon", stage := .basic, evolvesFrom := none,
    hp := 12, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shred", cost := [.colorless], damage := 0,
        effect := .damage (.const 4) { fx := true },
        gx := false },
      { name := "Ambush", cost := [.fire, .water, .colorless], damage := 0,
        effect := .choice (.damage (.const 15)) (.damage (.const 9)),
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

/-- Watchog (rsv10pt5-73). Records: rsv10pt5-73, rsv10pt5-153. -/
def rsv10pt5_73 : Card := .pokemon
  { name := "Watchog", stage := .stage1, evolvesFrom := some "Patrat",
    hp := 9, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Focus Energy", cost := [.colorless], damage := 0,
        effect := .skip,
        gx := false, selfLock := .note },
      { name := "Hyper Fang", cost := [.colorless], damage := 0,
        effect := .choice (.ite (.usedLast .own) (.damage (.const 24)) (.damage (.const 8))) .skip,
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

/-- Tornadus (rsv10pt5-78). Records: rsv10pt5-78. Caveats: mayFail, moveAnyPair, moveMayFail. -/
def rsv10pt5_78 : Card := .pokemon
  { name := "Tornadus", stage := .basic, evolvesFrom := none,
    hp := 12, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wrapped in Wind", cost := [.colorless], damage := 0,
        effect := .attach .own .hand .basicEnergy .active .any,
        gx := false },
      { name := "Hurricane", cost := [.colorless, .colorless, .colorless], damage := 10,
        effect := .moveEnergy .own .basicEnergy,
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
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 3) .hand .any .all))

/-- Energy Retrieval (rsv10pt5-82). Records: rsv10pt5-82, me4-108. Caveats: upTo0. -/
def rsv10pt5_82 : Card := .trainer "Energy Retrieval" .item
    (.seq (.ite (.countGe (.pile .own .discard .basicEnergy) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own .discard .hand .basicEnergy (.upTo 2)))

/-- Harlequin (rsv10pt5-83). Records: rsv10pt5-83, rsv10pt5-163. -/
def rsv10pt5_83 : Card := .trainer "Harlequin" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .own .hand .any) 1) .skip (.ite (.countGe (.pile .opp .deck .any) 1) .skip (.ite (.countGe (.pile .opp .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))))) (.seq (.seq (.move .own .hand .shuffle .any .all) (.move .opp .hand .shuffle .any .all)) (.choice (.seq (.move .own (.top 5) .hand .any .all) (.move .opp (.top 3) .hand .any .all)) (.seq (.move .own (.top 3) .hand .any .all) (.move .opp (.top 5) .hand .any .all)))))

/-- Hilda (rsv10pt5-84). Records: rsv10pt5-84, rsv10pt5-164, rsv10pt5-171. -/
def rsv10pt5_84 : Card := .trainer "Hilda" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.seq (.move .own .deck .hand (.and .pokemon (.not .basic)) (.upTo 1)) (.move .own .deck .hand .energy (.upTo 1))) .shuffle))

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
        effect := .fx (.seq (.move .own .hand .discard (.energyOf .fire) (.exactly 1)) (.seq (.ite (.cond .opp .burned) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.inflict .burned))) }],
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
        effect := .fx (.seq (.seq (.ite (.countGe (.bench .own .pokemon) 5) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.ite (.countGe (.pile .own .discard (.and .basic (.hpLe 7))) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.putBench .own .discard (.and .basic (.hpLe 7)))) }],
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

/-- Cryogonal (zsv10pt5-27). Records: zsv10pt5-27, zsv10pt5-111. -/
def zsv10pt5_27 : Card := .pokemon
  { name := "Cryogonal", stage := .basic, evolvesFrom := none,
    hp := 9, type := .water, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Drag Off", cost := [.water], damage := 0,
        effect := .seq (.switch .opp) (.ite (.countGe (.bench .opp .pokemon) 1) (.damage (.const 2)) .skip),
        gx := false },
      { name := "Icicle", cost := [.water], damage := 3,
        effect := .skip,
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
        effect := .fx (.seq (.seq (.ite (.countGe (.pile .own .discard (.energyOf .lightning)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.attach .own .discard (.energyOf .lightning) .bench .any)) }],
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

/-- Zekrom ex (zsv10pt5-34). Records: zsv10pt5-34, zsv10pt5-158, zsv10pt5-166, zsv10pt5-172. Caveats: prizes6, recoil. -/
def zsv10pt5_34 : Card := .pokemon
  { name := "Zekrom ex", stage := .basic, evolvesFrom := none,
    hp := 23, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Slash", cost := [.colorless, .colorless], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Voltage Burst", cost := [.lightning, .lightning, .colorless], damage := 0,
        effect := .seq (.damage (.add (.const 13) (.count (.prizesTaken .opp) 5))) (.selfDamage 3),
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

/-- Elgyem (zsv10pt5-40). Records: zsv10pt5-40, zsv10pt5-120. Caveats: moveMayFail. -/
def zsv10pt5_40 : Card := .pokemon
  { name := "Elgyem", stage := .basic, evolvesFrom := none,
    hp := 6, type := .psychic, retreat := 1, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Slight Shift", cost := [.psychic], damage := 0,
        effect := .moveEnergy .opp .energy,
        gx := false },
      { name := "Beam", cost := [.colorless, .colorless, .colorless], damage := 4,
        effect := .skip,
        gx := false }] }

/-- Beheeyem (zsv10pt5-41). Records: zsv10pt5-41, zsv10pt5-121. Caveats: energyUnitsCount. -/
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

/-- The cards of this part. -/
def cards : List Card := [
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
  sv10_163,
  sv10_164,
  sv10_165,
  sv10_166,
  sv10_168,
  sv10_169,
  sv10_171,
  sv10_173,
  sv10_175,
  sv10_176,
  sv10_178,
  sv10_179,
  sv10_181,
  sv10_182,
  rsv10pt5_1,
  rsv10pt5_2,
  rsv10pt5_4,
  rsv10pt5_5,
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
  rsv10pt5_25,
  rsv10pt5_26,
  rsv10pt5_27,
  rsv10pt5_28,
  rsv10pt5_29,
  rsv10pt5_30,
  rsv10pt5_31,
  rsv10pt5_32,
  rsv10pt5_33,
  rsv10pt5_34,
  rsv10pt5_35,
  rsv10pt5_36,
  rsv10pt5_38,
  rsv10pt5_39,
  rsv10pt5_41,
  rsv10pt5_42,
  rsv10pt5_44,
  rsv10pt5_47,
  rsv10pt5_49,
  rsv10pt5_50,
  rsv10pt5_52,
  rsv10pt5_53,
  rsv10pt5_54,
  rsv10pt5_55,
  rsv10pt5_56,
  rsv10pt5_57,
  rsv10pt5_58,
  rsv10pt5_59,
  rsv10pt5_60,
  rsv10pt5_61,
  rsv10pt5_63,
  rsv10pt5_64,
  rsv10pt5_65,
  rsv10pt5_66,
  rsv10pt5_68,
  rsv10pt5_70,
  rsv10pt5_71,
  rsv10pt5_72,
  rsv10pt5_73,
  rsv10pt5_74,
  rsv10pt5_75,
  rsv10pt5_77,
  rsv10pt5_78,
  rsv10pt5_80,
  rsv10pt5_81,
  rsv10pt5_82,
  rsv10pt5_83,
  rsv10pt5_84,
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
  zsv10pt5_27,
  zsv10pt5_29,
  zsv10pt5_30,
  zsv10pt5_31,
  zsv10pt5_32,
  zsv10pt5_33,
  zsv10pt5_34,
  zsv10pt5_37,
  zsv10pt5_40,
  zsv10pt5_41]

/-- Every card of this part passes the per-card checks (`Card.importOk`). -/
theorem cards_ok : cards.all Card.importOk = true := by decide +kernel

/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a
Tool that gives nothing, a Special Energy card whose payload models nothing or sets `rest`). -/
theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel

/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/
theorem cards_nodup : nodupFp cards = true := by decide +kernel

/-- The cards of this part with a static HP effect (milestone M6), by name. -/
theorem cards_staticHp : (cards.filter (Card.hasStatic Static.isHp)).map Card.label = ["Cynthia's Power Weight"] := by decide +kernel

/-- The cards of this part with a static damage bonus effect (milestone M6), by name. -/
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Brave Bangle", "Serperior ex"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Granite Cave", "Bouffalant ex"] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Virizion", "Sigilyph"] := by decide +kernel

end PokemonCards.Standard.Part06
