# CONTEXT.md — Meeting to Tasks

## What is this
AI-powered SaaS that turns meeting transcripts or voice recordings into structured task lists, assigned to team members, with deadlines extracted from natural language.

## Current state
- ✅ Auth (Google SSO via Firebase)
- ✅ Transcript ingestion (text + audio upload → Whisper transcription)
- ✅ Task extraction pipeline (Haiku precheck → Sonnet extraction)
- ✅ Task CRUD + assignee management
- 🚧 Slack integration (notify assignees on task creation)
- ⬜ Calendar sync (Google Calendar deadlines)
- ⬜ Weekly digest email

## Architecture in one screen

```
Browser (SvelteKit SPA)
    │
    ▼ POST /api/transcripts         ← upload text or audio
    │
    ▼ Layer 1: Format check         $0.00  — reject non-text/audio
    ▼ Layer 2: Haiku precheck       $0.001 — "does this look like a meeting transcript?"
    ▼ Layer 3: Sonnet extraction    $0.025 — structured tasks + assignees + deadlines
    │
    ▼ PostgreSQL                    ← tasks, assignments, transcripts
    │
    ▼ Slack webhook (async)         ← notify assignees
```

## Key modules
| What I'm looking for | Where it is |
|---|---|
| Transcript ingestion | `src/products/transcripts/` |
| Task extraction logic | `src/products/tasks/extractor.py` |
| Pydantic output model | `src/products/tasks/models.py` |
| Slack notifier | `src/integrations/slack.py` |
| API routes | `src/api/routes.py` |
| Auth + sessions | `src/auth/` |
| DB models + migrations | `src/models/` |
| Frontend pages | `frontend/src/routes/` |

## Quality rules
```bash
make quality   # ruff + mypy + pytest — must pass before any commit
```

## Key decisions
| Decision | Why |
|---|---|
| Haiku precheck before Sonnet | $0.001 vs $0.025 — reject garbage early |
| Extract tasks as JSON schema | Structured output, typed, validated by Pydantic |
| Whisper for audio → text | Runs server-side, no client dependency |
| HTTP-only cookie auth | Firebase token never in localStorage |
| Tasks owned by workspace, not user | Team context: tasks survive member departure |

## What NOT to do
- ❌ Never store raw audio — transcribe immediately, discard the file
- ❌ Never call Sonnet without passing Haiku precheck first
- ❌ Never expose workspace tasks across workspace boundaries
- ❌ Never skip the quality gate (`make quality`) before committing

## Recent Changes
_Auto-updated by scripts/update_docs.py after every commit and session end_

<!-- recent-changes-start -->
- feat: transcript ingestion + Haiku precheck (2 days ago)
- feat: Sonnet task extraction with structured JSON output (2 days ago)
- feat: task CRUD API + frontend task list (1 day ago)
- fix: deadline parser handles relative dates ("next Friday") (1 day ago)
- feat: assignee matching by name fuzzy search (today)
<!-- recent-changes-end -->
