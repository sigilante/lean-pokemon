import Pokemon.Rules

/-!
# Turn fidelity (milestone M1)

The rules of `Pokemon/Rules.lean` that make a turn in the model what a turn is in the rulebook,
stated as theorems.

* `Move.after_attack`: an attack ends the turn. Once the player to move has attacked (or
  failed a Confused attempt), every legal move is a Knock Out move (a Knock Out, a promotion, or
  a loss for want of a Pokémon to promote) or `endTurn`, which passes the turn.
* `dealtBy_zero`, `GameState.dealt_zero`: an attack with base damage 0 does no damage, whatever
  the lingering modifiers ("Stop if the base damage is 0").
* `InPlay.inflict_poisoned`: a new Poison replaces the old one, so the Poison strength returns
  to that of a plain Poison.
* First-turn rules are premises of the moves (`Move.attack`, `Move.attackConfused` and
  `Move.supporter` need `firstTurn = false`; `Move.evolve` needs `PlayerState.hadTurn`, which
  `Move.endTurn` sets for the player whose turn ends), as are the once-per-turn limits on
  Energy, Supporters and retreat and the evolution timing (`InPlay.fresh`).
-/

namespace Pokemon

/-- **An attack ends the turn.** From a state of the turn proper in which the player to move
has attacked, every move is a Knock Out move (`KOMove`: the Knock Outs the attack caused, the
promotions, or a loss) or the end of the turn, after which the opponent is to move, between
turns, and has not attacked. No other action (playing a card, attaching Energy, evolving,
retreating, attacking again) is legal. -/
theorem Move.after_attack {g g' : GameState} (hm : Move g g') (ha : g.attacked = true)
    (hb : g.between = false) :
    KOMove g g' ∨ (g'.curIsFirst = !g.curIsFirst ∧ g'.between = true ∧ g'.attacked = false) := by
  cases hm with
  | playBasic _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | attach _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | evolve _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | retreat _ _ _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | item _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | supporter _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | attack _ _ _ _ hn => exact absurd (ha.symm.trans hn) (by decide)
  | attackConfused _ _ _ _ hn => exact absurd (ha.symm.trans hn) (by decide)
  | knockOut h₁ h₂ h₃ => exact .inl (.knockOut h₁ h₂ h₃)
  | promote h₁ h₂ => exact .inl (.promote h₁ h₂)
  | noPokemon h₁ h₂ => exact .inl (.noPokemon h₁ h₂)
  | knockOutOwn h₁ h₂ h₃ => exact .inl (.knockOutOwn h₁ h₂ h₃)
  | promoteOwn h₁ h₂ => exact .inl (.promoteOwn h₁ h₂)
  | noPokemonOwn h₁ h₂ => exact .inl (.noPokemonOwn h₁ h₂)
  | endTurn => exact .inr ⟨rfl, rfl, rfl⟩
  | startTurn hbt => exact absurd (hbt.symm.trans hb) (by decide)
  | deckOut hbt => exact absurd (hbt.symm.trans hb) (by decide)

/-- **Base damage 0 does no damage**, whatever the bonuses, reductions and prevention, and
whatever the Weakness and Resistance. -/
theorem dealtBy_zero (weak : Bool) (resist : Nat) (own opp : Store) :
    dealtBy 0 weak resist own opp = 0 := rfl

@[inherit_doc dealtBy_zero]
theorem GameState.dealt_zero (g : GameState) : g.dealt 0 = 0 := rfl

/-- **A new Poison replaces the old one**: poisoning a Pokémon, Poisoned or not, leaves it
Poisoned with Poison strength 0 (one damage counter at each Checkup). -/
theorem InPlay.inflict_poisoned (p : InPlay) :
    (p.inflict .poisoned).poisoned = true ∧ (p.inflict .poisoned).poisonUp = 0 :=
  ⟨rfl, rfl⟩

end Pokemon
