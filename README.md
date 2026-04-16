# AI App Blueprint v2

> Build functional, stable, and scalable apps with Claude Code — without losing context between sessions.

**The problem:** Every new Claude Code session starts from zero. You spend the first 20% of your tokens re-explaining what the project does, what decisions were made, what not to touch. That's wasted money and time.

**The solution:** A blueprint that makes your entire repo self-documenting for AI. Claude reads `CONTEXT.md` and all living docs at the start of every session and knows everything — architecture, decisions, constraints, what's done and what's next.

**The concept:** [Structured Vibe Coding](#structured-vibe-coding) — the speed and freedom of vibecoding, with structure that builds and documents itself.

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
│       ├── estado-del-arte/     ← product vision (what, for whom, why)
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
    ├── idfy/                    ← IDfy Validate + Hipotecario (idfy.cl)
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
- Creates stub docs automatically for greenfield projects (no doc = no problem)
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
| Payments | Stripe · Reveniu (LATAM) | Stripe for global, Reveniu for local currency |
| Deploy | Railway | Managed PostgreSQL + app in one place, zero ops |
| AI | Claude API (Anthropic) | Haiku for cheap tasks, Sonnet for analysis |
| Quality | ruff · mypy · pytest | Linting + types + tests — no exceptions |

> **SvelteKit as full-stack:** For simpler apps, SvelteKit server routes (`+server.ts`) can replace a separate backend entirely — one repo, one deploy. Use a dedicated backend when you need language-specific libraries (ML, data processing, Claude SDK async pipelines) or a strict API contract.

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
Estado del Arte    → Problem, for whom, why now
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

### [idfy.cl](https://idfy.cl) — IDfy Validate + Hipotecario

Chilean identity document validator + mortgage evaluator.
Built entirely with this blueprint. Both products in production.

- **Validate:** 4-layer AI pipeline (format → pixels → Haiku → Sonnet). 85% of bad inputs rejected before AI.
- **Hipotecario:** Rule-based mortgage evaluator with per-bank policy pattern. 5 entities active.
- **Pattern demonstrated:** Policy pattern, cost-proportional pipeline, B2B API keys, unified payment webhook.

→ [Full example](examples/idfy/)

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
