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
Colorless or Dragon Energy. Since milestone MV5 an Energy card is Basic or Special (`EnergyCard`). -/
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
(`EType.paidBy`). Each unit is listed by the types it counts as; the units of a Pokémon are what its
attached cards provide on it (`InPlay.units`, through `Card.unitsOn` since milestone MV8;
`Card.provides` is the printed provision). With Basic Energy only, every unit is one type. This is a matching problem, not a count: `[fire, fire]` is
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
  /-- (milestone MV6) the player's attacks do `n` less damage, at step 2 of the damage calculation,
  before Weakness and Resistance: "During your opponent's next turn, attacks used by the Defending
  Pokémon do 30 less damage (before applying Weakness and Resistance)" (Pawmi me2-32) is
  `linger .opp .next (.weaken 3)`; repeated uses add up -/
  | weaken (n : Nat)
  /-- (milestone MV6) attacks do `n` more damage to the player's Pokémon, at step 5 of the damage
  calculation, after Weakness and Resistance and before the player's damage reduction: "During your
  next turn, the Defending Pokémon takes 50 more damage from attacks (after applying Weakness and
  Resistance)" (Vibrava sv8-105) is `linger .opp .after (.expose 5)`; repeated uses add up -/
  | expose (n : Nat)
  deriving DecidableEq

/-- A modifier the capped clamp can absorb (milestone MV6): every modifier but a damage reduction,
a step-2 penalty (`weaken`) and a step-5 increase (`expose`). `Effect.tame` admits only these. -/
def Mod.plain : Mod → Bool
  | .reduce _ => false
  | .weaken _ => false
  | .expose _ => false
  | _ => true

/-! ## Card filters and zone moves (milestone MV) -/

/-- The kinds of Trainer card played from the hand and resolved or put into play by `Move.item`,
`Move.supporter` and (milestone M5) `Move.stadium`. Pokémon Tools are a constructor of their own,
`Card.tool`, since they carry what they give the Pokémon they are attached to (`ToolGrant`). -/
inductive TrainerKind where
  | item | supporter | stadium
  deriving DecidableEq

/-- The UTF-8 bytes of a string (milestone MV4). The name filters compare bytes: `String.toList`
and `String.startsWith` depend on `Classical.choice` in this Lean version and do not reduce in the
kernel, while the bytes do. A byte-level prefix or substring test is a character-level one for
valid UTF-8 (no encoded character is a prefix of another, and a continuation byte never starts
one). -/
def nameBytes (s : String) : List UInt8 := s.toByteArray.data.toList

/-- Is the byte list `p` a prefix of `n`? (milestone MV4; written out with `decide` on bytes, since
`List.isPrefixOf` at `UInt8` goes through a `BEq` instance that depends on `Classical.choice`) -/
def bytesPrefix : List UInt8 → List UInt8 → Bool
  | [], _ => true
  | _ :: _, [] => false
  | a :: as, b :: bs => decide (a = b) && bytesPrefix as bs

/-- Does the byte list `p` occur in `n` as a contiguous block? (milestone MV4) -/
def bytesHas (p : List UInt8) : List UInt8 → Bool
  | [] => bytesPrefix p []
  | c :: cs => bytesPrefix p (c :: cs) || bytesHas p cs

/-- Does the name `n` begin with `p`? (milestone MV4) -/
def nameStarts (p n : String) : Bool := bytesPrefix (nameBytes p) (nameBytes n)

/-- Does `s` occur in the name `n`? ("has \"Koffing\" in its name"; milestone MV4) -/
def nameContains (s n : String) : Bool := bytesHas (nameBytes s) (nameBytes n)

/-- A card filter (milestone MV): the kind of card a zone move may pick ("a Basic Pokémon", "a
Supporter card", "a Basic Fire Energy card", "up to 2 Pokémon that don't have a Rule Box").
Evaluated by `Filter.eval`, a `Bool`, so every filter is decidable; a new printed kind is one more
constructor and one more clause of `Filter.eval`. Pokémon filters read the printed card (stage,
type, name, HP, rule box; since milestone MV2 also Tera, a printed attack's name and whether the
card has an Ability), not the Pokémon in play. Since milestone MV5 an Energy card is Basic or
Special (`EnergyCard`): "an Energy card" is `energy`, "a Basic Energy card" `basicEnergy`, "a Special
Energy card" `specialEnergy`; "a Basic Fire Energy card" is `energyOf`, which passes Basic Energy
only. -/
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
  /-- a Trainer card of the given kind (Item, Supporter, Stadium) -/
  | kind (k : TrainerKind)
  /-- a Pokémon Tool card (milestone M5; `Card.tool`) -/
  | tool
  /-- an Energy card, Basic or (milestone MV5) Special -/
  | energy
  /-- a Basic Energy card of type `t` ("a Basic Fire Energy card"); never a Special Energy card,
  whatever it provides -/
  | energyOf (t : EType)
  /-- a Pokémon ex, Mega Evolution Pokémon ex included (milestone MV2: "if your opponent's Active
  Pokémon is a Pokémon ex"; the rule box gives it, `RuleBox`). Today's Standard has no Pokémon V,
  so "a Pokémon ex or Pokémon V" is this filter -/
  | ex
  /-- a Tera Pokémon (milestone MV2: "if your opponent's Active Pokémon is a Tera Pokémon", "if you
  have any Tera Pokémon on your Bench") -/
  | tera
  /-- a Pokémon card with a printed attack of this name (milestone MV2: "for each of your Pokémon in
  play that has the Round attack"); attacks given by a Tool are not read -/
  | hasAttack (n : String)
  /-- a Pokémon card with a printed Ability (milestone MV2: "a Pokémon that has an Ability") -/
  | hasAbility
  /-- a card whose printed name begins with `p` (milestone MV4): the owner prefixes of today's
  Standard, "Iono's Pokémon" (`and pokemon (namePrefix "Iono's ")`), "Team Rocket's Pokémon",
  "Cynthia's Pokémon". Pokémon, Trainer and Tool names; the importer writes the prefix with its
  apostrophe and the following space, as printed -/
  | namePrefix (p : String)
  /-- a card whose printed name contains `s` (milestone MV4): "a Pokémon that has \"Nidoking\" in its
  name", "a Supporter card that has \"Team Rocket\" in its name" -/
  | nameHas (s : String)
  /-- a Basic Energy card (milestone MV5: "a Basic Energy card", as against "an Energy card") -/
  | basicEnergy
  /-- a Special Energy card (milestone MV5: "Discard a Special Energy from your opponent's Active
  Pokémon", Victini sv5-30; "for each Special Energy card attached to this Pokémon", Cinccino
  sv5-137) -/
  | specialEnergy
  | and (a b : Filter)
  | or (a b : Filter)
  | not (a : Filter)
  deriving DecidableEq

/-- Where a zone move takes its cards from, in the zones of one player: the deck (searched: any
cards of it), the top `n` cards of the deck ("look at the top 7 cards of your deck"; drawing and
milling take from here), the hand, or the discard pile (recycling: "Put up to 2 Basic Energy cards
from your discard pile into your hand", "Shuffle up to 5 Pokémon from your discard pile into your
deck", "Attach a Basic Energy card from your discard pile to this Pokémon", "Put up to 2 Basic
Pokémon from your discard pile onto your Bench"). -/
inductive Src where
  | deck
  | top (n : Nat)
  | hand
  | discard
  /-- the bottom `n` cards of the deck (milestone MV6: "Look at the bottom 7 cards of your deck", Dusk
  Ball sv8-175; "Draw 3 cards from the bottom of your deck", Rabsca ex sv10-25); all of them if fewer
  are left -/
  | bottom (n : Nat)
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
Pokémon"; drawing and milling are `all` from the top `n` cards). The rulebook (2026 p. 21) reads
"up to X" as 0..X in attacks and 1..X in other effects (Trainer cards, Abilities), and at least 1
for a search of the deck or discard pile "for any card you want"; `upTo` allows 0 in every effect,
a superset outside attacks and for any search for any card (Known gaps). "Any amount" allows 0 (p. 21), as `upTo` does. -/
inductive Qty where
  | upTo (n : Nat)
  | exactly (n : Nat)
  | all
  /-- (milestone MV6) `n` cards, or every card that passes if fewer pass: "Discard a card you find
  there" (Luxray ex sv6-68, after "Your opponent reveals their hand"), "reveal an Energy card you find
  there, and put it into your hand" (Delibird me6-79), "Search your deck for a card" in an Ability
  (at least 1, 2026 p. 21). It always has a resolution (`Qty.canFail` is false), unlike `exactly` -/
  | most (n : Nat)
  deriving DecidableEq

/-- Where the cards taken from a window go (milestone MV6, `Effect.look`): to a zone (`put d`, as a
zone move's destination); onto the player's Bench (`bench`: each card a Basic Pokémon card, as many as
the Bench has room for: "You may put any number of Pokémon you find there onto your Bench", Reuniclus
sv5-72); or attached, each card an Energy card, to any of the player's Pokémon in play whose card
passes `tf`, one card at a time, "in any way you like" (`attach tf`: Lapras ex svp-164). -/
inductive Into where
  | put (d : Dst)
  | bench
  | attach (tf : Filter)
  deriving DecidableEq

/-- Which of a player's Pokémon in play an effect acts on: the Active Pokémon, or one Benched
Pokémon chosen when the effect resolves. "1 of your Pokémon" is a `choice` of the two. -/
inductive Spot where
  | active | bench
  deriving DecidableEq

/-- A zone of one player that a count reads (milestone MV). -/
inductive Pile where
  | hand | deck | discard
  /-- (milestone MV6) the top `n` cards of the deck ("Reveal the top 5 cards of your deck. This
  attack does 70 damage for each … you find there", Iron Thorns svp-98) -/
  | top (n : Nat)
  /-- (milestone MV6) the bottom `n` cards of the deck ("Reveal the bottom 7 cards of your deck, and
  this attack does 50 damage for each Pokémon you find there that has the Bug Out attack",
  Sizzlipede me5-9) -/
  | bottom (n : Nat)
  deriving DecidableEq

/-- A number read from the state (milestone MV), for amounts ("30 damage for each card in your
hand") and tests ("if you have 3 or more Benched Pokémon"): the cards passing a filter in one of
the `w` player's hand, deck or discard pile; the `w` player's Prize cards left; the `w` player's
Benched Pokémon whose card passes a filter; the Energy passing a filter attached to the `w`
player's Active Pokémon, or to all of the `w` player's Pokémon in play (since milestone MV8 counted by
what the cards provide under `Filter.energy`, by cards under every other filter: `Filter.weight`). No count reads damage, so
both clamps keep every count exact (`Count.val_clampAt`, `Count.val_xclampAt`). -/
inductive Count where
  | pile (w : Whose) (z : Pile) (f : Filter)
  | prizes (w : Whose)
  | bench (w : Whose) (f : Filter)
  | energy (w : Whose) (f : Filter)
  | energyAll (w : Whose) (f : Filter)
  /-- the `w` player's Pokémon in play, Active and Benched, whose top card passes `f` (milestone
  MV2: "for each of your Pokémon in play that has the Round attack", "if you have any Tera Pokémon
  in play", "if you have Tornadus in play") -/
  | inPlay (w : Whose) (f : Filter)
  /-- 1 if any of the `w` player's Pokémon were Knocked Out during the previous turn (with `atk`:
  by the Knock Out check after an attack), else 0 (milestone MV2, `KOHist`): "If any of your Pokémon
  were Knocked Out by damage from an attack during your opponent's last turn, this attack does 60
  more damage" (Iron Leaves sv6-19) is `ite (countGe (koLast .own true) 1) …`. A flag read as a
  count, so that it is a read of the state that both clamps keep like every count -/
  | koLast (w : Whose) (atk : Bool)
  /-- the Pokémon Tools attached to all of the `w` player's Pokémon in play (milestone MV4: "30
  damage for each Pokémon Tool attached to all of your Pokémon", Mow Rotom sv10-9; "attached to all
  Pokémon", Bronzong me2-72, is the sum of the two players' counts) -/
  | tools (w : Whose)
  /-- the Special Conditions affecting the `w` player's Active Pokémon, 0 to 3 (milestone MV4: "100
  damage for each Special Condition affecting your opponent's Active Pokémon", Cradily sv7-6): one
  for Asleep, Confused or Paralyzed (they replace each other), one for Poisoned, one for Burned; 0
  with no Active Pokémon -/
  | conds (w : Whose)
  /-- the Prize cards the `w` player has taken, 6 less the Prize cards left, at least 0 (milestone
  MV4: "60 damage for each Prize card your opponent has taken", Pecharunt ex sv6pt5-39). Exact for a
  game set up with 6 Prize cards ("7) Put the top 6 cards of your deck off to the side face down as
  your Prize cards", rulebook 2026 p. 8), since nothing in the model returns a card to the Prizes;
  the model does not require 6 at the start (Known gaps) -/
  | prizesTaken (w : Whose)
  /-- the number of distinct types of the Basic Energy cards attached to all of the `w` player's
  Pokémon in play (milestone MV4: "50 damage for each type of Basic Energy attached to all of your
  Pokémon", Sylveon ex me55-71) -/
  | energyTypes (w : Whose)
  /-- 1 if the `w` player has played a Supporter card from the hand this turn
  (`PlayerState.supporterPlayed`), else 0 (milestone MV4: "if they played a Supporter card from
  their hand this turn", Community Center sv6-146); the Supporter's name is not recorded. The flag
  is cleared when its player's turn starts, so for the player whose turn it is it means "this
  turn", and for the other player it means "during their last turn" -/
  | supporter (w : Whose)
  /-- the printed Retreat Cost of the `w` player's Active Pokémon, 0 with no Active Pokémon
  (milestone MV6: "This attack does 30 more damage for each Colorless in your opponent's Active
  Pokémon's Retreat Cost", Ariados sv6-5). The printed card's, not the derived Retreat Cost
  (`GameState.retreatOf`, which static effects change): counts are defined before the static
  effects, so for a Pokémon whose Retreat Cost a static effect changes (Air Balloon, Gravity
  Gemstone, N's Castle, …) the count reads the printed value (Known gaps). It reads the printed card,
  which both clamps keep -/
  | retreat (w : Whose)
  deriving DecidableEq

/-- A test an effect can make on one Active Pokémon, or (since milestone MV) on a count. Milestone
MV2 added tests on the Active Pokémon's printed card (`top`) and its Tools (`hasTool`). -/
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
  /-- the count is at least `n` (milestone MV; "if you have 3 or more cards in your hand"); it reads
  no Active Pokémon, and like every test it is made while the player has an Active Pokémon -/
  | countGe (c : Count) (n : Nat)
  /-- its top card passes the filter `f` (milestone MV2: "if your opponent's Active Pokémon is a
  Pokémon ex" is `top .opp .ex`; "is an Evolution Pokémon", `top .opp (.not .basic)`; "is a Stage 1
  Pokémon", `top .opp (.stage .stage1)`; "is a Tera Pokémon", `top .opp .tera`). It reads the
  printed card, which both clamps keep -/
  | top (w : Whose) (f : Filter)
  /-- it has a Pokémon Tool attached (milestone MV2) -/
  | hasTool (w : Whose)
  /-- it moved from the Bench to the Active Spot this turn (milestone MV2, `InPlay.movedUp`: "If
  this Pokémon moved from your Bench to the Active Spot this turn", Keldeo ex rsv10pt5-30) -/
  | movedUp (w : Whose)
  /-- it evolved this turn (milestone MV2: "If this Pokémon evolved from Salandit during this turn",
  Salazzle sv7-24): it was put into play or evolved this turn (`InPlay.fresh`) and has a card under
  it. Exact without new state: only Basic Pokémon are put into play, evolution sets `fresh`, and
  `fresh` is cleared at the end of its owner's turn; the printed "from X" is the card's own
  pre-evolution, the only way the model evolves it -/
  | evolved (w : Whose)
  /-- (milestone MV6) it used an attack whose `Attack.selfLock` is `AtkLock.note` during its owner's
  last turn (the record in force in `InPlay.lk`). "During your next turn, this Pokémon's Meteor Mash
  attack does 60 more damage (before applying Weakness and Resistance)" (Metagross sv5-115) is
  Meteor Mash with `selfLock := .note` and the effect `ite (usedLast .own) (damage (const 12))
  (damage (const 6))`; "this Pokémon's Hyper Fang attack's base damage is 240" (Watchog
  rsv10pt5-73) puts the record on Focus Energy and the test in Hyper Fang. Per Pokémon: the record
  ends when the Pokémon moves to the Bench or evolves (2026 p. 20, p. 11), as print says. Exact for
  a Pokémon with at most one attack whose `selfLock` is not `none` -/
  | usedLast (w : Whose)
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
  /-- `k` for each unit of the count `c` ("30 damage for each Energy attached to this Pokémon" is
  `count (.energy .own .energy) 3`; milestone MV) -/
  | count (c : Count) (k : Nat)
  /-- `k` for each heads among `a` coins (milestone MV6): any multiple `k · m` with `m` at most the
  value of `a`. "Flip a coin for each Energy attached to this Pokémon. This attack does 80 damage for
  each heads" (Larry's Dudunsparce ex me2pt5-164) is `heads (count (.energy .own .energy) 1) 8`;
  "Flip 3 coins. This attack does 50 damage for each heads" is `heads (const 3) 5`; "Reveal any
  number of Honedge … from your hand, and this attack does 60 damage for each card you revealed in
  this way" (Doublade me3-57) is `heads (count (.pile .own .hand f) 1) 6`. Coin flips are
  nondeterministic choices (the model is silent about probability), so each number of heads is one
  value -/
  | heads (a : Amt) (k : Nat)
  deriving DecidableEq

/-- Which steps of the damage calculation an attack's damage step switches off (milestone MV3): the
Defending Pokémon's Weakness (step 3), its Resistance (step 4), and every effect on it (step 5: its
stored reduction and prevention and the static reductions and preventions in force on it). The
2026 rulebook's steps (p. 20): "3) Increase the damage by the amount next to your opponent's Active
Pokémon's Weakness … 4) Reduce the damage by the amount next to your opponent's Active Pokémon's
Resistance … 5) Figure out damage effects of Trainer or Energy cards, or other effects on your
opponent's Active Pokémon". The printed variants: "This attack's damage isn't affected by
Weakness" (`weak`), "… by Resistance" (`resist`), "… by Weakness or Resistance" (both), "… by any
effects on your opponent's Active Pokémon" (`fx`), and "… by Weakness or Resistance, or by any
effects on your opponent's Active Pokémon" (all three). Step 2, the attacker's own bonuses, is
never switched off: the text names only the defender. The default, `{}`, switches nothing off. -/
structure Ign where
  weak : Bool := false
  resist : Bool := false
  fx : Bool := false
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
  `Move.supporter`): printed Trainer cards place damage counters, not attack damage. Since milestone
  MV3 the step carries `ig : Ign`, the steps of the calculation its text switches off ("This
  attack's damage isn't affected by Resistance" is `damage a { resist := true }`); `damage a` is
  `damage a {}`, the full calculation -/
  | damage (a : Amt) (ig : Ign := {})
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
  /-- discard Energy cards that pass `f` from one of the `w` player's Pokémon at `sp`, as much as
  `q` says ("Discard 2 Energy from this Pokémon" is `discardEnergy .own .active .energy
  (.exactly 2)`; "discard an Energy from your opponent's Active Pokémon",
  `discardEnergy .opp .active .energy (.upTo 1)`); they go to that player's discard pile. Since
  milestone MV8 the quantity is counted by `Qty.okE`: under `Filter.energy` by the Energy the cards
  provide (cards that provide `n`, none superfluous; one card that provides 2 meets "exactly 1" and
  "exactly 2"), under any other filter by cards (`Filter.weight`). With `bench` and an empty Bench,
  nothing -/
  | discardEnergy (w : Whose) (sp : Spot) (f : Filter) (q : Qty)
  /-- move one Energy card that passes `f` from one of the `w` player's Pokémon in play to another
  ("Move an Energy from 1 of your Benched Pokémon to your Active Pokémon"); or nothing -/
  | moveEnergy (w : Whose) (f : Filter)
  /-- move one damage counter from one of the player's own Pokémon in play whose card passes `f`
  to another of the player's Pokémon (milestone M8a: "move 1 damage counter from 1 of your Team
  Rocket's Pokémon to another of your Pokémon", Team Rocket's Orbeetle sv10-89, an "as often as you
  like" Ability). With `noKO`, a counter may not be moved onto a Pokémon it would bring to its HP
  ("… in a way that would Knock Out …"). A move, not healing and not damage: no modifier applies.
  It has no resolution when no counter can be moved, like a cost that cannot be paid. The
  opponent's Pokémon are out of its reach (`Effect.moveCounter` moves the player's own counters
  only) -/
  | moveCounter (f : Filter) (noKO : Bool)
  /-- discard the Stadium in play, if any, to its owner's discard pile (milestone M5: "Discard a
  Stadium in play", Hisuian Growlithe sv6-99, Eternatus sv8-141, Megaton Blower sv8-182; "You may
  discard a Stadium in play" is a `choice` with `skip`); nothing if no Stadium is in play. Whose
  Stadium it is is not read ("If your opponent has a Stadium in play, discard it", Chi-Yu me1-31,
  is not expressible exactly) -/
  | discardStadium
  /-- discard every Pokémon Tool attached to one of the `w` player's Pokémon at `sp` to that
  player's discard pile (milestone M5: "Before doing damage, discard all Pokémon Tools from your
  opponent's Active Pokémon", Spearow me1-102 and eight more; at `bench` one Benched Pokémon chosen
  when the effect resolves, nothing with an empty Bench; "discard a Pokémon Tool from 1 of your
  opponent's Pokémon" is a `choice` of the two, exact with one Tool per Pokémon) -/
  | discardTools (w : Whose) (sp : Spot)
  /-- (milestone MV2) attack damage `n` (`dmg = true`, as `benchDamage`: no modifier, none on a Tera
  Pokémon) or `n` damage counters (`dmg = false`, as `benchCounters`) on each of `m` distinct
  Benched Pokémon of the `w` player whose card passes `f`, chosen when the effect resolves; all of
  them if fewer pass ("This attack also does 130 damage to 2 of your opponent's Benched Pokémon",
  Hydreigon ex sv8-119, is `benchSome .opp 2 .any true 13`; "This attack does 210 damage to 1 of
  your opponent's Benched Pokémon ex", Zeraora sv10-78, `benchSome .opp 1 .ex true 21`). With the
  Active Pokémon among the targets ("120 damage to 2 of your opponent's Pokémon") it is a derived
  form, `Effect.hitSome`. Only attacks may use the damage form (`benchHitFree`) -/
  | benchSome (w : Whose) (m : Nat) (f : Filter) (dmg : Bool) (n : Nat)
  /-- **look at a fixed window and choose** (milestone MV6): take the whole window `src.get` of the
  `w` player's zones off its source at once (the top or bottom `n` cards of the deck as they are when
  the effect starts, the whole deck, hand or discard pile), take from it cards that pass `f`, as many
  as `q` says, put the other cards of the window at `rest`, and then put the taken cards `into` their
  place (`Into`: a zone, the Bench, or attached to Pokémon). "Look at the top 6 cards of your deck,
  reveal an Energy card you find there, and put it into your hand. Shuffle the other cards and put
  them on the bottom of your deck" (Delibird me6-79) is `look .own (.top 6) .energy (.most 1) (.put
  .hand) .bottom`; "Look at the top 5 cards of your deck and discard any number of them. Put the other
  cards back in any order" (Raifort sv6-161) is `look .own (.top 5) .any (.upTo 5) (.put .discard)
  .top`; "Look at the top 4 cards of your deck and attach any number of Basic Metal Energy cards you
  find there to your Pokémon in any way you like. Shuffle the other cards and put them on the bottom of
  your deck" (Metang svp-90) is `look .own (.top 4) (.energyOf .metal) (.upTo 4) (.attach .any)
  .bottom`. Unlike a sequence of one-card primitives on `.top n`, each of which reads the top `n` of
  the deck as it is then, the window is read once (semantics `ZStep.look`; `Pokemon/Look.lean`) -/
  | look (w : Whose) (src : Src) (f : Filter) (q : Qty) (into : Into) (rest : Dst)
  | seq (a b : Effect)
  | choice (a b : Effect)
  | iter (a : Effect)
  deriving DecidableEq

/-- A per-Pokémon attack lock (milestone MV4): none; "this Pokémon can't use [this attack]" (`this`:
the attacks of the Pokémon whose `Attack.selfLock` is `this`); or "this Pokémon can't use attacks"
(`all`). -/
inductive AtkLock where
  | none | this | all
  /-- (milestone MV6) no lock: the record that the Pokémon used an attack whose `selfLock` is
  `note`, read during its owner's next turn by `Test.usedLast` ("During your next turn, this
  Pokémon's Meteor Mash attack does 60 more damage", Metagross sv5-115; "If this Pokémon used
  [attack] during your last turn") -/
  | note
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
  /-- (milestone MV4) the lock the attack puts on the attacking Pokémon for its owner's next turn:
  "During your next turn, this Pokémon can't use [this attack]" (`this`; Feraligatr svp-89, 27
  refused Standard cards, survey S17 §C) or "During your next turn, this Pokémon can't use attacks"
  (`all`). The lock is per Pokémon (`InPlay.lk`): set by `Move.attack`, in force during the owner's
  next turn, and gone when the Pokémon moves to the Bench or evolves (rulebook 2026 p. 20: "if an
  Active Pokémon moves to the Bench, all effects of attacks go away"; p. 11: "Any effects of attacks
  … end when it evolves"). `this` is exact for a Pokémon with at most one attack whose `selfLock` is
  `this`, which is every card record in the data (S17 §E). Default `none` -/
  selfLock : AtkLock := .none
  deriving DecidableEq

/-- Does a lock in force allow the attack? (milestone MV4) -/
def AtkLock.allows : AtkLock → Attack → Bool
  | .none, _ => true
  | .this, atk => !decide (atk.selfLock = .this)
  | .all, _ => false
  | .note, _ => true

/-- No damage step (`damage` or `drain`) anywhere in the effect. -/
def Effect.hitFree : Effect → Bool
  | .damage _ _ => false
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
  | .benchSome _ _ _ dmg _ => !dmg
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

/-- The test reads the player's own Active Pokémon (a count of the Energy attached to it
included). -/
def Test.onOwn : Test → Bool
  | .atLeast .own _ | .exactly .own _ | .cond .own _ | .marked .own _ | .isType .own _ => true
  | .countGe (.energy .own _) _ => true
  | .countGe (.conds .own) _ => true
  | .countGe (.retreat .own) _ => true
  | .top .own _ | .hasTool .own | .movedUp .own | .evolved .own | .usedLast .own => true
  | _ => false

/-- The effect neither reads nor writes the player's own Active Pokémon: no `heal`, `cure`,
`selfDamage`, `healAll`, `scale .own`, `switch .own`, no Energy attached to, discarded from or
moved off it (`attach .own _ _ .active _`, `discardEnergy .own .active`, `moveEnergy .own`;
milestone MV; `look .own … (.attach _)`, milestone MV6), no test on the player's own Active Pokémon,
and no damage step (`damage` and `drain` read the attacker's type for Weakness and Resistance, and
their amount may read its damage; `drain` heals it). `mark .own` and `color .own` are allowed: they
may choose any of the player's Pokémon in play, Active or Benched. -/
def Effect.ownFree : Effect → Bool
  | .heal _ => false
  | .cure => false
  | .selfDamage _ => false
  | .healAll => false
  | .damage _ _ => false
  | .drain _ => false
  | .scale .own _ => false
  | .switch .own => false
  | .attach .own _ _ .active _ => false
  | .discardEnergy .own .active _ _ => false
  | .moveEnergy .own _ => false
  | .moveCounter _ _ => false
  | .look .own _ _ _ (.attach _) _ => false
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
  | .switch _, _ | .benchDamage _ _, _ | .spreadDamage _ _, _ | .damage _ _, _ | .drain _, _
  | .move _ _ _ _ _, _ | .drawTo _ _, _ | .attach _ _ _ _ _, _ | .putBench _ _ _, _
  | .discardEnergy _ _ _ _, _ | .moveEnergy _ _, _ | .moveCounter _ _, _ | .discardStadium, _
  | .discardTools _ _, _ | .benchSome _ _ _ _ _, _ | .look _ _ _ _ _ _, _ => rfl

/-- A quantity whose zone move can fail (`exactly n`: no resolution if fewer cards can be taken). -/
def Qty.canFail : Qty → Bool
  | .exactly _ => true
  | _ => false

/-- **The trigger fragment** (milestone M8b): the effects a triggered Ability resolves. Drawing,
damage counters and a Special Condition other than Paralysis on the opponent's Active Pokémon (from
the trigger's owner, "the Attacking Pokémon"), shuffling, the zone moves that always have a resolution (no `exactly`),
discarding Tools, in sequence or as a choice. Excluded: tests and `iter`, every effect that reads
damage (`heal`, `scale`, the damage steps, `moveCounter`), lingering modifiers (`linger`), switching,
markers, `poisonUp`, `search` (no resolution on an empty deck; "search your deck" is a `move`),
`discardStadium`, and Paralysis: a trigger resolves during the attacker's owner's turn, and
"After its owner's next turn, it recovers during Pokémon Checkup" (rulebook 2026 p. 16) would keep
the attacker Paralyzed through its owner's next turn, whereas `InPlay.checkup` cures Paralysis at
the Checkup that ends its owner's turn, here the very turn it was inflicted; the model has no
record of when a Condition was inflicted, so the fragment leaves Paralysis out (no imported trigger
inflicts it). So a trigger can always be resolved when both Active Spots are filled
(`Run.exists_of_trigOk`), writes no store, and reads no damage, which both clamps need. Every
printed effect of the two implemented shapes in today's Standard that the model can express is in
the fragment (survey S12 §3). -/
def Effect.trigOk : Effect → Bool
  | .skip => true
  | .draw => true
  | .counters _ => true
  | .inflict c => decide (c ≠ .paralyzed)
  | .shuffle => true
  | .move _ _ _ _ q => !q.canFail
  | .drawTo _ _ => true
  | .attach _ _ _ _ _ => true
  | .putBench _ _ _ => true
  | .discardEnergy _ _ _ q => !q.canFail
  | .moveEnergy _ _ => true
  | .discardTools _ _ => true
  | .seq a b => a.trigOk && b.trigOk
  | .choice a b => a.trigOk && b.trigOk
  | _ => false

/-- What an attack resolves (rulebook 2023 p. 20, step F: "Apply any effects that happen before
damage, then place damage counters, and then do all other effects"). An attack with printed base
damage `n ≠ 0` and no damage step in its text does its damage first, then its effect. An attack
with base damage 0 resolves its effect, which places its damage, if any, with its own damage
step: this is how an attack writes damage computed by its text ("×", "+", "–"), damage that
depends on a coin flip or a choice made in the same effect, or effects before the damage. -/
def Attack.script (atk : Attack) : Effect :=
  if atk.damage = 0 then atk.effect else .seq (.damage (.const atk.damage)) atk.effect

/-- The lock an attack sets on the attacker (milestone MV4): its `selfLock`, unless its script may
switch the attacker to the Bench (`Effect.switchesOwn`), where the lock would land on another
Pokémon; no printed self-locking attack switches (survey S17 §E), and for such an attack the model
sets no lock (an under-model, Known gaps). -/
def Attack.lockSet (atk : Attack) : AtkLock :=
  if atk.script.switchesOwn then .none else atk.selfLock

/-- An attack whose text sets no lock sets none. -/
theorem Attack.lockSet_of_none {atk : Attack} (h : atk.selfLock = .none) : atk.lockSet = .none := by
  unfold Attack.lockSet; split
  · rfl
  · exact h

/-- A well-formed attack: at most one damage step on each line of resolution, none in the
text when a printed base damage is done first, and nothing that reads or writes the player's own
Active Pokémon after a switch of it (`Effect.switchSafe`, so the attacker stays the attacker:
`Attack.attacker_at_hit`). `Move.attack` requires it. -/
def Attack.wf (atk : Attack) : Bool :=
  atk.effect.oneHit && (decide (atk.damage = 0) || atk.effect.hitFree) && atk.effect.switchSafe

theorem Effect.oneHit_of_hitFree : ∀ {e : Effect}, e.hitFree = true → e.oneHit = true
  | .damage _ _, h => by simp [Effect.hitFree] at h
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
  | .discardEnergy _ _ _ _, _ | .moveEnergy _ _, _ | .moveCounter _ _, _ | .discardStadium, _
  | .discardTools _ _, _ | .benchSome _ _ _ _ _, _ | .look _ _ _ _ _ _, _ => rfl

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

/-! ## Static effects (milestone M6)

A static effect is in force exactly while its source is in play: a Pokémon's static Ability
(while that Pokémon is in play, or only while it is Active or Benched), a Tool's static text (while
attached, for its holder), a Stadium's static text (while it is in play, for both players). The
quantities it changes (HP, the damage of an attack, the Retreat Cost) are computed from the state
when they are read (`Pokemon/Static.lean`); nothing is stored. -/

/-- Which Pokémon in play a static effect applies to, relative to its source: the source Pokémon
itself (for a Tool: its holder; nothing for a Stadium), every Pokémon in play of the source's owner,
every Pokémon in play of the owner's opponent, or every Pokémon in play. A Stadium belongs to the
player who played it (`GameState.stadium`); printed Stadium text says "each player's" or "all",
which is `all`. -/
inductive Sel where
  | self | own | opp | all
  deriving DecidableEq

/-- The amount of a static change: a printed number (`const`), or `k` for each Energy card passing
`f` attached to the affected Pokémon (`perEnergy`: Conkeldurr's "+40 HP for each Fighting Energy
attached to this Pokémon", Galarian Stunfisk V). -/
inductive SAmt where
  | const (n : Nat)
  | perEnergy (f : Filter) (k : Nat)
  deriving DecidableEq

/-- What a static effect changes, for the Pokémon it applies to (counters, like everything else).

* `hpPlus a`: "+N HP" (Hero's Cape, Lively Stadium, Ludicolo sv9-37's Vibrant Dance);
* `hpMinus n`: "−N HP" (Gravity Mountain: "Stage 2 Pokémon in play get −30 HP"); HP is the
  printed HP plus every `hpPlus` less every `hpMinus`, stopping at 0 (`GameState.hpOf`);
* `bonus n vs`: the attacks of the affected Pokémon do `n` more damage to the opponent's Active
  Pokémon, if its top card passes `vs` (Maximum Belt: "to your opponent's Active Pokémon ex");
  added at step 2 of the damage calculation, with the attacker's stored bonus (rulebook 2023
  p. 20; `GameState.dealt`);
* `reduce n fr`: the affected Pokémon takes `n` less damage from attacks of Pokémon whose top card
  passes `fr`; subtracted at step 5, with the defender's stored reduction;
* `retreatPlus n`, `retreatMinus n`: its Retreat Cost is `n` more or `n` less, stopping at 0
  (`GameState.retreatOf`; Air Balloon "−2", Gravity Gemstone "+1");
* `prevent fr` (milestone MV3): "Prevent all damage done to this Pokémon by attacks from your
  opponent's Pokémon ex" (Sylveon sv8pt5-40: `fr = ex`); damage to the affected Pokémon in the
  Active Spot from attacks of Pokémon whose top card passes `fr` is 0 (step 5 of the damage
  calculation, with the defender's other effects; `GameState.sPrevent`). A flag, not an amount: it
  is read, never stored, and an attack whose damage "isn't affected by any effects on your
  opponent's Active Pokémon" (`Ign.fx`) is not prevented.
* `condMore c n` (milestone MV7b, survey S20 §a T1): during Pokémon Checkup, `n` more damage
  counters on the affected Pokémon if it has the Special Condition `c` ("During Pokémon Checkup,
  put 3 more damage counters on your opponent's Burned Pokémon", Magmortar sv9-21: `sel = opp`,
  `c = burned`, `n = 3`; Pecharunt svp-129, "As long as this Pokémon is in the Active Spot, put 5
  more damage counters on your opponent's Poisoned Pokémon during Pokémon Checkup": `src = some
  .active`, `c = poisoned`, `n = 5`). Read by `Move.endTurn` (`GameState.checkupMoreBy`), never
  stored.
* `noRetreat` (milestone MV8): "The Metal Pokémon this card is attached to has no Retreat Cost"
  (Magnetic Metal Energy me4-85): the affected Pokémon's Retreat Cost is 0, whatever else is in force
  (`GameState.retreatOf`: a set, applied after the additions and subtractions). -/
inductive SEff where
  | hpPlus (a : SAmt)
  | hpMinus (n : Nat)
  | bonus (n : Nat) (vs : Filter)
  | reduce (n : Nat) (fr : Filter)
  | retreatPlus (n : Nat)
  | retreatMinus (n : Nat)
  | prevent (fr : Filter)
  | condMore (c : Condition) (n : Nat)
  | noRetreat
  deriving DecidableEq

/-- **A static effect** (milestone M6): what it changes (`eff`), for which Pokémon (`sel`, relative
to its source), with conditions on the affected Pokémon (its top card passes `filt`; it is at `tgt`,
if given; at least `n` Energy cards passing `f` are attached to it, if `need = some (f, n)`) and on
the source (it is at `src`, if given: "as long as this Pokémon is in the Active Spot"; ignored for a
Stadium). Several effects in force add up: no stacking rule is modelled ("The effect of Vibrant Dance
doesn't stack" is not expressible; Known gaps). No condition reads HP, damage or the Retreat Cost:
an HP amount is a constant or a count of attached Energy, so HP is never defined in terms of HP
(the circular cases of survey S7 §A, Ditto copying HP and Heavy Boots with Rescue Board, are not
expressible). -/
structure Static where
  sel : Sel
  filt : Filter
  tgt : Option Spot
  src : Option Spot
  need : Option (Filter × Nat)
  eff : SEff
  deriving DecidableEq

/-! ## Abilities (milestone M8a) -/

/-- How an on-play Ability is triggered: "When you play this Pokémon from your hand onto your
Bench during your turn" (`bench`), "When you play this Pokémon from your hand to evolve 1 of your
Pokémon during your turn" (`evolve`), or either. -/
inductive PlayWay where
  | bench | evolve | either
  deriving DecidableEq

/-- The event a triggered Ability (milestone M8b) fires on; survey S12 §1, the two commonest shapes
of today's Standard.

* `damaged` (S12 E1, 24 cards): "If this Pokémon is in the Active Spot and is damaged by an attack
  from your opponent's Pokémon (even if this Pokémon is Knocked Out), …" (Iron Jugulis sv5-139,
  Roselia sv5-8, Lucky Helmet sv6-158). It fires at the end of the attack, before the Knock Out
  check, and "this Pokémon" is its owner's Active Pokémon.
* `koByAttack` (S12 E2, 11 cards): "If this Pokémon is Knocked Out by damage from an attack from
  your opponent's Pokémon, …" (Maractus sv9-8, Amulet of Hope sv8-162). It fires in the Knock Out
  check after the attack, when the Pokémon and its cards are already in the discard pile; with the
  Ability's `spot = some .active`, only if the Pokémon was Knocked Out in the Active Spot.

* `oppBenched` (milestone MV7; survey S20, S12 E8): "Whenever your opponent's Active Pokémon moves to
  the Bench during their turn, …" (Magcargo sv5-29, Mismagius ex me2-36). Raised at its source: by a
  retreat (`Move.retreat`) and by a switch of the player's own Active Pokémon with a Benched one inside
  any effect of their turn (`Run.switch .own`), which record it in the state (`GameState.pend`); it
  resolves before anything else, the Knock Out check included (`Move.trigger` after a retreat or an
  attack, `Resolve.trigger` after a step of a Trainer, Stadium or Ability effect), so the triggers
  that fire are those of the opponent's Pokémon in play as the retreat, the step or the attack left
  them. "Their new Active Pokémon" is the opponent's Active Pokémon then (`counters`, `inflict`):
  the Pokémon switched in (a well-formed attack does nothing more to the player's Active Pokémon
  after the switch). The holders that fire are those at the event (milestone MV7b): the event marks
  them (`InPlay.owe`) and the resolution fires the marked ones (`GameState.owedTrigs`), wherever
  the rest of the attack has moved them (`Pokemon/Gust.lean`; departures in the Known gaps of
  `Pokemon/Rules.lean`).

* `movedUp`, `movedDown` (milestone MV7c; survey S20 §a, group (a)): "Once during your turn, when
  this Pokémon moves from your Bench to the Active Spot, you may …" (Yanmega ex sv10-3) and "Once
  during your turn, when this Pokémon moves from the Active Spot to your Bench, you may use this
  Ability. …" (Clawitzer me1-38); both expressible (not imported; witnesses with test cards in
  `Pokemon/Moved.lean`). The "once during your turn" limit is part of the event: the holder's
  single `InPlay.used` flag (shared with activated Abilities; exact only for a holder whose one
  Ability is this trigger, Known gaps) is set when the event marks it, and a holder with the flag
  set is not marked. Raised for the player to move's own Pokémon, in their turn: by a retreat
  (`Move.retreat`: the retreating Pokémon moves down, the one switched in moves up), by a switch of
  their own Active Pokémon inside any effect of their turn (`Run.switch .own`, including
  `SelfOp.switchIn`), and (`movedUp`) by the promotion of a Benched Pokémon after a Knock Out of
  their Active Pokémon in their own turn (`KOBatch`, `GameState.promoUp`; not between turns, at
  Checkup, read as no player's turn (a reading, Known gaps), and not for the opponent's promotion,
  in a turn that is not the opponent's). The event marks the holder
  (`InPlay.owe`: `some .active` moved up, `some .bench` moved down, `InPlay.noteMove`) and sets the
  record (`GameState.pend`); the resolution (`Owed`) fires the marked holders' triggers with "this
  Pokémon" at its new place (`TrigEvent.place`), before anything else, as for `oppBenched`.

`damaged`, `koByAttack` and `oppBenched` belong to the player whose turn it is not, and their effects
are written from that player's side: `.own` is the owner, `.opp` the player to move, so "the
Attacking Pokémon" is the opponent's Active Pokémon (`counters`, `inflict`, `discardEnergy .opp
.active`). `movedUp` and `movedDown` belong to the player to move (`TrigEvent.mine`), and their
effects are written from that player's side too: `.own` is the owner, the player to move. -/
inductive TrigEvent where
  | damaged
  | koByAttack
  | oppBenched
  | movedUp
  | movedDown
  deriving DecidableEq

/-- Where "this Pokémon" is when a trigger on the event resolves: in the Active Spot for `damaged`;
nowhere in play for `koByAttack` (it has been Knocked Out), so an effect on it is not tracked; for
`oppBenched` not tracked either (the trigger's Pokémon may be Active or Benched); (milestone MV7c) in
the Active Spot for `movedUp` (the Pokémon has just moved there, and nothing moves the player's
Active Pokémon before the resolution: a well-formed attack switches it at most once, `Attack.wf`, and
the trigger fragment has no switch), on the Bench for `movedDown` (where an effect on "this Pokémon"
acts on one Benched Pokémon chosen when it resolves, `SelfOp.atS`: a superset). -/
def TrigEvent.place : TrigEvent → Option Spot
  | .damaged => some .active
  | .koByAttack => none
  | .oppBenched => none
  | .movedUp => some .active
  | .movedDown => some .bench

/-- Does the event fire only after the turn's attack (milestone MV7)? `damaged` and `koByAttack` do;
`oppBenched` (and, milestone MV7c, `movedUp`, `movedDown`) fire at any time of the turn, as often as
the player switches, so their effects must recycle nothing (`Ability.trigOn`): the per-turn store
invariant needs the discard piles kept before the attack (`StoreSafe`, clause 3 (a)). -/
def TrigEvent.late : TrigEvent → Bool
  | .damaged => true
  | .koByAttack => true
  | .oppBenched => false
  | .movedUp => false
  | .movedDown => false

/-- Does a trigger of the event belong to the player to move (milestone MV7c)? `movedUp` and
`movedDown` do (the player's own Pokémon moved in their turn); the other three belong to the
player whose turn it is not. -/
def TrigEvent.mine : TrigEvent → Bool
  | .movedUp => true
  | .movedDown => true
  | _ => false

/-- The use limit of an Ability (survey S9 part 2, `ability_kind`): "Once during your turn, you
may …" (`once`: once per turn for each Pokémon in play that has it); "As often as you like during
your turn, you may …" (`unlimited`); or a trigger on entering play from the hand (`onPlay`; "you
may", so optional); or (milestone M6) static (`static ss`: never used; its static effects `ss` are
in force while the Pokémon is in play, `Pokemon/Static.lean`); or (milestone M8b) triggered by the
event `ev` (`triggered ev opt`; `opt`: "you may", so the owner may decline it; otherwise it must
resolve). The events are those of `TrigEvent` (since milestone MV7c the player's own moves between
the Bench and the Active Spot too); other triggered Abilities (S12, S20: attaching Energy, the
opponent's evolution and plays, replacement effects) have no constructor. -/
inductive AbilityUse where
  | once
  | unlimited
  | onPlay (w : PlayWay)
  | static (ss : List Static)
  | triggered (ev : TrigEvent) (opt : Bool)
  deriving DecidableEq

/-- The event of a triggered Ability (milestone M8b), `none` for every other use limit. -/
def AbilityUse.event : AbilityUse → Option TrigEvent
  | .triggered ev _ => some ev
  | _ => none

/-- May the owner decline the trigger? ("you may"; an on-play Ability is optional too.) -/
def AbilityUse.optional : AbilityUse → Bool
  | .triggered _ opt => opt
  | _ => true

/-- An effect on "this Pokémon", the Pokémon whose Ability resolves (milestone M8a): heal `n`
damage counters from it; put `n` damage counters on it ("put 5 damage counters on this Pokémon",
Feraligatr sv5-41); attach to it an Energy card that passes `f`, taken from `src` ("attach a Basic
Energy card from your discard pile to this Pokémon", Team Rocket's Spidops me2pt5-19); switch it,
on the Bench, with the Active Pokémon; move to it an Energy that passes `f` from another of the
player's Pokémon ("Move an Energy from 1 of your other Pokémon to this Pokémon", Azumarill ex
me2pt5-84). -/
inductive SelfOp where
  | heal (n : Nat)
  | counters (n : Nat)
  | attach (src : Src) (f : Filter)
  | switchIn
  | energyTo (f : Filter)
  deriving DecidableEq

/-- The effect of an Ability: effects of the language (`fx`) and effects on "this Pokémon"
(`self`), in sequence or as a choice. -/
inductive AbEff where
  | fx (e : Effect)
  | self (o : SelfOp)
  | seq (a b : AbEff)
  | choice (a b : AbEff)
  deriving DecidableEq

/-- A `SelfOp` as an effect of the language, for "this Pokémon" at `sp`. In the Active Spot it is
exact (`heal`, `selfDamage`, `attach … .active`; a switch-in does nothing); on the Bench it acts on
one Benched Pokémon chosen when it resolves (`benchHeal`, `benchCounters .own`, `attach … .bench`,
`switch .own`), which includes this Pokémon: a superset of the printed outcomes. "Move an Energy to
this Pokémon" is `moveEnergy .own f`, which moves an Energy between any two of the player's
Pokémon: a superset in either place. -/
def SelfOp.atS : Spot → SelfOp → Effect
  | .active, .heal n => .heal n
  | .bench, .heal n => .benchHeal n
  | .active, .counters n => .selfDamage n
  | .bench, .counters n => .benchCounters .own n
  | .active, .attach src f => .attach .own src f .active .any
  | .bench, .attach src f => .attach .own src f .bench .any
  | .active, .switchIn => .skip
  | .bench, .switchIn => .switch .own
  | _, .energyTo f => .moveEnergy .own f

/-- A `SelfOp` where "this Pokémon" is at `p`, or (`none`) at a place the model does not track:
then the choice of both. -/
def SelfOp.at : Option Spot → SelfOp → Effect
  | some sp, o => o.atS sp
  | none, o => .choice (o.atS .active) (o.atS .bench)

/-- Where "this Pokémon" is after the `SelfOp`, if the model knows: after a switch-in from the
Bench the place is unknown, since `switch .own` may switch in another Benched Pokémon. -/
def SelfOp.after : Option Spot → SelfOp → Option Spot
  | some .active, .switchIn => some .active
  | _, .switchIn => none
  | p, _ => p

/-- Where "this Pokémon" is after the effect, if the model knows: an effect of the language that
may switch the player's Active Pokémon (`Effect.switchesOwn`) loses track of it. -/
def AbEff.after : Option Spot → AbEff → Option Spot
  | p, .fx e => if e.switchesOwn then none else p
  | p, .self o => o.after p
  | p, .seq a b => b.after (a.after p)
  | p, .choice a b => if a.after p = b.after p then a.after p else none

/-- **The effect an Ability resolves**, with "this Pokémon" at `p` (milestone M8a), compiled to
the effect language. The model does not follow "this Pokémon" if it is Knocked Out in mid-effect:
the later steps then act on the Pokémon in its place (the new Active Pokémon), which the printed
card does not do (Known gaps). -/
def AbEff.compile : Option Spot → AbEff → Effect
  | _, .fx e => e
  | p, .self o => o.at p
  | p, .seq a b => .seq (a.compile p) (b.compile (a.after p))
  | p, .choice a b => .choice (a.compile p) (b.compile p)

/-- An Ability (milestone M8a). `spot` is where the Pokémon must be to use it, as printed ("if
this Pokémon is in the Active Spot": `some .active`; "if this Pokémon is on your Bench":
`some .bench`; no restriction: `none`); `cond` is a further printed condition, a `Test` that must
hold when the Ability is used; `effect` (`AbEff`) resolves as a Trainer card's effect does
(`TRun`), compiled with "this Pokémon" at the place of the Pokémon that uses it
(`Ability.script`). An Ability belongs to the Pokémon card: a Pokémon in play has the Abilities of
its top card, so it loses them on leaving play and an evolved Pokémon has the new card's
Abilities ("A Pokémon cannot use the attacks or Abilities of its previous Evolution unless a card
says so", rulebook 2023 p. 11). -/
structure Ability where
  name : String
  use : AbilityUse
  spot : Option Spot
  cond : Option Test
  effect : AbEff
  deriving DecidableEq

/-- The effect the Ability resolves with "this Pokémon" at `p` (`none`: not tracked). -/
def Ability.script (ab : Ability) (p : Option Spot) : Effect := ab.effect.compile p

/-- Every effect the Ability can resolve: with "this Pokémon" Active, Benched, or not tracked. The
conditions on cards (`Card.tame`, `Card.tmax`, the clauses of `StoreSafe`) read all three. -/
def Ability.scripts (ab : Ability) : List Effect :=
  [ab.script (some .active), ab.script (some .bench), ab.script none]

theorem Ability.script_mem (ab : Ability) : ∀ p : Option Spot, ab.script p ∈ ab.scripts
  | some .active => .head _
  | some .bench => .tail _ (.head _)
  | none => .tail _ (.tail _ (.head _))

/-- An Ability that a player uses during their turn by choice (`once` or `unlimited`), as opposed
to an on-play trigger. -/
def AbilityUse.activated : AbilityUse → Bool
  | .once => true
  | .unlimited => true
  | .onPlay _ => false
  | .static _ => false
  | .triggered _ _ => false

/-- The static effects of an Ability (milestone M6): those of a static Ability, none otherwise. -/
def Ability.statics (ab : Ability) : List Static :=
  match ab.use with
  | .static ss => ss
  | _ => []

/-- Can the Ability be used by a Pokémon at `sp`? -/
def Ability.spotOk (ab : Ability) (sp : Spot) : Bool :=
  match ab.spot with
  | none => true
  | some s => decide (s = sp)

/-- The filters of an effect's zone moves out of a discard pile: what it can recycle to the hand
or the deck. (Attaching Energy or benching a Basic Pokémon from a discard pile moves an Energy or
a Pokémon card, which carries no Trainer amount.) A window on a discard pile (`Effect.look`,
milestone MV6) takes the whole pile off: with the other cards put back in the discard pile it
recycles what its filter admits; with them put anywhere else it may recycle any card (`Filter.any`).
A window on a deck or a hand recycles nothing. -/
def Effect.recFilters : Effect → List Filter
  | .move _ .discard _ f _ => [f]
  | .look _ .discard f _ _ rest => if rest = .discard then [f] else [.any]
  | .ite _ a b => a.recFilters ++ b.recFilters
  | .seq a b => a.recFilters ++ b.recFilters
  | .choice a b => a.recFilters ++ b.recFilters
  | .iter a => a.recFilters
  | _ => []

/-- **Does the Ability trigger on `ev`, for its Pokémon at `sp`?** (milestone M8b) A triggered
Ability of that event, whose place allows `sp` ("if this Pokémon is in the Active Spot and is
Knocked Out": `spot = some .active`), with no further printed condition (a trigger with a `cond`
never fires: conditions on a trigger, such as Adversity Policy's Weakness, are not expressible), and
whose effect is in the trigger fragment (`Effect.trigOk`; a trigger outside it never fires, which
under-models the card). Since milestone MV7 an event that can fire before the turn's attack
(`TrigEvent.late = false`: `oppBenched`, and since milestone MV7c `movedUp`, `movedDown`) also needs
an effect that recycles nothing
(`Effect.recFilters = []`): such a trigger can fire many times in one turn, and the store bound
(`StoreSafe`) keeps the discard piles' Item writers before the attack; a trigger of that event whose
effect recycles never fires (an under-model; no card of the census recycles, survey S20). -/
def Ability.trigOn (ev : TrigEvent) (sp : Spot) (ab : Ability) : Bool :=
  ab.use.event == some ev && ab.spotOk sp && ab.cond.isNone && (ab.script ev.place).trigOk &&
    (ev.late || (ab.script ev.place).recFilters.isEmpty)

/-- The rule box of a Pokémon card, as far as it decides how many Prize cards its Knock Out gives
(milestone M3; survey S8 C3, S9). The kinds are those of today's Standard (regulation marks H, I,
J): no rule box (1 Prize, "take one of your Prize cards", rulebook 2023 p. 7); Pokémon ex, Tera
Pokémon ex included ("Like other Pokémon ex, when a Tera Pokémon ex is Knocked Out, your opponent
takes 2 Prize cards", p. 24; printed "Pokémon ex rule: When your Pokémon ex is Knocked Out, your
opponent takes 2 Prize cards."); and Mega Evolution Pokémon ex ("Mega Evolution ex Rule: When
your Mega Evolution Pokémon ex is Knocked Out, your opponent takes 3 Prize cards.", printed on the
cards; the 2023 rulebook predates them, S9; the 2026 rulebook confirms it: "these Pokémon allow
your opponent to take three Prize cards when they are Knocked Out", 2026 p. 24, and "Mega Evolution
Pokémon ex are considered to be Pokémon ex", p. 24). In the card data every Standard card with the MEGA
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
  /-- the Abilities printed on the card (milestone M8a; in today's Standard at most one, survey
  S9: 316 of 1,860 Pokémon have exactly one) -/
  abilities : List Ability
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

/-- What a Pokémon Tool (or, since milestone MV8, a Special Energy card, `EnergyText.grant`) gives
the Pokémon it is attached to (milestone M5): attacks the Pokémon
can use ("The Pokémon this card is attached to can use the attack on this card. (You still need
the necessary Energy to use this attack.)", Technical Machine: Fluorite sv8-188, Mega Rayquaza Cap
me6-100) and activated Abilities, both only while the Pokémon's top card passes `holder` ("The Mega
Zygarde ex this card is attached to can use the attack on this card", Core Memory me3-70), and
(milestone M6) static effects in force while it is attached (`statics`: HP, damage and Retreat Cost
changes, "The Pokémon this card is attached to gets +100 HP", Hero's Cape), for the same holders;
`Sel.self` in them means the holder. Since milestone M8b triggered Tool text of the two
implemented shapes ("If the Pokémon this card is attached to is in the Active Spot and is damaged by
an attack …", "… is Knocked Out by damage from an attack …": Lucky Helmet, Punk Helmet, Deluxe Bomb,
Amulet of Hope) is a triggered Ability in `abilities` (`AbilityUse.triggered`), which the holder has
(`InPlay.abilities`); other triggered Tool text (Berries, Survival Brace, Powerglass, Prize changes)
is not modelled: a Tool with only such text is a Tool with an empty grant (`ToolGrant.none`), which
can be attached and does nothing (Known gaps in `Pokemon/Rules.lean`). -/
structure ToolGrant where
  holder : Filter
  attacks : List Attack
  abilities : List Ability
  statics : List Static := []
  deriving DecidableEq

/-- The empty grant: a Tool whose effect the model does not express, or that has none. -/
def ToolGrant.none : ToolGrant := ⟨.any, [], [], []⟩

/-- The condition under which a Special Energy card provides its alternative Energy (milestone MV8):
its holder's top card passes the filter, or the holder has another Special Energy card attached. -/
inductive ProvIf where
  | holder (f : Filter)
  | otherSpecial
  deriving DecidableEq

/-- **What a Special Energy card gives besides its Energy** (milestone MV8, survey S22): the payload
of `EnergyCard.special`. `grant` is what it gives the Pokémon it is attached to, by the Tool path
(`ToolGrant`: a holder filter, "the Grass Pokémon this card is attached to"; static effects in force
while it is attached, `ToolGrant.statics`, read by `SView.statics`; triggered Abilities the holder has,
`InPlay.abilities`). Several Energy cards can be attached to one Pokémon, and each card's grant is in
force (they add up, as printed: no Special Energy card of the pool limits its own stacking). The empty
payload (`{}`) is a card none of whose riders is modelled: `Card.inert`.

`alt` (stage 3) is provision that depends on the holder: "If this card is attached to a Basic Pokémon,
this card provides every type of Energy but provides only 1 Energy at a time" (Prism Energy) is
`some (.holder .basic, [every type])`; "If the Pokémon this card is attached to has any other Special
Energy attached, this card provides Colorless Energy instead" (Luminous Energy) is
`some (.otherSpecial, [[.colorless]])`; read by `EnergyCard.unitsAt`. `only` is the holder
restriction "This card can only be attached to a Team Rocket's Pokémon" (`.namePrefix "Team
Rocket's"`): every attachment of the card, from the hand or by an effect, and every move of it to
another Pokémon, needs the target's top card to pass it (`Card.attachOk`).

`rest` says that the printed card has a rider this payload does not model ("discard it at the end
of your turn", written beside Ignition Energy's expressible provision): such a card is
`Card.inert` whatever else the payload says, so a partial writing cannot pass for a complete one. -/
structure EnergyText where
  grant : ToolGrant := ToolGrant.none
  alt : Option (ProvIf × List (List EType)) := none
  only : Filter := .any
  rest : Bool := false
  deriving DecidableEq

/-- **The payload models something** (milestone MV8): a static effect, an Ability or an attack in
its grant, an alternative provision, or a holder restriction. A grant's holder filter alone models
nothing (it restricts a grant that gives nothing), and `rest` is not content. -/
def EnergyText.content (x : EnergyText) : Bool :=
  !x.grant.statics.isEmpty || !x.grant.abilities.isEmpty || !x.grant.attacks.isEmpty ||
    x.alt.isSome || x.only != .any

/-- **An Energy card** (milestone MV5): Basic (`basic t`) or Special (`special name prov text`). A
Special Energy card has its printed name, what it provides while attached, one entry per unit, each
entry the types that unit counts as ("provides Colorless Energy" is `[[.colorless]]`; "provides every
type of Energy but provides only 1 Energy at a time" is one unit of every type; Team Rocket's Energy,
"2 in any combination of Psychic Energy and Darkness Energy", is `[[.psychic, .darkness], [.psychic,
.darkness]]`), and (milestone MV8) a payload (`EnergyText`): what it gives its holder by the Tool path
(static effects, triggered Abilities, under a holder filter), provision that depends on the holder
and a holder restriction. A card whose payload models nothing (`EnergyText.content` false), or says
that a rider is not modelled (`EnergyText.rest`), is marked by `Card.inert` (an under-model of a
printed card with riders); otherwise it is not inert (`Card.inert_special`), and whether the payload
says all the printed card says is the importer's claim (survey S22 lists the cards whose every rider has a payload form).

Why a kind inside `Card.energy` and not a flag with a default or a new `Card` constructor: in Lean
v4.36.0 a pattern `.energy t` fills in an omitted default argument, so a defaulted flag would
silently narrow every existing match on `.energy _` to Basic Energy (S18 §A2); and a new `Card`
constructor would break the exhaustive matches of `PokemonCards/Props.lean`. With `EnergyCard`,
`.energy _` still matches every Energy card, and the generated `.energy .fire` still elaborates
(`EnergyCard.fire` is `basic .fire`).

Deck construction is not modelled: the rule that a deck may hold only 4 copies of a card with the
same name "except for Basic Energy cards" (rulebook 2026, PDF p. 21), which covers Special Energy,
and the ACE SPEC limit (Neo Upper, Legacy, Enriching Energy), are not checked anywhere. -/
inductive EnergyCard where
  | basic (t : BasicEnergy)
  | special (name : String) (prov : List (List EType)) (text : EnergyText)
  deriving DecidableEq

namespace EnergyCard
/-- The Basic Energy cards by type, so that `.energy .fire` denotes the Basic Fire Energy card. -/
@[match_pattern] abbrev grass : EnergyCard := .basic .grass
@[match_pattern] abbrev fire : EnergyCard := .basic .fire
@[match_pattern] abbrev water : EnergyCard := .basic .water
@[match_pattern] abbrev lightning : EnergyCard := .basic .lightning
@[match_pattern] abbrev psychic : EnergyCard := .basic .psychic
@[match_pattern] abbrev fighting : EnergyCard := .basic .fighting
@[match_pattern] abbrev darkness : EnergyCard := .basic .darkness
@[match_pattern] abbrev metal : EnergyCard := .basic .metal
@[match_pattern] abbrev fairy : EnergyCard := .basic .fairy
end EnergyCard

/-- The Energy one card provides while attached, one entry per unit, each entry the types that unit
counts as: one unit of its type for a Basic Energy card, `prov` for a Special Energy card. -/
def EnergyCard.units : EnergyCard → List (List EType)
  | .basic t => [[t.type]]
  | .special _ p _ => p

inductive Card where
  | pokemon (p : PokemonCard)
  /-- an Energy card: Basic (`BasicEnergy`: nine types, no Colorless or Dragon) or, since milestone
  MV5, Special (`EnergyCard`) -/
  | energy (t : EnergyCard)
  /-- an Item, Supporter or (milestone M5) Stadium card. For an Item or a Supporter, `effect` is
  what it does when played (`Move.item`, `Move.supporter`); for a Stadium it is what "Once during
  each player's turn, that player may …" lets the player to move do while the Stadium is in play
  (`Move.stadiumUse`), and `skip` for a Stadium with no such effect. `statics` (milestone M6) is
  a Stadium's static text, in force while it is in play (`Pokemon/Static.lean`); an Item or a
  Supporter is never in play, and its `statics` are never read (`[]`, the default, is what
  `Move.item` and `Move.supporter` play) -/
  | trainer (name : String) (kind : TrainerKind) (effect : Effect) (statics : List Static := [])
  /-- a Pokémon Tool card (milestone M5), attached to a Pokémon by `Move.tool` and `Move.toolBench`,
  with what it gives that Pokémon (`ToolGrant`) -/
  | tool (name : String) (grant : ToolGrant)
  deriving DecidableEq

/-- The attacks a card has (a Pokémon card) or gives the Pokémon it is attached to (a Tool,
milestone M5; `ToolGrant`). -/
def Card.attacks : Card → List Attack
  | .pokemon p => p.attacks
  | .tool _ gr => gr.attacks
  | .energy (.special _ _ x) => x.grant.attacks
  | _ => []

/-- The Abilities a card has (a Pokémon card) or gives the Pokémon it is attached to (a Tool,
milestone M5; `ToolGrant`). -/
def Card.abilities : Card → List Ability
  | .pokemon p => p.abilities
  | .tool _ gr => gr.abilities
  | .energy (.special _ _ x) => x.grant.abilities
  | _ => []

/-- The printed name of a Pokémon, Trainer, Tool or (milestone MV5) Special Energy card; none for
a Basic Energy card (milestone MV4, read by the name filters). -/
def Card.name? : Card → Option String
  | .pokemon p => some p.name
  | .trainer m _ _ _ => some m
  | .tool m _ => some m
  | .energy (.basic _) => none
  | .energy (.special m _ _) => some m

/-- The name filters (milestone MV4): does the card's printed name contain `x` (`sub`) or begin
with it? A Basic Energy card has no name the filters read. -/
def Filter.nameEval (sub : Bool) (x : String) (c : Card) : Bool :=
  match c.name? with
  | some n => if sub then nameContains x n else nameStarts x n
  | none => false

/-- Does the card pass the filter? -/
def Filter.eval : Filter → Card → Bool
  | .any, _ => true
  | .pokemon, .pokemon _ => true
  | .basic, .pokemon p => decide (p.stage = .basic)
  | .stage s, .pokemon p => decide (p.stage = s)
  | .ptype t, .pokemon p => decide (p.type = t)
  | .named n, .pokemon p => decide (p.name = n)
  | .named n, .trainer m _ _ _ => decide (m = n)
  | .named n, .tool m _ => decide (m = n)
  | .named n, .energy (.special m _ _) => decide (m = n)
  | .hpLe n, .pokemon p => decide (p.hp ≤ n)
  | .noRuleBox, .pokemon p => decide (p.ruleBox = .none)
  | .trainer, .trainer _ _ _ _ => true
  | .trainer, .tool _ _ => true
  | .kind k, .trainer _ k' _ _ => decide (k' = k)
  | .tool, .tool _ _ => true
  | .energy, .energy _ => true
  | .energyOf t, .energy (.basic e) => decide (e.type = t)
  | .basicEnergy, .energy (.basic _) => true
  | .specialEnergy, .energy (.special _ _ _) => true
  | .ex, .pokemon p => decide (p.ruleBox ≠ .none)
  | .tera, .pokemon p => p.tera
  | .hasAttack n, .pokemon p => p.attacks.any fun a => decide (a.name = n)
  | .hasAbility, .pokemon p => !p.abilities.isEmpty
  | .and a b, c => a.eval c && b.eval c
  | .or a b, c => a.eval c || b.eval c
  | .namePrefix x, c => Filter.nameEval false x c
  | .nameHas x, c => Filter.nameEval true x c
  | .not a, c => !a.eval c
  | _, _ => false

/-- The attacks a card attached to a Pokémon whose top card is `p` gives it (milestone M5): a
Tool's granted attacks, if `p` passes the grant's holder filter; nothing for other cards. -/
def Card.grantAttacks (p : PokemonCard) : Card → List Attack
  | .tool _ gr => if gr.holder.eval (.pokemon p) then gr.attacks else []
  | .energy (.special _ _ x) => if x.grant.holder.eval (.pokemon p) then x.grant.attacks else []
  | _ => []

/-- The Abilities a card attached to a Pokémon whose top card is `p` gives it (milestone M5), as
`Card.grantAttacks`. -/
def Card.grantAbilities (p : PokemonCard) : Card → List Ability
  | .tool _ gr => if gr.holder.eval (.pokemon p) then gr.abilities else []
  | .energy (.special _ _ x) => if x.grant.holder.eval (.pokemon p) then x.grant.abilities else []
  | _ => []

theorem Card.grantAttacks_sub {p : PokemonCard} {c : Card} {atk : Attack}
    (h : atk ∈ c.grantAttacks p) : atk ∈ c.attacks := by
  cases c with
  | tool n gr =>
      simp only [Card.grantAttacks] at h
      split at h
      · exact h
      · nomatch h
  | energy t =>
      cases t with
      | basic => nomatch h
      | special m pr x =>
          simp only [Card.grantAttacks] at h
          split at h
          · exact h
          · nomatch h
  | _ => nomatch h

theorem Card.grantAbilities_sub {p : PokemonCard} {c : Card} {ab : Ability}
    (h : ab ∈ c.grantAbilities p) : ab ∈ c.abilities := by
  cases c with
  | tool n gr =>
      simp only [Card.grantAbilities] at h
      split at h
      · exact h
      · nomatch h
  | energy t =>
      cases t with
      | basic => nomatch h
      | special m pr x =>
          simp only [Card.grantAbilities] at h
          split at h
          · exact h
          · nomatch h
  | _ => nomatch h

/-- **A Stadium or Tool that the model plays with no effect** (milestone M5): a Stadium whose
effect is `skip` and that has no static effect, or a Tool that gives nothing (no attack, no
Ability, no static effect). Such a card occupies the Stadium slot or a Pokémon's Tool place and
does nothing. An importer writes these terms for Stadiums and Tools whose printed text the model
does not express (triggered text outside the two shapes of milestone M8b and the event of milestone
MV7, and static text outside
the language of `Static`), so `Card.inert` tells "playable, effect not modelled" (an under-model of
the printed card) from "playable, effect expressed" (a Stadium with an activated or, since milestone
M6, a static effect; a Tool that gives an attack, an Ability or a static effect, and since milestone
M8b a triggered Ability: a Tool whose triggered text is expressed is not inert). A Special Energy
card (milestone MV5) is inert unless its payload models something (`EnergyText.content`: a static
effect, Ability or attack granted, an alternative provision, a holder restriction), and is inert
whenever the payload says a rider is not modelled (`EnergyText.rest`), milestone MV8,
`Card.inert_special`. An inert Special Energy card provides Energy and at most part of the rest of
its text is modelled, so an importer must refuse it or caveat it as "provides …; text not (fully)
modelled", unless the printed card has no other text. -/
def Card.inert : Card → Bool
  | .trainer _ .stadium e ss => e == .skip && ss.isEmpty
  | .tool _ gr => gr.attacks.isEmpty && gr.abilities.isEmpty && gr.statics.isEmpty
  | .energy (.special _ _ x) => x.rest || !x.content
  | _ => false

/-- **The static effects printed on a card** (milestone M6): a Pokémon card's static Abilities; a
Tool's static text and static Abilities; a Stadium's static text. Items and Supporters have none
(they are never in play). -/
def Card.statics : Card → List Static
  | .pokemon p => p.abilities.flatMap Ability.statics
  | .tool _ gr => gr.statics ++ gr.abilities.flatMap Ability.statics
  | .energy (.special _ _ x) => x.grant.statics ++ x.grant.abilities.flatMap Ability.statics
  | .trainer _ .stadium _ ss => ss
  | _ => []

/-- Is the card a Stadium? (milestone M5) -/
def Card.isStadium : Card → Bool
  | .trainer _ .stadium _ _ => true
  | _ => false

/-- The card gives no attack and no Ability as a Special Energy card (milestone MV8): true of every
card but a Special Energy card whose payload grants one. -/
def Card.energyGrantFree : Card → Bool
  | .energy (.special _ _ x) => x.grant.attacks.isEmpty && x.grant.abilities.isEmpty
  | _ => true

/-- Is the card a Pokémon Tool? (milestone M5) -/
def Card.isTool : Card → Bool
  | .tool _ _ => true
  | _ => false

/-- The Energy a card attached to a Pokémon provides, one entry per unit, each entry the types
that unit counts as (`EnergyCard.units`). A Basic Energy card provides one unit of its type; a
Special Energy card (milestone MV5) what its `prov` says, whatever Pokémon holds it (several units,
as Team Rocket's Energy's two, or one unit of several types, as "provides every type of Energy but
only 1 Energy at a time"; `Pays` matches units of several types). This is the printed provision;
what a card provides attached to a given holder, which since milestone MV8 may depend on the holder or
on the other attached cards, is `Card.unitsOn`.
Other cards provide nothing. -/
def Card.provides : Card → List (List EType)
  | .energy t => t.units
  | _ => []

/-- **What an Energy card provides attached to a Pokémon whose top card is `top` and whose attached
Energy cards are `att`** (milestone MV8): a Basic Energy card one unit of its type; a Special Energy
card its alternative provision (`EnergyText.alt`) when its condition holds (the holder passes the
filter; or another Special Energy card is attached, that is at least two among `att`, the card
itself included), and its printed provision otherwise. -/
def EnergyCard.unitsAt (top : PokemonCard) (att : List Card) : EnergyCard → List (List EType)
  | .basic t => [[t.type]]
  | .special _ p x =>
      match x.alt with
      | none => p
      | some (.holder f, u) => if f.eval (.pokemon top) then u else p
      | some (.otherSpecial, u) =>
          if Nat.ble 2 (att.countP Filter.specialEnergy.eval) then u else p

/-- **The Energy a card provides while attached** (milestone MV8): the units the card `c` provides
attached to a Pokémon whose top card is `top` and whose attached Energy cards are `att` (`c` among
them). Attack costs (`InPlay.units`, `Pays`), the Retreat Cost (`retreatPaid`), the counts of Energy
attached under `Filter.energy` (`Filter.weight`, `InPlay.energyCount`) and Energy discards
(`Qty.okE`) read it; the static amount `SAmt.perEnergy`, the static condition `Static.need` and the
card filters count cards instead (Known gaps). For a Basic Energy card it is one unit of its
type (`Card.unitsOn_basic`). -/
def Card.unitsOn (top : PokemonCard) (att : List Card) : Card → List (List EType)
  | .energy t => t.unitsAt top att
  | _ => []

/-- A Basic Energy card provides one unit of its type, wherever it is attached. -/
theorem Card.unitsOn_basic (top : PokemonCard) (att : List Card) (t : BasicEnergy) :
    Card.unitsOn top att (.energy (.basic t)) = [[t.type]] := rfl

/-- May the card be attached to a Pokémon whose top card is `top` (milestone MV8)? Every card but a
Special Energy card with a holder restriction (`EnergyText.only`) may. -/
def Card.attachOk (top : PokemonCard) : Card → Bool
  | .energy (.special _ _ x) => x.only.eval (.pokemon top)
  | _ => true

/-- **How many Energy an attached card counts for under the filter `f`** (milestone MV8), the card
providing the units `us`: "Energy" (`Filter.energy`: "for each Energy attached", "discard 2 Energy")
counts the units the card provides; every other filter is a card filter and counts the card once if
it passes ("Basic Energy card", "Special Energy card", a name, and `Filter.energyOf t`, which reads
Basic Energy only: Known gaps). With one-unit Basic Energy every case is the card count
(`Filter.weight_basic`).

The test is syntactic: only the constructor `Filter.energy` itself counts units. A filter that passes
the same cards but is written otherwise (`or energy energy`, `and energy any`) counts each card once
(`Units.weight_syntactic`); this is the form available for a count of cards ("for each Energy card
attached"), and an importer that writes it for printed "Energy" counts fewer than print for a card
that provides 2 (Known gaps). -/
def Filter.weight (f : Filter) (us : List (List EType)) (c : Card) : Nat :=
  match f with
  | .energy => us.length
  | _ => if f.eval c then 1 else 0

/-- `Filter.weight` for a card attached to a Pokémon whose top card is `top` and whose attached
Energy is `att`. -/
def Filter.weightOn (f : Filter) (top : PokemonCard) (att : List Card) (c : Card) : Nat :=
  f.weight (c.unitsOn top att) c

/-- A card that fails the filter weighs nothing: under `Filter.energy` it is not an Energy card,
and provides nothing. -/
theorem Filter.weightOn_of_eval {f : Filter} {top : PokemonCard} {att : List Card} {c : Card}
    (h : f.eval c = false) : f.weightOn top att c = 0 := by
  unfold Filter.weightOn Filter.weight Card.unitsOn
  split
  · cases c with
    | energy t => exact absurd h (by simp [Filter.eval])
    | _ => rfl
  · rw [h]; rfl

/-- **With Basic Energy the weights are the card counts**: a Basic Energy card weighs 1 under every
filter it passes. -/
theorem Filter.weight_basic (f : Filter) (top : PokemonCard) (att : List Card) (t : BasicEnergy) :
    f.weightOn top att (.energy (.basic t)) = if f.eval (.energy (.basic t)) then 1 else 0 := by
  unfold Filter.weightOn Filter.weight
  split
  · rfl
  · rfl

/-- **A Retreat Cost of `n` is paid by discarding cards that provide `us` units** (milestone MV8):
together they provide at least `n` Energy, and none of them is superfluous (without any one of them
the rest would provide fewer than `n`). With one-unit cards this is "exactly `n` cards"
(`retreatPaid_ones`); a card that provides 2 pays 2 symbols, and may be discarded for a cost of 1
when no smaller payment is chosen; a card that provides nothing can never be discarded. A reading of
"discard 1 Energy from your Active Pokémon for each [✱] listed in its Retreat Cost" (rulebook 2026
p. 12), Known gaps. -/
def retreatPaid (n : Nat) (us : List Nat) : Bool :=
  Nat.ble n us.sum && us.all fun u => Nat.blt (us.sum - u) n

/-- With one-unit cards, a Retreat Cost of `n` is paid by exactly `n` cards. -/
theorem retreatPaid_ones {n : Nat} {us : List Nat} (h : ∀ u ∈ us, u = 1) :
    retreatPaid n us = true ↔ us.length = n := by
  have hs : us.sum = us.length := by
    induction us with
    | nil => rfl
    | cons u us ih =>
        rw [List.sum_cons, List.length_cons, h u (.head _), ih fun v hv => h v (.tail _ hv)]
        exact Nat.add_comm _ _
  unfold retreatPaid
  rw [hs, Bool.and_eq_true, List.all_eq_true, Nat.ble_eq]
  constructor
  · rintro ⟨h1, h2⟩
    cases us with
    | nil => simp only [List.length_nil] at h1 ⊢; omega
    | cons u us =>
        have h3 := h2 u (.head _)
        rw [Nat.blt_eq, h u (.head _)] at h3
        simp only [List.length_cons] at h1 h3 ⊢
        omega
  · intro hl
    refine ⟨Nat.le_of_eq hl.symm, fun u hu => ?_⟩
    rw [h u hu, Nat.blt_eq]
    have : 0 < us.length := List.length_pos_of_mem hu
    omega

/-- A cost of 0 is paid by discarding nothing, and nothing pays a positive cost. -/
theorem retreatPaid_nil (n : Nat) : retreatPaid n [] = true ↔ n = 0 := by
  simp only [retreatPaid, List.sum_nil, List.all_nil, Bool.and_true, Nat.ble_eq]
  exact Nat.le_zero

/-- The units paid cover the cost. -/
theorem retreatPaid_le {n : Nat} {us : List Nat} (h : retreatPaid n us = true) : n ≤ us.sum := by
  unfold retreatPaid at h
  rw [Bool.and_eq_true, Nat.ble_eq] at h
  exact h.1

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
(`Pokemon/Lingering.lean` shows that each of the two breaks the cap); since milestone MV6 also no
step-2 penalty (`Mod.weaken`, a subtraction like the reduction) and no step-5 increase
(`Mod.expose`), the modifiers that are not `Mod.plain`. -/
def Effect.tame : Effect → Bool
  | .linger _ _ m => m.plain
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

/-- The largest test constant of a list of effects. -/
def effectsTmax : List Effect → Nat
  | [] => 0
  | e :: es => max e.tmax (effectsTmax es)

/-- The largest test constant of an Ability: its condition's and its effects'. -/
def Ability.tmax (ab : Ability) : Nat :=
  max (match ab.cond with | some t => t.bound | none => 0) (effectsTmax ab.scripts)

/-- The largest test constant over a list of Abilities. -/
def abilitiesTmax : List Ability → Nat
  | [] => 0
  | a :: as => max a.tmax (abilitiesTmax as)

def abilitiesTame : List Ability → Bool
  | [] => true
  | a :: as => (a.scripts.all fun e => e.tame) && abilitiesTame as

def Card.tmax : Card → Nat
  | .pokemon p => max (attacksTmax p.attacks) (abilitiesTmax p.abilities)
  | .energy (.basic _) => 0
  | .energy (.special _ _ x) => max (attacksTmax x.grant.attacks) (abilitiesTmax x.grant.abilities)
  | .trainer _ _ e _ => e.tmax
  | .tool _ gr => max (attacksTmax gr.attacks) (abilitiesTmax gr.abilities)

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
  | .pokemon p => attacksTame p.attacks && abilitiesTame p.abilities
  | .energy (.basic _) => true
  | .energy (.special _ _ x) => attacksTame x.grant.attacks && abilitiesTame x.grant.abilities
  | .trainer _ _ e _ => e.tame
  | .tool _ gr => attacksTame gr.attacks && abilitiesTame gr.abilities

end Pokemon
