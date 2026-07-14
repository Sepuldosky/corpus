#Requires -Version 5.1
<#
.SYNOPSIS
    Regenera el espejo Code->Desktop (.claude/desktop-sync/): agrega TODOS los docs de
    todos los repos del ecosistema en una carpeta plana, con prefijo <Modulo>_ por archivo,
    y regenera _SYNC_INDEX.md.

.DESCRIPTION
    Destino fisico del seam Code<->Desktop (ver docs/corpus_flujo_trabajo.txt sec. 6). NO es
    un bundle-delta: es el ESPEJO COMPLETO del contexto que el Project "Corpus Framework" de
    Claude Desktop debe contener. El flujo del autor es "borrar y reemplazar": vaciar el
    Project y soltar el contenido de esta carpeta.

    Recorre las siete raices de repo del workspace (corpus + los cinco modulos + corpus-stalker,
    el addon de CONTENIDO de la Zona); incluye las que ya tienen docs y salta las vacias. Cada
    archivo se copia con prefijo <Modulo>_ para declarar su origen y evitar colisiones (p.ej.
    Corpus_CHANGELOG.md vs Cargo_CHANGELOG.md). Las raices que aun no tienen docs (hoy: Cortex)
    se sumaran solas cuando los reciban, sin editar el helper.

    NOTA: este archivo se mantiene en ASCII puro a proposito. Windows PowerShell 5.1 lee los
    .ps1 sin BOM como ANSI (no UTF-8): cualquier caracter no-ASCII en un string literal rompe
    el parser. Los docs se copian byte-por-byte (conservan sus acentos); solo el texto que el
    script GENERA (el indice) va sin acentos, y el signo de seccion se emite por codigo.

.PARAMETER Purpose
    Nota opcional de la tanda, se escribe en el indice. Si se omite usa un texto generico.

.EXAMPLE
    .\.claude\desktop-sync\sync.ps1

.EXAMPLE
    .\.claude\desktop-sync\sync.ps1 -Purpose "refrescar el contexto para la sesion de Cargo"
#>
[CmdletBinding()]
param(
    [string]$Purpose = "espejo completo del contexto del ecosistema para el Project de Desktop"
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$DesktopProject = "Corpus Framework"
$bt  = '`'
$sec = [char]0x00A7

# --- Rutas: el script vive en <workspace>/corpus/.claude/desktop-sync/ ---
$BundleDir     = $PSScriptRoot
$RepoRoot      = (Resolve-Path (Join-Path $BundleDir '..\..')).Path
$WorkspaceRoot = (Resolve-Path (Join-Path $RepoRoot '..')).Path

# --- Repos del ecosistema: etiqueta -> carpeta relativa al workspace ---
# Las seis primeras son framework + modulos. La septima, Stalker, NO es un modulo: es el
# addon de CONTENIDO de la Zona (consumidor puro). Entra al espejo igual, porque Desktop
# necesita su manifiesto de assets y sus contratos para disenar defs de item contra el.
$Repos = @(
    [pscustomobject]@{ Module = 'Corpus';    Path = 'corpus' }
    [pscustomobject]@{ Module = 'Cortex';    Path = 'corpus-cortex' }
    [pscustomobject]@{ Module = 'Caliber';   Path = 'corpus-caliber' }
    [pscustomobject]@{ Module = 'Coagulant'; Path = 'corpus-coagulant' }
    [pscustomobject]@{ Module = 'Craving';   Path = 'corpus-craving' }
    [pscustomobject]@{ Module = 'Cargo';     Path = 'corpus-cargo' }
    [pscustomobject]@{ Module = 'Stalker';   Path = 'corpus-stalker' }
)

# Normaliza el nombre destino a "<Module>_<resto>" sin duplicar el prefijo si ya lo trae.
function Get-BundleName {
    param([string]$FileName, [string]$Module)
    $prefix = "${Module}_"
    if ($FileName.Length -ge $prefix.Length -and
        $FileName.Substring(0, $prefix.Length).ToLower() -eq $prefix.ToLower()) {
        return $prefix + $FileName.Substring($prefix.Length)
    }
    return $prefix + $FileName
}

# --- Limpieza: el espejo se regenera entero. Borra todo menos README.md y sync.ps1. ---
Get-ChildItem -LiteralPath $BundleDir -File |
    Where-Object { $_.Name -ne 'README.md' -and $_.Name -ne 'sync.ps1' } |
    Remove-Item -Force

# --- Recorrer repos, copiar docs con prefijo, juntar metadata ---
$Included = @()
foreach ($repo in $Repos) {
    $repoPath   = Join-Path $WorkspaceRoot $repo.Path
    if (-not (Test-Path -LiteralPath $repoPath)) { continue }
    $docsPath   = Join-Path $repoPath 'docs'
    $claudePath = Join-Path $repoPath 'CLAUDE.md'
    $hasDocs    = Test-Path -LiteralPath $docsPath
    $hasClaude  = Test-Path -LiteralPath $claudePath
    if (-not $hasDocs -and -not $hasClaude) { continue }

    # Metadata git del repo (cada uno es un git independiente).
    Push-Location $repoPath
    try {
        $sha = (git rev-parse --short HEAD 2>$null)
        if ($LASTEXITCODE -ne 0 -or -not $sha) {
            $sha = $null; $subj = 'sin commits (solo working tree)'; $dirty = $true
        } else {
            $sha  = ([string]$sha).Trim()
            $subj = ([string](git log -1 --format=%s 2>$null)).Trim()
            $dirty = [bool](git status --porcelain 2>$null)
        }
    } finally { Pop-Location }

    $files = @()
    if ($hasClaude) {
        $dst = Get-BundleName -FileName 'CLAUDE.md' -Module $repo.Module
        Copy-Item -LiteralPath $claudePath -Destination (Join-Path $BundleDir $dst) -Force
        $files += $dst
    }
    $skipped = @()
    if ($hasDocs) {
        Get-ChildItem -LiteralPath $docsPath | Sort-Object Name | ForEach-Object {
            if ($_.PSIsContainer) { $skipped += $_.Name; return }
            $dst = Get-BundleName -FileName $_.Name -Module $repo.Module
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $BundleDir $dst) -Force
            $files += $dst
        }
    }

    $Included += [pscustomobject]@{
        Module = $repo.Module; Repo = $repo.Path; Sha = $sha
        Subject = $subj; Dirty = $dirty; Files = $files; Skipped = $skipped
    }
}

$includedModules = @($Included | ForEach-Object { $_.Module })
$pending = @($Repos | Where-Object { $includedModules -notcontains $_.Module })
$Today   = Get-Date -Format 'yyyy-MM-dd'
$totalFiles = ($Included | ForEach-Object { $_.Files.Count } | Measure-Object -Sum).Sum

# --- Construir _SYNC_INDEX.md ---
$L = New-Object System.Collections.Generic.List[string]
$L.Add("# _SYNC_INDEX - espejo Code->Desktop (Project ${bt}$DesktopProject${bt})")
$L.Add("")
$L.Add("> Generado por ${bt}sync.ps1${bt} el $Today. ESPEJO COMPLETO del contexto del")
$L.Add("> ecosistema: esta carpeta reemplaza integramente los archivos del Project en Claude")
$L.Add("> Desktop. Regenerable, no fuente de verdad; se sobrescribe entero en cada corrida.")
$L.Add("")
$L.Add("- **Project Desktop destino:** ${bt}$DesktopProject${bt}")
$L.Add("- **Fecha del espejo:** $Today")
$L.Add("- **Proposito:** $Purpose")
$L.Add("- **Archivos:** $totalFiles docs de $($Included.Count) repo(s)")
$L.Add("- **Convencion de nombres:** cada archivo lleva prefijo ${bt}<Modulo>_${bt} para")
$L.Add("  declarar su repo de origen y evitar colisiones (${bt}Corpus_CHANGELOG.md${bt} vs")
$L.Add("  ${bt}Cargo_CHANGELOG.md${bt}, etc.).")
$L.Add("")
$L.Add("## Repos incluidos")
foreach ($inc in $Included) {
    $L.Add("")
    $shaTxt = if ($inc.Sha) { "${bt}$($inc.Sha)${bt} ($($inc.Subject))" } else { $inc.Subject }
    $dirtyTxt = if ($inc.Dirty) { " - working tree con cambios sin commitear" } else { "" }
    $L.Add("### $($inc.Module)  (repo ${bt}$($inc.Repo)${bt})")
    $L.Add("- SHA: $shaTxt$dirtyTxt")
    $L.Add("- Archivos: " + ($inc.Files -join ', '))
    if ($inc.Skipped.Count -gt 0) {
        $L.Add("- Subcarpetas de docs/ NO incluidas (arrastrar aparte si se necesitan): " + ($inc.Skipped -join ', '))
    }
}
$L.Add("")
$L.Add("## Repos sin docs todavia")
$L.Add("")
if ($pending.Count -eq 0) {
    $L.Add("- Ninguno: los $($Repos.Count) repos del ecosistema tienen docs.")
} else {
    $L.Add("- " + (($pending | ForEach-Object { $_.Module }) -join ', ') + " - se sumaran solos cuando reciban su Block de diseno.")
}
$L.Add("")
$L.Add("## Como usarlo")
$L.Add("")
$L.Add("En el Project ${bt}$DesktopProject${bt} de Claude Desktop: borra TODO el contenido")
$L.Add("actual y sustituyelo por los archivos ${bt}<Modulo>_*${bt} de esta carpeta (podes")
$L.Add("omitir ${bt}README.md${bt} y ${bt}sync.ps1${bt}, que son tooling). Regenerar con")
$L.Add("${bt}.\.claude\desktop-sync\sync.ps1${bt}.")

$IndexPath = Join-Path $BundleDir '_SYNC_INDEX.md'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($IndexPath, (($L -join "`r`n") + "`r`n"), $utf8NoBom)

# --- Resumen en consola ---
Write-Host ""
Write-Host "Espejo Code->Desktop regenerado" -ForegroundColor Green
Write-Host "  Carpeta : $BundleDir"
Write-Host "  Project : $DesktopProject (Claude Desktop)"
Write-Host "  Repos   : $($Included.Count) con docs, $totalFiles archivos + _SYNC_INDEX.md"
foreach ($inc in $Included) {
    $tag = if ($inc.Sha) { $inc.Sha } else { 'sin-commits' }
    $flag = if ($inc.Dirty) { ' [dirty]' } else { '' }
    Write-Host ("            - {0,-9} {1}  {2} archivo(s){3}" -f $inc.Module, $tag, $inc.Files.Count, $flag)
}
if ($pending.Count -gt 0) {
    Write-Host "  Pend.   : $((($pending | ForEach-Object { $_.Module }) -join ', ')) (sin docs todavia)"
}
Write-Host "  Proposito: $Purpose"
Write-Host ""
Write-Host "Siguiente: en Desktop, vacia el Project '$DesktopProject' y suelta el contenido de la carpeta." -ForegroundColor Cyan
