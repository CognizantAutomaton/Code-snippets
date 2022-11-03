[string]$ImageMagickPath = "C:\Program Files\ImageMagick-7.1.0-Q16-HDRI\magick.exe"
[string]$PathToProcess = Join-Path $env:USERPROFILE "Pictures"

$ErrorActionPreference = "Stop"

$imgs = @(@(Get-ChildItem -Filter "*.webp" -LiteralPath $PathToProcess) | Where-Object {
    ($_.LastWriteTime -gt (Get-Date '2022-09-02')) -and ($_.LastWriteTime -lt (Get-Date '2022-09-03'))
})

function Test-IsWebPAnimated([Parameter(Mandatory=$true)][string]$Path) {
    if ($Path.ToLower().EndsWith(".webp")) {
        [byte[]]$bytes = [byte[]]::CreateInstance([byte], 4)

        $reader = New-Object System.IO.BinaryReader((New-Object System.IO.FileStream($Path, "Open")))

        # read header bytes
        [void]$reader.BaseStream.Seek(12, "Begin")
        [void]$reader.Read($bytes, 0, 4)

        $header = [System.Text.Encoding]::ASCII.GetString($bytes)

        if ($header -eq "VP8X") {
            [void]$reader.BaseStream.Seek(4, "Current")
            $b = [byte]$reader.ReadByte()
            $reader.Close()
            return ((($b -shr 1) -band 1) -eq 1)
        }

        $reader.Close()
    }

    return $false
}

foreach ($img in $imgs) {
    [bool]$IsAnimated = Test-IsWebPAnimated -Path $img.FullName
    [string]$DirectoryPath = [IO.Path]::GetDirectoryName($img.FullName)
    [string]$BaseFilename = [IO.Path]::GetFilenameWithoutExtension($img.Name)
    [string]$NewFilename = if ($IsAnimated) {"$BaseFilename.gif"} else {"$BaseFilename.jpg"}
    $NewFilename = Join-Path $DirectoryPath $NewFilename

    if (-not (Test-Path -LiteralPath $NewFilename)) {
        Write-Host "Converting '$($img.FullName)' to '$NewFilename'"
        #& magick $file.FullName $NewFilename
        #Start-Process -FilePath $Sync.MagickPath -ArgumentList @($file.FullName, $NewFilename) -Wait
        & $ImageMagickPath $img.FullName $NewFilename

        $NewFile = Get-Item -LiteralPath $NewFilename
        $NewFile.LastWriteTime = $img.LastWriteTime
        $NewFile.CreationTime = $img.CreationTime
    }

    Start-Sleep -Milliseconds 200

    Remove-Item -LiteralPath $img.FullName
}
