# Corpus — CHANGELOG de parches (repo: corpus/)

> Registro de parches al código y a la documentación, por sesión de diseño.
> **Disciplina (heredada de Kontrol vía ADS 2.0):**
> - Un parche nace `[PENDIENTE]` y pasa a `[APLICADO YYYY-MM-DD]` cuando se aplica y
>   verifica. Para código de addon GMod, "verificado" = confirmado en juego (ver
>   [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt)).
> - **Nunca** se borra una entrada. **Nunca** se renumera un parche existente.
> - Cada sesión de diseño abre su **propia subsección**, con numeración de parches
>   independiente de otras sesiones.
> - Estado vivo del proyecto → [`corpus_estado.md`](corpus_estado.md). Lo
>   `[PENDIENTE]` acá debe coincidir con lo pendiente allá.
> - Este CHANGELOG es de **este repo** (`corpus/`). Cada repo hermano abre el suyo
>   propio cuando empieza a recibir código.

---

## PARCHES DE sesión Bootstrap del workspace + metodología — 2026-07-08

Sesión de arranque del ecosistema: cierre de Block 1 (framework Corpus + grafo de
dependencias + workspace multi-root, diseño ya validado en sesión previa de
planificación), creación del workspace VSCode de seis raíces, y portación del flujo
de trabajo (planificación por bloques, vertical slice, convenciones de commit,
changelog) desde ADS 2.0 / Kontrol a Corpus.

- PARCHE 1 — Documento de arquitectura: `CORPUS_Architecture.md` (§1-§9) — framework,
  grafo de dependencias, superficie de API, fronteras de módulo, contrato de ítems,
  orden de carga, migración ADS→Caliber, workspace multi-root. **[APLICADO
  2026-07-08]**

- PARCHE 2 — Workspace multi-root: `corpus.code-workspace` + seis carpetas raíz
  (`corpus`, `corpus-cortex`, `corpus-caliber`, `corpus-coagulant`, `corpus-craving`,
  `corpus-cargo`) + carpeta `dev/` fuera de todo repo git, para mods de referencia y
  código que no se publica. **[APLICADO 2026-07-08]**

- PARCHE 3 — Docs de metodología: `CLAUDE.md`, `corpus_flujo_trabajo.txt`,
  `corpus_convenciones_commits.txt`, `corpus_estado.md`, `corpus_roadmap.txt`, este
  `CHANGELOG.md` — adaptados desde el equivalente de ADS 2.0
  (`ads_flujo_trabajo.txt` / `ads_convenciones_commits.txt` / etc., a su vez
  portados de Kontrol), generalizados para el workspace multi-repo de Corpus.
  **[APLICADO 2026-07-08]**

- PARCHE 4 — Legacy ADS 2.0 + VMT Editor movidos a `dev/legacy/` como material de
  referencia: mod antiguo a revisar/mejorar dentro de Corpus (ver §7 de la
  arquitectura, migración ADS→Caliber), junto con los mods de terceros que ya traía
  en su propio `dev/` interno. **[APLICADO 2026-07-08]**

- PARCHE 5 — Reorganización de `dev/`: los mods de terceros (VJ Base, ARC9 EFT,
  zbase, drgbase, halo energy shield, visceral dynamic blood, etc.) que vivían
  anidados en `dev/legacy/AdvancedDamageSystem 2.0/dev/` se subieron a `dev/other/`,
  al nivel del resto del workspace. **[APLICADO 2026-07-08]**

- PARCHE 6 — `git init` corrido en los seis repos del workspace (`corpus` + los
  cinco hermanos). `corpus/` suma `.gitignore` y su primer commit con los docs de
  bootstrap; los cinco repos hermanos quedan inicializados sin commits, a la espera
  de su Block de diseño. Ningún repo tiene remote todavía. **[APLICADO 2026-07-08]**

- PARCHE 7 — Metodología: `corpus_flujo_trabajo.txt` y `CLAUDE.md` reconocen ahora
  el patrón doc de arquitectura GENERAL vs. PARTICULAR (precedente: en ADS,
  `ADS_2_0_Architecture_updated.md` + `ADS_EnergyShields_Arquitectura.md`, patrón que
  nunca quedó escrito en su propio `ads_flujo_trabajo.txt`). Se agrega
  `<modulo>_Architecture.md` a la plantilla de docs que recibe un repo hermano al
  cerrar su primer Block (antes faltaba), y se documenta el criterio para desprender
  un doc particular autocontenido cuando un subsistema lo amerita. **[APLICADO
  2026-07-08]**

Nota: sesión puramente de documentación y estructura de carpetas — cero código Lua
escrito. Ver [`corpus_estado.md`](corpus_estado.md) "Próximo paso" para la decisión
abierta sobre cuándo empieza la implementación.
