import Pokemon.Damage

/-!
# Zone moves and the clamps (milestone MV)

Both clamps (`GameState.clampAt`, `GameState.xclampAt`) keep every zone exact (deck, hand,
discard pile) and keep every Pokémon in play exact except for damage and Poison strength
(`InPlay.Agree`): its card, the cards under it and its attached Energy are kept. A zone step reads
only zones, the top cards of Pokémon in play (filters, the Bench's length) and attached Energy,
and writes zones and attached Energy, or adds a Basic Pokémon with no damage to the Bench. So the
kernel of every clamp is a simulation for zone steps, at any caps (`ZStep.sim`), without
hypothesis on the cards.
-/

namespace Pokemon

/-- Two player states with the same zones, their Pokémon in play agreeing at the caps `c`
(Active) and `cb` (Bench). -/
structure PlayerState.ZAgree (c cb : Cap) (s₁ s₂ : PlayerState) : Prop where
  deck : s₂.deck = s₁.deck
  hand : s₂.hand = s₁.hand
  discard : s₂.discard = s₁.discard
  active : s₂.active.map (InPlay.clampWith c) = s₁.active.map (InPlay.clampWith c)
  bench : s₂.bench.map (InPlay.clampWith cb) = s₁.bench.map (InPlay.clampWith cb)

theorem Src.get_congr {c cb : Cap} {s₁ s₂ : PlayerState} (h : PlayerState.ZAgree c cb s₁ s₂)
    (src : Src) : src.get s₂ = src.get s₁ := by
  cases src <;> simp only [Src.get, h.deck, h.hand, h.discard]

theorem Src.set_agree {c cb : Cap} {s₁ s₂ : PlayerState} (h : PlayerState.ZAgree c cb s₁ s₂)
    (src : Src) (r : List Card) : PlayerState.ZAgree c cb (src.set r s₁) (src.set r s₂) := by
  cases src <;>
    exact ⟨by simp only [Src.set, h.deck], by simp only [Src.set, h.hand],
      by simp only [Src.set, h.discard], h.active, h.bench⟩

theorem Put.sim {c cb : Cap} {d : Dst} {t : List Card} {x₁ y₁ x₂ : PlayerState}
    (hp : Put d t x₁ y₁) (h : PlayerState.ZAgree c cb x₁ x₂) :
    ∃ y₂, Put d t x₂ y₂ ∧ PlayerState.ZAgree c cb y₁ y₂ := by
  cases hp with
  | hand => exact ⟨_, .hand t x₂, ⟨h.deck, by simp only [h.hand], h.discard, h.active, h.bench⟩⟩
  | discard =>
      exact ⟨_, .discard t x₂, ⟨h.deck, h.hand, by simp only [h.discard], h.active, h.bench⟩⟩
  | top _ hq =>
      exact ⟨_, .top x₂ hq, ⟨by simp only [h.deck], h.hand, h.discard, h.active, h.bench⟩⟩
  | bottom _ hq =>
      exact ⟨_, .bottom x₂ hq, ⟨by simp only [h.deck], h.hand, h.discard, h.active, h.bench⟩⟩
  | shuffle _ hq =>
      exact ⟨_, .shuffle x₂ (by rw [h.deck]; exact hq), ⟨rfl, h.hand, h.discard, h.active, h.bench⟩⟩

/-- Attaching an Energy card keeps two agreeing Pokémon agreeing. -/
theorem InPlay.Agree.addEnergy {c : Cap} {q p : InPlay} (h : InPlay.Agree c q p) (x : Card) :
    InPlay.Agree c (q.addEnergy x) (p.addEnergy x) := by
  unfold InPlay.addEnergy; rw [h.energy]; exact h.upd.1 _

/-- Replacing the attached Energy keeps two agreeing Pokémon agreeing. -/
theorem InPlay.Agree.setEnergy {c : Cap} {q p : InPlay} (h : InPlay.Agree c q p) (e : List Card) :
    InPlay.Agree c { q with energy := e } { p with energy := e } := h.upd.1 e

/-- **The kernel of every clamp is a simulation for zone steps**, at any caps. -/
theorem ZStep.sim {c cb : Cap} {e : Effect} {s₁ s₁' s₂ : PlayerState} (h : ZStep e s₁ s₁')
    (ha : PlayerState.ZAgree c cb s₁ s₂) :
    ∃ s₂', ZStep e s₂ s₂' ∧ PlayerState.ZAgree c cb s₁' s₂' := by
  cases h with
  | @move w src dst f q s s' t r hs hq hp =>
      obtain ⟨y₂, hp₂, hy⟩ := hp.sim (Src.set_agree ha src r)
      exact ⟨y₂, .move (by rw [Src.get_congr ha]; exact hs) hq hp₂, hy⟩
  | drawTo w n s =>
      refine ⟨_, .drawTo w n s₂, ⟨?_, ?_, ha.discard, ha.active, ha.bench⟩⟩ <;>
        simp only [PlayerState.drawK, ha.deck, ha.hand]
  | @attachActive w src f tf s r t a hs hac ht =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      have hs' := Src.set_agree ha src r
      refine ⟨_, .attachActive (by rw [Src.get_congr ha]; exact hs) ha₂ (by rw [hag.top]; exact ht),
        ⟨hs'.deck, hs'.hand, hs'.discard, ?_, hs'.bench⟩⟩
      simp only [Option.map_some, InPlay.clamp_of_agree (hag.addEnergy _)]
  | @attachBench w src f tf s r t q b₁ b₂ hs hb ht =>
      have hs' := Src.set_agree ha src r
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hq := InPlay.agree_of_clamp h2
      refine ⟨_, .attachBench (by rw [Src.get_congr ha]; exact hs) hb₂ (by rw [hq.top]; exact ht),
        ⟨hs'.deck, hs'.hand, hs'.discard, hs'.active, ?_⟩⟩
      simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hq.addEnergy _)]
  | attachNone w src f sp tf s => exact ⟨s₂, .attachNone w src f sp tf s₂, ha⟩
  | @putBench w src f s r p hs hst hhp hb =>
      have hs' := Src.set_agree ha src r
      refine ⟨_, .putBench (by rw [Src.get_congr ha]; exact hs) hst hhp
          (by rw [length_of_map ha.bench]; exact hb),
        ⟨hs'.deck, hs'.hand, hs'.discard, hs'.active, ?_⟩⟩
      simp only [List.map_append, ha.bench]
  | putBenchNone w src f s => exact ⟨s₂, .putBenchNone w src f s₂, ha⟩
  | @discardActive w f q s a t r hac hs hq =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      refine ⟨_, .discardActive ha₂ (by rw [hag.energy]; exact hs) hq,
        ⟨ha.deck, ha.hand, by simp only [ha.discard], ?_, ha.bench⟩⟩
      simp only [Option.map_some, InPlay.clamp_of_agree (hag.setEnergy r)]
  | @discardBench w f q s p b₁ b₂ t r hb hs hq =>
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hp := InPlay.agree_of_clamp h2
      refine ⟨_, .discardBench hb₂ (by rw [hp.energy]; exact hs) hq,
        ⟨ha.deck, ha.hand, by simp only [ha.discard], ha.active, ?_⟩⟩
      simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hp.setEnergy r)]
  | discardNone hb =>
      have hm := ha.bench
      rw [hb, List.map_nil, List.map_eq_nil_iff] at hm
      exact ⟨s₂, .discardNone hm, ha⟩
  | @moveAB w f s a q b₁ b₂ e₁ e₂ x hac he hx hb =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hq := InPlay.agree_of_clamp h2
      refine ⟨_, .moveAB ha₂ (by rw [hag.energy]; exact he) hx hb₂,
        ⟨ha.deck, ha.hand, ha.discard, ?_, ?_⟩⟩
      · simp only [Option.map_some, InPlay.clamp_of_agree (hag.setEnergy _)]
      · simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hq.addEnergy _)]
  | @moveBA w f s a q b₁ b₂ e₁ e₂ x hac hb he hx =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hq := InPlay.agree_of_clamp h2
      refine ⟨_, .moveBA ha₂ hb₂ (by rw [hq.energy]; exact he) hx,
        ⟨ha.deck, ha.hand, ha.discard, ?_, ?_⟩⟩
      · simp only [Option.map_some, InPlay.clamp_of_agree (hag.addEnergy _)]
      · simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hq.setEnergy _)]
  | @moveBB w f s q q' b₁ b₂ c₁ c₂ e₁ e₂ x hb he hx hc =>
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hq := InPlay.agree_of_clamp h2
      have hm : (d₁ ++ { q₂ with energy := e₁ ++ e₂ } :: d₂).map (InPlay.clampWith cb) =
          (c₁ ++ q' :: c₂).map (InPlay.clampWith cb) := by
        rw [← hc]
        simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hq.setEnergy _)]
      obtain ⟨k₁, q₃, k₂, hk, g1, g2, g3⟩ := map_eq_split hm
      have hq' := InPlay.agree_of_clamp g2
      refine ⟨_, .moveBB hb₂ (by rw [hq.energy]; exact he) hx hk,
        ⟨ha.deck, ha.hand, ha.discard, ha.active, ?_⟩⟩
      simp only [List.map_append, List.map_cons, g1, g3, InPlay.clamp_of_agree (hq'.addEnergy _)]
  | moveNone w f s => exact ⟨s₂, .moveNone w f s₂, ha⟩

end Pokemon
