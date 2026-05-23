---
name: bootstrap-app
description: Bootstrap a new app from a single idea — modular architecture, spec-driven development, living docs with auto-harness, and quality design. Not a monolith. Everything updates automatically after every commit and session.
---

# Bootstrap — New AI App

> **Working agreement** — Before doing anything, read `WORKING-AGREEMENT.md` at the repo root. The rule applies here too: analyze → summarize → propose → wait for OK → write the spec → only then act. If `WORKING-AGREEMENT.md` doesn't exist yet, create it from this blueprint's template.

You are the architect of this project. Follow this blueprint exactly.
The goal: a functional, stable, and scalable app from the first commit.

---

## Step 0 — Understand the idea

Ask the user ONE question and wait for the answer before generating anything:

---
**Cuéntame tu idea: ¿qué hace, para quién es y qué puede hacer un usuario en ella?**

---

Wait for the answer. Do NOT ask follow-up questions. If the answer is too vague to infer the main features, ask ONE specific clarification before proceeding. Do NOT proceed until you have enough to fill every doc with real content.

Use the answers to:
- Name the project (slug format, e.g. `meeting-to-tasks`)
- Fill `CONTEXT.md` with the real problem, not placeholders
- Write `docs/vision/product-vision.md` adapted to that idea
- Write `docs/constitution/constitution.md` with principles for that domain
- Write `docs/plan/v1-mvp.md` with ADRs relevant to the stack and problem
- Write `docs/clarify/assumptions.md` with real open questions for that product
- Write `docs/modular/modules.md` with the module breakdown inferred from the features
- Write `docs/sdd/arquitectura.md` with the data flow and system design

Do not use generic placeholders anywhere — every doc must reflect the actual project.

**Stack decision — automatic, never ask the user:**

Analyze the idea and decide silently:
- If the idea involves AI/LLM calls, ML, Python libraries, data pipelines, or heavy async processing → **SvelteKit + FastAPI**
- Everything else (CRUDs, marketplaces, dashboards, SaaS, search, booking) → **SvelteKit fullstack**

Announce the chosen stack once with a one-line reason, then offer a correction window:

> "Usaré **[stack]** porque [razón en una línea]. ¿Quieres cambiar algo del stack o seguimos?"

If the user confirms or says nothing → proceed to Step 1.
If the user specifies a different stack → adapt and proceed.

**Stack rules:**
- SvelteKit fullstack: use server routes (`+server.ts`) as the API layer. Never mention FastAPI, Python backend, or requirements.txt.
- SvelteKit + FastAPI: generate both with a clear API contract between them.
- User-specified stack: adapt the blueprint structure to it.

---

## Default stack

| Layer | Technology | Notes |
|---|---|---|
| Backend | Python 3.11+ · FastAPI | Strict typing, async, auto OpenAPI |
| Frontend | SvelteKit | SPA, minimal bundle, Svelte 5 `$state()` |
| Database | PostgreSQL (prod) / SQLite (dev) · SQLAlchemy | ORM + migrations |
| Auth | Firebase Auth (Google + Microsoft) | HTTP-only cookie |
| Payments | Stripe | Only if idea requires it |
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

## Step 6 — Generate initial specs

Generate one spec file per main feature inferred from the user's answer.
Use the template at `docs/specs/_spec.template.md` as base.

**Rules:**
- One file per feature: `docs/specs/<feature-slug>.md`
- Fill every section with real content — no placeholders
- Include real behavior steps, real edge cases, real test scenarios for that domain
- Mark each spec with `<!-- status: pending -->` at the top

These specs are the contract. No code is written without an approved spec.

---

## Step 7 — Ask about implementation

Print a short summary of the specs generated, then ask:

"¿Quieres que implemente las features ahora?
1. Sí — implementa todas las features en orden lógico
2. No — me encargo yo manualmente"

- If **1**: proceed to Step 8
- If **2**: skip to Step 9

---

## Step 8 — Implement features (spec-driven, modular, with quality design)

Implement each feature one by one following this process for each:

1. Read the spec from `docs/specs/<feature>.md`
2. Announce what you're about to build and wait for OK
3. Implement following these mandatory rules:

**Modular architecture — non-negotiable:**
- Each feature lives in its own module with clear inputs/outputs
- No business logic in UI components — goes in `+page.server.ts` or service layer
- Modules communicate through typed contracts, never through internals
- This is NOT a monolith — every module is independently testable and replaceable

**Design quality — read the skills before writing any UI:**
- Before any UI component → read `skills/senior-frontend.md`
- Before any user flow or layout → read `skills/senior-design.md`
- Apply: semantic HTML, accessibility, mobile-first, skeleton loaders, proper empty states
- One primary action per screen, clear visual hierarchy, no generic AI aesthetics
- Tap targets 44×44px minimum, inputs with labels, keyboard navigable

**Harness & context engineering — always active:**
- After each feature commit, `update_docs.py` runs automatically (git hook)
- CONTEXT.md stays current — the AI never loses context between sessions
- Specs get their status marker updated automatically (`<!-- status: in-progress -->`)

4. Run `make quality` after each feature — fix any errors before moving to the next
5. Commit with a descriptive message

---

## Step 9 — Final summary and launch

**Print this after all features are implemented (or if user chose to implement manually):**

```
✅ Bootstrap completo — <project-name>
📁 <ruta del proyecto>

Lo que se construyó:
  <lista de features implementadas con una línea cada una>

Arquitectura:
  - Modular — cada feature en su propio módulo con contratos tipados
  - Harness activo — docs se actualizan solos tras cada commit y sesión
  - Spec-driven — todo el código tiene su spec en docs/specs/
  - Diseño de calidad — senior-frontend + senior-design aplicados

Stack: <stack> — <razón>
🔄 Docs vivos: CONTEXT.md · constitution.md · plan/v1-mvp.md · specs/*.md
🔗 Git hooks: pre-commit (avisa si falta spec) · post-commit (actualiza docs)
```

**Then ask — wait for the answer:**

"¿Levantamos el proyecto localmente ahora? (`make install-dev && make dev`)"

- If **yes**: run `make install-dev && make dev` and confirm it started
- If **no**: print the commands to run manually

**After answering:**

```
Listo. Para agregar una nueva feature:
→ Escribe "implementar <feature>" — el AI crea la spec, propone el plan y espera tu OK.
```

---

## Rules always active

1. **Spec before code** — always. No exceptions, not even in long sessions
2. **Modular architecture** — each module owns its domain, communicates through typed contracts
3. **Design quality** — read senior-frontend.md and senior-design.md before any UI
4. **`make quality` must pass** before every commit
5. **Living docs** — update automatically after every commit and session (hooks)
6. **Never commit `.env`** — only `.env.example`
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
