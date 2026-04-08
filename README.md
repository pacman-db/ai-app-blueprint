# AI App Blueprint

> Build functional, stable and scalable AI apps with Claude Code — without losing context between sessions.

**The problem:** Every new Claude Code session starts from zero. You spend the first 20% of your tokens re-explaining what the project does, what decisions were made, what not to touch. That's wasted money and time.

**The solution:** A blueprint that makes your repo self-documenting for AI. Claude reads `CONTEXT.md` at the start of every session and knows everything — architecture, decisions, constraints, what's done and what's next.

---

## What's inside

```
ai-app-blueprint/
├── README.md                    ← you are here
├── PHILOSOPHY.md                ← why this blueprint exists
│
├── blueprint/                   ← copy these to your project
│   ├── CONTEXT.md.template      ← living context for AI (auto-updated)
│   ├── CLAUDE.md.template       ← project rules for Claude Code
│   ├── Makefile.template        ← standardized commands
│   ├── .env.example.template    ← env vars documented
│   └── docs/
│       ├── estado-del-arte/     ← product vision (what, for whom, why)
│       ├── constitution/        ← immutable principles
│       ├── plan/                ← technical decisions + ADRs
│       ├── specs/               ← one spec per feature, written before code
│       ├── clarify/             ← assumptions documented upfront
│       ├── modular/             ← module map + contracts
│       └── sdd/                 ← system design document
│
├── scripts/
│   ├── update_context.py        ← auto-updates CONTEXT.md after each commit
│   ├── install_hooks.sh         ← installs git hooks (run once after clone)
│   └── bootstrap.sh             ← full project bootstrapper
│
├── github/
│   ├── workflows/ci.yml         ← ruff + mypy + pytest on every push
│   └── PULL_REQUEST_TEMPLATE.md
│
├── commands/
│   └── bootstrap-app.md        ← Claude Code global command (/bootstrap-app)
│
└── examples/
    └── idfy/                    ← real-world reference implementation
```

> **`docs/specs/`** is where spec-driven development lives. One markdown file per feature, written *before* coding. Claude implements the spec; the spec is the source of truth. See [SpecKit pattern](#speckit--spec-driven-development).

---

## Quick Start

### Option A — New project
```bash
# 1. Clone this blueprint
git clone https://github.com/pacman-db/ai-app-blueprint
cd ai-app-blueprint

# 2. Bootstrap your project
bash scripts/bootstrap.sh my-app-name

# 3. Install auto-context hooks
cd my-app-name
bash scripts/install_hooks.sh

# 4. Open in Claude Code and start building
# CONTEXT.md will auto-update after every session and commit
```

### Option B — Existing project
```
# In your Claude Code session, tell Claude:
Read this file and adapt it to our existing project:
/path/to/ai-app-blueprint/commands/bootstrap-app.md
```

### Option C — Claude Code global command
```bash
# Copy the global command
cp commands/bootstrap-app.md ~/.claude/commands/

# Then in any Claude Code session:
/bootstrap-app
```

---

## The Core Idea: CONTEXT.md as AI Memory

```
Session 1: Claude builds feature X
    → commit → post-commit hook fires
    → update_context.py runs:
         reads last 8 commits
         classifies by type (feat/fix/docs/infra)
         updates "## Últimos cambios" section
         lists top modified files
    → CONTEXT.md updated in seconds

Session 2: Claude reads CONTEXT.md (first thing)
    → knows everything from session 1
    → zero tokens re-explaining
    → starts working immediately

Session N: CONTEXT.md has full project history
    → new developer (human or AI) onboards in minutes
```

**`update_context.py` never overwrites the full file** — it surgically replaces only the `## Últimos cambios` section using regex. Your architecture docs, decisions, and module map stay intact.

**Result:** Each session costs ~70% fewer tokens on context-setting.

---

## Stack (default)

| Layer | Technology | Why |
|---|---|---|
| Backend | Python 3.11 + FastAPI | Typed, async, OpenAPI auto-generated |
| Frontend | SvelteKit | Minimal bundle, Svelte 5 reactivity, full-stack capable |
| Database | PostgreSQL + SQLAlchemy | Reliable, great for complex queries |
| Auth | Firebase Auth | Google/Microsoft SSO, no custom auth |
| Payments | Reveniu (CLP) / Stripe | Native currency support |
| Deploy | Railway | Managed PostgreSQL + app, zero ops |
| AI | Claude API (Anthropic) | Haiku for cheap tasks, Sonnet for analysis |
| Quality | ruff + mypy + pytest | No exceptions |

> **SvelteKit as full-stack:** For simple apps (no complex background jobs), SvelteKit server routes (`+server.ts`) can replace FastAPI entirely — one repo, one deploy. Use FastAPI when you need Python-specific libraries (ML, data processing, Claude SDK async pipelines).

---

## Architecture & Development Patterns

### DDD Lite — modules with contracts

Each module owns its domain. Modules communicate through Pydantic models, not internal imports:

```
src/
├── auth/       → owns users, sessions, api_keys
├── products/
│   ├── validator/  → owns validation pipeline
│   └── hipotecario/ → owns mortgage calculation
│       ├── evaluator.py    → core logic
│       ├── policies/       → one file per bank/entity
│       │   ├── base.py     → BasePolicy contract
│       │   ├── registry.py → ACTIVE_POLICIES list
│       │   └── banco_x.py  → BancoXPolicy(BasePolicy)
│       └── models.py       → Pydantic input/output
└── api/        → FastAPI routes only, no business logic
```

**The rule:** `api/` calls `products/`, `products/` calls `auth/` and `models/`. No cross-product imports.

### Spec-first → then code

```
docs/specs/feature-name.md   ← write this first
    → defines: inputs, outputs, edge cases, cost constraints

Claude reads spec → implements exactly that
    → no guessing, no scope creep, no "I thought you meant..."
```

### ADRs — decisions that don't get re-opened

```
docs/plan/v1-mvp.md
    ADR-001: FastAPI over Flask (typing, async, auto-OpenAPI)
    ADR-002: Modular monolith over microservices (small team)
    ADR-003: Haiku precheck before Sonnet (cost proportional to risk)
```

Claude reads ADRs → doesn't suggest Flask, doesn't propose microservices, doesn't skip the precheck.

### 4-layer AI pipeline (cost-proportional)

```
Input received
    │
    ▼ Layer 1: Format/size validation       Cost: $0.00
    ▼ Layer 2: Local pixel analysis (Pillow) Cost: $0.00
    ▼ Layer 3: Claude Haiku precheck        Cost: ~$0.001
    ▼ Layer 4: Claude Sonnet full analysis  Cost: ~$0.025
```

**Each layer only runs if the previous one passed.** Reject obvious bad inputs early, pay for AI only when needed.

### Error handling — 3 levels

```python
# Level 1: Validation errors (client mistake) → 400
raise HTTPException(status_code=400, detail="Invalid format")

# Level 2: Business rule errors (expected failure) → structured response
return PolicyResult(aprobado=False, razon="Income below minimum")

# Level 3: Unexpected errors → 500 + log
logger.exception("Unexpected error in pipeline")
raise HTTPException(status_code=500, detail="Internal error")
```

Never let Level 3 silently swallow Level 1 or 2.

---

## SpecKit — Spec-Driven Development

**Write the spec before you write the code.**

```markdown
# specs/document-validation.md

## Input
- Image file: JPEG/PNG/HEIC, max 10MB
- Accepted document types: cédula_frontal, cédula_reverso, pasaporte

## Validation layers
1. Format check: reject if not image, >10MB, or 0 bytes
2. Pixel analysis: reject if >95% uniform color (screenshot/blank)
3. Haiku precheck: "Is this a Chilean identity document? yes/no"
4. Sonnet analysis: full structured extraction

## Output
{ "valid": bool, "confidence": float, "reason": str, "extracted": {...} }

## Edge cases
- Photocopies: usually pass layer 1-2, Haiku rejects ~90%
- Screenshots: rejected at layer 2 (uniform background)
- Expired documents: valid=true, flagged in extracted.expired
```

The spec is the contract. Claude implements it. If the implementation diverges from the spec, the spec wins.

---

## Claude Code Skills (recommended)

Install these global skills to get senior-level code review on every task:

```bash
# Copy to your global Claude Code commands directory
cp commands/bootstrap-app.md ~/.claude/commands/

# Or create your own:
# ~/.claude/commands/senior-backend.md  → backend architecture review
# ~/.claude/commands/senior-frontend.md → frontend/UX review
```

**How to use in a session:**
```
/senior-backend   → reviews API design, DB schema, security, performance
/senior-frontend  → reviews component structure, UX patterns, accessibility
/bootstrap-app    → sets up full project structure from scratch
```

Skills give Claude a defined persona with specific expertise. A "senior backend" skill makes Claude think about edge cases, security, and performance — not just "make it work."

---

## Blueprint Stages

```
Estado del Arte    → What problem, for whom, why now
Constitution       → Immutable principles (never violate these)
Plan / ADRs        → Technical decisions and why they were made
Clarify            → Assumptions documented before coding
Modular Design     → Clear contracts between modules
Specs              → One spec per feature, before writing code  ← SpecKit
SDD                → System design document
Development        → Code that implements specs
Quality            → ruff + mypy + pytest (automated via CI)
Tests              → Unit + integration, no mocks on critical paths
GitHub / CI        → Auto-quality gate on every push
Deployment         → Reproducible, documented, automated
CONTEXT.md         → Living memory updated after every session
```

---

## Philosophy

> The developer who masters this workflow builds 5x faster without sacrificing quality or stability.

Traditional blueprints are written for human teams. This one is designed for **human + AI collaboration**:

1. **Specs before code** — Claude writes better code when it knows the expected behavior first
2. **Constitution** — prevents Claude from making decisions that violate your core principles
3. **CONTEXT.md** — eliminates the "re-explain everything" tax at the start of each session
4. **Modular contracts** — Claude knows exactly what each module does and what it can't touch
5. **ADRs** — Claude doesn't re-open decisions that were already made and documented

Vibecoding works. This blueprint makes it **reliable.**

→ [Read the full philosophy](PHILOSOPHY.md)

---

## Real-world example

[examples/idfy/](examples/idfy/) — IDfy is a Chilean identity document validator built entirely with this blueprint. It processes real documents in production, uses the 4-layer AI pipeline, policy pattern, and CONTEXT.md auto-update. Every pattern in this blueprint was extracted from that experience.

---

## Integrations

- **GitHub Actions** — CI runs automatically on every push/PR
- **SpecKit pattern** — spec-driven development: write the spec (`docs/specs/`) before the code
- **Claude Code hooks** — Stop hook updates context when session ends
- **Git hooks** — post-commit updates context after every commit
- **Railway** — push-to-deploy with managed PostgreSQL

---

## Contributing

If you build something with this blueprint, open a PR with your learnings — especially edge cases, patterns that didn't work, or improvements to the templates.

---

## License

MIT — use it, fork it, adapt it.
