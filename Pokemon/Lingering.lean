import Pokemon.Finite

/-!
# Lingering modifiers

Each player has a store of lingering modifiers (`Store`), by the turn in which they are in
effect: this turn, the next turn (the opponent's), the turn after (the player's next), and the
rest of the game (`Slot`). An effect adds a modifier with `Effect.linger w s m`: a damage bonus
for the `w` player's attacks, a damage reduction or prevention for attacks against the `w`
player's Pokémon, or a lock on attacking, retreating or playing Items. Bonuses and reductions add
up, without limit (`linger` is a general primitive, usable inside `iter`). `Effect.damage n`
does `n` damage to the opponent's Active Pokémon with the modifiers in effect
(`GameState.dealt`); an attack's base damage is done this way. `Effect.drain n` does the same
and heals the player's Active Pokémon by the damage done.

Expiry. `Move.endTurn` shifts both players' stores (`Store.shift`): this turn's modifiers
expire and the others move one turn closer. `Store.add_now_shift` .. `Store.add_always_shift`
state the result: a modifier for this turn is gone after the end of the turn, one for the next
turn is in effect in that turn, one for the turn after is in effect two turns on, and one for
the rest of the game stays. The between-turns phase and `startTurn` belong to the new turn.

What is proved about finiteness.
* For decks whose cards are *tame* (no damage reduction, no `drain`) and a start with no damage
  reduction in effect, the damage bonus can be capped: the clamp `GameState.clamp k`, which caps
  every bonus at `k = bound` (more than every printed HP and every test constant in the cards),
  is a bisimulation (`Move.clamp_sim`, `Reach.clamp_sim`, under `GameState.Fit k`; `Fit` holds
  at `bound` by `GameState.fit_bound`), and the clamps of the reachable states lie in a finite
  list (`Reach.finite`, which holds for every deck). The reason: a bonus is read only by
  `damage`, which adds it to the opponent's damage, and that damage is read only by tests
  against constants below `k` and by the Knock Out test at HP, so a bonus of `k` or more acts
  as `k` does.
* `reduce_breaks_clamp`: with damage reduction, no cap works. Damage done is `(n + bonus) -
  reduction`, so a bonus above the cap matters when a reduction above the cap offsets it: for
  every `k ≥ 3` there is a well-formed start, `Fit k` except that one card adds a damage
  reduction, from which two states with the same clamp are reachable whose attacks do 1 and 2
  damage.
* `drain_breaks_clamp`: with `drain` and in-attack self-damage, no cap works either: the heal
  reads the bonus exactly, and the attacker's own damage, raised above `k` by `selfDamage`
  earlier in the same attack, shows it.

What is not proved: whether, for decks with both a damage bonus and a damage reduction (or a
`drain`), the reachable states are finite up to some other bisimulation. The obstacle is that
bonus and reduction are two unbounded counters whose difference is observable: with modifiers
for the rest of the game, an attack used every turn could raise one and the opponent's attack
lower it, and `damage` tests the difference against zero. The printed cards do not do this:
S7 found that every lingering damage bonus or reduction is bounded by the copies of its card
times a printed constant, and that the rest-of-game ones come from once-per-game GX attacks.
-/

namespace Pokemon

/-! ## Expiry -/

/-- A modifier for this turn expires at the end of the turn. -/
theorem Store.add_now_shift (t : Store) (m : Mod) : (t.add .now m).shift = t.shift := rfl

/-- A modifier for the next turn is in effect during it. -/
theorem Store.add_next_shift (t : Store) (m : Mod) :
    (t.add .next m).shift = t.shift.add .now m := rfl

/-- A modifier for the turn after next is in effect two turns on. -/
theorem Store.add_after_shift (t : Store) (m : Mod) :
    (t.add .after m).shift.shift = t.shift.shift.add .now m := rfl

/-- A modifier for the rest of the game stays. -/
theorem Store.add_always_shift (t : Store) (m : Mod) :
    (t.add .always m).shift = t.shift.add .always m := rfl

namespace Lingering

/-- A Basic Pokémon with `h` counters of HP and one free attack: base damage 0, effect `e`. -/
def mon (h : Nat) (e : Effect) : PokemonCard :=
  ⟨"Mon", .basic, none, h, .colorless, [⟨"Hit", [], 0, e⟩], 0⟩

def side (hand discard : List Card) (a : InPlay) (t : Store) : PlayerState :=
  ⟨[.energy .grass], hand, discard, [.energy .fire], [], some a, [], none, false, false, false,
    false, false, t⟩

/-- The player to move has `a` and the store `s`; the opponent has `b` and the store `t`. -/
def st (hand discard : List Card) (a b : InPlay) (s t : Store) : GameState :=
  ⟨side hand discard a s, side [] [] b t, true, false, false, false, none⟩

theorem settled_st (hand discard : List Card) (a b : InPlay) (s t : Store)
    (ha : a.damage < a.top.hp) (hb : b.damage < b.top.hp) :
    Settled (st hand discard a b s t) := by
  refine ⟨fun p hp => ?_, by simp [st, side], by simp [st, side]⟩
  rcases hp with hp | hp | hp | hp
  · simp only [st, side, Option.some.injEq] at hp; subst hp; exact ha
  · simp [st, side] at hp
  · simp only [st, side, Option.some.injEq] at hp; subst hp; exact hb
  · simp [st, side] at hp

theorem wellFormed_st (hand discard : List Card) (a b : InPlay) (s t : Store) :
    WellFormed (st hand discard a b s t) :=
  ⟨fun _ => ⟨by simp [st, side], by simp [st, side]⟩, fun p hp => by simp [st, side] at hp,
    fun p hp => by simp [st, side] at hp⟩

theorem clamp_st {k : Nat} (hand discard : List Card) (a b : InPlay) {s₁ s₂ : Store}
    (t : Store) (h : s₁.cap k = s₂.cap k) :
    (st hand discard a b s₁ t).clamp k = (st hand discard a b s₂ t).clamp k := by
  simp only [GameState.clamp, GameState.clampAt, st, side, h]

/-- A store with a damage bonus `n` for this turn. -/
def bonusNow (n : Nat) : Store := Store.empty.add .now (.bonus n)

theorem bonusNow_cap (k : Nat) : (bonusNow (k + 1)).cap k = (bonusNow (k + 2)).cap k := by
  rw [Store.cap_iff]
  refine ⟨?_, rfl, rfl, rfl⟩
  rw [Mods.cap_iff]
  exact ⟨show min (0 + (k + 1)) k = min (0 + (k + 2)) k by omega, rfl, rfl, rfl, rfl, rfl⟩

/-! ## Damage reduction breaks the cap -/

/-- Give the opponent a damage reduction of `k` for this turn, and take a damage bonus of `k + 1`
or `k + 2` for this turn. -/
def redItem (k : Nat) : Card :=
  .trainer "Reduce" .item (.seq (.linger .opp .now (.reduce k))
    (.choice (.linger .own .now (.bonus (k + 1))) (.linger .own .now (.bonus (k + 2)))))

/-- The attacker: 1 HP counter, a free attack with base damage 0 and no effect. -/
def hitter : PokemonCard := mon 1 .skip

/-- The target: 3 HP counters. -/
def target : PokemonCard := mon 3 .skip

def red₀ (k : Nat) : GameState :=
  st [redItem k] [] (InPlay.ofBasic hitter) (InPlay.ofBasic target) Store.empty Store.empty

def red (k b : Nat) : GameState :=
  st [] [redItem k] (InPlay.ofBasic hitter) (InPlay.ofBasic target) (bonusNow b)
    (Store.empty.add .now (.reduce k))

theorem reach_red (k : Nat) (i : Bool) : Reach (red₀ k) (red k (if i then k + 1 else k + 2)) := by
  have s₁ := settled_st [] [redItem k] (InPlay.ofBasic hitter) (InPlay.ofBasic target)
    Store.empty (Store.empty.add .now (.reduce k)) (by decide) (by decide)
  cases i with
  | true =>
      exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) rfl rfl
        (settled_st _ _ _ _ _ _ (by decide) (by decide))
        (.seq (.prim rfl rfl (.linger .opp .now _ _) (.done (.inl s₁)))
          (.choiceL (.prim rfl rfl (.linger .own .now _ _)
            (.done (.inl (settled_st _ _ _ _ _ _ (by decide) (by decide))))))) rfl)
  | false =>
      exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) rfl rfl
        (settled_st _ _ _ _ _ _ (by decide) (by decide))
        (.seq (.prim rfl rfl (.linger .opp .now _ _) (.done (.inl s₁)))
          (.choiceR (.prim rfl rfl (.linger .own .now _ _)
            (.done (.inl (settled_st _ _ _ _ _ _ (by decide) (by decide))))))) rfl)

theorem hpLe_red₀ {k : Nat} (hk : 3 ≤ k) : (red₀ k).HpLe k := by
  intro p hp
  simp [red₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
    stadiumCardList, InPlay.cardList, InPlay.ofBasic, redItem, hitter, target, mon] at hp
  rcases hp with rfl | rfl <;> simp <;> omega

theorem tmax_red₀ {k : Nat} (hk : 3 ≤ k) : ∀ x ∈ (red₀ k).allCards, x.tmax < k := by
  intro x hx
  simp [red₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
    stadiumCardList, InPlay.cardList, InPlay.ofBasic] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Card.tmax, attacksTmax, Effect.tmax, redItem, hitter, target, mon] <;> omega

/-- **Damage reduction breaks every cap on the damage bonus.** For every `k ≥ 3` there is a
well-formed, `Settled` start with no damage reduction in effect, every HP at most `k` and every
test constant below `k` (so `GameState.Fit k` holds except that one card, an Item, adds a damage
reduction), from which two states are reachable with the same `clamp k` (damage bonus `k + 1`
and `k + 2`, both capped at `k`; the opponent's reduction `k`), such that an attack from the
first does 1 damage and no move from the second reaches a state with the same clamp (every
attack from it does 2). So the kernel of `clamp k` is not a simulation, whatever `k` is. -/
theorem reduce_breaks_clamp (k : Nat) (hk : 3 ≤ k) :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.NoReduce ∧ g₀.HpLe k ∧
      (∀ x ∈ g₀.allCards, x.tmax < k) ∧
      ∃ g₁ g₂ g₁', Reach g₀ g₁ ∧ Reach g₀ g₂ ∧ g₁.clamp k = g₂.clamp k ∧ Move g₁ g₁' ∧
        ∀ g₂', Move g₂ g₂' → g₁'.clamp k ≠ g₂'.clamp k := by
  refine ⟨red₀ k, wellFormed_st _ _ _ _ _ _, settled_st _ _ _ _ _ _ (by decide) (by decide),
    ⟨⟨rfl, rfl, rfl, rfl⟩, ⟨rfl, rfl, rfl, rfl⟩⟩, hpLe_red₀ hk, tmax_red₀ hk,
    red k (k + 1), red k (k + 2), _, reach_red k true, reach_red k false,
    clamp_st _ _ _ _ _ (bonusNow_cap k),
    .attack (atk := ⟨"Hit", [], 0, .skip⟩) rfl (.head _) (Nat.zero_le _) rfl rfl rfl rfl
      (settled_st _ _ _ _ _ _ (by decide) (by decide)) (.seq (.damage 0 rfl) (.skip _)) rfl,
    fun g₂' hm heq => ?_⟩
  cases hm with
  | playBasic hh => simp [red, st, side] at hh
  | attach hh => simp [red, st, side] at hh
  | evolve hh => simp [red, st, side] at hh
  | retreat ha hb => simp [red, st, side] at hb
  | item hh => simp [red, st, side] at hh
  | supporter hh => simp [red, st, side] at hh
  | @attack g' a atk ha hm hc hs hn hf hbt hst hr hl =>
      simp only [red, st, side, Option.some.injEq] at ha
      subst ha
      simp only [InPlay.ofBasic, hitter, mon, List.mem_singleton] at hm
      subst hm
      cases hr with
      | seq h1 h2 =>
          cases h1 with
          | damage n hp =>
              simp only [red, st, side, Option.some.injEq] at hp
              subst hp
              cases h2 with
              | skip =>
                  have e := congrArg (fun g : GameState => g.opp.active) heq
                  simp [GameState.clamp, GameState.clampAt, InPlay.clampWith, Cap.dmg, red, st,
                    side, GameState.dealt, dealtBy, Store.live, Mods.merge, Store.add,
                    Mods.addMod, Store.empty, Mods.empty, bonusNow, InPlay.ofBasic, target,
                    mon] at e <;> omega
              | touchActive he => simp [Effect.touch] at he
              | touchBench he => simp [Effect.touch] at he
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
  | attackConfused ha hm hc hs =>
      simp only [red, st, side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic] at hs
  | knockOut ha hk =>
      simp only [red, st, side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic, target, mon] at hk
  | promote ha => simp [red, st, side] at ha
  | noPokemon ha => simp [red, st, side] at ha
  | knockOutOwn ha hk =>
      simp only [red, st, side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic, hitter, mon] at hk
  | promoteOwn ha => simp [red, st, side] at ha
  | noPokemonOwn ha => simp [red, st, side] at ha
  | endTurn =>
      have e := congrArg GameState.attacked heq
      simp [GameState.clamp, GameState.clampAt] at e
  | startTurn hbt => simp [red, st] at hbt
  | deckOut hbt => simp [red, st] at hbt

/-! ## `drain` breaks the cap -/

/-- Take a damage bonus of `k + 1` or `k + 2` for this turn. -/
def bonusItem (k : Nat) : Card :=
  .trainer "Bonus" .item (.choice (.linger .own .now (.bonus (k + 1)))
    (.linger .own .now (.bonus (k + 2))))

/-- The attacker: 2 HP counters, a free attack with base damage 0 whose effect puts `k + 2`
damage counters on itself and then does 0 damage, healing the attacker by the damage done. -/
def drainer (k : Nat) : PokemonCard := mon 2 (.seq (.selfDamage (k + 2)) (.drain 0))

/-- The target: 1 HP counter. -/
def prey : PokemonCard := mon 1 .skip

theorem drainer_ok (k : Nat) :
    (InPlay.ofBasic (drainer k)).damage < (InPlay.ofBasic (drainer k)).top.hp := Nat.zero_lt_two

def dr₀ (k : Nat) : GameState :=
  st [bonusItem k] [] (InPlay.ofBasic (drainer k)) (InPlay.ofBasic prey) Store.empty Store.empty

def dr (k b : Nat) : GameState :=
  st [] [bonusItem k] (InPlay.ofBasic (drainer k)) (InPlay.ofBasic prey) (bonusNow b) Store.empty

theorem reach_dr (k : Nat) (i : Bool) : Reach (dr₀ k) (dr k (if i then k + 1 else k + 2)) := by
  cases i with
  | true =>
      exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) rfl rfl
        (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide))
        (.choiceL (.prim rfl rfl (.linger .own .now _ _)
          (.done (.inl (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide)))))) rfl)
  | false =>
      exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) rfl rfl
        (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide))
        (.choiceR (.prim rfl rfl (.linger .own .now _ _)
          (.done (.inl (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide)))))) rfl)

theorem hpLe_dr₀ {k : Nat} (hk : 2 ≤ k) : (dr₀ k).HpLe k := by
  intro p hp
  simp [dr₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
    stadiumCardList, InPlay.cardList, InPlay.ofBasic, bonusItem, drainer, prey, mon] at hp
  rcases hp with rfl | rfl <;> simp <;> omega

theorem tmax_dr₀ {k : Nat} (hk : 2 ≤ k) : ∀ x ∈ (dr₀ k).allCards, x.tmax < k := by
  intro x hx
  simp [dr₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
    stadiumCardList, InPlay.cardList, InPlay.ofBasic] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Card.tmax, attacksTmax, Effect.tmax, bonusItem, drainer, prey, mon] <;> omega

/-- **`drain` breaks every cap on the damage bonus.** For every `k ≥ 2` there is a well-formed,
`Settled` start with no damage reduction anywhere, every HP at most `k` and every test constant
below `k` (so `GameState.Fit k` holds except that one card's attack uses `drain`), from which two
states are reachable with the same `clamp k` (damage bonus `k + 1` and `k + 2`), such that the
attack from the first leaves the attacker with 1 damage counter and no move from the second
reaches a state with the same clamp (the attack leaves it with none). The attack first puts
`k + 2` counters on the attacker, above every cap, and `drain` then removes exactly the damage
done. -/
theorem drain_breaks_clamp (k : Nat) (hk : 2 ≤ k) :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.NoReduce ∧ g₀.HpLe k ∧
      (∀ x ∈ g₀.allCards, x.tmax < k) ∧
      ∃ g₁ g₂ g₁', Reach g₀ g₁ ∧ Reach g₀ g₂ ∧ g₁.clamp k = g₂.clamp k ∧ Move g₁ g₁' ∧
        ∀ g₂', Move g₂ g₂' → g₁'.clamp k ≠ g₂'.clamp k := by
  refine ⟨dr₀ k, wellFormed_st _ _ _ _ _ _, settled_st _ _ _ _ _ _ (drainer_ok k) (by decide),
    ⟨⟨rfl, rfl, rfl, rfl⟩, ⟨rfl, rfl, rfl, rfl⟩⟩, hpLe_dr₀ hk, tmax_dr₀ hk,
    dr k (k + 1), dr k (k + 2), _, reach_dr k true, reach_dr k false,
    clamp_st _ _ _ _ _ (bonusNow_cap k),
    .attack (atk := ⟨"Hit", [], 0, .seq (.selfDamage (k + 2)) (.drain 0)⟩) rfl (.head _)
      (Nat.zero_le _) rfl rfl rfl rfl (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide))
      (.seq (.damage 0 rfl) (.seq (.selfDamage _ rfl) (.drain 0 rfl rfl))) rfl,
    fun g₂' hm heq => ?_⟩
  cases hm with
  | playBasic hh => simp [dr, st, side] at hh
  | attach hh => simp [dr, st, side] at hh
  | evolve hh => simp [dr, st, side] at hh
  | retreat ha hb => simp [dr, st, side] at hb
  | item hh => simp [dr, st, side] at hh
  | supporter hh => simp [dr, st, side] at hh
  | @attack g' a atk ha hm hc hs hn hf hbt hst hr hl =>
      simp only [dr, st, side, Option.some.injEq] at ha
      subst ha
      simp only [InPlay.ofBasic, drainer, mon, List.mem_singleton] at hm
      subst hm
      cases hr with
      | seq h1 h2 =>
          cases h1 with
          | damage n hp =>
              simp only [dr, st, side, Option.some.injEq] at hp
              subst hp
              cases h2 with
              | seq h3 h4 =>
                  cases h3 with
                  | selfDamage n hq =>
                      simp only [dr, st, side, Option.some.injEq] at hq
                      subst hq
                      cases h4 with
                      | drain n hp hq =>
                          simp only [dr, st, side, Option.some.injEq] at hp hq
                          subst hp hq
                          have e := congrArg (fun g : GameState => g.cur.active) heq
                          simp [GameState.clamp, GameState.clampAt, InPlay.clampWith, Cap.dmg,
                            dr, st, side, GameState.dealt, dealtBy, Store.live, Mods.merge,
                            Store.add, Mods.addMod, Store.empty, Mods.empty, bonusNow,
                            InPlay.ofBasic, drainer, mon] at e <;> omega
                      | touchActive he => simp [Effect.touch] at he
                      | touchBench he => simp [Effect.touch] at he
                  | touchActive he => simp [Effect.touch] at he
                  | touchBench he => simp [Effect.touch] at he
              | touchActive he => simp [Effect.touch] at he
              | touchBench he => simp [Effect.touch] at he
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
  | attackConfused ha hm hc hs =>
      simp only [dr, st, side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic] at hs
  | knockOut ha hk =>
      simp only [dr, st, side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic, prey, mon] at hk
  | promote ha => simp [dr, st, side] at ha
  | noPokemon ha => simp [dr, st, side] at ha
  | knockOutOwn ha hk =>
      simp only [dr, st, side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic, drainer, mon] at hk
  | promoteOwn ha => simp [dr, st, side] at ha
  | noPokemonOwn ha => simp [dr, st, side] at ha
  | endTurn =>
      have e := congrArg GameState.attacked heq
      simp [GameState.clamp, GameState.clampAt] at e
  | startTurn hbt => simp [dr, st] at hbt
  | deckOut hbt => simp [dr, st] at hbt

end Lingering

end Pokemon
