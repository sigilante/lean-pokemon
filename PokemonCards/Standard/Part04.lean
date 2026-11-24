/-
Imported Standard cards, part 4 of 10 (150 cards).

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.13.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Props

namespace PokemonCards.Standard.Part04
open Pokemon

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

/-- Klefki (sv8-128). Records: sv8-128. -/
def sv8_128 : Card := .pokemon
  { name := "Klefki", stage := .basic, evolvesFrom := none,
    hp := 7, type := .metal, retreat := 1, weakness := some .fire,
    resistance := some (.grass, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Stick 'n' Draw", cost := [.colorless], damage := 0,
        effect := .ifDone (.countGe (.pile .own .hand .any) 1) (.move .own .hand .discard .any (.exactly 1)) (.move .own (.top 2) .hand .any .all),
        gx := false },
      { name := "Hook", cost := [.colorless], damage := 2,
        effect := .skip,
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
        effect := .seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) .shuffle,
        gx := false },
      { name := "Cotton Wings", cost := [.water, .metal], damage := 10,
        effect := .choice (.linger .own .next .prevent) .skip,
        gx := false }] }

/-- Dialga (sv8-135). Records: sv8-135. -/
def sv8_135 : Card := .pokemon
  { name := "Dialga", stage := .basic, evolvesFrom := none,
    hp := 13, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Time Manipulation", cost := [.colorless], damage := 0,
        effect := .seq .shuffle (.ite (.countGe (.pile .own .deck .any) 2) (.move .own .deck .top .any (.exactly 2)) (.move .own .deck .top .any .all)),
        gx := false },
      { name := "Buster Tail", cost := [.psychic, .metal, .colorless], damage := 16,
        effect := .skip,
        gx := false }] }

/-- Palkia (sv8-136). Records: sv8-136. -/
def sv8_136 : Card := .pokemon
  { name := "Palkia", stage := .basic, evolvesFrom := none,
    hp := 13, type := .dragon, retreat := 2, weakness := none,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Space Crash", cost := [.grass, .water], damage := 0,
        effect := .damage (.count (.energy .own .basicEnergy) 4),
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

/-- Tatsugiri ex (sv8-142). Records: sv8-142, sv8-226. Caveats: ignFxStadium. -/
def sv8_142 : Card := .pokemon
  { name := "Tatsugiri ex", stage := .basic, evolvesFrom := none,
    hp := 16, type := .dragon, retreat := 1, weakness := none,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Surprise Pump", cost := [.fire, .water], damage := 0,
        effect := .damage (.const 10) { fx := true },
        gx := false },
      { name := "Cinnabar Lure", cost := [.fire, .water, .darkness], damage := 0,
        effect := .look .own (.top 10) .pokemon (.upTo 10) .bench .shuffle,
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

/-- Zangoose (sv8-149). Records: sv8-149. -/
def sv8_149 : Card := .pokemon
  { name := "Zangoose", stage := .basic, evolvesFrom := none,
    hp := 9, type := .colorless, retreat := 1, weakness := some .fighting,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Fury Cutter", cost := [.colorless], damage := 0,
        effect := .choice (.damage (.const 1)) (.choice (.damage (.const 3)) (.choice (.damage (.const 6)) (.damage (.const 9)))),
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

/-- Braviary (sv8-153). Records: sv8-153, sv8-214. -/
def sv8_153 : Card := .pokemon
  { name := "Braviary", stage := .stage1, evolvesFrom := some "Rufflet",
    hp := 13, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Drag Off", cost := [.colorless, .colorless], damage := 0,
        effect := .seq (.switch .opp) (.ite (.countGe (.bench .opp .pokemon) 1) (.damage (.const 4)) .skip),
        gx := false },
      { name := "Blasting Wind", cost := [.colorless, .colorless, .colorless], damage := 12,
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

/-- Brilliant Blender (sv8-164). Records: sv8-164. Caveats: aceSpec, searchAny, upTo0. -/
def sv8_164 : Card := .trainer "Brilliant Blender" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .discard .any (.upTo 5)) .shuffle))

/-- Cyrano (sv8-170). Records: sv8-170, sv8-230. Caveats: upTo0. -/
def sv8_170 : Card := .trainer "Cyrano" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.and .pokemon (.not .noRuleBox)) (.upTo 3)) .shuffle))

/-- Deduction Kit (sv8-171). Records: sv8-171. -/
def sv8_171 : Card := .trainer "Deduction Kit" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.look .own (.top 3) .any (.exactly 0) (.put .top) .top) (.look .own (.top 3) .any (.exactly 0) (.put .top) .bottom)))

/-- Drasna (sv8-173). Records: sv8-173, sv8-231. -/
def sv8_173 : Card := .trainer "Drasna" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .own .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.move .own .hand .shuffle .any .all) (.choice (.move .own (.top 8) .hand .any .all) (.move .own (.top 3) .hand .any .all))))

/-- Dusk Ball (sv8-175). Records: sv8-175. -/
def sv8_175 : Card := .trainer "Dusk Ball" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.look .own (.bottom 7) .pokemon (.upTo 1) (.put .hand) .shuffle))

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
    (.seq (.ite (.countGe (.pile .own .discard (.kind .supporter)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own .discard .hand (.kind .supporter) (.upTo 2)))

/-- Precious Trolley (sv8-185). Records: sv8-185. Caveats: aceSpec. -/
def sv8_185 : Card := .trainer "Precious Trolley" .item
    (.seq (.ite (.countGe (.bench .own .pokemon) 5) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.seq (.putBench .own .deck .basic) (.seq (.putBench .own .deck .basic) (.seq (.putBench .own .deck .basic) (.seq (.putBench .own .deck .basic) (.putBench .own .deck .basic))))) .shuffle)))

/-- Surfer (sv8-187). Records: sv8-187, sv8-235, me2pt5-200, me2pt5-293. -/
def sv8_187 : Card := .trainer "Surfer" .supporter
    (.seq (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.switch .own) (.drawTo .own 5)))

/-- Tera Orb (sv8-189). Records: sv8-189. -/
def sv8_189 : Card := .trainer "Tera Orb" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand (.and .pokemon .tera) (.upTo 1)) .shuffle))

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

/-- Pyroar (sv8pt5-16). Records: sv8pt5-16. -/
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
        effect := .skip,
        gx := false, selfLock := .all }] }

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

/-- Vaporeon ex (sv8pt5-23). Records: sv8pt5-23, sv8pt5-149. Caveats: benchMods. -/
def sv8pt5_23 : Card := .pokemon
  { name := "Vaporeon ex", stage := .stage1, evolvesFrom := some "Eevee",
    hp := 28, type := .water, retreat := 2, weakness := some .lightning,
    resistance := none, ruleBox := .ex, tera := true,
    abilities := [],
    attacks := [
      { name := "Severe Squall", cost := [.water, .colorless], damage := 0,
        effect := .seq (.ite (.top .opp .ex) (.damage (.const 6) { weak := true, resist := true }) .skip) (.benchSome .opp 5 .ex true 6),
        gx := false },
      { name := "Aquamarine", cost := [.fire, .water, .lightning], damage := 28,
        effect := .skip,
        gx := false, selfLock := .all }] }

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

/-- Sylveon (sv8pt5-40). Records: sv8pt5-40. Caveats: staticPreventBench. -/
def sv8pt5_40 : Card := .pokemon
  { name := "Sylveon", stage := .stage1, evolvesFrom := some "Eevee",
    hp := 12, type := .psychic, retreat := 1, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Safeguard", use := .static [{ sel := .self, filt := .any, tgt := none, src := none, need := none, eff := .prevent .ex }],
        spot := none, cond := none,
        effect := .fx .skip }],
    attacks := [
      { name := "Magical Shot", cost := [.psychic, .colorless, .colorless], damage := 10,
        effect := .skip,
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

/-- Lucario ex (sv8pt5-51). Records: sv8pt5-51. -/
def sv8pt5_51 : Card := .pokemon
  { name := "Lucario ex", stage := .stage1, evolvesFrom := some "Riolu",
    hp := 26, type := .fighting, retreat := 2, weakness := some .psychic,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Aura Uppercut", cost := [.fighting], damage := 5,
        effect := .skip,
        gx := false },
      { name := "Tornado Rush", cost := [.fighting, .colorless], damage := 0,
        effect := .ite (.usedLast .own) (.damage (.const 20)) (.damage (.const 10)),
        gx := false, selfLock := .note }] }

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
        effect := .seq (.seq (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any)) (.choice (.attach .own .deck .basicEnergy .active .any) (.attach .own .deck .basicEnergy .bench .any))) .shuffle,
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

/-- Heatran (sv8pt5-68). Records: sv8pt5-68. -/
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
        effect := .skip,
        gx := false, selfLock := .all }] }

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

/-- Lugia ex (sv8pt5-82). Records: sv8pt5-82. -/
def sv8pt5_82 : Card := .pokemon
  { name := "Lugia ex", stage := .basic, evolvesFrom := none,
    hp := 22, type := .colorless, retreat := 2, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .ex, tera := false,
    abilities := [],
    attacks := [
      { name := "Hyper Whirlpool", cost := [.colorless, .colorless, .colorless], damage := 14,
        effect := .iter (.ite (.countGe (.energy .opp .energy) 1) (.discardEnergy .opp .active .energy (.exactly 1)) .skip),
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

/-- Shaymin (sv8pt5-87). Records: sv8pt5-87. Caveats: moveAnyPair, moveMayFail. -/
def sv8pt5_87 : Card := .pokemon
  { name := "Shaymin", stage := .basic, evolvesFrom := none,
    hp := 7, type := .colorless, retreat := 1, weakness := some .lightning,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Reflect Energy", cost := [.colorless, .colorless], damage := 6,
        effect := .moveEnergy .own .energy,
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
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own (.top 3) .hand .any .all))

/-- Larry's Skill (sv8pt5-115). Records: sv8pt5-115, sv8pt5-139. -/
def sv8pt5_115 : Card := .trainer "Larry's Skill" .supporter
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.ite (.countGe (.pile .own .hand .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.seq (.seq (.move .own .hand .discard .any .all) (.seq (.move .own .deck .hand .pokemon (.upTo 1)) (.seq (.move .own .deck .hand (.kind .supporter) (.upTo 1)) (.move .own .deck .hand .basicEnergy (.upTo 1))))) .shuffle))

/-- Max Rod (sv8pt5-116). Records: sv8pt5-116. Caveats: aceSpec, upTo0. -/
def sv8pt5_116 : Card := .trainer "Max Rod" .item
    (.seq (.ite (.countGe (.pile .own .discard (.or .pokemon .basicEnergy)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.move .own .discard .hand (.or .pokemon .basicEnergy) (.upTo 5)))

/-- Roto-Stick (sv8pt5-127). Records: sv8pt5-127. -/
def sv8pt5_127 : Card := .trainer "Roto-Stick" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own (.top 4) .hand (.kind .supporter) (.upTo 4)) .shuffle))

/-- Treasure Tracker (sv8pt5-131). Records: sv8pt5-131. Caveats: aceSpec, upTo0. -/
def sv8pt5_131 : Card := .trainer "Treasure Tracker" .item
    (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand .tool (.upTo 5)) .shuffle))

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

/-- Butterfree (sv9-3). Records: sv9-3. -/
def sv9_3 : Card := .pokemon
  { name := "Butterfree", stage := .stage2, evolvesFrom := some "Metapod",
    hp := 12, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Scale Hurricane", cost := [.grass], damage := 0,
        effect := .choice (.damage (.const 0)) (.choice (.damage (.const 6)) (.choice (.seq (.damage (.const 12)) (.inflict .paralyzed)) (.choice (.seq (.damage (.const 18)) (.inflict .paralyzed)) (.seq (.damage (.const 24)) (.inflict .paralyzed))))),
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

/-- Floragato (sv9-17). Records: sv9-17. -/
def sv9_17 : Card := .pokemon
  { name := "Floragato", stage := .stage1, evolvesFrom := some "Sprigatito",
    hp := 9, type := .grass, retreat := 1, weakness := some .fire,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Magical Leaf", cost := [.colorless, .colorless], damage := 0,
        effect := .choice (.damage (.const 3)) (.seq (.damage (.const 6)) (.heal 3)),
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

/-- Blaziken ex (sv9-24). Records: sv9-24. Caveats: mayFail. -/
def sv9_24 : Card := .pokemon
  { name := "Blaziken ex", stage := .stage2, evolvesFrom := some "Combusken",
    hp := 32, type := .fire, retreat := 2, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Seething Spirit", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .discard .basicEnergy) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.choice (.attach .own .discard .basicEnergy .active .any) (.attach .own .discard .basicEnergy .bench .any))) }],
    attacks := [
      { name := "Smolder-sault", cost := [.fire, .colorless], damage := 20,
        effect := .skip,
        gx := false, selfLock := .all }] }

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
        effect := .damage (.count (.pile .opp .discard .basicEnergy) 3),
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

/-- Volcanion ex (sv9-31). Records: sv9-31, sv9-171, sv9-182. Caveats: moveAnyPair, moveMayFail. -/
def sv9_31 : Card := .pokemon
  { name := "Volcanion ex", stage := .basic, evolvesFrom := none,
    hp := 22, type := .fire, retreat := 3, weakness := some .water,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Scalding Steam", use := .once,
        spot := some .active, cond := none,
        effect := .fx (.seq (.ite (.cond .opp .burned) (.move .own (.top 0) .hand .any (.exactly 1)) .skip) (.inflict .burned)) }],
    attacks := [
      { name := "Scorching Cyclone", cost := [.fire, .fire, .colorless], damage := 16,
        effect := .moveEnergy .own .energy,
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

/-- Lombre (sv9-36). Records: sv9-36. -/
def sv9_36 : Card := .pokemon
  { name := "Lombre", stage := .stage1, evolvesFrom := some "Lotad",
    hp := 9, type := .water, retreat := 1, weakness := some .lightning,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Aqua Slash", cost := [.water, .water], damage := 7,
        effect := .skip,
        gx := false, selfLock := .all }] }

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

/-- Iono's Bellibolt ex (sv9-53). Records: sv9-53, sv9-172, sv9-183, sv9-188, me2pt5-70, me2pt5-279. Caveats: mayFail. -/
def sv9_53 : Card := .pokemon
  { name := "Iono's Bellibolt ex", stage := .stage1, evolvesFrom := some "Iono's Tadbulb",
    hp := 28, type := .lightning, retreat := 2, weakness := some .fighting,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Electric Streamer", use := .unlimited,
        spot := none, cond := none,
        effect := .fx (.seq (.seq (.ite (.countGe (.pile .own .hand (.energyOf .lightning)) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.ite (.countGe (.bench .own (.and .pokemon (.namePrefix "Iono's "))) 1) .skip (.ite (.top .own (.and .pokemon (.namePrefix "Iono's "))) .skip (.move .own (.top 0) .hand .any (.exactly 1))))) (.choice (.attach .own .hand (.energyOf .lightning) .active (.and .pokemon (.namePrefix "Iono's "))) (.attach .own .hand (.energyOf .lightning) .bench (.and .pokemon (.namePrefix "Iono's "))))) }],
    attacks := [
      { name := "Thunderous Bolt", cost := [.lightning, .lightning, .lightning, .colorless], damage := 23,
        effect := .skip,
        gx := false, selfLock := .all }] }

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

/-- Metagross (sv9-63). Records: sv9-63. -/
def sv9_63 : Card := .pokemon
  { name := "Metagross", stage := .stage2, evolvesFrom := some "Metang",
    hp := 17, type := .psychic, retreat := 3, weakness := some .darkness,
    resistance := some (.fighting, 3), ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Wrack Down", cost := [.psychic], damage := 6,
        effect := .skip,
        gx := false },
      { name := "Conjoined Beams", cost := [.psychic, .psychic], damage := 0,
        effect := .ite (.countGe (.bench .own (.named "Beldum")) 1) (.ite (.countGe (.bench .own (.named "Metang")) 1) (.damage (.const 28)) (.damage (.const 13))) (.damage (.const 13)),
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

/-- Lillie's Ribombee (sv9-67). Records: sv9-67, sv9-164. Caveats: oppBenchFresh. -/
def sv9_67 : Card := .pokemon
  { name := "Lillie's Ribombee", stage := .stage1, evolvesFrom := some "Lillie's Cutiefly",
    hp := 7, type := .psychic, retreat := 0, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Inviting Wink", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .fx (.look .opp .hand .basic (.upTo 5) .bench .hand) }],
    attacks := [
      { name := "Magical Shot", cost := [.psychic], damage := 5,
        effect := .skip,
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

/-- Grimmsnarl (sv9-73). Records: sv9-73. Caveats: printedRetreat. -/
def sv9_73 : Card := .pokemon
  { name := "Grimmsnarl", stage := .stage2, evolvesFrom := some "Morgrem",
    hp := 17, type := .psychic, retreat := 2, weakness := some .metal,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Shadowy Knot", cost := [.psychic], damage := 0,
        effect := .damage (.count (.retreat .opp) 5),
        gx := false },
      { name := "Mega Punch", cost := [.psychic, .colorless], damage := 12,
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
        effect := .fx (.seq (.ite (.atLeast .own 1) .skip (.ite (.countGe (.bench .own .pokemon) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1)))) (.ite (.countGe (.bench .own .pokemon) 1) (.choice (.heal 3) (.benchHeal 3)) (.heal 3))) }],
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

/-- Mamoswine ex (sv9-79). Records: sv9-79, sv9-174. -/
def sv9_79 : Card := .pokemon
  { name := "Mamoswine ex", stage := .stage2, evolvesFrom := some "Piloswine",
    hp := 34, type := .fighting, retreat := 4, weakness := some .grass,
    resistance := none, ruleBox := .ex, tera := false,
    abilities := [
      { name := "Mammoth Hauler", use := .once,
        spot := none, cond := none,
        effect := .fx (.seq (.ite (.countGe (.pile .own .deck .any) 1) .skip (.move .own (.top 0) .hand .any (.exactly 1))) (.seq (.move .own .deck .hand .pokemon (.upTo 1)) .shuffle)) }],
    attacks := [
      { name := "Rumbling March", cost := [.fighting, .fighting], damage := 0,
        effect := .damage (.add (.const 18) (.count (.bench .own (.stage .stage2)) 4)),
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

/-- Rockruff (sv9-84). Records: sv9-84. -/
def sv9_84 : Card := .pokemon
  { name := "Rockruff", stage := .basic, evolvesFrom := none,
    hp := 7, type := .fighting, retreat := 1, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [],
    attacks := [
      { name := "Dig It Up", cost := [.colorless], damage := 0,
        effect := .choice (.move .own (.top 1) .discard .any .all) .skip,
        gx := false },
      { name := "Stampede", cost := [.colorless, .colorless], damage := 2,
        effect := .skip,
        gx := false }] }

/-- Lycanroc (sv9-85). Records: sv9-85, sv9-166. Caveats: selfBench, upTo0. -/
def sv9_85 : Card := .pokemon
  { name := "Lycanroc", stage := .stage1, evolvesFrom := some "Rockruff",
    hp := 12, type := .fighting, retreat := 2, weakness := some .grass,
    resistance := none, ruleBox := .none, tera := false,
    abilities := [
      { name := "Spike-Clad", use := .onPlay .evolve,
        spot := none, cond := none,
        effect := .seq (.self (.attach .discard (.named "Spiky Energy"))) (.self (.attach .discard (.named "Spiky Energy"))) }],
    attacks := [
      { name := "Clamping Fangs", cost := [.colorless, .colorless, .colorless], damage := 0,
        effect := .damage (.add (.const 4) (.per .opp 4)),
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

/-- The cards of this part. -/
def cards : List Card := [
  sv8_126,
  sv8_127,
  sv8_128,
  sv8_129,
  sv8_132,
  sv8_134,
  sv8_135,
  sv8_136,
  sv8_138,
  sv8_139,
  sv8_140,
  sv8_142,
  sv8_144,
  sv8_145,
  sv8_146,
  sv8_148,
  sv8_149,
  sv8_152,
  sv8_153,
  sv8_154,
  sv8_155,
  sv8_157,
  sv8_159,
  sv8_162,
  sv8_164,
  sv8_170,
  sv8_171,
  sv8_173,
  sv8_175,
  sv8_177,
  sv8_178,
  sv8_180,
  sv8_183,
  sv8_185,
  sv8_187,
  sv8_189,
  sv8pt5_1,
  sv8pt5_2,
  sv8pt5_3,
  sv8pt5_4,
  sv8pt5_15,
  sv8pt5_16,
  sv8pt5_18,
  sv8pt5_23,
  sv8pt5_24,
  sv8pt5_28,
  sv8pt5_38,
  sv8pt5_39,
  sv8pt5_40,
  sv8pt5_47,
  sv8pt5_48,
  sv8pt5_50,
  sv8pt5_51,
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
  sv8pt5_82,
  sv8pt5_83,
  sv8pt5_84,
  sv8pt5_86,
  sv8pt5_87,
  sv8pt5_88,
  sv8pt5_89,
  sv8pt5_90,
  sv8pt5_91,
  sv8pt5_109,
  sv8pt5_115,
  sv8pt5_116,
  sv8pt5_127,
  sv8pt5_131,
  sv9_1,
  sv9_3,
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
  sv9_17,
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
  sv9_31,
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
  sv9_53,
  sv9_54,
  sv9_57,
  sv9_59,
  sv9_61,
  sv9_62,
  sv9_63,
  sv9_65,
  sv9_66,
  sv9_67,
  sv9_69,
  sv9_70,
  sv9_71,
  sv9_72,
  sv9_73,
  sv9_74,
  sv9_75,
  sv9_76,
  sv9_77,
  sv9_78,
  sv9_79,
  sv9_80,
  sv9_81,
  sv9_82,
  sv9_83,
  sv9_84,
  sv9_85,
  sv9_86,
  sv9_87,
  sv9_88]

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
theorem cards_staticBonus : (cards.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Lilligant"] := by decide +kernel

/-- The cards of this part with a static damage reduction effect (milestone M6), by name. -/
theorem cards_staticReduce : (cards.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Bronzong", "Furfrou", "Regirock"] := by decide +kernel

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
theorem cards_trigDamaged : (cards.filter (Card.hasTrig .damaged)).map Card.label = [] := by decide +kernel

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
theorem cards_untame : (cards.filter (fun c => !c.tame)).map Card.label = ["Jasmine's Gaze", "Paras"] := by decide +kernel

end PokemonCards.Standard.Part04
