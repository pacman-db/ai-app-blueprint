# Philosophy — Why this blueprint exists

## The problem with vibecoding

Vibecoding — building apps by talking to an AI — is real and it works. But it has a critical flaw:

**Every session starts from zero.**

You open Claude Code, start a new conversation, and the first thing you do is spend 10-15 minutes explaining:
- What the project does
- What decisions were made and why
- What was built last session
- What NOT to touch
- What's next

That's not building. That's paying to re-explain your own project to your own tool. At $3-15 per million tokens, that's expensive. At 30-60 minutes per week, that's a lot of time.

---

## The insight

The best developers don't carry everything in their heads. They write things down — architecture docs, ADRs, specs — so that anyone (including their future self) can understand the system without asking.

**The same principle applies to AI-assisted development, but more strictly.**

An AI doesn't have a memory that persists between sessions. It needs to reconstruct context from what it can read. If your repo is well-documented, the AI is productive immediately. If it's not, you pay the context tax every single session.

---

## What this blueprint does

It makes your repo **self-documenting for AI**. Not just for humans — for AI.

The difference:
- Human docs explain *what* the system does
- AI-optimized docs also explain *what decisions were made*, *why*, and *what not to do*

That last part is crucial. An AI that doesn't know what decisions were already made will re-open them. An AI that doesn't know what not to touch will touch it. An AI that doesn't know why something was built a certain way will refactor it into something worse.

---

## The CONTEXT.md idea

Every project has a `CONTEXT.md` — a living document that captures:
- Current state of the project
- Key decisions and why they were made
- What's done, what's in progress, what's next
- What NOT to do (and why)
- Where to find things

This file is auto-updated after every session (via Claude Code Stop hook) and after every commit (via git post-commit hook). It's never stale because it updates itself.

The result: Claude reads the file and starts working immediately — no re-explaining, no wrong assumptions, no re-opening closed decisions.

---

## Spec-driven development (SpecKit)

The other half of the blueprint is writing specs before code.

Not because it's "proper software engineering" — because it makes the AI write better code.

When Claude has a spec that says:
> "The validation pipeline has 4 layers. Layer 1 is format/size (no cost). Layer 2 is Pillow pixel analysis (no cost). Layer 3 is Claude Haiku precheck (~$0.001). Layer 4 is Claude Sonnet full analysis (~$0.025). Each layer only runs if the previous one passed."

...it writes code that implements exactly that. Without the spec, it writes whatever seems reasonable, which may or may not match what you had in mind.

Specs are cheap to write (10-20 minutes). Fixing code that doesn't match what you meant is expensive.

---

## Modular architecture

Modules with clear contracts mean Claude knows exactly what it can and can't change.

When a module has a defined interface:
```python
# evaluator.py returns DatosAjustados
# policy.evaluar(datos, ajustado) returns PolicyResult
```

Claude can change the internals of any module without breaking others. Without clear contracts, every change is a potential breakage.

---

## The quality gate

`make quality` runs ruff + mypy + pytest before every commit. This isn't optional.

The reason: Claude Code writes code fast. Sometimes too fast. The quality gate catches:
- Type errors that would surface in production
- Style inconsistencies that accumulate into unreadable code
- Regressions in existing functionality

With CI running the same checks on GitHub, nothing broken ever reaches main.

---

## Vibecoding + Blueprint = The future

The best development workflow right now is:
1. Human defines the problem (Estado del Arte)
2. Human sets the principles (Constitution)
3. Human and AI design together (Plan, Specs, SDD)
4. AI implements (Development)
5. AI verifies (Tests, Quality)
6. Everything is documented automatically (CONTEXT.md, hooks)
7. Next session starts with full context

This is not replacing developers. It's removing the parts that slow developers down — boilerplate, repetitive implementation, context-switching overhead — while keeping the parts that require human judgment: defining problems, setting constraints, making architectural decisions.

The developer who masters this workflow builds 5x faster without sacrificing quality or stability.
