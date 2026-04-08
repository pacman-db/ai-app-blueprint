# IDfy — Real-world example

IDfy is a Chilean identity document validator built on this blueprint.
It validates cédulas de identidad (national ID cards) using Claude Vision API.

## What it does

- Detects fake, altered, photocopied, or screenshot documents
- 4-layer AI pipeline (format → pixel analysis → Haiku precheck → Sonnet full analysis)
- FastAPI backend + SvelteKit frontend
- Firebase Auth (Google + Microsoft)
- Credit-based usage model with Reveniu payments

## Blueprint elements used

| Blueprint element | IDfy implementation |
|---|---|
| `CONTEXT.md` | Auto-updated after every commit and Claude session |
| `CLAUDE.md` | Enforces ruff + mypy + pytest before finishing any task |
| Modular architecture | `src/validators/`, `src/analyzers/`, `src/api/` |
| 4-layer AI pipeline | `src/validators/` (layers 1-2) + `src/analyzers/` (layers 3-4) |
| Policy pattern | `src/products/hipotecario/policies/` — one file per bank |
| Stop hook | Updates CONTEXT.md when Claude session ends |
| Post-commit hook | Updates CONTEXT.md after every git commit |
| CI/CD | GitHub Actions: ruff + mypy + pytest on every push |
| Railway deploy | Single `git push` deploys frontend + backend |

## Key decisions

- **No image storage**: validated documents are never saved — only the result
- **Haiku precheck**: saves ~95% of Sonnet costs by rejecting obvious non-documents early
- **Pillow local analysis**: detects screenshots by pixel uniformity before any API call
- **HTTP-only cookies**: Firebase token stored server-side, never in localStorage

## Architecture

```
Browser
  │
  ▼ SvelteKit SPA (Firebase Auth)
  │
  ▼ FastAPI
  ├── /api/validate  → 4-layer pipeline → result
  ├── /api/auth      → Firebase token → HTTP-only cookie
  └── /api/payment   → Reveniu webhook → credit user
  │
  ▼ PostgreSQL (Railway)
```

## Lessons learned

1. **CONTEXT.md saves tokens** — starting a session without re-explaining the project saves ~2000 tokens per session
2. **Policy pattern scales well** — adding a new bank = 1 new file + 1 registry line
3. **Haiku precheck is essential** — without it, every bad photo costs ~$0.025
4. **ruff + mypy as gates** — caught real bugs before they reached prod (type mismatches in Pydantic models)
