import Pokemon.Trainer

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
  trigger is pending, and the owner's hand is unchanged.
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
    true, KOHist.empty⟩

/-- The start: `runner` Active and `sitter` Benched, Switch and Nest in hand, a `runner` in the deck;
the opponent has `watcher` Active and one card in the deck. -/
def s0 (hand : List Card) (opt : Bool) : GameState :=
  ⟨pl hand [.pokemon runnerC] (InPlay.ofBasic runnerC) [InPlay.ofBasic sitterC],
    pl [] [.energy .grass] (InPlay.ofBasic (watcherC opt)) [], true, false, false, false, none, none,
    false, false, false⟩

theorem s0_wellFormed (hand : List Card) (opt : Bool) : WellFormed (s0 hand opt) := by
  refine ⟨fun _ => ⟨by simp [s0, pl], by simp [s0, pl]⟩, ?_, ?_⟩ <;> intro p hp <;>
    simp [s0, pl] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem s0_settled (hand : List Card) (opt : Bool) : Settled (s0 hand opt) := by
  cases opt <;>
  exact Trainer.settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by simp only [s0, pl, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by cases hp)

/-- The state after the retreat (`sitter` moved up, `runner` Benched), with the event raised. -/
def s1 (opt : Bool) : GameState :=
  ({ s0 [nestCard] opt with cur := { (s0 [nestCard] opt).cur with
      active := some (InPlay.ofBasic sitterC).moveUp,
      bench := [] ++ { InPlay.ofBasic runnerC with
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
  refine ⟨_, .trigger (l := [surge opt]) (retreat_raises opt).2.2.1 (retreat_raises opt).2.1
    (by cases opt <;> exact .refl _)
    (.run (by cases opt <;> rfl) (.seq (.inflict .burned rfl) (.draw rfl)) (.nil _)), rfl, rfl, ?_⟩
  cases opt <;> exact (GameState.settled_iff _).2 (by decide)

/-- **The mandatory trigger cannot be skipped**: every move after the retreat Burns the new Active
Pokémon and gives the owner the card. -/
theorem retreat_forced :
    ∀ g₂, Move (s1 false) g₂ → g₂.cur.active = some burnt ∧ g₂.opp.hand = [.energy .grass] := by
  intro g₂ hm
  rcases hm.batch_of_not_settled (retreat_raises false).2.2.2 with ⟨g₁, l, hb, -⟩ | ⟨-, -, l, hl, ht⟩
  · exact absurd (retreat_raises false).2.2.1 hb.not_calm
  · have e : (s1 false).benchedTrigs = [surge false] := rfl
    rw [e] at hl
    rw [List.perm_singleton.1 hl] at ht
    cases ht with
    | decline ho => cases ho
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
  ⟨_, .trigger (l := [surge true]) (retreat_raises true).2.2.1 (retreat_raises true).2.1 (.refl _)
    (.decline rfl (.nil _)), rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

/-- **A Switch fires the trigger inside the Item's resolution** (`Resolve.trigger`). -/
theorem switch_fires (opt : Bool) :
    ∃ g', Move (s0 [switchCard] opt) g' ∧ g'.cur.active = some burnt ∧
      g'.opp.hand = [.energy .grass] ∧ Settled g' := by
  refine ⟨_, .item (l₁ := []) (l₂ := []) rfl rfl (s0_settled _ opt)
    (.prim rfl rfl (.switch (b₁ := []) .own rfl rfl)
      (.trigger (l := [surge opt]) rfl (by cases opt <;> exact (GameState.calm_iff _).2 (by decide))
        (by cases opt <;> rfl) (by cases opt <;> exact .refl _)
        (.run (by cases opt <;> rfl) (.seq (.inflict .burned rfl) (.draw rfl)) (.nil _))
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
  refine ⟨_, _, .trigger (l := [surge false]) (retreat_raises false).2.2.1 (retreat_raises false).2.1
      (.refl _) (.run rfl (.seq (.inflict .burned rfl) (.draw rfl)) (.nil _)),
    .item (l₁ := []) (l₂ := []) rfl rfl ((GameState.settled_iff _).2 (by decide))
      (.prim rfl rfl (.zone rfl (.putBench (.take rfl .nil) rfl (by decide) (by decide)))
        (.done (.inl ((GameState.settled_iff _).2 (by decide))))) rfl rfl rfl rfl,
    rfl, rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

end Pokemon.Benched
