import Pokemon.StoreSafe
import Pokemon.IfDo

/-!
# Checks on imported cards

Hand-written (not generated). The importer (`tools/importer/`) writes printed Standard cards as
terms of the model's `Card` type in `PokemonCards/Standard/Part*.lean`. This file gives the
decidable checks those files prove of every card, and the lemmas that turn them into the
statements the model's theorems use. Every check is stated with the model's own predicates
(`Card.attacks` and `Card.abilities`, which since milestone M5 include what a Pokémon Tool gives;
`Card.loopFree`, `Card.abilitySafe`, `Card.stadiumSafe`, `Card.freeRec`, `Card.allRec`,
`Card.wAmt`, `Card.alAmt`); nothing here redefines a clause.

* `Card.importOk`: every attack the card has or gives is well formed (`Attack.wf`, a premise of
  `Move.attack`); a Trainer's effect (an Item's or Supporter's, or since milestone M5 a Stadium's)
  is `hitFree` and `benchHitFree` (premises of `Move.item`, `Move.supporter` and
  `Move.stadiumUse`); every script of every Ability the card has or gives is `hitFree` and
  `benchHitFree` (premises of `Move.ability` and `Move.onPlay`); the card satisfies clause 1 of
  `StoreSafe` (`Card.loopFree`), the per-card part of clause 2 (`GXOnly`: an attack that is not a
  GX attack writes no rest-of-game bonus or reduction), clause 4 (`Card.abilitySafe`) and clause 5
  (`Card.stadiumSafe`: a Stadium's effect writes no rest-of-game bonus or reduction).
* `recSafeB C`: clause 3 of `StoreSafe` (`RecycleSafe`) for every game whose cards all come from `C`,
  as one Boolean over the recycling filters of `C` (`Card.freeRec`, which counts "as often as you
  like" Abilities with Items and Supporters and, since milestone M5, not Stadiums, whose uses are
  bounded per turn; and `Card.allRec`) and the modifier writers of `C`.
* `storeSafe_of`: from both, every game whose cards all come from `C` is `StoreSafe` (all five
  clauses), so `StoreSafe.xfinite` applies to it.
* `nodupFp`: a check that a list of cards has no two equal terms, cheap enough for the kernel on
  the whole imported list (`nodup_of_nodupFp`).

Since milestone M6 a card may carry static effects (`Card.statics`: a static Ability's, a Tool's
static text, a Stadium's static text). `StoreSafe` has no clause about them and `StoreSafe.xfinite`
holds with the clamp at `Enum.bound`, which bounds every derived HP and every static damage
reduction; `Card.hasStatic` lists the cards by kind (a static damage reduction is `Static.isReduce`,
a nonzero `Static.reduceUnit` of the model), `hpOf_le_of` bounds derived HP over a pool, and
`sReduce_le_of` bounds the static damage reduction in force over a pool.

The tame-deck theorem `Reach.finite` does not apply to imported decks in general: its premise
`GameState.Fit` asks every card to be `Card.tame` (no `drain`, no stored damage reduction), and the
imported pool has cards with `drain` attacks and with stored damage reductions. Its new clause
`ReduceLe` (Resistance plus `sReduceBound`) holds at `Enum.bound` for every game by the definition
of the bound (`reduceLe_bound`), so static reductions do not stand in the way; tameness does.
For imported decks the theorem that applies is `StoreSafe.xfinite`, through `storeSafe_of`.

Triggered Abilities (milestone M8b, importer 0.6.0): `Card.trigsOn`, `Card.hasTrig` list a card's
triggers by event (`AbilityUse.event`); `Card.trigsOk` checks that each has no printed condition and an
effect of the trigger fragment at its event's place, so that `Ability.trigOn` is the test of its place
alone (`trigOn_of_trigsOk`); `Card.trigLingers` and `Card.trigRecycles` find triggers that write a
lingering modifier or return a card from a discard pile. The five clauses of `StoreSafe` need no new
check: a trigger is an Ability, so its scripts are among those `Card.loopFree`, `Card.abilitySafe` and
`Card.allRec` (clause 3 (b)) already read.

These are facts about the Lean terms; whether a term says what its printed card says is the
importer's claim, checked by eye in survey S11, not by Lean.
-/

namespace Pokemon

/-- Every attack the card has or (a Tool, milestone M5) gives is well formed (`Attack.wf`). -/
def Card.attacksWf (c : Card) : Bool := c.attacks.all Attack.wf

/-- A Trainer's effect (an Item's or a Supporter's when played, a Stadium's when used) has no
attack damage step and no attack damage to the Bench. -/
def Card.trainerOk : Card → Bool
  | .trainer _ _ e _ => e.hitFree && e.benchHitFree
  | _ => true

/-- The per-card part of `GXOnly`: an attack the card has or gives that is not a GX attack writes no
rest-of-game damage bonus or reduction. -/
def Card.gxOk (c : Card) : Bool := c.attacks.all fun a => a.gx || a.effect.amtAt .always == 0

/-- Every script of every Ability the card has or gives has no attack damage step and no attack
damage to the Bench (`Move.ability` and `Move.onPlay` require both of the script they resolve). -/
def Card.abilitiesOk (c : Card) : Bool :=
  c.abilities.all fun ab => ab.scripts.all fun e => e.hitFree && e.benchHitFree

/-- The per-card checks every imported card passes. -/
def Card.importOk (c : Card) : Bool :=
  c.attacksWf && c.trainerOk && c.abilitiesOk && c.loopFree && c.gxOk && c.abilitySafe &&
    c.stadiumSafe

/-- Any lingering modifier (bonus, reduction, prevention or lock) anywhere in the effect. -/
def Effect.lingers : Effect → Bool
  | .linger _ _ _ => true
  | .ite _ a b => a.lingers || b.lingers
  | .seq a b => a.lingers || b.lingers
  | .choice a b => a.lingers || b.lingers
  | .iter a => a.lingers
  | _ => false

/-- A Trainer card's effect (an Item's or Supporter's when played, a Stadium's when used), `skip`
for other cards. -/
def Card.trainerEffect : Card → Effect
  | .trainer _ _ e _ => e
  | _ => .skip

/-- The card writes a lingering damage bonus or reduction (`Effect.writes`) in an attack or an
Ability it has or gives (any script), or as a Trainer. -/
def Card.writesAmt (c : Card) : Bool :=
  (c.attacks.any fun a => a.effect.writes) || (c.abilities.any fun ab => ab.scripts.any Effect.writes) ||
    c.trainerEffect.writes

/-- The card writes any lingering modifier (in an attack or Ability it has or gives, or as a
Trainer). -/
def Card.lingers (c : Card) : Bool :=
  (c.attacks.any fun a => a.effect.lingers) || (c.abilities.any fun ab => ab.scripts.any Effect.lingers) ||
    c.trainerEffect.lingers

/-- An Ability the card has or gives writes a lingering damage bonus or reduction (in any script). -/
def Card.abilityWrites (c : Card) : Bool := c.abilities.any fun ab => ab.scripts.any Effect.writes

/-- An Ability the card has or gives writes any lingering modifier (in any of its scripts). -/
def Card.abilityLingers (c : Card) : Bool := c.abilities.any fun ab => ab.scripts.any Effect.lingers

/-- The card has or gives an "as often as you like" Ability. -/
def Card.hasUnlimited (c : Card) : Bool := c.abilities.any fun ab => ab.use == .unlimited

/-- The card has or gives an Ability that can return a card from a discard pile
(`Effect.recFilters` of one of its scripts). -/
def Card.abilityRecycles (c : Card) : Bool :=
  c.abilities.any fun ab => ab.scripts.any fun e => !e.recFilters.isEmpty

/-! ### Triggered Abilities (milestone M8b) -/

/-- The triggered Abilities on the event `ev` that the card has or (a Tool) gives (`AbilityUse.event`). -/
def Card.trigsOn (ev : TrigEvent) (c : Card) : List Ability :=
  c.abilities.filter fun ab => ab.use.event == some ev

/-- The card has or gives a triggered Ability on `ev`. -/
def Card.hasTrig (ev : TrigEvent) (c : Card) : Bool := !(c.trigsOn ev).isEmpty

/-- Every triggered Ability the card has or gives has no printed condition (`cond = none`) and resolves an
effect of the trigger fragment at its event's place (`Effect.trigOk` of `Ability.script ab ev.place`), and
(milestone MV7) on an event that can fire before the attack (`TrigEvent.late = false`) recycles nothing: the
conditions under which `Ability.trigOn` holds wherever the Ability's place allows. -/
def Card.trigsOk (c : Card) : Bool :=
  c.abilities.all fun ab =>
    match ab.use.event with
    | some ev => ab.cond.isNone && (ab.script ev.place).trigOk &&
        (ev.late || (ab.script ev.place).recFilters.isEmpty)
    | none => true

/-- A triggered Ability the card has or gives writes a lingering modifier (bonus, reduction, prevention or
lock; `Effect.lingers`) in one of its scripts. -/
def Card.trigLingers (c : Card) : Bool :=
  c.abilities.any fun ab => ab.use.event.isSome && ab.scripts.any Effect.lingers

/-- A triggered Ability the card has or gives can return a card from a discard pile (`Effect.recFilters` of
one of its scripts; these filters are among `Card.allRec`, which clause 3 (b) of `StoreSafe` constrains). -/
def Card.trigRecycles (c : Card) : Bool :=
  c.abilities.any fun ab => ab.use.event.isSome && ab.scripts.any fun e => !e.recFilters.isEmpty

/-! ### Static effects (milestone M6) -/

/-- A static HP change ("+N HP", "−N HP", "+N HP for each Energy"). -/
def Static.isHp (s : Static) : Bool :=
  match s.eff with
  | .hpPlus _ => true
  | .hpMinus _ => true
  | _ => false

/-- A static damage bonus. -/
def Static.isBonus (s : Static) : Bool :=
  match s.eff with
  | .bonus _ _ => true
  | _ => false

/-- A static damage reduction: a static effect whose reduction constant (`Static.reduceUnit`, the
model's) is nonzero, that is one that counts in the model's bound `sReduceBound`. -/
def Static.isReduce (s : Static) : Bool := s.reduceUnit != 0

theorem Static.isReduce_iff (s : Static) : s.isReduce = true ↔ 0 < s.reduceUnit := by
  unfold Static.isReduce
  cases s.reduceUnit with
  | zero => decide
  | succ n => exact ⟨fun _ => Nat.succ_pos n, fun _ => rfl⟩

/-- The reduction units of a card's static effects (`Static.reduceUnit`), the summand of the model's
`sReduceBound`. -/
def Card.reduceGain (c : Card) : Nat := c.gain Static.reduceUnit

/-- A static Retreat Cost change (more, less, or since milestone MV8 none: `SEff.noRetreat`). -/
def Static.isRetreat (s : Static) : Bool :=
  match s.eff with
  | .retreatPlus _ => true
  | .retreatMinus _ => true
  | .noRetreat => true
  | _ => false

/-- The card has a static effect of the kind `k` (`Card.statics`, the model's). -/
def Card.hasStatic (k : Static → Bool) (c : Card) : Bool := c.statics.any k

/-- The printed HP of a Pokémon card, 0 for other cards. -/
def Card.printedHp : Card → Nat
  | .pokemon p => p.hp
  | _ => 0

/-- The printed name (Basic Energy cards are labelled by kind only; a Special Energy card, imported since
importer 0.15.0, by its name). -/
def Card.label : Card → String
  | .pokemon p => p.name
  | .trainer n _ _ _ => n
  | .tool n _ => n
  | .energy (.special n _ _) => n
  | .energy (.basic _) => "Basic Energy"

end Pokemon

namespace PokemonCards

open Pokemon

/-- Clause 3 of `StoreSafe` for the pool `C`, decidable by evaluation: no recycling filter of an Item
or Supporter or of an "as often as you like" Ability of `C` (`Card.freeRec`; since milestone M5 a
Stadium's effect is not a free recycler) admits a card of `C` that is an Item writing a bonus or
reduction (`Card.wAmt`), and no recycling filter of any effect of `C`, attacks, Abilities and
Stadium effects included (`Card.allRec`), admits a card of `C` that writes a rest-of-game bonus or
reduction when played (`Card.alAmt`). -/
def recSafeB (C : List Card) : Bool :=
  ((C.flatMap Card.freeRec).all fun f => (C.filter fun y => y.wAmt != 0).all fun y => !f.eval y) &&
  ((C.flatMap Card.allRec).all fun f => (C.filter fun y => y.alAmt != 0).all fun y => !f.eval y)

/-- `recSafeB C` gives `RecycleSafe` for every game whose cards all come from `C`. -/
theorem recycleSafe_of {C : List Card} (h : recSafeB C = true) (g : GameState)
    (hg : ∀ x ∈ g.allCards, x ∈ C) : g.RecycleSafe := by
  unfold recSafeB at h
  rw [Bool.and_eq_true] at h
  obtain ⟨h1, h2⟩ := h
  refine ⟨fun x hx f hf y hy hfy => ?_, fun x hx f hf y hy hfy => ?_⟩
  · cases hw : y.wAmt with
    | zero => rfl
    | succ n =>
      have hf' : f ∈ C.flatMap Card.freeRec := List.mem_flatMap.2 ⟨x, hg x hx, hf⟩
      have hy' : y ∈ C.filter (fun y => y.wAmt != 0) := List.mem_filter.2 ⟨hg y hy, by simp [hw]⟩
      have := List.all_eq_true.1 (List.all_eq_true.1 h1 f hf') y hy'
      rw [hfy] at this
      exact absurd this (by decide)
  · cases hw : y.alAmt with
    | zero => rfl
    | succ n =>
      have hf' : f ∈ C.flatMap Card.allRec := List.mem_flatMap.2 ⟨x, hg x hx, hf⟩
      have hy' : y ∈ C.filter (fun y => y.alAmt != 0) := List.mem_filter.2 ⟨hg y hy, by simp [hw]⟩
      have := List.all_eq_true.1 (List.all_eq_true.1 h2 f hf') y hy'
      rw [hfy] at this
      exact absurd this (by decide)

theorem importOk_parts {c : Card} (h : c.importOk = true) :
    c.attacksWf = true ∧ c.trainerOk = true ∧ c.abilitiesOk = true ∧ c.loopFree = true ∧
      c.gxOk = true ∧ c.abilitySafe = true ∧ c.stadiumSafe = true := by
  simp only [Card.importOk, Bool.and_eq_true] at h
  obtain ⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩ := h
  exact ⟨h1, h2, h3, h4, h5, h6, h7⟩

/-- Every attack a card of a checked pool has or (a Tool) gives is well formed (`Attack.wf`, a
premise of `Move.attack` and `Move.attackConfused`). -/
theorem attacks_wf_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ a ∈ c.attacks, a.wf = true :=
  fun c hc a ha => List.all_eq_true.1 (importOk_parts (List.all_eq_true.1 h c hc)).1 a ha

theorem trainers_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ n k e ss, c = .trainer n k e ss → e.hitFree = true ∧ e.benchHitFree = true := by
  intro c hc n k e ss he
  have := (importOk_parts (List.all_eq_true.1 h c hc)).2.1
  subst he
  simpa only [Card.trainerOk, Bool.and_eq_true] using this

theorem loopFree_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, c.loopFree = true :=
  fun c hc => (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.1

/-- The per-card part of clause 2 for every card of a checked pool, over the attacks each card has
or (a Tool) gives (`Card.attacks`, as `GameState.GXOnly` reads them). -/
theorem gxOnly_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ atk ∈ c.attacks, atk.gx = false → atk.effect.amtAt .always = 0 := by
  intro c hc atk ha hgx
  have := (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.2.1
  have h2 := List.all_eq_true.1 this atk ha
  rw [hgx, Bool.false_or] at h2
  exact Nat.eq_of_beq_eq_true h2

/-- Clause 4 for every card of a checked pool. -/
theorem abilitySafe_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, c.abilitySafe = true :=
  fun c hc => (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.2.2.1

/-- Clause 5 for every card of a checked pool. -/
theorem stadiumSafe_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, c.stadiumSafe = true :=
  fun c hc => (importOk_parts (List.all_eq_true.1 h c hc)).2.2.2.2.2.2

/-- Every script of every Ability a card of a checked pool has or (a Tool) gives has no attack
damage, on the Active Pokémon or the Bench (the premises `hnd` and `hbh` of `Move.ability` and
`Move.onPlay`). -/
theorem abilities_of {C : List Card} (h : C.all Card.importOk = true) :
    ∀ c ∈ C, ∀ ab ∈ c.abilities, ∀ e ∈ ab.scripts, e.hitFree = true ∧ e.benchHitFree = true := by
  intro c hc ab hab e he
  have := (importOk_parts (List.all_eq_true.1 h c hc)).2.2.1
  have h2 := List.all_eq_true.1 (List.all_eq_true.1 this ab hab) e he
  simpa only [Bool.and_eq_true] using h2

/-! ### Distinct terms

`List.Nodup` of a thousand `Card` terms by `decide` compares every pair with the derived
`DecidableEq`, which the kernel evaluates slowly and with much memory. `nodupFp` first compares a
cheap fingerprint (`cardFp`, a natural number from HP, retreat, type, Weakness and each attack's
damage and cost length), and compares the terms only when the fingerprints agree; `nodupFp_append`
and `crossOk_append_left` let a long list be checked block by block. The fingerprint is used only
to skip comparisons: whatever it is, `nodupFp l = true` gives `l.Nodup`. -/

/-- The position of a type in `EType`'s declaration. -/
def etypeIdx : EType → Nat
  | .grass => 0 | .fire => 1 | .water => 2 | .lightning => 3 | .psychic => 4 | .fighting => 5
  | .darkness => 6 | .metal => 7 | .fairy => 8 | .dragon => 9 | .colorless => 10

/-- A fingerprint of a card; equal cards have equal fingerprints. -/
def cardFp : Card → Nat
  | .pokemon p => (p.attacks.foldl (fun h a => (h * 64 + a.damage) * 8 + a.cost.length)
      (((p.hp * 8 + p.retreat) * 16 + etypeIdx p.type) * 16 +
        (match p.weakness with | some t => etypeIdx t + 1 | none => 0))) * 3
  | .energy _ => 1
  | .trainer _ _ _ _ => 2
  | .tool _ _ => 4

/-- No card of `l₁` is the same term as a card of `l₂`. -/
def crossOk (l₁ l₂ : List Card) : Bool :=
  l₁.all fun a => l₂.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)

/-- No two entries of the list are the same term. -/
def nodupFp : List Card → Bool
  | [] => true
  | a :: l => crossOk [a] l && nodupFp l

theorem crossOk_append_left (l₁ l₂ l₃ : List Card) :
    crossOk (l₁ ++ l₂) l₃ = (crossOk l₁ l₃ && crossOk l₂ l₃) := by
  simp only [crossOk, List.all_append]

theorem crossOk_cons_left (a : Card) (l₁ l₃ : List Card) :
    crossOk (a :: l₁) l₃ = (crossOk [a] l₃ && crossOk l₁ l₃) := by
  simp only [crossOk, List.all_cons, List.all_nil, Bool.and_true]

theorem crossOk_append_right (l₁ l₂ l₃ : List Card) :
    crossOk l₁ (l₂ ++ l₃) = (crossOk l₁ l₂ && crossOk l₁ l₃) := by
  induction l₁ with
  | nil => rfl
  | cons a l ih =>
    rw [crossOk_cons_left, ih, crossOk_cons_left a l l₂, crossOk_cons_left a l l₃]
    simp only [crossOk, List.all_cons, List.all_nil, Bool.and_true, List.all_append]
    cases (l₂.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)) <;>
    cases (l₃.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)) <;>
    cases (l.all fun a => l₂.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)) <;>
    cases (l.all fun a => l₃.all fun b => !decide (cardFp a = cardFp b) || !decide (a = b)) <;> rfl

theorem nodupFp_append (l₁ l₂ : List Card) :
    nodupFp (l₁ ++ l₂) = (nodupFp l₁ && nodupFp l₂ && crossOk l₁ l₂) := by
  induction l₁ with
  | nil => simp [nodupFp, crossOk]
  | cons a l ih =>
    simp only [List.cons_append, nodupFp, ih, crossOk_append_right, crossOk_cons_left a l l₂]
    cases crossOk [a] l <;> cases crossOk [a] l₂ <;> cases nodupFp l <;> cases nodupFp l₂ <;>
      cases crossOk l l₂ <;> rfl

/-- `nodupFp` decides `List.Nodup` (in one direction, which is all the generated files use). -/
theorem nodup_of_nodupFp {l : List Card} (h : nodupFp l = true) : l.Nodup := by
  induction l with
  | nil => exact List.nodup_nil
  | cons a l ih =>
    rw [nodupFp, Bool.and_eq_true] at h
    refine List.nodup_cons.2 ⟨fun hm => ?_, ih h.2⟩
    have := List.all_eq_true.1 (List.all_eq_true.1 h.1 a (List.mem_singleton_self a)) a hm
    rw [decide_eq_true rfl, decide_eq_true rfl] at this
    exact absurd this (by decide)

/-! ### Static effects over a pool (milestone M6) -/

theorem csum_le_mul {f : Card → Nat} {G : Nat} :
    ∀ {C : List Card}, (∀ c ∈ C, f c ≤ G) → csum f C ≤ C.length * G
  | [], _ => Nat.zero_le _
  | c :: cs, h => by
      have ih := csum_le_mul (C := cs) fun x hx => h x (.tail _ hx)
      have hc := h c (.head _)
      rw [csum_cons, List.length_cons, Nat.succ_mul]
      omega

/-- **Derived HP over a pool.** If every card of `C` has printed HP at most `M` and static HP units
(`Card.hpGain`) at most `G`, then in every game of at most `N` cards all from `C`, every Pokémon in play
has derived HP at most `M + 2 (N + 1) (N G)`: the model's `hpBound` (`GameState.hpOf_le_hpBound`), bounded
with `M`, `G` and `N`. -/
theorem hpOf_le_of {C : List Card} {M G N : Nat} (hm : ∀ c ∈ C, c.printedHp ≤ M)
    (hgn : ∀ c ∈ C, c.hpGain ≤ G) {g : GameState} (hg : ∀ x ∈ g.allCards, x ∈ C)
    (hn : g.allCards.length ≤ N) {w : Whose} {sp : Spot} {p : InPlay} (hp : g.In w sp p) :
    g.hpOf w sp p ≤ M + 2 * (N + 1) * (N * G) := by
  have h1 := g.hpOf_le_hpBound hp
  have h2 : maxHp g.allCards ≤ M :=
    maxHp_le fun q hq => by simpa only [Card.printedHp] using hm _ (hg _ hq)
  have h3 : csum Card.hpGain g.allCards ≤ g.allCards.length * G :=
    csum_le_mul fun c hc => hgn c (hg c hc)
  have h4 : 2 * (g.allCards.length + 1) * csum Card.hpGain g.allCards ≤ 2 * (N + 1) * (N * G) :=
    Nat.mul_le_mul (Nat.mul_le_mul_left 2 (Nat.succ_le_succ hn))
      (Nat.le_trans h3 (Nat.mul_le_mul_right G hn))
  unfold hpBound at h1
  omega

/-- **Static damage reduction over a pool.** If every card of `C` has static reduction units
(`Card.reduceGain`) at most `R`, then in every game of at most `N` cards all from `C`, the static
damage reduction in force (`GameState.sReduce`) and the model's bound `sReduceBound` of the cards
are at most `2 (N R)`. -/
theorem sReduce_le_of {C : List Card} {R N : Nat} (hr : ∀ c ∈ C, c.reduceGain ≤ R) {g : GameState}
    (hg : ∀ x ∈ g.allCards, x ∈ C) (hn : g.allCards.length ≤ N) :
    g.sReduce ≤ sReduceBound g.allCards ∧ sReduceBound g.allCards ≤ 2 * (N * R) := by
  have h3 : csum (Card.gain Static.reduceUnit) g.allCards ≤ g.allCards.length * R :=
    csum_le_mul fun c hc => hr c (hg c hc)
  have h4 := Nat.le_trans h3 (Nat.mul_le_mul_right R hn)
  refine ⟨g.sReduce_le, ?_⟩
  unfold sReduceBound
  omega

/-- The clause `ReduceLe` of `GameState.Fit` (milestone M6: every Resistance plus the static reduction
bound `sReduceBound` at most `k`) holds at `Enum.bound` for every game, by the definition of the bound. -/
theorem reduceLe_bound (g : GameState) : g.ReduceLe (Enum.bound g.allCards) := fun p hp => by
  have := resist_le_maxResist hp
  simp only [Enum.bound]
  omega

/-- **A checked trigger fires wherever its place allows.** For a triggered Ability of a card that passes
`Card.trigsOk`, `Ability.trigOn` (the model's test of whether it fires on `ev` for its Pokémon at `sp`) is
the test of its place alone: no printed condition and no effect outside the fragment silences it. -/
theorem trigOn_of_trigsOk {c : Card} (h : c.trigsOk = true) {ab : Ability} (hab : ab ∈ c.abilities)
    {ev : TrigEvent} (he : ab.use.event = some ev) (sp : Spot) :
    ab.trigOn ev sp = ab.spotOk sp ∧ (ab.script ev.place).trigOk = true := by
  have h1 := List.all_eq_true.1 h ab hab
  rw [he] at h1
  simp only [Bool.and_eq_true] at h1
  refine ⟨?_, h1.1.2⟩
  simp only [Ability.trigOn, he, beq_self_eq_true, Bool.true_and, h1.1.1, h1.1.2, h1.2,
    Bool.and_true]

/-- **Store-safe decks from a checked pool.** If every card of `C` passes `Card.importOk` and
`recSafeB C` holds, every game whose cards all come from `C` is `StoreSafe`: `LoopFree`, `GXOnly`,
`RecycleSafe`, `AbilitySafe` and `StadiumSafe`. -/
theorem storeSafe_of {C : List Card} (h : C.all Card.importOk = true) (hr : recSafeB C = true)
    (g : GameState) (hg : ∀ x ∈ g.allCards, x ∈ C) : g.StoreSafe :=
  ⟨fun x hx => loopFree_of h x (hg x hx),
   fun c hc atk ha hgx => gxOnly_of h c (hg c hc) atk ha hgx,
   recycleSafe_of hr g hg,
   fun x hx => abilitySafe_of h x (hg x hx),
   fun x hx => stadiumSafe_of h x (hg x hx)⟩

end PokemonCards
