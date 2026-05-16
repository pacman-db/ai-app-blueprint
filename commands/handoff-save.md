# Handoff Save — Guardar contexto de sesión

Guarda un resumen de esta sesión en `HANDOFF.md` para que la próxima arranque sin re-explicar nada.

## Instrucciones

1. Lee `CONTEXT.md` para entender el estado actual
2. Revisa los últimos 5 commits: `git log --oneline -5`
3. Revisa specs recientes: `git log --oneline -3 -- docs/specs/`
4. Genera el resumen y escríbelo en `HANDOFF.md` (sobreescribe si existe)

## Formato de HANDOFF.md

```markdown
## Handoff — {{fecha}}

**Repo:** {{path}}
**Rama:** {{rama}}

### Qué se hizo
- (bullets concretos de lo completado)

### Decisiones tomadas
- (decisiones con su razón)

### Próximo paso
(una acción concreta)

### Contexto para arrancar
(párrafo autosuficiente — quien lo lea sin haber visto esta sesión debe poder arrancar solo)
```

## Reglas

- Sin preamble, escribe HANDOFF.md directo
- Máximo 200 palabras en total
- El bloque "Contexto para arrancar" debe mencionar archivos y specs relevantes por nombre
- Confirma con: `✓ HANDOFF.md guardado`
