#$root = "C:\\ProgramVideoGames"
$root = "E:\\Apps"

if (!(Test-Path $root)) {
    New-Item -Path "C:\" -Name "ProgramVideoGames" -ItemType Directory
}

#$bt_path = "$root\\BuildTools"
$bt_path = "$root\\VSCppBuildTools"
if (Test-Path $bt_path) {
    Write-Host "Portable Build Tools is already installed." -ForegroundColor Green
} else {
    Write-Host "Installing Portable Build Tools in $bt_path"
    $url = "https://github.com/Data-Oriented-House/PortableBuildTools/releases/latest/download/PortableBuildTools.exe"
    $dst = "$root\\PortableBuildTools.exe"
    Start-BitsTransfer -Source $url -Destination $dst -DisplayName "Downlaoding Portable Build Tools" -Description "Downloading Portable Build Tools..."
    Start-Process -FilePath $dst -ArgumentList "cli accept_license install_path=$($bt_path)" -NoNewWindow -Wait
    Remove-Item -Path $dst -Force
}

#$odin_path = "$root\\Odin"
$odin_path = "$root\\_odin"
if (Test-Path "$odin_path\\odin.exe") {
    Write-Host "Odin is already installed." -ForegroundColor Green
} else {
    Write-Host "Downloading Odin"
    $url = "https://api.github.com/repos/odin-lang/Odin/releases/latest"
    $res = Invoke-RestMethod -Uri $url
    foreach ($asset in $res.assets) {
        if ($asset.name -match "windows-amd64") {
            $dst = "$root\\$($asset.name)"
            #if (!(Test-Path $dst)) {
            #    New-Item -Path $dst -ItemType Directory
            #}

            Start-BitsTransfer -Source $asset.browser_download_url -Destination $dst -DisplayName "Downloading Odin" -Description "Downloading Odin..."
            Write-Host "Odin downloaded. Unpacking..."
            Expand-Archive -Path $dst -DestinationPath $odin_path -Force

            $file = Get-ChildItem -Path $odin_path -Recurse -Filter "odin.exe" | Select-Object -First 1
            if ($file) {
                Write-Host "Odin unpacked. Modifying BuildTools script..."
                Add-Content -Path "$bt_path\\devcmd.bat" -Value "`nset PATH=%PATH%;$($file.DirectoryName)"
            } else {
                Write-Host "Failed to find odin.exe" -ForegroundColor Red
            }

            Remove-Item -Path $dst -Force
        }
    }
}

Write-Host "If you got this far without errors, looks good." -ForegroundColor Green

Write-Host "Press any key to continue..."
Read-Host