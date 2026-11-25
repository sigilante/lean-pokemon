import Pokemon.IfDo
import Pokemon.Special

/-!
# Energy by what it provides (milestone MV8, stage 1)

Survey S22. The rulebook reads Energy by what it provides wherever it pays or counts Energy: an
attack cost ("You need the right amount of Energy attached", "the ✱ means that any type of Energy
can be used", rulebook 2026 p. 13) and a Retreat Cost ("you must discard 1 Energy from your Active
Pokémon for each [✱] listed in its Retreat Cost", p. 12; glossary, "you must discard Energy from the
retreating Pokémon equal to the Retreat Cost", p. 45); a card is attached ("Attach an Energy card to
one of your Pokémon (once per turn)", p. 11) and discarded as a card. Since this milestone the model
reads every such place through one function, `Card.unitsOn` (what a card provides attached to a given
holder):

* attack costs: `Pays cost a.units` (unchanged in form; `InPlay.units` reads `Card.unitsOn`);
* the Retreat Cost: the cards discarded provide at least the cost with none superfluous
  (`retreatPaid`; `Move.retreat`);
* "for each Energy attached": `Count.energy`, `Count.energyAll` count what the cards provide under
  `Filter.energy`, and cards under every other filter (`Filter.weight`, `InPlay.energyCount`);
* "discard `n` Energy": `discardEnergy` takes cards that provide `n` with none superfluous
  (`Qty.okE`; `ZStep.discardActive`, `ZStep.discardBench`).

What stays by card, and why: `Filter.energyOf t` reads Basic Energy only, because the same filter
writes "Basic [◉] Energy card" in a hand, deck or discard pile, where a Special Energy card provides
nothing ("As long as this card is attached to a Pokémon, it provides …"); so "a [◉] Energy attached"
does not see a Special Energy card that provides `t` (a subset of print; Known gaps).
`Count.energyTypes` counts the types of Basic Energy cards, as its printed text says. A static amount
"for each [◉] Energy attached" (`SAmt.perEnergy`) and a static Energy condition (`Static.need`) count
cards (Known gaps). Moving Energy moves a card, with what it provides.

**Basic Energy is unchanged** (`InPlay.units_basic`, `InPlay.energyCount_basic`,
`retreatPaid_basic`, `Qty.okE_basic`): with only Basic Energy attached every changed function equals
the old one, so no generated card and no theorem about Basic Energy decks changes meaning.

Witnesses with Team Rocket's Energy (its provision, "2 in any combination of Psychic Energy and
Darkness Energy"): it alone pays a Retreat Cost of 2 (`retreat_two`), counts 2 for "for each Energy
attached" (`count_two`), and is the one card discarded by "discard 2 Energy" (`discard_two`).
-/

namespace Pokemon

/-- Every card attached to the Pokémon is a Basic Energy card. -/
def InPlay.BasicOnly (p : InPlay) : Prop := ∀ c ∈ p.energy, ∃ t : BasicEnergy, c = .energy (.basic t)

/-- **With Basic Energy only, the units are the cards' printed units** (the definition before
milestone MV8). -/
theorem InPlay.units_basic (p : InPlay) : p.units = p.energy.flatMap Card.provides := rfl

/-- With Basic Energy only, every card counts one Energy. -/
theorem InPlay.unitCount_basic {p : InPlay} (h : p.BasicOnly) {c : Card} (hc : c ∈ p.energy) :
    p.unitCount c = 1 := by
  obtain ⟨t, rfl⟩ := h c hc
  rfl

/-- **With Basic Energy only, a Retreat Cost of `n` is paid by `n` cards** (the premise before
milestone MV8). -/
theorem retreatPaid_basic {p : InPlay} (h : p.BasicOnly) {paid : List Card}
    (hs : ∀ c ∈ paid, c ∈ p.energy) (n : Nat) :
    retreatPaid n (paid.map p.unitCount) = true ↔ paid.length = n := by
  rw [retreatPaid_ones, List.length_map]
  intro u hu
  obtain ⟨c, hc, rfl⟩ := List.mem_map.1 hu
  exact InPlay.unitCount_basic h (hs c hc)

/-- With Basic Energy only, the weights are the card counts. -/
theorem InPlay.weight_basic {p : InPlay} (h : p.BasicOnly) (f : Filter) {c : Card}
    (hc : c ∈ p.energy) : f.weightOn p.top p.energy c = if f.eval c then 1 else 0 := by
  obtain ⟨t, rfl⟩ := h c hc
  exact Filter.weight_basic f _ _ t

/-- **With Basic Energy only, "for each Energy attached" counts cards** (the count before
milestone MV8). -/
theorem InPlay.energyCount_basic {p : InPlay} (h : p.BasicOnly) (f : Filter) :
    p.energyCount f = p.energy.countP f.eval := by
  unfold InPlay.energyCount
  have : ∀ l : List Card, (∀ c ∈ l, c ∈ p.energy) →
      (l.map (f.weightOn p.top p.energy)).sum = l.countP f.eval := by
    intro l hl
    induction l with
    | nil => rfl
    | cons c l ih =>
        rw [List.map_cons, List.sum_cons, List.countP_cons, InPlay.weight_basic h f (hl c (.head _)),
          ih fun x hx => hl x (.tail _ hx)]
        cases f.eval c <;> simp only [Bool.false_eq_true, ↓reduceIte] <;> exact Nat.add_comm _ _
  exact this _ fun _ hc => hc

/-- **With Basic Energy only, an Energy discard counts cards** (the quantity before milestone MV8). -/
theorem Qty.okE_basic {p : InPlay} (h : p.BasicOnly) {q : Qty} {f : Filter} {t r : List Card}
    (hs : Split f p.energy t r) : q.okE (f.weightOn p.top p.energy) f t r ↔ q.ok f t r := by
  refine Qty.okE_ones fun x hx => ?_
  rw [InPlay.weight_basic h f (hs.mem x hx), hs.taken x hx]
  rfl

namespace Units

open Trainer Special

/-- A Pokémon with a Retreat Cost of 2. -/
def heavy : PokemonCard := ⟨"Heavy", .basic, none, 10, .psychic, [], 2, none, none, .none, false, []⟩

/-- `heavy` with Team Rocket's Energy attached. -/
def heavyTR : InPlay := { InPlay.ofBasic heavy with energy := [trE] }

/-- The player to move has `heavyTR` Active and `big` on the Bench. -/
def rStart : GameState :=
  ⟨side [] [.energy .fire] heavyTR [InPlay.ofBasic big],
    side [] [.energy .fire] (InPlay.ofBasic big) [], true, false, false, false, none, none, false,
    false, false⟩

theorem rStart_settled : Settled rStart := (GameState.settled_iff _).2 (by decide)

/-- **Witness: one card that provides 2 Energy pays a Retreat Cost of 2.** -/
theorem retreat_two : ∃ g', Move rStart g' ∧ g'.cur.discard = [trE] :=
  ⟨_, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl (.take rfl .nil) (by decide) rfl rfl
    rStart_settled rfl rfl, rfl⟩

/-- "For each Energy attached" counts what the cards provide; "for each Special Energy card" counts
cards. -/
theorem count_two :
    (Count.energy .own .energy).val rStart = 2 ∧ (Count.energy .own .specialEnergy).val rStart = 1 :=
  by decide

/-- **Witness: "discard 2 Energy from this Pokémon" discards the one card that provides 2.** -/
theorem discard_two : ∃ g, Run (.discardEnergy .own .active .energy (.exactly 2)) rStart g ∧
    g.cur.discard = [trE] :=
  ⟨_, .zone rfl (.discardActive rfl (.take rfl .nil) (show retreatPaid 2 _ = true by decide)), rfl⟩

/-- **A card that provides 2 is not superfluous, nor is a second card**: with Team Rocket's Energy
and a Basic Energy attached, a Retreat Cost of 2 is not paid by discarding both (the Basic Energy is
superfluous), and is paid by Team Rocket's Energy alone. -/
theorem paid_minimal : retreatPaid 2 [2, 1] = false ∧ retreatPaid 2 [2] = true ∧
    retreatPaid 2 [1, 1] = true ∧ retreatPaid 1 [2] = true := by decide

end Units

end Pokemon
