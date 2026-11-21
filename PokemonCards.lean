import PokemonCards.Props
import PokemonCards.Standard
import PokemonCards.OverApprox
import PokemonCards.Audit

/-!
# Imported cards (library `PokemonCards`)

Today's Standard cards written as terms of the model's `Card` type by the importer
(`tools/importer/`), with Lean-checked properties of the imported set. Not part of the default
build target. Build with `lake build PokemonCards`; regenerate with
`python3 -I tools/importer/importer.py <path to pokemon-tcg-data>`.
-/
