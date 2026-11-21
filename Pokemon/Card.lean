/-!
# Cards

Static card data. HP and damage are measured in damage counters (one counter = 10 HP),
so every quantity in the model is a natural number of physical objects.

Card text is represented by `Effect`, a small language of primitive operations. The
language is the boundary of the model: a theorem proved here speaks about decks whose
card texts are expressible in `Effect`, and about no others.
-/

namespace Pokemon

inductive EType where
  | grass | fire | water | lightning | psychic | fighting
  | darkness | metal | fairy | dragon | colorless
  deriving DecidableEq

/-- The nine types of Basic Energy card: "A Grass, Fire, Water, Lightning, Psychic, Fighting,
Darkness, Metal or Fairy Energy card" (rulebook 2023, glossary p. 39). There is no Basic
Colorless or Dragon Energy. Special Energy cards are absent from the model. -/
inductive BasicEnergy where
  | grass | fire | water | lightning | psychic | fighting | darkness | metal | fairy
  deriving DecidableEq

/-- The type of Energy a Basic Energy card provides. -/
def BasicEnergy.type : BasicEnergy → EType
  | .grass => .grass
  | .fire => .fire
  | .water => .water
  | .lightning => .lightning
  | .psychic => .psychic
  | .fighting => .fighting
  | .darkness => .darkness
  | .metal => .metal
  | .fairy => .fairy

/-! ## Energy and attack costs -/

/-- Can a unit of Energy that counts as any of the types `u` pay the cost symbol `s`? A
Colorless symbol is paid by any Energy; a typed symbol only by Energy of that type: "the ◉ means
you need to have 1 ◉ Energy attached. However, the ✱ means that any type of Energy can be used"
(rulebook 2023, p. 13, Quaxwell's Spiral Kick). -/
def EType.paidBy (s : EType) (u : List EType) : Bool :=
  decide (s = .colorless) || decide (s ∈ u)

/-- `Pays cost units`: the symbols of an attack cost can be paid by distinct units of the
attached Energy, a typed symbol by a unit of that type and a Colorless symbol by any unit
(`EType.paidBy`). Each unit is listed by the types it counts as (`Card.provides`); with Basic
Energy only, every unit is one type. This is a matching problem, not a count: `[fire, fire]` is
not paid by one Fire and one Water Energy, although two Energy are attached. -/
inductive Pays : List EType → List (List EType) → Prop where
  | nil (us : List (List EType)) : Pays [] us
  | cons {s : EType} {cs : List EType} {u : List EType} {us₁ us₂ : List (List EType)}
      (hu : s.paidBy u = true) (h : Pays cs (us₁ ++ us₂)) : Pays (s :: cs) (us₁ ++ u :: us₂)

/-- Every way to take one element out of a list: the element and the rest, in order. -/
def pick {α : Type} : List α → List (α × List α)
  | [] => []
  | x :: xs => (x, xs) :: (pick xs).map fun yr => (yr.1, x :: yr.2)

theorem mem_pick {α : Type} {y : α} {r : List α} : ∀ {l : List α},
    (y, r) ∈ pick l ↔ ∃ l₁ l₂, l = l₁ ++ y :: l₂ ∧ r = l₁ ++ l₂
  | [] => by simp [pick]
  | x :: xs => by
      simp only [pick, List.mem_cons, Prod.mk.injEq, List.mem_map]
      constructor
      · intro h
        rcases h with ⟨h1, h2⟩ | ⟨⟨y', r'⟩, hm, he⟩
        · exact ⟨[], xs, by rw [h1]; rfl, h2⟩
        · obtain ⟨h1, h2⟩ := he
          subst h1; subst h2
          obtain ⟨l₁, l₂, h3, h4⟩ := (mem_pick (l := xs)).1 hm
          subst h3; subst h4
          exact ⟨x :: l₁, l₂, rfl, rfl⟩
      · intro h
        obtain ⟨l₁, l₂, he, hr⟩ := h
        subst hr
        cases l₁ with
        | nil =>
            simp only [List.nil_append, List.cons.injEq] at he
            obtain ⟨h1, h2⟩ := he
            subst h1; subst h2
            exact .inl ⟨rfl, rfl⟩
        | cons z l₁ =>
            simp only [List.cons_append, List.cons.injEq] at he
            obtain ⟨h1, h2⟩ := he
            subst h1; subst h2
            exact .inr ⟨(y, l₁ ++ l₂), (mem_pick (l := l₁ ++ y :: l₂)).2 ⟨l₁, l₂, rfl, rfl⟩,
              rfl, rfl⟩

/-- A decision procedure for `Pays`: try every unit for the first symbol (`payable_iff`). -/
def payable : List EType → List (List EType) → Bool
  | [], _ => true
  | s :: cs, us => (pick us).any fun ur => s.paidBy ur.1 && payable cs ur.2

theorem payable_iff : ∀ {cs : List EType} {us : List (List EType)},
    payable cs us = true ↔ Pays cs us
  | [], us => by simp only [payable, true_iff]; exact .nil us
  | s :: cs, us => by
      simp only [payable, List.any_eq_true, Bool.and_eq_true]
      constructor
      · rintro ⟨⟨u, r⟩, hm, hu, hr⟩
        obtain ⟨l₁, l₂, rfl, rfl⟩ := mem_pick.1 hm
        exact .cons hu (payable_iff.1 hr)
      · intro h
        cases h with
        | @cons _ _ u us₁ us₂ hu h =>
            exact ⟨(u, us₁ ++ us₂), mem_pick.2 ⟨us₁, us₂, rfl, rfl⟩, hu, payable_iff.2 h⟩

instance (cs : List EType) (us : List (List EType)) : Decidable (Pays cs us) :=
  decidable_of_iff _ payable_iff

/-- A cost can be paid only if at least as many units are attached: typed costs are stricter
than the count of Energy the model checked before. -/
theorem Pays.length_le {cs : List EType} {us : List (List EType)} (h : Pays cs us) :
    cs.length ≤ us.length := by
  induction h with
  | nil => exact Nat.zero_le _
  | cons _ _ ih => simp only [List.length_cons, List.length_append] at ih ⊢; omega

/-- More Energy never hurts: a cost paid by `us` is paid by `u :: us`. -/
theorem Pays.cons_unit {cs : List EType} {us : List (List EType)} (h : Pays cs us)
    (u : List EType) : Pays cs (u :: us) := by
  induction h with
  | nil => exact .nil _
  | @cons s cs u' us₁ us₂ hu _ ih => exact .cons (us₁ := u :: us₁) hu ih

/-- A cost of Colorless symbols only is paid exactly when enough units are attached: for such
costs the typed rule and the old count agree. -/
theorem Pays.colorless_iff {cs : List EType} {us : List (List EType)}
    (hc : ∀ s ∈ cs, s = .colorless) : Pays cs us ↔ cs.length ≤ us.length := by
  refine ⟨Pays.length_le, fun hl => ?_⟩
  induction cs generalizing us with
  | nil => exact .nil _
  | cons s cs ih =>
      cases us with
      | nil => simp at hl
      | cons u us =>
          have hs := hc s (.head _)
          have := ih (fun t ht => hc t (.tail _ ht)) (us := us)
            (by simp only [List.length_cons] at hl; omega)
          exact .cons (us₁ := []) (by simp [EType.paidBy, hs]) this

/-- A typed symbol needs a unit of its type. -/
theorem Pays.typed {s : EType} {cs : List EType} {us : List (List EType)}
    (h : Pays (s :: cs) us) (hs : s ≠ .colorless) : ∃ u ∈ us, s ∈ u := by
  cases h with
  | @cons _ _ u us₁ us₂ hu _ =>
      refine ⟨u, List.mem_append_right _ (.head _), ?_⟩
      simpa [EType.paidBy, hs] using hu

/-- Two Energy are not enough for `[fire, fire]` if one is Water. -/
theorem pays_fire_fire : ¬ Pays [.fire, .fire] [[.fire], [.water]] := by decide

/-- Quaxwell's Spiral Kick (◉✱✱, rulebook 2023 p. 13) is paid by a Water, a Fire and a Grass
Energy, but not by three Fire Energy. -/
theorem pays_spiral_kick :
    Pays [.water, .colorless, .colorless] [[.fire], [.water], [.grass]] ∧
      ¬ Pays [.water, .colorless, .colorless] [[.fire], [.fire], [.fire]] := by decide

inductive Stage where
  | basic | stage1 | stage2
  deriving DecidableEq

/-- The five Special Conditions an effect can apply. Asleep, Confused and Paralyzed rotate the
card, so a new one of these replaces the old; Poisoned and Burned are markers beside them. -/
inductive Condition where
  | poisoned | burned | asleep | confused | paralyzed
  deriving DecidableEq

/-- Whose Active Pokémon an effect reads: the player's own, or the opponent's. -/
inductive Whose where
  | own | opp
  deriving DecidableEq

/-- The named Boolean markers a Pokémon in play can carry (`survey/S7-load-bearing-spec.md`
§3.1): Imprison and Shock-wave (Gardevoir ex δ ex15-93, Tyranitar ex δ ex15-99; removed by
Tropius δ ex15-23), Lightning Rod (Electabuzz basep-46) and Char (Quilava neo1-47). The
Coloring counter (Smeargle basep-32) carries a type and is a separate field
(`Marks.coloring`). -/
inductive Marker where
  | imprison | shockwave | lightningRod | char
  deriving DecidableEq

/-- When a lingering modifier is in effect, counted in turns from the current one (either
player's): this turn, the next turn (the opponent's), the turn after (the player's next turn),
or every turn for the rest of the game. "Until the end of your opponent's next turn" is `now`
and `next` together. -/
inductive Slot where
  | now | next | after | always
  deriving DecidableEq

/-- What a lock forbids its player to do. -/
inductive Lock where
  | attack | retreat | item
  deriving DecidableEq

/-- A lingering modifier on one player (`survey/S7-load-bearing-spec.md` §4). -/
inductive Mod where
  /-- the player's attacks do `n` more damage (PlusPower, "this attack does 30 more damage
  during your next turn"); repeated uses add up -/
  | bonus (n : Nat)
  /-- damage done to the player's Pokémon by attacks is reduced by `n` (Iron Defender, "during
  your opponent's next turn, any damage done to this Pokémon is reduced by 30"); repeated uses
  add up -/
  | reduce (n : Nat)
  /-- prevent all damage done to the player's Pokémon by attacks -/
  | prevent
  /-- the player cannot attack, retreat, or play Item cards -/
  | lock (l : Lock)
  deriving DecidableEq

/-- A test an effect can make on one Active Pokémon. -/
inductive Test where
  /-- it has at least `n` damage counters ("if it has any damage counters" is `atLeast w 1`;
  "if it has no damage counters" is the `else` branch of that test) -/
  | atLeast (w : Whose) (n : Nat)
  /-- it has exactly `n` damage counters (Mega Absol ex, me1-86) -/
  | exactly (w : Whose) (n : Nat)
  /-- it is affected by the Special Condition `c` -/
  | cond (w : Whose) (c : Condition)
  /-- it has the marker `m` ("any Pokémon that has any Imprison markers on it", "that has any
  Shock-wave markers on it", "with a Lightning Rod marker on it") -/
  | marked (w : Whose) (m : Marker)
  /-- its type is `t`: the type of its top card, or the type its Coloring counter set -/
  | isType (w : Whose) (t : EType)
  deriving DecidableEq

/-- Primitive card effects. `choice` covers both coin flips and player decisions;
`iter` covers "flip until tails" and "as often as you like". -/
inductive Effect where
  /-- do nothing -/
  | skip
  /-- the player to move draws one card (no-op on an empty deck) -/
  | draw
  /-- remove up to `n` damage counters from the player's Active Pokémon -/
  | heal (n : Nat)
  /-- place `n` damage counters on the opponent's Active Pokémon -/
  | counters (n : Nat)
  /-- apply a Special Condition to the opponent's Active Pokémon -/
  | inflict (c : Condition)
  /-- if the opponent's Active Pokémon is Poisoned, it takes `n` more damage counters from
  Poison at every Pokémon Checkup; repeated uses add up (Croagunk STS 58, *Poison Up*: "This
  effect can be applied more than once"). It does not Poison: it raises the strength of the
  Poison already there, which lasts until Poison ends or a new Poison replaces it
  (`InPlay.inflict` resets it) -/
  | poisonUp (n : Nat)
  /-- the player's Active Pokémon recovers from all Special Conditions (Full Heal) -/
  | cure
  /-- shuffle the player's deck -/
  | shuffle
  /-- move one chosen card from the player's deck to their hand -/
  | search
  /-- put the player's hand on the bottom of their deck in a chosen order -/
  | handToBottom
  /-- if the test holds then `a` else `b` -/
  | ite (t : Test) (a b : Effect)
  /-- place `k` damage counters on the opponent's Active Pokémon for each damage counter on
  the `w` Active Pokémon (`k · d` counters in all; with `w = opp` and `k = 1` this doubles
  the damage on the opponent's Active Pokémon, as Lunala cel25-15 does) -/
  | scale (w : Whose) (k : Nat)
  /-- place `n` damage counters on the player's own Active Pokémon -/
  | selfDamage (n : Nat)
  /-- remove all damage counters from the player's own Active Pokémon -/
  | healAll
  /-- put the marker `m` on one of the `w` player's Pokémon in play, Active or Benched (the
  player chooses). A Pokémon has the marker or not: placing it again changes nothing. -/
  | mark (w : Whose) (m : Marker)
  /-- remove every `m` marker from all of the `w` player's Pokémon in play (Tropius δ) -/
  | unmark (w : Whose) (m : Marker)
  /-- put a Coloring counter for type `t` on one of the `w` player's Pokémon in play, replacing
  any earlier one: that Pokémon is now of type `t` (Smeargle basep-32, *Paint*) -/
  | color (w : Whose) (t : EType)
  /-- the `w` player gets the lingering modifier `m` for the turns `s` -/
  | linger (w : Whose) (s : Slot) (m : Mod)
  /-- the attack does `n` damage to the opponent's Active Pokémon, `n` being its base damage as
  printed or as the attack's text computes it: nothing if `n = 0` (the rulebook's "Stop if the
  base damage is 0"), else `n` plus the player's damage bonus, minus the opponent's damage
  reduction, or nothing if the opponent has damage prevention (`GameState.dealt`, `dealtBy`).
  `Move.attack` does the printed base damage (`Attack.damage`) this way; an effect may do more
  `damage` (an attack whose text sets or adds to its damage) -/
  | damage (n : Nat)
  /-- as `damage n`, and heal the player's Active Pokémon by the damage done ("heal from this
  Pokémon the same amount of damage you did to your opponent's Active Pokémon") -/
  | drain (n : Nat)
  | seq (a b : Effect)
  | choice (a b : Effect)
  | iter (a : Effect)
  deriving DecidableEq

structure Attack where
  name : String
  cost : List EType
  /-- base damage, in counters (0 for an attack printed with no damage, or whose damage the
  text computes; that damage is then an `Effect.damage` in the effect) -/
  damage : Nat
  effect : Effect
  /-- a GX attack: each player can use at most one GX attack in a game (`PlayerState.gxUsed`;
  "You can't use more than 1 GX attack in a game") -/
  gx : Bool
  deriving DecidableEq

structure PokemonCard where
  name : String
  stage : Stage
  evolvesFrom : Option String
  /-- printed HP, in counters -/
  hp : Nat
  type : EType
  attacks : List Attack
  /-- retreat cost, in Energy cards -/
  retreat : Nat
  /-- Weakness, as printed today: attacks from Pokémon of this type do double damage to it
  ("Spriggatito's Weakness of ×2 to ◉ Pokémon makes that 10 ×2 = 20 damage", rulebook 2023
  p. 14; ×2 on every Standard Pokémon with a Weakness, survey S9). Older forms are out of scope:
  "+10" to "+40" Weakness (1,119 older card records in the data), and two Weaknesses on one card (38 records). -/
  weakness : Option EType
  /-- Resistance: attacks from Pokémon of the type do this much less damage, in counters (−30
  is 3, −20 is 2; "It takes less damage from a Pokémon if it has Resistance to that Pokémon's
  type", p. 14). Two Resistances on one card (54 older records) are out of scope. -/
  resistance : Option (EType × Nat)
  deriving DecidableEq

/-- Is this Pokémon weak to Pokémon of type `t`? -/
def PokemonCard.weakTo (d : PokemonCard) (t : EType) : Bool := decide (d.weakness = some t)

/-- The Resistance this Pokémon has to Pokémon of type `t`, in counters (0 if none). -/
def PokemonCard.resistTo (d : PokemonCard) (t : EType) : Nat :=
  match d.resistance with
  | some (u, r) => if u = t then r else 0
  | none => 0

/-- The printed Resistance amount, whatever the type (0 if none). -/
def PokemonCard.resistAmt (d : PokemonCard) : Nat :=
  match d.resistance with
  | some (_, r) => r
  | none => 0

theorem PokemonCard.resistTo_le (d : PokemonCard) (t : EType) : d.resistTo t ≤ d.resistAmt := by
  unfold resistTo resistAmt
  split
  · split <;> omega
  · exact Nat.le_refl _

inductive TrainerKind where
  | item | supporter | stadium | tool
  deriving DecidableEq

inductive Card where
  | pokemon (p : PokemonCard)
  /-- a Basic Energy card (`BasicEnergy`: nine types, no Colorless or Dragon) -/
  | energy (t : BasicEnergy)
  | trainer (name : String) (kind : TrainerKind) (effect : Effect)
  deriving DecidableEq

/-- The Energy a card attached to a Pokémon provides, one entry per unit, each entry the types
that unit counts as. A Basic Energy card provides one unit of its type. Special Energy cards
(several units, as "provides 2 Colorless Energy", or one unit of several types, as "provides
every type of Energy but only 1 Energy at a time") are not in the model; each would be one more
clause here, and `Pays` already matches units of several types. Other cards provide nothing. -/
def Card.provides : Card → List (List EType)
  | .energy t => [[t.type]]
  | _ => []

/-- The constant a test compares damage with (0 for the tests that do not read damage). -/
def Test.bound : Test → Nat
  | .atLeast _ n => n
  | .exactly _ n => n
  | _ => 0

/-- The largest constant an effect's tests compare damage with. -/
def Effect.tmax : Effect → Nat
  | .ite t a b => max t.bound (max a.tmax b.tmax)
  | .seq a b => max a.tmax b.tmax
  | .choice a b => max a.tmax b.tmax
  | .iter a => a.tmax
  | _ => 0

/-- No damage reduction and no `drain`: the effects for which the damage bonus can be capped
(`Pokemon/Lingering.lean` shows that each of the two breaks the cap). -/
def Effect.tame : Effect → Bool
  | .linger _ _ (.reduce _) => false
  | .drain _ => false
  | .ite _ a b => a.tame && b.tame
  | .seq a b => a.tame && b.tame
  | .choice a b => a.tame && b.tame
  | .iter a => a.tame
  | _ => true

/-- The largest test constant over a list of attacks. -/
def attacksTmax : List Attack → Nat
  | [] => 0
  | a :: as => max a.effect.tmax (attacksTmax as)

def attacksTame : List Attack → Bool
  | [] => true
  | a :: as => a.effect.tame && attacksTame as

def Card.tmax : Card → Nat
  | .pokemon p => attacksTmax p.attacks
  | .energy _ => 0
  | .trainer _ _ e => e.tmax

def Card.tame : Card → Bool
  | .pokemon p => attacksTame p.attacks
  | .energy _ => true
  | .trainer _ _ e => e.tame

end Pokemon
