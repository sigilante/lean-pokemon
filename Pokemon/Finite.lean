import Pokemon.Sim

/-!
# Finiteness

`Reach.finite`, the headline: from any start state (well-formed or not) that is `Fit` at
`k = bound g₀.allCards` (tame cards: no damage reduction, no `drain`; no reduction in effect),
the clamps `clamp k` of all reachable states lie in one finite list, and the kernel of the clamp
is a bisimulation for moves along reachable states. `bound C` is larger than every printed HP,
every printed Resistance and every test constant in the cards `C`; the clamp caps damage and
Poison strength on every Pokémon in play (Active and, since milestone M3, Benched) at HP and every
damage bonus and reduction at
`2 * bound` (twice, because Resistance is subtracted after the bonus). So for tame decks the
clamped game is a finite transition system that answers every question about legal play that
does not read the damage or Poison strength above HP on any Pokémon in play (Active or Benched),
or a damage bonus above `2 * bound`.

`Reach.clamp_mem` is the list-membership half alone, from any start with no tameness
hypothesis. On its own it says nothing about play: for every cap `k ≥ 3` there is a deck with
a damage reduction for which the clamp is not a bisimulation (`Lingering.reduce_breaks_clamp`),
and for every `k ≥ 2` a deck with `drain` (`Lingering.drain_breaks_clamp`); and for some such
decks the reachable states are not finite up to any equivalence fine enough to recover the
configuration of a two-counter machine (`Counter.not_finite_up_to`, a statement about
representation, not play).

This holds for the effect language with state-reading effects (`ite` on damage thresholds,
exact damage and Special Conditions; `scale`; `selfDamage`; `healAll`), and for the
rulebook's Knock Out timing inside Item and Supporter effects (`TRun`: Knock Outs taken at once
after each step, which can promote a new Active Pokémon or end the game in mid-effect). Inside
an attack's effect these reads see damage above HP, so the HP clamp is not a simulation for
`Run` (`Reads.run_clamp_not_sim`); but no move other than a Knock Out starts from a state with
a Pokémon at or above its HP (`Settled`), and from such a state equal clamps mean equal damage.
Inside a Trainer effect every step starts `Settled`, so the clamp simulates it step by step
(`TRun.clamp_sim`). The cap on damage stays at HP; the cap on the damage bonus must exceed the
cards' test constants, since a bonus is read through the damage it adds inside an attack
(`Run.cap_sim`).

The clamp is needed even at turn boundaries. Inside one effect (a statement about `Run`,
not `Reach`), `poisonUp_unbounded` raises the Poison strength of a Poisoned opposing Active
Pokémon without bound, and no Knock Out check resets it, since it causes no damage until
Checkup. `Pokemon/Infinite.lean` gives a well-formed start with no pending Knock Out from which
one Item reaches a state with no pending Knock Out at every Poison strength `n`
(`Infinite.not_finite_damageBounded`, `Reach.infinite_damageBounded`), so the unclamped
reachable state space is infinite (`Infinite.not_finite`).

The list `states g₀.allCards` is a crude over-approximation, built from: lists of length at
most `N` over the starting cards (`N` = the number of cards in the game), the Pokémon cards
among them, damage and Poison strength up to `bound`, the modifier stores with amounts up to
`2 * bound`, and the finitely many values of each flag and marker. It is never computed; it witnesses finiteness only. The proof uses `Reach.perm` (cards
are only permuted); the clamp caps every Pokémon in play, Benched ones included (before milestone
M3 it capped only the Active Pokémon, and the proof used that Benched Pokémon were below HP). Unlike the previous version, the start state
need not be free of pending Knock Outs.
-/

namespace Pokemon.Enum

variable {α : Type}

/-- All lists of length at most `n` with entries from `xs`. -/
def listsUpTo (xs : List α) : Nat → List (List α)
  | 0 => [[]]
  | n + 1 => [] :: xs.flatMap fun x => (listsUpTo xs n).map (x :: ·)

theorem mem_listsUpTo {xs : List α} : ∀ {n : Nat} {l : List α},
    l.length ≤ n → (∀ x ∈ l, x ∈ xs) → l ∈ listsUpTo xs n
  | 0, [], _, _ => .head _
  | n + 1, [], _, _ => .head _
  | 0, _ :: _, hl, _ => absurd hl (by simp)
  | n + 1, x :: l, hl, hx =>
      List.mem_cons_of_mem _ (List.mem_flatMap.2 ⟨x, hx x (.head _),
        List.mem_map.2 ⟨l, mem_listsUpTo (by simp at hl; omega) (fun y hy => hx y (.tail _ hy)),
          rfl⟩⟩)

/-- `none` and every `some x` for `x` in `xs`. -/
def opts (xs : List α) : List (Option α) := none :: xs.map some

theorem mem_opts {xs : List α} : ∀ {o : Option α}, (∀ x, o = some x → x ∈ xs) → o ∈ opts xs
  | none, _ => .head _
  | some x, h => .tail _ (List.mem_map.2 ⟨x, h x rfl, rfl⟩)

def bools : List Bool := [false, true]

theorem mem_bools : ∀ b : Bool, b ∈ bools
  | false => .head _
  | true => .tail _ (.head _)

def rots : List Rot := [.none, .asleep, .confused, .paralyzed]

theorem mem_rots : ∀ r : Rot, r ∈ rots
  | .none => .head _
  | .asleep => .tail _ (.head _)
  | .confused => .tail _ (.tail _ (.head _))
  | .paralyzed => .tail _ (.tail _ (.tail _ (.head _)))

def etypes : List EType :=
  [.grass, .fire, .water, .lightning, .psychic, .fighting, .darkness, .metal, .fairy, .dragon,
    .colorless]

theorem mem_etypes (t : EType) : t ∈ etypes := by
  cases t <;> simp [etypes]

/-- Every value of the markers on one Pokémon. -/
def markss : List Marks :=
  bools.flatMap fun a => bools.flatMap fun b => bools.flatMap fun c => bools.flatMap fun d =>
  (opts etypes).map fun e => ⟨a, b, c, d, e⟩

theorem mem_markss (k : Marks) : k ∈ markss := by
  obtain ⟨a, b, c, d, e⟩ := k
  simp only [markss, List.mem_flatMap, List.mem_map]
  exact ⟨a, mem_bools _, b, mem_bools _, c, mem_bools _, d, mem_bools _, e,
    mem_opts fun t _ => mem_etypes t, rfl⟩

def winners : List (Option Bool) := [none, some false, some true]

theorem mem_winners : ∀ w : Option Bool, w ∈ winners
  | none => .head _
  | some false => .tail _ (.head _)
  | some true => .tail _ (.tail _ (.head _))

/-- `l` is no longer than `C` and has all its entries in `C`. -/
def Within (C l : List Card) : Prop := l.length ≤ C.length ∧ ∀ x ∈ l, x ∈ C

theorem Within.of_sub {C l l' : List Card} (h : Within C l) (hl : l'.length ≤ l.length)
    (hx : ∀ x ∈ l', x ∈ l) : Within C l' :=
  ⟨Nat.le_trans hl h.1, fun x hx' => h.2 x (hx x hx')⟩

theorem Within.left {C a b : List Card} (h : Within C (a ++ b)) : Within C a :=
  h.of_sub (by simp) (fun _ hx => List.mem_append_left _ hx)

theorem Within.right {C a b : List Card} (h : Within C (a ++ b)) : Within C b :=
  h.of_sub (by simp) (fun _ hx => List.mem_append_right _ hx)

theorem Within.of_perm {C l : List Card} (h : l.Perm C) : Within C l :=
  ⟨Nat.le_of_eq h.length_eq, fun _ hx => h.mem_iff.1 hx⟩

/-- The Pokémon cards in `C`. -/
def tops (C : List Card) : List PokemonCard :=
  C.filterMap fun | .pokemon p => some p | _ => none

theorem mem_tops {C : List Card} {p : PokemonCard} (h : Card.pokemon p ∈ C) : p ∈ tops C :=
  List.mem_filterMap.2 ⟨_, h, rfl⟩

def cardLists (C : List Card) : List (List Card) := listsUpTo C C.length

theorem mem_cardLists {C l : List Card} (h : Within C l) : l ∈ cardLists C :=
  mem_listsUpTo h.1 h.2

/-- The bound used for damage and Poison strength (and, doubled, for damage bonuses and
reductions, `GameState.clamp`): larger than every printed HP, every printed Resistance and every
test constant in the cards of `C`. -/
def bound (C : List Card) : Nat := maxHp C + maxResist C + cardsTmax C + 1

/-- Every value of one turn's modifiers with amounts at most `M`. -/
def modss (M : Nat) : List Mods :=
  (List.range (M + 1)).flatMap fun b => (List.range (M + 1)).flatMap fun r =>
  bools.flatMap fun p => bools.flatMap fun a => bools.flatMap fun t => bools.map fun i =>
  ⟨b, r, p, a, t, i⟩

/-- The amounts in one turn's modifiers are at most `M`. -/
def ModsLe (M : Nat) (m : Mods) : Prop := m.bonus ≤ M ∧ m.reduce ≤ M

theorem mem_modss {M : Nat} {m : Mods} (h : ModsLe M m) : m ∈ modss M := by
  obtain ⟨b, r, p, a, t, i⟩ := m
  simp only [modss, List.mem_flatMap, List.mem_map]
  exact ⟨b, List.mem_range.2 (Nat.lt_succ_of_le h.1), r, List.mem_range.2 (Nat.lt_succ_of_le h.2),
    p, mem_bools _, a, mem_bools _, t, mem_bools _, i, mem_bools _, rfl⟩

/-- Every store with amounts at most `M`. -/
def stores (M : Nat) : List Store :=
  (modss M).flatMap fun a => (modss M).flatMap fun b => (modss M).flatMap fun c =>
  (modss M).map fun d => ⟨a, b, c, d⟩

def StoreLe (M : Nat) (t : Store) : Prop :=
  ModsLe M t.now ∧ ModsLe M t.next ∧ ModsLe M t.after ∧ ModsLe M t.always

theorem mem_stores {M : Nat} {t : Store} (h : StoreLe M t) : t ∈ stores M := by
  obtain ⟨a, b, c, d⟩ := t
  simp only [stores, List.mem_flatMap, List.mem_map]
  exact ⟨a, mem_modss h.1, b, mem_modss h.2.1, c, mem_modss h.2.2.1, d, mem_modss h.2.2.2, rfl⟩

theorem storeLe_cap (M : Nat) (t : Store) : StoreLe M (t.cap M) :=
  ⟨⟨Nat.min_le_right _ _, Nat.min_le_right _ _⟩, ⟨Nat.min_le_right _ _, Nat.min_le_right _ _⟩,
    ⟨Nat.min_le_right _ _, Nat.min_le_right _ _⟩, ⟨Nat.min_le_right _ _, Nat.min_le_right _ _⟩⟩

/-- A finite list containing every Pokémon in play made of cards from `C` with damage and
Poison strength at most `bound C`. -/
def inPlays (C : List Card) : List InPlay :=
  (tops C).flatMap fun top => (cardLists C).flatMap fun under =>
  (cardLists C).flatMap fun energy => (cardLists C).flatMap fun tools =>
  (List.range (bound C + 1)).flatMap fun damage => rots.flatMap fun rot =>
  bools.flatMap fun poisoned => bools.flatMap fun burned =>
  (List.range (bound C + 1)).flatMap fun poisonUp => bools.flatMap fun fresh =>
  markss.flatMap fun marks => bools.map fun used =>
  ⟨top, under, energy, tools, damage, rot, poisoned, burned, poisonUp, fresh, marks, used⟩

theorem mem_inPlays {C : List Card} {p : InPlay} (hw : Within C p.cardList)
    (hd : p.damage ≤ bound C) (hu : p.poisonUp ≤ bound C) : p ∈ inPlays C := by
  obtain ⟨top, under, energy, tools, damage, rot, poisoned, burned, poisonUp, fresh, marks, used⟩ := p
  have hw' : Within C (under ++ energy ++ tools) :=
    hw.of_sub (by simp [InPlay.cardList]) (fun _ hx => .tail _ hx)
  simp only [inPlays, List.mem_flatMap, List.mem_map]
  exact ⟨top, mem_tops (hw.2 _ (.head _)), under, mem_cardLists hw'.left.left,
    energy, mem_cardLists hw'.left.right, tools, mem_cardLists hw'.right,
    damage, List.mem_range.2 (Nat.lt_succ_of_le hd), rot, mem_rots _, poisoned, mem_bools _,
    burned, mem_bools _, poisonUp, List.mem_range.2 (Nat.lt_succ_of_le hu), fresh, mem_bools _,
    marks, mem_markss _, used, mem_bools _, rfl⟩

theorem length_le_benchCardList : ∀ b : List InPlay, b.length ≤ (benchCardList b).length
  | [] => Nat.le_refl _
  | p :: ps => by
      have := length_le_benchCardList ps
      simp only [benchCardList, List.length_append, List.length_cons, InPlay.cardList]
      omega

theorem within_of_mem_bench {C : List Card} {b : List InPlay} {p : InPlay}
    (hw : Within C (benchCardList b)) (hp : p ∈ b) : Within C p.cardList := by
  refine hw.of_sub ?_ (fun _ hx => mem_benchCardList hx hp)
  induction b with
  | nil => cases hp
  | cons q qs ih =>
      simp only [benchCardList, List.length_append]
      cases hp with
      | head => omega
      | tail _ hp =>
          have := ih (hw.right) hp
          omega

/-- All Pokémon in play on one side have damage and Poison strength at most `M`, and the
side's damage bonuses and reductions are at most `2 * M` (the clamp caps the stores at twice
its damage bound, `GameState.clamp`). -/
def SideDamageLe (M : Nat) (s : PlayerState) : Prop :=
  (∀ p, s.active = some p → p.damage ≤ M ∧ p.poisonUp ≤ M) ∧
    (∀ p ∈ s.bench, p.damage ≤ M ∧ p.poisonUp ≤ M) ∧ StoreLe (2 * M) s.mods

def players (C : List Card) : List PlayerState :=
  (cardLists C).flatMap fun deck => (cardLists C).flatMap fun hand =>
  (cardLists C).flatMap fun discard => (cardLists C).flatMap fun prizes =>
  (cardLists C).flatMap fun lost => (opts (inPlays C)).flatMap fun active =>
  (listsUpTo (inPlays C) C.length).flatMap fun bench =>
  bools.flatMap fun energyAttached => bools.flatMap fun supporterPlayed =>
  bools.flatMap fun retreated => bools.flatMap fun gxUsed => bools.flatMap fun vstarUsed =>
  (stores (2 * bound C)).flatMap fun mods => bools.map fun hadTurn =>
  ⟨deck, hand, discard, prizes, lost, active, bench, energyAttached, supporterPlayed,
    retreated, gxUsed, vstarUsed, mods, hadTurn⟩

theorem mem_players {C : List Card} {s : PlayerState} (hw : Within C s.allCards)
    (hd : SideDamageLe (bound C) s) : s ∈ players C := by
  obtain ⟨deck, hand, discard, prizes, lost, active, bench, energyAttached,
    supporterPlayed, retreated, gxUsed, vstarUsed, mods, hadTurn⟩ := s
  simp only [PlayerState.allCards] at hw
  have hbench : Within C (benchCardList bench) := hw.right
  have hactive : Within C (optCardList active) := hw.left.right
  simp only [players, List.mem_flatMap, List.mem_map]
  refine ⟨deck, mem_cardLists hw.left.left.left.left.left.left,
    hand, mem_cardLists hw.left.left.left.left.left.right,
    discard, mem_cardLists hw.left.left.left.left.right,
    prizes, mem_cardLists hw.left.left.left.right,
    lost, mem_cardLists hw.left.left.right,
    active, ?_, bench, ?_, energyAttached, mem_bools _,
    supporterPlayed, mem_bools _, retreated, mem_bools _, gxUsed, mem_bools _,
    vstarUsed, mem_bools _, mods, mem_stores hd.2.2, hadTurn, mem_bools _, rfl⟩
  · refine mem_opts fun p hp => ?_
    subst hp
    exact mem_inPlays hactive (hd.1 p rfl).1 (hd.1 p rfl).2
  · refine mem_listsUpTo (Nat.le_trans (length_le_benchCardList bench) hbench.1) ?_
    exact fun p hp => mem_inPlays (within_of_mem_bench hbench hp) (hd.2.1 p hp).1
      (hd.2.1 p hp).2

/-- A finite list containing every state whose cards are those of `C` (up to order) and
whose Pokémon in play all have damage and Poison strength at most `bound C`. -/
def states (C : List Card) : List GameState :=
  (players C).flatMap fun cur => (players C).flatMap fun opp =>
  bools.flatMap fun curIsFirst => bools.flatMap fun firstTurn =>
  bools.flatMap fun attacked => bools.flatMap fun between => winners.flatMap fun winner =>
  (opts (bools.flatMap fun b => C.map fun c => (b, c))).flatMap fun stadium =>
  bools.flatMap fun stadiumPlayed => bools.map fun stadiumUsed =>
  ⟨cur, opp, curIsFirst, firstTurn, attacked, between, winner, stadium, stadiumPlayed, stadiumUsed⟩

theorem mem_states {C : List Card} {g : GameState} (hp : g.allCards.Perm C)
    (hd : SideDamageLe (bound C) g.cur ∧ SideDamageLe (bound C) g.opp) : g ∈ states C := by
  have hw : Within C (g.cur.allCards ++ g.opp.allCards ++ stadiumCardList g.stadium) :=
    Within.of_perm hp
  obtain ⟨cur, opp, curIsFirst, firstTurn, attacked, between, winner, stadium, stadiumPlayed,
    stadiumUsed⟩ := g
  simp only [states, List.mem_flatMap, List.mem_map]
  refine ⟨cur, mem_players hw.left.left hd.1, opp, mem_players hw.left.right hd.2,
    curIsFirst, mem_bools _, firstTurn, mem_bools _, attacked, mem_bools _,
    between, mem_bools _, winner, mem_winners _, stadium, ?_, stadiumPlayed, mem_bools _,
    stadiumUsed, mem_bools _, rfl⟩
  refine mem_opts fun ⟨b, c⟩ hc => ?_
  subst hc
  exact List.mem_flatMap.2 ⟨b, mem_bools _, List.mem_map.2 ⟨c, hw.right.2 c (.head _), rfl⟩⟩

end Enum

open Enum

theorem optCardList_clamp (c : Cap) (o : Option InPlay) :
    optCardList (o.map (InPlay.clampWith c)) = optCardList o := by
  cases o <;> rfl

theorem GameState.allCards_clamp (k : Nat) (g : GameState) : (g.clamp k).allCards = g.allCards := by
  simp only [GameState.clamp, GameState.clampAt, GameState.allCards, PlayerState.allCards,
    optCardList_clamp, benchCardList_clamp]

/-- In the clamp of a reachable state, every Pokémon in play has damage and Poison strength at
most `bound g₀.allCards`: the clamp caps every Pokémon in play, Active or Benched, at its HP.
(Before milestone M3 the clamp capped only the Active Pokémon, and this used `Reach.wellFormed`:
Benched Pokémon were below HP with no Poison strength. Benched Pokémon can now be damaged, and
reach or pass their HP, so the clamp caps them too and well-formedness is not needed here.) -/
theorem Reach.clamp_bounded {g₀ g : GameState} (h : Reach g₀ g) :
    SideDamageLe (bound g₀.allCards) (g.clamp (bound g₀.allCards)).cur ∧
      SideDamageLe (bound g₀.allCards) (g.clamp (bound g₀.allCards)).opp := by
  have hM : ∀ p, Card.pokemon p ∈ g.allCards → p.hp ≤ maxHp g₀.allCards :=
    fun p hp => hp_le_maxHp (h.perm.mem_iff.1 hp)
  have hA : ∀ q : InPlay, Card.pokemon q.top ∈ g.allCards →
      (q.clampWith .hp).damage ≤ bound g₀.allCards ∧
        (q.clampWith .hp).poisonUp ≤ bound g₀.allCards := by
    intro q hq
    have := hM _ hq
    simp only [InPlay.clampWith, Cap.dmg, bound]
    exact ⟨by omega, by omega⟩
  refine ⟨⟨fun p hp => ?_, fun p hp => ?_, storeLe_cap _ _⟩,
    ⟨fun p hp => ?_, fun p hp => ?_, storeLe_cap _ _⟩⟩
  · obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.1 hp
    exact hA q (GameState.top_mem_cur_active hq)
  · obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
    exact hA q (GameState.top_mem_cur_bench hq)
  · obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.1 hp
    exact hA q (GameState.top_mem_opp_active hq)
  · obtain ⟨q, hq, rfl⟩ := List.mem_map.1 hp
    exact hA q (GameState.top_mem_opp_bench hq)

/-- **The clamps of reachable states lie in a finite list.** From any start state (well-formed
or not),
there is a finite list of states containing the clamp (`GameState.clamp`) of every reachable
state.

This is a statement about the clamp, not about play. Without a hypothesis that makes the clamp
a bisimulation (the tameness hypothesis `GameState.Fit` of `Reach.finite`) it says nothing about
which questions of play the finite list answers: for every cap `k ≥ 3` there is a deck with
damage reduction (`Lingering.reduce_breaks_clamp`), and for every `k ≥ 2` a deck with `drain`
(`Lingering.drain_breaks_clamp`), whose clamp kernel is not a simulation, and play can then
separate states with the same clamp. -/
theorem Reach.clamp_mem {g₀ : GameState} :
    ∃ L : List GameState, ∀ g, Reach g₀ g → g.clamp (bound g₀.allCards) ∈ L := by
  refine ⟨states g₀.allCards, fun g h => mem_states ?_ h.clamp_bounded⟩
  rw [GameState.allCards_clamp]; exact h.perm

/-- A start state with tame cards (no damage reduction, no `drain`) and no damage reduction in
effect is `Fit` at `bound`, so `Reach.finite` applies to it. -/
theorem GameState.fit_bound {g₀ : GameState} (ht : ∀ x ∈ g₀.allCards, x.tame = true)
    (hn : g₀.NoReduce) : g₀.Fit (bound g₀.allCards) := by
  refine ⟨by simp only [bound]; omega, fun p hp => ?_, fun x hx => ⟨ht x hx, ?_⟩, hn⟩
  · have := hp_le_maxHp hp; have := resist_le_maxResist hp; simp only [bound]
    exact ⟨by omega, by omega⟩
  · have := tmax_le_cardsTmax hx; simp only [bound]; omega

/-- **Finiteness, for tame decks.** Let `g₀` be any start state (well-formed or not) that is
`Fit` at
`k = bound g₀.allCards` (every card tame, that is without damage reduction or `drain`; no damage
reduction in effect; `GameState.fit_bound` gives this). Then

* the clamps `g.clamp k` of all states reachable from `g₀` lie in one finite list `L`; and
* the kernel of the clamp is a bisimulation along reachable states: if `g₁` is reachable and
  `g₂` has the same clamp, every move from either one is matched by a move from the other to a
  state with the same clamp.

So the quotient of the reachable states by the clamp is a finite transition system with the same
moves, and any question about play whose answer depends only on the clamp (every question that
does not read damage or Poison strength above HP on a Pokémon in play, Active or Benched, or a
damage bonus above `2 * k`) has the same answer in it. The list is not computed, and the move
relation of the quotient is not shown to be computable, so decidability of such questions is not
formalized. -/
theorem Reach.finite {g₀ : GameState} (hF : g₀.Fit (bound g₀.allCards)) :
    (∃ L : List GameState, ∀ g, Reach g₀ g → g.clamp (bound g₀.allCards) ∈ L) ∧
      ∀ g₁ g₂, Reach g₀ g₁ → g₁.clamp (bound g₀.allCards) = g₂.clamp (bound g₀.allCards) →
        (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧
            g₁'.clamp (bound g₀.allCards) = g₂'.clamp (bound g₀.allCards)) ∧
        (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧
            g₂'.clamp (bound g₀.allCards) = g₁'.clamp (bound g₀.allCards)) := by
  refine ⟨Reach.clamp_mem, fun g₁ g₂ h hc => ⟨fun g₁' hm => ?_, fun g₂' hm => ?_⟩⟩
  · exact hm.clamp_sim (h.fit hF) hc
  · exact hm.clamp_sim ((h.fit hF).of_clamp hc) hc.symm

end Pokemon
