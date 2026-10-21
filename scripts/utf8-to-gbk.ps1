param(
    [string]$Source = "src",
    [string]$Dest = "build/gbk"
)

$ErrorActionPreference = "Stop"
$src = (Resolve-Path $Source).Path
$dst = Join-Path (Get-Location) $Dest
New-Item -ItemType Directory -Force -Path $dst | Out-Null

Get-ChildItem $src -Recurse -File -Include *.asm, *.c | ForEach-Object {
    $text = [IO.File]::ReadAllText($_.FullName, [Text.UTF8Encoding]::new($false))
    $text = $text -replace "`r?`n", "`r`n"
    $out = Join-Path $dst $_.Name
    [IO.File]::WriteAllText($out, $text, [Text.Encoding]::GetEncoding(936))
    Write-Output ("{0} -> {1}" -f $_.Name, $out)
}
