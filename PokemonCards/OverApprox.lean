import PokemonCards.Standard

/-!
# A recycling probe with two refused Items, over-approximated

Hand-written (not generated). Two Items of today's Standard write a lingering damage modifier and
are refused by the importer, because each modifier is restricted to a type the model's modifiers
cannot name:

* Iron Defender (me1-118): "During your opponent's next turn, all of your Metal Pokémon take 30
  less damage from attacks from your opponent's Pokémon (after applying Weakness and Resistance)."
* Premium Power Pro (me1-124): "During this turn, attacks used by your Fighting Pokémon do 30 more
  damage to your opponent's Active Pokémon (before applying Weakness and Resistance)."

Below, each is written with its type restriction dropped: the modifier applies to all of the
player's Pokémon. That is an over-approximation of the card's *write* (it writes the same amount,
to a wider set of Pokémon), and these terms are not translations of the printed cards; the imported
pool (`Standard.all`) does not contain them.

`recSafe_withOverItems` says clause 3 of `Faithful` (`RecycleSafe`, through `recSafeB`) still holds
for the imported pool with the two terms added. Clause 3 asks that no Trainer recycler admit a
non-Supporter writer and that nothing recycle a rest-of-game writer; these two terms are Items
writing for this turn or the next, and no recycling filter of an imported card admits an Item. It is
evidence that a recycling loop through these two Items needs a recycler outside the imported pool:
whether a filter admits a Trainer card depends only on the card's name and kind (`Filter.eval`),
which the over-approximated terms share with the printed cards. It is NOT evidence that
today's Standard satisfies `RecycleSafe` (refused recyclers, Tools, Stadiums and Abilities are not
here), nor that games with the printed cards are `Faithful`, nor anything about how much damage the
printed cards do.
-/

namespace PokemonCards.OverApprox

open Pokemon

/-- Iron Defender (me1-118) with "your Metal Pokémon" widened to all of your Pokémon. NOT the
printed card. -/
def ironDefenderOver : Card := .trainer "Iron Defender" .item (.linger .own .next (.reduce 3))

/-- Premium Power Pro (me1-124) with "your Fighting Pokémon" widened to all of your Pokémon. NOT
the printed card. -/
def premiumPowerProOver : Card := .trainer "Premium Power Pro" .item (.linger .own .now (.bonus 3))

/-- Both terms are non-Supporter writers (so clause 3 (a) constrains their recycling). -/
theorem overItems_write :
    ironDefenderOver.wAmt ≠ 0 ∧ premiumPowerProOver.wAmt ≠ 0 := by decide +kernel

/-- **Probe, over-approximated.** The recycling check of clause 3 holds for the imported pool with
the two over-approximated Items added. -/
theorem recSafe_withOverItems :
    recSafeB (Standard.all ++ [ironDefenderOver, premiumPowerProOver]) = true := by decide +kernel

end PokemonCards.OverApprox
