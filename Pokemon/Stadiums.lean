import Pokemon.Abilities
import Pokemon.NoStadiums

/-!
# Stadium effects and the store bound (milestone M5)

A Stadium stays in play, and "Once during each player's turn, that player may …" lets each player
use its effect once in each of their turns (`Move.stadiumUse`), without the card being played
again. Within one turn the uses are few: the Stadium in play once, and, after the one Stadium play
of the turn (`Move.stadium`), the new Stadium once (`GameState.stPot`, at most 2). So a Stadium's
effect is paid for per use, like a once-per-turn Ability (`Card.stQ`: what it writes, plus `P` if
it recycles), and the per-turn count of `Faithful.TInv` covers it. Across turns nothing is paid:

* `stadium_writer_breaks_bound`: a well-formed start satisfying clauses 1–4 of `Faithful` and
  violating clause 5 (`StadiumSafe`), with a Stadium in play whose effect writes a rest-of-game
  damage bonus, has reachable states with unbounded stores and `xclamp`s in no finite list: each
  player uses the Stadium in each of their turns, and the rest-of-game bonus never expires. (The
  effect also puts the player's hand on the bottom of the deck, so that the draw at the start of
  each turn never empties the deck: without some return to the deck the game ends, since every
  turn draws a card.) So clause 5 is needed.
* `stadium_recycler_faithful`: a Stadium whose effect returns an Iron Defender-like Item (a
  modifier writer) from the discard pile to the hand, usable by both players every turn, is
  faithful, so `Faithful.xfinite` applies: the Item is played at most once per Stadium use, and the
  uses are at most two in a turn. Before milestone M5 clause 3 (a) counted every Trainer card's
  effect as a free recycler; this deck fails that clause (`stadium_recycler_not_M8a`), so clause 3
  is weaker than before for Stadiums, which survey S10's property P had listed with the free
  recyclers ("no Stadium in either deck may return a modifier writer"). The proof of
  `Faithful.reach_boundedStores` shows that the per-turn limit is enough.

As for `Recycle.recycling_breaks_bound`, the negative result is about representation: nothing
reads the stored bonus (no attack is made), so the unboundedly many states are not shown to
differ in play. No Standard Stadium writes a damage bonus or reduction at all (survey S9); the
three whose effect the model expresses (Academy at Night, Levincia, Prism Tower) move cards.
-/

namespace Pokemon.Stadiums

open Recycle

/-! ## A Stadium whose effect writes a rest-of-game bonus -/

/-- "Once during each player's turn, that player may put their hand on the bottom of their deck.
If they do, for the rest of the game their attacks do 10 more damage": no printed card has it. -/
def gym : Card :=
  .trainer "Gym" .stadium (.seq (.linger .own .always (.bonus 1)) .handToBottom)

/-- A store with a rest-of-game damage bonus of `b`. -/
def ab (b : Nat) : Store := ⟨Mods.empty, Mods.empty, Mods.empty, { Mods.empty with bonus := b }⟩

/-- The guard in play, not put into play this turn. -/
def mon : InPlay := { InPlay.ofBasic guard with fresh := false }

def spl (b : Nat) (hand deck : List Card) : PlayerState :=
  ⟨deck, hand, [], [.energy .metal], [], some mon, [], false, false, false, false, false, ab b,
    true⟩

/-- The player who went first to move, in the turn proper after the draw, both players with a
rest-of-game bonus of `b`, the Stadium `gym` in play (owned by the first player), not yet used. -/
def S (b : Nat) : GameState :=
  ⟨spl b [.energy .metal] [], spl b [] [.energy .metal], true, false, false, false, none,
    some (true, gym), false, false⟩

theorem settled_mon {g : GameState} (hc : g.cur.active = some mon) (ho : g.opp.active = some mon)
    (h1 : g.cur.bench = []) (h2 : g.opp.bench = []) : Settled g :=
  Abilities.settled_two hc ho (show 0 < 10 by decide) (show 0 < 10 by decide) h1 h2

/-- **One round**: the first player uses the Stadium and ends the turn, the second player draws,
uses the Stadium and ends the turn, the first player draws: both rest-of-game bonuses are one
higher. -/
theorem round (b : Nat) : Reach (S b) (S (b + 1)) :=
  .step (.step (.step (.step (.step (.step (.refl _) rfl
    (.stadiumUse rfl rfl rfl (settled_mon rfl rfl rfl rfl) rfl
      (.seq (.prim rfl rfl (.linger .own .always (.bonus 1) _)
          (.done (.inl (settled_mon rfl rfl rfl rfl))))
        (.prim rfl rfl (.handToBottom (List.Perm.refl _))
          (.done (.inl (settled_mon rfl rfl rfl rfl)))))
      rfl rfl))
    rfl (.endTurn false false false false false false rfl rfl
      (settled_mon rfl rfl rfl rfl).1 rfl .nil .nil))
    rfl (.startTurn rfl rfl rfl (settled_mon rfl rfl rfl rfl).1 rfl))
    rfl (.stadiumUse rfl rfl rfl (settled_mon rfl rfl rfl rfl) rfl
      (.seq (.prim rfl rfl (.linger .own .always (.bonus 1) _)
          (.done (.inl (settled_mon rfl rfl rfl rfl))))
        (.prim rfl rfl (.handToBottom (List.Perm.refl _))
          (.done (.inl (settled_mon rfl rfl rfl rfl)))))
      rfl rfl))
    rfl (.endTurn false false false false false false rfl rfl
      (settled_mon rfl rfl rfl rfl).1 rfl .nil .nil))
    rfl (.startTurn rfl rfl rfl (settled_mon rfl rfl rfl rfl).1 rfl)

theorem reach_S (k : Nat) : Reach (S 0) (S k) := by
  induction k with
  | zero => exact .refl _
  | succ k ih => exact reach_trans ih (round k)

theorem S_wellFormed : WellFormed (S 0) :=
  ⟨fun _ => ⟨by simp [S, spl], by simp [S, spl]⟩, (fun p hp => by cases hp),
    (fun p hp => by cases hp)⟩

theorem S_allCards : (S 0).allCards =
    [.energy .metal, .energy .metal, .pokemon guard, .energy .metal, .energy .metal,
      .pokemon guard, gym] := rfl

theorem S_gxOnly : (S 0).GXOnly := by
  intro p hp atk hm
  rw [S_allCards] at hp
  simp only [List.mem_cons, Card.pokemon.injEq, List.not_mem_nil, or_false, reduceCtorEq,
    false_or, gym] at hp
  rcases hp with rfl | rfl <;> cases hm

theorem S_not_stadiumSafe : ¬ (S 0).StadiumSafe := by
  intro h
  have := h gym (by rw [S_allCards]; simp)
  exact absurd this (by decide)

/-- The rest-of-game bonus of the player to move. -/
def bon (g : GameState) : Nat := g.cur.mods.always.bonus

theorem bon_xclamp (g : GameState) : bon g.xclamp = bon g := rfl

/-- **A Stadium whose effect writes a rest-of-game bonus breaks the store bound** (milestone M5).
There is a well-formed start satisfying clauses 1 to 4 of `Faithful` and violating clause 5
(`StadiumSafe`), whose reachable states have unbounded stores and whose reachable states'
`xclamp`s lie in no finite list: both players use the Stadium in play in every turn, and the
rest-of-game bonus it writes never expires. So clause 5, or some other condition on Stadium
effects, is needed for `Faithful.reach_boundedStores` and the finiteness half of
`Faithful.xfinite`. -/
theorem stadium_writer_breaks_bound :
    ∃ g₀ : GameState, WellFormed g₀ ∧ g₀.LoopFree ∧ g₀.GXOnly ∧ g₀.RecycleSafe ∧
      g₀.AbilitySafe ∧ ¬ g₀.StadiumSafe ∧ (∀ B, ∃ g, Reach g₀ g ∧ ¬ g.BoundedStores B) ∧
      ¬ ∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp ∈ L := by
  refine ⟨S 0, S_wellFormed, by unfold GameState.LoopFree; rw [S_allCards]; decide, S_gxOnly,
    by unfold GameState.RecycleSafe; rw [S_allCards]; decide,
    by unfold GameState.AbilitySafe; rw [S_allCards]; decide, S_not_stadiumSafe, fun B => ?_, ?_⟩
  · refine ⟨_, reach_S (B + 1), fun hb => ?_⟩
    have := hb.1.2.2.2.1
    simp only [S, spl, ab] at this
    omega
  · intro ⟨L, hL⟩
    let n := (L.map bon).sum + 1
    have hm := hL _ (reach_S n)
    have : bon (S n).xclamp ≤ (L.map bon).sum := Infinite.le_sum (List.mem_map_of_mem hm)
    rw [bon_xclamp] at this
    simp only [bon, S, spl, ab, n] at this
    omega

/-! ## A Stadium that recycles a modifier writer is faithful -/

/-- "Once during each player's turn, that player may put an Iron Defender from their discard pile
into their hand": no printed card has it (Levincia sv10-244 returns Basic Lightning Energy). -/
def depot : Card :=
  .trainer "Depot" .stadium (.move .own .discard .hand (.named "Iron Defender") (.upTo 1))

/-- A deck with `ironDefender` (an Item that writes a carried reduction) and `depot` in play. -/
def D : GameState :=
  ⟨spl 0 [ironDefender] [.energy .metal], spl 0 [] [.energy .metal], true, false, false, false,
    none, some (true, depot), false, false⟩

/-- **A Stadium that returns a modifier-writing Item every turn, to both players, is faithful**
(milestone M5), so `Faithful.xfinite` applies to `D`. -/
theorem stadium_recycler_faithful : D.Faithful := by
  refine ⟨by unfold GameState.LoopFree; decide, ?_, by unfold GameState.RecycleSafe; decide,
    by unfold GameState.AbilitySafe; decide, by unfold GameState.StadiumSafe; decide⟩
  intro p hp atk hm
  simp [D, spl, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
    InPlay.cardList, mon, InPlay.ofBasic, stadiumCardList, ironDefender, depot] at hp
  subst hp; cases hm

/-- **…and fails the clause 3 of milestone M8a**, which counted every Trainer card's effect,
a Stadium's included, as a free recycler: clause 3 is weaker for Stadiums since milestone M5. -/
theorem stadium_recycler_not_M8a : ¬ D.RecycleSafeM8a := by
  intro h
  have := h.1 depot (by decide) (.named "Iron Defender") (.head _) ironDefender (by decide) rfl
  exact absurd this (by decide)

end Pokemon.Stadiums
