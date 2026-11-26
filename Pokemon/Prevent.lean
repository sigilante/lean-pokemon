import Pokemon.IfDo

/-!
# Damage prevention (milestone MV3, stage 3)

Survey S15 §3. What is implemented:

* (a) **static prevention by a filter on the attacker** (`SEff.prevent fr`): "Prevent all damage
  done to this Pokémon by attacks from your opponent's Pokémon ex" (Sylveon sv8pt5-40, Crustle
  sv10-12; Farigiraf ex sv5-108 with `and basic ex`; Cornerstone Mask Ogerpon ex sv6-112 with
  `hasAbility`), on an Ability, a Tool or a Stadium (Neutralization Zone sv6pt5-60: `sel = all`,
  `filt = noRuleBox`, `fr = ex`). It is read, never stored (`GameState.sPrevent`, computed from the
  static effects in force on the defender, like the static reduction), and makes the damage 0 at
  step 5 of the calculation (`GameState.dealt`). It is a flag: the store bound and both clamps are
  untouched (the clamps keep the field, `GameState.SameField.sPrevent`).
* (b) **lingering prevention for the opponent's next turn**: the model already had it, per player
  (`Mod.prevent`, `linger .own .next .prevent`); print gives it to one Pokémon ("prevent all damage
  … done to this Pokémon"). The departure, listed among the lingering modifiers since they were
  introduced, is unchanged: the model protects whichever Pokémon its player has Active during that
  turn, so a Pokémon switched in after the attack is protected too and the protection does not end
  when the protected Pokémon leaves the Active Spot (fewer damage outcomes than print). The importer
  may write the damage-only form ("prevent all damage done to this Pokémon by attacks", no effect
  clause) as `linger .own .next .prevent`; the filtered form ("from Basic Pokémon", 11 cards) and
  the effect half ("damage from and effects of attacks", 22 cards) are not modelled, and writing the
  latter as damage prevention alone would let the attack's effects through (more outcomes).
* (c) thresholds ("if that damage is 60 or less", 3 cards) are not modelled.

Interaction with stage 1: an attack whose damage "isn't affected by any effects on your opponent's
Active Pokémon" (`Ign.fx`) is not prevented, statically or by the store (`GameState.dealtI`).
Interaction with triggers: a prevented attack does no damage, so the defender's damage does not
rise over the damage step and its `damaged` triggers do not fire (`prevented_quiet`: on every
resolution of the attack the list of triggers is empty); the same defender hit by an attack that
ignores effects on it fires its trigger (`pierce_fires`).
-/

namespace Pokemon.Prevent

open Trainer InPlayTests

/-- "Prevent all damage done to this Pokémon by attacks from your opponent's Pokémon ex." -/
def shield : Ability :=
  ⟨"Shield", .static [⟨.self, .any, none, none, none, .prevent .ex⟩], none, none, .fx .skip⟩

/-- "If this Pokémon is in the Active Spot and is damaged by an attack from your opponent's
Pokémon (even if this Pokémon is Knocked Out), put 2 damage counters on the Attacking Pokémon." -/
def barb : Ability := ⟨"Barb", .triggered .damaged false, none, none, .fx (.counters 2)⟩

/-- A defender with both, 100 HP. -/
def warden : PokemonCard := ⟨"Warden", .basic, none, 10, .fairy, [], 1, none, none, .none, false,
  [shield, barb]⟩

/-- 60 damage, the full calculation. -/
def hit : Attack := ⟨"Hit", [], 0, .damage (.const 6), false, .none⟩

/-- 60 damage that "isn't affected by any effects on your opponent's Active Pokémon". -/
def pierce : Attack := ⟨"Pierce", [], 0, .damage (.const 6) { fx := true }, false, .none⟩

/-- A Pokémon ex attacker with both attacks, and one without a rule box. -/
def brute (rb : RuleBox) : PokemonCard := ⟨"Brute", .basic, none, 20, .dragon, [hit, pierce], 1,
  none, none, rb, false, []⟩

def start (rb : RuleBox) : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic (brute rb)) [],
    side [] [.energy .fire] (InPlay.ofBasic warden) [], true, false, false, false, none, none,
    false, false, false⟩

theorem start_wellFormed (rb : RuleBox) : WellFormed (start rb) := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> cases hp

theorem start_settled : Settled (start .ex) := (GameState.settled_iff _).2 (by decide)

/-- The calculation: 0 from the Pokémon ex (prevented), 6 when step 5 is switched off, 6 from an
attacker without a rule box (the filter fails). -/
theorem start_dealt : (start .ex).sPrevent = true ∧ (start .ex).dealt 6 = 0 ∧
    (start .ex).dealtI { fx := true } 6 = 6 ∧ (start .none).sPrevent = false ∧
    (start .none).dealt 6 = 6 :=
  ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- The resolution of a damage step of a printed amount. -/
theorem damage_const_inv {n : Nat} {ig : Ign} {g g' : GameState} {p : InPlay}
    (hp : g.opp.active = some p) (h : Run (.damage (.const n) ig) g g') :
    g' = { g with opp := { g.opp with active := some { p with damage := p.damage + g.dealtI ig n } } } := by
  cases h with
  | damage hv h' =>
      cases hv
      rw [hp] at h'
      cases h'
      rfl
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw

/-- The state after `hit` from `start .ex`: nothing changed. -/
theorem hit_run : Run hit.script (start .ex) (start .ex) :=
  Run.damage (g := start .ex) (ig := {}) (.const 6 _) rfl

/-- **Witness: a prevented attack**, a legal move from a well-formed, `Settled` state: the Pokémon
ex's attack does no damage to the defender, and fires no trigger. -/
theorem prevented :
    WellFormed (start .ex) ∧ Settled (start .ex) ∧ ∃ g, Move (start .ex) g ∧
      g.opp.active = some (InPlay.ofBasic warden) ∧ g.cur.active = some (InPlay.ofBasic (brute .ex)) :=
  ⟨start_wellFormed _, start_settled, _,
    Move.attackOpen (hlk := rfl) (atk := hit) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled hit_run rfl
      (fun h => absurd h (by decide)) rfl
      (.quiet (sw := false) (.hit rfl hit_run rfl (fun _ => rfl))) (.nil _), rfl, rfl⟩

/-- **The prevented attack fires no trigger, on any resolution**: every choice of `damaged`
triggers that `Move.attack` allows for it is empty. -/
theorem prevented_quiet : ∀ g' l, HitTrig hit (start .ex) g' l → l = [] := by
  intro g' l h
  cases h with
  | quiet => rfl
  | fire h _ =>
      exfalso
      change HitRun (.damage (.const 6)) (start .ex) g' true _ at h
      cases h with
      | hit _ hr hp hb =>
          obtain rfl : InPlay.ofBasic warden = _ := Option.some.inj hp
          obtain rfl := damage_const_inv hp hr
          exact absurd (hb (by decide)) (by decide)

/-- **Witness: the same defender, hit by an attack that ignores effects on it**, takes 6 damage
counters, and its trigger fires: 2 damage counters on the attacker. -/
theorem pierce_fires :
    ∃ g, Move (start .ex) g ∧ g.opp.active = some { InPlay.ofBasic warden with damage := 6 } ∧
      g.cur.active = some { InPlay.ofBasic (brute .ex) with damage := 2 } := by
  have hr : Run pierce.script (start .ex) _ := Run.damage (ig := { fx := true }) (.const 6 _) rfl
  exact ⟨_, Move.attackOpen (hlk := rfl) (atk := pierce) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl start_settled hr
    rfl (fun h => absurd h (by decide)) rfl
    (.fire (sw := false) (.hit rfl hr rfl (fun _ => rfl)) (List.Perm.refl _))
    (.run (ab := barb) (l := []) rfl (.counters 2 rfl) (.nil _)), rfl, rfl⟩

end Pokemon.Prevent
