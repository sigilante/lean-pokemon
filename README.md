# lean-pokemon

A Lean 4 model of the Pokémon Trading Card Game, built to settle whether the game is Turing
complete. The working hypothesis is that it is not: the game has no token generation, and a
Pokémon whose damage reaches its HP is Knocked Out, so no usable unbounded store exists.

Status: early. The model covers a core of the rules: state; an effect language of seventeen
primitives, including the five Special Conditions, a cure, Croagunk's stacking Poison ("This
effect can be applied more than once"), and effects that read the state: a test on either
Active Pokémon (at least `n` damage counters, exactly `n`, a Special Condition), placing `k`
counters on the opponent's Active Pokémon for each damage counter on either Active Pokémon
(Lunala's doubling is the case `k = 1` on the opponent's), damage to the player's own Active
Pokémon, and healing all of its damage; a move relation in which an Asleep or Paralyzed
Pokémon can neither attack nor retreat and a Confused Pokémon's attack can fail (tails: no
attack, and 3 damage counters on itself); Knock Out timing at the level of moves: once a
move leaves a Pokémon at or above its HP, it must be Knocked Out and replaced before any
other move (`Settled`), while inside one effect damage may exceed HP and be read. This
matches the rulebook for attacks and Checkup but not for Item and Supporter cards, where the
rulebook Knocks Out immediately in mid-effect; there the model and the printed game are
incomparable (see the gaps list in `Pokemon/Rules.lean`);
and Pokémon Checkup between turns (Poison, Burn, Sleep, Paralysis, then Knock Outs). For that
model it proves:

* play permutes the cards in the game (`Reach.perm`);
* from a well-formed start (`WellFormed`: both players have Prizes while there is no winner;
  Benched Pokémon are below HP with no Special Condition), no reachable state without a winner
  is stuck (`Reach.progress`), and if a Knock Out is pending, a move that Knocks Out an Active
  Pokémon and takes a Prize card is legal (`Reach.knockOut_of_pending`); a move never changes
  an Active Pokémon at or above its HP except by Knocking it Out (`Move.pending_untouched`);
* the reachable states are finite up to a clamp (`Reach.finite`, from a well-formed start):
  cap at the Pokémon's HP the damage and the Poison strength on both Active Pokémon, and the
  clamps of all reachable states lie in one finite list. The clamp is a bisimulation for moves
  (`Move.clamp_sim`, `Reach.clamp_sim`), so these excesses cannot be observed by play.

Effects that read damage do not break finiteness, but they change why it holds. Inside one
effect the clamp is not a simulation: a test against 6 counters separates 5 from 6 counters on
a 5-HP Pokémon (`Reads.run_clamp_not_sim`). Effects are instead simulated with damage exact
(`Run.exact_sim`), and every move that resolves an effect starts from a state with no Pokémon
at or above its HP, where equal clamps mean equal damage. The cap stays at HP; no larger cap
computed from the cards is needed. The earlier bound on the player's own Active Pokémon during
a turn (at most `maxHp + 3` counters) is false once effects can damage it
(`Reads.activeLe_false`) and is no longer used.

The unclamped reachable state space is infinite (`Infinite.not_finite`): from a well-formed
start with no pending Knock Out, one Item that Poisons the opponent's Active Pokémon and then
raises its Poison strength any number of times reaches infinitely many states, none with a
pending Knock Out (`Reach.infinite_damageBounded`). One effect can also place arbitrarily many
damage counters before the Knock Out is taken (`counters_unbounded`). Checkup can leave a
Pokémon at or above its HP when the turn passes, in play reached from a well-formed start
(`Infinite.endTurn_pending_ko_reachable`); the Knock Out is taken between turns, before the
next draw (`Move.damageBounded_of_startTurn`). The finite list is not computed, depends on the
start state, and gives no size bound; decidability of reachability follows in principle but is
not formalized. These are theorems about the model, not yet about the printed game: they cover
only decks whose card text is expressible in `Pokemon.Effect`, and the model's departures from
the rulebook are listed at the top of `Pokemon/Rules.lean` (among them: Item and Supporter
effects resolve as a whole before Knock Outs are taken, as attacks do, which lets them read
more than the printed game allows).

Build: `lake build` (core Lean only, no dependencies). `Pokemon/Audit.lean` runs
`#audit_namespace Pokemon` (defined in `Pokemon/AuditCmd.lean`), which checks every theorem
declared in the project, private and generated ones included, and fails the build if any
depends on an axiom other than `propext` and `Quot.sound` (so `sorry` fails it too) or if a
file under `Pokemon/` is not imported. `scripts/audit.sh build.log` then fails CI unless the
log shows the gate's success line and no error or `sorry`.

Licence: MIT (see `LICENSE`).
