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
Pokémon (`benchCounters`, `spreadCounters`) and heal one (`benchHeal`, the one read of a Benched
Pokémon's damage, by truncated subtraction). The damage step also reads the two Active Pokémon's types,
Weakness and Resistance, and both players' modifiers (`GameState.dealt`). Inside one `Run` nothing is Knocked Out, so damage may exceed HP and
these reads see the excess. `Run` is the semantics of an attack's effect, where the rulebook
checks for Knock Outs only at the end of the attack. The effect of an Item or Supporter card is
resolved by `TRun` (in `Pokemon.Rules`), which uses `Run` for one primitive step at a time and
takes every Knock Out at once after each step.
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

/-- An amount evaluates the same in a state whose Active Pokémon have the same damage. -/
theorem Amt.Val.congr {a : Amt} {g₁ g₂ : GameState} {n : Nat} (h : a.Val g₁ n)
    (hc : ∀ w p, g₁.activeOf w = some p → ∃ q, g₂.activeOf w = some q ∧ q.damage = p.damage) :
    a.Val g₂ n := by
  induction h with
  | const n g => exact .const n g₂
  | per k h =>
      obtain ⟨q, hq, hd⟩ := hc _ _ h
      rw [← hd]; exact .per k hq
  | add _ _ ih₁ ih₂ => exact .add (ih₁ hc) (ih₂ hc)
  | sub _ _ ih₁ ih₂ => exact .sub (ih₁ hc) (ih₂ hc)
  | manyNil a g => exact .manyNil a g₂
  | manyCons _ _ ih₁ ih₂ => exact .manyCons (ih₁ hc) (ih₂ hc)

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

/-- A printed number evaluates to itself. -/
theorem Amt.Val.const_inv {n m : Nat} {g : GameState} (h : (Amt.const n).Val g m) : m = n := by
  cases h; rfl

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
      (h : g.activeOf t.whose = some p) (ht : t.eval p = true) :
      Run a g g' → Run (.ite t a b) g g'
  | iteF {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay}
      (h : g.activeOf t.whose = some p) (ht : t.eval p = false) :
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
  | seq {a b : Effect} {g₁ g₂ g₃ : GameState} :
      Run a g₁ g₂ → Run b g₂ g₃ → Run (.seq a b) g₁ g₃
  | choiceL {a b : Effect} {g g' : GameState} : Run a g g' → Run (.choice a b) g g'
  | choiceR {a b : Effect} {g g' : GameState} : Run b g g' → Run (.choice a b) g g'
  | iterNil (a : Effect) (g : GameState) : Run (.iter a) g g
  | iterCons {a : Effect} {g₁ g₂ g₃ : GameState} :
      Run a g₁ g₂ → Run (.iter a) g₂ g₃ → Run (.iter a) g₁ g₃

end Pokemon
