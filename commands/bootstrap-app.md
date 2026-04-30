---
name: bootstrap-app
description: Bootstrap a new app with Structured Vibe Coding — generates constitution, vision, ADRs, specs and living docs from a single idea. Use when starting any new project from scratch.
---

# Bootstrap — New AI App

You are the architect of this project. Follow this blueprint exactly.
The goal: a functional, stable, and scalable app from the first commit.

---

## Step 0 — Understand the idea

Before creating anything, ask the user two questions and wait for both answers before generating anything:

**Question 1:** "What app do you want to build? Describe it in one or two sentences."

**Question 2:** "What stack do you prefer?
1. SvelteKit full-stack (frontend + backend in one repo, server routes as API) — recommended for most projects
2. SvelteKit + FastAPI separate (when you need Python pipelines, ML, or async Claude SDK)
3. Other (describe it)"

Wait for both answers. Then use them to:
- Name the project (slug format, e.g. `meeting-to-tasks`)
- Fill `CONTEXT.md` with the real problem, not placeholders
- Write `docs/vision/product-vision.md` adapted to that idea
- Write `docs/constitution/constitution.md` with principles that make sense for that domain
- Write `docs/plan/v1-mvp.md` with ADRs relevant to that stack and problem
- Write `docs/clarify/assumptions.md` with real open questions for that product

Do not proceed to Step 1 until you have both answers from the user.
Do not use generic placeholders anywhere — every doc must reflect the actual project.

**Stack rules:**
- If option 1 (SvelteKit full-stack): never mention FastAPI, uvicorn, Python backend, or requirements.txt. Use SvelteKit server routes (`+server.ts`) as the API layer.
- If option 2 (SvelteKit + FastAPI): generate both repos with a clear API contract between them.
- If option 3: adapt the blueprint to the described stack.

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
├── .env.example                 # documented env vars — include at minimum:
│                                #   ANTHROPIC_API_KEY=
│                                #   DATABASE_URL=
│                                #   # Dev mode — bypasses Firebase/Google auth for local testing
│                                #   DEV_MODE=false
│                                #   DEV_USER_EMAIL=dev@local.dev
│                                #   DEV_USER_NAME=Developer
├── .gitignore
├── Makefile
│
├── docs/
│   ├── vision/
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

Generate the Makefile based on the chosen stack:

**Option 1 — SvelteKit full-stack:**
```makefile
install-dev:
	npm install

quality:
	npm run check      # svelte-check + TypeScript
	npm run lint       # eslint
	npm run test       # vitest

dev:
	npm run dev

build:
	npm run build

test:
	npm run test
```

**Option 2 — SvelteKit + FastAPI:**
```makefile
install-dev:
	pip install -r requirements.txt -r requirements-dev.txt
	cd frontend && npm install

quality:
	.venv/bin/ruff check src/ tests/ main.py --fix
	.venv/bin/ruff format src/ tests/ main.py
	.venv/bin/mypy src/
	.venv/bin/pytest tests/ -v
	cd frontend && npm run check

dev-api:
	.venv/bin/uvicorn main:app --reload

dev-frontend:
	cd frontend && npm run dev

test:
	.venv/bin/pytest tests/ -v

build:
	cd frontend && npm run build
```

**Option 3 — adapt to the described stack.**

---

## Step 4 — CI/CD (.github/workflows/ci.yml)

Generate based on the chosen stack:

**Option 1 — SvelteKit full-stack:**
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
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
      - run: npm install
      - run: npm run check
      - run: npm run lint
      - run: npm run test
```

**Option 2 — SvelteKit + FastAPI:**
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
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
          cache-dependency-path: frontend/package-lock.json
      - run: pip install -r requirements.txt -r requirements-dev.txt
      - run: ruff check src/ tests/ main.py
      - run: ruff format --check src/ tests/ main.py
      - run: mypy src/
      - run: pytest tests/ -v --tb=short
        env:
          ANTHROPIC_API_KEY: sk-ant-test-key
      - run: cd frontend && npm install && npm run check
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

## Before the final summary — ask the user

"Do you want to start the project locally now?
1. Yes — install dependencies and start the server
2. Yes + Railway — start local and configure deploy
3. Not yet"

- If **1**: run `make install-dev && make dev`
- If **2**: run `make install-dev && make dev`, then `railway login && railway init && railway up`
- If **3**: continue without starting

---

## Rules always active

1. **Before finishing any task:** `make quality` must pass
2. **Each new feature:** write spec in `docs/specs/<name>.md` **before** coding
3. **Each architectural decision:** add ADR in `docs/plan/v1-mvp.md`
4. **Each session end:** all living docs update automatically (Stop hook)
5. **Each commit:** all living docs update automatically (post-commit hook)
6. **Never commit `.env`** — only `.env.example` with descriptions
7. **No tests, no merge**
8. **After bootstrap you can keep iterating** — write "iterate and improve" so Claude reviews `docs/`, completes empty stubs, improves existing specs, and runs `scripts/update_docs.py`
9. **After each commit you make, hooks update all docs automatically** — you don't need to do it manually

---

## Final summary block — always print this at the end

```
---
✅ Bootstrap complete.

To continue, write any of these:
→ "continue with recommended" — Claude reads CONTEXT.md and knows what comes next
→ "iterate and improve the product" — Claude reviews docs/ and completes what's missing
→ "complete the docs and context files" — Claude runs scripts and fills empty stubs
→ "update the docs" — Claude runs scripts/update_docs.py manually

🔄 Docs update automatically after every commit and session (Stop hook active):
- CONTEXT.md → recent changes
- constitution.md → project status
- plan/v1-mvp.md → build progress
- specs/*.md → status of each spec
```

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
