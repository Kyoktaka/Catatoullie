param(
    [string]$JavaHome
)

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$javaCandidates = New-Object 'System.Collections.Generic.List[string]'

# Prefer an explicitly supplied JDK, then the JDK bundled with Processing.
if ($JavaHome) { $javaCandidates.Add($JavaHome) }
if ($env:ProgramFiles) {
    $javaCandidates.Add((Join-Path $env:ProgramFiles 'Processing\app\resources\jdk'))
}
$processingCommand = Get-Command Processing -ErrorAction SilentlyContinue
if ($processingCommand -and $processingCommand.Source) {
    $processingDirectory = Split-Path -Parent $processingCommand.Source
    $javaCandidates.Add((Join-Path $processingDirectory 'app\resources\jdk'))
}
if ($env:JAVA_HOME) { $javaCandidates.Add($env:JAVA_HOME) }

$javacPath = $null
$javaPath = $null
foreach ($candidate in $javaCandidates) {
    $compiler = Join-Path $candidate 'bin\javac.exe'
    $runtime = Join-Path $candidate 'bin\java.exe'
    if ((Test-Path -LiteralPath $compiler -PathType Leaf) -and
        (Test-Path -LiteralPath $runtime -PathType Leaf)) {
        $javacPath = $compiler
        $javaPath = $runtime
        break
    }
}

if (-not $javacPath) {
    $compilerCommand = Get-Command javac -ErrorAction SilentlyContinue
    $runtimeCommand = Get-Command java -ErrorAction SilentlyContinue
    if ($compilerCommand -and $runtimeCommand) {
        $javacPath = $compilerCommand.Source
        $javaPath = $runtimeCommand.Source
    }
}
if (-not $javacPath -or -not $javaPath) {
    throw 'A Java 17 or newer JDK is required. Install Processing 4, set JAVA_HOME, or pass -JavaHome with your JDK folder.'
}

$buildDirectory = Join-Path $projectRoot 'tmp\model-tests'
New-Item -ItemType Directory -Path $buildDirectory -Force | Out-Null
$modelSource = Join-Path $projectRoot 'GameModel.java'
$testSource = Join-Path $projectRoot 'tests\GameModelTest.java'

Write-Host "Compiling model tests with $javacPath"
& $javacPath --release 17 -encoding UTF-8 -d $buildDirectory $modelSource (Join-Path $projectRoot 'WardrobeInventory.java') (Join-Path $projectRoot 'CookingModel.java') (Join-Path $projectRoot 'PreparedLayout.java') (Join-Path $projectRoot 'CookingRecipes.java') $testSource (Join-Path $projectRoot 'tests\CookingModelTest.java') (Join-Path $projectRoot 'MealModel.java') (Join-Path $projectRoot 'tests\MealModelTest.java')
if ($LASTEXITCODE -ne 0) { throw "Model compilation failed (exit $LASTEXITCODE)." }

& $javaPath -cp $buildDirectory GameModelTest
if ($LASTEXITCODE -ne 0) { throw "Model tests failed (exit $LASTEXITCODE)." }
& $javaPath -cp $buildDirectory CookingModelTest
if ($LASTEXITCODE -ne 0) { throw "Cooking model tests failed (exit $LASTEXITCODE)." }

& $javaPath -cp $buildDirectory MealModelTest
if ($LASTEXITCODE -ne 0) { throw "Meal model tests failed (exit $LASTEXITCODE)." }
