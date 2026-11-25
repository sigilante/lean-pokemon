import Pokemon.StoreSafe.Invariant
import Pokemon.Terminate

/-!
# Decks without triggered Abilities (milestone M8b)

Milestone M8b changed two moves (`Move.attack` ends with the opponent's `damaged` triggers,
`Move.knockOuts` with the `koByAttack` triggers of the batch); `StoreSafe` is unchanged (a first
version of M8b counted triggered Abilities as free recyclers in clause 3 (a); a review showed that
unnecessary, and it was undone). For a game in which no card has a
triggered Ability (`GameState.TrigFree`, kept by play) nothing changed:

* `Move.knockOuts_of_trigFree`, `Move.batch_of_not_settled_trigFree`: the batch move is the batch
  Knock Out step, as before (the statement of `Move.batch_of_not_settled` before milestone M8b);
* `Move.attack_of_trigFree`, `Move.attack_eq_of_trigFree`: an attack is what it was, the state
  after its script with the attack recorded;
* `Reach.trigFree`: play keeps the hypothesis.
-/

namespace Pokemon

theorem Reach.trigFree {g₀ g : GameState} (h : Reach g₀ g) (hf : g₀.TrigFree) : g.TrigFree :=
  hf.of_perm h.perm

/-- With no triggered Ability, the batch Knock Out step is a move. -/
theorem Move.knockOuts_of_trigFree {g g₁ : GameState} (h : KOBatch g g₁) (hf : g.TrigFree) :
    Move g g₁ :=
  Move.knockOuts_of_nil h (hf.batchTrigs g₁)

/-- **With no triggered Ability, the batch move is the batch Knock Out step** (the statement of
`Move.batch_of_not_settled` before milestone M8b), from a state with no trigger pending (milestone
MV7: `g.pend = false`, which holds in every state reached from a start with none,
`Reach.batch_of_not_settled_trigFree`). -/
theorem Move.batch_of_not_settled_trigFree {g g' : GameState} (hm : Move g g') (hu : ¬ Settled g)
    (hf : g.TrigFree) (hpd : g.pend = false := by first | rfl | assumption) : KOBatch g g' := by
  rcases hm.batch_of_not_settled hu with ⟨g₁, l, hb, hl, ht⟩ | ⟨-, hp, -⟩
  · rw [Move.eq_of_batchTrigs_nil hl ht (hf.batchTrigs g₁)]
    exact hb
  · rw [hpd] at hp; cases hp

/-- With no triggered Ability, an attack with the premises of milestone M8a (and, since milestone
MV4, no attack lock against it) is a move to the state after its script with the attack recorded
(`GameState.afterAttack`, which since milestone MV4 also sets the attacker's lock). -/
theorem Move.attack_of_trigFree {g g' : GameState} {a : InPlay} {atk : Attack}
    (ha : g.cur.active = some a) (hm : atk ∈ a.attacks)
    (hc : Pays atk.cost a.units) (hs : a.rot.canAct = true)
    (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
    (hst : Settled g) (hr : Run atk.script g g') (hl : g.cur.mods.live.noAttack = false)
    (hgx : atk.gx = true → g.cur.gxUsed = false) (hw : atk.wf = true) (htf : g.TrigFree)
    (hlk : a.lk.on.allows atk = true) :
    Move g (g'.afterAttack atk.lockSet atk.gx) :=
  .attack ha hm hc hs hn hf hbt hst hr hl hgx hw
    (HitTrig.exists_nil hr ((htf.of_perm hr.perm).optTrigs_opp _)) (.nil _) hlk

/-- With no triggered Ability, an attack fires no trigger: its result is the state after its
script with the attack recorded. -/
theorem Move.attack_eq_of_trigFree {atk : Attack} {g g' g'' : GameState} {l : List Ability}
    (hr : Run atk.script g g') (hd : HitTrig atk g g' l) (ht : Fire .damaged l g' g'')
    (htf : g.TrigFree) : g'' = g' := by
  have hl := hd.nil_of ((htf.of_perm hr.perm).optTrigs_opp _)
  subst hl
  exact ht.nil_eq

/-! ## Decks without an `oppBenched` trigger (milestone MV7)

Milestone MV7 added the record `GameState.pend`, raised by a retreat and by a switch of the player's
own Active Pokémon when the opponent has an `oppBenched` trigger in play (`GameState.noteBenched`).
For a game in which no card has such a trigger (`GameState.BenchedFree`, kept by play; implied by
`GameState.TrigFree`) and that starts with nothing pending:

* `GameState.noteBenched_of_nil`: the retreat and the switch give the states they gave before MV7;
* `Reach.pend_false`: every reachable state has nothing pending, so `Settled` is the `Settled` of
  the milestones before MV7 (`Reach.settled_iff_calm`) and the premises `pend = false` of
  `endTurn`, `startTurn`, `deckOut` and of the batch Knock Out step hold;
* `Reach.not_trigMove`: no move of any play resolves a trigger (`Move.trigger` is never taken);
* `Reach.batch_of_not_settled_trigFree`: with no triggered Ability at all, the move from a state
  that is not `Settled` is the batch Knock Out step (the statement of `Move.batch_of_not_settled`
  before milestone M8b, hypothesis `¬ Settled g`).
-/

/-- A card with no `oppBenched` trigger (of its own, or given by it as a Tool). -/
def Card.benchedFree (c : Card) : Bool := c.abilities.all fun ab => ab.use.event != some .oppBenched

/-- No card of the game has an `oppBenched` trigger (milestone MV7). Play keeps it
(`GameState.BenchedFree.of_perm`). -/
def GameState.BenchedFree (g : GameState) : Prop := ∀ c ∈ g.allCards, c.benchedFree = true

theorem GameState.BenchedFree.of_perm {g g' : GameState} (h : g.BenchedFree)
    (hp : g'.allCards.Perm g.allCards) : g'.BenchedFree :=
  fun c hc => h c (hp.mem_iff.1 hc)

/-- A game with no triggered Ability has no `oppBenched` trigger. -/
theorem GameState.TrigFree.benchedFree {g : GameState} (h : g.TrigFree) : g.BenchedFree := by
  intro c hc
  have h1 := h c hc
  simp only [Card.trigFree, List.all_eq_true] at h1
  simp only [Card.benchedFree, List.all_eq_true]
  intro ab hab
  rw [Option.isNone_iff_eq_none.1 (h1 ab hab)]
  rfl

/-- A Pokémon made of cards with no `oppBenched` trigger has none. -/
theorem InPlay.benchedTrigs_nil_of {p : InPlay} (h : ∀ c ∈ p.cardList, c.benchedFree = true)
    (sp : Spot) : p.trigs .oppBenched sp = [] := by
  unfold InPlay.trigs
  refine filter_nil_of fun ab hab => ?_
  have hev : (ab.use.event != some .oppBenched) = true := by
    rcases List.mem_append.1 hab with h1 | h1
    · have := h (.pokemon p.top) (.head _)
      simp only [Card.benchedFree, Card.abilities, List.all_eq_true] at this
      exact this ab h1
    · obtain ⟨c, hc, hab'⟩ := List.mem_flatMap.1 h1
      have := h c (.tail _ (List.mem_append_right _ hc))
      simp only [Card.benchedFree, List.all_eq_true] at this
      exact this ab (Card.grantAbilities_sub hab')
  simp only [bne] at hev
  simp only [Ability.trigOn]
  revert hev
  cases (ab.use.event == some TrigEvent.oppBenched) <;> intro hev
  · rfl
  · cases hev

/-- **With no `oppBenched` trigger in the game, the opponent has none in play.** -/
theorem GameState.BenchedFree.benchedTrigs {g : GameState} (h : g.BenchedFree) :
    g.benchedTrigs = [] := by
  have h1 : optTrigs .oppBenched g.opp.active = [] := by
    cases ha : g.opp.active with
    | none => rfl
    | some p =>
        exact InPlay.benchedTrigs_nil_of
          (fun c hc => h c (GameState.mem_allCards_of_opp_active ha hc)) _
  have h2 : g.opp.bench.flatMap (InPlay.trigs .oppBenched .bench) = [] :=
    flatMap_nil_of fun p hp => InPlay.benchedTrigs_nil_of
      (fun c hc => h c (GameState.mem_allCards_of_opp_bench hp hc)) _
  unfold GameState.benchedTrigs
  rw [h1, h2]; rfl

/-! ### Decks without a trigger of a move event (milestone MV7c)

Since milestone MV7c the player's own moves raise `movedUp` and `movedDown` too, and a promotion in
the player's own turn raises `movedUp`. A game with no trigger of any of the three move events
(`GameState.MoveFree`, kept by play) and that starts with nothing pending and no mark
(`GameState.MarksOk`, part of `WellFormed`) never has one pending. Until milestone MV7c the
hypotheses were `BenchedFree` and `pend = false` (with no mark on the player to move's Pokémon
there was nothing else to raise). -/

/-- No card of the game has a trigger of a move event: `oppBenched`, `movedUp` or `movedDown`
(milestone MV7c). -/
def GameState.MoveFree (g : GameState) : Prop :=
  g.BenchedFree ∧ g.EvFree .movedUp ∧ g.EvFree .movedDown

theorem GameState.MoveFree.of_perm {g g' : GameState} (h : g.MoveFree)
    (hp : g'.allCards.Perm g.allCards) : g'.MoveFree :=
  ⟨h.1.of_perm hp, h.2.1.of_perm hp, h.2.2.of_perm hp⟩

/-- A game with no triggered Ability has no trigger of a move event. -/
theorem GameState.TrigFree.moveFree {g : GameState} (h : g.TrigFree) : g.MoveFree := by
  have key : ∀ ev, g.EvFree ev := fun ev c hc => by
    have h1 := h c hc
    simp only [Card.trigFree, List.all_eq_true] at h1
    simp only [Card.evFree, List.all_eq_true]
    intro ab hab
    rw [Option.isNone_iff_eq_none.1 (h1 ab hab)]
    rfl
  exact ⟨h.benchedFree, key _, key _⟩

/-- The record after raising the event, when the opponent has no `oppBenched` trigger in play and
no Pokémon of the player to move is marked. -/
theorem GameState.noteBenched_pend_of_nil {g : GameState} (h : g.noteBenched.benchedTrigs = [])
    (hc : g.cur.noMarksB = true) : g.noteBenched.pend = g.pend := by
  have e : g.noteBenched.benchedTrigs = g.benchedTrigs :=
    GameState.benchedTrigs_of_map (f := InPlay.noteOwe .active) (f' := InPlay.noteOwe .bench)
      (fun _ => rfl) (fun _ => rfl) rfl rfl
  rw [GameState.noteBenched_of_nil (g := g) (e ▸ h) hc]

theorem PlayerState.noMarksB_of {s : PlayerState} (h : s.NoMarks) : s.noMarksB = true := by
  unfold PlayerState.noMarksB
  rw [Bool.and_eq_true]
  refine ⟨?_, List.all_eq_true.2 fun p hp => by rw [h.2 p hp]; rfl⟩
  cases ha : s.active with
  | none => rfl
  | some p => show p.owe.isNone = true; rw [h.1 p ha]; rfl

/-- In a game with no trigger of the event, marking a Pokémon of the game changes nothing. -/
theorem InPlay.noteMove_of_free {ev : TrigEvent} {sp : Spot} {g : GameState} (hf : g.EvFree ev)
    {p : InPlay} (hp : ∀ c ∈ p.cardList, c ∈ g.allCards) : p.noteMove ev sp = p :=
  InPlay.noteMove_of_nil (InPlay.trigs_nil_of_evFree (fun c hc => hf c (hp c hc)) sp)

/-- **An effect's resolution leaves nothing pending** when nothing was, no Pokémon is marked, and
no card of the game has a trigger of a move event (milestone MV7c; before it: keeps the record,
when no card has an `oppBenched` trigger). -/
theorem Run.pend_false {e : Effect} {g g' : GameState} (h : Run e g g') :
    g.MoveFree → g.MarksOk → g.pend = false → g'.pend = false := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq h₁ _ ih₁ ih₂ =>
      intro hf hm hp
      exact ih₂ (hf.of_perm h₁.perm) (h₁.marksOk hm) (ih₁ hf hm hp)
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => intro _ _ hp; exact hp
  | iterCons h₁ _ ih₁ ih₂ =>
      intro hf hm hp
      exact ih₂ (hf.of_perm h₁.perm) (h₁.marksOk hm) (ih₁ hf hm hp)
  | @switch g a q b₁ b₂ w ha hb =>
      intro hf hm hp
      cases w with
      | own =>
          simp only [GameState.side] at ha hb
          have hc := (hm hp).1
          have hq : q ∈ g.cur.bench := by rw [hb]; exact List.mem_append_right _ (.head _)
          have eu : Whose.noteUp .own (Whose.mover .own q) = q.moveUp :=
            InPlay.noteMove_of_free hf.2.1 fun c hc' => GameState.mem_allCards_of_cur_bench hq hc'
          have ed : Whose.noteDown .own a.cure.unlock = a.cure.unlock :=
            InPlay.noteMove_of_free hf.2.2 fun c hc' => GameState.mem_allCards_of_cur_active ha hc'
          have hb' := (hf.1.of_perm (Run.switch (g := g) .own ha hb).perm).benchedTrigs
          simp only [Whose.noteBenched, eu, ed] at hb' ⊢
          rw [GameState.noteBenched_pend_of_nil hb' (PlayerState.noMarksB_of
            ⟨OptNoOwe.some_of (hc.2.mem hb : q.owe = none), hc.2.upd hb (hc.1 a ha)⟩)]
          exact hp
      | opp => exact hp
  | _ => intro _ _ hp; first | exact hp | (cases ‹Whose› <;> exact hp)

/-- A chain of batch Knock Out steps keeps the record, in a game with no `movedUp` trigger
(hypothesis added by milestone MV7c). -/
theorem KOChain.pend_eq {n : Nat} {g g' : GameState} (h : KOChain n g g') (hf : g.EvFree .movedUp) :
    g'.pend = g.pend := by
  induction h with
  | refl => rfl
  | step _ hm _ ih => exact (ih (hf.of_perm hm.perm)).trans (hm.pend_eq_of_upFree hf)

/-- Taking the Knock Outs from a state with nothing pending leaves nothing pending, in a game with
no `movedUp` trigger (hypothesis added by milestone MV7c). -/
theorem Resolve.pend_false {g g' : GameState} (h : Resolve g g') (hp : g.pend = false)
    (hf : g.EvFree .movedUp) : g'.pend = false := by
  obtain ⟨n, hc⟩ := h.chain hp hf
  exact (hc.pend_eq hf).trans hp

/-- A Trainer, Stadium or Ability effect's resolution leaves nothing pending, when nothing was, no
Pokémon is marked, and no card of the game has a trigger of a move event. -/
theorem TRun.pend_false {e : Effect} {g g' : GameState} (h : TRun e g g') :
    g.MoveFree → g.MarksOk → g.pend = false → g'.pend = false := by
  induction h with
  | prim _ _ hr hk =>
      intro hf hm hp
      exact hk.pend_false (hr.pend_false hf hm hp) (hf.of_perm hr.perm).2.1
  | stop => intro _ _ hp; exact hp
  | iteT _ _ _ _ ih => exact ih
  | iteF _ _ _ _ ih => exact ih
  | seq h₁ _ ih₁ ih₂ =>
      intro hf hm hp; exact ih₂ (hf.of_perm h₁.perm) (h₁.marksOk hm) (ih₁ hf hm hp)
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => intro _ _ hp; exact hp
  | iterCons h₁ _ ih₁ ih₂ =>
      intro hf hm hp; exact ih₂ (hf.of_perm h₁.perm) (h₁.marksOk hm) (ih₁ hf hm hp)

/-- **A move leaves nothing pending** when nothing was, no Pokémon is marked, and no card of the game
has a trigger of a move event (milestone MV7c; before it, when no card had an `oppBenched`
trigger). -/
theorem Move.pend_false {g g' : GameState} (hm : Move g g') (hf : g.MoveFree) (hmk : g.MarksOk)
    (hp : g.pend = false) : g'.pend = false := by
  have hf' : g'.MoveFree := hf.of_perm hm.perm
  have key : ∀ {e : Effect} {X : GameState}, TRun e X g' → X.MarksOk → X.pend = false →
      g'.pend = false :=
    fun hr hX hXp => hr.pend_false (hf'.of_perm hr.perm.symm) hX hXp
  cases hm with
  | @retreat a q b₁ b₂ paid rest ha hb =>
      have hc := (hmk hp).1
      have hq : q ∈ g.cur.bench := by rw [hb]; exact List.mem_append_right _ (.head _)
      have eu : q.moveUp.noteMove .movedUp .active = q.moveUp :=
        InPlay.noteMove_of_free hf.2.1 fun c hc' => GameState.mem_allCards_of_cur_bench hq hc'
      have ta : a.trigs .movedDown .bench = [] := InPlay.trigs_nil_of_evFree
        (fun c hc' => hf.2.2 c (GameState.mem_allCards_of_cur_active ha hc')) _
      have ed := InPlay.noteMove_of_nil (p := ({ a with
          energy := rest, rot := .none, poisoned := false, burned := false, poisonUp := 0,
          lk := {} } : InPlay)) ta
      have hb' := hf'.1.benchedTrigs
      rw [eu, ed] at hb' ⊢
      rw [GameState.noteBenched_pend_of_nil hb' (PlayerState.noMarksB_of
        ⟨OptNoOwe.some_of (hc.2.mem hb : q.owe = none), hc.2.upd hb (hc.1 a ha)⟩)]
      exact hp
  | item _ _ _ hr => exact key hr hmk hp
  | supporter _ _ _ _ hr => exact key hr hmk hp
  | stadiumUse _ _ _ _ _ hr => exact key hr hmk hp
  | ability hu _ _ _ _ _ _ _ _ hr => exact key hr (hu.marksOk hmk) (by cases hu <;> exact hp)
  | onPlay hpl _ _ _ hst _ hr => exact key hr (hpl.marksOk hmk) hst.2.2.2
  | attack _ _ _ _ _ _ _ _ hr _ _ _ _ ht =>
      exact ht.zoneOnly.pend.trans (hr.pend_false hf hmk hp)
  | knockOuts h _ ht => exact ht.zoneOnly.pend.trans ((h.pend_eq_of_upFree hf.2.1).trans hp)
  | trigger _ hp' => rw [hp] at hp'; cases hp'
  | _ => first | exact hp | rfl

/-- **Play keeps nothing pending** (milestone MV7): from a start with nothing pending, no mark
(`GameState.MarksOk`, part of `WellFormed`; hypothesis added by milestone MV7c) and no card with a
trigger of a move event (`GameState.MoveFree`; milestone MV7c, before it `BenchedFree`), every
reachable state has `pend = false`. -/
theorem Reach.pend_false {g₀ g : GameState} (h : Reach g₀ g) (hf : g₀.MoveFree)
    (hm : g₀.MarksOk) (hp : g₀.pend = false) : g.pend = false := by
  induction h with
  | refl => exact hp
  | step h' _ hmv ih =>
      exact hmv.pend_false (hf.of_perm h'.perm) (Reach.marksOk hm h') ih

/-- **No play resolves a trigger** (milestone MV7) from such a start: no move from a reachable state
is the resolution of pending triggers (`Move.trigger`, spelled out by `TrigMove`), so every move of
every play is a move of the relation without that constructor. -/
theorem Reach.not_trigMove {g₀ g g' : GameState} (h : Reach g₀ g) (hf : g₀.MoveFree)
    (hm : g₀.MarksOk) (hp : g₀.pend = false) : ¬ TrigMove g g' := fun ⟨_, hp', _⟩ => by
  rw [h.pend_false hf hm hp] at hp'; cases hp'

/-- From such a start, `Settled` is the `Settled` of the milestones before MV7 (now `Calm`). -/
theorem Reach.settled_iff_calm {g₀ g : GameState} (h : Reach g₀ g) (hf : g₀.MoveFree)
    (hm : g₀.MarksOk) (hp : g₀.pend = false) : Settled g ↔ Calm g :=
  ⟨Settled.calm, fun hc => hc.settled (h.pend_false hf hm hp)⟩

/-- **With no triggered Ability, the move from a state that is not `Settled` is the batch Knock Out
step**, for play from a start with nothing pending and no mark: the statement of
`Move.batch_of_not_settled` before milestone M8b, with its hypothesis `¬ Settled g`. -/
theorem Reach.batch_of_not_settled_trigFree {g₀ g g' : GameState} (h : Reach g₀ g)
    (hf : g₀.TrigFree) (hm : g₀.MarksOk) (hp : g₀.pend = false) (hmv : Move g g')
    (hu : ¬ Settled g) : KOBatch g g' :=
  hmv.batch_of_not_settled_trigFree hu (h.trigFree hf) (h.pend_false hf.moveFree hm hp)

end Pokemon
