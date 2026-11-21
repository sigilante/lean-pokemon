import Pokemon.Exact

/-!
# Finiteness up to the exact-store clamp, on states with bounded stores

`GameState.xclamp` (`Pokemon/Exact.lean`) keeps the modifier stores exact, so its values are
finite in number only where the stores are bounded. This file states that bound as a property
of a state, not of the proof, and proves finiteness under it.

* `GameState.BoundedStores B g`: in both players' stores, every slot's damage bonus and damage
  reduction is at most `B` (flags are unrestricted; they have two values each).
* `Reach.xclamp_mem_bounded`: from a well-formed start `g₀`, for every `B` there is one finite
  list, depending only on `g₀` and `B`, that contains the `xclamp` of every reachable state
  satisfying `BoundedStores B`.
* `Reach.xfinite_bounded`: that list, together with `Reach.xclamp_bisim`: the kernel of
  `xclamp` is a two-way bisimulation along reachable states, for every deck. Since `xclamp`
  keeps the stores, `BoundedStores B` is a property of the `xclamp` class
  (`GameState.BoundedStores.of_xclamp`), so the reachable states satisfying it fall into
  finitely many classes of a bisimulation. A move can leave the bounded part; the theorem says
  nothing about where it goes then.

Nothing here bounds the stores: whether play keeps them bounded depends on the deck.
-/

namespace Pokemon

open Enum

/-- **Bounded stores**: in both players' modifier stores, every slot (this turn, next turn,
the turn after, the rest of the game) has a damage bonus and a damage reduction of at most
`B`. -/
def GameState.BoundedStores (B : Nat) (g : GameState) : Prop :=
  StoreLe B g.cur.mods ∧ StoreLe B g.opp.mods

/-- `BoundedStores` is a property of the `xclamp` class: the clamp keeps the stores. -/
theorem GameState.BoundedStores.of_xclamp {B : Nat} {g₁ g₂ : GameState}
    (h : g₁.BoundedStores B) (hc : g₁.xclamp = g₂.xclamp) : g₂.BoundedStores B := by
  obtain ⟨e₁, e₂⟩ := GameState.mods_of_xclamp hc
  exact ⟨e₁ ▸ h.1, e₂ ▸ h.2⟩

/-- The exact-store clamp is the capped clamp with the stores put back. -/
theorem GameState.xclamp_eq (k : Nat) (g : GameState) :
    g.xclamp = { g.clamp k with cur := { (g.clamp k).cur with mods := g.cur.mods },
                                opp := { (g.clamp k).opp with mods := g.opp.mods } } :=
  rfl

/-- The finite list: every state of `states C` with both stores replaced by stores whose
amounts are at most `B`. -/
def Enum.xstates (C : List Card) (B : Nat) : List GameState :=
  (states C).flatMap fun s => (stores B).flatMap fun t₁ => (stores B).map fun t₂ =>
    { s with cur := { s.cur with mods := t₁ }, opp := { s.opp with mods := t₂ } }

/-- **The exact-store clamps of reachable states with bounded stores lie in a finite list.**
From a well-formed start state `g₀`, for every `B` there is a finite list `L`, chosen before
the reachable state (it depends only on `g₀` and `B`), containing `g.xclamp` for every state
`g` reachable from `g₀` that satisfies `BoundedStores B`. -/
theorem Reach.xclamp_mem_bounded {g₀ : GameState} (hw : WellFormed g₀) (B : Nat) :
    ∃ L : List GameState, ∀ g, Reach g₀ g → g.BoundedStores B → g.xclamp ∈ L := by
  refine ⟨xstates g₀.allCards B, fun g h hb => ?_⟩
  have hm : g.clamp (bound g₀.allCards) ∈ states g₀.allCards :=
    mem_states (by rw [GameState.allCards_clamp]; exact h.perm) (h.clamp_bounded hw)
  rw [GameState.xclamp_eq (bound g₀.allCards)]
  simp only [xstates, List.mem_flatMap, List.mem_map]
  exact ⟨_, hm, g.cur.mods, mem_stores hb.1, g.opp.mods, mem_stores hb.2, rfl⟩

/-- **Finiteness on the bounded part.** Let `g₀` be a well-formed start state and `B` any
bound. Then

* the `xclamp`s of the states reachable from `g₀` that satisfy `BoundedStores B` lie in one
  finite list `L` (depending only on `g₀` and `B`); and
* the kernel of `xclamp` is a two-way bisimulation along reachable states: if `g₁` is reachable
  and `g₂` has the same `xclamp`, every move from either is matched by a move from the other to
  a state with the same `xclamp` (and `g₂` satisfies `BoundedStores B` if `g₁` does).

There is no hypothesis on the cards: damage reduction, `drain`, rest-of-game modifiers and
`linger` inside `iter` are allowed. The hypothesis is on the reached states, and a move from a
state with bounded stores may lead to one without. As for `Reach.finite`, the list is not computed
and the quotient's moves are not shown computable. -/
theorem Reach.xfinite_bounded {g₀ : GameState} (hw : WellFormed g₀) (B : Nat) :
    (∃ L : List GameState, ∀ g, Reach g₀ g → g.BoundedStores B → g.xclamp ∈ L) ∧
      ∀ g₁ g₂, Reach g₀ g₁ → g₁.xclamp = g₂.xclamp →
        (g₁.BoundedStores B → g₂.BoundedStores B) ∧
        (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp) ∧
        (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧ g₂'.xclamp = g₁'.xclamp) :=
  ⟨Reach.xclamp_mem_bounded hw B, fun _ _ h hc =>
    ⟨fun hb => hb.of_xclamp hc, (Reach.xclamp_bisim h hc).1, (Reach.xclamp_bisim h hc).2⟩⟩

end Pokemon
