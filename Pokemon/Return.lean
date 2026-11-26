import Pokemon.Lock
import Pokemon.StoreSafe

/-!
# Return from play (milestone MV15, survey S29)

One effect primitive, `Effect.returnPokemon w sp d`: one of the `w` player's Pokémon at `sp` (the
Active Pokémon, or one Benched Pokémon chosen when the effect resolves) leaves play with every card
attached to it and under it (`InPlay.cardList`) for `d` (hand, deck, discard pile). It is a zone step
(`ZStep.monActive`, `ZStep.monBench`, `ZStep.monNone`), so it permutes the player's cards
(`ZStep.count`), is simulated by the kernel of every clamp at any caps (`ZStep.sim`: the cards a
Pokémon is made of do not depend on its damage), keeps every Benched Pokémon `Benched` and the marks as
`WellFormed` asks (`ZStep.benchOk`, `ZStep.noMarks`), and adds no state: the damage counters, Special
Conditions, markers and other effects on the Pokémon go with its `InPlay` record. An Active Spot it
empties is filled by the batch step that follows (`KOBatch`, which from a state with an empty Active
Spot and no Knock Out takes no Prize card and promotes), and a player left with no Pokémon in play has
lost there (`winWays`, rulebook 2026 p. 7: "If your opponent doesn't have any more Pokémon in play,
you win the game!").

**Who pays.** The store bound of `StoreSafe` counts the uses of "once during your turn" and on-play
Abilities in a turn with a potential of the player's board (`GameState.abPot`), which no move before
the turn's attack raises. A return raises it (`return_raises_abPot`, `trun_raises_abPot`: a used,
fresh Pokémon leaves and frees a place), and a play–use–return loop would leave it where it was. So
the primitive is **attacks only**: every move that resolves an effect outside an attack (`Move.item`,
`Move.supporter`, `Move.stadiumUse`, `Move.ability`, `Move.onPlay`) has the premise
`Effect.retFree` (no `returnPokemon` in the effect), and the trigger fragment excludes it
(`Effect.retFree_of_trigOk`). An attack ends the turn (`Move.after_attack`: afterwards only the batch
step, a pending trigger and the end of the turn are legal), and the per-turn invariant reads the
potential only before the turn's attack (`TInv.pot`, `TInv.turn`), so `Move.abPot_le` now has the
hypothesis `g'.attacked = false`. Across turns nothing needs bounding: the potential is counted afresh
at the start of every turn (`TInv.endTurn`), and it is at most `potBound` of the number of cards in
every state (`GameState.abPot_le_bound`).

**What the model does not hide** (`trace`): a Pokémon uses its once-per-turn Ability (a stored
damage bonus), attacks with "Put this Pokémon and all attached cards into your hand", the Bench
Pokémon is promoted with no Prize card, the turns pass, the card is played again from the hand and
uses its Ability again, writing the store again. The returned Pokémon re-enters play as a new
Pokémon (no damage, unused, put into play this turn).

**Witnesses** (legal moves from starts proved `WellFormed` and `Settled`; the states of `trace` are
reached from `r0`): `return_hand` (to the hand, with the attached Energy; damage counters gone),
`return_deck` (shuffled into the deck), `return_opp_bench` (the opponent's Benched Pokémon into their
deck), `opp_refill` (the opponent's Active Pokémon to their hand, and the opponent promotes with no
Prize card taken), `refill` (the player's own Active Spot refilled, no Prize card), `no_pokemon_loses`
(a player who returns their only Pokémon loses at the batch step), `trace` (above). **General**
(every resolution): `monActive_empties`, `monActive_hand`. **Negative** (hand-built starts, labelled):
`return_raises_abPot`, `trun_raises_abPot`.
-/

namespace Pokemon.Return

open Trainer Lock

/-- "Once during your turn, you may use this Ability. During this turn, attacks used by your Pokémon
do 10 more damage" (a scaled Feraligatr sv5-41 shape: a stored bonus). -/
def charge : Ability := ⟨"Charge", .once, none, none, .fx (.linger .own .now (.bonus 1))⟩

/-- "Fade Out" (Combee me6-6, scaled): 10 damage. "Put this Pokémon and all attached cards into your
hand." -/
def fadeOut : Attack := ⟨"Fade Out", [], 1, .returnPokemon .own .active .hand, false, .none⟩

/-- "Jumping Shot" (Lokix me2-10, scaled): 10 damage. "Shuffle this Pokémon and all attached cards
into your deck." -/
def jump : Attack := ⟨"Jumping Shot", [], 1, .returnPokemon .own .active .shuffle, false, .none⟩

/-- "Slowing Perfume" (Illumise sv6-10, without its first-turn condition): "Shuffle 1 of your
opponent's Benched Pokémon and all attached cards into their deck." -/
def perfume : Attack := ⟨"Slowing Perfume", [], 0, .returnPokemon .opp .bench .shuffle, false, .none⟩

/-- A test attack: "Put your opponent's Active Pokémon and all attached cards into their hand." -/
def snatch : Attack := ⟨"Snatch", [], 0, .returnPokemon .opp .active .hand, false, .none⟩

/-- The returning Pokémon: 100 HP, the four attacks and the Ability. -/
def flier : PokemonCard :=
  ⟨"Flier", .basic, none, 10, .grass, [fadeOut, jump, perfume, snatch], 1, none, none, .none, false,
    [charge]⟩

/-- `flier` in play since an earlier turn, with 2 damage counters and a Fire Energy attached. -/
def flierA : InPlay :=
  { InPlay.ofBasic flier with fresh := false, damage := 2, energy := [.energy .fire] }

/-- **The start**: the first player (to move) has `flierA` Active and `big` on the Bench; the second
player has `big` Active (with `big` on the Bench when `ob`); one Prize card each, three cards in each
deck. -/
def start (ob : List InPlay) : GameState :=
  ⟨{ side [] [.energy .fire] flierA [InPlay.ofBasic big] with deck := deck3 },
    { side [] [.energy .fire] (InPlay.ofBasic big) ob with deck := deck3 },
    true, false, false, false, none, none, false, false, false⟩

def r0 : GameState := start []

/-- The start with a Benched `big` for the opponent. -/
def o0 : GameState := start [InPlay.ofBasic big]

theorem r0_wf : WellFormed r0 := by
  refine ⟨fun _ => ⟨by simp [r0, start, side], by simp [r0, start, side]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp
  · simp only [r0, start, side, List.mem_singleton] at hp
    subst hp; exact ⟨rfl, rfl, rfl, rfl⟩
  · cases hp

theorem o0_wf : WellFormed o0 := by
  refine ⟨fun _ => ⟨by simp [o0, start, side], by simp [o0, start, side]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp
  · simp only [o0, start, side, List.mem_singleton] at hp
    subst hp; exact ⟨rfl, rfl, rfl, rfl⟩
  · simp only [o0, start, side, List.mem_singleton] at hp
    subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem r0_settled : Settled r0 :=
  settled_of rfl rfl (show 2 < 10 by decide) (show 0 < 10 by decide)
    (fun p hp => by simp only [r0, start, side, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by cases hp)

theorem o0_settled : Settled o0 :=
  settled_of rfl rfl (show 2 < 10 by decide) (show 0 < 10 by decide)
    (fun p hp => by simp only [o0, start, side, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by simp only [o0, start, side, List.mem_singleton] at hp; subst hp; decide)

/-! ## The trace: use, return, refill, play again, use again -/

/-- After Charge: `flierA` has used its Ability, and this turn's bonus is 1. -/
def r1 : GameState :=
  { r0 with cur := { r0.cur with active := some flierA.markUsed, mods := r0.cur.mods.add .now (.bonus 1) } }

theorem r1_settled : Settled r1 :=
  settled_of rfl rfl (show 2 < 10 by decide) (show 0 < 10 by decide)
    (fun p hp => by simp only [r1, r0, start, side, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by cases hp)

theorem r0_r1 : Move r0 r1 := by
  have m : Move r0 _ :=
    .ability (ab := charge) (.active rfl) (.head _) rfl rfl (fun _ => rfl) trivial rfl r0_settled rfl
      (.prim rfl rfl (.linger .own .now (.bonus 1) _) (.done (.inl r1_settled))) rfl rfl
  exact m

/-- After Fade Out: the defender has 2 damage counters (10 damage and the bonus of 10), the
player's Active Spot is empty, and `flier` and its Fire Energy are in the player's hand. -/
def r2 : GameState :=
  ({ r1 with
      cur := { r1.cur with active := none, hand := [.pokemon flier, .energy .fire] },
      opp := { r1.opp with active := some { InPlay.ofBasic big with damage := 2 } } } : GameState).afterAttack
    .none false

theorem r1_r2 : Move r1 r2 := by
  have hr : Run fadeOut.script r1 _ :=
    .seq (.damage (.const 1 _) rfl) (.zone (w := .own) rfl (.monActive rfl (.hand _ _)))
  have m : Move r1 _ :=
    Move.attackOpen (atk := fadeOut) rfl (.head _) (.nil _) rfl rfl rfl rfl r1_settled hr rfl
      (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl
  exact m

/-- After the batch step: the Benched `big` is promoted to the empty Active Spot; no Pokémon was
Knocked Out, so no Prize card is taken. -/
def r3 : GameState :=
  r2.afterBatch (some (InPlay.ofBasic big)) [] (some { InPlay.ofBasic big with damage := 2 }) []

theorem r2_r3 : Move r2 r3 :=
  Move.knockOuts_of_nil (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide)) rfl
    (.pick (b₁ := []) (b₂ := [])) .keep) rfl

theorem r3_settled : Settled r3 := (GameState.settled_iff _).2 (by decide)

/-- The second player's turn passes (no attack), and the first player draws. -/
def r5 : GameState := startT (endT (startT (endT r3)))

theorem r3_r5 : Reach r3 r5 := by
  have m1 : Move r3 (endT r3) := endT_move rfl rfl r3_settled.1 rfl (by decide) (by decide)
  have s2 : Settled (endT r3) := (GameState.settled_iff _).2 (by decide)
  have m2 : Move (endT r3) (startT (endT r3)) := startT_move rfl rfl rfl s2.1 rfl
  have s3 : Settled (startT (endT r3)) := (GameState.settled_iff _).2 (by decide)
  have m3 : Move (startT (endT r3)) (endT (startT (endT r3))) :=
    endT_move rfl rfl s3.1 rfl (by decide) (by decide)
  have s4 : Settled (endT (startT (endT r3))) := (GameState.settled_iff _).2 (by decide)
  have m4 : Move (endT (startT (endT r3))) r5 := startT_move rfl rfl rfl s4.1 rfl
  exact .step (.step (.step (.step (.refl _) rfl m1) rfl m2) rfl m3) rfl m4

theorem r5_facts : r5.curIsFirst = true ∧ r5.between = false ∧ r5.attacked = false ∧
    r5.cur.hand = [.energy .grass, .pokemon flier, .energy .fire] ∧ r5.cur.bench = [] ∧
    r5.cur.mods.now.bonus = 0 := by decide

theorem r5_settled : Settled r5 := (GameState.settled_iff _).2 (by decide)

/-- `flier` is played again from the hand onto the Bench: a new Pokémon, with no damage and unused. -/
def r6 : GameState :=
  { r5 with cur := { r5.cur with
      hand := [.energy .grass] ++ [.energy .fire]
      bench := r5.cur.bench ++ [InPlay.ofBasic flier] } }

theorem r5_r6 : Move r5 r6 := by
  have m : Move r5 _ :=
    .playBasic (l₁ := [.energy .grass]) (l₂ := [.energy .fire]) (p := flier) rfl rfl (by decide)
      (by decide) rfl r5_settled rfl
  exact m

theorem r6_settled : Settled r6 :=
  settled_of rfl rfl (show 0 < 10 by decide) (show 2 < 10 by decide)
    (fun p hp => by
      have : r6.cur.bench = [InPlay.ofBasic flier] := by
        show r5.cur.bench ++ _ = _; rw [r5_facts.2.2.2.2.1]; rfl
      rw [this, List.mem_singleton] at hp
      subst hp; decide)
    (fun p hp => by
      have : r6.opp.bench = [] := by decide
      rw [this] at hp; cases hp)

/-- `flier` uses Charge again, from the Bench: this turn's bonus is 1 again. -/
def r7 : GameState :=
  { r6 with cur := { r6.cur with
      bench := [] ++ (InPlay.ofBasic flier).markUsed :: []
      mods := r6.cur.mods.add .now (.bonus 1) } }

theorem r6_r7 : Move r6 r7 := by
  have s7 : Settled r7 :=
    settled_of rfl rfl (show 0 < 10 by decide) (show 2 < 10 by decide)
      (fun p hp => by
        have : r7.cur.bench = [(InPlay.ofBasic flier).markUsed] := rfl
        rw [this, List.mem_singleton] at hp; subst hp; decide)
      (fun p hp => by
        have : r7.opp.bench = [] := by decide
        rw [this] at hp; cases hp)
  have m : Move r6 _ :=
    .ability (ab := charge) (.bench (b₁ := []) (b₂ := []) (by
        show r5.cur.bench ++ [InPlay.ofBasic flier] = _
        rw [r5_facts.2.2.2.2.1])) (.head _) rfl rfl (fun _ => rfl) trivial rfl r6_settled rfl
      (.prim rfl rfl (.linger .own .now (.bonus 1) _) (.done (.inl s7))) rfl rfl
  exact m

theorem reach_trans {a b c : GameState} (h₁ : Reach a b) (h₂ : Reach b c) : Reach a c := by
  induction h₂ with
  | refl => exact h₁
  | step _ hw hm ih => exact .step ih hw hm

/-- **The trace** (from the well-formed, `Settled` start `r0`; every state reached by legal moves):
`flierA` uses Charge (this turn's bonus becomes 1), attacks with Fade Out (the defender takes 2
counters, 10 damage plus the bonus; `flier` and its Fire Energy go to the hand, its 2 damage counters
with it out of the game's state; the Active Spot is empty); the batch step promotes the Benched `big`
and nobody takes a Prize card; the turns pass; the player plays `flier` again from the hand (a new
Pokémon: no damage, unused, put into play this turn) and it uses Charge again, from the Bench, in a
later turn of the same player. So the model lets a returned Pokémon write the store again; what it
does not allow is a return outside an attack (`Effect.retFree`), so the second use is in another
turn. -/
theorem trace : WellFormed r0 ∧ Settled r0 ∧ Move r0 r1 ∧ Move r1 r2 ∧ Move r2 r3 ∧ Reach r3 r5 ∧
    Move r5 r6 ∧ Move r6 r7 ∧ Reach r0 r7 ∧
    r1.cur.mods.now.bonus = 1 ∧
    r2.cur.active = none ∧ r2.cur.hand = [.pokemon flier, .energy .fire] ∧
    r2.opp.active.map InPlay.damage = some 2 ∧
    r3.cur.active = some (InPlay.ofBasic big) ∧ r3.cur.prizes = r2.cur.prizes ∧
    r3.opp.prizes = r2.opp.prizes ∧ r3.winner = none ∧
    r6.cur.bench = [InPlay.ofBasic flier] ∧
    r7.curIsFirst = r0.curIsFirst ∧ r7.cur.mods.now.bonus = 1 ∧
    r7.cur.bench.map InPlay.used = [true] := by
  have hr : Reach r0 r7 :=
    .step (.step (reach_trans (.step (.step (.step (.refl _) rfl r0_r1) rfl r1_r2) rfl r2_r3) r3_r5)
      rfl r5_r6) rfl r6_r7
  refine ⟨r0_wf, r0_settled, r0_r1, r1_r2, r2_r3, r3_r5, r5_r6, r6_r7, hr, by decide, rfl, rfl, rfl,
    rfl, by decide, by decide, by decide, ?_, by decide, by decide, ?_⟩
  · show r5.cur.bench ++ _ = _; rw [r5_facts.2.2.2.2.1]; rfl
  · rfl

/-! ## To the deck; the opponent's Pokémon; no Pokémon left -/

/-- **Witness: to the deck.** From `r0`, Jumping Shot is a legal move after which `flier` and its
Fire Energy are on top of the player's deck (the shuffle read as any order, here this one), the
Active Spot is empty, and the player has the same cards (`Reach.perm`). -/
theorem return_deck : WellFormed r0 ∧ Settled r0 ∧ ∃ g, Move r0 g ∧ g.cur.active = none ∧
    g.cur.deck = [.pokemon flier, .energy .fire] ++ deck3 ∧ g.cur.hand = [] := by
  have hr : Run jump.script r0 _ :=
    .seq (.damage (.const 1 _) rfl)
      (.zone (w := .own) rfl (.monActive rfl (.shuffle (d := [.pokemon flier, .energy .fire] ++ deck3) _
        (List.Perm.refl _))))
  exact ⟨r0_wf, r0_settled, _, Move.attackOpen (atk := jump) rfl (.tail _ (.head _)) (.nil _) rfl rfl
    rfl rfl r0_settled hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl,
    rfl, rfl, rfl⟩

/-- **Witness: the opponent's Benched Pokémon into their deck** (from `o0`): their Bench is empty
afterwards and the card is in their deck; their Active Pokémon is untouched. -/
theorem return_opp_bench : WellFormed o0 ∧ Settled o0 ∧ ∃ g, Move o0 g ∧ g.opp.bench = [] ∧
    g.opp.deck = [.pokemon big] ++ deck3 ∧ g.opp.active = o0.opp.active := by
  have hr : Run perfume.script o0 _ :=
    .zone (w := .opp) rfl (.monBench (b₁ := []) (b₂ := []) rfl
      (.shuffle (d := [.pokemon big] ++ deck3) _ (List.Perm.refl _)))
  exact ⟨o0_wf, o0_settled, _, Move.attackOpen (atk := perfume) rfl (.tail _ (.tail _ (.head _)))
    (.nil _) rfl rfl rfl rfl o0_settled hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl)
    (.nil _) rfl, rfl, rfl, rfl⟩

/-- After Snatch from `o0`: the opponent's Active `big` is in their hand, their Active Spot empty. -/
def s1 : GameState :=
  ({ o0 with opp := { o0.opp with active := none, hand := [.pokemon big] } } : GameState).afterAttack
    .none false

theorem o0_s1 : Move o0 s1 := by
  have hr : Run snatch.script o0 _ := .zone (w := .opp) rfl (.monActive rfl (.hand _ _))
  have m : Move o0 _ := Move.attackOpen (atk := snatch) rfl (.tail _ (.tail _ (.tail _ (.head _))))
    (.nil _) rfl rfl rfl rfl o0_settled hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl)
    (.nil _) rfl
  exact m

/-- **Witness: the opponent's Active Pokémon to their hand, and the opponent refills.** From `o0`,
Snatch empties the opponent's Active Spot; the next move is the batch step, which promotes the
opponent's Benched `big` with no Knock Out and no Prize card taken by either player, and the game
goes on. (Who chooses the Pokémon promoted is not modelled: `Promote` is a nondeterministic choice,
which covers the owner's.) -/
theorem opp_refill : WellFormed o0 ∧ Settled o0 ∧ Move o0 s1 ∧ s1.opp.active = none ∧
    s1.opp.hand = [.pokemon big] ∧
    ∃ g, Move s1 g ∧ g.opp.active = some (InPlay.ofBasic big) ∧ g.opp.bench = [] ∧
      g.cur.prizes = o0.cur.prizes ∧ g.opp.prizes = o0.opp.prizes ∧ g.winner = none ∧ Settled g :=
  ⟨o0_wf, o0_settled, o0_s1, rfl, rfl, _,
    Move.knockOuts_of_nil (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide)) rfl .keep
      (.pick (b₁ := []) (b₂ := []))) rfl, rfl, rfl, rfl, rfl, rfl,
    (GameState.settled_iff _).2 (by decide)⟩

/-- **Witness: the player's own Active Spot refilled** (in the trace, `r2 → r3`): no Prize card
for either player, the Benched Pokémon promoted, the game going on, the state `Settled`. -/
theorem refill : Move r2 r3 ∧ r2.cur.active = none ∧ r3.cur.active = some (InPlay.ofBasic big) ∧
    r3.cur.bench = [] ∧ r3.cur.prizes = r2.cur.prizes ∧ r3.opp.prizes = r2.opp.prizes ∧
    r3.winner = none ∧ Settled r3 :=
  ⟨r2_r3, rfl, rfl, rfl, rfl, rfl, rfl, r3_settled⟩

/-- The first player alone in play: `flierA` Active, an empty Bench. -/
def z0 : GameState :=
  ⟨{ side [] [.energy .fire] flierA [] with deck := deck3 },
    { side [] [.energy .fire] (InPlay.ofBasic big) [] with deck := deck3 },
    true, false, false, false, none, none, false, false, false⟩

theorem z0_wf : WellFormed z0 := by
  refine ⟨fun _ => ⟨by simp [z0, side], by simp [z0, side]⟩, ?_, ?_, .of_b rfl⟩ <;> intro p hp <;>
    cases hp

theorem z0_settled : Settled z0 :=
  settled_of rfl rfl (show 2 < 10 by decide) (show 0 < 10 by decide) (fun p hp => by cases hp)
    (fun p hp => by cases hp)

/-- **Witness: a player who returns their only Pokémon loses** at the batch step that follows (the
rulebook's "If your opponent doesn't have any more Pokémon in play, you win the game!", 2026 p. 7;
read at the batch step, as "has no Benched Pokémon to replace their Active Pokémon if it is Knocked
Out (or otherwise removed from play)", p. 21). The first player (`curIsFirst`) moves; the outcome is
a win for the second player (`Outcome.win false`). -/
theorem no_pokemon_loses : WellFormed z0 ∧ Settled z0 ∧ ∃ g g', Move z0 g ∧ g.cur.active = none ∧
    g.cur.bench = [] ∧ Move g g' ∧ g'.winner = some (.win false) := by
  have hr : Run fadeOut.script z0 _ :=
    .seq (.damage (.const 1 _) rfl) (.zone (w := .own) rfl (.monActive rfl (.hand _ _)))
  have m : Move z0 _ := Move.attackOpen (atk := fadeOut) rfl (.head _) (.nil _) rfl rfl rfl rfl
    z0_settled hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl
  exact ⟨z0_wf, z0_settled, _, _, m, rfl, rfl,
    Move.knockOuts_of_nil (.won (fun h => absurd ((GameState.calm_iff _).1 h) (by decide))
      (by decide)) rfl, rfl⟩

/-! ## General statements, every resolution -/

/-- **A return from the Active Spot empties it** and leaves the Bench as it was, in every resolution
in every state. -/
theorem monActive_empties {w : Whose} {d : Dst} {s s' : PlayerState}
    (h : ZStep (.returnPokemon w .active d) s s') : s'.active = none ∧ s'.bench = s.bench := by
  cases h with
  | monActive _ hp => exact ⟨hp.fields.2.1, hp.fields.2.2⟩

/-- **To the hand, the Pokémon's cards are exactly what is added to the hand**: its top card, the
cards under it, its attached Energy and Tools (`InPlay.cardList`), and nothing else of it (damage
counters, Special Conditions, markers have no card), in every resolution. -/
theorem monActive_hand {w : Whose} {s s' : PlayerState} {a : InPlay} (ha : s.active = some a)
    (h : ZStep (.returnPokemon w .active .hand) s s') :
    s'.hand = a.cardList ++ s.hand ∧ s'.deck = s.deck ∧ s'.discard = s.discard := by
  cases h with
  | monActive ha' hp =>
      rw [ha] at ha'; cases ha'
      cases hp; exact ⟨rfl, rfl, rfl⟩

/-! ## Why outside an attack it is excluded (negative; hand-built states) -/

/-- A **hand-built** state (not shown reachable): the player to move has a Pokémon put into play this
turn that has used its Ability (`fresh`, `used`), Active, with `big` on the Bench. -/
def h0 : GameState :=
  ⟨side [] [.energy .fire] { InPlay.ofBasic flier with used := true } [InPlay.ofBasic big],
    side [] [.energy .fire] (InPlay.ofBasic big) [], true, false, false, false, none, none, false,
    false, false⟩

/-- **A return raises the potential** `GameState.abPot` on which the store bound's count of Ability
uses rests (hand-built `h0`): the used, fresh Pokémon weighs nothing and its place weighs two. So
`ZStep.abPot_le` and `Run.abPot_le` are false without their hypothesis `Effect.retFree`. -/
theorem return_raises_abPot :
    ∃ g', Run (.returnPokemon .own .active .hand) h0 g' ∧ h0.abPot < g'.abPot :=
  ⟨_, .zone (w := .own) rfl (.monActive rfl (.hand _ _)), by decide⟩

/-- **…and so does its resolution as a Trainer or Ability effect would resolve it** (`TRun`, with the
Knock Out check and the promotion it forces; hand-built `h0`): the game goes on and the potential
has risen by 2. So `TRun.abPot_le` is false without `Effect.retFree`, and the per-turn invariant's
`pot` clause (`TInv.pot`) would fail for a non-attack move resolving a return: a play–use–return
loop would leave the potential where it was while its uses add up. The moves that resolve a `TRun`
refuse such an effect (`Effect.retFree` premise), so no legal move does this; a loop that grows a
store within one turn is therefore not expressible in the model, and is argued, not built (survey
S29 §6). -/
theorem trun_raises_abPot :
    ∃ g', TRun (.returnPokemon .own .active .hand) h0 g' ∧ g'.winner = none ∧ h0.abPot + 2 = g'.abPot :=
  ⟨_, .prim rfl rfl (.zone (w := .own) rfl (.monActive rfl (.hand _ _)))
    (.step rfl (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide)) rfl
      (.pick (b₁ := []) (b₂ := [])) .keep)
      (.done (.inl ((GameState.settled_iff _).2 (by decide))))), rfl, by decide⟩

end Pokemon.Return
