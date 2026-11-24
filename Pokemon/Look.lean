import Pokemon.Special

/-!
# Effect vocabulary 6, stage 1: look at a fixed window and choose (milestone MV6)

Survey S19 §A. The primitive `Effect.look w src f q i rest` (semantics `ZStep.look`) takes a whole
window of the `w` player's zones off its source at once (`Src.get`: the top or, since this milestone,
the bottom `n` cards of the deck as they are when the effect starts, the whole deck, the hand or the
discard pile), splits it into the cards taken (passing `f`, as many as `q` says; `Qty.most n`, new
here, is "`n`, or all that pass if fewer") and the other cards, puts the other cards at `rest`, and
then places the taken cards (`Into`: a zone, the Bench, or attached to the player's Pokémon "in any
way you like").

What "exact" means. The model has no hidden information (looking and revealing change nothing),
a shuffle is any permutation, chosen nondeterministically, and "in any order" is any permutation.
So a printed outcome is a partition of the window into the cards taken and the others, with the
others put where the text says in some order and the taken cards placed where it says. The two
theorems below say that the resolutions of `look` are exactly these:

* soundness, `ZStep.look_window`: every resolution partitions the window as it was when the effect
  started (`(t ++ r).Perm (src.get s)`), every card taken passes the filter, the quantity is as `q`
  says, the others are put at `rest`, and the taken cards are placed `i`;
* completeness, `ZStep.look_complete`: every such partition (up to the order inside each part) is a
  resolution, with every placement of its two parts.

The difference from a sequence of one-card primitives on `.top n` is that each of those reads the
top `n` cards of the deck as it is at that point, a window that moves down by one card each time a
card is taken: `moving_window` benches two cards with two `putBench … (.top 1)`, while every
resolution of `look … (.top 1) …` benches at most one (`fixed_window`).

A derived form already in the language is now proved equal to the new primitive: "Look at the top
`n` cards of your deck, take … into your hand, and shuffle the other cards back into your deck" is
`seq (move .own (.top n) .hand f q) shuffle` (`Run.look_hand_shuffle_iff`), and "put them back in any
order" is `look w (.top n) .any (.exactly 0) (.put .top) .top` (`ZStep.look_reorder_iff`).

The witnesses are attacks used as legal moves from well-formed, `Settled` states: Delibird's shape
(an Energy card to the hand, the others on the bottom), Reuniclus's (Pokémon onto the Bench, the
others shuffled back) and Metang's (Energy attached to two Pokémon, the others on the bottom).
-/

namespace Pokemon

/-! ## The characterisation -/

/-- A resolution of `look` is a zone step on its player's side. -/
theorem Run.look_iff {w : Whose} {src : Src} {f : Filter} {q : Qty} {i : Into} {rest : Dst}
    {g g' : GameState} :
    Run (.look w src f q i rest) g g' ↔
      ∃ s', ZStep (.look w src f q i rest) (g.side w) s' ∧ g' = g.updSide w fun s => s.setZones s' := by
  constructor
  · intro h
    cases h with
    | zone hw hz =>
        simp only [Effect.zSide, Option.some.injEq] at hw
        subst hw
        exact ⟨_, hz, rfl⟩
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he
  · rintro ⟨s', hz, rfl⟩
    exact .zone rfl hz

theorem ZStep.look_iff {w : Whose} {src : Src} {f : Filter} {q : Qty} {i : Into} {rest : Dst}
    {s s' : PlayerState} :
    ZStep (.look w src f q i rest) s s' ↔ ∃ s₁ t r, Split f (src.get s) t r ∧ q.ok f t r ∧
      Put rest r (src.set [] s) s₁ ∧ Place i t s₁ s' := by
  constructor
  · intro h
    cases h with
    | look hs hq hr hp => exact ⟨_, _, _, hs, hq, hr, hp⟩
  · rintro ⟨s₁, t, r, hs, hq, hr, hp⟩
    exact .look hs hq hr hp

/-- **Soundness**: every resolution of `look` partitions the window as it was when the effect
started into the cards taken, each passing the filter and as many as `q` says, and the other
cards; the others are put at `rest` and the taken cards placed `i`. -/
theorem ZStep.look_window {w : Whose} {src : Src} {f : Filter} {q : Qty} {i : Into} {rest : Dst}
    {s s' : PlayerState} (h : ZStep (.look w src f q i rest) s s') :
    ∃ s₁ t r, (t ++ r).Perm (src.get s) ∧ (∀ x ∈ t, f.eval x = true) ∧ q.ok f t r ∧
      Put rest r (src.set [] s) s₁ ∧ Place i t s₁ s' := by
  obtain ⟨s₁, t, r, hs, hq, hr, hp⟩ := ZStep.look_iff.1 h
  refine ⟨s₁, t, r, ListPerm.perm_of_count fun x => ?_, hs.taken, hq, hr, hp⟩
  rw [List.count_append, hs.count x]

/-- A partition of a list, given by counts, is a `Split` up to the order inside each part. -/
theorem Split.of_counts (f : Filter) : ∀ (l : List Card) {t' r' : List Card},
    (∀ a, List.count a t' + List.count a r' = List.count a l) → (∀ x ∈ t', f.eval x = true) →
    ∃ t r, Split f l t r ∧ (∀ a, List.count a t = List.count a t') ∧
      ∀ a, List.count a r = List.count a r'
  | [], t', r', h, _ => by
      refine ⟨[], [], .nil, fun a => ?_, fun a => ?_⟩ <;>
        · have := h a
          simp only [List.count_nil] at this ⊢
          omega
  | x :: l, t', r', h, hf => by
      by_cases hx : x ∈ t'
      · have h' : ∀ a, List.count a (ListPerm.remove1 x t') + List.count a r' = List.count a l := by
          intro a
          have h1 := h a
          have h2 := ListPerm.count_remove1 a x hx
          simp only [List.count_cons, beq_iff_eq] at h1
          by_cases hxa : x = a
          · subst hxa; simp only at h1 h2; omega
          · simp only [hxa, ite_false] at h1 h2; omega
        obtain ⟨t, r, hs, ht, hr⟩ := Split.of_counts f l h' fun y hy =>
          hf y (List.Perm.mem_iff (ListPerm.perm_cons_remove1 hx) |>.2 (.tail _ hy))
        refine ⟨x :: t, r, .take (hf x hx) hs, fun a => ?_, hr⟩
        have h2 := ListPerm.count_remove1 a x hx
        simp only [List.count_cons, beq_iff_eq, ht a]
        by_cases hxa : x = a
        · subst hxa; simp only at h2 ⊢; omega
        · simp only [hxa, ite_false] at h2 ⊢; omega
      · have hxr : x ∈ r' := by
          have h1 := h x
          have h0 : List.count x t' = 0 := List.count_eq_zero.2 hx
          simp only [List.count_cons, beq_self_eq_true, ite_true, h0, Nat.zero_add] at h1
          exact List.count_pos_iff.1 (by omega)
        have h' : ∀ a, List.count a t' + List.count a (ListPerm.remove1 x r') = List.count a l := by
          intro a
          have h1 := h a
          have h2 := ListPerm.count_remove1 a x hxr
          simp only [List.count_cons, beq_iff_eq] at h1
          by_cases hxa : x = a
          · subst hxa; simp only at h1 h2; omega
          · simp only [hxa, ite_false] at h1 h2; omega
        obtain ⟨t, r, hs, ht, hr⟩ := Split.of_counts f l h' hf
        refine ⟨t, x :: r, .keep hs, ht, fun a => ?_⟩
        have h2 := ListPerm.count_remove1 a x hxr
        simp only [List.count_cons, beq_iff_eq, hr a]
        by_cases hxa : x = a
        · subst hxa; simp only at h2 ⊢; omega
        · simp only [hxa, ite_false] at h2 ⊢; omega

/-- A quantity is a condition on the numbers of cards taken and on which cards are left, so it
does not depend on the order inside the two parts. -/
theorem Qty.ok_of_perm {q : Qty} {f : Filter} {t t' r r' : List Card} (ht : t.Perm t')
    (hr : r.Perm r') (h : q.ok f t' r') : q.ok f t r := by
  have hl := ht.length_eq
  cases q with
  | upTo n => simp only [Qty.ok] at h ⊢; omega
  | exactly n => simp only [Qty.ok] at h ⊢; omega
  | all => exact fun x hx => h x (hr.mem_iff.1 hx)
  | most n =>
      obtain ⟨h1, h2⟩ := h
      exact ⟨by omega, fun hlt x hx => h2 (by omega) x (hr.mem_iff.1 hx)⟩

/-- **Completeness**: every partition of the window into cards passing the filter, as many as `q`
says, and the other cards is a resolution of `look`, up to the order inside each part, with every
placement of the two parts. -/
theorem ZStep.look_complete {w : Whose} {src : Src} {f : Filter} {q : Qty} {i : Into} {rest : Dst}
    {s : PlayerState} {t' r' : List Card} (hp : (t' ++ r').Perm (src.get s))
    (hf : ∀ x ∈ t', f.eval x = true) (hq : q.ok f t' r') :
    ∃ t r, t.Perm t' ∧ r.Perm r' ∧ ∀ s₁ s', Put rest r (src.set [] s) s₁ → Place i t s₁ s' →
      ZStep (.look w src f q i rest) s s' := by
  obtain ⟨t, r, hs, ht, hr⟩ := Split.of_counts f (src.get s) (t' := t') (r' := r')
    (fun a => by rw [← List.count_append]; exact hp.count_eq a) hf
  have ht' := ListPerm.perm_of_count ht
  have hr' := ListPerm.perm_of_count hr
  exact ⟨t, r, ht', hr', fun _ _ h1 h2 => .look hs (Qty.ok_of_perm ht' hr' hq) h1 h2⟩

/-! ## Derived forms -/

/-- A `Split` that takes nothing leaves the whole list. -/
theorem Split.nil_taken {f : Filter} : ∀ {l r : List Card}, Split f l [] r → r = l
  | [], _, .nil => rfl
  | _ :: _, _, .keep h => by rw [Split.nil_taken h]

/-- **"Put them back in any order"** (Team Rocket's Dottler sv10-88, Gothorita rsv10pt5-42):
`look w (.top n) .any (.exactly 0) (.put .top) .top` puts the top `n` cards back in any order and
changes nothing else. -/
theorem ZStep.look_reorder_iff {w : Whose} {n : Nat} {s s' : PlayerState} :
    ZStep (.look w (.top n) .any (.exactly 0) (.put .top) .top) s s' ↔
      ∃ d, d.Perm (s.deck.take n) ∧ s' = { s with deck := d ++ s.deck.drop n } := by
  constructor
  · intro h
    obtain ⟨s₁, t, r, hs, hq, hr, hp⟩ := ZStep.look_iff.1 h
    simp only [Qty.ok] at hq
    obtain rfl : t = [] := List.eq_nil_of_length_eq_zero hq
    have hr0 := Split.nil_taken hs
    subst hr0
    cases hr with
    | @top _ d _ hd =>
        cases hp with
        | put hp =>
            cases hp with
            | @top _ e _ he =>
                obtain rfl : e = [] := List.eq_nil_of_length_eq_zero he.length_eq
                exact ⟨d, hd, rfl⟩
  · rintro ⟨d, hd, rfl⟩
    exact .look (t := []) (r := s.deck.take n) (Split.keepAll .any _) rfl
      (.top _ hd) (.put (.top (t' := []) _ (List.Perm.refl _)))

/-- **"Look at the top `n` cards …, put … into your hand, and shuffle the other cards back into your
deck"**: the window primitive and the derived form of milestone MV, a `move` from the top `n` cards
followed by a shuffle of the deck, have the same resolutions. -/
theorem Run.look_hand_shuffle_iff {n : Nat} {f : Filter} {q : Qty} {g g' : GameState} :
    Run (.look .own (.top n) f q (.put .hand) .shuffle) g g' ↔
      Run (.seq (.move .own (.top n) .hand f q) .shuffle) g g' := by
  constructor
  · intro h
    obtain ⟨s', hz, rfl⟩ := Run.look_iff.1 h
    obtain ⟨s₁, t, r, hs, hq, hr, hp⟩ := ZStep.look_iff.1 hz
    cases hr with
    | shuffle _ hd =>
        cases hp with
        | put hp =>
            cases hp with
            | hand => exact .seq (.zone rfl (.move hs hq (.hand _ _))) (.shuffle hd)
  · intro h
    cases h with
    | seq h₁ h₂ =>
        cases h₁ with
        | zone hw hz =>
            simp only [Effect.zSide, Option.some.injEq] at hw
            subst hw
            cases hz with
            | move hs hq hp =>
                cases hp with
                | hand =>
                    cases h₂ with
                    | shuffle hd =>
                        exact .zone rfl (.look hs hq (.shuffle _ hd) (.put (.hand _ _)))
                    | zone hw => simp [Effect.zSide] at hw
                    | touchActive he _ => simp [Effect.touch] at he
                    | touchBench he _ => simp [Effect.touch] at he
        | touchActive he _ => simp [Effect.touch] at he
        | touchBench he _ => simp [Effect.touch] at he
    | zone hw => simp [Effect.zSide] at hw
    | touchActive he _ => simp [Effect.touch] at he
    | touchBench he _ => simp [Effect.touch] at he

/-! ## A fixed window against a moving one -/

open Trainer

/-- A player whose deck holds two Basic Pokémon cards and whose Bench is empty. -/
def twoBasics : PlayerState :=
  { side [] [.energy .fire] (InPlay.ofBasic big) [] with deck := [.pokemon big, .pokemon big] }

/-- **The moving window**: two one-card primitives on the top card of the deck bench two Pokémon,
the second of which was not among the top card when the effect started. -/
theorem moving_window : ∃ s₁ s₂, ZStep (.putBench .own (.top 1) .basic) twoBasics s₁ ∧
    ZStep (.putBench .own (.top 1) .basic) s₁ s₂ ∧ s₂.bench.length = 2 :=
  ⟨_, _, .putBench (p := big) (.take rfl .nil) rfl (by decide) (by decide),
    .putBench (p := big) (.take rfl .nil) rfl (by decide) (by decide), rfl⟩

/-- **The fixed window**: every resolution of the window primitive on the top card benches at most
one Pokémon, however many it may take. -/
theorem fixed_window {s' : PlayerState}
    (h : ZStep (.look .own (.top 1) .basic (.upTo 2) .bench .top) twoBasics s') :
    s'.bench.length ≤ 1 := by
  obtain ⟨s₁, t, r, hp, -, -, hr, hpl⟩ := h.look_window
  have hl := hp.length_eq
  simp only [List.length_append, Src.get, twoBasics] at hl
  obtain ⟨-, -, hb⟩ := hr.fields
  cases hpl with
  | bench _ _ =>
      simp only [List.length_append, List.length_map] at hl ⊢
      rw [hb]
      simp only [Src.set, twoBasics, side, List.length_nil]
      have : (List.take 1 [Card.pokemon big, Card.pokemon big]).length = 1 := rfl
      omega

/-! ## Witnesses: attacks from well-formed, `Settled` states -/

namespace Look

open InPlayTests

/-- Delibird me6-79's shape as an attack: "Look at the top 2 cards of your deck, reveal an Energy
card you find there, and put it into your hand. Shuffle the other cards and put them on the bottom
of your deck." -/
def present : Attack :=
  ⟨"Present", [], 0, .look .own (.top 2) .energy (.most 1) (.put .hand) .bottom, false, .none⟩

/-- Reuniclus sv5-72's shape: "Look at the top 2 cards of your deck. You may put any number of
Pokémon you find there onto your Bench. Shuffle the other cards back into your deck." -/
def gate : Attack :=
  ⟨"Gate", [], 0, .look .own (.top 2) .pokemon (.upTo 2) .bench .shuffle, false, .none⟩

/-- Metang svp-90's shape: "Look at the top 3 cards of your deck and attach any number of Energy
cards you find there to your Pokémon in any way you like. Shuffle the other cards and put them on
the bottom of your deck." -/
def maker : Attack :=
  ⟨"Maker", [], 0, .look .own (.top 3) .energy (.upTo 3) (.attach .any) .bottom, false, .none⟩

def looker : PokemonCard := ⟨"Looker", .basic, none, 10, .colorless, [present, gate, maker], 1,
  none, none, .none, false, []⟩

/-- The player to move has `looker` Active, one Benched Pokémon, and the deck `d`; the opponent
`big`. -/
def start (d : List Card) : GameState :=
  ⟨{ side [] [.energy .fire] (InPlay.ofBasic looker) [InPlay.ofBasic big] with deck := d },
    side [] [.energy .fire] (InPlay.ofBasic big) [], true, false, false, false, none, none, false,
    false, false⟩

theorem start_wellFormed (d : List Card) : WellFormed (start d) := by
  refine ⟨fun _ => ⟨by simp [start, side], by simp [start, side]⟩, ?_, ?_⟩
  · intro p hp
    simp only [start, side, List.mem_singleton] at hp
    subst hp
    exact ⟨rfl, rfl, rfl, rfl⟩
  · intro p hp; cases hp

/-- The deck of the first witness: a Pokémon, a Fire Energy and a Water Energy, from the top. -/
def d₁ : List Card := [.pokemon big, .energy .fire, .energy .water]

theorem start_settled₁ : Settled (start d₁) := (GameState.settled_iff _).2 (by decide)

/-- **Witness (Delibird's shape)**: the Fire Energy, the one Energy among the top 2 cards, goes to
the hand, and the Pokémon card goes under the Water Energy, outside the window. -/
theorem present_witness :
    WellFormed (start d₁) ∧ Settled (start d₁) ∧ ∃ g, Move (start d₁) g ∧
      g.cur.hand = [.energy .fire] ∧ g.cur.deck = [.energy .water, .pokemon big] := by
  have hr : Run present.script (start d₁) _ :=
    .zone rfl (.look (t := [.energy .fire]) (r := [.pokemon big]) (.keep (.take rfl .nil))
      ⟨Nat.le_refl _, fun h => absurd h (Nat.lt_irrefl _)⟩ (.bottom _ (List.Perm.refl _))
      (.put (.hand _ _)))
  exact ⟨start_wellFormed _, start_settled₁, _,
    .attack (hlk := rfl) (atk := present) rfl (.head _) (.nil _) rfl rfl rfl rfl start_settled₁ hr
      rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl) (.nil _), rfl, rfl⟩

/-- The deck of the second witness: a Pokémon card, then a Grass Energy. -/
def d₂ : List Card := [.pokemon big, .energy .grass]

theorem start_settled₂ : Settled (start d₂) := (GameState.settled_iff _).2 (by decide)

/-- **Witness (Reuniclus's shape)**: the Pokémon card in the window goes onto the Bench, now of
two, and the Energy card is shuffled back. -/
theorem gate_witness :
    WellFormed (start d₂) ∧ Settled (start d₂) ∧ ∃ g, Move (start d₂) g ∧
      g.cur.bench = [InPlay.ofBasic big, InPlay.ofBasic big] ∧ g.cur.deck = [.energy .grass] := by
  have hr : Run gate.script (start d₂) _ :=
    .zone rfl (.look (t := [.pokemon big]) (r := [.energy .grass]) (.take rfl (.keep .nil))
      (by unfold Qty.ok; decide) (.shuffle _ (List.Perm.refl _))
      (.bench (ps := [big]) (fun p hp => by
        simp only [List.mem_singleton] at hp; subst hp; exact ⟨rfl, by decide⟩) (by decide)))
  exact ⟨start_wellFormed _, start_settled₂, _,
    .attack (hlk := rfl) (atk := gate) rfl (.tail _ (.head _)) (.nil _) rfl rfl rfl rfl
      start_settled₂ hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl)
      (.nil _), rfl, rfl⟩

/-- **Witness (Metang's shape)**: the two Energy cards of the top 3 are attached, one to the Active
Pokémon and one to the Benched Pokémon, and the Pokémon card goes to the bottom of the deck. -/
theorem maker_witness :
    WellFormed (start d₁) ∧ Settled (start d₁) ∧ ∃ g, Move (start d₁) g ∧
      g.cur.active = some ((InPlay.ofBasic looker).addEnergy (.energy .fire)) ∧
      g.cur.bench = [(InPlay.ofBasic big).addEnergy (.energy .water)] ∧
      g.cur.deck = [.pokemon big] := by
  have hr : Run maker.script (start d₁) _ :=
    .zone rfl (.look (t := [.energy .fire, .energy .water]) (r := [.pokemon big])
      (.keep (.take rfl (.take rfl .nil))) (by unfold Qty.ok; decide) (.bottom _ (List.Perm.refl _))
      (.attach (.active rfl (.bench (b₁ := []) rfl (.nil _ _)))))
  exact ⟨start_wellFormed _, start_settled₁, _,
    .attack (hlk := rfl) (atk := maker) rfl (.tail _ (.tail _ (.head _))) (.nil _) rfl rfl rfl rfl
      start_settled₁ hr rfl (fun h => absurd h (by decide)) rfl (HitTrig.exists_nil hr rfl)
      (.nil _), rfl, rfl, rfl⟩

end Look

end Pokemon
