import Pokemon.Trainer
import Pokemon.Finite

/-!
# One-turn history (milestone MV2, stage 3)

Survey S13 §A. The commonest history shapes of today's Standard that the model now expresses:

* "If any of your Pokémon were Knocked Out by damage from an attack during your opponent's last
  turn, this attack does 60 more damage" (Iron Leaves sv6-19; 10 refused cards, 8 without a
  name-prefix filter) and "… were Knocked Out during your opponent's last turn" (Hassel sv6-151,
  Fezandipiti ex sv6pt5-38): `Count.koLast w atk`, read from the player's Knock Out history
  (`PlayerState.ko : KOHist`);
* "If this Pokémon moved from your Bench to the Active Spot this turn" (Keldeo ex rsv10pt5-30; 4):
  `Test.movedUp`, read from `InPlay.movedUp`;
* "If this Pokémon evolved from X during this turn" (Gholdengo sv8-131; 5): `Test.evolved`, which
  needs no new state (`InPlay.fresh` and a card under the top card).

**The record and why it is finite.** History is four flags per player (`KOHist`: a Knock Out of
one of the player's Pokémon in the current turn, the same after an attack, and both for the
previous turn) and one flag per Pokémon in play (`InPlay.movedUp`). Nothing is counted, so no new
quantity needs a bound: the record takes `2⁴` values per player (`Enum.mem_kohists`) and two per
Pokémon, and the finite lists of `Reach.clamp_mem` and `StoreSafe.xfinite` enumerate them (`Enum.players`,
`Enum.inPlays`, and their counterparts in `Pokemon/Bounded.lean`). Neither clamp touches a flag:
the clamps change damage, Poison strength and (the capped clamp) the stores only, so both keep
the record exactly (`Count.val_clampAt`, `Count.val_xclampAt` for `koLast`; `InPlay.Agree.movedUp`
for the per-Pokémon flag).

**Where the flags are set.** `GameState.koStep` (the batch Knock Out check) records, for each
player, whether one of their Pokémon was Knocked Out, outside Pokémon Checkup (`between = false`)
and, separately, after the turn's attack (`attacked = true`); `Move.endTurn` shifts both players'
histories (`KOHist.shift`), as it shifts the lingering stores. A retreat and a `switch .own` mark
the Pokémon that comes into the Active Spot (`InPlay.moveUp`), and the end of its owner's turn
clears the mark (`InPlay.unfresh`).

**Departures** (Known gaps in `Pokemon/Rules.lean`). "Knocked Out by damage from an attack" is
read as "Knocked Out by the check after an attack": damage counters an attack's effect places
also count (a superset). A promotion after a Knock Out of the player's own Active Pokémon in their
own turn does not set `movedUp` (an under-model; promotions in the opponent's turn and between
turns are rightly not moves in the owner's turn, and set nothing).
-/

namespace Pokemon

/-- The end of a turn shifts the Knock Out history of both players: the player who now moves
reads, as "last turn", what happened to their Pokémon in the turn just ended. (Milestone MV7 added
the premise `g.pend = false` of `Move.endTurn`.) -/
theorem Move.endTurn_ko {g : GameState} {a b : InPlay} {bo bc : List InPlay}
    (fa sa ca fb sb cb : Bool) (ha : g.opp.active = some a) (hb : g.cur.active = some b)
    (hk : DamageBounded g) (hbt : g.between = false) (hco : BenchChar g.opp.bench bo)
    (hcc : BenchChar (g.cur.bench.map InPlay.unfresh) bc) (hpd : g.pend = false) :
    ∃ g', Move g g' ∧ g'.cur.ko.last = g.opp.ko.now ∧ g'.cur.ko.lastAtk = g.opp.ko.nowAtk ∧
      g'.cur.ko.now = false ∧ g'.opp.ko.last = g.cur.ko.now :=
  ⟨_, .endTurn fa sa ca fb sb cb ha hb hk hbt hco hcc hpd, rfl, rfl, rfl, rfl⟩

/-- The batch Knock Out check outside Checkup records a Knock Out of the opponent's Pokémon. -/
theorem GameState.koStep_noteOpp {g : GameState} (hbt : g.between = false)
    (hk : 0 < g.koVal .opp) : g.koStep.opp.ko.now = true := by
  simp only [GameState.koStep, PlayerState.noteKO, KOHist.note, hbt, Bool.not_false,
    decide_eq_true hk, Bool.and_self, Bool.or_true]

/-- A retreat marks the Pokémon that comes into the Active Spot: "this Pokémon moved from your
Bench to the Active Spot this turn" holds for it. -/
theorem Move.retreat_movedUp {g : GameState} {a q : InPlay} {b₁ b₂ : List InPlay}
    {paid rest : List Card} (ha : g.cur.active = some a) (hb : g.cur.bench = b₁ ++ q :: b₂)
    (hr : g.cur.retreated = false) (he : Split .any a.energy paid rest)
    (hp : retreatPaid (g.retreatOf a) (paid.map a.unitCount) = true) (hs : a.rot.canAct = true) (hbt : g.between = false)
    (hst : Settled g) (hl : g.cur.mods.live.noRetreat = false) (hat : g.attacked = false) :
    ∃ g' a', Move g g' ∧ g'.cur.active = some a' ∧ a'.top = q.top ∧
      (Test.movedUp .own).eval g' a' = true :=
  ⟨_, _, .retreat ha hb hr he hp hs hbt hst hl hat, rfl, InPlay.noteMove_top _ _ _,
    InPlay.noteMove_movedUp _ _ _⟩

/-- Evolving the Active Pokémon makes "this Pokémon evolved during this turn" true for it. -/
theorem Move.evolve_evolved {g : GameState} {l₁ l₂ : List Card} {p : PokemonCard}
    {a : InPlay} (hh : g.cur.hand = l₁ ++ Card.pokemon p :: l₂) (ha : g.cur.active = some a)
    (he : p.evolvesFrom = some a.top.name) (hfr : a.fresh = false) (hf : g.cur.hadTurn = true)
    (hbt : g.between = false) (hst : Settled g) (hat : g.attacked = false) :
    ∃ g' a', Move g g' ∧ g'.cur.active = some a' ∧ a'.top = p ∧
      (Test.evolved .own).eval g' a' = true :=
  ⟨_, _, .evolve hh ha he hfr hf hbt hst hat, rfl, rfl, rfl⟩

/-- A Pokémon put into play this turn as a Basic did not evolve this turn. -/
theorem InPlay.ofBasic_not_evolved (p : PokemonCard) (g : GameState) :
    (Test.evolved .own).eval g (InPlay.ofBasic p) = false := rfl

/-- The end of a turn clears the per-Pokémon history of the player whose turn ends. -/
theorem InPlay.unfresh_checkup_movedUp (b : InPlay) (o f s c : Bool) :
    ((b.unfresh).checkup o f s c).movedUp = false := rfl

/-- Both clamps keep the history: a test on it reads the same in agreeing Pokémon. -/
theorem Test.movedUp_agree {K : Nat} {c : Cap} {q p : InPlay} (h : InPlay.Agree K c q p)
    (w : Whose) (g₁ g₂ : GameState) : (Test.movedUp w).eval g₂ q = (Test.movedUp w).eval g₁ p := by
  simp only [Test.eval, h.movedUp]

/-- The Knock Out history takes finitely many values: 16. -/
theorem KOHist.finite : ∃ L : List KOHist, L.length = 16 ∧ ∀ h : KOHist, h ∈ L :=
  ⟨Enum.kohists, rfl, Enum.mem_kohists⟩

namespace History

open Trainer

/-- `move_after2` Knocks Out the opponent's Active Pokémon with an Item in the player's turn; the
opponent's history records it for this turn. -/
theorem after2_noted : after2.opp.ko.now = true ∧ after2.opp.ko.nowAtk = false := ⟨rfl, rfl⟩

theorem after2_settled : Settled after2 := (GameState.settled_iff _).2 (by decide)

/-- The state after the player ends the turn from `after2` (no Special Condition, no Char). -/
def after2End : GameState :=
  { cur := { after2.opp with
      active := some (InPlay.checkup false false false false
        { InPlay.ofBasic big with damage := 0 + 5 }),
      energyAttached := false, supporterPlayed := false, retreated := false,
      mods := after2.opp.mods.shift, ko := after2.opp.ko.shift, supCard := none },
    opp := { after2.cur.unfresh with
      active := some ((InPlay.ofBasic big).unfresh.checkup true false false false), bench := [],
      mods := after2.cur.mods.shift, hadTurn := true, ko := after2.cur.ko.shift },
    curIsFirst := false, firstTurn := false, attacked := false, between := true, winner := none,
    stadium := none, stadiumPlayed := false, stadiumUsed := false }

theorem after2_end : Move after2 after2End :=
  .endTurn_of_zero false false false false false false rfl rfl after2_settled.1 rfl .nil .nil
    (by decide) (by decide)

/-- **Witness: a history test false, then true across a turn boundary.** "If any of your Pokémon
were Knocked Out during your opponent's last turn": false for the opponent while the turn in which
their Pokémon was Knocked Out goes on (`after2`, read from their side: `.opp`), true for them once
it has ended and they move (`after2End`, `.own`). "… by damage from an attack" stays false: the
Knock Out came from an Item. -/
theorem koLast_across_turn :
    (Count.koLast .opp false).val after2 = 0 ∧ (Count.koLast .own false).val after2End = 1 ∧
      (Count.koLast .own true).val after2End = 0 := ⟨rfl, rfl, rfl⟩

/-- The same test as an `ite` condition, true in `after2End`. -/
theorem koLast_test : (Test.countGe (.koLast .own false) 1).eval after2End
    (InPlay.ofBasic big) = true := rfl

/-- **Witness: the record lasts one turn.** Two consecutive ends of turn, with the draw between
them: the Knock Out recorded for the opponent in `after2`'s turn is visible to them as "last turn"
through the whole of their next turn (after the end of turn and after their draw), and once they end
that turn it is gone: the shift has replaced it by their (empty) record of the turn just ended. -/
theorem koLast_forgotten :
    ∃ g₂ g₃, Move after2 after2End ∧ Move after2End g₂ ∧ Move g₂ g₃ ∧
      after2.opp.ko.now = true ∧
      (Count.koLast .own false).val after2End = 1 ∧ (Count.koLast .own false).val g₂ = 1 ∧
      (Count.koLast .opp false).val g₃ = 0 :=
  ⟨_, _, after2_end,
    .startTurn rfl rfl rfl (by exact ((GameState.settled_iff _).2 (by decide)).1) rfl,
    .endTurn_of_zero false false false false false false rfl rfl
      (by exact ((GameState.settled_iff _).2 (by decide)).1) rfl .nil .nil (by decide) (by decide),
    rfl, rfl, rfl, rfl⟩

end History

end Pokemon
