import Lean

/-!
# An automatic axiom gate

`#audit_namespace Pokemon` checks every theorem declared in this project and fails the build
unless each depends on no axiom outside `propext` and `Quot.sound`.

What it checks:
* every module whose name lies under `Pokemon` must be imported (it walks the directory that
  holds the current file, so a new `Pokemon/*.lean` that nobody imports is an error);
* every `theorem` declared in those modules, or in the current file, is checked with
  `Lean.collectAxioms`. Private theorems, theorems in nested namespaces, theorems outside the
  `Pokemon` namespace, and compiler-generated theorems (equation lemmas, `injEq`,
  `sizeOf_spec`, abstracted `_proof_` terms, ...) are all included. Nothing is skipped:
  checking an auxiliary theorem costs little and can only make the gate stricter.
* `sorry` is the axiom `sorryAx`, so a theorem that uses `sorry` fails the gate too.

The info line reports how many checked theorems have source declaration ranges (those written
by hand) and how many are generated. The gate fails if it finds no
theorem with source at all.
-/

namespace Pokemon.Audit

open Lean Elab Command

/-- The axioms a theorem may depend on. -/
def allowedAxioms : List Name := [``propext, ``Quot.sound]

/-- Module names for the `.lean` files under `dir`, prefixed by `pre`. -/
partial def modulesUnder (dir : System.FilePath) (pre : Name) : IO (Array Name) := do
  let mut out := #[]
  for e in ← dir.readDir do
    if ← e.path.isDir then
      out := out ++ (← modulesUnder e.path (pre.str e.fileName))
    else if e.path.extension == some "lean" then
      if let some stem := e.path.fileStem then
        out := out.push (pre.str stem)
  return out

/-- `#audit_namespace N` checks every theorem declared in the modules under `N`. -/
syntax (name := auditNamespace) "#audit_namespace " ident : command

@[command_elab auditNamespace]
def elabAuditNamespace : CommandElab := fun stx => do
  let root := stx[1].getId
  let env ← getEnv
  -- 1. Every module under `root` must be imported.
  let file : System.FilePath := ← getFileName
  let some fileDir := file.parent
    | throwError "audit: cannot locate the directory of {file}"
  let here ← getMainModule
  let onDisk ← modulesUnder fileDir root
  let imported := env.allImportedModuleNames
  let missing := onDisk.filter fun m => m != here && !imported.contains m
  unless missing.isEmpty do
    throwError "audit: modules not imported by the audit file: {missing.toList}"
  -- 2. Collect the theorems declared in project modules and in this file.
  let mut thms : Array Name := #[]
  -- (Zipping, not `for h : i in ...` with a bounds proof: that proof used `Classical.choice`,
  -- and the gate, which also audits this file, rejected it.)
  for (m, d) in imported.zip env.header.moduleData do
    if root.isPrefixOf m then
      for c in d.constants do
        if c matches .thmInfo _ then thms := thms.push c.name
  for (n, c) in env.constants.map₂.toList do
    if c matches .thmInfo _ then thms := thms.push n
  let mut written := 0
  for n in thms do
    if (← findDeclarationRanges? n).isSome then written := written + 1
  if written == 0 then
    throwError "audit: no theorems found under {root}"
  -- 3. Check each theorem's axioms.
  let mut bad : Array MessageData := #[]
  for n in thms do
    let axs ← liftCoreM <| collectAxioms n
    for ax in axs do
      unless allowedAxioms.contains ax do
        bad := bad.push m!"{privateToUserName n} depends on {ax}"
  unless bad.isEmpty do
    throwError "audit: unexpected axioms:\n{MessageData.joinSep bad.toList "\n"}"
  logInfo m!"audit: {written} theorems (+{thms.size - written} generated), axioms ⊆ \{propext, Quot.sound}"

end Pokemon.Audit
