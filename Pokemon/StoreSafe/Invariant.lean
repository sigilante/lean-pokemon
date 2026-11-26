import Pokemon.StoreSafe.Deck
import Pokemon.Bounded
import Pokemon.Counter

/-! Part of `Pokemon/StoreSafe.lean` (see its module documentation): the bound on the Ability
potential, the invariant that bounds the stores, and the per-turn invariant. -/

namespace Pokemon

/-- The potential is at most `potBound` of the number of cards in the game. -/
def potBound (L : Nat) : Nat := 5 * L + 2 * (benchLimit + 1)

theorem GameState.abPot_le_bound (g : GameState) : g.abPot ≤ potBound g.allCards.length := by
  have h1 := abWo_le g.cur.active
  have h2 := abWs_le g.cur.bench
  have h3 : optN g.cur.active + g.cur.bench.length ≤ g.allCards.length := by
    have := Enum.length_le_benchCardList g.cur.bench
    have : optN g.cur.active ≤ (optCardList g.cur.active).length := by
      cases g.cur.active <;> simp [optN, optCardList, InPlay.cardList]
    simp only [GameState.allCards, PlayerState.allCards, List.length_append]; omega
  have h4 : g.opp.prizes.length ≤ g.allCards.length := by
    simp only [GameState.allCards, PlayerState.allCards, List.length_append]; omega
  simp only [GameState.abPot, PlayerState.abPot, potBound]; omega

/-! ## The invariant -/

namespace StoreSafe

/-- `A` if the player to move has attacked this turn, else 0. -/
def atkT (A : Nat) (g : GameState) : Nat := if g.attacked then A else 0

/-- `A` for each player who has used a GX attack. -/
def gxT (A : Nat) (g : GameState) : Nat :=
  (if g.cur.gxUsed then A else 0) + (if g.opp.gxUsed then A else 0)

theorem atkT_le (A : Nat) (g : GameState) : atkT A g ≤ A := by
  unfold atkT; split <;> omega

theorem gxT_le (A : Nat) (g : GameState) : gxT A g ≤ A + A := by
  unfold gxT; split <;> split <;> omega

/-- **The invariant.** For each slot, the amounts of both players together are at most `S`
(the start stores), plus the Trainer amounts in the discard piles, plus `A` for every attack
that may still be live in the slot: one for the turn after next, if this turn's attack has been
made; one more for the next turn (last turn's attack); one more for this turn; and, for the
rest of the game, one per GX attack used. -/
structure Inv (S A : Nat) (g : GameState) : Prop where
  after : g.slotAmt .after ≤ S + g.discAmt + atkT A g
  next : g.slotAmt .next ≤ S + g.discAmt + A + atkT A g
  now : g.slotAmt .now ≤ S + g.discAmt + A + A + atkT A g
  always : g.slotAmt .always ≤ S + g.discAmt + gxT A g

theorem Inv.start (g : GameState) (A : Nat) : Inv g.storeTotal A g := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp only [GameState.storeTotal] <;> omega

/-- A step that writes nothing, keeps the discards growing, and does not undo an attack or a
GX attack. -/
theorem Inv.frame {S A : Nat} {g g' : GameState} (hi : Inv S A g)
    (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s) (hd : g.discAmt ≤ g'.discAmt)
    (ha : atkT A g ≤ atkT A g') (hx : gxT A g ≤ gxT A g') : Inv S A g' := by
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now; have h4 := hs .always
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨by omega, by omega, by omega, by omega⟩

theorem atkT_congr {A : Nat} {g g' : GameState} (h : g'.attacked = g.attacked) :
    atkT A g' = atkT A g := by
  simp only [atkT, h]

theorem gxT_congr {A : Nat} {g g' : GameState} (h₁ : g'.cur.gxUsed = g.cur.gxUsed)
    (h₂ : g'.opp.gxUsed = g.opp.gxUsed) : gxT A g' = gxT A g := by
  simp only [gxT, h₁, h₂]

theorem Inv.keeps {S A : Nat} {g g' : GameState} (hi : Inv S A g) (hk : Keeps g g')
    (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s) : Inv S A g' :=
  hi.frame hs hk.disc (Nat.le_of_eq (atkT_congr hk.attacked).symm)
    (Nat.le_of_eq (gxT_congr hk.gxCur hk.gxOpp).symm)

/-- A Trainer card: its amounts are matched by the card's amount in the discard pile. -/
theorem Inv.trainer {S A W : Nat} {g g' : GameState} (hi : Inv S A g) (hk : Keeps g g')
    (w : Slot → Nat) (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s + w s) (hw : ∀ s, w s ≤ W)
    (hd : g.discAmt + W ≤ g'.discAmt) : Inv S A g' := by
  have ea := atkT_congr (A := A) hk.attacked
  have ex := gxT_congr (A := A) hk.gxCur hk.gxOpp
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now; have h4 := hs .always
  have w1 := hw .after; have w2 := hw .next; have w3 := hw .now; have w4 := hw .always
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨by omega, by omega, by omega, by omega⟩

/-- An attack: at most `A` in each slot, the rest-of-game slot only with a GX attack. -/
theorem Inv.attack {S A : Nat} {g g' : GameState} (hi : Inv S A g) (hn : g.attacked = false)
    (ha : g'.attacked = true) (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s + A)
    (hal : g'.slotAmt .always + gxT A g ≤ g.slotAmt .always + gxT A g')
    (hd : g.discAmt ≤ g'.discAmt) : Inv S A g' := by
  have e0 : atkT A g = 0 := by simp only [atkT, hn]; rfl
  have e1 : atkT A g' = A := by simp only [atkT, ha]; rfl
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨by omega, by omega, by omega, by omega⟩

/-- The end of the turn: every slot moves one turn closer, the player's attack is forgotten. -/
theorem Inv.endTurn {S A : Nat} {g g' : GameState} (hi : Inv S A g)
    (h0 : g'.slotAmt .after = 0) (h1 : g'.slotAmt .next = g.slotAmt .after)
    (h2 : g'.slotAmt .now = g.slotAmt .next) (h3 : g'.slotAmt .always = g.slotAmt .always)
    (hd : g'.discAmt = g.discAmt) (ha : atkT A g' = 0) (hx : gxT A g' = gxT A g) :
    Inv S A g' := by
  have := atkT_le A g
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨by omega, by omega, by omega, by omega⟩

/-- The state after an attack whose resolution ended in `g`. -/
def atkRes (atk : Attack) (g : GameState) : GameState := g.afterAttack atk.lockSet atk.gx

theorem atkRes_slotAmt (atk : Attack) (g : GameState) (s : Slot) :
    (atkRes atk g).slotAmt s = g.slotAmt s := rfl

theorem atkRes_gxT_false {A : Nat} {atk : Attack} {g g'' : GameState} (hgv : atk.gx = false)
    (h₁ : g''.cur.gxUsed = g.cur.gxUsed) (h₂ : g''.opp.gxUsed = g.opp.gxUsed) :
    gxT A (atkRes atk g'') = gxT A g := by
  simp only [gxT, atkRes, GameState.afterAttack, hgv, Bool.false_or, h₁, h₂]

theorem atkRes_gxT_true {A : Nat} {atk : Attack} {g g'' : GameState} (hgv : atk.gx = true)
    (hu : g.cur.gxUsed = false) (h₂ : g''.opp.gxUsed = g.opp.gxUsed) :
    gxT A (atkRes atk g'') = gxT A g + A := by
  simp only [gxT, atkRes, GameState.afterAttack, hgv, Bool.true_or, h₂, hu, ite_true]
  simp only [Bool.false_eq_true, ite_false]
  omega

/-- **Every move preserves the invariant**, for cards satisfying clauses 1 and 2 that recycle
nothing (`NoRecycle`), whose Abilities write nothing (`AbilityQuiet`, milestone M8a), whose Stadium
effects write nothing (`StadiumQuiet`, milestone M5) and whose attacks write at most `A`. -/
theorem Inv.move {S A : Nat} {g g' : GameState} (hm : Move g g') (hi : Inv S A g)
    (hL : g.LoopFree) (hG : g.GXOnly) (hN : g.NoRecycle) (hQ : g.AbilityQuiet)
    (hSQ : g.StadiumQuiet) (hA : ∀ x ∈ g.allCards, x.atkAmt ≤ A) : Inv S A g' := by
  cases hm with
  | playBasic => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | attach => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | evolve => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | attachBench => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | evolveBench => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | retreat =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append, GameState.noteBenched]; omega
  | @item g' l₁ l₂ n e hh hbt hst hr hl =>
      have hx : Card.trainer n .item e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hlf : e.loopFree = true := hL _ (GameState.mem_allCards_of_hand hx)
      have hk := hr.keeps (hN _ (GameState.mem_allCards_of_hand hx))
      refine hi.trainer ⟨Nat.le_trans ?_ hk.disc, hk.attacked, hk.gxCur, hk.gxOpp⟩
        e.amtAt (hr.slot_le hlf) e.amtAt_le_amt (Nat.le_trans ?_ hk.disc)
      · simp only [GameState.discAmt, cardsAmt]; omega
      · simp only [GameState.discAmt, cardsAmt, Card.amt]; omega
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr =>
      have hx : Card.trainer n .supporter e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hlf : e.loopFree = true := hL _ (GameState.mem_allCards_of_hand hx)
      have hk := hr.keeps (hN _ (GameState.mem_allCards_of_hand hx))
      refine hi.trainer ⟨Nat.le_trans ?_ hk.disc, hk.attacked, hk.gxCur, hk.gxOpp⟩
        e.amtAt (hr.slot_le hlf) e.amtAt_le_amt (Nat.le_trans ?_ hk.disc)
      · simp only [GameState.discAmt, cardsAmt]; omega
      · simp only [GameState.discAmt, cardsAmt, Card.amt]; omega
  | stadium =>
      refine hi.keeps ⟨?_, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
      simp only [GameState.discAmt, cardsAmt_append]; omega
  | @stadiumUse g'' o n e ss hs hu hbt hst hat hr hnd hbh =>
      have hxC := GameState.mem_allCards_of_stadium hs
      have hlf : e.loopFree = true := hL _ hxC
      have hk' := hr.keeps (hN _ hxC)
      have h0 := hSQ n e ss hxC
      refine hi.keeps ⟨hk'.disc, hk'.attacked, hk'.gxCur, hk'.gxOpp⟩ fun s => ?_
      have h1 := hr.slot_le hlf s; have h2 := e.amtAt_le_amt s
      simp only [GameState.slotAmt] at h1 ⊢; omega
  | tool => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | toolBench => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | @onPlay g₁ g'' x how w ab hp hm hk hw hst₁ hcd hr hnd hbh =>
      have hxC := hp.top_mem
      have he := ab.script_mem none
      have hlf := Card.loopFree_ability (hL _ hxC) hm he
      have hk' := hr.keeps (abilitiesRec_nil (hN _ hxC) hm he)
      have h0 := hQ _ hxC ab hm _ he
      have hsl := hr.slot_le hlf
      refine hi.keeps ⟨by rw [← hp.discAmt]; exact hk'.disc, hk'.attacked.trans hp.flags.attacked,
        hk'.gxCur.trans hp.flags.gxCur, hk'.gxOpp.trans hp.flags.gxOpp⟩ fun s => ?_
      have h1 := hsl s; have h2 := (ab.script none).amtAt_le_amt s; rw [hp.slotAmt] at h1; omega
  | @ability g₁ g'' x sp ab hu hm hk hsp hn hcd hbt hst hat hr hnd hbh =>
      obtain ⟨c, hcx, hmc⟩ := InPlay.ability_mem hm
      have hxC := hu.card_mem hcx
      have he := ab.script_mem (some sp)
      have hlf := Card.loopFree_ability (hL _ hxC) hmc he
      have hk' := hr.keeps (abilitiesRec_nil (hN _ hxC) hmc he)
      have h0 := hQ _ hxC ab hmc _ he
      have hsl := hr.slot_le hlf
      refine hi.keeps ⟨by rw [← hu.discAmt]; exact hk'.disc, hk'.attacked.trans hu.flags.attacked,
        hk'.gxCur.trans hu.flags.gxCur, hk'.gxOpp.trans hu.flags.gxOpp⟩ fun s => ?_
      have h1 := hsl s; have h2 := (ab.script (some sp)).amtAt_le_amt s; rw [hu.slotAmt] at h1
      omega
  | @attack g₀ a atk ha hm hc hs hn hf hbt hst hr hl hgx _ l g'' hd ht =>
      show Inv S A (atkRes atk g'')
      have hkf := ht.keeps fun ab hab => by
        obtain ⟨c, hc, hmc, -⟩ := GameState.optTrigs_card (hd.mem hab)
        exact abilitiesRec_nil (hN _ (hr.perm.mem_iff.1 hc)) hmc (ab.script_mem _)
      obtain ⟨c, hcx, hmc⟩ := InPlay.attack_mem hm
      have hmem := GameState.mem_allCards_of_cur_active ha hcx
      have hlf : atk.effect.loopFree = true := Card.loopFree_attack (hL _ hmem) hmc
      have hamt : atk.effect.amt ≤ A := by
        have h1 := attacksAmt_mem hmc
        have h2 := hA _ hmem
        simp only [Card.atkAmt] at h2
        omega
      have hk := (hr.keeps (by rw [Attack.against_recFilters]; exact attacksRec_nil (hN _ hmem) hmc)).trans
        hkf
      have hsl := hr.slot_le (Attack.against_loopFree _ hlf)
      have hs' : ∀ s, (atkRes atk g'').slotAmt s ≤ g.slotAmt s + A := by
        intro s
        have h1 := Nat.le_trans (hsl s) (Nat.add_le_add_left (Attack.against_amtAt_le _ atk s) _)
        have h2 := atk.effect.amtAt_le_amt s
        rw [atkRes_slotAmt, ht.slotAmt]
        omega
      refine hi.attack hn rfl hs' ?_ hk.disc
      have hal := Nat.le_trans (hsl .always)
        (Nat.add_le_add_left (Attack.against_amtAt_le _ atk .always) _)
      rw [atkRes_slotAmt, ht.slotAmt]
      cases hgv : atk.gx with
      | false =>
          have h0 := hG _ hmem atk hmc hgv
          rw [h0] at hal
          rw [atkRes_gxT_false hgv hk.gxCur hk.gxOpp]
          omega
      | true =>
          rw [atkRes_gxT_true hgv (hgx hgv) hk.gxOpp]
          have := atk.effect.amtAt_le_amt .always
          omega
  | attackConfused =>
      exact hi.frame (fun _ => Nat.le_refl _) (Nat.le_refl _) (atkT_le A g) (Nat.le_refl _)
  | knockOuts h hl ht =>
      have hkf := ht.keeps fun ab hab => by
        obtain ⟨c, hc, hmc, -⟩ := GameState.batchTrigs_card (hl.mem_iff.1 hab)
        exact abilitiesRec_nil (hN _ hc) hmc (ab.script_mem _)
      exact hi.keeps (h.keeps.1.trans hkf) fun s => Nat.le_of_eq ((ht.slotAmt s).trans (h.keeps.2 s))
  | trigger _ _ ho =>
      have k := ho.keeps
      exact hi.keeps ⟨k.disc, k.attacked, k.gxCur, k.gxOpp⟩ fun s => Nat.le_of_eq (ho.slotAmt s)
  | endTurn =>
      exact hi.endTurn rfl (Nat.add_comm _ _) (Nat.add_comm _ _) (Nat.add_comm _ _)
        (Nat.add_comm _ _) rfl (Nat.add_comm _ _)
  | startTurn => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _
  | deckOut => exact hi.keeps ⟨Nat.le_refl _, rfl, rfl, rfl⟩ fun _ => Nat.le_refl _

/-- The bound on the stores of every state reachable from `g₀` when no card recycles: the start
stores, plus every Trainer amount among the cards, plus three attacks' worth (the bound proved
before milestone MV, as `storeBound`). -/
def storeBoundNR (g₀ : GameState) : Nat :=
  g₀.storeTotal + cardsAmt g₀.allCards + 3 * cardsAtkAmt g₀.allCards

theorem reach_inv {g₀ g : GameState} (hL : g₀.LoopFree) (hG : g₀.GXOnly) (hN : g₀.NoRecycle)
    (hQ : g₀.AbilityQuiet) (hSQ : g₀.StadiumQuiet) (h : Reach g₀ g) :
    Inv g₀.storeTotal (cardsAtkAmt g₀.allCards) g := by
  induction h with
  | refl => exact Inv.start _ _
  | step hr _ hm ih =>
      have hp := hr.perm
      exact ih.move hm (hL.of_perm hp) (hG.of_perm hp) (hN.of_perm hp) (hQ.of_perm hp)
        (hSQ.of_perm hp) (fun x hx => atkAmt_le_cardsAtkAmt (hp.mem_iff.1 hx))

theorem modsLe_of {B : Nat} {m : Mods} (h : m.amt ≤ B) : Enum.ModsLe B m := by
  unfold Mods.amt at h
  -- One conjunct per `omega`: `omega` on a conjunction pulls in `Classical.choice`.
  exact ⟨by omega, by omega, by omega, by omega, by omega⟩

/-- **Without recycling, the bound of master.** From a start state `g₀` satisfying clauses 1 and
2 whose cards recycle nothing (`NoRecycle`: no effect moves a card out of a discard pile to a hand
or deck; every deck before milestone MV) and whose Abilities write nothing (`AbilityQuiet`, added
by milestone M8a: an Ability writes every turn, so its amounts are not counted once per game) and
whose Stadium effects write nothing (`StadiumQuiet`, added by milestone M5 for the same reason),
every reachable state has every slot's bonus and reduction (since milestone MV6 also its step-2 penalty and step-5 increase) at most `storeBoundNR g₀`: each Trainer
card is then played at most once per game. This is the statement `reach_boundedStores` had before
milestone MV, with its bound; for decks without Abilities and Stadiums the added hypotheses hold
(`GameState.NoAbilities.quiet`, `GameState.NoStadiums.quiet`). -/
theorem reach_boundedStores_noRecycle {g₀ g : GameState} (hL : g₀.LoopFree) (hG : g₀.GXOnly)
    (hN : g₀.NoRecycle) (hQ : g₀.AbilityQuiet) (hSQ : g₀.StadiumQuiet) (h : Reach g₀ g) :
    g.BoundedStores (storeBoundNR g₀) := by
  have hi := reach_inv hL hG hN hQ hSQ h
  have hd : g.discAmt ≤ cardsAmt g₀.allCards :=
    Nat.le_trans g.discAmt_le (Nat.le_of_eq (cardsAmt_perm h.perm))
  have ha := atkT_le (cardsAtkAmt g₀.allCards) g
  have hx := gxT_le (cardsAtkAmt g₀.allCards) g
  have hn := hi.now; have hnx := hi.next; have haf := hi.after; have hal := hi.always
  have hB : ∀ s, g.slotAmt s ≤ storeBoundNR g₀ := by
    intro s; cases s <;> simp only [storeBoundNR] <;> omega
  have hc : ∀ s, (g.cur.mods.at s).amt ≤ storeBoundNR g₀ := fun s =>
    Nat.le_trans (Nat.le_add_right _ _) (hB s)
  have ho : ∀ s, (g.opp.mods.at s).amt ≤ storeBoundNR g₀ := fun s =>
    Nat.le_trans (Nat.le_add_left _ _) (hB s)
  exact ⟨⟨modsLe_of (hc .now), modsLe_of (hc .next), modsLe_of (hc .after),
      modsLe_of (hc .always)⟩,
    ⟨modsLe_of (ho .now), modsLe_of (ho .next), modsLe_of (ho .after), modsLe_of (ho .always)⟩⟩

/-! ## The per-turn invariant (milestone MV)

With recycling a Trainer card can be played more than once per game, so the amounts in the
discard piles no longer bound what Trainers have written. They still bound what Trainers write in
one turn, under clause 3: before the turn's attack no Item or Supporter effect and no "as often as
you like" Ability returns an Item writer from a discard pile, so each such card is played at most
once in the turn, except after a once-per-turn or on-play Ability or (milestone M5) a Stadium's
effect has returned it, and at most one Supporter is. The invariant tracks, as witnesses, the amount `X₀` Trainers and Abilities wrote this
turn, `X₁` last turn and `X₂` the turn before (each at most `2 P + Q · K`, `P` the Trainer amounts
of all cards, `Q` what one bounded Ability use can write and recycle, `K` a bound on the
potential), the weight `D` of the Item writers in the discard piles (`Card.wAmt`) when the turn began,
and the potential `E` when the turn began (milestone M8a); carried amounts expire within three turn
boundaries, as for attacks. The rest-of-game slot is bounded as before, by the rest-of-game
Trainer amounts in the discard piles, which no effect recycles (clause 3 (b)); no Ability writes
it (clause 4), and no Stadium effect (clause 5). Milestone M5 adds the Stadium uses of a turn,
at most two (`GameState.stPot`), each paid for by `R` (`cardsStQ`). -/

/-- `P` once the player to move has played a Supporter this turn, else 0. -/
def supT (P : Nat) (g : GameState) : Nat := if g.cur.supporterPlayed then P else 0

theorem supT_le (P : Nat) (g : GameState) : supT P g ≤ P := by
  unfold supT; split <;> omega

/-- **No move but the end of the turn raises the potential** (milestone M8a), unless it ends the
game (milestone batch-KO added the hypothesis `g'.winner = none`: a batch Knock Out step can
Knock Out several of the player's Pokémon while the opponent's Prize cards run out), or (milestone
MV15, the hypothesis `g'.attacked = false`) it is an attack: an attack may return a Pokémon from
play (`Effect.returnPokemon`), which frees a place. The per-turn invariant reads the potential only
before the turn's attack (`TInv.pot`, `TInv.turn`). -/
theorem _root_.Pokemon.Move.abPot_le {g g' : GameState} (hm : Move g g')
    (hc : g'.curIsFirst = g.curIsFirst) (hatk : g'.attacked = false) (hw : g'.winner = none) :
    g'.abPot ≤ g.abPot := by
  cases hm with
  | @playBasic l₁ l₂ p hh hs hhp hb hbt hst hat =>
      have := optN_le g.cur.active
      simp only [benchLimit] at hb
      have e : (InPlay.ofBasic p).abW = 1 := rfl
      simp only [GameState.abPot, PlayerState.abPot, abWs_append, abWs, e, List.length_append,
        List.length_cons, List.length_nil, benchLimit]
      omega
  | @attach l₁ l₂ t a hh hf ha =>
      have e : ({ a with energy := Card.energy t :: a.energy } : InPlay).abW = a.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | @evolve l₁ l₂ p a hh ha he hfr =>
      have : a.abW ≥ 2 := by unfold InPlay.abW; rw [hfr]; split <;> simp
      have e : InPlay.abW { a with
          top := p, under := Card.pokemon a.top :: a.under, rot := .none,
          poisoned := false, burned := false, poisonUp := 0, fresh := true, used := false, lk := {} } = 1 :=
        rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | @attachBench l₁ l₂ t q b₁ b₂ hh hf hb =>
      simp only [GameState.abPot, PlayerState.abPot, hb,
        abWs_split (b₁ := b₁) (b₂ := b₂) (q := q)
          (q' := { q with energy := Card.energy t :: q.energy }) rfl,
        List.length_append, List.length_cons]; omega
  | @evolveBench l₁ l₂ p q b₁ b₂ hh hb he hfr =>
      have : q.abW ≥ 2 := by unfold InPlay.abW; rw [hfr]; split <;> simp
      have e : InPlay.abW { q with
          top := p, under := Card.pokemon q.top :: q.under, rot := .none,
          poisoned := false, burned := false, poisonUp := 0, fresh := true, used := false, lk := {} } = 1 :=
        rfl
      simp only [GameState.abPot, PlayerState.abPot, hb, abWs_append, abWs, e,
        List.length_append, List.length_cons]; omega
  | @retreat a q b₁ b₂ paid rest ha hb =>
      have e : InPlay.abW (InPlay.noteMove .movedDown .bench { a with
          energy := rest, rot := .none, poisoned := false, burned := false, poisonUp := 0,
          lk := {} }) ≤ a.abW := InPlay.abW_noteMove _ _ _
      have e2 : (q.moveUp.noteMove .movedUp .active).abW ≤ q.abW := InPlay.abW_noteMove _ _ _
      simp only [GameState.abPot, PlayerState.abPot, ha, hb, abWo, optN, abWs_append, abWs,
        List.length_append, List.length_cons, GameState.noteBenched]; omega
  | item _ _ _ hr _ _ _ _ hrf => exact hr.abPot_le hrf hw
  | supporter _ _ _ _ hr _ _ _ _ hrf => exact hr.abPot_le hrf hw
  | stadiumUse _ _ _ _ _ hr _ _ hrf => exact hr.abPot_le hrf hw
  | stadium => exact Nat.le_refl _
  | @tool l₁ l₂ n gr a hh ha =>
      have e : ({ a with tools := [Card.tool n gr] } : InPlay).abW = a.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | @toolBench l₁ l₂ n gr q b₁ b₂ hh hb =>
      simp only [GameState.abPot, PlayerState.abPot, hb,
        abWs_split (b₁ := b₁) (b₂ := b₂) (q := q)
          (q' := { q with tools := [Card.tool n gr] }) rfl,
        List.length_append, List.length_cons]; omega
  | ability hu _ _ _ _ _ _ _ _ hr _ _ hrf =>
      have := hu.abPot
      exact Nat.le_trans (hr.abPot_le hrf hw) (by omega)
  | onPlay hp _ _ _ _ _ hr _ _ hrf =>
      have := hp.abPot
      exact Nat.le_trans (hr.abPot_le hrf hw) (by omega)
  | attack => simp [GameState.afterAttack] at hatk
  | @attackConfused a atk ha =>
      have e : ({ a with damage := a.damage + 3 } : InPlay).abW = a.abW := rfl
      simp only [GameState.abPot, PlayerState.abPot, ha, abWo, optN, e]; omega
  | knockOuts h _ ht =>
      exact Nat.le_trans ht.abPot_le (h.abPot_le (ht.zoneOnly.winner.symm.trans hw))
  | trigger _ _ ho => exact ho.abPot_le
  | endTurn => simp at hc
  | startTurn => exact Nat.le_refl _
  | deckOut => exact Nat.le_refl _

/-- **The Stadium uses still open to the player to move this turn** (milestone M5): one if the
Stadium in play has not been used (`GameState.stadiumUsed`), one more if no Stadium has been
played (`GameState.stadiumPlayed`): a Stadium played this turn is new and can be used once. Both
flags are cleared at the end of every turn, so it is 2 when a turn begins. Using the Stadium lowers
it by one; playing a Stadium makes it 1 from at least 1; nothing else in the turn changes it. -/
def _root_.Pokemon.GameState.stPot (g : GameState) : Nat :=
  (if g.stadiumUsed then 0 else 1) + (if g.stadiumPlayed then 0 else 1)

theorem _root_.Pokemon.GameState.stPot_le (g : GameState) : g.stPot ≤ 2 := by
  unfold GameState.stPot; split <;> split <;> omega

theorem _root_.Pokemon.GameState.stPot_congr {g g' : GameState} (h₁ : g'.stadiumPlayed = g.stadiumPlayed)
    (h₂ : g'.stadiumUsed = g.stadiumUsed) : g'.stPot = g.stPot := by
  simp only [GameState.stPot, h₁, h₂]

theorem _root_.Pokemon.UseAt.stFlags {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    g₁.stadiumPlayed = g.stadiumPlayed ∧ g₁.stadiumUsed = g.stadiumUsed := by
  cases h <;> exact ⟨rfl, rfl⟩

theorem _root_.Pokemon.PlayFromHand.stFlags {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) :
    g₁.stadiumPlayed = g.stadiumPlayed ∧ g₁.stadiumUsed = g.stadiumUsed := by
  cases h <;> exact ⟨rfl, rfl⟩

/-- **No move but the end of the turn raises the Stadium potential** (milestone M5). -/
theorem _root_.Pokemon.Move.stPot_le {g g' : GameState} (hm : Move g g')
    (hc : g'.curIsFirst = g.curIsFirst) : g'.stPot ≤ g.stPot := by
  cases hm with
  | item _ _ _ hr => exact Nat.le_of_eq (GameState.stPot_congr hr.stFlags.1 hr.stFlags.2)
  | supporter _ _ _ _ hr => exact Nat.le_of_eq (GameState.stPot_congr hr.stFlags.1 hr.stFlags.2)
  | @stadium l₁ l₂ n e ss hh hs =>
      cases hu : g.stadiumUsed <;> simp [GameState.stPot, hs, hu]
  | @stadiumUse g' o n e ss hs hu _ _ _ hr =>
      rw [GameState.stPot_congr hr.stFlags.1 hr.stFlags.2]
      simp [GameState.stPot, hu]
  | ability hu _ _ _ _ _ _ _ _ hr =>
      exact Nat.le_of_eq ((GameState.stPot_congr hr.stFlags.1 hr.stFlags.2).trans
        (GameState.stPot_congr hu.stFlags.1 hu.stFlags.2))
  | onPlay hp _ _ _ _ _ hr =>
      exact Nat.le_of_eq ((GameState.stPot_congr hr.stFlags.1 hr.stFlags.2).trans
        (GameState.stPot_congr hp.stFlags.1 hp.stFlags.2))
  | attack _ _ _ _ _ _ _ _ hr _ _ _ _ ht =>
      exact Nat.le_of_eq (GameState.stPot_congr
        (ht.zoneOnly.stadiumPlayed.trans hr.stFlags.1) (ht.zoneOnly.stadiumUsed.trans hr.stFlags.2))
  | endTurn => simp at hc
  | knockOuts h _ ht =>
      have e := GameState.stPot_congr ht.zoneOnly.stadiumPlayed ht.zoneOnly.stadiumUsed
      cases h <;> exact Nat.le_of_eq e
  | trigger _ _ ho =>
      exact Nat.le_of_eq (GameState.stPot_congr ho.zoneOnly.stadiumPlayed ho.zoneOnly.stadiumUsed)
  | _ => exact Nat.le_refl _

/-- **The per-turn invariant.** The witnesses: `X₀`, `X₁`, `X₂` the amounts that Trainer cards,
Abilities and (milestone M5) Stadium effects wrote this turn, last turn and the turn before; `D`
the weight of the Item writers in the discard piles when the turn began; and (milestone M8a) `E`
the potential `GameState.abPot` when the turn began. Within the turn, before its attack, the
potential does not rise (`pot`), and `turn` says what has been written so far is paid for: by the
Item writers that went to the discard piles (each such card played this turn), by the Supporter,
by `Q` for each unit of potential spent (each "once during your turn" or on-play Ability used; `Q`
bounds what one use writes, plus what it can recycle), and (milestone M5) by `R` for each Stadium
use (`GameState.stPot` counts the uses still open, two at the start of a turn; `R` bounds what
one use writes and recycles, `Card.stQ`). Since milestone batch-KO `pot` and `turn` are asked only
while the game goes on (`g.winner = none`): a batch Knock Out step that ends the game can raise the
potential (`KOBatch.abPot_le`), and no move follows it. The store bounds (`after`, `next`, `now`,
`always`) hold in every state. -/
structure TInv (S A P Q K R : Nat) (g : GameState) (X₀ X₁ X₂ D E : Nat) : Prop where
  x0 : X₀ ≤ P + P + Q * K + R * 2
  x1 : X₁ ≤ P + P + Q * K + R * 2
  x2 : X₂ ≤ P + P + Q * K + R * 2
  e : E ≤ K
  pot : g.attacked = false → g.winner = none → g.abPot ≤ E
  turn : g.attacked = false → g.winner = none →
    D + X₀ + Q * g.abPot + R * g.stPot ≤ g.discW Card.wAmt + supT P g + Q * E + R * 2
  after : g.slotAmt .after ≤ S + X₀ + atkT A g
  next : g.slotAmt .next ≤ S + X₀ + X₁ + A + atkT A g
  now : g.slotAmt .now ≤ S + X₀ + X₁ + X₂ + A + A + atkT A g
  always : g.slotAmt .always ≤ S + g.discW Card.alAmt + gxT A g

theorem TInv.start (g : GameState) (A P Q K R : Nat) (hK : g.abPot ≤ K) :
    TInv g.storeTotal A P Q K R g 0 0 0 (g.discW Card.wAmt) g.abPot := by
  have := Nat.mul_le_mul_left R g.stPot_le
  refine ⟨Nat.zero_le _, Nat.zero_le _, Nat.zero_le _, hK, fun _ _ => Nat.le_refl _,
    fun _ _ => by omega, ?_, ?_, ?_, ?_⟩ <;>
    simp only [GameState.storeTotal] <;> omega

/-- A step that writes nothing and recycles no weighted card. The weight of the discard piles
is read only by the per-turn clause, before the turn's attack, so it need not be kept by a step
that ends after the attack (milestone M8b: the `koByAttack` triggers). -/
theorem TInv.frame' {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hn : g.winner = none)
    (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s)
    (hW : g'.attacked = false → g.discW Card.wAmt ≤ g'.discW Card.wAmt)
    (hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt) (ha : atkT A g ≤ atkT A g')
    (ht : g'.attacked = false → g'.winner = none → g.attacked = false ∧ supT P g ≤ supT P g' ∧
      g'.abPot ≤ g.abPot ∧ g'.stPot ≤ g.stPot)
    (hx : gxT A g ≤ gxT A g') : TInv S A P Q K R g' X₀ X₁ X₂ D E := by
  have h1 := hs .after; have h2 := hs .next; have h3 := hs .now; have h4 := hs .always
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  refine ⟨hi.x0, hi.x1, hi.x2, hi.e, fun hf hw => ?_, fun hf hw => ?_, by omega, by omega,
    by omega, by omega⟩
  · obtain ⟨hg, -, hp, -⟩ := ht hf hw
    exact Nat.le_trans hp (hi.pot hg hn)
  · obtain ⟨hg, hsup, hp, hq⟩ := ht hf hw
    have := hi.turn hg hn
    have := hW hf
    have := Nat.mul_le_mul_left Q hp
    have := Nat.mul_le_mul_left R hq
    omega

/-- A step that writes nothing and recycles no weighted card. -/
theorem TInv.frame {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hn : g.winner = none)
    (hs : ∀ s, g'.slotAmt s ≤ g.slotAmt s) (hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt)
    (hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt) (ha : atkT A g ≤ atkT A g')
    (ht : g'.attacked = false → g'.winner = none → g.attacked = false ∧ supT P g ≤ supT P g' ∧
      g'.abPot ≤ g.abPot ∧ g'.stPot ≤ g.stPot)
    (hx : gxT A g ≤ gxT A g') : TInv S A P Q K R g' X₀ X₁ X₂ D E :=
  hi.frame' hn hs (fun _ => hW) hAl ha ht hx

/-- A step that changes no flag, store or discard pile weight of interest; the weight of Item
writers need only be kept when the step ends before the turn's attack (`TInv.frame'`). -/
theorem TInv.same' {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hn : g.winner = none)
    (hW : g'.attacked = false → g.discW Card.wAmt ≤ g'.discW Card.wAmt)
    (hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt)
    (ha : g'.attacked = g.attacked) (hsp : g'.cur.supporterPlayed = g.cur.supporterPlayed)
    (hgc : g'.cur.gxUsed = g.cur.gxUsed) (hgo : g'.opp.gxUsed = g.opp.gxUsed)
    (hs : ∀ s, g'.slotAmt s = g.slotAmt s)
    (hp : g'.attacked = false → g'.winner = none → g'.abPot ≤ g.abPot)
    (hq : g'.stPot ≤ g.stPot) :
    TInv S A P Q K R g' X₀ X₁ X₂ D E :=
  hi.frame' hn (fun s => Nat.le_of_eq (hs s)) hW hAl (Nat.le_of_eq (atkT_congr ha).symm)
    (fun hf hw => ⟨ha ▸ hf, by simp only [supT, hsp]; exact Nat.le_refl _, hp hf hw, hq⟩)
    (Nat.le_of_eq (gxT_congr hgc hgo).symm)

/-- A step that changes no flag, store or discard pile weight of interest. -/
theorem TInv.same {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hn : g.winner = none)
    (hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt) (hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt)
    (ha : g'.attacked = g.attacked) (hsp : g'.cur.supporterPlayed = g.cur.supporterPlayed)
    (hgc : g'.cur.gxUsed = g.cur.gxUsed) (hgo : g'.opp.gxUsed = g.opp.gxUsed)
    (hs : ∀ s, g'.slotAmt s = g.slotAmt s)
    (hp : g'.attacked = false → g'.winner = none → g'.abPot ≤ g.abPot)
    (hq : g'.stPot ≤ g.stPot) :
    TInv S A P Q K R g' X₀ X₁ X₂ D E :=
  hi.frame hn (fun s => Nat.le_of_eq (hs s)) hW hAl (Nat.le_of_eq (atkT_congr ha).symm)
    (fun hf hw => ⟨ha ▸ hf, by simp only [supT, hsp]; exact Nat.le_refl _, hp hf hw, hq⟩)
    (Nat.le_of_eq (gxT_congr hgc hgo).symm)

/-- The end of the turn: the witnesses move one turn back, and the potential is counted afresh
for the new player to move. -/
theorem TInv.endTurn {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E)
    (h0 : g'.slotAmt .after = 0) (h1 : g'.slotAmt .next = g.slotAmt .after)
    (h2 : g'.slotAmt .now = g.slotAmt .next) (h3 : g'.slotAmt .always = g.slotAmt .always)
    (hd : g'.discW Card.alAmt = g.discW Card.alAmt) (ha : atkT A g' = 0)
    (hx : gxT A g' = gxT A g) (hK : g'.abPot ≤ K) :
    TInv S A P Q K R g' 0 X₀ X₁ (g'.discW Card.wAmt) g'.abPot := by
  have := atkT_le A g
  have := Nat.mul_le_mul_left R g'.stPot_le
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  exact ⟨Nat.zero_le _, hi.x0, hi.x1, hK, fun _ _ => Nat.le_refl _, fun _ _ => by omega,
    by omega, by omega, by omega, by omega⟩

theorem Card.wAmt_le_P {g : GameState} {P : Nat} (hP : cardsAmt g.allCards ≤ P) :
    g.discW Card.wAmt ≤ P :=
  Nat.le_trans (GameState.discW_le Card.wAmt_le g) hP

/-- **One bounded use** (milestone M8a; milestone M5 added the Stadium term): a step `g → g₁`
that changes no store, discard pile or flag and pays `C` in the potential (`Q` per unit of
`abPot`, `R` per unit of `stPot`), followed by the resolution of a loop-free effect `e` that
writes no rest-of-game amount, recycles no rest-of-game writer, and has `e.amt + (P if it
recycles)` at most `C`, keeps the per-turn invariant, with `e.amt` added to this turn's writes.
This is the case of a "once during your turn" Ability used by a Pokémon that had not used one and
of an on-play Ability (`C = Q`), and of a Stadium's effect (`C = R`). -/
theorem TInv.bounded_use {S A P Q K R X₀ X₁ X₂ D E C : Nat} {g g₁ g' : GameState} {e : Effect}
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hat : g.attacked = false) (hn : g.winner = none)
    (hpot₁ : g₁.abPot ≤ g.abPot)
    (hpay : Q * g₁.abPot + R * g₁.stPot + C ≤ Q * g.abPot + R * g.stPot)
    (hsl : ∀ s, g₁.slotAmt s = g.slotAmt s)
    (hW₁ : g₁.discW Card.wAmt = g.discW Card.wAmt)
    (hAl₁ : g₁.discW Card.alAmt = g.discW Card.alAmt)
    (hfl : Flags g g₁) (hsp : g₁.cur.supporterPlayed = g.cur.supporterPlayed)
    (hp₁ : g₁.allCards.Perm g.allCards)
    (hr : TRun e g₁ g') (hrf : e.retFree = true) (hlf : e.loopFree = true) (hal : e.amtAt .always = 0)
    (hq : e.q P ≤ C)
    (hrec : ∀ f ∈ e.recFilters, ∀ y ∈ g.allCards, f.eval y = true → y.alAmt = 0)
    (hP : cardsAmt g.allCards ≤ P) :
    TInv S A P Q K R g' (X₀ + e.amt) X₁ X₂ D E := by
  have hP' : cardsAmt g'.allCards ≤ P := by rw [cardsAmt_perm (hr.perm.trans hp₁)]; exact hP
  have hWle : g'.discW Card.wAmt ≤ P := Card.wAmt_le_P hP'
  have hsP := supT_le P g'
  have hEK := Nat.mul_le_mul_left Q hi.e
  have hAl₀ := hr.disc_mono Card.alAmt_tw (C := g.allCards) hrec fun y hy => hp₁.mem_iff.1 hy
  have hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt := by rw [← hAl₁]; exact hAl₀
  have hsl' := hr.slot_le hlf
  have hp2 := hr.abPot_le hrf
  have hst2 : g'.stPot = g₁.stPot := GameState.stPot_congr hr.stFlags.1 hr.stFlags.2
  have hfk := hr.flags_keep
  have hst' := hr.sameTurn
  have hsup : supT P g' = supT P g := by
    simp only [supT, show g'.cur.supporterPlayed = g.cur.supporterPlayed from
      hst'.2.2.2.2.2.2.trans hsp]
  have hat' : atkT A g' = atkT A g := atkT_congr (hfk.attacked.trans hfl.attacked)
  have hgx : gxT A g' = gxT A g :=
    gxT_congr (hfk.gxCur.trans hfl.gxCur) (hfk.gxOpp.trans hfl.gxOpp)
  have hturn := hi.turn hat hn
  have hpg := hi.pot hat hn
  have hs' : ∀ s, g'.slotAmt s ≤ g.slotAmt s + e.amtAt s := fun s => by
    rw [← hsl s]; exact hsl' s
  have h1 := hs' .after; have h2 := hs' .next; have h3 := hs' .now; have h4 := hs' .always
  have w1 := e.amtAt_le_amt .after; have w2 := e.amtAt_le_amt .next
  have w3 := e.amtAt_le_amt .now
  have := hi.after; have := hi.next; have := hi.now; have := hi.always
  rw [hal] at h4
  unfold Effect.q at hq
  have hW : g.discW Card.wAmt + e.amt ≤ g'.discW Card.wAmt + C := by
    by_cases hrf : e.recFilters = []
    · simp only [hrf, ite_true] at hq
      have hW₀ := hr.disc_mono Card.wAmt_tw (C := g.allCards) (Effect.recOk_nil hrf)
        fun y hy => hp₁.mem_iff.1 hy
      rw [hW₁] at hW₀
      omega
    · simp only [hrf, ite_false] at hq
      have := Card.wAmt_le_P (g := g) hP
      omega
  have hR2 : R * g'.stPot = R * g₁.stPot := by rw [hst2]
  exact ⟨by omega, hi.x1, hi.x2, hi.e, fun _ hw => by have := hp2 hw; omega,
    fun _ hw => by have := Nat.mul_le_mul_left Q (hp2 hw); omega, by omega, by omega,
    by omega, by omega⟩

/-- **Every move preserves the per-turn invariant**, for cards satisfying the five clauses
whose attacks write at most `A`, whose Trainer amounts add up to at most `P`, whose Abilities
have `Ability.q P` at most `Q` (milestone M8a), whose Stadiums have `Card.stQ P` at most `R`
(milestone M5), and whose number bounds the potential by `K`. -/
theorem TInv.move {S A P Q K R X₀ X₁ X₂ D E : Nat} {g g' : GameState} (hm : Move g g')
    (hi : TInv S A P Q K R g X₀ X₁ X₂ D E) (hL : g.LoopFree) (hG : g.GXOnly) (hR : g.RecycleSafe)
    (hAb : g.AbilitySafe) (hSS : g.StadiumSafe) (hA : ∀ x ∈ g.allCards, x.atkAmt ≤ A)
    (hP : cardsAmt g.allCards ≤ P)
    (hQ : ∀ c ∈ g.allCards, ∀ ab ∈ c.abilities, ab.q P ≤ Q)
    (hRq : ∀ x ∈ g.allCards, x.stQ P ≤ R) (hK : potBound g.allCards.length ≤ K)
    (hwn : g.winner = none) :
    ∃ Y₀ Y₁ Y₂ E' F, TInv S A P Q K R g' Y₀ Y₁ Y₂ E' F := by
  have hP' : cardsAmt g'.allCards ≤ P := by rw [cardsAmt_perm hm.perm]; exact hP
  have hWle : g'.discW Card.wAmt ≤ P := Card.wAmt_le_P hP'
  have hWle₀ : g.discW Card.wAmt ≤ P := Card.wAmt_le_P hP
  have hsP := supT_le P g'
  have hEK := Nat.mul_le_mul_left Q hi.e
  have hpot := hm.abPot_le
  have hstp := hm.stPot_le
  cases hm with
  | playBasic => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | attach => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | evolve => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | attachBench => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | evolveBench => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | retreat =>
      exact ⟨_, _, _, _, _, hi.same hwn
        (by simp only [GameState.discW, wsum_append, GameState.noteBenched]; omega)
        (by simp only [GameState.discW, wsum_append, GameState.noteBenched]; omega) rfl rfl rfl rfl
        (fun _ => rfl)
        (hpot rfl) (hstp rfl)⟩
  | stadium =>
      exact ⟨_, _, _, _, _, hi.same hwn (by simp only [GameState.discW, wsum_append]; omega)
        (by simp only [GameState.discW, wsum_append]; omega) rfl rfl rfl rfl (fun _ => rfl)
        (hpot rfl) (hstp rfl)⟩
  | tool => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | toolBench => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | @item g' l₁ l₂ n e hh hbt hst hr hl hat hnd hbh =>
      have hx : Card.trainer n .item e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hxC := GameState.mem_allCards_of_hand hx
      have hlf : e.loopFree = true := hL _ hxC
      have hp₁ : ({ g with cur := { g.cur with
          hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } :
          GameState).allCards.Perm g.allCards := by perm_count [hh]
      have hW₀ := hr.disc_mono Card.wAmt_tw (C := g.allCards)
        (fun f hf y hy hfy => hR.1 _ hxC f hf y hy hfy) fun y hy => hp₁.mem_iff.1 hy
      have hAl₀ := hr.disc_mono Card.alAmt_tw (C := g.allCards)
        (fun f hf y hy hfy => hR.2 _ hxC f hf y hy hfy) fun y hy => hp₁.mem_iff.1 hy
      have ew : Card.wAmt (.trainer n .item e) = e.amt := rfl
      have ea : Card.alAmt (.trainer n .item e) = e.amtAt .always := rfl
      have hW : g.discW Card.wAmt + e.amt ≤ g'.discW Card.wAmt := by
        simp only [GameState.discW, wsum] at hW₀ ⊢; omega
      have hAl : g.discW Card.alAmt + e.amtAt .always ≤ g'.discW Card.alAmt := by
        simp only [GameState.discW, wsum] at hAl₀ ⊢; omega
      have hf := hr.flags_keep
      have hst' := hr.sameTurn
      have hsl : ∀ s, g'.slotAmt s ≤ g.slotAmt s + e.amtAt s := hr.slot_le hlf
      have hsup : supT P g' = supT P g := by
        have e2 : g'.cur.supporterPlayed = g.cur.supporterPlayed := hst'.2.2.2.2.2.2
        simp only [supT, e2]
      have hat' : atkT A g' = atkT A g := atkT_congr hf.attacked
      have hgx : gxT A g' = gxT A g := gxT_congr hf.gxCur hf.gxOpp
      have hturn := hi.turn hat hwn
      have hpg := hi.pot hat hwn
      have hp := fun ha' hw' => hpot hst'.1 ha' hw'
      have hRp := Nat.mul_le_mul_left R (hstp hst'.1)
      have h1 := hsl .after; have h2 := hsl .next; have h3 := hsl .now; have h4 := hsl .always
      have w1 := e.amtAt_le_amt .after; have w2 := e.amtAt_le_amt .next
      have w3 := e.amtAt_le_amt .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀ + e.amt, X₁, X₂, D, E, by omega, hi.x1, hi.x2, hi.e,
        fun ha' hw' => Nat.le_trans (hp ha' hw') hpg,
        fun ha' hw' => by have := Nat.mul_le_mul_left Q (hp ha' hw'); omega, by omega, by omega,
        by omega, by omega⟩
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr hat hf hnd hbh =>
      have hx : Card.trainer n .supporter e ∈ g.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hxC := GameState.mem_allCards_of_hand hx
      have hlf : e.loopFree = true := hL _ hxC
      have hp₁ : ({ g with cur := { g.cur with
          hand := l₁ ++ l₂, supporterPlayed := true, supCard := some (Card.trainer n .supporter e),
          discard := Card.trainer n .supporter e :: g.cur.discard } } :
          GameState).allCards.Perm g.allCards := by perm_count [hh]
      have hW₀ := hr.disc_mono Card.wAmt_tw (C := g.allCards)
        (fun f hf y hy hfy => hR.1 _ hxC f hf y hy hfy) fun y hy => hp₁.mem_iff.1 hy
      have hAl₀ := hr.disc_mono Card.alAmt_tw (C := g.allCards)
        (fun f hf y hy hfy => hR.2 _ hxC f hf y hy hfy) fun y hy => hp₁.mem_iff.1 hy
      have ew : Card.wAmt (.trainer n .supporter e) = 0 := rfl
      have ea : Card.alAmt (.trainer n .supporter e) = e.amtAt .always := rfl
      have hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt := by
        simp only [GameState.discW, wsum] at hW₀ ⊢; omega
      have hAl : g.discW Card.alAmt + e.amtAt .always ≤ g'.discW Card.alAmt := by
        simp only [GameState.discW, wsum] at hAl₀ ⊢; omega
      have hfk := hr.flags_keep
      have hst' := hr.sameTurn
      have hsl : ∀ s, g'.slotAmt s ≤ g.slotAmt s + e.amtAt s := hr.slot_le hlf
      have hsup0 : supT P g = 0 := by simp only [supT, hs]; rfl
      have hsup1 : supT P g' = P := by
        have e2 : g'.cur.supporterPlayed = true := hst'.2.2.2.2.2.2
        simp only [supT, e2]; rfl
      have hamt : e.amt ≤ P := Nat.le_trans (amt_le_cardsAmt hxC) hP
      have hat' : atkT A g' = atkT A g := atkT_congr hfk.attacked
      have hgx : gxT A g' = gxT A g := gxT_congr hfk.gxCur hfk.gxOpp
      have hturn := hi.turn hat hwn
      have hpg := hi.pot hat hwn
      have hp := fun ha' hw' => hpot hst'.1 ha' hw'
      have hRp := Nat.mul_le_mul_left R (hstp hst'.1)
      have h1 := hsl .after; have h2 := hsl .next; have h3 := hsl .now; have h4 := hsl .always
      have w1 := e.amtAt_le_amt .after; have w2 := e.amtAt_le_amt .next
      have w3 := e.amtAt_le_amt .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀ + e.amt, X₁, X₂, D, E, by omega, hi.x1, hi.x2, hi.e,
        fun ha' hw' => Nat.le_trans (hp ha' hw') hpg,
        fun ha' hw' => by have := Nat.mul_le_mul_left Q (hp ha' hw'); omega, by omega, by omega,
        by omega, by omega⟩
  | @stadiumUse g' o n e ss hs hu hbt hst hat hr hnd hbh hrf =>
      have hxC := GameState.mem_allCards_of_stadium hs
      have hpay : Q * ({ g with stadiumUsed := true } : GameState).abPot +
          R * ({ g with stadiumUsed := true } : GameState).stPot + R ≤
          Q * g.abPot + R * g.stPot := by
        have e1 : ({ g with stadiumUsed := true } : GameState).stPot + 1 = g.stPot := by
          simp only [GameState.stPot, hu]; simp; omega
        have e2 : R * ({ g with stadiumUsed := true } : GameState).stPot + R = R * g.stPot := by
          rw [← e1, Nat.mul_add, Nat.mul_one]
        have e3 : Q * ({ g with stadiumUsed := true } : GameState).abPot = Q * g.abPot := rfl
        omega
      exact ⟨_, _, _, _, _, hi.bounded_use (g₁ := { g with stadiumUsed := true }) hat hwn
        (Nat.le_refl _) hpay (fun _ => rfl) rfl rfl
        ⟨rfl, rfl, rfl⟩ rfl (List.Perm.refl _) hr hrf (hL _ hxC) (hSS.get hxC) (hRq _ hxC)
        (fun f hf y hy hfy => hR.2 _ hxC f hf y hy hfy) hP⟩
  | @ability g₁ g' x sp ab hu hm hk hsp hn hcd hbt hst hat hr hnd hbh hrf =>
      obtain ⟨c, hcx, hmc⟩ := InPlay.ability_mem hm
      have hxC := hu.card_mem hcx
      have he := ab.script_mem (some sp)
      have hlf := Card.loopFree_ability (hL _ hxC) hmc he
      have hsafe := hAb.get hxC hmc he
      have hrec : ∀ f ∈ (ab.script (some sp)).recFilters, ∀ y ∈ g.allCards, f.eval y = true →
          y.alAmt = 0 := fun f hf y hy hfy =>
        hR.2 _ hxC f (Card.allRec_of_ability hmc he hf) y hy hfy
      have hs₁ : g₁.stPot = g.stPot := GameState.stPot_congr hu.stFlags.1 hu.stFlags.2
      cases hab : ab.use with
      | onPlay w => rw [hab] at hk; cases hk
      | static _ => rw [hab] at hk; cases hk
      | triggered _ _ => rw [hab] at hk; cases hk
      | once =>
          have hu0 : x.used = false := hn hab
          have hpu := hu.abPot
          rw [hu0] at hpu
          have hpu' : g₁.abPot + 1 ≤ g.abPot := by simp at hpu; omega
          have hpay : Q * g₁.abPot + R * g₁.stPot + Q ≤ Q * g.abPot + R * g.stPot := by
            have := Nat.mul_le_mul_left Q hpu'
            rw [Nat.mul_add, Nat.mul_one] at this
            rw [hs₁]; omega
          exact ⟨_, _, _, _, _, hi.bounded_use hat hwn (by omega) hpay hu.slotAmt (hu.discW _)
            (hu.discW _) hu.flags hu.supporterPlayed hu.perm hr hrf hlf hsafe.2
            (Nat.le_trans (Ability.q_script he) (hQ _ hxC ab hmc)) hrec hP⟩
      | unlimited =>
          have hp₁ := hu.perm
          have hAl₀ := hr.disc_mono Card.alAmt_tw (C := g.allCards) hrec
            fun y hy => hp₁.mem_iff.1 hy
          have hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt := by rw [← hu.discW]; exact hAl₀
          have hsl := hr.slot_le hlf
          have hpu := hu.abPot
          have hp2 := hr.abPot_le hrf
          have hfk := hr.flags_keep
          have hfu := hu.flags
          have hst' := hr.sameTurn
          have hsup : supT P g' = supT P g := by
            simp only [supT, show g'.cur.supporterPlayed = g.cur.supporterPlayed from
              hst'.2.2.2.2.2.2.trans hu.supporterPlayed]
          have hat' : atkT A g' = atkT A g := atkT_congr (hfk.attacked.trans hfu.attacked)
          have hgx : gxT A g' = gxT A g := gxT_congr (hfk.gxCur.trans hfu.gxCur)
            (hfk.gxOpp.trans hfu.gxOpp)
          have hturn := hi.turn hat hwn
          have hpg := hi.pot hat hwn
          have hs' : ∀ s, g'.slotAmt s ≤ g.slotAmt s + (ab.script (some sp)).amtAt s := fun s => by
            rw [← hu.slotAmt s]; exact hsl s
          have h1 := hs' .after; have h2 := hs' .next; have h3 := hs' .now
          have h4 := hs' .always
          have w1 := (ab.script (some sp)).amtAt_le_amt .after
          have w2 := (ab.script (some sp)).amtAt_le_amt .next
          have w3 := (ab.script (some sp)).amtAt_le_amt .now
          have := hi.after; have := hi.next; have := hi.now; have := hi.always
          rw [hsafe.2] at h4
          have h0 := hsafe.1 hab
          have hW₀ := hr.disc_mono Card.wAmt_tw (C := g.allCards)
            (fun f hf y hy hfy => hR.1 _ hxC f (Card.freeRec_of_unlimited hmc hab he hf) y hy hfy)
            fun y hy => hp₁.mem_iff.1 hy
          have hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt := by rw [← hu.discW]; exact hW₀
          have hp : g'.winner = none → g'.abPot ≤ g.abPot := fun hw' =>
            Nat.le_trans (hp2 hw') (by omega)
          have hsq : g'.stPot = g.stPot :=
            (GameState.stPot_congr hr.stFlags.1 hr.stFlags.2).trans hs₁
          have hRp : R * g'.stPot = R * g.stPot := by rw [hsq]
          exact ⟨X₀, X₁, X₂, D, E, hi.x0, hi.x1, hi.x2, hi.e,
            fun _ hw' => Nat.le_trans (hp hw') hpg,
            fun _ hw' => by have := Nat.mul_le_mul_left Q (hp hw'); omega, by omega, by omega,
            by omega, by omega⟩
  | @onPlay g₁ g' x how w ab hp hm hk hw hst₁ hcd hr hnd hbh hrf =>
      have hxC := hp.top_mem
      have he := ab.script_mem none
      have hsafe := hAb.get hxC hm he
      have hs₁ : g₁.stPot = g.stPot := GameState.stPot_congr hp.stFlags.1 hp.stFlags.2
      have hpay : Q * g₁.abPot + R * g₁.stPot + Q ≤ Q * g.abPot + R * g.stPot := by
        have := Nat.mul_le_mul_left Q hp.abPot
        rw [Nat.mul_add, Nat.mul_one] at this
        rw [hs₁]; omega
      exact ⟨_, _, _, _, _, hi.bounded_use hp.attacked hwn (by have := hp.abPot; omega) hpay
        hp.slotAmt (hp.discW _) (hp.discW _) hp.flags hp.supporterPlayed hp.perm hr hrf
        (Card.loopFree_ability (hL _ hxC) hm he) hsafe.2
        (Nat.le_trans (Ability.q_script he) (hQ _ hxC ab hm))
        (fun f hf y hy hfy => hR.2 _ hxC f (Card.allRec_of_ability (c := .pokemon x.top) hm he hf)
          y hy hfy) hP⟩
  | @attack g₀ a atk ha hm hc hs hn hf hbt hst hr hl hgx _ l g'' hd ht =>
      show ∃ Y₀ Y₁ Y₂ E' F, TInv S A P Q K R (atkRes atk g'') Y₀ Y₁ Y₂ E' F
      have hAlf : g₀.discW Card.alAmt ≤ g''.discW Card.alAmt :=
        ht.disc_mono Card.alAmt_tw (C := g.allCards) (fun ab hab f hf y hy hfy => by
          obtain ⟨c, hc, hmc, -⟩ := GameState.optTrigs_card (hd.mem hab)
          exact hR.2 _ (hr.perm.mem_iff.1 hc) f
            (Card.allRec_of_ability hmc (ab.script_mem _) hf) y hy hfy)
          (fun y hy => hr.perm.mem_iff.1 hy)
      have hfkt := ht.flags_keep
      obtain ⟨c, hcx, hmc⟩ := InPlay.attack_mem hm
      have hmem := GameState.mem_allCards_of_cur_active ha hcx
      have hlf : atk.effect.loopFree = true := Card.loopFree_attack (hL _ hmem) hmc
      have hamt : atk.effect.amt ≤ A := by
        have h1 := attacksAmt_mem hmc
        have h2 := hA _ hmem
        simp only [Card.atkAmt] at h2
        omega
      have hfk := hr.flags_keep.trans hfkt
      have hAl : g.discW Card.alAmt ≤ (atkRes atk g'').discW Card.alAmt :=
        Nat.le_trans (hr.disc_mono Card.alAmt_tw (C := g.allCards)
          (fun f hf y hy hfy => hR.2 _ hmem f
            (Card.allRec_of_attack hmc (by rw [Attack.against_recFilters] at hf; exact hf)) y hy hfy)
          fun _ hy => hy) hAlf
      have hsl := hr.slot_le (Attack.against_loopFree _ hlf)
      have hs' : ∀ s, (atkRes atk g'').slotAmt s ≤ g.slotAmt s + A := by
        intro s
        have h1 := Nat.le_trans (hsl s) (Nat.add_le_add_left (Attack.against_amtAt_le _ atk s) _)
        have h2 := atk.effect.amtAt_le_amt s
        rw [atkRes_slotAmt, ht.slotAmt]
        omega
      have e0 : atkT A g = 0 := by simp only [atkT, hn]; rfl
      have e1 : atkT A (atkRes atk g'') = A := rfl
      have hal' : (atkRes atk g'').slotAmt .always + gxT A g ≤
          g.slotAmt .always + gxT A (atkRes atk g'') := by
        have hal := Nat.le_trans (hsl .always)
          (Nat.add_le_add_left (Attack.against_amtAt_le _ atk .always) _)
        rw [atkRes_slotAmt, ht.slotAmt]
        cases hgv : atk.gx with
        | false =>
            have h0 := hG _ hmem atk hmc hgv
            rw [h0] at hal
            rw [atkRes_gxT_false hgv hfk.gxCur hfk.gxOpp]
            omega
        | true =>
            rw [atkRes_gxT_true hgv (hgx hgv) hfk.gxOpp]
            have := atk.effect.amtAt_le_amt .always
            omega
      have h1 := hs' .after; have h2 := hs' .next; have h3 := hs' .now
      have := hi.after; have := hi.next; have := hi.now; have := hi.always
      exact ⟨X₀, X₁, X₂, D, E, hi.x0, hi.x1, hi.x2, hi.e, fun h _ => absurd h (by simp [atkRes, GameState.afterAttack]),
        fun h _ => absurd h (by simp [atkRes, GameState.afterAttack]), by omega, by omega, by omega, by omega⟩
  | attackConfused =>
      exact ⟨_, _, _, _, _, hi.frame hwn (fun _ => Nat.le_refl _) (Nat.le_refl _) (Nat.le_refl _)
        (atkT_le A g) (fun h _ => absurd h (by simp)) (Nat.le_refl _)⟩
  | @knockOuts g₁ g' l h hl ht =>
      have hf := h.flags_keep.trans ht.flags_keep
      have z := ht.zoneOnly
      have hC₁ : ∀ y ∈ g₁.allCards, y ∈ g.allCards := fun y hy => h.perm.mem_iff.1 hy
      have hW : g'.attacked = false → g.discW Card.wAmt ≤ g'.discW Card.wAmt := fun hf' => by
        have hga : g.attacked = false := hf.attacked.symm.trans hf'
        have e := Move.eq_of_batchTrigs_nil hl ht (GameState.batchTrigs_of_not_attacked hga)
        subst e
        exact KOBatch.disc_mono _ h
      have hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt :=
        Nat.le_trans (KOBatch.disc_mono _ h) (ht.disc_mono Card.alAmt_tw (C := g.allCards)
          (fun ab hab f hf y hy hfy => by
            obtain ⟨c, hc, hmc, -⟩ := GameState.batchTrigs_card (hl.mem_iff.1 hab)
            exact hR.2 _ hc f (Card.allRec_of_ability hmc (ab.script_mem _) hf) y hy hfy) hC₁)
      exact ⟨_, _, _, _, _, hi.same' hwn hW hAl hf.attacked
        (z.cur_supporterPlayed.trans h.sides.2.2.2.2.2.2.2.2.1) hf.gxCur hf.gxOpp
        (fun s => (ht.slotAmt s).trans (h.keeps.2 s)) (hpot (z.first.trans h.same.1))
        (hstp (z.first.trans h.same.1))⟩
  | @trigger g' _ _ ho =>
      -- milestone MV7: the triggers recycle nothing (`Ability.trigOn`), so the discard weights stay
      -- (milestone MV7c: the owed triggers of both players, `Owed`)
      have hf := ho.keeps
      have z := ho.zoneOnly
      have hW : g.discW Card.wAmt ≤ g'.discW Card.wAmt := ho.disc_mono Card.wAmt_tw
      have hAl : g.discW Card.alAmt ≤ g'.discW Card.alAmt := ho.disc_mono Card.alAmt_tw
      exact ⟨_, _, _, _, _, hi.same hwn hW hAl hf.attacked z.cur_supporterPlayed hf.gxCur hf.gxOpp
        (fun s => ho.slotAmt s) (hpot z.first) (hstp z.first)⟩
  | @endTurn a b bo bc fa sa ca fb sb cb ha hb hk hbt hco hcc hpd oa ob =>
      refine ⟨_, _, _, _, _, hi.endTurn rfl (Nat.add_comm _ _) (Nat.add_comm _ _)
        (Nat.add_comm _ _) (Nat.add_comm _ _) rfl (Nat.add_comm _ _) ?_⟩
      have hperm := (Move.endTurn fa sa ca fb sb cb ha hb hk hbt hco hcc hpd oa ob).perm
      exact Nat.le_trans (GameState.abPot_le_bound _) (by rw [hperm.length_eq]; exact hK)
  | startTurn => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩
  | deckOut => exact ⟨_, _, _, _, _, hi.same hwn (Nat.le_refl _) (Nat.le_refl _) rfl rfl rfl rfl
      (fun _ => rfl) (hpot rfl) (hstp rfl)⟩

/-- The bound on the stores of every state reachable from `g₀` (milestone MV; milestone M8a
added the third term, milestone M5 the fourth): the start stores, plus three turns of Trainer,
Ability and Stadium writes (each turn at most twice the Trainer amounts of the cards, plus `Q` for
each unit of the potential, which is at most `potBound` of the number of cards, plus two Stadium
uses of at most `cardsStQ` each), plus three attacks' worth. For a deck without Abilities
`cardsAbQ` is 0, and for a deck without Stadium cards `cardsStQ` is 0; for a deck with neither the
bound is the bound of milestone MV, `storeTotal + 6 · cardsAmt + 3 · cardsAtkAmt`. The per-game
bound of master is `storeBoundNR g₀`, which still holds for decks that recycle nothing and whose
Abilities and Stadiums write nothing (`reach_boundedStores_noRecycle`). -/
def storeBound (g₀ : GameState) : Nat :=
  g₀.storeTotal + 6 * cardsAmt g₀.allCards +
    3 * (cardsAbQ (cardsAmt g₀.allCards) g₀.allCards * potBound g₀.allCards.length) +
    6 * cardsStQ (cardsAmt g₀.allCards) g₀.allCards +
    3 * cardsAtkAmt g₀.allCards

theorem reach_tinv {g₀ g : GameState} (hF : g₀.StoreSafe) (h : Reach g₀ g) :
    ∃ X₀ X₁ X₂ D E, TInv g₀.storeTotal (cardsAtkAmt g₀.allCards) (cardsAmt g₀.allCards)
      (cardsAbQ (cardsAmt g₀.allCards) g₀.allCards) (potBound g₀.allCards.length)
      (cardsStQ (cardsAmt g₀.allCards) g₀.allCards) g X₀ X₁ X₂ D E := by
  induction h with
  | refl => exact ⟨_, _, _, _, _, TInv.start _ _ _ _ _ _ (GameState.abPot_le_bound _)⟩
  | step hr hn hm ih =>
      obtain ⟨X₀, X₁, X₂, D, E, hi⟩ := ih
      have hp := hr.perm
      exact hi.move hm (hF.1.of_perm hp) (hF.2.1.of_perm hp) (hF.2.2.1.of_perm hp)
        (hF.2.2.2.1.of_perm hp) (hF.2.2.2.2.of_perm hp)
        (fun x hx => atkAmt_le_cardsAtkAmt (hp.mem_iff.1 hx))
        (Nat.le_of_eq (cardsAmt_perm hp))
        (fun p hx ab hab => Ability.q_le (hp.mem_iff.1 hx) hab)
        (fun x hx => stQ_le_cardsStQ (hp.mem_iff.1 hx))
        (by rw [hp.length_eq]; exact Nat.le_refl _) hn

/-- **For a store-safe deck the stores stay bounded.** From a start state `g₀` satisfying
`StoreSafe` (clauses 1–5), every reachable state has, in both players' stores, every slot's damage
bonus and damage reduction at most `storeBound g₀`, which is computed from the start state's stores
and cards. Milestone MV changed the hypothesis (clause 3, `RecycleSafe`, which every deck without
recycling satisfies) and the bound (`storeBound` counts six times the Trainer amounts, a per-turn
count; the per-game bound of master is `reach_boundedStores_noRecycle`). Milestone M8a added
clause 4 (`AbilitySafe`) to the hypothesis and the Ability term to the bound; for a deck without
Abilities both changes are void. Milestone M5 added clause 5 (`StadiumSafe`) and the Stadium term;
for a deck without Stadium cards both are void (`Pokemon/NoStadiums.lean`). -/
theorem reach_boundedStores {g₀ g : GameState} (hF : g₀.StoreSafe) (h : Reach g₀ g) :
    g.BoundedStores (storeBound g₀) := by
  obtain ⟨X₀, X₁, X₂, D, E, hi⟩ := reach_tinv hF h
  have hd : g.discW Card.alAmt ≤ cardsAmt g₀.allCards :=
    Nat.le_trans (GameState.discW_le Card.alAmt_le g) (Nat.le_of_eq (cardsAmt_perm h.perm))
  have ha := atkT_le (cardsAtkAmt g₀.allCards) g
  have hx := gxT_le (cardsAtkAmt g₀.allCards) g
  have := hi.x0; have := hi.x1; have := hi.x2
  have hn := hi.now; have hnx := hi.next; have haf := hi.after; have hal := hi.always
  have hB : ∀ s, g.slotAmt s ≤ storeBound g₀ := by
    intro s; cases s <;> simp only [storeBound] <;> omega
  have hc : ∀ s, (g.cur.mods.at s).amt ≤ storeBound g₀ := fun s =>
    Nat.le_trans (Nat.le_add_right _ _) (hB s)
  have ho : ∀ s, (g.opp.mods.at s).amt ≤ storeBound g₀ := fun s =>
    Nat.le_trans (Nat.le_add_left _ _) (hB s)
  exact ⟨⟨modsLe_of (hc .now), modsLe_of (hc .next), modsLe_of (hc .after),
      modsLe_of (hc .always)⟩,
    ⟨modsLe_of (ho .now), modsLe_of (ho .next), modsLe_of (ho .after), modsLe_of (ho .always)⟩⟩


/-- **Finiteness for store-safe decks.** Let `g₀` be any start state (well-formed or not) whose
cards satisfy `StoreSafe`, its five clauses:
1. `LoopFree`: no damage bonus or reduction is written under `iter`;
2. `GXOnly`: an attack writes a rest-of-game bonus or reduction only if it is a GX attack, which
   the rules make once per player per game;
3. `RecycleSafe` (milestone MV, revised in M8a and M5): (a) no free recycler (an Item or Supporter
   effect, or an "as often as you like" Ability; not a Stadium's effect) returns from a discard
   pile an Item card that writes a bonus or reduction, and (b) no effect at all returns an Item or
   Supporter card that writes a rest-of-game one;
4. `AbilitySafe` (milestone M8a): no "as often as you like" Ability writes a bonus or reduction,
   and no Ability a rest-of-game one;
5. `StadiumSafe` (milestone M5): no Stadium's effect writes a rest-of-game bonus or reduction.
A Stadium's once-per-turn effect may otherwise recycle and write; it is paid per use through
`Card.stQ`, at most two uses a turn.
Then

* the `xclamp`s of all states reachable from `g₀` lie in one finite list `L`; and
* the kernel of `xclamp` is a two-way bisimulation along reachable states: if `g₁` is reachable
  and `g₂` has the same `xclamp`, every move from either is matched by a move from the other to
  a state with the same `xclamp`.

So the quotient of the reachable states by `xclamp` is a finite transition system with the same
moves. Unlike `Reach.finite`, this allows damage reduction, `drain`, and carried and
rest-of-game modifiers (the latter only from GX attacks and Item and Supporter cards); unlike
`Reach.finite`, it forbids amounts under `iter`. The bisimulation half holds for all pairs of
states with equal `xclamp` (`GameState.xclamp_bisim`). Since milestone M6 the clamp takes its bound,
`Enum.bound g₀.allCards`, which bounds every derived HP; before it the clamp capped at the printed HP
and had no parameter. The list is not computed and the quotient's moves are not shown
computable. -/
theorem xfinite {g₀ : GameState} (hF : g₀.StoreSafe) :
    (∃ L : List GameState, ∀ g, Reach g₀ g → g.xclamp (Enum.bound g₀.allCards) ∈ L) ∧
      ∀ g₁ g₂, Reach g₀ g₁ →
        g₁.xclamp (Enum.bound g₀.allCards) = g₂.xclamp (Enum.bound g₀.allCards) →
        (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧
          g₁'.xclamp (Enum.bound g₀.allCards) = g₂'.xclamp (Enum.bound g₀.allCards)) ∧
        (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧
          g₂'.xclamp (Enum.bound g₀.allCards) = g₁'.xclamp (Enum.bound g₀.allCards)) := by
  obtain ⟨L, hL⟩ := Reach.xclamp_mem_bounded (storeBound g₀)
  exact ⟨⟨L, fun g h => hL g h (reach_boundedStores hF h)⟩,
    fun _ _ h hc => Reach.xclamp_bisim h hc⟩

end StoreSafe

end Pokemon
