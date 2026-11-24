# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis for the printed game is that it is not: the game has no token
generation, and a Pokémon whose damage reaches its HP is Knocked Out, and the survey of the
English card pool (S3) found no unbounded store that play can both write and read. The model
generalises some card text beyond what printed cards do (for instance, lingering damage
modifiers add up without limit); with those generalisations the model does have unbounded
stores, and the finiteness results below need a hypothesis on the deck: tame decks
(`Reach.finite`) or store-safe decks (`StoreSafe.xfinite`); neither class contains the other.
The deck condition `StoreSafe` was called `Faithful` before 2026-11-22; it was renamed because
the old name read as "faithful to the printed cards", which it never meant (it only keeps the
stored damage modifiers bounded).

Status: early. The model covers a core of the rules: state; an effect language (`Pokemon.Effect`, 40 constructors) of
thirty-six primitive effects (`skip` included; milestone M5 added `discardStadium` and `discardTools`, milestone MV2 `benchSome`, milestone MV6 `look`) and four combinators (`ite`, `seq`, `choice`, `iter`), including the five
Special Conditions, a cure, Croagunk's stacking Poison ("This effect can be applied more than
once"), markers (Imprison, Shock-wave, Lightning Rod and Char as flags, the Coloring counter as a
type; placed on any Pokémon in play, removed from all of a player's Pokémon, Char damaging its
Active Pokémon at Checkup), lingering modifiers (per player, for this turn, the next turn, the
turn after, or the rest of the game, shifted at the end of every turn: a damage bonus, a damage
reduction, since milestone MV6 a step-2 penalty and a step-5 increase, damage prevention, and locks
on attacking, retreating and playing Items; the amounts add up without limit, and enter the damage
calculation described below), and effects
that read the state: a test on either
Active Pokémon (at least `n` damage counters, exactly `n`, a Special Condition, a marker, a
type), placing `k`
counters on the opponent's Active Pokémon for each damage counter on either Active Pokémon
(Lunala's doubling is the case `k = 1` on the opponent's), damage to the player's own Active
Pokémon, and healing all of its damage; a move relation in which an Asleep or Paralyzed
Pokémon can neither attack nor retreat and a Confused Pokémon's attack can fail (tails: no
attack, and 3 damage counters on itself); the rulebook's turn (milestone M1): an attack, or a
failed Confused attempt, ends the turn, so only its Knock Outs and the end of the turn follow
(`Move.after_attack`); the starting player cannot attack or play a Supporter on the first turn
of the game, and neither player can evolve on their own first turn (`PlayerState.hadTurn`) or
evolve a Pokémon put into play or evolved that turn (these bans assume a start state whose
turn flags are consistent, `GameState.FlagsOk`, which the model does not require of a start
state but which play preserves, `Reach.flagsOk`; the bans on the first turn of the game are theorems under it (the second player's
evolution ban on their own first turn is a premise of the move, not a theorem),
`Move.firstTurn_no_attack` and the like; after an attack a move either takes Knock Outs or
gives exactly the state that ending the turn gives, `Move.after_attack_passTurn`); one Energy attachment, one Supporter and
one retreat per turn (discarding the Energy of the player's choice, `Pokemon/Retreat.lean`); a new Poison replaces the old one, resetting its strength; Basic Energy
cards of the nine Basic types; typed attack costs, each typed symbol paid by Energy of its type
and each Colorless symbol by any Energy (`Pays`, a matching, decided by `payable`);
Weakness ×2 and Resistance −N on the Defending (Active) Pokémon; and the rulebook's damage
calculation, made once per attack (`dealtBy`: stop at base damage 0, the attacker's bonus,
Weakness, Resistance, the defender's reduction or prevention; an attack has at most one damage
step, whose amount its text may compute from the damage on either Active Pokémon, `Amt`, and
Item and Supporter effects have none); one Stadium slot shared by both players (milestone M5,
below); the Knock Out timing: once a move
leaves a Pokémon at or above its HP, it must be Knocked Out and replaced before any other
move (`Settled`); every Knock Out is taken by the batch Knock Out step (`KOBatch`, milestone
batch-KO), the rulebook's single check: every Pokémon in play of both players is tested against
its derived HP once, before any removal, all those at or above it leave play together, both
players take their Prize cards, the game is decided (a win, or `Outcome.suddenDeath` when both
players win in as many ways: the 2026 rulebook's tiebreaker game, not played; the name is the 2023
rulebook's), and then empty Active Spots are filled; if that leaves another
Pokémon at or above its HP the check repeats; inside an attack's effect damage may exceed HP and be read, and the Knock
Out comes after the attack; inside an Item or Supporter card's effect (`TRun`) the batch step
is taken at once after the step that causes a Knock Out, the rest of the effect acts on the new board,
and a finished game stops the effect (Knock Outs after an attack and after Checkup are the
English rulebook's; the immediate Knock Outs at other times come from the Pokémon Asia
*Advanced Player's Rulebook*, and survey S9 found no English rule for them, a provenance
problem recorded in the Known gaps); and Pokémon Checkup between turns (Poison, Burn,
Sleep, Paralysis, then Knock Outs). The sources of the turn rules, and where the 2023
rulebook, the later sources and the model differ, are listed at the top of
`Pokemon/Rules.lean`. Milestone M3 (the Bench) added: damage counters on one chosen or on every
Benched Pokémon of either player (`benchCounters`, `spreadCounters`), healing one of the player's
own Benched Pokémon (`benchHeal`), attack damage to Benched Pokémon (`benchDamage`,
`spreadDamage`: a printed amount with no Weakness, Resistance or other modifier, and none on a
Tera Pokémon on the Bench; dropping the defender's reduction and prevention does more damage to
the Bench than the rulebook, and dropping the attacker's bonus rests on a claim about printed
bonuses that the rulebook's own example, "this Pokémon's attacks do 40 more damage", does not
support, so the model's Bench damage is not a superset of the printed outcomes), switching the
player's own or the opponent's Active Pokémon with a Benched one (`switch`, which cures the
Pokémon sent to the Bench; inside an attack nothing after a `switch .own` may act on the
player's Active Pokémon, `Effect.switchSafe`, so the attacker stays the attacker,
`Attack.attacker_at_hit`, which since milestone MV keeps the attacker's Pokémon cards, not its
attached Energy; printed switch-out attacks do their damage first), Energy attachment
and evolution on the Bench, Char counters acting on Benched Pokémon between turns, Knock Outs of
any Pokémon in play (a Benched one goes to the discard pile with no promotion; until milestone
batch-KO several pending Knock Outs were taken one at a time in any order, and the order could
decide the winner and, with derived HP, which Pokémon were Knocked Out; since batch-KO they are
taken together, and when both players take their last Prize card the rulebook's simultaneous-win
rule applies: a tiebreaker game (`Outcome.suddenDeath`), unless one player wins in both ways, `Bench.suddenDeath_forced`,
`Bench.bothWays_wins`), and
Prize values by rule box (1; 2 for Pokémon ex; 3 for Mega Evolution Pokémon ex), taking the top
Prize cards and winning when the last one is taken in the middle of a multi-Prize Knock Out
(witnesses in `Pokemon/Bench.lean`). The Bench holds at most 5 Pokémon. Milestone MV (effect
vocabulary) added card filters (`Filter`: Pokémon, Basic, Stage, type, name, HP at most `n`, no
rule box, Trainer, a Trainer kind, Energy, Energy of a type, and Boolean combinations; a `Bool`,
so decidable) and six zone-move primitives on either player's zones (`ZStep`, lifted by the one
constructor `Run.zone`): `move` (from the deck, its top `n` cards, the hand or the discard pile, to
the hand, the discard pile, the top or bottom of the deck or shuffled into it, "up to `n`",
exactly `n` or all: search with a filter, draw `n`, mill, look at the top `n` and take some, a
discard-from-hand cost whose continuation runs only if it was paid, and recycling to hand or
deck), `drawTo` ("draw until you have `n` cards"), `attach` (one Energy from a zone to the Active
Pokémon or a Benched one), `putBench` (a Basic Pokémon from a zone onto the Bench),
`discardEnergy` and `moveEnergy`; and counts (`Count`: cards passing a filter in a hand, deck or
discard pile, Prize cards left, Benched Pokémon passing a filter, Energy on the Active Pokémon or on
all Pokémon in play) as amounts (`Amt.count`, "30 damage for each Energy attached") and tests
(`Test.countGe`). Its simplifications are in the Known gaps of `Pokemon/Rules.lean` ("up to"
allows 0 everywhere; `attach`, `putBench` and `moveEnergy` may do nothing; no hidden
information; a played Trainer is in the discard pile while it resolves; absent: returning a
Pokémon in play to the hand or deck, devolution, evolution by effect). Zone moves change only zones
and attached Energy and counts read no damage, so both clamps keep them exact and every clamp
theorem was re-proved without new hypotheses (`ZStep.sim`, `Count.val_clampAt`). Milestone M8a
added activated and on-play Abilities: a Pokémon card has a list of Abilities (`Ability`: a use
limit, "once during your turn" per Pokémon in play, "as often as you like", or on entering play from
the hand as a Basic, as an evolution or either; where it can be used from; an optional printed
condition; an effect). `Move.ability` uses an activated Ability of a Pokémon in play during the turn
proper, before attacking (rulebook 2023 p. 9: "F. Use Abilities (as many as you want). 3) Attack."),
with no Knock Out pending and spending no allowance of the turn; `Move.onPlay` plays a Pokémon from
the hand and resolves its on-play Ability. The effect resolves as a Trainer effect does (`TRun`). A
per-Pokémon flag (`InPlay.used`) records a use and is cleared at the end of its owner's turn and by
evolution (the evolved Pokémon has the new card's Abilities). Ability effects may act on "this
Pokémon" (`SelfOp`: heal it, put damage counters on it, attach Energy to it, switch it in, move
Energy to it): exact in the Active Spot, on the Bench a chosen Benched Pokémon (a superset); and a
new primitive moves a damage counter between the player's own Pokémon (`Effect.moveCounter`, Team
Rocket's Orbeetle), which both clamps keep exact (`CMove.sim`). Triggered Abilities (other than
on-play and the two shapes of milestone M8b), Ability locks and per-Pokémon modifiers are not
modelled (Known gaps); static Abilities came with milestone M6 (below). Milestone M8b added
triggered Abilities of the two commonest shapes of today's Standard (survey S12: 24 and 11 of the 67
after-event triggers): "if this Pokémon is in the Active Spot and is damaged by an attack from your
opponent's Pokémon (even if this Pokémon is Knocked Out), …" (`TrigEvent.damaged`) and "if this
Pokémon is Knocked Out by damage from an attack from your opponent's Pokémon, …"
(`TrigEvent.koByAttack`), on a Pokémon card or given by a Tool (`AbilityUse.triggered ev opt`,
`opt` for "you may"), with effects in a fragment that always resolves and reads no damage
(`Effect.trigOk`). They belong to the player whose turn it is not and resolve on the state with the
players exchanged (`GameState.swap`, `Fire`), each as a whole and several in any order: `damaged`
triggers at the end of the attack, before its Knock Out check (`Move.attack`, `HitTrig`; decided on the
attack's damage step, `HitRun`, so an attack that switches the opponent's Active Pokémon fires the
triggers of the Pokémon it damaged and no other's; the departures are in the Known gaps), `koByAttack`
triggers in the batch move after the attack (`Move.knockOuts`, `GameState.batchTrigs`), with the
Pokémon already in the discard pile. Every earlier theorem was re-proved; the statements that
named the batch step's result were restated (`Move.batch_of_not_settled`, `Move.after_attack`,
`Move.after_attack_passTurn`, `Move.knockOut_of_pending`, `Reach.knockOut_of_pending`,
`Move.pending_knockedOut`: the batch step is followed by its triggers), and for games with no
triggered Ability nothing changed (`Pokemon/NoTriggers.lean`). A chain of triggers and Knock Outs
ends (`KOMove.acc`, `Move.unsettled_acc`): every batch that Knocks Out a Pokémon takes Prize cards,
which nothing returns, and a batch that Knocks Out none fires no trigger and fills an Active Spot;
the Prize-changing triggers of the card pool, which would break this, are not modelled. The store
bound needs no new clause of `StoreSafe`: triggered Abilities write no store (the fragment has no
`linger`), their recycling is bound by clause 3 (b) like every effect's, and they are not free
recyclers in clause 3 (a), since a `koByAttack` trigger fires only after the turn's attack, when the
per-turn part of the invariant is vacuous (`TInv.same'`). Witnesses (`Pokemon/TriggerWitness.lean`):
a `damaged` trigger that Knocks Out the attacker with the defender, the batch that follows with a
`koByAttack` trigger that draws (forced when mandatory, declined when optional), the simultaneous
win, and attacks that switch the opponent's Active Pokémon (`gust_quiet`, `pull_fires`,
`hitRun_quiet`). Milestone MV7 (survey S20) added a third trigger event, "whenever your opponent's
Active Pokémon moves to the Bench during their turn" (`TrigEvent.oppBenched`; Magcargo sv5-29,
Mismagius ex me2-36), to the real move relation: a retreat and a switch of the player's own Active
Pokémon inside any effect record the event in the state (`GameState.pend`, a `Bool`, set only when
the opponent has such a trigger in play; enumerated by `Finite.states`, copied by both clamps);
`Settled` now also asks that nothing be pending (the old meaning is `Calm`), so the triggers resolve
before any other action, by the new move `Move.trigger` or, inside a Trainer, Stadium or Ability
effect, by the new step `Resolve.trigger` after the step that raised the event. Recording the event
at its source needs no Pokémon identity: Benching an identical copy of the old Active Pokémon raises
nothing (`Benched.copy_quiet`). Such a trigger may fire before the attack, as often as the player
switches, so its effect must recycle nothing (`Ability.trigOn`); with that the store bound needs no
new clause. Every theorem was re-proved; statements that spell out the moves from an unsettled state
gained the alternative `TrigMove` (`Move.batch_of_not_settled`, `Move.after_attack`,
`Move.after_attack_passTurn`), and a few hypotheses `¬ Settled` became `¬ Calm` (Known gaps of
`Pokemon/Rules.lean`; witnesses in `Pokemon/Benched.lean`). Milestone M5 added Stadiums
and Pokémon Tools: `Move.stadium` plays a Stadium from the hand into the slot both players share
(one per turn, `GameState.stadiumPlayed`; not while a Stadium of the same name is in play; the
Stadium it replaces goes to its owner's discard pile, whoever plays the new one), and
`Move.stadiumUse` lets the player to move use the effect of the Stadium in play once in their turn
("Once during each player's turn, that player may …", `GameState.stadiumUsed`, cleared at the end
of the turn and when a Stadium is played; the effect resolves as a Trainer's, `TRun`). A Tool
(`Card.tool`) is attached from the hand to a Pokémon with no Tool (`Move.tool`, `Move.toolBench`;
any number per turn; it stays attached and goes to the discard pile with its Pokémon) and may give
that Pokémon attacks and activated Abilities, for a holder passing a filter (`ToolGrant`,
`InPlay.attacks`, `InPlay.abilities`; Core Memory's attack for Mega Zygarde ex). Two primitives
discard a Stadium in play (`Effect.discardStadium`) and the Tools of a Pokémon
(`Effect.discardTools`). Triggered Stadium and Tool text, and static text outside the language of
milestone M6 (Bench size, locks, prevention, cost changes; HP, damage and Retreat Cost changes are
expressed since M6, below), is not modelled: such a card is played as a card with no effect
(`Card.inert`), which under-models it; the kinds and their counts
in today's Standard are in the Known gaps. Of the 37 distinct Standard Stadiums, 4 are expressed
with their effect (Academy at Night, Levincia, Prism Tower; Spikemuth Gym since milestone MV4), 8 have
an activated effect the model cannot express exactly, and 25 are static or triggered; of the 45 Tools, 1 is expressed (Core
Memory), 2 grant attacks the model cannot express exactly, 41 are static (22), triggered (18) or change
nothing in the model (Backtrack Badge), and 1 record (Adventure Lantern me6-90) is unclassified.
Milestone MV2 (effect vocabulary 2; census in survey S13) added three families of card text. Tests
and counts on cards in play: `Test.top` (the printed card of either Active Pokémon passes a filter:
"is a Pokémon ex", "is an Evolution Pokémon", "is a Stage 2 Pokémon", "is a Tera Pokémon"),
`Test.hasTool`, the filters `Filter.ex`, `Filter.tera`, `Filter.hasAttack` and `Filter.hasAbility`,
and `Count.inPlay` (Pokémon in play passing a filter); both clamps keep them, since they read
printed cards (`Pokemon/InPlayTests.lean`). Spread: the primitive `Effect.benchSome` (damage or
counters on `m` distinct Benched Pokémon passing a filter, all of them if fewer pass; semantics
`Hits`) and the derived forms `Effect.rep`, `Effect.spreadAny` ("put 6 damage counters on your
opponent's Benched Pokémon in any way you like"; on "your opponent's Pokémon", each counter goes on
the Active Pokémon when the Bench is empty; proved exact for the resolution of an attack's effect
from a state with both Active Pokémon: every distribution of the counters is a resolution, and every
resolution is one and changes nothing else, `Spread.spreadAny_sound`, `Spread.spreadAny_complete`),
`Effect.hitSome` ("120 damage to
2 of your opponent's Pokémon") and `Effect.countersSome`; both clamps simulate it (`Hits.transfer`),
and one spread can Knock Out two Benched Pokémon in one batch (`Pokemon/Spread.lean`). One-turn
history: a per-player Knock Out record (`KOHist`: this turn and the last, any Knock Out and one by
the check after an attack; set by the batch check outside Checkup, shifted by `Move.endTurn`), read
by `Count.koLast` ("if any of your Pokémon were Knocked Out by damage from an attack during your
opponent's last turn"); a per-Pokémon flag `InPlay.movedUp` (set by a retreat and by `switch .own`,
cleared at the end of its owner's turn), read by `Test.movedUp`; and `Test.evolved`, which reads
`fresh` and the cards under the top card and needs no new state. The record is flags only, 16
values per player and 2 per Pokémon, and nothing is counted, so every finiteness theorem holds with
the enumerations extended and no new hypothesis (`Pokemon/History.lean`: a history test false and
then true across a turn boundary). No theorem statement changed in text except those that spell out
a changed definition: the internal `Counter.Fits.toCur`, `Counter.Fits.toOpp` (the record update of
`Move.endTurn` gained `ko := s.ko.shift`), and the witness states `Trainer.after1`, `after2`,
`after3` and `StaticWitness.tg2`, whose Knock Outs now leave a record. Not expressible: the played
Supporter's name this turn, attacks used last turn and per-Pokémon attack locks, healing this turn,
spread amounts computed by the text, name-prefix filters (Known gaps).
Milestone MV3 (effect vocabulary 3; census in survey S15) added, in stage 1, damage steps that
ignore steps of the damage calculation: `Effect.damage a ig` carries a flag record `Ign` (Weakness,
Resistance, effects on the defender), and the damage is `GameState.dealtI ig n`, the rulebook's
calculation with step 3, 4 or 5 switched off (2026 rulebook p. 20; step 2, the attacker's own
bonuses, is kept); `damage a` is `damage a {}`, the full calculation (`GameState.dealtI_none`). Five
printed variants, 39 refused Standard cards. Both clamps keep it with no new hypothesis
(`dealtBy_cap_ign`); witnesses in `Pokemon/Ignore.lean` (one defender, Resistance and a reduction:
1 damage counter from the plain attack, 6 from the one that ignores them). Stage 2 added "if you do"
and "for each … in this way" as derived forms that read the branch a resolution took, with no log
and no new state (`Pokemon/IfDo.lean`): `Effect.mayDo`, `Effect.ifDone` and `Effect.forUpTo`, each
with a characterisation (`Run.mayDo_iff`, `Run.ifDone_iff`, `Run.forUpTo_iff`, and `TRun.mayDo_iff`,
`TRun.ifDone_iff`, `TRun.forUpTo_iff`). Their exactness is conditional on the action A: `mayDo` only
if no resolution of A does nothing (`Run.mayDo_exact`), `ifDone` only if its test holds exactly
when A has a resolution (`Run.ifDone_exact`), `forUpTo` for "any amount" only once the bound covers
what can be taken (`Run.forUpTo_complete`); these are proved for "discard N cards from your hand"
and "discard N Energy from this Pokémon" (`Run.ifDone_discardHand`, `Run.ifDone_discardActive`,
`Run.discardHand_ne`, `Run.discardActive_ne`, `Run.forUpTo_discardActive`), and are otherwise the
importer's to respect (Known gaps); witnesses: Klefki's "Discard a card from your hand.
If you do, draw 2 cards" as a legal attack that draws, and from an empty hand one that, on every
resolution, changes nothing. Stage 3 added static damage prevention by a filter on the attacker
(`SEff.prevent`: "Prevent all damage done to this Pokémon by attacks from your opponent's Pokémon ex"),
read at step 5 with the defender's other effects and never stored (`GameState.sPrevent`); an attack
whose damage ignores effects on the defender is not prevented, and prevented damage fires no
`damaged` trigger (`Pokemon/Prevent.lean`: `prevented_quiet` on every resolution, `pierce_fires`
for the same defender against `Ign.fx`). Lingering prevention stays per player (`Mod.prevent`).
Changed definitions: `Effect.damage` (a second field, defaulted), `Run.damage`, `HitAt.damage`,
`SEff` (a constructor), `GameState.dealt` (0 under static prevention); new `GameState.dealtI`,
`GameState.sPrevent`. Every theorem statement is unchanged in text; `GameState.dealt_zero` is now
proved by cases instead of `rfl`. The prevention protects the Active Pokémon only: Bench damage reads
no static effect, so a Benched Pokémon with such an Ability takes Bench damage that print prevents
(Known gaps). A review and a check against the 2026 rulebook (survey S14) then changed two
definitions: `Move.retreat` discards any sub-multiset of the attached Energy (`Split .any`, the
player's choice, 2026 p. 12; before, only the most recently attached), which changes the stated
premise of `Move.retreat_marks` and `Move.retreat_movedUp`; and `Effect.trigOk` excludes Paralysis
(a trigger Paralyzes in the attacker's owner's turn, where print keeps it Paralyzed through that
owner's next turn and the model would cure it at once). The Known gaps were updated against the
2026 rulebook (tiebreaker game, "up to", deck construction, Legendary Stadiums, effects ending on
evolution, `putBench .opp` and evolution).
Milestone MV4 (effect vocabulary 4; census in survey S17) added, in stage 1, two filters on the
printed name, `Filter.namePrefix` ("Iono's Pokémon" is `and pokemon (namePrefix "Iono's ")`) and
`Filter.nameHas` ("a Pokémon that has \"Nidoking\" in its name"), which compare the UTF-8 bytes of
the names (`nameBytes`; `String.startsWith` depends on `Classical.choice` in this Lean version), so
`Filter.eval` stays a kernel-computable `Bool`; and five counts (`Count`, now 12 constructors):
Pokémon Tools attached to a player's Pokémon (`tools`), Special Conditions on an Active Pokémon
(`conds`), Prize cards a player has taken (`prizesTaken`, 6 less those left: exact for games set up
with 6 Prize cards, rulebook 2026 p. 8), types of Basic Energy attached (`energyTypes`) and the
turn's Supporter flag (`supporter`). None reads damage, so both clamps keep them exactly and
`Count.val_clampAt`, `Count.val_xclampAt` gained one case each; counts of damage counters on several
Pokémon are left out (not clamp-exact; S17 §B). Witnesses in `Pokemon/Vocab4.lean` (attacks whose
damage is computed from a Tool count, a Special Condition count and a Prize count, as legal moves).
Stage 2 added per-Pokémon attack locks (S17 §C: "During your next turn, this Pokémon can't use
[this attack]", 27 refused Standard cards; "… can't use attacks"): `Attack.selfLock` (`AtkLock`:
none, this attack, all attacks; a defaulted field, so the generated library builds unchanged) and
`InPlay.lk` (`LockState`: the lock set this turn and the lock in force, nine values per Pokémon (sixteen since milestone MV6's `AtkLock.note`), in
the enumeration `Enum.lockStates`, kept exactly by both clamps). `Move.attack` sets the attacker's
lock (its result is now `GameState.afterAttack`), `InPlay.unfresh` brings it into force at the end
of its owner's turn and ends it a turn later, `Move.attack` and `Move.attackConfused` refuse an
attack the lock forbids, and moving to the Bench (`Move.retreat`, `Effect.switch` through
`InPlay.unlock`) or evolving clears it (rulebook 2026 p. 20, p. 11). Witnesses in
`Pokemon/Lock.lean`: from a well-formed, `Settled` start, Giant Wave is used, every attack in its
user's next turn is the other one (`g3_no_wave`, over all moves), a retreat in that turn clears the
lock, and two turns later Giant Wave is legal again (`trace`). Changed definitions: `InPlay` (field
`lk`), `Attack` (field `selfLock`), `InPlay.unfresh`, `InPlay.Agree` (field `lk`), `Move.attack`,
`Move.attackConfused`, `Move.retreat`, `Move.evolve`, `Move.evolveBench`, `PlayFromHand`, `Run.switch`,
`Enum.inPlays`, and internal ones (`Counter.Fits` gained the conjunct that the Active Pokémon carries
no lock, so `Counter.Encodes` requires it; `Counter.onPlay`, `StoreSafe` `atkRes`). Changed statements,
each spelling out a changed definition: `Move.attack_of_trigFree` (premise `hlk`, conclusion
`afterAttack`), `Counter.move_shape` (its attack disjunct is `afterAttack`) and `Counter.attack_move`
(premise `atk.selfLock = .none`). No other theorem statement changed in text; `Counter.universal`,
`Counter.simulate`, `Counter.halts_of_haltMarked` are unchanged. The per-player `Mod.lock .attack`
stays; "if this Pokémon used [attack] during your last turn", the named Supporter of the turn and
Paralysis timing per Pokémon are not modelled (Known gaps; S17 §E).
Milestone MV5 (survey S18) made Special Energy a card kind, the cheapest step of the Poet's idea B
(S18 §A): `Card.energy` takes an `EnergyCard`, Basic (`basic t`) or Special (`special name prov`:
the printed name and a fixed list of provided units, each of one or several types), and
`EnergyCard.fire` and the like abbreviate `basic .fire`, so the generated `.energy .fire` and every
existing match on `.energy _` are unchanged (a defaulted flag would not do: a Lean pattern fills in an
omitted default, which would have narrowed every such match to Basic Energy; a new `Card`
constructor would have broken `PokemonCards/Props.lean`). Two filters, `Filter.basicEnergy` and
`Filter.specialEnergy` (`Filter`, now 24 constructors; `Filter.energy` passes both kinds,
`Filter.energyOf` Basic Energy only), and the name filters read a Special Energy card's name. A
Special Energy card is attached, pays costs (`Card.provides`, `Pays`), is discarded and counted as
any Energy card. Nothing else of its text is modelled (riders, holder-dependent provision, holder
restrictions, deck construction), so every Special Energy card is `Card.inert`; of the 19 in today's
Standard none is exact, and an importer must refuse them or caveat them. What becomes expressible is
text that mentions Special Energy (22 refused cards, S18 §A1), exact as far as this construct goes
for decks with no Special Energy card. Witnesses in `Pokemon/Special.lean`. Changed definitions:
`Card` (`energy` takes `EnergyCard`), `Card.provides` (through `EnergyCard.units`), `Card.name?`,
`Card.inert`, `Filter`, `Filter.eval`, `energyTypeCount` (spelled `Card.energy (.basic t)`).
No theorem statement changed in text; `Move.attach`, `Move.attachBench`, `ZStep.attachActive` and
`ZStep.attachBench` now range over Special Energy too (their `t` is an `EnergyCard`). The
measurement for idea A (attachments as one kind) found 3 to 4 of the 19 riders expressible by an
existing mechanism (S18 §A3), so the generalisation was not made.
Milestone MV6 (effect vocabulary 6; census in survey S19) added, in stage 1, a window primitive:
`Effect.look w src f q i rest` takes a whole window of the `w` player's zones off its source at once
(the top `n` cards of the deck as they are when the effect starts, since MV6 also the bottom `n`,
`Src.bottom`; or a whole deck, hand or discard pile), takes cards passing `f`, as many as `q` says
(new: `Qty.most n`, "`n`, or all that pass if fewer": "Discard a card you find there"), puts the
other cards at `rest` (the hand, the discard pile, the top or bottom of the deck in any order, or
shuffled in) and places the taken cards (`Into`: a zone, onto the Bench, or attached to the player's
Pokémon "in any way you like"). "Look at the top 6 cards of your deck, reveal an Energy card you find
there, and put it into your hand. Shuffle the other cards and put them on the bottom of your deck"
(Delibird me6-79) is `look .own (.top 6) .energy (.most 1) (.put .hand) .bottom`. With no hidden
information in the model and a shuffle read as any permutation, it is exact: every resolution
partitions the window as it was when the effect started and every partition is a resolution
(`ZStep.look_window`, `ZStep.look_complete`, `Pokemon/Look.lean`); unlike one-card primitives on
`.top n`, which read a window that moves down as cards are taken (`moving_window`, `fixed_window`).
The derived form "take … into your hand, shuffle the other cards back" of milestone MV is proved
equal to it (`Run.look_hand_shuffle_iff`). A window is a zone step (`ZStep.look`), so both clamps
keep it with no new hypothesis (`Place.sim`, `Deal.sim`), it permutes the cards (`ZStep.count`), and
a window on a discard pile is a recycler for clause 3 of `StoreSafe` (`Effect.recFilters`).
Witnesses: attacks of Delibird's, Reuniclus's and Metang's shapes as legal moves. Changed
definitions: `Src`, `Qty`, `Effect` (a constructor each), `Src.get`, `Src.set`, `Qty.ok`,
`Effect.zSide`, `Effect.ownFree`, `Effect.recFilters`, `ZStep` (a constructor); new `Into`,
`Place`, `Deal`. No theorem statement changed in text.
Stage 2 (S19 §B) added the defender modifiers outside steps 2 and 5. Two new stored amounts, per
player like every lingering modifier: `Mod.weaken n` ("During your opponent's next turn, attacks used
by the Defending Pokémon do 30 less damage (before applying Weakness and Resistance)", 11 refused
Standard cards; `Mods.minus`, subtracted at step 2) and `Mod.expose n` ("During your next turn, the
Defending Pokémon takes 50 more damage from attacks (after applying Weakness and Resistance)", 4;
`Mods.more`, added at step 5 before the reduction). `dealtBy` reads them (at this stage it stopped
when the damage after step 2 was 0; since then the stop test is on the base damage alone, as the
rulebook defines it, 2026 p. 20, so a penalty that cancels an attack's damage leaves a step-5
increase in force: `Defender.weaken_then_expose`, `Defender.cancelled_exposed`). They
are amounts (`Mod.isAmt`, `Mods.amt`), so `StoreSafe`'s five clauses govern their writers with no
change to the clauses' text, and the store bound, `BoundedStores` (`Enum.ModsLe`) and the
enumerations cover them; `LoopFreeNeeded.iter_weaken_breaks_bound` is the negative theorem for clause
1's reading of the new kind. The exact-store clamp keeps them; the capped clamp caps them at `2 · k`,
and tame decks may not write them (`Mod.plain`; `Store.NoReduce` now asks for no reduction, penalty
or increase, and `dealtBy_cap`, `dealtBy_cap_reduce`, `dealtBy_cap_ign` gained the premise that the
attacker's store has none). "During your next turn, this Pokémon's [attack] does 60 more damage" (5)
needs no store: the attack records its use on its Pokémon (`AtkLock.note`, in the MV4 lock state, now
sixteen values per Pokémon) and the named attack tests it (`Test.usedLast`), per Pokémon and exact.
Witnesses in `Pokemon/Defender.lean`. Changed definitions: `Mod`, `AtkLock`, `Test` (a constructor
each), `Mods` (fields `minus`, `more`), `Mods.empty`, `Mods.merge`, `Mods.addMod`, `dealtBy`,
`Mods.cap`, `Store.NoReduce` (now per slot `Mods.NoReduce`), `Effect.tame` (`Mod.plain`), `Mod.amt`,
`Mod.isAmt`, `Mods.amt`, `Enum.modss`, `Enum.ModsLe`, `Enum.atkLocks`, `Test.eval`, `Test.whose`,
`Test.onOwn`, `AtkLock.allows`. Changed statements, each spelling out a changed definition or adding
the premise the new kinds need: `Mods.cap_iff` (two conjuncts), `Store.NoReduce.add` (premise
`m.plain = true` for `∀ n, m ≠ .reduce n`), `dealtBy_of_noReduce`, `dealtBy_cap`,
`dealtBy_cap_reduce`, `dealtBy_cap_ign` (premise: the attacker's store `NoReduce`),
`dealtBy_le_empty` and `GameState.dealt_le_dealtI` (premise: no step-5 increase in effect on the
defender; switching off "effects on your opponent's Active Pokémon" removes an increase, so without
it the old statements are false). Weakness changes ("has no Weakness", 3) are left out (a stored
value with an order, not an amount). `Counter.universal`, `Counter.simulate`,
`Counter.halts_of_haltMarked` and `Counter.Encodes` are unchanged in text (the encoded stores fix the
new fields at 0).
Stage 3 (S19 §C) added counts that read no damage: `Amt.heads a k` ("Flip a coin for each Energy
attached to this Pokémon. This attack does 80 damage for each heads": `k` times any number of heads
up to the value of `a`, `Amt.Val.heads_iff`; 7 refused cards, and "reveal any number … for each card
revealed"), counts over the top or bottom `n` cards of a deck (`Pile.top`, `Pile.bottom`: Bug Out,
"reveal the bottom 7 cards … for each Pokémon you find there"), and the printed Retreat Cost of an
Active Pokémon (`Count.retreat`, 7 cards; printed, not derived: a listed departure when a static
effect changes it). Both clamps keep them, so `Count.val_clampAt`, `Count.val_xclampAt`,
`Amt.Val.congr` and `Amt.Val.transfer` gained a case each with unchanged statements. Left out, with
the argument in S19 §C: sums of damage over several Pokémon (not kept by either clamp: the sum of
capped values is not the capped sum, and under the in-attack clamp a capped excess on the opponent's
Bench would reach the Active Pokémon's damage through Resistance) and the number of Pokémon with
damage counters (exact at every cap of at least 1, but the count theorems hold at the cap 0 too).
Witnesses in `Pokemon/Coins.lean` (Work Rush does 0, 80 or 160 with two Energy and nothing else;
String Bind against a Retreat Cost of 1; Bug Out as one attack: a count over the bottom 2 cards, then
a window that shuffles the counted Pokémon back and discards the rest). Changed definitions: `Amt`,
`Pile`, `Count` (constructors), `Amt.Val`, `Pile.get`, `Count.val`, `Test.onOwn`.
Witnesses: `Pokemon/Stadiums.lean` (Levincia played and used by the first player, refused a
second time in the turn, used by the second player in their turn, replaced by Academy at Night,
which goes to the first player's discard pile, and the new Stadium used in the same turn; the
same-name ban) and `Pokemon/Tools.lean` (a Tool on a Benched Pokémon discarded with it on a Knock
Out; a second Tool refused; an attack given by a Tool to its holder only; Tools discarded by an
effect). Milestone M6 added effects that hold while a card is in play: a static effect (`Static`:
an HP change, a constant or a constant per Energy attached; a damage bonus with a filter on the
defender; a damage reduction with a filter on the attacker; a Retreat Cost change) applies to the
source Pokémon itself, to its owner's Pokémon, to the opponent's, or to all, with conditions on the
affected Pokémon (a card filter, its place, an Energy count) and on the source's place; static
Abilities (`AbilityUse.static`), Tools (`ToolGrant.statics`) and Stadiums (the `statics` of
`Card.trainer`) carry them, and they are in force exactly while their source is in play. The
quantities they change are computed from the state, never stored (`Pokemon/Static.lean`): derived
HP (`GameState.hpOf`), the static bonus and reduction, which enter the damage calculation at steps
2 and 5 (`GameState.dealt`), and the Retreat Cost (`GameState.retreatOf`). Every Knock Out premise
reads derived HP, so HP that drops when a source leaves play (a Tool discarded, a Stadium replaced,
Energy removed, a Pokémon with a static Ability Knocked Out) is followed by the Knock Out the model
already takes (between moves, `Settled`; in mid-effect, `Resolve`); the rulebook says nothing about
damage when HP drops, and the counters stay. Derived HP of every Pokémon in play is at most
`hpBound` of the cards of the game (`GameState.hpOf_le_hpBound`: every amount is a constant times a
count of cards), and the clamps now cap damage and Poison strength at that bound instead of at the
printed HP. Witnesses in `Pokemon/StaticWitness.lean` (a Pokémon surviving above its printed HP on
a Tool and Knocked Out when the Tool is discarded; a Stadium replacement Knocking Out a Benched
Pokémon; an Energy-scaled HP bonus raising HP in mid-effect; two Knock Outs in a chain from one
removal, by two batches; a static reduction applied after Weakness; and, as a recorded modelling
decision, the outcome decided at the end of each round of the repeated check, so that a Pokémon
doomed only by another's removal is not counted in the round that ends the game,
`StaticWitness.outcome_per_round`). With derived HP the order of
one-at-a-time Knock Outs changed outcomes, a departure from the rulebook recorded at milestone M6;
the batch Knock Out step removed it: a Benched Pokémon at its HP can no longer be promoted and
survive, and two Pokémon that lower each other's HP are Knocked Out together, on every line of play
(`StaticWitness.guard_knocked_out`, `StaticWitness.double_knockOut_taken`; the old departure
statements are now false, `StaticWitness.promotion_rescues_false`,
`StaticWitness.double_knockOut_lost_false`); for decks without static effects every derived
quantity is the printed one (`Pokemon/NoStatics.lean`). Not expressible: circular HP (Ditto copying
HP; an HP bonus keyed to a Retreat Cost keyed to the remaining HP), "set" HP and its order against
"+", stacking rules, Bench size, locks and prevention (static prevention by a filter on the attacker
came with milestone MV3), cost changes and every triggered effect
(Known gaps). For that model it proves:

* play permutes the cards in the game (`Reach.perm`), Knock Outs inside Trainer effects
  and zone moves included (`TRun.perm`, `ZStep.perm`);
* Knock Out timing inside Trainer effects (`TRun.guarded`, `TRun.iff_guarded`): from a
  `Settled` state, as every Item and Supporter starts, every primitive step and every test of
  the effect starts in a `Settled` state, so no step runs while a Pokémon is at or above its
  HP; the effect ends `Settled` or with the game over (`TRun.settled_or_won`), and a finished
  game resolves nothing more (`TRun.of_won`). Single legal moves from well-formed starts
  witness behaviours the earlier model lacked: an Item `seq (selfDamage 5)
  (heal 5)` Knocks Out its player's 50-HP Active Pokémon after the first step
  (`Trainer.selfKO_reachable`); an Item `iter (counters 5)`, read as "as often as you like,
  put 5 damage counters on the opponent's Active Pokémon", Knocks Out the opponent's Active
  Pokémon, the opponent promotes, and the next round hits the new Active Pokémon
  (`Trainer.koThenHit_reachable`; read instead as "flip until tails, 5 counters per heads",
  this outcome is a consequence of the model's check between primitives, not rulebook
  behaviour, since the printed card places all its counters at once); an Item takes the last Prize card in mid-effect and the
  rest of it is not resolved (`Trainer.winMidEffect_reachable`);
* from a well-formed start (`WellFormed`: both players have Prizes while there is no winner;
  Benched Pokémon have no Special Condition; since M3 a Benched Pokémon may be at or above its HP,
  which is a pending Knock Out, and `Settled` excludes it before every move but the batch Knock
  Out step), no reachable state without a winner is stuck (`Reach.progress`; since milestone
  batch-KO no state at all is, `Move.exists_move`), and if a Knock Out is pending the batch Knock
  Out step is legal: it Knocks Out every Pokémon in play (Active or Benched, of either player) at
  or above its HP at once, each player's Prize list loses its top cards, as many as the Prize value
  of the opponent's Knocked Out Pokémon (or all that are left), and every Pokémon in play
  afterwards was below its HP in the state before the step (`Reach.knockOut_of_pending`; a
  survivor can be at its HP afterwards, when a removal or promotion lowered it, and then the check
  repeats). Milestone batch-KO restated it: the earlier statement named the one Pokémon Knocked
  Out and left the other player's Prize list unchanged; the new one names no Pokémon and gives
  both Prize lists, each with its top cards dropped. A move from a state with an Active Pokémon
  at or above its HP is the batch step, which Knocks it Out (`Move.pending_knockedOut`, formerly
  `Move.pending_untouched`; restated by batch-KO: the same move may now fill the Active Spot again
  by a promotion);
* the repeated check with its triggers ends (milestone M8b, `KOMove.acc`, `Move.unsettled_acc`: no
  infinite sequence of moves through states that are not `Settled`, by the pending-trigger record
  (milestone MV7: no trigger sets it again), the Prize cards left and then the measure below);
* the repeated check ends (`Pokemon/Terminate.lean`): a batch that does not end the game lowers
  twice the number of Pokémon in play plus the number of empty Active Spots
  (`KOBatch.koMeasure_lt`), so every chain of batches is finite (`KOBatch.acc`), every state has a
  `Resolve` result, `Settled` or with an outcome (`Resolve.exists`), and `Resolve` from a state with
  no pending trigger takes at most that measure plus one batches (`Resolve.chain_le`);
* **finiteness, for tame decks** (`Reach.finite`): let the clamp cap at `bound` the
  damage and the Poison strength on every Pokémon in play (both Active Pokémon and, since M3,
  every Benched Pokémon, whose damage effects can now raise past HP), and cap every damage bonus and
  reduction at `2 · bound` (`bound` is a constant computed from the cards: more than every
  HP a Pokémon can have (`hpBound`, since milestone M6, when HP became derived; before it the clamp
  capped at the printed HP), every Resistance plus the bound `sReduceBound` on static damage
  reductions (M6), and every test constant; the factor 2 absorbs Resistance, which is
  subtracted after the bonus, `dealtBy_cap`; Weakness, which doubles, needs no larger cap). From any start (well-formed or not) whose cards are *tame* (no stored damage reduction (since milestone MV6 also no step-2 penalty or step-5 increase), no
  `drain`; static reductions are allowed) and with no reduction stored (`GameState.Fit` at
  `bound`, which `GameState.fit_bound` gives from those two hypotheses alone), the clamps of all reachable states lie in one finite list, and
  the kernel of the clamp is a bisimulation for moves along reachable states (`Move.clamp_sim`,
  `Reach.clamp_sim`), so the excesses the clamp removes cannot be observed by play. This holds
  with the Trainer timing above. The list half alone (`Reach.clamp_mem`) holds from every
  start, but without tameness it says nothing about play: for every cap `k ≥ 3`
  there is a deck with a damage reduction for which the clamp is not a simulation
  (`Lingering.reduce_breaks_clamp`), and for every cap `k ≥ 2` a deck with `drain`
  (`Lingering.drain_breaks_clamp`); with rest-of-game modifiers, a reduction on one player and a
  bonus on the other are two persistent unbounded counters with an exact zero test, and the
  model then simulates two-counter machines (next item).
* **universality, for the generalisation** (`Counter.universal`, `Pokemon/Counter.lean`):
  generalised beyond printed cards so that rest-of-game damage bonuses and reductions
  accumulate without limit and can be granted by an ordinary attack every turn, the model
  admits, for every two-counter machine `M`, a well-formed game state from which a designated
  marker is reachable under legal play by both players if and only if `M` halts; with Minsky's
  theorem, reachability in this generalised model is undecidable (the reduction is
  machine-checked, the appeal to Minsky's theorem is not), and nothing follows for the printed
  card pool. The start `start M a b` uses cards in the existing effect language; neither of its
  attacks is a GX attack, so the once-per-game GX rule (next item) does not restrict them; every configuration `M` reaches is encoded by a reachable state
  (`Counter.simulate`, whose proof uses six fixed moves per machine step) (since milestone M8b `Encodes` also asks that no card of the game have a triggered Ability, which the start satisfies, since an attached Tool could otherwise fire a mandatory trigger; since milestone MV7 `Encodes` asks, through `Counter.Shape`, that no trigger be pending, which no move of the construction changes), and the converse
  direction (`Counter.halts_of_haltMarked`) covers every line of play, not only the intended
  one (a player who declines to attack, or attaches the Energy, decks out at their next draw,
  and the game ends without the mark). The construction relies on: (1) rest-of-game damage
  bonuses and reductions that add up without limit and are placed by an attack used every
  turn, including an attack that grants the *opponent* a reduction (printed cards give
  rest-of-game modifiers only through once-per-game attacks, survey S7 §C); (2) `damage` read
  by a test later in the same attack, using the model's freedom to order primitives; (3) a
  printed HP that grows with the machine; (4) a halt mark placed on the player's own Pokémon,
  whereas printed markers target the opponent (this affects only the observable); (5) a
  hand-built start (an Active Pokémon and one Energy each, one Prize, no set-up), not shown
  reachable from a legal set-up, with padding to legal deck size not proved harmless; and (6)
  `ite`, `healAll`, `selfDamage`, `counters`, `mark` and `handToBottom` as general primitives
  combined in one attack. It does not rely on an attack not ending the turn (each player
  attacks once and the turn ends; re-checked under the rule that an attack ends the turn), on a
  bonus being added to base damage 0 (the zero test is the damage step `damage (const 1)`, with
  base damage 1), on attack costs being counted rather than typed (costs are typed and empty),
  on modifiers being per player rather than per Pokémon (one Pokémon each, no Bench), or on the
  absence of Weakness and Resistance (the Clock and the Tape have neither, and each attack makes
  the damage calculation at most once; re-checked under milestone M4).
  Separately, `Counter.not_finite_up_to` shows that for one witness deck the reachable states
  are not finite up to any equivalence fine enough to recover the encoded configuration. That
  is a statement about how states are represented, not about play: its machine never reads its
  counter, so the extra states differ only in a reduction nothing observes, and it is not the
  counterpart of `Reach.finite` (a finite bisimulation quotient). The behavioural counterpart
  is `Counter.universal` with Minsky's theorem (prose), which rules out a uniform computable
  finite abstraction; for any single machine a finite quotient respecting the halt question
  exists, non-constructively.

Markers alone did not change the statements: they are finitely many flags per Pokémon, not
clamped, and enumerated by the list of `Reach.clamp_mem`. Printed Imprison and Shock-wave markers are uncapped counts; a flag
is exact for them because the cards only place one, remove all, and test for any
(`Markers.flag_exact`), and this is a stated assumption about the card pool.

Lingering modifiers change the statements: the clamp takes a cap `k`, and the bisimulation needs
a hypothesis on the deck (tameness, `GameState.Fit`). An unbounded damage bonus can be capped because it is read only through
the damage it adds to the opponent's Active Pokémon, which is read only by tests against card
constants and by the Knock Out test at HP; a bonus of `2 · bound` or more acts as `2 · bound`
does (Weakness doubles the base damage plus bonus, which only raises it; Resistance, at most
`bound`, is what the factor 2 absorbs: with the stores capped at `bound` itself, a bonus of
`bound` and one of `bound + 1` against Resistance 3 do different damage below the cap,
`Calc.cap_at_k_fails`). A damage reduction breaks this: damage done by base damage `n ≥ 1` is
`n + bonus - reduction` without Weakness or Resistance,
and a bonus above any cap matters when an equally large reduction offsets it
(`Lingering.reduce_breaks_clamp`, for every cap `k ≥ 3`; its witness attack has base damage 1,
since base damage 0 does no damage). So does `drain` after in-attack
self-damage, which reads the bonus exactly through the heal (`Lingering.drain_breaks_clamp`, for
every `k ≥ 2`). Expiry follows the turn structure:
`endTurn` shifts both stores, and `Store.add_now_shift` .. `Store.add_always_shift` state when
each kind of modifier is in effect. Printed rest-of-game bonuses and reductions come only from
once-per-game attacks (survey S7), and same-turn ones are bounded by copies of their cards times
printed constants provided no recycling replays them within a turn; since milestone MV this is
clause 3 of `StoreSafe` (`RecycleSafe`), a decidable hypothesis on the two decks together. Survey
S10 found no Item or Supporter card in today's Standard pool whose discard-pile filter admits a
modifier-writing Item, and no rest-of-game Trainer writer there, so the model's
encodings of those Trainers and attacks satisfy clause 3 for every pairing of decks (a reading
of the card pool, not a theorem; static text outside the language of `Static` (milestone M6), triggered
text and returns from play are outside the model, so this does not say Standard decks are covered). A reduction carried into the opponent's turn does exist on a printed Item (Iron
Defender: "During your opponent's next turn, all of your Metal Pokémon take 30 less
damage…"), so printed decks are not all tame. The model over-approximates modifiers on purpose;
`Reach.finite` covers only the tame decks, and `StoreSafe.xfinite` (next paragraph) covers decks
with reductions such as Iron Defender's.

Exact stores. Both clamp counterexamples reach two states whose stores differ only above the
cap. The clamp `GameState.xclamp K` (`Pokemon/Exact.lean`) caps damage and Poison strength on
every Pokémon in play at `K` (since milestone M6 a parameter, taken to be `Enum.bound` of the cards,
which bounds every derived HP; before it the cap was the printed HP) and keeps both stores exact, so those states are not identified. Every
reader of the stores sees equal values in two states with equal `xclamp`: the damage step
computes the same `dealtBy` (the same amount, Weakness, Resistance and stores; `drain` heals the
attacker by that amount), locks and prevention are flags in the stores, and `endTurn` shifts
equal stores; damage is read by tests, by `scale`, by the damage step's amount, by Checkup only
in states with no pending Knock Out, and by the Knock Out test at HP. Inside an attack damage is
kept exact on every Pokémon in play (every attack starts with no pending Knock Out, where `xclamp`
determines the damage; before milestone M4 the opponent's was capped, which a damage step that
reads it and `drain` that writes the amount to the attacker would break); damage done needs no
cap, however large in either direction, since it is computed from equal values. What the exact clamp gives up is boundedness of the stores, and with it
finiteness; the deck condition `StoreSafe` buys it back:

* **exact-store bisimulation, every deck** (`Move.xclamp_sim`, `Reach.xclamp_bisim`,
  `GameState.xclamp_bisim`): the kernel of `xclamp` is a two-way bisimulation, with no
  hypothesis on the cards; it holds for all pairs of states with equal `xclamp`, reachable or
  not (the reachability premise of `Reach.xclamp_bisim` is vacuous: take the start to be the
  state itself);
* **finiteness on bounded stores** (`Reach.xfinite_bounded`, `Pokemon/Bounded.lean`): from
  any start, for every `B` one finite list (depending only on the start and `B`)
  contains the `xclamp` of every reachable state satisfying `BoundedStores B` (every slot's
  bonus and reduction, and since milestone MV6 step-2 penalty and step-5 increase, at most `B`). The bounded part is not closed under moves, so on its own
  this gives a finite set of classes and a bisimulation that may leave that set, not a finite
  quotient; the finite quotient is `StoreSafe.xfinite`;
* **finiteness for store-safe decks** (`StoreSafe.xfinite`, `Pokemon/StoreSafe/Invariant.lean`, imported by `Pokemon/StoreSafe.lean`): a start is
  `StoreSafe` if no card's effect has a damage bonus or reduction under `iter` (`LoopFree`), only
  GX attacks write rest-of-game bonuses or reductions (`GXOnly`), and, since milestone MV, no
  Item or Supporter effect can return from a discard pile an Item card that writes a bonus or
  reduction, and no effect at all an Item or Supporter card that writes a rest-of-game amount
  (`RecycleSafe`, decidable; a Stadium's once-per-turn effect is not restricted this way, and is
  paid for per use;
  attacks may recycle every other card, because an attack ends the turn; every deck with no
  recycling satisfies it, so for such decks `StoreSafe` means what it meant before), and, since
  milestone M8a, clauses 1 and 3 read Abilities too ("as often as you like" Abilities count with
  Trainer effects in clause 3 (a)) and a fourth clause holds: no "as often as you like" Ability writes
  a bonus or reduction and no Ability a rest-of-game one (`AbilitySafe`, decidable; every deck without
  Abilities satisfies it), and, since milestone M5, a fifth: no Stadium's effect writes a
  rest-of-game bonus or reduction (`StadiumSafe`, decidable; every deck without Stadiums satisfies
  it); milestone M5 also weakened clause 3 for Stadiums (a Stadium card is not a protected writer,
  and its effect is not a free recycler: its uses are bounded per turn), and for a deck without
  Stadiums clauses 3 and 5 are what they were (`Pokemon/NoStadiums.lean`). Then every reachable
  state satisfies `BoundedStores (storeBound g₀)`
  (`StoreSafe.reach_boundedStores`), where `storeBound` adds the start stores, six times the Trainer
  amounts of the cards, three times `Q · potBound |C|` for Abilities (`Q` what one bounded Ability use
  can write and recycle, 0 for a deck without Abilities), six times `cardsStQ` for Stadium effects
  (at most two uses a turn, each writing and recycling at most `cardsStQ`, 0 for a deck without
  Stadiums) and three times the largest amount of one attack; so from any store-safe start (well-formed or not) the `xclamp`s of all reachable states lie
  in one finite list, with the two-way bisimulation. Once-per-turn and on-play Abilities may write
  modifiers (Feraligatr sv5-41: `Abilities.feraligatr_storeSafe`) and recycle writers
  (`Abilities.once_recycler_storeSafe`): their uses in one turn are bounded by a potential of the
  player's Pokémon in play and the opponent's Prize cards (`GameState.abPot`), which no move of the
  turn raises; this rests on the model having no return of a Pokémon from play to the hand or deck. The bound is per turn:
  within a turn, before its attack, each writer Item is played at most once unless a Stadium use returns it (clause 3) and
  one Supporter at most, so Trainers write at most twice the Trainer amounts in a turn; at most one
  attack is made per turn; carried amounts expire within three turn boundaries; the rest-of-game
  slot holds only amounts of cards in the discard piles that nothing recycles, and of GX attacks.
  Before milestone MV the bound counted each Trainer once per game, because nothing left a discard
  pile; that bound (`storeBoundNR`, with the Trainer amounts once) still holds for decks that recycle
  nothing and (since milestone M8a, a new hypothesis that every deck without Abilities satisfies)
  whose Abilities write nothing, and (since milestone M5, a hypothesis that every deck without
  Stadiums satisfies) whose Stadium effects write nothing
  (`StoreSafe.reach_boundedStores_noRecycle`). Store-safe decks may use damage reduction,
  `drain`, carried bonuses and reductions in attacks and Trainers (Iron Defender), rest-of-game
  modifiers in GX attacks and Trainer cards, and recycling within clause 3 (Energy Retrieval,
  Night Stretcher, Dedenne's "Put a Trainer card from your discard pile into your hand" attack:
  `Recycle.printed_shapes_recycleSafe`);
* **recycling breaks the per-game bound** (`Recycle.recycling_breaks_bound`,
  `Pokemon/Recycle.lean`): a well-formed start satisfying `LoopFree` and `GXOnly` (all of
  `StoreSafe` before milestone MV) but not `RecycleSafe` has reachable states with unbounded stores
  and `xclamp`s in no finite list. Its loop, within one turn and with no attack: play an Item
  modelled on Iron Defender (a carried reduction of 3), play Item A ("put up to 2 Item cards from
  your discard pile into your hand"), which returns Iron Defender and Item B, play Iron Defender,
  play Item B (the same text), which returns Iron Defender and Item A. Each recycler returns the
  other, never itself, and each round costs no card. Survey S10 found no Standard card with this
  shape. Like `xclamp_not_finite`, this is a statement about representation: in the witness
  nothing ever reads the stored reduction (no attack is made), so the unboundedly many states
  are not shown to differ in play. Whether unrestricted recycling could simulate a counter
  machine is open, and nothing here claims either way;
* **unlimited Abilities break the bound** (`Abilities.unlimited_writer_breaks_bound`,
  `Abilities.unlimited_recycler_breaks_bound`, `Pokemon/Abilities.lean`, milestone M8a): a
  well-formed start satisfying clauses 1–3 whose Pokémon has an "as often as you like" Ability that
  writes a carried reduction, and one satisfying clauses 1, 2 and 4 whose "as often as you like"
  Ability returns an Iron Defender-like Item from the discard pile, have reachable states with
  unbounded stores and `xclamp`s in no finite list (statements about representation, as above). No
  Standard Ability has either shape (survey S10). Witnesses: an unlimited Ability used twice in a
  turn (`Abilities.unlimited_twice`), a once-per-turn Ability refused the second time and available
  again in the player's next turn (`Abilities.once_refused`, `Abilities.once_again`), an on-play
  Ability (`Abilities.onPlay_witness`), and the card-neutral loops of survey S10, Mega Venusaur ex's
  Grass Energy and Team Rocket's Orbeetle's damage counter moved to the Bench and back
  (`Abilities.venusaur_loop`, `Abilities.orbeetle_loop`): states reachable from themselves by
  Ability moves, which is why the finiteness theorems are about the state space, not termination;
* **Stadium effects** (`Pokemon/Stadiums.lean`, milestone M5): a well-formed start satisfying
  clauses 1–4 whose Stadium's effect writes a rest-of-game bonus has reachable states with
  unbounded stores and `xclamp`s in no finite list (`Stadiums.stadium_writer_breaks_bound`: both
  players use the Stadium every turn, and the effect also puts the hand on the bottom of the deck,
  without which the draw of each turn would end the game); so clause 5 is needed. A Stadium whose
  effect returns an Iron Defender-like Item from the discard pile every turn, to both players, is
  store-safe (`Stadiums.stadium_recycler_storeSafe`): the Item is replayed at most once per Stadium
  use, and a turn has at most two uses (`GameState.stPot`); the clause 3 of milestone M8a refused
  this deck (`Stadiums.stadium_recycler_not_M8a`). No Standard Stadium's activated ("once during each player's turn") effect writes a lingering modifier; static ones (Postwick, Full Metal Lab, …) are not modelled (see Known gaps);
* **the rule change**: `Attack` has a field `gx`, and `Move.attack` lets a player use a GX
  attack only if they have not used one in the game, and records it (`PlayerState.gxUsed`,
  unused before); `Move.attackConfused` (a Confused Pokémon's failed attempt) has the same
  premise and does not record it (an unverified ruling, listed in the Known gaps of `Pokemon/Rules.lean`). Every earlier
  theorem was re-proved; `Counter.universal` is unchanged;
* **the dichotomy** (`StoreSafe.dichotomy`, `Pokemon/Dichotomy.lean`): the two-counter starts
  satisfy `LoopFree` (`StoreSafe.counter_loopFree`) and `RecycleSafe` (`StoreSafe.counter_recycleSafe`:
  they recycle nothing) and violate `GXOnly` whenever the machine's
  first instruction is not `halt` (`StoreSafe.counter_not_gxOnly`: their attacks, not GX attacks,
  write rest-of-game amounts); for `start countUp 0 0` the `xclamp`s of the reachable states lie
  in no finite list (`StoreSafe.xclamp_not_finite`, a statement about representation, as for
  `Counter.not_finite_up_to`). This is a sharpness result for the `GXOnly` clause, not a
  classification of decks: store-safe decks are finite up to a two-way bisimulation; some decks
  that violate only `GXOnly` (the two-counter starts) simulate every two-counter machine, so
  that clause cannot be dropped from the theorem; nothing is proved about other decks that are
  not store-safe, and some of them are finite (tame decks that violate `GXOnly` are covered by
  `Reach.finite`).

Which theorem applies. `Reach.finite` needs tame cards (no stored damage reduction, step-2 penalty or step-5 increase, no `drain`;
static reductions are allowed) and no reduction stored at the start; it allows bonus writes under `iter` and rest-of-game bonuses
in attacks that are not GX attacks, and recycling of every kind (milestone MV), and gives a
coarser quotient (the clamp caps stored bonuses). `StoreSafe.xfinite` allows damage reduction,
`drain`, carried modifiers and Trainer modifiers; it forbids amounts written under `iter`,
rest-of-game amounts written by attacks that are not GX attacks, and recycling of modifier-writing Items
by Item and Supporter effects and unlimited Abilities (`RecycleSafe`), and gives a finer quotient (the stores are kept exact). Neither class
contains the other; for decks in both, both theorems apply.

Not covered by `StoreSafe`, or not in the model: recycling outside clause 3 (an Item that returns
a modifier-writing Item, as in `Recycle.recycling_breaks_bound`, or an "as often as you like"
Ability that does, `Abilities.unlimited_recycler_breaks_bound`); "as often as you like" Abilities
that write a modifier (outside clause 4); static and triggered Abilities and Stadium effects
(absent); returning a card from play to the hand (absent; with it a Pokémon could re-enter play and
use or trigger its Ability again in the same turn, which the Ability bound does not cover);
"attack twice", "attack again" after a Knock Out, and extra turns (absent: more than
one attack's amounts per turn); rest-of-game modifiers from VSTAR Powers (absent), from Abilities
(outside clause 4) and from Stadium effects (outside clause 5); copy attacks, for instance copying a GX attack (absent); static modifiers outside the language of `Static`
and modifiers from Special Energy (absent; static HP, damage and Retreat Cost changes are constants
of the cards in play since milestone M6, not stored, and need no store bound); per-Pokémon modifiers (Feraligatr's "attacks used by this Pokémon
do 120 more damage" is the player's bonus in the model, milestone M7); reductions restricted by type (printed Iron Defender protects Metal
Pokémon only, whereas the model's reduction protects all of a player's Pokémon); effects that
lock GX attacks (absent). The store bound rests on clause 3, on at most one attack per turn, and
on there being no extra turns; "attack twice" and "take another turn" exist on printed cards
(Festival Lead in Standard; extra turns in older sets), so adding them reopens the bound. The
guess-and-verify coupling of the Poet's second session (one replayable effect that writes a
this-turn and a carried amount in lockstep) is excluded inside one effect by `LoopFree`, and
across effects it lacks the replays it needs: an attack writes a bounded amount once per turn,
and within a turn each writer Item is played a bounded number of times and one Supporter at
most (clause 3); survey S10 found no printed card that writes modifiers of two durations.

For tame decks, effects that read damage do not break finiteness, but they change why it holds. Inside an
attack's effect the clamp is not a simulation: a test against 6 counters separates 5 from 6
counters on a 5-HP Pokémon (`Reads.run_clamp_not_sim`). Attack effects are instead simulated
with the damage on the player's own Pokémon exact and on the opponent's capped at `bound`
(`Run.cap_sim`; since M3 this covers the Benches: the opponent's Bench is capped like the
opponent's Active Pokémon, because a switch inside an attack moves a Pokémon between the two,
and the only reader of a Benched Pokémon's damage, `benchHeal`, reads the player's own), and
every move that resolves an effect starts from a state with no Pokémon at or above its HP,
where equal clamps mean equal damage. Inside a Trainer effect the clamp is a simulation
(`TRun.clamp_sim`), since every step of it starts in such a state. The damage cap at move
boundaries stays at HP. The
earlier bound on the player's own Active Pokémon during a turn (at most `maxHp + 3` counters)
is false once an attack's effect can damage it (`Reads.activeLe_false`) and is no longer used.

The unclamped reachable state space is infinite (`Infinite.not_finite`): from a well-formed
start with no pending Knock Out, one Item that Poisons the opponent's Active Pokémon and then
raises its Poison strength any number of times reaches infinitely many states, none with a
pending Knock Out (`Reach.infinite_damageBounded`). One attack's effect can also place
arbitrarily many damage counters before the Knock Out is taken (`counters_unbounded`). Checkup
can leave a Pokémon at or above its HP when the turn passes, in play reached from a
well-formed start (`Infinite.endTurn_pending_ko_reachable`); the Knock Out is taken between
turns, before the next draw (`Move.damageBounded_of_startTurn`). The finite list is not
computed, depends on the start state, and gives no size bound. For tame decks, the finite
quotient with the same moves (`Reach.finite`) means that reachability questions that depend only
on the clamp could be decided by exploring it, given a computable successor function for the
quotient; neither that function nor the decision procedure is formalized. The same holds for
store-safe decks with the exact-store quotient (`StoreSafe.xfinite`). For the two-counter starts,
which violate `GXOnly` only, no such procedure exists uniformly: by the reduction of `Pokemon/Counter.lean` and
Minsky's theorem, reachability of the halt mark, as a problem over the family of its start
states, is undecidable in the generalised model (the reduction is proved; the appeal to
Minsky's theorem is not formalized). These are theorems about the model, not yet about
the printed game: they cover only decks whose card text is expressible in `Pokemon.Effect`,
and the model's departures from the rulebook are listed at the top of `Pokemon/Rules.lean`.
For Knock Out timing inside Trainer effects the remaining simplifications are these: Knock
Outs are checked after each primitive of the model's effect language (a printed sentence
written as several primitives gets a check between them); the replacement is promoted at once,
before the next step (no ruling on its timing was found); and the Prize cards are the top ones
(several Knock Outs caused by one step, `spreadCounters`, are taken together by the batch
Knock Out step, as after an attack, since milestone batch-KO). Up to these, the model's
Trainer timing is that of the Advanced Player's Rulebook (Pokémon Asia, 2025; the English
rulebook states no rule for it, see above) (an earlier version resolved a Trainer effect as a whole and
could read and heal damage above HP; that defect is gone). Two of these simplifications can
still lose printed outcomes, so transfer to the printed game by inclusion needs them as named
caveats: where a printed sentence is atomic but is written as several primitives, the check
between them removes the outcome in which the whole sentence acts on the original Pokémon
(e.g. `seq (counters 5) (scale opp 1)` against a 5-HP Active always doubles the promoted
Pokémon's damage); and immediate promotion removes outcomes in which later steps find an
empty Active Spot. Neither makes finiteness easier: the atomic reading is the attack case,
and deferred promotion is a finite-branching variant. The other listed departures remain.

Build: `lake build` (core Lean only, no dependencies). `Pokemon/Audit.lean` runs
`#audit_namespace Pokemon` (defined in `Pokemon/AuditCmd.lean`), which checks every theorem
declared in the project, private and generated ones included, and fails the build if any
depends on an axiom other than `propext` and `Quot.sound` (so `sorry` fails it too) or if a
file under `Pokemon/` is not imported. `scripts/audit.sh build.log` then fails CI unless the
log shows the gate's success line and no error or `sorry`.

Imported cards (library `PokemonCards`, not a default target): `tools/importer/` translates
today's Standard pool (survey S9's pool B: regulation marks H, I, J plus Basic Energy) into
`Card` terms, conservatively, and writes them to `PokemonCards/Standard/Part*.lean` with
per-card checks, plus `PokemonCards/Standard.lean` (the count of imported cards, the named
list of the rest, and the set-level theorems, ending in `PokemonCards.Standard.storeSafe`:
every game whose cards all come from the imported pool is `StoreSafe`, all five clauses, and
`PokemonCards.Standard.xfinite`, `StoreSafe.xfinite` for those games, both stated with the clamp
at `Enum.bound` of the cards, which since milestone M6 bounds every derived HP and every static
damage reduction). Of the pool's 2,161 cards, 1,465 are imported (1,097 exactly, 368 with
caveats) as 1,458 distinct terms, and 696 are refused, each with a reason
(`tools/importer/out/coverage.md`; importer 0.13.0, which since 0.13.0 writes the precondition that a
Trainer or an activated Ability can do something where public information decides it,
`tools/importer/noop.py`, and since 0.12.0 the MV6 vocabulary: fixed windows
`Effect.look`, `Qty.most`, the defender modifiers `Mod.weaken` and `Mod.expose`, named-attack bonuses
with `AtkLock.note` and `Test.usedLast`, `Amt.heads` and `Count.retreat`; since 0.11.0 the MV5 Energy
filters as printed: `basicEnergy` for "Basic Energy", `energy` for "Energy", `specialEnergy` for
"Special Energy"; survey S16 classifies the refusals). Since importer version 0.3.0 activated ("once during your
turn", "as often as you like") and on-play Abilities are translated when every sentence has a
rule, since milestone M6 static text (of an Ability, a Tool or a Stadium) in the shapes of
the model's `Static`, and since importer 0.6.0 (milestone M8b) triggered Abilities and Tool text
of the two shapes `TrigEvent.damaged` and `TrigEvent.koByAttack` whose effect is in the trigger
fragment (16 cards; `Standard.trigDamaged`, `Standard.trigKO`; `Standard.triggers_fire`: every
imported trigger fires wherever its place allows, with an effect satisfying `Effect.trigOk`);
passive Abilities, triggered text of other shapes, static text in other shapes, and the other
forms the model lacks are refused with a reason. The tame-deck theorem `Reach.finite`
does not cover imported decks in general: `Standard.untame` lists the imported cards that are
not tame (a `drain` attack, a stored damage reduction, or since milestone MV6 a step-2 penalty or
step-5 increase); its clause on static reductions holds
for every game (`reduceLe_bound`), and `Standard.sReduce_le` bounds the static reduction in force. Regenerate with
`python3 -I tools/importer/importer.py <path to pokemon-tcg-data>` (`--check` re-generates in
memory and diffs; `tools/importer/count_writers.py` recounts writers and recyclers from the
generated library); build with `lake build PokemonCards`, which runs its own axiom gate
(`PokemonCards/Audit.lean`). These are facts about the generated terms; whether a term says
what its printed card says is the importer's claim, validated by eye in survey S11. The
theorems cover only games built entirely from imported cards: the refused cards, and decks
that mix any of them in, are not covered, and "today's Standard satisfies `RecycleSafe`" is
not proved. A separate, hand-written probe (`PokemonCards/OverApprox.lean`) adds
over-approximated terms for the two refused Items that write a modifier (Iron Defender and
Premium Power Pro, type restriction dropped) and shows the recycling check still holds; it is
evidence about those two Items, not a theorem about the Standard pool. Cards imported with
caveats are in general neither over- nor under-approximations of their printed cards (a
caveat may allow outcomes the card does not, forbid outcomes it allows, or both; S11 tables
the direction of each), so the imported pool must not be used for "no deck can …" arguments
without checking the caveats. `Standard.all_nodup` proves that the imported list has no two
equal terms; `pool_size` is arithmetic on two list lengths, and the partition of the pool into
the two lists is established by the importer, not by Lean. The
library lives outside `Pokemon/` because `Pokemon/Audit.lean` requires every module under
`Pokemon/` to be imported by it.

## Licence and trademarks

The MIT licence (`LICENSE`) covers the original code, proofs and documentation written for this
project. Pokémon, the Pokémon Trading Card Game, card names and the text of cards and of the
rulebook belong to their respective owners (Nintendo, Creatures Inc., GAME FREAK inc. and The
Pokémon Company) and are not covered by that licence. Where the repository reproduces card names
or short passages of card or rulebook text (the generated card files, the importer's output
tables, comments), they are quoted for research and commentary, and no licence to them is granted
or implied. The project is not affiliated with, sponsored by or endorsed by those owners. The card
data the importer reads (pokemon-tcg-data) is not distributed here; it comes from that third-party
dataset under its own terms. This is the authors' statement of intent, not legal advice; see
`NOTICE`.
