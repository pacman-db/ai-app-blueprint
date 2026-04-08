#!/bin/bash
# bootstrap.sh — Creates a new project from the AI App Blueprint
# Usage: bash scripts/bootstrap.sh <project-name>

set -e

PROJECT_NAME="${1:-my-ai-app}"
BLUEPRINT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="$(pwd)/$PROJECT_NAME"

echo "🚀 Bootstrapping $PROJECT_NAME..."

# ── Create project directory ───────────────────────────────────────────────────
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"
git init

# ── Copy blueprint files ───────────────────────────────────────────────────────
cp -r "$BLUEPRINT_DIR/blueprint/." .
cp "$BLUEPRINT_DIR/scripts/update_context.py" scripts/
cp "$BLUEPRINT_DIR/scripts/install_hooks.sh" scripts/
mkdir -p .github/workflows
cp "$BLUEPRINT_DIR/github/workflows/ci.yml" .github/workflows/
cp "$BLUEPRINT_DIR/github/PULL_REQUEST_TEMPLATE.md" .github/

# ── Rename templates ───────────────────────────────────────────────────────────
mv CONTEXT.md.template CONTEXT.md
mv CLAUDE.md.template CLAUDE.md
mv .env.example.template .env.example 2>/dev/null || true
mv Makefile.template Makefile 2>/dev/null || true

# ── Replace placeholders ───────────────────────────────────────────────────────
DATE=$(date +%Y-%m-%d)
find . -name "*.md" -not -path "./.git/*" | xargs sed -i '' \
  "s/{{PROJECT_NAME}}/$PROJECT_NAME/g; s/{{DATE}}/$DATE/g" 2>/dev/null || true

# ── Create base structure ──────────────────────────────────────────────────────
mkdir -p src/{models,auth,api,products} tests specs observability

# ── Install git hooks ──────────────────────────────────────────────────────────
bash scripts/install_hooks.sh

# ── Create .gitignore ─────────────────────────────────────────────────────────
cat > .gitignore << 'EOF'
# Python
.venv/
__pycache__/
*.pyc
*.pyo
.mypy_cache/
.ruff_cache/
.pytest_cache/

# Environment
.env
.env.*
!.env.example

# Database
*.db
*.sqlite

# Frontend
frontend/node_modules/
frontend/build/
frontend/.svelte-kit/

# Deploy
*.log
EOF

# ── Create .claude/settings.json with Stop hook ───────────────────────────────
mkdir -p .claude
cat > .claude/settings.json << EOF
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "python3 $(pwd)/scripts/update_context.py 2>/dev/null || true",
        "statusMessage": "Updating CONTEXT.md..."
      }]
    }]
  }
}
EOF

echo ""
echo "✅ $PROJECT_NAME created at $TARGET_DIR"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. Fill in CONTEXT.md and CLAUDE.md with your project details"
echo "  3. Copy .env.example to .env and set your values"
echo "  4. Open in Claude Code and run /bootstrap-app"
echo ""
echo "Auto-context hooks installed:"
echo "  → git post-commit: updates CONTEXT.md after every commit"
echo "  → Claude Code Stop: updates CONTEXT.md after every session"
