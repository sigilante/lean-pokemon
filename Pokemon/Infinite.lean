import Pokemon.WellFormed
import Pokemon.Damage

/-!
# The unclamped reachable state space is infinite

A concrete start state `Infinite.start`, well formed and with no pending Knock Out, from which
play reaches infinitely many states, all with no pending Knock Out. The player to move holds
one Item whose effect is `seq (inflict poisoned) (iter (poisonUp 1))`: it Poisons the
opponent's Active Pokémon and then raises its Poison strength by any number `n`. Poison deals
no damage until Checkup, so each resulting state `Infinite.st n` is `DamageBounded`.

* `Infinite.not_finite_damageBounded`: the reachable states with no pending Knock Out do not
  lie in any finite list. This refutes the statement `Reach.finite_damageBounded` that an
  earlier version of `Pokemon/Finite.lean` proved before stacking Poison was added.
* `Infinite.not_finite`: hence the reachable states do not lie in any finite list.
* `Infinite.endTurn_pending_ko_reachable`: ending the turn from `st 5` Knocks Out the
  opponent's Active Pokémon in Checkup, so a state with a pending Knock Out is reachable from a
  well-formed start by `endTurn` (compare `Move.endTurn_pending_ko`, whose witness is not
  reachable from a well-formed state).

The excess Poison strength is invisible to play up to `clamp` (`Reach.clamp_sim`), and
`Reach.finite` bounds the clamped states; these theorems concern the unclamped states only.
-/

namespace Pokemon.Infinite

/-- A Basic Pokémon with 50 HP (five counters). -/
def mon : PokemonCard := ⟨"Mon", .basic, none, 5, .grass, [], 1⟩

/-- Poison the opponent's Active Pokémon, then raise its Poison strength any number of times. -/
def eff : Effect := .seq (.inflict .poisoned) (.iter (.poisonUp 1))

def item : Card := .trainer "PoisonUpItem" .item eff

def side (hand : List Card) (discard : List Card) (a : InPlay) : PlayerState :=
  ⟨[.energy .grass, .energy .grass], hand, discard, [.energy .fire], [], some a, [],
    none, false, false, false, false, false⟩

/-- Each player has one Prize card and a 50-HP Active Pokémon; the player to move holds
`item`. -/
def start : GameState :=
  ⟨side [item] [] (InPlay.ofBasic mon), side [] [] (InPlay.ofBasic mon),
    true, false, false, false, none⟩

/-- `start` after playing `item` with `n` repetitions of `poisonUp 1`. -/
def st (n : Nat) : GameState :=
  ⟨side [] [item] (InPlay.ofBasic mon),
    side [] [] { InPlay.ofBasic mon with poisoned := true, poisonUp := n },
    true, false, false, false, none⟩

theorem start_wellFormed : WellFormed start := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_⟩ <;>
    intro p hp <;> cases hp

theorem start_damageBounded : DamageBounded start := by
  intro p hp
  rcases hp with hp | hp | hp | hp
  · cases hp; decide
  · cases hp
  · cases hp; decide
  · cases hp

theorem start_settled : Settled start :=
  ⟨start_damageBounded, by simp [start, side], by simp [start, side]⟩

theorem st_damageBounded (n : Nat) : DamageBounded (st n) := by
  intro p hp
  rcases hp with hp | hp | hp | hp
  · cases hp; show 0 < 5; decide
  · cases hp
  · cases hp; show 0 < 5; decide
  · cases hp

theorem st_settled (n : Nat) : Settled (st n) :=
  ⟨st_damageBounded n, by simp [st, side], by simp [st, side]⟩

/-- Each round of `poisonUp 1` is one primitive step; it damages nothing, so no Knock Out is
taken and the state stays `Settled`. -/
theorem trun_iter_st : ∀ n u, TRun (.iter (.poisonUp 1)) (st u) (st (u + n))
  | 0, u => .iterNil _ _
  | n + 1, u => by
      have h := trun_iter_st n (u + 1)
      have e : u + 1 + n = u + (n + 1) := by omega
      rw [e] at h
      exact .iterCons (.prim rfl rfl (.poisonUp 1 rfl rfl) (.done (.inl (st_settled (u + 1))))) h

theorem reach_st (n : Nat) : Reach start (st n) := by
  have hr : TRun eff
      { start with cur := { start.cur with hand := [] ++ [], discard := [item] } }
      (st (0 + n)) :=
    .seq (.prim rfl rfl (.inflict .poisoned rfl) (.done (.inl (st_settled 0))))
      (trun_iter_st n 0)
  rw [Nat.zero_add] at hr
  exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) (n := "PoisonUpItem") rfl rfl
    start_settled hr)

/-- Poison strength on the opponent's Active Pokémon. -/
def oppPoisonUp (g : GameState) : Nat :=
  match g.opp.active with
  | some p => p.poisonUp
  | none => 0

theorem le_sum : ∀ {l : List Nat} {x : Nat}, x ∈ l → x ≤ l.sum
  | _ :: _, _, .head _ => by simp
  | y :: l, x, .tail _ h => by have := le_sum h; simp; omega

/-- **The reachable states with no pending Knock Out are infinite.** No finite list contains
every state reachable from the well-formed, damage-bounded `start` that is `DamageBounded`.
So the statement `Reach.finite_damageBounded` of an earlier version is false. -/
theorem not_finite_damageBounded :
    ¬ ∃ L : List GameState, ∀ g, Reach start g → DamageBounded g → g ∈ L := by
  intro ⟨L, hL⟩
  let n := (L.map oppPoisonUp).sum + 1
  have hm := hL (st n) (reach_st n) (st_damageBounded n)
  have : oppPoisonUp (st n) ≤ (L.map oppPoisonUp).sum := le_sum (List.mem_map_of_mem hm)
  simp [oppPoisonUp, st, side, n] at this
  omega

/-- **The unclamped reachable state space is infinite.** -/
theorem not_finite : ¬ ∃ L : List GameState, ∀ g, Reach start g → g ∈ L :=
  fun ⟨L, hL⟩ => not_finite_damageBounded ⟨L, fun g h _ => hL g h⟩

/-- The same, as a statement about the model: some well-formed start with no pending Knock Out
has infinitely many reachable states with no pending Knock Out. -/
theorem _root_.Pokemon.Reach.infinite_damageBounded :
    ∃ g₀, WellFormed g₀ ∧ DamageBounded g₀ ∧
      ¬ ∃ L : List GameState, ∀ g, Reach g₀ g → DamageBounded g → g ∈ L :=
  ⟨start, start_wellFormed, start_damageBounded, not_finite_damageBounded⟩

/-- **Checkup leaves a pending Knock Out, reachably.** From the well-formed start `start` with
no pending Knock Out, play reaches a state `g` with no pending Knock Out, during the turn
proper, from which a move that passes the turn to the opponent and enters the between-turns
phase yields a state with a pending Knock Out. The move is `endTurn`: Checkup puts 1 + 5 Poison
counters on the opponent's 50-HP Active Pokémon. -/
theorem endTurn_pending_ko_reachable :
    ∃ g₀, WellFormed g₀ ∧ DamageBounded g₀ ∧
      ∃ g g', Reach g₀ g ∧ DamageBounded g ∧ g.between = false ∧ Move g g' ∧
        g'.curIsFirst ≠ g.curIsFirst ∧ g'.between = true ∧ ¬ DamageBounded g' := by
  refine ⟨start, start_wellFormed, start_damageBounded, st 5, _, reach_st 5,
    st_damageBounded 5, rfl, .endTurn false false false false rfl rfl (st_damageBounded 5) rfl,
    by decide, rfl, fun hk => ?_⟩
  have := hk _ (Or.inl rfl)
  exact absurd this (by decide)

end Pokemon.Infinite
