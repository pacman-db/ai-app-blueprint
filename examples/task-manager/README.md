# task-manager — Bootstrap output example

This is what `/bootstrap-app` generates for a real idea.

**The idea given:** "An app that turns meeting transcripts into task lists, assigned to the right people, with deadlines."

Everything below was generated from that one sentence.

---

## What was generated (Step 0 → Step 5)

### Project name
`meeting-to-tasks` — derived from the idea, slug format.

### CONTEXT.md
→ [See CONTEXT.md](CONTEXT.md)

Real problem, real architecture, real decisions.
No placeholders. Compare this to the template in `blueprint/CONTEXT.md.template` to see the difference.

### docs/vision/product-vision.md (generated)

```markdown
## Problem
Teams leave meetings with action items scattered across notes, chat, and memory.
Within 48 hours, 60% of verbal commitments are forgotten or unassigned.

## Solution
Upload or paste the meeting transcript → get a structured task list in 30 seconds,
with each task assigned to the right person and a deadline extracted from what was said.

## For whom
Small and mid-size teams (5–50 people) that run meetings but don't have a PM.

## Why now
LLMs are now good enough at extracting structured data from messy natural language.
This wasn't reliably possible 2 years ago.
```

### docs/constitution/constitution.md (generated)

```markdown
## Principles

1. **Accuracy over speed** — a wrong task assignment is worse than a slow extraction.
   Never return a task without a clear owner if one was mentioned in the transcript.

2. **Workspace isolation is non-negotiable** — tasks from workspace A are never
   visible to workspace B. No exceptions, no admin overrides.

3. **Transcripts are transient** — process and discard. We are not a recording platform.
   Store only the extracted tasks, not the source audio or full transcript.
```

### docs/plan/v1-mvp.md (generated ADRs)

```markdown
## ADR-001: Haiku precheck before Sonnet
**Context:** Sonnet costs ~$0.025/call. Some uploads will be garbage (wrong file, spam).
**Decision:** Run a Haiku precheck first ($0.001): "Is this a meeting transcript? yes/no"
**Consequence:** ~70% cost reduction on bad inputs. Adds ~200ms latency on the happy path.

## ADR-002: Extract tasks as structured JSON, not free text
**Context:** We need to create DB records from the extraction.
**Decision:** Use Claude's structured output mode with a Pydantic schema.
**Consequence:** No parsing step. Type-safe from API to DB. Schema changes are explicit.

## ADR-003: Fuzzy match assignees against workspace members
**Context:** Transcripts say "John will do this" — we need to match to john@company.com
**Decision:** Fuzzy match on first name + last name against workspace member list.
**Consequence:** Need a confidence threshold. Below threshold → task unassigned with a flag.
```

### docs/clarify/assumptions.md (generated)

```markdown
## Open questions (before coding)

| Question | Status | Answer |
|---|---|---|
| Max transcript length? | ⬜ open | |
| Handle multiple languages? | ⬜ open | |
| What if same name appears twice in workspace? | ⬜ open | |
| Do we notify the assigner or just the assignee? | ⬜ open | |
| Free tier? Paid tier? | ⬜ open | |
```

---

## Why this example exists

Most blueprint examples show what the structure looks like after months of development.
This example shows what it looks like **on day 1**, generated from a single idea.

The point: you arrive with one sentence, and `/bootstrap-app` gives you a project
that Claude can start working on immediately — with real constraints, real decisions,
and real open questions documented before a single line of code is written.

---

## Try it yourself

```bash
cp commands/bootstrap-app.md ~/.claude/commands/
# In any Claude Code session:
/bootstrap-app
# Claude asks: "What app do you want to build?"
# You answer. Everything else follows.
```
