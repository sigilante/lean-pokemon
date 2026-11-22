import Pokemon.Defender

/-!
# Effect vocabulary 6, stage 3: counts (milestone MV6)

Survey S19 §C. Three additions, none of which reads damage:

* `Amt.heads a k`: "`k` for each heads among `a` coins", any multiple `k · m` with `m` at most the
  value of `a` (`Amt.Val.heads`; characterised by `Amt.Val.heads_iff`). Coins counted by the state
  ("Flip a coin for each Energy attached to this Pokémon. This attack does 80 damage for each
  heads", 7 refused Standard cards), a fixed number of coins, and "Reveal any number of … from your
  hand, … 60 damage for each card you revealed in this way" (Doublade me3-57). Coin flips are
  nondeterministic choices, so this is exact up to probability. Before this milestone a fixed
  number of coins was a `choice` of damage steps (one per number of heads); a number of coins read
  from the state was not expressible.
* `Pile.top n`, `Pile.bottom n`: counts over the top or bottom `n` cards of a deck ("Reveal the
  bottom 7 cards of your deck, and this attack does 50 damage for each Pokémon you find there that
  has the Bug Out attack", Sizzlipede me5-9).
* `Count.retreat w`: the printed Retreat Cost of the `w` Active Pokémon ("30 more damage for each
  Colorless in your opponent's Active Pokémon's Retreat Cost", Ariados sv6-5; 7 cards). The printed
  value, not the derived one (Known gaps).

Each reads zones or printed cards, which both clamps keep, so `Count.val_clampAt` and
`Count.val_xclampAt` gained one case each and stayed equalities at every cap, and `Amt.Val.congr`
and `Amt.Val.transfer` one case each; no clamp theorem needed a hypothesis. Counts that read
damage on several Pokémon, or the number of Pokémon with damage counters, are left out (S19 §C: the
first is not kept by either clamp; the second is kept at every cap of at least 1, but the count
theorems hold at every cap, 0 included).

Witnesses: Larry's Dudunsparce ex's shape with two Energy attached does 0, 80 or 160 (each a legal
move, and nothing else, `work_values`); Ariados's shape against a Retreat Cost of 1; Bug Out as one
attack, a count over the bottom 2 cards followed by a window that shuffles the counted Pokémon back
and discards the others.
-/

namespace Pokemon

/-- **The values of `heads`**: `k` times any number of heads up to the number of coins. -/
theorem Amt.Val.heads_iff {a : Amt} {k : Nat} {g : GameState} {v : Nat} :
    (Amt.heads a k).Val g v ↔ ∃ n m, a.Val g n ∧ m ≤ n ∧ v = k * m := by
  constructor
  · intro h
    cases h with
    | heads _ ha hm => exact ⟨_, _, ha, hm, rfl⟩
  · rintro ⟨n, m, ha, hm, rfl⟩
    exact .heads k ha hm

namespace Coins

open Trainer InPlayTests

/-- Larry's Dudunsparce ex me2pt5-164, Work Rush: "Flip a coin for each Energy attached to this
Pokémon. This attack does 80 damage for each heads." -/
def workRush : Attack :=
  ⟨"Work Rush", [], 0, .damage (.heads (.count (.energy .own .energy) 1) 8), false, .none⟩

/-- Ariados sv6-5, String Bind (10+): "This attack does 30 more damage for each Colorless in your
opponent's Active Pokémon's Retreat Cost." -/
def stringBind : Attack :=
  ⟨"String Bind", [], 0, .damage (.add (.const 1) (.count (.retreat .opp) 3)), false, .none⟩

/-- Sizzlipede me5-9, Bug Out (50×), on the bottom 2 cards: "Reveal the bottom 2 cards of your deck,
and this attack does 50 damage for each Pokémon you find there that has the Bug Out attack. Then,
shuffle any revealed Pokémon back into your deck. Discard the other cards." -/
def bugOut : Attack :=
  ⟨"Bug Out", [], 0, .seq (.damage (.count (.pile .own (.bottom 2) (.hasAttack "Bug Out")) 5))
    (.look .own (.bottom 2) (.hasAttack "Bug Out") .all (.put .shuffle) .discard), false, .none⟩

def bugger : PokemonCard := ⟨"Bugger", .basic, none, 10, .grass, [workRush, stringBind, bugOut],
  1, none, none, .none, false, []⟩

/-- The attacker, with two Energy attached. -/
def buggerIn : InPlay := { InPlay.ofBasic bugger with energy := [.energy .grass, .energy .grass] }

/-- The player to move has `buggerIn` Active and the deck `[Grass Energy, Bugger, Fire Energy]`; the
opponent `big` (Retreat Cost 1). -/
def start : GameState :=
  ⟨{ side [] [.energy .fire] buggerIn [] with
      deck := [.energy .grass, .pokemon bugger, .energy .fire] },
    side [] [.energy .fire] (InPlay.ofBasic big) [], true, false, false, false, none, none, false,
    false⟩

theorem start_wellFormed : WellFormed start := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_⟩ <;>
    intro p hp <;> cases hp

theorem start_settled : Settled start := (GameState.settled_iff _).2 (by decide)

/-- The damage step of Work Rush resolves with `m` heads, for `m` at most 2. -/
theorem energy_two : (Count.energy .own .energy).val start = 2 := rfl

theorem work_run (m : Nat) (hm : m ≤ 2) : Run workRush.script start
    { start with opp := { start.opp with
      active := some { InPlay.ofBasic big with damage := 0 + start.dealtI {} (8 * m) } } } :=
  Run.damage (g := start) (p := InPlay.ofBasic big) (ig := {})
    (.heads (m := m) 8 (.count (.energy .own .energy) 1 start)
      (by rw [Nat.one_mul, energy_two]; exact hm)) rfl

/-- **Witness: coins counted by the state.** With two Energy attached, Work Rush with two heads is a
legal move and does 160 damage. -/
theorem work_two_heads :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      g.opp.active = some { InPlay.ofBasic big with damage := 16 } := by
  have hr := work_run 2 (Nat.le_refl _)
  exact ⟨start_wellFormed, start_settled, _,
    .attack (hlk := rfl) (atk := workRush) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled hr
      rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _), rfl⟩

/-- **The values of Work Rush** with two Energy attached: 0, 80 or 160 damage, and nothing else. -/
theorem work_values (v : Nat) :
    (Amt.heads (.count (.energy .own .energy) 1) 8).Val start v ↔ v = 0 ∨ v = 8 ∨ v = 16 := by
  rw [Amt.Val.heads_iff]
  constructor
  · rintro ⟨n, m, hn, hm, rfl⟩
    cases hn
    rw [Nat.one_mul, energy_two] at hm
    omega
  · rintro (rfl | rfl | rfl)
    · exact ⟨_, 0, .count _ 1 _, Nat.zero_le _, rfl⟩
    · exact ⟨_, 1, .count _ 1 _, by decide, rfl⟩
    · exact ⟨_, 2, .count _ 1 _, by decide, rfl⟩

/-- **Witness: the opponent's Retreat Cost.** Against a Retreat Cost of 1, String Bind does
`10 + 30 = 40`. -/
theorem stringBind_witness :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      g.opp.active = some { InPlay.ofBasic big with damage := 4 } := by
  have hr : Run stringBind.script start _ := .damage (.add (.const 1 _) (.count _ 3 _)) rfl
  exact ⟨start_wellFormed, start_settled, _,
    .attack (hlk := rfl) (atk := stringBind) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      start_settled hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    rfl⟩

/-- **Witness: Bug Out.** The bottom 2 cards are Bugger and a Fire Energy: one Pokémon with the Bug
Out attack, so 50 damage; Bugger is shuffled back into the deck and the Fire Energy discarded. -/
theorem bugOut_witness :
    WellFormed start ∧ Settled start ∧ ∃ g, Move start g ∧
      g.opp.active = some { InPlay.ofBasic big with damage := 5 } ∧
      g.cur.deck = [.pokemon bugger, .energy .grass] ∧ g.cur.discard = [.energy .fire] := by
  have hr : Run bugOut.script start _ :=
    .seq (.damage (.count _ 5 _) rfl)
      (.zone rfl (.look (t := [.pokemon bugger]) (r := [.energy .fire]) (.take (by decide) (.keep .nil))
        (by unfold Qty.ok; decide) (.discard _ _) (.put (.shuffle _ (List.Perm.refl _)))))
  exact ⟨start_wellFormed, start_settled, _,
    .attack (hlk := rfl) (atk := bugOut) rfl (.tail _ (.tail _ (.head _))) (.nil _) rfl rfl rfl rfl
      start_settled hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    rfl, rfl, rfl⟩

end Coins

end Pokemon
