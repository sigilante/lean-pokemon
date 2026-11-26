import Pokemon.Played

/-!
# Prevention of effects of attacks, milestone MV10 (survey S24)

"During your opponent's next turn, prevent all damage from and effects of attacks done to this
Pokémon" (22 refused Standard cards, Elgyem sv5-73 and others) and the static "Prevent all effects of
attacks used by your opponent's Pokémon done to this Pokémon. (Damage is not an effect.)" (Skeledirge
sv8-31, Empoleon ex me2-70; Mist Energy sv5-161 gives it to its holder).

**The construct.** A lingering flag `Mod.shield` (`Mods.shield`, one Boolean per slot of a player's
store) and a static effect `SEff.shield fr`. `GameState.shield g` holds when the opponent of the player
to move has the flag in effect (`Store.live`) or a `shield` effect in force on their Active Pokémon
against the attacker's top card. `Move.attack` resolves the attack as `atk.against g.shield`: when the
flag holds, the attack's effect is `Effect.shielded`, every primitive that the model counts as done to
the Defending Pokémon replaced by `skip` (its docstring lists them). The damage half of the printed
lingering text is the existing `Mod.prevent`; the importer writes the text as
`seq (linger .own .next .prevent) (linger .own .next .shield)`.

**When the flag is written and cleared.** Written by the owner's attack in the `next` slot of the
owner's store (`Run.linger`): not in effect during the owner's own turn. The end of that turn
(`Move.endTurn`, `Store.shift`) moves it to `now`: in effect during the opponent's next turn. The end
of the opponent's turn shifts again (`Move.endTurn` shifts both players' stores), and the slot `now` becomes the old `next`, which no attack of
the opponent writes for the owner: the flag is gone when the owner's next turn starts. `round`
follows all three steps by legal moves; the general fact is `Store.shift_live_shield`. Like every
lingering modifier it belongs to the player, not to the Pokémon (Known gaps: it protects whichever
Pokémon that player has Active, and survives evolution).

**Finiteness.** A Boolean of the store: the capped clamp keeps it (`Mods.cap` changes only amounts;
`Mods.cap_iff` gained a conjunct), the exact clamp keeps the stores whole, and the finite list of
stores lists both values (`modss`). `StoreSafe`'s amounts do not count it (`Mod.amt .shield = 0`), and
`Effect.shielded` writes, loops and recycles no more than the effect (`Effect.shielded_amtAt`,
`Effect.shielded_loopFree`, `Effect.shielded_recFilters`), so no headline statement changed.
-/

namespace Pokemon.Shield

open Trainer

/-- "During your opponent's next turn, prevent all damage from and effects of attacks done to this
Pokémon." -/
def guard : Attack :=
  ⟨"Guard", [], 0, .seq (.linger .own .next .prevent) (.linger .own .next .shield), false, .none⟩

/-- 20 damage; "Your opponent's Active Pokémon is now Paralyzed. During your opponent's next turn,
they can't play any Item cards from their hand." -/
def zap : Attack :=
  ⟨"Zap", [], 0, .seq (.damage (.const 2)) (.seq (.inflict .paralyzed) (.linger .opp .next (.lock .item))),
    false, .none⟩

/-- A 100-HP Basic Pokémon with both attacks. -/
def mon : PokemonCard := { big with name := "Mon", attacks := [guard, zap] }

/-- "Prevent all effects of attacks used by your opponent's Pokémon done to this Pokémon. (Damage is
not an effect.)" -/
def veil : Ability :=
  ⟨"Veil", .static [⟨.self, .any, none, none, none, .shield .any⟩], none, none, .fx .skip⟩

/-- The same Pokémon with the static protection. -/
def veiled : PokemonCard := { mon with name := "Veiled", abilities := [veil] }

def deck2 (a : InPlay) : PlayerState :=
  { side [] [.energy .fire] a [] with deck := [.energy .grass, .energy .grass] }

/-- The player to move has `mon` Active, the opponent `d`; both decks hold cards for the draws. -/
def r0 (d : PokemonCard) : GameState :=
  ⟨deck2 (InPlay.ofBasic mon), deck2 (InPlay.ofBasic d), true, false, false, false, none, none,
    false, false, false⟩

theorem r0_wellFormed (d : PokemonCard) : WellFormed (r0 d) := by
  refine ⟨fun _ => ⟨by simp [r0, deck2, side], by simp [r0, deck2, side]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> cases hp

theorem r0_settled_mon : Settled (r0 mon) := (GameState.settled_iff _).2 (by decide)

theorem r0_settled_veiled : Settled (r0 veiled) := (GameState.settled_iff _).2 (by decide)

/-! ## The lingering flag over a round -/

/-- The store of the player whose turn ends moves one turn closer (`Store.shift`): the flag in
effect afterwards is the flag of the `next` slot (or of the rest of the game). -/
theorem Store.shift_live_shield (t : Store) : t.shift.live.shield = (t.next.shield || t.always.shield) :=
  rfl

/-- What Zap resolves against a protected Pokémon: the damage step (prevented, if at all, by
`Mod.prevent` or `SEff.prevent`) and the Item lock on the player (not an effect on the Pokémon); the
Paralysis is gone. -/
theorem zap_shielded : (zap.against true).script =
    .seq (.damage (.const 2)) (.seq .skip (.linger .opp .next (.lock .item))) := rfl

/-- **Witnesses over a round, from the well-formed, `Settled` start `r0 mon`.** The player uses Guard
(a legal move); the flag is then written in the `next` slot of their store and is not in effect in
their own turn. Their turn ends and the opponent draws; the flag is now in effect against the
opponent's attack (`g₃.shield`), with the damage prevention. **The prevention blocks the attack's
effects**: the opponent's Zap is a legal move after which the protected Pokémon has no damage and is
not Paralyzed, while the Item lock on its player, not an effect on the Pokémon, is written. **The flag
is cleared**: the opponent's turn ends (instead of attacking) and the protected player, to move
again, has the flag in no slot of their store. -/
theorem round :
    WellFormed (r0 mon) ∧ Settled (r0 mon) ∧
    ∃ g₁ g₂ g₃ g₄ g₅, Move (r0 mon) g₁ ∧ Move g₁ g₂ ∧ Move g₂ g₃ ∧ Move g₃ g₄ ∧ Move g₃ g₅ ∧
      g₁.cur.mods.next.shield = true ∧ g₁.cur.mods.live.shield = false ∧
      g₃.shield = true ∧ g₃.opp.mods.live.prevent = true ∧
      g₄.opp.active.map InPlay.damage = some 0 ∧
      g₄.opp.active.map (InPlay.has .paralyzed) = some false ∧ g₄.opp.mods.next.noItem = true ∧
      g₅.cur.mods.live.shield = false ∧ g₅.cur.mods.next.shield = false ∧
      g₅.cur.mods.after.shield = false ∧ g₅.cur.mods.always.shield = false := by
  have hr : Run guard.script (r0 mon) _ :=
    .seq (.linger .own .next .prevent _) (.linger .own .next .shield _)
  exact ⟨r0_wellFormed _, r0_settled_mon, _, _, _, _, _,
    Move.attackOpen (hlk := rfl) (atk := guard) rfl (.head _) (.nil _) rfl rfl rfl rfl
      r0_settled_mon hr rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil hr rfl) (.nil _),
    .endTurn_of_zero false false false false false false rfl rfl
      ((GameState.settled_iff _).2 (by decide)).1 rfl .nil .nil (by decide) (by decide),
    .startTurn rfl rfl rfl ((GameState.settled_iff _).2 (by decide)).1 rfl,
    Move.attackShielded (hlk := rfl) (atk := zap) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      ((GameState.settled_iff _).2 (by decide))
      (.seq (.damage (.const 2 _) rfl) (.seq (.skip _) (.linger .opp .next (.lock .item) _)))
      rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil
        (.seq (.damage (.const 2 _) rfl) (.seq (.skip _) (.linger .opp .next (.lock .item) _))) rfl)
      (.nil _),
    .endTurn_of_zero false false false false false false rfl rfl
      ((GameState.settled_iff _).2 (by decide)).1 rfl .nil .nil (by decide) (by decide),
    rfl, rfl, by decide, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- **Witness: without the protection the effect applies.** From the well-formed, `Settled` start
`r0 mon`, Zap Paralyzes the opponent's Active Pokémon and does 20 damage. -/
theorem not_blocked :
    WellFormed (r0 mon) ∧ Settled (r0 mon) ∧ ∃ g, Move (r0 mon) g ∧
      g.opp.active.map InPlay.damage = some 2 ∧ g.opp.active.map (InPlay.has .paralyzed) = some true := by
  have hr : Run zap.script (r0 mon) _ :=
    .seq (.damage (.const 2 _) rfl) (.seq (.inflict .paralyzed rfl) (.linger .opp .next (.lock .item) _))
  exact ⟨r0_wellFormed _, r0_settled_mon, _,
    Move.attackOpen (hlk := rfl) (atk := zap) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      r0_settled_mon hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _),
    by decide, by decide⟩

/-! ## The static effect -/

/-- **Witness: a static protection blocks the effect but not the damage** ("Damage is not an
effect"): from the well-formed, `Settled` start `r0 veiled`, Zap does 20 damage to the Pokémon with
Veil and does not Paralyze it. -/
theorem static_blocks :
    WellFormed (r0 veiled) ∧ Settled (r0 veiled) ∧ ∃ g, Move (r0 veiled) g ∧
      g.opp.active.map InPlay.damage = some 2 ∧
      g.opp.active.map (InPlay.has .paralyzed) = some false := by
  have hr : Run (zap.against true).script (r0 veiled) _ :=
    .seq (.damage (.const 2 _) rfl) (.seq (.skip _) (.linger .opp .next (.lock .item) _))
  exact ⟨r0_wellFormed _, r0_settled_veiled, _,
    Move.attackShielded (hlk := rfl) (atk := zap) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      r0_settled_veiled hr rfl (fun h => absurd h (by decide)) rfl
      (HitTrig.exists_nil hr rfl) (.nil _),
    by decide, by decide⟩

/-- The static protection reads the attacker: a `shield` effect whose filter the attacker fails does
not protect (here a filter on Pokémon ex, and the attacker has no rule box). -/
theorem static_filter :
    Static.shieldsFrom mon ⟨.self, .any, none, none, none, .shield .ex⟩ = false ∧
    Static.shieldsFrom mon ⟨.self, .any, none, none, none, .shield .any⟩ = true := ⟨rfl, rfl⟩

/-! ## Under the protection, no Special Condition reaches the Defending Pokémon

A general fact about `Effect.shielded`, for every effect, not only for the witnesses' attack: a
resolution (`Run`) of a shielded effect leaves the Special Conditions and the Poison strength of the
Pokémon in the opponent's Active Spot as they were (that it is the same Pokémon is not proved here:
it holds because the switch of the opponent's Active Pokémon is removed). It is a fact about `Run`,
not about `Move` (triggers are outside it). Existing effects stay: nothing is cured either. That no
damage counter is placed, no Energy or Tool discarded and no lock or modifier written on the
Defending Pokémon is shown by the witnesses above for their attack only, not proved for every
effect. -/

/-- The Special Conditions and the Poison strength of a Pokémon in play. -/
def _root_.Pokemon.InPlay.conds (p : InPlay) : Rot × Bool × Bool × Nat :=
  (p.rot, p.poisoned, p.burned, p.poisonUp)

/-- No primitive that gives a Special Condition, raises Poison strength, or switches the opponent's
Active Pokémon. -/
def _root_.Pokemon.Effect.spares : Effect → Bool
  | .inflict _ => false
  | .poisonUp _ => false
  | .switch .opp => false
  | .ite _ a b => a.spares && b.spares
  | .seq a b => a.spares && b.spares
  | .choice a b => a.spares && b.spares
  | .iter a => a.spares
  | _ => true

theorem _root_.Pokemon.Effect.shielded_spares (e : Effect) : e.shielded.spares = true := by
  induction e with
  | ite t a b iha ihb => simp only [Effect.shielded, Effect.spares, iha, ihb, Bool.and_self]
  | seq a b iha ihb => simp only [Effect.shielded, Effect.spares, iha, ihb, Bool.and_self]
  | choice a b iha ihb => simp only [Effect.shielded, Effect.spares, iha, ihb, Bool.and_self]
  | iter a iha => simp only [Effect.shielded, Effect.spares, iha]
  | _ => unfold Effect.shielded; (try split) <;> simp_all [Effect.spares]

theorem _root_.Pokemon.Put.active {d : Dst} {t : List Card} {s s' : PlayerState} (h : Put d t s s') : s'.active = s.active := by
  cases h <;> rfl

theorem _root_.Pokemon.Deal.conds {tf : Filter} {t : List Card} {a : Option InPlay} {b : List InPlay}
    {a' : Option InPlay} {b' : List InPlay} (h : Deal tf t a b a' b') :
    a'.map InPlay.conds = a.map InPlay.conds := by
  induction h with
  | nil => rfl
  | active _ _ _ ih => exact ih
  | bench _ _ _ ih => exact ih

theorem _root_.Pokemon.Place.conds {i : Into} {t : List Card} {s s' : PlayerState} (h : Place i t s s') :
    s'.active.map InPlay.conds = s.active.map InPlay.conds := by
  cases h with
  | put h => rw [h.active]
  | bench => rfl
  | attach h => exact h.conds

/-- A zone move keeps the Special Conditions of the Active Pokémon (it moves only cards). -/
theorem _root_.Pokemon.ZStep.conds {e : Effect} {s s' : PlayerState} (h : ZStep e s s') :
    s'.active.map InPlay.conds = s.active.map InPlay.conds := by
  cases h with
  | move _ _ hp => rw [hp.active, Src.set_active]
  | drawTo => rfl
  | attachActive _ ha => rw [ha]; rfl
  | attachBench => simp only [Src.set_active]
  | attachNone => rfl
  | putBench => simp only [Src.set_active]
  | putBenchNone => rfl
  | discardActive ha => rw [ha]; rfl
  | discardBench => rfl
  | discardNone => rfl
  | moveAB ha => rw [ha]; rfl
  | moveBA ha => rw [ha]; rfl
  | moveBB => rfl
  | moveNone => rfl
  | toolsActive ha => rw [ha]; rfl
  | toolsBench => rfl
  | toolsNone => rfl
  | look _ _ hr hp => rw [hp.conds, hr.active, Src.set_active]
  | retActive ha _ _ hp => rw [hp.fields.2.1, ha]; rfl
  | retBench _ _ _ hp => rw [hp.fields.2.1]
  | retNone => rfl
  | shiftAB ha => rw [ha]; rfl
  | shiftBA ha _ _ _ hd => show Option.map _ _ = _; rw [hd.conds, ha]
  | shiftNone => rfl

/-- **A spared resolution keeps the opponent's Active Pokémon's Special Conditions and Poison
strength.** -/
theorem _root_.Pokemon.Run.conds {e : Effect} {g g' : GameState} (h : Run e g g') (hs : e.spares = true) :
    g'.opp.active.map InPlay.conds = g.opp.active.map InPlay.conds := by
  induction h with
  | inflict => simp [Effect.spares] at hs
  | poisonUp => simp [Effect.spares] at hs
  | iteT _ _ _ ih => simp only [Effect.spares, Bool.and_eq_true] at hs; exact ih hs.1
  | iteF _ _ _ ih => simp only [Effect.spares, Bool.and_eq_true] at hs; exact ih hs.2
  | seq _ _ ih₁ ih₂ =>
      simp only [Effect.spares, Bool.and_eq_true] at hs; rw [ih₂ hs.2, ih₁ hs.1]
  | choiceL _ ih => simp only [Effect.spares, Bool.and_eq_true] at hs; exact ih hs.1
  | choiceR _ ih => simp only [Effect.spares, Bool.and_eq_true] at hs; exact ih hs.2
  | iterNil => rfl
  | iterCons _ _ ih₁ ih₂ =>
      have h' : _ := hs; simp only [Effect.spares] at h'; rw [ih₂ hs, ih₁ h']
  | counters _ h => rw [h]; rfl
  | scale _ _ _ h => rw [h]; rfl
  | damage _ h => rw [h]; rfl
  | drain _ h => rw [h]; rfl
  | @touchActive _ w _ _ _ _ h =>
      cases w with
      | own => rfl
      | opp => simp only [GameState.updSide]; simp only [GameState.side] at h; rw [h]; rfl
  | @touchBench _ w => cases w <;> rfl
  | unmark w =>
      cases w with
      | own => rfl
      | opp =>
          simp only [GameState.updSide, PlayerState.unmark, Option.map_map]
          cases g.opp.active <;> rfl
  | linger w => cases w <;> rfl
  | benchCounters w => cases w <;> rfl
  | benchCountersNone w => cases w <;> rfl
  | spreadCounters w => cases w <;> rfl
  | @switch _ _ _ _ _ w =>
      cases w with
      | own =>
          simp only [Whose.noteBenched, GameState.noteBenched, GameState.updSide, Option.map_map]
          cases g.opp.active <;> rfl
      | opp => simp [Effect.spares] at hs
  | benchDamage w => cases w <;> rfl
  | benchDamageNone w => cases w <;> rfl
  | spreadDamage w => cases w <;> rfl
  | benchSome w => cases w <;> rfl
  | @zone _ w _ _ _ h =>
      cases w with
      | own => rfl
      | opp => exact h.conds
  | _ => rfl

/-- **Under the protection, the opponent's attack gives no Special Condition and no Poison strength
to the Defending Pokémon, and removes none**: for every effect `e`, every resolution of
`e.shielded` keeps them. -/
theorem shielded_keeps_conds {e : Effect} {g g' : GameState} (h : Run e.shielded g g') :
    g'.opp.active.map InPlay.conds = g.opp.active.map InPlay.conds :=
  h.conds (Effect.shielded_spares e)

/-- **The same for an attack against a protected Pokémon** (`Move.attack` with `g.shield = true`). -/
theorem against_keeps_conds {atk : Attack} {g g' : GameState} (h : Run (atk.against true).script g g') :
    g'.opp.active.map InPlay.conds = g.opp.active.map InPlay.conds := by
  rw [Attack.against_script] at h
  exact shielded_keeps_conds h

end Pokemon.Shield
