# Second Brain — Global Knowledge Base

A personal knowledge wiki is maintained at `~/Desktop/AI/second-brain/`.
Use it as a reference when working on any project.

## When to Consult the Knowledge Base

- When the user asks about topics that may already be covered (AI, agentic systems, security, etc.)
- When making architectural or design decisions that could benefit from prior research
- When the user explicitly says "check my notes", "what do I know about X", or "search my wiki"

## How to Use It

1. Read `~/Desktop/AI/second-brain/wiki/index.md` to find relevant pages
2. Read the specific wiki pages for synthesized knowledge
3. Cite the wiki page when using information from it: "Based on your wiki page on [[topic]]..."

## How to Add to It

If the current project produces knowledge worth preserving (architectural decisions, research findings, useful patterns):
1. Offer to save it: "This seems worth adding to your second brain. Want me to file it?"
2. If yes, save raw material to `~/Desktop/AI/second-brain/raw/articles/`
3. Then follow the ingest workflow in `~/Desktop/AI/second-brain/KIRO.md`

## Study a Project

To deeply analyze a codebase and wire it into the knowledge graph:
1. User runs: `~/Desktop/AI/second-brain/scripts/tag-project.sh <path> [name]`
2. Then in an interactive session: "study project <name>"
3. This runs a 5-pass analysis (orient → structure → domain → connect → assess)
4. Full workflow is in `~/Desktop/AI/second-brain/KIRO.md` under "Study Project Workflow"
5. To resume an interrupted study: "continue studying <name>"

## Tag a Document to a Project

To link a source to a specific project by path:
- "tag <document> to <path>" — the path is looked up in the project registry
- Full workflow is in `~/Desktop/AI/second-brain/KIRO.md` under "Tag Document to Project"

## YouTube Transcript Skill

When processing any YouTube URL, if the transcript is empty or missing:
- Run: `~/Desktop/AI/second-brain/scripts/fetch-yt-transcript.sh "<URL>"`
- This works globally — not just inside the second-brain project.
