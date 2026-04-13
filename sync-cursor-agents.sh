#!/bin/bash
# Sync Cursor agents (.md with YAML frontmatter) → Kiro agents (.json)
# Source: ~/.cursor/agents/*.md → Target: ~/.kiro/agents/*.json
# Run after editing Cursor agents to update Kiro copies.

CURSOR_DIR="$HOME/.cursor/agents"
KIRO_DIR="$HOME/.kiro/agents"

for md in "$CURSOR_DIR"/*.md; do
  [ -f "$md" ] || continue
  base=$(basename "$md" .md)
  json="$KIRO_DIR/$base.json"

  # Extract frontmatter fields
  name=$(sed -n '/^---$/,/^---$/{ /^name:/s/^name: *//p; }' "$md" | head -1)
  desc=$(sed -n '/^---$/,/^---$/{ /^description:/s/^description: *//p; }' "$md" | head -1)
  [ -z "$name" ] && name="$base"

  # Extract body (everything after the second ---)
  body=$(awk 'BEGIN{c=0} /^---$/{c++; if(c==2){found=1; next}} found{print}' "$md")

  # Build JSON with python for proper escaping
  python3 -c "
import json, sys
obj = {
    'name': sys.argv[1],
    'description': sys.argv[2] or sys.argv[1],
    'prompt': sys.argv[3] if sys.argv[3].strip() else None,
    'tools': ['@builtin'],
    'includeMcpJson': True,
    'model': None
}
print(json.dumps(obj, indent=2))
" "$name" "$desc" "$body" > "$json"

  echo "✓ $base.md → $base.json"
done
