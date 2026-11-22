import Pokemon.Bounded
import Pokemon.Counter
import Pokemon.Turn
import Pokemon.StoreSafe.Deck
import Pokemon.StoreSafe.Invariant

/-!
# Store-safe decks: the stores stay bounded, so the exact-store quotient is finite

`Pokemon/Bounded.lean` proves finiteness up to `xclamp` on the reachable states whose stores are
bounded. This file gives a condition on the deck under which every reachable state has bounded
stores, at a bound computed from the start state, and so finiteness for those decks without
further hypothesis.

**The deck condition** (`GameState.StoreSafe`, on the cards of the start state; play only
permutes cards, so it holds all game):
* `LoopFree` (clause 1): no effect, of an attack, a Trainer card or (milestone M8a) an Ability,
  contains a damage bonus or damage reduction (`linger … (bonus n)`, `linger … (reduce n)`) under
  `iter`. Locks and prevention may appear anywhere; they are flags.
* `GXOnly` (clause 2): every attack whose effect can write a rest-of-game damage bonus or
  reduction (`Slot.always`) is a GX attack (`Attack.gx`).
* `RecycleSafe` (clause 3, milestone MV): (a) no free recycler can return from a discard pile to
  a hand or deck an Item card of the game that writes a damage bonus or reduction (`Card.wAmt`,
  which is the Item's amount for an Item card and 0 for every other card: a Supporter is played
  at most once a turn, and Stadium and Tool cards write nothing when played). The free recyclers
  (`Card.freeRec`) are the effects of Item and Supporter cards and (milestone M8a) the "as often as
  you like" Abilities of Pokémon cards and (milestone M5) of Tools; attacks, "once during your
  turn" and on-play Abilities, and Stadium effects are not free recyclers. (b) No effect at all,
  attacks, Abilities and Stadium effects included, can return an Item or Supporter card that
  writes a rest-of-game bonus or reduction (`Card.alAmt`). "Can return":
  the filter of one of its zone moves out of a discard pile admits the card. Attacks may recycle
  every other card (an attack ends the turn), and Energy and Pokémon cards may be recycled by any
  effect (they write nothing when played). A Stadium's once-per-turn effect may recycle a writer
  and write itself; it is paid per use through `Card.stQ`, at most two uses a turn. Decidable. A deck with no recycling satisfies it
  (`GameState.NoRecycle.recycleSafe`), so for such decks `StoreSafe` means what it meant before
  milestone MV. Survey S10 §5 proposes property P ("no in-turn effect may return a non-Supporter
  modifier writer from the discard pile or from play to hand or deck; no Stadium of either deck
  either"); in the model's vocabulary (no return from play) clause 3 (a) is P for Item and
  Supporter effects, quantified over the cards of both decks together, without P's Stadium part
  (a Stadium's uses are counted per turn instead, `Stadiums.stadium_recycler_storeSafe`), extended to
  "as often as you like" Abilities but not to once-per-turn or on-play ones, which P covers and
  which the potential `abPot` bounds per turn instead (clause 4 only forbids their rest-of-game
  writes); clause 3 (b), which P lacks, is vacuous for every deck with no
  rest-of-game Trainer writer (all of today's Standard, survey S9 N3).
* `AbilitySafe` (clause 4, milestone M8a): no "as often as you like" Ability writes a damage bonus
  or reduction, and no Ability writes a rest-of-game one. Decidable; every deck without Abilities
  satisfies it.
* `StadiumSafe` (clause 5, milestone M5): no Stadium's effect writes a rest-of-game damage bonus
  or reduction. Decidable; every deck without Stadium cards satisfies it. Since milestone M5
  clause 3 also treats Stadiums differently: a Stadium card is not a writer that clause 3 (a)
  protects (playing it writes nothing; `Card.wAmt`, `Card.alAmt`), and a Stadium's effect is not
  a free recycler (`Card.freeRec`): its uses are bounded per turn instead. For a deck without
  Stadium cards clauses 3 and 5 say what they said before (`Pokemon/NoStadiums.lean`).

**Why it bounds the stores** (milestone MV: a per-turn count). Each resolution of a loop-free
effect `e` adds at most `e.amtAt s` to the amounts in slot `s` (`Run.slot_le`, `TRun.slot_le`).
The writers are:
* Item and Supporter cards. Within one turn, before the turn's attack, no free recycler returns
  an Item writer from a discard pile (clause 3 (a); `Run.disc_mono`: the writer weight of the
  discard piles does not drop), so each such card is played at most once in the turn, and at most
  one Supporter is played; so Trainers write at most `2 P` in one turn (`P = cardsAmt` of the
  cards). An attack may recycle a writer, but it ends the turn. Carried amounts expire within
  three turn boundaries (`Store.shift`), so at most three turns' Trainer writes are live. The
  rest-of-game slot holds only amounts of writers in the discard piles, which no effect recycles
  (clause 3 (b)), and of GX attacks.
* Abilities (milestone M8a). An "as often as you like" Ability writes nothing (clause 4) and
  recycles no writer (clause 3 (a)), so it is a step that keeps the count. Each use of a "once
  during your turn" Ability by a Pokémon that has not used one, and each on-play trigger, spends at
  least one unit of a potential of the player to move (`GameState.abPot`: their Pokémon in play
  not yet used, still able to evolve, the free places in play, and the opponent's Prize cards),
  which no move of the turn raises while the game goes on (a batch Knock Out step that ends the
  game can raise it, milestone batch-KO) and which is at most `potBound` of the number of cards; each
  such use writes and recycles at most `Q` (`Ability.q`, `cardsAbQ`). The bound rests on there
  being no effect that returns a Pokémon in play to the hand or deck: a Pokémon leaves play only
  by a Knock Out, which costs a Prize card.
* Stadium effects (milestone M5). The player to move uses the Stadium in play at most once
  (`GameState.stadiumUsed`) and plays at most one Stadium (`GameState.stadiumPlayed`), whose effect
  is then usable once more; both flags are cleared at the end of the turn. So a turn has at most
  two Stadium uses (`GameState.stPot`), each writing and recycling at most `R` (`Card.stQ`,
  `cardsStQ`). A rest-of-game write by a Stadium would recur every turn (clause 5).
* Attacks. At most one attack per turn (`GameState.attacked`, reset only by `endTurn`), each
  writing at most `A = cardsAtkAmt` (the largest attack amount among the cards); three attacks'
  carried amounts at once; rest-of-game amounts only from GX attacks (clause 2), once per player per
  game.

Before milestone MV nothing left a discard pile, each Trainer card was played at most once per
game, and the bound counted the Trainer amounts once (`storeBoundNR`); that proof is kept for decks
that recycle nothing (`reach_boundedStores_noRecycle`). With recycling the per-game count is false:
`Recycle.recycling_breaks_bound` gives a deck satisfying clauses 1, 2, 4 and 5, violating clause 3, with
unbounded stores and infinitely many `xclamp` classes.

The per-turn invariant (`StoreSafe.TInv`) has as witnesses the Trainer and Ability amounts written
this turn, last turn and the turn before, the writer weight of the discard piles at the start of the
turn, and (milestone M8a) the potential at the start of the turn. `StoreSafe.reach_boundedStores`
concludes `BoundedStores (storeBound g₀)` for every reachable state, with `storeBound g₀ =
storeTotal g₀ + 6 · cardsAmt C + 3 · (Q · potBound |C|) + 6 · cardsStQ (cardsAmt C) C +
3 · cardsAtkAmt C` (`C` the cards of `g₀`, `Q = cardsAbQ (cardsAmt C) C`, which is 0 for a deck
without Abilities; the Stadium term, milestone M5, is 0 for a deck without Stadiums).

**Results.**
* `StoreSafe.reach_boundedStores`: for a start satisfying `StoreSafe`, every reachable state has
  stores bounded by `storeBound g₀`.
* `StoreSafe.reach_boundedStores_noRecycle`: for a start satisfying clauses 1 and 2 whose cards
  recycle nothing and (milestone M8a) whose Abilities write nothing (`AbilityQuiet`), the bound of
  master, `storeBoundNR g₀ = storeTotal g₀ + cardsAmt C + 3 · cardsAtkAmt C`.
* `StoreSafe.xfinite`: from any `StoreSafe` start (well-formed or not), the `xclamp`s of all reachable states
  lie in one finite list, and the kernel of `xclamp` is a two-way bisimulation along reachable
  states. No tameness: damage reduction (Iron Defender), `drain`, carried bonuses and
  reductions, rest-of-game modifiers from GX attacks, and recycling within clause 3 are allowed.
* `Pokemon/Dichotomy.lean`: the two-counter starts of `Pokemon/Counter.lean` satisfy clauses 1
  and 3 and, when the machine's first instruction is not `halt`, violate clause 2
  (`StoreSafe.counter_loopFree`, `StoreSafe.counter_recycleSafe`, `StoreSafe.counter_not_gxOnly`).
* `Pokemon/Recycle.lean`: clause 3 cannot be dropped (`Recycle.recycling_breaks_bound`).
  `Pokemon/LoopFreeNeeded.lean`: nor can clause 1 (`LoopFreeNeeded.iter_writer_breaks_bound`).
* `Pokemon/Abilities.lean` (milestone M8a): clause 4 cannot be dropped, nor clause 3 (a) for
  Abilities (`Abilities.unlimited_writer_breaks_bound`, `Abilities.unlimited_recycler_breaks_bound`);
  a once-per-turn recycler of a writer is store-safe (`Abilities.once_recycler_storeSafe`), and so is
  a deck with Feraligatr's once-per-turn bonus (`Abilities.feraligatr_storeSafe`).
* `Pokemon/Stadiums.lean` (milestone M5): clause 5 cannot be dropped
  (`Stadiums.stadium_writer_breaks_bound`); a Stadium that returns a modifier writer every turn,
  to both players, is store-safe (`Stadiums.stadium_recycler_storeSafe`). `Pokemon/NoStadiums.lean`:
  for a deck without Stadiums, clauses 3 and 5 and the bound are those of milestone M8a.

**Which theorem applies.** `Reach.finite` (`Pokemon/Finite.lean`) needs tame cards (no damage
reduction, no `drain`) and no reduction in effect at the start; it allows bonus writes under
`iter` and rest-of-game bonuses in attacks that are not GX attacks, and its quotient is coarser
(the clamp caps stored bonuses). `StoreSafe.xfinite` allows damage reduction, `drain`, carried
modifiers and Trainer modifiers; it forbids amounts written under `iter` and rest-of-game
amounts written by attacks that are not GX attacks, and its quotient is finer (the stores are
kept exact). Neither class contains the other; for decks in both, both theorems apply.

**Rule change** (in `Pokemon/Rules.lean` and `Pokemon/Card.lean`): `Attack` has a new field
`gx`; `Move.attack` requires `atk.gx = true → g.cur.gxUsed = false` and sets the attacker's
`gxUsed` when `atk.gx` (the result's `gxUsed` is `atk.gx || gxUsed`). `Move.attackConfused`
(the failed attempt of a Confused Pokémon) has the same premise and leaves `gxUsed` unchanged
(an unverified ruling; see the Known gaps in `Pokemon/Rules.lean`). Before, `gxUsed` was never
read or written. Every theorem that mentions attacks was re-proved; `Counter.universal` is
unchanged in statement (its attacks have `gx = false`).

**What the condition does not cover.** Printed behaviours outside it, or outside the model:
* static effects of Abilities, Stadiums and Tools outside the language of `Static` (since
  milestone M6 HP changes, damage bonuses and reductions and Retreat Cost changes are modelled;
  Bench size, damage prevention, Ability and Tool locks are not), and triggered Abilities other
  than the two shapes of milestone M8b (`TrigEvent`); the model plays such text as no effect;
* returning a card from play to the hand or deck (Scoop Up Cyclone, and the Abilities of Abra,
  Dudunsparce and Misty's Psyduck) and devolution are not in the model; with them a Pokémon card
  could re-enter play within a turn, and the potential that bounds Ability uses would need
  another argument;
* the model lets a played Item or Supporter recycle itself (it is in the discard pile while its
  effect resolves; the rulebook discards it afterwards); clause 3 (a) covers that case, since it
  constrains every return from the discard pile;
* "attack twice", "attack again" after a Knock Out, and "take another turn" are not modelled;
  with them more than one attack's amounts would be written per turn;
* the Poet's guess-and-verify coupling (one replayable effect writing a this-turn and a carried
  modifier together) is excluded inside one effect by clause 1 and across effects by the per-turn
  count: within a turn each Item writer is played at most once and one Supporter at most;
  survey S10 §0 found no printed card that writes modifiers of two durations together;
* rest-of-game modifiers from VSTAR Powers are not modelled (`vstarUsed` is unused); from
  Abilities they are outside clause 4, from Stadium effects outside clause 5;
* copy attacks are not modelled; the once-per-game rule and clause 2 are stated for the attacks
  printed on the attacker;
* the store bound is about stored modifiers, written by an effect when it resolves; static damage
  bonuses and reductions (milestone M6: from static Abilities, Stadiums and Tools, `Static`) are not
  stored: they are constants of the cards in force (`GameState.sBonus`, `GameState.sReduce`), so
  they need no clause; modifiers from Special Energy are not modelled;
* reductions restricted by type are not modelled: printed Iron Defender protects Metal Pokémon
  only, whereas the model's reduction protects all of a player's Pokémon;
* effects that lock GX attacks are not modelled.

The store bound rests on: at most one attack per turn, no extra turns, clause 3 for recycling,
clause 4 for "as often as you like" Abilities, clause 5 and the once-per-turn and one-play-per-turn
Stadium rules for Stadium effects, and the absence of returns from play.
-/
