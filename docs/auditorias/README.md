# Actas de auditoría de coherencia

> Tracker de cobertura del **gate de coherencia LLM** (§7.8 del flujo, Bloque E del plan
> anti-drift). El gate vive en [`../../.claude/workflows/auditoria-coherencia-docs.js`](../../.claude/workflows/auditoria-coherencia-docs.js).

## Qué son estas actas

**Inmutables** (AUD-4). Un acta es la foto del estado **al momento de auditar**, no la foto
de hoy — esa vive en `<modulo>_estado.md`. No se editan: si algo cambió, lo dice el acta
siguiente. Es la misma disciplina del CHANGELOG (FLU-14), por la misma razón.

**El gate PROPONE, jamás aplica.** READ-ONLY estricto sobre las siete raíces: el único
archivo que escribe es su propia acta. Los parches se proponen dentro; los aplica una pasada
documental aparte, con el autor, con el triage A/B/C/CADUCO de §7.8 (AUD-5).

## Qué NO es este gate

No caza huérfanos, bicéfalos, sedes rotas ni evidencia rota: eso lo prueba el **checker
determinista** (`.claude/check-ids/`, §7.7), que corre en cada commit y es exhaustivo. El
gate es para lo único que un script no puede ver: la **contradicción semántica entre prosa**.

## Cómo se corre

```
Workflow({ name: 'auditoria-coherencia-docs', args: { fecha: '2026-07-16', piloto: true } })
```

> **TRAMPA, ya pagada (2026-07-16, corrida `_v2`).** Si acabás de EDITAR el `.js`, invocarlo
> por `name:` puede correr una versión **cacheada** y tus cambios no entran — sin avisar. Esa
> corrida gastó ~1,1M tokens probando un fix que no estaba en el script, y solo se detectó
> porque `docsAuditados` dio 4 donde tenían que ser 5. **Después de editar, invocá por ruta:**
>
> ```
> Workflow({ scriptPath: 'corpus/.claude/workflows/auditoria-coherencia-docs.js', args: {...} })
> ```
>
> Y siempre contrastá el retorno contra lo que esperabas: si el conteo de sujetos no coincide
> con la tabla del script, corrió otra cosa.

- **SCOPED / piloto** (`piloto: true`) — solo el framework. Barato.
- **COMPLETO** (`piloto: false`) — los docs normativos de las siete raíces. La lista canónica
  es la tabla `CORPUS_COMPLETO` del script (**29 docs** al 2026-07-19) — se deriva del árbol,
  no se enumera acá (FLU-27); verificá que `docsAuditados` del retorno coincida con ella.

**Cadencia:** AUD-1 (SCOPED al cerrar cualquier sesión que escribió normas), AUD-2 (COMPLETO
al cerrar un Block de módulo), AUD-3 (ningún gate corre con poco contexto: se difiere).

**Modelo y sesión (instrucción del autor, 2026-07-19):** las corridas del gate se lanzan en
**sesión fresca** (AUD-3) y sus agentes corren con **Opus 4.8** — no con el modelo Max de la
sesión de trabajo.

**Antes de correr un COMPLETO, leer las deudas D-3/D-7 del registro.** Un gate que cruza IDs
es **ciego** a un doc sin IDs. Al 2026-07-19 la prosa de los módulos ya lleva sus IDs
(109/125) y `GIT-1..7` están etiquetados; lo que sigue sin ancla son las sedes fuera de doc
(D-3) y los roadmaps, que por voto del autor son **intención pura**: un "limpio" sobre ellos
en el cruce de IDs se reporta NO-AUDITABLE POR DISEÑO, no como cobertura. En Kontrol esa
confusión costó 22 hallazgos después de declarar un doc limpio (§10.8 de su referencia).

## Cobertura

| Fecha | Modo | Docs | Resultado | Acta |
|---|---|---|---|---|
| 2026-07-16 | SCOPED / piloto | 4 | **DEGRADADA** — 7 confirmadas, 0 bloqueantes. Dos temas (`namespacing`, `dano-limbs`) quedaron **sin cruzar** por una caída del clasificador: no están limpios, están **sin auditar** | [acta](2026-07-16_coherencia_docs_PILOTO.md) |
| 2026-07-16b | SCOPED / piloto v2 | 4 | 2 confirmadas (MEDIA), 62 sin ID, 7 huecos. **La corrida pagó la trampa del caché**: `Workflow({name})` corrió el script viejo (~1,1M tokens) — de ahí la regla del `scriptPath` de arriba | [acta](2026-07-16b_coherencia_docs_PILOTO_v2.md) |
| 2026-07-16c | PILOTO v3 (5 docs del framework) | 5 | **COMPLETA** (0 cobertura perdida) — 4 confirmadas, 0 bloqueantes, 86 sin ID, 56 sin alcance. Triadas el 2026-07-19: los 3 bucket A reparados, el 2.4 consolidado con el voto de COR-6 (votado y aplicado) | [acta](2026-07-16c_coherencia_docs_PILOTO_v3.md) |
| 2026-07-19 | **COMPLETO (AUD-2, 1.ª corrida)** | **29** | **ÍNTEGRA** (0 cobertura perdida, sin resumes: 145 agentes, 0 caídos) — **26 confirmadas** (6 ALTA / 13 MEDIA / 7 BAJA / 0 bloqueantes), triage del gate: **25 A + 1 B** (el GC del cadáver looteado, hallazgo 2.10 — voto del autor), 1 divergencia yaml-vs-sede, 844 normativas sin ID, 10 de 29 docs sin un solo ID (cobertura ciega declarada). Agentes en Opus 4.8, sesión fresca. Reparación: pendiente de su propia tanda | [acta](2026-07-19_coherencia_docs.md) |

**Costo medido del COMPLETO (2026-07-19):** 145 agentes / 8,31M tokens / 1.245 tool uses /
~44 min para 29 docs — dentro de la estimación de 8-10M. Limpio a la primera (0 resumes);
`agents_empty_result: 1` verificado contra `journal.jsonl` — retorno bien formado con cero
candidatas, no un agente caído.

**Costo medido del piloto:** 41 agentes / 1,69M tokens / ~23 min, para 4 docs y 1.188 líneas.
Referencia de Kontrol: ~216 agentes / ~11M tokens / ~84 min para 3 docs — unas **6,5× más
caro**. La mayor parte del ahorro es de diseño: este gate lee `ids.yaml` como glosario en vez
de re-derivar el índice a grep, porque el checker ya prueba esa parte mecánicamente.

**Dos defectos que el piloto encontró en el gate mismo, ya corregidos:**

1. Los **`CLAUDE.md` quedaban fuera del corpus** por ser árbitros (jerarquía nivel 4) — pero
   son la **sede de 32 IDs** del ecosistema, y el valor único del gate es contrastar el
   `titulo` del yaml contra la prosa de su sede. Estaban omitidos justo donde más servían.
   Ahora son **sujetos obligatorios en todo modo**. (Kontrol los excluye y tiene el mismo
   punto ciego.)
2. Un agente muerto se descartaba con `filter(Boolean)` y el acta reportaba cobertura que no
   tuvo — un **falso-limpio por omisión**, el modo de falla del §10.8 cometido por el gate que
   existe para prevenirlo. Ahora la cobertura perdida se cuenta, se loguea, viaja al acta y
   marca la corrida como `degradada`.
