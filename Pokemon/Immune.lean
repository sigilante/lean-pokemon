import Pokemon.BenchGuard

/-!
# Special Condition immunity and heal block (milestone MV13, survey S27 A3, A4)

* `SEff.noCond c`: "This Pokémon can't be Asleep" (Hoothoot sv8pt5-77). `Run.inflict` reads
  `GameState.condImmune .opp c p` on the opponent's Active Pokémon `p` and leaves it as it was when an
  effect in force makes it immune to `c` (`InPlay.inflictIf`). Every Special Condition of the model
  enters through `Run.inflict` (attacks, Trainers, Abilities and triggers alike), and the immunity is
  of the Pokémon, whatever the source, so the read needs no mode.
* `SEff.noHeal`: "Your opponent's Active Pokémon can't be healed" (Yveltal me55-100). `Run.heal`,
  `Run.healAll` and the heal of `Run.drain` remove `GameState.healAmt n` counters from the player's
  Active Pokémon: `n`, or none when a `noHeal` effect is in force on it (`GameState.healBlocked`).
  These are the only heals of an Active Pokémon in the language (`benchHeal`, `benchHealSome` heal
  Benched Pokémon; moving damage counters, `moveCounter`, is not healing).

**The clamps.** Both reads are functions of the field (`SameField.condImmune`, `SameField.healBlocked`),
so `Run.cap_sim`, `Run.xcap_sim`, `Run.clamp_sim` (ZoneSim) kept their statements; heals act on the
player's own Active Pokémon, exact under both clamps inside an effect, as before.

**The old step.** `Run.inflict_old`, `Run.heal_old`, `Run.healAll_old`, `Run.drain_old` (each an `↔`
with the pre-MV13 rule), and `GameState.immune_heal_noStatics` for states with no static effect:
without such an effect in force each rule is its pre-MV13 form.
-/

namespace Pokemon

@[simp] theorem InPlay.inflictIf_false (c : Condition) (p : InPlay) : p.inflictIf false c = p.inflict c :=
  rfl

@[simp] theorem InPlay.inflictIf_true (c : Condition) (p : InPlay) : p.inflictIf true c = p := rfl

theorem GameState.healAmt_of {g : GameState} (h : g.healBlocked = false) (n : Nat) : g.healAmt n = n := by
  simp only [GameState.healAmt, h, Bool.false_eq_true, ite_false]

/-- **The old step: inflict** (milestone MV13). When the opponent's Active Pokémon is not immune to
`c`, `inflict c` has exactly the resolution of its pre-MV13 rule. -/
theorem Run.inflict_old {g g' : GameState} {c : Condition} {p : InPlay} (hp : g.opp.active = some p)
    (hi : g.condImmune .opp c p = false) :
    Run (.inflict c) g g' ↔ g' = { g with opp := { g.opp with active := some (p.inflict c) } } := by
  constructor
  · intro h
    cases h with
    | inflict _ h' => rw [hp] at h'; cases h'; rw [hi]; rfl
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
    | zone hw _ => simp [Effect.zSide] at hw
  · rintro rfl
    have r := Run.inflict (g := g) c hp
    rw [hi] at r
    exact r

/-- **The old step: heal** (milestone MV13). Without a heal block, `heal n` has exactly the resolution
of its pre-MV13 rule. -/
theorem Run.heal_old {g g' : GameState} {n : Nat} {p : InPlay} (hp : g.cur.active = some p)
    (hb : g.healBlocked = false) :
    Run (.heal n) g g' ↔ g' = { g with cur := { g.cur with active := some { p with damage := p.damage - n } } } := by
  constructor
  · intro h
    cases h with
    | heal _ h' => rw [hp] at h'; cases h'; rw [GameState.healAmt_of hb]
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
    | zone hw _ => simp [Effect.zSide] at hw
  · rintro rfl
    have r := Run.heal (g := g) n hp
    rw [GameState.healAmt_of hb] at r
    exact r

/-- **The old step: heal all** (milestone MV13). -/
theorem Run.healAll_old {g g' : GameState} {p : InPlay} (hp : g.cur.active = some p)
    (hb : g.healBlocked = false) :
    Run .healAll g g' ↔ g' = { g with cur := { g.cur with active := some { p with damage := 0 } } } := by
  constructor
  · intro h
    cases h with
    | healAll h' => rw [hp] at h'; cases h'; rw [GameState.healAmt_of hb, Nat.sub_self]
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
    | zone hw _ => simp [Effect.zSide] at hw
  · rintro rfl
    have r := Run.healAll (g := g) hp
    rw [GameState.healAmt_of hb, Nat.sub_self] at r
    exact r

/-- **The old step: drain** (milestone MV13). Without a heal block, `drain a` has exactly the
resolutions of its pre-MV13 rule (as at `master` c1ea6fb): the damage step, and the player's Active
Pokémon healed by the damage done. -/
theorem Run.drain_old {g g' : GameState} {a : Amt} (hb : g.healBlocked = false) :
    Run (.drain a) g g' ↔ ∃ (p q : InPlay) (n : Nat), a.Val g n ∧ g.opp.active = some p ∧
      g.cur.active = some q ∧
      g' = { g with cur := { g.cur with active := some { q with damage := q.damage - g.dealt n } },
                    opp := { g.opp with active := some { p with damage := p.damage + g.dealt n } } } := by
  constructor
  · intro h
    cases h with
    | @drain _ p q _ n hv hp hq => exact ⟨p, q, n, hv, hp, hq, by rw [GameState.healAmt_of hb]⟩
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
    | zone hw _ => simp [Effect.zSide] at hw
  · rintro ⟨p, q, n, hv, hp, hq, rfl⟩
    have r := Run.drain hv hp hq
    rw [GameState.healAmt_of hb] at r
    exact r

/-- The heal of `drain` without a heal block is the damage dealt (milestone MV13). -/
theorem GameState.drainHeal_of {g : GameState} (hb : g.healBlocked = false) (n : Nat) :
    g.healAmt (g.dealt n) = g.dealt n := GameState.healAmt_of hb _

/-- With no static effects, nothing is immune and nothing blocks a heal: `inflict` and every heal
resolve as before milestone MV13 (`Run.inflict_old`, `Run.heal_old`, `Run.healAll_old`,
`Run.drain_old`). -/
theorem GameState.immune_heal_noStatics {g : GameState} (hn : g.NoStatics) {p : InPlay}
    (hp : g.opp.active = some p) (c : Condition) :
    g.condImmune .opp c p = false ∧ g.healBlocked = false :=
  ⟨g.condImmune_noStatics hn (w' := .opp) (sp := .active) hp .opp c, g.healBlocked_noStatics hn⟩

namespace Immune

open Trainer

/-- "This Pokémon can't be Asleep." -/
def insomnia : Ability :=
  ⟨"Insomnia", .static [⟨.self, .any, none, none, none, .noCond .asleep⟩], none, none, .fx .skip⟩

def owl : InPlay := InPlay.ofBasic { big with name := "Owl", abilities := [insomnia] }

/-- "Your opponent's Active Pokémon can't be healed." -/
def lifeLock : Ability :=
  ⟨"LifeLock", .static [⟨.opp, .any, some .active, none, none, .noHeal⟩], none, none, .fx .skip⟩

def locker : InPlay := InPlay.ofBasic { big with name := "Locker", abilities := [lifeLock] }

def plain : InPlay := InPlay.ofBasic { big with name := "Plain" }

def hurt : InPlay := { InPlay.ofBasic { big with name := "Hurt" } with damage := 5 }

/-- Item cards: "Your opponent's Active Pokémon is now Asleep / Confused"; "Heal 30 damage from your
Active Pokémon". -/
def sleepy : Card := .trainer "Sleepy" .item (.inflict .asleep)
def dizzy : Card := .trainer "Dizzy" .item (.inflict .confused)
def potion : Card := .trainer "Potion" .item (.heal 3)

/-- The player to move has `a` Active and `c` in hand; the opponent has `d` Active and `b` Benched. -/
def st (c : Card) (a d : InPlay) (b : List InPlay) : GameState :=
  ⟨side [c] [.energy .fire] a [], side [] [.energy .fire] d b,
    true, false, false, false, none, none, false, false, false⟩

theorem st_wf_nil (c : Card) (a d : InPlay) (hm : (st c a d []).marksOkB = true) :
    WellFormed (st c a d []) := by
  refine ⟨fun _ => ⟨by simp [st, Trainer.side], by simp [st, Trainer.side]⟩, ?_, ?_, ?_⟩
  · intro p hp; simp [st, Trainer.side] at hp
  · intro p hp; simp [st, Trainer.side] at hp
  · exact .of_b hm

theorem st_wf_locker (c : Card) (a d : InPlay) (hm : (st c a d [locker]).marksOkB = true) :
    WellFormed (st c a d [locker]) := by
  refine ⟨fun _ => ⟨by simp [st, Trainer.side], by simp [st, Trainer.side]⟩, ?_, ?_, ?_⟩
  · intro p hp; simp [st, Trainer.side] at hp
  · intro p hp
    simp only [st, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
    subst hp; exact ⟨rfl, rfl, rfl, rfl⟩
  · exact .of_b hm

/-- **Witness: immunity blocks** (positive). From a well-formed, `Settled` start, playing Sleepy
against an opponent's Active Pokémon that can't be Asleep is a legal move after which it is not
Asleep. -/
theorem sleep_blocked :
    WellFormed (st sleepy plain owl []) ∧ Settled (st sleepy plain owl []) ∧
      ∃ g, Move (st sleepy plain owl []) g ∧ g.opp.active.map (InPlay.has .asleep) = some false := by
  have hs : Settled (st sleepy plain owl []) := (GameState.settled_iff _).2 (by decide)
  exact ⟨st_wf_nil _ _ _ rfl, hs, _,
    .item (l₁ := []) (l₂ := []) (n := "Sleepy") rfl rfl hs
      (.prim rfl rfl (.inflict .asleep rfl) (.done (.inl ((GameState.settled_iff _).2 (by decide)))))
      rfl rfl rfl rfl, by decide⟩

/-- **Every resolution of the Item's effect from that start leaves the immune Pokémon not Asleep**
(universal form of `sleep_blocked`): a fact about `Run` of `inflict .asleep` from the start
`st sleepy plain owl []`, not about `Move`. -/
theorem sleep_blocked_all :
    ∀ g', Run (.inflict .asleep) (st sleepy plain owl []) g' →
      g'.opp.active.map (InPlay.has .asleep) = some false := by
  intro g' h
  cases h with
  | inflict _ h' => cases h'; decide
  | touchActive he _ => simp [Effect.touch] at he
  | touchBench he _ => simp [Effect.touch] at he
  | zone hw _ => simp [Effect.zSide] at hw

/-- **Witness: the immunity is to Asleep only** (negative, outside the filter): the same opponent is
Confused by Dizzy. -/
theorem confusion_lands :
    WellFormed (st dizzy plain owl []) ∧ Settled (st dizzy plain owl []) ∧
      ∃ g, Move (st dizzy plain owl []) g ∧ g.opp.active.map (InPlay.has .confused) = some true := by
  have hs : Settled (st dizzy plain owl []) := (GameState.settled_iff _).2 (by decide)
  exact ⟨st_wf_nil _ _ _ rfl, hs, _,
    .item (l₁ := []) (l₂ := []) (n := "Dizzy") rfl rfl hs
      (.prim rfl rfl (.inflict .confused rfl) (.done (.inl ((GameState.settled_iff _).2 (by decide)))))
      rfl rfl rfl rfl, by decide⟩

/-- **Witness: without the Ability the Pokémon is Asleep** (negative). -/
theorem sleep_lands :
    WellFormed (st sleepy plain plain []) ∧ Settled (st sleepy plain plain []) ∧
      ∃ g, Move (st sleepy plain plain []) g ∧ g.opp.active.map (InPlay.has .asleep) = some true := by
  have hs : Settled (st sleepy plain plain []) := (GameState.settled_iff _).2 (by decide)
  exact ⟨st_wf_nil _ _ _ rfl, hs, _,
    .item (l₁ := []) (l₂ := []) (n := "Sleepy") rfl rfl hs
      (.prim rfl rfl (.inflict .asleep rfl) (.done (.inl ((GameState.settled_iff _).2 (by decide)))))
      rfl rfl rfl rfl, by decide⟩

/-- **Witness: the heal block** (positive). The opponent has a Benched Pokémon whose Ability says "Your
opponent's Active Pokémon can't be healed"; playing Potion is a legal move after which the player's
Active Pokémon still has its 5 damage counters. -/
theorem heal_blocked :
    WellFormed (st potion hurt plain [locker]) ∧ Settled (st potion hurt plain [locker]) ∧
      ∃ g, Move (st potion hurt plain [locker]) g ∧ g.cur.active.map InPlay.damage = some 5 := by
  have hs : Settled (st potion hurt plain [locker]) := (GameState.settled_iff _).2 (by decide)
  exact ⟨st_wf_locker _ _ _ rfl, hs, _,
    .item (l₁ := []) (l₂ := []) (n := "Potion") rfl rfl hs
      (.prim rfl rfl (.heal 3 rfl) (.done (.inl ((GameState.settled_iff _).2 (by decide)))))
      rfl rfl rfl rfl, by decide⟩

/-- **Every resolution of Potion's effect from that start heals nothing** (universal form of
`heal_blocked`): a fact about `Run` of `heal 3` from the start `st potion hurt plain [locker]`, not about
`Move`. -/
theorem heal_blocked_all :
    ∀ g', Run (.heal 3) (st potion hurt plain [locker]) g' → g'.cur.active.map InPlay.damage = some 5 := by
  intro g' h
  cases h with
  | heal _ h' => cases h'; decide
  | touchActive he _ => simp [Effect.touch] at he
  | touchBench he _ => simp [Effect.touch] at he
  | zone hw _ => simp [Effect.zSide] at hw

/-- **Witness: without the heal block Potion heals** (negative): the Active Pokémon has 2 damage
counters left. -/
theorem heal_lands :
    WellFormed (st potion hurt plain []) ∧ Settled (st potion hurt plain []) ∧
      ∃ g, Move (st potion hurt plain []) g ∧ g.cur.active.map InPlay.damage = some 2 := by
  have hs : Settled (st potion hurt plain []) := (GameState.settled_iff _).2 (by decide)
  exact ⟨st_wf_nil _ _ _ rfl, hs, _,
    .item (l₁ := []) (l₂ := []) (n := "Potion") rfl rfl hs
      (.prim rfl rfl (.heal 3 rfl) (.done (.inl ((GameState.settled_iff _).2 (by decide)))))
      rfl rfl rfl rfl, by decide⟩

/-- **Witness: the heal block is on the opponent's side only** (negative, outside the filter): the
same Ability on the player's own Benched Pokémon (`sel = opp` reaches only the other player's Pokémon)
does not stop the player's Potion. -/
def ownLock : GameState :=
  ⟨side [potion] [.energy .fire] hurt [locker], side [] [.energy .fire] plain [],
    true, false, false, false, none, none, false, false, false⟩

theorem own_lock_heals :
    WellFormed ownLock ∧ Settled ownLock ∧
      ∃ g, Move ownLock g ∧ g.cur.active.map InPlay.damage = some 2 := by
  have hs : Settled ownLock := (GameState.settled_iff _).2 (by decide)
  have hw : WellFormed ownLock := by
    refine ⟨fun _ => ⟨by simp [ownLock, Trainer.side], by simp [ownLock, Trainer.side]⟩, ?_, ?_, ?_⟩
    · intro p hp
      simp only [ownLock, Trainer.side, List.mem_cons, List.not_mem_nil, or_false] at hp
      subst hp; exact ⟨rfl, rfl, rfl, rfl⟩
    · intro p hp; simp [ownLock, Trainer.side] at hp
    · exact .of_b rfl
  exact ⟨hw, hs, _,
    .item (l₁ := []) (l₂ := []) (n := "Potion") rfl rfl hs
      (.prim rfl rfl (.heal 3 rfl) (.done (.inl ((GameState.settled_iff _).2 (by decide)))))
      rfl rfl rfl rfl, by decide⟩

end Immune

end Pokemon
