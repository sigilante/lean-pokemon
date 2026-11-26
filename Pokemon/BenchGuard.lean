import Pokemon.Computed

/-!
# Static damage prevention on the Bench (milestone MV13, survey S27 A1)

"Prevent all damage done to your Benched Pokémon that don't have a Rule Box by attacks from your
opponent's Pokémon" (Shaymin sv10-10), "As long as this Pokémon is on your Bench, prevent all damage
… done to this Pokémon" (Poltchageist sv6-20, Misty's Magikarp sv10-48, Pikachu me55-33, Shadowy
Darkness Energy me5-83), "… done to your Benched Pokémon" (Rabsca sv5-24), and every existing
`SEff.prevent` not limited to the Active Spot (Sylveon sv8pt5-40: "Prevent all damage done to this
Pokémon by attacks from your opponent's Pokémon ex", which print applies on the Bench too).

**The construct.** No new state and no new constructor. The damage forms of the Bench primitives
(`benchDamage`, `spreadDamage`, `benchSome … true`, `hitBy … .bench … true`) place on each Benched
target of the `w` player the amount `GameState.bAmt w dmg n q`: `n`, or 0 when `dmg` holds and a static
`SEff.prevent fr` is in force on the target at the Bench with `fr` passing the attacker's top card
(`GameState.benchSafe`; only for `w = opp`). The damage forms are used only by attacks
(`Effect.benchHitFree`, required of Items, Supporters, Stadiums and Abilities; `Effect.trigOk` excludes
them from triggers), so "by attacks" needs no mode in `Run`. Damage counters are not read: "effects of
attacks" on the Bench stay absent (Known gaps; survey S27 §2 explains why: `Run` does not know whether
it resolves an attack).

**The clamps.** The protection reads the static effects in force on the target (a function of its view,
the field and the Stadium) and the attacker's top card; both clamps keep all of them
(`GameState.SameField.benchSafe`), so the amount is the same on both sides (`clampWith_hitB`,
`InPlay.Agree.hitBenchB`, `clampWith_hitAmtB`). `Run.cap_sim` and `Run.xcap_sim` kept their statements.

**The old step.** `Run.benchDamage_old`, `Run.spreadDamage_old`, `Run.benchSome_old`,
`Run.hitByBench_old` prove that when no Benched Pokémon of the `w` player is protected
(`GameState.BenchOpen`), each primitive has exactly the resolutions of its pre-MV13 rule;
`GameState.benchOpen_noStatics` gives that hypothesis for every state with no static effect, and
`GameState.benchOpen_own` for the player's own Bench.
-/

namespace Pokemon

/-- No Benched Pokémon of the `w` player is protected by a static damage prevention (milestone MV13). -/
def GameState.BenchOpen (g : GameState) (w : Whose) : Prop :=
  ∀ q ∈ (g.side w).bench, g.benchSafe w q = false

/-- The player's own Bench is always open to their own attack. -/
theorem GameState.benchOpen_own (g : GameState) : g.BenchOpen .own :=
  fun q _ => g.benchSafe_own q

/-- With no static effects in the game, every Bench is open. -/
theorem GameState.benchOpen_noStatics {g : GameState} (hn : g.NoStatics) (w : Whose) : g.BenchOpen w :=
  fun _ hq => g.benchSafe_noStatics hn (w' := w) (sp := .bench) hq w

/-- `Hits` with two updates that agree on the old Bench. -/
theorem Hits.congr_upd {U V : InPlay → InPlay} {f : Filter} {k : Nat} {b b' : List InPlay}
    (h : Hits U f k b b') (hUV : ∀ x ∈ b, U x = V x) : Hits V f k b b' := by
  induction h with
  | nil => exact .nil
  | hit hx _ ih =>
      rw [hUV _ (.head _)]
      exact .hit hx (ih fun x hx' => hUV x (.tail _ hx'))
  | keep _ ih => exact .keep (ih fun x hx' => hUV x (.tail _ hx'))

/-- `HitsP` with two updates that agree on the old Bench. -/
theorem HitsP.congr_upd {P : InPlay → Bool} {U V : InPlay → InPlay} {k : Nat} {b b' : List InPlay}
    (h : HitsP P U k b b') (hUV : ∀ x ∈ b, U x = V x) : HitsP P V k b b' := by
  induction h with
  | nil => exact .nil
  | hit hx _ ih =>
      rw [hUV _ (.head _)]
      exact .hit hx (ih fun x hx' => hUV x (.tail _ hx'))
  | keep _ ih => exact .keep (ih fun x hx' => hUV x (.tail _ hx'))

theorem GameState.BenchOpen.amt {g : GameState} {w : Whose} (h : g.BenchOpen w) (dmg : Bool) (n : Nat)
    {q : InPlay} (hq : q ∈ (g.side w).bench) : g.bAmt w dmg n q = n :=
  GameState.bAmt_of_safe (h q hq) dmg n

/-- **The old step: one chosen Benched Pokémon** (milestone MV13). When no Benched Pokémon of the `w`
player is protected, `benchDamage w n` has exactly the resolutions of its pre-MV13 rule: `n` more
damage (none on a Tera Pokémon) on one chosen Benched Pokémon, or nothing on an empty Bench. -/
theorem Run.benchDamage_old {g g' : GameState} {w : Whose} {n : Nat} (ho : g.BenchOpen w) :
    Run (.benchDamage w n) g g' ↔
      (∃ b₁ q b₂, (g.side w).bench = b₁ ++ q :: b₂ ∧
        g' = g.updSide w fun s => { s with bench := b₁ ++ q.hitBench n :: b₂ }) ∨
      ((g.side w).bench = [] ∧ g' = g) := by
  constructor
  · intro h
    cases h with
    | @benchDamage _ q b₁ b₂ _ _ hb =>
        refine .inl ⟨b₁, q, b₂, hb, ?_⟩
        rw [ho.amt true n (by rw [hb]; exact List.mem_append_right _ (.head _))]
    | benchDamageNone _ _ hb => exact .inr ⟨hb, rfl⟩
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
    | zone hw _ => simp [Effect.zSide] at hw
  · rintro (⟨b₁, q, b₂, hb, rfl⟩ | ⟨hb, rfl⟩)
    · have e := ho.amt true n (q := q) (by rw [hb]; exact List.mem_append_right _ (.head _))
      have r := Run.benchDamage (g := g) (b₁ := b₁) w n hb
      rw [e] at r
      exact r
    · exact .benchDamageNone w n hb

/-- **The old step: each Benched Pokémon** (milestone MV13). -/
theorem Run.spreadDamage_old {g g' : GameState} {w : Whose} {n : Nat} (ho : g.BenchOpen w) :
    Run (.spreadDamage w n) g g' ↔
      g' = g.updSide w fun s => { s with bench := s.bench.map (InPlay.hitBench n) } := by
  have e : (g.side w).bench.map (fun q => q.hitBench (g.bAmt w true n q)) =
      (g.side w).bench.map (InPlay.hitBench n) :=
    List.map_congr_left fun q hq => by rw [ho.amt true n hq]
  have e' : (g.updSide w fun s => { s with bench := s.bench.map fun q => q.hitBench (g.bAmt w true n q) })
      = g.updSide w fun s => { s with bench := s.bench.map (InPlay.hitBench n) } := by
    cases w <;> simp only [GameState.side] at e <;> simp only [GameState.updSide, e]
  constructor
  · intro h
    cases h with
    | spreadDamage => exact e'
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
    | zone hw _ => simp [Effect.zSide] at hw
  · rintro rfl
    rw [← e']
    exact .spreadDamage w n g

/-- **The old step: `m` filtered Benched Pokémon** (milestone MV13). -/
theorem Run.benchSome_old {g g' : GameState} {w : Whose} {m n : Nat} {f : Filter} {dmg : Bool}
    (ho : g.BenchOpen w) :
    Run (.benchSome w m f dmg n) g g' ↔
      ∃ b', Hits (InPlay.hitWith dmg n) f (min m (benchElig f (g.side w).bench)) (g.side w).bench b' ∧
        g' = g.updSide w fun s => { s with bench := b' } := by
  constructor
  · intro h
    cases h with
    | @benchSome _ b' _ _ _ _ _ hh =>
        exact ⟨b', hh.congr_upd fun x hx => by simp only [ho.amt dmg n hx], rfl⟩
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
    | zone hw _ => simp [Effect.zSide] at hw
  · rintro ⟨b', hh, rfl⟩
    exact .benchSome w m f dmg n (hh.congr_upd fun x hx => by simp only [ho.amt dmg n hx])

/-- **The old step: a computed amount on Benched targets** (milestone MV13). -/
theorem Run.hitByBench_old {g g' : GameState} {w : Whose} {m : Nat} {f : Filter} {hurt dmg : Bool}
    {a : HAmt} (ho : g.BenchOpen w) :
    Run (.hitBy w .bench m f hurt dmg a) g g' ↔
      ∃ b', HitsP (InPlay.hitOk f hurt) (fun q => q.hitWith dmg (a.at g w .bench q))
          (min m (benchEligP (InPlay.hitOk f hurt) (g.side w).bench)) (g.side w).bench b' ∧
        g' = g.updSide w fun s => { s with bench := b' } := by
  constructor
  · intro h
    cases h with
    | @hitByBench _ b' _ _ _ _ _ _ hh =>
        exact ⟨b', hh.congr_upd fun x hx => by simp only [ho.amt dmg _ hx], rfl⟩
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
    | zone hw _ => simp [Effect.zSide] at hw
  · rintro ⟨b', hh, rfl⟩
    exact .hitByBench w m f hurt dmg a (hh.congr_upd fun x hx => by simp only [ho.amt dmg _ hx])

/-- **What a protected Pokémon gets: nothing** (milestone MV13), for every amount: a Benched Pokémon
with `benchSafe` keeps its damage under every damage form. -/
theorem GameState.hitBench_safe {g : GameState} {w : Whose} {q : InPlay} (h : g.benchSafe w q = true)
    (n : Nat) : (q.hitBench (g.bAmt w true n q)).damage = q.damage := by
  simp only [GameState.bAmt, h, Bool.and_self, ite_true, InPlay.hitBench]
  split <;> simp [InPlay.addDamage]

namespace BenchGuard

open Trainer

/-- "This attack does 30 damage to each of your opponent's Benched Pokémon." -/
def spray : Attack := ⟨"Spray", [], 0, .spreadDamage .opp 3, false, .none⟩

/-- A 100-HP Basic Pokémon with Spray. -/
def mon : PokemonCard := { big with name := "Mon", attacks := [spray] }

/-- "As long as this Pokémon is on your Bench, prevent all damage done to this Pokémon by attacks from
your opponent's Pokémon" (Poltchageist sv6-20's damage half; Shadowy Darkness Energy). -/
def hide (fr : Filter) : Ability :=
  ⟨"Hide", .static [⟨.self, .any, none, some .bench, none, .prevent fr⟩], none, none, .fx .skip⟩

/-- A Pokémon with that Ability, against every attacker (`any`) or only against Pokémon ex. -/
def hider (fr : Filter) : InPlay := InPlay.ofBasic { big with name := "Hider", abilities := [hide fr] }

def plain : InPlay := InPlay.ofBasic { big with name := "Plain" }

/-- The player to move has `mon` Active; the opponent has `big` Active and `b` on the Bench. -/
def r0 (b : List InPlay) : GameState :=
  ⟨side [] [.energy .fire] (InPlay.ofBasic mon) [], side [] [.energy .fire] (InPlay.ofBasic big) b,
    true, false, false, false, none, none, false, false, false⟩

theorem r0_wellFormed (x : InPlay) (hx : x = hider .any ∨ x = hider .ex ∨ x = plain) :
    WellFormed (r0 [x, plain]) := by
  rcases hx with rfl | rfl | rfl <;>
  · refine ⟨fun _ => ⟨by simp [r0, Trainer.side], by simp [r0, Trainer.side]⟩,
      fun p hp => ?_, fun p hp => ?_, .of_b rfl⟩
    · simp [r0, Trainer.side] at hp
    · simp only [r0, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem r0_settled_any : Settled (r0 [hider .any, plain]) := (GameState.settled_iff _).2 (by decide)
theorem r0_settled_ex : Settled (r0 [hider .ex, plain]) := (GameState.settled_iff _).2 (by decide)
theorem r0_settled_plain : Settled (r0 [plain, plain]) := (GameState.settled_iff _).2 (by decide)

/-- **Witness: the protection blocks** (positive). From the well-formed, `Settled` start, Spray is a
legal move after which the opponent's protected Benched Pokémon has no damage and the other one 3
counters. -/
theorem blocks :
    WellFormed (r0 [hider .any, plain]) ∧ Settled (r0 [hider .any, plain]) ∧
      ∃ g, Move (r0 [hider .any, plain]) g ∧ g.opp.bench.map InPlay.damage = [0, 3] := by
  have hr : Run spray.script (r0 [hider .any, plain]) _ := .spreadDamage .opp 3 _
  exact ⟨r0_wellFormed _ (.inl rfl), r0_settled_any, _,
    Move.attackOpen (hlk := rfl) (atk := spray) rfl (.head _) (.nil _) rfl rfl rfl rfl
      r0_settled_any hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    by decide⟩

/-- **Witness: against an attacker outside the filter the damage lands** (negative). The same start,
with the prevention limited to attacks from Pokémon ex (the attacker has no rule box): Spray is a
legal move after which both Benched Pokémon have 3 counters. -/
theorem filter_lands :
    WellFormed (r0 [hider .ex, plain]) ∧ Settled (r0 [hider .ex, plain]) ∧
      ∃ g, Move (r0 [hider .ex, plain]) g ∧ g.opp.bench.map InPlay.damage = [3, 3] := by
  have hr : Run spray.script (r0 [hider .ex, plain]) _ := .spreadDamage .opp 3 _
  exact ⟨r0_wellFormed _ (.inr (.inl rfl)), r0_settled_ex, _,
    Move.attackOpen (hlk := rfl) (atk := spray) rfl (.head _) (.nil _) rfl rfl rfl rfl
      r0_settled_ex hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    by decide⟩

/-- **Witness: without the Ability the damage lands** (negative): from the well-formed, `Settled`
start with two Benched Pokémon without it, Spray is a legal move after which both have 3 counters. -/
theorem no_ability_lands :
    WellFormed (r0 [plain, plain]) ∧ Settled (r0 [plain, plain]) ∧
      ∃ g, Move (r0 [plain, plain]) g ∧ g.opp.bench.map InPlay.damage = [3, 3] := by
  have hr : Run spray.script (r0 [plain, plain]) _ := .spreadDamage .opp 3 _
  exact ⟨r0_wellFormed _ (.inr (.inr rfl)), r0_settled_plain, _,
    Move.attackOpen (hlk := rfl) (atk := spray) rfl (.head _) (.nil _) rfl rfl rfl rfl
      r0_settled_plain hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    by decide⟩

end BenchGuard

end Pokemon
