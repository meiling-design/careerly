#Requires -Version 5.1
<#
.SYNOPSIS
    Generates the Careerly Android RELEASE keystore and android/key.properties.

.DESCRIPTION
    Run this YOURSELF, on your own machine. The password is typed here and is
    never sent anywhere; it is not passed on the keytool command line either
    (it goes through an environment variable, which keytool reads via
    -storepass:env).

    Why this matters: the release keystore is the app's permanent identity.
    Google Play will REFUSE any future update signed with a different key.
    If you lose the .jks file or its password, you cannot update Careerly
    again under the same listing. Back both up offline before publishing.

.PARAMETER Alias
    Key alias. Default: careerly

.PARAMETER ValidityDays
    Certificate validity. Default: 10000 days (~27 years).
    Google Play requires a validity past 2033-10-22.

.PARAMETER DistinguishedName
    Optional X.500 name, e.g. "CN=Careerly, O=LingDesign, C=CN".
    If omitted, keytool asks interactively.

.PARAMETER Force
    Overwrite an existing keystore / key.properties. Dangerous.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts/gen_keystore.ps1
#>
[CmdletBinding()]
param(
    [string]$Alias = 'careerly',
    [string]$KeystoreName = 'careerly-release.jks',
    [int]$ValidityDays = 10000,
    [string]$DistinguishedName = '',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot   = Split-Path -Parent $ScriptDir
$AndroidDir = Join-Path $RepoRoot 'android'
$KeystorePath = Join-Path $AndroidDir $KeystoreName
$KeyPropertiesPath = Join-Path $AndroidDir 'key.properties'

function Find-Keytool {
    $candidates = @()
    if ($env:JAVA_HOME) { $candidates += (Join-Path $env:JAVA_HOME 'bin\keytool.exe') }

    # Android Studio ships its own JBR; Flutter uses it by default.
    $bases = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, 'D:\Program Files', 'C:\Program Files', 'G:\Program Files')
    foreach ($base in $bases) {
        if ($base) { $candidates += (Join-Path $base 'Android\Android Studio\jbr\bin\keytool.exe') }
    }
    if ($env:LOCALAPPDATA) {
        $candidates += (Join-Path $env:LOCALAPPDATA 'Programs\Android Studio\jbr\bin\keytool.exe')
    }

    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) { return $c }
    }
    $cmd = Get-Command keytool.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Read-PlainPassword([string]$Prompt) {
    $secure = Read-Host -Prompt $Prompt -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) | Out-Null
    }
}

Write-Host ''
Write-Host 'Careerly release keystore generator' -ForegroundColor Cyan
Write-Host '===================================='
Write-Host ''

if (-not (Test-Path -LiteralPath $AndroidDir)) {
    throw "android/ not found at $AndroidDir - is this the Careerly repo root?"
}

# --- Guard against clobbering an existing identity -------------------------
if ((Test-Path -LiteralPath $KeystorePath) -and -not $Force) {
    Write-Host "REFUSING TO CONTINUE: keystore already exists" -ForegroundColor Red
    Write-Host "  $KeystorePath"
    Write-Host ''
    Write-Host 'Overwriting it would create a DIFFERENT app identity and break'
    Write-Host 'every future Play update. If you really mean to regenerate,'
    Write-Host 'delete it yourself first, or pass -Force.'
    exit 1
}

$keytool = Find-Keytool
if (-not $keytool) {
    Write-Host 'ERROR: keytool.exe not found.' -ForegroundColor Red
    Write-Host 'Install Android Studio, or set JAVA_HOME to a JDK, then re-run.'
    exit 1
}
Write-Host "keytool : $keytool"

# --- Password --------------------------------------------------------------
Write-Host ''
Write-Host 'Choose a strong password for the keystore.'
Write-Host '(For a PKCS12 keystore the key password is the same as the store password.)'
$pw1 = Read-PlainPassword 'Keystore password'
$pw2 = Read-PlainPassword 'Confirm password'
if ($pw1 -ne $pw2) {
    Write-Host 'ERROR: passwords do not match. Nothing was written.' -ForegroundColor Red
    exit 1
}
if ($pw1.Length -lt 8) {
    Write-Host 'ERROR: password must be at least 8 characters. Nothing was written.' -ForegroundColor Red
    exit 1
}

# --- Generate --------------------------------------------------------------
$env:CAREERLY_KEYSTORE_PW = $pw1
try {
    $keytoolArgs = @(
        '-genkeypair', '-v',
        '-keystore', $KeystorePath,
        '-storetype', 'PKCS12',
        '-keyalg', 'RSA',
        '-keysize', '2048',
        '-validity', $ValidityDays,
        '-alias', $Alias,
        '-storepass:env', 'CAREERLY_KEYSTORE_PW'
    )
    if ($DistinguishedName) { $keytoolArgs += @('-dname', $DistinguishedName) }

    Write-Host ''
    Write-Host 'Generating keystore...'
    & $keytool @keytoolArgs
    if ($LASTEXITCODE -ne 0) { throw "keytool failed with exit code $LASTEXITCODE" }
} finally {
    Remove-Item Env:\CAREERLY_KEYSTORE_PW -ErrorAction SilentlyContinue
}

# --- Write key.properties --------------------------------------------------
$keyProperties = @"
# Generated by scripts/gen_keystore.ps1
# NEVER commit this file. It is ignored by android/.gitignore.
storePassword=$pw1
keyPassword=$pw1
keyAlias=$Alias
storeFile=../$KeystoreName
"@
Set-Content -LiteralPath $KeyPropertiesPath -Value $keyProperties -Encoding ASCII

# --- Verify it is ignored by git ------------------------------------------
Write-Host ''
Write-Host 'Checking git ignore rules...' -ForegroundColor Cyan
foreach ($p in @($KeystorePath, $KeyPropertiesPath)) {
    $rel = $p.Substring($RepoRoot.Length + 1) -replace '\\', '/'
    $ignored = & git -C $RepoRoot check-ignore -q $rel 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK      ignored: $rel" -ForegroundColor Green
    } else {
        Write-Host "  DANGER  NOT ignored: $rel" -ForegroundColor Red
        Write-Host "          Do NOT commit it. Fix .gitignore before proceeding."
    }
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Yellow
Write-Host ' BACK THIS UP NOW - offline, in two places.' -ForegroundColor Yellow
Write-Host '============================================================' -ForegroundColor Yellow
Write-Host "  keystore : $KeystorePath"
Write-Host "  password : (the one you just typed - store it in your password manager)"
Write-Host ''
Write-Host ' If you lose either, you can never update this app on Google Play'
Write-Host ' again. Google Play App Signing can help, but only if you enrolled'
Write-Host ' and uploaded this key as your upload key.'
Write-Host ''
Write-Host 'Next: flutter build appbundle --release' -ForegroundColor Cyan
