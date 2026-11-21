"""Load the card data and select the Standard pool.

The pool is survey S9's pool B: every record with regulation mark H, I or J, plus every Basic
Energy record (an assumption about today's Standard format; see survey/S9-standard-profile.md (a)).
Records are grouped into *cards*: records with the same game-relevant content (name, supertype,
subtypes, HP, types, evolves-from, abilities, attacks with cost, damage and text, Weakness,
Resistance, retreat cost, rules) are one card. This is finer than S9's identity key (name plus
text), which ignores HP, costs and damage; both counts are reported.

Standard library only; the data is untrusted and read as JSON only. Run with python3 -I.
"""
import glob
import json
import os
import re

MARKS = ('H', 'I', 'J')


def load(root):
    """All English card records, each with its set id, release date and joined text."""
    sets = {s['id']: s for s in json.load(open(os.path.join(root, 'sets', 'en.json'), encoding='utf-8'))}
    cards = []
    for f in sorted(glob.glob(os.path.join(root, 'cards', 'en', '*.json'))):
        sid = os.path.basename(f)[:-5]
        for c in json.load(open(f, encoding='utf-8')):
            c['_set'] = sid
            c['_date'] = sets[sid]['releaseDate']
            c['_sub'] = set(c.get('subtypes') or [])
            cards.append(c)
    return sets, cards


def is_basic_energy(c):
    return c['supertype'] == 'Energy' and 'Basic' in c['_sub']


def standard_pool(cards):
    return [c for c in cards if c.get('regulationMark') in MARKS or is_basic_energy(c)]


def norm_text(s):
    return (s or '').replace('’', "'").replace('‘', "'").strip()


def s9_key(c):
    """Survey S9's identity: name plus all text (abilities, ancient trait, attacks, rules)."""
    parts = []
    for a in c.get('abilities') or []:
        parts.append(a.get('text') or '')
    at = c.get('ancientTrait')
    if at:
        parts.append(at.get('text') or '')
    for a in c.get('attacks') or []:
        parts.append(a.get('text') or '')
    for r in c.get('rules') or []:
        parts.append(r)
    return (c['name'], ' \n '.join(parts).replace('’', "'"))


def card_key(c):
    """Every field the importer reads; two records with the same key are the same card."""
    def atk(a):
        return (a.get('name'), tuple(a.get('cost') or []), a.get('damage') or '', norm_text(a.get('text')))
    return json.dumps([
        c['name'], c['supertype'], sorted(c['_sub']), c.get('hp'), c.get('types'), c.get('evolvesFrom'),
        [(a.get('type'), a.get('name'), norm_text(a.get('text'))) for a in c.get('abilities') or []],
        c.get('ancientTrait'),
        [atk(a) for a in c.get('attacks') or []],
        c.get('weaknesses'), c.get('resistances'), c.get('convertedRetreatCost'),
        [norm_text(r) for r in c.get('rules') or []],
    ], ensure_ascii=False, sort_keys=True)


def num_key(n):
    m = re.match(r'(\D*)(\d*)(.*)', n or '')
    return (m.group(1), int(m.group(2)) if m.group(2) else -1, m.group(3))


def group(pool):
    """Cards: lists of records with the same `card_key`, each list sorted by release date, set and
    number; the first record is the card's representative. Cards are sorted by representative."""
    d = {}
    for c in pool:
        d.setdefault(card_key(c), []).append(c)
    out = []
    for recs in d.values():
        recs.sort(key=lambda c: (c['_date'], c['_set'], num_key(c.get('number'))))
        out.append(recs)
    out.sort(key=lambda rs: (rs[0]['_date'], rs[0]['_set'], num_key(rs[0].get('number'))))
    return out


def dataset_commit(root):
    """The dataset's git commit, read from .git without running git (HEAD, then the ref)."""
    try:
        g = os.path.join(root, '.git')
        head = open(os.path.join(g, 'HEAD')).read().strip()
        if head.startswith('ref: '):
            ref = head[5:]
            p = os.path.join(g, ref)
            if os.path.exists(p):
                return open(p).read().strip()
            for line in open(os.path.join(g, 'packed-refs')):
                if line.strip().endswith(ref):
                    return line.split()[0]
        return head
    except OSError:
        return 'unknown'
