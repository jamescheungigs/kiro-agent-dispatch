# Kiro Agent Dispatch

Lead → Worker agent hierarchy for Kiro IDE. An Opus orchestrator
delegates tasks to Sonnet (complex) and Haiku (fast) workers based
on complexity, with auto-discovery of latest model IDs.

## Agent Hierarchy

```
lead (Opus)
├── sonnet-worker    — complex implementation, multi-file changes, analysis
├── haiku-worker     — quick lookups, grep, formatting, summaries
├── code-reviewer    — iterative review with fix loops (up to 5 rounds)
├── general-subagent — inherited model, full toolset
└── doc-gen-agent    — document generation pipeline
```

## Files

| File | Purpose |
|---|---|
| `agents/lead.json` | Orchestrator config with delegation rules |
| `agents/sonnet-worker.json` | Mid-tier worker (full tools) |
| `agents/haiku-worker.json` | Fast worker (restricted to read/grep/glob/bash) |
| `agents/code-reviewer.json` | Review agent with iterative fix dispatch |
| `agents/general-subagent.json` | Generic subagent (inherits parent model) |
| `agents/doc-gen-agent.json` | Document generation subagent |
| `agents/model-fallback.json` | Persisted model IDs (auto-updated) |
| `agents/sync-models.sh` | Auto-discover models via Bedrock API |
| `agents/sync-models-from-agent.sh` | Agent-callable model persistence |
| `agents/agent_config.json.example` | Reference template for new agents |
| `steering/second-brain.md` | Global steering rule for knowledge base |
| `settings/cli.json` | CLI config (default agent = lead) |
| `sync-cursor-agents.sh` | Convert Cursor .md agents → Kiro .json |

## Setup

### 1. Clone to ~/.kiro

```bash
git clone https://github.com/jamescheungigs/kiro-agent-dispatch.git ~/.kiro
```

### 2. Create symlinks to Cursor resources

```bash
cd ~/.kiro
ln -sf ~/.cursor/skills   skills
ln -sf ~/.cursor/docs     docs
ln -sf ~/.cursor/plans    plans
ln -sf ~/.cursor/commands prompts
ln -sf ~/.cursor/mcp.json settings/mcp.json
```

### 3. Update model IDs

Models change as Anthropic releases new versions. Three options:

```bash
# A. Tell the lead agent: "update models" (interactive selection)
# B. Auto-discover via AWS Bedrock:
~/.kiro/agents/sync-models.sh
# C. Manual edit: update model fields in lead.json, sonnet-worker.json, haiku-worker.json
```

The lead agent's prompt includes a built-in model selection flow — on first
session it checks `model-fallback.json` and uses saved models, or prompts
for selection if the file is missing.

## How Delegation Works

The lead agent's prompt contains these rules:

- **sonnet-worker**: complex implementation, multi-file changes, code analysis, architecture
- **haiku-worker**: simple lookups, file reads, grep, formatting, quick summaries

The lead specifies `agent_name` explicitly when delegating. Workers return
results to the lead, which synthesizes and responds to the user.

## Adding a New Agent

1. Copy `agents/agent_config.json.example` to `agents/your-agent.json`
2. Set `name`, `description`, `prompt`, `model`, and `tools`
3. Add the agent name to `lead.json` → `toolsSettings.subagent.availableAgents`
   and `trustedAgents`
4. Commit and push

## Syncing Cursor Agents

If you define agents as `.md` files with YAML frontmatter in `~/.cursor/agents/`,
convert them to Kiro's JSON format:

```bash
~/.kiro/sync-cursor-agents.sh
```
