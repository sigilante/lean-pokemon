import Pokemon.Promoted

/-!
# The holders are recorded at the event (milestone MV7b)

The review of milestone MV7 found that the `oppBenched` triggers that fired were read after the
whole attack's effect, so an attack that switches its user and THEN switches the opponent's Active
Pokémon (Iron Bundle sv6-62 *Interjet*; Quaquaval ex sv2-52; Baltoy sv3-94) changed which holders
fired: against Mismagius ex me2-36 ("As long as this Pokémon is in the Active Spot, whenever your
opponent's Active Pokémon moves to the Bench during their turn, their new Active Pokémon is now
Confused"), a holder in the Active Spot at the switch, gusted to the Bench, did not fire, and a
Benched one gusted in did (the reviewer's kernel-checked probe). Milestone MV7b records the holders
at the event: `GameState.noteBenched` marks each of the opponent's Pokémon that has such a trigger
where it is (`InPlay.owe`), the mark travels with the Pokémon, and the resolution fires the marked
ones (`GameState.owedTrigs`). The two cases are now theorems that the wrong outcome cannot happen.

The attacker `jetter` has `jet`, Interjet's order: 10 damage, switch the attacker with a Benched
Pokémon, then switch the opponent's Active Pokémon with one of their Benched Pokémon.

* `gust_drops_holder`: from `a0` (the opponent's Mismagius-like `misty` Active, `victim` Benched),
  every play that attacks and then makes a move Confuses the mover's new Active Pokémon, with
  `misty` on the Bench: the holder was in the Active Spot at the event; `gust_drops_runs`: such a
  play exists and ends `Settled`.
* `gust_adds_holder`: from `b0` (`victim` Active; the Magcargo-like `watcher` and `misty` Benched),
  no play that attacks and then makes a move Confuses the mover's Active Pokémon, whichever Benched
  Pokémon the attack gusts in: `misty` was on the Bench at the event, where its trigger does not
  work; `watcher`, which works from the Bench, fires (Burned). `gust_adds_runs`: the play that gusts
  `misty` in, with the mover's Active Pokémon Burned and not Confused.
* `gust_probe_fails`: the reviewer's two statements, restricted to plays that begin with the attack,
  are false.
-/

namespace Pokemon.Gust
open Pokemon.Benched Pokemon.Promoted

/-- Iron Bundle sv6-62 Interjet's order: 10 damage, switch the attacker, then gust. -/
def jet : Attack := ⟨"Jet", [], 10, .seq (.switch .own) (.switch .opp), false, .none⟩

/-- A Basic Pokémon with `jet` and no Retreat Cost. -/
def jetterC : PokemonCard :=
  ⟨"Jetter", .basic, none, 10, .grass, [jet], 0, none, none, .none, false, []⟩

/-- The mover has `jetter` Active and `sitter` Benched; the opponent's side is `o`. -/
def stJ (o : PlayerState) : GameState :=
  ⟨side (InPlay.ofBasic jetterC) [InPlay.ofBasic sitterC], o, true, false, false, false, none, none,
    false, false, false⟩

/-- (A): `misty` (30 HP) Active, `victim` Benched. -/
def a0 : GameState := stJ (side (InPlay.ofBasic (mistyC 30)) [InPlay.ofBasic victimC])

/-- (B): `victim` Active, `watcher` (mandatory) and `misty` Benched. -/
def b0 : GameState :=
  stJ (side (InPlay.ofBasic victimC) [InPlay.ofBasic (watcherC false), InPlay.ofBasic (mistyC 30)])

theorem a0_wellFormed : WellFormed a0 := by
  refine ⟨fun _ => ⟨by simp [a0, stJ, side], by simp [a0, stJ, side]⟩, ?_, ?_⟩ <;> intro p hp <;>
    simp [a0, stJ, side] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem a0_settled : Settled a0 := (GameState.settled_iff _).2 (by decide)

theorem b0_wellFormed : WellFormed b0 := by
  refine ⟨fun _ => ⟨by simp [b0, stJ, side], by simp [b0, stJ, side]⟩, ?_, ?_⟩ <;> intro p hp <;>
    simp [b0, stJ, side] at hp <;> rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem b0_settled : Settled b0 := (GameState.settled_iff _).2 (by decide)

/-- Every move from a start `stJ o` that makes the turn's attack is `jet`. -/
theorem attack_inv {o : PlayerState} {g₁ : GameState} (hm : Move (stJ o) g₁)
    (ha : g₁.attacked = true) :
    ∃ g' l g'', Run jet.script (stJ o) g' ∧ HitTrig jet (stJ o) g' l ∧ Fire .damaged l g' g'' ∧
      g₁ = g''.afterAttack jet.lockSet jet.gx := by
  cases hm with
  | playBasic hh => simp [stJ, side] at hh
  | trigger _ hp => simp [stJ] at hp
  | attach => simp [stJ] at ha
  | evolve hh => simp [stJ, side] at hh
  | attachBench hh => simp [stJ, side] at hh
  | evolveBench hh => simp [stJ, side] at hh
  | retreat => simp [stJ, GameState.noteBenched] at ha
  | item hh => simp [stJ, side] at hh
  | supporter hh => simp [stJ, side] at hh
  | stadium hh => simp [stJ, side] at hh
  | tool hh => simp [stJ, side] at hh
  | toolBench hh => simp [stJ, side] at hh
  | stadiumUse hs => simp [stJ] at hs
  | ability hu hm' =>
      cases hu with
      | active ha' =>
          simp only [stJ, side, Option.some.injEq] at ha'; subst ha'
          simp [InPlay.abilities, InPlay.ofBasic, jetterC] at hm'
      | bench hb' =>
          obtain ⟨rfl, rfl, rfl⟩ := one_split hb'
          simp [InPlay.abilities, InPlay.ofBasic, sitterC] at hm'
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [stJ, side] at hh
  | @attack g' a atk ha' hm' _ _ _ _ _ _ hr _ _ _ l g'' hd ht =>
      simp only [stJ, side, Option.some.injEq] at ha'; subst ha'
      have e : atk = jet := by simpa [InPlay.attacks, InPlay.ofBasic, jetterC] using hm'
      subst e
      exact ⟨g', l, g'', hr, hd, ht, rfl⟩
  | attackConfused ha' _ _ hs =>
      simp only [stJ, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.ofBasic] at hs
  | knockOuts h _ ht =>
      rw [ht.zoneOnly.attacked, h.sameTurn.2.2.1] at ha
      simp [stJ] at ha
  | endTurn => simp at ha
  | startTurn hbt => simp [stJ] at hbt
  | deckOut hbt => simp [stJ] at hbt

theorem two_split {α : Type} {x y q : α} {b₁ b₂ : List α} (h : [x, y] = b₁ ++ q :: b₂) :
    (b₁ = [] ∧ q = x ∧ b₂ = [y]) ∨ (b₁ = [x] ∧ q = y ∧ b₂ = []) := by
  cases b₁ with
  | nil =>
      simp only [List.nil_append, List.cons.injEq] at h
      exact .inl ⟨rfl, h.1.symm, h.2.symm⟩
  | cons c l =>
      cases l with
      | nil =>
          simp only [List.cons_append, List.nil_append, List.cons.injEq] at h
          exact .inr ⟨by rw [h.1], h.2.1.symm, h.2.2.symm⟩
      | cons d l => cases l <;> simp at h

/-- **(A) The holder in the Active Spot at the event fires, though the attack gusts it to the
Bench.** From `a0`, every play that attacks (Interjet: 10 damage, switch the attacker, gust) and then
makes a move ends with the mover's new Active Pokémon Confused, and `misty` on the Bench. Before
milestone MV7b the trigger was read after the gust and nothing fired (the review's
`gust_drops_holder`). -/
theorem gust_drops_holder : ∀ g₁ g₂, Move a0 g₁ → g₁.attacked = true → Move g₁ g₂ →
    g₂.cur.active.map InPlay.rot = some .confused ∧ g₂.opp.bench.map InPlay.top = [mistyC 30] := by
  intro g₁ g₂ h1 ha h2
  obtain ⟨g', l, g'', hr, hd, ht, rfl⟩ := attack_inv h1 ha
  change Run (.seq (.damage (.const 10)) (.seq (.switch .own) (.switch .opp))) a0 g' at hr
  cases hr with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | seq hA hB =>
  cases hA with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | damage hv h =>
  cases hv
  simp only [a0, stJ, side, Option.some.injEq] at h; subst h
  cases hB with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | seq hB₁ hB₂ =>
  cases hB₁ with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | switchNone _ hb => simp [GameState.side, a0, stJ, side] at hb
  | switch _ ha' hb =>
  obtain ⟨rfl, rfl, rfl⟩ := one_split hb
  simp only [GameState.side, a0, stJ, side, Option.some.injEq] at ha'
  subst ha'
  cases hB₂ with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | switchNone _ hb => simp [GameState.side, GameState.updSide, Whose.noteBenched,
      GameState.noteBenched, a0, stJ, side] at hb
  | switch _ ha' hb =>
  obtain ⟨rfl, rfl, rfl⟩ := one_split hb
  simp only [GameState.side, GameState.updSide, Whose.noteBenched, GameState.noteBenched, a0, stJ,
    side, Option.map_some, Option.some.injEq] at ha'
  subst ha'
  obtain rfl := hd.nil_of rfl
  cases ht
  rcases h2.batch_of_not_settled (fun h => absurd h.2.2.2 (by decide)) with ⟨_, _, hb, -⟩ | ⟨-, -, l, hl, ht⟩
  · rcases hb.not_ready with h | h
    · exact absurd h (by decide)
    · exact absurd ⟨rfl, rfl⟩ h
  rw [List.perm_singleton.1 (show l.Perm [prose] from hl)] at ht
  cases ht with
  | decline ho => cases ho
  | run _ hr ht =>
  cases ht.nil_eq
  cases hr with
  | touchActive he => simp [Effect.touch, Ability.script, AbEff.compile, prose] at he
  | touchBench he => simp [Effect.touch, Ability.script, AbEff.compile, prose] at he
  | zone hw => simp [Effect.zSide, Ability.script, AbEff.compile, prose] at hw
  | inflict _ h =>
  cases h
  exact ⟨rfl, rfl⟩

/-- (A) as a play: the attack, then the trigger; the mover's new Active Pokémon Confused, `misty`
on the Bench, the state `Settled`. -/
theorem gust_drops_runs :
    ∃ g₁ g₂, Move a0 g₁ ∧ g₁.pend = true ∧ Move g₁ g₂ ∧ Settled g₂ ∧
      g₂.cur.active.map InPlay.rot = some .confused ∧
      g₂.opp.bench.map InPlay.top = [mistyC 30] := by
  have hr : Run jet.script a0 _ :=
    .seq (.damage (.const 10 _) rfl)
      (.seq (.switch (b₁ := []) (b₂ := []) .own rfl rfl) (.switch (b₁ := []) (b₂ := []) .opp rfl rfl))
  exact ⟨_, _, .attack (atk := jet) rfl (.head _) (.nil _) rfl rfl rfl rfl a0_settled
      hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl, rfl,
    .trigger (l := [prose]) ⟨rfl, rfl⟩ rfl (.refl _) (.run rfl (.inflict .confused rfl) (.nil _)),
    (GameState.settled_iff _).2 (by decide), rfl, rfl⟩

/-- **(B) A Benched holder gusted in does not fire.** From `b0`, no play that attacks and then
makes a move Confuses the mover's Active Pokémon, whichever Benched Pokémon the attack gusts in:
`misty` was on the Bench at the event, where its trigger does not work. Before milestone MV7b the
play that gusts `misty` in Confused it (the review's `gust_adds_holder`). -/
theorem gust_adds_holder : ∀ g₁ g₂, Move b0 g₁ → g₁.attacked = true → Move g₁ g₂ →
    g₂.cur.active.map InPlay.rot ≠ some .confused := by
  intro g₁ g₂ h1 ha h2
  obtain ⟨g', l, g'', hr, hd, ht, rfl⟩ := attack_inv h1 ha
  change Run (.seq (.damage (.const 10)) (.seq (.switch .own) (.switch .opp))) b0 g' at hr
  cases hr with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | seq hA hB =>
  cases hA with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | damage hv h =>
  cases hv
  simp only [b0, stJ, side, Option.some.injEq] at h; subst h
  cases hB with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | seq hB₁ hB₂ =>
  cases hB₁ with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | switchNone _ hb => simp [GameState.side, b0, stJ, side] at hb
  | switch _ ha' hb =>
  obtain ⟨rfl, rfl, rfl⟩ := one_split hb
  simp only [GameState.side, b0, stJ, side, Option.some.injEq] at ha'
  subst ha'
  cases hB₂ with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | switchNone _ hb => simp [GameState.side, GameState.updSide, Whose.noteBenched,
      GameState.noteBenched, b0, stJ, side] at hb
  | switch _ ha' hb =>
  simp only [GameState.side, GameState.updSide, Whose.noteBenched, GameState.noteBenched, b0, stJ,
    side, Option.map_some, Option.some.injEq] at ha'
  subst ha'
  simp only [GameState.side, GameState.updSide, Whose.noteBenched, GameState.noteBenched, b0, stJ,
    side, List.map_cons, List.map_nil] at hb
  rcases two_split hb with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ <;>
  · obtain rfl := hd.nil_of rfl
    cases ht
    rcases h2.batch_of_not_settled (fun h => absurd h.2.2.2 (by decide)) with
      ⟨_, _, hb, -⟩ | ⟨-, -, l, hl, ht⟩
    · rcases hb.not_ready with h | h
      · exact absurd h (by decide)
      · exact absurd ⟨rfl, rfl⟩ h
    rw [List.perm_singleton.1 (show l.Perm [surge false] from hl)] at ht
    cases ht with
    | decline ho => cases ho
    | run _ hr ht =>
    cases ht.nil_eq
    cases hr with
    | touchActive he => simp [Effect.touch, Ability.script, AbEff.compile, surge] at he
    | touchBench he => simp [Effect.touch, Ability.script, AbEff.compile, surge] at he
    | zone hw => simp [Effect.zSide, Ability.script, AbEff.compile, surge] at hw
    | seq h₁ h₂ =>
    cases h₁ with
    | touchActive he => simp [Effect.touch] at he
    | touchBench he => simp [Effect.touch] at he
    | zone hw => simp [Effect.zSide] at hw
    | inflict _ h =>
    cases h
    cases h₂ with
    | drawEmpty h => cases h
    | touchActive he => simp [Effect.touch] at he
    | touchBench he => simp [Effect.touch] at he
    | zone hw => simp [Effect.zSide] at hw
    | draw h =>
    cases h
    intro h
    cases h

/-- (B) as a play: the attack gusts `misty` in, then the trigger: `watcher` fires (its mark was set
on the Bench), `misty` does not; the mover's Active Pokémon Burned and not Confused. -/
theorem gust_adds_runs :
    ∃ g₁ g₂, Move b0 g₁ ∧ Move g₁ g₂ ∧ g₂.opp.active.map InPlay.top = some (mistyC 30) ∧
      g₂.cur.active.map InPlay.rot = some .none ∧ g₂.cur.active.map InPlay.burned = some true := by
  have hr : Run jet.script b0 _ :=
    .seq (.damage (.const 10 _) rfl)
      (.seq (.switch (b₁ := []) (b₂ := []) .own rfl rfl)
        (.switch (b₁ := [(InPlay.ofBasic (watcherC false)).noteOwe .bench]) (b₂ := []) .opp rfl rfl))
  exact ⟨_, _, .attack (atk := jet) rfl (.head _) (.nil _) rfl rfl rfl rfl b0_settled
      hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl,
    .trigger (l := [surge false]) ⟨rfl, rfl⟩ rfl (.refl _)
      (.run rfl (.seq (.inflict .burned rfl) (.draw rfl)) (.nil _)),
    rfl, rfl, rfl⟩

/-- **The reviewer's probe fails**: its two statements, for the plays that begin with the attack,
are false. -/
theorem gust_probe_fails :
    (¬ ∃ g₁ g₂, Move a0 g₁ ∧ g₁.attacked = true ∧ Move g₁ g₂ ∧
        g₂.cur.active.map InPlay.rot = some .none) ∧
      ¬ ∃ g₁ g₂, Move b0 g₁ ∧ g₁.attacked = true ∧ Move g₁ g₂ ∧
        g₂.cur.active.map InPlay.rot = some .confused :=
  by
  refine ⟨fun h => ?_, fun h => ?_⟩
  · obtain ⟨_, _, h1, ha, h2, hc⟩ := h
    rw [(gust_drops_holder _ _ h1 ha h2).1] at hc
    cases hc
  · obtain ⟨_, _, h1, ha, h2, hc⟩ := h
    exact gust_adds_holder _ _ h1 ha h2 hc

end Pokemon.Gust
