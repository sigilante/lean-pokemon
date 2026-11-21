import Pokemon.Conservation

/-!
# Damage: what is bounded, and a clamp that makes it bounded

Damage is the one numeric component of the state that legal play can make large
(`counters_unbounded`). This file shows that the excess carries no information.

* `Move.damageBounded_of_turn`: every move that passes the turn (the only such move is
  `endTurn`) yields a `DamageBounded` state. This is immediate from the `endTurn` guard.
* `GameState.clamp` replaces the damage `d` on the OPPONENT'S Active Pokémon (the only place
  where `counters` puts damage) by `min d hp`. `Run.clamp_sim`, `Move.clamp_sim` and
  `Reach.clamp_sim`: states with the same clamp have the same moves, up to the same clamp. So
  the kernel of `clamp` is a (strong) bisimulation for `Move`, and every question about
  legal play that does not read the exact damage above HP on that one Pokémon can be asked
  of the clamped states instead.
* `Reach.damage_le`: from a `DamageBounded` start, every Pokémon in play other than the
  opponent's Active has at most `maxHp g₀.allCards` damage counters, in EVERY reachable state
  (mid-turn included). No rule needed to change for this.

Why only the opponent's Active is clamped. The player's own Active can also exceed its HP
mid-turn (evolving into a card with less HP), but `heal` reads its damage exactly
(`5 - 2 = 3 ≥ 3` while `min 5 3 - 2 = 1 < 3`), so clamping it would not be a bisimulation.
Its damage is instead bounded by `Reach.damage_le`: evolution keeps the damage, and the
damage was below the HP of the card underneath, which is still in the game.
-/

namespace Pokemon

/-- Damage capped at the printed HP. -/
def InPlay.clamp (p : InPlay) : InPlay := { p with damage := min p.damage p.top.hp }

/-- Cap the damage on the opponent's Active Pokémon at its HP. Every other component,
including the damage on every other Pokémon, is unchanged. -/
def GameState.clamp (g : GameState) : GameState :=
  { g with opp := { g.opp with active := g.opp.active.map InPlay.clamp } }

/-! ## Turn boundaries -/

theorem Run.curIsFirst_eq {e : Effect} {g g' : GameState} (h : Run e g g') :
    g'.curIsFirst = g.curIsFirst := by
  induction h with
  | seq _ _ ih₁ ih₂ => rw [ih₂, ih₁]
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterCons _ _ ih₁ ih₂ => rw [ih₂, ih₁]
  | _ => rfl

/-- Every move that passes the turn yields a state with no pending Knock Out. -/
theorem Move.damageBounded_of_turn {g g' : GameState} (h : Move g g')
    (ht : g'.curIsFirst ≠ g.curIsFirst) : DamageBounded g' := by
  cases h with
  | item hh hr => exact absurd hr.curIsFirst_eq ht
  | supporter hh hs hr => exact absurd hr.curIsFirst_eq ht
  | attack ha hm hc hn hf hr => exact absurd hr.curIsFirst_eq ht
  | endTurn ha hb hk hd =>
      intro p hp
      rcases hp with hp | hp | hp | hp
      · exact hk p (Or.inr (Or.inr (Or.inl hp)))
      · exact hk p (Or.inr (Or.inr (Or.inr hp)))
      · obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.1 hp
        exact hk q (Or.inl hq)
      · obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
        exact hk q (Or.inr (Or.inl hq))
  | _ => exact absurd rfl ht

/-! ## The clamp is a bisimulation -/

namespace InPlay

theorem clamp_inj_top {p q : InPlay} (h : q.clamp = p.clamp) : q.top = p.top := by
  have := congrArg InPlay.top h
  exact this

theorem clamp_inj_cardList {p q : InPlay} (h : q.clamp = p.clamp) :
    q.cardList = p.cardList := by
  have := congrArg InPlay.cardList h
  exact this

theorem clamp_inj_ko {p q : InPlay} (h : q.clamp = p.clamp) (hk : p.top.hp ≤ p.damage) :
    q.top.hp ≤ q.damage := by
  have hd := congrArg InPlay.damage h
  have ht := clamp_inj_top h
  simp only [clamp] at hd
  rw [ht] at hd ⊢
  omega

theorem clamp_inj_of_lt {p q : InPlay} (h : q.clamp = p.clamp) (hl : p.damage < p.top.hp) :
    q = p := by
  cases p; cases q
  simp only [clamp, InPlay.mk.injEq] at h hl ⊢
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h9⟩ := h
  subst h1 h2 h3 h4 h6 h7 h8 h9
  refine ⟨rfl, rfl, rfl, rfl, ?_, rfl, rfl, rfl, rfl⟩
  omega

theorem clamp_add {p q : InPlay} (h : q.clamp = p.clamp) (n : Nat) :
    ({ q with damage := q.damage + n } : InPlay).clamp
      = ({ p with damage := p.damage + n } : InPlay).clamp := by
  cases p; cases q
  simp only [clamp, InPlay.mk.injEq] at h ⊢
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, h9⟩ := h
  subst h1 h2 h3 h4 h6 h7 h8 h9
  refine ⟨rfl, rfl, rfl, rfl, ?_, rfl, rfl, rfl, rfl⟩
  omega

end InPlay

/-- Two states with the same clamp differ at most in the opponent's Active Pokémon, and
there only in damage at or above HP. -/
theorem GameState.clamp_inv {g₁ g₂ : GameState} (h : g₁.clamp = g₂.clamp) :
    ∃ a₂, g₂ = { g₁ with opp := { g₁.opp with active := a₂ } } ∧
      a₂.map InPlay.clamp = g₁.opp.active.map InPlay.clamp := by
  refine ⟨g₂.opp.active, ?_, (congrArg (fun g => g.opp.active) h).symm⟩
  have e : g₂ = { g₂.clamp with opp := { g₂.clamp.opp with active := g₂.opp.active } } := rfl
  refine e.trans ?_
  rw [← h]
  rfl

theorem GameState.clamp_setCur {g₁ g₂ : GameState} {s : PlayerState}
    (h : g₁.clamp = g₂.clamp) :
    ({ g₁ with cur := s } : GameState).clamp = ({ g₂ with cur := s } : GameState).clamp := by
  have e₁ : ({ g₁ with cur := s } : GameState).clamp = { g₁.clamp with cur := s } := rfl
  have e₂ : ({ g₂ with cur := s } : GameState).clamp = { g₂.clamp with cur := s } := rfl
  rw [e₁, e₂, h]

/-- The kernel of `clamp` is a bisimulation for `Run`. -/
theorem Run.clamp_sim {e : Effect} {g₁ g₁' : GameState} (h : Run e g₁ g₁') :
    ∀ {g₂ : GameState}, g₁.clamp = g₂.clamp →
      ∃ g₂', Run e g₂ g₂' ∧ g₁'.clamp = g₂'.clamp := by
  induction h with
  | skip g => intro g₂ hc; exact ⟨g₂, .skip g₂, hc⟩
  | draw h =>
      intro g₂ hc
      obtain ⟨a₂, rfl, ha⟩ := GameState.clamp_inv hc
      exact ⟨_, .draw h, by simp only [GameState.clamp, ha]⟩
  | drawEmpty h => intro g₂ hc; obtain ⟨a₂, rfl, ha⟩ := GameState.clamp_inv hc; exact ⟨_, .drawEmpty h, hc⟩
  | heal n h =>
      intro g₂ hc
      obtain ⟨a₂, rfl, ha⟩ := GameState.clamp_inv hc
      exact ⟨_, .heal n h, by simp only [GameState.clamp, ha]⟩
  | counters n h =>
      intro g₂ hc
      obtain ⟨a₂, rfl, ha⟩ := GameState.clamp_inv hc
      rw [h, Option.map_some] at ha
      obtain ⟨q, rfl, hq⟩ := Option.map_eq_some_iff.1 ha
      exact ⟨_, .counters n rfl, by simp only [GameState.clamp, Option.map_some, InPlay.clamp_add hq n]⟩
  | shuffle h =>
      intro g₂ hc
      obtain ⟨a₂, rfl, ha⟩ := GameState.clamp_inv hc
      exact ⟨_, .shuffle h, by simp only [GameState.clamp, ha]⟩
  | search h =>
      intro g₂ hc
      obtain ⟨a₂, rfl, ha⟩ := GameState.clamp_inv hc
      exact ⟨_, .search h, by simp only [GameState.clamp, ha]⟩
  | handToBottom h =>
      intro g₂ hc
      obtain ⟨a₂, rfl, ha⟩ := GameState.clamp_inv hc
      exact ⟨_, .handToBottom h, by simp only [GameState.clamp, ha]⟩
  | seq _ _ ih₁ ih₂ =>
      intro g₂ hc
      obtain ⟨g₂', h₁, hc'⟩ := ih₁ hc
      obtain ⟨g₂'', h₂, hc''⟩ := ih₂ hc'
      exact ⟨g₂'', .seq h₁ h₂, hc''⟩
  | choiceL _ ih =>
      intro g₂ hc
      obtain ⟨g₂', h₁, hc'⟩ := ih hc
      exact ⟨g₂', .choiceL h₁, hc'⟩
  | choiceR _ ih =>
      intro g₂ hc
      obtain ⟨g₂', h₁, hc'⟩ := ih hc
      exact ⟨g₂', .choiceR h₁, hc'⟩
  | iterNil a g => intro g₂ hc; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons _ _ ih₁ ih₂ =>
      intro g₂ hc
      obtain ⟨g₂', h₁, hc'⟩ := ih₁ hc
      obtain ⟨g₂'', h₂, hc''⟩ := ih₂ hc'
      exact ⟨g₂'', .iterCons h₁ h₂, hc''⟩

/-- The kernel of `clamp` is a bisimulation for `Move`: if `g₁` and `g₂` have the same
clamp, every move from `g₁` is matched by a move from `g₂` to a state with the same clamp.
(The relation is symmetric, so this gives both directions.) -/
theorem Move.clamp_sim {g₁ g₁' g₂ : GameState} (h : Move g₁ g₁')
    (hc : g₁.clamp = g₂.clamp) : ∃ g₂', Move g₂ g₂' ∧ g₁'.clamp = g₂'.clamp := by
  obtain ⟨a₂, rfl, ha₂⟩ := GameState.clamp_inv hc
  cases h with
  | playBasic hh hs hhp hb =>
      exact ⟨_, .playBasic hh hs hhp hb, by simp only [GameState.clamp, ha₂]⟩
  | attach hh hf ha => exact ⟨_, .attach hh hf ha, by simp only [GameState.clamp, ha₂]⟩
  | evolve hh ha he hfr hf =>
      exact ⟨_, .evolve hh ha he hfr hf, by simp only [GameState.clamp, ha₂]⟩
  | retreat ha hb hr he hp hk =>
      exact ⟨_, .retreat ha hb hr he hp hk, by simp only [GameState.clamp, ha₂]⟩
  | item hh hr =>
      obtain ⟨g₂', hr', hc'⟩ := Run.clamp_sim hr (GameState.clamp_setCur hc)
      exact ⟨g₂', .item hh hr', hc'⟩
  | supporter hh hs hr =>
      obtain ⟨g₂', hr', hc'⟩ := Run.clamp_sim hr (GameState.clamp_setCur hc)
      exact ⟨g₂', .supporter hh hs hr', hc'⟩
  | attack ha hm hc' hn hf hr =>
      obtain ⟨g₂', hr', hc''⟩ := Run.clamp_sim hr hc
      refine ⟨_, .attack ha hm hc' hn hf hr', ?_⟩
      have := congrArg (fun g : GameState => ({ g with attacked := true } : GameState)) hc''
      exact this
  | knockOut ha hk hp =>
      rw [ha, Option.map_some] at ha₂
      obtain ⟨q, rfl, hq⟩ := Option.map_eq_some_iff.1 ha₂
      refine ⟨_, Move.knockOut (p := q) rfl (InPlay.clamp_inj_ko hq hk) hp, ?_⟩
      simp only [GameState.clamp, Option.map_none, InPlay.clamp_inj_cardList hq]
  | promote ha hb =>
      rw [ha, Option.map_none] at ha₂
      have ha₃ : a₂ = none := Option.map_eq_none_iff.1 ha₂
      subst ha₃
      exact ⟨_, .promote rfl hb, rfl⟩
  | noPokemon ha hb =>
      rw [ha, Option.map_none] at ha₂
      have ha₃ : a₂ = none := Option.map_eq_none_iff.1 ha₂
      subst ha₃
      exact ⟨_, .noPokemon rfl hb, by simp only [GameState.clamp, ha, Option.map_none]⟩
  | knockOutOwn ha hk hp =>
      exact ⟨_, .knockOutOwn ha hk hp, by simp only [GameState.clamp, ha₂]⟩
  | promoteOwn ha hb => exact ⟨_, .promoteOwn ha hb, by simp only [GameState.clamp, ha₂]⟩
  | noPokemonOwn ha hb => exact ⟨_, .noPokemonOwn ha hb, by simp only [GameState.clamp, ha₂]⟩
  | endTurn ha hb hk hd =>
      rename_i a _ _ _
      rw [ha, Option.map_some] at ha₂
      obtain ⟨q, rfl, hq⟩ := Option.map_eq_some_iff.1 ha₂
      have hqa : q = a := InPlay.clamp_inj_of_lt hq (hk a (Or.inr (Or.inr (Or.inl ha))))
      subst hqa
      have e : ({ g₁ with opp := { g₁.opp with active := some q } } : GameState) = g₁ := by
        rw [← ha]
      rw [e]
      exact ⟨_, .endTurn ha hb hk hd, rfl⟩
  | deckOut ha hb hk hd =>
      rename_i a _
      rw [ha, Option.map_some] at ha₂
      obtain ⟨q, rfl, hq⟩ := Option.map_eq_some_iff.1 ha₂
      have hqa : q = a := InPlay.clamp_inj_of_lt hq (hk a (Or.inr (Or.inr (Or.inl ha))))
      subst hqa
      have e : ({ g₁ with opp := { g₁.opp with active := some q } } : GameState) = g₁ := by
        rw [← ha]
      rw [e]
      exact ⟨_, .deckOut ha hb hk hd, rfl⟩

/-- The kernel of `clamp` is a bisimulation for `Reach`: from start states with the same
clamp, the same clamped states are reachable. -/
theorem Reach.clamp_sim {g₀ h₀ g₁ : GameState} (h : Reach g₀ g₁) (hc : g₀.clamp = h₀.clamp) :
    ∃ g₂, Reach h₀ g₂ ∧ g₁.clamp = g₂.clamp := by
  induction h with
  | refl => exact ⟨h₀, .refl _, hc⟩
  | step _ hw hm ih =>
      obtain ⟨g₂, hr, hc'⟩ := ih
      obtain ⟨g₂', hm', hc''⟩ := hm.clamp_sim hc'
      have hw' : g₂.winner = none := by
        have e := congrArg GameState.winner hc'
        exact e.symm.trans hw
      exact ⟨g₂', .step hr hw' hm', hc''⟩

/-! ## Damage away from the opponent's Active Pokémon is bounded -/

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

/-- Every Pokémon in play, except the opponent's Active Pokémon, has at most `M` damage
counters. -/
def DamageLe (M : Nat) (g : GameState) : Prop :=
  ∀ p : InPlay, (g.cur.active = some p ∨ p ∈ g.cur.bench ∨ p ∈ g.opp.bench) → p.damage ≤ M

theorem Run.damageLe {e : Effect} {g g' : GameState} {M : Nat} (h : Run e g g') :
    DamageLe M g → DamageLe M g' := by
  induction h with
  | heal n h =>
      intro hJ p hp
      rcases hp with hp | hp | hp
      · cases hp
        have := hJ _ (Or.inl h)
        exact Nat.le_trans (Nat.sub_le _ _) this
      · exact hJ p (Or.inr (Or.inl hp))
      · exact hJ p (Or.inr (Or.inr hp))
  | seq _ _ ih₁ ih₂ => intro hJ; exact ih₂ (ih₁ hJ)
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterCons _ _ ih₁ ih₂ => intro hJ; exact ih₂ (ih₁ hJ)
  | _ => exact id

theorem Move.damageLe {g g' : GameState} {M : Nat} (h : Move g g')
    (hM : ∀ p, Card.pokemon p ∈ g.allCards → p.hp ≤ M) (hJ : DamageLe M g) :
    DamageLe M g' := by
  cases h with
  | playBasic hh hs hhp hb =>
      intro p hp
      rcases hp with hp | hp | hp
      · exact hJ p (Or.inl hp)
      · rcases List.mem_append.1 hp with hp | hp
        · exact hJ p (Or.inr (Or.inl hp))
        · rw [List.mem_singleton] at hp; subst hp; exact Nat.zero_le _
      · exact hJ p (Or.inr (Or.inr hp))
  | attach hh hf ha =>
      intro p hp
      rcases hp with hp | hp | hp
      · cases hp; have := hJ _ (Or.inl ha); exact this
      · exact hJ p (Or.inr (Or.inl hp))
      · exact hJ p (Or.inr (Or.inr hp))
  | evolve hh ha he hfr hf =>
      intro p hp
      rcases hp with hp | hp | hp
      · cases hp; have := hJ _ (Or.inl ha); exact this
      · exact hJ p (Or.inr (Or.inl hp))
      · exact hJ p (Or.inr (Or.inr hp))
  | retreat ha hb hr he hp' hk =>
      rename_i a q b₁ b₂ _ _
      have hq : q ∈ g.cur.bench := by rw [hb]; exact List.mem_append_right _ (.head _)
      intro p hp
      rcases hp with hp | hp | hp
      · cases hp; exact hJ _ (Or.inr (Or.inl hq))
      · rcases List.mem_append.1 hp with hp | hp
        · exact hJ p (Or.inr (Or.inl (by rw [hb]; exact List.mem_append_left _ hp)))
        · cases hp with
          | head =>
              have := hM _ (GameState.top_mem_cur_active ha)
              exact Nat.le_of_lt (Nat.lt_of_lt_of_le hk this)
          | tail _ hp =>
              exact hJ p (Or.inr (Or.inl (by
                rw [hb]; exact List.mem_append_right _ (.tail _ hp))))
      · exact hJ p (Or.inr (Or.inr hp))
  | item hh hr => exact hr.damageLe hJ
  | supporter hh hs hr => exact hr.damageLe hJ
  | attack ha hm hc hn hf hr => exact hr.damageLe hJ
  | knockOut ha hk hp => exact hJ
  | promote ha hb =>
      intro p hp
      rcases hp with hp | hp | hp
      · exact hJ p (Or.inl hp)
      · exact hJ p (Or.inr (Or.inl hp))
      · refine hJ p (Or.inr (Or.inr ?_))
        rw [hb]
        rcases List.mem_append.1 hp with hp | hp
        · exact List.mem_append_left _ hp
        · exact List.mem_append_right _ (.tail _ hp)
  | noPokemon ha hb => exact hJ
  | knockOutOwn ha hk hp =>
      intro p hp
      rcases hp with hp | hp | hp
      · cases hp
      · exact hJ p (Or.inr (Or.inl hp))
      · exact hJ p (Or.inr (Or.inr hp))
  | promoteOwn ha hb =>
      rename_i q b₁ b₂
      intro p hp
      rcases hp with hp | hp | hp
      · cases hp
        exact hJ _ (Or.inr (Or.inl (by rw [hb]; exact List.mem_append_right _ (.head _))))
      · refine hJ p (Or.inr (Or.inl ?_))
        rw [hb]
        rcases List.mem_append.1 hp with hp | hp
        · exact List.mem_append_left _ hp
        · exact List.mem_append_right _ (.tail _ hp)
      · exact hJ p (Or.inr (Or.inr hp))
  | noPokemonOwn ha hb => exact hJ
  | endTurn ha hb hk hd =>
      intro p hp
      rcases hp with hp | hp | hp
      · have := hM _ (GameState.top_mem_opp_active hp)
        exact Nat.le_of_lt (Nat.lt_of_lt_of_le (hk p (Or.inr (Or.inr (Or.inl hp)))) this)
      · exact hJ p (Or.inr (Or.inr hp))
      · obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
        exact hJ q (Or.inr (Or.inl hq))
  | deckOut ha hb hk hd => exact hJ

/-- From a start state with no pending Knock Out, in every reachable state (mid-turn states
included) every Pokémon in play other than the opponent's Active Pokémon has at most
`maxHp g₀.allCards` damage counters: the largest printed HP among the cards of the game. -/
theorem Reach.damage_le {g₀ g : GameState} (h₀ : DamageBounded g₀) (h : Reach g₀ g) :
    DamageLe (maxHp g₀.allCards) g := by
  induction h with
  | refl =>
      intro p hp
      have hlt : p.damage < p.top.hp := by
        rcases hp with hp | hp | hp
        · exact h₀ p (Or.inl hp)
        · exact h₀ p (Or.inr (Or.inl hp))
        · exact h₀ p (Or.inr (Or.inr (Or.inr hp)))
      have hmem : Card.pokemon p.top ∈ g₀.allCards := by
        rcases hp with hp | hp | hp
        · exact GameState.top_mem_cur_active hp
        · exact GameState.top_mem_cur_bench hp
        · exact GameState.top_mem_opp_bench hp
      exact Nat.le_of_lt (Nat.lt_of_lt_of_le hlt (hp_le_maxHp hmem))
  | step hr _ hm ih =>
      exact hm.damageLe (fun p hp => hp_le_maxHp ((hr.perm.mem_iff).1 hp)) ih

/-- From a start state with no pending Knock Out, in the clamp of every reachable state
every Pokémon in play has at most `maxHp g₀.allCards` damage counters. -/
theorem Reach.clamp_damage_le {g₀ g : GameState} (h₀ : DamageBounded g₀) (h : Reach g₀ g)
    (p : InPlay)
    (hp : g.clamp.cur.active = some p ∨ p ∈ g.clamp.cur.bench ∨
      g.clamp.opp.active = some p ∨ p ∈ g.clamp.opp.bench) :
    p.damage ≤ maxHp g₀.allCards := by
  have hJ := h.damage_le h₀
  rcases hp with hp | hp | hp | hp
  · exact hJ p (Or.inl hp)
  · exact hJ p (Or.inr (Or.inl hp))
  · obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.1 hp
    have hmem := h.perm.mem_iff.1 (GameState.top_mem_opp_active hq)
    exact Nat.le_trans (Nat.min_le_right _ _) (hp_le_maxHp hmem)
  · exact hJ p (Or.inr (Or.inr hp))

end Pokemon
