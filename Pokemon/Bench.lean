import Pokemon.Trainer

/-!
# The Bench (milestone M3)

Witnesses for the rules milestone M3 added: Knock Outs give the Prize cards of the Knocked Out
Pokémon's rule box, and a player who takes their last Prize card in the middle of a multi-Prize
Knock Out wins.

* `twoPrizes_reachable`: an Item Knocks Out the opponent's Pokémon ex (2 Prize cards) in
  mid-effect; the player takes two Prize cards and the game goes on.
* `lastPrize_reachable`: the same Knock Out with one Prize card left: the player takes it, has
  taken their last Prize card, and wins.
-/

namespace Pokemon.Bench

open Trainer

/-- A Basic Pokémon ex with 50 HP: its Knock Out gives two Prize cards. -/
def exMon : PokemonCard := ⟨"ExMon", .basic, none, 5, .grass, [], 1, none, none, .ex, false⟩

/-- Put 5 damage counters on the opponent's Active Pokémon. -/
def hit5 : Card := .trainer "Hit5" .item (.counters 5)

/-- The player to move has `prizes` and `hit5` in hand; the opponent has `exMon` Active and a
100-HP Pokémon on the Bench. -/
def exStart (prizes : List Card) : GameState :=
  ⟨side [hit5] prizes (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic exMon) [InPlay.ofBasic big],
    true, false, false, false, none, none⟩

theorem exStart_wellFormed (c : Card) (cs : List Card) : WellFormed (exStart (c :: cs)) := by
  refine ⟨fun _ => ⟨by simp [exStart, Trainer.side], by simp [exStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [exStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact benched_ofBasic (by decide)

theorem exStart_settled (prizes : List Card) : Settled (exStart prizes) :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by simp only [exStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)

/-- **Witness: a Knock Out gives two Prize cards.** From a well-formed, `Settled` start in which
the player to move has three Prize cards, playing `hit5` Knocks Out the opponent's Pokémon ex in
mid-effect: the player takes two Prize cards, the opponent promotes, and nobody has won. -/
theorem twoPrizes_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.winner = none ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.cur.prizes.length + 2 = g₀.cur.prizes.length ∧
        g.cur.hand.length = 2 ∧ Card.pokemon exMon ∈ g.opp.discard ∧ g.winner = none := by
  refine ⟨exStart [.energy .fire, .energy .fire, .energy .fire], exStart_wellFormed _ _,
    exStart_settled _, rfl, ?_⟩
  have hm : Move (exStart [.energy .fire, .energy .fire, .energy .fire]) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Hit5") rfl rfl (exStart_settled _)
      (.prim rfl rfl (.counters 5 rfl)
        (.step rfl (.knockOut rfl (by decide) rfl)
          (.step rfl (.promote (b₁ := []) rfl rfl)
            (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
              (fun p hp => by cases hp))))))) rfl rfl rfl
  exact ⟨_, hm, .step (.refl _) rfl hm, rfl, rfl, .head _, rfl⟩

/-- **Witness: the last Prize card in the middle of a multi-Prize Knock Out wins.** With one
Prize card left, Knocking Out a Pokémon ex (two Prize cards) takes that card, and the player who
took it wins. -/
theorem lastPrize_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.winner = none ∧ g₀.cur.prizes.length = 1 ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.cur.prizes = [] ∧ g.cur.hand.length = 1 ∧
        g.winner = some g₀.curIsFirst := by
  refine ⟨exStart [.energy .fire], exStart_wellFormed _ _, exStart_settled _, rfl, rfl, ?_⟩
  have hm : Move (exStart [.energy .fire]) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Hit5") rfl rfl (exStart_settled _)
      (.prim rfl rfl (.counters 5 rfl)
        (.step rfl (.knockOut rfl (by decide) rfl) (.done (.inr (by decide))))) rfl rfl rfl
  exact ⟨_, hm, .step (.refl _) rfl hm, rfl, rfl, rfl⟩

end Pokemon.Bench
