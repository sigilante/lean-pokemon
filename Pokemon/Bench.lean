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
  Benched Pokémon; two Knock Outs are pending at once, and both are taken before the next step.
* `charBench_reachable`: a Char counter on a Benched Pokémon puts 2 damage counters on it
  between turns (tails), which Knocks it Out on the Bench.
* `gust_reachable`: an Item switches the opponent's 50-HP Benched Pokémon into the Active Spot
  and Knocks it Out there; `switch_cures`: the player's Poisoned Active Pokémon switched to the
  Bench is no longer Poisoned.
* `teraBench_reachable`: an attack does 50 damage to each of the opponent's Benched Pokémon; the
  Tera Pokémon among them takes none, the other is left at its HP and is Knocked Out next.
-/

namespace Pokemon.Bench

open Trainer

/-- A Basic Pokémon ex with 50 HP: its Knock Out gives two Prize cards. -/
def exMon : PokemonCard := ⟨"ExMon", .basic, none, 5, .grass, [], 1, none, none, .ex, false⟩

/-- Put 5 damage counters on the opponent's Active Pokémon. -/
def hit5 : Card := .trainer "Hit5" .item (.counters 5)

/-- The player to move has `prizes` and `hit5` in hand; the opponent has `exMon` Active and a
100-HP Pokémon on the Bench. -/
def exStart (prizes : List Card) : GameState :=
  ⟨side [hit5] prizes (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic exMon) [InPlay.ofBasic big],
    true, false, false, false, none, none⟩

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
        (.step rfl (.knockOut rfl (by decide) rfl)
          (.step rfl (.promote (b₁ := []) rfl rfl)
            (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
              (fun p hp => by cases hp))))))) rfl rfl rfl rfl
  exact ⟨_, hm, .step (.refl _) rfl hm, rfl, rfl, .head _, rfl⟩

/-- **Witness: the last Prize card in the middle of a multi-Prize Knock Out wins.** With one
Prize card left, Knocking Out a Pokémon ex (two Prize cards) takes that card, and the player who
took it wins. -/
theorem lastPrize_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.winner = none ∧ g₀.cur.prizes.length = 1 ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.cur.prizes = [] ∧ g.cur.hand.length = 1 ∧
        g.winner = some g₀.curIsFirst := by
  refine ⟨exStart [.energy .fire], exStart_wellFormed _ _, exStart_settled _, rfl, rfl, ?_⟩
  have hm : Move (exStart [.energy .fire]) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Hit5") rfl rfl (exStart_settled _)
      (.prim rfl rfl (.counters 5 rfl)
        (.step rfl (.knockOut rfl (by decide) rfl) (.done (.inr (by decide))))) rfl rfl rfl rfl
  exact ⟨_, hm, .step (.refl _) rfl hm, rfl, rfl, rfl⟩

/-! ## Energy and evolution on the Bench, and a Knock Out on the Bench -/

/-- A Basic Pokémon with 50 HP. -/
def low : PokemonCard := ⟨"Low", .basic, none, 5, .grass, [], 1, none, none, .none, false⟩

/-- A Stage 1 Pokémon that evolves from `low` and has 20 HP. -/
def weak : PokemonCard := ⟨"Weak", .stage1, some "Low", 2, .grass, [], 1, none, none, .none, false⟩

/-- `low` on the Bench since an earlier turn, with 3 damage counters. -/
def lowBenched : InPlay := { InPlay.ofBasic low with damage := 3, fresh := false }

/-- The player to move has `big` Active, `lowBenched` on the Bench, and a Grass Energy and
`weak` in hand; the opponent has two Prize cards. -/
def benchStart : GameState :=
  ⟨side [.energy .grass, .pokemon weak] [.energy .fire] (InPlay.ofBasic big) [lowBenched],
    side [] [.energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none⟩

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
  have h₂ : Move benchMid _ := .knockOutBenchOwn (b₁ := []) (b₂ := []) rfl (by decide) rfl
  refine ⟨benchStart, benchStart_wellFormed, benchStart_settled, _, _, h₁, h₂,
    .step (.step (.refl _) rfl h₁) rfl h₂, fun hk => ?_, .head _, rfl, rfl, rfl, rfl⟩
  have := hk weakBenched (Or.inr (Or.inl (.head _)))
  exact absurd this (by decide)

/-! ## Several Knock Outs from one step -/

/-- Put 5 damage counters on each of the opponent's Benched Pokémon. -/
def spread5 : Card := .trainer "Spread" .item (.spreadCounters .opp 5)

/-- The opponent has `big` Active and two 50-HP Pokémon on the Bench; the player to move has three
Prize cards and `spread5` in hand. -/
def spreadStart : GameState :=
  ⟨side [spread5] [.energy .fire, .energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic low, InPlay.ofBasic low],
    true, false, false, false, none, none⟩

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
Outs are taken (`Resolve`, two `knockOutBench` moves) before the effect ends, the player takes two
Prize cards, and the opponent's Active Pokémon stays. -/
theorem doubleKO_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.opp.bench = [] ∧
      g.opp.active = g₀.opp.active ∧ g.cur.prizes.length + 2 = g₀.cur.prizes.length ∧
      g.winner = none := by
  have hm : Move spreadStart _ :=
    .item (l₁ := []) (l₂ := []) (n := "Spread") rfl rfl spreadStart_settled
      (.prim rfl rfl (.spreadCounters .opp 5 _)
        (.step rfl (.knockOutBench (b₁ := []) rfl (by decide) rfl)
          (.step rfl (.knockOutBench (b₁ := []) rfl (by decide) rfl)
            (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
              (fun p hp => by cases hp))))))) rfl rfl rfl rfl
  exact ⟨spreadStart, spreadStart_wellFormed, spreadStart_settled, _, hm,
    .step (.refl _) rfl hm, rfl, rfl, rfl, rfl⟩

/-! ## A Char counter on the Bench -/

/-- A Basic Pokémon with 20 HP. -/
def tiny : PokemonCard := ⟨"Tiny", .basic, none, 2, .grass, [], 1, none, none, .none, false⟩

/-- `tiny` on the Bench with a Char counter. -/
def charred : InPlay := (InPlay.ofBasic tiny).setMarks (Marks.set .char true)

/-- The player to move has `big` Active and `charred` on the Bench. -/
def charStart : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic big) [charred],
    side [] [.energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none⟩

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
  have h₂ : Move charMid _ :=
    .knockOutBench (b₁ := []) (b₂ := []) (p := charred.unfresh.addDamage 2) rfl (by decide) rfl
  refine ⟨charStart, charStart_wellFormed, hs, _, _, h₁, h₂, .step (.step (.refl _) rfl h₁) rfl h₂,
    fun hk => ?_, rfl, .head _⟩
  exact absurd (hk (charred.unfresh.addDamage 2) (Or.inr (Or.inr (Or.inr (.head _)))))
    (by decide)

/-! ## Switching -/

/-- Switch in one of the opponent's Benched Pokémon, then put 5 damage counters on the
opponent's Active Pokémon. -/
def gust : Card := .trainer "Gust" .item (.seq (.switch .opp) (.counters 5))

def gustStart : GameState :=
  ⟨side [gust] [.energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic low],
    true, false, false, false, none, none⟩

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
          (.step rfl (.knockOut rfl (by decide) rfl)
            (.step rfl (.promote (b₁ := []) rfl rfl)
              (.done (.inl (settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
                (fun p hp => by cases hp)))))))) rfl rfl rfl rfl
  exact ⟨gustStart, gustStart_wellFormed, gustStart_settled, _, hm, .step (.refl _) rfl hm,
    .head _, rfl, rfl, rfl⟩

/-- Switch the player's Active Pokémon with one of their Benched Pokémon. -/
def switchCard : Card := .trainer "Switch" .item (.switch .own)

/-- The player to move has a Poisoned `big` Active and `low` on the Bench. -/
def switchStart : GameState :=
  ⟨side [switchCard] [.energy .fire] { InPlay.ofBasic big with poisoned := true }
      [InPlay.ofBasic low],
    side [] [.energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none⟩

/-- **Witness: switching cures.** Playing `switchCard` puts the Poisoned Active Pokémon on the
Bench, no longer Poisoned ("When your Active Pokémon goes to your Bench … Special Conditions …
go away", rulebook 2023 p. 12). -/
theorem switch_cures :
    ∃ g q, Move switchStart g ∧ g.cur.bench = [q] ∧ q.top = big ∧ q.poisoned = false ∧
      (∃ p, switchStart.cur.active = some p ∧ p.poisoned = true) := by
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
  exact ⟨_, _, hm, rfl, rfl, rfl, _, rfl, rfl⟩

/-! ## Attack damage to the Bench, and Tera -/

/-- 50 damage to each of the opponent's Benched Pokémon, no damage to the Active Pokémon. -/
def snipe : Attack := ⟨"Snipe", [], 0, .spreadDamage .opp 5, false⟩

/-- A 100-HP Basic Pokémon with `snipe`. -/
def sniper : PokemonCard := ⟨"Sniper", .basic, none, 10, .grass, [snipe], 1, none, none, .none, false⟩

/-- A 50-HP Basic Tera Pokémon ex. -/
def teraMon : PokemonCard := ⟨"TeraMon", .basic, none, 5, .grass, [], 1, none, none, .ex, true⟩

def snipeStart : GameState :=
  ⟨side [] [.energy .fire, .energy .fire] (InPlay.ofBasic sniper) [],
    side [] [.energy .fire] (InPlay.ofBasic big) [InPlay.ofBasic low, InPlay.ofBasic teraMon],
    true, false, false, false, none, none⟩

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
  refine ⟨snipeStart, snipeStart_wellFormed, snipeStart_settled, _, hm, .step (.refl _) rfl hm,
    rfl, fun hk => ?_⟩
  exact absurd (hk ((InPlay.ofBasic low).addDamage 5) (Or.inr (Or.inr (Or.inr (.head _)))))
    (by decide)

end Pokemon.Bench
