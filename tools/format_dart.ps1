param(
    [switch]$Check
)

$dartFiles = Get-ChildItem -Path 'lib' -Recurse -Filter '*.dart' -File |
    Where-Object {
        $_.Name -notmatch '\.(g|gr|freezed|config|gen)\.dart$' -and
        $_.FullName -notmatch '[\\/]generated[\\/]'
    } |
    ForEach-Object { $_.FullName }

$formatArguments = @('dart', 'format')
if ($Check) {
    $formatArguments += @('--output=none', '--set-exit-if-changed')
}
$formatFailed = $false
for ($offset = 0; $offset -lt $dartFiles.Count; $offset += 50) {
    $end = [Math]::Min($offset + 49, $dartFiles.Count - 1)
    $batch = $dartFiles[$offset..$end]
    $arguments = $formatArguments + $batch

    & fvm @arguments
    if ($LASTEXITCODE -ne 0) {
        $formatFailed = $true
    }
}

if ($formatFailed) {
    exit 1
}
