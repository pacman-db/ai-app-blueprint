#!/bin/bash
# install_hooks.sh — Install git hooks for this project.
# Run once after cloning: bash scripts/install_hooks.sh

set -e

HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"

echo "Installing git hooks in $HOOKS_DIR"

# ── post-commit: update all living docs after every commit ────────────────────
cat > "$HOOKS_DIR/post-commit" << EOF
#!/bin/bash
# Auto-updates CONTEXT.md, constitution, clarify, plan and spec statuses
python3 "$SCRIPTS_DIR/update_docs.py" 2>/dev/null || true
EOF

chmod +x "$HOOKS_DIR/post-commit"
echo "  ✓ post-commit installed"

echo ""
echo "Done. All living docs will auto-update after every commit."
echo "To update manually: python3 scripts/update_docs.py"
