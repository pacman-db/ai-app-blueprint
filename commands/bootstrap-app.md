# Bootstrap — New AI App

You are the architect of this project. Follow this blueprint exactly.
The goal: a functional, stable, and scalable app from the first commit.

---

## Default stack

| Layer | Technology | Notes |
|---|---|---|
| Backend | Python 3.11+ · FastAPI | Strict typing, async, auto OpenAPI |
| Frontend | SvelteKit | SPA, minimal bundle, Svelte 5 `$state()` |
| Database | PostgreSQL (prod) / SQLite (dev) · SQLAlchemy | ORM + migrations |
| Auth | Firebase Auth (Google + Microsoft) | HTTP-only cookie |
| Payments | Stripe (global) · Reveniu (LATAM) | Choose by market |
| Deploy | Railway | Managed PostgreSQL + app in one place |
| AI | Claude API (Anthropic) | Haiku for cheap tasks, Sonnet for analysis |
| Quality | ruff · mypy · pytest | No exceptions |

> **Stack-agnostic option:** If the project doesn't use this stack, replace what doesn't apply.
> The blueprint structure works with any language or framework.

---

## Step 1 — Project structure

Create exactly this structure before writing any code:

```
<project-name>/
├── CLAUDE.md                    # Claude Code rules + context pointer
├── CONTEXT.md                   # living AI context (auto-updated)
├── .blueprint                   # config: BLUEPRINT_LANG, PROJECT_NAME
├── .env.example                 # documented env vars (never .env in git)
├── .gitignore
├── Makefile
│
├── docs/
│   ├── estado-del-arte/
│   │   └── product-vision.md    # what, for whom, why now
│   ├── constitution/
│   │   └── constitution.md      # immutable principles (+ auto Project Status)
│   ├── plan/
│   │   └── v1-mvp.md            # technical plan + ADRs (+ auto Build Progress)
│   ├── clarify/
│   │   └── assumptions.md       # assumptions + open questions (+ auto Last Review)
│   ├── modular/
│   │   └── modules.md           # module contracts
│   ├── sdd/
│   │   └── arquitectura.md      # system design document
│   └── specs/                   # one spec per feature
│       └── _spec.template.md    # use this as starting point
│
├── scripts/
│   ├── update_docs.py           # auto-updates all living docs
│   └── install_hooks.sh         # installs git hooks
│
├── .github/
│   ├── workflows/
│   │   └── ci.yml               # quality gate on every push
│   └── PULL_REQUEST_TEMPLATE.md
│
├── src/                         # source code
├── tests/
│   └── conftest.py
│
└── .claude/
    ├── settings.json            # Stop hook → update_docs.py
    └── commands/                # project slash commands
```

---

## Step 2 — Auto-context hooks (always install both)

### A — Claude Code Stop Hook (.claude/settings.json)
```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "python3 scripts/update_docs.py 2>/dev/null || true",
        "statusMessage": "Updating living docs..."
      }]
    }]
  }
}
```

### B — Git post-commit hook
```bash
bash scripts/install_hooks.sh
```

`scripts/update_docs.py` runs after every commit AND every session end, updating:
- `CONTEXT.md` → `## Recent Changes`
- `docs/constitution/constitution.md` → `## Project Status`
- `docs/clarify/assumptions.md` → `## Last Review`
- `docs/plan/v1-mvp.md` → `## Build Progress`
- `docs/specs/*.md` → `<!-- status: ... -->` marker

---

## Step 3 — Quality gate (Makefile)

```makefile
quality:
	.venv/bin/ruff check src/ tests/ main.py --fix
	.venv/bin/ruff format src/ tests/ main.py
	.venv/bin/mypy src/
	.venv/bin/pytest tests/ -v

dev:
	.venv/bin/uvicorn main:app --reload

test:
	.venv/bin/pytest tests/ -v

build:
	cd frontend && npm run build
```

---

## Step 4 — CI/CD (.github/workflows/ci.yml)

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: "pip"
      - run: pip install -r requirements.txt -r requirements-dev.txt
      - run: ruff check src/ tests/ main.py
      - run: ruff format --check src/ tests/ main.py
      - run: mypy src/
      - run: pytest tests/ -v --tb=short
        env:
          ANTHROPIC_API_KEY: sk-ant-test-key
```

---

## Step 5 — Fill in CONTEXT.md

Complete before starting to code:

```markdown
# CONTEXT.md — <Project Name>

## What is this
<One line: what it does and for whom>

## Current state
- 🚧 Setup

## Architecture in one screen
<ASCII diagram>

## Key modules
| What I'm looking for | Where it is |
|---|---|

## Quality rules
make quality  # linting + types + tests

## Key decisions
| Decision | Why |
|---|---|

## What NOT to do
- ❌

## Recent Changes
_Auto-updated by scripts/update_docs.py_
```

---

## Rules always active

1. **Before finishing any task:** `make quality` must pass
2. **Each new feature:** write spec in `docs/specs/<name>.md` **before** coding
3. **Each architectural decision:** add ADR in `docs/plan/v1-mvp.md`
4. **Each session end:** all living docs update automatically (Stop hook)
5. **Each commit:** all living docs update automatically (post-commit hook)
6. **Never commit `.env`** — only `.env.example` with descriptions
7. **No tests, no merge**

---

## Stack variants

### Backend API only (no frontend)
- Remove `frontend/`
- Add `contracts/openapi.yml` from day 1

### Frontend only (no separate backend)
- Use SvelteKit server routes (`+server.ts`) as the backend
- One repo, one deploy

### With AI (recommended pipeline)
```
Input
  ▼ Layer 1: Local validation      Cost: $0.00
  ▼ Layer 2: Cheap AI precheck     Cost: ~$0.001 (Haiku)
  ▼ Layer 3: Full AI analysis      Cost: ~$0.025 (Sonnet)
```
Never call the expensive model without passing through the cheap one first.
