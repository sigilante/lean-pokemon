import Pokemon.AuditCmd
import PokemonCards.Props
import PokemonCards.Standard
import PokemonCards.OverApprox

/-! Axiom audit of the imported-card library. `#audit_namespace PokemonCards` checks every theorem
declared in the `PokemonCards` modules and fails the build unless each depends only on `propext`
and `Quot.sound`; it also fails if a file under `PokemonCards/` is not imported here. -/

#audit_namespace PokemonCards
