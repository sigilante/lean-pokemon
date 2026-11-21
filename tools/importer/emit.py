"""Print translated cards as Lean source."""
import re

from terms import lean, lean_str


def ident(rec):
    """A Lean identifier for a card, from its representative record's id ('sv1-166' -> sv1_166)."""
    s = re.sub(r'[^A-Za-z0-9]', '_', rec['id'])
    if not s[0].isalpha():
        s = 'c_' + s
    return s


def attack_src(a, ind):
    pad = ' ' * ind
    return (pad + '{ name := ' + lean_str(a['name']) + ', cost := ' + lean(a['cost'])
            + ', damage := ' + str(a['damage']) + ',\n'
            + pad + '  effect := ' + lean(a['effect']) + ',\n'
            + pad + '  gx := ' + lean(a['gx']) + ' }')


def ability_src(ab, ind):
    pad = ' ' * ind
    return (pad + '{ name := ' + lean_str(ab['name']) + ', use := ' + lean(ab['use']) + ',\n'
            + pad + '  spot := ' + lean(ab['spot']) + ', cond := ' + lean(ab['cond']) + ',\n'
            + pad + '  effect := ' + lean(ab['effect']) + ' }')


def card_src(term):
    if term[0] == 'energy':
        return '.energy ' + lean(term[1], False)
    if term[0] == 'trainer':
        return ('.trainer ' + lean_str(term[1]) + ' ' + lean(term[2], False) + '\n    '
                + lean(term[3], False))
    if term[0] == 'tool':
        g = term[2]
        atks = ('[\n' + ',\n'.join(attack_src(x, 6) for x in g['attacks']) + ']') if g['attacks'] else '[]'
        abs_ = ('[\n' + ',\n'.join(ability_src(x, 6) for x in g['abilities']) + ']') if g['abilities'] else '[]'
        return ('.tool ' + lean_str(term[1]) + '\n'
                + '  { holder := ' + lean(g['holder']) + ',\n'
                + '    attacks := ' + atks + ',\n'
                + '    abilities := ' + abs_ + ' }')
    p = term[1]
    if p['attacks']:
        atks = '[\n' + ',\n'.join(attack_src(a, 6) for a in p['attacks']) + ']'
    else:
        atks = '[]'
    if p['abilities']:
        abs_ = '[\n' + ',\n'.join(ability_src(a, 6) for a in p['abilities']) + ']'
    else:
        abs_ = '[]'
    return ('.pokemon\n'
            + '  { name := ' + lean_str(p['name']) + ', stage := ' + lean(p['stage'])
            + ', evolvesFrom := ' + lean(p['evolvesFrom']) + ',\n'
            + '    hp := ' + str(p['hp']) + ', type := ' + lean(p['type']) + ', retreat := ' + str(p['retreat'])
            + ', weakness := ' + lean(p['weakness']) + ',\n'
            + '    resistance := ' + lean(p['resistance']) + ', ruleBox := ' + lean(p['ruleBox'])
            + ', tera := ' + lean(p['tera']) + ',\n'
            + '    abilities := ' + abs_ + ',\n'
            + '    attacks := ' + atks + ' }')


def doc_comment(recs, status, caveats):
    ids = ', '.join(r['id'] for r in recs)
    s = recs[0]['name'] + ' (' + recs[0]['id'] + '). Records: ' + ids + '.'
    if caveats:
        s += ' Caveats: ' + ', '.join(sorted(caveats)) + '.'
    return '/-- ' + s.replace('-/', '- /') + ' -/'
