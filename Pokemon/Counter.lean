import Pokemon.Rules

/-!
# The generalised model simulates a two-counter machine

`Pokemon/Lingering.lean` shows that for every cap `k ≥ 3` there is a deck with a damage
reduction for which the clamp at `k` is not a simulation. This file shows more: the model, with lingering modifiers generalised beyond
what printed cards allow, simulates every two-counter (Minsky) machine, and reachability of a
designated halt mark from the constructed start state holds exactly when the machine halts.

**Machines.** `Machine` is a program, a list of `Instr` (`inc r q`: increment counter `r`, go
to `q`; `jz r q₁ q₂`: if counter `r` is zero go to `q₁`, else decrement it and go to `q₂`;
`halt`), with every state at or beyond the end of the program halting. `Config` is a state and
two counters, `Machine.Step` the (deterministic) step relation, `Machine.Reaches` its
reflexive-transitive closure, `Machine.Halts c₀` reachability of a halted configuration.

**The construction** (`start M a b`, cards `clock M` and `tape M`; the rules as they are: neither
attack is a GX attack, so the once-per-game rule for GX attacks does not apply). The
first player has one Pokémon, the Clock, the second one, the Tape; no Bench; one Energy card in
each deck-and-hand; one Prize card each.
* Counters. The rest-of-game slot (`Slot.always`) never expires. Counter one is the second
  player's rest-of-game damage reduction minus the first player's rest-of-game damage bonus;
  counter two the first player's reduction minus the second player's bonus. `linger … .always
  (reduce 1)` increments one, `linger own .always (bonus 1)` decrements one. The inputs `a`, `b`
  are the start reductions.
* Zero test. `damage 1` deals `1 + bonus − reduction`, truncated at 0: 1 if the counter read
  in that direction is zero, 0 otherwise; `ite (exactly opp v)` then reads it exactly. The
  Clock's attacks read counter one, the Tape's counter two.
* Program counter: the damage on the Clock, set by `healAll` and `selfDamage`, read by
  `exactly own q` (the Clock) and `exactly opp q` (the Tape). The Clock writes `W + q'` after
  running an instruction (`W = 2 · span`); the Tape can only add damage to the Clock, so after
  its test it adds counters to reach `W + q'`. The Clock's attack first normalises `W + q` to
  `q`, then runs every instruction except a test of counter two, which it leaves to the Tape
  (the Tape acts only on the normalised form `q`, so each round runs exactly one step). HP of
  the Clock: `3 · span + 1`, above every value the counter takes.
* Clean-up. The Clock's zero test damages the Tape (2 HP) by at most 1; the Tape's attack heals
  it (`healAll`) first, and the Clock runs nothing while the Tape is damaged. No Pokémon ever
  reaches its HP, so there is no Knock Out.
* Decks. On the intended line decks never run out: each attack begins with `handToBottom`,
  which returns the drawn card. A player who declines to attack, or who attaches the Energy
  card, decks out at their next draw, and the game ends (`deckOut`) without a halt mark.
* Halt mark: in a halting state the Clock's attack puts an Imprison marker on the Clock itself
  (`HaltMarked`).

**Results.**
* `start_wellFormed`, `start_encodes`: the start is well formed and encodes `init a b`.
* `simulate`: if `M` steps from `c` to `c'` and `g` encodes `c`, a state encoding `c'` is
  reachable from `g` (the proof uses six fixed moves: Clock attacks, end turn, draw, Tape
  attacks, end turn, draw);
  `reach_of_reaches`: every reachable configuration is encoded by a reachable state;
  `Encodes.inj`: a state encodes at most one configuration.
* `haltMarked_of_halts`: if `M` halts, a halt-marked state is reachable.
* `halts_of_haltMarked` (**the converse**): a halt-marked state is reachable only if `M` halts.
  It covers all play: `move_inv` shows that every legal move from a state satisfying the
  invariant `Inv` (an abstract state `Abs` that is `Good` and whose configuration `M` reaches)
  leads to such a state. Attacks run the machine or do nothing; attaching Energy, drawing and
  ending the turn change nothing abstract; decking out ends the game; and no other move is legal
  (hands hold only Energy, Benches are empty, nothing is Confused or at its HP). A player who
  declines to attack, or who attaches the Energy card, decks out at their next draw, and the
  game ends with a winner and no halt mark; the invariant covers `deckOut`, so this does not
  affect the converse.
* `universal`: all of this for every machine; so `M ↦ start M a b` reduces the halting problem
  for two-counter machines to reachability of the halt mark. With Minsky's theorem (1967) that
  this halting problem is undecidable, reachability in the generalised model is undecidable.
  That last step is prose: undecidability is not stated as a Lean theorem.
* `not_finite_up_to`, `reachable_le`: the states reachable from `start countUp 0 0` (a machine
  that counts up for ever) are not finite up to any equivalence fine enough to recover the
  encoded configuration; `not_finite`, the case of equality. This is a statement about how
  states are represented, not about play: `countUp` never reads its counter, so the extra
  states differ only in a reduction that nothing observes. It is not the counterpart of
  `Reach.finite` (a finite bisimulation quotient) for decks that are not tame. The behavioural
  counterpart is `universal` together with Minsky's theorem (prose): it rules out a uniform,
  computable finite abstraction of the generalised model, although for any single machine a
  finite quotient that respects the halt question exists, non-constructively.

**Generality used.** The construction relies on these departures from printed cards and from
legal play.
1. Damage bonuses and reductions for the rest of the game that add up without limit, placed by
   an attack's effect that is used every turn (`linger` is a general primitive here), including
   an attack that grants the *opponent* a rest-of-game damage reduction
   (`linger .opp .always (reduce 1)`). Printed cards give rest-of-game modifiers only through
   once-per-game attacks (GX attacks; survey S7 §C). Neither attack here is a GX attack
   (`Attack.gx = false`); this is exactly the clause `GXOnly` of `GameState.Faithful` that the
   construction violates (`Faithful.counter_not_gxOnly`, in `Pokemon/Dichotomy.lean`).
2. `damage` read by a test later in the same attack (`ite (exactly opp v)` after `damage 1`):
   this uses the model's freedom to order primitives inside one effect.
3. Arbitrary printed HP: the Clock's HP, `3 · span + 1`, grows with the machine.
4. The halt mark is a marker the Clock places on itself (`mark .own .imprison`); printed
   markers target the opponent. This affects only the observable, not the simulation.
5. A hand-built start: each player has an Active Pokémon and one Energy card, plus one Prize
   card, with no set-up. It is not shown to be reachable from a legal set-up, and padding the
   decks to legal size is not proved harmless.
6. The model's other generalisations of card text: `ite`, `healAll`, `selfDamage`, `counters`,
   `mark` and `handToBottom` as general primitives combined in one attack.

It does not rely on an attack not ending the turn (each round ends the turn right after
attacking); on a bonus being added to an attack with base damage 0 (both attacks have base
damage 0, which does no damage, `dealtBy`; the zero test is `damage 1` inside the effect); on
attack costs being counted rather than typed (both attacks cost nothing); on
modifiers belonging to a player rather than to one Pokémon (each player has one Pokémon and no
Bench); or on the absence of Weakness and Resistance.

So the construction is about this generalisation of the model, not about the printed game: it
does not show that the printed card pool is Turing complete. On the printed side, same-turn
bonuses and reductions are bounded by copies of their cards times a printed constant only if
no card-recycling loop replays them, which is an empirical claim about the card pool; and a
reduction carried into the opponent's turn exists on a printed Item (Iron Defender: "During
your opponent's next turn, all of your Metal Pokémon take 30 less damage…").
-/

namespace Pokemon.Counter

-- The record-equality goals share one `simp only` list; not every lemma fires in every case.
set_option linter.unusedSimpArgs false

/-! ## Two-counter machines -/

/-- The two counters. -/
inductive Reg where
  | one | two
  deriving DecidableEq

/-- An instruction: increment counter `r` and go to `q`; if counter `r` is zero go to `q₁`,
else decrement it and go to `q₂`; halt. -/
inductive Instr where
  | inc (r : Reg) (q : Nat)
  | jz (r : Reg) (q₁ q₂ : Nat)
  | halt
  deriving DecidableEq

/-- A two-counter (Minsky) machine: a finite program. State `q` runs the instruction
`prog[q]`; every state at or beyond the end of the program halts. -/
structure Machine where
  prog : List Instr

/-- A configuration: the state and the values of the two counters. -/
structure Config where
  pc : Nat
  a : Nat
  b : Nat
  deriving DecidableEq

namespace Machine

/-- The instruction of state `q` (`halt` beyond the program). -/
def instr (M : Machine) (q : Nat) : Instr := M.prog.getD q .halt

/-- One step of the machine. There is no step from a configuration whose instruction is
`halt`, and the step relation is deterministic (`Machine.Step.det`). -/
inductive Step (M : Machine) : Config → Config → Prop where
  | incOne {pc a b q : Nat} (h : M.instr pc = .inc .one q) : Step M ⟨pc, a, b⟩ ⟨q, a + 1, b⟩
  | incTwo {pc a b q : Nat} (h : M.instr pc = .inc .two q) : Step M ⟨pc, a, b⟩ ⟨q, a, b + 1⟩
  | zeroOne {pc b q₁ q₂ : Nat} (h : M.instr pc = .jz .one q₁ q₂) :
      Step M ⟨pc, 0, b⟩ ⟨q₁, 0, b⟩
  | decOne {pc a b q₁ q₂ : Nat} (h : M.instr pc = .jz .one q₁ q₂) :
      Step M ⟨pc, a + 1, b⟩ ⟨q₂, a, b⟩
  | zeroTwo {pc a q₁ q₂ : Nat} (h : M.instr pc = .jz .two q₁ q₂) :
      Step M ⟨pc, a, 0⟩ ⟨q₁, a, 0⟩
  | decTwo {pc a b q₁ q₂ : Nat} (h : M.instr pc = .jz .two q₁ q₂) :
      Step M ⟨pc, a, b + 1⟩ ⟨q₂, a, b⟩

/-- The configurations the machine reaches from `c₀`. -/
inductive Reaches (M : Machine) (c₀ : Config) : Config → Prop where
  | refl : Reaches M c₀ c₀
  | step {c c' : Config} : Reaches M c₀ c → Step M c c' → Reaches M c₀ c'

/-- A configuration is halted when its instruction is `halt`. -/
def Halted (M : Machine) (c : Config) : Prop := M.instr c.pc = .halt

/-- The machine halts from `c₀`: it reaches a halted configuration. -/
def Halts (M : Machine) (c₀ : Config) : Prop := ∃ c, M.Reaches c₀ c ∧ M.Halted c

/-- The start configuration with inputs `a` and `b` in the two counters. -/
def init (a b : Nat) : Config := ⟨0, a, b⟩

theorem Step.det {M : Machine} {c c₁ c₂ : Config} (h₁ : M.Step c c₁) (h₂ : M.Step c c₂) :
    c₁ = c₂ := by
  cases h₁ <;> cases h₂ <;> simp_all

theorem Step.not_halted {M : Machine} {c c' : Config} (h : M.Step c c') : ¬ M.Halted c := by
  intro hh; simp only [Halted] at hh; cases h <;> simp_all

end Machine

/-- One more than the largest state an instruction can go to. -/
def Instr.next : Instr → Nat
  | .inc _ q => q + 1
  | .jz _ q₁ q₂ => max q₁ q₂ + 1
  | .halt => 0

/-- A bound on the states that matter: more than every target of an instruction, and at
least 1 (so that state 0 is below it). -/
def Machine.span (M : Machine) : Nat := M.prog.foldr (fun i n => max i.next n) 1

theorem next_le_foldr {i : Instr} : ∀ {l : List Instr}, i ∈ l →
    i.next ≤ l.foldr (fun i n => max i.next n) 1
  | _ :: _, .head _ => Nat.le_max_left _ _
  | _ :: _, .tail _ h => Nat.le_trans (next_le_foldr h) (Nat.le_max_right _ _)

theorem one_le_foldr : ∀ (l : List Instr), 1 ≤ l.foldr (fun i n => max i.next n) 1
  | [] => Nat.le_refl _
  | _ :: l => Nat.le_trans (one_le_foldr l) (Nat.le_max_right _ _)

theorem getD_mem : ∀ (l : List Instr) (n : Nat), l.getD n .halt ≠ .halt → l.getD n .halt ∈ l
  | [], n, h => by simp at h
  | x :: l, 0, _ => by simp
  | x :: l, n + 1, h => by
      simp only [List.getD_cons_succ] at h ⊢
      exact .tail _ (getD_mem l n h)

theorem Machine.span_pos (M : Machine) : 0 < M.span := one_le_foldr _

theorem Machine.next_le_span {M : Machine} {q : Nat} (h : M.instr q ≠ .halt) :
    (M.instr q).next ≤ M.span :=
  next_le_foldr (getD_mem _ _ h)

/-- Every step goes to a state below `span`. -/
theorem Machine.Step.pc_lt {M : Machine} {c c' : Config} (h : M.Step c c') : c'.pc < M.span := by
  cases h with
  | incOne h | incTwo h =>
      have := M.next_le_span (by rw [h]; exact fun e => by cases e)
      rw [h] at this; simp only [Instr.next] at this; exact this
  | zeroOne h | decOne h | zeroTwo h | decTwo h =>
      have := M.next_le_span (by rw [h]; exact fun e => by cases e)
      rw [h] at this; simp only [Instr.next] at this; simp only; omega

/-! ## The construction -/

/-- The number of program-counter values used, `span`. -/
def V (M : Machine) : Nat := M.span

/-- The offset of the second form of the program counter. -/
def W (M : Machine) : Nat := 2 * V M

/-- Select by exact damage: if the `w` Active Pokémon has exactly `v` damage counters for the
first `v` in `l`, do `f v`; if it has none of them, do nothing. -/
def sel (w : Whose) (f : Nat → Effect) : List Nat → Effect
  | [] => .skip
  | v :: l => .ite (.exactly w v) (f v) (sel w f l)

/-- Set the damage on the player's own Active Pokémon to `v`. -/
def setPc (v : Nat) : Effect := .seq .healAll (.selfDamage v)

/-- What the Clock's attack does in state `q`, by its instruction. Counter one is the
opponent's rest-of-game damage reduction minus the player's rest-of-game damage bonus; counter
two is the player's reduction minus the opponent's bonus. -/
def stepAOf (w : Nat) : Instr → Effect
  | .inc .one q' => .seq (.linger .opp .always (.reduce 1)) (setPc (w + q'))
  | .inc .two q' => .seq (.linger .own .always (.reduce 1)) (setPc (w + q'))
  | .jz .one q₁ q₂ =>
      .seq (.damage 1) (.ite (.exactly .opp 1) (setPc (w + q₁))
        (.seq (.linger .own .always (.bonus 1)) (setPc (w + q₂))))
  | .jz .two _ _ => .skip
  | .halt => .mark .own .imprison

/-- What the Tape's attack does when the opponent's Clock shows state `q`, by its instruction:
only the zero test and decrement of counter two, which the Tape's attacks read. -/
def stepBOf (w q : Nat) : Instr → Effect
  | .jz .two q₁ q₂ =>
      .seq (.damage 1) (.ite (.exactly .opp (q + 1)) (.counters (w + q₁ - (q + 1)))
        (.seq (.linger .own .always (.bonus 1)) (.counters (w + q₂ - q))))
  | _ => .skip

/-- Normalise the program counter: `W + q` becomes `q`. -/
def normA (M : Machine) : Effect :=
  sel .own (fun v => setPc (v - W M)) ((List.range (V M)).map (W M + ·))

/-- The Clock's attack: recycle the hand, normalise the program counter, and, if the
opponent's Tape has no damage, run the instruction of the current state (unless it is a test of
counter two). -/
def effA (M : Machine) : Effect :=
  .seq .handToBottom (.seq (normA M)
    (.ite (.exactly .opp 0) (sel .own (fun q => stepAOf (W M) (M.instr q)) (List.range (V M)))
      .skip))

/-- The Tape's attack: recycle the hand, heal the Tape, and, if the opponent's Clock shows a
state `q` (not `W + q`) whose instruction tests counter two, run that test. -/
def effB (M : Machine) : Effect :=
  .seq .handToBottom (.seq .healAll
    (sel .opp (fun q => stepBOf (W M) q (M.instr q)) (List.range (V M))))

/-- The Clock's only attack: no cost, base damage 0, effect `effA`. -/
def atkA (M : Machine) : Attack := ⟨"Tick", [], 0, effA M, false⟩
/-- The Tape's only attack: no cost, base damage 0, effect `effB`. -/
def atkB (M : Machine) : Attack := ⟨"Tock", [], 0, effB M, false⟩

/-- The first player's Pokémon: its damage is the program counter, so its HP exceeds every
value the counter takes. -/
def clock (M : Machine) : PokemonCard :=
  ⟨"Clock", .basic, none, 3 * V M + 1, .colorless, [atkA M], 0, none, none⟩

/-- The second player's Pokémon, the target of the first player's zero tests. -/
def tape (M : Machine) : PokemonCard := ⟨"Tape", .basic, none, 2, .colorless, [atkB M], 0, none, none⟩

/-- The halt mark: an Imprison marker on the Clock. -/
def haltMarks : Marks := Marks.set .imprison true Marks.empty

/-- A store with only a rest-of-game damage bonus `b` and damage reduction `r`. -/
def storeOf (b r : Nat) : Store :=
  ⟨Mods.empty, Mods.empty, Mods.empty, ⟨b, r, false, false, false, false⟩⟩

def isEnergy : Card → Bool
  | .energy _ => true
  | _ => false

/-! ## What the invariant knows about a player -/

/-- What the proofs track of one player: the Active Pokémon's card, damage and markers, the
rest-of-game damage bonus and reduction, and whether the deck and hand are known to be
nonempty. -/
structure Pk where
  top : PokemonCard
  dmg : Nat
  marks : Marks
  bonus : Nat
  reduce : Nat
  stocked : Bool
  held : Bool

/-- The player state `s` agrees with `k`: one Active Pokémon, with no Special Condition, and
no Bench; only Energy in deck and hand; only rest-of-game modifiers. -/
structure Fits (k : Pk) (s : PlayerState) : Prop where
  active : ∃ p, s.active = some p ∧ p.top = k.top ∧ p.rot = .none ∧ p.poisoned = false ∧
    p.burned = false ∧ p.damage = k.dmg ∧ p.marks = k.marks
  bench : s.bench = []
  deck : ∀ c ∈ s.deck, isEnergy c = true
  hand : ∀ c ∈ s.hand, isEnergy c = true
  mods : s.mods = storeOf k.bonus k.reduce
  stocked : k.stocked = true → s.deck ≠ []
  held : k.held = true → s.hand ≠ []

/-- The player to move agrees with `kc`, the opponent with `ko`. -/
structure Shape (kc ko : Pk) (g : GameState) : Prop where
  cur : Fits kc g.cur
  opp : Fits ko g.opp

/-- Forget what is known about deck and hand being nonempty. -/
def Pk.weak (k : Pk) : Pk := { k with stocked := false, held := false }

theorem Fits.weak {k : Pk} {s : PlayerState} (h : Fits k s) : Fits k.weak s :=
  ⟨h.active, h.bench, h.deck, h.hand, h.mods, (fun e => by cases e), (fun e => by cases e)⟩

/-- `Fits` does not read the once-per-game flag. -/
theorem Fits.setGx {k : Pk} {s : PlayerState} (h : Fits k s) (b : Bool) :
    Fits k { s with gxUsed := b } :=
  ⟨h.active, h.bench, h.deck, h.hand, h.mods, h.stocked, h.held⟩

/-- `e`, resolved as an attack's effect (`Run`) from any state of shape `(kc, ko)`, can be
resolved, and every resolution ends in a state of shape `(kc', ko')`. -/
def Does (e : Effect) (kc ko kc' ko' : Pk) : Prop :=
  ∀ g, Shape kc ko g → (∃ g', Run e g g') ∧ ∀ g', Run e g g' → Shape kc' ko' g'

theorem Does.of_eq {e : Effect} {kc ko kc' ko' kc'' ko'' : Pk} (h : Does e kc ko kc' ko')
    (h₁ : kc' = kc'') (h₂ : ko' = ko'') : Does e kc ko kc'' ko'' := h₁ ▸ h₂ ▸ h

theorem Does.seq {a b : Effect} {k₁ o₁ k₂ o₂ k₃ o₃ : Pk} (ha : Does a k₁ o₁ k₂ o₂)
    (hb : Does b k₂ o₂ k₃ o₃) : Does (.seq a b) k₁ o₁ k₃ o₃ := by
  intro g hs
  obtain ⟨⟨g₁, r₁⟩, ha'⟩ := ha g hs
  obtain ⟨⟨g₂, r₂⟩, _⟩ := hb g₁ (ha' g₁ r₁)
  refine ⟨⟨g₂, .seq r₁ r₂⟩, fun g' h => ?_⟩
  cases h with
  | seq h₁ h₂ => exact (hb _ (ha' _ h₁)).2 _ h₂
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.skip (kc ko : Pk) : Does .skip kc ko kc ko := by
  intro g hs
  refine ⟨⟨g, .skip g⟩, fun g' h => ?_⟩
  cases h with
  | skip => exact hs
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

/-- The damage a test on the `w` Active Pokémon reads. -/
def rd : Whose → Pk → Pk → Nat
  | .own, kc, _ => kc.dmg
  | .opp, _, ko => ko.dmg

theorem Shape.activeOf {kc ko : Pk} {g : GameState} (hs : Shape kc ko g) (w : Whose) :
    ∃ p, g.activeOf w = some p ∧ p.damage = rd w kc ko := by
  cases w with
  | own =>
      obtain ⟨p, hp, -, -, -, -, hd, -⟩ := hs.cur.active
      exact ⟨p, hp, hd⟩
  | opp =>
      obtain ⟨p, hp, -, -, -, -, hd, -⟩ := hs.opp.active
      exact ⟨p, hp, hd⟩

theorem beq_false {x y : Nat} (h : x ≠ y) : Nat.beq x y = false := by
  cases hb : Nat.beq x y
  · rfl
  · rw [Nat.beq_eq] at hb; exact absurd hb h

theorem Does.ite_eq {w : Whose} {v : Nat} {a b : Effect} {kc ko kc' ko' : Pk}
    (hv : rd w kc ko = v) (h : Does a kc ko kc' ko') :
    Does (.ite (.exactly w v) a b) kc ko kc' ko' := by
  intro g hs
  obtain ⟨p, hp, hd⟩ := hs.activeOf w
  have ht : (Test.exactly w v).eval p = true := by
    simp only [Test.eval, hd, hv]; exact Nat.beq_refl v
  obtain ⟨⟨g', r⟩, h'⟩ := h g hs
  refine ⟨⟨g', .iteT (p := p) hp ht r⟩, fun g' hr => ?_⟩
  cases hr with
  | iteT hp' _ r' => exact h' _ r'
  | iteF hp' ht' _ =>
      simp only [Test.whose] at hp'
      rw [hp] at hp'; cases hp'; rw [ht] at ht'; cases ht'
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.ite_ne {w : Whose} {v : Nat} {a b : Effect} {kc ko kc' ko' : Pk}
    (hv : rd w kc ko ≠ v) (h : Does b kc ko kc' ko') :
    Does (.ite (.exactly w v) a b) kc ko kc' ko' := by
  intro g hs
  obtain ⟨p, hp, hd⟩ := hs.activeOf w
  have ht : (Test.exactly w v).eval p = false := by
    simp only [Test.eval, hd]; exact beq_false hv
  obtain ⟨⟨g', r⟩, h'⟩ := h g hs
  refine ⟨⟨g', .iteF (p := p) hp ht r⟩, fun g' hr => ?_⟩
  cases hr with
  | iteF hp' _ r' => exact h' _ r'
  | iteT hp' ht' _ =>
      simp only [Test.whose] at hp'
      rw [hp] at hp'; cases hp'; rw [ht] at ht'; cases ht'
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.sel_hit {w : Whose} {f : Nat → Effect} {kc ko kc' ko' : Pk} :
    ∀ {l : List Nat}, rd w kc ko ∈ l → Does (f (rd w kc ko)) kc ko kc' ko' →
      Does (sel w f l) kc ko kc' ko'
  | [], hm, _ => absurd hm (List.not_mem_nil)
  | v :: l, hm, h => by
      by_cases he : rd w kc ko = v
      · subst he; exact Does.ite_eq rfl h
      · exact Does.ite_ne he (Does.sel_hit (List.mem_of_ne_of_mem he hm) h)

theorem Does.sel_miss {w : Whose} {f : Nat → Effect} {kc ko : Pk} :
    ∀ {l : List Nat}, rd w kc ko ∉ l → Does (sel w f l) kc ko kc ko
  | [], _ => Does.skip kc ko
  | v :: l, hm => by
      have he : rd w kc ko ≠ v := fun e => hm (e ▸ List.mem_cons_self ..)
      exact Does.ite_ne he (Does.sel_miss (fun h => hm (List.mem_cons_of_mem _ h)))

/-! ### Primitive effects on states of known shape -/

theorem Does.handToBottom (kc ko : Pk) :
    Does .handToBottom kc ko { kc with stocked := kc.stocked || kc.held, held := false } ko := by
  intro g hs
  refine ⟨⟨_, .handToBottom (List.Perm.refl _)⟩, fun g' h => ?_⟩
  cases h with
  | @handToBottom _ hs' hp =>
      have hc := hs.cur
      refine ⟨⟨hc.active, hc.bench, fun c hc' => ?_, (fun c hc' => by cases hc'), hc.mods,
        fun e => ?_, (fun e => by cases e)⟩, hs.opp⟩
      · rcases List.mem_append.1 hc' with h | h
        · exact hc.deck c h
        · exact hc.hand c (hp.mem_iff.1 h)
      · intro hn
        have h1 := List.append_eq_nil_iff.1 hn
        cases hk : kc.stocked
        · rw [hk] at e
          have h2 := hc.held e
          exact h2 (List.eq_nil_of_length_eq_zero (hp.length_eq ▸ by rw [h1.2]; rfl))
        · exact hc.stocked hk h1.1
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.healAll (kc ko : Pk) : Does .healAll kc ko { kc with dmg := 0 } ko := by
  intro g hs
  obtain ⟨p, hp, h1, h2, h3, h4, _, h6⟩ := hs.cur.active
  refine ⟨⟨_, .healAll hp⟩, fun g' h => ?_⟩
  cases h with
  | healAll h' =>
      rw [hp] at h'; cases h'
      have hc := hs.cur
      exact ⟨⟨⟨_, rfl, h1, h2, h3, h4, rfl, h6⟩, hc.bench, hc.deck, hc.hand, hc.mods, hc.stocked,
        hc.held⟩, hs.opp⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.selfDamage (n : Nat) (kc ko : Pk) :
    Does (.selfDamage n) kc ko { kc with dmg := kc.dmg + n } ko := by
  intro g hs
  obtain ⟨p, hp, h1, h2, h3, h4, h5, h6⟩ := hs.cur.active
  refine ⟨⟨_, .selfDamage n hp⟩, fun g' h => ?_⟩
  cases h with
  | selfDamage _ h' =>
      rw [hp] at h'; cases h'
      have hc := hs.cur
      exact ⟨⟨⟨_, rfl, h1, h2, h3, h4, by simp only [h5], h6⟩, hc.bench, hc.deck, hc.hand,
        hc.mods, hc.stocked, hc.held⟩, hs.opp⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.counters (n : Nat) (kc ko : Pk) :
    Does (.counters n) kc ko kc { ko with dmg := ko.dmg + n } := by
  intro g hs
  obtain ⟨p, hp, h1, h2, h3, h4, h5, h6⟩ := hs.opp.active
  refine ⟨⟨_, .counters n hp⟩, fun g' h => ?_⟩
  cases h with
  | counters _ h' =>
      rw [hp] at h'; cases h'
      have hc := hs.opp
      exact ⟨hs.cur, ⟨⟨_, rfl, h1, h2, h3, h4, by simp only [h5], h6⟩, hc.bench, hc.deck,
        hc.hand, hc.mods, hc.stocked, hc.held⟩⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem dealt_shape {kc ko : Pk} {g : GameState} (hs : Shape kc ko g) (n : Nat) :
    g.dealt (n + 1) = (n + 1 + kc.bonus) - ko.reduce := by
  simp [GameState.dealt, dealtBy, hs.cur.mods, hs.opp.mods, storeOf, Store.live, Mods.merge,
    Mods.empty]

/-- Base damage 0 does no damage (the rulebook's "Stop if the base damage is 0"). -/
theorem dealt_zero (g : GameState) : g.dealt 0 = 0 := by
  simp [GameState.dealt, dealtBy]

theorem Does.damage (n : Nat) (kc ko : Pk) :
    Does (.damage (n + 1)) kc ko kc
      { ko with dmg := ko.dmg + ((n + 1 + kc.bonus) - ko.reduce) } := by
  intro g hs
  obtain ⟨p, hp, h1, h2, h3, h4, h5, h6⟩ := hs.opp.active
  refine ⟨⟨_, .damage (n + 1) hp⟩, fun g' h => ?_⟩
  cases h with
  | damage _ h' =>
      rw [hp] at h'; cases h'
      have hc := hs.opp
      exact ⟨hs.cur, ⟨⟨_, rfl, h1, h2, h3, h4, by simp only [h5, dealt_shape hs], h6⟩, hc.bench,
        hc.deck, hc.hand, hc.mods, hc.stocked, hc.held⟩⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

/-- An attack with base damage 0 does no damage, whatever the modifiers. -/
theorem Does.damageZero (kc ko : Pk) : Does (.damage 0) kc ko kc ko := by
  intro g hs
  obtain ⟨p, hp, h1, h2, h3, h4, h5, h6⟩ := hs.opp.active
  refine ⟨⟨_, .damage 0 hp⟩, fun g' h => ?_⟩
  cases h with
  | damage _ h' =>
      rw [hp] at h'; cases h'
      have hc := hs.opp
      exact ⟨hs.cur, ⟨⟨_, rfl, h1, h2, h3, h4, by simp only [h5, dealt_zero, Nat.add_zero], h6⟩,
        hc.bench, hc.deck, hc.hand, hc.mods, hc.stocked, hc.held⟩⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.bonusOwn (n : Nat) (kc ko : Pk) :
    Does (.linger .own .always (.bonus n)) kc ko { kc with bonus := kc.bonus + n } ko := by
  intro g hs
  refine ⟨⟨_, .linger _ _ _ g⟩, fun g' h => ?_⟩
  cases h with
  | linger =>
      have hc := hs.cur
      exact ⟨⟨hc.active, hc.bench, hc.deck, hc.hand, by
        simp only [GameState.updSide, hc.mods]; rfl, hc.stocked, hc.held⟩, hs.opp⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.reduceOwn (n : Nat) (kc ko : Pk) :
    Does (.linger .own .always (.reduce n)) kc ko { kc with reduce := kc.reduce + n } ko := by
  intro g hs
  refine ⟨⟨_, .linger _ _ _ g⟩, fun g' h => ?_⟩
  cases h with
  | linger =>
      have hc := hs.cur
      exact ⟨⟨hc.active, hc.bench, hc.deck, hc.hand, by
        simp only [GameState.updSide, hc.mods]; rfl, hc.stocked, hc.held⟩, hs.opp⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.reduceOpp (n : Nat) (kc ko : Pk) :
    Does (.linger .opp .always (.reduce n)) kc ko kc { ko with reduce := ko.reduce + n } := by
  intro g hs
  refine ⟨⟨_, .linger _ _ _ g⟩, fun g' h => ?_⟩
  cases h with
  | linger =>
      have hc := hs.opp
      exact ⟨hs.cur, ⟨hc.active, hc.bench, hc.deck, hc.hand, by
        simp only [GameState.updSide, hc.mods]; rfl, hc.stocked, hc.held⟩⟩
  | touchActive he => simp [Effect.touch] at he
  | touchBench he => simp [Effect.touch] at he

theorem Does.markOwn (m : Marker) (kc ko : Pk) :
    Does (.mark .own m) kc ko { kc with marks := kc.marks.set m true } ko := by
  intro g hs
  obtain ⟨p, hp, h1, h2, h3, h4, h5, h6⟩ := hs.cur.active
  refine ⟨⟨_, .touchActive (w := .own) rfl hp⟩, fun g' h => ?_⟩
  cases h with
  | touchActive he h' =>
      simp only [Effect.touch, Option.some.injEq, Prod.mk.injEq] at he
      obtain ⟨rfl, rfl⟩ := he
      simp only [GameState.side] at h'
      rw [hp] at h'; cases h'
      have hc := hs.cur
      exact ⟨⟨⟨_, rfl, h1, h2, h3, h4, h5, by simp only [InPlay.setMarks, h6]⟩, hc.bench,
        hc.deck, hc.hand, hc.mods, hc.stocked, hc.held⟩, hs.opp⟩
  | touchBench he h' =>
      simp only [Effect.touch, Option.some.injEq, Prod.mk.injEq] at he
      obtain ⟨rfl, rfl⟩ := he
      simp only [GameState.side, hs.cur.bench] at h'
      exact absurd h'.symm (by simp)

/-! ## The abstract state, and one attack of each player -/

/-- The abstract state of the construction: machine state and counters; the rest-of-game
damage bonuses `x` (Clock player) and `y` (Tape player); the damage `rA` on the Clock and `rB`
on the Tape; whether the halt mark is set. The Clock player's reduction is `y + b`, the Tape
player's `x + a`. -/
structure Abs where
  q : Nat
  a : Nat
  b : Nat
  x : Nat
  y : Nat
  rA : Nat
  rB : Nat
  halted : Bool

def Abs.cfg (s : Abs) : Config := ⟨s.q, s.a, s.b⟩

/-- The Clock's markers: the halt mark or none. -/
def mkOf (h : Bool) : Marks := if h then haltMarks else Marks.empty

def pkA (M : Machine) (s : Abs) (st hd : Bool) : Pk :=
  ⟨clock M, s.rA, mkOf s.halted, s.x, s.y + s.b, st, hd⟩

def pkB (M : Machine) (s : Abs) (st hd : Bool) : Pk :=
  ⟨tape M, s.rB, Marks.empty, s.y, s.x + s.a, st, hd⟩

/-- The invariant on the abstract state: the program counter is `q` or `W + q` with `q` below
`V`; the Tape has at most one damage counter; the halt mark only in a halting state. -/
def Good (M : Machine) (s : Abs) : Prop :=
  s.q < V M ∧ (s.rA = s.q ∨ s.rA = W M + s.q) ∧ s.rB ≤ 1 ∧ (s.halted = true → M.instr s.q = .halt)

/-- What the Clock's attack does to the abstract state after normalisation, by instruction. -/
def tickOf (w : Nat) (s : Abs) : Instr → Abs
  | .inc .one q' => { s with q := q', a := s.a + 1, rA := w + q' }
  | .inc .two q' => { s with q := q', b := s.b + 1, rA := w + q' }
  | .jz .one q₁ q₂ => if s.a = 0 then { s with q := q₁, rA := w + q₁, rB := 1 }
      else { s with q := q₂, a := s.a - 1, x := s.x + 1, rA := w + q₂ }
  | .jz .two _ _ => s
  | .halt => { s with halted := true }

/-- The Clock's attack on the abstract state. -/
def tickS (M : Machine) (s : Abs) : Abs :=
  if s.rB = 0 then tickOf (W M) { s with rA := s.q } (M.instr s.q) else { s with rA := s.q }

/-- What the Tape's attack does to the abstract state after healing, by instruction. -/
def tockOf (w : Nat) (s : Abs) : Instr → Abs
  | .jz .two q₁ q₂ => if s.b = 0 then { s with q := q₁, rA := w + q₁ }
      else { s with q := q₂, b := s.b - 1, y := s.y + 1, rA := w + q₂ }
  | _ => s

/-- The Tape's attack on the abstract state. -/
def tockS (M : Machine) (s : Abs) : Abs :=
  if s.rA = s.q then tockOf (W M) { s with rB := 0 } (M.instr s.q) else { s with rB := 0 }

theorem mkOf_set (h : Bool) : (mkOf h).set .imprison true = mkOf true := by
  cases h <;> rfl

theorem Does.stepA {M : Machine} {s : Abs} (hr : s.rB = 0) (st hd st' hd' : Bool) (i : Instr) :
    Does (stepAOf (W M) i) (pkA M s st hd) (pkB M s st' hd') (pkA M (tickOf (W M) s i) st hd)
      (pkB M (tickOf (W M) s i) st' hd') := by
  cases i with
  | inc r q' =>
      cases r with
      | one =>
          refine ((Does.reduceOpp 1 _ _).seq ((Does.healAll _ _).seq
            (Does.selfDamage _ _ _))).of_eq ?_ ?_ <;>
            simp only [pkA, pkB, tickOf, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
      | two =>
          refine ((Does.reduceOwn 1 _ _).seq ((Does.healAll _ _).seq
            (Does.selfDamage _ _ _))).of_eq ?_ ?_ <;>
            simp only [pkA, pkB, tickOf, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
  | jz r q₁ q₂ =>
      cases r with
      | one =>
          by_cases ha : s.a = 0
          · refine ((Does.damage 0 _ _).seq (Does.ite_eq ?_ ((Does.healAll _ _).seq
              (Does.selfDamage _ _ _)))).of_eq ?_ ?_
            · simp only [rd, pkA, pkB]; omega
            · simp only [pkA, tickOf, ha, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
            · simp only [pkA, pkB, tickOf, ha, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
          · refine ((Does.damage 0 _ _).seq (Does.ite_ne ?_ ((Does.bonusOwn 1 _ _).seq
              ((Does.healAll _ _).seq (Does.selfDamage _ _ _))))).of_eq ?_ ?_
            · simp only [rd, pkA, pkB]; omega
            · simp only [pkA, tickOf, ha, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
            · simp only [pkA, pkB, tickOf, ha, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
      | two => exact Does.skip _ _
  | halt =>
      refine (Does.markOwn .imprison _ _).of_eq ?_ rfl
      simp only [pkA, tickOf, mkOf_set]

theorem Does.stepB {M : Machine} {s : Abs} (hq : s.q < V M) (hr : s.rA = s.q)
    (st hd st' hd' : Bool) (i : Instr) :
    Does (stepBOf (W M) s.q i) (pkB M s st hd) (pkA M s st' hd') (pkB M (tockOf (W M) s i) st hd)
      (pkA M (tockOf (W M) s i) st' hd') := by
  have hW : W M = 2 * V M := rfl
  cases i with
  | jz r q₁ q₂ =>
      cases r with
      | two =>
          by_cases hb : s.b = 0
          · refine ((Does.damage 0 _ _).seq (Does.ite_eq ?_
              (Does.counters _ _ _))).of_eq ?_ ?_
            · simp only [rd, pkA, pkB]; omega
            · simp only [pkB, tockOf, hb, ↓reduceIte]
            · simp only [pkA, pkB, tockOf, hb, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
          · refine ((Does.damage 0 _ _).seq (Does.ite_ne ?_ ((Does.bonusOwn 1 _ _).seq
              (Does.counters _ _ _)))).of_eq ?_ ?_
            · simp only [rd, pkA, pkB]; omega
            · simp only [pkB, tockOf, hb, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
            · simp only [pkA, pkB, tockOf, hb, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
      | one => exact Does.skip _ _
  | inc => exact Does.skip _ _
  | halt => exact Does.skip _ _

/-- **The Clock's attack** (base damage, then `effA`) from a state of shape `pkA s`, `pkB s`
ends in shape `pkA (tickS s)`, `pkB (tickS s)`, and can be resolved. -/
theorem Does.attackA {M : Machine} {s : Abs} (hg : Good M s) (st hd st' hd' : Bool) :
    Does (.seq (.damage 0) (effA M)) (pkA M s st hd) (pkB M s st' hd')
      (pkA M (tickS M s) (st || hd) false) (pkB M (tickS M s) st' hd') := by
  obtain ⟨hq, hrA, hrB, -⟩ := hg
  have hW : W M = 2 * V M := rfl
  have h0 : Does (.damage 0) (pkA M s st hd) (pkB M s st' hd') (pkA M s st hd)
      (pkB M s st' hd') :=
    Does.damageZero _ _
  have hn : Does (normA M) (pkA M s (st || hd) false) (pkB M s st' hd')
      (pkA M { s with rA := s.q } (st || hd) false) (pkB M { s with rA := s.q } st' hd') := by
    rcases hrA with h | h
    · refine (Does.sel_miss ?_).of_eq ?_ rfl
      · simp only [rd, pkA, List.mem_map, List.mem_range, not_exists, not_and]
        intro i _ e; omega
      · simp only [pkA, h]
    · refine (Does.sel_hit ?_ ((Does.healAll _ _).seq (Does.selfDamage _ _ _))).of_eq ?_ rfl
      · simp only [rd, pkA, List.mem_map, List.mem_range]; exact ⟨s.q, hq, h.symm⟩
      · simp only [pkA, rd, Pk.mk.injEq, ↓reduceIte, and_true, true_and, Nat.zero_add] <;>
              (repeat' apply And.intro) <;> first | rfl | trivial | omega
  refine h0.seq ((Does.handToBottom _ _).seq (hn.seq ?_))
  by_cases hb : s.rB = 0
  · have e : tickS M s = tickOf (W M) { s with rA := s.q } (M.instr s.q) := by
      simp only [tickS, hb, ↓reduceIte]
    rw [e]
    refine Does.ite_eq (by simp only [rd, pkB, hb])
      (Does.sel_hit (f := fun q => stepAOf (W M) (M.instr q)) ?_
        (Does.stepA (s := { s with rA := s.q }) hb _ _ _ _ _))
    simp only [rd, pkA, List.mem_range]; exact hq
  · have e : tickS M s = { s with rA := s.q } := by simp only [tickS, hb, ↓reduceIte]
    rw [e]
    exact Does.ite_ne (by simp only [rd, pkB]; exact hb) (Does.skip _ _)

/-- **The Tape's attack** (base damage, then `effB`) from a state of shape `pkB s`, `pkA s`
ends in shape `pkB (tockS s)`, `pkA (tockS s)`, and can be resolved. -/
theorem Does.attackB {M : Machine} {s : Abs} (hg : Good M s) (st hd st' hd' : Bool) :
    Does (.seq (.damage 0) (effB M)) (pkB M s st hd) (pkA M s st' hd')
      (pkB M (tockS M s) (st || hd) false) (pkA M (tockS M s) st' hd') := by
  obtain ⟨hq, hrA, hrB, -⟩ := hg
  have hW : W M = 2 * V M := rfl
  have hV := M.span_pos
  have h0 : Does (.damage 0) (pkB M s st hd) (pkA M s st' hd') (pkB M s st hd)
      (pkA M s st' hd') :=
    Does.damageZero _ _
  refine h0.seq ((Does.handToBottom _ _).seq (((Does.healAll _ _).of_eq
    (show _ = pkB M { s with rB := 0 } (st || hd) false from rfl)
    (show _ = pkA M { s with rB := 0 } st' hd' from rfl)).seq ?_))
  rcases hrA with h | h
  · have e : tockS M s = tockOf (W M) { s with rB := 0 } (M.instr s.q) := by
      simp only [tockS, h, ↓reduceIte]
    rw [e]
    refine Does.sel_hit (f := fun q => stepBOf (W M) q (M.instr q)) ?_ ?_
    · simp only [rd, pkA, List.mem_range]; omega
    · have e2 : rd .opp (pkB M { s with rB := 0 } (st || hd) false)
          (pkA M { s with rB := 0 } st' hd') = s.q := h
      rw [e2]
      exact Does.stepB (s := { s with rB := 0 }) hq h _ _ _ _ _
  · have e : tockS M s = { s with rB := 0 } := by
      have hne : s.rA ≠ s.q := by simp only [V] at hW hq; omega
      simp only [tockS, hne, ↓reduceIte]
    rw [e]
    refine Does.sel_miss ?_
    simp only [rd, pkA, List.mem_range]; omega

/-! ## The abstract state: steps and invariant -/

theorem tickS_spec {M : Machine} {s : Abs} (hg : Good M s) :
    Good M (tickS M s) ∧ ((tickS M s).cfg = s.cfg ∨ M.Step s.cfg (tickS M s).cfg) := by
  obtain ⟨q, a, b, x, y, rA, rB, h⟩ := s
  obtain ⟨hq, hrA, hrB, hh⟩ := hg
  simp only at hq hrA hrB hh
  have hW : W M = 2 * V M := rfl
  unfold tickS
  by_cases hb : rB = 0
  · simp only [hb, ↓reduceIte]
    cases hi : M.instr q with
    | inc r q' =>
        have hh' : h = false := by
          cases h
          · rfl
          · rw [hh rfl] at hi; cases hi
        cases r with
        | one =>
            have st : M.Step ⟨q, a, b⟩ ⟨q', a + 1, b⟩ := .incOne hi
            have := st.pc_lt
            refine ⟨⟨this, .inr rfl, by first | omega | (simp [tickOf] <;> omega), fun e => by simp [tickOf, hh'] at e⟩,
              .inr st⟩
        | two =>
            have st : M.Step ⟨q, a, b⟩ ⟨q', a, b + 1⟩ := .incTwo hi
            have := st.pc_lt
            refine ⟨⟨this, .inr rfl, by first | omega | (simp [tickOf] <;> omega), fun e => by simp [tickOf, hh'] at e⟩,
              .inr st⟩
    | jz r q₁ q₂ =>
        have hh' : h = false := by
          cases h
          · rfl
          · rw [hh rfl] at hi; cases hi
        cases r with
        | one =>
            cases a with
            | zero =>
                have st : M.Step ⟨q, 0, b⟩ ⟨q₁, 0, b⟩ := .zeroOne hi
                have := st.pc_lt
                refine ⟨⟨this, .inr rfl, by first | omega | (simp [tickOf] <;> omega),
                  fun e => by simp [tickOf, hh'] at e⟩, .inr st⟩
            | succ a =>
                have st : M.Step ⟨q, a + 1, b⟩ ⟨q₂, a, b⟩ := .decOne hi
                have := st.pc_lt
                refine ⟨⟨this, .inr rfl, by first | omega | (simp [tickOf] <;> omega),
                  fun e => by simp [tickOf, hh'] at e⟩, .inr st⟩
        | two =>
            exact ⟨⟨hq, .inl rfl, by first | omega | (simp [tickOf] <;> omega), hh⟩, .inl rfl⟩
    | halt => exact ⟨⟨hq, .inl rfl, by first | omega | (simp [tickOf] <;> omega), fun _ => hi⟩, .inl rfl⟩
  · simp only [hb, ↓reduceIte]
    exact ⟨⟨hq, .inl rfl, hrB, hh⟩, .inl rfl⟩

theorem tockS_spec {M : Machine} {s : Abs} (hg : Good M s) :
    Good M (tockS M s) ∧ ((tockS M s).cfg = s.cfg ∨ M.Step s.cfg (tockS M s).cfg) := by
  obtain ⟨q, a, b, x, y, rA, rB, h⟩ := s
  obtain ⟨hq, hrA, hrB, hh⟩ := hg
  simp only at hq hrA hrB hh
  have hW : W M = 2 * V M := rfl
  unfold tockS
  by_cases hr : rA = q
  · simp only [hr, ↓reduceIte]
    cases hi : M.instr q with
    | jz r q₁ q₂ =>
        have hh' : h = false := by
          cases h
          · rfl
          · rw [hh rfl] at hi; cases hi
        cases r with
        | two =>
            cases b with
            | zero =>
                have st : M.Step ⟨q, a, 0⟩ ⟨q₁, a, 0⟩ := .zeroTwo hi
                have := st.pc_lt
                refine ⟨⟨this, .inr rfl, by first | omega | (simp [tockOf] <;> omega),
                  fun e => by simp [tockOf, hh'] at e⟩, .inr st⟩
            | succ b =>
                have st : M.Step ⟨q, a, b + 1⟩ ⟨q₂, a, b⟩ := .decTwo hi
                have := st.pc_lt
                refine ⟨⟨this, .inr rfl, by first | omega | (simp [tockOf] <;> omega),
                  fun e => by simp [tockOf, hh'] at e⟩, .inr st⟩
        | one => exact ⟨⟨hq, .inl rfl, by first | omega | (simp [tockOf] <;> omega), hh⟩, .inl rfl⟩
    | inc => exact ⟨⟨hq, .inl rfl, by first | omega | (simp [tockOf] <;> omega), hh⟩, .inl rfl⟩
    | halt => exact ⟨⟨hq, .inl rfl, by first | omega | (simp [tockOf] <;> omega), hh⟩, .inl rfl⟩
  · simp only [hr, ↓reduceIte]
    exact ⟨⟨hq, hrA, by first | omega | (simp <;> omega), hh⟩, .inl rfl⟩

/-- **One round does one step.** From an abstract state with the Tape undamaged and no halt
mark, the Clock's attack followed by the Tape's attack performs exactly the machine's next
step, and leaves the Tape undamaged and no halt mark. -/
theorem round_spec {M : Machine} {s : Abs} {c' : Config} (hg : Good M s) (hb : s.rB = 0)
    (hh : s.halted = false) (hs : M.Step s.cfg c') :
    (tockS M (tickS M s)).cfg = c' ∧ (tockS M (tickS M s)).rB = 0 ∧
      (tockS M (tickS M s)).halted = false := by
  obtain ⟨q, a, b, x, y, rA, rB, h⟩ := s
  obtain ⟨hq, hrA, hrB, -⟩ := hg
  simp only at hq hrA hrB hb hh
  subst hb hh
  have hW : W M = 2 * V M := rfl
  have hV := M.span_pos
  have hne : ∀ q', W M + q' ≠ q' := by intro q' e; simp only [V] at hW; omega
  cases hs with
  | incOne hi =>
      simp only [tickS, hi, tickOf, ↓reduceIte, tockS, hne, Abs.cfg]; refine ⟨?_, ?_, ?_⟩ <;> first | rfl | trivial
  | incTwo hi =>
      simp only [tickS, hi, tickOf, ↓reduceIte, tockS, hne, Abs.cfg]; refine ⟨?_, ?_, ?_⟩ <;> first | rfl | trivial
  | zeroOne hi =>
      simp only [tickS, hi, tickOf, ↓reduceIte, tockS, hne, Abs.cfg]; refine ⟨?_, ?_, ?_⟩ <;> first | rfl | trivial
  | decOne hi =>
      simp only [tickS, hi, tickOf, ↓reduceIte, tockS, hne, Abs.cfg, Nat.add_one_ne_zero]
      refine ⟨?_, ?_, ?_⟩ <;> first | rfl | trivial
  | zeroTwo hi =>
      simp only [tickS, hi, tickOf, ↓reduceIte, tockS, tockOf, Abs.cfg]; refine ⟨?_, ?_, ?_⟩ <;> first | rfl | trivial
  | decTwo hi =>
      simp only [tickS, hi, tickOf, ↓reduceIte, tockS, tockOf, Abs.cfg, Nat.add_one_ne_zero]
      refine ⟨?_, ?_, ?_⟩ <;> first | rfl | trivial

theorem tickS_halted {M : Machine} {s : Abs} (hb : s.rB = 0) (hH : M.Halted s.cfg) :
    (tickS M s).halted = true := by
  simp only [Machine.Halted, Abs.cfg] at hH
  simp only [tickS, hb, hH, tickOf, ↓reduceIte]

/-! ## Moves from states of known shape -/

theorem Run.flags {e : Effect} {g g' : GameState} (h : Run e g g') :
    g'.firstTurn = g.firstTurn ∧ g'.attacked = g.attacked ∧ g'.between = g.between ∧
      g'.winner = g.winner := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ =>
      exact ⟨ih₂.1.trans ih₁.1, ih₂.2.1.trans ih₁.2.1, ih₂.2.2.1.trans ih₁.2.2.1,
        ih₂.2.2.2.trans ih₁.2.2.2⟩
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterCons _ _ ih₁ ih₂ =>
      exact ⟨ih₂.1.trans ih₁.1, ih₂.2.1.trans ih₁.2.1, ih₂.2.2.1.trans ih₁.2.2.1,
        ih₂.2.2.2.trans ih₁.2.2.2⟩
  | @touchActive e w f g p he h => cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | @touchBench e w f g q b₁ b₂ he h => cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | unmark w m g => cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | linger w s m g => cases w <;> exact ⟨rfl, rfl, rfl, rfl⟩
  | _ => exact ⟨rfl, rfl, rfl, rfl⟩

theorem Shape.damageBounded {kc ko : Pk} {g : GameState} (hs : Shape kc ko g)
    (hc : kc.dmg < kc.top.hp) (ho : ko.dmg < ko.top.hp) : DamageBounded g := by
  obtain ⟨p, hp, ht, -, -, -, hd, -⟩ := hs.cur.active
  obtain ⟨p', hp', ht', -, -, -, hd', -⟩ := hs.opp.active
  intro r hr
  rcases hr with hr | hr | hr | hr
  · rw [hp] at hr; cases hr; rw [hd, ht]; exact hc
  · rw [hs.cur.bench] at hr; cases hr
  · rw [hp'] at hr; cases hr; rw [hd', ht']; exact ho
  · rw [hs.opp.bench] at hr; cases hr

theorem Shape.settled {kc ko : Pk} {g : GameState} (hs : Shape kc ko g)
    (hc : kc.dmg < kc.top.hp) (ho : ko.dmg < ko.top.hp) : Settled g := by
  obtain ⟨p, hp, -⟩ := hs.cur.active
  obtain ⟨p', hp', -⟩ := hs.opp.active
  exact ⟨hs.damageBounded hc ho, (by rw [hp]; exact fun e => by cases e),
    (by rw [hp']; exact fun e => by cases e)⟩

/-- Checkup changes nothing on a Pokémon with no Special Condition and no Char counter. -/
theorem checkup_calm {p : InPlay} (hr : p.rot = .none) (hp : p.poisoned = false)
    (hb : p.burned = false) (hc : p.marks.char = false) (o f sp c : Bool) :
    (p.checkup o f sp c).damage = p.damage ∧ (p.checkup o f sp c).rot = .none ∧
      (p.checkup o f sp c).burned = false := by
  simp [InPlay.checkup, hr, hp, hb, hc]

theorem Fits.toCur {k : Pk} {s : PlayerState} {a : InPlay} (h : Fits k s)
    (ha : s.active = some a) (hc : k.marks.char = false) (o f sp c : Bool) :
    Fits k { s with
      active := some (a.checkup o f sp c), energyAttached := false,
      supporterPlayed := false, retreated := false, mods := s.mods.shift } := by
  obtain ⟨p, hp, h1, h2, h3, h4, h5, h6⟩ := h.active
  rw [ha] at hp; cases hp
  obtain ⟨e1, e2, e3⟩ := checkup_calm h2 h3 h4 (by rw [h6]; exact hc) o f sp c
  exact ⟨⟨_, rfl, h1, e2, h3, e3, e1.trans h5, h6⟩, h.bench, h.deck, h.hand,
    by rw [h.mods]; rfl, h.stocked, h.held⟩

theorem Fits.toOpp {k : Pk} {s : PlayerState} {b : InPlay} (h : Fits k s)
    (hb : s.active = some b) (hc : k.marks.char = false) (o f sp c : Bool) :
    Fits k { s.unfresh with
      active := some (b.unfresh.checkup o f sp c), mods := s.mods.shift, hadTurn := true } := by
  obtain ⟨p, hp, h1, h2, h3, h4, h5, h6⟩ := h.active
  rw [hb] at hp; cases hp
  obtain ⟨e1, e2, e3⟩ := checkup_calm (p := b.unfresh) h2 h3 h4 (by rw [← hc, ← h6]; rfl)
    o f sp c
  exact ⟨⟨_, rfl, h1, e2, h3, e3, e1.trans h5, h6⟩,
    by simp only [PlayerState.unfresh, h.bench, List.map_nil], h.deck, h.hand,
    by rw [h.mods]; rfl, h.stocked, h.held⟩

theorem not_mem_hand {k : Pk} {s : PlayerState} {l₁ l₂ : List Card} {c : Card} (h : Fits k s)
    (hh : s.hand = l₁ ++ c :: l₂) (hc : isEnergy c = false) : False := by
  have := h.hand c (by rw [hh]; exact List.mem_append_right _ (.head _))
  rw [hc] at this; cases this

/-- Every move from a state of known shape is an attack, keeps the shape (attach, the draw,
deck out), or swaps it (end of turn). No other move is legal: hands hold only Energy, Benches
are empty, nothing is Confused, and no Pokémon is at its HP. -/
theorem move_shape {kc ko : Pk} {g g' : GameState} (hm : Move g g') (hs : Shape kc ko g)
    (hc : kc.dmg < kc.top.hp) (ho : ko.dmg < ko.top.hp) (hcc : kc.marks.char = false)
    (hoc : ko.marks.char = false) :
    Shape kc.weak ko.weak g' ∨ Shape ko.weak kc.weak g' ∨
      ∃ atk g'', atk ∈ kc.top.attacks ∧ Run (.seq (.damage atk.damage) atk.effect) g g'' ∧
        g' = { g'' with
          attacked := true, cur := { g''.cur with gxUsed := atk.gx || g''.cur.gxUsed } } := by
  have hC := hs.cur
  have hO := hs.opp
  obtain ⟨p, hp, h1, h2, h3, h4, h5, h6⟩ := hC.active
  obtain ⟨p', hp', h1', h2', h3', h4', h5', h6'⟩ := hO.active
  cases hm with
  | playBasic hh => exact (not_mem_hand hC hh rfl).elim
  | @attach l₁ l₂ t a hh hf ha =>
      rw [hp] at ha; cases ha
      refine .inl ⟨⟨⟨_, rfl, h1, h2, h3, h4, h5, h6⟩, hC.bench, hC.deck, fun c hc' => ?_,
        hC.mods, (fun e => by cases e), (fun e => by cases e)⟩, hO.weak⟩
      exact hC.hand c (by
        rw [hh]; rcases List.mem_append.1 hc' with h | h
        · exact List.mem_append_left _ h
        · exact List.mem_append_right _ (.tail _ h))
  | evolve hh => exact (not_mem_hand hC hh rfl).elim
  | retreat ha hb => rw [hC.bench] at hb; exact absurd hb.symm (by simp)
  | item hh => exact (not_mem_hand hC hh rfl).elim
  | supporter hh => exact (not_mem_hand hC hh rfl).elim
  | @attack g'' a atk ha hm' _ _ _ _ _ _ hr _ _ =>
      rw [hp] at ha; cases ha
      exact .inr (.inr ⟨atk, g'', h1 ▸ hm', hr, rfl⟩)
  | attackConfused ha _ _ hs' => rw [hp] at ha; cases ha; rw [h2] at hs'; cases hs'
  | knockOut ha hk =>
      rw [hp'] at ha; cases ha; rw [h5', h1'] at hk; exact absurd hk (Nat.not_le.2 ho)
  | promote ha => rw [hp'] at ha; cases ha
  | noPokemon ha => rw [hp'] at ha; cases ha
  | knockOutOwn ha hk =>
      rw [hp] at ha; cases ha; rw [h5, h1] at hk; exact absurd hk (Nat.not_le.2 hc)
  | promoteOwn ha => rw [hp] at ha; cases ha
  | noPokemonOwn ha => rw [hp] at ha; cases ha
  | endTurn fa sa ca fb sb cb ha hb =>
      exact .inr (.inl ⟨(hO.toCur ha hoc false fa sa ca).weak,
        (hC.toOpp hb hcc true fb sb cb).weak⟩)
  | @startTurn a b c d _ _ _ _ hd =>
      refine .inl ⟨⟨hC.active, hC.bench, fun x hx => hC.deck x (by rw [hd]; exact .tail _ hx),
        fun x hx => ?_, hC.mods, (fun e => by cases e), (fun e => by cases e)⟩, hO.weak⟩
      cases hx with
      | head => exact hC.deck c (by rw [hd]; exact .head _)
      | tail _ hx => exact hC.hand x hx
  | deckOut => exact .inl ⟨hC.weak, hO.weak⟩

theorem mkOf_char (h : Bool) : (mkOf h).char = false := by cases h <;> rfl

theorem Good.hpA {M : Machine} {s : Abs} (hg : Good M s) (st hd : Bool) :
    (pkA M s st hd).dmg < (pkA M s st hd).top.hp := by
  obtain ⟨hq, hrA, -, -⟩ := hg
  have hW : W M = 2 * V M := rfl
  simp only [pkA, clock]; omega

theorem Good.hpB {M : Machine} {s : Abs} (hg : Good M s) (st hd : Bool) :
    (pkB M s st hd).dmg < (pkB M s st hd).top.hp := by
  obtain ⟨-, -, hrB, -⟩ := hg
  simp only [pkB, tape]; omega

/-- An attack from a state of known shape, given what its effect does. -/
theorem attack_move {kc ko kc' ko' : Pk} {g : GameState} {atk : Attack} (hs : Shape kc ko g)
    (hatk : atk ∈ kc.top.attacks) (hcost : atk.cost = [])
    (hD : Does (.seq (.damage atk.damage) atk.effect) kc ko kc' ko')
    (hc : kc.dmg < kc.top.hp) (ho : ko.dmg < ko.top.hp) (hbt : g.between = false)
    (hn : g.attacked = false) (hf : g.firstTurn = false) (hgx : atk.gx = false) :
    ∃ g', Move g g' ∧ Shape kc' ko' g' ∧ g'.between = false ∧ g'.firstTurn = false ∧
      g'.winner = g.winner := by
  obtain ⟨p, hp, h1, h2, -⟩ := hs.cur.active
  obtain ⟨⟨g'', hr⟩, hsh⟩ := hD g hs
  have hfl := Run.flags hr
  refine ⟨_, .attack hp (h1 ▸ hatk) (by rw [hcost]; exact .nil _) (by rw [h2]; rfl) hn hf
    hbt (hs.settled hc ho) hr (by rw [hs.cur.mods]; rfl) (fun h => by rw [hgx] at h; cases h),
    ⟨(hsh _ hr).cur.setGx _, (hsh _ hr).opp⟩, hfl.2.2.1.trans hbt, hfl.1.trans hf, hfl.2.2.2⟩

/-- Ending the turn from a state of known shape swaps the shape. -/
theorem endTurn_move {kc ko : Pk} {g : GameState} (hs : Shape kc ko g)
    (hc : kc.dmg < kc.top.hp) (ho : ko.dmg < ko.top.hp) (hcc : kc.marks.char = false)
    (hoc : ko.marks.char = false) (hbt : g.between = false) :
    ∃ g', Move g g' ∧ Shape ko kc g' ∧ g'.between = true ∧ g'.attacked = false ∧
      g'.firstTurn = false ∧ g'.winner = g.winner := by
  obtain ⟨p, hp, -⟩ := hs.cur.active
  obtain ⟨p', hp', -⟩ := hs.opp.active
  exact ⟨_, .endTurn false false false false false false hp' hp (hs.damageBounded hc ho) hbt,
    ⟨hs.opp.toCur hp' hoc false false false false, hs.cur.toOpp hp hcc true false false false⟩,
    rfl, rfl, rfl, rfl⟩

/-- Drawing for the turn from a state of known shape whose deck is known to be nonempty. -/
theorem startTurn_move {kc ko : Pk} {g : GameState} (hs : Shape kc ko g)
    (hc : kc.dmg < kc.top.hp) (ho : ko.dmg < ko.top.hp) (hbt : g.between = true)
    (hst : kc.stocked = true) :
    ∃ g', Move g g' ∧ Shape { kc with stocked := false, held := true } ko g' ∧
      g'.between = false ∧ g'.attacked = g.attacked ∧ g'.firstTurn = g.firstTurn ∧
      g'.winner = g.winner := by
  obtain ⟨p, hp, -⟩ := hs.cur.active
  obtain ⟨p', hp', -⟩ := hs.opp.active
  have hC := hs.cur
  match hd : g.cur.deck with
  | [] => exact absurd hd (hC.stocked hst)
  | c :: d =>
      refine ⟨_, .startTurn hbt hp' hp (hs.damageBounded hc ho) hd,
        ⟨⟨hC.active, hC.bench, fun x hx => hC.deck x (by rw [hd]; exact .tail _ hx),
          fun x hx => ?_, hC.mods, (fun e => by cases e), (fun _ => List.cons_ne_nil _ _)⟩,
          hs.opp⟩, rfl, rfl, rfl, rfl⟩
      cases hx with
      | head => exact hC.deck c (by rw [hd]; exact .head _)
      | tail _ hx => exact hC.hand x hx

theorem reach_trans {g₁ g₂ g₃ : GameState} (h₁ : Reach g₁ g₂) (h₂ : Reach g₂ g₃) :
    Reach g₁ g₃ := by
  induction h₂ with
  | refl => exact h₁
  | step _ hw hm ih => exact .step ih hw hm

/-! ## The start state and the encoding -/

/-- A Basic Pokémon just set up as Active: no damage, no Energy, no markers. -/
def onPlay (top : PokemonCard) : InPlay :=
  ⟨top, [], [], [], 0, .none, false, false, 0, false, Marks.empty⟩

/-- **The start state for machine `M` with inputs `a`, `b`.** The first player (to move, in
the main phase of a turn after the draw) has the Clock Active, one Energy in hand, an empty
deck and one Prize card; the second player has the Tape Active, one Energy in its deck, an empty
hand and one Prize card. Neither has a Bench. The inputs are rest-of-game damage reductions:
`b` on the first player, `a` on the second. The state is in the middle of a game: not its
first turn, both players have had a turn (`hadTurn`), and the Stadium slot is empty. -/
def start (M : Machine) (a b : Nat) : GameState where
  cur := ⟨[], [.energy .grass], [], [.energy .grass], [], some (onPlay (clock M)), [],
    false, false, false, false, false, storeOf 0 b, true⟩
  opp := ⟨[.energy .grass], [], [], [.energy .grass], [], some (onPlay (tape M)), [],
    false, false, false, false, false, storeOf 0 a, true⟩
  curIsFirst := true
  firstTurn := false
  attacked := false
  between := false
  winner := none
  stadium := none

/-- **The encoding of a configuration** `c` at the start of the first player's main phase
(after the draw, before attacking): the abstract state has configuration `c`, the Tape is
undamaged, there is no halt mark, and the game has no winner. The program counter is the
damage on the Clock, `c.pc` or `W + c.pc` with `c.pc < V`; counter one is the second player's
rest-of-game damage reduction minus the first player's rest-of-game damage bonus, counter two
the first player's reduction minus the second player's bonus. -/
def Encodes (M : Machine) (c : Config) (g : GameState) : Prop :=
  ∃ s : Abs, s.cfg = c ∧ Good M s ∧ s.rB = 0 ∧ s.halted = false ∧
    Shape (pkA M s false true) (pkB M s true false) g ∧ g.between = false ∧
    g.attacked = false ∧ g.firstTurn = false ∧ g.winner = none

/-- **The halt mark**: some Active Pokémon has an Imprison marker. -/
def HaltMarked (g : GameState) : Prop :=
  ∃ p, (g.cur.active = some p ∨ g.opp.active = some p) ∧ p.marks.imprison = true

theorem start_wellFormed (M : Machine) (a b : Nat) : WellFormed (start M a b) :=
  ⟨fun _ => ⟨List.cons_ne_nil _ _, List.cons_ne_nil _ _⟩, (fun _ hp => by cases hp),
    (fun _ hp => by cases hp)⟩

theorem start_encodes (M : Machine) (a b : Nat) : Encodes M (Machine.init a b) (start M a b) := by
  refine ⟨⟨0, a, b, 0, 0, 0, 0, false⟩, rfl, ⟨M.span_pos, .inl rfl, Nat.zero_le _,
    (fun e => by cases e)⟩, rfl, rfl, ⟨?_, ?_⟩, rfl, rfl, rfl, rfl⟩
  · refine ⟨⟨_, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩, rfl, (fun _ h => by cases h), fun c h => ?_,
      (by show storeOf 0 b = storeOf 0 (0 + b); rw [Nat.zero_add]), (fun e => by cases e),
      (fun _ => List.cons_ne_nil _ _)⟩
    cases h with
    | head => rfl
    | tail _ h => cases h
  · refine ⟨⟨_, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩, rfl, fun c h => ?_, (fun _ h => by cases h),
      (by show storeOf 0 a = storeOf 0 (0 + a); rw [Nat.zero_add]), (fun _ => List.cons_ne_nil _ _),
      (fun e => by cases e)⟩
    cases h with
    | head => rfl
    | tail _ h => cases h

theorem storeOf_inj {b r b' r' : Nat} (h : storeOf b r = storeOf b' r') : b = b' ∧ r = r' :=
  ⟨congrArg (fun t : Store => t.always.bonus) h, congrArg (fun t : Store => t.always.reduce) h⟩

/-- **The encoding is injective**: a state encodes at most one configuration. -/
theorem Encodes.inj {M : Machine} {c c' : Config} {g : GameState} (h : Encodes M c g)
    (h' : Encodes M c' g) : c = c' := by
  obtain ⟨s, rfl, ⟨hq, hrA, -⟩, -, -, hs, -⟩ := h
  obtain ⟨s', rfl, ⟨hq', hrA', -⟩, -, -, hs', -⟩ := h'
  obtain ⟨p, hp, -, -, -, -, hd, -⟩ := hs.cur.active
  obtain ⟨p', hp', -, -, -, -, hd', -⟩ := hs'.cur.active
  rw [hp] at hp'; cases hp'
  have e1 := storeOf_inj (hs.cur.mods.symm.trans hs'.cur.mods)
  have e2 := storeOf_inj (hs.opp.mods.symm.trans hs'.opp.mods)
  simp only [pkA, pkB] at hd hd' e1 e2
  have hW : W M = 2 * V M := rfl
  simp only [Abs.cfg, Config.mk.injEq]
  refine ⟨?_, ?_, ?_⟩ <;> omega

/-! ## Forward simulation -/

/-- **Forward simulation.** If the machine steps from `c` to `c'` and `g` encodes `c`, then a
state encoding `c'` is reachable from `g`. (The statement says only `Reach`; the proof uses six
moves: the first player attacks with the Clock and ends the turn; the second player draws,
attacks with the Tape and ends the turn; the first player draws.) -/
theorem simulate {M : Machine} {c c' : Config} {g : GameState} (hst : M.Step c c')
    (he : Encodes M c g) : ∃ g', Reach g g' ∧ Encodes M c' g' := by
  obtain ⟨s, rfl, hg, hb, hh, hsh, hbt, hat, hft, hw⟩ := he
  have hg₁ := (tickS_spec hg).1
  have hg₂ := (tockS_spec hg₁).1
  obtain ⟨g₁, m₁, s₁, b₁, f₁, w₁⟩ := attack_move (atk := atkA M) hsh (.head _) rfl
    (Does.attackA hg false true true false) (hg.hpA _ _) (hg.hpB _ _) hbt hat hft rfl
  obtain ⟨g₂, m₂, s₂, b₂, a₂, f₂, w₂⟩ := endTurn_move s₁ (hg₁.hpA _ _) (hg₁.hpB _ _)
    (mkOf_char _) rfl b₁
  obtain ⟨g₃, m₃, s₃, b₃, a₃, f₃, w₃⟩ := startTurn_move s₂ (hg₁.hpB _ _) (hg₁.hpA _ _) b₂ rfl
  obtain ⟨g₄, m₄, s₄, b₄, f₄, w₄⟩ := attack_move (atk := atkB M) s₃ (.head _) rfl
    (Does.attackB hg₁ false true true false) (hg₁.hpB _ _) (hg₁.hpA _ _) b₃ (a₃.trans a₂)
    (f₃.trans f₂) rfl
  obtain ⟨g₅, m₅, s₅, b₅, a₅, f₅, w₅⟩ := endTurn_move s₄ (hg₂.hpB _ _) (hg₂.hpA _ _) rfl
    (mkOf_char _) b₄
  obtain ⟨g₆, m₆, s₆, b₆, a₆, f₆, w₆⟩ := startTurn_move s₅ (hg₂.hpA _ _) (hg₂.hpB _ _) b₅ rfl
  obtain ⟨hc', hb', hh'⟩ := round_spec hg hb hh hst
  have wn₁ : g₁.winner = none := w₁.trans hw
  have wn₂ : g₂.winner = none := w₂.trans wn₁
  have wn₃ : g₃.winner = none := w₃.trans wn₂
  have wn₄ : g₄.winner = none := w₄.trans wn₃
  have wn₅ : g₅.winner = none := w₅.trans wn₄
  refine ⟨g₆, .step (.step (.step (.step (.step (.step (.refl _) hw m₁) wn₁ m₂) wn₂ m₃) wn₃ m₄)
    wn₄ m₅) wn₅ m₆, ⟨_, hc', hg₂, hb', hh', s₆, b₆, a₆.trans a₅, f₆.trans f₅, w₆.trans wn₅⟩⟩

/-- Every configuration the machine reaches is encoded by a reachable state. -/
theorem reach_of_reaches {M : Machine} {c₀ c : Config} {g₀ : GameState} (he : Encodes M c₀ g₀)
    (h : M.Reaches c₀ c) : ∃ g, Reach g₀ g ∧ Encodes M c g := by
  induction h with
  | refl => exact ⟨g₀, .refl _, he⟩
  | step _ hs ih =>
      obtain ⟨g, hr, hg⟩ := ih
      obtain ⟨g', hr', hg'⟩ := simulate hs hg
      exact ⟨g', reach_trans hr hr', hg'⟩

/-- From an encoding of a halted configuration, the Clock's attack sets the halt mark. -/
theorem haltMarked_of_halted {M : Machine} {c : Config} {g : GameState} (he : Encodes M c g)
    (hH : M.Halted c) : ∃ g', Reach g g' ∧ HaltMarked g' := by
  obtain ⟨s, rfl, hg, hb, -, hsh, hbt, hat, hft, hw⟩ := he
  obtain ⟨g₁, m₁, s₁, -⟩ := attack_move (atk := atkA M) hsh (.head _) rfl
    (Does.attackA hg false true true false) (hg.hpA _ _) (hg.hpB _ _) hbt hat hft rfl
  obtain ⟨p, hp, -, -, -, -, -, hm⟩ := s₁.cur.active
  refine ⟨g₁, .step (.refl _) hw m₁, p, .inl hp, ?_⟩
  rw [hm]; simp only [pkA, tickS_halted hb hH]; rfl

/-! ## Soundness: every line of play -/

/-- The invariant of all play from the start state: the state has the shape of an abstract
state that is `Good` and whose configuration the machine reaches, with either player to move.
-/
def Inv (M : Machine) (c₀ : Config) (g : GameState) : Prop :=
  ∃ s, Good M s ∧ M.Reaches c₀ s.cfg ∧
    (Shape (pkA M s false false) (pkB M s false false) g ∨
      Shape (pkB M s false false) (pkA M s false false) g)

theorem Encodes.inv {M : Machine} {c : Config} {g : GameState} (he : Encodes M c g) :
    Inv M c g := by
  obtain ⟨s, rfl, hg, -, -, hsh, -⟩ := he
  exact ⟨s, hg, .refl, .inl ⟨hsh.cur.weak, hsh.opp.weak⟩⟩

theorem reaches_of_spec {M : Machine} {c₀ : Config} {s t : Abs} (hr : M.Reaches c₀ s.cfg)
    (h : t.cfg = s.cfg ∨ M.Step s.cfg t.cfg) : M.Reaches c₀ t.cfg := by
  rcases h with h | h
  · rw [h]; exact hr
  · exact .step hr h

/-- **Every move preserves the invariant**, whatever the players choose: attacks run the
machine (or do nothing), and every other legal move leaves the abstract state unchanged. -/
theorem move_inv {M : Machine} {c₀ : Config} {g g' : GameState} (hm : Move g g')
    (hi : Inv M c₀ g) : Inv M c₀ g' := by
  obtain ⟨s, hg, hr, hs | hs⟩ := hi
  · rcases move_shape hm hs (hg.hpA _ _) (hg.hpB _ _) (mkOf_char _) rfl with h | h | ⟨atk, g'', ha, hr', rfl⟩
    · exact ⟨s, hg, hr, .inl h⟩
    · exact ⟨s, hg, hr, .inr h⟩
    · simp only [pkA, clock, List.mem_singleton] at ha
      subst ha
      have h := (Does.attackA hg false false false false g hs).2 g'' hr'
      exact ⟨_, (tickS_spec hg).1, reaches_of_spec hr (tickS_spec hg).2,
        .inl ⟨h.cur.setGx _, h.opp⟩⟩
  · rcases move_shape hm hs (hg.hpB _ _) (hg.hpA _ _) rfl (mkOf_char _) with h | h | ⟨atk, g'', ha, hr', rfl⟩
    · exact ⟨s, hg, hr, .inr h⟩
    · exact ⟨s, hg, hr, .inl h⟩
    · simp only [pkB, tape, List.mem_singleton] at ha
      subst ha
      have h := (Does.attackB hg false false false false g hs).2 g'' hr'
      exact ⟨_, (tockS_spec hg).1, reaches_of_spec hr (tockS_spec hg).2,
        .inr ⟨h.cur.setGx _, h.opp⟩⟩

theorem reach_inv {M : Machine} {c₀ : Config} {g₀ g : GameState} (h₀ : Inv M c₀ g₀)
    (h : Reach g₀ g) : Inv M c₀ g := by
  induction h with
  | refl => exact h₀
  | step _ _ hm ih => exact move_inv hm ih

/-- In a state satisfying the invariant, the halt mark means the machine halts. -/
theorem Inv.halts {M : Machine} {c₀ : Config} {g : GameState} (hi : Inv M c₀ g)
    (hm : HaltMarked g) : M.Halts c₀ := by
  obtain ⟨s, ⟨-, -, -, hh⟩, hr, hs⟩ := hi
  obtain ⟨p, hp, hi⟩ := hm
  refine ⟨s.cfg, hr, hh ?_⟩
  have key : ∀ (kA kB : Pk), kA.marks = mkOf s.halted → kB.marks = Marks.empty →
      (Shape kA kB g ∨ Shape kB kA g) → s.halted = true := by
    intro kA kB hA hB hS
    cases hH : s.halted
    · exfalso
      rw [hH] at hA
      have hk : ∀ (k : Pk) (st : PlayerState), Fits k st → k.marks = Marks.empty →
          st.active = some p → False := by
        intro k st hf he ha
        obtain ⟨p', hp', -, -, -, -, -, hm'⟩ := hf.active
        rw [ha] at hp'; cases hp'
        rw [hm', he] at hi; cases hi
      rcases hS with hS | hS <;> rcases hp with hp | hp
      · exact hk _ _ hS.cur hA hp
      · exact hk _ _ hS.opp hB hp
      · exact hk _ _ hS.cur hB hp
      · exact hk _ _ hS.opp hA hp
    · rfl
  exact key (pkA M s false false) (pkB M s false false) rfl rfl hs

/-- **Soundness.** A state with the halt mark is reachable from `start M a b` only if the
machine halts from `init a b`. Every line of play is covered, whatever either player does. -/
theorem halts_of_haltMarked {M : Machine} {a b : Nat} {g : GameState}
    (h : Reach (start M a b) g) (hm : HaltMarked g) : M.Halts (Machine.init a b) :=
  (reach_inv (start_encodes M a b).inv h).halts hm

/-- **Completeness.** If the machine halts from `init a b`, a state with the halt mark is
reachable from `start M a b`. -/
theorem haltMarked_of_halts {M : Machine} {a b : Nat} (h : M.Halts (Machine.init a b)) :
    ∃ g, Reach (start M a b) g ∧ HaltMarked g := by
  obtain ⟨c, hr, hH⟩ := h
  obtain ⟨g, hg, he⟩ := reach_of_reaches (start_encodes M a b) hr
  obtain ⟨g', hg', hm⟩ := haltMarked_of_halted he hH
  exact ⟨g', reach_trans hg hg', hm⟩

/-! ## What follows -/

/-- **The generalised model simulates every two-counter machine.** For every machine `M` and
inputs `a`, `b`, the start state `start M a b` is well formed; it encodes the initial
configuration; every configuration the machine reaches is encoded by a reachable state (and a
state encodes at most one configuration, `Encodes.inj`); and a state with the halt mark is
reachable if and only if the machine halts.

So `M ↦ start M a b` reduces the halting problem for two-counter machines to reachability of
the halt mark in the model. With Minsky's theorem (1967) that halting is undecidable for
two-counter machines, reachability in the model so generalised is undecidable; that last step
is not formalised here. The construction uses these generalisations (the module docstring
gives details): (1) damage bonuses and reductions for the rest of the game that add up without
limit (`linger … .always`, inside attacks used every turn), including a reduction granted to the
opponent, by attacks that are not GX attacks (printed cards give rest-of-game modifiers only
through once-per-game attacks, survey S7 §C; the model's GX rule would allow one such attack per
player per game); (2) `damage` read by a test later in the same attack (`ite (exactly opp v)` after
`damage 1`), using the model's freedom to order primitives; (3) a printed HP chosen for the
machine (the Clock has HP `3 · span + 1`); (4) a halt mark placed on the player's own Pokémon
(printed markers target the opponent; this affects only the observable); (5) a hand-built start
(an Active Pokémon and one Energy each, one Prize, no set-up), not shown reachable from a legal
set-up, with padding to legal deck size not proved harmless; and (6) `ite`, `healAll`,
`selfDamage`, `counters`, `mark` and `handToBottom` as general primitives combined in one
attack. It does not rely on an attack not ending the turn, on a bonus being added to base
damage 0 (its attacks have base damage 0, which does no damage), on costs being counted rather
than typed (costs are empty), on modifiers being per player rather than per Pokémon (one Pokémon
each, no Bench), or on the absence of Weakness and Resistance. It is a theorem about this
generalisation of the model, not about the printed game. -/
theorem universal (M : Machine) (a b : Nat) :
    WellFormed (start M a b) ∧ Encodes M (Machine.init a b) (start M a b) ∧
      (∀ c, M.Reaches (Machine.init a b) c → ∃ g, Reach (start M a b) g ∧ Encodes M c g) ∧
      ((∃ g, Reach (start M a b) g ∧ HaltMarked g) ↔ M.Halts (Machine.init a b)) :=
  ⟨start_wellFormed M a b, start_encodes M a b,
    fun _ h => reach_of_reaches (start_encodes M a b) h,
    ⟨fun ⟨_, h, hm⟩ => halts_of_haltMarked h hm, haltMarked_of_halts⟩⟩

/-- Pigeonhole, for a relation that sends distinct indices to distinct list members. -/
theorem pigeon {α : Type} (R : Nat → α → Prop) (hu : ∀ i j x, R i x → R j x → i = j) :
    ∀ (k : Nat) (L : List α), (∀ i < k, ∃ x ∈ L, R i x) → k ≤ L.length
  | 0, _, _ => Nat.zero_le _
  | k + 1, L, hall => by
      obtain ⟨x, hm, hx⟩ := hall k (Nat.lt_succ_self k)
      obtain ⟨L₁, L₂, rfl⟩ := List.append_of_mem hm
      have : ∀ i < k, ∃ y ∈ L₁ ++ L₂, R i y := by
        intro i hi
        obtain ⟨y, hy, hr⟩ := hall i (by omega)
        rcases List.mem_append.1 hy with h | h
        · exact ⟨y, List.mem_append_left _ h, hr⟩
        · cases h with
          | head => exact absurd (hu i k _ hr hx) (by omega)
          | tail _ h => exact ⟨y, List.mem_append_right _ h, hr⟩
      have := pigeon R hu k (L₁ ++ L₂) this
      simp only [List.length_append, List.length_cons] at this ⊢
      omega

/-- **A finite cover must tell reached configurations apart.** Let `E` be an equivalence on game
states under which encodings of different configurations are never equivalent. If every state
reachable from `start M a b` is `E`-equivalent to a member of a list `L`, then `L` is at least
as long as any list of distinct configurations that the machine reaches. This is about how
states are represented: `E` is required to recover the encoded configuration, whether or not
play can observe it. -/
theorem reachable_le {M : Machine} {a b : Nat} (E : GameState → GameState → Prop)
    (hE : Equivalence E) (hsep : ∀ c c' g g', Encodes M c g → Encodes M c' g' → E g g' → c = c')
    (L : List GameState) (hL : ∀ g, Reach (start M a b) g → ∃ h ∈ L, E g h)
    (f : Nat → Config) (hf : ∀ i j, f i = f j → i = j) (k : Nat)
    (hk : ∀ i < k, M.Reaches (Machine.init a b) (f i)) : k ≤ L.length := by
  refine pigeon (fun i h => ∃ g, Encodes M (f i) g ∧ E g h) ?_ k L ?_
  · intro i j h ⟨g, hg, he⟩ ⟨g', hg', he'⟩
    exact hf i j (hsep _ _ _ _ hg hg' (hE.trans he (hE.symm he')))
  · intro i hi
    obtain ⟨g, hr, hg⟩ := reach_of_reaches (start_encodes M a b) (hk i hi)
    obtain ⟨h, hm, he⟩ := hL g hr
    exact ⟨h, hm, g, hg, he⟩

/-- A machine that counts up for ever: state 0 increments counter one and stays in state 0. -/
def countUp : Machine := ⟨[.inc .one 0]⟩

theorem countUp_reaches (n : Nat) : countUp.Reaches (Machine.init 0 0) ⟨0, n, 0⟩ := by
  induction n with
  | zero => exact .refl
  | succ n ih => exact .step ih (.incOne rfl)

/-- **The reachable states are not finite up to any equivalence fine enough to recover the
encoded configuration.** From the well-formed start `start countUp 0 0`, no finite list of
states contains, up to such an equivalence, every reachable state.

This is a statement about how states are represented, not about play. The hypothesis `hsep`
asks `E` to separate encodings of different configurations, and `countUp` never reads its
counter, so the extra states differ only in a damage reduction that nothing observes. So this is
not the counterpart, for decks that are not tame, of `Reach.finite` (a finite bisimulation
quotient), and it does not show that no finite bisimulation quotient exists. The behavioural
counterpart is `universal` together with Minsky's theorem (prose): no uniform, computable finite
abstraction of the generalised model answers the halt question, although for any single
machine a finite quotient respecting it exists, non-constructively. -/
theorem not_finite_up_to (E : GameState → GameState → Prop) (hE : Equivalence E)
    (hsep : ∀ c c' g g', Encodes countUp c g → Encodes countUp c' g' → E g g' → c = c') :
    ¬ ∃ L : List GameState, ∀ g, Reach (start countUp 0 0) g → ∃ h ∈ L, E g h := by
  intro ⟨L, hL⟩
  have := reachable_le E hE hsep L hL (fun n => ⟨0, n, 0⟩)
    (fun i j h => congrArg Config.a h) (L.length + 1) (fun i _ => countUp_reaches i)
  omega

/-- In particular, the states reachable from `start countUp 0 0` do not lie in any finite list
(the case of `not_finite_up_to` where the equivalence is equality, which separates encodings
of different configurations by `Encodes.inj`). Like `not_finite_up_to`, this concerns the
representation of states, not what play can observe. -/
theorem not_finite : ¬ ∃ L : List GameState, ∀ g, Reach (start countUp 0 0) g → g ∈ L := by
  intro ⟨L, hL⟩
  refine not_finite_up_to Eq ⟨fun _ => rfl, Eq.symm, Eq.trans⟩ ?_ ⟨L, fun g h => ⟨g, hL g h, rfl⟩⟩
  intro c c' g g' h h' e
  subst e
  exact h.inj h'

end Pokemon.Counter
