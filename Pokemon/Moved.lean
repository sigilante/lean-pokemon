import Pokemon.SelfKO

/-!
# Triggers on the player's own moves between the Bench and the Active Spot (milestone MV7c)

Witnesses for `TrigEvent.movedUp` and `TrigEvent.movedDown` (survey S20 §a, group (a)):
"Once during your turn, when this Pokémon moves from your Bench to the Active Spot, you may search
your deck for up to 3 Basic Grass Energy cards and attach them to this Pokémon. Then, shuffle your
deck." (Yanmega ex sv10-3; the test card `yan` has it with one Grass Energy) and "Once during your
turn, when this Pokémon moves from the Active Spot to your Bench, you may use this Ability. Attach up
to 2 Basic Water Energy cards from your hand to this Pokémon." (Clawitzer me1-38; `claw`, one Water
Energy). Both cards are expressible; since importer 0.15.0 Clawitzer is imported (with caveats) and Yanmega ex is
refused for an unrelated attack sentence: `yan` and `claw` are test cards, not the printed ones. The event is
raised where the Pokémon moves (`InPlay.noteMove` marks it and spends its
"once during your turn" flag, `InPlay.used`), and the resolution (`Owed`) fires the marked holders'
triggers, the player to move's own (`FireMine`), before anything else.

Existential witnesses (one play exists; nothing is claimed about every resolution):
* `retreat_fires_up`: a retreat moves `yan` up; the next move resolves its trigger, which attaches
  the Grass Energy from the deck to it, the new Active Pokémon;
* `retreat_fires_down`: a retreat moves `claw` down; its trigger attaches the Water Energy from the
  hand to it, on the Bench;
* `up_declined`: the optional trigger (a drawing variant, `up true`) can be declined;
* `uturn_fires`: an attack that switches its own user moves `yan` up; the trigger resolves before
  the attack's Knock Out check;
* `promotion_fires`: an Ability that Knocks Out its own user (`SelfKO.cursed`) leaves the Active Spot
  empty in its owner's turn; the batch step promotes `yan`, and its trigger resolves inside the
  Ability's resolution (`Resolve.trigger`);
* `once_per_turn`: retreat, trigger, Switch, Switch: `yan` moves up a second time in the turn and
  nothing is pending afterwards (with the universal lemma `InPlay.noteMove_of_used`);
* `copy_quiet`: putting a second `yan` onto the Bench from the hand is no move between the Bench and
  the Active Spot: the play is legal and leaves nothing pending (with the universal lemma
  `PlayFromHand.pend`: no play from the hand changes the record).

Universal statements (over every move or every resolution from the state named):
* `up_forced`: the mandatory drawing variant (`up false`) cannot be skipped: every move after the
  retreat gives the owner the card;
* `checkup_promotion_quiet`: between turns (after Pokémon Checkup, which the model reads as in no
  player's turn; a reading, Known gaps of `Pokemon/Rules.lean`), a Knock Out of the Active Pokémon
  of the player about to move and the promotion of `yan` raise nothing: every move leaves nothing
  pending;
* `opp_promotion_quiet`: the opponent's promotion of `yan` after an attack Knocks out their Active
  Pokémon raises nothing (it is not the opponent's turn): every move leaves nothing pending;
* `gust_quiet`: the player's gust (`switch .opp`) moves the opponent's `yan` up during the player's
  turn, not the opponent's: every resolution of the gust Item leaves nothing pending.
-/

namespace Pokemon.Moved
open Pokemon.Benched Pokemon.Promoted Pokemon.CheckupW Pokemon.SelfKO

/-- Yanmega ex's Ability (sv10-3), with one Grass Energy (three are three such steps). -/
def buzz : Ability :=
  ⟨"Buzz", .triggered .movedUp true, none, none,
    .seq (.self (.attach .deck (.energyOf .grass))) (.fx .shuffle)⟩

def yanC : PokemonCard := ⟨"Yan", .basic, none, 10, .grass, [], 0, none, none, .none, false, [buzz]⟩

/-- Clawitzer's Ability (me1-38), with one Water Energy. -/
def reload : Ability :=
  ⟨"Reload", .triggered .movedDown true, none, none, .self (.attach .hand (.energyOf .water))⟩

def clawC : PokemonCard := ⟨"Claw", .basic, none, 10, .water, [], 0, none, none, .none, false, [reload]⟩

/-- A `movedUp` trigger with an observable effect: its owner draws a card; mandatory (`opt = false`)
or optional. -/
def up (opt : Bool) : Ability := ⟨"Up", .triggered .movedUp opt, none, none, .fx .draw⟩

def upC (opt : Bool) : PokemonCard :=
  ⟨"Upper", .basic, none, 10, .grass, [], 0, none, none, .none, false, [up opt]⟩

/-- A player with the hand, deck, Active and Bench given and two Prize cards. -/
def ps (hand deck : List Card) (a : InPlay) (b : List InPlay) : PlayerState :=
  ⟨deck, hand, [], [.energy .fire, .energy .fire], [], some a, b, false, false, false, false, false,
    Store.empty, true, KOHist.empty⟩

/-- The opponent: `victim` Active, nothing else in play, one card in the deck. -/
def foe : PlayerState := ps [] [.energy .fire] (InPlay.ofBasic victimC) []

/-- A turn-proper state of the player to move `c` against `o`. -/
def tp (c o : PlayerState) : GameState :=
  ⟨c, o, true, false, false, false, none, none, false, false, false⟩

/-- The start for `yan`: `sitter` (no Retreat Cost) Active, `yan` Benched, a Grass Energy in the
deck and two Switch cards in the hand. -/
def y0 : GameState :=
  tp (ps [switchCard, switchCard] [.energy .grass] (InPlay.ofBasic sitterC) [InPlay.ofBasic yanC]) foe

theorem y0_wellFormed : WellFormed y0 := by
  refine ⟨fun _ => ⟨by simp [y0, tp, ps], by simp [y0, tp, ps, foe]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> simp [y0, tp, ps, foe] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem y0_settled : Settled y0 := (GameState.settled_iff _).2 (by decide)

/-- The retreat from `y0`. -/
theorem y0_retreat : ∃ g₁, Move y0 g₁ ∧ g₁.pend = true ∧ g₁.upOwed = [buzz] ∧
    g₁.cur.active.map InPlay.top = some yanC :=
  ⟨_, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl .nil rfl rfl rfl y0_settled rfl rfl, rfl, rfl, rfl⟩

/-- **A retreat that moves `yan` up fires its trigger** (an existential witness): the retreat
raises the event (`pend`), and the next move resolves it: the Grass Energy from the deck is
attached to `yan`, the new Active Pokémon, and the state is `Settled`. -/
theorem retreat_fires_up :
    ∃ g₁ g₂, Move y0 g₁ ∧ g₁.pend = true ∧ Move g₁ g₂ ∧
      g₂.cur.active.map InPlay.top = some yanC ∧
      g₂.cur.active.map InPlay.energy = some [.energy .grass] ∧ Settled g₂ := by
  refine ⟨_, _, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl .nil rfl rfl rfl y0_settled rfl rfl, rfl,
    .trigger ⟨rfl, rfl⟩ rfl (.of_mine (u := [buzz]) (d := []) rfl (.refl _) (.refl _)
      ⟨_, _, .run rfl (.seq (.zone rfl (.attachActive (.take rfl .nil) rfl rfl rfl))
          (.shuffle (List.Perm.refl _))) (.nil _), .nil _, rfl⟩),
    rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

/-- The start for `claw`: `claw` (no Retreat Cost) Active, `sitter` Benched, a Water Energy in the
hand. -/
def w0 : GameState :=
  tp (ps [.energy .water] [] (InPlay.ofBasic clawC) [InPlay.ofBasic sitterC]) foe

theorem w0_wellFormed : WellFormed w0 := by
  refine ⟨fun _ => ⟨by simp [w0, tp, ps], by simp [w0, tp, ps, foe]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> simp [w0, tp, ps, foe] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem w0_settled : Settled w0 := (GameState.settled_iff _).2 (by decide)

/-- **A retreat that moves `claw` down fires its trigger** (an existential witness): the Water
Energy from the hand is attached to `claw`, now on the Bench. (On the Bench "this Pokémon" is one
Benched Pokémon chosen when the trigger resolves, `SelfOp.atS`: here the only one.) -/
theorem retreat_fires_down :
    ∃ g₁ g₂, Move w0 g₁ ∧ g₁.pend = true ∧ Move g₁ g₂ ∧
      g₂.cur.bench.map InPlay.top = [clawC] ∧
      g₂.cur.bench.map InPlay.energy = [[.energy .water]] ∧ g₂.cur.hand = [] ∧ Settled g₂ := by
  refine ⟨_, _, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl .nil rfl rfl rfl w0_settled rfl rfl, rfl,
    .trigger ⟨rfl, rfl⟩ rfl (.of_mine (u := []) (d := [reload]) rfl (.refl _) (.refl _)
      ⟨_, _, .nil _, .run rfl (.zone rfl (.attachBench (b₁ := []) (b₂ := []) (.take rfl .nil) rfl rfl rfl))
          (.nil _), rfl⟩),
    rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

/-- The start for the drawing variant: `sitter` Active, `upper` Benched, a Grass Energy in the deck,
an empty hand. -/
def u0 (opt : Bool) : GameState :=
  tp (ps [] [.energy .grass] (InPlay.ofBasic sitterC) [InPlay.ofBasic (upC opt)]) foe

theorem u0_settled (opt : Bool) : Settled (u0 opt) := by
  cases opt <;> exact (GameState.settled_iff _).2 (by decide)

/-- The state after the retreat from `u0`. -/
def u1 (opt : Bool) : GameState :=
  ({ u0 opt with cur := { (u0 opt).cur with
      active := some ((InPlay.ofBasic (upC opt)).moveUp.noteMove .movedUp .active),
      bench := [] ++ InPlay.noteMove .movedDown .bench { InPlay.ofBasic sitterC with
        energy := [], rot := .none, poisoned := false, burned := false, poisonUp := 0,
        lk := {} } :: [],
      discard := [] ++ (u0 opt).cur.discard, retreated := true } } : GameState).noteBenched

theorem u_retreat (opt : Bool) : Move (u0 opt) (u1 opt) :=
  .retreat (b₁ := []) (b₂ := []) rfl rfl rfl .nil rfl rfl rfl (u0_settled opt) rfl rfl

theorem u1_pending (opt : Bool) : (u1 opt).pend = true ∧ Calm (u1 opt) ∧ ¬ Settled (u1 opt) :=
  ⟨by cases opt <;> rfl, by cases opt <;> exact (GameState.calm_iff _).2 (by decide),
    fun h => by cases opt <;> exact absurd h.2.2.2 (by decide)⟩

/-- **The mandatory trigger cannot be skipped**: every move after the retreat that moved the
mandatory `upper` up gives its owner the card. -/
theorem up_forced : ∀ g₂, Move (u1 false) g₂ → g₂.cur.hand = [.energy .grass] := by
  intro g₂ hm
  rcases hm.batch_of_not_settled (u1_pending false).2.2 with ⟨g₁, l, hb, -⟩ | ⟨-, -, ho⟩
  · exact absurd (u1_pending false).2.1 hb.not_calm
  obtain ⟨u, d, hu, hd, x₁, x₂, h₁, h₂, rfl⟩ := ho.mine_inv rfl
  have eu : (u1 false).upOwed = [up false] := rfl
  have ed : (u1 false).downOwed = [] := rfl
  rw [eu] at hu
  rw [ed] at hd
  rw [List.perm_singleton.1 hu] at h₁
  rw [List.Perm.eq_nil hd] at h₂
  cases h₂.nil_eq
  cases h₁ with
  | decline ho => cases ho
  | run _ hr ht =>
      cases ht.nil_eq
      cases hr with
      | draw h => cases h; rfl
      | drawEmpty h => cases h
      | touchActive he => simp [Effect.touch, Ability.script, AbEff.compile, up] at he
      | touchBench he => simp [Effect.touch, Ability.script, AbEff.compile, up] at he
      | zone hw => simp [Effect.zSide, Ability.script, AbEff.compile, up] at hw

/-- **The optional trigger can be declined** (an existential witness): the owner draws nothing. -/
theorem up_declined :
    ∃ g₂, Move (u1 true) g₂ ∧ g₂.cur.hand = [] ∧ g₂.cur.deck = [.energy .grass] ∧ Settled g₂ :=
  ⟨_, .trigger (u1_pending true).2.1.bothActive (u1_pending true).1
    (.of_mine (u := [up true]) (d := []) rfl (.refl _) (.refl _)
      ⟨_, _, .decline rfl (.nil _), .nil _, rfl⟩), rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

/-- **An attack that switches its own user moves the Pokémon switched in up** (an existential
witness): U-turn moves `yan` up; the next move, before the attack's Knock Out check, resolves its
trigger: the Grass Energy from the deck is attached to `yan`. -/
theorem uturn_fires :
    ∃ g₁ g₂, Move (tp (side (InPlay.ofBasic turnerC) [InPlay.ofBasic yanC])
        (side (InPlay.ofBasic bigC) [])) g₁ ∧ g₁.attacked = true ∧ g₁.pend = true ∧ Move g₁ g₂ ∧
      g₂.cur.active.map InPlay.top = some yanC ∧
      g₂.cur.active.map InPlay.energy = some [.energy .grass] := by
  have hr : Run uturn.script (tp (side (InPlay.ofBasic turnerC) [InPlay.ofBasic yanC])
      (side (InPlay.ofBasic bigC) [])) _ :=
    .seq (.damage (.const 10 _) rfl) (.switch (b₁ := []) (b₂ := []) .own rfl rfl)
  exact ⟨_, _, .attack (atk := uturn) rfl (.head _) (.nil _) rfl rfl rfl rfl
      ((GameState.settled_iff _).2 (by decide))
      hr rfl (fun h => nomatch h) rfl (HitTrig.exists_nil hr rfl) (.nil _) rfl, rfl, rfl,
    .trigger ⟨rfl, rfl⟩ rfl (.of_mine (u := [buzz]) (d := []) rfl (.refl _) (.refl _)
      ⟨_, _, .run rfl (.seq (.zone rfl (.attachActive (.take rfl .nil) rfl rfl rfl))
          (.shuffle (List.Perm.refl _))) (.nil _), .nil _, rfl⟩),
    rfl, rfl⟩

/-- The start for the promotion: the Dusclops-like `dusk` (whose Ability Knocks it Out) Active,
`yan` Benched, a Grass Energy in the deck; the opponent's `big` (30 HP) Active. -/
def p0 : GameState := tp (side (InPlay.ofBasic duskC) [InPlay.ofBasic yanC]) (side (InPlay.ofBasic bigC) [])

theorem p0_wellFormed : WellFormed p0 := by
  refine ⟨fun _ => ⟨by simp [p0, tp, side], by simp [p0, tp, side]⟩, fun p hp => ?_, fun _ hp => by
    simp [p0, tp, side] at hp, .of_b rfl⟩
  simp only [p0, tp, side, List.mem_singleton] at hp
  subst hp; exact ⟨rfl, rfl, rfl, rfl⟩

theorem p0_settled : Settled p0 := (GameState.settled_iff _).2 (by decide)

/-- **A promotion in the owner's own turn fires the trigger** (an existential witness): `dusk` uses
its Ability, which puts 5 counters on the opponent's Active Pokémon and Knocks `dusk` Out; the batch
step inside the Ability's resolution promotes `yan`, which has moved from the Bench to the Active
Spot during its owner's turn, and its trigger resolves before the next step: the Grass Energy from
the deck is attached to `yan`. -/
theorem promotion_fires :
    ∃ g', Move p0 g' ∧ Card.pokemon duskC ∈ g'.cur.discard ∧
      g'.cur.active.map InPlay.top = some yanC ∧
      g'.cur.active.map InPlay.energy = some [.energy .grass] ∧ g'.opp.prizes.length = 1 ∧
      Settled g' := by
  refine ⟨_, .ability (ab := cursed) (.active rfl) (.head _) rfl rfl (fun _ => rfl) trivial rfl
    p0_settled rfl
    (.seq (.choiceL (.prim rfl rfl (.counters 5 rfl)
        (.done (.inl ((GameState.settled_iff _).2 (by decide))))))
      (.prim rfl rfl (.selfDamage 9999 rfl)
        (.step rfl (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide)) (by decide)
            (.pick (b₁ := []) (b₂ := [])) .keep)
          (.trigger rfl ⟨rfl, rfl⟩ rfl (.of_mine (u := [buzz]) (d := []) rfl (.refl _) (.refl _)
              ⟨_, _, .run rfl (.seq (.zone rfl (.attachActive (.take rfl .nil) rfl rfl rfl))
                (.shuffle (List.Perm.refl _))) (.nil _), .nil _, rfl⟩)
            (.done (.inl ((GameState.settled_iff _).2 (by decide))))))))
    rfl rfl, by decide, rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

/-- A Pokémon that has used its "once during your turn" limit is not marked again. -/
theorem _root_.Pokemon.InPlay.noteMove_of_used {ev : TrigEvent} {sp : Spot} {p : InPlay}
    (h : p.used = true) : p.noteMove ev sp = p :=
  InPlay.noteMove_of_not (by simp [InPlay.fires, h])

/-- **Once per turn** (an existential witness): retreat (`yan` moves up and its trigger fires),
then two Switch cards (`yan` down, then up again): after the second Switch nothing is pending, `yan`
is Active with the one Grass Energy of the first trigger, and the state is `Settled`. That no
resolution of the second Switch can mark `yan` is the universal lemma `InPlay.noteMove_of_used`: a
Pokémon that has spent its limit (`InPlay.used`) is not marked. -/
theorem once_per_turn :
    ∃ g₁ g₂ g₃ g₄, Move y0 g₁ ∧ Move g₁ g₂ ∧ Move g₂ g₃ ∧ Move g₃ g₄ ∧
      g₄.cur.active.map InPlay.top = some yanC ∧
      g₄.cur.active.map InPlay.energy = some [.energy .grass] ∧
      g₄.cur.active.map InPlay.used = some true ∧ g₄.pend = false ∧ Settled g₄ := by
  refine ⟨_, _, _, _, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl .nil rfl rfl rfl y0_settled rfl rfl,
    .trigger ⟨rfl, rfl⟩ rfl (.of_mine (u := [buzz]) (d := []) rfl (.refl _) (.refl _)
      ⟨_, _, .run rfl (.seq (.zone rfl (.attachActive (.take rfl .nil) rfl rfl rfl))
          (.shuffle (List.Perm.refl _))) (.nil _), .nil _, rfl⟩),
    .item (l₁ := []) rfl rfl ((GameState.settled_iff _).2 (by decide))
      (.prim rfl rfl (.switch (b₁ := []) (b₂ := []) .own rfl rfl)
        (.done (.inl ((GameState.settled_iff _).2 (by decide))))) rfl rfl rfl rfl,
    .item (l₁ := []) rfl rfl ((GameState.settled_iff _).2 (by decide))
      (.prim rfl rfl (.switch (b₁ := []) (b₂ := []) .own rfl rfl)
        (.done (.inl ((GameState.settled_iff _).2 (by decide))))) rfl rfl rfl rfl,
    rfl, rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

/-- From a `Settled` state, taking the Knock Outs does nothing. -/
theorem _root_.Pokemon.Resolve.eq_of_settled {g g' : GameState} (h : Resolve g g') (hs : Settled g) :
    g' = g := by
  cases h with
  | done => rfl
  | step _ hm => exact absurd hs hm.not_settled
  | trigger _ _ hp => rw [hs.2.2.2] at hp; cases hp

/-- Between turns (after Pokémon Checkup), the player about to move has `sitter` Active at its HP
and `yan` Benched. -/
def k0 : GameState :=
  ⟨ps [] [.energy .grass] { InPlay.ofBasic sitterC with damage := 10 } [InPlay.ofBasic yanC], foe,
    true, false, false, true, none, none, false, false, false⟩

theorem k0_wellFormed : WellFormed k0 := by
  refine ⟨fun _ => ⟨by simp [k0, ps], by simp [k0, ps, foe]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> simp [k0, ps, foe] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem k0_unsettled : ¬ Settled k0 := fun h => absurd ((GameState.settled_iff _).1 h) (by decide)

/-- **A promotion between turns raises nothing**: the model reads Pokémon Checkup as in no player's
turn (a reading, Known gaps of `Pokemon/Rules.lean`). The batch
step promotes `yan` (an existential witness: the result is `Settled`, with `yan` Active), and every
move from `k0` leaves nothing pending (universal). -/
theorem checkup_promotion_quiet :
    (∃ g', Move k0 g' ∧ g'.cur.active.map InPlay.top = some yanC ∧ Settled g') ∧
      ∀ g', Move k0 g' → g'.pend = false := by
  refine ⟨⟨_, Move.knockOuts' (.go (fun h => k0_unsettled (h.settled rfl)) (by decide)
      (.pick (b₁ := []) (b₂ := [])) .keep) rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩,
    fun g' hm => ?_⟩
  rcases hm.batch_of_not_settled k0_unsettled with ⟨g₁, l, hb, -, ht⟩ | ⟨-, hp, -⟩
  · exact ht.zoneOnly.pend.trans (hb.pend_eq_of rfl)
  · exact absurd hp (by decide)

/-- After the player's attack, the opponent's `victim` is at its HP and `yan` is on the opponent's
Bench. -/
def o0 : GameState :=
  ⟨ps [] [] (InPlay.ofBasic sitterC) [],
    ps [] [.energy .grass] { InPlay.ofBasic victimC with damage := 10 } [InPlay.ofBasic yanC],
    true, false, true, false, none, none, false, false, false⟩

theorem o0_wellFormed : WellFormed o0 := by
  refine ⟨fun _ => ⟨by simp [o0, ps], by simp [o0, ps]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> simp [o0, ps] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem o0_unsettled : ¬ Settled o0 := fun h => absurd ((GameState.settled_iff _).1 h) (by decide)

/-- **The opponent's promotion raises nothing**: `yan` moves up in a turn that is not its owner's.
The batch step promotes it (an existential witness), and every move from `o0` leaves nothing pending
(universal). -/
theorem opp_promotion_quiet :
    (∃ g', Move o0 g' ∧ g'.opp.active.map InPlay.top = some yanC ∧ Settled g') ∧
      ∀ g', Move o0 g' → g'.pend = false := by
  have hu : o0.promoUp = false := rfl
  refine ⟨⟨_, .knockOuts (l := []) (.go (fun h => o0_unsettled (h.settled rfl)) (by decide) .keep
      (.pick (b₁ := []) (b₂ := []))) .nil (.nil _), rfl,
      (GameState.settled_iff _).2 (by decide)⟩, fun g' hm => ?_⟩
  rcases hm.batch_of_not_settled o0_unsettled with ⟨g₁, l, hb, -, ht⟩ | ⟨-, hp, -⟩
  · exact ht.zoneOnly.pend.trans (hb.pend_eq_of hu)
  · exact absurd hp (by decide)

/-- "Switch in 1 of your opponent's Benched Pokémon to the Active Spot." -/
def gustCard : Card := .trainer "Gust" .item (.switch .opp)

/-- The player holds the gust Item; the opponent has `victim` Active and `yan` Benched. -/
def q0 : GameState :=
  tp (ps [gustCard] [] (InPlay.ofBasic sitterC) [])
    (ps [] [.energy .grass] (InPlay.ofBasic victimC) [InPlay.ofBasic yanC])

theorem q0_settled : Settled q0 := (GameState.settled_iff _).2 (by decide)

/-- `q0` with the gust Item played (in the discard pile), before its effect. -/
def q1 : GameState :=
  { q0 with cur := { q0.cur with hand := [] ++ [], discard := gustCard :: q0.cur.discard } }

/-- **A gust raises nothing for the opponent's Pokémon it moves up**: the switch is made in the
player's turn, not the opponent's. The Item is a legal move that brings `yan` into the opponent's
Active Spot (an existential witness), and every resolution of its effect leaves nothing pending
(universal). -/
theorem gust_quiet :
    (∃ g', Move q0 g' ∧ g'.opp.active.map InPlay.top = some yanC ∧ Settled g') ∧
      ∀ Y, TRun (.switch .opp) q1 Y → Y.pend = false := by
  refine ⟨⟨_, .item (l₁ := []) (l₂ := []) rfl rfl q0_settled
      (.prim rfl rfl (.switch (b₁ := []) (b₂ := []) .opp rfl rfl)
        (.done (.inl ((GameState.settled_iff _).2 (by decide))))) rfl rfl rfl rfl,
      rfl, (GameState.settled_iff _).2 (by decide)⟩, fun Y h => ?_⟩
  cases h with
  | stop hn => exact absurd rfl hn
  | prim _ _ hr hk =>
      cases hr with
      | switch _ ha hb =>
          have hb' : [InPlay.ofBasic yanC] = _ ++ _ :: _ := hb
          obtain ⟨rfl, rfl, rfl⟩ := one_split hb'
          have ha' : some (InPlay.ofBasic victimC) = some _ := ha
          cases ha'
          rw [hk.eq_of_settled ((GameState.settled_iff _).2 (by decide))]
          rfl
      | switchNone _ hb => cases hb
      | touchActive he => simp [Effect.touch] at he
      | touchBench he => simp [Effect.touch] at he
      | zone hw => simp [Effect.zSide] at hw

/-- A play from the hand changes neither the record nor any mark (no event is raised by putting a
Pokémon into play or evolving it). -/
theorem _root_.Pokemon.PlayFromHand.pend {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : g₁.pend = g.pend := by
  cases h <;> rfl

/-- **Benching a copy raises nothing** (an existential witness, with the universal lemma
`PlayFromHand.pend`): from `y0` with a `yan` card in the hand, playing it onto the Bench beside the
other `yan` leaves nothing pending and the state `Settled`. -/
theorem copy_quiet :
    ∃ g', Move (tp (ps [.pokemon yanC] [] (InPlay.ofBasic sitterC) [InPlay.ofBasic yanC]) foe) g' ∧
      g'.cur.bench.map InPlay.top = [yanC, yanC] ∧ g'.pend = false ∧ Settled g' :=
  ⟨_, .playBasic (l₁ := []) (l₂ := []) rfl rfl (by decide) (by decide) rfl
    ((GameState.settled_iff _).2 (by decide)) rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

end Pokemon.Moved
