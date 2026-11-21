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

Two DEPARTURES from the rulebook, recorded so that they cannot be forgotten (see the Known gaps in
`Pokemon/Rules.lean`). The rulebook checks every affected Pokémon for a Knock Out once, after the
attack, and only then is a new Active Pokémon chosen (2023 rulebook p. 14); the model takes pending
Knock Outs one at a time, in any order, with promotions in between, and with derived HP the order
changes the outcome, in both directions:

* `promotion_rescues`: a Pokémon the rulebook Knocks Out survives in the model (it is promoted while
  its own Knock Out is pending, and its HP rises in the Active Spot);
* `double_knockOut_lost`: a double Knock Out the rulebook takes is not taken in the model in
  either order of the two Knock Outs (whichever comes first raises the other Pokémon's HP above
  its damage). The theorem is about those two orders; that no other move is legal in that state
  holds by inspection of `Move` (every other move needs `Settled`) and is not proved.
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
    (hb : g.opp.active = some b) (h : dbB g = true) : Settled g :=
  ⟨damageBounded_of_dbB h, (by rw [ha]; exact fun e => nomatch e),
    (by rw [hb]; exact fun e => nomatch e)⟩

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
  ⟨[mt], hand, [], prizes, [], some a, bench, false, false, false, false, false, Store.empty, true⟩

def gs (a b : PlayerState) (st : Option (Bool × Card)) : GameState :=
  ⟨a, b, true, false, false, false, none, st, false, false⟩

theorem benched_at (c : PokemonCard) (d : Nat) (e t : List Card) : Benched (at_ c d e t) :=
  ⟨rfl, rfl, rfl, rfl⟩

/-- A state built by `gs` and `pl` with Prize cards on both sides and no Special Condition on the
Benches is well formed. -/
theorem wellFormed_gs {h₁ h₂ p₁ p₂ : List Card} {a₁ a₂ : InPlay} {b₁ b₂ : List InPlay}
    {st : Option (Bool × Card)} (hp₁ : p₁ ≠ []) (hp₂ : p₂ ≠ []) (hb₁ : ∀ p ∈ b₁, Benched p)
    (hb₂ : ∀ p ∈ b₂, Benched p) : WellFormed (gs (pl h₁ p₁ a₁ b₁) (pl h₂ p₂ a₂ b₂) st) :=
  ⟨fun _ => ⟨hp₁, hp₂⟩, hb₁, hb₂⟩

/-! ## A Tool holds a Pokémon above its printed HP, and its discard Knocks it Out -/

def hurt : Card := .trainer "Hurt" .item (.selfDamage 5)

def strip : Card := .trainer "Strip" .item (.discardTools .own .active)

def tg0 : GameState :=
  gs (pl [hurt, strip] [mt, mt] (at_ small 0 [] [cape]) [at_ big 0 [] []])
    (pl [] [mt, mt] (at_ big 0 [] []) []) none

/-- After the Item: 5 damage counters on the 30-HP holder of `cape`. -/
def tg1 : GameState :=
  gs (⟨[mt], [strip], [hurt], [mt, mt], [], some (at_ small 5 [] [cape]), [at_ big 0 [] []], false,
      false, false, false, false, Store.empty, true⟩)
    (pl [] [mt, mt] (at_ big 0 [] []) []) none

theorem tg0_wellFormed : WellFormed tg0 :=
  wellFormed_gs (by decide) (by decide) (by simp [benched_at]) (by simp)

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
      false, false, false, false, false, Store.empty, true⟩)
    (⟨[mt], [mt], [], [mt], [], some (at_ big 0 [] []), [], false, false, false, false, false,
      Store.empty, true⟩) none

/-- **Discarding the Tool Knocks the Pokémon Out** (milestone M6): from `tg1` the player plays
`strip` ("discard the Tools of your Active Pokémon"); the holder's HP drops from 8 to 3 counters,
below its 5 counters, and the Knock Out is taken at once (`TRun`, `Resolve`): the opponent takes a
Prize card, the player promotes, and the Tool and the Pokémon are in the discard pile. -/
theorem discard_tool_knocks_out : Reach tg0 tg2 := by
  refine .step (.step (.refl _) rfl survives_above_printed.1) rfl
    (.item (l₁ := []) (l₂ := []) rfl rfl tg1_settled
      (.prim rfl rfl (.zone rfl (.toolsActive rfl))
        (.step rfl (.knockOutOwn rfl (by decide) rfl)
          (.step rfl (.promoteOwn (b₁ := []) (b₂ := []) rfl rfl)
            (.done (.inl (settled_of_dbB rfl rfl (by decide)))))))
      rfl rfl rfl rfl)

/-! ## A Stadium's replacement Knocks Out a Benched Pokémon -/

def sg0 : GameState :=
  gs (pl [plainStadium] [mt, mt] (at_ big 0 [] []) [at_ small 4 [] []])
    (pl [] [mt, mt] (at_ big 0 [] []) []) (some (false, lively))

def sg1 : GameState :=
  ⟨⟨[mt], [], [], [mt, mt], [], some (at_ big 0 [] []), [at_ small 4 [] []], false, false, false,
      false, false, Store.empty, true⟩,
    ⟨[mt], [], [lively], [mt, mt], [], some (at_ big 0 [] []), [], false, false, false, false,
      false, Store.empty, true⟩,
    true, false, false, false, none, some (true, plainStadium), true, false⟩

theorem sg0_wellFormed : WellFormed sg0 :=
  wellFormed_gs (by decide) (by decide) (by simp [benched_at]) (by simp)

theorem sg0_settled : Settled sg0 := settled_of_dbB rfl rfl (by decide)

/-- **A Stadium's replacement Knocks Out a Benched Pokémon** (milestone M6): the Benched 30-HP
Pokémon has 4 damage counters and survives only by `lively` (+30 HP, owned by the opponent);
the player plays `plainStadium`, which replaces it (it goes to the opponent's discard pile); the
Benched Pokémon is now at or above its HP, no move but a Knock Out move is legal (`Settled`
fails), and it is Knocked Out. -/
theorem stadium_replacement_knocks_out :
    Move sg0 sg1 ∧ ¬ DamageBounded sg1 ∧
      ∃ g, Move sg1 g ∧ g.cur.bench = [] ∧ g.cur.discard = [.pokemon small] :=
  ⟨.stadium (l₁ := []) (l₂ := []) rfl rfl rfl rfl sg0_settled rfl,
    not_damageBounded_of_dbB (by decide),
    _, .knockOutBenchOwn (b₁ := []) (b₂ := []) rfl (by decide) rfl, rfl, rfl⟩

/-! ## Attaching Energy raises HP in mid-effect -/

/-- "Attach a Basic Energy card from your hand to your Active Pokémon. Then put 2 damage counters
on it." (no printed card; the order is the point). -/
def charge : Card := .trainer "Charge" .item
  (.seq (.attach .own .hand .energy .active .any) (.selfDamage 2))

def eg0 : GameState :=
  gs (pl [charge, mt] [mt, mt] (at_ bulky 3 [mt] []) []) (pl [] [mt, mt] (at_ big 0 [] []) []) none

theorem eg0_wellFormed : WellFormed eg0 :=
  wellFormed_gs (by decide) (by decide) (by simp) (by simp)

theorem eg0_settled : Settled eg0 := settled_of_dbB rfl rfl (by decide)

/-- After the Item with the attachment: 5 counters, HP 3 + 2 × 2 = 7. -/
def eg1 : GameState :=
  gs (⟨[mt], [], [charge], [mt, mt], [], some (at_ bulky 5 [mt, mt] []), [], false, false, false,
      false, false, Store.empty, true⟩)
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
          (.take rfl .nil) rfl rfl)) (.done (.inl (settled_of_dbB rfl rfl (by decide)))))
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
        (.prim rfl rfl (.selfDamage 2 rfl) (.step rfl (.knockOutOwn rfl (by decide) rfl)
          (.step rfl (.noPokemonOwn rfl rfl) (.done (.inr (by decide)))))))
      rfl rfl rfl rfl, rfl, by decide, by decide⟩

/-! ## One removal, two Knock Outs in a chain -/

def cg0 : GameState :=
  gs (pl [plainStadium] [mt, mt, mt] (at_ big 0 [] []) [at_ dancer 5 [] [], at_ small 5 [] []])
    (pl [] [mt, mt, mt] (at_ big 0 [] []) []) (some (false, lively))

def cg1 : GameState :=
  ⟨⟨[mt], [], [], [mt, mt, mt], [], some (at_ big 0 [] []), [at_ dancer 5 [] [], at_ small 5 [] []],
      false, false, false, false, false, Store.empty, true⟩,
    ⟨[mt], [], [lively], [mt, mt, mt], [], some (at_ big 0 [] []), [], false, false, false, false,
      false, Store.empty, true⟩,
    true, false, false, false, none, some (true, plainStadium), true, false⟩

theorem cg0_wellFormed : WellFormed cg0 :=
  wellFormed_gs (by decide) (by decide) (by simp [benched_at]) (by simp)

theorem cg0_settled : Settled cg0 := settled_of_dbB rfl rfl (by decide)

/-- **Two Knock Outs from one removal** (milestone M6): `dancer` (printed HP 3, 5 counters) gives
the player's other Pokémon +30 HP; `small` (printed HP 3, 5 counters) survives on `lively` (+30)
and `dancer` (+30): HP 9. `dancer` survives on `lively` alone: HP 6. Replacing `lively` leaves
`dancer` at HP 3 (pending Knock Out) and `small` at HP 6 (not pending). Knocking `dancer` Out
removes its Ability: `small` is now at HP 3 with 5 counters, a pending Knock Out, and it is Knocked
Out in turn. -/
theorem chain_knock_out :
    Settled cg0 ∧ Move cg0 cg1 ∧
      cg1.hpOf .own .bench (at_ dancer 5 [] []) = 3 ∧ cg1.hpOf .own .bench (at_ small 5 [] []) = 6 ∧
      ∃ g₂ g₃, Move cg1 g₂ ∧ ¬ DamageBounded g₂ ∧ g₂.cur.bench = [at_ small 5 [] []] ∧
        Move g₂ g₃ ∧ g₃.cur.bench = [] ∧ DamageBounded g₃ :=
  ⟨settled_of_dbB rfl rfl (by decide),
    .stadium (l₁ := []) (l₂ := []) rfl rfl rfl rfl (settled_of_dbB rfl rfl (by decide)) rfl,
    by decide, by decide,
    _, _, .knockOutBenchOwn (b₁ := []) (b₂ := [at_ small 5 [] []]) rfl (by decide) rfl,
    not_damageBounded_of_dbB (by decide), rfl,
    .knockOutBenchOwn (b₁ := []) (b₂ := []) rfl (by decide) rfl, rfl,
    damageBounded_of_dbB (by decide)⟩

/-! ## A static reduction comes after Weakness -/

/-- A Fire attacker. -/
def flame : PokemonCard := ⟨"Flame", .basic, none, 10, .fire, [], 1, none, none, .none, false, []⟩

/-- A defender weak to Fire. -/
def leaf : PokemonCard := ⟨"Leaf", .basic, none, 10, .grass, [], 1, some .fire, none, .none, false, []⟩

def wg : GameState :=
  gs (pl [] [mt] (at_ flame 0 [] []) []) (pl [] [mt] (at_ leaf 0 [] [scale]) []) none

theorem wg_wellFormed : WellFormed wg := wellFormed_gs (by decide) (by decide) (by simp) (by simp)

theorem wg_settled : Settled wg := settled_of_dbB rfl rfl (by decide)

/-- **A static reduction is applied at step 5, after Weakness** (milestone M6; rulebook 2023
p. 20): base damage 3 counters against a defender weak to the attacker and holding `scale` (20
less damage): (3 × 2) − 2 = 4 counters, not (3 − 2) × 2 = 2. -/
theorem reduction_after_weakness : wg.sReduce = 2 ∧ wg.weak = true ∧ wg.dealt 3 = 4 :=
  ⟨by decide, by decide, by decide⟩

/-! ## DEPARTURES: the order of Knock Outs changes the outcome

The rulebook (2023, p. 14): "check to see if any Pokémon were Knocked Out by the attack … check
every Pokémon that was affected", and only then does a player whose Active Pokémon was Knocked Out
choose a new one. The model takes pending Knock Outs as separate moves, one at a time, in any order,
and allows a promotion while a Benched Pokémon's Knock Out is pending. With derived HP (milestone
M6) a Knock Out or a promotion can change another Pokémon's HP, so the model and the rulebook part
ways, in both directions. The planned repair is a batch Knock Out step: compute the set of pending
Knock Outs once, remove them together, and promote only afterwards. -/

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
def blast : Attack := ⟨"Blast", [], 0, .seq (.counters 3) (.benchCounters .opp 3), false⟩

def blaster : PokemonCard :=
  ⟨"Blaster", .basic, none, 10, .colorless, [blast], 1, none, none, .none, false, []⟩

/-- The opponent has `small` (HP 3) in the Active Spot and `guard` (HP 3 on the Bench). -/
def r0 : GameState :=
  gs (pl [] [mt, mt] (at_ blaster 0 [] []) []) (pl [] [mt, mt] (at_ small 0 [] []) [at_ guard 0 [] []])
    none

theorem r0_wellFormed : WellFormed r0 :=
  wellFormed_gs (by decide) (by decide) (by simp) (by simp [benched_at])

theorem r0_settled : Settled r0 := settled_of_dbB rfl rfl (by decide)

/-- **A Pokémon the rulebook Knocks Out survives in the model.** This is a DEPARTURE from the
rulebook, recorded so that it cannot be forgotten.

From the well-formed, `Settled` start `r0` the player attacks with `blast`: the opponent's Active
`small` (HP 3) and Benched `guard` (HP 3 on the Bench) each take 3 counters. In the resulting state
`g₁` both are at their HP, and the rulebook's single check after the attack Knocks Out both. In the
model the Active Pokémon's Knock Out is taken first, then `guard` is promoted while its own Knock
Out is pending; in the Active Spot its HP is 6, so with 3 counters it is no longer pending: the state
`g₃` has no pending Knock Out and `guard` is still in play. (The model also allows the rulebook's
outcome: the Bench Knock Out can be taken first, `promotion_rescues_alt`.) So the model has an
outcome the rulebook does not. -/
theorem promotion_rescues :
    ∃ g₁ g₂ g₃, Move r0 g₁ ∧ g₁.opp.bench = [at_ guard 3 [] []] ∧
      g₁.hpOf .opp .bench (at_ guard 3 [] []) = 3 ∧ ¬ DamageBounded g₁ ∧
      Move g₁ g₂ ∧ Move g₂ g₃ ∧ Reach r0 g₃ ∧ g₃.opp.active = some (at_ guard 3 [] []) ∧
      g₃.hpOf .opp .active (at_ guard 3 [] []) = 6 ∧ DamageBounded g₃ := by
  have m1 : Move r0 _ :=
    .attack (atk := blast) rfl (.head _) (.nil _) rfl rfl rfl rfl r0_settled
      (.seq (.counters 3 rfl) (.benchCounters (b₁ := []) .opp 3 rfl)) rfl (fun h => nomatch h) rfl
  refine ⟨_, _, _, m1, rfl, by decide, not_damageBounded_of_dbB (by decide),
    .knockOut rfl (by decide) rfl, .promote (b₁ := []) rfl rfl, ?_, rfl, by decide,
    damageBounded_of_dbB (by decide)⟩
  exact .step (.step (.step (.refl _) rfl m1) rfl (.knockOut rfl (by decide) rfl)) rfl
    (.promote (b₁ := []) rfl rfl)

/-- The rulebook's outcome is also reachable from the same state: the Bench Knock Out first. -/
theorem promotion_rescues_alt : ∃ g₁ g₂, Move r0 g₁ ∧ Move g₁ g₂ ∧ g₂.opp.bench = [] := by
  have m1 : Move r0 _ :=
    .attack (atk := blast) rfl (.head _) (.nil _) rfl rfl rfl rfl r0_settled
      (.seq (.counters 3 rfl) (.benchCounters (b₁ := []) .opp 3 rfl)) rfl (fun h => nomatch h) rfl
  exact ⟨_, _, m1, .knockOutBench (b₁ := []) (b₂ := []) rfl (by decide) rfl, rfl⟩

/-- "Each of your Pokémon gets −10 HP" (a static effect on its owner's side, the source included;
no printed card is claimed). -/
def grav : Ability :=
  ⟨"Grav", .static [⟨.own, .any, none, none, none, .hpMinus 1⟩], none, none, .fx .skip⟩

/-- A 40-HP Basic Pokémon with `grav`: with two of them in play, each has HP 4 − 2 = 2. -/
def gm : PokemonCard := ⟨"Gm", .basic, none, 4, .colorless, [], 1, none, none, .none, false, [grav]⟩

/-- "Put 2 damage counters on your opponent's Active Pokémon and 2 on one of their Benched
Pokémon." -/
def hit2 : Attack := ⟨"Hit2", [], 0, .seq (.counters 2) (.benchCounters .opp 2), false⟩

def hitter2 : PokemonCard :=
  ⟨"Hitter2", .basic, none, 10, .colorless, [hit2], 1, none, none, .none, false, []⟩

/-- The opponent has a `gm` in the Active Spot and one on the Bench. -/
def m0 : GameState :=
  gs (pl [] [mt, mt, mt] (at_ hitter2 0 [] []) [])
    (pl [] [mt, mt, mt] (at_ gm 0 [] []) [at_ gm 0 [] []]) none

theorem m0_wellFormed : WellFormed m0 :=
  wellFormed_gs (by decide) (by decide) (by simp) (by simp [benched_at])

theorem m0_settled : Settled m0 := settled_of_dbB rfl rfl (by decide)

/-- **A double Knock Out the rulebook takes is lost in the model.** This is a DEPARTURE from the
rulebook, recorded so that it cannot be forgotten.

From the well-formed, `Settled` start `m0` the player attacks with `hit2`: each of the opponent's
two `gm` (HP 2 each, since each carries "your Pokémon get −10 HP") takes 2 counters. In the
resulting state `g₁` both are at their HP, and the rulebook's single check after the attack
Knocks Out both. In the model they are Knocked Out one at a time, and either Knock Out removes one
source of −1 HP: the other `gm` then has HP 3 with 2 counters, and is no longer pending. Proved here
for both orders: taking the Active Knock Out first, and taking the Bench Knock Out first. (That
these are the only Knock Out moves from `g₁` — no other Pokémon is pending there — is read off the
state, not proved.) So the rulebook has an outcome the model does not. -/
theorem double_knockOut_lost :
    ∃ g₁, Move m0 g₁ ∧ g₁.opp.active = some (at_ gm 2 [] []) ∧
      g₁.opp.bench = [at_ gm 2 [] []] ∧ g₁.hpOf .opp .active (at_ gm 2 [] []) = 2 ∧
      g₁.hpOf .opp .bench (at_ gm 2 [] []) = 2 ∧ ¬ DamageBounded g₁ ∧
      (∃ g₂, Move g₁ g₂ ∧ g₂.opp.active = none ∧ g₂.opp.bench = [at_ gm 2 [] []] ∧
        g₂.hpOf .opp .bench (at_ gm 2 [] []) = 3) ∧
      (∃ g₂, Move g₁ g₂ ∧ g₂.opp.bench = [] ∧ g₂.opp.active = some (at_ gm 2 [] []) ∧
        g₂.hpOf .opp .active (at_ gm 2 [] []) = 3) := by
  have m1 : Move m0 _ :=
    .attack (atk := hit2) rfl (.head _) (.nil _) rfl rfl rfl rfl m0_settled
      (.seq (.counters 2 rfl) (.benchCounters (b₁ := []) .opp 2 rfl)) rfl (fun h => nomatch h) rfl
  exact ⟨_, m1, rfl, rfl, by decide, by decide, not_damageBounded_of_dbB (by decide),
    ⟨_, .knockOut rfl (by decide) rfl, rfl, rfl, by decide⟩,
    ⟨_, .knockOutBench (b₁ := []) (b₂ := []) rfl (by decide) rfl, rfl, rfl, by decide⟩⟩

end Pokemon.StaticWitness
