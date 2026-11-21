import Pokemon.Card

/-!
# Game state

The state inventory follows `survey/S2-rules-state-space.md`. Every component is either a
list of cards, a number of damage counters, or a flag. There is deliberately no turn
counter: card text reads the turn number only as "first turn".
-/

namespace Pokemon

/-- The three mutually exclusive Special Conditions (they rotate the card). -/
inductive Rot where
  | none | asleep | confused | paralyzed

/-- An Asleep or Paralyzed Pokémon can neither attack nor retreat. -/
def Rot.canAct : Rot → Bool
  | .asleep => false
  | .paralyzed => false
  | _ => true

/-- A Pokémon in play, with everything attached to it. -/
structure InPlay where
  top : PokemonCard
  /-- earlier Stages beneath the top card -/
  under : List Card
  energy : List Card
  tools : List Card
  /-- damage counters on this Pokémon -/
  damage : Nat
  rot : Rot
  poisoned : Bool
  burned : Bool
  /-- extra damage counters Poison places at each Checkup, beyond the ordinary one; raised by
  `Effect.poisonUp`, cleared with the Poisoned condition. Not bounded by any rule. -/
  poisonUp : Nat
  /-- put into play or evolved this turn -/
  fresh : Bool

namespace InPlay

/-- Number of physical cards making up this Pokémon. -/
def cards (p : InPlay) : Nat := 1 + p.under.length + p.energy.length + p.tools.length

/-- The physical cards making up this Pokémon, as they go to the discard pile. -/
def cardList (p : InPlay) : List Card := Card.pokemon p.top :: (p.under ++ p.energy ++ p.tools)

/-- A Basic Pokémon just put into play. -/
def ofBasic (p : PokemonCard) : InPlay :=
  { top := p, under := [], energy := [], tools := [], damage := 0,
    rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true }

def unfresh (p : InPlay) : InPlay := { p with fresh := false }

/-- Apply a Special Condition. A new Asleep, Confused or Paralyzed replaces the old one.
Poisoning an already Poisoned Pokémon keeps its `poisonUp`. -/
def inflict : Condition → InPlay → InPlay
  | .poisoned, p => { p with poisoned := true }
  | .burned, p => { p with burned := true }
  | .asleep, p => { p with rot := .asleep }
  | .confused, p => { p with rot := .confused }
  | .paralyzed, p => { p with rot := .paralyzed }

/-- Pokémon Checkup on one Active Pokémon (`S2`, `S4`: Poisoned, then Burned, then Asleep, then
Paralyzed). Poison places `1 + poisonUp` damage counters. Burn places 2, then a coin flip
(`burnHeads`) cures it on heads. Sleep is cured on heads (`sleepHeads`). Paralysis ends at the
Checkup after its owner's turn (`ownersTurnEnded`). Knock Outs are checked afterwards, by the
Knock Out moves; Confusion has no Checkup step. -/
def checkup (ownersTurnEnded burnHeads sleepHeads : Bool) (p : InPlay) : InPlay :=
  { p with
    damage := p.damage + (if p.poisoned then 1 + p.poisonUp else 0) + (if p.burned then 2 else 0),
    burned := p.burned && !burnHeads,
    rot := match p.rot with
      | .asleep => if sleepHeads then .none else .asleep
      | .paralyzed => if ownersTurnEnded then .none else .paralyzed
      | r => r }

/-- Recover from all Special Conditions (also what moving to the Bench or evolving does). -/
def cure (p : InPlay) : InPlay :=
  { p with rot := .none, poisoned := false, burned := false, poisonUp := 0 }

/-- Is this Pokémon affected by the Special Condition `c`? -/
def has : Condition → InPlay → Bool
  | .poisoned, p => p.poisoned
  | .burned, p => p.burned
  | .asleep, p => match p.rot with | .asleep => true | _ => false
  | .confused, p => match p.rot with | .confused => true | _ => false
  | .paralyzed, p => match p.rot with | .paralyzed => true | _ => false

end InPlay

/-- Whose Active Pokémon the test reads. -/
def Test.whose : Test → Whose
  | .atLeast w _ => w
  | .exactly w _ => w
  | .cond w _ => w

/-- The value of a test on the Active Pokémon it reads. -/
def Test.eval : Test → InPlay → Bool
  | .atLeast _ n, p => Nat.ble n p.damage
  | .exactly _ n, p => Nat.beq p.damage n
  | .cond _ c, p => p.has c

def optCards : Option InPlay → Nat
  | none => 0
  | some p => p.cards

def benchCards : List InPlay → Nat
  | [] => 0
  | p :: ps => p.cards + benchCards ps

def stadiumCards : Option Card → Nat
  | none => 0
  | some _ => 1

/-- The physical cards of an optional Pokémon in play. -/
def optCardList : Option InPlay → List Card
  | none => []
  | some p => p.cardList

/-- The physical cards of a Bench, Pokémon by Pokémon. -/
def benchCardList : List InPlay → List Card
  | [] => []
  | p :: ps => p.cardList ++ benchCardList ps

def stadiumCardList : Option Card → List Card
  | none => []
  | some c => [c]

structure PlayerState where
  /-- head of the list is the top of the deck -/
  deck : List Card
  hand : List Card
  discard : List Card
  prizes : List Card
  lost : List Card
  active : Option InPlay
  bench : List InPlay
  /-- the Stadium this player has in play, if any -/
  stadium : Option Card
  energyAttached : Bool
  supporterPlayed : Bool
  retreated : Bool
  /-- once-per-game flags (GX attack, VSTAR Power) -/
  gxUsed : Bool
  vstarUsed : Bool

namespace PlayerState

/-- Number of physical cards this player owns, over all zones. -/
def cards (s : PlayerState) : Nat :=
  s.deck.length + s.hand.length + s.discard.length + s.prizes.length + s.lost.length
    + optCards s.active + benchCards s.bench + stadiumCards s.stadium

/-- Every physical card this player owns, over all zones: deck, hand, discard pile, Prizes,
Lost Zone, the Active Pokémon and each Benched Pokémon (top card, the cards under it,
attached Energy and Tools), and the Stadium. -/
def allCards (s : PlayerState) : List Card :=
  s.deck ++ s.hand ++ s.discard ++ s.prizes ++ s.lost
    ++ optCardList s.active ++ benchCardList s.bench ++ stadiumCardList s.stadium

def unfresh (s : PlayerState) : PlayerState :=
  { s with active := s.active.map InPlay.unfresh, bench := s.bench.map InPlay.unfresh }

end PlayerState

/-- Whole-game state. `cur` is the player to move; the two swap at end of turn. -/
structure GameState where
  cur : PlayerState
  opp : PlayerState
  /-- is the player to move the one who went first? -/
  curIsFirst : Bool
  /-- is this the first turn of the game? -/
  firstTurn : Bool
  /-- has the player to move attacked this turn? -/
  attacked : Bool
  /-- between turns: Pokémon Checkup has been applied and its Knock Outs are being resolved;
  the player to move has not yet drawn for the turn -/
  between : Bool
  /-- `some b`: the game is over, won by the first player iff `b` -/
  winner : Option Bool

/-- The Active Pokémon of the player to move (`own`) or of the opponent (`opp`). -/
def GameState.activeOf : Whose → GameState → Option InPlay
  | .own, g => g.cur.active
  | .opp, g => g.opp.active

def GameState.cards (g : GameState) : Nat := g.cur.cards + g.opp.cards

/-- Every physical card in the game, in both players' zones. -/
def GameState.allCards (g : GameState) : List Card := g.cur.allCards ++ g.opp.allCards

def benchLimit : Nat := 5

end Pokemon
