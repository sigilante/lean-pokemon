import Pokemon.Damage

/-!
# Finiteness

`Reach.finite`: from a start state with no pending Knock Out, the clamps of all reachable
states lie in one finite list. Since the kernel of `clamp` is a bisimulation
(`Reach.clamp_sim`), the clamped game is a finite transition system that answers every
question about legal play that does not read the damage above HP on the opponent's Active
Pokémon. `Reach.finite_damageBounded`: the reachable states with no pending Knock Out, which
include every state at a turn boundary (`Move.damageBounded_of_turn`), themselves lie in one
finite list, without any clamp.

The list `states g₀.allCards` is a crude over-approximation, built from: lists of length at
most `N` over the starting cards (`N` = the number of cards in the game), the Pokémon cards
among them, damage up to `maxHp`, and the finitely many values of each flag. It is never
computed; it witnesses finiteness only. The proof uses `Reach.perm` (cards are only
permuted) and `Reach.clamp_damage_le` (damage is bounded after the clamp). The only
hypothesis on the start state is `DamageBounded g₀`.
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

/-- A finite list containing every Pokémon in play made of cards from `C` with damage at
most `maxHp C`. -/
def inPlays (C : List Card) : List InPlay :=
  (tops C).flatMap fun top => (cardLists C).flatMap fun under =>
  (cardLists C).flatMap fun energy => (cardLists C).flatMap fun tools =>
  (List.range (maxHp C + 1)).flatMap fun damage => rots.flatMap fun rot =>
  bools.flatMap fun poisoned => bools.flatMap fun burned => bools.map fun fresh =>
  ⟨top, under, energy, tools, damage, rot, poisoned, burned, fresh⟩

theorem mem_inPlays {C : List Card} {p : InPlay} (hw : Within C p.cardList)
    (hd : p.damage ≤ maxHp C) : p ∈ inPlays C := by
  obtain ⟨top, under, energy, tools, damage, rot, poisoned, burned, fresh⟩ := p
  have hw' : Within C (under ++ energy ++ tools) :=
    hw.of_sub (by simp [InPlay.cardList]) (fun _ hx => .tail _ hx)
  simp only [inPlays, List.mem_flatMap, List.mem_map]
  exact ⟨top, mem_tops (hw.2 _ (.head _)), under, mem_cardLists hw'.left.left,
    energy, mem_cardLists hw'.left.right, tools, mem_cardLists hw'.right,
    damage, List.mem_range.2 (Nat.lt_succ_of_le hd), rot, mem_rots _, poisoned, mem_bools _,
    burned, mem_bools _, fresh, mem_bools _, rfl⟩

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

/-- All Pokémon in play on one side have damage at most `M`. -/
def SideDamageLe (M : Nat) (s : PlayerState) : Prop :=
  (∀ p, s.active = some p → p.damage ≤ M) ∧ ∀ p ∈ s.bench, p.damage ≤ M

def players (C : List Card) : List PlayerState :=
  (cardLists C).flatMap fun deck => (cardLists C).flatMap fun hand =>
  (cardLists C).flatMap fun discard => (cardLists C).flatMap fun prizes =>
  (cardLists C).flatMap fun lost => (opts (inPlays C)).flatMap fun active =>
  (listsUpTo (inPlays C) C.length).flatMap fun bench => (opts C).flatMap fun stadium =>
  bools.flatMap fun energyAttached => bools.flatMap fun supporterPlayed =>
  bools.flatMap fun retreated => bools.flatMap fun gxUsed => bools.map fun vstarUsed =>
  ⟨deck, hand, discard, prizes, lost, active, bench, stadium, energyAttached, supporterPlayed,
    retreated, gxUsed, vstarUsed⟩

theorem mem_players {C : List Card} {s : PlayerState} (hw : Within C s.allCards)
    (hd : SideDamageLe (maxHp C) s) : s ∈ players C := by
  obtain ⟨deck, hand, discard, prizes, lost, active, bench, stadium, energyAttached,
    supporterPlayed, retreated, gxUsed, vstarUsed⟩ := s
  simp only [PlayerState.allCards] at hw
  have hbench : Within C (benchCardList bench) := hw.left.right
  have hactive : Within C (optCardList active) := hw.left.left.right
  simp only [players, List.mem_flatMap, List.mem_map]
  refine ⟨deck, mem_cardLists hw.left.left.left.left.left.left.left,
    hand, mem_cardLists hw.left.left.left.left.left.left.right,
    discard, mem_cardLists hw.left.left.left.left.left.right,
    prizes, mem_cardLists hw.left.left.left.left.right,
    lost, mem_cardLists hw.left.left.left.right,
    active, ?_, bench, ?_, stadium, ?_, energyAttached, mem_bools _,
    supporterPlayed, mem_bools _, retreated, mem_bools _, gxUsed, mem_bools _,
    vstarUsed, mem_bools _, rfl⟩
  · refine mem_opts fun p hp => ?_
    subst hp
    exact mem_inPlays hactive (hd.1 p rfl)
  · refine mem_listsUpTo (Nat.le_trans (length_le_benchCardList bench) hbench.1) ?_
    exact fun p hp => mem_inPlays (within_of_mem_bench hbench hp) (hd.2 p hp)
  · refine mem_opts fun c hc => ?_
    subst hc
    exact hw.right.2 c (.head _)

/-- A finite list containing every state whose cards are those of `C` (up to order) and
whose Pokémon in play all have damage at most `maxHp C`. -/
def states (C : List Card) : List GameState :=
  (players C).flatMap fun cur => (players C).flatMap fun opp =>
  bools.flatMap fun curIsFirst => bools.flatMap fun firstTurn =>
  bools.flatMap fun attacked => winners.map fun winner =>
  ⟨cur, opp, curIsFirst, firstTurn, attacked, winner⟩

theorem mem_states {C : List Card} {g : GameState} (hp : g.allCards.Perm C)
    (hd : SideDamageLe (maxHp C) g.cur ∧ SideDamageLe (maxHp C) g.opp) : g ∈ states C := by
  have hw : Within C (g.cur.allCards ++ g.opp.allCards) := Within.of_perm hp
  obtain ⟨cur, opp, curIsFirst, firstTurn, attacked, winner⟩ := g
  simp only [states, List.mem_flatMap, List.mem_map]
  exact ⟨cur, mem_players hw.left hd.1, opp, mem_players hw.right hd.2,
    curIsFirst, mem_bools _, firstTurn, mem_bools _, attacked, mem_bools _,
    winner, mem_winners _, rfl⟩

end Enum

open Enum

theorem optCardList_clamp (o : Option InPlay) :
    optCardList (o.map InPlay.clamp) = optCardList o := by
  cases o <;> rfl

theorem GameState.allCards_clamp (g : GameState) : g.clamp.allCards = g.allCards := by
  simp only [GameState.clamp, GameState.allCards, PlayerState.allCards, optCardList_clamp]

theorem InPlay.clamp_of_lt {p : InPlay} (h : p.damage < p.top.hp) : p.clamp = p := by
  cases p
  simp only [InPlay.clamp] at h ⊢
  rw [Nat.min_eq_left (Nat.le_of_lt h)]

/-- With no pending Knock Out, the clamp changes nothing. -/
theorem GameState.clamp_of_damageBounded {g : GameState} (h : DamageBounded g) :
    g.clamp = g := by
  have e : g.opp.active.map InPlay.clamp = g.opp.active := by
    cases ha : g.opp.active with
    | none => rfl
    | some p =>
        simp only [Option.map_some]
        rw [InPlay.clamp_of_lt (h p (Or.inr (Or.inr (Or.inl ha))))]
  show ({ g with opp := { g.opp with active := g.opp.active.map InPlay.clamp } } : GameState) = g
  rw [e]

/-- **Finiteness.** From a start state with no pending Knock Out, there is a finite list of
states containing the clamp (`GameState.clamp`) of every reachable state. -/
theorem Reach.finite {g₀ : GameState} (h₀ : DamageBounded g₀) :
    ∃ L : List GameState, ∀ g, Reach g₀ g → g.clamp ∈ L := by
  refine ⟨states g₀.allCards, fun g h => mem_states ?_ ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩⟩⟩
  · rw [GameState.allCards_clamp]; exact h.perm
  · exact fun p hp => h.clamp_damage_le h₀ p (Or.inl hp)
  · exact fun p hp => h.clamp_damage_le h₀ p (Or.inr (Or.inl hp))
  · exact fun p hp => h.clamp_damage_le h₀ p (Or.inr (Or.inr (Or.inl hp)))
  · exact fun p hp => h.clamp_damage_le h₀ p (Or.inr (Or.inr (Or.inr hp)))

/-- From a start state with no pending Knock Out, the reachable states with no pending
Knock Out (among them every state at a turn boundary, `Move.damageBounded_of_turn`) lie in a
finite list. -/
theorem Reach.finite_damageBounded {g₀ : GameState} (h₀ : DamageBounded g₀) :
    ∃ L : List GameState, ∀ g, Reach g₀ g → DamageBounded g → g ∈ L := by
  obtain ⟨L, hL⟩ := Reach.finite h₀
  exact ⟨L, fun g h hb => GameState.clamp_of_damageBounded hb ▸ hL g h⟩

end Pokemon
