$NewPath = Join-Path $env:USERPROFILE "Destination"

if (-not (Test-Path -LiteralPath $NewPath)) {
    mkdir $NewPath
}

$files = @(Get-Content -LiteralPath (Join-Path $env:USERPROFILE "Documents\source.txt") -Encoding UTF8)

foreach ($file in $files) {
    if ((Test-Path -LiteralPath $file)) {
        Copy-Item -LiteralPath $file -Destination $NewPath
    } else {
        Write-Host "Cannot find '$file'"
    }
}
