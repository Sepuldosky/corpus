#Requires -Version 5.1
<#
.SYNOPSIS
    Regenera el bundle Code->Desktop (.claude/desktop-sync/): copia los docs vivos del
    framework al bundle y regenera _SYNC_INDEX.md anclado al HEAD actual del repo.

.DESCRIPTION
    Destino fisico del seam Code<->Desktop (ver docs/corpus_flujo_trabajo.txt sec. 6).
    El bundle es un snapshot REGENERABLE, no fuente de verdad: refleja el working tree
    (no HEAD), se sobrescribe en cada corrida, y esta gitignoreado salvo README + este
    script. Tras correrlo, arrastra el contenido de la carpeta al Project "Corpus
    Framework" en Claude Desktop para refrescar el RAG.

    NOTA: este archivo se mantiene en ASCII puro a proposito. Windows PowerShell 5.1 lee
    los .ps1 sin BOM como ANSI (no UTF-8): cualquier caracter no-ASCII en un string literal
    rompe el parser. Los glifos Unicode del indice (p.ej. el signo de seccion) se emiten
    via codigo de caracter, no como literales en la fuente.

.PARAMETER Purpose
    Frase que describe para que es este bundle (se escribe en el indice). Ej:
    "sembrar la sesion de diseno de Cargo (Block 4)". Si se omite, usa un texto generico
    de re-sincronizacion.

.EXAMPLE
    .\.claude\desktop-sync\sync.ps1 -Purpose "sembrar la sesion de diseno de Cargo (Block 4)"

.EXAMPLE
    .\.claude\desktop-sync\sync.ps1
#>
[CmdletBinding()]
param(
    [string]$Purpose = "re-sincronizar el RAG de Desktop con la foto actual del framework"
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Nombre del Project en Claude Desktop donde vive el RAG del ecosistema.
$DesktopProject = "Corpus Framework"

# Glifos para el OUTPUT (el indice se escribe en UTF-8): backtick para code-spans y el
# signo de seccion. Se construyen por codigo para no meter no-ASCII en esta fuente.
$bt  = '`'
$sec = [char]0x00A7

# --- Rutas: el script vive en <repo>/.claude/desktop-sync/ ---
$BundleDir = $PSScriptRoot
$RepoRoot  = (Resolve-Path (Join-Path $BundleDir '..\..')).Path

Push-Location $RepoRoot
try {
    $null = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0) { throw "No es un repositorio git: $RepoRoot" }

    # --- Fuentes: ruta repo-relativa -> nombre en el bundle + descripcion para el indice ---
    $Sources = @(
        [pscustomobject]@{ Src = 'docs/corpus_estado.md';                Dst = 'corpus_estado.md';                Desc = "foto de HOY del framework" }
        [pscustomobject]@{ Src = 'docs/corpus_roadmap.txt';              Dst = 'corpus_roadmap.txt';              Desc = "rumbo / orden de bloques (Cargo = Block 4)" }
        [pscustomobject]@{ Src = 'docs/CHANGELOG.md';                    Dst = 'CHANGELOG.md';                    Desc = "historial de parches del framework" }
        [pscustomobject]@{ Src = 'docs/corpus_flujo_trabajo.txt';        Dst = 'corpus_flujo_trabajo.txt';        Desc = "metodologia canonica del ecosistema (incl. ${sec}6 seam Code<->Desktop)" }
        [pscustomobject]@{ Src = 'docs/CORPUS_Architecture.md';          Dst = 'CORPUS_Architecture.md';          Desc = "diseno general; ${sec}5 = contrato de items (frontera Cargo)" }
        [pscustomobject]@{ Src = 'docs/corpus_convenciones_commits.txt'; Dst = 'corpus_convenciones_commits.txt'; Desc = "convenciones de commit del framework" }
        [pscustomobject]@{ Src = 'CLAUDE.md';                            Dst = 'CLAUDE.md';                       Desc = "contratos no-negociables del framework" }
    )

    # --- Metadata de git ---
    $Sha     = (git rev-parse --short HEAD).Trim()
    $Subject = (git log -1 --format=%s).Trim()
    $CDate   = (git log -1 --format=%cd --date=short).Trim()
    $Branch  = (git rev-parse --abbrev-ref HEAD).Trim()
    $Today   = Get-Date -Format 'yyyy-MM-dd'

    # --- Copiar cada fuente + detectar deltas sin commitear respecto de HEAD ---
    $Deltas = @()
    foreach ($s in $Sources) {
        $srcPath = Join-Path $RepoRoot $s.Src
        if (-not (Test-Path -LiteralPath $srcPath)) { throw "Falta el archivo fuente: $($s.Src)" }
        Copy-Item -LiteralPath $srcPath -Destination (Join-Path $BundleDir $s.Dst) -Force

        $numstat = (git diff --numstat HEAD -- $s.Src)
        if ($numstat) {
            $parts = ([string]$numstat) -split "`t"
            $Deltas += [pscustomobject]@{ Name = $s.Dst; Add = $parts[0]; Del = $parts[1] }
        }
    }

    # --- Construir _SYNC_INDEX.md ---
    $L = New-Object System.Collections.Generic.List[string]
    $L.Add("# _SYNC_INDEX - bundle Code->Desktop")
    $L.Add("")
    $L.Add("> Generado por ${bt}sync.ps1${bt} el $Today. Snapshot regenerable, no fuente de verdad")
    $L.Add("> (ver ${bt}docs/corpus_flujo_trabajo.txt ${sec}6${bt}). Se sobrescribe en cada corrida;")
    $L.Add("> refleja el working tree, no HEAD.")
    $L.Add("")
    $L.Add("- **Project Desktop destino:** ${bt}$DesktopProject${bt}")
    $L.Add("- **SHA de HEAD:** ${bt}$Sha${bt} ($Subject, $CDate)")
    if ($Branch -ne 'main') {
        $L.Add("- **Rama:** $Branch  (ATENCION: no es main, el bundle refleja esta rama)")
    } else {
        $L.Add("- **Rama:** main")
    }
    $L.Add("- **Fecha del bundle:** $Today")
    $L.Add("- **Proposito:** $Purpose")
    $L.Add("")
    $L.Add("## Archivos del bundle")
    $L.Add("")
    foreach ($s in $Sources) { $L.Add("- ${bt}$($s.Dst)${bt} - $($s.Desc)") }
    $L.Add("")
    $L.Add("## Deltas sin commitear respecto de HEAD")
    $L.Add("")
    $L.Add("El snapshot refleja el working tree, no HEAD. Diferencias:")
    $L.Add("")
    if ($Deltas.Count -eq 0) {
        $L.Add("- Ninguno - los docs del bundle coinciden con HEAD.")
    } else {
        foreach ($d in $Deltas) { $L.Add("- ${bt}$($d.Name)${bt} - +$($d.Add)/-$($d.Del) lineas sin commitear (revisar con git diff)") }
    }
    $L.Add("")
    $L.Add("## Contexto adicional NO incluido en el bundle")
    $L.Add("")
    $L.Add("- ${bt}dev/mods_workshop_mapa.md${bt} - mapa de mods de terceros (ARC9, VJ Base, etc.)")
    $L.Add("  para decidir compat de items/armas. Vive fuera de git (${bt}dev/${bt}, nunca se")
    $L.Add("  publica); cargarlo aparte en Desktop si la sesion entra en compat de armas.")
    $L.Add("- Los repos hermanos aun no tienen docs de diseno propios salvo Caliber; Cargo no")
    $L.Add("  depende de ninguno (hoja en el grafo, ${sec}2), asi que el contexto de framework")
    $L.Add("  alcanza para abrir su diseno.")
    $L.Add("")
    $L.Add("## Como usarlo")
    $L.Add("")
    $L.Add("Arrastra el contenido de esta carpeta al Project ${bt}$DesktopProject${bt} en Claude")
    $L.Add("Desktop, reemplazando las versiones previas. Incluir este ${bt}_SYNC_INDEX.md${bt} le")
    $L.Add("dice a Desktop a que SHA esta anclado. Regenerar con")
    $L.Add("${bt}.\.claude\desktop-sync\sync.ps1${bt}.")

    $IndexPath = Join-Path $BundleDir '_SYNC_INDEX.md'
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($IndexPath, (($L -join "`r`n") + "`r`n"), $utf8NoBom)

    # --- Resumen en consola ---
    Write-Host ""
    Write-Host "Bundle Code->Desktop regenerado" -ForegroundColor Green
    Write-Host "  Carpeta : $BundleDir"
    Write-Host "  Project : $DesktopProject (Claude Desktop)"
    Write-Host "  HEAD    : $Sha ($Branch) - $Subject"
    Write-Host "  Docs    : $($Sources.Count) copiados + _SYNC_INDEX.md"
    if ($Deltas.Count -eq 0) {
        Write-Host "  Deltas  : ninguno (working tree = HEAD)"
    } else {
        Write-Host "  Deltas  : $($Deltas.Count) archivo(s) con cambios sin commitear:" -ForegroundColor Yellow
        foreach ($d in $Deltas) { Write-Host "            - $($d.Name)  (+$($d.Add)/-$($d.Del))" -ForegroundColor Yellow }
    }
    Write-Host "  Proposito: $Purpose"
    Write-Host ""
    Write-Host "Siguiente: arrastra el contenido de la carpeta al Project '$DesktopProject'." -ForegroundColor Cyan
}
finally {
    Pop-Location
}
