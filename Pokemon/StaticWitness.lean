import Pokemon.Tools

/-!
# Static effects: witnesses (milestone M6)

HP is derived from the state (`GameState.hpOf`): printed HP changed by the static effects in force.
These witnesses are single states or short lines of play from hand-built, well-formed starts; every
state is closed, so derived HP is computed by `decide` (through `GameState.dbB`).

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
  first raises its HP in mid-effect, so the counters do not Knock it Out, whereas the same counters
  without the attachment do.
* `chain_knock_out`: one Stadium replacement Knocks Out a Benched Pokémon whose static Ability gave
  another Benched Pokémon +30 HP; that Knock Out leaves the second Pokémon at or above its HP, and
  it is Knocked Out next: two Knock Outs from one removal.
* `reduction_after_weakness`: a static reduction of 20 (Tool) on a defender weak to the attacker:
  base damage 30 is doubled by Weakness (step 3) and then reduced (step 5), 60 − 20 = 40, not
  (30 − 20) × 2 = 20.
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

/-- After the Item with the attachment: 5 counters, HP 3 + 2 × 2 = 7. -/
def eg1 : GameState :=
  gs (⟨[mt], [], [charge], [mt, mt], [], some (at_ bulky 5 [mt, mt] []), [], false, false, false,
      false, false, Store.empty, true⟩)
    (pl [] [mt, mt] (at_ big 0 [] []) []) none

/-- **Attaching raises HP in mid-effect** (milestone M6): the Active Pokémon has printed HP 3 and
a static Ability "+20 HP per Energy attached", one Energy and 3 damage counters (HP 5). The Item
attaches a second Energy (HP 7), then puts 2 counters on it: 5 < 7, it survives (`eg1` is
`Settled`). Had the counters come first (HP 5, damage 5) it would have been Knocked Out; and
without the attachment (the model allows attaching nothing) the Knock Out is taken. -/
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

/-- **A static reduction is applied at step 5, after Weakness** (milestone M6; rulebook 2023
p. 20): base damage 3 counters against a defender weak to the attacker and holding `scale` (20
less damage): (3 × 2) − 2 = 4 counters, not (3 − 2) × 2 = 2. -/
theorem reduction_after_weakness : wg.sReduce = 2 ∧ wg.weak = true ∧ wg.dealt 3 = 4 :=
  ⟨by decide, by decide, by decide⟩

end Pokemon.StaticWitness
