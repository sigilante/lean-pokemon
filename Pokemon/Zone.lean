import Pokemon.Rules
import Pokemon.ListPerm

/-!
# Zone moves: what they keep (milestone MV)

The zone-move primitives (`Effect.move`, `drawTo`, `attach`, `putBench`, `discardEnergy`,
`moveEnergy`; semantics `ZStep`, lifted by `Run.zone`) move cards between one player's deck,
hand, discard pile and Pokémon in play, and change nothing else.

* `ZStep.setZones`: a zone step changes only the five zones, so `Run.zone`'s result is the state
  the step computes.
* `ZStep.count`, `ZStep.perm`: a zone step permutes the player's cards (no card is created,
  destroyed or altered), which `Run.perm` and so `Reach.perm` use.
-/

namespace Pokemon

/-! ## Splitting a source -/

theorem Split.count {f : Filter} {l t r : List Card} (h : Split f l t r) (x : Card) :
    List.count x l = List.count x t + List.count x r := by
  induction h with
  | nil => rfl
  | take _ _ ih => simp only [List.count_cons, ih]; omega
  | keep _ ih => simp only [List.count_cons, ih]; omega

/-- Every card taken passes the filter. -/
theorem Split.taken {f : Filter} {l t r : List Card} (h : Split f l t r) :
    ∀ x ∈ t, f.eval x = true := by
  induction h with
  | nil => intro x hx; nomatch hx
  | take hx _ ih =>
      intro y hy
      cases hy with
      | head => exact hx
      | tail _ hy => exact ih y hy
  | keep _ ih => exact ih

/-- Every card taken is in the source. -/
theorem Split.mem {f : Filter} {l t r : List Card} (h : Split f l t r) :
    ∀ x ∈ t, x ∈ l := by
  induction h with
  | nil => intro x hx; nomatch hx
  | take _ _ ih =>
      intro y hy
      cases hy with
      | head => exact .head _
      | tail _ hy => exact .tail _ (ih y hy)
  | keep _ ih => exact fun y hy => .tail _ (ih y hy)

/-! ## Sources and destinations -/

@[simp] theorem Src.set_active (src : Src) (r : List Card) (s : PlayerState) :
    (src.set r s).active = s.active := by cases src <;> rfl
@[simp] theorem Src.set_bench (src : Src) (r : List Card) (s : PlayerState) :
    (src.set r s).bench = s.bench := by cases src <;> rfl
@[simp] theorem Src.set_prizes (src : Src) (r : List Card) (s : PlayerState) :
    (src.set r s).prizes = s.prizes := by cases src <;> rfl
@[simp] theorem Src.set_lost (src : Src) (r : List Card) (s : PlayerState) :
    (src.set r s).lost = s.lost := by cases src <;> rfl

theorem count_take_drop (n : Nat) (l : List Card) (x : Card) :
    List.count x l = List.count x (l.take n) + List.count x (l.drop n) := by
  rw [← List.count_append, List.take_append_drop]

/-- Replacing a source by the cards not taken: the counts of the player's cards change by the
cards taken. -/
theorem Src.count_set (src : Src) (r : List Card) (s : PlayerState) (x : Card) :
    List.count x (src.set r s).allCards + List.count x (src.get s) =
      List.count x s.allCards + List.count x r := by
  have := count_take_drop (match src with | .top n => n | _ => 0) s.deck x
  cases src <;>
    simp only [Src.set, Src.get, PlayerState.allCards, List.count_append] at this ⊢ <;> omega

/-- Putting cards at a destination adds them to the player's cards. -/
theorem Put.count {d : Dst} {t : List Card} {s s' : PlayerState} (h : Put d t s s') (x : Card) :
    List.count x s'.allCards = List.count x s.allCards + List.count x t := by
  cases h with
  | hand => simp only [PlayerState.allCards, List.count_append]; omega
  | discard => simp only [PlayerState.allCards, List.count_append]; omega
  | top _ h =>
      have := h.count_eq x
      simp only [PlayerState.allCards, List.count_append] at this ⊢; omega
  | bottom _ h =>
      have := h.count_eq x
      simp only [PlayerState.allCards, List.count_append] at this ⊢; omega
  | shuffle _ h =>
      have := h.count_eq x
      simp only [PlayerState.allCards, List.count_append] at this ⊢; omega

/-- A destination is never the Active Spot, the Bench, the Prizes or the Lost Zone. -/
theorem Put.fields {d : Dst} {t : List Card} {s s' : PlayerState} (h : Put d t s s') :
    s' = s.setZones s' ∧ s'.active = s.active ∧ s'.bench = s.bench := by
  cases h <;> exact ⟨rfl, rfl, rfl⟩

/-! ## Zone steps -/

theorem Src.setZones_set (src : Src) (r : List Card) (s : PlayerState) :
    src.set r s = s.setZones (src.set r s) := by cases src <;> rfl

/-- **A zone step changes only the five zones** (deck, hand, discard pile, Active Spot, Bench). -/
theorem ZStep.setZones {e : Effect} {s s' : PlayerState} (h : ZStep e s s') : s.setZones s' = s' := by
  cases h with
  | @move w src dst f q s s' t r hs hq hp => cases hp <;> cases src <;> rfl
  | @attachActive w src f tf s r t a hs ha ht => cases src <;> rfl
  | @attachBench w src f tf s r t q b₁ b₂ hs hb ht => cases src <;> rfl
  | @putBench w src f s r p hs hst hhp hb => cases src <;> rfl
  | _ => rfl

/-- The counts of the cards in a Pokémon's card list. -/
theorem InPlay.count_cardList (p : InPlay) (x : Card) :
    List.count x p.cardList = List.count x [Card.pokemon p.top] + List.count x p.under +
      List.count x p.energy + List.count x p.tools := by
  simp only [InPlay.cardList, List.count_cons, List.count_append, List.count_nil]; omega

theorem count_benchCardList_append (a b : List InPlay) (x : Card) :
    List.count x (benchCardList (a ++ b)) =
      List.count x (benchCardList a) + List.count x (benchCardList b) := by
  induction a with
  | nil => simp only [List.nil_append, benchCardList, List.count_nil, Nat.zero_add]
  | cons p ps ih => simp only [List.cons_append, benchCardList, List.count_append, ih]; omega

/-- **A zone step permutes the player's cards**: every count is unchanged. -/
theorem ZStep.count {e : Effect} {s s' : PlayerState} (h : ZStep e s s') (x : Card) :
    List.count x s'.allCards = List.count x s.allCards := by
  cases h with
  | @move w src dst f q s s' t r hs hq hp =>
      have h1 := hp.count x
      have h2 := Src.count_set src r s x
      have h3 := hs.count x
      omega
  | drawTo w n s =>
      have := count_take_drop (n - s.hand.length) s.deck x
      simp only [PlayerState.drawK, PlayerState.allCards, List.count_append] at this ⊢; omega
  | @attachActive w src f tf s r t a hs ha ht =>
      have h2 := Src.count_set src r s x
      have h3 := hs.count x
      simp only [PlayerState.allCards, List.count_append, optCardList, Src.set_active,
        Src.set_bench, ha, InPlay.count_cardList, InPlay.addEnergy] at h2 ⊢
      simp only [List.count_cons, List.count_nil] at h3 ⊢
      omega
  | @attachBench w src f tf s r t q b₁ b₂ hs hb ht =>
      have h2 := Src.count_set src r s x
      have h3 := hs.count x
      simp only [PlayerState.allCards, List.count_append, Src.set_active, Src.set_bench, hb,
        count_benchCardList_append, benchCardList, InPlay.count_cardList,
        InPlay.addEnergy] at h2 ⊢
      simp only [List.count_cons, List.count_nil] at h3 ⊢
      omega
  | attachNone => rfl
  | @putBench w src f s r p hs hst hhp hb =>
      have h2 := Src.count_set src r s x
      have h3 := hs.count x
      simp only [PlayerState.allCards, List.count_append, Src.set_active, Src.set_bench,
        count_benchCardList_append, benchCardList, InPlay.count_cardList, InPlay.ofBasic] at h2 ⊢
      simp only [List.count_cons, List.count_nil] at h3 ⊢
      omega
  | putBenchNone => rfl
  | @discardActive w f q s a t r ha hs hq =>
      have h3 := hs.count x
      simp only [PlayerState.allCards, List.count_append, optCardList, ha,
        InPlay.count_cardList]
      omega
  | @discardBench w f q s p b₁ b₂ t r hb hs hq =>
      have h3 := hs.count x
      simp only [PlayerState.allCards, List.count_append, hb, count_benchCardList_append,
        benchCardList, InPlay.count_cardList]
      omega
  | discardNone => rfl
  | @moveAB w f s a q b₁ b₂ e₁ e₂ y ha he hx hb =>
      simp only [PlayerState.allCards, List.count_append, optCardList, ha, hb,
        count_benchCardList_append, benchCardList, InPlay.count_cardList, InPlay.addEnergy, he,
        List.count_cons]
      omega
  | @moveBA w f s a q b₁ b₂ e₁ e₂ y ha hb he hx =>
      simp only [PlayerState.allCards, List.count_append, optCardList, ha, hb,
        count_benchCardList_append, benchCardList, InPlay.count_cardList, InPlay.addEnergy, he,
        List.count_cons]
      omega
  | @moveBB w f s q q' b₁ b₂ c₁ c₂ e₁ e₂ y hb he hx hc =>
      have h4 := congrArg (fun b => List.count x (benchCardList b)) hc
      simp only [count_benchCardList_append, benchCardList, List.count_append,
        InPlay.count_cardList, InPlay.addEnergy, List.count_cons] at h4
      simp only [PlayerState.allCards, List.count_append, hb, count_benchCardList_append,
        benchCardList, InPlay.count_cardList, InPlay.addEnergy, he, List.count_cons]
      omega
  | moveNone => rfl

theorem ZStep.perm {e : Effect} {s s' : PlayerState} (h : ZStep e s s') :
    s'.allCards.Perm s.allCards :=
  ListPerm.perm_of_count fun x => h.count x

/-- The result of `Run.zone` is the state the zone step computes, on its player's side. -/
theorem ZStep.updSide {e : Effect} {w : Whose} {g : GameState} {s' : PlayerState}
    (h : ZStep e (g.side w) s') :
    (g.updSide w fun s => s.setZones s') = g.updSide w fun _ => s' := by
  cases w <;> simp only [GameState.side] at h <;> simp only [GameState.updSide, h.setZones]

end Pokemon
