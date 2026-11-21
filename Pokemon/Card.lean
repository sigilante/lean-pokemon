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

/-- The amount of damage an attack's text computes, in counters: its base damage "as printed, or
as the attack text will tell you" when "an ×, –, or + is printed next to it" (rulebook 2023
p. 20, step 1), before any modifier. It is evaluated once, when the attack's damage is placed
(`Amt.Val`, `Effect.damage`). -/
inductive Amt where
  /-- a printed number -/
  | const (n : Nat)
  /-- `k` for each damage counter on the `w` Active Pokémon ("20 damage plus 10 more for each
  damage counter on your opponent's Active Pokémon" is `add (const 2) (per opp 1)`, Jynx
  base1-31) -/
  | per (w : Whose) (k : Nat)
  | add (a b : Amt)
  /-- `a` less `b`, at least 0 ("10 less damage for each damage counter on this Pokémon") -/
  | sub (a b : Amt)
  /-- the sum of any number of values of `a`: "Flip a coin until you get tails. This attack does
  30 damage for each heads" is `many (const 3)` -/
  | many (a : Amt)
  deriving DecidableEq

/-! ## Card filters and zone moves (milestone MV) -/

inductive TrainerKind where
  | item | supporter | stadium | tool
  deriving DecidableEq

/-- A card filter (milestone MV): the kind of card a zone move may pick ("a Basic Pokémon", "a
Supporter card", "a Basic Fire Energy card", "up to 2 Pokémon that don't have a Rule Box").
Evaluated by `Filter.eval`, a `Bool`, so every filter is decidable; a new printed kind is one more
constructor and one more clause of `Filter.eval`. Pokémon filters read the printed card (stage,
type, name, HP, rule box), not the Pokémon in play. With Basic Energy only (no Special Energy in
the model), "an Energy card" and "a Basic Energy card" are the same filter, `energy`. -/
inductive Filter where
  /-- any card ("a card", "cards") -/
  | any
  /-- a Pokémon card -/
  | pokemon
  /-- a Basic Pokémon card -/
  | basic
  /-- a Pokémon card of the given Stage -/
  | stage (s : Stage)
  /-- a Pokémon card of type `t` ("a Fire Pokémon") -/
  | ptype (t : EType)
  /-- a card with this name, Pokémon or Trainer ("Duskull", "Arven's Sandwich") -/
  | named (n : String)
  /-- a Pokémon card with printed HP at most `n` counters ("a Basic Pokémon with 70 HP or less" is
  `and basic (hpLe 7)`) -/
  | hpLe (n : Nat)
  /-- a Pokémon card without a rule box ("Pokémon that don't have a Rule Box") -/
  | noRuleBox
  /-- a Trainer card of any kind -/
  | trainer
  /-- a Trainer card of the given kind (Item, Supporter, Stadium, Pokémon Tool) -/
  | kind (k : TrainerKind)
  /-- an Energy card (in the model every Energy card is a Basic Energy card) -/
  | energy
  /-- a Basic Energy card of type `t` ("a Basic Fire Energy card") -/
  | energyOf (t : EType)
  | and (a b : Filter)
  | or (a b : Filter)
  | not (a : Filter)
  deriving DecidableEq

/-- Where a zone move takes its cards from, in the zones of one player: the deck (searched: any
cards of it), the top `n` cards of the deck ("look at the top 7 cards of your deck"; drawing and
milling take from here), or the hand. Milestone MV, stage 1: no source is the discard pile (the
recycling stage adds it). -/
inductive Src where
  | deck
  | top (n : Nat)
  | hand
  deriving DecidableEq

/-- Where a zone move puts the cards it takes: the hand, the discard pile, the top or the bottom
of the deck (in an order the player chooses), or shuffled into the deck. -/
inductive Dst where
  | hand | discard | top | bottom | shuffle
  deriving DecidableEq

/-- How many cards a zone move takes, among the cards of its source that pass its filter:
"up to `n`" (any number from 0 to `n`), exactly `n` (the move has no resolution if fewer can be
taken: "You can use this card only if you discard 2 other cards from your hand"; a continuation
after it in `seq` runs only if the cost was paid), or all of them ("discard all Energy from this
Pokémon"; drawing and milling are `all` from the top `n` cards). Today's rule (S8, PP26) reads "up
to X" as 0..X in attacks and 1..X in other effects; `upTo` allows 0 in both, a superset. -/
inductive Qty where
  | upTo (n : Nat)
  | exactly (n : Nat)
  | all
  deriving DecidableEq

/-- Which of a player's Pokémon in play an effect acts on: the Active Pokémon, or one Benched
Pokémon chosen when the effect resolves. "1 of your Pokémon" is a `choice` of the two. -/
inductive Spot where
  | active | bench
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
  /-- the attack's damage step: evaluate the amount `a` to a base damage `n` (`Amt.Val`) and do
  the damage the rulebook's calculation gives (`dealtBy`, rulebook 2023 p. 20: stop at base 0;
  the attacker's bonus; Weakness; Resistance; the defender's reduction and prevention) to the
  opponent's Active Pokémon. An attack has at most one damage step on each line of resolution
  (`Effect.oneHit`, required by `Move.attack`), so the calculation is made once per attack, and
  Item and Supporter effects have none (`Effect.hitFree`, required by `Move.item` and
  `Move.supporter`): printed Trainer cards place damage counters, not attack damage -/
  | damage (a : Amt)
  /-- as `damage a`, and heal the player's Active Pokémon by the damage done ("heal from this
  Pokémon the same amount of damage you did to your opponent's Active Pokémon") -/
  | drain (a : Amt)
  /-- place `n` damage counters on one of the `w` player's Benched Pokémon, chosen when the effect
  resolves ("Put 2 damage counters on 1 of your opponent's Benched Pokémon"); nothing if that
  player has no Benched Pokémon. Damage counters, not damage: no Weakness, Resistance or other
  modifier applies (rulebook 2023 p. 20, step 1). Milestone M3 -/
  | benchCounters (w : Whose) (n : Nat)
  /-- place `n` damage counters on each of the `w` player's Benched Pokémon -/
  | spreadCounters (w : Whose) (n : Nat)
  /-- remove up to `n` damage counters from one of the player's own Benched Pokémon, chosen when
  the effect resolves ("Heal 30 damage from 1 of your Benched Pokémon"); nothing if the player has
  no Benched Pokémon -/
  | benchHeal (n : Nat)
  /-- the `w` player's Active Pokémon switches with one of their Benched Pokémon, chosen when the
  effect resolves (`own`: "Switch your Active Pokémon with 1 of your Benched Pokémon", Switch;
  `opp`: "Switch in 1 of your opponent's Benched Pokémon to the Active Spot", Boss's Orders, or
  "your opponent switches their Active Pokémon with 1 of their Benched Pokémon"; the relation
  covers whoever chooses); nothing if that player has no Benched Pokémon. The Pokémon that goes
  to the Bench recovers from all Special Conditions (rulebook 2023 p. 12, p. 16). In an attack,
  nothing after `switch .own` may act on the player's Active Pokémon (`Effect.switchSafe`, part of
  `Attack.wf`): the attacker stays the attacker. Milestone M3 -/
  | switch (w : Whose)
  /-- attack damage `n` to one of the `w` player's Benched Pokémon, chosen when the effect
  resolves ("This attack also does 30 damage to 1 of your opponent's Benched Pokémon"); nothing if
  that player has no Benched Pokémon. Damage to a Benched Pokémon is not affected by Weakness or
  Resistance ("Don't apply Weakness and Resistance for Benched Pokémon!", rulebook 2023 p. 14);
  in the model no other modifier applies either: no bonus (a departure: the rulebook's example
  bonus, "this Pokémon's attacks do 40 more damage", p. 20, names no target), and no reduction
  or prevention (a departure the other way: the model's modifiers protect a player's Active
  Pokémon only; Known gaps), and a Tera Pokémon on the Bench takes none (`InPlay.hitBench`). The amount is a printed number. Not a damage step of the Active
  Pokémon (`hitFree`, `oneHit` ignore it); only attacks may use it (`benchHitFree`, required by
  `Move.item` and `Move.supporter`). Milestone M3 -/
  | benchDamage (w : Whose) (n : Nat)
  /-- attack damage `n` to each of the `w` player's Benched Pokémon ("This attack also does 10
  damage to each of your opponent's Benched Pokémon"; with `w = own`, "to each of your Benched
  Pokémon"), as `benchDamage` -/
  | spreadDamage (w : Whose) (n : Nat)
  /-- move cards between the `w` player's zones (milestone MV): take, from `src`, cards that pass
  the filter `f`, as many as `q` says, the rest of the source keeping its order, and put them at
  `dst`. "Search your deck for a Basic Pokémon, reveal it, and put it into your hand. Then, shuffle
  your deck" is `seq (move .own .deck .hand .basic (.upTo 1)) shuffle`; "discard 2 cards from your
  hand" is `move .own .hand .discard .any (.exactly 2)`; "draw 3 cards" is
  `move .own (.top 3) .hand .any .all`; "discard the top 2 cards of your opponent's deck" (mill) is
  `move .opp (.top 2) .discard .any .all`; "look at the top 6 cards of your deck and put a Supporter
  you find there into your hand" is `move .own (.top 6) .hand (.kind .supporter) (.upTo 1)` -/
  | move (w : Whose) (src : Src) (dst : Dst) (f : Filter) (q : Qty)
  /-- the `w` player draws cards until they have `n` cards in hand (none if they have `n` or more;
  fewer if the deck runs out) -/
  | drawTo (w : Whose) (n : Nat)
  /-- attach one Energy card that passes `f`, taken from `src`, to one of the `w` player's Pokémon
  at `sp` whose card passes `tf` ("Search your deck for a Basic Energy card and attach it to 1 of
  your Benched Pokémon"); or nothing (the model always allows attaching nothing, a superset of the
  printed "attach a … if you can"). "Up to 2" is two of these. Not the once-per-turn attachment
  from hand (`Move.attach`) -/
  | attach (w : Whose) (src : Src) (f : Filter) (sp : Spot) (tf : Filter)
  /-- put a Basic Pokémon card that passes `f`, taken from `src`, onto the `w` player's Bench, if
  it has room ("Search your deck for up to 2 Basic Pokémon and put them onto your Bench" is two of
  these, then `shuffle`); or nothing -/
  | putBench (w : Whose) (src : Src) (f : Filter)
  /-- discard Energy cards that pass `f` from one of the `w` player's Pokémon at `sp`, as many as
  `q` says ("Discard 2 Energy from this Pokémon" is `discardEnergy .own .active .energy
  (.exactly 2)`; "discard an Energy from your opponent's Active Pokémon",
  `discardEnergy .opp .active .energy (.upTo 1)`); they go to that player's discard pile. With
  `bench` and an empty Bench, nothing -/
  | discardEnergy (w : Whose) (sp : Spot) (f : Filter) (q : Qty)
  /-- move one Energy card that passes `f` from one of the `w` player's Pokémon in play to another
  ("Move an Energy from 1 of your Benched Pokémon to your Active Pokémon"); or nothing -/
  | moveEnergy (w : Whose) (f : Filter)
  | seq (a b : Effect)
  | choice (a b : Effect)
  | iter (a : Effect)
  deriving DecidableEq

structure Attack where
  name : String
  /-- the Energy symbols of the cost, paid by matching (`Pays`) -/
  cost : List EType
  /-- the printed base damage, in counters, when the text does not change it; 0 for an attack
  printed with no damage, or whose damage the text computes, which then places it with a
  damage step (`Effect.damage`, `Effect.drain`) in its effect (`Attack.script`) -/
  damage : Nat
  effect : Effect
  /-- a GX attack: each player can use at most one GX attack in a game (`PlayerState.gxUsed`;
  "You can't use more than 1 GX attack in a game") -/
  gx : Bool
  deriving DecidableEq

/-- No damage step (`damage` or `drain`) anywhere in the effect. -/
def Effect.hitFree : Effect → Bool
  | .damage _ => false
  | .drain _ => false
  | .ite _ a b => a.hitFree && b.hitFree
  | .seq a b => a.hitFree && b.hitFree
  | .choice a b => a.hitFree && b.hitFree
  | .iter a => a.hitFree
  | _ => true

/-- No attack damage to a Benched Pokémon anywhere in the effect (`benchDamage`,
`spreadDamage`): Item and Supporter effects must satisfy it, as they must `hitFree` (printed
Trainer cards place damage counters, not attack damage). -/
def Effect.benchHitFree : Effect → Bool
  | .benchDamage _ _ => false
  | .spreadDamage _ _ => false
  | .ite _ a b => a.benchHitFree && b.benchHitFree
  | .seq a b => a.benchHitFree && b.benchHitFree
  | .choice a b => a.benchHitFree && b.benchHitFree
  | .iter a => a.benchHitFree
  | _ => true

/-- At most one damage step on each line of resolution: the branches of `ite` and `choice` may
each have one, a `seq` may have one in either part but not both, and nothing under `iter` may
have one. So resolving the effect makes the damage calculation at most once. -/
def Effect.oneHit : Effect → Bool
  | .ite _ a b => a.oneHit && b.oneHit
  | .seq a b => (a.oneHit && b.hitFree) || (a.hitFree && b.oneHit)
  | .choice a b => a.oneHit && b.oneHit
  | .iter a => a.hitFree
  | _ => true

/-- The test reads the player's own Active Pokémon. -/
def Test.onOwn : Test → Bool
  | .atLeast .own _ | .exactly .own _ | .cond .own _ | .marked .own _ | .isType .own _ => true
  | _ => false

/-- The effect neither reads nor writes the player's own Active Pokémon: no `heal`, `cure`,
`selfDamage`, `healAll`, `scale .own`, `switch .own`, no test on the player's own Active Pokémon,
and no damage step (`damage` and `drain` read the attacker's type for Weakness and Resistance, and
their amount may read its damage; `drain` heals it). `mark .own` and `color .own` are allowed: they
may choose any of the player's Pokémon in play, Active or Benched. -/
def Effect.ownFree : Effect → Bool
  | .heal _ => false
  | .cure => false
  | .selfDamage _ => false
  | .healAll => false
  | .damage _ => false
  | .drain _ => false
  | .scale .own _ => false
  | .switch .own => false
  | .attach .own _ _ .active _ => false
  | .discardEnergy .own .active _ _ => false
  | .moveEnergy .own _ => false
  | .ite t a b => !t.onOwn && a.ownFree && b.ownFree
  | .seq a b => a.ownFree && b.ownFree
  | .choice a b => a.ownFree && b.ownFree
  | .iter a => a.ownFree
  | _ => true

/-- The effect may switch the player's own Active Pokémon (`switch .own` somewhere in it). -/
def Effect.switchesOwn : Effect → Bool
  | .switch .own => true
  | .ite _ a b => a.switchesOwn || b.switchesOwn
  | .seq a b => a.switchesOwn || b.switchesOwn
  | .choice a b => a.switchesOwn || b.switchesOwn
  | .iter a => a.switchesOwn
  | _ => false

/-- Nothing after a `switch .own` on the same line of resolution reads or writes the player's own
Active Pokémon (`ownFree`), and no `switch .own` is under `iter`. In the printed game the
attacking Pokémon stays "this Pokémon" for the whole attack, also after it has been switched to
the Bench; in the model the effects on the player's Active Pokémon act on whichever Pokémon is
Active, so an attack could otherwise switch first and then do damage of the new Active Pokémon's
type, or heal it. Printed attacks that switch the attacker out (132 distinct texts in the card
data, "Switch this Pokémon with 1 of your Benched Pokémon") do their damage first and switch
after it (rulebook 2023 p. 20, step F); what some of them do after the switch, to "this Pokémon"
on the Bench (attach Energy, evolve it, Return Charge sv8-68, Valiant Evolution sv3-60) or to the
opponent (switch, a lingering modifier), is not an effect on the player's Active Pokémon. -/
def Effect.switchSafe : Effect → Bool
  | .ite _ a b => a.switchSafe && b.switchSafe
  | .seq a b => a.switchSafe && b.switchSafe && (!a.switchesOwn || b.ownFree)
  | .choice a b => a.switchSafe && b.switchSafe
  | .iter a => a.switchSafe && !a.switchesOwn
  | _ => true

theorem Effect.switchSafe_of_switchesOwn : ∀ {e : Effect}, e.switchesOwn = false →
    e.switchSafe = true
  | .ite _ a b, h => by
      simp only [Effect.switchesOwn, Bool.or_eq_false_iff] at h
      simp only [Effect.switchSafe, switchSafe_of_switchesOwn h.1, switchSafe_of_switchesOwn h.2,
        Bool.and_self]
  | .seq a b, h => by
      simp only [Effect.switchesOwn, Bool.or_eq_false_iff] at h
      simp only [Effect.switchSafe, switchSafe_of_switchesOwn h.1, switchSafe_of_switchesOwn h.2,
        h.1, Bool.not_false, Bool.true_or, Bool.and_self]
  | .choice a b, h => by
      simp only [Effect.switchesOwn, Bool.or_eq_false_iff] at h
      simp only [Effect.switchSafe, switchSafe_of_switchesOwn h.1, switchSafe_of_switchesOwn h.2,
        Bool.and_self]
  | .iter a, h => by
      simp only [Effect.switchesOwn] at h
      simp only [Effect.switchSafe, switchSafe_of_switchesOwn h, h, Bool.not_false, Bool.and_self]
  | .skip, _ | .draw, _ | .heal _, _ | .counters _, _ | .inflict _, _ | .poisonUp _, _
  | .cure, _ | .shuffle, _ | .search, _ | .handToBottom, _ | .scale _ _, _
  | .selfDamage _, _ | .healAll, _ | .mark _ _, _ | .unmark _ _, _ | .color _ _, _
  | .linger _ _ _, _ | .benchCounters _ _, _ | .spreadCounters _ _, _ | .benchHeal _, _
  | .switch _, _ | .benchDamage _ _, _ | .spreadDamage _ _, _ | .damage _, _ | .drain _, _
  | .move _ _ _ _ _, _ | .drawTo _ _, _ | .attach _ _ _ _ _, _ | .putBench _ _ _, _
  | .discardEnergy _ _ _ _, _ | .moveEnergy _ _, _ => rfl

/-- What an attack resolves (rulebook 2023 p. 20, step F: "Apply any effects that happen before
damage, then place damage counters, and then do all other effects"). An attack with printed base
damage `n ≠ 0` and no damage step in its text does its damage first, then its effect. An attack
with base damage 0 resolves its effect, which places its damage, if any, with its own damage
step: this is how an attack writes damage computed by its text ("×", "+", "–"), damage that
depends on a coin flip or a choice made in the same effect, or effects before the damage. -/
def Attack.script (atk : Attack) : Effect :=
  if atk.damage = 0 then atk.effect else .seq (.damage (.const atk.damage)) atk.effect

/-- A well-formed attack: at most one damage step on each line of resolution, none in the
text when a printed base damage is done first, and nothing that reads or writes the player's own
Active Pokémon after a switch of it (`Effect.switchSafe`, so the attacker stays the attacker:
`Attack.attacker_at_hit`). `Move.attack` requires it. -/
def Attack.wf (atk : Attack) : Bool :=
  atk.effect.oneHit && (decide (atk.damage = 0) || atk.effect.hitFree) && atk.effect.switchSafe

theorem Effect.oneHit_of_hitFree : ∀ {e : Effect}, e.hitFree = true → e.oneHit = true
  | .damage _, h => by simp [Effect.hitFree] at h
  | .drain _, h => by simp [Effect.hitFree] at h
  | .ite _ a b, h => by
      simp only [Effect.hitFree, Bool.and_eq_true] at h
      simp only [Effect.oneHit, oneHit_of_hitFree h.1, oneHit_of_hitFree h.2, Bool.and_self]
  | .seq a b, h => by
      simp only [Effect.hitFree, Bool.and_eq_true] at h
      simp only [Effect.oneHit, oneHit_of_hitFree h.1, h.2, oneHit_of_hitFree h.2, h.1,
        Bool.and_self, Bool.or_self]
  | .choice a b, h => by
      simp only [Effect.hitFree, Bool.and_eq_true] at h
      simp only [Effect.oneHit, oneHit_of_hitFree h.1, oneHit_of_hitFree h.2, Bool.and_self]
  | .iter a, h => by simpa only [Effect.hitFree, Effect.oneHit] using h
  | .skip, _ | .draw, _ | .heal _, _ | .counters _, _ | .inflict _, _ | .poisonUp _, _
  | .cure, _ | .shuffle, _ | .search, _ | .handToBottom, _ | .scale _ _, _
  | .selfDamage _, _ | .healAll, _ | .mark _ _, _ | .unmark _ _, _ | .color _ _, _
  | .linger _ _ _, _ | .benchCounters _ _, _ | .spreadCounters _ _, _ | .benchHeal _, _
  | .switch _, _ | .benchDamage _ _, _ | .spreadDamage _ _, _
  | .move _ _ _ _ _, _ | .drawTo _ _, _ | .attach _ _ _ _ _, _ | .putBench _ _ _, _
  | .discardEnergy _ _ _ _, _ | .moveEnergy _ _, _ => rfl

theorem Effect.oneHit_seq_right {a b : Effect} (ha : a.hitFree = true) (hb : b.oneHit = true) :
    (Effect.seq a b).oneHit = true := by
  simp only [Effect.oneHit, ha, hb, Bool.and_self, Bool.or_true]

/-- **One damage calculation per attack**: the script of a well-formed attack has at most one
damage step on each line of resolution. -/
theorem Attack.script_oneHit {atk : Attack} (h : atk.wf = true) : atk.script.oneHit = true := by
  simp only [Attack.wf, Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq] at h
  replace h := h.1
  unfold Attack.script
  split
  · exact h.1
  · rcases h.2 with h0 | hf
    · contradiction
    · simp only [Effect.oneHit, Effect.hitFree, hf, Bool.and_self, Bool.true_or]

/-- The script of a well-formed attack is `switchSafe`: the printed base damage, if any, comes
before the effect and does not switch. -/
theorem Attack.script_switchSafe {atk : Attack} (h : atk.wf = true) :
    atk.script.switchSafe = true := by
  simp only [Attack.wf, Bool.and_eq_true] at h
  unfold Attack.script
  split
  · exact h.2
  · simp only [Effect.switchSafe, Effect.switchesOwn, h.2, Bool.not_false, Bool.true_or,
      Bool.and_self]

/-- The rule box of a Pokémon card, as far as it decides how many Prize cards its Knock Out gives
(milestone M3; survey S8 C3, S9). The kinds are those of today's Standard (regulation marks H, I,
J): no rule box (1 Prize, "take one of your Prize cards", rulebook 2023 p. 7); Pokémon ex, Tera
Pokémon ex included ("Like other Pokémon ex, when a Tera Pokémon ex is Knocked Out, your opponent
takes 2 Prize cards", p. 24; printed "Pokémon ex rule: When your Pokémon ex is Knocked Out, your
opponent takes 2 Prize cards."); and Mega Evolution Pokémon ex ("Mega Evolution ex Rule: When
your Mega Evolution Pokémon ex is Knocked Out, your opponent takes 3 Prize cards.", printed on the
cards; the 2023 rulebook predates them, S9). In the card data every Standard card with the MEGA
subtype is also ex, and 45 of its records print both rules; the Mega Evolution rule is the one
that gives the number. Older kinds (EX, GX, V, VSTAR: 2; VMAX, TAG TEAM, V-UNION: 3; Radiant:
1) give the same three numbers and are out of scope until the card pool needs them. -/
inductive RuleBox where
  | none | ex | megaEx
  deriving DecidableEq

/-- The number of Prize cards a Knock Out of a Pokémon with this rule box gives. -/
def RuleBox.prizes : RuleBox → Nat
  | .none => 1
  | .ex => 2
  | .megaEx => 3

theorem RuleBox.prizes_pos (r : RuleBox) : 0 < r.prizes := by cases r <;> decide

theorem RuleBox.prizes_le (r : RuleBox) : r.prizes ≤ 3 := by cases r <;> decide

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
  /-- the rule box, which gives the number of Prize cards its Knock Out gives
  (`PokemonCard.prizeCount`) -/
  ruleBox : RuleBox
  /-- a Tera Pokémon: "As long as this Pokémon is on your Bench, prevent all damage done to this
  Pokémon by attacks (both yours and your opponent's)" (printed on every Tera card; rulebook 2023
  p. 24: "a new effect that prevents all attack damage done to them while they're on your
  Bench"). In today's Standard every Tera Pokémon is a Pokémon ex (101 card records). -/
  tera : Bool
  deriving DecidableEq

/-- How many Prize cards the opponent takes when this Pokémon is Knocked Out (1, 2 or 3). -/
def PokemonCard.prizeCount (d : PokemonCard) : Nat := d.ruleBox.prizes

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

inductive Card where
  | pokemon (p : PokemonCard)
  /-- a Basic Energy card (`BasicEnergy`: nine types, no Colorless or Dragon) -/
  | energy (t : BasicEnergy)
  | trainer (name : String) (kind : TrainerKind) (effect : Effect)
  deriving DecidableEq

/-- Does the card pass the filter? -/
def Filter.eval : Filter → Card → Bool
  | .any, _ => true
  | .pokemon, .pokemon _ => true
  | .basic, .pokemon p => decide (p.stage = .basic)
  | .stage s, .pokemon p => decide (p.stage = s)
  | .ptype t, .pokemon p => decide (p.type = t)
  | .named n, .pokemon p => decide (p.name = n)
  | .named n, .trainer m _ _ => decide (m = n)
  | .hpLe n, .pokemon p => decide (p.hp ≤ n)
  | .noRuleBox, .pokemon p => decide (p.ruleBox = .none)
  | .trainer, .trainer _ _ _ => true
  | .kind k, .trainer _ k' _ => decide (k' = k)
  | .energy, .energy _ => true
  | .energyOf t, .energy e => decide (e.type = t)
  | .and a b, c => a.eval c && b.eval c
  | .or a b, c => a.eval c || b.eval c
  | .not a, c => !a.eval c
  | _, _ => false

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

/-- The script of an attack is tame when its effect is: the base damage adds no reduction and
no `drain`. -/
theorem Attack.script_tame (atk : Attack) : atk.script.tame = atk.effect.tame := by
  unfold Attack.script
  split
  · rfl
  · simp only [Effect.tame, Bool.true_and]

/-- The script of an attack has the test constants of its effect. -/
theorem Attack.script_tmax (atk : Attack) : atk.script.tmax = atk.effect.tmax := by
  unfold Attack.script
  split
  · rfl
  · simp only [Effect.tmax, Nat.zero_max]

def Card.tame : Card → Bool
  | .pokemon p => attacksTame p.attacks
  | .energy _ => true
  | .trainer _ _ e => e.tame

end Pokemon
