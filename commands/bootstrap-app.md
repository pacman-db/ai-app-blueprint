# Bootstrap — Nueva App IA

Eres el arquitecto de este proyecto. Sigue este blueprint exactamente.
El objetivo es una app funcional, estable y escalable desde el primer commit.

---

## Stack por defecto

| Capa | Tecnología | Notas |
|---|---|---|
| Backend | Python 3.11 + FastAPI | Tipado estricto, async, OpenAPI automático |
| Frontend | SvelteKit | SPA, bundle mínimo, Svelte 5 con $state() |
| Base de datos | PostgreSQL (prod) / SQLite (dev) + SQLAlchemy | ORM + migraciones |
| Auth | Firebase Auth (Google + Microsoft) | Cookie HTTP-only |
| Pagos | Reveniu | CLP nativo, webhooks |
| Deploy | Railway | PostgreSQL managed + app en un solo lugar |
| IA | Claude API (Anthropic) | Haiku para tareas simples, Sonnet para análisis |
| Calidad | ruff + mypy + pytest | Sin excepciones |

---

## Paso 1 — Estructura de carpetas

Crear exactamente esta estructura antes de escribir código:

```
<nombre-proyecto>/
├── CLAUDE.md                    # instrucciones del proyecto para Claude Code
├── CONTEXT.md                   # contexto vivo (se actualiza automáticamente)
├── .env.example                 # variables documentadas (nunca .env en git)
├── .editorconfig
├── .gitignore
├── Makefile
├── Procfile
├── Dockerfile
├── pyproject.toml
├── requirements.txt
├── requirements-dev.txt
│
├── docs/
│   ├── estado-del-arte/
│   │   └── product-vision.md    # qué, para quién, por qué
│   ├── constitution/
│   │   └── constitution.md      # principios inmutables
│   ├── plan/
│   │   └── v1-mvp.md            # plan técnico + ADRs
│   ├── clarify/
│   │   └── assumptions.md       # supuestos y decisiones tempranas
│   ├── modular/
│   │   └── modules.md           # contratos entre módulos
│   └── sdd/
│       └── arquitectura.md      # system design document
│
├── specs/                       # una spec por feature
│
├── scripts/
│   ├── update_context.py        # auto-actualiza CONTEXT.md
│   └── install_hooks.sh         # instala git hooks
│
├── .github/
│   ├── workflows/
│   │   └── ci.yml               # ruff + mypy + pytest en cada push
│   └── PULL_REQUEST_TEMPLATE.md
│
├── observability/
│   └── logging.md
│
├── src/
│   ├── models/                  # SQLAlchemy + Pydantic
│   ├── auth/                    # Firebase + API Keys
│   ├── api/                     # rutas FastAPI
│   └── products/                # un directorio por producto
│
├── tests/
│   └── conftest.py
│
├── frontend/                    # SvelteKit
│   ├── src/
│   │   └── routes/
│   ├── package.json
│   └── svelte.config.js
│
└── .claude/
    ├── settings.json            # hooks Stop + permisos
    └── commands/                # slash commands del proyecto
```

---

## Paso 2 — Instalación

### Python
```bash
python3.11 -m venv .venv
.venv/bin/pip install fastapi uvicorn sqlalchemy pydantic alembic
.venv/bin/pip install anthropic httpx python-multipart python-jose
.venv/bin/pip install ruff mypy pytest pytest-asyncio httpx --group dev
```

### SvelteKit
```bash
npm create svelte@latest frontend
cd frontend && npm install
```

### requirements.txt mínimo
```
fastapi>=0.110
uvicorn[standard]>=0.27
sqlalchemy>=2.0
pydantic>=2.0
alembic>=1.13
anthropic>=0.20
httpx>=0.27
python-multipart>=0.0.9
```

### requirements-dev.txt
```
ruff>=0.4
mypy>=1.9
pytest>=8.0
pytest-asyncio>=0.23
```

---

## Paso 3 — Configuración de calidad (pyproject.toml)

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP"]

[tool.mypy]
python_version = "3.11"
strict = false
ignore_missing_imports = true

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
```

---

## Paso 4 — Hooks automáticos (siempre A + B)

### A — Claude Code Stop Hook (.claude/settings.json)
```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "python3 scripts/update_context.py 2>/dev/null || true",
        "statusMessage": "Actualizando CONTEXT.md..."
      }]
    }]
  }
}
```

### B — Git post-commit hook
```bash
bash scripts/install_hooks.sh
```

El script `scripts/update_context.py` lee los últimos commits y actualiza
la sección `## Últimos cambios` en `CONTEXT.md` automáticamente.

---

## Paso 5 — CI/CD (.github/workflows/ci.yml)

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
      - run: pip install -r requirements.txt -r requirements-dev.txt
      - run: ruff check src/ tests/ main.py
      - run: ruff format --check src/ tests/ main.py
      - run: mypy src/
      - run: pytest tests/ -v --tb=short
        env:
          ANTHROPIC_API_KEY: sk-ant-test-key
```

---

## Paso 6 — CONTEXT.md inicial

Crear con este template y completar antes de codear:

```markdown
# CONTEXT.md — <Nombre Proyecto>

## Qué es
<Una línea: qué hace y para quién>

## Productos
- **<Producto 1>** — descripción breve
- **<Producto 2>** — descripción breve

## Estado actual
- [ ] Setup inicial
- [ ] Módulo X
- [ ] Deploy

## Arquitectura
<diagrama ASCII básico>

## Módulos clave
| Qué busco | Dónde está |
|---|---|

## Reglas de calidad
make quality  # ruff + mypy + pytest

## Decisiones clave
| Decisión | Por qué |
|---|---|

## Lo que NO hacer
- ❌
```

---

## Paso 7 — Makefile mínimo

```makefile
quality:
	.venv/bin/ruff check src/ tests/ main.py --fix
	.venv/bin/ruff format src/ tests/ main.py
	.venv/bin/mypy src/
	.venv/bin/pytest tests/ -v

dev:
	.venv/bin/uvicorn main:app --reload

test:
	.venv/bin/pytest tests/ -v

build:
	cd frontend && npm run build
```

---

## Reglas siempre activas

1. **Antes de terminar cualquier tarea:** `make quality` debe pasar sin errores
2. **Cada módulo nuevo:** spec en `specs/<modulo>.md` antes de codear
3. **Cada decisión arquitectónica:** ADR en `docs/plan/v1-mvp.md`
4. **Cada sesión que termina:** CONTEXT.md se actualiza solo (Stop hook)
5. **Cada commit:** CONTEXT.md se actualiza solo (post-commit hook)
6. **Nunca subir `.env`** — solo `.env.example` con descripciones
7. **Tests antes de PR** — sin tests, no se mergea

---

## Variantes de stack

### Solo backend (API sin frontend)
- Eliminar `frontend/`
- Agregar `contracts/openapi.yml` desde el día 1

### Solo frontend estático
- Eliminar `src/` FastAPI
- Usar SvelteKit con adaptador estático

### Con IA generativa
- Instalar `anthropic`
- Pipeline 4 capas: validación local → Haiku precheck → Sonnet análisis
- Nunca llamar Sonnet sin pasar por Haiku primero (costo)
