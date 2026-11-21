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

VERSION = '0.5.0'
PART_SIZE = 150

CARD_LEVEL = ('Ability', 'Ancient Trait', 'Pokémon Tool', 'Stadium', 'Special Energy',
              'Trainer played as a Pokémon')

# Blocking mechanisms for the not-imported cards, by keyword (an approximate classification of the
# refusal reason and sentence, first match wins; card-level kinds come first).
MECHS = [
    # static text of an Ability, a Tool or a Stadium outside the model's `Static` (milestone M6), by reason code
] + [('static text (Ability, Tool or Stadium): ' + d, r'^(?:Ability|Pokémon Tool|Stadium): static, ' + k + ' ')
     for k, d in TR.STATIC_DESC.items()] + [
    ('static Ability: first-turn rule', r'^Ability: static \(first-turn rule\)'),
    ('data defect: a Stage 1 or Stage 2 record with no evolves-from field', r'^evolution card with no evolves-from'),
    ("triggered Ability (Knock Out, damage, Checkup, opponent's action, move between spots)", r'^Ability: triggered'),
    ('Ability with a first-turn rule ("once during your first turn", "can\'t use … during your first turn")',
     r'^Ability: (?:once during your first turn|first-turn limit)'),
    ('Ability: self Knock Out, from the hand, untestable condition or cost (other activated-Ability forms)',
     r'^Ability: (?!returns|condition on the history)|^Ability$|^Ancient Trait$'),
    ('Pokémon Tool card: triggered text (the model would play it inert; refused)', r'^Pokémon Tool: triggered'),
    ('Stadium card: triggered text, or several paragraphs (the model would play it inert; refused)',
     r'^Stadium: (?:triggered|text of several)'),
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
    all_imported = [(recs, r) for recs, r in results if r['ok']]
    # Two cards of the pool whose records differ only in text the importer reads as a reminder (a Tool's
    # "Attach a Pokémon Tool to 1 of your Pokémon …" line, a misprinted "Pokémon V_atk" in the Rule Box
    # reminder) translate to the same term (milestone M6: Air Balloon, Brave Bangle). The term is written
    # once, for the earlier card; the later one is listed in `sameTerm` with the card whose term it is.
    first = {}
    imported, same = [], []
    for recs, r in all_imported:
        k = emit.card_src(r['term'])
        if k in first:
            same.append((recs, r, first[k]))
        else:
            first[k] = recs
            imported.append((recs, r))
    term_of = {id(recs): first[emit.card_src(r['term'])] for recs, r in all_imported}
    idents = [emit.ident(recs[0]) for recs, _ in imported]
    assert len(set(idents)) == len(idents)
    # distinct written terms (checked again in Lean: `all_nodup`)
    srcs = [emit.card_src(r['term']) for _, r in imported]
    assert len(set(srcs)) == len(srcs), 'two imported cards have the same Lean term'
    # the pool is partitioned: every card is imported (with its own term, or one it shares) or not, once
    assert len(results) == len(imported) + len(same) + sum(1 for _, r in results if not r['ok'])
    assert len({id(recs) for recs, _ in results}) == len(results)
    parts = [imported[i:i + PART_SIZE] for i in range(0, len(imported), PART_SIZE)]
    part_names = []
    # the largest printed HP and the largest HP units of one card's static effects, over the imported
    # pool (the constants of the HP bound, `hpOf_le`)
    hp_max = max(printed_hp(r['term']) for _, r in imported)
    gain_max = max(hp_gain(r['term']) for _, r in imported)
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
        for k, what, pred, _ in STATIC_KINDS:
            src.append('/-- The cards of this part with a static %s effect (milestone M6), by name. -/' % what)
            src.append('theorem cards_static%s : (cards.filter (Card.hasStatic %s)).map Card.label = %s := by decide +kernel\n'
                       % (k, pred, T.lean([recs[0]['name'] for recs, r in chunk if k in static_kinds(r['term'])])))
        src.append('/-- Every printed HP in this part is at most %d counters (the largest over the imported pool). -/' % hp_max)
        src.append('theorem cards_printedHp : cards.all (fun c => decide (c.printedHp ≤ %d)) = true := by decide +kernel\n'
                   % hp_max)
        src.append('/-- The HP units of every card\'s static effects in this part (`Card.hpGain`) are at most %d counters\n'
                   '(the largest over the imported pool). -/' % gain_max)
        src.append('theorem cards_hpGain : cards.all (fun c => decide (c.hpGain ≤ %d)) = true := by decide +kernel\n'
                   % gain_max)
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
           '/-- Every imported card (%d terms, for %d of the pool\'s %d cards: %d cards share the term of another,\n'
           '`sameTerm`). -/' % (n_imp, n_imp + len(same), n_pool, len(same)),
           'def all : List Card :=\n  ' + ' ++\n  '.join(pn + '.cards' for pn in part_names) + '\n',
           '/-- The imported cards whose term is that of an earlier card in `all` (their records differ only in\n'
           'text read as a reminder): representative record id, name, and the id of the card whose term it is. -/',
           'def sameTerm : List (String × String × String) := ['
           + ', '.join('(' + T.lean_str(recs[0]['id']) + ', ' + T.lean_str(recs[0]['name']) + ', '
                       + T.lean_str(o[0]['id']) + ')' for recs, _, o in same) + ']\n',
           '/-- The cards of the pool that were not imported, each with its representative record id, name and\n'
           'first blocking reason (the full list of reasons is in tools/importer/out/not-imported.tsv). -/',
           'def notImported : List (String × String × String) := [\n  '
           + ',\n  '.join('(' + T.lean_str(recs[0]['id']) + ', ' + T.lean_str(recs[0]['name']) + ', '
                          + T.lean_str(first_reason(r)) + ')' for recs, r in not_imp) + ']\n',
           '/-- **The count.** `all` has %d entries. -/' % n_imp,
           'theorem all_length : all.length = %d := by decide +kernel\n' % n_imp,
           '/-- `notImported` has %d entries. -/' % len(not_imp),
           'theorem notImported_length : notImported.length = %d := by decide +kernel\n' % len(not_imp),
           '/-- Arithmetic on the three lengths, and nothing more: %d + %d + %d = %d. That the three lists partition\n'
           'the pool\'s %d cards (every card of the pool in exactly one of them, once) is established outside Lean, by\n'
           'the importer (`tools/importer/importer.py`, which asserts it when it writes this file); the pool itself\n'
           'is not a Lean object. -/' % (n_imp, len(same), len(not_imp), n_pool, n_pool),
           'theorem pool_size : all.length + sameTerm.length + notImported.length = %d := by decide +kernel\n' % n_pool,
           '/-- Every imported card passes the per-card checks. -/',
           'theorem all_ok : all.all Card.importOk = true := by\n  simp only [all, List.all_append, '
           + ', '.join(pn + '.cards_ok' for pn in part_names) + ', Bool.and_self]\n',
           '/-- **No imported card is inert.** No imported Stadium or Tool is a card the model plays with no\n'
           'effect (`Card.inert`): every imported Stadium has an activated or (milestone M6) a static effect the\n'
           'model expresses, every imported Tool gives an attack, an Ability or a static effect. (Triggered Stadium\n'
           'and Tool text, and static text outside the model\'s `Static`, which the model would play as inert, is\n'
           'refused by the importer.) -/',
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
                '/-- The finiteness theorem for imported decks: `Faithful.xfinite` with its premise discharged; the clamp\n'
                'is taken at `Enum.bound g₀.allCards`, which bounds every derived HP (milestone M6). -/',
                'theorem xfinite (g₀ : GameState) (hg : ∀ x ∈ g₀.allCards, x ∈ all) :\n'
                '    (∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp (Enum.bound g₀.allCards) ∈ L) ∧\n'
                '      ∀ g₁ g₂, Reach g₀ g₁ →\n'
                '        g₁.xclamp (Enum.bound g₀.allCards) = g₂.xclamp (Enum.bound g₀.allCards) →\n'
                '        (∀ g₁\', Move g₁ g₁\' → ∃ g₂\', Move g₂ g₂\' ∧\n'
                '          g₁\'.xclamp (Enum.bound g₀.allCards) = g₂\'.xclamp (Enum.bound g₀.allCards)) ∧\n'
                '        (∀ g₂\', Move g₂ g₂\' → ∃ g₁\', Move g₁ g₁\' ∧\n'
                '          g₂\'.xclamp (Enum.bound g₀.allCards) = g₁\'.xclamp (Enum.bound g₀.allCards)) :=\n'
                '  Faithful.xfinite (faithful g₀ hg)\n']
    src += static_theorems(imported, part_names, hp_max, gain_max)
    src += ['/-- Every attack an imported card has or (a Tool) gives is well formed (`Attack.wf`, required by\n'
            '`Move.attack`). -/',
            'theorem attacks_wf : ∀ c ∈ all, ∀ a ∈ c.attacks, a.wf = true :=\n'
            '  attacks_wf_of all_ok\n',
            '/-- Every imported Trainer effect is `hitFree` and `benchHitFree` (required by `Move.item`,\n'
            '`Move.supporter` and, for a Stadium\'s effect, `Move.stadiumUse`). -/',
            'theorem trainers_hitFree : ∀ c ∈ all, ∀ n k e ss, c = .trainer n k e ss →\n'
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
    rows = [('id', 'name', 'kind', 'status', 'caveats', 'records', 'lean_name', 'static_kinds')]
    for recs, r in all_imported:
        rows.append((recs[0]['id'], recs[0]['name'], kind_of(recs[0]), status_of(r), ','.join(sorted(r['caveats'])),
                     ' '.join(x['id'] for x in recs), emit.ident(term_of[id(recs)][0]),
                     ','.join(static_kinds(r['term']))))
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


def stadium_tool_section(results):
    """Stadiums and Tools (milestone M5): the imported ones with their terms, the refused ones by
    reason (the reason with its quoted text dropped)."""
    L = []
    for kind in ('Stadium', 'Pokémon Tool'):
        rs = [(recs, r) for recs, r in results if kind_of(recs[0]) == kind]
        imp = [(recs, r) for recs, r in rs if r['ok']]
        L.append('%s cards (%d): imported %d, refused %d.' % (kind, len(rs), len(imp), len(rs) - len(imp)))
        L.append('')
        for recs, r in imp:
            L.append('- imported: %s (%s)%s: `%s`' % (recs[0]['name'], ', '.join(x['id'] for x in recs),
                                                      ' [caveats: ' + ', '.join(sorted(r['caveats'])) + ']' if r['caveats'] else '',
                                                      ' '.join(emit.card_src(r['term']).split())))
        L.append('')
        c = collections.Counter()
        for recs, r in rs:
            if not r['ok']:
                a = r['blockers'][0][0]
                a = re.sub(r'^(Stadium: activated effect not expressible): .*$', r'\1', a)
                c[a] += 1
        L.append('| refused by reason | cards |')
        L.append('|---|---|')
        for k, v in sorted(c.items(), key=lambda kv: (-kv[1], kv[0])):
            L.append('| %s | %d |' % (k, v))
        L.append('')
    return L


def static_source(c):
    return 'Pokémon Tool' if 'Pokémon Tool' in c['_sub'] else 'Stadium' if 'Stadium' in c['_sub'] else 'Ability'


def static_texts(c):
    """The static texts of a card that the importer read as static (milestone M6): each static Ability's text,
    a Tool's or a Stadium's whole text."""
    out = []
    if c['supertype'] == 'Pokémon':
        for a in c.get('abilities') or []:
            t = TR.norm(a.get('text'))
            if TR.ability_refusal(t) == 'Ability: static or passive':
                out.append(t)
    return out


def static_section(results):
    """Static text (milestone M6): the imported static effects by kind and source, the refused static texts
    by reason code, and the stacking texts."""
    L = []
    imp = [(recs, r) for recs, r in results if r['ok'] and card_statics(r['term'])]
    L.append('Static text (milestone M6). Cards imported with a static effect: %d (Pokémon with a static Ability %d, '
             'Pokémon Tools %d, Stadiums %d). By kind (a card may have several):' % (
                 len(imp), sum(1 for recs, _ in imp if recs[0]['supertype'] == 'Pokémon'),
                 sum(1 for recs, _ in imp if 'Pokémon Tool' in recs[0]['_sub']),
                 sum(1 for recs, _ in imp if 'Stadium' in recs[0]['_sub'])))
    L.append('')
    L.append('| kind | cards | names |')
    L.append('|---|---|---|')
    for k, what, _, _ in STATIC_KINDS:
        xs = [(recs, r) for recs, r in imp if k in static_kinds(r['term'])]
        L.append('| %s | %d | %s |' % (what, len(xs), ', '.join('%s (%s)' % (recs[0]['name'], recs[0]['id']) for recs, _ in xs)))
    L.append('')
    for recs, r in imp:
        L.append('- %s (%s)%s: `%s`' % (recs[0]['name'], recs[0]['id'],
                                       ' [caveats: ' + ', '.join(sorted(r['caveats'])) + ']' if r['caveats'] else '',
                                       ' '.join(T.lean(card_statics(r['term'])).split())))
    L.append('')
    # refused static texts, by reason code: the first, and every code recorded
    first = collections.Counter()
    anyc = collections.Counter()
    alone = collections.Counter()
    by_src = collections.defaultdict(collections.Counter)
    n_txt = 0
    for recs, r in results:
        seen = collections.OrderedDict()
        for a, b in r['blockers']:
            m = re.match(r'^(Ability|Pokémon Tool|Stadium): static, (\w+) ', a)
            if m:
                seen.setdefault(b, []).append((m.group(1), m.group(2)))
        for b, codes in seen.items():
            n_txt += 1
            first[codes[0][1]] += 1
            by_src[codes[0][1]][codes[0][0]] += 1
            for _, k in codes:
                anyc[k] += 1
            if len({k for _, k in codes}) == 1:
                alone[codes[0][1]] += 1
    L.append('Static texts refused (%d texts, counted per card: an Ability text, or a whole Tool or Stadium text), by '
             'reason code: "first" is the code reported first, "alone" the texts with no other code, "any" the texts '
             'with this code among theirs (a keyword classification of the text):' % n_txt)
    L.append('')
    L.append('| code | meaning | first | Ability / Tool / Stadium (first) | alone | any |')
    L.append('|---|---|---|---|---|---|')
    for k, v in sorted(first.items(), key=lambda kv: (-kv[1], kv[0])):
        b = by_src[k]
        L.append('| `%s` | %s | %d | %d / %d / %d | %d | %d |' % (k, TR.STATIC_DESC[k], v, b['Ability'], b['Pokémon Tool'],
                                                             b['Stadium'], alone[k], anyc[k]))
    for k in sorted(set(anyc) - set(first)):
        L.append('| `%s` | %s | 0 | 0 / 0 / 0 | 0 | %d |' % (k, TR.STATIC_DESC[k], anyc[k]))
    L.append('')
    # stacking texts
    st = []
    for recs, r in results:
        for t in static_texts(recs[0]):
            if re.search(TR.STATIC_CODES[0][1], t):
                sents = [x for x in TR.split_sentences(t) if not re.search(TR.STATIC_CODES[0][1], x)]
                try:
                    TR.parse_static(sents, 'ability', {'kind': 'ability', 'name': recs[0]['name'], 'base': None, 'cost': None})
                    rest = 'the rest translates'
                except TR.Refuse as e:
                    rest = 'the rest is refused too (%s)' % e.reason
                st.append('- %s (%s): "%s" Refused; without the stacking sentence %s.' % (recs[0]['name'], recs[0]['id'], t, rest))
    L.append('Stacking texts ("The effect of X doesn\'t stack", "You can\'t apply more than 1 … at a time") in static '
             'Abilities: %d, all refused. The model adds every static effect in force, so two Pokémon with the Ability '
             'give twice the amount, where the printed card gives it once: a different HP, damage or reduction, which '
             'changes outcomes in both directions (more HP lets a Pokémon survive what the printed card Knocks Out, '
             'and a larger bonus Knocks Out what the printed card leaves standing), so the term would not be an '
             'over-approximation and an "allows more" caveat would be false. Pokémon Tools and Stadiums in the pool '
             'print no stacking text (a player has one Stadium in play; one Tool per Pokémon).' % len(st))
    L.append('')
    L += st
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


def static_theorems(imported, part_names, hp_max, gain_max):
    """The set-level statements about static effects (milestone M6): the imported cards with a static
    effect, by kind; the HP bound; `StaticTame` for decks without a static reduction."""
    out = []
    pl = lambda suffix: ', '.join(pn + '.' + suffix for pn in part_names)  # noqa: E731
    for k, what, pred, _ in STATIC_KINDS:
        names = [recs[0]['name'] for recs, r in imported if k in static_kinds(r['term'])]
        out += ['/-- The imported cards with a static %s effect (milestone M6), by name (%d). Checked part by part. -/'
                % (what, len(names)),
                'theorem static%s : (all.filter (Card.hasStatic %s)).map Card.label = %s := by\n'
                '  simp only [all, List.filter_append, List.map_append, %s, List.cons_append, List.nil_append,\n'
                '    List.append_nil]\n' % (k, pred, T.lean(names), pl('cards_static' + k))]
    out += ['/-- Every printed HP of an imported Pokémon is at most %d counters. -/' % hp_max,
            'theorem printedHp_le : ∀ c ∈ all, c.printedHp ≤ %d := by\n'
            '  have h : all.all (fun c => decide (c.printedHp ≤ %d)) = true := by\n'
            '    simp only [all, List.all_append, %s, Bool.and_self]\n'
            '  intro c hc\n'
            '  exact of_decide_eq_true (List.all_eq_true.1 h c hc)\n' % (hp_max, hp_max, pl('cards_printedHp')),
            '/-- The HP units of the static effects of every imported card (`Card.hpGain`: a constant "+N HP", or\n'
            'the N of "+N HP for each Energy") are at most %d counters. -/' % gain_max,
            'theorem hpGain_le : ∀ c ∈ all, c.hpGain ≤ %d := by\n'
            '  have h : all.all (fun c => decide (c.hpGain ≤ %d)) = true := by\n'
            '    simp only [all, List.all_append, %s, Bool.and_self]\n'
            '  intro c hc\n'
            '  exact of_decide_eq_true (List.all_eq_true.1 h c hc)\n' % (gain_max, gain_max, pl('cards_hpGain')),
            '/-- **A bound on derived HP** (milestone M6). In every game whose cards are all imported cards and\n'
            'number at most `N`, every Pokémon in play has derived HP (`GameState.hpOf`, in counters: printed HP\n'
            'changed by the static effects in force) at most %d + 2 (N + 1) (N %d). It is the model\'s `hpBound`\n'
            '(`GameState.hpOf_le_hpBound`) bounded with the two constants above; a bound, far from the largest HP\n'
            'reachable, about the model\'s terms and not about printed cards. The model has no deck size, hence\n'
            'the hypothesis on `N`. -/' % (hp_max, gain_max),
            'theorem hpOf_le (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) {N : Nat} (hn : g.allCards.length ≤ N)\n'
            '    {w : Whose} {sp : Spot} {p : InPlay} (hp : g.In w sp p) :\n'
            '    g.hpOf w sp p ≤ %d + 2 * (N + 1) * (N * %d) :=\n'
            '  hpOf_le_of printedHp_le hpGain_le hg hn hp\n' % (hp_max, gain_max),
            '/-- The bound for two 60-card decks (120 cards): derived HP at most %d counters (%d HP). -/'
            % (hp_max + 2 * 121 * 120 * gain_max, 10 * (hp_max + 2 * 121 * 120 * gain_max)),
            'theorem hpOf_le_120 (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all) (hn : g.allCards.length ≤ 120)\n'
            '    {w : Whose} {sp : Spot} {p : InPlay} (hp : g.In w sp p) : g.hpOf w sp p ≤ %d :=\n'
            '  hpOf_le g hg hn hp\n' % (hp_max + 2 * 121 * 120 * gain_max),
            '/-- **Decks without a static reduction are `StaticTame`** (the static part of `GameState.Fit`, a premise\n'
            'of the tame-deck theorem `Reach.finite`): every game whose cards are imported cards other than those of\n'
            '`staticReduce`. `Fit` asks more (every card `Card.tame`, no reduction stored at the start), which this\n'
            'does not establish; every game of imported cards is `Faithful` (`faithful`), so `Faithful.xfinite`\n'
            'applies to all of them. -/',
            'theorem staticTame (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ all ∧ x.hasStatic Static.reduces = false) :\n'
            '    g.StaticTame :=\n'
            '  staticTame_of fun x hx => (hg x hx).2\n']
    return out


def ab_statics(ab):
    """`Ability.statics`."""
    return list(ab['use'][1]) if ab['use'][0] == 'static' else []


def card_statics(term):
    """`Card.statics` (milestone M6): a Pokémon's static Abilities; a Tool's static text and static
    Abilities; a Stadium's static text."""
    if term[0] == 'pokemon':
        return [x for ab in term[1]['abilities'] for x in ab_statics(ab)]
    if term[0] == 'tool':
        return list(term[2].get('statics') or []) + [x for ab in term[2]['abilities'] for x in ab_statics(ab)]
    if term[0] == 'trainer' and term[2] == ('stadium',) and len(term) > 4:
        return list(term[4])
    return []


# The kinds of static effect, with the Lean predicate on a `Static` (PokemonCards/Props.lean; `Static.reduces`
# is the model's) and the `SEff` constructors of the kind.
STATIC_KINDS = [('Hp', 'HP', 'Static.isHp', ('hpPlus', 'hpMinus')),
                ('Bonus', 'damage bonus', 'Static.isBonus', ('bonus',)),
                ('Reduce', 'damage reduction', 'Static.reduces', ('reduce',)),
                ('Retreat', 'Retreat Cost', 'Static.isRetreat', ('retreatPlus', 'retreatMinus'))]


def static_kinds(term):
    return [k for k, _, _, effs in STATIC_KINDS if any(x['eff'][0] in effs for x in card_statics(term))]


def printed_hp(term):
    """`Card.printedHp`."""
    return term[1]['hp'] if term[0] == 'pokemon' else 0


def hp_gain(term):
    """`Card.hpGain`: the HP units of the card's static effects (`Static.hpUnit`)."""
    out = 0
    for x in card_statics(term):
        e = x['eff']
        if e[0] == 'hpPlus':
            out += e[1][1] if e[1][0] == 'const' else e[1][2]
    return out


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
    L += stadium_tool_section(results)
    L += static_section(results)
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
        L.append('Writers that clause 3 constrains: Items writing a bonus or reduction (`Card.wAmt`): %s; '
                 'Items or Supporters writing a rest-of-game bonus or reduction (`Card.alAmt`): %s.' % (
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
