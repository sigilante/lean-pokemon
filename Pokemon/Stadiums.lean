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
differ in play. No Standard Stadium's activated ("Once during each player's turn") effect writes
a lingering damage bonus or reduction (survey S9); the three whose activated effect the model
expresses (Academy at Night, Levincia, Prism Tower) move cards. Static Stadium text that changes
damage (Postwick sv9-154: "do 30 more damage"; Full Metal Lab sv5-148: "take 30 less damage";
the reduction or prevention of Battle Cage, Granite Cave and Neutralization Zone) is not modelled (Known gaps in
`Pokemon/Rules.lean`): such a Stadium is played as an inert card.
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

theorem S_gxOnly : (S 0).GXOnly :=
  GameState.GXOnly.of_noAttacks (by rw [S_allCards]; decide)

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
  refine ⟨by unfold GameState.LoopFree; decide, GameState.GXOnly.of_noAttacks (by decide),
    by unfold GameState.RecycleSafe; decide, by unfold GameState.AbilitySafe; decide,
    by unfold GameState.StadiumSafe; decide⟩

/-- **…and fails the clause 3 of milestone M8a**, which counted every Trainer card's effect,
a Stadium's included, as a free recycler: clause 3 is weaker for Stadiums since milestone M5. -/
theorem stadium_recycler_not_M8a : ¬ D.RecycleSafeM8a := by
  intro h
  have := h.1 depot (by decide) (.named "Iron Defender") (.head _) ironDefender (by decide) rfl
  exact absurd this (by decide)

/-! ## Witnesses (milestone M5) -/

theorem mem_of_eq {h l₁ l₂ : List Card} {c : Card} (e : h = l₁ ++ c :: l₂) : c ∈ h := by
  rw [e]; exact List.mem_append_right _ (.head _)

/-- Levincia sv10-244: "Once during each player's turn, that player may put up to 2 Basic
Lightning Energy cards from their discard pile into their hand." -/
def levincia : Card :=
  .trainer "Levincia" .stadium (.move .own .discard .hand (.energyOf .lightning) (.upTo 2))

/-- Academy at Night sv6pt5-54: "Once during each player's turn, that player may put a card from
their hand on top of their deck." -/
def academy : Card := .trainer "Academy at Night" .stadium (.move .own .hand .top .any (.upTo 1))

def lt : Card := .energy .lightning
def mt : Card := .energy .metal

/-- A player with `mon` Active, no Bench, two Prize cards, and the given hand, deck and discard
pile. -/
def wpl (hand deck discard : List Card) : PlayerState :=
  ⟨deck, hand, discard, [mt, mt], [], some mon, [], false, false, false, false, false,
    Store.empty, true⟩

/-- A state in the turn proper (`bt = false`) or between turns, with the player to move `a`, the
opponent `b`, whether the player to move went first, the Stadium slot and the two Stadium flags. -/
def W (a b : PlayerState) (cf bt : Bool) (st : Option (Bool × Card)) (sp su : Bool) : GameState :=
  ⟨a, b, cf, false, false, bt, none, st, sp, su⟩

theorem W_settled (a b : PlayerState) (cf bt : Bool) (st : Option (Bool × Card)) (sp su : Bool)
    (ha : a.active = some mon) (hb : b.active = some mon) (ha' : a.bench = [])
    (hb' : b.bench = []) : Settled (W a b cf bt st sp su) :=
  settled_mon ha hb ha' hb'

/-- The first player holds Levincia, and each player has Basic Lightning Energy in the discard
pile; the second player holds Academy at Night. -/
def W0 : GameState := W (wpl [levincia] [mt] [lt, lt]) (wpl [academy] [mt] [lt]) true false none
  false false

/-- After the first player has played Levincia and used it to return one Lightning Energy. -/
def W2 : GameState := W (wpl [lt] [mt] [lt]) (wpl [academy] [mt] [lt]) true false
  (some (true, levincia)) true true

/-- After the second player has drawn and used Levincia (their own use in their own turn). -/
def W5 : GameState := W (wpl [lt, mt, academy] [] []) (wpl [lt] [mt] [lt]) false false
  (some (true, levincia)) false true

/-- After the second player has played Academy at Night over Levincia and used it. -/
def W7 : GameState := W (wpl [mt] [lt] []) (wpl [lt] [mt] [levincia, lt]) false false
  (some (false, academy)) true true

/-- **The first player plays Levincia and uses it**: one Lightning Energy goes from the discard
pile to the hand. -/
theorem levincia_first : Reach W0 W2 :=
  .step (.step (.refl _) rfl
    (.stadium (l₁ := []) (l₂ := []) rfl rfl rfl rfl
      (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl) rfl))
    rfl (.stadiumUse rfl rfl rfl (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl) rfl
      (.prim rfl rfl
        (.zone (w := .own) rfl
          (.move (src := .discard) (.take rfl (.keep .nil)) (by unfold Qty.ok; decide)
            (.hand _ _)))
        (.done (.inl (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl))))
      rfl rfl)

/-- **The Stadium is refused a second time in the turn**: from `W2` no move of the first
player's turn changes their discard pile, which still holds a Lightning Energy that a second use
of Levincia would return, or the Stadium in play (a second Stadium may not be played either: one
has been played this turn). -/
theorem levincia_refused : ∀ g', Move W2 g' → g'.curIsFirst = true →
    g'.cur.discard = W2.cur.discard ∧ g'.stadium = W2.stadium := by
  intro g' hm hc
  cases hm with
  | playBasic hh => exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | attach => exact ⟨rfl, rfl⟩
  | evolve hh => exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | attachBench _ _ hb => simp [W2, W, wpl] at hb
  | evolveBench hh => exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | retreat _ hb => simp [W2, W, wpl] at hb
  | item hh => exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | supporter hh => exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | stadium hh => exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | tool hh => exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | toolBench hh => exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | stadiumUse _ hu => simp [W2, W] at hu
  | ability hu hm =>
      cases hu with
      | active ha =>
          simp only [W2, W, wpl, Option.some.injEq] at ha; subst ha
          simp [InPlay.abilities, Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hm
      | bench hb => simp [W2, W, wpl] at hb
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      exact absurd (mem_of_eq hh) (by simp [W2, W, wpl, lt])
  | attack ha hm =>
      simp only [W2, W, wpl, Option.some.injEq] at ha; subst ha
      simp [InPlay.attacks, Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hm
  | attackConfused ha hm =>
      simp only [W2, W, wpl, Option.some.injEq] at ha; subst ha
      simp [InPlay.attacks, Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hm
  | knockOut ha hk =>
      simp only [W2, W, wpl, Option.some.injEq] at ha; subst ha
      simp [Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hk
  | promote ha => simp [W2, W, wpl] at ha
  | noPokemon ha => simp [W2, W, wpl] at ha
  | knockOutOwn ha hk =>
      simp only [W2, W, wpl, Option.some.injEq] at ha; subst ha
      simp [Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hk
  | promoteOwn ha => simp [W2, W, wpl] at ha
  | noPokemonOwn ha => simp [W2, W, wpl] at ha
  | knockOutBench hb => simp [W2, W, wpl] at hb
  | knockOutBenchOwn hb => simp [W2, W, wpl] at hb
  | endTurn => simp [W2, W] at hc
  | startTurn hbt => simp [W2, W] at hbt
  | deckOut hbt => simp [W2, W] at hbt

/-- **The second player uses the same Stadium in their turn**: the first player ends the turn,
the second draws and uses Levincia, whose effect acts for them. -/
theorem levincia_second : Reach W2 W5 :=
  .step (.step (.step (.refl _) rfl
    (.endTurn false false false false false false rfl rfl
      (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl).1 rfl .nil .nil))
    rfl (.startTurn rfl rfl rfl (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl).1 rfl))
    rfl (.stadiumUse rfl rfl rfl (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl) rfl
      (.prim rfl rfl
        (.zone (w := .own) rfl
          (.move (src := .discard) (.take rfl .nil) (by unfold Qty.ok; decide) (.hand _ _)))
        (.done (.inl (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl))))
      rfl rfl)

/-- **A new Stadium replaces the old one, which goes to its owner's discard pile**: the second
player plays Academy at Night over Levincia, which goes to the first player's discard pile, and
then uses the new Stadium in the same turn (a Stadium newly put into play has not been used: two
Stadium uses in one turn, the most `GameState.stPot` allows). -/
theorem academy_replaces : Reach W5 W7 :=
  .step (.step (.refl _) rfl
    (.stadium (l₁ := [lt, mt]) (l₂ := []) rfl rfl (by decide) rfl
      (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl) rfl))
    rfl (.stadiumUse rfl rfl rfl (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl) rfl
      (.prim rfl rfl
        (.zone (w := .own) rfl
          (.move (src := .hand) (.take rfl (.keep .nil)) (by unfold Qty.ok; decide)
            (.top _ (List.Perm.refl _))))
        (.done (.inl (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl))))
      rfl rfl)

theorem academy_replaces_owner : W7.opp.discard = [levincia, lt] ∧ W7.cur.discard = [] ∧
    W7.stadium = some (false, academy) := ⟨rfl, rfl, rfl⟩

/-- Levincia in play (owned by the second player, already used this turn) and a second Levincia
in the first player's hand; no Stadium played this turn. -/
def X (inPlay : Card) : GameState :=
  W (wpl [levincia] [mt] []) (wpl [] [mt] []) true false (some (false, inPlay)) false true

/-- **No Stadium with the name of the one in play**: from `X levincia` no move of the turn plays
the Levincia in hand or changes the Stadium in play ("You can't play a Stadium card if a Stadium
with the same name is already in play"). -/
theorem same_name_refused : ∀ g', Move (X levincia) g' → g'.curIsFirst = true →
    g'.cur.hand = [levincia] ∧ g'.stadium = some (false, levincia) := by
  intro g' hm hc
  cases hm with
  | playBasic hh => exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | attach hh => exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | evolve hh => exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | attachBench _ _ hb => simp [X, W, wpl] at hb
  | evolveBench hh => exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | retreat _ hb => simp [X, W, wpl] at hb
  | item hh => exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | supporter hh => exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | stadium hh _ hn =>
      have hm := mem_of_eq hh
      simp only [X, W, wpl, levincia, List.mem_singleton, Card.trainer.injEq] at hm
      obtain ⟨rfl, -, rfl, rfl⟩ := hm
      exact absurd hn (by decide)
  | tool hh => exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | toolBench hh => exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | stadiumUse _ hu => simp [X, W] at hu
  | ability hu hm =>
      cases hu with
      | active ha =>
          simp only [X, W, wpl, Option.some.injEq] at ha; subst ha
          simp [InPlay.abilities, Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hm
      | bench hb => simp [X, W, wpl] at hb
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      exact absurd (mem_of_eq hh) (by simp [X, W, wpl, levincia])
  | attack ha hm =>
      simp only [X, W, wpl, Option.some.injEq] at ha; subst ha
      simp [InPlay.attacks, Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hm
  | attackConfused ha hm =>
      simp only [X, W, wpl, Option.some.injEq] at ha; subst ha
      simp [InPlay.attacks, Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hm
  | knockOut ha hk =>
      simp only [X, W, wpl, Option.some.injEq] at ha; subst ha
      simp [Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hk
  | promote ha => simp [X, W, wpl] at ha
  | noPokemon ha => simp [X, W, wpl] at ha
  | knockOutOwn ha hk =>
      simp only [X, W, wpl, Option.some.injEq] at ha; subst ha
      simp [Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hk
  | promoteOwn ha => simp [X, W, wpl] at ha
  | noPokemonOwn ha => simp [X, W, wpl] at ha
  | knockOutBench hb => simp [X, W, wpl] at hb
  | knockOutBenchOwn hb => simp [X, W, wpl] at hb
  | endTurn => simp [X, W] at hc
  | startTurn hbt => simp [X, W] at hbt
  | deckOut hbt => simp [X, W] at hbt

/-- …while with Academy at Night in play the same Levincia can be played, replacing it. -/
theorem other_name_allowed : ∃ g', Move (X academy) g' ∧ g'.stadium = some (true, levincia) :=
  ⟨_, .stadium (l₁ := []) (l₂ := []) rfl rfl (by decide) rfl
    (W_settled _ _ _ _ _ _ _ rfl rfl rfl rfl) rfl, rfl⟩

end Pokemon.Stadiums
