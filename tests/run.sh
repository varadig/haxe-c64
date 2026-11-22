#!/usr/bin/env bash
# Runs every tests/<name>/Main.hx in the llvm-mos 6502 simulator and compares stdout with expected.txt
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass=0; fail=0
for dir in "$ROOT"/tests/*/; do
  name=$(basename "$dir")
  [[ -f "$dir/expected.txt" ]] || continue
  out=$(cd "$dir" && "$ROOT/bin/haxe64" -main Main --sim -o "$ROOT/build/test_$name.sim" 2>&1)
  if [[ "$out" == "$(cat "$dir/expected.txt")" ]]; then
    echo "PASS $name"; pass=$((pass+1))
  else
    echo "FAIL $name"; diff <(echo "$out") "$dir/expected.txt" | head -20; fail=$((fail+1))
  fi
done
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
