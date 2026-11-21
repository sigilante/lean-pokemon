import Pokemon.Finite

/-!
# A clamp with exact stores: a bisimulation for every deck

`GameState.clamp k` (in `Pokemon/Damage.lean`) caps the damage bonuses and reductions in the
modifier stores at `k`, and that is why it fails for decks with damage reduction or `drain`
(`Lingering.reduce_breaks_clamp`, `Lingering.drain_breaks_clamp`): both counterexamples
reach two states whose stores differ only above the cap. This file keeps every store exact and
clamps only what Knock Outs make irrelevant.

* `GameState.xclampAt co cp` applies `InPlay.clampWith co` to the Active Pokémon of the player
  to move and `clampWith cp` to the opponent's (damage as the cap says, Poison strength capped
  at the printed HP); nothing else changes, the modifier stores included.
* `GameState.xclamp` is `xclampAt .hp .hp`, the clamp at move boundaries. It has no parameter.
  `GameState.xrclamp k` is `xclampAt .exact (.upto k)`, the relation used inside an attack's
  effect: the player's own damage exact, the opponent's capped at `k`.
* `Run.xcap_sim`: inside an attack's effect, the kernel of `xrclamp k` is a simulation for
  every effect whose test constants are below `k`. No tameness: damage reduction and `drain`
  are allowed.
* `TRun.xclamp_sim`, `Move.xclamp_sim`, `Reach.xclamp_sim`: the kernel of `xclamp` is a
  simulation for Trainer effects and a (strong) bisimulation for moves and for reachability,
  under `GameState.XFit k`: every printed HP is at most `k` and every test constant is below
  `k`. Nothing is assumed about modifiers, damage reduction or `drain`.
* `Reach.xclamp_bisim`, `GameState.xclamp_bisim`: with `k` computed from the cards, the kernel
  of `xclamp` is a two-way bisimulation for every deck. The first is stated along states
  reachable from a start `g₀`; that premise is vacuous (take `g₀ = g₁`), and the second states
  it for all pairs of states with equal `xclamp`.

Why this works, reader by reader. Two states with the same `xrclamp k` have identical stores,
identical Benches, hands, decks, discard piles, flags and markers, the same Active Pokémon
except in damage and Poison strength, the player's own Active Pokémon with the same damage, and
the opponent's with damage equal or both at least `k`.
* `damage n` and `drain n` compute `dealtBy n` from the stores, which are equal, so both states
  add the same amount, however large and whether or not a reduction offsets a bonus; `drain`
  heals the player's own Active Pokémon, whose damage is exact, by that same amount.
* Tests (`ite`): the player's own damage is exact; the opponent's is read only against test
  constants below `k`; conditions, markers and types are equal.
* `scale w k'`: from the player's own Pokémon it adds the same amount; from the opponent's,
  `d + k'·d` is at least `k` when `d` is (`min_add_mul`).
* Locks and prevention are flags in the stores, which are equal: the same attacks, retreats and
  Items are legal, and prevention zeroes damage in both states alike.
* Checkup reads damage only from `Settled` states (`endTurn` requires `DamageBounded`), where
  capping at HP loses nothing, and Poison strength above HP adds at least HP either way.
* Store shifting at `endTurn` acts on equal stores.
* Trainer effects (`TRun`): each primitive step starts `Settled`, where `xclamp` and
  `xrclamp k` agree; Knock Outs in mid-effect read damage only against HP.

The cap on damage. Inside an attack the opponent's damage is capped at `k`, which must exceed
every test constant (tests read it) and be at least every printed HP (so the cap at `k` still
decides every Knock Out after the attack). Attack damage can now be large in either direction
(a bonus far above every HP, or a reduction that brings damage to 0), but it is the same in
both states, since it is computed from equal stores; no cap on damage done is needed, and none
on the stores. `XFit` asks exactly for these two conditions, and `bound` (larger than every HP
and test constant) gives them (`GameState.xfit_bound`).

What the stores cost. The clamp no longer bounds the stores, so finiteness of the reachable
clamps needs a separate bound on the stores; that is `Pokemon/Bounded.lean`.
-/

namespace Pokemon

/-- Clamp the player's Active Pokémon by `co` and the opponent's by `cp`. Every other
component is unchanged, the modifier stores included. -/
def GameState.xclampAt (co cp : Cap) (g : GameState) : GameState :=
  { g with cur := { g.cur with active := g.cur.active.map (InPlay.clampWith co) },
           opp := { g.opp with active := g.opp.active.map (InPlay.clampWith cp) } }

/-- **The clamp with exact stores**, at move boundaries: damage and Poison strength on both
Active Pokémon capped at the printed HP; the modifier stores, and everything else, exact. -/
def GameState.xclamp (g : GameState) : GameState := g.xclampAt .hp .hp

/-- The relation used inside an attack's effect: the player's own damage exact, the opponent's
capped at `k`, Poison strength capped at HP, the stores exact. -/
def GameState.xrclamp (k : Nat) (g : GameState) : GameState := g.xclampAt .exact (.upto k)

/-- Two states with the same `xclampAt co cp` differ at most in the two Active Pokémon, as
`InPlay.Agree` allows. -/
theorem GameState.xclamp_inv {co cp : Cap} {g₁ g₂ : GameState}
    (h : g₁.xclampAt co cp = g₂.xclampAt co cp) :
    ∃ c₂ a₂, g₂ = { g₁ with cur := { g₁.cur with active := c₂ },
                            opp := { g₁.opp with active := a₂ } } ∧
      c₂.map (InPlay.clampWith co) = g₁.cur.active.map (InPlay.clampWith co) ∧
      a₂.map (InPlay.clampWith cp) = g₁.opp.active.map (InPlay.clampWith cp) := by
  refine ⟨g₂.cur.active, g₂.opp.active, ?_,
    (congrArg (fun g => g.cur.active) h).symm, (congrArg (fun g => g.opp.active) h).symm⟩
  have e : g₂ = { g₂.xclampAt co cp with
      cur := { (g₂.xclampAt co cp).cur with active := g₂.cur.active },
      opp := { (g₂.xclampAt co cp).opp with active := g₂.opp.active } } :=
    rfl
  refine e.trans ?_
  rw [← h]
  rfl

/-- The clamp with exact stores determines the stores. -/
theorem GameState.mods_of_xclamp {co cp : Cap} {g₁ g₂ : GameState}
    (h : g₁.xclampAt co cp = g₂.xclampAt co cp) :
    g₁.cur.mods = g₂.cur.mods ∧ g₁.opp.mods = g₂.opp.mods :=
  ⟨congrArg (fun g => g.cur.mods) h, congrArg (fun g => g.opp.mods) h⟩

/-- The Active Pokémon read by a test, in states with the same `xrclamp k`. -/
theorem GameState.xactiveOf_agree {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.xrclamp k = g₂.xrclamp k) {w : Whose} {p : InPlay} (hp : g₁.activeOf w = some p) :
    ∃ q, g₂.activeOf w = some q ∧ InPlay.Agree (.upto k) q p := by
  cases w with
  | own =>
      have e := (congrArg (fun g => g.cur.active) h).symm
      simp only [GameState.xrclamp, GameState.xclampAt] at e
      rw [show g₁.cur.active = some p from hp] at e
      obtain ⟨q, hq, ha⟩ := agree_of_map e
      exact ⟨q, hq, ha.recap ha.damage_eq⟩
  | opp =>
      have e := (congrArg (fun g => g.opp.active) h).symm
      simp only [GameState.xrclamp, GameState.xclampAt] at e
      rw [show g₁.opp.active = some p from hp] at e
      exact agree_of_map e

/-- With no pending Knock Out, equal `xclamp` gives equal `xrclamp k`. -/
theorem GameState.xrclamp_of_xclamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.xclamp = g₂.xclamp)
    (hk : DamageBounded g₁) : g₁.xrclamp k = g₂.xrclamp k := by
  obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv h
  simp only [GameState.xrclamp, GameState.xclampAt,
    map_exact_of_hp hc₂ fun p hp => hk p (Or.inl hp),
    map_recap (c := .upto k) (map_exact_of_hp ha₂ fun p hp => hk p (Or.inr (Or.inr (Or.inl hp))))]

/-- Equal `xrclamp k` gives equal `xclamp` when the opponent's Active Pokémon has HP at most
`k`. -/
theorem GameState.xclamp_of_xrclamp {k : Nat} {g₁ g₂ : GameState}
    (h : g₁.xrclamp k = g₂.xrclamp k) (hk : ∀ p, g₁.opp.active = some p → p.top.hp ≤ k) :
    g₁.xclamp = g₂.xclamp := by
  obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv h
  simp only [GameState.xclamp, GameState.xclampAt, map_recap (c := .hp) hc₂, map_hp_of_upto ha₂ hk]

/-- Equal `xclamp` gives equal `clamp k`, for every `k`. -/
theorem GameState.clamp_of_xclamp {k : Nat} {g₁ g₂ : GameState} (h : g₁.xclamp = g₂.xclamp) :
    g₁.clamp k = g₂.clamp k := by
  obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv h
  simp only [GameState.clamp, GameState.clampAt, hc₂, ha₂]

theorem GameState.damageBounded_of_xclamp {g₁ g₂ : GameState} (h : g₁.xclamp = g₂.xclamp)
    (hk : DamageBounded g₁) : DamageBounded g₂ :=
  GameState.damageBounded_of_clamp (k := 0) (GameState.clamp_of_xclamp h) hk

theorem GameState.settled_of_xclamp {g₁ g₂ : GameState} (h : g₁.xclamp = g₂.xclamp)
    (hs : Settled g₁) : Settled g₂ :=
  GameState.settled_of_clamp (k := 0) (GameState.clamp_of_xclamp h) hs

theorem GameState.winner_of_xclamp {g₁ g₂ : GameState} (h : g₁.xclamp = g₂.xclamp) :
    g₂.winner = g₁.winner :=
  (congrArg GameState.winner h).symm

/-! ## Knock Outs -/

/-- The kernel of `xclamp` is a simulation for Knock Out moves. -/
theorem KOMove.xclamp_sim {g₁ g₁' g₂ : GameState} (h : KOMove g₁ g₁')
    (hc : g₁.xclamp = g₂.xclamp) : ∃ g₂', KOMove g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp := by
  obtain ⟨c₂, a₂, hg, hc₂, ha₂⟩ := GameState.xclamp_inv hc
  subst hg
  cases h with
  | knockOut ha hk hp =>
      rw [ha] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .knockOut rfl (hq.ko hk) hp, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_none, hc₂, hq.cardList]⟩
  | promote ha hb =>
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .promote rfl hb, by simp only [GameState.xclamp, GameState.xclampAt, hc₂]⟩
  | noPokemon ha hb =>
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .noPokemon rfl hb, by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha, Option.map_none]⟩
  | knockOutOwn ha hk hp =>
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .knockOutOwn rfl (hq.ko hk) hp, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_none, ha₂, hq.cardList]⟩
  | promoteOwn ha hb =>
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .promoteOwn rfl hb, by simp only [GameState.xclamp, GameState.xclampAt, ha₂]⟩
  | noPokemonOwn ha hb =>
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .noPokemonOwn rfl hb, by
        simp only [GameState.xclamp, GameState.xclampAt, ha₂, ha, Option.map_none]⟩

/-- The kernel of `xclamp` is a simulation for taking the Knock Outs. -/
theorem Resolve.xclamp_sim {g₁ g₁' : GameState} (h : Resolve g₁ g₁') :
    ∀ {g₂ : GameState}, g₁.xclamp = g₂.xclamp →
      ∃ g₂', Resolve g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp := by
  induction h with
  | done h =>
      intro g₂ hc
      refine ⟨g₂, .done ?_, hc⟩
      rcases h with h | h
      · exact .inl (GameState.settled_of_xclamp hc h)
      · exact .inr (by rw [GameState.winner_of_xclamp hc]; exact h)
  | step hn hm _ ih =>
      intro g₂ hc
      obtain ⟨m₂, hm₂, hcm⟩ := hm.xclamp_sim hc
      obtain ⟨g₂', hr₂, hc'⟩ := ih hcm
      exact ⟨g₂', .step (by rw [GameState.winner_of_xclamp hc]; exact hn) hm₂ hr₂, hc'⟩

/-! ## Inside an attack's effect -/

/-- **Inside an attack's effect, the kernel of `xrclamp k` is a simulation**, for every effect
whose test constants are below `k`: damage reduction, `drain`, rest-of-game modifiers and
`linger` inside `iter` are all allowed. Two states that agree except in the opponent's damage
at or above `k` and in Poison strength above HP have the same effect resolutions, up to the same
relation. -/
theorem Run.xcap_sim {k : Nat} {e : Effect} {g₁ g₁' : GameState} (h : Run e g₁ g₁') :
    e.tmax < k → ∀ {g₂ : GameState}, g₁.xrclamp k = g₂.xrclamp k →
      ∃ g₂', Run e g₂ g₂' ∧ g₁'.xrclamp k = g₂'.xrclamp k := by
  induction h with
  | skip g => intro _ g₂ hc; exact ⟨g₂, .skip g₂, hc⟩
  | draw h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .draw h, by simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂]⟩
  | drawEmpty h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .drawEmpty h, hc⟩
  | @heal g p n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have hq' : InPlay.Agree .exact { q with damage := q.damage - n }
          { p with damage := p.damage - n } := by
        rw [hq.damage_eq]; exact hq.setDamage _
      exact ⟨_, .heal n rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some,
          InPlay.clamp_of_agree hq', ha₂]⟩
  | counters n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .counters n rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n)]⟩
  | inflict c h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .inflict c rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.2.2.1 c)]⟩
  | poisonUp n h hp =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUp n rfl (hq.poisoned.trans hp), by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.2.1 n)]⟩
  | poisonUpSkip n h hp =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .poisonUpSkip n rfl (hq.poisoned.trans hp), hc⟩
  | cure h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .cure rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree hq.upd.2.2.2.2.1]⟩
  | iteT h ht' _ ih =>
      intro hb g₂ hc
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih (by omega) hc
      exact ⟨g₂', .iteT hq (by rw [Test.eval_agree _ hqa (by omega)]; exact ht') r', hc'⟩
  | iteF h ht' _ ih =>
      intro hb g₂ hc
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree hc h
      obtain ⟨g₂', r', hc'⟩ := ih (by omega) hc
      exact ⟨g₂', .iteF hq (by rw [Test.eval_agree _ hqa (by omega)]; exact ht') r', hc'⟩
  | @scale g p q w k' hs h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q₂, rfl, hq⟩ := agree_of_map ha₂
      cases w with
      | own =>
          change g.cur.active = some p at hs
          rw [hs] at hc₂
          obtain ⟨s, rfl, hsa⟩ := agree_of_map hc₂
          have hq' : InPlay.Agree (.upto k) { q₂ with damage := q₂.damage + k' * s.damage }
              { q with damage := q.damage + k' * p.damage } := by
            rw [hsa.damage_eq]; exact hq.upd.2.1 _
          exact ⟨_, .scale .own k' rfl rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hs,
              InPlay.clamp_of_agree hq', InPlay.clamp_of_agree hsa]⟩
      | opp =>
          change g.opp.active = some p at hs
          have e : q = p := Option.some.inj (h.symm.trans hs)
          subst e
          have hd := hq.damage
          simp only [Cap.dmg] at hd
          have hq' : InPlay.Agree (.upto k) { q₂ with damage := q₂.damage + k' * q₂.damage }
              { q with damage := q.damage + k' * q.damage } :=
            ⟨hq.top, hq.under, hq.energy, hq.tools, hq.rot, hq.poisoned, hq.burned, hq.fresh,
              hq.marks, by simp only [Cap.dmg]; exact min_add_mul hd k', hq.poisonUp⟩
          exact ⟨_, .scale .opp k' rfl rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, hc₂,
              InPlay.clamp_of_agree hq']⟩
  | @selfDamage g p n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .selfDamage n rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n)]⟩
  | @healAll g p h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .healAll rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.setDamage 0)]⟩
  | @touchActive e w f g p he h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      cases w with
      | own =>
          simp only [GameState.side] at h
          rw [h] at hc₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, Option.map_some,
              ha₂, InPlay.clamp_of_agree (hq.setMarks f)]⟩
      | opp =>
          simp only [GameState.side] at h
          rw [h] at ha₂
          obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
          exact ⟨_, .touchActive he rfl, by
            simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, Option.map_some,
              hc₂, InPlay.clamp_of_agree (hq.setMarks f)]⟩
  | @touchBench e w f g q b₁ b₂ he h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      cases w <;>
        exact ⟨_, .touchBench he h, by
          simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂]⟩
  | unmark w m g =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      cases w <;>
        exact ⟨_, .unmark _ m _, by
          simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, PlayerState.unmark,
            hc₂, ha₂, map_clamp_setMarks _ hc₂, map_clamp_setMarks _ ha₂]⟩
  | linger w s m g =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      cases w <;>
        exact ⟨_, .linger _ s m _, by
          simp only [GameState.xrclamp, GameState.xclampAt, GameState.updSide, hc₂, ha₂]⟩
  | @damage g p n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .damage n rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, GameState.dealt, Option.map_some, hc₂,
          InPlay.clamp_of_agree (hq.upd.2.1 (dealtBy n g.cur.mods g.opp.mods))]⟩
  | @drain g p q n h hq =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      rw [h] at ha₂
      rw [hq] at hc₂
      obtain ⟨p₂, rfl, hp₂⟩ := agree_of_map ha₂
      obtain ⟨q₂, rfl, hq₂⟩ := agree_of_map hc₂
      have hq' : InPlay.Agree .exact
          { q₂ with damage := q₂.damage - dealtBy n g.cur.mods g.opp.mods }
          { q with damage := q.damage - dealtBy n g.cur.mods g.opp.mods } := by
        rw [hq₂.damage_eq]; exact hq₂.setDamage _
      exact ⟨_, .drain n rfl rfl, by
        simp only [GameState.xrclamp, GameState.xclampAt, GameState.dealt, Option.map_some,
          InPlay.clamp_of_agree hq',
          InPlay.clamp_of_agree (hp₂.upd.2.1 (dealtBy n g.cur.mods g.opp.mods))]⟩
  | shuffle h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .shuffle h, by simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂]⟩
  | search h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .search h, by simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂]⟩
  | handToBottom h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
      exact ⟨_, .handToBottom h, by
        simp only [GameState.xrclamp, GameState.xclampAt, hc₂, ha₂]⟩
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
      g₁.xclamp = g₂.xclamp → (Settled g₁ ∨ g₁.winner ≠ none) →
        ∃ g₂', TRun e g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp := by
  induction h with
  | prim he hn hr hk =>
      intro hb hhp g₂ hc hs
      have hs : Settled _ := hs.resolve_right (fun h => h hn)
      obtain ⟨m₂, hr₂, hcm⟩ := Run.xcap_sim hr hb (GameState.xrclamp_of_xclamp hc hs.1)
      have hhp' := hhp.of_perm hr.perm
      obtain ⟨g₂', hk₂, hc'⟩ := hk.xclamp_sim
        (GameState.xclamp_of_xrclamp hcm fun p hp => hhp' _ (GameState.top_mem_opp_active hp))
      exact ⟨g₂', .prim he (by rw [GameState.winner_of_xclamp hc]; exact hn) hr₂ hk₂, hc'⟩
  | stop hn =>
      intro _ _ g₂ hc _
      exact ⟨g₂, .stop (by rw [GameState.winner_of_xclamp hc]; exact hn), hc⟩
  | iteT hn h ht' _ ih =>
      intro hb hhp g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree (GameState.xrclamp_of_xclamp (k := k) hc hs'.1) h
      obtain ⟨g₂', r', hc'⟩ := ih (by omega) hhp hc hs
      exact ⟨g₂', .iteT (by rw [GameState.winner_of_xclamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ hqa (by omega)]; exact ht') r', hc'⟩
  | iteF hn h ht' _ ih =>
      intro hb hhp g₂ hc hs
      have hs' : Settled _ := hs.resolve_right (fun h => h hn)
      simp only [Effect.tmax] at hb
      obtain ⟨q, hq, hqa⟩ := GameState.xactiveOf_agree (GameState.xrclamp_of_xclamp (k := k) hc hs'.1) h
      obtain ⟨g₂', r', hc'⟩ := ih (by omega) hhp hc hs
      exact ⟨g₂', .iteF (by rw [GameState.winner_of_xclamp hc]; exact hn) hq
        (by rw [Test.eval_agree _ hqa (by omega)]; exact ht') r', hc'⟩
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

/-- The conditions under which the kernel of `xclamp` is a bisimulation for moves: every
Pokémon card has HP at most `k`, and every card's test constants are below `k`. Nothing about
modifiers, damage reduction or `drain`. -/
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
  refine ⟨fun p hp => ?_, fun x hx => ?_⟩
  · have := hp_le_maxHp hp; simp only [Enum.bound]; omega
  · have := tmax_le_cardsTmax hx; simp only [Enum.bound]; omega

/-- `XFit k` transfers along equal `xclamp`. -/
theorem GameState.XFit.of_xclamp {k : Nat} {g₁ g₂ : GameState} (hF : g₁.XFit k)
    (hc : g₁.xclamp = g₂.xclamp) : g₂.XFit k := by
  obtain ⟨c₂, a₂, rfl, hc₂, ha₂⟩ := GameState.xclamp_inv hc
  refine hF.of_perm ?_
  have e₁ := optCardList_of_map hc₂
  have e₂ := optCardList_of_map ha₂
  simp only [GameState.allCards, PlayerState.allCards, e₁, e₂]
  exact .refl _

/-- The effect an attack resolves has test constants below `k`. -/
theorem GameState.XFit.attack {k : Nat} {g : GameState} (hF : g.XFit k) {a : InPlay}
    {atk : Attack} (ha : g.cur.active = some a) (hm : atk ∈ a.top.attacks) :
    (Effect.seq (.damage atk.damage) atk.effect).tmax < k := by
  have hb := hF.2 _ (GameState.top_mem_cur_active ha)
  simp only [Card.tmax] at hb
  have h2 := attacksTmax_mem (as := a.top.attacks) hm
  simp only [Effect.tmax]; omega

/-- **The kernel of `xclamp` is a bisimulation for `Move`**, for a state that is `XFit k`, with
no hypothesis on damage reduction, `drain` or modifiers: if `g₁` and `g₂` have the same
`xclamp`, every move from `g₁` is matched by a move from `g₂` to a state with the same `xclamp`.
(`XFit k` transfers to `g₂`, `GameState.XFit.of_xclamp`, so this gives both directions.) -/
theorem Move.xclamp_sim {k : Nat} {g₁ g₁' g₂ : GameState} (hF : g₁.XFit k) (h : Move g₁ g₁')
    (hc : g₁.xclamp = g₂.xclamp) : ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp := by
  have hk₂ := GameState.damageBounded_of_xclamp hc
  have hs₂ := GameState.settled_of_xclamp hc
  obtain ⟨c₂, a₂, hg, hc₂, ha₂⟩ := GameState.xclamp_inv hc
  cases h with
  | playBasic hh hs hhp hb hbt hst =>
      have hs' := hs₂ hst
      subst hg
      exact ⟨_, .playBasic hh hs hhp hb hbt hs', by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂]⟩
  | @attach l₁ l₂ t a hh hf ha hbt hst =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have key := hq.clamp_map (c' := .hp) (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
        (fun x => { x with energy := Card.energy t :: x.energy }) (fun _ => rfl) rfl rfl
      exact ⟨_, .attach hh hf rfl hbt hs', by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha₂, key]⟩
  | @evolve l₁ l₂ p a hh ha he hfr hf hbt hst =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
      refine ⟨_, .evolve hh rfl (by rw [hq.top]; exact he) (hq.fresh.trans hfr) hf hbt hs', ?_⟩
      rw [e]
      simp only [GameState.xclamp, GameState.xclampAt, ha₂]
  | @retreat a q' b₁ b₂ paid rest ha hb hr he hp hs hbt hst hl =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      have e := hq.eq_upd (hq.damage_eq_of_lt (hst.1 a (Or.inl ha)))
      refine ⟨_, .retreat rfl hb hr (hq.energy.trans he) (by rw [hq.top]; exact hp)
        (by rw [hq.rot]; exact hs) hbt hs' hl, ?_⟩
      rw [e]
      simp only [GameState.xclamp, GameState.xclampAt, ha₂]
  | @item g' l₁ l₂ n e hh hbt hst hr hl =>
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
        (by subst hg; simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂])
        (.inl hst)
      exact ⟨g₂', .item (by subst hg; exact hh) (by subst hg; exact hbt) hs' hr'
        (by subst hg; exact hl), hc'⟩
  | @supporter g' l₁ l₂ n e hh hs hbt hst hr =>
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
        (by subst hg; simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha₂])
        (.inl hst)
      exact ⟨g₂', .supporter (by subst hg; exact hh) (by subst hg; exact hs)
        (by subst hg; exact hbt) hs' hr', hc'⟩
  | @attack g' a atk ha hm hc' hs hn hf hbt hst hr hl hgx =>
      have hs' := hs₂ hst
      have hb := hF.attack ha hm
      obtain ⟨g₂', hr', hc''⟩ := Run.xcap_sim hr hb (GameState.xrclamp_of_xclamp hc hst.1)
      have hhp := hF.1.of_perm hr.perm
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      refine ⟨_, .attack rfl (by rw [hq.top]; exact hm) (by rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hs' hr' hl hgx, ?_⟩
      have := congrArg (fun g : GameState => ({ g with
        attacked := true, cur := { g.cur with gxUsed := atk.gx || g.cur.gxUsed } } :
        GameState)) hc''
      exact GameState.xclamp_of_xrclamp this
        (fun p hp => hhp _ (GameState.top_mem_opp_active (g := g') hp))
  | attackConfused ha hm hc' hs hn hf hbt hst hl hgx =>
      have hs' := hs₂ hst
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .attackConfused rfl (by rw [hq.top]; exact hm) (by rw [hq.energy]; exact hc')
        (by rw [hq.rot]; exact hs) hn hf hbt hs' hl hgx, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha₂,
          InPlay.clamp_of_agree (hq.upd.2.1 3)]⟩
  | knockOut ha hk hp =>
      subst hg
      rw [ha] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .knockOut rfl (hq.ko hk) hp, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_none, hc₂, hq.cardList]⟩
  | promote ha hb =>
      subst hg
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .promote rfl hb, by simp only [GameState.xclamp, GameState.xclampAt, hc₂]⟩
  | noPokemon ha hb =>
      subst hg
      rw [ha] at ha₂
      have := none_of_map ha₂
      subst this
      exact ⟨_, .noPokemon rfl hb, by
        simp only [GameState.xclamp, GameState.xclampAt, hc₂, ha, Option.map_none]⟩
  | knockOutOwn ha hk hp =>
      subst hg
      rw [ha] at hc₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map hc₂
      exact ⟨_, .knockOutOwn rfl (hq.ko hk) hp, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_none, ha₂, hq.cardList]⟩
  | promoteOwn ha hb =>
      subst hg
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .promoteOwn rfl hb, by simp only [GameState.xclamp, GameState.xclampAt, ha₂]⟩
  | noPokemonOwn ha hb =>
      subst hg
      rw [ha] at hc₂
      have := none_of_map hc₂
      subst this
      exact ⟨_, .noPokemonOwn rfl hb, by
        simp only [GameState.xclamp, GameState.xclampAt, ha₂, ha, Option.map_none]⟩
  | endTurn fa sa ca fb sb cb ha hb hk hbt =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      have h1 := hqa.checkup (hqa.damage_eq_of_lt (hk _ (Or.inr (Or.inr (Or.inl ha))))) false
        fa sa ca
      have h2 := hqb.upd.2.2.2.2.2.checkup (hqb.damage_eq_of_lt (hk _ (Or.inl hb))) true fb sb cb
      refine ⟨_, .endTurn fa sa ca fb sb cb rfl rfl hk' hbt, ?_⟩
      simp only [GameState.xclamp, GameState.xclampAt, PlayerState.unfresh, Option.map_some, hb,
        InPlay.clamp_of_agree h1, InPlay.clamp_of_agree h2]
  | startTurn hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      refine ⟨_, .startTurn hbt rfl rfl hk' hd, ?_⟩
      simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha, hb,
        InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb]
  | deckOut hbt ha hb hk hd =>
      have hk' := hk₂ hk
      subst hg
      rw [ha] at ha₂
      rw [hb] at hc₂
      obtain ⟨qa, rfl, hqa⟩ := agree_of_map ha₂
      obtain ⟨qb, rfl, hqb⟩ := agree_of_map hc₂
      exact ⟨_, .deckOut hbt rfl rfl hk' hd, by
        simp only [GameState.xclamp, GameState.xclampAt, Option.map_some, ha, hb,
          InPlay.clamp_of_agree hqa, InPlay.clamp_of_agree hqb]⟩

/-- **The kernel of `xclamp` is a bisimulation for `Reach`**, from a start that is `XFit k`:
from start states with the same `xclamp`, the same clamped states are reachable. -/
theorem Reach.xclamp_sim {k : Nat} {g₀ h₀ g₁ : GameState} (hF : g₀.XFit k) (h : Reach g₀ g₁)
    (hc : g₀.xclamp = h₀.xclamp) : ∃ g₂, Reach h₀ g₂ ∧ g₁.xclamp = g₂.xclamp := by
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
same `xclamp`. The bound `Enum.bound g₀.allCards` is only used to cap the opponent's damage
inside attack effects; the clamp itself has no parameter. -/
theorem Reach.xclamp_bisim {g₀ g₁ g₂ : GameState} (h : Reach g₀ g₁)
    (hc : g₁.xclamp = g₂.xclamp) :
    (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp) ∧
      (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧ g₂'.xclamp = g₁'.xclamp) := by
  have hF := h.xfit (GameState.xfit_bound g₀)
  exact ⟨fun g₁' hm => hm.xclamp_sim hF hc,
    fun g₂' hm => hm.xclamp_sim (hF.of_xclamp hc) hc.symm⟩

/-- **The exact-store clamp is a two-way bisimulation on all states, for every deck.** For any
two states with the same `xclamp`, reachable or not, every move from either is matched by a
move from the other to a state with the same `xclamp`. The reachability premise of
`Reach.xclamp_bisim` is vacuous: take the start to be `g₁` itself (`Reach.refl`). -/
theorem GameState.xclamp_bisim {g₁ g₂ : GameState} (hc : g₁.xclamp = g₂.xclamp) :
    (∀ g₁', Move g₁ g₁' → ∃ g₂', Move g₂ g₂' ∧ g₁'.xclamp = g₂'.xclamp) ∧
      (∀ g₂', Move g₂ g₂' → ∃ g₁', Move g₁ g₁' ∧ g₂'.xclamp = g₁'.xclamp) :=
  Reach.xclamp_bisim (.refl g₁) hc

end Pokemon
