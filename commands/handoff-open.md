# Handoff Open — Cargar contexto de sesión anterior

Carga el contexto guardado por `/handoff-save` y prepara la sesión para continuar.

## Instrucciones

1. Lee `HANDOFF.md` — contexto de la sesión anterior
2. Lee `CONTEXT.md` — estado actual del proyecto
3. Si se mencionan specs en HANDOFF.md, léelas
4. Presenta un resumen de situación y pregunta cómo continuar

## Formato de respuesta

```
Contexto cargado ✓

**Dónde quedamos:** (1 línea)
**Próximo paso:** (1 línea)

¿Continuamos con {{próximo paso}} o tienes algo distinto en mente?
```

## Reglas

- Sin preamble largo — ir directo al resumen
- Si HANDOFF.md no existe, avisar: `No hay sesión guardada. Ejecuta /handoff-save al terminar tu próxima sesión.`
- No ejecutar código ni modificar archivos — solo leer y presentar
