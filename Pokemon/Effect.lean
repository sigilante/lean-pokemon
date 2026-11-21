import Pokemon.State

/-!
# Semantics of effects

`Run e g g'` holds when resolving effect `e` in state `g` can produce `g'`. The relation is
nondeterministic: player choices, coin flips and shuffles are all branches of it. That is
the right shape for reachability questions, and it is silent about probability.

Effects read the state through the two Active Pokémon: a test (`ite`) on the damage, the
Special Conditions, the markers or the type of either one; `scale`, which places counters in
proportion to the damage on either one; and the amount of the damage step (`Amt.per`), which
reads the damage on either one. Since milestone M3 effects also place damage counters on Benched
Pokémon (`benchCounters`, `spreadCounters`) and heal one (`benchHeal`, which reads a Benched
Pokémon's damage by truncated subtraction; since milestone M8a `moveCounter` reads it too). The damage step also reads the two Active Pokémon's types,
Weakness and Resistance, and both players' modifiers (`GameState.dealt`). Inside one `Run` nothing is Knocked Out, so damage may exceed HP and
these reads see the excess. `Run` is the semantics of an attack's effect, where the rulebook
checks for Knock Outs only at the end of the attack. The effect of an Item or Supporter card is
resolved by `TRun` (in `Pokemon.Rules`), which uses `Run` for one primitive step at a time and
takes every Knock Out at once after each step.

Since milestone MV effects also move cards between a player's zones (`Run.zone`, with the
semantics `ZStep` on one player's state): search, draw, mill, discard from the hand, recycling
from the discard pile, attaching Energy from a zone, putting a Basic Pokémon onto the Bench, and
discarding or moving attached Energy; and amounts and tests read counts (`Count.val`).

Since milestone M8a an effect also moves a damage counter between the player's own Pokémon in play
(`Run.moveCounter`, with the relation `CMove`); it reads and writes only the player's own damage,
which both clamps keep exact inside an effect (`CMove.sim`). Abilities' effects are compiled to this
language (`AbEff.compile`), so `Run` has no other new case.
-/

namespace Pokemon

/-- A primitive effect: anything but `ite`, `seq`, `choice` and `iter`. Each primitive resolves
in one step of `Run`, with no sub-derivation. -/
def Effect.isPrim : Effect → Bool
  | .ite .. => false
  | .seq .. => false
  | .choice .. => false
  | .iter .. => false
  | _ => true

/-- The effects that change the markers of one Pokémon in play: whose Pokémon, and how
(`mark` sets a marker; `color` replaces the Coloring counter). -/
def Effect.touch : Effect → Option (Whose × (Marks → Marks))
  | .mark w m => some (w, Marks.set m true)
  | .color w t => some (w, fun k => { k with coloring := some t })
  | _ => none

/-- Put `n` more damage counters on a Pokémon. -/
def InPlay.addDamage (n : Nat) (p : InPlay) : InPlay := { p with damage := p.damage + n }

/-- Attack damage `n` to a Benched Pokémon: `n` more damage counters, none on a Tera Pokémon ("As
long as this Pokémon is on your Bench, prevent all damage done to this Pokémon by attacks (both
yours and your opponent's)", printed on every Tera Pokémon; rulebook 2023 p. 24). -/
def InPlay.hitBench (n : Nat) (p : InPlay) : InPlay := if p.top.tera then p else p.addDamage n

/-- Remove the marker `m` from every Pokémon of one player. -/
def PlayerState.unmark (m : Marker) (s : PlayerState) : PlayerState :=
  { s with active := s.active.map (InPlay.setMarks (Marks.set m false)),
           bench := s.bench.map (InPlay.setMarks (Marks.set m false)) }

/-- `Amt.Val a g n`: the amount `a` evaluates to `n` counters in state `g`. `per` reads the
damage on an Active Pokémon (and needs one); `many` sums any number of values (a coin flipped
until tails), so evaluation is a relation. -/
inductive Amt.Val : Amt → GameState → Nat → Prop where
  | const (n : Nat) (g : GameState) : Amt.Val (.const n) g n
  | per {w : Whose} {g : GameState} {p : InPlay} (k : Nat) (h : g.activeOf w = some p) :
      Amt.Val (.per w k) g (k * p.damage)
  | add {a b : Amt} {g : GameState} {x y : Nat} :
      Amt.Val a g x → Amt.Val b g y → Amt.Val (.add a b) g (x + y)
  | sub {a b : Amt} {g : GameState} {x y : Nat} :
      Amt.Val a g x → Amt.Val b g y → Amt.Val (.sub a b) g (x - y)
  | manyNil (a : Amt) (g : GameState) : Amt.Val (.many a) g 0
  | manyCons {a : Amt} {g : GameState} {x y : Nat} :
      Amt.Val a g x → Amt.Val (.many a) g y → Amt.Val (.many a) g (x + y)
  | count (c : Count) (k : Nat) (g : GameState) : Amt.Val (.count c k) g (k * c.val g)

/-- An amount evaluates the same in a state whose Active Pokémon have the same damage and whose
counts are the same. -/
theorem Amt.Val.congr {a : Amt} {g₁ g₂ : GameState} {n : Nat} (h : a.Val g₁ n)
    (hv : ∀ c : Count, c.val g₂ = c.val g₁)
    (hc : ∀ w p, g₁.activeOf w = some p → ∃ q, g₂.activeOf w = some q ∧ q.damage = p.damage) :
    a.Val g₂ n := by
  induction h with
  | const n g => exact .const n g₂
  | per k h =>
      obtain ⟨q, hq, hd⟩ := hc _ _ h
      rw [← hd]; exact .per k hq
  | add _ _ ih₁ ih₂ => exact .add (ih₁ hv hc) (ih₂ hv hc)
  | sub _ _ ih₁ ih₂ => exact .sub (ih₁ hv hc) (ih₂ hv hc)
  | manyNil a g => exact .manyNil a g₂
  | manyCons _ _ ih₁ ih₂ => exact .manyCons (ih₁ hv hc) (ih₂ hv hc)
  | count c k g => rw [← hv c]; exact .count c k g₂

/-- An amount that has a value in one state has one in every state with Active Pokémon where
the first has them (the values may differ). -/
theorem Amt.Val.transfer {a : Amt} {g₁ g₂ : GameState} {n : Nat} (h : a.Val g₁ n)
    (hc : ∀ w p, g₁.activeOf w = some p → ∃ q, g₂.activeOf w = some q) : ∃ m, a.Val g₂ m := by
  induction h with
  | const n g => exact ⟨n, .const n g₂⟩
  | per k h =>
      obtain ⟨q, hq⟩ := hc _ _ h
      exact ⟨_, .per k hq⟩
  | add _ _ ih₁ ih₂ =>
      obtain ⟨x, hx⟩ := ih₁ hc
      obtain ⟨y, hy⟩ := ih₂ hc
      exact ⟨_, .add hx hy⟩
  | sub _ _ ih₁ ih₂ =>
      obtain ⟨x, hx⟩ := ih₁ hc
      obtain ⟨y, hy⟩ := ih₂ hc
      exact ⟨_, .sub hx hy⟩
  | manyNil a g => exact ⟨0, .manyNil a g₂⟩
  | manyCons _ _ _ _ => exact ⟨0, .manyNil _ g₂⟩
  | count c k g => exact ⟨_, .count c k g₂⟩

/-- A printed number evaluates to itself. -/
theorem Amt.Val.const_inv {n m : Nat} {g : GameState} (h : (Amt.const n).Val g m) : m = n := by
  cases h; rfl

/-! ## Zone moves (milestone MV)

The primitives `move`, `drawTo`, `attach`, `putBench`, `discardEnergy` and `moveEnergy` act on the
zones of one player (deck, hand, discard pile, Active Spot, Bench), never on damage, Special
Conditions, markers, Prizes, the Lost Zone, the stores or the flags. `ZStep e s s'` is their
semantics on one player's state; `Run.zone` lifts it to the game, with `PlayerState.setZones`
taking from `s'` only the five zones, so that everything else is unchanged by definition. -/

/-- The cards a source offers (`Src`). -/
def Src.get : Src → PlayerState → List Card
  | .deck, s => s.deck
  | .top n, s => s.deck.take n
  | .hand, s => s.hand
  | .discard, s => s.discard

/-- Replace the cards of a source by `r` (the cards not taken, in their order). -/
def Src.set : Src → List Card → PlayerState → PlayerState
  | .deck, r, s => { s with deck := r }
  | .top n, r, s => { s with deck := r ++ s.deck.drop n }
  | .hand, r, s => { s with hand := r }
  | .discard, r, s => { s with discard := r }

/-- `Split f l t r`: the cards `t` are taken from `l`, each passing `f`, and `r` are the others;
both keep the order of `l`. -/
inductive Split (f : Filter) : List Card → List Card → List Card → Prop where
  | nil : Split f [] [] []
  | take {x : Card} {l t r : List Card} (hx : f.eval x = true) :
      Split f l t r → Split f (x :: l) (x :: t) r
  | keep {x : Card} {l t r : List Card} : Split f l t r → Split f (x :: l) t (x :: r)

/-- The number of cards taken is as `q` says: at most `n`, exactly `n`, or every card of the
source that passes the filter. -/
def Qty.ok : Qty → Filter → List Card → List Card → Prop
  | .upTo n, _, t, _ => t.length ≤ n
  | .exactly n, _, t, _ => t.length = n
  | .all, f, _, r => ∀ x ∈ r, f.eval x = false

/-- `Put d t s s'`: the cards `t` are put at the destination `d` of the state `s`. -/
inductive Put : Dst → List Card → PlayerState → PlayerState → Prop where
  | hand (t : List Card) (s : PlayerState) : Put .hand t s { s with hand := t ++ s.hand }
  | discard (t : List Card) (s : PlayerState) :
      Put .discard t s { s with discard := t ++ s.discard }
  | top {t t' : List Card} (s : PlayerState) (h : t'.Perm t) :
      Put .top t s { s with deck := t' ++ s.deck }
  | bottom {t t' : List Card} (s : PlayerState) (h : t'.Perm t) :
      Put .bottom t s { s with deck := s.deck ++ t' }
  | shuffle {t d : List Card} (s : PlayerState) (h : d.Perm (t ++ s.deck)) :
      Put .shuffle t s { s with deck := d }

/-- The player whose zones a zone-move primitive acts on; `none` for every other effect. -/
def Effect.zSide : Effect → Option Whose
  | .move w _ _ _ _ => some w
  | .drawTo w _ => some w
  | .attach w _ _ _ _ => some w
  | .putBench w _ _ => some w
  | .discardEnergy w _ _ _ => some w
  | .moveEnergy w _ => some w
  | .discardTools w _ => some w
  | _ => none

/-- `s` with the five zones (deck, hand, discard pile, Active Spot, Bench) of `z`; every other
component (Prizes, Lost Zone, stores, flags) is `s`'s. -/
def PlayerState.setZones (s z : PlayerState) : PlayerState :=
  { s with deck := z.deck, hand := z.hand, discard := z.discard, active := z.active,
           bench := z.bench }

/-- Add an Energy card to a Pokémon in play. -/
def InPlay.addEnergy (c : Card) (p : InPlay) : InPlay := { p with energy := c :: p.energy }

/-- Draw the top `k` cards (all of them if fewer are left). -/
def PlayerState.drawK (k : Nat) (s : PlayerState) : PlayerState :=
  { s with deck := s.deck.drop k, hand := s.deck.take k ++ s.hand }

/-- The semantics of the zone-move primitives on one player's state. -/
inductive ZStep : Effect → PlayerState → PlayerState → Prop where
  | move {w : Whose} {src : Src} {dst : Dst} {f : Filter} {q : Qty} {s s' : PlayerState}
      {t r : List Card} (hs : Split f (src.get s) t r) (hq : q.ok f t r)
      (hp : Put dst t (src.set r s) s') : ZStep (.move w src dst f q) s s'
  | drawTo (w : Whose) (n : Nat) (s : PlayerState) :
      ZStep (.drawTo w n) s (s.drawK (n - s.hand.length))
  | attachActive {w : Whose} {src : Src} {f tf : Filter} {s : PlayerState} {r : List Card}
      {t : BasicEnergy} {a : InPlay} (hs : Split f (src.get s) [.energy t] r)
      (ha : s.active = some a) (ht : tf.eval (.pokemon a.top) = true) :
      ZStep (.attach w src f .active tf) s
        { src.set r s with active := some (a.addEnergy (.energy t)) }
  | attachBench {w : Whose} {src : Src} {f tf : Filter} {s : PlayerState} {r : List Card}
      {t : BasicEnergy} {q : InPlay} {b₁ b₂ : List InPlay} (hs : Split f (src.get s) [.energy t] r)
      (hb : s.bench = b₁ ++ q :: b₂) (ht : tf.eval (.pokemon q.top) = true) :
      ZStep (.attach w src f .bench tf) s
        { src.set r s with bench := b₁ ++ q.addEnergy (.energy t) :: b₂ }
  | attachNone (w : Whose) (src : Src) (f : Filter) (sp : Spot) (tf : Filter) (s : PlayerState) :
      ZStep (.attach w src f sp tf) s s
  | putBench {w : Whose} {src : Src} {f : Filter} {s : PlayerState} {r : List Card}
      {p : PokemonCard} (hs : Split f (src.get s) [.pokemon p] r) (hst : p.stage = .basic)
      (hhp : 0 < p.hp) (hb : s.bench.length < benchLimit) :
      ZStep (.putBench w src f) s { src.set r s with bench := s.bench ++ [InPlay.ofBasic p] }
  | putBenchNone (w : Whose) (src : Src) (f : Filter) (s : PlayerState) :
      ZStep (.putBench w src f) s s
  | discardActive {w : Whose} {f : Filter} {q : Qty} {s : PlayerState} {a : InPlay}
      {t r : List Card} (ha : s.active = some a) (hs : Split f a.energy t r) (hq : q.ok f t r) :
      ZStep (.discardEnergy w .active f q) s
        { s with active := some { a with energy := r }, discard := t ++ s.discard }
  | discardBench {w : Whose} {f : Filter} {q : Qty} {s : PlayerState} {p : InPlay}
      {b₁ b₂ : List InPlay} {t r : List Card} (hb : s.bench = b₁ ++ p :: b₂)
      (hs : Split f p.energy t r) (hq : q.ok f t r) :
      ZStep (.discardEnergy w .bench f q) s
        { s with bench := b₁ ++ { p with energy := r } :: b₂, discard := t ++ s.discard }
  | discardNone {w : Whose} {f : Filter} {q : Qty} {s : PlayerState} (hb : s.bench = []) :
      ZStep (.discardEnergy w .bench f q) s s
  /-- from the Active Pokémon to a Benched one -/
  | moveAB {w : Whose} {f : Filter} {s : PlayerState} {a q : InPlay} {b₁ b₂ : List InPlay}
      {e₁ e₂ : List Card} {x : Card} (ha : s.active = some a) (he : a.energy = e₁ ++ x :: e₂)
      (hx : f.eval x = true) (hb : s.bench = b₁ ++ q :: b₂) :
      ZStep (.moveEnergy w f) s
        { s with active := some { a with energy := e₁ ++ e₂ }, bench := b₁ ++ q.addEnergy x :: b₂ }
  /-- from a Benched Pokémon to the Active one -/
  | moveBA {w : Whose} {f : Filter} {s : PlayerState} {a q : InPlay} {b₁ b₂ : List InPlay}
      {e₁ e₂ : List Card} {x : Card} (ha : s.active = some a) (hb : s.bench = b₁ ++ q :: b₂)
      (he : q.energy = e₁ ++ x :: e₂) (hx : f.eval x = true) :
      ZStep (.moveEnergy w f) s
        { s with active := some (a.addEnergy x), bench := b₁ ++ { q with energy := e₁ ++ e₂ } :: b₂ }
  /-- from a Benched Pokémon to a Benched one (taken off first, so the target may be any
  Pokémon of the Bench after that) -/
  | moveBB {w : Whose} {f : Filter} {s : PlayerState} {q q' : InPlay} {b₁ b₂ c₁ c₂ : List InPlay}
      {e₁ e₂ : List Card} {x : Card} (hb : s.bench = b₁ ++ q :: b₂) (he : q.energy = e₁ ++ x :: e₂)
      (hx : f.eval x = true) (hc : b₁ ++ { q with energy := e₁ ++ e₂ } :: b₂ = c₁ ++ q' :: c₂) :
      ZStep (.moveEnergy w f) s { s with bench := c₁ ++ q'.addEnergy x :: c₂ }
  | moveNone (w : Whose) (f : Filter) (s : PlayerState) : ZStep (.moveEnergy w f) s s
  /-- discard the Tools of the Active Pokémon (milestone M5) -/
  | toolsActive {w : Whose} {s : PlayerState} {a : InPlay} (ha : s.active = some a) :
      ZStep (.discardTools w .active) s
        { s with active := some { a with tools := [] }, discard := a.tools ++ s.discard }
  /-- discard the Tools of one Benched Pokémon -/
  | toolsBench {w : Whose} {s : PlayerState} {p : InPlay} {b₁ b₂ : List InPlay}
      (hb : s.bench = b₁ ++ p :: b₂) :
      ZStep (.discardTools w .bench) s
        { s with bench := b₁ ++ { p with tools := [] } :: b₂, discard := p.tools ++ s.discard }
  | toolsNone {w : Whose} {s : PlayerState} (hb : s.bench = []) :
      ZStep (.discardTools w .bench) s s

/-- `CMove f noKO a b a' b'` (milestone M8a): one damage counter moves from one of the player's
Pokémon in play (Active Pokémon `a`, Bench `b`) whose card passes `f` to another of them, giving
`a'` and `b'`: from the Active Pokémon to a Benched one (`ab`), from a Benched one to the Active
Pokémon (`ba`), or from a Benched one to another Benched one (`bb`; the counter is taken off
first, and the target is at another place of the Bench). With `noKO` the target stays below its
HP. -/
inductive CMove (f : Filter) (noKO : Bool) :
    Option InPlay → List InPlay → Option InPlay → List InPlay → Prop where
  | ab {x q : InPlay} {b₁ b₂ : List InPlay} (hx : f.eval (.pokemon x.top) = true)
      (hd : 0 < x.damage) (hk : noKO = true → q.damage + 1 < q.top.hp) :
      CMove f noKO (some x) (b₁ ++ q :: b₂) (some { x with damage := x.damage - 1 })
        (b₁ ++ q.addDamage 1 :: b₂)
  | ba {x q : InPlay} {b₁ b₂ : List InPlay} (hq : f.eval (.pokemon q.top) = true)
      (hd : 0 < q.damage) (hk : noKO = true → x.damage + 1 < x.top.hp) :
      CMove f noKO (some x) (b₁ ++ q :: b₂) (some (x.addDamage 1))
        (b₁ ++ { q with damage := q.damage - 1 } :: b₂)
  | bb {a : Option InPlay} {q r : InPlay} {b₁ b₂ c₁ c₂ : List InPlay}
      (hq : f.eval (.pokemon q.top) = true) (hd : 0 < q.damage)
      (hc : b₁ ++ { q with damage := q.damage - 1 } :: b₂ = c₁ ++ r :: c₂)
      (hne : c₁.length ≠ b₁.length) (hk : noKO = true → r.damage + 1 < r.top.hp) :
      CMove f noKO a (b₁ ++ q :: b₂) a (c₁ ++ r.addDamage 1 :: c₂)

inductive Run : Effect → GameState → GameState → Prop where
  | skip (g : GameState) : Run .skip g g
  | draw {g : GameState} {c : Card} {d : List Card} (h : g.cur.deck = c :: d) :
      Run .draw g { g with cur := { g.cur with deck := d, hand := c :: g.cur.hand } }
  | drawEmpty {g : GameState} (h : g.cur.deck = []) : Run .draw g g
  | heal {g : GameState} {p : InPlay} (n : Nat) (h : g.cur.active = some p) :
      Run (.heal n) g
        { g with cur := { g.cur with active := some { p with damage := p.damage - n } } }
  | counters {g : GameState} {p : InPlay} (n : Nat) (h : g.opp.active = some p) :
      Run (.counters n) g
        { g with opp := { g.opp with active := some { p with damage := p.damage + n } } }
  | inflict {g : GameState} {p : InPlay} (c : Condition) (h : g.opp.active = some p) :
      Run (.inflict c) g { g with opp := { g.opp with active := some (p.inflict c) } }
  | poisonUp {g : GameState} {p : InPlay} (n : Nat) (h : g.opp.active = some p)
      (hp : p.poisoned = true) :
      Run (.poisonUp n) g
        { g with opp := { g.opp with active := some { p with poisonUp := p.poisonUp + n } } }
  | poisonUpSkip {g : GameState} {p : InPlay} (n : Nat) (h : g.opp.active = some p)
      (hp : p.poisoned = false) : Run (.poisonUp n) g g
  | cure {g : GameState} {p : InPlay} (h : g.cur.active = some p) :
      Run .cure g { g with cur := { g.cur with active := some p.cure } }
  | shuffle {g : GameState} {d : List Card} (h : d.Perm g.cur.deck) :
      Run .shuffle g { g with cur := { g.cur with deck := d } }
  | search {g : GameState} {l₁ l₂ : List Card} {c : Card} (h : g.cur.deck = l₁ ++ c :: l₂) :
      Run .search g { g with cur := { g.cur with deck := l₁ ++ l₂, hand := c :: g.cur.hand } }
  | handToBottom {g : GameState} {hs : List Card} (h : hs.Perm g.cur.hand) :
      Run .handToBottom g { g with cur := { g.cur with deck := g.cur.deck ++ hs, hand := [] } }
  | iteT {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay}
      (h : g.activeOf t.whose = some p) (ht : t.eval g p = true) :
      Run a g g' → Run (.ite t a b) g g'
  | iteF {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay}
      (h : g.activeOf t.whose = some p) (ht : t.eval g p = false) :
      Run b g g' → Run (.ite t a b) g g'
  | scale {g : GameState} {p q : InPlay} (w : Whose) (k : Nat)
      (hs : g.activeOf w = some p) (h : g.opp.active = some q) :
      Run (.scale w k) g
        { g with opp := { g.opp with active := some { q with damage := q.damage + k * p.damage } } }
  | selfDamage {g : GameState} {p : InPlay} (n : Nat) (h : g.cur.active = some p) :
      Run (.selfDamage n) g
        { g with cur := { g.cur with active := some { p with damage := p.damage + n } } }
  | healAll {g : GameState} {p : InPlay} (h : g.cur.active = some p) :
      Run .healAll g { g with cur := { g.cur with active := some { p with damage := 0 } } }
  /-- `mark` or `color` on the `w` player's Active Pokémon -/
  | touchActive {e : Effect} {w : Whose} {f : Marks → Marks} {g : GameState} {p : InPlay}
      (he : e.touch = some (w, f)) (h : (g.side w).active = some p) :
      Run e g (g.updSide w fun s => { s with active := some (p.setMarks f) })
  /-- `mark` or `color` on one of the `w` player's Benched Pokémon -/
  | touchBench {e : Effect} {w : Whose} {f : Marks → Marks} {g : GameState} {q : InPlay}
      {b₁ b₂ : List InPlay} (he : e.touch = some (w, f)) (h : (g.side w).bench = b₁ ++ q :: b₂) :
      Run e g (g.updSide w fun s => { s with bench := b₁ ++ q.setMarks f :: b₂ })
  | unmark (w : Whose) (m : Marker) (g : GameState) :
      Run (.unmark w m) g (g.updSide w (PlayerState.unmark m))
  | linger (w : Whose) (s : Slot) (m : Mod) (g : GameState) :
      Run (.linger w s m) g (g.updSide w fun p => { p with mods := p.mods.add s m })
  /-- the damage step: the amount evaluates to `n`, and the calculation `GameState.dealt n`
  gives the damage placed -/
  | damage {g : GameState} {p : InPlay} {a : Amt} {n : Nat} (hv : a.Val g n)
      (h : g.opp.active = some p) :
      Run (.damage a) g
        { g with opp := { g.opp with active := some { p with damage := p.damage + g.dealt n } } }
  | drain {g : GameState} {p q : InPlay} {a : Amt} {n : Nat} (hv : a.Val g n)
      (h : g.opp.active = some p) (hq : g.cur.active = some q) :
      Run (.drain a) g
        { g with cur := { g.cur with active := some { q with damage := q.damage - g.dealt n } },
                 opp := { g.opp with active := some { p with damage := p.damage + g.dealt n } } }
  /-- damage counters on one of the `w` player's Benched Pokémon (milestone M3) -/
  | benchCounters {g : GameState} {q : InPlay} {b₁ b₂ : List InPlay} (w : Whose) (n : Nat)
      (h : (g.side w).bench = b₁ ++ q :: b₂) :
      Run (.benchCounters w n) g
        (g.updSide w fun s => { s with bench := b₁ ++ { q with damage := q.damage + n } :: b₂ })
  | benchCountersNone {g : GameState} (w : Whose) (n : Nat) (h : (g.side w).bench = []) :
      Run (.benchCounters w n) g g
  /-- damage counters on each of the `w` player's Benched Pokémon -/
  | spreadCounters (w : Whose) (n : Nat) (g : GameState) :
      Run (.spreadCounters w n) g
        (g.updSide w fun s => { s with bench := s.bench.map (InPlay.addDamage n) })
  /-- heal one of the player's own Benched Pokémon -/
  | benchHeal {g : GameState} {q : InPlay} {b₁ b₂ : List InPlay} (n : Nat)
      (h : g.cur.bench = b₁ ++ q :: b₂) :
      Run (.benchHeal n) g
        { g with cur := { g.cur with bench := b₁ ++ { q with damage := q.damage - n } :: b₂ } }
  | benchHealNone {g : GameState} (n : Nat) (h : g.cur.bench = []) : Run (.benchHeal n) g g
  /-- the `w` player's Active Pokémon `a` switches with the Benched `q`; `a` goes to the Bench
  cured of its Special Conditions ("When your Active Pokémon goes to your Bench (whether it
  retreated or got there some other way), some things do go away—Special Conditions and any
  effects from attacks", rulebook 2023 p. 12) -/
  | switch {g : GameState} {a q : InPlay} {b₁ b₂ : List InPlay} (w : Whose)
      (ha : (g.side w).active = some a) (hb : (g.side w).bench = b₁ ++ q :: b₂) :
      Run (.switch w) g
        (g.updSide w fun s => { s with active := some q, bench := b₁ ++ a.cure :: b₂ })
  | switchNone {g : GameState} (w : Whose) (hb : (g.side w).bench = []) : Run (.switch w) g g
  /-- attack damage to one of the `w` player's Benched Pokémon (milestone M3) -/
  | benchDamage {g : GameState} {q : InPlay} {b₁ b₂ : List InPlay} (w : Whose) (n : Nat)
      (h : (g.side w).bench = b₁ ++ q :: b₂) :
      Run (.benchDamage w n) g
        (g.updSide w fun s => { s with bench := b₁ ++ q.hitBench n :: b₂ })
  | benchDamageNone {g : GameState} (w : Whose) (n : Nat) (h : (g.side w).bench = []) :
      Run (.benchDamage w n) g g
  /-- attack damage to each of the `w` player's Benched Pokémon -/
  | spreadDamage (w : Whose) (n : Nat) (g : GameState) :
      Run (.spreadDamage w n) g
        (g.updSide w fun s => { s with bench := s.bench.map (InPlay.hitBench n) })
  /-- a zone-move primitive (milestone MV) on the `w` player's zones -/
  | zone {e : Effect} {w : Whose} {g : GameState} {s' : PlayerState} (hw : e.zSide = some w)
      (h : ZStep e (g.side w) s') : Run e g (g.updSide w fun s => s.setZones s')
  /-- move a damage counter between the player's own Pokémon (milestone M8a) -/
  | moveCounter {g : GameState} {f : Filter} {noKO : Bool} {a' : Option InPlay}
      {b' : List InPlay} (h : CMove f noKO g.cur.active g.cur.bench a' b') :
      Run (.moveCounter f noKO) g { g with cur := { g.cur with active := a', bench := b' } }
  /-- discard the Stadium in play to its owner's discard pile (milestone M5) -/
  | discardStadium (g : GameState) :
      Run .discardStadium g { g with
        cur := { g.cur with discard := stadiumTo g.curIsFirst g.stadium ++ g.cur.discard },
        opp := { g.opp with discard := stadiumTo (!g.curIsFirst) g.stadium ++ g.opp.discard },
        stadium := none }
  | seq {a b : Effect} {g₁ g₂ g₃ : GameState} :
      Run a g₁ g₂ → Run b g₂ g₃ → Run (.seq a b) g₁ g₃
  | choiceL {a b : Effect} {g g' : GameState} : Run a g g' → Run (.choice a b) g g'
  | choiceR {a b : Effect} {g g' : GameState} : Run b g g' → Run (.choice a b) g g'
  | iterNil (a : Effect) (g : GameState) : Run (.iter a) g g
  | iterCons {a : Effect} {g₁ g₂ g₃ : GameState} :
      Run a g₁ g₂ → Run (.iter a) g₂ g₃ → Run (.iter a) g₁ g₃

end Pokemon
