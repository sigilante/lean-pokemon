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
recycle nothing (the list is in survey S10: Mega Venusaur ex, Team Rocket's Orbeetle,
Bellibolt, Azumarill, Emboar, Oricorio, Dewgong). For decks with no Abilities at all, see
`Pokemon/NoAbilities.lean`.
-/

namespace Pokemon.Abilities

open Recycle

/-! ## An "as often as you like" Ability that writes a reduction -/

/-- "As often as you like during your turn, you may use this Ability. During your opponent's next
turn, your Pokémon take 30 less damage from attacks": no printed card has it. -/
def guardUp : Ability := ⟨"Guard Up", .unlimited, none, none, .fx (.linger .own .next (.reduce 3))⟩

def warden : PokemonCard :=
  ⟨"Warden", .basic, none, 10, .metal, [], 1, none, none, .none, false, [guardUp]⟩

/-- The warden in the Active Spot, having used an Ability this turn or not. -/
def wardenAt (u : Bool) : InPlay := { InPlay.ofBasic warden with used := u }

def wpl (r : Nat) (u : Bool) : PlayerState :=
  ⟨[], [], [], [.energy .metal], [], some (wardenAt u), [], false, false, false,
    false, false, store r, true⟩

def wgs (r : Nat) (u : Bool) : GameState :=
  ⟨wpl r u, Recycle.pl [] [] 0, true, false, false, false, none, none, false, false⟩

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
  have := (h.get (p := warden) (by rw [wgs_allCards]; simp) (List.mem_singleton.2 rfl)
    (guardUp.script_mem (some .active))).1 rfl
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
  ⟨"Retrieve", u, none, none, .fx (.move .own .discard .hand (.named "Iron Defender") (.upTo 1))⟩

def keeper (u : AbilityUse) : PokemonCard :=
  ⟨"Keeper", .basic, none, 10, .metal, [], 1, none, none, .none, false, [retrieve u]⟩

def kAt (u : AbilityUse) (b : Bool) : InPlay := { InPlay.ofBasic (keeper u) with used := b }

def kpl (u : AbilityUse) (hand discard : List Card) (r : Nat) (b : Bool) : PlayerState :=
  ⟨[], hand, discard, [.energy .metal], [], some (kAt u b), [], false, false, false,
    false, false, store r, true⟩

def kgs (u : AbilityUse) (hand discard : List Card) (r : Nat) (b : Bool) : GameState :=
  ⟨kpl u hand discard r b, Recycle.pl [] [] 0, true, false, false, false, none, none, false, false⟩

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

/-! ## Witnesses (milestone M8a) -/

/-- An "as often as you like" Ability used twice in one turn: two uses of `guardUp`. -/
theorem unlimited_twice : Reach (wgs 0 false) (wgs 6 true) := reach_wgs 2

theorem settled_two {g : GameState} {a b : InPlay} (hc : g.cur.active = some a)
    (ho : g.opp.active = some b) (ha : a.damage < a.top.hp) (hb : b.damage < b.top.hp)
    (h1 : g.cur.bench = []) (h2 : g.opp.bench = []) : Settled g :=
  Trainer.settled_of hc ho ha hb (by rw [h1]; intro p hp; cases hp) (by rw [h2]; intro p hp; cases hp)

/-- "Once during your turn, you may use this Ability. During this turn, your attacks do 10 more
damage": a once-per-turn Ability whose use is visible in the store. -/
def charge : Ability := ⟨"Charge", .once, none, none, .fx (.linger .own .now (.bonus 1))⟩

def charger : PokemonCard :=
  ⟨"Charger", .basic, none, 10, .grass, [], 1, none, none, .none, false, [charge]⟩

def chargerAt (u : Bool) : InPlay := { InPlay.ofBasic charger with used := u }

def bonusStore (b : Nat) : Store := ⟨{ Mods.empty with bonus := b }, Mods.empty, Mods.empty, Mods.empty⟩

def cpl (u : Bool) (b : Nat) : PlayerState :=
  ⟨[.energy .grass], [], [], [.energy .grass], [], some (chargerAt u), [], false, false, false,
    false, false, bonusStore b, true⟩

def bpl : PlayerState :=
  ⟨[.energy .metal], [], [], [.energy .metal], [], some (InPlay.ofBasic Recycle.guard), [], false,
    false, false, false, false, Store.empty, true⟩

/-- The charger's player to move, in the turn proper, `u` whether it has used its Ability. -/
def cgs (u : Bool) (b : Nat) : GameState := ⟨cpl u b, bpl, true, false, false, false, none, none, false, false⟩

theorem cgs_settled (u : Bool) (b : Nat) : Settled (cgs u b) :=
  settled_two rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide) rfl rfl

/-- The first use of the once-per-turn Ability. -/
theorem once_first : Move (cgs false 0) (cgs true 1) :=
  .ability (ab := charge) (.active rfl) (.head _) rfl rfl (fun _ => rfl) trivial rfl
    (cgs_settled _ _) rfl
    (.prim rfl rfl (.linger .own .now (.bonus 1) _) (.done (.inl (cgs_settled _ _)))) rfl rfl

/-- **A once-per-turn Ability is refused the second time**: once the charger has used it, no
Pokémon of the player to move can use an Ability with the premises of `Move.ability` (its only
Pokémon is the charger, its only Ability is `charge`, a "once during your turn" Ability, and the
charger has used an Ability this turn). -/
theorem once_refused (b : Nat) : ¬ ∃ (g₁ : GameState) (x : InPlay) (sp : Spot) (ab : Ability),
    UseAt (cgs true b) x sp g₁ ∧ ab ∈ x.top.abilities ∧ (ab.use = .once → x.used = false) := by
  rintro ⟨g₁, x, sp, ab, hu, hm, hn⟩
  cases hu with
  | active ha =>
      simp only [cgs, cpl, Option.some.injEq] at ha
      subst ha
      simp only [chargerAt, InPlay.ofBasic, charger, List.mem_singleton] at hm
      subst hm
      exact absurd (hn rfl) (by decide)
  | bench hb => simp [cgs, cpl] at hb

/-- **…and is available again in the player's next turn**: from the state after the first use,
the player ends the turn (the use flag is cleared, and this turn's bonus expires), the opponent
draws and ends their turn, the player draws, and the charger uses its Ability again (the bonus in
effect rises by one). -/
theorem once_again : ∃ g g', Reach (cgs true 1) g ∧ g.curIsFirst = true ∧ g.between = false ∧
    Move g g' ∧ g'.cur.mods.now.bonus = g.cur.mods.now.bonus + 1 := by
  refine ⟨_, _, .step (.step (.step (.step (.refl _) rfl
      (.endTurn false false false false false false rfl rfl (cgs_settled true 1).1 rfl .nil .nil))
      rfl (.startTurn rfl rfl rfl
        (settled_two rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide) rfl rfl).1 rfl))
      rfl (.endTurn false false false false false false rfl rfl
        (settled_two rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide) rfl rfl).1 rfl
        .nil .nil))
      rfl (.startTurn rfl rfl rfl
        (settled_two rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide) rfl rfl).1 rfl),
    rfl, rfl, .ability (ab := charge) (.active rfl) (.head _) rfl rfl (fun _ => rfl) trivial rfl
      (settled_two rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide) rfl rfl) rfl
      (.prim rfl rfl (.linger .own .now (.bonus 1) _)
        (.done (.inl (settled_two rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide) rfl
          rfl)))) rfl rfl, rfl⟩

/-- "When you play this Pokémon from your hand onto your Bench during your turn, you may draw a
card." -/
def scout : Ability := ⟨"Scout", .onPlay .bench, none, none, .fx .draw⟩

def scoutMon : PokemonCard :=
  ⟨"Scout", .basic, none, 6, .grass, [], 1, none, none, .none, false, [scout]⟩

def spl (hand deck : List Card) (bench : List InPlay) : PlayerState :=
  ⟨deck, hand, [], [.energy .grass], [], some (chargerAt false), bench, false, false, false,
    false, false, Store.empty, true⟩

def sgs (hand deck : List Card) (bench : List InPlay) : GameState :=
  ⟨spl hand deck bench, bpl, true, false, false, false, none, none, false, false⟩

/-- **An on-play Ability**: playing `scoutMon` from the hand onto the Bench triggers its Ability,
and the player draws a card. -/
theorem onPlay_witness :
    Move (sgs [.pokemon scoutMon] [.energy .grass] [])
      (sgs [.energy .grass] [] [InPlay.ofBasic scoutMon]) := by
  have hs : Settled (sgs [] [.energy .grass] [InPlay.ofBasic scoutMon]) :=
    Trainer.settled_of rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide)
      (fun p hp => by simp only [sgs, spl, List.mem_singleton] at hp; subst hp; decide)
      (fun p hp => by cases hp)
  have hs' : Settled (sgs [.energy .grass] [] [InPlay.ofBasic scoutMon]) :=
    Trainer.settled_of rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide)
      (fun p hp => by simp only [sgs, spl, List.mem_singleton] at hp; subst hp; decide)
      (fun p hp => by cases hp)
  exact .onPlay (ab := scout) (.basic (l₁ := []) (l₂ := []) rfl rfl (by decide) (by decide) rfl
      (settled_two rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide) rfl rfl) rfl)
    (.head _) rfl rfl hs trivial (.prim rfl rfl (.draw rfl) (.done (.inl hs'))) rfl rfl

/-! ### The harmless loops of survey S10

Mega Venusaur ex me1-3, Solar Transfer: "As often as you like during your turn, you may use this
Ability. Move a Basic Grass Energy from 1 of your Pokémon to another of your Pokémon." Moving one
Grass Energy to a Benched Pokémon and back returns to the same state, so a state is reachable from
itself by Ability moves, as often as the player likes: play need not terminate. That is why the
finiteness theorems (`Reach.finite`, `Faithful.xfinite`) are about the state space (a finite
quotient, with a bisimulation), not about the length of play. Nothing accumulates: the loop
changes no store, card zone or flag. Team Rocket's Orbeetle sv10-89 does the same with a damage
counter (`Effect.moveCounter`). -/

def solarTransfer : Ability :=
  ⟨"Solar Transfer", .unlimited, none, none, .fx (.moveEnergy .own (.energyOf .grass))⟩

def venusaur : PokemonCard :=
  ⟨"Mega Venusaur ex", .stage2, some "Ivysaur", 36, .grass, [], 3, none, none, .megaEx, false,
    [solarTransfer]⟩

def sprout : PokemonCard := ⟨"Sprout", .basic, none, 6, .grass, [], 1, none, none, .none, false, []⟩

/-- Venusaur Active, having used an Ability or not, with the Grass Energy on it (`onV`) or on the
Benched sprout. -/
def vpl (u onV : Bool) : PlayerState :=
  ⟨[], [], [], [.energy .grass], [],
    some { InPlay.ofBasic venusaur with used := u, energy := if onV then [.energy .grass] else [] },
    [{ InPlay.ofBasic sprout with energy := if onV then [] else [.energy .grass] }], false, false,
    false, false, false, Store.empty, true⟩

def vgs (u onV : Bool) : GameState := ⟨vpl u onV, bpl, true, false, false, false, none, none, false, false⟩

theorem vgs_settled (u onV : Bool) : Settled (vgs u onV) :=
  Trainer.settled_of rfl rfl (show 0 < 36 by decide) (show 0 < 10 by decide)
    (fun p hp => by
      simp only [vgs, vpl, List.mem_singleton] at hp; subst hp; exact (show 0 < 6 by decide))
    (fun p hp => by cases hp)

/-- Move the Grass Energy from Venusaur to the sprout. -/
theorem vmove1 (u : Bool) : Move (vgs u true) (vgs true false) :=
  .ability (ab := solarTransfer) (.active rfl) (.head _) rfl rfl (fun h => nomatch h) trivial rfl
    (vgs_settled _ _) rfl
    (.prim rfl rfl
      (.zone (w := .own) rfl (.moveAB (e₁ := []) (e₂ := []) (b₁ := []) (b₂ := []) rfl rfl rfl rfl))
      (.done (.inl (vgs_settled true false))))
    rfl rfl

/-- Move it back. -/
theorem vmove2 : Move (vgs true false) (vgs true true) :=
  .ability (ab := solarTransfer) (.active rfl) (.head _) rfl rfl (fun h => nomatch h) trivial rfl
    (vgs_settled _ _) rfl
    (.prim rfl rfl
      (.zone (w := .own) rfl (.moveBA (e₁ := []) (e₂ := []) (b₁ := []) (b₂ := []) rfl rfl rfl rfl))
      (.done (.inl (vgs_settled true true))))
    rfl rfl

/-- **A state reachable from itself by Ability moves** (survey S10's card-neutral loop): from
the start, one use of Solar Transfer reaches `vgs true false`, and two more uses return to it,
through a different state. -/
theorem venusaur_loop :
    Reach (vgs false true) (vgs true false) ∧ vgs true true ≠ vgs true false ∧
      Move (vgs true false) (vgs true true) ∧ Move (vgs true true) (vgs true false) :=
  ⟨.step (.refl _) rfl (vmove1 false), fun h => by
    have := congrArg (fun g : GameState => g.cur.bench.map InPlay.energy) h
    simp [vgs, vpl, InPlay.ofBasic] at this, vmove2, vmove1 true⟩

/-- Team Rocket's Orbeetle sv10-89, Rocket Brain: "As often as you like during your turn, you may
move 1 damage counter from 1 of your Team Rocket's Pokémon to another of your Pokémon." The filter
"Team Rocket's Pokémon" (a name prefix) is not expressible; `.pokemon` admits every Pokémon, a
superset. -/
def rocketBrain : Ability :=
  ⟨"Rocket Brain", .unlimited, none, none, .fx (.moveCounter .pokemon false)⟩

def orbeetle : PokemonCard :=
  ⟨"Team Rocket's Orbeetle", .stage1, some "Team Rocket's Blipbug", 12, .psychic, [], 1, none,
    none, .none, false, [rocketBrain]⟩

/-- Orbeetle Active with the damage counter on it (`onO`) or on the Benched sprout. -/
def opl (u onO : Bool) : PlayerState :=
  ⟨[], [], [], [.energy .grass], [],
    some { InPlay.ofBasic orbeetle with used := u, damage := if onO then 1 else 0 },
    [{ InPlay.ofBasic sprout with damage := if onO then 0 else 1 }], false, false,
    false, false, false, Store.empty, true⟩

def ogs (u onO : Bool) : GameState := ⟨opl u onO, bpl, true, false, false, false, none, none, false, false⟩

theorem ogs_settled (u onO : Bool) : Settled (ogs u onO) := by
  cases onO
  · exact Trainer.settled_of rfl rfl (show 0 < 12 by decide) (show 0 < 10 by decide)
      (fun p hp => by
        simp only [ogs, opl, List.mem_singleton] at hp; subst hp; exact (show 1 < 6 by decide))
      (fun p hp => by cases hp)
  · exact Trainer.settled_of rfl rfl (show 1 < 12 by decide) (show 0 < 10 by decide)
      (fun p hp => by
        simp only [ogs, opl, List.mem_singleton] at hp; subst hp; exact (show 0 < 6 by decide))
      (fun p hp => by cases hp)

theorem omove1 (u : Bool) : Move (ogs u true) (ogs true false) :=
  .ability (ab := rocketBrain) (.active rfl) (.head _) rfl rfl (fun h => nomatch h) trivial rfl
    (ogs_settled _ _) rfl
    (.prim rfl rfl
      (.moveCounter (.ab (b₁ := []) (b₂ := []) rfl (show 0 < 1 by decide) (fun h => nomatch h)))
      (.done (.inl (ogs_settled true false))))
    rfl rfl

theorem omove2 : Move (ogs true false) (ogs true true) :=
  .ability (ab := rocketBrain) (.active rfl) (.head _) rfl rfl (fun h => nomatch h) trivial rfl
    (ogs_settled _ _) rfl
    (.prim rfl rfl
      (.moveCounter (.ba (b₁ := []) (b₂ := []) rfl (show 0 < 1 by decide) (fun h => nomatch h)))
      (.done (.inl (ogs_settled true true))))
    rfl rfl

/-- **The damage-counter loop**: Rocket Brain moves the counter to the Benched sprout and back. -/
theorem orbeetle_loop :
    Reach (ogs false true) (ogs true false) ∧ ogs true true ≠ ogs true false ∧
      Move (ogs true false) (ogs true true) ∧ Move (ogs true true) (ogs true false) :=
  ⟨.step (.refl _) rfl (omove1 false), fun h => by
    have := congrArg (fun g : GameState => g.cur.bench.map InPlay.damage) h
    simp [ogs, opl, InPlay.ofBasic] at this, omove2, omove1 true⟩

/-! ### A printed once-per-turn writer: Feraligatr -/

/-- Feraligatr sv5-41, Torrential Heart: "Once during your turn, you may put 5 damage counters on
this Pokémon. If you do, during this turn, attacks used by this Pokémon do 120 more damage to your
opponent's Active Pokémon (before applying Weakness and Resistance)." The bonus is the player's
(the model's modifiers are per player, milestone M7). This is a departure, not a superset: the
bonus applies to whichever of the player's Pokémon attacks (after a retreat the printed card
gives the new attacker no bonus, the model does; two uses on two Feraligatr add up on one
attacker; a replacement inherits it). -/
def torrentialHeart : Ability :=
  ⟨"Torrential Heart", .once, none, none,
    .seq (.self (.counters 5)) (.fx (.linger .own .now (.bonus 12)))⟩

def feraligatr : PokemonCard :=
  ⟨"Feraligatr", .stage2, some "Croconaw", 18, .water, [], 3, some .lightning, none, .none, false,
    [torrentialHeart]⟩

/-- A deck with Feraligatr and the Iron Defender-like Item is faithful: a once-per-turn Ability may
write a damage bonus. -/
theorem feraligatr_faithful :
    (⟨⟨[], [ironDefender], [], [.energy .water], [], some (InPlay.ofBasic feraligatr), [], false,
      false, false, false, false, Store.empty, true⟩, Recycle.pl [] [] 0, true, false, false,
      false, none, none, false, false⟩ : GameState).Faithful := by
  refine ⟨by unfold GameState.LoopFree; decide, ?_, by unfold GameState.RecycleSafe; decide,
    by unfold GameState.AbilitySafe; decide⟩
  intro p hp atk hm
  simp [GameState.allCards, PlayerState.allCards, optCardList, benchCardList, InPlay.cardList,
    InPlay.ofBasic, stadiumCardList, ironDefender, Recycle.pl] at hp
  rcases hp with rfl | rfl <;> cases hm

end Pokemon.Abilities
