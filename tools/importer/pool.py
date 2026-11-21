"""Load the card data and select the Standard pool.

The pool is survey S9's pool B: every record with regulation mark H, I or J, plus every Basic
Energy record (an assumption about today's Standard format; see survey/S9-standard-profile.md (a)).
Records are grouped into *cards*: records with the same game-relevant content (name, supertype,
subtypes, HP, types, evolves-from, abilities, attacks with cost, damage and text, Weakness,
Resistance, retreat cost, rules), after the formatting variants listed in `card_key` are
canonicalised, are one card. S9's identity key (name plus text) ignores HP, costs and damage but
does not canonicalise formatting; both counts are reported.

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


# Lines that are formatting, not content: play reminders (the rules say the same), the ACE SPEC
# line (the subtype says it), and the labels some printings put before a rule line.
REMINDER_LINES = {
    'You may play any number of Item cards during your turn.',
    'You may play only 1 Supporter card during your turn.',
    'You may play only 1 Supporter card during your turn (before your attack).',
    "ACE SPEC: You can't have more than 1 ACE SPEC card in your deck.",
    "You can't have more than 1 ACE SPEC card in your deck.",
}
RULE_LABELS = ('Tera: ', 'Pokémon ex rule: ')


def canon(s):
    """Text with typographic quotes straightened and every run of whitespace (spaces, newlines)
    collapsed to one space."""
    return ' '.join(norm_text(s).split())


def canon_rules(rules):
    """Rule lines as a set: canonical text, a leading label removed, reminder lines dropped, sorted."""
    out = []
    for r in rules or []:
        r = canon(r)
        if r in REMINDER_LINES:
            continue
        for lab in RULE_LABELS:
            if r.startswith(lab):
                r = r[len(lab):]
        out.append(r)
    return sorted(out)


def canon_name(c):
    """A Basic Energy card is printed as 'Fire Energy' or 'Basic Fire Energy'; the same card."""
    n = c['name']
    if is_basic_energy(c) and n.startswith('Basic '):
        n = n[len('Basic '):]
    return n


def card_key(c):
    """Every field the importer reads, canonicalised; two records with the same key are the same card.
    Formatting variants are one card: whitespace and line breaks in text, the order of rule lines, a
    'Tera: ' or 'Pokémon ex rule: ' label, play reminders and the ACE SPEC line, a 'Free' cost (printed
    as an empty cost elsewhere), 'Basic ' in a Basic Energy name, and the `types` field of a Basic
    Energy record (present on some records, absent on others; the name gives the type). Reprints that
    differ in any field (HP, cost, damage, text, Weakness, ...) stay distinct cards."""
    def atk(a):
        return (canon(a.get('name')), tuple(x for x in a.get('cost') or [] if x != 'Free'),
                canon(a.get('damage')), canon(a.get('text')))
    at = c.get('ancientTrait')
    return json.dumps([
        canon_name(c), c['supertype'], sorted(c['_sub']), c.get('hp'),
        None if is_basic_energy(c) else c.get('types'), c.get('evolvesFrom'),
        [(a.get('type'), canon(a.get('name')), canon(a.get('text'))) for a in c.get('abilities') or []],
        (canon(at.get('name')), canon(at.get('text'))) if at else None,
        [atk(a) for a in c.get('attacks') or []],
        c.get('weaknesses'), c.get('resistances'), c.get('convertedRetreatCost'),
        canon_rules(c.get('rules')),
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
