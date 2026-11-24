import Pokemon.Static

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
  /-- (milestone MV6) `k` for each heads among `n` coins: any number of heads `m` up to `n` -/
  | heads {a : Amt} {g : GameState} {n m : Nat} (k : Nat) :
      Amt.Val a g n → m ≤ n → Amt.Val (.heads a k) g (k * m)

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
  | heads k _ hm ih => exact .heads k (ih hv hc) hm

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
  | heads k _ _ ih =>
      obtain ⟨x, hx⟩ := ih hc
      exact ⟨_, .heads (m := 0) k hx (Nat.zero_le _)⟩

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
  | .bottom n, s => s.deck.drop (s.deck.length - n)

/-- Replace the cards of a source by `r` (the cards not taken, in their order). -/
def Src.set : Src → List Card → PlayerState → PlayerState
  | .deck, r, s => { s with deck := r }
  | .top n, r, s => { s with deck := r ++ s.deck.drop n }
  | .hand, r, s => { s with hand := r }
  | .discard, r, s => { s with discard := r }
  | .bottom n, r, s => { s with deck := s.deck.take (s.deck.length - n) ++ r }

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
  | .most n, f, t, r => t.length ≤ n ∧ (t.length < n → ∀ x ∈ r, f.eval x = false)

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
  | .look w _ _ _ _ _ => some w
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

/-- `Deal tf t a b a' b'` (milestone MV6, `Into.attach`): the Energy cards `t` are attached one at a
time, each to the Active Pokémon or to one Benched Pokémon whose card passes `tf` ("in any way you
like"), turning the Active Spot `a` and the Bench `b` into `a'` and `b'`. Every card of `t` must be an
Energy card. -/
inductive Deal (tf : Filter) : List Card → Option InPlay → List InPlay → Option InPlay →
    List InPlay → Prop where
  | nil (a : Option InPlay) (b : List InPlay) : Deal tf [] a b a b
  | active {e : EnergyCard} {xs : List Card} {p : InPlay} {b : List InPlay} {a' : Option InPlay}
      {b' : List InPlay} (ht : tf.eval (.pokemon p.top) = true) :
      Deal tf xs (some (p.addEnergy (.energy e))) b a' b' → Deal tf (.energy e :: xs) (some p) b a' b'
  | bench {e : EnergyCard} {xs : List Card} {a : Option InPlay} {q : InPlay} {b₁ b₂ : List InPlay}
      {a' : Option InPlay} {b' : List InPlay} (ht : tf.eval (.pokemon q.top) = true) :
      Deal tf xs a (b₁ ++ q.addEnergy (.energy e) :: b₂) a' b' →
        Deal tf (.energy e :: xs) a (b₁ ++ q :: b₂) a' b'

/-- `Place i t s s'` (milestone MV6): the cards `t` taken from a window go where `i` says: to a zone
(`Put`), onto the Bench (each a Basic Pokémon card with HP, all of them fitting on the Bench), or
attached to the player's Pokémon (`Deal`). -/
inductive Place : Into → List Card → PlayerState → PlayerState → Prop where
  | put {d : Dst} {t : List Card} {s s' : PlayerState} (h : Put d t s s') : Place (.put d) t s s'
  | bench {ps : List PokemonCard} {s : PlayerState} (hb : ∀ p ∈ ps, p.stage = .basic ∧ 0 < p.hp)
      (hl : s.bench.length + ps.length ≤ benchLimit) :
      Place .bench (ps.map Card.pokemon) s { s with bench := s.bench ++ ps.map InPlay.ofBasic }
  | attach {tf : Filter} {t : List Card} {s : PlayerState} {a : Option InPlay} {b : List InPlay}
      (h : Deal tf t s.active s.bench a b) : Place (.attach tf) t s { s with active := a, bench := b }

/-- The semantics of the zone-move primitives on one player's state. -/
inductive ZStep : Effect → PlayerState → PlayerState → Prop where
  | move {w : Whose} {src : Src} {dst : Dst} {f : Filter} {q : Qty} {s s' : PlayerState}
      {t r : List Card} (hs : Split f (src.get s) t r) (hq : q.ok f t r)
      (hp : Put dst t (src.set r s) s') : ZStep (.move w src dst f q) s s'
  | drawTo (w : Whose) (n : Nat) (s : PlayerState) :
      ZStep (.drawTo w n) s (s.drawK (n - s.hand.length))
  | attachActive {w : Whose} {src : Src} {f tf : Filter} {s : PlayerState} {r : List Card}
      {t : EnergyCard} {a : InPlay} (hs : Split f (src.get s) [.energy t] r)
      (ha : s.active = some a) (ht : tf.eval (.pokemon a.top) = true) :
      ZStep (.attach w src f .active tf) s
        { src.set r s with active := some (a.addEnergy (.energy t)) }
  | attachBench {w : Whose} {src : Src} {f tf : Filter} {s : PlayerState} {r : List Card}
      {t : EnergyCard} {q : InPlay} {b₁ b₂ : List InPlay} (hs : Split f (src.get s) [.energy t] r)
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
  /-- look at a fixed window and choose (milestone MV6): the window `src.get s` is taken off its
  source whole (`src.set []`), split into the cards taken `t` and the others `r`, the others are put
  at `rest`, and then the taken cards are placed (`Place`) -/
  | look {w : Whose} {src : Src} {f : Filter} {q : Qty} {i : Into} {rest : Dst}
      {s s₁ s' : PlayerState} {t r : List Card} (hs : Split f (src.get s) t r) (hq : q.ok f t r)
      (hr : Put rest r (src.set [] s) s₁) (hp : Place i t s₁ s') :
      ZStep (.look w src f q i rest) s s'

/-- `CMove f noKO a b a' b'` (milestone M8a): one damage counter moves from one of the player's
Pokémon in play (Active Pokémon `a`, Bench `b`) whose card passes `f` to another of them, giving
`a'` and `b'`: from the Active Pokémon to a Benched one (`ab`), from a Benched one to the Active
Pokémon (`ba`), or from a Benched one to another Benched one (`bb`; the counter is taken off
first, and the target is at another place of the Bench). With `noKO` the target stays below its
HP, `hp` (milestone M6: the derived HP in the state the step starts from, `GameState.hpOf`; moving
a counter changes no HP). -/
inductive CMove (f : Filter) (noKO : Bool) (hp : Spot → InPlay → Nat) :
    Option InPlay → List InPlay → Option InPlay → List InPlay → Prop where
  | ab {x q : InPlay} {b₁ b₂ : List InPlay} (hx : f.eval (.pokemon x.top) = true)
      (hd : 0 < x.damage) (hk : noKO = true → q.damage + 1 < hp .bench q) :
      CMove f noKO hp (some x) (b₁ ++ q :: b₂) (some { x with damage := x.damage - 1 })
        (b₁ ++ q.addDamage 1 :: b₂)
  | ba {x q : InPlay} {b₁ b₂ : List InPlay} (hq : f.eval (.pokemon q.top) = true)
      (hd : 0 < q.damage) (hk : noKO = true → x.damage + 1 < hp .active x) :
      CMove f noKO hp (some x) (b₁ ++ q :: b₂) (some (x.addDamage 1))
        (b₁ ++ { q with damage := q.damage - 1 } :: b₂)
  | bb {a : Option InPlay} {q r : InPlay} {b₁ b₂ c₁ c₂ : List InPlay}
      (hq : f.eval (.pokemon q.top) = true) (hd : 0 < q.damage)
      (hc : b₁ ++ { q with damage := q.damage - 1 } :: b₂ = c₁ ++ r :: c₂)
      (hne : c₁.length ≠ b₁.length) (hk : noKO = true → r.damage + 1 < hp .bench r) :
      CMove f noKO hp a (b₁ ++ q :: b₂) a (c₁ ++ r.addDamage 1 :: c₂)

/-- What `Effect.benchSome` does to one chosen Pokémon: attack damage (`InPlay.hitBench`) or
damage counters (`InPlay.addDamage`). -/
def InPlay.hitWith (dmg : Bool) (n : Nat) (p : InPlay) : InPlay :=
  cond dmg (p.hitBench n) (p.addDamage n)

/-- The number of Pokémon of a Bench whose card passes `f`. -/
def benchElig (f : Filter) (b : List InPlay) : Nat :=
  (b.map InPlay.top).countP fun p => f.eval (.pokemon p)

/-- `Hits U f k b b'` (milestone MV2): `b'` is the Bench `b` with exactly `k` of its Pokémon, each
passing `f`, changed by `U`, and the others kept in place. Distinct Pokémon by construction. -/
inductive Hits (U : InPlay → InPlay) (f : Filter) : Nat → List InPlay → List InPlay → Prop where
  | nil : Hits U f 0 [] []
  | hit {x : InPlay} {k : Nat} {b b' : List InPlay} (hx : f.eval (.pokemon x.top) = true) :
      Hits U f k b b' → Hits U f (k + 1) (x :: b) (U x :: b')
  | keep {x : InPlay} {k : Nat} {b b' : List InPlay} :
      Hits U f k b b' → Hits U f k (x :: b) (x :: b')

/-- The triggered Abilities of a Pokémon in play at `sp` that fire on `ev` (`Ability.trigOn`), its
own and those its Tools give it (`InPlay.abilities`). -/
def InPlay.trigs (ev : TrigEvent) (sp : Spot) (p : InPlay) : List Ability :=
  p.abilities.filter (Ability.trigOn ev sp)

/-- The `ev` triggers of an optional Pokémon in the Active Spot. -/
def optTrigs (ev : TrigEvent) : Option InPlay → List Ability
  | none => []
  | some p => p.trigs ev .active

/-- The `oppBenched` triggers (milestone MV7) of the opponent of the player to move: those of the
opponent's Active Pokémon and of their Benched Pokémon, which fire when the player's Active Pokémon
moves to the Bench during their turn. -/
def GameState.benchedTrigs (g : GameState) : List Ability :=
  optTrigs .oppBenched g.opp.active ++ g.opp.bench.flatMap (InPlay.trigs .oppBenched .bench)

/-- **Raise the `oppBenched` event** (milestone MV7): the player to move's Active Pokémon has just
moved to the Bench (a retreat, or a switch of their own Active Pokémon). The record
`GameState.pend` is set when the opponent has such a trigger in play, and left as it was otherwise,
so a game without one is unchanged. -/
def GameState.noteBenched (g : GameState) : GameState :=
  { g with pend := g.pend || !g.benchedTrigs.isEmpty }

/-- The event of a switch of the `w` player's Active Pokémon: raised for the player's own (`.own`, in
their turn); a switch of the opponent's Active Pokémon (`.opp`) is not "during their turn". -/
def Whose.noteBenched : Whose → GameState → GameState
  | .own, g => g.noteBenched
  | .opp, g => g

/-- The `oppBenched` triggers depend on the opponent's Pokémon in play only through their Abilities:
a map of the Pokémon in play that keeps the Abilities (both clamps) keeps them. -/
theorem GameState.benchedTrigs_of_map {f f' : InPlay → InPlay}
    (hab : ∀ p, (f p).abilities = p.abilities) (hab' : ∀ p, (f' p).abilities = p.abilities)
    {g g' : GameState} (ha : g'.opp.active = g.opp.active.map f)
    (hb : g'.opp.bench = g.opp.bench.map f') : g'.benchedTrigs = g.benchedTrigs := by
  have htr : ∀ sp p, (f p).trigs .oppBenched sp = p.trigs .oppBenched sp := fun sp p => by
    simp only [InPlay.trigs, hab p]
  have htr' : ∀ sp p, (f' p).trigs .oppBenched sp = p.trigs .oppBenched sp := fun sp p => by
    simp only [InPlay.trigs, hab' p]
  have hfl : ∀ (b : List InPlay), (b.map f').flatMap (InPlay.trigs .oppBenched .bench) =
      b.flatMap (InPlay.trigs .oppBenched .bench) := fun b => by
    induction b with
    | nil => rfl
    | cons p ps ih => simp only [List.map_cons, List.flatMap_cons, htr', ih]
  unfold GameState.benchedTrigs
  rw [ha, hb, hfl]
  cases g.opp.active with
  | none => rfl
  | some p => simp only [Option.map_some, optTrigs, htr]

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
  /-- the damage step: the amount evaluates to `n`, and the calculation `GameState.dealtI ig n`
  (`GameState.dealt n` when `ig` switches nothing off) gives the damage placed -/
  | damage {g : GameState} {p : InPlay} {a : Amt} {ig : Ign} {n : Nat} (hv : a.Val g n)
      (h : g.opp.active = some p) :
      Run (.damage a ig) g
        { g with opp := { g.opp with active := some { p with damage := p.damage + g.dealtI ig n } } }
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
  effects from attacks", rulebook 2023 p. 12; since milestone MV4 its attack locks end too,
  `InPlay.unlock`); `q` has moved to the Active Spot, which is recorded when the switch is the
  player's own (milestone MV2, `Whose.mover`); a switch of the player's own Active Pokémon raises
  the `oppBenched` event (milestone MV7, `Whose.noteBenched`) -/
  | switch {g : GameState} {a q : InPlay} {b₁ b₂ : List InPlay} (w : Whose)
      (ha : (g.side w).active = some a) (hb : (g.side w).bench = b₁ ++ q :: b₂) :
      Run (.switch w) g (w.noteBenched
        (g.updSide w fun s => { s with active := some (w.mover q), bench := b₁ ++ a.cure.unlock :: b₂ }))
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
  /-- damage or counters on `m` distinct Benched Pokémon of the `w` player passing `f`, or on all
  that pass if fewer do (milestone MV2) -/
  | benchSome {g : GameState} {b' : List InPlay} (w : Whose) (m : Nat) (f : Filter) (dmg : Bool)
      (n : Nat)
      (h : Hits (InPlay.hitWith dmg n) f (min m (benchElig f (g.side w).bench)) (g.side w).bench b') :
      Run (.benchSome w m f dmg n) g (g.updSide w fun s => { s with bench := b' })
  /-- a zone-move primitive (milestone MV) on the `w` player's zones -/
  | zone {e : Effect} {w : Whose} {g : GameState} {s' : PlayerState} (hw : e.zSide = some w)
      (h : ZStep e (g.side w) s') : Run e g (g.updSide w fun s => s.setZones s')
  /-- move a damage counter between the player's own Pokémon (milestone M8a) -/
  | moveCounter {g : GameState} {f : Filter} {noKO : Bool} {a' : Option InPlay}
      {b' : List InPlay} (h : CMove f noKO (g.hpOf .own) g.cur.active g.cur.bench a' b') :
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

/-! ## `Hits` (milestone MV2) -/

namespace Hits

variable {U : InPlay → InPlay} {f : Filter}

/-- A function of a Bench that is unchanged when one Pokémon is replaced by its image under `U`
(element by element) is unchanged by `Hits`. -/
theorem congr {β : Type} (F : List InPlay → β)
    (hF : ∀ x y b₁ b₂, (y = x ∨ y = U x) → F b₁ = F b₂ → F (y :: b₁) = F (x :: b₂))
    {k : Nat} {b b' : List InPlay} (h : Hits U f k b b') : F b' = F b := by
  induction h with
  | nil => rfl
  | hit _ _ ih => exact hF _ _ _ _ (.inr rfl) ih
  | keep _ ih => exact hF _ _ _ _ (.inl rfl) ih

/-- A property of Pokémon kept by `U` holds on the new Bench if it held on the old one. -/
theorem forall_of {Q : InPlay → Prop} (hU : ∀ x, Q x → Q (U x)) {k : Nat} {b b' : List InPlay}
    (h : Hits U f k b b') (hb : ∀ x ∈ b, Q x) : ∀ y ∈ b', Q y := by
  induction h with
  | nil => intro y hy; cases hy
  | hit _ _ ih =>
      intro y hy
      cases hy with
      | head => exact hU _ (hb _ (.head _))
      | tail _ hy => exact ih (fun x hx => hb x (.tail _ hx)) y hy
  | keep _ ih =>
      intro y hy
      cases hy with
      | head => exact hb _ (.head _)
      | tail _ hy => exact ih (fun x hx => hb x (.tail _ hx)) y hy

/-- Images of a Bench under `P` are unchanged when `U` does not change `P`. -/
theorem map_eq {β : Type} {P : InPlay → β} (hP : ∀ x, P (U x) = P x) {k : Nat}
    {b b' : List InPlay} (h : Hits U f k b b') : b'.map P = b.map P :=
  h.congr (fun l => l.map P) fun x y _ _ hy he => by
    rcases hy with rfl | rfl <;> simp only [List.map_cons, hP, he]

/-- **`Hits` transfers along any map `C` of Pokémon that keeps the top card and commutes with `U`
up to `C`** (both clamps are such maps, `Pokemon/Damage.lean`): a Bench with the same image under
`C` has a `Hits` with the same count, whose result has the same image. -/
theorem transfer {C : InPlay → InPlay} (hC : ∀ x y, C y = C x → C (U y) = C (U x))
    (ht : ∀ x y, C y = C x → y.top = x.top) {k : Nat} {b b' : List InPlay}
    (h : Hits U f k b b') : ∀ {e : List InPlay}, e.map C = b.map C →
      ∃ e', Hits U f k e e' ∧ e'.map C = b'.map C := by
  induction h with
  | nil =>
      intro e he
      cases e with
      | nil => exact ⟨[], .nil, rfl⟩
      | cons _ _ => simp at he
  | @hit x _ _ _ hx _ ih =>
      intro e he
      cases e with
      | nil => simp at he
      | cons y e =>
          simp only [List.map_cons, List.cons.injEq] at he
          obtain ⟨e', h', he'⟩ := ih he.2
          exact ⟨U y :: e', .hit (by rw [ht _ _ he.1]; exact hx) h',
            by simp only [List.map_cons, hC _ _ he.1, he']⟩
  | keep _ ih =>
      intro e he
      cases e with
      | nil => simp at he
      | cons y e =>
          simp only [List.map_cons, List.cons.injEq] at he
          obtain ⟨e', h', he'⟩ := ih he.2
          exact ⟨y :: e', .keep h', by simp only [List.map_cons, he.1, he']⟩

end Hits

/-- Benches with the same image under a map that keeps the top card have the same eligible
count. -/
theorem benchElig_congr {C : InPlay → InPlay} (ht : ∀ x y, C y = C x → y.top = x.top)
    (f : Filter) : ∀ {e b : List InPlay}, e.map C = b.map C → benchElig f e = benchElig f b
  | [], [], _ => rfl
  | [], _ :: _, he => by simp at he
  | _ :: _, [], he => by simp at he
  | y :: e, x :: b, he => by
      simp only [List.map_cons, List.cons.injEq] at he
      have ih := benchElig_congr ht f he.2
      simp only [benchElig, List.map_cons, List.countP_cons, ht _ _ he.1] at ih ⊢
      rw [ih]

/-- The state as the opponent sees it: the two players exchanged (milestone M8b). Effects of the
language act for the player to move (`.own`); a trigger of the other player resolves on the
exchanged state. -/
def GameState.swap (g : GameState) : GameState :=
  { g with cur := g.opp, opp := g.cur, curIsFirst := !g.curIsFirst }

@[simp] theorem GameState.swap_swap (g : GameState) : g.swap.swap = g := by
  cases g; simp only [GameState.swap, Bool.not_not]

/-- **Resolving triggers** (milestone M8b): the triggers `l` of the opponent of the player to move,
one after another, each with "this Pokémon" where the event leaves it (`TrigEvent.place`): its effect
resolves on the exchanged state (`GameState.swap`) by `Run`, as a whole, and the state is exchanged
back; an optional one (`AbilityUse.optional`, "you may") may be declined instead. -/
inductive Fire (ev : TrigEvent) : List Ability → GameState → GameState → Prop where
  | nil (g : GameState) : Fire ev [] g g
  | run {ab : Ability} {l : List Ability} {g g₁ g₂ : GameState}
      (hk : (ab.script ev.place).trigOk = true)
      (hr : Run (ab.script ev.place) g.swap g₁) (ht : Fire ev l g₁.swap g₂) :
      Fire ev (ab :: l) g g₂
  | decline {ab : Ability} {l : List Ability} {g g₂ : GameState}
      (ho : ab.use.optional = true) (ht : Fire ev l g g₂) : Fire ev (ab :: l) g g₂

end Pokemon
