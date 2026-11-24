import Pokemon.Checkup

/-!
# Self-Knock-Out Abilities with the existing language (milestone MV7b, survey S20 §a "other")

"Once during your turn, you may put 5 damage counters on 1 of your opponent's Pokémon. If you use
this Ability, this Pokémon is Knocked Out." (Dusclops sv6pt5-19; Dusknoir sv6pt5-20 with 13; Magneton
svp-153 has the same rider). These are not triggers: an activated Ability whose effect ends by
Knocking Out its own Pokémon. The model has no Knock-Out primitive, but it needs none: damage
counters on "this Pokémon" (`SelfOp.counters`, `selfDamage` in the Active Spot) at or above its
derived HP make it a pending Knock Out, which the batch Knock Out step inside the Ability's resolution
(`Resolve`, after the step) takes at once, with the Prize card and the promotion. A constant above
every derived HP of the game (`hpBound`) does it; the witness uses 9999 counters.

How far this is the printed card: the Knock Out is the batch step's, so its Prize cards, outcome and
promotion are exactly those of any Knock Out; it is not "by damage from an attack", so no
`koByAttack` trigger fires (as printed). Differences: the Pokémon is Knocked Out by damage counters,
which a card that prevents damage counters being placed on it would stop (no such card is modelled),
and the HP bound must be a constant above every derived HP (the importer must write one, e.g.
`hpBound` of the card pool). "This Pokémon" in the Active Spot is exact (`selfDamage`); on the Bench
`SelfOp.counters` puts the counters on one Benched Pokémon chosen at resolution, which includes this
one: a superset (another Benched Pokémon could be Knocked Out instead), so the importer should
import the Bench form only with a caveat. "1 of your opponent's Pokémon" is
`choice (counters 5) (benchCounters .opp 5)`, exact.

* `self_ko`: from the well-formed, `Settled` start `d0`, the Ability puts 5 counters on the
  opponent's Active Pokémon and Knocks its user Out inside the same move: the user is in its
  owner's discard pile, the Benched `sitter` is promoted, and the opponent has taken a Prize card.
-/

namespace Pokemon.SelfKO
open Pokemon.Benched Pokemon.Promoted Pokemon.CheckupW

/-- Dusclops's Ability (sv6pt5-19), with "this Pokémon is Knocked Out" as 9999 counters on it. -/
def cursed : Ability :=
  ⟨"Cursed", .once, none, none,
    .seq (.fx (.choice (.counters 5) (.benchCounters .opp 5))) (.self (.counters 9999))⟩

def duskC : PokemonCard :=
  ⟨"Dusk", .basic, none, 10, .psychic, [], 1, none, none, .none, false, [cursed]⟩

/-- The start: `dusk` Active and `sitter` Benched for the player to move; `big` (30 HP) Active for
the opponent. Two Prize cards each. -/
def d0 : GameState :=
  ⟨side (InPlay.ofBasic duskC) [InPlay.ofBasic sitterC], side (InPlay.ofBasic bigC) [], true, false,
    false, false, none, none, false, false, false⟩

theorem d0_wellFormed : WellFormed d0 := by
  refine ⟨fun _ => ⟨by simp [d0, side], by simp [d0, side]⟩, fun p hp => ?_, fun _ hp => by
    simp [d0, side] at hp⟩
  simp only [d0, side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem d0_settled : Settled d0 := (GameState.settled_iff _).2 (by decide)

/-- **A self-Knock-Out Ability, with the existing language**: one move uses it; the opponent's
Active Pokémon has 5 damage counters, the user is Knocked Out (in the discard pile), `sitter` is
promoted, and the opponent has taken one of their two Prize cards. -/
theorem self_ko :
    ∃ g', Move d0 g' ∧ g'.opp.active.map InPlay.damage = some 5 ∧
      Card.pokemon duskC ∈ g'.cur.discard ∧ g'.cur.active.map InPlay.top = some sitterC ∧
      g'.opp.prizes.length = 1 ∧ g'.winner = none ∧ Settled g' := by
  refine ⟨_, .ability (ab := cursed) (.active rfl) (.head _) rfl rfl (fun _ => rfl) trivial rfl
    d0_settled rfl
    (.seq (.choiceL (.prim rfl rfl (.counters 5 rfl)
        (.done (.inl ((GameState.settled_iff _).2 (by decide))))))
      (.prim rfl rfl (.selfDamage 9999 rfl)
        (.step rfl (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide)) (by decide)
            (.pick (b₁ := []) (b₂ := [])) .keep)
          (.done (.inl ((GameState.settled_iff _).2 (by decide)))))))
    rfl rfl, rfl, by decide, rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

end Pokemon.SelfKO
