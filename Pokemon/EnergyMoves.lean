import Pokemon.Bench

/-!
# Attached Energy to a zone, and directed Energy moves (milestone MV11, survey S25)

Two zone primitives (semantics `ZStep`, lifted by `Run.zone`):

* `Effect.returnEnergy w sp f q d`: Energy cards attached to one of the `w` player's Pokémon at `sp`
  go to `d` (hand, deck, discard pile), counted as `discardEnergy` counts them. "Put an Energy
  attached to this Pokémon into your hand" (Chien-Pao svp-152), "You may put 2 Energy attached to
  your opponent's Active Pokémon into their hand" (Unfezant sv5-135), "shuffle all Energy attached to
  this Pokémon into your deck" (Dialga me1-95).
* `Effect.shiftEnergy w src f q dst one`: Energy cards move from one Pokémon at `src` to the Pokémon
  at `dst` (Active Spot to Bench or Bench to Active Spot): all to one chosen Pokémon (`one`), or in
  any way you like. "Move all Energy from this Pokémon to 1 of your Benched Pokémon" (Castform Sunny
  Form sv8-20); "… to your Benched Pokémon in any way you like" (Kilowattrel sv8-67).

**What they keep.** Both are zone steps: they change only the five zones of one player
(`ZStep.setZones`), permute that player's cards (`ZStep.count`, so `Reach.perm` holds unchanged),
change no damage, Special Condition, marker or store, and are simulated by the kernel of every
clamp at any caps (`ZStep.sim`, which covers `clamp` and `xclamp`). No new state: the finite lists
of `Enum` are lists of the same states. For the store bound (`StoreSafe`): neither takes a card out of
a discard pile (`Run.disc_mono`; `Effect.recFilters` is `[]` for both), and neither raises the
potential `abPot` (`ZStep.abPot_le`). `returnEnergy` returns a card from play to the hand or deck,
where it can be played again; the cards it moves are the cards attached to a Pokémon as Energy,
and playing a card from the hand writes a stored amount only if it is an Item (`Card.wAmt`), whose
writes the per-turn invariant pays by its arrival in the discard pile. So the five clauses and their
proofs are unchanged.

**Witnesses** (Item cards, legal moves from well-formed, `Settled` starts) and **general facts**
about every resolution:
* `recall_hand`: a Fire Energy attached to the Active Pokémon goes to the hand (positive);
  `recall_none_of_type`: a Water-only `returnEnergy` has no resolution there (negative: the filter is
  read); `returnEnergy_all_leaves`: for every resolution of a `.all` return from the Active Pokémon,
  no card passing the filter is left on it.
* `shift_one`: both Energy cards of the Active Pokémon move to one Benched Pokémon (positive);
  `shiftTo_one_target`: for every resolution with `one = true`, the Bench changes at one place only
  (negative: no split between two Benched Pokémon); `shift_many`: with `one = false` the two cards
  go to two Benched Pokémon; `shift_all_leaves`: with `.all` nothing passing the filter is left on the
  Active Pokémon.
-/

namespace Pokemon.EnergyMoves

open Trainer

/-- The player's Active Pokémon, with a Fire and a Water Energy attached. -/
def charged : InPlay := { InPlay.ofBasic big with energy := [.energy .fire, .energy .water] }

def benchA : InPlay := InPlay.ofBasic { big with name := "BenchA" }
def benchB : InPlay := InPlay.ofBasic { big with name := "BenchB" }

/-- The player to move has `charged` Active, `benchA` and `benchB` on the Bench, and `c` in hand. -/
def start (c : Card) : GameState :=
  ⟨side [c] [.energy .fire] charged [benchA, benchB],
    side [] [.energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none, false, false, false⟩

theorem start_wellFormed (c : Card) : WellFormed (start c) := by
  refine ⟨fun _ => ⟨by simp [start, Trainer.side], by simp [start, Trainer.side]⟩,
    fun p hp => ?_, (fun p hp => by cases hp), .of_b rfl⟩
  simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem start_settled (c : Card) : Settled (start c) :=
  settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by
      simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide)
    (fun p hp => by cases hp)

/-! ## `returnEnergy` -/

/-- "Put a Fire Energy attached to your Active Pokémon into your hand." -/
def recallFire : Card := .trainer "Recall" .item (.returnEnergy .own .active (.energyOf .fire) (.exactly 1) .hand)

/-- **Witness: Energy from play to the hand.** From the well-formed, `Settled` start, playing `recallFire`
is a legal move after which the Fire Energy is in the player's hand and the Active Pokémon keeps only
its Water Energy; the player's cards are the same cards (`Reach.perm`). -/
theorem recall_hand :
    WellFormed (start recallFire) ∧ Settled (start recallFire) ∧ ∃ g, Move (start recallFire) g ∧
      g.cur.hand = [.energy .fire] ∧ g.cur.active.map InPlay.energy = some [.energy .water] ∧
      g.cur.discard = [recallFire] := by
  have hm : Move (start recallFire) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Recall") rfl rfl (start_settled _)
      (.prim rfl rfl (.zone rfl (.retActive (t := [.energy .fire]) (r := [.energy .water]) rfl
          (.take rfl (.keep .nil)) (show retreatPaid 1 _ = true from rfl) (.hand _ _)))
        (.done (.inl (settled_of rfl rfl (by decide) (by decide)
          (by decide)
          (fun p hp => by cases hp))))) rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl, rfl, rfl⟩

/-- **The filter is read** (negative witness): a return of exactly one Grass Energy from the Active
Pokémon, which has none (only Fire and Water), has no resolution from the start state, so an Item with
that effect cannot be played there. -/
theorem recall_none_of_type (c : Card) :
    ¬ ∃ g, Run (.returnEnergy .own .active (.energyOf .grass) (.exactly 1) .hand) (start c) g := by
  rintro ⟨g, h⟩
  have key : ∀ {s s' : PlayerState}, s.active = some charged →
      ¬ ZStep (.returnEnergy .own .active (.energyOf .grass) (.exactly 1) .hand) s s' := by
    intro s s' hs hz
    cases hz with
    | @retActive _ _ _ _ _ _ a t r ha hsp hq _ =>
        rw [hs, Option.some.injEq] at ha
        subst ha
        have hx := hsp.taken
        have hm := hsp.mem
        match t, hx, hm, hq with
        | [], _, _, hq => simp [Qty.okE, retreatPaid] at hq
        | x :: _, hx, hm, _ =>
            have h1 := hx x (.head _)
            have h2 := hm x (.head _)
            simp only [charged, InPlay.ofBasic, List.mem_cons, List.not_mem_nil, or_false] at h2
            rcases h2 with rfl | rfl <;> revert h1 <;> decide
  match h with
  | .zone hw hz => cases hw; exact key rfl hz
  | .touchActive he _ => simp [Effect.touch] at he
  | .touchBench he _ => simp [Effect.touch] at he

/-- **General: a return of `all` leaves nothing that passes the filter** on the Pokémon it takes from
(for every resolution at the Active Spot, in every state). -/
theorem returnEnergy_all_leaves {w : Whose} {f : Filter} {d : Dst} {s s' : PlayerState}
    (h : ZStep (.returnEnergy w .active f .all d) s s') :
    ∀ a ∈ s'.active, ∀ x ∈ a.energy, f.eval x = false := by
  cases h with
  | @retActive _ _ _ _ _ _ a t r ha hs hq hp =>
      intro a' ha' x hx
      rw [hp.fields.2.1] at ha'
      simp only [Option.mem_def, Option.some.injEq] at ha'
      subst ha'
      exact hq x hx

/-! ## `shiftEnergy` -/

/-- "Move all Energy from your Active Pokémon to 1 of your Benched Pokémon." -/
def sunny : Card := .trainer "Sunny" .item (.shiftEnergy .own .active .energy .all .bench true)

/-- "Move all Energy from your Active Pokémon to your Benched Pokémon in any way you like." -/
def storm : Card := .trainer "Storm" .item (.shiftEnergy .own .active .energy .all .bench false)

/-- **Witness: all Energy to one Benched Pokémon.** Playing `sunny` from the well-formed, `Settled`
start is a legal move after which `benchB` carries both Energy cards, `benchA` none, and the Active
Pokémon none. -/
theorem shift_one :
    WellFormed (start sunny) ∧ Settled (start sunny) ∧ ∃ g, Move (start sunny) g ∧
      g.cur.active.map InPlay.energy = some [] ∧
      g.cur.bench.map InPlay.energy = [[], [.energy .water, .energy .fire]] := by
  have hd : Deal .any [.energy .fire, .energy .water] none [benchB] none
      [{ benchB with energy := [.energy .water, .energy .fire] }] :=
    .bench (b₁ := []) (b₂ := []) rfl rfl (.bench (b₁ := []) (b₂ := []) rfl rfl (.nil _ _))
  have hm : Move (start sunny) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Sunny") rfl rfl (start_settled _)
      (.prim rfl rfl (.zone rfl (.shiftAB (t := [.energy .fire, .energy .water]) (r := []) rfl
          (.take rfl (.take rfl .nil)) (fun _ h => nomatch h) (.one (b₁ := [benchA]) (b₂ := []) hd)))
        (.done (.inl (settled_of rfl rfl (by decide) (by decide)
          (by decide)
          (fun p hp => by cases hp))))) rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl, rfl⟩

/-- **General: "to 1 of your Benched Pokémon" changes one place of the Bench** (negative: the cards
are never split between two Benched Pokémon), for every resolution in every state. -/
theorem shiftTo_one_target {t : List Card} {b b' : List InPlay} (h : ShiftTo t true b b') :
    ∃ b₁ q q' b₂, b = b₁ ++ q :: b₂ ∧ b' = b₁ ++ q' :: b₂ := by
  cases h with
  | @one q q' b₁ b₂ _ => exact ⟨b₁, q, q', b₂, rfl, rfl⟩

/-- **Witness: "in any way you like".** Playing `storm` from the well-formed, `Settled` start is a
legal move after which `benchA` carries the Fire Energy and `benchB` the Water Energy. -/
theorem shift_many :
    WellFormed (start storm) ∧ Settled (start storm) ∧ ∃ g, Move (start storm) g ∧
      g.cur.active.map InPlay.energy = some [] ∧
      g.cur.bench.map InPlay.energy = [[.energy .fire], [.energy .water]] := by
  have hd : Deal .any [.energy .fire, .energy .water] none [benchA, benchB] none
      [{ benchA with energy := [.energy .fire] }, { benchB with energy := [.energy .water] }] :=
    .bench (b₁ := []) (b₂ := [benchB]) rfl rfl
      (.bench (b₁ := [{ benchA with energy := [.energy .fire] }]) (b₂ := []) rfl rfl (.nil _ _))
  have hm : Move (start storm) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Storm") rfl rfl (start_settled _)
      (.prim rfl rfl (.zone rfl (.shiftAB (t := [.energy .fire, .energy .water]) (r := []) rfl
          (.take rfl (.take rfl .nil)) (fun _ h => nomatch h) (.many hd)))
        (.done (.inl (settled_of rfl rfl (by decide) (by decide)
          (by decide)
          (fun p hp => by cases hp))))) rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl, rfl⟩

/-- **General: a move of `all` from the Active Pokémon leaves nothing that passes the filter on it**
(for every resolution in every state with a Bench; with an empty Bench nothing moves). -/
theorem shift_all_leaves {w : Whose} {f : Filter} {one : Bool} {s s' : PlayerState}
    (h : ZStep (.shiftEnergy w .active f .all .bench one) s s') (hb : s.bench ≠ []) :
    ∀ a ∈ s'.active, ∀ x ∈ a.energy, f.eval x = false := by
  cases h with
  | @shiftAB _ _ _ _ _ a t r b' ha hs hq hd =>
      intro a' ha' x hx
      simp only [Option.mem_def, Option.some.injEq] at ha'
      subst ha'
      exact hq x hx
  | shiftNone hb' => exact absurd hb' hb

end Pokemon.EnergyMoves
