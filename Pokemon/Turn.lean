import Pokemon.Rules

/-!
# Turn fidelity (milestone M1)

The rules of `Pokemon/Rules.lean` that make a turn in the model what a turn is in the rulebook,
stated as theorems.

* `Move.after_attack`: an attack ends the turn. Once the player to move has attacked (or
  failed a Confused attempt), every legal move is the batch Knock Out step (`KOBatch`: the Knock
  Outs, the Prize cards, the outcome, the promotions) or `endTurn`, which passes the turn;
  `Move.after_attack_passTurn` says more: the second kind of move gives exactly the state
  `GameState.passTurn` describes (Checkup on both Active Pokémon, the stores shifted, the
  opponent to move between turns).
* `GameState.FlagsOk`: the turn flags are consistent (on the first turn of the game the player
  to move went first, neither player has had a turn, and nobody has attacked; between turns
  nobody has attacked). `Move.flagsOk`, `Reach.flagsOk`: play preserves it. Under it the
  bans on the first turn of the game are theorems (`GameState.FlagsOk.firstTurn_starting`,
  `Move.firstTurn_no_attack`, `Move.firstTurn_no_supporter`,
  `GameState.FlagsOk.firstTurn_no_evolve`).
* `dealtBy_zero`, `GameState.dealt_zero`: an attack with base damage 0 does no damage, whatever
  the lingering modifiers ("Stop if the base damage is 0").
* `InPlay.inflict_poisoned`: a new Poison replaces the old one, so the Poison strength returns
  to that of a plain Poison.
* First-turn rules are premises of the moves (`Move.attack`, `Move.attackConfused` and
  `Move.supporter` need `firstTurn = false`; `Move.evolve` needs `PlayerState.hadTurn`, which
  `Move.endTurn` sets for the player whose turn ends), as are the once-per-turn limits on
  Energy, Supporters and retreat and the evolution timing (`InPlay.fresh`).
-/

namespace Pokemon

/-- **An attack ends the turn.** From a state of the turn proper in which the player to move
has attacked, every move is the batch Knock Out step (`KOBatch`: the Knock Outs the attack
caused, the Prize cards, the outcome and the promotions) or the end of the turn, after which the opponent is to move, between
turns, and has not attacked. No other action (playing a card, attaching Energy, evolving,
retreating, attacking again) is legal. (Milestone batch-KO replaced `KOMove`, the eight Knock Out
moves, by `KOBatch` in the statement.) -/
theorem Move.after_attack {g g' : GameState} (hm : Move g g') (ha : g.attacked = true)
    (hb : g.between = false) :
    KOBatch g g' ∨ (g'.curIsFirst = !g.curIsFirst ∧ g'.between = true ∧ g'.attacked = false) := by
  cases hm with
  | playBasic _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | attach _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | evolve _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | attachBench _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | evolveBench _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | retreat _ _ _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | item _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | supporter _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | stadiumUse _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | stadium _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | tool _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | toolBench _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | ability _ _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | onPlay hp => exact absurd (ha.symm.trans hp.attacked) (by decide)
  | attack _ _ _ _ hn => exact absurd (ha.symm.trans hn) (by decide)
  | attackConfused _ _ _ _ hn => exact absurd (ha.symm.trans hn) (by decide)
  | knockOuts h => exact .inl h
  | endTurn => exact .inr ⟨rfl, rfl, rfl⟩
  | startTurn hbt => exact absurd (hbt.symm.trans hb) (by decide)
  | deckOut hbt => exact absurd (hbt.symm.trans hb) (by decide)

/-- **Base damage 0 does no damage**, whatever the bonuses, reductions and prevention, and
whatever the Weakness and Resistance. -/
theorem dealtBy_zero (weak : Bool) (resist : Nat) (own opp : Store) :
    dealtBy 0 weak resist own opp = 0 := rfl

@[inherit_doc dealtBy_zero]
theorem GameState.dealt_zero (g : GameState) : g.dealt 0 = 0 := rfl

/-- The state `Move.endTurn` produces from `g`, with Checkup coin flips `fa sa ca` for the
opponent's Active Pokémon `a` and `fb sb cb` for the player's own `b`, and the Benches after
their Char counters, `bo` (the opponent's) and `bc` (the player's). -/
def GameState.passTurn (fa sa ca fb sb cb : Bool) (a b : InPlay) (bo bc : List InPlay)
    (g : GameState) : GameState :=
  { cur := { g.opp with
      active := some (a.checkup false fa sa ca), bench := bo,
      energyAttached := false, supporterPlayed := false, retreated := false,
      mods := g.opp.mods.shift },
    opp := { g.cur.unfresh with
      active := some (b.unfresh.checkup true fb sb cb), bench := bc,
      mods := g.cur.mods.shift, hadTurn := true },
    curIsFirst := !g.curIsFirst, firstTurn := false, attacked := false,
    between := true, winner := g.winner, stadium := g.stadium, stadiumPlayed := false,
    stadiumUsed := false }

/-- With no Char counter on any Pokémon of a Bench, the Benches' Char step leaves it as it is. -/
theorem BenchChar.eq_of_noChar {b b' : List InPlay} (h : BenchChar b b')
    (hc : ∀ p ∈ b, p.marks.char = false) : b' = b := by
  induction h with
  | nil => rfl
  | cons hs _ ih =>
      rw [ih (fun q hq => hc q (.tail _ hq))]
      cases hs with
      | keep => rfl
      | burn h => exact absurd (h.symm.trans (hc _ (.head _))) (by decide)

/-- **An attack ends the turn, exactly.** After an attack (or a failed Confused attempt), a move
is the batch Knock Out step, or it ends the turn: both Active Pokémon are present, no Knock Out is
pending, and the result is `GameState.passTurn` for some Checkup coin flips and Char flips on
the Benches. (Milestone M3 added the Benches' Char flips `bo`, `bc` to the statement; with no
Char counter on a Benched Pokémon, `BenchChar` leaves the Bench as it is
(`BenchChar.eq_of_noChar`: `bo = g.opp.bench` and `bc = g.cur.bench.map InPlay.unfresh`), which
is the old statement. Milestone batch-KO replaced the first alternative, the eight Knock Out moves
(`KOMove`), by the batch Knock Out step `KOBatch`, which takes them all at once.) -/
theorem Move.after_attack_passTurn {g g' : GameState} (hm : Move g g') (ha : g.attacked = true)
    (hb : g.between = false) :
    KOBatch g g' ∨ ∃ (a b : InPlay) (fa sa ca fb sb cb : Bool) (bo bc : List InPlay),
      g.opp.active = some a ∧ g.cur.active = some b ∧ DamageBounded g ∧
      BenchChar g.opp.bench bo ∧ BenchChar (g.cur.bench.map InPlay.unfresh) bc ∧
      g' = g.passTurn fa sa ca fb sb cb a b bo bc := by
  cases hm with
  | playBasic _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | attach _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | evolve _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | attachBench _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | evolveBench _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | retreat _ _ _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | item _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | supporter _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | stadiumUse _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | stadium _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | tool _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | toolBench _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | ability _ _ _ _ _ _ _ _ hat => exact absurd (ha.symm.trans hat) (by decide)
  | onPlay hp => exact absurd (ha.symm.trans hp.attacked) (by decide)
  | attack _ _ _ _ hn => exact absurd (ha.symm.trans hn) (by decide)
  | attackConfused _ _ _ _ hn => exact absurd (ha.symm.trans hn) (by decide)
  | knockOuts h => exact .inl h
  | endTurn fa sa ca fb sb cb ha' hb' hk _ hco hcc =>
      exact .inr ⟨_, _, fa, sa, ca, fb, sb, cb, _, _, ha', hb', hk, hco, hcc, rfl⟩
  | startTurn hbt => exact absurd (hbt.symm.trans hb) (by decide)
  | deckOut hbt => exact absurd (hbt.symm.trans hb) (by decide)

/-! ## Consistent turn flags -/

/-- **Consistent turn flags.** On the first turn of the game the player to move is the one who
went first, neither player has finished a turn, and nobody has attacked; between turns nobody
has attacked. Every start state of a game satisfies it, and play preserves it
(`Move.flagsOk`); the model does not require it of a start state. -/
def GameState.FlagsOk (g : GameState) : Prop :=
  (g.firstTurn = true →
    g.curIsFirst = true ∧ g.cur.hadTurn = false ∧ g.opp.hadTurn = false ∧ g.attacked = false) ∧
  (g.between = true → g.attacked = false)

/-- What an effect's resolution leaves alone: whose turn it is, the turn flags, both players'
`hadTurn`, and whether the player to move has played a Supporter. -/
def GameState.SameTurn (g g' : GameState) : Prop :=
  g'.curIsFirst = g.curIsFirst ∧ g'.firstTurn = g.firstTurn ∧ g'.attacked = g.attacked ∧
    g'.between = g.between ∧ g'.cur.hadTurn = g.cur.hadTurn ∧ g'.opp.hadTurn = g.opp.hadTurn ∧
    g'.cur.supporterPlayed = g.cur.supporterPlayed

theorem GameState.SameTurn.refl (g : GameState) : g.SameTurn g :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem GameState.SameTurn.trans {g₁ g₂ g₃ : GameState} (h₁ : g₁.SameTurn g₂)
    (h₂ : g₂.SameTurn g₃) : g₁.SameTurn g₃ :=
  ⟨h₂.1.trans h₁.1, h₂.2.1.trans h₁.2.1, h₂.2.2.1.trans h₁.2.2.1, h₂.2.2.2.1.trans h₁.2.2.2.1,
    h₂.2.2.2.2.1.trans h₁.2.2.2.2.1, h₂.2.2.2.2.2.1.trans h₁.2.2.2.2.2.1,
    h₂.2.2.2.2.2.2.trans h₁.2.2.2.2.2.2⟩

theorem Run.sameTurn {e : Effect} {g g' : GameState} (h : Run e g g') : g.SameTurn g' := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact .refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | @touchActive e w f g p he h => cases w <;> exact .refl _
  | @touchBench e w f g q b₁ b₂ he h => cases w <;> exact .refl _
  | unmark w m g => cases w <;> exact .refl _
  | benchCounters w n h => cases w <;> exact .refl _
  | spreadCounters w n g => cases w <;> exact .refl _
  | switch w ha hb => cases w <;> exact .refl _
  | benchDamage w n h => cases w <;> exact .refl _
  | spreadDamage w n g => cases w <;> exact .refl _
  | linger w s m g => cases w <;> exact .refl _
  | @zone e w g s' hw hz => cases w <;> exact .refl _
  | _ => exact .refl _

theorem KOBatch.sameTurn {g g' : GameState} (h : KOBatch g g') : g.SameTurn g' := by
  cases h <;> exact .refl _

theorem Resolve.sameTurn {g g' : GameState} (h : Resolve g g') : g.SameTurn g' := by
  induction h with
  | done => exact .refl _
  | step _ hm _ ih => exact hm.sameTurn.trans ih

theorem TRun.sameTurn {e : Effect} {g g' : GameState} (h : TRun e g g') : g.SameTurn g' := by
  induction h with
  | prim _ _ hr hk => exact hr.sameTurn.trans hk.sameTurn
  | stop => exact .refl _
  | iteT _ _ _ _ ih => exact ih
  | iteF _ _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact .refl _
  | iterCons _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/-- Marking a Pokémon as having used an Ability changes no turn flag (milestone M8a). -/
theorem UseAt.sameTurn {g g₁ : GameState} {x : InPlay} {sp : Spot} (h : UseAt g x sp g₁) :
    g.SameTurn g₁ := by
  cases h <;> exact .refl _

/-- A play from the hand changes no turn flag (milestone M8a). -/
theorem PlayFromHand.sameTurn {g g₁ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g x w g₁) : g.SameTurn g₁ := by
  cases h <;> exact .refl _

/-- An effect's resolution leaves the Stadium flags alone (milestone M5). -/
theorem Run.stFlags {e : Effect} {g g' : GameState} (h : Run e g g') :
    g'.stadiumPlayed = g.stadiumPlayed ∧ g'.stadiumUsed = g.stadiumUsed := by
  induction h with
  | iteT _ _ _ ih => exact ih
  | iteF _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ⟨ih₂.1.trans ih₁.1, ih₂.2.trans ih₁.2⟩
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact ⟨rfl, rfl⟩
  | iterCons _ _ ih₁ ih₂ => exact ⟨ih₂.1.trans ih₁.1, ih₂.2.trans ih₁.2⟩
  | @touchActive e w f g p he h => cases w <;> exact ⟨rfl, rfl⟩
  | @touchBench e w f g q b₁ b₂ he h => cases w <;> exact ⟨rfl, rfl⟩
  | unmark w m g => cases w <;> exact ⟨rfl, rfl⟩
  | benchCounters w n h => cases w <;> exact ⟨rfl, rfl⟩
  | spreadCounters w n g => cases w <;> exact ⟨rfl, rfl⟩
  | switch w ha hb => cases w <;> exact ⟨rfl, rfl⟩
  | benchDamage w n h => cases w <;> exact ⟨rfl, rfl⟩
  | spreadDamage w n g => cases w <;> exact ⟨rfl, rfl⟩
  | linger w s m g => cases w <;> exact ⟨rfl, rfl⟩
  | @zone e w g s' hw hz => cases w <;> exact ⟨rfl, rfl⟩
  | _ => exact ⟨rfl, rfl⟩

theorem KOBatch.stFlags {g g' : GameState} (h : KOBatch g g') :
    g'.stadiumPlayed = g.stadiumPlayed ∧ g'.stadiumUsed = g.stadiumUsed := by
  cases h <;> exact ⟨rfl, rfl⟩

theorem Resolve.stFlags {g g' : GameState} (h : Resolve g g') :
    g'.stadiumPlayed = g.stadiumPlayed ∧ g'.stadiumUsed = g.stadiumUsed := by
  induction h with
  | done => exact ⟨rfl, rfl⟩
  | step _ hm _ ih => exact ⟨ih.1.trans hm.stFlags.1, ih.2.trans hm.stFlags.2⟩

theorem TRun.stFlags {e : Effect} {g g' : GameState} (h : TRun e g g') :
    g'.stadiumPlayed = g.stadiumPlayed ∧ g'.stadiumUsed = g.stadiumUsed := by
  induction h with
  | prim _ _ hr hk => exact ⟨hk.stFlags.1.trans hr.stFlags.1, hk.stFlags.2.trans hr.stFlags.2⟩
  | stop => exact ⟨rfl, rfl⟩
  | iteT _ _ _ _ ih => exact ih
  | iteF _ _ _ _ ih => exact ih
  | seq _ _ ih₁ ih₂ => exact ⟨ih₂.1.trans ih₁.1, ih₂.2.trans ih₁.2⟩
  | choiceL _ ih => exact ih
  | choiceR _ ih => exact ih
  | iterNil => exact ⟨rfl, rfl⟩
  | iterCons _ _ ih₁ ih₂ => exact ⟨ih₂.1.trans ih₁.1, ih₂.2.trans ih₁.2⟩

/-- Using an Ability (marking, then resolving its effect) changes no turn flag. -/
theorem UseAt.sameTurn_run {e : Effect} {g g₁ g' : GameState} {x : InPlay} {sp : Spot}
    (hu : UseAt g x sp g₁) (hr : TRun e g₁ g') : g.SameTurn g' :=
  hu.sameTurn.trans hr.sameTurn

theorem GameState.FlagsOk.of_flags {g g' : GameState} (hc : g.FlagsOk)
    (h : g'.curIsFirst = g.curIsFirst ∧ g'.firstTurn = g.firstTurn ∧ g'.attacked = g.attacked ∧
      g'.between = g.between ∧ g'.cur.hadTurn = g.cur.hadTurn ∧ g'.opp.hadTurn = g.opp.hadTurn) :
    g'.FlagsOk := by
  obtain ⟨h1, h2, h3, h4, h5, h6⟩ := h
  refine ⟨fun hf => ?_, fun hb => ?_⟩
  · obtain ⟨a, b, c, d⟩ := hc.1 (h2 ▸ hf)
    exact ⟨h1 ▸ a, h5 ▸ b, h6 ▸ c, h3 ▸ d⟩
  · exact h3 ▸ hc.2 (h4 ▸ hb)

theorem GameState.FlagsOk.of_sameTurn {g g' : GameState} (hc : g.FlagsOk) (h : g.SameTurn g') :
    g'.FlagsOk :=
  hc.of_flags ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.1⟩

/-- **Play preserves consistent turn flags.** -/
theorem Move.flagsOk {g g' : GameState} (hm : Move g g') (hc : g.FlagsOk) : g'.FlagsOk := by
  cases hm with
  | item hh hbt hst hr =>
      have h := hr.sameTurn
      exact hc.of_flags ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.1⟩
  | supporter hh hs hbt hst hr =>
      have h := hr.sameTurn
      exact hc.of_flags ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.1⟩
  | ability hu _ _ _ _ _ _ _ _ hr =>
      exact hc.of_sameTurn (hu.sameTurn_run hr)
  | stadiumUse _ _ _ _ _ hr => exact hc.of_sameTurn hr.sameTurn
  | onPlay hp _ _ _ _ _ hr => exact hc.of_sameTurn (hp.sameTurn.trans hr.sameTurn)
  | attack ha hm hc' hs hn hf hbt hst hr =>
      have h := hr.sameTurn
      refine ⟨fun hf' => ?_, fun hb' => ?_⟩
      · have : g.firstTurn = true := h.2.1.symm.trans hf'
        rw [hf] at this; cases this
      · have : g.between = true := h.2.2.2.1.symm.trans hb'
        rw [hbt] at this; cases this
  | attackConfused ha hm hc' hs hn hf hbt =>
      refine ⟨fun hf' => ?_, fun hb' => ?_⟩
      · exact absurd (hf.symm.trans hf') (by decide)
      · rw [hbt] at hb'; cases hb'
  | endTurn => exact ⟨fun hf => (by cases hf), fun _ => rfl⟩
  | startTurn => exact ⟨hc.1, fun hb => by cases hb⟩
  | knockOuts h => exact hc.of_sameTurn h.sameTurn
  | _ => exact hc

theorem Reach.flagsOk {g₀ g : GameState} (h : Reach g₀ g) (hc : g₀.FlagsOk) : g.FlagsOk := by
  induction h with
  | refl => exact hc
  | step _ _ hm ih => exact hm.flagsOk ih

/-- **The starting player cannot attack on the first turn of the game**: from a state with
consistent flags on the first turn, no move leaves the player to move having attacked (or having
failed a Confused attempt). -/
theorem Move.firstTurn_no_attack {g g' : GameState} (hc : g.FlagsOk) (hf : g.firstTurn = true)
    (hm : Move g g') : g'.attacked = false := by
  have ha := (hc.1 hf).2.2.2
  cases hm with
  | item hh hbt hst hr => exact hr.sameTurn.2.2.1.trans ha
  | ability hu _ _ _ _ _ _ _ _ hr => exact (hu.sameTurn_run hr).2.2.1.trans ha
  | stadiumUse _ _ _ _ _ hr => exact hr.sameTurn.2.2.1.trans ha
  | onPlay hp _ _ _ _ _ hr => exact (hp.sameTurn.trans hr.sameTurn).2.2.1.trans ha
  | supporter hh hs hbt hst hr _ hf' => exact absurd (hf.symm.trans hf') (by decide)
  | attack _ _ _ _ _ hf' => exact absurd (hf.symm.trans hf') (by decide)
  | attackConfused _ _ _ _ _ hf' => exact absurd (hf.symm.trans hf') (by decide)
  | knockOuts h => exact h.sameTurn.2.2.1.trans ha
  | _ => first | exact ha | rfl

/-- **The starting player cannot play a Supporter on the first turn of the game**: no move made
while it is the first turn plays one (the player's Supporter flag is unchanged, and no Supporter
goes to the discard pile by `Move.supporter`, whose premise `firstTurn = false` fails). -/
theorem Move.firstTurn_no_supporter {g g' : GameState} (hf : g.firstTurn = true)
    (hm : Move g g') (hf' : g'.firstTurn = true) :
    g'.cur.supporterPlayed = g.cur.supporterPlayed := by
  cases hm with
  | item hh hbt hst hr => exact hr.sameTurn.2.2.2.2.2.2
  | ability hu _ _ _ _ _ _ _ _ hr => exact (hu.sameTurn_run hr).2.2.2.2.2.2
  | stadiumUse _ _ _ _ _ hr => exact hr.sameTurn.2.2.2.2.2.2
  | onPlay hp _ _ _ _ _ hr => exact (hp.sameTurn.trans hr.sameTurn).2.2.2.2.2.2
  | supporter _ _ _ _ _ _ hf₀ => exact absurd (hf.symm.trans hf₀) (by decide)
  | attack _ _ _ _ _ hf₀ => exact absurd (hf.symm.trans hf₀) (by decide)
  | attackConfused _ _ _ _ _ hf₀ => exact absurd (hf.symm.trans hf₀) (by decide)
  | endTurn => cases hf'
  | knockOuts h => exact h.sameTurn.2.2.2.2.2.2
  | _ => rfl

/-- **On the first turn of the game the player to move is the starting player**, with
consistent flags: the bans of `firstTurn` (no attack, no Supporter) fall on the player who went
first, as the rulebook says ("the starting player skips this step", 2023 p. 13; "The player who
goes first cannot play a Supporter card on their first turn", p. 12). -/
theorem GameState.FlagsOk.firstTurn_starting {g : GameState} (hc : g.FlagsOk)
    (hf : g.firstTurn = true) : g.curIsFirst = true :=
  (hc.1 hf).1

/-- **No evolution on the first turn of the game**: with consistent flags, on the first turn
of the game neither player has had a turn, so `Move.evolve`, which needs
`g.cur.hadTurn = true`, is not legal. This theorem covers the game's first turn only. The ban
on the second player's own first turn is the `hadTurn` premise of `Move.evolve` itself
(`Move.endTurn` sets `hadTurn` only for the player whose turn ends); `FlagsOk` constrains
`hadTurn` only while `firstTurn` holds, so that ban is not a theorem under `FlagsOk`. -/
theorem GameState.FlagsOk.firstTurn_no_evolve {g : GameState} (hc : g.FlagsOk)
    (hf : g.firstTurn = true) : g.cur.hadTurn = false ∧ g.opp.hadTurn = false :=
  ⟨(hc.1 hf).2.1, (hc.1 hf).2.2.1⟩

/-- **A new Poison replaces the old one**: poisoning a Pokémon, Poisoned or not, leaves it
Poisoned with Poison strength 0 (one damage counter at each Checkup). -/
theorem InPlay.inflict_poisoned (p : InPlay) :
    (p.inflict .poisoned).poisoned = true ∧ (p.inflict .poisoned).poisonUp = 0 :=
  ⟨rfl, rfl⟩

end Pokemon
