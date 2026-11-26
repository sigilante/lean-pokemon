import Pokemon.Benched

/-!
# A trigger raised by an attack resolves before the Knock Out check (milestone MV7)

The review of milestone MV7 stage 2 found that a trigger raised inside an attack (an attack that
switches its own user, "Switch this Pokémon with 1 of your Benched Pokémon") resolved after the
attack's Knock Out check, so the triggers that fired were those of the Pokémon in play after the
check: a Mismagius-like Pokémon ("As long as this Pokémon is in the Active Spot, whenever your
opponent's Active Pokémon moves to the Bench during their turn, their new Active Pokémon is now
Confused", me2-36) that was Benched when the attacker moved, and was promoted by the check, fired;
one in the Active Spot when the attacker moved, Knocked Out by the same attack, did not. The repair:
a pending trigger resolves before the batch Knock Out step (`KOBatch` needs no trigger ready,
`GameState.pend = false` or an empty Active Spot), so after an attack the next move is the
trigger's resolution (`Move.trigger`), on the Pokémon in play as the attack left them.

From the well-formed, `Settled` start `g0` of the review (the mover has `turner`, with U-turn,
Active and `sitter` Benched; the opponent has a 10-HP `victim` Active, the Magcargo-like `watcher`
and the Mismagius-like `misty` Benched):
* `promoted_quiet`, `promoted_probe_fails`: every play of three moves that begins with the attack
  (U-turn, the trigger, the Knock Out check) leaves the mover's Active Pokémon not Confused; the
  review's sequence (attack, check, trigger) no longer elaborates;
* `promoted_runs`: the play that exists: U-turn, the trigger (`watcher` fires: Burned), the check
  (`misty` promoted), the mover's Active Pokémon Burned and not Confused.

From the start `h0 hp` (`misty`, `hp` HP, Active; `victim` Benched):
* `held_fires`: with 10 HP, so that U-turn Knocks `misty` Out, every resolution after the attack
  Confuses the new Active Pokémon: the holder was in the Active Spot when the attacker moved;
* `held_fires_ko`: the play continues with the check, which Knocks `misty` Out and promotes
  `victim`; the Confusion stays;
* `switch_attack_fires`: with 30 HP (no Knock Out), U-turn then the trigger: the new Active Pokémon
  Confused, the state `Settled`.
-/

namespace Pokemon.Promoted
open Pokemon.Benched

/-- Mismagius ex's Ability (me2-36): mandatory, only in the Active Spot. -/
def prose : Ability := ⟨"Prose", .triggered .oppBenched false, some .active, none, .fx (.inflict .confused)⟩
/-- A Mismagius-like Basic Pokémon with `hp` HP. -/
def mistyC (hp : Nat) : PokemonCard :=
  ⟨"Misty", .basic, none, hp, .psychic, [], 1, none, none, .none, false, [prose]⟩
/-- A 10-HP Basic Pokémon with no Ability. -/
def victimC : PokemonCard := ⟨"Victim", .basic, none, 10, .grass, [], 0, none, none, .none, false, []⟩
/-- "10 damage. Switch this Pokémon with 1 of your Benched Pokémon." -/
def uturn : Attack := ⟨"U-turn", [], 10, .switch .own, false, .none⟩
/-- A Basic Pokémon with U-turn and no Retreat Cost. -/
def turnerC : PokemonCard := ⟨"Turner", .basic, none, 10, .grass, [uturn], 0, none, none, .none, false, []⟩

/-- A side with `a` Active and `b` Benched, one card in the deck and two Prize cards. -/
def side (a : InPlay) (b : List InPlay) : PlayerState :=
  ⟨[.energy .grass], [], [], [.energy .grass, .energy .grass], [], some a, b, false, false, false,
    false, false, Store.empty, true, KOHist.empty, none⟩

/-- The mover has `turner` Active and `sitter` Benched; the opponent's side is `o`. -/
def st (o : PlayerState) : GameState :=
  ⟨side (InPlay.ofBasic turnerC) [InPlay.ofBasic sitterC], o, true, false, false, false, none, none,
    false, false, false⟩

/-- The review's start: `victim` Active, `watcher` and `misty` Benched. -/
def g0 : GameState :=
  st (side (InPlay.ofBasic victimC) [InPlay.ofBasic (watcherC false), InPlay.ofBasic (mistyC 10)])

theorem g0_wellFormed : WellFormed g0 := by
  refine ⟨fun _ => ⟨by simp [g0, st, side], by simp [g0, st, side]⟩, ?_, ?_, .of_b rfl⟩ <;> intro p hp <;>
    simp [g0, st, side] at hp <;> rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem g0_settled : Settled g0 := (GameState.settled_iff _).2 (by decide)

/-- Every move from a start `st o` that makes the turn's attack is U-turn. -/
theorem attack_inv {o : PlayerState} {g₁ : GameState} (hm : Move (st o) g₁) (ha : g₁.attacked = true)
    (hsh : (st o).shield = false) :
    ∃ g' l g'', Run uturn.script (st o) g' ∧ HitTrig uturn (st o) g' l ∧ Fire .damaged l g' g'' ∧
      g₁ = g''.afterAttack uturn.lockSet uturn.gx := by
  cases hm with
  | playBasic hh => simp [st, side] at hh
  | trigger _ hp => simp [st] at hp
  | attach => simp [st] at ha
  | evolve hh => simp [st, side] at hh
  | attachBench hh => simp [st, side] at hh
  | evolveBench hh => simp [st, side] at hh
  | retreat => simp [st, GameState.noteBenched] at ha
  | item hh => simp [st, side] at hh
  | supporter hh => simp [st, side] at hh
  | stadium hh => simp [st, side] at hh
  | tool hh => simp [st, side] at hh
  | toolBench hh => simp [st, side] at hh
  | stadiumUse hs => simp [st] at hs
  | ability hu hm' =>
      cases hu with
      | active ha' =>
          simp only [st, side, Option.some.injEq] at ha'; subst ha'
          simp [InPlay.abilities, InPlay.ofBasic, turnerC] at hm'
      | bench hb' =>
          obtain ⟨rfl, rfl, rfl⟩ := one_split hb'
          simp [InPlay.abilities, InPlay.ofBasic, sitterC] at hm'
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [st, side] at hh
  | @attack g' a atk ha' hm' _ _ _ _ _ _ hr _ _ _ l g'' hd ht =>
      simp only [st, side, Option.some.injEq] at ha'; subst ha'
      have e : atk = uturn := by simpa [InPlay.attacks, InPlay.ofBasic, turnerC] using hm'
      subst e
      rw [hsh, Attack.against_false] at hr hd
      exact ⟨g', l, g'', hr, hd, ht, rfl⟩
  | attackConfused ha' _ _ hs =>
      simp only [st, side, Option.some.injEq] at ha'; subst ha'
      simp [InPlay.ofBasic] at hs
  | knockOuts h _ ht =>
      rw [ht.zoneOnly.attacked, h.sameTurn.2.2.1] at ha
      simp [st] at ha
  | endTurn => simp at ha
  | startTurn hbt => simp [st] at hbt
  | deckOut hbt => simp [st] at hbt


theorem promoted_quiet : ∀ g₁ g₂ g₃, Move g0 g₁ → g₁.attacked = true → Move g₁ g₂ → Move g₂ g₃ →
    g₃.cur.active.map InPlay.rot ≠ some .confused := by
  intro g₁ g₂ g₃ h1 ha h2 h3
  obtain ⟨g', l, g'', hr, hd, ht, rfl⟩ := attack_inv h1 ha (by decide)
  change Run (.seq (.damage (.const 10)) (.switch .own)) g0 g' at hr
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
  simp only [g0, st, side, Option.some.injEq] at h; subst h
  cases hB with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | switchNone _ hb => simp [GameState.side, g0, st, side] at hb
  | switch _ ha' hb =>
  obtain ⟨rfl, rfl, rfl⟩ := one_split hb
  simp only [GameState.side, g0, st, side, Option.some.injEq] at ha'
  subst ha'
  obtain rfl := hd.nil_of rfl
  cases ht
  rcases h2.batch_of_not_settled (fun h => absurd h.2.2.2 (by decide)) with ⟨_, _, hb, -⟩ | ⟨-, -, ho⟩
  · rcases hb.not_ready with h | h
    · exact absurd h (by decide)
    · exact absurd ⟨rfl, rfl⟩ h
  obtain ⟨l, hl, ht⟩ := ho.opp_inv rfl rfl
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
  rcases h3.batch_of_not_settled (fun h => absurd ((GameState.settled_iff _).1 h) (by decide))
    with ⟨g₄, l', hb, hl', ht'⟩ | ⟨-, hp, -⟩
  · rw [Move.eq_of_batchTrigs_nil hl' ht' (by unfold GameState.batchTrigs; split <;> first | rfl | decide)]
    cases hb with
    | won _ hw => exact absurd rfl hw
    | go _ _ hc _ =>
        cases hc
        rw [GameState.afterBatch_active_map (fun p => InPlay.noteMove_rot _ _ p)]
        simp only [Option.map_some]
        intro h
        cases h
  · exact absurd hp (by decide)


/-- The reviewer's sequence now resolves the trigger before the Knock Out check: U-turn, the
trigger (Magcargo-like `watcher` Benched fires; `misty`, Benched, does not), then the check, which
promotes `misty`. The mover's new Active Pokémon is Burned, not Confused. -/
theorem promoted_runs :
    ∃ g₁ g₂ g₃, Move g0 g₁ ∧ g₁.attacked = true ∧ Move g₁ g₂ ∧ Move g₂ g₃ ∧
      g₃.opp.active.map InPlay.top = some (mistyC 10) ∧
      g₃.cur.active.map InPlay.rot = some .none ∧ g₃.cur.active.map InPlay.burned = some true := by
  have hr : Run uturn.script g0 _ :=
    .seq (.damage (.const 10 _) rfl) (.switch (b₁ := []) (b₂ := []) .own rfl rfl)
  refine ⟨_, _, _, Move.attackOpen (atk := uturn) rfl (.head _) (.nil _) rfl rfl rfl rfl g0_settled
      hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl, rfl,
    .trigger ⟨rfl, rfl⟩ rfl (.of_opp (l := [surge false]) rfl rfl (.refl _) (.run rfl (.seq (.inflict .burned rfl) (.draw rfl)) (.nil _))),
    .knockOuts (l := []) (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide)) (by decide) .keep
      (.pick (b₁ := [InPlay.ofBasic (watcherC false)]) (b₂ := []))) .nil (.nil _),
    rfl, rfl, rfl⟩

/-- **The reviewer's counterexample no longer elaborates**: no play of three moves from `g0`
that begins with the attack leaves the mover's Active Pokémon Confused. -/
theorem promoted_probe_fails :
    ¬ ∃ g₁ g₂ g₃, Move g0 g₁ ∧ g₁.attacked = true ∧ Move g₁ g₂ ∧ Move g₂ g₃ ∧
      g₃.cur.active.map InPlay.rot = some .confused :=
  fun ⟨_, _, _, h1, ha, h2, h3, hc⟩ => promoted_quiet _ _ _ h1 ha h2 h3 hc

/-- The companion start: the opponent's Mismagius-like `misty` (`hp` HP) is Active, `victim`
Benched. -/
def h0 (hp : Nat) : GameState := st (side (InPlay.ofBasic (mistyC hp)) [InPlay.ofBasic victimC])

theorem h0_settled : Settled (h0 10) := (GameState.settled_iff _).2 (by decide)

/-- **A holder in the Active Spot at the event fires, even when the same attack Knocks it Out.**
U-turn puts `misty` (10 HP) at its HP and switches the attacker out; every resolution of the
trigger, which comes before the Knock Out check, Confuses the new Active Pokémon. -/
theorem held_fires : ∀ g₁ g₂, Move (h0 10) g₁ → g₁.attacked = true → Move g₁ g₂ →
    g₂.cur.active.map InPlay.rot = some .confused := by
  intro g₁ g₂ h1 ha h2
  obtain ⟨g', l, g'', hr, hd, ht, rfl⟩ := attack_inv h1 ha (by decide)
  change Run (.seq (.damage (.const 10)) (.switch .own)) (h0 10) g' at hr
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
  simp only [h0, st, side, Option.some.injEq] at h; subst h
  cases hB with
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw
  | switchNone _ hb => simp [GameState.side, h0, st, side] at hb
  | switch _ ha' hb =>
  obtain ⟨rfl, rfl, rfl⟩ := one_split hb
  simp only [GameState.side, h0, st, side, Option.some.injEq] at ha'
  subst ha'
  obtain rfl := hd.nil_of rfl
  cases ht
  rcases h2.batch_of_not_settled (fun h => absurd h.2.2.2 (by decide)) with ⟨_, _, hb, -⟩ | ⟨-, -, ho⟩
  · rcases hb.not_ready with h | h
    · exact absurd h (by decide)
    · exact absurd ⟨rfl, rfl⟩ h
  obtain ⟨l, hl, ht⟩ := ho.opp_inv rfl rfl
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
  rfl

/-- The companion as a play: U-turn, the trigger (the new Active Pokémon Confused), then the
check, which Knocks `misty` Out and promotes `victim`; the Confusion stays. -/
theorem held_fires_ko :
    ∃ g₁ g₂ g₃, Move (h0 10) g₁ ∧ Move g₁ g₂ ∧ Move g₂ g₃ ∧
      g₃.cur.active.map InPlay.rot = some .confused ∧
      g₃.opp.active.map InPlay.top = some victimC := by
  have hr : Run uturn.script (h0 10) _ :=
    .seq (.damage (.const 10 _) rfl) (.switch (b₁ := []) (b₂ := []) .own rfl rfl)
  refine ⟨_, _, _, Move.attackOpen (atk := uturn) rfl (.head _) (.nil _) rfl rfl rfl rfl h0_settled
      hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl,
    .trigger ⟨rfl, rfl⟩ rfl (.of_opp (l := [prose]) rfl rfl (.refl _) (.run rfl (.inflict .confused rfl) (.nil _))),
    .knockOuts (l := []) (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide)) (by decide) .keep
      (.pick (b₁ := []) (b₂ := []))) .nil (.nil _),
    rfl, rfl⟩

/-- **An attack that switches its own user fires a correctly placed holder** (no Knock Out): with
`misty` at 30 HP, U-turn then the trigger Confuse the new Active Pokémon, and the state is
`Settled`. -/
theorem switch_attack_fires :
    ∃ g₁ g₂, Move (h0 30) g₁ ∧ Move g₁ g₂ ∧ g₂.cur.active.map InPlay.rot = some .confused ∧
      Settled g₂ := by
  have hr : Run uturn.script (h0 30) _ :=
    .seq (.damage (.const 10 _) rfl) (.switch (b₁ := []) (b₂ := []) .own rfl rfl)
  exact ⟨_, _, Move.attackOpen (atk := uturn) rfl (.head _) (.nil _) rfl rfl rfl rfl
      ((GameState.settled_iff _).2 (by decide))
      hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl,
    .trigger ⟨rfl, rfl⟩ rfl (.of_opp (l := [prose]) rfl rfl (.refl _) (.run rfl (.inflict .confused rfl) (.nil _))),
    rfl, (GameState.settled_iff _).2 (by decide)⟩

end Pokemon.Promoted
