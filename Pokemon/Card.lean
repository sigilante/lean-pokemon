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

/-- A test an effect can make on one Active Pokémon. -/
inductive Test where
  /-- it has at least `n` damage counters ("if it has any damage counters" is `atLeast w 1`;
  "if it has no damage counters" is the `else` branch of that test) -/
  | atLeast (w : Whose) (n : Nat)
  /-- it has exactly `n` damage counters (Mega Absol ex, me1-86) -/
  | exactly (w : Whose) (n : Nat)
  /-- it is affected by the Special Condition `c` -/
  | cond (w : Whose) (c : Condition)
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
  effect can be applied more than once") -/
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
  | seq (a b : Effect)
  | choice (a b : Effect)
  | iter (a : Effect)
  deriving DecidableEq

structure Attack where
  name : String
  cost : List EType
  /-- base damage, in counters -/
  damage : Nat
  effect : Effect
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
  deriving DecidableEq

inductive TrainerKind where
  | item | supporter | stadium | tool
  deriving DecidableEq

inductive Card where
  | pokemon (p : PokemonCard)
  | energy (t : EType)
  | trainer (name : String) (kind : TrainerKind) (effect : Effect)
  deriving DecidableEq

end Pokemon
