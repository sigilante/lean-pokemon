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
"damage from and effects of attacks" (prevention of effects), filtered lingering prevention.
"""
import re

import terms as T
from terms import OWN, OPP, SKIP, seq, choice, ite

ENERGY_F = ('energy',)

CAVEATS = {
    'perPokemon': "a lingering effect printed on one Pokémon ('this Pokémon', 'the Defending Pokémon') "
                  "is a modifier of its player in the model (Known gaps: modifiers belong to a player)",
    'recoil': "self-damage ('also does N damage to itself') is written as damage counters (selfDamage): "
              "no Weakness, Resistance or modifier applies to it (Known gaps)",
    'benchMods': "attack damage to Benched Pokémon takes no bonus, reduction or prevention in the model "
                 "(Known gaps, milestone M3)",
    'mayFail': "an attach or Bench placement may do nothing in the model (`attach` and `putBench` always allow "
               "nothing), a superset of the printed 'attach a …' from the hand or discard pile, and of 'if you can' "
               "(Known gaps)",
    'upTo0': "'up to N' in a Trainer or an Ability allows 0 in the model; the rulebook asks for at least 1 outside "
             "attacks (2026 rulebook p. 21; Known gaps, zone moves item)",
    'hiddenInfo': "a sentence that only reveals or looks at cards is a no-op (hidden information is not "
                  "modelled, Known gaps)",
    'aceSpec': "the ACE SPEC deck-building limit is not modelled (no deck construction in the model)",
    'poisonStrength': "a stronger Poison ('N damage counters instead of 1') is written as Poison plus "
                      "poisonUp (N-1); the Known gaps list numbered Poison variants as absent",
    'selfInDiscard': "the model resolves a Trainer with the card already in the discard pile, so its "
                     "recycling filter or discard count can see the card itself (Known gaps)",
    'searchAny': "a deck search for 'a card' (any card) may find nothing in the model",
    'noopPlay': "a Trainer whose effect may do nothing in the model (switch with an empty Bench, heal an "
                "undamaged Pokémon, cure a Pokémon with no Special Condition) can be played to no effect; "
                "a Trainer cannot be played when its effect cannot happen (taken from rulings, not in the "
                "2023 rulebook on hand)",
    'koBetweenSteps': "a Trainer or Ability sentence written as several primitives gets a Knock Out check between "
                      "them, and after a Knock Out later steps act on the replacement (Known gaps, TRun, M8a)",
    'noopUse': "an Ability whose effect may do nothing in the model (a switch with an empty Bench, a heal of an "
               "undamaged Pokémon, a move of Energy that moves none, a take when there is nothing to take, a "
               "condition tested when the effect resolves) can be used to no effect, marking its Pokémon as used; "
               "whether the printed game allows such a use was not checked",
    'selfBench': "'this Pokémon' on the Bench is one Benched Pokémon chosen when the effect resolves, and for an "
                 "on-play Ability the Active Pokémon or a Benched one (Known gaps, M8a: SelfOp.at)",
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
                   "'exact once the bound covers the cards that can be taken'); for 'discard all' with more than 60 the attack has "
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
}


# The direction of each caveat: does the model's term allow outcomes the printed card does not
# ('allows more'), forbid outcomes the printed card allows ('forbids some'), or both? A card imported
# with caveats is in general neither an over- nor an under-approximation of its printed card.
CAVEAT_DIRECTION = {
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
    attack doing nothing is what the card does when it cannot, so no caveat."""
    if ctx['kind'] == 'trainer':
        return {'noopPlay'}
    if ctx['kind'] == 'ability':
        return {'noopUse'}
    return set()


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
    if s in ('Energy', 'Basic Energy'):
        # With Basic Energy only in the model (Special Energy cards are not imported), "an Energy
        # card" and "a Basic Energy card" are the same filter (`Filter.energy`, Pokemon/Card.lean).
        return ENERGY_F
    m = re.match(r'^Basic ' + TYPE_RE + r' Energy$', s)
    if m:
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
        bad = sorted(kinds & {'Special Energy', 'Trainer (other)'})
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


def set_names(cards):
    KNOWN_NAMES.clear()
    NAME_STAGES.clear()
    TOOL_ATTACKS.clear()
    OWNERS.clear()
    ALL_NAMES.clear()
    for c in cards:
        ALL_NAMES.add(c['name'])
        if c['supertype'] == 'Pokémon':
            m = re.match(r"^(.+?)'s ", c['name'])
            if m:
                OWNERS.add(m.group(1))
        if c['supertype'] == 'Trainer' and 'Pokémon Tool' in c['_sub']:
            TOOL_ATTACKS.update(norm(a.get('name')) for a in c.get('attacks') or [])
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
    from rulings; not in the 2023 rulebook on hand), so in a Trainer the case with nothing to take
    has no resolution: `exactly 1` of none, the model's convention for an unpayable cost
    (Pokemon/Rules.lean, `Move.item`), and a Trainer that can take some but fewer than `n` takes all
    of them.

    An Ability follows the attack convention (it does what it can, nothing when nothing can be
    taken) and is marked `noopUse`: whether the printed game lets an Ability be used when its effect
    cannot happen was not checked, so the model allows such a use (allows more)."""
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
    if x == 'Prize card your opponent has taken':
        return lambda k: ('count', ('prizesTaken', OPP), k)
    if x == 'Prize card you have taken':
        return lambda k: ('count', ('prizesTaken', OWN), k)
    if x == "Special Condition affecting your opponent's Active Pokémon":
        return lambda k: ('count', ('conds', OPP), k)
    if x == 'type of Basic Energy attached to all of your Pokémon':
        return lambda k: ('count', ('energyTypes', OWN), k)
    x = re.sub(r'^Basic Energy attached', 'Energy attached', x)
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


def parse_test(c, ctx):
    """A condition 'If C, ...' to (tests, negated): the condition holds iff some test holds
    (or, when negated, iff none does)."""
    c = c.strip()
    # importer 0.9.0: a misprint in the data ("this Pokémon has any Fire Energy attaches", Zekrom)
    c = c.replace(' Energy attaches', ' Energy attached')
    r = parse_test_s16(c, ctx)
    if r is not None:
        return r
    opp_a = "your opponent's Active Pokémon"
    m = re.match(r'^(this Pokémon|' + opp_a + r') (?:already )?has (any|no) damage counters on it$', c)
    if m:
        w = OWN if m.group(1) == 'this Pokémon' else OPP
        return [('atLeast', w, 1)], m.group(2) == 'no'
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
    raise Refuse('condition not expressible: ' + c)


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
    if h in ('pokemon', 'basic', 'stage', 'ptype', 'ex', 'tera', 'hasAttack', 'hasAbility'):
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
    """`if any test then a else b` (or the reverse when negated), as nested `ite`."""
    if neg:
        a, b = b, a
    out = b
    for t in reversed(tests):
        out = ite(t, a, out)
    return out


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


@rule('recoil', r'This Pokémon also does (\d+) damage to itself\.', 'A', 'selfDamage n')
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


ATTACH_TGT = (r'(this Pokémon|1 of your Pokémon|1 of your Benched Pokémon|your Pokémon in any way you like|'
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
    return ('attach', OWN, src, f, ('bench',), ('any',))


@rule('search-attach', r'Search your deck for (up to \d+|an?|\d+) (.+?) and attach (?:it|them) to ' + ATTACH_TGT + r'\.',
      'B', 'attach own deck F spot any (n times)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    if f != ENERGY_F and f[0] != 'energyOf':
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
    if f != ENERGY_F and f[0] != 'energyOf':
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


@rule('discard-energy', r"Discard (an|a|all|\d+) (?:(Basic )?" + TYPE_RE + r" )?Energy (?:cards? )?from (this Pokémon|"
      + OPPA + r')\.', 'B',
      'ite (countGe (energy w F) n) (discardEnergy w active F (exactly n)) (... all | skip); in a Trainer no fallback when none (min_take)')
def _(m, ctx):
    q = m.group(1)
    t = m.group(3)
    if t in ('Dragon', 'Colorless'):
        raise Refuse('Energy of a type with no Basic Energy')
    f = ('energyOf', etype(t)) if t else ENERGY_F
    if m.group(4) == 'this Pokémon':
        if ctx['kind'] != 'attack':
            raise Refuse('this Pokémon outside an attack')
        w = OWN
    else:
        w = OPP
    mk = lambda qq: ('discardEnergy', w, ('active',), f, qq)
    if q == 'all':
        return Eff(mk(('all',)))
    return Eff(min_take(('energy', w, f), num(q), mk, ctx))


@rule('ling-reduce-self', r"During your opponent's next turn, this Pokémon takes (\d+) less damage from attacks \(after applying Weakness and Resistance\)\.",
      'A', 'linger own next (reduce n)')
def _(m, ctx):
    return Eff(('linger', OWN, ('next',), ('reduce', counters(m.group(1)))), {'perPokemon'})


@rule('ling-prevent-self', r"During your opponent's next turn, prevent all damage done to this Pokémon by attacks\.",
      'A', 'linger own next prevent')
def _(m, ctx):
    return Eff(('linger', OWN, ('next',), ('prevent',)), {'perPokemon'})


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
    if t in ('Dragon', 'Colorless'):
        raise Refuse('Energy of a type with no Basic Energy')
    return ('energyOf', etype(t)) if t else ENERGY_F


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
    if f != ENERGY_F and f[0] != 'energyOf':
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
    if f != ENERGY_F and f[0] != 'energyOf':
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
    if f != ENERGY_F and f[0] != 'energyOf':
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


@rule('discard-energy-1-opp', r"Discard an Energy from 1 of your opponent's Pokémon\.", 'B',
      'ite (countGe (energyAll opp energy) 1) (choice (discardEnergy opp active energy (exactly 1)) '
      '(ite (countGe (bench opp pokemon) 1) (discardEnergy opp bench energy (exactly 1)) none)) (skip | none)')
def _(m, ctx):
    # one Energy from one of the opponent's Pokémon that has one: `exactly 1` has a resolution only on a Pokémon with
    # an Energy (`ZStep.discardActive`, `discardBench`), and the Bench branch is guarded so that `discardNone` (empty
    # Bench) is not a do-nothing resolution. With no Energy in play on that side: nothing in an attack, no resolution
    # in a Trainer (min_take's convention)
    e = choice(('discardEnergy', OPP, ('active',), ENERGY_F, ('exactly', 1)),
               ite(('countGe', ('bench', OPP, ('pokemon',)), 1),
                   ('discardEnergy', OPP, ('bench',), ENERGY_F, ('exactly', 1)), NO_PLAY))
    if ctx['kind'] == 'ability':
        ctx['_cavs'].add('noopUse')
    ctx['_s16coin'] = True
    return Eff(ite(('countGe', ('energyAll', OPP, ENERGY_F), 1), e, NO_PLAY if ctx['kind'] == 'trainer' else SKIP))


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
        # "Discard all Energy from this Pokémon, and this attack [also] does ...": two sentences. The
        # discard and the damage commute in the model (the damage step reads no Energy of the attacker),
        # so the order of the two items does not matter.
        # Since importer 0.7 (milestone MV2 census, S13 §B) the discard may be of N, or of all of a type: the damage
        # step and a damage-to-chosen-Pokémon step read no Energy of the attacker either.
        m = re.match(r"^(Discard (?:all|an|a|\d+) (?:(?:Basic )?" + TYPE_RE + r" )?Energy from this Pokémon), and "
                     r"(?P<dmg>this attack (?:also )?does (?!.*for each).+)$", s)
        if m and ctx['kind'] == 'attack':
            first = self.one(m.group(1) + '.')
            second = self.one(m.group('dmg')[0].upper() + m.group('dmg')[1:])
            self.used.append(('discard-all-and', s))
            if m.group(1) != 'Discard all Energy from this Pokémon' and isinstance(second, Dmg):
                # importer 0.7.0: the discard is resolved before the damage step, as printed (a static bonus
                # with an Energy condition on the attacker could otherwise see the Energy; validation, MV2). The
                # v0.6.0 form "Discard all Energy from this Pokémon, and …" keeps its earlier term.
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

    def s16_step(self, S, i, nxt):
        """Multi-sentence forms of importer 0.9.0 (survey S16, class I); None if none applies."""
        s = S[i]
        ctx = self.ctx
        nx2 = S[i + 2] if i + 2 < len(S) else ''
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
            self.used.append(('ab-look-top-may-discard', s + ' ' + nxt))
            self.items.append((i, Eff(choice(('move', OWN, ('top', 1), ('discard',), ('any',), ('all',)), SKIP))))
            return i + 2
        if (s == 'Look at the top 2 cards of your deck and put 1 of them into your hand.'
                and nxt == 'Put the other card on the bottom of your deck.'):
            self.used.append(('ab-look-2-take-1', s + ' ' + nxt))
            two = seq(('move', OWN, ('top', 2), ('hand',), ('any',), ('exactly', 1)),
                      ('move', OWN, ('top', 1), ('bottom',), ('any',), ('all',)))
            self.items.append((i, Eff(ite(('countGe', ('pile', OWN, ('deck',), ('any',)), 2), two,
                                          ('move', OWN, ('top', 1), ('hand',), ('any',), ('all',))))))
            return i + 2
        m = re.match(r'^Look at the top (\d+) cards of your deck, reveal (an?) (.+?) you find there, and put it into your hand\.$', s)
        if m and nxt == 'Shuffle the other cards back into your deck.':
            k = num(m.group(1))
            f = parse_filter(m.group(3), self.ctx)
            self.used.append(('ab-look-top-reveal-take', s + ' ' + nxt))
            self.items.append((i, Eff(seq(('move', OWN, ('top', k), ('hand',), f, ('upTo', 1)), ('shuffle',)))))
            return i + 2
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
    if tree[0] == 'ite':
        return ('ite', tree[1], tmap(tree[2], f), tmap(tree[3], f))
    if tree[0] == 'choice':
        return ('choice', tmap(tree[1], f), tmap(tree[2], f))
    if tree[0] in ('T1', 'TM'):
        raise Refuse('computed damage to a chosen Pokémon')
    if tree[0] == 'S':
        raise Refuse('another damage change with damage to each Pokémon of a kind')
    if tree[0] == 'FU':
        raise Refuse('another damage change with "for each card you discarded in this way"')
    raise AssertionError(tree)


def tbranch(tests, neg, a, b):
    if neg:
        a, b = b, a
    out = b
    for t in reversed(tests):
        out = ('ite', t, a, out)
    return out


def dmg(a, ig=None):
    """A damage step to the opponent's Active Pokémon; with `ig` (milestone MV3) the steps of the calculation it
    switches off (`Effect.damage a ig`; `{}` is the default and is not written)."""
    return ('damage', a, ig) if ig else ('damage', a)


def to_effect(tree, drain=False, ig=None):
    if ig and drain:
        raise Refuse('drain with a damage step that ignores Weakness, Resistance or effects')
    if tree[0] == 'L':
        return ('drain', tree[1]) if drain else dmg(tree[1], ig)
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
    if tree[0] == 'TM':
        # milestone MV2: `Effect.hitSome m n`, unfolded
        if drain:
            raise Refuse('drain with damage to chosen Pokémon')
        _, k, n = tree
        return some_of(k, dmg(('const', n), ig), lambda j: ('benchSome', OPP, j, ('any',), True, n))
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
    if tree[0] == 'L':
        return amt_reads(tree[1])
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
    for idx, it in items:
        if isinstance(it, Eff) and it.pre:
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


def translate_card(c):
    """Translate a card record (`_translate_card`), then add the caveat `abilityByTool` to every imported term that
    reads `Filter.hasAbility` (wherever it occurs: a count, a test, a static prevention)."""
    res = _translate_card(c)
    if res['ok'] and 'hasAbility' in repr(res['term']):
        res['caveats'].add('abilityByTool')
    if res['ok'] and 'prizesTaken' in repr(res['term']):
        res['caveats'].add('prizes6')
    return res


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
            B.append(('Special Energy', ''))
        res['ok'] = not B
        return res
    if sup == 'Trainer':
        return translate_trainer(c, res)
    return translate_pokemon(c, res)


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
                B.append(('Stadium: activated effect not expressible: ' + r.reason.replace('Ability: ', ''), t))
                return res
            sents = [cap(mc.group(2))] + sents[1:]
        p = Parser(ctx).run(sents)
        res['used'] += [('stadium-use', t)] + p.used
        if p.blockers:
            # the reasons quote the text as read in the second person; the sentence is the printed one
            B += [('Stadium: activated effect not expressible: ' + a, t) for a, _ in p.blockers]
            return res
        effs = []
        for _, it in p.items:
            if not isinstance(it, Eff) or it.pre:
                B.append(('Stadium: activated effect not expressible: not a plain effect', t))
                return res
            res['caveats'] |= it.cavs
            effs.append(it.e)
        e = seq(*([cost] if cost else []), *effs)
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
    ('noRetreat', r'no Retreat Cost', '"has no Retreat Cost" (a set form; the model has more and less only)'),
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


def static_ability_sentence(s, ctx, src=None, need=None):
    """One sentence of a static Ability to `Static`s; `src` and `need` from the prefixes."""
    m = re.match(r'^As long as this Pokémon is (in the Active Spot|on your Bench), (.+)$', s)
    if m:
        if src is not None:
            raise Refuse('other', s)
        return static_ability_sentence(cap(m.group(2)), ctx, 'active' if 'Active' in m.group(1) else 'bench', need)
    m = re.match(r'^If this Pokémon has (any|(\d+) or more) (?:(Basic) )?(?:' + TYPE_RE + r' )?Energy attached, it (.+)$', s)
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
    m = re.match(r'^As long as the (.+?) this card is attached to is in the Active Spot, the Retreat Cost of both Active '
                 r'Pokémon is (\w+) (more|less)\.$', s)
    if m:
        return m.group(1), [mk_static('all', retreat_eff(m.group(2), m.group(3)), tgt='active', src='active')]
    raise Refuse('other', s)


def static_stadium_sentence(s, ctx):
    """One sentence of a Stadium's static text to `Static`s (`all`: both players' Pokémon)."""
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
        if s['eff'][0] == 'prevent' and s['tgt'] != ('some', ('active',)):
            cv.add('staticPreventBench')
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
    if re.search(r'if you played .+ this turn|last turn',
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
    if len(tests) == 1 and not neg:
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
    if FLYGON_KO in t:
        # an on-play Ability that may also be used on a Knock Out (Flygon me2-53): the on-play Ability, and an
        # optional `koByAttack` trigger in the Active Spot with the same effect
        return translate_also_ko(c, a, t, res)
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
    for _, tests, neg in wraps:
        # a condition that is not one positive test: tested when the effect resolves, doing nothing
        # when it fails (a use to no effect, which the printed card forbids: allows more)
        if eff[0] != 'fx':
            B.append(('Ability: condition not one test, around an effect on this Pokémon', t))
            return None
        eff = ('fx', branch(tests, neg, eff[1], SKIP))
        cavs.add('noopUse')
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
        if counters_then_more(e):
            cavs.add('koBetweenSteps')
    if not T.ability_safe(ab):
        B.append(('Ability: writes a modifier the model forbids an Ability to write (AbilitySafe)', t))
        return None
    cavs.discard('_needsPoison')
    res['caveats'] |= cavs
    return ab


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


def trig_effect(c, body, ev, spot, opt, cavs, tool):
    """Translate the effect sentences of a trigger; raise Refuse with a reason starting 'triggered (M8b shape), '."""
    R = 'triggered (M8b shape), '
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
    if 'noopUse' in cavs or 'selfBench' in cavs or 'koBetweenSteps' in cavs:
        raise Refuse(R + 'effect needs a caveat of activated Abilities')
    cavs.add('trigDamaged' if ev == 'damaged' else 'trigKO')
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
    for a in c.get('attacks') or []:
        at = translate_attack(c, a, res)
        if at is not None:
            attacks.append(at)
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


def translate_attack(c, a, res):
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
    lock, sents = self_lock(sents, norm(a.get('name')), res)
    if lock is False:
        return None
    p = Parser(ctx).run(sents)
    res['used'] += p.used
    if p.blockers:
        B += p.blockers
        return None
    if lock and any(isinstance(it, Nothing) or (isinstance(it, tuple) and it[0] in ('wrapFlip', 'wrapIf', 'wrapFn'))
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
