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

/-- The markers on one Pokémon in play (`survey/S7-load-bearing-spec.md` §3).

Modelling assumption (markers as flags). Printed Imprison and Shock-wave markers have no cap:
the cards place one at a time, and nothing limits how many a Pokémon carries. The model keeps
only whether a Pokémon has any. This is exact for the printed cards: the only reads are "has
any Imprison markers" (Gardevoir ex δ) and "has any Shock-wave markers" (Tyranitar ex δ), and
the only removal takes them all (Tropius δ), so the map from a count to "count > 0" commutes
with placing, removing and reading. A card that counted these markers, or removed one at a
time, would break it; none was found in the English card data. Lightning Rod has a printed cap
of one and Char is placed only on a Pokémon without one, so flags are exact for them too.
The Coloring counter (Smeargle basep-32) is a type, not a flag: placing one removes the old
one, and the Pokémon is of the chosen type while the counter is on it.

Fate of markers (a rule choice; card text is silent except for Char, whose text says it stays
while the Pokémon is in play): every marker stays on its Pokémon through evolution, retreat and
promotion, and leaves play with it (a Knocked Out Pokémon's `InPlay` record is discarded). -/
structure Marks where
  imprison : Bool
  shockwave : Bool
  lightningRod : Bool
  char : Bool
  /-- the type set by a Coloring counter, if the Pokémon has one -/
  coloring : Option EType
  deriving DecidableEq

namespace Marks

/-- No markers. -/
def empty : Marks := ⟨false, false, false, false, none⟩

/-- Does the Pokémon have the marker `m`? -/
def get : Marker → Marks → Bool
  | .imprison, k => k.imprison
  | .shockwave, k => k.shockwave
  | .lightningRod, k => k.lightningRod
  | .char, k => k.char

/-- Put (`b = true`) or remove (`b = false`) the marker `m`. -/
def set (m : Marker) (b : Bool) (k : Marks) : Marks :=
  match m with
  | .imprison => { k with imprison := b }
  | .shockwave => { k with shockwave := b }
  | .lightningRod => { k with lightningRod := b }
  | .char => { k with char := b }

end Marks

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
  `Effect.poisonUp`, cleared with the Poisoned condition and reset to 0 by a new Poison
  (`InPlay.inflict`). Not bounded by any rule. -/
  poisonUp : Nat
  /-- put into play or evolved this turn -/
  fresh : Bool
  /-- markers (Imprison, Shock-wave, Lightning Rod, Char) and the Coloring counter -/
  marks : Marks

namespace InPlay

/-- Number of physical cards making up this Pokémon. -/
def cards (p : InPlay) : Nat := 1 + p.under.length + p.energy.length + p.tools.length

/-- The physical cards making up this Pokémon, as they go to the discard pile. -/
def cardList (p : InPlay) : List Card := Card.pokemon p.top :: (p.under ++ p.energy ++ p.tools)

/-- A Basic Pokémon just put into play. -/
def ofBasic (p : PokemonCard) : InPlay :=
  { top := p, under := [], energy := [], tools := [], damage := 0,
    rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true,
    marks := Marks.empty }

def unfresh (p : InPlay) : InPlay := { p with fresh := false }

/-- Change the markers. -/
def setMarks (f : Marks → Marks) (p : InPlay) : InPlay := { p with marks := f p.marks }

/-- The Pokémon's type: the one its Coloring counter set, or else its top card's. -/
def type (p : InPlay) : EType := p.marks.coloring.getD p.top.type

/-- Apply a Special Condition. A new Asleep, Confused or Paralyzed replaces the old one. A new
Poison replaces the old one: "A Pokémon cannot have two Poison markers; if an attack gives it
another Poison marker, the new Poisoned Condition simply replaces the old one" (rulebook 2023,
p. 16; the same in the 2024 rulebook, survey S8 G7), so poisoning resets the Poison strength
`poisonUp` to that of a plain Poison (0 extra counters). Burn has the same rule; a Burn carries
no strength here, so re-burning changes nothing. -/
def inflict : Condition → InPlay → InPlay
  | .poisoned, p => { p with poisoned := true, poisonUp := 0 }
  | .burned, p => { p with burned := true }
  | .asleep, p => { p with rot := .asleep }
  | .confused, p => { p with rot := .confused }
  | .paralyzed, p => { p with rot := .paralyzed }

/-- Pokémon Checkup on one Active Pokémon (`S2`, `S4`: Poisoned, then Burned, then Asleep, then
Paralyzed). Poison places `1 + poisonUp` damage counters. Burn places 2, then a coin flip
(`burnHeads`) cures it on heads. Sleep is cured on heads (`sleepHeads`). Paralysis ends at the
Checkup after its owner's turn (`ownersTurnEnded`). A Char counter makes the opponent flip a
coin after every turn and puts 2 damage counters on its Pokémon on tails (`charTails`; Quilava
neo1-47). Knock Outs are checked afterwards, by the Knock Out moves; Confusion has no Checkup
step. -/
def checkup (ownersTurnEnded burnHeads sleepHeads charTails : Bool) (p : InPlay) : InPlay :=
  { p with
    damage := p.damage + (if p.poisoned then 1 + p.poisonUp else 0) + (if p.burned then 2 else 0)
      + (if p.marks.char && charTails then 2 else 0),
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
  | .marked w _ => w
  | .isType w _ => w

/-- The value of a test on the Active Pokémon it reads. -/
def Test.eval : Test → InPlay → Bool
  | .atLeast _ n, p => Nat.ble n p.damage
  | .exactly _ n, p => Nat.beq p.damage n
  | .cond _ c, p => p.has c
  | .marked _ m, p => p.marks.get m
  | .isType _ t, p => decide (p.type = t)

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

/-- The lingering modifiers on one player for one turn (or for the rest of the game). -/
structure Mods where
  bonus : Nat
  reduce : Nat
  prevent : Bool
  noAttack : Bool
  noRetreat : Bool
  noItem : Bool
  deriving DecidableEq

namespace Mods

def empty : Mods := ⟨0, 0, false, false, false, false⟩

/-- Two sets of modifiers in effect together: amounts add, flags combine. -/
def merge (a b : Mods) : Mods :=
  ⟨a.bonus + b.bonus, a.reduce + b.reduce, a.prevent || b.prevent, a.noAttack || b.noAttack,
    a.noRetreat || b.noRetreat, a.noItem || b.noItem⟩

/-- Add one modifier. -/
def addMod : Mod → Mods → Mods
  | .bonus n, m => { m with bonus := m.bonus + n }
  | .reduce n, m => { m with reduce := m.reduce + n }
  | .prevent, m => { m with prevent := true }
  | .lock .attack, m => { m with noAttack := true }
  | .lock .retreat, m => { m with noRetreat := true }
  | .lock .item, m => { m with noItem := true }

end Mods

/-- A player's lingering modifiers, by the turn in which they are in effect (`Slot`). -/
structure Store where
  now : Mods
  next : Mods
  after : Mods
  always : Mods
  deriving DecidableEq

namespace Store

def empty : Store := ⟨Mods.empty, Mods.empty, Mods.empty, Mods.empty⟩

/-- Add the modifier `m` for the turns `s`. -/
def add (s : Slot) (m : Mod) (t : Store) : Store :=
  match s with
  | .now => { t with now := t.now.addMod m }
  | .next => { t with next := t.next.addMod m }
  | .after => { t with after := t.after.addMod m }
  | .always => { t with always := t.always.addMod m }

/-- The modifiers in effect in the current turn. -/
def live (t : Store) : Mods := t.now.merge t.always

/-- The end of a turn: this turn's modifiers expire, and the others move one turn closer. -/
def shift (t : Store) : Store := ⟨t.next, t.after, Mods.empty, t.always⟩

end Store

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
  /-- lingering modifiers on this player (`Store`); shifted at the end of every turn -/
  mods : Store

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

/-- The damage an attack of base `n` does to the opponent's Active Pokémon: nothing if the
opponent has damage prevention in effect; otherwise `n` plus the player's damage bonus minus the
opponent's damage reduction (at least 0). Weakness and Resistance are absent. -/
def dealtBy (n : Nat) (own opp : Store) : Nat :=
  if opp.live.prevent then 0 else (n + own.live.bonus) - opp.live.reduce

@[inherit_doc dealtBy]
def GameState.dealt (n : Nat) (g : GameState) : Nat := dealtBy n g.cur.mods g.opp.mods

/-- The player to move (`own`) or the opponent (`opp`). -/
def GameState.side : Whose → GameState → PlayerState
  | .own, g => g.cur
  | .opp, g => g.opp

/-- Change the state of the player to move (`own`) or of the opponent (`opp`). -/
def GameState.updSide : Whose → (PlayerState → PlayerState) → GameState → GameState
  | .own, f, g => { g with cur := f g.cur }
  | .opp, f, g => { g with opp := f g.opp }

def GameState.cards (g : GameState) : Nat := g.cur.cards + g.opp.cards

/-- Every physical card in the game, in both players' zones. -/
def GameState.allCards (g : GameState) : List Card := g.cur.allCards ++ g.opp.allCards

def benchLimit : Nat := 5

end Pokemon
