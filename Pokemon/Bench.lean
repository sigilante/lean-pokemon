import Pokemon.Trainer
import Pokemon.Turn

/-!
# The Bench (milestone M3)

Witnesses for the rules milestone M3 added: Knock Outs give the Prize cards of the Knocked Out
Pokémon's rule box, and a player who takes their last Prize card in the middle of a multi-Prize
Knock Out wins.

* `twoPrizes_reachable`: an Item Knocks Out the opponent's Pokémon ex (2 Prize cards) in
  mid-effect; the player takes two Prize cards and the game goes on.
* `lastPrize_reachable`: the same Knock Out with one Prize card left: the player takes it, has
  taken their last Prize card, and wins.
* `attachBench_reachable`, `benchKO_reachable`: Energy attached to a Benched Pokémon; a Benched
  Pokémon evolved into a card with less HP than its damage, which leaves a Knock Out pending on
  the Bench, and its Knock Out (the opponent takes a Prize card; nobody is promoted).
* `doubleKO_reachable`: one step of an Item puts damage counters on each of the opponent's
  Benched Pokémon; two Knock Outs are pending at once, and both are taken together, by one batch
  Knock Out step, before the next step.
* `charBench_reachable`: a Char counter on a Benched Pokémon puts 2 damage counters on it
  between turns (tails), which Knocks it Out on the Bench.
* `gust_reachable`: an Item switches the opponent's 50-HP Benched Pokémon into the Active Spot
  and Knocks it Out there; `switch_cures`: from a well-formed start, the player's Poisoned,
  Burned and Confused Active Pokémon switched to the Bench has no Special Condition and Poison
  strength 0; `whirl_reachable`: an attack does damage, Paralyzes, and switches the opponent's
  Active Pokémon to the Bench, cured.
* `threePrizes_reachable`: a Mega Evolution Pokémon ex Knocked Out gives three Prize cards;
  `benchTwoPrizes_reachable`: a Pokémon ex Knocked Out on the Bench gives two.
* `benchHeal_reachable`: an Item heals one of the player's Benched Pokémon.
* `HitAt`, `HitAt.attacker`, `Attack.attacker_at_hit`: in a well-formed attack every damage step
  is reached with the attacking Pokémon still Active (`Effect.switchSafe`);
  `switchThenHit_not_wf`: an attack that switches its user out and then does damage is not well
  formed, so it cannot be used; the printed order (damage, then switch) is.
* `teraBench_reachable`: an attack does 50 damage to each of the opponent's Benched Pokémon; the
  Tera Pokémon among them takes none, the other is left at its HP and is Knocked Out next;
  `benchDamage_reachable`: an attack does 50 damage to one of two Benched Pokémon.
* `suddenDeath_forced`, `bothWays_wins` (milestone batch-KO): an attack Knocks Out both Active
  Pokémon when each player has one Prize card left; every move from there gives the rulebook's
  outcome (rulebook 2023 p. 21): Sudden Death when each player wins in one way, a win for the
  player who also left the opponent with no Pokémon. Before milestone batch-KO the order of the
  two Knock Outs decided the game.
-/

namespace Pokemon.Bench

open Trainer

/-- A Basic Pokémon ex with 50 HP: its Knock Out gives two Prize cards. -/
def exMon : PokemonCard := ⟨"ExMon", .basic, none, 5, .grass, [], 1, none, none, .ex, false, []⟩

/-- Put 5 damage counters on the opponent's Active Pokémon. -/
def hit5 : Card := .trainer "Hit5" .item (.counters 5)

/-- The player to move has `prizes` and `hit5` in hand; the opponent has `exMon` Active and a
100-HP Pokémon on the Bench. -/
def exStart (prizes : List Card) : GameState :=
  ⟨side [hit5] prizes (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic exMon) [InPlay.ofBasic big],
    true, false, false, false, none, none, false, false⟩

theorem exStart_wellFormed (c : Card) (cs : List Card) : WellFormed (exStart (c :: cs)) := by
  refine ⟨fun _ => ⟨by simp [exStart, Trainer.side], by simp [exStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [exStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact benched_ofBasic (by decide)

theorem exStart_settled (prizes : List Card) : Settled (exStart prizes) :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by simp only [exStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)

/-- **Witness: a Knock Out gives two Prize cards.** From a well-formed, `Settled` start in which
the player to move has three Prize cards, playing `hit5` Knocks Out the opponent's Pokémon ex in
mid-effect: the player takes two Prize cards, the opponent promotes, and nobody has won. -/
theorem twoPrizes_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.winner = none ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.cur.prizes.length + 2 = g₀.cur.prizes.length ∧
        g.cur.hand.length = 2 ∧ Card.pokemon exMon ∈ g.opp.discard ∧ g.winner = none := by
  refine ⟨exStart [.energy .fire, .energy .fire, .energy .fire], exStart_wellFormed _ _,
    exStart_settled _, rfl, ?_⟩
  have hm : Move (exStart [.energy .fire, .energy .fire, .energy .fire]) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Hit5") rfl rfl (exStart_settled _)
      (.prim rfl rfl (.counters 5 rfl)
        (.step rfl (.go (by decide) rfl .keep (.pick (b₁ := [])))
          (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
            (fun p hp => by cases hp)))))) rfl rfl rfl rfl
  exact ⟨_, hm, .step (.refl _) rfl hm, rfl, rfl, .head _, rfl⟩

/-- **Witness: the last Prize card in the middle of a multi-Prize Knock Out wins.** With one
Prize card left, Knocking Out a Pokémon ex (two Prize cards) takes that card, and the player who
took it wins. -/
theorem lastPrize_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.winner = none ∧ g₀.cur.prizes.length = 1 ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.cur.prizes = [] ∧ g.cur.hand.length = 1 ∧
        g.winner = some (.win g₀.curIsFirst) := by
  refine ⟨exStart [.energy .fire], exStart_wellFormed _ _, exStart_settled _, rfl, rfl, ?_⟩
  have hm : Move (exStart [.energy .fire]) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Hit5") rfl rfl (exStart_settled _)
      (.prim rfl rfl (.counters 5 rfl)
        (.step rfl (.won (by decide) (by decide)) (.done (.inr (by decide))))) rfl rfl rfl rfl
  exact ⟨_, hm, .step (.refl _) rfl hm, rfl, rfl, rfl⟩

/-! ## Energy and evolution on the Bench, and a Knock Out on the Bench -/

/-- A Basic Pokémon with 50 HP. -/
def low : PokemonCard := ⟨"Low", .basic, none, 5, .grass, [], 1, none, none, .none, false, []⟩

/-- A Stage 1 Pokémon that evolves from `low` and has 20 HP. -/
def weak : PokemonCard := ⟨"Weak", .stage1, some "Low", 2, .grass, [], 1, none, none, .none, false, []⟩

/-- `low` on the Bench since an earlier turn, with 3 damage counters. -/
def lowBenched : InPlay := { InPlay.ofBasic low with damage := 3, fresh := false }

/-- The player to move has `big` Active, `lowBenched` on the Bench, and a Grass Energy and
`weak` in hand; the opponent has two Prize cards. -/
def benchStart : GameState :=
  ⟨side [.energy .grass, .pokemon weak] [.energy .fire] (InPlay.ofBasic big) [lowBenched],
    side [] [.energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none, false, false⟩

theorem benchStart_wellFormed : WellFormed benchStart := by
  refine ⟨fun _ => ⟨by simp [benchStart, Trainer.side], by simp [benchStart, Trainer.side]⟩,
    fun p hp => ?_, fun p hp => by cases hp⟩
  simp only [benchStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem benchStart_settled : Settled benchStart :=
  settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by simp only [benchStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by cases hp)

/-- **Witness: Energy attached to a Benched Pokémon.** The turn's Energy attachment goes to
`lowBenched` on the Bench. -/
theorem attachBench_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g q, Move g₀ g ∧ Reach g₀ g ∧ g.cur.bench = [q] ∧
      q.energy = [.energy .grass] ∧ g.cur.energyAttached = true := by
  have hm : Move benchStart _ :=
    .attachBench (l₁ := []) (b₁ := []) rfl rfl rfl rfl benchStart_settled rfl
  exact ⟨benchStart, benchStart_wellFormed, benchStart_settled, _, _, hm, .step (.refl _) rfl hm,
    rfl, rfl, rfl⟩

/-- `lowBenched` evolved into `weak`. -/
def weakBenched : InPlay :=
  { lowBenched with top := weak, under := [.pokemon low], fresh := true }

/-- The board after evolving `lowBenched`: the Grass Energy is still in hand. -/
def benchMid : GameState :=
  { benchStart with cur := { benchStart.cur with hand := [.energy .grass], bench := [weakBenched] } }

/-- **Witness: a Knock Out on the Bench.** Evolving `lowBenched` (3 damage counters) into `weak`
(20 HP) is legal and leaves a Knock Out pending on the Bench; the next move Knocks it Out: its
cards go to the discard pile, the opponent takes a Prize card, and the Active Pokémon stays. -/
theorem benchKO_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g₁ g₂, Move g₀ g₁ ∧ Move g₁ g₂ ∧ Reach g₀ g₂ ∧
      ¬ DamageBounded g₁ ∧ Card.pokemon weak ∈ g₂.cur.discard ∧ g₂.cur.bench = [] ∧
      g₂.cur.active = g₀.cur.active ∧ g₂.opp.prizes.length + 1 = g₀.opp.prizes.length ∧
      g₂.winner = none := by
  have h₁ : Move benchStart benchMid :=
    .evolveBench (l₁ := [.energy .grass]) (l₂ := []) (p := weak) (q := lowBenched) (b₁ := [])
      (b₂ := []) rfl rfl rfl rfl rfl rfl
      benchStart_settled rfl
  have h₂ : Move benchMid _ := Move.knockOuts_of_nil (.go (by decide) rfl .keep .keep) rfl
  refine ⟨benchStart, benchStart_wellFormed, benchStart_settled, _, _, h₁, h₂,
    .step (.step (.refl _) rfl h₁) rfl h₂, fun hk => ?_, .head _, rfl, rfl, rfl, rfl⟩
  have := hk .own .bench weakBenched (List.Mem.head _)
  exact absurd this (by decide)

/-! ## Several Knock Outs from one step -/

/-- Put 5 damage counters on each of the opponent's Benched Pokémon. -/
def spread5 : Card := .trainer "Spread" .item (.spreadCounters .opp 5)

/-- The opponent has `big` Active and two 50-HP Pokémon on the Bench; the player to move has three
Prize cards and `spread5` in hand. -/
def spreadStart : GameState :=
  ⟨side [spread5] [.energy .fire, .energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic low, InPlay.ofBasic low],
    true, false, false, false, none, none, false, false⟩

theorem spreadStart_wellFormed : WellFormed spreadStart := by
  refine ⟨fun _ => ⟨by simp [spreadStart, Trainer.side], by simp [spreadStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [spreadStart, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem spreadStart_settled : Settled spreadStart :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by
      simp only [spreadStart, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide)

/-- **Witness: two Knock Outs from one step.** From a well-formed, `Settled` start, `spread5`
puts 5 damage counters on both of the opponent's 50-HP Benched Pokémon in one step; both Knock
Outs are taken together (`Resolve`, one batch Knock Out step; before milestone batch-KO, two
`knockOutBench` moves) before the effect ends, the player takes two Prize cards, and the opponent's
Active Pokémon stays. -/
theorem doubleKO_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.opp.bench = [] ∧
      g.opp.active = g₀.opp.active ∧ g.cur.prizes.length + 2 = g₀.cur.prizes.length ∧
      g.winner = none := by
  have hm : Move spreadStart _ :=
    .item (l₁ := []) (l₂ := []) (n := "Spread") rfl rfl spreadStart_settled
      (.prim rfl rfl (.spreadCounters .opp 5 _)
        (.step rfl (.go (by decide) rfl .keep .keep)
          (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
            (fun p hp => by cases hp)))))) rfl rfl rfl rfl
  exact ⟨spreadStart, spreadStart_wellFormed, spreadStart_settled, _, hm,
    .step (.refl _) rfl hm, rfl, rfl, rfl, rfl⟩

/-! ## A Char counter on the Bench -/

/-- A Basic Pokémon with 20 HP. -/
def tiny : PokemonCard := ⟨"Tiny", .basic, none, 2, .grass, [], 1, none, none, .none, false, []⟩

/-- `tiny` on the Bench with a Char counter. -/
def charred : InPlay := (InPlay.ofBasic tiny).setMarks (Marks.set .char true)

/-- The player to move has `big` Active and `charred` on the Bench. -/
def charStart : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic big) [charred],
    side [] [.energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none, false, false⟩

theorem charStart_wellFormed : WellFormed charStart := by
  refine ⟨fun _ => ⟨by simp [charStart, Trainer.side], by simp [charStart, Trainer.side]⟩,
    fun p hp => ?_, fun p hp => by cases hp⟩
  simp only [charStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

/-- The board after the turn ends with tails for the Char counter. -/
def charMid : GameState :=
  charStart.passTurn false false false false false false (InPlay.ofBasic big) (InPlay.ofBasic big)
    [] [charred.unfresh.addDamage 2]

/-- **Witness: Char on the Bench.** Ending the turn with tails for the Char counter on the
Benched `tiny` (20 HP) puts 2 damage counters on it; between turns its Knock Out is pending, and
the new player to move Knocks it Out on the Bench. Before milestone M3 the Char counter acted only
in the Active Spot. -/
theorem charBench_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g₁ g₂, Move g₀ g₁ ∧ Move g₁ g₂ ∧ Reach g₀ g₂ ∧
      ¬ DamageBounded g₁ ∧ g₂.opp.bench = [] ∧ Card.pokemon tiny ∈ g₂.opp.discard := by
  have hs : Settled charStart :=
    settled_of rfl rfl (by decide) (by decide)
      (fun p hp => by simp only [charStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)
      (fun p hp => by cases hp)
  have h₁ : Move charStart charMid :=
    .endTurn (bo := []) (bc := [charred.unfresh.addDamage 2]) false false false false false false
      rfl rfl hs.1 rfl .nil (.cons (.burn rfl) .nil)
  have h₂ : Move charMid _ := Move.knockOuts_of_nil (.won (by decide) (by decide)) rfl
  refine ⟨charStart, charStart_wellFormed, hs, _, _, h₁, h₂, .step (.step (.refl _) rfl h₁) rfl h₂,
    fun hk => ?_, rfl, .head _⟩
  exact absurd (hk .opp .bench (charred.unfresh.addDamage 2) (List.Mem.head _))
    (by decide)

/-! ## Switching -/

/-- Switch in one of the opponent's Benched Pokémon, then put 5 damage counters on the
opponent's Active Pokémon. -/
def gust : Card := .trainer "Gust" .item (.seq (.switch .opp) (.counters 5))

def gustStart : GameState :=
  ⟨side [gust] [.energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic low],
    true, false, false, false, none, none, false, false⟩

theorem gustStart_wellFormed : WellFormed gustStart := by
  refine ⟨fun _ => ⟨by simp [gustStart, Trainer.side], by simp [gustStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [gustStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem gustStart_settled : Settled gustStart :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by simp only [gustStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)

/-- **Witness: a gust and a Knock Out in one Item.** The opponent's Benched 50-HP Pokémon is
switched into the Active Spot, Knocked Out by the second step, and the opponent promotes the
Pokémon that the switch sent to the Bench. -/
theorem gust_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧
      Card.pokemon low ∈ g.opp.discard ∧ g.opp.active = some (InPlay.ofBasic big).cure ∧
      g.opp.bench = [] ∧ g.cur.prizes.length + 1 = g₀.cur.prizes.length := by
  have hm : Move gustStart _ :=
    .item (l₁ := []) (l₂ := []) (n := "Gust") rfl rfl gustStart_settled
      (.seq (.prim rfl rfl (.switch (b₁ := []) .opp rfl rfl)
          (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
            (fun p hp => by
            simp only [GameState.updSide, List.nil_append, List.mem_singleton] at hp
            subst hp; decide)))))
        (.prim rfl rfl (.counters 5 rfl)
          (.step rfl (.go (by decide) rfl .keep (.pick (b₁ := [])))
            (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
              (fun p hp => by cases hp))))))) rfl rfl rfl rfl
  exact ⟨gustStart, gustStart_wellFormed, gustStart_settled, _, hm, .step (.refl _) rfl hm,
    .head _, rfl, rfl, rfl⟩

/-- Switch the player's Active Pokémon with one of their Benched Pokémon. -/
def switchCard : Card := .trainer "Switch" .item (.switch .own)

/-- The player to move has a Poisoned, Burned and Confused `big` Active, its Poison raised by 2,
and `low` on the Bench. -/
def switchStart : GameState :=
  ⟨side [switchCard] [.energy .fire]
      { InPlay.ofBasic big with poisoned := true, burned := true, rot := .confused, poisonUp := 2 }
      [InPlay.ofBasic low],
    side [] [.energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none, false, false⟩

theorem switchStart_wellFormed : WellFormed switchStart := by
  refine ⟨fun _ => ⟨by simp [switchStart, Trainer.side], by simp [switchStart, Trainer.side]⟩,
    fun p hp => ?_, fun p hp => by cases hp⟩
  simp only [switchStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

/-- **Witness: switching cures.** From a well-formed start, playing `switchCard` puts the
Poisoned, Burned and Confused Active Pokémon (Poison strength 2) on the Bench with no Special
Condition and Poison strength 0 (`Benched`: "When your Active Pokémon goes to your Bench …
Special Conditions … go away", rulebook 2023 p. 12). -/
theorem switch_cures :
    WellFormed switchStart ∧
      ∃ g q, Move switchStart g ∧ g.cur.bench = [q] ∧ q.top = big ∧ Benched q ∧
        (∃ p, switchStart.cur.active = some p ∧ p.poisoned = true ∧ p.burned = true ∧
          p.rot = .confused ∧ p.poisonUp = 2) := by
  have hm : Move switchStart _ :=
    .item (l₁ := []) (l₂ := []) (n := "Switch") rfl rfl
      (settled_of rfl rfl (by decide) (by decide)
        (fun p hp => by simp only [switchStart, Trainer.side, List.mem_singleton] at hp
                        subst hp; decide)
        (fun p hp => by cases hp))
      (.prim rfl rfl (.switch (b₁ := []) .own rfl rfl)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide)
          (fun p hp => by
            simp only [GameState.updSide, List.nil_append, List.mem_singleton] at hp
            subst hp; decide)
          (fun p hp => by cases hp))))) rfl rfl rfl rfl
  exact ⟨switchStart_wellFormed, _, _, hm, rfl, rfl, ⟨rfl, rfl, rfl, rfl⟩, _, rfl, rfl, rfl, rfl,
    rfl⟩

/-- An attack that does 10 damage and Paralyzes the opponent's Active Pokémon, then switches in
one of the opponent's Benched Pokémon. -/
def whirl : Attack := ⟨"Whirl", [], 1, .seq (.inflict .paralyzed) (.switch .opp), false⟩

def whirler : PokemonCard := ⟨"Whirler", .basic, none, 10, .grass, [whirl], 1, none, none, .none, false, []⟩

def whirlStart : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic whirler) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic low],
    true, false, false, false, none, none, false, false⟩

theorem whirlStart_wellFormed : WellFormed whirlStart := by
  refine ⟨fun _ => ⟨by simp [whirlStart, Trainer.side], by simp [whirlStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [whirlStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem whirlStart_settled : Settled whirlStart :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by simp only [whirlStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)

/-- **Witness: a switch of the opponent's Active Pokémon inside an attack.** From a well-formed,
`Settled` start, `whirl` does 10 damage to the opponent's Active `big`, Paralyzes it, and
switches in the opponent's Benched `low`: `big` goes to the Bench with its damage counter and
cured of the Paralysis. -/
theorem whirl_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g q, Move g₀ g ∧ Reach g₀ g ∧
      g.opp.active = some (InPlay.ofBasic low) ∧ g.opp.bench = [q] ∧ q.top = big ∧
      q.damage = 1 ∧ Benched q := by
  have hr : Run whirl.script whirlStart _ :=
    show Run (.seq (.damage (.const 1)) (.seq (.inflict .paralyzed) (.switch .opp))) _ _ from
      .seq (.damage (.const 1 _) rfl) (.seq (.inflict .paralyzed rfl)
        (.switch (b₁ := []) .opp rfl rfl))
  have hm : Move whirlStart _ :=
    .attack (atk := whirl) rfl (.head _) (.nil _) rfl rfl rfl rfl whirlStart_settled hr rfl
      (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _)
  exact ⟨whirlStart, whirlStart_wellFormed, whirlStart_settled, _, _, hm, .step (.refl _) rfl hm,
    rfl, rfl, rfl, rfl, ⟨rfl, rfl, rfl, rfl⟩⟩

/-! ## More Prize counts, healing and single-target damage on the Bench -/

/-- A Basic Mega Evolution Pokémon ex with 50 HP: its Knock Out gives three Prize cards. -/
def megaMon : PokemonCard := ⟨"MegaMon", .basic, none, 5, .grass, [], 1, none, none, .megaEx, false, []⟩

/-- The player to move has `prizes` and `hit5` in hand; the opponent has `megaMon` Active and a
100-HP Pokémon on the Bench. -/
def megaStart (prizes : List Card) : GameState :=
  ⟨side [hit5] prizes (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic megaMon) [InPlay.ofBasic big],
    true, false, false, false, none, none, false, false⟩

theorem megaStart_wellFormed (c : Card) (cs : List Card) : WellFormed (megaStart (c :: cs)) := by
  refine ⟨fun _ => ⟨by simp [megaStart, Trainer.side], by simp [megaStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [megaStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact benched_ofBasic (by decide)

theorem megaStart_settled (prizes : List Card) : Settled (megaStart prizes) :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by simp only [megaStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)

/-- **Witness: a Knock Out gives three Prize cards.** From a well-formed, `Settled` start in which
the player to move has four Prize cards, playing `hit5` Knocks Out the opponent's Mega Evolution
Pokémon ex in mid-effect: the player takes three Prize cards, the opponent promotes, and nobody
has won. -/
theorem threePrizes_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.winner = none ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.cur.prizes.length + 3 = g₀.cur.prizes.length ∧
        Card.pokemon megaMon ∈ g.opp.discard ∧ g.winner = none := by
  refine ⟨megaStart [.energy .fire, .energy .fire, .energy .fire, .energy .fire],
    megaStart_wellFormed _ _, megaStart_settled _, rfl, ?_⟩
  have hm : Move (megaStart [.energy .fire, .energy .fire, .energy .fire, .energy .fire]) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Hit5") rfl rfl (megaStart_settled _)
      (.prim rfl rfl (.counters 5 rfl)
        (.step rfl (.go (by decide) rfl .keep (.pick (b₁ := [])))
          (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
            (fun p hp => by cases hp)))))) rfl rfl rfl rfl
  exact ⟨_, hm, .step (.refl _) rfl hm, rfl, .head _, rfl⟩

/-- The opponent has `big` Active and the 50-HP Pokémon ex `exMon` on the Bench; the player to
move has three Prize cards and `spread5` in hand. -/
def exBenchStart : GameState :=
  ⟨side [spread5] [.energy .fire, .energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic exMon],
    true, false, false, false, none, none, false, false⟩

theorem exBenchStart_wellFormed : WellFormed exBenchStart := by
  refine ⟨fun _ => ⟨by simp [exBenchStart, Trainer.side], by simp [exBenchStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [exBenchStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem exBenchStart_settled : Settled exBenchStart :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by simp only [exBenchStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)

/-- **Witness: a multi-Prize Knock Out on the Bench.** `spread5` puts 5 damage counters on the
opponent's Benched Pokémon ex; its Knock Out on the Bench gives the player two Prize cards, with
no promotion, and the opponent's Active Pokémon stays. -/
theorem benchTwoPrizes_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.opp.bench = [] ∧
      g.opp.active = g₀.opp.active ∧ Card.pokemon exMon ∈ g.opp.discard ∧
      g.cur.prizes.length + 2 = g₀.cur.prizes.length ∧ g.winner = none := by
  have hm : Move exBenchStart _ :=
    .item (l₁ := []) (l₂ := []) (n := "Spread") rfl rfl exBenchStart_settled
      (.prim rfl rfl (.spreadCounters .opp 5 _)
        (.step rfl (.go (by decide) rfl .keep .keep)
          (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
            (fun p hp => by cases hp)))))) rfl rfl rfl rfl
  exact ⟨exBenchStart, exBenchStart_wellFormed, exBenchStart_settled, _, hm,
    .step (.refl _) rfl hm, rfl, rfl, .head _, rfl, rfl⟩

/-- Heal 20 damage from one of the player's Benched Pokémon. -/
def healBench : Card := .trainer "HealBench" .item (.benchHeal 2)

/-- The player to move has `big` Active, `lowBenched` (3 damage counters) on the Bench, and
`healBench` in hand. -/
def healStart : GameState :=
  ⟨side [healBench] [.energy .fire] (InPlay.ofBasic big) [lowBenched],
    side [] [.energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none, false, false⟩

theorem healStart_wellFormed : WellFormed healStart := by
  refine ⟨fun _ => ⟨by simp [healStart, Trainer.side], by simp [healStart, Trainer.side]⟩,
    fun p hp => ?_, fun p hp => by cases hp⟩
  simp only [healStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem healStart_settled : Settled healStart :=
  settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by simp only [healStart, Trainer.side, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by cases hp)

/-- **Witness: healing a Benched Pokémon.** `healBench` removes 2 of the 3 damage counters on the
Benched `lowBenched`. -/
theorem benchHeal_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧
      g₀.cur.bench = [lowBenched] ∧ g.cur.bench = [{ lowBenched with damage := 1 }] := by
  have hm : Move healStart _ :=
    .item (l₁ := []) (l₂ := []) (n := "HealBench") rfl rfl healStart_settled
      (.prim rfl rfl (.benchHeal (b₁ := []) 2 rfl)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide)
          (fun p hp => by
            simp only [List.nil_append, List.mem_singleton] at hp
            subst hp; decide)
          (fun p hp => by cases hp))))) rfl rfl rfl rfl
  exact ⟨healStart, healStart_wellFormed, healStart_settled, _, hm, .step (.refl _) rfl hm,
    rfl, rfl⟩

end Pokemon.Bench

/-! ## The attacker stays the attacker -/

namespace Pokemon

/-- `HitAt e g h`: resolving `e` from `g` reaches a damage step (`damage` or `drain`) in the
state `h`; the steps before it are resolved by `Run`, as in the resolution of `e`. -/
inductive HitAt : Effect → GameState → GameState → Prop where
  | damage (a : Amt) (g : GameState) : HitAt (.damage a) g g
  | drain (a : Amt) (g : GameState) : HitAt (.drain a) g g
  | iteT {t : Test} {a b : Effect} {g h : GameState} {p : InPlay}
      (hp : g.activeOf t.whose = some p) (ht : t.eval g p = true) :
      HitAt a g h → HitAt (.ite t a b) g h
  | iteF {t : Test} {a b : Effect} {g h : GameState} {p : InPlay}
      (hp : g.activeOf t.whose = some p) (ht : t.eval g p = false) :
      HitAt b g h → HitAt (.ite t a b) g h
  | seqL {a b : Effect} {g h : GameState} : HitAt a g h → HitAt (.seq a b) g h
  | seqR {a b : Effect} {g g₁ h : GameState} : Run a g g₁ → HitAt b g₁ h → HitAt (.seq a b) g h
  | choiceL {a b : Effect} {g h : GameState} : HitAt a g h → HitAt (.choice a b) g h
  | choiceR {a b : Effect} {g h : GameState} : HitAt b g h → HitAt (.choice a b) g h
  | iterHead {a : Effect} {g h : GameState} : HitAt a g h → HitAt (.iter a) g h
  | iterTail {a : Effect} {g g₁ h : GameState} :
      Run a g g₁ → HitAt (.iter a) g₁ h → HitAt (.iter a) g h

/-- An effect that reaches a damage step is not `ownFree`. -/
theorem HitAt.not_ownFree {e : Effect} {g h : GameState} (hh : HitAt e g h) :
    e.ownFree = false := by
  induction hh with
  | damage => rfl
  | drain => rfl
  | iteT _ _ _ ih => simp only [Effect.ownFree, ih, Bool.and_false, Bool.false_and]
  | iteF _ _ _ ih => simp only [Effect.ownFree, ih, Bool.and_false]
  | seqL _ ih => simp only [Effect.ownFree, ih, Bool.false_and]
  | seqR _ _ ih => simp only [Effect.ownFree, ih, Bool.and_false]
  | choiceL _ ih => simp only [Effect.ownFree, ih, Bool.false_and]
  | choiceR _ ih => simp only [Effect.ownFree, ih, Bool.and_false]
  | iterHead _ ih => simp only [Effect.ownFree, ih]
  | iterTail _ _ ih => exact ih

/-- The Pokémon cards of a Pokémon in play: its top card and the cards under it (its attached
Energy and Tools are not part of it). -/
def InPlay.pokemonCards (p : InPlay) : List Card := Card.pokemon p.top :: p.under

/-- Moving a damage counter leaves the same Pokémon in the Active Spot (milestone M8a). -/
theorem CMove.active_pokemonCards {f : Filter} {noKO : Bool} {a a' : Option InPlay}
    {b b' : List InPlay} (h : CMove f noKO hp a b a' b') :
    a'.map InPlay.pokemonCards = a.map InPlay.pokemonCards := by
  cases h <;> rfl

/-- A zone step leaves the same Pokémon (top card and the cards under it) in its player's Active
Spot; it may attach or discard Energy there. -/
theorem ZStep.active_pokemonCards {e : Effect} {s s' : PlayerState} (h : ZStep e s s') :
    s'.active.map InPlay.pokemonCards = s.active.map InPlay.pokemonCards := by
  cases h with
  | @move w src dst f q s s' t r hs hq hp => rw [hp.fields.2.1, Src.set_active]
  | @attachActive w src f tf s r t a hs ha ht => rw [ha]; rfl
  | @attachBench w src f tf s r t q b₁ b₂ hs hb ht => cases src <;> rfl
  | @putBench w src f s r p hs hst hhp hb => cases src <;> rfl
  | discardActive ha => rw [ha]; rfl
  | toolsActive ha => rw [ha]; rfl
  | moveAB ha => rw [ha]; rfl
  | moveBA ha => rw [ha]; rfl
  | _ => rfl

/-- An effect that does not switch the player's own Active Pokémon leaves the same Pokémon in the
player's Active Spot (its damage, markers, Special Conditions and, since milestone MV, attached
Energy may change; before MV the whole card list was kept). -/
theorem Run.cardList_of_switchesOwn {e : Effect} {g g' : GameState} (h : Run e g g')
    (hs : e.switchesOwn = false) :
    g'.cur.active.map InPlay.pokemonCards = g.cur.active.map InPlay.pokemonCards := by
  induction h with
  | iteT _ _ _ ih =>
      simp only [Effect.switchesOwn, Bool.or_eq_false_iff] at hs; exact ih hs.1
  | iteF _ _ _ ih =>
      simp only [Effect.switchesOwn, Bool.or_eq_false_iff] at hs; exact ih hs.2
  | seq _ _ ih₁ ih₂ =>
      simp only [Effect.switchesOwn, Bool.or_eq_false_iff] at hs
      exact (ih₂ hs.2).trans (ih₁ hs.1)
  | choiceL _ ih =>
      simp only [Effect.switchesOwn, Bool.or_eq_false_iff] at hs; exact ih hs.1
  | choiceR _ ih =>
      simp only [Effect.switchesOwn, Bool.or_eq_false_iff] at hs; exact ih hs.2
  | iterCons _ _ ih₁ ih₂ =>
      simp only [Effect.switchesOwn] at hs
      exact (ih₂ hs).trans (ih₁ hs)
  | heal _ h => rw [h]; rfl
  | cure h => rw [h]; rfl
  | selfDamage _ h => rw [h]; rfl
  | healAll h => rw [h]; rfl
  | drain _ _ hq => rw [hq]; rfl
  | @touchActive e w f g p he h =>
      cases w
      · simp only [GameState.side] at h; simp only [GameState.updSide, h]; rfl
      · rfl
  | unmark w m g =>
      cases w
      · simp only [GameState.updSide, PlayerState.unmark, Option.map_map]
        cases g.cur.active <;> rfl
      · rfl
  | switch w ha hb =>
      cases w
      · simp [Effect.switchesOwn] at hs
      · rfl
  | @touchBench _ w _ _ _ _ _ _ _ => cases w <;> rfl
  | linger w _ _ _ => cases w <;> rfl
  | @zone e w g s' hw hz =>
      cases w
      · simp only [GameState.side] at hz
        simp only [GameState.updSide, PlayerState.setZones]; exact hz.active_pokemonCards
      · rfl
  | @benchCounters _ _ _ _ w _ _ => cases w <;> rfl
  | spreadCounters w _ _ => cases w <;> rfl
  | @benchDamage _ _ _ _ w _ _ => cases w <;> rfl
  | spreadDamage w _ _ => cases w <;> rfl
  | moveCounter h => exact h.active_pokemonCards
  | _ => rfl

/-- **The attacker stays the attacker.** In a `switchSafe` effect, every damage step is reached
with the same Pokémon (top card and the cards under it) in the player's Active Spot as at the
start (since milestone MV its attached Energy may have changed): the Pokémon whose type the
damage step reads for Weakness and Resistance (`GameState.weak`, `GameState.resist`) is the one
that was Active when the effect began (its type can differ only by a Coloring counter). -/
theorem HitAt.attacker {e : Effect} {g h : GameState} (hh : HitAt e g h)
    (hs : e.switchSafe = true) :
    h.cur.active.map InPlay.pokemonCards = g.cur.active.map InPlay.pokemonCards := by
  induction hh with
  | damage => rfl
  | drain => rfl
  | iteT _ _ _ ih =>
      simp only [Effect.switchSafe, Bool.and_eq_true] at hs; exact ih hs.1
  | iteF _ _ _ ih =>
      simp only [Effect.switchSafe, Bool.and_eq_true] at hs; exact ih hs.2
  | seqL _ ih =>
      simp only [Effect.switchSafe, Bool.and_eq_true] at hs; exact ih hs.1.1
  | seqR hr hb ih =>
      simp only [Effect.switchSafe, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at hs
      obtain ⟨⟨-, hsb⟩, hso⟩ := hs
      have ha : _ = false := hso.resolve_right (by rw [hb.not_ownFree]; exact Bool.false_ne_true)
      exact (ih hsb).trans (hr.cardList_of_switchesOwn ha)
  | choiceL _ ih =>
      simp only [Effect.switchSafe, Bool.and_eq_true] at hs; exact ih hs.1
  | choiceR _ ih =>
      simp only [Effect.switchSafe, Bool.and_eq_true] at hs; exact ih hs.2
  | iterHead _ ih =>
      simp only [Effect.switchSafe, Bool.and_eq_true] at hs; exact ih hs.1
  | iterTail hr _ ih =>
      have hs' := hs
      simp only [Effect.switchSafe, Bool.and_eq_true, Bool.not_eq_true'] at hs'
      exact (ih hs).trans (hr.cardList_of_switchesOwn hs'.2)

/-- **The attacker at the damage step is the Pokémon that declared the attack.** For a
well-formed attack (`Attack.wf`, a premise of `Move.attack`) used by the Active Pokémon `a`,
every damage step of its script is reached with `a`'s Pokémon cards (top card and the cards under
it) in the Active Spot. Milestone MV weakened the statement from `a`'s whole card list: an
attack may attach Energy to its user before its damage step ("Attach a Basic Energy card from your
discard pile to this Pokémon"), which changes the card list but not the Pokémon. -/
theorem Attack.attacker_at_hit {atk : Attack} {g h : GameState} {a : InPlay}
    (hw : atk.wf = true) (ha : g.cur.active = some a) (hh : HitAt atk.script g h) :
    h.cur.active.map InPlay.pokemonCards = some a.pokemonCards := by
  rw [hh.attacker (Attack.script_switchSafe hw), ha]; rfl

end Pokemon

namespace Pokemon.Bench

open Trainer

/-- An attack that switches its user out and then does 10 damage: the damage step would read the
switched-in Pokémon's type. -/
def switchThenHit : Attack := ⟨"SwitchThenHit", [], 0, .seq (.switch .own) (.damage (.const 1)), false⟩

/-- The printed order: 10 damage, then switch this Pokémon with a Benched Pokémon. -/
def hitThenSwitch : Attack := ⟨"HitThenSwitch", [], 1, .switch .own, false⟩

/-- **Witness: switch-then-damage is not playable.** `switchThenHit` is not well formed, so no
`Move.attack` (nor `Move.attackConfused`) uses it; the printed order, `hitThenSwitch`, is. -/
theorem switchThenHit_not_wf : switchThenHit.wf = false ∧ hitThenSwitch.wf = true :=
  ⟨rfl, rfl⟩

/-! ## Attack damage to the Bench, and Tera -/

/-- 50 damage to each of the opponent's Benched Pokémon, no damage to the Active Pokémon. -/
def snipe : Attack := ⟨"Snipe", [], 0, .spreadDamage .opp 5, false⟩

/-- A 100-HP Basic Pokémon with `snipe`. -/
def sniper : PokemonCard := ⟨"Sniper", .basic, none, 10, .grass, [snipe], 1, none, none, .none, false, []⟩

/-- A 50-HP Basic Tera Pokémon ex. -/
def teraMon : PokemonCard := ⟨"TeraMon", .basic, none, 5, .grass, [], 1, none, none, .ex, true, []⟩

def snipeStart : GameState :=
  ⟨side [] [.energy .fire, .energy .fire] (InPlay.ofBasic sniper) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic low, InPlay.ofBasic teraMon],
    true, false, false, false, none, none, false, false⟩

theorem snipeStart_wellFormed : WellFormed snipeStart := by
  refine ⟨fun _ => ⟨by simp [snipeStart, Trainer.side], by simp [snipeStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [snipeStart, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem snipeStart_settled : Settled snipeStart :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by
      simp only [snipeStart, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide)

/-- **Witness: attack damage to the Bench, and Tera.** From a well-formed, `Settled` start, the
attack `snipe` does 50 damage to each of the opponent's Benched Pokémon: the 50-HP `low` gets 5
damage counters and its Knock Out is pending; the Tera Pokémon `teraMon` on the Bench takes no
damage. -/
theorem teraBench_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧
      g.opp.bench = [(InPlay.ofBasic low).addDamage 5, InPlay.ofBasic teraMon] ∧
      ¬ DamageBounded g := by
  have hm : Move snipeStart _ :=
    .attack (atk := snipe) rfl (.head _) (.nil _) rfl rfl rfl rfl snipeStart_settled
      (.spreadDamage .opp 5 _) rfl (fun h => nomatch h) rfl
      (HitTrig.exists_nil (.spreadDamage .opp 5 _) rfl) (.nil _)
  refine ⟨snipeStart, snipeStart_wellFormed, snipeStart_settled, _, hm, .step (.refl _) rfl hm,
    rfl, fun hk => ?_⟩
  exact absurd (hk .opp .bench ((InPlay.ofBasic low).addDamage 5) (List.Mem.head _))
    (by decide)

/-- 50 damage to one of the opponent's Benched Pokémon. -/
def poke : Attack := ⟨"Poke", [], 0, .benchDamage .opp 5, false⟩

def poker : PokemonCard := ⟨"Poker", .basic, none, 10, .grass, [poke], 1, none, none, .none, false, []⟩

def pokeStart : GameState :=
  ⟨side [] [.energy .fire, .energy .fire] (InPlay.ofBasic poker) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic low, InPlay.ofBasic low],
    true, false, false, false, none, none, false, false⟩

theorem pokeStart_wellFormed : WellFormed pokeStart := by
  refine ⟨fun _ => ⟨by simp [pokeStart, Trainer.side], by simp [pokeStart, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [pokeStart, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem pokeStart_settled : Settled pokeStart :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by
      simp only [pokeStart, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide)

/-- **Witness: attack damage to one Benched Pokémon.** `poke` does 50 damage to one of the
opponent's two 50-HP Benched Pokémon: that one is at its HP and its Knock Out is pending; the
other takes none. -/
theorem benchDamage_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧
      g.opp.bench = [(InPlay.ofBasic low).addDamage 5, InPlay.ofBasic low] ∧
      ¬ DamageBounded g := by
  have hm : Move pokeStart _ :=
    .attack (atk := poke) rfl (.head _) (.nil _) rfl rfl rfl rfl pokeStart_settled
      (.benchDamage (b₁ := []) .opp 5 rfl) rfl (fun h => nomatch h) rfl
      (HitTrig.exists_nil (.benchDamage (b₁ := []) .opp 5 rfl) rfl) (.nil _)
  refine ⟨pokeStart, pokeStart_wellFormed, pokeStart_settled, _, hm, .step (.refl _) rfl hm,
    rfl, fun hk => ?_⟩
  exact absurd (hk .opp .bench ((InPlay.ofBasic low).addDamage 5) (List.Mem.head _))
    (by decide)

/-! ## Both players win at once (milestone batch-KO)

"You win if you take your last Prize card or if your opponent has no Benched Pokémon to replace
their Active Pokémon if it is Knocked Out … This makes it possible for both players to win at the
same time. If this happens, play Sudden Death. However, if you win in both ways and your opponent
wins in only one way, you are the victor!" (rulebook 2023 p. 21). Before milestone batch-KO the
model took the two Knock Outs one at a time and the first one taken decided the game (either
player could win). With the batch Knock Out step the outcome no longer depends on any order: every
move from the state after the attack gives the rulebook's outcome. -/

/-- "Put 5 damage counters on your opponent's Active Pokémon and 5 on this Pokémon." -/
def both : Attack := ⟨"Both", [], 0, .seq (.counters 5) (.selfDamage 5), false⟩

/-- A 50-HP Basic Pokémon with `both`. -/
def bother : PokemonCard :=
  ⟨"Bother", .basic, none, 5, .grass, [both], 1, none, none, .none, false, []⟩

/-- Each player has one Prize card left and a 50-HP Pokémon Active; the player to move has a
100-HP Pokémon on the Bench, and the opponent has one too if `oppBench`. -/
def lastStart (oppBench : List InPlay) : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic bother) [InPlay.ofBasic big],
    side [] [.energy .fire] (InPlay.ofBasic Infinite.mon) oppBench,
    true, false, false, false, none, none, false, false⟩

theorem lastStart_wellFormed (b : List InPlay) (hb : ∀ p ∈ b, Benched p) :
    WellFormed (lastStart b) := by
  refine ⟨fun _ => ⟨by simp [lastStart, Trainer.side], by simp [lastStart, Trainer.side]⟩,
    fun p hp => ?_, hb⟩
  simp only [lastStart, Trainer.side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

/-- The state after `both` from `lastStart b`: both Active Pokémon at their HP. -/
def lastHit (b : List InPlay) : GameState :=
  let g₂ : GameState := { lastStart b with opp := { (lastStart b).opp with
    active := some { InPlay.ofBasic Infinite.mon with
      damage := (InPlay.ofBasic Infinite.mon).damage + 5 } } }
  let g₃ : GameState := { g₂ with cur := { g₂.cur with
    active := some { InPlay.ofBasic bother with
      damage := (InPlay.ofBasic bother).damage + 5 } } }
  { g₃ with attacked := true, cur := { g₃.cur with gxUsed := both.gx || g₃.cur.gxUsed } }

theorem move_lastHit (b : List InPlay) (hs : Settled (lastStart b)) :
    Move (lastStart b) (lastHit b) :=
  .attack (atk := both) rfl (.head _) (.nil _) rfl rfl rfl rfl hs
    (.seq (.counters 5 rfl) (.selfDamage 5 rfl)) rfl (fun h => nomatch h) rfl
    (HitTrig.exists_nil (.seq (.counters 5 rfl) (.selfDamage 5 rfl)) rfl) (.nil _)

/-- **Both players take their last Prize card: Sudden Death, whatever the order.** From a
well-formed, `Settled` start in which each player has one Prize card left and a Benched Pokémon
(so neither is left without Pokémon), the attack `both` leaves both Active Pokémon at their HP.
Every move from there is the batch Knock Out step, both players take their last Prize card, each
wins in one way, and the game ends in Sudden Death; nobody is promoted. -/
theorem suddenDeath_forced :
    WellFormed (lastStart [InPlay.ofBasic big]) ∧ Settled (lastStart [InPlay.ofBasic big]) ∧
      Move (lastStart [InPlay.ofBasic big]) (lastHit [InPlay.ofBasic big]) ∧
      ¬ DamageBounded (lastHit [InPlay.ofBasic big]) ∧
      (lastHit [InPlay.ofBasic big]).cur.prizes.length = 1 ∧
      (lastHit [InPlay.ofBasic big]).opp.prizes.length = 1 ∧
      ∀ g₂, Move (lastHit [InPlay.ofBasic big]) g₂ →
        g₂.winner = some .suddenDeath ∧ g₂.cur.prizes = [] ∧ g₂.opp.prizes = [] := by
  have hs : Settled (lastStart [InPlay.ofBasic big]) := by decide
  have hu : ¬ Settled (lastHit [InPlay.ofBasic big]) := by decide
  refine ⟨lastStart_wellFormed _ (fun p hp => by
      simp only [List.mem_singleton] at hp; subst hp; exact ⟨rfl, rfl, rfl, rfl⟩),
    hs, move_lastHit _ hs, fun hk => hu ⟨hk, by decide, by decide⟩, rfl, rfl, fun g₂ hm => ?_⟩
  have e := hm.eq_koStep_of_won hu (by decide)
  subst e
  exact ⟨by decide, rfl, rfl⟩

/-- **Both ways beat one way.** The same attack when the opponent has no Benched Pokémon: the
player takes their last Prize card and leaves the opponent no Pokémon (two ways), the opponent
takes their last Prize card (one way), and on every move from there the player who attacked wins
("if you win in both ways and your opponent wins in only one way, you are the victor!"). -/
theorem bothWays_wins :
    WellFormed (lastStart []) ∧ Settled (lastStart []) ∧ Move (lastStart []) (lastHit []) ∧
      ¬ DamageBounded (lastHit []) ∧
      ∀ g₂, Move (lastHit []) g₂ →
        g₂.winner = some (.win (lastHit []).curIsFirst) ∧ g₂.cur.prizes = [] ∧
          g₂.opp.prizes = [] ∧ g₂.opp.active = none ∧ g₂.opp.bench = [] := by
  have hs : Settled (lastStart []) := by decide
  have hu : ¬ Settled (lastHit []) := by decide
  refine ⟨lastStart_wellFormed _ (fun p hp => nomatch hp), hs, move_lastHit _ hs,
    fun hk => hu ⟨hk, by decide, by decide⟩, fun g₂ hm => ?_⟩
  have e := hm.eq_koStep_of_won hu (by decide)
  subst e
  exact ⟨by decide, rfl, rfl, rfl, rfl⟩

end Pokemon.Bench
