"""Survey S16: classification of the importer's refusals (importer 0.9.0, 2026-11-22).

Each blocker of a refused card -- a (reason, sentence) pair recorded by `translate.translate_card` -- is put in one
of three classes, by reading the sentence against the model (Pokemon/Card.lean, Effect.lean, Rules.lean and its Known
gaps), not by the keyword of the refusal:

  I  importer gap: the model as it stands expresses the sentence exactly, or with a departure the Known gaps list (so a
     caveat with a direction can name it); only a translation rule is missing;
  M  model gap: no construct of the model expresses it (the construct is named; constructs are grouped);
  D  deliberate: a term could be written, but it would be wrong in a way no listed departure covers (the reason is
     named).

The table below is ordered; the first entry whose reason pattern and sentence pattern both match (re.search) decides.
A card's class is the worst of its blockers' (M or D beats I). The rules were written by reading every distinct
blocker of the 928 cards refused by importer 0.8.0 (1,003 distinct pairs); `classify` raises on a blocker no entry
matches, so a new refusal cannot be classified silently.

Run: python3 -I tools/importer/s16_classes.py DATASET OUTDIR  (writes S16-refusal-classes.tsv and the counts used by
S16-refusal-classes.md); with --before, classifies the refusals of the translator as it is (use the 0.8.0 translator
to reproduce the survey's table of the 928).
"""
import collections
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# (class, construct or rule, reason regex, sentence regex)
R = []


def c(cls, what, reason='', sent=''):
    R.append((cls, what, re.compile(reason), re.compile(sent)))


# ---------------------------------------------------------------- card-level kinds
# importer 0.15.0 (milestone MV8): the Special Energy cards whose riders the model does not express (S22 §1)
c('M', 'Special Energy riders (on-attach, end-of-turn discard, return after discard, effect prevention, Special Condition '
       'immunity, Bench damage prevention, Prize change)', r'^Special Energy: rider not modelled')
c('M', 'Special Energy (cards and text)', r'^Special Energy$|card named in text is a Special Energy')
c('M', 'Special Energy (cards and text)', '', r'Special Energy|Team Rocket\'s Energy|Voltaic Lightning Energy|Shadowy Darkness Energy|Spiky Energy')
c('M', 'Trainer played as a Pokémon (Fossils)', r'^Trainer played as a Pokémon$|^Ability$')
# importer 0.10.0 (milestone MV4): "Benched Pokémon that has \"Antique\" in its name" reads Fossil Items played as Pokémon
c('M', 'Trainer played as a Pokémon (Fossils)', r'^name substring that no card of that kind contains: Antique')
c('M', 'history: Knock Out of a kind of Pokémon (Count.koLast records any)', r'Knock Out record of a kind of Pokémon')
c('M', 'tests on a Pokémon chosen in the effect (not an Active Pokémon)', r'condition not expressible: that Pokémon is an')
c('I', 'rule: "all of your Pokémon in play are F" (no Pokémon in play outside F)',
  r'condition not expressible: all of your Pokémon in play are')
c('M', 'Trainer played as a Pokémon (Fossils)', '', r'^Play this card as if it were|can\'t be affected by any Special Conditions and can\'t retreat|discard this card from play')
# importer 0.12.0 (milestone MV6)
c('D', 'Count.retreat on a card whose own static effect changes the Retreat Cost: the printed count is off by that effect '
       'whenever the card is in play', r'^count of the Retreat Cost on a card whose own static effect')
c('M', 'draw by a count of the state', r'^revealed hand: clause not expressible', r'draw a card for each')
c('M', "copy an attack or a Supporter's effect", r'^revealed hand: clause not expressible', r'effect of a Supporter card')
c('M', 'data defect or out-of-range stage/Resistance (record)', r'^evolution card with no evolves-from|^stage not Basic|^Resistance not|^rule box kind without')
c('M', 'static effects: prevention or immunity (effects, Special Conditions, healing, thresholds, Bench)', r'static, prevent')
c('M', 'static effects: Ability/Tool/Item/Stadium/attack locks', r'static, lock')
c('M', 'static effects: cost changes and Energy provision', r'static, cost')
c('M', 'filters: name prefix, Ancient/Future, Mega Evolution Pokémon ex, has-an-Ability on the attacker', r'static, filter')
c('M', 'static effects: "has no Retreat Cost" (set form)', r'static, noRetreat')
c('M', 'static effects: stacking rules', r'static, stack')
c('M', 'static effects: change of type or Weakness', r'static, typeWeak')
c('M', 'static effects: conditions read from the state (Prizes, hand, other Pokémon, damage)', r'static, (cond|readsHp|bench|checkup|evolve|toolCount|attacks|play)')
c('M', 'static effects: opponent\'s attacks less damage before Weakness and Resistance', r'static, oppLess')
c('D', 'Backtrack Badge: re-flips change nothing with nondeterministic flips; the term would be inert (notInert)', r'static, coins')
c('M', 'static effects: first-turn rules', r'static \(first-turn rule\)|first-turn limit|once during your first turn')
c('M', 'triggers: other events (Checkup, moves between spots, opponent\'s plays, replacement, Prize changes, other Pokémon)',
  r'triggered|^Stadium: triggered')
c('M', 'Ability conditions: conjunctions, Mega Evolution filter, Bench-place tests, Ability of another Pokémon',
  r'^Ability: condition not expressible|condition on this Pokémon, which may be on the Bench')
c('M', 'history: Supporter played this turn', r'^Ability: condition on the history|^Stadium: activated effect not expressible: a condition on the history')
c('M', 'Ability costs and self Knock Out', r'^Ability: cost not expressible|^Ability: Knocks Out its own')
c('M', 'return from play to hand or deck', r'^Ability: returns its Pokémon')
c('M', 'Abilities used from the hand', r'^Ability: used from the hand')
c('M', 'putBench of a non-Basic card (Bench placement by name)', r'^Bench placement of a named card')
c('M', 'Pokémon Tool texts outside the grant (end-of-turn discard, Mega rule, unclassified Item-like record, subtype filters)',
  r'^Pokémon Tool: (text besides|record text|subtype)')
c('M', 'filters: name prefix', r'name prefix|^Stadium: activated effect not expressible: card kind with no filter: Item cards that have')
c('M', 'Stadium: evolution by effect / turn end', r'^Stadium: activated effect not expressible: (condition not expressible|unhandled)', r'evolve|turn ends|Stage 1 Pokémon that evolves')
c('M', 'Stadium: draw to a count of Pokémon in play', r'^Stadium: activated', r'draw cards until they have as many')
# importer 0.16.0: Community Center's condition is expressible (`Count.played`); its healing is not
c('M', 'heal several Pokémon, heal filtered, heal all of a Benched Pokémon, heal the opponent\'s Pokémon',
  r'^Stadium: activated effect not expressible: unhandled', r'heal 10 damage from each of their Pokémon')
c('M', 'switch with filters (by type, Basic, HP)', r'^Stadium: activated', r'Water Pokémon')
c('M', 'history: per-attack lock, attack used last turn, Supporter played, healed, counted, next-turn trigger', r'MV2\): history')
c('M', 'spread: amount computed by the text or target filtered by damage', r'MV2\): spread')
c('M', 'several cards attached to one chosen Pokémon', r'^several cards to one chosen')
c('M', 'attach a non-Energy card (Tool by effect)', r'^attach a non-Energy card')
c('M', 'effects on the attacker after it switched to the Bench (Attack.wf: switchSafe, ownFree)', r'^attack not well formed in the model')
c('M', 'switch this Pokémon in from anywhere (Ability not restricted to the Bench)', r'switch this Pokémon in, not restricted')
c('M', 'Stadium-slot test ("If you can\'t [discard a Stadium]")', r"^'If you can't' after an action")

# ---------------------------------------------------------------- consequences ("If you do", "in this way")
c('I', 'rule: the opponent\'s hand on the bottom, then draw if any', r'condition not expressible: (they put any cards on the bottom|either player put any cards on the bottom)')
c('M', 'consequence of an action the model may do nothing for (attach, put onto the Bench, heal, move, discard)',
  r'condition not expressible: (you attached|you healed|you moved|you put any|you put \d|you switched|you discarded|you drew|they do|they put|either player put)')
c('M', 'consequence on "that Pokémon" / per-Pokémon targets, or of an untranslated action', r"^'If you (do|can't)' after a sentence with no translation")
c('M', 'Stadium in play test', r"^'If you do' after an action with no exact", r'this attack does \d+ more damage')
c('M', 'consequence of an action the model may do nothing for (attach, put onto the Bench, heal, move, discard)', r"^'If you do' after an action with no exact")

# ---------------------------------------------------------------- conditions (class I where the model has the test)
c('I', 'rule: conditions "X is on your Bench", conjunctions over Bench names', r'condition not expressible: ((\w+) is on your Bench|Beldum and Metang|you don\'t have Uxie and Azelf)')
c('I', 'rule: condition "X is in your discard pile"', r'condition not expressible: Rosa\'s Encouragement is in your discard')
c('I', 'rule: conditions on the deck size and exact Prize counts', r'condition not expressible: (there are \d or fewer cards in your deck|you have exactly \d Prize card|your opponent has exactly 1 Prize|your opponent doesn\'t have exactly)')
c('I', 'rule: conditions on the attacker (Special Conditions, damage counters, Energy typo)', r'condition not expressible: this Pokémon (is Poisoned|is Burned or Poisoned|has 2 or more damage counters|has any Fire Energy attaches)')
c('I', 'rule: conditions on the defender (not ex, exactly N damage counters)', r"condition not expressible: your opponent's Active Pokémon (isn't a Pokémon ex|has exactly 6 damage counters)")
c('I', 'rule: Energy in play count test', r'condition not expressible: you have 3 or more Energy in play')
c('I', 'rule: "Flip N coins. If both/all/any/either …" as one choice', r'condition not expressible: (both of them|either of them is heads|at least 2 of them|all of them are heads|any of them are heads|1 of them is heads|2 of them are heads)')
c('I', 'rule: "Then, flip a coin." in Trainers', r'condition not expressible: (heads|tails)$', r'draw|draws')
c('M', 'heal several Pokémon, heal filtered, heal all of a Benched Pokémon, heal the opponent\'s Pokémon', r'^coin flips not expressible', r'heal all damage from 1 of your Pokémon')
c('M', 'return from play (to hand or deck), discard a Pokémon in play, Knock Out by effect', r'^coin flips not expressible', r'Knock Out 1 of')
c('I', 'rule: multi-coin forms', r'^coin flips not expressible', r'^Flip [23] coins\. If (both|all|any|either|1 of them|at least)')
c('M', 'Stadium in play test', r'condition not expressible: (a Stadium is in play|there is no Stadium|you have a Stadium|your opponent has a Stadium)')
c('M', 'tests on Benched Pokémon\'s damage', r'condition not expressible: (your Benched Pokémon have any damage|all of your Benched|any of your Benched)')
c('M', 'comparisons between two counts (hand sizes, Prize cards, Energy)', r'condition not expressible: (you have more Prize|you have the same number|you don\'t have the same|this Pokémon and your opponent|this Pokémon has more Energy)')
c('M', 'first-turn rules in card text', r'condition not expressible: you go (first|second)|You can use this (attack|card) only if you go second|during your first turn')
c('M', 'Weakness, Resistance and Retreat Cost reads', r'condition not expressible: (the Retreat Cost|your opponent\'s Active Pokémon has (Fighting Resistance|no Retreat Cost))')
c('M', 'Knock Out by this attack as a condition (Prize and next-turn consequences)', r'condition not expressible: (your opponent\'s Pokémon is Knocked Out|you use this attack when)')
c('M', 'reads of the defender before the damage step in a later sentence', r'condition not expressible: your opponent\'s Active Pokémon has no damage counters on it before')
c('M', 'devolution', r'condition not expressible: your opponent\'s Active Pokémon is an evolved')
c('M', 'filters: Ancient/Future, Stage-2-by-name', r'condition not expressible: (your opponent has any Future|you have a Stage 2 card)')
c('M', 'per-attack lock or attack choice (coin to attack)', r'condition not expressible: (tails|either of them is tails)', r"attack doesn't happen|instead of using it")
c('M', 'Prize cards (taken, compared, moved, face up)', r'condition not expressible: (yes|no)$')
c('M', 'hidden information as a game element (guessing)', r'condition not expressible: (they guessed|your opponent guessed)')
c('M', 'per-effect duration on one Pokémon ("this effect ends")', r'condition not expressible: this Pokémon is no longer')
c('M', 'coins counted by the state, or flips decided per target', r'condition not expressible: heads$', r'that Pokémon')
c('M', 'own Special Conditions as attack cost changes', r'condition not expressible: this Pokémon is affected by a Special')
c('M', 'name prefix', r'condition not expressible: .*(Legendary|Community Center)')
c('M', 'comparisons between two counts (hand sizes, Prize cards, Energy)', r'condition not expressible: any of your Pokémon in play are the same type')
# importer 0.17.0 (milestone MV10, survey S24): the coin forms (Tranquill, Trumbeak) are imported; the entry is kept for
# a heads condition on another effect-prevention sentence
c('M', 'prevention of effects of attacks (lingering and static)', r'condition not expressible: heads$', r'effects of attacks')

# ---------------------------------------------------------------- counts
c('I', 'rule: counts by name and kind in play or on the Bench', r'card kind with no filter: (Beedrill and|Drifloon and|Pikachu and)|count not expressible: (of your Benched Charjabug|Stage 2 Pokémon on your Bench)')
c('I', 'rule: Energy attached to both Active Pokémon / all Pokémon / two types', r'count not expressible: (Energy attached to (both Active|all Pokémon)|Fire Energy and each Lightning)')
c('I', 'rule: filters "Stage 2 Darkness Pokémon", searches for several kinds in one sentence', r'card kind with no filter: (Stage 2 Darkness|Evolution Pokémon and an Energy|Stadium card and an Energy|Basic Pokémon, a Stage 1|Item card, a Pokémon Tool|1 Evolution Pokémon)')
c('M', 'counts of Tools, Special Conditions, Prize cards taken, damage on several Pokémon, types, revealed cards, cards moved',
  r'count not expressible|card kind with no filter: (Ancient|Pokémon that have the Hide|Basic Energy cards of different|Pokémon with |Pokémon that are the same type|Pokémon and a Trainer|Basic Grass Energy cards and up to|Supporter cards that have|amount of|number of|Mega Evolution Pokémon ex|Pokémon Tool cards that have|Pokémon that has a maximum HP|Pokémon that has any Fire Energy)')
c('M', 'coins counted by the state, or amounts "up to the number of heads"', r'^coin flips not expressible|^flip until tails', r'up to the number of heads|For each tails|random card')
c('I', 'rule: "Flip a coin until you get tails. For each heads, X." as iter X', r'^flip until tails', r'discard the top card|discard an Energy from your opponent')
c('M', 'coin forms with a damage table (Zangoose) or Knock Out', r'^coin flips not expressible')
c('M', 'Prize cards', r'Prize card', '')

# ---------------------------------------------------------------- unhandled sentences: class I
UH = r'^unhandled sentence|^Ability effect|effect sentence not translated \(unhandled'
c('M', 'effects on the attacker after it switched to the Bench (Attack.wf: switchSafe, ownFree)', r'^unhandled sentence', r'^Attach up to 2 Basic Lightning Energy cards from your hand to this Pokémon\.$')
c('I', 'rule: attach from the hand in attacks; targets "1 of your [Benched] F Pokémon", "your F Pokémon in any way you like"', UH,
  r'^Attach (a|an|up to 2) (Basic (\w+ )?)?Energy cards? from your (hand|discard pile) to (1 of your Pokémon|this Pokémon|1 of your Benched (Pokémon|\w+ Pokémon)|1 of your (Dragon) Pokémon|your (Metal )?Pokémon in any way you like)\.$')
c('I', 'rule: search and attach to 1 of your Benched F Pokémon', UH, r'^Search your deck for (a Basic \w+ Energy card|an Energy card) and attach it to 1 of your Benched \w+ Pokémon\.$')
c('I', 'rule: move an Energy from this Pokémon to a Benched Pokémon (moveEnergy, caveat moveAnyPair)', UH, r'^Move an? (Basic |Water )?Energy from this Pokémon to 1 of your Benched Pokémon\.$')
c('I', 'rule: move an Energy between the opponent\'s Pokémon (moveEnergy opp, caveat moveAnyPair)', UH, r"^(You may move an Energy from your opponent's Active Pokémon to 1 of their Benched Pokémon|Move an Energy from 1 of your opponent's Pokémon to another of their Pokémon)\.$")
c('I', 'rule: "Move a Basic Energy from 1 of your Pokémon to another" (Basic without a type)', UH, r'^Move a Basic Energy from 1 of your Pokémon to another of your Pokémon\.$')
c('I', 'rule: "You may draw cards until you have N"', UH, r'^You may draw cards until you have \d+ cards in your hand\.$')
c('I', 'rule: hand into deck and draw (each player / the opponent)', UH, r'^(Each player|Your opponent) shuffles their hand into their deck and draws \d+ cards\.$')
c('I', 'rule: the opponent\'s hand on the bottom, then draw if any', UH, r'^Your opponent shuffles their hand and puts it on the bottom of their deck\.$')
c('I', 'rule: random card of the opponent\'s hand shuffled into their deck', UH, r'^(Choose a random card from your opponent\'s hand|Your opponent reveals that card and shuffles it into their deck)\.$|^Choose a random card from your opponent\'s hand, and your opponent reveals')
c('I', 'rule: search 2, shuffle, put on top (Ciphermaniac)', UH, r'^Search your deck for 2 cards, shuffle your deck, then put')
c('I', 'rule: discard an Energy from 1 of the opponent\'s Pokémon', UH, r"^Discard an Energy from 1 of your opponent's Pokémon\.$")
c('I', 'rule: any number of Basic Pokémon onto the Bench', UH, r'^Search your deck for any number of Basic Pokémon and put them onto your Bench\.$')
c('I', 'rule: play condition on the opponent\'s Prize cards', UH, r'^You can use this card only if your opponent has 3 or fewer Prize')
c('I', 'rule: look at the top N, put K into the hand, discard the other cards', UH, r'^(Look at the top 6 cards of your deck and put 2 of them into your hand|Discard the other cards)\.$')
c('I', 'rule: look at the top card, may discard it (attacks)', UH, r'^(Look at the top card of your deck|You may discard that card)\.$')
c('I', 'rule: search and discard in Trainers', UH, r'^Search your deck for up to \d+ cards and discard them\.$')
c('I', 'rule: damage to each of the opponent\'s Pokémon ex', UH, r"^This attack does \d+ damage to each of your opponent's Pokémon ex( and Pokémon V)?\.$")
c('I', 'rule: "to each of 2 of your opponent\'s Pokémon"', UH, r"^This attack does \d+ damage to each of 2 of your opponent's Pokémon\.$")
c('I', 'rule: "Then, flip a coin." in Trainers', UH, r'^Then, flip a coin\.$')
c('I', 'rule: inflict with lower-case condition (data typo), and "It is now X" after an inflict', UH, r"^(Your opponent's Active Pokémon is now paralyzed|It is now Paralyzed)\.$")
c('I', 'rule: two effects in one sentence (inflict and discard, discard and inflict, damage and heal)', UH,
  r"^(Your opponent's Active Pokémon is now Paralyzed, and discard an Energy|Discard 2 Energy from this Pokémon, and your opponent's|This attack does 30 more damage, and heal 30)")
c('I', 'rule: mill both decks', UH, r'^Discard the top card of each player\'s deck\.$')
c('I', 'rule: "Heal N damage from this Pokémon" without a final period (data)', UH, r'^Heal 50 damage from this Pokémon$')
c('I', 'rule: "You may discard your hand."', UH, r'^You may discard your hand\.$')
c('I', 'rule: "Shuffle the other cards back into your deck" after a translated look', UH, r'^Shuffle the other cards back into your deck\.$')
c('I', 'rule: discard up to N Energy from this Pokémon / hand, then damage for each (two sentences)', UH, r'^Discard up to \d+ (Metal |Fire )?Energy( cards)? from (this Pokémon|your hand)\.$')
c('I', 'rule: "Discard all Pokémon Tools from this Pokémon" before damage, with "If you can\'t discard any"', UH, r'^(Before doing damage, discard all Pokémon Tools from this Pokémon|If you can\'t discard any, this attack does nothing)\.$')
c('I', 'rule: "Draw 2 more cards." / "Draw 8 cards instead" (conditional draws on translated tests)', UH, r'^(Draw 2 more cards|Draw 8 cards instead)\.$')
c('I', 'rule: "You may do N more damage" as a damage choice', UH, r'^You may do \d+ more damage\.$')
c('I', 'rule: switch out the opponent\'s Active Pokémon (wording variants)', UH, r"^Switch out your (oppoennt|opponent)'s Active Pokémon to the Bench\.|^\(Your opponent chooses the new Active")
c('I', 'rule: damage to the new Active Pokémon after a gust (when the Bench is empty, no damage)', UH, r'^This attack does \d+ damage to the new Active Pokémon\.$')
c('I', 'rule: Rule-Box reminder in a filter sentence', UH, r'^\(Pokémon ex, Pokémon V(_atk)?, etc\. have Rule Boxes\.\)$|^\(Apply Weakness as x2\.\)$|^\(Don\'t apply Weakness and Resistance for Benched Pokémon\.$')

# ---------------------------------------------------------------- unhandled sentences: class D
c('D', 'heal 20 and remove ONE Special Condition: `cure` removes all (forbids keeping the others; no listed departure)', UH, r'remove a Special Condition|recover from a Special Condition')
# importer 0.12.0: `Effect.look` reads a fixed window, so the moving-window reason of importer 0.8.0 is gone; what is left of
# the row (Grimsley's Move, refused by its first-turn rule) is a window rule not written, class I
c('I', 'rule: window, a mandatory card onto the Bench (written for no card: Grimsley\'s Move has a first-turn rule)', UH,
  r'^Look at the top \d+ cards of your deck and put a Darkness')
c('D', 'look at the top N and attach / bench "any number" from it: repeated primitives read a moving window (top N of the current deck)', UH,
  r'^Look at the top \d+ cards of your deck(,)? (and attach|and you may put any number|and put a Darkness)|^You may put any number of Pokémon you find there onto your Bench')

# ---------------------------------------------------------------- unhandled sentences: class M
c('M', 'own Special Conditions (effects that affect the attacker)', UH, r'^This Pokémon is now (Asleep|Confused)|^Both Active Pokémon are now|^Both Active non-Darkness')
# importer 0.17.0 (milestone MV10, survey S24): "During your opponent's next turn, prevent all damage from and effects of
# attacks done to this Pokémon" is imported (`Mod.shield`); what is left here is the filtered or chosen form ("done to
# that Pokémon by your opponent's Pokémon ex", Acerola's Mischief), which needs a per-Pokémon, filtered flag
c('M', 'prevention of effects of attacks (lingering and static)', UH, r'prevent all damage from and effects of|effects of attacks')
c('M', 'filtered lingering modifiers (prevention, reduction, bonus by attacker or holder kind; thresholds)', UH,
  r'prevent all damage (done to this Pokémon by attacks (from|if)|done to each of your)|takes \d+ less damage from attacks from|attacks used by your (Fighting|Pokémon that don\'t|Pokémon do \d+ more damage to your opponent\'s Active Pokémon ex)|all of your Metal Pokémon take|Active Pokémon ex and Active Pokémon V')
c('M', 'defender modifiers outside steps 2 and 5 (less before W/R, more after W/R, Weakness changes, named-attack bonus, base-damage set, cost changes)', UH,
  r'do \d+ less damage \(before|takes \d+ more damage from attacks|Weakness is now|has no Weakness|attack does \d+ more damage \(before|base damage is|cost Colorless more|can be used for|Weakness doesn\'t change')
c('M', 'locks: Supporters, Stadiums, evolution, Energy attachment, retreat of Poisoned, attack coin, per-attack lock', UH,
  r"can't play any (Supporter|Stadium)|can't play any Pokémon from their hand to evolve|Energy (cards )?can't be attached|Poisoned Pokémon can't retreat|tries to use an attack|try to use a Trainer|can't use that attack|can't use Blaze Blitz|It can't attack during|Pokémon that have \d or less Energy attached can't attack")
c('M', 'heal several Pokémon, heal filtered, heal all of a Benched Pokémon, heal the opponent\'s Pokémon', UH, r'^Heal |For each Tasty Rice Ball|^Heal 30 damage from it')
c('M', 'Energy to the hand or deck, Energy moves of several or all, Energy moves "in any way you like"', UH,
  r'Energy attached to .* into (your|their) hand|Energy attached to this Pokémon into your deck|Move (all|up to 2|3) Energy|move any amount of|Move all Energy|Energy from the Pokémon you moved|shuffle those Energy cards')
c('M', 'return from play (to hand or deck), discard a Pokémon in play, Knock Out by effect', UH,
  r'all attached cards (into|,)|Discard this Pokémon and all|Knocked Out\.$|^Knock Out|is Knocked Out|Discard 6 Basic Grass .* Knock Out|put this Pokémon into your hand|Then, return the Pokémon')
c('M', 'evolution and devolution by effect, switching with cards outside play', UH, r'evolves from|[Dd]evolve|switch it with|Any attached cards, damage counters|Choose 1 of your Basic Pokémon in play|can\'t evolve this turn|works one time for 2|Transformation Tome|put down when you were setting up')
c('M', 'copy an attack or a Supporter\'s effect', UH, r'use it as this attack|as the effect of this attack|Choose \d of your opponent\'s Active Pokémon\'s attacks\.|choose 1 of its attacks')
c('M', 'Prize cards (taken, moved, face up)', UH, r'Prize card|Prize cards')
c('M', 'look or reveal and choose from a fixed set (top/bottom of a deck, the opponent\'s hand), "the other cards"', UH,
  r'^Look at|^Reveal|reveals their hand|^Then, shuffle any revealed|^Then, discard those|^Shuffle the other cards and put them on the bottom|^Shuffle the revealed|^Your opponent shuffles the other cards|^Put the other cards back|^You may reveal|you find there|^Discard a card you find|^Discard all Item cards and Pokémon Tool cards you find|^For each heads, choose a card you find|Your opponent reveals those cards|^Your opponent reveals that card\.$|^Draw 3 cards from the bottom|from your hand with the top card|in any order|^Shuffle your deck, then put that card on top|^Search your deck for a card\.$|bottom \d+ cards')
c('M', 'damage counters or damage spread with computed amounts, on several chosen, "until remaining HP", doubling, damage to own named Pokémon', UH,
  r'damage counters on (each|your opponent\'s Active Pokémon until|this Pokémon\.$)|until its remaining HP|Double the number|Put up to \d+ damage counters on this|Choose \d+ of your opponent\'s|Choose 1 of your opponent\'s (Pokémon|Benched)|For each time you chose|damage counters from|to each Pokémon that has any damage|to each of your Drifloon|for each card in your hand|for each damage counter on it|Prize card your opponent has taken|damage to the chosen Pokémon|also does 10 damage to itself for each|Pokémon that has any Special Energy|isn\'t affected by Weakness or Resistance, or by any effects on those|This damage isn\'t affected')
c('M', 'coins counted by the state ("Flip a coin for each …") and their amounts', UH, r'^Flip a coin for each|for each heads|for each tails|^For each heads|^For each of your opponent\'s Pokémon, flip|flips a coin for each')
c('M', 'per-Benched-Pokémon effects ("for each of your Benched Pokémon …", "each of your Future Pokémon", "choose up to 2 …")', UH, r'^For each of|to each of your (Future|Benched) Pokémon|Choose up to 2 of your|Choose up to 2 Pokémon Tools')
c('M', 'Tools and Special Energy of the opponent (discard several or all, by filter)', UH, r'Pokémon Tools? (and|or)|Discard up to 2 Pokémon Tools|discard all Pokémon Tools and')
c('M', 'switch with filters (Basic, type, HP, except a name)', UH, r'^Switch (in 1 of your opponent\'s Benched (Basic|Pokémon that has)|1 of your Benched Darkness|this Pokémon with 1 of your Benched Lightning)|^The new Active Pokémon is now|^Kieran|^Choose 1:')
c('M', 'attach "any number", from the opponent\'s discard pile, to several named Pokémon, or "a, b, or 1 of each"', UH,
  r'attach any number|Attach up to 3 Energy cards from your opponent\'s|or 1 of each|Each player may attach|to each of your Benched|Attach the other to|N\'s Pokémon|to your Future Pokémon|Tera Pokémon in any way|Choose Basic Lightning Energy|any number of Basic Water Energy')
c('M', 'discards from several Pokémon or "any amount" from all, with counts of discarded cards', UH,
  r'from (among )?your (Benched )?Pokémon|Discard up to 3 Grass Energy cards from your Pokémon|Discard the top \d+ cards of your deck, and this attack|discarded in this way|Discard a (Fire|Pokémon Tool)|Discard all Energy from this Pokémon (and place|, and take)|Shuffle all Energy attached|You may (discard|put|shuffle) (\d+|all|a Water) ')
c('M', 'hand-size and player choices of the opponent (discard until N, choose 3, count then draw, discard first)', UH,
  r'until (they|it) ha|discards cards from their hand until|chooses 3 cards|counts the cards|discards first|does this first|Your opponent shuffles their hand and puts|Each player shuffles their hand and puts|they do not discard|At the end of this turn|Before drawing cards|You may discard any number of cards from your hand|Choose a Special Condition|Choose Burned|affected by that Special Condition|choose Basic Pokémon you find|onto (their|your opponent\'s) Bench|have your opponent shuffle')
c('M', 'delayed effects at the end of a turn, turn end, extra card plays', UH, r'^At the end of your opponent\'s next turn|Your turn ends|must play 2|You can use this card only|You can\'t use this card|Ask your opponent|Tell your opponent|guesses|Count your Prize')
c('M', 'draw by a count of the state', UH, r'^(Then, )?[Dd]raw a card for each|draw 3 cards for each|if you have 10 or more cards in your hand, draw|if you have exactly 30')
c('M', 'card searches with kinds the model lacks (different types, any number of a name)', UH, r'of different types|any number of Fennel|that have "Rotom"|Discard up to 2 Pokémon that don\'t have|Search your deck for a Basic Psychic Energy card, a Basic Metal|Search your deck for up to 2 Basic Energy cards and attach them to your Future')
c('M', 'Stadium of the opponent ("discard that Stadium")', UH, r'discard that Stadium')
c('M', 'own deck milled to hand ("Discard the top 3 and put 1 into your hand"), switch hand cards with deck', UH, r'^Discard the top 3 cards of your deck and put 1')
c('M', 'discard rider "can\'t be put into your hand or deck" (Item text)', UH, r"can't be put into your hand or deck|Pokémon in play and all attached cards can't")
c('M', 'Energy of a kind on the opponent\'s Active Pokémon ex', UH, r'Active Pokémon ex\.$')
c('M', 'discard several kinds of Energy at once ("a Fire, a Water and a Lightning")', UH, r'a Fire Energy, a Water Energy')
c('M', 'reminder belonging to a refused sentence', UH, r'^\((If a player|If you can\'t|This includes|You can choose|That Prize|The amount|Discard all cards attached)')
c('M', 'per-Pokémon Bench placement from the opponent\'s hand or deck', UH, r'onto your opponent\'s Bench|Put up to 2 Basic Pokémon you find there')
c('M', 'Energy discarded "up to" from several of the player\'s Pokémon', UH, r'^You may discard up to 2 (Basic )?Energy from your Benched')
c('M', 'Supporter effects that replace or extend other effects', UH, r'^Draw \d+ more|instead\.$')
c('M', 'coins counted by the state ("Flip a coin for each …") and their amounts', UH, r'^For each tails')
c('M', 'first-turn rules in card text', UH, r'only if you go second')
c('M', 'triggers on the opponent\'s actions (Energy attachment) in the next turn', UH, r'attach an Energy card from their hand to the Defending')
c('M', 'Burn strength (numbered Burn)', UH, r'instead of 3 on that Pokémon for this Special Condition')
c('I', 'rule: Poison strength, "place" wording', UH, r'^During Pokémon Checkup, place \d+ damage counters on that Pokémon instead of 1\.$')
c('I', 'rule: discard the hand and search for several kinds', UH, r'^Discard your hand and search your deck for a Pokémon, a Supporter card, and a Basic Energy card')
c('M', 'Knock Out by effect (with recoil)', UH, r'^This Pokémon does 100 damage to itself')
c('M', 'Prize cards (taken, moved, face up)', UH, r'switch those cards')
c('M', 'reminder belonging to a refused sentence', UH, r'^Then, shuffle those cards into your deck')
c('M', 'per-Pokémon targets chosen in an earlier sentence ("Choose 1 of your Pokémon in play")', UH, r'^Choose 1 of your Pokémon in play')
c('I', 'rule: optional recoil with a Special Condition ("You may have this Pokémon also do N damage to itself and make …")', UH, r'^You may have this Pokémon also do')
c('M', 'several cards attached to one chosen Pokémon', UH, r'^Attach up to 2 Basic (Metal )?Energy cards from your discard pile to 1 of your')
c('I', 'rule: "Choose 1 or both" with two bulleted Trainer effects', UH, r'^Choose 1 or both:|^• Shuffle up to 3')
c('I', 'rule: lingering prevention, wording "prevent all damage from attacks done to this Pokémon"', UH, r'^During your opponent\'s next turn, prevent all damage from attacks done to this Pokémon\.$')
c('M', 'other effects with no construct (listed in the TSV by sentence)', UH, '')


def classify(reason, sent):
    for cls, what, rr, rs in R:
        if rr.search(reason) and rs.search(sent):
            return cls, what
    return '?', 'UNCLASSIFIED'


ORDER = {'I': 0, 'D': 1, 'M': 1}


def card_class(classes):
    """The worst class of the card's blockers: M or D beats I; between M and D, M (a missing construct) is reported
    first, D only when no blocker is M."""
    s = set(classes)
    return 'M' if 'M' in s else 'D' if 'D' in s else 'I'


def main(argv):
    import importlib.util
    import pool
    import importer as IM
    data, outdir = argv[1], argv[2]
    # the translator whose refusals are classified (default: this directory's; the survey used importer 0.8.0's,
    # `git show 830eb42:tools/importer/translate.py`), and the current one, for the status after this round
    TR_now = IM.TR
    if len(argv) > 3:
        spec = importlib.util.spec_from_file_location('translate_before', argv[3])
        TR = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(TR)
    else:
        TR = TR_now
    _, cards = pool.load(data)
    TR.set_names(cards)
    TR_now.set_names(cards)
    G = pool.group(pool.standard_pool(cards))
    rows = [('id', 'name', 'kind', 'class', 'card_class', 'missing construct or rule', 'reason', 'sentence', 'imported_' + IM.VERSION)]
    per_card = []
    for recs in G:
        r = TR.translate_card(recs[0])
        if r['ok']:
            continue
        x = recs[0]
        cl = [(classify(a, b), a, b) for a, b in r['blockers']]
        cc = card_class(k[0] for k, _, _ in cl)
        now = TR_now.translate_card(x)['ok']
        per_card.append({'id': x['id'], 'name': x['name'], 'kind': IM.kind_of(x), 'class': cc, 'now': now,
                         'blockers': [(k[0], k[1], a, b) for k, a, b in cl]})
        for (k, what), a, b in cl:
            rows.append((x['id'], x['name'], IM.kind_of(x), k, cc, what, a, b, 'yes' if now else 'no'))
    with open(os.path.join(outdir, 'S16-refusal-classes.tsv'), 'w', encoding='utf-8') as f:
        for row in rows:
            f.write('\t'.join(str(v).replace('\t', ' ').replace('\n', ' ') for v in row) + '\n')
    with open(os.path.join(outdir, 'S16-cards.json'), 'w', encoding='utf-8') as f:
        json.dump(per_card, f, ensure_ascii=False, indent=0)
    bad = sorted({(a, b) for p in per_card for k, w, a, b in p['blockers'] if k == '?'})
    for a, b in bad:
        print('UNCLASSIFIED', a[:80], '|', b[:150])
    if bad:
        sys.exit(1)
    print(collections.Counter(p['class'] for p in per_card), len(per_card))


if __name__ == '__main__':
    main(sys.argv)
