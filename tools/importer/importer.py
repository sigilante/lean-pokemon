"""Card importer: today's Standard pool to Lean terms of the model's card language.

Usage (standard library only; the card data is untrusted, so run in isolated mode):

    python3 -I tools/importer/importer.py DATASET [--out REPO] [--survey DIR] [--check]

DATASET is a checkout of pokemon-tcg-data (the directory holding cards/en and sets/en.json).
Writes, under REPO (default: the repository holding this script):
  PokemonCards/Standard/PartNN.lean   the accepted cards, a few hundred per file, with per-file checks
  PokemonCards/Standard.lean          the list of all imported cards, the named list of the rest, and
                                      the set-level theorems
  tools/importer/out/*.tsv            imported cards, not-imported cards, the template table
  tools/importer/out/coverage.md      the counted part of the coverage report
With --survey DIR, also copies the TSVs and the report to DIR (survey/S11-*). With --check, writes
everything to a temporary directory and diffs it against the files in REPO (exit 1 on a difference).
"""
import collections
import re
import difflib
import os
import sys


sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import emit  # noqa: E402
import pool  # noqa: E402
import terms as T  # noqa: E402
import translate as TR  # noqa: E402

VERSION = '0.1.0'
PART_SIZE = 150

CARD_LEVEL = ('Ability', 'Ancient Trait', 'Pokémon Tool', 'Stadium', 'Special Energy',
              'Trainer played as a Pokémon')

# Blocking mechanisms for the not-imported cards, by keyword (an approximate classification of the
# refusal reason and sentence, first match wins; card-level kinds come first).
MECHS = [
    ('Ability', r'^Ability$|^Ancient Trait$'),
    ('Pokémon Tool (card or text)', r'^Pokémon Tool$|Pokémon Tool|\bTools?\b'),
    ('Stadium (card or text)', r'^Stadium$|Stadium'),
    ('Special Energy (card or text)', r'^Special Energy$|Special Energy'),
    ('Trainer played as a Pokémon', r'^Trainer played as a Pokémon$'),
    ('first-turn rules in text', r'first turn|go first|go second'),
    ('history (this turn, last turn, Knock Outs)', r'last turn|this turn|during this game|Knocked Out|was healed|moved from your Bench'),
    ('evolution or devolution by effect', r'evolve|devolve'),
    ('return from play to hand or deck', r'(this|that|those) Pokémon and all attached cards|all attached cards into'),
    ('copy an attack', r'use it as this attack|as this attack'),
    ('Weakness/Resistance or effects ignored', r"isn't affected by|Weakness|Resistance"),
    ('test on a card in play (ex, Evolution, Basic, name, Tool, attack)', r"is a Pokémon ex|is an Evolution Pokémon|is a Basic Pokémon|is a Stage|has the .* attack|has a Pokémon Tool|in its name|Tera"),
    ('per-attack lock or attack choice', r"can't use (that attack|[A-Z][a-z]+)|Pokémon's attacks|tries to use an attack"),
    ('effect prevention, threshold or typed prevention', r'effects of attacks|from Basic|if that damage is|damage done to this Pokémon by attacks from'),
    ('Prize cards (taken, compared, moved)', r'Prize'),
    ('HP reads', r'\bHP\b'),
    ('opponent-side damage modifier before W/R / after W/R on the opponent', r'less damage \(before|more damage from attacks \(after'),
    ('damage or counters spread "in any way you like" / to several chosen', r"in any way you like|to \d+ of your opponent's|to 2 of|on \d+ of your opponent's|Choose \d+ of your opponent's"),
    ('Energy to hand, deck or between specific Pokémon', r'Energy .*into (your|their) (hand|deck)|Move .*Energy|Energy attached to this Pokémon into'),
    ('"If you do" / "in this way" consequences', r"If you do|in this way|If you can't|If you don't"),
    ('own Special Conditions', r'This Pokémon is now'),
    ('look at / reveal and choose from deck or hand', r'Look at|Reveal|reveal|find there'),
    ('heal several Pokémon', r'Heal .* each of|heal .* each'),
    ('turn ends / extra turns', r'turn ends|another turn'),
    ('coin-flip variants', r'heads|tails|coin'),
    ('effects before damage (switch then damage, "before doing damage")', r'new Active Pokémon|Before doing damage'),
    ('a condition the model cannot test', r'^condition not expressible'),
    ('a count the model cannot read', r'^count not expressible'),
    ('a card kind with no filter', r'^card kind with no filter'),
    ('several cards to one chosen Pokémon, or one to each', r'^several cards|to each of your|for each of your'),
    ('draw or discard variants (may draw until, draw for each, discard until)', r'[Dd]raw|discards? .*until'),
    ('other', r'.'),
]


def mech_of(reason, sentence):
    import re
    s = reason + ' :: ' + sentence
    for name, rx in MECHS:
        if re.search(rx, reason) or re.search(rx, sentence):
            return name
    return 'other'


def status_of(r):
    if not r['ok']:
        return 'not imported'
    return 'imported with caveats' if r['caveats'] else 'imported exactly'


def kind_of(c):
    if c['supertype'] == 'Pokémon':
        return 'Pokémon'
    if c['supertype'] == 'Energy':
        return 'Basic Energy' if 'Basic' in c['_sub'] else 'Special Energy'
    for k in ('Item', 'Supporter', 'Pokémon Tool', 'Stadium'):
        if k in c['_sub']:
            return k
    return 'Trainer (other)'


def text_of(c):
    parts = []
    for a in c.get('abilities') or []:
        parts.append('[Ability] ' + (a.get('name') or '') + ': ' + TR.norm(a.get('text')))
    for a in c.get('attacks') or []:
        parts.append('[' + ''.join(x[0] if x != 'Colorless' else 'C' for x in a.get('cost') or []) + '] '
                     + (a.get('name') or '') + ' ' + (a.get('damage') or '') + ': ' + TR.norm(a.get('text')))
    for r in c.get('rules') or []:
        parts.append(TR.norm(r))
    return ' | '.join(parts)


def tsv(rows):
    return ''.join('\t'.join(str(x).replace('\t', ' ').replace('\n', ' ') for x in r) + '\n' for r in rows)


def header(commit, what):
    return ('/-\n' + what + '\n\nGENERATED FILE: do not edit. Written by tools/importer/importer.py version ' + VERSION
            + '\nfrom pokemon-tcg-data commit ' + commit + ' (pool: regulation marks H, I, J plus Basic Energy,\n'
            'survey S9 pool B). Regenerate with `python3 -I tools/importer/importer.py <dataset>`.\n-/\n')


def run(data, out, survey=None):
    _, cards = pool.load(data)
    P = pool.standard_pool(cards)
    G = pool.group(P)
    commit = pool.dataset_commit(data)
    results = []
    for recs in G:
        r = TR.translate_card(recs[0])
        results.append((recs, r))
    files = {}

    # ---------------------------------------------------------------- Lean parts
    imported = [(recs, r) for recs, r in results if r['ok']]
    idents = [emit.ident(recs[0]) for recs, _ in imported]
    assert len(set(idents)) == len(idents)
    parts = [imported[i:i + PART_SIZE] for i in range(0, len(imported), PART_SIZE)]
    part_names = []
    for k, chunk in enumerate(parts, 1):
        pn = 'Part%02d' % k
        part_names.append(pn)
        src = [header(commit, 'Imported Standard cards, part %d of %d (%d cards).' % (k, len(parts), len(chunk))),
               'import PokemonCards.Props\n\nnamespace PokemonCards.Standard.' + pn + '\nopen Pokemon\n']
        for recs, r in chunk:
            src.append(emit.doc_comment(recs, status_of(r), r['caveats']))
            src.append('def ' + emit.ident(recs[0]) + ' : Card := ' + emit.card_src(r['term']) + '\n')
        src.append('/-- The cards of this part. -/')
        src.append('def cards : List Card := [\n  ' + ',\n  '.join(emit.ident(recs[0]) for recs, _ in chunk) + ']\n')
        src.append('/-- Every card of this part passes the per-card checks (`Card.importOk`). -/')
        src.append('theorem cards_ok : cards.all Card.importOk = true := by decide +kernel\n')
        src.append('end PokemonCards.Standard.' + pn + '\n')
        files['PokemonCards/Standard/' + pn + '.lean'] = '\n'.join(src)

    # ---------------------------------------------------------------- Standard.lean
    n_imp = len(imported)
    n_pool = len(results)
    not_imp = [(recs, r) for recs, r in results if not r['ok']]
    writers = [(recs, r) for recs, r in imported if term_writes(r['term'])]
    lingerers = [(recs, r) for recs, r in imported if term_lingers(r['term'])]
    rs_pairs = recycle_pairs([r['term'] for _, r in imported])
    src = [header(commit, 'The imported Standard cards: the list, the cards not imported, and the set-level checks.'),
           '\n'.join('import PokemonCards.Standard.' + pn for pn in part_names),
           'import PokemonCards.Props\n',
           'namespace PokemonCards.Standard\nopen Pokemon\n',
           '/-- Every imported card (%d of the pool\'s %d cards). -/' % (n_imp, n_pool),
           'def all : List Card :=\n  ' + ' ++\n  '.join(pn + '.cards' for pn in part_names) + '\n',
           '/-- The cards of the pool that were not imported, each with its representative record id, name and\n'
           'first blocking reason (the full list of reasons is in tools/importer/out/not-imported.tsv). -/',
           'def notImported : List (String × String × String) := [\n  '
           + ',\n  '.join('(' + T.lean_str(recs[0]['id']) + ', ' + T.lean_str(recs[0]['name']) + ', '
                          + T.lean_str(first_reason(r)) + ')' for recs, r in not_imp) + ']\n',
           '/-- **The count.** %d cards of the pool are imported. -/' % n_imp,
           'theorem all_length : all.length = %d := by decide +kernel\n' % n_imp,
           '/-- %d cards are not imported, and the two lists together are the %d cards of the pool. -/' % (len(not_imp), n_pool),
           'theorem notImported_length : notImported.length = %d := by decide +kernel\n' % len(not_imp),
           'theorem pool_size : all.length + notImported.length = %d := by decide +kernel\n' % n_pool,
           '/-- Every imported card passes the per-card checks. -/',
           'theorem all_ok : all.all Card.importOk = true := by\n  simp only [all, List.all_append, '
           + ', '.join(pn + '.cards_ok' for pn in part_names) + ', Bool.and_self]\n',
           '/-- The imported cards that write a lingering damage bonus or reduction (`Effect.writes`), by name. -/',
           'theorem writers : (all.filter Card.writesAmt).map Card.label = ' + T.lean([recs[0]['name'] for recs, _ in writers])
           + ' := by decide +kernel\n',
           '/-- The imported cards that write any lingering modifier (bonus, reduction, prevention, lock), by name. -/',
           'theorem lingerers : (all.filter Card.lingers).map Card.label = ' + T.lean([recs[0]['name'] for recs, _ in lingerers])
           + ' := by decide +kernel\n',
           '/-- The imported Trainers that are not Supporters and write a bonus or reduction (`Card.wAmt`), the\n'
           'cards clause 3 (a) of `Faithful` forbids Trainers to recycle, by name. -/',
           'theorem nonSupporterWriters : (all.filter fun c => c.wAmt != 0).map Card.label = '
           + T.lean([t[1] for t in [r['term'] for _, r in imported] if w_amt(t)]) + ' := by decide +kernel\n',
           '/-- The imported Trainers that write a rest-of-game bonus or reduction (`Card.alAmt`), by name. -/',
           'theorem restOfGameWriters : (all.filter fun c => c.alAmt != 0).map Card.label = '
           + T.lean([t[1] for t in [r['term'] for _, r in imported] if al_amt(t)]) + ' := by decide +kernel\n',
           '/-- Clause 3 of `Faithful` over the whole imported pool, decided. -/',
           'theorem recSafe : recSafeB all = ' + ('true' if not rs_pairs else 'false') + ' := by decide +kernel\n',
           ]
    if not rs_pairs:
        src += ['/-- **Every game whose cards are all imported cards is `Faithful`** (`LoopFree`, `GXOnly` and\n'
                '`RecycleSafe`), so `Faithful.xfinite` applies to it. -/',
                'theorem faithful (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.Faithful :=\n'
                '  faithful_of all_ok recSafe g hg\n',
                '/-- The finiteness theorem for imported decks: `Faithful.xfinite` with its premise discharged. -/',
                'theorem xfinite (g₀ : GameState) (hg : ∀ x ∈ g₀.allCards, x ∈ all) :\n'
                '    (∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp ∈ L) ∧\n'
                '      ∀ g₁ g₂, Reach g₀ g₁ → g₁.xclamp = g₂.xclamp →\n'
                '        (∀ g₁\', Move g₁ g₁\' → ∃ g₂\', Move g₂ g₂\' ∧ g₁\'.xclamp = g₂\'.xclamp) ∧\n'
                '        (∀ g₂\', Move g₂ g₂\' → ∃ g₁\', Move g₁ g₁\' ∧ g₂\'.xclamp = g₁\'.xclamp) :=\n'
                '  Faithful.xfinite (faithful g₀ hg)\n']
    src += ['/-- Every imported attack is well formed (`Attack.wf`, required by `Move.attack`). -/',
            'theorem attacks_wf : ∀ c ∈ all, ∀ p, c = .pokemon p → ∀ a ∈ p.attacks, a.wf = true :=\n'
            '  attacks_wf_of all_ok\n',
            '/-- Every imported Trainer effect is `hitFree` and `benchHitFree` (required by `Move.item` and\n'
            '`Move.supporter`). -/',
            'theorem trainers_hitFree : ∀ c ∈ all, ∀ n k e, c = .trainer n k e →\n'
            '    e.hitFree = true ∧ e.benchHitFree = true :=\n  trainers_of all_ok\n',
            '/-- Every imported card satisfies clause 1 of `Faithful` (`Card.loopFree`). -/',
            'theorem loopFree : ∀ c ∈ all, c.loopFree = true := loopFree_of all_ok\n',
            '/-- `GXOnly` over the imported pool: no imported attack that is not a GX attack writes a\n'
            'rest-of-game bonus or reduction (no imported attack is a GX attack). -/',
            'theorem gxOnly : ∀ p, Card.pokemon p ∈ all → ∀ atk ∈ p.attacks, atk.gx = false →\n'
            '    atk.effect.amtAt .always = 0 :=\n  gxOnly_of all_ok\n',
            'end PokemonCards.Standard\n']
    files['PokemonCards/Standard.lean'] = '\n'.join(src)

    # ---------------------------------------------------------------- TSVs
    rows = [('id', 'name', 'kind', 'status', 'caveats', 'records', 'lean_name')]
    for recs, r in imported:
        rows.append((recs[0]['id'], recs[0]['name'], kind_of(recs[0]), status_of(r), ','.join(sorted(r['caveats'])),
                     ' '.join(x['id'] for x in recs), emit.ident(recs[0])))
    files['tools/importer/out/imported.tsv'] = tsv(rows)
    rows = [('id', 'name', 'kind', 'mechanisms', 'reasons', 'records')]
    for recs, r in not_imp:
        ms = sorted({mech_of(a, b) for a, b in r['blockers']})
        rs = ' || '.join(sorted({a + (': ' + b if b else '') for a, b in r['blockers']}))
        rows.append((recs[0]['id'], recs[0]['name'], kind_of(recs[0]), '; '.join(ms), rs, ' '.join(x['id'] for x in recs)))
    files['tools/importer/out/not-imported.tsv'] = tsv(rows)
    files['tools/importer/out/templates.tsv'] = template_table(results)
    files['tools/importer/out/coverage.md'] = coverage(results, P, commit, writers, lingerers, rs_pairs, len(parts))
    for k in list(files):
        files[k] = files[k].rstrip('\n') + '\n'
    return files


def first_reason(r):
    a, b = r['blockers'][0]
    return a + (': ' + b if b and a != 'unhandled sentence' else (': ' + b if b else ''))


def card_effects(term):
    if term[0] == 'pokemon':
        return [a['effect'] for a in term[1]['attacks']]
    if term[0] == 'trainer':
        return [term[3]]
    return []


def term_writes(term):
    return any(T.writes(e) for e in card_effects(term))


def term_lingers(term):
    return any(T.lingers(e) for e in card_effects(term))


def w_amt(term):
    if term[0] == 'trainer':
        e = term[3]
        return 0 if term[2] == ('supporter',) else sum(T.amt_at(s, e) for s in ('now', 'next', 'after', 'always'))
    return 0


def al_amt(term):
    return T.amt_at('always', term[3]) if term[0] == 'trainer' else 0


def recycle_pairs(terms):
    """Violations of `RecycleSafe` over the pool: (recycler, filter, writer) triples."""
    out = []
    W = [y for y in terms if w_amt(y)]
    A = [y for y in terms if al_amt(y)]
    for x in terms:
        if x[0] == 'trainer':
            for f in T.rec_filters(x[3]):
                for y in W:
                    if T.filter_eval(f, y):
                        out.append((x, f, y, 'a'))
        for e in card_effects(x):
            for f in T.rec_filters(e):
                for y in A:
                    if T.filter_eval(f, y):
                        out.append((x, f, y, 'b'))
    return out


def template_table(results):
    """One row per rule: name, Lean fragment, sentences matched in imported cards and in the whole pool,
    and an example card."""
    desc = {name: d for name, _, _, d, _ in TR.RULES}
    desc.update({'reminder': 'skip (the model never applies Weakness or Resistance to the Bench)',
                 'flip-a-coin': 'choice (heads) (tails), or a choice of damage, or choice (whole attack) skip',
                 'flip-n-coins-damage': 'choice over 0..N heads of damage (const (h * k)) [+ base]',
                 'flip-n-coins-each': 'choice over 0..N heads of h copies of the effect',
                 'flip-until-tails-damage': 'damage (many (const k)) [+ base]',
                 'if-condition': 'ite test (consequence) (alternative); for damage, a test-dependent amount',
                 'look-top-take': 'move own (top n) hand F (upTo k); shuffle'})
    imp = collections.Counter()
    allc = collections.Counter()
    ex = {}
    for recs, r in results:
        for name, s in r['used']:
            allc[name] += 1
            if r['ok']:
                imp[name] += 1
                ex.setdefault(name, (recs[0]['id'] + ' ' + recs[0]['name'], s))
    rows = [('rule', 'lean_fragment', 'sentences_in_imported_cards', 'sentences_in_pool', 'example_card', 'example_sentence')]
    for name in sorted(allc, key=lambda n: -imp[n]):
        e = ex.get(name, ('', ''))
        rows.append((name, desc.get(name, ''), imp[name], allc[name], e[0], e[1]))
    return tsv(rows)


def pct(a, b):
    return '%.1f%%' % (100.0 * a / b) if b else '-'


def coverage(results, P, commit, writers, lingerers, rs_pairs, nparts):
    L = []
    n = len(results)
    recs_n = len(P)
    s9 = len({pool.s9_key(c) for c in P})
    L.append('<!-- generated by tools/importer/importer.py %s from pokemon-tcg-data %s -->' % (VERSION, commit))
    L.append('')
    L.append('Pool: %d records, %d cards (S9 identities: %d), %d Lean files.' % (recs_n, n, s9, nparts))
    L.append('')
    by = collections.defaultdict(collections.Counter)
    for recs, r in results:
        by[kind_of(recs[0])][status_of(r)] += 1
    L.append('| kind | cards | imported exactly | with caveats | not imported |')
    L.append('|---|---|---|---|---|')
    tot = collections.Counter()
    for k in ('Pokémon', 'Item', 'Supporter', 'Pokémon Tool', 'Stadium', 'Basic Energy', 'Special Energy', 'Trainer (other)'):
        c = by.get(k)
        if not c:
            continue
        t = sum(c.values())
        tot.update(c)
        L.append('| %s | %d | %d (%s) | %d (%s) | %d (%s) |' % (
            k, t, c['imported exactly'], pct(c['imported exactly'], t), c['imported with caveats'],
            pct(c['imported with caveats'], t), c['not imported'], pct(c['not imported'], t)))
    t = sum(tot.values())
    L.append('| **all** | **%d** | **%d (%s)** | **%d (%s)** | **%d (%s)** |' % (
        t, tot['imported exactly'], pct(tot['imported exactly'], t), tot['imported with caveats'],
        pct(tot['imported with caveats'], t), tot['not imported'], pct(tot['not imported'], t)))
    L.append('')
    # records
    rc = collections.Counter()
    for recs, r in results:
        rc[status_of(r)] += len(recs)
    L.append('By records: imported exactly %d, with caveats %d, not imported %d (of %d).' % (
        rc['imported exactly'], rc['imported with caveats'], rc['not imported'], recs_n))
    L.append('')
    cav = collections.Counter()
    for recs, r in results:
        if r['ok']:
            for k in r['caveats']:
                cav[k] += 1
    L.append('Caveats (cards may carry several):')
    L.append('')
    L.append('| caveat | cards | meaning |')
    L.append('|---|---|---|')
    for k, v in cav.most_common():
        L.append('| `%s` | %d | %s |' % (k, v, TR.CAVEATS[k]))
    L.append('')
    # blocking mechanisms
    alone = collections.Counter()
    anyc = collections.Counter()
    for recs, r in results:
        if r['ok']:
            continue
        ms = {mech_of(a, b) for a, b in r['blockers']}
        for m in ms:
            anyc[m] += 1
        if len(ms) == 1:
            alone[next(iter(ms))] += 1
    nn = sum(1 for _, r in results if not r['ok'])
    L.append('Blocking mechanisms of the %d cards not imported (keyword classification of each refusal; '
             '"alone": the only mechanism blocking the card, so the card would be imported once it is handled '
             'and its sentences are translated; "any": among its blockers):' % nn)
    L.append('')
    L.append('| mechanism | blocks alone | blocks (any) |')
    L.append('|---|---|---|')
    for m, _ in sorted(anyc.items(), key=lambda kv: (-alone[kv[0]], -kv[1])):
        L.append('| %s | %d | %d |' % (m, alone[m], anyc[m]))
    L.append('')
    # attacks-only hypothetical
    ab = [r for recs, r in results if recs[0]['supertype'] == 'Pokémon' and recs[0].get('abilities')]
    ab_ok = sum(1 for r in ab if {a for a, _ in r['blockers']} == {'Ability'})
    L.append('Hypothetical, NOT an import: of the %d Pokémon with an Ability, %d have no other blocker '
             '(static fields and every attack sentence translate); with Abilities in the model they would be '
             'candidates, subject to translating the Ability.' % (len(ab), ab_ok))
    L.append('')
    # unhandled templates
    sc = collections.Counter()
    exs = {}
    for recs, r in results:
        if r['ok']:
            continue
        if any(a in CARD_LEVEL for a, _ in r['blockers']):
            continue
        for a, b in r['blockers']:
            if a == 'unhandled sentence' or b:
                key = TR.normal(b or a, recs[0]['name'])
                sc[key] += 1
                exs.setdefault(key, recs[0]['id'])
    L.append('Top unhandled sentences (templates: numbers N, own name SELF, types TYPE) in cards not blocked by a '
             'card-level mechanism (Ability, Tool, Stadium, Special Energy):')
    L.append('')
    L.append('| count | template | example |')
    L.append('|---|---|---|')
    for k, v in sc.most_common(40):
        L.append('| %d | %s | %s |' % (v, k.replace('|', '/'), exs[k]))
    L.append('')
    L.append('Imported cards that write a lingering damage bonus or reduction (%d): %s.' % (
        len(writers), ', '.join('%s (%s)' % (recs[0]['name'], recs[0]['id']) for recs, _ in writers)))
    L.append('')
    L.append('Imported cards that write any lingering modifier (%d).' % len(lingerers))
    L.append('')
    if rs_pairs:
        L.append('RecycleSafe FAILS over the imported pool; violating (recycler, filter, writer, clause):')
        for x, f, y, cl in rs_pairs:
            L.append('- %s / %s / %s / %s' % (T.lean(x[1] if x[0] == 'trainer' else x[1]['name']), T.lean(f),
                                               y[1] if y[0] == 'trainer' else y[1]['name'], cl))
    else:
        rec = [(recs, r) for recs, r in results if r['ok'] and any(T.rec_filters(e) for e in card_effects(r['term']))]
        L.append('RecycleSafe holds over the imported pool. Imported recyclers (%d): %s.' % (
            len(rec), ', '.join('%s (%s)' % (recs[0]['name'], recs[0]['id']) for recs, _ in rec)))
        L.append('')
        terms_ = [r['term'] for _, r in results if r['ok']]
        L.append('Writers that clause 3 constrains: non-Supporter Trainers writing a bonus or reduction: %s; '
                 'Trainers writing a rest-of-game bonus or reduction: %s.' % (
                     [t[1] for t in terms_ if w_amt(t)] or 'none', [t[1] for t in terms_ if al_amt(t)] or 'none'))
    return '\n'.join(L)


def main(argv):
    args = [a for a in argv if not a.startswith('--')]
    flags = {a.split('=')[0]: (a.split('=', 1)[1] if '=' in a else True) for a in argv if a.startswith('--')}
    if not args:
        print(__doc__)
        return 2
    data = args[0]
    repo = flags.get('--out') or os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    files = run(data, repo)
    if flags.get('--check'):
        # regenerated in memory; compared with the files on disk, including stale generated files
        bad = 0
        expected = set(files)
        on_disk = {'PokemonCards/Standard.lean'}
        for root, ext in (('PokemonCards/Standard', '.lean'), ('tools/importer/out', '')):
            d = os.path.join(repo, root)
            if os.path.isdir(d):
                on_disk |= {root + '/' + f for f in os.listdir(d) if f.endswith(ext)}
        for f in sorted(expected | on_disk):
            p = os.path.join(repo, f)
            old = open(p, encoding='utf-8').read() if os.path.exists(p) else None
            new = files.get(f)
            if old != new:
                bad += 1
                print('DIFFERS:', f)
                if old is not None and new is not None:
                    sys.stdout.writelines(list(difflib.unified_diff(old.splitlines(True), new.splitlines(True), f, f))[:40])
                else:
                    print('  missing on disk' if old is None else '  not generated (stale file)')
        print('check:', 'OK, %d files identical' % len(files) if not bad else '%d files differ' % bad)
        return 1 if bad else 0
    for f, content in files.items():
        p = os.path.join(repo, f)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, 'w', encoding='utf-8') as h:
            h.write(content)
    survey = flags.get('--survey')
    if survey:
        for src, dst in (('tools/importer/out/imported.tsv', 'S11-imported.tsv'),
                         ('tools/importer/out/not-imported.tsv', 'S11-not-imported.tsv'),
                         ('tools/importer/out/templates.tsv', 'S11-templates.tsv')):
            with open(os.path.join(survey, dst), 'w', encoding='utf-8') as h:
                h.write(files[src])
    print('wrote %d files; imported %s' % (len(files), files['tools/importer/out/coverage.md'].split('\n')[2]))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
