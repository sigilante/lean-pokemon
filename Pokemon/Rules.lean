import Pokemon.Effect

/-!
# Moves

`Move g g'` is one legal step of the game from the point of view of the player to move.
`Reach g₀ g` is reachability by legal play; no move is available once a winner is set.

A turn has two phases, told apart by `GameState.between`. `endTurn` applies Pokémon Checkup
to both Active Pokémon and hands the move to the opponent with `between = true`; in that
phase only the batch Knock Out step and the draw that starts the turn proper (`startTurn`, or
`deckOut` if the deck is empty) are legal. Checkup is the only place where damage arrives
without a player's action; the Knock Outs it causes are therefore taken before anything else
can happen, as the rulebook requires.

An attack ends the turn: "Once you attack, your turn is over" (rulebook 2023 p. 13; "3) Attack.
Then, end your turn.", p. 9). `attack` and `attackConfused` (a Confused Pokémon's failed
attempt, which is still the turn's attack) set `GameState.attacked`, and every action of the
turn proper (`playBasic`, `attach`, `evolve`, `retreat`, `item`, `supporter`, `attack`,
`attackConfused`, since milestone M8a `ability` and `onPlay`, and since milestone M5 `stadium`,
`stadiumUse`, `tool` and `toolBench`) requires `attacked = false`; so after an attack only its Knock Outs (the batch
step: Prize cards, the outcome, promotions) and `endTurn` are legal, and `endTurn` resets the flag. A player who
does not attack ends the turn by `endTurn` at any point of the turn proper.

Knock Out timing. The rulebook checks for Knock Outs at the end of every attack ("check to see
if any Pokémon were Knocked Out by the attack", 2023 p. 14) and at the end of every Pokémon
Checkup ("After both players have gone through these checks", p. 15). The model also takes a
Knock Out at once whenever damage reaches HP at any other time; that third clause is not in the
English rulebook (see the Known gaps for its source). Every Knock Out is taken by the batch
Knock Out step (`KOBatch`, milestone batch-KO), the rulebook's single check: every Pokémon in play
of both players is tested against its derived HP once, in the state before any removal; all those
at or above their HP leave play together; both players take their Prize cards; the game is decided
(`Outcome`: a win, or Sudden Death when both players win in as many ways); then each player with an
empty Active Spot promotes. If the removals or promotions leave another Pokémon at or above its HP
(derived HP can change), the check repeats. The model follows the timing in two ways. Between
moves: every move other than the batch step (`Move.knockOuts`) requires the state to be `Settled`:
no Pokémon in play is at or above its HP, and both Active Spots are filled; from any other state
the batch step is the only move (`Move.batch_of_not_settled`). So once a move leaves a Pokémon at
or above its HP, the next move Knocks it Out, with every other pending one, before anything else
happens; nothing can read, heal or otherwise use an over-HP Pokémon between moves. Inside a move:
an attack's effect is resolved as a whole by `Run`, so damage may exceed HP and the effect can read
it, and the Knock Outs come after the attack, as the rulebook says; an Item or Supporter's effect
is resolved by `TRun`, which takes the batch steps after each primitive step (`Resolve`) and stops
if the game is over, so no step of a Trainer effect runs while a Pokémon is at or above its HP
(`TRun.guarded`).

Sources of the turn rules (milestone M1). The rulebook quoted is the *Scarlet & Violet—151*
rulebook (©2023, `data/mew_rulebook_en.pdf`, survey S9); survey S8 read the *Surging Sparks*
rulebook (©2024) and a Professor Program post on the rule changes of February 2026. The model
follows the latest source; for the rules below the three agree except where noted.
* An attack ends the turn (2023 pp. 9, 13; 2024 the same, S8 B13). The failed Confused attempt
  also ends the turn: the rulebook says only that "the attack doesn't happen" (p. 16); the model
  reads the Confusion check as step C of using the attack (p. 20).
* First-turn bans (2023 pp. 11–13; 2024 the same, S8 B4, B8, B14): no attack and no Supporter
  for the starting player on the first turn of the game, no evolving on either player's own
  first turn. Card text that lifts them is absent from the model.
* Damage calculation stops at base damage 0 (2023 p. 20; 2024 the same, S8 F2). Since milestone
  M4 the stop is applied once per attack, to the base damage as the attack's text computes it.
* A new Poison replaces the old one (2023 p. 16; 2024 the same, S8 G7). That Croagunk's
  stacked increase ends with the replaced Poison is the model's reading; no ruling was found.
* Nine Basic Energy types (2023 glossary p. 39; S8 D1); `BasicEnergy`.
* Stadiums (2023 p. 12; 2024 the same, S8 B9): one shared slot; one Stadium played per turn; not
  one with the name of the Stadium in play; the replaced Stadium goes to its owner's discard pile;
  "Once during each player's turn" effects usable by whoever is taking their turn (milestone M5).
* Pokémon Tools (2023 glossary p. 40, "Each Pokémon can have only 1 Pokémon Tool attached at a
  time"; p. 9, "as many Item and Pokémon Tool cards as you like"): milestone M5. Technical
  Machines (glossary p. 41: an Item "you can attach to your Pokémon"; "remain attached unless the
  card text says otherwise") are, in today's Standard, one Tool (Technical Machine: Fluorite
  sv8-188) whose text says "discard it at the end of your turn" (survey S9 C10); the model has no
  end-of-turn discard.
* Simultaneous wins: the 2023 rulebook has Sudden Death (p. 21), and "if you win in both ways and
  your opponent wins in only one way, you are the victor!"; the model ends the game with the
  outcome `Outcome.suddenDeath` (milestone batch-KO) and does not play the new game; the 2026 post
  replaced Sudden Death with tiebreaker games (S8 J4, unverified against a rulebook; gaps).
* Knock Outs at times other than after an attack or Checkup: in neither English rulebook; the
  model's rule comes from another source (gaps).

Sources of the damage and Energy rules (milestone M4; the 2023 and 2024 rulebooks agree word for
word on the damage steps, survey S9 against S8 F2; S8 records no later change to these rules).
* Typed attack costs (2023 p. 13, Quaxwell: "the ◉ means you need to have 1 ◉ Energy attached.
  However, the ✱ means that any type of Energy can be used"; S8 D2): `Pays`, a matching of cost
  symbols to units of attached Energy. A Retreat Cost is paid by discarding "1 Energy from your
  Active Pokémon for each ✱ listed in its Retreat Cost" (p. 12); with Basic Energy only, one
  Energy card is one unit, as `retreat` counts.
* Weakness and Resistance (2023 p. 14: "If the attack does damage, your opponent's Active
  Pokémon takes more damage if it has Weakness to the attacker's type. It takes less damage from
  a Pokémon if it has Resistance to that Pokémon's type", and "Don't apply Weakness and
  Resistance for Benched Pokémon!"; S8 E1): `PokemonCard.weakness` (×2), `resistance` (−N).
  Since milestone M3 attack damage also reaches Benched Pokémon (`Effect.benchDamage`,
  `Effect.spreadDamage`), and Weakness and Resistance are not applied to it. The attacker's type is `InPlay.type` (a Coloring counter changes it).
* The damage calculation (2023 p. 20, steps 1–6, quoted in `dealtBy`; S8 F2): one calculation
  per attack (`Effect.oneHit`, required by `Move.attack` through `Attack.wf`), on the base damage
  as the text computes it (`Amt`), then the attacker's bonus, Weakness, Resistance, the
  defender's reduction and prevention, each subtraction stopping at 0.
* Attack damage only from attacks (2023 p. 20, step 1: "If an attack tells you to put damage
  counters on a Pokémon, you have no more calculations to do because damage counters aren't
  affected by Weakness, Resistance, or any other effects"): Item and Supporter effects have no
  damage step (`Move.item`, `Move.supporter` require `Effect.hitFree`); their damage is written
  as damage counters (`counters`, `selfDamage`). A printed Trainer card whose text says "does
  damage", if there is one, would lose any modifier the rulebook applies to it; no search for
  such cards was made.

Known gaps (each is a place where this model is simpler than the rulebook):
* setup, mulligans and the opening coin flip are not modelled; start from a set-up state;
* Energy is attached, and evolution applied, to the Active Pokémon (`attach`, `evolve`) or to a
  Benched one (`attachBench`, `evolveBench`; milestone M3, rulebook 2023 p. 11); the "had in
  play at the beginning of your turn" condition of evolution is read as `InPlay.fresh` (not
  put into play or evolved this turn);
* attack costs are typed (milestone M4; rulebook 2023 p. 13): each typed symbol is paid by a
  unit of attached Energy of that type and each Colorless symbol by any unit, every unit paying
  one symbol (`Pays`, decided by `payable`); only Basic Energy exists, one unit of its type
  (`Card.provides`); Special Energy (several units, or units of several types), cost changes
  ("this attack costs ✱ less") and Energy that provides nothing in some states are absent. A
  Retreat Cost is still paid by discarding that many Energy cards, which with Basic Energy only
  is the rulebook's rule;
* Weakness is ×2 to one type and Resistance −N to one type, as printed today (S9: every Standard
  Weakness is ×2; Resistance −30, once −20). Absent: "+10" to "+40" Weakness on older cards,
  two Weaknesses or two Resistances on one card (dual-type Pokémon, S8 C6; a Pokémon has one
  type here), and effects that change or ignore Weakness or Resistance (S8 E2); Weakness and
  Resistance never apply to the Bench (milestone M3: attack damage to Benched Pokémon skips them);
* Knock Outs (milestone batch-KO; before it, separate moves taken one at a time in any order, a
  DEPARTURE from the rulebook since milestone M6 that is now removed, see below): every Knock Out
  is taken by the batch Knock Out step (`KOBatch`, the move `Move.knockOuts`, and the steps of
  `Resolve` inside Trainer effects), forced by `Settled` before any other move. Any Pokémon in play
  whose damage reaches its derived HP is Knocked Out (milestone M3): the check (`GameState.koStep`)
  tests every Pokémon in play of both players once, in the state before any removal, and removes
  all those at or above their HP together, each with every card attached to its owner's discard
  pile ("If a player's Pokémon is Knocked Out, that player puts it and all cards attached to it in
  the discard pile", rulebook 2023 p. 14); each player takes the Prize cards of the opponent's
  Knocked Out Pokémon, added up by rule box (`PokemonCard.prizeCount`: 1, 2 for Pokémon ex, 3 for
  Mega Evolution Pokémon ex; with fewer left, all are taken); the game is decided by counting each
  player's ways of winning (the last Prize card taken; the opponent left with no Pokémon in play):
  more ways win, equal nonzero ways are Sudden Death (`Outcome.ofWays`; "if you win in both ways
  and your opponent wins in only one way, you are the victor!", p. 21); then each player with an
  empty Active Spot promotes a Benched Pokémon (`Promote`). The departures the old order allowed
  are gone and their statements are now false (`StaticWitness.promotion_rescues_false`,
  `StaticWitness.double_knockOut_lost_false`); the same starts give the rulebook's outcome on every
  move (`StaticWitness.guard_knocked_out`, `StaticWitness.double_knockOut_taken`), and when both
  players take their last Prize card the outcome no longer depends on an order
  (`Bench.suddenDeath_forced`, `Bench.bothWays_wins`). What remains of the gap:
  - the Prize cards taken are the top ones of the Prize list (`PlayerState.takePrizes`), whereas
    the rulebook lets the player choose which ones (a finite choice; item below);
  - who promotes first when both players must: no rule was found (the 2023 rulebook says only "The
    player whose Pokémon was Knocked Out chooses a new Active Pokémon from their Bench", p. 14);
    the model makes both choices in one step, a nondeterministic choice that covers both orders,
    and checks nothing between them, so every order gives the same states;
  - the check repeats: after a batch, removals (a static Ability leaving play) and promotions (a
    Pokémon whose static effect depends on its place) can change derived HP and leave another
    Pokémon at or above its HP; the state is then not `Settled` and the next move is another batch
    (`StaticWitness.chain_knock_out`), until the state is `Settled` or the game is over. The 2023
    rulebook describes one check after an attack and one after Checkup and is silent on this case;
    the repetition is the model's reading of the rule it uses for Knock Outs at other times (the
    Asia rule, next item), and it ends: a batch that does not end the game lowers twice the number
    of Pokémon in play plus the number of empty Active Spots (`KOBatch.koMeasure_lt`), so every
    chain of batches is finite (`KOBatch.acc`), every state has a `Resolve` result, `Settled` or
    with an outcome (`Resolve.exists`), and `Resolve` takes at most that measure plus one batches
    (`Resolve.chain_le`; all in `Pokemon/Terminate.lean`);
  - the outcome is decided at the end of each round of the repeated check, from that round's
    Knock Outs, so a Pokémon that is doomed only because another leaves play (its HP falls after
    the removal) is not counted in the round that ends the game. Example: player B has an Active
    Pokémon whose static effect gives B's Benched Pokémon +30 HP, and a Benched Pokémon with 4
    damage counters and 60 HP with the bonus (30 without); both Active Pokémon are Knocked Out and
    both players take their last Prize card. The model ends the game in Sudden Death at the end of
    round 1 (B still has the Benched Pokémon), whereas a reading that re-checked after the removals
    before deciding would Knock it Out too and give A a second way to win, so A would win. The
    rulebook is silent on this case; deciding per round is the model's reading
    (`StaticWitness.outcome_per_round`, a machine-checked witness);
  - Sudden Death is a new game, which the model does not play: `Outcome.suddenDeath` is a terminal
    outcome of the model's game. The 2026 rules (Professor Program post, survey S8 J4) replaced
    Sudden Death by a tiebreaker game; that was read only through a secondary summary and is
    unverified against a rulebook. For the model it changes only the name of the outcome;
  - the outcome counts the two ways of winning the rulebook names at a Knock Out (p. 21); a third
    way, an opponent who cannot draw at the start of their turn (`deckOut`), never coincides with a
    Knock Out check in the model (the draw is a separate move);
  - effects that change the number of Prize cards taken (Shedinja, "take 1 more Prize card", S8
    I5) are absent; Knock Out triggers came with milestone M8b, for one shape ("this Pokémon is
    Knocked Out by damage from an attack from your opponent's Pokémon", `TrigEvent.koByAttack`;
    the triggers section above `Move`), and every trigger that changes the Prize cards taken
    (Shedinja, Lillie's Pearl, Munkidori ex, Mega Gengar ex, Legendary Summit, Togekiss,
    Hydreigon ex; survey S12) is absent: the termination of trigger chains rests on every Knock
    Out giving a Prize card (`KOMove.acc`);
* the source of the Knock Out timing outside attacks and Checkup: survey S9 found no rule in
  the 2023 English rulebook (*Scarlet & Violet—151*) that Knock Outs are checked at once at
  other times, and survey S8 quotes none from the 2024 rulebook; the model's immediate Knock
  Outs in mid-effect (`TRun`) and its `Settled` premise on every other move rest on the Pokémon
  Asia *Advanced Player's Rulebook* (Ver. 3.4, 2025), quoted by survey S2 ("When to check for a
  Knock Out: At the end of an attack, At the end of Pokémon checkup, Anytime a Pokémon's
  remaining HP becomes zero, in addition to the above"), a document of another region's rules
  text. This milestone does not change the timing; it is a modelling decision until an English
  source confirms it;
* Knock Outs in mid-effect (Item and Supporter cards, `TRun`): they are checked after each
  primitive step of the model's effect language, so a printed sentence that the model writes
  as several primitives gets a check between them, and the outcome in which the whole
  sentence acts on the original Pokémon is then absent from the model (e.g.
  `seq (counters 5) (scale opp 1)` against a 5-HP Active always acts on the promoted
  Pokémon in its second step); the Knocked Out Pokémon's replacement is
  promoted at once, before the next step (no ruling was found on when the replacement is
  chosen in mid-effect; the promoted Pokémon is a nondeterministic choice, which covers the
  owner's choice, but outcomes in which later steps of the effect find an empty Active Spot
  are absent from the model); when a Prize ends the game, or its owner has no Pokémon to promote, the
  game ends and the rest of the effect is not resolved. Several Knock Outs after one step are
  taken together, by the batch Knock Out step, as after an attack (`Bench.doubleKO_reachable`);
* a Knock Out takes the top Prize cards of the Prize list, whereas the rulebook lets the player
  choose which Prize cards to take (a finite choice; since milestone batch-KO a player takes the
  Prize cards of all the opponent's Pokémon Knocked Out by one check at once);
* HP is derived (milestone M6; the survey's loophole L1): `GameState.hpOf` is the printed HP plus
  every `hpPlus` and less every `hpMinus` of the static effects in force (`Static`, from static
  Abilities, Tools and the Stadium in play), computed from the state and never stored, and every
  Knock Out premise (`DamageBounded`, `Settled`, the batch Knock Out check, `moveCounter`'s "without
  Knocking it Out") reads it. When a source leaves play (a Tool discarded, a Stadium replaced,
  Energy removed, a Pokémon with a static Ability Knocked Out, a Pokémon moved out of the place its
  bonus needs) HP can drop below the damage; no card text or rule found says what then happens to
  the damage (survey S7 §A), and the model keeps the counters and takes the Knock Out by its
  ordinary timing (between moves, `Settled`; in mid-effect, `Resolve` inside `TRun`; after an
  attack or Checkup), a reading recorded here as a modelling decision. Chains are taken by
  repeated batches (`StaticWitness.chain_knock_out`; item on Knock Outs above). Not expressible, and open: HP defined by copying another
  Pokémon's HP (Ditto dp6-27, base3-3: circular between two Dittos), an HP bonus keyed to the
  Retreat Cost combined with a Retreat Cost keyed to the remaining HP (Heavy Boots with Rescue
  Board: no condition of `Static` reads HP or the Retreat Cost, so HP is never defined in terms of
  itself), "set" forms ("its maximum HP is 300", Crystal Wall; "max HP is 80", Koga's Ditto) and
  the order of "set" and "add" (the model adds, then subtracts, stopping at 0), stacking rules
  ("The effect of Vibrant Dance doesn't stack", "You can't apply more than 1 … at a time": the
  model adds every effect in force), HP bonuses counted per Prize card taken, per Benched Pokémon
  or per named Pokémon in play (Brambleghast, Pangoro, Nidoking), effects that read "remaining HP"
  (Rescue Board), and Special Energy HP bonuses (no Special Energy). Before milestone M6 HP was the
  printed value, and the clamps capped damage there; they now cap at a bound on every derived HP
  (`hpBound`, `Enum.bound`). A Pokémon whose derived HP is 0 (its `hpMinus` effects reach its
  printed HP plus its `hpPlus` effects) is a pending Knock Out at once, with no damage on it;
* markers (`Marks`): Imprison, Shock-wave, Lightning Rod and Char are flags, and the Coloring
  counter is a type. The printed Imprison and Shock-wave counts are uncapped, but only "has
  any" is read and removal takes them all, so a flag is exact for them (`Markers.flag_exact`;
  this is a modelling assumption about the card pool: a card that counted them would break it).
  Effects put a marker or a Coloring counter on any one of either player's Pokémon in play
  (`mark`, `color`; printed cards target the opponent's), remove a marker from all of either
  player's Pokémon (`unmark`; Tropius removes from its own player's), and test either Active
  Pokémon (`Test.marked`, `Test.isType`); markers are general primitives, usable any number of
  times and inside `iter`. Markers stay through evolution, retreat and promotion and leave play
  with the Pokémon (text is silent except for Char, which stays while in play). Char puts 2
  damage counters on tails after every turn on its Pokémon, Active (`InPlay.checkup`) or, since
  milestone M3, Benched (`BenchChar` in `Move.endTurn`, one flip per Pokémon); "A Char counter
  requires your opponent to flip a coin after every turn. If tails, put 2 damage counters on the
  Pokémon with that Char counter" (Quilava neo1-47) does not restrict it to the Active Spot. Absent: the readers of Imprison (Poké-Powers and Poké-Bodies; Ability locks are absent),
  tests on Benched Pokémon's markers ("Choose 1 of your opponent's Pokémon that has any
  Shock-wave markers", "any Pokémon with a Lightning Rod marker"), Dark Ivysaur bp-6's
  transient markers allocated by the opponent, and the marker-like states of S7 §3.3 (Poison
  payloads, delayed triggers, attack locks bound to one Pokémon, history flags, face-up Prizes);
* effects read only the two Active Pokémon: their damage (threshold and exact tests,
  `Test.atLeast` and `Test.exactly`; the proportional write `scale`), their Special
  Conditions (`Test.cond`), their markers (`Test.marked`) and their type (`Test.isType`); the
  reads of a Benched Pokémon's damage are the truncated subtraction of `benchHeal`
  (milestone M3) and, since milestone M8a, `moveCounter` (`CMove`: a counter moves off a Pokémon
  only if it has one, and with "without Knocking it Out" onto one only if its damage stays below
  HP), both on the player's own Pokémon; since milestone MV amounts and tests also read counts (`Count`: the cards that
  pass a filter in a player's hand, deck or discard pile; a player's Prize cards left; a player's
  Benched Pokémon whose card passes a filter; the Energy passing a filter attached to a player's
  Active Pokémon or to all of their Pokémon in play; `Amt.count`, `Test.countGe`), none of which
  reads damage, so both clamps keep them exact (`Count.val_clampAt`, `Count.val_xclampAt`);
  since milestone MV2 tests also read the printed card of either Active Pokémon (`Test.top`: "is a
  Pokémon ex", "is an Evolution Pokémon", "is a Tera Pokémon") and whether it has a Tool
  (`Test.hasTool`), and counts read the Pokémon in play passing a filter (`Count.inPlay`), all
  exact under both clamps (`Pokemon/InPlayTests.lean`); absent: name-prefix filters ("has
  \"Nidoking\" in its name", 8 refused cards in survey S13 §C), reads of the defender's Retreat
  Cost or remaining HP, and Special Energy; two filters read less than print does:
  `Filter.ptype` reads the printed type and ignores a Coloring counter, and `Filter.hasAbility`
  reads the printed Abilities and ignores one a Tool gives (the first cannot arise among the
  imported Standard cards, none of which places a Coloring counter; the second can: one imported
  attack counts the opponent's Pokémon that have Abilities, and imported Tools give triggered
  ones — whether print counts a Tool's effect as the Pokémon's Ability is not settled here);
  there are no other reads of the damage on Benched Pokémon (no tests or counts of it), none of
  Poison strength, of HP ("if it has full
  HP", "remaining HP"), of the lingering modifiers in effect, or of the turn's history beyond
  milestone MV2's (next item); a count test is made, like every test, while the player has an
  Active Pokémon; `scale` writes only to the
  opponent's Active Pokémon (Lunala cel25-15 doubles the damage on each of the opponent's
  Pokémon, Bench included); the damage step's amount (`Amt`) reads the damage on either
  Active Pokémon (`Amt.per`); the damage step itself reads the Weakness and Resistance of the
  opponent's Active Pokémon and the type of the player's;
* lingering modifiers (`Store`, `Effect.linger`): each player has a damage bonus for their
  attacks, a damage reduction and a damage prevention for attacks against their Pokémon, and
  locks on attacking, retreating and playing Items, for this turn, the next turn, the turn
  after, or the rest of the game; `endTurn` shifts the turns (`Store.shift`). Amounts add up
  without limit: `linger` is a general primitive, usable any number of times and inside
  `iter` (printed same-turn bonuses and reductions are bounded by copies times a constant if no
  card-recycling loop replays them, an empirical claim about the card pool; rest-of-game ones
  come from once-per-game GX attacks; a reduction carried into the opponent's turn exists on a
  printed Item, Iron Defender; the model over-approximates them).
  Modifiers belong to a player, not to one Pokémon: "this Pokémon takes 30 less damage during
  your opponent's next turn" protects whichever Pokémon that player has Active, and does not
  end when the Pokémon leaves the Active Spot or follow it to the Bench. Damage done by an
  attack is computed once per attack, by the rulebook's steps (`dealtBy`, 2023 p. 20): nothing
  if the base damage `n` is 0; otherwise `n` plus the attacker's bonus (step 2), doubled under
  Weakness (step 3), less Resistance (step 4), less the defender's reduction (step 5), each
  subtraction stopping at 0, or nothing under prevention; `counters` (damage counters, not
  damage) is not modified, as in the rulebook. The bonus is placed at step 2 and the reduction
  at step 5, which is what printed modifiers say ("… more damage … (before applying Weakness
  and Resistance)", "… less damage … (after applying Weakness and Resistance)", survey S9);
  modifiers that name the other step are not expressible. Absent: threshold
  prevention ("prevent damage of 40 or less"), prevention of effects, locks on Supporters,
  Stadiums, Abilities or Energy attachment, cost changes, effects that change Weakness,
  Resistance or type (other than the Coloring counter), "attack twice" and "take another turn",
  and "that much more damage" (damage taken last turn).
  Finiteness is proved for two classes of decks. *Tame decks* (`Reach.finite`): the clamp
  `GameState.clamp k`, which caps every bonus and reduction, is a bisimulation when no card adds
  a damage reduction or uses `drain` and no reduction is in effect at the start
  (`GameState.Fit`); for every cap `k ≥ 3` there is a deck with a reduction for which that clamp
  is not a simulation (`Lingering.reduce_breaks_clamp`), and for every `k ≥ 2` a deck with
  `drain` (`Lingering.drain_breaks_clamp`). *Faithful decks* (`Faithful.xfinite`): the clamp
  with exact stores, `GameState.xclamp`, is a bisimulation for every deck, on all pairs of
  states with equal `xclamp` (`Reach.xclamp_bisim`, `GameState.xclamp_bisim`), and its reachable
  values are finite when the stores stay bounded
  (`Reach.xfinite_bounded`), which holds for decks with no damage bonus or reduction under
  `iter` (`LoopFree`) and rest-of-game bonuses and reductions only in GX attacks (`GXOnly`;
  `Faithful.reach_boundedStores`). Faithful decks may use damage reduction, `drain`, and
  carried bonuses and reductions in attacks and Trainers. Since milestone MV cards leave the discard
  pile (recycling), and `Faithful` has a third clause, `RecycleSafe`, in its present form (after
  milestones M8a and M5): (a) no free recycler (an Item or Supporter effect, or an "as often as you
  like" Ability of a Pokémon or given by a Tool, `Card.freeRec`; not an attack, a once-per-turn or
  on-play Ability, a triggered Ability (milestone M8b), or a Stadium's effect) can return an Item card that writes a bonus or reduction
  (`Card.wAmt`) from a discard pile, and (b) no effect at all can return an Item or Supporter card
  that writes a rest-of-game one (`Card.alAmt`); the
  bound is then per turn (each Item writer played at most once a turn, one Supporter, one
  attack; carried amounts expire within three turns). Without clause 3 the stores are unbounded
  (`Recycle.recycling_breaks_bound`: two Items that return each other and an Iron Defender-like
  Item); "attack twice" or extra turns would break the bound too. Since milestone M8a clause 3
  (a) also covers "as often as you like" Abilities, and a fourth clause, `AbilitySafe`, says that
  no such Ability writes a bonus or reduction and no Ability a rest-of-game one; once-per-turn and
  on-play Abilities may write and recycle, and their uses in one turn are bounded by a potential
  of the player's Pokémon in play and the opponent's Prize cards (`GameState.abPot`). Since
  milestone M5 a fifth clause, `StadiumSafe`, says that no Stadium's effect writes a rest-of-game
  bonus or reduction; a Stadium's once-per-turn effect may otherwise write and recycle, and is paid
  per use through `Card.stQ`, with at most two uses a turn (`GameState.stPot`), in a Stadium term
  of the bound. Each of the five clauses has a negative theorem: without it the stores are
  unbounded (clause 1: `LoopFreeNeeded.iter_writer_breaks_bound`; 2: below; 3:
  `Recycle.recycling_breaks_bound`; 4: `Abilities.unlimited_writer_breaks_bound`; 5:
  `Stadiums.stadium_writer_breaks_bound`). What `Faithful.xfinite` covers is the model: for a
  deck containing a card whose static or triggered text is not modelled (the Stadium and Tool
  item below, static and triggered Abilities), it is a theorem about the inert card the model
  plays, not the printed one. Until milestone M6 the omission that most directly made the model's
  finiteness easier than the real game's was HP modifiers: the clamps capped damage at printed HP,
  and `Settled` forced a Knock Out at printed HP. Since M6 HP is derived (item above): the clamps
  cap damage and Poison strength at a bound `K` on every derived HP (`hpBound`, a function of the
  cards of the game), and `Reach.finite` and `Faithful.xfinite` hold with the clamp at that bound
  (`GameState.xclamp_bisim` is stated at `K = Enum.bound` of the state's cards, and holds at any
  larger `K`, `GameState.xclamp_bisim_of_le`);
  for `Reach.finite` the bound also exceeds every Resistance plus the static damage reductions the
  cards can put in force (`sReduceBound`): unlike a stored reduction, a static one is bounded by the
  cards (`GameState.sReduce_le`), so tame decks may have them. The other static
  omissions are milder: static damage bonuses and reductions, Bench-size and cost changes are
  constants of a card, not stored amounts; Ability and Tool locks only remove behaviour; triggered
  Tools add behaviour. The
  rest-of-game
  modifiers of non-GX attacks give two unbounded counters with an exact zero test, and the model
  simulates every two-counter machine (`Counter.universal`; this rests on the
  over-approximation of rest-of-game modifiers just described, on `damage` read by a test later
  in the same attack, on a printed HP chosen for the machine, and on the other departures listed
  in `Pokemon/Counter.lean`); its start states satisfy `LoopFree`, and violate `GXOnly` when the
  machine's first instruction is not `halt` (`Faithful.counter_not_gxOnly`), so the `GXOnly`
  clause cannot be dropped from `Faithful.xfinite` (`Faithful.dichotomy`, a sharpness result, not
  a classification: nothing is proved about other decks that are not faithful); with Minsky's theorem (prose) this rules out a uniform computable
  finite abstraction of the generalised model; for one such deck the reachable states are not
  finite up to the exact-store clamp, nor up to any equivalence fine enough to recover the
  machine's configuration, a statement about representation, not play
  (`Faithful.xclamp_not_finite`, `Counter.not_finite_up_to`);
* an attack's damage (milestone M4): an attack with a printed base damage and no damage text
  does that damage and then its effect (`Attack.script`); an attack whose text computes or
  conditions its damage has base damage field 0 and one damage step in its effect
  (`damage a`, `drain a`; at most one on each line of resolution, `Effect.oneHit`), whose
  amount `a` is evaluated once when the step is reached ("20 damage plus 10 more for each
  damage counter on the Defending Pokémon", Jynx base1-31, is `damage (add (const 2) (per opp
  1))`; with a reduction of 3 and 3 counters on the target it does (2 + 3) - 3 = 2,
  `Calc.dealtBy_jynx`). Effects before the damage step are the rulebook's "effects that happen
  before damage" (step F); effects after it see the damage placed. The amount language (`Amt`:
  constants, a multiple of the damage counters on either Active Pokémon, sums, truncated
  differences, and the sum of any number of copies, for "flip until tails") has no tests of its
  own: a damage that depends on a test, a coin flip or a choice is written with the damage step
  inside the branches of `ite` or `choice`, which also lets the same flip decide the damage and
  another effect. Since milestone MV the amount may also count cards (`Amt.count`: Energy attached,
  Benched Pokémon, cards in a hand, deck or discard pile, Prize cards left). Not expressible: two
  damage calculations
  in one attack on the Active Pokémon (damage to Benched Pokémon is separate: `benchDamage`,
  `spreadDamage`).
  Generality lost
  against the earlier model: an attack can no longer make several damage steps (an `iter` of
  `damage`, which applied the modifiers per step and is not the rulebook's calculation), and
  Item and Supporter effects can no longer do attack damage (their printed counterparts place
  counters);
* `ite`, `scale`, `selfDamage` and `healAll` are general primitives, usable in any effect,
  any number of times and inside `iter`, whereas printed cards use them once, in fixed forms;
  the model over-approximates the printed texts. The same holds for the Bench primitives of
  milestone M3: `benchCounters`, `spreadCounters`, `benchHeal` and `switch` are usable in any
  effect and inside `iter` (except that an attack has no `switch .own` under `iter`,
  `Effect.switchSafe`), and `benchDamage` and `spreadDamage` in any attack and inside `iter`, so
  `iter (benchDamage .opp n)` in an attack does Bench damage any number of times, which no
  printed card does;
* GX attacks (`Attack.gx`): a player who has used one (`PlayerState.gxUsed`) cannot use another
  in the same game; the flag is set by `Move.attack` (a rule added for `Pokemon/Faithful.lean`;
  before it, `gxUsed` was never read or written). A Confused Pokémon can try a GX attack
  (`attackConfused`) only under the same condition, and a failed attempt (tails) does not use it
  up: whether a failed Confused GX attempt uses up the once-per-game attack is an unverified
  ruling, and the model takes the answer "no"; VSTAR Powers are absent (`vstarUsed` is unused);
* Special Conditions: effects apply them only to the opponent's Active Pokémon (`inflict`) and
  remove them from the player's own Active Pokémon (`cure`) and, since milestone M3, from the
  Pokémon that a switch sends to the Bench, either player's (`switch .own` and `switch .opp`,
  as the rulebook says for any Active Pokémon that goes to the Bench); the variants with a number
  ("put 2 damage counters instead of 1 on the Poisoned Pokémon") are absent; a new Poison
  replaces the old one, as the rulebook says (2023 p. 16, 2024 the same), so poisoning a
  Pokémon that is already Poisoned resets its Poison strength (`poisonUp`) to 0
  (`InPlay.inflict`); Croagunk's cumulative increase is modelled as a number on the Pokémon
  (`poisonUp`) that belongs to the Poisoned Condition: it lasts until Poison ends or is
  replaced, and stacks across uses of the attack, which raises an existing Poison and does not
  re-Poison (that the increase ends when a later attack re-Poisons the Pokémon is the model's
  reading of "replaces"; no ruling on it was found); a Confused Pokémon whose flip is tails
  ends the turn as an attack does (the rulebook: "the attack doesn't happen", p. 16; that the
  failed attempt still ends the turn is the model's reading of the attack steps, p. 20, in
  which the Confusion check is step C of using the attack), and its attack must be one it could
  otherwise use;
* Pokémon Checkup (`InPlay.checkup`, and `BenchChar` on the Benches) covers the five Special
  Conditions (Active Pokémon only, the only ones that can have them) and the Char counter
  only: no Ability (Checkup Abilities, 5 Standard cards in survey S12, are not modelled; milestone
  M8b implemented the two commonest trigger shapes instead),
  Stadium or other "between turns" card effect exists in the model (so the rulebook's
  choice of order between Special Conditions and those effects does not arise); Burn uses the
  current rule (2 counters, then heads cures); Paralysis ends at the Checkup after its
  owner's turn, which is exact here because only the opponent's Pokémon can be Paralyzed;
  coin flips are nondeterministic choices, so the model is silent about probability;
* `poisonUp n` is a general effect primitive, usable in any effect and inside `iter`, whereas
  the printed card (Croagunk) raises Poison strength once per use of its attack; the model
  over-approximates it, and one Item can raise Poison strength without bound
  (`Infinite.not_finite_damageBounded`);
* effects place damage counters on either Active Pokémon (`counters`, `scale` on the
  opponent's, `selfDamage` on the player's own) and, since milestone M3, on one chosen Benched
  Pokémon of either player (`benchCounters`) or on each of a player's Benched Pokémon
  (`spreadCounters`), and since milestone MV2 on `m` distinct chosen Benched Pokémon passing a filter
  (`benchSome`, attack damage or counters; "N damage to 2 of your opponent's Pokémon",
  `Effect.hitSome`; "put N damage counters on your opponent's Pokémon in any way you like",
  `Effect.spreadAny`, each counter on the Active Pokémon when the Bench is empty, proved exact for `Run`,
  the semantics of an attack's effect, from a state with both Active Pokémon: every distribution of the counters is a resolution and nothing else is,
  `Spread.spreadAny_sound`, `Spread.spreadAny_complete`; inside a Trainer effect a Knock Out check
  would follow each counter; `Pokemon/Spread.lean`; absent: spread whose amount the text computes, "for each Energy
  attached to this Pokémon", 7 refused cards in survey S13 §B, a target filtered by its damage, 2,
  moving Energy or counters "in any way you like", 4, and "any number" of attachments); recoil and
  other self-damage are written as damage counters
  (`selfDamage`), not as attack damage, so a printed recoil "This Pokémon also does 30 damage to
  itself" escapes the attacker's own Weakness, Resistance and modifiers in the model; attack
  damage reaches the opponent's Active Pokémon (the damage step, `dealtBy`) and, since M3, Benched
  Pokémon of either player (`benchDamage`, `spreadDamage`: a printed amount, with no Weakness,
  Resistance, bonus, reduction or prevention, and none on a Tera Pokémon; `InPlay.hitBench`;
  amounts computed by the text, "30 damage for each Energy", are not expressible). Dropping the
  modifiers departs from the rulebook in both directions, so Bench damage in the model is not a
  superset of the printed outcomes: the defender's reduction and prevention protect only the
  Active Pokémon here, whereas a printed "all of your Metal Pokémon take 30 less damage" or
  "prevent all damage done to your Benched Pokémon" protects Benched ones too, so the model
  does more damage to the Bench than the rulebook; and the attacker's bonus is not added, on the
  claim that printed bonuses name "your opponent's Active Pokémon", which the rulebook's own
  example of step 2 does not support ("During your next turn, this Pokémon's attacks do 40 more
  damage (before applying Weakness and Resistance)", 2023 p. 20, names no target), so the model
  may do less damage to the Bench than the rulebook. No search of the card pool settles which
  printed bonuses reach the Bench. The damage
  counters an effect places are not affected by Weakness, Resistance or any other effect, as the
  rulebook says (2023 p. 20, step 1);
* `heal` and `healAll` remove damage from the player's own Active Pokémon, and `benchHeal` from
  one of the player's own Benched Pokémon (milestone M3); no effect heals the opponent's
  Pokémon, and none heals each of a player's Benched Pokémon at once ("Heal 20 damage from
  each of your Pokémon" is not expressible exactly);
* switching by effect (`Effect.switch`, milestone M3): the player's own Active Pokémon with one of
  their Benched Pokémon (Switch), or the opponent's ("gust": Boss's Orders, or the opponent's own
  choice; the nondeterministic choice covers whoever chooses); the Pokémon that goes to the Bench
  is cured of its Special Conditions and Poison strength (rulebook 2023 pp. 12, 16). The
  rulebook also ends "any effects from attacks" on it; the model's lingering effects belong to a
  player, not to a Pokémon, so there is nothing more to end (per-Pokémon effects are milestone
  M7). With no Benched Pokémon a switch does nothing. A switch that the rulebook makes a choice
  of a player other than the one the model lets choose is still in the relation. Inside an
  attack the printed game keeps the attacking Pokémon as "this Pokémon" after it is switched
  to the Bench, whereas the model's effects on the player's Active Pokémon act on whichever
  Pokémon is Active; so `Attack.wf` (a premise of `Move.attack` and `Move.attackConfused`)
  requires `Effect.switchSafe`: after a `switch .own`, nothing on the same line of resolution
  reads or writes the player's own Active Pokémon (the damage step, which reads the attacker's
  type for Weakness and Resistance, `drain`, `heal`, `healAll`, `cure`, `selfDamage`,
  `scale .own`, a test on it, another `switch .own`), and no `switch .own` is under `iter`.
  So every damage step of an attack is reached with the attacking Pokémon Active
  (`Attack.attacker_at_hit`), and an attack that switches and then does damage is not playable
  (`Bench.switchThenHit_not_wf`). The restriction excludes nothing printed that the model can
  express: in the card data the 132 distinct attack texts that "Switch this Pokémon with 1 of
  your Benched Pokémon" do their damage first (rulebook 2023 p. 20, step F) and switch after;
  after the switch some act on "this Pokémon" on the Bench (attach Energy, Return Charge
  sv8-68; evolve it, Valiant Evolution sv3-60; inexpressible here), on the opponent (switch,
  lingering modifiers), or on the player (Fluffy Tag bw7-15: "the attacks of that Pokémon do 40
  more damage", a player's bonus here). `mark .own` and `color .own` stay allowed after a
  switch: they choose any of the player's Pokémon, Bench included. Trainer effects have no
  attacker, and their "your Active Pokémon" is whichever is Active, as in the model;
* absent after milestone M3: moving damage counters among the opponent's Pokémon (Gengar-style;
  moving one among the player's own Pokémon, "move 1 damage counter from 1 of your Pokémon to
  another of your Pokémon", Team Rocket's Orbeetle sv10-89, came with milestone M8a as
  `Effect.moveCounter`), tests and counts on Benched Pokémon ("if any
  of your Benched Pokémon have damage counters"), healing the opponent's Pokémon, and Bench damage
  whose amount the text computes. (Putting Pokémon onto the Bench from the deck or discard pile,
  moving Energy between Pokémon, and counts of Benched Pokémon came with milestone MV.) Moving counters among the player's own Pokémon would keep both clamps (the player's
  own damage is exact inside an attack; `CMove.sim`); moving counters off the opponent's Active
  Pokémon would read damage that the capped clamp `rclamp` knows only up to its cap inside an
  attack;
* Bench size is the constant `benchLimit = 5` (milestone M6 did not add a Bench-size static effect:
  a shrinking Bench needs a discard rule, S7 §D) ("Each player may have up to 5 Pokémon on the
  Bench at any one time", rulebook 2023 p. 7); cards that change it (Sky Field, Area Zero
  Underdepths, S8 L2) are static Stadium effects, not modelled (next item but one);
* Stadium and Tool cards (milestone M5; survey S8 B9, B10): a Stadium is played from the hand
  into the one slot both players share (`Move.stadium`: one per turn, `GameState.stadiumPlayed`;
  not while a Stadium of the same name is in play; the Stadium it replaces goes to its owner's
  discard pile), and a Tool is attached from the hand to a Pokémon with no Tool (`Move.tool`,
  `Move.toolBench`; any number per turn; it stays attached and leaves play with the Pokémon).
  A Stadium's "Once during each player's turn, that player may …" effect is used by
  `Move.stadiumUse`. A Tool may give the Pokémon it is attached to attacks and activated Abilities
  (`ToolGrant`, for a holder passing a filter: `InPlay.attacks`, `InPlay.abilities`); a Tool's
  once-per-turn Ability shares the Pokémon's one use flag (`InPlay.used`), so a Pokémon with an
  Ability of its own and one from a Tool uses only one of them in a turn (fewer outcomes than the
  rulebook). For such a holder `Faithful.xfinite` is therefore a theorem about a game with fewer
  outcomes than the printed one; the store bound is not proved for a model with one use flag per
  Ability. Effects discard a Stadium in play (`Effect.discardStadium`) and the Tools of a
  Pokémon (`Effect.discardTools`). Not modelled: the end-of-turn discard of Technical Machine:
  Fluorite sv8-188 ("discard it at the end of your turn"; the model keeps it attached), Tools
  attached to the opponent's Pokémon, more than one Tool on a Pokémon (Rotom ex me2-29 and others
  that raise the limit, S8 B10), and every static and triggered Stadium and Tool effect (next
  item): a Stadium whose effect is `skip` and a Tool with an empty grant (`ToolGrant.none`)
  occupy their place and do nothing, which under-models a printed card with such text;
* static and triggered Stadium and Tool effects (after milestone M5; counts are distinct Standard
  records, regulation marks H–J, read from the card data: 37 Stadiums, 45 Tools). A Stadium or
  Tool with such text is still playable, as a card with no effect (`Card.inert`: a Stadium whose
  effect is `skip`, a Tool with an empty grant): it occupies the slot or the Tool place and does
  nothing, which under-models the printed card (it removes the printed outcomes the text adds and
  keeps the ones it forbids). `Faithful.xfinite` for a deck containing such a card is a theorem
  about the inert card, not the printed one. Since milestone M6 static text in the language of
  `Static` is expressed (`ToolGrant.statics`, the `statics` of a Stadium; `Card.inert` is false
  for such a card): HP changes (Stadiums 3: Ange Floette, Gravity Mountain, Lively Stadium; Tools
  3: Ancient Booster Energy Capsule, Cynthia's Power Weight, Hero's Cape); damage bonuses with a
  filter on the defender (Stadium 1, Postwick; Tools: Hop's Choice Band, Light Ball, Maximum Belt
  and others whose condition is a filter on a top card; Binding Mochi's "if this Pokémon is
  Poisoned" is not expressible; Brave Bangle's conditions are, as the static's filter `noRuleBox`
  on the holder and the bonus filter "Pokémon with a Rule Box" on the defender, which is "Pokémon
  ex" because `RuleBox` has no kind but `ex` and `megaEx`); damage reduction (Stadiums 2: Full
  Metal Lab, Granite Cave; Tools 2: Sacred Charm, Thick Scale; the Berries and Custom Vest are
  triggered or conditional); Retreat Cost changes (Stadiums 2: N's Castle, Paradise Resort; Tools 2:
  Air Balloon, Gravity Gemstone; Rescue Board reads the remaining HP and is not expressible). These
  counts are a regular-expression classification of the card data by kind (milestone M6), not a
  card-by-card check of every condition. Absent kinds, for a later milestone: damage prevention
  (Battle Cage, Neutralization Zone); attack cost changes (Stadium 1, Nighttime Mine; Tools 3: Counter Gain ×2, Sparkling Crystal, and
  Hop's Choice Band); Bench size (Stadiums 2: Area Zero Underdepths ×2); Ability locks ("have no
  Abilities": Stadiums 2, Legendary Pyroduct, Team Rocket's Watchtower); Tool locks (Stadiums 2:
  Jamming Tower ×2); Special Condition rules (Stadiums 3: Dizzying Valley, Festival Grounds ×2;
  Ancient Booster Energy Capsule); evolution timing (Stadium 1, Forest of Vitality); Checkup
  (Stadium 1, Perilous Jungle); and triggered effects (Stadiums 3: Legendary Summit, Legendary
  Trench, Risky Ruins; Tools 18: "If the Pokémon this card is attached to is Knocked Out / is
  damaged by an attack / at the end of your turn …": Adversity Policy, Amulet of Hope, the six
  type Berries, Deluxe Bomb, Handheld Fan, Heavy Baton, Lillie's Pearl, Lucky Helmet, Powerglass,
  Punk Helmet, Survival Brace, Team Rocket's Hypnotizer, Tremendous Bomb). Since milestone M8b
  the Tools of the two implemented trigger shapes are expressible as a triggered Ability given by
  the Tool (5 of the 18: Amulet of Hope, Deluxe Bomb, Handheld Fan as a superset, Lucky Helmet,
  Punk Helmet; Heavy Baton's Retreat Cost condition is not; survey S12 §3); the Berries and
  Survival Brace are replacement effects, Powerglass is an end-of-turn trigger, Lillie's Pearl
  changes Prize cards, Adversity Policy, Tremendous Bomb and Team Rocket's Hypnotizer have
  conditions or filters the model lacks, and the three Stadiums are not modelled either. Activated effects the
  model cannot express exactly: Stadiums 9 (Lumiose City ends the turn; Surfing Beach ×2 and
  Spikemuth Gym need a filter on the Bench or a name prefix; Fossil Quarry benches Items; Grand Tree
  evolves by effect; Mystery Garden draws to a count of Pokémon in play; Community Center and Team
  Rocket's Factory read the turn's history), Tools 2 granting attacks (Technical Machine: Fluorite,
  "heal all damage from each of your Tera Pokémon" and its end-of-turn discard; Mega Rayquaza Cap,
  an attachment per capped Pokémon). Backtrack Badge (re-flip coins) changes nothing in a model in
  which flips are nondeterministic choices. Expressed with effect: Stadiums 3 (Academy at Night,
  Levincia, Prism Tower) and Tool 1 (Core Memory, whose attack goes to a holder named "Mega
  Zygarde ex"). Adventure Lantern me6-90's record carries only an Item-like text and is left
  unclassified. A Stadium's play condition ("only if you discard a Prism Tower in play", Ange
  Floette) and "This card can't be put into your hand or deck from the discard pile"
  (Neutralization Zone) are not modelled either;
* Abilities (milestone M8a): a Pokémon card has a list of Abilities (`PokemonCard.abilities`;
  every Standard Pokémon has at most one, survey S9), each with a use limit, a place, an optional
  printed condition and an effect (`Ability`). Activated Abilities, "once during your turn" (per
  Pokémon in play) and "as often as you like", are used by `Move.ability` during the turn proper,
  before attacking (rulebook 2023 pp. 9, 12), with no Knock Out pending, spending no allowance of
  the turn; on-play Abilities ("When you play this Pokémon from your hand onto your Bench / to
  evolve …, you may") by `Move.onPlay`, after the play. Effects resolve as Trainer effects do
  (`TRun`; the Knock Out timing outside attacks, from the source given above). The use flag is per
  Pokémon (`InPlay.used`), cleared at the end of its owner's turn and by evolution (the evolved
  Pokémon has the new card's Abilities, unused; an evolution line whose two cards print the same
  once-per-turn Ability could use it twice in a turn in the model, a reading no ruling was checked
  for); one flag serves all of a Pokémon's Abilities, exact for cards with one. Departures: "this
  Pokémon" (`SelfOp`) is exact in the Active Spot, but on the Bench it acts on one Benched Pokémon
  chosen when the effect resolves (a superset), and the model does not follow it if it is Knocked
  Out in mid-effect (later steps act on the Pokémon in its place, not a superset) or after a
  switch-in from the Bench (a choice of both places); an on-play Ability does not track "this
  Pokémon" at all, and its `spot` is not read; it is offered only when the play leaves no Knock
  Out pending; per-Pokémon bonuses ("attacks used by this Pokémon do 120 more damage", Feraligatr
  sv5-41) are the player's (per-Pokémon lingering modifiers are milestone M7); a condition is a
  `Test` on an Active Pokémon or a count (conditions on the Bench or on rule boxes, such as "if you
  have any Fire Mega Evolution Pokémon ex in play", are not expressible). Since milestone M6 a
  static Ability (`AbilityUse.static`) carries static effects in the language of `Static` (HP,
  damage bonus and reduction, Retreat Cost; a regular-expression count of today's Standard by kind:
  about 5 HP, 13 bonus, 17 reduction and 11 Retreat Cost Abilities, of which those with conditions
  beyond a top-card filter, a place or an Energy count are not expressible); it is never used.
  Absent: other static (passive) Abilities (immunities, locks, cost changes and the like, about 57
  in today's Standard by the same count), triggered Abilities other than on-play ones and the two
  shapes of milestone M8b (survey S12: Checkup 5, moving between spots 8, attaching Energy 2, the
  opponent's plays 6, end of turn 1, replacement effects 14, Knock Outs of other Pokémon or with
  Prize changes; 44 cards of the 67 after-event triggers are of other shapes), Ability locks
  and "has an Ability" predicates (S8 K4), "once during your first turn" and other activated
  limits (5 in S9), VSTAR Powers, returning a Pokémon in play to the hand or deck by an Ability
  (Abra sv6-80, Dudunsparce sv5-129, Misty's Psyduck sv10-45), and Special Energy (Lycanroc
  sv9-85 attaches Spiky Energy). The finiteness results cover activated and on-play Abilities:
  `Reach.finite` with tame, low-constant Ability effects, `Faithful.xfinite` under clause 4
  (`AbilitySafe`) with clauses 1 and 3 extended to Abilities; `Abilities.unlimited_writer_breaks_bound` and
  `Abilities.unlimited_recycler_breaks_bound` show what clauses 4 and 3 (a) exclude;
* triggered Abilities (milestone M8b; survey S12): two shapes, `TrigEvent.damaged` ("if this
  Pokémon is in the Active Spot and is damaged by an attack from your opponent's Pokémon (even if
  this Pokémon is Knocked Out)") and `TrigEvent.koByAttack` ("if this Pokémon is Knocked Out by
  damage from an attack from your opponent's Pokémon"), on a Pokémon card or given by a Tool,
  mandatory or optional, with an effect in the trigger fragment (`Effect.trigOk`: draw, damage
  counters and a Special Condition on the Attacking Pokémon, zone moves that cannot fail, Tool
  discard). Resolution (see the triggers section above `Move`): from the owner's side on the
  exchanged state (`GameState.swap`), by `Run`, each trigger as a whole, several in any order
  (`List.Perm`: the order of simultaneous triggers is not in the 2023 rulebook, and the 2026 rule
  on who orders them is unverified, S8); `damaged` at the end of the attack, before the Knock Out
  check; `koByAttack` in the batch move, after the batch step. Departures: a trigger's steps get no
  Knock Out check between them (`TRun` checks after each step of a Trainer effect); "the
  Attacking Pokémon" is the opponent's Active Pokémon when the trigger resolves (for a
  `koByAttack` trigger after promotions, so if the attacker was Knocked Out by the same check its
  replacement is hit); "Knocked Out by damage from an attack" is read as "Knocked Out by a check
  while the turn's attack has been made" (Knock Outs by the attack's damage counters and by later
  rounds of the check included); the failed Confused attempt (`Move.attackConfused`) also sets
  `GameState.attacked`, so in the check after it a Knock Out of an opponent's Pokémon fires its
  `koByAttack` triggers though no attack happened (more outcomes than the rulebook; the failed
  attempt damages only the player's own Pokémon, so this needs an opponent's Pokémon brought to its
  HP by a change of derived HP, such as a static HP bonus leaving play with the Confused Pokémon); "is damaged by an attack" is decided on the attack's damage step
  (`HitRun`, `HitTrig`): the triggers of the Pokémon in the opponent's Active Spot at the end of
  the attack fire when the damage step did damage to it while it was in the Active Spot and no
  later step of the attack switched the opponent's Active Pokémon, so
  an attack that only switches the opponent's Active Pokémon fires nothing
  (`TriggerWitness.gust_quiet`) and one that switches and then does damage fires the triggers of the
  Pokémon it damaged (`TriggerWitness.pull_fires`). Two departures remain, one in each direction.
  Fewer outcomes: a Pokémon damaged and then switched to the Bench by the same attack fires
  nothing (`TriggerWitness.hitRun_quiet`), even if a second switch in the same attack brings it
  back to the Active Spot (any later `switch .opp` with a Benched Pokémon clears the flag; no
  printed attack is known to do this); the model reads "if this Pokémon is in the Active Spot
  and is damaged by an attack" as needing the Pokémon in the Active Spot both when it is damaged
  and at the end of the attack, an unverified reading (no ruling was found). More outcomes: when the
  Defending Pokémon is already at or above its derived HP before the damage step (damage counters
  placed earlier by the same attack, or its derived HP lowered earlier in the same attack: a Tool
  with an HP bonus discarded from it, Energy discarded from under a per-Energy HP bonus, an HP
  Stadium discarded), the triggers may fire or not, whatever the step did. This corner was chosen
  so that the capped clamp of `Reach.finite` stays a simulation (`HitRun.cap_sim`); it is wider
  than the case that clamp is blind to (damage at or above the cap), and whether a narrower rule
  would do is not established, nor is it proved that such a defender is always Knocked Out after
  the attack; a
  trigger with a
  printed condition (`cond`) or an effect outside the fragment never fires. The trigger chains end
  (`KOMove.acc`, `Move.unsettled_acc`): every Knock Out takes a Prize card, and nothing returns
  one; with Prize-changing triggers (absent) that argument fails;
* start states are not required to be well formed; from a `WellFormed` start no reachable
  state without a winner is stuck (`Reach.progress`), and since milestone batch-KO no state at all
  is (`Move.exists_move`, with no hypothesis: the batch Knock Out step exists in every state that
  is not `Settled`, `KOBatch.exists_of`); before it, from other starts (e.g. no winner and an
  empty Prize list) a pending Knock Out could be impossible to take. Start states are not required to
  be consistent in their turn flags (`firstTurn` with `curIsFirst` and `hadTurn`; `attacked`
  with `between`): from a start with `firstTurn` true and the player's `hadTurn` already true,
  that player could evolve on the game's first turn. Consistency is `GameState.FlagsOk`
  (`Pokemon/Turn.lean`); play preserves it (`Reach.flagsOk`), and the first-turn bans are
  theorems under it (`Move.firstTurn_no_attack`, `GameState.FlagsOk.firstTurn_no_evolve`);
* zone moves (milestone MV, `Effect.move`, `drawTo`, `attach`, `putBench`, `discardEnergy`,
  `moveEnergy`, semantics `ZStep` lifted by `Run.zone`): cards that pass a filter (`Filter`:
  Pokémon, Basic, Stage, type, name, HP at most `n`, no rule box, Trainer, a Trainer kind, Energy,
  Energy of a type, since milestone MV2 Pokémon ex, Tera, a named printed attack and a printed
  Ability, and Boolean combinations) move between one player's deck (searched, or its
  top `n` cards), hand and discard pile, to the hand, the discard pile, the top or bottom of the
  deck or shuffled into it, "up to `n`", exactly `n` or all of them; Energy is attached from a
  zone to the Active Pokémon or a Benched one, Basic Pokémon are put onto the Bench from a zone,
  Energy is discarded from a Pokémon or moved between a player's Pokémon. Simplifications and
  departures: "up to `n`" allows 0 in every effect (today's rule allows 0 only in attacks, S8
  PP26), a superset; `attach`, `putBench` and `moveEnergy` may always do nothing, a superset of
  "if you can"; a cost ("discard 2 cards from your hand. If you do, …") is `exactly 2`, which has
  no resolution when it cannot be paid, so a Trainer whose cost cannot be paid cannot be played,
  and an attack writes the optional reading with `choice`; one card is attached or benched per
  primitive ("up to 2" is two of them; "to each of your Benched Pokémon" is written as one per
  Pokémon); the player chooses wherever the printed card lets the opponent choose; hidden
  information is not modelled (the state is public, so "reveal" and "look at" are no-ops, and a
  search may take fewer cards than it could, which "up to" already allows); the model resolves a
  played Item or Supporter with the card already in the discard pile (the rulebook: "follow the
  instructions on the card and then discard it", 2023 glossary), so a card can recycle itself in
  the model; clause 3 of `Faithful` constrains that case like any other. For the same reason a
  count of the discard pile read by that Trainer's own effect includes the card itself. Inside an attack nothing
  after a `switch .own` may attach Energy to, discard Energy from or move Energy off the player's
  Active Pokémon (`Effect.ownFree`), and the attacker at a damage step is the same Pokémon (top
  card and the cards under it) as when the attack began, its attached Energy possibly changed
  (`Attack.attacker_at_hit`, restated by milestone MV: before it, the whole card list was kept).
  Absent: returning a Pokémon in play and its cards to the hand or deck (Scoop Up Cyclone, Abra,
  Dudunsparce, Misty's Psyduck in S10), devolution, evolution by effect, switching a card in play
  with one in the discard pile (Transformation Tome, Ogre's Mask), Prize-card moves other than
  taking them, the Lost Zone, and "attach to each of" a varying set;
* one-turn history (milestone MV2, survey S13 §A, `Pokemon/History.lean`): a per-player Knock Out
  record (`KOHist`, read by `Count.koLast`), a per-Pokémon "moved from the Bench to the Active
  Spot this turn" flag (`InPlay.movedUp`, `Test.movedUp`) and "evolved this turn" (`Test.evolved`,
  from `fresh`). Departures: "Knocked Out by damage from an attack" is read as "Knocked Out by the
  check after the turn's attack", so damage counters placed by an attack's effect count too (a
  superset); the failed Confused attempt (`Move.attackConfused`) sets `GameState.attacked` like an
  attack, so if its 3 damage counters bring the confused player's own Active Pokémon to its HP, the
  batch Knock Out step records in that player's history a Knock Out "after an attack"
  (`KOHist.nowAtk`) though no attack happened, and likewise a Knock Out of the attacker's own
  Pokémon by recoil (`selfDamage`) is recorded in its owner's history as after an attack. The flag is read only through the record of the turn in which it was set: during the
  next turn (the opponent's) by `Count.koLast .opp true`, and it is gone by the owner's own next
  turn (`Move.endTurn` shifts it out). Both history shapes the census implements ("if any of your
  Pokémon were Knocked Out [by damage from an attack] during your opponent's last turn") read
  `Count.koLast .own`, the reader's own record of the opponent's turn, so no implemented card
  notices; a card reading `koLast .opp true` would. Knock Outs at Checkup are recorded in no turn
  (Checkup is between turns); a promotion
  after a Knock Out of the player's own Active Pokémon in their own turn does not set `movedUp`
  (an under-model). Absent, with the refused cards of today's Standard that need them (S13 §A;
  cards can need several): "if you played [named, Future, Ancient, Team Rocket] Supporter this
  turn" (7), "if this Pokémon used [attack] during your last turn" (4) and "if 1 of your Pokémon
  used [attack] during your last turn" (3), the per-Pokémon attack lock "during your next turn,
  this Pokémon can't use [attack]" (36 in its own family), "healed this turn" (3), "damaged during
  your opponent's last turn … that much more damage" (2, an amount), next-turn per-Pokémon
  triggers (4), filtered "during this turn" bonuses (4), Prize and Knock Out consequences (8),
  "Prize cards your opponent took during their last turn" (1, the one counted quantity, at most 6),
  and name prefixes ("any of your Ethan's Pokémon", 2 of the 10 Knock Out tests);
* first-turn rules are the rulebook's (2023 pp. 11–13; S8 records no later change): the
  starting player cannot attack or play a Supporter on the first turn of the game
  (`firstTurn`), and neither player can evolve on their own first turn (`hadTurn`); card text
  that lifts these bans ("If you go first, you can use this attack during your first turn",
  Delibird me1-105; 26 Standard cards, survey S9 part 2) is not expressible.
-/

namespace Pokemon

/-- No Knock Out is pending: every Pokémon in play has fewer damage counters than its HP, its
derived HP (`GameState.hpOf`, milestone M6: printed HP changed by the static effects in force in
`g`). Every move except the batch Knock Out step requires it (through `Settled`, or directly). It is NOT
an invariant of all reachable states: an attack or Trainer card can leave a Pokémon at or above
its HP (then the Knock Out must be taken next), and so can Checkup
(`Infinite.endTurn_pending_ko_reachable`), and since milestone M6 so can any move that removes a
source of HP (a Tool discarded, a Stadium replaced, Energy removed, a Pokémon with a static Ability
Knocked Out, a Pokémon moved out of the place its bonus needs); it holds when the turn proper begins
(`Move.damageBounded_of_startTurn`). -/
def DamageBounded (g : GameState) : Prop :=
  ∀ (w : Whose) (sp : Spot) (p : InPlay), g.In w sp p → p.damage < g.hpOf w sp p

/-- `DamageBounded`, place by place. -/
theorem DamageBounded.intro' {g : GameState}
    (h1 : ∀ p, g.cur.active = some p → p.damage < g.hpOf .own .active p)
    (h2 : ∀ p ∈ g.cur.bench, p.damage < g.hpOf .own .bench p)
    (h3 : ∀ p, g.opp.active = some p → p.damage < g.hpOf .opp .active p)
    (h4 : ∀ p ∈ g.opp.bench, p.damage < g.hpOf .opp .bench p) : DamageBounded g := by
  intro w sp p hp
  cases w <;> cases sp
  · exact h1 p hp
  · exact h2 p hp
  · exact h3 p hp
  · exact h4 p hp

/-- `DamageBounded` depends only on the Pokémon in play, the Stadium and who goes first (milestone
M6: derived HP reads them). -/
theorem DamageBounded.congr {g g' : GameState} (h : DamageBounded g)
    (hc : g'.cur.active = g.cur.active) (hcb : g'.cur.bench = g.cur.bench)
    (ho : g'.opp.active = g.opp.active) (hob : g'.opp.bench = g.opp.bench)
    (hs : g'.stadium = g.stadium) (hf : g'.curIsFirst = g.curIsFirst) : DamageBounded g' := by
  have hsf : GameState.SameField g g' :=
    ⟨by simp only [PlayerState.field, hc, hcb], by simp only [PlayerState.field, ho, hob], hs, hf⟩
  intro w sp p hp
  rw [hsf.hpOf w sp rfl]
  cases w <;> cases sp <;> simp only [GameState.In, GameState.side, hc, hcb, ho, hob] at hp <;>
    exact h _ _ p hp

/-- A Benched Pokémon as the rules leave it: with no Special Condition ("When a Pokémon evolves
or moves to the Bench, it recovers from all Special Conditions", rulebook 2023 p. 16) and so with
no Poison strength. Before milestone M3 this also asked that the Pokémon be below its HP; once
Benched Pokémon can be damaged and Knocked Out, a Benched Pokémon at or above its HP is a pending
Knock Out, which `DamageBounded` (and so `Settled`) excludes before every move other than the
batch Knock Out step, as for the Active Pokémon. -/
def Benched (p : InPlay) : Prop :=
  p.rot = .none ∧ p.poisoned = false ∧ p.burned = false ∧ p.poisonUp = 0

/-- Well-formed states: while there is no winner both players have Prize cards left, and
every Benched Pokémon is `Benched` (no Special Condition). `Move` preserves it
(`Move.wellFormed`). Damage on Benched Pokémon below HP is part of `Settled`, not of
`WellFormed`: since milestone M3 an effect or an evolution can leave a Benched Pokémon at or above
its HP, and it is then Knocked Out by the next moves. -/
def WellFormed (g : GameState) : Prop :=
  (g.winner = none → g.cur.prizes ≠ [] ∧ g.opp.prizes ≠ []) ∧
    (∀ p ∈ g.cur.bench, Benched p) ∧ ∀ p ∈ g.opp.bench, Benched p

/-- No Knock Out is pending (no Pokémon in play, Active or Benched, is at or above its HP) and
both Active Spots are filled. Every move except the batch Knock Out step (`Move.knockOuts`)
requires it, so every pending Knock Out is taken, and the Active Pokémon replaced, before any other
move (`Move.batch_of_not_settled`). -/
def Settled (g : GameState) : Prop :=
  DamageBounded g ∧ g.cur.active ≠ none ∧ g.opp.active ≠ none

/-- `Settled` depends only on the Pokémon in play, the Stadium and who goes first. -/
theorem Settled.congr {g g' : GameState} (h : Settled g)
    (hc : g'.cur.active = g.cur.active) (hcb : g'.cur.bench = g.cur.bench)
    (ho : g'.opp.active = g.opp.active) (hob : g'.opp.bench = g.opp.bench)
    (hs : g'.stadium = g.stadium) (hf : g'.curIsFirst = g.curIsFirst) : Settled g' :=
  ⟨h.1.congr hc hcb ho hob hs hf, by rw [hc]; exact h.2.1, by rw [ho]; exact h.2.2⟩

/-! ## The batch Knock Out check

The rulebook checks every Pokémon for a Knock Out at once, takes the Prize cards, decides the
game, and only then has new Active Pokémon chosen. After an attack (2023 p. 14): "Your attack is
complete, so check to see if any Pokémon were Knocked Out by the attack. Some attacks can damage
more than one Pokémon, and sometimes they can even damage the Attacking Pokémon! So, make sure to
check every Pokémon that was affected by the attack. If a Pokémon has total damage at least equal
to its HP (for example, 5 or more damage counters on a Pokémon with 50 HP), it is Knocked Out. If
a player's Pokémon is Knocked Out, that player puts it and all cards attached to it in the discard
pile. That player's opponent takes 1 of their own Prize cards and puts it into their hand. The
player whose Pokémon was Knocked Out chooses a new Active Pokémon from their Bench. If your
opponent can't do this because their Bench is empty (or for any other reason), you win the game!
If your opponent still has Pokémon in play, but you just took your last Prize card, you also win
the game!" After Pokémon Checkup (p. 15): "After both players have gone through these checks, any
Pokémon that has no HP remaining is Knocked Out. (The player moves a new Pokémon into the Active
Spot, and the opponent takes a Prize card.)" Both players at once (p. 21): "You win if you take
your last Prize card or if your opponent has no Benched Pokémon to replace their Active Pokémon if
it is Knocked Out (or otherwise removed from play). This makes it possible for both players to win
at the same time. If this happens, play Sudden Death. However, if you win in both ways and your
opponent wins in only one way, you are the victor!"

`GameState.koStep` is that check: the test `koT` (damage at least the derived HP of the place) is
evaluated once for every Pokémon in play of both players, in the state before any removal; all the
Pokémon it holds for leave play together, each to its owner's discard pile with every card
attached (`PlayerState.koOut`); each player takes as many Prize cards as the Prize values of the
opponent's Knocked Out Pokémon add up to (`PlayerState.koValue`; the top ones, `takePrizes`); and
the outcome is decided by counting each player's ways of winning (`winWays`: the last Prize card
taken, and the opponent left with no Pokémon in play), more ways winning, equal nonzero ways
giving Sudden Death (`Outcome.ofWays`). `KOBatch` then has each player with an empty Active Spot
promote a Benched Pokémon (`Promote`), unless the game is over. -/

/-- The Knock Out test of the check: the Pokémon `p` of the `w` player at `sp` has damage at least
its derived HP in `g`. -/
def GameState.koT (g : GameState) (w : Whose) (sp : Spot) (p : InPlay) : Bool :=
  decide (g.hpOf w sp p ≤ p.damage)

theorem GameState.koT_iff {g : GameState} {w : Whose} {sp : Spot} {p : InPlay} :
    g.koT w sp p = true ↔ g.hpOf w sp p ≤ p.damage :=
  decide_eq_true_iff

/-- Keep an optional Pokémon if it passes `t`. -/
def optFilter (t : InPlay → Bool) : Option InPlay → Option InPlay
  | none => none
  | some p => if t p then some p else none

/-- `t` holds for the optional Pokémon, if there is one. -/
def optAll (t : InPlay → Bool) : Option InPlay → Bool
  | none => true
  | some p => t p

/-- The Prize value of an optional Pokémon (0 if there is none). -/
def optPrizes : Option InPlay → Nat
  | none => 0
  | some p => p.top.prizeCount

/-- The Prize values of the Pokémon of a list, added up. -/
def benchPrizes : List InPlay → Nat
  | [] => 0
  | p :: ps => p.top.prizeCount + benchPrizes ps

/-- The Pokémon of a player that the check Knocks Out (the Active Pokémon if it passes `ta`, the
Benched ones that pass `tb`) leave play together, each with every card attached, to the player's
discard pile; the others stay where they are. -/
def PlayerState.koOut (ta tb : InPlay → Bool) (s : PlayerState) : PlayerState :=
  { s with
    active := optFilter (fun p => !ta p) s.active,
    bench := s.bench.filter (fun p => !tb p),
    discard := optCardList (optFilter ta s.active) ++ benchCardList (s.bench.filter tb) ++
      s.discard }

/-- The Prize cards the opponent takes for the Pokémon the check Knocks Out: their Prize values
added up. -/
def PlayerState.koValue (ta tb : InPlay → Bool) (s : PlayerState) : Nat :=
  optPrizes (optFilter ta s.active) + benchPrizes (s.bench.filter tb)

/-- The player has no Pokémon in play. -/
def PlayerState.noPokemon (s : PlayerState) : Bool := s.active.isNone && s.bench.isEmpty

/-- Taking `n` Prize cards takes the player's last one (and `n` is not 0). -/
def PlayerState.prizeWin (n : Nat) (s : PlayerState) : Bool := (n != 0) && s.prizesOut n

/-- The ways in which a player wins the check (rulebook 2023 p. 21): taking their last Prize card
(`taker` is the player before taking `n`), and leaving the opponent no Pokémon to promote (`other`
is the opponent after the check). 0, 1 or 2. -/
def winWays (n : Nat) (taker other : PlayerState) : Nat :=
  (if taker.prizeWin n then 1 else 0) + (if other.noPokemon then 1 else 0)

/-- The outcome of a check in which the player to move wins in `wc` ways and the opponent in `wo`:
no outcome if neither wins; otherwise the player with more ways wins ("if you win in both ways and
your opponent wins in only one way, you are the victor!"), and equal ways are Sudden Death. -/
def Outcome.ofWays (curIsFirst : Bool) (wc wo : Nat) : Option Outcome :=
  if wc = wo then (if wc = 0 then none else some .suddenDeath)
  else if wo < wc then some (.win curIsFirst) else some (.win !curIsFirst)

/-- The player `w`'s side after the check removes their Knocked Out Pokémon. -/
def GameState.koOf (g : GameState) (w : Whose) : PlayerState :=
  (g.side w).koOut (g.koT w .active) (g.koT w .bench)

/-- The Prize cards the opponent of `w` takes for `w`'s Knocked Out Pokémon. -/
def GameState.koVal (g : GameState) (w : Whose) : Nat :=
  (g.side w).koValue (g.koT w .active) (g.koT w .bench)

/-- **The Knock Out check** (rulebook 2023 pp. 14, 15, 21; quoted above): every Pokémon in play
whose damage is at least its derived HP in `g` is Knocked Out, all together; the player to move
takes `g.koVal .opp` Prize cards and the opponent `g.koVal .own`, the top ones; the game ends if
either player wins (`Outcome.ofWays`; a game already over stays over). Nobody is promoted yet
(`KOBatch`). Before milestone
batch-KO the model took Knock Outs one at a time, in any order, with promotions in between. -/
def GameState.koStep (g : GameState) : GameState :=
  { g with
    cur := ((g.koOf .own).takePrizes (g.koVal .opp)).noteKO
      (!g.between && decide (0 < g.koVal .own)) g.attacked,
    opp := ((g.koOf .opp).takePrizes (g.koVal .own)).noteKO
      (!g.between && decide (0 < g.koVal .opp)) g.attacked,
    winner := match g.winner with
      | none => Outcome.ofWays g.curIsFirst (winWays (g.koVal .opp) g.cur (g.koOf .opp))
          (winWays (g.koVal .own) g.opp (g.koOf .own))
      | some o => some o }

/-- A player with an empty Active Spot promotes one of their Benched Pokémon; a player whose Active
Spot is filled keeps it. `Promote a b a' b'`: the Active Spot and Bench `a`, `b` become `a'`, `b'`. -/
inductive Promote : Option InPlay → List InPlay → Option InPlay → List InPlay → Prop where
  | keep {a : InPlay} {b : List InPlay} : Promote (some a) b (some a) b
  | pick {q : InPlay} {b₁ b₂ : List InPlay} : Promote none (b₁ ++ q :: b₂) (some q) (b₁ ++ b₂)

/-- The state `g` with the Active Spots and Benches replaced. -/
def GameState.withPlay (g : GameState) (ac : Option InPlay) (bc : List InPlay)
    (ao : Option InPlay) (bo : List InPlay) : GameState :=
  { g with cur := { g.cur with active := ac, bench := bc },
           opp := { g.opp with active := ao, bench := bo } }

/-- **The batch Knock Out step.** From a state that is not `Settled` (a Pokémon in play has damage
at least its HP, or an Active Spot is empty), the check `GameState.koStep`; then, if nobody has
won, every player with an empty Active Spot promotes a Benched Pokémon (the result's Active Spots
are filled: a player with no Pokémon left has lost, so the game is over). The promoted Pokémon is
a nondeterministic choice, which covers its owner's. When both players promote, the two choices
are made together: no rule found says who chooses first (the 2023 rulebook says only "The player
whose Pokémon was Knocked Out chooses a new Active Pokémon from their Bench", p. 14), and since
nothing is checked between them every order gives the same states.

The promotions can change derived HP (a Pokémon whose static bonus needs the Bench, or the Active
Spot, has moved), and the check removes Pokémon whose static effects gave HP to others; so after a
batch another Pokémon may be at or above its HP. Then the state is not `Settled`, and another batch
follows, until the state is `Settled` or the game is over: the check repeats. The 2023 rulebook is
silent on this case (it describes one check after the attack and one after Checkup); the repetition
is the model's reading of the rule it already uses for Knock Outs at other times, "Anytime a
Pokémon's remaining HP becomes zero" (Pokémon Asia *Advanced Player's Rulebook*, survey S2; see the
Known gaps). The repetition ends: a batch from a state with a pending Knock Out removes at least
one Pokémon, and a batch from a state with none fills an empty Active Spot, so a batch that does
not end the game lowers twice the number of Pokémon in play plus the number of empty Active Spots
(`KOBatch.koMeasure_lt`); every chain of batches is finite (`KOBatch.acc`) and every state has a
`Resolve` result (`Resolve.exists`), in `Pokemon/Terminate.lean`. -/
inductive KOBatch : GameState → GameState → Prop where
  | won {g : GameState} (hu : ¬ Settled g) (hw : g.koStep.winner ≠ none) : KOBatch g g.koStep
  | go {g : GameState} {ac ao : Option InPlay} {bc bo : List InPlay} (hu : ¬ Settled g)
      (hw : g.koStep.winner = none)
      (hc : Promote g.koStep.cur.active g.koStep.cur.bench ac bc)
      (ho : Promote g.koStep.opp.active g.koStep.opp.bench ao bo) :
      KOBatch g (g.koStep.withPlay ac bc ao bo)

/-- `Settled`, decided. -/
def GameState.settledB (g : GameState) : Bool :=
  g.cur.active.isSome && g.opp.active.isSome &&
    optAll (fun p => !g.koT .own .active p) g.cur.active &&
    g.cur.bench.all (fun p => !g.koT .own .bench p) &&
    optAll (fun p => !g.koT .opp .active p) g.opp.active &&
    g.opp.bench.all (fun p => !g.koT .opp .bench p)

theorem optAll_iff {t : InPlay → Bool} {o : Option InPlay} :
    optAll t o = true ↔ ∀ p, o = some p → t p = true := by
  cases o with
  | none => simp [optAll]
  | some p => simp [optAll]

theorem GameState.settled_iff (g : GameState) : Settled g ↔ g.settledB = true := by
  simp only [settledB, Bool.and_eq_true, List.all_eq_true, optAll_iff, Bool.not_eq_true',
    koT, decide_eq_false_iff_not, Nat.not_le, Option.isSome_iff_ne_none]
  constructor
  · rintro ⟨hk, hc, ho⟩
    exact ⟨⟨⟨⟨⟨hc, ho⟩, fun p hp => hk .own .active p hp⟩, fun p hp => hk .own .bench p hp⟩,
      fun p hp => hk .opp .active p hp⟩, fun p hp => hk .opp .bench p hp⟩
  · rintro ⟨⟨⟨⟨⟨hc, ho⟩, h1⟩, h2⟩, h3⟩, h4⟩
    exact ⟨DamageBounded.intro' h1 h2 h3 h4, hc, ho⟩

instance (g : GameState) : Decidable (Settled g) :=
  decidable_of_iff _ (GameState.settled_iff g).symm

/-- `Resolve g g'`: take every pending Knock Out now. Batch Knock Out steps (`KOBatch`: the check
of every Pokémon in play at once, the Prize cards, the outcome, then the promotions) are made one
after another until the state is `Settled` or the game is over. Stopping earlier is not allowed:
`done` requires one of the two, and no `KOBatch` exists from a `Settled` state. Before milestone
batch-KO the steps were single Knock Outs and promotions (`KOMove`), in any order. -/
inductive Resolve : GameState → GameState → Prop where
  | done {g : GameState} (h : Settled g ∨ g.winner ≠ none) : Resolve g g
  | step {g g₁ g' : GameState} (hn : g.winner = none) (hm : KOBatch g g₁)
      (hr : Resolve g₁ g') : Resolve g g'

/-- **Resolution of a Trainer card's effect**, with the rulebook's Knock Out timing: a Pokémon
whose damage reaches its HP at any time other than during an attack or Checkup is Knocked Out
at once. Each primitive step (`Effect.isPrim`, resolved by one step of `Run`) is followed by
`Resolve`, which takes every Knock Out it caused, gives the Prize card and promotes the
replacement before the next step; the rest of the effect then acts on the new board. Once the
game has a winner the rest of the effect is not resolved (`stop`; `TRun.of_won`: a finished
game is the only result). Tests (`ite`) and primitive steps require that the game is not over.

Design. Of the two candidate semantics, the exact one (Knock Outs forced after every step) was
chosen over a superset (Knock Outs allowed but not forced at every step): the superset would
keep the model's ability to read and heal over-HP damage inside a Trainer effect, which the
printed game lacks, so it would only over-approximate, and its finiteness would have to be
proved anyway for the larger relation; the exact semantics costs no more to prove and makes
the clamp a simulation for whole Trainer effects (`TRun.clamp_sim`). `TRun.guarded` states the
timing: from a state that is `Settled` or finished, every primitive step and every test of a
resolution starts in a `Settled` state, so no step of a Trainer effect is executed while an
Active Pokémon is at or above its HP.

Several Pokémon can reach their HP in one step (`spreadCounters` damages every Benched Pokémon of
a player, milestone M3); `Resolve` takes all of their Knock Outs together, by the batch Knock Out
step, before the next step (`Bench.doubleKO_reachable`). -/
inductive TRun : Effect → GameState → GameState → Prop where
  | prim {e : Effect} {g g₁ g₂ : GameState} (he : e.isPrim = true) (hn : g.winner = none)
      (hr : Run e g g₁) (hk : Resolve g₁ g₂) : TRun e g g₂
  | stop {e : Effect} {g : GameState} (hn : g.winner ≠ none) : TRun e g g
  | iteT {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay} (hn : g.winner = none)
      (h : g.activeOf t.whose = some p) (ht : t.eval g p = true) :
      TRun a g g' → TRun (.ite t a b) g g'
  | iteF {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay} (hn : g.winner = none)
      (h : g.activeOf t.whose = some p) (ht : t.eval g p = false) :
      TRun b g g' → TRun (.ite t a b) g g'
  | seq {a b : Effect} {g₁ g₂ g₃ : GameState} :
      TRun a g₁ g₂ → TRun b g₂ g₃ → TRun (.seq a b) g₁ g₃
  | choiceL {a b : Effect} {g g' : GameState} : TRun a g g' → TRun (.choice a b) g g'
  | choiceR {a b : Effect} {g g' : GameState} : TRun b g g' → TRun (.choice a b) g g'
  | iterNil (a : Effect) (g : GameState) : TRun (.iter a) g g
  | iterCons {a : Effect} {g₁ g₂ g₃ : GameState} :
      TRun a g₁ g₂ → TRun (.iter a) g₂ g₃ → TRun (.iter a) g₁ g₃

/-- Between turns, a Char counter on a Benched Pokémon: its owner flips a coin, and on tails the
Pokémon gets 2 damage counters (Quilava neo1-47; the card text does not restrict the Char counter
to the Active Spot, and since milestone M3 the model applies it on the Bench too, as Checkup
applies it to the Active Pokémon, `InPlay.checkup`). `keep` is heads, or no Char counter. -/
inductive CharStep : InPlay → InPlay → Prop where
  | keep (p : InPlay) : CharStep p p
  | burn {p : InPlay} (h : p.marks.char = true) : CharStep p (p.addDamage 2)

/-- `CharStep` on every Pokémon of a Bench, each with its own coin flip. -/
inductive BenchChar : List InPlay → List InPlay → Prop where
  | nil : BenchChar [] []
  | cons {p p' : InPlay} {b b' : List InPlay} :
      CharStep p p' → BenchChar b b' → BenchChar (p :: b) (p' :: b')

/-- Every Bench has a Char step: all coins heads. -/
theorem BenchChar.refl : ∀ b : List InPlay, BenchChar b b
  | [] => .nil
  | p :: ps => .cons (.keep p) (BenchChar.refl ps)

/-- `UseAt g x sp g'` (milestone M8a): the player's Pokémon `x`, at `sp` (the Active Spot, or a
place on the Bench), uses an Ability; `g'` is `g` with `x` marked as having used an Ability this
turn (`InPlay.markUsed`), and nothing else changed. -/
inductive UseAt : GameState → InPlay → Spot → GameState → Prop where
  | active {g : GameState} {x : InPlay} (ha : g.cur.active = some x) :
      UseAt g x .active { g with cur := { g.cur with active := some x.markUsed } }
  | bench {g : GameState} {x : InPlay} {b₁ b₂ : List InPlay} (hb : g.cur.bench = b₁ ++ x :: b₂) :
      UseAt g x .bench { g with cur := { g.cur with bench := b₁ ++ x.markUsed :: b₂ } }

/-- `PlayFromHand g x w g'` (milestone M8a): the player plays a Pokémon card from the hand, onto
the Bench as a Basic Pokémon (`w = .bench`) or to evolve the Active Pokémon or a Benched one
(`w = .evolve`), with exactly the premises and result of `Move.playBasic`, `Move.evolve` and
`Move.evolveBench` (`PlayFromHand.move`); `x` is the Pokémon in play that the card now tops. The
on-play trigger of an Ability (`Move.onPlay`) follows such a play. -/
inductive PlayFromHand : GameState → InPlay → PlayWay → GameState → Prop where
  | basic {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂)
      (hs : p.stage = .basic) (hhp : 0 < p.hp)
      (hb : g.cur.bench.length < benchLimit) (hbt : g.between = false) (hst : Settled g)
      (hat : g.attacked = false) :
      PlayFromHand g (InPlay.ofBasic p) .bench { g with cur := { g.cur with
        hand := l₁ ++ l₂, bench := g.cur.bench ++ [InPlay.ofBasic p] } }
  | evolve {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (ha : g.cur.active = some a)
      (he : p.evolvesFrom = some a.top.name) (hfr : a.fresh = false)
      (hf : g.cur.hadTurn = true) (hbt : g.between = false) (hst : Settled g)
      (hat : g.attacked = false) :
      PlayFromHand g { a with
          top := p, under := Card.pokemon a.top :: a.under,
          rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true,
          used := false } .evolve
        { g with cur := { g.cur with
          hand := l₁ ++ l₂,
          active := some { a with
            top := p, under := Card.pokemon a.top :: a.under,
            rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true,
            used := false } } }
  | evolveBench {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard} {q : InPlay}
      {b₁ b₂ : List InPlay}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (hb : g.cur.bench = b₁ ++ q :: b₂)
      (he : p.evolvesFrom = some q.top.name) (hfr : q.fresh = false)
      (hf : g.cur.hadTurn = true) (hbt : g.between = false) (hst : Settled g)
      (hat : g.attacked = false) :
      PlayFromHand g { q with
          top := p, under := Card.pokemon q.top :: q.under,
          rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true,
          used := false } .evolve
        { g with cur := { g.cur with
          hand := l₁ ++ l₂,
          bench := b₁ ++ { q with
            top := p, under := Card.pokemon q.top :: q.under,
            rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true,
            used := false } :: b₂ } }

/-- Does an on-play trigger printed as `w` fire on a play of kind `how`? -/
def PlayWay.fires : PlayWay → PlayWay → Bool
  | .either, _ => true
  | .bench, .bench => true
  | .evolve, .evolve => true
  | _, _ => false

/-- The printed condition of an Ability holds (milestone M8a): none, or its test holds on the
Active Pokémon the test reads (a count test reads the state). -/
def Ability.CondOk (ab : Ability) (g : GameState) : Prop :=
  match ab.cond with
  | none => True
  | some t => ∃ p, g.activeOf t.whose = some p ∧ t.eval g p = true

/-! ## Triggered Abilities (milestone M8b)

Two shapes, the commonest of today's Standard (survey S12): "if this Pokémon is in the Active Spot
and is damaged by an attack from your opponent's Pokémon (even if this Pokémon is Knocked Out), …"
(`TrigEvent.damaged`) and "if this Pokémon is Knocked Out by damage from an attack from your
opponent's Pokémon, …" (`TrigEvent.koByAttack`). Both belong to the player whose turn it is not, so
their effects resolve from that player's side: on the state with the players exchanged
(`GameState.swap`), by `Run`, and the result exchanged back (`Fire`).

When they resolve. A `damaged` trigger resolves at the end of the attack, after the attack's
script and before the Knock Out check (`Move.attack`, `HitTrig`): "even if this Pokémon is Knocked
Out" means the Pokémon is still there when it resolves, and Knock Outs it causes (damage counters on
the Attacking Pokémon) are taken by the one check after the attack, together with the attack's own
(a double Knock Out, `TriggerWitness`). A `koByAttack` trigger resolves in the Knock Out check after
the attack (`Move.knockOuts`): after the batch step (removal, Prize cards, outcome, promotions), so
the Pokémon and its cards are in the discard pile, as printed effects need ("put it into your hand
instead of the discard pile" is the one that would need otherwise, and is not expressible). It
fires for every Pokémon of the opponent of the player to move that a batch Knocks Out while the
turn's attack has been made (`GameState.attacked`), and only if the game goes on. The Knock Outs its
effect causes are taken by the next batch: the check repeats.

Order. Several triggers fire at once (several Pokémon Knocked Out by one check; a Pokémon and its
Tool). The 2023 rulebook says nothing about their order, and the 2026 rule on who orders
simultaneous triggers (survey S8) is unverified; the model resolves them one after another in any
order (`List.Perm`, a nondeterministic choice that covers whoever orders them), each as a whole.

Departures (Known gaps): a trigger's effect resolves as a whole, by `Run`, with the Knock Out check
after it, not after each of its steps as for a Trainer card (`TRun`); the effects of the fragment
read no damage (`Effect.trigOk`), so the only difference is that a later step can still act on a
Pokémon an earlier step brought to its HP, which is what a printed sentence that is one effect does.
"The Attacking Pokémon" is the opponent's Active Pokémon when the trigger resolves: for a
`koByAttack` trigger after the promotions, so if the attacker was Knocked Out by the same check, the
trigger acts on its replacement instead of on nothing. "Knocked Out by damage from an attack" is
read as "Knocked Out by a check while the turn's attack has been made": it includes Knock Outs by
damage counters the attack placed and by later rounds of the check. "Is damaged by an attack" is
decided on the damage step (`HitRun`), with the reading and the corner listed in the Known gaps. -/

/-- The state as the opponent sees it: the two players exchanged (milestone M8b). Effects of the
language act for the player to move (`.own`); a trigger of the other player resolves on the
exchanged state. -/
def GameState.swap (g : GameState) : GameState :=
  { g with cur := g.opp, opp := g.cur, curIsFirst := !g.curIsFirst }

@[simp] theorem GameState.swap_swap (g : GameState) : g.swap.swap = g := by
  cases g; simp only [GameState.swap, Bool.not_not]

/-- The triggered Abilities of a Pokémon in play at `sp` that fire on `ev` (`Ability.trigOn`), its
own and those its Tools give it (`InPlay.abilities`). -/
def InPlay.trigs (ev : TrigEvent) (sp : Spot) (p : InPlay) : List Ability :=
  p.abilities.filter (Ability.trigOn ev sp)

/-- The `ev` triggers of an optional Pokémon in the Active Spot. -/
def optTrigs (ev : TrigEvent) : Option InPlay → List Ability
  | none => []
  | some p => p.trigs ev .active

/-- **Resolving triggers** (milestone M8b): the triggers `l` of the opponent of the player to move,
one after another, each with "this Pokémon" where the event leaves it (`TrigEvent.place`): its effect
resolves on the exchanged state (`GameState.swap`) by `Run`, as a whole, and the state is exchanged
back; an optional one (`AbilityUse.optional`, "you may") may be declined instead. -/
inductive Fire (ev : TrigEvent) : List Ability → GameState → GameState → Prop where
  | nil (g : GameState) : Fire ev [] g g
  | run {ab : Ability} {l : List Ability} {g g₁ g₂ : GameState}
      (hk : (ab.script ev.place).trigOk = true)
      (hr : Run (ab.script ev.place) g.swap g₁) (ht : Fire ev l g₁.swap g₂) :
      Fire ev (ab :: l) g g₂
  | decline {ab : Ability} {l : List Ability} {g g₂ : GameState}
      (ho : ab.use.optional = true) (ht : Fire ev l g g₂) : Fire ev (ab :: l) g g₂

/-- Did the opponent's Active Pokémon's damage rise from `g` to `g'`? Read on one damage step
(`HitRun.hit`), where the opponent's Active Pokémon is the same Pokémon before and after. -/
def GameState.damagedB (g g' : GameState) : Bool :=
  match g.opp.active, g'.opp.active with
  | some d, some d' => decide (d.damage < d'.damage)
  | _, _ => false

/-- A primitive effect that neither does attack damage to the opponent's Active Pokémon nor
replaces it (milestone M8b): every primitive but the damage steps (`damage`, `drain`) and
`switch .opp`; not the compound effects. -/
def Effect.plain : Effect → Bool
  | .damage _ => false
  | .drain _ => false
  | .switch .opp => false
  | .ite .. => false
  | .seq .. => false
  | .choice .. => false
  | .iter .. => false
  | _ => true

/-- The damage steps. -/
def Effect.isHit : Effect → Bool
  | .damage _ => true
  | .drain _ => true
  | _ => false

/-- **A resolution of an effect, with what it did to the opponent's Active Pokémon** (milestone
M8b). `HitRun e g g' hit sw`: `Run e g g'` along one line of resolution, where `sw` says whether a
`switch .opp` replaced the opponent's Active Pokémon (its Bench was not empty), and `hit` whether a
damage step did damage to the opponent's Active Pokémon and no `switch .opp` replaced it after
that step. So `hit` is "the Pokémon in the opponent's Active Spot after the attack was damaged by
it, while in the Active Spot". It is read on the damage step itself (`hit`): the defender is the
opponent's Active Pokémon at that step, and the damage done is the rise of its damage over the
step (`GameState.damagedB` on the step), which is `GameState.dealt` of the amount. One corner is
left free: when the defender is already at or above its derived HP before the step (counters
placed earlier in the same attack, or its derived HP lowered earlier in the same attack), `hit`
may be either value. (This keeps the capped clamp of the tame decks a simulation,
`HitRun.cap_sim`; the corner is wider than the case that clamp is blind to, and whether a narrower
rule would do is not established.) In `seq`, any later `switch .opp` with a Benched Pokémon
clears the flag, even if a further switch brings the damaged Pokémon back. -/
inductive HitRun : Effect → GameState → GameState → Bool → Bool → Prop where
  | plain {e : Effect} {g g' : GameState} (he : e.plain = true) (h : Run e g g') :
      HitRun e g g' false false
  | hit {e : Effect} {g g' : GameState} {p : InPlay} {b : Bool} (he : e.isHit = true)
      (h : Run e g g') (hp : g.opp.active = some p)
      (hb : p.damage < g.hpOf .opp .active p → b = g.damagedB g') : HitRun e g g' b false
  | gust {g g' : GameState} (h : Run (.switch .opp) g g') :
      HitRun (.switch .opp) g g' false (decide (0 < g.opp.bench.length))
  | iteT {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay} {hb sw : Bool}
      (h : g.activeOf t.whose = some p) (ht : t.eval g p = true) :
      HitRun a g g' hb sw → HitRun (.ite t a b) g g' hb sw
  | iteF {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay} {hb sw : Bool}
      (h : g.activeOf t.whose = some p) (ht : t.eval g p = false) :
      HitRun b g g' hb sw → HitRun (.ite t a b) g g' hb sw
  | seq {a b : Effect} {g₁ g₂ g₃ : GameState} {h₁ s₁ h₂ s₂ : Bool} :
      HitRun a g₁ g₂ h₁ s₁ → HitRun b g₂ g₃ h₂ s₂ →
        HitRun (.seq a b) g₁ g₃ ((h₁ && !s₂) || h₂) (s₁ || s₂)
  | choiceL {a b : Effect} {g g' : GameState} {hb sw : Bool} :
      HitRun a g g' hb sw → HitRun (.choice a b) g g' hb sw
  | choiceR {a b : Effect} {g g' : GameState} {hb sw : Bool} :
      HitRun b g g' hb sw → HitRun (.choice a b) g g' hb sw
  | iterNil (a : Effect) (g : GameState) : HitRun (.iter a) g g false false
  | iterCons {a : Effect} {g₁ g₂ g₃ : GameState} {h₁ s₁ h₂ s₂ : Bool} :
      HitRun a g₁ g₂ h₁ s₁ → HitRun (.iter a) g₂ g₃ h₂ s₂ →
        HitRun (.iter a) g₁ g₃ ((h₁ && !s₂) || h₂) (s₁ || s₂)

/-- A `HitRun` is a resolution. -/
theorem HitRun.run {e : Effect} {g g' : GameState} {hb sw : Bool} (h : HitRun e g g' hb sw) :
    Run e g g' := by
  induction h with
  | plain _ h => exact h
  | hit _ h => exact h
  | gust h => exact h
  | iteT h ht _ ih => exact .iteT h ht ih
  | iteF h ht _ ih => exact .iteF h ht ih
  | seq _ _ ih₁ ih₂ => exact .seq ih₁ ih₂
  | choiceL _ ih => exact .choiceL ih
  | choiceR _ ih => exact .choiceR ih
  | iterNil a g => exact .iterNil a g
  | iterCons _ _ ih₁ ih₂ => exact .iterCons ih₁ ih₂

/-- Every resolution is a `HitRun`, with some flags. -/
theorem Run.hitRun {e : Effect} {g g' : GameState} (h : Run e g g') :
    ∃ hb sw, HitRun e g g' hb sw := by
  induction h with
  | iteT h ht _ ih => obtain ⟨a, b, r⟩ := ih; exact ⟨a, b, .iteT h ht r⟩
  | iteF h ht _ ih => obtain ⟨a, b, r⟩ := ih; exact ⟨a, b, .iteF h ht r⟩
  | seq _ _ ih₁ ih₂ =>
      obtain ⟨a, b, r⟩ := ih₁; obtain ⟨c, d, s⟩ := ih₂; exact ⟨_, _, .seq r s⟩
  | choiceL _ ih => obtain ⟨a, b, r⟩ := ih; exact ⟨a, b, .choiceL r⟩
  | choiceR _ ih => obtain ⟨a, b, r⟩ := ih; exact ⟨a, b, .choiceR r⟩
  | iterNil a g => exact ⟨_, _, .iterNil a g⟩
  | iterCons _ _ ih₁ ih₂ =>
      obtain ⟨a, b, r⟩ := ih₁; obtain ⟨c, d, s⟩ := ih₂; exact ⟨_, _, .iterCons r s⟩
  | damage hv h => exact ⟨_, _, .hit rfl (.damage hv h) h (fun _ => rfl)⟩
  | drain hv h hq => exact ⟨_, _, .hit rfl (.drain hv h hq) h (fun _ => rfl)⟩
  | switch w ha hb =>
      cases w with
      | own => exact ⟨_, _, .plain rfl (.switch .own ha hb)⟩
      | opp => exact ⟨_, _, .gust (.switch .opp ha hb)⟩
  | switchNone w hb =>
      cases w with
      | own => exact ⟨_, _, .plain rfl (.switchNone .own hb)⟩
      | opp => exact ⟨_, _, .gust (.switchNone .opp hb)⟩
  | @touchActive e w f g p he h =>
      exact ⟨_, _, .plain (by cases e <;> simp_all [Effect.touch, Effect.plain]) (.touchActive he h)⟩
  | @touchBench e w f g q b₁ b₂ he h =>
      exact ⟨_, _, .plain (by cases e <;> simp_all [Effect.touch, Effect.plain]) (.touchBench he h)⟩
  | @zone e w g s' hw h =>
      exact ⟨_, _, .plain (by cases e <;> simp_all [Effect.zSide, Effect.plain]) (.zone hw h)⟩
  | skip g => exact ⟨_, _, .plain rfl (.skip g)⟩
  | draw h => exact ⟨_, _, .plain rfl (.draw h)⟩
  | drawEmpty h => exact ⟨_, _, .plain rfl (.drawEmpty h)⟩
  | heal n h => exact ⟨_, _, .plain rfl (.heal n h)⟩
  | counters n h => exact ⟨_, _, .plain rfl (.counters n h)⟩
  | inflict c h => exact ⟨_, _, .plain rfl (.inflict c h)⟩
  | poisonUp n h hp => exact ⟨_, _, .plain rfl (.poisonUp n h hp)⟩
  | poisonUpSkip n h hp => exact ⟨_, _, .plain rfl (.poisonUpSkip n h hp)⟩
  | cure h => exact ⟨_, _, .plain rfl (.cure h)⟩
  | shuffle h => exact ⟨_, _, .plain rfl (.shuffle h)⟩
  | search h => exact ⟨_, _, .plain rfl (.search h)⟩
  | handToBottom h => exact ⟨_, _, .plain rfl (.handToBottom h)⟩
  | scale w k hs h => exact ⟨_, _, .plain rfl (.scale w k hs h)⟩
  | selfDamage n h => exact ⟨_, _, .plain rfl (.selfDamage n h)⟩
  | healAll h => exact ⟨_, _, .plain rfl (.healAll h)⟩
  | unmark w m g => exact ⟨_, _, .plain rfl (.unmark w m g)⟩
  | linger w s m g => exact ⟨_, _, .plain rfl (.linger w s m g)⟩
  | benchCounters w n h => exact ⟨_, _, .plain rfl (.benchCounters w n h)⟩
  | benchCountersNone w n h => exact ⟨_, _, .plain rfl (.benchCountersNone w n h)⟩
  | spreadCounters w n g => exact ⟨_, _, .plain rfl (.spreadCounters w n g)⟩
  | benchHeal n h => exact ⟨_, _, .plain rfl (.benchHeal n h)⟩
  | benchHealNone n h => exact ⟨_, _, .plain rfl (.benchHealNone n h)⟩
  | benchDamage w n h => exact ⟨_, _, .plain rfl (.benchDamage w n h)⟩
  | benchDamageNone w n h => exact ⟨_, _, .plain rfl (.benchDamageNone w n h)⟩
  | spreadDamage w n g => exact ⟨_, _, .plain rfl (.spreadDamage w n g)⟩
  | benchSome w m f dmg n h => exact ⟨_, _, .plain rfl (.benchSome w m f dmg n h)⟩
  | moveCounter h => exact ⟨_, _, .plain rfl (.moveCounter h)⟩
  | discardStadium g => exact ⟨_, _, .plain rfl (.discardStadium g)⟩

/-- **Which `damaged` triggers an attack fires** (milestone M8b), from the state `g` before its
script and `g'` after it: none (`quiet`), or every `damaged` trigger of the opponent's Active
Pokémon in some order (`fire`). Each is allowed for the resolutions of the script from `g` to `g'`
that agree with it (`HitRun`): `fire` for one in which the Pokémon in the opponent's Active Spot at
the end was damaged by the attack's damage step while in the Active Spot, `quiet` for one in which
it was not. So an attack that only switches the opponent's Active Pokémon fires nothing
(`TriggerWitness.gust_quiet`), one that switches and then does damage fires the triggers of the
Pokémon it damaged (`TriggerWitness.pull_fires`), and a Pokémon damaged and then switched to the
Bench by the same attack fires nothing: the model reads "if this Pokémon is in the Active Spot and
is damaged by an attack" as needing the Pokémon in the Active Spot both when it is damaged and when
the trigger resolves, at the end of the attack (an unverified reading; Known gaps). The choice is
determined by the resolution, with two exceptions: when the defender was already at or above its
HP before the damage step, either is allowed (`HitRun.hit`); and a Pokémon switched out after
the damage step fires nothing even if the same attack switches it back. Two resolutions with the same end state are told
apart only by what they did: the model's outcomes are the union, over the resolutions, of the
printed ones. -/
inductive HitTrig (atk : Attack) (g g' : GameState) : List Ability → Prop where
  | quiet {sw : Bool} (h : HitRun atk.script g g' false sw) : HitTrig atk g g' []
  | fire {l : List Ability} {sw : Bool} (h : HitRun atk.script g g' true sw)
      (hl : l.Perm (optTrigs .damaged g'.opp.active)) : HitTrig atk g g' l

/-- The resolution an attack's choice of triggers rests on. -/
theorem HitTrig.run {atk : Attack} {g g' : GameState} {l : List Ability}
    (h : HitTrig atk g g' l) : Run atk.script g g' := by
  cases h with
  | quiet h => exact h.run
  | fire h _ => exact h.run

/-- The `koByAttack` triggers of the opponent's Pokémon that the check of `g` Knocks Out. -/
def GameState.koTrigs (g : GameState) : List Ability :=
  optTrigs .koByAttack (optFilter (g.koT .opp .active) g.opp.active) ++
    (g.opp.bench.filter (g.koT .opp .bench)).flatMap (InPlay.trigs .koByAttack .bench)

/-- The triggers a batch Knock Out step from `g` to `g₁` fires (milestone M8b): the `koByAttack`
triggers of the Pokémon of the opponent it Knocks Out, if the turn's attack has been made and the
game goes on; none otherwise. -/
def GameState.batchTrigs (g g₁ : GameState) : List Ability :=
  if g.attacked && g₁.winner.isNone then g.koTrigs else []

inductive Move : GameState → GameState → Prop where
  /-- put a Basic Pokémon from hand onto the Bench -/
  | playBasic {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂)
      (hs : p.stage = .basic) (hhp : 0 < p.hp)
      (hb : g.cur.bench.length < benchLimit) (hbt : g.between = false) (hst : Settled g)
      (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, bench := g.cur.bench ++ [InPlay.ofBasic p] } }
  /-- attach one Energy card from hand to the Active Pokémon, once per turn -/
  | attach {g : GameState} {l₁ l₂ : List Card} {t : BasicEnergy} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.energy t :: l₂)
      (hf : g.cur.energyAttached = false) (ha : g.cur.active = some a)
      (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, energyAttached := true,
        active := some { a with energy := Card.energy t :: a.energy } } }
  /-- evolve the Active Pokémon; Special Conditions are removed. Not a Pokémon put into play or
  evolved this turn (`fresh`: "Neither player can evolve a Pokémon on its first turn in play",
  "you can't evolve it a second time the same turn"), and not on the player's own first turn
  (`hadTurn`: "neither player can evolve a Pokémon on that player's first turn unless a card
  says so"; rulebook 2023 p. 11) -/
  | evolve {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (ha : g.cur.active = some a)
      (he : p.evolvesFrom = some a.top.name) (hfr : a.fresh = false)
      (hf : g.cur.hadTurn = true) (hbt : g.between = false) (hst : Settled g)
      (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂,
        active := some { a with
          top := p, under := Card.pokemon a.top :: a.under,
          rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true,
          used := false } } }
  /-- attach one Energy card from hand to one of the player's Benched Pokémon; the same
  once-per-turn attachment as `attach` ("Take an Energy card from your hand and put it under your
  Active Pokémon or one of your Benched Pokémon … You can attach Energy just once each turn!",
  rulebook 2023 p. 11; milestone M3) -/
  | attachBench {g : GameState} {l₁ l₂ : List Card} {t : BasicEnergy} {q : InPlay}
      {b₁ b₂ : List InPlay}
      (hh : g.cur.hand = l₁ ++ Card.energy t :: l₂)
      (hf : g.cur.energyAttached = false) (hb : g.cur.bench = b₁ ++ q :: b₂)
      (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, energyAttached := true,
        bench := b₁ ++ { q with energy := Card.energy t :: q.energy } :: b₂ } }
  /-- evolve one of the player's Benched Pokémon ("You can evolve any Pokémon you have in play,
  whether it's Active or Benched", rulebook 2023 p. 11; milestone M3), with the premises of
  `evolve`; Special Conditions are removed (a Benched Pokémon has none) -/
  | evolveBench {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard} {q : InPlay}
      {b₁ b₂ : List InPlay}
      (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (hb : g.cur.bench = b₁ ++ q :: b₂)
      (he : p.evolvesFrom = some q.top.name) (hfr : q.fresh = false)
      (hf : g.cur.hadTurn = true) (hbt : g.between = false) (hst : Settled g)
      (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂,
        bench := b₁ ++ { q with
          top := p, under := Card.pokemon q.top :: q.under,
          rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true,
          used := false } :: b₂ } }
  /-- retreat: discard Energy equal to the retreat cost and swap with a Benched Pokémon -/
  | retreat {g : GameState} {a q : InPlay} {b₁ b₂ : List InPlay} {paid rest : List Card}
      (ha : g.cur.active = some a) (hb : g.cur.bench = b₁ ++ q :: b₂)
      (hr : g.cur.retreated = false) (he : a.energy = paid ++ rest)
      (hp : paid.length = g.retreatOf a)
      (hs : a.rot.canAct = true) (hbt : g.between = false) (hst : Settled g)
      (hl : g.cur.mods.live.noRetreat = false) (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        active := some q.moveUp,
        bench := b₁ ++ { a with
          energy := rest, rot := .none, poisoned := false, burned := false, poisonUp := 0 } :: b₂,
        discard := paid ++ g.cur.discard, retreated := true } }
  /-- play an Item card: it goes to the discard pile and its effect resolves, with Knock Outs
  taken at once in mid-effect (`TRun`); not while an Item lock is in effect. Its effect has no
  attack damage step (`Effect.hitFree`): Trainer cards place damage counters -/
  | item {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .item e :: l₂) (hbt : g.between = false)
      (hst : Settled g)
      (hr : TRun e { g with cur := { g.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } g')
      (hl : g.cur.mods.live.noItem = false) (hat : g.attacked = false)
      (hnd : e.hitFree = true) (hbh : e.benchHitFree = true) :
      Move g g'
  /-- play a Supporter card, once per turn, and not on the first turn of the game ("The player
  who goes first cannot play a Supporter card on their first turn", rulebook 2023 p. 12); its
  effect resolves as an Item's does (`TRun`), and has no attack damage step -/
  | supporter {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .supporter e :: l₂)
      (hs : g.cur.supporterPlayed = false) (hbt : g.between = false) (hst : Settled g)
      (hr : TRun e { g with cur := { g.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g.cur.discard } } g')
      (hat : g.attacked = false) (hf : g.firstTurn = false) (hnd : e.hitFree = true)
      (hbh : e.benchHitFree = true) :
      Move g g'
  /-- play a Stadium card (milestone M5): "You can play only one Stadium card each turn", "You
  can't play a Stadium card if a Stadium with the same name is already in play", "Only one Stadium
  can be in play at a time—if a new one comes into play, discard the old one and end its effects",
  and "it stays in play" (rulebook 2023 p. 12). The Stadium goes to the shared slot with its owner
  (the player to move); the one it replaces, if any, goes to its owner's discard pile, whoever
  that is (`stadiumTo`). Played during the turn proper, before attacking, with no Knock Out
  pending, like an Item; an Item lock does not stop it (a Stadium is not an Item). Playing it
  resolves nothing: its effect is used by `Move.stadiumUse`, and the new Stadium has not been
  used this turn (`stadiumUsed := false`) -/
  | stadium {g : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect} {ss : List Static}
      (hh : g.cur.hand = l₁ ++ Card.trainer n .stadium e ss :: l₂)
      (hs : g.stadiumPlayed = false) (hn : g.stadiumNamed n = false)
      (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false) :
      Move g { g with
        cur := { g.cur with
          hand := l₁ ++ l₂, discard := stadiumTo g.curIsFirst g.stadium ++ g.cur.discard },
        opp := { g.opp with discard := stadiumTo (!g.curIsFirst) g.stadium ++ g.opp.discard },
        stadium := some (g.curIsFirst, Card.trainer n .stadium e ss),
        stadiumPlayed := true, stadiumUsed := false }
  /-- attach a Pokémon Tool from the hand to the player's Active Pokémon (milestone M5), which must
  have no Tool attached ("Each Pokémon can have only 1 Pokémon Tool attached at a time", rulebook
  2023 glossary p. 40; printed on the cards: "You may attach any number of Pokémon Tools to your
  Pokémon during your turn. You may attach only 1 Pokémon Tool to each Pokémon, and it stays
  attached"). Any number per turn; during the turn proper, before attacking, with no Knock Out
  pending; an Item lock does not stop it. The Tool stays attached through evolution and retreat
  and goes to the discard pile with the Pokémon (`InPlay.cardList`) -/
  | tool {g : GameState} {l₁ l₂ : List Card} {n : String} {gr : ToolGrant} {a : InPlay}
      (hh : g.cur.hand = l₁ ++ Card.tool n gr :: l₂) (ha : g.cur.active = some a)
      (ht : a.tools = []) (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, active := some { a with tools := [Card.tool n gr] } } }
  /-- attach a Pokémon Tool from the hand to one of the player's Benched Pokémon that has no Tool
  attached (milestone M5), as `tool` -/
  | toolBench {g : GameState} {l₁ l₂ : List Card} {n : String} {gr : ToolGrant} {q : InPlay}
      {b₁ b₂ : List InPlay}
      (hh : g.cur.hand = l₁ ++ Card.tool n gr :: l₂) (hb : g.cur.bench = b₁ ++ q :: b₂)
      (ht : q.tools = []) (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false) :
      Move g { g with cur := { g.cur with
        hand := l₁ ++ l₂, bench := b₁ ++ { q with tools := [Card.tool n gr] } :: b₂ } }
  /-- use the effect of the Stadium in play (milestone M5): "Once during each player's turn, that
  player may …" (Academy at Night sv6pt5-54, Levincia sv10-244, Prism Tower me4-80). Whoever owns
  the Stadium, the player to move may use it once in their turn (`GameState.stadiumUsed`, cleared
  at the end of the turn and when a new Stadium is played); its effect (`Card.trainer`'s `effect`)
  acts for that player (`.own` is the player to move) and resolves as a Trainer card's does
  (`TRun`, Knock Outs taken after each step), during the turn proper, before attacking, with no
  Knock Out pending, and with no attack damage step. A use spends no allowance of the turn. So at
  most two Stadium effects are used in one turn: the Stadium in play, and the one Stadium the
  player may play after using it -/
  | stadiumUse {g g' : GameState} {o : Bool} {n : String} {e : Effect} {ss : List Static}
      (hs : g.stadium = some (o, Card.trainer n .stadium e ss)) (hu : g.stadiumUsed = false)
      (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false)
      (hr : TRun e { g with stadiumUsed := true } g') (hnd : e.hitFree = true)
      (hbh : e.benchHitFree = true) :
      Move g g'
  /-- use an activated Ability (milestone M8a) of one of the player's Pokémon in play, its own or
  (milestone M5) one an attached Tool gives it (`InPlay.abilities`), Active or
  Benched as the Ability allows (`Ability.spotOk`), during the turn proper and before attacking
  (rulebook 2023 p. 9: "2) … F. Use Abilities (as many as you want). 3) Attack. Then, end your
  turn."; p. 12: "Many of them can be used before you attack", "You can use Abilities from both
  your Active and Benched Pokémon"), with no
  Knock Out pending (`Settled`), and when its printed condition holds (`Ability.CondOk`). A
  "once during your turn" Ability (`AbilityUse.once`) needs the Pokémon not to have used an
  Ability this turn (`InPlay.used`); every use marks the Pokémon (`UseAt`). The effect resolves,
  with "this Pokémon" at `sp` (`Ability.script`), as a Trainer card's does (`TRun`, Knock Outs
  taken after each step) and, like a Trainer card's, has no attack damage. Using an Ability spends no allowance of the turn: not the Supporter, the
  Energy attachment or the retreat. -/
  | ability {g g₁ g' : GameState} {x : InPlay} {sp : Spot} {ab : Ability}
      (hu : UseAt g x sp g₁) (hm : ab ∈ x.abilities) (hk : ab.use.activated = true)
      (hsp : ab.spotOk sp = true) (hn : ab.use = .once → x.used = false) (hc : ab.CondOk g)
      (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false)
      (hr : TRun (ab.script (some sp)) g₁ g') (hnd : (ab.script (some sp)).hitFree = true)
      (hbh : (ab.script (some sp)).benchHitFree = true) :
      Move g g'
  /-- play a Pokémon from the hand (onto the Bench, or to evolve) and resolve an on-play Ability
  of the card played (milestone M8a: "When you play this Pokémon from your hand onto your Bench
  during your turn, you may …", "When you play this Pokémon from your hand to evolve 1 of your
  Pokémon during your turn, you may …"). The play has the premises of `Move.playBasic`,
  `Move.evolve` or `Move.evolveBench` (`PlayFromHand`); playing without using the Ability ("you
  may") is that move itself. The effect resolves as a Trainer card's does (`TRun`), from the state
  after the play, which must have no pending Knock Out (a Pokémon evolved into a card whose HP its
  damage reaches is Knocked Out first, and the model then offers no trigger); the printed
  condition is read there. The Ability's `spot` is not read, and "this Pokémon" is not tracked
  (`Ability.script none`: an effect on it acts on the Active Pokémon or on a Benched one). -/
  | onPlay {g g₁ g' : GameState} {x : InPlay} {how w : PlayWay} {ab : Ability}
      (hp : PlayFromHand g x how g₁) (hm : ab ∈ x.top.abilities) (hk : ab.use = .onPlay w)
      (hw : w.fires how = true) (hst : Settled g₁) (hc : ab.CondOk g₁)
      (hr : TRun (ab.script none) g₁ g') (hnd : (ab.script none).hitFree = true)
      (hbh : (ab.script none).benchHitFree = true) :
      Move g g'
  /-- attack with one of the Active Pokémon's attacks, its own or (milestone M5) one an attached
  Tool gives it (`InPlay.attacks`): the attached Energy must pay the cost (`Pays`, typed); resolve the attack's script
  (`Attack.script`: the printed base damage then the effect, or the effect with its own damage
  step), making the rulebook's damage calculation at most once (`Attack.wf`, `Effect.oneHit`;
  `dealtBy`), with nothing after a switch of the attacker that acts on the player's Active
  Pokémon (`Effect.switchSafe`, part of `Attack.wf`). The attack ends the turn (`attacked`): afterwards only Knock Outs and
  `endTurn` are legal. An Asleep or Paralyzed Pokémon cannot attack; a Confused one can, when
  its coin flip is heads; nobody can attack while an attack lock is in effect on them. A GX
  attack (`Attack.gx`) can be used only by a player who has not used one in this game, and
  using it records that (`PlayerState.gxUsed`). Since milestone M8b the attack ends with the
  opponent's `damaged` triggers (`HitTrig`, `Fire`), resolved before the Knock Out check. -/
  | attack {g g' : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.attacks)
      (hc : Pays atk.cost a.units) (hs : a.rot.canAct = true)
      (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
      (hst : Settled g)
      (hr : Run atk.script g g')
      (hl : g.cur.mods.live.noAttack = false)
      (hgx : atk.gx = true → g.cur.gxUsed = false) (hw : atk.wf = true)
      {l : List Ability} {g'' : GameState} (hd : HitTrig atk g g' l) (ht : Fire .damaged l g' g'') :
      Move g { g'' with attacked := true, cur := { g''.cur with gxUsed := atk.gx || g''.cur.gxUsed } }
  /-- a Confused Pokémon tries to attack and the coin flip is tails: the attack does not
  happen, and the attacker gets 3 damage counters; this still ends the turn (`attacked`). As for `attack`, a GX attack can be tried
  only by a player who has not used one in this game; the failed attempt does not use it up
  (an unverified ruling; see the Known gaps). -/
  | attackConfused {g : GameState} {a : InPlay} {atk : Attack}
      (ha : g.cur.active = some a) (hm : atk ∈ a.attacks)
      (hc : Pays atk.cost a.units) (hs : a.rot = .confused)
      (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
      (hst : Settled g) (hl : g.cur.mods.live.noAttack = false)
      (hgx : atk.gx = true → g.cur.gxUsed = false) (hw : atk.wf = true) :
      Move g { g with
        cur := { g.cur with active := some { a with damage := a.damage + 3 } },
        attacked := true }
  /-- the batch Knock Out step (`KOBatch`; during the turn or between turns): from a state that
  is not `Settled`, every Pokémon in play at or above its HP is Knocked Out at once, both players
  take their Prize cards, the game ends if either player wins (Sudden Death if both win in as many
  ways), and otherwise each player with an empty Active Spot promotes a Benched Pokémon. Before
  milestone batch-KO this was eight moves (`knockOut`, `knockOutBench`, `promote`, `noPokemon` and
  their `Own` versions), taken one at a time in any order. Since milestone M8b the step ends with
  the `koByAttack` triggers of the opponent's Pokémon it Knocked Out, when the turn's attack has been
  made and the game goes on (`GameState.batchTrigs`), in any order (`Fire`) -/
  | knockOuts {g g₁ g' : GameState} {l : List Ability} (h : KOBatch g g₁)
      (hl : l.Perm (g.batchTrigs g₁)) (ht : Fire .koByAttack l g₁ g') : Move g g'
  /-- end the turn: Pokémon Checkup on both Active Pokémon, with coin flips `fa`, `sa`, `ca`
  (Burn, Sleep, Char) for the opponent's and `fb`, `sb`, `cb` for the player's own, and the Char
  counters of both Benches, one coin flip per Pokémon (`BenchChar`: the opponent's Bench becomes
  `bo`, the player's `bc`); the lingering modifiers of this turn expire and the others move one
  turn closer (`Store.shift`); then the opponent becomes the player to move, between turns.
  Requires both Active Pokémon and no pending Knock Out anywhere. -/
  | endTurn {g : GameState} {a b : InPlay} {bo bc : List InPlay} (fa sa ca fb sb cb : Bool)
      (ha : g.opp.active = some a) (hb : g.cur.active = some b) (hk : DamageBounded g)
      (hbt : g.between = false) (hco : BenchChar g.opp.bench bo)
      (hcc : BenchChar (g.cur.bench.map InPlay.unfresh) bc) :
      Move g
        { cur := { g.opp with
            active := some (a.checkup false fa sa ca), bench := bo,
            energyAttached := false, supporterPlayed := false, retreated := false,
            mods := g.opp.mods.shift, ko := g.opp.ko.shift },
          opp := { g.cur.unfresh with
            active := some (b.unfresh.checkup true fb sb cb), bench := bc,
            mods := g.cur.mods.shift, hadTurn := true, ko := g.cur.ko.shift },
          curIsFirst := !g.curIsFirst, firstTurn := false, attacked := false,
          between := true, winner := g.winner, stadium := g.stadium, stadiumPlayed := false,
          stadiumUsed := false }
  /-- begin the turn by drawing a card, once the Knock Outs from Checkup have all been taken
  and both Active Spots are filled -/
  | startTurn {g : GameState} {a b : InPlay} {c : Card} {d : List Card}
      (hbt : g.between = true) (ha : g.opp.active = some a) (hb : g.cur.active = some b)
      (hk : DamageBounded g) (hd : g.cur.deck = c :: d) :
      Move g { g with cur := { g.cur with deck := d, hand := c :: g.cur.hand }, between := false }
  /-- the player to move cannot draw at the beginning of the turn and loses -/
  | deckOut {g : GameState} {a b : InPlay}
      (hbt : g.between = true) (ha : g.opp.active = some a) (hb : g.cur.active = some b)
      (hk : DamageBounded g) (hd : g.cur.deck = []) :
      Move g { g with winner := some (.win !g.curIsFirst) }

/-- Reachability by legal play. No move is made once the game has a winner. -/
inductive Reach : GameState → GameState → Prop where
  | refl (g : GameState) : Reach g g
  | step {g₀ g g' : GameState} : Reach g₀ g → g.winner = none → Move g g' → Reach g₀ g'

/-- The batch Knock Out step is taken only from a state that is not `Settled`. -/
theorem KOBatch.not_settled {g g' : GameState} (h : KOBatch g g') : ¬ Settled g := by
  cases h <;> assumption

/-- When the check ends the game, the batch Knock Out step is the check alone. -/
theorem KOBatch.eq_of_won {g g' : GameState} (h : KOBatch g g') (hw : g.koStep.winner ≠ none) :
    g' = g.koStep := by
  cases h with
  | won => rfl
  | go _ hk => exact absurd hk hw

/-- The batch Knock Out step changes no turn flag, no Stadium and no flag of the Stadium. -/
theorem KOBatch.same {g g' : GameState} (h : KOBatch g g') :
    g'.curIsFirst = g.curIsFirst ∧ g'.firstTurn = g.firstTurn ∧ g'.attacked = g.attacked ∧
      g'.between = g.between ∧ g'.stadium = g.stadium ∧ g'.stadiumPlayed = g.stadiumPlayed ∧
      g'.stadiumUsed = g.stadiumUsed := by
  cases h <;> exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- The batch Knock Out step changes, of each player, only the Pokémon in play, the discard pile,
the Prize cards and the hand. -/
theorem KOBatch.sides {g g' : GameState} (h : KOBatch g g') :
    g'.cur.deck = g.cur.deck ∧ g'.opp.deck = g.opp.deck ∧ g'.cur.lost = g.cur.lost ∧
      g'.opp.lost = g.opp.lost ∧ g'.cur.mods = g.cur.mods ∧ g'.opp.mods = g.opp.mods ∧
      g'.cur.hadTurn = g.cur.hadTurn ∧ g'.opp.hadTurn = g.opp.hadTurn ∧
      g'.cur.supporterPlayed = g.cur.supporterPlayed ∧
      g'.opp.supporterPlayed = g.opp.supporterPlayed ∧
      g'.cur.energyAttached = g.cur.energyAttached ∧ g'.cur.retreated = g.cur.retreated ∧
      g'.cur.gxUsed = g.cur.gxUsed ∧ g'.opp.gxUsed = g.opp.gxUsed := by
  cases h <;> exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- A play from the hand is the plain move (`Move.playBasic`, `Move.evolve`,
`Move.evolveBench`). -/
theorem PlayFromHand.move {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : Move g g₁ := by
  cases h with
  | basic hh hs hhp hb hbt hst hat => exact .playBasic hh hs hhp hb hbt hst hat
  | evolve hh ha he hfr hf hbt hst hat => exact .evolve hh ha he hfr hf hbt hst hat
  | evolveBench hh hb he hfr hf hbt hst hat => exact .evolveBench hh hb he hfr hf hbt hst hat

theorem PlayFromHand.attacked {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : g.attacked = false := by
  cases h <;> assumption

theorem PlayFromHand.between {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : g.between = false := by
  cases h <;> assumption

theorem PlayFromHand.settled {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : Settled g := by
  cases h <;> assumption

/-- The card played is in the hand. -/
theorem PlayFromHand.hand {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : ∃ l₁ l₂, g.cur.hand = l₁ ++ Card.pokemon x.top :: l₂ := by
  cases h with
  | basic hh => exact ⟨_, _, hh⟩
  | evolve hh => exact ⟨_, _, hh⟩
  | evolveBench hh => exact ⟨_, _, hh⟩

/-- **From a state that is not `Settled` the only move is the batch Knock Out step**: every other
move needs `Settled` (`endTurn`, `startTurn` and `deckOut` need both Active Pokémon and no pending
Knock Out, which is the same). -/
theorem Move.batch_of_not_settled {g g' : GameState} (hm : Move g g') (hu : ¬ Settled g) :
    ∃ g₁ l, KOBatch g g₁ ∧ l.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack l g₁ g' := by
  have of : ∀ {a b : InPlay}, DamageBounded g → g.opp.active = some a → g.cur.active = some b →
      Settled g := fun hk ha hb =>
    ⟨hk, ⟨by rw [hb]; exact Option.some_ne_none _, by rw [ha]; exact Option.some_ne_none _⟩⟩
  cases hm with
  | knockOuts h hl ht => exact ⟨_, _, h, hl, ht⟩
  | endTurn _ _ _ _ _ _ ha hb hk => exact absurd (of hk ha hb) hu
  | startTurn _ ha hb hk => exact absurd (of hk ha hb) hu
  | deckOut _ ha hb hk => exact absurd (of hk ha hb) hu
  | onPlay hp => exact absurd hp.settled hu
  | _ => exact absurd ‹Settled g› hu

/-! ## Triggers: basic facts (milestone M8b) -/

/-- No trigger, no change. -/
theorem Fire.nil_eq {ev : TrigEvent} {g g' : GameState} (h : Fire ev [] g g') : g' = g := by
  cases h; rfl

/-- Before the turn's attack a batch fires no trigger. -/
theorem GameState.batchTrigs_of_not_attacked {g g₁ : GameState} (h : g.attacked = false) :
    g.batchTrigs g₁ = [] := by
  simp only [GameState.batchTrigs, h, Bool.false_and, Bool.false_eq_true, ite_false]

/-- A batch that fires a trigger is taken after the turn's attack (milestone M8b). -/
theorem GameState.attacked_of_batchTrigs {g g₁ : GameState} (h : g.batchTrigs g₁ ≠ []) :
    g.attacked = true := by
  cases e : g.attacked with
  | true => rfl
  | false => exact absurd (GameState.batchTrigs_of_not_attacked e) h

/-- A batch that ends the game fires no trigger. -/
theorem GameState.batchTrigs_of_won {g g₁ : GameState} (h : g₁.winner ≠ none) :
    g.batchTrigs g₁ = [] := by
  have : g₁.winner.isNone = false := by
    cases e : g₁.winner with
    | none => exact absurd e h
    | some _ => rfl
  simp only [GameState.batchTrigs, this, Bool.and_false, Bool.false_eq_true, ite_false]

/-- A batch that fires no trigger is the batch Knock Out step alone. -/
theorem Move.knockOuts_of_nil {g g₁ : GameState} (h : KOBatch g g₁) (hn : g.batchTrigs g₁ = []) :
    Move g g₁ :=
  .knockOuts h (hn ▸ List.Perm.refl []) (.nil _)

/-- Before the turn's attack the batch move is the batch Knock Out step (`Move.knockOuts` with no
trigger). -/
theorem Move.knockOuts' {g g₁ : GameState} (h : KOBatch g g₁) (ha : g.attacked = false) :
    Move g g₁ :=
  Move.knockOuts_of_nil h (GameState.batchTrigs_of_not_attacked ha)

/-- A batch move whose step fires no trigger is that step. -/
theorem Move.eq_of_batchTrigs_nil {g g₁ g' : GameState} {l : List Ability}
    (hl : l.Perm (g.batchTrigs g₁)) (ht : Fire .koByAttack l g₁ g') (hn : g.batchTrigs g₁ = []) :
    g' = g₁ := by
  rw [hn] at hl
  rw [List.Perm.eq_nil hl] at ht
  exact ht.nil_eq

/-- A move from a state that is not `Settled`, whose check ends the game, is the check alone: no
trigger fires once the game is over. -/
theorem Move.eq_koStep_of_won {g g' : GameState} (hm : Move g g') (hu : ¬ Settled g)
    (hw : g.koStep.winner ≠ none) : g' = g.koStep := by
  obtain ⟨g₁, l, h, hl, ht⟩ := hm.batch_of_not_settled hu
  have e := h.eq_of_won hw
  subst e
  exact Move.eq_of_batchTrigs_nil hl ht (GameState.batchTrigs_of_won hw)

end Pokemon
