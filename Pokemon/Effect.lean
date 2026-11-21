import Pokemon.State

/-!
# Semantics of effects

`Run e g g'` holds when resolving effect `e` in state `g` can produce `g'`. The relation is
nondeterministic: player choices, coin flips and shuffles are all branches of it. That is
the right shape for reachability questions, and it is silent about probability.

Effects read the state only through the two Active Pokémon: a test (`ite`) on the damage, the
Special Conditions, the markers or the type of either one, and `scale`, which places counters in proportion to the
damage on either one. Inside one `Run` nothing is Knocked Out, so damage may exceed HP and
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

/-- Remove the marker `m` from every Pokémon of one player. -/
def PlayerState.unmark (m : Marker) (s : PlayerState) : PlayerState :=
  { s with active := s.active.map (InPlay.setMarks (Marks.set m false)),
           bench := s.bench.map (InPlay.setMarks (Marks.set m false)) }

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
  | seq {a b : Effect} {g₁ g₂ g₃ : GameState} :
      Run a g₁ g₂ → Run b g₂ g₃ → Run (.seq a b) g₁ g₃
  | choiceL {a b : Effect} {g g' : GameState} : Run a g g' → Run (.choice a b) g g'
  | choiceR {a b : Effect} {g g' : GameState} : Run b g g' → Run (.choice a b) g g'
  | iterNil (a : Effect) (g : GameState) : Run (.iter a) g g
  | iterCons {a : Effect} {g₁ g₂ g₃ : GameState} :
      Run a g₁ g₂ → Run (.iter a) g₂ g₃ → Run (.iter a) g₁ g₃

end Pokemon
