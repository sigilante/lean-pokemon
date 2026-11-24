import Pokemon.Gust

/-!
# Static Checkup effects (milestone MV7b, survey S20 §a T1)

"During Pokémon Checkup, put 3 more damage counters on your opponent's Burned Pokémon." (Magmortar
sv9-21); "As long as this Pokémon is in the Active Spot, put 5 more damage counters on your
opponent's Poisoned Pokémon during Pokémon Checkup." (Pecharunt svp-129). These are static
modifications of the Checkup step (`SEff.condMore c n`), computed from the state when `Move.endTurn`
applies Checkup (`GameState.checkupMore`), never stored; they are not triggers.

The order: "The player whose turn is next decides the order of the effects, but all Special
Conditions must happen at the same time" (rulebook 2026 p. 15). For added damage counters the order
matters only through the Burn flip: applied after the Special Conditions' step, the effect sees a
Pokémon that recovered on heads as no longer Burned. `Move.endTurn` lets each Active Pokémon's
static effects come first (`oa`, `ob` true, the default) or after the Special Conditions
(false); the Knock Out check follows all of them, as the rulebook says ("After both players have
gone through these checks", p. 15).

From the well-formed, `Settled` start `s0 c` (the player to move has the Magmortar-like `magma`
Active; the opponent has `victim` Active, Burned if `c`):
* `only_endTurn`: the only moves are ends of turn;
* `burn_more_fires`: an end of turn with tails puts 2 + 3 damage counters on the Burned `victim`,
  whatever order (`burn_more_tails`: every end of turn with tails does; the effect is mandatory);
* `burn_heads_order`: with heads the order matters: 5 counters (the effect first) and 2 (the
  Special Conditions first, the Pokémon recovered) are both reachable;
* `burn_more_quiet`: a `victim` that is not Burned gets no counter from any end of turn.

From `t0 sp` (the player's Pecharunt-like `tox` at `sp`, the opponent's `victim` Poisoned):
* `poison_active`: with `tox` Active, every end of turn puts 1 + 5 counters on `victim`;
* `poison_bench`: with `tox` Benched (a `sitter` Active), only the Poison's 1.
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
    fun _ hp => by simp [s0, side] at hp⟩

theorem s0_settled (c : Bool) : Settled (s0 c) := by
  cases c <;> exact (GameState.settled_iff _).2 (by decide)

/-- **From `s0 c` the only moves are ends of turn**: hands are empty, no Bench, no activated
Ability, no attack. -/
theorem only_endTurn {c : Bool} {g' : GameState} (hm : Move (s0 c) g') :
    ∃ (fa sa ca fb sb cb oa ob : Bool),
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
theorem burn_more_tails (sa ca fb sb cb oa ob : Bool) :
    ((s0 true).passTurn false sa ca fb sb cb (victim true) (InPlay.ofBasic magmaC) [] []
      oa ob).cur.active.map InPlay.damage = some 5 := by
  cases oa <;> cases sa <;> cases ca <;> rfl

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
      (oa := false), rfl⟩⟩

/-- **No Burn, no extra counter**: from `s0 false` every move leaves `victim` undamaged. -/
theorem burn_more_quiet : ∀ g', Move (s0 false) g' → g'.cur.active.map InPlay.damage = some 0 := by
  intro g' hm
  obtain ⟨fa, sa, ca, fb, sb, cb, oa, ob, rfl⟩ := only_endTurn hm
  cases oa <;> cases fa <;> cases sa <;> cases ca <;> rfl

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
      fun _ hp => by simp [t0, side] at hp⟩
  · refine ⟨fun _ => ⟨by simp [t0, side], by simp [t0, side]⟩, fun p hp => ?_, fun _ hp => by simp [t0, side] at hp⟩
    simp only [t0, side, List.mem_singleton] at hp
    subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

/-- **The Active-only static effect fires while its source is Active**: ending the turn puts the
Poison's 1 and the effect's 5 counters on `victim`. -/
theorem poison_active :
    ∃ g', Move (t0 .active) g' ∧ g'.cur.active.map InPlay.damage = some 6 :=
  ⟨_, .endTurn false false false false false false rfl rfl (t0_settled .active).1 rfl .nil .nil, rfl⟩

/-- **…and not while it is Benched**: only the Poison's 1. -/
theorem poison_bench :
    ∃ g', Move (t0 .bench) g' ∧ g'.cur.active.map InPlay.damage = some 1 :=
  ⟨_, .endTurn false false false false false false rfl rfl (t0_settled .bench).1 rfl .nil
    (.cons (.keep _) .nil), rfl⟩

end Pokemon.CheckupW
