$shell32 = New-Object -ComObject Shell.Application

# build a list of shortcuts to process
$files = @(Get-ChildItem *.lnk -LiteralPath (Join-Path $env:USERPROFILE "Shortcuts"))

foreach ($file in $files) {
    # read the shortcut's properties
    $shortcut = $shell32.Namespace(0).ParseName($file).GetLink
    # copy the original file to some destination
    Copy-Item -LiteralPath $shortcut.Path -Destination (Join-Path $env:USERPROFILE "Downloads")
}
