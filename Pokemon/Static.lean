import Pokemon.State

/-!
# Static effects: derived quantities (milestone M6)

A static effect (`Static`, in `Pokemon/Card.lean`) is in force exactly while its source is in play:
a Pokémon's static Ability (`AbilityUse.static`; while the Pokémon is in play, or only at the spot
`Static.src` names), a Tool's static text (`ToolGrant.statics`; while attached, for a holder that
passes the grant's filter), a Stadium's static text (the `statics` of `Card.trainer`; while it is in
play). Nothing about them is stored: the quantities they change are functions of the state, computed
when they are read.

* `GameState.inForce g w sp v`: the static effects in force on a Pokémon (seen through `InPlay.sv`:
  its top card, attached Energy and Tools) of the `w` player at the spot `sp`.
* `GameState.hpOf g w sp p`: its HP, the printed HP plus every `hpPlus` less every `hpMinus` in force,
  stopping at 0 ("derived HP").
* `GameState.sBonus g`, `GameState.sReduce g`: the static damage bonus of the player's Active Pokémon
  against the opponent's, and the static reduction of the opponent's Active Pokémon against the
  player's; they enter the damage calculation at steps 2 and 5 (rulebook 2023 p. 20).
* `GameState.retreatOf g a`: the Retreat Cost of the player's Active Pokémon `a`.

What a derived quantity reads (`GameState.SameField`): the top cards, attached Energy and Tools of
the Pokémon in play and their places, the Stadium in play and its owner. It reads no damage, Poison
strength, Special Condition, marker or store, so both clamps keep it (`GameState.SameField.inForce`).

Bounds: every HP amount is a printed constant or a constant times a count of attached Energy, so
the HP of a Pokémon in play is at most `hpBound` of the cards in the game
(`GameState.hpOf_le_hpBound`), a function of the multiset of cards that play permutes.

No statics: when no card in the game has a static effect (`GameState.NoStatics`), every derived
quantity is the printed one (`GameState.hpOf_noStatics` and the like).
-/

namespace Pokemon

/-- What static effects read of a Pokémon in play: its top card, its attached Energy and its
Tools. -/
structure SView where
  top : PokemonCard
  energy : List Card
  tools : List Card
  deriving DecidableEq

/-- The view of a Pokémon in play. -/
def InPlay.sv (p : InPlay) : SView := ⟨p.top, p.energy, p.tools⟩

/-- The static effects a card attached to a Pokémon whose top card is `p` gives it: a Tool's static
text and its static Abilities, if `p` passes the grant's holder filter. -/
def Card.grantStatics (p : PokemonCard) : Card → List Static
  | .tool _ gr =>
      if gr.holder.eval (.pokemon p) then gr.statics ++ gr.abilities.flatMap Ability.statics else []
  | _ => []

/-- The static effects whose source is the Pokémon in play `v`: its top card's static Abilities and
what its Tools give it. -/
def SView.statics (v : SView) : List Static :=
  v.top.abilities.flatMap Ability.statics ++ v.tools.flatMap (Card.grantStatics v.top)

/-- The static effects of the Stadium in play. -/
def stadiumStatics : Option (Bool × Card) → List Static
  | none => []
  | some (_, c) => c.statics

/-- The Pokémon in play of one player, with their places. -/
def fieldOf (a : Option InPlay) (b : List InPlay) : List (Spot × SView) :=
  (match a with
    | some p => [(Spot.active, p.sv)]
    | none => []) ++ b.map fun p => (Spot.bench, p.sv)

/-- The Pokémon in play of a player, with their places. -/
def PlayerState.field (s : PlayerState) : List (Spot × SView) := fieldOf s.active s.bench

/-- A place condition: none, or the place itself. -/
def Spot.ok : Option Spot → Spot → Bool
  | none, _ => true
  | some t, sp => decide (t = sp)

/-- The Energy condition of a static effect holds on the affected Pokémon. -/
def Static.needOk (s : Static) (v : SView) : Bool :=
  match s.need with
  | none => true
  | some (f, n) => Nat.ble n (v.energy.countP f.eval)

/-- The conditions of a static effect on the affected Pokémon `v` at `sp` hold. -/
def Static.hits (s : Static) (v : SView) (sp : Spot) : Bool :=
  s.filt.eval (.pokemon v.top) && Spot.ok s.tgt sp && s.needOk v

def Sel.isSelf : Sel → Bool
  | .self => true
  | _ => false

/-- A source on the affected Pokémon's side reaches it. -/
def Sel.fromOwn : Sel → Bool
  | .own => true
  | .all => true
  | _ => false

/-- A source on the other side reaches it. -/
def Sel.fromOpp : Sel → Bool
  | .opp => true
  | .all => true
  | _ => false

/-- A Stadium reaches it (`stOwn`: the Stadium belongs to the affected Pokémon's owner). -/
def Sel.fromStadium (stOwn : Bool) : Sel → Bool
  | .all => true
  | .own => stOwn
  | .opp => !stOwn
  | .self => false

/-- **The static effects in force on the Pokémon `v` at `sp`**, whose owner's Pokémon in play are
`mine`, whose opponent's are `theirs`, with the Stadium effects `st` (owned by `v`'s owner iff
`stOwn`): its own `self` effects (with their source at `sp`), the `own` and `all` effects of its
owner's Pokémon (itself included), the `opp` and `all` effects of the opponent's Pokémon, and the
Stadium's, each only if its conditions on the affected Pokémon hold. -/
def staticsInForce (mine theirs : List (Spot × SView)) (st : List Static) (stOwn : Bool) (v : SView)
    (sp : Spot) : List Static :=
  v.statics.filter (fun s => s.sel.isSelf && Spot.ok s.src sp && s.hits v sp) ++
  (mine.flatMap fun e => e.2.statics.filter fun s =>
    s.sel.fromOwn && Spot.ok s.src e.1 && s.hits v sp) ++
  (theirs.flatMap fun e => e.2.statics.filter fun s =>
    s.sel.fromOpp && Spot.ok s.src e.1 && s.hits v sp) ++
  st.filter (fun s => s.sel.fromStadium stOwn && s.hits v sp)

/-- The other player. -/
def Whose.flip : Whose → Whose
  | .own => .opp
  | .opp => .own

/-- Did the `w` player go first? -/
def GameState.isFirst (g : GameState) : Whose → Bool
  | .own => g.curIsFirst
  | .opp => !g.curIsFirst

/-- Does the Stadium in play belong to the `w` player? -/
def GameState.stOwn (g : GameState) (w : Whose) : Bool :=
  match g.stadium with
  | some (o, _) => o == g.isFirst w
  | none => false

/-- The static effects in force on a Pokémon `v` of the `w` player at `sp`, in the state `g`. -/
def GameState.inForce (g : GameState) (w : Whose) (sp : Spot) (v : SView) : List Static :=
  staticsInForce (g.side w).field (g.side w.flip).field (stadiumStatics g.stadium) (g.stOwn w) v sp

/-- The sum of `f` over a list of static effects. -/
def sumOf (f : Static → Nat) (l : List Static) : Nat := (l.map f).sum

/-- The value of a static amount on the affected Pokémon. -/
def SAmt.val (a : SAmt) (v : SView) : Nat :=
  match a with
  | .const n => n
  | .perEnergy f k => k * v.energy.countP f.eval

def Static.hpPlusAt (v : SView) (s : Static) : Nat :=
  match s.eff with
  | .hpPlus a => a.val v
  | _ => 0

def Static.hpMinus (s : Static) : Nat :=
  match s.eff with
  | .hpMinus n => n
  | _ => 0

/-- The bonus of a static effect on an attacker, against a defender whose top card is `d`. -/
def Static.bonusVs (d : PokemonCard) (s : Static) : Nat :=
  match s.eff with
  | .bonus n vs => if vs.eval (.pokemon d) then n else 0
  | _ => 0

/-- The reduction of a static effect on a defender, against an attacker whose top card is `a`. -/
def Static.reduceFrom (a : PokemonCard) (s : Static) : Nat :=
  match s.eff with
  | .reduce n fr => if fr.eval (.pokemon a) then n else 0
  | _ => 0

def Static.retreatPlus (s : Static) : Nat :=
  match s.eff with
  | .retreatPlus n => n
  | _ => 0

def Static.retreatMinus (s : Static) : Nat :=
  match s.eff with
  | .retreatMinus n => n
  | _ => 0

/-- **Derived HP** (milestone M6): the HP of the Pokémon `p` of the `w` player at `sp` in the state
`g`, in counters: its printed HP, plus every `hpPlus` in force, less every `hpMinus` in force
(stopping at 0). It is computed, never stored: it changes when a source enters or leaves play, when
Energy is attached or removed, when the Pokémon moves between the Active Spot and the Bench, or
evolves. The order "add, then subtract" is the model's: no card text or rule found fixes how a
"set" (Crystal Wall's "its maximum HP is 300", not expressible) or several changes combine. -/
def GameState.hpOf (g : GameState) (w : Whose) (sp : Spot) (p : InPlay) : Nat :=
  p.top.hp + sumOf (Static.hpPlusAt p.sv) (g.inForce w sp p.sv) -
    sumOf Static.hpMinus (g.inForce w sp p.sv)

/-- **The static damage bonus** (milestone M6) of the player's Active Pokémon against the
opponent's: the sum of the `bonus` effects in force on the attacker whose filter the defender
passes; 0 if either Active Spot is empty. -/
def GameState.sBonus (g : GameState) : Nat :=
  match g.cur.active, g.opp.active with
  | some a, some d => sumOf (Static.bonusVs d.top) (g.inForce .own .active a.sv)
  | _, _ => 0

/-- **The static damage reduction** (milestone M6) of the opponent's Active Pokémon against the
player's: the sum of the `reduce` effects in force on the defender whose filter the attacker
passes; 0 if either Active Spot is empty. -/
def GameState.sReduce (g : GameState) : Nat :=
  match g.cur.active, g.opp.active with
  | some a, some d => sumOf (Static.reduceFrom a.top) (g.inForce .opp .active d.sv)
  | _, _ => 0

/-- **The Retreat Cost** (milestone M6) of the player's Active Pokémon `a`: printed, plus every
`retreatPlus` in force, less every `retreatMinus` in force (stopping at 0). It reads no HP, so the
circular case of survey S7 (an HP bonus keyed to the Retreat Cost with a Retreat Cost keyed to the
remaining HP) cannot be written. -/
def GameState.retreatOf (g : GameState) (a : InPlay) : Nat :=
  a.top.retreat + sumOf Static.retreatPlus (g.inForce .own .active a.sv) -
    sumOf Static.retreatMinus (g.inForce .own .active a.sv)

/-- `g.In w sp p`: `p` is a Pokémon in play of the `w` player at `sp`. -/
def GameState.In (g : GameState) : Whose → Spot → InPlay → Prop
  | w, .active, p => (g.side w).active = some p
  | w, .bench, p => p ∈ (g.side w).bench

/-- The damage an attack with base damage `n` does to the opponent's Active Pokémon in state
`g`: `dealtBy` with the Active Pokémon's Weakness and Resistance and both players' modifiers
in effect, the static ones included (milestone M6): the attacker's static bonus (`sBonus`) is added
with its stored bonus at step 2, the defender's static reduction (`sReduce`) subtracted with its
stored reduction at step 5 (as rest-of-game amounts of a copy of the stores, so `dealtBy` is
unchanged). Weakness and Resistance apply to the Active Pokémon only ("Don't apply Weakness and
Resistance for Benched Pokémon!", p. 14); attack damage to Benched Pokémon (`InPlay.hitBench`,
milestone M3) skips the calculation. -/
def GameState.dealt (n : Nat) (g : GameState) : Nat :=
  dealtBy n g.weak g.resist (g.cur.mods.add .always (.bonus g.sBonus))
    (g.opp.mods.add .always (.reduce g.sReduce))

@[simp] theorem Store.add_bonus_zero (t : Store) : t.add .always (.bonus 0) = t := rfl

@[simp] theorem Store.add_reduce_zero (t : Store) : t.add .always (.reduce 0) = t := rfl

/-- Every Pokémon in play has derived HP at most `K`. -/
def GameState.HpBelow (K : Nat) (g : GameState) : Prop :=
  ∀ w sp p, g.In w sp p → g.hpOf w sp p ≤ K

/-- No card of the game has a static damage reduction. -/
def GameState.StaticTame (g : GameState) : Prop :=
  ∀ c ∈ g.allCards, ∀ s ∈ c.statics, s.reduces = false

/-! ## What derived quantities read -/

/-- Two states whose Pokémon in play have the same views, at the same places, with the same Stadium
and the same player to move: every derived quantity agrees (`GameState.SameField.inForce`). -/
structure GameState.SameField (g₁ g₂ : GameState) : Prop where
  cur : g₂.cur.field = g₁.cur.field
  opp : g₂.opp.field = g₁.opp.field
  stadium : g₂.stadium = g₁.stadium
  first : g₂.curIsFirst = g₁.curIsFirst

theorem GameState.SameField.refl (g : GameState) : GameState.SameField g g := ⟨rfl, rfl, rfl, rfl⟩

theorem GameState.SameField.inForce {g₁ g₂ : GameState} (h : GameState.SameField g₁ g₂)
    (w : Whose) (sp : Spot) (v : SView) : g₂.inForce w sp v = g₁.inForce w sp v := by
  cases w <;>
    simp only [GameState.inForce, GameState.side, Whose.flip, GameState.stOwn, GameState.isFirst,
      h.cur, h.opp, h.stadium, h.first]

theorem GameState.SameField.hpOf {g₁ g₂ : GameState} (h : GameState.SameField g₁ g₂)
    (w : Whose) (sp : Spot) {p q : InPlay} (hv : q.sv = p.sv) : g₂.hpOf w sp q = g₁.hpOf w sp p := by
  have ht : q.top = p.top := congrArg SView.top hv
  simp only [GameState.hpOf, h.inForce, hv, ht]

theorem GameState.SameField.retreatOf {g₁ g₂ : GameState} (h : GameState.SameField g₁ g₂)
    {p q : InPlay} (hv : q.sv = p.sv) : g₂.retreatOf q = g₁.retreatOf p := by
  have ht : q.top = p.top := congrArg SView.top hv
  simp only [GameState.retreatOf, h.inForce, hv, ht]

/-- The field determines the view of the Active Pokémon (it is the entry tagged `active`). -/
theorem fieldOf_active {a₁ a₂ : Option InPlay} {b₁ b₂ : List InPlay}
    (h : fieldOf a₁ b₁ = fieldOf a₂ b₂) : a₁.map InPlay.sv = a₂.map InPlay.sv := by
  cases a₁ with
  | none =>
      cases a₂ with
      | none => rfl
      | some p =>
          cases b₁ with
          | nil => simp [fieldOf] at h
          | cons x xs => simp [fieldOf] at h
  | some p =>
      cases a₂ with
      | none =>
          cases b₂ with
          | nil => simp [fieldOf] at h
          | cons x xs => simp [fieldOf] at h
      | some q =>
          simp only [fieldOf, List.singleton_append, List.cons.injEq, Prod.mk.injEq] at h
          simp only [Option.map_some, h.1.2]

/-- Updating the Pokémon in play by maps that keep their views keeps the field. -/
theorem fieldOf_map {F G : InPlay → InPlay} (hF : ∀ p, (F p).sv = p.sv) (hG : ∀ p, (G p).sv = p.sv)
    (a : Option InPlay) (b : List InPlay) : fieldOf (a.map F) (b.map G) = fieldOf a b := by
  have hb : (b.map G).map (fun p => (Spot.bench, p.sv)) = b.map fun p => (Spot.bench, p.sv) := by
    rw [List.map_map]
    exact List.map_congr_left fun p _ => by simp only [Function.comp, hG]
  cases a with
  | none => simp only [fieldOf, Option.map_none, hb]
  | some p => simp only [fieldOf, Option.map_some, hF, hb]

theorem GameState.SameField.sBonus {g₁ g₂ : GameState} (h : GameState.SameField g₁ g₂) :
    g₂.sBonus = g₁.sBonus := by
  have hc := fieldOf_active h.cur
  have ho := fieldOf_active h.opp
  unfold GameState.sBonus
  cases h1 : g₁.cur.active <;> cases h2 : g₂.cur.active <;> cases h3 : g₁.opp.active <;>
    cases h4 : g₂.opp.active <;>
    simp only [h1, h2, h3, h4, Option.map_none, Option.map_some,
      reduceCtorEq, Option.some.injEq] at hc ho ⊢
  next a₁ a₂ d₁ d₂ =>
    rw [h.inForce, hc, show d₂.top = d₁.top from congrArg SView.top ho]

theorem GameState.SameField.sReduce {g₁ g₂ : GameState} (h : GameState.SameField g₁ g₂) :
    g₂.sReduce = g₁.sReduce := by
  have hc := fieldOf_active h.cur
  have ho := fieldOf_active h.opp
  unfold GameState.sReduce
  cases h1 : g₁.cur.active <;> cases h2 : g₂.cur.active <;> cases h3 : g₁.opp.active <;>
    cases h4 : g₂.opp.active <;>
    simp only [h1, h2, h3, h4, Option.map_none, Option.map_some,
      reduceCtorEq, Option.some.injEq] at hc ho ⊢
  next a₁ a₂ d₁ d₂ =>
    rw [h.inForce, ho, show a₂.top = a₁.top from congrArg SView.top hc]

/-! ## Decks with no static effects -/

/-- No card in the game has a static effect. -/
def GameState.NoStatics (g : GameState) : Prop := ∀ c ∈ g.allCards, c.statics = []

theorem GameState.NoStatics.of_perm {g g' : GameState} (h : g.NoStatics)
    (hp : g'.allCards.Perm g.allCards) : g'.NoStatics :=
  fun c hc => h c (hp.mem_iff.1 hc)

theorem Card.grantStatics_nil {p : PokemonCard} {c : Card} (h : c.statics = []) :
    c.grantStatics p = [] := by
  cases c with
  | tool n gr =>
      simp only [Card.statics] at h
      simp only [Card.grantStatics, h, ite_self]
  | _ => rfl

/-- A Pokémon in play whose cards have no static effect is the source of none. -/
theorem InPlay.sv_statics_nil {p : InPlay} (h : ∀ c ∈ p.cardList, c.statics = []) :
    p.sv.statics = [] := by
  have h1 : p.top.abilities.flatMap Ability.statics = [] := h (.pokemon p.top) (.head _)
  have h2 : p.tools.flatMap (Card.grantStatics p.top) = [] := by
    rw [List.flatMap_eq_nil_iff]
    intro c hc
    exact Card.grantStatics_nil (h c (.tail _ (List.mem_append_right _ hc)))
  simp only [InPlay.sv, SView.statics, h1, h2, List.append_nil]

theorem mem_benchCardList_of {c : Card} {p : InPlay} :
    ∀ {b : List InPlay}, p ∈ b → c ∈ p.cardList → c ∈ benchCardList b
  | _ :: _, .head _, hc => List.mem_append_left _ hc
  | _ :: _, .tail _ hp, hc => List.mem_append_right _ (mem_benchCardList_of hp hc)

/-- The cards of a Pokémon in play are cards of the game. -/
theorem GameState.cardList_sub {g : GameState} {w : Whose} {p : InPlay}
    (h : (g.side w).active = some p ∨ p ∈ (g.side w).bench) {c : Card} (hc : c ∈ p.cardList) :
    c ∈ g.allCards := by
  have hs : c ∈ (g.side w).allCards := by
    simp only [PlayerState.allCards, List.mem_append]
    rcases h with h | h
    · exact .inl (.inr (by simp only [optCardList, h]; exact hc))
    · exact .inr (mem_benchCardList_of h hc)
  simp only [GameState.allCards, List.mem_append]
  cases w
  · exact .inl (.inl hs)
  · exact .inl (.inr hs)

theorem GameState.In.cardList_sub {g : GameState} {w : Whose} {sp : Spot} {p : InPlay}
    (h : g.In w sp p) {c : Card} (hc : c ∈ p.cardList) : c ∈ g.allCards := by
  cases sp
  · exact GameState.cardList_sub (.inl h) hc
  · exact GameState.cardList_sub (.inr h) hc

theorem mem_fieldOf {e : Spot × SView} {a : Option InPlay} {b : List InPlay}
    (h : e ∈ fieldOf a b) : ∃ p, (a = some p ∨ p ∈ b) ∧ e.2 = p.sv := by
  simp only [fieldOf, List.mem_append, List.mem_map] at h
  rcases h with h | ⟨p, hp, rfl⟩
  · cases a with
    | none => nomatch h
    | some p =>
        simp only [List.mem_singleton] at h
        exact ⟨p, .inl rfl, by rw [h]⟩
  · exact ⟨p, .inr hp, rfl⟩

/-- With no static effects in the game, none is in force anywhere. -/
theorem GameState.inForce_noStatics {g : GameState} (hn : g.NoStatics) {w : Whose} {sp : Spot}
    {p : InPlay} (hp : g.In w sp p) (w' : Whose) (sp' : Spot) : g.inForce w' sp' p.sv = [] := by
  have hv : p.sv.statics = [] := InPlay.sv_statics_nil fun c hc => hn c (hp.cardList_sub hc)
  have hf : ∀ (u : Whose) (e : Spot × SView), e ∈ (g.side u).field → e.2.statics = [] := by
    intro u e he
    obtain ⟨q, hq, he2⟩ := mem_fieldOf he
    rw [he2]
    exact InPlay.sv_statics_nil fun c hc => hn c (GameState.cardList_sub hq hc)
  have hst : stadiumStatics g.stadium = [] := by
    unfold stadiumStatics
    split
    · rfl
    · next o c hs =>
        exact hn c (by simp only [GameState.allCards, hs, stadiumCardList, List.mem_append,
          List.mem_singleton, or_true])
  have hm : ∀ (u : Whose) (f : Spot × SView → Static → Bool),
      ((g.side u).field.flatMap fun e => e.2.statics.filter (f e)) = [] := by
    intro u f
    rw [List.flatMap_eq_nil_iff]
    intro e he
    rw [hf u e he]
    rfl
  simp only [GameState.inForce, staticsInForce, hv, hst, List.filter_nil, hm, List.append_nil]

theorem sumOf_nil (f : Static → Nat) : sumOf f [] = 0 := rfl
/-- **No static effect has a source in play** (milestone M6): every Pokémon in play is the source of
none, and the Stadium in play (if any) has none. A property of a state, for witnesses whose start
is built by hand; `GameState.NoStatics` (no card of the game has one) implies it. -/
def GameState.Plain (g : GameState) : Prop :=
  (∀ (u : Whose) (e : Spot × SView), e ∈ (g.side u).field → e.2.statics = []) ∧
    stadiumStatics g.stadium = []

/-- `Plain`, decided (for witnesses: `GameState.plain_of_plainB rfl`). -/
def GameState.plainB (g : GameState) : Bool :=
  ((g.cur.field ++ g.opp.field).all fun e => e.2.statics.isEmpty) &&
    (stadiumStatics g.stadium).isEmpty

theorem GameState.plain_of_plainB {g : GameState} (h : g.plainB = true) : g.Plain := by
  simp only [GameState.plainB, Bool.and_eq_true, List.all_eq_true, List.isEmpty_iff,
    List.mem_append] at h
  refine ⟨fun u e he => ?_, h.2⟩
  cases u
  · exact h.1 e (.inl he)
  · exact h.1 e (.inr he)

/-- With no source in play, no static effect is in force on a Pokémon that is the source of
none. -/
theorem GameState.Plain.inForce {g : GameState} (h : g.Plain) {v : SView} (hv : v.statics = [])
    (w : Whose) (sp : Spot) : g.inForce w sp v = [] := by
  have hm : ∀ (u : Whose) (f : Spot × SView → Static → Bool),
      ((g.side u).field.flatMap fun e => e.2.statics.filter (f e)) = [] := by
    intro u f
    rw [List.flatMap_eq_nil_iff]
    intro e he
    rw [h.1 u e he]
    rfl
  simp only [GameState.inForce, staticsInForce, hv, h.2, List.filter_nil, hm, List.append_nil]

theorem GameState.Plain.sv {g : GameState} (h : g.Plain) {w : Whose} {sp : Spot} {p : InPlay}
    (hp : g.In w sp p) : p.sv.statics = [] := by
  cases sp
  · exact h.1 w (.active, p.sv) (by
      simp only [GameState.In] at hp
      simp only [PlayerState.field, fieldOf, hp, List.mem_append, List.mem_singleton, true_or])
  · exact h.1 w (.bench, p.sv) (by
      simp only [GameState.In] at hp
      simp only [PlayerState.field, fieldOf, List.mem_append, List.mem_map]
      exact .inr ⟨p, hp, rfl⟩)

/-- With no source in play, HP is the printed HP. -/
theorem GameState.Plain.hpOf {g : GameState} (h : g.Plain) {w : Whose} {sp : Spot} {p : InPlay}
    (hp : g.In w sp p) : g.hpOf w sp p = p.top.hp := by
  simp only [GameState.hpOf, h.inForce (h.sv hp), sumOf, List.map_nil, List.sum_nil,
    Nat.add_zero, Nat.sub_zero]

theorem GameState.Plain.retreatOf {g : GameState} (h : g.Plain) {a : InPlay}
    (ha : g.cur.active = some a) : g.retreatOf a = a.top.retreat := by
  simp only [GameState.retreatOf, h.inForce (h.sv (w := .own) (sp := .active) ha), sumOf,
    List.map_nil, List.sum_nil, Nat.add_zero, Nat.sub_zero]

theorem GameState.Plain.sBonus {g : GameState} (h : g.Plain) : g.sBonus = 0 := by
  unfold GameState.sBonus
  split
  · next a d ha hd => rw [h.inForce (h.sv (w := .own) (sp := .active) ha)]; rfl
  · rfl

theorem GameState.Plain.sReduce {g : GameState} (h : g.Plain) : g.sReduce = 0 := by
  unfold GameState.sReduce
  split
  · next a d ha hd => rw [h.inForce (h.sv (w := .opp) (sp := .active) hd)]; rfl
  · rfl

/-- The field of a side whose Pokémon in play are the source of no static effect. -/
theorem fieldOf_plain {a : Option InPlay} {b : List InPlay}
    (ha : ∀ p, a = some p → p.sv.statics = []) (hb : ∀ p ∈ b, p.sv.statics = []) :
    ∀ e ∈ fieldOf a b, e.2.statics = [] := by
  intro e he
  obtain ⟨q, hq, he2⟩ := mem_fieldOf he
  rw [he2]
  rcases hq with hq | hq
  · exact ha q hq
  · exact hb q hq

/-- `Plain`, side by side. -/
theorem GameState.Plain.intro {g : GameState}
    (hca : ∀ p, g.cur.active = some p → p.sv.statics = []) (hcb : ∀ p ∈ g.cur.bench, p.sv.statics = [])
    (hoa : ∀ p, g.opp.active = some p → p.sv.statics = []) (hob : ∀ p ∈ g.opp.bench, p.sv.statics = [])
    (hs : stadiumStatics g.stadium = []) : g.Plain :=
  ⟨fun u => by cases u <;> exact fieldOf_plain ‹_› ‹_›, hs⟩


theorem sumOf_eq_zero {f : Static → Nat} : ∀ {l : List Static}, (∀ s ∈ l, f s = 0) → sumOf f l = 0
  | [], _ => rfl
  | s :: l, h => by
      have := sumOf_eq_zero (l := l) fun x hx => h x (.tail _ hx)
      simp only [sumOf, List.map_cons, List.sum_cons] at this ⊢
      rw [h s (.head _), this]

theorem Card.mem_grantStatics {p : PokemonCard} {c : Card} {s : Static}
    (h : s ∈ c.grantStatics p) : s ∈ c.statics := by
  cases c with
  | tool n gr =>
      simp only [Card.grantStatics] at h
      split at h
      · exact h
      · nomatch h
  | _ => nomatch h

/-- A static effect a Pokémon in play is the source of is printed on one of its cards. -/
theorem InPlay.mem_sv_statics {p : InPlay} {s : Static} (h : s ∈ p.sv.statics) :
    ∃ c ∈ p.cardList, s ∈ c.statics := by
  simp only [InPlay.sv, SView.statics, List.mem_append] at h
  rcases h with h | h
  · exact ⟨.pokemon p.top, .head _, h⟩
  · obtain ⟨c, hc, hs⟩ := List.mem_flatMap.1 h
    exact ⟨c, .tail _ (List.mem_append_right _ hc), Card.mem_grantStatics hs⟩

/-- **Every static effect in force is printed on a card of the game.** -/
theorem GameState.mem_inForce {g : GameState} {w : Whose} {sp : Spot} {p : InPlay}
    (hp : g.In w sp p) {w' : Whose} {sp' : Spot} {s : Static} (hs : s ∈ g.inForce w' sp' p.sv) :
    ∃ c ∈ g.allCards, s ∈ c.statics := by
  have hfield : ∀ (u : Whose) (e : Spot × SView), e ∈ (g.side u).field → s ∈ e.2.statics →
      ∃ c ∈ g.allCards, s ∈ c.statics := by
    intro u e he hse
    obtain ⟨q, hq, he2⟩ := mem_fieldOf he
    rw [he2] at hse
    obtain ⟨c, hc, hsc⟩ := InPlay.mem_sv_statics hse
    exact ⟨c, GameState.cardList_sub hq hc, hsc⟩
  simp only [GameState.inForce, staticsInForce, List.mem_append, List.mem_filter,
    List.mem_flatMap] at hs
  rcases hs with ((⟨h, -⟩ | ⟨e, he, h, -⟩) | ⟨e, he, h, -⟩) | ⟨h, -⟩
  · obtain ⟨c, hc, hsc⟩ := InPlay.mem_sv_statics h
    exact ⟨c, hp.cardList_sub hc, hsc⟩
  · exact hfield _ e he h
  · exact hfield _ e he h
  · unfold stadiumStatics at h
    split at h
    · nomatch h
    · next o c hst =>
        exact ⟨c, by simp only [GameState.allCards, hst, stadiumCardList, List.mem_append,
          List.mem_singleton, or_true], h⟩

/-- **No static reduction in the cards, none in force** (milestone M6). -/
theorem GameState.sReduce_of_staticTame {g : GameState} (h : g.StaticTame) : g.sReduce = 0 := by
  unfold GameState.sReduce
  split
  · next a d ha hd =>
      refine sumOf_eq_zero fun s hs => ?_
      obtain ⟨c, hc, hsc⟩ := g.mem_inForce (w := .opp) (sp := .active) hd hs
      have := h c hc s hsc
      unfold Static.reduceFrom
      unfold Static.reduces at this
      split
      · next n fr he => rw [he] at this; cases this
      · rfl
  · rfl


/-- **With no static effects, HP is the printed HP.** -/
theorem GameState.hpOf_noStatics {g : GameState} (hn : g.NoStatics) {w : Whose} {sp : Spot}
    {p : InPlay} (hp : g.In w sp p) : g.hpOf w sp p = p.top.hp := by
  simp only [GameState.hpOf, g.inForce_noStatics hn hp, sumOf_nil, Nat.add_zero, Nat.sub_zero]

/-- With no static effects, the Retreat Cost of the player's Active Pokémon is the printed one. -/
theorem GameState.retreatOf_noStatics {g : GameState} (hn : g.NoStatics) {a : InPlay}
    (ha : g.cur.active = some a) : g.retreatOf a = a.top.retreat := by
  simp only [GameState.retreatOf, g.inForce_noStatics (w := .own) (sp := .active) hn ha, sumOf_nil,
    Nat.add_zero, Nat.sub_zero]

/-- With no static effects, there is no static damage bonus. -/
theorem GameState.sBonus_noStatics {g : GameState} (hn : g.NoStatics) : g.sBonus = 0 := by
  unfold GameState.sBonus
  split
  · next a d ha hd =>
      rw [g.inForce_noStatics (w := .own) (sp := .active) hn ha]
      rfl
  · rfl

/-- With no static effects, there is no static damage reduction. -/
theorem GameState.sReduce_noStatics {g : GameState} (hn : g.NoStatics) : g.sReduce = 0 := by
  unfold GameState.sReduce
  split
  · next a d ha hd =>
      rw [g.inForce_noStatics (w := .opp) (sp := .active) hn hd]
      rfl
  · rfl

/-! ## The HP bound -/

/-- The largest printed HP among the Pokémon cards in a list (0 if there are none). -/
def maxHp : List Card → Nat
  | [] => 0
  | .pokemon p :: cs => max p.hp (maxHp cs)
  | _ :: cs => maxHp cs

theorem hp_le_maxHp {p : PokemonCard} : ∀ {cs : List Card}, Card.pokemon p ∈ cs → p.hp ≤ maxHp cs
  | [], h => nomatch h
  | c :: cs, h => by
      cases h with
      | head => simp only [maxHp]; omega
      | tail _ h =>
          have := hp_le_maxHp h
          cases c <;> simp only [maxHp] <;> omega

/-- The HP a static effect adds per unit: its constant, or its amount per Energy. -/
def Static.hpUnit (s : Static) : Nat :=
  match s.eff with
  | .hpPlus (.const n) => n
  | .hpPlus (.perEnergy _ k) => k
  | _ => 0

/-- The HP units of a card's static effects. -/
def Card.hpGain (c : Card) : Nat := sumOf Static.hpUnit c.statics

/-- A sum of a weight over a list of cards. -/
def csum (f : Card → Nat) (C : List Card) : Nat := (C.map f).sum

/-- **The HP bound of a list of cards** (milestone M6): the largest printed HP, plus twice the HP
units of all the cards' static effects times one more than the number of cards. Every Pokémon in
play has HP at most `hpBound` of the cards of the game (`GameState.hpOf_le_hpBound`): a static
effect adds at most its unit times one more than the Energy attached, its source is a card of the
game, and a source can reach a Pokémon twice (as `self` and as `own`) at most. A bound, not the
maximum: survey S7 builds 780 by hand from today's constants, and finds Energy-scaled HP bounded
only by the deck. -/
def hpBound (C : List Card) : Nat := maxHp C + 2 * (C.length + 1) * csum Card.hpGain C

theorem sumOf_cons (f : Static → Nat) (s : Static) (l : List Static) :
    sumOf f (s :: l) = f s + sumOf f l := rfl

theorem sumOf_append (f : Static → Nat) (a b : List Static) :
    sumOf f (a ++ b) = sumOf f a + sumOf f b := by
  induction a with
  | nil => simp only [List.nil_append, sumOf_nil, Nat.zero_add]
  | cons s l ih => simp only [List.cons_append, sumOf_cons, ih]; omega

theorem sumOf_filter_le (f : Static → Nat) (q : Static → Bool) (l : List Static) :
    sumOf f (l.filter q) ≤ sumOf f l := by
  induction l with
  | nil => exact Nat.le_refl _
  | cons s l ih =>
      simp only [List.filter_cons]
      split
      · simp only [sumOf_cons]; omega
      · simp only [sumOf_cons]; omega

theorem sumOf_le_mul (f u : Static → Nat) (c : Nat) (hf : ∀ s, f s ≤ c * u s) :
    ∀ l : List Static, sumOf f l ≤ c * sumOf u l
  | [] => Nat.le_refl _
  | s :: l => by
      have := sumOf_le_mul f u c hf l
      simp only [sumOf_cons, Nat.mul_add]
      exact Nat.add_le_add (hf s) this

/-- A sum over a `flatMap`, bounded entry by entry. -/
theorem sumOf_flatMap_le {α : Type} (f : Static → Nat) (g : α → List Static) (h : α → Nat)
    (hg : ∀ x, sumOf f (g x) ≤ h x) : ∀ l : List α, sumOf f (l.flatMap g) ≤ (l.map h).sum
  | [] => Nat.le_refl _
  | x :: l => by
      have := sumOf_flatMap_le f g h hg l
      simp only [List.flatMap_cons, sumOf_append, List.map_cons, List.sum_cons]
      exact Nat.add_le_add (hg x) this

theorem csum_cons (f : Card → Nat) (c : Card) (C : List Card) : csum f (c :: C) = f c + csum f C :=
  rfl

theorem csum_append (f : Card → Nat) (a b : List Card) : csum f (a ++ b) = csum f a + csum f b := by
  induction a with
  | nil => simp only [List.nil_append, csum, List.map_nil, List.sum_nil, Nat.zero_add]
  | cons c l ih => simp only [List.cons_append, csum_cons, ih]; omega

theorem csum_one (C : List Card) : csum (fun _ => 1) C = C.length := by
  induction C with
  | nil => rfl
  | cons c l ih => simp only [csum_cons, ih, List.length_cons]; omega

theorem Card.grantStatics_le (p : PokemonCard) (c : Card) :
    sumOf Static.hpUnit (c.grantStatics p) ≤ c.hpGain := by
  cases c with
  | tool n gr =>
      simp only [Card.grantStatics, Card.hpGain, Card.statics]
      split
      · exact Nat.le_refl _
      · exact Nat.zero_le _
  | _ => exact Nat.zero_le _

/-- The HP units of the static effects a Pokémon in play is the source of are at most those of its
cards. -/
theorem InPlay.statics_le (p : InPlay) :
    sumOf Static.hpUnit p.sv.statics ≤ csum Card.hpGain p.cardList := by
  have h1 : sumOf Static.hpUnit (p.top.abilities.flatMap Ability.statics) =
      (Card.pokemon p.top).hpGain := rfl
  have h2 : sumOf Static.hpUnit (p.tools.flatMap (Card.grantStatics p.top)) ≤
      csum Card.hpGain p.tools :=
    sumOf_flatMap_le _ _ _ (Card.grantStatics_le p.top) p.tools
  simp only [InPlay.sv, SView.statics, sumOf_append, InPlay.cardList, csum_cons, csum_append]
  omega

/-- The HP units of the sources on one side are at most those of the side's cards in play. -/
theorem fieldOf_le (a : Option InPlay) (b : List InPlay) :
    ((fieldOf a b).map fun e => sumOf Static.hpUnit e.2.statics).sum ≤
      csum Card.hpGain (optCardList a) + csum Card.hpGain (benchCardList b) := by
  have hb : ∀ b : List InPlay,
      ((b.map fun p => (Spot.bench, p.sv)).map fun e => sumOf Static.hpUnit e.2.statics).sum ≤
        csum Card.hpGain (benchCardList b) := by
    intro b
    induction b with
    | nil => exact Nat.le_refl _
    | cons p ps ih =>
        have := p.statics_le
        simp only [List.map_cons, List.sum_cons, benchCardList, csum_append]
        omega
  have := hb b
  cases a with
  | none =>
      simp only [fieldOf, List.nil_append, optCardList, csum, List.map_nil, List.sum_nil,
        Nat.zero_add] at this ⊢
      exact this
  | some p =>
      have hp := p.statics_le
      simp only [fieldOf, List.singleton_append, List.map_cons, List.sum_cons, optCardList]
      omega

/-- The sum of a weight over a player's cards is at least that over the player's cards in play. -/
theorem PlayerState.csum_inPlay_le (f : Card → Nat) (s : PlayerState) :
    csum f (optCardList s.active) + csum f (benchCardList s.bench) ≤ csum f s.allCards := by
  simp only [PlayerState.allCards, csum_append]
  omega

/-- The sum of a weight over the cards of a Pokémon in play is at most that over its side's cards
in play. -/
theorem csum_cardList_le_side (f : Card → Nat) {s : PlayerState} {p : InPlay}
    (h : s.active = some p ∨ p ∈ s.bench) :
    csum f p.cardList ≤ csum f (optCardList s.active) + csum f (benchCardList s.bench) := by
  rcases h with h | h
  · simp only [h, optCardList]; omega
  · have : ∀ b : List InPlay, p ∈ b → csum f p.cardList ≤ csum f (benchCardList b) := by
      intro b hb
      induction b with
      | nil => nomatch hb
      | cons q qs ih =>
          simp only [benchCardList, csum_append]
          cases hb with
          | head => omega
          | tail _ hb => have := ih hb; omega
    have := this _ h
    omega

theorem GameState.csum_allCards (f : Card → Nat) (g : GameState) :
    csum f g.allCards = csum f g.cur.allCards + csum f g.opp.allCards +
      csum f (stadiumCardList g.stadium) := by
  simp only [GameState.allCards, csum_append]

theorem stadiumStatics_le (st : Option (Bool × Card)) :
    sumOf Static.hpUnit (stadiumStatics st) ≤ csum Card.hpGain (stadiumCardList st) := by
  cases st with
  | none => exact Nat.le_refl _
  | some oc =>
      obtain ⟨o, c⟩ := oc
      simp only [stadiumStatics, stadiumCardList, csum_cons, Card.hpGain]
      omega

/-- The HP units of the effects in force on a Pokémon are at most those of its own sources and of
everything in play. -/
theorem staticsInForce_le (mine theirs : List (Spot × SView)) (st : List Static) (o : Bool) (v : SView)
    (sp : Spot) :
    sumOf Static.hpUnit (staticsInForce mine theirs st o v sp) ≤ sumOf Static.hpUnit v.statics +
      (mine.map fun e => sumOf Static.hpUnit e.2.statics).sum +
      (theirs.map fun e => sumOf Static.hpUnit e.2.statics).sum + sumOf Static.hpUnit st := by
  simp only [staticsInForce, sumOf_append]
  have h1 := sumOf_filter_le Static.hpUnit (fun s => s.sel.isSelf && Spot.ok s.src sp && s.hits v sp)
    v.statics
  have h2 := sumOf_flatMap_le Static.hpUnit (fun e => e.2.statics.filter fun s =>
    s.sel.fromOwn && Spot.ok s.src e.1 && s.hits v sp) (fun e => sumOf Static.hpUnit e.2.statics)
    (fun e => sumOf_filter_le _ _ _) mine
  have h3 := sumOf_flatMap_le Static.hpUnit (fun e => e.2.statics.filter fun s =>
    s.sel.fromOpp && Spot.ok s.src e.1 && s.hits v sp) (fun e => sumOf Static.hpUnit e.2.statics)
    (fun e => sumOf_filter_le _ _ _) theirs
  have h4 := sumOf_filter_le Static.hpUnit (fun s => s.sel.fromStadium o && s.hits v sp) st
  omega

/-- One static effect adds at most its unit times one more than the Energy attached. -/
theorem Static.hpPlusAt_le (v : SView) (s : Static) :
    s.hpPlusAt v ≤ (v.energy.length + 1) * s.hpUnit := by
  unfold Static.hpPlusAt Static.hpUnit
  cases s.eff with
  | hpPlus a =>
      cases a with
      | const n => simp only [SAmt.val]; exact Nat.le_mul_of_pos_left n (Nat.succ_pos _)
      | perEnergy f k =>
          simp only [SAmt.val]
          rw [Nat.mul_comm k]
          exact Nat.mul_le_mul_right k (Nat.le_succ_of_le List.countP_le_length)
  | _ => exact Nat.zero_le _

/-- **Derived HP is bounded by the cards of the game** (milestone M6): every Pokémon in play has HP
at most `hpBound g.allCards`. -/
theorem GameState.hpOf_le_hpBound {g : GameState} {w : Whose} {sp : Spot} {p : InPlay}
    (hp : g.In w sp p) : g.hpOf w sp p ≤ hpBound g.allCards := by
  have hside : (g.side w).active = some p ∨ p ∈ (g.side w).bench := by
    cases sp
    · exact .inl hp
    · exact .inr hp
  -- the printed HP
  have htop : p.top.hp ≤ maxHp g.allCards := hp_le_maxHp (hp.cardList_sub (.head _))
  -- the Energy attached
  have hlen : p.energy.length ≤ g.allCards.length := by
    have e1 := csum_cardList_le_side (fun _ => 1) hside
    have e2 := PlayerState.csum_inPlay_le (fun _ => 1) (g.side w)
    have e3 := GameState.csum_allCards (fun _ => 1) g
    have e4 : csum (fun _ => 1) p.cardList = 1 + p.under.length + p.energy.length + p.tools.length := by
      simp only [csum_one, InPlay.cardList, List.length_cons, List.length_append]; omega
    rw [csum_one] at e3
    cases w <;> simp only [GameState.side] at e1 e2 <;> omega
  -- the units of the effects in force
  have hunits : sumOf Static.hpUnit (g.inForce w sp p.sv) ≤ 2 * csum Card.hpGain g.allCards := by
    have i1 := staticsInForce_le (g.side w).field (g.side w.flip).field (stadiumStatics g.stadium)
      (g.stOwn w) p.sv sp
    have i2 := p.statics_le
    have i3 := csum_cardList_le_side Card.hpGain hside
    have i4 := fieldOf_le (g.side w).active (g.side w).bench
    have i5 := fieldOf_le (g.side w.flip).active (g.side w.flip).bench
    have i6 := stadiumStatics_le g.stadium
    have i7 := PlayerState.csum_inPlay_le Card.hpGain g.cur
    have i8 := PlayerState.csum_inPlay_le Card.hpGain g.opp
    have i9 := GameState.csum_allCards Card.hpGain g
    simp only [GameState.inForce, PlayerState.field] at i1 ⊢
    cases w <;> simp only [GameState.side, Whose.flip] at i1 i3 i4 i5 ⊢ <;> omega
  have hplus : sumOf (Static.hpPlusAt p.sv) (g.inForce w sp p.sv) ≤
      (g.allCards.length + 1) * (2 * csum Card.hpGain g.allCards) := by
    have := sumOf_le_mul (Static.hpPlusAt p.sv) Static.hpUnit (p.energy.length + 1)
      (Static.hpPlusAt_le p.sv) (g.inForce w sp p.sv)
    exact Nat.le_trans this (Nat.mul_le_mul (Nat.succ_le_succ hlen) hunits)
  unfold GameState.hpOf hpBound
  have e : 2 * (g.allCards.length + 1) * csum Card.hpGain g.allCards =
      (g.allCards.length + 1) * (2 * csum Card.hpGain g.allCards) := by
    rw [Nat.mul_comm 2, Nat.mul_assoc]
  omega

/-- Derived HP is below `K` everywhere when `hpBound` of the cards is. -/
theorem GameState.hpBelow_of_hpBound {g : GameState} {K : Nat} (h : hpBound g.allCards ≤ K) :
    g.HpBelow K :=
  fun _ _ _ hp => Nat.le_trans (g.hpOf_le_hpBound hp) h

theorem csum_perm (f : Card → Nat) {C D : List Card} (h : C.Perm D) : csum f C = csum f D := by
  induction h with
  | nil => rfl
  | cons x _ ih => simp only [csum_cons, ih]
  | swap x y l => simp only [csum_cons]; omega
  | trans _ _ ih₁ ih₂ => exact ih₁.trans ih₂

theorem maxHp_le {M : Nat} : ∀ {C : List Card}, (∀ p, Card.pokemon p ∈ C → p.hp ≤ M) → maxHp C ≤ M
  | [], _ => Nat.zero_le _
  | c :: cs, h => by
      have ih := maxHp_le (C := cs) fun p hp => h p (.tail _ hp)
      cases c with
      | pokemon p => have := h p (.head _); simp only [maxHp]; omega
      | _ => simpa only [maxHp] using ih

theorem maxHp_perm {C D : List Card} (h : C.Perm D) : maxHp C = maxHp D :=
  Nat.le_antisymm (maxHp_le fun _ hp => hp_le_maxHp (h.mem_iff.1 hp))
    (maxHp_le fun _ hp => hp_le_maxHp (h.mem_iff.2 hp))

/-- `hpBound` depends only on the multiset of cards, which play permutes. -/
theorem hpBound_perm {C D : List Card} (h : C.Perm D) : hpBound C = hpBound D := by
  simp only [hpBound, maxHp_perm h, csum_perm _ h, h.length_eq]

/-- A card list with no static effect has `hpBound` its largest printed HP. -/
theorem hpBound_le_of {C : List Card} {k : Nat} (hs : ∀ c ∈ C, c.statics = [])
    (hh : ∀ p, Card.pokemon p ∈ C → p.hp ≤ k) : hpBound C ≤ k := by
  have h0 : csum Card.hpGain C = 0 := by
    have : ∀ D : List Card, (∀ c ∈ D, c.statics = []) → csum Card.hpGain D = 0 := by
      intro D hD
      induction D with
      | nil => rfl
      | cons c cs ih =>
          rw [csum_cons, ih fun x hx => hD x (.tail _ hx)]
          simp only [Card.hpGain, hD c (.head _), sumOf_nil]
    exact this C hs
  simp only [hpBound, h0, Nat.mul_zero, Nat.add_zero]
  exact maxHp_le hh

end Pokemon
