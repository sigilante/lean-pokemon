import Pokemon.StaticWitness

/-!
# Decks without static effects (milestone M6)

Milestone M6 made HP, the damage of an attack and the Retreat Cost functions of the state, and
restated the clamps with a bound on derived HP. For a game none of whose cards has a static effect
(`GameState.NoStatics`, which play preserves) everything is what it was before M6:

* `GameState.NoStatics.damageBounded_iff`: no pending Knock Out means every Pokémon in play is
  below its printed HP (the definition of `DamageBounded` before M6);
* `GameState.NoStatics.ko_iff`: the Knock Out premise at a place is the printed one;
* `GameState.NoStatics.dealt`: the damage calculation is the one before M6;
* `GameState.NoStatics.retreatOf`: the Retreat Cost is the printed one;
* `hpBound_noStatics`, `Enum.bound_noStatics`: the bound is the one before M6 (largest printed
  HP, plus Resistance and test constants);
* `GameState.NoStatics.hpLe_iff`: `HpLe k` is the condition before M6 (every printed HP and
  Resistance at most `k`), and `GameState.NoStatics.staticTame`: the new clause of `Fit` holds;
* `GameState.fit_bound_noStatics`: `GameState.fit_bound` with the hypotheses it had before M6.
-/

namespace Pokemon

theorem Reach.noStatics {g₀ g : GameState} (h : Reach g₀ g) (h₀ : g₀.NoStatics) : g.NoStatics :=
  h₀.of_perm h.perm

theorem GameState.NoStatics.staticTame {g : GameState} (h : g.NoStatics) : g.StaticTame :=
  fun c hc s hs => by rw [h c hc] at hs; nomatch hs

theorem GameState.NoStatics.plain {g : GameState} (h : g.NoStatics) : g.Plain := by
  refine ⟨fun u e he => ?_, ?_⟩
  · obtain ⟨q, hq, he2⟩ := mem_fieldOf he
    rw [he2]
    exact InPlay.sv_statics_nil fun c hc => h c (GameState.cardList_sub hq hc)
  · unfold stadiumStatics
    split
    · rfl
    · next o c hs =>
        exact h c (by simp only [GameState.allCards, hs, stadiumCardList, List.mem_append,
          List.mem_singleton, or_true])

/-- With no static effects, the Knock Out premise at a place is the printed one. -/
theorem GameState.NoStatics.ko_iff {g : GameState} (h : g.NoStatics) {w : Whose} {sp : Spot}
    {p : InPlay} (hp : g.In w sp p) : g.hpOf w sp p ≤ p.damage ↔ p.top.hp ≤ p.damage := by
  rw [g.hpOf_noStatics h hp]

/-- **With no static effects, `DamageBounded` is its definition before milestone M6.** -/
theorem GameState.NoStatics.damageBounded_iff {g : GameState} (h : g.NoStatics) :
    DamageBounded g ↔ ∀ p : InPlay,
      (g.cur.active = some p ∨ p ∈ g.cur.bench ∨ g.opp.active = some p ∨ p ∈ g.opp.bench) →
        p.damage < p.top.hp := by
  constructor
  · intro hk p hp
    rcases hp with hp | hp | hp | hp
    · have := hk .own .active p hp
      rwa [g.hpOf_noStatics (w := .own) (sp := .active) h hp] at this
    · have := hk .own .bench p hp
      rwa [g.hpOf_noStatics (w := .own) (sp := .bench) h hp] at this
    · have := hk .opp .active p hp
      rwa [g.hpOf_noStatics (w := .opp) (sp := .active) h hp] at this
    · have := hk .opp .bench p hp
      rwa [g.hpOf_noStatics (w := .opp) (sp := .bench) h hp] at this
  · intro hk w sp p hp
    rw [g.hpOf_noStatics h hp]
    cases w <;> cases sp
    · exact hk p (.inl hp)
    · exact hk p (.inr (.inl hp))
    · exact hk p (.inr (.inr (.inl hp)))
    · exact hk p (.inr (.inr (.inr hp)))

/-- With no static effects, the damage calculation is the one before milestone M6. -/
theorem GameState.NoStatics.dealt {g : GameState} (h : g.NoStatics) (n : Nat) :
    g.dealt n = dealtBy n g.weak g.resist g.cur.mods g.opp.mods := by
  simp only [GameState.dealt, g.sBonus_noStatics h, g.sReduce_noStatics h,
    Store.add_bonus_zero, Store.add_reduce_zero]

/-- With no static effects, the Retreat Cost is the printed one. -/
theorem GameState.NoStatics.retreatOf {g : GameState} (h : g.NoStatics) {a : InPlay}
    (ha : g.cur.active = some a) : g.retreatOf a = a.top.retreat :=
  g.retreatOf_noStatics h ha

/-- With no static effects, `hpBound` is the largest printed HP. -/
theorem hpBound_noStatics {C : List Card} (h : ∀ c ∈ C, c.statics = []) : hpBound C = maxHp C :=
  Nat.le_antisymm (hpBound_le_of h fun _ hp => hp_le_maxHp hp) (Nat.le_add_right _ _)

/-- With no static effects, `Enum.bound` is its definition before milestone M6. -/
theorem Enum.bound_noStatics {C : List Card} (h : ∀ c ∈ C, c.statics = []) :
    Enum.bound C = maxHp C + maxResist C + cardsTmax C + 1 := by
  simp only [Enum.bound, hpBound_noStatics h]

/-- With no static effects, `HpLe k` is its definition before milestone M6. -/
theorem GameState.NoStatics.hpLe_iff {g : GameState} (h : g.NoStatics) {k : Nat} :
    g.HpLe k ↔ ∀ p : PokemonCard, Card.pokemon p ∈ g.allCards → p.hp ≤ k ∧ p.resistAmt ≤ k := by
  rw [GameState.HpLe, hpBound_noStatics h]
  constructor
  · exact fun hh p hp => ⟨Nat.le_trans (hp_le_maxHp hp) hh.1, hh.2 p hp⟩
  · exact fun hh => ⟨maxHp_le fun p hp => (hh p hp).1, fun p hp => (hh p hp).2⟩

/-- `GameState.fit_bound` with the hypotheses it had before milestone M6, for a deck without
static effects. -/
theorem GameState.fit_bound_noStatics {g₀ : GameState} (ht : ∀ x ∈ g₀.allCards, x.tame = true)
    (hn : g₀.NoReduce) (hs : g₀.NoStatics) : g₀.Fit (Enum.bound g₀.allCards) :=
  GameState.fit_bound ht hn hs.staticTame

end Pokemon
