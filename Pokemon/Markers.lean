import Pokemon.Finite

/-!
# Markers

Markers (`Marks`, in `Pokemon.State`) are flags on a Pokémon in play: Imprison, Shock-wave,
Lightning Rod and Char, and a Coloring counter that carries a type. Effects place them on any
of a player's Pokémon in play (`Effect.mark`, `Effect.color`), remove them from all of a player's
Pokémon (`Effect.unmark`), and test them on either Active Pokémon (`Test.marked`, `Test.isType`).
A Char counter puts 2 damage counters on its Pokémon on tails at every Checkup, while that
Pokémon is Active. Markers stay with their Pokémon through evolution, retreat and promotion, and
leave play with it.

* `flag_exact`: the modelling assumption that a flag is enough. The printed Imprison and
  Shock-wave markers are uncapped counts, but the cards only place one at a time, remove all at
  once, and test whether there are any; the map from a count to "there is at least one" commutes
  with all three, so the flag model and the count model have the same observable behaviour.
* `Move.evolve_marks`, `Move.retreat_marks`: evolving or retreating keeps the markers.

`Reach.perm`, `Move.wellFormed`, `Reach.progress`, `Move.clamp_sim`, `Reach.clamp_mem` and
`Reach.finite` hold with markers. Markers are finitely many flags, they are not clamped, and the
finite list of `Reach.clamp_mem` enumerates them; markers alone needed no change to these
statements. (The statements of `Move.clamp_sim` and `Reach.finite` did change later, for
lingering modifiers: both now assume `GameState.Fit`, see `Pokemon/Lingering.lean`.)
-/

namespace Pokemon.Markers

/-- The operations printed cards perform on an uncapped marker count. -/
inductive CountOp where
  /-- put one more marker on the Pokémon -/
  | place
  /-- remove all such markers from it -/
  | removeAll

/-- The operation on the count. -/
def CountOp.onCount : CountOp → Nat → Nat
  | .place, n => n + 1
  | .removeAll, _ => 0

/-- The operation on the flag, as `Marks.set` performs it. -/
def CountOp.onFlag : CountOp → Bool → Bool
  | .place, _ => true
  | .removeAll, _ => false

/-- The only read: "has any markers". -/
def hasAny (n : Nat) : Bool := Nat.blt 0 n

/-- **Flags are exact for the printed marker operations.** Reading "has any" after any sequence
of placements and removals gives the same answer on the count as on the flag. -/
theorem flag_exact (ops : List CountOp) (n : Nat) :
    hasAny (ops.foldl (fun k o => o.onCount k) n) =
      ops.foldl (fun b o => o.onFlag b) (hasAny n) := by
  induction ops generalizing n with
  | nil => rfl
  | cons o os ih =>
      simp only [List.foldl_cons]
      rw [ih]
      congr 1
      cases o <;> simp [CountOp.onCount, CountOp.onFlag, hasAny, Nat.blt] <;> decide

/-- Evolving the Active Pokémon keeps its markers. -/
theorem _root_.Pokemon.Move.evolve_marks {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard}
    {a : InPlay} (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (ha : g.cur.active = some a)
    (he : p.evolvesFrom = some a.top.name) (hfr : a.fresh = false) (hf : g.cur.hadTurn = true)
    (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false) :
    ∃ g' a', Move g g' ∧ g'.cur.active = some a' ∧ a'.top = p ∧ a'.marks = a.marks :=
  ⟨_, _, .evolve hh ha he hfr hf hbt hst hat, rfl, rfl, rfl⟩

/-- Retreating keeps the markers of the Pokémon that goes to the Bench. -/
theorem _root_.Pokemon.Move.retreat_marks {g : GameState} {a q : InPlay} {b₁ b₂ : List InPlay}
    {paid rest : List Card} (ha : g.cur.active = some a) (hb : g.cur.bench = b₁ ++ q :: b₂)
    (hr : g.cur.retreated = false) (he : a.energy = paid ++ rest)
    (hp : paid.length = a.top.retreat) (hs : a.rot.canAct = true) (hbt : g.between = false)
    (hst : Settled g) (hl : g.cur.mods.live.noRetreat = false) (hat : g.attacked = false) :
    ∃ g' a', Move g g' ∧ a' ∈ g'.cur.bench ∧ a'.top = a.top ∧ a'.marks = a.marks :=
  ⟨_, _, .retreat ha hb hr he hp hs hbt hst hl hat, List.mem_append_right _ (.head _), rfl,
    rfl⟩

end Pokemon.Markers
