param([string]$ProcessingHome="$env:ProgramFiles\Processing",[string]$VideoLibrary="$env:USERPROFILE\OneDrive\Documents\Processing\libraries\video\library")
$ErrorActionPreference='Stop'
$runtimeRoot=Join-Path $ProcessingHome 'app\resources\jdk\bin'
$videoTestDir=Join-Path $PSScriptRoot 'tmp\video-check'
New-Item -ItemType Directory -Force -Path $videoTestDir,(Join-Path $PSScriptRoot 'tmp\qa-kitchen') | Out-Null
$videoTestCp="$ProcessingHome\app\*;$VideoLibrary\*;$videoTestDir"
$videoOriginalPath=$env:PATH
Push-Location $PSScriptRoot
try {
  $videoGameBuild=Join-Path $PSScriptRoot ('tmp\video-sketch-'+[guid]::NewGuid().ToString('N').Substring(0,8))
  $resourceRoot=Join-Path $ProcessingHome 'app\resources'
  & (Join-Path $runtimeRoot 'java.exe') "-Dcompose.application.resources.dir=$resourceRoot" -cp "$ProcessingHome\app\*" processing.mode.java.Commander "--sketch=$PSScriptRoot" "--output=$videoGameBuild" --build
  if($LASTEXITCODE -ne 0){throw 'Processing compilation failed.'}
  $videoTestCp="$videoGameBuild;$videoTestCp"
  & (Join-Path $runtimeRoot 'javac.exe') -encoding UTF-8 -cp $videoTestCp -d $videoTestDir 'tests\EndingPlaybackTest.java'
  if($LASTEXITCODE -ne 0){throw 'Video test compilation failed.'}
  $gstNative=Join-Path $VideoLibrary 'windows-amd64'
  $env:PATH="$gstNative;$videoOriginalPath"
  $videoResult=Join-Path $videoTestDir ('passed-'+[guid]::NewGuid().ToString('N')+'.txt')
  $videoStart=[System.Diagnostics.ProcessStartInfo]::new()
  $videoStart.FileName=Join-Path $runtimeRoot 'java.exe'
  $videoStart.UseShellExecute=$false
  $videoStart.CreateNoWindow=$true
  $videoStart.RedirectStandardOutput=$true
  $videoStart.RedirectStandardError=$true
  foreach($videoArg in @('-Djava.awt.headless=true',"-Dgstreamer.library.path=$gstNative","-Dgstreamer.plugin.path=$gstNative\gstreamer-1.0","-Dcatatoullie.video.result=$videoResult",'-cp',$videoTestCp,'EndingPlaybackTest')){$videoStart.ArgumentList.Add($videoArg)}
  $videoProcess=[System.Diagnostics.Process]::Start($videoStart)
  $videoStdout=$videoProcess.StandardOutput.ReadToEndAsync()
  $videoStderr=$videoProcess.StandardError.ReadToEndAsync()
  if(-not $videoProcess.WaitForExit(35000)){
    # GStreamer's native DLL shutdown can stall in a surface-free harness.
    # Kill only this owned child after giving both playback assertions time to run.
    $videoProcess.Kill();$videoProcess.WaitForExit()
  }
  Write-Host $videoStdout.GetAwaiter().GetResult()
  if(-not (Test-Path -LiteralPath $videoResult)){Write-Host $videoStderr.GetAwaiter().GetResult();throw 'Actual video playback failed; see decoder output.'}
  Write-Host (Get-Content -LiteralPath $videoResult)
} finally {$env:PATH=$videoOriginalPath;Pop-Location}
