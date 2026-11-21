/-!
# A constructive count criterion for permutations

Core's `List.perm_iff_count` depends on `Classical.choice`. This file proves the direction
we need (equal counts give a permutation) for a type with decidable equality, using only
`propext` and `Quot.sound`.
-/

namespace Pokemon.ListPerm

variable {α : Type} [DecidableEq α]

/-- Remove the first occurrence of `x`. -/
def remove1 (x : α) : List α → List α
  | [] => []
  | y :: t => if y = x then t else y :: remove1 x t

theorem perm_cons_remove1 {x : α} : ∀ {l : List α}, x ∈ l → l.Perm (x :: remove1 x l)
  | [], h => nomatch h
  | y :: t, h => by
      by_cases hy : y = x
      · subst hy; simp only [remove1, ite_true]; exact .refl _
      · simp only [remove1, hy, ite_false]
        have ht : x ∈ t := by
          cases h with
          | head => exact absurd rfl hy
          | tail _ h => exact h
        exact (List.Perm.cons y (perm_cons_remove1 ht)).trans (.swap x y _)

theorem count_remove1 (a x : α) : ∀ {l : List α}, x ∈ l →
    List.count a l = List.count a (remove1 x l) + (if x = a then 1 else 0)
  | [], h => nomatch h
  | y :: t, h => by
      by_cases hy : y = x
      · subst hy; simp only [remove1, ite_true, List.count_cons, beq_iff_eq]
      · simp only [remove1, hy, ite_false]
        have ht : x ∈ t := by
          cases h with
          | head => exact absurd rfl hy
          | tail _ h => exact h
        simp only [List.count_cons, count_remove1 a x ht]
        omega

private theorem mem_of_count_cons {x : α} {t l : List α}
    (h : ∀ a, List.count a (x :: t) = List.count a l) : x ∈ l := by
  have := h x
  apply List.count_pos_iff.1
  simp only [List.count_cons, beq_self_eq_true, ite_true] at this
  omega

private theorem count_nil_cons {b : α} {t : List α}
    (h : ∀ a, List.count a [] = List.count a (b :: t)) : False := by
  have := h b
  simp only [List.count_nil, List.count_cons, beq_self_eq_true, ite_true] at this
  omega

private theorem count_tail {x a : α} {t l r : List α}
    (h : List.count a (x :: t) = List.count a l)
    (h2 : List.count a l = List.count a r + (if x = a then 1 else 0)) :
    List.count a t = List.count a r := by
  rw [List.count_cons] at h
  simp only [beq_iff_eq] at h
  exact Nat.add_right_cancel (h.trans h2)

/-- Lists with the same count of every element are permutations of each other. -/
theorem perm_of_count {l₁ : List α} : ∀ {l₂ : List α},
    (∀ a, List.count a l₁ = List.count a l₂) → l₁.Perm l₂ := by
  induction l₁ with
  | nil =>
      intro l₂ h
      cases l₂ with
      | nil => exact .nil
      | cons b t => exact (count_nil_cons h).elim
  | cons x t ih =>
      intro l₂ h
      have hx : x ∈ l₂ := mem_of_count_cons h
      refine List.Perm.trans ?_ (perm_cons_remove1 hx).symm
      exact List.Perm.cons x (ih fun a => count_tail (h a) (count_remove1 a x hx))

end Pokemon.ListPerm
