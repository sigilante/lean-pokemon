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
    rot := .none, poisoned := false, burned := false, fresh := true }

def unfresh (p : InPlay) : InPlay := { p with fresh := false }

end InPlay

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
  /-- `some b`: the game is over, won by the first player iff `b` -/
  winner : Option Bool

def GameState.cards (g : GameState) : Nat := g.cur.cards + g.opp.cards

/-- Every physical card in the game, in both players' zones. -/
def GameState.allCards (g : GameState) : List Card := g.cur.allCards ++ g.opp.allCards

def benchLimit : Nat := 5

end Pokemon
