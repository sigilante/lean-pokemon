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

VERSION = '0.4.0'
PART_SIZE = 150

CARD_LEVEL = ('Ability', 'Ancient Trait', 'Pokémon Tool', 'Stadium', 'Special Energy',
              'Trainer played as a Pokémon')

# Blocking mechanisms for the not-imported cards, by keyword (an approximate classification of the
# refusal reason and sentence, first match wins; card-level kinds come first).
MECHS = [
    ('static or passive Ability', r'^Ability: static'),
    ("triggered Ability (Knock Out, damage, Checkup, opponent's action, move between spots)", r'^Ability: triggered'),
    ('Ability with a first-turn rule ("once during your first turn", "can\'t use … during your first turn")',
     r'^Ability: (?:once during your first turn|first-turn limit)'),
    ('Ability: self Knock Out, from the hand, untestable condition or cost (other activated-Ability forms)',
     r'^Ability: (?!returns|condition on the history)|^Ability$|^Ancient Trait$'),
    ('Pokémon Tool card: static or triggered text (the model would play it inert; refused)',
     r'^Pokémon Tool: (?:static|triggered)'),
    ('Stadium card: static or triggered text (the model would play it inert; refused)', r'^Stadium: (?:static|triggered|text of several)'),
    ('Stadium card: activated effect the model cannot express', r'^Stadium: activated'),
    ('Pokémon Tool card: other (attack grant not expressible, end-of-turn discard, Mega rule, unclassified record)',
     r'^Pokémon Tool: '),
    ('Pokémon Tool in other card text', r'Pokémon Tool|\bTools?\b'),
    ('Stadium in other card text', r'Stadium'),
    ('Special Energy (card or text)', r'^Special Energy$|Special Energy'),
    ('Trainer played as a Pokémon', r'^Trainer played as a Pokémon$'),
    ('first-turn rules in text', r'first turn|go first|go second'),
    ('history (this turn, last turn, Knock Outs)', r'^Ability: condition on the history|last turn|this turn|during this game|Knocked Out|was healed|moved from your Bench'),
    ('evolution or devolution by effect', r'evolve|devolve'),
    ('return from play to hand or deck', r'^Ability: returns|(this|that|those) Pokémon and all attached cards|all attached cards into'),
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
    TR.set_names(cards)
    P = pool.standard_pool(cards)
    G = pool.group(P)
    commit = pool.dataset_commit(data)
    results = []
    for recs in G:
        r = TR.translate_card(recs[0])
        # every record of a card translates to the same result (the key's canonicalisation loses
        # nothing the translator reads)
        for x in recs[1:]:
            rx = TR.translate_card(x)
            assert (rx['ok'], rx['term'], rx['caveats']) == (r['ok'], r['term'], r['caveats']), (recs[0]['id'], x['id'])
        results.append((recs, r))
    files = {}

    # ---------------------------------------------------------------- Lean parts
    imported = [(recs, r) for recs, r in results if r['ok']]
    idents = [emit.ident(recs[0]) for recs, _ in imported]
    assert len(set(idents)) == len(idents)
    # distinct cards have distinct terms (checked again in Lean: `all_nodup`)
    srcs = [emit.card_src(r['term']) for _, r in imported]
    assert len(set(srcs)) == len(srcs), 'two imported cards have the same Lean term'
    # the pool is partitioned: every card is imported or not, once
    assert len(results) == len(imported) + sum(1 for _, r in results if not r['ok'])
    assert len({id(recs) for recs, _ in results}) == len(results)
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
        src.append('/-- No card of this part is played with no effect (`Card.inert`: a Stadium whose effect is `skip`, a\n'
                   'Tool that gives nothing). -/')
        src.append('theorem cards_notInert : cards.all (fun c => !c.inert) = true := by decide +kernel\n')
        src.append('/-- No two cards of this part are the same term (`nodupFp`, see `PokemonCards.Props`). -/')
        src.append('theorem cards_nodup : nodupFp cards = true := by decide +kernel\n')
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
           '/-- **The count.** `all` has %d entries. -/' % n_imp,
           'theorem all_length : all.length = %d := by decide +kernel\n' % n_imp,
           '/-- `notImported` has %d entries. -/' % len(not_imp),
           'theorem notImported_length : notImported.length = %d := by decide +kernel\n' % len(not_imp),
           '/-- Arithmetic on the two lengths, and nothing more: %d + %d = %d. That the two lists partition the\n'
           'pool\'s %d cards (every card of the pool in exactly one of them, once) is established outside Lean, by\n'
           'the importer (`tools/importer/importer.py`, which asserts it when it writes this file) and by an\n'
           'external check script; the pool itself is not a Lean object. -/' % (n_imp, len(not_imp), n_pool, n_pool),
           'theorem pool_size : all.length + notImported.length = %d := by decide +kernel\n' % n_pool,
           '/-- Every imported card passes the per-card checks. -/',
           'theorem all_ok : all.all Card.importOk = true := by\n  simp only [all, List.all_append, '
           + ', '.join(pn + '.cards_ok' for pn in part_names) + ', Bool.and_self]\n',
           '/-- **No imported card is inert.** No imported Stadium or Tool is a card the model plays with no\n'
           'effect (`Card.inert`): every imported Stadium has an effect the model expresses, every imported Tool\n'
           'gives an attack or an Ability. (Static and triggered Stadium and Tool text, which the model would\n'
           'play as inert, is refused by the importer.) -/',
           'theorem notInert : ∀ c ∈ all, c.inert = false := by\n'
           '  have h : all.all (fun c => !c.inert) = true := by\n'
           '    simp only [all, List.all_append, '
           + ', '.join(pn + '.cards_notInert' for pn in part_names) + ', Bool.and_self]\n'
           '  intro c hc\n'
           '  simpa using List.all_eq_true.1 h c hc\n',
           ] + [
           '/-- No card of part %d is the same term as a card of part %d. -/\n'
           'theorem cross_%d_%d : crossOk %s.cards %s.cards = true := by decide +kernel\n'
           % (i + 1, j + 1, i + 1, j + 1, part_names[i], part_names[j])
           for j in range(len(part_names)) for i in range(j)] + [
           '/-- **No duplicates.** No two entries of `all` are the same `Card` term, so `all` counts %d distinct\n'
           'cards. (Checked by `nodupFp`, part by part and pair of parts by pair of parts, to keep each kernel check\n'
           'small.) -/' % n_imp,
           'theorem all_nodup : all.Nodup :=\n  nodup_of_nodupFp (by\n    simp only [all, nodupFp_append, crossOk_append_left, '
           + ', '.join(pn + '.cards_nodup' for pn in part_names) + ',\n      '
           + ', '.join('cross_%d_%d' % (i + 1, j + 1) for j in range(len(part_names)) for i in range(j))
           + ', Bool.and_self])\n',
           '/-- The imported cards that write a lingering damage bonus or reduction (`Effect.writes`), by name. -/',
           'theorem writers : (all.filter Card.writesAmt).map Card.label = ' + T.lean([recs[0]['name'] for recs, _ in writers])
           + ' := by decide +kernel\n',
           '/-- The imported cards that write any lingering modifier (bonus, reduction, prevention, lock), by name. -/',
           'theorem lingerers : (all.filter Card.lingers).map Card.label = ' + T.lean([recs[0]['name'] for recs, _ in lingerers])
           + ' := by decide +kernel\n',
           '/-- The imported Items that write a bonus or reduction (`Card.wAmt`), the cards clause 3 (a) of\n'
           '`Faithful` forbids Items, Supporters and "as often as you like" Abilities to recycle, by name. -/',
           'theorem nonSupporterWriters : (all.filter fun c => c.wAmt != 0).map Card.label = '
           + T.lean([t[1] for t in [r['term'] for _, r in imported] if w_amt(t)]) + ' := by decide +kernel\n',
           '/-- The imported Items and Supporters that write a rest-of-game bonus or reduction (`Card.alAmt`), by\n'
           'name. -/',
           'theorem restOfGameWriters : (all.filter fun c => c.alAmt != 0).map Card.label = '
           + T.lean([t[1] for t in [r['term'] for _, r in imported] if al_amt(t)]) + ' := by decide +kernel\n',
           '/-- The imported cards with (or, a Tool, giving) an Ability that writes a lingering damage bonus or\n'
           'reduction, by name. -/',
           'theorem abilityWriters : (all.filter Card.abilityWrites).map Card.label = '
           + T.lean([recs[0]['name'] for recs, r in imported if ability_writes(r['term'], T.writes)]) + ' := by decide +kernel\n',
           '/-- The imported cards with (or giving) an Ability that writes any lingering modifier, by name. -/',
           'theorem abilityLingerers : (all.filter Card.abilityLingers).map Card.label = '
           + T.lean([recs[0]['name'] for recs, r in imported if ability_writes(r['term'], T.lingers)]) + ' := by decide +kernel\n',
           '/-- The imported cards with (or giving) an "as often as you like" Ability (`AbilityUse.unlimited`), by\n'
           'name. -/',
           'theorem unlimitedAbilities : (all.filter Card.hasUnlimited).map Card.label = '
           + T.lean([recs[0]['name'] for recs, r in imported if has_unlimited(r['term'])]) + ' := by decide +kernel\n',
           '/-- The imported cards with (or giving) an Ability that can return a card from a discard pile, by\n'
           'name. -/',
           'theorem abilityRecyclers : (all.filter Card.abilityRecycles).map Card.label = '
           + T.lean([recs[0]['name'] for recs, r in imported if ability_recycles(r['term'])]) + ' := by decide +kernel\n',
           '/-- The imported cards whose effects a player can resolve again and again in one turn and that can\n'
           'return a card from a discard pile (`Card.freeRec`: Items, Supporters and "as often as you like"\n'
           'Abilities; not Stadiums, whose uses are bounded per turn), by name: the recyclers clause 3 (a) of\n'
           '`Faithful` constrains. -/',
           'theorem freeRecyclers : (all.filter fun c => !c.freeRec.isEmpty).map Card.label = '
           + T.lean([recs[0]['name'] for recs, r in imported if free_rec(r['term'])]) + ' := by decide +kernel\n',
           '/-- The imported Stadiums and Pokémon Tools, by name (milestone M5; none is `Card.inert`, `notInert`). -/',
           'theorem stadiumsAndTools : (all.filter fun c => c.isStadium || c.isTool).map Card.label = '
           + T.lean([recs[0]['name'] for recs, r in imported if r['term'][0] == 'tool'
                     or (r['term'][0] == 'trainer' and r['term'][2] == ('stadium',))]) + ' := by decide +kernel\n',
           '/-- The imported Stadiums whose effect can return a card from a discard pile (`Card.allRec`; not\n'
           'free recyclers, `Card.freeRec`, since their uses are bounded per turn), by name. -/',
           'theorem stadiumRecyclers : (all.filter fun c => c.isStadium && !c.allRec.isEmpty).map Card.label = '
           + T.lean([recs[0]['name'] for recs, r in imported if r['term'][0] == 'trainer'
                     and r['term'][2] == ('stadium',) and T.rec_filters(r['term'][3])]) + ' := by decide +kernel\n',
           '/-- Clause 3 of `Faithful` over the whole imported pool, decided. -/',
           'theorem recSafe : recSafeB all = ' + ('true' if not rs_pairs else 'false') + ' := by decide +kernel\n',
           ]
    if not rs_pairs:
        src += ['/-- Clause 3 (`RecycleSafe`) for every game whose cards are all imported cards: no Trainer and no\n'
                '"as often as you like" Ability of the pool can return a non-Supporter writer of a bonus or reduction,\n'
                'and no effect of the pool a rest-of-game writer. -/',
                'theorem recycleSafe (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.RecycleSafe :=\n'
                '  recycleSafe_of recSafe g hg\n',
                '/-- Clause 4 (`AbilitySafe`) for every game whose cards are all imported cards. -/',
                'theorem abilitySafeGames (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.AbilitySafe :=\n'
                '  fun x hx => abilitySafe_of all_ok x (hg x hx)\n',
                '/-- Clause 5 (`StadiumSafe`) for every game whose cards are all imported cards. -/',
                'theorem stadiumSafeGames (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.StadiumSafe :=\n'
                '  fun x hx => stadiumSafe_of all_ok x (hg x hx)\n',
                '/-- **Every game whose cards are all imported cards is `Faithful`** (all five clauses: `LoopFree`,\n'
                '`GXOnly`, `RecycleSafe`, `AbilitySafe` and `StadiumSafe`), so `Faithful.xfinite` applies to it. -/',
                'theorem faithful (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) : g.Faithful :=\n'
                '  faithful_of all_ok recSafe g hg\n',
                '/-- The finiteness theorem for imported decks: `Faithful.xfinite` with its premise discharged. -/',
                'theorem xfinite (g₀ : GameState) (hg : ∀ x ∈ g₀.allCards, x ∈ all) :\n'
                '    (∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp ∈ L) ∧\n'
                '      ∀ g₁ g₂, Reach g₀ g₁ → g₁.xclamp = g₂.xclamp →\n'
                '        (∀ g₁\', Move g₁ g₁\' → ∃ g₂\', Move g₂ g₂\' ∧ g₁\'.xclamp = g₂\'.xclamp) ∧\n'
                '        (∀ g₂\', Move g₂ g₂\' → ∃ g₁\', Move g₁ g₁\' ∧ g₂\'.xclamp = g₁\'.xclamp) :=\n'
                '  Faithful.xfinite (faithful g₀ hg)\n']
    src += ['/-- Every attack an imported card has or (a Tool) gives is well formed (`Attack.wf`, required by\n'
            '`Move.attack`). -/',
            'theorem attacks_wf : ∀ c ∈ all, ∀ a ∈ c.attacks, a.wf = true :=\n'
            '  attacks_wf_of all_ok\n',
            '/-- Every imported Trainer effect is `hitFree` and `benchHitFree` (required by `Move.item`,\n'
            '`Move.supporter` and, for a Stadium\'s effect, `Move.stadiumUse`). -/',
            'theorem trainers_hitFree : ∀ c ∈ all, ∀ n k e, c = .trainer n k e →\n'
            '    e.hitFree = true ∧ e.benchHitFree = true :=\n  trainers_of all_ok\n',
            '/-- Every script of every Ability an imported card has or (a Tool) gives has no attack damage step\n'
            'and no attack damage to the Bench (premises of `Move.ability` and `Move.onPlay`). -/',
            'theorem abilities_hitFree : ∀ c ∈ all, ∀ ab ∈ c.abilities, ∀ e ∈ ab.scripts,\n'
            '    e.hitFree = true ∧ e.benchHitFree = true :=\n  abilities_of all_ok\n',
            '/-- Every imported card satisfies clause 4 of `Faithful` (`Card.abilitySafe`): no imported "as often\n'
            'as you like" Ability writes a damage bonus or reduction, and no imported Ability a rest-of-game one. -/',
            'theorem abilitySafe : ∀ c ∈ all, c.abilitySafe = true := abilitySafe_of all_ok\n',
            '/-- Every imported card satisfies clause 1 of `Faithful` (`Card.loopFree`, Ability scripts included). -/',
            'theorem loopFree : ∀ c ∈ all, c.loopFree = true := loopFree_of all_ok\n',
            '/-- Every imported card satisfies clause 5 of `Faithful` (`Card.stadiumSafe`): no imported Stadium\'s\n'
            'effect writes a rest-of-game bonus or reduction. -/',
            'theorem stadiumSafe : ∀ c ∈ all, c.stadiumSafe = true := stadiumSafe_of all_ok\n',
            '/-- `GXOnly` over the imported pool: no attack an imported card has or gives that is not a GX attack\n'
            'writes a rest-of-game bonus or reduction (no imported attack is a GX attack). -/',
            'theorem gxOnly : ∀ c ∈ all, ∀ atk ∈ c.attacks, atk.gx = false →\n'
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


def ability_status(recs, r):
    """For a Pokémon with an Ability: 'imported ...', or the first reason its Ability was refused, or
    'Ability translated; card blocked elsewhere'."""
    if r['ok']:
        return status_of(r)
    texts = [TR.norm(a.get('text')) for a in recs[0].get('abilities') or []]
    for a, b in r['blockers']:
        if a.startswith('Ability') or (b and any(b in t for t in texts)):
            if a.startswith('Ability'):
                return ':'.join(a.split(':')[:2])
            if a == 'unhandled sentence':
                return 'Ability effect: a sentence has no rule'
            return 'Ability effect: ' + a.split(':')[0]
    return 'Ability translated; card blocked elsewhere'


def ability_section(results):
    L = []
    ab = [(recs, r) for recs, r in results if recs[0]['supertype'] == 'Pokémon' and recs[0].get('abilities')]
    c = collections.Counter(ability_status(recs, r) for recs, r in ab)
    L.append('Pokémon with an Ability (%d cards): imported exactly %d, imported with caveats %d, not imported %d. '
             'Not imported, by the first reason the Ability was refused (or "translated; card blocked elsewhere"):'
             % (len(ab), c['imported exactly'], c['imported with caveats'],
                len(ab) - c['imported exactly'] - c['imported with caveats']))
    L.append('')
    L.append('| status or reason | cards |')
    L.append('|---|---|')
    for k, v in sorted(c.items(), key=lambda kv: (not kv[0].startswith('imported'), -kv[1], kv[0])):
        L.append('| %s | %d |' % (k, v))
    L.append('')
    use = collections.Counter()
    for recs, r in ab:
        if r['ok']:
            for x in r['term'][1]['abilities']:
                use[x['use'][0] + ('-' + x['use'][1][0] if x['use'][0] == 'onPlay' else '')] += 1
    L.append('Imported Abilities by use limit: %s.' % ', '.join('%s %d' % kv for kv in sorted(use.items())))
    L.append('')
    one = [(recs, r) for recs, r in ab if any(TR.ONE_PER_NAME.match(s) for a in recs[0]['abilities']
                                              for s in TR.split_sentences(TR.norm(a.get('text'))))]
    L.append('Cards whose Ability says "You can\'t use more than 1 … Ability each turn" (%d): %s. Imported with the '
             'caveat `onePerName` (allows more): %s.' % (
                 len(one), ', '.join('%s (%s)' % (recs[0]['name'], recs[0]['id']) for recs, _ in one),
                 ', '.join('%s (%s)' % (recs[0]['name'], recs[0]['id']) for recs, r in one if r['ok']) or 'none'))
    L.append('')
    unl = [(recs, r) for recs, r in ab if r['ok'] and has_unlimited(r['term'])]
    L.append('Imported "as often as you like" Abilities (%d):' % len(unl))
    L.append('')
    for recs, r in unl:
        for x in r['term'][1]['abilities']:
            L.append('- %s (%s), %s: `%s`' % (recs[0]['name'], recs[0]['id'], x['name'], T.lean(x['effect'])))
    L.append('')
    return L


def first_reason(r):
    a, b = r['blockers'][0]
    return a + (': ' + b if b and a != 'unhandled sentence' else (': ' + b if b else ''))


def card_attacks(term):
    """`Card.attacks`: a Pokémon card's attacks, or the attacks a Tool gives."""
    if term[0] == 'pokemon':
        return term[1]['attacks']
    if term[0] == 'tool':
        return term[2]['attacks']
    return []


def card_abilities(term):
    """`Card.abilities`: a Pokémon card's Abilities, or the Abilities a Tool gives."""
    if term[0] == 'pokemon':
        return term[1]['abilities']
    if term[0] == 'tool':
        return term[2]['abilities']
    return []


def card_effects(term):
    """Every effect of the card: the attacks and the scripts of the Abilities it has or gives, or a
    Trainer's effect (an Item's or Supporter's, or a Stadium's)."""
    if term[0] == 'trainer':
        return [term[3]]
    return ([a['effect'] for a in card_attacks(term)]
            + [e for ab in card_abilities(term) for e in T.ability_scripts(ab)])


def ability_writes(term, pred):
    return any(pred(e) for ab in card_abilities(term) for e in T.ability_scripts(ab))


def has_unlimited(term):
    return any(ab['use'] == ('unlimited',) for ab in card_abilities(term))


def ability_recycles(term):
    return any(T.rec_filters(e) for ab in card_abilities(term) for e in T.ability_scripts(ab))


def term_writes(term):
    return any(T.writes(e) for e in card_effects(term))


def term_lingers(term):
    return any(T.lingers(e) for e in card_effects(term))


def w_amt(term):
    """`Card.wAmt`: what an Item writes when played (0 for a Supporter and, since M5, a Stadium)."""
    if term[0] == 'trainer' and term[2] == ('item',):
        return T.amt(term[3])
    return 0


def al_amt(term):
    """`Card.alAmt`: the rest-of-game amount an Item or Supporter writes (0 for a Stadium)."""
    if term[0] == 'trainer' and term[2] != ('stadium',):
        return T.amt_at('always', term[3])
    return 0


def free_rec(term):
    """`Card.freeRec`: the recycling filters of an Item's or Supporter's effect (not a Stadium's,
    since M5) and of the "as often as you like" Abilities a card has or gives."""
    if term[0] == 'trainer':
        return [] if term[2] == ('stadium',) else T.rec_filters(term[3])
    return [f for ab in card_abilities(term) if ab['use'] == ('unlimited',)
            for e in T.ability_scripts(ab) for f in T.rec_filters(e)]


def recycle_pairs(terms):
    """Violations of `RecycleSafe` over the pool: (recycler, filter, writer, clause) tuples."""
    out = []
    W = [y for y in terms if w_amt(y)]
    A = [y for y in terms if al_amt(y)]
    for x in terms:
        for f in free_rec(x):
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
                 'look-top-take': 'move own (top n) hand F (upTo k); shuffle',
                 'discard-all-and': 'the two clauses as two sentences (discardEnergy own active energy all; the damage)'})
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
    L.append('Caveats (cards may carry several), with their direction: does the term allow outcomes the printed '
             'card does not (allows more), forbid outcomes it allows (forbids some), or both? A card imported with '
             'caveats is in general neither an over- nor an under-approximation of its printed card, so the imported '
             'pool must not be used for "no deck can ..." arguments without checking the caveat.')
    L.append('')
    L.append('| caveat | direction | cards | meaning |')
    L.append('|---|---|---|---|')
    for k, v in sorted(cav.items(), key=lambda kv: (['allows more', 'forbids some', 'both'].index(TR.CAVEAT_DIRECTION[kv[0]]), -kv[1], kv[0])):
        L.append('| `%s` | %s | %d | %s |' % (k, TR.CAVEAT_DIRECTION[k], v, TR.CAVEATS[k]))
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
    L += ability_section(results)
    # unhandled templates
    sc = collections.Counter()
    exs = {}
    for recs, r in results:
        if r['ok']:
            continue
        if any(a in CARD_LEVEL or a.startswith(('Pokémon Tool:', 'Stadium:')) for a, _ in r['blockers']):
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
