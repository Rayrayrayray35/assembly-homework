param(
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [Parameter(Mandatory=$true)][string]$Program
)
$dosbox = "C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe"
if (-not (Test-Path $dosbox)) { throw "DOSBox not found: $dosbox" }
& $dosbox -c "mount c `"$WorkDir`"" -c "c:" -c "$Program" -c "exit"
