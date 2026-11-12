param(
    [ValidateSet('template_release', 'template_debug')]
    [string]$Target = 'template_release',
    [ValidateSet('no', 'yes')]
    [string]$Threads = 'no',
    [ValidateSet('wasm32', 'wasm64')]
    [string]$Arch = 'wasm32',
    [ValidateSet('yes', 'no')]
    [string]$DlinkEnabled = 'yes',
    [int]$Jobs = 8,
    [string]$SdkPath = (Join-Path $PSScriptRoot '..\emsdk'),
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
$sdkEnvironment = Join-Path $SdkPath 'emsdk_env.ps1'
if (!(Test-Path -LiteralPath $sdkEnvironment)) {
    throw "Emscripten SDK not found: $sdkEnvironment. Use -SdkPath to select your SDK."
}
. $sdkEnvironment
if (!(Get-Command emcc -ErrorAction SilentlyContinue)) {
    throw 'emcc is unavailable after loading the SDK. Install and activate Emscripten first.'
}

Push-Location $PSScriptRoot
try {
    if ($Check) {
        & emcc --version
        if ($LASTEXITCODE -ne 0) { throw 'emcc verification failed.' }
        & python -m SCons platform=list
    } else {
        & python -m SCons platform=web "target=$Target" "arch=$Arch" "threads=$Threads" "dlink_enabled=$DlinkEnabled" "-j$Jobs"
    }
    if ($LASTEXITCODE -ne 0) { throw "SCons failed with exit code $LASTEXITCODE." }
} finally {
    Pop-Location
}
