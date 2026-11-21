import Pokemon.Card

/-!
# Game state

The state inventory follows `survey/S2-rules-state-space.md`. Every component is either a
list of cards, a number of damage counters, or a flag. There is deliberately no turn
counter: card text reads the turn number only as "first turn", which two flags record (the
first turn of the game, `GameState.firstTurn`, and each player's first turn,
`PlayerState.hadTurn`).
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
  /-- has used an Ability this turn (milestone M8a): set by `Move.ability`, read by the "once
  during your turn" limit (`AbilityUse.once`), cleared at the end of its owner's turn
  (`InPlay.unfresh`) and by evolution (the evolved Pokémon has the new card's Abilities, unused).
  One flag per Pokémon: exact for cards with at most one Ability, which is every Standard card
  (survey S9); for a card with two once-per-turn Abilities the flag would let only one be used. -/
  used : Bool
  /-- moved from its owner's Bench to the Active Spot during its owner's current turn (milestone
  MV2: "If this Pokémon moved from your Bench to the Active Spot this turn", Keldeo ex
  rsv10pt5-30): set by retreat and by `Effect.switch .own` (`InPlay.moveUp`, `Whose.mover`), that
  is by the owner in the owner's turn, and cleared at the end of the owner's turn (`InPlay.unfresh`).
  A switch made by the opponent (`switch .opp`, in the opponent's turn) and a promotion after a Knock
  Out set nothing: exact for promotions between turns and in the opponent's turn, which are not moves
  in the owner's turn; a promotion after a Knock Out of the player's own Active Pokémon in their own
  turn (by an Item or an Ability) is a move the printed card counts and the model does not (Known
  gaps) -/
  movedUp : Bool

namespace InPlay

/-- Number of physical cards making up this Pokémon. -/
def cards (p : InPlay) : Nat := 1 + p.under.length + p.energy.length + p.tools.length

/-- The physical cards making up this Pokémon, as they go to the discard pile. -/
def cardList (p : InPlay) : List Card := Card.pokemon p.top :: (p.under ++ p.energy ++ p.tools)

/-- The attacks this Pokémon can use (milestone M5): its top card's, and those its Tools give it
(`Card.grantAttacks`: "The Pokémon this card is attached to can use the attack on this card"). -/
def attacks (p : InPlay) : List Attack := p.top.attacks ++ p.tools.flatMap (Card.grantAttacks p.top)

/-- The Abilities this Pokémon has (milestone M5): its top card's, and those its Tools give it
(`Card.grantAbilities`). -/
def abilities (p : InPlay) : List Ability :=
  p.top.abilities ++ p.tools.flatMap (Card.grantAbilities p.top)

/-- An attack this Pokémon can use is on one of its cards: the top card, or an attached Tool. -/
theorem attack_mem {p : InPlay} {atk : Attack} (h : atk ∈ p.attacks) :
    ∃ c ∈ p.cardList, atk ∈ c.attacks := by
  rcases List.mem_append.1 h with h | h
  · exact ⟨.pokemon p.top, .head _, h⟩
  · obtain ⟨c, hc, hm⟩ := List.mem_flatMap.1 h
    exact ⟨c, .tail _ (List.mem_append_right _ hc), Card.grantAttacks_sub hm⟩

/-- An Ability this Pokémon has is on one of its cards: the top card, or an attached Tool. -/
theorem ability_mem {p : InPlay} {ab : Ability} (h : ab ∈ p.abilities) :
    ∃ c ∈ p.cardList, ab ∈ c.abilities := by
  rcases List.mem_append.1 h with h | h
  · exact ⟨.pokemon p.top, .head _, h⟩
  · obtain ⟨c, hc, hm⟩ := List.mem_flatMap.1 h
    exact ⟨c, .tail _ (List.mem_append_right _ hc), Card.grantAbilities_sub hm⟩

/-- A Pokémon with no Tool attached has its top card's attacks and Abilities. -/
theorem attacks_of_noTool {p : InPlay} (h : ∀ c ∈ p.tools, c.isTool = false) :
    p.attacks = p.top.attacks ∧ p.abilities = p.top.abilities := by
  have e1 : ∀ l : List Card, (∀ c ∈ l, c.isTool = false) →
      l.flatMap (Card.grantAttacks p.top) = [] := by
    intro l hl
    induction l with
    | nil => rfl
    | cons c cs ih =>
        have hc := hl c (.head _)
        rw [List.flatMap_cons, ih (fun x hx => hl x (.tail _ hx)), List.append_nil]
        cases c with
        | tool n gr => cases hc
        | _ => rfl
  have e2 : ∀ l : List Card, (∀ c ∈ l, c.isTool = false) →
      l.flatMap (Card.grantAbilities p.top) = [] := by
    intro l hl
    induction l with
    | nil => rfl
    | cons c cs ih =>
        have hc := hl c (.head _)
        rw [List.flatMap_cons, ih (fun x hx => hl x (.tail _ hx)), List.append_nil]
        cases c with
        | tool n gr => cases hc
        | _ => rfl
  exact ⟨by simp only [attacks, e1 _ h, List.append_nil],
    by simp only [abilities, e2 _ h, List.append_nil]⟩

/-- A Basic Pokémon just put into play. -/
def ofBasic (p : PokemonCard) : InPlay :=
  { top := p, under := [], energy := [], tools := [], damage := 0,
    rot := .none, poisoned := false, burned := false, poisonUp := 0, fresh := true,
    marks := Marks.empty, used := false, movedUp := false }

/-- The end of its owner's turn for a Pokémon in play: it is no longer one put into play or evolved
this turn, (milestone M8a) it has not used an Ability this turn, and (milestone MV2) it has not
moved to the Active Spot this turn. -/
def unfresh (p : InPlay) : InPlay := { p with fresh := false, used := false, movedUp := false }

/-- The Pokémon moves from the Bench to the Active Spot (milestone MV2). -/
def moveUp (p : InPlay) : InPlay := { p with movedUp := true }

theorem cardList_moveUp (p : InPlay) : p.moveUp.cardList = p.cardList := rfl

/-- The Pokémon moved by a switch of the `w` player's Active Pokémon (milestone MV2): marked as moved
when the switch is the player's own (`own`), unmarked when it is made on the opponent's Pokémon,
in a turn that is not theirs. -/
def _root_.Pokemon.Whose.mover : Whose → InPlay → InPlay
  | .own => moveUp
  | .opp => id

/-- Record that the Pokémon has used an Ability this turn (milestone M8a). -/
def markUsed (p : InPlay) : InPlay := { p with used := true }

/-- The units of Energy attached to this Pokémon (`Card.provides`), which pay attack costs
(`Pays`). -/
def units (p : InPlay) : List (List EType) := p.energy.flatMap Card.provides

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
neo1-47). Knock Outs are checked afterwards, by the batch Knock Out step; Confusion has no Checkup
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
  | .countGe _ _ => .own
  | .top w _ => w
  | .hasTool w => w
  | .movedUp w => w
  | .evolved w => w

def optCards : Option InPlay → Nat
  | none => 0
  | some p => p.cards

def benchCards : List InPlay → Nat
  | [] => 0
  | p :: ps => p.cards + benchCards ps

/-- The number of cards in the Stadium slot. -/
def stadiumCards : Option (Bool × Card) → Nat
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

/-- The card in the Stadium slot, if any. -/
def stadiumCardList : Option (Bool × Card) → List Card
  | none => []
  | some (_, c) => [c]

/-- The card in the Stadium slot if its owner is `me` (milestone M5): what goes to that player's
discard pile when the Stadium leaves play. -/
def stadiumTo (me : Bool) : Option (Bool × Card) → List Card
  | none => []
  | some (o, c) => if o = me then [c] else []

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

/-- **Knock Out history of one player** (milestone MV2): whether any of the player's Pokémon was
Knocked Out during the current turn (`now`), and by the Knock Out check after an attack
(`nowAtk`), and the same for the previous turn (`last`, `lastAtk`). Four flags: the record takes 16
values, and nothing is counted. Set by the batch Knock Out step outside Pokémon Checkup
(`GameState.koStep`, `KOHist.note`), shifted at the end of every turn (`KOHist.shift`). Read by
`Count.koLast`: "If any of your Pokémon were Knocked Out [by damage from an attack] during your
opponent's last turn" (Iron Leaves sv6-19, Hassel sv6-151), made in the player's own turn, when
`last` is the opponent's turn just ended. -/
structure KOHist where
  now : Bool
  nowAtk : Bool
  last : Bool
  lastAtk : Bool
  deriving DecidableEq

namespace KOHist

def empty : KOHist := ⟨false, false, false, false⟩

/-- The end of a turn: this turn becomes the last one. -/
def shift (h : KOHist) : KOHist := ⟨false, false, h.now, h.nowAtk⟩

/-- Record a Knock Out of one of the player's Pokémon (`ko`), after an attack if `atk`. -/
def note (ko atk : Bool) (h : KOHist) : KOHist :=
  { h with now := h.now || ko, nowAtk := h.nowAtk || (ko && atk) }

end KOHist

structure PlayerState where
  /-- head of the list is the top of the deck -/
  deck : List Card
  hand : List Card
  discard : List Card
  prizes : List Card
  lost : List Card
  active : Option InPlay
  bench : List InPlay
  energyAttached : Bool
  supporterPlayed : Bool
  retreated : Bool
  /-- once-per-game flags (GX attack, VSTAR Power) -/
  gxUsed : Bool
  vstarUsed : Bool
  /-- lingering modifiers on this player (`Store`); shifted at the end of every turn -/
  mods : Store
  /-- has this player finished a turn of their own? `false` during the player's first turn,
  set by `Move.endTurn` when that turn ends. Read by the evolution ban: "neither player can
  evolve a Pokémon on that player's first turn" (rulebook 2023 p. 11). -/
  hadTurn : Bool
  /-- the Knock Out history of this player (milestone MV2, `KOHist`) -/
  ko : KOHist

namespace PlayerState

/-- Number of physical cards this player owns, over all zones. -/
def cards (s : PlayerState) : Nat :=
  s.deck.length + s.hand.length + s.discard.length + s.prizes.length + s.lost.length
    + optCards s.active + benchCards s.bench

/-- Every physical card this player owns, over all zones except the Stadium slot (which both
players share, `GameState.stadium`): deck, hand, discard pile, Prizes, Lost Zone, the Active
Pokémon and each Benched Pokémon (top card, the cards under it, attached Energy and Tools). -/
def allCards (s : PlayerState) : List Card :=
  s.deck ++ s.hand ++ s.discard ++ s.prizes ++ s.lost
    ++ optCardList s.active ++ benchCardList s.bench

/-- Record in the player's Knock Out history whether one of their Pokémon was Knocked Out (`ko`),
after an attack if `atk` (milestone MV2). -/
def noteKO (ko atk : Bool) (s : PlayerState) : PlayerState := { s with ko := s.ko.note ko atk }

def unfresh (s : PlayerState) : PlayerState :=
  { s with active := s.active.map InPlay.unfresh, bench := s.bench.map InPlay.unfresh }

/-- Take `n` Prize cards, the top ones, into the hand ("That player's opponent takes 1 of their
own Prize cards and puts it into their hand", rulebook 2023 p. 14; "or 2 Prize cards, for certain
kinds of Pokémon such as Pokémon ex", glossary p. 40). With fewer than `n` left, all are taken
(the player has then taken their last Prize card and wins, `PlayerState.prizesOut`). The
rulebook lets the player choose which Prize cards to take; the model takes the top ones (a
finite choice; Known gaps). -/
def takePrizes (n : Nat) (s : PlayerState) : PlayerState :=
  { s with prizes := s.prizes.drop n, hand := s.prizes.take n ++ s.hand }

/-- Taking `n` Prize cards leaves none: the player has taken their last Prize card. -/
def prizesOut (n : Nat) (s : PlayerState) : Bool := (s.prizes.drop n).isEmpty

end PlayerState

/-- How a finished game ended. `win b`: the player who went first won iff `b`. `suddenDeath`:
both players won at the same time and neither won in more ways (rulebook 2026 p. 21: "You win if
you take your last Prize card or if your opponent has no Benched Pokémon to replace their Active
Pokémon if it is Knocked Out (or otherwise removed from play). This makes it possible for both
players to win at the same time. If this happens, play a tiebreaker game. However, if you win in
both ways and your opponent wins in only one way, you are the victor!"). Under the current rules
the outcome stands for "a tiebreaker game is played" (p. 21: "Both players set up as though they
were playing a normal game … The first player to take a Prize card (or to otherwise have fewer
Prize cards remaining than their opponent) wins"), a new game that the model does not play:
`suddenDeath` is a terminal outcome of this game, like a win. The name is the 2023 rulebook's
(Sudden Death, a new game with 1 Prize card each), kept because generated code and the paper cite
it; it is not the 2026 rule. -/
inductive Outcome where
  | win (firstWon : Bool)
  | suddenDeath
  deriving DecidableEq

/-- Whole-game state. `cur` is the player to move; the two swap at end of turn. -/
structure GameState where
  cur : PlayerState
  opp : PlayerState
  /-- is the player to move the one who went first? -/
  curIsFirst : Bool
  /-- is this the first turn of the game, that is the starting player's first turn? Read by the
  bans on attacking and on Supporters, which apply to the starting player's first turn only
  (rulebook 2023 pp. 12–13). The per-player first turn is `PlayerState.hadTurn`; in play from
  the start of a game the two agree (`firstTurn` holds exactly when the player to move went
  first and has not had a turn), but start states are not required to be consistent
(`GameState.FlagsOk`, preserved by play: `Reach.flagsOk`). -/
  firstTurn : Bool
  /-- has the player to move attacked this turn? -/
  attacked : Bool
  /-- between turns: Pokémon Checkup has been applied and its Knock Outs are being resolved;
  the player to move has not yet drawn for the turn -/
  between : Bool
  /-- `some o`: the game is over, with outcome `o` (`Outcome.win b`: won by the first player iff
  `b`; `Outcome.suddenDeath`: both players won at once in as many ways, and a tiebreaker game, which the
  model does not play, would follow). `none`: the
  game goes on. -/
  winner : Option Outcome
  /-- the Stadium in play, if any, with its owner (`true`: the player who went first). There is
  one Stadium slot for both players: "Only one Stadium can be in play at a time" (rulebook 2023
  p. 12). `Move.stadium` (milestone M5) puts a Stadium from the hand here, and the Stadium it
  replaces goes to its owner's discard pile. -/
  stadium : Option (Bool × Card)
  /-- has the player to move played a Stadium this turn? (milestone M5: "You can play only one
  Stadium card each turn", rulebook 2023 p. 12); set by `Move.stadium`, cleared by `Move.endTurn` -/
  stadiumPlayed : Bool
  /-- has the player to move used the effect of the Stadium in play this turn? (milestone M5: "Once
  during each player's turn, that player may …"); set by `Move.stadiumUse`, cleared by
  `Move.endTurn` and by `Move.stadium` (a Stadium newly put into play has not been used) -/
  stadiumUsed : Bool

/-- The Active Pokémon of the player to move (`own`) or of the opponent (`opp`). -/
def GameState.activeOf : Whose → GameState → Option InPlay
  | .own, g => g.cur.active
  | .opp, g => g.opp.active

/-- **The damage calculation** (rulebook 2023 p. 20, "Figuring out how many damage counters to
place"; the same in the 2024 rulebook, survey S8 F2), for an attack whose base damage is `n`
counters, against a Defending Pokémon that is weak to the attacker (`weak`) and has Resistance
`resist` to it:

1. "Start with the base damage printed to the right of the attack. If an ×, –, or + is printed
   next to it, the attack text will tell you how much damage to do." That is `n` (`Amt`).
2. "Figure out damage effects on your Active Pokémon based on Trainer cards or any other
   relevant effects. … Stop if the base damage is 0 (or if the attack does not do any damage at
   all). Otherwise, keep going." If `n = 0` the result is 0; otherwise the attacker's damage
   bonus is added.
3. "Increase the damage by the amount next to your opponent's Active Pokémon's Weakness, if it
   has Weakness to your Active Pokémon's type." Weakness ×2 doubles.
4. "Reduce the damage by the amount next to your opponent's Active Pokémon's Resistance, if it
   has Resistance to your Active Pokémon's type."
5. "Figure out damage effects of Trainer or Energy cards, or other effects on your opponent's
   Active Pokémon." The defender's damage reduction is subtracted; damage prevention makes it 0.
6. "For each 10 damage of the final attack, put 1 damage counter on the affected Pokémon. If
   the damage is 0 or less, don't put on any damage counters!" Amounts are in counters, and
   subtraction stops at 0.

Units: one counter is 10 damage, so Resistance −30 is 3. Prevention ("prevent all damage done
to this Pokémon by attacks") is read in step 5, as an effect on the Defending Pokémon. Step 2's
stop is applied to the base damage as the text computes it (`n`), so an attack whose text gives
0 ("10× the number of heads", no heads) also stops. Truncation: steps 4 and 5 each stop at 0, so
a Resistance larger than the damage leaves nothing for step 5 to remove. The rulebook does not
say whether a negative intermediate damage carries over; with only subtractions after step 4 the
result is 0 either way. -/
def dealtBy (n : Nat) (weak : Bool) (resist : Nat) (own opp : Store) : Nat :=
  if n = 0 then 0 else if opp.live.prevent then 0 else
    ((if weak then 2 * (n + own.live.bonus) else n + own.live.bonus) - resist) - opp.live.reduce

/-- Is the opponent's Active Pokémon weak to the type of the player's Active Pokémon (its type
as `InPlay.type` gives it, Coloring counter included)? False if either Spot is empty. -/
def GameState.weak (g : GameState) : Bool :=
  match g.cur.active, g.opp.active with
  | some a, some d => d.top.weakTo a.type
  | _, _ => false

/-- The Resistance of the opponent's Active Pokémon to the type of the player's Active Pokémon,
in counters (0 if either Spot is empty). -/
def GameState.resist (g : GameState) : Nat :=
  match g.cur.active, g.opp.active with
  | some a, some d => d.top.resistTo a.type
  | _, _ => 0

/-- The player to move (`own`) or the opponent (`opp`). -/
def GameState.side : Whose → GameState → PlayerState
  | .own, g => g.cur
  | .opp, g => g.opp

/-- Change the state of the player to move (`own`) or of the opponent (`opp`). -/
def GameState.updSide : Whose → (PlayerState → PlayerState) → GameState → GameState
  | .own, f, g => { g with cur := f g.cur }
  | .opp, f, g => { g with opp := f g.opp }

def GameState.cards (g : GameState) : Nat :=
  g.cur.cards + g.opp.cards + stadiumCards g.stadium

/-- Every physical card in the game, in both players' zones. -/
def GameState.allCards (g : GameState) : List Card :=
  g.cur.allCards ++ g.opp.allCards ++ stadiumCardList g.stadium

def benchLimit : Nat := 5

/-- Is a Stadium with the name `n` in play? (milestone M5: "You can't play a Stadium card if a
Stadium with the same name is already in play", rulebook 2023 p. 12) -/
def GameState.stadiumNamed (n : String) (g : GameState) : Bool :=
  match g.stadium with
  | none => false
  | some (_, c) => (Filter.named n).eval c

/-- The cards of a pile. -/
def Pile.get : Pile → PlayerState → List Card
  | .hand, s => s.hand
  | .deck, s => s.deck
  | .discard, s => s.discard

/-- The value of a count in a state. -/
def Count.val : Count → GameState → Nat
  | .pile w z f, g => (z.get (g.side w)).countP f.eval
  | .prizes w, g => (g.side w).prizes.length
  | .bench w f, g => ((g.side w).bench.map InPlay.top).countP fun p => f.eval (.pokemon p)
  | .energy w f, g => (((g.side w).active.map InPlay.energy).getD []).countP f.eval
  | .energyAll w f, g =>
      ((((g.side w).active.map InPlay.energy).getD []) ++
        ((g.side w).bench.map InPlay.energy).flatten).countP f.eval
  | .koLast w atk, g => if cond atk (g.side w).ko.lastAtk (g.side w).ko.last then 1 else 0
  | .inPlay w f, g =>
      (((g.side w).active.map InPlay.top).toList ++ (g.side w).bench.map InPlay.top).countP
        fun p => f.eval (.pokemon p)

/-- The value of a test in a state, on the Active Pokémon `p` it reads (a count test reads the
state instead). -/
def Test.eval : Test → GameState → InPlay → Bool
  | .atLeast _ n, _, p => Nat.ble n p.damage
  | .exactly _ n, _, p => Nat.beq p.damage n
  | .cond _ c, _, p => p.has c
  | .marked _ m, _, p => p.marks.get m
  | .isType _ t, _, p => decide (p.type = t)
  | .countGe c n, g, _ => Nat.ble n (c.val g)
  | .top _ f, _, p => f.eval (.pokemon p.top)
  | .hasTool _, _, p => !p.tools.isEmpty
  | .movedUp _, _, p => p.movedUp
  | .evolved _, _, p => p.fresh && !p.under.isEmpty

end Pokemon
