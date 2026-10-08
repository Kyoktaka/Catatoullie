param(
    [string]$ProcessingHome = "$env:ProgramFiles\Processing",
    [string]$VideoLibrary
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
if (-not $VideoLibrary) { throw 'Pass -VideoLibrary with the folder containing video.jar, gst1-java-core and jna.jar.' }
$buildDir = Join-Path $PSScriptRoot ('tmp\sketch-check-' + [guid]::NewGuid().ToString('N').Substring(0,8))
$appJars = Join-Path $ProcessingHome 'app\*'
Push-Location $PSScriptRoot
try {
    & $javaExe "-Dcompose.application.resources.dir=$resourceRoot" -cp $appJars processing.mode.java.Commander "--sketch=$PSScriptRoot" "--output=$buildDir" --build
    if ($LASTEXITCODE -ne 0) { throw 'Processing compilation failed.' }
    $testCp = "$buildDir;$appJars;$VideoLibrary\*"
    & $javacExe -cp $testCp -d $buildDir 'tests\SketchSmokeTest.java'
    if ($LASTEXITCODE -ne 0) { throw 'Smoke-test compilation failed.' }
    & $javaExe '-Djava.awt.headless=true' -cp $testCp SketchSmokeTest
    if ($LASTEXITCODE -ne 0) { throw 'Sketch smoke tests failed.' }
} finally { Pop-Location }
