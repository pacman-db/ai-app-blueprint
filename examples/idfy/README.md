# IDfy — Real-world reference implementation

IDfy is a Chilean identity document validator built entirely with this blueprint.
It validates cédulas de identidad (national ID cards) using Claude Vision API.

> Every pattern in the AI App Blueprint was extracted from building IDfy in production.

---

## What it does

- Validates Chilean cédulas de identidad (front + back)
- Detects fake, altered, photocopied, or screenshot documents before spending on AI
- Mortgage calculator with per-bank policy rules
- Credit-based usage model with Reveniu payments
- B2B API with API keys + rate limiting

---

## How the 4-layer pipeline works in practice

```
User uploads photo of cédula
    │
    ▼ Layer 1: Format check                          Cost: $0.00
    │  - Not an image? Reject.
    │  - > 10MB? Reject.
    │  - 0 bytes? Reject.
    │
    ▼ Layer 2: Pillow pixel analysis                 Cost: $0.00
    │  - >95% uniform color? → screenshot/blank. Reject.
    │  - Histogram analysis detects photocopy artifacts.
    │
    ▼ Layer 3: Claude Haiku precheck                 Cost: ~$0.001
    │  - "Is this a Chilean national ID card? Answer only yes or no."
    │  - Passport photo? Dog photo? Reject.
    │
    ▼ Layer 4: Claude Sonnet full analysis           Cost: ~$0.025
       - Extracts: RUT, name, birth date, expiry, MRZ
       - Detects: tampering signs, font inconsistencies, photo substitution
       - Returns structured JSON with confidence score
```

**Result:** ~85% of bad inputs are rejected before Layer 4. Average cost per validation: ~$0.004.

---

## The policy pattern (mortgage calculator)

Each bank is one file. Adding a new bank = 1 new file + 1 registry line.

```python
# src/products/hipotecario/policies/bice.py
class BicePolicy(BasePolicy):
    # BICE-specific constants from their official policy PDF
    CF_MAX = 0.50          # 50% — more generous than average
    CF_MAX_MAYOR50 = 0.30  # drops at age >50
    CH_NUEVO_MAX = 0.30    # new debt: 30% (35% with down payment)
    CH_TOTAL_MAX = 0.45    # all debt: 45%

    def evaluate(self, data: DatosHipotecario, adjusted: DatosAjustados) -> PolicyResult:
        # BICE doesn't penalize rental income (other banks castigo 30%)
        ingreso_bice = adjusted.ingreso_total - adjusted.arriendo_castigado + data.arriendos
        div_entidad = min(div_cf, div_ch_nuevo, div_ch_total)  # triple constraint
        ...
```

```python
# src/products/hipotecario/policies/registry.py
POLITICAS_ACTIVAS = [
    FlechaPolicy(),
    BancoEstadoPolicy(),
    BancoChilePolicy(),
    BicePolicy(),          # ← add one line
    EvolucionaPolicy(),
]
```

---

## How CONTEXT.md saved this project

Real example from development. Opening a new session after 3 days away:

**Without CONTEXT.md:**
```
Developer: "Ok Claude, so we're building a document validator..."
[10 minutes of context re-establishment]
[Wrong assumptions about what was already built]
[Claude suggests refactoring something that was deliberately designed that way]
```

**With CONTEXT.md:**
```
Claude reads CONTEXT.md (auto-loaded)
→ Knows the 4-layer pipeline exists
→ Knows why Haiku precheck comes before Sonnet
→ Knows the policy pattern for the mortgage calculator
→ Knows what was done last session
→ Starts working in 30 seconds
```

**Measured difference:** First useful output in ~30 seconds vs ~15 minutes. ~70% fewer tokens on context-setting per session.

---

## Blueprint elements used

| Blueprint element | IDfy implementation | Result |
|---|---|---|
| `CONTEXT.md` + hooks | Auto-updated every commit + session end | Zero re-explaining |
| `CLAUDE.md` | Enforces ruff + mypy + pytest | No broken code reaches main |
| Modular architecture | `validators/`, `analyzers/`, `products/` | Changed pipeline without touching mortgage |
| 4-layer AI pipeline | `src/validators/` + `src/analyzers/` | 85% cost reduction vs direct Sonnet |
| Policy pattern | `policies/` one file per bank | Added BICE in 45 minutes |
| SpecKit | `specs/document-analysis.md` before coding | No scope creep |
| CI/CD | GitHub Actions: ruff + mypy + pytest | Caught 3 real bugs before prod |
| Constitution | `docs/constitution/constitution.md` | Claude never suggested storing images |

---

## Key architectural decisions (ADRs)

| ADR | Decision | Why |
|---|---|---|
| ADR-001 | No image storage | Privacy + GDPR. Validate → return result → discard. |
| ADR-002 | Haiku precheck before Sonnet | $0.001 vs $0.025. Filter early, pay late. |
| ADR-003 | Policy pattern over if/else | Adding bank X shouldn't touch bank Y's logic. |
| ADR-004 | HTTP-only cookies | Firebase token never in localStorage — XSS protection. |
| ADR-005 | SQLite dev / PostgreSQL prod | Same SQLAlchemy ORM. Zero config difference. |

---

## What didn't work (lessons)

1. **Skipping specs on "small" features** — the mortgage calculator started without a spec. It needed 3 rewrites because the edge cases (arriendos, age-based CF, triple div constraint) weren't documented upfront. Writing the spec first would have saved ~4 hours.

2. **CONTEXT.md too long** — at one point CONTEXT.md grew to 600 lines. Claude was spending tokens reading irrelevant history. Pruned to ~150 lines of current state + pointer to git log for history.

3. **Mocking too much in tests** — early tests mocked the Claude API response. When the actual API changed its response format slightly, tests passed but prod broke. Switched to real API calls with test fixtures for the happy path.
