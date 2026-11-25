import Pokemon.Finite

/-!
# Lingering modifiers

Each player has a store of lingering modifiers (`Store`), by the turn in which they are in
effect: this turn, the next turn (the opponent's), the turn after (the player's next), and the
rest of the game (`Slot`). An effect adds a modifier with `Effect.linger w s m`: a damage bonus
for the `w` player's attacks, a damage reduction or prevention for attacks against the `w`
player's Pokémon, or a lock on attacking, retreating or playing Items. Bonuses and reductions add
up, without limit (`linger` is a general primitive, usable inside `iter`). An attack's damage
step (`Effect.damage a`, once per attack) does the damage the rulebook's calculation gives for
the base damage `n` its amount evaluates to (`GameState.dealt`, `dealtBy`): nothing at all if
`n = 0`, else `n` plus the bonus, doubled under Weakness, less Resistance, less the reduction.
`Effect.drain a` does the same and heals the player's Active Pokémon by the damage done.

Expiry. `Move.endTurn` shifts both players' stores (`Store.shift`): this turn's modifiers
expire and the others move one turn closer. `Store.add_now_shift` .. `Store.add_always_shift`
state the result: a modifier for this turn is gone after the end of the turn, one for the next
turn is in effect in that turn, one for the turn after is in effect two turns on, and one for
the rest of the game stays. The between-turns phase and `startTurn` belong to the new turn.

What is proved about finiteness.
* For decks whose cards are *tame* (no stored damage reduction, no `drain` (since milestone MV6 also no step-2 penalty or step-5 increase, `Mod.plain`)) and a start with no
  damage reduction stored, the damage bonus can be capped: the clamp `GameState.clamp k`, which caps
  every bonus at `2 * k` with `k = bound` (more than every derived HP, every Resistance plus the
  static damage reduction bound, and every test constant in the cards), is a bisimulation (`Move.clamp_sim`, `Reach.clamp_sim`, under `GameState.Fit k`; `Fit` holds
  at `bound` by `GameState.fit_bound`), and the clamps of the reachable states lie in a finite
  list (`Reach.finite` states both; the list half alone, `Reach.clamp_mem`, holds for every deck
  but says nothing about play without `Fit`). The reason: a bonus is read only by the damage
  step, which adds it to the opponent's damage, and that damage is read only by tests against
  constants below `k` and by the Knock Out test at HP, so a bonus of `2 * k` or more acts as
  `2 * k` does (the factor 2 absorbs a Resistance of at most `k`; Weakness only doubles).
* `reduce_breaks_clamp`: for every cap `k ≥ 3` there is a deck with damage reduction for which
  the clamp at `k` is not a simulation (smaller caps are not considered: `Fit k` asks for every
  printed HP to be at most `k`, and the witness has a 3-HP Pokémon). Damage done by base
  damage `n ≥ 1` is `(n + bonus) - reduction` without Weakness or Resistance (base damage 0
  does nothing, `dealtBy`), so a bonus above the cap matters when a reduction above the cap
  offsets it: the witness is a well-formed start, `Fit k` except that one card adds a damage
  reduction, from which two states with the same clamp are reachable (bonuses `2k + 1` and
  `2k + 2` against a reduction `2k + 1`, above the store cap `2k`) whose attacks, of base
  damage 1, do 1 and 2 damage. (Milestone M4 rebuilt the witness: the bonuses were `k + 1`
  and `k + 2` when the stores were capped at `k`.)
* `drain_breaks_clamp`: likewise, for every cap `k ≥ 2` there is a deck with `drain` and
  in-attack self-damage for which the clamp is not a simulation: the heal reads the bonus
  exactly, and the attacker's own damage, raised above the store cap by `selfDamage` earlier in
  the same attack (before its damage step), shows it.

* Both counterexamples reach two states whose stores differ only above the cap. The clamp with
  exact stores, `GameState.xclamp` (`Pokemon/Exact.lean`), does not identify them; its kernel is
  a bisimulation for every deck, on all pairs of states (`Reach.xclamp_bisim`,
  `GameState.xclamp_bisim`), and its reachable values are finite for
  decks with no damage bonus or reduction under `iter` and rest-of-game bonuses and reductions
  only in GX attacks (`StoreSafe.xfinite`, `Pokemon/StoreSafe.lean`); such decks may use damage
  reduction and `drain`.

Beyond the clamp. For some decks that are not tame the obstacle is not the choice of clamp.
With modifiers for the rest of the game (`Slot.always`, which never expires), the differences
between one player's damage reduction and the other's damage bonus are two persistent,
unbounded counters: `linger` raises either side, and `seq (damage (const 1)) (ite (exactly opp
d) …)` tests one of them against zero exactly. `Pokemon/Counter.lean` turns this into a theorem: the
model, so generalised, simulates every two-counter machine, and reachability of a halt mark is
equivalent to halting (`Counter.universal`). With Minsky's theorem (prose, not formalised) this
rules out a uniform computable finite abstraction of the generalised model; for any single
machine a finite quotient respecting the halt question exists, non-constructively. Separately,
`Counter.not_finite_up_to` shows that for one witness deck (with a reduction, without `drain`)
the reachable states are not finite up to any equivalence fine enough to recover the encoded
configuration. That is a statement about representation, not play (its machine never reads
its counter), and not the counterpart of `Reach.finite`. The construction never uses `drain`,
and a deck whose reduction card is never played is unaffected. The printed cards do not do
this: S7 found that the rest-of-game damage bonuses and reductions come from once-per-game GX
attacks, and that same-turn ones are bounded by the copies of their card times a printed
constant, provided no card-recycling loop replays them (an empirical claim about the card
pool). A reduction carried into the opponent's turn does exist on a printed Item (Iron
Defender: "During your opponent's next turn, all of your Metal Pokémon take 30 less
damage…").
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

/-- A Basic Pokémon with `h` counters of HP and one free attack: base damage `d`, effect `e`. -/
def mon (h d : Nat) (e : Effect) : PokemonCard :=
  ⟨"Mon", .basic, none, h, .colorless, [⟨"Hit", [], d, e, false, .none⟩], 0, none, none, .none, false, []⟩

def side (hand discard : List Card) (a : InPlay) (t : Store) : PlayerState :=
  ⟨[.energy .grass], hand, discard, [.energy .fire], [], some a, [], false, false, false,
    false, false, t, true, KOHist.empty, none⟩

/-- The player to move has `a` and the store `s`; the opponent has `b` and the store `t`. -/
def st (hand discard : List Card) (a b : InPlay) (s t : Store) : GameState :=
  ⟨side hand discard a s, side [] [] b t, true, false, false, false, none, none, false, false, false⟩

/-- No static effect has a source in play (milestone M6): the witnesses' cards have none. -/
theorem plain_st (hand discard : List Card) (a b : InPlay) (s t : Store)
    (hsa : a.sv.statics = []) (hsb : b.sv.statics = []) : (st hand discard a b s t).Plain :=
  GameState.Plain.intro (fun _ hp => by cases hp; exact hsa) (fun _ hp => by cases hp)
    (fun _ hp => by cases hp; exact hsb) (fun _ hp => by cases hp) rfl

theorem settled_st (hand discard : List Card) (a b : InPlay) (s t : Store)
    (ha : a.damage < a.top.hp) (hb : b.damage < b.top.hp)
    (hsa : a.sv.statics = [] := by rfl) (hsb : b.sv.statics = [] := by rfl) :
    Settled (st hand discard a b s t) := by
  have hpl := plain_st hand discard a b s t hsa hsb
  refine ⟨DamageBounded.intro' (fun p hp => ?_) (fun p hp => ?_) (fun p hp => ?_)
    (fun p hp => ?_), by simp [st, side], by simp [st, side]⟩
  · rw [hpl.hpOf (w := .own) (sp := .active) hp]
    simp only [st, side, Option.some.injEq] at hp; subst hp; exact ha
  · simp [st, side] at hp
  · rw [hpl.hpOf (w := .opp) (sp := .active) hp]
    simp only [st, side, Option.some.injEq] at hp; subst hp; exact hb
  · simp [st, side] at hp

theorem wellFormed_st (hand discard : List Card) (a b : InPlay) (s t : Store)
    (hm : (st hand discard a b s t).MarksOk) : WellFormed (st hand discard a b s t) :=
  ⟨fun _ => ⟨by simp [st, side], by simp [st, side]⟩, fun p hp => by simp [st, side] at hp,
    fun p hp => by simp [st, side] at hp, hm⟩

theorem clamp_st {k : Nat} (hand discard : List Card) (a b : InPlay) {s₁ s₂ : Store}
    (t : Store) (h : s₁.cap (2 * k) = s₂.cap (2 * k)) :
    (st hand discard a b s₁ t).clamp k = (st hand discard a b s₂ t).clamp k := by
  simp only [GameState.clamp, GameState.clampAt, st, side, h]

/-- A store with a damage bonus `n` for this turn. -/
def bonusNow (n : Nat) : Store := Store.empty.add .now (.bonus n)

/-- Bonuses of `2k + 1` and `2k + 2` have the same cap at `2k`, where `clamp k` caps the
stores. -/
theorem bonusNow_cap (k : Nat) :
    (bonusNow (2 * k + 1)).cap (2 * k) = (bonusNow (2 * k + 2)).cap (2 * k) := by
  rw [Store.cap_iff]
  refine ⟨?_, rfl, rfl, rfl⟩
  rw [Mods.cap_iff]
  exact ⟨show min (0 + (2 * k + 1)) (2 * k) = min (0 + (2 * k + 2)) (2 * k) by omega, rfl, rfl,
    rfl, rfl, rfl, rfl, rfl⟩

/-! ## Damage reduction breaks the cap -/

/-- Give the opponent a damage reduction of `2k + 1` for this turn, and take a damage bonus of
`2k + 1` or `2k + 2` for this turn (both above the cap `2k` of `clamp k` on the stores). -/
def redItem (k : Nat) : Card :=
  .trainer "Reduce" .item (.seq (.linger .opp .now (.reduce (2 * k + 1)))
    (.choice (.linger .own .now (.bonus (2 * k + 1))) (.linger .own .now (.bonus (2 * k + 2)))))

/-- The attacker: 1 HP counter, a free attack with base damage 1 (10 damage) and no effect.
The base damage is not 0, so the bonus and the reduction both apply (`dealtBy`). -/
def hitter : PokemonCard := mon 1 1 .skip

/-- The target: 3 HP counters. -/
def target : PokemonCard := mon 3 0 .skip

def red₀ (k : Nat) : GameState :=
  st [redItem k] [] (InPlay.ofBasic hitter) (InPlay.ofBasic target) Store.empty Store.empty

def red (k b : Nat) : GameState :=
  st [] [redItem k] (InPlay.ofBasic hitter) (InPlay.ofBasic target) (bonusNow b)
    (Store.empty.add .now (.reduce (2 * k + 1)))

theorem reach_red (k : Nat) (i : Bool) :
    Reach (red₀ k) (red k (if i then 2 * k + 1 else 2 * k + 2)) := by
  have s₁ := settled_st [] [redItem k] (InPlay.ofBasic hitter) (InPlay.ofBasic target)
    Store.empty (Store.empty.add .now (.reduce (2 * k + 1))) (by decide) (by decide)
  cases i with
  | true =>
      exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) rfl rfl
        (settled_st _ _ _ _ _ _ (by decide) (by decide))
        (.seq (.prim rfl rfl (.linger .opp .now _ _) (.done (.inl s₁)))
          (.choiceL (.prim rfl rfl (.linger .own .now _ _)
            (.done (.inl (settled_st _ _ _ _ _ _ (by decide) (by decide))))))) rfl rfl rfl rfl)
  | false =>
      exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) rfl rfl
        (settled_st _ _ _ _ _ _ (by decide) (by decide))
        (.seq (.prim rfl rfl (.linger .opp .now _ _) (.done (.inl s₁)))
          (.choiceR (.prim rfl rfl (.linger .own .now _ _)
            (.done (.inl (settled_st _ _ _ _ _ _ (by decide) (by decide))))))) rfl rfl rfl rfl)

theorem hpLe_red₀ {k : Nat} (hk : 3 ≤ k) : (red₀ k).HpLe k := by
  refine ⟨hpBound_le_of (fun c hc => ?_) (fun p hp => ?_), fun p hp => ?_⟩
  · simp [red₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
      stadiumCardList, InPlay.cardList, InPlay.ofBasic] at hc
    rcases hc with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl
  · simp [red₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
      stadiumCardList, InPlay.cardList, InPlay.ofBasic, redItem, hitter, target, mon] at hp
    rcases hp with rfl | rfl <;> simp <;> omega
  · simp [red₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
      stadiumCardList, InPlay.cardList, InPlay.ofBasic, redItem, hitter, target, mon] at hp
    rcases hp with rfl | rfl <;> simp [PokemonCard.resistAmt] <;> omega

theorem tmax_red₀ {k : Nat} (hk : 3 ≤ k) : ∀ x ∈ (red₀ k).allCards, x.tmax < k := by
  intro x hx
  simp [red₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
    stadiumCardList, InPlay.cardList, InPlay.ofBasic] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Card.tmax, attacksTmax, abilitiesTmax, Effect.tmax, redItem, hitter, target, mon] <;> omega

/-- **Damage reduction breaks every cap on the damage bonus.** For every `k ≥ 3` there is a
well-formed, `Settled` start with no damage reduction in effect, every HP (and Resistance) at
most `k` and every test constant below `k` (so `GameState.Fit k` holds except that one card, an
Item, adds a damage reduction), from which two states are reachable with the same `clamp k`
(damage bonus `2k + 1` and `2k + 2`, both capped at `2k`; the opponent's reduction `2k + 1`),
such that an attack with base damage 1 from the first does `1 + (2k + 1) - (2k + 1) = 1` damage
counter and no move from the second reaches a state with the same clamp (every attack from it
does 2). So the kernel of `clamp k` is not a simulation, whatever `k` is. (An earlier witness
used base damage 0 and did damage through the bonus alone; the rulebook's stop at base damage 0,
now in `dealtBy`, rules that out. Milestone M4 moved the bonuses above the new store cap `2k`.)
-/
theorem reduce_breaks_clamp (k : Nat) (hk : 3 ≤ k) :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.NoReduce ∧ g₀.HpLe k ∧
      (∀ x ∈ g₀.allCards, x.tmax < k) ∧
      ∃ g₁ g₂ g₁', Reach g₀ g₁ ∧ Reach g₀ g₂ ∧ g₁.clamp k = g₂.clamp k ∧ Move g₁ g₁' ∧
        ∀ g₂', Move g₂ g₂' → g₁'.clamp k ≠ g₂'.clamp k := by
  refine ⟨red₀ k, wellFormed_st _ _ _ _ _ _ (.of_b rfl), settled_st _ _ _ _ _ _ (by decide) (by decide),
    ⟨Store.NoReduce.empty, Store.NoReduce.empty⟩, hpLe_red₀ hk, tmax_red₀ hk,
    red k (2 * k + 1), red k (2 * k + 2), _, reach_red k true, reach_red k false,
    clamp_st _ _ _ _ _ (bonusNow_cap k),
    .attack (hlk := rfl) (atk := ⟨"Hit", [], 1, .skip, false, .none⟩) rfl (.head _) (.nil _) rfl rfl rfl
      rfl (settled_st _ _ _ _ _ _ (by decide) (by decide))
      (.seq (.damage (.const 1 _) rfl) (.skip _)) rfl (fun h => nomatch h) rfl
      (HitTrig.exists_nil (.seq (.damage (.const 1 _) rfl) (.skip _)) rfl) (.nil _),
    fun g₂' hm heq => ?_⟩
  cases hm with
  | playBasic hh => simp [red, st, side] at hh
  | trigger _ hp => simp [red, st] at hp
  | attach hh => simp [red, st, side] at hh
  | evolve hh => simp [red, st, side] at hh
  | attachBench hh => simp [red, st, side] at hh
  | evolveBench hh => simp [red, st, side] at hh
  | retreat ha hb => simp [red, st, side] at hb
  | item hh => simp [red, st, side] at hh
  | supporter hh => simp [red, st, side] at hh
  | stadium hh => simp [red, st, side] at hh
  | stadiumUse hs => simp [red, st, side] at hs
  | tool hh => simp [red, st, side] at hh
  | toolBench hh => simp [red, st, side] at hh
  | ability hu hm =>
      cases hu with
      | active ha =>
          simp only [red, st, side, Option.some.injEq] at ha
          subst ha
          simp [InPlay.abilities, InPlay.ofBasic, hitter, mon] at hm
      | bench hb => simp [red, st, side] at hb
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [red, st, side] at hh
  | @attack g' a atk ha hm hc hs hn hf hbt hst hr hl _ _ _ _ hd ht =>
      simp only [red, st, side, Option.some.injEq] at ha
      subst ha
      simp only [InPlay.attacks, InPlay.ofBasic, hitter, mon, List.flatMap_nil, List.append_nil,
        List.mem_singleton] at hm
      subst hm
      change Run (.seq (.damage (.const 1)) .skip) _ _ at hr
      cases hr with
      | seq h1 h2 =>
          cases h1 with
          | damage hv hp =>
              cases hv
              simp only [red, st, side, Option.some.injEq] at hp
              subst hp
              cases h2 with
              | skip =>
                  obtain rfl := hd.nil_of rfl
                  cases ht
                  have e := congrArg (fun g : GameState => g.opp.active) heq
                  simp [GameState.clamp, GameState.clampAt, InPlay.clampWith, Cap.dmg, red, st,
                    side, GameState.dealt, dealtBy, GameState.weak, GameState.resist, GameState.sBonus,
                    GameState.sReduce, GameState.sPrevent, GameState.inForce, staticsInForce, PlayerState.field, fieldOf,
                    InPlay.sv, SView.statics, stadiumStatics, sumOf, List.flatMap_cons,
                    List.flatMap_nil, Whose.flip, GameState.stOwn, GameState.side,
                    PokemonCard.weakTo, PokemonCard.resistTo, Store.live, Mods.merge, Store.add,
                    Mods.addMod, Store.empty, Mods.empty, bonusNow, InPlay.ofBasic, target,
                    hitter, mon, GameState.afterAttack, InPlay.noteLock] at e <;> omega
              | touchActive he => simp [Effect.touch] at he
              | touchBench he => simp [Effect.touch] at he
              | zone hw => simp [Effect.zSide] at hw
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | attackConfused ha hm hc hs =>
      simp only [red, st, side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic] at hs
  | knockOuts h =>
      have hs : Settled (red k (2 * k + 2)) := settled_st _ _ _ _ _ _ (by decide) (by decide)
      cases h with
      | won hu => exact hu hs.calm
      | go hu => exact hu hs.calm
  | endTurn =>
      have e := congrArg GameState.attacked heq
      simp [GameState.clamp, GameState.clampAt, GameState.afterAttack] at e
  | startTurn hbt => simp [red, st] at hbt
  | deckOut hbt => simp [red, st] at hbt

/-! ## `drain` breaks the cap -/

/-- Take a damage bonus of `2k + 1` or `2k + 2` for this turn. -/
def bonusItem (k : Nat) : Card :=
  .trainer "Bonus" .item (.choice (.linger .own .now (.bonus (2 * k + 1)))
    (.linger .own .now (.bonus (2 * k + 2))))

/-- The attacker: 2 HP counters, a free attack whose text puts `2k + 3` damage counters on
itself and then does 10 damage (base damage 1, plus the bonus), healing the attacker by the
damage done. The printed base damage field is 0, so the damage step is the `drain` in the text,
after the self-damage (`Attack.script`); its amount is 1, not 0, so the bonus applies to it under
the rulebook's stop at base damage 0 (`dealtBy`). -/
def drainer (k : Nat) : PokemonCard :=
  mon 2 0 (.seq (.selfDamage (2 * k + 3)) (.drain (.const 1)))

/-- The target: 1 HP counter. -/
def prey : PokemonCard := mon 1 0 .skip

theorem drainer_ok (k : Nat) :
    (InPlay.ofBasic (drainer k)).damage < (InPlay.ofBasic (drainer k)).top.hp := Nat.zero_lt_two

def dr₀ (k : Nat) : GameState :=
  st [bonusItem k] [] (InPlay.ofBasic (drainer k)) (InPlay.ofBasic prey) Store.empty Store.empty

def dr (k b : Nat) : GameState :=
  st [] [bonusItem k] (InPlay.ofBasic (drainer k)) (InPlay.ofBasic prey) (bonusNow b) Store.empty

theorem reach_dr (k : Nat) (i : Bool) :
    Reach (dr₀ k) (dr k (if i then 2 * k + 1 else 2 * k + 2)) := by
  cases i with
  | true =>
      exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) rfl rfl
        (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide))
        (.choiceL (.prim rfl rfl (.linger .own .now _ _)
          (.done (.inl (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide)))))) rfl rfl rfl rfl)
  | false =>
      exact .step (.refl _) rfl (.item (l₁ := []) (l₂ := []) rfl rfl
        (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide))
        (.choiceR (.prim rfl rfl (.linger .own .now _ _)
          (.done (.inl (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide)))))) rfl rfl rfl rfl)

theorem hpLe_dr₀ {k : Nat} (hk : 2 ≤ k) : (dr₀ k).HpLe k := by
  refine ⟨hpBound_le_of (fun c hc => ?_) (fun p hp => ?_), fun p hp => ?_⟩
  · simp [dr₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
      stadiumCardList, InPlay.cardList, InPlay.ofBasic] at hc
    rcases hc with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl
  · simp [dr₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
      stadiumCardList, InPlay.cardList, InPlay.ofBasic, bonusItem, drainer, prey, mon] at hp
    rcases hp with rfl | rfl <;> simp <;> omega
  · simp [dr₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
      stadiumCardList, InPlay.cardList, InPlay.ofBasic, bonusItem, drainer, prey, mon] at hp
    rcases hp with rfl | rfl <;> simp [PokemonCard.resistAmt] <;> omega

theorem tmax_dr₀ {k : Nat} (hk : 2 ≤ k) : ∀ x ∈ (dr₀ k).allCards, x.tmax < k := by
  intro x hx
  simp [dr₀, st, side, GameState.allCards, PlayerState.allCards, optCardList, benchCardList,
    stadiumCardList, InPlay.cardList, InPlay.ofBasic] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Card.tmax, attacksTmax, abilitiesTmax, Effect.tmax, bonusItem, drainer, prey, mon] <;> omega

/-- **`drain` breaks every cap on the damage bonus.** For every `k ≥ 2` there is a well-formed,
`Settled` start with no damage reduction anywhere, every HP (and Resistance) at most `k` and
every test constant below `k` (so `GameState.Fit k` holds except that one card's attack uses
`drain`), from which two states are reachable with the same `clamp k` (damage bonus `2k + 1` and
`2k + 2`, capped at `2k`), such that the attack from the first leaves the attacker with 1 damage
counter and no move from the second reaches a state with the same clamp (the attack leaves it
with none). The attack first puts `2k + 3` counters on the attacker, above every cap, and its
damage step `drain (const 1)` then removes exactly the damage done, `1 + 2k + 1` or `1 + 2k + 2`.
(An earlier witness used `drain 0`, which did damage through the bonus alone; the rulebook's stop
at base damage 0, now in `dealtBy`, rules that out. Milestone M4 moved the bonuses above the new
store cap `2k`.) -/
theorem drain_breaks_clamp (k : Nat) (hk : 2 ≤ k) :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ g₀.NoReduce ∧ g₀.HpLe k ∧
      (∀ x ∈ g₀.allCards, x.tmax < k) ∧
      ∃ g₁ g₂ g₁', Reach g₀ g₁ ∧ Reach g₀ g₂ ∧ g₁.clamp k = g₂.clamp k ∧ Move g₁ g₁' ∧
        ∀ g₂', Move g₂ g₂' → g₁'.clamp k ≠ g₂'.clamp k := by
  refine ⟨dr₀ k, wellFormed_st _ _ _ _ _ _ (.of_b rfl), settled_st _ _ _ _ _ _ (drainer_ok k) (by decide),
    ⟨Store.NoReduce.empty, Store.NoReduce.empty⟩, hpLe_dr₀ hk, tmax_dr₀ hk,
    dr k (2 * k + 1), dr k (2 * k + 2), _, reach_dr k true, reach_dr k false,
    clamp_st _ _ _ _ _ (bonusNow_cap k),
    .attack (hlk := rfl) (atk := ⟨"Hit", [], 0, .seq (.selfDamage (2 * k + 3)) (.drain (.const 1)), false, .none⟩)
      rfl (.head _) (.nil _) rfl rfl rfl rfl
      (settled_st _ _ _ _ _ _ (drainer_ok k) (by decide))
      (.seq (.selfDamage _ rfl) (.drain (.const 1 _) rfl rfl)) rfl
      (fun h => nomatch h) rfl (HitTrig.exists_nil (.seq (.selfDamage _ rfl) (.drain (.const 1 _) rfl rfl)) rfl) (.nil _),
    fun g₂' hm heq => ?_⟩
  cases hm with
  | playBasic hh => simp [dr, st, side] at hh
  | trigger _ hp => simp [dr, st] at hp
  | attach hh => simp [dr, st, side] at hh
  | evolve hh => simp [dr, st, side] at hh
  | attachBench hh => simp [dr, st, side] at hh
  | evolveBench hh => simp [dr, st, side] at hh
  | retreat ha hb => simp [dr, st, side] at hb
  | item hh => simp [dr, st, side] at hh
  | supporter hh => simp [dr, st, side] at hh
  | stadium hh => simp [dr, st, side] at hh
  | stadiumUse hs => simp [dr, st, side] at hs
  | tool hh => simp [dr, st, side] at hh
  | toolBench hh => simp [dr, st, side] at hh
  | ability hu hm =>
      cases hu with
      | active ha =>
          simp only [dr, st, side, Option.some.injEq] at ha
          subst ha
          simp [InPlay.abilities, InPlay.ofBasic, drainer, mon] at hm
      | bench hb => simp [dr, st, side] at hb
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      simp [dr, st, side] at hh
  | @attack g' a atk ha hm hc hs hn hf hbt hst hr hl _ _ _ _ hd ht =>
      simp only [dr, st, side, Option.some.injEq] at ha
      subst ha
      simp only [InPlay.attacks, InPlay.ofBasic, drainer, mon, List.flatMap_nil, List.append_nil,
        List.mem_singleton] at hm
      subst hm
      change Run (.seq (.selfDamage (2 * k + 3)) (.drain (.const 1))) _ _ at hr
      cases hr with
      | seq h3 h4 =>
          cases h3 with
          | selfDamage n hq =>
              simp only [dr, st, side, Option.some.injEq] at hq
              subst hq
              cases h4 with
              | drain hv hp hq =>
                  cases hv
                  simp only [dr, st, side, Option.some.injEq] at hp hq
                  subst hp hq
                  obtain rfl := hd.nil_of rfl
                  cases ht
                  have e := congrArg (fun g : GameState => g.cur.active) heq
                  simp [GameState.clamp, GameState.clampAt, InPlay.clampWith, Cap.dmg,
                    dr, st, side, GameState.dealt, dealtBy, GameState.weak, GameState.resist, GameState.sBonus,
                    GameState.sReduce, GameState.sPrevent, GameState.inForce, staticsInForce, PlayerState.field, fieldOf,
                    InPlay.sv, SView.statics, stadiumStatics, sumOf, List.flatMap_cons,
                    List.flatMap_nil, Whose.flip, GameState.stOwn, GameState.side,
                    PokemonCard.weakTo, PokemonCard.resistTo, Store.live, Mods.merge,
                    Store.add, Mods.addMod, Store.empty, Mods.empty, bonusNow,
                    InPlay.ofBasic, drainer, prey, mon, InPlay.noteLock, GameState.afterAttack] at e <;> omega
              | touchActive he => simp [Effect.touch] at he
              | touchBench he => simp [Effect.touch] at he
              | zone hw => simp [Effect.zSide] at hw
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | attackConfused ha hm hc hs =>
      simp only [dr, st, side, Option.some.injEq] at ha
      subst ha
      simp [InPlay.ofBasic] at hs
  | knockOuts h =>
      have hs : Settled (dr k (2 * k + 2)) := settled_st _ _ _ _ _ _ (drainer_ok k) (by decide)
      cases h with
      | won hu => exact hu hs.calm
      | go hu => exact hu hs.calm
  | endTurn =>
      have e := congrArg GameState.attacked heq
      simp [GameState.clamp, GameState.clampAt, GameState.afterAttack] at e
  | startTurn hbt => simp [dr, st] at hbt
  | deckOut hbt => simp [dr, st] at hbt

end Lingering

end Pokemon
