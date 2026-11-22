import Pokemon.Vocab4

/-!
# Per-Pokémon attack locks (milestone MV4, stage 2)

Survey S17 §C, the largest history shape among refused Standard cards (27): "During your next turn,
this Pokémon can't use [this attack]" (Feraligatr svp-89: "During your next turn, this Pokémon can't
use Giant Wave."). The rulebook makes it an effect on the Pokémon, not on the player: "if an Active
Pokémon moves to the Bench, all effects of attacks go away" (2026 p. 20) and "Any effects of attacks
… end when it evolves" (p. 11).

The record is `InPlay.lk : LockState`, two values of the three-valued `AtkLock` (four-valued since milestone MV6, `AtkLock.note`; nine, now sixteen, values per
Pokémon, in the enumeration `Enum.lockStates`), kept exactly by both clamps (`InPlay.clampWith`
changes only damage and Poison strength; `InPlay.Agree.lk`). It is

* set by `Move.attack` on the attacking Pokémon: `lk.new := atk.lockSet` (`GameState.afterAttack`,
  `InPlay.noteLock`; `Attack.lockSet` is the printed `Attack.selfLock` unless the attack may switch
  the attacker out);
* shifted at the end of its owner's turn (`InPlay.unfresh`: `on := new`, `new := none`), so a lock
  set in the owner's turn is in force during the opponent's turn (where it is not read) and the
  owner's next turn, and gone at the end of that turn;
* read by `Move.attack` and `Move.attackConfused` (`AtkLock.allows`: `this` forbids the attacks
  whose `selfLock` is `this`, `all` forbids every attack);
* cleared when the Pokémon moves to the Bench (`Move.retreat`; `Effect.switch`, through
  `InPlay.unlock`) and when it evolves (`Move.evolve`, `Move.evolveBench`).

Nothing is counted: the record takes finitely many values whatever the cards. The witnesses below
trace two turns of each player from a well-formed, `Settled` start: Giant Wave is used, is illegal
in its user's next turn (every attack then is Splash, which does nothing), and is legal in the turn
after that; and a retreat in the locked turn clears the lock.
-/

namespace Pokemon.Lock

open Trainer

/-- "Giant Wave": 20 damage. "During your next turn, this Pokémon can't use Giant Wave." -/
def wave : Attack :=
  { name := "Giant Wave", cost := [], damage := 2, effect := .skip, gx := false, selfLock := .this }

/-- An attack that does nothing. -/
def splash : Attack := ⟨"Splash", [], 0, .skip, false, .none⟩

/-- The locked Pokémon: 100 HP, no Retreat Cost. -/
def feral : PokemonCard := ⟨"Feraligatr", .basic, none, 10, .water, [wave, splash], 0, none, none,
  .none, false, []⟩

/-- Three cards to draw. -/
def deck3 : List Card := [.energy .grass, .energy .grass, .energy .grass]

/-- The first player (to move) has `feral` Active and `big` on the Bench; the second has `big`
Active; one Prize card each, one card in each deck. -/
def g0 : GameState :=
  ⟨{ side [] [.energy .fire] (InPlay.ofBasic feral) [InPlay.ofBasic big] with deck := deck3 },
    { side [] [.energy .fire] (InPlay.ofBasic big) [] with deck := deck3 },
    true, false, false, false, none, none, false, false⟩

theorem g0_wellFormed : WellFormed g0 := by
  refine ⟨fun _ => ⟨by simp [g0, side], by simp [g0, side]⟩, fun p hp => ?_, fun p hp => by cases hp⟩
  simp only [g0, side, List.mem_singleton] at hp
  subst hp
  exact ⟨rfl, rfl, rfl, rfl⟩

theorem g0_settled : Settled g0 := (GameState.settled_iff _).2 (by decide)

/-- The end of a turn with every coin flip tails and every Bench unchanged by Char counters: the
state `Move.endTurn` gives. -/
def endT (g : GameState) : GameState :=
  { cur := { g.opp with
      active := g.opp.active.map (InPlay.checkup false false false false), bench := g.opp.bench,
      energyAttached := false, supporterPlayed := false, retreated := false,
      mods := g.opp.mods.shift, ko := g.opp.ko.shift },
    opp := { g.cur.unfresh with
      active := g.cur.active.map (fun b => b.unfresh.checkup true false false false),
      bench := g.cur.bench.map InPlay.unfresh,
      mods := g.cur.mods.shift, hadTurn := true, ko := g.cur.ko.shift },
    curIsFirst := !g.curIsFirst, firstTurn := false, attacked := false,
    between := true, winner := g.winner, stadium := g.stadium, stadiumPlayed := false,
    stadiumUsed := false }

theorem endT_move {g : GameState} {a b : InPlay} (ha : g.opp.active = some a)
    (hb : g.cur.active = some b) (hk : DamageBounded g) (hbt : g.between = false) :
    Move g (endT g) := by
  have := Move.endTurn false false false false false false ha hb hk hbt (BenchChar.refl _)
    (BenchChar.refl _)
  simp only [endT, ha, hb, Option.map_some]
  exact this

/-- The draw that starts a turn. -/
def startT (g : GameState) : GameState :=
  { g with cur := { g.cur with deck := g.cur.deck.drop 1, hand := g.cur.deck.take 1 ++ g.cur.hand },
           between := false }

theorem startT_move {g : GameState} {a b : InPlay} {c : Card} {d : List Card}
    (hbt : g.between = true) (ha : g.opp.active = some a) (hb : g.cur.active = some b)
    (hk : DamageBounded g) (hd : g.cur.deck = c :: d) : Move g (startT g) := by
  have := Move.startTurn hbt ha hb hk hd
  simp only [startT, hd, List.drop_succ_cons, List.drop_zero, List.take_succ_cons, List.take_zero,
    List.singleton_append]
  exact this

/-- After Giant Wave: the defender has 2 damage counters, the attacker the lock `this` to come. -/
def g1 : GameState :=
  ({ g0 with opp := { g0.opp with active := some { InPlay.ofBasic big with damage := 2 } } } :
    GameState).afterAttack .this false

theorem g0_g1 : Move g0 g1 :=
  .attack (atk := wave) rfl (.head _) (.nil _) rfl rfl rfl rfl g0_settled
    (.seq (.damage (.const 2 _) rfl) (.skip _)) rfl (fun h => nomatch h) rfl
    (HitTrig.exists_nil (.seq (.damage (.const 2 _) rfl) (.skip _)) rfl) (.nil _) rfl

/-- The second player's turn begins: the lock is in force (`on`), set in the first player's turn. -/
def g2 : GameState := startT (endT g1)
/-- The second player ends the turn without attacking; the first player draws. -/
def g3 : GameState := startT (endT g2)

theorem g1_g3 : Reach g1 g3 := by
  have s1 : Settled g1 := (GameState.settled_iff _).2 (by decide)
  have m1 : Move g1 (endT g1) := endT_move rfl rfl s1.1 rfl
  have s2 : Settled (endT g1) := (GameState.settled_iff _).2 (by decide)
  have m2 : Move (endT g1) g2 := startT_move rfl rfl rfl s2.1 rfl
  have s3 : Settled g2 := (GameState.settled_iff _).2 (by decide)
  have m3 : Move g2 (endT g2) := endT_move rfl rfl s3.1 rfl
  have s4 : Settled (endT g2) := (GameState.settled_iff _).2 (by decide)
  have m4 : Move (endT g2) g3 := startT_move rfl rfl rfl s4.1 rfl
  exact .step (.step (.step (.step (.refl _) rfl m1) rfl m2) rfl m3) rfl m4

/-- In the first player's next turn the attacker carries the lock in force, `this`; the second
player's Pokémon carries none. -/
theorem g3_lock : g3.cur.active.map InPlay.lk = some { new := .none, on := .this } ∧
    g3.opp.active.map InPlay.lk = some {} ∧ g3.curIsFirst = true ∧ g3.between = false := by
  decide

theorem g3_settled : Settled g3 := (GameState.settled_iff _).2 (by decide)

/-- The first player's Active Pokémon in `g3`: the lock `this` in force. -/
def feral3 : InPlay := { InPlay.ofBasic feral with fresh := false, lk := { on := .this } }

theorem g3_cur : g3.cur.active = some feral3 ∧
    g3.cur.bench = [{ InPlay.ofBasic big with fresh := false }] ∧ g3.cur.hand = [.energy .grass] ∧
    g3.stadium = none ∧ g3.attacked = false ∧ g3.between = false :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem single_eq {a b : Card} {l₁ l₂ : List Card} (h : [a] = l₁ ++ b :: l₂) : a = b := by
  cases l₁ with
  | nil => simp only [List.nil_append, List.cons.injEq] at h; exact h.1
  | cons c l => simp only [List.cons_append, List.cons.injEq] at h; cases l <;> simp at h

/-- **Witness: the locked attack is illegal.** Every attack the first player can make from `g3` is
Splash, which changes nothing on the opponent's side: Giant Wave (2 more damage counters) is not a
legal move. -/
theorem g3_no_wave : ∀ g', Move g3 g' → g'.attacked = true → g'.opp.active = g3.opp.active := by
  intro g' hm hat
  have hs := g3_settled
  obtain ⟨ha3, hb3, hh3, hs3, hat3, hbt3⟩ := g3_cur
  cases hm with
  | item hh => rw [hh3] at hh; nomatch single_eq hh
  | supporter hh => rw [hh3] at hh; nomatch single_eq hh
  | stadiumUse hs' => rw [hs3] at hs'; cases hs'
  | @ability g₁m g'' x sp ab hu hm =>
      cases hu with
      | active ha =>
          rw [ha3] at ha; cases ha
          simp [InPlay.abilities, feral3, InPlay.ofBasic, feral] at hm
      | bench hb =>
          have hx : x ∈ g3.cur.bench := by rw [hb]; simp
          rw [hb3, List.mem_singleton] at hx
          subst hx
          simp [InPlay.abilities, InPlay.ofBasic, big] at hm
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      rw [hh3] at hh; nomatch single_eq hh
  | @attack g₁ a atk ha hm hc hs' hn hf hbt hst hr hl _ _ _ _ hd ht hlk =>
      rw [ha3] at ha; cases ha
      simp only [InPlay.attacks, feral3, InPlay.ofBasic, feral, List.flatMap_nil, List.append_nil,
        List.mem_cons, List.not_mem_nil, or_false] at hm
      rcases hm with rfl | rfl
      · simp [AtkLock.allows, feral3, wave] at hlk
      · change Run .skip _ _ at hr
        cases hr with
        | skip =>
            obtain rfl := hd.nil_of rfl
            cases ht
            rfl
        | touchActive he => simp [Effect.touch] at he
        | touchBench he => simp [Effect.touch] at he
        | zone hw => simp [Effect.zSide] at hw
  | knockOuts h => exact absurd hs h.not_settled
  | endTurn => exact absurd hat (by simp)
  | _ => rfl

/-- **Witness: the lock is gone after a retreat.** In the locked turn the first player retreats
`feral3` (no Retreat Cost) to the Bench; it arrives with no lock (`lk = {}`), and its lock does not
pass to the Pokémon that comes in. -/
theorem g3_retreat_unlocks : ∃ g', Move g3 g' ∧
    g'.cur.bench.map InPlay.lk = [{}] ∧ g'.cur.active.map InPlay.lk = some {} := by
  refine ⟨_, .retreat (b₁ := []) (b₂ := []) (paid := []) (rest := []) rfl rfl rfl .nil rfl rfl rfl
    g3_settled rfl rfl, rfl, rfl⟩

/-- **Witness: the lock ends after the locked turn.** The first player uses Splash in the locked
turn (legal), the turns pass (the second player ends theirs without attacking), and in the first
player's turn after that, Giant Wave is a legal move again: it puts 2 more damage counters on the
defender, which has 2 from the first Giant Wave. -/
def g4 : GameState := (g3).afterAttack .none false

theorem g3_g4 : Move g3 g4 :=
  .attack (atk := splash) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl g3_settled
    (.skip _) rfl (fun h => nomatch h) rfl (HitTrig.exists_nil (.skip _) rfl) (.nil _) rfl

/-- After the turns pass: the second player's turn, then the first player's. -/
def g5 : GameState := startT (endT (startT (endT g4)))

theorem g4_g5 : Reach g4 g5 := by
  have s1 : Settled g4 := (GameState.settled_iff _).2 (by decide)
  have m1 : Move g4 (endT g4) := endT_move rfl rfl s1.1 rfl
  have s2 : Settled (endT g4) := (GameState.settled_iff _).2 (by decide)
  have m2 : Move (endT g4) (startT (endT g4)) := startT_move rfl rfl rfl s2.1 rfl
  have s3 : Settled (startT (endT g4)) := (GameState.settled_iff _).2 (by decide)
  have m3 : Move (startT (endT g4)) (endT (startT (endT g4))) := endT_move rfl rfl s3.1 rfl
  have s4 : Settled (endT (startT (endT g4))) := (GameState.settled_iff _).2 (by decide)
  have m4 : Move (endT (startT (endT g4))) g5 := startT_move rfl rfl rfl s4.1 rfl
  exact .step (.step (.step (.step (.refl _) rfl m1) rfl m2) rfl m3) rfl m4

theorem g5_lock : g5.cur.active.map InPlay.lk = some {} ∧ g5.curIsFirst = true := by decide

theorem g5_wave : ∃ g', Move g5 g' ∧
    g'.opp.active.map InPlay.damage = some 4 := by
  have s : Settled g5 := (GameState.settled_iff _).2 (by decide)
  exact ⟨_, .attack (atk := wave) rfl (.head _) (.nil _) rfl rfl rfl rfl s
    (.seq (.damage (.const 2 _) rfl) (.skip _)) rfl (fun h => nomatch h) rfl
    (HitTrig.exists_nil (.seq (.damage (.const 2 _) rfl) (.skip _)) rfl) (.nil _) rfl, rfl⟩

/-- **The trace**: from a well-formed, `Settled` start, Giant Wave is used (turn 1, first player),
the turns pass (turn 2), Giant Wave is illegal and Splash is used (turn 3), the turns pass (turn
4), and Giant Wave is legal (turn 5). -/
theorem trace : WellFormed g0 ∧ Settled g0 ∧ Move g0 g1 ∧ Reach g1 g3 ∧
    (∀ g', Move g3 g' → g'.attacked = true → g'.opp.active = g3.opp.active) ∧
    Move g3 g4 ∧ Reach g4 g5 ∧ ∃ g', Move g5 g' ∧ g'.opp.active.map InPlay.damage = some 4 :=
  ⟨g0_wellFormed, g0_settled, g0_g1, g1_g3, g3_no_wave, g3_g4, g4_g5, g5_wave⟩

end Pokemon.Lock
