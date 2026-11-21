#!/usr/bin/env bash
# Axiom gate, second line. `#audit_namespace` in Pokemon/Audit.lean fails the build itself on a
# bad axiom; this script fails CI unless the build log shows the gate's success line, and fails
# on any error or `sorry` warning.
set -euo pipefail
log="$1"
if grep -n -E "error|sorry" "$log"; then
  echo "audit: error or sorry in $log"; exit 1
fi
ok=$(grep -E "audit: [1-9][0-9]* theorems \(\+[0-9]+ generated\), axioms ⊆ \{propext, Quot\.sound\}" "$log" || true)
[ -n "$ok" ] || { echo "audit: success line missing from $log"; exit 1; }
echo "$ok"
