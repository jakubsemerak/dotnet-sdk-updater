# Update to the latest version of the .NET SDK
# Run as Admin or approve the UAC propt when upgrading.

# Parse webpage to get current dotnet version available.
Write-Host "Running dotnet SDK update $(Get-Date)."

$base = "https://dotnet.microsoft.com"
$url = "$base/en-us/download"
$webpage = Invoke-WebRequest -Uri $url
$latestVersionInstalled = (dotnet --list-sdks | Select-Object -Last 1).Split()[0]

$relativeDownloadPath = ($webpage.Links | Where-Object { $_.href -like "*windows-x64-installer" } | Select-Object -First 1 -expand href)

if (-not $relativeDownloadPath) {
    Write-Host "Relative dotnet SDK download path not found."
    exit
}

$versionToBeInstalled = (Select-String -InputObject $relativeDownloadPath -Pattern '\d+.\d+.\d+').Matches.Value;

if ($latestVersionInstalled -ge $versionToBeInstalled) {
    Write-Host "Latest dotnet SDK version $latestVersionInstalled is already installed."
    exit
}

$downloadPageUri = ($base + $relativeDownloadPath)
$downloadPage = Invoke-WebRequest -Uri $downloadPageUri
$fileLink = ($downloadPage.Links | Where-Object { $_.href -like "*-win-x64.exe" } | Select-Object -First 1 -expand href)

if (-not $fileLink) {
    Write-Host "File download link not found on the $downloadPageUri."
    exit
}

$output = "./dotnet-sdk-$versionToBeInstalled.exe"

# Download
Write-Host "Downloading $fileLink."
Invoke-WebRequest -Uri $fileLink -OutFile $output
Write-Host "Done. Starting installation."

# Install the downloaded SDK
Start-Process -FilePath $output -ArgumentList '/quiet /norestart' -Wait
Write-Host "New dotnet SDK version $versionToBeInstalled was succesfully installed."

# Cleanup
Write-Host "Removing downloaded SDK file"
Remove-Item $output