import Pokemon.Recycle

/-!
# Activated Abilities and the store bound (milestone M8a)

An "as often as you like" Ability (`AbilityUse.unlimited`) is a free, repeatable effect within a
turn: an `iter` at the level of moves rather than inside one effect. Clause 1 of
`GameState.Faithful` (`LoopFree`) forbids writing a damage bonus or reduction under `iter`
inside one effect; it says nothing about repeating a whole move. This file proves that a further
condition is needed, and that the one chosen, clause 4 (`AbilitySafe`) with clause 3
(`RecycleSafe`) extended to "as often as you like" Abilities, is not vacuous:

* `unlimited_writer_breaks_bound`: a well-formed start satisfying clauses 1–3 and violating
  clause 4, whose Pokémon has an "as often as you like" Ability that writes a carried damage
  reduction, has reachable states with unbounded stores and `xclamp`s in no finite list (the
  Ability is used again and again in one turn).
* `unlimited_recycler_breaks_bound`: a well-formed start satisfying clauses 1, 2 and 4 and
  violating clause 3 (a), whose Pokémon has an "as often as you like" Ability that returns an
  Item modelled on Iron Defender from the discard pile to the hand, has the same: play the Item,
  return it with the Ability, play it again.
* `once_recycler_faithful`: the same deck with the Ability limited to "once during your turn" is
  faithful, so `Faithful.xfinite` applies to it: a once-per-turn recycler of a modifier writer is
  allowed, because the uses of such Abilities in one turn are bounded by the potential
  `GameState.abPot` (each use returns at most `P`, the Trainer amounts of all the cards, which
  `storeBound` pays for through `Ability.q`).

As for `Recycle.recycling_breaks_bound`, these are statements about representation: in the
witnesses nothing reads the stored reduction (no attack is made), so the unboundedly many states
are not shown to differ in play.

Survey S10 found no Standard Ability with either shape: the seven "as often as you like" Abilities
of today's Standard move or attach Energy, or move a damage counter, and write no modifier and
recycle nothing (see the README for the list).
-/

namespace Pokemon.Abilities

open Recycle

/-! ## An "as often as you like" Ability that writes a reduction -/

/-- "As often as you like during your turn, you may use this Ability. During your opponent's next
turn, your Pokémon take 30 less damage from attacks": no printed card has it. -/
def guardUp : Ability := ⟨"Guard Up", .unlimited, none, none, .linger .own .next (.reduce 3)⟩

def warden : PokemonCard :=
  ⟨"Warden", .basic, none, 10, .metal, [], 1, none, none, .none, false, [guardUp]⟩

/-- The warden in the Active Spot, having used an Ability this turn or not. -/
def wardenAt (u : Bool) : InPlay := { InPlay.ofBasic warden with used := u }

def wpl (r : Nat) (u : Bool) : PlayerState :=
  ⟨[], [], [], [.energy .metal], [], some (wardenAt u), [], false, false, false,
    false, false, store r, true⟩

def wgs (r : Nat) (u : Bool) : GameState :=
  ⟨wpl r u, Recycle.pl [] [] 0, true, false, false, false, none, none⟩

theorem wgs_settled (r : Nat) (u : Bool) : Settled (wgs r u) :=
  Trainer.settled_of rfl rfl (show 0 < 10 by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by cases hp)

/-- **One use of the Ability** adds 3 to the carried reduction. -/
theorem wmove (r : Nat) (u : Bool) : Move (wgs r u) (wgs (r + 3) true) :=
  .ability (ab := guardUp) (.active rfl) (.head _) rfl rfl (fun h => nomatch h) trivial rfl
    (wgs_settled _ _) rfl
    (.prim rfl rfl (.linger .own .next (.reduce 3) _) (.done (.inl (wgs_settled _ _))))
    rfl rfl

theorem reach_wgs (k : Nat) : Reach (wgs 0 false) (wgs (3 * k) (decide (0 < k))) := by
  induction k with
  | zero => exact .refl _
  | succ k ih =>
      have e : 3 * (k + 1) = 3 * k + 3 := by omega
      rw [e, show decide (0 < k + 1) = true from rfl]
      exact .step ih rfl (wmove _ _)

theorem wgs_wellFormed : WellFormed (wgs 0 false) :=
  ⟨fun _ => ⟨by simp [wgs, wpl], by simp [wgs, Recycle.pl]⟩, (fun p hp => by cases hp),
    (fun p hp => by cases hp)⟩

theorem wgs_allCards : (wgs 0 false).allCards =
    [.energy .metal, .pokemon warden, .energy .metal, .pokemon Recycle.guard] := rfl

theorem wgs_loopFree : (wgs 0 false).LoopFree := by
  unfold GameState.LoopFree; rw [wgs_allCards]; decide

theorem wgs_gxOnly : (wgs 0 false).GXOnly := by
  intro p hp atk hm
  rw [wgs_allCards] at hp
  simp only [List.mem_cons, Card.pokemon.injEq, List.not_mem_nil, or_false, reduceCtorEq,
    false_or] at hp
  rcases hp with rfl | rfl <;> cases hm

theorem wgs_recycleSafe : (wgs 0 false).RecycleSafe := by
  unfold GameState.RecycleSafe; rw [wgs_allCards]; decide

theorem wgs_not_abilitySafe : ¬ (wgs 0 false).AbilitySafe := by
  intro h
  have := (h.get (p := warden) (by rw [wgs_allCards]; simp) (List.mem_singleton.2 rfl)).1 rfl
  exact absurd this (by decide)

/-- The carried reduction of the player to move. -/
def red (g : GameState) : Nat := g.cur.mods.next.reduce

theorem red_xclamp (g : GameState) : red g.xclamp = red g := rfl

/-- **An "as often as you like" Ability that writes a damage reduction breaks the store bound**
(milestone M8a). There is a well-formed start satisfying clauses 1, 2 and 3 of `Faithful` and
violating clause 4 (`AbilitySafe`), whose reachable states have unbounded stores and whose
reachable states' `xclamp`s lie in no finite list. Its one Pokémon uses the Ability again and
again in one turn. So clause 4, or some other condition on unlimited Abilities, is needed for
`Faithful.reach_boundedStores` and the finiteness half of `Faithful.xfinite`. -/
theorem unlimited_writer_breaks_bound :
    ∃ g₀ : GameState, WellFormed g₀ ∧ g₀.LoopFree ∧ g₀.GXOnly ∧ g₀.RecycleSafe ∧
      ¬ g₀.AbilitySafe ∧ (∀ B, ∃ g, Reach g₀ g ∧ ¬ g.BoundedStores B) ∧
      ¬ ∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp ∈ L := by
  refine ⟨wgs 0 false, wgs_wellFormed, wgs_loopFree, wgs_gxOnly, wgs_recycleSafe,
    wgs_not_abilitySafe, fun B => ?_, ?_⟩
  · refine ⟨_, reach_wgs (B + 1), fun hb => ?_⟩
    have := hb.1.2.1.2
    simp only [wgs, wpl, store] at this
    omega
  · intro ⟨L, hL⟩
    let n := (L.map red).sum + 1
    have hm := hL _ (reach_wgs n)
    have : red (wgs (3 * n) (decide (0 < n))).xclamp ≤ (L.map red).sum :=
      Infinite.le_sum (List.mem_map_of_mem hm)
    rw [red_xclamp] at this
    simp only [red, wgs, wpl, store, n] at this
    omega

/-! ## An "as often as you like" Ability that recycles a modifier writer -/

/-- "As often as you like during your turn, you may put an Iron Defender from your discard pile
into your hand": no printed card has it. -/
def retrieve (u : AbilityUse) : Ability :=
  ⟨"Retrieve", u, none, none, .move .own .discard .hand (.named "Iron Defender") (.upTo 1)⟩

def keeper (u : AbilityUse) : PokemonCard :=
  ⟨"Keeper", .basic, none, 10, .metal, [], 1, none, none, .none, false, [retrieve u]⟩

def kAt (u : AbilityUse) (b : Bool) : InPlay := { InPlay.ofBasic (keeper u) with used := b }

def kpl (u : AbilityUse) (hand discard : List Card) (r : Nat) (b : Bool) : PlayerState :=
  ⟨[], hand, discard, [.energy .metal], [], some (kAt u b), [], false, false, false,
    false, false, store r, true⟩

def kgs (u : AbilityUse) (hand discard : List Card) (r : Nat) (b : Bool) : GameState :=
  ⟨kpl u hand discard r b, Recycle.pl [] [] 0, true, false, false, false, none, none⟩

theorem kgs_settled (u : AbilityUse) (hand discard : List Card) (r : Nat) (b : Bool) :
    Settled (kgs u hand discard r b) :=
  Trainer.settled_of rfl rfl (show 0 < 10 by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by cases hp)

/-- Play Iron Defender. -/
theorem kmove1 (r : Nat) (b : Bool) :
    Move (kgs .unlimited [ironDefender] [] r b) (kgs .unlimited [] [ironDefender] (r + 3) b) :=
  .item (l₁ := []) (l₂ := []) (n := "Iron Defender") rfl rfl (kgs_settled _ _ _ _ _)
    (.prim rfl rfl (.linger .own .next (.reduce 3) _) (.done (.inl (kgs_settled _ _ _ _ _))))
    rfl rfl rfl rfl

/-- Return it with the Ability. -/
theorem kmove2 (r : Nat) (b : Bool) :
    Move (kgs .unlimited [] [ironDefender] r b) (kgs .unlimited [ironDefender] [] r true) :=
  .ability (ab := retrieve .unlimited) (.active rfl) (.head _) rfl rfl (fun h => nomatch h)
    trivial rfl (kgs_settled _ _ _ _ _) rfl
    (.prim rfl rfl
      (.zone (w := .own) rfl
        (.move (src := .discard) (.take rfl .nil) (by unfold Qty.ok; decide) (.hand _ _)))
      (.done (.inl (kgs_settled _ _ _ _ _))))
    rfl rfl

theorem reach_kgs (k : Nat) :
    Reach (kgs .unlimited [ironDefender] [] 0 false)
      (kgs .unlimited [ironDefender] [] (3 * k) (decide (0 < k))) := by
  induction k with
  | zero => exact .refl _
  | succ k ih =>
      have e : 3 * (k + 1) = 3 * k + 3 := by omega
      rw [e, show decide (0 < k + 1) = true from rfl]
      exact .step (.step ih rfl (kmove1 _ _)) rfl (kmove2 _ _)

theorem kgs_wellFormed (u : AbilityUse) : WellFormed (kgs u [ironDefender] [] 0 false) :=
  ⟨fun _ => ⟨by simp [kgs, kpl], by simp [kgs, Recycle.pl]⟩, (fun p hp => by cases hp),
    (fun p hp => by cases hp)⟩

theorem kgs_allCards (u : AbilityUse) : (kgs u [ironDefender] [] 0 false).allCards =
    [ironDefender, .energy .metal, .pokemon (keeper u), .energy .metal,
      .pokemon Recycle.guard] := rfl

theorem kgs_gxOnly (u : AbilityUse) : (kgs u [ironDefender] [] 0 false).GXOnly := by
  intro p hp atk hm
  rw [kgs_allCards] at hp
  simp only [List.mem_cons, Card.pokemon.injEq, List.not_mem_nil, or_false, reduceCtorEq,
    false_or, ironDefender] at hp
  rcases hp with rfl | rfl <;> cases hm

/-- **An "as often as you like" Ability that recycles a modifier writer breaks the store bound**
(milestone M8a). There is a well-formed start satisfying clauses 1, 2 and 4 of `Faithful` and
violating clause 3 (its Ability, an "as often as you like" one, can return `ironDefender`, a
non-Supporter writer), whose reachable states have unbounded stores and whose reachable states'
`xclamp`s lie in no finite list: within one turn, play `ironDefender`, return it with the
Ability, and play it again. -/
theorem unlimited_recycler_breaks_bound :
    ∃ g₀ : GameState, WellFormed g₀ ∧ g₀.LoopFree ∧ g₀.GXOnly ∧ ¬ g₀.RecycleSafe ∧
      g₀.AbilitySafe ∧ (∀ B, ∃ g, Reach g₀ g ∧ ¬ g.BoundedStores B) ∧
      ¬ ∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp ∈ L := by
  refine ⟨kgs .unlimited [ironDefender] [] 0 false, kgs_wellFormed _,
    by unfold GameState.LoopFree; rw [kgs_allCards]; decide, kgs_gxOnly _, fun h => ?_,
    by unfold GameState.AbilitySafe; rw [kgs_allCards]; decide, fun B => ?_, ?_⟩
  · have := h.1 (.pokemon (keeper .unlimited)) (by rw [kgs_allCards]; simp) _ (.head _)
      ironDefender (by rw [kgs_allCards]; simp) rfl
    exact absurd this (by decide)
  · refine ⟨_, reach_kgs (B + 1), fun hb => ?_⟩
    have := hb.1.2.1.2
    simp only [kgs, kpl, store] at this
    omega
  · intro ⟨L, hL⟩
    let n := (L.map red).sum + 1
    have hm := hL _ (reach_kgs n)
    have : red (kgs .unlimited [ironDefender] [] (3 * n) (decide (0 < n))).xclamp ≤
        (L.map red).sum := Infinite.le_sum (List.mem_map_of_mem hm)
    rw [red_xclamp] at this
    simp only [red, kgs, kpl, store, n] at this
    omega

/-- **A once-per-turn recycler of a modifier writer is faithful** (milestone M8a): the deck of
`unlimited_recycler_breaks_bound` with the Ability limited to "once during your turn" satisfies
all four clauses, so `Faithful.xfinite` applies to it. -/
theorem once_recycler_faithful : (kgs .once [ironDefender] [] 0 false).Faithful :=
  ⟨by unfold GameState.LoopFree; rw [kgs_allCards]; decide, kgs_gxOnly _,
    by unfold GameState.RecycleSafe; rw [kgs_allCards]; decide,
    by unfold GameState.AbilitySafe; rw [kgs_allCards]; decide⟩

end Pokemon.Abilities
