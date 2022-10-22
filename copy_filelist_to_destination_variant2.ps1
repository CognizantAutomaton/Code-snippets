$NewPath = Join-Path $env:USERPROFILE "Destination"

if (-not (Test-Path -LiteralPath $NewPath)) {
    mkdir $NewPath
}

$files = @(Get-Content -LiteralPath (Join-Path $env:USERPROFILE "Documents\source.txt") -Encoding UTF8)

foreach ($file in $files) {
    $ParentDir = [IO.Path]::GetDirectoryName($file)
    $ParentDir = $ParentDir.Replace((Join-Path $env:USERPROFILE "Documents"), $NewPath)

    if (-not (Test-Path -LiteralPath $ParentDir)) {
        mkdir $ParentDir | Out-Null
    }

    $FullPath = Join-Path $ParentDir ([IO.Path]::GetFileName($file))

    if ((Test-Path -LiteralPath $file)) {
        if (-not (Test-Path -LiteralPath $FullPath)) {
            Copy-Item -LiteralPath $file -Destination $ParentDir
        }
    } else {
        Write-Host "Cannot find '$file'"
    }
}
