#!/bin/bash
# Auto-discover latest Claude model IDs via Bedrock and patch agent configs.
# Falls back to kiro-cli /model output if Bedrock API unavailable.

set -euo pipefail

AGENTS_DIR="$HOME/.kiro/agents"
LOG="$AGENTS_DIR/sync-models.log"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG"; }

# Strategy 1: Bedrock API (requires bedrock in AWS CLI)
fetch_via_bedrock() {
  local pattern="$1"
  aws bedrock list-foundation-models \
    --region "$REGION" \
    --query "modelSummaries[?contains(modelId, '$pattern') && responseStreamingSupported==\`true\`] | sort_by(@, &modelId) | [-1].modelId" \
    --output text 2>/dev/null
}

# Strategy 2: kiro-cli model list (parse available models headlessly)
fetch_via_kiro() {
  local pattern="$1"
  # kiro-cli doesn't expose a headless model list command, so we read from
  # a manually maintained fallback file if it exists
  local fallback="$AGENTS_DIR/model-fallback.json"
  if [[ -f "$fallback" ]]; then
    python3 -c "
import json, sys
data = json.load(open('$fallback'))
matches = [m for m in data.get('models', []) if '$pattern' in m]
print(matches[-1] if matches else '')
"
  fi
}

patch_model() {
  local file="$1"
  local model_id="$2"
  [[ -z "$model_id" || "$model_id" == "None" || "$model_id" == "null" ]] && return 1
  [[ ! -f "$file" ]] && return 1
  python3 -c "
import json
with open('$file') as f: cfg = json.load(f)
cfg['model'] = '$model_id'
with open('$file', 'w') as f: json.dump(cfg, f, indent=2)
"
  log "Patched $(basename $file) → $model_id"
}

log "=== sync-models start ==="

# Try Bedrock first, fall back to kiro fallback file
for tier in opus sonnet haiku; do
  MODEL=$(fetch_via_bedrock "$tier" 2>/dev/null || fetch_via_kiro "$tier" || echo "")
  case "$tier" in
    opus)   TARGET="$AGENTS_DIR/lead.json" ;;
    sonnet) TARGET="$AGENTS_DIR/sonnet-worker.json" ;;
    haiku)  TARGET="$AGENTS_DIR/haiku-worker.json" ;;
  esac
  if [[ -n "$MODEL" ]]; then
    patch_model "$TARGET" "$MODEL" || log "WARN: could not patch $TARGET"
  else
    log "WARN: no model found for $tier — keeping existing value"
  fi
done

log "=== sync-models done ==="
