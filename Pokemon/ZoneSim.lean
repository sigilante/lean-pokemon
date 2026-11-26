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
structure PlayerState.ZAgree (K : Nat) (c cb : Cap) (s₁ s₂ : PlayerState) : Prop where
  deck : s₂.deck = s₁.deck
  hand : s₂.hand = s₁.hand
  discard : s₂.discard = s₁.discard
  active : s₂.active.map (InPlay.clampWith K c) = s₁.active.map (InPlay.clampWith K c)
  bench : s₂.bench.map (InPlay.clampWith K cb) = s₁.bench.map (InPlay.clampWith K cb)

theorem Src.get_congr {c cb : Cap} {s₁ s₂ : PlayerState} (h : PlayerState.ZAgree K c cb s₁ s₂)
    (src : Src) : src.get s₂ = src.get s₁ := by
  cases src <;> simp only [Src.get, h.deck, h.hand, h.discard]

theorem Src.set_agree {c cb : Cap} {s₁ s₂ : PlayerState} (h : PlayerState.ZAgree K c cb s₁ s₂)
    (src : Src) (r : List Card) : PlayerState.ZAgree K c cb (src.set r s₁) (src.set r s₂) := by
  cases src <;>
    exact ⟨by simp only [Src.set, h.deck], by simp only [Src.set, h.hand],
      by simp only [Src.set, h.discard], h.active, h.bench⟩

theorem Put.sim {c cb : Cap} {d : Dst} {t : List Card} {x₁ y₁ x₂ : PlayerState}
    (hp : Put d t x₁ y₁) (h : PlayerState.ZAgree K c cb x₁ x₂) :
    ∃ y₂, Put d t x₂ y₂ ∧ PlayerState.ZAgree K c cb y₁ y₂ := by
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
theorem InPlay.Agree.addEnergy {c : Cap} {q p : InPlay} (h : InPlay.Agree K c q p) (x : Card) :
    InPlay.Agree K c (q.addEnergy x) (p.addEnergy x) := by
  unfold InPlay.addEnergy; rw [h.energy]; exact h.upd.1 _

/-- Replacing the attached Energy keeps two agreeing Pokémon agreeing. -/
theorem InPlay.Agree.setEnergy {c : Cap} {q p : InPlay} (h : InPlay.Agree K c q p) (e : List Card) :
    InPlay.Agree K c { q with energy := e } { p with energy := e } := h.upd.1 e

/-- Dealing Energy cards (milestone MV6) keeps agreeing Active Spots and Benches agreeing. -/
theorem Deal.sim {c cb : Cap} {tf : Filter} {t : List Card} {a₁ a₁' : Option InPlay}
    {b₁ b₁' : List InPlay} (h : Deal tf t a₁ b₁ a₁' b₁') : ∀ {a₂ : Option InPlay} {b₂ : List InPlay},
    a₂.map (InPlay.clampWith K c) = a₁.map (InPlay.clampWith K c) →
    b₂.map (InPlay.clampWith K cb) = b₁.map (InPlay.clampWith K cb) →
    ∃ a₂' b₂', Deal tf t a₂ b₂ a₂' b₂' ∧
      a₂'.map (InPlay.clampWith K c) = a₁'.map (InPlay.clampWith K c) ∧
      b₂'.map (InPlay.clampWith K cb) = b₁'.map (InPlay.clampWith K cb) := by
  induction h with
  | nil a b => intro a₂ b₂ ha hb; exact ⟨a₂, b₂, .nil _ _, ha, hb⟩
  | @active e xs p b a' b' ht hok _ ih =>
      intro a₂ b₂ ha hb
      obtain ⟨p₂, rfl, hag⟩ := agree_of_map ha
      obtain ⟨a₃, b₃, hd, h1, h2⟩ := ih (a₂ := some (p₂.addEnergy (.energy e))) (b₂ := b₂)
        (by simp only [Option.map_some, InPlay.clamp_of_agree (hag.addEnergy _)]) hb
      exact ⟨a₃, b₃, .active (by rw [hag.top]; exact ht) (by rw [hag.top]; exact hok) hd, h1, h2⟩
  | @bench e xs a q c₁ c₂ a' b' ht hok _ ih =>
      intro a₂ b₂ ha hb
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split hb
      have hq := InPlay.agree_of_clamp h2
      subst hb₂
      obtain ⟨a₃, b₃, hd, k1, k2⟩ := ih (a₂ := a₂) (b₂ := d₁ ++ q₂.addEnergy (.energy e) :: d₂) ha
        (by simp only [List.map_append, List.map_cons, h1, h3,
          InPlay.clamp_of_agree (hq.addEnergy _)])
      exact ⟨a₃, b₃, .bench (by rw [hq.top]; exact ht) (by rw [hq.top]; exact hok) hd, k1, k2⟩

/-- Attaching Energy cards to agreeing Benches (milestone MV11, `ShiftTo`) keeps them agreeing. -/
theorem ShiftTo.sim {cb : Cap} {t : List Card} {one : Bool} {b b' : List InPlay}
    (h : ShiftTo t one b b') {e : List InPlay}
    (he : e.map (InPlay.clampWith K cb) = b.map (InPlay.clampWith K cb)) :
    ∃ e', ShiftTo t one e e' ∧ e'.map (InPlay.clampWith K cb) = b'.map (InPlay.clampWith K cb) := by
  cases h with
  | @one q q' b₁ b₂ hd =>
      obtain ⟨d₁, q₂, d₂, rfl, h1, h2, h3⟩ := map_eq_split he
      obtain ⟨a₃, b₃, hd₃, ha₃, hb₃⟩ := hd.sim (K := K) (c := cb) (cb := cb) (a₂ := none) (b₂ := [q₂]) rfl
        (by simp only [List.map_cons, List.map_nil, h2])
      cases a₃ with
      | some _ => simp at ha₃
      | none =>
          match b₃, hb₃, hd₃ with
          | [x], hx, hd₃ =>
              simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at hx
              exact ⟨d₁ ++ x :: d₂, .one hd₃, by
                simp only [List.map_append, List.map_cons, h1, h3, hx]⟩
          | [], hx, _ => simp at hx
          | _ :: _ :: _, hx, _ => simp at hx
  | many hd =>
      obtain ⟨a₃, b₃, hd₃, ha₃, hb₃⟩ := hd.sim (K := K) (c := cb) (cb := cb) (a₂ := none) (b₂ := e) rfl he
      cases a₃ with
      | some _ => simp at ha₃
      | none => exact ⟨b₃, .many hd₃, hb₃⟩

/-- Placing the cards taken from a window (milestone MV6) keeps agreeing states agreeing. -/
theorem Place.sim {c cb : Cap} {i : Into} {t : List Card} {x₁ y₁ x₂ : PlayerState}
    (hp : Place i t x₁ y₁) (h : PlayerState.ZAgree K c cb x₁ x₂) :
    ∃ y₂, Place i t x₂ y₂ ∧ PlayerState.ZAgree K c cb y₁ y₂ := by
  cases hp with
  | put hp =>
      obtain ⟨y₂, h₂, hy⟩ := hp.sim h
      exact ⟨y₂, .put h₂, hy⟩
  | bench hb hl =>
      refine ⟨_, .bench hb (by rw [length_of_map h.bench]; exact hl),
        ⟨h.deck, h.hand, h.discard, h.active, ?_⟩⟩
      simp only [List.map_append, h.bench]
  | attach hd =>
      obtain ⟨a₂, b₂, hd₂, ha, hb⟩ := hd.sim h.active h.bench
      exact ⟨_, .attach hd₂, ⟨h.deck, h.hand, h.discard, ha, hb⟩⟩

/-- **The kernel of every clamp is a simulation for zone steps**, at any caps. -/
theorem ZStep.sim {c cb : Cap} {e : Effect} {s₁ s₁' s₂ : PlayerState} (h : ZStep e s₁ s₁')
    (ha : PlayerState.ZAgree K c cb s₁ s₂) :
    ∃ s₂', ZStep e s₂ s₂' ∧ PlayerState.ZAgree K c cb s₁' s₂' := by
  cases h with
  | @move w src dst f q s s' t r hs hq hp =>
      obtain ⟨y₂, hp₂, hy⟩ := hp.sim (Src.set_agree ha src r)
      exact ⟨y₂, .move (by rw [Src.get_congr ha]; exact hs) hq hp₂, hy⟩
  | drawTo w n s =>
      refine ⟨_, .drawTo w n s₂, ⟨?_, ?_, ha.discard, ha.active, ha.bench⟩⟩ <;>
        simp only [PlayerState.drawK, ha.deck, ha.hand]
  | @attachActive w src f tf s r t a hs hac ht hok =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      have hs' := Src.set_agree ha src r
      refine ⟨_, .attachActive (by rw [Src.get_congr ha]; exact hs) ha₂ (by rw [hag.top]; exact ht)
        (by rw [hag.top]; exact hok),
        ⟨hs'.deck, hs'.hand, hs'.discard, ?_, hs'.bench⟩⟩
      simp only [Option.map_some, InPlay.clamp_of_agree (hag.addEnergy _)]
  | @attachBench w src f tf s r t q b₁ b₂ hs hb ht hok =>
      have hs' := Src.set_agree ha src r
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hq := InPlay.agree_of_clamp h2
      refine ⟨_, .attachBench (by rw [Src.get_congr ha]; exact hs) hb₂ (by rw [hq.top]; exact ht)
        (by rw [hq.top]; exact hok),
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
      refine ⟨_, .discardActive ha₂ (by rw [hag.energy]; exact hs) (by rw [hag.top, hag.energy]; exact hq),
        ⟨ha.deck, ha.hand, by simp only [ha.discard], ?_, ha.bench⟩⟩
      simp only [Option.map_some, InPlay.clamp_of_agree (hag.setEnergy r)]
  | @discardBench w f q s p b₁ b₂ t r hb hs hq =>
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hp := InPlay.agree_of_clamp h2
      refine ⟨_, .discardBench hb₂ (by rw [hp.energy]; exact hs) (by rw [hp.top, hp.energy]; exact hq),
        ⟨ha.deck, ha.hand, by simp only [ha.discard], ha.active, ?_⟩⟩
      simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hp.setEnergy r)]
  | discardNone hb =>
      have hm := ha.bench
      rw [hb, List.map_nil, List.map_eq_nil_iff] at hm
      exact ⟨s₂, .discardNone hm, ha⟩
  | @moveAB w f s a q b₁ b₂ e₁ e₂ x hac he hx hb hok =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hq := InPlay.agree_of_clamp h2
      refine ⟨_, .moveAB ha₂ (by rw [hag.energy]; exact he) hx hb₂ (by rw [hq.top]; exact hok),
        ⟨ha.deck, ha.hand, ha.discard, ?_, ?_⟩⟩
      · simp only [Option.map_some, InPlay.clamp_of_agree (hag.setEnergy _)]
      · simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hq.addEnergy _)]
  | @moveBA w f s a q b₁ b₂ e₁ e₂ x hac hb he hx hok =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hq := InPlay.agree_of_clamp h2
      refine ⟨_, .moveBA ha₂ hb₂ (by rw [hq.energy]; exact he) hx (by rw [hag.top]; exact hok),
        ⟨ha.deck, ha.hand, ha.discard, ?_, ?_⟩⟩
      · simp only [Option.map_some, InPlay.clamp_of_agree (hag.addEnergy _)]
      · simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hq.setEnergy _)]
  | @moveBB w f s q q' b₁ b₂ c₁ c₂ e₁ e₂ x hb he hx hc hok =>
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hq := InPlay.agree_of_clamp h2
      have hm : (d₁ ++ { q₂ with energy := e₁ ++ e₂ } :: d₂).map (InPlay.clampWith K cb) =
          (c₁ ++ q' :: c₂).map (InPlay.clampWith K cb) := by
        rw [← hc]
        simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hq.setEnergy _)]
      obtain ⟨k₁, q₃, k₂, hk, g1, g2, g3⟩ := map_eq_split hm
      have hq' := InPlay.agree_of_clamp g2
      refine ⟨_, .moveBB hb₂ (by rw [hq.energy]; exact he) hx hk (by rw [hq'.top]; exact hok),
        ⟨ha.deck, ha.hand, ha.discard, ha.active, ?_⟩⟩
      simp only [List.map_append, List.map_cons, g1, g3, InPlay.clamp_of_agree (hq'.addEnergy _)]
  | moveNone w f s => exact ⟨s₂, .moveNone w f s₂, ha⟩
  | @toolsActive w s a hac =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      refine ⟨_, .toolsActive ha₂,
        ⟨ha.deck, ha.hand, by simp only [ha.discard, hag.tools], ?_, ha.bench⟩⟩
      simp only [Option.map_some, InPlay.clamp_of_agree (hag.setTools [])]
  | @toolsBench w s p b₁ b₂ hb =>
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hp := InPlay.agree_of_clamp h2
      refine ⟨_, .toolsBench hb₂,
        ⟨ha.deck, ha.hand, by simp only [ha.discard, hp.tools], ha.active, ?_⟩⟩
      simp only [List.map_append, List.map_cons, h1, h3, InPlay.clamp_of_agree (hp.setTools [])]
  | toolsNone hb =>
      have hm := ha.bench
      rw [hb, List.map_nil, List.map_eq_nil_iff] at hm
      exact ⟨s₂, .toolsNone hm, ha⟩
  | @look w src f q i rest s s₁ s' t r hs hq hr hp =>
      obtain ⟨y₁, hr₂, hy₁⟩ := hr.sim (Src.set_agree ha src [])
      obtain ⟨y₂, hp₂, hy₂⟩ := hp.sim hy₁
      exact ⟨y₂, .look (by rw [Src.get_congr ha]; exact hs) hq hr₂ hp₂, hy₂⟩
  | @retActive w f q d s s' a t r hac hs hq hp =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      obtain ⟨y₂, hp₂, hy⟩ := hp.sim (c := c) (cb := cb) (x₂ := { s₂ with active := some { a₂ with energy := r } })
        ⟨ha.deck, ha.hand, ha.discard,
          by simp only [Option.map_some, InPlay.clamp_of_agree (hag.setEnergy r)], ha.bench⟩
      exact ⟨y₂, .retActive ha₂ (by rw [hag.energy]; exact hs)
        (by rw [hag.top, hag.energy]; exact hq) hp₂, hy⟩
  | @retBench w f q d s s' p b₁ b₂ t r hb hs hq hp =>
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hpa := InPlay.agree_of_clamp h2
      obtain ⟨y₂, hp₂, hy⟩ := hp.sim (c := c) (cb := cb)
        (x₂ := { s₂ with bench := d₁ ++ { q₂ with energy := r } :: d₂ })
        ⟨ha.deck, ha.hand, ha.discard, ha.active,
          by simp only [List.map_append, List.map_cons, h1, h3,
            InPlay.clamp_of_agree (hpa.setEnergy r)]⟩
      exact ⟨y₂, .retBench hb₂ (by rw [hpa.energy]; exact hs)
        (by rw [hpa.top, hpa.energy]; exact hq) hp₂, hy⟩
  | retNone hb =>
      have hm := ha.bench
      rw [hb, List.map_nil, List.map_eq_nil_iff] at hm
      exact ⟨s₂, .retNone hm, ha⟩
  | @shiftAB w f q one s a t r b' hac hs hq hd =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      obtain ⟨e', hd₂, he'⟩ := hd.sim ha.bench
      exact ⟨_, .shiftAB ha₂ (by rw [hag.energy]; exact hs) (by rw [hag.top, hag.energy]; exact hq) hd₂,
        ⟨ha.deck, ha.hand, ha.discard,
          by simp only [Option.map_some, InPlay.clamp_of_agree (hag.setEnergy r)], he'⟩⟩
  | @shiftBA w f q one s a p b₁ b₂ t r a' hac hb hs hq hd =>
      have hm := ha.active
      rw [hac] at hm
      obtain ⟨a₂, ha₂, hag⟩ := agree_of_map hm
      obtain ⟨d₁, q₂, d₂, hb₂, h1, h2, h3⟩ := map_eq_split (hb ▸ ha.bench)
      have hpa := InPlay.agree_of_clamp h2
      obtain ⟨a₃, b₃, hd₃, ha₃, hb₃⟩ := hd.sim (c := c) (cb := cb) (a₂ := some a₂) (b₂ := [])
        (by rw [ha₂] at hm; exact hm) rfl
      cases b₃ with
      | cons _ _ => simp at hb₃
      | nil =>
          exact ⟨_, .shiftBA ha₂ hb₂ (by rw [hpa.energy]; exact hs)
            (by rw [hpa.top, hpa.energy]; exact hq) hd₃,
            ⟨ha.deck, ha.hand, ha.discard, ha₃,
              by simp only [List.map_append, List.map_cons, h1, h3,
                InPlay.clamp_of_agree (hpa.setEnergy r)]⟩⟩
  | shiftNone hb =>
      have hm := ha.bench
      rw [hb, List.map_nil, List.map_eq_nil_iff] at hm
      exact ⟨s₂, .shiftNone hm, ha⟩

/-! ## Triggers (milestone M8b)

An effect of the trigger fragment (`Effect.trigOk`) reads no damage and only adds damage counters,
so it is simulated under every clamp, whatever the caps on each player's Active and Benched
Pokémon (`Run.trig_sim`); with the players exchanged the caps are exchanged
(`GameState.swap_clampAt`), so a trigger resolution is simulated too (`Fire.clamp_sim`). -/

theorem GameState.swap_clampAt (co cp cbo cbp : Cap) (k : Nat) (g : GameState) :
    g.swap.clampAt co cp cbo cbp k = (g.clampAt cp co cbp cbo k).swap := rfl

/-- **An effect of the trigger fragment is simulated under any clamp.** -/
theorem Run.trig_sim {co cp cbo cbp : Cap} {k : Nat} {e : Effect} {g₁ g₁' : GameState}
    (h : Run e g₁ g₁') : e.trigOk = true → ∀ {g₂ : GameState},
      g₁.clampAt co cp cbo cbp k = g₂.clampAt co cp cbo cbp k →
      ∃ g₂', Run e g₂ g₂' ∧ g₁'.clampAt co cp cbo cbp k = g₂'.clampAt co cp cbo cbp k := by
  induction h with
  | skip g => intro _ g₂ hc; exact ⟨g₂, .skip g₂, hc⟩
  | draw h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .draw h, by simp only [GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂]⟩
  | drawEmpty h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .drawEmpty h, hc⟩
  | counters n h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .counters n rfl, by
        simp only [GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.upd.2.1 n), he₁, he₂]⟩
  | @inflict g p c h =>
      intro _ g₂ hc
      have hsf := GameState.sameField_of_clampAt hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      rw [h] at ha₂
      obtain ⟨q, rfl, hq⟩ := agree_of_map ha₂
      exact ⟨_, .inflict c rfl, by
        simp only [GameState.clampAt, Option.map_some, hc₂, hm₁, hm₂,
          InPlay.clamp_of_agree (hq.inflictIf (hsf.condImmune .opp c hq.sv) c), he₁, he₂]⟩
  | shuffle h =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      exact ⟨_, .shuffle h, by simp only [GameState.clampAt, hc₂, ha₂, hm₁, hm₂, he₁, he₂]⟩
  | @zone e w g s' hw hz =>
      intro _ g₂ hc
      obtain ⟨c₂, a₂, m₁, m₂, e₁, e₂, rfl, hc₂, ha₂, hm₁, hm₂, he₁, he₂⟩ := GameState.clamp_inv hc
      cases w with
      | own =>
          obtain ⟨s₂', hz₂, hag⟩ := hz.sim (s₂ := { g.cur with active := c₂, bench := e₁, mods := m₁ })
            ⟨rfl, rfl, rfl, hc₂, he₁⟩
          exact ⟨_, .zone hw hz₂, by
            simp only [GameState.clampAt, GameState.updSide,
              PlayerState.setZones, hag.deck, hag.hand, hag.discard, hag.active, hag.bench, ha₂,
              he₂, hm₁, hm₂]⟩
      | opp =>
          obtain ⟨s₂', hz₂, hag⟩ := hz.sim (s₂ := { g.opp with active := a₂, bench := e₂, mods := m₂ })
            ⟨rfl, rfl, rfl, ha₂, he₂⟩
          exact ⟨_, .zone hw hz₂, by
            simp only [GameState.clampAt, GameState.updSide,
              PlayerState.setZones, hag.deck, hag.hand, hag.discard, hag.active, hag.bench, hc₂,
              he₁, hm₁, hm₂]⟩
  | seq _ _ ih₁ ih₂ =>
      intro hk g₂ hc
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      obtain ⟨g₂', r₁, hc'⟩ := ih₁ hk.1 hc
      obtain ⟨g₂'', r₂, hc''⟩ := ih₂ hk.2 hc'
      exact ⟨g₂'', .seq r₁ r₂, hc''⟩
  | choiceL _ ih =>
      intro hk g₂ hc
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      obtain ⟨g₂', r, hc'⟩ := ih hk.1 hc
      exact ⟨g₂', .choiceL r, hc'⟩
  | choiceR _ ih =>
      intro hk g₂ hc
      simp only [Effect.trigOk, Bool.and_eq_true] at hk
      obtain ⟨g₂', r, hc'⟩ := ih hk.2 hc
      exact ⟨g₂', .choiceR r, hc'⟩
  | @touchActive e w f g p he h =>
      intro hk; cases e <;> simp [Effect.touch, Effect.trigOk] at he hk
  | @touchBench e w f g q b₁ b₂ he h =>
      intro hk; cases e <;> simp [Effect.touch, Effect.trigOk] at he hk
  | _ => intro hk; simp [Effect.trigOk] at hk

/-- **A trigger resolution is simulated under any clamp** (milestone M8b). -/
theorem Fire.clamp_sim {co cp cbo cbp : Cap} {k : Nat} {ev : TrigEvent} {l : List Ability}
    {g₁ g₁' : GameState} (h : Fire ev l g₁ g₁') : ∀ {g₂ : GameState},
      g₁.clampAt co cp cbo cbp k = g₂.clampAt co cp cbo cbp k →
      ∃ g₂', Fire ev l g₂ g₂' ∧ g₁'.clampAt co cp cbo cbp k = g₂'.clampAt co cp cbo cbp k := by
  induction h generalizing co cp cbo cbp with
  | nil g => intro g₂ hc; exact ⟨g₂, .nil g₂, hc⟩
  | @run ab l g g₁ g₂ hk hr _ ih =>
      intro g₂' hc
      have hs : g.swap.clampAt cp co cbp cbo k = g₂'.swap.clampAt cp co cbp cbo k := by
        rw [GameState.swap_clampAt, GameState.swap_clampAt, hc]
      obtain ⟨h₁, r, hc₁⟩ := hr.trig_sim hk hs
      have hs' : g₁.swap.clampAt co cp cbo cbp k = h₁.swap.clampAt co cp cbo cbp k := by
        rw [GameState.swap_clampAt, GameState.swap_clampAt, hc₁]
      obtain ⟨h₂, ht, hc₂⟩ := ih hs'
      exact ⟨h₂, .run hk r ht, hc₂⟩
  | decline ho _ ih =>
      intro g₂ hc
      obtain ⟨h₂, ht, hc₂⟩ := ih hc
      exact ⟨h₂, .decline ho ht, hc₂⟩

/-- **The player to move's own triggers are simulated under any clamp** (milestone MV7c): they are
`Fire` on the exchanged state, whose clamp has the caps exchanged. -/
theorem FireMine.clamp_sim {co cp cbo cbp : Cap} {k : Nat} {u d : List Ability}
    {g₁ g₁' : GameState} (h : FireMine u d g₁ g₁') : ∀ {g₂ : GameState},
      g₁.clampAt co cp cbo cbp k = g₂.clampAt co cp cbo cbp k →
      ∃ g₂', FireMine u d g₂ g₂' ∧ g₁'.clampAt co cp cbo cbp k = g₂'.clampAt co cp cbo cbp k := by
  obtain ⟨x₁, x₂, h₁, h₂, rfl⟩ := h
  intro g₂ hc
  have hs : g₁.swap.clampAt cp co cbp cbo k = g₂.swap.clampAt cp co cbp cbo k := by
    rw [GameState.swap_clampAt, GameState.swap_clampAt, hc]
  obtain ⟨y₁, f₁, c₁⟩ := h₁.clamp_sim hs
  obtain ⟨y₂, f₂, c₂⟩ := h₂.clamp_sim c₁
  exact ⟨y₂.swap, ⟨y₁, y₂, f₁, f₂, rfl⟩, by rw [GameState.swap_clampAt, GameState.swap_clampAt, c₂]⟩

/-- **The resolution of the owed triggers is simulated under any clamp** (milestone MV7c): the
owed lists are read through the clamp and each block is simulated. -/
theorem Owed.clamp_sim {co cp cbo cbp : Cap} {k : Nat} {g₁ g₁' : GameState} (h : Owed g₁ g₁') :
    ∀ {g₂ : GameState}, g₁.clampAt co cp cbo cbp k = g₂.clampAt co cp cbo cbp k →
      ∃ g₂', Owed g₂ g₂' ∧ g₁'.clampAt co cp cbo cbp k = g₂'.clampAt co cp cbo cbp k := by
  intro g₂ hc
  have hU := GameState.upOwed_of_clampAt hc
  have hT := GameState.owedTrigs_of_clampAt hc
  have hc₀ := GameState.unpend_clampAt hc
  cases h with
  | mineFirst hu hd hl hm ht =>
      obtain ⟨m₂, hm₂, c₁⟩ := hm.clamp_sim hc₀
      obtain ⟨g₂', ht₂, c₂⟩ := ht.clamp_sim c₁
      exact ⟨g₂', .mineFirst (hU.1 ▸ hu) (hU.2 ▸ hd) (hT ▸ hl) hm₂ ht₂, c₂⟩
  | oppFirst hu hd hl ht hm =>
      obtain ⟨m₂, ht₂, c₁⟩ := ht.clamp_sim hc₀
      obtain ⟨g₂', hm₂, c₂⟩ := hm.clamp_sim c₁
      exact ⟨g₂', .oppFirst (hU.1 ▸ hu) (hU.2 ▸ hd) (hT ▸ hl) ht₂ hm₂, c₂⟩

/-- The kernel of `clamp k` is a simulation for taking the Knock Outs, when `hpBound` of the cards
is at most `k` (milestone M6 added the hypothesis: derived HP must be at most the cap). -/
theorem Resolve.clamp_sim {k : Nat} {g₁ g₁' : GameState} (h : Resolve g₁ g₁') :
    ∀ {g₂ : GameState}, hpBound g₁.allCards ≤ k → g₁.clamp k = g₂.clamp k →
      ∃ g₂', Resolve g₂ g₂' ∧ g₁'.clamp k = g₂'.clamp k := by
  induction h with
  | done h =>
      intro g₂ hH hc
      refine ⟨g₂, .done ?_, hc⟩
      rcases h with h | h
      · exact .inl (GameState.settled_of_clamp hc h (GameState.hpBelow_of_hpBound hH))
      · exact .inr (by rw [GameState.winner_of_clamp hc]; exact h)
  | step hn hm _ ih =>
      intro g₂ hH hc
      obtain ⟨m₂, hm₂, hcm⟩ := hm.clamp_sim hc (GameState.hpBelow_of_hpBound hH)
      obtain ⟨g₂', hr₂, hc'⟩ := ih (by rw [hpBound_perm hm.perm]; exact hH) hcm
      exact ⟨g₂', .step (by rw [GameState.winner_of_clamp hc]; exact hn) hm₂ hr₂, hc'⟩
  | @trigger g₀ g₃ g' hn hcl hp ho _ ih =>
      intro g₂ hH hc
      have hcl₂ := GameState.bothActive_of_clampAt hc hcl
      have hp₂ : g₂.pend = true := (GameState.pend_of_clampAt hc).trans hp
      obtain ⟨m₂, ho₂, hcm⟩ := ho.clamp_sim hc
      obtain ⟨g₂', hr₂, hc'⟩ := ih (by rw [hpBound_perm ho.perm, GameState.allCards_unpend]; exact hH) hcm
      exact ⟨g₂', .trigger (by rw [GameState.winner_of_clamp hc]; exact hn) hcl₂ hp₂ ho₂ hr₂, hc'⟩

end Pokemon
