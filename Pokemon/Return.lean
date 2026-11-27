import Pokemon.Lock
import Pokemon.StoreSafe
import Pokemon.Shield
import Pokemon.TriggerWitness

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
reached from `r0`): `return_hand` (to the hand, with the attached Energy; the Active Spot empty),
`return_deck` (shuffled into the deck), `return_opp_bench` (the opponent's Benched Pokémon into their
deck), `opp_refill` (the opponent's Active Pokémon to their hand, and the opponent promotes with no
Prize card taken), `refill` (the player's own Active Spot refilled, no Prize card), `no_pokemon_loses`
(a player who returns their only Pokémon loses at the batch step: every move from there is that
step), `trace` (above). **General**
(every resolution): `monActive_empties`, `monActive_hand`, `HitTrig.nil_of_empty` (a defender returned
by the attack fires no `damaged` trigger). **Negative** (hand-built starts, labelled):
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
counters, 10 damage plus the bonus; `flier` and its Fire Energy go to the hand; the Active Spot is
empty, so `flierA`'s 2 damage counters are on no Pokémon in play, which is all the conjuncts below
say of them); the batch step promotes the Benched `big`
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

/-- **Witness: to the hand.** From `r0`, Fade Out is a legal move after which the player's hand holds
exactly `flier` and its Fire Energy (the hand was empty), the Active Spot is empty, the Bench is as it
was, and the defender has the attack's 1 damage counter. `flierA`'s 2 damage counters are on no
Pokémon in play afterwards: its record left the Active Spot, and the hand holds cards, which carry no
damage. -/
theorem return_hand : WellFormed r0 ∧ Settled r0 ∧ ∃ g, Move r0 g ∧ g.cur.active = none ∧
    g.cur.hand = [.pokemon flier, .energy .fire] ∧ g.cur.bench = r0.cur.bench ∧
    g.opp.active.map InPlay.damage = some 1 := by
  have hr : Run fadeOut.script r0 _ :=
    .seq (.damage (.const 1 _) rfl) (.zone (w := .own) rfl (.monActive rfl (.hand _ _)))
  exact ⟨r0_wf, r0_settled, _, Move.attackOpen (atk := fadeOut) rfl (.head _) (.nil _) rfl rfl
    rfl rfl r0_settled hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl,
    rfl, rfl, rfl, rfl⟩

/-- **Witness: to the deck.** From `r0`, Jumping Shot is a legal move after which `flier` and its
Fire Energy are on top of the player's deck (the shuffle read as any order, here this one), the
Active Spot is empty and the hand empty. (That every move keeps the multiset of the player's cards is
the general `Reach.perm`; it is not restated here.) -/
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

/-- After Fade Out from `z0`: the player's only Pokémon is in the hand. -/
def z1 : GameState :=
  ({ z0 with
      cur := { z0.cur with active := none, hand := [.pokemon flier, .energy .fire] },
      opp := { z0.opp with active := some { InPlay.ofBasic big with damage := 1 } } } : GameState).afterAttack
    .none false

theorem z0_z1 : Move z0 z1 := by
  have hr : Run fadeOut.script z0 _ :=
    .seq (.damage (.const 1 _) rfl) (.zone (w := .own) rfl (.monActive rfl (.hand _ _)))
  have m : Move z0 _ := Move.attackOpen (atk := fadeOut) rfl (.head _) (.nil _) rfl rfl rfl rfl
    z0_settled hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl
  exact m

/-- **Witness: a player who returns their only Pokémon loses** at the batch step that follows (the
rulebook's "If your opponent doesn't have any more Pokémon in play, you win the game!", 2026 p. 7;
read at the batch step, as "has no Benched Pokémon to replace their Active Pokémon if it is Knocked
Out (or otherwise removed from play)", p. 21). From `z0` (proved `WellFormed` and `Settled`) Fade Out
leaves the first player (`curIsFirst`) with no Pokémon in play (`z1`), and **every** move from `z1` is
the batch step, whose result is the check `z1.koStep`, a win for the second player
(`Outcome.win false`). -/
theorem no_pokemon_loses : WellFormed z0 ∧ Settled z0 ∧ Move z0 z1 ∧ z1.cur.active = none ∧
    z1.cur.bench = [] ∧ (∃ g', Move z1 g') ∧
    ∀ g', Move z1 g' → g' = z1.koStep ∧ g'.winner = some (.win false) := by
  have hwin : z1.koStep.winner = some (.win false) := by decide
  have hnc : ¬ Calm z1 := fun h => absurd ((GameState.calm_iff _).1 h) (by decide)
  refine ⟨z0_wf, z0_settled, z0_z1, rfl, rfl,
    ⟨_, Move.knockOuts_of_nil (.won hnc (by rw [hwin]; exact Option.some_ne_none _)) rfl⟩, ?_⟩
  intro g' hm
  rcases Move.after_attack_passTurn hm rfl rfl with ⟨g₁, l, hk, hl, hf⟩ | ⟨hb, -, -⟩ | ⟨_, b, _, _, _, _, _, _, _, _, _, _, _, hb, _⟩
  · have hg₁ : g₁ = z1.koStep := by
      cases hk with
      | won => rfl
      | go _ hw => rw [hwin] at hw; cases hw
    subst hg₁
    have hl' : l = [] := by
      rw [GameState.batchTrigs_of_won (by rw [hwin]; exact Option.some_ne_none _)] at hl
      exact List.Perm.eq_nil hl
    subst hl'
    cases hf
    exact ⟨rfl, hwin⟩
  · exact absurd hb.1 (by decide)
  · have : z1.cur.active = none := rfl
    rw [this] at hb; cases hb

/-- **A defender returned from play fires no `damaged` trigger**: if the opponent's Active Spot is empty
when the attack's resolution ends, the attack's `damaged` triggers are none, whatever the damage step
did (`HitTrig.fire` takes the triggers of the Pokémon in the opponent's Active Spot at the end of the
resolution, `optTrigs .damaged none = []`). Inside an attack no primitive puts a Pokémon into the
opponent's empty Active Spot (`switch` needs an Active Pokémon; argued from the `Run` constructors, not
stated as a theorem), so a `returnPokemon .opp .active` leaves it empty to the end. -/
theorem _root_.Pokemon.HitTrig.nil_of_empty {atk : Attack} {g g' : GameState} {l : List Ability}
    (h : HitTrig atk g g' l) (he : g'.opp.active = none) : l = [] := by
  cases h with
  | quiet => rfl
  | fire _ hl =>
      rw [he] at hl
      exact List.Perm.eq_nil hl

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

/-! ## No return card, no change (milestone MV15)

Every definition MV15 changed differs from its old form only on effects that contain
`returnPokemon`, and the five move constructors that gained the premise `Effect.retFree` have exactly
their old premises in a game none of whose cards has such an effect (`GameState.RetFree`, kept by play:
`Reach.retFree`). The three new `ZStep` constructors have the effect index `returnPokemon _ _ _`, so no
resolution of an effect without it uses them (by inspection of the inductive; `retFree_not_return`). `Move.attack` reads three changed
definitions (`Attack.wf`, `Attack.lockSet`, `Attack.against`), equal to their old forms for an attack
with no return (`attack_old`), and every attack of such a game has none (`attack_retFree`). This is
proved in pieces: no copy of the pre-MV15 `Move`, `Run`, `ZStep` was made, so there is no single
equivalence theorem. -/

/-- No effect of the card (a Trainer's effect, any script of its or a granted Ability, any attack's
effect) contains `returnPokemon`. -/
def _root_.Pokemon.Card.retFree (c : Card) : Bool :=
  (match c with | .trainer _ _ e _ => e.retFree | _ => true) &&
    c.abilities.all (fun ab => ab.scripts.all Effect.retFree) &&
    c.attacks.all (fun atk => atk.effect.retFree)

/-- No card of the game has a return from play. -/
def _root_.Pokemon.GameState.RetFree (g : GameState) : Prop := ∀ c ∈ g.allCards, c.retFree = true

theorem _root_.Pokemon.Reach.retFree {g₀ g : GameState} (h : Reach g₀ g) (h₀ : g₀.RetFree) :
    g.RetFree := fun c hc => h₀ c (h.perm.mem_iff.1 hc)

theorem trainer_retFree {g : GameState} {n : String} {k : TrainerKind} {e : Effect} {ss : List Static}
    (hR : g.RetFree) (hc : Card.trainer n k e ss ∈ g.allCards) : e.retFree = true := by
  have := hR _ hc
  simp only [Card.retFree, Bool.and_eq_true] at this
  exact this.1.1

theorem ability_retFree {g : GameState} {c : Card} {ab : Ability} (hR : g.RetFree)
    (hc : c ∈ g.allCards) (hm : ab ∈ c.abilities) (p : Option Spot) : (ab.script p).retFree = true := by
  have := hR _ hc
  simp only [Card.retFree, Bool.and_eq_true, List.all_eq_true] at this
  exact this.1.2 ab hm _ (ab.script_mem p)

/-- **`Move.item` with its pre-MV15 premises**, in a game with no return card. -/
theorem _root_.Pokemon.Move.item_old {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
    (hR : g.RetFree)
    (hh : g.cur.hand = l₁ ++ Card.trainer n .item e :: l₂) (hbt : g.between = false)
    (hst : Settled g)
    (hr : TRun e { g with cur := { g.cur with
      hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } g')
    (hl : g.cur.mods.live.noItem = false) (hat : g.attacked = false)
    (hnd : e.hitFree = true) (hbh : e.benchHitFree = true) : Move g g' :=
  .item hh hbt hst hr hl hat hnd hbh
    (trainer_retFree (n := n) (k := .item) (ss := []) hR (GameState.mem_allCards_of_hand (by rw [hh]; simp)))

/-- **`Move.supporter` with its pre-MV15 premises**, in a game with no return card. -/
theorem _root_.Pokemon.Move.supporter_old {g g' : GameState} {l₁ l₂ : List Card} {n : String}
    {e : Effect} (hR : g.RetFree)
    (hh : g.cur.hand = l₁ ++ Card.trainer n .supporter e :: l₂)
    (hs : g.cur.supporterPlayed = false) (hbt : g.between = false) (hst : Settled g)
    (hr : TRun e { g with cur := { g.cur with
      hand := l₁ ++ l₂, supporterPlayed := true, supCard := some (Card.trainer n .supporter e),
      discard := Card.trainer n .supporter e :: g.cur.discard } } g')
    (hat : g.attacked = false) (hf : g.firstTurn = false) (hnd : e.hitFree = true)
    (hbh : e.benchHitFree = true) : Move g g' :=
  .supporter hh hs hbt hst hr hat hf hnd hbh
    (trainer_retFree (n := n) (k := .supporter) (ss := []) hR (GameState.mem_allCards_of_hand (by rw [hh]; simp)))

/-- **`Move.stadiumUse` with its pre-MV15 premises**, in a game with no return card. -/
theorem _root_.Pokemon.Move.stadiumUse_old {g g' : GameState} {o : Bool} {n : String} {e : Effect}
    {ss : List Static} (hR : g.RetFree)
    (hs : g.stadium = some (o, Card.trainer n .stadium e ss)) (hu : g.stadiumUsed = false)
    (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false)
    (hr : TRun e { g with stadiumUsed := true } g') (hnd : e.hitFree = true)
    (hbh : e.benchHitFree = true) : Move g g' :=
  .stadiumUse hs hu hbt hst hat hr hnd hbh (trainer_retFree hR (GameState.mem_allCards_of_stadium hs))

/-- **`Move.ability` with its pre-MV15 premises**, in a game with no return card. -/
theorem _root_.Pokemon.Move.ability_old {g g₁ g' : GameState} {x : InPlay} {sp : Spot} {ab : Ability}
    (hR : g.RetFree)
    (hu : UseAt g x sp g₁) (hm : ab ∈ x.abilities) (hk : ab.use.activated = true)
    (hsp : ab.spotOk sp = true) (hn : ab.use = .once → x.used = false) (hc : ab.CondOk g)
    (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false)
    (hr : TRun (ab.script (some sp)) g₁ g') (hnd : (ab.script (some sp)).hitFree = true)
    (hbh : (ab.script (some sp)).benchHitFree = true) : Move g g' := by
  obtain ⟨c, hcx, hmc⟩ := InPlay.ability_mem hm
  exact .ability hu hm hk hsp hn hc hbt hst hat hr hnd hbh
    (ability_retFree hR (hu.card_mem hcx) hmc _)

/-- **`Move.onPlay` with its pre-MV15 premises**, in a game with no return card. -/
theorem _root_.Pokemon.Move.onPlay_old {g g₁ g' : GameState} {x : InPlay} {how w : PlayWay}
    {ab : Ability} (hR : g.RetFree)
    (hp : PlayFromHand g x how g₁) (hm : ab ∈ x.top.abilities) (hk : ab.use = .onPlay w)
    (hw : w.fires how = true) (hst : Settled g₁) (hc : ab.CondOk g₁)
    (hr : TRun (ab.script none) g₁ g') (hnd : (ab.script none).hitFree = true)
    (hbh : (ab.script none).benchHitFree = true) : Move g g' :=
  .onPlay hp hm hk hw hst hc hr hnd hbh
    (ability_retFree (c := .pokemon x.top) hR hp.top_mem hm _)

/-- `Effect.switchesOwn` before milestone MV15. -/
def switchesOwnOld : Effect → Bool
  | .switch .own => true
  | .ite _ a b => switchesOwnOld a || switchesOwnOld b
  | .seq a b => switchesOwnOld a || switchesOwnOld b
  | .choice a b => switchesOwnOld a || switchesOwnOld b
  | .iter a => switchesOwnOld a
  | _ => false

/-- `Effect.spares` before milestone MV15. -/
def sparesOld : Effect → Bool
  | .inflict _ => false
  | .poisonUp _ => false
  | .switch .opp => false
  | .ite _ a b => sparesOld a && sparesOld b
  | .seq a b => sparesOld a && sparesOld b
  | .choice a b => sparesOld a && sparesOld b
  | .iter a => sparesOld a
  | _ => true

theorem switchesOwn_old : ∀ {e : Effect}, e.retFree = true → e.switchesOwn = switchesOwnOld e
  | .ite _ a b, h | .seq a b, h | .choice a b, h => by
      simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.switchesOwn, switchesOwnOld, switchesOwn_old h.1, switchesOwn_old h.2]
  | .iter a, h => by
      simp only [Effect.retFree] at h
      simp only [Effect.switchesOwn, switchesOwnOld, switchesOwn_old h]
  | .returnPokemon _ _ _, h => by simp [Effect.retFree] at h
  | .switch w, _ => by cases w <;> rfl
  | .skip, _ | .draw, _ | .heal _, _ | .counters _, _ | .inflict _, _ | .poisonUp _, _
  | .cure, _ | .shuffle, _ | .search, _ | .handToBottom, _ | .scale _ _, _
  | .selfDamage _, _ | .healAll, _ | .mark _ _, _ | .unmark _ _, _ | .color _ _, _
  | .linger _ _ _, _ | .benchCounters _ _, _ | .spreadCounters _ _, _ | .benchHeal _, _
  | .benchDamage _ _, _ | .spreadDamage _ _, _ | .damage _ _, _ | .drain _, _
  | .move _ _ _ _ _, _ | .drawTo _ _, _ | .attach _ _ _ _ _, _ | .putBench _ _ _, _
  | .discardEnergy _ _ _ _, _ | .moveEnergy _ _, _ | .returnEnergy _ _ _ _ _, _
  | .shiftEnergy _ _ _ _ _ _, _
  | .moveCounter _ _, _ | .discardStadium, _
  | .discardTools _ _, _ | .benchSome _ _ _ _ _, _ | .look _ _ _ _ _ _, _
  | .benchHealSome _ _ _, _ | .hitBy _ _ _ _ _ _ _, _ | .dumpCounters _ _, _ => rfl

theorem spares_old : ∀ {e : Effect}, e.retFree = true → e.spares = sparesOld e
  | .ite _ a b, h | .seq a b, h | .choice a b, h => by
      simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.spares, sparesOld, spares_old h.1, spares_old h.2]
  | .iter a, h => by
      simp only [Effect.retFree] at h
      simp only [Effect.spares, sparesOld, spares_old h]
  | .returnPokemon _ _ _, h => by simp [Effect.retFree] at h
  | .switch w, _ => by cases w <;> rfl
  | .skip, _ | .draw, _ | .heal _, _ | .counters _, _ | .inflict _, _ | .poisonUp _, _
  | .cure, _ | .shuffle, _ | .search, _ | .handToBottom, _ | .scale _ _, _
  | .selfDamage _, _ | .healAll, _ | .mark _ _, _ | .unmark _ _, _ | .color _ _, _
  | .linger _ _ _, _ | .benchCounters _ _, _ | .spreadCounters _ _, _ | .benchHeal _, _
  | .benchDamage _ _, _ | .spreadDamage _ _, _ | .damage _ _, _ | .drain _, _
  | .move _ _ _ _ _, _ | .drawTo _ _, _ | .attach _ _ _ _ _, _ | .putBench _ _ _, _
  | .discardEnergy _ _ _ _, _ | .moveEnergy _ _, _ | .returnEnergy _ _ _ _ _, _
  | .shiftEnergy _ _ _ _ _ _, _
  | .moveCounter _ _, _ | .discardStadium, _
  | .discardTools _ _, _ | .benchSome _ _ _ _ _, _ | .look _ _ _ _ _ _, _
  | .benchHealSome _ _ _, _ | .hitBy _ _ _ _ _ _ _, _ | .dumpCounters _ _, _ => rfl

/-- Shielding keeps `retFree` (an effect with no return shields to one with none). That the shielded
effect is the pre-MV15 one is `shielded_old`. -/
theorem shielded_retFree (e : Effect) : e.retFree = true → e.shielded.retFree = true := by
  induction e with
  | ite t a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.shielded, Effect.retFree, iha h.1, ihb h.2, Bool.and_self]
  | seq a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.shielded, Effect.retFree, iha h.1, ihb h.2, Bool.and_self]
  | choice a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.shielded, Effect.retFree, iha h.1, ihb h.2, Bool.and_self]
  | iter a iha =>
      intro h; simp only [Effect.retFree] at h
      simp only [Effect.shielded, Effect.retFree, iha h]
  | returnPokemon => intro h; simp [Effect.retFree] at h
  | _ => intro _; unfold Effect.shielded; (try split) <;> simp_all [Effect.retFree]

/-- `Effect.ownFree` before milestone MV15. -/
def ownFreeOld : Effect → Bool
  | .heal _ => false
  | .cure => false
  | .selfDamage _ => false
  | .healAll => false
  | .damage _ _ => false
  | .drain _ => false
  | .scale .own _ => false
  | .switch .own => false
  | .attach .own _ _ .active _ => false
  | .discardEnergy .own .active _ _ => false
  | .moveEnergy .own _ => false
  | .returnEnergy .own .active _ _ _ => false
  | .shiftEnergy .own _ _ _ _ _ => false
  | .moveCounter _ _ => false
  | .look .own _ _ _ (.attach _) _ => false
  | .hitBy .own .active _ _ _ _ _ => false
  | .ite t a b => !t.onOwn && ownFreeOld a && ownFreeOld b
  | .seq a b => ownFreeOld a && ownFreeOld b
  | .choice a b => ownFreeOld a && ownFreeOld b
  | .iter a => ownFreeOld a
  | _ => true

theorem ownFree_old (e : Effect) : e.retFree = true → e.ownFree = ownFreeOld e := by
  induction e with
  | ite t a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.ownFree, ownFreeOld, iha h.1, ihb h.2]
  | seq a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.ownFree, ownFreeOld, iha h.1, ihb h.2]
  | choice a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.ownFree, ownFreeOld, iha h.1, ihb h.2]
  | iter a iha =>
      intro h; simp only [Effect.retFree] at h
      simp only [Effect.ownFree, ownFreeOld, iha h]
  | returnPokemon => intro h; simp [Effect.retFree] at h
  | scale w => intro _; cases w <;> rfl
  | switch w => intro _; cases w <;> rfl
  | attach w _ _ sp => intro _; cases w <;> cases sp <;> rfl
  | discardEnergy w sp => intro _; cases w <;> cases sp <;> rfl
  | moveEnergy w => intro _; cases w <;> rfl
  | returnEnergy w sp => intro _; cases w <;> cases sp <;> rfl
  | shiftEnergy w => intro _; cases w <;> rfl
  | look w _ _ _ i => intro _; cases w <;> cases i <;> rfl
  | hitBy w sp => intro _; cases w <;> cases sp <;> rfl
  | _ => intro _; rfl

/-- `Effect.shielded` before milestone MV15 (copied from d6cb457). -/
def shieldedOld : Effect → Effect
  | .counters _ => .skip
  | .inflict _ => .skip
  | .poisonUp _ => .skip
  | .scale _ _ => .skip
  | .switch .opp => .skip
  | .mark .opp _ => .skip
  | .color .opp _ => .skip
  | .linger .opp _ (.lock .attack) => .skip
  | .linger .opp _ (.lock .retreat) => .skip
  | .linger .opp _ (.weaken _) => .skip
  | .linger .opp _ (.expose _) => .skip
  | .discardEnergy .opp .active _ _ => .skip
  | .discardTools .opp .active => .skip
  | .attach .opp _ _ .active _ => .skip
  | .moveEnergy .opp _ => .skip
  | .returnEnergy .opp .active _ _ _ => .skip
  | .shiftEnergy .opp _ _ _ _ _ => .skip
  | .hitBy .opp .active _ _ _ _ _ => .skip
  | .dumpCounters _ .active => .skip
  | .ite t a b => .ite t (shieldedOld a) (shieldedOld b)
  | .seq a b => .seq (shieldedOld a) (shieldedOld b)
  | .choice a b => .choice (shieldedOld a) (shieldedOld b)
  | .iter a => .iter (shieldedOld a)
  | e => e

/-- **`Effect.shielded` is the pre-MV15 function on effects with no return.** -/
theorem shielded_old (e : Effect) : e.retFree = true → e.shielded = shieldedOld e := by
  induction e with
  | ite t a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.shielded, shieldedOld, iha h.1, ihb h.2]
  | seq a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.shielded, shieldedOld, iha h.1, ihb h.2]
  | choice a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.shielded, shieldedOld, iha h.1, ihb h.2]
  | iter a iha =>
      intro h; simp only [Effect.retFree] at h
      simp only [Effect.shielded, shieldedOld, iha h]
  | returnPokemon => intro h; simp [Effect.retFree] at h
  | switch w => intro _; cases w <;> rfl
  | mark w => intro _; cases w <;> rfl
  | color w => intro _; cases w <;> rfl
  | linger w sl m =>
      intro _
      cases w <;> cases m with
      | lock l => cases l <;> rfl
      | _ => rfl
  | discardEnergy w sp => intro _; cases w <;> cases sp <;> rfl
  | discardTools w sp => intro _; cases w <;> cases sp <;> rfl
  | attach w _ _ sp => intro _; cases w <;> cases sp <;> rfl
  | moveEnergy w => intro _; cases w <;> rfl
  | returnEnergy w sp => intro _; cases w <;> cases sp <;> rfl
  | shiftEnergy w => intro _; cases w <;> rfl
  | hitBy w sp => intro _; cases w <;> cases sp <;> rfl
  | dumpCounters _ sp => intro _; cases sp <;> rfl
  | _ => intro _; rfl

/-- `Effect.switchSafe` read with the pre-MV15 `switchesOwn` and `ownFree`. -/
def switchSafeOld : Effect → Bool
  | .ite _ a b => switchSafeOld a && switchSafeOld b
  | .seq a b => switchSafeOld a && switchSafeOld b && (!switchesOwnOld a || ownFreeOld b)
  | .choice a b => switchSafeOld a && switchSafeOld b
  | .iter a => switchSafeOld a && !switchesOwnOld a
  | _ => true

/-- **`Effect.switchSafe` is the pre-MV15 predicate on effects with no return.** -/
theorem switchSafe_old (e : Effect) : e.retFree = true → e.switchSafe = switchSafeOld e := by
  induction e with
  | ite t a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.switchSafe, switchSafeOld, iha h.1, ihb h.2]
  | seq a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.switchSafe, switchSafeOld, iha h.1, ihb h.2, switchesOwn_old h.1,
        ownFree_old b h.2]
  | choice a b iha ihb =>
      intro h; simp only [Effect.retFree, Bool.and_eq_true] at h
      simp only [Effect.switchSafe, switchSafeOld, iha h.1, ihb h.2]
  | iter a iha =>
      intro h; simp only [Effect.retFree] at h
      simp only [Effect.switchSafe, switchSafeOld, iha h, switchesOwn_old h]
  | _ => intro _; rfl

/-- An attack whose effect has no return has a script with none. -/
theorem script_retFree {atk : Attack} (h : atk.effect.retFree = true) : atk.script.retFree = true := by
  unfold Attack.script; split
  · exact h
  · simp only [Effect.retFree, h, Bool.and_self]

/-- **The premises of `Move.attack` that MV15 changed in meaning are the pre-MV15 ones** for an attack
with no return: well-formedness (`Attack.wf`, through `switchSafe`), the lock it sets
(`Attack.lockSet`, through `switchesOwn`), and the script resolved against a protected defender
(`Attack.against`, through `shielded`). -/
theorem attack_old {atk : Attack} (h : atk.effect.retFree = true) :
    atk.wf = (atk.effect.oneHit && (decide (atk.damage = 0) || atk.effect.hitFree) &&
      switchSafeOld atk.effect) ∧
    atk.lockSet = (if switchesOwnOld atk.script then .none else atk.selfLock) ∧
    (∀ b : Bool, (atk.against b).script = cond b (shieldedOld atk.script) atk.script) := by
  refine ⟨by simp only [Attack.wf, switchSafe_old _ h], by
    simp only [Attack.lockSet, switchesOwn_old (script_retFree h)], fun b => ?_⟩
  rw [Attack.against_script, shielded_old _ (script_retFree h)]

/-- An effect with no return is not a `returnPokemon` step. (That the three MV15 zone steps
`ZStep.monActive`, `monBench`, `monNone` are exactly the constructors with that index, so that no
zone step of an effect with `retFree` uses them, is read off the inductive, not a theorem.) -/
theorem retFree_not_return {e : Effect} (hr : e.retFree = true) :
    ∀ w sp d, e ≠ .returnPokemon w sp d := by
  rintro w sp d rfl; simp [Effect.retFree] at hr

/-- **Every attack of a game with no return card has no return** (the attack is on a card of the game:
`InPlay.attack_mem`). -/
theorem attack_retFree {g : GameState} {a : InPlay} {atk : Attack} (hR : g.RetFree)
    (ha : g.cur.active = some a) (hm : atk ∈ a.attacks) : atk.effect.retFree = true := by
  obtain ⟨c, hc, hmc⟩ := InPlay.attack_mem hm
  have := hR c (GameState.mem_allCards_of_cur_active ha hc)
  simp only [Card.retFree, Bool.and_eq_true, List.all_eq_true] at this
  exact this.2 atk hmc

/-! ## Triggers aimed at an attacker that has left play (fix round 2)

A `damaged` trigger of the Defending Pokémon resolves after the attack's script, on the state the
script leaves (`Move.attack`: `HitTrig`, then `Fire .damaged`). After a return of the attacker
(`returnPokemon .own .active`) the attacker's Active Spot is empty, and a trigger aimed at "the
Attacking Pokémon" (`counters`, `inflict` on `.opp` of the exchanged state) has no resolution. Before
this round `Fire` could only skip an optional trigger, so such a trigger step had no result
(`fireOld_stuck`, one step at the state the script leaves) and, argued from that, the attack had no
`Move` against a defender with a mandatory one; in print the trigger finds no Attacking Pokémon and does
nothing. `Fire.vacant` lets such a trigger do nothing. -/

/-- `Fire` before fix round 2 of milestone MV15 (copied: `nil`, `run`, `decline`). -/
inductive FireOld (ev : TrigEvent) : List Ability → GameState → GameState → Prop where
  | nil (g : GameState) : FireOld ev [] g g
  | run {ab : Ability} {l : List Ability} {g g₁ g₂ : GameState}
      (hk : (ab.script ev.place).trigOk = true)
      (hr : Run (ab.script ev.place) g.swap g₁) (ht : FireOld ev l g₁.swap g₂) :
      FireOld ev (ab :: l) g g₂
  | decline {ab : Ability} {l : List Ability} {g g₂ : GameState}
      (ho : ab.use.optional = true) (ht : FireOld ev l g g₂) : FireOld ev (ab :: l) g g₂

/-- A zone step that is not a return of the Active Pokémon keeps the Active Spot filled. -/
theorem _root_.Pokemon.ZStep.active_isSome {e : Effect} {s s' : PlayerState} (h : ZStep e s s')
    (hr : ∀ w d, e ≠ .returnPokemon w .active d) (ha : s.active.isSome = true) :
    s'.active.isSome = true := by
  have e1 := h.active_pokemonCards hr
  cases hs : s.active with
  | none => rw [hs] at ha; cases ha
  | some p =>
      rw [hs] at e1
      cases hs' : s'.active with
      | none => rw [hs'] at e1; cases e1
      | some _ => rfl

/-- **A trigger's effect keeps the Active Spot of the side it is aimed at filled** (`.opp` of the state
it runs on): the trigger fragment has no switch and no return. -/
theorem _root_.Pokemon.Run.opp_isSome_of_trigOk {e : Effect} {g g' : GameState} (h : Run e g g') :
    e.trigOk = true → g.opp.active.isSome = true → g'.opp.active.isSome = true := by
  induction h with
  | seq _ _ ih₁ ih₂ =>
      intro hk ha; simp only [Effect.trigOk, Bool.and_eq_true] at hk; exact ih₂ hk.2 (ih₁ hk.1 ha)
  | choiceL _ ih =>
      intro hk ha; simp only [Effect.trigOk, Bool.and_eq_true] at hk; exact ih hk.1 ha
  | choiceR _ ih =>
      intro hk ha; simp only [Effect.trigOk, Bool.and_eq_true] at hk; exact ih hk.2 ha
  | counters => intro _ _; rfl
  | inflict => intro _ _; rfl
  | skip => intro _ ha; exact ha
  | draw => intro _ ha; exact ha
  | drawEmpty => intro _ ha; exact ha
  | shuffle => intro _ ha; exact ha
  | @zone e w g s' hw hz =>
      intro hk ha
      cases w with
      | own => exact ha
      | opp =>
          show (s'.active).isSome = true
          refine hz.active_isSome ?_ ha
          rintro w' d rfl; simp [Effect.trigOk] at hk
  | @touchActive e w f g p he h =>
      intro hk; cases e <;> simp [Effect.touch, Effect.trigOk] at he hk
  | @touchBench e w f g q b₁ b₂ he h =>
      intro hk; cases e <;> simp [Effect.touch, Effect.trigOk] at he hk
  | _ => intro hk; simp [Effect.trigOk] at hk

/-- **No change where the attacker is in play**: from a state whose player to move has an Active
Pokémon, `Fire` is the pre-round relation `FireOld` (the new case `vacant` needs that spot empty, and
a trigger's effect never empties it). At the three places a move fires triggers the hypothesis is
proved for a game with no return card: `attack_fire_old`, `batch_fire_old`, `owed_old` (below). -/
theorem fire_old {ev : TrigEvent} {l : List Ability} {g g' : GameState} (ha : g.cur.active.isSome = true) :
    Fire ev l g g' ↔ FireOld ev l g g' := by
  constructor
  · intro h
    induction h with
    | nil g => exact .nil g
    | @run ab l g g₁ g₂ hk hr _ ih =>
        exact .run hk hr (ih (hr.opp_isSome_of_trigOk hk ha))
    | decline ho _ ih => exact .decline ho (ih ha)
    | vacant _ hv _ _ => rw [hv] at ha; cases ha
  · intro h
    induction h with
    | nil g => exact .nil g
    | @run ab l g g₁ g₂ hk hr _ ih => exact .run hk hr (ih (hr.opp_isSome_of_trigOk hk ha))
    | decline ho _ ih => exact .decline ho (ih ha)

/-! ### The test pair -/

/-- Base damage 10, no text. -/
def jab : Attack := ⟨"Jab", [], 1, .skip, false, .none⟩

/-- The returning attacker: Fade Out and Jab. -/
def fader : PokemonCard := ⟨"Fader", .basic, none, 10, .grass, [fadeOut, jab], 1, none, none, .none, false, []⟩

/-- The player to move has `fader` Active and `big` on the Bench; the opponent has `spiky false`
Active (a **mandatory** `damaged` trigger: "put 3 damage counters on the Attacking Pokémon",
`TriggerWitness.spikes`) and `big` on the Bench. -/
def t0 : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic fader) [InPlay.ofBasic big],
    side [] [.energy .fire] (InPlay.ofBasic (TriggerWitness.spiky false)) [InPlay.ofBasic big],
    true, false, false, false, none, none, false, false, false⟩

theorem t0_wf : WellFormed t0 := by
  refine ⟨fun _ => ⟨by simp [t0, side], by simp [t0, side]⟩, ?_, ?_, .of_b rfl⟩ <;> intro p hp <;>
    · simp only [t0, side, List.mem_singleton] at hp
      subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem t0_settled : Settled t0 := (GameState.settled_iff _).2 (by decide)

/-- The state Fade Out's script leaves: 1 damage counter on `spiky`, `fader` in the hand. -/
def u : GameState :=
  { t0 with cur := { t0.cur with active := none, hand := [.pokemon fader] },
            opp := { t0.opp with active := some { InPlay.ofBasic (TriggerWitness.spiky false) with damage := 1 } } }

theorem run_fade_t0 : Run fadeOut.script t0 u := by
  have r : Run fadeOut.script t0 _ :=
    .seq (.damage (.const 1 _) rfl) (.zone (w := .own) rfl (.monActive rfl (.hand _ _)))
  exact r

/-- Mandatory `spikes` has no resolution on `u`: the Attacking Pokémon's spot is empty. -/
theorem spikes_none : ∀ g₁, ¬ Run (TriggerWitness.spikes.script TrigEvent.damaged.place) u.swap g₁ := by
  intro g₁ h
  change Run (.counters 3) _ _ at h
  cases h with
  | counters _ hp => nomatch hp
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw

/-- **The departure the round fixes (step 1)**: under the pre-round `FireOld`, the mandatory trigger
of `spiky` has no result at `u` (no resolution, and it cannot be declined). Since `u` is the state Fade
Out's script leaves from `t0` (`run_fade_t0`), Fade Out had no `Move` from `t0` with the old relation:
**argued**, not proved (that every resolution of the script leaves `u` and that the fired list is
`[spikes]` is not stated). -/
theorem fireOld_stuck : ∀ g'', ¬ FireOld .damaged [TriggerWitness.spikes] u g'' := by
  intro g'' h
  cases h with
  | run _ hr _ => exact spikes_none _ hr
  | decline ho => cases ho

/-- The state after Fade Out's damage step, before the return. -/
def v : GameState :=
  { t0 with opp := { t0.opp with active := some { InPlay.ofBasic (TriggerWitness.spiky false) with damage := 1 } } }

theorem ret_v : Run (.returnPokemon .own .active .hand) v u := by
  have r : Run (.returnPokemon .own .active .hand) v _ := .zone (w := .own) rfl (.monActive rfl (.hand _ _))
  exact r

theorem dmg_t0 : Run (.damage (.const 1)) t0 v := by
  have r : Run (.damage (.const 1)) t0 _ := .damage (.const 1 _) rfl
  exact r

theorem hit_fade : HitTrig fadeOut t0 u [TriggerWitness.spikes] :=
  .fire (sw := false) (.seq (h₁ := true) (s₁ := false) (h₂ := false) (s₂ := false)
    (.hit (b := true) rfl dmg_t0 rfl (fun _ => rfl)) (.plain rfl ret_v)) (.refl _)

/-- After Fade Out against `spiky`: nothing was placed by the trigger (the attacker is in the hand). -/
def t1 : GameState := u.afterAttack .none false

/-- **Witness (fixed): Fade Out is a legal move against a mandatory `damaged` trigger aimed at the
attacker**: the trigger fires (`hit_fade`) and does nothing (`Fire.vacant`): no damage counter is on
any Pokémon of the attacking player (the attacker is in the hand, the Benched `big` has none). The next
move promotes `big`, with no Prize card. -/
theorem fade_vs_spikes : WellFormed t0 ∧ Settled t0 ∧ Move t0 t1 ∧ t1.cur.active = none ∧
    t1.cur.hand = [.pokemon fader] ∧ t1.cur.bench.map InPlay.damage = [0] ∧
    ∃ t2, Move t1 t2 ∧ t2.cur.active = some (InPlay.ofBasic big) ∧ t2.cur.prizes = t1.cur.prizes ∧
      t2.opp.prizes = t1.opp.prizes ∧ t2.winner = none := by
  have m : Move t0 t1 := by
    have m' := Move.attackOpen (hlk := rfl) (atk := fadeOut) (g := t0) rfl (.head _) (.nil _) rfl rfl
      rfl rfl t0_settled run_fade_t0 rfl (fun h => nomatch h) rfl hit_fade
      (.vacant rfl rfl spikes_none (.nil _))
    exact m'
  exact ⟨t0_wf, t0_settled, m, rfl, rfl, rfl, _,
    Move.knockOuts_of_nil (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide)) rfl
      (.pick (b₁ := []) (b₂ := [])) .keep) rfl, rfl, rfl, rfl, rfl⟩

/-- **The trigger still fires when the attacker stays**: Jab from the same start puts 1 damage counter on
`spiky`, and the mandatory trigger puts 3 on `fader` (as before the round). -/
theorem jab_vs_spikes : ∃ g, Move t0 g ∧ g.cur.active.map InPlay.damage = some 3 ∧
    g.opp.active.map InPlay.damage = some 1 := by
  have hr : Run jab.script t0 _ := .seq (.damage (.const 1 _) rfl) (.skip _)
  exact ⟨_, Move.attackOpen (hlk := rfl) (atk := jab) (g := t0) rfl (.tail _ (.head _)) (.nil _) rfl rfl
    rfl rfl t0_settled hr rfl (fun h => nomatch h) rfl (l := [TriggerWitness.spikes])
    (.fire (.seq (.hit (b := true) rfl (.damage (.const 1 _) rfl) rfl (fun _ => rfl)) (.plain rfl (.skip _)))
      (.refl _))
    (.run rfl (.counters 3 rfl) (.nil _)), rfl, rfl⟩

/-! ## Every `Fire` inside a move of a game with no return card is a `FireOld` (fix round 3) -/

theorem cmove_isSome {f : Filter} {noKO : Bool} {hp : Spot → InPlay → Nat} {a a' : Option InPlay}
    {b b' : List InPlay} (h : CMove f noKO hp a b a' b') (ha : a.isSome = true) : a'.isSome = true := by
  cases h with
  | ab => rfl
  | ba => rfl
  | bb => exact ha

/-- **An effect with no return keeps both Active Spots filled**: each that was filled stays filled. -/
theorem _root_.Pokemon.Run.isSome_of_retFree {e : Effect} {g g' : GameState} (h : Run e g g') :
    e.retFree = true → (g.cur.active.isSome = true → g'.cur.active.isSome = true) ∧
      (g.opp.active.isSome = true → g'.opp.active.isSome = true) := by
  induction h with
  | iteT _ _ _ ih =>
      intro hk; simp only [Effect.retFree, Bool.and_eq_true] at hk; exact ih hk.1
  | iteF _ _ _ ih =>
      intro hk; simp only [Effect.retFree, Bool.and_eq_true] at hk; exact ih hk.2
  | seq _ _ ih₁ ih₂ =>
      intro hk; simp only [Effect.retFree, Bool.and_eq_true] at hk
      exact ⟨fun a => (ih₂ hk.2).1 ((ih₁ hk.1).1 a), fun a => (ih₂ hk.2).2 ((ih₁ hk.1).2 a)⟩
  | choiceL _ ih =>
      intro hk; simp only [Effect.retFree, Bool.and_eq_true] at hk; exact ih hk.1
  | choiceR _ ih =>
      intro hk; simp only [Effect.retFree, Bool.and_eq_true] at hk; exact ih hk.2
  | iterNil => intro _; exact ⟨id, id⟩
  | iterCons _ _ ih₁ ih₂ =>
      intro hk; simp only [Effect.retFree] at hk ih₂
      exact ⟨fun a => (ih₂ hk).1 ((ih₁ hk).1 a), fun a => (ih₂ hk).2 ((ih₁ hk).2 a)⟩
  | @zone e w g s' hw hz =>
      intro hk
      have hr : ∀ w d, e ≠ .returnPokemon w .active d := by
        rintro w' d rfl; simp [Effect.retFree] at hk
      cases w with
      | own => exact ⟨fun a => hz.active_isSome hr a, id⟩
      | opp => exact ⟨id, fun a => hz.active_isSome hr a⟩
  | switch w ha hb =>
      intro _
      cases w <;> simp only [Whose.noteBenched, GameState.noteBenched, GameState.updSide] <;>
        refine ⟨fun a => ?_, fun a => ?_⟩ <;> (try split) <;> first | exact a | rfl | simp_all
  | @touchActive _ w => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | @touchBench _ w _ _ _ _ _ _ _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | unmark w m g =>
      intro _
      cases w <;> simp only [GameState.updSide, PlayerState.unmark] <;>
        exact ⟨fun a => by simpa using a, fun a => by simpa using a⟩
  | linger w _ _ _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | @benchCounters _ _ _ _ w _ _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | spreadCounters w _ _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | benchSome w _ _ _ _ _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | hitByActive w _ _ _ _ _ h _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | hitByBench w _ _ _ _ _ _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | @benchDamage _ _ _ _ w _ _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | spreadDamage w _ _ => intro _; cases w <;> exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩
  | moveCounter h =>
      intro _
      exact ⟨fun a => cmove_isSome h a, id⟩
  | _ => intro _; exact ⟨fun a => by first | exact a | rfl, fun a => by first | exact a | rfl⟩

theorem promote_isSome {a a' : Option InPlay} {b b' : List InPlay} (h : Promote a b a' b') :
    a'.isSome = true := by
  cases h <;> rfl

/-- A trigger resolution from a state with both Active Spots filled keeps them filled. -/
theorem _root_.Pokemon.Fire.bothActive {ev : TrigEvent} {l : List Ability} {g g' : GameState}
    (h : Fire ev l g g') (hb : g.BothActive) : g'.BothActive := by
  induction h with
  | nil => exact hb
  | @run ab l g g₁ g₂ hk hr _ ih =>
      have e := hr.isSome_of_retFree (Effect.retFree_of_trigOk hk)
      exact ih ⟨e.2 hb.1, e.1 hb.2⟩
  | decline _ _ ih => exact ih hb
  | vacant _ hv _ _ => have := hb.1; rw [hv] at this; cases this

/-- **Site 1, `Move.attack`, in a game with no return card**: the `damaged` triggers resolve by the
pre-round relation (`FireOld`): the attack (or its shielded form) returns nothing, so the state its
script leaves still has the attacker in the Active Spot (`Run.isSome_of_retFree`). -/
theorem attack_fire_old {g g' g'' : GameState} {a : InPlay} {atk : Attack} {l : List Ability}
    (hR : g.RetFree) (ha : g.cur.active = some a) (hm : atk ∈ a.attacks)
    (hr : Run (atk.against g.shield).script g g') (ht : Fire .damaged l g' g'') :
    FireOld .damaged l g' g'' := by
  have hs := script_retFree (attack_retFree hR ha hm)
  have hrf : (atk.against g.shield).script.retFree = true := by
    rw [Attack.against_script]
    cases g.shield
    · exact hs
    · exact shielded_retFree _ hs
  have hc : g'.cur.active.isSome = true := (hr.isSome_of_retFree hrf).1 (by rw [ha]; rfl)
  exact (fire_old hc).1 ht

/-- **Site 2, `Move.knockOuts`** (every game): the `koByAttack` triggers resolve by `FireOld`: either
the batch step ended the game and none fires, or it promoted, filling the player to move's Active
Spot. -/
theorem batch_fire_old {g g₁ g' : GameState} {l : List Ability} (hk : KOBatch g g₁)
    (hl : l.Perm (g.batchTrigs g₁)) (ht : Fire .koByAttack l g₁ g') : FireOld .koByAttack l g₁ g' := by
  cases hk with
  | won _ hw =>
      rw [GameState.batchTrigs_of_won hw] at hl
      have := List.Perm.eq_nil hl
      subst this
      rw [ht.nil_eq]; exact .nil _
  | @go ac ao bc bo _ _ hc _ _ =>
      refine (fire_old ?_).1 ht
      show (if g.promoUp then ac.map (InPlay.noteMove .movedUp .active) else ac).isSome = true
      have := promote_isSome hc
      split
      · cases ac with
        | none => cases this
        | some _ => rfl
      · exact this

/-- `FireMine` with `FireOld`. -/
def FireMineOld (u d : List Ability) (g g' : GameState) : Prop :=
  ∃ g₁ g₂, FireOld .movedUp u g.swap g₁ ∧ FireOld .movedDown d g₁ g₂ ∧ g' = g₂.swap

/-- `Owed` with `FireOld` (the pre-round relation). -/
inductive OwedOld (g : GameState) : GameState → Prop where
  | mineFirst {u d l : List Ability} {g₁ g' : GameState} (hu : u.Perm g.upOwed)
      (hd : d.Perm g.downOwed) (hl : l.Perm g.owedTrigs) (hm : FireMineOld u d g.unpend g₁)
      (ht : FireOld .oppBenched l g₁ g') : OwedOld g g'
  | oppFirst {u d l : List Ability} {g₁ g' : GameState} (hu : u.Perm g.upOwed)
      (hd : d.Perm g.downOwed) (hl : l.Perm g.owedTrigs) (ht : FireOld .oppBenched l g.unpend g₁)
      (hm : FireMineOld u d g₁ g') : OwedOld g g'

theorem fireMine_old {u d : List Ability} {g g' : GameState} (h : FireMine u d g g') (hb : g.BothActive) :
    FireMineOld u d g g' ∧ g'.BothActive := by
  obtain ⟨x₁, x₂, h₁, h₂, rfl⟩ := h
  have b₁ := h₁.bothActive hb.swap
  have b₂ := h₂.bothActive b₁
  exact ⟨⟨x₁, x₂, (fire_old hb.swap.1).1 h₁, (fire_old b₁.1).1 h₂, rfl⟩, b₂.swap⟩

theorem unpend_bothActive {g : GameState} (hb : g.BothActive) : g.unpend.BothActive := by
  refine ⟨?_, ?_⟩
  · show (g.cur.active.map InPlay.clearOwe).isSome = true
    have := hb.1; cases h : g.cur.active <;> simp_all
  · show (g.opp.active.map InPlay.clearOwe).isSome = true
    have := hb.2; cases h : g.opp.active <;> simp_all

/-- **Site 3, `Owed`** (`Move.trigger`, `Resolve.trigger`; every game): from a state with both Active
Spots filled, as both callers require, the owed triggers resolve by `FireOld`. -/
theorem owed_old {g g' : GameState} (h : Owed g g') (hb : g.BothActive) : OwedOld g g' := by
  have hb' := unpend_bothActive hb
  cases h with
  | mineFirst hu hd hl hm ht =>
      obtain ⟨m, b⟩ := fireMine_old hm hb'
      exact .mineFirst hu hd hl m ((fire_old b.1).1 ht)
  | oppFirst hu hd hl ht hm =>
      have b := ht.bothActive hb'
      exact .oppFirst hu hd hl ((fire_old hb'.1).1 ht) (fireMine_old hm b).1

end Pokemon.Return
