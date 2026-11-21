import Pokemon.Zone

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

/-- Attack damage to a Benched Pokémon changes only its damage. -/
theorem InPlay.hitBench_fields (n : Nat) (p : InPlay) :
    (p.hitBench n).top = p.top ∧ (p.hitBench n).under = p.under ∧
      (p.hitBench n).energy = p.energy ∧ (p.hitBench n).tools = p.tools ∧
      (p.hitBench n).rot = p.rot ∧ (p.hitBench n).poisoned = p.poisoned ∧
      (p.hitBench n).burned = p.burned ∧ (p.hitBench n).poisonUp = p.poisonUp ∧
      (p.hitBench n).fresh = p.fresh ∧ (p.hitBench n).marks = p.marks := by
  unfold InPlay.hitBench; split <;> exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem InPlay.cardList_hitBench (n : Nat) (p : InPlay) :
    (p.hitBench n).cardList = p.cardList := by
  obtain ⟨h1, h2, h3, h4, -⟩ := p.hitBench_fields n
  simp only [InPlay.cardList, h1, h2, h3, h4]

theorem benchCardList_hitBench (n : Nat) (b : List InPlay) :
    benchCardList (b.map (InPlay.hitBench n)) = benchCardList b := by
  induction b with
  | nil => rfl
  | cons p ps ih => simp only [List.map, benchCardList, ih, InPlay.cardList_hitBench]

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

/-- Char counters on a Bench move no card. -/
theorem BenchChar.cardList {b b' : List InPlay} (h : BenchChar b b') :
    benchCardList b' = benchCardList b := by
  induction h with
  | nil => rfl
  | cons hs _ ih =>
      cases hs with
      | keep => simp only [benchCardList, ih]
      | burn => simp only [benchCardList, ih]; rfl

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

/-- Moving a damage counter moves no card (milestone M8a). -/
theorem CMove.cardLists {f : Filter} {noKO : Bool} {a a' : Option InPlay} {b b' : List InPlay}
    (h : CMove f noKO hp a b a' b') :
    optCardList a' = optCardList a ∧ benchCardList b' = benchCardList b := by
  cases h with
  | ab => exact ⟨rfl, by simp only [benchCardList_append, benchCardList, InPlay.cardList,
      InPlay.addDamage]⟩
  | ba => exact ⟨rfl, by simp only [benchCardList_append, benchCardList, InPlay.cardList]⟩
  | @bb _ q r b₁ b₂ c₁ c₂ hq hd hc hne hk =>
      refine ⟨rfl, ?_⟩
      have e := congrArg benchCardList hc
      simp only [benchCardList_append, benchCardList, InPlay.cardList] at e
      simp only [benchCardList_append, benchCardList, InPlay.cardList, InPlay.addDamage, ← e]

/-- The Stadium slot's card goes to one of the two players: `stadiumTo` splits it by owner
(milestone M5). -/
theorem count_stadiumTo (b : Bool) (s : Option (Bool × Card)) (x : Card) :
    List.count x (stadiumTo b s) + List.count x (stadiumTo (!b) s) =
      List.count x (stadiumCardList s) := by
  rcases s with _ | ⟨o, c⟩
  · rfl
  · cases o <;> cases b <;> simp [stadiumTo, stadiumCardList]

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
  | @switch g a q b₁ b₂ w ha hb =>
      cases w <;> simp only [GameState.side] at ha hb <;> perm_count [ha, hb, GameState.updSide]
  | switchNone => exact .refl _
  | @benchDamage g q b₁ b₂ w n h =>
      cases w <;> simp only [GameState.side] at h <;>
        perm_count [h, GameState.updSide, (q.hitBench_fields n).1, (q.hitBench_fields n).2.1,
          (q.hitBench_fields n).2.2.1, (q.hitBench_fields n).2.2.2.1]
  | benchDamageNone => exact .refl _
  | spreadDamage w n g =>
      cases w <;>
        simp only [GameState.allCards, PlayerState.allCards, GameState.updSide,
          benchCardList_hitBench] <;> exact .refl _
  | damage n h => perm_count [h]
  | drain n h hq => perm_count [h, hq]
  | shuffle h =>
      have := fun x => h.count_eq x
      perm_count [this]
  | search h => perm_count [h]
  | handToBottom h =>
      have := fun x => h.count_eq x
      perm_count [this]
  | moveCounter h =>
      obtain ⟨h1, h2⟩ := h.cardLists
      simp only [GameState.allCards, PlayerState.allCards, h1, h2]
      exact .refl _
  | @zone e w g s' hw hz =>
      rw [hz.updSide]
      cases w with
      | own =>
          simp only [GameState.updSide, GameState.allCards]
          exact (hz.perm.append_right _).append_right _
      | opp =>
          simp only [GameState.updSide, GameState.allCards]
          exact (hz.perm.append_left _).append_right _
  | discardStadium g =>
      refine ListPerm.perm_of_count fun x => ?_
      have := count_stadiumTo g.curIsFirst g.stadium x
      simp only [GameState.allCards, PlayerState.allCards, List.count_append, List.count_nil,
        stadiumCardList] at this ⊢
      omega
  | seq _ _ ih₁ ih₂ => exact ih₂.trans ih₁
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact .refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₂.trans ih₁

/-- The cards of an optional Pokémon are those of its part that passes `t` and of its part that
does not. -/
theorem count_optFilter (t : InPlay → Bool) (o : Option InPlay) (x : Card) :
    List.count x (optCardList o) = List.count x (optCardList (optFilter t o)) +
      List.count x (optCardList (optFilter (fun p => !t p) o)) := by
  cases o with
  | none => rfl
  | some p => cases h : t p <;> simp [optFilter, h, optCardList]

/-- The cards of a Bench are those of its Pokémon that pass `t` and of those that do not. -/
theorem count_benchFilter (t : InPlay → Bool) (b : List InPlay) (x : Card) :
    List.count x (benchCardList b) = List.count x (benchCardList (b.filter t)) +
      List.count x (benchCardList (b.filter fun p => !t p)) := by
  induction b with
  | nil => rfl
  | cons p ps ih =>
      cases h : t p <;>
        simp only [List.filter_cons, h, Bool.not_false, Bool.not_true, ite_true,
          Bool.false_eq_true, ite_false, benchCardList, List.count_append, ih] <;> omega

/-- The check's removal moves cards only from play to the discard pile. -/
theorem PlayerState.koOut_count (ta tb : InPlay → Bool) (s : PlayerState) (x : Card) :
    List.count x (s.koOut ta tb).allCards = List.count x s.allCards := by
  have h1 := count_optFilter ta s.active x
  have h2 := count_benchFilter tb s.bench x
  simp only [PlayerState.allCards, PlayerState.koOut, List.count_append] at h1 h2 ⊢
  omega

/-- Taking Prize cards moves cards only from the Prize cards to the hand. -/
theorem PlayerState.takePrizes_count (n : Nat) (s : PlayerState) (x : Card) :
    List.count x (s.takePrizes n).allCards = List.count x s.allCards := by
  have := count_prizes n s.prizes x
  simp only [PlayerState.allCards, PlayerState.takePrizes, List.count_append] at this ⊢
  omega

/-- A promotion moves a Pokémon from the Bench to the Active Spot. -/
theorem Promote.count_eq {a a' : Option InPlay} {b b' : List InPlay} (h : Promote a b a' b')
    (x : Card) :
    List.count x (optCardList a') + List.count x (benchCardList b') =
      List.count x (optCardList a) + List.count x (benchCardList b) := by
  cases h with
  | keep => rfl
  | pick =>
      simp only [optCardList, benchCardList_append, benchCardList, List.count_append,
        List.count_nil]
      omega

/-- **The batch Knock Out step permutes the cards in the game**: every Knocked Out Pokémon's cards,
attached cards included, go to its owner's discard pile, the Prize cards taken go to the takers'
hands, and the promoted Pokémon move from the Bench to the Active Spot. -/
theorem KOBatch.perm {g g' : GameState} (h : KOBatch g g') : g'.allCards.Perm g.allCards := by
  have hk : g.koStep.allCards.Perm g.allCards := by
    refine ListPerm.perm_of_count fun x => ?_
    have c1 := PlayerState.takePrizes_count (g.koVal .opp) (g.koOf .own) x
    have c2 := PlayerState.takePrizes_count (g.koVal .own) (g.koOf .opp) x
    have c3 := PlayerState.koOut_count (g.koT .own .active) (g.koT .own .bench) g.cur x
    have c4 := PlayerState.koOut_count (g.koT .opp .active) (g.koT .opp .bench) g.opp x
    simp only [GameState.koOf, GameState.side] at c1 c2
    simp only [GameState.allCards, GameState.koStep, List.count_append, GameState.koOf,
      GameState.side] at c3 c4 ⊢
    omega
  cases h with
  | won => exact hk
  | go _ _ hc ho =>
      refine (ListPerm.perm_of_count fun x => ?_).trans hk
      have := hc.count_eq x
      have := ho.count_eq x
      simp only [GameState.allCards, GameState.withPlay, PlayerState.allCards,
        List.count_append] at *
      omega

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

/-- Marking a Pokémon as having used an Ability moves no card (milestone M8a). -/
theorem UseAt.perm {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    g₁.allCards.Perm g.allCards := by
  cases h with
  | active ha => perm_count [ha, InPlay.markUsed]
  | bench hb => perm_count [hb, InPlay.markUsed]

/-- A play from the hand permutes the cards in the game (milestone M8a). -/
theorem PlayFromHand.perm {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : g₁.allCards.Perm g.allCards := by
  cases h with
  | basic hh => perm_count [hh]
  | evolve hh ha => perm_count [hh, ha]
  | evolveBench hh hb => perm_count [hh, hb]

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
  | @stadium l₁ l₂ n e ss hh =>
      refine ListPerm.perm_of_count fun x => ?_
      have := count_stadiumTo g.curIsFirst g.stadium x
      simp only [GameState.allCards, PlayerState.allCards, List.count_append, List.count_cons,
        List.count_nil, stadiumCardList, hh] at this ⊢
      omega
  | stadiumUse _ _ _ _ _ hr => exact hr.perm
  | tool hh ha ht => perm_count [hh, ha, ht]
  | toolBench hh hb ht => perm_count [hh, hb, ht]
  | ability hu _ _ _ _ _ _ _ _ hr => exact hr.perm.trans hu.perm
  | onPlay hp _ _ _ _ _ hr => exact hr.perm.trans hp.perm
  | attack ha hm hc hs hn hf hbt hst hr => exact hr.perm
  | attackConfused ha hm hc hs hn hf => perm_count [ha]
  | knockOuts h => exact h.perm
  | endTurn fa sa ca fb sb cb ha hb hk hbt hco hcc =>
      simp only [GameState.allCards, PlayerState.allCards, PlayerState.unfresh, hco.cardList,
        hcc.cardList, benchCardList_unfresh]
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

/-- The cards of the player's Active Pokémon are in the game (milestone M5: its Tools give it
attacks and Abilities). -/
theorem GameState.mem_allCards_of_cur_active {g : GameState} {a : InPlay}
    (ha : g.cur.active = some a) {c : Card} (hc : c ∈ a.cardList) : c ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, optCardList, ha, hc]

theorem GameState.mem_allCards_of_cur_bench {g : GameState} {a : InPlay}
    (ha : a ∈ g.cur.bench) {c : Card} (hc : c ∈ a.cardList) : c ∈ g.allCards := by
  have := mem_benchCardList hc ha
  simp [GameState.allCards, PlayerState.allCards, this]

/-- The cards of the Pokémon that uses an Ability are in the game (milestone M5). -/
theorem UseAt.card_mem {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁)
    {c : Card} (hc : c ∈ x.cardList) : c ∈ g.allCards := by
  cases h with
  | active ha => exact GameState.mem_allCards_of_cur_active ha hc
  | bench hb =>
      exact GameState.mem_allCards_of_cur_bench (by rw [hb]; exact List.mem_append_right _ (.head _))
        hc

/-- The card of the Pokémon that uses an Ability is in the game (milestone M8a). -/
theorem UseAt.top_mem {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    Card.pokemon x.top ∈ g.allCards := by
  cases h with
  | active ha => exact GameState.top_mem_cur_active ha
  | bench hb => exact GameState.top_mem_cur_bench (by rw [hb]; exact List.mem_append_right _ (.head _))

/-- The card played from the hand is in the game (milestone M8a). -/
theorem PlayFromHand.top_mem {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : Card.pokemon x.top ∈ g.allCards := by
  obtain ⟨l₁, l₂, hh⟩ := h.hand
  simp [GameState.allCards, PlayerState.allCards, hh]

theorem GameState.top_mem_opp_bench {g : GameState} {a : InPlay}
    (ha : a ∈ g.opp.bench) : Card.pokemon a.top ∈ g.allCards := by
  have := mem_benchCardList (x := Card.pokemon a.top) (.head _) ha
  simp [GameState.allCards, PlayerState.allCards, this]

/-- The card in the Stadium slot is in the game (milestone M5). -/
theorem GameState.mem_allCards_of_stadium {g : GameState} {o : Bool} {x : Card}
    (hs : g.stadium = some (o, x)) : x ∈ g.allCards := by
  simp [GameState.allCards, stadiumCardList, hs]

theorem GameState.mem_allCards_of_hand {g : GameState} {x : Card} (hx : x ∈ g.cur.hand) :
    x ∈ g.allCards := by
  simp [GameState.allCards, PlayerState.allCards, hx]

end Pokemon
