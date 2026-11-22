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

`recSafe_withOverItems` says clause 3 of `StoreSafe` (`RecycleSafe`, through `recSafeB`) still holds
for the imported pool with the two terms added. Clause 3 asks that no Item or Supporter and no "as
often as you like" Ability (`Card.freeRec`) recycle an Item that writes a bonus or reduction
(`Card.wAmt`), and that nothing, attacks, Abilities and Stadium effects included (`Card.allRec`),
recycle a rest-of-game writer; these two terms are Items writing for this turn or the next. Since the
importer translates Abilities (version 0.3.0) the pool has Ability recyclers and "as often as you
like" Abilities, so the check covers them: no recycling filter of an Item, a Supporter or an "as often
as you like" Ability of the imported pool admits either Item (`Standard.freeRecyclers` lists the cards
those filters come from). Since milestone M5 a Stadium's effect is not a free recycler (its uses are
at most two in a turn, `Card.stQ`), so clause 3 (a) does not ask it to leave the two Items alone.
`storeSafe_withOverItems` adds the per-card checks and gives all five clauses for every game whose
cards come from the pool with the two terms added.

Stadiums (importer 0.4.0). The pool now has Stadiums whose effect recycles (`Standard.stadiumRecyclers`:
Levincia). Clause 3 lets a Stadium recycle a writer, since its uses are bounded per turn, so the
five-clause theorem would hold even if one returned these Items. `stadiums_leave_overItems` checks the
stronger property of survey S10 §5 (P: no Stadium of either deck may return a modifier writer) for the
imported Stadiums and the two Items: no recycling filter of an imported Stadium admits either.

It is evidence that a recycling loop through these two Items needs a recycler outside the imported
pool: whether a filter admits a Trainer card depends only on the card's name and kind
(`Filter.eval`), which the over-approximated terms share with the printed cards. It is NOT evidence
that today's Standard satisfies `RecycleSafe` (refused recyclers, Abilities, Tools and Stadiums are not
here), nor that games with the printed cards are `StoreSafe`, nor anything about how much damage the
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

/-- **Stadium recyclers.** No recycling filter of an imported Stadium's effect admits either
over-approximated Item (survey S10's property P for Stadiums, stronger than clause 3 asks). -/
theorem stadiums_leave_overItems :
    ((Standard.all.filter Card.isStadium).flatMap Card.allRec).all
      (fun f => !f.eval ironDefenderOver && !f.eval premiumPowerProOver) = true := by decide +kernel

/-- Both terms pass the per-card checks (`Card.importOk`). -/
theorem overItems_ok : [ironDefenderOver, premiumPowerProOver].all Card.importOk = true := by
  decide +kernel

/-- **Probe, over-approximated, all five clauses.** Every game whose cards come from the imported
pool and the two over-approximated Items is `StoreSafe`, so `StoreSafe.xfinite` applies to it. -/
theorem storeSafe_withOverItems (g : GameState)
    (hg : ∀ x ∈ g.allCards, x ∈ Standard.all ++ [ironDefenderOver, premiumPowerProOver]) :
    g.StoreSafe :=
  storeSafe_of (by rw [List.all_append, Standard.all_ok, overItems_ok]; rfl) recSafe_withOverItems g hg

end PokemonCards.OverApprox
