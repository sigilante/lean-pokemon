import Pokemon.Finite

/-!
# A clamp with exact stores: a bisimulation for every deck

`GameState.clamp k` (in `Pokemon/Damage.lean`) caps the damage bonuses and reductions in the
modifier stores (at `2 * k`), and that is why it fails for decks with damage reduction or
`drain` (`Lingering.reduce_breaks_clamp`, `Lingering.drain_breaks_clamp`): both counterexamples
reach two states whose stores differ only above the cap. This file keeps every store exact and
clamps only what Knock Outs make irrelevant.

* `GameState.xclampAt K co cp cb` applies `InPlay.clampWith co` to the Active Pokémon of the player
  to move, `clampWith cp` to the opponent's, and `clampWith cb` to every Benched Pokémon
  (milestone M3) (damage as the cap says, Poison strength capped at `K`); nothing else changes,
  the modifier stores included.
* `GameState.xclamp K` is `xclampAt K .hp .hp .hp`, the clamp at move boundaries: damage capped at
  `K`, a bound on every derived HP (milestone M6; before it the clamp capped at the printed HP and
  had no parameter). `GameState.xrclamp K` is `xclampAt K .exact .exact .exact`, the relation used
  inside an attack's effect: damage exact on every Pokémon in play, Poison strength capped at `K`. (Before milestone M4 the
  opponent's damage was capped at a constant `k` inside attacks; since an attack's damage step
  can read that damage, `Amt.per`, and `drain` writes the amount to the attacker, it is kept
  exact.)
* `Run.xcap_sim`: inside an attack's effect, the kernel of `xrclamp` is a simulation for every
  effect whose test constants are below `k` (the bound is no longer needed, and kept). No
  tameness: damage reduction and `drain` are allowed.
* `TRun.xclamp_sim`, `Move.xclamp_sim`, `Reach.xclamp_sim`: the kernel of `xclamp` is a
  simulation for Trainer effects and a (strong) bisimulation for moves and for reachability,
  under `GameState.XFit k`: `hpBound` of the cards (so every derived HP) and every printed
  Resistance are at most `k` and every test constant is below `k`. Nothing is assumed about modifiers, damage reduction or `drain`.
* `Reach.xclamp_bisim`, `GameState.xclamp_bisim`: with `k` computed from the cards, the kernel
  of `xclamp` is a two-way bisimulation for every deck. The first is stated along states
  reachable from a start `g₀`; that premise is vacuous (take `g₀ = g₁`), and the second states
  it for all pairs of states with equal `xclamp`; `GameState.xclamp_bisim_of_le` states it at any
  bound at least `Enum.bound` of the cards.

Why this works, reader by reader. Two states with the same `xrclamp` have identical stores,
hands, decks, discard piles, flags and markers, and the same Pokémon in play (both Active
Pokémon and, since milestone M3, every Benched Pokémon, which effects can damage, heal and switch
into the Active Spot) except in Poison strength above the bound `K`.
* The damage step (`damage a`, `drain a`): the amount evaluates the same (`Amt.Val.of_xrclamp`),
  Weakness and Resistance are read from the same cards and types, and the stores are equal, so
  `dealtBy` is the same in both states, however large and whether or not a reduction offsets a
  bonus; `drain` heals the attacker by that same amount. Weakness, which doubles a quantity
  containing an unbounded stored bonus, is harmless here because the stores are exact.
* Tests (`ite`) and `scale` read damage, which is equal.
* Locks and prevention are flags in the stores, which are equal: the same attacks, retreats and
  Items are legal, and prevention zeroes damage in both states alike.
* Checkup reads damage only from `Settled` states (`endTurn` requires `DamageBounded`), where
  every damage is below its HP and so below `K`, and capping at `K` loses nothing; Poison strength
  at or above `K` adds at least `K`, so at least the derived HP, either way.
* Store shifting at `endTurn` acts on equal stores.
* Every move that resolves an effect (an attack, an Item, a Supporter, each step of a Trainer
  effect under `TRun`) starts `Settled`, where `xclamp` and `xrclamp` agree; Knock Outs read
  damage only against HP, and `xrclamp` determines `xclamp`.

What the stores cost. The clamp no longer bounds the stores, so finiteness of the reachable
clamps needs a separate bound on the stores; that is `Pokemon/Bounded.lean`.
-/

namespace Pokemon

/-- Clamp the player's Active Pokémon by `co`, the opponent's by `cp`, and every Benched Pokémon
of both players by `cb`. Every other component is unchanged, the modifier stores included. -/
def GameState.xclampAt (K : Nat) (co cp cb : Cap) (g : GameState) : GameState :=
  { g with cur := { g.cur with active := g.cur.active.map (InPlay.clampWith K co),
                               bench := g.cur.bench.map (InPlay.clampWith K cb) },
           opp := { g.opp with active := g.opp.active.map (InPlay.clampWith K cp),
                               bench := g.opp.bench.map (InPlay.clampWith K cb) } }

/-- **The clamp with exact stores**, at move boundaries: damage and Poison strength on every
Pokémon in play (both Active Pokémon and, since milestone M3, every Benched Pokémon) capped at `K`
(milestone M6: a bound on every derived HP; before it, the printed HP); the modifier stores, and
everything else, exact. -/
def GameState.xclamp (K : Nat) (g : GameState) : GameState := g.xclampAt K .hp .hp .hp

/-- The relation used inside an attack's effect: damage on every Pokémon in play exact, Poison
strength capped at `K` (milestone M6: before it, at the printed HP), the stores exact. (Before milestone M4 the opponent's damage was capped
at a constant `k` here. An attack's damage step can now read the opponent's damage (`Amt.per`)
and, through `drain`, write the amount to the player's own Pokémon, so damage above any cap can
reach the attacker's exact damage; inside an attack damage is therefore kept exact. Every move
that resolves an effect starts `Settled`, where `xclamp` already determines the damage.) -/
def GameState.xrclamp (K : Nat) (g : GameState) : GameState := g.xclampAt K .exact .exact .exact

/-- Two states with the same `xclampAt K co cp cb` differ at most in the Pokémon in play (both
Active Pokémon and both Benches), each Pokémon only as its cap allows. -/
theorem GameState.xclamp_inv {co cp cb : Cap} {g₁ g₂ : GameState}
    (h : g₁.xclampAt K co cp cb = g₂.xclampAt K co cp cb) :
    ∃ c₂ a₂ e₁ e₂, g₂ = { g₁ with
        cur := { g₁.cur with active := c₂, bench := e₁ },
        opp := { g₁.opp with active := a₂, bench := e₂ } } ∧
      c₂.map (InPlay.clampWith K co) = g₁.cur.active.map (InPlay.clampWith K co) ∧
      a₂.map (InPlay.clampWith K cp) = g₁.opp.active.map (InPlay.clampWith K cp) ∧
      e₁.map (InPlay.clampWith K cb) = g₁.cur.bench.map (InPlay.clampWith K cb) ∧
      e₂.map (InPlay.clampWith K cb) = g₁.opp.bench.map (InPlay.clampWith K cb) := by
  refine ⟨g₂.cur.active, g₂.opp.active, g₂.cur.bench, g₂.opp.bench, ?_,
    (congrArg (fun g => g.cur.active) h).symm, (congrArg (fun g => g.opp.active) h).symm,
    (congrArg (fun g => g.cur.bench) h).symm, (congrArg (fun g => g.opp.bench) h).symm⟩
  have e : g₂ = { g₂.xclampAt K co cp cb with
      cur := { (g₂.xclampAt K co cp cb).cur with active := g₂.cur.active, bench := g₂.cur.bench },
      opp := { (g₂.xclampAt K co cp cb).opp with active := g₂.opp.active, bench := g₂.opp.bench } } :=
    rfl
  refine e.trans ?_
  rw [← h]
  rfl

/-- States with the same `xclampAt` have the same derived quantities (milestone M6). -/
theorem GameState.sameField_of_xclampAt {K : Nat} {co cp cb : Cap} {g₁ g₂ : GameState}
    (h : g₁.xclampAt K co cp cb = g₂.xclampAt K co cp cb) : GameState.SameField g₁ g₂ := by
  have hsv : ∀ (c : Cap) (p : InPlay), (InPlay.clampWith K c p).sv = p.sv := fun _ _ => rfl
  have e1 := congrArg (fun g => g.cur.field) h
  have e2 := congrArg (fun g => g.opp.field) h
  simp only [GameState.xclampAt, PlayerState.field, fieldOf_map (hsv _) (hsv _)] at e1 e2
  exact ⟨by simp only [PlayerState.field]; exact e1.symm, by simp only [PlayerState.field]; exact e2.symm,
    (congrArg GameState.stadium h).symm, (congrArg GameState.curIsFirst h).symm⟩

/-- The clamp with exact stores keeps every count (milestone MV). -/
theorem Count.val_xclampAt (c : Count) (K : Nat) (co cp cb : Cap) (g : GameState) :
    c.val (g.xclampAt K co cp cb) = c.val g := by
  have t1 : ∀ (cb : Cap) (b : List InPlay),
      (b.map (InPlay.clampWith K cb)).map InPlay.top = b.map InPlay.top := fun cb b => by
    rw [List.map_map]; rfl
  have t2 : ∀ (cb : Cap) (b : List InPlay),
      (b.map (InPlay.clampWith K cb)).map InPlay.energy = b.map InPlay.energy := fun cb b => by
    rw [List.map_map]; rfl
  have t3 : ∀ (cb : Cap) (o : Option InPlay),
      (o.map (InPlay.clampWith K cb)).map InPlay.energy = o.map InPlay.energy := fun cb o => by
    cases o <;> rfl
  cases c with
  | pile w z f => cases w <;> cases z <;> rfl
  | prizes w => cases w <;> rfl
  | bench w f => cases w <;> simp only [Count.val, GameState.side, GameState.xclampAt, t1]
  | energy w f => cases w <;> simp only [Count.val, GameState.side, GameState.xclampAt, t3]
  | energyAll w f =>
      cases w <;> simp only [Count.val, GameState.side, GameState.xclampAt, t2, t3]

theorem GameState.count_of_xclampAt {co cp cb : Cap} {g₁ g₂ : GameState}
    (h : g₁.xclampAt K co cp cb = g₂.xclampAt K co cp cb) (c : Count) : c.val g₂ = c.val g₁ := by
  rw [← c.val_xclampAt K co cp cb g₂, ← h, c.val_xclampAt]

/-- The clamp with exact stores determines the stores. -/
theorem GameState.mods_of_xclamp {co cp cb : Cap} {g₁ g₂ : GameState}
    (h : g₁.xclampAt K co cp cb = g₂.xclampAt K co cp cb) :
    g₁.cur.mods = g₂.cur.mods ∧ g₁.opp.mods = g₂.opp.mods :=
  ⟨congrArg (fun g => g.cur.mods) h, congrArg (fun g => g.opp.mods) h⟩

/-- The Active Pokémon read by a test, in states with the same `xrclamp k`. -/
theorem GameState.xactiveOf_exact {g₁ g₂ : GameState}
    (h : g₁.xrclamp K = g₂.xrclamp K) {w : Whose} {p : InPlay} (hp : g₁.activeOf w = some p) :
    ∃ q, g₂.activeOf w = some q ∧ InPlay.Agree K .exact q p := by
  cases w with
  | own =>
      have e := (congrArg (fun g => g.cur.active) h).symm
      simp only [GameState.xrclamp, GameState.xclampAt] at e
      rw [show g₁.cur.active = some p from hp] at e
      exact agree_of_map e
  | opp =>
      have e := (congrArg (fun g => g.opp.active) h).symm
      simp only [GameState.xrclamp, GameState.xclampAt] at e
      rw [show g₁.opp.active = some p from hp] at e
      exact agree_of_map e

theorem GameState.xactiveOf_agree {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.xrclamp k = g₂.xrclamp k) {w : Whose} {p : InPlay} (hp : g₁.activeOf w = some p) :
    ∃ q, g₂.activeOf w = some q ∧ InPlay.Agree k (.upto k) q p := by
  obtain ⟨q, hq, ha⟩ := GameState.xactiveOf_exact h hp
  exact ⟨q, hq, ha.recap ha.damage_eq⟩

/-- An amount of damage evaluates the same in states with the same `xrclamp`. -/
theorem Amt.Val.of_xrclamp {a : Amt} {g₁ g₂ : GameState} {n : Nat} (hv : a.Val g₁ n)
    (h : g₁.xrclamp K = g₂.xrclamp K) : a.Val g₂ n :=
  hv.congr (GameState.count_of_xclampAt h) fun _ _ hp => by
    obtain ⟨q, hq, ha⟩ := GameState.xactiveOf_exact h hp
    exact ⟨q, hq, ha.damage_eq⟩

/-- Weakness and Resistance in effect agree in states with the same `xclampAt`. -/
theorem GameState.wr_of_xclampAt {co cp cb : Cap} {g₁ g₂ : GameState}
    (h : g₁.xclampAt K co cp cb = g₂.xclampAt K co cp cb) :
    g₂.weak = g₁.weak ∧ g₂.resist = g₁.resist := by
  obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, -, -⟩ := GameState.xclamp_inv h
  exact GameState.wr_congr (map_type_top_of_map hc₂).1 (map_type_top_of_map ha₂).2

/-- With no pending Knock Out, equal `xclamp` gives equal `xrclamp k`. -/
theorem GameState.xrclamp_of_xclamp {g₁ g₂ : GameState} (h : g₁.xclamp K = g₂.xclamp K)
    (hk : DamageBounded g₁) (hH : g₁.HpBelow K) : g₁.xrclamp K = g₂.xrclamp K := by
  obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv h
  simp only [GameState.xrclamp, GameState.xclampAt,
    map_exact_of_hp hc₂ fun p hp => hk.lt_bound hH (w := .own) (sp := .active) hp,
    map_exact_of_hp ha₂ fun p hp => hk.lt_bound hH (w := .opp) (sp := .active) hp,
    bench_exact_of_hp he₁ fun p hp => hk.lt_bound hH (w := .own) (sp := .bench) hp,
    bench_exact_of_hp he₂ fun p hp => hk.lt_bound hH (w := .opp) (sp := .bench) hp]

/-- Equal `xrclamp` gives equal `xclamp`. -/
theorem GameState.xclamp_of_xrclamp {g₁ g₂ : GameState} (h : g₁.xrclamp K = g₂.xrclamp K) :
    g₁.xclamp K = g₂.xclamp K := by
  obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv h
  simp only [GameState.xclamp, GameState.xclampAt, map_recap (c := .hp) hc₂,
    map_recap (c := .hp) ha₂, bench_recap (c := .hp) he₁, bench_recap (c := .hp) he₂]

/-- Equal `xclamp` gives equal `clamp k`, for every `k`. -/
theorem GameState.clamp_of_xclamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.xclamp k = g₂.xclamp k) :
    g₁.clamp k = g₂.clamp k := by
  obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv h
  simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂, he₁, he₂]

theorem GameState.damageBounded_of_xclamp {g₁ g₂ : GameState} (h : g₁.xclamp K = g₂.xclamp K)
    (hk : DamageBounded g₁) (hH : g₁.HpBelow K) : DamageBounded g₂ :=
  GameState.damageBounded_of_clamp (GameState.clamp_of_xclamp h) hk hH

theorem GameState.settled_of_xclamp {g₁ g₂ : GameState} (h : g₁.xclamp K = g₂.xclamp K)
    (hs : Settled g₁) (hH : g₁.HpBelow K) : Settled g₂ :=
  GameState.settled_of_clamp (GameState.clamp_of_xclamp h) hs hH

theorem GameState.winner_of_xclamp {g₁ g₂ : GameState} (h : g₁.xclamp K = g₂.xclamp K) :
    g₂.winner = g₁.winner :=
  (congrArg GameState.winner h).symm

/-! ## Knock Outs -/

/-- **The check commutes with the clamp with exact stores**, when every derived HP is at most the
cap. -/
theorem GameState.koStep_xclamp {g : GameState} (hH : g.HpBelow K) :
    (g.xclamp K).koStep = g.koStep.xclamp K :=
  GameState.koStep_mapPlay (f := InPlay.clampWith K .hp) (m := id) (g := g)
    (fun _ => rfl) (fun _ => rfl) (fun w sp p hp => decide_le_min (hH w sp p hp))

/-- **The kernel of `xclamp` is a simulation for the batch Knock Out step**, when every derived HP
is at most `K`. -/
theorem KOBatch.xclamp_sim {g₁ g₁' g₂ : GameState} (h : KOBatch g₁ g₁')
    (hc : g₁.xclamp K = g₂.xclamp K) (hH : g₁.HpBelow K) :
    ∃ g₂', KOBatch g₂ g₂' ∧ g₁'.xclamp K = g₂'.xclamp K := by
  have hH₂ := GameState.hpBelow_of_clamp (GameState.clamp_of_xclamp hc) hH
  have hks : g₁.koStep.xclamp K = g₂.koStep.xclamp K := by
    rw [← GameState.koStep_xclamp hH, hc, GameState.koStep_xclamp hH₂]
  have hwk := GameState.winner_of_xclamp hks
  cases h with
  | won hu hw =>
      exact ⟨_, .won (fun hs => hu (GameState.settled_of_xclamp hc.symm hs hH₂))
        (by rw [hwk]; exact hw), hks⟩
  | @go ac ao bc bo hu hw hpc hpo =>
      obtain ⟨c₂, a₂, e₁, e₂, hg, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hks
      obtain ⟨ac', bc', hpc', hac, hbc⟩ := hpc.sim (a₂ := g₂.koStep.cur.active)
        (b₂ := g₂.koStep.cur.bench) (by rw [hg]; exact hc₂) (by rw [hg]; exact he₁)
      obtain ⟨ao', bo', hpo', hao, hbo⟩ := hpo.sim (a₂ := g₂.koStep.opp.active)
        (b₂ := g₂.koStep.opp.bench) (by rw [hg]; exact ha₂) (by rw [hg]; exact he₂)
      refine ⟨_, .go (fun hs => hu (GameState.settled_of_xclamp hc.symm hs hH₂))
        (by rw [hwk]; exact hw) hpc' hpo', ?_⟩
      have e : ∀ X : GameState, ∀ a b c d, (X.withPlay a b c d).xclamp K =
          (X.xclamp K).withPlay (a.map (InPlay.clampWith K .hp)) (b.map (InPlay.clampWith K .hp))
            (c.map (InPlay.clampWith K .hp)) (d.map (InPlay.clampWith K .hp)) :=
        fun _ _ _ _ _ => rfl
      rw [e, e, hks, hac, hbc, hao, hbo]

/-- The kernel of `xclamp` is a simulation for taking the Knock Outs. -/
theorem Resolve.xclamp_sim {g₁ g₁' : GameState} (h : Resolve g₁ g₁') :
    ∀ {g₂ : GameState}, hpBound g₁.allCards ≤ K → g₁.xclamp K = g₂.xclamp K →
      ∃ g₂', Resolve g₂ g₂' ∧ g₁'.xclamp K = g₂'.xclamp K := by
  induction h with
  | done h =>
      intro g₂ hH hc
      refine ⟨g₂, .done ?_, hc⟩
      rcases h with h | h
      · exact .inl (GameState.settled_of_xclamp hc h (GameState.hpBelow_of_hpBound hH))
      · exact .inr (by rw [GameState.winner_of_xclamp hc]; exact h)
  | step hn hm _ ih =>
      intro g₂ hH hc
      obtain ⟨m₂, hm₂, hcm⟩ := hm.xclamp_sim hc (GameState.hpBelow_of_hpBound hH)
      obtain ⟨g₂', hr₂, hc'⟩ := ih (by rw [hpBound_perm hm.perm]; exact hH) hcm
      exact ⟨g₂', .step (by rw [GameState.winner_of_xclamp hc]; exact hn) hm₂ hr₂, hc'⟩

/-! ## Inside an attack's effect -/

/-- **Inside an attack's effect, the kernel of `xrclamp` is a simulation**, for every effect
whose test constants are below `k`: damage reduction, `drain`, rest-of-game modifiers and
`linger` inside `iter` are all allowed. Two states that agree except in Poison strength above
HP have the same effect resolutions, up to the same relation. -/
theorem Run.xcap_sim {k : Nat} {e : Effect} {g₁ g₁' : GameState} (h : Run e g₁ g₁') :
    e.tmax < k → ∀ {g₂ : GameState}, g₁.xrclamp k = g₂.xrclamp k →
      ∃ g₂', Run e g₂ g₂' ∧ g₁'.xrclamp k = g₂'.xrclamp k := by
  induction h with
  | skip g => intro _ g₂ hc; exact ⟨g₂, .skip g₂, hc⟩
  | draw h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .draw h, by simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂]⟩
  | drawEmpty h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .drawEmpty h, hc⟩
  | @heal g p n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have hq' : InPlay.Agree k .exact { q with damage := q.damage - n }
          { p with damage := p.damage - n } := by
        rw [hq.damage_eq]; exact hq.setDamage _
      exact ⟨_, .heal n rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some,
          InPlay.clamp_of_agree hq', ha₂, he₁, he₂]⟩
  | counters n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .counters n rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n), he₁, he₂]⟩
  | inflict c h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .inflict c rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.2.2.1 c), he₁, he₂]⟩
  | poisonUp n h hp =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUp n rfl (hq.poisoned.trans hp), by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.2.1 n), he₁, he₂]⟩
  | poisonUpSkip n h hp =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUpSkip n rfl (hq.poisoned.trans hp), hc⟩
  | cure h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .cure rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree hq.upd.2.2.2.2.1, he₁, he₂]⟩
  | iteT h ht' _ ih =>
      intro hb g₂ hc
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree (k := k) hc h
      obtain ⟨g₂', r', hc'⟩ := ih (by omega) hc
      exact ⟨g₂', .iteT hq (by rw [Test.eval_agree _ (GameState.count_of_xclampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | iteF h ht' _ ih =>
      intro hb g₂ hc
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree (k := k) hc h
      obtain ⟨g₂', r', hc'⟩ := ih (by omega) hc
      exact ⟨g₂', .iteF hq (by rw [Test.eval_agree _ (GameState.count_of_xclampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | @scale g p q w k' hs h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q₂, rfl, hq⟩ := agree_of_map ha₂
      cases w with
      | own =>
          change g.cur.active = some p at hs
          rw [hs] at hc₂
          obtain ⟨s, rfl, hsa⟩ := agree_of_map hc₂
          have hq' : InPlay.Agree k .exact { q₂ with damage := q₂.damage + k' * s.damage }
              { q with damage := q.damage + k' * p.damage } := by
            rw [hsa.damage_eq]; exact hq.upd.2.1 _
          exact ⟨_, .scale .own k' rfl rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hs,
              InPlay.clamp_of_agree hq', InPlay.clamp_of_agree hsa, he₁, he₂]⟩
      | opp =>
          change g.opp.active = some p at hs
          have e : q = p := Option.some.inj (h.symm.trans hs)
          subst e
          have hq' : InPlay.Agree k .exact { q₂ with damage := q₂.damage + k' * q₂.damage }
              { q with damage := q.damage + k' * q.damage } := by
            rw [hq.damage_eq]; exact hq.setDamage _
          exact ⟨_, .scale .opp k' rfl rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hc₂,
              InPlay.clamp_of_agree hq', he₁, he₂]⟩
  | @selfDamage g p n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .selfDamage n rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n), he₁, he₂]⟩
  | @healAll g p h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .healAll rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.setDamage 0), he₁, he₂]⟩
  | @touchActive e w f g p he h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h] at hc₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, Option.map_some,
              ha₂, InPlay.clamp_of_agree (hq.setMarks f), he₁, he₂]⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h] at ha₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, Option.map_some,
              hc₂, InPlay.clamp_of_agree (hq.setMarks f), he₁, he₂]⟩
  | @touchBench e w f g q b₁ b₂ he h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
          exact ⟨_, .touchBench (w := .own) he rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₂,
              List.map_append, List.map_cons, h1, h3, InPlay.clampWith_setMarks', h2]⟩
      | opp =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₂)
          exact ⟨_, .touchBench (w := .opp) he rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₁,
              List.map_append, List.map_cons, h1, h3, InPlay.clampWith_setMarks', h2]⟩
  | unmark w m g =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w <;>
        exact ⟨_, .unmark _ m _, by
          simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, PlayerState.unmark,
            hc₂, ha₂, map_clamp_setMarks _ hc₂, map_clamp_setMarks _ ha₂,
            bench_map_comm (InPlay.clampWith_setMarks' _ _) he₁,
            bench_map_comm (InPlay.clampWith_setMarks' _ _) he₂, he₁, he₂]⟩
  | linger w s m g =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w <;>
        exact ⟨_, .linger _ s m _, by
          simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₁, he₂]⟩
  | @damage g p a n hv h =>
      intro _ g₂ hc
      have hv₂ := hv.of_xrclamp hc
      have hwr := GameState.wr_of_xclampAt hc
      have hsf := GameState.sameField_of_xclampAt hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      have e : GameState.dealt n
          { g with cur := { g.cur with active := c₂, bench := e₁ },
                   opp := { g.opp with active := some q, bench := e₂ } } = g.dealt n := by
        simp only [GameState.dealt, hwr.1, hwr.2, hsf.sBonus, hsf.sReduce]
      exact ⟨_, .damage hv₂ rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, e, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.1 (g.dealt n)), he₁, he₂]⟩
  | @drain g p q a n hv h hq =>
      intro _ g₂ hc
      have hv₂ := hv.of_xrclamp hc
      have hwr := GameState.wr_of_xclampAt hc
      have hsf := GameState.sameField_of_xclampAt hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      rw [hq] at hc₂
      obtain ⟨p₂, rfl, hp₂⟩ := agree_of_map ha₂
      obtain ⟨q₂, rfl, hq₂⟩ := agree_of_map hc₂
      have e : GameState.dealt n
          { g with cur := { g.cur with active := some q₂, bench := e₁ },
                   opp := { g.opp with active := some p₂, bench := e₂ } } = g.dealt n := by
        simp only [GameState.dealt, hwr.1, hwr.2, hsf.sBonus, hsf.sReduce]
      have hq' : InPlay.Agree k .exact
          { q₂ with damage := q₂.damage - g.dealt n } { q with damage := q.damage - g.dealt n } := by
        rw [hq₂.damage_eq]; exact hq₂.setDamage _
      exact ⟨_, .drain hv₂ rfl rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, e, Option.map_some,
          InPlay.clamp_of_agree hq', InPlay.clamp_of_agree (hp₂.upd.2.1 (g.dealt n)), he₁, he₂]⟩
  | @benchCounters g q b₁ b₂ w n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
          have hr := InPlay.agree_of_clamp h2
          exact ⟨_, .benchCounters (b₁ := d₁) .own n rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₂,
              List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.upd.2.1 n)]⟩
      | opp =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₂)
          have hr := InPlay.agree_of_clamp h2
          exact ⟨_, .benchCounters (b₁ := d₁) .opp n rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₁,
              List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.upd.2.1 n)]⟩
  | benchCountersNone w n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₁
          subst he₁
          exact ⟨_, .benchCountersNone .own n rfl, hc⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₂
          subst he₂
          exact ⟨_, .benchCountersNone .opp n rfl, hc⟩
  | spreadCounters w n g =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w <;>
        exact ⟨_, .spreadCounters _ n _, by
          simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₁, he₂,
            bench_map_comm (InPlay.clampWith_exact_addDamage n) he₁,
            bench_map_comm (InPlay.clampWith_exact_addDamage n) he₂]⟩
  | moveCounter h =>
      intro _ g₂ hc
      have hsf := GameState.sameField_of_xclampAt hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      obtain ⟨a₂', b₂', hm, ha', hb'⟩ := h.sim (fun sp _ _ hxy => hsf.hpOf .own sp hxy) hc₂ he₁
      exact ⟨_, .moveCounter hm, by
        simp only [GameState.xrclamp, GameState.xclampAt, ha', hb', ha₂, he₂]⟩
  | @benchHeal g q b₁ b₂ n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      have hr' : InPlay.Agree k .exact { r with damage := r.damage - n }
          { q with damage := q.damage - n } := by
        rw [hr.damage_eq]; exact hr.setDamage _
      exact ⟨_, .benchHeal n rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂, he₂, List.map_append, List.map_cons, h1, h3,
          InPlay.clamp_of_agree hr']⟩
  | @switch g a q b₁ b₂ w ha h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at ha h
          rw [ha] at hc₂
          obtain ⟨a', rfl, hqa⟩ := agree_of_map hc₂
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
          exact ⟨_, .switch (b₁ := d₁) .own rfl rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, ha₂, he₂, Option.map_some,
              List.map_append, List.map_cons, h1, h2, h3, InPlay.clamp_of_agree hqa.upd.2.2.2.2.1]⟩
      | opp =>
          simp only [GameState.side] at ha h
          rw [ha] at ha₂
          obtain ⟨a', rfl, hqa⟩ := agree_of_map ha₂
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₂)
          exact ⟨_, .switch (b₁ := d₁) .opp rfl rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, he₁, Option.map_some,
              List.map_append, List.map_cons, h1, h2, h3, InPlay.clamp_of_agree hqa.upd.2.2.2.2.1]⟩
  | switchNone w h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₁
          subst he₁
          exact ⟨_, .switchNone .own rfl, hc⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₂
          subst he₂
          exact ⟨_, .switchNone .opp rfl, hc⟩
  | @benchDamage g q b₁ b₂ w n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₁)
          have hr := InPlay.agree_of_clamp h2
          exact ⟨_, .benchDamage (b₁ := d₁) .own n rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₂,
              List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.hitBench n)]⟩
      | opp =>
          simp only [GameState.side] at h
          obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (h ▸ he₂)
          have hr := InPlay.agree_of_clamp h2
          exact ⟨_, .benchDamage (b₁ := d₁) .opp n rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₁,
              List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.hitBench n)]⟩
  | benchDamageNone w n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₁
          subst he₁
          exact ⟨_, .benchDamageNone .own n rfl, hc⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h, List.map_nil, List.map_eq_nil_iff] at he₂
          subst he₂
          exact ⟨_, .benchDamageNone .opp n rfl, hc⟩
  | spreadDamage w n g =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w <;>
        exact ⟨_, .spreadDamage _ n _, by
          simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂, he₁, he₂,
            bench_map_agree (U := InPlay.hitBench n) (fun x y h => h.hitBench n) he₁,
            bench_map_agree (U := InPlay.hitBench n) (fun x y h => h.hitBench n) he₂]⟩
  | benchHealNone n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      rw [h, List.map_nil, List.map_eq_nil_iff] at he₁
      subst he₁
      exact ⟨_, .benchHealNone n rfl, hc⟩
  | shuffle h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .shuffle h, by simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂]⟩
  | search h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .search h, by simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂]⟩
  | handToBottom h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .handToBottom h, by
        simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂]⟩
  | discardStadium g =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .discardStadium _, by
        simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂]⟩
  | @zone e w g s' hw hz =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          obtain ⟨s₂', hz₂, hag⟩ := hz.sim (s₂ := { g.cur with active := c₂, bench := e₁ })
            ⟨rfl, rfl, rfl, hc₂, he₁⟩
          exact ⟨_, .zone hw hz₂, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide,
              PlayerState.setZones, hag.deck, hag.hand, hag.discard, hag.active, hag.bench, ha₂,
              he₂]⟩
      | opp =>
          obtain ⟨s₂', hz₂, hag⟩ := hz.sim (s₂ := { g.opp with active := a₂, bench := e₂ })
            ⟨rfl, rfl, rfl, ha₂, he₂⟩
          exact ⟨_, .zone hw hz₂, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide,
              PlayerState.setZones, hag.deck, hag.hand, hag.discard, hag.active, hag.bench, hc₂,
              he₁]⟩
  | seq _ _ ih₁ ih₂ =>
      intro hb g₂ hc
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ (by omega) hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ (by omega) hc'
      exact ⟨g₂'', .seq r₁ r₂, hc''⟩
  | choiceL _ ih =>
      intro hb g₂ hc
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih (by omega) hc
      exact ⟨g₂', .choiceL r, hc'⟩
  | choiceR _ ih =>
      intro hb g₂ hc
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih (by omega) hc
      exact ⟨g₂', .choiceR r, hc'⟩
  | iterNil a g => intro _ g₂ hc; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons _ _ ih₁ ih₂ =>
      intro hb g₂ hc
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ hb hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ hb hc'
      exact ⟨g₂'', .iterCons r₁ r₂, hc''⟩

/-! ## Trainer effects -/

/-- **The kernel of `xclamp` is a simulation for Trainer effects** (`TRun`), from a state that
is `Settled` or finished, for every effect with test constants below `k`, when every HP is at
most `k`. -/
theorem TRun.xclamp_sim {k : Nat} {e : Effect} {g₁ g₁' : GameState} (h : TRun e g₁ g₁') :
    e.tmax < k → g₁.HpLe k → ∀ {g₂ : GameState},
      g₁.xclamp k = g₂.xclamp k → (Settled g₁ ∨ g₁.winner ≠ none) →
        ∃ g₂', TRun e g₂ g₂' ∧ g₁'.xclamp k = g₂'.xclamp k := by
  induction h with
  | prim he hn hr hk =>
      intro hb hhp g₂ hc hs
      have hs : Settled _ := hs.resolve_right (fun h => h hn)
      obtain ⟨m₂, hr₂, hcm⟩ := Run.xcap_sim hr hb (GameState.xrclamp_of_xclamp hc hs.1 hhp.below)
      have hhp' := hhp.of_perm hr.perm
      obtain ⟨g₂', hk₂, hc'⟩ := hk.xclamp_sim hhp'.1 (GameState.xclamp_of_xrclamp hcm)
      exact ⟨g₂', .prim he (by rw [GameState.winner_of_xclamp hc]; exact hn) hr₂ hk₂, hc'⟩
  | stop hn =>
      intro _ _ g₂ hc _
      exact ⟨g₂, .stop (by rw [GameState.winner_of_xclamp hc]; exact hn), hc⟩
  | iteT hn h ht' _ ih =>
      intro hb hhp g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree (k := k) (GameState.xrclamp_of_xclamp hc hs'.1 hhp.below) h
      obtain ⟨g₂', r', hc'⟩ := ih (by omega) hhp hc hs
      exact ⟨g₂', .iteT (by rw [GameState.winner_of_xclamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ (GameState.count_of_xclampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | iteF hn h ht' _ ih =>
      intro hb hhp g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree (k := k) (GameState.xrclamp_of_xclamp hc hs'.1 hhp.below) h
      obtain ⟨g₂', r', hc'⟩ := ih (by omega) hhp hc hs
      exact ⟨g₂', .iteF (by rw [GameState.winner_of_xclamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ (GameState.count_of_xclampAt hc) hqa (by omega)]; exact ht') r', hc'⟩
  | seq h₁ _ ih₁ ih₂ =>
      intro hb hhp g₂ hc hs
      simp only [Effect.tmax] at hb
      obtain ⟨m₂, r₁, hcm⟩ := ih₁ (by omega) hhp hc hs
      obtain ⟨g₂', r₂, hc'⟩ := ih₂ (by omega) (hhp.of_perm h₁.perm) hcm (h₁.settled_or_won hs)
      exact ⟨g₂', .seq r₁ r₂, hc'⟩
  | choiceL _ ih =>
      intro hb hhp g₂ hc hs
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih (by omega) hhp hc hs
      exact ⟨g₂', .choiceL r, hc'⟩
  | choiceR _ ih =>
      intro hb hhp g₂ hc hs
      simp only [Effect.tmax] at hb
      obtain ⟨g₂', r, hc'⟩ := ih (by omega) hhp hc hs
      exact ⟨g₂', .choiceR r, hc'⟩
  | iterNil a g => intro _ _ g₂ hc _; exact ⟨g₂, .iterNil a g₂, hc⟩
  | iterCons h₁ _ ih₁ ih₂ =>
      intro hb hhp g₂ hc hs
      obtain ⟨m₂, r₁, hcm⟩ := ih₁ hb hhp hc hs
      obtain ⟨g₂', r₂, hc'⟩ := ih₂ hb (hhp.of_perm h₁.perm) hcm (h₁.settled_or_won hs)
      exact ⟨g₂', .iterCons r₁ r₂, hc'⟩

/-! ## Moves -/

/-- The conditions under which the kernel of `xclamp` is a bisimulation for moves: `hpBound` of
the cards, which bounds every derived HP, and every Resistance are at most `k` (`GameState.HpLe`;
milestone M6: before it, every printed HP), and every card's test constants are below `k`. Nothing about modifiers, damage reduction or `drain`. (Since milestone
M4 damage inside an attack is kept exact, so the proof of `Move.xclamp_sim` no longer needs the
bound on HP and Resistance; the definition keeps it, and the statements are unchanged.) -/
def GameState.XFit (k : Nat) (g : GameState) : Prop :=
  g.HpLe k ∧ ∀ x ∈ g.allCards, x.tmax < k

theorem GameState.XFit.of_perm {k : Nat} {g g' : GameState} (h : g.XFit k)
    (hp : g'.allCards.Perm g.allCards) : g'.XFit k :=
  ⟨h.1.of_perm hp, fun x hx => h.2 x (hp.mem_iff.1 hx)⟩

theorem Move.xfit {k : Nat} {g g' : GameState} (h : Move g g') (hF : g.XFit k) : g'.XFit k :=
  hF.of_perm h.perm

theorem Reach.xfit {k : Nat} {g₀ g : GameState} (h : Reach g₀ g) (hF : g₀.XFit k) : g.XFit k :=
  hF.of_perm h.perm

/-- Every start state is `XFit` at `bound` of its cards. -/
theorem GameState.xfit_bound (g₀ : GameState) : g₀.XFit (Enum.bound g₀.allCards) := by
  refine ⟨⟨by simp only [Enum.bound]; omega, fun p hp => ?_⟩, fun x hx => ?_⟩
  · have := resist_le_maxResist hp; simp only [Enum.bound]; omega
  · have := tmax_le_cardsTmax hx; simp only [Enum.bound]; omega

/-- `XFit k` transfers along equal `xclamp`. -/
theorem GameState.XFit.of_xclamp {k : Nat} {g₁ g₂ : GameState} (hF : g₁.XFit k)
    (hc : g₁.xclamp k = g₂.xclamp k) : g₂.XFit k := by
  obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
  refine hF.of_perm ?_
  have f₁ := optCardList_of_map hc₂
  have f₂ := optCardList_of_map ha₂
  simp only [GameState.allCards, PlayerState.allCards, f₁, f₂, benchCardList_of_map he₁,
    benchCardList_of_map he₂]
  exact .refl _

/-- The effect an attack resolves has test constants below `k`. -/
theorem GameState.XFit.attack {k : Nat} {g : GameState} (hF : g.XFit k) {a : InPlay}
    {atk : Attack} (ha : g.cur.active = some a) (hm : atk ∈ a.attacks) :
    atk.script.tmax < k := by
  obtain ⟨c, hc, hmc⟩ := InPlay.attack_mem hm
  have hb := hF.2 _ (GameState.mem_allCards_of_cur_active ha hc)
  have h2 : atk.effect.tmax ≤ c.tmax := by
    cases c with
    | pokemon p => have := attacksTmax_mem (as := p.attacks) hmc; simp only [Card.tmax]; omega
    | tool n gr => have := attacksTmax_mem (as := gr.attacks) hmc; simp only [Card.tmax]; omega
    | _ => nomatch hmc
  rw [Attack.script_tmax]; omega

/-- An Ability's test constants, its condition's included, are below `k` (milestone M8a). -/
theorem GameState.XFit.ability {k : Nat} {g g₁ : GameState} (hF : g.XFit k) {x : InPlay}
    {sp : Spot} {ab : Ability} (hu : UseAt g x sp g₁) (hm : ab ∈ x.abilities) :
    ab.tmax < k := by
  obtain ⟨c, hc, hmc⟩ := InPlay.ability_mem hm
  exact Nat.lt_of_le_of_lt (Card.ability_tmax hmc) (hF.2 _ (hu.card_mem hc))

/-- **A play from the hand commutes with `xclamp`** (milestone M8a). -/
theorem PlayFromHand.xclamp_sim {g₁ g₁' g₂ : GameState} {x : InPlay} {w : PlayWay}
    (h : PlayFromHand g₁ x w g₁') (hc : g₁.xclamp K = g₂.xclamp K) (hH : g₁.HpBelow K) :
    ∃ x' g₂', PlayFromHand g₂ x' w g₂' ∧ x'.top = x.top ∧ g₁'.xclamp K = g₂'.xclamp K := by
  have hs₂ := fun hs => GameState.settled_of_xclamp hc hs hH
  obtain ⟨c₂, a₂, e₁, e₂, hg, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
  cases h with
  | basic hh hs hhp hb hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, _, .basic hh hs hhp (by rw [length_of_map he₁]; exact hb) hbt hs' hat, rfl, by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂, List.map_append]⟩
  | @evolve l₁ l₂ p a hh ha he hfr hf hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
      refine ⟨_, _, .evolve hh rfl (by rw [hq.top]; exact he) (hq.fresh.trans hfr) hf hbt hs' hat,
        rfl, ?_⟩
      rw [e]
      simp only [GameState.xclamp, GameState.xclampAt, ha₂, he₁, he₂]
  | @evolveBench l₁ l₂ p q b₁ b₂ hh hb he hfr hf hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      have hlt : q.damage < _ := hst.1.lt_bound hH (w := .own) (sp := .bench)
        (show q ∈ g₁.cur.bench by rw [hb]; exact List.mem_append_right _ (.head _))
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      have e := hr.eq_upd (hr.damage_eq_of_lt hlt)
      refine ⟨_, _, .evolveBench hh rfl (by rw [hr.top]; exact he) (hr.fresh.trans hfr) hf hbt hs'
        hat, rfl, ?_⟩
      rw [e]
      simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₂, List.map_append,
        List.map_cons, h1, h3]

/-- An Ability's condition holds in a state with the same `xclamp`, with no Knock Out pending
(milestone M8a). -/
theorem Ability.CondOk.of_xclamp {k : Nat} {ab : Ability} {g₁ g₂ : GameState} (h : ab.CondOk g₁)
    (hc : g₁.xclamp k = g₂.xclamp k) (hk : DamageBounded g₁) (hb : ab.tmax < k)
    (hH : g₁.HpBelow k) : ab.CondOk g₂ := by
  unfold Ability.CondOk at h ⊢
  cases hcd : ab.cond with
  | none => trivial
  | some t =>
      rw [hcd] at h
      obtain ⟨p, hp, he⟩ := h
      have ht : t.bound < k := by simp only [Ability.tmax, hcd] at hb; omega
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree (k := k) (GameState.xrclamp_of_xclamp hc hk hH) hp
      exact ⟨q, hq, by rw [Test.eval_agree _ (GameState.count_of_xclampAt hc) hqa ht]; exact he⟩

/-- **Marking a Pokémon as having used an Ability commutes with `xclamp`** (milestone M8a). -/
theorem UseAt.xclamp_sim {g₁ g₁' g₂ : GameState} {x : InPlay} {sp : Spot}
    (hu : UseAt g₁ x sp g₁') (hc : g₁.xclamp K = g₂.xclamp K) :
    ∃ x' g₂', UseAt g₂ x' sp g₂' ∧ x'.top = x.top ∧ x'.used = x.used ∧
      x'.abilities = x.abilities ∧ g₁'.xclamp K = g₂'.xclamp K := by
  obtain ⟨c₂, a₂, e₁, e₂, hg, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
  subst hg
  cases hu with
  | active ha =>
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨q, _, .active rfl, hq.top, hq.used, hq.grants.2, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha₂, he₁, he₂,
          InPlay.clamp_of_agree hq.markUsed]⟩
  | @bench b₁ b₂ hb =>
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      exact ⟨r, _, .bench rfl, hr.top, hr.used, hr.grants.2, by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₂, List.map_append,
          List.map_cons, h1, h3, InPlay.clamp_of_agree hr.markUsed]⟩

/-! ## Triggers under the exact-store clamp (milestone M8b) -/

/-- Equal `xclampAt` is equal `clampAt` (with the Bench cap on both Benches) and equal stores. -/
theorem GameState.xclampAt_iff {K : Nat} {co cp cb : Cap} {g₁ g₂ : GameState} :
    g₁.xclampAt K co cp cb = g₂.xclampAt K co cp cb ↔
      g₁.clampAt co cp cb cb K = g₂.clampAt co cp cb cb K ∧ g₁.cur.mods = g₂.cur.mods ∧
        g₁.opp.mods = g₂.opp.mods := by
  constructor
  · intro h
    obtain ⟨c₂, a₂, e₁, e₂, rfl, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv h
    exact ⟨by simp only [GameState.clampAt, hc₂, ha₂, he₁, he₂], rfl, rfl⟩
  · rintro ⟨h, h1, h2⟩
    obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, -, -, he₁, he₂⟩ := GameState.clamp_inv h
    simp only at h1 h2
    subst h1 h2
    simp only [GameState.xclampAt, hc₂, ha₂, he₁, he₂]

/-- **A trigger resolution is simulated under the exact-store clamp, at any caps.** -/
theorem Fire.xclamp_sim {K : Nat} {co cp cb : Cap} {ev : TrigEvent} {l : List Ability}
    {g₁ g₁' g₂ : GameState} (h : Fire ev l g₁ g₁')
    (hc : g₁.xclampAt K co cp cb = g₂.xclampAt K co cp cb) :
    ∃ g₂', Fire ev l g₂ g₂' ∧ g₁'.xclampAt K co cp cb = g₂'.xclampAt K co cp cb := by
  obtain ⟨hc', h1, h2⟩ := GameState.xclampAt_iff.1 hc
  obtain ⟨g₂', h₂, e⟩ := h.clamp_sim hc'
  have z₁ := h.zoneOnly
  have z₂ := h₂.zoneOnly
  exact ⟨g₂', h₂, GameState.xclampAt_iff.2 ⟨e, by rw [z₁.cur_mods, z₂.cur_mods, h1],
    by rw [z₁.opp_mods, z₂.opp_mods, h2]⟩⟩

/-- Whether the opponent's Active Pokémon's damage rose, read through the damage alone. -/
theorem GameState.damagedB_eq (g g' : GameState) : g.damagedB g' =
    (match g.opp.active.map InPlay.damage, g'.opp.active.map InPlay.damage with
      | some a, some b => decide (a < b)
      | _, _ => false) := by
  unfold GameState.damagedB
  cases g.opp.active <;> cases g'.opp.active <;> rfl

theorem opt_exact_agree {K : Nat} {o₁ o₂ : Option InPlay}
    (h : o₂.map (InPlay.clampWith K .exact) = o₁.map (InPlay.clampWith K .exact)) (ev : TrigEvent) :
    o₂.map InPlay.damage = o₁.map InPlay.damage ∧ optTrigs ev o₂ = optTrigs ev o₁ := by
  have d : ∀ o : Option InPlay,
      o.map InPlay.damage = (o.map (InPlay.clampWith K .exact)).map InPlay.damage := by
    intro o; cases o <;> rfl
  have t : ∀ o : Option InPlay, optTrigs ev o = optTrigs ev (o.map (InPlay.clampWith K .exact)) := by
    intro o; cases o <;> rfl
  exact ⟨by rw [d o₂, d o₁, h], by rw [t o₂, t o₁, h]⟩

/-- **Which `damaged` triggers an attack fires is the same under the exact clamp.** -/
theorem HitTrig.xclamp_sim {K : Nat} {atk : Attack} {g₁ g₁' g₂ g₂' : GameState} {l : List Ability}
    (h : HitTrig atk g₁ g₁' l) (hc : g₁.xrclamp K = g₂.xrclamp K)
    (hc' : g₁'.xrclamp K = g₂'.xrclamp K) : HitTrig atk g₂ g₂' l := by
  obtain ⟨a1, -⟩ := opt_exact_agree (congrArg (fun g => g.opp.active) hc).symm .damaged
  obtain ⟨a2, t2⟩ := opt_exact_agree (congrArg (fun g => g.opp.active) hc').symm .damaged
  have key : g₂.damagedB g₂' = g₁.damagedB g₁' := by
    rw [GameState.damagedB_eq, GameState.damagedB_eq, a1, a2]
  cases h with
  | quiet hq => exact .quiet fun hcl => key.trans (hq hcl)
  | fire hd hl => exact .fire (key.trans hd) (t2 ▸ hl)

/-- The triggers a check fires are the same in two states with the same `xclamp`. -/
theorem GameState.koTrigs_of_xclamp {g₁ g₂ : GameState} (hc : g₁.xclamp K = g₂.xclamp K)
    (hH : g₁.HpBelow K) (hH₂ : g₂.HpBelow K) : g₁.koTrigs = g₂.koTrigs := by
  have e : ∀ {g : GameState}, g.HpBelow K → (g.xclamp K).koTrigs = g.koTrigs := fun {g} h =>
    GameState.koTrigs_mapPlay (f := InPlay.clampWith K .hp) (m := id) (g := g)
      (fun _ => rfl) (fun _ => rfl) (fun w sp p hp => decide_le_min (h w sp p hp))
  rw [← e hH, hc, e hH₂]

/-- **The kernel of `xclamp` is a bisimulation for `Move`**, for a state that is `XFit k`, with
no hypothesis on damage reduction, `drain` or modifiers: if `g₁` and `g₂` have the same
`xclamp`, every move from `g₁` is matched by a move from `g₂` to a state with the same `xclamp`.
(`XFit k` transfers to `g₂`, `GameState.XFit.of_xclamp`, so this gives both directions.) -/
theorem Move.xclamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} (hF : g₁.XFit k) (h : Move g₁ g₁')
    (hc : g₁.xclamp k = g₂.xclamp k) : ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp k = g₂'.xclamp k := by
  have hH : g₁.HpBelow k := hF.1.below
  have hsf := GameState.sameField_of_xclampAt hc
  have hk₂ := fun hk => GameState.damageBounded_of_xclamp hc hk hH
  have hs₂ := fun hs => GameState.settled_of_xclamp hc hs hH
  obtain ⟨c₂, a₂, e₁, e₂, hg, hc₂, ha₂, he₁, he₂⟩ := GameState.xclamp_inv hc
  cases h with
  | playBasic hh hs hhp hb hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, .playBasic hh hs hhp (by rw [length_of_map he₁]; exact hb) hbt hs' hat, by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂, List.map_append]⟩
  | @attach l₁ l₂ t a hh hf ha hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have key := hq.clamp_map (c' := .hp) (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
        (fun x => { x with energy := Card.energy t :: x.energy }) (fun _ => rfl) rfl rfl
      exact ⟨_, .attach hh hf rfl hbt hs' hat, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha₂, key, he₁, he₂]⟩
  | @evolve l₁ l₂ p a hh ha he hfr hf hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
      refine ⟨_, .evolve hh rfl (by rw [hq.top]; exact he) (hq.fresh.trans hfr) hf hbt hs' hat, ?_⟩
      rw [e]
      simp only [GameState.xclamp, GameState.xclampAt, ha₂, he₁, he₂]
  | @attachBench l₁ l₂ t q b₁ b₂ hh hf hb hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      exact ⟨_, .attachBench hh hf rfl hbt hs' hat, by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₂, List.map_append, List.map_cons, h1, h3,
          hr.energy, InPlay.clamp_of_agree (hr.upd.1 (Card.energy t :: q.energy))]⟩
  | @evolveBench l₁ l₂ p q b₁ b₂ hh hb he hfr hf hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      have hlt : q.damage < _ := hst.1.lt_bound hH (w := .own) (sp := .bench)
        (show q ∈ g₁.cur.bench by rw [hb]; exact List.mem_append_right _ (.head _))
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      have e := hr.eq_upd (hr.damage_eq_of_lt hlt)
      refine ⟨_, .evolveBench hh rfl (by rw [hr.top]; exact he) (hr.fresh.trans hfr) hf hbt hs'
        hat, ?_⟩
      rw [e]
      simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₂, List.map_append, List.map_cons, h1, h3]
  | @retreat a q' b₁ b₂ paid rest ha hb hr he hp hs hbt hst hl hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      refine ⟨_, .retreat rfl rfl hr (hq.energy.trans he) (by rw [hsf.retreatOf hq.sv]; exact hp)
        (by rw [hq.rot]; exact hs) hbt hs' hl hat, ?_⟩
      rw [e]
      simp only [GameState.xclamp, GameState.xclampAt, ha₂, he₂, Option.map_some,
        List.map_append, List.map_cons, h1, h2, h3]
  | @item g' l₁ l₂ n e hh hbt hst hr hl hat hnd hbh =>
      have hs' := hs₂ hst
      have hx : Card.trainer n .item e ∈ g₁.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hb := hF.2 _ (GameState.mem_allCards_of_hand hx)
      have hp : ({ g₁ with cur := { g₁.cur with
          hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g₁.cur.discard } } :
          GameState).allCards.Perm g₁.allCards := by perm_count [hh]
      obtain ⟨g₂', hr', hc'⟩ := hr.xclamp_sim hb (hF.1.of_perm hp)
        (g₂ := { g₂ with cur := { g₂.cur with
          hand := l₁ ++ l₂, discard := Card.trainer n .item e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂])
        (.inl (hst.congr rfl rfl rfl rfl rfl rfl))
      exact ⟨g₂', .item (by subst hg; exact hh) (by subst hg; exact hbt) hs' hr'
        (by subst hg; exact hl) (by subst hg; exact hat) hnd hbh, hc'⟩
  | @onPlay g₁m g' x how w ab hp hm hk hw hst₁ hcd hr hnd hbh =>
      have hb := Nat.lt_of_le_of_lt (Card.ability_tmax hm) (hF.2 _ hp.top_mem)
      obtain ⟨x', g₂m, hp', hxt, hcm⟩ := hp.xclamp_sim hc hH
      have hH₁ : g₁m.HpBelow k := (hF.1.of_perm hp.perm).below
      have hst₂ := GameState.settled_of_xclamp hcm hst₁ hH₁
      have hcd' := hcd.of_xclamp hcm hst₁.1 hb hH₁
      obtain ⟨g₂', hr', hc'⟩ := hr.xclamp_sim (Nat.lt_of_le_of_lt (ab.script_tmax_le _) hb)
        (hF.1.of_perm hp.perm) hcm (.inl hst₁)
      exact ⟨g₂', .onPlay hp' (hxt ▸ hm) hk hw hst₂ hcd' hr' hnd hbh, hc'⟩
  | @stadium l₁ l₂ n e ss hh hs hn hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, .stadium hh hs hn hbt hs' hat, by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂]⟩
  | @stadiumUse g' o n e ss hs hu hbt hst hat hr hnd hbh =>
      have hs' := hs₂ hst
      have hb := hF.2 _ (GameState.mem_allCards_of_stadium hs)
      obtain ⟨g₂', hr', hc'⟩ := hr.xclamp_sim hb hF.1
        (g₂ := { g₂ with stadiumUsed := true })
        (by subst hg; simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂])
        (.inl (hst.congr rfl rfl rfl rfl rfl rfl))
      exact ⟨g₂', .stadiumUse (by subst hg; exact hs) (by subst hg; exact hu)
        (by subst hg; exact hbt) hs' (by subst hg; exact hat) hr' hnd hbh, hc'⟩
  | @tool l₁ l₂ n gr a hh ha ht hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have key := hq.clamp_map (c' := .hp) (hq.damage_eq_of_lt (hst.1.lt_bound hH (w := .own) (sp := .active) ha))
        (fun x => { x with tools := [Card.tool n gr] }) (fun _ => rfl) rfl rfl
      exact ⟨_, .tool hh rfl (hq.tools.trans ht) hbt hs' hat, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha₂, key, he₁, he₂]⟩
  | @toolBench l₁ l₂ n gr q b₁ b₂ hh hb ht hbt hst hat =>
      have hs' := hs₂ hst
      subst hg
      obtain ⟨d₁, r, d₂, rfl, h1, h2, h3⟩ := map_eq_split (hb ▸ he₁)
      have hr := InPlay.agree_of_clamp h2
      exact ⟨_, .toolBench hh rfl (hr.tools.trans ht) hbt hs' hat, by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₂, List.map_append,
          List.map_cons, h1, h3, InPlay.clamp_of_agree (hr.setTools [Card.tool n gr])]⟩
  | @ability g₁m g' x sp ab hu hm hk hsp hn hcd hbt hst hat hr hnd hbh =>
      have hs' := hs₂ hst
      have hb := hF.ability hu hm
      have hcd' := hcd.of_xclamp hc hst.1 hb hH
      obtain ⟨x', g₂m, hu', hxt, hxu, hxa, hcm⟩ := hu.xclamp_sim hc
      obtain ⟨g₂', hr', hc'⟩ := hr.xclamp_sim (Nat.lt_of_le_of_lt (ab.script_tmax_le _) hb)
        (hF.1.of_perm hu.perm) hcm (.inl (hu.settled hst))
      exact ⟨g₂', .ability hu' (hxa ▸ hm) hk hsp (hxu ▸ hn) hcd' (by subst hg; exact hbt) hs'
        (by subst hg; exact hat) hr' hnd hbh, hc'⟩
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr hat hf hnd hbh =>
      have hs' := hs₂ hst
      have hx : Card.trainer n .supporter e ∈ g₁.cur.hand := by
        rw [hh]; exact List.mem_append_right _ (.head _)
      have hb := hF.2 _ (GameState.mem_allCards_of_hand hx)
      have hp : ({ g₁ with cur := { g₁.cur with
          hand := l₁ ++ l₂, supporterPlayed := true,
          discard := Card.trainer n .supporter e :: g₁.cur.discard } } :
          GameState).allCards.Perm g₁.allCards := by perm_count [hh]
      obtain ⟨g₂', hr', hc'⟩ := hr.xclamp_sim hb (hF.1.of_perm hp)
        (g₂ := { g₂ with cur := { g₂.cur with
          hand := l₁ ++ l₂, supporterPlayed := true,
          discard := Card.trainer n .supporter e :: g₂.cur.discard } })
        (by subst hg; simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂, he₁, he₂])
        (.inl (hst.congr rfl rfl rfl rfl rfl rfl))
      exact ⟨g₂', .supporter (by subst hg; exact hh) (by subst hg; exact hs)
        (by subst hg; exact hbt) hs' hr' (by subst hg; exact hat) (by subst hg; exact hf) hnd hbh,
        hc'⟩
  | @attack g' a atk ha hm hc' hs hn hf hbt hst hr hl hgx hw l g'' hd ht' =>
      have hs' := hs₂ hst
      have hb := hF.attack ha hm
      have hxr := GameState.xrclamp_of_xclamp hc hst.1 hH
      obtain ⟨g₂', hr', hc''⟩ := Run.xcap_sim hr hb hxr
      have hd' := hd.xclamp_sim hxr hc''
      obtain ⟨g₂'', ht₂, hc'''⟩ := ht'.xclamp_sim (co := .exact) (cp := .exact) (cb := .exact) hc''
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      refine ⟨_, .attack rfl (by rw [hq.grants.1]; exact hm) (by unfold InPlay.units; rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) (by exact hn) (by exact hf) (by exact hbt) hs' hr' (by exact hl)
        (by exact hgx) hw hd' ht₂, ?_⟩
      have := congrArg (fun g : GameState => ({ g with
        attacked := true, cur := { g.cur with gxUsed := atk.gx || g.cur.gxUsed } } :
        GameState)) hc'''
      exact GameState.xclamp_of_xrclamp this
  | attackConfused ha hm hc' hs hn hf hbt hst hl hgx hw =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .attackConfused rfl (by rw [hq.grants.1]; exact hm) (by unfold InPlay.units; rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hs' hl hgx hw, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.upd.2.1 3), he₁, he₂]⟩
  | @knockOuts g₁m g' l h hl ht =>
      obtain ⟨g₂m, h₂, e⟩ := h.xclamp_sim hc hH
      have hbt : g₁.batchTrigs g₁m = g₂.batchTrigs g₂m := by
        have hat : g₁.attacked = g₂.attacked := congrArg (fun g => g.attacked) hc
        simp only [GameState.batchTrigs, hat, GameState.winner_of_xclamp e,
          GameState.koTrigs_of_xclamp hc hH
            (GameState.hpBelow_of_clamp (GameState.clamp_of_xclamp hc) hH)]
      obtain ⟨g₂', ht₂, e'⟩ := ht.xclamp_sim (co := .hp) (cp := .hp) (cb := .hp) e
      exact ⟨g₂', .knockOuts h₂ (hbt ▸ hl) ht₂, e'⟩
  | endTurn fa sa ca fb sb cb ha hb hk hbt hco hcc =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      have h1 := hqa.checkup (hqa.damage_eq_of_lt (hk.lt_bound hH (w := .opp) (sp := .active) ha)) false
        fa sa ca
      have h2 := hqb.upd.2.2.2.2.2.checkup
        (hqb.damage_eq_of_lt (hk.lt_bound hH (w := .own) (sp := .active) hb)) true fb sb cb
      have ee₂ := bench_exact_of_hp he₂ fun p hp => hk.lt_bound hH (w := .opp) (sp := .bench) hp
      have ee₁ := bench_map_comm (InPlay.clampWith_unfresh _)
        (bench_exact_of_hp he₁ fun p hp => hk.lt_bound hH (w := .own) (sp := .bench) hp)
      obtain ⟨bo', hbo, ebo⟩ := hco.sim ee₂
      obtain ⟨bc', hbc, ebc⟩ := hcc.sim ee₁
      refine ⟨_, .endTurn fa sa ca fb sb cb rfl rfl hk' hbt hbo hbc, ?_⟩
      simp only [GameState.xclamp, GameState.xclampAt, PlayerState.unfresh, Option.map_some, hb,
        InPlay.clamp_of_agree h1, InPlay.clamp_of_agree h2, bench_recap (c := .hp) ebo,
        bench_recap (c := .hp) ebc]
  | startTurn hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      refine ⟨_, .startTurn hbt rfl rfl hk' hd, ?_⟩
      simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha, hb,
        InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb, he₁, he₂]
  | deckOut hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      exact ⟨_, .deckOut hbt rfl rfl hk' hd, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha, hb,
          InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb, he₁, he₂]⟩

/-- **The kernel of `xclamp` is a bisimulation for `Reach`**, from a start that is `XFit k`:
from start states with the same `xclamp`, the same clamped states are reachable. -/
theorem Reach.xclamp_sim {k : Nat} {g₀ h₀ g₁ : GameState} (hF : g₀.XFit k) (h : Reach g₀ g₁)
    (hc : g₀.xclamp k = h₀.xclamp k) : ∃ g₂, Reach h₀ g₂ ∧ g₁.xclamp k = g₂.xclamp k := by
  induction h with
  | refl => exact ⟨h₀, .refl _, hc⟩
  | step hr hw hm ih =>
      obtain ⟨g₂, hr₂, hc'⟩ := ih
      obtain ⟨g₂', hm', hc''⟩ := hm.xclamp_sim (hr.xfit hF) hc'
      have hw' : g₂.winner = none := by
        have e := congrArg GameState.winner hc'
        exact e.symm.trans hw
      exact ⟨g₂', .step hr₂ hw' hm', hc''⟩

/-- **The exact-store clamp is a two-way bisimulation along reachable states, for every deck.**
(The reachability premise is vacuous; `GameState.xclamp_bisim` states the same for all pairs
of states with equal `xclamp`.) From any start state `g₀` (no hypothesis on its cards: damage reduction, `drain`, rest-of-game
modifiers and `linger` inside `iter` are all allowed), if `g₁` is reachable and `g₂` has the
same `xclamp`, every move from either is matched by a move from the other to a state with the
same `xclamp`. Milestone M6 gave the clamp a parameter, its bound `K`: damage and Poison strength
are capped at `K`, which must bound every derived HP (before M6 the clamp capped at the printed
HP and had no parameter); the statement takes `K = Enum.bound g₀.allCards`, which is at least
`hpBound` of the cards (`GameState.xfit_bound`). -/
theorem Reach.xclamp_bisim {g₀ g₁ g₂ : GameState} (h : Reach g₀ g₁)
    (hc : g₁.xclamp (Enum.bound g₀.allCards) = g₂.xclamp (Enum.bound g₀.allCards)) :
    (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧
        g₁'.xclamp (Enum.bound g₀.allCards) = g₂'.xclamp (Enum.bound g₀.allCards)) ∧
      (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧
        g₂'.xclamp (Enum.bound g₀.allCards) = g₁'.xclamp (Enum.bound g₀.allCards)) := by
  have hF := h.xfit (GameState.xfit_bound g₀)
  exact ⟨fun g₁' hm => hm.xclamp_sim hF hc,
    fun g₂' hm => hm.xclamp_sim (hF.of_xclamp hc) hc.symm⟩

/-- **The exact-store clamp is a two-way bisimulation on all states, for every deck.** For any
two states with the same `xclamp`, reachable or not, every move from either is matched by a
move from the other to a state with the same `xclamp`. The reachability premise of
`Reach.xclamp_bisim` is vacuous: take the start to be `g₁` itself (`Reach.refl`). The clamp's
bound is `Enum.bound g₁.allCards` (milestone M6; see `Reach.xclamp_bisim`); the same holds at any
larger bound (`GameState.xclamp_bisim_of_le`). -/
theorem GameState.xclamp_bisim {g₁ g₂ : GameState}
    (hc : g₁.xclamp (Enum.bound g₁.allCards) = g₂.xclamp (Enum.bound g₁.allCards)) :
    (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧
        g₁'.xclamp (Enum.bound g₁.allCards) = g₂'.xclamp (Enum.bound g₁.allCards)) ∧
      (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧
        g₂'.xclamp (Enum.bound g₁.allCards) = g₁'.xclamp (Enum.bound g₁.allCards)) :=
  Reach.xclamp_bisim (.refl g₁) hc

/-- `XFit` is monotone in its bound. -/
theorem GameState.XFit.mono {k K : Nat} {g : GameState} (h : g.XFit k) (hK : k ≤ K) : g.XFit K :=
  ⟨⟨Nat.le_trans h.1.1 hK, fun p hp => Nat.le_trans (h.1.2 p hp) hK⟩,
    fun x hx => Nat.lt_of_lt_of_le (h.2 x hx) hK⟩

/-- **`GameState.xclamp_bisim` at any larger bound.** The exact-store clamp at any `K` at least
`Enum.bound g₁.allCards` is a two-way bisimulation on all pairs of states with the same `xclamp K`:
`XFit` is monotone in its bound (`GameState.XFit.mono`). -/
theorem GameState.xclamp_bisim_of_le {K : Nat} {g₁ g₂ : GameState}
    (hK : Enum.bound g₁.allCards ≤ K) (hc : g₁.xclamp K = g₂.xclamp K) :
    (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp K = g₂'.xclamp K) ∧
      (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧ g₂'.xclamp K = g₁'.xclamp K) := by
  have hF := (GameState.xfit_bound g₁).mono hK
  exact ⟨fun g₁' hm => hm.xclamp_sim hF hc,
    fun g₂' hm => hm.xclamp_sim (hF.of_xclamp hc) hc.symm⟩

end Pokemon
