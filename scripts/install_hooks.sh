#!/bin/bash
# Instala los git hooks del proyecto.
# Correr una vez después de clonar: bash scripts/install_hooks.sh

set -e

HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"

echo "📎 Instalando git hooks en $HOOKS_DIR"

# ── post-commit: actualiza CONTEXT.md después de cada commit ──────────────────
cat > "$HOOKS_DIR/post-commit" << EOF
#!/bin/bash
# Auto-actualiza CONTEXT.md con los últimos commits
python3 "$SCRIPTS_DIR/update_context.py" 2>/dev/null || true
EOF

chmod +x "$HOOKS_DIR/post-commit"
echo "  ✅ post-commit instalado"

echo ""
echo "Listo. CONTEXT.md se actualizará automáticamente después de cada commit."
echo "Para actualizar manualmente: python3 scripts/update_context.py"
