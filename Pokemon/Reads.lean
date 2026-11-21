import Pokemon.Finite
import Pokemon.Infinite

/-!
# Effects that read the state: what changes, and what survives

The effect language reads the two Active Pokémon (`Effect.ite` on a `Test`: at least `n`
damage counters, exactly `n`, a Special Condition, a marker, a type; `Effect.scale`, `k` counters
on the opponent's Active Pokémon per damage counter on either Active Pokémon; the amount of the
damage step, `Amt.per`), and can damage or heal the player's own Active Pokémon (`selfDamage`,
`heal`, `healAll`, `drain`). Since milestone M3 it also places damage counters and attack damage
on Benched Pokémon of either player (`benchCounters`, `spreadCounters`, `benchDamage`,
`spreadDamage`), heals one of the player's own Benched Pokémon (`benchHeal`, whose truncated
subtraction reads a Benched Pokémon's damage; since milestone M8a `moveCounter`, among the
player's own Pokémon, reads it too), and switches either player's Active
Pokémon with a Benched one (`switch`), which brings a Benched Pokémon's damage within reach of
the readers of the Active Pokémon. Inside an attack's effect
(`Run`) nothing is Knocked Out, so these reads see damage above HP. Inside an Item or Supporter
effect (`TRun`) they do not: a Knock Out is taken at once after the step that causes it
(`TRun.guarded`, in `Pokemon/Trainer.lean`).

* `run_clamp_not_sim`: the HP clamp is NOT a simulation for `Run`. Two states whose opposing
  Active Pokémon have 5 and 6 damage counters on 5 HP have the same clamp, but the effect "if
  it has at least 6 damage counters, do nothing, else draw a card" separates them.
* `Move.pending_knockedOut` (formerly `Move.pending_untouched`, kept as a deprecated alias):
  Knock Out timing. A move from a state with an Active Pokémon at or above its HP is the batch
  Knock Out step, which Knocks it Out (its cards go to the discard pile); and the turn does not
  pass. So no effect can read or heal over-HP damage between moves.
* `activeLe_false`: the invariant `Reach.activeLe` of the previous version (during a turn, the
  player's own Active Pokémon has at most `maxHp + 3` damage counters) is false once an
  attack's effect can damage the player's own Pokémon. It is no longer needed.

What survives. Every move except the batch Knock Out step starts from a `Settled` state, where damage on
every Pokémon in play is below HP and so equal clamps mean equal damage; `Run.cap_sim`
simulates an attack's effect with the player's own damage exact (and the opponent's capped at a
constant above every HP and test constant, which the damage bonus of `Pokemon/Lingering.lean`
requires), and `TRun.clamp_sim` a Trainer card's. Hence `Move.clamp_sim` and `Reach.clamp_sim`
(the clamp is a bisimulation for moves, for tame decks), `Reach.clamp_mem` (the clamps of the
reachable states lie in one finite list) and `Reach.finite` (both together, for tame decks) hold
for the extended language, with the damage cap at
HP. (`run_clamp_not_sim` is stated for every cap `k` on the damage bonuses; its states have no
modifiers.)
In particular no combination of `iter`, `choice`, `selfDamage`, `scale`, `heal` and the tests
inside one effect yields infinitely many states up to the clamp at move boundaries: within one
attack's effect the damage is unbounded, but at the end of the effect it is either below HP
(finitely many values) or at or above HP, where only the Knock Out test reads it. This depends
on the model's Knock Out timing (`Settled`); without it, `heal` would read over-HP damage across
moves and the clamp would fail as above. -/

namespace Pokemon

/-- The check Knocks Out a pending Active Pokémon: its cards, with everything attached, go on top
of its owner's discard pile. -/
theorem KOBatch.active_out {g g' : GameState} (h : KOBatch g g') {w : Whose} {p : InPlay}
    (ha : (g.side w).active = some p) (hk : g.hpOf w .active p ≤ p.damage) :
    ∃ l, (g'.side w).discard = p.cardList ++ l ++ (g.side w).discard := by
  obtain ⟨-, -, d1, d2, -⟩ := h.piles
  have ht : g.koT w .active p = true := GameState.koT_iff.2 hk
  have e : (g.koOf w).discard = p.cardList ++ benchCardList ((g.side w).bench.filter
      (g.koT w .bench)) ++ (g.side w).discard := by
    simp only [GameState.koOf, PlayerState.koOut, ha, optFilter, ht, ite_true, optCardList]
  cases w
  · exact ⟨_, d1.trans e⟩
  · exact ⟨_, d2.trans e⟩

/-- **Knock Out timing.** A move from a state in which an Active Pokémon is at or above its HP is
the batch Knock Out step, which Knocks that Pokémon Out (its cards, with everything attached, go on
top of its owner's discard pile), and it does not pass the turn. (Milestone M6: "its HP" is its
derived HP, `GameState.hpOf`, in the state before the move.)

Milestone batch-KO changed the conclusion. Before it, the Pokémon stayed as it was in its Active
Spot or the Active Spot was left empty (the one-at-a-time Knock Out moves; the Pokémon stayed only
while another Knock Out was taken first, and promotion was a later move). The batch step Knocks it
Out in every case and may refill the Active Spot by a promotion in the same move, so the statement
now says where the Pokémon goes and which move it is. Milestone M8b changed it again: the move is
the batch step `g₁` followed by the `koByAttack` triggers it fires (`Fire`), and the discard pile
named is the batch step's (a trigger may move cards out of it). Until this name was introduced the theorem was
`Move.pending_untouched`, a name from before batch-KO that no longer fits; that name is kept as a
deprecated alias. -/
theorem Move.pending_knockedOut {g g' : GameState} {p : InPlay} (hm : Move g g') :
    (g.cur.active = some p → g.hpOf .own .active p ≤ p.damage →
        ∃ g₁, KOBatch g g₁ ∧ (∃ l, g₁.cur.discard = p.cardList ++ l ++ g.cur.discard) ∧
          (∃ ts, ts.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack ts g₁ g') ∧
          g'.curIsFirst = g.curIsFirst) ∧
      (g.opp.active = some p → g.hpOf .opp .active p ≤ p.damage →
        ∃ g₁, KOBatch g g₁ ∧ (∃ l, g₁.opp.discard = p.cardList ++ l ++ g.opp.discard) ∧
          (∃ ts, ts.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack ts g₁ g') ∧
          g'.curIsFirst = g.curIsFirst) := by
  have bounded : DamageBounded g → ∀ X Y : Prop,
      (g.cur.active = some p → g.hpOf .own .active p ≤ p.damage → X) ∧
        (g.opp.active = some p → g.hpOf .opp .active p ≤ p.damage → Y) := fun hk X Y =>
    ⟨fun ha hl => absurd (hk .own .active p ha) (Nat.not_lt.2 hl),
      fun ha hl => absurd (hk .opp .active p ha) (Nat.not_lt.2 hl)⟩
  cases hm with
  | playBasic _ _ _ _ _ hst => exact bounded hst.1 _ _
  | attach _ _ _ _ hst => exact bounded hst.1 _ _
  | evolve _ _ _ _ _ _ hst => exact bounded hst.1 _ _
  | attachBench _ _ _ _ hst => exact bounded hst.1 _ _
  | evolveBench _ _ _ _ _ _ hst => exact bounded hst.1 _ _
  | retreat _ _ _ _ _ _ _ hst => exact bounded hst.1 _ _
  | item _ _ hst _ => exact bounded hst.1 _ _
  | supporter _ _ _ hst _ => exact bounded hst.1 _ _
  | stadium _ _ _ _ hst => exact bounded hst.1 _ _
  | stadiumUse _ _ _ hst => exact bounded hst.1 _ _
  | tool _ _ _ _ hst => exact bounded hst.1 _ _
  | toolBench _ _ _ _ hst => exact bounded hst.1 _ _
  | ability _ _ _ _ _ _ _ hst _ => exact bounded hst.1 _ _
  | onPlay hp => exact bounded hp.settled.1 _ _
  | attack _ _ _ _ _ _ _ hst _ => exact bounded hst.1 _ _
  | attackConfused _ _ _ _ _ _ _ hst => exact bounded hst.1 _ _
  | endTurn _ _ _ _ _ _ _ _ hk _ => exact bounded hk _ _
  | startTurn _ _ _ hk _ => exact bounded hk _ _
  | deckOut _ _ _ hk _ => exact bounded hk _ _
  | knockOuts h hl ht =>
      exact ⟨fun ha hk => ⟨_, h, h.active_out (w := .own) ha hk, ⟨_, hl, ht⟩,
          ht.zoneOnly.first.trans h.same.1⟩,
        fun ha hk => ⟨_, h, h.active_out (w := .opp) ha hk, ⟨_, hl, ht⟩,
          ht.zoneOnly.first.trans h.same.1⟩⟩

/-- Deprecated name of `Move.pending_knockedOut` (same statement). The name dates from before
milestone batch-KO, when the pending Active Pokémon could stay untouched by the move; it is now
Knocked Out, so the name no longer fits. -/
@[deprecated Move.pending_knockedOut (since := "2026-11-22")]
theorem Move.pending_untouched {g g' : GameState} {p : InPlay} (hm : Move g g') :
    (g.cur.active = some p → g.hpOf .own .active p ≤ p.damage →
        ∃ g₁, KOBatch g g₁ ∧ (∃ l, g₁.cur.discard = p.cardList ++ l ++ g.cur.discard) ∧
          (∃ ts, ts.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack ts g₁ g') ∧
          g'.curIsFirst = g.curIsFirst) ∧
      (g.opp.active = some p → g.hpOf .opp .active p ≤ p.damage →
        ∃ g₁, KOBatch g g₁ ∧ (∃ l, g₁.opp.discard = p.cardList ++ l ++ g.opp.discard) ∧
          (∃ ts, ts.Perm (g.batchTrigs g₁) ∧ Fire .koByAttack ts g₁ g') ∧
          g'.curIsFirst = g.curIsFirst) :=
  Move.pending_knockedOut hm

namespace Reads

open Infinite

/-- Two 50-HP Active Pokémon; the opponent's has `d` damage counters; the player to move has
two cards in the deck. -/
def rs (d : Nat) : GameState :=
  ⟨side [] [] (InPlay.ofBasic mon), side [] [] { InPlay.ofBasic mon with damage := d },
    true, false, false, false, none, none, false, false⟩

/-- If the opponent's Active Pokémon has at least `k + 1` damage counters, do nothing; else
draw. -/
def probe (k : Nat) : Effect := .ite (.atLeast .opp (k + 1)) .skip .draw

/-- `rs k` after drawing a card. -/
def drawn (k : Nat) : GameState :=
  ⟨⟨[.energy .grass], [.energy .grass], [], [.energy .fire], [], some (InPlay.ofBasic mon), [],
    false, false, false, false, false, Store.empty, true, KOHist.empty⟩,
    side [] [] { InPlay.ofBasic mon with damage := k }, true, false, false, false, none, none, false,
    false⟩

/-- `rs k` and `rs (k + 1)` have the same clamp at `k`, which caps damage at `k` (milestone M6:
before it the clamp capped at the printed HP, 5, and the witness was `rs 5` and `rs 6`). -/
theorem rs_clamp (k : Nat) : (rs k).clamp k = (rs (k + 1)).clamp k := by
  have h : min k k = min (k + 1) k := by omega
  simp only [rs, side, GameState.clamp, GameState.clampAt, Option.map_some, List.map_nil,
    InPlay.clampWith, Cap.dmg, h]

/-- **The clamp is not a simulation for `Run`** once effects read damage: `rs k` and `rs (k + 1)`
have the same clamp `k`, `probe k` takes `rs k` to `drawn k`, and every resolution of `probe k`
from `rs (k + 1)` ends in a state whose clamp differs from that of `drawn k` (the hand has no
card). (Milestone M6 changed the witness from `rs 5`, `rs 6` and a test against 6: the clamp now
caps damage at `k`, not at the printed HP.) -/
theorem run_clamp_not_sim (k : Nat) :
    ∃ e g₁ g₂ g₁', g₁.clamp k = g₂.clamp k ∧ Run e g₁ g₁' ∧
      ∀ g₂', Run e g₂ g₂' → g₁'.clamp k ≠ g₂'.clamp k := by
  refine ⟨probe k, rs k, rs (k + 1), drawn k, rs_clamp k,
    .iteF rfl (Bool.eq_false_iff.mpr fun h => by
      simp only [Test.eval, Nat.ble_eq] at h; exact absurd h (by simp)) (.draw rfl),
    fun g₂' hr heq => ?_⟩
  cases hr with
  | iteT h ht r =>
      cases r with
      | skip =>
          exact absurd (congrArg (fun g : GameState => g.cur.hand.length) heq)
            (by simp [drawn, rs, side, GameState.clamp, GameState.clampAt])
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | iteF h ht r =>
      cases h
      exact absurd ht (by simp [Test.eval])
  | touchActive he => simp [probe, Effect.touch] at he
  | touchBench he => simp [probe, Effect.touch] at he
  | zone hw => simp [probe, Effect.zSide] at hw

/-- A 50-HP Basic Pokémon whose free attack does no base damage and places 9 damage counters
on itself. -/
def hurter : PokemonCard :=
  ⟨"Hurter", .basic, none, 5, .grass, [⟨"Hurt", [], 0, .selfDamage 9, false⟩], 1, none, none, .none, false, []⟩

def start2 : GameState :=
  ⟨side [] [] (InPlay.ofBasic hurter), side [] [] (InPlay.ofBasic mon),
    true, false, false, false, none, none, false, false⟩

def after2 : GameState :=
  ⟨side [] [] { InPlay.ofBasic hurter with damage := 9 },
    side [] [] { InPlay.ofBasic mon with damage := 0 + 0 },
    true, false, true, false, none, none, false, false⟩

theorem start2_damageBounded : DamageBounded start2 := by
  refine DamageBounded.intro' (fun p hp => ?_) (fun p hp => ?_) (fun p hp => ?_) (fun p hp => ?_)
  · cases hp; decide
  · cases hp
  · cases hp; decide
  · cases hp

theorem start2_wellFormed : WellFormed start2 := by
  refine ⟨fun _ => ⟨by simp [start2, side], by simp [start2, side]⟩, ?_, ?_⟩ <;>
    intro p hp <;> cases hp

theorem reach_after2 : Reach start2 after2 :=
  .step (.refl _) rfl (.attack (atk := ⟨"Hurt", [], 0, .selfDamage 9, false⟩) rfl (.head _)
    (.nil _) rfl rfl rfl rfl
    ⟨start2_damageBounded, by simp [start2, side], by simp [start2, side]⟩
    (.selfDamage 9 rfl) rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil (.selfDamage 9 rfl) rfl) (.nil _))

/-- **The old bound on the player's own Active Pokémon is false.** From a well-formed start with
no pending Knock Out, one attack whose effect damages the attacker reaches, during the turn, a
state whose own Active Pokémon has more than `maxHp + 3` damage counters (`Reach.activeLe` of
the previous version claimed at most `maxHp + 3`). The Knock Out is the next move
(`Move.pending_knockedOut`). An Item with the same effect would have its Knock Out taken in
mid-effect, inside the same move (`TRun`; compare `Trainer.selfKO_reachable`). -/
theorem activeLe_false :
    ∃ g₀, WellFormed g₀ ∧ DamageBounded g₀ ∧
      ∃ g p, Reach g₀ g ∧ g.between = false ∧ g.cur.active = some p ∧
        maxHp g₀.allCards + 3 < p.damage :=
  ⟨start2, start2_wellFormed, start2_damageBounded, after2, _, reach_after2, rfl, rfl,
    by decide⟩

end Reads

end Pokemon
