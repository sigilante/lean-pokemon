"""The model's card language as Python terms, its Lean printer, and Python mirrors of the Lean
checks (`Effect.hitFree`, `oneHit`, `switchSafe`, `loopFree`, ... in Pokemon/Card.lean and
Pokemon/StoreSafe.lean). The mirrors only decide what the importer emits; the Lean proofs in
PokemonCards/ re-check every emitted term.

Terms are tuples whose head names the Lean constructor: ('seq', a, b) prints as `.seq a b`;
('own',) prints as `.own`. Python ints print as numerals, str as string literals, bools as
`true`/`false`, None as `none`, and ('some', x) as `some x`.
"""

TYPES = {'Grass': 'grass', 'Fire': 'fire', 'Water': 'water', 'Lightning': 'lightning',
         'Psychic': 'psychic', 'Fighting': 'fighting', 'Darkness': 'darkness', 'Metal': 'metal',
         'Fairy': 'fairy', 'Dragon': 'dragon', 'Colorless': 'colorless'}
BASIC_ENERGY = {k: v for k, v in TYPES.items() if k not in ('Dragon', 'Colorless')}

SKIP = ('skip',)
OWN, OPP = ('own',), ('opp',)


def lean_str(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'


def lean(x, top=True):
    if isinstance(x, bool):
        return 'true' if x else 'false'
    if isinstance(x, int):
        return str(x)
    if isinstance(x, str):
        return lean_str(x)
    if x is None:
        return 'none'
    if isinstance(x, list):
        return '[' + ', '.join(lean(a) for a in x) + ']'
    if isinstance(x, dict):
        # a structure instance (a `Static`, milestone M6), fields in the structure's order
        return '{ ' + ', '.join(k + ' := ' + lean(v) for k, v in x.items()) + ' }'
    assert isinstance(x, tuple) and x, x
    if isinstance(x, Folded):
        # a derived form of the model (milestone MV3, Pokemon/IfDo.lean), printed by its name; the term
        # itself (what every mirror below reads) is its unfolding, equal to it by definition
        return lean(x.form, top)
    if x[0] == 'some':
        s = 'some ' + lean(x[1], False)
        return s if top else '(' + s + ')'
    if x[0] == 'pair':
        return '(' + lean(x[1]) + ', ' + lean(x[2]) + ')'
    if len(x) == 1:
        return '.' + x[0]
    s = '.' + x[0] + ' ' + ' '.join(lean(a, False) for a in x[1:])
    return s if top else '(' + s + ')'


class Folded(tuple):
    """An effect term that is the unfolding of a derived form (`Effect.ifDone t a b` is by definition
    `ite t (seq a b) skip`): it compares, and is read by every mirror, as the unfolded tuple; only the
    Lean printer uses `form`, the derived form's name and arguments."""
    form = None


def if_done(t, a, b):
    """`Effect.ifDone t a b` (Pokemon/IfDo.lean): `ite t (seq a b) skip`, printed as `.ifDone t a b`."""
    x = Folded(('ite', t, ('seq', a, b), SKIP))
    x.form = ('ifDone', t, a, b)
    return x


def seq(*es):
    """Right-nested `seq` of the effects, dropping `skip`s; `skip` if none is left."""
    es = [e for e in es if e != SKIP]
    if not es:
        return SKIP
    out = es[-1]
    for e in reversed(es[:-1]):
        out = ('seq', e, out)
    return out


def choice(a, b):
    return ('choice', a, b)


def ite(t, a, b):
    return ('ite', t, a, b)


# ---------------------------------------------------------------- mirrors of the Lean checks

COMPOUND = ('ite', 'seq', 'choice', 'iter')


def subs(e):
    if e[0] == 'ite':
        return [e[2], e[3]]
    if e[0] in ('seq', 'choice'):
        return [e[1], e[2]]
    if e[0] == 'iter':
        return [e[1]]
    return []


def hit_free(e):
    if e[0] in ('damage', 'drain'):
        return False
    return all(hit_free(s) for s in subs(e))


def bench_hit_free(e):
    if e[0] in ('benchDamage', 'spreadDamage'):
        return False
    if e[0] == 'benchSome':
        # milestone MV2: `Effect.benchHitFree (.benchSome _ _ _ dmg _) = !dmg`
        return not e[4]
    return all(bench_hit_free(s) for s in subs(e))


def one_hit(e):
    if e[0] in ('ite', 'choice'):
        a, b = subs(e)
        return one_hit(a) and one_hit(b)
    if e[0] == 'seq':
        a, b = e[1], e[2]
        return (one_hit(a) and hit_free(b)) or (hit_free(a) and one_hit(b))
    if e[0] == 'iter':
        return hit_free(e[1])
    return True


def test_on_own(t):
    if t[0] in ('atLeast', 'exactly', 'cond', 'marked', 'isType'):
        return t[1] == OWN
    if t[0] == 'countGe':
        return t[1][0] == 'energy' and t[1][1] == OWN
    if t[0] in ('top', 'hasTool', 'movedUp', 'evolved'):
        # milestone MV2 (`Test.onOwn`)
        return t[1] == OWN
    return False


def own_free(e):
    h = e[0]
    if h in ('heal', 'cure', 'selfDamage', 'healAll', 'damage', 'drain'):
        return False
    if h == 'scale' and e[1] == OWN:
        return False
    if h == 'switch' and e[1] == OWN:
        return False
    if h == 'attach' and e[1] == OWN and e[4] == ('active',):
        return False
    if h == 'discardEnergy' and e[1] == OWN and e[2] == ('active',):
        return False
    if h == 'moveEnergy' and e[1] == OWN:
        return False
    if h == 'moveCounter':
        return False
    if h == 'ite':
        return not test_on_own(e[1]) and own_free(e[2]) and own_free(e[3])
    return all(own_free(s) for s in subs(e))


def switches_own(e):
    if e == ('switch', OWN):
        return True
    return any(switches_own(s) for s in subs(e))


def switch_safe(e):
    h = e[0]
    if h in ('ite', 'choice'):
        return all(switch_safe(s) for s in subs(e))
    if h == 'seq':
        a, b = e[1], e[2]
        return switch_safe(a) and switch_safe(b) and (not switches_own(a) or own_free(b))
    if h == 'iter':
        return switch_safe(e[1]) and not switches_own(e[1])
    return True


def attack_wf(damage, effect):
    return one_hit(effect) and (damage == 0 or hit_free(effect)) and switch_safe(effect)


def mod_is_amt(m):
    return m[0] in ('bonus', 'reduce')


def writes(e):
    if e[0] == 'linger':
        return mod_is_amt(e[3])
    return any(writes(s) for s in subs(e))


def loop_free(e):
    if e[0] == 'iter':
        return not writes(e[1])
    return all(loop_free(s) for s in subs(e))


def amt_at(slot, e):
    h = e[0]
    if h == 'linger':
        m = e[3]
        return (m[1] if mod_is_amt(m) else 0) if e[2] == (slot,) else 0
    if h in ('ite', 'choice'):
        return max(amt_at(slot, s) for s in subs(e))
    if h == 'seq':
        return amt_at(slot, e[1]) + amt_at(slot, e[2])
    return 0


def lingers(e):
    """Any lingering modifier at all (flags included)."""
    if e[0] == 'linger':
        return True
    return any(lingers(s) for s in subs(e))


def rec_filters(e):
    if e[0] == 'move' and e[2] == ('discard',):
        return [e[4]]
    out = []
    for s in subs(e):
        out += rec_filters(s)
    return out


def prims(e):
    if e[0] in COMPOUND:
        out = []
        for s in subs(e):
            out += prims(s)
        return out
    return [e]


# ---------------------------------------------------------------- Abilities (mirrors of Pokemon/Card.lean, M8a)
#
# An Ability is a dict {'name', 'use', 'spot', 'cond', 'effect'}; `use` is ('once',), ('unlimited',)
# or ('onPlay', ('bench',) | ('evolve',) | ('either',)); `spot` is None or ('some', ('active',) |
# ('bench',)); `cond` is None or ('some', test); `effect` is an `AbEff`: ('fx', e), ('self', op),
# ('seq', a, b), ('choice', a, b); a `SelfOp` is ('heal', n), ('counters', n), ('attach', src, f),
# ('switchIn',) or ('energyTo', f).

ACTIVE, BENCH = ('active',), ('bench',)


def selfop_at_s(sp, o):
    """`SelfOp.atS`."""
    h = o[0]
    if h == 'heal':
        return ('heal', o[1]) if sp == ACTIVE else ('benchHeal', o[1])
    if h == 'counters':
        return ('selfDamage', o[1]) if sp == ACTIVE else ('benchCounters', OWN, o[1])
    if h == 'attach':
        return ('attach', OWN, o[1], o[2], sp, ('any',))
    if h == 'switchIn':
        return SKIP if sp == ACTIVE else ('switch', OWN)
    if h == 'energyTo':
        return ('moveEnergy', OWN, o[1])
    raise AssertionError(o)


def selfop_at(p, o):
    """`SelfOp.at`: p is ACTIVE, BENCH or None (not tracked)."""
    if p is None:
        return ('choice', selfop_at_s(ACTIVE, o), selfop_at_s(BENCH, o))
    return selfop_at_s(p, o)


def selfop_after(p, o):
    if o[0] == 'switchIn':
        return ACTIVE if p == ACTIVE else None
    return p


def abeff_after(p, a):
    h = a[0]
    if h == 'fx':
        return None if switches_own(a[1]) else p
    if h == 'self':
        return selfop_after(p, a[1])
    if h == 'seq':
        return abeff_after(abeff_after(p, a[1]), a[2])
    if h == 'choice':
        x, y = abeff_after(p, a[1]), abeff_after(p, a[2])
        return x if x == y else None
    raise AssertionError(a)


def abeff_compile(p, a):
    """`AbEff.compile`."""
    h = a[0]
    if h == 'fx':
        return a[1]
    if h == 'self':
        return selfop_at(p, a[1])
    if h == 'seq':
        return ('seq', abeff_compile(p, a[1]), abeff_compile(abeff_after(p, a[1]), a[2]))
    if h == 'choice':
        return ('choice', abeff_compile(p, a[1]), abeff_compile(p, a[2]))
    raise AssertionError(a)


def ability_scripts(ab):
    """`Ability.scripts`: the script with "this Pokémon" Active, Benched, and not tracked."""
    return [abeff_compile(ACTIVE, ab['effect']), abeff_compile(BENCH, ab['effect']),
            abeff_compile(None, ab['effect'])]


TRIG_EVENTS = {'damaged': ACTIVE, 'koByAttack': None}   # `TrigEvent.place`


def trig_ok(e):
    """`Effect.trigOk` (milestone M8b): the trigger fragment."""
    h = e[0]
    if h in ('skip', 'draw', 'counters', 'inflict', 'shuffle', 'drawTo', 'attach', 'putBench', 'moveEnergy',
             'discardTools'):
        return True
    if h == 'move':
        return e[5][0] != 'exactly'
    if h == 'discardEnergy':
        return e[4][0] != 'exactly'
    if h in ('seq', 'choice'):
        return trig_ok(e[1]) and trig_ok(e[2])
    return False


def trig_script(ab):
    """`Ability.script ab ev.place` for a triggered Ability."""
    return abeff_compile(TRIG_EVENTS[ab['use'][1][0]], ab['effect'])


def amt(e):
    return sum(amt_at(s, e) for s in ('now', 'next', 'after', 'always'))


def ability_safe(ab):
    """`Card.abilitySafe` for one Ability."""
    return all((ab['use'] != ('unlimited',) or amt(e) == 0) and amt_at('always', e) == 0
               for e in ability_scripts(ab))


# ---------------------------------------------------------------- filters, evaluated in Python

def filter_eval(f, card):
    """`Filter.eval` on a Python card term ('pokemon', fields) / ('energy', t) / ('trainer', n, k, e) /
    ('tool', n, grant)."""
    h = f[0]
    kind = card[0]
    if h == 'any':
        return True
    if h == 'and':
        return filter_eval(f[1], card) and filter_eval(f[2], card)
    if h == 'or':
        return filter_eval(f[1], card) or filter_eval(f[2], card)
    if h == 'not':
        return not filter_eval(f[1], card)
    if kind == 'pokemon':
        p = card[1]
        if h == 'pokemon':
            return True
        if h == 'basic':
            return p['stage'] == ('basic',)
        if h == 'stage':
            return p['stage'] == f[1]
        if h == 'ptype':
            return p['type'] == f[1]
        if h == 'named':
            return p['name'] == f[1]
        if h == 'hpLe':
            return p['hp'] <= f[1]
        if h == 'noRuleBox':
            return p['ruleBox'] == ('none',)
        # milestone MV2
        if h == 'ex':
            return p['ruleBox'] != ('none',)
        if h == 'tera':
            return p['tera']
        if h == 'hasAttack':
            return any(a['name'] == f[1] for a in p['attacks'])
        if h == 'hasAbility':
            return bool(p['abilities'])
        return False
    if kind == 'trainer':
        if h == 'named':
            return card[1] == f[1]
        if h == 'trainer':
            return True
        if h == 'kind':
            return card[2] == f[1]
        return False
    if kind == 'tool':
        if h == 'named':
            return card[1] == f[1]
        return h in ('trainer', 'tool')
    if kind == 'energy':
        # an imported Energy card is a Basic Energy card ('energy', (t,)); no Special Energy card is imported
        # (milestone MV5: `Filter.basicEnergy` passes it, `specialEnergy` and the name filters do not)
        if h in ('energy', 'basicEnergy'):
            return True
        if h == 'energyOf':
            return card[1] == f[1]
        return False
    return False
