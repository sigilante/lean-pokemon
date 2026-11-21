#!/usr/bin/env bash
# Axiom gate, second line. `#audit_namespace` in Pokemon/Audit.lean fails the build itself on a
# bad axiom; this script fails CI unless the build log shows the gate's success line, and fails
# on any error or `sorry` warning. With a second argument (a file, e.g. PokemonCards/Audit.lean),
# the success line must be that file's, so that another library's gate line, replayed into the same
# log, does not stand in for it.
set -euo pipefail
log="$1"
where="${2:-}"
if grep -n -E "error|sorry" "$log"; then
  echo "audit: error or sorry in $log"; exit 1
fi
ok=$(grep -E "audit: [1-9][0-9]* theorems \(\+[0-9]+ generated\), axioms ⊆ \{propext, Quot\.sound\}" "$log" | grep -F "$where" || true)
[ -n "$ok" ] || { echo "audit: success line missing from $log"; exit 1; }
echo "$ok"
