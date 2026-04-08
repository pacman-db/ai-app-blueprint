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
│   ├── .editorconfig
│   └── docs/
│       ├── estado-del-arte/product-vision.md.template
│       ├── constitution/constitution.md.template
│       ├── plan/v1-mvp.md.template
│       ├── clarify/assumptions.md.template
│       ├── modular/modules.md.template
│       └── sdd/arquitectura.md.template
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

---

## Quick Start

### Option A — New project
```bash
# 1. Clone this blueprint
git clone https://github.com/christianjcgbot/ai-app-blueprint
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
/Users/christian/.claude/commands/bootstrap-app.md
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
    → CONTEXT.md updated with what changed and why

Session 2: Claude reads CONTEXT.md
    → knows everything from session 1
    → zero tokens re-explaining
    → starts working immediately

Session N: CONTEXT.md has full project history
    → new developer (human or AI) onboards in minutes
```

**Result:** Each session costs ~70% fewer tokens on context-setting.

---

## Stack (default)

| Layer | Technology | Why |
|---|---|---|
| Backend | Python 3.11 + FastAPI | Typed, async, OpenAPI auto-generated |
| Frontend | SvelteKit | Minimal bundle, Svelte 5 reactivity |
| Database | PostgreSQL + SQLAlchemy | Reliable, great for complex queries |
| Auth | Firebase Auth | Google/Microsoft SSO, no custom auth |
| Payments | Reveniu (CLP) / Stripe | Native currency support |
| Deploy | Railway | Managed PostgreSQL + app, zero ops |
| AI | Claude API (Anthropic) | Haiku for cheap tasks, Sonnet for analysis |
| Quality | ruff + mypy + pytest | No exceptions |

---

## Blueprint Stages

```
Estado del Arte    → What problem, for whom, why now
Constitution       → Immutable principles (never violate these)
Plan / ADRs        → Technical decisions and why they were made
Clarify            → Assumptions documented before coding
Modular Design     → Clear contracts between modules
Specs              → One spec per feature, before writing code
SDD                → System design document
Development        → Code that implements specs
Quality            → ruff + mypy + pytest (automated via CI)
Tests              → Unit + integration, no mocks on critical paths
GitHub / CI        → Auto-quality gate on every push
Deployment         → Reproducible, documented, automated
CONTEXT.md         → Living memory updated after every session
```

---

## Why this works for AI-assisted development

Traditional blueprints are written for human teams. This one is designed for **human + AI collaboration**:

1. **Specs before code** — Claude writes better code when it knows the expected behavior first
2. **Constitution** — prevents Claude from making decisions that violate your core principles
3. **CONTEXT.md** — eliminates the "re-explain everything" tax at the start of each session
4. **Modular contracts** — Claude knows exactly what each module does and what it can't touch
5. **ADRs** — Claude doesn't re-open decisions that were already made and documented

---

## Integrations

- **GitHub Actions** — CI runs automatically on every push/PR
- **SpecKit pattern** — spec-driven development, write the spec before the code
- **Claude Code hooks** — Stop hook updates context when session ends
- **Git hooks** — post-commit updates context after every commit

---

## Contributing

This blueprint is extracted from [IDfy](https://idfy.cl) — a real production app built entirely with this method. If you build something with it, open a PR with your learnings.

---

## License

MIT — use it, fork it, adapt it.
