import Pokemon.AuditCmd
import Pokemon.Card
import Pokemon.ListPerm
import Pokemon.State
import Pokemon.Effect
import Pokemon.Rules
import Pokemon.Conservation
import Pokemon.WellFormed
import Pokemon.Damage
import Pokemon.Sim
import Pokemon.Finite
import Pokemon.Infinite
import Pokemon.Reads
import Pokemon.Trainer
import Pokemon.Markers
import Pokemon.Lingering
import Pokemon.Counter
import Pokemon.Exact
import Pokemon.Bounded

/-! Axiom audit. `#audit_namespace` checks every theorem declared in the `Pokemon` modules
(private and generated ones included) and fails the build unless each depends only on
`propext` and `Quot.sound`. It also fails if a file under `Pokemon/` is not imported here. -/

#audit_namespace Pokemon
