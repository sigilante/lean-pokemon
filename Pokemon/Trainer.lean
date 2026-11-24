import Pokemon.Finite
import Pokemon.Infinite

/-!
# Knock Out timing inside Trainer effects

The model checks for Knock Outs at the end of every attack, at the end of every Pokémon
Checkup (both as the English rulebook says, 2023 pp. 14–15), and at once at any other time a
Pokémon's damage reaches its HP. The third clause is not in the English rulebook: it comes from
the Pokémon Asia *Advanced Player's Rulebook* (Ver. 3.4, 2025; survey S2), and survey S9 found
no English rule for it (see the Known gaps of `Pokemon/Rules.lean`). An Item or Supporter
card's effect is such an "other time": a Pokémon whose damage reaches its HP in the middle of
the effect is Knocked Out at once (its owner's opponent takes a Prize card, a Benched Pokémon
is promoted, or the game ends), and the rest of the effect acts on the new board. The model
resolves Trainer effects by `TRun` (in `Pokemon.Rules`), which does exactly this.

* `TRun.guarded`, `TRun.iff_guarded`: the timing statement. `TRunG` is `TRun` with the extra
  premise `Settled g` on every primitive step and every test. From a state that is `Settled`
  or finished (as every `Move.item` and `Move.supporter` starts), the two relations coincide:
  no step of a Trainer effect is executed, and no test is evaluated, while a Pokémon in play is
  at or above its HP or an Active Spot is empty.
* `TRun.of_won`: once the game has a winner, the rest of the effect is not resolved.
* Witnesses, each a single legal move from a well-formed, `Settled` start:
  `selfKO_reachable` (an Item `seq (selfDamage 5) (heal 5)` Knocks Out the player's own 50-HP
  Active Pokémon after its first step; the heal then acts on the promoted Pokémon),
  `koThenHit_reachable` (an Item `iter (counters 5)` Knocks Out the opponent's 50-HP Active
  Pokémon, the opponent promotes a 100-HP Pokémon, and the next round hits it; this is
  rulebook behaviour for "as often as you like, put 5 damage counters", but for "flip until
  tails, 5 counters per heads" it is an artefact of the check between primitives), and
  `winMidEffect_reachable` (an Item `seq (counters 5) draw` takes the last Prize card in its
  first step; the game is over and the draw is not made).

With the earlier semantics (a Trainer effect resolved as a whole by `Run`) none of the three
behaviours was possible, and a Trainer effect could read and heal damage above HP; now neither
difference remains.
-/

namespace Pokemon

/-- `TRun` with every primitive step and every test guarded by `Settled`. Used only to state the
Knock Out timing (`TRun.guarded`). -/
inductive TRunG : Effect → GameState → GameState → Prop where
  | prim {e : Effect} {g g₁ g₂ : GameState} (he : e.isPrim = true) (hs : Settled g)
      (hn : g.winner = none) (hr : Run e g g₁) (hk : Resolve g₁ g₂) : TRunG e g g₂
  | stop {e : Effect} {g : GameState} (hn : g.winner ≠ none) : TRunG e g g
  | iteT {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay} (hs : Settled g)
      (hn : g.winner = none) (h : g.activeOf t.whose = some p) (ht : t.eval g p = true) :
      TRunG a g g' → TRunG (.ite t a b) g g'
  | iteF {t : Test} {a b : Effect} {g g' : GameState} {p : InPlay} (hs : Settled g)
      (hn : g.winner = none) (h : g.activeOf t.whose = some p) (ht : t.eval g p = false) :
      TRunG b g g' → TRunG (.ite t a b) g g'
  | seq {a b : Effect} {g₁ g₂ g₃ : GameState} :
      TRunG a g₁ g₂ → TRunG b g₂ g₃ → TRunG (.seq a b) g₁ g₃
  | choiceL {a b : Effect} {g g' : GameState} : TRunG a g g' → TRunG (.choice a b) g g'
  | choiceR {a b : Effect} {g g' : GameState} : TRunG b g g' → TRunG (.choice a b) g g'
  | iterNil (a : Effect) (g : GameState) : TRunG (.iter a) g g
  | iterCons {a : Effect} {g₁ g₂ g₃ : GameState} :
      TRunG a g₁ g₂ → TRunG (.iter a) g₂ g₃ → TRunG (.iter a) g₁ g₃

theorem TRunG.trun {e : Effect} {g g' : GameState} (h : TRunG e g g') : TRun e g g' := by
  induction h with
  | prim he _ hn hr hk => exact .prim he hn hr hk
  | stop hn => exact .stop hn
  | iteT _ hn h ht _ ih => exact .iteT hn h ht ih
  | iteF _ hn h ht _ ih => exact .iteF hn h ht ih
  | seq _ _ ih₁ ih₂ => exact .seq ih₁ ih₂
  | choiceL _ ih => exact .choiceL ih
  | choiceR _ ih => exact .choiceR ih
  | iterNil a g => exact .iterNil a g
  | iterCons _ _ ih₁ ih₂ => exact .iterCons ih₁ ih₂

/-- **Knock Out timing in Trainer effects.** From a state that is `Settled` or finished, every
resolution of a Trainer effect executes each primitive step, and evaluates each test, in a
`Settled` state: no Pokémon in play is at or above its HP and both Active Spots are filled. A
Knock Out caused by a step is therefore taken before the next step, and no step reads, heals or
otherwise acts on a Pokémon at or above its HP. -/
theorem TRun.guarded {e : Effect} {g g' : GameState} (h : TRun e g g')
    (hs : Settled g ∨ g.winner ≠ none) : TRunG e g g' := by
  induction h with
  | prim he hn hr hk => exact .prim he (hs.resolve_right (fun h => h hn)) hn hr hk
  | stop hn => exact .stop hn
  | iteT hn h ht _ ih => exact .iteT (hs.resolve_right (fun h => h hn)) hn h ht (ih hs)
  | iteF hn h ht _ ih => exact .iteF (hs.resolve_right (fun h => h hn)) hn h ht (ih hs)
  | seq h₁ _ ih₁ ih₂ => exact .seq (ih₁ hs) (ih₂ (h₁.settled_or_won hs))
  | choiceL _ ih => exact .choiceL (ih hs)
  | choiceR _ ih => exact .choiceR (ih hs)
  | iterNil a g => exact .iterNil a g
  | iterCons h₁ _ ih₁ ih₂ => exact .iterCons (ih₁ hs) (ih₂ (h₁.settled_or_won hs))

theorem TRun.iff_guarded {e : Effect} {g g' : GameState} (hs : Settled g ∨ g.winner ≠ none) :
    TRun e g g' ↔ TRunG e g g' :=
  ⟨fun h => h.guarded hs, TRunG.trun⟩

/-- Every Trainer effect played in a move is resolved with the rulebook's timing: the state in
which it starts is `Settled`. -/
theorem Move.item_guarded {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
    (hst : Settled g)
    (hr : TRun e { g with cur := { g.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } g') :
    TRunG e { g with cur := { g.cur with
        hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g.cur.discard } } g' :=
  hr.guarded (.inl (hst.congr rfl rfl rfl rfl rfl rfl rfl))

theorem Move.supporter_guarded {g g' : GameState} {l₁ l₂ : List Card} {n : String} {e : Effect}
    (hst : Settled g)
    (hr : TRun e { g with cur := { g.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g.cur.discard } } g') :
    TRunG e { g with cur := { g.cur with
        hand := l₁ ++ l₂, supporterPlayed := true,
        discard := Card.trainer n .supporter e :: g.cur.discard } } g' :=
  hr.guarded (.inl (hst.congr rfl rfl rfl rfl rfl rfl rfl))

/-- **A finished game stops the effect.** From a state with a winner, the only resolution of
any effect leaves the state unchanged. -/
theorem TRun.of_won {e : Effect} {g g' : GameState} (h : TRun e g g') (hw : g.winner ≠ none) :
    g' = g := by
  induction h with
  | prim _ hn => exact absurd hn hw
  | stop => rfl
  | iteT hn => exact absurd hn hw
  | iteF hn => exact absurd hn hw
  | seq _ _ ih₁ ih₂ =>
      have e₁ := ih₁ hw
      subst e₁
      exact ih₂ hw
  | choiceL _ ih => exact ih hw
  | choiceR _ ih => exact ih hw
  | iterNil => rfl
  | iterCons _ _ ih₁ ih₂ =>
      have e₁ := ih₁ hw
      subst e₁
      exact ih₂ hw

namespace Trainer

open Infinite (mon)

/-- A Basic Pokémon with 100 HP (ten counters). -/
def big : PokemonCard := ⟨"Big", .basic, none, 10, .grass, [], 1, none, none, .none, false, []⟩

/-- A player with the given hand, Prizes, Active Pokémon and Bench. -/
def side (hand prizes : List Card) (a : InPlay) (bench : List InPlay) : PlayerState :=
  ⟨[.energy .grass], hand, [], prizes, [], some a, bench, false, false, false, false,
    false, Store.empty, true, KOHist.empty⟩

/-- A state is `Settled` if both Active Pokémon, and every Benched Pokémon, are below HP, when no
static effect has a source in play (`GameState.Plain`, milestone M6: then HP is the printed HP;
decided by `plainB` for the witnesses). -/
theorem settled_of {g : GameState} {a b : InPlay} (hc : g.cur.active = some a)
    (ho : g.opp.active = some b) (ha : a.damage < a.top.hp) (hb : b.damage < b.top.hp)
    (hbc : ∀ p ∈ g.cur.bench, p.damage < p.top.hp)
    (hbo : ∀ p ∈ g.opp.bench, p.damage < p.top.hp)
    (hpl : g.Plain := by exact GameState.plain_of_plainB rfl)
    (hpd : g.pend = false := by first | rfl | assumption) : Settled g := by
  refine ⟨DamageBounded.intro' (fun p hp => ?_) (fun p hp => ?_) (fun p hp => ?_)
    (fun p hp => ?_), by rw [hc]; simp, by rw [ho]; simp, hpd⟩
  · rw [hpl.hpOf (w := .own) (sp := .active) hp]; rw [hc] at hp; cases hp; exact ha
  · rw [hpl.hpOf (w := .own) (sp := .bench) hp]; exact hbc p hp
  · rw [hpl.hpOf (w := .opp) (sp := .active) hp]; rw [ho] at hp; cases hp; exact hb
  · rw [hpl.hpOf (w := .opp) (sp := .bench) hp]; exact hbo p hp

theorem benched_ofBasic {c : PokemonCard} (_h : 0 < c.hp) : Benched (InPlay.ofBasic c) :=
  ⟨rfl, rfl, rfl, rfl⟩

/-! ## A Knock Out after the first step of an Item -/

/-- Place 5 damage counters on your own Active Pokémon, then heal 5 from it. -/
def selfItem : Card := .trainer "SelfHarm" .item (.seq (.selfDamage 5) (.heal 5))

/-- The player to move has a 50-HP Active Pokémon, a 100-HP Pokémon on the Bench and
`selfItem` in hand; the opponent has two Prize cards. -/
def start1 : GameState :=
  ⟨side [selfItem] [.energy .fire] (InPlay.ofBasic mon) [InPlay.ofBasic big],
    side [] [.energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    true, false, false, false, none, none, false, false, false⟩

theorem start1_wellFormed : WellFormed start1 := by
  refine ⟨fun _ => ⟨by simp [start1, side], by simp [start1, side]⟩, fun p hp => ?_,
    fun p hp => by cases hp⟩
  simp only [start1, side, List.mem_singleton] at hp
  subst hp; exact benched_ofBasic (by decide)

theorem start1_settled : Settled start1 :=
  settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by simp only [start1, side, List.mem_singleton] at hp; subst hp; decide)
    (fun p hp => by cases hp)

/-- The board after `selfItem`: `mon` was Knocked Out by the first step and is in the discard
pile with the Item, the opponent took a Prize card, `big` was promoted, and the heal acted on
`big`. -/
def after1 : GameState :=
  ⟨⟨[.energy .grass], [], [.pokemon mon, selfItem], [.energy .fire], [],
      some { InPlay.ofBasic big with damage := 0 - 5 }, [], false, false, false, false,
      false, Store.empty, true, ⟨true, false, false, false⟩⟩,
    ⟨[.energy .grass], [.energy .fire], [], [.energy .fire], [], some (InPlay.ofBasic big), [],
      false, false, false, false, false, Store.empty, true, KOHist.empty⟩,
    true, false, false, false, none, none, false, false, false⟩

theorem move_after1 : Move start1 after1 := by
  refine .item (l₁ := []) (l₂ := []) (n := "SelfHarm") rfl rfl start1_settled
    (.seq (.prim rfl rfl (.selfDamage 5 rfl)
      (.step rfl (.go (by decide) rfl (.pick (b₁ := [])) .keep) (.done (.inl ?_))))
      (.prim rfl rfl (.heal 5 rfl) (.done (.inl ?_)))) rfl rfl rfl rfl
  · exact settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
      (fun p hp => by cases hp)
  · exact settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
      (fun p hp => by cases hp)

/-- **Witness: an Item Knocks Out the player's own Active Pokémon in mid-effect.** From a
well-formed, `Settled` start, playing `seq (selfDamage 5) (heal 5)` on a 50-HP Active Pokémon
is a legal move after which that Pokémon is in its owner's discard pile, the opponent has taken
a Prize card, and the player's Active Pokémon is the promoted `big` (the heal acted on it). -/
theorem selfKO_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.cur.active = some (InPlay.ofBasic mon) ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ Card.pokemon mon ∈ g.cur.discard ∧
        g.cur.active = some (InPlay.ofBasic big) ∧
        g.opp.prizes.length + 1 = g₀.opp.prizes.length ∧ g.winner = none :=
  ⟨start1, start1_wellFormed, start1_settled, rfl, after1, move_after1,
    .step (.refl _) rfl move_after1, .head _, rfl, rfl, rfl⟩

/-! ## A Knock Out, a promotion, and a hit on the new Active Pokémon, within one Item -/

/-- As often as you like, put 5 damage counters on the opponent's Active Pokémon. (Read as
"flip until tails, 5 counters for each heads", the outcome of `koThenHit_reachable` is an
artefact of the check between primitives, since the printed card places its counters at once.) -/
def hitItem : Card := .trainer "Hit" .item (.iter (.counters 5))

/-- The opponent has a 50-HP Active Pokémon and a 100-HP Pokémon on the Bench; the player to
move has two Prize cards and `hitItem` in hand. -/
def start2 : GameState :=
  ⟨side [hitItem] [.energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic mon) [InPlay.ofBasic big],
    true, false, false, false, none, none, false, false, false⟩

theorem start2_wellFormed : WellFormed start2 := by
  refine ⟨fun _ => ⟨by simp [start2, side], by simp [start2, side]⟩,
    (fun p hp => by cases hp),
    fun p hp => ?_⟩
  simp only [start2, side, List.mem_singleton] at hp
  subst hp; exact benched_ofBasic (by decide)

theorem start2_settled : Settled start2 :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by simp only [start2, side, List.mem_singleton] at hp; subst hp; decide)

/-- The board after two rounds of `hitItem`: `mon` was Knocked Out by the first round, the
player took a Prize card, the opponent promoted `big`, and the second round put 5 counters on
`big`. -/
def after2 : GameState :=
  ⟨⟨[.energy .grass], [.energy .fire], [hitItem], [.energy .fire], [],
      some (InPlay.ofBasic big), [], false, false, false, false, false, Store.empty, true, KOHist.empty⟩,
    ⟨[.energy .grass], [], [.pokemon mon], [.energy .fire], [],
      some { InPlay.ofBasic big with damage := 0 + 5 }, [], false, false, false, false,
      false, Store.empty, true, ⟨true, false, false, false⟩⟩,
    true, false, false, false, none, none, false, false, false⟩

theorem move_after2 : Move start2 after2 := by
  refine .item (l₁ := []) (l₂ := []) (n := "Hit") rfl rfl start2_settled
    (.iterCons (.prim rfl rfl (.counters 5 rfl)
      (.step rfl (.go (by decide) rfl .keep (.pick (b₁ := []))) (.done (.inl ?_))))
      (.iterCons (.prim rfl rfl (.counters 5 rfl) (.done (.inl ?_))) (.iterNil _ _))) rfl rfl rfl rfl
  · exact settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
      (fun p hp => by cases hp)
  · exact settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
      (fun p hp => by cases hp)

/-- **Witness: Knock Out, promote, and hit the new Active Pokémon, within one Item.** From a
well-formed, `Settled` start, one play of `iter (counters 5)` is a legal move after which the
opponent's former Active Pokémon is in their discard pile, the player has taken a Prize card,
and the opponent's new Active Pokémon (promoted from the Bench in mid-effect) has the 5 damage
counters of the second round. -/
theorem koThenHit_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.opp.active = some (InPlay.ofBasic mon) ∧
      InPlay.ofBasic big ∈ g₀.opp.bench ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ Card.pokemon mon ∈ g.opp.discard ∧
        g.opp.active = some { InPlay.ofBasic big with damage := 5 } ∧
        g.cur.prizes.length + 1 = g₀.cur.prizes.length ∧ g.winner = none :=
  ⟨start2, start2_wellFormed, start2_settled, rfl, .head _, after2, move_after2,
    .step (.refl _) rfl move_after2, .head _, rfl, rfl, rfl⟩

/-! ## The game ends in mid-effect -/

/-- 5 damage counters on the opponent's Active Pokémon, then draw a card. -/
def winItem : Card := .trainer "Win" .item (.seq (.counters 5) .draw)

/-- The player to move has one Prize card left and `winItem` in hand; the opponent's Active
Pokémon has 50 HP. -/
def start3 : GameState :=
  ⟨side [winItem] [.energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic mon) [InPlay.ofBasic big],
    true, false, false, false, none, none, false, false, false⟩

theorem start3_wellFormed : WellFormed start3 := by
  refine ⟨fun _ => ⟨by simp [start3, side], by simp [start3, side]⟩,
    (fun p hp => by cases hp),
    fun p hp => ?_⟩
  simp only [start3, side, List.mem_singleton] at hp
  subst hp; exact benched_ofBasic (by decide)

theorem start3_settled : Settled start3 :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by simp only [start3, side, List.mem_singleton] at hp; subst hp; decide)

def after3 : GameState :=
  ⟨⟨[.energy .grass], [.energy .fire], [winItem], [], [], some (InPlay.ofBasic big),
      [], false, false, false, false, false, Store.empty, true, KOHist.empty⟩,
    ⟨[.energy .grass], [], [.pokemon mon], [.energy .fire], [], none, [InPlay.ofBasic big],
      false, false, false, false, false, Store.empty, true, ⟨true, false, false, false⟩⟩,
    true, false, false, false, some (.win true), none, false, false, false⟩

theorem move_after3 : Move start3 after3 :=
  .item (l₁ := []) (l₂ := []) (n := "Win") rfl rfl start3_settled
    (.seq (.prim rfl rfl (.counters 5 rfl) (.step rfl (.won (by decide) (by decide))
      (.done (.inr (by decide))))) (.stop (by decide))) rfl rfl rfl rfl

/-- **Witness: the win condition fires inside an Item's effect.** From a well-formed, `Settled`
start, `seq (counters 5) draw` Knocks Out the opponent's Active Pokémon in its first step, the
player takes their last Prize card and wins, and the draw is not made (the deck keeps its card;
by `TRun.of_won` no resolution makes it). -/
theorem winMidEffect_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.winner = none ∧
      ∃ g, Move g₀ g ∧ Reach g₀ g ∧ g.winner = some (.win g₀.curIsFirst) ∧
        g.cur.deck = g₀.cur.deck :=
  ⟨start3, start3_wellFormed, start3_settled, rfl, after3, move_after3,
    .step (.refl _) rfl move_after3, rfl, rfl⟩

end Trainer

end Pokemon
