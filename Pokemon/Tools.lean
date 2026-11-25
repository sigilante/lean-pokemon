import Pokemon.Stadiums

/-!
# Pokémon Tools: witnesses (milestone M5)

* `tool_discarded_with_pokemon`: a Tool attached to a Benched Pokémon goes to the discard pile
  with it when it is Knocked Out (here by an Item that puts a damage counter on it; the Knock Out
  is taken in mid-effect, `TRun`).
* `second_tool_refused`: a Pokémon with a Tool attached cannot take a second one; from a state in
  which every Pokémon of the player to move has a Tool, the Tool in hand stays in hand for the rest
  of the turn.
* `granted_attack`, `granted_attack_holder`: a Tool that gives an attack to a holder passing its
  filter (Core Memory me3-70: "The Mega Zygarde ex this card is attached to can use the attack on
  this card") lets that Pokémon attack; on another Pokémon the attack is not there.
* `tools_discarded`: an effect discards the Tools of the opponent's Active Pokémon ("discard all
  Pokémon Tools from your opponent's Active Pokémon").
-/

namespace Pokemon.Tools

open Recycle Stadiums

/-- A Tool whose effect the model does not express (static text; `ToolGrant.none`). -/
def helmet : Card := .tool "Helmet" ToolGrant.none

/-- A Basic Pokémon with 10 HP (one counter). -/
def small : PokemonCard := ⟨"Small", .basic, none, 1, .grass, [], 1, none, none, .none, false, []⟩

def smallAt (t : List Card) : InPlay := { InPlay.ofBasic small with fresh := false, tools := t }

/-- "Put 1 damage counter on 1 of your Benched Pokémon": no printed card has it. -/
def strike : Card := .trainer "Strike" .item (.benchCounters .own 1)

def tpl (hand : List Card) (active : InPlay) (bench : List InPlay) (discard : List Card) :
    PlayerState :=
  ⟨[mt], hand, discard, [mt, mt], [], some active, bench, false, false, false, false, false,
    Store.empty, true, KOHist.empty⟩

def T (a b : PlayerState) : GameState := ⟨a, b, true, false, false, false, none, none, false, false, false⟩

theorem T_settled {a b : PlayerState} (ha : a.active = some mon) (hb : b.active = some mon)
    (hab : ∀ p ∈ a.bench, p.damage < p.top.hp) (hbb : b.bench = [])
    (hpl : (T a b).Plain := by exact GameState.plain_of_plainB rfl) : Settled (T a b) :=
  Trainer.settled_of ha hb (show 0 < 10 by decide) (show 0 < 10 by decide) hab
    (by intro p hp; change p ∈ b.bench at hp; rw [hbb] at hp; cases hp) hpl

/-- **A Tool attached to a Benched Pokémon goes to the discard pile with it on a Knock Out**: the
player attaches `helmet` to the Benched `small` and plays `strike`, which Knocks it Out; the
opponent takes a Prize card, and `small` and `helmet` are in the player's discard pile. -/
theorem tool_discarded_with_pokemon :
    ∃ g, Reach (T (tpl [helmet, strike] mon [smallAt []] []) (wpl [] [mt] [])) g ∧
      g.cur.bench = [] ∧ g.cur.discard = [.pokemon small, helmet, strike] ∧
      g.opp.prizes = [mt] := by
  refine ⟨_, .step (.step (.refl _) rfl
    (.toolBench (l₁ := []) (l₂ := [strike]) (b₁ := []) (b₂ := []) rfl rfl rfl rfl
      (T_settled rfl rfl (fun p hp => by
        simp only [tpl, List.mem_singleton] at hp; subst hp; decide) rfl) rfl))
    rfl (.item (l₁ := []) (l₂ := []) rfl rfl
      (T_settled rfl rfl (fun p hp => by
        simp only [List.nil_append, List.mem_singleton] at hp; subst hp; decide) rfl)
      (.prim rfl rfl (.benchCounters (b₁ := []) (b₂ := []) .own 1 rfl)
        (.step rfl (.go (by decide) rfl .keep .keep)
          (.done (.inl (T_settled rfl rfl (fun p hp => by cases hp) rfl)))))
      rfl rfl rfl rfl), rfl, rfl, rfl⟩

/-- Every Pokémon of the player to move has a Tool attached, and a second Tool is in hand. -/
def R : GameState :=
  T (tpl [helmet] { mon with tools := [helmet] } [smallAt [helmet]] []) (wpl [] [mt] [])

/-- **A second Tool is refused**: from `R` no move of the turn attaches the Tool in hand ("Each
Pokémon can have only 1 Pokémon Tool attached at a time"); it stays in hand. -/
theorem second_tool_refused : ∀ g', Move R g' → g'.curIsFirst = true → g'.cur.hand = [helmet] := by
  intro g' hm hc
  cases hm with
  | playBasic hh => exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | trigger _ hp => simp [R, T] at hp
  | attach hh => exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | evolve hh => exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | attachBench hh => exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | evolveBench hh => exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | retreat ha hb hr he hp =>
      simp only [R, T, tpl, Option.some.injEq] at ha; subst ha
      rw [(GameState.plain_of_plainB (g := R) rfl).retreatOf rfl] at hp
      have hl := Split.taken_le he
      simp [Stadiums.mon, InPlay.ofBasic, Recycle.guard] at hl
      subst hl
      exact absurd hp (by decide)
  | item hh => exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | supporter hh => exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | stadium hh => exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | tool _ ha ht =>
      simp only [R, T, tpl, Option.some.injEq] at ha; subst ha
      simp at ht
  | toolBench _ hb ht =>
      simp only [R, T, tpl] at hb
      rcases List.cons_eq_append_iff.1 hb with ⟨rfl, h⟩ | ⟨_, rfl, h⟩
      · simp only [List.cons.injEq] at h; obtain ⟨rfl, -⟩ := h; simp [smallAt] at ht
      · simp at h
  | stadiumUse hs => simp [R, T] at hs
  | ability hu hm =>
      cases hu with
      | active ha =>
          simp only [R, T, tpl, Option.some.injEq] at ha; subst ha
          simp [InPlay.abilities, Stadiums.mon, InPlay.ofBasic, Recycle.guard, helmet,
            Card.grantAbilities, ToolGrant.none] at hm
      | bench hb =>
          simp only [R, T, tpl] at hb
          rcases List.cons_eq_append_iff.1 hb with ⟨rfl, h⟩ | ⟨_, rfl, h⟩
          · simp only [List.cons.injEq] at h; obtain ⟨rfl, -⟩ := h
            simp [InPlay.abilities, smallAt, InPlay.ofBasic, small, helmet, Card.grantAbilities,
              ToolGrant.none] at hm
          · simp at h
  | onPlay hp =>
      obtain ⟨_, _, hh⟩ := hp.hand
      exact absurd (mem_of_eq hh) (by simp [R, T, tpl, helmet])
  | attack ha hm =>
      simp only [R, T, tpl, Option.some.injEq] at ha; subst ha
      simp [InPlay.attacks, Stadiums.mon, InPlay.ofBasic, Recycle.guard, helmet,
        Card.grantAttacks, ToolGrant.none] at hm
  | attackConfused ha hm =>
      simp only [R, T, tpl, Option.some.injEq] at ha; subst ha
      simp [InPlay.attacks, Stadiums.mon, InPlay.ofBasic, Recycle.guard, helmet,
        Card.grantAttacks, ToolGrant.none] at hm
  | knockOuts h =>
      have hs : Settled R := by decide
      cases h with
      | won hu => exact absurd hs.calm hu
      | go hu => exact absurd hs.calm hu
  | endTurn => simp [R, T] at hc
  | startTurn hbt => simp [R, T] at hbt
  | deckOut hbt => simp [R, T] at hbt

/-! ## A Tool that gives an attack -/

/-- "Hit": no cost, 10 damage. -/
def hit : Attack := ⟨"Hit", [], 1, .skip, false, .none⟩

/-- A Tool that gives `hit` to a Pokémon named "Small" only (as Core Memory gives its attack to
Mega Zygarde ex only). -/
def memory : Card := .tool "Memory" ⟨.named "Small", [hit], [], []⟩

/-- The player to move has `small` Active with `memory` attached; the opponent has `mon`. -/
def G (t : List Card) (top : PokemonCard) : GameState :=
  T (tpl [] { InPlay.ofBasic top with fresh := false, tools := t } [] [])
    (wpl [] [mt] [])

/-- **A Tool gives its holder an attack**: `small`, which has no attack of its own, attacks with
`hit`, and the opponent's Active Pokémon takes a damage counter. -/
theorem granted_attack : ∃ g, Move (G [memory] small) g ∧
    g.opp.active.map InPlay.damage = some 1 :=
  ⟨_, .attack (hlk := rfl) (atk := hit) rfl
      (by simp [InPlay.attacks, memory, Card.grantAttacks, small, Filter.eval, InPlay.ofBasic])
      (.nil _) rfl rfl rfl rfl
      (Trainer.settled_of rfl rfl (show 0 < 1 by decide) (show 0 < 10 by decide)
        (fun p hp => by cases hp) (fun p hp => by cases hp))
      (.seq (.damage (.const 1 _) rfl) (.skip _)) rfl (fun h => nomatch h) rfl
      (HitTrig.exists_nil (.seq (.damage (.const 1 _) rfl) (.skip _)) rfl) (.nil _), rfl⟩

/-- **…only to a holder passing its filter**: attached to `mon` (not named "Small") the Tool gives
nothing, and `mon` has no attack. -/
theorem granted_attack_holder : ({ InPlay.ofBasic Recycle.guard with tools := [memory] } :
    InPlay).attacks = [] := by
  decide

/-! ## Discarding Tools -/

/-- "Discard all Pokémon Tools from your opponent's Active Pokémon" as an Item: no printed Item has
exactly this text (Megaton Blower sv8-182 discards Tools from all of the opponent's Pokémon). -/
def scrapper : Card := .trainer "Scrapper" .item (.discardTools .opp .active)

/-- **An effect discards the Tools of the opponent's Active Pokémon** to the opponent's discard
pile. -/
theorem tools_discarded : ∃ g, Move
      (T (tpl [scrapper] mon [] []) { wpl [] [mt] [] with active := some { mon with tools := [helmet] } }) g ∧
      g.opp.active.map InPlay.tools = some [] ∧ g.opp.discard = [helmet] :=
  ⟨_, .item (l₁ := []) (l₂ := []) rfl rfl
      (Trainer.settled_of rfl rfl (show 0 < 10 by decide) (show 0 < 10 by decide)
        (fun p hp => by cases hp) (fun p hp => by cases hp))
      (.prim rfl rfl (.zone (w := .opp) rfl (.toolsActive rfl))
        (.done (.inl (Trainer.settled_of rfl rfl (show 0 < 10 by decide)
          (show 0 < 10 by decide) (fun p hp => by cases hp) (fun p hp => by cases hp)))))
      rfl rfl rfl rfl, rfl, rfl⟩

end Pokemon.Tools
