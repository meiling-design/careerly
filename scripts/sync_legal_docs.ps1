#Requires -Version 5.1
<#
.SYNOPSIS
    Mirrors the legal documents from the app bundle into work_agent's release docs.

.DESCRIPTION
    careerly/assets/legal/*.md is the SINGLE SOURCE OF TRUTH for the legal texts.
    They are bundled into the app (see the `assets:` section of pubspec.yaml) and
    are what the in-app 用户协议 / 隐私政策 pages render.

    work_agent/docs/09_Release/ holds the same three files as a MIRROR. That copy
    exists because docs/09_Release/ is where release artefacts live, and because
    an externally hosted copy will eventually be needed for the Google Play
    Privacy Policy URL (TODO.md section 1.0f, item E4 - still blocked on D121).

    Editing the mirror directly is a mistake: the next run overwrites it. Edit
    assets/legal/ instead, then run this script.

    The copy is BYTE-FOR-BYTE - no header is injected - so that -Check can compare
    without normalising anything away.

    PENDING DECISION (D122, TODO.md section 3.1): the SOURCE -> MIRROR direction
    was proposed by the Flutter side to reconcile two conflicting TODO statements
    (item E1 puts the documents in docs/09_Release/, item E3 calls
    assets/legal/*.md the only in-app source). It has NOT been confirmed by the
    product side. If the ruling reverses it, this script must be inverted - the
    consumers do not need to change, only this direction.

.PARAMETER TargetDir
    Directory to mirror into. Defaults to ../work_agent/docs/09_Release relative
    to this repository's root.

.PARAMETER Check
    Verify only. Writes nothing; exits 1 if any file differs or is missing.
    Use this to detect drift without changing anything.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts/sync_legal_docs.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts/sync_legal_docs.ps1 -Check
#>
[CmdletBinding()]
param(
    [string]$TargetDir = '',
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir
$SourceDir = Join-Path $RepoRoot 'assets\legal'

if (-not $TargetDir) {
    $SiblingRepo = Split-Path -Parent $RepoRoot
    $TargetDir = Join-Path $SiblingRepo 'work_agent\docs\09_Release'
}

# --- Preconditions -----------------------------------------------------------

if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
    Write-Host "Source directory not found: $SourceDir" -ForegroundColor Red
    exit 2
}

$SourceFiles = @(Get-ChildItem -LiteralPath $SourceDir -Filter '*.md' -File | Sort-Object Name)
if ($SourceFiles.Count -eq 0) {
    Write-Host "Source directory has no .md files: $SourceDir" -ForegroundColor Red
    exit 2
}

if (-not (Test-Path -LiteralPath $TargetDir -PathType Container)) {
    if ($Check) {
        Write-Host "Target directory not found: $TargetDir" -ForegroundColor Red
        exit 1
    }
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# --- Compare / copy ----------------------------------------------------------

Write-Host "Source : $SourceDir"
Write-Host "Target : $TargetDir"
Write-Host "Mode   : $(if ($Check) { 'check only' } else { 'write' })"
Write-Host ''

$Drift      = 0
$Copied     = 0
$Unchanged  = 0

foreach ($SourceFile in $SourceFiles) {
    $TargetPath = Join-Path $TargetDir $SourceFile.Name

    $SourceBytes = [System.IO.File]::ReadAllBytes($SourceFile.FullName)
    $TargetBytes = $null
    if (Test-Path -LiteralPath $TargetPath -PathType Leaf) {
        $TargetBytes = [System.IO.File]::ReadAllBytes($TargetPath)
    }

    $Same = $false
    if ($null -ne $TargetBytes -and $TargetBytes.Length -eq $SourceBytes.Length) {
        $Same = $true
        for ($i = 0; $i -lt $SourceBytes.Length; $i++) {
            if ($SourceBytes[$i] -ne $TargetBytes[$i]) { $Same = $false; break }
        }
    }

    if ($Same) {
        Write-Host ("  [ok]      {0}" -f $SourceFile.Name) -ForegroundColor DarkGray
        $Unchanged++
        continue
    }

    $Drift++
    if ($Check) {
        $Reason = if ($null -eq $TargetBytes) { 'missing' } else { 'differs' }
        Write-Host ("  [DRIFT]   {0} ({1})" -f $SourceFile.Name, $Reason) -ForegroundColor Yellow
    }
    else {
        [System.IO.File]::WriteAllBytes($TargetPath, $SourceBytes)
        Write-Host ("  [copied]  {0}" -f $SourceFile.Name) -ForegroundColor Green
        $Copied++
    }
}

# --- Report ------------------------------------------------------------------

Write-Host ''
Write-Host ("Files: {0} total, {1} unchanged, {2} {3}" -f `
    $SourceFiles.Count, $Unchanged, $Drift, $(if ($Check) { 'drifted' } else { 'copied' }))

if ($Check -and $Drift -gt 0) {
    Write-Host 'The mirror is out of date. Run without -Check to refresh it.' -ForegroundColor Yellow
    exit 1
}

if (-not $Check -and $Copied -gt 0) {
    Write-Host 'Remember: the mirror is generated output. Edit assets/legal/ instead.' -ForegroundColor DarkGray
}

exit 0
