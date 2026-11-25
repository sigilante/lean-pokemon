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
reads the following places through one function, `Card.unitsOn` (what a card provides attached to a
given holder); not every count of Energy does (see "What stays by card" below):

* attack costs: `Pays cost a.units` (unchanged in form; `InPlay.units` reads `Card.unitsOn`);
* the Retreat Cost: the cards discarded provide at least the cost with none superfluous
  (`retreatPaid`; `Move.retreat`);
* "for each Energy attached": `Count.energy`, `Count.energyAll` count what the cards provide under
  the filter `Filter.energy` written as such, and cards under every other filter (`Filter.weight`,
  `InPlay.energyCount`; the test is syntactic, so `or energy energy` counts cards: `weight_syntactic`);
* "discard `n` Energy": `discardEnergy` takes cards that provide `n` with none superfluous
  (`Qty.okE`; `ZStep.discardActive`, `ZStep.discardBench`). So the `forUpTo` writing of "discard up
  to N Energy, K more damage for each card discarded" reads its branch as Energy, not cards: one card
  that provides 2 can pay for 2K (`forUpTo_one_card`, Known gaps), and with N = 2 a 2-unit card and a
  1-unit card are never discarded together (`forUpTo_no_pair`); with Basic Energy only the branch is
  the number of cards (`Run.forUpTo_discardActive_basic`).

What stays by card, and why: `Filter.energyOf t` reads Basic Energy only, because the same filter
writes "Basic [◉] Energy card" in a hand, deck or discard pile, where a Special Energy card provides
nothing ("As long as this card is attached to a Pokémon, it provides …"); so "a [◉] Energy attached"
does not see a Special Energy card that provides `t` (a subset of print; Known gaps).
`Count.energyTypes` counts the types of Basic Energy cards, as its printed text says. A static amount
"for each [◉] Energy attached" (`SAmt.perEnergy`) and a static Energy condition (`Static.need`) count
cards (Known gaps). Moving Energy moves a card, with what it provides.

**Basic Energy, function by function.** With only Basic Energy attached to a Pokémon, each function
milestone MV8 changed equals its old definition on that Pokémon: `InPlay.units_basic` (attack costs),
`InPlay.energyCount_basic` (counts), `retreatPaid_basic` (the Retreat Cost), `Qty.okE_basic` and
`Run.discardActive_does_basic` (Energy discards: `n` cards), `InPlay.statics_basic`,
`InPlay.attacks_basic`, `InPlay.abilities_basic` (the payload path adds nothing), `Card.attachOk_basic`
(no restriction), and `GameState.retreatOf_of_noRetreat_false` (the Retreat Cost formula, under the
hypothesis that no `noRetreat` effect is in force, which Basic Energy alone does not discharge). These
are per-function lemmas. That the `Move` relation, or any theorem about Basic Energy decks, means the
same as before on Basic-only states is NOT proved; several statements changed in text (listed in the
README, milestone MV8; among them the premises of `Move.retreat`, `Move.attach` and the other attachment moves, of
`ZStep.discardActive`, `ZStep.discardBench`, and `IfDo.discardActive_le`, `Run.discardActive_does`,
`InPlay.attacks_of_noTool`, `NoTS.tools` and the definition `NoTS`, `Special.special_inert`).

Witnesses with Team Rocket's Energy (its provision, "2 in any combination of Psychic Energy and
Darkness Energy"): it alone pays a Retreat Cost of 2 (`retreat_two`), counts 2 for "for each Energy
attached" (`count_two`), and is the one card discarded by "discard 2 Energy" (`discard_two`).
-/

namespace Pokemon

/-- Every card attached to the Pokémon is a Basic Energy card. -/
def InPlay.BasicOnly (p : InPlay) : Prop := ∀ c ∈ p.energy, ∃ t : BasicEnergy, c = .energy (.basic t)

/-- **With Basic Energy only, the units are the cards' printed units** (the definition before
milestone MV8). -/
theorem InPlay.units_basic {p : InPlay} (h : p.BasicOnly) :
    p.units = p.energy.flatMap Card.provides := by
  unfold InPlay.units
  have : ∀ l : List Card, (∀ c ∈ l, ∃ t : BasicEnergy, c = .energy (.basic t)) →
      l.flatMap (Card.unitsOn p.top p.energy) = l.flatMap Card.provides := by
    intro l hl
    induction l with
    | nil => rfl
    | cons c l ih =>
        obtain ⟨t, rfl⟩ := hl c (.head _)
        rw [List.flatMap_cons, List.flatMap_cons, ih fun x hx => hl x (.tail _ hx)]
        rfl
  exact this _ h

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

/-- With Basic Energy only, a discard of `n` Energy takes `n` cards (`Run.discardActive_does` with
`retreatPaid_ones`: every card taken weighs 1). -/
theorem Run.discardActive_does_basic {w : Whose} {f : Filter} {n : Nat} {g g' : GameState}
    {a : InPlay} (ha : (g.side w).active = some a) (hb : a.BasicOnly)
    (h : Run (.discardEnergy w .active f (.exactly n)) g g') :
    ∃ t r, Split f a.energy t r ∧ t.length = n ∧
      (g'.side w).active = some { a with energy := r } ∧
      (g'.side w).discard = t ++ (g.side w).discard := by
  obtain ⟨a', t, r, ha', hs, hq, h1, h2⟩ := Run.discardActive_does h
  obtain rfl : a' = a := Option.some.inj (ha'.symm.trans ha)
  have h1' : ∀ u ∈ t.map (f.weightOn a'.top a'.energy), u = 1 := by
    intro u hu
    obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hu
    rw [InPlay.weight_basic hb f (hs.mem x hx), hs.taken x hx]
    rfl
  have hl := (retreatPaid_ones h1').1 hq
  rw [List.length_map] at hl
  exact ⟨t, r, hs, hl, h1, h2⟩

/-- **With Basic Energy only, the branch of "discard any amount of Energy, K for each card" is the
number of cards discarded**: a resolution of the `forUpTo` form takes `j ≤ N` cards and then runs
the branch `k j`. Without `BasicOnly` this fails: one card that provides 2 is taken by the branches
`j = 1` and `j = 2` alike (`Units.forUpTo_one_card`). -/
theorem Run.forUpTo_discardActive_basic {w : Whose} {fl : Filter} {k : Nat → Effect}
    {g g' : GameState} {a : InPlay} {N : Nat} (ha : (g.side w).active = some a) (hb : a.BasicOnly)
    (h : Run (Effect.forUpTo (fun j => .seq (.discardEnergy w .active fl (.exactly j)) (k j)) N)
      g g') :
    ∃ j t r g₁, j ≤ N ∧ Split fl a.energy t r ∧ t.length = j ∧
      (g₁.side w).discard = t ++ (g.side w).discard ∧ Run (k j) g₁ g' := by
  obtain ⟨j, hj, h⟩ := Run.forUpTo_iff.1 h
  obtain ⟨g₁, h₁, h₂⟩ := Run.seq_inv h
  obtain ⟨t, r, hs, hl, -, hd⟩ := Run.discardActive_does_basic ha hb h₁
  exact ⟨j, t, r, g₁, hj, hs, hl, hd, h₂⟩

/-- A list of Basic Energy cards contributes nothing to a `flatMap` of a function that is empty on
Basic Energy. -/
theorem flatMap_basicOnly {β : Type} {F : Card → List β} (hF : ∀ t, F (.energy (.basic t)) = [])
    {l : List Card} (h : ∀ c ∈ l, ∃ t : BasicEnergy, c = .energy (.basic t)) : l.flatMap F = [] := by
  induction l with
  | nil => rfl
  | cons c l ih =>
      obtain ⟨t, rfl⟩ := h c (.head _)
      rw [List.flatMap_cons, hF, ih fun x hx => h x (.tail _ hx)]
      rfl

/-- **With Basic Energy only, the static effects of a Pokémon are its top card's and its Tools'**
(the definition before milestone MV8). -/
theorem InPlay.statics_basic {p : InPlay} (h : p.BasicOnly) :
    p.sv.statics = p.top.abilities.flatMap Ability.statics ++ p.tools.flatMap (Card.grantStatics p.top) := by
  show _ ++ _ ++ p.energy.flatMap (Card.grantStatics p.top) = _
  rw [flatMap_basicOnly (fun _ => rfl) h, List.append_nil]
  rfl

/-- **With Basic Energy only, a Pokémon's attacks are its top card's and its Tools'** (the definition
before milestone MV8). -/
theorem InPlay.attacks_basic {p : InPlay} (h : p.BasicOnly) :
    p.attacks = p.top.attacks ++ p.tools.flatMap (Card.grantAttacks p.top) := by
  unfold InPlay.attacks
  rw [flatMap_basicOnly (fun _ => rfl) h, List.append_nil]

/-- **With Basic Energy only, a Pokémon's Abilities are its top card's and its Tools'** (the
definition before milestone MV8). -/
theorem InPlay.abilities_basic {p : InPlay} (h : p.BasicOnly) :
    p.abilities = p.top.abilities ++ p.tools.flatMap (Card.grantAbilities p.top) := by
  unfold InPlay.abilities
  rw [flatMap_basicOnly (fun _ => rfl) h, List.append_nil]

/-- **A Basic Energy card may be attached to any Pokémon** (`Card.attachOk`, milestone MV8). -/
theorem Card.attachOk_basic (top : PokemonCard) (t : BasicEnergy) :
    (Card.energy (.basic t)).attachOk top = true := rfl

/-- **Without a `noRetreat` effect in force the Retreat Cost is the one before milestone MV8**. The
hypothesis is about every static effect in force (Abilities, Tools, the Stadium, Special Energy),
not about the attached Energy: Basic Energy alone does not discharge it. -/
theorem GameState.retreatOf_of_noRetreat_false {g : GameState} {a : InPlay}
    (h : (g.inForce .own .active a.sv).any Static.isNoRetreat = false) :
    g.retreatOf a = a.top.retreat + sumOf Static.retreatPlus (g.inForce .own .active a.sv) -
      sumOf Static.retreatMinus (g.inForce .own .active a.sv) := by
  unfold GameState.retreatOf
  rw [h]
  rfl

/-- With a `noRetreat` effect in force the Retreat Cost is 0, whatever is added (a reading: Known
gaps). -/
theorem GameState.retreatOf_of_noRetreat {g : GameState} {a : InPlay}
    (h : (g.inForce .own .active a.sv).any Static.isNoRetreat = true) : g.retreatOf a = 0 := by
  unfold GameState.retreatOf
  rw [h]
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

/-- "Discard up to 2 Energy from this Pokémon. This attack does 60 more damage for each card you
discarded in this way", written `forUpTo` as the importer writes it (`Pokemon/IfDo.lean`). -/
def erase : Effect :=
  Effect.forUpTo (fun j => .seq (.discardEnergy .own .active .energy (.exactly j))
    (.damage (.const (6 * j)))) 2

/-- **Witness: the branch index is not the number of cards** (Known gaps). From `rStart` the one
card Team Rocket's Energy is discarded by the branch `j = 1` and by the branch `j = 2`, so the
effect may do 120 for one card discarded, where print says 60. -/
theorem forUpTo_one_card : ∃ g₁ g₂, Run erase rStart g₁ ∧ Run erase rStart g₂ ∧
    g₁.cur.discard = [trE] ∧ g₂.cur.discard = [trE] ∧
    g₁.opp.active.map InPlay.damage = some 6 ∧ g₂.opp.active.map InPlay.damage = some 12 :=
  ⟨_, _,
    Run.forUpTo_iff.2 ⟨1, by decide, .seq (.zone rfl (.discardActive rfl (.take rfl .nil)
      (show retreatPaid 1 _ = true by decide))) (.damage (.const _ _) rfl)⟩,
    Run.forUpTo_iff.2 ⟨2, by decide, .seq (.zone rfl (.discardActive rfl (.take rfl .nil)
      (show retreatPaid 2 _ = true by decide))) (.damage (.const _ _) rfl)⟩,
    rfl, rfl, by decide, by decide⟩

/-- **Witness: no branch up to 2 takes a 2-unit card together with a 1-unit card** (Known gaps; fix
round of importer 0.15.0). A branch `j` of the `forUpTo` writing discards cards whose units pay `j`
with none superfluous (`Qty.okE` at `exactly j`, `retreatPaid`); for Team Rocket's Energy (2) and a
Basic Energy card (1) together, the payments 1 and 2 both have a superfluous card, so with `N = 2`
print's "discard both cards" (2K) is not a branch: fewer outcomes than print, beside the extra one of
`forUpTo_one_card`. A statement about the payment test, which every branch's discard requires, not
about `Run` as a whole. -/
theorem forUpTo_no_pair : retreatPaid 1 [2, 1] = false ∧ retreatPaid 2 [2, 1] = false ∧
    retreatPaid 3 [2, 1] = true := by decide

/-- **`Filter.weight` reads `Filter.energy` syntactically**: "for each Energy attached" counts 2 for
Team Rocket's Energy, but the equivalent filters `or energy energy` and `and energy any` count the
card once (Known gaps). -/
theorem weight_syntactic : (Count.energy .own .energy).val rStart = 2 ∧
    (Count.energy .own (.or .energy .energy)).val rStart = 1 ∧
    (Count.energy .own (.and .energy .any)).val rStart = 1 := by decide

end Units

end Pokemon
