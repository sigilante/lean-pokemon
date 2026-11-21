import Pokemon.Faithful.Invariant
import Pokemon.Terminate

/-!
# Decks without triggered Abilities (milestone M8b)

Milestone M8b changed two moves (`Move.attack` ends with the opponent's `damaged` triggers,
`Move.knockOuts` with the `koByAttack` triggers of the batch); `Faithful` is unchanged (a first
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
`Move.batch_of_not_settled` before milestone M8b). -/
theorem Move.batch_of_not_settled_trigFree {g g' : GameState} (hm : Move g g') (hu : ¬ Settled g)
    (hf : g.TrigFree) : KOBatch g g' := by
  obtain ⟨g₁, l, hb, hl, ht⟩ := hm.batch_of_not_settled hu
  rw [Move.eq_of_batchTrigs_nil hl ht (hf.batchTrigs g₁)]
  exact hb

/-- With no triggered Ability, an attack with the premises of milestone M8a is a move to the state
after its script with the attack recorded. -/
theorem Move.attack_of_trigFree {g g' : GameState} {a : InPlay} {atk : Attack}
    (ha : g.cur.active = some a) (hm : atk ∈ a.attacks)
    (hc : Pays atk.cost a.units) (hs : a.rot.canAct = true)
    (hn : g.attacked = false) (hf : g.firstTurn = false) (hbt : g.between = false)
    (hst : Settled g) (hr : Run atk.script g g') (hl : g.cur.mods.live.noAttack = false)
    (hgx : atk.gx = true → g.cur.gxUsed = false) (hw : atk.wf = true) (htf : g.TrigFree) :
    Move g { g' with attacked := true, cur := { g'.cur with gxUsed := atk.gx || g'.cur.gxUsed } } :=
  .attack ha hm hc hs hn hf hbt hst hr hl hgx hw
    (HitTrig.exists_nil hr ((htf.of_perm hr.perm).optTrigs_opp _)) (.nil _)

/-- With no triggered Ability, an attack fires no trigger: its result is the state after its
script with the attack recorded. -/
theorem Move.attack_eq_of_trigFree {atk : Attack} {g g' g'' : GameState} {l : List Ability}
    (hr : Run atk.script g g') (hd : HitTrig atk g g' l) (ht : Fire .damaged l g' g'')
    (htf : g.TrigFree) : g'' = g' := by
  have hl := hd.nil_of ((htf.of_perm hr.perm).optTrigs_opp _)
  subst hl
  exact ht.nil_eq

end Pokemon
