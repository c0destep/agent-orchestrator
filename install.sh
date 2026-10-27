#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scope=user; project=; dry=0; force=0; retire=0
while (($#)); do
 case "$1" in
 --user) scope=user;;
 --project) scope=project; shift; project="${1:?project path required}";;
 --dry-run) dry=1;;
 --force) force=1;;
 --retire-legacy) retire=1;;
 *) echo "Unknown argument: $1" >&2; exit 2;;
 esac; shift
done
if [[ "$scope" == project ]]; then
 [[ -d "$project" ]] || { echo "Project not found" >&2; exit 2; }
 project="$(cd "$project" && pwd)"
 skill="$project/.agents/skills/agent-orchestrator"; agents="$project/.codex/agents"
else
 skill="$HOME/.agents/skills/agent-orchestrator"; agents="${CODEX_HOME:-$HOME/.codex}/agents"
fi
shopt -s nullglob
srcs=(); dsts=()
while IFS= read -r -d '' source; do
 relative="${source#"$root/src/skills/agent-orchestrator/"}"
 srcs+=("$source"); dsts+=("$skill/$relative")
done < <(find "$root/src/skills/agent-orchestrator" -type f -print0 | sort -z)
for source in "$root"/src/agents/*.toml; do srcs+=("$source"); dsts+=("$agents/${source##*/}"); done
for ((i=0;i<${#srcs[@]};i++)); do
 d="${dsts[i]}"; s="${srcs[i]}"
 [[ ! -L "$d" && ! -d "$d" ]] || { echo "Refusing non-regular destination: $d" >&2; exit 1; }
 if [[ -f "$d" ]] && ! cmp -s "$s" "$d" && (( ! force )); then echo "Conflict: $d. Use --force after backup." >&2; exit 1; fi
done
legacy=(); for n in implementer-fast.toml reviewer-fast.toml; do
 old="$agents/$n"; backup="$agents/.agent-orchestrator-retired/v1.2.0/$n"
 if ((retire)) && [[ -e "$old" || -L "$old" ]]; then
 [[ -f "$old" && ! -L "$old" && ! -e "$backup" ]] || { echo "Unsafe legacy backup: $old" >&2; exit 1; }
 legacy+=("$n")
 fi
done
for ((i=0;i<${#srcs[@]};i++)); do
 d="${dsts[i]}"; s="${srcs[i]}"
 if [[ -f "$d" ]] && cmp -s "$s" "$d"; then echo "SKIP $d"; elif ((dry)); then echo "PLAN $d"; else mkdir -p "$(dirname "$d")"; cp "$s" "$d"; echo "WRITE $d"; fi
done
for n in "${legacy[@]}"; do
 if ((dry)); then echo "PLAN-RETIRE $agents/$n"; else mkdir -p "$agents/.agent-orchestrator-retired/v1.2.0"; mv "$agents/$n" "$agents/.agent-orchestrator-retired/v1.2.0/$n"; echo "RETIRED $n"; fi
done
