import Pokemon.Heals

/-!
# Computed amounts on chosen or filtered Pokémon, and moves of all damage counters (milestone MV12,
survey S26)

`Effect.hitBy w sp m f hurt dmg a`: at `sp = .active` damage counters on the `w` player's Active
Pokémon if it is a target (`InPlay.hitOk f hurt`: its card passes `f` and, with `hurt`, it has a
damage counter), nothing otherwise; at `sp = .bench`, on `m` distinct Benched targets (all if fewer),
attack damage (`dmg`, none on a Tera Pokémon) or damage counters. The amount (`HAmt`) is computed for
each target from the state the effect starts in and from the target: a constant, `k` per unit of a
count, `k` per damage counter on the target, or as many as bring its remaining HP down to `n`.
Semantics `Run.hitByActive`, `Run.hitByActiveSkip`, `Run.hitByBench` (the last through `HitsP`, the
relation of `Hits` with a test on the whole Pokémon).

`Effect.dumpCounters f sp`: all damage counters of one of the player's Benched Pokémon passing `f` moved
to the opponent's Pokémon at `sp` (`Run.dumpActive`, `Run.dumpBench`, `Run.dumpNone`).

**The clamps** (what survey S26 asked of each read). Each amount adds to the target's damage a quantity
that depends on the old damage only through the target (`HAmt.amt`), so it only raises the damage, and
any cap commutes with it (`Cap.dmg_inflate`: below the cap the damages are equal, at or above it both
results are). The amount reads the counts, which both clamps keep (`Count.val_clampAt`,
`Count.val_xclampAt`), and the derived HP, a function of the Pokémon's view, which both keep
(`GameState.SameField.hpOf`). "Has a damage counter" is kept by the capped clamp because its bound is
positive (`Cap.keepsPos`, `InPlay.Agree.hitOk`; `Run.cap_sim` assumes `0 < k`). `dumpCounters` reads only
the player's own Benched damage, exact under both clamps inside an effect, and adds it to the opponent.
So `Run.cap_sim` and `Run.xcap_sim` gained these cases with no change of statement. Not covered, and not
in the language: an effect that lowers or moves the opponent's damage (S25, S26).

**What it keeps.** No zone, store or flag; the cards of every Pokémon (`Run.perm`); conditions and
markers; the potential `abPot`. No new state, so the enumerations are unchanged.

**Witnesses** (Item cards with the counters forms, legal moves from a well-formed, `Settled` start; the
damage form, `dmg = true`, is for attacks only, `Effect.benchHitFree`):
* `to_hp` (positive): "until its remaining HP is 5": the opponent's Active Pokémon (HP 10, 3 counters)
  ends with 5; `toHp_noop` (general negative, every resolution in every state): a Pokémon already at or
  below the remaining HP keeps its damage;
* `double` (positive): `per 1` doubles the opponent's Active Pokémon's 3 counters to 6;
* `hurt_only` (positive and negative on one move): "2 damage counters on each of your opponent's Benched
  Pokémon that has any damage counters on it": the damaged one gets 2, the undamaged one none;
  `hitBy_bench_targets` (general): in every resolution every changed Benched Pokémon had a damage
  counter;
* `dump` (positive): the player's Benched Pokémon with 4 counters is left with none and the opponent's
  Active Pokémon has 4 more; `dump_none` (general negative): with no Benched Pokémon passing the filter
  every resolution leaves the state unchanged.
-/

namespace Pokemon.Computed

open Trainer

def hurt4 : InPlay := { InPlay.ofBasic { big with name := "Hurt4" } with damage := 4 }
def clean : InPlay := InPlay.ofBasic { big with name := "Clean" }
def opp3 : InPlay := { InPlay.ofBasic big with damage := 3 }
def oppHurt : InPlay := { InPlay.ofBasic { big with name := "OppHurt" } with damage := 2 }

/-- The player to move has `big` Active and `hurt4` (4 counters) and `clean` on the Bench, and `c` in
hand; the opponent has `opp3` (3 counters) Active and `oppHurt` (2 counters) and `clean` on the Bench.
Every Pokémon has HP 10 (counters). -/
def start (c : Card) : GameState :=
  ⟨side [c] [.energy .fire] (InPlay.ofBasic big) [hurt4, clean],
    side [] [.energy .fire] opp3 [oppHurt, clean],
    true, false, false, false, none, none, false, false, false⟩

theorem start_wellFormed (c : Card) : WellFormed (start c) := by
  refine ⟨fun _ => ⟨by simp [start, Trainer.side], by simp [start, Trainer.side]⟩,
    fun p hp => ?_, fun p hp => ?_, .of_b rfl⟩
  · simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩
  · simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem start_settled (c : Card) : Settled (start c) :=
  settled_of rfl rfl (by decide) (by decide)
    (fun p hp => by
      simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide)
    (fun p hp => by
      simp only [start, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide)

/-- "Put damage counters on your opponent's Active Pokémon until its remaining HP is 50." -/
def toHp5 : Card := .trainer "ToHp5" .item (.hitBy .opp .active 1 .any false false (.toHp 5))

/-- "Double the number of damage counters on your opponent's Active Pokémon." -/
def double : Card := .trainer "Double" .item (.hitBy .opp .active 1 .any false false (.per 1))

/-- "Put 2 damage counters on each of your opponent's Benched Pokémon that has any damage counters on
it." -/
def hurtSpread : Card := .trainer "HurtSpread" .item (.hitBy .opp .bench 5 .any true false (.const 2))

/-- "Move all damage counters from 1 of your Benched Pokémon to your opponent's Active Pokémon." -/
def dumpCard : Card := .trainer "Dump" .item (.dumpCounters .any .active)

/-- **Witness: until its remaining HP is 5.** Playing `toHp5` is a legal move after which the opponent's
Active Pokémon (HP 10) has 5 damage counters (it had 3). -/
theorem to_hp :
    WellFormed (start toHp5) ∧ Settled (start toHp5) ∧ ∃ g, Move (start toHp5) g ∧
      g.opp.active.map InPlay.damage = some 5 := by
  have hm : Move (start toHp5) _ :=
    .item (l₁ := []) (l₂ := []) (n := "ToHp5") rfl rfl (start_settled _)
      (.prim rfl rfl (.hitByActive .opp 1 .any false false (.toHp 5) rfl rfl)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide) (by decide) (by decide)))))
      rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl⟩

/-- **General negative: "until its remaining HP is `n`" adds nothing to a Pokémon whose remaining HP is
already at most `n`**, for every resolution in every state. -/
theorem toHp_noop {w : Whose} {m n : Nat} {f : Filter} {hurt dmg : Bool} {g g' : GameState}
    {p : InPlay} (hp : (g.side w).active = some p) (hle : g.hpOf w .active p - n ≤ p.damage)
    (h : Run (.hitBy w .active m f hurt dmg (.toHp n)) g g') :
    (g'.side w).active.map InPlay.damage = some p.damage := by
  cases h with
  | hitByActive _ _ _ _ _ _ h' _ =>
      rw [hp] at h'; cases h'
      have e : HAmt.amt (fun x => x.val g) (g.hpOf w .active p) p.damage (.toHp n) = 0 := by
        simp only [HAmt.amt]; omega
      cases w <;>
        simp only [GameState.side, GameState.updSide, Option.map_some, InPlay.addDamage, HAmt.at, e,
          Nat.add_zero]
  | hitByActiveSkip _ _ _ _ _ _ h' _ => rw [hp]; rfl
  | touchActive he _ => simp [Effect.touch] at he
  | touchBench he _ => simp [Effect.touch] at he
  | zone hw _ => simp [Effect.zSide] at hw

/-- **Witness: doubling.** Playing `double` is a legal move after which the opponent's Active Pokémon
has 6 damage counters (it had 3). -/
theorem double_witness :
    WellFormed (start double) ∧ Settled (start double) ∧ ∃ g, Move (start double) g ∧
      g.opp.active.map InPlay.damage = some 6 := by
  have hm : Move (start double) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Double") rfl rfl (start_settled _)
      (.prim rfl rfl (.hitByActive .opp 1 .any false false (.per 1) rfl rfl)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide) (by decide) (by decide)))))
      rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl⟩

/-- **Witness: only damaged targets.** Playing `hurtSpread` is a legal move after which the opponent's
damaged Benched Pokémon has 4 counters (it had 2) and the undamaged one still none. -/
theorem hurt_only :
    WellFormed (start hurtSpread) ∧ Settled (start hurtSpread) ∧ ∃ g, Move (start hurtSpread) g ∧
      g.opp.bench.map InPlay.damage = [4, 0] := by
  have hh : HitsP (InPlay.hitOk .any true)
      (fun q => q.hitWith false ((HAmt.const 2).at (start hurtSpread) .opp .bench q)) 1
      [oppHurt, clean] [oppHurt.addDamage 2, clean] := .hit rfl (.keep .nil)
  have hm : Move (start hurtSpread) _ :=
    .item (l₁ := []) (l₂ := []) (n := "HurtSpread") rfl rfl (start_settled _)
      (.prim rfl rfl (.hitByBench .opp 5 .any true false (.const 2) hh)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide) (by decide) (by decide)))))
      rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl⟩

/-- **General: with `hurt`, only damaged Pokémon change.** For every resolution in every state, each
Benched Pokémon after it is one of the Benched Pokémon before it, or the update of one that had a damage
counter. -/
theorem hitBy_bench_targets {w : Whose} {m : Nat} {f : Filter} {dmg : Bool} {a : HAmt}
    {g g' : GameState} (h : Run (.hitBy w .bench m f true dmg a) g g') :
    ∀ y ∈ (g'.side w).bench, y ∈ (g.side w).bench ∨
      ∃ x ∈ (g.side w).bench, 0 < x.damage ∧ y = x.hitWith dmg (a.at g w .bench x) := by
  cases h with
  | @hitByBench _ b' _ _ _ _ _ _ hh =>
      have key : ∀ y ∈ b', y ∈ (g.side w).bench ∨
          ∃ x ∈ (g.side w).bench, 0 < x.damage ∧ y = x.hitWith dmg (a.at g w .bench x) := by
        intro y hy
        rcases hh.cases_of y hy with e | ⟨x, hx, hp, e⟩
        · exact .inl e
        · refine .inr ⟨x, hx, ?_, e⟩
          simp only [InPlay.hitOk, Bool.not_true, Bool.false_or, Bool.and_eq_true,
            decide_eq_true_eq] at hp
          exact hp.2
      cases w <;> exact key
  | touchActive he _ => simp [Effect.touch] at he
  | touchBench he _ => simp [Effect.touch] at he
  | zone hw _ => simp [Effect.zSide] at hw

/-- **Witness: moving all damage counters.** Playing `dumpCard` is a legal move after which the
player's `hurt4` has no damage counters and the opponent's Active Pokémon has 7 (it had 3). -/
theorem dump :
    WellFormed (start dumpCard) ∧ Settled (start dumpCard) ∧ ∃ g, Move (start dumpCard) g ∧
      g.cur.bench.map InPlay.damage = [0, 0] ∧ g.opp.active.map InPlay.damage = some 7 := by
  have hm : Move (start dumpCard) _ :=
    .item (l₁ := []) (l₂ := []) (n := "Dump") rfl rfl (start_settled _)
      (.prim rfl rfl (.dumpActive (b₁ := []) .any rfl rfl rfl)
        (.done (.inl (settled_of rfl rfl (by decide) (by decide) (by decide) (by decide)))))
      rfl rfl rfl rfl
  exact ⟨start_wellFormed _, start_settled _, _, hm, rfl, rfl⟩

/-- **General negative: with no Benched Pokémon passing the filter nothing moves**, for every resolution
in every state. -/
theorem dump_none {f : Filter} {sp : Spot} {g g' : GameState} (h0 : benchElig f g.cur.bench = 0)
    (h : Run (.dumpCounters f sp) g g') : g' = g := by
  have hpos : ∀ {b₁ b₂ : List InPlay} {q : InPlay}, g.cur.bench = b₁ ++ q :: b₂ →
      f.eval (.pokemon q.top) = true → False := by
    intro b₁ b₂ q hb hf
    have : 0 < benchElig f g.cur.bench := by
      rw [hb]
      simp only [benchElig, List.map_append, List.map_cons, List.countP_append, List.countP_cons, hf,
        ite_true]
      omega
    omega
  cases h with
  | dumpActive _ hb hf _ => exact (hpos hb hf).elim
  | dumpBench _ hb hf _ => exact (hpos hb hf).elim
  | dumpNone => rfl
  | touchActive he _ => simp [Effect.touch] at he
  | touchBench he _ => simp [Effect.touch] at he
  | zone hw _ => simp [Effect.zSide] at hw

end Pokemon.Computed
