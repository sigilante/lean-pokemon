"""Print a stratified random sample of imported cards, each card's printed text beside its Lean term,
for checking by eye (survey S11, validation).

    python3 -I tools/importer/validate.py DATASET [--seed=N] [--per=K]
    python3 -I tools/importer/validate.py DATASET --abilities [--seed=N] [--n=K]

Strata: Pokémon with one attack and no attack text; Pokémon with two attacks; Pokémon with attack
text; Items; Supporters; Basic Energy (one). K cards per stratum (default 13; all of a stratum if
fewer).

With --abilities: imported Pokémon with an Ability, every "as often as you like" one and a seeded
sample of the others drawn in proportion from the once-per-turn and on-play strata, K in all
(default 40), each with its printed text, its caveats and its Lean term.
"""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import emit  # noqa: E402
import pool  # noqa: E402
import translate as TR  # noqa: E402
from importer import text_of  # noqa: E402


def stratum(c):
    if c['supertype'] == 'Energy':
        return 'energy'
    if c['supertype'] == 'Trainer':
        return 'item' if 'Item' in c['_sub'] else 'supporter'
    atks = c.get('attacks') or []
    if any(TR.norm(a.get('text')) for a in atks):
        return 'pokemon-text'
    return 'pokemon-1' if len(atks) == 1 else 'pokemon-2'


def ability_sample(G, seed, n):
    by = {}
    for recs in G:
        if recs[0]['supertype'] != 'Pokémon' or not recs[0].get('abilities'):
            continue
        r = TR.translate_card(recs[0])
        if r['ok']:
            u = r['term'][1]['abilities'][0]['use'][0]
            by.setdefault(u, []).append((recs, r))
    rnd = random.Random(seed)
    pick = [('unlimited', x) for x in by.get('unlimited', [])]
    rest = by.get('once', []) + by.get('onPlay', [])
    k = max(0, n - len(pick))
    for x in rnd.sample(rest, min(k, len(rest))):
        pick.append((x[1]['term'][1]['abilities'][0]['use'][0], x))
    return pick


def main(argv):
    args = [a for a in argv if not a.startswith('--')]
    flags = dict(a[2:].split('=', 1) for a in argv if a.startswith('--') and '=' in a)
    seed = int(flags.get('seed', 11))
    per = int(flags.get('per', 13))
    _, cards = pool.load(args[0])
    TR.set_names(cards)
    G = pool.group(pool.standard_pool(cards))
    if '--abilities' in argv:
        k = 0
        for s, (recs, r) in ability_sample(G, seed, int(flags.get('n', 40))):
            k += 1
            c = recs[0]
            print('=' * 100)
            print('#%d [%s] %s %s | %s | HP %s | %s' % (k, s, c['id'], c['name'], ','.join(sorted(c['_sub'])),
                                                      c.get('hp'), c.get('types')))
            for part in text_of(c).split(' | '):
                print('  TEXT  ' + part)
            print('  CAVEATS', ', '.join('%s (%s)' % (x, TR.CAVEAT_DIRECTION[x]) for x in sorted(r['caveats'])) or '-')
            print('  LEAN  def ' + emit.ident(c) + ' : Card := ' + emit.card_src(r['term']).replace('\n', '\n        '))
        print('sampled', k)
        return
    by = {}
    for recs in G:
        r = TR.translate_card(recs[0])
        if r['ok']:
            by.setdefault(stratum(recs[0]), []).append((recs, r))
    rnd = random.Random(seed)
    k = 0
    for s in ('pokemon-1', 'pokemon-2', 'pokemon-text', 'item', 'supporter', 'energy'):
        xs = by.get(s, [])
        pick = rnd.sample(xs, min(per if s != 'energy' else 1, len(xs)))
        for recs, r in pick:
            k += 1
            c = recs[0]
            print('=' * 100)
            print('#%d [%s] %s %s | %s | HP %s | %s | weak %s | res %s | retreat %s' % (
                k, s, c['id'], c['name'], ','.join(sorted(c['_sub'])), c.get('hp'), c.get('types'),
                c.get('weaknesses'), c.get('resistances'), c.get('convertedRetreatCost'),
            ))
            print('evolvesFrom:', c.get('evolvesFrom'))
            for part in text_of(c).split(' | '):
                print('  TEXT  ' + part)
            print('  CAVEATS', sorted(r['caveats']))
            print('  LEAN  def ' + emit.ident(c) + ' : Card := ' + emit.card_src(r['term']).replace('\n', '\n        '))
    print('sampled', k)


if __name__ == '__main__':
    main(sys.argv[1:])
