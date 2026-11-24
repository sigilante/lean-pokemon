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

/-- **With no trigger to record, raising the event changes nothing** (milestone MV7): the retreat
and the switch of the player's own Active Pokémon give the states they gave before MV7. -/
theorem GameState.noteBenched_of_nil {g : GameState} (h : g.benchedTrigs = []) :
    g.noteBenched = g := by
  unfold GameState.noteBenched
  rw [h]
  cases g; rename_i pend
  cases pend <;> rfl

/-- The record after raising the event, when the opponent has no `oppBenched` trigger in play. -/
theorem GameState.noteBenched_pend_of_nil {g : GameState} (h : g.noteBenched.benchedTrigs = []) :
    g.noteBenched.pend = g.pend := by
  rw [GameState.noteBenched_of_nil (g := g) h]

/-- An effect's resolution keeps the record when no card of the game has an `oppBenched`
trigger. -/
theorem Run.pend_eq {e : Effect} {g g' : GameState} (h : Run e g g') :
    g.BenchedFree → g'.pend = g.pend := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq h₁ _ ih₁ ih₂ => intro hf; exact (ih₂ (hf.of_perm h₁.perm)).trans (ih₁ hf)
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => intro _; rfl
  | iterCons h₁ _ ih₁ ih₂ => intro hf; exact (ih₂ (hf.of_perm h₁.perm)).trans (ih₁ hf)
  | switch w ha hb =>
      intro hf
      have hb' := (hf.of_perm (Run.switch w ha hb).perm).benchedTrigs
      cases w
      · exact GameState.noteBenched_pend_of_nil hb'
      · rfl
  | _ => intro _; first | rfl | (cases ‹Whose› <;> rfl)

/-- A chain of batch Knock Out steps keeps the record. -/
theorem KOChain.pend_eq {n : Nat} {g g' : GameState} (h : KOChain n g g') : g'.pend = g.pend := by
  induction h with
  | refl => rfl
  | step _ hm _ ih => exact ih.trans hm.pend_eq

/-- Taking the Knock Outs from a state with nothing pending leaves nothing pending. -/
theorem Resolve.pend_false {g g' : GameState} (h : Resolve g g') (hp : g.pend = false) :
    g'.pend = false := by
  obtain ⟨n, hc⟩ := h.chain hp
  exact hc.pend_eq.trans hp

/-- A Trainer, Stadium or Ability effect's resolution leaves nothing pending, when nothing was and
no card of the game has an `oppBenched` trigger. -/
theorem TRun.pend_false {e : Effect} {g g' : GameState} (h : TRun e g g') :
    g.BenchedFree → g.pend = false → g'.pend = false := by
  induction h with
  | prim _ _ hr hk => intro hf hp; exact hk.pend_false ((hr.pend_eq hf).trans hp)
  | stop => intro _ hp; exact hp
  | iteT _ _ _ _ ih => exact ih
  | iteF _ _ _ _ ih => exact ih
  | seq h₁ _ ih₁ ih₂ => intro hf hp; exact ih₂ (hf.of_perm h₁.perm) (ih₁ hf hp)
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => intro _ hp; exact hp
  | iterCons h₁ _ ih₁ ih₂ => intro hf hp; exact ih₂ (hf.of_perm h₁.perm) (ih₁ hf hp)

/-- **A move leaves nothing pending** when nothing was and no card of the game has an
`oppBenched` trigger. -/
theorem Move.pend_false {g g' : GameState} (hm : Move g g') (hf : g.BenchedFree)
    (hp : g.pend = false) : g'.pend = false := by
  have hf' : g'.BenchedFree := hf.of_perm hm.perm
  have hb : g'.benchedTrigs = [] := hf'.benchedTrigs
  have key : ∀ {e : Effect} {X : GameState}, TRun e X g' → X.pend = false → g'.pend = false :=
    fun hr hX => hr.pend_false (hf'.of_perm hr.perm.symm) hX
  cases hm with
  | retreat => exact (GameState.noteBenched_pend_of_nil hb).trans hp
  | item => exact key (by assumption) (by exact hp)
  | supporter => exact key (by assumption) (by exact hp)
  | stadiumUse => exact key (by assumption) (by exact hp)
  | ability hu => exact key (by assumption) (by cases hu <;> exact hp)
  | onPlay _ _ _ _ hst => exact key (by assumption) hst.2.2.2
  | attack _ _ _ _ _ _ _ _ hr _ _ _ _ ht => exact (ht.zoneOnly.pend.trans (hr.pend_eq hf)).trans hp
  | knockOuts h _ ht => exact ht.zoneOnly.pend.trans (h.pend_eq.trans hp)
  | trigger _ hp' => rw [hp] at hp'; cases hp'
  | _ => first | exact hp | rfl

/-- **Play keeps nothing pending** (milestone MV7): from a start with nothing pending and no card
with an `oppBenched` trigger, every reachable state has `pend = false`. -/
theorem Reach.pend_false {g₀ g : GameState} (h : Reach g₀ g) (hf : g₀.BenchedFree)
    (hp : g₀.pend = false) : g.pend = false := by
  induction h with
  | refl => exact hp
  | step h' _ hm ih => exact hm.pend_false (hf.of_perm h'.perm) ih

/-- **No play resolves a trigger** (milestone MV7) from such a start: no move from a reachable state
is the resolution of pending triggers (`Move.trigger`, spelled out by `TrigMove`), so every move of
every play is a move of the relation without that constructor. -/
theorem Reach.not_trigMove {g₀ g g' : GameState} (h : Reach g₀ g) (hf : g₀.BenchedFree)
    (hp : g₀.pend = false) : ¬ TrigMove g g' := fun ⟨_, hp', _⟩ => by
  rw [h.pend_false hf hp] at hp'; cases hp'

/-- From such a start, `Settled` is the `Settled` of the milestones before MV7 (now `Calm`). -/
theorem Reach.settled_iff_calm {g₀ g : GameState} (h : Reach g₀ g) (hf : g₀.BenchedFree)
    (hp : g₀.pend = false) : Settled g ↔ Calm g :=
  ⟨Settled.calm, fun hc => hc.settled (h.pend_false hf hp)⟩

/-- **With no triggered Ability, the move from a state that is not `Settled` is the batch Knock Out
step**, for play from a start with nothing pending: the statement of `Move.batch_of_not_settled`
before milestone M8b, with its hypothesis `¬ Settled g`. -/
theorem Reach.batch_of_not_settled_trigFree {g₀ g g' : GameState} (h : Reach g₀ g)
    (hf : g₀.TrigFree) (hp : g₀.pend = false) (hm : Move g g') (hu : ¬ Settled g) :
    KOBatch g g' :=
  hm.batch_of_not_settled_trigFree hu (h.trigFree hf) (h.pend_false hf.benchedFree hp)

end Pokemon
