function Install-Chrome {
    $LocalTempDir = $env:TEMP;
    $ChromeInstaller = "ChromeInstaller.exe";
    (new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/latest/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller");
    & "$LocalTempDir\$ChromeInstaller" /silent /install;
    $Process2Monitor = "ChromeInstaller";
    Do {
        $ProcessesFound = Get-Process | ? { $Process2Monitor -contains $_.Name } | Select-Object -ExpandProperty Name;
        If ($ProcessesFound) {
            "Still running: $($ProcessesFound -join ', ')" | Write-Host;
            Start-Sleep -Seconds 2
        }
        else {
            rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose
        }
    }
    Until (!$ProcessesFound)
    Write-Host "Google Chrome Installed Successfully." -ForegroundColor Green
}
Install-Chrome

function Install-7zipNpp ($source = ($env:TEMP + "\SW")) {    
    If (!(Test-Path -Path $source -PathType Container)) { New-Item -Path $source -ItemType Directory | Out-Null }
    
    $packages = @(
        @{title = '7zip Extractor'; url = 'https://www.7-zip.org/a/7z1900-x64.msi'; Arguments = ' /qn'; Destination = $source },
        @{title = 'Notepad++ 7.8.9'; url = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.9/npp.7.8.9.Installer.exe'; Arguments = ' /Q /S'; Destination = $source }
    )
    
    foreach ($package in $packages) {
        $packageName = $package.title
        $fileName = Split-Path $package.url -Leaf
        $destinationPath = $package.Destination + "\" + $fileName
    
        If (!(Test-Path -Path $destinationPath -PathType Leaf)) {
    
            Write-Host "Downloading $packageName"
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($package.url, $destinationPath)
        }
    }
    
    foreach ($package in $packages) {
        $packageName = $package.title
        $fileName = Split-Path $package.url -Leaf
        $destinationPath = $package.Destination + "\" + $fileName
        $Arguments = $package.Arguments
        Write-Output "Installing $packageName"
    
    
        Invoke-Expression -Command "$destinationPath $Arguments"
    }
}
Install-7zipNpp


$trainingURLs = @("https://docs.uipath.com/orchestrator/v2019/docs/prerequisites-for-installation", "https://docs.uipath.com/orchestrator/v2019/docs/haa-installation", "https://docs.uipath.com/orchestrator/v2019/docs/the-windows-installer" )

$wshShell = New-Object -ComObject "WScript.Shell"
foreach ($url in $trainingURLs) {
    $urlName = $url.Substring($url.LastIndexOf("/") + 1)
    $Shortcut = $wshShell.CreateShortcut(
        (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "$urlName.url")
    )
    $Shortcut.TargetPath = $url
    $Shortcut.Save()
}

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

Disable-InternetExplorerESC