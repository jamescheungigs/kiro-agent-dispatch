#!/bin/bash
# Called by the lead agent's prompt instruction to write discovered model IDs to disk.
# Usage: sync-models-from-agent.sh <opus_id> <sonnet_id> <haiku_id>

AGENTS_DIR="$HOME/.kiro/agents"
OPUS="$1"; SONNET="$2"; HAIKU="$3"

patch() {
  local file="$1" model="$2"
  [[ -z "$model" || ! -f "$file" ]] && return
  python3 -c "
import json
with open('$file') as f: c = json.load(f)
c['model'] = '$model'
with open('$file', 'w') as f: json.dump(c, f, indent=2)
print('patched $(basename $file) -> $model')
"
}

patch "$AGENTS_DIR/lead.json"          "$OPUS"
patch "$AGENTS_DIR/sonnet-worker.json" "$SONNET"
patch "$AGENTS_DIR/haiku-worker.json"  "$HAIKU"

# Update fallback too
python3 -c "
import json
models = [m for m in ['$HAIKU','$SONNET','$OPUS'] if m]
if models:
    with open('$AGENTS_DIR/model-fallback.json', 'w') as f:
        json.dump({'models': models, 'updated': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}, f, indent=2)
    print('updated model-fallback.json')
"
