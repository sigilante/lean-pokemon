import Pokemon.Bench

/-!
# Tests on cards in play (milestone MV2, stage 1)

Survey S13 §C: the commonest refused shape of the family is a test on the printed card of the
opponent's Active Pokémon ("If your opponent's Active Pokémon is a Pokémon ex, this attack does 70
more damage", Koraidon sv7-90; "… is an Evolution Pokémon", Toxicroak sv6pt5-24; "… is a Stage 2
Pokémon", Regirock ex sv10-101; "… is a Tera Pokémon", Regigigas sv8pt5-86), then counts of
Pokémon in play passing a filter ("for each of your Pokémon in play that has the Round attack",
Tympole zsv10pt5-19; "if you have any Tera Pokémon on your Bench", Ho-Oh sv8-19). Milestone MV2
added `Test.top` (the Active Pokémon's top card passes a filter), `Test.hasTool`, the filters
`Filter.ex`, `Filter.tera`, `Filter.hasAttack` and `Filter.hasAbility`, and the count
`Count.inPlay` (Active and Benched Pokémon whose top card passes a filter).

They read the printed cards of the Pokémon in play and their Tools, which both clamps keep: the
clamps change damage and Poison strength only (and the capped clamp the stores). So no clamp
theorem needed a new hypothesis: `Test.eval_agree` gained two cases closed by the agreement of the
top card and the Tools, and `Count.val_clampAt`, `Count.val_xclampAt` one case each. The lemmas
below state this directly; the witnesses show a test on a card in play true and false.
-/

namespace Pokemon.InPlayTests

open Trainer Bench

/-- A test on a card in play reads the same in a Pokémon that agrees with it under any clamp
(`InPlay.Agree`: same cards, the damage possibly capped). -/
theorem top_agree {K : Nat} {c : Cap} {q p : InPlay} (h : InPlay.Agree K c q p) (w : Whose)
    (f : Filter) (g₁ g₂ : GameState) : (Test.top w f).eval g₂ q = (Test.top w f).eval g₁ p := by
  simp only [Test.eval, h.top]

theorem hasTool_agree {K : Nat} {c : Cap} {q p : InPlay} (h : InPlay.Agree K c q p) (w : Whose)
    (g₁ g₂ : GameState) : (Test.hasTool w).eval g₂ q = (Test.hasTool w).eval g₁ p := by
  simp only [Test.eval, h.tools]

/-- "If your opponent's Active Pokémon is a Pokémon ex, put 3 damage counters on it." -/
def exPunish : Effect := .ite (.top .opp .ex) (.counters 3) .skip

/-- The player to move has `big` Active; the opponent has `opp` Active. -/
def duel (opp : PokemonCard) : GameState :=
  ⟨side [] [] (InPlay.ofBasic big) [], side [] [] (InPlay.ofBasic opp) [],
    true, false, false, false, none, none, false, false⟩

/-- **Witness: the test is true on a Pokémon ex.** -/
theorem exPunish_ex :
    Run exPunish (duel exMon)
      { duel exMon with opp := { (duel exMon).opp with
          active := some { InPlay.ofBasic exMon with damage := 3 } } } :=
  .iteT (p := InPlay.ofBasic exMon) rfl (by decide) (.counters 3 rfl)

/-- **Witness: the test is false on a Pokémon without a rule box**, and the effect does nothing. -/
theorem exPunish_plain : Run exPunish (duel big) (duel big) :=
  .iteF (p := InPlay.ofBasic big) rfl (by decide) (.skip _)

/-- "For each of your Pokémon in play that has the Round attack": two of the player's three
Pokémon in play pass `hasAttack "Round"`. -/
def round : Attack := ⟨"Round", [], 2, .skip, false⟩

def singer : PokemonCard := ⟨"Singer", .basic, none, 6, .water, [round], 1, none, none, .none,
  false, []⟩

def choir : GameState :=
  ⟨side [] [] (InPlay.ofBasic singer) [InPlay.ofBasic big, InPlay.ofBasic singer],
    side [] [] (InPlay.ofBasic big) [], true, false, false, false, none, none, false, false⟩

theorem choir_count : (Count.inPlay .own (.hasAttack "Round")).val choir = 2 := by decide

/-- The count of Evolution Pokémon is 0 here, and of Basic Pokémon in play 3. -/
theorem choir_counts : (Count.inPlay .own (.not .basic)).val choir = 0 ∧
    (Count.inPlay .own .basic).val choir = 3 := by decide

end Pokemon.InPlayTests
