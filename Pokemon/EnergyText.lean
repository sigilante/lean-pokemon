import Pokemon.Units
import Pokemon.TriggerWitness

/-!
# Special Energy with a payload (milestone MV8, stage 2)

Survey S22. A Special Energy card carries a payload (`EnergyText`) whose `grant` is a `ToolGrant`:
the holder filter, static effects in force while the card is attached, and triggered Abilities the
holder has. The Tool path reads it unchanged: `Card.grantStatics`, `Card.grantAbilities` and
`Card.grantAttacks` have a case for it, and `SView.statics`, `InPlay.abilities` and `InPlay.attacks`
read the holder's attached Energy cards as they read its Tools. Since a Pokémon may hold several
Energy cards, several payloads are in force at once, each card's (they add up; no card of the pool
says otherwise). Since everything is read from the attached cards, which both clamps keep, no clamp
theorem changed; the HP bound `hpBound` sums the HP gains of every card of the game, Special Energy
included (`Card.statics`), so `GameState.hpOf_le_hpBound` holds as before. `SEff.noRetreat` is the
one new static effect: "has no Retreat Cost", a set applied last in `GameState.retreatOf`.

Expressible with this file's terms (imported since importer 0.15.0, with the caveats survey S11 lists), each witnessed below from a `Settled` start:
Growing Grass Energy (me3-86), Voltaic Lightning Energy (me5-84), Magnetic Metal Energy (me4-85),
Spiky Energy (sv9-159). A Special Energy card is `Card.inert` exactly when its payload says a rider
is not modelled (`EnergyText.rest`) or models nothing (no static effect, Ability or attack granted,
no alternative provision, no holder restriction: `Card.inert_special`); a grant's holder filter alone
is not content (`Card.inert_holderOnly`). Other cards are non-inert too (a Pokémon card, a Basic
Energy card, a Stadium or Tool with an effect), so the theorem characterises Special Energy cards only.
-/

namespace Pokemon

/-- **A Special Energy card is inert exactly when its payload says a rider is not modelled, or
models nothing** (milestone MV8): no static effect, Ability or attack granted, no alternative
provision and no holder restriction. -/
theorem Card.inert_special (n : String) (p : List (List EType)) (x : EnergyText) :
    (Card.energy (.special n p x)).inert = true ↔
      x.rest = true ∨ (x.grant.statics = [] ∧ x.grant.abilities = [] ∧ x.grant.attacks = [] ∧
        x.alt = none ∧ x.only = .any) := by
  simp only [Card.inert, EnergyText.content, Bool.or_eq_true, Bool.not_eq_true',
    Bool.or_eq_false_iff, Bool.not_eq_false', List.isEmpty_iff, Option.isSome_eq_false_iff,
    Option.isNone_iff_eq_none, bne_eq_false_iff_eq, and_assoc]

/-- **A payload that only sets the grant's holder filter is inert**: it models nothing. -/
theorem Card.inert_holderOnly (n : String) (p : List (List EType)) (f : Filter) :
    (Card.energy (.special n p { grant := { ToolGrant.none with holder := f } })).inert = true :=
  (Card.inert_special _ _ _).2 (.inr ⟨rfl, rfl, rfl, rfl, rfl⟩)

/-- **A payload that says a rider is not modelled is inert**, whatever else it models. -/
theorem Card.inert_rest (n : String) (p : List (List EType)) {x : EnergyText} (h : x.rest = true) :
    (Card.energy (.special n p x)).inert = true :=
  (Card.inert_special _ _ _).2 (.inl h)

namespace EnergyText

open Trainer

/-- A static effect on the holder ("the … Pokémon this card is attached to"). -/
def onHolder (e : SEff) : Static := ⟨.self, .any, none, none, none, e⟩

/-- Growing Grass Energy (me3-86): "As long as this card is attached to a Pokémon, it provides Grass
Energy. The Grass Pokémon this card is attached to gets +20 HP." -/
def growingGrass : Card := .energy <| .special "Growing Grass Energy" [[.grass]]
  { grant := { holder := .ptype .grass, attacks := [], abilities := [],
               statics := [onHolder (.hpPlus (.const 2))] } }

/-- Voltaic Lightning Energy (me5-84): "… it provides Lightning Energy. Attacks used by the Lightning
Pokémon this card is attached to do 20 more damage to your opponent's Active Pokémon (before
applying Weakness and Resistance)." -/
def voltaic : Card := .energy <| .special "Voltaic Lightning Energy" [[.lightning]]
  { grant := { holder := .ptype .lightning, attacks := [], abilities := [],
               statics := [onHolder (.bonus 2 .any)] } }

/-- Magnetic Metal Energy (me4-85): "… it provides Metal Energy. The Metal Pokémon this card is
attached to has no Retreat Cost." -/
def magnetic : Card := .energy <| .special "Magnetic Metal Energy" [[.metal]]
  { grant := { holder := .ptype .metal, attacks := [], abilities := [],
               statics := [onHolder .noRetreat] } }

/-- Spiky Energy's trigger: "If the Pokémon this card is attached to is in the Active Spot and is
damaged by an attack from your opponent's Pokémon (even if this Pokémon is Knocked Out), put 2
damage counters on the Attacking Pokémon." -/
def spikyAb : Ability := ⟨"Spiky Energy", .triggered .damaged false, some .active, none,
  .fx (.counters 2)⟩

/-- Spiky Energy (sv9-159): "… it provides Colorless Energy." and `spikyAb`. -/
def spikyE : Card := .energy <| .special "Spiky Energy" [[.colorless]]
  { grant := { holder := .any, attacks := [], abilities := [spikyAb] } }

theorem not_inert : growingGrass.inert = false ∧ voltaic.inert = false ∧ magnetic.inert = false ∧
    spikyE.inert = false := by decide

/-- A Grass, a Lightning and a Metal Basic Pokémon (100 HP, Retreat Cost 2) and a Psychic one. -/
def grassMon : PokemonCard := ⟨"Leafy", .basic, none, 10, .grass, [TriggerWitness.strike], 2, none,
  none, .none, false, []⟩
def boltMon : PokemonCard := ⟨"Volty", .basic, none, 10, .lightning, [TriggerWitness.strike], 2,
  none, none, .none, false, []⟩
def metalMon : PokemonCard := ⟨"Steely", .basic, none, 10, .metal, [TriggerWitness.strike], 2, none,
  none, .none, false, []⟩
def psyMon : PokemonCard := ⟨"Psy", .basic, none, 10, .psychic, [TriggerWitness.strike], 2, none,
  none, .none, false, []⟩

/-- The player to move has `p` Active with the Energy `e` attached and `big` on the Bench, and the
card `h` in hand; the opponent has `big`. -/
def st (p : PokemonCard) (e : List Card) (h : List Card) : GameState :=
  ⟨side h [.energy .fire] { InPlay.ofBasic p with energy := e } [InPlay.ofBasic big],
    side [] [.energy .fire] (InPlay.ofBasic big) [], true, false, false, false, none, none, false,
    false, false⟩

/-- The HP of the player's Active Pokémon. -/
def hpA (g : GameState) : Nat := match g.cur.active with
  | some a => g.hpOf .own .active a
  | none => 0

/-- **Growing Grass Energy**: +20 HP on a Grass holder, +40 with two (each card's effect applies),
nothing on a Psychic holder, and nothing once the card is gone. -/
theorem growingGrass_hp :
    hpA (st grassMon [growingGrass] []) = 12 ∧ hpA (st grassMon [growingGrass, growingGrass] []) = 14 ∧
      hpA (st psyMon [growingGrass] []) = 10 ∧ hpA (st grassMon [] []) = 10 := by decide

/-- **Witness: the turn's attachment of Growing Grass Energy raises the holder's HP**, and the card
pays a Grass symbol. -/
theorem attach_growingGrass : ∃ g a, Move (st grassMon [] [growingGrass]) g ∧ g.cur.active = some a ∧
    g.hpOf .own .active a = 12 ∧ Pays [.grass] a.units :=
  ⟨_, _, .attach (l₁ := []) (l₂ := []) rfl rfl rfl rfl ((GameState.settled_iff _).2 (by decide)) rfl rfl,
    rfl, by decide, by decide⟩

/-- **The HP bonus stops when the card leaves**: "discard an Energy from your Active Pokémon" takes
Growing Grass Energy off, and the HP is the printed HP again. -/
theorem growingGrass_leaves : ∃ g, Run (.discardEnergy .own .active .energy (.exactly 1))
    (st grassMon [growingGrass] []) g ∧ hpA g = 10 :=
  ⟨_, .zone rfl (.discardActive rfl (.take rfl .nil) (show retreatPaid 1 _ = true by decide)),
    by decide⟩

/-- **Voltaic Lightning Energy**: a Lightning attacker's 50 does 70; a Psychic attacker's does 50. -/
theorem voltaic_bonus : (st boltMon [voltaic] []).dealt 5 = 7 ∧ (st psyMon [voltaic] []).dealt 5 = 5 ∧
    (st boltMon [voltaic, voltaic] []).dealt 5 = 9 := by decide

/-- **Magnetic Metal Energy**: a Metal holder has no Retreat Cost; a Psychic holder keeps its 2. -/
theorem magnetic_retreat :
    (st metalMon [magnetic] []).retreatOf { InPlay.ofBasic metalMon with energy := [magnetic] } = 0 ∧
    (st psyMon [magnetic] []).retreatOf { InPlay.ofBasic psyMon with energy := [magnetic] } = 2 := by
  decide

/-- **Witness: a Metal Pokémon with Magnetic Metal Energy retreats discarding nothing**, and keeps
the card. -/
theorem magnetic_free_retreat : ∃ g', Move (st metalMon [magnetic] []) g' ∧ g'.cur.discard = [] ∧
    g'.cur.bench.map InPlay.energy = [[magnetic]] :=
  ⟨_, .retreat (b₁ := []) (b₂ := []) (paid := []) rfl rfl rfl (Split.keepAll _ _) (by decide) rfl rfl
    ((GameState.settled_iff _).2 (by decide)) rfl rfl, rfl, rfl⟩

/-- The player to move has `striker` (30 HP, attack for 50) Active; the opponent has `big` (100 HP)
Active with Spiky Energy attached. -/
def spStart : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic TriggerWitness.striker) [InPlay.ofBasic big],
    side [] [.energy .fire] { InPlay.ofBasic big with energy := [spikyE] } [InPlay.ofBasic big],
    true, false, false, false, none, none, false, false, false⟩

/-- **Witness: Spiky Energy's trigger fires**: the attack does 50 to its holder, and the attacker
gets 2 damage counters. -/
theorem spiky_fires : ∃ g', Move spStart g' ∧ g'.cur.active.map InPlay.damage = some 2 ∧
    g'.opp.active.map InPlay.damage = some 5 :=
  ⟨_, Move.attack (hlk := rfl) (atk := TriggerWitness.strike) rfl (.head _) (.nil _) rfl rfl rfl rfl
      ((GameState.settled_iff _).2 (by decide)) (.seq (.damage (.const 5 _) rfl) (.skip _)) rfl
      (fun h => nomatch h) rfl (l := [spikyAb])
      (.fire (.seq (.hit (b := true) rfl (.damage (.const 5 _) rfl) rfl (fun _ => rfl))
        (.plain rfl (.skip _))) (.refl _))
      (.run rfl (.counters 2 rfl) (.nil _)), rfl, rfl⟩

end EnergyText

end Pokemon
