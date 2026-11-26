"""Translate one card record into a term of the model's card language, or refuse it.

Conservative by design: a card is accepted only if every static field is in the model's range and
every sentence of its text is matched by a rule of the table below (`RULES`, plus the multi-sentence
forms in `Parser`), each of which is meant to say exactly what the sentence says under the model's
semantics (Pokemon/Effect.lean, Pokemon/Rules.lean). A rule that knowingly loses a detail named in
the model's Known gaps attaches a caveat code (`CAVEATS`); such cards are counted apart. Anything
else blocks the card, and every blocker is recorded (not only the first), so that the coverage report
can rank the mechanisms by how many cards each blocks alone.

Abilities (milestone M8a, `translate_ability`): activated ("Once during your turn", "As often as you
like during your turn") and on-play ("When you play this Pokémon from your hand …") Abilities whose
conditions are a place or one test of the model and whose every sentence matches a rule; first-turn
rules, self Knock Outs, uses from the hand, returns from play and conditions the model cannot test are
refused with a reason that starts with 'Ability: '.

Triggered Abilities (milestone M8b, `translate_trigger`, importer 0.6.0): the two shapes the model has
("… is in the Active Spot and is damaged by an attack from your opponent's Pokémon (even if this Pokémon
is Knocked Out), …" and "… is Knocked Out by damage from an attack from your opponent's Pokémon, …"), on a
Pokémon's Ability or as a Tool's text, when the effect translates by the ordinary rules into the trigger
fragment (`Effect.trigOk`); the qualifiers and their caveats are documented above `TRIG_SUBJ_POKEMON`.
Other triggered text is refused with a reason that starts with 'Ability: triggered' or 'Pokémon Tool:
triggered'.

Static text (milestone M6, `parse_static`): a static Ability, a Pokémon Tool's or a Stadium's text is
written as the model's `Static` effects only in the shapes listed there (HP plus or minus, a damage bonus
before Weakness and Resistance, a damage reduction after them, Retreat Cost more or less, with the
model's selectors, filters, places and Energy conditions); everything else static is refused with a
reason code (`STATIC_CODES`), stacking rules included.

Milestone MV3 (importer 0.8.0): the five "This attack's damage isn't affected by …" variants (`Effect.damage a ig`,
rule 'damage-ignores'); "A. If you do, B." as `Effect.ifDone t a b` over the actions listed above `done_action`, each
with the test that holds exactly when the action can be done; "… If you can't [discard N cards in this way], this
attack does nothing." over the exact costs of `cost_action`; "discard up to N / any amount …, and this attack does K
damage for each card you discarded in this way" and "Discard all F Energy from this Pokémon. This attack does K damage
for each card you discarded in this way." as an unfolded `Effect.forUpTo` (`Parser.mv3_step`); static "Prevent all
damage done to this Pokémon by attacks from your opponent's F" as `SEff.prevent` (`static_ability_sentence`). Not
written: `Effect.mayDo`, consequences of `attach` / `putBench` / `moveEnergy` (which may do nothing in the model),
filtered lingering prevention.

Milestone MV10 (importer 0.17.0, survey S24): "During your opponent's next turn, prevent all damage from and effects of
attacks done to this Pokémon" as `linger own next prevent; linger own next shield` (rule 'ling-shield-self'; caveats
perPokemon, shieldReach); the static "Prevent all effects of attacks used by your opponent's F done to this Pokémon /
to your G / to the G this card is attached to" and "Prevent all damage from and effects of attacks from your opponent's
F done to this Pokémon" as `SEff.shield` (with `SEff.prevent` for the second; caveats shieldActive, shieldReach), their
reminders "(Existing effects are not removed. Damage is not an effect.)" dropped; a source in force only on the Bench is
refused. "Flip a coin. If tails, this attack does nothing. If heads, X." as the attack on heads with X.
"""
import re

import noop as N
import terms as T
from terms import OWN, OPP, SKIP, seq, choice, ite

# Energy filters (milestone MV5, Pokemon/Card.lean `Filter`): an Energy card is Basic or Special (`EnergyCard`).
# Printed "Energy card(s)" with no qualifier is `energy`, which passes both kinds; "Basic Energy card(s)" is
# `basicEnergy`; "Special Energy" is `specialEnergy`; "Basic Fire Energy" and "Fire Energy" are `energyOf .fire`, which
# passes Basic Fire Energy only. For a card in a deck, hand or discard pile "a Fire Energy card" is a Basic Energy card
# (2026 rulebook, glossary p. 43: "Basic Energy card: A Grass, Fire, … or Fairy Energy card"); for Energy attached to a
# Pokémon print reads a type by what the Energy provides, so `energyOf` in a count or test reads less than print once a
# Special Energy card that provides that type is in play (Known gaps, Energy item). Until importer 0.14.0 that was vacuous
# in a game of imported cards (none was a Special Energy card); since 0.15.0 it is not, and `energy_caveats` marks every
# such reader (caveats energyOfBasic, energyOfCount).
ENERGY_F = ('energy',)
BASIC_F = ('basicEnergy',)
SPECIAL_F = ('specialEnergy',)


def is_energy_filter(f):
    """A filter only Energy cards pass (what `attach` may take: `ZStep.attachActive` takes an Energy card anyway, so
    this keeps the printed kind visible): the Energy filters above, or the name of a Special Energy card."""
    if f in (ENERGY_F, BASIC_F, SPECIAL_F) or f[0] == 'energyOf':
        return True
    return f[0] == 'named' and KNOWN_NAMES.get(f[1]) == {'Special Energy'}

CAVEATS = {
    'perPokemon': "a lingering effect printed on one Pokémon ('this Pokémon', 'the Defending Pokémon') "
                  "is a modifier of its player in the model (Known gaps: modifiers belong to a player)",
    'recoil': "self-damage ('also does N damage to itself') is written as damage counters (selfDamage): "
              "no Weakness, Resistance or modifier applies to it (Known gaps)",
    'benchMods': "attack damage to Benched Pokémon takes no bonus, reduction or stored (lingering) prevention in the "
                 "model; since milestone MV13 a static prevention in force on the Benched Pokémon is read (Known gaps, "
                 "milestone M3)",
    'mayFail': "an attach or Bench placement may do nothing in the model (`attach` and `putBench` always allow "
               "nothing), a superset of the printed 'attach a …' from the hand or discard pile, and of 'if you can' "
               "(Known gaps)",
    'upTo0': "'up to N' in a Trainer or an Ability allows 0 in the model; the rulebook asks for at least 1 outside "
             "attacks (2026 rulebook p. 21; Known gaps, zone moves item)",
    'hiddenInfo': "a sentence that only reveals or looks at cards is a no-op (hidden information is not "
                  "modelled, Known gaps)",
    'aceSpec': "the ACE SPEC deck-building limit is not modelled (no deck construction in the model)",
    'poisonStrength': "a stronger Poison ('N damage counters instead of 1') is written as Poison plus "
                      "poisonUp (N-1), which a later Poison resets and Croagunk's increase adds to (Known gaps, Special "
                      "Conditions: a variant with a number has no constructor of its own)",
    'selfInDiscard': "the model resolves a Trainer with the card already in the discard pile, so its "
                     "recycling filter or discard count can see the card itself (Known gaps)",
    'searchAny': "a deck search for 'a card' (any card) may find nothing in the model, where print must take at least 1 "
                 "(2026 rulebook p. 21: 'for any effect that allows you to search your deck or discard pile for any card you "
                 "want and doesn't specify what kind, you must choose at least 1'; Known gaps, zone moves item: 'a superset "
                 "elsewhere and for an attack that searches for any card')",
    'noopPlay': "a Trainer (an Item, a Supporter, a Stadium's use) whose effect may do nothing in the model in a state where "
                "it could do something (heal 30 damage from 1 of your Pokémon: the model may heal an undamaged one, as it "
                "has no test of a Benched Pokémon's damage) can be played to no effect there. The importer reads the usual "
                "ruling, not in the rulebook (2026 p. 12 says only 'When you play any Trainer card, do what it says'): a "
                "card may not be played when its effect cannot do anything, except that a search of a hidden zone may find "
                "nothing; where public information decides it the term states the precondition instead (noop.py; Known "
                "gaps, item on plays to no effect)",
    'koBetweenSteps': "a Trainer or Ability sentence written as several primitives gets a Knock Out check between "
                      "them, and after a Knock Out later steps act on the replacement (Known gaps, TRun, M8a)",
    'noopUse': "an activated Ability whose effect may do nothing in the model in a state where it could do something (as "
               "noopPlay) can be used to no effect there, marking its Pokémon as used; the importer reads the ruling of "
               "noopPlay for Abilities too, and states the precondition where public information decides it (noop.py; "
               "Known gaps, item on plays to no effect)",
    'selfBench': "'this Pokémon' on the Bench is a Benched Pokémon chosen when each step resolves (each `SelfOp` step "
                 "chooses its own, so two attach steps may go to two different Benched Pokémon), and for an on-play "
                 "Ability the Active Pokémon or a Benched one (Known gaps, Abilities, M8a: `SelfOp`)",
    'moveAnyPair': "a move of Energy printed between particular Pokémon ('to this Pokémon', 'from 1 of your Benched "
                   "Pokémon to your Active Pokémon') is a move between any two of the player's Pokémon (moveEnergy)",
    'onePerName': "'You can't use more than 1 X Ability each turn' is not modelled: the use flag is per Pokémon, so "
                  "each of several Pokémon with that Ability can use it in the same turn",
    'staticBench': "a static damage reduction ('takes N less damage from attacks') is subtracted at step 5 of the "
                   "damage calculation, which only damage to the Active Pokémon passes through: attack damage to a "
                   "Benched Pokémon takes no reduction in the model (Known gaps, milestone M3: Bench damage takes no "
                   "bonus, reduction or prevention; milestone M6)",
    'toolAbilityFlag': "an Ability a Pokémon Tool gives shares the use flag of the Pokémon it is attached to (`InPlay.used`), "
                       "so a Pokémon with an Ability of its own and one from a Tool uses only one of them in a turn "
                       "(Known gaps, M5)",
    'trigDamaged': "'is in the Active Spot and is damaged by an attack' is decided on the attack's damage step (HitRun, "
                   "HitTrig): a Pokémon damaged and then switched to the Bench by the same attack fires nothing, and when "
                   "the Defending Pokémon was already at or above its HP before the damage step the trigger may fire or "
                   "not (Known gaps, triggered Abilities, M8b: the two departures, one in each direction)",
    'trigKO': "'is Knocked Out by damage from an attack' is read as 'Knocked Out by a Knock Out check while the turn's "
              "attack has been made': Knock Outs by damage counters the attack placed, by later rounds of the check, "
              "and in the check after a failed Confused attempt also fire it (Known gaps, triggered Abilities, M8b)",
    'trigAttacker': "'the Attacking Pokémon' is the opponent's Active Pokémon when the trigger resolves: if the attack "
                    "switched its attacker out ('damaged'), or the attacker was Knocked Out by the same check "
                    "('Knocked Out'), the effect falls on the new Active Pokémon instead of the attacker or nothing "
                    "(Known gaps, triggered Abilities, M8b)",
    'koAttackWide': "'Knocked Out by damage from an attack during your opponent's last turn' is read as 'Knocked Out by the "
                    "Knock Out check after the turn's attack' (`Count.koLast w true`): Knock Outs by damage counters an "
                    "attack's effect placed also count (Known gaps, one-turn history, milestone MV2)",
    'koCheckup': "'Knocked Out during your opponent's last turn' (any cause) is `Count.koLast w false`, and the model "
                 "records Knock Outs at Pokémon Checkup in no turn (Known gaps, one-turn history, milestone MV2): a Knock Out "
                 "by Poison or Burn after the opponent's turn does not make the test true; whether the printed condition "
                 "counts it was not checked against a ruling",
    'movedUpPromotion': "'moved from your Bench to the Active Spot this turn' is `InPlay.movedUp`, which a promotion after a "
                        "Knock Out of the player's own Active Pokémon in their own turn does not set (Known gaps, one-turn "
                        "history, milestone MV2: an under-model)",
    'staticPreventBench': "a static prevention ('Prevent all damage done to this Pokémon by attacks from your opponent's F', "
                          "`SEff.prevent`, milestone MV3) protects the Pokémon only in the Active Spot: attack damage to a "
                          "Benched Pokémon reads no static effect in the model (Known gaps, milestone M3: Bench damage takes "
                          "no bonus, reduction or prevention; `GameState.sPrevent` is read at step 5, for the Active Pokémon)",
    'ignFxStadium': "'isn't affected by any effects on your opponent's Active Pokémon' (`Ign.fx`, milestone MV3) switches "
                    "off step 5 of the damage calculation, which in the model includes the reductions and preventions a "
                    "Stadium gives the defender (Known gaps, Weakness and Resistance item: `Ign`, step 5); whether the "
                    "printed text ignores a Stadium's effect was not checked against a ruling",
    'anyAmount60': "'discard any amount / all … for each card you discarded in this way' is `forUpTo` with the bound 60, the "
                   "cards of a legal deck (2026 rulebook p. 21): exact for every state in which the player has at most 60 "
                   "cards that could be discarded (`Run.forUpTo_complete`, `discardActive_le`); the model does not require "
                   "this of a start state, and beyond it a larger discard is forbidden (Known gaps, zone moves item: "
                   "'exact for \"any amount\" once the bound covers the cards that can be taken'); for 'discard all' with more than 60 the attack has "
                   "no resolution",
    'abilityByTool': "'Pokémon that have an Ability' is `Filter.hasAbility`, which reads the printed Abilities and ignores an "
                     "Ability a Tool gives in the model (Known gaps, filters: whether print counts a Tool's effect as the "
                     "Pokémon's Ability is not settled); if it does, a Pokémon whose Ability comes from a Tool is not "
                     "counted where print counts it, and an attacker with such an Ability is not prevented where print "
                     "prevents its damage",
    'prizes6': "'Prize cards taken' is `Count.prizesTaken w`, 6 less the Prize cards left (milestone MV4): exact in a game set "
               "up with 6 Prize cards (2026 rulebook p. 8), which the model does not require of a start state (Known gaps: "
               "setup is not modelled; `Count.prizesTaken`); from another start it is the shortfall from 6, at least 0",
    'moveMayFail': "a move of Energy is `moveEnergy`, which may move nothing (`moveNone`; Known gaps, zone moves item: "
                   "'attach, putBench and moveEnergy may always do nothing, a superset of \"if you can\"'), where print moves "
                   "one Energy if one can be moved",
    'printedRetreat': "'for each Colorless in your opponent's Active Pokémon's Retreat Cost' is `Count.retreat`, the printed "
                      "Retreat Cost (milestone MV6): a static effect in force that changes the Retreat Cost (imported Tools, "
                      "Stadiums and Abilities do) is not read (Known gaps, counts item: `Count.retreat`, a departure in both "
                      "directions for such a Pokémon)",
    'oppBenchFresh': "a Basic Pokémon an effect puts onto the opponent's Bench enters play `fresh` and stays so through its "
                     "owner's next turn, so it cannot evolve then (Known gaps, item on Pokémon put onto the opponent's Bench: "
                     "whether that turn is its first turn in play is not settled; if it is not, the model forbids an "
                     "evolution print allows)",
    'failToFind': "a mandatory take from a private window ('a Basic Energy card you find there' among the top cards of the "
                  "player's own deck) is `Qty.most`, which must take a passing card when there is one: fewer outcomes than "
                  "the usual practice of failing to find in a private window, which the 2026 rulebook does not state "
                  "(Known gaps, zone moves item, hidden information)",
    # importer 0.14.0 (milestones MV7, MV7b)
    'trigBenched': "'Whenever your opponent's Active Pokémon moves to the Bench during their turn' (`TrigEvent.oppBenched`, "
                   "milestone MV7) resolves when the event happens, before the Knock Outs it causes, on the holders marked at "
                   "the event: a Pokémon switched in at or above its HP (a static HP change that reads its place or its "
                   "Energy) gets the effect and is then Knocked Out, and its replacement gets nothing, where under a reading "
                   "that takes the Knock Out first the effect falls on the replacement; and in a state no play is known to "
                   "reach (a trigger pending with an Active Spot empty) a marked holder Knocked Out first fires nothing "
                   "(Known gaps, triggers of the event 'your opponent's Active Pokémon moves to the Bench': the order item "
                   "and the unreached states)",
    'koCounters': "'… is Knocked Out' / 'Knock Out …' is written as 9999 damage counters on that Pokémon (`selfDamage`, "
                  "`counters`, `benchCounters`, `benchSome`), which the batch Knock Out step takes as a Knock Out with its "
                  "Prize cards and promotion (Known gaps, self-Knock-Out Abilities; `SelfKO.self_ko`): exact while every "
                  "derived HP in the game is below 9999 counters (over the imported pool a Pokémon's derived HP is at most "
                  "76 + 4E counters, E the Energy cards attached to it: per Energy card a Pokémon's own '+N HP for each "
                  "Energy' (at most 4) or Growing Grass Energy's +2 to a Grass Pokémon, never both on one imported card), "
                  "so below in every game of two 60-card decks; the "
                  "importer checks this bound, survey S11) and nothing prevents damage counters being placed on it (no "
                  "such effect is modelled); above that the Pokémon survives where print Knocks it Out. A Knock Out written so inside an attack is one by the "
                  "check after the attack, which the readers of 'Knocked Out by damage from an attack' count (their own "
                  "caveats trigKO, koAttackWide)",
    'selfKOTiming': "the Knock Outs of an Ability's resolution are checked after each step (`TRun`): when the step before "
                    "'this Pokémon is Knocked Out' Knocks Out an opponent's Pokémon and so gives the player their last Prize "
                    "card, or leaves the opponent no Pokémon in play, the player wins before the self-Knock-Out step, where a "
                    "check after the whole Ability would also Knock Out this Pokémon in the same check (both players' "
                    "last Prize cards at once, a tiebreaker; or possibly a way to win for the opponent) (Known gaps, "
                    "self-Knock-Out Abilities: timing)",
    'selfKOBench': "used from the Bench, 'this Pokémon is Knocked Out' is 9999 damage counters on one Benched Pokémon "
                   "chosen at resolution (`SelfOp.counters` on the Bench, `benchCounters .own`): another Benched Pokémon "
                   "may be Knocked Out instead, so this Pokémon survives (and can use the Ability again next turn) and "
                   "the opponent takes the Prize cards of the other Pokémon (2 or 3 for a Pokémon ex or Mega Evolution "
                   "Pokémon ex) (Known gaps, self-Knock-Out Abilities: 'on the Bench SelfOp.counters may choose another "
                   "Benched Pokémon (a superset)')",
    # importer 0.15.0 (milestones MV7c and MV8)
    'energyOfBasic': "'a [T] Energy' attached to a Pokémon, chosen to be discarded or moved, is `Filter.energyOf t`, which "
                     "passes Basic Energy cards only: a Special Energy card that provides T (Prism, Neo Upper, Luminous, "
                     "Team Rocket's Energy; the typed Special Energy cards) cannot be chosen where print lets it be "
                     "(Known gaps, Energy item: 'Filter.energyOf t reads Basic Energy only … fewer than print in counts, "
                     "tests and discards'); written only where the printed sentence does not say 'Basic'",
    'energyOfCount': "'[T] Energy attached' in a count or a test is `Filter.energyOf t` (Basic Energy cards only) or a "
                     "static count (`SAmt.perEnergy`, `Static.need`) of Basic cards: a Special Energy card that provides "
                     "T is not counted, so the count or test reads less than print; likewise 'discard all [T] Energy' "
                     "leaves such a card attached (Known gaps, Energy item); a different amount, branch or discard, so "
                     "outcomes differ either way",
    'staticCardCount': "a static 'for each Energy attached' or 'N or more Energy attached' (`SAmt.perEnergy`, `Static.need` "
                       "under `Filter.energy`) counts Energy cards, not the Energy they provide: a card that provides 2 "
                       "(Team Rocket's Energy; Neo Upper Energy on a Stage 2 Pokémon) counts 1 (Known gaps, Energy item: "
                       "'SAmt.perEnergy and Static.need count cards'). Written only where the Pokémon read can hold a "
                       "card that provides 2 (see MULTI_UNIT). On no imported card in 0.15.0: kept because the rule that "
                       "writes it is live (a future static of this form would otherwise be written exact)",
    # importer 0.18.0 (milestone MV11)
    'moveUnits': "'put N Energy attached to … into the hand', 'move N Energy' (N at least 2) are `returnEnergy` / "
                 "`shiftEnergy … (Filter.energy)`, read as `discardEnergy` reads 'discard N Energy', by the Energy the "
                 "cards provide (`Qty.okE`); 'move up to N Energy from your Benched Pokémon' is N one-card steps, each "
                 "of which may take one card providing 2. Print may count cards, or Energy where the model counts "
                 "cards (Known gaps, Energy item: readings). Written only where the Pokémon taken from can hold a card "
                 "that provides 2 (MULTI_UNIT)",
    'shiftFromMoved': "'move Energy from the Pokémon you moved to your Bench to the new Active Pokémon' takes the Energy "
                      "from a Benched Pokémon chosen when the move resolves: the model does not record which Pokémon the "
                      "switch moved, and may take it from a Benched Pokémon with none where the moved one has some; a forced move "
                      "('move an Energy') whose only source holds an Energy the new Active Pokémon may not hold (a holder-"
                      "restricted Special Energy) has no resolution, so the card cannot be played where print plays it "
                      "(Known gaps, zone moves item, milestone MV11)",
    'discardUnits': "'discard N Energy' (N at least 2) is `discardEnergy … (Filter.energy)`, read by the Energy the cards "
                    "provide (`Qty.okE`): one card that provides 2 pays 2, a card providing more than still needed may be "
                    "discarded, no card the payment does not need may be (Known gaps, Energy item: readings, no rule found "
                    "in the 2026 rulebook, which never mentions Special Energy); print may count cards. Written only where "
                    "the Pokémon discarded from can hold a card that provides 2 (a Stage 2 Pokémon with Neo Upper Energy, a "
                    "Team Rocket's Pokémon with Team Rocket's Energy; `EnergyCard.unitsAt` reads the holder's top card); "
                    "elsewhere every card weighs 1 and the readings agree (`Qty.okE_ones`)",
    'energyUnitsCount': "'for each Energy attached' or 'N or more Energy attached' (N at least 2) is `Count.energy` / "
                        "`Count.energyAll` under `Filter.energy`, which counts the Energy the cards provide "
                        "(`Filter.weight`): a card that provides 2 counts 2, where print may count cards (Known gaps, "
                        "Energy item: a reading, no rule found in the 2026 rulebook). Written only where the Pokémon read "
                        "can hold a card that provides 2 (a Stage 2 or Team Rocket's Pokémon, read on its top card); a "
                        "different amount or branch, so outcomes differ either way",
    'forUpToUnits': "'discard up to N Energy …, K damage for each card you discarded in this way' is `forUpTo` over "
                    "`discardEnergy … (Filter.energy) (exactly j)`, whose branch j counts Energy provided, not cards: one "
                    "card that provides 2 is discarded by the branches 1 and 2 alike, so the attack may do 2K for one card "
                    "(more), and with that card and a Basic Energy card attached no branch j ≤ N discards both (the payment "
                    "would have a superfluous card, `retreatPaid 2 [2, 1] = false`), so print's 'discard both' is absent "
                    "(fewer) (Known gaps, Energy item; `Units.forUpTo_one_card`, `Units.forUpTo_no_pair`). Written only "
                    "where the Pokémon read can hold a card that provides 2 (a Stage 2 or Team Rocket's Pokémon: see "
                    "MULTI_UNIT)",
    'forAllUnits': "'discard all Energy from this Pokémon; K damage for each card you discarded in this way' is `forUpTo` "
                   "over `discardEnergy … (Filter.energy) (exactly j)` with every Energy discarded, whose branch j is the "
                   "Energy provided, not the cards: a card that provides 2 adds 2K where print adds K (Known gaps, "
                   "Energy item; `Units.forUpTo_one_card`). On no imported card in 0.15.0 (the two imported 'discard "
                   "all … for each card' attacks name a type, `energyOf`): kept because the rule that writes it is live",
    'unitsReading': "a Special Energy card that provides 2 Energy pays the Retreat Cost and 'discard N Energy' by what it "
                    "provides: it may be discarded when only 1 is still needed, and no card the payment does not need may be "
                    "(Known gaps, Energy item: readings, no rule found in the 2026 rulebook, which never mentions Special "
                    "Energy)",
    'rocketMove': "'This card can only be attached to a Team Rocket's Pokémon. If this card is attached to anything other "
                  "than a Team Rocket's Pokémon, discard this card.' is `EnergyText.only`: an effect cannot move the card "
                  "onto a Pokémon that is not a Team Rocket's Pokémon, where print moves it and then discards it (a subset "
                  "of print); the discard rule is not applied at evolution, vacuous for the card data (every card that "
                  "evolves from a Team Rocket's Pokémon is one; survey S22) (Known gaps, Energy item)",
    'noRetreatLast': "'has no Retreat Cost' is `SEff.noRetreat`, applied after every `retreatPlus` and `retreatMinus` in force "
                     "(`GameState.retreatOf_of_noRetreat`): with a Retreat Cost increase in force (Gravity Gemstone) the "
                     "model's cost is 0; a reading, no rule found on the order of a set against an addition (Known gaps, "
                     "Energy item)",
    'trigAttached': "a triggered Ability a Pokémon Tool or a Special Energy card gives its holder fires only if the card is "
                    "still attached when the trigger resolves, at the end of the attack: an attack that damages the holder "
                    "and then discards the card silences it (Known gaps, Energy item: 'Spiky Energy's trigger, like a "
                    "Tool's, fires only if the card is still attached at the end of the attack')",
    'specialCountCards': "'for each Special Energy attached' (no 'card') is `Count.energy … specialEnergy`, which counts "
                         "cards (`Filter.weight`: under a filter other than `Filter.energy`, cards; Known gaps, Energy "
                         "item): a Special Energy card that provides 2 (Team Rocket's Energy) counts 1, where print, read "
                         "as 'for each Energy attached' is (by the Energy provided), may count 2; a reading either way",
    'movedOnce': "'Once during your turn, when this Pokémon moves …, you may …' (`TrigEvent.movedUp` / `movedDown`, milestone "
                 "MV7c) spends the once-per-turn limit at the event: a declined trigger has spent it, and the same Pokémon "
                 "moving again in that turn fires nothing, where print would allow it then (Known gaps, triggers of the "
                 "player's own moves: fewer outcomes)",
    # importer 0.16.0 (milestone MV9, survey S23)
    'usedLastBench': "'if this Pokémon used X during your last turn' reads the use record of X (`Attack.selfLock := .note`, "
                     "`Test.usedLast`), which ends when the Pokémon moves to the Bench or evolves (`InPlay.unlock`); print "
                     "does not say that the history ends then (a reading, Known gaps: one-turn history, use records): a "
                     "Pokémon that used X, moved to the Bench during the opponent's turn and came back to the Active Spot "
                     "does not get the bonus in the model, where print gives it; a failed Confused attempt of X writes no "
                     "record, which is also a reading",
    'printedMaxHP': "'has a maximum HP of N' reads the printed HP of the card (`Filter.hpLe`, as every filter reads the "
                    "printed card), not the derived HP that static effects change (`GameState.hpOf`; Known gaps, filters: "
                    "maximum HP): a Pokémon whose HP an effect raises to N, or from N, is counted the other way",
    'usedLastBenchUse': "'You can use this attack only if this Pokémon used X during your last turn' reads the use record "
                        "of X (as usedLastBench): a Pokémon that used X, moved to the Bench and came back cannot use the "
                        "attack in the model, where print allows it; a failed Confused attempt of X writes no record, also a reading",
    # importer 0.21.0 (milestone MV14, survey S28)
    'thresholdRead': "a damage threshold ('prevent all damage … if that damage is N or more / N or less', `SEff.preventGe`, "
                     "`Mod.preventLe`) compares N with the damage after every other effect of the calculation: Weakness, "
                     "Resistance, the step-5 increase and every damage reduction, stored or static (`GameState.dealt`, "
                     "`dealtBy`). The rulebook gives no order among step-5 effects (2026 p. 20) and no ruling was checked: "
                     "a reading that compares before a reduction prevents a damage the model lets through, or the reverse "
                     "(Known gaps, threshold prevention)",
    # importer 0.20.0 (milestone MV13, survey S27)
    'shieldBench': "a static 'prevent all damage from and effects of attacks … done to' a Benched Pokémon (in force on "
                   "the Bench only: 'As long as this Pokémon is on your Bench', 'done to your Benched Pokémon') prevents "
                   "the damage (`SEff.prevent`, read by the Bench damage primitives, `GameState.benchSafe`) but not the "
                   "effects: in the model an opponent's attack still places damage counters on the protected Benched "
                   "Pokémon (`benchCounters`, `spreadCounters`, `benchSome` and `hitBy` with counters, `dumpCounters` "
                   "to the Bench), still switches it into the Active Spot (a gust, `switch .opp`), and still discards "
                   "Energy or Tools from it or puts markers on it, none of which print allows if the printed protection "
                   "covers them, because `Run` does not know whether it resolves an attack (Known gaps, prevention of "
                   "effects (e); survey S27 §2)",
    'healMove': "'can't be healed' (`SEff.noHeal`) is read by the heals of the Active Pokémon (`heal`, `healAll`, the "
                "heal of `drain`); moving damage counters off it (`moveCounter`) is not read as healing, a reading with "
                "no ruling checked (Known gaps, heal block)",
    # importer 0.17.0 (milestone MV10, survey S24)
    'shieldReach': "'prevent all effects of attacks done to this Pokémon' removes from the opponent's attack the primitives "
                   "the model counts as done to the Defending Pokémon (`Effect.shielded`): damage counters, Special Conditions, "
                   "Poison strength, a switch of the Defending Pokémon in either direction (a gust from the Bench included), "
                   "the Defending Pokémon's attack and retreat locks and damage modifiers, Energy and Tools discarded from "
                   "or attached to it, every move of Energy between the opponent's Pokémon (Bench to Bench included), and "
                   "markers on the opponent's Pokémon; it keeps everything on the Bench, attachments from a looked-at window "
                   "('attach … to your opponent's Pokémon in any way'), and locks on the player (Items) (Known gaps, "
                   "prevention of effects: a reading of 'done to this Pokémon'; no ruling was checked)",
    'shieldActive': "a static 'prevent all effects of attacks … done to this Pokémon' (`SEff.shield`, milestone MV10) is read "
                    "for the protected Pokémon (the holder, or the Pokémon the Ability names) in the Active Spot, at the start of the attack (`GameState.shield`): effects of attacks "
                    "on a Benched holder (damage counters on the Bench) are not prevented, and a holder that the attack "
                    "itself switches into the Active Spot is not protected from the rest of that attack (Known gaps, "
                    "prevention of effects)",
    'movedCheckup': "a promotion after Pokémon Checkup is read as in no player's turn, so it never fires a 'during your "
                    "turn' `movedUp` trigger; under the reading of Checkup as part of the ending player's turn it would "
                    "(Known gaps, triggers of the player's own moves: reading, fewer outcomes). On no imported card in "
                    "0.15.0 (the one `movedUp` card, Yanmega ex, is refused for an attack): kept because `translate_moved` "
                    "writes it on every `movedUp` trigger it imports",
}


# The direction of each caveat: does the model's term allow outcomes the printed card does not
# ('allows more'), forbid outcomes the printed card allows ('forbids some'), or both? A card imported
# with caveats is in general neither an over- nor an under-approximation of its printed card.
CAVEAT_DIRECTION = {
    # importer 0.18.0
    'moveUnits': 'both',           # by units a 2-unit card counts 2 (fewer cards than print by cards), and the steps
                                   # of 'up to N from your Benched Pokémon' may move N 2-unit cards (more than by units)
    'shiftFromMoved': 'both',  # the Energy of another Benched Pokémon may move (allows more); a forced move blocked
                               # by a holder restriction blocks the play (forbids some)
    # importer 0.21.0
    'thresholdRead': 'both',       # with a reduction in force, another order of step 5 prevents what the model lets
                                   # through ('N or more' read before the reduction) or the reverse
    # importer 0.20.0
    'shieldBench': 'both',         # a forced effect of an attack lands on the protected Benched Pokémon: print's
                                   # outcome (nothing) absent, another present
    'healMove': 'allows more',     # moving damage counters off the protected Active Pokémon is allowed in the model
    # importer 0.17.0
    'shieldReach': 'both',         # a gust or a Bench-to-Bench Energy move print may allow is absent (forbids some); an
                                   # attachment onto the protected Pokémon from a window is kept (allows more)
    'shieldActive': 'both',        # a forced effect lands on a Benched or switched-in holder: print's outcome absent, another present
    # importer 0.16.0
    'usedLastBench': 'both',       # after a trip to the Bench: no bonus in the model, the bonus in print
    'usedLastBenchUse': 'forbids some',  # after a trip to the Bench the attack cannot be used in the model
    'printedMaxHP': 'both',        # a derived HP of N not counted, or a printed N with a changed HP counted
    # importer 0.15.0
    'energyOfBasic': 'forbids some',  # the Special Energy card providing the type cannot be chosen
    'energyOfCount': 'both',       # a smaller count or a false test: the printed amount or branch is absent, the
                                   # model's is extra (as koAttackWide, printedRetreat)
    'staticCardCount': 'both',     # a smaller static amount or an unmet need, as energyOfCount
    'discardUnits': 'both',        # by units: one 2-unit card pays 2 (print by cards would ask for 2 cards), and a
                                   # payment by cards may differ the other way
    'forUpToUnits': 'both',        # the branch 2 for one 2-unit card is extra; "discard both" of a 2-unit and a
                                   # 1-unit card under "up to 2" has no branch (retreatPaid 2 [2, 1] = false)
    'energyUnitsCount': 'both',    # a different amount or branch, if print counts cards
    'forAllUnits': 'both',         # the one resolution is the unit count, not the card count
    'unitsReading': 'both',        # a reading of payment by units, either way against a reading by cards
    'specialCountCards': 'both',   # a different amount, if print counts Energy provided
    'rocketMove': 'forbids some',  # the move-then-discard outcome is absent
    'noRetreatLast': 'both',       # cost 0 where another order gives 1 or more, and the reverse
    'trigAttached': 'forbids some',  # the trigger of a holder whose card the attack discarded is absent
    'movedOnce': 'forbids some',   # a second firing in the turn after a declined or spent one
    'movedCheckup': 'forbids some',  # the firing on a promotion after Checkup, under the other reading
    'moveMayFail': 'allows more',  # the move of nothing is an extra outcome
    'prizes6': 'both',             # off a 6-Prize start the count differs from the printed one, either way
    'perPokemon': 'both',          # a reduction or prevention on one Pokémon covers all of its player's
                                   # (allows more); a lock on the Defending Pokémon locks every Pokémon
                                   # of that player, so a switched-in Pokémon cannot attack (forbids some)
    'recoil': 'both',              # self-damage takes no Weakness, Resistance or modifier: a different amount
    'benchMods': 'both',           # Bench damage takes no bonus, reduction or prevention: a different amount
    'mayFail': 'allows more',
    'upTo0': 'allows more',
    'hiddenInfo': 'allows more',   # the player acts on information the printed card hides
    'aceSpec': 'allows more',      # decks with several ACE SPEC cards
    'poisonStrength': 'both',      # the strength is a separate counter (a new Poison resets it)
    'selfInDiscard': 'both',       # the card can recycle or count itself
    'searchAny': 'allows more',
    'koBetweenSteps': 'both',      # a Knock Out check, with its replacement, falls between two steps
    'noopPlay': 'allows more',
    'noopUse': 'allows more',
    'selfBench': 'allows more',
    'moveAnyPair': 'allows more',
    'onePerName': 'allows more',     # more uses per turn; still bounded by the model's potential (abPot)
    'staticBench': 'both',         # Bench damage is not reduced: more damage to a Benched Pokémon than printed
                                   # (forbids the printed survivals, allows Knock Outs the printed card prevents)
    'toolAbilityFlag': 'forbids some',  # fewer Ability uses per turn than the rulebook allows
    'trigDamaged': 'both',         # damaged-then-switched fires nothing (forbids some); the corner at or above
                                   # HP may fire a trigger the printed card would not (allows more)
    'trigKO': 'allows more',       # more Knock Outs fire the trigger than the printed "by damage from an attack"
    'trigAttacker': 'both',        # a different Pokémon gets the effect: the printed outcome is not among the
                                   # model's when the attacker was switched out or Knocked Out
    'koAttackWide': 'both',        # the test is true in more states: the printed result of a false test (no bonus)
                                   # is then absent, and the model's bonus is an outcome the printed card lacks
    'koCheckup': 'forbids some',   # if a Checkup Knock Out counts in print, the model's test is false where it is true
    'movedUpPromotion': 'forbids some',  # the printed bonus after such a promotion is not available
    'staticPreventBench': 'both',  # a Benched Pokémon takes damage the printed card prevents (Knock Outs the printed
                                   # card forbids; the printed survivals are absent)
    'ignFxStadium': 'both',        # if print keeps a Stadium's reduction, the model's damage is larger (and the
                                   # printed smaller damage is absent)
    'anyAmount60': 'forbids some', # more than 60 cards cannot be discarded
    'printedRetreat': 'both',      # a static increase is not counted (less damage than print for "more", more for
                                   # "less"); a static decrease the other way
    'oppBenchFresh': 'forbids some',  # an evolution in the owner's next turn, if print allows it
    'failToFind': 'forbids some',  # declining to take a card the player found in a private window
    'trigBenched': 'forbids some',  # the effect on the replacement of a switched-in Pokémon Knocked Out, if print
                                    # takes the Knock Out first; a marked holder's trigger in unreached states
    'koCounters': 'both',          # with a derived HP of 9999 counters or more the Pokémon survives (the printed Knock
                                   # Out is absent, the survival is extra); vacuous in games of two 60-card decks
    'selfKOBench': 'allows more',  # the printed Knock Out of this Pokémon is among the outcomes; others are extra
    'selfKOTiming': 'both',        # the win before the self-Knock-Out step, where print may give a tiebreaker
    'abilityByTool': 'both',       # a Tool-given Ability is not read: a smaller count than print may give (the
                                   # printed amount is absent), or damage that print may prevent (allows more)
}


class Refuse(Exception):
    def __init__(self, reason, sentence=''):
        super().__init__(reason)
        self.reason = reason
        self.sentence = sentence


# ------------------------------------------------------------------ small parsers

NUMW = {'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'another': 1}
TYPE_RE = r'(Grass|Fire|Water|Lightning|Psychic|Fighting|Darkness|Metal|Fairy|Dragon|Colorless)'
CONDS = {'Asleep': 'asleep', 'Burned': 'burned', 'Confused': 'confused', 'Paralyzed': 'paralyzed',
         'Poisoned': 'poisoned'}


def noop(ctx):
    """The `noopPlay` caveat, for a mandatory Trainer primitive that the model lets do nothing
    (`switchNone`, `heal` of an undamaged Pokémon, `benchHealNone`, `cure` with no condition). In an
    attack doing nothing is what the card does when it cannot, so no caveat. Since importer 0.13.0 these
    marks are provisional: `no_effect_trainer` and `no_effect_ability` drop them and decide the caveat
    from the whole effect (`noop.py`)."""
    if ctx['kind'] == 'trainer':
        return {'noopPlay'}
    if ctx['kind'] == 'ability':
        return {'noopUse'}
    return set()


COIN_RE = re.compile(r'[Ff]lip (?:a coin|\d+ coins)')


def no_effect_trainer(body, text, cavs):
    """Importer 0.13.0, one treatment of plays to no effect (`noop.py`): the effect `body` of an Item, Supporter or
    Stadium use (its cost excluded) gets the precondition that it can do something, where public information decides
    it, and the caveat `noopPlay` where a play to no effect is left that print forbids. Returns the new body; updates
    `cavs` (the provisional `noopPlay` marks of the rules are dropped first)."""
    cavs.discard('noopPlay')
    known, clauses, _, residue = N.plan([body], bool(COIN_RE.search(text)))
    cavs |= N.residue_caveats(residue, cavs, 'trainer')
    return N.apply(body, known, clauses)


def ab_decide(a, units):
    if a[0] == 'fx':
        return ('fx', N.decide(a[1], units))
    if a[0] in ('seq', 'choice'):
        return (a[0], ab_decide(a[1], units), ab_decide(a[2], units))
    return a


def no_effect_ability(eff, use, spot, text, cavs):
    """As `no_effect_trainer`, for an Ability's effect before its cost: an activated Ability ("Once during your turn",
    "As often as you like") gets the precondition and the caveat `noopUse`, the effect read at every place the Ability
    can be used from; an on-play Ability needs neither, as a use to no effect leaves the state of the play without the
    Ability (`Move.onPlay` against `PlayFromHand`)."""
    cavs.discard('noopUse')
    if use[0] not in ('once', 'unlimited'):
        return eff
    places = [spot] if spot is not None else [T.ACTIVE, T.BENCH]
    bodies = [T.abeff_compile(p, eff) for p in places]
    facts = [(N.bench(OWN), True)] if spot == T.BENCH else []
    known, clauses, _, residue = N.plan(bodies, bool(COIN_RE.search(text)), facts)
    cavs |= N.residue_caveats(residue, cavs, 'ability')
    if not clauses:
        return eff
    units = list(known) + [cl[0] for cl in clauses if len(cl) == 1]
    return abseq(('fx', seq(*[N.require(cl) for cl in clauses])), ab_decide(eff, units))


def num(s):
    s = s.strip().lower()
    if s in NUMW:
        return NUMW[s]
    return int(s)


def counters(dmg):
    """Damage in HP to counters; refuse amounts that are not whole counters."""
    n = int(dmg)
    if n % 10:
        raise Refuse('damage not a multiple of 10')
    return n // 10


def etype(word):
    return (T.TYPES[word],)


def parse_filter(np, ctx):
    """A noun phrase naming a kind of card ("Basic Pokémon", "Basic Fire Energy cards", "Item card"),
    to a `Filter`. Singular and plural forms; refuses phrases the model has no filter for."""
    s = np.strip()
    s = re.sub(r'^(an?|any|the) ', '', s)
    # milestone MV2: "Pokémon ex or Pokémon V" / "Pokémon ex and Pokémon V" (a count's union). The model's
    # `RuleBox` has no V kind and today's Standard pool (H, I, J) has no Pokémon V, so no card of a game the
    # model plays is a Pokémon V and the phrase is "Pokémon ex" (Pokemon/Card.lean, `Filter.ex`)
    if s in ('Pokémon ex or Pokémon V', 'Pokémon ex and Pokémon V', 'Benched Pokémon ex or Benched Pokémon V'):
        return ('ex',)
    # milestone MV2: "Pokémon that has the Round attack" (`Filter.hasAttack`, the card's printed attacks) and
    # "Pokémon that has an Ability" (`Filter.hasAbility`, the card's printed Abilities)
    m = re.match(r'^Pokémon (?:that|which) (?:has|have) the (.+) attack$', s)
    if m:
        return ('and', ('pokemon',), has_attack(m.group(1)))
    if s in ('Pokémon that has an Ability', 'Pokémon that have an Ability'):
        return ('and', ('pokemon',), ('hasAbility',))
    # importer 0.16.0 (milestone MV9): "Mega Evolution Pokémon ex" (`Filter.megaEx`), "Pokémon with T Resistance"
    # (`Filter.resists`), "Pokémon that have the X Ability" (`Filter.abilityNamed`, printed Abilities; refused if a
    # Tool of the data prints an Ability of that name), "Ancient X" / "Future X" (`tag_filter`)
    if s in ('Mega Evolution Pokémon ex',):
        return ('and', ('pokemon',), ('megaEx',))
    m = re.match(r'^Pokémon with ' + TYPE_RE + r' Resistance$', s)
    if m:
        return ('and', ('pokemon',), ('resists', etype(m.group(1))))
    m = re.match(r'^Pokémon (?:that|which) (?:has|have) the (.+) Ability$', s)
    if m:
        if m.group(1) in TOOL_ABILITIES:
            raise Refuse('Ability name a Pokémon Tool can give (Filter.abilityNamed reads printed Abilities only): '
                         + m.group(1))
        return ('and', ('pokemon',), ('abilityNamed', m.group(1)))
    m = re.match(r'^Pokémon (?:that|which) (?:has|have) a maximum HP of (\d+)$', s)
    if m:
        # printed HP exactly N (`hpLe`, the printed card; caveat `printedMaxHP`, added by `translate_card`)
        n = counters(m.group(1))
        return ('and', ('pokemon',), ('and', ('hpLe', n), ('not', ('hpLe', n - 1))))
    m = re.match(r'^(Ancient|Future) (.+)$', s)
    if m:
        base = parse_filter(m.group(2), ctx)
        return ('and', base, tag_filter(m.group(1)))
    if s == 'Tera Pokémon':
        # milestone MV2: `Filter.tera`, the card's Tera mark (every Tera Pokémon of today's Standard)
        return ('and', ('pokemon',), ('tera',))
    # milestone MV4: "F that has \"X\" in its name" (`Filter.nameHas`, `name_has`)
    m = re.match(r'^(.+?) that (?:has|have) "([^"]+)" in (?:its|their) names?$', s)
    if m:
        base = parse_filter(m.group(1), ctx)
        return ('and', base, name_has(m.group(2), base))
    m = re.match(r'^(.+?) that (?:has|have) "([^"]+)" or "([^"]+)" in (?:its|their) names?$', s)
    if m:
        base = parse_filter(m.group(1), ctx)
        return ('and', base, ('or', name_has(m.group(2), base), name_has(m.group(3), base)))
    # milestone MV4: owner phrases "[Basic / Evolution] X's Pokémon [ex]" (`owner_filter`)
    m = re.match(r"^(Basic |Evolution |Stage [12] )?(.+?)'s (Pokémon(?: ex)?)$", s)
    if m:
        base = parse_filter((m.group(1) or '') + m.group(3), ctx)
        if not is_pokemon_filter(base):
            raise Refuse('card kind with no filter: ' + s)
        return owner_filter(m.group(2), base)
    m = re.match(r'^(.+?),? or (an? )?(.+)$', s)
    if m and ' or less' not in s and ' or more' not in s:
        return ('or', parse_filter(m.group(1), ctx), parse_filter(m.group(3), ctx))
    m = re.match(r'^(?:up to \d+ )?in any combination of (.+?) and (.+)$', s)
    if m:
        return ('or', parse_filter(m.group(1), ctx), parse_filter(m.group(2), ctx))
    s = re.sub(r' cards?$', '', s)
    if s in ('card', 'cards', ''):
        return ('any',)
    if s == 'Pokémon':
        return ('pokemon',)
    if s == 'Basic Pokémon':
        return ('basic',)
    if s == 'Evolution Pokémon':
        return ('and', ('pokemon',), ('not', ('basic',)))
    m = re.match(r'^Stage (1|2) Pokémon$', s)
    if m:
        return ('stage', ('stage' + m.group(1),))
    m = re.match(r'^' + TYPE_RE + r' Pokémon$', s)
    if m:
        return ('ptype', etype(m.group(1)))
    m = re.match(r'^Basic ' + TYPE_RE + r' Pokémon$', s)
    if m:
        return ('and', ('basic',), ('ptype', etype(m.group(1))))
    if s == 'Pokémon ex':
        return ('and', ('pokemon',), ('not', ('noRuleBox',)))
    if s in ("Pokémon that don't have a Rule Box", "Pokémon that doesn't have a Rule Box"):
        return ('and', ('pokemon',), ('noRuleBox',))
    m = re.match(r'^Basic Pokémon with (\d+) HP or less$', s)
    if m:
        return ('and', ('basic',), ('hpLe', counters(m.group(1))))
    m = re.match(r'^Pokémon with (\d+) HP or less$', s)
    if m:
        return ('and', ('pokemon',), ('hpLe', counters(m.group(1))))
    if s == 'Item':
        return ('kind', ('item',))
    if s == 'Supporter':
        return ('kind', ('supporter',))
    if s == 'Trainer':
        return ('trainer',)
    if s == 'Pokémon Tool':
        # milestone M5: `Filter.tool` (`Card.tool`); not an Item (a Tool is its own Trainer kind)
        return ('tool',)
    if s == 'Stadium':
        return ('kind', ('stadium',))
    if s == 'Energy':
        # "an Energy card": Basic or Special (`Filter.energy`, milestone MV5)
        return ENERGY_F
    if s == 'Basic Energy':
        # "a Basic Energy card" (`Filter.basicEnergy`, milestone MV5; until importer 0.10.0 written `Filter.energy`,
        # the same filter while no Special Energy card is in the game)
        return BASIC_F
    if s == 'Special Energy':
        return SPECIAL_F
    m = re.match(r'^(?:Basic )?' + TYPE_RE + r' Energy$', s)
    if m:
        # "a Basic Fire Energy card", and "a Fire Energy card", which the rulebook's glossary makes a Basic Energy card
        # (see ENERGY_F); `Filter.energyOf` passes Basic Energy of that type only
        if m.group(1) in ('Dragon', 'Colorless'):
            raise Refuse('no Basic Energy of that type')
        return ('energyOf', etype(m.group(1)))
    m = re.match(r'^Stage (1|2) ' + TYPE_RE + r' Pokémon$', s)
    if m:
        # importer 0.9.0: "Stage 2 Darkness Pokémon"
        return ('and', ('stage', ('stage' + m.group(1),)), ('ptype', etype(m.group(2))))
    m = re.match(r'^Evolution ' + TYPE_RE + r' Pokémon$', s)
    if m:
        return ('and', ('and', ('pokemon',), ('not', ('basic',))), ('ptype', etype(m.group(1))))
    if s in ('SELF', ctx.get('name')):
        return ('named', ctx['name'])
    if s in KNOWN_NAMES:
        # a card name ("Shedinja", "Arven's Sandwich"): `Filter.named`, exact for Pokémon, Items,
        # Supporters and (milestone M5) Stadiums and Tools; names of kinds the model lacks are refused
        # with that kind as the reason
        kinds = KNOWN_NAMES[s]
        # since importer 0.11.0 (milestone MV5) a Special Energy card's name is a filter too (`Filter.named` reads it)
        bad = sorted(kinds & {'Trainer (other)', 'Basic Energy'})
        if bad:
            raise Refuse('card named in text is a ' + ' / '.join(bad) + ': ' + s)
        return ('named', s)
    raise Refuse('card kind with no filter: ' + s)


# Card names in the whole dataset (all regulation marks), name -> set of kinds ('Pokémon', 'Item',
# 'Supporter', 'Pokémon Tool', 'Stadium', 'Basic Energy', 'Special Energy'); filled by `set_names`.
KNOWN_NAMES = {}


# Pokémon card names in the whole dataset, name -> set of stages ('Basic', 'Stage 1', 'Stage 2', ...).
NAME_STAGES = {}


# Names of the attacks Pokémon Tool cards of the whole dataset print (and may give, `ToolGrant`).
TOOL_ATTACKS = set()

# importer 0.16.0: names of the Abilities Pokémon Tool and Special Energy cards of the whole dataset print.
TOOL_ABILITIES = set()


# milestone MV4 (importer 0.10.0): the owners of the whole dataset, the X of every Pokémon card named "X's …"
# ("Iono's Voltorb", "Team Rocket's Mewtwo ex", "N's Zoroark ex"). An owner phrase "X's Pokémon" is written as
# `and pokemon (namePrefix "X's ")`: the printed owner with its ASCII apostrophe (every name of the data uses
# U+0027; `norm` straightens the text's U+2019), "s" and the following space, so that "N's " does not match
# "Naganadel" and the conjoined `pokemon` keeps Trainer names ("Arven's Sandwich") out. Filled by `set_names`.
OWNERS = set()


def owner_filter(owner, base):
    """`Filter.and base (namePrefix "X's ")`, `base` a filter that only Pokémon cards pass."""
    if owner not in OWNERS:
        raise Refuse('card kind with no filter: ' + owner + "'s Pokémon (no Pokémon card has that owner)")
    return ('and', base, ('namePrefix', owner + "'s "))


# milestone MV4: `Filter.nameHas s` is a byte-level substring test. Print's "has \"X\" in its name" is written with it
# only when every card name of the whole dataset that contains X contains it as a whole word (not followed or
# preceded by a letter), so the substring test and the printed reading agree on every card of the data: "Mew" would
# also match "Mewtwo", and is refused. Filled by `set_names`: name -> True if the literal is safe.
ALL_NAMES = set()


def name_kinds(base):
    """The card kinds (`KNOWN_NAMES` values) a filter can pass, as far as `name_has` needs: Pokémon for a Pokémon-only filter,
    Supporter, Item, Stadium or Pokémon Tool for those kinds, None (any) otherwise."""
    if is_pokemon_filter(base):
        return {'Pokémon'}
    if base == ('tool',):
        return {'Pokémon Tool'}
    if base[0] == 'kind':
        return {{'supporter': 'Supporter', 'item': 'Item', 'stadium': 'Stadium'}[base[1][0]]}
    return None


def name_has(x, base):
    """`Filter.nameHas x` under the filter `base`: refused if no card of `base`'s kinds in the whole dataset has a name
    containing `x` (print would then read cards the model cannot have in that place: "Benched Pokémon that has
    \"Antique\" in its name" means Fossil Items played as Pokémon, which the model does not play), or if a name contains
    it inside a longer word."""
    ks = name_kinds(base)
    hits = [n for n in ALL_NAMES if x in n and (ks is None or KNOWN_NAMES.get(norm(n), set()) & ks)]
    if not hits:
        raise Refuse('name substring that no card of that kind contains: ' + x)
    bad = [n for n in hits if not re.search(r'(?<![A-Za-zé])' + re.escape(x) + r'(?![A-Za-zé])', n)]
    if bad:
        raise Refuse('name substring that is part of a longer word in a card name: ' + x + ' (' + sorted(bad)[0] + ')')
    return ('nameHas', x)


def has_attack(n):
    """`Filter.hasAttack n` reads the printed attacks of a Pokémon card, not attacks a Tool gives (Pokemon/Card.lean).
    For a Pokémon in play that is the printed "has the X attack" unless a Tool can give an attack named X, so
    such a name is refused (none is, in the dataset, for the names the importer meets)."""
    if n in TOOL_ATTACKS:
        raise Refuse('attack name a Pokémon Tool can give (Filter.hasAttack reads printed attacks only): ' + n)
    return ('hasAttack', n)


def bench_filter_ok(f):
    """`putBench` puts only a Basic Pokémon onto the Bench (`ZStep.putBench` requires `stage = .basic`,
    Pokemon/Effect.lean), which is the general rule for a card effect that puts Pokémon onto the Bench
    ("Put up to 3 Water Pokémon from your discard pile onto your Bench" benches Basic ones only). A
    printed placement that names an Evolution card ("search your deck for a Silcoon and put it onto your
    Bench", "up to 3 Lampent"; both Stage 1) overrides that rule, and is unreachable in the model
    (forbids some), so it is refused: every name in the filter must be a Basic Pokémon in every printing
    of the dataset (found in validation, importer v0.3.0)."""
    def bad(g):
        if g[0] == 'named':
            return not (NAME_STAGES.get(g[1]) == {'Basic'} and KNOWN_NAMES.get(g[1]) == {'Pokémon'})
        return any(bad(x) for x in g[1:] if isinstance(x, tuple) and x and isinstance(x[0], str) and x[0] in
                   ('and', 'or', 'not', 'named'))
    if bad(f):
        raise Refuse('Bench placement of a named card that is not a Basic Pokémon (putBench is Basic-only)')


# importer 0.16.0 (milestone MV9, survey S23 group A1): the printed subtypes "Ancient" and "Future", which the model's
# cards do not carry, as filters over the importer's pool (regulation marks H, I, J and Basic Energy, `pool.standard_pool`):
# `Filter.nameIn` of the names every pool record of which has the subtype, or'd with `and (named n) (hasAttack a)` for
# each pool record with the subtype whose name also has pool records without it (Koraidon, Koraidon ex, Miraidon,
# Miraidon ex), `a` an attack of that record that no record of the same name without the subtype prints. Every term
# the importer writes comes from a pool record, so on every card the importer can write the filter and the printed
# subtype agree (checked by `set_names`, which leaves a subtype out, and the phrase refused, if a record cannot be told
# apart this way). Filled by `set_names`: subtype -> filter, or None.
TAG_FILTERS = {}


def tag_filter(tag):
    f = TAG_FILTERS.get(tag)
    if f is None:
        raise Refuse('card kind with no filter: ' + tag + ' (a record with the subtype cannot be told apart by name '
                     'and attack)')
    return f


def _tag_filters(cards):
    import pool as P
    st = P.standard_pool(cards)
    out = {}
    for tag in ('Ancient', 'Future'):
        by = {}
        for c in st:
            by.setdefault(norm(c['name']), []).append(c)
        whole, parts, ok = [], [], True
        for n in sorted(by):
            recs = by[n]
            yes = [c for c in recs if tag in c['_sub']]
            if not yes:
                continue
            no = [c for c in recs if tag not in c['_sub']]
            if not no:
                whole.append(n)
                continue
            if any(c['supertype'] != 'Pokémon' for c in recs):
                ok = False
                break
            no_atk = {norm(a.get('name')) for c in no for a in c.get('attacks') or []}
            for c in yes:
                cand = [norm(a.get('name')) for a in c.get('attacks') or [] if norm(a.get('name')) not in no_atk
                        and norm(a.get('name')) not in TOOL_ATTACKS]
                if not cand:
                    ok = False
                    break
                part = ('and', ('named', n), ('hasAttack', cand[0]))
                if part not in parts:
                    parts.append(part)
            if not ok:
                break
        if not ok:
            out[tag] = None
            continue
        f = ('nameIn', whole)
        for x in parts:
            f = ('or', f, x)
        out[tag] = f
    return out


def set_names(cards):
    KNOWN_NAMES.clear()
    NAME_STAGES.clear()
    TOOL_ATTACKS.clear()
    OWNERS.clear()
    ALL_NAMES.clear()
    TOOL_ABILITIES.clear()
    for c in cards:
        ALL_NAMES.add(c['name'])
        if c['supertype'] == 'Pokémon':
            m = re.match(r"^(.+?)'s ", c['name'])
            if m:
                OWNERS.add(m.group(1))
        if c['supertype'] == 'Trainer' and 'Pokémon Tool' in c['_sub']:
            TOOL_ATTACKS.update(norm(a.get('name')) for a in c.get('attacks') or [])
        if c['supertype'] != 'Pokémon':
            TOOL_ABILITIES.update(norm(a.get('name')) for a in c.get('abilities') or [])
        sub = c['_sub']
        if c['supertype'] == 'Pokémon':
            NAME_STAGES.setdefault(norm(c['name']), set()).update(
                x for x in ('Basic', 'Stage 1', 'Stage 2', 'BREAK', 'LEGEND', 'Level-Up', 'VMAX', 'VSTAR', 'V-UNION')
                if x in sub or (x == 'Basic' and not sub & {'Stage 1', 'Stage 2', 'BREAK', 'LEGEND', 'Level-Up',
                                                            'VMAX', 'VSTAR', 'V-UNION'} and 'Basic' in sub))
        if c['supertype'] == 'Pokémon':
            k = 'Pokémon'
        elif c['supertype'] == 'Energy':
            k = 'Basic Energy' if 'Basic' in sub else 'Special Energy'
        else:
            k = next((x for x in ('Item', 'Supporter', 'Pokémon Tool', 'Stadium') if x in sub), 'Trainer (other)')
        KNOWN_NAMES.setdefault(norm(c['name']), set()).add(k)
    TAG_FILTERS.clear()
    TAG_FILTERS.update(_tag_filters(cards))


def parse_qty_np(q):
    """'up to 2 ', 'a ', 'an ', '2 ' -> (n, upto)."""
    q = q.strip()
    m = re.match(r'^up to (\d+|a|an|one|two|three)$', q)
    if m:
        return num(m.group(1)), True
    return num(q), False


def min_take(count, n, make, ctx):
    """Take `n` if at least `n` are there, else as many as there are: the printed 'put N' or
    'discard N' when fewer may be available. `make(q)` builds the move for quantity `q`.

    In an attack the effect does as much as it can, so with nothing to take it does nothing (`skip`,
    or the move of `all` of none). A Trainer cannot be played when its effect cannot happen (taken
    from rulings; not in the rulebook, 2026 p. 12; `noop.py`), so in a Trainer the case with nothing to take
    has no resolution: `exactly 1` of none, the model's convention for an unpayable cost
    (Pokemon/Rules.lean, `Move.item`), and a Trainer that can take some but fewer than `n` takes all
    of them.

    An Ability follows the attack convention (it does what it can, nothing when nothing can be
    taken); since importer 0.13.0 `no_effect_ability` then adds the precondition that something can be
    taken (`noop.py`), and the provisional `noopUse` mark set here is dropped."""
    if ctx['kind'] == 'ability':
        ctx['_cavs'].add('noopUse')
    if ctx['kind'] == 'trainer':
        if n == 1:
            return make(('exactly', 1))
        return ite(('countGe', count, n), make(('exactly', n)),
                   ite(('countGe', count, 1), make(('all',)), make(('exactly', 1))))
    if n == 1:
        return ite(('countGe', count, 1), make(('exactly', 1)), SKIP)
    return ite(('countGe', count, n), make(('exactly', n)), make(('all',)))


def parse_count(x, ctx):
    """'for each X' to a function k -> Amt (k counters per unit)."""
    x = x.strip()
    r = parse_count_s16(x, ctx)
    if r is not None:
        return r
    # milestone MV4 (S17 §B): Tools, Prize cards taken, Special Conditions, types of Basic Energy
    if x == 'Pokémon Tool attached to all of your Pokémon':
        return lambda k: ('count', ('tools', OWN), k)
    if x == "Pokémon Tool attached to all of your opponent's Pokémon":
        return lambda k: ('count', ('tools', OPP), k)
    if x == 'Pokémon Tool attached to all Pokémon':
        return lambda k: ('add', ('count', ('tools', OWN), k), ('count', ('tools', OPP), k))
    if x == "Colorless in your opponent's Active Pokémon's Retreat Cost":
        # milestone MV6: `Count.retreat`, the printed Retreat Cost (caveat `printedRetreat`, added in `translate_card`)
        return lambda k: ('count', ('retreat', OPP), k)
    if x == 'Prize card your opponent has taken':
        return lambda k: ('count', ('prizesTaken', OPP), k)
    if x == 'Prize card you have taken':
        return lambda k: ('count', ('prizesTaken', OWN), k)
    if x == "Special Condition affecting your opponent's Active Pokémon":
        return lambda k: ('count', ('conds', OPP), k)
    # "Pokémon in play that has \"Koffing\" or \"Weezing\" in its name (both yours and your opponent's)": both players'
    # Pokémon in play whose top card passes the name filter (`Count.inPlay`)
    m = re.match(r"^Pokémon in play that (?:has|have) (.+ in (?:its|their) names?) \(both yours and your opponent's\)$", x)
    if m:
        f = parse_filter('Pokémon that has ' + m.group(1), ctx)
        return lambda k: ('add', ('count', ('inPlay', OWN, f), k), ('count', ('inPlay', OPP, f), k))
    if x == 'type of Basic Energy attached to all of your Pokémon':
        return lambda k: ('count', ('energyTypes', OWN), k)
    # "Basic Energy attached" is `basicEnergy` (milestone MV5; until 0.10.0 `energy`); "Special Energy [card]
    # attached" is `specialEnergy`, counted by card (`Count.energy`)
    m = re.match(r'^(Basic|Special) Energy(?: cards?)? attached to (this Pokémon|your opponent\'s Active Pokémon'
                 r'|all of your Pokémon|all of your opponent\'s Pokémon)$', x)
    if m:
        f = BASIC_F if m.group(1) == 'Basic' else SPECIAL_F
        where = m.group(2)
        c = (('energy', OWN, f) if where == 'this Pokémon' else ('energy', OPP, f) if where.startswith('your opponent')
             else ('energyAll', OWN, f) if where == 'all of your Pokémon' else ('energyAll', OPP, f))
        return lambda k: ('count', c, k)
    m = re.match(r'^(?:(Basic )?' + TYPE_RE + r' )?Energy attached to (this Pokémon|your opponent\'s Active Pokémon'
                 r'|all of your Pokémon|all of your opponent\'s Pokémon)$', x)
    if m:
        f = ('energyOf', etype(m.group(2))) if m.group(2) else ENERGY_F
        if m.group(2) in ('Dragon', 'Colorless'):
            raise Refuse('Energy of a type with no Basic Energy')
        where = m.group(3)
        if where == 'this Pokémon':
            c = ('energy', OWN, f)
        elif where.startswith('your opponent'):
            c = ('energy', OPP, f)
        elif where == 'all of your Pokémon':
            c = ('energyAll', OWN, f)
        else:
            c = ('energyAll', OPP, f)
        return lambda k: ('count', c, k)
    if x == 'damage counter on this Pokémon':
        return lambda k: ('per', OWN, k)
    if x == "damage counter on your opponent's Active Pokémon":
        return lambda k: ('per', OPP, k)
    if x == 'of your Benched Pokémon':
        return lambda k: ('count', ('bench', OWN, ('pokemon',)), k)
    if x == "of your opponent's Benched Pokémon":
        return lambda k: ('count', ('bench', OPP, ('pokemon',)), k)
    if x == "Benched Pokémon (both yours and your opponent's)":
        return lambda k: ('add', ('count', ('bench', OWN, ('pokemon',)), k),
                          ('count', ('bench', OPP, ('pokemon',)), k))
    if x == 'of your Pokémon in play':
        # the Active Pokémon (the attacker, always there) and each Benched Pokémon
        return lambda k: ('add', ('const', k), ('count', ('bench', OWN, ('pokemon',)), k))
    if x == "of your opponent's Pokémon in play":
        return lambda k: ('add', ('const', k), ('count', ('bench', OPP, ('pokemon',)), k))
    if x == 'card in your hand':
        return lambda k: ('count', ('pile', OWN, ('hand',), ('any',)), k)
    if x == "card in your opponent's hand":
        return lambda k: ('count', ('pile', OPP, ('hand',), ('any',)), k)
    m = re.match(r"^(.+?) in your (opponent's )?discard pile$", x)
    if m:
        f = parse_filter(m.group(1), ctx)
        w = OPP if m.group(2) else OWN
        return lambda k: ('count', ('pile', w, ('discard',), f), k)
    # milestone MV2: "Pokémon in your discard pile that has the United Wings attack"
    m = re.match(r"^Pokémon in your (opponent's )?discard pile that (?:has|have) the (.+) attack$", x)
    if m:
        w = OPP if m.group(1) else OWN
        f = ('and', ('pokemon',), ('hasAttack', m.group(2)))
        return lambda k: ('count', ('pile', w, ('discard',), f), k)
    # milestone MV2: "of your [opponent's] F in play [that has the X attack / that has an Ability]": the
    # Pokémon in play, Active and Benched, whose top card passes the filter (`Count.inPlay`)
    m = re.match(r"^of your (opponent's )?(.+?) in play(?: that (?:has|have) (?:the (.+) attack|(an Ability)))?$", x)
    if m:
        w = OPP if m.group(1) else OWN
        f = parse_filter(m.group(2), ctx)
        if not is_pokemon_filter(f):
            raise Refuse('count not expressible: ' + x)
        if m.group(3):
            f = ('and', f, has_attack(m.group(3)))
        elif m.group(4):
            f = ('and', f, ('hasAbility',))
        return lambda k: ('count', ('inPlay', w, f), k)
    raise Refuse('count not expressible: ' + x)


# importer 0.16.0 (milestone MV9, survey S23 group B3): "you played X from your hand during this turn" and "you didn't
# play X …" (also "… this turn" without "during", in Abilities; "they played X from their hand this turn" in a
# Stadium, read for the player who uses it): `Count.played .own f`, the Supporter card the player played from the hand
# this turn (`PlayerState.supCard`, written by `Move.supporter` when the card is played, cleared when the player's next
# turn starts). Only a Supporter is recorded, so X must be a kind of Supporter ("a Supporter card", "a Future Supporter
# card", "a Supporter card that has \"Team Rocket\" in its name") or the name of a Supporter card; the filter is
# conjoined with `kind supporter`. The rulebook allows one Supporter a turn, so the one record is the whole history.
PLAYED_RX = re.compile(r"^(?:you|they) (played|didn't play) (.+?) from (?:your|their) hand (?:during )?this turn$")


def parse_test_played(c, ctx):
    m = PLAYED_RX.match(c)
    if not m:
        return None
    x = m.group(2)
    f = parse_filter(x, ctx)
    if f[0] == 'named' and KNOWN_NAMES.get(f[1]) != {'Supporter'}:
        raise Refuse('condition not expressible: a played card that is not a Supporter (only the Supporter is recorded): '
                     + c)
    if f[0] != 'named' and not supporter_filter(f):
        raise Refuse('condition not expressible: a played card that is not a Supporter (only the Supporter is recorded): '
                     + c)
    if not supporter_filter(f):
        f = ('and', ('kind', ('supporter',)), f)
    return [('countGe', ('played', OWN, f), 1)], m.group(1) == "didn't play"


def supporter_filter(f):
    """Only Supporter cards pass the filter (it names the Supporter kind in a conjunction)."""
    if f == ('kind', ('supporter',)):
        return True
    if f[0] == 'and':
        return supporter_filter(f[1]) or supporter_filter(f[2])
    if f[0] == 'or':
        return supporter_filter(f[1]) and supporter_filter(f[2])
    return False


def parse_test(c, ctx):
    """A condition 'If C, ...' to (tests, negated): the condition holds iff some test holds
    (or, when negated, iff none does)."""
    c = c.strip()
    # importer 0.9.0: a misprint in the data ("this Pokémon has any Fire Energy attaches", Zekrom)
    c = c.replace(' Energy attaches', ' Energy attached')
    r = parse_test_s16(c, ctx)
    if r is not None:
        return r
    r = parse_test_played(c, ctx)
    if r is not None:
        return r
    opp_a = "your opponent's Active Pokémon"
    m = re.match(r'^(this Pokémon|' + opp_a + r') (?:already )?has (any|no) damage counters on it$', c)
    if m:
        w = OWN if m.group(1) == 'this Pokémon' else OPP
        return [('atLeast', w, 1)], m.group(2) == 'no'
    # importer 0.13.0: "has exactly N damage counters on it" (`Test.exactly`, Mega Absol ex me1-86's test)
    m = re.match(r'^(this Pokémon|' + opp_a + r') has exactly (\d+) damage counters on it$', c)
    if m:
        return [('exactly', OWN if m.group(1) == 'this Pokémon' else OPP, num(m.group(2)))], False
    m = re.match(r'^' + opp_a + r" (is|isn't) (Asleep|Burned|Confused|Paralyzed|Poisoned)$", c)
    if m:
        return [('cond', OPP, (CONDS[m.group(2)],))], m.group(1) == "isn't"
    m = re.match(r'^' + opp_a + r" (is|isn't) affected by a Special Condition$", c)
    if m:
        return [('cond', OPP, (v,)) for v in CONDS.values()], m.group(1) == "isn't"
    m = re.match(r'^' + opp_a + r" is an? " + TYPE_RE + r' Pokémon$', c)
    if m:
        return [('isType', OPP, etype(m.group(1)))], False
    m = re.match(r'^this Pokémon has (?:at least )?(\d+) extra Energy attached \(in addition to this attack\'s cost\)$', c)
    if m:
        if ctx.get('cost') is None:
            raise Refuse('extra Energy outside an attack')
        return [('countGe', ('energy', OWN, ENERGY_F), num(m.group(1)) + len(ctx['cost']))], False
    m = re.match(r'^this Pokémon has any (Basic )?' + TYPE_RE + r' Energy attached(?: to it)?$', c)
    if m:
        return [('countGe', ('energy', OWN, ('energyOf', etype(m.group(2)))), 1)], False
    # importer 0.11.0 (milestone MV5): "any Special Energy" (`specialEnergy`) and "any Team Rocket's Energy" (the
    # name of a Special Energy card, `named`), counted by card on this Pokémon
    m = re.match(r'^this Pokémon has any (.+?) attached(?: to it)?$', c)
    if m and (m.group(1) == 'Special Energy' or KNOWN_NAMES.get(m.group(1)) == {'Special Energy'}):
        f = SPECIAL_F if m.group(1) == 'Special Energy' else ('named', m.group(1))
        return [('countGe', ('energy', OWN, f), 1)], False
    # importer 0.14.0 (Haxorus sv6pt5-46): the same on the opponent's Active Pokémon (`Count.energy .opp`, which counts
    # the Energy cards attached to that player's Active Pokémon passing the filter, Pokemon/Card.lean `Count`)
    if c == opp_a + ' has any Special Energy attached':
        return [('countGe', ('energy', OPP, SPECIAL_F), 1)], False
    m = re.match(r'^(you have|your opponent has) (\d+) or (more|fewer) cards in (your|their) hand$', c)
    if m:
        w = OWN if m.group(1) == 'you have' else OPP
        n = num(m.group(2))
        cnt = ('pile', w, ('hand',), ('any',))
        if m.group(3) == 'more':
            return [('countGe', cnt, n)], False
        return [('countGe', cnt, n + 1)], True
    m = re.match(r'^(you have|your opponent has) (\d+) or (more|fewer) Prize cards remaining$', c)
    if m:
        w = OWN if m.group(1) == 'you have' else OPP
        n = num(m.group(2))
        if m.group(3) == 'more':
            return [('countGe', ('prizes', w), n)], False
        return [('countGe', ('prizes', w), n + 1)], True
    m = re.match(r'^(you have|your opponent has) (\d+) or more Benched Pokémon$', c)
    if m:
        w = OWN if m.group(1) == 'you have' else OPP
        return [('countGe', ('bench', w, ('pokemon',)), num(m.group(2)))], False
    m = re.match(r'^you have any (.+?) on your Bench$', c)
    if m:
        return [('countGe', ('bench', OWN, parse_filter(m.group(1), ctx)), 1)], False
    # importer 0.8.0 (S15 §2, "If you don't have …, this attack does nothing": already expressible): the negations
    m = re.match(r"^you don't have (?:any )?(.+?) on your Bench$", c)
    if m and not re.search(r',| and |\d', m.group(1)):
        f = parse_filter(m.group(1), ctx)
        if not is_pokemon_filter(f):
            raise Refuse('condition not expressible: ' + c)
        return [('countGe', ('bench', OWN, f), 1)], True
    m = re.match(r"^you don't have (\d+) or more (.+?) in your discard pile$", c)
    if m:
        return [('countGe', ('pile', OWN, ('discard',), parse_filter(m.group(2), ctx)), num(m.group(1)))], True
    m = re.match(r'^you have no cards in your hand$', c)
    if m:
        return [('countGe', ('pile', OWN, ('hand',), ('any',)), 1)], True
    m = re.match(r'^(you have|your opponent has) (\d+) or fewer Benched Pokémon$', c)
    if m:
        w = OWN if m.group(1) == 'you have' else OPP
        return [('countGe', ('bench', w, ('pokemon',)), num(m.group(2)) + 1)], True
    m = re.match(r'^you have at least (\d+) ' + TYPE_RE + r' Energy in play$', c)
    if m:
        if m.group(2) in ('Dragon', 'Colorless'):
            raise Refuse('Energy of a type with no Basic Energy')
        return [('countGe', ('energyAll', OWN, ('energyOf', etype(m.group(2)))), num(m.group(1)))], False
    m = re.match(r'^this Pokémon has (\d+) or more (?:Basic )?' + TYPE_RE + r' Energy attached(?: to it)?$', c)
    if m:
        if m.group(2) in ('Dragon', 'Colorless'):
            raise Refuse('Energy of a type with no Basic Energy')
        return [('countGe', ('energy', OWN, ('energyOf', etype(m.group(2)))), num(m.group(1)))], False
    m = re.match(r'^your opponent has any ' + TYPE_RE + r' Pokémon in play$', c)
    if m:
        t = etype(m.group(1))
        return [('isType', OPP, t), ('countGe', ('bench', OPP, ('ptype', t)), 1)], False
    m = re.match(r'^you have (\d+) or more (.+?) in your discard pile$', c)
    if m:
        return [('countGe', ('pile', OWN, ('discard',), parse_filter(m.group(2), ctx)), num(m.group(1)))], False
    r = parse_test_mv2(c, ctx)
    if r is not None:
        return r
    r = parse_test_and(c, ctx)
    if r is not None:
        return r
    raise Refuse('condition not expressible: ' + c)


def parse_test_and(c, ctx):
    """Importer 0.13.0 (survey S16 §5): conditions that are conjunctions of the model's tests, written as nested `ite`s
    (`branch`, `and_ite`): an exact number of Prize cards ("you have exactly 6 Prize cards remaining"; "doesn't have
    exactly 3 or 4": 3 or more and not 5 or more; `Count.prizes`, the Prize cards left), two Pokémon names on the Bench
    ("Beldum and Metang are on your Bench", "you don't have Uxie and Azelf on your Bench"), and "all of your Pokémon in
    play are F" (no Pokémon in play outside F, `Count.inPlay`)."""
    m = re.match(r"^(you have|your opponent has|your opponent doesn't have) exactly (\d+)(?: or (\d+))? Prize cards? remaining$", c)
    if m:
        w = OWN if m.group(1) == 'you have' else OPP
        lo = num(m.group(2))
        hi = num(m.group(3)) if m.group(3) else lo
        if hi < lo:
            raise Refuse('condition not expressible: ' + c)
        cnt = ('prizes', w)
        t = ('AND', ((('countGe', cnt, lo), True), (('countGe', cnt, hi + 1), False)))
        return [t], m.group(1) == "your opponent doesn't have"
    m = re.match(r"^(?:(.+?) and (.+?) are on your Bench|you don't have (.+?) and (.+?) on your Bench)$", c)
    if m:
        a, b = (m.group(1), m.group(2)) if m.group(1) else (m.group(3), m.group(4))
        fs = []
        for x in (a, b):
            if re.search(r',| and |\d|any ', x):
                return None
            f = parse_filter(x, ctx)
            if not (f[0] == 'named' and is_pokemon_filter(f)):
                return None
            fs.append(f)
        t = ('AND', tuple((('countGe', ('bench', OWN, f), 1), True) for f in fs))
        return [t], bool(m.group(3))
    m = re.match(r'^all of your Pokémon in play are (.+)$', c)
    if m:
        f = parse_filter(m.group(1), ctx)
        if not is_pokemon_filter(f):
            return None
        return [('countGe', ('inPlay', OWN, ('and', ('pokemon',), ('not', f))), 1)], True
    return None


# milestone MV2, (C): the printed kinds of the opponent's Active Pokémon a test reads (`Test.top w f`, which reads
# its top card, a printed card). "Pokémon ex" is `Filter.ex` (rule box ex or Mega Evolution ex: every Mega
# Evolution Pokémon ex is a Pokémon ex, Pokemon/Card.lean `RuleBox`); "Evolution Pokémon" is "not Basic" (the
# model's stages are Basic, Stage 1, Stage 2, and only Basic Pokémon are put into play other than by evolving).
TOP_KINDS = {
    'Pokémon ex': ('ex',),
    'Pokémon ex or Pokémon V': ('ex',),
    'Evolution Pokémon': ('not', ('basic',)),
    'Basic Pokémon': ('basic',),
    'Stage 1 Pokémon': ('stage', ('stage1',)),
    'Stage 2 Pokémon': ('stage', ('stage2',)),
    'Tera Pokémon': ('tera',),
}

KO_LAST = r'^any of your (.+?) were Knocked Out (by damage from an attack )?during your opponent\'s last turn$'


def is_pokemon_filter(f):
    """Only Pokémon cards pass the filter (a count or test of Pokémon in play reads top cards, which are
    Pokémon cards; a filter that names another kind would be read as an empty count, so it is refused)."""
    h = f[0]
    if h in ('pokemon', 'basic', 'stage', 'ptype', 'ex', 'tera', 'hasAttack', 'hasAbility', 'megaEx', 'resists',
             'abilityNamed'):
        return True
    if h == 'named':
        return KNOWN_NAMES.get(f[1]) == {'Pokémon'}
    if h == 'and':
        return is_pokemon_filter(f[1]) or is_pokemon_filter(f[2])
    if h == 'or':
        return is_pokemon_filter(f[1]) and is_pokemon_filter(f[2])
    return False


def tcav(ctx, code):
    """A caveat of a test (recorded on the context; the caller moves it onto the item it builds)."""
    ctx.setdefault('_tc', set()).add(code)


def parse_test_mv2(c, ctx):
    m = re.match(r"^(your opponent's Active Pokémon|the Defending Pokémon) (is|isn't) (?:a|an) (.+)$", c)
    if m and m.group(3) in TOP_KINDS:
        if m.group(1) == 'the Defending Pokémon' and ctx['kind'] != 'attack':
            raise Refuse('the Defending Pokémon outside an attack')
        return [('top', OPP, TOP_KINDS[m.group(3)])], m.group(2) == "isn't"
    if c == 'this Pokémon has a Pokémon Tool attached':
        if ctx['kind'] == 'trainer':
            raise Refuse('this Pokémon outside an attack')
        return [('hasTool', OWN)], False
    if c == "your opponent's Active Pokémon has a Pokémon Tool attached":
        return [('hasTool', OPP)], False
    m = re.match(r'^you have (?:any )?(.+?) in play$', c)
    if m and not re.search(r',| and |\d', m.group(1)):
        try:
            f = parse_filter(m.group(1), ctx)
        except Refuse:
            return None
        if is_pokemon_filter(f):
            return [('countGe', ('inPlay', OWN, f), 1)], False
    # importer 0.16.0 (milestone MV9): the same of the opponent ("If your opponent has any Future Pokémon in play"), and
    # the printed Resistance of the opponent's Active Pokémon (`Test.top .opp (resists t)`)
    m = re.match(r'^your opponent has (?:any )?(.+?) in play$', c)
    if m and not re.search(r',| and |\d', m.group(1)):
        try:
            f = parse_filter(m.group(1), ctx)
        except Refuse:
            return None
        if is_pokemon_filter(f):
            return [('countGe', ('inPlay', OPP, f), 1)], False
    m = re.match(r"^(your opponent's Active Pokémon|the Defending Pokémon) has " + TYPE_RE + r' Resistance$', c)
    if m:
        if m.group(1) == 'the Defending Pokémon' and ctx['kind'] != 'attack':
            raise Refuse('the Defending Pokémon outside an attack')
        return [('top', OPP, ('resists', etype(m.group(2))))], False
    # (A) one-turn history
    m = re.match(KO_LAST, c)
    if m:
        if m.group(1) != 'Pokémon':
            # `Count.koLast` records a Knock Out of any of the player's Pokémon, not of a kind (milestone MV4 left it so)
            raise Refuse('condition not expressible: Knock Out record of a kind of Pokémon (Count.koLast records any): ' + c)
        if m.group(2):
            tcav(ctx, 'koAttackWide')
            return [('countGe', ('koLast', OWN, True), 1)], False
        tcav(ctx, 'koCheckup')
        return [('countGe', ('koLast', OWN, False), 1)], False
    if c == 'this Pokémon moved from your Bench to the Active Spot this turn':
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon moved up: outside an attack')
        tcav(ctx, 'movedUpPromotion')
        return [('movedUp', OWN)], False
    m = re.match(r'^this Pokémon evolved from (.+) during this turn$', c)
    if m:
        # `Test.evolved` is "evolved this turn"; "from X" is exact only when X is the card's own printed
        # pre-evolution, the one card the model can evolve it from (no Rare Candy or evolution by effect)
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon evolved: outside an attack')
        if m.group(1) != ctx.get('evolvesFrom'):
            raise Refuse('evolved from a card that is not its printed pre-evolution: ' + c)
        return [('evolved', OWN)], False
    return None


def branch(tests, neg, a, b):
    """`if any test then a else b` (or the reverse when negated), as nested `ite`. A test may be a conjunction
    ('AND', ((t, polarity), ...)) (importer 0.13.0: "exactly N Prize cards", "X and Y are on your Bench", "all of your
    Pokémon in play are F"), written as nested `ite`s whose failing branches are the rest."""
    if neg:
        a, b = b, a
    out = b
    for t in reversed(tests):
        out = and_ite(t, a, out, ite)
    return out


def and_ite(t, a, b, mk):
    """`ite t a b` for a test or a conjunction of literals (see `branch`); `mk` builds one `ite` node."""
    if t[0] != 'AND':
        return mk(t, a, b)
    out = a
    for (u, p) in reversed(t[1]):
        out = mk(u, out, b) if p else mk(u, b, out)
    return out


def exactly_count(cnt, n):
    """'the count is exactly n': n or more and not n + 1 or more."""
    return ('AND', ((('countGe', cnt, n), True), (('countGe', cnt, n + 1), False)))


# ------------------------------------------------------------------ items produced by sentences

class Eff:
    """A plain effect, resolved after the damage step in printed order, or (`pre`, "Before doing
    damage, …") before it."""
    def __init__(self, e, cavs=(), pre=False):
        self.e, self.cavs, self.pre = e, set(cavs), pre


class Dmg:
    """A change to the attack's damage: `op` in set (the amount for '×' and blank damage), add
    ('+'), sub ('-'), cond (test-dependent addition), flipadd (one coin), coins (N coins), many
    (flip until tails)."""
    def __init__(self, op, *args, cavs=(), reads=False):
        self.op, self.args, self.cavs, self.reads = op, args, set(cavs), reads


class Nothing:
    """'this attack does nothing' (the consequent of a coin flip or a condition)."""


class Drain:
    """'Heal from this Pokémon the same amount of damage you did to your opponent's Active Pokémon.'"""


class AbItem:
    """An Ability's effect that acts on "this Pokémon" (an `AbEff`, Pokemon/Card.lean)."""
    def __init__(self, a, cavs=()):
        self.a, self.cavs = a, set(cavs)


def abseq(*xs):
    """Right-nested `AbEff.seq`, adjacent `fx` parts merged into one `fx` of their `seq`."""
    out = []
    for x in xs:
        if out and out[-1][0] == 'fx' and x[0] == 'fx':
            out[-1] = ('fx', seq(out[-1][1], x[1]))
        else:
            out.append(x)
    out = [x for x in out if x != ('fx', SKIP)] or [('fx', SKIP)]
    r = out[-1]
    for x in reversed(out[:-1]):
        r = ('seq', x, r)
    return r


class Cost:
    """A Trainer's cost ('You can use this card only if you discard N other cards from your hand'),
    resolved first."""
    def __init__(self, e, cavs=()):
        self.e, self.cavs = e, set(cavs)


# ------------------------------------------------------------------ the sentence table

RULES = []


def rule(name, pattern, where, lean_desc):
    """Register a sentence rule. `where`: 'A' attacks, 'T' Trainers, 'B' both."""
    rx = re.compile('^' + pattern + '$')

    def deco(fn):
        RULES.append((name, rx, where, lean_desc, fn))
        return fn
    return deco


OPPA = r"your opponent's Active Pokémon"


@rule('more-damage-for-each', r'This attack does (\d+) more damage for each (.+)\.', 'A',
      'damage (add (const B) (count C k))')
def _(m, ctx):
    k = counters(m.group(1))
    return Dmg('add', parse_count(m.group(2), ctx)(k), reads=True)


@rule('damage-for-each', r'This attack does (\d+) damage for each (?!heads)(.+)\.', 'A', 'damage (count C k)')
def _(m, ctx):
    k = counters(m.group(1))
    return Dmg('set', parse_count(m.group(2), ctx)(k), k, reads=True)


@rule('less-damage-for-each', r'This attack does (\d+) less damage for each (.+)\.', 'A',
      'damage (sub (const B) (per/count C k))')
def _(m, ctx):
    k = counters(m.group(1))
    return Dmg('sub', parse_count(m.group(2), ctx)(k), reads=True)


@rule('damage-to-1-opp', r"This attack does (\d+) damage to 1 of your opponent's Pokémon\.", 'A',
      'ite (countGe (bench opp pokemon) 1) (choice (damage (const n)) (benchDamage opp n)) (damage (const n))')
def _(m, ctx):
    return Dmg('target1', counters(m.group(1)), cavs={'benchMods'})


@rule('damage-to-each-opp', r"This attack does (\d+) damage to each of your opponent's Pokémon\.", 'A',
      'damage (const n); spreadDamage opp n')
def _(m, ctx):
    return Dmg('each', counters(m.group(1)), cavs={'benchMods'})


@rule('damage-to-1-opp-bench', r"This attack does (\d+) damage to 1 of your opponent's Benched Pokémon\.", 'A',
      'benchDamage opp n')
def _(m, ctx):
    if ctx['base'] is not None:
        raise Refuse('Bench-only damage with a printed base damage')
    return Eff(('benchDamage', OPP, counters(m.group(1))), {'benchMods'})


@rule('damage-each-opp-bench', r"This attack does (\d+) damage to each of your opponent's Benched Pokémon\.", 'A',
      'spreadDamage opp n')
def _(m, ctx):
    if ctx['base'] is not None:
        raise Refuse('Bench-only damage with a printed base damage')
    return Eff(('spreadDamage', OPP, counters(m.group(1))), {'benchMods'})


@rule('counters-each-opp', r"(?:Put|Place) (\d+) damage counters? on each of your opponent's Pokémon\.", 'B',
      'counters n; spreadCounters opp n')
def _(m, ctx):
    n = num(m.group(1))
    return Eff(seq(('counters', n), ('spreadCounters', OPP, n)))


@rule('counters-own-active', r'Put (\d+) damage counters? on your Active Pokémon\.', 'T', 'selfDamage n')
def _(m, ctx):
    return Eff(('selfDamage', num(m.group(1))))


@rule('each-draws', r'Each player draws (a card|\d+ cards)\.', 'B', 'move own (top n) hand any all; move opp (top n) hand any all')
def _(m, ctx):
    n = 1 if m.group(1) == 'a card' else num(m.group(1).split()[0])
    return Eff(seq(draw(OWN, n), draw(OPP, n)))


@rule('may-draw', r'You may draw (a card|\d+ cards)\.', 'B', 'choice (move own (top n) hand any all) skip')
def _(m, ctx):
    n = 1 if m.group(1) == 'a card' else num(m.group(1).split()[0])
    return Eff(choice(draw(OWN, n), SKIP))


@rule('may-switch-out-opp', r"You may switch out your opponent's Active Pokémon to the Bench\. \(Your opponent chooses the new Active Pokémon\.\)",
      'B', 'choice (switch opp) skip')
def _(m, ctx):
    return Eff(choice(('switch', OPP), SKIP))


@rule('may-search-to-hand', r'You may search your deck for (up to \d+|an?|\d+) (.+?)(?:, reveal (?:it|them),)? and put (?:it|them) into your hand\.',
      'B', 'move own deck hand F (upTo n)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    return Eff(('move', OWN, ('deck',), ('hand',), f, ('upTo', n)), {'searchAny'} if f == ('any',) else set())


@rule('also-1-bench', r"This attack also does (\d+) damage to 1 of (your|your opponent's) Benched Pokémon\.", 'A',
      'benchDamage w n')
def _(m, ctx):
    w = OWN if m.group(2) == 'your' else OPP
    return Eff(('benchDamage', w, counters(m.group(1))), {'benchMods'})


@rule('also-each-bench', r"This attack also does (\d+) damage to each of (your|your opponent's) Benched Pokémon\.",
      'A', 'spreadDamage w n')
def _(m, ctx):
    w = OWN if m.group(2) == 'your' else OPP
    return Eff(('spreadDamage', w, counters(m.group(1))), {'benchMods'})


@rule('also-each-bench-both', r"This attack also does (\d+) damage to each Benched Pokémon \(both yours and your opponent's\)\.",
      'A', 'spreadDamage own n; spreadDamage opp n')
def _(m, ctx):
    n = counters(m.group(1))
    return Eff(seq(('spreadDamage', OWN, n), ('spreadDamage', OPP, n)), {'benchMods'})


# ---- milestone MV3, stage 1: a damage step that ignores steps of the damage calculation (`Ign`, Pokemon/Ignore.lean)

IGN_TEXT = {
    'Weakness': {'weak': True},
    'Resistance': {'resist': True},
    'Weakness or Resistance': {'weak': True, 'resist': True},
    "any effects on your opponent's Active Pokémon": {'fx': True},
    "Weakness or Resistance, or by any effects on your opponent's Active Pokémon": {'weak': True, 'resist': True, 'fx': True},
}


@rule('damage-ignores', r"This attack's damage isn't affected by (" + '|'.join(re.escape(k) for k in IGN_TEXT) + r")\.", 'A',
      'damage a {weak/resist/fx := true} on every damage step to the opponent\'s Active Pokémon')
def _(m, ctx):
    # `Effect.damage a ig`: the damage is `GameState.dealtI ig n`, the rulebook's calculation (2026 p. 19) with step 3
    # (Weakness, `weak`), step 4 (Resistance, `resist`) or step 5 (every effect on the defender: its stored reduction and
    # prevention and the static reductions and preventions in force on it, `fx`) switched off; step 2, the attacker's
    # bonuses, always applies, as the printed text names only the defender. Exact for the five printed variants. The flags
    # go on every damage step of the attack's damage tree (`build_attack`); Bench damage takes no Weakness, Resistance or
    # modifier in the model in any case (its caveat `benchMods` is unchanged). With `fx`, step 5 also drops a Stadium's
    # reduction or prevention on the defender: caveat `ignFxStadium`.
    ig = IGN_TEXT[m.group(1)]
    return Dmg('ign', ig, cavs={'ignFxStadium'} if ig.get('fx') else set())


# ---- milestone MV2, (B): damage and counters on several chosen Pokémon (Pokemon/Spread.lean)

@rule('damage-to-M-opp', r"This attack does (\d+) damage to (?:each of )?(\d+) of your opponent's Pokémon\.", 'A',
      'Effect.hitSome m n, unfolded: ite (countGe (bench opp any) m) (choice (damage n; benchSome opp (m-1) any true n) '
      '(benchSome opp m any true n)) (damage n; benchSome opp (m-1) any true n)')
def _(m, ctx):
    k = num(m.group(2))
    if k < 2:
        raise Refuse('wording')
    return Dmg('targetM', k, counters(m.group(1)), cavs={'benchMods'})


BENCH_KINDS = {'Pokémon': ('any',), 'Pokémon ex': ('ex',), 'Pokémon ex or Benched Pokémon V': ('ex',)}


@rule('damage-to-M-opp-bench', r"This attack (also )?does (\d+) damage to (\d+) of your opponent's Benched "
      r"(Pokémon|Pokémon ex|Pokémon ex or Benched Pokémon V)\.", 'A', 'benchSome opp m F true n')
def _(m, ctx):
    # "M of your opponent's Benched Pokémon [ex]": M distinct Benched Pokémon whose card passes F, all of them if
    # fewer pass (`Hits`); attack damage with no Weakness or Resistance (as printed for the Bench) and in the
    # model no other modifier (benchMods); none on a Benched Tera Pokémon (as printed)
    if not m.group(1) and ctx['base'] is not None:
        raise Refuse('Bench-only damage with a printed base damage')
    return Eff(('benchSome', OPP, num(m.group(3)), BENCH_KINDS[m.group(4)], True, counters(m.group(2))), {'benchMods'})


@rule('spread-any', r"Put (\d+) damage counters on your opponent's (Benched )?Pokémon in any way you like\.", 'B',
      'N copies of (benchCounters opp 1), or of (one_of opp (counters 1) (benchCounters opp 1))')
def _(m, ctx):
    # One counter at a time on a chosen Pokémon (Effect.spreadAny's idea): every distribution of the N
    # counters, and nothing else, because inside an attack no Knock Out is taken between the counters. Outside
    # an attack (TRun) a Knock Out check follows each counter, so it is refused there. With the Active Pokémon
    # among the targets each counter is `one_of`, not the bare `choice` of `Effect.spreadAny false`, whose
    # `benchCounters` branch does nothing on an empty Bench and would let counters be dropped.
    if ctx['kind'] != 'attack':
        raise Refuse('damage counters "in any way you like" outside an attack (a Knock Out check follows each counter)')
    n = num(m.group(1))
    one = ('benchCounters', OPP, 1) if m.group(2) else one_of(OPP, ('counters', 1), ('benchCounters', OPP, 1))
    return Eff(seq(*[one] * n))


@rule('counters-M-opp', r"Choose (\d+) of your opponent's Pokémon and put (\d+) damage counters on each of them\.", 'A',
      'Effect.countersSome m n, unfolded')
def _(m, ctx):
    k, n = num(m.group(1)), num(m.group(2))
    if k < 2:
        raise Refuse('wording')
    return Eff(some_of(k, ('counters', n), lambda j: ('benchSome', OPP, j, ('any',), False, n)))


@rule('opp-discards-more', r"Your opponent discards (\d+) more cards\.", 'A',
      'as opp-discards: the cards after the ones a sentence before discarded')
def _(m, ctx):
    return Eff(opp_hand_discard(num(m.group(1)), ctx))


def some_of(k, active, bench):
    """`k` distinct Pokémon of the opponent's (`Effect.hitSome`, `Effect.countersSome`, Pokemon/Spread.lean): the
    Active Pokémon and k-1 Benched ones, or k Benched ones when the Bench has that many; with fewer, the Active
    Pokémon and every Benched one (`benchSome` takes all that pass when fewer than asked do)."""
    return ite(('countGe', ('bench', OPP, ('any',)), k), choice(seq(active, bench(k - 1)), bench(k)),
               seq(active, bench(k - 1)))


# milestone MV7b (importer 0.14.0): an attack's "Knock Out …" / "… is Knocked Out" on the opponent's Pokémon is
# `KO_COUNTERS` damage counters on it (Pokemon/SelfKO.lean: counters above every derived HP are a pending Knock Out,
# taken by the batch Knock Out step after the attack, with its Prize cards and promotion; Known gaps, self-Knock-Out
# Abilities), caveat koCounters. Damage counters are not damage (2023 rulebook p. 20, step 1), as a Knock Out is not:
# no Weakness, Resistance, reduction or prevention applies to either (`counters` is unmodified, Known gaps).
@rule('ko-opp-active', r"(?:Knock Out your opponent's Active Pokémon|Your opponent's Active Pokémon is Knocked Out)\.", 'A',
      'counters 9999')
def _(m, ctx):
    return Eff(('counters', KO_COUNTERS), {'koCounters'})


@rule('ko-opp-active-kind', r"Knock Out your opponent's Active (Basic Pokémon|Pokémon ex|Evolution Pokémon)\.", 'A',
      'ite (top opp F) (counters 9999) skip')
def _(m, ctx):
    return Eff(ite(('top', OPP, TOP_KINDS[m.group(1)]), ('counters', KO_COUNTERS), SKIP), {'koCounters'})


@rule('ko-opp-bench-kind', r"Knock Out 1 of your opponent's Benched (Basic Pokémon|Pokémon ex|Pokémon)\.", 'A',
      'benchSome opp 1 F false 9999')
def _(m, ctx):
    f = {'Basic Pokémon': ('basic',), 'Pokémon ex': ('ex',), 'Pokémon': ('any',)}[m.group(1)]
    return Eff(('benchSome', OPP, 1, f, False, KO_COUNTERS), {'koCounters'})


@rule('ko-opp-1', r"Knock Out 1 of your opponent's Pokémon\.", 'A', 'one_of opp (counters 9999) (benchCounters opp 9999)')
def _(m, ctx):
    return Eff(one_of(OPP, ('counters', KO_COUNTERS), ('benchCounters', OPP, KO_COUNTERS)), {'koCounters'})


@rule('recoil', r'This Pokémon (?:also )?does (\d+) damage to itself\.', 'A', 'selfDamage n')
def _(m, ctx):
    return Eff(('selfDamage', counters(m.group(1))), {'recoil'})


@rule('heal-self', r'Heal (\d+) damage from this Pokémon\.', 'A', 'heal n')
def _(m, ctx):
    return Eff(('heal', counters(m.group(1))))


@rule('heal-all-self', r'Heal all damage from this Pokémon\.', 'A', 'healAll')
def _(m, ctx):
    return Eff(('healAll',))


@rule('drain', r"Heal from this Pokémon the same amount of damage you did to your opponent's Active Pokémon\.",
      'A', 'drain (the damage step)')
def _(m, ctx):
    return Drain()


@rule('heal-active', r'Heal (\d+) damage from your Active Pokémon\.', 'T', 'heal n')
def _(m, ctx):
    return Eff(('heal', counters(m.group(1))), noop(ctx))


def one_of(w, active, bench):
    """'1 of the w player's Pokémon': the Active one or a Benched one, and the Active one when
    there is no Benched Pokémon (`benchHeal`, `benchDamage` and `benchCounters` do nothing on an
    empty Bench, so a bare `choice` would also allow doing nothing)."""
    return ite(('countGe', ('bench', w, ('pokemon',)), 1), choice(active, bench), active)


@rule('heal-1-of-your', r'Heal (\d+) damage from 1 of your Pokémon\.', 'B',
      'ite (countGe (bench own pokemon) 1) (choice (heal n) (benchHeal n)) (heal n)')
def _(m, ctx):
    n = counters(m.group(1))
    return Eff(one_of(OWN, ('heal', n), ('benchHeal', n)), noop(ctx))


@rule('heal-1-bench', r'Heal (\d+) damage from 1 of your Benched Pokémon\.', 'B', 'benchHeal n')
def _(m, ctx):
    return Eff(('benchHeal', counters(m.group(1))), noop(ctx))


# importer 0.18.0 (milestone MV11, survey S25): heals of several, filtered or all-damage Benched Pokémon
# (`Effect.benchHealSome m f n`: m distinct Benched Pokémon passing f, all if fewer pass; n = None heals all damage).
# m = 5 = `benchLimit` takes every Benched Pokémon that passes. Only the player's own Pokémon: a heal of the opponent's
# Pokémon is refused (it would not commute with the capped clamp inside an attack; S25).
BENCH_ALL = 5


def heal_filter(np, ctx):
    """The filter of "your [F] Pokémon" (np = "F Pokémon" or "Pokémon")."""
    if np == 'Pokémon':
        return ('any',)
    f = parse_filter(np, ctx)
    if not is_pokemon_filter(f):
        raise Refuse('card kind with no filter: ' + np)
    return f


def one_of_f(f, active, bench, ctx):
    """'1 of your F Pokémon': the Active Pokémon if it passes f, or one Benched Pokémon that passes f; with no Benched
    Pokémon passing f, the Active one if it passes, and otherwise nothing (an attack) or no resolution (a Trainer,
    `min_take`'s convention). The Active branch of the choice has no resolution when the Active Pokémon fails f."""
    if f == ('any',):
        return one_of(OWN, active, bench)
    act = ite(('top', OWN, f), active, NO_PLAY)
    none = NO_PLAY if ctx['kind'] == 'trainer' else SKIP
    return ite(('countGe', ('bench', OWN, f), 1), choice(act, bench), ite(('top', OWN, f), active, none))


@rule('heal-each', r'Heal (\d+) damage from each of your ((?:.+ )?Pokémon)\.', 'B',
      'seq (ite (top own F) (heal n) skip) (benchHealSome 5 F (some n)); F any: seq (heal n) (benchHealSome 5 any (some n))')
def _(m, ctx):
    n = counters(m.group(1))
    np = m.group(2)
    if np == 'Benched Pokémon':
        return Eff(('benchHealSome', BENCH_ALL, ('any',), ('some', n)), noop(ctx))
    if np.startswith('Benched '):
        raise Refuse('wording')
    f = heal_filter(np, ctx)
    act = ('heal', n) if f == ('any',) else ite(('top', OWN, f), ('heal', n), SKIP)
    return Eff(seq(act, ('benchHealSome', BENCH_ALL, f, ('some', n))), noop(ctx))


@rule('heal-1-bench-f', r'Heal (\d+|all) damage from 1 of your Benched (.+ )?Pokémon\.', 'B',
      'benchHealSome 1 F (some n | none)')
def _(m, ctx):
    n = None if m.group(1) == 'all' else ('some', counters(m.group(1)))
    f = heal_filter((m.group(2) or '') + 'Pokémon', ctx)
    return Eff(('benchHealSome', 1, f, n), noop(ctx))


@rule('heal-1-of-your-f', r'Heal (\d+|all) damage from 1 of your (.+ )?Pokémon\.', 'B',
      'one of: (heal n | healAll) on the Active Pokémon if it passes F, or benchHealSome 1 F')
def _(m, ctx):
    a = m.group(1)
    f = heal_filter((m.group(2) or '') + 'Pokémon', ctx)
    act = ('healAll',) if a == 'all' else ('heal', counters(a))
    bench = ('benchHealSome', 1, f, None if a == 'all' else ('some', counters(a)))
    return Eff(one_of_f(f, act, bench, ctx), noop(ctx))


@rule('heal-1-cure', r'Heal (\d+) damage from 1 of your Pokémon, and it recovers from all Special Conditions\.', 'T',
      'ite (countGe (bench own pokemon) 1) (choice (seq (heal n) cure) (benchHeal n)) (seq (heal n) cure)')
def _(m, ctx):
    # a Benched Pokémon has no Special Condition (`Benched`, kept by every move: `Move.wellFormed`), so the cure is
    # written on the Active branch only
    n = counters(m.group(1))
    return Eff(one_of(OWN, seq(('heal', n), ('cure',)), ('benchHeal', n)), noop(ctx))


@rule('heal-active-f', r'Heal (\d+) damage from your Active (.+ Pokémon|Pokémon that has (\d+) or more Energy attached)\.',
      'T', 'ite (top own F | countGe (energy own energy) k) (heal n) (no resolution)')
def _(m, ctx):
    n = counters(m.group(1))
    if m.group(3):
        t = ('countGe', ('energy', OWN, ENERGY_F), num(m.group(3)))
    else:
        t = ('top', OWN, heal_filter(m.group(2), ctx))
    return Eff(ite(t, ('heal', n), NO_PLAY), noop(ctx))


# importer 0.19.0 (milestone MV12, survey S26): computed amounts on chosen or filtered Pokémon (`Effect.hitBy w sp m F
# hurt dmg a`: at sp = active the w player's Active Pokémon if it is a target, damage counters; at sp = bench m distinct
# Benched targets, all if fewer, attack damage (dmg, none on a Tera Pokémon) or counters; a target passes F and, with
# hurt, has a damage counter; the amount `HAmt` is const n, count C k, per k (k per counter on the target) or toHp n
# ("until its remaining HP is n"), computed per target), and moves of all damage counters from one of the player's
# Benched Pokémon to the opponent's (`Effect.dumpCounters F sp`). Both clamps commute with every such read (survey S26:
# the amount added depends on the old damage only through the target, and only raises it; "has any damage counters"
# is kept by a cap at a positive bound): `Run.cap_sim`, `Run.xcap_sim`. Reads of the opponent's damage that lower it
# or move it (Sableye sv5-107, Alakazam sv6-82) stay refused.
def hit_by(w, sp, m, f, hurt, dmg, a):
    return ('hitBy', w, (sp,), m, f, hurt, dmg, a)


def count_hamt(x, k, ctx):
    """'k for each X' as an `HAmt` (`count C k` only; refused for other amounts)."""
    a = parse_count(x, ctx)(k)
    if a[0] != 'count':
        raise Refuse('a computed amount on a chosen Pokémon that is not a count')
    return a


@rule('damage-to-1-opp-for-each', r"This attack does (\d+) damage to 1 of your opponent's Pokémon for each (.+)\.", 'A',
      "ite (countGe (bench opp pokemon) 1) (choice (damage A) (hitBy opp bench 1 any false true H)) (damage A); "
      "A = count C k, H = count C k; 'for each damage counter on that Pokémon': A = per opp k, H = per k")
def _(m, ctx):
    k = counters(m.group(1))
    if m.group(2) == 'damage counter on that Pokémon':
        return Dmg('target1x', ('per', OPP, k), ('per', k), cavs={'benchMods'})
    a = count_hamt(m.group(2), k, ctx)
    return Dmg('target1x', a, a, cavs={'benchMods'})


@rule('also-1-opp-bench-hurt', r"This attack also does (\d+) damage to 1 of your opponent's Benched Pokémon that has any "
      r"damage counters on it\.", 'A', 'hitBy opp bench 1 any true true (const n)')
def _(m, ctx):
    return Eff(hit_by(OPP, 'bench', 1, ('any',), True, True, ('const', counters(m.group(1)))), {'benchMods'})


@rule('bench-for-each-counter', r"This attack does (\d+) damage to 1 of your opponent's Benched Pokémon for each damage "
      r"counter on that Pokémon\.", 'A', 'hitBy opp bench 1 any false true (per k)')
def _(m, ctx):
    if ctx['base'] is not None:
        raise Refuse('Bench-only damage with a printed base damage')
    return Eff(hit_by(OPP, 'bench', 1, ('any',), False, True, ('per', counters(m.group(1)))), {'benchMods'})


@rule('also-each-bench-hurt-both', r"This attack also does (\d+) damage to each Benched Pokémon that has any damage "
      r"counters on it \(both yours and your opponent's\)\.", 'A',
      'hitBy own bench 5 any true true (const n); hitBy opp bench 5 any true true (const n)')
def _(m, ctx):
    n = ('const', counters(m.group(1)))
    return Eff(seq(hit_by(OWN, 'bench', BENCH_ALL, ('any',), True, True, n),
                   hit_by(OPP, 'bench', BENCH_ALL, ('any',), True, True, n)), {'benchMods'})


@rule('damage-each-hurt-both', r"This attack does (\d+) damage to each Pokémon that has any damage counters on it "
      r"\(both yours and your opponent's\), except for this Pokémon\.", 'A',
      'ite (atLeast opp 1) (damage n) skip; hitBy opp bench 5 any true true n; hitBy own bench 5 any true true n')
def _(m, ctx):
    return Dmg('eachHurt', counters(m.group(1)), cavs={'benchMods'})


@rule('counters-each-opp-hurt', r"(?:Put|Place) (\d+) damage counters on each of your opponent's Pokémon that has any "
      r"damage counters on it\.", 'A', 'hitBy opp active 1 any true false (const n); hitBy opp bench 5 any true false (const n)')
def _(m, ctx):
    n = ('const', num(m.group(1)))
    return Eff(seq(hit_by(OPP, 'active', 1, ('any',), True, False, n),
                   hit_by(OPP, 'bench', BENCH_ALL, ('any',), True, False, n)))


@rule('counters-each-ability-both', r"(?:Put|Place) (\d+) damage counters on each Pokémon that has an Ability \(both "
      r"yours and your opponent's\)\.", 'A', 'hitBy w sp m hasAbility false false (const n), for both players and spots')
def _(m, ctx):
    # `Filter.hasAbility` reads the printed card: an Ability a Tool gives is not read (caveat abilityByTool)
    n = ('const', num(m.group(1)))
    f = ('hasAbility',)
    return Eff(seq(hit_by(OWN, 'active', 1, f, False, False, n), hit_by(OWN, 'bench', BENCH_ALL, f, False, False, n),
                   hit_by(OPP, 'active', 1, f, False, False, n), hit_by(OPP, 'bench', BENCH_ALL, f, False, False, n)),
               {'abilityByTool'})


@rule('counters-opp-active-to-hp', r"(?:Put|Place) damage counters on your opponent's Active Pokémon until its "
      r"remaining HP is (\d+)\.", 'A', 'hitBy opp active 1 any false false (toHp n)')
def _(m, ctx):
    return Eff(hit_by(OPP, 'active', 1, ('any',), False, False, ('toHp', counters(m.group(1)))))


@rule('counters-opp-bench-to-hp', r"(?:Put|Place) damage counters on each of your opponent's Benched Pokémon until its "
      r"remaining HP is (\d+)\.", 'A', 'hitBy opp bench 5 any false false (toHp n)')
def _(m, ctx):
    return Eff(hit_by(OPP, 'bench', BENCH_ALL, ('any',), False, False, ('toHp', counters(m.group(1)))))


@rule('counters-opp-active-for-each', r"(?:Put|Place) (\d+) damage counters on your opponent's Active Pokémon for each "
      r"(.+)\.", 'A', 'hitBy opp active 1 any false false (count C n)')
def _(m, ctx):
    return Eff(hit_by(OPP, 'active', 1, ('any',), False, False, count_hamt(m.group(2), num(m.group(1)), ctx)))


MULT = {'Double': 1, 'Triple': 2, 'Quadruple': 3}


@rule('multiply-each-opp', r"(Double|Triple|Quadruple) the number of damage counters on each of your opponent's "
      r"Pokémon\.", 'A', 'hitBy opp active 1 any false false (per k); hitBy opp bench 5 any false false (per k)')
def _(m, ctx):
    a = ('per', MULT[m.group(1)])
    return Eff(seq(hit_by(OPP, 'active', 1, ('any',), False, False, a),
                   hit_by(OPP, 'bench', BENCH_ALL, ('any',), False, False, a)))


@rule('multiply-M-opp', r"[Cc]hoose (\d+) of your opponent's Pokémon and (double|triple|quadruple) the number of damage "
      r"counters on each of them\.", 'A', 'some_of m (hitBy opp active 1 any false false (per k)) (hitBy opp bench j any false false (per k))')
def _(m, ctx):
    k = num(m.group(1))
    if k < 2:
        raise Refuse('wording')
    a = ('per', MULT[m.group(2).capitalize()])
    return Eff(some_of(k, hit_by(OPP, 'active', 1, ('any',), False, False, a),
                       lambda j: hit_by(OPP, 'bench', j, ('any',), False, False, a)))


@rule('recoil-per-counter', r'This Pokémon also does (\d+) damage to itself for each damage counter on it\.', 'A',
      'hitBy own active 1 any false false (per k)')
def _(m, ctx):
    return Eff(hit_by(OWN, 'active', 1, ('any',), False, False, ('per', counters(m.group(1)))), {'recoil'})


@rule('also-each-own-named', r"This attack also does (\d+) damage to each of your (\S+) and (\S+)\.", 'A',
      'hitBy own active 1 F false false (const n); benchSome own 5 F true n; F = or (named a) (named b)')
def _(m, ctx):
    # "each of your Drifloon and Drifblim" (Drifblim svp-135): the player's own Active Pokémon (the attacker, if it has
    # one of the names) as damage counters (caveat recoil), and attack damage to each Benched one (benchMods)
    a, b = m.group(2), m.group(3)
    if not all(KNOWN_NAMES.get(x) == {'Pokémon'} for x in (a, b)):
        raise Refuse('names')
    f = ('or', ('named', a), ('named', b))
    n = counters(m.group(1))
    return Eff(seq(hit_by(OWN, 'active', 1, f, False, False, ('const', n)), ('benchSome', OWN, BENCH_ALL, f, True, n)),
               {'recoil', 'benchMods'})


@rule('dump-counters', r"Move all damage counters from 1 of your Benched ((?:.+ )?Pokémon) to (your opponent's Active "
      r"Pokémon|1 of your opponent's Pokémon)\.", 'A',
      "dumpCounters F active; '1 of your opponent's Pokémon': ite (countGe (bench opp pokemon) 1) (choice (dumpCounters F "
      "active) (dumpCounters F bench)) (dumpCounters F active)")
def _(m, ctx):
    f = heal_filter(m.group(1), ctx)
    if m.group(2).startswith('your'):
        return Eff(('dumpCounters', f, ('active',)))
    return Eff(one_of(OPP, ('dumpCounters', f, ('active',)), ('dumpCounters', f, ('bench',))))


COND_RE = r'(?:Asleep|Burned|Confused|Paralyzed|Poisoned)'


@rule('inflict', r"Your opponent's Active Pokémon is now (" + COND_RE + r'(?:, ' + COND_RE + r')*(?:,? and ' + COND_RE + r')?)\.',
      'B', 'inflict c [; inflict c\' ...]')
def _(m, ctx):
    cs = re.findall(COND_RE, m.group(1))
    return Eff(seq(*[('inflict', (CONDS[c],)) for c in cs]))


@rule('cure-self', r'(This Pokémon|Your Active Pokémon) recovers from all Special Conditions\.', 'B', 'cure')
def _(m, ctx):
    if ctx['kind'] == 'attack' and m.group(1) != 'This Pokémon':
        raise Refuse('wording')
    if ctx['kind'] == 'ability' and m.group(1) == 'This Pokémon' and ctx.get('spot') != ('active',):
        raise Refuse('this Pokémon (an Ability usable on the Bench) recovers: not expressible')
    return Eff(('cure',), noop(ctx))


@rule('counters-opp-active', r'(?:Put|Place) (\d+) damage counters? on ' + OPPA + r'\.', 'B', 'counters n')
def _(m, ctx):
    return Eff(('counters', num(m.group(1))))


@rule('counters-opp-1bench', r"(?:Put|Place) (\d+) damage counters? on 1 of your opponent's Benched Pokémon\.", 'B',
      'benchCounters opp n')
def _(m, ctx):
    return Eff(('benchCounters', OPP, num(m.group(1))))


@rule('counters-opp-1', r"(?:Put|Place) (\d+) damage counters? on 1 of your opponent's Pokémon\.", 'B',
      'ite (countGe (bench opp pokemon) 1) (choice (counters n) (benchCounters opp n)) (counters n)')
def _(m, ctx):
    n = num(m.group(1))
    return Eff(one_of(OPP, ('counters', n), ('benchCounters', OPP, n)))


@rule('counters-opp-each-bench', r"(?:Put|Place) (\d+) damage counters? on each of your opponent's Benched Pokémon\.", 'B',
      'spreadCounters opp n')
def _(m, ctx):
    return Eff(('spreadCounters', OPP, num(m.group(1))))


# An effect with no resolution: exactly 1 card from the top 0 cards of the deck.
NO_PLAY = ('move', OWN, ('top', 0), ('hand',), ('any',), ('exactly', 1))


def draw(w, n):
    return ('move', w, ('top', n), ('hand',), ('any',), ('all',))


@rule('draw', r'(?:Then, )?[Dd]raw (a card|(\d+) cards)\.', 'B', 'move own (top n) hand any all')
def _(m, ctx):
    return Eff(draw(OWN, num(m.group(2)) if m.group(2) else 1))


@rule('draw-more', r'[Dd]raw (a card|(\d+) cards) more\.|[Dd]raw (\d+) more cards?\.', 'B', 'move own (top n) hand any all')
def _(m, ctx):
    # importer 0.13.0 (Emcee's Hype sv10-163): "draw 2 more cards" after a draw is a second draw of 2
    n = num(m.group(3) or m.group(2) or '1')
    return Eff(draw(OWN, n))


@rule('draw-to', r'Draw cards until you have (\d+) cards in your hand\.', 'B', 'drawTo own n')
def _(m, ctx):
    return Eff(('drawTo', OWN, num(m.group(1))))


@rule('mill', r"Discard the top (?:(\d+) cards|card) of (your|your opponent's) deck\.", 'B',
      'move w (top n) discard any all')
def _(m, ctx):
    w = OWN if m.group(2) == 'your' else OPP
    return Eff(('move', w, ('top', num(m.group(1)) if m.group(1) else 1), ('discard',), ('any',), ('all',)))


@rule('switch-self', r'Switch this Pokémon with 1 of your Benched Pokémon\.', 'A', 'switch own')
def _(m, ctx):
    return Eff(('switch', OWN))


@rule('may-switch-self', r'You may switch this Pokémon with 1 of your Benched Pokémon\.', 'A',
      'choice (switch own) skip')
def _(m, ctx):
    return Eff(choice(('switch', OWN), SKIP))


@rule('switch-active', r'Switch your Active Pokémon with 1 of your Benched Pokémon\.', 'T', 'switch own')
def _(m, ctx):
    return Eff(('switch', OWN), noop(ctx))


@rule('gust', r"Switch in 1 of your opponent's Benched Pokémon to the Active Spot\.", 'B', 'switch opp')
def _(m, ctx):
    return Eff(('switch', OPP), noop(ctx))


@rule('switch-out-opp', r"Switch out your opponent's Active Pokémon to the Bench\. \(Your opponent chooses the new Active Pokémon\.\)",
      'B', 'switch opp')
def _(m, ctx):
    return Eff(('switch', OPP), noop(ctx))


@rule('shuffle', r'(?:Then, shuffle your deck|Shuffle your deck afterward)\.', 'B', 'shuffle')
def _(m, ctx):
    return Eff(('shuffle',))


def search_cavs(f, upto, ctx):
    cv = set()
    if upto and ctx['kind'] != 'attack':
        cv.add('upTo0')
    if f == ('any',):
        cv.add('searchAny')
    return cv


@rule('search-to-hand', r'Search your deck for (up to \d+|an?|\d+) (.+?)(?:, reveal (?:it|them),)? and put (?:it|them) into your hand\.',
      'B', 'move own deck hand F (upTo n)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    return Eff(('move', OWN, ('deck',), ('hand',), f, ('upTo', n)), search_cavs(f, upto, ctx))


@rule('search-to-bench', r'Search your deck for (up to \d+|an?|\d+) (.+?) and put (?:it|them) onto your Bench\.',
      'B', 'putBench own deck F (n times)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    cv = {'upTo0'} if upto and ctx['kind'] != 'attack' else set()
    bench_filter_ok(f)
    return Eff(seq(*[('putBench', OWN, ('deck',), f)] * n), cv)


def attach_item(parts, cv):
    """The attachments of one sentence as an item: an `Eff`, or, when they attach to "this Pokémon"
    in an Ability, an `AbItem` of `SelfOp.attach`s."""
    if any(x[0] == 'SELF' for x in parts):
        assert all(x[0] == 'SELF' for x in parts)
        return AbItem(abseq(*[('self', x[1]) for x in parts]), cv)
    return Eff(seq(*parts), cv)


# importer 0.14.0 (Magneton svp-153): "to your Lightning Pokémon in any way you like" is the target filter `ptype t` of
# `attach` (Pokemon/Effect.lean `ZStep.attachActive`, `attachBench`: `tf.eval (.pokemon top)`), the printed type
ATTACH_TGT = (r'(this Pokémon|1 of your Pokémon|1 of your Benched Pokémon|your (?:(?:Grass|Fire|Water|Lightning|Psychic|'
              r'Fighting|Darkness|Metal|Fairy|Dragon|Colorless) )?Pokémon in any way you like|'
              r'your Benched Pokémon in any way you like)')


def attach_one(src, f, tgt, ctx):
    if tgt == 'this Pokémon':
        if ctx['kind'] == 'ability':
            return ('SELF', ('attach', src, f))
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon outside an attack')
        return ('attach', OWN, src, f, ('active',), ('any',))
    if tgt in ('1 of your Pokémon', 'your Pokémon in any way you like'):
        return choice(('attach', OWN, src, f, ('active',), ('any',)), ('attach', OWN, src, f, ('bench',), ('any',)))
    mt = re.match(r'^your ' + TYPE_RE + r' Pokémon in any way you like$', tgt)
    if mt:
        tf = ('ptype', etype(mt.group(1)))
        return choice(('attach', OWN, src, f, ('active',), tf), ('attach', OWN, src, f, ('bench',), tf))
    return ('attach', OWN, src, f, ('bench',), ('any',))


@rule('search-attach', r'Search your deck for (up to \d+|an?|\d+) (.+?) and attach (?:it|them) to ' + ATTACH_TGT + r'\.',
      'B', 'attach own deck F spot any (n times)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    if not is_energy_filter(f):
        raise Refuse('attach a non-Energy card')
    if n > 1 and m.group(3) in ('1 of your Pokémon', '1 of your Benched Pokémon'):
        raise Refuse('several cards to one chosen Pokémon')
    cv = {'upTo0'} if upto and ctx['kind'] != 'attack' else set()
    return attach_item([attach_one(('deck',), f, m.group(3), ctx)] * n, cv)


@rule('attach-from-discard', r'Attach (up to \d+|an?|\d+) (.+?) from your discard pile to ' + ATTACH_TGT + r'\.',
      'B', 'attach own discard F spot any (n times)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    if not is_energy_filter(f):
        raise Refuse('attach a non-Energy card')
    if n > 1 and m.group(3) in ('1 of your Pokémon', '1 of your Benched Pokémon'):
        raise Refuse('several cards to one chosen Pokémon')
    cv = set()
    if not upto:
        cv.add('mayFail')
    elif ctx['kind'] != 'attack':
        cv.add('upTo0')
    return attach_item([attach_one(('discard',), f, m.group(3), ctx)] * n, cv)


@rule('recycle-to-hand', r'Put (up to \d+|an?|\d+) (.+?) from your discard pile into your hand\.', 'B',
      'move own discard hand F (upTo n | exactly n, or as many as there are; in a Trainer at least 1, min_take)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    mk = lambda q: ('move', OWN, ('discard',), ('hand',), f, q)
    if upto:
        return Eff(mk(('upTo', n)), {'upTo0'} if ctx['kind'] != 'attack' else set())
    return Eff(min_take(('pile', OWN, ('discard',), f), n, mk, ctx))


@rule('recycle-to-deck', r'Shuffle (up to \d+|an?|\d+) (.+?) from your discard pile into your deck\.', 'B',
      'move own discard shuffle F (upTo n | exactly n, or as many as there are; in a Trainer at least 1, min_take)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    mk = lambda q: ('move', OWN, ('discard',), ('shuffle',), f, q)
    if upto:
        return Eff(mk(('upTo', n)), {'upTo0'} if ctx['kind'] != 'attack' else set())
    return Eff(min_take(('pile', OWN, ('discard',), f), n, mk, ctx))


@rule('discard-to-bench', r'Put (up to \d+|an?|\d+) (.+?) from your discard pile onto your Bench\.', 'B',
      'putBench own discard F (n times)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    cv = set()
    if not upto:
        cv.add('mayFail')
    elif ctx['kind'] != 'attack':
        cv.add('upTo0')
    bench_filter_ok(f)
    return Eff(seq(*[('putBench', OWN, ('discard',), f)] * n), cv)


@rule('discard-energy', r"Discard (an|a|all|\d+) (?:(Basic )?" + TYPE_RE + r" |(Special) )?Energy (?:cards? )?from (this Pokémon|"
      + OPPA + r')\.', 'B',
      'ite (countGe (energy w F) n) (discardEnergy w active F (exactly n)) (... all | skip); in a Trainer no fallback when none (min_take)')
def _(m, ctx):
    q = m.group(1)
    t = m.group(3)
    if t in ('Dragon', 'Colorless'):
        raise Refuse('Energy of a type with no Basic Energy')
    # importer 0.11.0: "Discard a Special Energy from …" (`specialEnergy`; one card, as printed)
    f = ('energyOf', etype(t)) if t else SPECIAL_F if m.group(4) else ENERGY_F
    if m.group(5) == 'this Pokémon':
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon outside an attack')
        w = OWN
    else:
        w = OPP
    mk = lambda qq: ('discardEnergy', w, ('active',), f, qq)
    if q == 'all':
        return Eff(mk(('all',)))
    return Eff(min_take(('energy', w, f), num(q), mk, ctx))


# importer 0.18.0 (milestone MV11, survey S25): attached Energy put into the hand or shuffled into the deck
# (`Effect.returnEnergy w sp f q d`, the same take as `discardEnergy`, the cards put at `d`). The take is read as the
# discard's (`min_take`, `Qty.okE`); its Energy caveats come from the term walk (`_energy_reads`, kind 'select').
def return_energy(q, basic, t, special, who, dst, ctx):
    f = energy_filter(special or basic, t)
    if who == 'this Pokémon':
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon outside an attack')
        w = OWN
    else:
        w = OPP
    mk = lambda qq: ('returnEnergy', w, ('active',), f, qq, dst)  # noqa: E731
    if q == 'all':
        return mk(('all',))
    return min_take(('energy', w, f), num(q), mk, ctx)


RET_E = (r"(an|a|all|\d+) (?:(Basic )?" + TYPE_RE + r" |(Special) )?Energy attached to (this Pokémon|" + OPPA + r")")


@rule('put-energy-hand', r"Put " + RET_E + r" into (your|their) hand\.", 'B',
      'returnEnergy w active F (exactly n | all) hand, under min_take')
def _(m, ctx):
    if (m.group(5) == 'this Pokémon') != (m.group(6) == 'your'):
        raise Refuse('wording')
    return Eff(return_energy(m.group(1), m.group(2), m.group(3), m.group(4), m.group(5), ('hand',), ctx))


@rule('may-put-energy-opp-hand', r"You may put (an|a|\d+) Energy attached to your opponent's Active (Stage 2 )?Pokémon "
      r"into their hand\.", 'A', 'choice (ite (top opp (stage stage2))) (returnEnergy opp active energy … hand) skip) skip')
def _(m, ctx):
    e = return_energy(m.group(1), None, None, None, OPPA, ('hand',), ctx)
    if m.group(2):
        e = ite(('top', OPP, ('stage', ('stage2',))), e, SKIP)
    return Eff(choice(e, SKIP))


@rule('shuffle-energy-deck', r"Shuffle (all) Energy attached to this Pokémon into your deck\.", 'A',
      'returnEnergy own active energy all shuffle')
def _(m, ctx):
    return Eff(return_energy('all', None, None, None, 'this Pokémon', ('shuffle',), ctx))


# importer 0.18.0 (milestone MV11): "You may move any amount of [T] Energy from your Pokémon to your other Pokémon in any
# way you like." is `iter (moveEnergy own F)`: each step moves one card between two of the player's Pokémon, and any
# final placement is reached by moving each card once, from where it is to where it ends (each step checks
# `Card.attachOk` at its target, as print's attachment does); `iter` may stop at once (the printed "may", "any amount")
@rule('move-energy-any-way', r"You may move any amount of (?:(Basic )?" + TYPE_RE + r" )?Energy from your Pokémon to your "
      r"other Pokémon in any way you like\.", 'B', 'iter (moveEnergy own F)')
def _(m, ctx):
    return Eff(('iter', ('moveEnergy', OWN, energy_filter(m.group(1), m.group(2)))))


# importer 0.18.0 (milestone MV11): directed moves (`Effect.shiftEnergy w src F q dst one`): from this Pokémon (the
# attacker, Active) to one Benched Pokémon or to the Bench in any way; from the Benched Pokémon to the Active Pokémon
@rule('move-energy-self-to-bench', r"Move (all|\d+) Energy from this Pokémon to (1 of your Benched Pokémon|your Benched "
      r"Pokémon in any way you like)\.", 'A', 'shiftEnergy own active energy (all | exactly n) bench (one?)')
def _(m, ctx):
    one = m.group(2).startswith('1 of')
    mk = lambda qq: ('shiftEnergy', OWN, ('active',), ENERGY_F, qq, ('bench',), one)  # noqa: E731
    if m.group(1) == 'all':
        return Eff(mk(('all',)))
    return Eff(min_take(('energy', OWN, ENERGY_F), num(m.group(1)), mk, ctx))


@rule('move-energy-bench-to-active', r"Move up to (\d+) Energy from your Benched Pokémon to your Active Pokémon\.", 'T',
      'shiftEnergy own bench energy (upTo 1) active true, n times')
def _(m, ctx):
    # "from your Benched Pokémon": each card may come from another Benched Pokémon, so n one-card steps, each from a
    # Benched Pokémon chosen when it resolves; "up to" allows 0 (upTo0). Each step takes one card (`upTo 1` by units: one
    # card providing at least 1), so the n steps move up to n cards (moveUnits)
    n = num(m.group(1))
    st = ('shiftEnergy', OWN, ('bench',), ENERGY_F, ('upTo', 1), ('active',), True)
    return Eff(seq(*[st] * n), {'upTo0', 'moveUnits'})


@rule('ling-reduce-self', r"During your opponent's next turn, this Pokémon takes (\d+) less damage from attacks \(after applying Weakness and Resistance\)\.",
      'A', 'linger own next (reduce n)')
def _(m, ctx):
    return Eff(('linger', OWN, ('next',), ('reduce', counters(m.group(1)))), {'perPokemon'})


@rule('ling-prevent-self', r"During your opponent's next turn, prevent all damage done to this Pokémon by attacks\.",
      'A', 'linger own next prevent')
def _(m, ctx):
    return Eff(('linger', OWN, ('next',), ('prevent',)), {'perPokemon'})


# importer 0.17.0 (milestone MV10, survey S24): the damage half is `Mod.prevent`, the effect half `Mod.shield`
# (`Effect.shielded`, read by `Move.attack` through `GameState.shield`); both belong to the player (perPokemon).
@rule('ling-shield-self', r"During your opponent's next turn, prevent all damage from and effects of attacks done to this "
      r"Pokémon\.", 'A', 'linger own next prevent; linger own next shield')
def _(m, ctx):
    return Eff(seq(('linger', OWN, ('next',), ('prevent',)), ('linger', OWN, ('next',), ('shield',))),
               {'perPokemon', 'shieldReach'})


@rule('ling-lock-defending', r"During your opponent's next turn, (?:the Defending Pokémon|that Pokémon) can't (attack|use attacks|retreat)\.",
      'A', 'linger opp next (lock attack|retreat)')
def _(m, ctx):
    lk = 'retreat' if m.group(1) == 'retreat' else 'attack'
    return Eff(('linger', OPP, ('next',), ('lock', (lk,))), {'perPokemon'})


@rule('ling-lock-self', r"During your next turn, this Pokémon can't (attack|use attacks|retreat)\.", 'A',
      'linger own after (lock attack|retreat)')
def _(m, ctx):
    lk = 'retreat' if m.group(1) == 'retreat' else 'attack'
    return Eff(('linger', OWN, ('after',), ('lock', (lk,))), {'perPokemon'})


@rule('ling-lock-own-player', r"During your next turn, your Pokémon can't attack\.", 'B', 'linger own after (lock attack)')
def _(m, ctx):
    return Eff(('linger', OWN, ('after',), ('lock', ('attack',))))


@rule('ling-item-lock', r"During your opponent's next turn, they can't play any Item cards from their hand\.", 'B',
      'linger opp next (lock item)')
def _(m, ctx):
    return Eff(('linger', OPP, ('next',), ('lock', ('item',))))


@rule('ling-bonus-self', r"During your next turn, attacks used by this Pokémon do (\d+) more damage to your opponent's Active Pokémon \(before applying Weakness and Resistance\)\.",
      'A', 'linger own after (bonus n)')
def _(m, ctx):
    return Eff(('linger', OWN, ('after',), ('bonus', counters(m.group(1)))), {'perPokemon'})


@rule('ling-bonus-turn', r"During this turn, attacks used by your Pokémon do (\d+) more damage to your opponent's Active Pokémon \(before applying Weakness and Resistance\)\.",
      'T', 'linger own now (bonus n)')
def _(m, ctx):
    return Eff(('linger', OWN, ('now',), ('bonus', counters(m.group(1)))))


@rule('ling-reduce-all', r"During your opponent's next turn, all of your Pokémon take (\d+) less damage from attacks from your opponent's Pokémon \(after applying Weakness and Resistance\)\.",
      'T', 'linger own next (reduce n)')
def _(m, ctx):
    return Eff(('linger', OWN, ('next',), ('reduce', counters(m.group(1)))), {'benchMods'})


@rule('reveal-hand', r"Your opponent reveals their hand\.", 'B', 'skip')
def _(m, ctx):
    return Eff(SKIP, {'hiddenInfo'})


def opp_hand_discard(n, ctx):
    mk = lambda q: ('move', OPP, ('hand',), ('discard',), ('any',), q)
    return min_take(('pile', OPP, ('hand',), ('any',)), n, mk, ctx)


@rule('discard-random-opp-hand', r"Discard a random card from your opponent's hand\.", 'B',
      'ite (countGe (pile opp hand any) 1) (move opp hand discard any (exactly 1)) skip; in a Trainer move ... (exactly 1) (min_take)')
def _(m, ctx):
    return Eff(opp_hand_discard(1, ctx))


@rule('opp-discards', r"Your opponent discards (a card|\d+ cards) from their hand\.", 'B',
      'ite (countGe (pile opp hand any) n) (move opp hand discard any (exactly n)) (... all); in a Trainer no fallback when none (min_take)')
def _(m, ctx):
    n = 1 if m.group(1) == 'a card' else num(m.group(1).split()[0])
    return Eff(opp_hand_discard(n, ctx))


@rule('discard-own-hand-card', r"Discard (a card|\d+ cards) from your hand\.", 'A',
      'ite (countGe (pile own hand any) n) (move own hand discard any (exactly n)) (... all)')
def _(m, ctx):
    n = 1 if m.group(1) == 'a card' else num(m.group(1).split()[0])
    mk = lambda q: ('move', OWN, ('hand',), ('discard',), ('any',), q)
    return Eff(min_take(('pile', OWN, ('hand',), ('any',)), n, mk, ctx))


@rule('discard-own-hand-kind', r"Discard (an?|\d+) (?!cards?\b)(.+?) from your hand\.", 'A',
      'ite (countGe (pile own hand F) n) (move own hand discard F (exactly n)) (... all | skip)')
def _(m, ctx):
    # importer 0.8.0 (milestone MV3: the cost of "If you can't, this attack does nothing"): a discard of a kind of
    # card from the hand, as the any-card rule above, with the filter; alone it does what it can (min_take)
    n = num(m.group(1))
    f = parse_filter(m.group(2), ctx)
    mk = lambda q: ('move', OWN, ('hand',), ('discard',), f, q)
    return Eff(min_take(('pile', OWN, ('hand',), f), n, mk, ctx))


@rule('hand-into-deck', r'Shuffle your hand into your deck\.', 'B', 'move own hand shuffle any all')
def _(m, ctx):
    return Eff(('move', OWN, ('hand',), ('shuffle',), ('any',), ('all',)))


@rule('each-hand-into-deck', r'Each player shuffles their hand into their deck\.', 'B',
      'move own hand shuffle any all; move opp hand shuffle any all')
def _(m, ctx):
    return Eff(seq(('move', OWN, ('hand',), ('shuffle',), ('any',), ('all',)),
                   ('move', OPP, ('hand',), ('shuffle',), ('any',), ('all',))))


@rule('discard-hand-draw', r'Discard your hand and draw (\d+) cards\.', 'B',
      'move own hand discard any all; move own (top n) hand any all')
def _(m, ctx):
    return Eff(seq(('move', OWN, ('hand',), ('discard',), ('any',), ('all',)), draw(OWN, num(m.group(1)))))


@rule('both-draw', r'Then, you draw (\d+) cards, and your opponent draws (\d+) cards\.', 'B',
      'move own (top n) hand any all; move opp (top m) hand any all')
def _(m, ctx):
    return Eff(seq(draw(OWN, num(m.group(1))), draw(OPP, num(m.group(2)))))


@rule('discard-cost', r'You can use this card only if you discard (another card|\d+ other cards) from your hand\.', 'T',
      'move own hand discard any (exactly n), first')
def _(m, ctx):
    n = 1 if m.group(1) == 'another card' else num(m.group(1).split()[0])
    return Cost(('move', OWN, ('hand',), ('discard',), ('any',), ('exactly', n)))


@rule('poison-strength', r'During Pokémon Checkup, put (\d+) damage counters on that Pokémon instead of 1\.', 'A',
      'poisonUp (n-1), after the Poison')
def _(m, ctx):
    n = num(m.group(1))
    return Eff(('poisonUp', n - 1), {'poisonStrength', '_needsPoison'})


# ------------------------------------------------------------------ Ability sentences (milestone M8a)
#
# Rules marked 'Ab' apply only in an Ability's effect. An Ability also uses the Trainer ('T') and
# shared ('B') rules: its effect resolves as a Trainer card's does (`TRun`, Pokemon/Rules.lean).

@rule('ab-inflict', r"Make your opponent's Active Pokémon (" + COND_RE + r')\.', 'Ab', 'inflict c')
def _(m, ctx):
    return Eff(('inflict', (CONDS[m.group(1)],)))


@rule('ab-each-draws', r'Have each player draw (a card|\d+ cards)\.', 'Ab',
      'move own (top n) hand any all; move opp (top n) hand any all')
def _(m, ctx):
    n = 1 if m.group(1) == 'a card' else num(m.group(1).split()[0])
    return Eff(seq(draw(OWN, n), draw(OPP, n)))


@rule('ab-opp-hand-into-deck-draw', r'Have your opponent shuffle their hand into their deck and draw (\d+) cards\.', 'Ab',
      'move opp hand shuffle any all; move opp (top n) hand any all')
def _(m, ctx):
    return Eff(seq(('move', OPP, ('hand',), ('shuffle',), ('any',), ('all',)), draw(OPP, num(m.group(1)))))


@rule('ab-may-hand-to-bottom', r'You may put a card from your hand on the bottom of your deck\.', 'Ab',
      'choice (move own hand bottom any (exactly 1)) skip')
def _(m, ctx):
    return Eff(choice(('move', OWN, ('hand',), ('bottom',), ('any',), ('exactly', 1)), SKIP))


@rule('ab-gust-confuse', r"Switch in 1 of your opponent's Benched Pokémon to the Active Spot, and the new Active Pokémon is now ("
      + COND_RE + r')\.', 'Ab',
      'ite (countGe (bench opp pokemon) 1) (seq (switch opp) (inflict c)) skip')
def _(m, ctx):
    return Eff(ite(('countGe', ('bench', OPP, ('pokemon',)), 1),
                   seq(('switch', OPP), ('inflict', (CONDS[m.group(1)],))), SKIP), noop(ctx))


@rule('ab-search-discard', r'Search your deck for (up to \d+|an?|\d+) (.+?) and discard (?:it|them)\.', 'Ab',
      'move own deck discard F (upTo n)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    if not upto:
        raise Refuse('exact search and discard')
    return Eff(('move', OWN, ('deck',), ('discard',), f, ('upTo', n)), search_cavs(f, upto, ctx))


@rule('ab-heal-self', r'Heal (\d+) damage from this Pokémon\.', 'Ab', 'self (heal n)')
def _(m, ctx):
    return AbItem(('self', ('heal', counters(m.group(1)))), noop(ctx))


@rule('ab-counters-self', r'(?:Put|Place) (\d+) damage counters? on this Pokémon\.', 'Ab', 'self (counters n)')
def _(m, ctx):
    return AbItem(('self', ('counters', num(m.group(1)))))


@rule('ab-switch-in-self', r'Switch (?:this Pokémon|it) with your Active Pokémon\.', 'Ab', 'self switchIn')
def _(m, ctx):
    if ctx.get('spot') != ('bench',):
        raise Refuse('switch this Pokémon in, not restricted to the Bench')
    return AbItem(('self', ('switchIn',)))


@rule('ab-energy-to-self', r'Move (an|a) (?:(Basic )?' + TYPE_RE + r' )?Energy from 1 of your other Pokémon to this Pokémon\.', 'Ab',
      'self (energyTo F)')
def _(m, ctx):
    return AbItem(('self', ('energyTo', energy_filter(m.group(2), m.group(3)))), {'moveAnyPair', 'noopUse'})


def energy_filter(basic, t):
    """The filter of "[Basic | Special] [T] Energy" (see ENERGY_F): `basic` is the qualifier as matched ('Basic',
    'Basic ', 'Special' or None)."""
    if t in ('Dragon', 'Colorless'):
        raise Refuse('Energy of a type with no Basic Energy')
    q = (basic or '').strip()
    if q == 'Special':
        if t:
            raise Refuse('Special Energy of a type')
        return SPECIAL_F
    if t:
        return ('energyOf', etype(t))
    return BASIC_F if q == 'Basic' else ENERGY_F


@rule('ab-move-energy', r'Move (an|a) (?:(Basic )?(?:' + TYPE_RE + r' )?)?Energy from 1 of your (Pokémon to another of your Pokémon|'
      r'Benched Pokémon to your Active Pokémon)\.', 'Ab', 'moveEnergy own F')
def _(m, ctx):
    cv = {'noopUse'}
    if m.group(4) != 'Pokémon to another of your Pokémon':
        cv.add('moveAnyPair')
    return Eff(('moveEnergy', OWN, energy_filter(m.group(2), m.group(3))), cv)


@rule('ab-attach-from-hand', r'Attach (up to \d+|an?|\d+) (.+?) from your hand to (this Pokémon|your Active Pokémon|'
      r'1 of your (?:(Benched) )?(?:(.+?) )?Pokémon)\.', 'Ab',
      'attach own hand F spot TF (n times); "this Pokémon": self (attach hand F)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    if not is_energy_filter(f):
        raise Refuse('attach a non-Energy card')
    cv = {'upTo0'} if upto else {'mayFail'}
    tgt = m.group(3)
    if tgt == 'this Pokémon':
        return AbItem(abseq(*[('self', ('attach', ('hand',), f))] * n), cv)
    if n > 1 and tgt != 'your Active Pokémon':
        raise Refuse('several cards to one chosen Pokémon')
    if tgt == 'your Active Pokémon':
        return Eff(seq(*[('attach', OWN, ('hand',), f, ('active',), ('any',))] * n), cv)
    tf = ('any',) if not m.group(5) else parse_filter(m.group(5) + ' Pokémon', ctx)
    if m.group(4):
        return Eff(('attach', OWN, ('hand',), f, ('bench',), tf), cv)
    return Eff(choice(('attach', OWN, ('hand',), f, ('active',), tf), ('attach', OWN, ('hand',), f, ('bench',), tf)), cv)


@rule('ab-bonus-self-turn', r"During this turn, attacks used by this Pokémon do (\d+) more damage to your opponent's Active Pokémon "
      r'\(before applying Weakness and Resistance\)\.', 'Ab', 'linger own now (bonus n)')
def _(m, ctx):
    return Eff(('linger', OWN, ('now',), ('bonus', counters(m.group(1)))), {'perPokemon'})


# ------------------------------------------------------------------ Stadiums and Tools (milestone M5)

@rule('discard-stadium', r'Discard a Stadium in play\.', 'B', 'discardStadium')
def _(m, ctx):
    # `Effect.discardStadium`: the Stadium in play, whoever's, to its owner's discard pile; nothing if
    # none is in play (an attack does what it can; a Trainer could then be played to no effect)
    return Eff(('discardStadium',), noop(ctx))


@rule('may-discard-stadium', r'You may discard a Stadium in play\.', 'B', 'choice discardStadium skip')
def _(m, ctx):
    return Eff(choice(('discardStadium',), SKIP))


@rule('pre-discard-tools-opp-active', r"Before doing damage, discard all Pokémon Tools from your opponent's Active Pokémon\.",
      'A', 'discardTools opp active, before the damage step')
def _(m, ctx):
    # `Effect.discardTools .opp .active`: every Tool of the opponent's Active Pokémon, to the
    # opponent's discard pile (the owner's); resolved before the damage step
    return Eff(('discardTools', OPP, ('active',)), pre=True)


@rule('pre-discard-tools-self', r"Before doing damage, discard all Pokémon Tools from this Pokémon\.", 'A',
      'discardTools own active, before the damage step')
def _(m, ctx):
    # importer 0.13.0 (Melmetal sv7-104): every Tool of the attacking Pokémon (the Active Pokémon in an attack, before
    # the damage step: no switch precedes it), to the player's discard pile; "If you can't discard any, this attack
    # does nothing" is the next sentence's `wrapIf` on `hasTool own`
    return Eff(('discardTools', OWN, ('active',)), pre=True)


@rule('pre-discard-tools-special-opp-active', r"Before doing damage, discard all Pokémon Tools and Special Energy from your "
      r"opponent's Active Pokémon\.", 'A', 'discardTools opp active; discardEnergy opp active specialEnergy all, before the damage step')
def _(m, ctx):
    # importer 0.11.0 (Mow Rotom sv7-8): every Tool and every Special Energy card of the opponent's Active Pokémon, to
    # the opponent's discard pile; `all` leaves no Special Energy card attached (`Qty.ok .all`), and none is a resolution
    return Eff(seq(('discardTools', OPP, ('active',)), ('discardEnergy', OPP, ('active',), SPECIAL_F, ('all',))), pre=True)


@rule('tool-and-special-1-opp', r"Discard a Pokémon Tool and a Special Energy from 1 of your opponent's Pokémon\.", 'B',
      'refused')
def _(m, ctx):
    # importer 0.11.0 (Ruffian sv9-157): on the Active Pokémon two primitives would be exact, but on the Bench
    # `discardTools .opp .bench` and `discardEnergy .opp .bench` each choose their own Benched Pokémon, so the term would
    # allow a Tool from one and a Special Energy from another (allows more), a departure no Known gaps entry names
    raise Refuse('Tool and Special Energy from the same Benched Pokémon (two primitives choose separately)', m.string)


@rule('hand-to-deck-top', r'Put a card from your hand on top of your deck\.', 'T', 'move own hand top any (exactly 1)')
def _(m, ctx):
    return Eff(('move', OWN, ('hand',), ('top',), ('any',), ('exactly', 1)))


# ------------------------------------------------------------------ importer 0.9.0 (survey S16): class-I rules
#
# Rules for refused sentences that the model already expresses (survey S16, class I), each read against the `Run` /
# `ZStep` rule of the primitives it writes (Pokemon/Effect.lean). Appended after the earlier rules, so a sentence an
# earlier rule matched keeps its translation; the two several-kind search rules are moved in front of the one-kind search
# rules (they match only sentences those refused). `parse_test_s16` and `parse_count_s16` are consulted first in
# `parse_test` and `parse_count`; they match no condition or count an earlier branch translated (checked: every term of
# importer 0.8.0 is reproduced unchanged).

def parse_test_s16(c, ctx):
    """Tests of importer 0.9.0; None if none applies."""
    # "X is on your Bench" (a Pokémon name): a Benched Pokémon whose card is named X (`Count.bench own (named X)`)
    m = re.match(r'^(\S+(?: ex)?) is on your Bench$', c)
    if m and KNOWN_NAMES.get(m.group(1)) == {'Pokémon'}:
        return [('countGe', ('bench', OWN, ('named', m.group(1))), 1)], False
    # milestone MV4 (importer 0.10.0): "a Pokémon that has \"Nidoking\" in its name is on your Bench", a Benched Pokémon
    # whose card passes a Pokémon filter (`Count.bench own f`, the filter read on the top card)
    m = re.match(r'^an? (.+?) is on your Bench$', c)
    if m and m.group(1) not in KNOWN_NAMES:
        f = parse_filter(m.group(1), ctx)
        if is_pokemon_filter(f):
            return [('countGe', ('bench', OWN, f), 1)], False
    # "X is in your discard pile" (a card name)
    m = re.match(r'^(.+?) is in your discard pile$', c)
    if m and m.group(1) in KNOWN_NAMES:
        return [('countGe', ('pile', OWN, ('discard',), parse_filter(m.group(1), ctx)), 1)], False
    # "there are N or fewer cards in your deck": not (deck ≥ N + 1)
    m = re.match(r'^there are (\d+) or fewer cards in your deck$', c)
    if m:
        return [('countGe', ('pile', OWN, ('deck',), ('any',)), num(m.group(1)) + 1)], True
    # the attacker's Special Conditions (`Test.cond .own`, the player's Active Pokémon, which is the attacker at the
    # damage step, `Attack.attacker_at_hit`)
    m = re.match(r'^this Pokémon is (Burned|Poisoned|Asleep|Confused|Paralyzed)(?: or (Burned|Poisoned))?$', c)
    if m:
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon outside an attack')
        return [('cond', OWN, (CONDS[x],)) for x in m.groups() if x], False
    m = re.match(r'^this Pokémon has (\d+) or more damage counters on it$', c)
    if m:
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon outside an attack')
        return [('atLeast', OWN, num(m.group(1)))], False
    m = re.match(r'^you have (\d+) or more Energy in play$', c)
    if m:
        return [('countGe', ('energyAll', OWN, ENERGY_F), num(m.group(1)))], False
    return None


def parse_count_s16(x, ctx):
    """Counts of importer 0.9.0; None if none applies."""
    m = re.match(r'^of your Benched (.+)$', x)
    if m:
        f = parse_filter(m.group(1), ctx)
        if is_pokemon_filter(f):
            return lambda k: ('count', ('bench', OWN, f), k)
    m = re.match(r'^(.+) on your Bench$', x)
    if m:
        f = parse_filter(m.group(1), ctx)
        if is_pokemon_filter(f):
            return lambda k: ('count', ('bench', OWN, f), k)
    # "each of your Drifloon and Drifblim in play": the Pokémon in play whose card has either name
    m = re.match(r'^of your (\S+(?: ex)?) and (\S+(?: ex)?) in play$', x)
    if m and all(KNOWN_NAMES.get(n) == {'Pokémon'} for n in m.groups()):
        f = ('or', ('named', m.group(1)), ('named', m.group(2)))
        return lambda k: ('count', ('inPlay', OWN, f), k)
    if x == 'Energy attached to both Active Pokémon':
        return lambda k: ('add', ('count', ('energy', OWN, ENERGY_F), k), ('count', ('energy', OPP, ENERGY_F), k))
    if x == 'Energy attached to all Pokémon':
        return lambda k: ('add', ('count', ('energyAll', OWN, ENERGY_F), k), ('count', ('energyAll', OPP, ENERGY_F), k))
    m = re.match(r'^' + TYPE_RE + r' Energy and each ' + TYPE_RE + r' Energy attached to all of your Pokémon$', x)
    if m:
        f = ('or', energy_filter(None, m.group(1)), energy_filter(None, m.group(2)))
        return lambda k: ('count', ('energyAll', OWN, f), k)
    return None


@rule('may-draw-to', r'You may draw cards until you have (\d+) cards in your hand\.', 'B', 'choice (drawTo own n) skip')
def _(m, ctx):
    # `drawTo own n` draws until the hand has n cards (none if it has n or more; fewer if the deck runs out); "you may"
    # is the choice with skip. In an Ability the skip branch is a use to no effect (noopUse)
    return Eff(choice(('drawTo', OWN, num(m.group(1))), SKIP), noop(ctx) if ctx['kind'] == 'ability' else set())


ATT2 = (r"(this Pokémon|1 of your Pokémon|1 of your Benched Pokémon|1 of your (Benched )?(\w+) Pokémon|"
        r"your (?:(\w+) )?Pokémon in any way you like)")


@rule('attach-2', r'Attach (up to \d+|an?|\d+) (.+?) from your (hand|discard pile) to ' + ATT2 + r'\.', 'B',
      'attach own (hand|discard) F spot TF (n times; a target of a type: TF = ptype)')
def _(m, ctx):
    # importer 0.9.0: attachments from the hand in attacks and Trainers, and targets with a type ("1 of your Dragon
    # Pokémon", "your Metal Pokémon in any way you like"): `attach own src f sp tf` attaches one Energy card passing f
    # to a Pokémon at sp whose card passes tf (`ZStep.attachActive`, `attachBench`), or nothing (`attachNone`)
    if ctx['kind'] == 'ability':
        raise Refuse('unhandled sentence', m.string)
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    if not is_energy_filter(f):
        raise Refuse('attach a non-Energy card')
    src = ('hand',) if m.group(3) == 'hand' else ('discard',)
    tgt = m.group(4)
    if tgt == 'this Pokémon':
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon outside an attack')
        one = ('attach', OWN, src, f, ('active',), ('any',))
    elif tgt.startswith('1 of your'):
        if n > 1:
            raise Refuse('several cards to one chosen Pokémon')
        tf = parse_filter(m.group(6) + ' Pokémon', ctx) if m.group(6) else ('any',)
        if not (tf == ('any',) or is_pokemon_filter(tf)):
            raise Refuse('card kind with no filter: ' + tgt)
        if m.group(5) or tgt == '1 of your Benched Pokémon':
            one = ('attach', OWN, src, f, ('bench',), tf)
        else:
            one = choice(('attach', OWN, src, f, ('active',), tf), ('attach', OWN, src, f, ('bench',), tf))
    else:
        tf = parse_filter(m.group(7) + ' Pokémon', ctx) if m.group(7) else ('any',)
        if not (tf == ('any',) or is_pokemon_filter(tf)):
            raise Refuse('card kind with no filter: ' + tgt)
        one = choice(('attach', OWN, src, f, ('active',), tf), ('attach', OWN, src, f, ('bench',), tf))
    cv = set()
    if not upto:
        cv.add('mayFail')
    elif ctx['kind'] != 'attack':
        cv.add('upTo0')
    return Eff(seq(*[one] * n), cv)


@rule('search-attach-typed', r'Search your deck for (an?) (.+?) and attach it to 1 of your (Benched )?(\w+) Pokémon\.', 'B',
      'attach own deck F spot (ptype t)')
def _(m, ctx):
    f = parse_filter(m.group(2), ctx)
    if not is_energy_filter(f):
        raise Refuse('attach a non-Energy card')
    tf = parse_filter(m.group(4) + ' Pokémon', ctx)
    if not is_pokemon_filter(tf):
        raise Refuse('card kind with no filter: ' + m.group(4) + ' Pokémon')
    b = ('attach', OWN, ('deck',), f, ('bench',), tf)
    return Eff(b if m.group(3) else choice(('attach', OWN, ('deck',), f, ('active',), tf), b))


@rule('move-energy-self-bench', r'Move (?:an|a) (Basic )?(?:' + TYPE_RE + r' )?Energy from this Pokémon to 1 of your Benched Pokémon\.',
      'A', 'moveEnergy own F')
def _(m, ctx):
    # `moveEnergy own f` moves one Energy passing f between any two of the player's Pokémon, or none (`ZStep.moveAB`,
    # `moveBA`, `moveBB`, `moveNone`): the printed move from the attacker to a Benched Pokémon is one of them
    return Eff(('moveEnergy', OWN, energy_filter(m.group(1), m.group(2))), {'moveAnyPair', 'moveMayFail'})


@rule('move-energy-opp', r"(You may move|Move) an Energy from (your opponent's Active Pokémon to 1 of their Benched Pokémon|"
      r"1 of your opponent's Pokémon to another of their Pokémon)\.", 'A', 'moveEnergy opp energy (or choice with skip)')
def _(m, ctx):
    e = ('moveEnergy', OPP, ENERGY_F)
    if m.group(1) == 'You may move':
        # optional, so the move of nothing is the printed "may not"; the pair is any (moveAnyPair)
        return Eff(choice(e, SKIP), {'moveAnyPair'} if m.group(2).startswith("your opponent's Active") else set())
    return Eff(e, {'moveMayFail'} | ({'moveAnyPair'} if m.group(2).startswith("your opponent's Active") else set()))


@rule('move-energy-own-trainer', r'Move (?:an|a) (Basic )?(?:' + TYPE_RE + r' )?Energy from 1 of your Pokémon to another of your Pokémon\.',
      'T', 'moveEnergy own F')
def _(m, ctx):
    return Eff(('moveEnergy', OWN, energy_filter(m.group(1), m.group(2))), {'moveMayFail'})


@rule('hand-deck-draw', r"(Each player|Your opponent) shuffles their hand into their deck and draws (\d+) cards\.", 'B',
      'move w hand shuffle any all; move w (top n) hand any all (each side)')
def _(m, ctx):
    n = num(m.group(2))
    sides = [OWN, OPP] if m.group(1) == 'Each player' else [OPP]
    return Eff(seq(*[x for w in sides for x in (('move', w, ('hand',), ('shuffle',), ('any',), ('all',)), draw(w, n))]))


@rule('play-condition-opp-prizes', r'You can use this card only if your opponent has (\d+) or fewer Prize cards remaining\.', 'T',
      'ite (countGe (prizes opp) (n+1)) (no resolution) skip, first')
def _(m, ctx):
    if ctx['kind'] != 'trainer':
        raise Refuse('wording')
    return Cost(ite(('countGe', ('prizes', OPP), num(m.group(1)) + 1), NO_PLAY, SKIP))


@rule('search-top-in-order', r'Search your deck for (\d+) cards, shuffle your deck, then put those cards on top of it in any order\.',
      'B', 'shuffle; move own deck top any (exactly n, or as many as there are; at least 1 in a Trainer)')
def _(m, ctx):
    # the shuffle is written first: shuffling the whole deck and then taking n cards to the top (in any order,
    # `Put.top`) leaves the rest in any order, the same set of decks as taking n first and shuffling the rest
    n = num(m.group(1))
    mk = lambda q: ('move', OWN, ('deck',), ('top',), ('any',), q)  # noqa: E731
    return Eff(seq(('shuffle',), min_take(('pile', OWN, ('deck',), ('any',)), n, mk, ctx)))


@rule('discard-energy-1-opp', r"Discard an? (Special )?Energy from 1 of your opponent's Pokémon\.", 'B',
      'ite (countGe (energyAll opp energy) 1) (choice (discardEnergy opp active energy (exactly 1)) '
      '(ite (countGe (bench opp pokemon) 1) (discardEnergy opp bench energy (exactly 1)) none)) (skip | none)')
def _(m, ctx):
    # one Energy from one of the opponent's Pokémon that has one: `exactly 1` has a resolution only on a Pokémon with
    # an Energy (`ZStep.discardActive`, `discardBench`), and the Bench branch is guarded so that `discardNone` (empty
    # Bench) is not a do-nothing resolution. With no Energy in play on that side: nothing in an attack, no resolution
    # in a Trainer (min_take's convention). Importer 0.11.0: "a Special Energy" is the same with `specialEnergy`
    # (Enhanced Hammer sv6-148)
    F = SPECIAL_F if m.group(1) else ENERGY_F
    e = choice(('discardEnergy', OPP, ('active',), F, ('exactly', 1)),
               ite(('countGe', ('bench', OPP, ('pokemon',)), 1),
                   ('discardEnergy', OPP, ('bench',), F, ('exactly', 1)), NO_PLAY))
    if ctx['kind'] == 'ability':
        ctx['_cavs'].add('noopUse')
    ctx['_s16coin'] = True
    return Eff(ite(('countGe', ('energyAll', OPP, F), 1), e, NO_PLAY if ctx['kind'] == 'trainer' else SKIP))


@rule('bench-any-number-basic', r'Search your deck for any number of Basic Pokémon and put them onto your Bench\.', 'B',
      'putBench own deck basic (5 times)')
def _(m, ctx):
    # "any number" allows 0 (2026 p. 21); five `putBench` steps, each of which may put nothing, cover every number the
    # Bench can take (benchLimit = 5)
    return Eff(seq(*[('putBench', OWN, ('deck',), ('basic',))] * 5))


@rule('search-discard-trainer', r'Search your deck for (up to \d+) cards and discard them\.', 'T', 'move own deck discard any (upTo n)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    return Eff(('move', OWN, ('deck',), ('discard',), ('any',), ('upTo', n)), search_cavs(('any',), upto, ctx))


@rule('damage-each-opp-kind', r"This attack does (\d+) damage to each of your opponent's Pokémon ex(?: and Pokémon V)?\.", 'A',
      "ite (top opp ex) (damage n) skip; benchSome opp 5 ex true n")
def _(m, ctx):
    return Dmg('eachF', counters(m.group(1)), ('ex',), cavs={'benchMods'})


@rule('inflict-and-discard-opp', r"Your opponent's Active Pokémon is now (" + COND_RE + r"), and discard an Energy from that Pokémon\.",
      'A', 'inflict c; ite (countGe (energy opp energy) 1) (discardEnergy opp active energy (exactly 1)) skip')
def _(m, ctx):
    return Eff(seq(('inflict', (CONDS[m.group(1)],)),
                   ite(('countGe', ('energy', OPP, ENERGY_F), 1), ('discardEnergy', OPP, ('active',), ENERGY_F, ('exactly', 1)), SKIP)))


@rule('both-draw-2', r'You draw (\d+) cards, and your opponent draws (\d+) cards\.', 'B',
      'move own (top n) hand any all; move opp (top m) hand any all')
def _(m, ctx):
    return Eff(seq(draw(OWN, num(m.group(1))), draw(OPP, num(m.group(2)))))


@rule('inflict-lc', r"Your opponent's Active Pokémon is now (asleep|burned|confused|paralyzed|poisoned)\.", 'B', 'inflict c')
def _(m, ctx):
    # a lower-case condition word (a misprint in the data, Azumarill me55-68)
    return Eff(('inflict', (CONDS[m.group(1).capitalize()],)))


@rule('mill-each', r"Discard the top card of each player's deck\.", 'B', 'move own (top 1) discard any all; move opp (top 1) discard any all')
def _(m, ctx):
    return Eff(seq(('move', OWN, ('top', 1), ('discard',), ('any',), ('all',)),
                   ('move', OPP, ('top', 1), ('discard',), ('any',), ('all',))))


# importer 0.21.0 (milestone MV14, survey S28): a lingering threshold, "During your opponent's next turn, prevent all
# damage done to this Pokémon by attacks if that damage is N or less" (Metapod sv9-2, Roggenrola rsv10pt5-46):
# `Mod.preventLe (N/10)`, stored for the player (`Mods.upto`, the largest in effect) and read at step 5 of the damage
# calculation (`dealtBy`). Per player as every lingering modifier (perPokemon); "that damage" read after every other
# step-5 effect (thresholdRead).
@rule('ling-prevent-self-le', r"During your opponent's next turn, prevent all damage done to this Pokémon by attacks if "
      r"that damage is (\d+) or less\.", 'A', 'linger own next (preventLe n)')
def _(m, ctx):
    return Eff(('linger', OWN, ('next',), ('preventLe', counters(m.group(1)))), {'perPokemon', 'thresholdRead'})


@rule('ling-prevent-self-2', r"During your opponent's next turn, prevent all damage from attacks done to this Pokémon\.", 'A',
      'linger own next prevent')
def _(m, ctx):
    return Eff(('linger', OWN, ('next',), ('prevent',)), {'perPokemon'})


@rule('poison-strength-2', r'During Pokémon Checkup, place (\d+) damage counters on that Pokémon instead of 1\.', 'A',
      'poisonUp (n-1), after the Poison')
def _(m, ctx):
    return Eff(('poisonUp', num(m.group(1)) - 1), {'poisonStrength', '_needsPoison'})


@rule('heal-self-noperiod', r'Heal (\d+) damage from this Pokémon', 'A', 'heal n (a sentence with no final period in the data)')
def _(m, ctx):
    return Eff(('heal', counters(m.group(1))))


@rule('may-recoil-inflict', r"You may have this Pokémon also do (\d+) damage to itself and make your opponent's Active Pokémon ("
      + COND_RE + r')\.', 'A', 'choice (selfDamage n; inflict c) skip')
def _(m, ctx):
    return Eff(choice(seq(('selfDamage', counters(m.group(1))), ('inflict', (CONDS[m.group(2)],))), SKIP), {'recoil'})


# searches for several kinds in one sentence (before search-to-hand, whose filter refuses the list)
def _kinds(lst, ctx):
    items = [x.strip() for x in re.split(r',? and |, ', lst)]
    if len(items) < 2 or not all(re.match(r'^an? ', x) for x in items):
        return None
    return [parse_filter(x, ctx) for x in items]


@rule('search-several', r'Search your deck for (an? [^,]+?(?:, an? [^,]+?)*,? and an? [^,]+?), reveal them, and put them into your hand\.', 'B',
      'move own deck hand F1 (upTo 1); move own deck hand F2 (upTo 1); …')
def _(m, ctx):
    # "a Basic Pokémon, a Stage 1 Pokémon, and a Stage 2 Pokémon": one search of up to 1 card for each kind, as the
    # one-kind rule writes "a F" (`upTo 1`: a search may find nothing; hidden information, Known gaps)
    fs = _kinds(m.group(1), ctx)
    if fs is None:
        raise Refuse('unhandled sentence', m.string)
    cv = set()
    for f in fs:
        cv |= search_cavs(f, False, ctx)
    return Eff(seq(*[('move', OWN, ('deck',), ('hand',), f, ('upTo', 1)) for f in fs]), cv)


@rule('discard-hand-search-several', r'Discard your hand and search your deck for (an? [^,]+?(?:, an? [^,]+?)*,? and an? [^,]+?), reveal them, and put them into your hand\.',
      'B', 'move own hand discard any all; move own deck hand F1 (upTo 1); …')
def _(m, ctx):
    fs = _kinds(m.group(1), ctx)
    if fs is None:
        raise Refuse('unhandled sentence', m.string)
    return Eff(seq(('move', OWN, ('hand',), ('discard',), ('any',), ('all',)),
                   *[('move', OWN, ('deck',), ('hand',), f, ('upTo', 1)) for f in fs]))


@rule('search-either', r'Search your deck for up to (\d+) (.+?) or (\d+) (.+?), reveal them, and put them into your hand\.', 'B',
      'choice (move own deck hand F1 (upTo n)) (move own deck hand F2 (upTo m))')
def _(m, ctx):
    f1, f2 = parse_filter(m.group(2), ctx), parse_filter(m.group(4), ctx)
    cv = {'upTo0'} if ctx['kind'] != 'attack' else set()
    return Eff(choice(('move', OWN, ('deck',), ('hand',), f1, ('upTo', num(m.group(1)))),
                      ('move', OWN, ('deck',), ('hand',), f2, ('upTo', num(m.group(3))))), cv)


def _before(names, anchor):
    """Move the rules `names` in front of the rule `anchor` (they match only sentences that rule refuses)."""
    moved = [r for r in RULES if r[0] in names]
    rest = [r for r in RULES if r[0] not in names]
    k = next(i for i, r in enumerate(rest) if r[0] == anchor)
    RULES[:] = rest[:k] + moved + rest[k:]


_before(('search-several', 'search-either'), 'may-search-to-hand')


# ------------------------------------------------------------------ the parser

def split_sentences(t):
    t = (t or '').replace('’', "'").replace('‘', "'")
    # importer 0.13.0: a misprint in the data ("your oppoennt's Active Pokémon", Palkia me55-20)
    t = t.replace("your oppoennt's", "your opponent's")
    out = []
    for line in re.split(r'\n+', t):
        for s in re.split(r"(?<=[.!?])[\"')]*\s+(?=[A-Z(\[•])", line):
            s = s.strip()
            if s:
                out.append(s)
    # glue parenthetical reminders that belong to the sentence before
    glued = []
    for s in out:
        if s == '(Your opponent chooses the new Active Pokémon.)' and glued:
            glued[-1] = glued[-1] + ' ' + s
        else:
            glued.append(s)
    return glued


REMINDERS = {
    "(Don't apply Weakness and Resistance for Benched Pokémon.)",
    # importer 0.9.0: the same reminder as `split_sentences` leaves it after "…, and" text (the closing parenthesis is
    # taken with the sentence end), and the Rule Box reminder after "Pokémon that don't have a Rule Box"
    "(Don't apply Weakness and Resistance for Benched Pokémon.",
    "(Pokémon ex, Pokémon V, etc. have Rule Boxes.)",
    # a clarification of "your Pokémon" in a player-wide effect; the model's modifiers belong to the player
    "(This includes new Pokémon that come into play.)",
}


def normal(s, name=None):
    """The template of a sentence: own name -> SELF, numbers -> N, type words -> TYPE."""
    s = s.replace('’', "'")
    if name:
        s = s.replace(name, 'SELF')
    s = re.sub(r'\d+', 'N', s)
    s = re.sub(r'\b(Grass|Fire|Water|Lightning|Psychic|Fighting|Darkness|Metal|Fairy|Dragon|Colorless)\b', 'TYPE', s)
    return s


def match_rule(s, ctx):
    """(rule name, item) for the first rule matching the sentence, or raise Refuse."""
    kinds = {'attack': ('A', 'B'), 'trainer': ('T', 'B'), 'ability': ('T', 'B', 'Ab')}[ctx['kind']]
    for name, rx, where, _, fn in RULES:
        if where not in kinds:
            continue
        m = rx.match(s)
        if m:
            return name, fn(m, ctx)
    raise Refuse('unhandled sentence', s)


def searches_deck(e):
    """The effect takes cards from the deck (a search, a Bench placement or an attachment)."""
    if e[0] == 'move' and e[2] == ('deck',):
        return True
    if e[0] in ('putBench', 'attach') and e[2] == ('deck',):
        return True
    return any(searches_deck(x) for x in T.subs(e))


# milestone MV2: the shapes of the three families (survey S13) that the model's Known gaps list as not modelled
# (Pokemon/Rules.lean, items "one-turn history", "effects read only the two Active Pokémon" and "effects place
# damage counters"), refused with a reason that names the gap instead of the generic one.
GAP_PREFIX = 'not modelled (Known gaps, MV2): '
GAP_SHAPES = [
    ('history: the Supporter played this turn', r"(?:If|if) you (?:played|didn't play) .+ from your hand during this turn"),
    ('history: an attack used last turn', r"used (?:.+|an attack) during your last turn"),
    ('history: healed this turn', r"was healed during this turn"),
    ('history: counted (damage or Prize cards of last turn)',
     r"that much more damage|Prize cards? your opponent took during their last turn"),
    ('history: next-turn trigger on this Pokémon', r"During your opponent's next turn, if this Pokémon is damaged"),
    ('spread: amount computed by the text', r"damage (?:counters )?(?:to|on) \d+ of your opponent's (?:Benched )?Pokémon for each|"
                                            r"for each damage counter on that Pokémon"),
    ('spread: target filtered by its damage', r"Benched Pokémon that has any damage counters on it"),
]
GAP_OVERRIDABLE = ('unhandled sentence', 'condition not expressible', 'count not expressible', 'card kind with no filter',
                   'history: ')


def gap_reason(sent):
    for name, rx in GAP_SHAPES:
        if re.search(rx, sent):
            return GAP_PREFIX + name
    return None



# ------------------------------------------------------------------ "if you do" and "in this way" (milestone MV3, stage 2)
#
# `Effect.ifDone t a b = ite t (seq a b) skip` (Pokemon/IfDo.lean, `Run.ifDone_iff`) is exact only when the test `t`
# holds exactly when the action `a` can be done, and `a` then has no resolution that does nothing. The importer
# writes it only over the actions below, each read against its `Run` / `ZStep` rule (Pokemon/Effect.lean):
#
#   action (printed)                                   a                                       t
#   "Discard a card [a F] from your hand." (attack)    move own hand discard F (exactly 1)     countGe (pile own hand F) 1
#   "Draw N cards."                                    move own (top N) hand any all           countGe (pile own deck any) 1
#   "Switch this Pokémon / your Active Pokémon with    switch own                              countGe (bench own pokemon) 1
#    1 of your Benched Pokémon."
#   "Switch in 1 of your opponent's Benched Pokémon    switch opp                              countGe (bench opp pokemon) 1
#    to the Active Spot."
#
# * `move … (exactly k)` (`ZStep.move`): a resolution is a `Split f l t r` with `t.length = k`, and a `Split` takes
#   only cards passing `f` (`Split.take`), so there is one exactly when at least k cards of the source pass `f`, the
#   value of `Count.pile own hand f` (`Count.val`, `countP`); every resolution moves k ≥ 1 cards. No other `Run` rule
#   applies to `move` (`Effect.touch` is `none` on it; `Run.zone` is its only rule).
# * `move … (top N) … all` (draw): `Qty.all` takes every card of the top N that passes `any`, so the one resolution
#   draws min(N, deck) cards: at least one exactly when the deck has a card.
# * `switch w` (`Run.switch`, `Run.switchNone`): a switch needs a Benched Pokémon (`bench = b₁ ++ q :: b₂`), and the
#   do-nothing resolution `switchNone` exists only when the Bench is empty; `Count.bench w pokemon` counts the
#   Benched Pokémon (every top card is a Pokémon card), so the test is "the Bench is not empty".
#
# Never written over `attach`, `putBench`, `moveEnergy` or `discardEnergy … bench`, which have a do-nothing rule
# (`attachNone`, `putBenchNone`, `moveNone`, `discardNone`) in every state: such cards stay refused ("If you
# attached / put onto your Bench in this way"). `Effect.mayDo` is not used: the printed "You may A. If you do, B"
# shapes of the pool have an A that is a damage choice or an action outside the list. The test is read in the state
# before `a`, as `ite` does; in an attack and in a Trainer the player has an Active Pokémon then (`Run.ite`).

def done_action(e):
    """(test, action) for an item that is exactly an action of the table above, or None. Accepts the attack form
    of a one-card discard (`min_take`: `ite (countGe c 1) (move … (exactly 1)) skip`)."""
    if e[0] == 'ite' and e[3] == SKIP and e[1][0] == 'countGe' and e[1][2] == 1:
        a = e[2]
        if (a[0] == 'move' and a[1] == OWN and a[2] in (('hand',), ('discard',)) and a[5] == ('exactly', 1)
                and e[1][1] == ('pile', OWN, a[2], a[4])):
            return e[1], a
        return None
    if e[0] == 'move' and e[1] == OWN and e[2][0] == 'top' and e[3:] == (('hand',), ('any',), ('all',)):
        return ('countGe', ('pile', OWN, ('deck',), ('any',)), 1), e
    if e[0] == 'switch':
        return ('countGe', ('bench', e[1], ('pokemon',)), 1), e
    return None


def cost_action(e):
    """(test, action, k) for a printed cost "Discard k F from your hand / from this Pokémon" in its attack form
    (`min_take`: `ite (countGe c k) (A (exactly k)) fallback`), A a move from the hand or discard pile or an Energy
    discard from the player's Active Pokémon; None otherwise. `A (exactly k)` has a resolution exactly when at least
    k cards of its source pass its filter (`ZStep.move`, `ZStep.discardActive`: a `Split` taking k cards, each
    passing the filter; for the Active Pokémon the source is `a.energy`, counted by `Count.energy own f`), and none
    that does nothing (k ≥ 1)."""
    if e[0] != 'ite' or e[1][0] != 'countGe':
        return None
    cnt, k = e[1][1], e[1][2]
    a = e[2]
    if k < 1:
        return None
    if (a[0] == 'move' and a[1] == OWN and a[2] in (('hand',), ('discard',)) and a[5] == ('exactly', k)
            and cnt == ('pile', OWN, a[2], a[4])):
        return e[1], a, k
    if (a[0] == 'discardEnergy' and a[1] == OWN and a[2] == ('active',) and a[4] == ('exactly', k)
            and cnt == ('energy', OWN, a[3])):
        return e[1], a, k
    return None


# The most cards one player can discard in a legal game: a deck has 60 cards (2026 rulebook p. 21), and the
# Energy attached to a player's Pokémon and the cards in their hand are that player's own cards.
ANY_BOUND = 60

FU_RE = re.compile(r"^(?:You may discard|Discard) (up to (\d+)|any amount of|any number of) (.+?) from (this Pokémon|your hand), "
                   r"and this attack does (\d+) (more )?damage for each (?:card|Energy card|Energy) (?:you )?discarded in this way\.$")


def fu_source(np, src, ctx):
    """The discard of exactly i cards of the printed kind, as a function of i, from "this Pokémon" (its attached
    Energy) or "your hand"."""
    if src == 'this Pokémon':
        mm = re.match(r'^(?:(Basic) )?(?:' + TYPE_RE + r' )?Energy(?: cards?)?$', np)
        if not mm:
            raise Refuse('card kind with no filter: ' + np)
        f = energy_filter(mm.group(1), mm.group(2))
        return lambda i: ('discardEnergy', OWN, ('active',), f, ('exactly', i))
    f = parse_filter(np, ctx)
    return lambda i: ('move', OWN, ('hand',), ('discard',), f, ('exactly', i))


class Parser:
    """Walks the sentences of one text (an attack's or a Trainer's), collecting items, and refusals
    for the sentences it cannot translate."""

    def __init__(self, ctx):
        self.ctx = ctx
        self.items = []        # (index, item)
        self.blockers = []     # (reason, sentence)
        self.used = []         # (rule name, sentence)

    def one(self, s):
        """Translate one sentence (or a clause rephrased as one)."""
        name, it = match_rule(s, self.ctx)
        self.used.append((name, s))
        return it

    def run(self, sents):
        # importer 0.9.0: "Then, flip a coin." (Drasna, Harlequin) is the flip of "Flip a coin.", in printed order
        sents = ['Flip a coin.' if x == 'Then, flip a coin.' else x for x in sents]
        # "If your opponent's Active Pokémon is a Dragon Pokémon, it is now Paralyzed." (Black Kyurem ex): "it" is the
        # opponent's Active Pokémon of the condition
        sents = [re.sub(r"^If (your opponent's Active Pokémon [^,]+), it is now (" + COND_RE + r")\.$",
                        r"If \1, your opponent's Active Pokémon is now \2.", x) for x in sents]
        # importer 0.14.0: "If your opponent's Active Pokémon …, it / that Pokémon is Knocked Out." (Haxorus, Mega Absol
        # ex): the pronoun is the opponent's Active Pokémon of the condition
        sents = [re.sub(r"^If (your opponent's Active Pokémon [^,]+), (?:it|that Pokémon) is Knocked Out\.$",
                        r"If \1, your opponent's Active Pokémon is Knocked Out.", x) for x in sents]
        # importer 0.14.0 (Hydrapple sv10-18): "Discard N F from your hand, and Knock Out your opponent's Active Pokémon.
        # If you can't discard N cards in this way, this attack does nothing." is the cost, its "If you can't", then the
        # Knock Out: `ite (countGe (pile own hand F) N) (seq (discard exactly N) (counters 9999)) skip`, as printed (both
        # halves happen together, or nothing does)
        for k in range(len(sents) - 1):
            m = re.match(r"^(Discard (\d+) .+? from your hand), and (Knock Out your opponent's Active Pokémon)\.$", sents[k])
            if m and sents[k + 1] == "If you can't discard %s cards in this way, this attack does nothing." % m.group(2):
                sents = sents[:k] + [m.group(1) + '.', sents[k + 1], m.group(3) + '.'] + sents[k + 2:]
                break
        i = 0
        n = len(sents)
        while i < n:
            s = sents[i]
            try:
                i = self.step(sents, i)
            except Refuse as r:
                j = self.span(sents, i)
                sent = r.sentence or ' '.join(sents[i:j])
                why = r.reason
                g = gap_reason(sent)
                if g and why.startswith(GAP_OVERRIDABLE):
                    why = g
                self.blockers.append((why, sent))
                i = j
        return self

    @staticmethod
    def span(S, i):
        """The sentences a construct starting at `i` covers: a coin flip and its 'If heads' /
        'If tails' sentences, 'Flip N coins' or 'until you get tails' and the next sentence."""
        s = S[i]
        j = i + 1
        if s == 'Flip a coin.' or re.match(r'^Flip (\d+|two|three|four) coins\.$', s) or \
                s == 'Flip a coin until you get tails.':
            while j < len(S) and (S[j].startswith('If heads') or S[j].startswith('If tails')
                                  or S[j].startswith('If both') or S[j].startswith('If either')
                                  or S[j].startswith('For each heads') or 'for each heads' in S[j]
                                  or S[j].startswith('If all of them')):
                j += 1
        return j

    def step(self, S, i):
        s = S[i]
        ctx = self.ctx
        if s in REMINDERS:
            self.used.append(('reminder', s))
            return i + 1
        nxt = S[i + 1] if i + 1 < len(S) else ''
        if ctx['kind'] == 'ability':
            j = self.ability_step(S, i, nxt)
            if j is not None:
                return j
        j = mv6_step(self, S, i, nxt)
        if j is not None:
            return j
        if ctx['kind'] in ('attack', 'trainer'):
            j = self.mv3_step(S, i, nxt)
            if j is not None:
                return j
        j = self.s16_step(S, i, nxt)
        if j is not None:
            return j
        # one coin: "Flip a coin. If heads, X. [If tails, Y.]"
        if s == 'Flip a coin.':
            heads = tails = None
            j = i + 1
            if j < len(S) and S[j].startswith('If heads, '):
                heads = S[j][len('If heads, '):]
                j += 1
            if j < len(S) and S[j].startswith('If tails, '):
                tails = S[j][len('If tails, '):]
                j += 1
            # importer 0.17.0: the two branches in the other order ("If tails, this attack does nothing. If heads, X.",
            # Tranquill zsv10pt5-72, Trumbeak me5-67); the branches exclude each other, so the order is immaterial
            if heads is None and tails is not None and j < len(S) and S[j].startswith('If heads, '):
                heads = S[j][len('If heads, '):]
                j += 1
            if heads is None and tails is None:
                raise Refuse('coin flip with no consequence', s + ' ' + nxt)
            self.used.append(('flip-a-coin', s))
            H = self.clause(heads) if heads else None
            Tl = self.clause(tails) if tails else None
            # "If heads, search your deck ... Then, shuffle your deck.": the shuffle belongs to the
            # heads branch (on tails the deck is left alone)
            if (isinstance(H, Eff) and Tl is None and j < len(S) and S[j] == 'Then, shuffle your deck.'
                    and searches_deck(H.e)):
                self.used.append(('shuffle', S[j]))
                H = Eff(seq(H.e, ('shuffle',)), H.cavs)
                j += 1
            self.flip(H, Tl, i)
            return j
        m = re.match(r'^Flip (\d+|two|three|four) coins\.$', s)
        if m:
            k = num(m.group(1))
            m2 = re.match(r'^This attack does (\d+) (more )?damage for each heads\.$', nxt)
            m3 = re.match(r'^For each heads, (.+)$', nxt)
            if m2 and ctx['kind'] == 'attack':
                self.used.append(('flip-n-coins-damage', s + ' ' + nxt))
                self.items.append((i, Dmg('coins', k, counters(m2.group(1)), bool(m2.group(2)))))
                return i + 2
            if m3:
                X = self.clause(m3.group(1))
                if not isinstance(X, Eff) or not T.hit_free(X.e):
                    raise Refuse('coin-count effect not expressible', nxt)
                self.used.append(('flip-n-coins-each', s + ' ' + nxt))
                j = i + 2
                tail = []
                if j < len(S) and S[j] == 'Then, shuffle your deck.' and searches_deck(X.e):
                    # the shuffle follows the searches; with no heads there was no search
                    self.used.append(('shuffle', S[j]))
                    tail = [('shuffle',)]
                    j += 1
                alts = [SKIP] + [seq(*([X.e] * h + tail)) for h in range(1, k + 1)]
                e = alts[-1]
                for a in reversed(alts[:-1]):
                    e = choice(a, e)
                self.items.append((i, Eff(e, X.cavs)))
                return j
            raise Refuse('coin flips not expressible', s + ' ' + nxt)
        if s == 'Flip a coin until you get tails.':
            m2 = re.match(r'^This attack does (\d+) (more )?damage for each heads\.$', nxt)
            if m2 and ctx['kind'] == 'attack':
                self.used.append(('flip-until-tails-damage', s + ' ' + nxt))
                self.items.append((i, Dmg('many', counters(m2.group(1)), bool(m2.group(2)))))
                return i + 2
            raise Refuse('flip until tails not expressible', s + ' ' + nxt)
        # milestone MV2: a Trainer's play condition on the Knock Out history. The card cannot be played when the test
        # fails: the else branch takes exactly 1 card from the top 0 cards of the deck, a move with no resolution
        # (`ZStep.move` needs `Split` of [] to take one card), and `Move.item` / `Move.supporter` need a resolution
        m = re.match(r"^You can use this card only if (any of your Pokémon were Knocked Out during your opponent's last turn)\.$", s)
        if m and ctx['kind'] == 'trainer':
            ctx.pop('_tc', None)
            tests, neg = parse_test(m.group(1), ctx)
            assert not neg and len(tests) == 1
            self.used.append(('play-condition-history', s))
            self.items.append((i, Cost(ite(tests[0], SKIP, NO_PLAY), ctx.pop('_tc', set()))))
            return i + 1
        # importer 0.13.0 (Lacey sv7-139, Lillie's Determination me1-119, Team Rocket's Ariana sv10-171): "If C, draw N
        # cards instead." / "If C, draw cards until you have N cards in your hand instead.", after a draw of the same
        # kind in the sentence before: `ite C (new draw) (the earlier draw)`
        m = re.match(r'^If (.+?), (draw (\d+) cards|draw cards until you have (\d+) cards in your hand) instead\.$', s)
        if m:
            prev = self.prev_item(i, "'instead'")
            if m.group(3) and not (prev.e[0] == 'move' and prev.e[1:2] == (OWN,) and prev.e[2][0] == 'top'
                                   and prev.e[3:] == (('hand',), ('any',), ('all',))):
                raise Refuse("'draw N cards instead' after a sentence that is not a draw", s)
            if m.group(4) and not (prev.e[0] == 'drawTo' and prev.e[1] == OWN):
                raise Refuse("'draw cards until … instead' after a sentence that is not such a draw", s)
            ctx.pop('_tc', None)
            tests, neg = parse_test(m.group(1), ctx)
            tc = ctx.pop('_tc', set())
            new_draw = draw(OWN, num(m.group(3))) if m.group(3) else ('drawTo', OWN, num(m.group(4)))
            self.used.append(('if-condition-draw-instead', s))
            self.items[-1] = (self.items[-1][0], Eff(branch(tests, neg, new_draw, prev.e), prev.cavs | tc))
            return i + 1
        # a condition: "If C, X."
        m = re.match(r'^If (.+?), (this attack does .+|.+)$', s)
        if m and not s.startswith('If you do,') and not s.startswith("If you can't"):
            ctx.pop('_tc', None)
            tests, neg = parse_test(m.group(1), ctx)
            tc = ctx.pop('_tc', set())
            # milestone MV2: "If C, this attack does N more damage, and X." (Hearthflame Mask Ogerpon ex): the
            # conditional damage and the conditional effect X after it, both on the same test; the test reads
            # nothing the damage step changes (no Knock Out is taken inside an attack)
            m2 = re.match(r'^this attack does (\d+) more damage, and (.+)$', m.group(2))
            if m2 and ctx['kind'] == 'attack' and all(t[0] in ('top', 'hasTool', 'movedUp', 'evolved') or
                                                      (t[0] == 'countGe' and t[1][0] in ('koLast', 'inPlay'))
                                                      for t in tests):
                X = self.clause(m2.group(2))
                self.used.append(('if-condition-more-and', s))
                self.items.append((i, Dmg('cond', tests, neg, counters(m2.group(1)), reads=True, cavs=tc)))
                self.items.append((i, Eff(branch(tests, neg, X.e, SKIP), X.cavs)))
                return i + 1
            X = self.clause(m.group(2))
            self.used.append(('if-condition', s))
            if isinstance(X, Nothing):
                if tc:
                    raise Refuse('a caveated test around "this attack does nothing"', s)
                self.items.append((i, ('wrapIf', tests, neg)))
            elif isinstance(X, Dmg) and X.op == 'add' and X.args[0][0] == 'const':
                self.items.append((i, Dmg('cond', tests, neg, X.args[0][1], reads=True, cavs=tc)))
            elif isinstance(X, Eff):
                self.items.append((i, Eff(branch(tests, neg, X.e, SKIP), X.cavs | tc)))
            else:
                raise Refuse('conditional consequence not expressible', s)
            return i + 1
        # two-sentence look at the top of the deck
        m = re.match(r'^Look at the top (\d+) cards of your deck\.$', s)
        if m and ctx['kind'] == 'trainer':
            k = num(m.group(1))
            m2 = re.match(r'^You may reveal (up to \d+|an?|any number of) (.+?) you find there and put (?:it|them) into your hand\.$', nxt)
            nx2 = S[i + 2] if i + 2 < len(S) else ''
            if m2 and nx2 == 'Shuffle the other cards back into your deck.':
                q = m2.group(1)
                cnt = k if q == 'any number of' else parse_qty_np(q)[0]
                f = parse_filter(m2.group(2), ctx)
                self.used.append(('look-top-take', s + ' ' + nxt + ' ' + nx2))
                self.items.append((i, Eff(seq(('move', OWN, ('top', k), ('hand',), f, ('upTo', cnt)), ('shuffle',)))))
                return i + 3
            raise Refuse('look at the top of the deck: not expressible', s + ' ' + nxt)
        m = re.match(r'^Look at the top (\d+) cards of your deck and put (up to \d+|an?|\d+) (?:of them|cards?) into your hand\.$', s)
        if m and nxt == 'Shuffle the other cards back into your deck.':
            k = num(m.group(1))
            c, upto = parse_qty_np(m.group(2))
            if not upto:
                raise Refuse('exact take from the top of the deck', s)
            self.used.append(('look-top-take', s + ' ' + nxt))
            self.items.append((i, Eff(seq(('move', OWN, ('top', k), ('hand',), ('any',), ('upTo', c)), ('shuffle',)),
                                      {'upTo0'} if ctx['kind'] != 'attack' else set())))
            return i + 2
        # importer 0.18.0 (milestone MV11): "Switch your Active Pokémon with 1 of your Benched Pokémon. If you do, [you
        # may] move (any amount of Energy | an Energy) from the Pokémon you moved to your Bench to the new Active
        # Pokémon." (Scramble Switch sv8-186, Zinnia's Trust me6-103): the switch, then a move from a Benched Pokémon
        # chosen when it resolves (`shiftEnergy own bench energy q active`); the model does not record which Pokémon the
        # switch moved (shiftFromMoved). With an empty Bench both do nothing (`switchNone`, `shiftNone`)
        if s == 'Switch your Active Pokémon with 1 of your Benched Pokémon.' and ctx['kind'] == 'trainer':
            mm = re.match(r'^If you do, (you may move any amount of|move an) Energy from the Pokémon you moved to your Bench '
                          r'to the new Active Pokémon\.$', nxt)
            if mm:
                q = ('upTo', 60) if mm.group(1).startswith('you may') else ('most', 1)
                cv = {'shiftFromMoved'} | ({'anyAmount60'} if q[0] == 'upTo' else set())
                self.used.append(('switch-then-move-energy', s + ' ' + nxt))
                self.items.append((i, Eff(seq(('switch', OWN),
                                              ('shiftEnergy', OWN, ('bench',), ENERGY_F, q, ('active',), True)), cv)))
                return i + 2
        # importer 0.18.0 (milestone MV11): "You may (shuffle | put) N Energy attached to this Pokémon into your (deck |
        # hand). If you do, X." (Wellspring Mask Ogerpon ex sv6-64): `choice (seq A X) skip` with A the `exactly N` take,
        # which has no resolution that takes nothing (N ≥ 1, `Qty.okE`), so X follows only a take that happened
        m = re.match(r"^You may (shuffle|put) (an|a|\d+) Energy attached to this Pokémon into your (deck|hand)\.$", s)
        if m and ctx['kind'] == 'attack' and nxt.startswith('If you do, ') and \
                (m.group(1) == 'shuffle') == (m.group(3) == 'deck'):
            X = self.clause(nxt[len('If you do, '):])
            if not isinstance(X, Eff) or X.pre:
                raise Refuse("'If you do' with a consequence that is not a plain effect", nxt)
            A = ('returnEnergy', OWN, ('active',), ENERGY_F, ('exactly', num(m.group(2))),
                 ('shuffle',) if m.group(1) == 'shuffle' else ('hand',))
            self.used.append(('may-return-energy-if-you-do', s + ' ' + nxt))
            self.items.append((i, Eff(choice(seq(A, X.e), SKIP), X.cavs)))
            return i + 2
        # importer 0.18.0 (milestone MV11): "You may (put | shuffle | discard) X Energy attached to / from this Pokémon
        # [into your hand | into your deck] (to | and) have this attack do N more damage." The choice is made before the
        # damage step and the Energy leaves first, as printed (a static bonus with an Energy condition reads the
        # attacker's Energy at the damage step): `choice (damage b) (seq X (damage (b + N)))` (`Dmg('mayPre')`)
        m = re.match(r"^You may (put|shuffle|discard) (an|a|all|\d+) (?:(Basic )?" + TYPE_RE + r" )?Energy (?:attached to|from) "
                     r"this Pokémon(?: (into your hand|into your deck))? (?:to|and) have this attack do (\d+) more damage\.$", s)
        if m and ctx['kind'] == 'attack':
            verb, dst = m.group(1), m.group(5)
            if (verb == 'put') != (dst == 'into your hand') or (verb == 'shuffle') != (dst == 'into your deck'):
                raise Refuse('wording', s)
            f = energy_filter(m.group(3), m.group(4))
            q = ('all',) if m.group(2) == 'all' else ('exactly', num(m.group(2)))
            if verb == 'discard':
                X = ('discardEnergy', OWN, ('active',), f, q)
            else:
                X = ('returnEnergy', OWN, ('active',), f, q, ('hand',) if verb == 'put' else ('shuffle',))
            self.used.append(('may-energy-for-more', s))
            self.items.append((i, Dmg('mayPre', X, counters(m.group(6)))))
            return i + 1
        # "Discard all Energy from this Pokémon, and this attack [also] does ...": two items, the discard first.
        # Since importer 0.7 (milestone MV2 census, S13 §B) the discard may be of N, or of all of a type. Since importer
        # 0.13.0 every such discard is resolved before the damage step, as printed (`build_attack`, `first_dmg`): the
        # damage step reads the attacker's Energy through a static bonus with an Energy condition (`Static.need`).
        # importer 0.18.0: also "Shuffle all Energy attached to this Pokémon into your deck, and …" (Mega Skarmory ex me3-55)
        m = re.match(r"^(Discard (?:all|an|a|\d+) (?:(?:Basic )?" + TYPE_RE + r" )?Energy from this Pokémon|"
                     r"Shuffle all Energy attached to this Pokémon into your deck), and "
                     r"(?P<dmg>this attack (?:also )?does (?!.*for each).+)$", s)
        if m and ctx['kind'] == 'attack':
            first = self.one(m.group(1) + '.')
            second = self.one(m.group('dmg')[0].upper() + m.group('dmg')[1:])
            self.used.append(('discard-all-and', s))
            if isinstance(second, Dmg):
                # importer 0.7.0: the discard is resolved before the damage step, as printed (a static bonus
                # with an Energy condition on the attacker could otherwise see the Energy; validation, MV2); since
                # importer 0.13.0 also for "Discard all Energy from this Pokémon, and …"
                first = Eff(first.e, first.cavs, pre=True)
            self.items.append((i, first))
            self.items.append((i, second))
            return i + 1
        it = self.one(s)
        self.items.append((i, it))
        return i + 1

    def prev_item(self, i, what):
        """The item of the sentence just before sentence i, which a consequence refers to: a plain effect."""
        if not self.items or self.items[-1][0] != i - 1:
            # the sentence before was refused (its own blocker is recorded) or produced no item
            raise Refuse(what + ' after a sentence with no translation')
        it = self.items[-1][1]
        if not isinstance(it, Eff) or it.pre:
            raise Refuse(what + ' after an action that is not a plain effect')
        return it

    def mv3_step(self, S, i, nxt):
        """Milestone MV3 forms of attacks and Trainers (importer 0.8.0); None if none applies."""
        s = S[i]
        ctx = self.ctx
        if s.startswith('If you do, '):
            # "A. If you do, B.": `Effect.ifDone t A B` over an action of the table above `done_action`
            prev = self.prev_item(i, "'If you do'")
            r = done_action(prev.e)
            if r is None:
                raise Refuse("'If you do' after an action with no exact feasibility test (the model's action may do "
                             "nothing, or its test is not one count)", s)
            t, a = r
            X = self.clause(s[len('If you do, '):])
            if not isinstance(X, Eff) or X.pre:
                raise Refuse("'If you do' with a consequence that is not a plain effect", s)
            self.used.append(('if-you-do', s))
            self.items[-1] = (self.items[-1][0], Eff(T.if_done(t, a, X.e), prev.cavs | X.cavs))
            return i + 1
        m = re.match(r"^If you can't(?: discard (\d+) cards? in this way)?, this attack does nothing\.$", s)
        if m and ctx['kind'] == 'attack':
            # "Discard k F from your hand / this Pokémon. If you can't [discard k cards in this way], this attack does
            # nothing.": the discard is a cost, resolved first (printed first; `pre`), and the whole attack happens
            # only when it can be paid: `ite (countGe c k) (seq A rest) skip`, with the test of `cost_action`
            prev = self.prev_item(i, "'If you can't'")
            r = cost_action(prev.e)
            if r is None:
                raise Refuse("'If you can't' after an action with no exact feasibility test", s)
            t, a, k = r
            if m.group(1) and num(m.group(1)) != k:
                raise Refuse("'If you can't discard N cards' with N not the printed cost", s)
            self.used.append(('if-you-cant-nothing', s))
            self.items[-1] = (self.items[-1][0], Eff(a, prev.cavs, pre=True))
            self.items.append((i, ('wrapIf', [t], True)))
            return i + 1
        if s == "If you can't discard any, this attack does nothing." and ctx['kind'] == 'attack':
            # importer 0.13.0 (Melmetal sv7-104): after "Before doing damage, discard all Pokémon Tools from this Pokémon":
            # the attack happens only if this Pokémon has a Tool (`hasTool own`, the exact test that the discard can
            # discard any), tested when the attack starts, before the discard
            if not self.items or self.items[-1][0] != i - 1 or not isinstance(self.items[-1][1], Eff) or \
                    self.items[-1][1].e != ('discardTools', OWN, ('active',)):
                raise Refuse("'If you can't discard any' after an action other than discarding this Pokémon's Tools", s)
            self.used.append(('if-you-cant-discard-tools', s))
            self.items.append((i, ('wrapIf', [('hasTool', OWN)], True)))
            return i + 1
        m = re.match(r"^If you don't have exactly (\d+) cards in your hand, this attack does nothing\.$", s)
        if m and ctx['kind'] == 'attack':
            # "exactly n" is `countGe … n` and not `countGe … (n + 1)` (S15 §2, "already expressible")
            n = num(m.group(1))
            c = ('pile', OWN, ('hand',), ('any',))
            self.used.append(('if-not-exactly-hand-nothing', s))
            self.items.append((i, ('wrapFn', lambda e, c=c, n=n: ite(('countGe', c, n), ite(('countGe', c, n + 1), SKIP, e), SKIP))))
            return i + 1
        m = FU_RE.match(s)
        if m and ctx['kind'] == 'attack':
            # "Discard up to N F from this Pokémon / your hand, and this attack does K damage for each card you
            # discarded in this way.": `Effect.forUpTo f N` unfolded, f i = seq (discard exactly i) (damage (K·i)), the
            # number discarded being the branch (`Run.forUpTo_iff`: the resolutions are those of f i for i ≤ N; f i has
            # one exactly when i cards of the kind are there, `cost_action`'s reading of `exactly`). The discard
            # comes first, as printed. "any amount" / "any number": N = ANY_BOUND (caveat anyAmount60). "You may
            # discard up to N" is the same set (0 is one of the choices in an attack, 2026 rulebook p. 21).
            mk = fu_source(m.group(3), m.group(4), ctx)
            n = num(m.group(2)) if m.group(2) else ANY_BOUND
            self.used.append(('for-each-discarded', s))
            self.items.append((i, Dmg('forUpTo', mk, n, counters(m.group(5)), bool(m.group(6)),
                                      cavs=set() if m.group(2) else {'anyAmount60'})))
            return i + 1
        m = re.match(r"^Discard all (?:(Basic) )?(?:" + TYPE_RE + r" )?Energy from this Pokémon\.$", s)
        m2 = re.match(r"^This attack does (\d+) damage for each (?:card|Energy card) (?:you )?discarded in this way\.$", nxt)
        if m and m2 and ctx['kind'] == 'attack':
            # "Discard all F Energy from this Pokémon. This attack does K damage for each card you discarded in this
            # way.": the branch i of `forUpTo` discards exactly i, and has a resolution only if no F Energy is left
            # (`NO_PLAY`, no resolution), so the one resolution is i = the F Energy attached, as printed, with the
            # discard before the damage step. Bound ANY_BOUND (caveat anyAmount60).
            f = energy_filter(m.group(1), m.group(2))
            k = counters(m2.group(1))
            mk = lambda j, f=f: seq(('discardEnergy', OWN, ('active',), f, ('exactly', j)),
                                     ite(('countGe', ('energy', OWN, f), 1), NO_PLAY, SKIP))
            self.used.append(('discard-all-for-each', s + ' ' + nxt))
            self.items.append((i, Dmg('forUpTo', mk, ANY_BOUND, k, False, cavs={'anyAmount60'})))
            return i + 2
        return None

    def coin_tree_step(self, S, i):
        """Importer 0.13.0 (survey S16 §5, class I): "Flip k coins. [This attack does P (more) damage for each heads.]
        If <a count of heads>, X. [If …, Y. …]" in an attack, where the same coins decide the damage and the
        conditions (`Dmg('coinsx')`, built by `build_attack`). Only the forms the older rules do not cover: a per-heads
        damage sentence followed by a condition, two or more conditions, or an exact count of heads."""
        s = S[i]
        m = re.match(r'^Flip (\d+|two|three|four) coins\.$', s)
        if not m or self.ctx['kind'] != 'attack':
            return None
        k = num(m.group(1))
        j = i + 1
        per = None
        more = False
        m2 = re.match(r'^This attack does (\d+) (more )?damage for each heads\.$', S[j] if j < len(S) else '')
        if m2:
            per, more = counters(m2.group(1)), bool(m2.group(2))
            j += 1
        conds = []
        exact = False
        while j < len(S):
            mc = re.match(r'^If (both of them are (?:heads|tails)|all of them are (?:heads|tails)|either of them is heads|'
                          r'any of them are heads|at least (\d) of them are heads|(\d) of them (?:is|are) heads), (.+)$', S[j])
            if not mc:
                break
            w = mc.group(1)
            if w.endswith('tails'):
                hs = {0}
            elif w.startswith(('both', 'all')):
                hs = {k}
            elif w.startswith(('either', 'any')):
                hs = set(range(1, k + 1))
            elif mc.group(2):
                hs = set(range(int(mc.group(2)), k + 1))
            else:
                hs = {int(mc.group(3))}
                exact = True
            if not hs or max(hs) > k or (w.startswith('both') and k != 2):
                raise Refuse('coin condition not expressible', S[j])
            X = self.clause(mc.group(4))
            if isinstance(X, Nothing) or (isinstance(X, Dmg) and (X.op != 'add' or X.args[0][0] != 'const')):
                raise Refuse('coin condition with a consequence not expressible', S[j])
            conds.append((frozenset(hs), X))
            j += 1
        if not conds or not (per is not None or len(conds) >= 2 or exact):
            return None
        self.used.append(('flip-n-coins-tree', ' '.join(S[i:j])))
        self.items.append((i, Dmg('coinsx', k, per, more, conds)))
        return j

    def s16_step(self, S, i, nxt):
        """Multi-sentence forms of importer 0.9.0 (survey S16, class I); None if none applies."""
        s = S[i]
        ctx = self.ctx
        nx2 = S[i + 2] if i + 2 < len(S) else ''
        j = self.coin_tree_step(S, i)
        if j is not None:
            return j
        # "Flip N coins. If both of them are heads / all … / either … / any … / at least k …, X." (one condition, no
        # further "If" sentence): for N ≥ 2 the event is neither certain nor impossible, and coin flips are
        # nondeterministic choices (Known gaps), so the outcomes are those of one flip: X, or not
        m = re.match(r'^Flip (\d+|two|three) coins\.$', s)
        mm = re.match(r'^If (both of them are|all of them are|either of them is|any of them are|at least (\d) of them are) '
                      r'(heads|tails), (.+)$', nxt)
        if m and mm and num(m.group(1)) >= 2 and not nx2.startswith('If ') and \
                (not mm.group(2) or 1 <= int(mm.group(2)) <= num(m.group(1))):
            X = self.clause(mm.group(4)) if not mm.group(4).startswith('this attack does') else None
            if X is None:
                mm2 = re.match(r'^this attack does (\d+) more damage\.$', mm.group(4))
                if not mm2:
                    raise Refuse('coin flips not expressible', s + ' ' + nxt)
                X = Dmg('add', ('const', counters(mm2.group(1))))
            j = i + 2
            if (isinstance(X, Eff) and j < len(S) and S[j] == 'Then, shuffle your deck.' and searches_deck(X.e)):
                self.used.append(('shuffle', S[j]))
                X = Eff(seq(X.e, ('shuffle',)), X.cavs)
                j += 1
            self.used.append(('flip-n-coins-if', s + ' ' + nxt))
            self.flip(X, None, i)
            return j
        # "Switch in 1 of your opponent's Benched Pokémon to the Active Spot. This attack does N damage to the new Active
        # Pokémon.": the switch first (printed first, `pre`), then a damage step if it happened. After `switch opp` the
        # opponent's Bench is non-empty exactly when the switch happened (`Run.switch` puts the old Active Pokémon on the
        # Bench; `Run.switchNone` needs an empty Bench), so the test `countGe (bench opp pokemon) 1`, read after the
        # switch, decides the damage step: N to the new Active Pokémon, or (no new Active Pokémon) none
        if s == "Switch in 1 of your opponent's Benched Pokémon to the Active Spot." and ctx['kind'] == 'attack':
            mm = re.match(r'^This attack does (\d+) damage to the new Active Pokémon\.$', nxt)
            if mm:
                self.used.append(('gust-then-damage', s + ' ' + nxt))
                self.items.append((i, Eff(('switch', OPP), pre=True)))
                self.items.append((i + 1, Dmg('afterGust', counters(mm.group(1)))))
                return i + 2
        # "Flip a coin until you get tails. For each heads, X." with X a mill or an Energy discard that does what it can:
        # `iter X`, any number of times (Card.lean: `iter` covers "flip until tails")
        if s == 'Flip a coin until you get tails.' and ctx['kind'] == 'attack':
            mm = re.match(r"^For each heads, (discard the top card of your opponent's deck|discard an Energy from your "
                          r"opponent's Active Pokémon)\.$", nxt)
            if mm:
                X = self.clause(mm.group(1) + '.')
                self.used.append(('flip-until-tails-each', s + ' ' + nxt))
                self.items.append((i, Eff(('iter', X.e), X.cavs)))
                return i + 2
        # "Your opponent shuffles their hand and puts it on the bottom of their deck. If they put any cards on the
        # bottom of their deck in this way, they draw N cards.": the move of all of the hand (`Put.bottom`, any order)
        # puts a card exactly when the hand has one, the test read before it
        if s == "Your opponent shuffles their hand and puts it on the bottom of their deck.":
            mm = re.match(r'^If they put any cards on the bottom of their deck in this way, they draw (\d+) cards\.$', nxt)
            if mm:
                self.used.append(('opp-hand-bottom-draw', s + ' ' + nxt))
                self.items.append((i, Eff(ite(('countGe', ('pile', OPP, ('hand',), ('any',)), 1),
                                              seq(('move', OPP, ('hand',), ('bottom',), ('any',), ('all',)),
                                                  draw(OPP, num(mm.group(1)))), SKIP))))
                return i + 2
        # a random card of the opponent's hand shuffled into their deck: a nondeterministic choice of one card
        # (random selection, like a coin flip, is a nondeterministic choice), revealing is a no-op
        one_rand = "Choose a random card from your opponent's hand, and your opponent reveals that card and shuffles it into their deck."
        if (s == "Choose a random card from your opponent's hand." and
                nxt == 'Your opponent reveals that card and shuffles it into their deck.') or s == one_rand:
            mk = lambda q: ('move', OPP, ('hand',), ('shuffle',), ('any',), q)  # noqa: E731
            self.used.append(('random-opp-hand-to-deck', s))
            self.items.append((i, Eff(min_take(('pile', OPP, ('hand',), ('any',)), 1, mk, ctx))))
            return i + 1 if s == one_rand else i + 2
        # "Look at the top N cards of your deck and put K of them into your hand. Discard the other cards."
        m = re.match(r'^Look at the top (\d+) cards of your deck and put (\d+) of them into your hand\.$', s)
        if m and nxt == 'Discard the other cards.':
            n, k = num(m.group(1)), num(m.group(2))
            mk = lambda q: ('move', OWN, ('top', n), ('hand',), ('any',), q)  # noqa: E731
            self.used.append(('look-top-take-discard', s + ' ' + nxt))
            self.items.append((i, Eff(seq(min_take(('pile', OWN, ('deck',), ('any',)), k, mk, ctx),
                                          ('move', OWN, ('top', n - k), ('discard',), ('any',), ('all',))))))
            return i + 2
        # attacks: "Look at the top card of your deck. You may discard that card." (as the Ability form)
        if s == 'Look at the top card of your deck.' and nxt == 'You may discard that card.' and ctx['kind'] == 'attack':
            self.used.append(('look-top-may-discard', s + ' ' + nxt))
            self.items.append((i, Eff(choice(('move', OWN, ('top', 1), ('discard',), ('any',), ('all',)), SKIP))))
            return i + 2
        # "Choose 1 or both: • A • B": A, B, or A then B (printed order)
        if s == 'Choose 1 or both:' and nxt.startswith('• ') and nx2.startswith('• ') and \
                not (i + 3 < len(S) and S[i + 3].startswith('• ')):
            A, B = self.one(nxt[2:]), self.one(nx2[2:])
            if not (isinstance(A, Eff) and isinstance(B, Eff)) or A.pre or B.pre:
                raise Refuse('"Choose 1 or both" with an item that is not a plain effect', s)
            self.used.append(('choose-1-or-both', s))
            self.items.append((i, Eff(choice(A.e, choice(B.e, seq(A.e, B.e))), A.cavs | B.cavs)))
            return i + 3
        # two effects in one sentence, in printed order
        m = re.match(r"^Your opponent's Active Pokémon is now (" + COND_RE + r"), and discard an Energy from that Pokémon\.$", s)
        if m and ctx['kind'] == 'attack':
            a = self.one("Your opponent's Active Pokémon is now %s." % m.group(1))
            b = self.one("Discard an Energy from your opponent's Active Pokémon.")
            self.used.append(('two-effects', s))
            self.items += [(i, a), (i, b)]
            return i + 1
        m = re.match(r"^(Discard \d+ Energy from this Pokémon), and (your opponent's Active Pokémon is now " + COND_RE + r")\.$", s)
        if m and ctx['kind'] == 'attack':
            a = self.one(m.group(1) + '.')
            b = self.one(m.group(2)[0].upper() + m.group(2)[1:] + '.')
            self.used.append(('two-effects', s))
            self.items += [(i, a), (i, b)]
            return i + 1
        m = re.match(r'^This attack does (\d+) more damage, and (heal \d+ damage from this Pokémon)\.$', s)
        if m and ctx['kind'] == 'attack':
            a = self.one('This attack does %s more damage.' % m.group(1))
            b = self.one(m.group(2)[0].upper() + m.group(2)[1:] + '.')
            self.used.append(('two-effects', s))
            self.items += [(i, a), (i, b)]
            return i + 1
        return None

    def ability_step(self, S, i, nxt):
        """Multi-sentence forms of Abilities; None if none applies."""
        s = S[i]
        if s.startswith('If you do, '):
            X = self.clause(s[len('If you do, '):])
            self.used.append(('ab-if-you-do', s))
            self.items.append((i, ('ifYouDo', X)))
            return i + 1
        if s == 'Look at the top card of your deck.' and nxt == 'You may discard that card.':
            # importer 0.13.0: a window of the top card (`Effect.look`, milestone MV6), of which up to 1 is discarded and
            # the rest put back on top: the same outcomes as `choice (move own (top 1) discard any all) skip`, written as
            # the look it is, so that a use that discards nothing reads as a look at a hidden card (`noop.py`)
            self.used.append(('ab-look-top-may-discard', s + ' ' + nxt))
            self.items.append((i, Eff(('look', OWN, ('top', 1), ('any',), ('upTo', 1), ('put', ('discard',)), ('top',)))))
            return i + 2
        if (s == 'Look at the top 2 cards of your deck and put 1 of them into your hand.'
                and nxt == 'Put the other card on the bottom of your deck.'):
            self.used.append(('ab-look-2-take-1', s + ' ' + nxt))
            two = seq(('move', OWN, ('top', 2), ('hand',), ('any',), ('exactly', 1)),
                      ('move', OWN, ('top', 1), ('bottom',), ('any',), ('all',)))
            self.items.append((i, Eff(ite(('countGe', ('pile', OWN, ('deck',), ('any',)), 2), two,
                                          ('move', OWN, ('top', 1), ('hand',), ('any',), ('all',))))))
            return i + 2
        # importer 0.13.0: "Look at the top N cards of your deck, reveal a X you find there, and put it into your hand.
        # Shuffle the other cards back into your deck." is left to the window rule of milestone MV6 (`mv6_step`: `look …
        # (most 1)` with the caveat `failToFind`), as Delibird me6-79's same shape is; until 0.12.0 this rule wrote
        # `upTo 1`, a take that may fail, without a caveat (Tatsugiri svp-118)
        return None

    def clause(self, c):
        """The consequent of a flip or a condition, as an item."""
        c = c.strip()
        if c in ('this attack does nothing.',):
            if self.ctx['kind'] != 'attack':
                raise Refuse('wording', c)
            return Nothing()
        m = re.match(r'^this attack does (\d+) more damage\.$', c)
        if m:
            return Dmg('add', ('const', counters(m.group(1))))
        m = re.match(r'^this attack does (\d+) more damage, and (heal \d+ damage from this Pokémon\.)$', c)
        if m and self.ctx['kind'] == 'attack':
            # importer 0.13.0 (Floragato sv9-17): both halves under one coin; `flip` writes them as one leaf
            X = self.clause(m.group(2))
            return Dmg('addx', counters(m.group(1)), X)
        m = re.match(r'^(your opponent\'s Active Pokémon is now .+)$', c)
        if m:
            c = 'Y' + c[1:]
        elif c and c[0].islower():
            c = c[0].upper() + c[1:]
        name, it = match_rule(c, self.ctx)
        self.used.append((name, c))
        if not isinstance(it, Eff):
            raise Refuse('consequence not a plain effect', c)
        return it

    def flip(self, H, Tl, i):
        if isinstance(Tl, Nothing) and H is None:
            self.items.append((i, ('wrapFlip',)))
            return
        # importer 0.17.0: "If tails, this attack does nothing. If heads, X." in an attack: the whole attack (its damage
        # and X) on heads, nothing on tails (`wrapFlip` around the script, X unconditional inside it)
        if isinstance(Tl, Nothing) and isinstance(H, Eff) and self.ctx['kind'] == 'attack':
            self.items.append((i, ('wrapFlip',)))
            self.items.append((i, H))
            return
        if isinstance(H, Dmg) and H.op == 'addx' and Tl is None:
            n, X = H.args
            self.items.append((i, Dmg('coinsx', 1, None, False, [({1}, Dmg('add', ('const', n))), ({1}, X)])))
            return
        if isinstance(H, Dmg) and Tl is None:
            if H.op != 'add' or H.args[0][0] != 'const':
                raise Refuse('coin-flip damage not expressible')
            self.items.append((i, Dmg('flipadd', H.args[0][1])))
            return
        if (self.ctx['kind'] == 'trainer' and isinstance(H, Eff) and Tl is None and H.e[0] == 'ite'
                and H.e[3] == NO_PLAY and H.e[2] != NO_PLAY and self.ctx.get('_s16coin')):
            # importer 0.9.0 (review of Crushing Hammer): "Flip a coin. If heads, X" where X cannot happen in some states
            # (`ite t X' none`): the Trainer cannot be played there, whatever the flip, so the test is taken outside the
            # flip (min_take's convention applied to the whole card): `ite t (choice X' skip) none`
            self.items.append((i, Eff(ite(H.e[1], choice(H.e[2], SKIP), NO_PLAY), H.cavs)))
            return
        if (H is None or isinstance(H, Eff)) and (Tl is None or isinstance(Tl, Eff)):
            a = H.e if H else SKIP
            b = Tl.e if Tl else SKIP
            cv = (H.cavs if H else set()) | (Tl.cavs if Tl else set())
            self.items.append((i, Eff(choice(a, b), cv)))
            return
        raise Refuse('coin-flip consequences not expressible')


# ------------------------------------------------------------------ milestone MV6 (importer 0.12.0)
#
# Windows (`Effect.look w src f q into rest`, Pokemon/Look.lean): the window is read once, when the effect starts
# (`ZStep.look`: `src.get`, the top or bottom n cards of the deck as they are then, all of them if fewer are left, as
# the rulebook says: "If a card tells you to draw or look at more cards from your deck than you have left, draw or look
# at the cards you have and continue play as normal", 2026 p. 21), the cards taken pass the filter in the number the
# quantity says, the other cards go where print puts them (`rest`) and then the taken cards go to their place (`Into`).
# Quantities, by the rulebook's p. 21 and the Known gaps' hidden-information entry:
#   * "you may … any number of" / "any number of": `upTo N` (N the window's size; "any number" allows 0, p. 21);
#   * "you may reveal a X": `upTo 1` (the print lets the player decline);
#   * "up to k" outside attacks (1 to k, p. 21) on a public window: the union over j = 1..k of `most j` (exactly the
#     numbers 1..min(k, m) when m cards pass, and 0 when none does); in attacks `upTo k`;
#   * a mandatory "a X you find there": `most 1`. On a public window (a revealed hand, revealed deck cards) that is
#     exact. On a private window (the top or bottom cards of the player's own deck, which the opponent does not see) the
#     rulebook states no rule on failing to find (2026 p. 21 speaks only of "up to", "any number" and of searches "for
#     any card you want", which must take at least 1); `most` follows the printed text and carries `failToFind` (the
#     usual practice lets the player fail to find; Known gaps, hidden information);
#   * onto a Bench: `upTo`, or for a mandatory single card `ite (countGe (bench w pokemon) 5) skip (look … (most 1))`
#     (with a full Bench `most` would have no resolution; print puts nothing then; `benchLimit` is 5).
# Defender modifiers (Pokemon/Defender.lean): "attacks used by the Defending Pokémon do N less damage (before …)" is
# `linger .opp .next (.weaken n)`; "the Defending Pokémon takes N more damage from attacks (after …)" during your next
# turn is `linger .opp .after (.expose n)`; "this Pokémon takes N more damage" during the opponent's next turn is
# `linger .own .next (.expose n)`. All carry `perPokemon` (modifiers belong to a player); the
# penalty also `benchMods` (print weakens the Defending Pokémon's attack damage to Benched Pokémon too).

def look(w, src, f, q, into, rest):
    return ('look', w, src, f, q, into, rest)


OWN_REST = {
    'Shuffle the other cards back into your deck.': ('shuffle',),
    'Shuffle the other cards and put them on the bottom of your deck.': ('bottom',),
    'Put the other cards back in any order.': ('top',),
    'Discard the other cards.': ('discard',),
}
OPP_REST = {
    'Your opponent shuffles the other cards back into their deck.': ('shuffle',),
}
WIN_HEAD = r"^(Look at|Reveal) the (top|bottom) (\d+) cards of (your|your opponent's) deck"


def chain_choice(alts):
    out = alts[-1]
    for a in reversed(alts[:-1]):
        out = choice(a, out)
    return out


def up_to_from_1(k, mk):
    """'up to k' outside attacks on a public window (1..k, or 0 when nothing passes): `most 1` | … | `most k`."""
    return chain_choice([mk(('most', j)) for j in range(1, k + 1)])


def attach_into(tgt, n, ctx):
    """The `Into` of 'attach … you find there to TGT', and caveats."""
    if tgt in ('your Pokémon in any way you like', '1 of your Pokémon'):
        if tgt == '1 of your Pokémon' and n != 1:
            raise Refuse('several cards to one chosen Pokémon')
        return ('attach', ('any',)), set()
    m = re.match(r'^your (' + TYPE_RE + r') Pokémon in any way you like$', tgt)
    if m:
        return ('attach', ('ptype', etype(m.group(1)))), set()
    if tgt == 'this Pokémon' and ctx['kind'] == 'ability' and ctx.get('spot') is None and n == 1:
        # "this Pokémon" not tracked (on-play Ability): any of the player's Pokémon (`SelfOp.at` none reads the same)
        return ('attach', ('any',)), {'selfBench'}
    raise Refuse('window: attach target not expressible: ' + tgt)


def window_qty(qw, n, private, ctx, bench=False):
    """(quantity, caveats) for 'any number of' / 'a' / 'an' / 'up to k' in a window of size n."""
    if qw == 'any number of':
        return ('upTo', n), set()
    if qw in ('a', 'an'):
        if bench:
            return None, set()      # the caller writes the full-Bench test
        return ('most', 1), ({'failToFind'} if private else set())
    m = re.match(r'^up to (\d+)$', qw)
    if m:
        if ctx['kind'] == 'attack':
            return ('upTo', num(m.group(1))), set()
        raise Refuse('window: "up to" outside an attack on a private window')
    raise Refuse('window quantity not expressible: ' + qw)


# "Your opponent reveals their hand" where nothing is then taken: a window on the opponent's hand that takes no card and
# puts the hand back (the identity on states, as `skip`).
REVEAL_OPP_HAND = ('look', OPP, ('hand',), ('any',), ('exactly', 0), ('put', ('hand',)), ('hand',))


def opp_hand_clause(c, ctx):
    """A clause on the cards 'you find there' after "Your opponent reveals their hand" (a public window): an `Eff` or a
    `Dmg`."""
    c = c.rstrip('.')
    c = c[0].lower() + c[1:]
    m = re.match(r'^this attack does (\d+) damage for each (.+?) you find there$', c)
    if m and ctx['kind'] == 'attack':
        k = counters(m.group(1))
        f = parse_filter(m.group(2), ctx)
        return Dmg('set', ('count', ('pile', OPP, ('hand',), f), k), k, reads=True)
    m = re.match(r"^discard all (.+?) cards and (.+?) cards you find there$", c)
    if m:
        f = ('or', parse_filter(m.group(1), ctx), parse_filter(m.group(2), ctx))
        return Eff(('move', OPP, ('hand',), ('discard',), f, ('all',)))
    m = re.match(r"^(discard|choose|put) (an?|up to \d+|any number of) (.+?) (?:that )?you find there"
                 r"(?: and put (?:it|them))?(?: (on the bottom of (?:their|your opponent's) deck|onto (?:their|your "
                 r"opponent's) Bench))?$", c)
    if not m:
        raise Refuse('revealed hand: clause not expressible', c)
    verb, qw, np_, where = m.groups()
    f = parse_filter(np_, ctx)
    if verb == 'discard' and where is None:
        dst = ('put', ('discard',))
    elif where and where.startswith('on the bottom') and verb in ('choose', 'put'):
        dst = ('put', ('bottom',))
    elif where and where.startswith('onto') and verb == 'put':
        dst = ('bench',)
    else:
        raise Refuse('revealed hand: clause not expressible', c)
    if dst == ('bench',):
        bench_filter_ok(f)
        mk = lambda q: look(OPP, ('hand',), f, q, ('bench',), ('hand',))  # noqa: E731
        if qw == 'any number of':
            return Eff(mk(('upTo', 5)))
        if qw in ('a', 'an'):
            # with a full Bench nothing is put there, but the hand is still revealed: importer 0.13.0 writes that branch as
            # the reveal it is, a window on the opponent's hand that takes nothing (`look … (exactly 0)`, the identity),
            # so that a use with a full Bench reads as a look at a hidden zone, not a use to no effect (`noop.py`)
            return Eff(ite(('countGe', ('bench', OPP, ('pokemon',)), 5), REVEAL_OPP_HAND, mk(('most', 1))))
        k = num(qw.split()[-1])
        if ctx['kind'] == 'attack':
            return Eff(mk(('upTo', k)))
        raise Refuse('revealed hand: "up to" onto a Bench outside an attack', c)
    mk = lambda q: ('move', OPP, ('hand',), dst[1], f, q)  # noqa: E731
    if qw in ('a', 'an'):
        return Eff(mk(('most', 1)))
    if qw == 'any number of':
        raise Refuse('revealed hand: "any number" to a zone', c)
    k = num(qw.split()[-1])
    if ctx['kind'] == 'attack':
        return Eff(mk(('upTo', k)))
    return Eff(up_to_from_1(k, mk))


def mv6_step(P, S, i, nxt):
    """Multi-sentence and window forms of milestone MV6 (importer 0.12.0); None if none applies."""
    s = S[i]
    ctx = P.ctx
    kind = ctx['kind']
    nx2 = S[i + 2] if i + 2 < len(S) else ''

    def emit(j, rule, it, n_used):
        P.used.append((rule, ' '.join(S[i:i + n_used])))
        P.items.append((i, it))
        return i + n_used

    # ---- Bug Out: a count over the bottom window, then its Pokémon shuffled back and the others discarded
    m = re.match(r'^Reveal the bottom (\d+) cards of your deck, and this attack does (\d+) damage for each Pokémon you find '
                 r'there that has the (.+) attack\.$', s)
    if m and kind == 'attack' and nxt == 'Then, shuffle any revealed Pokémon back into your deck.' and \
            nx2 == 'Discard the other cards.':
        n, k = int(m.group(1)), counters(m.group(2))
        f = ('and', ('pokemon',), has_attack(m.group(3)))
        P.used.append(('bottom-count-then-sort', ' '.join(S[i:i + 3])))
        P.items.append((i, Dmg('set', ('count', ('pile', OWN, ('bottom', n), f), k), k, reads=True)))
        P.items.append((i + 1, Eff(look(OWN, ('bottom', n), ('pokemon',), ('all',), ('put', ('shuffle',)), ('discard',)))))
        return i + 3

    # ---- windows on a deck
    m = re.match(WIN_HEAD + r'(.*)$', s)
    if m:
        verb, end, n, whose, tail = m.groups()
        n = int(n)
        w = OWN if whose == 'your' else OPP
        src = ('top', n) if end == 'top' else ('bottom', n)
        private = verb == 'Look at' and w == OWN
        rests = OWN_REST if w == OWN else OPP_REST
        # the existing importer 0.9.0 form for Trainers (top of the own deck, two sentences) keeps its term
        if (tail == '.' and end == 'top' and w == OWN and kind == 'trainer' and
                re.match(r'^You may reveal (up to \d+|an?|any number of) (.+?) you find there and put', nxt)):
            return None
        # "… and put them back in any order."
        if tail == ' and put them back in any order.':
            return emit(i, 'look-reorder', Eff(look(w, src, ('any',), ('exactly', 0), ('put', ('top',)), ('top',))), 1)
        # "… and put them back in any order, or shuffle them and put them on the bottom of your deck."
        if tail == ' and put them back in any order, or shuffle them and put them on the bottom of your deck.' and w == OWN:
            a = look(w, src, ('any',), ('exactly', 0), ('put', ('top',)), ('top',))
            b = look(w, src, ('any',), ('exactly', 0), ('put', ('top',)), ('bottom',))
            return emit(i, 'look-reorder-or-bottom', Eff(choice(a, b)), 1)
        # "… and discard any number of them." + "Put the other cards back in any order."
        if tail == ' and discard any number of them.' and nxt in rests:
            return emit(i, 'look-discard-any', Eff(look(w, src, ('any',), ('upTo', n), ('put', ('discard',)), rests[nxt])), 2)
        # one sentence, or the head and the next sentence joined
        if tail == '.':
            body, k0 = nxt, 2
        elif tail.startswith(', and '):
            body, k0 = tail[6:], 1
        elif tail.startswith(', '):
            body, k0 = tail[2:], 1
        elif tail.startswith(' and '):
            body, k0 = tail[5:], 1
        else:
            return None
        body = body[0].lower() + body[1:] if body else body
        rest_s = S[i + k0] if i + k0 < len(S) else ''
        if rest_s not in rests:
            return None     # earlier rules, or their refusals
        rest = rests[rest_s]
        cv = set()
        # to the hand
        mm = re.match(r'^(you may )?reveal (any number of|an?|up to \d+) (.+?) you find there,? and put (?:it|them) into '
                      r'your hand\.$', body)
        if mm:
            may, qw, np_ = mm.groups()
            f = parse_filter(np_, ctx)
            if may and qw in ('a', 'an'):
                q = ('upTo', 1)
            elif may and qw.startswith('up to'):
                if kind != 'attack':
                    cv.add('upTo0')
                q = ('upTo', num(qw.split()[-1]))
            else:
                q, cv2 = window_qty(qw, n, private, ctx)
                cv |= cv2
            P.used.append(('look-take-hand', ' '.join(S[i:i + k0 + 1])))
            P.items.append((i, Eff(look(w, src, f, q, ('put', ('hand',)), rest), cv)))
            return i + k0 + 1
        # onto the Bench
        mm = re.match(r'^(?:you may )?(?:put|choose) any number of (.+?) you find there (?:and put those Pokémon )?onto '
                      r'(your|their) Bench\.$', body)
        if mm:
            f = parse_filter(mm.group(1), ctx)
            if (mm.group(2) == 'your') != (w == OWN):
                raise Refuse('window: Bench of the other player', body)
            bench_filter_ok(f)
            P.used.append(('look-bench', ' '.join(S[i:i + k0 + 1])))
            P.items.append((i, Eff(look(w, src, f, ('upTo', n), ('bench',), rest), cv)))
            return i + k0 + 1
        # attached
        mm = re.match(r'^attach (any number of|an?) (.+?) you find there to (.+)\.$', body)
        if mm and w == OWN:
            qw, np_, tgt = mm.groups()
            f = parse_filter(np_, ctx)
            if not is_energy_filter(f):
                raise Refuse('attach a non-Energy card')
            q, cv2 = window_qty(qw, n, private, ctx)
            into, cv3 = attach_into(tgt, q[1] if q[0] == 'most' else n, ctx)
            P.used.append(('look-attach', ' '.join(S[i:i + k0 + 1])))
            P.items.append((i, Eff(look(w, src, f, q, into, rest), cv | cv2 | cv3)))
            return i + k0 + 1
        return None

    # ---- draws from the bottom
    m = re.match(r'^Draw (\d+) cards from the bottom of your deck\.$', s)
    if m:
        return emit(i, 'draw-bottom', Eff(('move', OWN, ('bottom', int(m.group(1))), ('hand',), ('any',), ('all',))), 1)

    # ---- "Search your deck for a card. Shuffle your deck, then put that card on top of it." (any card: at least 1, p. 21)
    if s == 'Search your deck for a card.' and nxt == 'Shuffle your deck, then put that card on top of it.':
        return emit(i, 'search-to-top', Eff(look(OWN, ('deck',), ('any',), ('most', 1), ('put', ('top',)), ('shuffle',))), 2)

    # ---- the opponent's revealed hand (a public window)
    if s == 'Your opponent reveals their hand.' and 'you find there' in nxt:
        it = opp_hand_clause(nxt, ctx)
        P.used.append(('revealed-hand', s + ' ' + nxt))
        P.items.append((i + 1, it))
        return i + 2
    m = re.match(r'^(?:Your opponent reveals their hand|Have your opponent reveal their hand),? and (?:you )?(.+ you find '
                 r'there.*)$', s)
    if m:
        it = opp_hand_clause(m.group(1), ctx)
        return emit(i, 'revealed-hand', it, 1)
    # "Flip 3 coins. If any of them are heads, your opponent reveals their hand. For each heads, choose a card you find
    # there and shuffle it into your opponent's deck."
    m = re.match(r'^Flip (\d+) coins\.$', s)
    if m and nxt == 'If any of them are heads, your opponent reveals their hand.' and \
            nx2 == "For each heads, choose a card you find there and shuffle it into your opponent's deck.":
        k = int(m.group(1))
        mk = lambda h: ('move', OPP, ('hand',), ('shuffle',), ('any',), ('most', h))  # noqa: E731
        return emit(i, 'coins-revealed-hand-shuffle', Eff(chain_choice([SKIP] + [mk(h) for h in range(1, k + 1)])), 3)
    # random cards of the opponent's hand, one per heads (random is a nondeterministic choice)
    if nxt == "For each heads, choose a random card from your opponent's hand." and \
            nx2 == 'Your opponent reveals those cards and shuffles them into their deck.':
        mv = lambda h: ('move', OPP, ('hand',), ('shuffle',), ('any',), ('most', h))  # noqa: E731
        m = re.match(r'^Flip (\d+|two|three) coins\.$', s)
        if m:
            k = num(m.group(1))
            return emit(i, 'coins-random-hand-shuffle', Eff(chain_choice([SKIP] + [mv(h) for h in range(1, k + 1)])), 3)
        if s == 'Flip a coin until you get tails.':
            return emit(i, 'until-tails-random-hand-shuffle', Eff(('iter', mv(1))), 3)

    # ---- coins counted by the state (`Amt.heads`)
    m = re.match(r'^Flip a coin for each (.+)\.$', s)
    mm = re.match(r'^This attack does (\d+) damage for each heads\.$', nxt)
    if m and mm and kind == 'attack':
        x = m.group(1)
        m2 = re.match(r'^(.+) you have in play$', x)
        if m2:
            x = 'of your ' + m2.group(1) + ' in play'
        c = parse_count(x, ctx)(1)
        k = counters(mm.group(1))
        return emit(i, 'coins-for-each-damage', Dmg('set', ('heads', c, k), k, reads=True), 2)
    m = re.match(r"^Your opponent flips a coin for each of their Benched Pokémon\.$", s)
    mm = re.match(r"^This attack does (\d+) damage to your opponent's Active Pokémon for each tails\.$", nxt)
    if m and mm and kind == 'attack':
        k = counters(mm.group(1))
        # tails among the coins has the distribution of heads; coin flips are nondeterministic choices
        return emit(i, 'coins-for-each-damage',
                    Dmg('set', ('heads', ('count', ('bench', OPP, ('pokemon',)), 1), k), k, reads=True), 2)
    # "Reveal any number of X, Y, and Z from your hand, and this attack does N damage for each card you revealed in this
    # way.": any number up to the count (`Amt.heads` over a hand count)
    m = re.match(r'^Reveal any number of (.+?) from your hand, and this attack does (\d+) damage for each card you '
                 r'revealed in this way\.$', s)
    if m and kind == 'attack':
        names = re.split(r', and |, | and ', m.group(1))
        if not all(KNOWN_NAMES.get(x) == {'Pokémon'} for x in names):
            raise Refuse('reveal from the hand: not a list of Pokémon names', s)
        f = chain_or([('named', x) for x in names])
        k = counters(m.group(2))
        return emit(i, 'reveal-hand-count-damage',
                    Dmg('set', ('heads', ('count', ('pile', OWN, ('hand',), f), 1), k), k, reads=True), 1)
    return None


def chain_or(fs):
    out = fs[-1]
    for f in reversed(fs[:-1]):
        out = ('or', f, out)
    return out


@rule('ling-weaken-defending', r"During your opponent's next turn, attacks used by the Defending Pokémon do (\d+) less damage "
      r"\(before applying Weakness and Resistance\)\.", 'A', 'linger opp next (weaken n)')
def _(m, ctx):
    return Eff(('linger', OPP, ('next',), ('weaken', counters(m.group(1)))), {'perPokemon', 'benchMods'})


@rule('ling-expose-defending', r"During your next turn, the Defending Pokémon takes (\d+) more damage from attacks "
      r"\(after applying Weakness and Resistance\)\.", 'A', 'linger opp after (expose n)')
def _(m, ctx):
    return Eff(('linger', OPP, ('after',), ('expose', counters(m.group(1)))), {'perPokemon'})


@rule('ling-expose-self', r"During your opponent's next turn, this Pokémon takes (\d+) more damage from attacks "
      r"\(after applying Weakness and Resistance\)\.", 'A', 'linger own next (expose n)')
def _(m, ctx):
    return Eff(('linger', OWN, ('next',), ('expose', counters(m.group(1)))), {'perPokemon'})


# milestone MV6: "During your next turn, this Pokémon's X attack does N more damage (before applying Weakness and
# Resistance)." / "… X attack's base damage is N." (Pokemon/Defender.lean): the attack that prints it records its use
# (`Attack.selfLock := .note`) and X tests the record (`Test.usedLast .own`) and does N more (or N) in that branch.
# Per Pokémon: the record ends when the Pokémon moves to the Bench or evolves, as print says of effects of attacks
# (2026 pp. 11, 20). Written only when X is an attack of the same card with a positive printed damage (a plain number;
# for "does N more" also a printed "+"), the sentence stands alone in its attack, that attack has no lock sentence, and
# the card ends with at most one attack whose `selfLock` is not `none` (`Test.usedLast` reads the one record).
NOTE_RX = re.compile(r"^During your next turn, this Pokémon's (.+?) attack(?: does (\d+) more damage \(before applying "
                     r"Weakness and Resistance\)|'s base damage is (\d+))\.$")


# ------------------------------------------------------------------ damage trees

def amt_add(a, b):
    if a[0] == 'const' and b[0] == 'const':
        return ('const', a[1] + b[1])
    if a == ('const', 0):
        return b
    return ('add', a, b)


def tmap(tree, f):
    if tree[0] == 'L':
        return f(tree[1])
    if tree[0] == 'LS':
        return tattach(f(tree[1]), tree[2])
    if tree[0] == 'ite':
        return ('ite', tree[1], tmap(tree[2], f), tmap(tree[3], f))
    if tree[0] == 'choice':
        return ('choice', tmap(tree[1], f), tmap(tree[2], f))
    if tree[0] in ('T1', 'TM', 'T1X'):
        raise Refuse('computed damage to a chosen Pokémon')
    if tree[0] == 'S':
        raise Refuse('another damage change with damage to each Pokémon of a kind')
    if tree[0] == 'FU':
        raise Refuse('another damage change with "for each card you discarded in this way"')
    if tree[0] == 'MP':
        raise Refuse('another damage change with an optional cost of more damage')
    raise AssertionError(tree)


def tbranch(tests, neg, a, b):
    if neg:
        a, b = b, a
    out = b
    for t in reversed(tests):
        out = and_ite(t, a, out, lambda u, x, y: ('ite', u, x, y))
    return out


def tattach(tree, e):
    """The damage tree with the effect `e` after the damage step of every leaf (importer 0.13.0, `LS` leaves: the same
    coins decide the damage and an effect)."""
    if tree[0] == 'L':
        return ('LS', tree[1], e)
    if tree[0] == 'LS':
        return ('LS', tree[1], seq(tree[2], e))
    if tree[0] in ('ite', 'choice'):
        return (tree[0],) + tuple(tattach(x, e) if isinstance(x, tuple) and x and x[0] in ('L', 'LS', 'ite', 'choice')
                                  else x for x in tree[1:])
    raise Refuse('an effect decided with the damage on a damage tree of another kind')


def dmg(a, ig=None):
    """A damage step to the opponent's Active Pokémon; with `ig` (milestone MV3) the steps of the calculation it
    switches off (`Effect.damage a ig`; `{}` is the default and is not written)."""
    return ('damage', a, ig) if ig else ('damage', a)


def to_effect(tree, drain=False, ig=None):
    if ig and drain:
        raise Refuse('drain with a damage step that ignores Weakness, Resistance or effects')
    if tree[0] == 'L':
        return ('drain', tree[1]) if drain else dmg(tree[1], ig)
    if tree[0] == 'LS':
        return seq(to_effect(('L', tree[1]), drain, ig), tree[2])
    if tree[0] == 'S':
        # no damage step on this line of resolution (importer 0.9.0, 'eachF')
        if drain:
            raise Refuse('drain with damage to each Pokémon of a kind')
        return SKIP
    if tree[0] == 'T1':
        if drain:
            raise Refuse('drain with damage to a chosen Pokémon')
        n = tree[1]
        return one_of(OPP, dmg(('const', n), ig), ('benchDamage', OPP, n))
    if tree[0] == 'T1X':
        # importer 0.19.0 (milestone MV12): "N damage to 1 of your opponent's Pokémon for each X": the damage step with
        # the amount A, or attack damage of the amount H (computed on the chosen Benched Pokémon) to one Benched one
        if drain:
            raise Refuse('drain with damage to a chosen Pokémon')
        _, a, h = tree
        return one_of(OPP, dmg(a, ig), hit_by(OPP, 'bench', 1, ('any',), False, True, h))
    if tree[0] == 'TM':
        # milestone MV2: `Effect.hitSome m n`, unfolded
        if drain:
            raise Refuse('drain with damage to chosen Pokémon')
        _, k, n = tree
        return some_of(k, dmg(('const', n), ig), lambda j: ('benchSome', OPP, j, ('any',), True, n))
    if tree[0] == 'MP':
        # importer 0.18.0 (milestone MV11): decline (the base damage), or the Energy first and N more
        if drain:
            raise Refuse('drain with an optional cost of more damage')
        _, X, b, n = tree
        return choice(dmg(b, ig), seq(X, dmg(amt_add(b, ('const', n)), ig)))
    if tree[0] == 'FU':
        # milestone MV3: `Effect.forUpTo f n` unfolded as its definition reads (`forUpTo f 0 = f 0`,
        # `forUpTo f (n + 1) = choice (forUpTo f n) (f (n + 1))`), f i = seq (discard exactly i) (damage (b + k·i))
        if drain:
            raise Refuse('drain with "for each card you discarded in this way"')
        _, mk, n, k, b = tree
        f = lambda i: seq(mk(i), dmg(('const', b + k * i), ig))  # noqa: E731
        out = f(0)
        for i in range(1, n + 1):
            out = choice(out, f(i))
        return out
    if tree[0] == 'ite':
        return ite(tree[1], to_effect(tree[2], drain, ig), to_effect(tree[3], drain, ig))
    if tree[0] == 'choice':
        return choice(to_effect(tree[1], drain, ig), to_effect(tree[2], drain, ig))
    raise AssertionError(tree)


def amt_reads(a):
    if a[0] in ('per', 'count'):
        return True
    return any(amt_reads(x) for x in a[1:] if isinstance(x, tuple))


def tree_reads(tree):
    if tree[0] in ('L', 'LS'):
        return amt_reads(tree[1])
    if tree[0] == 'T1X':
        return True
    if tree[0] == 'ite':
        return True
    if tree[0] == 'choice':
        return tree_reads(tree[1]) or tree_reads(tree[2])
    return False


def test_reads_damage(e):
    """Does an effect test the damage on the opponent's Active Pokémon?"""
    if e[0] == 'ite':
        t = e[1]
        if t[0] in ('atLeast', 'exactly') and t[1] == OPP:
            return True
    return any(test_reads_damage(s) for s in T.subs(e))


def build_attack(base, suffix, items, cost):
    """Compose an attack's items into (damage field, effect, caveats)."""
    cavs = set()
    tree = None
    if suffix == '' and base:
        tree = ('L', ('const', base))
    elif suffix in ('+', '-'):
        tree = ('L', ('const', base))
    elif suffix == '×':
        tree = 'X'
    modified = False
    drain = False
    dmg_idx = None
    post = []          # (index, effect)
    pre = []           # effects printed "Before doing damage", resolved before the damage step
    wraps = []         # (index, wrap)
    ig = {}            # milestone MV3: the steps of the damage calculation the damage step switches off
    # importer 0.13.0: an effect printed before the attack's damage text (a sentence, or the first half of one, before the
    # first sentence that sets or changes the damage) is resolved before the damage step, in printed order, as the
    # rulebook's "effects that happen before damage" (2026 p. 20, step F). Before 0.13.0 only some shapes were (`pre`):
    # "Discard N Energy from this Pokémon, and …", damage to M chosen Pokémon; "Discard all Energy from this Pokémon[,.]
    # [and] this attack does N damage to 1 of …" was resolved after the damage step (four cards).
    first_dmg = next((k for k, (_, it) in enumerate(items) if isinstance(it, Dmg) and it.op not in ('ign', 'lastUse')),
                     None)
    for k, (idx, it) in enumerate(items):
        if isinstance(it, Eff) and (it.pre or (first_dmg is not None and k < first_dmg)):
            cavs |= it.cavs
            pre.append(it.e)
        elif isinstance(it, Eff):
            cavs |= it.cavs
            post.append((idx, it.e))
        elif isinstance(it, Dmg) and it.op == 'ign':
            cavs |= it.cavs
            ig.update(it.args[0])
        elif isinstance(it, Dmg):
            cavs |= it.cavs
            op, a = it.op, it.args
            if dmg_idx is None:
                dmg_idx = idx
            if op == 'set':
                amt, k = a
                if suffix != '×' or tree != 'X' or k != base:
                    raise Refuse('damage-for-each does not match the printed damage')
                tree = ('L', amt)
            elif op == 'add':
                if suffix != '+' or tree in (None, 'X'):
                    raise Refuse('more-damage sentence without a printed "+"')
                tree = tmap(tree, lambda x: ('L', amt_add(x, a[0])))
            elif op == 'sub':
                if suffix != '-' or tree in (None, 'X'):
                    raise Refuse('less-damage sentence without a printed "-"')
                tree = tmap(tree, lambda x: ('L', ('sub', x, a[0])))
            elif op == 'cond':
                tests, neg, n = a
                if suffix != '+' or tree in (None, 'X'):
                    raise Refuse('conditional damage without a printed "+"')
                tree = tmap(tree, lambda x: tbranch(tests, neg, ('L', amt_add(x, ('const', n))), ('L', x)))
            elif op == 'lastUse':
                # milestone MV6: N more when this Pokémon's record of the writing attack is in force (`Test.usedLast`)
                (n,) = a
                if tree in (None, 'X'):
                    raise Refuse('a bonus of a named attack on an attack with no printed damage')
                tree = tmap(tree, lambda x: tbranch([('usedLast', OWN)], False, ('L', amt_add(x, ('const', n))), ('L', x)))
                continue
            elif op == 'flipadd':
                (n,) = a
                if suffix != '+' or tree in (None, 'X'):
                    raise Refuse('coin-flip damage without a printed "+"')
                tree = tmap(tree, lambda x: ('choice', ('L', amt_add(x, ('const', n))), ('L', x)))
            elif op == 'coins':
                k, per, more = a
                if more:
                    if suffix != '+' or tree in (None, 'X'):
                        raise Refuse('coin damage without a printed "+"')
                    def alts(x):
                        out = ('L', amt_add(x, ('const', k * per)))
                        for h in range(k - 1, -1, -1):
                            out = ('choice', ('L', amt_add(x, ('const', h * per))), out)
                        return out
                    tree = tmap(tree, alts)
                else:
                    if suffix != '×' or tree != 'X' or per != base:
                        raise Refuse('coin damage does not match the printed damage')
                    out = ('L', ('const', k * per))
                    for h in range(k - 1, -1, -1):
                        out = ('choice', ('L', ('const', h * per)), out)
                    tree = out
            elif op == 'coinsx':
                # importer 0.13.0: "Flip k coins. [This attack does P (more) damage for each heads.] If <heads count>,
                # X. …": one choice over the number of heads h = 0..k, whose leaf has the damage of h heads and the
                # effects X of the conditions h satisfies (coin flips are nondeterministic choices, Known gaps)
                k, per, more, conds = a
                if per is not None and not more:
                    if suffix != '×' or tree != 'X' or per != base:
                        raise Refuse('coin damage does not match the printed damage')
                    start = ('L', ('const', 0))
                else:
                    if tree in (None, 'X'):
                        raise Refuse('coin conditions on an attack with no printed damage')
                    if (per is not None or any(isinstance(x, Dmg) for _, x in conds)) and suffix != '+':
                        raise Refuse('coin damage without a printed "+"')
                    start = tree
                for _, x in conds:
                    cavs |= x.cavs

                def alts(x, k=k, per=per, conds=conds):
                    leaves = []
                    for h in range(k + 1):
                        add = (h * per if per else 0) + sum(X.args[0][1] for hs, X in conds if h in hs and isinstance(X, Dmg))
                        effs = [X.e for hs, X in conds if h in hs and isinstance(X, Eff)]
                        amt = amt_add(x, ('const', add)) if add else x
                        leaves.append(('LS', amt, seq(*effs)) if effs else ('L', amt))
                    out = leaves[-1]
                    for lf in reversed(leaves[:-1]):
                        out = ('choice', lf, out)
                    return out
                tree = tmap(start, alts)
            elif op == 'many':
                per, more = a
                if more:
                    if suffix != '+' or tree in (None, 'X'):
                        raise Refuse('coin damage without a printed "+"')
                    tree = tmap(tree, lambda x: ('L', amt_add(x, ('many', ('const', per)))))
                else:
                    if suffix != '×' or tree != 'X' or per != base:
                        raise Refuse('coin damage does not match the printed damage')
                    tree = ('L', ('many', ('const', per)))
            elif op == 'target1':
                if tree is not None:
                    raise Refuse('damage to a chosen Pokémon with a printed base damage')
                tree = ('T1', a[0])
            elif op == 'target1x':
                if tree is not None:
                    raise Refuse('damage to a chosen Pokémon with a printed base damage')
                tree = ('T1X', a[0], a[1])
            elif op == 'eachHurt':
                # importer 0.19.0 (milestone MV12): "N damage to each Pokémon that has any damage counters on it (both
                # yours and your opponent's), except for this Pokémon": the damage step on the opponent's Active Pokémon
                # if it has a damage counter (else no damage step), attack damage N to every Benched Pokémon of both
                # players that has one (`hitBy … 5 any true true`)
                if tree is not None:
                    raise Refuse('damage to each damaged Pokémon with a printed base damage')
                (n,) = a
                tree = ('ite', ('atLeast', OPP, 1), ('L', ('const', n)), ('S',))
                post.append((idx, hit_by(OPP, 'bench', BENCH_ALL, ('any',), True, True, ('const', n))))
                post.append((idx, hit_by(OWN, 'bench', BENCH_ALL, ('any',), True, True, ('const', n))))
            elif op == 'targetM':
                if tree is not None:
                    raise Refuse('damage to chosen Pokémon with a printed base damage')
                tree = ('TM', a[0], a[1])
                # the choice reads the size of the opponent's Bench: an effect printed before it must not act on
                # the opponent (the model resolves printed-earlier effects after the damage step)
                if any(any(x[1:2] == (OPP,) or x[0] in ('switch', 'counters', 'inflict', 'scale') for x in T.prims(e))
                       for i, e in post):
                    raise Refuse('an effect on the opponent printed before damage to chosen Pokémon')
                # effects printed before it (an Energy discard from this Pokémon) are resolved before it, as printed
                pre += [e for i, e in post]
                post = []
            elif op == 'forUpTo':
                mk, n, k, more = a
                if more:
                    if suffix != '+' or tree in (None, 'X') or tree[0] != 'L' or tree[1][0] != 'const':
                        raise Refuse('"more damage for each card you discarded" without a printed "+"')
                    tree = ('FU', mk, n, k, tree[1][1])
                else:
                    if suffix != '×' or tree != 'X' or k != base:
                        raise Refuse('"damage for each card you discarded" does not match the printed damage')
                    tree = ('FU', mk, n, k, 0)
            elif op == 'mayPre':
                # importer 0.18.0 (milestone MV11): the optional Energy cost of N more damage, before the damage step
                X, n = a
                if suffix != '+' or tree is None or tree == 'X' or tree[0] != 'L':
                    raise Refuse('an optional cost of more damage without a printed "+"')
                tree = ('MP', X, tree[1], n)
            elif op == 'afterGust':
                if tree is not None:
                    raise Refuse('damage to the new Active Pokémon with a printed base damage')
                tree = ('ite', ('countGe', ('bench', OPP, ('pokemon',)), 1), ('L', ('const', a[0])), ('S',))
            elif op == 'eachF':
                # importer 0.9.0: "N damage to each of your opponent's Pokémon ex": the damage step on the opponent's
                # Active Pokémon if its card passes F (else no damage step), and attack damage N to every Benched
                # Pokémon passing F (`benchSome` with m = 5 = `benchLimit`, which takes all that pass)
                if tree is not None:
                    raise Refuse('damage to each Pokémon of a kind with a printed base damage')
                n, f = a
                tree = ('ite', ('top', OPP, f), ('L', ('const', n)), ('S',))
                post.append((idx, ('benchSome', OPP, 5, f, True, n)))
            elif op == 'each':
                if tree is not None:
                    raise Refuse('damage to each Pokémon with a printed base damage')
                tree = ('L', ('const', a[0]))
                post.append((idx, ('spreadDamage', OPP, a[0])))
            else:
                raise AssertionError(op)
            modified = True
        elif isinstance(it, Drain):
            drain = True
        elif isinstance(it, tuple) and it[0] in ('wrapFlip', 'wrapIf', 'wrapFn'):
            wraps.append((idx, it))
        elif isinstance(it, Cost):
            raise Refuse('a Trainer cost in an attack')
        else:
            raise Refuse('item not expressible in an attack')
    if tree == 'X':
        raise Refuse('printed "×" damage with no recognized amount')
    if suffix in ('+', '-') and not modified:
        raise Refuse('printed "%s" damage with no recognized amount' % suffix)
    if tree is not None and tree_reads(tree) and dmg_idx is not None and any(i < dmg_idx for i, _ in post):
        raise Refuse('an effect printed before damage that reads the state')
    if tree is not None and tree[0] == 'MP' and any(i < dmg_idx for i, _ in post):
        raise Refuse('an effect printed before an optional cost of more damage')
    if tree is not None and tree[0] == 'FU' and any(i < dmg_idx for i, _ in post):
        # the discard of each branch resolves with the damage step; an effect printed before it would follow it
        raise Refuse('an effect printed before "discard …, and this attack does … for each card discarded"')
    if ig and tree is None:
        raise Refuse("'This attack's damage isn't affected by …' on an attack with no damage step")
    if tree is not None and any(test_reads_damage(e) for _, e in post):
        raise Refuse('an effect after the damage tests the damage on the opponent\'s Active Pokémon')
    if drain and tree is None:
        raise Refuse('drain with no damage')
    # Poison strength must follow the Poison it strengthens
    effs = [e for _, e in post]
    plain = tree is not None and tree == ('L', ('const', base)) and not drain and not wraps and base and not ig
    if plain:
        damage, eff = base, seq(*effs)
    else:
        damage = 0
        eff = seq(to_effect(tree, drain, ig) if tree is not None else SKIP, *effs)
    if pre:
        # the printed order: these effects, then the damage step (`Attack.script` puts the printed base
        # damage first, so it becomes an explicit damage step after them)
        if damage:
            eff, damage = seq(*pre, ('damage', ('const', damage)), eff), 0
        else:
            eff = seq(*pre, eff)
    for _, w in wraps:
        if w[0] == 'wrapFlip':
            if damage:
                eff, damage = seq(('damage', ('const', damage)), eff), 0
            eff = choice(eff, SKIP)
        elif w[0] == 'wrapFn':
            if damage:
                eff, damage = seq(('damage', ('const', damage)), eff), 0
            eff = w[1](eff)
        else:
            _, tests, neg = w
            if damage:
                eff, damage = seq(('damage', ('const', damage)), eff), 0
            eff = branch(tests, neg, SKIP, eff)
    return damage, eff, cavs


# ------------------------------------------------------------------ cards

EX_RULES = ['Pokémon ex rule: When your Pokémon ex is Knocked Out, your opponent takes 2 Prize cards.',
            'When your Pokémon ex is Knocked Out, your opponent takes 2 Prize cards.']
MEGA_RULES = ['Mega Evolution ex Rule: When your Mega Evolution Pokémon ex is Knocked Out, your opponent takes 3 Prize cards.']
# The rule-box lines a card of each kind may print, and the line it must print (the one that gives
# its Prize count: for a Mega Evolution Pokémon ex the Mega rule, S9 and Pokemon/Card.lean `RuleBox`).
RULEBOX_TEXT = {'ex': EX_RULES, 'megaEx': MEGA_RULES + EX_RULES}
RULEBOX_REQUIRED = {'ex': EX_RULES, 'megaEx': MEGA_RULES}
TERA_TEXTS = ["Tera: As long as this Pokémon is on your Bench, prevent all damage done to this Pokémon by attacks "
              "(both yours and your opponent's).",
              "As long as this Pokémon is on your Bench, prevent all damage done to this Pokémon by attacks "
              "(both yours and your opponent's)."]

PLAY_REMINDERS = (
    'You may play any number of Item cards during your turn.',
    'You may play only 1 Supporter card during your turn.',
    'You may play only 1 Supporter card during your turn (before your attack).',
)
ACE_LINES = ("ACE SPEC: You can't have more than 1 ACE SPEC card in your deck.",
             "You can't have more than 1 ACE SPEC card in your deck.")


def norm(s):
    return (s or '').replace('’', "'").replace('‘', "'").strip()


def json_text(c):
    """All printed text of a card record, joined (abilities, attacks, rules)."""
    parts = [a.get('text') or '' for a in c.get('abilities') or []]
    parts += [a.get('text') or '' for a in c.get('attacks') or []]
    parts += list(c.get('rules') or [])
    return norm(' '.join(parts))


def translate_card(c):
    """Translate a card record (`_translate_card`), then add the caveat `abilityByTool` to every imported term that
    reads `Filter.hasAbility` (wherever it occurs: a count, a test, a static prevention)."""
    res = _translate_card(c)
    if res['ok'] and 'hasAbility' in repr(res['term']):
        res['caveats'].add('abilityByTool')
    if res['ok'] and 'prizesTaken' in repr(res['term']):
        res['caveats'].add('prizes6')
    if res['ok'] and re.search(r'maximum HP of \d+', json_text(c)):
        res['caveats'].add('printedMaxHP')
    if res['ok'] and "('retreat', (" in repr(res['term']):
        if re.search(r"'(retreatPlus|retreatMinus)'", repr(res['term'])):
            # the card's own static effect changes the Retreat Cost its count reads: the printed count would be off by
            # that effect whenever the card is in play (Ariados sv6-5, Mega Chandelure ex me5-38)
            res['ok'] = False
            res['term'] = None
            res['blockers'].append(("count of the Retreat Cost on a card whose own static effect changes it "
                                    "(Count.retreat reads the printed cost)", ''))
            return res
        res['caveats'].add('printedRetreat')
    if res['ok'] and has_look_opp_bench(res['term']):
        res['caveats'].add('oppBenchFresh')
    if res['ok']:
        res['caveats'] |= energy_caveats(res['term'], c)
    return res


# ------------------------------------------------------------------ Energy readers since milestone MV8 (importer 0.15.0)
#
# Since importer 0.15.0 Special Energy cards are imported, so the readers of attached Energy that read Basic Energy
# cards only, or count Energy where print may count cards, are no longer vacuous in a game of imported cards (until
# 0.14.0 they were: no imported card was a Special Energy card). Every imported Special Energy card provides some type
# (Growing Grass G, Voltaic Lightning L, Magnetic Metal M, Spiky C, Team Rocket's P/D, Prism, Neo Upper and Luminous
# every type). The term walk below finds, wherever the term reads Energy attached to a Pokémon (Pokemon/Rules.lean,
# Known gaps, Energy item):
# * `Filter.energyOf t` chosen by `discardEnergy` (but not `all`), `moveEnergy`, `SelfOp.energyTo`: caveat energyOfBasic
#   (forbids some), unless every mention of that type's Energy in the card's text says "Basic" (or is a card in a zone, "…
#   Energy card", which the glossary makes a Basic Energy card);
# * `Filter.energyOf t` in a count or test (`Count.energy`, `Count.energyAll`), in a static count (`SAmt.perEnergy`,
#   `Static.need`), or in "discard all [T] Energy" (`discardEnergy … all`): caveat energyOfCount (both), with the same
#   exception;
# and, under `Filter.energy`, the places where the model counts Energy provided (units) or cards where print may count
# the other (readings, no rule found: the 2026 rulebook never mentions Special Energy; fix round of importer 0.15.0):
# * "for each Energy attached" (`Amt.count` of `Count.energy` / `Count.energyAll`) and a test of at least N ≥ 2 Energy
#   (`countGe`): units; caveat energyUnitsCount (both). A test of at least 1 agrees with a count of cards, since every
#   imported Energy card provides at least 1;
# * `discardEnergy … (Filter.energy)` of a fixed number N ≥ 2 (`exactly`, `upTo`, `most`): units; caveat discardUnits
#   (both). For N = 1 the two readings agree;
# * an unfolded `forUpTo` over `discardEnergy … (Filter.energy) (exactly j)` (its branch 0 is `exactly 0`): caveat
#   forUpToUnits (both), or forAllUnits (both) when every Energy must be discarded ("discard all");
# * `SAmt.perEnergy` / `Static.need` (at least 2) under `Filter.energy`: cards where print may mean Energy; caveat
#   staticCardCount (both).
# The holder rule (`MULTI_UNIT`): the unit and card readings differ only on a Pokémon that holds a card providing 2 or
# more units. In the imported pool these are exactly Team Rocket's Energy (2 units, attachable only to a Pokémon whose
# top card is named "Team Rocket's …", `EnergyText.only`) and Neo Upper Energy (2 units when the holder's top card is a
# Stage 2 Pokémon, `ProvIf.holder (stage stage2)`): `EnergyCard.unitsAt` reads the holder's top card at the moment of the
# read, so for a self-read ("this Pokémon" in an attack, or a static on itself) the holder is the card being read. On
# any other holder every card weighs 1 and the two readings agree (`Qty.okE_ones`, `retreatPaid_ones`). So the four
# unit caveats are written only when the Pokémon read can be a Stage 2 Pokémon or a Team Rocket's Pokémon: for a
# self-read, when the card itself is one; for any other read (the opponent's Pokémon, "your Active Pokémon" from a
# Trainer or an Ability, a Tool's or Special Energy card's holder, moves between Pokémon), always. The rule rests on the
# pool: `importer.check_multi_unit` fails loudly if another imported Special Energy card can provide 2 units, if either
# condition above changes, or if an imported Pokémon evolves from a Team Rocket's Pokémon without being one (a Team
# Rocket's Energy left on a non-Team-Rocket's holder; the model does not discard it at evolution).
MULTI_UNIT = {"Team Rocket's Energy": ('only', ('and', ('pokemon',), ('namePrefix', "Team Rocket's "))),
              'Neo Upper Energy': ('alt', ('holder', ('stage', ('stage2',))))}

TYPE_WORD = {v: k for k, v in T.TYPES.items()}


def _is_energy_count(c):
    return isinstance(c, tuple) and len(c) == 3 and c[0] in ('energy', 'energyAll') and c[1] in (OWN, OPP)


def _energy_reads(x, out, ctx='any'):
    """Collect (kind, filter, qty, who) for every read of attached Energy in a term (tuples, lists, dicts). `who` is
    'self' when the Pokémon read is the card itself (`ctx = 'self'`: an attack's own Active Pokémon, a static on
    `Sel.self`), else 'any'."""
    if isinstance(x, dict):
        if 'need' in x and 'eff' in x:
            who = 'self' if ctx == 'self' and x['sel'] == ('self',) else 'any'
            if x['need'] is not None:
                out.append(('static', x['need'][1][1], ('exactly', x['need'][1][2]), who))
            e = x['eff']
            if e[0] == 'hpPlus' and e[1][0] == 'perEnergy':
                out.append(('static', e[1][1], None, who))
        for v in x.values():
            _energy_reads(v, out, ctx)
        return
    if isinstance(x, list):
        for v in x:
            _energy_reads(v, out, ctx)
        return
    if not isinstance(x, tuple) or not x:
        return
    h = x[0]
    def who_c(c):
        return 'self' if ctx == 'self' and c[0] == 'energy' and c[1] == OWN else 'any'
    if h == 'discardEnergy' and len(x) == 5:
        out.append(('select', x[3], x[4], 'self' if ctx == 'self' and x[1] == OWN and x[2] == ('active',) else 'any'))
    elif h == 'returnEnergy' and len(x) == 6:
        # importer 0.18.0: the take of `discardEnergy`, read the same way (units: moveUnits, not discardUnits)
        out.append(('selectMove', x[3], x[4], 'self' if ctx == 'self' and x[1] == OWN and x[2] == ('active',) else 'any'))
    elif h == 'shiftEnergy' and len(x) == 7:
        out.append(('selectMove', x[3], x[4], 'self' if ctx == 'self' and x[1] == OWN and x[2] == ('active',) else 'any'))
    elif h == 'moveEnergy' and len(x) == 3:
        out.append(('select', x[2], None, 'any'))
    elif h == 'energyTo' and len(x) == 2:
        out.append(('select', x[1], None, 'any'))
    elif h == 'countGe' and len(x) == 3 and _is_energy_count(x[1]):
        out.append(('test', x[1][2], x[2], who_c(x[1])))
        return
    elif h == 'count' and len(x) == 3 and _is_energy_count(x[1]):
        # an amount "K for each … Energy attached" (`Amt.count`)
        out.append(('amount', x[1][2], None, who_c(x[1])))
        return
    elif _is_energy_count(x):
        out.append(('count', x[2], None, who_c(x)))
        return
    for v in x[1:]:
        _energy_reads(v, out, ctx)


def _filter_types(f):
    if not isinstance(f, tuple):
        return set()
    if f and f[0] == 'energyOf':
        return {f[1][0]}
    out = set()
    for y in f[1:]:
        out |= _filter_types(y)
    return out


def card_text(c):
    parts = [a.get('text') or '' for a in (c.get('attacks') or []) + (c.get('abilities') or [])]
    parts += c.get('rules') or []
    return ' '.join(norm(p) for p in parts)


def self_multi(term):
    """Can the card itself, as the holder's top card, hold a card that provides 2 units (`MULTI_UNIT`)?"""
    if term[0] != 'pokemon':
        return True
    p = term[1]
    return p['stage'] == ('stage2',) or p['name'].startswith("Team Rocket's ")


def _roots(term):
    """(effect or part, ctx) pairs: a Pokémon card's attacks and its own statics read the card itself; everything else
    (Abilities' scripts and conditions, Trainers, a Tool's or Special Energy card's grant) reads some Pokémon."""
    if term[0] == 'pokemon':
        p = term[1]
        out = [(a['effect'], 'self') for a in p['attacks']]
        for ab in p['abilities']:
            if ab['use'][0] == 'static':
                out.append((list(ab['use'][1]), 'self'))
                rest = dict(ab)
                rest['use'] = ('static', [])
                out.append((rest, 'any'))
            else:
                out.append((ab, 'any'))
        return out
    return [(term, 'any')]


def energy_caveats(term, c):
    cv = set()
    text = card_text(c)
    multi = self_multi(term)
    unit = lambda who: who == 'any' or multi  # noqa: E731
    for root, ctx in _roots(term):
        reads = []
        _energy_reads(root, reads, ctx)
        fu = ctx == 'self' and any(k == 'select' and f == ENERGY_F and q == ('exactly', 0) for k, f, q, _ in reads)
        if fu and unit('self'):
            cv.add('forAllUnits' if _has_all_guard(root) else 'forUpToUnits')
        # the guard `countGe (energy w energy) n` written with "discard n Energy" (`min_take`) is that discard's own
        # reading (discardUnits), not a separate count
        guards = {(q[1], who) for k, f, q, who in reads if k in ('select', 'selectMove') and f == ENERGY_F and q and
                  q[0] == 'exactly'}
        for kind, f, q, who in reads:
            if kind == 'test' and (q, who) in guards:
                kind = 'guard'
            for t in _filter_types(f):
                w = TYPE_WORD[t]
                if re.search(r'(?<!Basic )\b' + w + r' Energy\b(?! cards?\b)', text):
                    # "discard all [T] Energy" leaves the Special Energy card attached: one different outcome, not fewer
                    cv.add('energyOfBasic' if kind in ('select', 'selectMove') and q != ('all',) else 'energyOfCount')
            if kind == 'amount' and (f == SPECIAL_F or (f[0] == 'named' and KNOWN_NAMES.get(f[1]) == {'Special Energy'})) \
                    and re.search(r'for each Special Energy (?!card)', text):
                cv.add('specialCountCards')
            if f != ENERGY_F or not unit(who):
                continue
            if kind == 'static' and (q is None or q[1] >= 2):
                cv.add('staticCardCount')
            if kind == 'amount' or (kind == 'test' and q >= 2):
                cv.add('energyUnitsCount')
            if kind == 'select' and not fu and q is not None and q[0] in ('exactly', 'upTo', 'most') and q[1] >= 2:
                cv.add('discardUnits')
            # "any amount" is `upTo 60` (anyAmount60), a bound no reading of units against cards changes
            if kind == 'selectMove' and q is not None and q[0] in ('exactly', 'upTo', 'most') and q[1] >= 2 and \
                    q != ('upTo', 60):
                cv.add('moveUnits')
    return cv


def _has_all_guard(e):
    """The guard of "discard all …; K for each card discarded" (`ite (countGe (energy own f) 1) NO_PLAY skip`)."""
    if isinstance(e, tuple) and e and e[0] == 'ite' and e[2] == NO_PLAY and e[3] == SKIP and \
            e[1] == ('countGe', ('energy', OWN, ENERGY_F), 1):
        return True
    return isinstance(e, tuple) and any(_has_all_guard(y) for y in e[1:] if isinstance(y, tuple))


def has_look_opp_bench(x):
    if isinstance(x, tuple):
        if x and x[0] == 'look' and len(x) == 7 and x[1] == OPP and x[5] == ('bench',):
            return True
        return any(has_look_opp_bench(y) for y in x)
    if isinstance(x, (list,)):
        return any(has_look_opp_bench(y) for y in x)
    if isinstance(x, dict):
        return any(has_look_opp_bench(y) for y in x.values())
    return False


def _translate_card(c):
    """Translate a card record. Returns a dict with keys: ok (bool), term (Lean-ready Python term),
    caveats (set), blockers (list of (reason, sentence)), used (list of (rule, sentence))."""
    res = {'ok': False, 'term': None, 'caveats': set(), 'blockers': [], 'used': []}
    sup = c['supertype']
    sub = c['_sub']
    B = res['blockers']
    if sup == 'Energy':
        if 'Basic' in sub:
            t = c['name'].replace('Basic ', '').replace(' Energy', '')
            if t not in T.BASIC_ENERGY:
                B.append(('Basic Energy of an unknown type', c['name']))
            else:
                res['term'] = ('energy', (T.BASIC_ENERGY[t],))
        else:
            return translate_special_energy(c, res)
        res['ok'] = not B
        return res
    if sup == 'Trainer':
        return translate_trainer(c, res)
    return translate_pokemon(c, res)


# ------------------------------------------------------------------ Special Energy cards (milestone MV8, importer 0.15.0)
#
# `EnergyCard.special name prov text` (Pokemon/Card.lean; survey S22): `prov` is the printed provision ("As long as
# this card is attached to a Pokémon, it provides …"), one entry per unit, each the types that unit counts as; `text`
# (`EnergyText`) carries the riders the model expresses: `grant` (the Tool path: static effects and triggered
# Abilities for a holder filter), `alt` (provision that depends on the holder, or on another Special Energy card
# attached) and `only` (a holder restriction). A payload is written only when every rider of the card is expressed
# (rule 1 of the MV8 import): a card with a rider the model lacks (an on-attach effect, an end-of-turn discard, a return
# after a discard, prevention of effects, Special Condition immunity, Bench damage prevention, a Prize change) is
# refused, naming that rider; the importer never writes `EnergyText.rest` or an empty payload, because it never
# imports an inert card (`Card.inert`, `cards_notInert`).
SE_ALL = [('grass',), ('fire',), ('water',), ('lightning',), ('psychic',), ('fighting',), ('darkness',), ('metal',),
          ('fairy',), ('dragon',), ('colorless',)]
SE_PROV = re.compile(r'^As long as this card is attached to a Pokémon, it provides (.+?)\.$')
SE_EVERY = re.compile(r'^every type of Energy but provides only (\d) Energy at a time$')
SE_ALT_HOLDER = re.compile(r'^If this card is attached to an? (Basic|Stage 2|Evolution) Pokémon, (?:this card|it) provides '
                           r'(.+?)(?: instead)?\.$')
SE_ALT_OTHER = 'If the Pokémon this card is attached to has any other Special Energy attached, this card provides Colorless ' \
               'Energy instead.'
SE_ONLY = re.compile(r'^This card can only be attached to an? (.+?)\.$')
SE_ONLY_DISCARD = re.compile(r'^If this card is attached to anything other than an? (.+?), discard this card\.$')
# riders the model does not express, by kind (S22 §1): the card stays refused
SE_INERT = [
    (r'^When you attach this card', 'on-attach effect (stage 4 of MV8, not done)'),
    (r'at the end of your turn', 'end-of-turn discard (stage 4 of MV8, not done)'),
    (r'If this card is discarded by an effect of an attack', 'return after a discard by the holder\'s attack (no machinery)'),
    (r'Special Conditions', 'Special Condition recovery and immunity (no static form)'),
    # importer 0.20.0 (milestone MV13): "As long as the X this card is attached to is on your Bench, prevent all damage
    # done to it by attacks from your opponent's Pokémon" is now read (`static_tool_sentence`; Shadowy Darkness Energy)
    (r'Prize card', 'a Prize change on Knock Out, once per game (absent)'),
]


def se_units(s):
    """A provision phrase to the units of `EnergyCard.special` (None if not one the model has)."""
    m = re.match(r'^((?:' + TYPE_RE + r')+) Energy$', s)
    if m:
        ws = re.findall(TYPE_RE, m.group(1))
        return [[etype(w)] for w in ws]
    m = SE_EVERY.match(s)
    if m:
        return [list(SE_ALL) for _ in range(int(m.group(1)))]
    m = re.match(r'^(\d) in any combination of ' + TYPE_RE + r' Energy and ' + TYPE_RE + r' Energy$', s)
    if m:
        return [[etype(m.group(2)), etype(m.group(3))] for _ in range(int(m.group(1)))]
    return None


def translate_special_energy(c, res):
    B = res['blockers']
    name = c['name']
    head = 'Special Energy: '
    if 'ACE SPEC' in c['_sub']:
        res['caveats'].add('aceSpec')
    sents = []
    for r in c.get('rules') or []:
        r = norm(r)
        if r in ACE_LINES:
            continue
        sents += split_sentences(' '.join(r.split()))
    for rx, why in SE_INERT:
        hit = [s for s in sents if re.search(rx, s)]
        if hit:
            B.append((head + 'rider not modelled: ' + why, hit[0]))
    if c.get('attacks') or c.get('abilities'):
        B.append((head + 'printed attack or Ability on the card', ''))
    if B:
        return res
    prov, alt, only, grant_sents = None, None, None, []
    ctx = {'kind': 'trainer', 'name': name, 'base': None, 'cost': None}
    try:
        i = 0
        while i < len(sents):
            s = sents[i]
            m = SE_PROV.match(s)
            if m:
                if prov is not None:
                    raise Refuse(head + 'two provision sentences', s)
                prov = se_units(m.group(1))
                if prov is None:
                    raise Refuse(head + 'provision not expressible', s)
                res['used'].append(('se-provides', s))
            elif SE_ALT_HOLDER.match(s):
                m = SE_ALT_HOLDER.match(s)
                u = se_units(m.group(2))
                if u is None or alt is not None:
                    raise Refuse(head + 'alternative provision not expressible', s)
                f = {'Basic': ('basic',), 'Stage 2': ('stage', ('stage2',)), 'Evolution': ('not', ('basic',))}[m.group(1)]
                alt = ('some', ('pair', ('holder', f), u))
                res['used'].append(('se-alt-holder', s))
            elif s == SE_ALT_OTHER:
                if alt is not None:
                    raise Refuse(head + 'two alternative provisions', s)
                alt = ('some', ('pair', ('otherSpecial',), [[('colorless',)]]))
                res['used'].append(('se-alt-other', s))
            elif SE_ONLY.match(s):
                m = SE_ONLY.match(s)
                f = parse_filter(m.group(1), ctx)
                if not pokemon_only(f) and not (f[0] == 'and' and f[1] == ('pokemon',)):
                    raise Refuse(head + 'holder restriction not a filter on Pokémon', s)
                nxt = sents[i + 1] if i + 1 < len(sents) else ''
                m2 = SE_ONLY_DISCARD.match(nxt)
                if not m2 or m2.group(1) != m.group(1):
                    raise Refuse(head + 'holder restriction without its discard rule', s)
                only = f
                res['caveats'].add('rocketMove')
                res['used'].append(('se-only', s + ' ' + nxt))
                i += 1
            else:
                grant_sents.append(s)
            i += 1
        if prov is None:
            raise Refuse(head + 'no provision sentence', ' '.join(sents))
        grant = None
        if grant_sents:
            joined = ' '.join(grant_sents)
            if trig_shape(joined):
                r = translate_trigger(c, joined, res, tool=True)
                if r is None:
                    # translate_trigger recorded the reason (with the head 'Pokémon Tool: ')
                    B[:] = [(head + a[len('Pokémon Tool: '):] if a.startswith('Pokémon Tool: ') else a, b) for a, b in B]
                    return res
                ab, holder = r
                ab['name'] = name
                grant = {'holder': holder, 'attacks': [], 'abilities': [ab]}
            else:
                try:
                    holder, ss = parse_static(grant_sents, 'tool', ctx)
                except Refuse as r:
                    raise Refuse(head + 'rider not expressible: ' + STATIC_DESC.get(r.reason, r.reason), joined)
                res['caveats'] |= static_caveats(ss)
                if any(x['eff'] == ('noRetreat',) for x in ss):
                    res['caveats'].add('noRetreatLast')
                grant = {'holder': holder, 'attacks': [], 'abilities': [], 'statics': ss}
                res['used'].append(('se-static', joined))
    except Refuse as r:
        B.append((r.reason, r.sentence))
        return res
    units = [prov] + ([alt[1][2]] if alt else [])
    if any(len(u) > 1 for u in units):
        # a card that provides 2 Energy (Team Rocket's Energy; Neo Upper Energy on a Stage 2 Pokémon)
        res['caveats'].add('unitsReading')
    text = {}
    if grant is not None:
        text['grant'] = grant
    if alt is not None:
        text['alt'] = alt
    if only is not None:
        text['only'] = only
    if not text:
        B.append((head + 'no rider: the payload would be empty (`Card.inert`)', ' '.join(sents)))
        return res
    res['term'] = ('energy', ('special', name, prov, text))
    res['ok'] = True
    return res


def translate_trainer(c, res):
    sub = c['_sub']
    B = res['blockers']
    name = c['name']
    if 'Pokémon Tool' in sub or 'Stadium' in sub:
        return translate_tool_stadium(c, res)
    if c.get('hp') or any('Play this card as if it were' in norm(r) for r in c.get('rules') or []):
        B.append(('Trainer played as a Pokémon', ''))
    if c.get('abilities'):
        B.append(('Ability', ''))
    kind = 'item' if 'Item' in sub else 'supporter' if 'Supporter' in sub else None
    if kind is None and not B:
        B.append(('Trainer kind not modelled', ','.join(sorted(sub))))
    if 'ACE SPEC' in sub:
        res['caveats'].add('aceSpec')
    sents = []
    for r in c.get('rules') or []:
        r = norm(r)
        if r in PLAY_REMINDERS or r in ACE_LINES:
            continue
        sents += split_sentences(r)
    if B:
        # still parse, to record unhandled sentences of Tools and Stadiums too
        pass
    ctx = {'kind': 'trainer', 'name': name, 'base': None, 'cost': None}
    p = Parser(ctx).run(sents)
    res['used'] += p.used
    B += p.blockers
    if B:
        return res
    costs = [it.e for _, it in p.items if isinstance(it, Cost)]
    for _, it in p.items:
        if isinstance(it, Cost):
            res['caveats'] |= it.cavs
    effs = []
    for _, it in p.items:
        if isinstance(it, Cost):
            continue
        if not isinstance(it, Eff):
            B.append(('not a plain effect in a Trainer', ''))
            return res
        res['caveats'] |= it.cavs
        effs.append(it.e)
    if sents:
        effs = [no_effect_trainer(seq(*effs), ' '.join(sents), res['caveats'])]
    e = seq(*costs, *effs)
    if not sents:
        B.append(('Trainer with no text', ''))
        return res
    if not (T.hit_free(e) and T.bench_hit_free(e)):
        B.append(('Trainer effect with attack damage', ''))
        return res
    term = ('trainer', name, (kind,), e)
    # self-recycling and self-counting (the card is in the discard pile while it resolves)
    if any(T.filter_eval(f, term) for f in T.rec_filters(e)) or reads_own_discard(e, term):
        res['caveats'].add('selfInDiscard')
    if counters_then_more(e):
        res['caveats'].add('koBetweenSteps')
    res['caveats'].discard('_needsPoison')
    res['term'] = term
    res['ok'] = True
    return res


# ------------------------------------------------------------------ Stadiums and Tools (milestone M5)
#
# The model plays every Stadium and Tool, and one whose effect it does not express is a card with no
# effect (`Card.inert`: a Stadium whose effect is `skip`, a Tool that gives nothing). Such a term says
# less than its printed card, so it is never written: a Stadium is imported only if its whole text is
# an activated once-per-turn effect ("Once during each player's turn, that player may …") that
# translates by the rules for Trainers, and a Tool only if its whole text gives attacks that translate
# by the rules for attacks. Everything else is refused with a reason that starts with 'Stadium: ' or
# 'Pokémon Tool: ' and names the kind of text.

# The printed reminders of the play rules, which `Move.stadium`, `Move.tool` and `Move.toolBench`
# express (one Stadium per turn, not one of the same name, the old one discarded; any number of Tools,
# one per Pokémon, staying attached).
STADIUM_REMINDERS = (
    'You may play only 1 Stadium card during your turn. Put it next to the Active Spot, and discard it if '
    'another Stadium comes into play. A Stadium with the same name can\'t be played.',
    # the same reminder with "into" for "next to" (records of sv5, sv6 and sv8); the same rule
    'You may play only 1 Stadium card during your turn. Put it into the Active Spot, and discard it if '
    'another Stadium comes into play. A Stadium with the same name can\'t be played.',
)
TOOL_REMINDERS = (
    'You may attach any number of Pokémon Tools to your Pokémon during your turn. You may attach only 1 '
    'Pokémon Tool to each Pokémon, and it stays attached.',
    "Attach a Pokémon Tool to 1 of your Pokémon that doesn't already have a Pokémon Tool attached.",
)

# Static and triggered text, by kind (first match wins; the kinds of the model's Known gaps).
STATIC_KINDS = [
    ('Bench size', r'on their Bench'),
    ('Ability lock', r'have no Abilities'),
    ('Tool lock', r'Pokémon Tools attached .* have no effect'),
    ('Pokémon Checkup', r'Pokémon Checkup'),
    ('triggered (Knock Out, damage, end of turn, Bench placement, healing)',
     r'Knocked Out|is damaged by|[Ww]henever|[Aa]t the end of your turn|takes \d+ or more damage'),
    ('HP', r'[+-]\d+ HP'),
    ('damage bonus', r'more damage(?! counters)'),
    ('damage reduction or prevention', r'less damage|[Pp]revent all damage'),
    ('Retreat Cost', r'Retreat Cost'),
    ('attack cost', r'cost Colorless|costs \d+ Energy'),
    ('Special Conditions', r'Special Condition|Confused'),
    ('evolution timing', r'evolve'),
    ('coin re-flip', r'coin flips'),
]


def static_kind(text):
    for k, rx in STATIC_KINDS:
        if re.search(rx, text):
            return k
    return None


def translate_tool_stadium(c, res):
    sub = c['_sub']
    B = res['blockers']
    name = c['name']
    tool = 'Pokémon Tool' in sub
    head = 'Pokémon Tool: ' if tool else 'Stadium: '
    if 'ACE SPEC' in sub:
        res['caveats'].add('aceSpec')
    lines = [norm(r) for r in c.get('rules') or []]
    text = [r for r in lines if r not in ACE_LINES and r not in (TOOL_REMINDERS if tool else STADIUM_REMINDERS)]
    joined = ' '.join(text)
    if 'Pokémon Tool' in sub and 'Stadium' in sub:
        B.append(('Pokémon Tool and Stadium both', ''))
        return res
    if c.get('abilities'):
        B.append((head + 'gives an Ability (no rule; none in the pool)', joined))
        return res
    if tool:
        return translate_tool(c, res, text, joined)
    return translate_stadium(c, res, text, joined)


GRANT_RE = re.compile(r'^The (.+?) this card is attached to can use the attack on this card\.$')
GRANT_REMINDER = '(You still need the necessary Energy to use this attack.)'


def translate_tool(c, res, text, joined):
    """A Tool is imported only if its whole text gives its printed attack to a holder the model can
    name (`ToolGrant`: holder filter, attacks, no Abilities)."""
    B = res['blockers']
    sub = c['_sub']
    sents = [x for r in text for x in split_sentences(r)]
    grants = [x for x in sents if GRANT_RE.match(x)]
    if not sents:
        B.append(('Pokémon Tool: no text', ''))
        return res
    if not grants and trig_shape(joined):
        # triggered text of the two shapes of milestone M8b: a triggered Ability the Tool gives its holder
        other = sub - {'Pokémon Tool', 'ACE SPEC'}
        if other:
            B.append(('Pokémon Tool: subtype not modelled on a Tool: ' + ','.join(sorted(other)), joined))
            return res
        if c.get('attacks') or len(text) != 1:
            B.append(('Pokémon Tool: triggered (M8b shape), with other text', joined))
            return res
        r = translate_trigger(c, joined, res, tool=True)
        if r is None:
            return res
        ab, holder = r
        ab['name'] = c['name']
        res['term'] = ('tool', c['name'], {'holder': holder, 'attacks': [], 'abilities': [ab]})
        res['ok'] = True
        return res
    if not grants:
        k = static_kind(joined)
        if k is not None and k.startswith('triggered'):
            B.append(('Pokémon Tool: triggered', joined))
            return res
        if 'this card is attached to' in joined:
            return translate_static_tool(c, res, sents, joined)
        if k is not None:
            B += static_blockers('Pokémon Tool: ', joined, static_codes(joined)[0])
        elif 'this card is attached to' not in joined:
            B.append(('Pokémon Tool: record text names no holder (an Item-like text; unclassified record)', joined))
        else:
            B.append(('Pokémon Tool: static or triggered text of no listed kind', joined))
        return res
    rest = [x for x in sents if not GRANT_RE.match(x) and x != GRANT_REMINDER]
    if rest:
        r_ = ' '.join(rest)
        why = ('end-of-turn discard' if re.search(r'at the end of your turn', r_) else
               'the Mega Evolution ex rule printed on a Tool' if 'Mega Evolution' in r_ else static_kind(r_))
        B.append(('Pokémon Tool: text besides the attack grant' + (' (' + why + ')' if why else ''), ' '.join(rest)))
        return res
    other = sub - {'Pokémon Tool', 'ACE SPEC'}
    if other:
        B.append(('Pokémon Tool: subtype not modelled on a Tool: ' + ','.join(sorted(other)), joined))
        return res
    if len(grants) != 1 or len(c.get('attacks') or []) != 1:
        B.append(('Pokémon Tool: the grant does not name exactly one printed attack', joined))
        return res
    m = GRANT_RE.match(grants[0])
    ctx = {'kind': 'trainer', 'name': c['name'], 'base': None, 'cost': None}
    try:
        holder = parse_filter(m.group(1), ctx)
    except Refuse as r:
        B.append(('Pokémon Tool: holder not expressible: ' + r.reason, grants[0]))
        return res
    if not filter_names_pokemon(holder):
        B.append(('Pokémon Tool: holder filter admits cards other than Pokémon', grants[0]))
        return res
    res['used'].append(('tool-grant-attack', grants[0]))
    attacks = []
    for a in c['attacks']:
        at = translate_attack(c, a, res)
        if at is not None:
            attacks.append(at)
    if any(at.get('selfLock') for at in attacks):
        # a Tool's attack with a lock would share the holder's lock flag (`AtkLock.allows`); not written (milestone MV4)
        B.append(('Pokémon Tool: a given attack with a per-attack lock', ''))
    if B:
        return res
    res['term'] = ('tool', c['name'], {'holder': holder, 'attacks': attacks, 'abilities': []})
    res['ok'] = True
    return res


def translate_static_tool(c, res, sents, joined):
    """A Tool whose whole text is static (milestone M6): `ToolGrant.statics`, for the holder the text
    names; refused with reason codes otherwise."""
    B = res['blockers']
    other = c['_sub'] - {'Pokémon Tool', 'ACE SPEC'}
    if other:
        B.append(('Pokémon Tool: subtype not modelled on a Tool: ' + ','.join(sorted(other)), joined))
        return res
    if c.get('attacks'):
        B.append(('Pokémon Tool: static text with a printed attack', joined))
        return res
    ctx = {'kind': 'trainer', 'name': c['name'], 'base': None, 'cost': None}
    try:
        holder, ss = parse_static(sents, 'tool', ctx)
    except Refuse as r:
        B += static_blockers('Pokémon Tool: ', joined, r.reason)
        return res
    res['used'].append(('static-tool', joined))
    res['caveats'] |= static_caveats(ss)
    res['term'] = ('tool', c['name'], {'holder': holder, 'attacks': [], 'abilities': [], 'statics': ss})
    res['ok'] = True
    return res


def filter_names_pokemon(f):
    """The holder of a grant is a Pokémon in play: the filter is 'Pokémon', or names Pokémon only."""
    if f == ('pokemon',):
        return True
    if f[0] == 'named':
        return KNOWN_NAMES.get(f[1]) == {'Pokémon'}
    if f[0] == 'and':
        return filter_names_pokemon(f[1]) or filter_names_pokemon(f[2])
    return False


STADIUM_USE = re.compile(r"^Once during each player's turn, that player may (.+)$")


def third_to_second(t):
    """'that player' / 'they' / 'their' (the player using the Stadium, `.own` in `Move.stadiumUse`) to
    the second person of the Trainer rules."""
    t = re.sub(r'\bthat player shuffles their deck\b', 'shuffle your deck', t)
    t = re.sub(r'\bthat player\b', 'you', t)
    t = re.sub(r'\bthey\b', 'you', t)
    t = re.sub(r'\btheir\b', 'your', t)
    return t


def translate_stadium(c, res, text, joined):
    """A Stadium is imported only if its whole text is "Once during each player's turn, that player may
    X", X translating by the rules for Trainers (`.own` is the player who uses it)."""
    B = res['blockers']
    name = c['name']
    if not any(t.startswith("Once during each player's turn") for t in text):
        return translate_static_stadium(c, res, text, joined)
    if len(text) != 1:
        k = static_kind(joined)
        B.append(('Stadium: ' + ('static (' + k + ')' if k else 'text of several paragraphs, not one activated effect'),
                  joined))
        return res
    t = text[0]
    guard = None
    # importer 0.16.0 (milestone MV9): "Once during each player's turn, if they played X from their hand this turn, they
    # may Y" (Team Rocket's Factory sv10-173): Y under the test of the Supporter record (`parse_test_played`), with no
    # resolution when it fails (`NO_PLAY`: the Stadium cannot be used)
    mg = re.match(r"^Once during each player's turn, if (they (?:played|didn't play) .+? from their hand this turn), "
                  r"they may (.+)$", t)
    if mg:
        ctx0 = {'kind': 'trainer', 'name': name, 'base': None, 'cost': None}
        try:
            r0 = parse_test_played(mg.group(1), ctx0)
        except Refuse as r:
            B.append(('Stadium: activated effect not expressible: ' + r.reason, t))
            return res
        if r0 is None:
            B.append(('Stadium: activated effect not expressible: a condition on the history of the turn', t))
            return res
        (gt,), gneg = r0
        guard = (gt, gneg)
        t = "Once during each player's turn, that player may " + mg.group(2)
    if t.startswith("Once during each player's turn"):
        m = STADIUM_USE.match(t)
        if not m:
            why = ('a condition on the history of the turn' if re.search(r'this turn', t)
                   else 'opening not recognised')
            B.append(('Stadium: activated effect not expressible: ' + why, t))
            return res
        body = third_to_second(m.group(1))
        ctx = {'kind': 'trainer', 'name': name, 'base': None, 'cost': None}
        cost = None
        sents = split_sentences(cap(body))
        mc = re.match(r'^(.+) in order to (.+)$', sents[0]) if sents else None
        if mc:
            try:
                cost = ab_cost(cap(mc.group(1)), ctx)
            except Refuse as r:
                B.append(('Stadium: activated effect not expressible: ' + r.reason.replace('Ability: ', ''), text[0]))
                return res
            sents = [cap(mc.group(2))] + sents[1:]
        p = Parser(ctx).run(sents)
        res['used'] += [('stadium-use', text[0])] + p.used
        if p.blockers:
            # the reasons quote the text as read in the second person; the sentence is the printed one
            B += [('Stadium: activated effect not expressible: ' + a, text[0]) for a, _ in p.blockers]
            return res
        effs = []
        for _, it in p.items:
            if not isinstance(it, Eff) or it.pre:
                B.append(('Stadium: activated effect not expressible: not a plain effect', t))
                return res
            res['caveats'] |= it.cavs
            effs.append(it.e)
        effs = [no_effect_trainer(seq(*effs), t, res['caveats'])]
        e = seq(*([cost] if cost else []), *effs)
        if guard is not None and e != SKIP:
            gt, gneg = guard
            e = ite(gt, NO_PLAY, e) if gneg else ite(gt, e, NO_PLAY)
        if e == SKIP or not (T.hit_free(e) and T.bench_hit_free(e)):
            B.append(('Stadium: activated effect not expressible: empty or with attack damage', t))
            return res
        if T.amt_at('always', e):
            B.append(('Stadium: effect writes a rest-of-game modifier (StadiumSafe)', t))
            return res
        if counters_then_more(e):
            res['caveats'].add('koBetweenSteps')
        res['caveats'].discard('_needsPoison')
        res['term'] = ('trainer', name, ('stadium',), e)
        res['ok'] = True
        return res
    raise AssertionError(t)  # unreachable: a Stadium with no activated line is translate_static_stadium's


def translate_static_stadium(c, res, text, joined):
    """A Stadium whose whole text is static (milestone M6): `Card.trainer n .stadium .skip statics`;
    triggered text, and static text outside the shapes of `parse_static`, are refused."""
    B = res['blockers']
    k = static_kind(joined)
    if k is not None and k.startswith('triggered'):
        B.append(('Stadium: triggered', joined))
        return res
    ctx = {'kind': 'trainer', 'name': c['name'], 'base': None, 'cost': None}
    try:
        _, ss = parse_static([x for r in text for x in split_sentences(r)], 'stadium', ctx)
    except Refuse as r:
        B += static_blockers('Stadium: ', joined, r.reason)
        return res
    res['used'].append(('static-stadium', joined))
    res['caveats'] |= static_caveats(ss)
    res['term'] = ('trainer', c['name'], ('stadium',), SKIP, ss)
    res['ok'] = True
    return res


PLACERS = ('counters', 'benchCounters', 'spreadCounters', 'selfDamage')


def counters_then_more(e):
    """Some line of resolution places damage counters and then resolves another primitive (a Knock
    Out check falls between them in `TRun`)."""
    def lines(x):
        if x[0] == 'seq':
            return [a + b for a in lines(x[1]) for b in lines(x[2])]
        if x[0] in ('choice',):
            return lines(x[1]) + lines(x[2])
        if x[0] == 'ite':
            return lines(x[2]) + lines(x[3])
        if x[0] == 'iter':
            return [p * 2 for p in lines(x[1])]
        return [[x]]
    for ln in lines(e):
        for j, x in enumerate(ln):
            if x[0] in PLACERS and any(y != SKIP for y in ln[j + 1:]):
                return True
    return False


def reads_own_discard(e, term):
    found = []

    def walk_amt(a):
        if a[0] == 'count':
            chk(a[1])
        for x in a[1:]:
            if isinstance(x, tuple) and x and x[0] in ('add', 'sub', 'many', 'count', 'per', 'const'):
                walk_amt(x)

    def chk(cnt):
        if cnt[0] == 'pile' and cnt[1] == OWN and cnt[2] == ('discard',) and T.filter_eval(cnt[3], term):
            found.append(cnt)

    def walk(x):
        if x[0] == 'ite' and x[1][0] == 'countGe':
            chk(x[1][1])
        if x[0] in ('damage', 'drain'):
            walk_amt(x[1])
        for s in T.subs(x):
            walk(s)
    walk(e)
    return bool(found)


# ------------------------------------------------------------------ static text (milestone M6)
#
# Static text of a Pokémon's Ability, of a Pokémon Tool or of a Stadium is written as the model's
# `Static` (Pokemon/Card.lean; its semantics in Pokemon/Static.lean) only in the shapes below. Each
# shape was read against `staticsInForce` (who is reached: `Sel`, the filter on the affected
# Pokémon's top card, its place `tgt`, the source's place `src`, the Energy condition `need`),
# `GameState.hpOf` (printed HP plus every `hpPlus`, less every `hpMinus`), `GameState.sBonus` (added
# with the attacker's stored bonus at step 2 of `dealtBy`, before Weakness and Resistance, to damage
# to the opponent's Active Pokémon only), `GameState.sReduce` (subtracted at step 5, after Weakness
# and Resistance, from damage to the Active Pokémon only) and `GameState.retreatOf`. Every sentence
# of the text must match a shape; otherwise the text is refused, with every reason code of
# `STATIC_CODES` whose pattern the text matches (an approximate keyword classification, for ranking).
#
# Shapes (N, M numbers; F a filter phrase of `static_filter`; X a Retreat Cost amount):
#   Ability   [As long as this Pokémon is in the Active Spot / on your Bench, ]
#             [If this Pokémon has any / K or more [T] Energy attached, it …]
#             This Pokémon gets +N HP [for each [T] Energy attached to it].            self
#             This Pokémon takes N less damage from attacks [from your opponent's F]
#               (after applying Weakness and Resistance).                               self
#             Attacks used by this Pokémon do N more damage to your opponent's Active F
#               (before applying Weakness and Resistance).                              self
#             All of your F [that have any T Energy attached] take N less damage from attacks from
#               your opponent's F (after …).                                            own
#             Attacks used by your F do N more damage to your opponent's Active F (before …).  own
#             Your F [in play] get +N HP.                                               own
#             Your Active Pokémon's Retreat Cost is X less/more.                        own, Active
#             Your opponent's Active F's Retreat Cost is X more/less.                   opp, Active
#   Tool      The F this card is attached to gets +N HP / takes N less damage from attacks
#               [from your opponent's F] (after …).                                    holder
#             Attacks used by the F this card is attached to do N more damage to your opponent's
#               Active F (before …).                                                    holder
#             If the Pokémon this card is attached to doesn't have a Rule Box, the attacks it uses
#               do N more damage to your opponent's Active F (before …).               holder
#             The Retreat Cost of the F this card is attached to is X less/more.       holder
#             As long as the F this card is attached to is in the Active Spot, the Retreat Cost of
#               both Active Pokémon is X more/less.                                     all, Active
#   Stadium   Each F in play (both yours and your opponent's) gets +N / -N HP.          all
#             F (both yours and your opponent's) take N less damage from attacks from the
#               opponent's F (after …).                                                 all
#             Attacks used by F (both yours and your opponent's) do N more damage to the
#               opponent's Active F (before …).                                         all
#             The Retreat Cost of each F in play (both yours and your opponent's) is X less/more.
#
# Not expressible, refused: stacking rules ("The effect of X doesn't stack": the model adds every
# effect in force, so two sources give twice the amount, a different number in either direction;
# refused rather than imported with a one-way caveat), "has no Retreat Cost" (a set form: the
# model has more and less only), set or copied HP, conditions on Prize cards, the hand, damage,
# other Pokémon in play, Special Conditions or Special Energy, filters the model has not (name
# prefixes such as "Hop's", Ancient, Future, Tera, "has an Ability", Mega Evolution Pokémon ex),
# prevention and immunities, locks, cost changes, Bench size, type and Weakness changes, the
# opponent's attacks doing less damage before Weakness and Resistance, and anything triggered.

STATIC_CODES = [
    ('stack', r"doesn't stack|can't apply more than 1",
     'stacking rule ("doesn\'t stack"): the model adds every effect in force'),
    ('play', r'can put this card into play only|into play only with',
     'a rule on putting the card into play'),
    ('prevent', r"[Pp]revent all|can't be affected|isn't affected|can't be healed|can't be (?:Asleep|Burned|Confused|"
                r"Paralyzed|Poisoned)|recovers? from all Special Conditions|don't recover",
     'prevention or immunity (damage, effects, Special Conditions, healing)'),
    ('lock', r"ha(?:ve|s) no Abilities|lose any Ability|can't play|can't attack|can't use|can't be put into|can't be moved|"
             r"Tools attached .* have no effect",
     'a lock (Abilities, Tools, Items, Stadiums, attacks, moving damage counters)'),
    ('cost', r"costs? (?:\d+ Energy|(?:Colorless)+) (?:less|more)|in the costs? of|attack for |provides .* Energy",
     'attack cost or Energy provision'),
    # since importer 0.15.0 `SEff.noRetreat` (milestone MV8) writes "has no Retreat Cost" in the forms of
    # `static_ability_sentence` and `static_tool_sentence`; other forms keep this code
    ('noRetreat', r'no Retreat Cost', '"has no Retreat Cost" in a form not read (a condition or holder outside the forms '
                                      'of SEff.noRetreat)'),
    ('readsHp', r'remaining HP|full HP|maximum HP|damage counters on it',
     'reads HP or damage'),
    ('bench', r'on their Bench', 'Bench size'),
    ('typeWeak', r'Weakness of|apply Weakness|it is \w+ and \w+ type',
     'a change of type or Weakness'),
    ('oppLess', r"[Aa]ttacks used by your opponent's .*do \d+ less damage",
     "the opponent's attacks do less damage before Weakness and Resistance (the model's static reduction is at step 5)"),
    ('evolve', r'can evolve|\bevolve\b|devolve', 'evolution rules'),
    ('coins', r'coin flips', 'coin re-flips'),
    ('attacks', r'can use (?:any attack|the attacks)', 'use of other attacks'),
    ('toolCount', r'Pokémon Tool cards attached', 'the number of Tools'),
    ('checkup', r'Pokémon Checkup', 'Pokémon Checkup'),
    ('cond', r'Prize card|cards in (?:your|their) hand|If you have|As long as you have|If your opponent has|Poisoned|'
             r'Special Energy|has a Pokémon Tool attached|2 or more damage counters|that have \d+ or less Energy',
     'a condition the model cannot test statically (Prize cards, the hand, other Pokémon in play, Special '
     'Conditions, Special Energy, Tools, damage)'),
    ('filter', r"Cynthia's|Hop's|Steven's|\bN's|Team Rocket's|Ancient|Future|Tera|that ha(?:s|ve) an Ability|"
               r"Mega Evolution Pokémon ex|except any",
     'a filter the model has not (name prefix, Ancient, Future, Tera, "has an Ability", Mega Evolution Pokémon ex)'),
]
STATIC_DESC = dict((k, d) for k, _, d in STATIC_CODES)
STATIC_DESC['other'] = 'other static text'

BWR = r' \(before applying Weakness and Resistance\)\.$'
AWR = r' \(after applying Weakness and Resistance\)\.$'
BOTH = r" \(both yours and your opponent's\)"
SHIELD_REMINDER = re.compile(r'\s*\((?:Existing effects are not removed\. )?Damage is not an effect\.\)')
RULEBOX_REMINDER = re.compile(r'^\(Pokémon ex, Pokémon V(?:_atk)?, etc\. have Rule Boxes\.\)$')


def static_codes(text):
    """The reason codes of a static text that is not expressible (every pattern it matches; 'other' if none)."""
    cs = [k for k, rx, _ in STATIC_CODES if re.search(rx, text)]
    return cs or ['other']


def pokemon_only(f):
    """A filter on a Pokémon's top card built from the parts that name Pokémon (no `hpLe`: no static
    condition reads HP, printed or derived)."""
    h = f[0]
    if h in ('any', 'pokemon', 'basic', 'stage', 'ptype', 'noRuleBox', 'namePrefix', 'nameHas'):
        return True
    if h == 'named':
        return KNOWN_NAMES.get(f[1]) == {'Pokémon'}
    if h in ('and', 'or'):
        return pokemon_only(f[1]) and pokemon_only(f[2])
    if h == 'not':
        return pokemon_only(f[1])
    return False


def static_filter(np, ctx):
    """A phrase naming Pokémon ("Pokémon", "Basic Pokémon", "Evolution Fire Pokémon", "Fire or Water
    Pokémon", "Grass Pokémon and Fire Pokémon", "Pokémon ex", "Psyduck") to a `Filter` on the top card;
    `.any` for every Pokémon."""
    s = np.strip()
    if s == 'Pokémon':
        return ('any',)
    m = re.match(r'^([A-Za-z, ]+?),? or ([A-Za-z]+) Pokémon$', s)
    if m:
        ws = [w.strip() for w in m.group(1).split(',')] + [m.group(2)]
        if all(w in T.TYPES for w in ws):
            f = ('ptype', etype(ws[-1]))
            for w in reversed(ws[:-1]):
                f = ('or', ('ptype', etype(w)), f)
            return f
    m = re.match(r'^(.+ Pokémon) and (.+ Pokémon)$', s)
    if m:
        return ('or', static_filter(m.group(1), ctx), static_filter(m.group(2), ctx))
    try:
        f = parse_filter(s, ctx)
    except Refuse:
        raise Refuse('filter', s)
    if not pokemon_only(f):
        raise Refuse('filter', s)
    return f


def retreat_n(x):
    """A printed Retreat Cost change: 'Colorless' symbols, or a number."""
    if re.fullmatch(r'(?:Colorless)+', x):
        return len(x) // len('Colorless')
    if re.fullmatch(r'\d+', x):
        return int(x)
    raise Refuse('other', x)


def retreat_eff(x, way):
    return ('retreatPlus', retreat_n(x)) if way == 'more' else ('retreatMinus', retreat_n(x))


def mk_static(sel, eff, filt=('any',), tgt=None, src=None, need=None):
    """A `Static` as a Python dict, in the field order of the structure."""
    return {'sel': (sel,), 'filt': filt, 'tgt': ('some', (tgt,)) if tgt else None,
            'src': ('some', (src,)) if src else None,
            'need': ('some', ('pair', need[0], need[1])) if need else None, 'eff': eff}


# milestone MV7b (importer 0.14.0): static changes of Pokémon Checkup, `SEff.condMore c n` (Pokemon/Card.lean `SEff`;
# Pokemon/Static.lean `Static.condMoreFor`, `GameState.checkupMoreBy`; Pokemon/Rules.lean, Known gaps "static changes
# of Pokémon Checkup"; witnesses in Pokemon/Checkup.lean). "During Pokémon Checkup, put N more damage counters on your
# opponent's Burned / Poisoned Pokémon": `n` more counters, at every Checkup (`Move.endTurn`), on each Active Pokémon of
# the selected players (`sel`) that has the Special Condition `c`. Exact: only an Active Pokémon has Special Conditions
# in the model and in print ("your opponent's Burned Pokémon" can only be the Active one); each effect in force adds its
# own counters (two Magmortars put 6 more, as two Abilities do in print); each is read before or after the Special
# Conditions' block in every order the next player may choose (2026 rulebook p. 15; `CheckupW.two_sources`); the source
# conditions are the static's: "as long as this Pokémon is in the Active Spot" is `src = some .active` (Pecharunt
# svp-129), a Stadium's "each Poisoned non-Darkness Pokémon (both yours and your opponent's)" is `sel = all` with the
# filter `not (ptype darkness)` on the affected Pokémon's printed type (Perilous Jungle sv5-156; `Filter.ptype` ignores a
# Coloring counter, which no imported card places: Known gaps, filters).
CHECKUP_MORE = re.compile(r'more damage counters on .+ during Pokémon Checkup|During Pokémon Checkup, put \d+ more damage '
                          r'counters')
CHECKUP_AB = re.compile(r"^(?:During Pokémon Checkup, put (\d+) more damage counters on your opponent's (Burned|Poisoned) "
                        r"Pokémon|Put (\d+) more damage counters on your opponent's (Burned|Poisoned) Pokémon during Pokémon "
                        r"Checkup)\.$")
CHECKUP_ST = re.compile(r'^During Pokémon Checkup, put (\d+) more damage counters on each (Burned|Poisoned) (?:non-' + TYPE_RE
                        + r' )?Pokémon' + r" \(both yours and your opponent's\)" + r'\.$')


def static_ability_sentence(s, ctx, src=None, need=None):
    """One sentence of a static Ability to `Static`s; `src` and `need` from the prefixes."""
    m = re.match(r'^As long as this Pokémon is (in the Active Spot|on your Bench), (.+)$', s)
    if m:
        if src is not None:
            raise Refuse('other', s)
        return static_ability_sentence(cap(m.group(2)), ctx, 'active' if 'Active' in m.group(1) else 'bench', need)
    m = re.match(r'^If this Pokémon has (any|(\d+) or more) (?:(Basic|Special) )?(?:' + TYPE_RE + r' )?Energy attached, it (.+)$', s)
    if m:
        if need is not None:
            raise Refuse('other', s)
        k = int(m.group(2)) if m.group(2) else 1
        nd = (energy_filter(m.group(3), m.group(4)), k)
        rest = m.group(5)
        m2 = re.match(r'^(gets \+\d+ HP), and the attacks it uses (do .+)$', rest)
        if m2:
            return (static_ability_sentence('This Pokémon ' + m2.group(1) + '.', ctx, src, nd)
                    + static_ability_sentence('Attacks used by this Pokémon ' + m2.group(2), ctx, src, nd))
        return static_ability_sentence('This Pokémon ' + rest, ctx, src, nd)
    S = lambda sel, eff, **kw: [mk_static(sel, eff, src=src, need=need, **kw)]  # noqa: E731
    m = CHECKUP_AB.match(s)
    if m:
        if need is not None:
            raise Refuse('other', s)
        n, cnd = (m.group(1), m.group(2)) if m.group(1) else (m.group(3), m.group(4))
        return S('opp', ('condMore', (CONDS[cnd],), int(n)))
    m = re.match(r'^This Pokémon gets \+(\d+) HP\.$', s)
    if m:
        return S('self', ('hpPlus', ('const', counters(m.group(1)))))
    m = re.match(r'^This Pokémon gets \+(\d+) HP for each (?:(Basic) )?(?:' + TYPE_RE + r' )?Energy (?:card )?attached to '
                 r'(?:it|this Pokémon)\.$', s)
    if m:
        return S('self', ('hpPlus', ('perEnergy', energy_filter(m.group(2), m.group(3)), counters(m.group(1)))))
    m = re.match(r"^This Pokémon takes (\d+) less damage from attacks(?: from your opponent's (.+?))?" + AWR, s)
    if m:
        fr = static_filter(m.group(2), ctx) if m.group(2) else ('any',)
        return S('self', ('reduce', counters(m.group(1)), fr))
    m = re.match(r"^Attacks used by this Pokémon do (\d+) more damage to your opponent's Active (.+?)" + BWR, s)
    if m:
        return S('self', ('bonus', counters(m.group(1)), static_filter(m.group(2), ctx)))
    m = re.match(r"^This Pokémon's Retreat Cost is (\w+) (more|less)\.$", s)
    if m:
        return S('self', retreat_eff(m.group(1), m.group(2)))
    # milestone MV3, stage 3: static damage prevention by a filter on the attacker (`SEff.prevent fr`): damage to this
    # Pokémon in the Active Spot from attacks of Pokémon whose top card passes `fr` is 0 (step 5; not when the attack
    # ignores effects on the defender, `Ign.fx`, as print says of such attacks). Damage only: "damage from and effects
    # of attacks" is refused (no rule: its effect half would be dropped). On the Bench the model does not prevent it
    # (caveat staticPreventBench, `static_caveats`).
    # importer 0.17.0 (milestone MV10): static prevention of effects of attacks (`SEff.shield fr`), alone ("Damage is
    # not an effect") or with the damage (`SEff.prevent fr` too). Read in the Active Spot only (caveat shieldActive, from
    # `static_caveats`); a source that is in force only on the Bench would protect nothing in the model: refused.
    m = re.match(r"^Prevent all effects of attacks used by your opponent's (.+?) done to this Pokémon\.$", s)
    if m:
        if src == 'bench':
            raise Refuse('other', s)
        return S('self', ('shield', prevent_filter(m.group(1), ctx)))
    m = re.match(r"^Prevent all effects of attacks used by your opponent's (.+?) done to your (.+?)\.$", s)
    if m:
        if src == 'bench':
            raise Refuse('other', s)
        return S('own', ('shield', prevent_filter(m.group(1), ctx)), filt=static_filter(m.group(2), ctx))
    # importer 0.20.0 (milestone MV13, survey S27 A1): a source in force on the Bench only ("As long as this Pokémon is on
    # your Bench, prevent all damage from and effects of attacks …") is imported: the damage half is read by the Bench
    # damage primitives (`GameState.benchSafe`); the effect half (`SEff.shield`) is never read on the Bench (caveat
    # shieldBench, from `static_caveats`).
    m = re.match(r"^Prevent all damage from and effects of attacks from your opponent's (.+?) done to this Pokémon\.$", s)
    if m:
        fr = prevent_filter(m.group(1), ctx)
        return S('self', ('prevent', fr)) + S('self', ('shield', fr))
    m = re.match(r"^Prevent all damage from and effects of attacks from your opponent's (.+?) done to your Benched "
                 r"Pokémon\.$", s)
    if m:
        fr = prevent_filter(m.group(1), ctx)
        return S('own', ('prevent', fr), tgt='bench') + S('own', ('shield', fr), tgt='bench')
    m = re.match(r"^Prevent all damage done to your Benched (.+?) by attacks from your opponent's (.+?)\.$", s)
    if m:
        return S('own', ('prevent', prevent_filter(m.group(2), ctx)), filt=static_filter(m.group(1), ctx), tgt='bench')
    # importer 0.20.0 (milestone MV13, survey S27 A3, A4): Special Condition immunity (`SEff.noCond c`, read by
    # `Run.inflict`) and the heal block on the opponent's Active Pokémon (`SEff.noHeal`, read by heal, healAll, drain)
    m = re.match(r"^This Pokémon can't be (Asleep|Burned|Confused|Paralyzed|Poisoned)\.$", s)
    if m:
        return S('self', ('noCond', (CONDS[m.group(1)],)))
    if s == "Your opponent's Active Pokémon can't be healed.":
        return S('opp', ('noHeal',), tgt='active')
    # importer 0.21.0 (milestone MV14, survey S28): a static threshold, "Prevent all damage done to this Pokémon by attacks
    # from your opponent's F if that damage is N or more" (Drednaw sv7-44): `SEff.preventGe (N/10) fr`, read in the Active
    # Spot on the damage after every other effect of the calculation (`GameState.dealt`; caveat thresholdRead) and on the
    # Bench on the amount placed (`GameState.benchThr`). Exact except for that reading.
    m = re.match(r"^Prevent all damage done to this Pokémon by attacks from your opponent's (.+?) if that damage is "
                 r"(\d+) or more\.$", s)
    if m:
        return S('self', ('preventGe', counters(m.group(2)), prevent_filter(m.group(1), ctx)))
    m = re.match(r"^Prevent all damage (?:done to this Pokémon by attacks from|from attacks done to this Pokémon by) your "
                 r"opponent's (.+?)\.$", s)
    if m:
        return S('self', ('prevent', prevent_filter(m.group(1), ctx)))
    m = re.match(r'^(?:All of your|Your|Each of your) (.+?)(?: in play)? gets? \+(\d+) HP\.$', s)
    if m:
        return S('own', ('hpPlus', ('const', counters(m.group(2)))), filt=static_filter(m.group(1), ctx))
    m = re.match(r"^Attacks used by your (.+?) do (\d+) more damage to your opponent's Active (.+?)" + BWR, s)
    if m:
        return S('own', ('bonus', counters(m.group(2)), static_filter(m.group(3), ctx)),
                 filt=static_filter(m.group(1), ctx))
    m = re.match(r"^All of your (.+?)(?: that have any (?:(Basic) )?(?:" + TYPE_RE + r" )?Energy attached)? take (\d+) less "
                 r"damage from attacks from your opponent's (.+?)" + AWR, s)
    if m:
        if 'that ha' in m.group(1):
            raise Refuse('other', s)
        nd = need
        if re.search(r' that have any ', s.split(' take ')[0]):
            if need is not None:
                raise Refuse('other', s)
            nd = (energy_filter(m.group(2), m.group(3)), 1)
        return [mk_static('own', ('reduce', counters(m.group(4)), static_filter(m.group(5), ctx)),
                          filt=static_filter(m.group(1), ctx), src=src, need=nd)]
    m = re.match(r"^Your Active Pokémon's Retreat Cost is (\w+) (more|less)\.$", s)
    if m:
        return S('own', retreat_eff(m.group(1), m.group(2)), tgt='active')
    # importer 0.15.0 (milestone MV8, `SEff.noRetreat`; caveat noRetreatLast, added by `static_caveats`): "Your Basic
    # Pokémon in play have no Retreat Cost." (Latias ex sv8-76, Altaria me6-82); "All of your Pokémon that have Metal
    # Energy attached have no Retreat Cost." (Archaludon sv7-107: `need = (energyOf metal, 1)`, Basic cards only, caveat
    # energyOfCount by the term walk of `translate_card`)
    m = re.match(r'^Your (.+?) in play have no Retreat Cost\.$', s)
    if m:
        return S('own', ('noRetreat',), filt=static_filter(m.group(1), ctx))
    m = re.match(r'^All of your (.+?) that have (?:(Basic) )?(?:' + TYPE_RE + r' )?Energy attached have no Retreat Cost\.$', s)
    if m:
        if need is not None:
            raise Refuse('other', s)
        return [mk_static('own', ('noRetreat',), filt=static_filter(m.group(1), ctx), src=src,
                          need=(energy_filter(m.group(2), m.group(3)), 1))]
    m = re.match(r"^Your opponent's Active (.+?)'s Retreat Cost is (\w+) (more|less)\.$", s)
    if m:
        return S('opp', retreat_eff(m.group(2), m.group(3)), filt=static_filter(m.group(1), ctx), tgt='active')
    raise Refuse('other', s)


def static_tool_sentence(s, ctx):
    """One sentence of a Tool's static text to (holder phrase, `Static`s); `self` is the holder."""
    m = re.match(r'^The (.+?) this card is attached to gets \+(\d+) HP\.$', s)
    if m:
        return m.group(1), [mk_static('self', ('hpPlus', ('const', counters(m.group(2)))))]
    m = re.match(r"^The (.+?) this card is attached to takes (\d+) less damage from attacks(?: from your opponent's (.+?))?"
                 + AWR, s)
    if m:
        fr = static_filter(m.group(3), ctx) if m.group(3) else ('any',)
        return m.group(1), [mk_static('self', ('reduce', counters(m.group(2)), fr))]
    m = re.match(r"^Attacks used by the (.+?) this card is attached to do (\d+) more damage to your opponent's Active (.+?)"
                 + BWR, s)
    if m:
        return m.group(1), [mk_static('self', ('bonus', counters(m.group(2)), static_filter(m.group(3), ctx)))]
    m = re.match(r"^If the (.+?) this card is attached to doesn't have a Rule Box, the attacks it uses do (\d+) more damage "
                 r"to your opponent's Active (.+?)" + BWR, s)
    if m:
        return m.group(1), [mk_static('self', ('bonus', counters(m.group(2)), static_filter(m.group(3), ctx)),
                                      filt=('noRuleBox',))]
    m = re.match(r'^The Retreat Cost of the (.+?) this card is attached to is (\w+) (more|less)\.$', s)
    if m:
        return m.group(1), [mk_static('self', retreat_eff(m.group(2), m.group(3)))]
    # importer 0.17.0 (milestone MV10): Mist Energy, Rocky Fighting Energy
    m = re.match(r"^Prevent all effects of attacks used by your opponent's (.+?) done to the (.+?) this card is attached "
                 r"to\.$", s)
    if m:
        return m.group(2), [mk_static('self', ('shield', prevent_filter(m.group(1), ctx)))]
    # importer 0.20.0 (milestone MV13, survey S27 A1): Shadowy Darkness Energy me5-83, damage prevention for a Benched
    # holder (`SEff.prevent` with `tgt = bench`, read by the Bench damage primitives)
    m = re.match(r"^As long as the (.+?) this card is attached to is on your Bench, prevent all damage done to it by "
                 r"attacks from your opponent's (.+?)\.$", s)
    if m:
        return m.group(1), [mk_static('self', ('prevent', prevent_filter(m.group(2), ctx)), tgt='bench')]
    # importer 0.15.0 (milestone MV8): "The Metal Pokémon this card is attached to has no Retreat Cost." (`SEff.noRetreat`,
    # applied last: caveat noRetreatLast, added by the caller)
    m = re.match(r'^The (.+?) this card is attached to has no Retreat Cost\.$', s)
    if m:
        return m.group(1), [mk_static('self', ('noRetreat',))]
    m = re.match(r'^As long as the (.+?) this card is attached to is in the Active Spot, the Retreat Cost of both Active '
                 r'Pokémon is (\w+) (more|less)\.$', s)
    if m:
        return m.group(1), [mk_static('all', retreat_eff(m.group(2), m.group(3)), tgt='active', src='active')]
    raise Refuse('other', s)


def static_stadium_sentence(s, ctx):
    """One sentence of a Stadium's static text to `Static`s (`all`: both players' Pokémon)."""
    m = CHECKUP_ST.match(s)
    if m:
        f = ('not', ('ptype', etype(m.group(3)))) if m.group(3) else ('any',)
        return [mk_static('all', ('condMore', (CONDS[m.group(2)],), int(m.group(1))), filt=f)]
    m = re.match(r'^Each (.+?) in play' + BOTH + r' gets ([+-])(\d+) HP\.$', s)
    if m:
        n = counters(m.group(3))
        eff = ('hpPlus', ('const', n)) if m.group(2) == '+' else ('hpMinus', n)
        return [mk_static('all', eff, filt=static_filter(m.group(1), ctx))]
    m = re.match(r"^(.+?)(?: in play)?" + BOTH + r" take (\d+) less damage from attacks from the opponent's (.+?)" + AWR, s)
    if m:
        return [mk_static('all', ('reduce', counters(m.group(2)), static_filter(m.group(3), ctx)),
                          filt=static_filter(m.group(1), ctx))]
    m = re.match(r"^Attacks used by (.+?)(?: in play)?" + BOTH + r" do (\d+) more damage to the opponent's Active (.+?)" + BWR, s)
    if m:
        return [mk_static('all', ('bonus', counters(m.group(2)), static_filter(m.group(3), ctx)),
                          filt=static_filter(m.group(1), ctx))]
    m = re.match(r'^The Retreat Cost of each (.+?) in play' + BOTH + r' is (\w+) (more|less)\.$', s)
    if m:
        return [mk_static('all', retreat_eff(m.group(2), m.group(3)), filt=static_filter(m.group(1), ctx))]
    raise Refuse('other', s)


def static_caveats(ss):
    """`staticBench`: a static damage reduction protects only the Active Pokémon in the model; `staticPreventBench`
    (milestone MV3): so does a static prevention."""
    cv = set()
    for s in ss:
        if s['eff'][0] == 'reduce' and s['tgt'] != ('some', ('active',)):
            cv.add('staticBench')
        # importer 0.20.0 (milestone MV13): a static prevention is read on the Bench too (`GameState.benchSafe`), so
        # `staticPreventBench` is no longer written
        if s['eff'][0] == 'shield':
            if s['tgt'] == ('some', ('bench',)) or s['src'] == ('some', ('bench',)):
                # importer 0.20.0: in force on the Bench only, where the effect half is never read
                cv.add('shieldBench')
            else:
                # importer 0.17.0: read for the holder in the Active Spot, at the start of the attack
                cv.add('shieldActive')
                cv.add('shieldReach')
        if s['eff'] == ('noHeal',):
            cv.add('healMove')
        if s['eff'][0] == 'preventGe':
            # importer 0.21.0 (milestone MV14): "that damage" is read after every other effect of the calculation
            cv.add('thresholdRead')
        if s['eff'] == ('noRetreat',):
            # importer 0.15.0: `SEff.noRetreat` is applied after the additions and subtractions (a reading)
            cv.add('noRetreatLast')
    return cv


# The attacker kinds of a static prevention (`SEff.prevent fr`, `fr` read on the attacker's top card, a printed
# Pokémon card): "Pokémon ex" is `Filter.ex` (rule box ex or Mega Evolution ex; 2026 rulebook: a Mega Evolution Pokémon
# ex is a Pokémon ex), "Pokémon that have an Ability" is `Filter.hasAbility` (the printed card's Abilities; a Tool's
# text is not an Ability of its holder in print, and the model's Tools give Abilities only through `ToolGrant`, which
# `hasAbility` does not read), "Tera Pokémon" `Filter.tera`.
PREVENT_KINDS = {
    'Pokémon ex': ('ex',),
    'Basic Pokémon ex': ('and', ('basic',), ('ex',)),
    'Pokémon that have an Ability': ('hasAbility',),
    'Tera Pokémon': ('tera',),
}


def prevent_filter(np, ctx):
    if np in PREVENT_KINDS:
        return PREVENT_KINDS[np]
    return static_filter(np, ctx)


def parse_static(sents, kind, ctx):
    """The sentences of a static text to (holder, statics), or raise Refuse(code, text) with the first
    reason code. `kind` is 'ability', 'tool' or 'stadium'; `holder` is the Tool's holder filter."""
    text = ' '.join(sents)
    if re.search(STATIC_CODES[0][1], text):
        raise Refuse('stack', text)
    out = []
    holders = set()
    body = [x for x in sents if not RULEBOX_REMINDER.match(x)]
    if len(body) < len(sents) and 'Rule Box' not in ' '.join(body):
        raise Refuse('other', text)
    # importer 0.17.0: the reminder of the prevention of effects ("Damage is not an effect.", "Existing effects are not
    # removed."), which `SEff.shield` says by construction (it is read when an attack resolves and removes nothing)
    if any(x.startswith('Prevent all effects of attacks') for x in body):
        body = split_sentences(SHIELD_REMINDER.sub('', ' '.join(body)))
    if not body:
        raise Refuse('other', text)
    try:
        for s in body:
            if kind == 'ability':
                out += static_ability_sentence(s, ctx)
            elif kind == 'tool':
                h, ss = static_tool_sentence(s, ctx)
                holders.add(h)
                out += ss
            else:
                out += static_stadium_sentence(s, ctx)
    except Refuse as r:
        raise Refuse(static_codes(text)[0] if r.reason == 'other' else r.reason, text)
    holder = None
    if kind == 'tool':
        if len(holders) != 1:
            raise Refuse('other', text)
        h = holders.pop()
        try:
            holder = parse_filter(h, ctx)
        except Refuse:
            holder = None
        if holder is None or not pokemon_only(holder):
            code = static_codes(text)[0]
            raise Refuse('filter' if code == 'other' else code, text)
    return holder, out


def static_blockers(head, text, first):
    """The blockers of a refused static text: the first reason, then every other code the text matches."""
    found = [k for k in static_codes(text) if k != 'other']
    if first == 'stack' or not found:
        codes = [first] + [k for k in found if k != first]
    else:
        # the parser's reason (a phrase it could not read as a filter, or no shape) is less specific
        # than the keyword classification when that finds something
        codes = found
    return [(head + 'static, ' + k + ' (' + STATIC_DESC[k] + ')', text) for k in codes]


# ------------------------------------------------------------------ Abilities (milestone M8a)
#
# An Ability is translated only if it is activated ("Once during your turn, you may …", "As often as
# you like during your turn, you may …") or an on-play trigger ("When you play this Pokémon from your
# hand onto your Bench / to evolve 1 of your Pokémon during your turn, you may …"), its conditions are
# a place ("if this Pokémon is in the Active Spot / on your Bench") or a test the model has, and every
# sentence of its effect is matched by a rule. Everything else is refused with a reason that starts
# with 'Ability: ' (static, triggered, first-turn, from the hand, self Knock Out, return from play,
# conditions the model cannot test), or by the sentence that failed.

AB_HEADS = [
    (r"Once during your turn, when you play this Pokémon from your hand onto your Bench", ('onPlay', ('bench',))),
    (r"Once during your turn, when you play this Pokémon from your hand to evolve 1 of your Pokémon", ('onPlay', ('evolve',))),
    (r"When you play this Pokémon from your hand onto your Bench during your turn", ('onPlay', ('bench',))),
    (r"When you play this Pokémon from your hand to evolve 1 of your Pokémon during your turn", ('onPlay', ('evolve',))),
    (r"Once during your turn", ('once',)),
    (r"As often as you like during your turn", ('unlimited',)),
]

ONE_PER_NAME = re.compile(r"^You can't use more than 1 (?:.+ Ability|Ability that has .+ in its name) (?:each|during your) turn\.$")


def ability_refusal(t):
    """A specific reason for an Ability the model has no form for, or None."""
    act = re.match(r'^(?:You must .+ in order to use this Ability\. )?(Once during your turn|As often as you like during your turn|'
                   r'When you play this Pokémon from your hand)', t)
    if re.search(r'[Oo]nce during your first turn', t):
        return 'Ability: once during your first turn'
    if not act:
        if re.search(r'Knocked Out|is damaged|damage is done|[Ww]henever|^When |^If .* (?:would|is) |[Dd]uring Pokémon Checkup|'
                     r'moves (?:from|to)|is discarded', t):
            return 'Ability: triggered (Knock Out, damage, Checkup, an opponent\'s action or a move between spots)'
        if re.search(r'first turn|go first', t):
            return 'Ability: static (first-turn rule)'
        return 'Ability: static or passive'
    if re.search(r'when (?:this Pokémon|your .+) moves (?:from|to)', t):
        return 'Ability: triggered (Knock Out, damage, Checkup, an opponent\'s action or a move between spots)'
    if re.search(r'Knocked Out', t) and re.search(r'this Pokémon is Knocked Out|You may also use this Ability if', t):
        return 'Ability: Knocks Out its own Pokémon, or is also triggered by a Knock Out'
    if re.search(r'your turn ends', t):
        return 'Ability: ends the turn'
    if re.search(r'is in your hand', t):
        return 'Ability: used from the hand'
    if re.search(r'all attached cards|put this Pokémon on top of your deck|shuffle (?:it|this Pokémon) and all', t):
        return 'Ability: returns its Pokémon from play'
    if re.search(r"can't be", t):
        return "Ability: an effect that can't be stopped"
    if re.search(r"You can't use this Ability during your first turn", t):
        return 'Ability: first-turn limit'
    # milestone MV2: "if any of your Pokémon were Knocked Out during your opponent's last turn" is a test
    # (`Count.koLast`, `parse_test`); other history conditions are not
    # importer 0.16.0: "if you played X from your hand this turn" is a test (`Count.played`, `parse_test_played`)
    if re.search(r'if you played (?!.+ from your hand (?:during )?this turn).+ this turn|last turn',
                 re.sub(r"if any of your Pokémon were Knocked Out (?:by damage from an attack )?during your opponent's "
                        r"last turn", '', t)):
        return 'Ability: condition on the history of the turn (this turn, last turn)'
    return None


def ab_condition(c, spot, ctx):
    """One printed condition of an Ability: ('spot', s), ('cond', test) or ('wrap', tests, neg)."""
    if c == 'this Pokémon is in the Active Spot':
        return ('spot', ('active',))
    if c == 'this Pokémon is on your Bench':
        return ('spot', ('bench',))
    m = re.match(r'^this Pokémon has any (?:(Basic )?' + TYPE_RE + r' )?Energy attached(?: to it)?$', c)
    if m:
        if spot != ('active',):
            raise Refuse('Ability: condition on this Pokémon, which may be on the Bench: ' + c)
        return ('cond', ('countGe', ('energy', OWN, energy_filter(m.group(1), m.group(2))), 1))
    if 'this Pokémon' in c and spot != ('active',):
        raise Refuse('Ability: condition on this Pokémon, which may be on the Bench: ' + c)
    try:
        ctx.pop('_tc', None)
        tests, neg = parse_test(c, ctx)
    except Refuse as r:
        raise Refuse('Ability: ' + r.reason)
    ctx['_cavs'] |= ctx.pop('_tc', set())
    if len(tests) == 1 and not neg and tests[0][0] != 'AND':
        return ('cond', tests[0])
    return ('wrap', tests, neg)


def ab_cost(c, ctx):
    """'… in order to use this Ability': an exact cost, paid first (no resolution if it cannot be)."""
    m = re.match(r'^[Dd]iscard (a card|\d+ cards) from your hand$', c)
    if m:
        n = 1 if m.group(1) == 'a card' else num(m.group(1).split()[0])
        return ('move', OWN, ('hand',), ('discard',), ('any',), ('exactly', n))
    m = re.match(r'^[Dd]iscard (an?) (.+?) from your hand$', c)
    if m:
        return ('move', OWN, ('hand',), ('discard',), parse_filter(m.group(2), ctx), ('exactly', 1))
    if re.match(r'^[Pp]ut a card from your hand on the bottom of your deck$', c):
        return ('move', OWN, ('hand',), ('bottom',), ('any',), ('exactly', 1))
    raise Refuse('Ability: cost not expressible: ' + c)


def cap(s):
    return s[0].upper() + s[1:] if s else s


def self_places(a, p, out):
    """Where each `SelfOp` of an `AbEff` is compiled, with "this Pokémon" at p (None: not tracked)."""
    h = a[0]
    if h == 'self':
        out.append((a[1], p))
        return T.selfop_after(p, a[1])
    if h == 'fx':
        return T.abeff_after(p, a)
    if h == 'seq':
        return self_places(a[2], self_places(a[1], p, out), out)
    if h == 'choice':
        x = self_places(a[1], p, out)
        y = self_places(a[2], p, out)
        return x if x == y else None
    raise AssertionError(a)


def translate_ability(c, a, res):
    """Translate one printed Ability; append blockers to res and return None if it is refused."""
    B = res['blockers']
    t = norm(a.get('text'))
    name = a.get('name') or ''
    if (a.get('type') or 'Ability') != 'Ability':
        B.append(('Ability: kind not modelled: ' + str(a.get('type')), t))
        return None
    if trig_shape(t):
        # a triggered Ability of the two shapes of milestone M8b
        r = translate_trigger(c, t, res, tool=False)
        if r is None:
            return None
        r[0]['name'] = name
        return r[0]
    mb = BENCHED_RX.match(t)
    if mb:
        return translate_benched(c, a, t, mb, res)
    mm = MOVED_RX.match(t)
    if mm:
        return translate_moved(c, a, t, mm, res)
    if CHECKUP_MORE.search(t):
        # milestone MV7b: a static change of Pokémon Checkup (`SEff.condMore`), not a trigger
        return translate_static_ability(c, a, res)
    if FLYGON_KO in t:
        # an on-play Ability that may also be used on a Knock Out (Flygon me2-53): the on-play Ability, and an
        # optional `koByAttack` trigger in the Active Spot with the same effect
        return translate_also_ko(c, a, t, res)
    # milestone MV7b (importer 0.14.0): "If you use this Ability, this Pokémon is Knocked Out." ends the Ability's effect
    # with 9999 damage counters on this Pokémon (`KO_COUNTERS`, `SelfOp.counters`), a pending Knock Out the batch step
    # inside the Ability's resolution takes at once, with its Prize cards (the opponent's) and the promotion
    # (Pokemon/SelfKO.lean `self_ko`; Known gaps, self-Knock-Out Abilities). It follows the rest of the effect, as
    # printed, and "if you use this Ability" makes it unconditional. Caveats: koCounters (a constant above every derived
    # HP), selfKOTiming (a Knock Out check after each step, when an earlier step places damage counters), and on the
    # Bench selfBench (`SelfOp.counters` on one Benched Pokémon chosen at resolution, a superset).
    selfko = t.endswith(' ' + SELF_KO)
    if selfko:
        t = t[:-len(SELF_KO) - 1]
    why = ability_refusal(t)
    if why == 'Ability: static or passive':
        return translate_static_ability(c, a, res)
    if why:
        B.append((why, t))
        return None
    sents = split_sentences(t)
    cavs = set()
    cost = None
    ctx = {'kind': 'ability', 'name': c['name'], 'base': None, 'cost': None, '_cavs': cavs, 'spot': None}
    try:
        m = re.match(r'^You must (.+) in order to use this Ability\.$', sents[0])
        if m:
            cost = ab_cost(m.group(1), ctx)
            sents = sents[1:]
        s0 = sents[0]
        use = None
        for rx, u in AB_HEADS:
            if re.match('^' + rx + ', ', s0):
                use, rest = u, s0[len(re.match('^' + rx, s0).group(0)):]
                break
        if use is None:
            raise Refuse('Ability: opening not recognised', s0)
        conds = []
        while True:
            m = re.match(r'^, (?:and )?if (.+?)(?=, (?:and )?if |, you may )', rest)
            if not m:
                break
            conds.append(m.group(1))
            rest = rest[m.end():]
        m = re.match(r'^, you may (.+)$', rest)
        if not m:
            raise Refuse('Ability: opening not recognised', s0)
        tail = m.group(1)
        body = sents[1:]
        if tail == 'use this Ability.':
            pass
        else:
            m = re.match(r'^(.+) in order to use this Ability\.$', tail)
            if m:
                if cost is not None:
                    raise Refuse('Ability: two costs', s0)
                cost = ab_cost(m.group(1), ctx)
            else:
                body = [cap(tail)] + body
        if use[0] == 'onPlay' and conds:
            # the model reads an on-play condition after the play and does not track "this Pokémon"
            if any('this Pokémon' in x for x in conds):
                raise Refuse('Ability: on-play condition on this Pokémon: ' + '; '.join(conds))
        # place first (a condition on this Pokémon needs it)
        spot = None
        for x in conds:
            if x in ('this Pokémon is in the Active Spot', 'this Pokémon is on your Bench'):
                spot = ab_condition(x, None, ctx)[1]
        if use[0] == 'onPlay':
            spot = None
        ctx['spot'] = spot
        cond = None
        wraps = []
        for x in conds:
            k = ab_condition(x, spot, ctx)
            if k[0] == 'spot':
                continue
            if k[0] == 'cond' and cond is None:
                cond = k[1]
            else:
                wraps.append(k if k[0] == 'wrap' else ('wrap', [k[1]], False))
        # "You can't use more than 1 X Ability each turn": not modelled (one use flag per Pokémon)
        if body and ONE_PER_NAME.match(body[-1]):
            res['used'].append(('ab-one-per-name', body[-1]))
            cavs.add('onePerName')
            body = body[:-1]
    except Refuse as r:
        B.append((r.reason, r.sentence or t))
        return None
    if not body:
        B.append(('Ability: no effect text', t))
        return None
    p = Parser(ctx).run(body)
    res['used'] += p.used
    if p.blockers:
        B += p.blockers
        return None
    parts = []
    try:
        for _, it in p.items:
            if isinstance(it, Eff):
                cavs |= it.cavs
                parts.append(('fx', it.e))
            elif isinstance(it, AbItem):
                cavs |= it.cavs
                parts.append(it.a)
            elif isinstance(it, tuple) and it[0] == 'ifYouDo':
                X = it[1]
                cavs |= X.cavs
                if not parts:
                    raise Refuse("Ability: 'If you do' with nothing before it")
                prev = parts.pop()
                if prev[0] == 'fx' and prev[1] == ('switch', OWN):
                    parts.append(('fx', ite(('countGe', ('bench', OWN, ('pokemon',)), 1), seq(prev[1], X.e), SKIP)))
                elif prev[0] == 'fx' and prev[1][0] == 'move' and prev[1][1] == OWN and prev[1][2][0] == 'top' \
                        and prev[1][3:] == (('hand',), ('any',), ('all',)):
                    # "Draw N cards. If you do, X": X happens when the deck had a card to draw
                    parts.append(('fx', ite(('countGe', ('pile', OWN, ('deck',), ('any',)), 1), seq(prev[1], X.e), SKIP)))
                elif prev[0] == 'self' and prev[1][0] == 'counters':
                    # placing damage counters on this Pokémon always happens
                    parts.append(abseq(prev, ('fx', X.e)))
                else:
                    raise Refuse("Ability: 'If you do' after an effect the model cannot test")
            else:
                raise Refuse('Ability: item not expressible in an Ability')
    except Refuse as r:
        B.append((r.reason, t))
        return None
    eff = abseq(*parts)
    pre_eff = eff
    if selfko:
        if use[0] not in ('once', 'unlimited') or cost is not None or wraps or cond is not None:
            B.append(('Ability: self Knock Out with an on-play use, a cost or a condition', t))
            return None
        res['used'].append(('ab-self-ko', SELF_KO))
        eff = abseq(eff, ('self', ('counters', KO_COUNTERS)))
        cavs.add('koCounters')
        if spot != ('active',):
            # usable from the Bench: the self-Knock-Out step may fall on another Benched Pokémon (review, 0.14.0)
            cavs.add('selfKOBench')
        if any(x[0] in PLACERS for e in T.ability_scripts({'effect': pre_eff}) for x in T.prims(e)):
            cavs.add('selfKOTiming')
    for _, tests, neg in wraps:
        # a condition that is not one positive test: tested when the effect resolves, doing nothing
        # when it fails (a use to no effect, which the printed card forbids: allows more)
        if eff[0] != 'fx':
            B.append(('Ability: condition not one test, around an effect on this Pokémon', t))
            return None
        eff = ('fx', branch(tests, neg, eff[1], SKIP))
        cavs.add('noopUse')
    try:
        eff = no_effect_ability(eff, use, spot, t, cavs)
    except NotImplementedError as x:
        B.append(('Ability: use to no effect not analysed (importer error): ' + repr(x), t))
        return None
    if cost is not None:
        eff = abseq(('fx', cost), eff)
    ab = {'name': name, 'use': use, 'spot': ('some', spot) if spot else None,
          'cond': ('some', cond) if cond else None, 'effect': eff}
    # where "this Pokémon" is compiled
    places = []
    if use[0] == 'onPlay':
        self_places(eff, None, places)
    elif spot is not None:
        self_places(eff, spot, places)
    else:
        self_places(eff, ('active',), places)
        self_places(eff, ('bench',), places)
    for op, pl in places:
        if op[0] == 'energyTo':
            # `moveEnergy .own f` in every place: between any two of the player's Pokémon
            cavs.add('moveAnyPair')
        elif pl != ('active',):
            # on the Bench (or not tracked) "this Pokémon" is any Benched Pokémon (or either place)
            cavs.add('selfBench')
    scripts = T.ability_scripts(ab)
    for e in scripts:
        if not (T.hit_free(e) and T.bench_hit_free(e)):
            B.append(('Ability effect with attack damage', t))
            return None
    # the Knock Out check before the self-Knock-Out step is selfKOTiming's, not koBetweenSteps'
    for e in T.ability_scripts(dict(ab, effect=pre_eff) if selfko else ab):
        if counters_then_more(e):
            cavs.add('koBetweenSteps')
    if not T.ability_safe(ab):
        B.append(('Ability: writes a modifier the model forbids an Ability to write (AbilitySafe)', t))
        return None
    cavs.discard('_needsPoison')
    res['caveats'] |= cavs
    return ab


SELF_KO = 'If you use this Ability, this Pokémon is Knocked Out.'
# The damage counters that write "is Knocked Out" (milestone MV7b, Pokemon/SelfKO.lean, whose witness uses the same
# number): above every derived HP of a game of two 60-card decks of imported cards (survey S11 gives the bound).
KO_COUNTERS = 9999


def translate_also_ko(c, a, t, res):
    """Flygon's Ability: "Once during your turn, when you play this Pokémon from your hand to evolve 1 of your
    Pokémon, you may use this Ability. You may also use this Ability if this Pokémon is in the Active Spot and is
    Knocked Out by damage from an attack from your opponent's Pokémon. E": two Abilities of the model with the
    same name and effect, the on-play one and `triggered .koByAttack true` with place `some .active`."""
    B = res['blockers']
    a2 = dict(a)
    a2['text'] = t.replace(' ' + FLYGON_KO, '')
    sub = {'ok': False, 'term': None, 'caveats': set(), 'blockers': [], 'used': []}
    ab = translate_ability(c, a2, sub)
    res['used'] += sub['used']
    if ab is None or isinstance(ab, list) or ab['use'][0] != 'onPlay':
        B += sub['blockers'] or [('Ability: on-play part of an on-play-or-Knock-Out Ability not translated', t)]
        return None
    R = 'Ability: triggered (M8b shape), '
    cavs = set(sub['caveats'])
    if any(x[0] == 'self' for x in _abeff_leaves(ab['effect'])):
        B.append((R + 'effect on the Knocked Out Pokémon or its cards (not tracked after the Knock Out)', t))
        return None
    if cavs - {'upTo0', 'searchAny', 'mayFail', 'hiddenInfo'}:
        B.append((R + 'effect needs a caveat of activated Abilities', t))
        return None
    ko = {'name': ab['name'], 'use': ('triggered', ('koByAttack',), True), 'spot': ('some', ('active',)),
          'cond': None, 'effect': ab['effect']}
    if not T.trig_ok(T.trig_script(ko)):
        B.append((R + 'effect outside the trigger fragment (Effect.trigOk: a test or coin flip, a switch, a heal, '
                  'an exact zone move, …)', t))
        return None
    res['used'].append(('trigger-koByAttack-also', FLYGON_KO))
    res['caveats'] |= cavs | {'trigKO'}
    return [ab, ko]


def _abeff_leaves(a):
    if a[0] in ('seq', 'choice'):
        return _abeff_leaves(a[1]) + _abeff_leaves(a[2])
    return [a]


def translate_static_ability(c, a, res):
    """A static Ability (milestone M6): `AbilityUse.static` with its static effects, never used (its
    effect is `fx skip`, its place and condition none); refused with reason codes otherwise."""
    t = norm(a.get('text'))
    ctx = {'kind': 'ability', 'name': c['name'], 'base': None, 'cost': None}
    try:
        _, ss = parse_static(split_sentences(t), 'ability', ctx)
    except Refuse as r:
        res['blockers'] += static_blockers('Ability: ', t, r.reason)
        return None
    res['used'].append(('static-ability', t))
    res['caveats'] |= static_caveats(ss)
    return {'name': a.get('name') or '', 'use': ('static', ss), 'spot': None, 'cond': None, 'effect': ('fx', SKIP)}


# ------------------------------------------------------------------ triggered Abilities (milestone M8b)
#
# Two printed shapes, on a Pokémon's Ability or as a Tool's text (`ToolGrant.abilities`, for the holder):
#   damaged:    "If this Pokémon [the X this card is attached to] is in the Active Spot and is damaged by an
#               attack from your opponent's Pokémon (even if this Pokémon is Knocked Out), E"
#   koByAttack: "If this Pokémon [the X this card is attached to] [is in the Active Spot and] is Knocked Out by
#               damage from an attack from your opponent's Pokémon, E"
# and Flygon's "You may also use this Ability if this Pokémon is in the Active Spot and is Knocked Out by …",
# a second, optional koByAttack Ability with the on-play Ability's effect (`translate_ability`).
#
# The qualifiers, against the model (Pokemon/Rules.lean, triggers section and Known gaps):
# * "in the Active Spot": the Ability's place (`spot = some .active`). `damaged` fires only for the
#   opponent's Active Pokémon in any case (`HitTrig`); for `koByAttack` the place decides whether a Benched
#   Pokémon's Knock Out fires it (`GameState.koTrigs`, `Ability.spotOk`). Exact.
# * "by an attack from your opponent's Pokémon": always so in the model; triggers of the player not to move
#   fire only from that player's opponent's attack (`Move.attack`, `Move.knockOuts`). Exact.
# * "(even if this Pokémon is Knocked Out)": `damaged` resolves after the attack and before the Knock Out
#   check. Exact.
# * "is damaged by an attack" (`damaged`): decided on the damage step, with two departures (caveat
#   trigDamaged, both directions). "by damage from an attack" (`koByAttack`): read wider (caveat trigKO,
#   allows more).
# * "the Attacking Pokémon": read as the opponent's Active Pokémon when the trigger resolves (the sentence is
#   rewritten to "your opponent's Active Pokémon" and translated by the ordinary rules, which give `counters`,
#   `inflict`, …); wrong when the attack switched its attacker out or the attacker was Knocked Out by the
#   same check (caveat trigAttacker, both). It matters for every effect on the attacker, of both events.
# * "you may": `triggered ev true` (optional); otherwise mandatory.
# * coin flips are tests (`ite`), outside `Effect.trigOk`: refused, as is every effect outside the fragment
#   (a trigger outside it never fires in the model, which would under-model the card silently).
# Refused with a reason: Prize changes, replacement effects ("instead of"), reads of the damage taken,
# printed conditions (Weakness, Retreat Cost, another card in play, the attacker's kind, full HP), events of
# another Pokémon, the damaged shape not restricted to the Active Spot, effects on the Knocked Out Pokémon or
# its cards ("this Pokémon" is not tracked after a Knock Out), and other events (the M8a reasons).

TRIG_SUBJ_POKEMON = r'^If this Pokémon'
TRIG_SUBJ_TOOL = r'^If the (.+?) this card is attached to'
TRIG_DAMAGED = (r" is in the Active Spot and is damaged by an attack from your opponent's Pokémon "
                r"\(even if this (?:Pokémon|(?P<h2>.+?)) is Knocked Out\), ")
TRIG_KO_ACTIVE = r" is in the Active Spot and is Knocked Out by damage from an attack from your opponent's Pokémon, "
TRIG_KO = r" is Knocked Out by damage from an attack from your opponent's Pokémon, "
TRIG_SHAPE = re.compile(r"(?:is damaged by an attack|takes \d+ or more damage from an attack) from your opponent's.*\(even if|"
                        r"^If (?:this Pokémon|the [^.]*?this card is attached to)[^.]*? is Knocke[dt] Out by damage from an "
                        r"attack from your opponent's Pokémon")
DELUXE_DISCARD = 'If you placed any damage counters in this way, discard this card.'
FLYGON_KO = ("You may also use this Ability if this Pokémon is in the Active Spot and is Knocked Out by damage from an "
             "attack from your opponent's Pokémon.")


def trig_shape(t):
    """Is the text one of the two shapes of milestone M8b (survey S12 E1, E1', E2), whether or not it translates?"""
    return bool(TRIG_SHAPE.search(t))


def trig_head(t, tool):
    """(event, spot, holder phrase or None, rest of the first sentence) for an opening of the two shapes, or None."""
    m = re.match(TRIG_SUBJ_TOOL if tool else TRIG_SUBJ_POKEMON, t)
    if not m:
        return None
    holder = m.group(1) if tool else None
    rest = t[m.end():]
    for rx, ev, spot in ((TRIG_DAMAGED, 'damaged', ('active',)), (TRIG_KO_ACTIVE, 'koByAttack', ('active',)),
                         (TRIG_KO, 'koByAttack', None)):
        k = re.match(rx, rest)
        if k:
            h2 = k.groupdict().get('h2')
            if h2 is not None and h2 != holder:
                return None
            return ev, spot, holder, rest[k.end():]
    return None


def trig_refusal(t, tool):
    """A specific reason why a text of the two shapes is not translated before its effect is read, or None."""
    R = 'triggered (M8b shape), '
    if 'Prize' in t:
        return R + 'changes the Prize cards taken'
    if 'instead of' in t:
        return R + 'replacement effect ("instead of")'
    if re.search(r'takes \d+ or more damage|damage (?:done|taken)|amount of damage', t):
        return R + 'reads the damage taken'
    if 'Knocket' in t:
        return R + 'opening not recognised (misprint "Knocket Out" in the data)'
    if trig_head(t, tool) is None:
        if re.match(r'^If your ', t):
            return R + "fires on another Pokémon's event (your Active Pokémon of a type or name)"
        if re.match(r"^If this Pokémon is damaged by an attack", t):
            return R + 'not restricted to the Active Spot (the model fires damaged triggers in the Active Spot only)'
        return R + 'printed condition (Weakness, Retreat Cost, another card in play, the attacker\'s kind, a holder name)'
    return None


def attacking_to_active(s):
    """The model's reading of "the Attacking Pokémon": the opponent's Active Pokémon (caveat trigAttacker)."""
    return (s.replace('The Attacking Pokémon', "Your opponent's Active Pokémon")
             .replace('the Attacking Pokémon', "your opponent's Active Pokémon"))


def trig_effect(c, body, ev, spot, opt, cavs, tool, R='triggered (M8b shape), '):
    """Translate the effect sentences of a trigger; raise Refuse with a reason starting with `R`."""
    place = T.TRIG_EVENTS[ev]
    deluxe = False
    if tool and body and body[-1] == DELUXE_DISCARD:
        # Deluxe Bomb: the counters on the Attacking Pokémon are always placed (the opponent's Active Spot is
        # filled), and "this card" is the Tool of the holder, which is in the Active Spot (`damaged`)
        if ev != 'damaged' or len(body) != 2 or not re.match(r'^(?:Put|Place) \d+ damage counters on the Attacking Pokémon\.$',
                                                             body[0]):
            raise Refuse(R + "'If you placed any damage counters in this way' after another effect")
        deluxe = True
        body = body[:-1]
    if any('Attacking Pokémon' in s for s in body):
        cavs.add('trigAttacker')
    sents = [attacking_to_active(s) for s in body]
    ctx = {'kind': 'ability', 'name': c['name'], 'base': None, 'cost': None, '_cavs': cavs, 'spot': place}
    p = Parser(ctx).run(sents)
    if p.blockers:
        why, s = p.blockers[0]
        raise Refuse(R + 'effect sentence not translated (' + why + ')', s)
    parts = []
    for _, it in p.items:
        if isinstance(it, Eff):
            cavs |= it.cavs
            parts.append(('fx', it.e))
        elif isinstance(it, AbItem):
            if place is None:
                if ev == 'oppBenched':
                    raise Refuse(R + 'effect on this Pokémon (`TrigEvent.place` is none: not tracked)')
                raise Refuse(R + 'effect on the Knocked Out Pokémon or its cards (not tracked after the Knock Out)')
            cavs |= it.cavs
            parts.append(it.a)
        else:
            raise Refuse(R + 'effect item not expressible in a trigger (' + type(it).__name__ + ')')
    if deluxe:
        parts.append(('fx', ('discardTools', OWN, ('active',))))
    if not parts:
        raise Refuse(R + 'no effect')
    eff = abseq(*parts)
    ab = {'name': None, 'use': ('triggered', (ev,), opt), 'spot': ('some', spot) if spot else None, 'cond': None,
          'effect': eff}
    e = T.trig_script(ab)
    if not T.trig_ok(e):
        raise Refuse(R + 'effect outside the trigger fragment (Effect.trigOk: a test or coin flip, a switch, a heal, '
                     'an exact zone move, …)')
    if not T.TRIG_LATE[ev] and T.rec_filters(e):
        # `Ability.trigOn`: a trigger of an event that can fire before the attack and recycles never fires
        raise Refuse(R + 'effect recycles a card from a discard pile (`Ability.trigOn`: such a trigger never fires)')
    if ev in ('movedUp', 'movedDown'):
        # importer 0.15.0 (MV7c): see `translate_moved`; an optional trigger used to no effect is the declined one
        if not opt:
            raise Refuse(R + 'mandatory move trigger (none in the census)')
        cavs.discard('upTo0')
        cavs.discard('noopUse')
        if 'selfBench' in cavs and place != BENCH_SP:
            cavs.discard('selfBench')
        if place == BENCH_SP and any(it[0] == 'self' for it in abeff_selfops(eff)):
            cavs.add('selfBench')
        cavs.add('movedOnce')
        if ev == 'movedUp':
            cavs.add('movedCheckup')
    if 'noopUse' in cavs or 'koBetweenSteps' in cavs or ('selfBench' in cavs and ev not in ('movedUp', 'movedDown')):
        raise Refuse(R + 'effect needs a caveat of activated Abilities')
    if ev in ('damaged', 'koByAttack', 'oppBenched'):
        cavs.add({'damaged': 'trigDamaged', 'koByAttack': 'trigKO', 'oppBenched': 'trigBenched'}[ev])
    if tool and ev == 'damaged':
        # importer 0.15.0: a Tool's or Special Energy card's trigger fires only if the card is still attached at the end
        # of the attack (Known gaps, Energy item)
        cavs.add('trigAttached')
    return ab


BENCH_SP = ('bench',)


def abeff_selfops(a):
    """The `('self', op)` leaves of an `AbEff`."""
    if a[0] == 'self':
        return [a]
    if a[0] in ('seq', 'choice'):
        return abeff_selfops(a[1]) + abeff_selfops(a[2])
    return []


# ------------------------------------------------------------------ triggers on `TrigEvent.oppBenched` (milestone MV7)
#
# "[As long as this Pokémon is in the Active Spot, w]henever your opponent's Active Pokémon moves to the Bench during
# their turn, E" (Magcargo sv5-29, Mismagius ex me2-36). The semantics relied on (Pokemon/Card.lean `TrigEvent`,
# `Ability.trigOn`; Pokemon/Rules.lean, the triggers section above `Move` and the Known gaps entry "triggers of the
# event 'your opponent's Active Pokémon moves to the Bench'"):
# * the event is raised at its source, by the opponent's retreat (`Move.retreat`) and by a switch of their own Active
#   Pokémon inside any effect of their turn (`Run.switch .own`), and only then: the trigger's owner's own gusts do not
#   raise it ("during their turn" and "your opponent's Active Pokémon"). Exact (`Benched.retreat_fires`,
#   `Benched.switch_fires`, `Promoted.switch_attack_fires`; `Benched.copy_quiet` for an identical copy Benched later);
# * "as long as this Pokémon is in the Active Spot" is the Ability's `spot = some .active`, read on the holders marked
#   where they are at the event (`GameState.noteBenched`, `InPlay.owe`; `Gust.gust_drops_holder`,
#   `Gust.gust_adds_holder`). Exact;
# * "their new Active Pokémon" is the opponent's Active Pokémon when the trigger resolves (from the owner's side
#   `.opp`: `inflict`, `counters`), which is the Pokémon switched in, since a well-formed attack does nothing more to
#   its user's Active Spot after the switch (`Effect.switchSafe`) and inside a Trainer or Ability the trigger
#   resolves right after the step (`Resolve.trigger_first`). Exact, except the order item (caveat trigBenched);
# * the effect must be in `Effect.trigOk` and recycle nothing (`TrigEvent.late = false`), or the trigger never fires:
#   refused then. "That Pokémon" (the Pokémon moved to the Bench, Team Rocket's Dugtrio) has no target: refused.
BENCHED_RX = re.compile(r"^(As long as this Pokémon is in the Active Spot, w|W)henever your opponent's Active Pokémon moves "
                        r"to the Bench during their turn, (.+)$")
BENCHED_R = 'triggered (MV7 oppBenched), '


def translate_benched(c, a, t, m, res):
    """A triggered Ability on `TrigEvent.oppBenched`; appends a blocker and returns None if it is refused."""
    B = res['blockers']
    spot = ('active',) if m.group(1).startswith('As long as') else None
    rest = m.group(2)
    opt = False
    if rest.startswith('you may '):
        opt, rest = True, rest[len('you may '):]
    body = split_sentences(cap(rest))
    cavs = set()
    try:
        if any(re.search(r'\b[Tt]hat Pokémon\b', x) for x in body):
            raise Refuse('Ability: ' + BENCHED_R + "'that Pokémon' (the Pokémon moved to the Bench) has no target in the "
                         "model's language (Known gaps)")
        body = [x.replace('Their new Active Pokémon', "Your opponent's Active Pokémon")
                 .replace('their new Active Pokémon', "your opponent's Active Pokémon") for x in body]
        if any(re.search(r'\b[Tt]heir\b', x) for x in body):
            raise Refuse('Ability: ' + BENCHED_R + "'their' other than 'their new Active Pokémon'")
        ab = trig_effect(c, body, 'oppBenched', spot, opt, cavs, False, R='Ability: ' + BENCHED_R)
    except Refuse as r:
        B.append((r.reason, r.sentence or t))
        return None
    ab['name'] = a.get('name') or ''
    res['used'].append(('trigger-oppBenched', t))
    res['caveats'] |= cavs
    return ab


# ------------------------------------------------------------------ triggers on the player's own moves (milestone MV7c)
#
# "Once during your turn, when this Pokémon moves from your Bench to the Active Spot, you may …" (`TrigEvent.movedUp`,
# place `some .active`) and "… from the Active Spot to your Bench, you may use this Ability. E" (`movedDown`, place
# `some .bench`): Yanmega ex sv10-3, Clawitzer me1-38 (survey S20, MV7c; Pokemon/Rules.lean, Known gaps "triggers of the
# player's own moves"). The semantics relied on:
# * raised by the player's retreat, by a switch of their own Active Pokémon inside any effect of their turn, and
#   (`movedUp`) by a promotion during their turn proper; not by the opponent's gust or promotion. Exact;
# * "once during your turn" is spent at the event (`InPlay.noteMove`): caveat movedOnce (forbids some); a promotion
#   after Checkup never fires `movedUp` (a reading): caveat movedCheckup on `movedUp` triggers; the flag is the holder's
#   single `used`, exact for a holder whose one Ability is the trigger (checked here: the card has one Ability);
# * "this Pokémon" is the Pokémon at the event's place when the trigger resolves: in the Active Spot exactly the holder
#   (`movedUp`); on the Bench one Benched Pokémon chosen at resolution (`SelfOp.atS .bench`): caveat selfBench;
# * "you may": optional (`triggered ev true`). Declining and using with no effect leave the same state (the flag is
#   already spent at the event), so the activated-Ability caveats upTo0 and noopUse add no outcome and are not written;
# * the effect must be in `Effect.trigOk` and recycle nothing (`TrigEvent.late = false`), or the trigger never fires.
MOVED_RX = re.compile(r"^Once during your turn, when this Pokémon moves from (your Bench to the Active Spot|the Active Spot to "
                      r"your Bench), you may (.+)$")


def translate_moved(c, a, t, m, res):
    """A triggered Ability on `TrigEvent.movedUp` / `movedDown`; appends a blocker and returns None if refused."""
    B = res['blockers']
    ev = 'movedUp' if m.group(1).startswith('your Bench') else 'movedDown'
    R = 'Ability: triggered (MV7c ' + ev + '), '
    rest = m.group(2)
    if rest.startswith('use this Ability. '):
        rest = rest[len('use this Ability. '):]
    body = split_sentences(cap(rest))
    cavs = set()
    try:
        if len(c.get('abilities') or []) != 1:
            raise Refuse(R + "the holder has another Ability (the single `used` flag is exact for one Ability only)")
        ab = trig_effect(c, body, ev, None, True, cavs, False, R=R)
    except Refuse as r:
        B.append((r.reason, r.sentence or t))
        return None
    ab['name'] = a.get('name') or ''
    res['used'].append(('trigger-' + ev, t))
    res['caveats'] |= cavs
    return ab


def translate_trigger(c, t, res, tool):
    """A triggered Ability of the two M8b shapes (a Pokémon's, or a Tool's text): (Ability, holder filter or
    None); appends a blocker and returns None if it is refused."""
    B = res['blockers']
    head = 'Pokémon Tool: ' if tool else 'Ability: '
    why = trig_refusal(t, tool)
    if why:
        B.append((head + why, t))
        return None
    sents = split_sentences(t)
    ev, spot, holder_np, rest = trig_head(sents[0], tool)
    opt = False
    if rest.startswith('you may '):
        opt, rest = True, rest[len('you may '):]
    body = [cap(rest)] + sents[1:]
    cavs = set()
    holder = None
    try:
        if tool:
            ctx = {'kind': 'trainer', 'name': c['name'], 'base': None, 'cost': None}
            try:
                holder = parse_filter(holder_np, ctx)
            except Refuse as r:
                raise Refuse('triggered (M8b shape), holder not expressible: ' + r.reason)
            if not pokemon_only(holder):
                # the holder filter is read on the holder's top card, a Pokémon card (`Card.grantAbilities`)
                raise Refuse('triggered (M8b shape), holder filter not one on Pokémon')
        ab = trig_effect(c, body, ev, spot, opt, cavs, tool)
    except Refuse as r:
        B.append((head + r.reason, r.sentence or t))
        return None
    res['used'].append(('trigger-' + ev, sents[0]))
    res['caveats'] |= cavs
    return ab, holder


STAGES = {'Basic': ('basic',), 'Stage 1': ('stage1',), 'Stage 2': ('stage2',)}


def translate_pokemon(c, res):
    B = res['blockers']
    sub = c['_sub']
    name = c['name']
    abilities = []
    for a in c.get('abilities') or []:
        ab = translate_ability(c, a, res)
        if isinstance(ab, list):
            abilities += ab
        elif ab is not None:
            abilities.append(ab)
    if c.get('ancientTrait'):
        B.append(('Ancient Trait', ''))
    st = [STAGES[s] for s in STAGES if s in sub]
    if len(st) != 1:
        B.append(('stage not Basic, Stage 1 or Stage 2', ','.join(sorted(sub))))
        stage = None
    else:
        stage = st[0]
    other = sub - set(STAGES) - {'ex', 'MEGA', 'Tera', 'Ancient', 'Future'}
    if other:
        B.append(('Pokémon subtype not modelled', ','.join(sorted(other))))
    try:
        hp = counters(c.get('hp') or '0')
        if hp <= 0:
            raise Refuse('no HP')
    except (Refuse, ValueError):
        B.append(('HP not a positive multiple of 10', str(c.get('hp'))))
        hp = None
    types = c.get('types') or []
    if len(types) != 1 or types[0] not in T.TYPES:
        B.append(('not exactly one type', ','.join(types)))
        ptype = None
    else:
        ptype = etype(types[0])
    weak = None
    ws = c.get('weaknesses') or []
    if len(ws) > 1:
        B.append(('two Weaknesses', ''))
    elif ws:
        if ws[0].get('value') != '×2' or ws[0].get('type') not in T.TYPES:
            B.append(('Weakness not ×2', str(ws[0])))
        else:
            weak = ('some', etype(ws[0]['type']))
    res_ = None
    rs = c.get('resistances') or []
    if len(rs) > 1:
        B.append(('two Resistances', ''))
    elif rs:
        m = re.match(r'^[-−](\d+)$', rs[0].get('value') or '')
        if not m or rs[0].get('type') not in T.TYPES:
            B.append(('Resistance not -N', str(rs[0])))
        else:
            res_ = ('some', ('pair', etype(rs[0]['type']), counters(m.group(1))))
    retreat = c.get('convertedRetreatCost')
    if retreat is None:
        retreat = len(c.get('retreatCost') or [])
    if 'ex' in sub and 'MEGA' in sub:
        rb = 'megaEx'
    elif 'ex' in sub:
        rb = 'ex'
    elif 'MEGA' in sub:
        B.append(('MEGA without ex', ''))
        rb = 'none'
    else:
        rb = 'none'
    if stage is not None and stage != ('basic',) and not c.get('evolvesFrom'):
        # a Stage 1 or Stage 2 record with no evolves-from field (a data defect: Zoroark me55-96 evolves
        # from Zorua) would be a card that can never be played (`Move.evolve` needs `evolvesFrom`); found
        # in validation, importer 0.5.0
        B.append(('evolution card with no evolves-from field in the data', ''))
    tera = 'Tera' in sub
    rules = [norm(r) for r in c.get('rules') or []]
    allowed = list(RULEBOX_TEXT.get(rb, []))
    if tera:
        allowed += TERA_TEXTS
    for r in rules:
        if r not in allowed:
            B.append(('Pokémon rule text not modelled', r))
    if rb != 'none' and not any(r in RULEBOX_REQUIRED[rb] for r in rules):
        B.append(('rule box kind without its printed rule', rb))
    if tera and not any(r in TERA_TEXTS for r in rules):
        B.append(('Tera without the printed Tera rule', ''))
    attacks = []
    plan = note_plan(c, res)
    if plan is False:
        return res
    uplan = used_plan(c, res)
    if uplan is False:
        return res
    if plan and uplan:
        B.append(('a named-attack bonus and a use-history test on one card (one use record)', ''))
        return res
    for a in c.get('attacks') or []:
        nm = norm(a.get('name'))
        kw = {}
        if plan and nm == plan['writer']:
            kw['drop'], kw['note'] = plan['sentence'], True
        if plan and nm == plan['reader']:
            kw['bonus'] = plan['bonus']
        if uplan and nm == uplan['writer']:
            kw['note'], kw['use_record'] = True, True
        if uplan and nm == uplan['reader']:
            kw['drop'] = uplan['sentence']
            if uplan['bonus'] is None:
                kw['use_only'] = True
            else:
                kw['used_bonus'] = uplan['bonus']
            res['caveats'].add('usedLastBench' if uplan['bonus'] is not None else 'usedLastBenchUse')
        at = translate_attack(c, a, res, **kw)
        if at is not None:
            attacks.append(at)
    if plan and sum(1 for at in attacks if at.get('selfLock')) > 1:
        B.append(('use record (AtkLock.note) on a Pokémon with another attack that sets a lock (Test.usedLast reads one '
                  'record)', ''))
    if sum(1 for at in attacks if at.get('selfLock') == ('this',)) > 1:
        B.append(('per-attack lock: two attacks with a lock on themselves (the lock flag forbids both)', ''))
    if B:
        return res
    fields = {'name': name, 'stage': stage, 'evolvesFrom': ('some', c['evolvesFrom']) if c.get('evolvesFrom') else None,
              'hp': hp, 'type': ptype, 'attacks': attacks, 'retreat': retreat, 'weakness': weak,
              'resistance': res_, 'ruleBox': (rb,), 'tera': tera, 'abilities': abilities}
    res['term'] = ('pokemon', fields)
    res['ok'] = True
    return res


def note_plan(c, res):
    """Milestone MV6 (`NOTE_RX`): None, False (refused, a blocker appended), or the writer, the reader and the bonus."""
    hits = []
    for a in c.get('attacks') or []:
        for x in split_sentences(a.get('text')):
            m = NOTE_RX.match(x)
            if m:
                hits.append((norm(a.get('name')), x, m))
    if not hits:
        return None
    if len(hits) > 1:
        res['blockers'].append(('named-attack bonus: several sentences', ''))
        return False
    writer, sent, m = hits[0]
    reader = m.group(1)
    rs = [a for a in c.get('attacks') or [] if norm(a.get('name')) == reader]
    if len(rs) != 1:
        res['blockers'].append(('named-attack bonus on an attack this card does not have', sent))
        return False
    d = (rs[0].get('damage') or '').strip()
    md = re.match(r'^(\d+)(\+?)$', d)
    if not md or int(md.group(1)) <= 0:
        res['blockers'].append(('named-attack bonus on an attack with no positive printed damage', sent))
        return False
    base = counters(md.group(1))
    if m.group(2):
        bonus = counters(m.group(2))
    else:
        if md.group(2):
            res['blockers'].append(('"base damage is N" on an attack whose damage text adds more', sent))
            return False
        bonus = counters(m.group(3)) - base
        if bonus <= 0:
            res['blockers'].append(('"base damage is N" not above the printed damage', sent))
            return False
    res['used'].append(('named-attack-bonus', sent))
    return {'writer': writer, 'reader': reader, 'sentence': sent, 'bonus': bonus}


# importer 0.16.0 (milestone MV9, survey S23 group B1): "If this Pokémon used X during your last turn, this attack does N
# more damage." and "You can use this attack only if this Pokémon used X during your last turn.", where X is an attack of
# the same card. The model's per-Pokémon use record (`Attack.selfLock := .note`, written by X when it is used,
# `GameState.afterAttack`; in force through its owner's next turn, `LockState.shift`; read by `Test.usedLast`) is that
# history, with one departure: the record ends when the Pokémon moves to the Bench or evolves (`InPlay.unlock`), which
# print says of effects of attacks (2026 pp. 11, 20) but not of this condition (a reading, Known gaps: one-turn history;
# caveats `usedLastBench`, `usedLastBenchUse`). The record is set by every use of X, whatever X then does: print's
# "used X" is a use too, so the refusal of a lock on an attack that may do nothing does not apply. Written only when X
# is one attack of the card, the card has one such sentence, and no other attack of the card sets a lock (the record is
# one per Pokémon). The bonus needs a printed "+"; the use condition is `ite (usedLast own) skip <no resolution>`
# before the damage (`Move.attack` needs a resolution; a Confused attempt of it is refused print-side and allowed by
# the model, whose outcome is that of a Confused attempt of X, which costs no more: see S23).
USED_RX = re.compile(r"^(?:If this Pokémon used (.+?) during your last turn, this attack does (\d+) more damage|"
                     r"You can use this attack only if this Pokémon used (.+?) during your last turn)\.$")


def used_plan(c, res):
    """Importer 0.16.0 (`USED_RX`): None, False (refused, a blocker appended), or the writer, the reader, the sentence
    and the bonus (None for the use condition)."""
    hits = []
    for a in c.get('attacks') or []:
        for x in split_sentences(a.get('text')):
            m = USED_RX.match(x)
            if m:
                hits.append((norm(a.get('name')), x, m))
    if not hits:
        return None
    if len(hits) > 1:
        res['blockers'].append(('use-history test: several sentences', ''))
        return False
    reader, sent, m = hits[0]
    writer = m.group(1) or m.group(3)
    ws = [a for a in c.get('attacks') or [] if norm(a.get('name')) == writer]
    if len(ws) != 1:
        res['blockers'].append(('use-history test on an attack this card does not have', sent))
        return False
    bonus = None
    if m.group(2):
        rs = [a for a in c.get('attacks') or [] if norm(a.get('name')) == reader]
        d = (rs[0].get('damage') or '').strip()
        if not re.match(r'^\d+\+$', d):
            res['blockers'].append(('use-history bonus without a printed "+"', sent))
            return False
        bonus = counters(m.group(2))
    res['used'].append(('used-last-turn', sent))
    return {'writer': writer, 'reader': reader, 'sentence': sent, 'bonus': bonus}


def translate_attack(c, a, res, drop=None, note=False, bonus=None, use_record=False, use_only=False, used_bonus=None):
    B = res['blockers']
    cost = []
    for s in [x for x in a.get('cost') or [] if x != 'Free']:
        if s not in T.TYPES:
            B.append(('attack cost symbol not modelled', s))
            return None
        cost.append(etype(s))
    d = (a.get('damage') or '').strip()
    m = re.match(r'^(\d*)([+×x\-−]?)$', d)
    if not m:
        B.append(('printed damage not understood', d))
        return None
    base = None
    suffix = m.group(2).replace('x', '×').replace('−', '-')
    if m.group(1):
        try:
            base = counters(m.group(1))
        except Refuse:
            B.append(('damage not a multiple of 10', d))
            return None
    elif suffix:
        B.append(('printed damage not understood', d))
        return None
    ctx = {'kind': 'attack', 'name': c['name'], 'base': base, 'cost': cost,
           'evolvesFrom': norm(c.get('evolvesFrom')) or None}
    sents = split_sentences(a.get('text'))
    if drop is not None:
        sents = [x for x in sents if x != drop]
    lock, sents = self_lock(sents, norm(a.get('name')), res)
    if lock is False:
        return None
    if note:
        if lock:
            B.append(('a lock and a use record on one attack (one AtkLock)', norm(a.get('text'))))
            return None
        lock = 'note'
    p = Parser(ctx).run(sents)
    if bonus is not None:
        p.items.append((len(sents), Dmg('lastUse', bonus)))
    if used_bonus is not None:
        # importer 0.16.0: "If this Pokémon used X during your last turn, this attack does N more damage." (printed "+")
        p.items.append((len(sents), Dmg('cond', [('usedLast', OWN)], False, used_bonus)))
    if use_only:
        # importer 0.16.0: "You can use this attack only if this Pokémon used X during your last turn."
        p.items.insert(0, (-1, Eff(ite(('usedLast', OWN), SKIP, NO_PLAY), pre=True)))
    res['used'] += p.used
    if p.blockers:
        B += p.blockers
        return None
    if lock and not use_record and any(isinstance(it, Nothing) or
                                       (isinstance(it, tuple) and it[0] in ('wrapFlip', 'wrapIf', 'wrapFn'))
                                       for _, it in p.items):
        # print sets no lock when the attack does nothing; the model's lock is set by every use of the attack
        B.append(('per-attack lock on an attack that may do nothing (the model sets the lock on every use)',
                  norm(a.get('text'))))
        return None
    try:
        damage, eff, cavs = build_attack(base or 0, suffix, p.items, cost)
    except Refuse as r:
        B.append((r.reason, norm(a.get('text'))))
        return None
    if '_needsPoison' in cavs:
        cavs.discard('_needsPoison')
        if not poison_before_up(eff):
            B.append(('Poison strength without a Poison before it', norm(a.get('text'))))
            return None
    if not T.attack_wf(damage, eff):
        B.append(('attack not well formed in the model (Attack.wf)', norm(a.get('text'))))
        return None
    if lock and T.switches_own(eff):
        # `Attack.lockSet` sets no lock for an attack that may switch its user out (Known gaps, per-Pokémon attack locks)
        B.append(('per-attack lock on an attack that may switch its user out (the model sets no lock)', norm(a.get('text'))))
        return None
    res['caveats'] |= cavs
    out = {'name': a.get('name') or '', 'cost': cost, 'damage': damage, 'effect': eff, 'gx': False}
    if lock:
        out['selfLock'] = (lock,)
    return out


# milestone MV4 (importer 0.10.0): per-Pokémon attack locks (`Attack.selfLock`, `InPlay.lk`, Pokemon/Lock.lean). Only the
# two printed forms, as a sentence of their own (not inside a coin flip or a condition): "During your next turn, this
# Pokémon can't use [this attack's own name]." (`.this`) and "During your next turn, this Pokémon can't attack." / "…
# can't use attacks." (`.all`). The model sets the lock on the attacker after the attack (`GameState.afterAttack`),
# brings it into force at the end of its owner's turn, reads it in the owner's next turn and clears it when the Pokémon
# moves to the Bench or evolves, which is what print says of effects of attacks (2026 rulebook pp. 11, 20). Refused: a
# lock on a different attack, several lock sentences, a lock on an attack that may do nothing (print sets none then) or
# may switch its user out (the model sets none then), a Tool's attack with a lock, a Pokémon with two `.this` attacks
# (`AtkLock.allows .this` forbids every attack whose `selfLock` is `.this`, including one a Tool gives).
LOCK_RX = re.compile(r"^During your next turn, this Pokémon can't (attack|use attacks|use (.+?))\.?$")


def self_lock(sents, atk_name, res):
    """(lock, other sentences): lock is None, 'this' or 'all'; False if refused (a blocker is appended)."""
    hits = [(i, LOCK_RX.match(x)) for i, x in enumerate(sents)]
    hits = [(i, m) for i, m in hits if m]
    if not hits:
        return None, sents
    if len(hits) > 1:
        res['blockers'].append(('per-attack lock: several lock sentences', ' '.join(sents)))
        return False, sents
    i, m = hits[0]
    if m.group(1) in ('attack', 'use attacks'):
        lock = 'all'
    elif m.group(2) == atk_name:
        lock = 'this'
    else:
        res['blockers'].append(('per-attack lock on a different attack', sents[i]))
        return False, sents
    res['used'].append(('self-lock-' + lock, sents[i]))
    return lock, sents[:i] + sents[i + 1:]


def poison_before_up(e):
    """Every `poisonUp` comes right after an `inflict poisoned` in a `seq`."""
    ok = [True]

    def flat(x):
        if x[0] == 'seq':
            return flat(x[1]) + flat(x[2])
        return [x]

    def walk(x):
        if x[0] == 'seq':
            fl = flat(x)
            for j, y in enumerate(fl):
                if y[0] == 'poisonUp' and not (j > 0 and fl[j - 1] == ('inflict', ('poisoned',))):
                    ok[0] = False
                if y[0] != 'seq':
                    walk_inner(y)
            return
        if x[0] == 'poisonUp':
            ok[0] = False
        walk_inner(x)

    def walk_inner(x):
        for s in T.subs(x):
            walk(s)
    walk(e)
    return ok[0]
assert set(CAVEATS) == set(CAVEAT_DIRECTION)
