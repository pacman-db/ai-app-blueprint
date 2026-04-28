# AI App Blueprint

Stop re-explaining your project to Claude every session.

This blueprint makes your repo self-documenting for AI —
architecture, decisions, constraints, what's done and what's next.
Claude reads it at the start of every session and starts working in 30 seconds.

## Quickstart

```bash
git clone https://github.com/pacman-db/ai-app-blueprint
cp commands/bootstrap-app.md ~/.claude/commands/

# Then in any Claude Code session:
/bootstrap-app
```

---

## What's inside

```
ai-app-blueprint/
├── README.md                    ← you are here
├── PHILOSOPHY.md                ← why this blueprint exists
│
├── blueprint/                   ← copy these to your project
│   ├── CONTEXT.md.template      ← living context (auto-updated)
│   ├── CLAUDE.md.template       ← project rules for Claude Code
│   ├── Makefile.template        ← standardized quality commands
│   ├── .env.example.template    ← env vars documented
│   └── docs/
│       ├── vision/              ← product vision (what, for whom, why)
│       ├── constitution/        ← principles (+ auto Project Status)
│       ├── plan/                ← technical decisions + ADRs (+ auto Build Progress)
│       ├── specs/               ← one spec per feature, written before code
│       │   └── _spec.template.md ← spec template with status marker
│       ├── clarify/             ← assumptions (+ auto Last Review)
│       ├── modular/             ← module map + contracts
│       └── sdd/                 ← system design document
│
├── scripts/
│   ├── update_docs.py           ← auto-updates ALL living docs after each commit
│   ├── install_hooks.sh         ← installs git hooks (run once after clone)
│   └── bootstrap.sh             ← full project bootstrapper
│
├── github/
│   ├── workflows/ci.yml         ← quality gate on every push
│   └── PULL_REQUEST_TEMPLATE.md
│
├── commands/
│   └── bootstrap-app.md        ← Claude Code global command (/bootstrap-app)
│
└── examples/
    ├── task-manager/            ← Example output: task manager app
    └── bookia/                  ← Bookia (bookia.cl)
```

---

## Quick Start

### Option A — New project
```bash
# 1. Clone this blueprint
git clone https://github.com/pacman-db/ai-app-blueprint
cd ai-app-blueprint

# 2. Bootstrap your project (English, default)
bash scripts/bootstrap.sh my-app-name

# 3. Bootstrap in Spanish
bash scripts/bootstrap.sh mi-app --lang es

# 4. Open in Claude Code and start building
# All living docs will auto-update after every session and commit
```

### Option B — Existing project
```
# In your Claude Code session:
Read this file and adapt it to our existing project:
/path/to/ai-app-blueprint/commands/bootstrap-app.md
```

### Option C — Claude Code global command
```bash
cp commands/bootstrap-app.md ~/.claude/commands/
# Then in any Claude Code session: /bootstrap-app
```

---

## Greenfield support — docs that start from zero

This is the key differentiator from SpecKit and other spec-driven approaches.

**Traditional blueprints assume you arrive with docs ready.** You define the constitution, write the specs, then code. That works for well-understood products.

**This blueprint works when you have nothing.** Start with just an idea — `update_docs.py` creates the missing docs as stubs on the first commit and fills them in as the project evolves.

```
Day 1 — first commit, no docs exist
    │
    ▼ update_docs.py runs for the first time:
    │   + constitution.md created  (3 generic principles, Phase: Exploratory)
    │   + assumptions.md created   (placeholder table)
    │   + plan/v1-mvp.md created   (empty ADR section)
    │   CONTEXT.md already exists  (you filled it in manually)

Week 2 — 15 commits in, idea still mutating
    │
    ▼ update_docs.py after every commit:
    │   ✓ constitution.md  → Phase: Exploratory (15 commits)
    │   ✓ assumptions.md   → Last Review updated
    │   ✓ plan/v1-mvp.md   → Build Progress: 4 features, 6 fixes
    │   ✓ specs/*.md       → in-progress markers on active specs

Month 2 — 50 commits, core design settled
    │
    ▼ update_docs.py:
    │   ✓ constitution.md  → Phase: Stable (50 commits)
    │   ✓ assumptions.md   → ⚠️ Not updated in 30 commits — review it
    │   ✓ Everything else  → auto-updated as usual
```

The docs don't require upfront discipline. They start minimal and grow with the product. By the time the project stabilizes, the documentation is already there.

---

## How it works: all living docs auto-update

```
You commit a feature
    │
    ▼ post-commit hook fires
    │
    ▼ scripts/update_docs.py runs:
    │   ✓ CONTEXT.md          → ## Recent Changes  (last 8 commits classified)
    │   ✓ constitution.md     → ## Project Status  (phase, feature count)
    │   ✓ assumptions.md      → ## Last Review     (staleness warning if needed)
    │   ✓ plan/v1-mvp.md      → ## Build Progress  (total commits, features shipped)
    │   ✓ specs/*.md          → <!-- status -->    (in-progress / pending)
    │
    ▼ Same happens when Claude Code session ends (Stop hook)

Next session: Claude reads the docs → full context → starts working immediately
```

**Key design principles of `update_docs.py`:**
- Never overwrites a full file — surgical section replacement only
- Creates stub docs for any missing file — greenfield ready from commit 1
- Language-aware: set `BLUEPRINT_LANG=es` in `.blueprint` config for Spanish labels
- Detects project phase: Exploratory (<20 commits) vs Stable (≥20 commits)

---

## Language support

Set language in `.blueprint` (created by `bootstrap.sh`):
```
BLUEPRINT_LANG=es   # Spanish auto-updated sections
BLUEPRINT_LANG=en   # English (default)
```

Or pass `--lang es` when bootstrapping:
```bash
bash scripts/bootstrap.sh mi-proyecto --lang es
```

**What's language-aware:** All auto-updated section headers and labels.
**What's not:** The static content of your docs — you write those in whatever language you want.

---

## Structured Vibe Coding

This blueprint formalizes what we call **Structured Vibe Coding**:

| Traditional vibecoding | Structured Vibe Coding |
|---|---|
| Fast, but context evaporates | Fast, and context persists |
| AI re-opens settled decisions | AI reads ADRs, doesn't re-open them |
| Docs written once, never updated | Docs auto-update after every commit |
| Works for greenfield, breaks as project grows | Works for greenfield and scales as it grows |
| Session 1 and session 50 feel the same | Session 50 starts with full project history |

**The cycle:**
1. Human arrives with an idea
2. Blueprint structures everything (`/bootstrap-app`)
3. Human + AI design together (constitution, specs, ADRs)
4. AI implements — guided by specs
5. AI verifies — quality gate passes
6. Docs update themselves — hooks fire after every commit and session
7. Next session: Claude reads the docs and starts in 30 seconds

---

## Suggested stack

This blueprint is **stack-agnostic** — it works with any language or framework.
The following is the recommended default for full-stack AI apps:

| Layer | Technology | Why |
|---|---|---|
| Backend | Python 3.11+ · FastAPI | Typed, async, OpenAPI auto-generated |
| Frontend | SvelteKit | Minimal bundle, Svelte 5 reactivity, full-stack capable |
| Database | PostgreSQL + SQLAlchemy | Reliable, complex queries, easy migrations |
| Auth | Firebase Auth | Google/Microsoft SSO, no custom auth plumbing |
| Payments | Stripe | Global coverage, excellent DX |
| Deploy | Railway | Managed PostgreSQL + app in one place, zero ops |
| AI | Claude API (Anthropic) | Haiku for cheap tasks, Sonnet for analysis |
| Quality | ruff · mypy · pytest | Linting + types + tests — no exceptions |

> **SvelteKit as full-stack:** For simpler apps, SvelteKit server routes (`+server.ts`) can replace a separate backend entirely — one repo, one deploy. Use a dedicated backend when you need language-specific libraries (ML, data processing, Claude SDK async pipelines) or a strict API contract.

> **Local payment providers:** Stripe works globally. If you need local currency support (LATAM, etc.), drop in your regional provider — the blueprint doesn't prescribe one.

---

## Architecture patterns

### Spec-first → then code

```
docs/specs/feature-name.md   ← write this first
    → defines: inputs, outputs, edge cases, cost constraints

Claude reads spec → implements exactly that
    → no guessing, no scope creep
```

### Modules with contracts (DDD Lite)

```
src/
├── auth/           → owns identity, sessions, api_keys
├── products/
│   ├── feature_a/  → owns its domain, exposes typed outputs
│   └── feature_b/  → evaluator + policy pattern
│       ├── evaluator.py    → core logic
│       ├── policies/       → one file per variant/entity
│       │   ├── base.py     → BasePolicy contract
│       │   ├── registry.py → ACTIVE_POLICIES
│       │   └── variant_x.py
│       └── models.py       → Pydantic input/output types
└── api/            → routes only, no business logic
```

**The rule:** `api/` calls `products/`, `products/` calls `auth/` and `models/`. No cross-product imports.

### Cost-proportional AI pipeline

```
Input received
    │
    ▼ Layer 1: Local validation          Cost: $0.00
    ▼ Layer 2: Cheap AI precheck         Cost: ~$0.001
    ▼ Layer 3: Full AI analysis          Cost: ~$0.025
```

Each layer only runs if the previous one passed. Reject bad input early, pay for AI only when needed.

### ADRs — decisions that don't get re-opened

```
docs/plan/v1-mvp.md
    ADR-001: Why X over Y (context + decision + consequences)
    ADR-002: Modular monolith over microservices (small team)
    ADR-003: Cheap precheck before expensive AI call (cost)
```

Claude reads ADRs → doesn't suggest the alternative you already ruled out.

---

## Blueprint stages

```
Product Vision     → Problem, for whom, why now
Constitution       → Immutable principles (+ auto Project Status)
Plan / ADRs        → Technical decisions and rationale (+ auto Build Progress)
Clarify            → Assumptions documented before coding (+ auto Last Review)
Modular Design     → Clear contracts between modules
Specs              → One spec per feature, before writing code (+ auto status marker)
SDD                → System design document
Development        → Code that implements specs
Quality            → Linting + types + tests (automated via CI)
GitHub / CI        → Auto-quality gate on every push
Deployment         → Reproducible, documented, automated
CONTEXT.md         → Living memory, updated after every session and commit
```

---

## Real-world examples

> Both examples are the blueprint author's own products — not a geographic limitation.
> The blueprint works with any stack, language, and market.

### [igris.cl](https://igris.cl) — Igris Validate + Hipotecario

Chilean identity document validator + mortgage evaluator.
Built entirely with this blueprint. Both products in production.

- **Validate:** 4-layer AI pipeline (format → pixels → Haiku → Sonnet). 85% of bad inputs rejected before AI.
- **Hipotecario:** Rule-based mortgage evaluator with per-bank policy pattern. 5 entities active.
- **Pattern demonstrated:** Policy pattern, cost-proportional pipeline, B2B API keys, unified payment webhook.

### Generic example — task manager

→ [See bootstrap output](examples/task-manager/)

---

### [bookia.cl](https://bookia.cl) — Bookia

SaaS platform built with the same blueprint in a different domain.

→ [Full example](examples/bookia/)

---

## Philosophy

> The best repos are self-documenting. The best AI-assisted repos are self-documenting *for AI*.

Traditional blueprints are written for human teams. This one is designed for **human + AI collaboration**:

1. **Specs before code** — Claude writes better code when it knows the expected behavior first
2. **Constitution** — prevents Claude from making decisions that violate your core principles
3. **CONTEXT.md** — eliminates the "re-explain everything" tax at the start of each session
4. **Modular contracts** — Claude knows exactly what each module does and what it can't touch
5. **ADRs** — Claude doesn't re-open decisions that were already made and documented
6. **Auto-update hooks** — all living docs stay current without manual work

→ [Read the full philosophy](PHILOSOPHY.md)

---

## Contributing

If you build something with this blueprint, open a PR with your learnings — especially edge cases, patterns that didn't work, or improvements to the templates.

---

## License

MIT — use it, fork it, adapt it.
