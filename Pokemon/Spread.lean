import Pokemon.Bench

/-!
# Spread damage and counters (milestone MV2, stage 2)

Survey S13 §B. Three shapes of today's Standard place damage or counters on several of the
opponent's Pokémon chosen by the attacker:

* "Put 6 damage counters on your opponent's Benched Pokémon in any way you like" (Dragapult ex
  sv6-130; with "your opponent's Pokémon", Sinistcha sv6-22): `Effect.spreadAny`, one counter at
  a time on a chosen Pokémon, `N` times (`Effect.rep`); on "your opponent's Pokémon" each counter
  goes on the Active Pokémon when the Bench is empty (`Effect.spreadOne`). Proved: from a state
  where the opponent has an Active Pokémon (and, for completeness, the attacker is Active), every
  distribution of the `N` counters over the opponent's Pokémon (resp. Benched Pokémon) is a
  resolution, and every resolution is one and changes nothing else (`Spread.spreadAny_sound`,
  `Spread.spreadAny_complete`, `Spread.spreadAny_oppDamage`, `Spread.spreadAny_emptyBench`,
  `Spread.spreadBench_*`). Inside an attack no Knock Out is taken between the counters, as printed;
  inside an Item or Supporter (`TRun`) each counter would be followed by the Knock Out check, so
  the form is exact for attacks, which every card of the shape is. (Before this definition, with an
  empty Bench a counter could be lost: a `choice` of the Active Pokémon and an empty Bench.)
* "This attack does 120 damage to 2 of your opponent's Pokémon" (Greninja ex sv6-106) and "… to 2
  of your opponent's Benched Pokémon" (Hydreigon ex sv8-119): `Effect.hitSome` and the primitive
  `Effect.benchSome` (`M` distinct Benched Pokémon, `Hits`). Damage to the Active Pokémon is the
  attack's damage step (Weakness, Resistance and every modifier apply); damage to Benched Pokémon
  takes no Weakness or Resistance (rulebook 2023 p. 14) and, in the model, no other modifier
  either (the existing departure of `benchDamage`, Known gaps). A Tera Pokémon on the Bench takes
  none.
* "Choose 2 of your opponent's Pokémon and put 3 damage counters on each of them" (Mimikyu ex
  sv9-69): `Effect.countersSome`.

`benchSome` places damage on several Benched Pokémon in one step. Both clamps are simulations for
it (`Hits.transfer`: the chosen Pokémon are chosen by their top card, which the clamps keep, and
the clamps commute with adding damage up to agreement), and its Knock Outs are taken by the one
batch step that follows (after the attack, or after the step inside a Trainer effect):
`twoBenchKOs_reachable` Knocks Out two Benched Pokémon in one batch, leaving the third.
-/

namespace Pokemon

/-- `n` copies of `e` in sequence (`skip` for 0). -/
def Effect.rep (e : Effect) : Nat → Effect
  | 0 => .skip
  | n + 1 => .seq e (e.rep n)

/-- One counter of "put `n` damage counters on your opponent's Pokémon in any way you like": on the
opponent's Active Pokémon or on a chosen one of their Benched Pokémon, and on the Active Pokémon when
the Bench is empty (the test reads the count, which needs the attacker's Active Pokémon, present in
every attack). -/
def Effect.spreadOne : Effect :=
  .ite (.countGe (.bench .opp .any) 1) (.choice (.counters 1) (.benchCounters .opp 1)) (.counters 1)

/-- "Put `n` damage counters on your opponent's Pokémon in any way you like" (`bench = false`) or
"… on your opponent's Benched Pokémon …" (`bench = true`). Exact in an attack: every distribution of
the `n` counters is a resolution and nothing else is (`Spread.spreadAny_sound`,
`Spread.spreadAny_complete`; on the Bench, `Spread.spreadBench_sound`, `Spread.spreadBench_complete`,
`Spread.spreadBench_empty`). -/
def Effect.spreadAny (bench : Bool) (n : Nat) : Effect :=
  if bench then (Effect.benchCounters .opp 1).rep n
  else Effect.spreadOne.rep n

/-- "This attack does `n` damage to `m` of your opponent's Pokémon" (`m ≥ 1`): the Active Pokémon
by the damage step and `m - 1` Benched Pokémon, or `m` Benched Pokémon when the Bench has that
many; the Active Pokémon must be chosen when the Bench has fewer than `m`. -/
def Effect.hitSome (m n : Nat) : Effect :=
  .ite (.countGe (.bench .opp .any) m)
    (.choice (.seq (.damage (.const n)) (.benchSome .opp (m - 1) .any true n))
      (.benchSome .opp m .any true n))
    (.seq (.damage (.const n)) (.benchSome .opp (m - 1) .any true n))

/-- "Choose `m` of your opponent's Pokémon and put `n` damage counters on each of them." -/
def Effect.countersSome (m n : Nat) : Effect :=
  .ite (.countGe (.bench .opp .any) m)
    (.choice (.seq (.counters n) (.benchSome .opp (m - 1) .any false n))
      (.benchSome .opp m .any false n))
    (.seq (.counters n) (.benchSome .opp (m - 1) .any false n))

/-- The spread forms are well formed in an attack: one damage step on each line. -/
theorem Effect.hitSome_wf (m n : Nat) :
    (⟨"Spread", [], 0, Effect.hitSome m n, false, .none⟩ : Attack).wf = true := rfl

/-- `rep` of a hit-free effect is hit-free, so the counters forms are usable anywhere. -/
theorem Effect.rep_hitFree {e : Effect} (h : e.hitFree = true) : ∀ n, (e.rep n).hitFree = true
  | 0 => rfl
  | n + 1 => by simp only [Effect.rep, Effect.hitFree, h, Effect.rep_hitFree h n, Bool.and_self]

/-- The spread forms of counters are hit-free, usable in any effect. -/
theorem Effect.spreadAny_hitFree (bench : Bool) (n : Nat) :
    (Effect.spreadAny bench n).hitFree = true := by
  cases bench <;> exact Effect.rep_hitFree rfl n

/-- `Hits` keeps the length of the Bench. -/
theorem Hits.length_eq {U : InPlay → InPlay} {f : Filter} {k : Nat} {b b' : List InPlay}
    (h : Hits U f k b b') : b'.length = b.length :=
  h.congr List.length fun _ _ _ _ _ he => by simp only [List.length_cons, he]

/-- `Hits` changes exactly `k` Pokémon: at most the Bench's size, each chosen once. -/
theorem Hits.le_length {U : InPlay → InPlay} {f : Filter} {k : Nat} {b b' : List InPlay}
    (h : Hits U f k b b') : k ≤ b.length := by
  induction h with
  | nil => exact Nat.le_refl _
  | hit _ _ ih => simp only [List.length_cons]; exact Nat.succ_le_succ ih
  | keep _ ih => simp only [List.length_cons]; exact Nat.le_succ_of_le ih

/-! ## Exactness of `spreadAny`

`BenchAdd k b b'`: the Bench `b'` is `b` with `k` damage counters in all added, any number on each
Pokémon, and nothing else changed. Every distribution is one (`BenchAdd.ofCounts`). -/

/-- `b'` is the Bench `b` with `k` damage counters added in all, `j` on each Pokémon for some `j`. -/
inductive BenchAdd : Nat → List InPlay → List InPlay → Prop where
  | nil : BenchAdd 0 [] []
  | cons {k : Nat} {x : InPlay} {b b' : List InPlay} (j : Nat) :
      BenchAdd k b b' → BenchAdd (j + k) (x :: b) (x.addDamage j :: b')

theorem InPlay.addDamage_add (p : InPlay) (x y : Nat) :
    (p.addDamage x).addDamage y = p.addDamage (x + y) := by
  simp only [InPlay.addDamage, Nat.add_assoc]

theorem InPlay.addDamage_zero (p : InPlay) : p.addDamage 0 = p := rfl

namespace BenchAdd

/-- Adding no counter. -/
theorem zero : ∀ b : List InPlay, BenchAdd 0 b b
  | [] => .nil
  | x :: b => .cons (x := x) 0 (zero b)

/-- **Every distribution**: `ds[i]` counters on the `i`-th Pokémon of the Bench. -/
theorem ofCounts : ∀ (ds : List Nat) (b : List InPlay), ds.length = b.length →
    BenchAdd ds.sum b (List.zipWith (fun j x => InPlay.addDamage j x) ds b)
  | [], [], _ => .nil
  | [], _ :: _, h => Nat.noConfusion h
  | _ :: _, [], h => Nat.noConfusion h
  | j :: ds, x :: b, h => by
      simp only [List.sum_cons, List.zipWith_cons_cons]
      exact .cons j (ofCounts ds b (Nat.succ.inj h))

/-- The Bench keeps its length. -/
theorem length_eq {k : Nat} {b b' : List InPlay} (h : BenchAdd k b b') : b'.length = b.length := by
  induction h with
  | nil => rfl
  | cons _ _ ih => simp only [List.length_cons, ih]

/-- The damage on the Bench rises by exactly `k`. -/
theorem sum_damage {k : Nat} {b b' : List InPlay} (h : BenchAdd k b b') :
    (b'.map InPlay.damage).sum = (b.map InPlay.damage).sum + k := by
  induction h with
  | nil => rfl
  | @cons k x _ _ j _ ih =>
      simp only [List.map_cons, List.sum_cons, InPlay.addDamage, ih]
      omega

theorem nil_inv {k : Nat} {b' : List InPlay} (h : BenchAdd k [] b') : k = 0 ∧ b' = [] := by
  cases h; exact ⟨rfl, rfl⟩

/-- One more counter on one Pokémon, then `k` more anywhere, is `k + 1` anywhere. -/
theorem of_bump {q : InPlay} {b₂ : List InPlay} :
    ∀ {b₁ : List InPlay} {k : Nat} {b' : List InPlay},
      BenchAdd k (b₁ ++ q.addDamage 1 :: b₂) b' → BenchAdd (k + 1) (b₁ ++ q :: b₂) b'
  | [], k, b', h => by
      simp only [List.nil_append] at h ⊢
      cases h with
      | @cons k' _ _ b'' j h =>
          rw [InPlay.addDamage_add, show j + k' + 1 = (1 + j) + k' by omega]
          exact .cons _ h
  | x :: b₁, k, b', h => by
      simp only [List.cons_append] at h ⊢
      cases h with
      | @cons k' _ _ b'' j h =>
          rw [show j + k' + 1 = j + (k' + 1) by omega]
          exact .cons j (of_bump h)

end BenchAdd

/-- `g` with the opponent's Active Pokémon `a` and Bench `b`; everything else is `g`'s. -/
def GameState.withOpp (g : GameState) (a : InPlay) (b : List InPlay) : GameState :=
  { g with opp := { g.opp with active := some a, bench := b } }

theorem GameState.withOpp_self {g : GameState} {p : InPlay} (h : g.opp.active = some p) :
    g.withOpp p g.opp.bench = g := by
  unfold GameState.withOpp; rw [← h]

/-- The total damage on the opponent's Pokémon in play. -/
def GameState.oppDamage (g : GameState) : Nat :=
  (g.opp.active.map InPlay.damage).getD 0 + (g.opp.bench.map InPlay.damage).sum

/-- Resolving `e` `m` times, then `k` times, is resolving it `m + k` times. -/
theorem Run.rep_append {e : Effect} {k : Nat} :
    ∀ {m : Nat} {g₁ g₂ g₃ : GameState}, Run (e.rep m) g₁ g₂ → Run (e.rep k) g₂ g₃ →
      Run (e.rep (m + k)) g₁ g₃
  | 0, _, _, _, h₁, h₂ => by
      change Run .skip _ _ at h₁
      rw [Nat.zero_add]
      cases h₁ with
      | skip => exact h₂
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | m + 1, _, _, _, h₁, h₂ => by
      change Run (.seq e (e.rep m)) _ _ at h₁
      rw [Nat.succ_add]
      cases h₁ with
      | seq ha hb => exact .seq ha (Run.rep_append hb h₂)
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw

section SpreadExact

variable {g : GameState}

/-- An effect that can put one counter on the opponent's Active Pokémon, resolved `d` times, can
put `d` there. -/
theorem Run.rep_active {e : Effect} {b : List InPlay}
    (he : ∀ a, Run e (g.withOpp a b) (g.withOpp (a.addDamage 1) b)) :
    ∀ (d : Nat) (a : InPlay), Run (e.rep d) (g.withOpp a b) (g.withOpp (a.addDamage d) b)
  | 0, a => .skip _
  | d + 1, a => by
      have h := Run.rep_active he d (a.addDamage 1)
      rw [InPlay.addDamage_add, Nat.add_comm 1 d] at h
      exact .seq (he a) h

/-- An effect that can put one counter on any one of the opponent's Benched Pokémon, resolved
`k` times, can make any `BenchAdd k`. -/
theorem Run.rep_bench {e : Effect} {a : InPlay}
    (he : ∀ b₁ q b₂, Run e (g.withOpp a (b₁ ++ q :: b₂)) (g.withOpp a (b₁ ++ q.addDamage 1 :: b₂))) :
    ∀ {k : Nat} {b b' : List InPlay}, BenchAdd k b b' →
      ∀ b₁, Run (e.rep k) (g.withOpp a (b₁ ++ b)) (g.withOpp a (b₁ ++ b')) := by
  have one : ∀ (j : Nat) (b₁ b₂ : List InPlay) (q : InPlay),
      Run (e.rep j) (g.withOpp a (b₁ ++ q :: b₂)) (g.withOpp a (b₁ ++ q.addDamage j :: b₂)) := by
    intro j
    induction j with
    | zero => intro b₁ b₂ q; exact .skip _
    | succ j ih =>
        intro b₁ b₂ q
        have h := ih b₁ b₂ (q.addDamage 1)
        rw [InPlay.addDamage_add, Nat.add_comm 1 j] at h
        exact .seq (he b₁ q b₂) h
  intro k b b' h
  induction h with
  | nil => intro b₁; exact .skip _
  | @cons k x b b' j _ ih =>
      intro b₁
      have h₂ := ih (b₁ ++ [x.addDamage j])
      simp only [List.append_assoc, List.singleton_append] at h₂
      exact Run.rep_append (one j b₁ b x) h₂

/-- The count test of `spreadOne` holds on a nonempty Bench. -/
theorem Effect.spreadOne_test_true {c : InPlay} {a x : InPlay} {b : List InPlay} :
    (Test.countGe (.bench .opp .any) 1).eval (g.withOpp a (x :: b)) c = true := by
  simp [Test.eval, Count.val, GameState.side, GameState.withOpp, Filter.eval]

/-- and fails on an empty one. -/
theorem Effect.spreadOne_test_false {c : InPlay} {a : InPlay} :
    (Test.countGe (.bench .opp .any) 1).eval (g.withOpp a []) c = false := rfl

/-- One counter on the opponent's Active Pokémon. -/
theorem Effect.spreadOne_active {c : InPlay} (hc : g.cur.active = some c) (a : InPlay) :
    ∀ b, Run Effect.spreadOne (g.withOpp a b) (g.withOpp (a.addDamage 1) b)
  | [] => .iteF (p := c) hc spreadOne_test_false (.counters (p := a) 1 rfl)
  | _ :: _ => .iteT (p := c) hc spreadOne_test_true (.choiceL (.counters (p := a) 1 rfl))

/-- One counter on any one of the opponent's Benched Pokémon. -/
theorem Effect.spreadOne_bench {c : InPlay} (hc : g.cur.active = some c) (a : InPlay)
    (b₁ : List InPlay) (q : InPlay) (b₂ : List InPlay) :
    Run Effect.spreadOne (g.withOpp a (b₁ ++ q :: b₂)) (g.withOpp a (b₁ ++ q.addDamage 1 :: b₂)) := by
  have ht : (Test.countGe (.bench .opp .any) 1).eval (g.withOpp a (b₁ ++ q :: b₂)) c = true := by
    cases b₁ with
    | nil => exact spreadOne_test_true
    | cons y b₁ => exact spreadOne_test_true
  exact .iteT (p := c) hc ht (.choiceR (.benchCounters (q := q) (b₁ := b₁) (b₂ := b₂) .opp 1 rfl))

/-- What one resolution of `spreadOne` does: one counter on the Active Pokémon, or on one Benched
Pokémon; nothing else. -/
theorem Effect.spreadOne_inv {a : InPlay} {b : List InPlay} {g' : GameState}
    (h : Run Effect.spreadOne (g.withOpp a b) g') :
    g' = g.withOpp (a.addDamage 1) b ∨
      ∃ b₁ q b₂, b = b₁ ++ q :: b₂ ∧ g' = g.withOpp a (b₁ ++ q.addDamage 1 :: b₂) := by
  unfold Effect.spreadOne at h
  cases h with
  | iteT _ ht h =>
      cases h with
      | choiceL h =>
          cases h with
          | counters _ hp =>
              cases hp; exact .inl rfl
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | choiceR h =>
          cases h with
          | benchCounters _ _ hb => exact .inr ⟨_, _, _, hb, rfl⟩
          | benchCountersNone _ _ hb =>
              change b = [] at hb
              subst hb
              exact absurd ht (by rw [spreadOne_test_false]; decide)
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | iteF _ _ h =>
      cases h with
      | counters _ hp => cases hp; exact .inl rfl
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he
  | zone hw => simp [Effect.zSide] at hw

/-- Every resolution of `spreadOne` `n` times adds `d` counters to the Active Pokémon and `k` to the
Bench, `d + k = n`, and changes nothing else. -/
theorem Effect.spreadOne_rep_sound :
    ∀ {n : Nat} {a : InPlay} {b : List InPlay} {g' : GameState},
      Run (Effect.spreadOne.rep n) (g.withOpp a b) g' →
      ∃ d k b', d + k = n ∧ BenchAdd k b b' ∧ g' = g.withOpp (a.addDamage d) b'
  | 0, a, b, _, h => by
      change Run .skip _ _ at h
      cases h with
      | skip => exact ⟨0, 0, b, rfl, BenchAdd.zero b, rfl⟩
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | n + 1, a, b, _, h => by
      change Run (.seq Effect.spreadOne (Effect.spreadOne.rep n)) _ _ at h
      cases h with
      | seq h₁ h₂ =>
          rcases Effect.spreadOne_inv h₁ with rfl | ⟨b₁, q, b₂, rfl, rfl⟩
          · obtain ⟨d, k, b', hn, hb, rfl⟩ := Effect.spreadOne_rep_sound h₂
            refine ⟨1 + d, k, b', ?_, hb, by rw [InPlay.addDamage_add]⟩
            omega
          · obtain ⟨d, k, b', hn, hb, rfl⟩ := Effect.spreadOne_rep_sound h₂
            refine ⟨d, k + 1, b', ?_, BenchAdd.of_bump hb, rfl⟩
            omega
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw

/-- `n` counters on the Bench, one at a time: each lands on a Benched Pokémon when there is one. -/
theorem Effect.benchOne_rep_sound :
    ∀ {n : Nat} {a : InPlay} {b : List InPlay} {g' : GameState}, b ≠ [] →
      Run ((Effect.benchCounters .opp 1).rep n) (g.withOpp a b) g' →
      ∃ b', BenchAdd n b b' ∧ g' = g.withOpp a b'
  | 0, a, b, _, _, h => by
      change Run .skip _ _ at h
      cases h with
      | skip => exact ⟨b, BenchAdd.zero b, rfl⟩
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | n + 1, a, b, _, hne, h => by
      change Run (.seq (.benchCounters .opp 1) ((Effect.benchCounters .opp 1).rep n)) _ _ at h
      cases h with
      | seq h₁ h₂ =>
          cases h₁ with
          | @benchCounters _ q b₁ b₂ _ _ hb =>
              change b = b₁ ++ q :: b₂ at hb
              subst hb
              obtain ⟨b', hb', rfl⟩ := Effect.benchOne_rep_sound (by simp) h₂
              exact ⟨b', BenchAdd.of_bump hb', rfl⟩
          | benchCountersNone _ _ hb => exact absurd hb hne
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw

/-- With an empty Bench, counters on the Bench do nothing. -/
theorem Effect.benchOne_rep_empty :
    ∀ {n : Nat} {a : InPlay} {g' : GameState},
      Run ((Effect.benchCounters .opp 1).rep n) (g.withOpp a []) g' → g' = g.withOpp a []
  | 0, a, _, h => by
      change Run .skip _ _ at h
      cases h with
      | skip => rfl
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw
  | n + 1, a, _, h => by
      change Run (.seq (.benchCounters .opp 1) ((Effect.benchCounters .opp 1).rep n)) _ _ at h
      cases h with
      | seq h₁ h₂ =>
          cases h₁ with
          | benchCounters _ _ hb => simp [GameState.side, GameState.withOpp] at hb
          | benchCountersNone _ _ _ => exact Effect.benchOne_rep_empty h₂
          | touchActive he => simp [Effect.touch] at he
          | touchBench he => simp [Effect.touch] at he
          | zone hw => simp [Effect.zSide] at hw
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw

end SpreadExact

namespace Spread

open Trainer Bench

/-- "Put 5 damage counters on each of 2 of your opponent's Benched Pokémon." -/
def spread2 : Card := .trainer "Spread2" .item (.benchSome .opp 2 .any false 5)

/-- The opponent has `big` Active and on the Bench two 50-HP Pokémon around a 100-HP one; the
player to move has three Prize cards and `spread2` in hand. -/
def start : GameState :=
  ⟨side [spread2] [.energy .fire, .energy .fire, .energy .fire] (InPlay.ofBasic big) [],
    side [] [.energy .fire] (InPlay.ofBasic big)
      [InPlay.ofBasic low, InPlay.ofBasic big, InPlay.ofBasic low],
    true, false, false, false, none, none, false, false, false⟩

theorem start_wellFormed : WellFormed start := by
  refine ⟨fun _ => ⟨by simp [start, Trainer.side], by simp [start, Trainer.side]⟩,
    (fun p hp => by cases hp), fun p hp => ?_⟩
  simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem start_settled : Settled start :=
  settled_of rfl rfl (by decide) (by decide) (fun p hp => by cases hp)
    (fun p hp => by
      simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl | rfl <;> decide)

/-- The two 50-HP Pokémon are chosen. -/
theorem hits_two : Hits (InPlay.hitWith false 5) .any
    (min 2 (benchElig .any (start.side .opp).bench)) (start.side .opp).bench
    [(InPlay.ofBasic low).hitWith false 5, InPlay.ofBasic big,
      (InPlay.ofBasic low).hitWith false 5] :=
  .hit rfl (.keep (.hit rfl .nil))

/-- **Witness: one spread Knocks Out two Benched Pokémon in one batch.** From a well-formed,
`Settled` start, `spread2` puts 5 damage counters on each of two of the opponent's Benched
Pokémon, both 50-HP; the one batch Knock Out step after that step takes both (the player takes
two Prize cards), and the opponent's 100-HP Benched Pokémon and Active Pokémon stay. -/
theorem twoBenchKOs_reachable :
    ∃ g₀, WellFormed g₀ ∧ Settled g₀ ∧ ∃ g, Move g₀ g ∧ Reach g₀ g ∧
      g.opp.bench = [InPlay.ofBasic big] ∧ g.opp.active = g₀.opp.active ∧
      g.cur.prizes.length + 2 = g₀.cur.prizes.length ∧ g.winner = none := by
  have hm : Move start _ :=
    .item (l₁ := []) (l₂ := []) (n := "Spread2") rfl rfl start_settled
      (.prim rfl rfl (.benchSome .opp 2 .any false 5 hits_two)
        (.step rfl (.go (by decide) rfl .keep .keep)
          (.done (.inl ((GameState.settled_iff _).2 (by decide)))))) rfl rfl rfl rfl
  exact ⟨start, start_wellFormed, start_settled, _, hm, .step (.refl _) rfl hm, rfl, rfl, rfl, rfl⟩

/-- With a Bench of one, "2 of your opponent's Benched Pokémon" hits that one: the count is
`min 2 1`. -/
theorem hits_all_if_fewer :
    Hits (InPlay.hitWith true 3) .any (min 2 (benchElig .any [InPlay.ofBasic big]))
      [InPlay.ofBasic big] [(InPlay.ofBasic big).hitWith true 3] :=
  .hit rfl .nil

/-! ### `spreadAny` is exact

From a state where the opponent has an Active Pokémon `p`, the resolutions of
`spreadAny false n` are exactly the states with `d` more counters on `p` and `k` more on the Bench
in any distribution (`BenchAdd`), `d + k = n`, and nothing else changed (`spreadAny_sound`,
`spreadAny_complete`); with an empty Bench all `n` land on `p` (`spreadAny_emptyBench`). The same
for `spreadAny true n` on the Bench (`spreadBench_*`). `Run` takes no Knock Out between the counters;
this is the attack's effect, followed by one Knock Out check. -/

/-- **Soundness of "put `n` damage counters on your opponent's Pokémon in any way you like".** Every
resolution places `d` counters on the opponent's Active Pokémon and `k` on their Bench, `d + k = n`,
and changes nothing else. -/
theorem spreadAny_sound {g g' : GameState} {p : InPlay} {n : Nat} (hp : g.opp.active = some p)
    (h : Run (Effect.spreadAny false n) g g') :
    ∃ d k b', d + k = n ∧ BenchAdd k g.opp.bench b' ∧ g' = g.withOpp (p.addDamage d) b' := by
  change Run (Effect.spreadOne.rep n) _ _ at h
  rw [← GameState.withOpp_self hp] at h
  exact Effect.spreadOne_rep_sound h

/-- The total damage on the opponent's Pokémon in play rises by exactly `n`. -/
theorem spreadAny_oppDamage {g g' : GameState} {p : InPlay} {n : Nat}
    (hp : g.opp.active = some p) (h : Run (Effect.spreadAny false n) g g') :
    g'.oppDamage = g.oppDamage + n := by
  obtain ⟨d, k, b', hn, hb, rfl⟩ := spreadAny_sound hp h
  simp only [GameState.oppDamage, GameState.withOpp, hp, Option.map_some, Option.getD_some,
    InPlay.addDamage, hb.sum_damage]
  omega

/-- **With an empty Bench every counter goes on the Active Pokémon**, as printed. -/
theorem spreadAny_emptyBench {g g' : GameState} {p : InPlay} {n : Nat}
    (hp : g.opp.active = some p) (hb : g.opp.bench = [])
    (h : Run (Effect.spreadAny false n) g g') : g' = g.withOpp (p.addDamage n) [] := by
  obtain ⟨d, k, b', hn, hb', rfl⟩ := spreadAny_sound hp h
  rw [hb] at hb'
  obtain ⟨rfl, rfl⟩ := hb'.nil_inv
  rw [Nat.add_zero] at hn
  rw [hn]

/-- **Completeness: every distribution is a resolution.** In an attack (the attacker `c` is
Active), any `d` counters on the opponent's Active Pokémon and any `BenchAdd k` on their Bench
(`BenchAdd.ofCounts`: any count on each Benched Pokémon), `d + k = n`. -/
theorem spreadAny_complete {g : GameState} {p c : InPlay} {n d k : Nat} {b' : List InPlay}
    (hc : g.cur.active = some c) (hp : g.opp.active = some p) (hn : d + k = n)
    (hb : BenchAdd k g.opp.bench b') :
    Run (Effect.spreadAny false n) g (g.withOpp (p.addDamage d) b') := by
  change Run (Effect.spreadOne.rep n) _ _
  subst hn
  have h₁ := Run.rep_active (g := g) (b := g.opp.bench)
    (fun a => Effect.spreadOne_active hc a _) d p
  have h₂ := Run.rep_bench (g := g) (a := p.addDamage d) (Effect.spreadOne_bench hc _) hb []
  simp only [List.nil_append] at h₂
  have h₃ := Run.rep_append h₁ h₂
  rwa [GameState.withOpp_self hp] at h₃

/-- On the Bench (`spreadAny true n`), with a Benched Pokémon: every resolution is a `BenchAdd n`. -/
theorem spreadBench_sound {g g' : GameState} {p : InPlay} {n : Nat} (hp : g.opp.active = some p)
    (hne : g.opp.bench ≠ []) (h : Run (Effect.spreadAny true n) g g') :
    ∃ b', BenchAdd n g.opp.bench b' ∧ g' = g.withOpp p b' := by
  change Run ((Effect.benchCounters .opp 1).rep n) _ _ at h
  rw [← GameState.withOpp_self hp] at h
  exact Effect.benchOne_rep_sound hne h

/-- On the Bench with an empty Bench: nothing happens. -/
theorem spreadBench_empty {g g' : GameState} {p : InPlay} {n : Nat} (hp : g.opp.active = some p)
    (hb : g.opp.bench = []) (h : Run (Effect.spreadAny true n) g g') : g' = g := by
  change Run ((Effect.benchCounters .opp 1).rep n) _ _ at h
  have e := GameState.withOpp_self hp
  rw [hb] at e
  rw [← e] at h ⊢
  exact Effect.benchOne_rep_empty h

/-- On the Bench, every distribution is a resolution. -/
theorem spreadBench_complete {g : GameState} {p : InPlay} {n : Nat} {b' : List InPlay}
    (hp : g.opp.active = some p) (hb : BenchAdd n g.opp.bench b') :
    Run (Effect.spreadAny true n) g (g.withOpp p b') := by
  change Run ((Effect.benchCounters .opp 1).rep n) _ _
  have h := Run.rep_bench (g := g) (a := p)
    (fun b₁ q b₂ => .benchCounters (q := q) (b₁ := b₁) (b₂ := b₂) .opp 1 rfl) hb []
  simp only [List.nil_append] at h
  rwa [GameState.withOpp_self hp] at h

end Spread

end Pokemon
