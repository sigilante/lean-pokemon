import Pokemon.State

/-!
# Semantics of effects

`Run e g g'` holds when resolving effect `e` in state `g` can produce `g'`. The relation is
nondeterministic: player choices, coin flips and shuffles are all branches of it. That is
the right shape for reachability questions, and it is silent about probability.
-/

namespace Pokemon

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
  | shuffle {g : GameState} {d : List Card} (h : d.Perm g.cur.deck) :
      Run .shuffle g { g with cur := { g.cur with deck := d } }
  | search {g : GameState} {l₁ l₂ : List Card} {c : Card} (h : g.cur.deck = l₁ ++ c :: l₂) :
      Run .search g { g with cur := { g.cur with deck := l₁ ++ l₂, hand := c :: g.cur.hand } }
  | handToBottom {g : GameState} {hs : List Card} (h : hs.Perm g.cur.hand) :
      Run .handToBottom g { g with cur := { g.cur with deck := g.cur.deck ++ hs, hand := [] } }
  | seq {a b : Effect} {g₁ g₂ g₃ : GameState} :
      Run a g₁ g₂ → Run b g₂ g₃ → Run (.seq a b) g₁ g₃
  | choiceL {a b : Effect} {g g' : GameState} : Run a g g' → Run (.choice a b) g g'
  | choiceR {a b : Effect} {g g' : GameState} : Run b g g' → Run (.choice a b) g g'
  | iterNil (a : Effect) (g : GameState) : Run (.iter a) g g
  | iterCons {a : Effect} {g₁ g₂ g₃ : GameState} :
      Run a g₁ g₂ → Run (.iter a) g₂ g₃ → Run (.iter a) g₁ g₃

end Pokemon
