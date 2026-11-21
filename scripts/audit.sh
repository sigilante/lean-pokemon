#!/usr/bin/env bash
# Axiom gate: every `#print axioms` line in the build log may name only propext and Quot.sound.
set -euo pipefail
log="$1"
grep -q "axioms" "$log" || { echo "audit: no '#print axioms' output in $log"; exit 1; }
bad=$(grep "depends on axioms" "$log" \
  | grep -v -E "depends on axioms: \[(propext|Quot\.sound|propext, Quot\.sound)\]$" || true)
if [ -n "$bad" ]; then echo "audit: unexpected axioms:"; echo "$bad"; exit 1; fi
if grep -n "sorry" "$log"; then echo "audit: sorry found"; exit 1; fi
echo "audit: clean ($(grep -c "axioms" "$log") theorems)"
