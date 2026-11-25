import Pokemon.Moved
import Pokemon.TriggerWitness
import Pokemon.StaticWitness

/-!
# Move triggers in combination: the opponent's trigger, both players' blocks, a chain (milestone MV7c)

Three witnesses requested by the review of MV7c, each a sequence of legal moves from a `WellFormed`,
`Settled` start. All three are existential: each shows that one play exists and what it yields;
none says anything about every resolution.

* `damaged_ko_promotion_fires`: a promotion during the owner's own turn after the opponent's
  `damaged` trigger Knocks Out the owner's Active Pokémon. The owner attacks; the Defending
  Pokémon's trigger ("put 3 damage counters on the Attacking Pokémon") Knocks the attacker Out;
  the batch step promotes `yan`, which moves from the Bench to the Active Spot in its owner's turn
  and so raises `movedUp`; its trigger fires by the next move.
* `both_orders`: one retreat raises the opponent's `oppBenched` trigger (`strip`, "discard all
  Energy from their new Active Pokémon") and the mover's own `movedUp` trigger (`buzz`, attach a
  Grass Energy from the deck). `Owed` resolves the two players' blocks in either order: the
  player's first (`Owed.mineFirst`) leaves `yan` with no Energy and the Grass Energy in the
  discard pile; the opponent's first (`Owed.oppFirst`) leaves `yan` with the Grass Energy.
* `tool_chain`: the alternation that the termination measure of `Move.unsettled_acc` bounds
  (Prize cards left first, then the record, then `koMeasure`). After the attack of the first
  witness, the batch promotes `fragile`, whose `movedUp` trigger discards the Tools of its owner's
  Active Pokémon, itself: the Cape that raised its HP goes, it is at its HP, the next batch Knocks
  it Out and promotes `yan`, and `yan`'s trigger fires. Trigger, Knock Out batch, promotion,
  trigger: each batch that sets the record takes a Prize card (`GameState.koVal_pos_of_promoUp`).
-/

namespace Pokemon.MovedChain
open Pokemon.Benched Pokemon.Promoted Pokemon.Moved Pokemon.TriggerWitness Pokemon.StaticWitness

/-- "Whenever your opponent switches their Active Pokémon with a Benched Pokémon" (`oppBenched`):
discard all Energy from their new Active Pokémon (a test card). -/
def strip : Ability :=
  ⟨"Strip", .triggered .oppBenched false, none, none, .fx (.discardEnergy .opp .active .energy .all)⟩

def stripperC : PokemonCard :=
  ⟨"Stripper", .basic, none, 10, .fire, [], 1, none, none, .none, false, [strip]⟩

/-- The start of `both_orders`: `sitter` (no Retreat Cost) Active and `yan` Benched, a Grass
Energy in the deck; the opponent has `stripper` Active. -/
def b0 : GameState :=
  tp (ps [] [.energy .grass] (InPlay.ofBasic sitterC) [InPlay.ofBasic yanC])
    (ps [] [.energy .fire] (InPlay.ofBasic stripperC) [])

theorem b0_wellFormed : WellFormed b0 := by
  refine ⟨fun _ => ⟨by simp [b0, tp, ps], by simp [b0, tp, ps]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> simp [b0, tp, ps] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem b0_settled : Settled b0 := (GameState.settled_iff _).2 (by decide)

/-- **One retreat raises both players' triggers, and both orders of the two blocks are available**
(an existential witness: one retreat, and one resolution in each order; nothing is claimed about
every resolution). After the retreat the opponent owes `strip` and the player owes `buzz`. With the
player's block first (`Owed.mineFirst`), `buzz` attaches the Grass Energy to `yan` and `strip` then
discards it: `yan` ends with no Energy and the Grass Energy in the player's discard pile. With the
opponent's block first (`Owed.oppFirst`), `strip` finds no Energy and `buzz` then attaches it:
`yan` ends with the Grass Energy. -/
theorem both_orders :
    ∃ g₁, Move b0 g₁ ∧ g₁.pend = true ∧ g₁.upOwed = [buzz] ∧ g₁.owedTrigs = [strip] ∧
      (∃ g₂, Move g₁ g₂ ∧ g₂.cur.active.map InPlay.top = some yanC ∧
        g₂.cur.active.map InPlay.energy = some [] ∧ g₂.cur.discard = [.energy .grass] ∧
        Settled g₂) ∧
      (∃ g₂, Move g₁ g₂ ∧ g₂.cur.active.map InPlay.top = some yanC ∧
        g₂.cur.active.map InPlay.energy = some [.energy .grass] ∧ g₂.cur.discard = [] ∧
        Settled g₂) := by
  refine ⟨_, .retreat (b₁ := []) (b₂ := []) rfl rfl rfl .nil rfl rfl rfl b0_settled rfl rfl,
    rfl, rfl, rfl,
    ⟨_, .trigger ⟨rfl, rfl⟩ rfl (.mineFirst (u := [buzz]) (d := []) (l := [strip]) (.refl _)
        (.refl _) (.refl _)
        ⟨_, _, .run rfl (.seq (.zone rfl (.attachActive (.take rfl .nil) rfl rfl))
            (.shuffle (List.Perm.refl _))) (.nil _), .nil _, rfl⟩
        (.run rfl (.zone rfl (.discardActive rfl (.take rfl .nil) fun _ h => nomatch h)) (.nil _))),
      rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩,
    ⟨_, .trigger ⟨rfl, rfl⟩ rfl (.oppFirst (u := [buzz]) (d := []) (l := [strip]) (.refl _)
        (.refl _) (.refl _)
        (.run rfl (.zone rfl (.discardActive rfl .nil fun _ h => nomatch h)) (.nil _))
        ⟨_, _, .run rfl (.seq (.zone rfl (.attachActive (.take rfl .nil) rfl rfl))
            (.shuffle (List.Perm.refl _))) (.nil _), .nil _, rfl⟩),
      rfl, rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩⟩

/-- A 100-HP Defending Pokémon with the `damaged` trigger `spikes` ("put 3 damage counters on the
Attacking Pokémon"). -/
def spinyC : PokemonCard :=
  ⟨"Spiny", .basic, none, 10, .grass, [], 1, none, none, .none, false, [spikes]⟩

/-- The opponent: `spiny` Active, three Prize cards. -/
def foe3 : PlayerState :=
  { ps [] [.energy .fire] (InPlay.ofBasic spinyC) [] with
    prizes := [.energy .fire, .energy .fire, .energy .fire] }

/-- The attacker's side: `striker` (30 HP, `strike` for 50) Active, the Bench `b`, a Grass Energy in
the deck. -/
def a0 (b : List InPlay) : GameState :=
  tp (ps [] [.energy .grass] (InPlay.ofBasic striker) b) foe3

theorem a0_wellFormed_yan : WellFormed (a0 [InPlay.ofBasic yanC]) := by
  refine ⟨fun _ => ⟨by simp [a0, tp, ps, foe3], by simp [a0, tp, ps, foe3]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> simp [a0, tp, ps, foe3] at hp <;> subst hp <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem a0_settled_yan : Settled (a0 [InPlay.ofBasic yanC]) :=
  (GameState.settled_iff _).2 (by decide)

/-- **A promotion after the opponent's `damaged` trigger Knocks Out the owner's Active Pokémon fires
the owner's `movedUp` trigger** (an existential witness: one play of three moves). The owner's
`striker` attacks `spiny` for 50; `spiny`'s trigger puts 3 damage counters on `striker`, which is at
its HP; the batch step Knocks it Out (the opponent takes a Prize card) and promotes `yan` in its
owner's turn, which raises `movedUp` (the record is set); the next move resolves `buzz`, which
attaches the Grass Energy from the deck to `yan`. -/
theorem damaged_ko_promotion_fires :
    ∃ g₁ g₂ g₃, Move (a0 [InPlay.ofBasic yanC]) g₁ ∧ g₁.attacked = true ∧
      g₁.cur.active.map InPlay.damage = some 3 ∧ ¬ Calm g₁ ∧
      Move g₁ g₂ ∧ Card.pokemon striker ∈ g₂.cur.discard ∧ g₂.opp.prizes.length = 2 ∧
      g₂.cur.active.map InPlay.top = some yanC ∧ g₂.pend = true ∧ g₂.upOwed = [buzz] ∧
      Move g₂ g₃ ∧ g₃.cur.active.map InPlay.top = some yanC ∧
      g₃.cur.active.map InPlay.energy = some [.energy .grass] ∧ Settled g₃ := by
  refine ⟨_, _, _,
    Move.attack (hlk := rfl) (atk := strike) rfl (.head _) (.nil _) rfl rfl rfl rfl a0_settled_yan
      (.seq (.damage (.const 5 _) rfl) (.skip _)) rfl (fun h => nomatch h) rfl (l := [spikes])
      (.fire (.seq (.hit (b := true) rfl (.damage (.const 5 _) rfl) rfl (fun _ => rfl))
        (.plain rfl (.skip _))) (.refl _))
      (.run rfl (.counters 3 rfl) (.nil _)),
    rfl, rfl, fun h => absurd ((GameState.calm_iff _).1 h) (by decide),
    Move.knockOuts_of_nil (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide))
      (by decide) (.pick (b₁ := []) (b₂ := [])) .keep) (by decide),
    by decide, rfl, rfl, rfl, rfl,
    .trigger ⟨rfl, rfl⟩ rfl (.of_mine (u := [buzz]) (d := []) rfl (.refl _) (.refl _)
      ⟨_, _, .run rfl (.seq (.zone rfl (.attachActive (.take rfl .nil) rfl rfl))
          (.shuffle (List.Perm.refl _))) (.nil _), .nil _, rfl⟩),
    rfl, rfl, (GameState.settled_iff _).2 (by decide)⟩

/-- A `movedUp` trigger that discards the Tools of its owner's Active Pokémon (a test card; "this
Pokémon" in the Active Spot is the owner's Active Pokémon, so it discards its own Tool). -/
def shed : Ability :=
  ⟨"Shed", .triggered .movedUp false, none, none, .fx (.discardTools .own .active)⟩

/-- A 10-HP Basic Pokémon with `shed`. -/
def fragileC : PokemonCard :=
  ⟨"Fragile", .basic, none, 1, .grass, [], 0, none, none, .none, false, [shed]⟩

/-- `fragile` on the Bench with 3 damage counters and the Cape (+50 HP): 60 HP, below it. -/
def caped : InPlay := { InPlay.ofBasic fragileC with damage := 3, tools := [cape] }

theorem a0_wellFormed_chain : WellFormed (a0 [caped, InPlay.ofBasic yanC]) := by
  refine ⟨fun _ => ⟨by simp [a0, tp, ps, foe3], by simp [a0, tp, ps, foe3]⟩, ?_, ?_, .of_b rfl⟩ <;>
    intro p hp <;> simp [a0, tp, ps, foe3] at hp
  rcases hp with rfl | rfl <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem a0_settled_chain : Settled (a0 [caped, InPlay.ofBasic yanC]) :=
  (GameState.settled_iff _).2 (by decide)

/-- **A trigger causes a Knock Out and a second promotion, whose trigger fires** (an existential
witness: one play of five moves; nothing is claimed about every resolution). The attack and the
`spikes` trigger Knock Out `striker` as in `damaged_ko_promotion_fires`; the batch step promotes
`fragile` (first promotion, the record set, one Prize card taken); its `shed` trigger discards the
Cape, so `fragile` (10 HP, 3 counters) is at its HP and the state is not `Calm`; the next batch
Knocks it Out (a second Prize card) and promotes `yan` (second promotion, the record set again);
`yan`'s `buzz` attaches the Grass Energy. Each batch that set the record took a Prize card, which
is what the measure of `Move.unsettled_acc` counts first. -/
theorem tool_chain :
    ∃ g₁ g₂ g₃ g₄ g₅, Move (a0 [caped, InPlay.ofBasic yanC]) g₁ ∧ Move g₁ g₂ ∧ Move g₂ g₃ ∧
      Move g₃ g₄ ∧ Move g₄ g₅ ∧
      g₂.cur.active.map InPlay.top = some fragileC ∧ g₂.pend = true ∧ g₂.opp.prizes.length = 2 ∧
      cape ∈ g₃.cur.discard ∧ g₃.pend = false ∧ ¬ Calm g₃ ∧
      g₄.cur.active.map InPlay.top = some yanC ∧ g₄.pend = true ∧ g₄.opp.prizes.length = 1 ∧
      Card.pokemon fragileC ∈ g₄.cur.discard ∧
      g₅.cur.active.map InPlay.energy = some [.energy .grass] ∧ Settled g₅ := by
  refine ⟨_, _, _, _, _,
    Move.attack (hlk := rfl) (atk := strike) rfl (.head _) (.nil _) rfl rfl rfl rfl
      a0_settled_chain
      (.seq (.damage (.const 5 _) rfl) (.skip _)) rfl (fun h => nomatch h) rfl (l := [spikes])
      (.fire (.seq (.hit (b := true) rfl (.damage (.const 5 _) rfl) rfl (fun _ => rfl))
        (.plain rfl (.skip _))) (.refl _))
      (.run rfl (.counters 3 rfl) (.nil _)),
    Move.knockOuts_of_nil (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide))
      (by decide) (.pick (b₁ := []) (b₂ := [InPlay.ofBasic yanC])) .keep) (by decide),
    .trigger ⟨rfl, rfl⟩ rfl (.of_mine (u := [shed]) (d := []) rfl (.refl _) (.refl _)
      ⟨_, _, .run rfl (.zone rfl (.toolsActive rfl)) (.nil _), .nil _, rfl⟩),
    Move.knockOuts_of_nil (.go (fun h => absurd ((GameState.calm_iff _).1 h) (by decide))
      (by decide) (.pick (b₁ := []) (b₂ := [])) .keep) (by decide),
    .trigger ⟨rfl, rfl⟩ rfl (.of_mine (u := [buzz]) (d := []) rfl (.refl _) (.refl _)
      ⟨_, _, .run rfl (.seq (.zone rfl (.attachActive (.take rfl .nil) rfl rfl))
          (.shuffle (List.Perm.refl _))) (.nil _), .nil _, rfl⟩),
    rfl, rfl, rfl, by decide, rfl, fun h => absurd ((GameState.calm_iff _).1 h) (by decide),
    rfl, rfl, rfl, by decide, rfl, (GameState.settled_iff _).2 (by decide)⟩

end Pokemon.MovedChain
