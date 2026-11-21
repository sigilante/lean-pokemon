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
  /-- the attack does `n` damage to the opponent's Active Pokémon: `n` plus the player's damage
  bonus, minus the opponent's damage reduction, or nothing if the opponent has damage
  prevention (`GameState.dealt`) -/
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
  /-- base damage, in counters -/
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
  deriving DecidableEq

inductive TrainerKind where
  | item | supporter | stadium | tool
  deriving DecidableEq

inductive Card where
  | pokemon (p : PokemonCard)
  | energy (t : EType)
  | trainer (name : String) (kind : TrainerKind) (effect : Effect)
  deriving DecidableEq

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
