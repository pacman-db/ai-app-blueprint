#!/usr/bin/env python3
"""
update_context.py — Actualiza CONTEXT.md con los cambios recientes del repo.

Llamado por:
  - Git post-commit hook: captura qué cambió
  - Claude Code Stop hook: captura decisiones de la sesión

Nunca sobreescribe CONTEXT.md completo — solo actualiza secciones específicas.
"""

from __future__ import annotations

import re
import subprocess
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).parent.parent
CONTEXT_FILE = ROOT / "CONTEXT.md"
MAX_COMMITS = 8


def _git(cmd: list[str]) -> str:
    result = subprocess.run(["git", "-C", str(ROOT)] + cmd, capture_output=True, text=True)
    return result.stdout.strip()


def _recent_commits() -> list[dict]:
    """Últimos N commits con hash, mensaje y archivos cambiados."""
    log = _git(["log", f"-{MAX_COMMITS}", "--format=%H|%s|%ad", "--date=short"])
    commits = []
    for line in log.splitlines():
        if not line.strip():
            continue
        parts = line.split("|", 2)
        if len(parts) == 3:
            hash_, msg, date = parts
            files = _git(["diff-tree", "--no-commit-id", "-r", "--name-only", hash_])
            commits.append({"hash": hash_[:7], "msg": msg, "date": date, "files": files})
    return commits


def _classify_commits(commits: list[dict]) -> dict[str, list[str]]:
    """Clasifica commits por tipo para generar resumen."""
    classified: dict[str, list[str]] = {
        "features": [],
        "fixes": [],
        "docs": [],
        "infra": [],
        "other": [],
    }
    for c in commits:
        msg = c["msg"].lower()
        entry = f"`{c['hash']}` {c['msg']} ({c['date']})"
        if msg.startswith("feat"):
            classified["features"].append(entry)
        elif msg.startswith("fix"):
            classified["fixes"].append(entry)
        elif msg.startswith("docs") or msg.startswith("blueprint"):
            classified["docs"].append(entry)
        elif any(k in msg for k in ("ci", "deploy", "infra", "make", "chore")):
            classified["infra"].append(entry)
        else:
            classified["other"].append(entry)
    return classified


def _build_cambios_section(commits: list[dict]) -> str:
    """Genera la sección '## Últimos cambios' para CONTEXT.md."""
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    classified = _classify_commits(commits)

    lines = [f"## Últimos cambios\n", f"_Actualizado automáticamente: {now}_\n"]

    if classified["features"]:
        lines.append("\n### Features")
        lines.extend(f"- {e}" for e in classified["features"])

    if classified["fixes"]:
        lines.append("\n### Fixes")
        lines.extend(f"- {e}" for e in classified["fixes"])

    if classified["infra"] or classified["docs"]:
        lines.append("\n### Infra / Docs")
        lines.extend(f"- {e}" for e in classified["infra"] + classified["docs"])

    if classified["other"]:
        lines.append("\n### Otros")
        lines.extend(f"- {e}" for e in classified["other"])

    # Archivos más tocados en esta tanda
    all_files: list[str] = []
    for c in commits:
        all_files.extend(c["files"].splitlines())

    if all_files:
        from collections import Counter
        top = Counter(all_files).most_common(5)
        lines.append("\n### Archivos más modificados")
        lines.extend(f"- `{f}` ({n}x)" for f, n in top)

    return "\n".join(lines) + "\n"


def _update_section(content: str, section_header: str, new_content: str) -> str:
    """
    Reemplaza una sección completa en el archivo.
    Si no existe la sección, la agrega al final.
    """
    # Busca '## Últimos cambios' hasta el siguiente '## ' o fin de archivo
    pattern = rf"(## {re.escape(section_header.lstrip('## '))}.*?)(?=\n## |\Z)"
    match = re.search(pattern, content, re.DOTALL)
    if match:
        return content[: match.start()] + new_content + content[match.end() :]
    else:
        return content.rstrip() + "\n\n---\n\n" + new_content


def main() -> None:
    if not CONTEXT_FILE.exists():
        print(f"[context] {CONTEXT_FILE} no existe, nada que actualizar.")
        return

    commits = _recent_commits()
    if not commits:
        print("[context] Sin commits recientes.")
        return

    content = CONTEXT_FILE.read_text(encoding="utf-8")
    new_section = _build_cambios_section(commits)
    updated = _update_section(content, "## Últimos cambios", new_section)

    if updated != content:
        CONTEXT_FILE.write_text(updated, encoding="utf-8")
        print(f"[context] CONTEXT.md actualizado con {len(commits)} commits recientes.")
    else:
        print("[context] CONTEXT.md ya está al día.")


if __name__ == "__main__":
    main()
