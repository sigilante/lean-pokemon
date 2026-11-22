import Pokemon.StoreSafe
import Pokemon.Terminate

/-!
# Triggers as observations: the meta-theorem (milestone MV5, Part B; survey S18 §B)

The Poet's ideas 1 and 2 (survey S0c): an event is not a place in the rules but an observation of a
whole move. `OMove ev obs g g'` is a move `Move g g₁` followed by firing, from the side of the
player not to move (`Fire`), the triggers `obs` reads off the move's two end states, in any order.

The observation is taken on the **skeletons** of the two states (`GameState.skel`: the states with
every damage count, Poison strength and store erased), and only for a move made from a `Settled`
state that leaves the game going (`obsGate`). That is the congruence condition of the meta-theorem
made structural: both clamps change only damage, Poison strength and stores (`skel_clampAt`,
`skel_xclampAt`), and `Settled` is the same on two states with the same clamp below the clamp's
bound; so two moves related by either clamp observe the same triggers, and the existing simulations
of `Fire` (`Fire.clamp_sim`, `Fire.xclamp_sim`) finish the proof. No further condition is needed for
the simulations, `WellFormed`, card conservation, `Fit`, `XFit`, the finite quotients and the Knock
Out check. Two conditions on the triggers observed are needed elsewhere:

* `ObsTrigOk ev obs`: every trigger observed resolves an effect of the trigger fragment
  (`Effect.trigOk`); used for the existence of a move (`OMove.exists_move`: a mandatory trigger must
  have a resolution, `Fire.exists`, which needs both Active Spots filled, true after every move from
  a `Settled` state that leaves the game going, `Move.bothActive_of_settled`);
* for the store bound, every trigger observed recycles nothing (`(ab.script ev.place).recFilters =
  []`). A mid-turn trigger may fire many times in a turn, so it would be a free recycler of clause
  3 (a) of `StoreSafe`; the existing invariant (`TInv.same'`) needs the weight of the discard piles
  kept before the turn's attack, and this is the weakest condition under which the existing lemma
  `Fire.disc_mono` gives it without a new clause.

Results (each the counterpart of a theorem about `Move` / `Reach`, proved from it and from the
corresponding `Fire` lemma): `OMove.wellFormed`, `OMove.perm`, `OMove.fit`, `OMove.clamp_sim`,
`OReach.finite`, `OMove.xclamp_sim`, `OReach.xclamp_bisim`, `OReach.boundedStores`, `OReach.xfinite`,
`OMove.exists_move`, `OMove.unsettled_iff` and `OMove.unsettled_acc` (the Knock Out check
terminates). The theorems quantify over every `ev` and every `obs`.
-/

namespace Pokemon

open Enum

/-! ## Skeletons -/

/-- A Pokémon in play without its damage and Poison strength: what both clamps keep. -/
def InPlay.skel (p : InPlay) : InPlay := { p with damage := 0, poisonUp := 0 }

/-- A player without damage, Poison strength and store. -/
def PlayerState.skel (s : PlayerState) : PlayerState :=
  { s with active := s.active.map InPlay.skel, bench := s.bench.map InPlay.skel,
           mods := s.mods.cap 0 }

/-- **The skeleton of a state**: everything but damage counts, Poison strengths and stores. -/
def GameState.skel (g : GameState) : GameState := { g with cur := g.cur.skel, opp := g.opp.skel }

theorem InPlay.skel_clampWith (K : Nat) (c : Cap) (p : InPlay) : (p.clampWith K c).skel = p.skel :=
  rfl

theorem Mods.cap_cap_zero (k : Nat) (m : Mods) : (m.cap k).cap 0 = m.cap 0 := by
  simp only [Mods.cap, Nat.min_zero]

theorem Store.cap_cap_zero (k : Nat) (t : Store) : (t.cap k).cap 0 = t.cap 0 := by
  simp only [Store.cap, Mods.cap_cap_zero]

theorem skel_map_clampWith (K : Nat) (c : Cap) (l : List InPlay) :
    (l.map (InPlay.clampWith K c)).map InPlay.skel = l.map InPlay.skel := by
  simp only [List.map_map]; rfl

theorem skel_omap_clampWith (K : Nat) (c : Cap) (o : Option InPlay) :
    (o.map (InPlay.clampWith K c)).map InPlay.skel = o.map InPlay.skel := by
  cases o <;> rfl

theorem GameState.skel_clampAt (co cp cbo cbp : Cap) (k : Nat) (g : GameState) :
    (g.clampAt co cp cbo cbp k).skel = g.skel := by
  simp only [GameState.skel, GameState.clampAt, PlayerState.skel, skel_map_clampWith,
    skel_omap_clampWith, Store.cap_cap_zero]

theorem GameState.skel_xclampAt (K : Nat) (co cp cb : Cap) (g : GameState) :
    (g.xclampAt K co cp cb).skel = g.skel := by
  simp only [GameState.skel, GameState.xclampAt, PlayerState.skel, skel_map_clampWith,
    skel_omap_clampWith]

theorem GameState.skel_of_clamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.clamp k = g₂.clamp k) :
    g₁.skel = g₂.skel := by
  rw [← GameState.skel_clampAt .hp .hp .hp .hp k g₁, ← GameState.skel_clampAt .hp .hp .hp .hp k g₂]
  exact congrArg GameState.skel h

theorem GameState.skel_of_xclamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.xclamp k = g₂.xclamp k) :
    g₁.skel = g₂.skel := by
  rw [← GameState.skel_xclampAt k .hp .hp .hp g₁, ← GameState.skel_xclampAt k .hp .hp .hp g₂]
  exact congrArg GameState.skel h

/-! ## Observed triggers -/

/-- **The triggers observed on a move from `g` to `g₁`**: `obs` read on the two skeletons, for a
move from a `Settled` state that leaves the game going; none otherwise (in particular none after a
batch Knock Out step, which is the only move from a state that is not `Settled`). -/
def obsGate (obs : GameState → GameState → List Ability) (g g₁ : GameState) : List Ability :=
  if g.settledB && g₁.winner.isNone then obs g.skel g₁.skel else []

/-- **A move followed by firing the observed triggers** (milestone MV5, Part B). -/
inductive OMove (ev : TrigEvent) (obs : GameState → GameState → List Ability) :
    GameState → GameState → Prop where
  | mk {g g₁ g' : GameState} {l : List Ability} (hm : Move g g₁) (hl : l.Perm (obsGate obs g g₁))
      (hf : Fire ev l g₁ g') : OMove ev obs g g'

/-- Reachability by `OMove`, as `Reach` by `Move`. -/
inductive OReach (ev : TrigEvent) (obs : GameState → GameState → List Ability) :
    GameState → GameState → Prop where
  | refl (g : GameState) : OReach ev obs g g
  | step {g₀ g g' : GameState} : OReach ev obs g₀ g → g.winner = none → OMove ev obs g g' →
      OReach ev obs g₀ g'

/-- Every observed trigger resolves an effect of the trigger fragment. -/
def ObsTrigOk (ev : TrigEvent) (obs : GameState → GameState → List Ability) : Prop :=
  ∀ g g' ab, ab ∈ obs g g' → (ab.script ev.place).trigOk = true

variable {ev : TrigEvent} {obs : GameState → GameState → List Ability}

theorem obsGate_of_not_settled {g g₁ : GameState} (h : ¬ Settled g) : obsGate obs g g₁ = [] := by
  have : g.settledB = false := by
    cases e : g.settledB
    · rfl
    · exact absurd ((GameState.settled_iff g).2 e) h
  simp only [obsGate, this, Bool.false_and]; rfl

theorem obsGate_of_won {g g₁ : GameState} (h : g₁.winner ≠ none) : obsGate obs g g₁ = [] := by
  have : g₁.winner.isNone = false := by
    cases e : g₁.winner
    · exact absurd e h
    · rfl
  simp only [obsGate, this, Bool.and_false]; rfl

theorem obsGate_sub {g g₁ : GameState} {ab : Ability} (h : ab ∈ obsGate obs g g₁) :
    ab ∈ obs g.skel g₁.skel := by
  unfold obsGate at h; split at h
  · exact h
  · nomatch h

/-! ## Frame facts -/

theorem OMove.wellFormed {g g' : GameState} (h : OMove ev obs g g') (hw : WellFormed g) :
    WellFormed g' := by
  cases h with
  | mk hm _ hf => exact (hm.wellFormed hw).of_frame hf.frame

theorem OReach.wellFormed {g₀ g : GameState} (h₀ : WellFormed g₀) (h : OReach ev obs g₀ g) :
    WellFormed g := by
  induction h with
  | refl => exact h₀
  | step _ _ hm ih => exact hm.wellFormed ih

theorem OMove.perm {g g' : GameState} (h : OMove ev obs g g') : g'.allCards.Perm g.allCards := by
  cases h with
  | mk hm _ hf => exact hf.perm.trans hm.perm

theorem OReach.perm {g₀ g : GameState} (h : OReach ev obs g₀ g) : g.allCards.Perm g₀.allCards := by
  induction h with
  | refl => exact .refl _
  | step _ _ hm ih => exact hm.perm.trans ih

/-- A trigger resolution keeps `Fit`: it permutes the cards and stores no reduction. -/
theorem Fire.fit {k : Nat} {l : List Ability} {g g' : GameState} (h : Fire ev l g g')
    (hF : g.Fit k) : g'.Fit k :=
  ⟨hF.1, hF.2.1.of_perm h.perm, fun x hx => hF.2.2.1 x (h.perm.mem_iff.1 hx),
    h.zoneOnly.noReduce hF.2.2.2.1, hF.2.2.2.2.of_perm h.perm⟩

theorem OMove.fit {k : Nat} {g g' : GameState} (h : OMove ev obs g g') (hF : g.Fit k) : g'.Fit k := by
  cases h with
  | mk hm _ hf => exact hf.fit (hm.fit hF)

theorem OReach.fit {k : Nat} {g₀ g : GameState} (h : OReach ev obs g₀ g) (hF : g₀.Fit k) :
    g.Fit k := by
  induction h with
  | refl => exact hF
  | step _ _ hm ih => exact hm.fit ih

/-! ## The observation is a function of the clamp class -/

theorem GameState.settledB_of_clamp {k : Nat} {g₁ g₂ : GameState} (hc : g₁.clamp k = g₂.clamp k)
    (h₁ : g₁.HpBelow k) (h₂ : g₂.HpBelow k) : g₁.settledB = g₂.settledB := by
  cases e₁ : g₁.settledB <;> cases e₂ : g₂.settledB
  · rfl
  · exact absurd ((GameState.settled_iff g₁).1
      (GameState.settled_of_clamp hc.symm ((GameState.settled_iff g₂).2 e₂) h₂)) (by rw [e₁]; decide)
  · exact absurd ((GameState.settled_iff g₂).1
      (GameState.settled_of_clamp hc ((GameState.settled_iff g₁).2 e₁) h₁)) (by rw [e₂]; decide)
  · rfl

/-- **Congruence**: two moves whose end states have the same clamps observe the same triggers. -/
theorem obsGate_of_clamp {k : Nat} {g₁ g₂ g₁' g₂' : GameState} (hc : g₁.clamp k = g₂.clamp k)
    (hc' : g₁'.clamp k = g₂'.clamp k) (h₁ : g₁.HpBelow k) (h₂ : g₂.HpBelow k) :
    obsGate obs g₁ g₁' = obsGate obs g₂ g₂' := by
  have hw : g₁'.winner = g₂'.winner := congrArg (fun g => g.winner) hc'
  simp only [obsGate, GameState.settledB_of_clamp hc h₁ h₂, hw, GameState.skel_of_clamp hc,
    GameState.skel_of_clamp hc']

theorem obsGate_of_xclamp {k : Nat} {g₁ g₂ g₁' g₂' : GameState} (hc : g₁.xclamp k = g₂.xclamp k)
    (hc' : g₁'.xclamp k = g₂'.xclamp k) (h₁ : g₁.HpBelow k) (h₂ : g₂.HpBelow k) :
    obsGate obs g₁ g₁' = obsGate obs g₂ g₂' := by
  have hw : g₁'.winner = g₂'.winner := congrArg (fun g => g.winner) hc'
  simp only [obsGate, GameState.settledB_of_clamp (GameState.clamp_of_xclamp hc) h₁ h₂, hw,
    GameState.skel_of_xclamp hc, GameState.skel_of_xclamp hc']

/-! ## The simulations -/

/-- **`Move.clamp_sim` for `OMove`.** -/
theorem OMove.clamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} (hF : g₁.Fit k) (h : OMove ev obs g₁ g₁')
    (hc : g₁.clamp k = g₂.clamp k) : ∃ g₂', OMove ev obs g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  cases h with
  | mk hm hl hf =>
      obtain ⟨m₂, hm₂, hc'⟩ := hm.clamp_sim hF hc
      have e := obsGate_of_clamp (obs := obs) hc hc' hF.2.1.below (hF.of_clamp hc).2.1.below
      obtain ⟨g₂', hf₂, hc''⟩ := hf.clamp_sim (co := .hp) (cp := .hp) (cbo := .hp) (cbp := .hp) hc'
      exact ⟨g₂', .mk hm₂ (e ▸ hl) hf₂, hc''⟩

/-- `Reach.clamp_bounded`, whose proof does not use reachability, for any state. -/
theorem GameState.clamp_bounded (C : List Card) (g : GameState) :
    SideDamageLe (bound C) (g.clamp (bound C)).cur ∧ SideDamageLe (bound C) (g.clamp (bound C)).opp := by
  have hA : ∀ q : InPlay, (q.clampWith (bound C) .hp).damage ≤ bound C ∧
      (q.clampWith (bound C) .hp).poisonUp ≤ bound C :=
    fun _ => ⟨Nat.min_le_right _ _, Nat.min_le_right _ _⟩
  refine ⟨⟨fun p hp => ?_, fun p hp => ?_, storeLe_cap _ _⟩,
    ⟨fun p hp => ?_, fun p hp => ?_, storeLe_cap _ _⟩⟩
  · obtain ⟨q, _, rfl⟩ := Option.map_eq_some_iff.1 hp; exact hA q
  · obtain ⟨q, _, rfl⟩ := List.mem_map.1 hp; exact hA q
  · obtain ⟨q, _, rfl⟩ := Option.map_eq_some_iff.1 hp; exact hA q
  · obtain ⟨q, _, rfl⟩ := List.mem_map.1 hp; exact hA q

/-- **`Reach.finite` for `OReach`**: the same statement, for every observation. -/
theorem OReach.finite {g₀ : GameState} (hF : g₀.Fit (bound g₀.allCards)) :
    (∃ L : List GameState, ∀ g, OReach ev obs g₀ g → g.clamp (bound g₀.allCards) ∈ L) ∧
      ∀ g₁ g₂, OReach ev obs g₀ g₁ →
        g₁.clamp (bound g₀.allCards) = g₂.clamp (bound g₀.allCards) →
        (∀ g₁', OMove ev obs g₁ g₁' → ∃ g₂', OMove ev obs g₂ g₂' ∧
            g₁'.clamp (bound g₀.allCards) = g₂'.clamp (bound g₀.allCards)) ∧
        (∀ g₂', OMove ev obs g₂ g₂' → ∃ g₁', OMove ev obs g₁ g₁' ∧
            g₂'.clamp (bound g₀.allCards) = g₁'.clamp (bound g₀.allCards)) := by
  refine ⟨⟨states g₀.allCards, fun g h => mem_states ?_ (GameState.clamp_bounded _ g)⟩,
    fun g₁ g₂ h hc => ⟨fun g₁' hm => ?_, fun g₂' hm => ?_⟩⟩
  · rw [GameState.allCards_clamp]; exact h.perm
  · exact hm.clamp_sim (h.fit hF) hc
  · exact hm.clamp_sim ((h.fit hF).of_clamp hc) hc.symm

theorem OMove.xclamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} (hF : g₁.XFit k)
    (h : OMove ev obs g₁ g₁') (hc : g₁.xclamp k = g₂.xclamp k) :
    ∃ g₂', OMove ev obs g₂ g₂' ∧ g₁'.xclamp k = g₂'.xclamp k := by
  cases h with
  | mk hm hl hf =>
      obtain ⟨m₂, hm₂, hc'⟩ := hm.xclamp_sim hF hc
      have e := obsGate_of_xclamp (obs := obs) hc hc' hF.1.below (hF.of_xclamp hc).1.below
      obtain ⟨g₂', hf₂, hc''⟩ := hf.xclamp_sim (co := .hp) (cp := .hp) (cb := .hp) hc'
      exact ⟨g₂', .mk hm₂ (e ▸ hl) hf₂, hc''⟩

theorem OReach.xfit {k : Nat} {g₀ g : GameState} (h : OReach ev obs g₀ g) (hF : g₀.XFit k) :
    g.XFit k :=
  hF.of_perm h.perm

/-- **`Reach.xclamp_bisim` for `OReach`.** -/
theorem OReach.xclamp_bisim {g₀ g₁ g₂ : GameState} (h : OReach ev obs g₀ g₁)
    (hc : g₁.xclamp (Enum.bound g₀.allCards) = g₂.xclamp (Enum.bound g₀.allCards)) :
    (∀ g₁', OMove ev obs g₁ g₁' → ∃ g₂', OMove ev obs g₂ g₂' ∧
        g₁'.xclamp (Enum.bound g₀.allCards) = g₂'.xclamp (Enum.bound g₀.allCards)) ∧
      (∀ g₂', OMove ev obs g₂ g₂' → ∃ g₁', OMove ev obs g₁ g₁' ∧
        g₂'.xclamp (Enum.bound g₀.allCards) = g₁'.xclamp (Enum.bound g₀.allCards)) := by
  have hF := h.xfit (GameState.xfit_bound g₀)
  exact ⟨fun g₁' hm => hm.xclamp_sim hF hc, fun g₂' hm => hm.xclamp_sim (hF.of_xclamp hc) hc.symm⟩

/-! ## The store bound -/

namespace StoreSafe

/-- **The store invariant is kept by `OMove`**, when every observed trigger recycles nothing. -/
theorem TInv.omove {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState} (hm : OMove ev obs g g')
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hL : g.LoopFree) (hG : g.GXOnly) (hR : g.RecycleSafe)
    (hAb : g.AbilitySafe) (hSS : g.StadiumSafe) (hA : ∀ x ∈ g.allCards, x.atkAmt ≤ A)
    (hP : cardsAmt g.allCards ≤ P)
    (hQ : ∀ c ∈ g.allCards, ∀ ab ∈ c.abilities, ab.q P ≤ Q)
    (hRq : ∀ x ∈ g.allCards, x.stQ P ≤ R) (hK : potBound g.allCards.length ≤ K)
    (hwn : g.winner = none)
    (hN : ∀ g₁ ab, Move g g₁ → ab ∈ obsGate obs g g₁ → (ab.script ev.place).recFilters = []) :
    ∃ Y₀ Y₁ Y₂ E' F, TInv S A P Q K R g' Y₀ Y₁ Y₂ E' F := by
  cases hm with
  | mk hm' hl hf =>
      rename_i g₁ l
      obtain ⟨Y₀, Y₁, Y₂, E', F, hi₁⟩ := hi.move hm' hL hG hR hAb hSS hA hP hQ hRq hK hwn
      by_cases hw : g₁.winner = none
      · have hn : ∀ ab ∈ l, (ab.script ev.place).recFilters = [] := fun ab hab =>
          hN g₁ ab hm' (hl.mem_iff.1 hab)
        have z := hf.zoneOnly
        have hd := fun (w : Card → Nat) (hw' : TrainerWeight w) =>
          hf.disc_mono hw' (C := g₁.allCards) (fun ab hab => Effect.recOk_nil (hn ab hab))
            (fun _ hy => hy)
        exact ⟨_, _, _, _, _, hi₁.same' hw (fun _ => hd _ Card.wAmt_tw) (hd _ Card.alAmt_tw)
          z.attacked z.cur_supporterPlayed z.cur_gxUsed z.opp_gxUsed (hf.slotAmt)
          (fun _ => hf.abPot_le) (Nat.le_of_eq (GameState.stPot_congr z.stadiumPlayed z.stadiumUsed))⟩
      · have e : l = [] := by
          rw [obsGate_of_won hw] at hl; exact hl.eq_nil
        subst e
        rw [hf.nil_eq]
        exact ⟨_, _, _, _, _, hi₁⟩

theorem oreach_tinv {g₀ g : GameState} (hF : g₀.StoreSafe) (h : OReach ev obs g₀ g)
    (hN : ∀ g g₁ ab, g.allCards.Perm g₀.allCards → Move g g₁ → ab ∈ obsGate obs g g₁ →
      (ab.script ev.place).recFilters = []) :
    ∃ X₀ X₁ X₂ D E, TInv g₀.storeTotal (cardsAtkAmt g₀.allCards) (cardsAmt g₀.allCards)
      (cardsAbQ (cardsAmt g₀.allCards) g₀.allCards) (potBound g₀.allCards.length)
      (cardsStQ (cardsAmt g₀.allCards) g₀.allCards) g X₀ X₁ X₂ D E := by
  induction h with
  | refl => exact ⟨_, _, _, _, _, TInv.start _ _ _ _ _ _ (GameState.abPot_le_bound _)⟩
  | step hr hn hm ih =>
      obtain ⟨X₀, X₁, X₂, D, E, hi⟩ := ih
      have hp := hr.perm
      exact hi.omove hm (hF.1.of_perm hp) (hF.2.1.of_perm hp) (hF.2.2.1.of_perm hp)
        (hF.2.2.2.1.of_perm hp) (hF.2.2.2.2.of_perm hp)
        (fun x hx => atkAmt_le_cardsAtkAmt (hp.mem_iff.1 hx))
        (Nat.le_of_eq (cardsAmt_perm hp))
        (fun p hx ab hab => Ability.q_le (hp.mem_iff.1 hx) hab)
        (fun x hx => stQ_le_cardsStQ (hp.mem_iff.1 hx))
        (by rw [hp.length_eq]; exact Nat.le_refl _) hn (fun g₁ ab => hN _ g₁ ab hp)

/-- **`StoreSafe.reach_boundedStores` for `OReach`**, when no observed trigger recycles. -/
theorem oreach_boundedStores {g₀ g : GameState} (hF : g₀.StoreSafe) (h : OReach ev obs g₀ g)
    (hN : ∀ g g₁ ab, g.allCards.Perm g₀.allCards → Move g g₁ → ab ∈ obsGate obs g g₁ →
      (ab.script ev.place).recFilters = []) :
    g.BoundedStores (storeBound g₀) := by
  obtain ⟨X₀, X₁, X₂, D, E, hi⟩ := oreach_tinv hF h hN
  have hd : g.discW Card.alAmt ≤ cardsAmt g₀.allCards :=
    Nat.le_trans (GameState.discW_le Card.alAmt_le g) (Nat.le_of_eq (cardsAmt_perm h.perm))
  have ha := atkT_le (cardsAtkAmt g₀.allCards) g
  have hx := gxT_le (cardsAtkAmt g₀.allCards) g
  have := hi.x0; have := hi.x1; have := hi.x2
  have hn := hi.now; have hnx := hi.next; have haf := hi.after; have hal := hi.always
  have hB : ∀ s, g.slotAmt s ≤ storeBound g₀ := by
    intro s; cases s <;> simp only [storeBound] <;> omega
  have hc : ∀ s, (g.cur.mods.at s).amt ≤ storeBound g₀ := fun s =>
    Nat.le_trans (Nat.le_add_right _ _) (hB s)
  have ho : ∀ s, (g.opp.mods.at s).amt ≤ storeBound g₀ := fun s =>
    Nat.le_trans (Nat.le_add_left _ _) (hB s)
  exact ⟨⟨modsLe_of (hc .now), modsLe_of (hc .next), modsLe_of (hc .after), modsLe_of (hc .always)⟩,
    ⟨modsLe_of (ho .now), modsLe_of (ho .next), modsLe_of (ho .after), modsLe_of (ho .always)⟩⟩

/-- **`StoreSafe.xfinite` for `OReach`**, when no observed trigger recycles. -/
theorem oreach_xfinite {g₀ : GameState} (hF : g₀.StoreSafe)
    (hN : ∀ g g₁ ab, g.allCards.Perm g₀.allCards → Move g g₁ → ab ∈ obsGate obs g g₁ →
      (ab.script ev.place).recFilters = []) :
    (∃ L : List GameState, ∀ g, OReach ev obs g₀ g → g.xclamp (Enum.bound g₀.allCards) ∈ L) ∧
      ∀ g₁ g₂, OReach ev obs g₀ g₁ →
        g₁.xclamp (Enum.bound g₀.allCards) = g₂.xclamp (Enum.bound g₀.allCards) →
        (∀ g₁', OMove ev obs g₁ g₁' → ∃ g₂', OMove ev obs g₂ g₂' ∧
          g₁'.xclamp (Enum.bound g₀.allCards) = g₂'.xclamp (Enum.bound g₀.allCards)) ∧
        (∀ g₂', OMove ev obs g₂ g₂' → ∃ g₁', OMove ev obs g₁ g₁' ∧
          g₂'.xclamp (Enum.bound g₀.allCards) = g₁'.xclamp (Enum.bound g₀.allCards)) := by
  refine ⟨⟨xstates g₀.allCards (storeBound g₀), fun g h => ?_⟩, fun _ _ h hc => OReach.xclamp_bisim h hc⟩
  have hb := oreach_boundedStores hF h hN
  have hm : g.clamp (bound g₀.allCards) ∈ states g₀.allCards :=
    mem_states (by rw [GameState.allCards_clamp]; exact h.perm) (GameState.clamp_bounded _ g)
  rw [GameState.xclamp_eq (bound g₀.allCards)]
  simp only [xstates, List.mem_flatMap, List.mem_map]
  exact ⟨_, hm, g.cur.mods, mem_stores hb.1, g.opp.mods, mem_stores hb.2, rfl⟩

end StoreSafe

/-! ## Existence and the Knock Out check -/

/-- From a `Settled` state, every move to a state where the game goes on leaves both Active Spots
filled, except the moves that remove a Pokémon from play, which all take Knock Outs; we need only
the moves `Move.exists_move` uses. -/
theorem OMove.exists_move (hk : ObsTrigOk ev obs) (g : GameState) : ∃ g', OMove ev obs g g' := by
  have fire : ∀ {g₁ : GameState}, Move g g₁ → g₁.BothActive → ∃ g', OMove ev obs g g' := by
    intro g₁ hm hb
    obtain ⟨g', hf⟩ := Fire.exists (l := obsGate obs g g₁)
      (fun ab hab => hk _ _ ab (obsGate_sub hab)) hb
    exact ⟨g', .mk hm (.refl _) hf⟩
  by_cases hs : Settled g
  · obtain ⟨hk', hc, ho⟩ := hs
    match ha : g.opp.active, hb : g.cur.active with
    | none, _ => exact absurd ha ho
    | some _, none => exact absurd hb hc
    | some a, some b =>
        match hbt : g.between with
        | false => exact fire (.endTurn false false false false false false ha hb hk' hbt
            (BenchChar.refl _) (BenchChar.refl _)) ⟨rfl, rfl⟩
        | true =>
            match hd : g.cur.deck with
            | [] => exact fire (.deckOut hbt ha hb hk' hd) ⟨by simp [hb], by simp [ha]⟩
            | c :: d => exact fire (.startTurn hbt ha hb hk' hd) ⟨by simp [hb], by simp [ha]⟩
  · obtain ⟨g₁, hm⟩ := KOBatch.exists_of hs
    obtain ⟨g', l, hl, ht⟩ := hm.trigs_exist
    exact ⟨g', .mk (.knockOuts hm hl ht) (by rw [obsGate_of_not_settled hs]) (.nil _)⟩

/-- **From a state that is not `Settled`, `OMove` is `Move`**: the only move is the batch Knock Out
step, and nothing is observed after it. -/
theorem OMove.unsettled_iff {g g' : GameState} (hu : ¬ Settled g) :
    OMove ev obs g g' ↔ Move g g' := by
  constructor
  · intro h
    cases h with
    | mk hm hl hf =>
        rw [obsGate_of_not_settled hu] at hl
        rw [hl.eq_nil] at hf
        rw [hf.nil_eq]; exact hm
  · intro hm
    exact .mk hm (by rw [obsGate_of_not_settled hu]) (.nil _)

/-- **The Knock Out check terminates under `OMove`** (`Move.unsettled_acc`). -/
theorem OMove.unsettled_acc (g : GameState) :
    Acc (fun b a => ¬ Settled a ∧ a.winner = none ∧ OMove ev obs a b) g := by
  have h := Move.unsettled_acc g
  induction h with
  | intro x _ ih =>
      exact .intro _ fun y ⟨hu, hw, hm⟩ => ih y ⟨hu, hw, (OMove.unsettled_iff hu).1 hm⟩

end Pokemon
