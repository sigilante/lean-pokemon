/-
The imported Standard cards: the list, the cards not imported, and the set-level checks.

GENERATED FILE: do not edit. Written by tools/importer/importer.py version 0.16.0
from pokemon-tcg-data commit 90f27d0e14cefe48ccb2b8922a7a356b2fcf0072 (pool: regulation marks H, I, J plus Basic Energy,
survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.
-/

import PokemonCards.Standard.Part01
import PokemonCards.Standard.Part02
import PokemonCards.Standard.Part03
import PokemonCards.Standard.Part04
import PokemonCards.Standard.Part05
import PokemonCards.Standard.Part06
import PokemonCards.Standard.Part07
import PokemonCards.Standard.Part08
import PokemonCards.Standard.Part09
import PokemonCards.Standard.Part10
import PokemonCards.Props

namespace PokemonCards.Standard
open Pokemon

/-- Every imported card (1497 terms, for 1505 of the pool's 2161 cards: 8 cards share the term of another,
`sameTerm`). -/
def all : List Card :=
  Part01.cards ++
  Part02.cards ++
  Part03.cards ++
  Part04.cards ++
  Part05.cards ++
  Part06.cards ++
  Part07.cards ++
  Part08.cards ++
  Part09.cards ++
  Part10.cards

/-- The imported cards whose term is that of an earlier card in `all` (their records differ only in
text read as a reminder): representative record id, name, and the id of the card whose term it is. -/
def sameTerm : List (String × String × String) := [("sv8pt5-17", "Hearthflame Mask Ogerpon ex", "sv6-40"), ("sv8pt5-58", "Cornerstone Mask Ogerpon ex", "sv6-112"), ("sv8pt5-73", "Dragapult ex", "sv6-130"), ("me1-166", "Air Balloon", "zsv10pt5-79"), ("me2pt5-113", "Mega Lucario ex", "me1-77"), ("me2pt5-267", "Mega Diancie ex", "me2-41"), ("me5-104", "Brave Bangle", "rsv10pt5-80"), ("me6-133", "Growing Grass Energy", "me3-86")]

/-- The cards of the pool that were not imported, each with its representative record id, name and
first blocking reason (the full list of reasons is in tools/importer/out/not-imported.tsv). -/
def notImported : List (String × String × String) := [
  ("svp-92", "Miraidon", "unhandled sentence: Search your deck for up to 2 Basic Energy cards and attach them to your Future Pokémon in any way you like."),
  ("svp-97", "Flutter Mane", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): As long as this Pokémon is in the Active Spot, your opponent's Active Pokémon has no Abilities, except for Midnight Fluttering."),
  ("svp-98", "Iron Thorns", "unhandled sentence: Reveal the top 5 cards of your deck."),
  ("svp-115", "Thwackey", "Ability: condition not expressible: your Active Pokémon has the Festival Lead Ability: Once during your turn, if your Active Pokémon has the Festival Lead Ability, you may search your deck for a card and put it into your hand. Then, shuffle your deck."),
  ("svp-116", "Infernape", "unhandled sentence: Attach a Basic Fire Energy card, a Basic Fighting Energy card, or 1 of each from your hand to your Pokémon in any way you like."),
  ("svp-117", "Froslass", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): During Pokémon Checkup, put 1 damage counter on each Pokémon that has an Ability (both yours and your opponent's), except any Froslass."),
  ("svp-126", "Palafin ex", "Ability: static, play (a rule on putting the card into play): Put this Pokémon into play only with the effect of Palafin's Zero to Hero Ability."),
  ("svp-127", "Walking Wake ex", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Damage from attacks used by this Pokémon isn't affected by any effects on your opponent's Active Pokémon."),
  ("svp-128", "Iron Leaves ex", "switch this Pokémon in, not restricted to the Bench: Switch it with your Active Pokémon."),
  ("svp-133", "Ledian", "unhandled sentence: Switch in 1 of your opponent's Benched Pokémon that has 90 HP or less remaining to the Active Spot."),
  ("svp-134", "Crabominable", "Ability: static, cost (attack cost or Energy provision): Attacks used by this Pokémon cost Colorless less for each Kofu card in your discard pile."),
  ("svp-135", "Drifblim", "unhandled sentence: This attack also does 30 damage to each of your Drifloon and Drifblim."),
  ("svp-136", "Bouffalant", "Ability: static, stack (stacking rule (\"doesn't stack\"): the model adds every effect in force): As long as you have at least 1 other Bouffalant in play, all of your Basic Colorless Pokémon take 60 less damage from attacks from your opponent's Pokémon (after applying Weakness and Resistance). The effect of Curly Wall doesn't stack."),
  ("svp-144", "Gouging Fire ex", "unhandled sentence: This Pokémon can't use Blaze Blitz again until it leaves the Active Spot."),
  ("svp-145", "Raging Bolt ex", "unhandled sentence: You may discard any amount of Basic Energy from your Pokémon."),
  ("svp-146", "Iron Crown ex", "Ability: static, filter (a filter the model has not (name prefix, Ancient, Future, Tera, \"has an Ability\", Mega Evolution Pokémon ex)): Attacks used by your Future Pokémon, except any Iron Crown ex, do 20 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."),
  ("svp-147", "Iron Boulder ex", "not modelled (Known gaps, MV2): history: next-turn trigger on this Pokémon: During your opponent's next turn, if this Pokémon is damaged by an attack (even if it is Knocked Out), put 8 damage counters on the Attacking Pokémon."),
  ("svp-152", "Chien-Pao", "unhandled sentence: Put an Energy attached to this Pokémon into your hand."),
  ("svp-154", "Indeedee", "unhandled sentence: Heal 30 damage from your Active Pokémon and have it recover from a Special Condition."),
  ("svp-156", "Quagsire", "count not expressible: Energy card you discarded in this way: This attack does 80 damage for each Energy card you discarded in this way."),
  ("svp-158", "Pachirisu", "coin flips not expressible: Flip 3 coins. Attach a number of Basic Lightning Energy cards up to the number of heads from your discard pile to your Benched Pokémon in any way you like."),
  ("svp-165", "Terapagos ex", "condition not expressible: you go second: If you go second, you can't use this attack during your first turn."),
  ("sv5-5", "Shiftry", "unhandled sentence: Choose 3 of your opponent's Benched Pokémon."),
  ("sv5-15", "Whimsicott", "unhandled sentence: Heal all damage from your Active Grass Pokémon."),
  ("sv5-21", "Brambleghast", "Ability: static, cond (a condition the model cannot test statically (Prize cards, the hand, other Pokémon in play, Special Conditions, Special Energy, Tools, damage)): This Pokémon gets +50 HP for each Prize card your opponent has taken."),
  ("sv5-24", "Rabsca", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all damage from and effects of attacks from your opponent's Pokémon done to your Benched Pokémon."),
  ("sv5-31", "Heatmor", "coin flips not expressible: Flip 3 coins. For each tails, discard an Energy from this Pokémon."),
  ("sv5-34", "Incineroar ex", "Ability: static, cost (attack cost or Energy provision): Attacks used by this Pokémon cost Colorless less for each of your opponent's Benched Pokémon."),
  ("sv5-49", "Palafin", "unhandled sentence: This Pokémon also does 10 damage to itself for each damage counter on it."),
  ("sv5-52", "Raichu", "unhandled sentence: This attack does 50 damage to each Pokémon that has any damage counters on it (both yours and your opponent's), except for this Pokémon."),
  ("sv5-60", "Wugtrio ex", "unhandled sentence: Discard up to 3 Energy cards from your hand."),
  ("sv5-63", "Mr. Mime", "revealed hand: clause not expressible: you may use the effect of a Supporter card you find there as the effect of this attack"),
  ("sv5-69", "Bronzong", "unhandled sentence: During your opponent's next turn, they can't play any Pokémon from their hand to evolve their Pokémon."),
  ("sv5-73", "Elgyem", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv5-76", "Ribombee", "unhandled sentence: During your next turn, if the Defending Pokémon is Knocked Out, take 2 more Prize cards."),
  ("sv5-77", "Scream Tail", "unhandled sentence: Heal 100 damage from 1 of your Benched Ancient Pokémon."),
  ("sv5-80", "Iron Valiant", "not modelled (Known gaps, MV2): history: the Supporter played this turn: If you played a Future Supporter card from your hand during this turn, this attack does 100 more damage."),
  ("sv5-84", "Relicanth", "Ability: static, attacks (use of other attacks): Each of your evolved Pokémon can use any attack from its previous Evolutions. (You still need the necessary Energy to use each attack.)"),
  ("sv5-92", "Mudsdale", "unhandled sentence: Attach a Basic Fighting Energy card from your discard pile to each of your Benched Pokémon."),
  ("sv5-96", "Great Tusk", "condition not expressible: your Benched Pokémon have any damage counters on them: If your Benched Pokémon have any damage counters on them, this attack does 80 more damage."),
  ("sv5-97", "Great Tusk", "not modelled (Known gaps, MV2): history: the Supporter played this turn: If you played an Ancient Supporter card from your hand during this turn, discard 3 more cards in this way."),
  ("sv5-104", "Gengar ex", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): Whenever your opponent attaches an Energy card from their hand to 1 of their Pokémon, put 2 damage counters on that Pokémon."),
  ("sv5-107", "Sableye", "unhandled sentence: You may move any number of damage counters from your opponent's Benched Pokémon to their Active Pokémon."),
  ("sv5-111", "Scizor ex", "unhandled sentence: Discard up to 2 Metal Energy from this Pokémon."),
  ("sv5-118", "Iron Treads", "Ability: static, typeWeak (a change of type or Weakness): As long as this Pokémon has a Future Booster Energy Capsule attached, it is Fighting and Metal type."),
  ("sv5-128", "Dunsparce", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv5-129", "Dudunsparce", "Ability: returns its Pokémon from play: Once during your turn, you may draw 3 cards. If you drew any cards in this way, shuffle this Pokémon and all attached cards into your deck."),
  ("sv5-131", "Delcatty", "unhandled sentence: You may move any amount of Energy from your Pokémon to your other Pokémon in any way you like."),
  ("sv5-133", "Pidove", "Ability: condition on this Pokémon, which may be on the Bench: this Pokémon's remaining HP is 30 or less: Once during your turn, if this Pokémon's remaining HP is 30 or less, you may search your deck for an Unfezant or Unfezant ex and put it onto this Pidove to evolve it. Then, shuffle your deck."),
  ("sv5-135", "Unfezant", "unhandled sentence: You may put 2 Energy attached to your opponent's Active Pokémon into their hand."),
  ("sv5-136", "Minccino", "unhandled sentence: Discard up to 2 Pokémon Tools from your opponent's Pokémon."),
  ("sv5-138", "Drampa", "condition not expressible: all of your Benched Pokémon have at least 1 damage counter on them: If all of your Benched Pokémon have at least 1 damage counter on them, this attack does 120 more damage."),
  ("sv5-140", "Ancient Booster Energy Capsule", "Pokémon Tool: subtype not modelled on a Tool: Ancient: The Ancient Pokémon this card is attached to gets +60 HP, recovers from all Special Conditions, and can't be affected by any Special Conditions."),
  ("sv5-141", "Awakening Drum", "unhandled sentence: Draw a card for each of your Ancient Pokémon in play."),
  ("sv5-142", "Bianca's Devotion", "unhandled sentence: Heal all damage from 1 of your Pokémon that has 30 HP or less remaining."),
  ("sv5-143", "Boxed Order", "unhandled sentence: Your turn ends."),
  ("sv5-149", "Future Booster Energy Capsule", "Pokémon Tool: subtype not modelled on a Tool: Future: The Future Pokémon this card is attached to has no Retreat Cost, and the attacks it uses do 20 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."),
  ("sv5-150", "Hand Trimmer", "unhandled sentence: Each player discards cards from their hand until they have 5 cards in their hand."),
  ("sv5-151", "Heavy Baton", "Pokémon Tool: triggered (M8b shape), printed condition (Weakness, Retreat Cost, another card in play, the attacker's kind, a holder name): If the Pokémon this card is attached to has a Retreat Cost of exactly 4, is in the Active Spot, and is Knocked Out by damage from an attack from your opponent's Pokémon, move up to 3 Basic Energy cards from that Pokémon to your Benched Pokémon in any way you like."),
  ("sv5-155", "Morty's Conviction", "unhandled sentence: Draw a card for each of your opponent's Benched Pokémon."),
  ("sv5-158", "Reboot Pod", "unhandled sentence: Attach a Basic Energy card from your discard pile to each of your Future Pokémon."),
  ("sv5-159", "Rescue Board", "Pokémon Tool: static, noRetreat (\"has no Retreat Cost\" in a form not read (a condition or holder outside the forms of SEff.noRetreat)): The Retreat Cost of the Pokémon this card is attached to is Colorless less. If that Pokémon's remaining HP is 30 or less, it has no Retreat Cost."),
  ("sv5-160", "Salvatore", "unhandled sentence: Search your deck for a card that has no Abilities and evolves from 1 of your Pokémon, and put it onto that Pokémon to evolve it."),
  ("sv5-161", "Mist Energy", "Special Energy: rider not modelled: prevention of effects of attacks (absent from the language): Prevent all effects of attacks used by your opponent's Pokémon done to the Pokémon this card is attached to."),
  ("sv6-3", "Pinsir", "unhandled sentence: At the end of your opponent's next turn, the Defending Pokémon will be Knocked Out."),
  ("sv6-5", "Ariados", "count of the Retreat Cost on a card whose own static effect changes it (Count.retreat reads the printed cost)"),
  ("sv6-9", "Volbeat", "condition not expressible: you go first: If you go first, you can use this attack during your first turn."),
  ("sv6-10", "Illumise", "unhandled sentence: You can use this attack only if you go second, and only during your first turn."),
  ("sv6-11", "Leafeon", "'If you do' after an action with no exact feasibility test (the model's action may do nothing, or its test is not one count): If you do, heal all damage from that Pokémon."),
  ("sv6-16", "Rillaboom", "unhandled sentence: During your opponent's next turn, attacks used by the Defending Pokémon cost Colorless more, and its Retreat Cost is Colorless more."),
  ("sv6-18", "Dipplin", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If Festival Grounds is in play, this Pokémon may use an attack it has twice. If the first attack Knocks Out your opponent's Active Pokémon, you may attack again after your opponent chooses a new Active Pokémon."),
  ("sv6-20", "Poltchageist", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): As long as this Pokémon is on your Bench, prevent all damage from and effects of attacks from your opponent's Pokémon done to this Pokémon."),
  ("sv6-22", "Sinistcha", "unhandled sentence: Discard up to 3 Grass Energy cards from your Pokémon."),
  ("sv6-23", "Sinistcha ex", "not modelled (Known gaps, MV2): spread: amount computed by the text: Put 2 damage counters on 1 of your opponent's Pokémon for each Basic Grass Energy card in your discard pile."),
  ("sv6-25", "Teal Mask Ogerpon ex", "condition not expressible: you attached Energy to a Pokémon in this way: If you attached Energy to a Pokémon in this way, draw a card."),
  ("sv6-29", "Magcargo ex", "count not expressible: Energy card discarded in this way: This attack does 140 more damage for each Energy card discarded in this way."),
  ("sv6-39", "Chi-Yu", "condition not expressible: a Stadium is in play: If a Stadium is in play, this attack does 60 more damage."),
  ("sv6-43", "Poliwrath", "unhandled sentence: You may do 120 more damage."),
  ("sv6-44", "Goldeen", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If Festival Grounds is in play, this Pokémon may use an attack it has twice. If the first attack Knocks Out your opponent's Active Pokémon, you may attack again after your opponent chooses a new Active Pokémon."),
  ("sv6-46", "Jynx", "condition not expressible: you put any Pokémon onto your Bench in this way: If you put any Pokémon onto your Bench in this way, move an Energy from this Pokémon to the new Benched Pokémon."),
  ("sv6-50", "Milotic", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): Your opponent's Pokémon in play and all attached cards can't be put into your opponent's hand."),
  ("sv6-54", "Glaceon", "unhandled sentence: At the end of your opponent's next turn, put 9 damage counters on the Defending Pokémon."),
  ("sv6-60", "Palafin", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): Once during your turn, when this Pokémon moves from the Active Spot to the Bench, you may search your deck for a Palafin ex and switch it with this Pokémon. Any attached cards, damage counters, Special Conditions, turns in play, and any other effects remain on the new Pokémon. If you switched a Pokémon in this way, put this card into your deck. Then, shuffle your deck."),
  ("sv6-63", "Walking Wake", "unhandled sentence: Put up to 9 damage counters on this Pokémon."),
  ("sv6-64", "Wellspring Mask Ogerpon ex", "unhandled sentence: You may shuffle 3 Energy attached to this Pokémon into your deck."),
  ("sv6-77", "Iron Thorns ex", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): As long as this Pokémon is in the Active Spot, Pokémon with a Rule Box in play (both yours and your opponent's) have no Abilities, except for Future Pokémon. (Pokémon ex, Pokémon V, etc. have Rule Boxes.)"),
  ("sv6-79", "Clefable", "unhandled sentence: Choose 1 of your opponent's Active Pokémon's attacks and use it as this attack."),
  ("sv6-80", "Abra", "Ability: returns its Pokémon from play: Once during your turn, if this Pokémon is in the Active Spot, you may shuffle it and all attached cards into your deck."),
  ("sv6-82", "Alakazam", "unhandled sentence: You may move any number of damage counters from your opponent's Pokémon to their other Pokémon in any way you like."),
  ("sv6-85", "Chimecho", "unhandled sentence: Shuffle 1 of your Benched Pokémon and all attached cards into your deck."),
  ("sv6-89", "Swirlix", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If Festival Grounds is in play, this Pokémon may use an attack it has twice. If the first attack Knocks Out your opponent's Active Pokémon, you may attack again after your opponent chooses a new Active Pokémon."),
  ("sv6-91", "Sandygast", "unhandled sentence: During your opponent's next turn, if the Defending Pokémon tries to use an attack, your opponent flips a coin."),
  ("sv6-92", "Palossand", "unhandled sentence: During your opponent's next turn, if the Defending Pokémon tries to use an attack, your opponent flips a coin."),
  ("sv6-93", "Enamorus", "condition not expressible: any of your Pokémon in play are the same type as any of your opponent's Pokémon in play: If any of your Pokémon in play are the same type as any of your opponent's Pokémon in play, this attack does 120 more damage."),
  ("sv6-94", "Scream Tail ex", "unhandled sentence: You can use this attack only if you go second, and only during your first turn."),
  ("sv6-95", "Munkidori", "Ability: condition on this Pokémon, which may be on the Bench: this Pokémon has any Darkness Energy attached: Once during your turn, if this Pokémon has any Darkness Energy attached, you may move up to 3 damage counters from 1 of your Pokémon to 1 of your opponent's Pokémon."),
  ("sv6-96", "Fezandipiti", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If this Pokémon has any Darkness Energy attached and is damaged by an attack, flip a coin. If heads, prevent that damage."),
  ("sv6-100", "Hisuian Arcanine", "condition not expressible: your Benched Pokémon have any damage counters on them: If your Benched Pokémon have any damage counters on them, this attack does 90 more damage."),
  ("sv6-104", "Gurdurr", "unhandled sentence: You may do 30 more damage."),
  ("sv6-105", "Conkeldurr", "unhandled sentence: This Pokémon is now Confused."),
  ("sv6-107", "Hawlucha", "condition not expressible: you have more Prize cards remaining than your opponent: If you have more Prize cards remaining than your opponent, this attack does 90 more damage."),
  ("sv6-110", "Ting-Lu", "condition not expressible: a Stadium is in play: If a Stadium is in play, this attack also does 30 damage to each of your opponent's Benched Pokémon, and discard that Stadium."),
  ("sv6-117", "Scolipede", "unhandled sentence: Put damage counters on your opponent's Active Pokémon until its remaining HP is 10."),
  ("sv6-122", "Aggron", "count not expressible: of your Pokémon that has any damage counters on it: This attack does 50 damage for each of your Pokémon that has any damage counters on it."),
  ("sv6-132", "Farfetch'd", "attach a non-Energy card: Search your deck for a Pokémon Tool card and attach it to this Pokémon."),
  ("sv6-135", "Eevee", "unhandled sentence: Search your deck for a card that evolves from this Pokémon and put it onto this Pokémon to evolve it."),
  ("sv6-136", "Snorlax", "'If you do' after an action with no exact feasibility test (the model's action may do nothing, or its test is not one count): If you do, heal 60 damage from this Pokémon."),
  ("sv6-141", "Bloodmoon Ursaluna ex", "Ability: static, cost (attack cost or Energy provision): Blood Moon used by this Pokémon costs Colorless less for each Prize card your opponent has taken."),
  ("sv6-144", "Caretaker", "condition not expressible: you drew any cards in this way and if Community Center is in play: If you drew any cards in this way and if Community Center is in play, shuffle this Caretaker into your deck instead of discarding it."),
  ("sv6-145", "Carmine", "condition not expressible: you go first: If you go first, you may use this card during your first turn."),
  ("sv6-146", "Community Center", "Stadium: activated effect not expressible: a condition on the history of the turn: Once during each player's turn, if they played a Supporter card from their hand this turn, they may heal 10 damage from each of their Pokémon."),
  ("sv6-149", "Festival Grounds", "Stadium: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Each Pokémon that has any Energy attached (both yours and your opponent's) recovers from all Special Conditions and can't be affected by any Special Conditions."),
  ("sv6-150", "Handheld Fan", "Pokémon Tool: triggered (M8b shape), effect sentence not translated (unhandled sentence): Move an Energy from your opponent's Active Pokémon to 1 of your opponent's Benched Pokémon."),
  ("sv6-153", "Jamming Tower", "Stadium: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): Pokémon Tools attached to each Pokémon (both yours and your opponent's) have no effect."),
  ("sv6-154", "Kieran", "unhandled sentence: Choose 1:    • Switch your Active Pokémon with 1 of your Benched Pokémon."),
  ("sv6-156", "Love Ball", "card kind with no filter: Pokémon with the same name as 1 of your opponent's Pokémon in play: Search your deck for a Pokémon with the same name as 1 of your opponent's Pokémon in play, reveal it, and put it into your hand."),
  ("sv6-157", "Lucian", "unhandled sentence: Each player shuffles their hand and puts it on the bottom of their deck."),
  ("sv6-159", "Ogre's Mask", "unhandled sentence: Choose a Pokémon ex in your discard pile that has \"Ogerpon\" in its name, and switch it with 1 of your Pokémon ex in play that has \"Ogerpon\" in its name."),
  ("sv6-160", "Perrin", "unhandled sentence: Reveal up to 2 Pokémon in your hand and put them into your deck."),
  ("sv6-162", "Scoop Up Cyclone", "unhandled sentence: Put 1 of your Pokémon and all attached cards into your hand."),
  ("sv6-164", "Survival Brace", "Pokémon Tool: triggered: If the Pokémon this card is attached to has full HP and would be Knocked Out by damage from an attack from your opponent's Pokémon, it is not Knocked Out, and its remaining HP becomes 10. Then, discard this card."),
  ("sv6-166", "Boomerang Energy", "Special Energy: rider not modelled: return after a discard by the holder's attack (no machinery): If this card is discarded by an effect of an attack used by the Pokémon this card is attached to, attach this card from your discard pile to that Pokémon after attacking."),
  ("sv6-167", "Legacy Energy", "Special Energy: rider not modelled: a Prize change on Knock Out, once per game (absent): If the Pokémon this card is attached to is Knocked Out by damage from an attack from your opponent's Pokémon, that player takes 1 fewer Prize card."),
  ("sv6-225", "Rescue Board", "Pokémon Tool: static, noRetreat (\"has no Retreat Cost\" in a form not read (a condition or holder outside the forms of SEff.noRetreat)): The Retreat Cost of the Pokémon this card is attached to is Colorless less. If that Pokémon's remaining HP is 30 or less, it has no Retreat Cost."),
  ("sv6pt5-1", "Joltik", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv6pt5-2", "Galvantula", "Ability: static, filter (a filter the model has not (name prefix, Ancient, Future, Tera, \"has an Ability\", Mega Evolution Pokémon ex)): Attacks used by this Pokémon do 50 more damage to your opponent's Active Pokémon that has an Ability (before applying Weakness and Resistance)."),
  ("sv6pt5-9", "Iron Moth", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Ancient Pokémon."),
  ("sv6pt5-15", "Revavroom ex", "unhandled sentence: Discard this Pokémon and all attached cards."),
  ("sv6pt5-17", "Hypno", "unhandled sentence: During your opponent's next turn, if they attach an Energy card from their hand to the Defending Pokémon, their turn ends."),
  ("sv6pt5-21", "Cresselia", "unhandled sentence: Heal 20 damage from each of your Pokémon."),
  ("sv6pt5-22", "Sylveon", "unhandled sentence: Choose 1 of your opponent's Benched Pokémon."),
  ("sv6pt5-29", "Crobat", "Ability: condition on the history of the turn (this turn, last turn): Once during your turn, if you played Janine's Secret Art from your hand this turn, you may draw cards until you have 8 cards in your hand."),
  ("sv6pt5-33", "Inkay", "unhandled sentence: Look at the top card of your opponent's deck."),
  ("sv6pt5-34", "Malamar", "unhandled sentence: This attack does 120 damage to the new Active Pokémon."),
  ("sv6pt5-35", "Yveltal", "unhandled sentence: Put 2 damage counters on each of your opponent's Pokémon that has any damage counters on it."),
  ("sv6pt5-36", "Okidogi ex", "condition not expressible: you attached Energy to a Pokémon in this way: If you attached Energy to a Pokémon in this way, this Pokémon is now Poisoned."),
  ("sv6pt5-37", "Munkidori ex", "Ability: triggered (M8b shape), changes the Prize cards taken: If this Pokémon is Knocked Out by damage from an attack from your opponent's Pokémon, and if you have any Pecharunt ex in play, your opponent takes 1 fewer Prize card."),
  ("sv6pt5-39", "Pecharunt ex", "unhandled sentence: Switch 1 of your Benched Darkness Pokémon, except any Pecharunt ex, with your Active Pokémon."),
  ("sv6pt5-40", "Genesect", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): If this Pokémon has a Pokémon Tool attached, your opponent can't play any ACE SPEC cards from their hand."),
  ("sv6pt5-42", "Copperajah", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): As long as this Pokémon is in the Active Spot, your opponent can't play any Stadium cards from their hand."),
  ("sv6pt5-45", "Fraxure", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): Whenever your opponent plays an Item or Supporter card from their hand, prevent all effects of that card done to this Pokémon."),
  ("sv6pt5-47", "Kyurem", "Ability: static, cost (attack cost or Energy provision): If your opponent has any cards in their discard pile that have \"Colress\" in the name, this Pokémon can use the Trifrost attack for Colorless."),
  ("sv6pt5-50", "Eevee", "card kind with no filter: Basic Energy cards of different types: Search your deck for up to 3 Basic Energy cards of different types, reveal them, and put them into your hand."),
  ("sv6pt5-55", "Binding Mochi", "Pokémon Tool: static, cond (a condition the model cannot test statically (Prize cards, the hand, other Pokémon in play, Special Conditions, Special Energy, Tools, damage)): Attacks used by the Poisoned Pokémon this card is attached to do 40 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."),
  ("sv6pt5-56", "Cassiopeia", "unhandled sentence: You can use this card only when it is the last card in your hand."),
  ("sv6pt5-59", "Janine's Secret Art", "unhandled sentence: Choose up to 2 of your Darkness Pokémon."),
  ("sv6pt5-60", "Neutralization Zone", "Stadium: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all damage done to Pokémon that don't have a Rule Box (both yours and your opponent's) by attacks from the opponent's Pokémon ex and Pokémon V. (Pokémon ex, Pokémon V, etc. have Rule Boxes.)    This card can't be put into your hand or deck from the discard pile."),
  ("sv6pt5-62", "Poké Vital A", "unhandled sentence: This card can't be put into your hand or deck from the discard pile."),
  ("sv6pt5-63", "Powerglass", "Pokémon Tool: triggered: At the end of your turn (after your attack), if the Pokémon this card is attached to is in the Active Spot, you may attach a Basic Energy card from your discard pile to it."),
  ("sv6pt5-64", "Xerosic's Machinations", "unhandled sentence: Your opponent discards cards from their hand until they have 3 cards in their hand."),
  ("sv7-6", "Cradily", "unhandled sentence: Choose Burned, Confused, or Poisoned."),
  ("sv7-11", "Eldegoss", "unhandled sentence: Put this Pokémon and all attached cards into your deck."),
  ("sv7-13", "Dipplin", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Basic Pokémon."),
  ("sv7-14", "Hydrapple ex", "condition not expressible: you attached Energy to a Pokémon in this way: If you attached Energy to a Pokémon in this way, heal 30 damage from that Pokémon."),
  ("sv7-44", "Drednaw", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all damage done to this Pokémon by attacks from your opponent's Pokémon if that damage is 200 or more."),
  ("sv7-45", "Veluza", "Ability: static, cost (attack cost or Energy provision): Attacks used by this Pokémon cost Colorless less for each Kofu card in your discard pile."),
  ("sv7-49", "Lanturn", "unhandled sentence: Put 8 damage counters instead of 3 on that Pokémon for this Special Condition."),
  ("sv7-50", "Joltik", "card kind with no filter: Basic Grass Energy cards and up to 2 Basic Lightning Energy: Search your deck for up to 2 Basic Grass Energy cards and up to 2 Basic Lightning Energy cards and attach them to your Pokémon in any way you like."),
  ("sv7-52", "Charjabug", "Bench placement of a named card that is not a Basic Pokémon (putBench is Basic-only): Search your deck for up to 3 Charjabug and put them onto your Bench."),
  ("sv7-53", "Vikavolt", "unhandled sentence: Switch this Pokémon with 1 of your Benched Lightning Pokémon."),
  ("sv7-58", "Slowking", "unhandled sentence: Discard the top card of your deck, and if that card is a Pokémon that doesn't have a Rule Box, choose 1 of its attacks and use it as this attack."),
  ("sv7-65", "Alcremie", "card kind with no filter: Pokémon that are the same type as any Basic Energy attached to this Pokémon: Search your deck for up to 5 Pokémon that are the same type as any Basic Energy attached to this Pokémon, reveal them, and put them into your hand."),
  ("sv7-67", "Dachsbun ex", "unhandled sentence: Heal all damage from each of your Evolution Pokémon."),
  ("sv7-71", "Iron Boulder", "condition not expressible: you don't have the same number of cards in your hand as your opponent: If you don't have the same number of cards in your hand as your opponent, this attack does nothing."),
  ("sv7-73", "Marowak", "condition not expressible: any of your Benched Cubone have any damage counters on them: If any of your Benched Cubone have any damage counters on them, this attack does 120 more damage."),
  ("sv7-76", "Rhyperior", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): As long as this Pokémon is in the Active Spot, whenever your opponent plays a Supporter card from their hand, prevent all effects of that card done to all of your Pokémon."),
  ("sv7-80", "Medicham ex", "unhandled sentence: Put damage counters on your opponent's Active Pokémon until its remaining HP is 50."),
  ("sv7-92", "Swalot", "condition not expressible: this Pokémon has more Energy attached than your opponent's Active Pokémon: If this Pokémon has more Energy attached than your opponent's Active Pokémon, this attack does 160 more damage."),
  ("sv7-93", "Pangoro", "unhandled sentence: This Pokémon is now Confused."),
  ("sv7-96", "Grimmsnarl", "unhandled sentence: Switch out your opponent's Active Pokémon to the Bench."),
  ("sv7-101", "Klinklang", "Ability: used from the hand: Once during your turn, if this Pokémon is in your hand and your opponent has any Stage 2 Pokémon in play, you may put this Pokémon onto your Bench."),
  ("sv7-110", "Orthworm ex", "Ability: triggered (M8b shape), not restricted to the Active Spot (the model fires damaged triggers in the Active Spot only): If this Pokémon is damaged by an attack from your opponent's Pokémon (even if this Pokémon is Knocked Out), put 2 damage counters on the Attacking Pokémon for each Metal Energy attached to this Pokémon."),
  ("sv7-111", "Raging Bolt", "not modelled (Known gaps, MV2): spread: amount computed by the text: This attack does 30 damage to 1 of your opponent's Pokémon for each Energy attached to this Pokémon."),
  ("sv7-117", "Purugly", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv7-118", "Fan Rotom", "Ability: once during your first turn: Once during your first turn, you may search your deck for up to 3 Colorless Pokémon with 100 HP or less, reveal them, and put them into your hand. Then, shuffle your deck. You can't use more than 1 Fan Call Ability during your turn."),
  ("sv7-123", "Talonflame", "condition not expressible: the Retreat Cost of your opponent's Active Pokémon is ColorlessColorless or more: If the Retreat Cost of your opponent's Active Pokémon is ColorlessColorless or more, this attack does 110 more damage."),
  ("sv7-129", "Antique Cover Fossil", "Trainer played as a Pokémon"),
  ("sv7-130", "Antique Root Fossil", "Trainer played as a Pokémon"),
  ("sv7-131", "Area Zero Underdepths", "Stadium: static, bench (Bench size): Each player who has any Tera Pokémon in play can have up to 8 Pokémon on their Bench.    If a player no longer has any Tera Pokémon in play, that player discards Pokémon from their Bench until they have 5. When this card leaves play, both players discard Pokémon from their Bench until they have 5, and the player who played this card discards first."),
  ("sv7-132", "Briar", "unhandled sentence: You can use this card only if your opponent has exactly 2 Prize cards remaining."),
  ("sv7-133", "Crispin", "unhandled sentence: Search your deck for up to 2 Basic Energy cards of different types, reveal them, and put 1 of them into your hand."),
  ("sv7-135", "Glass Trumpet", "unhandled sentence: You can use this card only if you have any Tera Pokémon in play."),
  ("sv7-136", "Grand Tree", "Stadium: activated effect not expressible: unhandled sentence: Once during each player's turn, that player may search their deck for a Stage 1 Pokémon that evolves from 1 of their Basic Pokémon and put it onto that Pokémon to evolve it. If that Pokémon was evolved in this way, that player may search their deck for a Stage 2 Pokémon that evolves from that Pokémon and put it onto that Pokémon to evolve it. Then, that player shuffles their deck. (Players can't evolve a Basic Pokémon during their first turn or a Basic Pokémon that was put into play this turn.)"),
  ("sv7-138", "Kofu", "unhandled sentence: Put 2 cards from your hand on the bottom of your deck in any order."),
  ("sv7-140", "Occa Berry", "Pokémon Tool: triggered: If the Pokémon this card is attached to is damaged by an attack from your opponent's Fire Pokémon, it takes 60 less damage (after applying Weakness and Resistance), and discard this card."),
  ("sv7-141", "Payapa Berry", "Pokémon Tool: triggered: If the Pokémon this card is attached to is damaged by an attack from your opponent's Psychic Pokémon, it takes 60 less damage (after applying Weakness and Resistance), and discard this card."),
  ("sv7-142", "Sparkling Crystal", "Pokémon Tool: static, cost (attack cost or Energy provision): When the Tera Pokémon this card is attached to uses an attack, that attack costs 1 Energy less. (The Energy can be of any type.)"),
  ("sv8-1", "Exeggcute", "condition not expressible: you go first: If you go first, you can use this attack during your first turn."),
  ("sv8-7", "Vivillon", "unhandled sentence: For each of your Benched Pokémon, search your deck for a card that evolves from that Pokémon and put it onto that Pokémon to evolve it."),
  ("sv8-11", "Zarude", "unhandled sentence: You may put all Energy attached to this Pokémon into your hand to have this attack do 80 more damage."),
  ("sv8-20", "Castform Sunny Form", "unhandled sentence: Move all Energy from this Pokémon to 1 of your Benched Pokémon."),
  ("sv8-26", "Oricorio", "several cards to one chosen Pokémon: Attach up to 2 Basic Energy cards from your discard pile to 1 of your Benched Pokémon."),
  ("sv8-31", "Skeledirge", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all effects of attacks used by your opponent's Pokémon done to this Pokémon. (Damage is not an effect.)"),
  ("sv8-35", "Ceruledge", "unhandled sentence: Discard all Special Energy from all of your opponent's Pokémon."),
  ("sv8-37", "Scovillain ex", "Ability: static, typeWeak (a change of type or Weakness): As long as this Pokémon is in play, it is Grass and Fire type."),
  ("sv8-39", "Paldean Tauros", "unhandled sentence: You may put 2 Energy attached to your opponent's Active Stage 2 Pokémon into their hand."),
  ("sv8-42", "Milotic ex", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all damage from and effects of attacks from your opponent's Tera Pokémon done to this Pokémon."),
  ("sv8-45", "Walrein", "unhandled sentence: During your opponent's next turn, Pokémon that have 2 or less Energy attached can't attack."),
  ("sv8-57", "Pikachu ex", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If this Pokémon has full HP and would be Knocked Out by damage from an attack, it is not Knocked Out, and its remaining HP becomes 10."),
  ("sv8-65", "Tapu Koko", "condition not expressible: you have more Prize cards remaining than your opponent: If you have more Prize cards remaining than your opponent, this attack does 90 more damage."),
  ("sv8-67", "Kilowattrel", "unhandled sentence: Move all Energy from this Pokémon to your Benched Pokémon in any way you like."),
  ("sv8-68", "Kilowattrel ex", "attack not well formed in the model (Attack.wf): Switch this Pokémon with 1 of your Benched Pokémon. If you do, attach up to 2 Basic Lightning Energy cards from your hand to this Pokémon."),
  ("sv8-69", "Miraidon", "unhandled sentence: During your opponent's next turn, prevent all damage done to each of your Future Pokémon by attacks from Pokémon ex."),
  ("sv8-72", "Togekiss", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): When your opponent's Active Pokémon is Knocked Out, flip a coin. If heads, take 1 more Prize card. The effect of Wonder Kiss doesn't stack."),
  ("sv8-74", "Azumarill", "Ability: static, cost (attack cost or Energy provision): If you have any Tera Pokémon in play, this Pokémon can use the Double-Edge attack for Psychic."),
  ("sv8-75", "Smoochum", "several cards to one chosen Pokémon: Search your deck for up to 2 Basic Psychic Energy cards and attach them to 1 of your Benched Pokémon."),
  ("sv8-80", "Azelf", "count not expressible: damage counter on all of your opponent's Pokémon: This attack does 10 more damage for each damage counter on all of your opponent's Pokémon."),
  ("sv8-83", "Cofagrigus", "unhandled sentence: Put 6 damage counters on each Pokémon that has an Ability (both yours and your opponent's)."),
  ("sv8-86", "Sylveon ex", "unhandled sentence: Choose 2 of your opponent's Benched Pokémon."),
  ("sv8-89", "Oricorio", "several cards to one chosen Pokémon: Attach up to 2 Basic Energy cards from your discard pile to 1 of your Benched Pokémon."),
  ("sv8-91", "Palossand ex", "unhandled sentence: Put damage counters on each of your opponent's Benched Pokémon until its remaining HP is 100."),
  ("sv8-94", "Flittle", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv8-95", "Espathra", "unhandled sentence: Devolve 1 of your opponent's evolved Pokémon by putting the highest Stage Evolution card on it into your opponent's hand."),
  ("sv8-96", "Flutter Mane", "unhandled sentence: Move all damage counters from 1 of your Benched Ancient Pokémon to your opponent's Active Pokémon."),
  ("sv8-100", "Annihilape", "unhandled sentence: This Pokémon is now Confused."),
  ("sv8-101", "Paldean Tauros", "unhandled sentence: It can't attack during your opponent's next turn."),
  ("sv8-107", "Gastrodon", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): As long as this Pokémon is on your Bench, Benched Stage 2 Pokémon (both yours and your opponent's) have no Abilities."),
  ("sv8-113", "Grapploct", "unhandled sentence: This attack can be used for Fighting."),
  ("sv8-115", "Glimmora", "unhandled sentence: During your opponent's next turn, Energy cards can't be attached from your opponent's hand to that Pokémon."),
  ("sv8-116", "Koraidon", "not modelled (Known gaps, MV2): history: an attack used last turn: If 1 of your other Ancient Pokémon used an attack during your last turn, this attack does 150 more damage."),
  ("sv8-121", "Grafaiai", "unhandled sentence: Attach up to 3 Energy cards from your opponent's discard pile to their Pokémon in any way you like."),
  ("sv8-130", "Archaludon ex", "unhandled sentence: During your opponent's next turn, this Pokémon has no Weakness."),
  ("sv8-131", "Gholdengo", "unhandled sentence: You may shuffle this Pokémon and all attached cards into your deck."),
  ("sv8-133", "Alolan Exeggutor ex", "unhandled sentence: You may attach any number of Basic Energy cards from your hand to your Pokémon in any way you like."),
  ("sv8-137", "Turtonator", "unhandled sentence: Discard an Energy from your opponent's Active Pokémon ex."),
  ("sv8-141", "Eternatus", "'If you can't' after an action with no exact feasibility test: If you can't, this attack does nothing."),
  ("sv8-143", "Eevee", "Ability: static (first-turn rule): As long as this Pokémon is in the Active Spot, it can evolve during your first turn or the turn you play it."),
  ("sv8-147", "Slaking ex", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): If your opponent has no Pokémon ex or Pokémon V in play, this Pokémon can't attack."),
  ("sv8-150", "Kecleon", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If any damage is done to this Pokémon by attacks, flip a coin. If heads, prevent that damage."),
  ("sv8-151", "Bouffalant", "not modelled (Known gaps, MV2): history: next-turn trigger on this Pokémon: During your opponent's next turn, if this Pokémon is damaged by an attack (even if this Pokémon is Knocked Out), put 6 damage counters on the Attacking Pokémon."),
  ("sv8-156", "Oranguru", "unhandled sentence: Until the end of your next turn, the Defending Pokémon's Weakness is now Colorless."),
  ("sv8-158", "Maushold", "Bench placement of a named card that is not a Basic Pokémon (putBench is Basic-only): Search your deck for up to 2 in any combination of Maushold and Maushold ex and put them onto your Bench."),
  ("sv8-160", "Flamigo ex", "condition not expressible: this Pokémon and your opponent's Active Pokémon have the same amount of Energy attached: If this Pokémon and your opponent's Active Pokémon have the same amount of Energy attached, this attack does 100 more damage."),
  ("sv8-161", "Terapagos", "unhandled sentence: Search your deck for up to 3 Basic Energy cards of different types and attach them to your Tera Pokémon in any way you like."),
  ("sv8-163", "Babiri Berry", "Pokémon Tool: triggered: If the Pokémon this card is attached to is damaged by an attack from your opponent's Metal Pokémon, it takes 60 less damage (after applying Weakness and Resistance), and discard this card."),
  ("sv8-165", "Call Bell", "unhandled sentence: You can use this card only if you go second, and only during your first turn."),
  ("sv8-166", "Chill Teaser Toy", "unhandled sentence: You can use this card only if you go second, and only during your first turn."),
  ("sv8-167", "Clemont's Quick Wit", "unhandled sentence: Heal 60 damage from each of your Lightning Pokémon."),
  ("sv8-168", "Colbur Berry", "Pokémon Tool: triggered: If the Pokémon this card is attached to is damaged by an attack from your opponent's Darkness Pokémon, it takes 60 less damage (after applying Weakness and Resistance), and discard this card."),
  ("sv8-169", "Counter Gain", "Pokémon Tool: static, cost (attack cost or Energy provision): If you have more Prize cards remaining than your opponent, attacks used by the Pokémon this card is attached to cost Colorless less."),
  ("sv8-172", "Dragon Elixir", "unhandled sentence: Heal 60 damage from your Active Dragon Pokémon."),
  ("sv8-174", "Drayton", "card kind with no filter: Pokémon and a Trainer: Look at the top 7 cards of your deck."),
  ("sv8-176", "Energy Search Pro", "unhandled sentence: Search your deck for any number of Basic Energy cards of different types, reveal them, and put them into your hand."),
  ("sv8-179", "Lisia's Appeal", "unhandled sentence: Switch in 1 of your opponent's Benched Basic Pokémon to the Active Spot."),
  ("sv8-181", "Meddling Memo", "unhandled sentence: Your opponent counts the cards in their hand, shuffles those cards, and puts them on the bottom of their deck."),
  ("sv8-182", "Megaton Blower", "unhandled sentence: Discard all Pokémon Tools and Special Energy from all of your opponent's Pokémon, and discard a Stadium in play."),
  ("sv8-184", "Passho Berry", "Pokémon Tool: triggered: If the Pokémon this card is attached to is damaged by an attack from your opponent's Water Pokémon, it takes 60 less damage (after applying Weakness and Resistance), and discard this card."),
  ("sv8-186", "Scramble Switch", "unhandled sentence: You may move any amount of Energy from the Pokémon you moved to your Bench to the new Active Pokémon."),
  ("sv8-188", "Technical Machine: Fluorite", "Pokémon Tool: text besides the attack grant (end-of-turn discard): (You still need the necessary Energy to use this attack. If this card is attached to 1 of your Pokémon, discard it at the end of your turn."),
  ("sv8-190", "Tyme", "unhandled sentence: Tell your opponent the name of a Pokémon in your hand and put that Pokémon face down in front of you."),
  ("sv8-191", "Enriching Energy", "Special Energy: rider not modelled: on-attach effect (stage 4 of MV8, not done): When you attach this card from your hand to a Pokémon, draw 4 cards."),
  ("sv8-252", "Jet Energy", "Special Energy: rider not modelled: on-attach effect (stage 4 of MV8, not done): When you attach this card from your hand to 1 of your Benched Pokémon, switch that Pokémon with your Active Pokémon."),
  ("sv8pt5-6", "Leafeon ex", "unhandled sentence: Heal 100 damage from each of your Benched Pokémon."),
  ("sv8pt5-12", "Teal Mask Ogerpon ex", "condition not expressible: you attached Energy to a Pokémon in this way: If you attached Energy to a Pokémon in this way, draw a card."),
  ("sv8pt5-14", "Flareon ex", "several cards to one chosen Pokémon: Search your deck for up to 2 Basic Energy cards and attach them to 1 of your Pokémon."),
  ("sv8pt5-19", "Slowking", "unhandled sentence: You may put 2 Energy attached to your opponent's Active Pokémon into their hand."),
  ("sv8pt5-21", "Seaking", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If Festival Grounds is in play, this Pokémon may use an attack it has twice. If the first attack Knocks Out your opponent's Active Pokémon, you may attack again after your opponent chooses a new Active Pokémon."),
  ("sv8pt5-26", "Glaceon ex", "unhandled sentence: Knock Out 1 of your opponent's Pokémon that has exactly 6 damage counters on it."),
  ("sv8pt5-27", "Wellspring Mask Ogerpon ex", "unhandled sentence: You may shuffle 3 Energy attached to this Pokémon into your deck."),
  ("sv8pt5-30", "Jolteon ex", "unhandled sentence: You may discard up to 2 Basic Energy from your Benched Pokémon."),
  ("sv8pt5-34", "Espeon ex", "unhandled sentence: Devolve each of your opponent's evolved Pokémon by shuffling the highest Stage Evolution card on it into your opponent's deck."),
  ("sv8pt5-60", "Umbreon ex", "unhandled sentence: Discard all Energy from this Pokémon, and take a Prize card."),
  ("sv8pt5-75", "Eevee ex", "Ability: static (first-turn rule): This Pokémon can evolve into any Pokémon ex that evolves from Eevee if you play it from your hand onto this Pokémon. (This Pokémon can't evolve during your first turn or the turn you play it.)"),
  ("sv8pt5-77", "Hoothoot", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): This Pokémon can't be Asleep."),
  ("sv8pt5-92", "Terapagos ex", "condition not expressible: you go second: If you go second, you can't use this attack during your first turn."),
  ("sv8pt5-93", "Amarys", "unhandled sentence: At the end of this turn, if you have 5 or more cards in your hand, discard your hand."),
  ("sv8pt5-96", "Black Belt's Training", "unhandled sentence: During this turn, attacks used by your Pokémon do 40 more damage to your opponent's Active Pokémon ex (before applying Weakness and Resistance)."),
  ("sv8pt5-108", "Festival Grounds", "Stadium: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Each Pokémon that has any Energy attached (both yours and your opponent's) recovers from all Special Conditions and can't be affected by any Special Conditions."),
  ("sv8pt5-111", "Haban Berry", "Pokémon Tool: triggered: If the Pokémon this card is attached to is damaged by an attack from your opponent's Dragon Pokémon, it takes 60 less damage (after applying Weakness and Resistance), and discard this card."),
  ("sv9-2", "Metapod", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks if that damage is 60 or less."),
  ("sv9-34", "Octillery", "unhandled sentence: You may put an Energy attached to your opponent's Active Pokémon into their hand."),
  ("sv9-37", "Ludicolo", "Ability: static, stack (stacking rule (\"doesn't stack\"): the model adds every effect in force): All of your Pokémon in play get +40 HP. The effect of Vibrant Dance doesn't stack."),
  ("sv9-43", "Veluza ex", "unhandled sentence: You may discard your hand."),
  ("sv9-47", "Iono's Voltorb", "count not expressible: Lightning Energy attached to all of your Iono's Pokémon: This attack does 20 more damage for each Lightning Energy attached to all of your Iono's Pokémon."),
  ("sv9-49", "N's Joltik", "condition not expressible: you discarded a Pokémon Tool in this way: If you discarded a Pokémon Tool in this way, your opponent's Active Pokémon is now Paralyzed."),
  ("sv9-50", "Togedemaru", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv9-55", "Iono's Kilowattrel", "Ability: cost not expressible: discard a Basic Lightning Energy from this Pokémon: You must discard a Basic Lightning Energy from this Pokémon in order to use this Ability. Once during your turn, you may draw cards until you have 6 cards in your hand."),
  ("sv9-56", "Lillie's Clefairy ex", "Ability: static, typeWeak (a change of type or Weakness): The Weakness of each of your opponent's Dragon Pokémon in play is now Psychic. (Apply Weakness as ×2.)"),
  ("sv9-58", "Mr. Mime", "unhandled sentence: Then, draw a card for each card in your opponent's hand."),
  ("sv9-60", "Banette", "unhandled sentence: Your opponent chooses 3 cards from their hand and shuffles those cards into their deck."),
  ("sv9-64", "N's Sigilyph", "condition not expressible: you use this attack when you have exactly 1 Prize card remaining: If you use this attack when you have exactly 1 Prize card remaining, you win this game."),
  ("sv9-68", "Lillie's Comfey", "unhandled sentence: You may search your deck for any number of Basic Lillie's Pokémon and put them onto your Bench."),
  ("sv9-95", "Tyranitar", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): As long as this Pokémon is in the Active Spot, your opponent can't play any Item cards from their hand."),
  ("sv9-98", "N's Zoroark ex", "unhandled sentence: Choose 1 of your Benched N's Pokémon's attacks and use it as this attack."),
  ("sv9-99", "Pangoro", "unhandled sentence: Choose 1 of your opponent's Active Pokémon's attacks."),
  ("sv9-107", "Magearna", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): As long as this Pokémon is in the Active Spot, whenever you attach an Energy card from your hand to 1 of your Pokémon, heal 90 damage from that Pokémon."),
  ("sv9-117", "Hop's Snorlax", "Ability: static, stack (stacking rule (\"doesn't stack\"): the model adds every effect in force): Attacks used by your Hop's Pokémon do 30 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance). The effect of Extra Helpings doesn't stack."),
  ("sv9-122", "Kecleon", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv9-128", "Noivern", "Ability: static, cost (attack cost or Energy provision): If you have the same number of cards in your hand as your opponent, ignore all Energy in the cost of Frightening Howl used by this Pokémon."),
  ("sv9-129", "Komala", "unhandled sentence: Both Active Pokémon are now Asleep."),
  ("sv9-142", "Billy & O'Nare", "unhandled sentence: Then, if you have 10 or more cards in your hand, draw 2 more cards."),
  ("sv9-148", "Hop's Choice Band", "Pokémon Tool: static, cost (attack cost or Energy provision): Attacks used by the Hop's Pokémon this card is attached to cost Colorless less and do 30 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."),
  ("sv9-151", "Lillie's Pearl", "Pokémon Tool: triggered (M8b shape), changes the Prize cards taken: If the Lillie's Pokémon this card is attached to is Knocked Out by damage from an attack from your opponent's Pokémon, that player takes 1 fewer Prize card."),
  ("sv9-152", "N's Castle", "Stadium: static, noRetreat (\"has no Retreat Cost\" in a form not read (a condition or holder outside the forms of SEff.noRetreat)): N's Pokémon in play (both yours and your opponent's) have no Retreat Cost."),
  ("sv9-153", "N's PP Up", "unhandled sentence: Attach a Basic Energy card from your discard pile to 1 of your Benched N's Pokémon."),
  ("sv9-156", "Redeemable Ticket", "unhandled sentence: Count your Prize cards, shuffle them, and put them on the bottom of your deck."),
  ("sv9-157", "Ruffian", "Tool and Special Energy from the same Benched Pokémon (two primitives choose separately): Discard a Pokémon Tool and a Special Energy from 1 of your opponent's Pokémon."),
  ("sv9-158", "Super Potion", "condition not expressible: you healed any damage in this way: If you healed any damage in this way, discard an Energy from that Pokémon."),
  ("sv10-1", "Ethan's Pinsir", "condition not expressible: Knock Out record of a kind of Pokémon (Count.koLast records any): any of your Ethan's Pokémon were Knocked Out by damage from an attack during your opponent's last turn: If any of your Ethan's Pokémon were Knocked Out by damage from an attack during your opponent's last turn, this attack does 100 more damage."),
  ("sv10-3", "Yanmega ex", "unhandled sentence: Move 3 Energy from this Pokémon to 1 of your Benched Pokémon."),
  ("sv10-10", "Shaymin", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all damage done to your Benched Pokémon that don't have a Rule Box by attacks from your opponent's Pokémon. (Pokémon ex, Pokémon V, etc. have Rule Boxes.)"),
  ("sv10-11", "Dwebble", "unhandled sentence: Search your deck for a card that evolves from this Pokémon and put it onto this Pokémon to evolve it."),
  ("sv10-15", "Team Rocket's Blipbug", "unhandled sentence: Look at 1 of your opponent's face-down Prize cards."),
  ("sv10-17", "Dipplin", "unhandled sentence: Put an Energy attached to this Pokémon into your hand."),
  ("sv10-23", "Arboliva ex", "unhandled sentence: Choose 1 of your opponent's Pokémon 6 times."),
  ("sv10-31", "Team Rocket's Moltres ex", "unhandled sentence: Discard a Team Rocket's Energy from this Pokémon."),
  ("sv10-36", "Ethan's Magcargo", "Ability: static, noRetreat (\"has no Retreat Cost\" in a form not read (a condition or holder outside the forms of SEff.noRetreat)): If this Pokémon has no Energy attached, it has no Retreat Cost."),
  ("sv10-39", "Ethan's Ho-Oh ex", "several cards to one chosen Pokémon: Attach up to 2 Basic Fire Energy cards from your hand to 1 of your Benched Ethan's Pokémon."),
  ("sv10-45", "Misty's Psyduck", "Ability: returns its Pokémon from play: Once during your turn, if this Pokémon is on your Bench, you may discard the bottom card of your deck. If you do, discard all cards from this Pokémon and put this Pokémon on top of your deck."),
  ("sv10-48", "Misty's Magikarp", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): As long as this Pokémon is on your Bench, prevent all damage from and effects of attacks from your opponent's Pokémon done to this Pokémon."),
  ("sv10-49", "Misty's Gyarados", "unhandled sentence: Discard the top 7 cards of your deck, and this attack does 70 damage for each Misty's Pokémon that you discarded in this way."),
  ("sv10-51", "Team Rocket's Articuno", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all effects of attacks used by your opponent's Pokémon done to your Basic Team Rocket's Pokémon. (Existing effects are not removed. Damage is not an effect.)"),
  ("sv10-52", "Cynthia's Feebas", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv10-55", "Huntail", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): When 1 of your Water Pokémon is Knocked Out by damage from an attack from your opponent's Pokémon, you may put all Basic Water Energy attached to that Pokémon into your hand instead of the discard pile."),
  ("sv10-56", "Gorebyss", "unhandled sentence: Before doing damage, you may attach any number of Basic Water Energy cards from your hand to this Pokémon."),
  ("sv10-61", "Wash Rotom", "unhandled sentence: Heal 10 damage from each of your Pokémon."),
  ("sv10-63", "Barraskewda", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("sv10-65", "Cetitan ex", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): Whenever your opponent plays an Item or Supporter card from their hand, prevent all effects of that card done to this Pokémon."),
  ("sv10-66", "Dondozo ex", "unhandled sentence: You may do 120 more damage."),
  ("sv10-74", "Team Rocket's Ampharos", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): Whenever your opponent plays a Pokémon from their hand to evolve 1 of their Pokémon, put 4 damage counters on that Pokémon. The effect of Darkest Impulse doesn't stack."),
  ("sv10-81", "Team Rocket's Mewtwo ex", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): This Pokémon can't attack unless you have 4 or more Team Rocket's Pokémon in play."),
  ("sv10-82", "Team Rocket's Wobbuffet", "unhandled sentence: Move all damage counters from 1 of your Benched Team Rocket's Pokémon to your opponent's Active Pokémon."),
  ("sv10-86", "Steven's Carbink", "Ability: static, stack (stacking rule (\"doesn't stack\"): the model adds every effect in force): As long as this Pokémon is on your Bench, all of your Steven's Pokémon take 30 less damage from attacks from your opponent's Pokémon (after applying Weakness and Resistance). The effect of Stone Palace doesn't stack."),
  ("sv10-87", "Team Rocket's Mimikyu", "unhandled sentence: Choose 1 of your opponent's Active Tera Pokémon's attacks and use it as this attack."),
  ("sv10-89", "Team Rocket's Orbeetle", "unhandled sentence: Move 1 damage counter from 1 of your Team Rocket's Pokémon to another of your Pokémon."),
  ("sv10-92", "Annihilape", "Ability: static, readsHp (reads HP or damage): If this Pokémon has 2 or more damage counters on it, attacks used by this Pokémon do 120 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."),
  ("sv10-93", "Ethan's Sudowoodo", "unhandled sentence: Choose 1 of your opponent's Active Pokémon's attacks and use it as this attack."),
  ("sv10-95", "Team Rocket's Pupitar", "unhandled sentence: Search your deck for a card that evolves from this Pokémon and put it onto this Pokémon to evolve it."),
  ("sv10-96", "Team Rocket's Tyranitar", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): During Pokémon Checkup, if this Pokémon is in the Active Spot, put 2 damage counters on each of your opponent's Basic Pokémon."),
  ("sv10-98", "Probopass", "condition not expressible: a Stadium is in play: If a Stadium is in play, this attack does 70 more damage."),
  ("sv10-100", "Medicham", "condition not expressible: this Pokémon and your opponent's Active Pokémon have the same amount of Energy attached: If this Pokémon and your opponent's Active Pokémon have the same amount of Energy attached, this attack does 120 more damage."),
  ("sv10-106", "Hippowdon", "not modelled (Known gaps, MV2): spread: target filtered by its damage: This attack also does 40 damage to each Benched Pokémon that has any damage counters on it (both yours and your opponent's)."),
  ("sv10-113", "Team Rocket's Arbok", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): As long as this Pokémon is in the Active Spot, your opponent can't play any Pokémon that has an Ability from their hand, except for Team Rocket's Pokémon."),
  ("sv10-115", "Team Rocket's Nidorina", "unhandled sentence: Choose up to 2 of your Darkness Pokémon."),
  ("sv10-122", "Team Rocket's Crobat ex", "unhandled sentence: Choose 2 of your opponent's Pokémon and put 2 damage counters on each of them."),
  ("sv10-123", "Team Rocket's Grimer", "unhandled sentence: At the end of your opponent's next turn, discard the Defending Pokémon and all attached cards."),
  ("sv10-127", "Team Rocket's Murkrow", "unhandled sentence: Choose 1 of your opponent's Active Pokémon's attacks."),
  ("sv10-128", "Team Rocket's Sneasel", "not modelled (Known gaps, MV2): spread: amount computed by the text: This attack does 20 damage to 1 of your opponent's Benched Pokémon for each damage counter on that Pokémon."),
  ("sv10-129", "Cynthia's Spiritomb", "count not expressible: damage counter on all of your Benched Cynthia's Pokémon: This attack does 10 damage for each damage counter on all of your Benched Cynthia's Pokémon."),
  ("sv10-136", "Marnie's Grimmsnarl ex", "unhandled sentence: Search your deck for up to 5 Basic Darkness Energy cards and attach them to your Marnie's Pokémon in any way you like."),
  ("sv10-140", "Forretress", "unhandled sentence: You may move any amount of Metal Energy from your Pokémon to your other Pokémon in any way you like."),
  ("sv10-145", "Steven's Metagross ex", "unhandled sentence: Search your deck for a Basic Psychic Energy card, a Basic Metal Energy card, or 1 of each and attach them to your Psychic Pokémon and Metal Pokémon in any way you like."),
  ("sv10-146", "Zamazenta", "not modelled (Known gaps, MV2): history: next-turn trigger on this Pokémon: During your opponent's next turn, if this Pokémon is damaged by an attack (even if this Pokémon is Knocked Out), put damage counters on the Attacking Pokémon equal to the damage done to this Pokémon."),
  ("sv10-150", "Team Rocket's Persian ex", "unhandled sentence: Reveal the top 10 cards of your opponent's deck."),
  ("sv10-161", "Arven's Sandwich", "condition not expressible: that Pokémon is an Arven's Pokémon: If that Pokémon is an Arven's Pokémon, heal 100 damage from it instead."),
  ("sv10-170", "Team Rocket's Archer", "unhandled sentence: You can use this card only if any of your Team Rocket's Pokémon were Knocked Out during your opponent's last turn."),
  ("sv10-172", "Team Rocket's Bother-Bot", "unhandled sentence: Turn 1 of your opponent's face-down Prize cards face up and choose a random card from your opponent's hand."),
  ("sv10-173", "Team Rocket's Factory", "Stadium: activated effect not expressible: a condition on the history of the turn: Once during each player's turn, if they played a Supporter card that has \"Team Rocket\" in its name from their hand this turn, they may draw 2 cards."),
  ("sv10-174", "Team Rocket's Giovanni", "unhandled sentence: Switch your Active Team Rocket's Pokémon with 1 of your Benched Team Rocket's Pokémon."),
  ("sv10-177", "Team Rocket's Proton", "condition not expressible: you go first: If you go first, you may use this card during your first turn."),
  ("sv10-180", "Team Rocket's Watchtower", "Stadium: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): Colorless Pokémon in play (both yours and your opponent's) have no Abilities."),
  ("sv10-243", "Jamming Tower", "Stadium: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): Pokémon Tools attached to each Pokémon (both yours and your opponent's) have no effect."),
  ("rsv10pt5-3", "Leavanny", "unhandled sentence: Heal 100 damage from each of your Basic Pokémon."),
  ("rsv10pt5-8", "Shelmet", "Ability: static (first-turn rule): If you have Karrablast in play, this Pokémon can evolve during your first turn or the turn you play it."),
  ("rsv10pt5-24", "Basculin", "condition not expressible: your opponent's Active Pokémon has no damage counters on it before this attack does damage: If your opponent's Active Pokémon has no damage counters on it before this attack does damage, this attack does nothing."),
  ("rsv10pt5-37", "Swoobat", "unhandled sentence: Put 1 of your Benched Pokémon and all attached cards into your hand."),
  ("rsv10pt5-40", "Cofagrigus", "unhandled sentence: Move all damage counters from 1 of your Benched Pokémon to 1 of your opponent's Pokémon."),
  ("rsv10pt5-43", "Gothitelle", "condition not expressible: you have the same number of cards in your hand as your opponent: If you have the same number of cards in your hand as your opponent, this attack does 90 more damage."),
  ("rsv10pt5-45", "Jellicent ex", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): As long as this Pokémon is in the Active Spot, your opponent can't play any Item cards or Pokémon Tool cards from their hand."),
  ("rsv10pt5-46", "Roggenrola", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks if that damage is 40 or less."),
  ("rsv10pt5-48", "Gigalith", "count not expressible: damage counter on all of your Benched Fighting Pokémon: This attack does 20 damage for each damage counter on all of your Benched Fighting Pokémon."),
  ("rsv10pt5-51", "Archeops", "unhandled sentence: Devolve 1 of your opponent's evolved Pokémon by putting the highest Stage Evolution card on it into your opponent's hand."),
  ("rsv10pt5-62", "Zoroark", "unhandled sentence: Choose 1 of your opponent's Active Pokémon's attacks and use it as this attack."),
  ("rsv10pt5-67", "Hydreigon ex", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If your opponent's Basic Pokémon is Knocked Out by damage from an attack used by this Pokémon, take 1 more Prize card."),
  ("rsv10pt5-69", "Ferrothorn", "not modelled (Known gaps, MV2): spread: amount computed by the text: This attack does 20 damage to 1 of your opponent's Pokémon for each Energy attached to this Pokémon."),
  ("rsv10pt5-76", "Stoutland", "coin flips not expressible: Flip 3 coins. Put a number of cards up to the number of heads from your discard pile into your hand."),
  ("rsv10pt5-79", "Antique Plume Fossil", "Trainer played as a Pokémon"),
  ("rsv10pt5-85", "Tool Scrapper", "unhandled sentence: Choose up to 2 Pokémon Tools attached to Pokémon (yours or your opponent's) and discard them."),
  ("rsv10pt5-86", "Ignition Energy", "Special Energy: rider not modelled: end-of-turn discard (stage 4 of MV8, not done): If this card is attached to 1 of your Pokémon, discard it at the end of your turn."),
  ("zsv10pt5-6", "Petilil", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("zsv10pt5-8", "Maractus", "not modelled (Known gaps, MV2): history: healed this turn: If this Pokémon was healed during this turn, this attack does 100 more damage."),
  ("zsv10pt5-9", "Karrablast", "Ability: static (first-turn rule): If you have Shelmet in play, this Pokémon can evolve during your first turn or the turn you play it."),
  ("zsv10pt5-23", "Carracosta", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all damage from and effects of attacks done to this Pokémon by your opponent's Pokémon that have any Special Energy attached."),
  ("zsv10pt5-28", "Kyurem ex", "unhandled sentence: This attack also does 10 damage to each of your opponent's Benched Pokémon for each Prize card your opponent has taken."),
  ("zsv10pt5-35", "Munna", "unhandled sentence: This Pokémon is now Asleep."),
  ("zsv10pt5-36", "Musharna", "unhandled sentence: You may search your deck for any number of Fennel cards, reveal them, and put them into your hand."),
  ("zsv10pt5-38", "Duosion", "unhandled sentence: Search your deck for a card that evolves from 1 of your Pokémon and put it onto that Pokémon to evolve it."),
  ("zsv10pt5-39", "Reuniclus", "unhandled sentence: For each of your Benched Pokémon, search your deck for a card that evolves from that Pokémon and put it onto that Pokémon to evolve it."),
  ("zsv10pt5-44", "Meloetta ex", "Ability: static (first-turn rule): If you go first, this Pokémon can use attacks during your first turn."),
  ("zsv10pt5-46", "Excadrill ex", "not modelled (Known gaps, MV2): spread: target filtered by its damage: This attack also does 60 damage to 1 of your opponent's Benched Pokémon that has any damage counters on it."),
  ("zsv10pt5-52", "Crustle", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If this Pokémon has full HP and would be Knocked Out by damage from an attack, it is not Knocked Out, and its remaining HP becomes 10."),
  ("zsv10pt5-72", "Tranquill", "condition not expressible: heads: If heads, during your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("zsv10pt5-73", "Unfezant", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("zsv10pt5-82", "Fennel", "unhandled sentence: Heal 40 damage from each of your Pokémon."),
  ("zsv10pt5-83", "N's Plan", "unhandled sentence: Move up to 2 Energy from your Benched Pokémon to your Active Pokémon."),
  ("me1-10", "Meganium", "Ability: static, stack (stacking rule (\"doesn't stack\"): the model adds every effect in force): Each Basic Grass Energy attached to all of your Pokémon provides GrassGrass Energy. The effect of Wild Growth doesn't stack."),
  ("me1-11", "Shuckle", "Ability: condition on this Pokémon, which may be on the Bench: this Pokémon has any Grass Energy attached: Once during your turn, if this Pokémon has any Grass Energy attached, you may use this Ability. Heal 30 damage from 1 of your Pokémon."),
  ("me1-15", "Shiftry", "unhandled sentence: Choose 1 of your opponent's Pokémon."),
  ("me1-17", "Ninjask", "Bench placement of a named card that is not a Basic Pokémon (putBench is Basic-only): Search your deck for a Shedinja and put it onto your Bench."),
  ("me1-18", "Dhelmise", "condition not expressible: you have a Stadium in play: If you have a Stadium in play, this attack does 50 more damage."),
  ("me1-20", "Ninetales", "unhandled sentence: Discard the top card of your deck, and if that card is a Supporter card, use the effect of that card as the effect of this attack."),
  ("me1-24", "Pyroar", "Ability: static, oppLess (the opponent's attacks do less damage before Weakness and Resistance (the model's static reduction is at step 5)): As long as this Pokémon is in the Active Spot, attacks used by your opponent's Active Pokémon do 30 less damage (before applying Weakness and Resistance)."),
  ("me1-25", "Volcanion", "unhandled sentence: Put 2 Fire Energy attached to this Pokémon into your hand."),
  ("me1-28", "Cinderace", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If this Pokémon is in your hand when you are setting up to play, you may put it face down in the Active Spot."),
  ("me1-31", "Chi-Yu", "condition not expressible: your opponent has a Stadium in play: If your opponent has a Stadium in play, discard it."),
  ("me1-34", "Kyogre", "unhandled sentence: Then, shuffle those cards into your deck."),
  ("me1-36", "Mega Abomasnow ex", "unhandled sentence: Discard the top 6 cards of your deck, and this attack does 100 damage for each Basic Water Energy card that you discarded in this way."),
  ("me1-41", "Inteleon", "unhandled sentence: Choose a Pokémon in play (yours or your opponent's) that has the least HP remaining, except for this Pokémon, and it is Knocked Out."),
  ("me1-42", "Snom", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me1-50", "Mega Manectric ex", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Basic Pokémon."),
  ("me1-51", "Pachirisu", "unhandled sentence: During your opponent's next turn, whenever they attach an Energy card from their hand to the Defending Pokémon, place 8 damage counters on that Pokémon."),
  ("me1-56", "Alakazam", "unhandled sentence: Place 2 damage counters on your opponent's Active Pokémon for each card in your hand."),
  ("me1-60", "Mega Gardevoir ex", "unhandled sentence: For each of your Benched Pokémon, search your deck for a Basic Psychic Energy card and attach it to that Pokémon."),
  ("me1-61", "Shedinja", "Ability: triggered (M8b shape), changes the Prize cards taken: If this Pokémon is Knocked Out by damage from an attack from your opponent's Pokémon ex, your opponent can't take any Prize cards for it."),
  ("me1-69", "Sandslash", "unhandled sentence: During your opponent's next turn, if the Defending Pokémon tries to use an attack, your opponent flips a coin."),
  ("me1-80", "Marshadow", "condition not expressible: your opponent's Pokémon is Knocked Out by damage from this attack: If your opponent's Pokémon is Knocked Out by damage from this attack, during your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me1-85", "Crawdaunt", "unhandled sentence: This attack can be used for Darkness."),
  ("me1-87", "Spiritomb", "Ability: triggered (M8b shape), fires on another Pokémon's event (your Active Pokémon of a type or name): If your Active Darkness Pokémon is damaged by an attack from your opponent's Pokémon (even if your Active Darkness Pokémon is Knocked Out), place 1 damage counter on the Attacking Pokémon."),
  ("me1-92", "Grafaiai", "unhandled sentence: Choose a Special Condition."),
  ("me1-94", "Mega Mawile ex", "unhandled sentence: This attack's base damage is 30."),
  ("me1-95", "Dialga", "unhandled sentence: You may shuffle all Energy attached to this Pokémon into your deck and have this attack do 80 more damage."),
  ("me1-99", "Gholdengo", "flip until tails not expressible: Flip a coin until you get tails. Search your deck for a number of cards up to the number of heads and put them into your hand."),
  ("me1-101", "Latios", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): Once during your turn, when your Mega Latias ex moves from your Bench to the Active Spot, you may use this Ability. Move any amount of Energy from your Benched Pokémon to your Active Pokémon."),
  ("me1-105", "Delibird", "condition not expressible: you go first: If you go first, you can use this attack during your first turn."),
  ("me1-106", "Miltank", "unhandled sentence: Heal all damage from 1 of your Pokémon."),
  ("me1-110", "Gumshoos", "unhandled sentence: Switch a card from your hand with the top card of your deck."),
  ("me1-113", "Acerola's Mischief", "unhandled sentence: Choose 1 of your Pokémon in play."),
  ("me1-117", "Forest of Vitality", "Stadium: static, evolve (evolution rules): Each player's Grass Pokémon can evolve into Grass Pokémon during the turn they play those Pokémon, except during their first turn."),
  ("me1-118", "Iron Defender", "unhandled sentence: During your opponent's next turn, all of your Metal Pokémon take 30 less damage from attacks from your opponent's Pokémon (after applying Weakness and Resistance)."),
  ("me1-120", "Lt. Surge's Bargain", "unhandled sentence: Ask your opponent if each player may take a Prize card."),
  ("me1-122", "Mystery Garden", "Stadium: activated effect not expressible: unhandled sentence: Once during each player's turn, that player may discard an Energy card from their hand in order to draw cards until they have as many cards in their hand as they have Psychic Pokémon in play."),
  ("me1-123", "Pokémon Center Lady", "unhandled sentence: Heal 60 damage from 1 of your Pokémon, and it recovers from all Special Conditions."),
  ("me1-124", "Premium Power Pro", "unhandled sentence: During this turn, attacks used by your Fighting Pokémon do 30 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."),
  ("me1-125", "Rare Candy", "unhandled sentence: Choose 1 of your Basic Pokémon in play."),
  ("me1-127", "Risky Ruins", "Stadium: triggered: Whenever any player puts a Basic non-Darkness Pokémon onto their Bench during their turn, place 2 damage counters on that Pokémon."),
  ("me1-128", "Strange Timepiece", "unhandled sentence: Devolve 1 of your evolved Psychic Pokémon by putting any number of Evolution cards on it into your hand."),
  ("me1-129", "Surfing Beach", "Stadium: activated effect not expressible: unhandled sentence: Once during each player's turn, that player may switch their Active Water Pokémon with 1 of their Benched Water Pokémon."),
  ("me1-132", "Wally's Compassion", "unhandled sentence: Heal all damage from 1 of your Mega Evolution Pokémon ex."),
  ("me2-3", "Vileplume", "not modelled (Known gaps, MV2): history: healed this turn: If this Pokémon was healed during this turn, this attack does 120 more damage."),
  ("me2-4", "Mega Heracross ex", "not modelled (Known gaps, MV2): history: counted (damage or Prize cards of last turn): If this Pokémon was damaged by an attack during your opponent's last turn, this attack does that much more damage."),
  ("me2-7", "Ludicolo", "Ability: condition not expressible: you have any Grass Mega Evolution Pokémon ex in play: Once during your turn, if you have any Grass Mega Evolution Pokémon ex in play, you may use this Ability. Heal 60 damage from 1 of your Pokémon."),
  ("me2-8", "Genesect", "not modelled (Known gaps, MV2): spread: amount computed by the text: This attack does 20 damage to 1 of your opponent's Pokémon for each Grass Energy attached to this Pokémon."),
  ("me2-10", "Lokix", "unhandled sentence: Shuffle this Pokémon and all attached cards into your deck."),
  ("me2-11", "Charmander", "Ability: static, noRetreat (\"has no Retreat Cost\" in a form not read (a condition or holder outside the forms of SEff.noRetreat)): If this Pokémon has no Energy attached, it has no Retreat Cost."),
  ("me2-13", "Mega Charizard X ex", "unhandled sentence: Discard any amount of Fire Energy from among your Pokémon, and this attack does 90 damage for each card you discarded in this way."),
  ("me2-18", "Oricorio ex", "Ability: condition not expressible: you have any Fire Mega Evolution Pokémon ex in play: As often as you like during your turn, if you have any Fire Mega Evolution Pokémon ex in play, you may use this Ability. Attach a Basic Fire Energy card from your hand to 1 of your Benched Fire Pokémon."),
  ("me2-25", "Mamoswine", "condition not expressible: a Stadium is in play: If a Stadium is in play, this attack does 120 more damage."),
  ("me2-29", "Rotom ex", "Ability: static, toolCount (the number of Tools): Each of your Pokémon that has \"Rotom\" in its name may have up to 2 Pokémon Tool cards attached. If this Ability goes away, discard Pokémon Tools from those Pokémon until only 1 remains on each."),
  ("me2-40", "Meloetta", "unhandled sentence: Heal 120 damage from 1 of your Benched Psychic Pokémon."),
  ("me2-48", "Paldean Tauros", "count not expressible: of your Pokémon that has \"Tauros\" in its name that has any damage counters on it: This attack does 40 damage for each of your Pokémon that has \"Tauros\" in its name that has any damage counters on it."),
  ("me2-56", "Mega Gengar ex", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If 1 of your Darkness Pokémon is Knocked Out by damage from an attack from your opponent's Pokémon ex, that player takes 1 fewer Prize card. The effect of Shadowy Concealment doesn't stack."),
  ("me2-62", "Seviper", "Ability: static, cond (a condition the model cannot test statically (Prize cards, the hand, other Pokémon in play, Special Conditions, Special Energy, Tools, damage)): If you have any Darkness Mega Evolution Pokémon ex in play, attacks used by this Pokémon do 120 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."),
  ("me2-68", "Toxtricity", "condition not expressible: you attached Energy to a Pokémon in this way: If you attached Energy to a Pokémon in this way, place 2 damage counters on that Pokémon."),
  ("me2-70", "Empoleon ex", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all effects of attacks used by your opponent's Pokémon done to this Pokémon. (Damage is not an effect.)"),
  ("me2-75", "Archaludon", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Basic Pokémon."),
  ("me2-80", "Smeargle", "coin flips not expressible: Flip 3 coins. Attach an amount of Basic Energy up to the number of heads from your discard pile to your Benched Pokémon in any way you like."),
  ("me2-85", "Battle Cage", "Stadium: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all damage counters from being placed on Benched Pokémon (both yours and your opponent's) by effects of attacks and Abilities from the opponent's Pokémon. (Damage from attacks is still taken.)"),
  ("me2-86", "Blowtorch", "unhandled sentence: You can use this card only if you discard a Basic Fire Energy card from your hand."),
  ("me2-88", "Dizzying Valley", "Stadium: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Confused Pokémon (both yours and your opponent's) don't recover from that Special Condition when they evolve or devolve."),
  ("me2-90", "Grimsley's Move", "unhandled sentence: Look at the top 7 cards of your deck and put a Darkness Pokémon you find there onto your Bench."),
  ("me2-91", "Jumbo Ice Cream", "unhandled sentence: Heal 80 damage from your Active Pokémon that has 3 or more Energy attached."),
  ("me2-93", "Sacred Charm", "Pokémon Tool: static, filter (a filter the model has not (name prefix, Ancient, Future, Tera, \"has an Ability\", Mega Evolution Pokémon ex)): The Pokémon this card is attached to takes 30 less damage from attacks from your opponent's Pokémon that have an Ability (after applying Weakness and Resistance)."),
  ("me2pt5-3", "Erika's Vileplume ex", "unhandled sentence: Heal 30 damage from each of your Pokémon."),
  ("me2pt5-12", "Silcoon", "Bench placement of a named card that is not a Basic Pokémon (putBench is Basic-only): Search your deck for a Silcoon or a Cascoon and put it onto your Bench."),
  ("me2pt5-15", "Dustox", "unhandled sentence: Put an Energy attached to your opponent's Active Pokémon into their hand."),
  ("me2pt5-39", "Psyduck", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): Pokémon in play (both yours and your opponent's) lose any Ability that requires the Pokémon using it to Knock Out itself."),
  ("me2pt5-40", "Golduck", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): Pokémon in play (both yours and your opponent's) lose any Ability that requires the Pokémon using it to Knock Out itself."),
  ("me2pt5-51", "N's Vanilluxe", "unhandled sentence: Double the number of damage counters on each of your opponent's Pokémon."),
  ("me2pt5-61", "Mega Eelektross ex", "unhandled sentence: You may discard 2 Lightning Energy from this Pokémon and make your opponent's Active Pokémon Paralyzed."),
  ("me2pt5-64", "Heliolisk", "Ability: condition on the history of the turn (this turn, last turn): Once during your turn, if you played Canari from your hand this turn, you may use this Ability. Search your deck for up to 2 Basic Lightning Energy cards and attach them to this Pokémon. Then, shuffle your deck."),
  ("me2pt5-67", "Tapu Koko", "condition not expressible: you go first: If you go first, you can use this attack during your first turn."),
  ("me2pt5-83", "Marill", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me2pt5-85", "Misdreavus", "unhandled sentence: Search your deck for a card that evolves from this Pokémon and put it onto this Pokémon to evolve it."),
  ("me2pt5-89", "Mega Gardevoir ex", "unhandled sentence: For each of your Benched Pokémon, search your deck for a Basic Psychic Energy card and attach it to that Pokémon."),
  ("me2pt5-92", "Rotom", "unhandled sentence: You may search your deck for any number of Pokémon that have \"Rotom\" in their name and put them onto your Bench."),
  ("me2pt5-95", "Hop's Phantump", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me2pt5-96", "Hop's Trevenant", "condition not expressible: Knock Out record of a kind of Pokémon (Count.koLast records any): any of your Hop's Pokémon were Knocked Out by damage from an attack during your opponent's last turn: If any of your Hop's Pokémon were Knocked Out by damage from an attack during your opponent's last turn, this attack does 100 more damage."),
  ("me2pt5-98", "Spectrier", "unhandled sentence: Discard all Energy from this Pokémon and place 12 damage counters on 1 of your opponent's Pokémon."),
  ("me2pt5-101", "Team Rocket's Dugtrio", "Ability: triggered (MV7 oppBenched), 'that Pokémon' (the Pokémon moved to the Bench) has no target in the model's language (Known gaps): Whenever your opponent's Active Pokémon moves to the Bench during their turn, place 2 damage counters on that Pokémon."),
  ("me2pt5-116", "Mega Hawlucha ex", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If this Pokémon would be Knocked Out by damage from an attack, flip a coin. If heads, this Pokémon is not Knocked Out, and its remaining HP becomes 10."),
  ("me2pt5-117", "Carbink", "Ability: static, typeWeak (a change of type or Weakness): As long as this Pokémon is in play, it is Fighting and Psychic type."),
  ("me2pt5-122", "Okidogi", "not modelled (Known gaps, MV2): history: counted (damage or Prize cards of last turn): This attack does 60 more damage for each Prize card your opponent took during their last turn."),
  ("me2pt5-125", "Mega Gengar ex", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If 1 of your Darkness Pokémon is Knocked Out by damage from an attack from your opponent's Pokémon ex, that player takes 1 fewer Prize card. The effect of Shadowy Concealment doesn't stack."),
  ("me2pt5-140", "Pangoro", "condition not expressible: any of your Benched Pancham have any damage counters on them: If any of your Benched Pancham have any damage counters on them, this attack does 120 more damage."),
  ("me2pt5-148", "Kingambit", "Ability: static, cond (a condition the model cannot test statically (Prize cards, the hand, other Pokémon in play, Special Conditions, Special Energy, Tools, damage)): Attacks used by this Pokémon do 30 more damage to your opponent's Active Pokémon for each Prize card your opponent has taken (before applying Weakness and Resistance)."),
  ("me2pt5-151", "Dragonair", "Ability: condition on this Pokémon, which may be on the Bench: this Pokémon has any Energy attached: Once during your turn, if this Pokémon has any Energy attached, you may use this Ability. Search your deck for an Evolution Pokémon, reveal it, and put it into your hand. Then, shuffle your deck."),
  ("me2pt5-157", "Noivern", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me2pt5-162", "Team Rocket's Kangaskhan ex", "not modelled (Known gaps, MV2): history: the Supporter played this turn: If you played a Supporter card that has \"Team Rocket\" in its name from your hand during this turn, this attack does 100 more damage."),
  ("me2pt5-175", "Larry's Komala", "unhandled sentence: Attach an Energy card from your hand to your Active Larry's Pokémon."),
  ("me2pt5-182", "Anthea & Concordia", "unhandled sentence: You can use this card only if you have N's Darmanitan, N's Zoroark ex, N's Vanilluxe, N's Klinklang, N's Reshiram, and N's Zekrom in play."),
  ("me2pt5-186", "Counter Gain", "Pokémon Tool: static, cost (attack cost or Energy provision): If you have more Prize cards remaining than your opponent, attacks used by the Pokémon this card is attached to cost Colorless less."),
  ("me2pt5-197", "Nighttime Mine", "Stadium: static, cost (attack cost or Energy provision): Attacks used by each Tera Pokémon in play (both yours and your opponent's) cost Colorless more."),
  ("me3-8", "Spewpa", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me3-9", "Vivillon", "condition not expressible: a Stadium is in play: If a Stadium is in play, this attack does 60 more damage."),
  ("me3-12", "Decidueye ex", "Ability: static, cost (attack cost or Energy provision): If your opponent has exactly 4 cards in their hand, ignore all Colorless Energy in the costs of attacks used by this Pokémon."),
  ("me3-17", "Turtonator", "Ability: triggered (M8b shape), effect outside the trigger fragment (Effect.trigOk: a test or coin flip, a switch, a heal, an exact zone move, …): If this Pokémon is in the Active Spot and is damaged by an attack from your opponent's Pokémon (even if this Pokémon is Knocked Out), discard an Energy from the Attacking Pokémon."),
  ("me3-24", "Aurorus", "Ability: static, stack (stacking rule (\"doesn't stack\"): the model adds every effect in force): All of your Pokémon that have any Water Energy attached take 50 less damage from attacks from your opponent's Pokémon (after applying Weakness and Resistance). The effect of Tundra Wall doesn't stack."),
  ("me3-27", "Luxio", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If your opponent's Active Pokémon is a Pokémon ex, this Pokémon can evolve during your first turn or the turn you play it."),
  ("me3-29", "Dedenne", "unhandled sentence: Choose Basic Lightning Energy cards from your discard pile up to the amount of Energy attached to all of your opponent's Pokémon and attach them to your Lightning Pokémon in any way you like."),
  ("me3-31", "Mega Clefable ex", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all effects of your opponent's Pokémon's Abilities done to this Pokémon."),
  ("me3-39", "Hippopotas", "unhandled sentence: During your opponent's next turn, if the Defending Pokémon tries to use an attack, your opponent flips a coin."),
  ("me3-40", "Hippowdon", "not modelled (Known gaps, MV2): history: the Supporter played this turn: If you played Tarragon from your hand during this turn, discard the top 3 cards of your opponent's deck."),
  ("me3-41", "Landorus", "unhandled sentence: Put an Energy attached to this Pokémon into your hand."),
  ("me3-46", "Hawlucha", "condition not expressible: your Benched Pokémon have any damage counters on them: If your Benched Pokémon have any damage counters on them, this attack does 60 more damage."),
  ("me3-47", "Mega Zygarde ex", "unhandled sentence: For each of your opponent's Pokémon, flip a coin."),
  ("me3-50", "Gengar", "Ability: triggered (M8b shape), replacement effect (\"instead of\"): If this Pokémon is Knocked Out by damage from an attack from your opponent's Pokémon, put it into your hand instead of the discard pile. (Discard all attached cards.)"),
  ("me3-53", "Yveltal ex", "unhandled sentence: Knock Out each of your opponent's Pokémon that has 50 HP or less remaining."),
  ("me3-55", "Mega Skarmory ex", "unhandled sentence: Shuffle all Energy attached to this Pokémon into your deck, and this attack does 220 damage to 1 of your opponent's Pokémon."),
  ("me3-59", "Klefki", "unhandled sentence: Choose 1 of your opponent's Active Pokémon's attacks."),
  ("me3-61", "Raticate", "count not expressible: damage counter on all of your Benched Rattata: This attack does 40 damage for each damage counter on all of your Benched Rattata."),
  ("me3-62", "Meowth ex", "unhandled sentence: Put this Pokémon and all attached cards into your hand."),
  ("me3-63", "Snorlax", "flip until tails not expressible: Flip a coin until you get tails. Search your deck for an amount of Basic Energy up to the number of heads and attach it to this Pokémon."),
  ("me3-67", "Furfrou", "unhandled sentence: Discard random cards from your opponent's hand until they have 5 cards in their hand."),
  ("me3-68", "Antique Jaw Fossil", "Trainer played as a Pokémon"),
  ("me3-69", "Antique Sail Fossil", "Trainer played as a Pokémon"),
  ("me3-75", "Jacinthe", "unhandled sentence: Heal 150 damage from 1 of your Psychic Pokémon."),
  ("me3-77", "Lumiose City", "Stadium: activated effect not expressible: condition not expressible: a player searches your deck in this way: Once during each player's turn, that player may search their deck for a Basic Pokémon and put it onto their Bench. Then, that player shuffles their deck. If a player searches their deck in this way, their turn ends."),
  ("me3-78", "Lumiose Galette", "unhandled sentence: Heal 20 damage and remove a Special Condition from your Active Pokémon."),
  ("me3-79", "Naveen", "unhandled sentence: Before drawing cards, you may discard any number of cards from your hand."),
  ("me3-84", "Rosa's Encouragement", "unhandled sentence: You can use this card only if you have more Prize cards remaining than your opponent."),
  ("me3-87", "Rocky Fighting Energy", "Special Energy: rider not modelled: prevention of effects of attacks (absent from the language): Prevent all effects of attacks used by your opponent's Pokémon done to the Fighting Pokémon this card is attached to."),
  ("me3-88", "Telepathic Psychic Energy", "Special Energy: rider not modelled: on-attach effect (stage 4 of MV8, not done): When you attach this card from your hand to a Psychic Pokémon, search your deck for up to 2 Basic Psychic Pokémon and put them onto your Bench."),
  ("me4-4", "Carnivine", "condition not expressible: your opponent's Active Pokémon has no Retreat Cost: If your opponent's Active Pokémon has no Retreat Cost, this attack does 80 more damage."),
  ("me4-7", "Chesnaught", "Ability: triggered (M8b shape), effect sentence not translated (unhandled sentence): Place 3 damage counters on your opponent's Active Pokémon for each Grass Energy attached to this Pokémon."),
  ("me4-9", "Ninetales", "unhandled sentence: Move all damage counters from 1 of your Benched Pokémon to your opponent's Active Pokémon."),
  ("me4-17", "Octillery", "unhandled sentence: During your opponent's next turn, if the Defending Pokémon tries to use an attack, your opponent flips 2 coins."),
  ("me4-18", "Delibird", "unhandled sentence: Each player may attach up to 3 Basic Energy cards from their hand to their Pokémon in any way they like."),
  ("me4-22", "Mega Greninja ex", "unhandled sentence: You may put a Water Energy attached to this Pokémon into your hand and have this attack do 80 more damage."),
  ("me4-24", "Avalugg", "unhandled sentence: Discard the top 6 cards of your deck, and this attack does 60 damage for each Basic Water Energy card you discarded in this way."),
  ("me4-26", "Golisopod", "condition not expressible: your opponent's Pokémon is Knocked Out by damage from this attack: If your opponent's Pokémon is Knocked Out by damage from this attack, during your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me4-29", "Ampharos", "Ability: static, cond (a condition the model cannot test statically (Prize cards, the hand, other Pokémon in play, Special Conditions, Special Energy, Tools, damage)): If you have the same number of cards in your hand as your opponent, attacks used by this Pokémon do 80 more damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."),
  ("me4-30", "Emolga", "unhandled sentence: Put this Pokémon and all attached cards into your hand."),
  ("me4-33", "Deoxys", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Pokémon that have an Ability."),
  ("me4-35", "Mega Floette ex", "unhandled sentence: Heal 30 damage from each Pokémon (both yours and your opponent's)."),
  ("me4-36", "Espurr", "not modelled (Known gaps, MV2): history: the Supporter played this turn: If you played Emma from your hand during this turn, this attack does 60 more damage."),
  ("me4-38", "Phantump", "Ability: first-turn limit: Once during your turn, you may use this Ability. Choose a card in your hand that evolves from this Pokémon and put it onto this Pokémon to evolve it. If you do, place 2 damage counters on the Pokémon you evolved in this way. You can't use this Ability during your first turn."),
  ("me4-39", "Trevenant", "unhandled sentence: During your opponent's next turn, Energy can't be attached from your opponent's hand to the Defending Pokémon."),
  ("me4-41", "Gourgeist ex", "not modelled (Known gaps, MV2): spread: target filtered by its damage: This attack does 50 more damage for each of your Benched Pokémon that has any damage counters on it."),
  ("me4-47", "Claydol", "condition not expressible: your opponent's Active Pokémon is an evolved Pokémon: If your opponent's Active Pokémon is an evolved Pokémon, devolve it by putting the highest Stage Evolution card on it into your opponent's hand."),
  ("me4-50", "Golbat", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Basic Pokémon."),
  ("me4-57", "Garbodor", "Ability: static, oppLess (the opponent's attacks do less damage before Weakness and Resistance (the model's static reduction is at step 5)): Attacks used by your opponent's Active Pokémon that has a Pokémon Tool attached do 20 less damage (before applying Weakness and Resistance)."),
  ("me4-61", "Metagross", "unhandled sentence: You may discard 3 Metal Energy from this Pokémon and have this attack do 150 more damage."),
  ("me4-63", "Ferrothorn", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): During your opponent's turn, if this Pokémon is discarded from your deck by an effect of an attack or Ability from your opponent's Pokémon, or by an effect of your opponent's Item or Supporter cards, discard the top 8 cards of your opponent's deck."),
  ("me4-64", "Cobalion ex", "Ability: triggered (MV7c movedUp), effect sentence not translated (unhandled sentence): Move any amount of Metal Energy from your other Pokémon to this Pokémon."),
  ("me4-65", "Mega Dragalge ex", "unhandled sentence: Discard all Pokémon Tools and Special Energy from all of your opponent's Pokémon."),
  ("me4-68", "Goodra", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): When your opponent's Active Pokémon retreats, your opponent flips a coin. If tails, Energy for its Retreat Cost is not discarded, and they don't switch Pokémon. The effect of Slimy Sliding doesn't stack."),
  ("me4-69", "Tauros", "unhandled sentence: Choose 1 of your opponent's Pokémon and flip a coin for each of your Pokémon in play that has \"Tauros\" in its name."),
  ("me4-70", "Patrat", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): Damage counters on each Pokémon (both yours and your opponent's) can't be moved to other Pokémon."),
  ("me4-73", "Cinccino ex", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If any damage is done to this Pokémon by attacks, flip a coin. If heads, prevent that damage."),
  ("me4-74", "Adversity Policy", "Pokémon Tool: triggered (M8b shape), printed condition (Weakness, Retreat Cost, another card in play, the attacker's kind, a holder name): If the Pokémon this card is attached to has Weakness to your opponent's Active Pokémon's type, is in the Active Spot, and is damaged by an attack from your opponent's Pokémon (even if this Pokémon is Knocked Out), draw 3 cards."),
  ("me4-75", "Ange Floette", "Stadium: static, play (a rule on putting the card into play): You can put this card into play only if you discard a Prism Tower in play, and you can put this card into play during the same turn you play Prism Tower.
Each Mega Floette ex in play (both yours and your opponent's) gets +150 HP."),
  ("me4-76", "AZ's Tranquility", "condition not expressible: you moved a Pokémon ex to your Bench in this way: If you moved a Pokémon ex to your Bench in this way, heal 80 damage from that Pokémon."),
  ("me4-77", "Emma", "revealed hand: clause not expressible: draw a card for each Pokémon you find there"),
  ("me4-79", "Philippe", "several cards to one chosen Pokémon: Attach up to 2 Basic Metal Energy cards from your discard pile to 1 of your Metal Pokémon."),
  ("me4-81", "Roxie's Performance", "unhandled sentence: During your opponent's next turn, their Poisoned Pokémon can't retreat."),
  ("me4-83", "Transformation Tome", "unhandled sentence: You must play 2 Transformation Tome cards at once."),
  ("me4-84", "Bubbly Water Energy", "Special Energy: rider not modelled: Special Condition recovery and immunity (no static form): The Water Pokémon this card is attached to recovers from all Special Conditions and can't be affected by any Special Conditions."),
  ("me4-86", "Nitro Fire Energy", "Special Energy: rider not modelled: return after a discard by the holder's attack (no machinery): If this card is discarded by an effect of an attack used by the Fire Pokémon this card is attached to, put this card into your hand after attack damage and effects."),
  ("me4-114", "Surfing Beach", "Stadium: activated effect not expressible: unhandled sentence: Once during each player's turn, that player may switch their Active Water Pokémon with 1 of their Benched Water Pokémon."),
  ("me5-4", "Lurantis ex", "not modelled (Known gaps, MV2): history: healed this turn: If this Pokémon was healed during this turn, this attack does 200 more damage."),
  ("me5-5", "Poltchageist", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all effects of your opponent's Pokémon's attacks and Abilities done to this Pokémon. (Damage is not an effect.)"),
  ("me5-6", "Sinistcha", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all effects of your opponent's Pokémon's attacks and Abilities done to this Pokémon. (Damage is not an effect.)"),
  ("me5-7", "Heatran", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Burned Pokémon."),
  ("me5-12", "Armarouge", "card kind with no filter: Pokémon that has any Fire Energy attached: This attack does 40 more damage for each of your Benched Pokémon that has any Fire Energy attached."),
  ("me5-14", "Seaking", "not modelled (Known gaps, MV2): spread: amount computed by the text: This attack does 30 damage to 1 of your opponent's Pokémon for each Water Energy attached to this Pokémon."),
  ("me5-16", "Wailord ex", "unhandled sentence: This Pokémon is now Asleep."),
  ("me5-17", "Relicanth", "name substring that no card of that kind contains: Antique: This attack does 30 more damage for each of your Benched Pokémon that has \"Antique\" in its name."),
  ("me5-20", "Primarina", "unhandled sentence: Heal all damage from 1 of your Pokémon."),
  ("me5-24", "Manectric", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Evolution Pokémon."),
  ("me5-26", "Vikavolt", "condition not expressible: this Pokémon has no Voltaic Lightning Energy attached: If this Pokémon has no Voltaic Lightning Energy attached, this attack does nothing."),
  ("me5-28", "Miraidon", "Ability: triggered (M8b shape), effect sentence not translated (unhandled sentence): Move up to 2 Basic Lightning Energy cards from this Pokémon to 1 of your Benched Pokémon."),
  ("me5-29", "Slowpoke", "unhandled sentence: You may discard any number of cards from your hand."),
  ("me5-31", "Mega Slowbro ex", "not modelled (Known gaps, MV2): history: next-turn trigger on this Pokémon: During your opponent's next turn, if this Pokémon is damaged by an attack (even if this Pokémon is Knocked Out), place 12 damage counters on the Attacking Pokémon."),
  ("me5-32", "Jynx", "unhandled sentence: At the end of your opponent's next turn, discard the Defending Pokémon and all attached cards."),
  ("me5-33", "Shuppet", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all effects of your opponent's Pokémon's attacks and Abilities done to this Pokémon. (Damage is not an effect.)"),
  ("me5-34", "Banette", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Prevent all effects of your opponent's Pokémon's attacks and Abilities done to this Pokémon. (Damage is not an effect.)"),
  ("me5-35", "Spiritomb", "unhandled sentence: Choose 2 of your opponent's Pokémon and quadruple the number of damage counters on each of them."),
  ("me5-37", "Lampent", "Bench placement of a named card that is not a Basic Pokémon (putBench is Basic-only): Search your deck for up to 3 Lampent and put them onto your Bench."),
  ("me5-38", "Mega Chandelure ex", "count of the Retreat Cost on a card whose own static effect changes it (Count.retreat reads the printed cost)"),
  ("me5-41", "Annihilape", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If this Pokémon would be Knocked Out by damage from an attack, flip a coin. If heads, this Pokémon is not Knocked Out, and its remaining HP becomes 10."),
  ("me5-42", "Mankey", "stage not Basic, Stage 1 or Stage 2"),
  ("me5-48", "Mega Darkrai ex", "condition not expressible: your Benched Pokémon have any damage counters on them: If your Benched Pokémon have any damage counters on them, this attack does 110 more damage."),
  ("me5-50", "Mandibuzz", "unhandled sentence: This attack does 70 damage to 1 of your opponent's Pokémon that has any Special Energy attached."),
  ("me5-54", "Thievul", "unhandled sentence: Choose an attack from 1 of your opponent's Pokémon in play and use it as this attack."),
  ("me5-56", "Zarude", "condition not expressible: your Benched Pokémon have any Shadowy Darkness Energy attached: If your Benched Pokémon have any Shadowy Darkness Energy attached, this attack does 70 more damage."),
  ("me5-62", "Bastiodon", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): As long as this Pokémon is on your Bench, prevent all damage done to each of your Pokémon by attacks from your opponent's Pokémon that have 2 or less Energy attached."),
  ("me5-64", "Bronzong", "unhandled sentence: During your opponent's next turn, this Pokémon takes 100 less damage from attacks from Evolution Pokémon (after applying Weakness and Resistance)."),
  ("me5-67", "Trumbeak", "condition not expressible: heads: If heads, during your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me5-72", "Antique Armor Fossil", "Trainer played as a Pokémon"),
  ("me5-73", "Antique Skull Fossil", "Trainer played as a Pokémon"),
  ("me5-74", "Backtrack Badge", "Pokémon Tool: static, coins (coin re-flips): Once during your turn, after you flip any coins for an attack of the Colorless Pokémon this card is attached to, you may ignore all results of those coin flips and begin flipping those coins again."),
  ("me5-75", "Dark Bell", "unhandled sentence: Both Active non-Darkness Pokémon are now Confused."),
  ("me5-76", "Fossil Quarry", "Stadium: activated effect not expressible: card kind with no filter: Item cards that have \"Antique\" in your name: Once during each player's turn, that player may search their deck for up to 2 Item cards that have \"Antique\" in their name and put them onto their Bench. Then, that player shuffles their deck."),
  ("me5-77", "Gladion's Final Battle", "unhandled sentence: You can use this card only when it is the last card in your hand."),
  ("me5-78", "Gwynn", "unhandled sentence: Discard up to 2 Pokémon that don't have a Rule Box from your hand, and draw 3 cards for each card you discarded in this way."),
  ("me5-79", "Jett", "unhandled sentence: Draw a card for each of your opponent's Mega Evolution Pokémon ex in play."),
  ("me5-80", "Misty's Vitality", "several cards to one chosen Pokémon: Search your deck for up to 4 Basic Water Energy cards and attach them to 1 of your Pokémon."),
  ("me5-82", "Tremendous Bomb", "Pokémon Tool: triggered (M8b shape), reads the damage taken: If the Pokémon this card is attached to isn't a Mega Evolution Pokémon ex, is in the Active Spot, and takes 240 or more damage from an attack from your opponent's Mega Evolution Pokémon ex (even if this Pokémon is Knocked Out), place 12 damage counters on the Attacking Pokémon. If you placed any damage counters in this way, discard this card."),
  ("me5-83", "Shadowy Darkness Energy", "Special Energy: rider not modelled: prevention of damage to a Benched holder (`SEff.prevent` is read in the Active Spot only): As long as the Darkness Pokémon this card is attached to is on your Bench, prevent all damage done to it by attacks from your opponent's Pokémon."),
  ("me5-115", "Mega Chandelure ex", "stage not Basic, Stage 1 or Stage 2: MEGA,ex"),
  ("me55-4", "Illumise", "Ability: static, typeWeak (a change of type or Weakness): If you have Volbeat in play, apply Weakness for both Active Pokémon as x3"),
  ("me55-6", "Cherubi", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me55-11", "Moltres", "Ability: condition not expressible: you have Articuno and Zapdos in play: Once during your turn, if you have Articuno and Zapdos in play, you may use this Ability. Attach a Basic Fire Energy card from your hand to this Pokémon."),
  ("me55-12", "Ho-Oh", "unhandled sentence: Heal all damage from 1 of your Benched Pokémon."),
  ("me55-16", "Slowpoke", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me55-18", "Articuno", "Ability: condition not expressible: you have Moltres and Zapdos in play: Once during your turn, if you have Moltres and Zapdos in play, you may use this Ability. Attach a Basic Water Energy card from your hand to this Pokémon."),
  ("me55-21", "Greninja ex", "not modelled (Known gaps, MV2): spread: amount computed by the text: This attack does 30 damage to 1 of your opponent's Pokémon for each damage counter on that Pokémon."),
  ("me55-22", "Wishiwashi", "Ability: triggered (M8b shape), fires on another Pokémon's event (your Active Pokémon of a type or name): If your Wishiwashi or Wishiwashi ex is in the Active Spot and is damaged by an attack from your opponent's Pokémon (even if your Pokémon is Knocked Out), place 3 damage counters on the Attacking Pokémon."),
  ("me55-28", "Pikachu", "Ability: static, oppLess (the opponent's attacks do less damage before Weakness and Resistance (the model's static reduction is at step 5)): As long as this Pokémon is in the Active Spot, attacks used by your opponent's Active Pokémon do 20 less damage (before applying Weakness and Resistance)."),
  ("me55-33", "Pikachu", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): As long as this Pokémon is on your Bench, prevent all damage from and effects of attacks from your opponent's Pokémon done to this Pokémon."),
  ("me55-40", "Pikachu", "unhandled sentence: The Defending Pokémon's Weakness is now Lightning until the end of your next turn."),
  ("me55-42", "Pikachu", "flip until tails not expressible: Flip a coin until you get tails. Search your deck for an amount of Basic Lightning Energy up to the number of heads and attach it to this Pokémon."),
  ("me55-43", "Pikachu", "unhandled sentence: This Pokémon is now Asleep."),
  ("me55-44", "Pikachu", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me55-54", "Pikachu ex", "unhandled sentence: You may attach any number of Basic Energy cards from your hand to your Pokémon in any way you like."),
  ("me55-55", "Zapdos", "Ability: condition not expressible: you have Moltres and Articuno in play: Once during your turn, if you have Moltres and Articuno in play, you may use this Ability. Attach a Basic Lightning Energy card from your hand to this Pokémon."),
  ("me55-61", "Morpeko", "unhandled sentence: Discard the top 3 cards of your deck and put 1 of them into your hand."),
  ("me55-63", "Mewtwo", "several cards to one chosen Pokémon: Attach up to 2 Basic Energy cards from your discard pile to 1 of your Pokémon."),
  ("me55-66", "Mew ex", "Ability: static, attacks (use of other attacks): This Pokémon can use the attacks of any of your Benched Pokémon. (You still need the necessary Energy to use each attack.)"),
  ("me55-69", "Espeon", "unhandled sentence: Devolve each of your opponent's evolved Pokémon by putting the highest Stage Evolution card on it into your opponent's hand."),
  ("me55-72", "Unown", "condition not expressible: your opponent's Pokémon is Knocked Out by damage from this attack: If your opponent's Pokémon is Knocked Out by damage from this attack, take 1 more Prize card."),
  ("me55-73", "Drifloon", "unhandled sentence: You may shuffle this Pokémon and all attached cards into your deck."),
  ("me55-84", "Seismitoad", "unhandled sentence: During your opponent's next turn, whenever they try to use a Trainer card from their hand, they flip a coin."),
  ("me55-85", "Lycanroc", "not modelled (Known gaps, MV2): history: counted (damage or Prize cards of last turn): If this Pokémon was damaged by an attack during your opponent's last turn, this attack does that much more damage."),
  ("me55-90", "Gengar ex", "Ability: triggered (M8b shape), opening not recognised (misprint \"Knocket Out\" in the data): If this Pokémon is Knocket Out by damage from an attack from your opponent's Pokémon, flip a coin. If heads, the Attacking Pokémon is Knocket Out."),
  ("me55-93", "Murkrow", "Resistance not -N: {'type': 'Fighting', 'value': '×2'}"),
  ("me55-96", "Zoroark", "evolution card with no evolves-from field in the data"),
  ("me55-100", "Yveltal", "Ability: static, prevent (prevention or immunity (damage, effects, Special Conditions, healing)): Your opponent's Active Pokémon can't be healed."),
  ("me55-108", "Gholdengo", "unhandled sentence: if you have exactly 30 cards in your hand, take 2 Prize cards."),
  ("me55-115", "Ditto", "unhandled sentence: Search your deck for a Pokémon and switch it with this Pokémon."),
  ("me55-119", "Snorlax", "Ability: triggered (Knock Out, damage, Checkup, an opponent's action or a move between spots): If this Pokémon remains Asleep during Pokémon Checkup, heal all damage from this Pokémon."),
  ("me55-121", "Lugia", "unhandled sentence: Discard a Fire Energy, a Water Energy, and a Lightning Energy from this Pokémon."),
  ("me55-123", "Hisuian Zoroark", "unhandled sentence: Place damage counters on your opponent's Active Pokémon until its remaining HP is 50."),
  ("me55-125", "Maushold", "unhandled sentence: Flip a coin for each Maushold you have in play."),
  ("me6-6", "Combee", "unhandled sentence: Put this Pokémon and all attached cards into your hand."),
  ("me6-10", "Wimpod", "Ability: static, noRetreat (\"has no Retreat Cost\" in a form not read (a condition or holder outside the forms of SEff.noRetreat)): If your opponent has any Pokémon ex in play, this Pokémon has no Retreat Cost."),
  ("me6-14", "Meowscarada ex", "not modelled (Known gaps, MV2): spread: target filtered by its damage: This attack also does 120 damage to 1 of your opponent's Benched Pokémon that has any damage counters on it."),
  ("me6-21", "Magmortar", "unhandled sentence: Attach a Basic Fire Energy card, a Basic Lightning Energy card, or 1 of each from your hand to your Electivire and Magmortar in any way you like."),
  ("me6-23", "Heat Rotom ex", "unhandled sentence: Then, shuffle those cards into your deck."),
  ("me6-26", "Kyogre", "condition not expressible: a Stadium that has \"Legendary\" in its name is in play: If a Stadium that has \"Legendary\" in its name is in play, this attack also does 50 damage to each of your opponent's Benched Pokémon."),
  ("me6-33", "Raikou ex", "condition not expressible: you go first: If you go first, you can use this attack during your first turn."),
  ("me6-35", "Thundurus", "Ability: static, cost (attack cost or Energy provision): If you have Tornadus, Thundurus, Landorus, and Enamorus in play, ignore all Colorless Energy in the costs of attacks used by this Pokémon."),
  ("me6-40", "Wattrel", "unhandled sentence: During your opponent's next turn, prevent all damage from and effects of attacks done to this Pokémon."),
  ("me6-45", "Giratina", "not modelled (Known gaps, MV2): history: an attack used last turn: If 1 of your Pokémon used Chaos Crawler during your last turn, this attack can't be used."),
  ("me6-47", "Mega Golurk ex", "Ability: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): This Pokémon can't use attacks unless you have 10 or more cards in your hand."),
  ("me6-48", "Enamorus", "Ability: static, cost (attack cost or Energy provision): If you have Tornadus, Thundurus, Landorus, and Enamorus in play, ignore all Colorless Energy in the costs of attacks used by this Pokémon."),
  ("me6-49", "Sandshrew", "unhandled sentence: Search your deck for a card that evolves from this Pokémon and put it onto this Pokémon to evolve it."),
  ("me6-52", "Steelix", "Ability: static, readsHp (reads HP or damage): If this Pokémon has full HP, it takes 60 less damage from attacks from your opponent's Pokémon (after applying Weakness and Resistance)."),
  ("me6-53", "Groudon", "condition not expressible: a Stadium that has \"Legendary\" in its name is in play: If a Stadium that has \"Legendary\" in its name is in play, this attack does 170 more damage."),
  ("me6-54", "Landorus", "Ability: static, cost (attack cost or Energy provision): If you have Tornadus, Thundurus, Landorus, and Enamorus in play, ignore all Colorless Energy in the costs of attacks used by this Pokémon."),
  ("me6-59", "Ariados", "unhandled sentence: During your opponent's next turn, prevent all damage done to this Pokémon by attacks from Basic Pokémon."),
  ("me6-83", "Kecleon", "unhandled sentence: Reveal any number of Pokémon from your hand, and this attack does 30 damage for each different type of Pokémon you revealed in this way."),
  ("me6-85", "Tornadus", "Ability: static, cost (attack cost or Energy provision): If you have Tornadus, Thundurus, Landorus, and Enamorus in play, ignore all Colorless Energy in the costs of attacks used by this Pokémon."),
  ("me6-88", "Talonflame ex", "Ability: used from the hand: Once during your turn, if this Pokémon is in your hand, and if you have any Colorless Mega Evolution Pokémon ex in play, you may use this Ability. Put this Pokémon onto your Bench."),
  ("me6-90", "Adventure Lantern", "Pokémon Tool: record text names no holder (an Item-like text; unclassified record): Search your deck for a Basic Fire Energy card and a Basic Lightning Energy card, reveal them, and put them into your hand. Then, shuffle your deck."),
  ("me6-91", "Custom Vest", "Pokémon Tool: static, filter (a filter the model has not (name prefix, Ancient, Future, Tera, \"has an Ability\", Mega Evolution Pokémon ex)): If the Pokémon this card is attached to isn't a Mega Evolution Pokémon ex, it takes 60 less damage from attacks from your opponent's Mega Evolution Pokémon ex (after applying Weakness and Resistance)."),
  ("me6-93", "Grisham", "unhandled sentence: Heal 50 damage from each Pokémon (both yours and your opponent's)."),
  ("me6-94", "Legendary Pyroduct", "Stadium: static, lock (a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)): Evolution Pokémon in play (both yours and your opponent's) have no Abilities."),
  ("me6-96", "Legendary Summit", "Stadium: triggered: Whenever a Colorless Pokémon (yours or your opponent's) is Knocked Out by damage from an attack from the opponent's Pokémon, that player takes 1 fewer Prize card."),
  ("me6-98", "Legendary Trench", "Stadium: triggered: Whenever a Pokémon (yours or your opponent's) is healed, double the amount of damage healed."),
  ("me6-100", "Mega Rayquaza Cap", "Pokémon Tool: text besides the attack grant (the Mega Evolution ex rule printed on a Tool): Mega Evolution ex Rule: When your Mega Evolution Pokémon ex is Knocked Out, your opponent takes 3 Prize cards."),
  ("me6-101", "Tasty Rice Ball", "unhandled sentence: For each Tasty Rice Ball card (not including this card) in your discard pile, heal 30 more damage."),
  ("me6-102", "Tate & Liza's Training", "condition not expressible: you drew any cards in this way: If you drew any cards in this way, and if a Stadium that has \"Legendary\" in its name is in play, put this Tate & Liza's Training into your hand instead of the discard pile."),
  ("me6-103", "Zinnia's Trust", "unhandled sentence: Move an Energy from the Pokémon you moved to your Bench to the new Active Pokémon."),
  ("me6-132", "Bubbly Water Energy", "Special Energy: rider not modelled: Special Condition recovery and immunity (no static form): The Water Pokémon this card is attached to recovers from all Special Conditions and can't be affected by any Special Conditions."),
  ("me6-134", "Nitro Fire Energy", "Special Energy: rider not modelled: return after a discard by the holder's attack (no machinery): If this card is discarded by an effect of an attack used by the Fire Pokémon this card is attached to, put this card into your hand after attack damage and effects.")]

/-- **The count.** `all` has 1497 entries. -/
theorem all_length : all.length = 1497 := by decide +kernel

/-- `notImported` has 656 entries. -/
theorem notImported_length : notImported.length = 656 := by decide +kernel

/-- Arithmetic on the three lengths, and nothing more: 1497 + 8 + 656 = 2161. That the three lists partition
the pool's 2161 cards (every card of the pool in exactly one of them, once) is established outside Lean, by
the importer (`tools/importer/importer.py`, which asserts it when it writes this file); the pool itself
is not a Lean object. -/
theorem pool_size : all.length + sameTerm.length + notImported.length = 2161 := by decide +kernel

/-- Every imported card passes the per-card checks. -/
theorem all_ok : all.all Card.importOk = true := by
  simp only [all, List.all_append, Part01.cards_ok, Part02.cards_ok, Part03.cards_ok, Part04.cards_ok, Part05.cards_ok, Part06.cards_ok, Part07.cards_ok, Part08.cards_ok, Part09.cards_ok, Part10.cards_ok, Bool.and_self]

/-- **No imported card is inert.** No imported Stadium or Tool is a card the model plays with no
effect (`Card.inert`): every imported Stadium has an activated or (milestone M6) a static effect the
model expresses, every imported Tool gives an attack, an Ability (since importer 0.6.0 a triggered one,
milestone M8b) or a static effect, and (since importer 0.15.0, milestone MV8) every imported Special Energy
card has a payload that models something and does not set `EnergyText.rest`. (Triggered Stadium and Tool
text outside the shapes the model has, static text outside the model's `Static`, and Special Energy cards
with a rider the model lacks, which the model would play as inert, are refused by the importer.) -/
theorem notInert : ∀ c ∈ all, c.inert = false := by
  have h : all.all (fun c => !c.inert) = true := by
    simp only [all, List.all_append, Part01.cards_notInert, Part02.cards_notInert, Part03.cards_notInert, Part04.cards_notInert, Part05.cards_notInert, Part06.cards_notInert, Part07.cards_notInert, Part08.cards_notInert, Part09.cards_notInert, Part10.cards_notInert, Bool.and_self]
  intro c hc
  simpa using List.all_eq_true.1 h c hc

/-- No card of part 1 is the same term as a card of part 2. -/
theorem cross_1_2 : crossOk Part01.cards Part02.cards = true := by decide +kernel

/-- No card of part 1 is the same term as a card of part 3. -/
theorem cross_1_3 : crossOk Part01.cards Part03.cards = true := by decide +kernel

/-- No card of part 2 is the same term as a card of part 3. -/
theorem cross_2_3 : crossOk Part02.cards Part03.cards = true := by decide +kernel

/-- No card of part 1 is the same term as a card of part 4. -/
theorem cross_1_4 : crossOk Part01.cards Part04.cards = true := by decide +kernel

/-- No card of part 2 is the same term as a card of part 4. -/
theorem cross_2_4 : crossOk Part02.cards Part04.cards = true := by decide +kernel

/-- No card of part 3 is the same term as a card of part 4. -/
theorem cross_3_4 : crossOk Part03.cards Part04.cards = true := by decide +kernel

/-- No card of part 1 is the same term as a card of part 5. -/
theorem cross_1_5 : crossOk Part01.cards Part05.cards = true := by decide +kernel

/-- No card of part 2 is the same term as a card of part 5. -/
theorem cross_2_5 : crossOk Part02.cards Part05.cards = true := by decide +kernel

/-- No card of part 3 is the same term as a card of part 5. -/
theorem cross_3_5 : crossOk Part03.cards Part05.cards = true := by decide +kernel

/-- No card of part 4 is the same term as a card of part 5. -/
theorem cross_4_5 : crossOk Part04.cards Part05.cards = true := by decide +kernel

/-- No card of part 1 is the same term as a card of part 6. -/
theorem cross_1_6 : crossOk Part01.cards Part06.cards = true := by decide +kernel

/-- No card of part 2 is the same term as a card of part 6. -/
theorem cross_2_6 : crossOk Part02.cards Part06.cards = true := by decide +kernel

/-- No card of part 3 is the same term as a card of part 6. -/
theorem cross_3_6 : crossOk Part03.cards Part06.cards = true := by decide +kernel

/-- No card of part 4 is the same term as a card of part 6. -/
theorem cross_4_6 : crossOk Part04.cards Part06.cards = true := by decide +kernel

/-- No card of part 5 is the same term as a card of part 6. -/
theorem cross_5_6 : crossOk Part05.cards Part06.cards = true := by decide +kernel

/-- No card of part 1 is the same term as a card of part 7. -/
theorem cross_1_7 : crossOk Part01.cards Part07.cards = true := by decide +kernel

/-- No card of part 2 is the same term as a card of part 7. -/
theorem cross_2_7 : crossOk Part02.cards Part07.cards = true := by decide +kernel

/-- No card of part 3 is the same term as a card of part 7. -/
theorem cross_3_7 : crossOk Part03.cards Part07.cards = true := by decide +kernel

/-- No card of part 4 is the same term as a card of part 7. -/
theorem cross_4_7 : crossOk Part04.cards Part07.cards = true := by decide +kernel

/-- No card of part 5 is the same term as a card of part 7. -/
theorem cross_5_7 : crossOk Part05.cards Part07.cards = true := by decide +kernel

/-- No card of part 6 is the same term as a card of part 7. -/
theorem cross_6_7 : crossOk Part06.cards Part07.cards = true := by decide +kernel

/-- No card of part 1 is the same term as a card of part 8. -/
theorem cross_1_8 : crossOk Part01.cards Part08.cards = true := by decide +kernel

/-- No card of part 2 is the same term as a card of part 8. -/
theorem cross_2_8 : crossOk Part02.cards Part08.cards = true := by decide +kernel

/-- No card of part 3 is the same term as a card of part 8. -/
theorem cross_3_8 : crossOk Part03.cards Part08.cards = true := by decide +kernel

/-- No card of part 4 is the same term as a card of part 8. -/
theorem cross_4_8 : crossOk Part04.cards Part08.cards = true := by decide +kernel

/-- No card of part 5 is the same term as a card of part 8. -/
theorem cross_5_8 : crossOk Part05.cards Part08.cards = true := by decide +kernel

/-- No card of part 6 is the same term as a card of part 8. -/
theorem cross_6_8 : crossOk Part06.cards Part08.cards = true := by decide +kernel

/-- No card of part 7 is the same term as a card of part 8. -/
theorem cross_7_8 : crossOk Part07.cards Part08.cards = true := by decide +kernel

/-- No card of part 1 is the same term as a card of part 9. -/
theorem cross_1_9 : crossOk Part01.cards Part09.cards = true := by decide +kernel

/-- No card of part 2 is the same term as a card of part 9. -/
theorem cross_2_9 : crossOk Part02.cards Part09.cards = true := by decide +kernel

/-- No card of part 3 is the same term as a card of part 9. -/
theorem cross_3_9 : crossOk Part03.cards Part09.cards = true := by decide +kernel

/-- No card of part 4 is the same term as a card of part 9. -/
theorem cross_4_9 : crossOk Part04.cards Part09.cards = true := by decide +kernel

/-- No card of part 5 is the same term as a card of part 9. -/
theorem cross_5_9 : crossOk Part05.cards Part09.cards = true := by decide +kernel

/-- No card of part 6 is the same term as a card of part 9. -/
theorem cross_6_9 : crossOk Part06.cards Part09.cards = true := by decide +kernel

/-- No card of part 7 is the same term as a card of part 9. -/
theorem cross_7_9 : crossOk Part07.cards Part09.cards = true := by decide +kernel

/-- No card of part 8 is the same term as a card of part 9. -/
theorem cross_8_9 : crossOk Part08.cards Part09.cards = true := by decide +kernel

/-- No card of part 1 is the same term as a card of part 10. -/
theorem cross_1_10 : crossOk Part01.cards Part10.cards = true := by decide +kernel

/-- No card of part 2 is the same term as a card of part 10. -/
theorem cross_2_10 : crossOk Part02.cards Part10.cards = true := by decide +kernel

/-- No card of part 3 is the same term as a card of part 10. -/
theorem cross_3_10 : crossOk Part03.cards Part10.cards = true := by decide +kernel

/-- No card of part 4 is the same term as a card of part 10. -/
theorem cross_4_10 : crossOk Part04.cards Part10.cards = true := by decide +kernel

/-- No card of part 5 is the same term as a card of part 10. -/
theorem cross_5_10 : crossOk Part05.cards Part10.cards = true := by decide +kernel

/-- No card of part 6 is the same term as a card of part 10. -/
theorem cross_6_10 : crossOk Part06.cards Part10.cards = true := by decide +kernel

/-- No card of part 7 is the same term as a card of part 10. -/
theorem cross_7_10 : crossOk Part07.cards Part10.cards = true := by decide +kernel

/-- No card of part 8 is the same term as a card of part 10. -/
theorem cross_8_10 : crossOk Part08.cards Part10.cards = true := by decide +kernel

/-- No card of part 9 is the same term as a card of part 10. -/
theorem cross_9_10 : crossOk Part09.cards Part10.cards = true := by decide +kernel

/-- **No duplicates.** No two entries of `all` are the same `Card` term, so `all` counts 1497 distinct
cards. (Checked by `nodupFp`, part by part and pair of parts by pair of parts, to keep each kernel check
small.) -/
theorem all_nodup : all.Nodup :=
  nodup_of_nodupFp (by
    simp only [all, nodupFp_append, crossOk_append_left, Part01.cards_nodup, Part02.cards_nodup, Part03.cards_nodup, Part04.cards_nodup, Part05.cards_nodup, Part06.cards_nodup, Part07.cards_nodup, Part08.cards_nodup, Part09.cards_nodup, Part10.cards_nodup,
      cross_1_2, cross_1_3, cross_2_3, cross_1_4, cross_2_4, cross_3_4, cross_1_5, cross_2_5, cross_3_5, cross_4_5, cross_1_6, cross_2_6, cross_3_6, cross_4_6, cross_5_6, cross_1_7, cross_2_7, cross_3_7, cross_4_7, cross_5_7, cross_6_7, cross_1_8, cross_2_8, cross_3_8, cross_4_8, cross_5_8, cross_6_8, cross_7_8, cross_1_9, cross_2_9, cross_3_9, cross_4_9, cross_5_9, cross_6_9, cross_7_9, cross_8_9, cross_1_10, cross_2_10, cross_3_10, cross_4_10, cross_5_10, cross_6_10, cross_7_10, cross_8_10, cross_9_10, Bool.and_self])

/-- The imported cards that write a stored amount (`Effect.writes`, `Mod.isAmt`: a damage bonus or reduction, and since
milestone MV6 a step-2 penalty `weaken` or a step-5 increase `expose`), by name. -/
theorem writers : (all.filter Card.writesAmt).map Card.label = ["Feraligatr", "Seedot", "Grotle", "Torkoal", "Kilowattrel", "Houndoom", "Varoom", "Drifloon", "Tornadus", "Donphan", "Vibrava", "Skarmory", "Jasmine's Gaze", "Hop's Corviknight", "Shelgon", "Hop's Rookidee", "Clamperl", "Sigilyph", "Klink", "Klang", "Genesect ex", "Exeggutor", "Buneary", "Pawmi", "Chikorita", "Stunfisk", "Carkol", "Registeel ex", "Mega Pyroar ex", "Donphan", "Metang", "Rampardos ex", "Mabosstiff", "Cosmoem", "Nidoran ♀", "Zamazenta", "Jangmo-o", "Onix", "Jangmo-o"] := by decide +kernel

/-- The imported cards that write any lingering modifier (bonus, reduction, prevention, lock), by name. -/
theorem lingerers : (all.filter Card.lingers).map Card.label = ["Feraligatr", "Pecharunt", "Seedot", "Roserade", "Grotle", "Scovillain ex", "Totodile", "Frosmoth", "Golett", "Golurk", "Torkoal", "Luxio", "Kilowattrel", "Nosepass", "Mightyena", "Whirlipede", "Houndoom", "Sneasel", "Dusknoir", "Varoom", "Lileep", "Turtonator", "Electivire", "Galvantula ex", "Drifloon", "Tornadus", "Bruxish", "Magnezone", "Donphan", "Vibrava", "Skarmory", "Altaria", "Appletun", "Slakoth", "Jasmine's Gaze", "Budew", "Maractus", "Shelmet", "Dhelmise", "Hop's Sandaconda", "Paldean Clodsire ex", "Hop's Corviknight", "Shelgon", "Hop's Rookidee", "Oinkologne", "Clamperl", "Team Rocket's Muk", "Skarmory", "Sigilyph", "Frillish", "Cubchoo", "Beartic", "Klink", "Klang", "Pawniard", "Genesect ex", "Bulbasaur", "Exeggutor", "Yveltal", "Buneary", "Pawmi", "Gliscor", "Eternatus", "Bronzor", "Chikorita", "N's Vanillish", "Stunfisk", "Stunfisk ex", "Carkol", "Registeel ex", "Larry's Braviary", "Spinarak", "Ariados", "Mega Pyroar ex", "Flaaffy", "Donphan", "Krookodile ex", "Metang", "Rampardos ex", "Mabosstiff", "Cosmoem", "Nidoran ♀", "Zamazenta", "Jangmo-o", "Masquerain", "Mega Golisopod ex", "Onix", "Jangmo-o", "Fletchinder"] := by decide +kernel

/-- The imported Items that write a bonus or reduction (`Card.wAmt`), the cards clause 3 (a) of
`StoreSafe` forbids Items, Supporters and "as often as you like" Abilities to recycle, by name. -/
theorem nonSupporterWriters : (all.filter fun c => c.wAmt != 0).map Card.label = [] := by decide +kernel

/-- The imported Items and Supporters that write a rest-of-game bonus or reduction (`Card.alAmt`), by
name. -/
theorem restOfGameWriters : (all.filter fun c => c.alAmt != 0).map Card.label = [] := by decide +kernel

/-- The imported cards with (or, a Tool, giving) an Ability that writes a lingering damage bonus or
reduction, by name. -/
theorem abilityWriters : (all.filter Card.abilityWrites).map Card.label = ["Feraligatr"] := by decide +kernel

/-- The imported cards with (or giving) an Ability that writes any lingering modifier, by name. -/
theorem abilityLingerers : (all.filter Card.abilityLingers).map Card.label = ["Feraligatr"] := by decide +kernel

/-- The imported cards with (or giving) an "as often as you like" Ability (`AbilityUse.unlimited`), by
name. -/
theorem unlimitedAbilities : (all.filter Card.hasUnlimited).map Card.label = ["Iono's Bellibolt ex", "Emboar", "Mega Venusaur ex", "Azumarill ex", "Dewgong"] := by decide +kernel

/-- The imported cards with (or giving) an Ability that can return a card from a discard pile, by
name. -/
theorem abilityRecyclers : (all.filter Card.abilityRecycles).map Card.label = ["Arven's Greedent"] := by decide +kernel

/-- The imported cards whose effects a player can resolve again and again in one turn and that can
return a card from a discard pile (`Card.freeRec`: Items, Supporters and "as often as you like"
Abilities; not Stadiums, whose uses are bounded per turn), by name: the recyclers clause 3 (a) of
`StoreSafe` constrains. -/
theorem freeRecyclers : (all.filter fun c => !c.freeRec.isEmpty).map Card.label = ["Lana's Aid", "Night Stretcher", "Miracle Headset", "Max Rod", "Energy Recycler", "Sacred Ash", "Energy Retrieval", "Tarragon", "Great Haul Net"] := by decide +kernel

/-- The imported Stadiums and Pokémon Tools, by name (milestone M5; none is `Card.inert`, `notInert`). -/
theorem stadiumsAndTools : (all.filter fun c => c.isStadium || c.isTool).map Card.label = ["Paradise Resort", "Full Metal Lab", "Hero's Cape", "Maximum Belt", "Perilous Jungle", "Lucky Helmet", "Academy at Night", "Deluxe Bomb", "Gravity Gemstone", "Amulet of Hope", "Gravity Mountain", "Lively Stadium", "Levincia", "Postwick", "Cynthia's Power Weight", "Granite Cave", "Spikemuth Gym", "Brave Bangle", "Air Balloon", "Punk Helmet", "Light Ball", "Team Rocket's Hypnotizer", "Thick Scale", "Core Memory", "Prism Tower"] := by decide +kernel

/-- The imported Stadiums whose effect can return a card from a discard pile (`Card.allRec`; not
free recyclers, `Card.freeRec`, since their uses are bounded per turn), by name. -/
theorem stadiumRecyclers : (all.filter fun c => c.isStadium && !c.allRec.isEmpty).map Card.label = ["Levincia"] := by decide +kernel

/-- Clause 3 of `StoreSafe` over the whole imported pool, decided. -/
theorem recSafe : recSafeB all = true := by decide +kernel

/-- Clause 3 (`RecycleSafe`) for every game whose cards are all imported cards: no Trainer and no
"as often as you like" Ability of the pool can return a non-Supporter writer of a bonus or reduction,
and no effect of the pool a rest-of-game writer. -/
theorem recycleSafe (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.RecycleSafe :=
  recycleSafe_of recSafe g hg

/-- Clause 4 (`AbilitySafe`) for every game whose cards are all imported cards. -/
theorem abilitySafeGames (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.AbilitySafe :=
  fun x hx => abilitySafe_of all_ok x (hg x hx)

/-- Clause 5 (`StadiumSafe`) for every game whose cards are all imported cards. -/
theorem stadiumSafeGames (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.StadiumSafe :=
  fun x hx => stadiumSafe_of all_ok x (hg x hx)

/-- **Every game whose cards are all imported cards is `StoreSafe`** (all five clauses: `LoopFree`,
`GXOnly`, `RecycleSafe`, `AbilitySafe` and `StadiumSafe`), so `StoreSafe.xfinite` applies to it. -/
theorem storeSafe (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.StoreSafe :=
  storeSafe_of all_ok recSafe g hg

/-- The finiteness theorem for imported decks: `StoreSafe.xfinite` with its premise discharged; the clamp
is taken at `Enum.bound g₀.allCards`, which bounds every derived HP (milestone M6). -/
theorem xfinite (g₀ : GameState) (hg : ∀ x ∈ g₀.allCards, x ∈ all) :
    (∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp (Enum.bound g₀.allCards) ∈ L) ∧
      ∀ g₁ g₂, Reach g₀ g₁ →
        g₁.xclamp (Enum.bound g₀.allCards) = g₂.xclamp (Enum.bound g₀.allCards) →
        (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧
          g₁'.xclamp (Enum.bound g₀.allCards) = g₂'.xclamp (Enum.bound g₀.allCards)) ∧
        (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧
          g₂'.xclamp (Enum.bound g₀.allCards) = g₁'.xclamp (Enum.bound g₀.allCards)) :=
  StoreSafe.xfinite (storeSafe g₀ hg)

/-- The imported cards with a static HP effect (milestone M6), by name (9). Checked part by part. -/
theorem staticHp : (all.filter (Card.hasStatic Static.isHp)).map Card.label = ["Hero's Cape", "Okidogi", "Gravity Mountain", "Lively Stadium", "Cynthia's Power Weight", "Conkeldurr", "Tyrantrum", "Growing Grass Energy", "Alolan Exeggutor"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_staticHp, Part02.cards_staticHp, Part03.cards_staticHp, Part04.cards_staticHp, Part05.cards_staticHp, Part06.cards_staticHp, Part07.cards_staticHp, Part08.cards_staticHp, Part09.cards_staticHp, Part10.cards_staticHp, List.cons_append, List.nil_append,
    List.append_nil]

/-- The imported cards with a static damage bonus effect (milestone M6), by name (12). Checked part by part. -/
theorem staticBonus : (all.filter (Card.hasStatic Static.isBonus)).map Card.label = ["Maximum Belt", "Okidogi", "Carracosta", "Victini", "Lilligant", "Postwick", "Cynthia's Roserade", "Brave Bangle", "Serperior ex", "Garganacl", "Light Ball", "Voltaic Lightning Energy"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_staticBonus, Part02.cards_staticBonus, Part03.cards_staticBonus, Part04.cards_staticBonus, Part05.cards_staticBonus, Part06.cards_staticBonus, Part07.cards_staticBonus, Part08.cards_staticBonus, Part09.cards_staticBonus, Part10.cards_staticBonus, List.cons_append, List.nil_append,
    List.append_nil]

/-- The imported cards with a static damage reduction effect (milestone M6), by name (16). Checked part by part. -/
theorem staticReduce : (all.filter (Card.hasStatic Static.isReduce)).map Card.label = ["Turtwig", "Full Metal Lab", "Tangrowth", "Dubwool", "Cetitan", "Bronzong", "Furfrou", "Regirock", "Mudsdale", "Granite Cave", "Bouffalant ex", "Klinklang", "Dewgong", "Mega Diancie ex", "Thick Scale", "Kakuna"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_staticReduce, Part02.cards_staticReduce, Part03.cards_staticReduce, Part04.cards_staticReduce, Part05.cards_staticReduce, Part06.cards_staticReduce, Part07.cards_staticReduce, Part08.cards_staticReduce, Part09.cards_staticReduce, Part10.cards_staticReduce, List.cons_append, List.nil_append,
    List.append_nil]

/-- The imported cards with a static Retreat Cost effect (milestone M6), by name (8). Checked part by part. -/
theorem staticRetreat : (all.filter (Card.hasStatic Static.isRetreat)).map Card.label = ["Paradise Resort", "Archaludon", "Gravity Gemstone", "Latias ex", "Toedscruel", "Air Balloon", "Magnetic Metal Energy", "Altaria"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_staticRetreat, Part02.cards_staticRetreat, Part03.cards_staticRetreat, Part04.cards_staticRetreat, Part05.cards_staticRetreat, Part06.cards_staticRetreat, Part07.cards_staticRetreat, Part08.cards_staticRetreat, Part09.cards_staticRetreat, Part10.cards_staticRetreat, List.cons_append, List.nil_append,
    List.append_nil]

/-- Every printed HP of an imported Pokémon is at most 38 counters. -/
theorem printedHp_le : ∀ c ∈ all, c.printedHp ≤ 38 := by
  have h : all.all (fun c => decide (c.printedHp ≤ 38)) = true := by
    simp only [all, List.all_append, Part01.cards_printedHp, Part02.cards_printedHp, Part03.cards_printedHp, Part04.cards_printedHp, Part05.cards_printedHp, Part06.cards_printedHp, Part07.cards_printedHp, Part08.cards_printedHp, Part09.cards_printedHp, Part10.cards_printedHp, Bool.and_self]
  intro c hc
  exact of_decide_eq_true (List.all_eq_true.1 h c hc)

/-- The HP units of the static effects of every imported card (`Card.hpGain`: a constant "+N HP", or
the N of "+N HP for each Energy") are at most 25 counters. -/
theorem hpGain_le : ∀ c ∈ all, c.hpGain ≤ 25 := by
  have h : all.all (fun c => decide (c.hpGain ≤ 25)) = true := by
    simp only [all, List.all_append, Part01.cards_hpGain, Part02.cards_hpGain, Part03.cards_hpGain, Part04.cards_hpGain, Part05.cards_hpGain, Part06.cards_hpGain, Part07.cards_hpGain, Part08.cards_hpGain, Part09.cards_hpGain, Part10.cards_hpGain, Bool.and_self]
  intro c hc
  exact of_decide_eq_true (List.all_eq_true.1 h c hc)

/-- **A bound on derived HP** (milestone M6). In every game whose cards are all imported cards and
number at most `N`, every Pokémon in play has derived HP (`GameState.hpOf`, in counters: printed HP
changed by the static effects in force) at most 38 + 2 (N + 1) (N 25). It is the model's `hpBound`
(`GameState.hpOf_le_hpBound`) bounded with the two constants above; a bound, far from the largest HP
reachable, about the model's terms and not about printed cards. The model has no deck size, hence
the hypothesis on `N`. -/
theorem hpOf_le (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) {N : Nat} (hn : g.allCards.length ≤ N)
    {w : Whose} {sp : Spot} {p : InPlay} (hp : g.In w sp p) :
    g.hpOf w sp p ≤ 38 + 2 * (N + 1) * (N * 25) :=
  hpOf_le_of printedHp_le hpGain_le hg hn hp

/-- The bound for two 60-card decks (120 cards): derived HP at most 726038 counters (7260380 HP). -/
theorem hpOf_le_120 (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) (hn : g.allCards.length ≤ 120)
    {w : Whose} {sp : Spot} {p : InPlay} (hp : g.In w sp p) : g.hpOf w sp p ≤ 726038 :=
  hpOf_le g hg hn hp

/-- The static damage reduction units of every imported card (`Card.reduceGain`: the sum of the
`reduce` constants of its static effects) are at most 5 counters. -/
theorem reduceGain_le : ∀ c ∈ all, c.reduceGain ≤ 5 := by
  have h : all.all (fun c => decide (c.reduceGain ≤ 5)) = true := by
    simp only [all, List.all_append, Part01.cards_reduceGain, Part02.cards_reduceGain, Part03.cards_reduceGain, Part04.cards_reduceGain, Part05.cards_reduceGain, Part06.cards_reduceGain, Part07.cards_reduceGain, Part08.cards_reduceGain, Part09.cards_reduceGain, Part10.cards_reduceGain, Bool.and_self]
  intro c hc
  exact of_decide_eq_true (List.all_eq_true.1 h c hc)

/-- **A bound on static damage reduction** (milestone M6). In every game whose cards are all imported
cards and number at most `N`, the static damage reduction in force (`GameState.sReduce`) is at most the
model's bound `sReduceBound` of the cards, which is at most 2 (N 5). `sReduceBound` is a summand of
`Enum.bound`, so the clamp of `xfinite` caps above it. -/
theorem sReduce_le (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) {N : Nat} (hn : g.allCards.length ≤ N) :
    g.sReduce ≤ sReduceBound g.allCards ∧ sReduceBound g.allCards ≤ 2 * (N * 5) :=
  sReduce_le_of reduceGain_le hg hn

/-- **The imported cards that are not tame** (39), by name. Checked part by part. The tame-deck theorem
`Reach.finite` asks, through `GameState.Fit`, that every card of the game be `Card.tame` (no `drain`, no
stored damage reduction) and that no damage reduction be stored at the start; its clause `ReduceLe`
(Resistance plus `sReduceBound`), new in milestone M6, holds at `Enum.bound` for every game
(`reduceLe_bound`), so static damage reductions do not stand in the way. A deck with one of these cards
is not covered by `Reach.finite`; every game of imported cards is `StoreSafe` (`storeSafe`), and
`StoreSafe.xfinite` (`xfinite`) applies to all of them. -/
theorem untame : (all.filter (fun c => !c.tame)).map Card.label = ["Seedot", "Grotle", "Trevenant", "Torkoal", "Houndoom", "Varoom", "Drifloon", "Tornadus", "Volcarona", "Donphan", "Vibrava", "Skarmory", "Jasmine's Gaze", "Paras", "Hop's Corviknight", "Shelgon", "Hop's Rookidee", "Clamperl", "Virizion", "Sigilyph", "Klink", "Klang", "Genesect ex", "Exeggutor", "Buneary", "Pawmi", "Chikorita", "Stunfisk", "Carkol", "Registeel ex", "Mega Pyroar ex", "Metang", "Mabosstiff", "Cosmoem", "Nidoran ♀", "Zamazenta", "Jangmo-o", "Onix", "Jangmo-o"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_untame, Part02.cards_untame, Part03.cards_untame, Part04.cards_untame, Part05.cards_untame, Part06.cards_untame, Part07.cards_untame, Part08.cards_untame, Part09.cards_untame, Part10.cards_untame, List.cons_append, List.nil_append]

/-- The imported cards with or giving a triggered Ability on `TrigEvent.damaged` (milestone M8b), by name (17). Checked part by part. -/
theorem trigDamaged : (all.filter (Card.hasTrig .damaged)).map Card.label = ["Roselia", "Roserade", "Iron Jugulis", "Heatran", "Lucky Helmet", "Deluxe Bomb", "Bruxish", "Spiky Energy", "Team Rocket's Koffing", "Scolipede", "Punk Helmet", "Numel", "Hop's Pincurchin ex", "Mega Scrafty ex", "Team Rocket's Hypnotizer", "Qwilfish", "Sandslash"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_trigDamaged, Part02.cards_trigDamaged, Part03.cards_trigDamaged, Part04.cards_trigDamaged, Part05.cards_trigDamaged, Part06.cards_trigDamaged, Part07.cards_trigDamaged, Part08.cards_trigDamaged, Part09.cards_trigDamaged, Part10.cards_trigDamaged]
  all_goals rfl

/-- The imported cards with or giving a triggered Ability on `TrigEvent.koByAttack` (milestone M8b), by name (4). Checked part by part. -/
theorem trigKO : (all.filter (Card.hasTrig .koByAttack)).map Card.label = ["Amulet of Hope", "Maractus", "Flygon", "Pecharunt"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_trigKO, Part02.cards_trigKO, Part03.cards_trigKO, Part04.cards_trigKO, Part05.cards_trigKO, Part06.cards_trigKO, Part07.cards_trigKO, Part08.cards_trigKO, Part09.cards_trigKO, Part10.cards_trigKO]
  all_goals rfl

/-- The imported cards with or giving a triggered Ability on `TrigEvent.oppBenched` (milestone MV7) (milestone M8b), by name (2). Checked part by part. -/
theorem trigBenched : (all.filter (Card.hasTrig .oppBenched)).map Card.label = ["Magcargo", "Mismagius ex"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_trigBenched, Part02.cards_trigBenched, Part03.cards_trigBenched, Part04.cards_trigBenched, Part05.cards_trigBenched, Part06.cards_trigBenched, Part07.cards_trigBenched, Part08.cards_trigBenched, Part09.cards_trigBenched, Part10.cards_trigBenched]
  all_goals rfl

/-- The imported cards with or giving a triggered Ability on `TrigEvent.movedUp` (milestone MV7c) (milestone M8b), by name (0). Checked part by part. -/
theorem trigMovedUp : (all.filter (Card.hasTrig .movedUp)).map Card.label = [] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_trigMovedUp, Part02.cards_trigMovedUp, Part03.cards_trigMovedUp, Part04.cards_trigMovedUp, Part05.cards_trigMovedUp, Part06.cards_trigMovedUp, Part07.cards_trigMovedUp, Part08.cards_trigMovedUp, Part09.cards_trigMovedUp, Part10.cards_trigMovedUp]
  all_goals rfl

/-- The imported cards with or giving a triggered Ability on `TrigEvent.movedDown` (milestone MV7c) (milestone M8b), by name (1). Checked part by part. -/
theorem trigMovedDown : (all.filter (Card.hasTrig .movedDown)).map Card.label = ["Clawitzer"] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_trigMovedDown, Part02.cards_trigMovedDown, Part03.cards_trigMovedDown, Part04.cards_trigMovedDown, Part05.cards_trigMovedDown, Part06.cards_trigMovedDown, Part07.cards_trigMovedDown, Part08.cards_trigMovedDown, Part09.cards_trigMovedDown, Part10.cards_trigMovedDown]
  all_goals rfl

/-- The imported cards whose triggered Abilities write a lingering modifier (milestone M8b), by name (0). Checked part by part. -/
theorem trigLingers : (all.filter Card.trigLingers).map Card.label = [] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_trigLingers, Part02.cards_trigLingers, Part03.cards_trigLingers, Part04.cards_trigLingers, Part05.cards_trigLingers, Part06.cards_trigLingers, Part07.cards_trigLingers, Part08.cards_trigLingers, Part09.cards_trigLingers, Part10.cards_trigLingers]
  all_goals rfl

/-- The imported cards whose triggered Abilities can return a card from a discard pile (milestone M8b), by name (0). Checked part by part. -/
theorem trigRecycles : (all.filter Card.trigRecycles).map Card.label = [] := by
  simp only [all, List.filter_append, List.map_append, Part01.cards_trigRecycles, Part02.cards_trigRecycles, Part03.cards_trigRecycles, Part04.cards_trigRecycles, Part05.cards_trigRecycles, Part06.cards_trigRecycles, Part07.cards_trigRecycles, Part08.cards_trigRecycles, Part09.cards_trigRecycles, Part10.cards_trigRecycles]
  all_goals rfl

/-- **Every imported trigger fires wherever its place allows, and resolves an effect of the fragment**
(milestone M8b). For every triggered Ability an imported card has or (a Tool) gives, on its event `ev`,
the model's test `Ability.trigOn ev sp` is the test of its place (`Ability.spotOk sp`): no imported
trigger has a printed condition or an effect outside the trigger fragment, either of which would
silence it; and its effect satisfies `Effect.trigOk`, so it writes no lingering modifier, no store and
no turn flag (`Run.zoneOnly`) and always has a resolution with both Active Spots filled
(`Run.exists_of_trigOk`). Checked part by part. -/
theorem triggers_fire : ∀ c ∈ all, ∀ ab ∈ c.abilities, ∀ ev, ab.use.event = some ev → ∀ sp : Spot,
    ab.trigOn ev sp = ab.spotOk sp ∧ (ab.script ev.place).trigOk = true := by
  have h : all.all Card.trigsOk = true := by
    simp only [all, List.all_append, Part01.cards_trigsOk, Part02.cards_trigsOk, Part03.cards_trigsOk, Part04.cards_trigsOk, Part05.cards_trigsOk, Part06.cards_trigsOk, Part07.cards_trigsOk, Part08.cards_trigsOk, Part09.cards_trigsOk, Part10.cards_trigsOk, Bool.and_self]
  intro c hc ab hab ev he sp
  exact trigOn_of_trigsOk (List.all_eq_true.1 h c hc) hab he sp

/-- Every attack an imported card has or (a Tool) gives is well formed (`Attack.wf`, required by
`Move.attack`). -/
theorem attacks_wf : ∀ c ∈ all, ∀ a ∈ c.attacks, a.wf = true :=
  attacks_wf_of all_ok

/-- Every imported Trainer effect is `hitFree` and `benchHitFree` (required by `Move.item`,
`Move.supporter` and, for a Stadium's effect, `Move.stadiumUse`). -/
theorem trainers_hitFree : ∀ c ∈ all, ∀ n k e ss, c = .trainer n k e ss →
    e.hitFree = true ∧ e.benchHitFree = true :=
  trainers_of all_ok

/-- Every script of every Ability an imported card has or (a Tool) gives has no attack damage step
and no attack damage to the Bench (premises of `Move.ability` and `Move.onPlay`). -/
theorem abilities_hitFree : ∀ c ∈ all, ∀ ab ∈ c.abilities, ∀ e ∈ ab.scripts,
    e.hitFree = true ∧ e.benchHitFree = true :=
  abilities_of all_ok

/-- Every imported card satisfies clause 4 of `StoreSafe` (`Card.abilitySafe`): no imported "as often
as you like" Ability writes a damage bonus or reduction, and no imported Ability a rest-of-game one. -/
theorem abilitySafe : ∀ c ∈ all, c.abilitySafe = true := abilitySafe_of all_ok

/-- Every imported card satisfies clause 1 of `StoreSafe` (`Card.loopFree`, Ability scripts included). -/
theorem loopFree : ∀ c ∈ all, c.loopFree = true := loopFree_of all_ok

/-- Every imported card satisfies clause 5 of `StoreSafe` (`Card.stadiumSafe`): no imported Stadium's
effect writes a rest-of-game bonus or reduction. -/
theorem stadiumSafe : ∀ c ∈ all, c.stadiumSafe = true := stadiumSafe_of all_ok

/-- `GXOnly` over the imported pool: no attack an imported card has or gives that is not a GX attack
writes a rest-of-game bonus or reduction (no imported attack is a GX attack). -/
theorem gxOnly : ∀ c ∈ all, ∀ atk ∈ c.attacks, atk.gx = false →
    atk.effect.amtAt .always = 0 :=
  gxOnly_of all_ok

end PokemonCards.Standard
