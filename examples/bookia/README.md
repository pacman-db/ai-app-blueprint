# Bookia — Real-world reference implementation

[bookia.cl](https://bookia.cl) is a SaaS platform built with this blueprint.

> A second real-world example showing the same blueprint applied to a different domain and stack choices.

---

## What it shows

Where IDfy demonstrates the blueprint with a Python/AI-heavy backend,
Bookia demonstrates it with different architectural trade-offs:
- Different product domain (no AI validation pipeline)
- Same blueprint structure (CONTEXT.md, constitution, specs, ADRs, modular design)
- Same auto-update hooks (update_docs.py after every commit and session)

---

## Blueprint elements used

| Blueprint element | Implementation | Result |
|---|---|---|
| `CONTEXT.md` + hooks | Auto-updated every commit + session end | Zero re-explaining between sessions |
| `CLAUDE.md` | Enforces quality gate before every commit | No broken code reaches main |
| `docs/constitution/` | Core principles that don't get re-opened | Claude never suggests violating them |
| `docs/specs/` | Feature specs written before code | No scope creep, no ambiguity |
| `docs/plan/` | ADRs documenting architectural decisions | Claude doesn't re-suggest ruled-out alternatives |
| Modular contracts | Clear boundaries between modules | Changes in one module don't cascade |
| CI/CD | Quality gate on every push | Caught bugs before production |

---

## Key architectural decisions (ADRs)

| ADR | Decision | Why |
|---|---|---|
| ADR-001 | _Your key decision_ | _Context and reasoning_ |
| ADR-002 | _Your key decision_ | _Context and reasoning_ |
| ADR-003 | _Your key decision_ | _Context and reasoning_ |

---

## How CONTEXT.md works in practice

Opening a session after a week away:

**Without CONTEXT.md:**
```
Developer: "So we're building a booking platform, here's how it works..."
[15 minutes of context setup]
[Claude suggests something that was already decided against]
[Wasted tokens, wasted time]
```

**With CONTEXT.md:**
```
Claude reads CONTEXT.md (auto-loaded by CLAUDE.md instruction)
→ Knows the current architecture
→ Knows the ADRs — won't re-suggest what was ruled out
→ Knows what was built last session
→ Starts contributing in under a minute
```

---

## Lessons

_Add your learnings here as the project evolves. What worked, what didn't, what surprised you._

1. **Greenfield phase:** The constitution and assumptions docs changed frequently in the first 3 weeks — that's expected. `update_docs.py` creating stubs automatically meant no friction to start the docs early.

2. **Spec discipline:** Writing specs before features felt slow at first. After the first feature that required a rewrite due to unclear requirements, the discipline became worth it.

3. **CONTEXT.md length:** Keep it under 150 lines. If it grows beyond that, prune history and rely on git log for older context.
