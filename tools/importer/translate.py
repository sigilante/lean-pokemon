"""Translate one card record into a term of the model's card language, or refuse it.

Conservative by design: a card is accepted only if every static field is in the model's range and
every sentence of its text is matched by a rule of the table below (`RULES`, plus the multi-sentence
forms in `Parser`), each of which is meant to say exactly what the sentence says under the model's
semantics (Pokemon/Effect.lean, Pokemon/Rules.lean). A rule that knowingly loses a detail named in
the model's Known gaps attaches a caveat code (`CAVEATS`); such cards are counted apart. Anything
else blocks the card, and every blocker is recorded (not only the first), so that the coverage report
can rank the mechanisms by how many cards each blocks alone.
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
    'mayFail': "an attach or Bench placement from a public zone (discard pile) may do nothing in the model, "
               "a superset of the printed 'if you can' (Known gaps)",
    'upTo0': "'up to N' in a Trainer allows 0 in the model; today's rule asks for at least 1 (Known gaps, S8 PP26)",
    'hiddenInfo': "a sentence that only reveals or looks at cards is a no-op (hidden information is not "
                  "modelled, Known gaps)",
    'aceSpec': "the ACE SPEC deck-building limit is not modelled (no deck construction in the model)",
    'poisonStrength': "a stronger Poison ('N damage counters instead of 1') is written as Poison plus "
                      "poisonUp (N-1); the Known gaps list numbered Poison variants as absent",
    'selfInDiscard': "the model resolves a Trainer with the card already in the discard pile, so its "
                     "recycling filter or discard count can see the card itself (Known gaps)",
    'searchAny': "a deck search for 'a card' (any card) may find nothing in the model",
    'koBetweenSteps': "a Trainer sentence written as several primitives gets a Knock Out check between "
                      "them (Known gaps, TRun)",
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
    if s in ('Energy', 'Basic Energy'):
        # With Basic Energy only in the model (Special Energy cards are not imported), "an Energy
        # card" and "a Basic Energy card" are the same filter (`Filter.energy`, Pokemon/Card.lean).
        return ENERGY_F
    m = re.match(r'^Basic ' + TYPE_RE + r' Energy$', s)
    if m:
        if m.group(1) in ('Dragon', 'Colorless'):
            raise Refuse('no Basic Energy of that type')
        return ('energyOf', etype(m.group(1)))
    if s in ('SELF', ctx.get('name')):
        return ('named', ctx['name'])
    raise Refuse('card kind with no filter: ' + s)


def parse_qty_np(q):
    """'up to 2 ', 'a ', 'an ', '2 ' -> (n, upto)."""
    q = q.strip()
    m = re.match(r'^up to (\d+|a|an|one|two|three)$', q)
    if m:
        return num(m.group(1)), True
    return num(q), False


def min_take(count, n, make):
    """Take `n` if at least `n` are there, else all of them: the printed 'discard N' when fewer may
    be available ("as much as you can"). `make(q)` builds the move for quantity `q`."""
    if n == 1:
        return ite(('countGe', count, 1), make(('exactly', 1)), SKIP)
    return ite(('countGe', count, n), make(('exactly', n)), make(('all',)))


def parse_count(x, ctx):
    """'for each X' to a function k -> Amt (k counters per unit)."""
    x = x.strip()
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
    raise Refuse('count not expressible: ' + x)


def parse_test(c, ctx):
    """A condition 'If C, ...' to (tests, negated): the condition holds iff some test holds
    (or, when negated, iff none does)."""
    c = c.strip()
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
    raise Refuse('condition not expressible: ' + c)


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
    """A plain effect, resolved after the damage step in printed order."""
    def __init__(self, e, cavs=()):
        self.e, self.cavs = e, set(cavs)


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


class Cost:
    """A Trainer's cost ('You can use this card only if you discard N other cards from your hand'),
    resolved first."""
    def __init__(self, e):
        self.e = e


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
      'choice (damage (const n)) (benchDamage opp n)')
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


@rule('counters-each-opp', r"Put (\d+) damage counters? on each of your opponent's Pokémon\.", 'B',
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
    return Eff(('heal', counters(m.group(1))))


@rule('heal-1-of-your', r'Heal (\d+) damage from 1 of your Pokémon\.', 'B', 'choice (heal n) (benchHeal n)')
def _(m, ctx):
    n = counters(m.group(1))
    return Eff(choice(('heal', n), ('benchHeal', n)))


@rule('heal-1-bench', r'Heal (\d+) damage from 1 of your Benched Pokémon\.', 'B', 'benchHeal n')
def _(m, ctx):
    return Eff(('benchHeal', counters(m.group(1))))


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
    return Eff(('cure',))


@rule('counters-opp-active', r'Put (\d+) damage counters? on ' + OPPA + r'\.', 'B', 'counters n')
def _(m, ctx):
    return Eff(('counters', num(m.group(1))))


@rule('counters-opp-1bench', r"Put (\d+) damage counters? on 1 of your opponent's Benched Pokémon\.", 'B',
      'benchCounters opp n')
def _(m, ctx):
    return Eff(('benchCounters', OPP, num(m.group(1))))


@rule('counters-opp-1', r"Put (\d+) damage counters? on 1 of your opponent's Pokémon\.", 'B',
      'choice (counters n) (benchCounters opp n)')
def _(m, ctx):
    n = num(m.group(1))
    return Eff(choice(('counters', n), ('benchCounters', OPP, n)))


@rule('counters-opp-each-bench', r"Put (\d+) damage counters? on each of your opponent's Benched Pokémon\.", 'B',
      'spreadCounters opp n')
def _(m, ctx):
    return Eff(('spreadCounters', OPP, num(m.group(1))))


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
    return Eff(('switch', OWN))


@rule('gust', r"Switch in 1 of your opponent's Benched Pokémon to the Active Spot\.", 'B', 'switch opp')
def _(m, ctx):
    return Eff(('switch', OPP))


@rule('switch-out-opp', r"Switch out your opponent's Active Pokémon to the Bench\. \(Your opponent chooses the new Active Pokémon\.\)",
      'B', 'switch opp')
def _(m, ctx):
    return Eff(('switch', OPP))


@rule('shuffle', r'(?:Then, shuffle your deck|Shuffle your deck afterward)\.', 'B', 'shuffle')
def _(m, ctx):
    return Eff(('shuffle',))


def search_cavs(f, upto, ctx):
    cv = set()
    if upto and ctx['kind'] == 'trainer':
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
    cv = {'upTo0'} if upto and ctx['kind'] == 'trainer' else set()
    return Eff(seq(*[('putBench', OWN, ('deck',), f)] * n), cv)


ATTACH_TGT = (r'(this Pokémon|1 of your Pokémon|1 of your Benched Pokémon|your Pokémon in any way you like|'
              r'your Benched Pokémon in any way you like)')


def attach_one(src, f, tgt, ctx):
    if tgt == 'this Pokémon':
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
    cv = {'upTo0'} if upto and ctx['kind'] == 'trainer' else set()
    return Eff(seq(*[attach_one(('deck',), f, m.group(3), ctx)] * n), cv)


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
    elif ctx['kind'] == 'trainer':
        cv.add('upTo0')
    return Eff(seq(*[attach_one(('discard',), f, m.group(3), ctx)] * n), cv)


@rule('recycle-to-hand', r'Put (up to \d+|an?|\d+) (.+?) from your discard pile into your hand\.', 'B',
      'move own discard hand F (upTo n | at most n, as many as there are)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    mk = lambda q: ('move', OWN, ('discard',), ('hand',), f, q)
    if upto:
        return Eff(mk(('upTo', n)), {'upTo0'} if ctx['kind'] == 'trainer' else set())
    return Eff(min_take(('pile', OWN, ('discard',), f), n, mk))


@rule('recycle-to-deck', r'Shuffle (up to \d+|an?|\d+) (.+?) from your discard pile into your deck\.', 'B',
      'move own discard shuffle F (upTo n | ...)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    mk = lambda q: ('move', OWN, ('discard',), ('shuffle',), f, q)
    if upto:
        return Eff(mk(('upTo', n)), {'upTo0'} if ctx['kind'] == 'trainer' else set())
    return Eff(min_take(('pile', OWN, ('discard',), f), n, mk))


@rule('discard-to-bench', r'Put (up to \d+|an?|\d+) (.+?) from your discard pile onto your Bench\.', 'B',
      'putBench own discard F (n times)')
def _(m, ctx):
    n, upto = parse_qty_np(m.group(1))
    f = parse_filter(m.group(2), ctx)
    cv = set()
    if not upto:
        cv.add('mayFail')
    elif ctx['kind'] == 'trainer':
        cv.add('upTo0')
    return Eff(seq(*[('putBench', OWN, ('discard',), f)] * n), cv)


@rule('discard-energy', r"Discard (an|a|all|\d+) (?:(Basic )?" + TYPE_RE + r" )?Energy (?:cards? )?from (this Pokémon|"
      + OPPA + r')\.', 'B',
      'ite (countGe (energy w F) n) (discardEnergy w active F (exactly n)) (... all | skip)')
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
    return Eff(min_take(('energy', w, f), num(q), mk))


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


def opp_hand_discard(n):
    mk = lambda q: ('move', OPP, ('hand',), ('discard',), ('any',), q)
    return min_take(('pile', OPP, ('hand',), ('any',)), n, mk)


@rule('discard-random-opp-hand', r"Discard a random card from your opponent's hand\.", 'B',
      'ite (countGe (pile opp hand any) 1) (move opp hand discard any (exactly 1)) skip')
def _(m, ctx):
    return Eff(opp_hand_discard(1))


@rule('opp-discards', r"Your opponent discards (a card|\d+ cards) from their hand\.", 'B',
      'ite (countGe (pile opp hand any) n) (move opp hand discard any (exactly n)) (... all)')
def _(m, ctx):
    n = 1 if m.group(1) == 'a card' else num(m.group(1).split()[0])
    return Eff(opp_hand_discard(n))


@rule('discard-own-hand-card', r"Discard (a card|\d+ cards) from your hand\.", 'A',
      'ite (countGe (pile own hand any) n) (move own hand discard any (exactly n)) (... all)')
def _(m, ctx):
    n = 1 if m.group(1) == 'a card' else num(m.group(1).split()[0])
    mk = lambda q: ('move', OWN, ('hand',), ('discard',), ('any',), q)
    return Eff(min_take(('pile', OWN, ('hand',), ('any',)), n, mk))


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
    kind = 'A' if ctx['kind'] == 'attack' else 'T'
    for name, rx, where, _, fn in RULES:
        if where not in ('B', kind):
            continue
        m = rx.match(s)
        if m:
            return name, fn(m, ctx)
    raise Refuse('unhandled sentence', s)


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
        i = 0
        n = len(sents)
        while i < n:
            s = sents[i]
            try:
                i = self.step(sents, i)
            except Refuse as r:
                j = self.span(sents, i)
                self.blockers.append((r.reason, r.sentence or ' '.join(sents[i:j])))
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
                alts = [seq(*[X.e] * h) for h in range(k + 1)]
                e = alts[-1]
                for a in reversed(alts[:-1]):
                    e = choice(a, e)
                self.items.append((i, Eff(e, X.cavs)))
                return i + 2
            raise Refuse('coin flips not expressible', s + ' ' + nxt)
        if s == 'Flip a coin until you get tails.':
            m2 = re.match(r'^This attack does (\d+) (more )?damage for each heads\.$', nxt)
            if m2 and ctx['kind'] == 'attack':
                self.used.append(('flip-until-tails-damage', s + ' ' + nxt))
                self.items.append((i, Dmg('many', counters(m2.group(1)), bool(m2.group(2)))))
                return i + 2
            raise Refuse('flip until tails not expressible', s + ' ' + nxt)
        # a condition: "If C, X."
        m = re.match(r'^If (.+?), (this attack does .+|.+)$', s)
        if m and not s.startswith('If you do') and not s.startswith("If you can't"):
            tests, neg = parse_test(m.group(1), ctx)
            X = self.clause(m.group(2))
            self.used.append(('if-condition', s))
            if isinstance(X, Nothing):
                self.items.append((i, ('wrapIf', tests, neg)))
            elif isinstance(X, Dmg) and X.op == 'add' and X.args[0][0] == 'const':
                self.items.append((i, Dmg('cond', tests, neg, X.args[0][1], reads=True)))
            elif isinstance(X, Eff):
                self.items.append((i, Eff(branch(tests, neg, X.e, SKIP), X.cavs)))
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
                                      {'upTo0'} if ctx['kind'] == 'trainer' else set())))
            return i + 2
        it = self.one(s)
        self.items.append((i, it))
        return i + 1

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
    if tree[0] == 'T1':
        raise Refuse('computed damage to a chosen Pokémon')
    raise AssertionError(tree)


def tbranch(tests, neg, a, b):
    if neg:
        a, b = b, a
    out = b
    for t in reversed(tests):
        out = ('ite', t, a, out)
    return out


def to_effect(tree, drain=False):
    if tree[0] == 'L':
        return ('drain' if drain else 'damage', tree[1])
    if tree[0] == 'T1':
        if drain:
            raise Refuse('drain with damage to a chosen Pokémon')
        n = tree[1]
        return choice(('damage', ('const', n)), ('benchDamage', OPP, n))
    if tree[0] == 'ite':
        return ite(tree[1], to_effect(tree[2], drain), to_effect(tree[3], drain))
    if tree[0] == 'choice':
        return choice(to_effect(tree[1], drain), to_effect(tree[2], drain))
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
    wraps = []         # (index, wrap)
    for idx, it in items:
        if isinstance(it, Eff):
            cavs |= it.cavs
            post.append((idx, it.e))
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
        elif isinstance(it, tuple) and it[0] in ('wrapFlip', 'wrapIf'):
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
    if tree is not None and any(test_reads_damage(e) for _, e in post):
        raise Refuse('an effect after the damage tests the damage on the opponent\'s Active Pokémon')
    if drain and tree is None:
        raise Refuse('drain with no damage')
    # Poison strength must follow the Poison it strengthens
    effs = [e for _, e in post]
    plain = tree is not None and tree == ('L', ('const', base)) and not drain and not wraps and base
    if plain:
        damage, eff = base, seq(*effs)
    else:
        damage = 0
        eff = seq(to_effect(tree, drain) if tree is not None else SKIP, *effs)
    for _, w in wraps:
        if w[0] == 'wrapFlip':
            if damage:
                eff, damage = seq(('damage', ('const', damage)), eff), 0
            eff = choice(eff, SKIP)
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
    if 'Pokémon Tool' in sub:
        B.append(('Pokémon Tool', ''))
    if 'Stadium' in sub:
        B.append(('Stadium', ''))
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
    ps = T.prims(e)
    if any(x[0] in ('counters', 'benchCounters', 'spreadCounters', 'selfDamage') for x in ps) and len(ps) > 1:
        res['caveats'].add('koBetweenSteps')
    res['caveats'].discard('_needsPoison')
    res['term'] = term
    res['ok'] = True
    return res


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


STAGES = {'Basic': ('basic',), 'Stage 1': ('stage1',), 'Stage 2': ('stage2',)}


def translate_pokemon(c, res):
    B = res['blockers']
    sub = c['_sub']
    name = c['name']
    if c.get('abilities'):
        B.append(('Ability', ''))
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
    if B:
        return res
    fields = {'name': name, 'stage': stage, 'evolvesFrom': ('some', c['evolvesFrom']) if c.get('evolvesFrom') else None,
              'hp': hp, 'type': ptype, 'attacks': attacks, 'retreat': retreat, 'weakness': weak,
              'resistance': res_, 'ruleBox': (rb,), 'tera': tera}
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
    ctx = {'kind': 'attack', 'name': c['name'], 'base': base, 'cost': cost}
    p = Parser(ctx).run(split_sentences(a.get('text')))
    res['used'] += p.used
    if p.blockers:
        B += p.blockers
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
    res['caveats'] |= cavs
    return {'name': a.get('name') or '', 'cost': cost, 'damage': damage, 'effect': eff, 'gx': False}


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
