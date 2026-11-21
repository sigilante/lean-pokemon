import Pokemon.Finite
import Pokemon.Infinite

/-!
# Effects that read the state: what changes, and what survives

The effect language reads the two Active Pokémon (`Effect.ite` on a `Test`: at least `n`
damage counters, exactly `n`, a Special Condition; `Effect.scale`, `k` counters on the
opponent's Active Pokémon per damage counter on either Active Pokémon), and can damage or fully
heal the player's own Active Pokémon (`selfDamage`, `healAll`). Inside one effect nothing is
Knocked Out, so these reads see damage above HP.

* `run_clamp_not_sim`: the HP clamp is NOT a simulation for `Run`. Two states whose opposing
  Active Pokémon have 5 and 6 damage counters on 5 HP have the same clamp, but the effect "if
  it has at least 6 damage counters, do nothing, else draw a card" separates them.
* `Move.pending_untouched`: Knock Out timing. A move never changes an Active Pokémon at or
  above its HP: it stays as it is, or it leaves the Active Spot (is Knocked Out); and the turn
  does not pass. So no effect can read or heal over-HP damage between moves.
* `activeLe_false`: the invariant `Reach.activeLe` of the previous version (during a turn, the
  player's own Active Pokémon has at most `maxHp + 3` damage counters) is false once effects
  can damage the player's own Pokémon. It is no longer needed.

What survives. Every move except a Knock Out starts from a `Settled` state, where damage on
every Pokémon in play is below HP and so equal clamps mean equal damage; `Run.exact_sim`
simulates effects with damage exact. Hence `Move.clamp_sim` and `Reach.clamp_sim` (the HP
clamp is a bisimulation for moves) and `Reach.finite` (the clamps of the reachable states lie
in one finite list) hold for the extended language, with the cap at HP; no larger cap computed
from the constants in the cards is needed. In particular no combination of `iter`, `choice`,
`selfDamage`, `scale`, `heal` and the tests inside one effect yields infinitely many states up
to the clamp at move boundaries: within one effect the damage is unbounded, but at the end of
the effect it is either below HP (finitely many values) or at or above HP, where only the
Knock Out test reads it. This depends on the model's Knock Out timing (`Settled`); without it,
`heal` would read over-HP damage across moves and the clamp would fail as above.
-/

namespace Pokemon

/-- **Knock Out timing.** A move leaves an Active Pokémon at or above its HP either unchanged
in its Active Spot or removed from it (Knocked Out), and does not pass the turn. -/
theorem Move.pending_untouched {g g' : GameState} {p : InPlay} (hm : Move g g') :
    (g.cur.active = some p → p.top.hp ≤ p.damage →
        (g'.cur.active = some p ∨ g'.cur.active = none) ∧ g'.curIsFirst = g.curIsFirst) ∧
      (g.opp.active = some p → p.top.hp ≤ p.damage →
        (g'.opp.active = some p ∨ g'.opp.active = none) ∧ g'.curIsFirst = g.curIsFirst) := by
  have bounded : DamageBounded g → ∀ X Y : Prop,
      (g.cur.active = some p → p.top.hp ≤ p.damage → X) ∧
        (g.opp.active = some p → p.top.hp ≤ p.damage → Y) := fun hk X Y =>
    ⟨fun ha hl => absurd (hk p (Or.inl ha)) (Nat.not_lt.2 hl),
      fun ha hl => absurd (hk p (Or.inr (Or.inr (Or.inl ha)))) (Nat.not_lt.2 hl)⟩
  cases hm with
  | playBasic _ _ _ _ _ hst => exact bounded hst.1 _ _
  | attach _ _ _ _ hst => exact bounded hst.1 _ _
  | evolve _ _ _ _ _ _ hst => exact bounded hst.1 _ _
  | retreat _ _ _ _ _ _ _ hst => exact bounded hst.1 _ _
  | item _ _ hst _ => exact bounded hst.1 _ _
  | supporter _ _ _ hst _ => exact bounded hst.1 _ _
  | attack _ _ _ _ _ _ _ hst _ => exact bounded hst.1 _ _
  | attackConfused _ _ _ _ _ _ _ hst => exact bounded hst.1 _ _
  | endTurn _ _ _ _ _ _ hk _ => exact bounded hk _ _
  | startTurn _ _ _ hk _ => exact bounded hk _ _
  | deckOut _ _ _ hk _ => exact bounded hk _ _
  | knockOut ha hk hp => exact ⟨fun h _ => ⟨.inl h, rfl⟩, fun _ _ => ⟨.inr rfl, rfl⟩⟩
  | promote ha hb =>
      exact ⟨fun h _ => ⟨.inl h, rfl⟩, fun h _ => absurd (ha.symm.trans h) (by simp)⟩
  | noPokemon ha hb => exact ⟨fun h _ => ⟨.inl h, rfl⟩, fun h _ => ⟨.inl h, rfl⟩⟩
  | knockOutOwn ha hk hp => exact ⟨fun _ _ => ⟨.inr rfl, rfl⟩, fun h _ => ⟨.inl h, rfl⟩⟩
  | promoteOwn ha hb =>
      exact ⟨fun h _ => absurd (ha.symm.trans h) (by simp), fun h _ => ⟨.inl h, rfl⟩⟩
  | noPokemonOwn ha hb => exact ⟨fun h _ => ⟨.inl h, rfl⟩, fun h _ => ⟨.inl h, rfl⟩⟩

namespace Reads

open Infinite

/-- Two 50-HP Active Pokémon; the opponent's has `d` damage counters; the player to move has
two cards in the deck. -/
def rs (d : Nat) : GameState :=
  ⟨side [] [] (InPlay.ofBasic mon), side [] [] { InPlay.ofBasic mon with damage := d },
    true, false, false, false, none⟩

/-- If the opponent's Active Pokémon has at least 6 damage counters, do nothing; else draw. -/
def probe : Effect := .ite (.atLeast .opp 6) .skip .draw

/-- `rs 5` after drawing a card. -/
def drawn : GameState :=
  ⟨⟨[.energy .grass], [.energy .grass], [], [.energy .fire], [], some (InPlay.ofBasic mon), [],
    none, false, false, false, false, false⟩,
    side [] [] { InPlay.ofBasic mon with damage := 5 }, true, false, false, false, none⟩

theorem rs_clamp : (rs 5).clamp = (rs 6).clamp := rfl

/-- **The HP clamp is not a simulation for `Run`** once effects read damage: `rs 5` and `rs 6`
have the same clamp, `probe` takes `rs 5` to `drawn`, and every resolution of `probe` from
`rs 6` ends in a state whose clamp differs from that of `drawn` (the hand has no card). -/
theorem run_clamp_not_sim :
    ∃ e g₁ g₂ g₁', g₁.clamp = g₂.clamp ∧ Run e g₁ g₁' ∧
      ∀ g₂', Run e g₂ g₂' → g₁'.clamp ≠ g₂'.clamp := by
  refine ⟨probe, rs 5, rs 6, drawn, rs_clamp, .iteF rfl rfl (.draw rfl), fun g₂' hr heq => ?_⟩
  cases hr with
  | iteT h ht r =>
      cases r
      exact absurd (congrArg (fun g : GameState => g.cur.hand.length) heq) (by decide)
  | iteF h ht r =>
      cases h
      exact absurd ht (by decide)

/-- A 50-HP Basic Pokémon whose free attack does no base damage and places 9 damage counters
on itself. -/
def hurter : PokemonCard :=
  ⟨"Hurter", .basic, none, 5, .grass, [⟨"Hurt", [], 0, .selfDamage 9⟩], 1⟩

def start2 : GameState :=
  ⟨side [] [] (InPlay.ofBasic hurter), side [] [] (InPlay.ofBasic mon),
    true, false, false, false, none⟩

def after2 : GameState :=
  ⟨side [] [] { InPlay.ofBasic hurter with damage := 9 },
    side [] [] { InPlay.ofBasic mon with damage := 0 + 0 },
    true, false, true, false, none⟩

theorem start2_damageBounded : DamageBounded start2 := by
  intro p hp
  rcases hp with hp | hp | hp | hp
  · cases hp; decide
  · cases hp
  · cases hp; decide
  · cases hp

theorem start2_wellFormed : WellFormed start2 := by
  refine ⟨fun _ => ⟨by simp [start2, side], by simp [start2, side]⟩, ?_, ?_⟩ <;>
    intro p hp <;> cases hp

theorem reach_after2 : Reach start2 after2 :=
  .step (.refl _) rfl (.attack (atk := ⟨"Hurt", [], 0, .selfDamage 9⟩) rfl (.head _)
    (Nat.zero_le _) rfl rfl rfl rfl
    ⟨start2_damageBounded, by simp [start2, side], by simp [start2, side]⟩
    (.seq (.counters 0 rfl) (.selfDamage 9 rfl)))

/-- **The old bound on the player's own Active Pokémon is false.** From a well-formed start with
no pending Knock Out, one attack whose effect damages the attacker reaches, during the turn, a
state whose own Active Pokémon has more than `maxHp + 3` damage counters (`Reach.activeLe` of
the previous version claimed at most `maxHp + 3`). The Knock Out is the next move
(`Move.pending_untouched`). An Item with the same effect cannot do this: its Knock Out is taken
in mid-effect (`TRun`), and the move ends with the Pokémon in the discard pile. -/
theorem activeLe_false :
    ∃ g₀, WellFormed g₀ ∧ DamageBounded g₀ ∧
      ∃ g p, Reach g₀ g ∧ g.between = false ∧ g.cur.active = some p ∧
        maxHp g₀.allCards + 3 < p.damage :=
  ⟨start2, start2_wellFormed, start2_damageBounded, after2, _, reach_after2, rfl, rfl,
    by decide⟩

end Reads

end Pokemon
