"""Plays and uses to no effect (importer 0.13.0): one treatment for every Item, Supporter, Stadium use and activated
Ability.

The model lets an Item or Supporter be played (`Move.item`, `Move.supporter`), a Stadium be used (`Move.stadiumUse`) and
an activated Ability be used (`Move.ability`) whenever its effect has a resolution (`TRun`); nothing asks that the
effect change anything. The rulebook (2026, p. 12: "When you play any Trainer card, do what it says and obey the rule at
the bottom of the card") says nothing about a card whose effect cannot do anything. The importer reads the usual ruling,
which is not in the rulebook: a card or Ability may not be played or used when its effect cannot do anything (a cost
paid "in order to" use it is not its effect), but a search or a look at a hidden zone (a deck, the opponent's hand)
may always be made, and may find nothing.

This module decides, from the term alone, in which states an effect has a resolution that changes nothing (`may`) and
in which states every resolution changes nothing (`must`), as formulas in disjunctive normal form over the model's
tests. A conjunction of `must` that reads only public information (counts of a hand, a discard pile, a Bench, a deck's
size; the damage and Special Conditions of an Active Pokémon) is a state in which print forbids the play: the importer
writes the negation as a precondition (`require`, an `ite` whose failing branch is `NO_PLAY`, the effect with no
resolution), so that the model forbids it too, exactly. What `may` keeps after the precondition is either allowed by
print (a search of a hidden zone that finds nothing, `HIDDEN`; the losing side of a coin flip, `COIN`), covered by a
caveat the rule that wrote the primitive already names (`COV`: `upTo0`, `mayFail`, `moveMayFail`, `searchAny`), or a
use to no effect the model allows and print forbids: the caveat `noopPlay` (a Trainer or Stadium) or `noopUse` (an
Ability), direction "allows more".

Atoms are the model's tests (tuples as in `terms`) and four special atoms: ('HIDDEN',), ('COIN',), ('COV', names) and
('NOTEST', why), the last for a condition the model has no test for (a Benched Pokémon's damage, the Stadium slot, a
lingering lock already in force, a Poison strength). A literal is (atom, polarity); a conjunction a frozenset of
literals; a formula a list of conjunctions (`[]` false, `[frozenset()]` true).
"""
import itertools

from terms import OWN, OPP, SKIP

TRUE = [frozenset()]
FALSE = []

NO_PLAY = ('move', OWN, ('top', 0), ('hand',), ('any',), ('exactly', 1))
BENCH_LIMIT = 5
SPECIAL = ('HIDDEN', 'COIN', 'COV', 'NOTEST')


def lit(t, pol=True):
    return frozenset([(t, pol)])


def ge(c, n=1):
    return ('countGe', c, n)


def deck(w):
    return ge(('pile', w, ('deck',), ('any',)))


def hand(w, n=1):
    return ge(('pile', w, ('hand',), ('any',)), n)


def bench(w):
    return ge(('bench', w, ('pokemon',)))


def bench_full(w):
    return ge(('bench', w, ('pokemon',)), BENCH_LIMIT)


HIDDEN = (('HIDDEN',), True)
COIN = (('COIN',), True)


def cov(*names):
    return (('COV', tuple(names)), True)


def notest(why):
    return (('NOTEST', why), True)


def conj(*ls):
    return frozenset(ls)


# ---------------------------------------------------------------- satisfiability and simplification

def bounds(c):
    """For a conjunction: per count, (lower, upper) with lower <= value < upper; None if unsatisfiable."""
    b = {}
    seen = {}
    for (a, p) in c:
        if a[0] == 'countGe':
            lo, hi = b.get(a[1], (0, float('inf')))
            if p:
                lo = max(lo, a[2])
            else:
                hi = min(hi, a[2])
            b[a[1]] = (lo, hi)
        else:
            if seen.get(a, p) != p:
                return None
            seen[a] = p
    for lo, hi in b.values():
        if lo >= hi:
            return None
    return b


def sat(c):
    return bounds(c) is not None


def normalize(c):
    """Keep the strongest bound per count."""
    b = bounds(c)
    if b is None:
        return None
    out = set(x for x in c if x[0][0] != 'countGe')
    for k, (lo, hi) in b.items():
        if lo > 0:
            out.add((('countGe', k, lo), True))
        if hi != float('inf'):
            out.add((('countGe', k, hi), False))
    return frozenset(out)


def implies(c, d):
    """Conjunction c implies conjunction d (literal by literal, with count bounds)."""
    bc = bounds(c)
    if bc is None:
        return True
    for (a, p) in d:
        if a[0] == 'countGe':
            lo, hi = bc.get(a[1], (0, float('inf')))
            if p and not lo >= a[2]:
                return False
            if not p and not hi <= a[2]:
                return False
        elif (a, p) not in c:
            return False
    return True


def simp(f):
    """Drop unsatisfiable conjunctions and those implied by... (absorption: a conjunction that implies another is
    redundant in a disjunction)."""
    cs = []
    for c in f:
        n = normalize(c)
        if n is not None and n not in cs:
            cs.append(n)
    # resolution: A ∧ l and A ∧ ¬l give A
    merged = True
    while merged:
        merged = False
        for i, c in enumerate(cs):
            for d in cs[i + 1:]:
                x = c ^ d
                if len(x) == 2:
                    (a1, p1), (a2, p2) = sorted(x, key=repr)
                    if a1 == a2 and p1 != p2:
                        n = normalize(c - x)
                        cs = [y for y in cs if y not in (c, d)] + ([n] if n not in cs else [])
                        merged = True
                        break
            if merged:
                break
    out = []
    for c in cs:
        if any(d != c and implies(c, d) and not (implies(d, c) and cs.index(d) > cs.index(c)) for d in cs):
            continue
        out.append(c)
    return out


def f_and(f, g):
    return simp([a | b for a in f for b in g])


def f_or(f, g):
    return simp(list(f) + list(g))


def f_lit(t, pol, f):
    return simp([c | lit(t, pol) for c in f])


# ---------------------------------------------------------------- the analysis

def zone_none(w, src, f):
    """States in which no card passing f is in the source zone: (must, may-extra-for-hidden)."""
    s = src[0]
    if s in ('deck', 'top', 'bottom'):
        if s in ('top', 'bottom') and src[1] == 0:
            return TRUE, True
        if f == ('any',):
            return [lit(deck(w), False)], True
        return [lit(deck(w), False), conj((deck(w), True), HIDDEN)], True
    if s == 'hand':
        if w == OPP and f != ('any',):
            return [lit(hand(OPP), False), conj((hand(OPP), True), HIDDEN)], True
        return [lit(ge(('pile', w, ('hand',), f)), False)], False
    if s == 'discard':
        return [lit(ge(('pile', w, ('discard',), f)), False)], False
    raise NotImplementedError(src)


def covered(f, *names):
    """The conjunctions of f, each marked as covered by one of the caveats `names`: in `may`, a primitive that the
    model lets do nothing in every state (`attach`, `putBench`, `moveEnergy`, a move of 'up to N') does nothing in a
    `choice` branch the player need not take, which is the looseness its caveat already names."""
    return simp([c | {cov(*names)} for c in f])


def may_fail(must, hidden):
    """`may` of `attach` and `putBench`: nothing is attached or benched in every state (`attachNone`, `benchNone`),
    the looseness of the caveats `mayFail` and `upTo0`, or of a hidden search that finds nothing."""
    if hidden:
        return f_or(covered(must, 'mayFail', 'upTo0'), [conj(HIDDEN)])
    return f_or(covered(must, 'mayFail', 'upTo0'), [conj(cov('mayFail', 'upTo0'))])


def prim(e, coin):
    """(may, must) of a primitive."""
    h = e[0]
    if h in ('skip', 'shuffle'):
        # a shuffle that follows a search is part of the search, not an effect of its own (no imported Trainer or
        # Ability only shuffles)
        return TRUE, TRUE
    if h in ('counters', 'selfDamage', 'search', 'draw', 'handToBottom', 'heal_never'):
        return FALSE, FALSE
    if h == 'move':
        _, w, src, dst, f, q = e
        if q[0] == 'exactly':
            return (TRUE, TRUE) if q[1] == 0 else (FALSE, FALSE)
        none, hidden = zone_none(w, src, f)
        if q[0] in ('all', 'most'):
            return none, none
        if q[0] == 'upTo':
            # 'up to N' takes 0 in the model wherever it takes nothing (caveat `upTo0`, or `searchAny` for a search
            # for any card); a hidden search finds nothing in print too
            if hidden and f != ('any',):
                return f_or(none, [conj(HIDDEN)]), none
            return f_or(covered(none, 'upTo0', 'searchAny'), [conj(cov('upTo0', 'searchAny'))]), none
        raise NotImplementedError(e)
    if h == 'look':
        _, w, src, f, q, into, rest = e
        if src[0] in ('top', 'bottom', 'deck'):
            z = deck(w)
        elif src[0] == 'hand' and w == OPP:
            z = hand(OPP)
        else:
            raise NotImplementedError(e)
        f_ = [lit(z, False), conj((z, True), HIDDEN)]
        return f_, f_
    if h == 'drawTo':
        _, w, n = e
        f_ = [lit(hand(w, n)), lit(deck(w), False)]
        return f_, f_
    if h == 'putBench':
        _, w, src, f = e
        none, hidden = zone_none(w, src, f)
        must = f_or([lit(bench_full(w))], none)
        return may_fail(must, hidden), must
    if h == 'attach':
        _, w, src, f, sp, tf = e
        none, hidden = zone_none(w, src, f)
        if sp == ('active',):
            notgt = FALSE if tf == ('any',) else [lit(('top', w, tf), False)]
        else:
            notgt = [lit(ge(('bench', w, ('pokemon',) if tf == ('any',) else tf)), False)]
        must = f_or(none, notgt)
        return may_fail(must, hidden), must
    if h == 'moveEnergy':
        _, w, f = e
        must = [lit(ge(('energyAll', w, f)), False), lit(bench(w), False)]
        return f_or(covered(must, 'moveMayFail'), [conj(cov('moveMayFail'))]), must
    if h == 'discardEnergy':
        _, w, sp, f, q = e
        if q[0] == 'exactly':
            return (TRUE, TRUE) if q[1] == 0 else (FALSE, FALSE)
        if sp != ('active',):
            f_ = [conj(notest('Energy on a Benched Pokémon'))]
            return f_, f_
        none = [lit(ge(('energy', w, f)), False)]
        if q[0] == 'all':
            return none, none
        return f_or(none, [conj(cov('upTo0'))]), none
    if h == 'returnEnergy':
        # importer 0.18.0 (milestone MV11): the take of `discardEnergy`, the cards put elsewhere
        return prim(('discardEnergy',) + e[1:5], coin)
    if h == 'shiftEnergy':
        # importer 0.18.0 (milestone MV11): nothing moves with an empty Bench (`shiftNone`), or with nothing to take
        _, w, src, f, q, dst, one = e
        if q[0] == 'exactly':
            return (TRUE, TRUE) if q[1] == 0 else (FALSE, [lit(bench(w), False)])
        if src == ('active',):
            must = [lit(ge(('energy', w, f)), False), lit(bench(w), False)]
        else:
            must = [lit(bench(w), False), conj((bench(w), True), notest('Energy on a Benched Pokémon'))]
        if q[0] == 'upTo':
            return f_or(must, [conj(cov('upTo0'))]), must
        return must, must
    if h == 'switch':
        f_ = [lit(bench(e[1]), False)]
        return f_, f_
    if h in ('heal', 'healAll'):
        f_ = [lit(('atLeast', OWN, 1), False)]
        return f_, f_
    if h == 'benchHeal':
        f_ = [lit(bench(OWN), False), conj((bench(OWN), True), notest('damage on a Benched Pokémon'))]
        return f_, f_
    if h == 'cure':
        f_ = [lit(ge(('conds', OWN)), False)]
        return f_, f_
    if h == 'inflict':
        c = e[1][0]
        if c == 'poisoned':
            f_ = [conj((('cond', OPP, e[1]), True), notest('Poison strength'))]
        else:
            f_ = [lit(('cond', OPP, e[1]))]
        return f_, f_
    if h in ('benchCounters', 'spreadCounters'):
        f_ = [lit(bench(e[1]), False)]
        return f_, f_
    if h == 'linger':
        m = e[3]
        if m[0] in ('lock', 'prevent'):
            f_ = [conj(notest('a lingering ' + m[0] + ' already in force'))]
            return f_, f_
        return FALSE, FALSE
    if h == 'discardStadium':
        f_ = [conj(notest('the Stadium slot'))]
        return f_, f_
    raise NotImplementedError(e)


def analyse(e, coin=False):
    """(may, must) of an effect term. `coin`: the printed text flips a coin, and its `choice`s are coin flips."""
    h = e[0]
    if h == 'seq':
        a, b = analyse(e[1], coin), analyse(e[2], coin)
        return f_and(a[0], b[0]), f_and(a[1], b[1])
    if h == 'choice':
        a, b = analyse(e[1], coin), analyse(e[2], coin)
        may = f_or(a[0], b[0])
        if coin:
            may = simp([c | {COIN} for c in may])
        return may, f_and(a[1], b[1])
    if h == 'ite':
        t = e[1]
        a, b = analyse(e[2], coin), analyse(e[3], coin)
        return (f_or(f_lit(t, True, a[0]), f_lit(t, False, b[0])),
                f_or(f_lit(t, True, a[1]), f_lit(t, False, b[1])))
    if h == 'iter':
        a = analyse(e[1], coin)
        return TRUE, a[1]
    return prim(e, coin)


def special(c):
    return any(a[0] in SPECIAL for (a, _) in c)


# ---------------------------------------------------------------- the leading requirements and the guard

def leading(e):
    """The requirements an effect states first ('You can use this card only if …': `ite t skip NO_PLAY`, `ite t NO_PLAY
    skip`), as literals, and the rest of the effect."""
    known = []
    while True:
        first, rest = (e[1], e[2]) if e[0] == 'seq' else (e, SKIP)
        if first[0] == 'ite' and first[2] == SKIP and first[3] == NO_PLAY:
            known.append((first[1], True))
        elif first[0] == 'ite' and first[2] == NO_PLAY and first[3] == SKIP:
            known.append((first[1], False))
        else:
            return known, e
        e = rest
        if e == SKIP:
            return known, e


def lit_value(l, known):
    """True / False if the literal l is decided by the conjunction `known`, else None."""
    k = frozenset(known)
    if implies(k, frozenset([l])):
        return True
    if implies(k, frozenset([(l[0], not l[1])])):
        return False
    return None


def require(clause):
    """The precondition 'one of the literals of `clause` holds': nested `ite`s whose last branch is `NO_PLAY`."""
    out = NO_PLAY
    for (t, p) in reversed(clause):
        out = ('ite', t, SKIP, out) if p else ('ite', t, out, SKIP)
    return out


def decide(e, known):
    """Replace every `ite` whose test the literals `known` decide by its branch."""
    if e[0] == 'ite':
        v = lit_value((e[1], True), known)
        if v is True:
            return decide(e[2], known)
        if v is False:
            return decide(e[3], known)
        a, b = decide(e[2], known), decide(e[3], known)
        return e if (a, b) == (e[2], e[3]) else ('ite', e[1], a, b)
    if e[0] in ('seq', 'choice'):
        a, b = decide(e[1], known), decide(e[2], known)
        if (a, b) == (e[1], e[2]):
            return e
        if e[0] == 'seq':
            return b if a == SKIP else a if b == SKIP else ('seq', a, b)
        return ('choice', a, b)
    return e


def lit_order(l):
    # tests on the player's own side first, then by printed form
    return (0 if OWN in l[0] or (len(l[0]) > 1 and isinstance(l[0][1], tuple) and OWN in l[0][1]) else 1, repr(l))


def unit_propagate(clauses, known):
    """Simplify the clauses by the literals `known` and by each other's unit clauses."""
    out = [list(c) for c in clauses]
    changed = True
    while changed:
        changed = False
        new = []
        for i, c in enumerate(out):
            units = list(known) + [d[0] for j, d in enumerate(out) if len(d) == 1 and j != i and d not in new[:0]]
            vals = [lit_value(l, units) for l in c]
            if True in vals:
                changed = True
                out = out[:i] + out[i + 1:]
                break
            c2 = [l for l, v in zip(c, vals) if v is None]
            if not c2:
                raise ValueError('effect that can only do nothing under its own requirements')
            if len(c2) != len(c):
                changed = True
                out = out[:i] + [c2] + out[i + 1:]
                break
            if c in out[:i]:
                changed = True
                out = out[:i] + out[i + 1:]
                break
    return out


def plan(bodies, coin=False, facts=()):
    """For an effect (one body, or one per place of an Ability), the precondition clauses and what `may` keeps.

    Returns (known, clauses, rest, residue): the leading requirements, the new clauses (each a list of literals, one
    of which must hold), the body after the leading requirements (per place), and the satisfiable conjunctions of
    `may` that the precondition leaves (per place, special atoms included). `facts` are literals that hold wherever the
    effect can be used (an Ability used from the Bench: the player has a Benched Pokémon); they simplify the clauses and
    are not written."""
    ks = [leading(b) for b in bodies]
    known = ks[0][0]
    assert all(k == known for k, _ in ks)
    rests = [r for _, r in ks]
    musts, mays = [], []
    for r in rests:
        may, must = analyse(r, coin)
        musts.append(must)
        mays.append(may)
    # guardable: a conjunction of public literals that is `must` at every place
    cands = [c for c in musts[0] if not special(c)]
    guard = [c for c in cands if all(any(implies(c, d) for d in m if not special(d)) for m in musts[1:])]
    clauses = unit_propagate([[(t, not p) for (t, p) in sorted(c, key=lit_order)] for c in guard],
                             list(known) + list(facts))
    # the conjunctions of `may` consistent with the requirements and the new clauses
    residue = []
    for may in mays:
        for c in may:
            base = c | frozenset(known) | frozenset(facts)
            if any(sat(base | frozenset(pick)) for pick in itertools.product(*clauses)) and c not in residue:
                residue.append(c)
    return known, clauses, rests, residue


def apply(e, known, clauses):
    """The effect with the new precondition after its leading requirements, and the `ite`s it decides removed."""
    if not clauses:
        return e
    _, rest = leading(e)
    head = []
    first = e
    for _ in known:
        x, first = (first[1], first[2]) if first[0] == 'seq' else (first, SKIP)
        head.append(x)
    units = list(known) + [cl[0] for cl in clauses if len(cl) == 1]
    body = decide(rest, units)
    out = [*head, *[require(cl) for cl in clauses], body]
    out = [x for x in out if x != SKIP]
    r = out[-1]
    for x in reversed(out[:-1]):
        r = ('seq', x, r)
    return r


def residue_caveats(residue, have, kind):
    """The caveats the conjunctions left after the precondition call for, given the caveats `have` the card already
    carries: a `COV` conjunction is covered by any of its named caveats (the first is added if none is there); a
    conjunction with `HIDDEN` or `COIN` is allowed by print; anything else is a play or use to no effect."""
    out = set()
    for c in residue:
        atoms = [a for (a, _) in c]
        if ('HIDDEN',) in atoms or ('COIN',) in atoms:
            continue
        covs = [a[1] for a in atoms if a[0] == 'COV']
        if covs and not any(a[0] == 'NOTEST' for a in atoms):
            names = covs[0]
            if not (set(names) & (have | out)):
                out.add(names[0])
            continue
        out.add('noopUse' if kind == 'ability' else 'noopPlay')
    return out
