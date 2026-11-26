import Pokemon.Immune
import Pokemon.Prevent
import Pokemon.Exact
import Pokemon.Lingering

/-!
# Threshold damage prevention (milestone MV14, survey S28)

Two printed forms read the amount of damage an attack would do and prevent it by a comparison with a
constant of the card:

* **static, "N or more"** (`SEff.preventGe t fr`): "Prevent all damage done to this Pokémon by attacks
  from your opponent's Pokémon if that damage is 200 or more" (Drednaw sv7-44, `t = 20`). Read, never
  stored: in the Active Spot by `GameState.dealt` / `GameState.dealtI` (`GameState.sThr`,
  `GameState.thrCut`) on the result of the calculation with every other effect applied; on the Bench by
  the damage forms of the Bench primitives (`GameState.benchThr` in `GameState.bAmt`) on the amount
  placed.
* **lingering, "N or less"** (`Mod.preventLe t`, stored as `Mods.upto`, merged by `max`): "During your
  opponent's next turn, prevent all damage done to this Pokémon by attacks if that damage is 60 or less"
  (Metapod sv9-2, `t = 6`; Roggenrola rsv10pt5-46, `t = 4`). Read at step 5 by `dealtBy` (`uptoCut`).

**The bound.** The static threshold is a constant of a card, like a test constant, and enters
`Card.tmax` (`Card.thrMax`; the old definition is `Card.testMax`). So `GameState.Fit`, `GameState.XFit`
and `Enum.bound` are unchanged in text; for a game whose cards carry no static threshold they are
unchanged in value (`Card.tmax_of_thrMax`, `cardsTmax_of_noThr`, `bound_of_noThr`, `fit_iff_old`,
`xfit_iff_old`), and for a game with one the bound is above every threshold of its cards
(`thrMax_lt_bound`) and exceeds the old one by at most the largest threshold (`bound_le_old`). The
capped clamp needs it: inside an attack it determines the damage only up to the cap, and a threshold
above the cap separates two related states (`threshold_breaks_clamp`, for this proof). The lingering
threshold is not `Mod.plain`: the capped clamp cannot absorb a stored threshold that is not tied to a
card, so a deck with one is not tame (as with a damage reduction) and the exact-store clamp, which
keeps the stores and the damage inside an attack exact, handles it with no condition.

**The old step.** `GameState.NoThr g` (no static threshold reads any damage in `g`, and no lingering
threshold is in effect on the defender): the damage step is the pre-MV14 rule (`GameState.dealt_old`,
`GameState.dealtI_old`, `Run.damage_old`); `GameState.noThr_of` gives it from cards with no `preventGe`
and stores with no threshold. The Bench old step is MV13's (`GameState.BenchOpen` now includes the
threshold).

**Witnesses** (legal moves from starts proved `WellFormed` and `Settled`): `ge_blocks` (30 damage
against a 30-or-more threshold is prevented), `ge_lands` (20 lands), `ge_blocks_all` (every resolution
leaves the defender undamaged), `ge_bench_blocks` (on the Bench); `harden_writes` (the attack stores the
threshold for the opponent's next turn), `le_blocks` (20 against a 20-or-less threshold), `le_lands`
(30 lands), `le_blocks_all`.
-/

namespace Pokemon

/-! ## The damage step before milestone MV14, written out -/

/-- `dealtBy` before milestone MV14 (no lingering threshold). -/
def dealtByOld (n : Nat) (weak : Bool) (resist : Nat) (own opp : Store) : Nat :=
  if n = 0 then 0 else if opp.live.prevent then 0 else
    (((if weak then 2 * (n + own.live.bonus - own.live.minus)
      else n + own.live.bonus - own.live.minus) - resist) + opp.live.more) - opp.live.reduce

/-- With no lingering threshold in effect on the defender, `dealtBy` is the old calculation. -/
theorem dealtBy_old {opp : Store} (h : opp.live.upto = 0) (n : Nat) (w : Bool) (r : Nat) (own : Store) :
    dealtBy n w r own opp = dealtByOld n w r own opp := by
  simp only [dealtBy, dealtByOld, h, uptoCut_zero]

/-- No threshold reads the damage step of `g`: no static threshold in force on the defender reads any
damage (`sThr`), and no lingering threshold is in effect on the defender's player. -/
def GameState.NoThr (g : GameState) : Prop := (∀ d, g.sThr d = false) ∧ g.opp.mods.live.upto = 0

theorem GameState.NoThr.thrCut {g : GameState} (h : g.NoThr) (d : Nat) : g.thrCut d = d := by
  simp only [GameState.thrCut, h.1 d, Bool.false_eq_true, ite_false]

/-- **The old damage calculation** (milestone MV14): with no threshold, `GameState.dealt` is the
pre-MV14 definition. -/
theorem GameState.dealt_old {g : GameState} (h : g.NoThr) (n : Nat) :
    g.dealt n = if g.sPrevent then 0 else
      dealtByOld n g.weak g.resist (g.cur.mods.add .always (.bonus g.sBonus))
        (g.opp.mods.add .always (.reduce g.sReduce)) := by
  have hu : (g.opp.mods.add .always (.reduce g.sReduce)).live.upto = 0 := by
    have := h.2
    simp only [Store.live, Store.add, Mods.merge, Mods.addMod] at this ⊢; exact this
  simp only [GameState.dealt, h.thrCut, dealtBy_old hu]

/-- `GameState.dealtI` before milestone MV14. -/
def GameState.dealtIOld (ig : Ign) (n : Nat) (g : GameState) : Nat :=
  if cond ig.fx false g.sPrevent then 0 else
  dealtByOld n (cond ig.weak false g.weak) (cond ig.resist 0 g.resist)
    (g.cur.mods.add .always (.bonus g.sBonus))
    ((cond ig.fx Store.empty g.opp.mods).add .always (.reduce (cond ig.fx 0 g.sReduce)))

theorem GameState.dealtI_old {g : GameState} (h : g.NoThr) (ig : Ign) (n : Nat) :
    g.dealtI ig n = g.dealtIOld ig n := by
  have hu : ((cond ig.fx Store.empty g.opp.mods).add .always (.reduce (cond ig.fx 0 g.sReduce))).live.upto
      = 0 := by
    cases ig.fx
    · have := h.2
      simp only [Bool.cond_false, Store.live, Store.add, Mods.merge, Mods.addMod] at this ⊢; exact this
    · rfl
  have hc : cond ig.fx id g.thrCut = id := by
    cases ig.fx
    · exact funext h.thrCut
    · rfl
  simp only [GameState.dealtI, GameState.dealtIOld, hc, id_eq, dealtBy_old hu]

/-- **The old damage step** (milestone MV14): with no threshold, `damage a ig` has exactly the
resolutions of its pre-MV14 rule. -/
theorem Run.damage_old {g g' : GameState} {a : Amt} {ig : Ign} (h : g.NoThr) :
    Run (.damage a ig) g g' ↔ ∃ p n, a.Val g n ∧ g.opp.active = some p ∧
      g' = { g with opp := { g.opp with active := some { p with damage := p.damage + g.dealtIOld ig n } } } := by
  constructor
  · intro hr
    cases hr with
    | @damage _ p _ _ n hv hp => exact ⟨p, n, hv, hp, by rw [GameState.dealtI_old h]⟩
    | touchActive he => simp [Effect.touch] at he
    | touchBench he => simp [Effect.touch] at he
    | zone hw => simp [Effect.zSide] at hw
  · rintro ⟨p, n, hv, hp, rfl⟩
    rw [← GameState.dealtI_old h]
    exact .damage hv hp

/-- Is a static effect a threshold (`SEff.preventGe`)? -/
def Static.isGe (s : Static) : Bool :=
  match s.eff with
  | .preventGe _ _ => true
  | _ => false

/-- A card with no static threshold (milestone MV14). Every card before MV14. -/
def Card.noThr (c : Card) : Bool := c.statics.all fun s => !s.isGe

theorem Card.thrMax_of_noThr {c : Card} (h : c.noThr = true) : c.thrMax = 0 :=
  Card.thrMax_of_noGe fun s hs t fr he => by
    have := List.all_eq_true.1 h s hs
    simp [Static.isGe, he] at this

theorem Static.thrFrom_of_not_isGe {s : Static} (h : s.isGe = false) (a : PokemonCard) (d : Nat) :
    s.thrFrom a d = false := by
  unfold Static.isGe at h; unfold Static.thrFrom; split
  · next t fr he => rw [he] at h; cases h
  · rfl

/-- **A game whose cards have no static threshold reads none**: `sThr` is false at every damage. -/
theorem GameState.sThr_of_noThr {g : GameState} (h : ∀ c ∈ g.allCards, c.noThr = true) (d : Nat) :
    g.sThr d = false := by
  unfold GameState.sThr
  split
  · next a q ha hq =>
      rw [List.any_eq_false]
      intro s hs
      obtain ⟨c, hc, hsc⟩ := g.mem_inForce (w := .opp) (sp := .active) hq hs
      have := List.all_eq_true.1 (h c hc) s hsc
      simp only [Bool.not_eq_eq_eq_not, Bool.not_true] at this
      rw [Static.thrFrom_of_not_isGe this]; exact Bool.false_ne_true
  · rfl

/-- The hypothesis of the old step from the cards and the stores. -/
theorem GameState.noThr_of {g : GameState} (h : ∀ c ∈ g.allCards, c.noThr = true)
    (hu : g.opp.mods.live.upto = 0) : g.NoThr :=
  ⟨g.sThr_of_noThr h, hu⟩

/-- With no static effects and no stored threshold, no threshold (milestone MV14). -/
theorem GameState.noThr_noStatics {g : GameState} (hn : g.NoStatics) (hu : g.opp.mods.live.upto = 0) :
    g.NoThr :=
  ⟨g.sThr_noStatics hn, hu⟩

/-! ## The meaning of `Fit`, `XFit` and `Enum.bound` (survey S28 §4)

`Card.tmax` is now `max Card.testMax Card.thrMax`, where `Card.testMax` is the definition of
`Card.tmax` before milestone MV14, verbatim. Below: the old bound, `Fit` and `XFit`, written with
`Card.testMax`, and their equality with the new ones for games with no threshold. -/

/-- The largest old test constant over a list of cards (`cardsTmax` before MV14). -/
def cardsTestMax : List Card → Nat
  | [] => 0
  | c :: cs => max c.testMax (cardsTestMax cs)

/-- The largest static threshold over a list of cards. -/
def cardsThrMax : List Card → Nat
  | [] => 0
  | c :: cs => max c.thrMax (cardsThrMax cs)

/-- `cardsTmax` is the larger of the old test constants and the thresholds. -/
theorem cardsTmax_eq : ∀ C : List Card, cardsTmax C = max (cardsTestMax C) (cardsThrMax C)
  | [] => rfl
  | c :: cs => by
      have := cardsTmax_eq cs
      simp only [cardsTmax, cardsTestMax, cardsThrMax, Card.tmax] at this ⊢; omega

theorem cardsThrMax_of : ∀ {C : List Card}, (∀ c ∈ C, c.thrMax = 0) → cardsThrMax C = 0
  | [], _ => rfl
  | c :: cs, h => by
      simp only [cardsThrMax, h c (.head _), cardsThrMax_of fun x hx => h x (.tail _ hx)]; rfl

/-- **For cards with no threshold, `cardsTmax` is the old one.** -/
theorem cardsTmax_of_noThr {C : List Card} (h : ∀ c ∈ C, c.thrMax = 0) :
    cardsTmax C = cardsTestMax C := by
  rw [cardsTmax_eq, cardsThrMax_of h, Nat.max_zero]

/-- `Enum.bound` before milestone MV14. -/
def Enum.boundOld (C : List Card) : Nat :=
  hpBound C + maxResist C + sReduceBound C + cardsTestMax C + 1

/-- **For cards with no threshold, `Enum.bound` is the bound before milestone MV14.** -/
theorem Enum.bound_of_noThr {C : List Card} (h : ∀ c ∈ C, c.thrMax = 0) :
    Enum.bound C = Enum.boundOld C := by
  simp only [Enum.bound, Enum.boundOld, cardsTmax_of_noThr h]

/-- **What grows**: the bound exceeds the old one by at most the largest threshold of the cards
(and by nothing when it is at most the largest old test constant). -/
theorem Enum.bound_le_old (C : List Card) : Enum.bound C ≤ Enum.boundOld C + cardsThrMax C ∧
    Enum.boundOld C ≤ Enum.bound C := by
  have := cardsTmax_eq C
  -- One conjunct per `omega`: `omega` on a conjunction pulls in `Classical.choice`.
  simp only [Enum.bound, Enum.boundOld]
  exact ⟨by omega, by omega⟩

theorem thrMax_le_cardsThrMax {x : Card} : ∀ {C : List Card}, x ∈ C → x.thrMax ≤ cardsThrMax C
  | _ :: _, .head _ => by simp only [cardsThrMax]; omega
  | _ :: _, .tail _ h => by have := thrMax_le_cardsThrMax h; simp only [cardsThrMax]; omega

/-- **The bound is above every threshold of the cards.** -/
theorem Enum.thrMax_lt_bound {C : List Card} {x : Card} (hx : x ∈ C) : x.thrMax < Enum.bound C := by
  have := thrMax_le_cardsThrMax hx
  have := cardsTmax_eq C
  simp only [Enum.bound]; omega

/-- The stores hold no lingering threshold. -/
def Mods.NoUpto (m : Mods) : Prop := m.upto = 0

def GameState.NoUpto (g : GameState) : Prop :=
  g.cur.mods.now.upto = 0 ∧ g.cur.mods.next.upto = 0 ∧ g.cur.mods.after.upto = 0 ∧
    g.cur.mods.always.upto = 0 ∧ g.opp.mods.now.upto = 0 ∧ g.opp.mods.next.upto = 0 ∧
    g.opp.mods.after.upto = 0 ∧ g.opp.mods.always.upto = 0

/-- `Mods.NoReduce` before milestone MV14. -/
def Mods.NoReduceOld (m : Mods) : Prop := m.reduce = 0 ∧ m.minus = 0 ∧ m.more = 0

def Store.NoReduceOld (t : Store) : Prop :=
  t.now.NoReduceOld ∧ t.next.NoReduceOld ∧ t.after.NoReduceOld ∧ t.always.NoReduceOld

def GameState.NoReduceOld (g : GameState) : Prop := g.cur.mods.NoReduceOld ∧ g.opp.mods.NoReduceOld

/-- `GameState.Fit` before milestone MV14: `Card.testMax` for `Card.tmax`, the old `NoReduce`. -/
def GameState.FitOld (k : Nat) (g : GameState) : Prop :=
  0 < k ∧ g.HpLe k ∧ (∀ x ∈ g.allCards, x.tame = true ∧ x.testMax < k) ∧ g.NoReduceOld ∧ g.ReduceLe k

/-- `GameState.XFit` before milestone MV14. -/
def GameState.XFitOld (k : Nat) (g : GameState) : Prop :=
  g.HpLe k ∧ ∀ x ∈ g.allCards, x.testMax < k

/-- **`Fit` means what it meant**, for a game whose cards have no threshold and whose stores hold none
(every state of the model before MV14, read with `upto = 0`). -/
theorem GameState.fit_iff_old {g : GameState} (h : ∀ c ∈ g.allCards, c.thrMax = 0) (hu : g.NoUpto)
    (k : Nat) : g.Fit k ↔ g.FitOld k := by
  obtain ⟨u1, u2, u3, u4, u5, u6, u7, u8⟩ := hu
  have ht : ∀ x ∈ g.allCards, x.tmax = x.testMax := fun x hx => Card.tmax_of_thrMax (h x hx)
  constructor
  · rintro ⟨h0, h1, h2, ⟨⟨a1, a2, a3, a4⟩, ⟨b1, b2, b3, b4⟩⟩, h5⟩
    refine ⟨h0, h1, fun x hx => ?_, ⟨⟨⟨a1.1, a1.2.1, a1.2.2.1⟩, ⟨a2.1, a2.2.1, a2.2.2.1⟩,
      ⟨a3.1, a3.2.1, a3.2.2.1⟩, ⟨a4.1, a4.2.1, a4.2.2.1⟩⟩, ⟨⟨b1.1, b1.2.1, b1.2.2.1⟩,
      ⟨b2.1, b2.2.1, b2.2.2.1⟩, ⟨b3.1, b3.2.1, b3.2.2.1⟩, ⟨b4.1, b4.2.1, b4.2.2.1⟩⟩⟩, h5⟩
    rw [← ht x hx]; exact h2 x hx
  · rintro ⟨h0, h1, h2, ⟨⟨a1, a2, a3, a4⟩, ⟨b1, b2, b3, b4⟩⟩, h5⟩
    refine ⟨h0, h1, fun x hx => ?_, ⟨⟨⟨a1.1, a1.2.1, a1.2.2, u1⟩, ⟨a2.1, a2.2.1, a2.2.2, u2⟩,
      ⟨a3.1, a3.2.1, a3.2.2, u3⟩, ⟨a4.1, a4.2.1, a4.2.2, u4⟩⟩, ⟨⟨b1.1, b1.2.1, b1.2.2, u5⟩,
      ⟨b2.1, b2.2.1, b2.2.2, u6⟩, ⟨b3.1, b3.2.1, b3.2.2, u7⟩, ⟨b4.1, b4.2.1, b4.2.2, u8⟩⟩⟩, h5⟩
    rw [ht x hx]; exact h2 x hx

/-- **`XFit` means what it meant**, for a game whose cards have no threshold. -/
theorem GameState.xfit_iff_old {g : GameState} (h : ∀ c ∈ g.allCards, c.thrMax = 0) (k : Nat) :
    g.XFit k ↔ g.XFitOld k := by
  have ht : ∀ x ∈ g.allCards, x.tmax = x.testMax := fun x hx => Card.tmax_of_thrMax (h x hx)
  constructor
  · exact fun ⟨h1, h2⟩ => ⟨h1, fun x hx => ht x hx ▸ h2 x hx⟩
  · exact fun ⟨h1, h2⟩ => ⟨h1, fun x hx => (ht x hx).symm ▸ h2 x hx⟩

/-- `CapOk`'s new clause holds at every cap for such a game. -/
theorem GameState.capOk_iff_old {g : GameState} (h : ∀ c ∈ g.allCards, c.thrMax = 0) (k : Nat) :
    g.CapOk k ↔ g.HpLe k ∧ g.ReduceLe k :=
  ⟨fun hc => ⟨hc.1, hc.2.1⟩, fun hc => ⟨hc.1, hc.2, g.thrLe_of_noThr h k⟩⟩

namespace Threshold

open Trainer InPlayTests

/-! ## The static threshold ("30 or more", a scaled Drednaw) -/

/-- "Prevent all damage done to this Pokémon by attacks from your opponent's Pokémon if that damage is
30 or more." -/
def shell : Ability :=
  ⟨"Shell", .static [⟨.self, .any, none, none, none, .preventGe 3 .any⟩], none, none, .fx .skip⟩

/-- A defender with the threshold, 100 HP. -/
def turtle : PokemonCard := ⟨"Turtle", .basic, none, 10, .water, [], 1, none, none, .none, false, [shell]⟩

/-- A defender without it. -/
def plainMon : PokemonCard := ⟨"Plain", .basic, none, 10, .water, [], 1, none, none, .none, false, []⟩

/-- `n` damage, the full calculation. -/
def hitN (n : Nat) : Attack := ⟨"Hit", [], 0, .damage (.const n), false, .none⟩

/-- 30 damage to each of the opponent's Benched Pokémon. -/
def spray : Attack := ⟨"Spray", [], 0, .spreadDamage .opp 3, false, .none⟩

/-- The attacker, with 20 and 30 damage and the spread. -/
def biter : PokemonCard := ⟨"Biter", .basic, none, 10, .fire, [hitN 2, hitN 3, spray], 1, none, none,
  .none, false, []⟩

def start (d : PokemonCard) (b : List InPlay) : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic biter) [],
    side [] [.energy .fire] (InPlay.ofBasic d) b, true, false, false, false, none, none,
    false, false, false⟩

theorem start_wf (d : PokemonCard) : WellFormed (start d []) := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> cases hp

theorem start_settled : Settled (start turtle []) := (GameState.settled_iff _).2 (by decide)

/-- The calculation: 30 is prevented, 20 is not; with the threshold ignored (`Ign.fx`) 30 lands. -/
theorem start_dealt : (start turtle []).dealt 3 = 0 ∧ (start turtle []).dealt 2 = 2 ∧
    (start turtle []).dealtI { fx := true } 3 = 3 ∧ (start plainMon []).dealt 3 = 3 :=
  ⟨rfl, rfl, rfl, rfl⟩

/-- The resolution of `hitN n` from the start. -/
theorem hit_run (n : Nat) (d : PokemonCard) (b : List InPlay) :
    Run (hitN n).script (start d b) { start d b with opp := { (start d b).opp with
      active := some { InPlay.ofBasic d with damage := 0 + (start d b).dealt n } } } :=
  Run.damage (ig := {}) (.const n _) rfl

/-- **Witness (positive): damage at the threshold is prevented.** From a well-formed, `Settled` start,
the 30-damage attack is a legal move that leaves the defender with no damage. -/
theorem ge_blocks :
    WellFormed (start turtle []) ∧ Settled (start turtle []) ∧ ∃ g, Move (start turtle []) g ∧
      g.opp.active.map InPlay.damage = some 0 := by
  have hr := hit_run 3 turtle []
  exact ⟨start_wf _, start_settled, _,
    Move.attackOpen (hlk := rfl) (atk := hitN 3) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      start_settled hr rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩

/-- **Witness (negative): just below the threshold the damage lands.** The 20-damage attack leaves 2
damage counters. -/
theorem ge_lands :
    ∃ g, Move (start turtle []) g ∧ g.opp.active.map InPlay.damage = some 2 := by
  have hr := hit_run 2 turtle []
  exact ⟨_, Move.attackOpen (hlk := rfl) (atk := hitN 2) rfl (.head _) (.nil _) rfl rfl rfl rfl
      start_settled hr rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩

/-- **Every resolution of the 30-damage attack leaves the defender undamaged** (universal form of
`ge_blocks`; a fact about `Run` of the attack's script from the start). -/
theorem ge_blocks_all :
    ∀ g', Run (hitN 3).script (start turtle []) g' → g'.opp.active.map InPlay.damage = some 0 := by
  intro g' h
  change Run (.damage (.const 3)) _ _ at h
  cases h with
  | damage hv hp => cases hv; cases hp; rfl
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw

/-- The start with the threshold Pokémon on the opponent's Bench, behind a plain Active Pokémon. -/
def benchStart : GameState := start plainMon [InPlay.ofBasic turtle, InPlay.ofBasic plainMon]

theorem benchStart_wf : WellFormed benchStart := by
  refine ⟨fun _ => ⟨by simp [benchStart, start, side], by simp [benchStart, start, side]⟩, ?_, ?_,
    .of_b rfl⟩ <;> intro p hp
  · cases hp
  · simp only [benchStart, start, side, List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem benchStart_settled : Settled benchStart := (GameState.settled_iff _).2 (by decide)

/-- **Witness (Bench): the spread of 30 leaves the threshold Pokémon at 0 and the other at 3.** -/
theorem ge_bench_blocks :
    WellFormed benchStart ∧ Settled benchStart ∧ ∃ g, Move benchStart g ∧
      g.opp.bench.map InPlay.damage = [0, 3] := by
  have hr : Run spray.script benchStart _ := Run.spreadDamage .opp 3 benchStart
  exact ⟨benchStart_wf, benchStart_settled, _,
    Move.attackOpen (hlk := rfl) (atk := spray) rfl (.tail _ (.tail _ (.head _))) (.nil _) rfl rfl rfl
      rfl benchStart_settled hr rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil hr rfl) (.nil _), by decide⟩

/-! ## The lingering threshold ("20 or less", a scaled Metapod) -/

/-- "During your opponent's next turn, prevent all damage done to this Pokémon by attacks if that
damage is 20 or less." -/
def harden : Attack := ⟨"Harden", [], 0, .linger .own .next (.preventLe 2), false, .none⟩

def cocoon : PokemonCard := ⟨"Cocoon", .basic, none, 10, .grass, [harden], 1, none, none, .none, false, []⟩

/-- **Witness: Harden stores the threshold for the opponent's next turn**, a legal move. -/
theorem harden_writes :
    WellFormed (start cocoon []) ∧ ∃ g, Move ⟨(start cocoon []).opp, (start cocoon []).cur, true, false,
        false, false, none, none, false, false, false⟩ g ∧ g.cur.mods.next.upto = 2 := by
  have hs : Settled (⟨(start cocoon []).opp, (start cocoon []).cur, true, false, false, false, none,
      none, false, false, false⟩ : GameState) := (GameState.settled_iff _).2 (by decide)
  have hr : Run harden.script ⟨(start cocoon []).opp, (start cocoon []).cur, true, false, false, false,
      none, none, false, false, false⟩ _ := Run.linger .own .next (.preventLe 2) _
  exact ⟨start_wf _, _, Move.attackOpen (hlk := rfl) (atk := harden) rfl (.head _) (.nil _) rfl rfl rfl
      rfl hs hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩

/-- The opponent (the defender's player) has the threshold in effect this turn, as after Harden and the
end of its turn. -/
def leStart : GameState :=
  let g := start cocoon []
  { g with opp := { g.opp with mods := Store.empty.add .now (.preventLe 2) } }

theorem leStart_wf : WellFormed leStart := by
  refine ⟨fun _ => ⟨by simp [leStart, start, side], by simp [leStart, start, side]⟩, ?_, ?_,
    .of_b rfl⟩ <;> intro p hp <;> cases hp

theorem leStart_settled : Settled leStart := (GameState.settled_iff _).2 (by decide)

theorem le_dealt : leStart.dealt 2 = 0 ∧ leStart.dealt 3 = 3 ∧ leStart.dealtI { fx := true } 2 = 2 :=
  ⟨rfl, rfl, rfl⟩

/-- **Witness (positive): damage at the lingering threshold is prevented.** -/
theorem le_blocks :
    WellFormed leStart ∧ Settled leStart ∧ ∃ g, Move leStart g ∧ g.opp.active.map InPlay.damage = some 0 := by
  have hr : Run (hitN 2).script leStart _ := Run.damage (ig := {}) (.const 2 _) rfl
  exact ⟨leStart_wf, leStart_settled, _,
    Move.attackOpen (hlk := rfl) (atk := hitN 2) rfl (.head _) (.nil _) rfl rfl rfl rfl
      leStart_settled hr rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩

/-- **Witness (negative): just above it the damage lands** (3 counters). -/
theorem le_lands : ∃ g, Move leStart g ∧ g.opp.active.map InPlay.damage = some 3 := by
  have hr : Run (hitN 3).script leStart _ := Run.damage (ig := {}) (.const 3 _) rfl
  exact ⟨_, Move.attackOpen (hlk := rfl) (atk := hitN 3) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      leStart_settled hr rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩

/-- **Every resolution of the 20-damage attack leaves the protected defender undamaged.** -/
theorem le_blocks_all :
    ∀ g', Run (hitN 2).script leStart g' → g'.opp.active.map InPlay.damage = some 0 := by
  intro g' h
  change Run (.damage (.const 2)) _ _ at h
  cases h with
  | damage hv hp => cases hv; cases hp; rfl
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw


/-! ## The larger bound is needed for this proof

At the cap `k = 3` the capped clamp caps the stored bonuses at `6`. Two states that differ only in
the attacker's bonus for this turn, `6` and `7`, have the same clamp. Against a defender with a static
threshold of `8` (above the cap), an attack of base damage 1 does `1 + 6 = 7` in the first (not
prevented) and `1 + 7 = 8` in the second (prevented). The first leaves the defender at `min 7 3 = 3`
under the clamp, the second at 0; no move of the second matches. Every other clause of `Fit 3` holds
(old test constants below 3, every card tame, no reduction stored, `HpLe 3`, `ReduceLe 3`); only the
threshold is not below the cap. So the clause the threshold adds to `Card.tmax` (and `ThrLe` in
`CapOk`) is needed for `Move.clamp_sim` as proved; this says nothing about other abstractions. -/

/-- "Prevent all damage … if that damage is 80 or more." -/
def shell8 : Ability :=
  ⟨"Shell", .static [⟨.self, .any, none, none, none, .preventGe 8 .any⟩], none, none, .fx .skip⟩

/-- The defender: 3 HP counters, no attack, the threshold. -/
def wall : PokemonCard := { Lingering.mon 3 0 .skip with abilities := [shell8] }

/-- The two states: the attacker's bonus this turn is `b`. -/
def brk (b : Nat) : GameState :=
  Lingering.st [] [] (InPlay.ofBasic Lingering.hitter) (InPlay.ofBasic wall) (Lingering.bonusNow b)
    Store.empty

theorem brk_clamp : (brk 6).clamp 3 = (brk 7).clamp 3 :=
  Lingering.clamp_st _ _ _ _ _ (by decide)

theorem brk_settled (b : Nat) : Settled (brk b) := (GameState.settled_iff _).2 rfl

theorem brk_dealt : (brk 6).dealt 1 = 7 ∧ (brk 7).dealt 1 = 0 := ⟨rfl, rfl⟩

/-- **A static threshold above the cap breaks the capped clamp** (for this proof: `Move.clamp_sim`
needs `ThrLe k`, which `Fit k` gives through `Card.tmax`). Two well-formed, `Settled` states with the
same `clamp 3`, every card tame with old test constants below 3, no stored reduction, `HpLe 3` and
`ReduceLe 3`, one card with threshold 8; a move from the first that no move from the second matches. -/
theorem threshold_breaks_clamp :
    WellFormed (brk 6) ∧ WellFormed (brk 7) ∧ Settled (brk 6) ∧ Settled (brk 7) ∧
      (brk 6).clamp 3 = (brk 7).clamp 3 ∧ (brk 6).NoReduce ∧ (brk 6).HpLe 3 ∧ (brk 6).ReduceLe 3 ∧
      (∀ x ∈ (brk 6).allCards, x.tame = true ∧ x.testMax < 3) ∧
      (∃ x ∈ (brk 6).allCards, 3 < x.thrMax) ∧
      ∃ g₁', Move (brk 6) g₁' ∧ ∀ g₂', Move (brk 7) g₂' → g₁'.clamp 3 ≠ g₂'.clamp 3 := by
  have hwf : ∀ b, WellFormed (brk b) := fun b =>
    Lingering.wellFormed_st _ _ _ _ _ _ (.of_b rfl)
  have ht : (brk 6).allCards.all (fun x => x.tame && decide (x.testMax < 3)) = true := by decide
  have hp3 : (brk 6).allCards.all (fun x => match x with
      | .pokemon p => decide (p.resistAmt ≤ 3) && decide (p.resistAmt + sReduceBound (brk 6).allCards ≤ 3)
      | _ => true) = true := by decide
  have hw : (brk 6).allCards.any (fun x => decide (3 < x.thrMax)) = true := by decide
  have hb : hpBound (brk 6).allCards ≤ 3 := by decide
  refine ⟨hwf 6, hwf 7, brk_settled 6, brk_settled 7, brk_clamp,
    ⟨⟨⟨rfl, rfl, rfl, rfl⟩, ⟨rfl, rfl, rfl, rfl⟩, ⟨rfl, rfl, rfl, rfl⟩, ⟨rfl, rfl, rfl, rfl⟩⟩,
      ⟨⟨rfl, rfl, rfl, rfl⟩, ⟨rfl, rfl, rfl, rfl⟩, ⟨rfl, rfl, rfl, rfl⟩, ⟨rfl, rfl, rfl, rfl⟩⟩⟩,
    ⟨hb, fun p hp => ?_⟩, fun p hp => ?_, fun x hx => ?_, ?_, ?_⟩
  · have := List.all_eq_true.1 hp3 _ hp
    simp only [Bool.and_eq_true, decide_eq_true_eq] at this; exact this.1
  · have := List.all_eq_true.1 hp3 _ hp
    simp only [Bool.and_eq_true, decide_eq_true_eq] at this; exact this.2
  · have := List.all_eq_true.1 ht _ hx
    simp only [Bool.and_eq_true, decide_eq_true_eq] at this; exact this
  · obtain ⟨x, hx, h3⟩ := List.any_eq_true.1 hw
    exact ⟨x, hx, of_decide_eq_true h3⟩
  refine ⟨_, Move.attackOpen (hlk := rfl) (atk := ⟨"Hit", [], 1, .skip, false, .none⟩) rfl (.head _)
    (.nil _) rfl rfl rfl rfl (brk_settled 6) (.seq (.damage (.const 1 _) rfl) (.skip _)) rfl
    (fun h => nomatch h) rfl (HitTrig.exists_nil (.seq (.damage (.const 1 _) rfl) (.skip _)) rfl) (.nil _),
    fun g₂' hm heq => ?_⟩
  cases hm with
  | playBasic hh => simp [brk, Lingering.st, Lingering.side] at hh
  | trigger _ hp => simp [brk, Lingering.st] at hp
  | attach hh => simp [brk, Lingering.st, Lingering.side] at hh
  | evolve hh => simp [brk, Lingering.st, Lingering.side] at hh
  | attachBench hh => simp [brk, Lingering.st, Lingering.side] at hh
  | evolveBench hh => simp [brk, Lingering.st, Lingering.side] at hh
  | retreat ha hb => simp [brk, Lingering.st, Lingering.side] at hb
  | item hh => simp [brk, Lingering.st, Lingering.side] at hh
  | supporter hh => simp [brk, Lingering.st, Lingering.side] at hh
  | stadium hh => simp [brk, Lingering.st, Lingering.side] at hh
  | stadiumUse hs => simp [brk, Lingering.st, Lingering.side] at hs
  | tool hh => simp [brk, Lingering.st, Lingering.side] at hh
  | toolBench hh => simp [brk, Lingering.st, Lingering.side] at hh
  | ability hu hm =>
      cases hu with
      | active ha =>
          simp only [brk, Lingering.st, Lingering.side, Option.some.injEq] at ha
          subst ha
          simp [InPlay.abilities, InPlay.ofBasic, Lingering.hitter, Lingering.mon] at hm
      | bench hb => simp [brk, Lingering.st, Lingering.side] at hb
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [brk, Lingering.st, Lingering.side] at hh
  | @attack g' a atk ha hm hc hs hn hf hbt hst hr hl _ _ _ _ hd ht =>
      simp only [brk, Lingering.st, Lingering.side, Option.some.injEq] at ha
      subst ha
      simp only [InPlay.attacks, InPlay.ofBasic, Lingering.hitter, Lingering.mon, List.flatMap_nil,
        List.append_nil, List.mem_singleton] at hm
      subst hm
      change Run (.seq (.damage (.const 1)) .skip) _ _ at hr
      cases hr with
      | seq h1 h2 =>
          cases h1 with
          | damage hv hp =>
              cases hv
              simp only [brk, Lingering.st, Lingering.side, Option.some.injEq] at hp
              subst hp
              cases h2 with
              | skip =>
                  obtain rfl := hd.nil_of rfl
                  cases ht
                  have e := congrArg (fun g : GameState => g.opp.active.map InPlay.damage) heq
                  change some 3 = some 0 at e
                  cases e
              | touchActive he => simp [Effect.touch] at he
              | touchBench he => simp [Effect.touch] at he
              | zone hw => simp [Effect.zSide] at hw
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | attackConfused ha hm hc hs =>
      simp only [brk, Lingering.st, Lingering.side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic] at hs
  | knockOuts h =>
      cases h with
      | won hu => exact hu (brk_settled 7).calm
      | go hu => exact hu (brk_settled 7).calm
  | endTurn =>
      have e := congrArg GameState.attacked heq
      simp [GameState.clamp, GameState.clampAt, GameState.afterAttack] at e
  | startTurn hbt => simp [brk, Lingering.st] at hbt
  | deckOut hbt => simp [brk, Lingering.st] at hbt

end Threshold

end Pokemon
