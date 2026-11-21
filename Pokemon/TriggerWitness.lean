import Pokemon.Bench
import Pokemon.Terminate

/-!
# Triggered Abilities: witnesses (milestone M8b)

Single legal moves from concrete states, for the two trigger shapes of `TrigEvent`.

* `spikes_fire`: an attack damages a Defending Pokémon whose `damaged` trigger ("put 3 damage
  counters on the Attacking Pokémon", Iron Jugulis sv5-139 and others) brings the attacker to its
  HP: after the attack both Active Pokémon are at their HP, a double Knock Out through a trigger.
* `double_ko_then_draw`: the batch Knock Out step that follows Knocks Out both, both players take a
  Prize card, both promote, and then the Defending Pokémon's `koByAttack` trigger ("draw a card")
  resolves for its owner: a chain of two triggers started by one attack, and a Knock Out trigger
  that draws. With a mandatory trigger every move from there draws (`draw_forced`); with an
  optional one the owner may decline it (`draw_declined`).
* `last_prizes_suddenDeath`: the same attack when each player has one Prize card left: every move
  after the attack ends the game in Sudden Death (both take their last Prize card), and the
  `koByAttack` trigger does not fire, the game being over.
-/

namespace Pokemon.TriggerWitness

open Trainer

/-- Base damage 5, no text. -/
def strike : Attack := ⟨"Strike", [], 5, .skip, false⟩

/-- A 30-HP Basic Pokémon with `strike`. -/
def striker : PokemonCard :=
  ⟨"Striker", .basic, none, 3, .grass, [strike], 1, none, none, .none, false, []⟩

/-- "If this Pokémon is in the Active Spot and is damaged by an attack from your opponent's
Pokémon (even if this Pokémon is Knocked Out), put 3 damage counters on the Attacking Pokémon."
(Iron Jugulis sv5-139, Bruxish sv8-49, Hop's Pincurchin ex me2pt5-68 and Sandslash me6-50 have this
text.) -/
def spikes : Ability := ⟨"Spikes", .triggered .damaged false, some .active, none, .fx (.counters 3)⟩

/-- "If this Pokémon is Knocked Out by damage from an attack from your opponent's Pokémon, draw a
card." (`opt`: "you may".) -/
def lastWord (opt : Bool) : Ability :=
  ⟨"Last Word", .triggered .koByAttack opt, none, none, .fx .draw⟩

/-- A 50-HP Basic Pokémon with both triggers. -/
def spiky (opt : Bool) : PokemonCard :=
  ⟨"Spiky", .basic, none, 5, .grass, [], 1, none, none, .none, false, [spikes, lastWord opt]⟩

/-- The player to move has `striker` Active, the opponent `spiky`; each has `big` on the Bench, a
Grass Energy in the deck, an empty hand and the Prize cards `pz`. -/
def start (opt : Bool) (pz : List Card) : GameState :=
  ⟨side [] pz (InPlay.ofBasic striker) [InPlay.ofBasic big],
    side [] pz (InPlay.ofBasic (spiky opt)) [InPlay.ofBasic big],
    true, false, false, false, none, none, false, false⟩

/-- The state after `strike` and the `spikes` trigger: 5 damage counters on `spiky`, 3 on
`striker`. -/
def hit (opt : Bool) (pz : List Card) : GameState :=
  ⟨{ side [] pz { InPlay.ofBasic striker with damage := 3 } [InPlay.ofBasic big] with gxUsed := false },
    side [] pz { InPlay.ofBasic (spiky opt) with damage := 5 } [InPlay.ofBasic big],
    true, false, true, false, none, none, false, false⟩

/-- Two Prize cards. -/
def two : List Card := [.energy .fire, .energy .water]

/-- One Prize card. -/
def one : List Card := [.energy .fire]

theorem start_settled (opt : Bool) (pz : List Card) (hz : pz = two ∨ pz = one) :
    Settled (start opt pz) := by
  rcases hz with rfl | rfl <;> cases opt <;> decide

/-- **A `damaged` trigger fires and Knocks Out the attacker with the Defending Pokémon.** The
attack does 5 damage to `spiky`; its `spikes` trigger puts 3 damage counters on `striker`; after
the attack both Active Pokémon are at their HP, and the batch Knock Out step must follow. -/
theorem spikes_fire (opt : Bool) (pz : List Card) (hz : pz = two ∨ pz = one) :
    Move (start opt pz) (hit opt pz) ∧ ¬ DamageBounded (hit opt pz) ∧
      (hit opt pz).cur.active.map InPlay.damage = some 3 ∧
      (hit opt pz).opp.active.map InPlay.damage = some 5 := by
  refine ⟨?_, fun hk => ?_, rfl, rfl⟩
  · have hm := Move.attack (g := start opt pz) (atk := strike) rfl (.head _) (.nil _) rfl rfl rfl rfl
      (start_settled opt pz hz) (.seq (.damage (.const 5 _) rfl) (.skip _)) rfl
      (fun h => nomatch h) rfl (l := [spikes]) (.fire rfl (by cases opt <;> exact .refl _))
      (.run rfl (.counters 3 rfl) (.nil _))
    cases opt <;> exact hm
  · have := hk .opp .active _ rfl
    rcases hz with rfl | rfl <;> cases opt <;> exact absurd this (by decide)

/-- The state after the batch Knock Out step from `hit opt two` and the `lastWord` trigger:
both Active Pokémon in the discard piles, each player took one Prize card and promoted `big`, and
the opponent drew the Grass Energy. -/
theorem double_ko_then_draw (opt : Bool) :
    ∃ g', Move (hit opt two) g' ∧ g'.opp.hand = [.energy .grass, .energy .fire] ∧
      g'.cur.prizes = [.energy .water] ∧ g'.opp.prizes = [.energy .water] ∧ g'.winner = none := by
  have hu : ¬ Settled (hit opt two) := fun hs => (spikes_fire opt two (.inl rfl)).2.1 hs.1
  have hw : (hit opt two).koStep.winner = none := by cases opt <;> rfl
  have hb : KOBatch (hit opt two) _ :=
    .go hu hw (ac := some (InPlay.ofBasic big)) (bc := []) (ao := some (InPlay.ofBasic big))
      (bo := []) (by cases opt <;> exact .pick (b₁ := [])) (by cases opt <;> exact .pick (b₁ := []))
  have ht : (hit opt two).batchTrigs ((hit opt two).koStep.withPlay (some (InPlay.ofBasic big)) [] (some (InPlay.ofBasic big)) []) = [lastWord opt] := by
    cases opt <;> rfl
  refine ⟨_, Move.knockOuts (l := [lastWord opt]) hb (ht ▸ List.Perm.refl _)
    (.run rfl (.draw (c := .energy .grass) (d := []) (by cases opt <;> rfl)) (.nil _)),
    ?_, ?_, ?_, ?_⟩ <;>
    cases opt <;> rfl

/-- **A mandatory Knock Out trigger cannot be skipped**: every move from the state after the attack
gives the opponent a card. -/
theorem draw_forced :
    ∀ g', Move (hit false two) g' → g'.opp.hand.length = 2 := by
  intro g' hm
  have hu : ¬ Settled (hit false two) := fun hs => (spikes_fire false two (.inl rfl)).2.1 hs.1
  obtain ⟨g₁, l, hb, hl, hf⟩ := hm.batch_of_not_settled hu
  have hw₁ : g₁.winner = none := by
    obtain ⟨-, -, -, -, pw⟩ := hb.piles
    rw [pw]; rfl
  have ht : (hit false two).batchTrigs g₁ = [lastWord false] := by
    unfold GameState.batchTrigs; rw [hw₁]; rfl
  rw [ht] at hl
  rw [List.perm_singleton.1 hl] at hf
  obtain ⟨-, -, -, -, -, -, -, -, -, -, -, -, -, -⟩ := hb.sides
  have hd : g₁.opp.deck = [.energy .grass] := by rw [hb.sides.2.1]; rfl
  have hh : g₁.opp.hand = [.energy .fire] := by
    obtain ⟨p1, p2, -, -, -⟩ := hb.piles
    cases hb with
    | won _ hk => exact absurd hw₁ hk
    | go _ _ hc ho => rfl
  cases hf with
  | decline ho => cases ho
  | run _ hr ht =>
      cases ht.nil_eq
      cases hr with
      | draw h => show (_ :: g₁.opp.hand).length = 2; rw [hh]; rfl
      | drawEmpty h => rw [show g₁.swap.cur.deck = g₁.opp.deck from rfl, hd] at h; cases h
      | touchActive he => simp [Effect.touch, Ability.script, AbEff.compile, lastWord] at he
      | touchBench he => simp [Effect.touch, Ability.script, AbEff.compile, lastWord] at he
      | zone hw => simp [Effect.zSide, Ability.script, AbEff.compile, lastWord] at hw

/-- **An optional Knock Out trigger may be declined**: from the same state, with the trigger
optional, the batch move that declines it leaves the opponent's hand as the Prize card made it. -/
theorem draw_declined :
    ∃ g', Move (hit true two) g' ∧ g'.opp.hand = [.energy .fire] ∧ g'.winner = none := by
  have hu : ¬ Settled (hit true two) := fun hs => (spikes_fire true two (.inl rfl)).2.1 hs.1
  have hw : (hit true two).koStep.winner = none := rfl
  have hb : KOBatch (hit true two) _ :=
    .go hu hw (ac := some (InPlay.ofBasic big)) (bc := []) (ao := some (InPlay.ofBasic big))
      (bo := []) (.pick (b₁ := [])) (.pick (b₁ := []))
  have ht : (hit true two).batchTrigs ((hit true two).koStep.withPlay (some (InPlay.ofBasic big)) [] (some (InPlay.ofBasic big)) []) = [lastWord true] := rfl
  exact ⟨_, Move.knockOuts (l := [lastWord true]) hb (ht ▸ List.Perm.refl _) (.decline rfl (.nil _)),
    rfl, rfl⟩

/-- **The simultaneous win through a trigger.** With one Prize card left each, the attack and its
`damaged` trigger leave both Active Pokémon at their HP; every move from there is the batch step,
in which both players take their last Prize card: Sudden Death. The `koByAttack` trigger does not
fire (the game is over). -/
theorem last_prizes_suddenDeath (opt : Bool) :
    Move (start opt one) (hit opt one) ∧
      ∀ g', Move (hit opt one) g' → g'.winner = some .suddenDeath ∧ g'.opp.hand = one := by
  refine ⟨(spikes_fire opt one (.inr rfl)).1, fun g' hm => ?_⟩
  have hu : ¬ Settled (hit opt one) := fun hs => (spikes_fire opt one (.inr rfl)).2.1 hs.1
  have e := hm.eq_koStep_of_won hu (by cases opt <;> decide)
  subst e
  cases opt <;> exact ⟨rfl, rfl⟩

end Pokemon.TriggerWitness
