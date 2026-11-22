import Pokemon.Observe
import Pokemon.Special

/-!
# One observed event: "your opponent's Active Pokémon moves to the Bench during their turn"

Milestone MV5, Part B (survey S18 §B; S17 T3): Magcargo sv5-29, "Whenever your opponent's Active
Pokémon moves to the Bench during their turn, their new Active Pokémon is now Burned."; Mismagius ex
me2-36 (the same in the Active Spot, Confused). The instance of the meta-theorem of
`Pokemon/Observe.lean`: the observation `obsT3` on a move's two (skeleton) end states, and the two
side conditions (every observed trigger is in the trigger fragment; for the store bound, a deck
condition that no such trigger recycles). Everything else is the generic result.

The observation, without Pokémon identity. During the turn proper of one player (`between` false
before and after, the same player to move), the player's new Active Pokémon has the flag
`InPlay.movedUp` (set by a retreat and by `switch .own`), and either the Bench gained a Pokémon with
the old Active Pokémon's cards (`InPlay.sig`: top card, cards under it, Tools; counted with
multiplicity, so an evolution or a promotion after a Knock Out never fires), or the old Active
Pokémon had not moved up this turn, the new one has the same cards and such a Pokémon is on the
Bench (a swap of two copies). Departures (Known gaps): one firing per move however often the
Active Pokémon moved (no printed effect of today's Standard moves the same player's Active Pokémon
twice in one resolution, S18 §B1); a Pokémon that already moved up this turn and is swapped for a
copy fires nothing (missed); an Active Pokémon Knocked Out in mid-effect and replaced by a copy of
itself that moved up earlier in the turn, with a third copy on the Bench, fires (spurious); the
trigger resolves after the whole move, not at the moment of the switch; "that Pokémon" (Team
Rocket's Dugtrio) is not expressible: the fragment has no damage counters on a Benched Pokémon.
-/

namespace Pokemon

/-- The cards of a Pokémon in play: what tells two Pokémon apart without identity. -/
def InPlay.sig (p : InPlay) : PokemonCard × List Card × List Card := (p.top, p.under, p.tools)

/-- Did the player to move's Active Pokémon move to the Bench, from `g` to `g'`? -/
def GameState.activeBenched (g g' : GameState) : Bool :=
  !g.between && !g'.between && g.curIsFirst == g'.curIsFirst &&
    match g.cur.active, g'.cur.active with
    | some a, some a' => a'.movedUp &&
        ((g.cur.bench.map InPlay.sig).count a.sig < (g'.cur.bench.map InPlay.sig).count a.sig ||
          (!a.movedUp && a.sig == a'.sig && (g'.cur.bench.map InPlay.sig).contains a.sig))
    | _, _ => false

/-- The `ev` triggers of a player's Pokémon in play, Active and Benched. -/
def PlayerState.inPlayTrigs (ev : TrigEvent) (s : PlayerState) : List Ability :=
  optTrigs ev s.active ++ s.bench.flatMap (InPlay.trigs ev .bench)

/-- **The observation** of the event: the `oppBenched` triggers of the opponent's Pokémon in play
after the move. -/
def obsT3 (g g' : GameState) : List Ability :=
  if g.activeBenched g' then g'.opp.inPlayTrigs .oppBenched else []

theorem PlayerState.inPlayTrigs_trigOk {ev : TrigEvent} {s : PlayerState} {ab : Ability}
    (h : ab ∈ s.inPlayTrigs ev) : (ab.script ev.place).trigOk = true := by
  rcases List.mem_append.1 h with h | h
  · exact optTrigs_trigOk h
  · obtain ⟨p, _, hp⟩ := List.mem_flatMap.1 h
    exact InPlay.trigOk_of_mem_trigs hp

/-- **Side condition 1**: every observed trigger is in the trigger fragment. -/
theorem obsT3_trigOk : ObsTrigOk .oppBenched obsT3 := by
  intro g g' ab h
  unfold obsT3 at h; split at h
  · exact PlayerState.inPlayTrigs_trigOk h
  · nomatch h

/-- The skeleton keeps every card. -/
theorem GameState.allCards_skel (g : GameState) : g.skel.allCards = g.allCards := by
  have h1 : ∀ o : Option InPlay, optCardList (o.map InPlay.skel) = optCardList o := by
    intro o; cases o <;> rfl
  have h2 : ∀ l : List InPlay, benchCardList (l.map InPlay.skel) = benchCardList l := by
    intro l; induction l with
    | nil => rfl
    | cons p ps ih => simp only [List.map_cons, benchCardList, ih]; rfl
  simp only [GameState.skel, PlayerState.skel, GameState.allCards, PlayerState.allCards, h1, h2]

theorem PlayerState.inPlayTrigs_card {ev : TrigEvent} {g : GameState} {ab : Ability}
    (h : ab ∈ g.opp.inPlayTrigs ev) :
    ∃ c ∈ g.allCards, ab ∈ c.abilities ∧ ab.use.event = some ev := by
  rcases List.mem_append.1 h with h | h
  · exact GameState.optTrigs_card h
  · obtain ⟨p, hp, hm⟩ := List.mem_flatMap.1 h
    obtain ⟨c, hc, hmc, he⟩ := InPlay.trigs_card hm
    exact ⟨c, GameState.mem_allCards_of_opp_bench hp hc, hmc, he⟩

/-- The deck condition for the store bound: no `oppBenched` trigger of a card of the game recycles
(the clause 3 (a) a mid-turn trigger would need in `StoreSafe`). -/
def GameState.T3Quiet (g : GameState) : Prop :=
  ∀ c ∈ g.allCards, ∀ ab ∈ c.abilities, ab.use.event = some .oppBenched →
    (ab.script none).recFilters = []

/-- **Side condition 2**, from the deck condition. -/
theorem obsT3_quiet {g₀ : GameState} (hq : g₀.T3Quiet) :
    ∀ g g₁ ab, g.allCards.Perm g₀.allCards → Move g g₁ → ab ∈ obsGate obsT3 g g₁ →
      (ab.script TrigEvent.oppBenched.place).recFilters = [] := by
  intro g g₁ ab hp hm h
  have h' := obsGate_sub h
  unfold obsT3 at h'; split at h'
  · obtain ⟨c, hc, hmc, he⟩ := PlayerState.inPlayTrigs_card h'
    rw [GameState.allCards_skel] at hc
    exact hq c (hp.mem_iff.1 (hm.perm.mem_iff.1 hc)) ab hmc he
  · nomatch h'

/-! ## The generic results, instantiated -/

theorem T3.finite {g₀ : GameState} (hF : g₀.Fit (Enum.bound g₀.allCards)) :
    (∃ L : List GameState, ∀ g, OReach .oppBenched obsT3 g₀ g → g.clamp (Enum.bound g₀.allCards) ∈ L) ∧
      ∀ g₁ g₂, OReach .oppBenched obsT3 g₀ g₁ →
        g₁.clamp (Enum.bound g₀.allCards) = g₂.clamp (Enum.bound g₀.allCards) →
        (∀ g₁', OMove .oppBenched obsT3 g₁ g₁' → ∃ g₂', OMove .oppBenched obsT3 g₂ g₂' ∧
            g₁'.clamp (Enum.bound g₀.allCards) = g₂'.clamp (Enum.bound g₀.allCards)) ∧
        (∀ g₂', OMove .oppBenched obsT3 g₂ g₂' → ∃ g₁', OMove .oppBenched obsT3 g₁ g₁' ∧
            g₂'.clamp (Enum.bound g₀.allCards) = g₁'.clamp (Enum.bound g₀.allCards)) :=
  OReach.finite hF

theorem T3.boundedStores {g₀ g : GameState} (hF : g₀.StoreSafe) (hq : g₀.T3Quiet)
    (h : OReach .oppBenched obsT3 g₀ g) : g.BoundedStores (StoreSafe.storeBound g₀) :=
  StoreSafe.oreach_boundedStores hF h (obsT3_quiet hq)

theorem T3.exists_move (g : GameState) : ∃ g', OMove .oppBenched obsT3 g g' :=
  OMove.exists_move obsT3_trigOk g

/-! ## Witnesses -/

namespace T3

open Trainer

/-- "Lava Zone" (Magcargo sv5-29): "… their new Active Pokémon is now Burned." Mandatory. -/
def lavaZone : Ability := ⟨"Lava Zone", .triggered .oppBenched false, none, none, .fx (.inflict .burned)⟩

def magcargo : PokemonCard := ⟨"Magcargo", .stage1, some "Slugma", 12, .fire, [], 3, none, none,
  .none, false, [lavaZone]⟩

/-- A Basic Pokémon with no Retreat Cost. -/
def runner : PokemonCard := ⟨"Runner", .basic, none, 10, .grass, [], 0, none, none, .none, false, []⟩

def sitter : PokemonCard := { runner with name := "Sitter" }

/-- "Switch your Active Pokémon with 1 of your Benched Pokémon." -/
def switchCard : Card := .trainer "Switch" .item (.switch .own)

/-- The player to move has `runner` Active, `sitter` on the Bench and Switch in hand; the opponent
has Magcargo Active. -/
def s0 : GameState :=
  ⟨side [switchCard, .energy .grass] [.energy .grass] (InPlay.ofBasic runner) [InPlay.ofBasic sitter],
    side [] [.energy .grass] (InPlay.ofBasic magcargo) [], true, false, false, false, none, none,
    false, false⟩

theorem s0_settled : Settled s0 := (GameState.settled_iff _).2 (by decide)

theorem s0_wellFormed : WellFormed s0 := by
  refine ⟨fun _ => ⟨by simp [s0, side], by simp [s0, side]⟩, ?_, ?_⟩
  · intro p hp
    simp only [s0, side, List.mem_singleton] at hp
    subst hp
    exact ⟨rfl, rfl, rfl, rfl⟩
  · intro p hp; cases hp

/-- The state after `runner` retreats (no Retreat Cost), before any trigger. -/
def s0r : GameState :=
  { s0 with cur := { s0.cur with
      active := some (InPlay.moveUp (InPlay.ofBasic sitter)),
      bench := [{ (InPlay.ofBasic runner) with
        energy := [], rot := .none, poisoned := false, burned := false, poisonUp := 0, lk := {} }],
      retreated := true } }

theorem s0_s0r : Move s0 s0r :=
  .retreat (b₁ := []) (b₂ := []) (paid := []) (rest := []) rfl rfl rfl .nil rfl rfl rfl s0_settled
    rfl rfl

/-- **Witness: a retreat fires the trigger.** The retreat puts `runner` on the Bench and `sitter` in
the Active Spot; Lava Zone burns `sitter`. -/
theorem retreat_fires : ∃ g', OMove .oppBenched obsT3 s0 g' ∧
    g'.cur.active = some { (InPlay.moveUp (InPlay.ofBasic sitter)) with burned := true } :=
  ⟨_, .mk s0_s0r (l := [lavaZone]) (.of_eq (by decide)) (.run rfl (.inflict .burned rfl) (.nil _)),
    rfl⟩

/-- The state after Switch is played, before any trigger. -/
def s1 : GameState :=
  { s0 with cur := { s0.cur with
      hand := [.energy .grass], discard := [switchCard],
      active := some (InPlay.moveUp (InPlay.ofBasic sitter)),
      bench := [(InPlay.unlock (InPlay.cure (InPlay.ofBasic runner)))] } }

theorem s0_s1 : Move s0 s1 :=
  .item (l₁ := []) (l₂ := [.energy .grass]) (n := "Switch") rfl rfl s0_settled
    (.prim rfl rfl (.switch (b₁ := []) (b₂ := []) .own rfl rfl)
      (.done (.inl ((GameState.settled_iff _).2 (by decide)))))
    rfl rfl rfl rfl

/-- **Witness: a `switch` inside an Item's effect fires the trigger**, after the Item resolves. -/
theorem switch_fires : ∃ g', OMove .oppBenched obsT3 s0 g' ∧
    g'.cur.active = some { (InPlay.moveUp (InPlay.ofBasic sitter)) with burned := true } :=
  ⟨_, .mk s0_s1 (l := [lavaZone]) (.of_eq (by decide)) (.run rfl (.inflict .burned rfl) (.nil _)), rfl⟩

/-- The state after the turn's Energy attachment to `runner`. -/
def s0a : GameState :=
  { s0 with cur := { s0.cur with
      hand := [switchCard], energyAttached := true,
      active := some { (InPlay.ofBasic runner) with energy := [.energy .grass] } } }

theorem s0_s0a : Move s0 s0a :=
  .attach (l₁ := [switchCard]) (l₂ := []) rfl rfl rfl rfl s0_settled rfl

/-- **Witness: nothing fires on an Energy attachment**: the Active Pokémon did not move. The
observation is empty, so the observed move is the attachment itself. -/
theorem attach_quiet : ∃ g', Move s0 g' ∧ obsGate obsT3 s0 g' = [] ∧ OMove .oppBenched obsT3 s0 g' :=
  ⟨s0a, s0_s0a, by decide, .mk s0_s0a (by rw [show obsGate obsT3 s0 s0a = [] by decide]) (.nil _)⟩

/-- **Witness: the trigger is mandatory**: after the retreat, declining Lava Zone is not a
resolution; every observed move leaves the new Active Pokémon Burned. -/
theorem retreat_burns {g' : GameState} {l : List Ability} (hl : l.Perm [lavaZone])
    (hf : Fire .oppBenched l s0r g') : g'.cur.active.map InPlay.burned = some true := by
  rw [List.perm_singleton.1 hl] at hf
  cases hf with
  | run _ hr ht =>
      rw [ht.nil_eq]
      cases hr with
      | inflict c h => cases h; rfl
      | touchActive he _ => simp [lavaZone, Ability.script, AbEff.compile, Effect.touch] at he
      | touchBench he _ => simp [lavaZone, Ability.script, AbEff.compile, Effect.touch] at he
      | zone hw _ => simp [lavaZone, Ability.script, AbEff.compile, Effect.zSide] at hw
  | decline ho _ => exact absurd ho (by decide)

end T3

end Pokemon
