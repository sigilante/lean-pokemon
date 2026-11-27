import Pokemon.Trainer
import Pokemon.NoTriggers

/-!
# Triggers on "your opponent's Active Pokémon moves to the Bench" (milestone MV7)

Witnesses for `TrigEvent.oppBenched` (survey S20): "Whenever your opponent's Active Pokémon moves
to the Bench during their turn, their new Active Pokémon is now Burned." (Magcargo sv5-29). The test
card `watcher` has that Ability with an observable rider (its owner draws a card), mandatory
(`opt = false`) or optional (`opt = true`).

From the well-formed, `Settled` start `s0`, where the player to move has `runner` Active, `sitter`
Benched, and holds a Switch and a "Nest" Item that Benches a `runner` from the deck:
* `retreat_raises`, `retreat_fires`: a retreat leaves the trigger pending (`GameState.pend`), and
  the next move resolves it: the new Active Pokémon is Burned and the owner has drawn;
* `retreat_forced`: the mandatory trigger cannot be skipped: every move after the retreat Burns the
  new Active Pokémon and gives the owner a card;
* `retreat_declined`: the optional one can be declined;
* `switch_fires`: a Switch (an Item whose effect is `switch .own`) fires it inside the Item's
  resolution (`Resolve.trigger`);
* `copy_quiet`: the identical-copy case of the S18 review: after the retreat and its trigger, the
  Nest Item Benches an identical copy of the old Active Pokémon (the Bench then holds two equal
  `runner`s) with the Active Pokémon unchanged; nothing is raised: the result is `Settled`, so no
  trigger is pending, and the owner's hand is unchanged. `copy_quiet_all`: for every resolution of
  the trigger and every move after it (the Nest Item among them), nothing is pending;
* `retreat_quiet`: from the start `t0`, where no card has such a trigger, the retreat is legal and
  raises nothing, and nothing is pending in any state reached by any play (`Reach.pend_false`).

Attacks that switch their own user: `Pokemon/Promoted.lean`.
-/

namespace Pokemon.Benched

/-- A Basic Pokémon with no Retreat Cost. -/
def runnerC : PokemonCard := ⟨"Runner", .basic, none, 10, .grass, [], 0, none, none, .none, false, []⟩

def sitterC : PokemonCard := ⟨"Sitter", .basic, none, 10, .grass, [], 0, none, none, .none, false, []⟩

/-- Magcargo's Ability with a draw added, so that its firing is seen in the owner's hand. -/
def surge (opt : Bool) : Ability :=
  ⟨"Surge", .triggered .oppBenched opt, none, none, .fx (.seq (.inflict .burned) .draw)⟩

def watcherC (opt : Bool) : PokemonCard :=
  ⟨"Watcher", .basic, none, 10, .fire, [], 1, none, none, .none, false, [surge opt]⟩

def switchCard : Card := .trainer "Switch" .item (.switch .own)

/-- "Search your deck for a Runner and put it onto your Bench." -/
def nestCard : Card := .trainer "Nest" .item (.putBench .own .deck (.named "Runner"))

def pl (hand deck : List Card) (a : InPlay) (b : List InPlay) : PlayerState :=
  ⟨deck, hand, [], [.energy .grass], [], some a, b, false, false, false, false, false, Store.empty,
    true, KOHist.empty, none⟩

/-- The start: `runner` Active and `sitter` Benched, Switch and Nest in hand, a `runner` in the deck;
the opponent has `watcher` Active and one card in the deck. -/
def s0 (hand : List Card) (opt : Bool) : GameState :=
  ⟨pl hand [.pokemon runnerC] (InPlay.ofBasic runnerC) [InPlay.ofBasic sitterC],
    pl [] [.energy .grass] (InPlay.ofBasic (watcherC opt)) [], true, false, false, false, none, none,
    false, false, false⟩

theorem s0_wellFormed (hand : List Card) (opt : Bool) : WellFormed (s0 hand opt) := by
  refine ⟨fun _ => ⟨by simp [s0, pl], by simp [s0, pl]⟩, ?_, ?_, .of_b rfl⟩ <;> intro p hp <;>
    simp [s0, pl] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem s0_settled (hand : List Card) (opt : Bool) : Settled (s0 hand opt) := by
  cases opt <;>
  exact Trainer.settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by simp only [s0, pl, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by cases hp)

/-- The state after the retreat (`sitter` moved up, `runner` Benched), with the event raised. -/
def s1 (opt : Bool) : GameState :=
  ({ s0 [nestCard] opt with cur := { (s0 [nestCard] opt).cur with
      active := some ((InPlay.ofBasic sitterC).moveUp.noteMove .movedUp .active),
      bench := [] ++ InPlay.noteMove .movedDown .bench { InPlay.ofBasic runnerC with
        energy := [], rot := .none, poisoned := false, burned := false, poisonUp := 0,
        lk := {} } :: [],
      discard := [] ++ (s0 [nestCard] opt).cur.discard, retreated := true } } : GameState).noteBenched

theorem retreat_move (opt : Bool) : Move (s0 [nestCard] opt) (s1 opt) :=
  .retreat (b₁ := []) (b₂ := []) rfl rfl rfl .nil rfl rfl rfl (s0_settled _ opt) rfl rfl

/-- **A retreat raises the event**: the trigger is pending after it. -/
theorem retreat_raises (opt : Bool) : Move (s0 [nestCard] opt) (s1 opt) ∧ (s1 opt).pend = true ∧
    Calm (s1 opt) ∧ ¬ Settled (s1 opt) :=
  ⟨retreat_move opt, by cases opt <;> rfl, by cases opt <;> exact (GameState.calm_iff _).2 (by decide),
    fun h => by cases opt <;> exact absurd h.2.2.2 (by decide)⟩

/-- The new Active Pokémon, Burned. -/
def burnt : InPlay := (InPlay.ofBasic sitterC).moveUp.inflict .burned

/-- **The trigger resolves by the next move**: the new Active Pokémon is Burned and the owner drew. -/
theorem retreat_fires (opt : Bool) :
    ∃ g₂, Move (s1 opt) g₂ ∧ g₂.cur.active = some burnt ∧ g₂.opp.hand = [.energy .grass] ∧
      Settled g₂ := by
  refine ⟨_, .trigger (retreat_raises opt).2.2.1.bothActive (retreat_raises opt).2.1
    (.of_opp (l := [surge opt]) (by cases opt <;> rfl) (by cases opt <;> rfl)
      (by cases opt <;> exact .refl _)
      (.run (by cases opt <;> rfl) (.seq (.inflict .burned rfl) (.draw rfl)) (.nil _))), rfl, rfl, ?_⟩
  cases opt <;> exact (GameState.settled_iff _).2 (by decide)

/-- **The mandatory trigger cannot be skipped**: every move after the retreat Burns the new Active
Pokémon and gives the owner the card. -/
theorem retreat_forced :
    ∀ g₂, Move (s1 false) g₂ → g₂.cur.active = some burnt ∧ g₂.opp.hand = [.energy .grass] := by
  intro g₂ hm
  rcases hm.batch_of_not_settled (retreat_raises false).2.2.2 with ⟨g₁, l, hb, -⟩ | ⟨-, -, ho⟩
  · exact absurd (retreat_raises false).2.2.1 hb.not_calm
  · obtain ⟨l, hl, ht⟩ := ho.opp_inv rfl rfl
    have e : (s1 false).owedTrigs = [surge false] := rfl
    rw [e] at hl
    rw [List.perm_singleton.1 hl] at ht
    cases ht with
    | decline ho => cases ho
    | vacant _ ha => nomatch ha
    | run _ hr ht =>
        cases ht.nil_eq
        cases hr with
        | seq h₁ h₂ =>
            cases h₁ with
            | inflict _ h =>
                cases h
                cases h₂ with
                | draw h => cases h; exact ⟨rfl, rfl⟩
                | drawEmpty h => cases h
                | touchActive he => simp [Effect.touch] at he
                | touchBench he => simp [Effect.touch] at he
                | zone hw => simp [Effect.zSide] at hw
            | touchActive he => simp [Effect.touch] at he
            | touchBench he => simp [Effect.touch] at he
            | zone hw => simp [Effect.zSide] at hw
        | touchActive he => simp [Effect.touch, Ability.script, AbEff.compile, surge] at he
        | touchBench he => simp [Effect.touch, Ability.script, AbEff.compile, surge] at he
        | zone hw => simp [Effect.zSide, Ability.script, AbEff.compile, surge] at hw

/-- **The optional trigger can be declined**: the new Active Pokémon is not Burned and the owner
draws nothing. -/
theorem retreat_declined :
    ∃ g₂, Move (s1 true) g₂ ∧ g₂.cur.active = some (InPlay.ofBasic sitterC).moveUp ∧
      g₂.opp.hand = [] ∧ Settled g₂ :=
  ⟨_, .trigger (retreat_raises true).2.2.1.bothActive (retreat_raises true).2.1
    (.of_opp (l := [surge true]) rfl rfl (.refl _) (.decline rfl (.nil _))), rfl, rfl,
    (GameState.settled_iff _).2 (by decide)⟩

/-- **A Switch fires the trigger inside the Item's resolution** (`Resolve.trigger`). -/
theorem switch_fires (opt : Bool) :
    ∃ g', Move (s0 [switchCard] opt) g' ∧ g'.cur.active = some burnt ∧
      g'.opp.hand = [.energy .grass] ∧ Settled g' := by
  refine ⟨_, .item (l₁ := []) (l₂ := []) rfl rfl (s0_settled _ opt)
    (.prim rfl rfl (.switch (b₁ := []) .own rfl rfl)
      (.trigger rfl ⟨rfl, rfl⟩ (by cases opt <;> rfl)
        (.of_opp (l := [surge opt]) (by cases opt <;> rfl) (by cases opt <;> rfl)
          (by cases opt <;> exact .refl _)
          (.run (by cases opt <;> rfl) (.seq (.inflict .burned rfl) (.draw rfl)) (.nil _)))
        (.done (.inl (by cases opt <;> exact (GameState.settled_iff _).2 (by decide))))))
    rfl rfl rfl rfl, ?_, ?_, ?_⟩ <;> cases opt <;> first | rfl | exact (GameState.settled_iff _).2 (by decide)

/-- **The identical-copy case does not fire** (the S18 review's counterexample to the observation
of end states): after the retreat and its trigger, the Nest Item Benches a `runner` from the deck,
identical to the old Active Pokémon on the Bench, with the Active Pokémon unchanged. Nothing is
raised: the result is `Settled` (no trigger pending), and the owner's hand is as it was. -/
theorem copy_quiet :
    ∃ g₂ g₃, Move (s1 false) g₂ ∧ Move g₂ g₃ ∧
      g₃.cur.bench = [InPlay.ofBasic runnerC, InPlay.ofBasic runnerC] ∧
      g₃.cur.active = g₂.cur.active ∧ g₃.opp.hand = g₂.opp.hand ∧ g₂.opp.hand = [.energy .grass] ∧
      Settled g₃ := by
  refine ⟨_, _, .trigger (retreat_raises false).2.2.1.bothActive (retreat_raises false).2.1
      (.of_opp (l := [surge false]) rfl rfl (.refl _)
        (.run rfl (.seq (.inflict .burned rfl) (.draw rfl)) (.nil _))),
    .item (l₁ := []) (l₂ := []) rfl rfl ((GameState.settled_iff _).2 (by decide))
      (.prim rfl rfl (.zone rfl (.putBench (.take rfl .nil) rfl (by decide) (by decide)))
        (.done (.inl ((GameState.settled_iff _).2 (by decide))))) rfl rfl rfl rfl,
    rfl, rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

theorem one_split {α : Type} {x q : α} {b₁ b₂ : List α} (h : [x] = b₁ ++ q :: b₂) :
    b₁ = [] ∧ q = x ∧ b₂ = [] := by
  cases b₁ with
  | nil =>
      simp only [List.nil_append, List.cons.injEq] at h
      exact ⟨rfl, h.1.symm, h.2.symm⟩
  | cons c l => cases l <;> simp at h

/-- The Nest Item's effect raises nothing. -/
theorem nest_pend {X Y : GameState} (h : TRun (.putBench .own .deck (.named "Runner")) X Y)
    (hp : X.pend = false) (hf : X.EvFree .movedUp) : Y.pend = false := by
  cases h with
  | stop => exact hp
  | prim _ _ hr hk =>
      refine hk.pend_false ?_ (hf.of_perm hr.perm)
      cases hr with
      | @zone _ w _ _ _ _ => cases w <;> exact hp
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he

/-- **Benching an identical copy raises nothing, in every continuation**: after the retreat, every
resolution of its trigger, and then every move (the Nest Item among them), leaves no trigger
pending. -/
theorem copy_quiet_all : ∀ g₂ g₃, Move (s1 false) g₂ → Move g₂ g₃ → g₃.pend = false := by
  intro g₂ g₃ hm h3
  rcases hm.batch_of_not_settled (retreat_raises false).2.2.2 with ⟨g₁, l, hb, -⟩ | ⟨-, -, ho⟩
  · exact absurd (retreat_raises false).2.2.1 hb.not_calm
  obtain ⟨l, hl, ht⟩ := ho.opp_inv rfl rfl
  have e : (s1 false).owedTrigs = [surge false] := rfl
  rw [e] at hl
  rw [List.perm_singleton.1 hl] at ht
  cases ht with
  | decline ho => cases ho
  | vacant _ ha => nomatch ha
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
  cases h3 with
  | retreat _ _ hr => exact absurd hr (by decide)
  | item hh _ _ hr =>
      have hh' : [nestCard] = _ ++ _ :: _ := hh
      obtain ⟨rfl, he, rfl⟩ := one_split hh'
      cases he
      exact nest_pend hr rfl (by unfold GameState.EvFree; decide)
  | supporter hh =>
      have hh' : [nestCard] = _ ++ _ :: _ := hh
      obtain ⟨-, he, -⟩ := one_split hh'
      cases he
  | stadiumUse hs => cases hs
  | ability hu hm' =>
      cases hu with
      | active ha' =>
          obtain rfl := Option.some.inj ha'
          cases hm'
      | bench hb' =>
          have hb'' : [_] = _ ++ _ :: _ := hb'
          obtain ⟨-, rfl, -⟩ := one_split hb''
          cases hm'
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      have hh' : [nestCard] = _ ++ _ :: _ := hh
      obtain ⟨-, he, -⟩ := one_split hh'
      cases he
  | attack ha' hm' =>
      obtain rfl := Option.some.inj ha'
      cases hm'
  | knockOuts h => exact absurd ((GameState.calm_iff _).2 (by decide)) h.not_calm
  | trigger _ hp => exact absurd hp (by decide)
  | _ => rfl


/-- The start `s0` with the opponent's `watcher` replaced by `sitter`, which has no Ability: no
card of the game has an `oppBenched` trigger. -/
def t0 : GameState :=
  ⟨pl [nestCard] [.pokemon runnerC] (InPlay.ofBasic runnerC) [InPlay.ofBasic sitterC],
    pl [] [.energy .grass] (InPlay.ofBasic sitterC) [], true, false, false, false, none, none,
    false, false, false⟩

theorem t0_wellFormed : WellFormed t0 := by
  refine ⟨fun _ => ⟨by simp [t0, pl], by simp [t0, pl]⟩, ?_, ?_, .of_b rfl⟩ <;> intro p hp <;>
    simp [t0, pl] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem t0_settled : Settled t0 :=
  Trainer.settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by simp only [t0, pl, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by cases hp)

theorem t0_benchedFree : t0.BenchedFree := by unfold GameState.BenchedFree; decide

theorem t0_moveFree : t0.MoveFree :=
  ⟨t0_benchedFree, by unfold GameState.EvFree; decide, by unfold GameState.EvFree; decide⟩

/-- **With no such trigger, a retreat raises nothing, in every continuation**: from the
well-formed, `Settled` start `t0` the retreat is a legal move to a `Settled` state with nothing
pending, and every state reached by any play from `t0` has nothing pending (`Reach.pend_false`). -/
theorem retreat_quiet :
    (∃ g, Move t0 g ∧ g.cur.active = some (InPlay.ofBasic sitterC).moveUp ∧ g.pend = false ∧
      Settled g) ∧ ∀ g, Reach t0 g → g.pend = false :=
  ⟨⟨_, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl .nil rfl rfl rfl t0_settled rfl rfl, rfl, rfl,
      (GameState.settled_iff _).2 (by decide)⟩,
    fun _ h => h.pend_false t0_moveFree t0_wellFormed.2.2.2 rfl⟩

end Pokemon.Benched
