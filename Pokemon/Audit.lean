import Pokemon.Damage

/-! Axiom audit. The build log must show only `propext` and `Quot.sound`
(or no axioms) for each theorem below. -/

#print axioms Pokemon.ListPerm.perm_of_count
#print axioms Pokemon.Run.perm
#print axioms Pokemon.Move.perm
#print axioms Pokemon.Reach.perm
#print axioms Pokemon.GameState.cards_eq_length
#print axioms Pokemon.Reach.cards_eq
#print axioms Pokemon.counters_unbounded
#print axioms Pokemon.Run.curIsFirst_eq
#print axioms Pokemon.Move.damageBounded_of_turn
#print axioms Pokemon.InPlay.clamp_inj_top
#print axioms Pokemon.InPlay.clamp_inj_cardList
#print axioms Pokemon.InPlay.clamp_inj_ko
#print axioms Pokemon.InPlay.clamp_inj_of_lt
#print axioms Pokemon.InPlay.clamp_add
#print axioms Pokemon.GameState.clamp_inv
#print axioms Pokemon.GameState.clamp_setCur
#print axioms Pokemon.Run.clamp_sim
#print axioms Pokemon.Move.clamp_sim
#print axioms Pokemon.Reach.clamp_sim
#print axioms Pokemon.hp_le_maxHp
#print axioms Pokemon.mem_benchCardList
#print axioms Pokemon.GameState.top_mem_cur_active
#print axioms Pokemon.GameState.top_mem_opp_active
#print axioms Pokemon.GameState.top_mem_cur_bench
#print axioms Pokemon.GameState.top_mem_opp_bench
#print axioms Pokemon.Run.damageLe
#print axioms Pokemon.Move.damageLe
#print axioms Pokemon.Reach.damage_le
#print axioms Pokemon.Reach.clamp_damage_le
