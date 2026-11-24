import Pokemon.Gust

/-!
# Static Checkup effects (milestone MV7b, survey S20 §a T1)

"During Pokémon Checkup, put 3 more damage counters on your opponent's Burned Pokémon." (Magmortar
sv9-21); "As long as this Pokémon is in the Active Spot, put 5 more damage counters on your
opponent's Poisoned Pokémon during Pokémon Checkup." (Pecharunt svp-129). These are static
modifications of the Checkup step (`SEff.condMore c n`), computed from the state when `Move.endTurn`
applies Checkup (`GameState.checkupMoreBy`), never stored; they are not triggers.

The order: "The player whose turn is next decides the order of the effects, but all Special
Conditions must happen at the same time—for example, you can't add Poison damage, then apply an
Ability, then flip for Asleep, etc. But you can apply one Ability, then Special Conditions, and then
another Ability" (rulebook 2026 p. 15). For added damage counters the order matters only through
the Burn flip: applied after the Special Conditions' step, an effect sees a Pokémon that recovered
on heads as no longer Burned. `Move.endTurn` lets the next player put EACH static effect in force
on an Active Pokémon before or after the Special Conditions' step (`oa`, `ob`: one entry per effect,
`true` before; `[]`, the default, puts every effect first; `GameState.checkupMoreBy`); the Knock
Out check follows all of them, as the rulebook says ("After both players have gone through these
checks", p. 15). Until the review of stage 2 the choice was one Boolean per Active Pokémon (all of
its effects before, or all after), which missed the rulebook's "one Ability, then Special
Conditions, and then another Ability" when two such effects are in force (`two_sources`).

From the well-formed, `Settled` start `s0 c` (the player to move has the Magmortar-like `magma`
Active; the opponent has `victim` Active, Burned if `c`):
* `only_endTurn`: the only moves are ends of turn;
* `burn_more_fires`: an end of turn with tails puts 2 + 3 damage counters on the Burned `victim`,
  whatever order (`burn_more_tails`: every end of turn with tails does; the effect is mandatory);
* `burn_heads_order`: with heads the order matters: 5 counters (the effect first) and 2 (the
  Special Conditions first, the Pokémon recovered) are both reachable;
* `burn_more_quiet`: a `victim` that is not Burned gets no counter from any end of turn.

From `m2` (two Magmortar-like sources, one Active and one Benched, for the player to move; the
opponent's `victim` Burned):
* `m2_only_endTurn`: the only moves are ends of turn;
* `two_sources`: ends of turn leave `victim` with 2, 5 or 8 damage counters, each of them
  reachable, and no other total: 8 (both effects first, or tails), 5 (one effect, then the Burn's
  2 and the recovery on heads, then the other effect, which finds `victim` no longer Burned), 2
  (both after). The 5 is the rulebook's "one Ability, then Special Conditions, and then another
  Ability", which the one-Boolean choice of stage 2 could not give.

From `t0 sp` (the player's Pecharunt-like `tox` at `sp`, the opponent's `victim` Poisoned):
* `poison_active`: with `tox` Active, an end of turn exists and every move (every move is an end
  of turn) puts 1 + 5 counters on `victim`;
* `poison_bench`: with `tox` Benched (a `sitter` Active), an end of turn exists and every move
  that ends the turn puts only the Poison's 1 (`sitter` can also retreat, which does not end it).
-/

namespace Pokemon.CheckupW
open Pokemon.Benched Pokemon.Promoted

/-- Magmortar's Ability (sv9-21). -/
def blaze : Ability :=
  ⟨"Blaze", .static [⟨.opp, .any, none, none, none, .condMore .burned 3⟩], none, none, .fx .skip⟩

def magmaC : PokemonCard :=
  ⟨"Magma", .basic, none, 10, .fire, [], 1, none, none, .none, false, [blaze]⟩

/-- Pecharunt's Ability (svp-129): only while this Pokémon is in the Active Spot. -/
def venom : Ability :=
  ⟨"Venom", .static [⟨.opp, .any, none, some .active, none, .condMore .poisoned 5⟩], none, none,
    .fx .skip⟩

def toxC : PokemonCard :=
  ⟨"Tox", .basic, none, 10, .darkness, [], 1, none, none, .none, false, [venom]⟩

/-- A 30-HP Basic Pokémon with no Ability. -/
def bigC : PokemonCard := ⟨"Big", .basic, none, 30, .grass, [], 0, none, none, .none, false, []⟩

/-- `big`, Burned if `c`. -/
def victim (c : Bool) : InPlay := { InPlay.ofBasic bigC with burned := c }

/-- The start: `magma` Active for the player to move; `victim c` Active for the opponent. -/
def s0 (c : Bool) : GameState :=
  ⟨side (InPlay.ofBasic magmaC) [], side (victim c) [], true, false, false, false, none, none,
    false, false, false⟩

theorem s0_wellFormed (c : Bool) : WellFormed (s0 c) :=
  ⟨fun _ => ⟨by simp [s0, side], by simp [s0, side]⟩, fun _ hp => by simp [s0, side] at hp,
    fun _ hp => by simp [s0, side] at hp, .of_b rfl⟩

theorem s0_settled (c : Bool) : Settled (s0 c) := by
  cases c <;> exact (GameState.settled_iff _).2 (by decide)

/-- **From `s0 c` the only moves are ends of turn**: hands are empty, no Bench, no activated
Ability, no attack. -/
theorem only_endTurn {c : Bool} {g' : GameState} (hm : Move (s0 c) g') :
    ∃ (fa sa ca fb sb cb : Bool) (oa ob : List Bool),
      g' = (s0 c).passTurn fa sa ca fb sb cb (victim c) (InPlay.ofBasic magmaC) [] [] oa ob := by
  cases hm with
  | playBasic hh => simp [s0, side] at hh
  | trigger _ hp => simp [s0] at hp
  | attach hh => simp [s0, side] at hh
  | evolve hh => simp [s0, side] at hh
  | attachBench hh => simp [s0, side] at hh
  | evolveBench hh => simp [s0, side] at hh
  | retreat _ hb => simp [s0, side] at hb
  | item hh => simp [s0, side] at hh
  | supporter hh => simp [s0, side] at hh
  | stadium hh => simp [s0, side] at hh
  | tool hh => simp [s0, side] at hh
  | toolBench hh => simp [s0, side] at hh
  | stadiumUse hs => simp [s0] at hs
  | ability hu hm' hk =>
      cases hu with
      | active ha' =>
          simp only [s0, side, Option.some.injEq] at ha'; subst ha'
          simp only [InPlay.abilities, InPlay.ofBasic, magmaC, List.mem_cons, List.mem_append,
            List.not_mem_nil, or_false, List.flatMap_nil] at hm'
          subst hm'
          simp [blaze, AbilityUse.activated] at hk
      | bench hb' => simp [s0, side] at hb'
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [s0, side] at hh
  | attack ha' hm' =>
      simp only [s0, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.attacks, InPlay.ofBasic, magmaC] at hm'
  | attackConfused ha' hm' =>
      simp only [s0, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.attacks, InPlay.ofBasic, magmaC] at hm'
  | knockOuts h => exact absurd (s0_settled c).calm h.not_calm
  | @endTurn a b bo bc fa sa ca fb sb cb ha hb _ _ hco hcc _ oa ob =>
      simp only [s0, side, Option.some.injEq] at ha hb
      subst ha hb
      cases hco
      cases hcc
      exact ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩
  | startTurn hbt => simp [s0] at hbt
  | deckOut hbt => simp [s0] at hbt

/-- **Burned, tails: 2 + 3 counters, whatever the order.** -/
theorem burn_more_tails (sa ca fb sb cb : Bool) (oa ob : List Bool) :
    ((s0 true).passTurn false sa ca fb sb cb (victim true) (InPlay.ofBasic magmaC) [] []
      oa ob).cur.active.map InPlay.damage = some 5 := by
  cases oa with
  | nil => rfl
  | cons b o => cases b <;> rfl

/-- **The static effect fires and cannot be avoided**: an end of turn with tails exists, and every
end of turn on tails (the `victim` still Burned) leaves it with 5 damage counters. -/
theorem burn_more_fires :
    (∃ g', Move (s0 true) g' ∧ g'.cur.active.map InPlay.damage = some 5 ∧
        g'.cur.active.map InPlay.burned = some true) ∧
      ∀ g', Move (s0 true) g' → g'.cur.active.map InPlay.burned = some true →
        g'.cur.active.map InPlay.damage = some 5 := by
  refine ⟨⟨_, .endTurn false false false false false false rfl rfl (s0_settled true).1 rfl .nil .nil,
    rfl, rfl⟩, fun g' hm hb => ?_⟩
  obtain ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩ := only_endTurn hm
  cases fa
  · exact burn_more_tails sa ca fb sb cb oa ob
  · simp [GameState.passTurn, InPlay.addDamage, InPlay.checkup, victim] at hb

/-- **With heads the next player's order matters**: the static effect first gives 5 counters; the
Special Conditions first (the Burn cured by the flip) gives the Burn's 2. -/
theorem burn_heads_order :
    (∃ g', Move (s0 true) g' ∧ g'.cur.active.map InPlay.damage = some 5 ∧
        g'.cur.active.map InPlay.burned = some false) ∧
      ∃ g', Move (s0 true) g' ∧ g'.cur.active.map InPlay.damage = some 2 :=
  ⟨⟨_, .endTurn true false false false false false rfl rfl (s0_settled true).1 rfl .nil .nil,
      rfl, rfl⟩,
    ⟨_, .endTurn true false false false false false rfl rfl (s0_settled true).1 rfl .nil .nil
      (oa := [false]), rfl⟩⟩

/-- **No Burn, no extra counter**: from `s0 false` every move leaves `victim` undamaged. -/
theorem burn_more_quiet : ∀ g', Move (s0 false) g' → g'.cur.active.map InPlay.damage = some 0 := by
  intro g' hm
  obtain ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩ := only_endTurn hm
  cases oa with
  | nil => cases fa <;> rfl
  | cons b o => cases b <;> cases fa <;> rfl

/-! ## Two sources: an effect on each side of the Special Conditions' step -/

/-- Two Magmortar-like sources (one Active, one Benched) for the player to move; the opponent's
`victim` Burned (the review's probe). -/
def m2 : GameState :=
  ⟨side (InPlay.ofBasic magmaC) [InPlay.ofBasic magmaC], side (victim true) [], true, false, false,
    false, none, none, false, false, false⟩

theorem m2_wellFormed : WellFormed m2 := by
  refine ⟨fun _ => ⟨by simp [m2, side], by simp [m2, side]⟩, ?_, ?_, .of_b rfl⟩ <;> intro p hp <;>
    simp [m2, side] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem m2_settled : Settled m2 := (GameState.settled_iff _).2 (by decide)

/-- **From `m2` the only moves are ends of turn**: hands are empty, no activated Ability, no attack,
and the Active `magma` cannot pay its Retreat Cost. -/
theorem m2_only_endTurn {g' : GameState} (hm : Move m2 g') :
    ∃ (fa sa ca fb sb cb : Bool) (oa ob : List Bool),
      g' = m2.passTurn fa sa ca fb sb cb (victim true) (InPlay.ofBasic magmaC) []
        [(InPlay.ofBasic magmaC).unfresh] oa ob := by
  cases hm with
  | playBasic hh => simp [m2, side] at hh
  | trigger _ hp => simp [m2] at hp
  | attach hh => simp [m2, side] at hh
  | evolve hh => simp [m2, side] at hh
  | attachBench hh => simp [m2, side] at hh
  | evolveBench hh => simp [m2, side] at hh
  | retreat ha _ _ he hp =>
      simp only [m2, side, Option.some.injEq] at ha; subst ha
      simp only [InPlay.ofBasic] at he
      cases he
      exact absurd hp (by decide)
  | item hh => simp [m2, side] at hh
  | supporter hh => simp [m2, side] at hh
  | stadium hh => simp [m2, side] at hh
  | tool hh => simp [m2, side] at hh
  | toolBench hh => simp [m2, side] at hh
  | stadiumUse hs => simp [m2] at hs
  | @ability _ _ x _ _ hu hm' hk =>
      have hx : x = InPlay.ofBasic magmaC := by
        cases hu with
        | active ha' => simp only [m2, side, Option.some.injEq] at ha'; exact ha'.symm
        | bench hb' => exact (one_split hb').2.1
      subst hx
      simp only [InPlay.abilities, InPlay.ofBasic, magmaC, List.mem_cons, List.mem_append,
        List.not_mem_nil, or_false, List.flatMap_nil] at hm'
      subst hm'
      simp [blaze, AbilityUse.activated] at hk
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [m2, side] at hh
  | attack ha' hm' =>
      simp only [m2, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.attacks, InPlay.ofBasic, magmaC] at hm'
  | attackConfused ha' hm' =>
      simp only [m2, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.attacks, InPlay.ofBasic, magmaC] at hm'
  | knockOuts h => exact absurd m2_settled.calm h.not_calm
  | @endTurn a b bo bc fa sa ca fb sb cb ha hb _ _ hco hcc _ oa ob =>
      simp only [m2, side, Option.some.injEq] at ha hb
      subst ha hb
      cases hco
      simp only [m2, side, List.map_cons, List.map_nil] at hcc
      cases hcc with
      | cons hs hn =>
          cases hn
          cases hs with
          | keep => exact ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩
          | burn h => exact absurd h (by decide)
  | startTurn hbt => simp [m2] at hbt
  | deckOut hbt => simp [m2] at hbt

/-- The counters on `victim` after an end of turn from `m2`: 2, 5 or 8, whatever the flips and the
order. -/
theorem m2_totals (fa sa ca fb sb cb : Bool) (oa ob : List Bool) :
    (m2.passTurn fa sa ca fb sb cb (victim true) (InPlay.ofBasic magmaC) []
      [(InPlay.ofBasic magmaC).unfresh] oa ob).cur.active.map InPlay.damage ∈
        [some 2, some 5, some 8] := by
  rcases oa with _ | ⟨b₁, _ | ⟨b₂, o⟩⟩ <;> (try cases b₁) <;> (try cases b₂) <;> cases fa <;>
    first
    | exact .head _
    | exact .tail _ (.head _)
    | exact .tail _ (.tail _ (.head _))

/-- **Two sources: one before the Special Conditions' step, one after** (the review's case). From
the well-formed, `Settled` start `m2`, ends of turn leave the Burned `victim` with 2, 5 and 8 damage
counters, each reachable, and every move leaves it with one of these. The 5 is the rulebook's
"apply one Ability, then Special Conditions, and then another Ability" (2026 p. 15): one effect's
3 on the Burned `victim`, the Burn's 2 and the recovery on heads, then the second effect, which
finds it no longer Burned. -/
theorem two_sources :
    (∃ g', Move m2 g' ∧ g'.cur.active.map InPlay.damage = some 2) ∧
      (∃ g', Move m2 g' ∧ g'.cur.active.map InPlay.damage = some 5) ∧
      (∃ g', Move m2 g' ∧ g'.cur.active.map InPlay.damage = some 8) ∧
      ∀ g', Move m2 g' → g'.cur.active.map InPlay.damage ∈ [some 2, some 5, some 8] :=
  ⟨⟨_, .endTurn true false false false false false rfl rfl m2_settled.1 rfl .nil
      (.cons (.keep _) .nil) (oa := [false, false]), rfl⟩,
    ⟨_, .endTurn true false false false false false rfl rfl m2_settled.1 rfl .nil
      (.cons (.keep _) .nil) (oa := [true, false]), rfl⟩,
    ⟨_, .endTurn true false false false false false rfl rfl m2_settled.1 rfl .nil
      (.cons (.keep _) .nil), rfl⟩,
    fun g' hm => by
      obtain ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩ := m2_only_endTurn hm
      exact m2_totals fa sa ca fb sb cb oa ob⟩

/-- The opponent's `victim`, Poisoned. -/
def pvictim : InPlay := { InPlay.ofBasic bigC with poisoned := true }

/-- The player's `tox` at `sp` (with a `sitter` Active if `sp = .bench`); the opponent's Poisoned
`victim` Active. -/
def t0 : Spot → GameState
  | .active => ⟨side (InPlay.ofBasic toxC) [], side pvictim [], true, false, false, false, none,
      none, false, false, false⟩
  | .bench => ⟨side (InPlay.ofBasic sitterC) [InPlay.ofBasic toxC], side pvictim [], true, false,
      false, false, none, none, false, false, false⟩

theorem t0_settled (sp : Spot) : Settled (t0 sp) := by
  cases sp <;> exact (GameState.settled_iff _).2 (by decide)

theorem t0_wellFormed (sp : Spot) : WellFormed (t0 sp) := by
  cases sp
  · exact ⟨fun _ => ⟨by simp [t0, side], by simp [t0, side]⟩, fun _ hp => by simp [t0, side] at hp,
      fun _ hp => by simp [t0, side] at hp, .of_b rfl⟩
  · refine ⟨fun _ => ⟨by simp [t0, side], by simp [t0, side]⟩, fun p hp => ?_, fun _ hp => by simp [t0, side] at hp,
      .of_b rfl⟩
    simp only [t0, side, List.mem_singleton] at hp
    subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

/-- From `t0 .active` the only moves are ends of turn (`tox` cannot pay its Retreat Cost). -/
theorem t0a_only_endTurn {g' : GameState} (hm : Move (t0 .active) g') :
    ∃ (fa sa ca fb sb cb : Bool) (oa ob : List Bool),
      g' = (t0 .active).passTurn fa sa ca fb sb cb pvictim (InPlay.ofBasic toxC) [] [] oa ob := by
  cases hm with
  | playBasic hh => simp [t0, side] at hh
  | trigger _ hp => simp [t0] at hp
  | attach hh => simp [t0, side] at hh
  | evolve hh => simp [t0, side] at hh
  | attachBench hh => simp [t0, side] at hh
  | evolveBench hh => simp [t0, side] at hh
  | retreat _ hb => simp [t0, side] at hb
  | item hh => simp [t0, side] at hh
  | supporter hh => simp [t0, side] at hh
  | stadium hh => simp [t0, side] at hh
  | tool hh => simp [t0, side] at hh
  | toolBench hh => simp [t0, side] at hh
  | stadiumUse hs => simp [t0] at hs
  | ability hu hm' hk =>
      cases hu with
      | active ha' =>
          simp only [t0, side, Option.some.injEq] at ha'; subst ha'
          simp only [InPlay.abilities, InPlay.ofBasic, toxC, List.mem_cons, List.mem_append,
            List.not_mem_nil, or_false, List.flatMap_nil] at hm'
          subst hm'
          simp [venom, AbilityUse.activated] at hk
      | bench hb' => simp [t0, side] at hb'
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [t0, side] at hh
  | attack ha' hm' =>
      simp only [t0, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.attacks, InPlay.ofBasic, toxC] at hm'
  | attackConfused ha' hm' =>
      simp only [t0, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.attacks, InPlay.ofBasic, toxC] at hm'
  | knockOuts h => exact absurd (t0_settled .active).calm h.not_calm
  | @endTurn a b bo bc fa sa ca fb sb cb ha hb _ _ hco hcc _ oa ob =>
      simp only [t0, side, Option.some.injEq] at ha hb
      subst ha hb
      cases hco
      cases hcc
      exact ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩
  | startTurn hbt => simp [t0] at hbt
  | deckOut hbt => simp [t0] at hbt

/-- From `t0 .bench` every move that ends the turn (`between` set) is an end of turn; the other
moves are `sitter`'s retreats. -/
theorem t0b_endTurn {g' : GameState} (hm : Move (t0 .bench) g') (hbt' : g'.between = true) :
    ∃ (fa sa ca fb sb cb : Bool) (oa ob : List Bool),
      g' = (t0 .bench).passTurn fa sa ca fb sb cb pvictim (InPlay.ofBasic sitterC) []
        [(InPlay.ofBasic toxC).unfresh] oa ob := by
  cases hm with
  | playBasic hh => simp [t0, side] at hh
  | trigger _ hp => simp [t0] at hp
  | attach hh => simp [t0, side] at hh
  | evolve hh => simp [t0, side] at hh
  | attachBench hh => simp [t0, side] at hh
  | evolveBench hh => simp [t0, side] at hh
  | retreat => simp [GameState.noteBenched, t0] at hbt'
  | item hh => simp [t0, side] at hh
  | supporter hh => simp [t0, side] at hh
  | stadium hh => simp [t0, side] at hh
  | tool hh => simp [t0, side] at hh
  | toolBench hh => simp [t0, side] at hh
  | stadiumUse hs => simp [t0] at hs
  | @ability _ _ x _ _ hu hm' hk =>
      cases hu with
      | active ha' =>
          simp only [t0, side, Option.some.injEq] at ha'; subst ha'
          simp [InPlay.abilities, InPlay.ofBasic, sitterC] at hm'
      | bench hb' =>
          obtain ⟨-, rfl, -⟩ := one_split hb'
          simp only [InPlay.abilities, InPlay.ofBasic, toxC, List.mem_cons, List.mem_append,
            List.not_mem_nil, or_false, List.flatMap_nil] at hm'
          subst hm'
          simp [venom, AbilityUse.activated] at hk
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [t0, side] at hh
  | attack ha' hm' =>
      simp only [t0, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.attacks, InPlay.ofBasic, sitterC] at hm'
  | attackConfused ha' hm' =>
      simp only [t0, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.attacks, InPlay.ofBasic, sitterC] at hm'
  | knockOuts h => exact absurd (t0_settled .bench).calm h.not_calm
  | @endTurn a b bo bc fa sa ca fb sb cb ha hb _ _ hco hcc _ oa ob =>
      simp only [t0, side, Option.some.injEq] at ha hb
      subst ha hb
      cases hco
      simp only [t0, side, List.map_cons, List.map_nil] at hcc
      cases hcc with
      | cons hs hn =>
          cases hn
          cases hs with
          | keep => exact ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩
          | burn h => exact absurd h (by decide)
  | startTurn hbt => simp [t0] at hbt
  | deckOut hbt => simp [t0] at hbt

/-- **The Active-only static effect fires while its source is Active**: from `t0 .active` an end of
turn exists, and every move (every move is an end of turn, `t0a_only_endTurn`) puts the Poison's 1
and the effect's 5 counters on `victim`, in either order. -/
theorem poison_active :
    (∃ g', Move (t0 .active) g' ∧ g'.cur.active.map InPlay.damage = some 6) ∧
      ∀ g', Move (t0 .active) g' → g'.cur.active.map InPlay.damage = some 6 :=
  ⟨⟨_, .endTurn false false false false false false rfl rfl (t0_settled .active).1 rfl .nil .nil,
      rfl⟩,
    fun g' hm => by
      obtain ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩ := t0a_only_endTurn hm
      cases oa with
      | nil => rfl
      | cons b o => cases b <;> rfl⟩

/-- **…and not while it is Benched**: from `t0 .bench` an end of turn exists, and every move that
ends the turn puts only the Poison's 1 on `victim`. -/
theorem poison_bench :
    (∃ g', Move (t0 .bench) g' ∧ g'.cur.active.map InPlay.damage = some 1) ∧
      ∀ g', Move (t0 .bench) g' → g'.between = true → g'.cur.active.map InPlay.damage = some 1 :=
  ⟨⟨_, .endTurn false false false false false false rfl rfl (t0_settled .bench).1 rfl .nil
      (.cons (.keep _) .nil), rfl⟩,
    fun g' hm hbt => by
      obtain ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩ := t0b_endTurn hm hbt
      rfl⟩

end Pokemon.CheckupW
