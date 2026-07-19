export const meta = {
  name: 'auditoria-coherencia-docs',
  description: 'Auditoria doc-vs-doc del ecosistema Corpus, adjudicada contra el Lua / estado.md / CHANGELOG',
  whenToUse: 'Cuando haya que verificar que los docs de diseno de las siete raices no se contradicen entre si ni contra la realidad del arbol. args: { fecha: "2026-07-16", piloto: true|false, destino: "ruta" }',
  phases: [
    { title: 'Glosario', detail: 'Lee docs/ids.yaml: el indice ya existe y el checker lo valida. No se reconstruye por grep.' },
    { title: 'Lectura', detail: 'Un lector por tramo: extrae afirmaciones normativas con archivo:linea, tema, fuerza y ALCANCE' },
    { title: 'Cruce', detail: 'Un agente por tema: busca contradicciones entre docs dentro de su tema' },
    { title: 'Adjudicacion', detail: '3 verificadores adversariales por candidata; el Lua / estado.md / CHANGELOG desempatan' },
    { title: 'Completitud', detail: 'Critico: que quedo sin cubrir' },
    { title: 'Sintesis', detail: 'Acta en docs/auditorias/ + parches PROPUESTOS (jamas aplicados)' },
  ],
}

// ─────────────────────────────────────────────────────────────────────────────
// Parametros. args puede llegar como objeto o como string JSON segun el
// invocador: si llega string y lo tratamos como objeto, TODOS los flags dan
// undefined EN SILENCIO y el gate corre con los defaults (corpus completo).
// ─────────────────────────────────────────────────────────────────────────────
let ARGS = {}
if (typeof args === 'string') {
  try { ARGS = JSON.parse(args) } catch (e) { ARGS = {} }
} else if (args && typeof args === 'object') {
  ARGS = args
}

const FECHA = ARGS.fecha || '2026-07-16'
const PILOTO = !!ARGS.piloto
const DESTINO = ARGS.destino ||
  `corpus/docs/auditorias/${FECHA}_coherencia_docs${PILOTO ? '_PILOTO' : ''}.md`

// ─────────────────────────────────────────────────────────────────────────────
// Las tres reglas duras de Kontrol, conservadas. Van LITERALES en cada agente.
// ─────────────────────────────────────────────────────────────────────────────
const READ_ONLY = `
MODO READ-ONLY SOBRE LOS SIETE REPOS - NO NEGOCIABLE:
No modifiques, crees ni borres NINGUN archivo dentro de ninguna de las siete raices.
Ni un doc, ni el CHANGELOG, ni ids.yaml, ni Lua, ni el espejo desktop-sync. Nada.
El UNICO archivo que esta auditoria escribe es el acta final, en la ruta que se te
indique explicitamente. Los parches a docs se PROPONEN dentro del acta; JAMAS se
aplican. El gate propone, el autor dispone.
`.trim()

const JERARQUIA = `
JERARQUIA DE AUTORIDAD (corpus_flujo_trabajo.txt seccion 7.1 - no negociable):
  1. CODIGO Lua del repo (lua/**, defs, el arbol real) - verdad final.
  2. <modulo>_estado.md del repo dueno del hecho - foto de HOY.
  3. docs/CHANGELOG.md - una entrada [APLICADO] posterior DEROGA lo que un doc de
     arquitectura siga enunciando como vigente.
  4. CLAUDE.md - los "Contratos que no debes romper" de cada repo.
  5. Docs de arquitectura (<modulo>_Architecture.md y los particulares) - son DISENO,
     y son LOS AUDITADOS.
  6. roadmap - es intencion, no autoridad sobre lo que existe.
Cuando un doc de arquitectura choca con 1-4: el DOC esta mal, no el repo.
docs/ids.yaml NO entra a la jerarquia: es INDICE, jamas segunda definicion. Si el yaml
contradice la prosa de su sede, el yaml esta desactualizado.

FALSOS POSITIVOS QUE DEBES RECHAZAR (este ecosistema disena por delante del codigo A PROPOSITO):
  · "Esto no esta implementado todavia" NO es un hallazgo. JAMAS. El corpus es diseno futuro.
  · Dos docs diciendo LO MISMO con palabras distintas NO es una contradiccion.
  · Distinto NIVEL DE DETALLE no es contradiccion (un doc resume, otro especifica).
  · Distinto ALCANCE no es contradiccion. Verifica el alcance ANTES de declarar choque.
    En este ecosistema el alcance tiene cuatro ejes, y confundirlos es el 90% del ruido:
      - REALM: server / client / shared. Una regla de server y una de client NO chocan.
      - MODULO: cada modulo es dueno de su dominio. "El pool de limbs es de Caliber" y
        "Coagulant no toca limbs" son la MISMA regla vista de los dos lados, no un choque.
      - SOFT-DEP: "sin Cargo, la via es X" y "con Cargo, la via es Y" es DEGRADACION
        HONESTA (COR-11), no contradiccion. Es el patron de produccion del ecosistema.
      - BLOCK / SLICE: una regla de un slice cerrado y una de un slice pendiente
        conviven; el diseno va por delante.
  · MOCK-FIRST (FLU-17) NO es una contradiccion. Un doc que congela la firma de un peer
    que todavia no existe esta HACIENDO SU TRABAJO, no mintiendo. Ejemplo real: Craving
    congelo COAGULANT.ApplyExternalCondition antes de que Coagulant la ratificara. Eso es
    deuda declarada (D-5), no un choque de docs.
SOLO es hallazgo: (a) dos docs que afirman cosas mutuamente INCOMPATIBLES dentro del MISMO
alcance, o (b) un doc que afirma algo que el Lua / estado.md / CHANGELOG ya resolvieron
distinto.

${READ_ONLY}
`.trim()

// ─────────────────────────────────────────────────────────────────────────────
// Taxonomia fija - los buckets del cruce. Un doc puede tocar varios.
// Derivada del dominio real del ecosistema, no de la de Kontrol.
// ─────────────────────────────────────────────────────────────────────────────
const TEMAS = [
  { key: 'framework-delgado', desc: 'COR-10/COR-1: que sube a Corpus y que no. Logica de dominio en el framework, primitivas candidatas' },
  { key: 'soft-deps',         desc: 'COR-11/COR-5: hard-dep unica, deteccion en runtime, lazy-check, degradacion honesta, direccion de las soft-deps' },
  { key: 'realms',            desc: 'server/client/shared: defs en ambos realms (COR-12), prediccion de Move, autoridad del server, espejo NW2' },
  { key: 'namespacing',       desc: 'COR-2/3/4/6/9: namespace unico, persistencia y net namespaced, prefijo de archivo, autosuficiencia' },
  { key: 'contrato-items',    desc: 'COR-12/13/14 y CRG-*: defs, clases stackable/unique, onUse y su retorno, blob de instancia, footprint' },
  { key: 'boot-carga',        desc: 'CAL-1..9: boot diferido, sonda, manifest explicito, orden de include, nunca invocar hacia adelante' },
  { key: 'dano-limbs',        desc: 'Caliber: pipeline escudo/armadura/limbs, hitgroups, zonas, la frontera con Coagulant y Cortex' },
  { key: 'dominio-medico',    desc: 'Coagulant: heridas, sangrado, tratamiento, debuffs zonales, la frontera con Caliber y Cargo' },
  { key: 'inventario',        desc: 'Cargo: grid, peso, munition, cinturon, comercio, contenedores, la frontera con los modulos duenos' },
  { key: 'ui-vgui',           desc: 'Menu Q, HUD, pcall en HUDPaint, trampas de VGUI, theme, quien pinta que' },
  { key: 'persistencia',      desc: 'COR-3/COR-8: rutas namespaced, round-trip JSON y normalizacion de claves, que persiste y que no' },
  { key: 'evidencia',         desc: 'FLU-05..12: la planilla, sus IDs de check, el harness, el selftest, que cuenta como verificado' },
  { key: 'proceso',           desc: 'FLU-*: orden de ejecucion, jerarquia, barrido de ratificacion, el PROMPT, el registro, commits' },
  { key: 'assets-licencias',  desc: 'STK-*: consumidor puro, assets fuera de git, rutas verbatim, RECICLAR vs COMPAT-RUNTIME' },
]

// ─────────────────────────────────────────────────────────────────────────────
// Corpus AUDITADO. El Lua, los estado.md y los CHANGELOG NO estan aca: son los
// ARBITROS (jerarquia 1-3). Auditamos DISENO (5) y roadmap (6).
//
// LOS CLAUDE.md SI ENTRAN, y son OBLIGATORIOS en todo modo (piloto incluido).
// [Corregido tras el piloto 2026-07-16, hallazgo 5.2 de su acta.] Un CLAUDE.md es
// arbitro (nivel 4) Y ADEMAS es la SEDE de 32 IDs del ecosistema (corpus 11,
// coagulant 10, cargo 9, stalker 5, craving 4, caliber 3). El valor unico de este
// gate frente al checker es contrastar el `titulo` del yaml contra la PROSA de su
// sede -- y dejarlos fuera nos hizo saltear exactamente los archivos que mas lo
// necesitan. Los dos roles conviven: se AUDITA su prosa como sede, y se lo sigue
// usando como arbitro al adjudicar. Kontrol los excluye y tiene el mismo punto ciego.
// El piloto que los omitio no vio, entre otras, que COR-6 declara un alcance
// ("en lua/autorun/...") que el arbol abandono: 70 de 74 archivos Lua de los modulos
// viven FUERA de autorun.
// ─────────────────────────────────────────────────────────────────────────────
// Conteos DERIVADOS del arbol con wc -l, no estimados a ojo: una norma que enumera se
// deriva del codigo, no de la prosa (FLU-27). Si un doc crece mucho, re-derivar y subir
// su `chunks` -- el tramo apunta a ~1400 lineas, el mismo grano que usa Kontrol.
//
// RE-DERIVADO 2026-07-19 (hallazgo (c) del acta v3, y era grave): la lista tenia 25
// entradas contra 29 docs normativos reales. Faltaban los cuatro convenciones_commits
// de modulo -- que SON normativos: GIT-6 los declara sede de los alcances de cada repo.
// Un COMPLETO contra una lista corta arranca con docs INVISIBLES y su limpio no
// significa nada (es la seccion 10.8 por la puerta de atras). El comando que la deriva:
//   for r in corpus corpus-*; do ls $r/CLAUDE.md $r/docs/*.{md,txt}; done
//   ... excluyendo CHANGELOG (historial), *_estado (foto volatil) y auditorias/ (actas).
const CORPUS_COMPLETO = [
  // Framework
  { file: 'corpus/CLAUDE.md',                                           total:  85, chunks: 1, repo: 'corpus' },
  { file: 'corpus/docs/corpus_flujo_trabajo.txt',                       total: 696, chunks: 1, repo: 'corpus' },
  { file: 'corpus/docs/CORPUS_Architecture.md',                         total: 339, chunks: 1, repo: 'corpus' },
  { file: 'corpus/docs/corpus_convenciones_commits.txt',                total: 138, chunks: 1, repo: 'corpus' },
  { file: 'corpus/docs/corpus_roadmap.txt',                             total: 100, chunks: 1, repo: 'corpus' },
  // Modulos - el CLAUDE.md primero: es la sede de sus contratos
  { file: 'corpus-cargo/CLAUDE.md',                                     total: 140, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-caliber/CLAUDE.md',                                   total:  86, chunks: 1, repo: 'corpus-caliber' },
  { file: 'corpus-coagulant/CLAUDE.md',                                 total:  83, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-craving/CLAUDE.md',                                   total:  82, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-stalker/CLAUDE.md',                                   total:  75, chunks: 1, repo: 'corpus-stalker' },
  { file: 'corpus-cargo/docs/Cargo_Architecture.md',                    total: 899, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-cargo/docs/cargo_roadmap.txt',                        total: 546, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-cargo/docs/Cargo_Trade_Arquitectura.md',              total: 332, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-cargo/docs/Cargo_ItemImages_Arquitectura.md',         total: 314, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-cargo/docs/Workbench_Arquitectura.md',                total: 185, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-coagulant/docs/Coagulant_Architecture.md',            total: 335, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-coagulant/docs/Coagulant_Block3_Semilla.md',          total: 148, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-coagulant/docs/coagulant_roadmap.txt',                total:  55, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-caliber/docs/Caliber_Architecture.md',                total: 298, chunks: 1, repo: 'corpus-caliber' },
  { file: 'corpus-caliber/docs/Caliber_EnergyShields_Arquitectura.md',  total: 291, chunks: 1, repo: 'corpus-caliber' },
  { file: 'corpus-caliber/docs/caliber_roadmap.txt',                    total:  94, chunks: 1, repo: 'corpus-caliber' },
  { file: 'corpus-craving/docs/Craving_Architecture.md',                total: 401, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-craving/docs/Craving_Block4_Semilla.md',              total: 240, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-craving/docs/craving_roadmap.txt',                    total:  68, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-stalker/docs/ASSETS.md',                              total: 116, chunks: 1, repo: 'corpus-stalker' },
  // Los convenciones_commits de modulo: normativos por GIT-6 (cada repo define su propia
  // tabla de alcances). Faltaban en la v1 de esta lista -- eran cuatro docs invisibles.
  { file: 'corpus-cargo/docs/cargo_convenciones_commits.txt',           total: 180, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-coagulant/docs/coagulant_convenciones_commits.txt',   total: 165, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-craving/docs/craving_convenciones_commits.txt',       total: 153, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-caliber/docs/caliber_convenciones_commits.txt',       total: 142, chunks: 1, repo: 'corpus-caliber' },
]

// PILOTO: solo el framework. Modo acotado historico: nacio cuando solo la prosa del
// framework llevaba IDs (la deuda D-7 mantuvo fuera a los modulos hasta que la pasada
// de etiquetado del 2026-07-19 la recorto — hoy los modulos tambien llevan los suyos).
// Un gate que cruza IDs es CIEGO a un doc sin IDs: un "limpio" ahi seria "no
// auditado", no "sano" (leccion 10.8 de Kontrol, que alla costo 22 hallazgos).
const CORPUS_PILOTO = CORPUS_COMPLETO.filter(d => d.repo === 'corpus')

const CORPUS = PILOTO ? CORPUS_PILOTO : CORPUS_COMPLETO

const TRAMOS = []
for (const d of CORPUS) {
  const span = Math.ceil(d.total / d.chunks)
  for (let i = 0; i < d.chunks; i++) {
    const desde = i * span + 1
    const hasta = Math.min((i + 1) * span, d.total)
    const nombre = d.file.split('/').pop().replace(/\.(md|txt)$/, '')
    TRAMOS.push({
      file: d.file,
      desde,
      hasta,
      label: d.chunks > 1 ? `${nombre}#${i + 1}/${d.chunks}` : nombre,
    })
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schemas de salida estructurada
// ─────────────────────────────────────────────────────────────────────────────
const GLOSARIO_SCHEMA = {
  type: 'object',
  required: ['entradas', 'divergencias'],
  properties: {
    entradas: {
      type: 'array',
      description: 'Una por ID del registro: su titulo y su sede, tal como el yaml los declara',
      items: {
        type: 'object',
        required: ['id', 'sede', 'titulo'],
        properties: {
          id:     { type: 'string' },
          sede:   { type: 'string' },
          titulo: { type: 'string' },
        },
      },
    },
    divergencias: {
      type: 'array',
      description: 'IDs cuyo titulo en el yaml NO coincide con lo que dice la prosa de su sede. El yaml es INDICE: si diverge, el yaml esta desactualizado. Es un hallazgo.',
      items: {
        type: 'object',
        required: ['id', 'sede', 'tituloYaml', 'diceLaSede'],
        properties: {
          id:         { type: 'string' },
          sede:       { type: 'string' },
          tituloYaml: { type: 'string' },
          diceLaSede: { type: 'string' },
        },
      },
    },
  },
}

const LECTURA_SCHEMA = {
  type: 'object',
  required: ['afirmaciones'],
  properties: {
    afirmaciones: {
      type: 'array',
      description: 'Toda afirmacion NORMATIVA del tramo. Exhaustivo: si dudas, incluila.',
      items: {
        type: 'object',
        required: ['ref', 'tema', 'afirmacion', 'fuerza', 'alcance'],
        properties: {
          ref:        { type: 'string', description: 'archivo:linea exacto' },
          tema:       { type: 'string', enum: TEMAS.map(t => t.key) },
          ids:        { type: 'array', items: { type: 'string' }, description: 'IDs (COR-nn, FLU-nn, CAL-nn...) que la afirmacion define o cita' },
          afirmacion: { type: 'string', description: 'AUTOCONTENIDA: legible sin abrir el doc. 1-3 frases. Sin pronombres colgando.' },
          fuerza:     { type: 'string', enum: ['NORMATIVA', 'DESCRIPTIVA', 'EJEMPLO'], description: 'NORMATIVA = debe/nunca/siempre/jamas. Solo las NORMATIVAS pueden contradecirse.' },
          alcance:    { type: 'string', description: 'Los cuatro ejes: REALM (server/client/shared), MODULO, SOFT-DEP (con/sin), BLOCK/SLICE. CRITICO para no inventar choques. Si el doc no lo dice: "no especificado".' },
          sinId:      { type: 'boolean', description: 'true si es NORMATIVA (siempre/nunca/debe/jamas) y NO define ni cita ningun ID. Viola FLU-25 y es un hallazgo por si mismo.' },
        },
      },
    },
  },
}

const CRUCE_SCHEMA = {
  type: 'object',
  required: ['candidatas'],
  properties: {
    candidatas: {
      type: 'array',
      items: {
        type: 'object',
        required: ['refA', 'afirmacionA', 'refB', 'afirmacionB', 'porQueChocan', 'gravedad'],
        properties: {
          refA:         { type: 'string' },
          afirmacionA:  { type: 'string' },
          refB:         { type: 'string' },
          afirmacionB:  { type: 'string' },
          porQueChocan: { type: 'string', description: 'Por que son MUTUAMENTE INCOMPATIBLES dentro del MISMO alcance, no solo distintas' },
          gravedad:     { type: 'string', enum: ['BLOQUEANTE', 'ALTA', 'MEDIA', 'BAJA'] },
        },
      },
    },
  },
}

const VEREDICTO_SCHEMA = {
  type: 'object',
  required: ['esContradiccionReal', 'ganador', 'evidencia'],
  properties: {
    esContradiccionReal: { type: 'boolean' },
    ganador:             { type: 'string', enum: ['A', 'B', 'NINGUNO', 'INDETERMINADO'], description: 'Cual afirmacion sobrevive segun la jerarquia de autoridad' },
    evidencia:           { type: 'string', description: 'Cita con archivo:linea del Lua / estado.md / CHANGELOG que lo decide. Sin evidencia -> INDETERMINADO.' },
    correccion:          { type: 'string', description: 'Parche PROPUESTO al doc perdedor (texto concreto). Vacio si INDETERMINADO.' },
  },
}

// ─────────────────────────────────────────────────────────────────────────────
// FASE 1 - Glosario desde el REGISTRO.
//
// Divergencia deliberada con Kontrol: alla la fase 1 reconstruye el indice de IDs
// a grep, porque su gate se escribio ANTES que su registro. Aca el registro ya
// existe (docs/ids.yaml, 184 IDs) y el CHECKER determinista (seccion 7.7) ya valida
// mecanicamente lo que esa fase buscaba: huerfanos, bicefalos, sedes rotas. Pagarle
// a tres agentes por re-derivar lo que un script prueba en un segundo seria caro y
// PEOR (el script es exhaustivo; el agente, probabilistico).
//
// Es el P-19 de Kontrol -- "cablear el gate al yaml curado" -- hecho desde el dia uno.
// Lo que el gate SI hace, y el checker no puede: verificar que el titulo del yaml
// coincida con la PROSA de su sede. El checker prueba que la sede EXISTE; solo un
// lector puede ver que dice otra cosa.
// ─────────────────────────────────────────────────────────────────────────────
phase('Glosario')
log(`Corpus: ${CORPUS.length} docs - ${TRAMOS.length} tramos${PILOTO ? ' (PILOTO: solo el framework)' : ''}`)

const glos = await agent(
  `Lee el registro de IDs normativos del ecosistema Corpus: corpus/docs/ids.yaml

${JERARQUIA}

TU TRABAJO, en dos partes:

1. GLOSARIO. Devolve una entrada por cada ID del bloque \`ids:\` con su \`titulo\` y su \`sede\`.
   Este glosario viaja a todos los lectores de la fase siguiente para que normalicen
   vocabulario y no inventen significados. Se exhaustivo: son ~184 IDs.
   ${PILOTO ? 'MODO PILOTO: alcanza con las familias COR, FLU y GIT (el piloto solo audita los docs del framework).' : ''}

2. DIVERGENCIAS. Para las entradas de las familias ${PILOTO ? 'COR y FLU' : 'COR, FLU y GIT'}, ABRI la sede y compara:
   ¿el \`titulo\` del yaml dice lo MISMO que la prosa de su sede?
   - El yaml es INDICE, jamas segunda definicion. Si divergen, el YAML esta desactualizado
     (no se litiga contra el doc): es un hallazgo, y va en \`divergencias\`.
   - No reportes diferencias de redaccion: solo divergencias de SIGNIFICADO.
   - NO es tu trabajo buscar huerfanos, bicefalos ni sedes rotas: eso ya lo prueba el
     checker determinista (.claude/check-ids/), que corre en cada commit y esta en verde.
     No lo repitas.`,
  { label: 'glosario:ids.yaml', phase: 'Glosario', schema: GLOSARIO_SCHEMA }
)

const ENTRADAS = (glos && glos.entradas) || []
const DIVERGENCIAS = (glos && glos.divergencias) || []
log(`Glosario: ${ENTRADAS.length} IDs leidos del registro - ${DIVERGENCIAS.length} divergencia(s) yaml-vs-sede`)

const GLOSARIO = ENTRADAS
  .map(d => `${d.id} (${d.sede}): ${d.titulo}`)
  .join('\n')
  .slice(0, 14000)

// ─────────────────────────────────────────────────────────────────────────────
// FASE 2 - Lectura: un agente por tramo.
// BARRERA REAL: el cruce necesita todas las afirmaciones juntas para agruparlas.
// ─────────────────────────────────────────────────────────────────────────────
phase('Lectura')

const lecturas = await parallel(TRAMOS.map(t => () => agent(
  `Lee ${t.file} lineas ${t.desde}-${t.hasta} y extrae TODA afirmacion normativa, con archivo:linea.

${JERARQUIA}

GLOSARIO DE IDS DEL REGISTRO (usa este vocabulario; no inventes significados):
${GLOSARIO || '(vacio)'}

QUE ES UNA AFIRMACION NORMATIVA:
  Una regla que el sistema DEBE cumplir. "Ningun modulo asume que Corpus ya cargo".
  "Las defs y su onUse van en shared". "Coagulant nunca pisa SetWalkSpeed".
  NO son normativas: la prosa de motivacion, los ejemplos, la historia de por que se
  decidio algo. Marcalas igual pero con fuerza=DESCRIPTIVA o EJEMPLO.

REGLAS DE EXTRACCION (las dos que hacen o rompen esta auditoria):
  · AUTOCONTENIDA. Otro agente leera tu afirmacion SIN abrir el doc. Nada de "esto",
    "dicho modulo", "como se vio arriba". Nombra los sujetos completos.
  · ALCANCE EXPLICITO, siempre, en los cuatro ejes: REALM (server/client/shared),
    MODULO, SOFT-DEP (con o sin el peer), BLOCK/SLICE. El 90% de los falsos positivos
    de esta auditoria nacen de comparar dos afirmaciones de ALCANCE DISTINTO. Si el doc
    no declara el alcance, escribi "no especificado" - eso EN SI MISMO es un hallazgo.

Y marca \`sinId\`: si la afirmacion es NORMATIVA (siempre/nunca/debe/jamas) y no define ni
cita ningun ID del glosario, viola FLU-25 ("una norma sin ID es una norma que va a derivar")
y es un hallazgo por si mismo, aunque no choque con nada.

Se exhaustivo: es preferible una afirmacion de mas que una regla perdida.`,
  { label: `lee:${t.label}`, phase: 'Lectura', schema: LECTURA_SCHEMA }
)))

// COBERTURA PERDIDA - no se descarta en silencio. [Agregado tras el piloto 2026-07-16.]
// Un agente puede morir (error de API, clasificador, timeout) y `filter(Boolean)` lo
// tira sin dejar rastro: el acta despues reporta "auditamos 4 docs" y nadie sabe que
// uno volvio vacio. Eso es un falso-limpio por omision -- el modo de falla exacto de
// la seccion 10.8, cometido por el gate que existe para prevenirlo. Se cuenta y viaja
// hasta el acta.
const TRAMOS_CAIDOS = TRAMOS.filter((_, i) => !lecturas[i])
if (TRAMOS_CAIDOS.length) {
  log(`AVISO: ${TRAMOS_CAIDOS.length} tramo(s) NO se leyeron (agente caido): ${TRAMOS_CAIDOS.map(t => t.label).join(', ')} - su "limpio" no vale`)
}

const AFIRMACIONES = lecturas.filter(Boolean).flatMap(l => l.afirmaciones || [])
const NORMATIVAS = AFIRMACIONES.filter(a => a.fuerza === 'NORMATIVA')
const SIN_ID = NORMATIVAS.filter(a => a.sinId)
log(`Lectura: ${AFIRMACIONES.length} afirmaciones - ${NORMATIVAS.length} normativas - ${SIN_ID.length} normativas SIN ID (violan FLU-25)`)

// ─────────────────────────────────────────────────────────────────────────────
// FASE 3+4 - Cruce por tema -> Adjudicacion, en PIPELINE.
// Cada tema adjudica apenas termina su cruce; no espera a los otros.
// ─────────────────────────────────────────────────────────────────────────────
phase('Cruce')

const porTema = await pipeline(
  TEMAS,

  // Etapa A - cruce dentro del tema.
  // `sinClaims: true` distingue "el tema no tenia nada que cruzar" de "el agente murio":
  // sin eso, los dos casos son un objeto vacio y el tema caido pasa por tema limpio.
  (tema) => {
    const claims = NORMATIVAS.filter(a => a.tema === tema.key)
    if (claims.length < 2) return { candidatas: [], sinClaims: true }
    return agent(
      `Busca CONTRADICCIONES entre docs en el tema "${tema.key}" (${tema.desc}).

${JERARQUIA}

Estas son TODAS las afirmaciones normativas que los ${CORPUS.length} docs auditados hacen
sobre este tema, cada una con su archivo:linea y su alcance declarado:

${JSON.stringify(claims, null, 1)}

TU TRABAJO: encontrar pares MUTUAMENTE INCOMPATIBLES.

Antes de emitir cada par, aplica este filtro y descarta si falla ALGUNO:
  1. ¿Coincide el ALCANCE de ambas, en los cuatro ejes (realm, modulo, soft-dep, slice)?
     Si difieren, NO es contradiccion - es especializacion. Descarta.
  2. ¿Son realmente incompatibles, o es la misma regla redactada distinto? Descarta redacciones.
  3. ¿Podrian ser ambas verdaderas a la vez? Si si, no es contradiccion. Descarta.
  4. ¿Una es solo mas detallada que la otra? Eso es refinamiento, no choque. Descarta.
  5. ¿Una describe el camino CON un soft-dep y la otra SIN el? Eso es degradacion honesta
     (COR-11), el patron de produccion del ecosistema. Descarta.

Prefiero 3 contradicciones reales que 30 candidatas de las cuales 27 son ruido.
Si el tema esta limpio, devolve lista vacia - es un resultado perfectamente valido.

GRAVEDAD: BLOQUEANTE = construir siguiendo un doc rompe lo que el otro exige (romper un
contrato COR-nn, un invariante de datos, o la degradacion honesta de un soft-dep).
BAJA = inconsistencia cosmetica o de nombres.`,
      { label: `cruce:${tema.key}`, phase: 'Cruce', schema: CRUCE_SCHEMA }
    )
  },

  // Etapa B - adjudicacion adversarial de cada candidata (3 lentes distintas)
  (cruce, tema) => {
    // El agente de cruce murio: el tema NO se cruzo. No es un tema limpio -- es un
    // tema no auditado, y tiene que llegar al acta como tal.
    if (!cruce) return [{ __temaCaido: tema.key }]
    const cands = cruce.candidatas || []
    if (!cands.length) return []
    return parallel(cands.map(c => () => {
      const CASO = `
CONTRADICCION CANDIDATA (tema: ${tema.key}, gravedad alegada: ${c.gravedad})

  AFIRMACION A - ${c.refA}
    "${c.afirmacionA}"

  AFIRMACION B - ${c.refB}
    "${c.afirmacionB}"

  Por que se alega que chocan: ${c.porQueChocan}
`.trim()

      const LENTES = [
        {
          key: 'refutador',
          prompt: `Tu trabajo es REFUTAR esta contradiccion. Empezas asumiendo que es FALSA y que el
otro agente se equivoco.

${CASO}

${JERARQUIA}

ABRI LOS DOS DOCS y lee cada pasaje EN SU CONTEXTO (mas o menos 40 lineas alrededor). Casi
siempre la "contradiccion" se disuelve al leer el parrafo completo: alcances distintos, una
es un ejemplo, una fue derogada y el doc lo dice tres lineas mas abajo, una habla del camino
sin el soft-dep, o son sinonimos.

Solo si tras leer ambos contextos completos siguen siendo MUTUAMENTE IMPOSIBLES, admiti
esContradiccionReal=true. Ante la duda: FALSE.`,
        },
        {
          key: 'arbitro-codigo',
          prompt: `Sos el arbitro que consulta la VERDAD FINAL: el codigo Lua.

${CASO}

${JERARQUIA}

Anda al arbol y averigua cual de las dos afirmaciones describe la realidad. Busca en el
lua/ de las siete raices, en los defs, y en los CLAUDE.md. Usa Grep/Glob/Read con generosidad.

DOS SALIDAS POSIBLES Y SOLO DOS:
  · Encontras Lua que decide -> ganador=A o B, y evidencia CON archivo:linea del codigo.
  · El codigo aun no existe (mucho de este diseno va por delante, y Cortex esta vacio)
    -> ganador=INDETERMINADO. Eso NO es un fracaso: es informacion.

NUNCA inventes evidencia. Si no citas archivo:linea real, tu ganador es INDETERMINADO.
Ojo: que el codigo no exista NO convierte la contradiccion en falsa. Dos docs pueden
contradecirse perfectamente sobre algo que aun no se construyo - sigue siendo un hallazgo
(esContradiccionReal puede ser true con ganador INDETERMINADO). En este ecosistema eso es
FRECUENTE y tiene nombre: es el corolario de la seccion 7.1 (una afirmacion sobre algo NO
CONSTRUIDO no tiene arbitro) y va a VOTO del autor, no a parche.`,
        },
        {
          key: 'arbitro-historia',
          prompt: `Sos el arbitro que consulta la HISTORIA: ¿una de las dos ya fue derogada?

${CASO}

${JERARQUIA}

Busca en los docs/CHANGELOG.md de las siete raices, en los <modulo>_estado.md, y en
corpus/docs/auditorias/. Pregunta clave: ¿hubo una entrada [APLICADO] que resolvio esto y
uno de los dos docs simplemente no se actualizo? Ese es el patron de deriva mas comun de
este ecosistema - la pasada de veracidad del 2026-07-14 tuvo que limpiar exactamente eso.

Busca por los IDs implicados, por las palabras clave del tema, y por fecha: la afirmacion
MAS NUEVA que haya sido aplicada gana sobre la mas vieja que nadie toco. Ojo tambien con
los reportes de planilla: un check en FALLA que se arreglo deroga lo que el doc prometia.

Si encontras la ratificacion -> ganador = el lado que coincide, evidencia = CHANGELOG:linea.
Si no hay rastro -> INDETERMINADO.`,
        },
      ]

      return parallel(LENTES.map(l => () => agent(l.prompt, {
        label: `${l.key}:${c.refA.split('/').pop()}`,
        phase: 'Adjudicacion',
        schema: VEREDICTO_SCHEMA,
      }))).then(veredictos => {
        const vs = veredictos.filter(Boolean)
        const votosReal = vs.filter(v => v.esContradiccionReal).length
        // Sobrevive por MAYORIA (>=2 de 3). El refutador solo no puede matarla,
        // pero si los tres dudan, muere.
        const confirmada = votosReal >= 2
        const decisivo = vs.find(v => v.ganador === 'A' || v.ganador === 'B')
        return {
          ...c,
          tema: tema.key,
          confirmada,
          votosReal,
          ganador: decisivo ? decisivo.ganador : 'INDETERMINADO',
          evidencia: decisivo ? decisivo.evidencia : vs.map(v => v.evidencia).filter(Boolean).join(' | '),
          correccion: decisivo ? decisivo.correccion : '',
          veredictos: vs,
        }
      })
    }))
  }
)

// La deteccion va POR INDICE contra TEMAS, y ANTES de filtrar. [Corregido 2026-07-16,
// corrida _v3.] El detector anterior vivia en la etapa B del pipeline y no servia para
// nada: un agente BLOQUEADO hace throw, un stage que throwea tira el item entero a null
// y SALTEA los stages siguientes -- asi que la etapa B jamas corria, y el filter(Boolean)
// de abajo borraba la evidencia antes de mirarla. La _v3 reporto `degradada: false` con
// DOS temas sin cruzar: el detector de falsos-limpios emitiendo un falso-limpio.
// Se cubren los dos caminos: el item tirado a null (throw) y el marcador de la etapa B
// (por si agent() devuelve null sin throwear).
const TEMAS_CAIDOS = [
  ...TEMAS.filter((_, i) => !porTema[i]).map(t => t.key),
  ...porTema.filter(Boolean).flat().filter(f => f && f.__temaCaido).map(f => f.__temaCaido),
]
const CRUDO = porTema.filter(Boolean).flat()
const TODAS = CRUDO.filter(f => f && !f.__temaCaido)
const CONFIRMADAS = TODAS.filter(f => f.confirmada)
log(`Adjudicacion: ${TODAS.length} candidatas -> ${CONFIRMADAS.length} confirmadas (${TODAS.length - CONFIRMADAS.length} refutadas)`)
if (TEMAS_CAIDOS.length) {
  log(`AVISO: ${TEMAS_CAIDOS.length} tema(s) NO se cruzaron (agente caido): ${TEMAS_CAIDOS.join(', ')} - no estan limpios, estan sin auditar`)
}

// La cobertura perdida viaja al acta. Si esto queda vacio, la cobertura fue completa;
// si no, el acta tiene que DECIRLO en su seccion de huecos, no maquillarlo.
const COBERTURA_PERDIDA = [
  ...TRAMOS_CAIDOS.map(t => `tramo NO leido: ${t.file} lineas ${t.desde}-${t.hasta}`),
  ...TEMAS_CAIDOS.map(t => `tema NO cruzado: ${t}`),
]

// ─────────────────────────────────────────────────────────────────────────────
// FASE 5 - Critico de completitud. Lo que encuentre se convierte en trabajo.
// ─────────────────────────────────────────────────────────────────────────────
phase('Completitud')

const SIN_ALCANCE = AFIRMACIONES.filter(a => /no especificado/i.test(a.alcance || ''))

const critica = await agent(
  `Sos el critico de completitud de esta auditoria. Tu trabajo NO es revisar los hallazgos:
es encontrar QUE SE NOS ESCAPO.

Lo que se cubrio:
  · Docs auditados (${CORPUS.length}): ${CORPUS.map(d => d.file).join(', ')}
  · Temas cruzados (${TEMAS.length}): ${TEMAS.map(t => t.key).join(', ')}
  · ${AFIRMACIONES.length} afirmaciones extraidas, ${NORMATIVAS.length} normativas
  · ${TODAS.length} contradicciones candidatas, ${CONFIRMADAS.length} confirmadas
  · ${SIN_ID.length} normativas SIN ID (violan FLU-25)
  · ${DIVERGENCIAS.length} divergencias entre el titulo del yaml y la prosa de su sede
  · ${SIN_ALCANCE.length} afirmaciones cuyo ALCANCE el doc nunca declara
${PILOTO ? '  · MODO PILOTO: solo se auditaron los docs del FRAMEWORK. Los de modulo quedaron fuera a proposito (alcance acotado del modo piloto).' : ''}

Contradicciones confirmadas:
${JSON.stringify(CONFIRMADAS.map(f => ({ tema: f.tema, refA: f.refA, refB: f.refB, resumen: f.porQueChocan })), null, 1)}

PREGUNTAS QUE DEBES RESPONDER, yendo al arbol a mirar:
  1. ¿Algun doc de diseno de las siete raices quedo FUERA del corpus y deberia estar?
     (lista los docs/ de cada raiz y compara contra la lista de arriba)
  2. ¿Hay algun tema transversal que la taxonomia de ${TEMAS.length} buckets no captura, y por
     tanto sus contradicciones nunca se buscaron? Nombralo.
  3. Un tema con CERO contradicciones, ¿esta limpio de verdad o nadie lo miro bien?
     Señala los sospechosos.
  4. ¿Hay docs que se contradicen con un CLAUDE.md (los contratos no negociables) y que este
     cruce, al comparar solo doc-vs-doc, no podia ver? Revisa los contratos uno por uno.
  5. LA PREGUNTA DE LA SECCION 10.8: ¿cuantos de los docs auditados NO declaran ningun ID
     propio? Para un gate que cruza IDs, un doc sin IDs es un punto ciego perfecto: un
     "limpio" sobre el no es evidencia de nada - es "no auditado". Contalos y nombralos,
     y decilo con todas las letras en tu respuesta.

Devolve prosa: los huecos concretos, priorizados, cada uno con que habria que hacer para taparlo.`,
  { label: 'critico', phase: 'Completitud' }
)

// ─────────────────────────────────────────────────────────────────────────────
// FASE 6 - Sintesis
// ─────────────────────────────────────────────────────────────────────────────
phase('Sintesis')

await agent(
  `Escribe el acta final de la auditoria de coherencia documental en:
    ${DESTINO}
(ruta EXACTA).

${JERARQUIA}

Las actas son INMUTABLES: son la foto del estado AL MOMENTO DE AUDITAR, no la foto de hoy.
No se editan despues. Toda afirmacion con evidencia archivo:linea. Cero adjetivos sin respaldo.

MATERIAL:

## Contradicciones CONFIRMADAS (${CONFIRMADAS.length}) - sobrevivieron a 3 verificadores adversariales
${JSON.stringify(CONFIRMADAS, null, 1)}

## Divergencias yaml-vs-sede (${DIVERGENCIAS.length}) - el registro dice una cosa y su sede otra
${JSON.stringify(DIVERGENCIAS, null, 1)}

## Normativas SIN ID (${SIN_ID.length}) - violan FLU-25: una norma sin ID va a derivar
${JSON.stringify(SIN_ID.slice(0, 60), null, 1)}

## Afirmaciones sin alcance declarado (${SIN_ALCANCE.length}) - ambiguedad latente
${JSON.stringify(SIN_ALCANCE.slice(0, 40), null, 1)}

## COBERTURA PERDIDA (${COBERTURA_PERDIDA.length}) - agentes que murieron y NO auditaron su parte
${COBERTURA_PERDIDA.length ? JSON.stringify(COBERTURA_PERDIDA, null, 1) : '(ninguna: la cobertura fue completa)'}

## Critica de completitud
${critica || '(sin critica)'}

ESTRUCTURA DEL ACTA:
  1. Resumen ejecutivo: los hallazgos que CAMBIAN EL PLAN primero. Si construir segun el doc X
     rompe un contrato del doc Y, eso va arriba de todo, con nombre y apellido.
  2. Contradicciones por gravedad (BLOQUEANTE -> BAJA). Cada una: las dos afirmaciones con su
     archivo:linea, quien gana segun la jerarquia de autoridad, la evidencia que lo decide,
     y el parche PROPUESTO al doc perdedor.
     TRIAGE, marca cada hallazgo con su bucket:
       A - REPARABLE: el ganador esta decidido por el Lua, el estado o el CHANGELOG. Se parcha.
       B - VOTO DEL AUTOR: los docs chocan y el codigo NO dirime (seccion 7.1, corolario).
           NO se parcha: se consolida como voto abierto, con las dos posiciones, que depende
           de cada una, y una recomendacion de ingenieria.
       C - BUG DE CODIGO: el doc tiene razon y el Lua esta mal. Va a pasada aparte.
       CADUCO: la frase citada ya no existe.
  3. Patologia del registro: divergencias yaml-vs-sede, y normativas sin ID.
  4. Ambiguedades de alcance.
  5. Huecos de esta auditoria (de la critica de completitud) - honestidad sobre lo NO cubierto.
     Si algun doc auditado no tiene IDs propios, DECILO ACA con todas las letras: sobre ese
     doc este gate es ciego, y su "limpio" significa "no auditado", no "sano".
     Y si la lista de COBERTURA PERDIDA de arriba NO esta vacia, ABRI esta seccion con eso,
     en negrita: hubo tramos o temas que ningun agente audito porque su agente murio. Ese
     resultado NO es un limpio parcial: es un no-auditado, y el acta entera debe declararse
     DEGRADADA en su encabezado. Nunca lo maquilles ni lo omitas.
  6. Que NO se auditó y por que: doc-vs-codigo queda fuera del alcance; este acta NO afirma
     que nada este implementado. Los huerfanos, bicefalos y sedes rotas tampoco son de este
     gate: los prueba el checker determinista (.claude/check-ids/), que corre en cada commit.
${PILOTO ? '  7. MODO PILOTO: declara que solo se audito el framework y por que (alcance acotado del piloto).' : ''}

REGLA DURA: el UNICO archivo que escribis en todo el universo es ${DESTINO}.
Ningun doc de arquitectura, ningun README, ningun ids.yaml, ningun archivo de los siete repos.
Los parches se PROPONEN dentro del acta, no se aplican.

Devolve un resumen de 10 lineas de lo que encontraste.`,
  { label: 'acta', phase: 'Sintesis' }
)

return {
  destino: DESTINO,
  piloto: PILOTO,
  // degradada: hubo cobertura perdida. Un acta degradada es una HIPOTESIS, no un cierre.
  degradada: COBERTURA_PERDIDA.length > 0,
  coberturaPerdida: COBERTURA_PERDIDA,
  docsAuditados: CORPUS.length,
  tramos: TRAMOS.length,
  afirmaciones: AFIRMACIONES.length,
  normativas: NORMATIVAS.length,
  sinId: SIN_ID.length,
  divergenciasRegistro: DIVERGENCIAS.length,
  candidatas: TODAS.length,
  confirmadas: CONFIRMADAS.length,
  bloqueantes: CONFIRMADAS.filter(f => f.gravedad === 'BLOQUEANTE').length,
}
