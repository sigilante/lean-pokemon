"""Referee numbers for the generated card library: modifier writers, discard-pile recyclers, and which
recyclers can return which writers.

Reads the generated `PokemonCards/Standard/Part*.lean` (not the translator), so it is a second count
beside the Lean listings of `PokemonCards/Standard.lean` (`writers`, `freeRecyclers`, ...): survey S11
quotes its output. Text-level: each `def X : Card := ...` of a part is one term; a writer is a term with
a `linger` of a stored amount anywhere in it (`Mod.isAmt`: `bonus`, `reduce`, and since milestone MV6 the
step-2 penalty `weaken` and the step-5 increase `expose`); a recycler is a term with a `move .w .discard ...`
or (milestone MV6) a window `look .w .discard ...` (a card from a discard pile to the hand, deck or
elsewhere; `attach` from the discard pile takes Energy only, and no Energy card writes, so it is not
counted). A window on a discard pile recycles its filter if the other cards go back to the discard pile
and any card otherwise (`Effect.recFilters`). Whether a recycler can return a writer is
`Filter.eval` (Pokemon/Card.lean) mirrored on the parsed terms; an unknown filter stops the script.

Usage: python3 -I tools/importer/count_writers.py [PokemonCards/Standard]
(first written for the paper as a scratch script, 2026-11-22; importer 0.11.0 took it in; 0.12.0 added the MV6 kinds;
0.14.0 the triggered Abilities by event; 0.15.0 Special Energy cards.)
"""
import collections
import os
import re
import sys


def load(d):
    files = sorted(f for f in os.listdir(d) if re.match(r'Part\d+\.lean$', f))
    terms = []
    for f in files:
        txt = open(os.path.join(d, f), encoding='utf-8').read().split('\ndef cards : List Card')[0]
        for p in re.split(r'\n(?=(?:/--[^\n]*\n)?def [A-Za-z0-9_]+ : Card :=)', txt):
            m = re.search(r'def ([A-Za-z0-9_]+) : Card := \.(\w+)', p)
            if not m:
                continue
            p = p[m.start():]
            ident, ctor = m.group(1), m.group(2)
            info = dict(file=f, id=ident, ctor=ctor, kind=ctor, body=p)
            if ctor == 'pokemon':
                info['name'] = re.search(r'name := "([^"]*)"', p).group(1)
                info['stage'] = re.search(r'stage := \.(\w+)', p).group(1)
                info['type'] = re.search(r'type := \.(\w+)', p).group(1)
                info['ruleBox'] = re.search(r'ruleBox := \.(\w+)', p).group(1)
                info['hp'] = int(re.search(r'hp := (\d+)', p).group(1))
                info['tera'] = re.search(r'tera := (\w+)', p).group(1) == 'true'
                info['abilities'] = not re.search(r'abilities := \[\]', p)
                # importer 0.16.0 (milestone MV9): the printed Resistance type and the Ability names
                mr = re.search(r'resistance := some \(\.(\w+),', p)
                info['resist'] = mr.group(1) if mr else None
                ab = p.split('abilities := [', 1)[1].split('attacks := [', 1)[0] if 'abilities := [' in p else ''
                info['abNames'] = re.findall(r'\{ name := "([^"]*)", use :=', ab)
            elif ctor == 'energy':
                ms = re.match(r'def \S+ : Card := \.energy \(\.special "([^"]*)"', p)
                if ms:
                    # importer 0.15.0 (milestone MV8): a Special Energy card, read by its name
                    info['name'] = ms.group(1)
                    info['etype'] = None
                    info['special'] = True
                else:
                    info['name'] = None  # a Basic Energy card: no name the name filters read
                    info['etype'] = re.match(r'def \S+ : Card := \.energy \.(\w+)', p).group(1)
                    info['special'] = False
            else:
                info['name'] = re.search(r'\.\w+ "([^"]*)"', p).group(1)
                if ctor == 'trainer':
                    info['kind'] = re.match(r'def \S+ : Card := \.trainer "[^"]*" \.(\w+)', p).group(1)
            terms.append(info)
    return terms


def section(body, pos, ctor):
    """Where in a Pokémon or Tool term position `pos` lies: 'ability', 'attack' or 'static'."""
    if ctor not in ('pokemon', 'tool'):
        return 'card'
    best, bp = 'other', -1
    for h, lab in (('abilities := [', 'ability'), ('attacks := [', 'attack'), ('statics := [', 'static')):
        for mm in re.finditer(re.escape(h), body):
            if bp < mm.start() < pos:
                best, bp = lab, mm.start()
    return best


def ability_use(body, pos):
    uses = [mm for mm in re.finditer(r'use := (\.[a-zA-Z]+)', body) if mm.start() < pos]
    return uses[-1].group(1) if uses else None


def parse_filter(s, i=0):
    """Parse a Filter term starting at s[i]; return (ast, next index)."""
    while s[i] == ' ':
        i += 1
    if s[i] == '(':
        ast, i = parse_app(s, i + 1)
        assert s[i] == ')', s[i:i + 20]
        return ast, i + 1
    m = re.match(r'\.(\w+)', s[i:])
    return (m.group(1),), i + m.end()


def parse_app(s, i):
    while s[i] == ' ':
        i += 1
    m = re.match(r'\.(\w+)', s[i:])
    head = m.group(1)
    i += m.end()
    args = []
    while True:
        while s[i] == ' ':
            i += 1
        if s[i] == ')':
            return (head, *args), i
        if s[i] == '"':
            j = s.index('"', i + 1)
            args.append(s[i + 1:j])
            i = j + 1
        elif s[i] == '[':
            # importer 0.16.0: the name list of `Filter.nameIn`
            j = s.index(']', i)
            args.append(re.findall(r'"([^"]*)"', s[i:j]))
            i = j + 1
        elif s[i] == '(':
            a, i = parse_filter(s, i)
            args.append(a)
        elif s[i].isdigit():
            m2 = re.match(r'\d+', s[i:])
            args.append(int(m2.group(0)))
            i += m2.end()
        else:
            m2 = re.match(r'\.(\w+)', s[i:])
            args.append((m2.group(1),))
            i += m2.end()


def ev(f, c):
    """`Filter.eval` on a parsed term (Pokemon/Card.lean)."""
    h = f[0]
    pk = c['ctor'] == 'pokemon'
    if h == 'any':
        return True
    if h == 'and':
        return ev(f[1], c) and ev(f[2], c)
    if h == 'or':
        return ev(f[1], c) or ev(f[2], c)
    if h == 'not':
        return not ev(f[1], c)
    if h == 'pokemon':
        return pk
    if h == 'basic':
        return pk and c['stage'] == 'basic'
    if h == 'stage':
        return pk and c['stage'] == f[1][0]
    if h == 'ptype':
        return pk and c['type'] == f[1][0]
    if h == 'hpLe':
        return pk and c['hp'] <= f[1]
    if h == 'noRuleBox':
        return pk and c['ruleBox'] == 'none'
    if h == 'ex':
        return pk and c['ruleBox'] != 'none'
    if h == 'tera':
        return pk and c['tera']
    if h == 'hasAbility':
        return pk and c['abilities']
    # importer 0.16.0 (milestone MV9)
    if h == 'megaEx':
        return pk and c['ruleBox'] == 'megaEx'
    if h == 'resists':
        return pk and c['resist'] == f[1][0]
    if h == 'abilityNamed':
        return pk and f[1] in c['abNames']
    if h == 'nameIn':
        return c['name'] is not None and c['name'] in f[1]
    if h == 'named':
        return c['name'] == f[1]
    if h == 'namePrefix':
        return c['name'] is not None and c['name'].startswith(f[1])
    if h == 'nameHas':
        return c['name'] is not None and f[1] in c['name']
    if h == 'trainer':
        return c['ctor'] in ('trainer', 'tool')
    if h == 'kind':
        return c['ctor'] == 'trainer' and c['kind'] == f[1][0]
    if h == 'tool':
        return c['ctor'] == 'tool'
    if h == 'energy':
        return c['ctor'] == 'energy'
    if h == 'basicEnergy':
        return c['ctor'] == 'energy' and not c['special']
    if h == 'energyOf':
        return c['ctor'] == 'energy' and not c['special'] and c['etype'] == f[1][0]
    if h == 'specialEnergy':
        return c['ctor'] == 'energy' and c['special']
    raise ValueError('filter not mirrored: %r' % (f,))


LIN = re.compile(r'linger \.(own|opp) \.(now|next|after|always) \(?\.(bonus|reduce|weaken|expose|prevent|lock)')
AMT = ('bonus', 'reduce', 'weaken', 'expose')
REC = re.compile(r'move \.(own|opp) \.discard \.(\w+) ')
LOOK = re.compile(r'look \.(own|opp) \.discard ')
TRIG = re.compile(r'use := \.triggered \.(\w+) ')
# importer 0.18.0 (milestone MV11): attached Energy put into the hand or the deck (`Effect.returnEnergy w sp f q d`),
# a return from play to a zone a card can be played from again; `d = .discard` is a discard, not a return
RET = re.compile(r'returnEnergy \.(own|opp) \.(\w+) ')


def main(d):
    terms = load(d)
    print('terms:', len(terms), dict(sorted(collections.Counter(t['kind'] for t in terms).items())))
    writers = []
    for t in terms:
        hits = []
        for mm in LIN.finditer(t['body']):
            w, slot, mod = mm.groups()
            if mod in AMT:
                sec = t['kind'] if t['ctor'] == 'trainer' else section(t['body'], mm.start(), t['ctor'])
                if sec == 'ability':
                    sec += ':' + (ability_use(t['body'], mm.start()) or '?')
                hits.append((w, slot, mod, sec))
        if hits:
            writers.append((t, hits))
    print('terms writing a stored amount (bonus, reduce, weaken, expose):', len(writers),
          dict(sorted(collections.Counter(t['kind'] for t, _ in writers).items())))
    print('  by modifier (terms):', dict(sorted(collections.Counter(m for _, hs in writers for m in {h[2] for h in hs}).items())))
    print('  by (store, slot, modifier):', dict(sorted(collections.Counter((h[0], h[1], h[2]) for _, hs in writers for h in hs).items())))
    print('  by place (attack, ability:use, item, supporter, stadium, tool):',
          dict(sorted(collections.Counter(h[3] for _, hs in writers for h in hs).items())))
    print('  rest-of-game writes:', [t['name'] for t, hs in writers if any(h[1] == 'always' for h in hs)])
    print('  names:', [t['name'] for t, _ in writers])
    for mod in ('weaken', 'expose'):
        print('  %s writers:' % mod, [t['name'] for t, hs in writers if any(h[2] == mod for h in hs)])
    recyclers = collections.OrderedDict()
    for t in terms:
        for mm in REC.finditer(t['body']):
            fa, _ = parse_filter(t['body'], mm.end())
            sec = t['kind'] if t['ctor'] == 'trainer' else section(t['body'], mm.start(), t['ctor'])
            if sec == 'ability':
                sec += ':' + (ability_use(t['body'], mm.start()) or '?')
            recyclers.setdefault(t['id'], (t, []))[1].append((sec, fa))
        for mm in LOOK.finditer(t['body']):
            fa, j = parse_filter(t['body'], mm.end())          # the filter (the source `.discard` is matched)
            q, j = parse_filter(t['body'], j)
            into, j = parse_filter(t['body'], j)
            rest, j = parse_filter(t['body'], j)
            if rest != ('discard',):
                fa = ('any',)
            sec = t['kind'] if t['ctor'] == 'trainer' else section(t['body'], mm.start(), t['ctor'])
            if sec == 'ability':
                sec += ':' + (ability_use(t['body'], mm.start()) or '?')
            recyclers.setdefault(t['id'], (t, []))[1].append((sec, fa))
    print('terms that return a card from a discard pile:', len(recyclers),
          dict(sorted(collections.Counter(t['kind'] for t, _ in recyclers.values()).items())))
    free = [t['name'] for t, fs in recyclers.values()
            if any(s in ('item', 'supporter') or s == 'ability:.unlimited' for s, _ in fs)]
    print('  free recyclers (Item, Supporter, unlimited Ability):', len(free), free)
    wcards = [t for t, _ in writers]
    can, pairs = [], 0
    for t, fs in recyclers.values():
        ws = [w for w in wcards if any(ev(fa, w) for _, fa in fs)]
        if ws:
            can.append((t['name'], t['kind'], len(ws), sorted(set(w['kind'] for w in ws))))
            pairs += len(ws)
    print('recyclers that can return some writer:', len(can), '; recycler/writer pairs:', pairs)
    for x in can:
        print('   ', x)
    print('  can return a Pokémon writer:', len([x for x in can if 'pokemon' in x[3]]),
          [x[0] for x in can if 'pokemon' in x[3]])
    print('  can return a Supporter writer:', [x[0] for x in can if 'supporter' in x[3]])
    print('  can return an Item writer:', [x[0] for x in can if 'item' in x[3]])
    # importer 0.18.0 (milestone MV11): returns of attached Energy from play to the hand or the deck. Not recyclers in the
    # sense of `Effect.recFilters` (no card leaves a discard pile); the filter is still checked against every writer
    rets = collections.OrderedDict()
    for t in terms:
        for mm in RET.finditer(t['body']):
            fa, j = parse_filter(t['body'], mm.end())
            q, j = parse_filter(t['body'], j)
            dst, j = parse_filter(t['body'], j)
            if dst == ('discard',):
                continue
            sec = t['kind'] if t['ctor'] == 'trainer' else section(t['body'], mm.start(), t['ctor'])
            if sec == 'ability':
                sec += ':' + (ability_use(t['body'], mm.start()) or '?')
            rets.setdefault(t['id'], (t, []))[1].append((sec, fa, dst[0]))
    print('terms that return attached Energy from play to the hand or deck:', len(rets),
          dict(sorted(collections.Counter(s for _, fs in rets.values() for s, _, _ in fs).items())))
    print('  names:', [t['name'] for t, _ in rets.values()])
    rw = [(t['name'], w['name']) for t, fs in rets.values() for w in wcards if any(ev(fa, w) for _, fa, _ in fs)]
    print('  of them can return a writer (filter admits a writer term):', len(rw), rw)
    # importer 0.14.0: the triggered Abilities by event (`AbilityUse.triggered ev opt`; milestones M8b and MV7)
    trig = collections.OrderedDict()
    for t in terms:
        for mm in TRIG.finditer(t['body']):
            trig.setdefault(mm.group(1), []).append(t['name'])
    print('triggered Abilities by event (terms):', dict((k, len(v)) for k, v in trig.items()))
    for k, v in trig.items():
        print('  %s:' % k, v)


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'PokemonCards', 'Standard'))
