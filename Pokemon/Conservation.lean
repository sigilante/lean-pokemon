import Pokemon.Rules
import Pokemon.ListPerm

/-!
# Conservation of cards, and where finiteness can fail

`Run.perm`, `TRun.perm`, `Move.perm`, `Reach.perm`: legal play permutes the cards in the game.
The list `GameState.allCards` of every physical card in every zone of a reachable state is a
permutation of that list for the start state, for decks whose text is expressible in
`Effect`. No card is created, destroyed or altered. `Reach.cards_eq` (the NUMBER of cards is
constant) is a corollary.

`counters_unbounded`: inside the resolution of a single effect by `Run` (an attack's effect;
a statement about `Run`, not `Reach`), damage on the opponent's Active Pokémon is unbounded.
`DamageBounded` therefore cannot be an invariant of all reachable states: an attack can leave a
Pokémon far above its HP, and the Knock Out is the next move. `Damage` treats this with a clamp.
(A Trainer card's effect, resolved by `TRun`, Knocks Out at once a Pokémon whose damage reaches
its HP, but a single primitive step can still overshoot it.)
-/

namespace Pokemon

theorem InPlay.cardList_length (p : InPlay) : p.cardList.length = p.cards := by
  simp [InPlay.cardList, InPlay.cards] <;> omega

theorem optCardList_unfresh (o : Option InPlay) :
    optCardList (o.map InPlay.unfresh) = optCardList o := by
  cases o <;> rfl

theorem benchCardList_unfresh (b : List InPlay) :
    benchCardList (b.map InPlay.unfresh) = benchCardList b := by
  induction b with
  | nil => rfl
  | cons p ps ih => simp only [List.map, benchCardList, ih]; rfl

theorem optCardList_setMarks (f : Marks → Marks) (o : Option InPlay) :
    optCardList (o.map (InPlay.setMarks f)) = optCardList o := by
  cases o <;> rfl

theorem benchCardList_setMarks (f : Marks → Marks) (b : List InPlay) :
    benchCardList (b.map (InPlay.setMarks f)) = benchCardList b := by
  induction b with
  | nil => rfl
  | cons p ps ih => simp only [List.map, benchCardList, ih]; rfl

theorem benchCardList_addDamage (n : Nat) (b : List InPlay) :
    benchCardList (b.map (InPlay.addDamage n)) = benchCardList b := by
  induction b with
  | nil => rfl
  | cons p ps ih => simp only [List.map, benchCardList, ih]; rfl

theorem benchCardList_append (a b : List InPlay) :
    benchCardList (a ++ b) = benchCardList a ++ benchCardList b := by
  induction a with
  | nil => rfl
  | cons p ps ih => simp only [List.cons_append, benchCardList, ih, List.append_assoc]

@[simp] theorem InPlay.inflict_top (c : Condition) (p : InPlay) : (p.inflict c).top = p.top := by
  cases c <;> rfl
@[simp] theorem InPlay.inflict_under (c : Condition) (p : InPlay) :
    (p.inflict c).under = p.under := by cases c <;> rfl
@[simp] theorem InPlay.inflict_energy (c : Condition) (p : InPlay) :
    (p.inflict c).energy = p.energy := by cases c <;> rfl
@[simp] theorem InPlay.inflict_tools (c : Condition) (p : InPlay) :
    (p.inflict c).tools = p.tools := by cases c <;> rfl

/-- Taking Prize cards splits the Prize list into the cards taken and the cards left. -/
theorem count_prizes (n : Nat) (l : List Card) (x : Card) :
    List.count x l = List.count x (l.take n) + List.count x (l.drop n) := by
  rw [← List.count_append, List.take_append_drop]

/-- Close a goal `l₁.Perm l₂` by comparing counts after unfolding `allCards`. -/
macro "perm_count" "[" hs:Lean.Parser.Tactic.simpLemma,* "]" : tactic =>
  `(tactic| (
    refine ListPerm.perm_of_count fun x => ?_
    simp only [GameState.allCards, PlayerState.allCards, List.count_append, List.count_cons,
      List.count_nil, optCardList, benchCardList, benchCardList_append, InPlay.cardList,
      InPlay.ofBasic, InPlay.cure, InPlay.inflict_top, InPlay.inflict_under,
      InPlay.inflict_energy, InPlay.inflict_tools, stadiumCardList, $hs,*] <;>
    omega))

/-- Resolving an effect permutes the cards in the game: no card is created, destroyed or
changed. -/
theorem Run.perm {e : Effect} {g g' : GameState} (h : Run e g g') :
    g'.allCards.Perm g.allCards := by
  induction h with
  | skip => exact .refl _
  | draw h => perm_count [h]
  | drawEmpty => exact .refl _
  | heal n h => perm_count [h]
  | counters n h => perm_count [h]
  | inflict c h => perm_count [h]
  | poisonUp n h hp => perm_count [h]
  | poisonUpSkip => exact .refl _
  | cure h => perm_count [h]
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | scale w k hs h => perm_count [h]
  | selfDamage n h => perm_count [h]
  | healAll h => perm_count [h]
  | @touchActive e w f g p he h =>
      cases w <;> simp only [GameState.side] at h <;>
        perm_count [h, GameState.updSide, InPlay.setMarks]
  | @touchBench e w f g q b₁ b₂ he h =>
      cases w <;> simp only [GameState.side] at h <;>
        perm_count [h, GameState.updSide, InPlay.setMarks]
  | unmark w m g =>
      cases w <;>
        simp only [GameState.allCards, PlayerState.allCards, GameState.updSide,
          PlayerState.unmark, optCardList_setMarks, benchCardList_setMarks] <;> exact .refl _
  | linger w s m g =>
      cases w <;> simp only [GameState.allCards, PlayerState.allCards, GameState.updSide] <;>
        exact .refl _
  | @benchCounters g q b₁ b₂ w n h =>
      cases w <;> simp only [GameState.side] at h <;> perm_count [h, GameState.updSide]
  | benchCountersNone => exact .refl _
  | spreadCounters w n g =>
      cases w <;>
        simp only [GameState.allCards, PlayerState.allCards, GameState.updSide,
          benchCardList_addDamage] <;> exact .refl _
  | benchHeal n h => perm_count [h]
  | benchHealNone => exact .refl _
  | damage n h => perm_count [h]
  | drain n h hq => perm_count [h, hq]
  | shuffle h =>
      have := fun x => h.count_eq x
      perm_count [this]
  | search h => perm_count [h]
  | handToBottom h =>
      have := fun x => h.count_eq x
      perm_count [this]
  | seq _ _ ih₁ ih₂ => exact ih₂.trans ih₁
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact .refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₂.trans ih₁

/-- A Knock Out move permutes the cards in the game. -/
theorem KOMove.perm {g g' : GameState} (h : KOMove g g') : g'.allCards.Perm g.allCards := by
  cases h with
  | @knockOut p _ _ ha hk hp =>
      perm_count [ha, PlayerState.takePrizes, count_prizes p.top.prizeCount g.cur.prizes]
  | promote ha hb => perm_count [ha, hb]
  | noPokemon ha hb => exact .refl _
  | @knockOutOwn p _ _ ha hk hp =>
      perm_count [ha, PlayerState.takePrizes, count_prizes p.top.prizeCount g.opp.prizes]
  | promoteOwn ha hb => perm_count [ha, hb]
  | noPokemonOwn ha hb => exact .refl _
  | @knockOutBench p _ _ _ _ hb hk hp =>
      perm_count [hb, PlayerState.takePrizes, count_prizes p.top.prizeCount g.cur.prizes]
  | @knockOutBenchOwn p _ _ _ _ hb hk hp =>
      perm_count [hb, PlayerState.takePrizes, count_prizes p.top.prizeCount g.opp.prizes]

/-- Taking the Knock Outs permutes the cards in the game. -/
theorem Resolve.perm {g g' : GameState} (h : Resolve g g') : g'.allCards.Perm g.allCards := by
  induction h with
  | done => exact .refl _
  | step _ hm _ ih => exact ih.trans hm.perm

/-- Resolving a Trainer card's effect, Knock Outs included, permutes the cards in the game:
a Knock Out in mid-effect moves the Knocked Out Pokémon's cards to its owner's discard pile and
a Prize card to the other player's hand. -/
theorem TRun.perm {e : Effect} {g g' : GameState} (h : TRun e g g') :
    g'.allCards.Perm g.allCards := by
  induction h with
  | prim _ _ hr hk => exact hk.perm.trans hr.perm
  | stop => exact .refl _
  | iteT _ _ _ _ ih => exact ih
  | iteF _ _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ih₂.trans ih₁
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact .refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₂.trans ih₁

/-- A legal move permutes the cards in the game. -/
theorem Move.perm {g g' : GameState} (h : Move g g') : g'.allCards.Perm g.allCards := by
  cases h with
  | playBasic hh hs hhp hb => perm_count [hh]
  | attach hh hf ha => perm_count [hh, ha]
  | evolve hh ha he hfr hf => perm_count [hh, ha]
  | attachBench hh hf hb => perm_count [hh, hb]
  | evolveBench hh hb => perm_count [hh, hb]
  | retreat ha hb hr he hp hs => perm_count [ha, hb, he]
  | item hh hbt hst hr =>
      refine hr.perm.trans ?_
      perm_count [hh]
  | supporter hh hs hbt hst hr =>
      refine hr.perm.trans ?_
      perm_count [hh]
  | attack ha hm hc hs hn hf hbt hst hr => exact hr.perm
  | attackConfused ha hm hc hs hn hf => perm_count [ha]
  | @knockOut p _ _ ha hk hp =>
      perm_count [ha, PlayerState.takePrizes, count_prizes p.top.prizeCount g.cur.prizes]
  | promote ha hb => perm_count [ha, hb]
  | noPokemon ha hb => exact .refl _
  | @knockOutOwn p _ _ ha hk hp =>
      perm_count [ha, PlayerState.takePrizes, count_prizes p.top.prizeCount g.opp.prizes]
  | promoteOwn ha hb => perm_count [ha, hb]
  | noPokemonOwn ha hb => exact .refl _
  | @knockOutBench p _ _ _ _ hb hk hp =>
      perm_count [hb, PlayerState.takePrizes, count_prizes p.top.prizeCount g.cur.prizes]
  | @knockOutBenchOwn p _ _ _ _ hb hk hp =>
      perm_count [hb, PlayerState.takePrizes, count_prizes p.top.prizeCount g.opp.prizes]
  | endTurn fa sa ca fb sb cb ha hb hk hbt =>
      simp only [GameState.allCards, PlayerState.allCards, PlayerState.unfresh,
        benchCardList_unfresh]
      perm_count [ha, hb, InPlay.checkup, InPlay.unfresh]
  | startTurn hbt ha hb hk hd => perm_count [hd]
  | deckOut hbt ha hb hk hd => exact .refl _

/-- Legal play permutes the cards in the game: every reachable state holds exactly the
starting cards, each with its starting multiplicity. -/
theorem Reach.perm {g₀ g : GameState} (h : Reach g₀ g) : g.allCards.Perm g₀.allCards := by
  induction h with
  | refl => exact .refl _
  | step _ _ hm ih => exact hm.perm.trans ih

theorem optCards_eq_length (o : Option InPlay) : optCards o = (optCardList o).length := by
  cases o <;> simp [optCards, optCardList, InPlay.cardList_length]

theorem benchCards_eq_length (b : List InPlay) : benchCards b = (benchCardList b).length := by
  induction b with
  | nil => rfl
  | cons p ps ih => simp [benchCards, benchCardList, ih, InPlay.cardList_length]

theorem GameState.cards_eq_length (g : GameState) : g.cards = g.allCards.length := by
  cases hs : g.stadium <;>
    simp [GameState.cards, GameState.allCards, PlayerState.cards, PlayerState.allCards,
      optCards_eq_length, benchCards_eq_length, stadiumCards, stadiumCardList, hs] <;> omega

/-- Corollary of `Reach.perm`: legal play never changes the number of cards in the game. -/
theorem Reach.cards_eq {g₀ g : GameState} (h : Reach g₀ g) : g.cards = g₀.cards := by
  rw [GameState.cards_eq_length, GameState.cards_eq_length, h.perm.length_eq]

/-- Inside one effect, damage on the opponent's Active Pokémon can reach any value:
"flip until tails, one counter per heads" is `iter (counters 1)`. -/
theorem counters_unbounded (n : Nat) :
    ∀ (g : GameState) (p : InPlay), g.opp.active = some p →
      ∃ g' p', Run (.iter (.counters 1)) g g' ∧ g'.opp.active = some p' ∧
        p'.damage = p.damage + n := by
  induction n with
  | zero => intro g p h; exact ⟨g, p, .iterNil _ _, h, rfl⟩
  | succ n ih =>
      intro g p h
      obtain ⟨g', p', hr, hp', hd⟩ :=
        ih { g with opp := { g.opp with active := some { p with damage := p.damage + 1 } } }
          { p with damage := p.damage + 1 } rfl
      exact ⟨g', p', .iterCons (.counters 1 h) hr, hp', by simp at hd; omega⟩

/-- Inside one effect, the Poison strength of a Poisoned opposing Active Pokémon can reach any
value: `iter (poisonUp 1)` raises `poisonUp` by one per round. Unlike damage, `poisonUp` is not
reset by a Knock Out check, so `Damage` clamps it too. -/
theorem poisonUp_unbounded (n : Nat) :
    ∀ (g : GameState) (p : InPlay), g.opp.active = some p → p.poisoned = true →
      ∃ g' p', Run (.iter (.poisonUp 1)) g g' ∧ g'.opp.active = some p' ∧
        p'.poisonUp = p.poisonUp + n := by
  induction n with
  | zero => intro g p h _; exact ⟨g, p, .iterNil _ _, h, rfl⟩
  | succ n ih =>
      intro g p h hp
      obtain ⟨g', p', hr, hp', hd⟩ :=
        ih { g with opp := { g.opp with active := some { p with poisonUp := p.poisonUp + 1 } } }
          { p with poisonUp := p.poisonUp + 1 } rfl hp
      exact ⟨g', p', .iterCons (.poisonUp 1 h hp) hr, hp', by simp at hd; omega⟩

/-! ## Where the cards of the Pokémon in play are -/

theorem GameState.top_mem_cur_active {g : GameState} {a : InPlay}
    (ha : g.cur.active = some a) : Card.pokemon a.top ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, optCardList, ha, InPlay.cardList]

theorem GameState.top_mem_opp_active {g : GameState} {a : InPlay}
    (ha : g.opp.active = some a) : Card.pokemon a.top ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, optCardList, ha, InPlay.cardList]

theorem mem_benchCardList {p : InPlay} {x : Card} (hx : x ∈ p.cardList) :
    ∀ {b : List InPlay}, p ∈ b → x ∈ benchCardList b
  | _ :: _, .head _ => List.mem_append_left _ hx
  | _ :: _, .tail _ h => List.mem_append_right _ (mem_benchCardList hx h)

theorem GameState.top_mem_cur_bench {g : GameState} {a : InPlay}
    (ha : a ∈ g.cur.bench) : Card.pokemon a.top ∈ g.allCards := by
  have := mem_benchCardList (x := Card.pokemon a.top) (.head _) ha
  simp [GameState.allCards, PlayerState.allCards, this]

theorem GameState.top_mem_opp_bench {g : GameState} {a : InPlay}
    (ha : a ∈ g.opp.bench) : Card.pokemon a.top ∈ g.allCards := by
  have := mem_benchCardList (x := Card.pokemon a.top) (.head _) ha
  simp [GameState.allCards, PlayerState.allCards, this]

theorem GameState.mem_allCards_of_hand {g : GameState} {x : Card} (hx : x ∈ g.cur.hand) :
    x ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, hx]

end Pokemon
