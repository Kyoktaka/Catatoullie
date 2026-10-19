param(
    [string]$ProcessingHome = "$env:ProgramFiles\Processing",
    [string]$VideoLibrary,
    [string]$OutputDirectory = 'tmp/performance',
    [switch]$Pacing
)
$ErrorActionPreference = 'Stop'
$resourceRoot = Join-Path $ProcessingHome 'app\resources'
$javaExe = Join-Path $resourceRoot 'jdk\bin\java.exe'
$javacExe = Join-Path $resourceRoot 'jdk\bin\javac.exe'
if (-not (Test-Path -LiteralPath $javaExe)) { throw 'Processing 4 is required. Pass -ProcessingHome if installed elsewhere.' }
if (-not $VideoLibrary) {
    $videoCandidates = @(
        "$env:USERPROFILE\OneDrive\Documents\Processing\libraries\video\library",
        "$env:USERPROFILE\Documents\Processing\libraries\video\library"
    )
    $VideoLibrary = $videoCandidates | Where-Object { Test-Path -LiteralPath (Join-Path $_ 'video.jar') } | Select-Object -First 1
}
if (-not $VideoLibrary) { throw 'Pass -VideoLibrary with the folder containing video.jar.' }
$buildDir = Join-Path $PSScriptRoot ('tmp\performance-build-' + [guid]::NewGuid().ToString('N').Substring(0,8))
$appJars = Join-Path $ProcessingHome 'app\*'
Push-Location $PSScriptRoot
try {
    & $javaExe "-Dcompose.application.resources.dir=$resourceRoot" -cp $appJars processing.mode.java.Commander "--sketch=$PSScriptRoot" "--output=$buildDir" --build
    if ($LASTEXITCODE -ne 0) { throw 'Processing compilation failed.' }
    $testCp = "$buildDir;$appJars;$VideoLibrary\*"
    & $javacExe -encoding UTF-8 -cp $testCp -d $buildDir tests/PerformanceProbe.java tests/FramePacingProbe.java
    if ($LASTEXITCODE -ne 0) { throw 'Performance probe compilation failed.' }
    & $javaExe '-Djava.awt.headless=true' -cp $testCp PerformanceProbe $OutputDirectory
    if ($LASTEXITCODE -ne 0) { throw 'Render benchmark failed.' }
    if ($Pacing) {
        & $javaExe -cp $testCp FramePacingProbe $OutputDirectory
        if ($LASTEXITCODE -ne 0) { throw 'Frame pacing probe failed.' }
    }
} finally { Pop-Location }
