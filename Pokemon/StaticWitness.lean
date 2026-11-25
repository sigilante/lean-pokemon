import Pokemon.Tools

/-!
# Static effects: witnesses (milestone M6)

HP is derived from the state (`GameState.hpOf`): printed HP changed by the static effects in force.
These witnesses are single states or short lines of play from hand-built starts, each proved
`WellFormed` and `Settled` (`tg0_wellFormed`, `tg0_settled` and the like); every state is closed, so
derived HP is computed by `decide` (through `dbB`).

* `survives_above_printed`: an Item puts 5 damage counters on a 30-HP Pokémon holding a Tool that
  gives +50 HP (Hero's Cape-like); it survives with damage above its printed HP. Before milestone M6
  it was Knocked Out.
* `discard_tool_knocks_out`: from there, an Item that discards the Tools of the player's Active
  Pokémon ("discard all Pokémon Tools from …") lowers its HP below its damage, and the Knock Out is
  taken in mid-effect (`TRun`): the opponent takes a Prize card and the player promotes.
* `stadium_replacement_knocks_out`: a Benched Pokémon survives only by a Stadium's +30 HP (Lively
  Stadium-like); playing another Stadium replaces it, and the Benched Pokémon is then at or above
  its HP and is Knocked Out by the next move.
* `energy_raises_hp`: an Item attaches an Energy from the hand to a Pokémon whose static Ability
  gives +20 HP per Energy attached (Conkeldurr-like), then puts 2 damage counters on it; attaching
  first raises its HP in mid-effect, so the counters do not Knock it Out; `energy_raises_hp_none`:
  the same Item attaching nothing (the model allows it) Knocks it Out, and the game ends.
* `chain_knock_out`: one Stadium replacement Knocks Out a Benched Pokémon whose static Ability gave
  another Benched Pokémon +30 HP; that Knock Out leaves the second Pokémon at or above its HP, and
  it is Knocked Out next: two Knock Outs from one removal.
* `reduction_after_weakness`: a static reduction of 20 (Tool) on a defender weak to the attacker:
  base damage 30 is doubled by Weakness (step 3) and then reduced (step 5), 60 − 20 = 40, not
  (30 − 20) × 2 = 20.

* `chain_knock_out` is also the repetition of the batch Knock Out check (milestone batch-KO): the
  first batch removes the Pokémon whose Ability gave the bonus, and the second, the next move, the
  Pokémon left at or above its HP.

Batch Knock Outs (milestone batch-KO). Until that milestone the model took pending Knock Outs one at
a time, in any order, with promotions in between, and with derived HP the order changed the outcome
in both directions; two DEPARTURES from the rulebook were recorded here (`promotion_rescues`: a
Pokémon the rulebook Knocks Out was promoted while its Knock Out was pending and survived;
`double_knockOut_lost`: a double Knock Out the rulebook takes was not taken in either order). The
rulebook checks every Pokémon once, after the attack, and only then is a new Active Pokémon chosen
(2023 rulebook p. 14); the batch Knock Out step does the same, and the departures are gone:

* `guard_knocked_out`, `double_knockOut_taken`: from the same starts, after the same attacks, every
  move is the batch Knock Out step, which Knocks Out both Pokémon, as the rulebook does; the attack
  is the only move from the start that leads there (`move_r0`, `move_m0`);
* `promotion_rescues_false`, `double_knockOut_lost_false`: the statements of the two departure
  witnesses are false. (`promotion_rescues_alt`, which stated that the rulebook's outcome is also
  reachable, is still true: it is now the only outcome, and redundant beside `guard_knocked_out`.)
* `outcome_per_round`: a recorded modelling decision. The outcome is decided at the end of each
  round of the repeated check, so a Pokémon that is doomed only because another leaves play is not
  counted in the round that ends the game.
-/

namespace Pokemon.StaticWitness

open Trainer (big)

/-- Decide "no pending Knock Out" for a closed state. -/
def dbB (g : GameState) : Bool :=
  (match g.cur.active with
    | some p => decide (p.damage < g.hpOf .own .active p)
    | none => true) &&
  g.cur.bench.all (fun p => decide (p.damage < g.hpOf .own .bench p)) &&
  (match g.opp.active with
    | some p => decide (p.damage < g.hpOf .opp .active p)
    | none => true) &&
  g.opp.bench.all (fun p => decide (p.damage < g.hpOf .opp .bench p))

theorem damageBounded_of_dbB {g : GameState} (h : dbB g = true) : DamageBounded g := by
  simp only [dbB, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at h
  obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := h
  refine DamageBounded.intro' (fun p hp => ?_) h2 (fun p hp => ?_) h4
  · rw [hp] at h1; simpa using h1
  · rw [hp] at h3; simpa using h3

theorem not_damageBounded_of_dbB {g : GameState} (h : dbB g = false) : ¬ DamageBounded g := by
  intro hk
  have : dbB g = true := by
    simp only [dbB, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq]
    refine ⟨⟨⟨?_, fun p hp => hk .own .bench p hp⟩, ?_⟩, fun p hp => hk .opp .bench p hp⟩
    · cases e : g.cur.active with
      | none => rfl
      | some p => simpa using hk .own .active p e
    · cases e : g.opp.active with
      | none => rfl
      | some p => simpa using hk .opp .active p e
  rw [h] at this; cases this

/-- `Settled`, decided, for a closed state with both Active Pokémon. -/
theorem settled_of_dbB {g : GameState} {a b : InPlay} (ha : g.cur.active = some a)
    (hb : g.opp.active = some b) (h : dbB g = true)
    (hpd : g.pend = false := by first | rfl | assumption) : Settled g :=
  ⟨damageBounded_of_dbB h, (by rw [ha]; exact fun e => nomatch e),
    (by rw [hb]; exact fun e => nomatch e), hpd⟩

/-! ## Cards -/

/-- A static effect on the source itself (for a Tool: its holder). -/
def selfStatic (e : SEff) : Static := ⟨.self, .any, none, none, none, e⟩

/-- A Tool: "The Pokémon this card is attached to gets +50 HP" (Hero's Cape is +100). -/
def cape : Card :=
  .tool "Cape" { holder := .any, attacks := [], abilities := [],
                 statics := [selfStatic (.hpPlus (.const 5))] }

/-- A Tool: "The Pokémon this card is attached to takes 20 less damage from attacks" (step 5). -/
def scale : Card :=
  .tool "Scale" { holder := .any, attacks := [], abilities := [],
                  statics := [selfStatic (.reduce 2 .any)] }

/-- A Stadium: "Basic Pokémon in play (both yours and your opponent's) get +30 HP" (Lively
Stadium). -/
def lively : Card := .trainer "Lively" .stadium .skip [⟨.all, .basic, none, none, none, .hpPlus (.const 3)⟩]

/-- A Stadium with no effect. -/
def plainStadium : Card := .trainer "Plain" .stadium .skip

/-- A 30-HP Basic Pokémon with no attack. -/
def small : PokemonCard := ⟨"Small", .basic, none, 3, .colorless, [], 1, none, none, .none, false, []⟩

/-- A static Ability: "+20 HP for each Energy attached to this Pokémon" (Conkeldurr's is +40 per
Fighting Energy). -/
def bulk : Ability := ⟨"Bulk", .static [selfStatic (.hpPlus (.perEnergy .energy 2))], none, none,
  .fx .skip⟩

def bulky : PokemonCard :=
  ⟨"Bulky", .basic, none, 3, .colorless, [], 1, none, none, .none, false, [bulk]⟩

/-- A static Ability: "Your other Pokémon get +30 HP" (Vibrant Dance gives +40 to all). -/
def dance : Ability :=
  ⟨"Dance", .static [⟨.own, .not (.named "Dancer"), none, none, none, .hpPlus (.const 3)⟩], none,
    none, .fx .skip⟩

def dancer : PokemonCard :=
  ⟨"Dancer", .basic, none, 3, .colorless, [], 1, none, none, .none, false, [dance]⟩

/-- A Pokémon in play, not fresh, with damage `d`, Energy `e` and Tools `t`. -/
def at_ (c : PokemonCard) (d : Nat) (e t : List Card) : InPlay :=
  { InPlay.ofBasic c with damage := d, energy := e, tools := t, fresh := false }

def mt : Card := .energy .metal

/-- A player: deck of one Energy, the hand, Prize cards, the Active Pokémon and the Bench. -/
def pl (hand prizes : List Card) (a : InPlay) (bench : List InPlay) : PlayerState :=
  ⟨[mt], hand, [], prizes, [], some a, bench, false, false, false, false, false, Store.empty, true, KOHist.empty⟩

def gs (a b : PlayerState) (st : Option (Bool × Card)) : GameState :=
  ⟨a, b, true, false, false, false, none, st, false, false, false⟩

theorem benched_at (c : PokemonCard) (d : Nat) (e t : List Card) : Benched (at_ c d e t) :=
  ⟨rfl, rfl, rfl, rfl⟩

/-- A state built by `gs` and `pl` with Prize cards on both sides and no Special Condition on the
Benches is well formed. -/
theorem wellFormed_gs {h₁ h₂ p₁ p₂ : List Card} {a₁ a₂ : InPlay} {b₁ b₂ : List InPlay}
    {st : Option (Bool × Card)} (hp₁ : p₁ ≠ []) (hp₂ : p₂ ≠ []) (hb₁ : ∀ p ∈ b₁, Benched p)
    (hb₂ : ∀ p ∈ b₂, Benched p) (hm : (gs (pl h₁ p₁ a₁ b₁) (pl h₂ p₂ a₂ b₂) st).MarksOk) :
    WellFormed (gs (pl h₁ p₁ a₁ b₁) (pl h₂ p₂ a₂ b₂) st) :=
  ⟨fun _ => ⟨hp₁, hp₂⟩, hb₁, hb₂, hm⟩

/-! ## A Tool holds a Pokémon above its printed HP, and its discard Knocks it Out -/

def hurt : Card := .trainer "Hurt" .item (.selfDamage 5)

def strip : Card := .trainer "Strip" .item (.discardTools .own .active)

def tg0 : GameState :=
  gs (pl [hurt, strip] [mt, mt] (at_ small 0 [] [cape]) [at_ big 0 [] []])
    (pl [] [mt, mt] (at_ big 0 [] []) []) none

/-- After the Item: 5 damage counters on the 30-HP holder of `cape`. -/
def tg1 : GameState :=
  gs (⟨[mt], [strip], [hurt], [mt, mt], [], some (at_ small 5 [] [cape]), [at_ big 0 [] []], false,
      false, false, false, false, Store.empty, true, KOHist.empty⟩)
    (pl [] [mt, mt] (at_ big 0 [] []) []) none

theorem tg0_wellFormed : WellFormed tg0 :=
  wellFormed_gs (by decide) (by decide) (by simp [benched_at]) (by simp) (.of_b rfl)

theorem tg0_settled : Settled tg0 := settled_of_dbB rfl rfl (by decide)

theorem tg1_settled : Settled tg1 := settled_of_dbB rfl rfl (by decide)

/-- **A Pokémon survives with damage above its printed HP because of a Tool** (milestone M6): from
a `Settled` state the player plays `hurt`, which puts 5 damage counters on the Active 30-HP
Pokémon holding `cape` (+50 HP); the result is `Settled` with that Pokémon at 5 counters, above its
printed HP of 3 counters and below its derived HP of 8. -/
theorem survives_above_printed :
    Move tg0 tg1 ∧ Settled tg1 ∧
      ∃ p, tg1.cur.active = some p ∧ p.top.hp < p.damage ∧ p.damage < tg1.hpOf .own .active p :=
  ⟨.item (l₁ := []) (l₂ := [strip]) rfl rfl tg0_settled
      (.prim rfl rfl (.selfDamage 5 rfl) (.done (.inl tg1_settled))) rfl rfl rfl rfl,
    tg1_settled, _, rfl, by decide, by decide⟩

/-- After the Tool is discarded: the holder was Knocked Out (the opponent took a Prize card) and
the Benched Pokémon was promoted. -/
def tg2 : GameState :=
  gs (⟨[mt], [], [.pokemon small, cape, strip, hurt], [mt, mt], [], some (at_ big 0 [] []), [],
      false, false, false, false, false, Store.empty, true, ⟨true, false, false, false⟩⟩)
    (⟨[mt], [mt], [], [mt], [], some (at_ big 0 [] []), [], false, false, false, false, false,
      Store.empty, true, KOHist.empty⟩) none

/-- **Discarding the Tool Knocks the Pokémon Out** (milestone M6): from `tg1` the player plays
`strip` ("discard the Tools of your Active Pokémon"); the holder's HP drops from 8 to 3 counters,
below its 5 counters, and the Knock Out is taken at once (`TRun`, `Resolve`): the opponent takes a
Prize card, the player promotes, and the Tool and the Pokémon are in the discard pile. -/
theorem discard_tool_knocks_out : Reach tg0 tg2 := by
  refine .step (.step (.refl _) rfl survives_above_printed.1) rfl
    (.item (l₁ := []) (l₂ := []) rfl rfl tg1_settled
      (.prim rfl rfl (.zone rfl (.toolsActive rfl))
        (.step rfl (.go (by decide) rfl (.pick (b₁ := []) (b₂ := [])) .keep)
          (.done (.inl (settled_of_dbB rfl rfl (by decide))))))
      rfl rfl rfl rfl)

/-! ## A Stadium's replacement Knocks Out a Benched Pokémon -/

def sg0 : GameState :=
  gs (pl [plainStadium] [mt, mt] (at_ big 0 [] []) [at_ small 4 [] []])
    (pl [] [mt, mt] (at_ big 0 [] []) []) (some (false, lively))

def sg1 : GameState :=
  ⟨⟨[mt], [], [], [mt, mt], [], some (at_ big 0 [] []), [at_ small 4 [] []], false, false, false,
      false, false, Store.empty, true, KOHist.empty⟩,
    ⟨[mt], [], [lively], [mt, mt], [], some (at_ big 0 [] []), [], false, false, false, false,
      false, Store.empty, true, KOHist.empty⟩,
    true, false, false, false, none, some (true, plainStadium), true, false, false⟩

theorem sg0_wellFormed : WellFormed sg0 :=
  wellFormed_gs (by decide) (by decide) (by simp [benched_at]) (by simp) (.of_b rfl)

theorem sg0_settled : Settled sg0 := settled_of_dbB rfl rfl (by decide)

/-- **A Stadium's replacement Knocks Out a Benched Pokémon** (milestone M6): the Benched 30-HP
Pokémon has 4 damage counters and survives only by `lively` (+30 HP, owned by the opponent);
the player plays `plainStadium`, which replaces it (it goes to the opponent's discard pile); the
Benched Pokémon is now at or above its HP, no move but the batch Knock Out step is legal (`Settled`
fails), and it is Knocked Out. -/
theorem stadium_replacement_knocks_out :
    Move sg0 sg1 ∧ ¬ DamageBounded sg1 ∧
      ∃ g, Move sg1 g ∧ g.cur.bench = [] ∧ g.cur.discard = [.pokemon small] :=
  ⟨.stadium (l₁ := []) (l₂ := []) rfl rfl rfl rfl sg0_settled rfl,
    not_damageBounded_of_dbB (by decide),
    _, Move.knockOuts_of_nil (.go (by decide) rfl .keep .keep) rfl, rfl, rfl⟩

/-! ## Attaching Energy raises HP in mid-effect -/

/-- "Attach a Basic Energy card from your hand to your Active Pokémon. Then put 2 damage counters
on it." (no printed card; the order is the point). -/
def charge : Card := .trainer "Charge" .item
  (.seq (.attach .own .hand .energy .active .any) (.selfDamage 2))

def eg0 : GameState :=
  gs (pl [charge, mt] [mt, mt] (at_ bulky 3 [mt] []) []) (pl [] [mt, mt] (at_ big 0 [] []) []) none

theorem eg0_wellFormed : WellFormed eg0 :=
  wellFormed_gs (by decide) (by decide) (by simp) (by simp) (.of_b rfl)

theorem eg0_settled : Settled eg0 := settled_of_dbB rfl rfl (by decide)

/-- After the Item with the attachment: 5 counters, HP 3 + 2 × 2 = 7. -/
def eg1 : GameState :=
  gs (⟨[mt], [], [charge], [mt, mt], [], some (at_ bulky 5 [mt, mt] []), [], false, false, false,
      false, false, Store.empty, true, KOHist.empty⟩)
    (pl [] [mt, mt] (at_ big 0 [] []) []) none

/-- **Attaching raises HP in mid-effect** (milestone M6): the Active Pokémon has printed HP 3 and
a static Ability "+20 HP per Energy attached", one Energy and 3 damage counters (HP 5). The Item
attaches a second Energy (HP 7), then puts 2 counters on it: 5 < 7, it survives (`eg1` is
`Settled`). Without the attachment the counters Knock it Out (`energy_raises_hp_none`). -/
theorem energy_raises_hp :
    Move eg0 eg1 ∧ Settled eg1 ∧
      eg0.hpOf .own .active (at_ bulky 3 [mt] []) = 5 ∧
      eg1.hpOf .own .active (at_ bulky 5 [mt, mt] []) = 7 :=
  ⟨.item (l₁ := []) (l₂ := [mt]) rfl rfl (settled_of_dbB rfl rfl (by decide))
      (.seq (.prim rfl rfl (.zone rfl (.attachActive (t := .metal)
          (.take rfl .nil) rfl rfl rfl)) (.done (.inl (settled_of_dbB rfl rfl (by decide)))))
        (.prim rfl rfl (.selfDamage 2 rfl) (.done (.inl (settled_of_dbB rfl rfl (by decide))))))
      rfl rfl rfl rfl,
    settled_of_dbB rfl rfl (by decide), by decide, by decide⟩

/-- **The same counters without the attachment Knock it Out**, the companion of `energy_raises_hp`:
the same Item from `eg0`, attaching nothing (`ZStep.attachNone`), leaves the Pokémon at HP 5 with 5
counters; the Knock Out is taken in mid-effect (`TRun`). The theorem states that the player's
Active Spot is then empty, the Pokémon is in the discard pile and the game has a winner; that
the winner is the opponent is read off the witness, not stated. -/
theorem energy_raises_hp_none :
    ∃ g, Move eg0 g ∧ g.cur.active = none ∧ Card.pokemon bulky ∈ g.cur.discard ∧
      g.winner ≠ none :=
  ⟨_, .item (l₁ := []) (l₂ := [mt]) rfl rfl eg0_settled
      (.seq (.prim rfl rfl (.zone rfl (.attachNone _ _ _ _ _ _))
          (.done (.inl (settled_of_dbB rfl rfl (by decide)))))
        (.prim rfl rfl (.selfDamage 2 rfl) (.step rfl (.won (by decide) (by decide))
          (.done (.inr (by decide))))))
      rfl rfl rfl rfl, rfl, by decide, by decide⟩

/-! ## One removal, two Knock Outs in a chain -/

def cg0 : GameState :=
  gs (pl [plainStadium] [mt, mt, mt] (at_ big 0 [] []) [at_ dancer 5 [] [], at_ small 5 [] []])
    (pl [] [mt, mt, mt] (at_ big 0 [] []) []) (some (false, lively))

def cg1 : GameState :=
  ⟨⟨[mt], [], [], [mt, mt, mt], [], some (at_ big 0 [] []), [at_ dancer 5 [] [], at_ small 5 [] []],
      false, false, false, false, false, Store.empty, true, KOHist.empty⟩,
    ⟨[mt], [], [lively], [mt, mt, mt], [], some (at_ big 0 [] []), [], false, false, false, false,
      false, Store.empty, true, KOHist.empty⟩,
    true, false, false, false, none, some (true, plainStadium), true, false, false⟩

theorem cg0_wellFormed : WellFormed cg0 :=
  wellFormed_gs (by decide) (by decide) (by simp [benched_at]) (by simp) (.of_b rfl)

theorem cg0_settled : Settled cg0 := settled_of_dbB rfl rfl (by decide)

/-- **Two Knock Outs from one removal** (milestone M6): `dancer` (printed HP 3, 5 counters) gives
the player's other Pokémon +30 HP; `small` (printed HP 3, 5 counters) survives on `lively` (+30)
and `dancer` (+30): HP 9. `dancer` survives on `lively` alone: HP 6. Replacing `lively` leaves
`dancer` at HP 3 (pending Knock Out) and `small` at HP 6 (not pending). The batch Knock Out step
Knocks Out `dancer` alone (the check sees `small` at HP 6) and removes its Ability: `small` is now at
HP 3 with 5 counters, a pending Knock Out, and the check repeats: the next move, a second batch,
Knocks it Out (milestone batch-KO; before it, two single Knock Out moves). -/
theorem chain_knock_out :
    Settled cg0 ∧ Move cg0 cg1 ∧
      cg1.hpOf .own .bench (at_ dancer 5 [] []) = 3 ∧ cg1.hpOf .own .bench (at_ small 5 [] []) = 6 ∧
      ∃ g₂ g₃, Move cg1 g₂ ∧ ¬ DamageBounded g₂ ∧ g₂.cur.bench = [at_ small 5 [] []] ∧
        Move g₂ g₃ ∧ g₃.cur.bench = [] ∧ DamageBounded g₃ :=
  ⟨settled_of_dbB rfl rfl (by decide),
    .stadium (l₁ := []) (l₂ := []) rfl rfl rfl rfl (settled_of_dbB rfl rfl (by decide)) rfl,
    by decide, by decide,
    _, _, Move.knockOuts_of_nil (.go (by decide) rfl .keep .keep) rfl,
    not_damageBounded_of_dbB (by decide), rfl,
    Move.knockOuts_of_nil (.go (by decide) rfl .keep .keep) rfl, rfl,
    damageBounded_of_dbB (by decide)⟩

/-! ## A static reduction comes after Weakness -/

/-- A Fire attacker. -/
def flame : PokemonCard := ⟨"Flame", .basic, none, 10, .fire, [], 1, none, none, .none, false, []⟩

/-- A defender weak to Fire. -/
def leaf : PokemonCard := ⟨"Leaf", .basic, none, 10, .grass, [], 1, some .fire, none, .none, false, []⟩

def wg : GameState :=
  gs (pl [] [mt] (at_ flame 0 [] []) []) (pl [] [mt] (at_ leaf 0 [] [scale]) []) none

theorem wg_wellFormed : WellFormed wg := wellFormed_gs (by decide) (by decide) (by simp) (by simp) (.of_b rfl)

theorem wg_settled : Settled wg := settled_of_dbB rfl rfl (by decide)

/-- **A static reduction is applied at step 5, after Weakness** (milestone M6; rulebook 2023
p. 20): base damage 3 counters against a defender weak to the attacker and holding `scale` (20
less damage): (3 × 2) − 2 = 4 counters, not (3 − 2) × 2 = 2. -/
theorem reduction_after_weakness : wg.sReduce = 2 ∧ wg.weak = true ∧ wg.dealt 3 = 4 :=
  ⟨by decide, by decide, by decide⟩

/-! ## Batch Knock Outs: the order of Knock Outs no longer changes the outcome

The rulebook (2023, p. 14): "check to see if any Pokémon were Knocked Out by the attack … check
every Pokémon that was affected", and only then does a player whose Active Pokémon was Knocked Out
choose a new one. Until milestone batch-KO the model took pending Knock Outs as separate moves, one
at a time, in any order, with promotions in between; with derived HP (milestone M6) a Knock Out or
a promotion could change another Pokémon's HP, and the model parted ways with the rulebook in both
directions (`promotion_rescues`, `double_knockOut_lost`, recorded here as DEPARTURES). The batch
Knock Out step (`KOBatch`) evaluates every Pokémon's HP once, before any removal, and promotes
afterwards. The two starts of those witnesses now give the rulebook's outcome on every line of play
(`guard_knocked_out`, `double_knockOut_taken`), and the two departure statements are false
(`promotion_rescues_false`, `double_knockOut_lost_false`). -/

/-- "+30 HP while this Pokémon is in the Active Spot" (a `self` static effect with a place
condition on its source). -/
def guardAb : Ability :=
  ⟨"Guard", .static [⟨.self, .any, some .active, none, none, .hpPlus (.const 3)⟩], none, none,
    .fx .skip⟩

/-- A 30-HP Basic Pokémon with `guardAb`: HP 3 on the Bench, 6 in the Active Spot. -/
def guard : PokemonCard :=
  ⟨"Guard", .basic, none, 3, .colorless, [], 1, none, none, .none, false, [guardAb]⟩

/-- "Put 3 damage counters on your opponent's Active Pokémon and 3 on one of their Benched
Pokémon." -/
def blast : Attack := ⟨"Blast", [], 0, .seq (.counters 3) (.benchCounters .opp 3), false, .none⟩

def blaster : PokemonCard :=
  ⟨"Blaster", .basic, none, 10, .colorless, [blast], 1, none, none, .none, false, []⟩

/-- The opponent has `small` (HP 3) in the Active Spot and `guard` (HP 3 on the Bench). -/
def r0 : GameState :=
  gs (pl [] [mt, mt] (at_ blaster 0 [] []) []) (pl [] [mt, mt] (at_ small 0 [] []) [at_ guard 0 [] []])
    none

theorem r0_wellFormed : WellFormed r0 :=
  wellFormed_gs (by decide) (by decide) (by simp) (by simp [benched_at]) (.of_b rfl)

theorem r0_settled : Settled r0 := settled_of_dbB rfl rfl (by decide)

/-- `[x] = b₁ ++ q :: b₂` splits only one way. -/
theorem singleton_split {α : Type} {x q : α} {b₁ b₂ : List α} (h : [x] = b₁ ++ q :: b₂) :
    b₁ = [] ∧ q = x ∧ b₂ = [] := by
  cases b₁ with
  | nil =>
      simp only [List.nil_append, List.cons.injEq] at h
      exact ⟨rfl, h.1.symm, h.2.symm⟩
  | cons y ys => simp at h

/-- The state after `blast` from `r0`: 3 counters on the opponent's Active `small` and 3 on the
Benched `guard`. -/
def rA : GameState :=
  let g₂ : GameState := { r0 with opp := { r0.opp with
    active := some { at_ small 0 [] [] with damage := (at_ small 0 [] []).damage + 3 } } }
  let g₃ : GameState := g₂.updSide .opp fun s => { s with
    bench := [] ++ { at_ guard 0 [] [] with damage := (at_ guard 0 [] []).damage + 3 } :: [] }
  { g₃ with attacked := true, cur := { g₃.cur with gxUsed := blast.gx || g₃.cur.gxUsed } }

theorem move_r0_rA : Move r0 rA :=
  .attack (hlk := rfl) (atk := blast) rfl (.head _) (.nil _) rfl rfl rfl rfl r0_settled
    (.seq (.counters 3 rfl) (.benchCounters (b₁ := []) .opp 3 rfl)) rfl (fun h => nomatch h) rfl
    (HitTrig.exists_nil (.seq (.counters 3 rfl) (.benchCounters (b₁ := []) .opp 3 rfl)) rfl) (.nil _)

/-- The attack is the only move from `r0` that leaves `guard` on the Bench with 3 counters: `r0`
has no card in hand, no Benched Pokémon of the player to move, no Stadium, no Ability and no
Confused Pokémon, its only attack resolves one way, and the end of the turn swaps the players
(the new opponent has no Bench). -/
theorem move_r0 {g₁ : GameState} (hm : Move r0 g₁) (hb : g₁.opp.bench = [at_ guard 3 [] []]) :
    g₁ = rA := by
  cases hm with
  | playBasic hh => simp [r0, gs, pl] at hh
  | trigger _ hp => simp [r0, gs] at hp
  | attach hh => simp [r0, gs, pl] at hh
  | evolve hh => simp [r0, gs, pl] at hh
  | attachBench hh => simp [r0, gs, pl] at hh
  | evolveBench hh => simp [r0, gs, pl] at hh
  | retreat _ hb' => simp [r0, gs, pl] at hb'
  | item hh => simp [r0, gs, pl] at hh
  | supporter hh => simp [r0, gs, pl] at hh
  | stadium hh => simp [r0, gs, pl] at hh
  | tool hh => simp [r0, gs, pl] at hh
  | toolBench hh => simp [r0, gs, pl] at hh
  | stadiumUse hs => simp [r0, gs] at hs
  | ability hu hm' =>
      cases hu with
      | active ha =>
          simp only [r0, gs, pl, Option.some.injEq] at ha; subst ha
          simp [InPlay.abilities, at_, InPlay.ofBasic, blaster] at hm'
      | bench hb' => simp [r0, gs, pl] at hb'
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [r0, gs, pl] at hh
  | @attack g' a atk ha hm' _ _ _ _ _ _ hr _ _ _ _ _ hd ht =>
      simp only [r0, gs, pl, Option.some.injEq] at ha; subst ha
      have e : atk = blast := by simpa [InPlay.attacks, at_, InPlay.ofBasic, blaster] using hm'
      subst e
      change Run (.seq (.counters 3) (.benchCounters .opp 3)) r0 g' at hr
      cases hr with
      | seq h1 h2 =>
          cases h1 with
          | counters _ h =>
              simp only [r0, gs, pl, Option.some.injEq] at h; subst h
              cases h2 with
              | benchCounters _ _ h =>
                  obtain ⟨rfl, rfl, rfl⟩ := singleton_split h
                  obtain rfl := hd.nil_of rfl
                  cases ht
                  rfl
              | benchCountersNone _ _ h => simp [GameState.side, r0, gs, pl] at h
              | touchActive he => simp [Effect.touch] at he
              | touchBench he => simp [Effect.touch] at he
              | zone hw => simp [Effect.zSide] at hw
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | attackConfused ha _ _ hs =>
      simp only [r0, gs, pl, Option.some.injEq] at ha; subst ha
      simp [at_, InPlay.ofBasic] at hs
  | knockOuts h => exact absurd r0_settled h.not_settled
  | endTurn _ _ _ _ _ _ _ _ _ _ _ hcc =>
      simp only [r0, gs, pl, List.map_nil] at hcc
      cases hcc
      simp at hb
  | startTurn hbt => simp [r0, gs] at hbt
  | deckOut hbt => simp [r0, gs] at hbt

/-- From a state whose check ends the game, every move is the check. -/
theorem move_eq_koStep {g g' : GameState} (hu : ¬ Calm g) (hw : g.koStep.winner ≠ none)
    (hm : Move g g') (hpd : g.pend = false := by first | rfl | assumption) : g' = g.koStep :=
  hm.eq_koStep_of_won hu hw

/-- Reachability from a state whose check ends the game. -/
theorem reach_of_won {g g' : GameState} (hu : ¬ Calm g) (hw : g.koStep.winner ≠ none)
    (hn : g.winner = none) (h : Reach g g') (hpd : g.pend = false := by first | rfl | assumption) :
    g' = g ∨ g' = g.koStep := by
  induction h with
  | refl => exact .inl rfl
  | step _ hn' hm ih =>
      rcases ih with rfl | rfl
      · exact .inr (move_eq_koStep hu hw hm hpd)
      · exact absurd hn' hw

/-- **The Benched Pokémon cannot be promoted and survive** (milestone batch-KO; it replaces the
DEPARTURE `promotion_rescues`). From the well-formed, `Settled` start `r0` the player attacks with
`blast`, the only move that puts the blast's 3 counters on `guard` (`move_r0`): the opponent's
Active `small` (HP 3) and Benched `guard` (HP 3 on the Bench, 6 in the Active Spot) are both at
their HP in `rA`. Every move from `rA` is the batch Knock Out step `rA.koStep` (no promotion: the
game is over), which Knocks Out both, as the rulebook's single check does: the opponent has no
Pokémon left, both cards are in their discard pile, and the player, who took their last two Prize
cards and left the opponent no Pokémon, has won. Every line of play from `rA` is `rA` itself or
that state. -/
theorem guard_knocked_out :
    Move r0 rA ∧ rA.opp.bench = [at_ guard 3 [] []] ∧
      rA.hpOf .opp .bench (at_ guard 3 [] []) = 3 ∧ ¬ DamageBounded rA ∧
      (∀ g₁, Move r0 g₁ → g₁.opp.bench = [at_ guard 3 [] []] → g₁ = rA) ∧
      (∀ g₂, Move rA g₂ → g₂ = rA.koStep) ∧
      rA.koStep.opp.active = none ∧ rA.koStep.opp.bench = [] ∧
      rA.koStep.opp.discard = [.pokemon small, .pokemon guard] ∧
      rA.koStep.winner = some (.win true) ∧
      (∀ g, Reach rA g → g = rA ∨ g = rA.koStep) := by
  have hk : ¬ DamageBounded rA := not_damageBounded_of_dbB (by decide)
  have hu : ¬ Calm rA := fun hs => hk hs.1
  have hw : rA.koStep.winner ≠ none := by decide
  exact ⟨move_r0_rA, rfl, by decide, hk, fun _ hm hb => move_r0 hm hb,
    fun _ hm => move_eq_koStep hu hw hm, rfl, rfl, rfl, by decide,
    fun _ h => reach_of_won hu hw rfl h⟩

/-- **`promotion_rescues` is false** with batch Knock Outs. That theorem (milestones M6 to
batch-KO) stated a line of play from `r0` in which `guard`, Knocked Out by the rulebook, is
promoted while its Knock Out is pending and survives in the Active Spot with HP 6; this is its
negation. -/
theorem promotion_rescues_false :
    ¬ ∃ g₁ g₂ g₃, Move r0 g₁ ∧ g₁.opp.bench = [at_ guard 3 [] []] ∧
      g₁.hpOf .opp .bench (at_ guard 3 [] []) = 3 ∧ ¬ DamageBounded g₁ ∧
      Move g₁ g₂ ∧ Move g₂ g₃ ∧ Reach r0 g₃ ∧ g₃.opp.active = some (at_ guard 3 [] []) ∧
      g₃.hpOf .opp .active (at_ guard 3 [] []) = 6 ∧ DamageBounded g₃ := by
  rintro ⟨g₁, g₂, g₃, h1, hb, -, -, h2, h3, -, ha, -, -⟩
  obtain ⟨-, -, -, hk, hr0, hrA, -⟩ := guard_knocked_out
  have e1 := hr0 g₁ h1 hb
  subst e1
  have e2 := hrA g₂ h2
  subst e2
  have e3 := move_eq_koStep (g := rA.koStep) (fun hs => by
    have : rA.koStep.opp.active ≠ none := hs.2.2
    exact this rfl) (by decide) h3
  subst e3
  exact absurd ha (by simp [show rA.koStep.koStep.opp.active = none from rfl])

/-- The rulebook's outcome is reachable from `r0`: both Knock Outs, the Bench left empty. (Before
milestone batch-KO this was the companion of the departure `promotion_rescues`, one of two orders;
it is now the only outcome, `guard_knocked_out`.) Redundant since milestone batch-KO: it follows
from `guard_knocked_out` (whose moves `Move r0 rA` and `Move rA rA.koStep` give it), and is kept
only because earlier versions stated it. -/
theorem promotion_rescues_alt : ∃ g₁ g₂, Move r0 g₁ ∧ Move g₁ g₂ ∧ g₂.opp.bench = [] :=
  ⟨rA, rA.koStep, move_r0_rA, Move.knockOuts_of_nil (.won (fun hs => (not_damageBounded_of_dbB (by decide)) hs.1)
    (by decide)) rfl, rfl⟩

/-- "Each of your Pokémon gets −10 HP" (a static effect on its owner's side, the source included;
no printed card is claimed). -/
def grav : Ability :=
  ⟨"Grav", .static [⟨.own, .any, none, none, none, .hpMinus 1⟩], none, none, .fx .skip⟩

/-- A 40-HP Basic Pokémon with `grav`: with two of them in play, each has HP 4 − 2 = 2. -/
def gm : PokemonCard := ⟨"Gm", .basic, none, 4, .colorless, [], 1, none, none, .none, false, [grav]⟩

/-- "Put 2 damage counters on your opponent's Active Pokémon and 2 on one of their Benched
Pokémon." -/
def hit2 : Attack := ⟨"Hit2", [], 0, .seq (.counters 2) (.benchCounters .opp 2), false, .none⟩

def hitter2 : PokemonCard :=
  ⟨"Hitter2", .basic, none, 10, .colorless, [hit2], 1, none, none, .none, false, []⟩

/-- The opponent has a `gm` in the Active Spot and one on the Bench. -/
def m0 : GameState :=
  gs (pl [] [mt, mt, mt] (at_ hitter2 0 [] []) [])
    (pl [] [mt, mt, mt] (at_ gm 0 [] []) [at_ gm 0 [] []]) none

theorem m0_wellFormed : WellFormed m0 :=
  wellFormed_gs (by decide) (by decide) (by simp) (by simp [benched_at]) (.of_b rfl)

theorem m0_settled : Settled m0 := settled_of_dbB rfl rfl (by decide)

/-- The state after `hit2` from `m0`: 2 counters on each of the opponent's `gm`. -/
def mA : GameState :=
  let g₂ : GameState := { m0 with opp := { m0.opp with
    active := some { at_ gm 0 [] [] with damage := (at_ gm 0 [] []).damage + 2 } } }
  let g₃ : GameState := g₂.updSide .opp fun s => { s with
    bench := [] ++ { at_ gm 0 [] [] with damage := (at_ gm 0 [] []).damage + 2 } :: [] }
  { g₃ with attacked := true, cur := { g₃.cur with gxUsed := hit2.gx || g₃.cur.gxUsed } }

theorem move_m0_mA : Move m0 mA :=
  .attack (hlk := rfl) (atk := hit2) rfl (.head _) (.nil _) rfl rfl rfl rfl m0_settled
    (.seq (.counters 2 rfl) (.benchCounters (b₁ := []) .opp 2 rfl)) rfl (fun h => nomatch h) rfl
    (HitTrig.exists_nil (.seq (.counters 2 rfl) (.benchCounters (b₁ := []) .opp 2 rfl)) rfl) (.nil _)

/-- The attack is the only move from `m0` that leaves a `gm` with 2 counters on the opponent's
Bench. -/
theorem move_m0 {g₁ : GameState} (hm : Move m0 g₁) (hb : g₁.opp.bench = [at_ gm 2 [] []]) :
    g₁ = mA := by
  cases hm with
  | playBasic hh => simp [m0, gs, pl] at hh
  | trigger _ hp => simp [m0, gs] at hp
  | attach hh => simp [m0, gs, pl] at hh
  | evolve hh => simp [m0, gs, pl] at hh
  | attachBench hh => simp [m0, gs, pl] at hh
  | evolveBench hh => simp [m0, gs, pl] at hh
  | retreat _ hb' => simp [m0, gs, pl] at hb'
  | item hh => simp [m0, gs, pl] at hh
  | supporter hh => simp [m0, gs, pl] at hh
  | stadium hh => simp [m0, gs, pl] at hh
  | tool hh => simp [m0, gs, pl] at hh
  | toolBench hh => simp [m0, gs, pl] at hh
  | stadiumUse hs => simp [m0, gs] at hs
  | ability hu hm' =>
      cases hu with
      | active ha =>
          simp only [m0, gs, pl, Option.some.injEq] at ha; subst ha
          simp [InPlay.abilities, at_, InPlay.ofBasic, hitter2] at hm'
      | bench hb' => simp [m0, gs, pl] at hb'
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [m0, gs, pl] at hh
  | @attack g' a atk ha hm' _ _ _ _ _ _ hr _ _ _ _ _ hd ht =>
      simp only [m0, gs, pl, Option.some.injEq] at ha; subst ha
      have e : atk = hit2 := by simpa [InPlay.attacks, at_, InPlay.ofBasic, hitter2] using hm'
      subst e
      change Run (.seq (.counters 2) (.benchCounters .opp 2)) m0 g' at hr
      cases hr with
      | seq h1 h2 =>
          cases h1 with
          | counters _ h =>
              simp only [m0, gs, pl, Option.some.injEq] at h; subst h
              cases h2 with
              | benchCounters _ _ h =>
                  obtain ⟨rfl, rfl, rfl⟩ := singleton_split h
                  obtain rfl := hd.nil_of rfl
                  cases ht
                  rfl
              | benchCountersNone _ _ h => simp [GameState.side, m0, gs, pl] at h
              | touchActive he => simp [Effect.touch] at he
              | touchBench he => simp [Effect.touch] at he
              | zone hw => simp [Effect.zSide] at hw
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | attackConfused ha _ _ hs =>
      simp only [m0, gs, pl, Option.some.injEq] at ha; subst ha
      simp [at_, InPlay.ofBasic] at hs
  | knockOuts h => exact absurd m0_settled h.not_settled
  | endTurn _ _ _ _ _ _ _ _ _ _ _ hcc =>
      simp only [m0, gs, pl, List.map_nil] at hcc
      cases hcc
      simp at hb
  | startTurn hbt => simp [m0, gs] at hbt
  | deckOut hbt => simp [m0, gs] at hbt

/-- **A double Knock Out is taken together** (milestone batch-KO; it replaces the DEPARTURE
`double_knockOut_lost`). From the well-formed, `Settled` start `m0` the player attacks with `hit2`,
the only move that leaves a `gm` with 2 counters on the opponent's Bench (`move_m0`): each of the
opponent's two `gm` (HP 2 each, since each carries "your Pokémon get −10 HP") is at its HP in `mA`.
Every move from `mA` is the batch Knock Out step `mA.koStep`, which evaluates both HPs before
removing either and Knocks Out both, as the rulebook's single check does: the opponent has no
Pokémon left, both cards are in their discard pile, the player has taken two Prize cards (one is
left) and has won (the opponent has no Pokémon to promote). Every line of play from `mA` is `mA`
itself or that state. -/
theorem double_knockOut_taken :
    Move m0 mA ∧ mA.opp.active = some (at_ gm 2 [] []) ∧ mA.opp.bench = [at_ gm 2 [] []] ∧
      mA.hpOf .opp .active (at_ gm 2 [] []) = 2 ∧ mA.hpOf .opp .bench (at_ gm 2 [] []) = 2 ∧
      ¬ DamageBounded mA ∧
      (∀ g₁, Move m0 g₁ → g₁.opp.bench = [at_ gm 2 [] []] → g₁ = mA) ∧
      (∀ g₂, Move mA g₂ → g₂ = mA.koStep) ∧
      mA.koStep.opp.active = none ∧ mA.koStep.opp.bench = [] ∧
      mA.koStep.opp.discard = [.pokemon gm, .pokemon gm] ∧ mA.koStep.cur.prizes.length = 1 ∧
      mA.koStep.winner = some (.win true) ∧
      (∀ g, Reach mA g → g = mA ∨ g = mA.koStep) := by
  have hk : ¬ DamageBounded mA := not_damageBounded_of_dbB (by decide)
  have hu : ¬ Calm mA := fun hs => hk hs.1
  have hw : mA.koStep.winner ≠ none := by decide
  exact ⟨move_m0_mA, rfl, rfl, by decide, by decide, hk, fun _ hm hb => move_m0 hm hb,
    fun _ hm => move_eq_koStep hu hw hm, rfl, rfl, rfl, rfl, by decide,
    fun _ h => reach_of_won hu hw rfl h⟩

/-- **`double_knockOut_lost` is false** with batch Knock Outs. That theorem (milestones M6 to
batch-KO) stated that from the state after `hit2` either Knock Out could be taken first and left the
other `gm` in play, no longer pending; this is its negation. -/
theorem double_knockOut_lost_false :
    ¬ ∃ g₁, Move m0 g₁ ∧ g₁.opp.active = some (at_ gm 2 [] []) ∧
      g₁.opp.bench = [at_ gm 2 [] []] ∧ g₁.hpOf .opp .active (at_ gm 2 [] []) = 2 ∧
      g₁.hpOf .opp .bench (at_ gm 2 [] []) = 2 ∧ ¬ DamageBounded g₁ ∧
      (∃ g₂, Move g₁ g₂ ∧ g₂.opp.active = none ∧ g₂.opp.bench = [at_ gm 2 [] []] ∧
        g₂.hpOf .opp .bench (at_ gm 2 [] []) = 3) ∧
      (∃ g₂, Move g₁ g₂ ∧ g₂.opp.bench = [] ∧ g₂.opp.active = some (at_ gm 2 [] []) ∧
        g₂.hpOf .opp .active (at_ gm 2 [] []) = 3) := by
  rintro ⟨g₁, h1, -, hb, -, -, -, ⟨g₂, h2, -, hb₂, -⟩, -⟩
  obtain ⟨-, -, -, -, -, -, hm0, hmA, -⟩ := double_knockOut_taken
  have e1 := hm0 g₁ h1 hb
  subst e1
  have e2 := hmA g₂ h2
  subst e2
  exact absurd hb₂ (by simp [show mA.koStep.opp.bench = [] from rfl])

/-! ## The outcome is decided at the end of each round of the check

The check repeats (`KOBatch`), and the outcome is decided at the end of each round, from that
round's Knock Outs (`GameState.koStep`). A Pokémon whose HP falls only because another Pokémon
leaves play in that round is not Knocked Out in it; if the round ends the game, it is never
counted. -/

/-- "While this Pokémon is in the Active Spot, each of your Benched Pokémon gets +30 HP" (no
printed card is claimed). -/
def rallyAb : Ability :=
  ⟨"Rally", .static [⟨.own, .any, some .bench, some .active, none, .hpPlus (.const 3)⟩], none, none,
    .fx .skip⟩

/-- A 50-HP Basic Pokémon with `rallyAb`. -/
def boss : PokemonCard :=
  ⟨"Boss", .basic, none, 5, .colorless, [], 1, none, none, .none, false, [rallyAb]⟩

/-- Player A (to move) has one Prize card, an Active `small` with 3 damage counters (HP 3) and a
healthy Benched `small`. Player B has one Prize card, an Active `boss` with 5 damage counters (HP
5) and a Benched `small` with 4 damage counters (HP 6 with `boss`'s bonus, 3 without). -/
def sd0 : GameState :=
  gs (pl [] [mt] (at_ small 3 [] []) [at_ small 0 [] []])
     (pl [] [mt] (at_ boss 5 [] []) [at_ small 4 [] []]) none

theorem sd0_wellFormed : WellFormed sd0 :=
  wellFormed_gs (by decide) (by decide) (by simp [benched_at]) (by simp [benched_at]) (.of_b rfl)

/-- **A recorded modelling decision: the outcome is decided at the end of each round of the
check.** In `sd0` both Active Pokémon are at their HP; B's Benched `small` has 4 damage counters
and HP 6, which it has only while `boss` is in B's Active Spot. Every move from `sd0` is the check
`sd0.koStep`: both Active Pokémon are Knocked Out, each player takes their last Prize card, and B
still has the Benched `small`, so each player wins in one way and the game ends in Sudden Death.
In `sd0.koStep` the `small` has HP 3 and is at its HP, so a second round would Knock it Out, but
the game is already over and nothing follows (every line of play from `sd0` is `sd0` or
`sd0.koStep`). A reading that re-checked after the removals before deciding the game would also
Knock Out the `small`, leaving B no Pokémon in play, and give A a second way to win, so A would win.
The rulebook is silent on this case (it describes one check after an attack and one after Checkup);
deciding at the end of each round is the model's reading, recorded here (Known gaps,
`Pokemon/Rules.lean`). -/
theorem outcome_per_round :
    WellFormed sd0 ∧ sd0.winner = none ∧ ¬ Settled sd0 ∧
      sd0.hpOf .opp .bench (at_ small 4 [] []) = 6 ∧
      (∀ g, Move sd0 g → g = sd0.koStep) ∧
      sd0.koStep.winner = some .suddenDeath ∧
      sd0.koStep.opp.active = none ∧ sd0.koStep.opp.bench = [at_ small 4 [] []] ∧
      sd0.koStep.hpOf .opp .bench (at_ small 4 [] []) = 3 ∧ ¬ DamageBounded sd0.koStep ∧
      (∀ g, Reach sd0 g → g = sd0 ∨ g = sd0.koStep) := by
  have hk : ¬ DamageBounded sd0 := not_damageBounded_of_dbB (by decide)
  have hu : ¬ Calm sd0 := fun hs => hk hs.1
  have hw : sd0.koStep.winner ≠ none := by decide
  exact ⟨sd0_wellFormed, rfl, fun hs => hu hs.calm, by decide, fun _ hm => move_eq_koStep hu hw hm, by decide, rfl,
    rfl, by decide, not_damageBounded_of_dbB (by decide), fun _ h => reach_of_won hu hw rfl h⟩

end Pokemon.StaticWitness
